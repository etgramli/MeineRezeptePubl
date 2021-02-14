$pdf_mode = 1;
$pdflatex = 'pdflatex -interaction=nonstopmode -shell-escape';
$bibtex_use = 2;

@default_files = ('MeineRezepte.tex', 'MeineRezepte-mobile.tex');

@generated_exts = (@generated_exts, 'bbl');
@generated_exts = (@generated_exts, 'glg');
@generated_exts = (@generated_exts, 'glo');
@generated_exts = (@generated_exts, 'gls');
@generated_exts = (@generated_exts, 'ist');
@generated_exts = (@generated_exts, 'lol');
@generated_exts = (@generated_exts, 'synctex.gz');
