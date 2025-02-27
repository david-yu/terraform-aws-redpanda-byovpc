data "aws_iam_policy_document" "redpanda_node_group_trust" {
  statement {
    effect = "Allow"
    actions = [
      "sts:AssumeRole",
    ]
    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "redpanda_node_group" {
  assume_role_policy    = data.aws_iam_policy_document.redpanda_node_group_trust.json
  force_detach_policies = true
  name_prefix           = "${var.common_prefix}-rp-"
  path                  = "/"
}

resource "aws_iam_instance_profile" "redpanda_node_group" {
  name_prefix = "${var.common_prefix}-rp-"
  path        = "/"
  role        = aws_iam_role.redpanda_node_group.name
}

resource "aws_iam_role_policy_attachment" "redpanda_node_group" {
  for_each = {
    "1" = aws_iam_policy.aws_ebs_csi_driver_policy.arn
    "2" = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
    "3" = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
    "4" = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  }
  policy_arn = each.value
  role       = aws_iam_role.redpanda_node_group.name
}
