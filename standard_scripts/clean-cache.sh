#!/usr/bin/env bash

# Limpa o cache da memória

sync ; echo 3 > /proc/sys/vm/drop_caches
