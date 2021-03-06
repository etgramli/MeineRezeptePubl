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
BIGIMAGESIZE   :=85
SMALLIMAGESIZE :=65

# Programs and arguments
LATEXMK        :=latexmk
LATEXMKARGS    :=-pdf
CONVERT        :=convert
CONVERTARGS    :=-strip -sampling-factor 4:2:0 -filter Lanczos -resize x$(IMAGEHEIGHT)\> -adaptive-sharpen 0x0.6

# Image files (left hand side - right hand side)
SOURCEIMGSBIG  :=$(foreach dir,$(IMGDIR), $(wildcard $(dir)/*_0.jpg))
SOURCEIMGSSMALL:=$(foreach dir,$(IMGDIR), $(wildcard $(dir)/*_1.jpg))
SOURCEIMGS     :=$(SOURCEIMGSBIG) $(SOURCEIMGSSMALL)

# Down-scaled versions of images
TARGETIMGSBIG  :=$(addprefix $(SMALLIMGPREFIX)/, $(SOURCEIMGSBIG))
TARGETIMGSSMALL:=$(addprefix $(SMALLIMGPREFIX)/, $(SOURCEIMGSSMALL))
TARGETIMGS     :=$(TARGETIMGSBIG) $(TARGETIMGSSMALL)

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

# Target for individual recipes
$(SUBTARGETS): %.pdf: %.tex $(TEXFILE).tex $(PACKAGES) $(SOURCEIMGS)
	cd $(dir $<); sed '5a\\\graphicspath{{pics/}{../../pics/}}' < $(notdir $<) > $(notdir $<)_temp.tex; $(LATEXMK) $(LATEXMKARGS) $(notdir $<)_temp.tex; rm $(notdir $<)_temp.tex
	@cp $(dir $@)/$(notdir $<)_temp.pdf ./$(notdir $@).pdf

# Specific rule for normal pdf with full size images as dependencies
$(TEXFILE).pdf: $(SOURCES) $(PACKAGES) $(SOURCEIMGS) git-commit-time.tex

# Specific rule for mobile pdf with down-scaled images as dependencies
$(TEXFILE)-mobile.pdf: $(SOURCES) $(PACKAGES) $(TARGETIMGS) $(SMALLIMGDIR)/Gsicht.png git-commit-time.tex

# Funny image for left side of header
$(SMALLIMGDIR)/Gsicht.png: $(IMGDIR)/Gsicht.png $(SMALLIMGDIR)/.dirstamp
	@cp $(IMGDIR)/Gsicht.png $(SMALLIMGDIR)

# Scale down left hand side images
$(SMALLIMGDIR)/%_0.jpg: $(IMGDIR)/%_0.jpg $(SMALLIMGDIR)/.dirstamp
	$(CONVERT) $< $(CONVERTARGS) -define jpeg:extent="$(BIGIMAGESIZE)kb" $@

# Scale down right hand side image
$(SMALLIMGDIR)/%_1.jpg: $(IMGDIR)/%_1.jpg $(SMALLIMGDIR)/.dirstamp
	$(CONVERT) $< $(CONVERTARGS) -define jpeg:extent="$(SMALLIMAGESIZE)kb" $@

# Allow this one image a larger file size
$(SMALLIMGDIR)/LammbratenSherrySauce_1.jpg: $(IMGDIR)/LammbratenSherrySauce_1.jpg $(SMALLIMGDIR)/.dirstamp
	$(CONVERT) $< $(CONVERTARGS) -define jpeg:extent="$(BIGIMAGESIZE)kb" $@

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
