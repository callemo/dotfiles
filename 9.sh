#!/bin/sh

cd() { command cd "$@" && awd "$sysname"; }
