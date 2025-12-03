pipeline {
    agent {
        kubernetes {
            label "2401152_4-80psb"
            defaultContainer 'jnlp'
        }
    }

    environment {
        DOCKER_HOST = "tcp://localhost:2375"
        DOCKER_CLI_EXPERIMENTAL = "enabled"
        IMAGE_NAME = "nexus-service-for-docker-hosted-registry.nexus.svc.cluster.local:8085/kissan-konnect"
    }

    stages {

        stage('Checkout Code') {
            steps {
                deleteDir()
                sh 'git clone https://github.com/ruchika00/KissanKonnect_updated.git .'
                echo "✔ Source code cloned successfully"
            }
        }

        stage('Build Docker Image') {
            steps {
                container('dind') {
                    sh '''
                        echo "Checking Docker..."
                        docker info
                        echo "Building image..."
                        docker build -t ${IMAGE_NAME}:${BUILD_NUMBER} -t ${IMAGE_NAME}:latest .
                    '''
                }
            }
        }

        stage('Login to Nexus') {
            steps {
                container('dind') {
                    sh '''
                        echo "Logging into Nexus..."
                        docker login nexus-service-for-docker-hosted-registry.nexus.svc.cluster.local:8085 \
                        -u admin -p admin123
                    '''
                }
            }
        }

        stage('Push Image') {
            steps {
                container('dind') {
                    sh '''
                        echo "Pushing image..."
                        docker push ${IMAGE_NAME}:${BUILD_NUMBER}
                        docker push ${IMAGE_NAME}:latest
                    '''
                }
            }
        }

        stage('Deploy to Kubernetes') {
            steps {
                container('kubectl') {
                    sh '''
                        echo "Deploying to K8s..."
                        kubectl apply -f k8s_deployment/deployment.yaml
                    '''
                }
            }
        }
    }

    post {
        always {
            echo "🔄 Pipeline finished"
        }
        failure {
            echo "❌ Pipeline failed"
        }
    }
}

