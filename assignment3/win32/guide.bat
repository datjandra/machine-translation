@echo off
cls
SET SRILMPATH=.\

echo Append training files
type matthew.tok.low mark.tok.low luke.tok.low > bible.train.tok.low

echo.
echo Doing Counts of N-grams
%SRILMPATH%\ngram-count -text bible.train.tok.low  -order 3 -write1 bible.train.lm_counts.1 -write2 bible.train.lm_counts.2 -write3 bible.train.lm_counts.3

echo.
echo Obtaining Good Turing parameters and 1-gram, 2-gram and 3-gram Count of Counts
%SRILMPATH%\ngram-count -text bible.train.tok.low  -order 3 -gt1 bible.train.gt.1 -gt2 bible.train.gt.2 -gt3 bible.train.gt.3 -unk -debug 2 2> bible.train.CC

echo Obtaining Good Turing language model
%SRILMPATH%\ngram-count -unk -text bible.train.tok.low -order 3 -gt1 bible.train.gt.1 -gt2 bible.train.gt.2 -gt3 bible.train.gt.3 -lm bible.train.gt.lm

echo.
echo Obtaining Kneser-Ney parameters
%SRILMPATH%\ngram-count -text bible.train.tok.low -order 3 -kn1 bible.train.kn.1 -kn2 bible.train.kn.2 -kn3 bible.train.kn.3 -unk -debug 2 2> bible.train.KN

echo.
echo Building LM according to other different discounting interpolation schemes

echo Obtaining Witten-Bell language model
%SRILMPATH%\ngram-count -unk -text bible.train.tok.low -order 3 -lm bible.train.wb.lm -wbdiscount

echo Obtaining unmodified Kneser-Ney language model
%SRILMPATH%\ngram-count -unk -text bible.train.tok.low -order 3 -lm bible.train.ukn.lm -ukndiscount

echo Obtaining modified Kneser-Ney language model
%SRILMPATH%\ngram-count -unk -text bible.train.tok.low -order 3 -lm bible.train.kn.lm -kndiscount
	
echo.
echo Measuring perplexities according to John...
echo.
echo Good-Turing...
%SRILMPATH%\ngram -unk -lm bible.train.gt.lm -ppl john.tok.low | findstr ppl | cscript //Nologo %SRILMPATH%\sed.vbs "s/^.*ppl1= //g"

echo.
echo Witten-Bell...
%SRILMPATH%\ngram -unk -lm bible.train.wb.lm -ppl john.tok.low | findstr ppl | cscript //Nologo %SRILMPATH%\sed.vbs "s/^.*ppl1= //g"

echo.
echo Unmodified Kneser-Ney...
%SRILMPATH%\ngram -unk -lm bible.train.ukn.lm -ppl john.tok.low | findstr ppl | cscript //Nologo %SRILMPATH%\sed.vbs "s/^.*ppl1= //g"

echo.
echo Modified Kneser-Ney...
%SRILMPATH%\ngram -unk -lm bible.train.kn.lm -ppl john.tok.low | findstr ppl | cscript //Nologo %SRILMPATH%\sed.vbs "s/^.*ppl1= //g"

echo.
echo Interpolated and Modified Kneser-Ney...
%SRILMPATH%\ngram-count -unk -text bible.train.tok.low -order 3 -lm bible.train.ikn.lm -kndiscount -interpolate
%SRILMPATH%\ngram -unk -lm bible.train.ikn.lm -ppl john.tok.low | findstr ppl | cscript //Nologo %SRILMPATH%\sed.vbs "s/^.*ppl1= //g"

echo.
echo Building Gospel-specific Language Models...
%SRILMPATH%\ngram-count -unk -text matthew.tok.low -order 3 -lm matthew.ukn.lm -ukndiscount
%SRILMPATH%\ngram-count -unk -text mark.tok.low -order 3 -lm mark.ukn.lm -ukndiscount
%SRILMPATH%\ngram-count -unk -text luke.tok.low -order 3 -lm luke.ukn.lm -ukndiscount
%SRILMPATH%\ngram-count -unk -text john.tok.low -order 3 -lm john.ukn.lm -ukndiscount

echo.
echo Measuring similarities between LM and texts...
echo.
echo matthew-mark
%SRILMPATH%\ngram -unk -lm matthew.ukn.lm -ppl mark.tok.low | findstr ppl | cscript //Nologo %SRILMPATH%\sed.vbs "s/^.*ppl1= //g"

echo.
echo matthew-john
%SRILMPATH%\ngram -unk -lm matthew.ukn.lm -ppl john.tok.low | findstr ppl | cscript //Nologo %SRILMPATH%\sed.vbs "s/^.*ppl1= //g"

echo.
echo matthew-luke
%SRILMPATH%\ngram -unk -lm matthew.ukn.lm -ppl luke.tok.low | findstr ppl | cscript //Nologo %SRILMPATH%\sed.vbs "s/^.*ppl1= //g"

echo.
echo.
echo mark-matthew
%SRILMPATH%\ngram -unk -lm mark.ukn.lm -ppl matthew.tok.low | findstr ppl | cscript //Nologo %SRILMPATH%\sed.vbs "s/^.*ppl1= //g"

echo.
echo mark-john
%SRILMPATH%\ngram -unk -lm mark.ukn.lm -ppl john.tok.low | findstr ppl | cscript //Nologo %SRILMPATH%\sed.vbs "s/^.*ppl1= //g"

echo.
echo mark-luke
%SRILMPATH%\ngram -unk -lm mark.ukn.lm -ppl luke.tok.low | findstr ppl | cscript //Nologo %SRILMPATH%\sed.vbs "s/^.*ppl1= //g"

echo.
echo.
echo john-matthew
%SRILMPATH%\ngram -unk -lm john.ukn.lm -ppl matthew.tok.low | findstr ppl | cscript //Nologo %SRILMPATH%\sed.vbs "s/^.*ppl1= //g"

echo.
echo john-mark
%SRILMPATH%\ngram -unk -lm john.ukn.lm -ppl mark.tok.low | findstr ppl | cscript //Nologo %SRILMPATH%\sed.vbs "s/^.*ppl1= //g"

echo.
echo john-luke
%SRILMPATH%\ngram -unk -lm john.ukn.lm -ppl luke.tok.low | findstr ppl | cscript //Nologo %SRILMPATH%\sed.vbs "s/^.*ppl1= //g"

echo.
echo.
echo luke-matthew
%SRILMPATH%\ngram -unk -lm luke.ukn.lm -ppl matthew.tok.low | findstr ppl | cscript //Nologo %SRILMPATH%\sed.vbs "s/^.*ppl1= //g"

echo.
echo luke-mark
%SRILMPATH%\ngram -unk -lm luke.ukn.lm -ppl mark.tok.low | findstr ppl | cscript //Nologo %SRILMPATH%\sed.vbs "s/^.*ppl1= //g"

echo.
echo luke-john
%SRILMPATH%\ngram -unk -lm luke.ukn.lm -ppl john.tok.low | findstr ppl | cscript //Nologo %SRILMPATH%\sed.vbs "s/^.*ppl1= //g"

pause