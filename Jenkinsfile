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
        dnsConfig:
          options:
            - name: ndots
              value: "2"
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
                    withCredentials([gitUsernamePassword(
                            credentialsId: '3aa88b4c-320d-41fa-8ccb-8af7e350f671', gitToolName: 'git-tool'
                        )]) {
                        sh 'git config --global --add safe.directory \'*\''
                        sh "git fetch --no-tags origin ${env.CHANGE_TARGET}:refs/remotes/origin/${env.CHANGE_TARGET}"
                    }
                    sh 'ct lint --config ct.yaml'
                }
            }
        }
    }
}
