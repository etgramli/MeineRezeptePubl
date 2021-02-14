# Familien-Rezeptbuch
Das hier ist die Readme zu meinem Rezeptbuch, und soll die technische Umsetzung erklären.

Benutzt werden nur LaTeX um das Dokument zu setzen, Git für die Versionsverwaltung und Make, um verschiedene Versionen des Buches oder einzelne Rezepte zu erzeugen.


## Wie man das PDF erstellt
Das Buch als PDF kann man in zwei Versionen erstellen: mit Bildern in voller Auflösung (zum Druck) oder mit kleineren Bildern (für den Bildschirm).

Um das PDF mit großen Bildern zu generieren, braucht man zumindest eine LaTeX-Distribution und ein LaTeX-Editor (siehe Installation für das jeweilige Betriebssystem). Danach kann man das PDF innerhalb von Texmaker erstellen. Es wird aber dazu geraten, das Buch mit dem Makefile zu generieren, damit man auch das PDF mit kleinen Bildern erstellen kann (siehe nächster Absatz).

### Mit dem Makefile erstellen
Das Buch sollte besser mit dem Make erstellt werden. Dazu gibt es zwei Befehle:
- ```make```, und
- ```make mobile```
Mit dem ersten Aufruf erstellt man das PDF mit Bildern in voller Auflösung, mit dem zweiten die Bilder in geringerer Größe.

Zusätzlich kann man jedes Rezept einzeln generieren lassen, mit dem Pfad zum Tex-File vorangestellt; die Bilder sind hier voll aufgelöst.


## Installation
Zum Erstellen des PDFs braucht man mindestens:
- Texmaker
- TexLive oder MiKTeX

Für das PDF mit herunterskalierten Bildern zu generieren, braucht man zusätzlich:
- ImageMagick
- Make

In Texmaker sollte Shell-Escaping aktiviert werden, damit die Plattform richtig erkannt wird.

