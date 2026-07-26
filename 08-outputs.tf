output "linode_instance_public_ip" {
  value   = one(linode_instance.asiwko-rustdesk-01.ipv4)
}
