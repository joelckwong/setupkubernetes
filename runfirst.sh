#!/bin/bash
echo "$LOGNAME ALL=(ALL) NOPASSWD: ALL" | sudo tee -a /etc/sudoers
