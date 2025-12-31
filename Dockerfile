FROM eclipse-temurin:17-jdk

WORKDIR /app

COPY target/*.war app.war

EXPOSE 4002

ENTRYPOINT ["java","-war","app.war"]

