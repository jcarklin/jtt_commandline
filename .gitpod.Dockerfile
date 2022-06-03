# Temp
FROM gitpod/workspace-full-vnc:2022-05-25-08-50-33
SHELL ["/bin/bash", "-c"]

# Install Open JDK for android and other dependencies
USER root
RUN install-packages openjdk-8-jdk -y \
        libgtk-3-dev \
        libnss3-dev \
        fonts-noto \
        fonts-noto-cjk \
    && update-java-alternatives --set java-1.8.0-openjdk-amd64

# Insall dart 
USER gitpod
RUN brew tap dart-lang/dart && brew install dart