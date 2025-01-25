# ベースイメージとして Red Hat UBI 8 OpenJDK 17 を使用
FROM registry.access.redhat.com/ubi8/openjdk-17-ubi8

# rootユーザーに切り替え
USER root

# 証明書の更新（update-ca-trust extract）を実行
RUN update-ca-trust extract

# 証明書ストアの設定
ENV TRUSTSTORE_PATH="/etc/pki/ca-trust/extracted/java/cacerts"
ENV TRUSTSTORE_PASSWORD="changeit"

# MavenとJavaにTrustStore設定を適用
ENV MAVEN_OPTS="-Djavax.net.ssl.trustStore=${TRUSTSTORE_PATH} -Djavax.net.ssl.trustStorePassword=${TRUSTSTORE_PASSWORD}"
ENV JAVA_OPTS="-Djavax.net.ssl.trustStore=${TRUSTSTORE_PATH} -Djavax.net.ssl.trustStorePassword=${TRUSTSTORE_PASSWORD}"

# 作業ディレクトリの設定
WORKDIR /app

# アプリの依存関係を解決
COPY pom.xml ./
RUN mvn dependency:go-offline -B

# ソースコードをコピー
COPY src ./src

# ビルドの実行
RUN mvn clean package -DskipTests

# 実行ユーザーを変更（セキュリティ考慮）
USER 1001

# JARファイルの実行
CMD ["java", "-jar", "target/bike-service-1.0.0-SNAPSHOT-runner.jar"]
