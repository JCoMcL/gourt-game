tiles-layout.png: tilelist
	tiletemptool $@ < $<
watch:
	$(MAKE)
	inotifywait --event modify . && $(MAKE) watch
