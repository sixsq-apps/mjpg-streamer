#!/bin/bash -xe
curl -sL -o "${HADOLINT}" "https://github.com/hadolint/hadolint/releases/download/v1.16.0/hadolint-$(uname -s)-$(uname -m)"
chmod 700 ${HADOLINT}
${HADOLINT} --ignore DL3018 Dockerfile
