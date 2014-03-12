SRC=ese650-quchao-proj4
TEX=pdflatex

all: pdf

pdf: $(SRC).tex
	$(TEX) $<

% : %.tex
	$(TEX) $<

edit:
	vim $(SRC).tex

texm:
	texmaker $(SRC).tex &

test: pdf
	evince $(SRC).pdf &

clean:
	rm -f $(SRC).pdf *.aux *.log *.out *.pdfsync *.synctex.gz *.blg *.bbl *.tex.bak
