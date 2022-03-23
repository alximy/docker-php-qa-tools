#!/bin/bash
set -e

usage()
{
  echo "Usage:
  composer-unused ...
  jsonlint ...
  parallel-lint ...
  phpcpd ...
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
    exec "$@"
  fi
fi

sed -i -r "s/foo:x:\d+:\d+:/foo:x:$uid:$gid:/g" /etc/passwd
sed -i -r "s/bar:x:\d+:/bar:x:$gid:/g" /etc/group

if [ $# -eq 0 ]; then
  usage
else
  user=`grep ":x:$uid:" /etc/passwd | cut -d: -f1`
  exec su-exec $user "$@"
fi
