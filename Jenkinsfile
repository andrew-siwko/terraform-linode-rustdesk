pipeline {
    agent { label 'terraform' }

    options {
        ansiColor('xterm')
        disableConcurrentBuilds()
    }

    triggers {
        pollSCM('* * * * *')
    }

    environment {
        LANG   = 'en_US.UTF-8'
        LC_ALL = 'en_US.UTF-8'
        // Reuses the existing Linode API key credential already stored in Jenkins
        // (same one bound in the terraform-linode-create freestyle job).
        TF_VAR_LINODE_API_KEY = credentials('b4221ab43ff3c5ce2ac2baf652a26c5c93acc65deb7ee6e9f9a0727bab09eb9f')
    }

    stages {
        stage('Terraform Version') {
            steps {
                sh 'terraform version'
            }
        }

        stage('Terraform Init') {
            steps {
                sh 'terraform init'
            }
        }

        stage('Import DNS Zone') {
            steps {
                sh '''
                    if ! terraform state list | grep -q "linode_domain.dns_zone"; then
                        echo "Resource not in state. Importing..."
                        terraform import linode_domain.dns_zone 3417841
                    else
                        echo "Domain already managed. Skipping import."
                    fi
                '''
            }
        }

        stage('Terraform Plan') {
            steps {
                sh 'terraform plan'
            }
        }

        stage('Terraform Apply') {
            steps {
                sh 'terraform apply -auto-approve'
            }
        }

        stage('Publish Output') {
            steps {
                sh 'terraform output | mail -s terraform_output_rustdesk asiwko@siwko.org'
            }
        }
    }

    post {
        failure {
            mail to: 'asiwko@siwko.org',
                 subject: "terraform-linode-rustdesk build #${env.BUILD_NUMBER} FAILED",
                 body: "See ${env.BUILD_URL}console for details."
        }
    }
}
