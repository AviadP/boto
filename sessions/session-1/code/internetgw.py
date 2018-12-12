#!/usr/bin/python3
""" Create internet gateway, dhcp options,
    and attach both the selected vpc
"""
import argparse
import boto3


def describe_vpcs():
    """ Return description of all vpcs in region """
    response = EC2.describe_vpcs()
    return response


def create_internet_gateway():
    """ Return description of created internet gateway """
    response = EC2.create_internet_gateway()
    return response


def create_dhcp_options():
    """ Return description of created dhcp options """
    response = EC2.create_dhcp_options(
        DhcpConfigurations=[
            {
                'Key': 'domain-name-servers',
                'Values': [
                    '10.21.0.10',
                    '10.21.2.10',
                ],
            },
        ],
    )
    return response


def attach_internet_gateway(vpc_id, igw_id):
    """ Attach a given igw to a given vpc """
    response = EC2.attach_internet_gateway(
        InternetGatewayId=igw_id,
        VpcId=vpc_id
    )
    return response


def associate_dhcp_options(vpc_id, dhcp_options_id):
    """ Associate a given dhcp_options to a given vpc """
    response = EC2.associate_dhcp_options(
        DhcpOptionsId=dhcp_options_id,
        VpcId=vpc_id,
    )
    return response


def select_vpc(vpc_ids):
    """ Retrun a selected vpc id chosen by user """
    print("Select vpc to act on:")
    for vpc_id in vpc_ids:
        print(vpc_id)
    id_selected = input("Enter id: ")
    return id_selected


def args_parser():
    """ validate arguments and return them """
    parser = argparse.ArgumentParser(add_help=True, description="VPC Arguments")
    parser.add_argument("--region", "-r", help="Get target region",
                        required=True)
    return parser.parse_args()


if __name__ == '__main__':
    ARGS = args_parser()
    VPC_IDS = []
    EC2 = boto3.client('ec2', ARGS.region)
    RESPONSE_VPCS = describe_vpcs()
    for r in RESPONSE_VPCS['Vpcs']:
        VPC_IDS.append(r['VpcId'])
    VPC_ID = select_vpc(VPC_IDS)
    RESPONSE_IGW = create_internet_gateway()
    IGW_ID = RESPONSE_IGW['InternetGateway']['InternetGatewayId']
    RESPONSE_ATTACHE_IGW = attach_internet_gateway(VPC_ID, IGW_ID)
    RESPONSE_CREATE_DHCP_OPTIONS = create_dhcp_options()
    DHCP_OPTIONS_ID = RESPONSE_CREATE_DHCP_OPTIONS['DhcpOptions']['DhcpOptionsId']
    RESPONSE_ASSPCIATE_DHCP = associate_dhcp_options(VPC_ID, DHCP_OPTIONS_ID)
