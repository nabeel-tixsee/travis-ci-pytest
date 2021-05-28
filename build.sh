#!/usr/bin/env bash
./terraform-linux init
./terraform-linux validate 
./terraform-linux plan
./terraform-linux apply -auto-approve