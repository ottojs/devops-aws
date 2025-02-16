
locals {
  os = {
    #############################
    ##### Amazon Linux 2023 #####
    #############################
    al2023_250211 = {
      x86_64 = {
        # al2023-ami-2023.6.20250211.0-kernel-6.1-x86_64
        "us-east-1" = "ami-053a45fff0a704a47"
        "us-east-2" = "ami-0604f27d956d83a4d"
      }
      arm64 = {
        # al2023-ami-2023.6.20250211.0-kernel-6.1-arm64
        "us-east-1" = "ami-0c518311db5640eff"
        "us-east-2" = "ami-08ef92cd73f7c76ee"
      }
    }
  }
}
