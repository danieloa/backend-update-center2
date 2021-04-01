// Uses Declarative syntax to run commands inside a container.
pipeline {
    agent {
        kubernetes {
            yaml '''
apiVersion: v1
kind: Pod
spec:
  containers:
  - name: shell
    image: openjdk:8-jdk-buster
    command:
    - sleep
    args:
    - infinity
'''
            defaultContainer 'shell'
        }
    }
    stages {
        stage('Main') {
            steps {
                sh '''
                apt-get install vim git maven -y
                openssl genrsa -out my-update-center.key 1024
                openssl req -new -x509 -days 1095 -key my-update-center.key -out my-update-center.crt
                git clone https://github.com/danieloa/backend-update-center2 && cd backend-update-center2
                mkdir plugins
                wget https://jenkins-updates.cloudbees.com/download/plugins/chucknorris/*latest*/chucknorris.hpi plugins/
                wget https://jenkins-updates.cloudbees.com/download/plugins/beer/*latest*/beer.hpi plugins/
                mvn clean compile
                mvn exec:java -Dexec.args="-id my-update-center \
                    -h /dev/null \
                    -o update-center.json \
                    -r release-history.json
                    -repository http://<ARTIFACTORY_URL>/artifactory/local-jenkins/ \
                    -hpiDirectory ./plugins \
                    -nowiki \
                    -key my-update-center.key \
                    -certificate my-update-center.crt \
                    -root-certificate my-update-center.crt"
                curl -v --user user:pwd --data-binary "@beer.hpi" -X PUT "http://<ARTIFACTORY_URL>/artifactory/local-jenkins/beer.hpi"
                curl -v --user user:pwd --data-binary "@chucknorris.hpi" -X PUT "http://<ARTIFACTORY_URL>/artifactory/local-jenkins/chucknorris.hpi"
                curl -v --user user:pwd --data-binary "@update-center.json" -X PUT "https://<ARTIFACTORY_URL>/artifactory/local-jenkins/update-center.json"
                '''
            }
        }
    }
}

