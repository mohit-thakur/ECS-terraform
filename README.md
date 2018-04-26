# ECS-terraform
Step1:- 
Firstly, I have created a AWS EC2 instance and created a flask application with docker-compose and deploy a container.

Step2:-
Then I wrote a terraform script to deploy flask application on ECS. For that I have created different files like, task defination. frontend.json file created under task defination.

[
  {
    "name": "frontend",
    "image": "mohitthakur/flasknode1",
    "memory": 512,
    "essential": true,
    "logConfiguration": {
                "logDriver": "syslog"
            },
    "portMappings": [
      {
        "containerPort": 5000
      }
    ]
  }
]

Flask application deploye on port 5000 in ECS.


Step3:- 
For declaration of variables I have created one file 
vars.tf

Step4:-
I have created iam.tf file for policy creation.

Step5:-
alb.tf file created for load balancer.

Step6:- 
main.tf stores the access key and secret key and other information related security group, and autoscaling information.

Step7:-
service.tf file stores the information about frontend.

Step:8
After configuration of file I deployed these files on ECS using terraform command.
#terraform init
#terraform plan
#terraform apply

Step9:- Now terraform creates the task defination, and EC2 instance, autoscaling groups etc.

Step10:- The application deployed on port 5000.
