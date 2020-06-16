#!/usr/bin/env bash

sudo growpart /dev/nvme0n1 1
sudo xfs_growfs /dev/nvme0n1p1
