#!/bin/bash

echo "Enable hibernation..."
sudo systemctl unmask sleep.target suspend.target hibernate.target hybrid-sleep.target