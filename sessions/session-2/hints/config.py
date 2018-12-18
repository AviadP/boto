INSTANCE_SG_NAME = "Ops-school-internal-access"
INSTANCE_SG_DESCRIPTION = "security group for internal access"
INSTANCE_SG_RULES = \
    [{
        'FromPort': 8080,
        'IpRanges': [{
        'CidrIp': '10.0.0.0/8',
        'Description': 'open for ELB to backend instance'
    }],
        'ToPort': 8080,
        'IpProtocol': "tcp"}
    ]
ELB_SG_NAME = "Ops-school-external-access"
ELB_SG_DESCRIPTION = "security group for external access"
ELB_SG_RULES = \
    [{
        'FromPort': 80,
        'IpRanges': [{
        'CidrIp': '0.0.0.0/0',
        'Description': 'open from the world to the ELB'
    }],
        'ToPort': 8080,
        'IpProtocol': "tcp"}
    ]
REGION = "us-east-1"
VPC_ID = "your-vpc-id"
AMI_ID = "ami-0f9cf087c1f27d9b1"
INSTANCE_SUBNET_ID = "private-subnet-id"
INSTANCE_NAME = "opsschool-1"
ELB_SUBNET_ID = ["public-subnet-id"]
INSTANCE_NAME = "opsschool-1"
ELB_NAME = "opsschool-elb"
ELB_LISTENERS = \
    [{
    'InstancePort': 8080,
    'InstanceProtocol': 'HTTP',
    'LoadBalancerPort': 80,
    'Protocol': 'HTTP',
    }]
ELB_HEALTH = "HTTP:8080/healthcheck"
ELB_SCHEME = "internet-facing"
ELB_INTERVAL = 10
ELB_TIMEOUT = 5
ELB_UNHEALTH_THRESHOLD = 2
ELB_HEALTH_THRESHOLD = 2
USERDATA = '''#!/bin/bash -x
              exec > /tmp/part-001.log 2>&1    
              sudo apt-get update -y
              sudo apt-get install docker.io -y
              sudo docker run -d -p 8080:8080 relmos/flask1'''