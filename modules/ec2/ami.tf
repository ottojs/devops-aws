
locals {
  os = {
    #############################
    ##### Amazon Linux 2023 #####
    #############################
    al2023_250128 = {
      x86_64 = {
        # al2023-ami-2023.6.20250128.0-kernel-6.1-x86_64
        "us-east-1" = "ami-0c614dee691cbbf37"
        "us-east-2" = "ami-018875e7376831abe"
      }
      arm64 = {
        # al2023-ami-2023.6.20250123.4-kernel-6.1-arm64
        "us-east-1" = "ami-0b29c89c15cfb8a6d"
        "us-east-2" = "ami-031bb1452a43b486d"
      }
    }
  }
}
