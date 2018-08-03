#!/usr/bin/env bash
APP_DIR=${PWD}
TMP_DIR=${APP_DIR}/wp-work
VERSION=$1
TARGET_BASE_DIR=$2
LANG=$3
URL=https://ja.wordpress.org/wordpress-${VERSION}.zip
if [ -n "${LANG}" ]; then
    URL=https://${LANG}.wordpress.org/wordpress-${VERSION}-${LANG}.zip
fi
ZIP_FILE_NAME=$(basename ${URL})
FILE_NAME=$(basename ${URL%.*})

#echo ${APP_DIR}
#echo ${TMP_DIR}

if [ -e ${TMP_DIR} ]; then
    echo "${TMP_DIR} is exist."
else
    mkdir -p ${TMP_DIR}
fi

if [ ! -e ${TARGET_BASE_DIR} ]; then
    echo "${TARGET_BASE_DIR} does not exist."
    exit 1
fi

echo "Downloading ${URL}"
RES=$(wget --spider -nv --timeout 60 -t 1 ${URL} 2>&1 | grep -c '200 OK')
#echo ${RES}

if [ ${RES} -eq 0 ]; then
    echo "${URL} does not exist."
    exit 1
fi

if [ ! -e "${TMP_DIR}/${ZIP_FILE_NAME}" ]; then
    wget ${URL} -P ${TMP_DIR}
fi
if [ -e "${TMP_DIR}/${FILE_NAME}" ]; then
    rm -rf "${TMP_DIR}/${FILE_NAME}"
fi

unzip ${TMP_DIR}/${ZIP_FILE_NAME} -d ${TMP_DIR}/${FILE_NAME}
WP_DIR=${TMP_DIR}/${FILE_NAME}/wordpress
echo ${WP_DIR}
echo ${TARGET_BASE_DIR}

if [ -d ${TARGET_BASE_DIR}/wp-admin ]; then
    rm -rf ${TARGET_BASE_DIR}/wp-admin
fi

if [ -d ${TARGET_BASE_DIR}/wp-includes ]; then
    rm -rf ${TARGET_BASE_DIR}/wp-includes
fi

cp -R ${WP_DIR}/wp-admin ${TARGET_BASE_DIR}/wp-admin
cp -R ${WP_DIR}/wp-includes ${TARGET_BASE_DIR}/wp-includes
cp -R ${WP_DIR}/wp-content ${TARGET_BASE_DIR}/.
find ${WP_DIR} -maxdepth 1 -type f | while read line
do
  TARGET_PATH=${TARGET_BASE_DIR}/$(basename ${line})
  cp ${line} ${TARGET_PATH}
done
