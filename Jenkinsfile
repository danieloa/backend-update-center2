// This is still in WIP
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
    parameters{ 
        text(name: 'my_update_center_key', 
                 defaultValue: '''-----BEGIN RSA PRIVATE KEY-----
MIICXgIBAAKBgQCn1ptGOi6M1CDnC/DsxmFXGAfa1WIq7sOVjPkcZ0YgKfIARM02
EhM/bnKOKdUxyxUl2t9e7IOlCTErVDrVQZI8uuDFQvQU6rNf288sTSN5gHrfVn4X
5J8kRjZqv4yv4oFGUG2mKwoO+ErOUU6GN4UZIPd6mb+7CArHB6fDE5ehywIDAQAB
AoGBAIZlBEUB........................F1H8Bh5lCDJ9OsYaL4UmrN0CQQCm
G6P0iXsS1TaLe4shGcwiFDHZo4ivo5SrLfGhWPvG0kJieuJbz8wu2+gvO2fKE9dC
mmfl43hwVM5Y8hZYLEZtAkEAxTEDMvX5wZ1WJHNwL1FFMnkDHF2bghJYd8/PASkN
qEhVE7mFcsvlGwMAtoFy5BeyYmBqPKHBxsAOZziFA1D+kg==
-----END RSA PRIVATE KEY-----''', description: 'key file')    
        text(name: 'my_update_center_crt', 
                 defaultValue: '''-----BEGIN CERTIFICATE-----
MIICzzCCAjgCCQDjj0XktD/j7TANBgkqhkiG9w0BAQsFADCBqzELMAkGA1UEBhMC
RVMxDDAKBgNVBAgMA1ZBTDERMA8GA1UEBwwIVmFsZW5jaWExEjAQBgNVBAoMCUNs
b3VkYmVlczEMMAoGA1UECwwDU1JFMTMwMQYDVQQDDCphODViODFjMmZhM2RmNDAw
NGE5NDM3MzZ........................RTuDFQvQU6rNf288sTSN5gHrfVn4X
5J8kRjZqv4yv4oFGUG2mKwoO+ErOUU6GN4UZIPd6mb+7CArHB6fDE5ehywIDAQAB
MA0GCSqGSIb3DQEBCwUAA4GBAF9KxDL15oeRWJvqnfIm8DlDtCTHh7D4gLpo+NqY
ZxT/Oy6RyhnjvZqgoV7YXJl6ieadim2d6PeLPVe21jazCXfgKT7NEliARQ2wFCfw
SgLzbCOHSVBzRVdwZZrpIYMQr0MinLJcGxDXAVJBi8tENDowFtw83m4pUIqoOaJI
OOD3
-----END CERTIFICATE-----''', description: 'cert file')    
        string(name: '$artifactory_url', defaultValue: 'zzz-632389697.us-east-1.yyy.xxx.com', description: 'url') 
        string(name: '$user', defaultValue: 'admin', description: 'url') 
        string(name: '$pwd', defaultValue: 'pwd', description: 'url') 
    }
    stages {
        stage('Main') {
            steps {
                sh '''
                apt-get update && apt-get install git maven -y
                git clone https://github.com/danieloa/backend-update-center2 && cd backend-update-center2
                echo ${my_update_center_key} > my-update-center.key
                echo ${my_update_center_crt} > my-update-center.crt
                mkdir plugins
                wget -P plugins/ https://jenkins-updates.cloudbees.com/download/plugins/chucknorris/*latest*/chucknorris.hpi 
                wget -P plugins/ https://jenkins-updates.cloudbees.com/download/plugins/beer/*latest*/beer.hpi
                echo "plugins downloaded"
                mvn compile
                echo "building"
                mvn exec:java -Dexec.args="-id my-update-center \
                    -h /dev/null \
                    -o update-center.json \
                    -r release-history.json \
                    -repository http://zzz-632389697.us-east-1.yyy.xxx.com/artifactory/local-jenkins/ \
                    -hpiDirectory ./plugins \
                    -nowiki \
                    -key my-update-center.key \
                    -certificate my-update-center.crt \
                    -root-certificate my-update-center.crt"
                cat update-center.json
                curl -v --user $user:$pwd --data-binary "@beer.hpi" -X PUT "http://$artifactory_url/artifactory/local-jenkins/beer.hpi"
                curl -v --user $user:$pwd --data-binary "@chucknorris.hpi" -X PUT "http://$artifactory_url/artifactory/local-jenkins/chucknorris.hpi"
                curl -v --user $user:$pwd --data-binary "@update-center.json" -X PUT "https://$artifactory_url/artifactory/local-jenkins/update-center.json"
                '''
            }
        }
    }
}
