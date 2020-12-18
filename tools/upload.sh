#!/usr/bin/env bash
#
# Uploads an image to the len.to s3 bucket. Depends on exiftool
set -e

if [[ "$#" -ne 1 ]] ; then
  cat << EOF

Uploads a file to the len.to s3 bucket.

Usage: $0 <path_to_image>
EOF
  exit 1
fi

if ! [[ -x "$(command -v exiftool)" ]] ; then
  echo 'Error: must install exiftool first.' >&2
  exit 1
fi

bucket=ginput
filepath=$1
filename=$(basename "$1")
extension="${filename##*.}"

id=$(uuidgen | tr [:upper:] [:lower:] | cut -d'-' -f 1)
new_filename="${id}.${extension}"

url="https://d17enza3bfujl8.cloudfront.net/${new_filename}"

# Strip all metadata from the image
exiftool -all= $1

# Upload the image
aws s3 cp --acl public-read "${filepath}" "s3://${bucket}/${new_filename}"

# Copy the URL to the clipboard
printf "${url}" | pbcopy


echo "Enter location"
read loc

# Create the content/img file
img="./content/img/${id}.md"
touch "${img}"
echo "---" > "${img}"
echo "title: ${id}" >> "${img}"
echo "date: $(date +%Y-%m-%d)" >> "${img}"
echo "location: ${loc}" >> "${img}"
echo "img_url: ${url}" >> "${img}"
echo "original_fn: ${filename}" >> "${img}"
echo "tags:" >> "${img}"
echo "- ${loc}" >> "${img}"
echo "" >> "${img}"
echo "---" >> "${img}"

vim "${img}"
