#!/bin/bash

SUBPATH="grammars/"
PLOTDIR="plots/"

rm -rf ${PLOTDIR}
mkdir -p ${PLOTDIR}

cp ${SUBPATH}/smart_lamp_hsb_evl_fsg_num.txt_ofst_is.txt ${PLOTDIR}/isyms.txt
cp ${SUBPATH}/smart_lamp_hsb_evl_fsg_num.txt_ofst_os.txt ${PLOTDIR}/osyms.txt
# cp pregenerated/smart_lamp_hsb_evl_fsg_num.txt_ofst_os.txt ${PLOTDIR}/osyms.txt

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
## NUMBERS
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
plot_fst "NUM(1-9)00"

generate_isyms
add_to_isyms "NUM(1-9)00	1000"
add_to_isyms "NUM1-99	1001"
plot_fst "NUM1-999"

generate_isyms
add_to_isyms "NUM(1-9)00	1000"
add_to_isyms "NUM1-99	1001"
add_to_isyms "NUM1-999	1002"
add_to_isyms "NUM5-99	1003"
plot_fst "NUM1-10^6"

generate_isyms
add_to_isyms "NUM(1-9)00	1000"
add_to_isyms "NUM1-10^6	1002"
add_to_isyms "NUM5-99	1003"
plot_fst "NUM1-10^9"

generate_isyms
add_to_isyms "NUM(1-9)00	1000"
add_to_isyms "NUM1-10^9	1002"
add_to_isyms "NUM5-99	1003"
plot_fst "NUM1-10^12"

generate_isyms
add_to_isyms "NUM(1-9)00	1000"
add_to_isyms "NUM1-10^12	1002"
add_to_isyms "NUM5-99	1003"
plot_fst "NUM1-10^15"

##########################################################################
## TIMES
##########################################################################

generate_isyms
plot_fst "NUM1-5do"
plot_fst "NUM0-23hodzin"

generate_isyms
add_to_isyms "NUM1-9	1000"
plot_fst "NUM1-19"
plot_fst "NUM1-59"

generate_isyms
add_to_isyms "NUM1-5DO	1000"
plot_fst "NUM1-10do"

generate_isyms
add_to_isyms "NUM1-19	1000"
plot_fst "NUM1-20do"

generate_isyms
add_to_isyms "NUM1-9	1000"
add_to_isyms "NUM1-5DO	1001"
add_to_isyms "NUM1-10DO	1002"
add_to_isyms "NUM1-20DO	1003"
add_to_isyms "NUM1-19	1004"
plot_fst "CLOCKMODWE"
plot_fst "CLOCKMODW"

generate_isyms
add_to_isyms "CLOCKMODWE	1000"
add_to_isyms "CLOCKMODW	1001"
add_to_isyms "NUM1-59	1002"
add_to_isyms "NUM0-23HODZIN	1003"
add_to_isyms "CLOCKUNTYPICAL	1004"
plot_fst "clock"

generate_isyms
plot_fst "CLOCKUNTYPICAL"

##########################################################################
## DATES
##########################################################################

generate_isyms
plot_fst "ORDmDat31"
plot_fst "ORDmDat1-29"
plot_fst "ORDmDat30"
plot_fst "ORDfDat1-31"
plot_fst "ORDf1-31"
plot_fst "ORDm1-29"
plot_fst "ORDm30"
plot_fst "ORDm31"
plot_fst "weekdays"

generate_isyms
add_to_isyms "ORDMDAT31	1000"
add_to_isyms "ORDMDAT1-29	1001"
add_to_isyms "ORDMDAT30	1002"
add_to_isyms "ORDFDAT1-31	1003"
plot_fst "DateDat"

generate_isyms
add_to_isyms "ORDM31	1000"
add_to_isyms "ORDM1-29	1001"
add_to_isyms "ORDM30	1002"
add_to_isyms "ORDF1-31	1003"
plot_fst "DateNom"

generate_isyms
add_to_isyms "WEEKDAYS	1000"
add_to_isyms "DATEDAT	1001"
add_to_isyms "DATENOM	1002"
plot_fst "DATE"
