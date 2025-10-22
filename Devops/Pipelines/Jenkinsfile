pipeline {
    agent any

    environment {
        REPO_URL = 'https://github.com/reyman84/terraform-vprofile-project.git'
        SONAR_SERVER = 'SonarQubeServer'
        ARTIFACT_REPO = 'Nexus'
    }

    stages {
        stage('Checkout') {
            steps {
                git branch: 'main', url: "${REPO_URL}"
            }
        }

        stage('Build') {
            steps {
                sh 'mvn clean package -DskipTests'
            }
        }

        stage('Unit Tests') {
            steps {
                sh 'mvn test'
            }
        }

        stage('Code Quality - SonarQube') {
            steps {
                withSonarQubeEnv("${SONAR_SERVER}") {
                    sh 'mvn sonar:sonar'
                }
            }
        }

        stage('Publish Artifact') {
            steps {
                sh 'mvn deploy'
            }
        }

        stage('Deploy to Staging') {
            steps {
                echo 'Deploying to staging environment...'
                sh 'ansible-playbook -i inventory/staging deploy.yml'
            }
        }

        stage('Integration / Acceptance Testing') {
            steps {
                echo 'Running post-deployment tests on staging...'
                sh 'pytest tests/integration/'
            }
        }

        stage('Manual Approval') {
            steps {
                script {
                    timeout(time: 1, unit: 'HOURS') {
                        input message: "Approve deployment to PRODUCTION?"
                    }
                }
            }
        }

        stage('Deploy to Production') {
            steps {
                echo 'Deploying to production environment...'
                sh 'ansible-playbook -i inventory/production deploy.yml'
            }
        }
    }

    post {
        success {
            echo '✅ Continuous Delivery pipeline executed successfully!'
        }
        failure {
            echo '❌ Pipeline failed. Please check logs.'
        }
    }
}