data "aws_iam_policy_document" "ebs" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["pods.eks.amazonaws.com"]
    }
    actions = [
      "sts:AssumeRole",
      "sts:TagSession"
    ]
  }
}

resource "aws_iam_policy" "ebs" {
  name = "AwsEbsDriver"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "kms:Decrypt",
          "kms:GenerateDataKeyWithoutPlaintext",
          "kms:CreateGrant"
        ]
        Resource = "*" # <- restrict later
      }
    ]
    }
  )

}

resource "aws_iam_role" "ebs" {
  name               = "${aws_eks_cluster.this.name}-ebs-driver"
  assume_role_policy = data.aws_iam_policy_document.ebs.json
}

resource "aws_iam_role_policy_attachment" "ebs" {
  role       = aws_iam_role.ebs.name
  policy_arn = aws_iam_policy.ebs.arn
}

resource "aws_eks_pod_identity_association" "ebs" {
  cluster_name    = aws_eks_cluster.this.name
  namespace       = "kube-system"
  service_account = "ebs-csi-contoller-sa"
  role_arn        = aws_iam_role.ebs.arn
}

resource "aws_eks_addon" "ebs_csi" {
  cluster_name = aws_eks_cluster.this.name
  addon_name = "aws-ebs-csi-driver"
  resolve_conflicts_on_update = "OVERWRITE"

  depends_on = [ 
    aws_eks_node_group.this,
    aws_eks_addon.pod_identity_agent,
    aws_eks_pod_identity_association.ebs,
    aws_iam_role_policy_attachment.ebs
   ]
}

