#!/bin/env bash

echo "#define VERSION \"$(git describe --tags || git rev-parse --short HEAD)\"" > $(dirname $0)/../src/version.h
