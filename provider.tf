/*

Reference the provider documentation below for more information:

https://www.terraform.io/docs/providers/akamai/

Note: attributes can be initialized via TF variables. This is helpful if using secrets management like Vault.

*/
terraform {
  required_providers {
    akamai = {
      source = "akamai/akamai"
      version = "1.2.1"
    }
  }
}
provider "akamai" {
    
    # Path to edgerc file (ex: /home/ubuntu/.edgerc)
    edgerc = "/home/jalane/.edgerc"
    config_section = "papi"
}
