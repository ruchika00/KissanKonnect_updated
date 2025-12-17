pipeline {
  agent {
    kubernetes {
      label '2401152-kaniko-agent'
      defaultContainer 'jnlp'
      yaml '''
apiVersion: v1
kind: Pod
spec:
  containers:
  - name: kaniko
    image: gcr.io/kaniko-project/executor:latest
    command:
    - /busybox/cat
    tty: true
    volumeMounts:
    - name: docker-config
      mountPath: /kaniko/.docker

  - name: kubectl
    image: bitnami/kubectl:latest
    command:
    - cat
    tty: true

  volumes:
  - name: docker-config
    secret:
      secretName: nexus-docker-secret
'''
    }
  }

  environment {
    IMAGE_NAME = "nexus-service-for-docker-hosted-registry.nexus.svc.cluster.local:8085/kissan-konnect"
  }

  stages {

    stage('Checkout Code') {
      steps {
        deleteDir()
        git url: 'https://github.com/ruchika00/KissanKonnect_updated.git', branch: 'main'
        echo "✔ Source code cloned successfully"
      }
    }

    stage('Build & Push Image (Kaniko)') {
      steps {
        container('kaniko') {
          sh '''
            echo "🚀 Building & Pushing image to Nexus..."

            /kaniko/executor \
              --context $(pwd) \
              --dockerfile Dockerfile \
              --destination ${IMAGE_NAME}:${BUILD_NUMBER} \
              --destination ${IMAGE_NAME}:latest \
              --insecure \
              --skip-tls-verify
          '''
        }
      }
    }

    stage('Deploy to Kubernetes') {
      steps {
        container('kubectl') {
          sh '''
            echo "📦 Deploying application to Kubernetes..."
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
    success {
      echo "✅ Build & Deployment Successful"
    }
    failure {
      echo "❌ Pipeline failed"
    }
  }
}
