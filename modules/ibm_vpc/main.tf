resource "ibm_is_vpc" "vpc" {
  name                      = "${var.ibm_vpc_name}-${var.ibm_region}-${var.ibm_vpc_index}"
  resource_group            = data.ibm_resource_group.group.id
  address_prefix_management = "manual"
}

resource "ibm_is_vpc_address_prefix" "zone_1_vpc_address_prefix" {
  name = "${var.ibm_vpc_name}-${var.ibm_region}-1-${var.ibm_vpc_index}-ap"
  zone = "${var.ibm_region}-1"
  vpc  = ibm_is_vpc.vpc.id
  cidr = var.ibm_vpc_zone_1_prefix
}

resource "ibm_is_vpc_address_prefix" "zone_2_vpc_address_prefix" {
  name = "${var.ibm_vpc_name}-${var.ibm_region}-2-${var.ibm_vpc_index}-ap"
  zone = "${var.ibm_region}-2"
  vpc  = ibm_is_vpc.vpc.id
  cidr = var.ibm_vpc_zone_2_prefix
}

resource "ibm_is_vpc_address_prefix" "zone_3_vpc_address_prefix" {
  name = "${var.ibm_vpc_name}-${var.ibm_region}-3-${var.ibm_vpc_index}-ap"
  zone = "${var.ibm_region}-3"
  vpc  = ibm_is_vpc.vpc.id
  cidr = var.ibm_vpc_zone_3_prefix
}

// allow all inbound
resource "ibm_is_security_group_rule" "allow_inbound" {
  depends_on = [ibm_is_vpc.vpc]
  group      = ibm_is_vpc.vpc.default_security_group
  direction  = "inbound"
  remote     = "0.0.0.0/0"
}

// all all outbound
resource "ibm_is_security_group_rule" "allow_outbound" {
  depends_on = [ibm_is_vpc.vpc]
  group      = ibm_is_vpc.vpc.default_security_group
  direction  = "outbound"
  remote     = "0.0.0.0/0"
}

resource "ibm_is_public_gateway" "zone_1_gw" {
  name = "${var.ibm_vpc_name}-${var.ibm_region}-pg-1"
  vpc  = ibm_is_vpc.vpc.id
  zone = "${var.ibm_region}-1"
  timeouts {
    create = "90m"
  }
}

resource "ibm_is_subnet" "zone_1" {
  name            = "${var.ibm_vpc_name}-${var.ibm_region}-sn-1"
  vpc             = ibm_is_vpc.vpc.id
  zone            = "${var.ibm_region}-1"
  resource_group  = data.ibm_resource_group.group.id
  depends_on      = [ibm_is_vpc_address_prefix.zone_1_vpc_address_prefix]
  ipv4_cidr_block = cidrsubnet(var.ibm_vpc_zone_1_prefix, (24 - (split("/", var.ibm_vpc_zone_1_prefix)[1])), 0)
  public_gateway  = ibm_is_public_gateway.zone_1_gw.id
}

resource "ibm_is_public_gateway" "zone_2_gw" {
  name = "${var.ibm_vpc_name}-${var.ibm_region}-pg-2"
  vpc  = ibm_is_vpc.vpc.id
  zone = "${var.ibm_region}-2"
  timeouts {
    create = "90m"
  }
}

resource "ibm_is_subnet" "zone_2" {
  name            = "${var.ibm_vpc_name}-${var.ibm_region}-sn-2"
  vpc             = ibm_is_vpc.vpc.id
  zone            = "${var.ibm_region}-2"
  resource_group  = data.ibm_resource_group.group.id
  depends_on      = [ibm_is_vpc_address_prefix.zone_2_vpc_address_prefix]
  ipv4_cidr_block = cidrsubnet(var.ibm_vpc_zone_2_prefix, (24 - (split("/", var.ibm_vpc_zone_2_prefix)[1])), 0)
  public_gateway  = ibm_is_public_gateway.zone_2_gw.id
}

resource "ibm_is_public_gateway" "zone_3_gw" {
  name = "${var.ibm_vpc_name}-${var.ibm_region}-pg-3"
  vpc  = ibm_is_vpc.vpc.id
  zone = "${var.ibm_region}-3"
  timeouts {
    create = "90m"
  }
}

resource "ibm_is_subnet" "zone_3" {
  name            = "${var.ibm_vpc_name}-${var.ibm_region}-sn-3"
  vpc             = ibm_is_vpc.vpc.id
  zone            = "${var.ibm_region}-3"
  resource_group  = data.ibm_resource_group.group.id
  depends_on      = [ibm_is_vpc_address_prefix.zone_3_vpc_address_prefix]
  ipv4_cidr_block = cidrsubnet(var.ibm_vpc_zone_3_prefix, (24 - (split("/", var.ibm_vpc_zone_3_prefix)[1])), 0)
  public_gateway  = ibm_is_public_gateway.zone_3_gw.id
}

data "ibm_is_ssh_key" "ssh_key" {
  name = var.ibm_ssh_key_name
}
