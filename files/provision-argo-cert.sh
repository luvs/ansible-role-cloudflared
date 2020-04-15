#!/bin/bash
set -euo pipefail
IFS=$'\n\t'

ORIGIN_CA_KEY="${CLOUDFLARE_ORIGIN_CA_KEY:-$1}"
CF_API_KEY="${CLOUDFLARE_AUTH_KEY:-$2}"
CF_EMAIL="${CLOUDFLARE_AUTH_EMAIL:-$3}"
TUNNEL_ZONE_ID="${CLOUDFLARE_ZONE_ID:-$4}"
TUNNEL_HOSTNAMES="${TUNNEL_HOSTNAMES:-$5}"
OUTPUT_FILE="${OUTPUT_FILE:-$6}"
DEBUG="${DEBUG:-}"

## tmp dir
tmpbase=/tmp/${0##*/}
find ${tmpbase}* -type f -exec shred -uxz {} ';' || true
rm -rf ${tmpbase}*
TMPDIR="`mktemp -d ${tmpbase}-XXXXXX`"

curl -s https://api.cloudflare.com/client/v4/user/service_keys/origintunnel \
  -H "x-auth-key: $CF_API_KEY" \
  -H "x-auth-email: $CF_EMAIL" \
  | jq -r .result.service_key \
  > $TMPDIR/tunnel_service_key.txt

# generate private key
openssl ecparam -name prime256v1 -out $TMPDIR/tunnel_private_key_params.txt
openssl req -batch -new \
        -newkey ec:$TMPDIR/tunnel_private_key_params.txt \
        -nodes -out ${TMPDIR}/csr.txt \
        -keyout ${TMPDIR}/tunnel_private_key.txt \
        -subj "/C=US/CN=CloudFlare"

# make cert.pem, containing
# 1. Private key (in PKCS #8 format)
openssl pkcs8 -topk8 \
        -in ${TMPDIR}/tunnel_private_key.txt \
        -nocrypt -out "${OUTPUT_FILE}"

# 2. public key from originCA
curl -s -XPOST https://api.cloudflare.com/client/v4/certificates \
  -H "Content-Type: application/json" \
  -H "X-Auth-User-Service-Key: $ORIGIN_CA_KEY" \
  -d "$(jq -n --arg csr "$(cat ${TMPDIR}/csr.txt)" --argjson hostnames "$TUNNEL_HOSTNAMES" '{hostnames:$hostnames,requested_validity:5475,request_type:"origin-ecc",csr:$csr}')" \
  | jq -r .result.certificate \
  >> "${OUTPUT_FILE}"

# 3. Argo Tunnel token
echo "-----BEGIN ARGO TUNNEL TOKEN-----" >> "${OUTPUT_FILE}"
echo -n "$(echo $TUNNEL_ZONE_ID; cat ${TMPDIR}/tunnel_service_key.txt)" | \
        base64 | fold -w 64 >> "${OUTPUT_FILE}"
echo "-----END ARGO TUNNEL TOKEN-----" >> "${OUTPUT_FILE}"

if [ "x$DEBUG" == "x" ]; then
  find ${tmpbase}* -type f -exec shred -uxz {} ';' || true
fi
