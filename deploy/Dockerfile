
# Base image Dockerfile - openjdk_maven
FROM openjdk:8-jdk-buster
RUN apt-get update
RUN apt-get install maven -y
WORKDIR /update-center
COPY ../pom.xml .
ADD ../src/ .


