
locals {
  os = {
    #############################
    ##### Amazon Linux 2023 #####
    #############################
    al2023_250203 = {
      x86_64 = {
        # al2023-ami-2023.6.20250203.1-kernel-6.1-x86_64
        "us-east-1" = "ami-085ad6ae776d8f09c"
        "us-east-2" = "ami-088b41ffb0933423f"
      }
      arm64 = {
        # al2023-ami-2023.6.20250203.1-kernel-6.1-arm64
        "us-east-1" = "ami-0e532fbed6ef00604"
        "us-east-2" = "ami-0ab3ecd54bbd1565f"
      }
    }
  }
}
