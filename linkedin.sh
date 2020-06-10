#!/bin/bash

# if credentials are incorrect
# will download the first chapter's videos
# and then return the error
# "No video formats found"
username="lgalbuquerquebr@gmail.com"
password="wd051017"
download_dir="/media/gusalbukrk/Files/Downloading"

if [ ! -d "${download_dir}" ]; then
  mkdir "${download_dir}"
fi

to_download_content=$(cat download-linkedin)
if [[ "${to_download_content}" = "" ]]; then
  echo "The 'download-linkedin' file is empty. Nothing to download!"
  exit 0
fi

while read url; do
  if [[ "${url}" = "" ]]; then
    continue
  fi

  # FIXME: format title?
  title=$(grep -Po '(?<=https://www.linkedin.com/learning/).*' <<< "${url}" | sed 's/\/$//g')

  echo "=============== Downloading '${title}'... ==============="

  course_dir="${download_dir}/${title}/"
  mkdir "${course_dir}"

  youtube-dl --verbose --username "${username}" --password "${password}" --sleep-interval 10 --retries 3 --format "best[height=540]" --output "${course_dir}%(playlist_index)s - %(title)s.%(ext)s" "${url}"

  exit_code=$?

  if [ "${exit_code}" -eq 0 ]; then
    sed -i "\#${url}#d" download-linkedin
    echo "Download completed!"
    echo
  else
    echo "There was an error while downloading '${title}'!"
    echo
    exit 1
  fi

done <<< "${to_download_content}"