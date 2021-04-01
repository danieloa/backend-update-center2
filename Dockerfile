FROM openjdk:8-jdk-buster
RUN apt-get update
RUN apt-get install maven git -y
WORKDIR /update-center
ADD plugins/ ./plugins
ADD certs/ .
RUN mvn clean build
RUN mvn exec:java -Dexec.args="-id my-update-center \
    -h /dev/null \
    -o update-center.json \
    -r release-history.json \
    -repository http://zzz-632389697.us-east-1.yyy.xxx.com/artifactory/local-jenkins/ \
    -hpiDirectory ./plugins \
    -nowiki \
    -key my-update-center.key \
    -certificate my-update-center.crt \
    -root-certificate my-update-center.crt \
"
RUN cat update-center.json
