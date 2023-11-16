#!/bin/bash
set -e

usage()
{
  echo "Usage:
  composer-unused ...
  jsonlint ...
  parallel-lint ...
  pdepend ...
  phan ...
  php-cs-fixer ...
  phpcs ...
  phpdd ...
  phpinsights ...
  phploc ...
  phpmd ...
  phpmetrics ...
  phpmnd ...
  phpstan ...
  twigcs ...
  yaml-lint ..."

  exit
}

uid=$(stat -c %u .)
gid=$(stat -c %g .)

if [ $uid == 0 ] && [ $gid == 0 ]; then
  if [ $# -eq 0 ]; then
    usage
  else
    if [ -d "${QA_VENDOR_PATH}/$1" ]; then
      export QA_TOOL="$1"
    else
      export QA_TOOL="all"
    fi

    # always update dependencies
    composer --working-dir=/usr/local/src bin "$QA_TOOL" update

    exec "$@"
  fi
fi

if [ $# -eq 0 ]; then
  usage
else
  if [ -d "${QA_VENDOR_PATH}/$1" ]; then
    export QA_TOOL="$1"
  else
    export QA_TOOL="all"
  fi

  # always update dependencies
  composer --working-dir=/usr/local/src bin "$QA_TOOL" update

  exec su-exec php-qa-tools "$@"
fi
