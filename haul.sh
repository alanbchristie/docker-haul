#!/bin/bash

# Haul (pull) images using the Docker Hub V2 API.
# With thanks to Jerry Baker
# (https://gist.github.com/kizbitz/e59f95f7557b4bbb8bf2)
#
# Pulls all images associated with a Docker Hub user account and namespace
# (remembering that the namespace and user may not be the same).
#
# If you do not want to keep the images add the argument NO-KEEP.

set -e

# Expect username, password and namespace
: "${DOCKER_USERNAME?Need to set DOCKER_USERNAME}"
: "${DOCKER_PASSWORD?Need to set DOCKER_PASSWORD}"
: "${DOCKER_NAMESPACE?Need to set DOCKER_NAMESPACE}"

# Has the user used '--no-keep'?
NO_KEEP=0
if [[ $# -gt 0 ]]
then
  if [[ ${1} == '--no-keep' ]]
  then
    NO_KEEP=1
  fi
fi
# or, has the user used '--just-list'?
JUST_LIST=0
if [[ $# -gt 0 ]]
then
  if [[ ${1} == '--just-list' ]]
  then
    JUST_LIST=1
  fi
fi

echo "+> $(date)"

echo "+> Getting API token..."
TOKEN=$(curl -s -H "Content-Type: application/json" \
        -X POST \
        -d '{"username": "'${DOCKER_USERNAME}'", "password": "'${DOCKER_PASSWORD}'"}' \
        https://hub.docker.com/v2/users/login/ | \
        jq -r .token)

echo "+> Getting registries..."
REG_LIST=$(curl -s -H "Authorization: JWT ${TOKEN}" \
        https://hub.docker.com/v2/repositories/${DOCKER_NAMESPACE}/?page_size=100 | \
        jq -r '.results|.[]|.name')
NUM_REG=0
for i in ${REG_LIST}
do
  echo "   ${i}"
  ((NUM_REG=NUM_REG+1))
done
echo "+> Got ${NUM_REG} registries"

echo "+> Getting registry images..."
NUM_IMAGES=0
for i in ${REG_LIST}
do
  echo "   Getting tags for ${i}..."
  IMAGE_TAGS=$(curl -s -H "Authorization: JWT ${TOKEN}" \
        https://hub.docker.com/v2/repositories/${DOCKER_NAMESPACE}/${i}/tags/?page_size=100 | \
        jq -r '.results|.[]|.name')
  # Compile a list of images with tags
  # and put assemble them into the FULL_IMAGE_LIST variable
  for j in ${IMAGE_TAGS}
  do
    FULL_IMAGE_LIST="${FULL_IMAGE_LIST} ${DOCKER_NAMESPACE}/${i}:${j}"
    ((NUM_IMAGES=NUM_IMAGES+1))
  done
done
echo "+> Got ${NUM_IMAGES} images (and their tags)"

# If "--just-list" list the images and stop here.
if [[ ${JUST_LIST} == 1 ]]
then
  echo "+> Images follow..."
  for i in ${FULL_IMAGE_LIST}
  do
    echo "   ${i}"
  done
  echo "+> Done."
  exit 0
fi

# Force a pull of an image. We do this by: -
# - deleting any local copy
# - pulling the image
# - deleting the pulled image (if user used --no-keep)
echo "+> Hauling images..."
for i in ${FULL_IMAGE_LIST}
do
  echo "   ${i}"
  docker rmi "${i}" > /dev/null 2>&1 || true
  docker pull "${i}" > /dev/null 2>&1 || true
  # If the user's used '--no-haul' now remove the hauled image...
  if [[ ${NO_KEEP} == 1 ]]
  then
    docker rmi "${i}" > /dev/null 2>&1 || true
  fi
done

echo "+> Congratulations - u-hauled it all!"

echo "+> $(date)"
