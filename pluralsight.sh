#!/bin/bash

# if credentials are incorrect
# will download the first chapter's videos
# and then return the error
# "No video formats found"
# username="dosanbr@outlook.com"
# username="newsanbr@outlook.com"
# username="oldsanbr@outlook.com"
# password="myAss069"
download_dir="/media/gusalbukrk/Files/Downloading2"

if [ ! -d "${download_dir}" ]; then
  mkdir "${download_dir}"
fi

to_download_content=$(cat download-pluralsight)
if [[ "${to_download_content}" = "" ]]; then
  echo "The 'download-pluralsight' file is empty. Nothing to download!"
  exit 0
fi

while read url; do
  if [[ "${url}" = "" ]]; then
    continue
  fi

  # FIXME: format title?
  title=$(grep -Po '(?<=https://app.pluralsight.com/library/courses/).*' <<< "${url}" | sed 's/\/$//g')

  echo "=============== Downloading '${title}'... ==============="

  course_dir="${download_dir}/${title}/"
  mkdir "${course_dir}"

  youtube-dl --verbose --cookies "./cookies.txt" --sleep-interval 180 --max-sleep-interval 300 --limit-rate 250K --retries 5 --output "${course_dir}%(playlist_index)s - %(title)s.%(ext)s" "${url}"

  exit_code=$?

  if [ "${exit_code}" -eq 0 ]; then
    sed -i "\#${url}#d" download-pluralsight
    echo "Download completed!"
    echo
    exit 1
  else
    echo "There was an error while downloading '${title}'!"
    echo
    exit 1
  fi

done <<< "${to_download_content}"