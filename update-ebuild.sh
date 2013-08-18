#!/bin/bash
P="WW-ParserGen-PDA"
V="0.12.2"
PV="$P-$V"

overlay_dir="/usr/local/portage/dev-perl/$P"
bin_dir=$(realpath $(dirname "$0"))
ebuild_dir="$bin_dir/dev-perl/$P"

cd "$bin_dir"
rm -f "$PV.tar.gz"
./make-tar.sh
mv -i "$PV.tar.gz" "/usr/distfiles"

cd "$overlay_dir"
rsync --archive -v "$ebuild_dir/"* .
ebuild --force "$PV.ebuild" manifest

owner_group=$(stat --printf='%U:%G' "$bin_dir")
rsync --archive -v "$overlay_dir/"* "$ebuild_dir"
chown -R $owner_group "$ebuild_dir"
ls -al "$ebuild_dir"
echo diff --recursive --brief . "$ebuild_dir"
diff --recursive --brief . "$ebuild_dir"