### Windows 7
Die Software für Windows gibt es bei folgenden Links und sollten mit den Standardeinstellungen installiert werden:
- [Texmaker](http://www.xm1math.net/texmaker/)
- [MiKTeX](http://miktex.org/)

- [Git](https://git-scm.com/download/)
- [ImageMagick (dll)](https://www.imagemagick.org/script/download.php)
- [Make (Cygwin)](https://cygwin.com/install.html)

Make sollte über den Cygwin-Installer installiert und ausgeführt werden. Über die Suchfunktion innerhalb des Installers findet man Make schnell. Außerdem sollte das Paket "chere" installiert werden, mit dem Aufruf von ```chere -i -t mintty -s bash``` vom Cygwin-Terminal (als Admin gestartet) wird ein Kontextmenü-Eintrag erstellt, mit dem man das Cygwin-Terminal in einem beliebigen Ordner öffnen kann. Das erleichtert die Navigation doch sehr!

### Windows 10 (ab 1809)
Wie bei Windows 7 muss man [Texmaker](http://www.xm1math.net/texmaker/), [MiKTeX](http://miktex.org/) und [Git](https://git-scm.com/download/) installieren.

Jetzt kann man mit Texmaker schon die Version mit Bildern in voller Auflösung erstellen. Um die kleine Version zu erstellen, muss man die folgenden Schritte auch ausführen.

#### Windows Subsystem for Linux
Es muss noch das Windows Subsystem for Linux aktiviert und heruntergeladen werden.
Das macht man entweder über ```Wondows-Features aktivieren oder deaktivieren -> Windows-Subsystem für Linux``` oder in der PowerShell als Administrator: ```Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Windows-Subsystem-Linux```.

Danach kann man über den Store Ubuntu installieren und ein Benutzerkonto unter Linux einrichten. Es wird empfohlen, die Pakete zu aktualisieren (```sudo apt-get update && sudo apt-get upgrade```).

Zum Schluss muss man in Ubuntu noch folgende Pakete installieren (```sudo apt-get install git make imagemagick texlive-full```). Das wird eine Weile dauern, auch mit SSD:
- TexLive (full)
- Git
- Make
- ImageMagick

Jetzt kann man mit ```cd /mnt/c/<Ordner>``` in den Ordner mit dem Rezeptbuch navigieren und mit ```make mobile``` die Version mit kleinen Bildern generieren.

### Linux
Für Linux empfiehlt sich eine Vollinstallation von TeXLive, somit ergibt sich eine Installaion der Pakete mit folgendem Befehl: ```sudo apt-get install texmaker texlive-full git imagemagick make```.


## Versionsverwaltung mit Git
Es gibt einen master-Branch, der dem aktuellsten Stand entspricht und nur komplette Rezepte enthält. Von ihm aus werden neue Rezept- und Technische-Feature-Branches erzeugt. Wenn ein Rezept/Feature vollständig ist, wird der Branch in den master zurück gemergt.

Regeläßig wird der master in den release-Branch gemergt, um ein Release zu erstellen. Dafür sollten die Rezepte noch einmal auf Fehler oder fehlende Angaben überprüft werden. Falls doch ein Fehler im Release entdeckt wurde, kann er dort direkt behoben werden und die Änderungen in den master zurückgespielt werden.

Falls genug neue Rezepte im Release gelandet sind oder thematisch zueinander passende Rezepte hinzu gekommen sind, kann auf dem Release ein neues Tag erstellt werden, um einen Überblick zu gewähren. Das ist nur optional, das Rezeptbuch entspricht eher einem Rolling Release.


### Wann ein Rezept fertig ist:
- Zutatenliste entspricht den genutzten Zutaten in allen Schritten
- Die Mengeneinheiten der Zutaten sind in metrischen und europäischen Einheiten (ml statt oz, g statt pounds, TL statt Cups) angegeben
- Alles grammatikalisch und typografisch korrekt
- Mindestens ein linksbündiges und breites Bild
- Auf zu lange Zeilen und seltsame Umbrüche achten! (Underfull oder overfull box warnings)


## LaTeX
Genutzt wurde das Paket xcookybooky, das angepasst wurde, um die Höhe der Bilder zu verändern.

Ein neues Paket "recipe_book" wurde angelegt, das eigene Befehle enthält und alle nötigen Pakete einbindet.

Die PDFs entsprechen dem Standard PDF/A-1b, damit sie auf allen Plattformen möglist gleich aussehen, und das möglichst lange.

Zum Erstellen der PDFs gibt es Targets im Makefile, die jeweils LatexMk aufrufen. Ansonsten kann das Buch auch über mehrfachen Aufruf von PdfLaTeX, madeindex und noch einmal PdfLaTeX generiert werden, oder besser man benutzt Latexmk selbst. Das Rezeptbuch kann z.Zt. nicht mit Xe(La)TeX oder Lua(La)TeX erstellt werden.

Ein Latexmk-File liegt auch im Repository, das Regeln für die zwei Hauptdateien und zum Löschen von temporären Dateien enthält.


## Known Issues
Bekannte Probleme oder bewusst eingegangene Kompromisse:
- Underfull box warnings bei "Johannisbrotkernmehl" und "Cremetortenpulver" - sie lassen sich nicht gut trennen und die Zutatenmengen lassen sich nicht verkürzen, sodass eine Worttrennung ohne Warnung gegeben wäre
- Das Rezeptbuch lässt sich mit XeLaTeX und LuaLaTeX erstellen, entspricht dann aber nicht mehr einer validen PDF/A-Datei (laut VeraPDF).


## ToDos:
- Falls Update von [subfiles](https://github.com/gsalzer/subfiles/issues/3): entferne Fix im Makefile der Subfile targets
- Falls Update von xcookybooky: entferne manuellen Fix in recipy_book.sty
- Fix LuaLaTeX warnings:
-- Missing font shapes
