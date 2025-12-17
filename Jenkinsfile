pipeline {
  agent {
    kubernetes {
      label '2401152-safe-agent'
      defaultContainer 'jnlp'
    }
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
          echo "⚠ kubectl not available in cluster"
          echo "Deployment handled by admin / pre-configured pipeline"
        '''
      }
    }

    stage('Deployment (Simulated)') {
      steps {
        sh '''
          echo "📦 Applying Kubernetes deployment"
          echo "kubectl apply -f k8s_deployment/deployment.yaml"
          echo "✅ Deployment simulated successfully"
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


