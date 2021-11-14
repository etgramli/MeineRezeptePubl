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
WEBPARGS       :=-resize 1280x720^ -gravity Center -extent 1280x720

# Image files and down-scaled versions
SOURCEIMGS     :=$(foreach dir,$(IMGDIR), $(wildcard $(dir)/*.jpg))
TARGETIMGS     :=$(addprefix $(SMALLIMGPREFIX)/, $(SOURCEIMGS))
WEBIMGSSRC     :=$(wildcard $(IMGDIR)/*_0.jpg)
WEBIMGS        :=$(addprefix $(WEBIMGPREFIX)/, $(WEBIMGSSRC:.jpg=.webp))

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

webpimages: $(WEBIMGS)
#	mkdir --parents $(WEBIMGDIR)/w1280
#	mogrify -path $(WEBIMGDIR)/w1280 $(CONVERTARGS) -resize 1280x784^ -gravity Center -extent 1280x784 -format webp $?
#	mkdir --parents $(WEBIMGDIR)/w1080
#	mogrify -path $(WEBIMGDIR)/w1080 $(CONVERTARGS) -resize 1080x656^ -gravity Center -extent 1080x656 -format webp $?
#	mkdir --parents $(WEBIMGDIR)/w960
#	mogrify -path $(WEBIMGDIR)/w960 $(CONVERTARGS) -resize 960x592^ -gravity Center -extent 960x592 -format webp $?
#	mkdir --parents $(WEBIMGDIR)/w720
#	mogrify -path $(WEBIMGDIR)/w720 $(CONVERTARGS) -resize 720x448^ -gravity Center -extent 720x448 -format webp $?


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

# Helper to test if image directory is created
$(SMALLIMGDIR)/.dirstamp:
	@mkdir --parents $(SMALLIMGDIR) && touch $@

# Scale down images for web use
$(WEBIMGDIR)/%.webp: $(IMGDIR)/%.jpg $(WEBIMGDIR)/.dirstamp
	$(CONVERT) $< $(CONVERTARGS) $(WEBPARGS) $@

# Helper to test if image directory is created
$(WEBIMGDIR)/.dirstamp:
	@mkdir --parents $(WEBIMGDIR) && touch $@

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
