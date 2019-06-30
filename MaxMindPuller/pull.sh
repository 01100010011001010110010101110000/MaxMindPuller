#!/bin/bash -e

# Generate a configuration file if it does not exist
if [[ ! -f "${GEOIP_CONFIG_FILE:-/opt/geoip/GeoIP.conf}" ]]; then
    GEOIP_CONFIG_FILE="/${UPDATER_ROOT:-"/opt/geoip"}/GeoIP.conf"
    # If we have to create the config, ensure its location is available as an environment variable
    export GEOIP_CONFIG_FILE
    echo "AccountID ${GEOIP_ACCOUNT_ID:-"0"}" >> $GEOIP_CONFIG_FILE
    echo "LicenseKey ${GEOIP_LICENSE_KEY:-"000000000000"}" >> $GEOIP_CONFIG_FILE
    echo "EditionIDs ${GEOIP_PRODUCT_IDS:-"GeoLite2-City"}" >> $GEOIP_CONFIG_FILE
    echo "DatabaseDirectory ${GEOIP_DIRECTORY:-"/opt/geoip/databases"}" >> $GEOIP_CONFIG_FILE
fi

# Run the update program if initialize only is false or if it's true and the databsase directory is empty
if [[ ${INITIALIZE_ONLY} = true && -z $(ls -A ${GEOIP_DIRECTORY}) ]]; then
    ${UPDATER_ROOT}/geoipupdate -f "${GEOIP_CONFIG_FILE}" -v
elif [[ ${INITIALIZE_ONLY} = false ]]; then
    ${UPDATER_ROOT}/geoipupdate -f "${GEOIP_CONFIG_FILE}" -v
fi
