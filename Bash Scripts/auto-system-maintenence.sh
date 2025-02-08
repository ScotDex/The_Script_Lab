#!/bin/bash -x

# Copyright (C) 2022 ScotDex <themadlyscientific@gmail.com>

# This file is free software; as a special exception the author gives
# unlimited permission to copy and/or distribute it, with or without
# modifications, as long as this notice is preserved.

# Run the command - journalctl --disk-usage

# This will tell you how much space the journal logs are taking up, the following script is designed to make the logs 
# run more efficiently and not take up too much space.

# Based on the ubuntu distribution

##################

sudo journalctl --rotate                       #all currently active journal files are marked as archived and renamed, so that they are never written to in future.
sudo journalctl --vacuum-time=2days            #retains logs from the past 2 days only (adjustable)
sudo journalctl --vacuum-size=100M             #limits the space the log takes up to 100mb (again adjustable)
sudo systemctl daemon-reload                   #reloads the deamon

##################

Run the script by enterting the command ./logclean

Dex
