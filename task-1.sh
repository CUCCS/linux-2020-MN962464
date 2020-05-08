#!/usr/bin/env bash

function help_document()
{
	echo "How to use:	bash task-1.sh [options]"
	echo "options:"
	echo "-d	输入图片目录"
	echo "-j	对jpeg格式图片进行图片质量压缩"
	echo "-c	对jpeg/png/svg格式图片在保持原始宽高比的前提下压缩分辨率"
	echo "-w	给图片批量添加水印"
	echo "-p	批量添加前缀"
	echo "-s	批量添加后缀"
	echo "-v	将png/svg图片统一转换为jpg格式图片"
	echo "-h	帮助文档"

}

#JPEG_Compress
function JPEG_Compress {
	mkdir image_output
    	for p in "$1"*.jpg; do
	        fullname=$(basename "$p")
        	filename=$(echo "$fullname" | cut -d . -f1)
        	convert "$p" -quality "$2"% ./image_output/"$filename"."jpg"
	done

}

# Compress_Rate
function Compress_Rate {
	mkdir rate_output;
	for p in $(find "$1" -regex  '.*\.jpg\|.*\.svg\|.*\.png'); 
	do
		fullname=$(basename "$p")
	 	filename=$(echo "$fullname" | cut -d . -f1)
		extension=$(echo "$fullname" | cut -d . -f2)
		convert "$p" -resize "$2" ./rate_output/"$filename"'_'"$2"."$extension"
	echo "$fullname" 'is compressed into' "$filename" '_' "$2" '%.' "$extension"
	done
}


# Watermark
function Watermark {
	mkdir W_output
	for p in $(find "$1" -regex  '.*\.jpg\|.*\.svg\|.*\.png'); 
	do
		fullname=$(basename "$p")
        	filename=$(echo "$fullname" | cut -d . -f1)
		extension=$(echo "$fullname" | cut -d . -f2)
		width=$(identify -format %w "$p")
		convert -background '#FFFFFF' -fill blue -gravity center \
		-size "${width}"x30 caption:"$2" "$p" +swap -gravity south \
		-composite ./W_output/"$filename"."$extension"
	done
}

# 批量重命名（统一添加文件名前缀或后缀，不影响原始文件扩展名）
function addPrefix {
	mkdir p_output
	for p in "$1"*.*;
       	do
		fullname=$(basename "$p")
       		 filename=$(echo "$fullname" | cut -d . -f1)
		extension=$(echo "$fullname" | cut -d . -f2)
		cp "$p" ./p_output/"$2""$filename"."$extension"
	done
}

function addSuffix {
	mkdir s_output
	for p in "$1"*.*;
       	do
		fullname=$(basename "$p")
	 	filename=$(echo "$fullname" | cut -d . -f1)
		extension=$(echo "$fullname" | cut -d . -f2)
		cp "$p" ./s_output/"$filename""$2"."$extension"
	done
}

# 将png/svg图片统一转换为jpg格式图片
function Cvt2JPG {
	mkdir change_output
	for p in $(find "$1" -regex '.*\.svg\|.*\.png');do	
		fullname=$(basename "$p")
       		filename=$(echo "$fullname" | cut -d . -f1)
		extension=$(echo "$fullname" | cut -d . -f2)
		convert "$p" ./change_output/"$filename"".jpg"
	done
}

# main

dir=""

if [[ "$#" -lt 1 ]]; then
	echo "You need to input something"
else 
	while [[ "$#" -ne 0 ]]; do
		case "$1" in
			"-d")
				dir="$2"
				shift 2
				;;
				
			"-j")
				if [[ "$2" != '' ]]; then 
					JPEG_Compress "$dir" "$2"
					shift 2
				else 
					echo "You need to put in a quality parameter"
				fi
				;;
				
			"-c")
				if [[ "$2" != '' ]]; then 
					Compress_Rate "$dir" "$2"
					shift 2
				else 
					echo "You need to put in a resize rate"
				fi
				;;
				
			"-w")
				if [[ "$2" != '' ]]; then 
					Watermark "$dir" "$2"
					shift 2
				else 
					echo "You need to input a string to be embeded into pictures"
				fi
				;;
				
			"-p")
				if [[ "$2" != '' ]]; then 
					addPrefix "$dir" "$2"
					shift 2
				else 
					echo "You need to input a prefix"
				fi
				;;
				
			"-s")
				if [[ "$2" != '' ]]; then 
					addSuffix "$dir" "$2"
					shift 2
				else 
					echo "You need to input a suffix"
				fi
				;;
			
			"-v")
				Cvt2JPG "$dir"
				shift
				;;
				
			"-h")
				help_document
				shift
				;;
		esac
	done
fi

