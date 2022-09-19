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
        - name: ct
          image: quay.io/helmpack/chart-testing:v3.7.0
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

        stage('Lint Helm Chart') {
            steps {
                container('ct') {
                    sh 'ct lint'
                }
            }
        }
    }
}
