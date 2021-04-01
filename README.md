# update center .json file creation

## we need to use Java JDK 8 so we use docker image openjdk:8-jdk-buster and add some packages
docker run --name uc -t -i openjdk:8-jdk-buster bash
apt-get install vim git maven -y

### move to working dir
cd /tmp
git clone https://github.com/ikedam/backend-update-center2 && cd backend-update-center2


### generate key and cert - we will add them to artifactory and CB Sidecar Injector
openssl genrsa -out my-update-center.key 1024
openssl req -new -x509 -days 1095 -key my-update-center.key -out my-update-center.crt
cat my-update-center.key my-update-center.crt > my-update-center.pem

### git clone my repo. This repo only differs from original in the pom.xml file that has been updated to target right java version (8)
git clone https://github.com/danieloa/backend-update-center2.git && cd backend-update-center2

### only for documentation purpises, the pom.xml contains these extra lines to select the maven compiler

```bash
      <plugin>
        <artifactId>maven-compiler-plugin</artifactId>
        <configuration>
          <source>1.8</source>
          <target>1.8</target>
        </configuration>
      </plugin>  
```

### compile the project

`root@openjdk # mvn clean compile`

### download plugins

```bash
mkdir plugins
wget https://jenkins-updates.cloudbees.com/download/plugins/chucknorris/*latest*/chucknorris.hpi plugins/
wget https://jenkins-updates.cloudbees.com/download/plugins/beer/*latest*/beer.hpi plugins/
```

### generate update-center.json

```bash
mvn exec:java -Dexec.args="-id my-update-center \
    -h /dev/null \
    -o update-center.json \
    -r release-history.json
    -repository http://<ARTIFACTORY_URL>/artifactory/local-jenkins/ \
    -hpiDirectory ./plugins \
    -nowiki \
    -key my-update-center.key \
    -certificate my-update-center.crt \
    -root-certificate my-update-center.crt \
"
```

### upload local plugins and newly generated update-center to artifactory

```bash
curl -v --user user:pwd --data-binary "@beer.hpi" -X PUT "http://<ARTIFACTORY_URL>/artifactory/local-jenkins/beer.hpi"
curl -v --user user:pwd --data-binary "@chucknorris.hpi" -X PUT "http://<ARTIFACTORY_URL>/artifactory/local-jenkins/chucknorris.hpi"
curl -v --user user:pwd --data-binary "@update-center.json" -X PUT "https://<ARTIFACTORY_URL>/artifactory/local-jenkins/update-center.json"
```

### TODO:
upload cert to OC.
set update-center url to artifactory
check for updates

