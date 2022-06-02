#!/bin/bash
CD=$(dirname $(readlink -f $BASH_SOURCE))
cd $CD
$CD/run.sh python3  "$@"
