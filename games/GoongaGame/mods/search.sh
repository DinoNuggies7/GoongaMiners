#!/bin/bash

grep -rnw "./" -e "mcl_$1" | grep "mod.conf"