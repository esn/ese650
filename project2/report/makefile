NAME=ese650-quchao-proj2
CC=pdflatex

all: $(NAME).tex
	$(CC) $<

% : %.tex
	$(CC) $<

edit:
	vim $(NAME).tex

texm:
	texmaker $(NAME).tex &

test:
	evince $(NAME).pdf &

clean:
	rm -f *.aux *.log *.out *.pdf *.pdfsync *.synctex.gz *.blg *.bbl *.tex.bak
