output "cluster_id" {
  value = aws_eks_cluster.my.id
}

output "node_group_id" {
  value = aws_eks_node_group.my.id
}

output "vpc_id" {
  value = aws_vpc.my_vpc.id
}

output "subnet_ids" {
  value = aws_subnet.my_subnet[*].id
}
