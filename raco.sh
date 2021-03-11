#!/bin/bash

# Dependencies:
# - ffmpeg
# - imagemagick

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[0;33m'
NC='\033[0m'

srcPath=$1
destPath=$2

srcExt="${srcPath##*.}"
destExt="${destPath##*.}"

supportExt=("mp4" "mkv" "avi" "flv" "mov" "webm" "mp3" "png" "jpg" "pdf" "gif")

# Install ffmpeg
if [ ! command -v ffmpeg &> /dev/null ]; then
	if [[ $UID != 0 ]]; then
		echo -e "\n${YELLOW}Please run this program with sudo, so required programs can be installed.\n"
		exit 1
	fi
	if [ ! command -v apt-get &> /dev/null ]; then
	    echo -e "\n${GREEN}Checking for program updates..."
		sudo apt-get update &> /dev/null
		echo -e "${GREEN}Installing ffmpeg..."
		sudo apt-get install -y ffmpeg &> /dev/null
		echo -e "${GREEN}ffmpeg installed.\n"
	elif [ ! command -v pacman &> /dev/null ]; then
		echo -e "${GREEN}Installing ffmpeg..."
		sudo pacman -S --noconfirm ffmpeg4.0 &> /dev/null
		echo -e "${GREEN}ffmpeg installed.\n"
	else
		echo -e "\n${RED}Your operating system is not supported!"
		exit 1
	fi
fi

# Install imagemagick
if ! command -v convert &> /dev/null
then
	if [[ $UID != 0 ]]; then
		echo -e "\n${YELLOW}Please run this program with sudo, so required programs can be installed.\n"
		exit 1
	fi
	if [ ! command -v apt-get &> /dev/null ]; then
		echo -e "\n${GREEN}Checking for program updates..."
		sudo apt-get update &> /dev/null
		echo -e "${GREEN}Installing imagemagick..."
		sudo apt-get install -y imagemagick &> /dev/null
		echo -e "${GREEN}imagemagick installed.\n"
	elif [ ! command -v pacman &> /dev/null ]; then
		echo -e "${GREEN}Installing imagemagick..."
		sudo pacman -S --noconfirm imagemagick &> /dev/null
		echo -e "${GREEN}imagemagick installed.\n"
	else
		echo -e "\n${RED}Your operating system is not supported!"
		exit 1
	fi
fi

if [[ ! $# -eq 2 ]]; then
	echo -e "\n${YELLOW}You need to provide 2 arguments!\n"
	echo -e "First is path to file you want to convert."
	echo -e "Second is location with file name and extension for converted file.\n"
	echo -e "${GREEN}Format: raco <src> <dest>\n"
	echo -e "${BLUE}Examples:"
	echo -e "\traco movie.avi movie2.mp4"
	echo -e "\traco /downloads/movie.avi /downloads/movie2.mp4"
	echo -e "\traco '/downloads/Movie 1.avi' '/downloads/Movie 2.mp4'\n"
	exit 1
fi

if [ ! -f "$srcPath" ]; then
	echo -e "\n${YELLOW}${srcPath} does not exist.\n"
	exit 1
fi

if [ -f "$destPath" ]; then
	echo -e "\n${YELLOW}${destPath} already exist. Please choose different file name or location.\n"
	exit 1
fi

if [[ ! " ${supportExt[@]} " =~ " ${srcExt} " ]]; then
	echo -e "\n${YELLOW}Extension ${srcExt} is currently not supported.\n"
	echo -e "${BLUE}Supported extensions:"
	for ext in "${supportExt[@]}"
	do
		echo -e " - $ext"
	done
	echo -e "\n"
	exit 1
fi

if [[ ! " ${supportExt[@]} " =~ " ${destExt} " ]]; then
	echo -e "\n${YELLOW}Extension ${destExt} is currently not supported.\n"
    echo -e "${BLUE}Supported extensions:"
    for ext in "${supportExt[@]}"
    do
    	echo -e " - $ext"
    done
	echo -e "\n"
    exit 1
fi

if [ "${srcExt}" == "mp4" ]; then
	if [ "${destExt}" == "mp4" ]; then
		echo -e "${GREEN}Convertion from ${srcExt} to ${destExt} has started..."
        cp "${srcPath}" "${destPath}"
        echo -e "${GREEN}Convertion completed."
	elif [ "${destExt}" == "mkv" ] || [ "${destExt}" == "avi" ]; then
		echo -e "${GREEN}Convertion from ${srcExt} to ${destExt} has started..."
		ffmpeg -i "${srcPath}" -vcodec copy -acodec copy "${destPath}" &> /dev/null
		echo -e "${GREEN}Convertion completed."
	elif [ "${destExt}" == "flv" ]; then
		echo -e "${GREEN}Convertion from ${srcExt} to ${destExt} has started..."
		ffmpeg -i "${srcPath}" -c copy -copyts "${destPath}" &> /dev/null
		echo -e "${GREEN}Convertion completed."
	elif [ "${destExt}" == "mov" ]; then
		echo -e "${GREEN}Convertion from ${srcExt} to ${destExt} has started..."
		ffmpeg -i "${srcPath}" "${destPath}" &> /dev/null
		echo -e "${GREEN}Convertion completed."
	elif [ "${destExt}" == "webm" ]; then
		echo -e "${GREEN}Convertion from ${srcExt} to ${destExt} has started..."
		ffmpeg -i "${srcPath}" -c:v libvpx-vp9 -crf 30 -b:v 0 -b:a 128k -c:a libopus "${destPath}" &> /dev/null
		echo -e "${GREEN}Convertion completed."
	elif [ "${destExt}" == "mp3" ]; then
		echo -e "${GREEN}Convertion from ${srcExt} to ${destExt} has started..."
		ffmpeg -i "${srcPath}" -vn "${destPath}" &> /dev/null
		echo -e "${GREEN}Convertion completed."
	else
		echo -e "${YELLOW}Convertion from ${srcExt} to ${destExt} is not supported yet."
	fi
elif [ "${srcExt}" == "png" ]; then
	if [ "${destExt}" == "png" ]; then
		echo -e "${GREEN}Convertion from ${srcExt} to ${destExt} has started..."
        cp "${srcPath}" "${destPath}"
		echo -e "${GREEN}Convertion completed."
	elif [ "${destExt}" == "jpg" ] || [ "${destExt}" == "gif" ] || [ "${destExt}" == "pdf" ]; then
		echo -e "${GREEN}Convertion from ${srcExt} to ${destExt} has started..."
		convert "${srcPath}" "${destPath}" &> /dev/null
		echo -e "${GREEN}Convertion completed."
	else
		echo -e "${YELLOW}Convertion from ${srcExt} to ${destExt} is not supported yet."
	fi
elif [ "${srcExt}" == "jpg" ]; then
	if [ "${destExt}" == "jpg" ]; then
		echo -e "${GREEN}Convertion from ${srcExt} to ${destExt} has started..."
		cp "${srcPath}" "${destPath}"
		echo -e "${GREEN}Convertion completed."
	elif [ "${destExt}" == "png" ] || [ "${destExt}" == "gif" ] || [ "${destExt}" == "pdf" ]; then
		echo -e "${GREEN}Convertion from ${srcExt} to ${destExt} has started..."
		convert "${srcPath}" "${destPath}" &> /dev/null
		echo -e "${GREEN}Convertion completed."
	else
		echo -e "${YELLOW}Convertion from ${srcExt} to ${destExt} is not supported yet."
	fi
elif [ "${srcExt}" == "pdf" ]; then
	if [ "${destExt}" == "pdf" ]; then
		echo -e "${GREEN}Convertion from ${srcExt} to ${destExt} has started..."
		cp "${srcPath}" "${destPath}"
		echo -e "${GREEN}Convertion completed."
	elif [ "${destExt}" == "png" ] || [ "${destExt}" == "jpg" ] || [ "${destExt}" == "gif" ]; then
		echo -e "${GREEN}Convertion from ${srcExt} to ${destExt} has started..."
		convert "${srcPath}" "${destPath}" &> /dev/null
		echo -e "${GREEN}Convertion completed."
	else
		echo -e "${YELLOW}Convertion from ${srcExt} to ${destExt} is not supported yet."
	fi
else
	echo -e "${YELLOW}Convertion from ${srcExt} to ${destExt} is not supported yet."
fi
