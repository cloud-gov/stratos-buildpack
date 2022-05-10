#!/bin/bash
set -euo pipefail

DOWNLOAD_FOLDER=${CACHE_DIR}/Downloads
mkdir -p ${DOWNLOAD_FOLDER}
DOWNLOAD_FILE=${DOWNLOAD_FOLDER}/go${GO_VERSION}.tar.gz

export GoInstallDir="/tmp/go$GO_VERSION"
mkdir -p $GoInstallDir

# Download the archive if we do not have it cached
if [ ! -f ${DOWNLOAD_FILE} ]; then
  # Delete any cached go downloads, since those are now out of date
  rm -rf ${DOWNLOAD_FOLDER}/go*.tar.gz

  URL=https://buildpacks.cloudfoundry.org/dependencies/go/go${GO_VERSION}.linux-amd64-${GO_SHA256:0:8}.tar.gz

  echo "-----> Download go ${GO_VERSION}"
  curl -s -L --retry 15 --retry-delay 2 $URL -o ${DOWNLOAD_FILE}

  DOWNLOAD_SHA256=$(sha256sum ${DOWNLOAD_FILE} | cut -d ' ' -f 1)

  if [[ $DOWNLOAD_SHA256 != $GO_SHA256 ]]; then
    echo "       **ERROR** MD5 mismatch: got $DOWNLOAD_SHA256 expected $GO_SHA256"
    exit 1
  fi
else
  echo "-----> go install package available in cache"
fi

if [ ! -f $GoInstallDir/go/bin/go ]; then
  tar xzf ${DOWNLOAD_FILE} -C $GoInstallDir
fi

if [ ! -f $GoInstallDir/go/bin/go ]; then
  echo "       **ERROR** Could not download go"
  exit 1
fi


