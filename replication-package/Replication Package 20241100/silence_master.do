**************************************
* Spiral of Silence.                 *
* Last modified by: Yihong Huang     *
* Date: 08/20/2026                   *
* Version: 1                         *
**************************************
*
* Runs every Stata exhibit in the paper. Figure A.1 is produced separately by
* Code/Figure A1.ipynb -- see the README, section 6.
*
* TO REPLICATE: edit the one path below and run this file top to bottom.

version 18                  
clear all
set more off

* Change global userpath here

global userpath "/Users/yihong/Desktop/Replication Package 20241100" //Yihong
global data "$userpath/data"
global output "$userpath/Output"
global tempfile "$userpath/Tempfiles"
global code "$userpath/Code"
global logs "$userpath/logs"

cap mkdir "$logs"
cap mkdir "$output"
cap mkdir "$tempfile"

* Graph scheme, set here so that it does not depend on the order in which the
* figure scripts happen to be run.
set scheme s1mono

cap log close _all
log using "$logs/silence_master.log", replace text name(master)

*------------------------------------------------------------------------------
* LOGS
*
* The full run is captured in $logs/silence_master.log.
*
* Every exhibit writes a file to $output/ except Table D.15, which is displayed
* only. That one gets its own log below, $logs/Table_D15.log, which is the sole
* record of it; Code/Table D15.do documents which part of the output feeds each
* cell of the table.
*
* The master log is also where the SUEST rows of Table 2
*------------------------------------------------------------------------------

*** Main Experiment

do "$code/Figure 3.do"
do "$code/Table 1.do"
do "$code/Table 2.do"
do "$code/Table 3.do"
do "$code/Figure 4.do"
do "$code/Figure 5.do"

*** Main Experiment: Appendix Tables
do "$code/Table B1.do"

do "$code/Figure B2.do"

do "$code/Table C2.do"
do "$code/Table C3.do"
do "$code/Table C4.do"
do "$code/Table C5.do"
do "$code/Table C6.do"
do "$code/Table C7.do"
do "$code/Table C8.do"
do "$code/Table C9.do"
do "$code/Table C10.do"
do "$code/Table C11.do"       // requires Table 1.do above (uses first_movers_long.dta)

do "$code/Figure D4.do"
do "$code/Table D12.do"
do "$code/Table D13.do"
do "$code/Table D14.do"
do "$code/Figure D5.do"
log using "$logs/Table_D15.log", replace text name(exhibit)
do "$code/Table D15.do"       // sets its own seed; fmm is not reproducible without one
log close exhibit
do "$code/Table D16.do"
do "$code/Figure D6.do"
do "$code/Figure D7.do"

*** Extremity and Polarization
do "$code/Table E17.do"
do "$code/Table E18.do"
do "$code/Table E19.do"

*** Building Names
do "$code/Table E20.do"

*** Replication
do "$code/Figure E11.do"
do "$code/Table E21.do"
do "$code/Table E22.do"

*** ANES
do "$code/Table E23.do"

log close _all

* Figure A.1 is not produced here. Run Code/Figure A1.ipynb from the Code/
* directory after this file completes; it writes figure_A1.png to $output.
