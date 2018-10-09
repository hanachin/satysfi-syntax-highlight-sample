.PHONY: all
all: sample.pdf

.PHONY: clean
clean:
	rm -f sample.saty sample.satysfi-aux

sample.saty: sample.saty.erb
	bundle exec erb -r $(PWD)/highlight.rb sample.saty.erb > sample.saty

sample.pdf: sample.saty
	satysfi -b sample.saty
