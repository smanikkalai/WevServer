
    # The configuration for the `remote` backend.
terraform {
    backend "remote" {
        organization = "ProjectOfWebserver"
                # The name of the Terraform Cloud workspace to store Terraform state files in.

        workspaces {
          name = "Platform1-dev"
        }
    }
}

    # An example resource that does nothing.
resource "null_resource" "ProjectOfWebserver" {
    triggers = {
        value = "Hello. this is creating e-commerce website..."
    }
}