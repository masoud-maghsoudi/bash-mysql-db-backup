#!/bin/bash

################################################################
#
#   Using cron jobs this script helps to automate
#   the database backup procedure for MySQL database server
#   and its forks like MariaDB.
#
#   Author: Masoud Maghsoudi
#   Github: https://github.com/masoud-maghsoudi
#   Email:  masoud_maghsoudi@yahoo.com
#
################################################################

export PATH=/bin:/usr/bin:/usr/local/bin
TODAY=$(date +"%d%b%Y")
TIME=$(date +"%T")
DB_BACKUP_PATH='/YOUR_PATH/dbbackup'
MYSQL_HOST='localhost'
MYSQL_PORT='3306'
MYSQL_USER='USER'
MYSQL_PASSWORD='PASSWORD'
BACKUP_RETAIN_DAYS=10
LOG_FILE=${DB_BACKUP_PATH}/${TODAY}/${TODAY}-dbbackup.log
declare -a database_names=("DB1" "DB2" "DB3")

#################################################################

mkdir -p ${DB_BACKUP_PATH}/${TODAY}
touch ${LOG_FILE}

for database in ${database_names[@]}; do
    TIME=$(date +"%T")
    echo ${TODAY}-${TIME}-"Backup started for Database \"${database}\""\  >>${LOG_FILE}

    mysqldump -h ${MYSQL_HOST} \
        -P ${MYSQL_PORT} \
        -u ${MYSQL_USER} \
        -p${MYSQL_PASSWORD} \
        ${database} | gzip >${DB_BACKUP_PATH}/${TODAY}/${database}-${TODAY}.sql.gz

    TIME=$(date +"%T")
    if [ $? -eq 0 ]; then
        echo ${TODAY}-${TIME}-"Database \"${database}\" backup successfully completed"\  >>${LOG_FILE}
    else
        echo ${TODAY}-${TIME}-"Error found during backup Database \"${database}\""\  >>${LOG_FILE}
        exit 1
    fi
done

##### Remove backups older than {BACKUP_RETAIN_DAYS} days  #####

DBDELDATE=$(date +"%d%b%Y" --date="${BACKUP_RETAIN_DAYS} days ago")

TIME=$(date +"%T")
if [ ! -z ${DB_BACKUP_PATH} ]; then
    cd ${DB_BACKUP_PATH}
    if [ ! -z ${DBDELDATE} ] && [ -d ${DBDELDATE} ]; then
        rm -rf ${DBDELDATE}
        echo ${TODAY}-${TIME}-"Old backup files from ${DBDELDATE} were deleted succesfully"\  >>${LOG_FILE}
    fi
fi
