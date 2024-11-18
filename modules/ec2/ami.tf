
locals {
  os = {
    #############################
    ##### Amazon Linux 2023 #####
    #############################
    al2023_241111 = {
      x86_64 = {
        # al2023-ami-2023.6.20241111.0-kernel-6.1-x86_64
        "us-east-1" = "ami-012967cc5a8c9f891"
        "us-east-2" = "ami-0942ecd5d85baa812"
      }
      arm64 = {
        # al2023-ami-2023.6.20241111.0-kernel-6.1-arm64
        "us-east-1" = "ami-055e62b4ea2fe95fd"
        "us-east-2" = "ami-0a7c06753900acc19"
      }
    }
  }
}
