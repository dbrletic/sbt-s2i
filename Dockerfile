FROM quay.io/eclipse/che-java11-maven:7.22.0

MAINTAINER Andrew Brletich <dbrletic@gmail.com>

ARG SBT_VERSION=1.4.1
ARG SCALA_VERSION=2.13.3

ENV SBT_S2I_BUILDER_VERSION=0.1
ENV IVY_DIR=/opt/app-root/src/.ivy2
ENV SBT_DIR=/opt/app-root/src/.sbt

LABEL io.k8s.display-name="sbt-s2i $SBT_S2I_BUILDER_VERSION" \
      io.k8s.description="S2I Builder with cached SBT $SBT_VERSION and Scala $SCALA_VERSION" \
      io.openshift.expose-services="9000:http" \
      io.openshift.tags="builder,sbt,scala" \
      io.openshift.min-memory="1Gi"

USER root

RUN echo "deb https://dl.bintray.com/sbt/debian /" | tee -a /etc/apt/sources.list.d/sbt.list \
 && curl -sL "https://keyserver.ubuntu.com/pks/lookup?op=get&search=0x2EE0EA64E40A89B84B2DF73499E82A75642AC823" | apt-key add \
 && apt-get update \
 && apt-get install sbt \
 && apt-get clean

COPY plugins.sbt /tmp

RUN mkdir -p /tmp/caching/project \
 && cd /tmp/caching \
 && echo "sbt.version = $SBT_VERSION" > project/build.properties \
 && echo "scalaVersion := \"$SCALA_VERSION\"" > build.sbt \
 && mv /tmp/plugins.sbt project \
 && sbt -v -sbt-dir $SBT_DIR -sbt-boot $SBT_DIR/boot -ivy $IVY_DIR compile \
 && chown -R 1001:0 /opt/app-root \
 && chmod -R g+rw /opt/app-root \
 && rm -rf /tmp/*

COPY ./s2i/bin/ /usr/libexec/s2i

USER 1001
EXPOSE 9000

CMD ["/usr/libexec/s2i/usage"]