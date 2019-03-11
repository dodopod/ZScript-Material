#!/usr/bin/env bash

make build/material.pk3
make build/test.pk3
gzdoom -iwad doom2 -file build/material.pk3 build/test.pk3 -warp 1 "$@"
