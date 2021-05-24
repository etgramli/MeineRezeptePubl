## Constant files and folders
TEXFILE        :=MeineRezepte
SRCDIR         :=doc
IMGDIR         :=pics
SMALLIMGPREFIX :=mobile
SMALLIMGDIR    :=$(SMALLIMGPREFIX)/$(IMGDIR)
TMPFILEENDINGS :=*.aux *.bbl *.fdb_latexmk *.fls *.glg *.glo *.gls *.idx *.ilg *.ind *.ist *.log *.lol *.out *.synctex.gz
SUBDIRTMPFILES :=$(foreach dir,$(wildcard $(SRCDIR)/*/),$(addprefix $(dir),$(TMPFILEENDINGS)))

# Image parameters (height in pixels, size in kb)
IMAGEHEIGHT    :=560

# Programs and arguments
LATEXMK        :=latexmk
LATEXMKARGS    :=-pdf
CONVERT        :=convert
CONVERTARGS    :=-strip -colorspace sRGB -sampling-factor 4:2:0 -filter Lanczos -resize x$(IMAGEHEIGHT)\> -adaptive-sharpen 0x0.6 -interlace JPEG -quality 85

# Image files and down-scaled versions
SOURCEIMGS     :=$(foreach dir,$(IMGDIR), $(wildcard $(dir)/*.jpg))
TARGETIMGS     :=$(addprefix $(SMALLIMGPREFIX)/, $(SOURCEIMGS))

# Targets, used for creating single recipes and autocompletion
SUBSRC         :=$(wildcard $(SRCDIR)/*/*.tex)
SUBTARGETS     :=$(SUBSRC:.tex=.pdf)

# (La)TeX souce files
PACKAGES       :=recipe_book.sty xcookybooky.sty
SOURCES        :=$(TEXFILE).tex $(SUBSRC)


## Targets
# Generates pdf with original images (printing) and down-scaled images (mobile usage)
main:   $(TEXFILE).pdf
mobile: $(TEXFILE)-mobile.pdf


# Implicit pdf rule for PDFs
%.pdf: %.tex
	$(LATEXMK) $(LATEXMKARGS) $<

# Specific rule for normal pdf with full size images as dependencies
$(TEXFILE).pdf: $(SOURCES) $(PACKAGES) $(SOURCEIMGS) git-commit-time.tex

# Specific rule for mobile pdf with down-scaled images as dependencies
$(TEXFILE)-mobile.pdf: $(SOURCES) $(PACKAGES) $(TARGETIMGS) $(SMALLIMGDIR)/Gsicht.png git-commit-time.tex

# Funny image for left side of header
$(SMALLIMGDIR)/Gsicht.png: $(IMGDIR)/Gsicht.png $(SMALLIMGDIR)/.dirstamp
	@cp $(IMGDIR)/Gsicht.png $(SMALLIMGDIR)

# Scale down images for mobile use
$(SMALLIMGDIR)/%.jpg: $(IMGDIR)/%.jpg $(SMALLIMGDIR)/.dirstamp
	$(CONVERT) $< $(CONVERTARGS) $@

# Helper to test if image directory is created
$(SMALLIMGDIR)/.dirstamp:
	@mkdir --parents $(SMALLIMGDIR) && touch $@

# Retrieve the date from the commit's hash
git-commit-time.tex: .git
	@git rev-parse HEAD | git show -s --format=%ct | awk '{print "@"$$1}' | date -f - +'%d. %b %Y' >$@

.PHONY: all main mobile clean cleanup numberOfRecipes

all: mobile main

clean:
	latexmk -c
	rm -f git-commit-time.tex $(TMPFILEENDINGS)
	rm -f $(SUBDIRTMPFILES)

cleanup: clean
	latexmk -C
	rm -f *.pdf doc/*/*.pdf
	rm -rf $(SMALLIMGPREFIX)

numberOfRecipes:
	@echo "$(SUBSRC)" | wc -w
