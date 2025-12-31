FROM eclipse-temurin:17-jdk

WORKDIR /app

COPY target/*.war app.war

EXPOSE 8080

ENTRYPOINT ["java","-war","app.war"]

