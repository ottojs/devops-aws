
locals {
  os = {
    #############################
    ##### Amazon Linux 2023 #####
    #############################
    al2023 = {
      x86_64 = {
        # al2023-ami-2023.6.20250218.2-kernel-6.1-x86_64
        "us-east-1" = "ami-05b10e08d247fb927"
        "us-east-2" = "ami-0fc82f4dabc05670b"
      }
      arm64 = {
        # al2023-ami-2023.6.20250218.2-kernel-6.1-arm64
        "us-east-1" = "ami-0f37c4a1ba152af46"
        "us-east-2" = "ami-0d30ab9f2d2a4a63a"
      }
    }
  }
}
