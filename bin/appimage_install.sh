#!/usr/bin/env bash
#
# Moves appimage to ~/.local/bin and registers desktop shortcut

set -e

file=$1

# check if file is given and that its extention is .appimage
if [ -z "$file" ] || [ "${file##*.}" != "AppImage" ]; then
    echo "Usage: $0 <file.AppImage>"
    exit 1
fi

mv "$file" "$HOME/.local/bin/"

file_name=$(basename "$file")

target_file="$HOME/.local/bin/$file_name"

chmod +x "$target_file"

mkdir "/tmp/$file_name"

pushd "/tmp/$file_name" || exit 1

"$target_file" --appimage-extract
# replace Exec=.* with Exec=$target_file in .desktop file
sed -i "s|Exec=.*|Exec=$target_file|g" /tmp/"$file_name"/squashfs-root/*.desktop

cp /tmp/"$file_name"/squashfs-root/*.desktop ~/.local/share/applications/

popd || exit 1

rm -rf "/tmp/$file_name/"

echo "Installed $file to $target_file"
