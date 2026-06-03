NOTEBOOKS := git-collaboration peer-review

.PHONY: all slides clean $(NOTEBOOKS)

all: slides

slides: $(NOTEBOOKS)

$(NOTEBOOKS):
	jupyter nbconvert --to slides $@/talk.ipynb --output index --output-dir=$@

clean:
	rm -f git-collaboration/index.slides.html peer-review/index.slides.html
