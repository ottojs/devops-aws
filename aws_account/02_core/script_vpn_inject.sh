#!/usr/bin/env bash

# File Parameters
FILE_OVPN="./downloaded-client-config.ovpn";
FILE_KEY="./key.pem";
FILE_CERT="./cert.pem";

# Inject structure, then file contents
# Tested on BSD sed (macOS)
sed -i.bk "s#</ca>#</ca>\n<key>\n</key>\n<cert>\n</cert>#" "${FILE_OVPN}";
sed -i.bk "/<key>/r${FILE_KEY}" "${FILE_OVPN}";
sed -i.bk "/<cert>/r${FILE_CERT}" "${FILE_OVPN}";
rm "${FILE_OVPN}.bk" || echo "Backup file does not exist. Ignoring... (dont worry)";
