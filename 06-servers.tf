resource "linode_instance" "asiwko-rustdesk-01" {
  image = "linode/rocky9"
  label = "asiwko-rustdesk-01"
  region          = var.instance_region
  type            = var.instance_type
  authorized_keys = [trimspace(file("/container_shared/ansible/ansible_rsa.pub"))]
  root_pass       = trimspace(file("/container_shared/ansible/linode-root-pw.txt"))
}
