#! /bin/bash

# Import the .env vars
if [ ! -e .env ]; then
	echo >&2 "Please configure the .env file"
    exit 1
fi
set -a
. ./.env
set +a

BACKUP_DIR=$1

# Validate the backup directory
if [ -z "${BACKUP_DIR}" ]; then
	echo "no backup directory given."
	exit 1
fi
if [ ! -d "${BACKUPS}/${BACKUP_DIR}" ]; then
	echo "backup directory ${BACKUPS}/${BACKUP_DIR} does not exist."
	exit 1
fi

# Restore the Jellfin config
if [ -f ${BACKUPS}/${BACKUP_DIR}/${CONFIG_TAR} ]; then
	if [ ${BACKUP_EXISTING_CONFIG} == "1" ]; then
		if [ find ${BACKUPS}/old_config -mindepth 1 -maxdepth 1 | read ]; then
			echo "${BACKUPS}/old_config is not empty, removing legacy backup data..."
			rm -R ${BACKUPS}/old_config/*
		fi
		echo "backing up the existing config to ${BACKUPS}/old_config"
		sudo mv ${JELLYFIN_CONFIG_DIR}/* ${BACKUPS}/old_config/
	fi
	echo "restoring Jellyfin config from ${BACKUPS}/${BACKUP_DIR}/${CONFIG_TAR}"
	tar -zxvf ${BACKUPS}/${BACKUP_DIR}/${CONFIG_TAR} -C ${JELLYFIN_CONFIG_DIR}
fi

# Restore the Jellyfin media
if [ -f ${BACKUPS}/${BACKUP_DIR}/${MEDIA_TAR} ]; then
	if [ ${BACKUP_EXISTING_MEDIA} == "1" ]; then
		if [ find ${BACKUPS}/old_media -mindepth 1 -maxdepth 1 | read ]; then
			echo "${BACKUPS}/old_media is not empty, removing legacy backup data..."
			rm -R ${BACKUPS}/old_media/*
		fi
		echo "backing up the existing media to ${BACKUPS}/old_media"
		sudo mv ${JELLYFIN_MEDIA_DIR}/* ${BACKUPS}/old_media/
	fi
	echo "restoring Jellyfin media from ${BACKUPS}/${BACKUP_DIR}/${MEDIA_TAR}"
	tar -zxvf ${BACKUPS}/${BACKUP_DIR}/${MEDIA_TAR} -C ${JELLYFIN_DATA_DIR}
fi