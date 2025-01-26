
locals {
  os = {
    #############################
    ##### Amazon Linux 2023 #####
    #############################
    al2023_250123 = {
      x86_64 = {
        # al2023-ami-2023.6.20250123.4-kernel-6.1-x86_64
        "us-east-1" = "ami-0ac4dfaf1c5c0cce9"
        "us-east-2" = "ami-0eb070c40e6a142a3"
      }
      arm64 = {
        # al2023-ami-2023.6.20250123.4-kernel-6.1-arm64
        "us-east-1" = "ami-00d9a6d7d54864374"
        "us-east-2" = "ami-019e73f4c35a3c699"
      }
    }
  }
}
