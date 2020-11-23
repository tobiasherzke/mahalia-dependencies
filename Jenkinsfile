pipeline {
    agent {label "mhadev && linux"}
    stages {
        stage("create debian packages") {
            steps {
                sh 'git clean -fdx .'
                sh 'mhamakedeb mahalia-dependencies.csv $(cat version) armhf'
            }
        }
    }

    // Email notification on failed build taken from
    // https://jenkins.io/doc/pipeline/tour/post/
    // multiple recipients are comma-separated:
    // https://jenkins.io/doc/pipeline/steps/workflow-basic-steps/#-mail-%20mail
    post {
        failure {
            mail to: 't.herzke@hoertech.de',
                 subject: "Failed Pipeline: ${currentBuild.fullDisplayName}",
                 body: "Something is wrong with ${env.BUILD_URL}"
        }
    }
}
