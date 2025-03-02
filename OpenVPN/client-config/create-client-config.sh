#!/bin/bash 

KEYS_DIR='../openvpn-ca/pki'
BASE_FILE='./base-client.conf'

CLIENT=${1}

if [ "$CLIENT" == '' ]; then
    echo 'No client name provided'
    exit 1
fi

if [ ! -f "${BASE_FILE}" ];
then
	echo "No Base Config file found -> ${BASE_FILE}"
	exit 1
fi


CA="${KEYS_DIR}/ca.crt"
CERT="${KEYS_DIR}/issued/${CLIENT}.crt"
KEY="${KEYS_DIR}/private/${CLIENT}.key"
TA="${KEYS_DIR}/ta.key"

if [ ! -f "${CA}" ];
then
	echo "[ERROR]"
	echo "Provided CA path does not exist -> ${CA}"
	exit 1
fi

if [ ! -f "${CERT}" ];
then
	echo "[ERROR]"
	echo "Provided Certiicate path does not exist -> ${CERT}"
	exit 1
fi

if [ ! -f "${KEY}" ];
then
	echo "[ERROR]"
	echo "Provided Key path does not exist -> ${KEY}"
	exit 1
fi

if [ ! -f "${TA}" ];
then
        echo "[ERROR]"
        echo "Provided TA path does not exist -> ${TA}"
        exit 1
fi

echo "$(cat ${BASE_FILE})" > "${CLIENT}.conf"

echo '<ca>' >> "${CLIENT}.conf"
echo "$(cat ${CA})" >> "${CLIENT}.conf" 
echo '</ca>' >> "${CLIENT}.conf" 

echo '<cert>' >> "${CLIENT}.conf"
echo "$(cat ${CERT})" >> "${CLIENT}.conf"
echo '</cert>' >> "${CLIENT}.conf" 

echo '<key>' >> "${CLIENT}.conf"
echo "$(cat ${KEY})" >> "${CLIENT}.conf"
echo '</key>' >> "${CLIENT}.conf"

echo '<tls-auth>' >> "${CLIENT}.conf"
echo "$(cat ${TA})" >> "${CLIENT}.conf"
echo '</tls-auth>' >> "${CLIENT}.conf"

echo "The Client config file saved as -> ${CLIENT}.conf"









