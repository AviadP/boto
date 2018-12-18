#!/usr/bin/python3
""" This script get vpc id, internet gateway and region
    Create public & private subnets, route tables pe subnet, natgateway
    and set the default gateway according to the subnet / routing purpose
"""
import argparse
import boto3


def allocate_address():
    """ Allocate elastic IP address and return the response """
    response = EC2.allocate_address(
    )
    return response


def create_nat_gateway(subnet_id, eip):
    """ Get subnet id, elastic ip and creates a
        Nat gateway in the subnet id, using the
        elastic ip given
    """
    response = EC2.create_nat_gateway(
        AllocationId=eip,
        SubnetId=subnet_id
    )
    return response


def wait_for_nat_gateway(nat_gateway_id):
    """ Use waiter method to wait till the nat gateway is ready """
    waiter = EC2.get_waiter('nat_gateway_available')
    print("Starting wait loop till Nat Gateway is available")
    waiter.wait(
        NatGatewayIds=[
            nat_gateway_id,
            ],
        WaiterConfig={
            'Delay': 20,
            'MaxAttempts': 15
        }
    )


def create_subnet(availability_zone, cidr, vpc_id):
    """  Get availability zone, cidr and vpc id
         create a subnet and return its description
    """
    response = EC2.create_subnet(
        AvailabilityZone=availability_zone,
        CidrBlock=cidr,
        VpcId=vpc_id,
    )
    return response


def create_route_table(vpc_id):
    """ Get a vpc id and create a route table, return it's description"""
    response = EC2.create_route_table(
        VpcId=vpc_id
    )
    return response


def add_nat_gateway_route(route_table_id, destination, nat_gateway_id):
    """ Gets route table id, destination(default gateway in our case)
        and nat gateway id and create a default gateway route in the
        given route table, return the response
    """
    response = EC2.create_route(
        DestinationCidrBlock=destination,
        RouteTableId=route_table_id,
        NatGatewayId=nat_gateway_id
    )
    return response


def add_internet_gateway_route(route_table_id, destination, internet_gateway_id):
    """ Gets route table id, destination and internet gateway id
        and add a default gateway to the internet gateway in the route table
        return the response
    """
    response = EC2.create_route(
        DestinationCidrBlock=destination,
        RouteTableId=route_table_id,
        GatewayId=internet_gateway_id
    )
    return response


def create_tags(resource_id, key, value):
    """ Get id and create tags for the resource """
    response = EC2.create_tags(
        Resources=[
            resource_id,
        ],
        Tags=[
            {
                'Key': key,
                'Value': value
            },
        ]
    )
    return response


def associate_route_table(route_table_id, subnet_id):
    """ Gets route table id and subnet id and associate the route table
        to the subnet
    """
    response = EC2.associate_route_table(
        RouteTableId=route_table_id,
        SubnetId=subnet_id
    )
    return response


def args_parser():
    """ validate arguments and return them """
    parser = argparse.ArgumentParser(add_help=True, description="VPC Arguments")
    parser.add_argument("--vpc", "-p", help="Get vpc id",
                        required=True)
    parser.add_argument("--region", "-r", help="Get target region",
                        required=True)
    parser.add_argument("--igw", "-i", help="Get Internet gateway",
                        required=True)
    return parser.parse_args()


if __name__ == '__main__':
    ARGS = args_parser()
    EC2 = boto3.client('ec2', ARGS.region)
    SUBNET_ID = {}
    SUBNETS = {
        "Private_1c":"10.21.0.0/23",
        "Public_1c":"10.21.2.0/23"
    }
    for k in SUBNETS:
        ROUTE_TABLE_ID = create_route_table(ARGS.vpc)['RouteTable']['RouteTableId']
        create_tags(ROUTE_TABLE_ID, "Name", k)
        SUBNET_ID[k] = create_subnet("us-east-1c", SUBNETS[k], ARGS.vpc)['Subnet']['SubnetId']
        associate_route_table(ROUTE_TABLE_ID, SUBNET_ID)
        create_tags(SUBNET_ID, "Name", k)
        if "Public" in k:
            add_internet_gateway_route(ROUTE_TABLE_ID, "0.0.0.0/0", ARGS.igw)
        else:
            ELASTIC_IP = allocate_address()['AllocationId']
            NAT_GATEWAY_ID = create_nat_gateway(SUBNET_ID['Public_1c'], ELASTIC_IP)['NatGateway']['NatGatewayId']
            wait_for_nat_gateway(NAT_GATEWAY_ID)
            add_nat_gateway_route(ROUTE_TABLE_ID, "0.0.0.0/0", NAT_GATEWAY_ID)
            create_tags(NAT_GATEWAY_ID, "name", "Nat_gateway_1")
