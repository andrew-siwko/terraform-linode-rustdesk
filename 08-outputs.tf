output "linode_instance_public_ip" {
  value   = one(linode_instance.asiwko-rustdesk-01.ipv4)
}

# output "machine_info-01" {
#   value = {
#     id     = linode_instance.asiwko-rustdesk-01.id
#     label  = linode_instance.asiwko-rustdesk-01.label
#     ipv4   = one(linode_instance.asiwko-rustdesk-01.ipv4)
#     ipv6   = linode_instance.asiwko-rustdesk-01.ipv6
#     region = linode_instance.asiwko-rustdesk-01.region
#   }
# }
