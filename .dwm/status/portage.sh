#!/bin/bash

echo "$(eix-diff | grep -c "\[U\]") updates"
