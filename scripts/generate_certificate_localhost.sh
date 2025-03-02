#!/usr/bin/env bash

# Generate Self-Signed Certificate
# Use one of these for each internal applications behind
# a load balancers to have E2E TLS encryption in transit
# You can store this in Secrets Manager and pass as a secret
# 7300 days = 20 years
openssl req -x509 \
  -newkey rsa:4096 \
  -keyout localhost.key \
  -out localhost.crt \
  -sha256 -nodes \
  -days 7300 \
  -subj '/CN=localhost';
