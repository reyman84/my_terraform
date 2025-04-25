pipeline {
    agent { label 'PLUTO' }

    environment {
        AWS_REGION = 'us-east-1'
        AWS_ACCESS_KEY_ID = credentials('aws-access-key')       // Jenkins credential ID
        AWS_SECRET_ACCESS_KEY = credentials('aws-secret-key')   // Jenkins credential ID
    }

    stages {
        stage("Install Terraform (if needed)") {
            steps {
                sh '''
                    if ! command -v terraform &> /dev/null
                    then
                        echo "Installing Terraform..."
                        sudo yum install -y yum-utils
                        sudo yum-config-manager --add-repo https://rpm.releases.hashicorp.com/AmazonLinux/hashicorp.repo
                        sudo yum install -y terraform
                        echo "Terraform installed"
                    else
                        echo "Terraform already installed"
                        terraform version
                    fi
                '''
            }
        }

        stage("Clone") {
            steps {
                git branch: "new", url: "https://github.com/reyman84/my_terraform.git"
            }
        }
		
		stage("Key files") {
            steps {
                sh 'cp -pr /home/ec2-user/key-files/ /opt/jenkins/workspace/$JOB_NAME/key-files'
            }
        }
		

        stage("Terraform Init") {
            steps {
                sh 'terraform init'
            }
        }

        stage("Terraform Format") {
            steps {
                sh 'terraform fmt'
            }
        }

        stage("Terraform Validate") {
            steps {
                sh 'terraform validate'
            }
        }

        stage("Terraform Plan") {
            steps {
                sh 'terraform plan'
            }
        }

        stage("Terraform Apply") {
            steps {
                sh 'terraform apply --auto-approve'
            }
        }
    }
}