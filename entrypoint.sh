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
    # always update dependencies
    composer --working-dir=/usr/local/src bin all update

    exec "$@"
  fi
fi

sed -i -r "s/php-qa-tools:x:\d+:\d+:/php-qa-tools:x:$uid:$gid:/g" /etc/passwd
sed -i -r "s/php-qa-tools:x:\d+:/php-qa-tools:x:$gid:/g" /etc/group

if [ $# -eq 0 ]; then
  usage
else
  # always update dependencies
  composer --working-dir=/usr/local/src bin all update

  user=`grep ":x:$uid:" /etc/passwd | cut -d: -f1`
  exec su-exec $user "$@"
fi
