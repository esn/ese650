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
	rm -f $(NAME).pdf *.aux *.log *.out *.pdfsync *.synctex.gz *.blg *.bbl *.tex.bak
