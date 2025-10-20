#!/usr/bin/env bash

#Based on https://www.gnu.org/software/tar/manual/html_section/Reproducibility.html
#Drop the mtime attribute from the files since I was unable to reliably make that reproducible

set -e

export LANG="C"
export TZ=UTC0

location="$(dirname -- "$( readlink -f -- "$0"; )";)"
cd "$location"

# Set timestamp of each directory under $FILES
# to the latest timestamp of any descendant.
echo "Fixing directory timestamps"
find $git_file_list -depth -type d -exec sh -c \
  'touch -r "$0/$(ls -At "$0" | head -n 1)" "$0"' \
  {} ';'

export NGSCOPECLIENT_PACKAGE_VERSION="$(git describe --always --tags)"
export NGSCOPECLIENT_PACKAGE_VERSION_LONG="$(git describe --always --tags --long)"
export SCOPEHAL_PACKAGE_VERSION="cd lib;$(git describe --always --tags --long)"
cat release-info.cmake.in | envsubst > release-info.cmake



SOURCE_EPOCH=$(git log -1 \
                   --format=tformat:%cd \
                   --date=format:%Y-%m-%dT%H:%M:%SZ)

TARFLAGS="
  --sort=name --format=posix
  --pax-option=exthdr.name=%d/PaxHeaders/%f
  --pax-option=delete=atime,delete=ctime
  --mtime=$SOURCE_EPOCH
  --numeric-owner --owner=0 --group=0
  --mode=go+u,go-w
"

git_file_list="$git_file_list release-info.cmake"

echo "Creating tarball"
GZIPFLAGS="--no-name --best"

LC_ALL=C tar $TARFLAGS -cf - $git_file_list |
  gzip $GZIPFLAGS > "tarball.tar.gz"

tar $TARFLAGS -cf - $git_file_list > tarball.tar