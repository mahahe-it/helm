pipeline {
  agent {
    kubernetes {
      inheritFrom 'default-dev'
      yaml '''
      spec:
        containers:
        - name: helm
          image: alpine/helm:3.9.4
      '''
    }
  }
  stages {
    stage('Echo') {
      steps {
        echo 'Test'
      }
    }
  }
}
