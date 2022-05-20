#!/bin/bash
set -euo pipefail

DOWNLOAD_FOLDER=${CACHE_DIR}/Downloads
mkdir -p ${DOWNLOAD_FOLDER}
DOWNLOAD_FILE=${DOWNLOAD_FOLDER}/go_${GO_VERSION}.tgz

export GoInstallDir="/tmp/go_$GO_VERSION/go"
mkdir -p $GoInstallDir

# Download the archive if we do not have it cached
if [ ! -f ${DOWNLOAD_FILE} ]; then
  # Delete any cached go downloads, since those are now out of date
  rm -rf ${DOWNLOAD_FOLDER}/go*.tgz

  URL=https://buildpacks.cloudfoundry.org/dependencies/go/go_${GO_VERSION}_linux_x64_cflinuxfs3_${GO_SHA256:0:8}.tgz

  echo "-----> Download go ${GO_VERSION}"
  echo "       **URL** $URL"
  echo "       **DOWNLOAD_FILE** $DOWNLOAD_FILE"
  curl -s -L --retry 15 --retry-delay 2 $URL -o ${DOWNLOAD_FILE}

  echo "Checking download folder for files"
  ls -la $DOWNLOAD_FOLDER

# DOWNLOAD_SHA256=$(sha256sum ${DOWNLOAD_FILE} | cut -d ' ' -f 1)
#   if [[ $DOWNLOAD_SHA256 != $GO_SHA256 ]]; then
#     echo "       **URL** $URL"
#     echo "       **ERROR** SHA256 mismatch: got $DOWNLOAD_SHA256 expected $GO_SHA256"
#     exit 1
#  fi
else
  echo "-----> go install package available in cache"
fi

if [ ! -f $GoInstallDir/bin/go ]; then
  tar xzf ${DOWNLOAD_FILE} -C $GoInstallDir
fi

ls -la $GoInstallDir/bin

if [ ! -f $GoInstallDir/bin/go ]; then
  echo "       **ERROR** Could not download go"
  exit 1
fi
