#!/bin/ksh
#skrish .1
#steal-but-improve-this-script license
#the author is not responsible for any summoned gremlins
#br@triapul.cz

HELP() {
cat <<EOF_
skrish is a simple plain text language
for composing plays and dialogue heavy
texts.

skrish translates skrish-lang documents
into readable, well formated playscripts.

Anatomy of a skrish-lang doc:

Lines beginning with the following strings
or characters will format subsequent text 
accordingly. All blocks of text must 
be followed by an empty line. CH must  
be followed by a block of text. TITLE, 
SUB and ACT do not have to be followed 
by an empty line. All tags, with the 
exception of # must be followed by a space
or <TAB>.

see examples at https://triapul.cz/soft/skrish

Tags (case sensitive):

TITLE	Name of the text
SUB	Subtitle.
ACT	Title of act.
CH	Character name, followed by direct speech.
*	Paragraph describing an action.
#	Internal comment. Doesn't get printed.
		Must be bordered by empty lines.

Lines beginning with anything else are 
treated as regular paragraphs.

Dialogue and paragraphs can be split between
several lines or written on a single long one.

Usage: ksh skrish.ksh FILE > FORMATED_FILE
FILE is a properly syntaxed skrish-lang play.

By default the output is formated at
76 characters width with empty margins
on each side. This is to make it 
compatible with gopher.

Options:

-h	Display this text.

-A INT	Margin of Act title. (Default 0)

-d INT	Fold dialogue at INT characters.
	(Default 40)

-D INT	Margin of dialogue from the left.
	(Default 8)

-C INT 	Margin of character name.
	(Default 4)

-e INT	Width of event paragraphs.
	(Default 66)

-E INT	Margin of event paragraphs.
	(Default 4)

-S INT	Margin of subtitle. (Default 0)

-T INT	Margin of title. (Default 0)

-w INT	Width of regular paragraphs. 
	Effectively the width of the entire
	document. (Default 72)

-W INT	Margin of paragraphs. (Default 2)


EOF_
}



#DEFAULT MARGINS
MARGIN_CH="    "
#TO-DO(ATTEMPT) MARGIN_AC=$(tput col)/2 + 1/2 of string l etc
#center text; string-length-fold-length/2 -(pagemargin/2)
MARGIN_AC=""
WIDTH_DL=40
MARGIN_DL="        "
WIDTH_PRG=72
MARGIN_PRG="  "
MARGIN_STAR="    "
WIDTH_STAR=66
MARGIN_TI=""
MARGIN_SU=""


LINE_COUNT() {
LINE=$(sed -n $x\p $LOCAL_FILE)
P_END=$(sed -n $g\p $LOCAL_FILE)
}

LINE_ADV() {
((x++))
}

COUNT_PASSAGE() {
g=$x;TMP=0;
until [[ $P_END = "" ]]; do
LINE_COUNT
((TMP++))
((g++));
done
#print -n "passage long $TMP lines"; read
}

CORRECT_LINE() {
x=$((x+TMP-2))
}

DLG() {
	print -n "$MARGIN_DL\""
until [[ $LINE = "" ]]; do
	LINE_COUNT
	print -n "$LINE "
	LINE_ADV
done | sed 's/ *$//'
	print -n \"
}

PRG() {
	print -n "$MARGIN_PRG"
until [[ $LINE = "" ]]; do
	LINE_COUNT
	print -n "$LINE "
	LINE_ADV
done
}

