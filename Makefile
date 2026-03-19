.PHONY: README.md
README.md:
	sed -i '/# See Also/q' $@
	find -mindepth 2 -name '*.md' | awk -F '/' '{printf "[%s/%s](%s)\n\n",$$(NF-1), $$NF, $$0 }' >> $@
	grep -RIP '#(TODO|WARN|FIX|BM)' . | sed -E 's/\t+//' | awk -F: '{f=$$1;$$1="";printf "[`%s`](%s)\n\n", $$0, f}' >> $@

%_atlas.png: %_0000.png %_0001.png %_0002.png
	montage $^ -tile $(words $^)x1 -background transparent -geometry +0+0 $@
