#!/bin/bash

# Retrieve SSL Certificate in .der format (purpose: this format is suitable for computing sha fingerprint)
openssl s_client -showcerts -connect openweathermap.org:443 -servername openweathermap.org < /dev/null | openssl x509 -outform DER > cert.der

# Generate ECDSA key pair then store it in keypair.pem
#openssl ecparam -name prime256v1 -genkey | openssl pkcs8 -topk8 -v2 aes-128-cbc > keypair.pem

# Converts a server certificate stored in the cert.der file to SHA-256 fingerprint in binary form, encoded as Base64 and stored in fingerprint.txt
FINGERPRINT_BASE64=`openssl dgst -sha256 -binary < cert.der | openssl enc -base64 -A`

# Get certificate attribute (common name & expiration date)
COMMON_NAME=`openssl x509 -noout -subject -inform der -in cert.der | sed -n '/^subject/s/^.*CN = //p'`

EXPIRATION_TIME=`openssl x509 -noout -dates -inform der -in cert.der | grep notAfter | sed -e 's#notAfter=##'`

UNIXTIMESTAMP_EXPIRATION=`date -j -f "%b %d %H:%M:%S %Y %Z" "$EXPIRATION_TIME" "+%s"`

echo -n "$COMMON_NAME" > signature_base_string.txt
echo -n "&" >> signature_base_string.txt
echo -n "$UNIXTIMESTAMP_EXPIRATION" >> signature_base_string.txt
echo -n "&" >> signature_base_string.txt
echo -n "$FINGERPRINT_BASE64" >> signature_base_string.txt

# Sign the fingerprint from fingerprint.txt with the private key from the provided key pair file keypair.pem and stores the result signature as a Base64 encoded file sign.txt
# Signature Format: $COMMON_NAME + '&' + $UNIXTIMESTAMP_EXPIRATION + '&' + $FINGERPRINT
openssl dgst -sha256 -sign keypair.pem signature_base_string.txt > signature_raw.txt

SIGNATURE_BASE64=`openssl enc -base64 -A < signature_raw.txt`

echo "{" > fingerprints.json
echo "  \"fingerprints\": [" >> fingerprints.json
echo "    {" >> fingerprints.json
echo "      \"name\": \"$COMMON_NAME\"," >> fingerprints.json
echo "      \"fingerprint\": \"$FINGERPRINT_BASE64\"," >> fingerprints.json
echo "      \"expirationDate\": $UNIXTIMESTAMP_EXPIRATION," >> fingerprints.json
echo "      \"signature\": \"$SIGNATURE_BASE64\"" >> fingerprints.json
echo "    }" >> fingerprints.json
echo "  ]" >> fingerprints.json
echo "}" >> fingerprints.json

