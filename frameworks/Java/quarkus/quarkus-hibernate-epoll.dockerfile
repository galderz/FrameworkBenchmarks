FROM maven:3.6.3-jdk-11-slim as maven
WORKDIR /quarkus
COPY pom.xml pom.xml
COPY base/pom.xml base/pom.xml
COPY hibernate/pom.xml hibernate/pom.xml
COPY hibernate-epoll/pom.xml hibernate-epoll/pom.xml
COPY pgclient/pom.xml pgclient/pom.xml
RUN mvn dependency:go-offline -q -pl base
COPY base/src base/src
COPY hibernate/src hibernate/src
COPY hibernate-epoll/src hibernate-epoll/src
COPY pgclient/src pgclient/src

RUN mvn package -q -pl hibernate-epoll -am

FROM openjdk:11.0.6-jdk-slim
WORKDIR /quarkus
COPY --from=maven /quarkus/hibernate-epoll/target/lib lib
COPY --from=maven /quarkus/hibernate-epoll/target/hibernate-epoll-1.0-SNAPSHOT-runner.jar app.jar
CMD ["java", "-server", "-XX:-UseBiasedLocking", "-XX:+UseStringDeduplication", "-XX:+UseNUMA", "-XX:+UseParallelGC", "-Djava.lang.Integer.IntegerCache.high=10000", "-Dvertx.disableHttpHeadersValidation=true", "-Dvertx.disableMetrics=true", "-Dvertx.disableH2c=true", "-Dvertx.disableWebsockets=true", "-Dvertx.flashPolicyHandler=false", "-Dvertx.threadChecks=false", "-Dvertx.disableContextTimings=true", "-Dvertx.disableTCCL=true", "-Dhibernate.allow_update_outside_transaction=true", "-Djboss.threads.eqe.statistics=false", "-jar", "app.jar"]
