pipeline {
    agent {
        kubernetes {
            cloud 'development'
            inheritFrom 'default-dev'
            yaml '''
      spec:
        containers:
        - name: helm
          image: alpine/helm:3.9.4
          command: ['sleep', '999999']
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
