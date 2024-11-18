# Boilerplate DevOps AWS

## Overview
Example production-grade deployment in Amazon Web Services.
Use it as-is or as a reference for how the pieces fit together.

## Unstable Software
**WARNING** This is a work-in-progress and should not be used yet.

## Disclaimer
Using this software will incur costs on your AWS account. You are solely responsible for your use of this code (monitoring costs, adjusting settings, paying invoices, etc).

## Instructions
- Ensure you have AWS configured (`aws configure`)
- Run `tofu init -upgrade`
- Edit `variables.tf`
- Run `./script_generate_cert.sh`
- Run `tofu apply`
