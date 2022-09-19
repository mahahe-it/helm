pipeline {
    agent {
        kubernetes {
            cloud 'development'
            yaml '''
      spec:
        containers:
        - name: jnlp
          image: jenkins/inbound-agent:latest-jdk11
          command: ['sleep', '999999']
        - name: helm
          image: alpine/helm:3.9.4
          command: ['sleep', '999999']
          tty: true
        - name: ct
          image: quay.io/helmpack/chart-testing:v3.7.0
          command: ['sleep', '999999']
          tty: true

      '''
        }
    }

    stages {
        stage('Lint Helm Chart') {
            steps {
                container('ct') {
                    sh 'ct lint'
                }
            }
        }
    }
}
