resource "akamai_edge_hostname" "myEdgeHostname" {
    edge_hostname = "jalane-vod.akamaized.net"
    group_id = data.akamai_group.default.id
    contract_id = data.akamai_contract.default.id
    product_id = var.product_id

    # The CPS enrollment ID which can support the edge hostname, defined above
    #certificate = "${var.enrollment_id}"
    ip_behavior = "IPV6_COMPLIANCE"
}

resource "akamai_cp_code" "myCPCode" {
    # Using a akamai_cp_code resource will result in a TF-managed CP Code
    contract_id = data.akamai_contract.default.id
    group_id    = data.akamai_group.default.id
    name = (var.property_name)
    product_id = var.product_id
}

resource "akamai_property" "myProperty" {

    # Replace with the intended property name
    name    = var.property_name

    # The product class - 'prd_SPM' = Ion Premier
    product_id  = var.product_id
    contract_id = data.akamai_contract.default.id
    group_id    = data.akamai_group.default.id

    /*

        The desired rule tree format
        https://developer.akamai.com/api/core_features/property_manager/v1.html#understandingruleformats

    */

    rule_format = "latest"
    
    # The rendered template_file, as defined in data.tf
    rules       = data.template_file.init.rendered

    /*

        Map hostname to edge hostname, defined above.

    */
    hostnames = {
       (var.property_name) = akamai_edge_hostname.myEdgeHostname.edge_hostname
    }
}

/* 
    The second 'resource' parameter is the property name

*/
resource "akamai_property_activation" "example_staging" {
     property_id = akamai_property.myProperty.id
     contact  = ["jalane@akamai.com"] 
     # NOTE: Specifying a version as shown here will target the latest version created. This latest version will always be activated in staging.
     version  = akamai_property.myProperty.latest_version
     # not specifying network will target STAGING
}

resource "akamai_property_activation" "example_prod" {
     property_id = akamai_property.myProperty.id
     network  = "PRODUCTION"
     # manually specifying version allows production to lag behind staging until qualified by testing on staging URLs.
     version = 3 
     # manually declaring a dependency on staging means production activation will not update if staging update fails -  
     # useful when both target same version.  The example does not depict this approach. However, this practice is 
     # recommended even when you edit production version by hand as shown in this example.
     depends_on = [
        akamai_property_activation.example_staging
     ]
     contact  = ["jalane@akamai.com"]
}
