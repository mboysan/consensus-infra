terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "2.16.0"
    }
  }
}

provider "docker" {}

# YCSB setup

resource "docker_image" "ubuntu-ssh" {
  name = "ubuntu:latest"
  build {
    path = "."
    tag  = ["ubuntu-ssh:latest"]
    dockerfile = "ubuntu_ssh.dockerfile"
  }
}

resource "docker_container" "ycsb" {
  image = docker_image.ubuntu-ssh.latest
  name  = "ycsb"
  ports {
    # ssh
    internal = 22
  }
  command = [
    "tail",
    "-f",
    "/dev/null"
  ]
}

# commander node (ansible setup)

resource "docker_container" "commander" {
  image = docker_image.ubuntu-ssh.latest
  name  = "commander"
  ports {
    # ssh
    internal = 22
  }
  command = [
    "tail",
    "-f",
    "/dev/null"
  ]
}
