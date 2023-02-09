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
SOURCEWEBIMGS  :=$(foreach dir,$(IMGDIR), $(wildcard $(dir)/*_0.jpg))
WEBIMGS        :=$(addprefix $(WEBIMGPREFIX)/, $(SOURCEWEBIMGS:.jpg=.webp))
WEBIMGSGNORTH  :=AprikosenSahneDessert_0.webp Bananenmilch_0.webp Berliner_0.webp Bratkartoffeln_0.webp BruschettaMitOliven_0.webp Chilipaste_0.webp GefuelltePaprika_0.webp KaesekuchenLuftigUndZart_0.webp Kokosmakronen_0.webp Leber_0.webp Mohrenkopftorte_0.webp PestoGenovese_0.webp SaftigeMuffins_0.webp Quarkinis_0.webp QuicheAusQuarkOElTeig_0.webp RosenkohlSchlemmerGratin_0.webp Rueblekuchen_0.webp RuebleNachRita_0.webp SchwarzwaelderKirschtorte_0.webp Schneewittchenkuchen_0.webp SpaghettiMitFleischbaellchen_0.webp Tomatensauce_0.webp Traubenfisch_0.webp WalnussTomatenPesto_0.webp WhiskySahneSauce_0.webp ZitronenkuchenLammUndHase_0.webp Zwetschgenkernlikoer_0.webp ZwetschgenkuchenMuerbteig_0.webp
WEBIMGSGNORTHT :=$(addprefix $(WEBIMGPREFIX)/$(IMGDIR)/, $(WEBIMGSGNORTH))
WEBIMGSGSOUTH  :=DrunkenCrumble_0.webp Salzzitronen_0.webp
WEBIMGSGSOUTHT :=$(addprefix $(WEBIMGPREFIX)/$(IMGDIR)/, $(WEBIMGSGSOUTH))

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

$(WEBIMGSGNORTHT): $(WEBIMGDIR)/%.webp: $(IMGDIR)/%.jpg $(WEBIMGDIR)/.dirstamp
	$(CONVERT) $< $(CONVERTARGS) -resize 1280x720^ -gravity North -extent 1280x720 $@

$(WEBIMGSGSOUTHT): $(WEBIMGDIR)/%.webp: $(IMGDIR)/%.jpg $(WEBIMGDIR)/.dirstamp
	$(CONVERT) $< $(CONVERTARGS) -resize 1280x720^ -gravity South -extent 1280x720 $@

$(WEBIMGDIR)/EingelegterSchafskaese_0.webp: $(IMGDIR)/EingelegterSchafskaese_0.jpg $(WEBIMGDIR)/.dirstamp
	$(CONVERT) $< $(CONVERTARGS) -resize 1280x720^ -gravity North -chop 0x80 -extent 1280x720 $@

$(WEBIMGDIR)/WhiskyKraeuterLikoer_0.webp: $(IMGDIR)/WhiskyKraeuterLikoer_0.jpg $(WEBIMGDIR)/.dirstamp
	$(CONVERT) $< $(CONVERTARGS) -resize 1280x720^ -gravity North -chop 0x320 -extent 1280x720 $@

$(WEBIMGDIR)/ZwetschgenkuchenQuarkoelteig_0.webp: $(IMGDIR)/ZwetschgenkuchenQuarkoelteig_0.jpg $(WEBIMGDIR)/.dirstamp
	$(CONVERT) $< $(CONVERTARGS) -resize 1280x720^ -gravity North -chop 0x32 -extent 1280x720 $@

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
