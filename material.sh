#!/usr/bin/env bash

make
gzdoom -iwad doom2 -file build/material.pk3 -warp 1 "$@"
