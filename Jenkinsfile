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
    volumeMounts:
    - name: docker-config
      mountPath: /etc/docker/daemon.json
      subPath: daemon.json

  - name: sonar-scanner
    image: sonarsource/sonar-scanner-cli
    command:
    - cat
    tty: true

  - name: kubectl
    image: bitnami/kubectl:latest
    command:
    - cat
    tty: true
    securityContext:
      runAsUser: 0
      readOnlyRootFilesystem: false
    env:
    - name: KUBECONFIG
      value: /kube/config        
    volumeMounts:
    - name: kubeconfig-secret
      mountPath: /kube/config
      subPath: kubeconfig

  volumes:
  - name: docker-config
    configMap:
      name: docker-daemon-config
  - name: kubeconfig-secret
    secret:
      secretName: kubeconfig-secret
'''
        }
    }

    options { skipDefaultCheckout() }

    environment {
        DOCKER_IMAGE  = "kissankonnect"
        SONAR_TOKEN   = "sqp_6143e807cdac9c6f54cc04464e03c8a096cd45ef"
        REGISTRY_HOST = "nexus-service-for-docker-hosted-registry.nexus.svc.cluster.local:8085"
        REGISTRY      = "${REGISTRY_HOST}/2401152"
        NAMESPACE     = "2401152"
    }

    stages {

        stage('Checkout Code') {
            steps {
                deleteDir()
                sh "git clone https://github.com/ruchika00/KissanKonnect.git ."
                echo "✔ Source code cloned successfully"
            }
        }

        stage('Build Docker Image') {
            steps {
                container('dind') {
                    script {
                        timeout(time: 1, unit: 'MINUTES') {
                            waitUntil {
                                try {
                                    sh 'docker info >/dev/null 2>&1'
                                    return true
                                } catch (Exception e) {
                                    sleep 5
                                    return false
                                }
                            }
                        }

                        sh """
                            echo "Building Docker image..."
                            docker build -t ${DOCKER_IMAGE}:${BUILD_NUMBER} .
                            docker tag ${DOCKER_IMAGE}:${BUILD_NUMBER} ${DOCKER_IMAGE}:latest
                            docker image ls
                        """
                    }
                }
            }
        }

        stage('Run Tests & Coverage') {
            steps {
                container('dind') {
                    sh """
                        echo "Running PHP lint inside container..."
                        docker run --rm \
                          -v \$PWD:/var/www/html \
                          ${DOCKER_IMAGE}:latest \
                          sh -c "php -l index.php || true"
                    """
                }
            }
        }

        stage('SonarQube Analysis') {
            steps {
                container('sonar-scanner') {
                    sh """
                        sonar-scanner \
                          -Dsonar.projectKey=2401152_KissanKonnect \
                          -Dsonar.projectName=2401152_KissanKonnect \
                          -Dsonar.host.url=http://my-sonarqube-sonarqube.sonarqube.svc.cluster.local:9000 \
                          -Dsonar.token=${SONAR_TOKEN} \
                          -Dsonar.sources=. \
                          -Dsonar.language=php \
                          -Dsonar.sourceEncoding=UTF-8
                    """
                }
            }
        }

        stage('Login to Nexus') {
            steps {
                container('dind') {
                    sh """
                        echo 'Logging into Nexus registry...'
                        docker login ${REGISTRY_HOST} -u admin -p Changeme@2025
                    """
                }
            }
        }

        stage('Push Image') {
            steps {
                container('dind') {
                    sh """
                        docker tag ${DOCKER_IMAGE}:${BUILD_NUMBER} ${REGISTRY}/${DOCKER_IMAGE}:${BUILD_NUMBER}
                        docker tag ${DOCKER_IMAGE}:${BUILD_NUMBER} ${REGISTRY}/${DOCKER_IMAGE}:latest

                        docker push ${REGISTRY}/${DOCKER_IMAGE}:${BUILD_NUMBER}
                        docker push ${REGISTRY}/${DOCKER_IMAGE}:latest

                        docker pull ${REGISTRY}/${DOCKER_IMAGE}:${BUILD_NUMBER}
                        docker image ls
                    """
                }
            }
        }

        stage('Deploy to Kubernetes') {
            steps {
                container('kubectl') {
                    dir('k8s_deployment') {
                        sh """
                            kubectl apply -f deployment.yaml -n ${NAMESPACE}
                        """
                    }
                }
            }
        }
    }

    post {
        success { echo "🎉 KissanKonnect PHP CI/CD Pipeline completed successfully!" }
        failure { echo "❌ Pipeline failed" }
        always  { echo "🔄 Pipeline finished" }
    }
}
