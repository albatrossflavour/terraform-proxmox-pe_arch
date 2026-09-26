terraform {
  required_version = ">= 1.5"

  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = "0.114.0"
    }
    hiera5 = {
      source  = "chriskuchin/hiera5"
      version = "0.5.4"
    }
    random = {
      source  = "hashicorp/random"
      version = "3.9.1"
    }
  }
}
