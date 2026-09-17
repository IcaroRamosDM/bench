.PHONY: run build clean

run:
	$(DART) run "$(ENTRY)" $(RUN_FLAGS) -- "$(INPUT)"

build:	check
	mkdir -p "$(BUILD_DIR)"
	$(DART) compile exe "$(ENTRY)" -o "$(BINARY).tmp"
	mv -fT -- "$(BINARY).tmp" "$(BINARY)"

clean:
	rm -f -- "$(BINARY)" "$(BINARY).tmp"
