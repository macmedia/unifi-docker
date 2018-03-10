#!/bin/bash

BASEDIR=~/Applications/unifi-video

# Unifi-Video Version 

NAME=unifi-video
ANCESTOR=melser

# Color options
NC='\033[0m' # No Color
RED='\033[0;31m'
BLUE='\033[0;34m'
GREEN='\033[0;32m'


show_usage() {
  echo "Usage:"
  echo "    run -h             Display this help message."
  echo "    run -v {3.9.3}     Run/Install version number."
  exit 0 
}

while getopts ":v:h" opts; do
   case ${opts} in
      v  ) VERSION=${OPTARG} ;;
      :  ) printf "${RED}==>${NC} Invalid option: -$OPTARG requires a version number\n" 1>&2; exit;;
      h  ) show_usage;;
      \? ) show_usage;;
   esac
done

if [ -z "$VERSION" ]
then
  show_usage
fi

printf "${BLUE}==>${NC} Setting up Unifi-Video version $VERSION\n"



# Run docker once to create a container and return the ID
# For following startups, use 'docker start <containerID>'

CONTAINER=`docker ps -a --filter ancestor=$ANCESTOR/unifi-video:$VERSION --format "{{.ID}}"`
IMAGE=`docker images "$ANCESTOR/$NAME:$VERSION" -aq`

# Check if we have an image for this version
if [ -z $IMAGE ]
then
  printf "${RED}==>${NC} No image was found for: $ANCESTOR/$NAME:$VERSION\n"

  # Ask to create the image 
  while true; do
    read -p "Do you want to create this image? [y/n] " yn
    case $yn in
        [Yy]* ) docker image build --rm -t $ANCESTOR/$NAME:$VERSION --build-arg ver=$VERSION .; break;;
        [Nn]* ) printf "${RED}==>${NC} Exiting without doing anything!\n\n";exit;;
        * ) printf "Please answer [y]es or [n]o.";;
    esac
  done

  # Check one more time to see if the image was created successfully 
  if [ -z $(docker images "$ANCESTOR/$NAME:$VERSION" -aq) ]
  then
    printf "${RED}==>${NC} Error creating image!\n"
    printf "${RED}==>${NC} Exiting without doing anything!\n\n"
    exit 0
  fi
fi

if [ ! -z $CONTAINER ]
then
  echo "There seems to be an existing container with the ancestor image. Please use 'docker start <containerID|name> to start it."
  docker ps -a --filter ancestor=$ANCESTOR/unifi-video:$VERSION --format "table {{.ID}}\t{{.Names}}\t{{.CreatedAt}}\t{{.Status}}"
  printf "${RED}==>${NC} Exiting without doing anything!\n\n"
else
  printf "Checking for Host data volumes: MongoDB-"
  if [ -d $BASEDIR/mongodb ]
  then
    printf "${GREEN}OK${NC}"
  else
    printf "NOK\n"
    echo "Please make sure you have created the following directory: $BASEDIR/mongodb"
    exit 1;
  fi
  printf " | Unifi-Video-"
  if [ -d $BASEDIR/unifi-video ]
  then
    printf "${GREEN}OK${NC}"
  else
    printf "NOK\n"
    echo "Please make sure you have created the following directory: $BASEDIR/unifi-video"
    exit 1;
  fi
  printf " | Log-"
  if [ -d $BASEDIR/log ]
  then
    printf "${GREEN}OK${NC}\n"
  else
    printf "NOK\n"
    echo "Please make sure you have created the following directory: $BASEDIR/log"
    exit 1;
  fi

  # Stop older running version
  RUNNING=`docker ps | grep "unifi-video" | awk '{ print $1 }'`
  if [ ! -z $RUNNING ]
  then
    docker stop $RUNNING 1>/dev/null &
    pid=$!
    printf "${BLUE}==>${NC} Stopping older version  "
    s='-\|/'; i=0; while kill -0 $pid 2>/dev/null; do i=$(( (i+1) %4 )); 
    printf "\b${s:$i:1}"; sleep .1; done
    printf "\b \n"
  fi

  printf "${BLUE}==>${NC} Starting new version "
  docker run -d --privileged \
  -v $BASEDIR/mongodb:/var/lib/mongodb \
  -v $BASEDIR/unifi-video:/var/lib/unifi-video \
  -v $BASEDIR/log:/var/log/unifi-video \
  -p 6666:6666 \
  -p 7080:7080 \
  -p 7442:7442 \
  -p 7443:7443 \
  -p 7445:7445 \
  -p 7446:7446 \
  -p 7447:7447 \
  --name ${NAME}_${VERSION} \
  --restart=unless-stopped \
  $ANCESTOR/$NAME:$VERSION

fi
