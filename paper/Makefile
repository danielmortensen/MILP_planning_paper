all: compileTex clean

compileTex: 
	pdflatex busCharge.tex
	bibtex busCharge
	pdflatex busCharge.tex 

clean: 
	rm *.aux
	rm *-blx.bib
	rm *.log
	rm *.run.xml
	rm *.bbl
	rm *.blg
