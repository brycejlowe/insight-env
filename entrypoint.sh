#!/bin/bash

# remove the pre-existing custom configuration
rm -rf /etc/httpd/conf.d/site-*.conf

# set the application environment
APACHE_SITE_PATH="/etc/httpd/conf.d/site-config.conf"
cp /etc/httpd.custom/$(basename ${APACHE_SITE_PATH}) ${APACHE_SITE_PATH}
sed -i "s,@APP_ENV,${APP_ENV},g" ${APACHE_SITE_PATH}
sed -i "s,@APACHE_SERVER_NAME,${APACHE_SERVER_NAME},g" ${APACHE_SITE_PATH}

# set the debug level in php.ini
PHP_INI_PATH="/etc/php.ini"
PHP_DISPLAY_ERRORS="display_errors = Off"
PHP_DISPLAY_STARTUP_ERRORS="display_startup_errors = 0"
if [[ "${APP_ENV}" == "development" ]]; then
    PHP_DISPLAY_ERRORS="display_errors = E_ALL"
    PHP_DISPLAY_STARTUP_ERRORS="display_startup_errors = 1"
fi
sed -i "s,display_errors\s=.*,${PHP_DISPLAY_ERRORS},g" ${PHP_INI_PATH}
sed -i "s,display_startup_errors\s=.*,${PHP_DISPLAY_STARTUP_ERRORS},g" ${PHP_INI_PATH}

# remove custom configuration
rm -rf /etc/php.d/*-custom.ini

# setup xdebug configuration
XDEBUG_INI_PATH="/etc/php.d/99-xdebug-custom.ini"
if [[ "${XDEBUG_REMOTE_ENABLE}" == "1" || "${XDEBUG_PROFILE_ENABLE_TRIGGER}" == "1" ]]; then
    # copy the files in
    cp /etc/php.custom/$(basename ${XDEBUG_INI_PATH}) ${XDEBUG_INI_PATH}

    # make changes to the template based on the environment variables
    sed -i "s,@XDEBUG_REMOTE_ENABLE,${XDEBUG_REMOTE_ENABLE},g" ${XDEBUG_INI_PATH}
    sed -i "s,@XDEBUG_REMOTE_HANDLER,${XDEBUG_REMOTE_HANDLER},g" ${XDEBUG_INI_PATH}
    sed -i "s,@XDEBUG_REMOTE_IP,${XDEBUG_REMOTE_IP},g" ${XDEBUG_INI_PATH}
    sed -i "s,@XDEBUG_REMOTE_PORT,${XDEBUG_REMOTE_PORT},g" ${XDEBUG_INI_PATH}
    sed -i "s,@XDEBUG_IDE_KEY,${XDEBUG_IDE_KEY},g" ${XDEBUG_INI_PATH}
    sed -i "s,@XDEBUG_REMOTE_AUTOSTART,${XDEBUG_REMOTE_AUTOSTART},g" ${XDEBUG_INI_PATH}
    
    # enables xdebug logging
    XDEBUG_LOG_STRING=""
    if [[ -n "${XDEBUG_LOG_PATH}" ]]; then
        XDEBUG_LOG_STRING="xdebug.remote_log = ${XDEBUG_LOG_PATH}"
    fi
    sed -i "s,@XDEBUG_LOG_PATH,${XDEBUG_LOG_STRING},g" ${XDEBUG_INI_PATH}

    sed -i "s,@XDEBUG_PROFILE_ENABLE_TRIGGER,${XDEBUG_PROFILE_ENABLE_TRIGGER},g" ${XDEBUG_INI_PATH}
    sed -i "s,@XDEBUG_PROFILE_TRIGGER_VALUE,${XDEBUG_PROFILE_TRIGGER_VALUE},g" ${XDEBUG_INI_PATH}
    sed -i "s,@XDEBUG_PROFILE_OUTPUT_DIR,${XDEBUG_PROFILE_OUTPUT_DIR},g" ${XDEBUG_INI_PATH}
    sed -i "s,@XDEBUG_PROFILE_OUTPUT_NAME,${XDEBUG_PROFILE_OUTPUT_NAME},g" ${XDEBUG_INI_PATH}
fi

# run the command specified by the user or the dockerfile
exec "$@"