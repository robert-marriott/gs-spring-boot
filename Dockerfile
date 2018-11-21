#######################################################################
# This is an alpine based spring-boot container, the src forked from  #
# https://github.com/spring-guides/gs-spring-boot for what is         #
# most likely an interview skill proof demonstration. Alpine chosen   #
# for reduced attack surface and cool, wintery vibes.                 #
#######################################################################
FROM alpine

MAINTAINER Presumably nobody

LABEL container_software_rungime="Spring Boot" \
      breakfast_eaten="hard boiled eggs, banana"

ENV GRADLE_VERSION 4.10.2

COPY complete /complete

RUN apk add --update bash \
                     gradle \
                     findutils \
                     openjdk8 && \
    # Create unpriveleged user to run the spring application
    addgroup -S springtest && adduser -S -G springtest springtest && \
	  adduser -s /bin/bash -u 1001 -G root -D default && \
    # Complete the gradle build of the application
    cd complete && \
    gradle build && \
    # Remove unneeded packages and clean package manager cache
    apk del bash gradle && \
    rm -rf /var/cache/apk/* && \
    # change ownership of build artifacts to unpriveleged user
    chown -R springtest:springtest /complete && \
    # Remove unnecessary kruft. Could be done in multistage. meh.
    mv /complete/build/libs/gs-spring-boot-0.1.0.jar / && \
    rm -rf /complete

# Expose command is cosmetic, but I forgot to invoke the container with the -p arguement, so here we are
EXPOSE 8080

# Drop to least priveleged linux user
USER springtest

CMD  java -jar gs-spring-boot-0.1.0.jar

# This could also be used as a multistage build, but for such a small file,
# I don't see much of a point. This will be about as compact as it can get.
# Multistage builds also break compatibility with openshift build configs, as
# they rely on using older versions of docker. With a proper ci pipeline that
# would not be an issue
