NAME=ese650-quchao-proj5
CC=pdflatex

all: pdf

pdf: $(NAME).tex
	$(CC) $<

% : %.tex
	$(CC) $<

edit:
	vim $(NAME).tex

texm:
	texmaker $(NAME).tex &

test: pdf
	evince $(NAME).pdf &

clean:
	rm -f $(NAME).pdf *.aux *.log *.out *.pdfsync *.synctex.gz *.blg *.bbl *.tex.bak
