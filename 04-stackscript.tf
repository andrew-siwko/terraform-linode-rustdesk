locals {
  rustdesk_fqdn = "rustdesk.${var.domain_name}"
}

resource "linode_stackscript" "rustdesk_install" {
  label       = "rustdesk-install"
  description = "Installs Docker and brings up the RustDesk hbbs/hbbr relay server."
  script = templatefile("${path.module}/scripts/install-rustdesk.sh.tpl", {
    relay_fqdn = local.rustdesk_fqdn
  })
  images = ["linode/rocky9"]
}
