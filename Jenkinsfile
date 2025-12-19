pipeline {

    agent {
        kubernetes {
            yaml '''
apiVersion: v1
kind: Pod
spec:
  containers:
  - name: dind
    image: docker:dind
    securityContext:
      privileged: true
    env:
    - name: DOCKER_TLS_CERTDIR
      value: ""

  - name: sonar-scanner
    image: sonarsource/sonar-scanner-cli
    command: ["cat"]
    tty: true

  - name: kubectl
    image: bitnami/kubectl:latest
    command: ["cat"]
    tty: true
'''
        }
    }

    options { skipDefaultCheckout() }

    environment {
        REGISTRY_HOST = "nexus-service-for-docker-hosted-registry.nexus.svc.cluster.local:8085"
        REGISTRY      = "${REGISTRY_HOST}/2401152"
        IMAGE_NAME    = "kissankonnect"
        NAMESPACE     = "2401152"
        SONAR_TOKEN   = "sqp_6143e807cdac9c6f54cc04464e03c8a096cd45ef"
    }

    stages {

        stage('Checkout Code') {
            steps {
                deleteDir()
                sh 'git clone https://github.com/ruchika00/KissanKonnect_updated.git .'
            }
        }

        stage('Build Docker Image') {
            steps {
                container('dind') {
                    sh '''
                      docker build -t ${IMAGE_NAME}:${BUILD_NUMBER} .
                      docker tag ${IMAGE_NAME}:${BUILD_NUMBER} ${REGISTRY}/${IMAGE_NAME}:latest
                    '''
                }
            }
        }

        stage('SonarQube Analysis') {
            steps {
                container('sonar-scanner') {
                    sh '''
                      sonar-scanner \
                      -Dsonar.projectKey=2401152_KissanKonnect \
                      -Dsonar.projectName=2401152_KissanKonnect \
                      -Dsonar.host.url=http://my-sonarqube-sonarqube.sonarqube.svc.cluster.local:9000 \
                      -Dsonar.token=${SONAR_TOKEN} \
                      -Dsonar.sources=. \
                      -Dsonar.language=php
                    '''
                }
            }
        }

        stage('Login to Nexus') {
            steps {
                container('dind') {
                    sh '''
                      docker login ${REGISTRY_HOST} \
                      -u admin -p Changeme@2025
                    '''
                }
            }
        }

        stage('Push Image') {
            steps {
                container('dind') {
                    sh '''
                      docker push ${REGISTRY}/${IMAGE_NAME}:latest
                    '''
                }
            }
        }

        stage('Deploy to Kubernetes') {
            steps {
                container('kubectl') {
                    sh '''
                      kubectl get namespace 2401152 || kubectl create namespace 2401152
                      kubectl apply -f deployment.yaml -n 2401152
                    '''
                }
            }
        }
    }

    post {
        success { echo "🎉 Deployment Successful" }
        failure { echo "❌ Deployment Failed" }
    }
}
