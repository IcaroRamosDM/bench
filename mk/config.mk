DART ?= dart
INPUT ?= examples/nine_points.json

ENTRY := bin/bench.dart
BUILD_DIR := build
BINARY := $(BUILD_DIR)/bench

ifeq ($(strip $(DART)),)
$(error DART must not be empty)
endif
