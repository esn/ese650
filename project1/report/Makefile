NAME=ese650-quchao-proj1

all: $(NAME).tex
	rubber -d $<

% : %.tex
	rubber -d $<

edit:
	texmaker $(NAME).tex &

test:
	evince $(NAME).pdf &

clean:
	rm -f *.aux *.log *.out *.pdf *.pdfsync *.synctex.gz *.blg *.bbl *.tex.bak
