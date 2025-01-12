
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
    al2023_250107 = {
      x86_64 = {
        # al2023-ami-2023.6.20250107.0-kernel-6.1-x86_64
        "us-east-1" = "ami-05576a079321f21f8"
        "us-east-2" = "ami-0d7ae6a161c5c4239"
      }
      arm64 = {
        # al2023-ami-2023.6.20250107.0-kernel-6.1-arm64
        "us-east-1" = "ami-03ecf97a3bb0705c2"
        "us-east-2" = "ami-0db575de70f37f380"
      }
    }
  }
}
