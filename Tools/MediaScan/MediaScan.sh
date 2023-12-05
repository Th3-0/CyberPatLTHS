#!/bin/bash

if [ -f "media.log" ]; then
	rm media.log
fi

fileTypes=(
	# Video
	"mp4" "mpeg" "avi" "mpg" "webm" "mov" "wav"
	# Pictures
	"png" "jpg" "jpeg" "gif" "bmp" "tiff" "raw"
	# Audio
	"mp3" "ogg" "m4a" "flac"
	# Misc
	"txt" "docx" "pdf" "doc" "ppt" "pptx" "xls" "ps"
) 

fileCount=0
echo "Scanning..."
for file in "${fileTypes[@]}"; do
 	foundFiles=$(sudo find /home -name "*.$file" -type f)
 	if [ -n "$foundFiles" ]; then
		echo "$foundFiles" >> media.log
		fileCount=$((fileCount + $(echo "$foundFiles" | wc -l))
 	fi
done

echo "Media scan complete $fileCount files found."
echo "Output dropped to 'media.log'"
