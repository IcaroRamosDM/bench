.DEFAULT_GOAL := help

include mk/config.mk
include mk/dart.mk
include mk/quality.mk

.PHONY: help

help:
	@printf '%s\n' \
		'make help		Show available commands' \
		'make run		Run Bench' \
		'make build		Compile the executable' \
		'make clean		Remove generated executable files' \
		'make format		Format Dart source files' \
		'make analyze		Analyze Dart source files' \
		'make check-format	Check Dart formatting' \
		'make check		Run all quality checks' \
		'make test		Run automated tests'
