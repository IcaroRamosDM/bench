.PHONY: format check-format analyze test check

format:
	$(DART) format bin lib test

check-format:
	$(DART) format --output=none --set-exit-if-changed bin lib test

analyze:
	$(DART) analyze --fatal-infos

test:
	$(DART) test

check: check-format analyze test
