#!/bin/bash -x

# This file is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.

# This script is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License for more details.

# You should have received a copy of the GNU General Public License
# along with this script. If not, see <http://www.gnu.org/licenses/>.

# This script performs various system maintenance tasks to clean up logs, remove unnecessary packages, and update the system.
# It is based on the Ubuntu distribution and is intended for command line use.

# Check disk usage of journal logs
journalctl --disk-usage

# Rotate journal logs
sudo journalctl --rotate

# Retain logs from the past 2 days only
sudo journalctl --vacuum-time=2days

# Limit the space the log takes up to 100MB
sudo journalctl --vacuum-size=100M

# Reload the systemd daemon
sudo systemctl daemon-reload

# Display disk usage in human-readable format
df -h

# Remove packages that are no longer needed
sudo apt-get autoremove

# Clean the apt-get cache
sudo apt-get clean

# Purge old kernels that are no longer in use
sudo apt-get autoremove --purge

# Delete all .deb files from /var/cache/apt/archives
sudo apt-get autoclean

# Update the package list
sudo apt-get update

# Upgrade all packages to the latest versions
sudo apt-get upgrade

# Note: You can use 'sudo apt-mark hold <package name>' to prevent a specific package from being upgraded.

# Reboot the system to apply all changes
sudo reboot