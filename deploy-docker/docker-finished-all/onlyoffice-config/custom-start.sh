#!/bin/bash

# Fix substring expression error on line 259
# Original script has: if [[ ${ERR} != "" ]] && [[ ${ERR: -3} == "127" ]]; then
# Fix to: if [[ ${ERR} != "" ]] && [[ ${ERR: -3} == "127" ]] 2>/dev/null; then

# Override problematic script section
mkdir -p /tmp/fix
cp /app/ds/run-document-server.sh /tmp/fix/

sed -i "259s/if \[\[ \${ERR} != \"\" \]\] && \[\[ \${ERR: -3} == \"127\" \]\]; then/if \[\[ \${ERR} != \"\" \]\] && \[\[ \${ERR: -3} == \"127\" \]\] 2>\/dev\/null; then/" /tmp/fix/run-document-server.sh

chmod +x /tmp/fix/run-document-server.sh

# Start OnlyOffice with fixed script
JWT_ENABLED=true /tmp/fix/run-document-server.sh
