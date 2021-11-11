## Constant files and folders
TEXFILE        :=MeineRezepte
SRCDIR         :=doc
IMGDIR         :=pics
SMALLIMGPREFIX :=mobile
WEBIMGPREFIX   :=web
SMALLIMGDIR    :=$(SMALLIMGPREFIX)/$(IMGDIR)
WEBIMGDIR      :=$(WEBIMGPREFIX)/$(IMGDIR)
TMPFILEENDINGS :=*.aux *.bbl *.fdb_latexmk *.fls *.glg *.glo *.gls *.idx *.ilg *.ind *.ist *.log *.lol *.out *.synctex.gz
SUBDIRTMPFILES :=$(foreach dir,$(wildcard $(SRCDIR)/*/),$(addprefix $(dir),$(TMPFILEENDINGS)))

# Image parameters (in pixels)
IMAGEHEIGHT    :=560

# Programs and arguments
LATEXMK        :=latexmk
LATEXMKARGS    :=-pdf
CONVERT        :=convert
CONVERTARGS    :=-strip -colorspace sRGB -filter Lanczos -adaptive-sharpen 0x0.6 -quality 70
JPEGARGS       :=-resize x$(IMAGEHEIGHT)\> -sampling-factor 4:2:0 -interlace JPEG
WEBPARGSLARGE  :=-resize 1280x720^ -gravity Center -extent 1280x720
WEBPARGSBIG    :=-resize 1080x608^ -gravity Center -extent 1080x608
WEBPARGSMEDIUM :=-resize 960x540^ -gravity Center -extent 960x540
WEBPARGSSMALL  :=-resize 720x400^ -gravity Center -extent 720x400

# Image files and down-scaled versions
SOURCEIMGS     :=$(foreach dir,$(IMGDIR), $(wildcard $(dir)/*.jpg))
TARGETIMGS     :=$(addprefix $(SMALLIMGPREFIX)/, $(SOURCEIMGS))
WEBDIRLARGE    :=$(WEBIMGPREFIX)/w1280
WEBDIRBIG      :=$(WEBIMGPREFIX)/w1080
WEBDIRMEDIUM   :=$(WEBIMGPREFIX)/w960
WEBDIRSMALL    :=$(WEBIMGPREFIX)/w720
WEBIMGSLARGE   :=$(addprefix $(WEBDIRLARGE)/, $(notdir $(SOURCEIMGS:.jpg=.webp)))
WEBIMGSBIG     :=$(addprefix $(WEBDIRBIG)/, $(notdir $(SOURCEIMGS:.jpg=.webp)))
WEBIMGSMEDIUM  :=$(addprefix $(WEBDIRMEDIUM)/, $(notdir $(SOURCEIMGS:.jpg=.webp)))
WEBIMGSSMALL   :=$(addprefix $(WEBDIRSMALL)/, $(notdir $(SOURCEIMGS:.jpg=.webp)))

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

webpimages: $(WEBIMGSLARGE) $(WEBIMGSBIG) $(WEBIMGSMEDIUM) $(WEBIMGSSMALL)


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
	$(CONVERT) $< $(CONVERTARGS) $(JPEGARGS) $@

# Scale down images for web use
$(WEBDIRLARGE)/%.webp: $(IMGDIR)/%.jpg $(WEBDIRLARGE)/.dirstamp
	$(CONVERT) $< $(CONVERTARGS) $(WEBPARGSLARGE) $@

$(WEBDIRBIG)/%.webp: $(IMGDIR)/%.jpg $(WEBDIRBIG)/.dirstamp
	$(CONVERT) $< $(CONVERTARGS) $(WEBPARGSBIG) $@

$(WEBDIRMEDIUM)/%.webp: $(IMGDIR)/%.jpg $(WEBDIRMEDIUM)/.dirstamp
	$(CONVERT) $< $(CONVERTARGS) $(WEBPARGSMEDIUM) $@

$(WEBDIRSMALL)/%.webp: $(IMGDIR)/%.jpg $(WEBDIRSMALL)/.dirstamp
	$(CONVERT) $< $(CONVERTARGS) $(WEBPARGSSMALL) $@

# Helper to test if image directory is created
$(SMALLIMGDIR)/.dirstamp:
	@mkdir --parents $(SMALLIMGDIR) && touch $@

$(WEBDIRLARGE)/.dirstamp:
	@mkdir --parents $(WEBDIRLARGE) && touch $@

$(WEBDIRBIG)/.dirstamp:
	@mkdir --parents $(WEBDIRBIG) && touch $@

$(WEBDIRMEDIUM)/.dirstamp:
	@mkdir --parents $(WEBDIRMEDIUM) && touch $@

$(WEBDIRSMALL)/.dirstamp:
	@mkdir --parents $(WEBIMGSSMALL) && touch $@

# Retrieve the date from the commit's hash
git-commit-time.tex: .git
	@git rev-parse HEAD | git show -s --format=%ct | awk '{print "@"$$1}' | date -f - +'%d. %b %Y' >$@

.PHONY: all main mobile webpimages clean cleanup numberOfRecipes

all: main mobile webpimages

clean:
	latexmk -c
	rm -f git-commit-time.tex $(TMPFILEENDINGS)
	rm -f $(SUBDIRTMPFILES)

cleanup: clean
	latexmk -C
	rm -f *.pdf doc/*/*.pdf
	rm -rf $(SMALLIMGPREFIX)
	rm -rf $(WEBIMGPREFIX)

numberOfRecipes:
	@echo "$(SUBSRC)" | wc -w
