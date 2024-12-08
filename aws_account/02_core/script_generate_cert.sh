#!/usr/bin/env bash

openssl req -x509 -newkey rsa:2048 \
  -keyout key.pem \
  -out cert.pem \
  -sha256 -days 3650 -nodes \
  -subj "/C=US/ST=US/L=USA/O=Acme/OU=Security/CN=connect.example.com"
