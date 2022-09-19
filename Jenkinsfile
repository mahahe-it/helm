pipeline {
    agent {
        kubernetes {
            cloud 'development'
            yaml '''
      spec:
        containers:
        - name: jnlp
          image: jenkins/inbound-agent:latest-jdk11
          command: ['/usr/local/bin/jenkins-agent']
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
            when {
                changeRequest()
            }

            steps {
                container('ct') {
                    sh "git fetch --no-tags origin ${env.CHANGE_TARGET}:refs/remotes/origin/${env.CHANGE_TARGET}"
                    sh 'git config --global --add safe.directory \'*\''
                    sh 'ct lint --config ct.yaml --charts youtrack'
                }
            }
        }
    }
}
