#!/bin/bash
#Count
SRILMPATH="/Users/lluisf/Code/MOOC/bashlm/Assignment/driver_compiled/macosx/srilm"

echo Append training files
cat matthew.tok.low mark.tok.low luke.tok.low > bible.train.tok.low

echo
echo Doing Counts of N-grams
$SRILMPATH/ngram-count -text bible.train.tok.low  -order 3 -write1 bible.train.lm_counts.1 -write2 bible.train.lm_counts.2 -write3 bible.train.lm_counts.3 2>/dev/null

echo
echo Obtaining Good Turing parameters and 1-gram, 2-gram and 3-gram Count of Counts
$SRILMPATH/ngram-count -text bible.train.tok.low  -order 3 -gt1 bible.train.gt.1 -gt2 bible.train.gt.2 -gt3 bible.train.gt.3 -unk -debug 2 2> bible.train.CC

echo
echo Obtaining Kneser-Ney parameters
# TO BE PROGRAMMED

echo
echo Building LM according to other different discounting interpolation schemes
# TO BE PROGRAMMED
	
echo 
echo Measuring perplexities according to John...
echo 
echo Good-Turing...
# TO BE PROGRAMMED | grep ppl | sed "s/^.*ppl1= //g"
echo 
echo Witten-Bell...
# TO BE PROGRAMMED | grep ppl | sed "s/^.*ppl1= //g"
echo 
echo Unmodified Kneser-Ney...
# TO BE PROGRAMMED | grep ppl | sed "s/^.*ppl1= //g"
echo 
echo Modified Kneser-Ney...
# TO BE PROGRAMMED | grep ppl | sed "s/^.*ppl1= //g"
echo 
echo Interpolated and Modified Kneser-Ney...
# TO BE PROGRAMMED | grep ppl | sed "s/^.*ppl1= //g"

echo 
echo Building Gospel-specific Language Models...
# TO BE PROGRAMMED


echo 
echo Measuring similarities between LM and texts...
echo 
echo matthew-mark
# TO BE PROGRAMMED | grep ppl | sed "s/^.*ppl1= //g"
echo 
echo matthew-john
# TO BE PROGRAMMED | grep ppl | sed "s/^.*ppl1= //g"
echo 
echo matthew-luke
# TO BE PROGRAMMED | grep ppl | sed "s/^.*ppl1= //g"
echo 
echo 
echo mark-matthew
# TO BE PROGRAMMED | grep ppl | sed "s/^.*ppl1= //g"
echo 
echo mark-john
# TO BE PROGRAMMED | grep ppl | sed "s/^.*ppl1= //g"
echo 
echo mark-luke
# TO BE PROGRAMMED | grep ppl | sed "s/^.*ppl1= //g"
echo 
echo 
echo john-matthew
# TO BE PROGRAMMED | grep ppl | sed "s/^.*ppl1= //g"
echo 
echo john-mark
# TO BE PROGRAMMED | grep ppl | sed "s/^.*ppl1= //g"
echo 
echo john-luke
# TO BE PROGRAMMED | grep ppl | sed "s/^.*ppl1= //g"
echo 
echo 
echo luke-matthew
# TO BE PROGRAMMED | grep ppl | sed "s/^.*ppl1= //g"
echo 
echo luke-mark
# TO BE PROGRAMMED | grep ppl | sed "s/^.*ppl1= //g"
echo 
echo luke-john
# TO BE PROGRAMMED | grep ppl | sed "s/^.*ppl1= //g"