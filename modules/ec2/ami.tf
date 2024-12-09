
locals {
  os = {
    #############################
    ##### Amazon Linux 2023 #####
    #############################
    al2023_241121 = {
      x86_64 = {
        # al2023-ami-2023.6.20241121.0-kernel-6.1-x86_64
        "us-east-1" = "ami-0453ec754f44f9a4a"
        "us-east-2" = "ami-0c80e2b6ccb9ad6d1"
      }
      arm64 = {
        # al2023-ami-2023.6.20241121.0-kernel-6.1-arm64
        "us-east-1" = "ami-0ed83e7a78a23014e"
        "us-east-2" = "ami-0a9f08a6603f3338e"
      }
    }
  }
}
