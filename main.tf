terraform {
  cloud {
    organization = "ProjectOfWebserver"

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