TRANSFORM_TEXT() {
if [[ $LINE = TITLE* ]]; then
	 print "$MARGIN_TI$(print $LINE | sed 's/^TITLE *//' |\
		tr '[:lower:]' '[:upper:]')"
elif [[ $LINE = \#* ]]; then :
elif [[ $LINE = SUB* ]]; then
	 print "$MARGIN_SU$(print $LINE | sed 's/^SUB *//')"
elif [[ $LINE = ACT* ]]; then
	 print "$MARGIN_AC$(print $LINE | sed 's/^ACT *//')"
elif [[ $LINE = CH* ]]; then
	 print "$MARGIN_CH$(print $LINE | sed 's/^CH *//' |\
		 tr '[:lower:]' '[:upper:]'):"
	LINE_ADV
	COUNT_PASSAGE;
	DLG | fmt -w $WIDTH_DL
	CORRECT_LINE
elif [[ $LINE = \** ]]; then
	COUNT_PASSAGE;
	MARGIN_PRG=$MARGIN_STAR
	PRG | fmt -w $WIDTH_STAR
	CORRECT_LINE
else
	COUNT_PASSAGE;
	PRG | fmt -w $WIDTH_PRG	
	CORRECT_LINE
fi

}



SKRISH() {
NUMLINES=$(sed -n '$=' $LOCAL_FILE)

x=1
while (( x < NUMLINES + 1 )); do
	LINE_COUNT
	#print -n "DEBUG: $LINE";read
	if [[ $LINE = "" ]]; then
		print
	else
		TRANSFORM_TEXT
	fi
	LINE_ADV
 done
}

CHCK_INT() {
case $1 in
	("" | *[!0123456789]*)
	print "Option -$FLAG must be an integer!"
	exit
esac
}

	f=0;
while getopts :A:d:D:C:e:E:w:W:S:T:h FLAG; do
	case $FLAG in
		h) HELP; exit;;
		A) A_F=1;MAR_A=$OPTARG;CHCK_INT $MAR_A;((f++));;
		d) WIDTH_DL=$OPTARG;CHCK_INT $WIDTH_DL;((f++));;
		D) A_D=1;MAR_D=$OPTARG;CHCK_INT $MAR_D;((f++));;
		C) A_C=1;MAR_C=$OPTARG;CHCK_INT $MAR_C;((f++));;
		e) WIDTH_STAR=$OPTARG;CHCK_INT $WIDTH_STAR;((f++));;
		E) A_S=1;MAR_S=$OPTARG;CHCK_INT $MAR_S;((f++));;
		w) WIDTH_PRG=$OPTARG;CHCK_INT $WIDTH_PRG;((f++));;
		W) A_W=1;MAR_W=$OPTARG;CHCK_INT $MAR_W;((f++));;
		T) A_T=1;MAR_T=$OPTARG;CHCK_INT $MAR_T;((f++));;
		S) A_B=1;MAR_B=$OPTARG;CHCK_INT $MAR_B;((f++));;
	esac	
done

if (( f > 0 )); then
for SHIFTNUM in $(seq $f); do
	shift 2
done;fi

WIDEN() {
WID() {
for k in $(seq "$1"); do
print -n " ";
done
}

if [[ $2 = MARGIN_AC ]]; then
MARGIN_AC=$(print -n "$(WID $1 $2)"); 
elif [[ $2 = MARGIN_DL ]]; then
MARGIN_DL=$(print -n "$(WID $1 $2)");
elif [[ $2 = MARGIN_CH ]]; then
MARGIN_CH=$(print -n "$(WID $1 $2)");
elif [[ $2 = MARGIN_STAR ]]; then
MARGIN_STAR=$(print -n "$(WID $1 $2)");
elif [[ $2 = MARGIN_PRG ]]; then
MARGIN_PRG=$(print -n "$(WID $1 $2)");
elif [[ $2 = MARGIN_TI ]]; then
MARGIN_TI=$(print -n "$(WID $1 $2)");
elif [[ $2 = MARGIN_SU ]]; then
MARGIN_SU=$(print -n "$(WID $1 $2)");
fi
}

if (( A_F == 1 )); then WIDEN $MAR_A MARGIN_AC; fi
if (( A_D == 1 )); then WIDEN $MAR_D MARGIN_DL; fi
if (( A_C == 1 )); then WIDEN $MAR_C MARGIN_CH; fi
if (( A_S == 1 )); then WIDEN $MAR_S MARGIN_STAR; fi
if (( A_W == 1 )); then WIDEN $MAR_W MARGIN_PRG; fi
if (( A_T == 1 )); then WIDEN $MAR_T MARGIN_TI; fi
if (( A_B == 1 )); then WIDEN $MAR_B MARGIN_SU; fi


LOCAL_FILE=$1
if [[ ! -f $LOCAL_FILE ]]; then
	print "You need to put in something that exists (and better yet: is formatted for skrish)."
	exit

fi


SKRISH
