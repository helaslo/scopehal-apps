#!/usr/bin/env bash
#Based on https://www.gnu.org/software/tar/manual/html_section/Reproducibility.html

set -e

export LANG="C"


export TZ=UTC0

function fix_commit_time() {
   date=$(git log -1 \
    --format=tformat:%cd \
    --date=format:%Y-%m-%dT%H:%M:%SZ \
    "$@")
    touch -md "$date" "$file"
}

location="$(dirname -- "$( readlink -f -- "$0"; )";)"
cd "$location"

echo "Getting file list from version control"
git_file_list=$(git ls-files --recurse-submodules )
file_count=$(echo "$git_file_list" | wc -l)
echo "There are $file_count files "

#run in parallel according to https://stackoverflow.com/a/356154 to speed up
pids=()
echo "Setting file change times to commit times"

echo "$git_file_list" | while read -r file; do
  fix_commit_time "$file"  &
  pids[${i}]=$!
true
done

echo "Waiting for all forks to exit"
for pid in ${pids[*]}; do
    wait $pid
done

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

#
# Create $ARCHIVE.tgz from $FILES, pretending that
# the modification time for each newer file
# is that of the most recent commit of any source file.

SOURCE_EPOCH=$(git log -1 \
                   --format=tformat:%cd \
                   --date=format:%Y-%m-%dT%H:%M:%SZ)
TARFLAGS="
  --sort=name --format=posix
  --pax-option=exthdr.name=%d/PaxHeaders/%f
  --pax-option=delete=atime,delete=ctime
  --clamp-mtime --mtime=$SOURCE_EPOCH
  --numeric-owner --owner=0 --group=0
  --mode=go+u,go-w
"

touch -md "$SOURCE_EPOCH" release-info.cmake

git_file_list="$git_file_list release-info.cmake"

echo "Creating tarball"
GZIPFLAGS="--no-name --best"
LC_ALL=C tar $TARFLAGS -cf - $git_file_list |
  gzip $GZIPFLAGS > "tarball.tar.gz"