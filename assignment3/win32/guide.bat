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
REM TO BE PROGRAMMED | findstr ppl | cscript //Nologo %SRILMPATH%\sed.vbs "s/^.*ppl1= //g"
echo.
echo Witten-Bell...
REM TO BE PROGRAMMED | findstr ppl | cscript //Nologo %SRILMPATH%\sed.vbs "s/^.*ppl1= //g"
echo.
echo Unmodified Kneser-Ney...
REM TO BE PROGRAMMED | findstr ppl | cscript //Nologo %SRILMPATH%\sed.vbs "s/^.*ppl1= //g"
echo.
echo Modified Kneser-Ney...
REM TO BE PROGRAMMED | findstr ppl | cscript //Nologo %SRILMPATH%\sed.vbs "s/^.*ppl1= //g"
echo.
echo Interpolated and Modified Kneser-Ney...
REM TO BE PROGRAMMED | findstr ppl | cscript //Nologo %SRILMPATH%\sed.vbs "s/^.*ppl1= //g"

echo.
echo Building Gospel-specific Language Models...
REM TO BE PROGRAMMED


echo.
echo Measuring similarities between LM and texts...
echo.
echo matthew-mark
REM TO BE PROGRAMMED | findstr ppl | cscript //Nologo %SRILMPATH%\sed.vbs "s/^.*ppl1= //g"
echo.
echo matthew-john
REM TO BE PROGRAMMED | findstr ppl | cscript //Nologo %SRILMPATH%\sed.vbs "s/^.*ppl1= //g"
echo.
echo matthew-luke
REM TO BE PROGRAMMED | findstr ppl | cscript //Nologo %SRILMPATH%\sed.vbs "s/^.*ppl1= //g"
echo.
echo.
echo mark-matthew
REM TO BE PROGRAMMED | findstr ppl | cscript //Nologo %SRILMPATH%\sed.vbs "s/^.*ppl1= //g"
echo.
echo mark-john
REM TO BE PROGRAMMED | findstr ppl | cscript //Nologo %SRILMPATH%\sed.vbs "s/^.*ppl1= //g"
echo.
echo mark-luke
REM TO BE PROGRAMMED | findstr ppl | cscript //Nologo %SRILMPATH%\sed.vbs "s/^.*ppl1= //g"
echo.
echo.
echo john-matthew
REM TO BE PROGRAMMED | findstr ppl | cscript //Nologo %SRILMPATH%\sed.vbs "s/^.*ppl1= //g"
echo.
echo john-mark
REM TO BE PROGRAMMED | findstr ppl | cscript //Nologo %SRILMPATH%\sed.vbs "s/^.*ppl1= //g"
echo.
echo john-luke
REM TO BE PROGRAMMED | findstr ppl | cscript //Nologo %SRILMPATH%\sed.vbs "s/^.*ppl1= //g"
echo.
echo.
echo luke-matthew
REM TO BE PROGRAMMED | findstr ppl | cscript //Nologo %SRILMPATH%\sed.vbs "s/^.*ppl1= //g"
echo.
echo luke-mark
REM TO BE PROGRAMMED | findstr ppl | cscript //Nologo %SRILMPATH%\sed.vbs "s/^.*ppl1= //g"
echo.
echo luke-john
REM TO BE PROGRAMMED | findstr ppl | cscript //Nologo %SRILMPATH%\sed.vbs "s/^.*ppl1= //g"

pause