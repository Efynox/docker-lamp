FROM openjdk:jdk-alpine

# Android SDK
ENV ANDROID_SDK_ROOT /opt/android-sdk-linux
ENV SDK_BUILD 3859397
ENV SDK_CHECKSUM 444e22ce8ca0f67353bda4b85175ed3731cae3ffa695ca18119cbacef1c1bea0

ENV API_LEVELS android-27
ENV BUILD_TOOLS_VERSIONS build-tools-25.0.2,build-tools-27.0.3
ENV ANDROID_EXTRAS extra-android-m2repository,extra-android-support,extra-google-google_play_services,extra-google-m2repository

ENV PATH ${PATH}:${ANDROID_SDK_ROOT}/tools:${ANDROID_SDK_ROOT}/tools/bin

RUN mkdir -p ${ANDROID_SDK_ROOT} && cd /opt
RUN wget -q https://dl.google.com/android/repository/sdk-tools-linux-${SDK_BUILD}.zip -O android-sdk-tools.zip
RUN echo "${SDK_CHECKSUM}  android-sdk-tools.zip" | sha256sum -cs
RUN unzip -q android-sdk-tools.zip -d ${ANDROID_SDK_ROOT}
RUN rm -f android-sdk-tools.zip
RUN cd ${ANDROID_SDK_ROOT}/tools
RUN echo y | android update sdk --no-ui -a --filter tools,platform-tools,${ANDROID_EXTRAS},${API_LEVELS},${BUILD_TOOLS_VERSIONS} --no-https

RUN apk add --no-cache nodejs nodejs-npm