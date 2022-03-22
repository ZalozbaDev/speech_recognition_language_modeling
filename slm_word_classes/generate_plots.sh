#!/bin/bash

SUBPATH="merge/"
PLOTDIR="plots/"

rm -rf ${PLOTDIR}
mkdir -p ${PLOTDIR}

cp ${SUBPATH}/hsb.txt_ofst_is.txt ${PLOTDIR}/isyms.txt
cp ${SUBPATH}/hsb.txt_ofst_os.txt ${PLOTDIR}/osyms.txt

function generate_isyms {
	cat ${PLOTDIR}/isyms.txt | sed -e 's/.*/\U&/g' > ${PLOTDIR}/isyms_added.txt
}

function add_to_isyms {
	echo "$1" >> ${PLOTDIR}/isyms_added.txt
}

function plot_fst {
	echo "Plotting $1"
	
	cat ${SUBPATH}/$1.txt | sed -e 's/.*/\U&/g' > ${PLOTDIR}/input.txt

	fstcompile --isymbols=${PLOTDIR}/isyms_added.txt --osymbols=${PLOTDIR}/osyms.txt ${PLOTDIR}/input.txt ${PLOTDIR}/output.fst
	fstdraw --isymbols=${PLOTDIR}/isyms_added.txt --osymbols=${PLOTDIR}/osyms.txt ${PLOTDIR}/output.fst ${PLOTDIR}/output.dot
	dot -Tpdf -Grotate=0 ${PLOTDIR}/output.dot > ${PLOTDIR}/$1.pdf
}

##########################################################################
## NUMBERS (PERCENTAGES)
##########################################################################

generate_isyms
plot_fst "NUM1-9"

generate_isyms
add_to_isyms "NUM1-9	1000"
plot_fst "NUM5-99"

generate_isyms
add_to_isyms "NUM5-99	1000"
plot_fst "NUM1-99"

generate_isyms
add_to_isyms "NUM1-99	1000"
plot_fst "NUM1-100"
