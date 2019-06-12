#!/bin/bash -xe

tag_name=${TRAVIS_TAG:-${TRAVIS_BRANCH}}
platform=${PLATFORM:-amd64}
manifest=${DOCKER_ORG}/${DOCKER_IMAGE}:${tag_name}

# Login to docker hub
unset HISTFILE; set +x; echo ${DOCKER_PASSWORD} | docker login -u ${DOCKER_USERNAME} --password-stdin; set -x

# Build docker image
docker run --rm --privileged -v ${PWD}:/tmp/work --entrypoint buildctl-daemonless.sh moby/buildkit:master \
       build \
       --frontend dockerfile.v0 \
       --opt platform=linux/${platform} \
       --opt filename=./Dockerfile \
       --opt build-arg:GIT_BRANCH=${TRAVIS_BRANCH} \
       --opt build-arg:GIT_COMMIT_ID=${TRAVIS_COMMIT} \
       --opt build-arg:TRAVIS_BUILD_NUMBER=${TRAVIS_BUILD_NUMBER} \
       --opt build-arg:TRAVIS_BUILD_WEB_URL=${TRAVIS_BUILD_WEB_URL} \
       --opt build-arg:TRAVIS_JOB_WEB_URL=${TRAVIS_JOB_WEB_URL} \
       --output type=docker,name=${manifest}-${platform},dest=/tmp/work/target/${DOCKER_IMAGE}-${platform}.docker.tar \
       --local context=/tmp/work \
       --local dockerfile=/tmp/work \
       --progress plain

# Load docker image locally
docker load --input ./target/${DOCKER_IMAGE}-${platform}.docker.tar

# Push platform specific image to docker hub
docker push ${manifest}-${platform}
