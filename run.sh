#!/bin/bash
CD=$(dirname $(readlink -f $BASH_SOURCE))
cd $CD
source $CD/env.sh

echo $vglrun "$@"
$vglrun "$@"
