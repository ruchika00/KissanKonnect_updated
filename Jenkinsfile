properties([
  pipelineTriggers([]),
  durabilityHint('PERFORMANCE_OPTIMIZED')
])

pipeline {

    agent {
        kubernetes {
            yaml """
apiVersion: v1
kind: Pod
spec:
  containers:
- name: dind
  image: docker:dind
  securityContext:
    privileged: true
  command: ["dockerd-entrypoint.sh"]
  args:
    - "--host=tcp://0.0.0.0:2375"
    - "--insecure-registry=nexus-service-for-docker-hosted-registry.nexus.svc.cluster.local:8085"
  env:
    - name: DOCKER_TLS_CERTDIR
      value: ""
    - name: DOCKER_HOST
      value: tcp://localhost:2375
  volumeMounts:
    - name: docker-storage
      mountPath: /var/lib/docker
    - name: workspace-volume
      mountPath: /home/jenkins/agent


  - name: sonar-scanner
    image: sonarsource/sonar-scanner-cli
    command: ["cat"]
    tty: true

  - name: kubectl
    image: bitnami/kubectl:latest
    command: ["cat"]
    tty: true
    securityContext:
      runAsUser: 0
      readOnlyRootFilesystem: false

  volumes:
    - name: docker-storage
      emptyDir: {}
    - name: workspace-volume
      emptyDir: {}
"""
        }
    }

    options { skipDefaultCheckout() }

    environment {
        DOCKER_HOST = "tcp://localhost:2375"
        DOCKER_IMAGE  = "kissan-konnect"
        REGISTRY_HOST = "nexus-service-for-docker-hosted-registry.nexus.svc.cluster.local:8085"
        REGISTRY      = "${REGISTRY_HOST}/2401152"
        NAMESPACE     = "2401152"

        SONAR_TOKEN = "sqp_6143e807cdac9c6f54cc04464e03c8a096cd45ef"
    }

    stages {

        stage('Checkout Code') {
            steps {
                deleteDir()
                sh "git clone https://github.com/ruchika00/KissanKonnect_updated.git ."
                echo "✔ Source code cloned successfully"
            }
        }

        stage('Build Docker Image') {
            steps {
                container('dind') {
                    sh """
                        docker build -t ${DOCKER_IMAGE}:${BUILD_NUMBER} -t ${DOCKER_IMAGE}:latest .
                        docker image ls
                    """
                }
            }
        }

        stage('Run Tests') {
            steps {
                container('dind') {
                    sh """
                        echo "No automated tests configured for PHP project"
                        echo "Skipping test stage"
                    """
                }
            }
        }

        stage('SonarQube Analysis') {
            steps {
                container('sonar-scanner') {
                    sh """
                        sonar-scanner \
                        -Dsonar.projectKey=2401152_kissankonnect \
                        -Dsonar.projectName=2401152_kissankonnect \
                        -Dsonar.host.url=http://my-sonarqube-sonarqube.sonarqube.svc.cluster.local:9000 \
                        -Dsonar.token=${SONAR_TOKEN}
                    """
                }
            }
        }

        stage('Login to Nexus') {
            steps {
                container('dind') {
                    sh """
                        echo 'Logging into Nexus registry...'
                        docker login ${REGISTRY_HOST} -u admin -p admin123
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
        success { echo "🎉 KissanKonnect CI/CD Pipeline completed successfully!" }
        failure { echo "❌ Pipeline failed" }
        always  { echo "🔄 Pipeline finished" }
    }
}



