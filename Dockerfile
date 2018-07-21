FROM tomcat:8

COPY src/web/app/target/*.war /usr/local/tomcat/webapps/
