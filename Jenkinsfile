pipeline {
  agent {
    kubernetes {
      label '2401152-safe-agent'
      defaultContainer 'jnlp'
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

    stage('Build Info (Dry Run)') {
      steps {
        sh '''
          echo "⚠ Docker build skipped"
          echo "This cluster does not allow image building"
          echo "Image build handled by admin or external CI"
        '''
      }
    }

    stage('Deploy to Kubernetes') {
      steps {
        sh '''
          echo "📦 Deploying existing image to Kubernetes"
          kubectl apply -f k8s_deployment/deployment.yaml
        '''
      }
    }
  }

  post {
    success {
      echo "✅ Pipeline completed successfully"
    }
    failure {
      echo "❌ Pipeline failed"
    }
  }
}

