cd "E:\HANDLS_PAPER65_HCY_COGN\DATA"


capture log close

log using "E:\HANDLS_PAPER65_HCY_COGN\OUTPUT\DATA_MANAGEMENT.smcl",replace



//STEP 0: CHECK ALL VARIABLES IN THE WAVES 1 AND 3 DATASETS//

use 2023-11-27_HcyCog,clear
capture rename HNDid HNDID
save, replace


use 2023-11-27_HcyCog,clear
keep if HNDwave==1
save 2023-11-27_HcyCog_wave1, replace
capture rename HNDid HNDID
save, replace


use 2023-11-27_HcyCog,clear
keep if HNDwave==3
capture rename HNDid HNDID
save 2023-11-27_HcyCog_wave3, replace


use 2023-11-27_HcyCog_wave1,clear

describe
su



use 2023-11-27_HcyCog_wave3,clear

describe
su

//STEP 1: CREATE WAVE 1 DEMOGRAPHIC VARIABLES//

use 2023-11-27_HcyCog_wave1,clear

keep HNDID HNDwave Race PovStat Sex Age 
capture rename HNDid HNDID
sort HNDID

save DEMOw1, replace

addstub Race PovStat Sex Age, stub(w1)

save, replace


//STEP 2: CREATE COGNITIVE DATA AT WAVES 1 AND 3, LONG//

*****COGNITIVE DATA AT WAVE 1**

use 2023-11-27_HcyCog_wave1,clear
capture rename HNDid HNDID

keep HNDID HNDwave CogTester-CVLtca WRATtotal tag*
sort HNDID

save COGNITIVE_TEST_SCORES_wave1long, replace


*****COGNITIVE DATA AT WAVE 3**


use 2023-11-27_HcyCog_wave3,clear
capture rename HNDid HNDID


keep HNDID HNDwave Attention-tagTrailsB 
sort HNDID

save COGNITIVE_TEST_SCORES_wave3long, replace


//STEP 3: CREATE WAVE 1 and WAVE 3 COGNITIVE DATA, WIDE//


*****COGNITIVE DATA AT WAVE 1**

use COGNITIVE_TEST_SCORES_wave1long, clear

keep HNDID CogTester-tagMMS WRATtotal 

addstub CogTester-tagMMS, stub(w1)

save COGNITIVE_TEST_SCORES_wave1wide, replace



*****COGNITIVE DATA AT WAVE 3**

use COGNITIVE_TEST_SCORES_wave3long, clear

keep HNDID Attention-tagTrailsB

addstub Attention-tagTrailsB, stub(w3)

save COGNITIVE_TEST_SCORES_wave3wide, replace


//STEP 4: MERGE AGEw1 with COGNITIVE DATA AT WAVE 1//

use 2023-11-27_HcyCog_wave1,clear
capture rename HNDid HNDID

keep HNDID Age
sort HNDID

save Agew1, replace
capture rename Age w1Age
save, replace

use COGNITIVE_TEST_SCORES_wave1long,clear
merge HNDID using Agew1

save COGNITIVE_TEST_SCORES_wave1longAgew1, replace



//STEP 5: MERGE AGEw3 with COGNITIVE DATA AT WAVE 1//
use 2023-11-27_HcyCog_wave3,clear
capture rename HNDid HNDID

keep HNDID Age
sort HNDID

save Agew3, replace
capture rename Age w3Age
save, replace

use COGNITIVE_TEST_SCORES_wave3long,clear
merge HNDID using Agew3

save COGNITIVE_TEST_SCORES_wave3longAgew3, replace



//STEP 6: APPEND LONG COGNITIVE DATA MERGED WITH AGE VARIABLES//

use COGNITIVE_TEST_SCORES_wave1longAgew1, clear

capture drop _merge

save, replace


use COGNITIVE_TEST_SCORES_wave3longAgew3, clear

capture drop _merge

save, replace

use COGNITIVE_TEST_SCORES_wave1longAgew1, clear
append using COGNITIVE_TEST_SCORES_wave3longAgew3

save COGNITIVE_TEST_SCORES_waves13_append, replace

keep HNDID HNDwave Attention BVRtot ClockCmd*  CVLca* CVLtc* CVLfrl CVLbet DigitSpanFwd DigitSpanBck FluencyWord MMStot TrailsAtestSec TrailsBtestSec WRATtotal tag*  

save COGNITIVE_TEST_SCORES_waves13_appendsmall, replace


//STEP 7: APPEND THE COGNITIVE TEST SCORES (LONG) WITH DEMO AT WAVE 1: CALL THIS LAYER HNDWAVE==0//

use DEMOw1, clear
recode HNDwave 1=0

save, replace

append using COGNITIVE_TEST_SCORES_waves13_appendsmall

save COGNITIVE_TEST_SCORES_waves13_appendsmallDEMOw1long, replace

sort HNDID

save, replace

use DEMOw1, clear
sort HNDID
capture drop HNDwave
save DEMOw1wide, replace

use COGNITIVE_TEST_SCORES_waves13_appendsmallDEMOw1long,clear
capture drop w1Sex w1Race w1PovStat w1Age 

merge HNDID using DEMOw1wide
save, replace

//STEP 8: MERGE WAVE 1 COGNITIVE TEST, WIDE WITH THE APPENDED DATA//
use  COGNITIVE_TEST_SCORES_waves13_appendsmallDEMOw1long,clear
capture drop _merge
sort HNDID
save, replace

use COGNITIVE_TEST_SCORES_wave1wide,clear
sort HNDID
save, replace

use  COGNITIVE_TEST_SCORES_waves13_appendsmallDEMOw1long,clear
merge HNDID using COGNITIVE_TEST_SCORES_wave1wide

tab _merge
capture drop _merge

save COGNITIVE_TEST_SCORE_DEMO_WIDEW1_APPENDED, replace


//STEP 9: MERGE WAVE 3 COGNITIVE TEST, WIDE WITH THE APPENDED DATA//
use  COGNITIVE_TEST_SCORE_DEMO_WIDEW1_APPENDED,clear
capture drop _merge
sort HNDID
save, replace

use COGNITIVE_TEST_SCORES_wave1wide,clear
sort HNDID
save, replace

use  COGNITIVE_TEST_SCORE_DEMO_WIDEW1_APPENDED,clear
merge HNDID using COGNITIVE_TEST_SCORES_wave3wide

tab _merge
capture drop _merge

save COGNITIVE_TEST_SCORE_DEMO_WIDEW1W3_APPENDED, replace


//STEP 10: MERGE THIS FILE WITH WAVE 3 AGE//
use 2023-11-27_HcyCog_wave3,clear

describe
su


keep HNDID Age
save Agew3, replace
capture rename Age w3Age
capture rename HNDid HNDID
sort HNDID
save, replace

use COGNITIVE_TEST_SCORE_DEMO_WIDEW1W3_APPENDED,clear
sort HNDID
capture drop _merge
save, replace

merge HNDID using Agew3
save, replace


//STEP 11: CREATE THE TIME VARIABLE BETWEEN WAVES 1 AND 3//

use COGNITIVE_TEST_SCORE_DEMO_WIDEW1W3_APPENDED,clear

capture drop timew1w3
gen timew1w3=.
replace timew1w3=0 if HNDwave==1
replace timew1w3=w3Age-w1Age if HNDwave==3

su timew1w3 if HNDwave==3

save, replace


****************************************************************************************
//STEP 12A: CREATE THE EXPOSURE VARIABLES AT WAVE 1//
use 2023-11-27_HcyCog_wave1,clear

describe
su


keep HNDID HCys


addstub HCys, stub(w1)

capture drop w1HCY
gen w1HCY=ln(w1HCys)


save HOMOCYSTEINE_EXPOSURES_W1,replace

            
//STEP 12B: CREATE THE EXPOSURE VARIABLES AT WAVE 3//

use 2023-11-27_HcyCog_wave3,clear

describe
su


keep HNDID HCys


addstub HCys, stub(w3)


capture drop w3HCY
gen w3HCY=ln(w3HCys)

save HOMOCYSTEINE_EXPOSURES_W3,replace



//STEP 12C: MERGE WAVES 1 AND 3 EXPOSURES WITH FINAL FILE///

use COGNITIVE_TEST_SCORE_DEMO_WIDEW1W3_APPENDED,clear
capture drop _merge
sort HNDID

save HANDLS_PAPER65_HCY_COGN, replace


use HOMOCYSTEINE_EXPOSURES_W1,clear
sort HNDID
capture drop _merge
save HOMOCYSTEINE_EXPOSURES_W1, replace


use HOMOCYSTEINE_EXPOSURES_W3,clear
sort HNDID
capture drop _merge
save HOMOCYSTEINE_EXPOSURES_W3, replace



use HANDLS_PAPER65_HCY_COGN
merge HNDID using HOMOCYSTEINE_EXPOSURES_W1
tab _merge
capture drop _merge
sort HNDID
merge HNDID using HOMOCYSTEINE_EXPOSURES_W3
tab _merge
capture drop _merge
sort HNDID
save HANDLS_PAPER65_HCY_COGN, replace


*********************************************************************************************************


//STEP 13: CREATE ALL OTHER COVARIATE VARIABLES AT WAVES 1 //

*************************WAVE 1 VARIABLES************************

use 2023-11-27_HcyCog_wave1,clear
capture rename HNDid HNDID
save, replace


///DEMOGRAPHICS//

keep HNDID Race PovStat Sex 
save DEMOGRAPHICS_wave1, replace
sort HNDID
save, replace

use HANDLS_PAPER65_HCY_COGN, clear
sort HNDID
capture drop _merge
save, replace


merge HNDID using DEMOGRAPHICS_wave1

save, replace


// EDUCATION//
use 2023-11-27_HcyCog_wave1,clear
capture rename HNDid HNDID
save, replace


keep HNDID Education
capture rename Education w1Education
save Educationw1, replace
sort HNDID
save,replace

use HANDLS_PAPER65_HCY_COGN,clear
sort HNDID
capture drop _merge
save, replace

merge HNDID using Educationw1
save, replace

tab w1Education if HNDwave==1

capture drop w1edubr
gen w1edubr=.
replace w1edubr=1 if w1Education>=1 & w1Education<=8
replace w1edubr=2 if w1Education>=9 & w1Education<=12
replace w1edubr=3 if w1Education>=13 & w1Education~=.

tab w1edubr if HNDwave==1
tab w1edubr w1Education

save, replace


//LIFESTYLE FACTORS: SMOKING AND DRUG USE: CigaretteStatus //

use 2023-11-27_HcyCog_wave1,clear
capture rename HNDid HNDID
save, replace


keep HNDID CigaretteStatus MarijCurr CokeCurr OpiateCurr
addstub CigaretteStatus MarijCurr CokeCurr OpiateCurr,stub(w1)
sort HNDID
save Smoke_drugsw1,replace


**Current smoking status**

tab  w1CigaretteStatus
su w1CigaretteStatus

capture drop w1smoke
gen w1smoke=.
replace w1smoke=1 if w1CigaretteStatus==4 
replace w1smoke=0 if w1CigaretteStatus~=4 & w1CigaretteStatus~=.
replace w1smoke=9 if w1smoke==.

tab1 w1smoke w1CigaretteStatus w1MarijCurr w1CokeCurr w1OpiateCurr

capture drop w1smoke1 w1smoke9
gen w1smoke1=1 if w1smoke==1
replace w1smoke1=0 if w1smoke~=1

gen w1smoke9=1 if w1smoke==9
replace w1smoke9=0 if w1smoke~=9

sort HNDID

save, replace


**Current drug use**

tab1 w1MarijCurr w1CokeCurr w1OpiateCurr

capture drop w1currdrugs
gen w1currdrugs=.
replace w1currdrugs=1 if w1MarijCurr==1 | w1CokeCurr==1 | w1OpiateCurr==1
replace w1currdrugs=0 if w1currdrugs~=1 & w1MarijCurr~=. & w1CokeCurr~=. & w1OpiateCurr~=.
replace w1currdrugs=9 if w1currdrugs==.

tab w1currdrugs

tab w1currdrugs w1MarijCurr
tab w1currdrugs w1CokeCurr
tab w1currdrugs w1OpiateCurr

save, replace


use HANDLS_PAPER65_HCY_COGN,clear
sort HNDID
capture drop _merge
save, replace

merge HNDID using Smoke_drugsw1
save, replace




//CES-D, BMI, SELF-RATED HEALTH AND CO-MORBIND CONDITIONS//



use 2023-11-27_HcyCog_wave1,clear
capture rename HNDid HNDID
save, replace


keep HNDID CES BMI SF01 dxHTN dxDiabetes CVhighChol CVaFib CVangina CVcad CVchf CVmi 

addstub SF01-CES,stub(w1)

save HEALTH_w1, replace

tab w1SF01


capture drop w1SRH
gen w1SRH=.
replace w1SRH=1 if w1SF01==1 | w1SF01==2
replace w1SRH=2 if w1SF01==3
replace w1SRH=3 if w1SF01==4 | w1SF01==5


tab w1SRH

save, replace

su w1dxHTN w1dxDiabetes

tab1 w1dxHTN w1dxDiabetes


tab1 w1CVhighChol 

save, replace

tab1  w1CVaFib w1CVangina w1CVcad w1CVchf w1CVmi

capture drop w1cvdbr
gen w1cvdbr=.
replace w1cvdbr=1 if w1CVaFib==2 | w1CVangina==2 | w1CVcad==2 | w1CVchf==2 | w1CVmi==2
replace w1cvdbr=0 if w1cvdbr~=1 & w1CVaFib~=. & w1CVangina~=. & w1CVcad~=. & w1CVchf~=. & w1CVmi~=.


tab w1cvdbr


sort HNDID
save, replace



use HANDLS_PAPER65_HCY_COGN,clear
sort HNDID
capture drop _merge
save, replace



merge HNDID using HEALTH_w1
save, replace


//HEI, Wave 1://


use 2023-11-27_HcyCog_wave1,clear
capture rename HNDid HNDID
save, replace


keep HNDID hei2010_total_score
addstub hei2010_total_score,stub(w1)
sort HNDID
save Otherdietarysw1,replace


su w1hei2010_total_score
histogram w1hei2010_total_score


use HANDLS_PAPER65_HCY_COGN,clear
sort HNDID
capture drop _merge
save, replace



merge HNDID using Otherdietarysw1
save, replace

****WRAT total*****

use 2023-11-27_HcyCog_wave1,clear
capture rename HNDid HNDID
save, replace


keep HNDID WRATtotal 
addstub WRATtotal,stub(w1)
sort HNDID
save WRATw1,replace


su w1WRATtotal
histogram w1WRATtotal


use HANDLS_PAPER65_HCY_COGN,clear
sort HNDID
capture drop _merge
save, replace



merge HNDID using WRATw1
save HANDLS_PAPER65_HCY_COGN, replace



***FOLATE AND B12***********

use 2023-11-27_HcyCog_wave1,clear
capture rename HNDid HNDID
save, replace


keep HNDID Folate B12 Folate_total_d1 Folate_total_d2 VitaminB12_d1 VitaminB12_d2
addstub Folate B12 Folate_total_d1 Folate_total_d2 VitaminB12_d1 VitaminB12_d2,stub(w1)
sort HNDID
save Folate_B12w1,replace

su w1Folate
histogram w1Folate
su w1B12
histogram w1B12

capture drop w1Folate_total
gen w1Folate_total=(w1Folate_total_d1 + w1Folate_total_d2)/2
su w1Folate_total
histogram w1Folate_total

capture drop w1VitaminB12
gen w1VitaminB12=(w1VitaminB12_d1 + w1VitaminB12_d2)/2
su w1VitaminB12
histogram w1VitaminB12

sort HNDID
capture drop _merge
save, replace


use HANDLS_PAPER65_HCY_COGN,clear
sort HNDID
capture drop _merge
save, replace



merge HNDID using Folate_B12w1
save HANDLS_PAPER65_HCY_COGN, replace



//STEP 14: CREATE ALL COGNITIVE TEST SCORES AND THEIR SELECTION VARIABLES//


use HANDLS_PAPER65_HCY_COGN,clear
sort HNDID
capture drop _merge
save, replace



**MMSE total score**

capture drop selectmms
gen selectmms=.
replace selectmms=1 if tagMMS==1 & MMStot~=.
replace selectmms=0 if selectmms~=1 & MMStot~=.
tab selectmms


su MMStot if selectmms==1


capture drop w1selectmms
gen w1selectmms=.
replace w1selectmms=1 if w1tagMMS==1 & w1MMStot~=.
replace w1selectmms=0 if w1selectmms~=1 & w1MMStot~=.
tab w1selectmms


su w1MMStot if w1selectmms==1
su w1MMStot if w1selectmms==1 & HNDwave==1


capture drop w3selectmms
gen w3selectmms=.
replace w3selectmms=1 if w3tagMMS==1 & w3MMStot~=.
replace w3selectmms=0 if w3selectmms~=1 & w3MMStot~=.
tab w3selectmms


su w3MMStot if w3selectmms==1
su w3MMStot if w3selectmms==1 & HNDwave==3


**CVLT, LIST A, Immediate Recall**

capture drop selectcvltca
gen selectcvltca=.
replace selectcvltca=1 if tagCVLca1==1 & tagCVLca2==1 & tagCVLca3==1 & CVLca1~=. & CVLca2~=. & CVLca3~=.
replace selectcvltca=0 if selectcvltca~=1 & CVLca1~=. & CVLca2~=. & CVLca3~=.
tab selectcvltca

capture drop cvltca
gen cvltca=CVLca1+CVLca2+CVLca3

su cvltca if selectcvltca==1
su cvltca if selectcvltca==1 & HNDwave==1
su cvltca if selectcvltca==1 & HNDwave==3

capture drop w1selectcvltca
gen w1selectcvltca=.
replace w1selectcvltca=1 if w1tagCVLca1==1 & w1tagCVLca2==1 & w1tagCVLca3==1 & w1CVLca1~=. & w1CVLca2~=. & w1CVLca3~=.
replace w1selectcvltca=0 if w1selectcvltca~=1 & w1CVLca1~=. & w1CVLca2~=. & w1CVLca3~=.
tab w1selectcvltca

capture drop w1cvltca
gen w1cvltca=w1CVLca1+w1CVLca2+w1CVLca3

su w1cvltca if w1selectcvltca==1
su w1cvltca if w1selectcvltca==1 & HNDwave==1

capture drop w3selectcvltca
gen w3selectcvltca=.
replace w3selectcvltca=1 if w3tagCVLca1==1 & w3tagCVLca2==1 & w3tagCVLca3==1 & w3CVLca1~=. & w3CVLca2~=. & w3CVLca3~=.
replace w3selectcvltca=0 if w3selectcvltca~=1 & w3CVLca1~=. & w3CVLca2~=. & w3CVLca3~=.
tab w3selectcvltca

capture drop w3cvltca
gen w3cvltca=w3CVLca1+w3CVLca2+w3CVLca3

su w3cvltca if w3selectcvltca==1
su w3cvltca if w3selectcvltca==1 & HNDwave==3


**CVLT, Free long recall**

capture drop selectcvlfrl
gen selectcvlfrl=.
replace selectcvlfrl=1 if CVLfrl~=. & tagCVLfrl==1
replace selectcvlfrl=0 if selectcvlfrl~=1 & CVLfrl~=.
tab selectcvlfrl

su CVLfrl if selectcvlfrl==1
su CVLfrl if selectcvlfrl==1 & HNDwave==1
su CVLfrl if selectcvlfrl==1 & HNDwave==3

capture drop w1selectcvlfrl
gen w1selectcvlfrl=.
replace w1selectcvlfrl=1 if w1CVLfrl~=. & w1tagCVLfrl==1
replace w1selectcvlfrl=0 if w1selectcvlfrl~=1 & w1CVLfrl~=.
tab w1selectcvlfrl

su w1CVLfrl if w1selectcvlfrl==1
su w1CVLfrl if w1selectcvlfrl==1 & HNDwave==1

capture drop w3selectcvlfrl
gen w3selectcvlfrl=.
replace w3selectcvlfrl=1 if w3CVLfrl~=. & w3tagCVLfrl==1
replace w3selectcvlfrl=0 if w3selectcvlfrl~=1 & w3CVLfrl~=.
tab w3selectcvlfrl

su w3CVLfrl if w3selectcvlfrl==1
su w3CVLfrl if w3selectcvlfrl==1 & HNDwave==3

save,replace


**BVRT**  

capture drop selectBVRtot
gen selectBVRtot=.
replace selectBVRtot=1 if BVRtot~=. & tagBVR==1
replace selectBVRtot=0 if selectBVRtot~=1 & BVRtot~=.
tab selectBVRtot

su BVRtot if selectBVRtot==1
su BVRtot if selectBVRtot==1 & HNDwave==1
su BVRtot if selectBVRtot==1 & HNDwave==3


capture drop w1selectBVRtot
gen w1selectBVRtot=.
replace w1selectBVRtot=1 if w1BVRtot~=. & w1tagBVR==1
replace w1selectBVRtot=0 if w1selectBVRtot~=1 & w1BVRtot~=.
tab w1selectBVRtot

su w1BVRtot if w1selectBVRtot==1
su w1BVRtot if w1selectBVRtot==1 & HNDwave==1


capture drop w3selectBVRtot
gen w3selectBVRtot=.
replace w3selectBVRtot=1 if w3BVRtot~=. & w3tagBVR==1
replace w3selectBVRtot=0 if w3selectBVRtot~=1 & w3BVRtot~=.
tab w3selectBVRtot

su w3BVRtot if w3selectBVRtot==1
su w3BVRtot if w3selectBVRtot==1 & HNDwave==3



**Attention**
capture drop selectAttention
gen selectAttention=.
replace selectAttention=1 if Attention~=. & tagAttention==1
replace selectAttention=0 if selectAttention~=1 & Attention~=.
tab selectAttention

su Attention if selectAttention==1
su Attention if selectAttention==1 & HNDwave==1
su Attention if selectAttention==1 & HNDwave==3

capture drop w1selectAttention
gen w1selectAttention=.
replace w1selectAttention=1 if w1Attention~=. & w1tagAttention==1
replace w1selectAttention=0 if w1selectAttention~=1 & w1Attention~=.
tab w1selectAttention

su w1Attention if w1selectAttention==1
su w1Attention if w1selectAttention==1 & HNDwave==1

capture drop w3selectAttention
gen w3selectAttention=.
replace w3selectAttention=1 if w3Attention~=. & w3tagAttention==1
replace w3selectAttention=0 if w3selectAttention~=1 & w3Attention~=.
tab w3selectAttention

su w3Attention if w3selectAttention==1
su w3Attention if w3selectAttention==1 & HNDwave==3


**Word Fluency**
capture drop selectFluencyWord
gen selectFluencyWord=.
replace selectFluencyWord=1 if FluencyWord~=. & tagFluency==1
replace selectFluencyWord=0 if selectFluencyWord~=1 & FluencyWord~=.
tab selectFluencyWord

su FluencyWord if selectFluencyWord==1
su FluencyWord if selectFluencyWord==1 & HNDwave==1
su FluencyWord if selectFluencyWord==1 & HNDwave==3


capture drop w1selectFluencyWord
gen w1selectFluencyWord=.
replace w1selectFluencyWord=1 if w1FluencyWord~=. & w1tagFluency==1
replace w1selectFluencyWord=0 if w1selectFluencyWord~=1 & w1FluencyWord~=.
tab w1selectFluencyWord

su w1FluencyWord if w1selectFluencyWord==1
su w1FluencyWord if w1selectFluencyWord==1 & HNDwave==1

capture drop w3selectFluencyWord
gen w3selectFluencyWord=.
replace w3selectFluencyWord=1 if w3FluencyWord~=. & w3tagFluency==1
replace w3selectFluencyWord=0 if w3selectFluencyWord~=1 & w3FluencyWord~=.
tab w3selectFluencyWord

su w3FluencyWord if w3selectFluencyWord==1
su w3FluencyWord if w3selectFluencyWord==1 & HNDwave==3


save, replace




**Digits Span forward**
capture drop selectDigitSpanFwd
gen selectDigitSpanFwd=.
replace selectDigitSpanFwd=1 if DigitSpanFwd~=. & tagDigSpanFwd==1
replace selectDigitSpanFwd=0 if selectDigitSpanFwd~=1 & DigitSpanFwd~=.
tab selectDigitSpanFwd

su DigitSpanFwd if selectDigitSpanFwd==1
su DigitSpanFwd if selectDigitSpanFwd==1 & HNDwave==1
su DigitSpanFwd if selectDigitSpanFwd==1 & HNDwave==3

capture drop w1selectDigitSpanFwd
gen w1selectDigitSpanFwd=.
replace w1selectDigitSpanFwd=1 if w1DigitSpanFwd~=. & w1tagDigSpanFwd==1
replace w1selectDigitSpanFwd=0 if w1selectDigitSpanFwd~=1 & w1DigitSpanFwd~=.
tab selectDigitSpanFwd

su w1DigitSpanFwd if w1selectDigitSpanFwd==1
su w1DigitSpanFwd if w1selectDigitSpanFwd==1 & HNDwave==1

capture drop w3selectDigitSpanFwd
gen w3selectDigitSpanFwd=.
replace w3selectDigitSpanFwd=1 if w3DigitSpanFwd~=. & w3tagDigSpanFwd==1
replace w3selectDigitSpanFwd=0 if w3selectDigitSpanFwd~=1 & w3DigitSpanFwd~=.
tab selectDigitSpanFwd

su w3DigitSpanFwd if w3selectDigitSpanFwd==1
su w3DigitSpanFwd if w3selectDigitSpanFwd==1 & HNDwave==3


save, replace



**Digits Span backward**
capture drop selectDigitSpanBck
gen selectDigitSpanBck=.
replace selectDigitSpanBck=1 if DigitSpanBck~=. & tagDigSpanBck==1
replace selectDigitSpanBck=0 if selectDigitSpanBck~=1 & DigitSpanBck~=.
tab selectDigitSpanBck

su DigitSpanBck if selectDigitSpanBck==1
su DigitSpanBck if selectDigitSpanBck==1 & HNDwave==1
su DigitSpanBck if selectDigitSpanBck==1 & HNDwave==3

capture drop w1selectDigitSpanBck
gen w1selectDigitSpanBck=.
replace w1selectDigitSpanBck=1 if w1DigitSpanBck~=. & w1tagDigSpanBck==1
replace w1selectDigitSpanBck=0 if w1selectDigitSpanBck~=1 & w1DigitSpanBck~=.
tab w1selectDigitSpanBck

su w1DigitSpanBck if w1selectDigitSpanBck==1
su w1DigitSpanBck if w1selectDigitSpanBck==1 & HNDwave==1


capture drop w3selectDigitSpanBck
gen w3selectDigitSpanBck=.
replace w3selectDigitSpanBck=1 if w3DigitSpanBck~=. & w3tagDigSpanBck==1
replace w3selectDigitSpanBck=0 if w3selectDigitSpanBck~=1 & w3DigitSpanBck~=.
tab w3selectDigitSpanBck

su w3DigitSpanBck if w3selectDigitSpanBck==1
su w3DigitSpanBck if w3selectDigitSpanBck==1 & HNDwave==1

save, replace

**Clock command**
capture drop clock_command
gen clock_command=ClockCmdFace+ClockCmdHand+ClockCmdNumb

capture drop selectclock_command
gen selectclock_command=.
replace selectclock_command=1 if clock_command~=. & tagClock==1
replace selectclock_command=0 if selectclock_command~=1 & clock_command~=.
tab selectclock_command

su clock_command if selectclock_command==1



capture drop w1clock_command
gen w1clock_command=w1ClockCmdFace+w1ClockCmdHand+w1ClockCmdNumb

capture drop w1selectclock_command
gen w1selectclock_command=.
replace w1selectclock_command=1 if w1clock_command~=. & w1tagClock==1
replace w1selectclock_command=0 if w1selectclock_command~=1 & w1clock_command~=.
tab w1selectclock_command

su w1clock_command if w1selectclock_command==1
su w1clock_command if w1selectclock_command==1 & HNDwave==1


capture drop w3clock_command
gen w3clock_command=w3ClockCmdFace+w3ClockCmdHand+w3ClockCmdNumb

capture drop w3selectclock_command
gen w3selectclock_command=.
replace w3selectclock_command=1 if w3clock_command~=. & w3tagClock==1
replace w3selectclock_command=0 if w3selectclock_command~=1 & w3clock_command~=.
tab w3selectclock_command

su w3clock_command if w3selectclock_command==1 & HNDwave==3

save, replace


**TRAILS, COMBINED TAGS**
capture drop trailsatagw1w3
gen trailsatagw1w3=.
replace trailsatagw1w3=tagTrails if HNDwave==1 
replace trailsatagw1w3=tagTrailsA if HNDwave==3 


capture drop trailsbtagw1w3
gen trailsbtagw1w3=.
replace trailsbtagw1w3=tagTrails if HNDwave==1 
replace trailsbtagw1w3=tagTrailsB if HNDwave==3 


tab1 trailsatagw1w3 trailsbtagw1w3




**TRAILS A**
capture drop selectTrailsAtestSec
gen selectTrailsAtestSec=.
replace selectTrailsAtestSec=1 if TrailsAtestSec~=. & trailsatagw1w3==1
replace selectTrailsAtestSec=0 if selectTrailsAtestSec~=1 & TrailsAtestSec~=.
tab selectTrailsAtestSec

su TrailsAtestSec if selectTrailsAtestSec==1
su TrailsAtestSec if selectTrailsAtestSec==1 & HNDwave==1
su TrailsAtestSec if selectTrailsAtestSec==1 & HNDwave==3

capture drop w1selectTrailsAtestSec
gen w1selectTrailsAtestSec=.
replace w1selectTrailsAtestSec=1 if w1TrailsAtestSec~=. & trailsatagw1w3==1
replace w1selectTrailsAtestSec=0 if w1selectTrailsAtestSec~=1 & w1TrailsAtestSec~=.
tab w1selectTrailsAtestSec

su w1TrailsAtestSec if w1selectTrailsAtestSec==1
su w1TrailsAtestSec if w1selectTrailsAtestSec==1 & HNDwave==1

capture drop w3selectTrailsAtestSec
gen w3selectTrailsAtestSec=.
replace w3selectTrailsAtestSec=1 if w3TrailsAtestSec~=. & trailsatagw1w3==1
replace w3selectTrailsAtestSec=0 if w3selectTrailsAtestSec~=1 & w3TrailsAtestSec~=.
tab w3selectTrailsAtestSec

su w3TrailsAtestSec if w3selectTrailsAtestSec==1
su w3TrailsAtestSec if w3selectTrailsAtestSec==1 & HNDwave==3




**TRAILS B**

capture drop selectTrailsBtestSec 
gen selectTrailsBtestSec=. 
replace selectTrailsBtestSec=1 if TrailsBtestSec~=. &  trailsbtagw1w3==1
replace selectTrailsBtestSec=0 if selectTrailsBtestSec~=1 & TrailsAtestSec~=.
tab selectTrailsBtestSec 

su TrailsBtestSec  if selectTrailsBtestSec==1
su TrailsBtestSec  if selectTrailsBtestSec==1 & HNDwave==1
su TrailsBtestSec  if selectTrailsBtestSec==1 & HNDwave==3



capture drop w1selectTrailsBtestSec 
gen w1selectTrailsBtestSec=. 
replace w1selectTrailsBtestSec=1 if w1TrailsBtestSec~=. &  trailsbtagw1w3==1
replace w1selectTrailsBtestSec=0 if w1selectTrailsBtestSec~=1 & w1TrailsAtestSec~=.
tab w1selectTrailsBtestSec 

su w1TrailsBtestSec  if w1selectTrailsBtestSec==1
su w1TrailsBtestSec  if w1selectTrailsBtestSec==1 & HNDwave==1


capture drop w3selectTrailsBtestSec 
gen w3selectTrailsBtestSec=. 
replace w3selectTrailsBtestSec=1 if w3TrailsBtestSec~=. &  trailsbtagw1w3==1
replace w3selectTrailsBtestSec=0 if w3selectTrailsBtestSec~=1 & w3TrailsAtestSec~=.
tab w3selectTrailsBtestSec 

su w3TrailsBtestSec  if w3selectTrailsBtestSec==1
su w3TrailsBtestSec  if w3selectTrailsBtestSec==1 & HNDwave==1


save, replace






**WRATT**
capture drop w1selectWRATtotal
gen w1selectWRATtotal=.
replace w1selectWRATtotal=1 if w1WRATtotal~=. 
replace w1selectWRATtotal=0 if w1selectWRATtotal~=1 & w1WRATtotal~=.

tab w1selectWRATtotal

su w1WRATtotal if w1selectWRATtotal==1
su w1WRATtotal if w1selectWRATtotal==1 & HNDwave==1


capture drop _merge
sort HNDID
save, replace

//STEP 15A: RENAME FIXED COVARIATES///


use HANDLS_PAPER65_HCY_COGN,clear
sort HNDID
capture drop _merge
save, replace

capture rename w1Sex Sex
capture rename w1Race Race
capture rename w1PovStat PovStat

save, replace



//STEP 15B: CREATE EMPIRICAL BAYES ESTIMATORS FOR EACH COGNITIVE TEST SCORE: MIXED MODEL WITH TIME AS THE ONLY COVARIATE: RESTRICT TO RELIABLE SCORES//




**MMSE**

**Model 1: unadjusted**

xtmixed MMStot timew1w3 if selectmms==1 ||HNDID: timew1w3, cov(un)


capture drop e_consMMSE e_TIMEMMSE
predict  e_TIMEMMSE e_consMMSE if selectmms==1, reffects level(HNDID)

estat ic

capture drop bayes1MMSE
gen bayes1MMSE= .0002699+e_TIMEMMSE


su bayes1MMSE if selectmms==1 


su bayes1MMSE if selectmms==1 & HNDwave==1,det
su bayes1MMSE if selectmms==1 & HNDwave==3,det


histogram bayes1MMSE if selectmms==1 & HNDwave==1


**Normalized MMSE**
capture drop MMStotnorm
gen MMStotnorm=.
replace MMStotnorm=0 if MMStot==0
replace MMStotnorm=2.91 if MMStot==1
replace MMStotnorm=5.48 if MMStot==2
replace MMStotnorm=7.76 if MMStot==3
replace MMStotnorm=9.77 if MMStot==4
replace MMStotnorm=11.57 if MMStot==5
replace MMStotnorm=13.19 if MMStot==6
replace MMStotnorm=14.67 if MMStot==7
replace MMStotnorm=16.05 if MMStot==8
replace MMStotnorm=17.37 if MMStot==9
replace MMStotnorm=18.68 if MMStot==10
replace MMStotnorm=20.01 if MMStot==11
replace MMStotnorm=21.38 if MMStot==12
replace MMStotnorm=22.83 if MMStot==13
replace MMStotnorm=24.39 if MMStot==14
replace MMStotnorm=26.07 if MMStot==15
replace MMStotnorm=27.91 if MMStot==16
replace MMStotnorm=29.93 if MMStot==17
replace MMStotnorm=32.17 if MMStot==18
replace MMStotnorm=34.64 if MMStot==19
replace MMStotnorm=37.37 if MMStot==20
replace MMStotnorm=40.40 if MMStot==21
replace MMStotnorm=43.70 if MMStot==22
replace MMStotnorm=47.40 if MMStot==23
replace MMStotnorm=51.44 if MMStot==24
replace MMStotnorm=55.98 if MMStot==25
replace MMStotnorm=61.18 if MMStot==26
replace MMStotnorm=67.25 if MMStot==27
replace MMStotnorm=74.61 if MMStot==28
replace MMStotnorm=84.32 if MMStot==29
replace MMStotnorm=100 if MMStot==30

save, replace


xtmixed MMStotnorm timew1w3 if selectmms==1 ||HNDID: timew1w3


capture drop e_consMMSEnorm e_TIMEMMSEnorm
predict  e_TIMEMMSEnorm e_consMMSEnorm if selectmms==1, reffects level(HNDID)

estat ic

capture drop bayes1MMSEnorm
gen bayes1MMSEnorm=  -.1857864 +e_TIMEMMSEnorm


su bayes1MMSEnorm if selectmms==1 


su bayes1MMSEnorm if selectmms==1 & HNDwave==1,det
su bayes1MMSEnorm if selectmms==1 & HNDwave==3,det

histogram bayes1MMSEnorm if selectmms==1 & HNDwave==1

corr bayes1MMSEnorm bayes1MMSE if HNDwave==1


**CVLT, LIST A, Immediate Recall**

xtmixed cvltca timew1w3 if selectcvltca==1 ||HNDID: timew1w3, cov(un)


capture drop e_conscvltca e_TIMEcvltca
predict  e_TIMEcvltca e_conscvltca if selectcvltca==1, reffects level(HNDID)


capture drop bayes1cvltca
gen bayes1cvltca=   -1.140392 +e_TIMEcvltca

su bayes1cvltca if selectcvltca==1 

su bayes1cvltca if selectcvltca==1 

su bayes1cvltca if selectcvltca==1 & HNDwave==1
su bayes1cvltca if selectcvltca==1 & HNDwave==3

histogram bayes1cvltca if selectcvltca==1 & HNDwave==1

**CVLT, FRL**


xtmixed CVLfrl timew1w3 if selectcvlfrl==1 ||HNDID: timew1w3, cov(un)


capture drop e_consCVLfrl e_TIMECVLfrl
predict  e_TIMECVLfrl e_consCVLfrl if selectcvlfrl==1, reffects level(HNDID)


capture drop bayes1CVLfrl
gen bayes1CVLfrl=   -.3917931  +e_TIMECVLfrl


su bayes1CVLfrl if selectcvlfrl==1 


su bayes1CVLfrl if selectcvlfrl==1 & HNDwave==1
su bayes1CVLfrl if selectcvlfrl==1 & HNDwave==3

histogram bayes1CVLfrl if selectcvlfrl==1 & HNDwave==1


**BVRT**  

xtmixed BVRtot timew1w3 if selectBVRtot==1 ||HNDID: timew1w3, cov(un)


capture drop e_consBVRtot e_TIMEBVRtot
predict  e_TIMEBVRtot e_consBVRtot if selectBVRtot==1, reffects level(HNDID)


capture drop bayes1BVRtot
gen bayes1BVRtot=   .4328822   +e_TIMEBVRtot


su bayes1BVRtot if selectBVRtot==1 


su bayes1BVRtot if selectBVRtot==1 & HNDwave==1
su bayes1BVRtot if selectBVRtot==1 & HNDwave==3

histogram bayes1BVRtot if selectBVRtot==1 & HNDwave==1


**Attention**
xtmixed Attention timew1w3 if selectAttention==1 ||HNDID: timew1w3, cov(un)


capture drop e_consAttention e_TIMEAttention
predict e_TIMEAttention e_consAttention if selectAttention==1, reffects level(HNDID)


capture drop bayes1Attention
gen bayes1Attention=   -.0586604   +e_TIMEAttention

su bayes1Attention if selectAttention==1 

su bayes1Attention if selectAttention==1 & HNDwave==1
su bayes1Attention if selectAttention==1 & HNDwave==3

histogram bayes1Attention if selectAttention==1 & HNDwave==1

**Animal Fluency**
mixed FluencyWord timew1w3 if selectFluencyWord==1 ||HNDID: timew1w3


capture drop e_consFluencyWord e_TIMEFluencyWord
predict e_TIMEFluencyWord e_consFluencyWord if selectFluencyWord==1, reffects


capture drop bayes1FluencyWord
gen bayes1FluencyWord=    .0311311   +e_TIMEFluencyWord

su bayes1FluencyWord if selectFluencyWord==1 

su bayes1FluencyWord if selectFluencyWord==1 & HNDwave==1
su bayes1FluencyWord if selectFluencyWord==1 & HNDwave==3

**Digits Span forward**
xtmixed DigitSpanFwd timew1w3 if selectDigitSpanFwd==1 ||HNDID: timew1w3, cov(un)


capture drop e_consDigitSpanFwd e_TIMEDigitSpanFwd
predict e_TIMEDigitSpanFwd e_consDigitSpanFwd if selectDigitSpanFwd==1, reffects level(HNDID)


capture drop bayes1DigitSpanFwd
gen bayes1DigitSpanFwd=     -.0147174   +e_TIMEDigitSpanFwd

su bayes1DigitSpanFwd if selectDigitSpanFwd==1 

su bayes1DigitSpanFwd if selectDigitSpanFwd==1 & HNDwave==1
su bayes1DigitSpanFwd if selectDigitSpanFwd==1 & HNDwave==3

**Digits Span backward**


xtmixed DigitSpanBck timew1w3 if selectDigitSpanBck==1 ||HNDID: timew1w3, cov(un)


capture drop e_consDigitSpanBck e_TIMEDigitSpanBck
predict  e_TIMEDigitSpanBck e_consDigitSpanBck if selectDigitSpanBck==1, reffects level(HNDID)


capture drop bayes1DigitSpanBck
gen bayes1DigitSpanBck=     -.0201533   +e_TIMEDigitSpanBck

su bayes1DigitSpanBck if selectDigitSpanBck==1 

su bayes1DigitSpanBck if selectDigitSpanBck==1 & HNDwave==1
su bayes1DigitSpanBck if selectDigitSpanBck==1 & HNDwave==3

**Clock command**
xtmixed clock_command timew1w3 if selectclock_command==1 ||HNDID: timew1w3, cov(un)


capture drop e_consclock_command e_TIMEclock_command
predict  e_TIMEclock_command e_consclock_command if selectclock_command==1, reffects level(HNDID)


capture drop bayes1clock_command
gen bayes1clock_command=      -.0175067   +e_TIMEclock_command

su bayes1clock_command if selectclock_command==1 

su bayes1clock_command if selectclock_command==1 & HNDwave==1
su bayes1clock_command if selectclock_command==1 & HNDwave==3


**Trails A: LnTrailsAtestSec**
capture drop LnTrailsAtestSec
gen LnTrailsAtestSec=ln(TrailsAtestSec)

xtmixed LnTrailsAtestSec timew1w3 if selectTrailsAtestSec==1 ||HNDID: timew1w3, cov(un)


capture drop e_consLnTrailsAtestSec e_TIMELnTrailsAtestSec
predict e_TIMELnTrailsAtestSec e_consLnTrailsAtestSec if selectTrailsAtestSec==1, reffects level(HNDID)


capture drop bayes1LnTrailsAtestSec
gen bayes1LnTrailsAtestSec=        .0062478   +e_TIMELnTrailsAtestSec

su bayes1LnTrailsAtestSec if selectTrailsAtestSec==1 

su bayes1LnTrailsAtestSec if selectTrailsAtestSec==1 & HNDwave==1
su bayes1LnTrailsAtestSec if selectTrailsAtestSec==1 & HNDwave==3




**Trails B: LnTrailsBtestSec**
capture drop LnTrailsBtestSec
gen LnTrailsBtestSec=ln(TrailsBtestSec)



xtmixed LnTrailsBtestSec timew1w3 if selectTrailsBtestSec==1 ||HNDID: timew1w3, cov(un)


capture drop e_consLnTrailsBtestSec e_TIMELnTrailsBtestSec
predict  e_TIMELnTrailsBtestSec e_consLnTrailsBtestSec if selectTrailsBtestSec==1, reffects level(HNDID)


capture drop bayes1LnTrailsBtestSec
gen bayes1LnTrailsBtestSec=       .0028168   +e_TIMELnTrailsBtestSec

su bayes1LnTrailsBtestSec if selectTrailsBtestSec==1 

su bayes1LnTrailsBtestSec if selectTrailsBtestSec==1 & HNDwave==1
su bayes1LnTrailsBtestSec if selectTrailsBtestSec==1 & HNDwave==3


save, replace

//STEP 16: COLLAPSE THE EMPIRICAL BAYES ESTIMATORS AND RE-MERGE WITH DATA//

use HANDLS_PAPER65_HCY_COGN,clear

keep HNDID bayes1*

save bayes1_cognchange, replace

collapse (mean) bayes1*, by(HNDID)

save bayes1_cognchange_collapse, replace

addstub bayes1*, stub(w1w3)

sort HNDID
save, replace

use HANDLS_PAPER65_HCY_COGN,clear
capture drop _merge
sort HNDID
save, replace

merge HNDID using bayes1_cognchange_collapse
tab _merge
capture drop _merge
sort HNDID
save, replace


//STEP 17: CREATE STEPWISE SELECTION PROCESS FOR FLOWCHART//

**Initial wave 1 sample: SAMPLE1**

capture drop sample1
gen sample1=1 if w1Age~=.
replace sample1=0 if sample1~=1

tab sample1
tab sample1 if HNDwave==1

**Sample with complete w1 HOMOCYSTEINE  exposure data: SAMPLE2**

capture drop sample2
gen sample2=1 if w1HCY~=.
replace sample2=0 if sample2~=1

tab sample2
tab sample2 if HNDwave==1



save, replace 

**Samples with complete and reliable cognitive performance data at waves 1 and/or 3: SAMPLE3 SERIES**

**MMSE: sample3a**

use HANDLS_PAPER65_HCY_COGN,clear

keep HNDID selectmms

save selectmms, replace
collapse (mean) selectmms, by(HNDID)

save selectmms_collapse, replace
sort HNDID
addstub selectmms, stub(w1w3)
save, replace

use HANDLS_PAPER65_HCY_COGN,clear
capture drop _merge
sort HNDID

merge HNDID using selectmms_collapse
tab _merge
capture drop _merge
sort HNDID

save, replace


capture drop sample3aobs
gen sample3aobs=.
replace sample3aobs=1 if w1w3selectmms==1 & selectmms==1 & HNDwave==1 | w1w3selectmms==1 & selectmms==1  & HNDwave==3 |w1w3selectmms==0.5 & selectmms==1 & HNDwave==1 | w1w3selectmms==0.5 & selectmms==1 & HNDwave==3
replace sample3aobs=0 if sample3aobs~=1 

capture drop sample3apart
gen sample3apart=1 if w1w3selectmms==1 &  HNDwave==1 | w1w3selectmms==1 &  HNDwave==3 |w1w3selectmms==0.5 &  HNDwave==1 | w1w3selectmms==0.5 & HNDwave==3
replace sample3apart=0 if sample3apart~=1 

tab sample3aobs if HNDwave==1  | HNDwave==3  
tab sample3apart if HNDwave==1


xtmixed MMStotnorm timew1w3 if selectmms==1 || HNDID: timew1w3

save, replace

**CVLT-LIST A: sample3b**

use HANDLS_PAPER65_HCY_COGN,clear

keep HNDID selectcvltca

save selectcvltca, replace
collapse (mean) selectcvltca, by(HNDID)

save selectcvltca_collapse, replace
sort HNDID
addstub selectcvltca, stub(w1w3)
save, replace

use HANDLS_PAPER65_HCY_COGN,clear
capture drop _merge
sort HNDID

merge HNDID using selectcvltca_collapse
tab _merge
capture drop _merge
sort HNDID

save, replace


capture drop sample3bobs
gen sample3bobs=.
replace sample3bobs=1 if w1w3selectcvltca==1 & selectcvltca==1 & HNDwave==1 | w1w3selectcvltca==1 & selectcvltca==1  & HNDwave==3 |w1w3selectcvltca==0.5 & selectcvltca==1 & HNDwave==1 | w1w3selectcvltca==0.5 & selectcvltca==1 & HNDwave==3
replace sample3bobs=0 if sample3bobs~=1 

capture drop sample3bpart
gen sample3bpart=1 if w1w3selectcvltca==1 &  HNDwave==1 | w1w3selectcvltca==1 &  HNDwave==3 |w1w3selectcvltca==0.5 &  HNDwave==1 | w1w3selectcvltca==0.5 & HNDwave==3
replace sample3bpart=0 if sample3bpart~=1 

tab sample3bobs if HNDwave==1  | HNDwave==3  
tab sample3bpart if HNDwave==1


xtmixed cvltca timew1w3 if selectcvltca==1 || HNDID: timew1w3

save, replace


**CVLT-FRL: sample3c**

use HANDLS_PAPER65_HCY_COGN,clear

keep HNDID selectcvlfrl

save selectcvlfrl, replace
collapse (mean) selectcvlfrl, by(HNDID)

save selectcvlfrl_collapse, replace
sort HNDID
addstub selectcvlfrl, stub(w1w3)
save, replace

use HANDLS_PAPER65_HCY_COGN,clear
capture drop _merge
sort HNDID

merge HNDID using selectcvlfrl_collapse
tab _merge
capture drop _merge
sort HNDID

save, replace


capture drop sample3cobs
gen sample3cobs=.
replace sample3cobs=1 if w1w3selectcvlfrl==1 & selectcvlfrl==1 & HNDwave==1 | w1w3selectcvlfrl==1 & selectcvlfrl==1  & HNDwave==3 |w1w3selectcvlfrl==0.5 & selectcvlfrl==1 & HNDwave==1 | w1w3selectcvlfrl==0.5 & selectcvlfrl==1 & HNDwave==3
replace sample3cobs=0 if sample3cobs~=1 

capture drop sample3cpart
gen sample3cpart=1 if w1w3selectcvlfrl==1 &  HNDwave==1 | w1w3selectcvlfrl==1 &  HNDwave==3 |w1w3selectcvlfrl==0.5 &  HNDwave==1 | w1w3selectcvlfrl==0.5 & HNDwave==3
replace sample3cpart=0 if sample3cpart~=1 

tab sample3cobs if HNDwave==1  | HNDwave==3  
tab sample3cpart if HNDwave==1


xtmixed CVLfrl timew1w3 if selectcvlfrl==1 || HNDID: timew1w3

save, replace



**BVRT: sample3d**

use HANDLS_PAPER65_HCY_COGN,clear

keep HNDID selectBVRtot

save selectBVRtot, replace
collapse (mean) selectBVRtot, by(HNDID)

save selectBVRtot_collapse, replace
sort HNDID
addstub selectBVRtot, stub(w1w3)
save, replace

use HANDLS_PAPER65_HCY_COGN,clear
capture drop _merge
sort HNDID

merge HNDID using selectBVRtot_collapse
tab _merge
capture drop _merge
sort HNDID

save, replace


capture drop sample3dobs
gen sample3dobs=.
replace sample3dobs=1 if w1w3selectBVRtot==1 & selectBVRtot==1 & HNDwave==1 | w1w3selectBVRtot==1 & selectBVRtot==1  & HNDwave==3 |w1w3selectBVRtot==0.5 & selectBVRtot==1 & HNDwave==1 | w1w3selectBVRtot==0.5 & selectBVRtot==1 & HNDwave==3
replace sample3dobs=0 if sample3dobs~=1 

capture drop sample3dpart
gen sample3dpart=1 if w1w3selectBVRtot==1 &  HNDwave==1 | w1w3selectBVRtot==1 &  HNDwave==3 |w1w3selectBVRtot==0.5 &  HNDwave==1 | w1w3selectBVRtot==0.5 & HNDwave==3
replace sample3dpart=0 if sample3dpart~=1 

tab sample3dobs if HNDwave==1  | HNDwave==3  
tab sample3dpart if HNDwave==1


xtmixed BVRtot timew1w3 if selectBVRtot==1 || HNDID: timew1w3

save, replace

**Attention: sample3e**

use HANDLS_PAPER65_HCY_COGN,clear

keep HNDID selectAttention

save selectAttention, replace
collapse (mean) selectAttention, by(HNDID)

save selectAttention_collapse, replace
sort HNDID
addstub selectAttention, stub(w1w3)
save, replace

use HANDLS_PAPER65_HCY_COGN,clear
capture drop _merge
sort HNDID

merge HNDID using selectAttention_collapse
tab _merge
capture drop _merge
sort HNDID

save, replace


capture drop sample3eobs
gen sample3eobs=.
replace sample3eobs=1 if w1w3selectAttention==1 & selectAttention==1 & HNDwave==1 | w1w3selectAttention==1 & selectAttention==1  & HNDwave==3 |w1w3selectAttention==0.5 & selectAttention==1 & HNDwave==1 | w1w3selectAttention==0.5 & selectAttention==1 & HNDwave==3
replace sample3eobs=0 if sample3eobs~=1 

capture drop sample3epart
gen sample3epart=1 if w1w3selectAttention==1 &  HNDwave==1 | w1w3selectAttention==1 &  HNDwave==3 |w1w3selectAttention==0.5 &  HNDwave==1 | w1w3selectAttention==0.5 & HNDwave==3
replace sample3epart=0 if sample3epart~=1 

tab sample3eobs if HNDwave==1  | HNDwave==3  
tab sample3epart if HNDwave==1


xtmixed Attention timew1w3 if selectAttention==1 || HNDID: timew1w3

save, replace


**FluencyWord: sample3f**

use HANDLS_PAPER65_HCY_COGN,clear

keep HNDID selectFluencyWord

save selectFluencyWord, replace
collapse (mean) selectFluencyWord, by(HNDID)

save selectFluencyWord_collapse, replace
sort HNDID
addstub selectFluencyWord, stub(w1w3)
save, replace

use HANDLS_PAPER65_HCY_COGN,clear
capture drop _merge
sort HNDID

merge HNDID using selectFluencyWord_collapse
tab _merge
capture drop _merge
sort HNDID

save, replace


capture drop sample3fobs
gen sample3fobs=.
replace sample3fobs=1 if w1w3selectFluencyWord==1 & selectFluencyWord==1 & HNDwave==1 | w1w3selectFluencyWord==1 & selectFluencyWord==1  & HNDwave==3 |w1w3selectFluencyWord==0.5 & selectFluencyWord==1 & HNDwave==1 | w1w3selectFluencyWord==0.5 & selectFluencyWord==1 & HNDwave==3
replace sample3fobs=0 if sample3fobs~=1 

capture drop sample3fpart
gen sample3fpart=1 if w1w3selectFluencyWord==1 &  HNDwave==1 | w1w3selectFluencyWord==1 &  HNDwave==3 |w1w3selectFluencyWord==0.5 &  HNDwave==1 | w1w3selectFluencyWord==0.5 & HNDwave==3
replace sample3fpart=0 if sample3fpart~=1 

tab sample3fobs if HNDwave==1  | HNDwave==3  
tab sample3fpart if HNDwave==1


xtmixed FluencyWord timew1w3 if selectFluencyWord==1 || HNDID: timew1w3

save, replace



**DigitSpanFwd: sample3g**

use HANDLS_PAPER65_HCY_COGN,clear

keep HNDID selectDigitSpanFwd

save selectDigitSpanFwd, replace
collapse (mean) selectDigitSpanFwd, by(HNDID)

save selectDigitSpanFwd_collapse, replace
sort HNDID
addstub selectDigitSpanFwd, stub(w1w3)
save, replace

use HANDLS_PAPER65_HCY_COGN,clear
capture drop _merge
sort HNDID

merge HNDID using selectDigitSpanFwd_collapse
tab _merge
capture drop _merge
sort HNDID

save, replace


capture drop sample3gobs
gen sample3gobs=.
replace sample3gobs=1 if w1w3selectDigitSpanFwd==1 & selectDigitSpanFwd==1 & HNDwave==1 | w1w3selectDigitSpanFwd==1 & selectDigitSpanFwd==1  & HNDwave==3 |w1w3selectDigitSpanFwd==0.5 & selectDigitSpanFwd==1 & HNDwave==1 | w1w3selectDigitSpanFwd==0.5 & selectDigitSpanFwd==1 & HNDwave==3
replace sample3gobs=0 if sample3gobs~=1 

capture drop sample3gpart
gen sample3gpart=1 if w1w3selectDigitSpanFwd==1 &  HNDwave==1 | w1w3selectDigitSpanFwd==1 &  HNDwave==3 |w1w3selectDigitSpanFwd==0.5 &  HNDwave==1 | w1w3selectDigitSpanFwd==0.5 & HNDwave==3
replace sample3gpart=0 if sample3gpart~=1 

tab sample3gobs if HNDwave==1  | HNDwave==3  
tab sample3gpart if HNDwave==1


xtmixed DigitSpanFwd timew1w3 if selectDigitSpanFwd==1 || HNDID: timew1w3

save, replace

**DigitSpanBck: sample3h**

use HANDLS_PAPER65_HCY_COGN,clear

keep HNDID selectDigitSpanBck

save selectDigitSpanBck, replace
collapse (mean) selectDigitSpanBck, by(HNDID)

save selectDigitSpanBck_collapse, replace
sort HNDID
addstub selectDigitSpanBck, stub(w1w3)
save, replace

use HANDLS_PAPER65_HCY_COGN,clear
capture drop _merge
sort HNDID

merge HNDID using selectDigitSpanBck_collapse
tab _merge
capture drop _merge
sort HNDID

save, replace


capture drop sample3hobs
gen sample3hobs=.
replace sample3hobs=1 if w1w3selectDigitSpanBck==1 & selectDigitSpanBck==1 & HNDwave==1 | w1w3selectDigitSpanBck==1 & selectDigitSpanBck==1  & HNDwave==3 |w1w3selectDigitSpanBck==0.5 & selectDigitSpanBck==1 & HNDwave==1 | w1w3selectDigitSpanBck==0.5 & selectDigitSpanBck==1 & HNDwave==3
replace sample3hobs=0 if sample3hobs~=1 

capture drop sample3hpart
gen sample3hpart=1 if w1w3selectDigitSpanBck==1 &  HNDwave==1 | w1w3selectDigitSpanBck==1 &  HNDwave==3 |w1w3selectDigitSpanBck==0.5 &  HNDwave==1 | w1w3selectDigitSpanBck==0.5 & HNDwave==3
replace sample3hpart=0 if sample3hpart~=1 

tab sample3hobs if HNDwave==1  | HNDwave==3  
tab sample3hpart if HNDwave==1


xtmixed DigitSpanBck timew1w3 if selectDigitSpanBck==1 || HNDID: timew1w3

save, replace



**clock_command: sample3i**

use HANDLS_PAPER65_HCY_COGN,clear

keep HNDID selectclock_command

save selectclock_command, replace
collapse (mean) selectclock_command, by(HNDID)

save selectclock_command_collapse, replace
sort HNDID
addstub selectclock_command, stub(w1w3)
save, replace

use HANDLS_PAPER65_HCY_COGN,clear
capture drop _merge
sort HNDID

merge HNDID using selectclock_command_collapse
tab _merge
capture drop _merge
sort HNDID

save, replace


capture drop sample3iobs
gen sample3iobs=.
replace sample3iobs=1 if w1w3selectclock_command==1 & selectclock_command==1 & HNDwave==1 | w1w3selectclock_command==1 & selectclock_command==1  & HNDwave==3 |w1w3selectclock_command==0.5 & selectclock_command==1 & HNDwave==1 | w1w3selectclock_command==0.5 & selectclock_command==1 & HNDwave==3
replace sample3iobs=0 if sample3iobs~=1 

capture drop sample3ipart
gen sample3ipart=1 if w1w3selectclock_command==1 &  HNDwave==1 | w1w3selectclock_command==1 &  HNDwave==3 |w1w3selectclock_command==0.5 &  HNDwave==1 | w1w3selectclock_command==0.5 & HNDwave==3
replace sample3ipart=0 if sample3ipart~=1 

tab sample3iobs if HNDwave==1  | HNDwave==3  
tab sample3ipart if HNDwave==1


xtmixed clock_command timew1w3 if selectclock_command==1 || HNDID: timew1w3

save, replace





**TrailsAtestSec: sample3j**

use HANDLS_PAPER65_HCY_COGN,clear

keep HNDID selectTrailsAtestSec

save selectTrailsAtestSec, replace
collapse (mean) selectTrailsAtestSec, by(HNDID)

save selectTrailsAtestSec_collapse, replace
sort HNDID
addstub selectTrailsAtestSec, stub(w1w3)
save, replace

use HANDLS_PAPER65_HCY_COGN,clear
capture drop _merge
sort HNDID

merge HNDID using selectTrailsAtestSec_collapse
tab _merge
capture drop _merge
sort HNDID

save, replace


capture drop sample3jobs
gen sample3jobs=.
replace sample3jobs=1 if w1w3selectTrailsAtestSec==1 & selectTrailsAtestSec==1 & HNDwave==1 | w1w3selectTrailsAtestSec==1 & selectTrailsAtestSec==1  & HNDwave==3 |w1w3selectTrailsAtestSec==0.5 & selectTrailsAtestSec==1 & HNDwave==1 | w1w3selectTrailsAtestSec==0.5 & selectTrailsAtestSec==1 & HNDwave==3
replace sample3jobs=0 if sample3jobs~=1 

capture drop sample3jpart
gen sample3jpart=1 if w1w3selectTrailsAtestSec==1 &  HNDwave==1 | w1w3selectTrailsAtestSec==1 &  HNDwave==3 |w1w3selectTrailsAtestSec==0.5 &  HNDwave==1 | w1w3selectTrailsAtestSec==0.5 & HNDwave==3
replace sample3jpart=0 if sample3jpart~=1 

tab sample3jobs if HNDwave==1  | HNDwave==3  
tab sample3jpart if HNDwave==1


xtmixed TrailsAtestSec timew1w3 if selectTrailsAtestSec==1 || HNDID: timew1w3

save, replace


**TrailsBtestSec: sample3k**

use HANDLS_PAPER65_HCY_COGN,clear

keep HNDID selectTrailsBtestSec

save selectTrailsBtestSec, replace
collapse (mean) selectTrailsBtestSec, by(HNDID)

save selectTrailsBtestSec_collapse, replace
sort HNDID
addstub selectTrailsBtestSec, stub(w1w3)
save, replace

use HANDLS_PAPER65_HCY_COGN,clear
capture drop _merge
sort HNDID

merge HNDID using selectTrailsBtestSec_collapse
tab _merge
capture drop _merge
sort HNDID

save, replace


capture drop sample3kobs
gen sample3kobs=.
replace sample3kobs=1 if w1w3selectTrailsBtestSec==1 & selectTrailsBtestSec==1 & HNDwave==1 | w1w3selectTrailsBtestSec==1 & selectTrailsBtestSec==1  & HNDwave==3 |w1w3selectTrailsBtestSec==0.5 & selectTrailsBtestSec==1 & HNDwave==1 | w1w3selectTrailsBtestSec==0.5 & selectTrailsBtestSec==1 & HNDwave==3
replace sample3kobs=0 if sample3kobs~=1 

capture drop sample3kpart
gen sample3kpart=1 if w1w3selectTrailsBtestSec==1 &  HNDwave==1 | w1w3selectTrailsBtestSec==1 &  HNDwave==3 |w1w3selectTrailsBtestSec==0.5 &  HNDwave==1 | w1w3selectTrailsBtestSec==0.5 & HNDwave==3
replace sample3kpart=0 if sample3kpart~=1 

tab sample3kobs if HNDwave==1  | HNDwave==3  
tab sample3kpart if HNDwave==1


xtmixed TrailsBtestSec timew1w3 if selectTrailsBtestSec==1 || HNDID: timew1w3

save, replace



**Samples with complete and reliable cognitive performance data at waves 1 and/or 3 and HOMOCYSTEINE data at wave 1: SAMPLE4 SERIES**

use HANDLS_PAPER65_HCY_COGN,clear


**MMSE: sample4a: N=1,430; N'=2,653, k=1.9**


capture drop sample4aobs
gen sample4aobs=.
replace sample4aobs=1 if sample3aobs==1 & w1HCY~=.
replace sample4aobs=0 if sample4aobs~=1 

capture drop sample4apart
gen sample4apart=1 if sample3apart==1 &  w1HCY~=.
replace sample4apart=0 if sample4apart~=1 

tab sample4aobs if HNDwave==1  | HNDwave==3  
tab sample4apart if HNDwave==1



xtmixed MMStot c.timew1w3##c.c.w1HCY if selectmms==1  || HNDID: timew1w3


save, replace

**cvltca: sample4b: N=1,420; N'=2,464, k=1.7****

capture drop sample4bobs
gen sample4bobs=.
replace sample4bobs=1 if sample3bobs==1 & w1HCY~=.
replace sample4bobs=0 if sample4bobs~=1 

capture drop sample4bpart
gen sample4bpart=1 if sample3bpart==1 &  w1HCY~=.
replace sample4bpart=0 if sample4bpart~=1 

tab sample4bobs if HNDwave==1  | HNDwave==3  
tab sample4bpart if HNDwave==1



xtmixed cvltca c.timew1w3##c.w1HCY if selectcvltca==1  || HNDID: timew1w3

save, replace


**CVLfrl: sample4c: N=2,339; N'=1,391, k=1.7**** /*CHECK*/

capture drop sample4cobs
gen sample4cobs=.
replace sample4cobs=1 if sample3cobs==1 & w1HCY~=.
replace sample4cobs=0 if sample4cobs~=1 

capture drop sample4cpart
gen sample4cpart=1 if sample3cpart==1 &  w1HCY~=.
replace sample4cpart=0 if sample4cpart~=1 

tab sample4cobs if HNDwave==1  | HNDwave==3  
tab sample4cpart if HNDwave==1



xtmixed CVLfrl c.timew1w3##c.w1HCY if selectcvlfrl==1  || HNDID: timew1w3

save, replace


**BVRtot: sample4d: N=1,443; N'=2,751, k=1.7**** /*CHECK*/

capture drop sample4dobs
gen sample4dobs=.
replace sample4dobs=1 if sample3dobs==1 & w1HCY~=.
replace sample4dobs=0 if sample4dobs~=1 

capture drop sample4dpart
gen sample4dpart=1 if sample3dpart==1 &  w1HCY~=.
replace sample4dpart=0 if sample4dpart~=1 

tab sample4dobs if HNDwave==1  | HNDwave==3  
tab sample4dpart if HNDwave==1



xtmixed BVRtot c.timew1w3##c.w1HCY if selectBVRtot==1  || HNDID: timew1w3

save, replace


**Attention: sample4e: N=1,418; N'=2,486, k=1.8**** /*CHECK*/

capture drop sample4eobs
gen sample4eobs=.
replace sample4eobs=1 if sample3eobs==1 & w1HCY~=.
replace sample4eobs=0 if sample4eobs~=1 

capture drop sample4epart
gen sample4epart=1 if sample3epart==1 &  w1HCY~=.
replace sample4epart=0 if sample4epart~=1 

tab sample4eobs if HNDwave==1  | HNDwave==3  
tab sample4epart if HNDwave==1



xtmixed Attention c.timew1w3##c.w1HCY if selectAttention==1  || HNDID: timew1w3

save, replace


**FluencyWord: sample4f: N=1,446, N'=2,773, k=1.9*** /*CHECK*/

capture drop sample4fobs
gen sample4fobs=.
replace sample4fobs=1 if sample3fobs==1 & w1HCY~=.
replace sample4fobs=0 if sample4fobs~=1 

capture drop sample4fpart
gen sample4fpart=1 if sample3fpart==1 &  w1HCY~=.
replace sample4fpart=0 if sample4fpart~=1 

tab sample4fobs if HNDwave==1  | HNDwave==3  
tab sample4fpart if HNDwave==1



xtmixed FluencyWord c.timew1w3##c.w1HCY if selectFluencyWord==1  || HNDID: timew1w3

save, replace



**DigitSpanFwd: sample4g: N=1,443, N'=2,717, k=1.9***

capture drop sample4gobs
gen sample4gobs=.
replace sample4gobs=1 if sample3gobs==1 & w1HCY~=.
replace sample4gobs=0 if sample4gobs~=1 

capture drop sample4gpart
gen sample4gpart=1 if sample3gpart==1 &  w1HCY~=.
replace sample4gpart=0 if sample4gpart~=1 

tab sample4gobs if HNDwave==1  | HNDwave==3  
tab sample4gpart if HNDwave==1



xtmixed DigitSpanFwd c.timew1w3##c.w1HCY if selectDigitSpanFwd==1  || HNDID: timew1w3

save, replace




**DigitSpanBck: sample4h: N=1,444, N'=2,704, k=1.9***

capture drop sample4hobs
gen sample4hobs=.
replace sample4hobs=1 if sample3hobs==1 & w1HCY~=.
replace sample4hobs=0 if sample4hobs~=1 

capture drop sample4hpart
gen sample4hpart=1 if sample3hpart==1 &  w1HCY~=.
replace sample4hpart=0 if sample4hpart~=1 

tab sample4hobs if HNDwave==1  | HNDwave==3  
tab sample4hpart if HNDwave==1



xtmixed DigitSpanBck c.timew1w3##c.w1HCY if selectDigitSpanBck==1  || HNDID: timew1w3

save, replace



**clock_command: sample4i: N=1,445, N'=2,767, k=1.9***

capture drop sample4iobs
gen sample4iobs=.
replace sample4iobs=1 if sample3iobs==1 & w1HCY~=.
replace sample4iobs=0 if sample4iobs~=1 

capture drop sample4ipart
gen sample4ipart=1 if sample3ipart==1 &  w1HCY~=.
replace sample4ipart=0 if sample4ipart~=1 

tab sample4iobs if HNDwave==1  | HNDwave==3  
tab sample4ipart if HNDwave==1



xtmixed clock_command c.timew1w3##c.w1HCY if selectclock_command==1  || HNDID: timew1w3

save, replace




**TrailsAtestSec: sample4j: N=1,428, N'= 2,701, k=1.9***

capture drop sample4jobs
gen sample4jobs=.
replace sample4jobs=1 if sample3jobs==1 & w1HCY~=.
replace sample4jobs=0 if sample4jobs~=1 

capture drop sample4jpart
gen sample4jpart=1 if sample3jpart==1 &  w1HCY~=.
replace sample4jpart=0 if sample4jpart~=1 

tab sample4jobs if HNDwave==1  | HNDwave==3  
tab sample4jpart if HNDwave==1



xtmixed TrailsAtestSec c.timew1w3##c.w1HCY if selectTrailsAtestSec==1  || HNDID: timew1w3

save, replace




**TrailsBtestSec: sample4k: N=1,414, N'=2,609, k=1.8***

capture drop sample4kobs
gen sample4kobs=.
replace sample4kobs=1 if sample3kobs==1 & w1HCY~=.
replace sample4kobs=0 if sample4kobs~=1 

capture drop sample4kpart
gen sample4kpart=1 if sample3kpart==1 &  w1HCY~=.
replace sample4kpart=0 if sample4kpart~=1 

tab sample4kobs if HNDwave==1  | HNDwave==3  
tab sample4kpart if HNDwave==1



xtmixed TrailsBtestSec c.timew1w3##c.w1HCY if selectTrailsBtestSec==1  || HNDID: timew1w3

save HANDLS_PAPER65_HCY_COGN, replace

//STEP 18: CREATE INVERSE MILLS RATIOS FOR FINAL SELECTED SAMPLES FOR MIXED-EFFECTS REGRESSION MODELS//

use HANDLS_PAPER65_HCY_COGN, clear

**MMSE**

xi:probit sample4aobs w1Age Race PovStat Sex

capture drop p1mms
predict p1mms, xb

capture drop phimms
capture drop caphimms
capture drop invmillsmms

gen phimms=(1/sqrt(2*_pi))*exp(-(p1mms^2/2))

egen caphimms=std(p1mms)

capture drop invmillsmms
gen invmillsmms=phimms/caphimms


su invmillsmms

**CVLT,LIST A** 

xi:probit sample4bobs w1Age Race PovStat Sex

capture drop p1cvltca
predict p1cvltca, xb

capture drop phicvltca
capture drop caphicvltca
capture drop invmillscvltca

gen phicvltca=(1/sqrt(2*_pi))*exp(-(p1cvltca^2/2))

egen caphicvltca=std(p1cvltca)

capture drop invmillscvltca
gen invmillscvltca=phicvltca/caphicvltca

su invmillscvltca


**CVLT, FREE DELAYED RECALL** /*CHECK*/
xi:probit sample4cobs w1Age Race PovStat Sex

capture drop p1cvlfrl
predict p1cvlfrl, xb

capture drop phicvlfrl
capture drop caphicvlfrl
capture drop invmillscvlfrl

gen phicvlfrl=(1/sqrt(2*_pi))*exp(-(p1cvlfrl^2/2))

egen caphicvlfrl=std(p1cvlfrl)

capture drop invmillscvlfrl
gen invmillscvlfrl=phicvlfrl/caphicvlfrl

su invmillscvlfrl

**BVRTOT** /*CHECK*/
xi:probit sample4dobs w1Age Race PovStat Sex

capture drop p1BVRtot
predict p1BVRtot, xb

capture drop phiBVRtot
capture drop caphiBVRtot
capture drop invmillsBVRtot

gen phiBVRtot=(1/sqrt(2*_pi))*exp(-(p1BVRtot^2/2))

egen caphiBVRtot=std(p1BVRtot)

capture drop invmillsBVRtot
gen invmillsBVRtot=phiBVRtot/caphiBVRtot

su invmillsBVRtot
histogram invmillsBVRtot


**Attention** /*CHECK*/
xi:probit sample4eobs w1Age Race PovStat Sex

capture drop p1Attention
predict p1Attention, xb

capture drop phiAttention
capture drop caphiAttention
capture drop invmillsAttention

gen phiAttention=(1/sqrt(2*_pi))*exp(-(p1Attention^2/2))

egen caphiAttention=std(p1Attention)

capture drop invmillsAttention
gen invmillsAttention=phiAttention/caphiAttention

su invmillsAttention
histogram invmillsAttention


**WORD FLUENCY** /*CHECK*/
xi:probit sample4fobs w1Age Race PovStat Sex

capture drop p1FluencyWord
predict p1FluencyWord, xb

capture drop phiFluencyWord
capture drop caphiFluencyWord
capture drop invmillsFluencyWord

gen phiFluencyWord=(1/sqrt(2*_pi))*exp(-(p1FluencyWord^2/2))

egen caphiFluencyWord=std(p1FluencyWord)

capture drop invmillsFluencyWord
gen invmillsFluencyWord=phiFluencyWord/caphiFl

su invmillsFluencyWord
histogram invmillsFluencyWord

save, replace


**DIGITS SPAN FORWARD** /*CHECK*/

xi:probit sample4gobs w1Age Race PovStat Sex


capture drop p1DigitSpanFwd
predict p1DigitSpanFwd, xb

capture drop phiDigitSpanFwd
capture drop caphiDigitSpanFwd
capture drop invmillsDigitSpanFwd

gen phiDigitSpanFwd=(1/sqrt(2*_pi))*exp(-(p1DigitSpanFwd^2/2))

egen caphiDigitSpanFwd=std(p1DigitSpanFwd)

capture drop invmillsDigitSpanFwd
gen invmillsDigitSpanFwd=phiDigitSpanFwd/caphiFl

su invmillsDigitSpanFwd
histogram invmillsDigitSpanFwd

save, replace



**DIGITS SPAN BACKWARD** /*CHECK*/


xi:probit sample4hobs w1Age Race PovStat Sex


capture drop p1DigitSpanBck
predict p1DigitSpanBck, xb

capture drop phiDigitSpanBck
capture drop caphiDigitSpanBck
capture drop invmillsDigitSpanBck

gen phiDigitSpanBck=(1/sqrt(2*_pi))*exp(-(p1DigitSpanBck^2/2))

egen caphiDigitSpanBck=std(p1DigitSpanBck)

capture drop invmillsDigitSpanBck
gen invmillsDigitSpanBck=phiDigitSpanBck/caphiFl

su invmillsDigitSpanBck
histogram invmillsDigitSpanBck

save, replace



**CLOCK, COMMAND**
xi:probit sample4iobs w1Age Race PovStat Sex

capture drop p1clock_command 
predict p1clock_command , xb

capture drop phiclock_command 
capture drop caphiclock_command 
capture drop invmillsclock_command 

gen phiclock_command =(1/sqrt(2*_pi))*exp(-(p1clock_command ^2/2))

egen caphiclock_command =std(p1clock_command )

capture drop invmillsclock_command 
gen invmillsclock_command =phiclock_command /caphiclock_command 

su invmillsclock_command
histogram invmillsclock_command

save, replace

**TRAILS A**
xi:probit sample4jobs w1Age Race PovStat Sex

capture drop p1TrailsAtestSec 
predict p1TrailsAtestSec , xb

capture drop phiTrailsAtestSec 
capture drop caphiTrailsAtestSec 
capture drop invmillsTrailsAtestSec 

gen phiTrailsAtestSec =(1/sqrt(2*_pi))*exp(-(p1TrailsAtestSec ^2/2))

egen caphiTrailsAtestSec =std(p1TrailsAtestSec )

capture drop invmillsTrailsAtestSec 
gen invmillsTrailsAtestSec =phiTrailsAtestSec/caphiTrailsAtestSec 

su invmillsTrailsAtestSec
histogram invmillsTrailsAtestSec

**TRAILS B**
xi:probit sample4kobs w1Age Race PovStat Sex

capture drop p1TrailsBtestSec 
predict p1TrailsBtestSec , xb

capture drop phiTrailsBtestSec 
capture drop caphiTrailsBtestSec 
capture drop invmillsTrailsBtestSec 

gen phiTrailsBtestSec =(1/sqrt(2*_pi))*exp(-(p1TrailsBtestSec ^2/2))

egen caphiTrailsBtestSec =std(p1TrailsBtestSec )

capture drop invmillsTrailsBtestSec 
gen invmillsTrailsBtestSec =phiTrailsBtestSe

save, replace


su invmillsTrailsBtestSec
histogram invmillsTrailsBtestSec

save HANDLS_PAPER65_HCY_COGN, replace

capture log close


log using "E:\HANDLS_PAPER65_HCY_COGN\OUTPUT\TRAJ.smcl",replace

capture net from https://www.andrew.cmu.edu/user/bjones/traj
capture net install traj
help traj

//////STEP 19A: TRAJECTORY OF HOMOCYSTEINE BETWEEN WAVES 1 AND 3///////////////////

use HANDLS_PAPER65_HCY_COGN,clear
keep if HNDwave==1
save HANDLS_PAPER65_HCY_COGN_wide, replace

capture drop sampleHCY
gen sampleHCY=.
replace sampleHCY=1 if (w1HCys~=. & w1Age~=. & w3Age~=. | w3HCys~=. & w1Age~=. & w3Age~=.)
replace sampleHCY=0 if sampleHCY~=1

tab sampleHCY
tab sampleHCY if HNDwave==1
tab sampleHCY if HNDwave==3


su w1Age if sampleHCY==1 & HNDwave==1
su w3Age if sampleHCY==1 & HNDwave==1


su w1HCys if sampleHCY==1 & HNDwave==1
su w3HCys if sampleHCY==1 & HNDwave==1


**Log transformation of HCY***

capture drop Lnw1HCys Lnw3HCys  
foreach x of varlist w1HCys w3HCys  {
gen Ln`x'=ln(`x')	
}
 
save HANDLS_PAPER65_HCY_COGN_wide, replace

**w1w3HCysTRAJ**

traj if sampleHCY==1, var(Lnw1HCys Lnw3HCys) indep(w1Age w3Age) model(cnorm) max1(400) order(1 1) sigmabygroup detail

trajplot, xtitle(Age (years)) ytitle(HCY) ci

graph save "FIGURE2.gph",replace

capture drop R_traj_*

capture rename _traj_Group R_traj_GroupHCY 
capture rename _traj_ProbG1 R_traj_ProbG1HCY 
capture rename _traj_ProbG2  R_traj_ProbG2HCY

save, replace

corr R_traj_ProbG1HCY Lnw1HCys Lnw3HCys 
corr R_traj_ProbG2HCY Lnw1HCys Lnw3HCys 

bysort R_traj_GroupHCY: su Lnw1HCys Lnw3HCys if (sampleHCY==1 & HNDwave==1)


capture drop w1w3HCysTRAJ
gen w1w3HCysTRAJ=R_traj_ProbG2HCY

save HANDLS_PAPER65_HCY_COGN_wide, replace

keep HNDID R_traj* w1w3HCysTRAJ

save HCY_TRAJ_DATA, replace
sort HNDID
save, replace

use HANDLS_PAPER65_HCY_COGN,clear
capture drop _merge
sort HNDID
save, replace

merge HNDID using HCY_TRAJ_DATA
save HANDLS_PAPER65_HCY_COGN, replace



capture log close

log using "E:\HANDLS_PAPER65_HCY_COGN\OUTPUT\IMPUTATIONS.smcl",replace


//STEP 19B: MULTIPLE IMPUTATIONS FOR COVARIATES////////

use HANDLS_PAPER65_HCY_COGN,clear

sort HNDwave HNDID


save finaldata_imputed,replace


capture set matsize 11000

capture mi set flong

capture mi xtset, clear

capture mi stset, clear

save, replace

su HNDwave w1w3bayes*  w1Age Sex Race PovStat w1edubr w1WRATtotal w1currdrugs w1smoke  w1BMI w1SRH w1hei2010_total_score  w1CES w1dxHTN w1dxDiabetes w1CVhighChol w1cvdbr if HNDwave==1


replace w1smoke=. if w1smoke==9
save, replace

replace w1currdrugs=. if w1currdrugs==9
save, replace

replace w1SRH=. if w1SRH==9
save, replace

mi unregister HNDID HNDwave w1w3bayes*  w1Age Sex Race PovStat w1edubr w1WRATtotal w1currdrugs w1smoke  w1BMI w1SRH w1hei2010_total_score  w1CES w1dxHTN w1dxDiabetes w1CVhighChol w1cvdbr w1Folate w1B12 w1Folate_total w1VitaminB12

mi register imputed  w1edubr w1WRATtotal w1currdrugs w1smoke  w1BMI w1SRH w1hei2010_total_score  w1CES w1dxHTN w1dxDiabetes w1CVhighChol w1cvdbr  w1Folate w1B12 w1Folate_total w1VitaminB12


mi register passive bayes1*  


mi impute chained (ologit) w1edubr w1smoke w1currdrugs  w1dxHTN w1dxDiabetes w1CVhighChol w1cvdbr w1SRH (regress)  w1BMI w1hei2010_total_score  w1CES  w1WRATtotal w1Folate w1B12 w1Folate_total w1VitaminB12=w1Age Sex Race PovStat if w1Age~=., force augment noisily  add(5) rseed(1234) savetrace(tracefile, replace) 


save finaldata_imputed, replace

capture drop w1comorbid
mi passive: gen w1comorbid=w1dxHTN+w1dxDiabetes+w1CVhighChol+w1cvdbr

save finaldata_imputed_FINAL, replace



//STEP 20: CENTER CONTINUOUS VARIABLES AND LOG TRANSFORM TRAILS// /*CHECK*/

use finaldata_imputed_FINAL,clear


**Dietary exposures and other continuous covariates**
su w1HCY if HNDwave==1 & _mi_m==0
su w1hei2010_total_score if HNDwave==1 & _mi_m==0
su w1WRATtotal if HNDwave==1 & _mi_m==0
su w1CES if HNDwave==1 & _mi_m==0
su w1BMI if HNDwave==1 & _mi_m==0
su invmills* if HNDwave==1 & _mi_m==0
su w1Age if HNDwave==1 & _mi_m==0

******HOMOCYSTEINE******

capture drop w1HCYcenter2p15
mi passive: gen w1HCYcenter2p15=w1HCY-2.15

capture drop zw1w3HCYTRAJ
egen zw1w3HCYTRAJ=std(w1w3HCysTRAJ)  


******Dietary exposures and covariates******

capture drop w1hei2010_total_scorecent43
gen w1hei2010_total_scorecent43=w1hei2010_total_score-43

****************Folate and B12*******************

su w1Folate if HNDwave==1 & _mi_m==0
mi passive: gen w1Folatecenter14p3=w1Folate-14.3

su w1B12 if HNDwave==1 & _mi_m==0
mi passive: gen w1B12center522=w1B12-522

su w1Folate_total if HNDwave==1 & _mi_m==0 
mi passive: gen w1Folate_totalcenter357=w1Folate_total-357

su w1VitaminB12 if HNDwave==1 & _mi_m==0
mi passive: gen w1VitaminB12center6p1=w1VitaminB12-6.1

save, replace

******Other covariates*******

capture drop w1WRATtotalcent42
gen w1WRATtotalcent42=w1WRATtotal-42

su w1WRATtotalcent42 if HNDwave==1 


capture drop w1CEScent15
gen w1CEScent15=w1CES-15

su w1CEScent15 if HNDwave==1

capture drop w1BMIcent30
gen w1BMIcent30=w1BMI-30

su w1BMIcent30 if HNDwave==1

capture drop w1Agecent48
gen w1Agecent48=w1Age-48

su w1Agecent48 if HNDwave==1


**Categorical covariates:
tab1 w1edubr  w1currdrugs w1smoke  w1SRH w1dxHTN w1dxDiabetes w1CVhighChol w1cvdbr 


**Time varialbes: timew1w3

**Outcome variables**
su MMStot cvltca CVLfrl BVRtot Attention FluencyWord DigitSpanFwd DigitSpanBck clock_command TrailsAtestSec TrailsBtestSec

save finaldata_imputed_FINAL, replace


**Final sample**

tab1 sample4apart sample4bpart sample4cpart sample4dpart sample4epart sample4fpart sample4gpart sample4hpart sample4ipart sample4jpart sample4kpart if HNDwave==1

capture drop sample_final_part
gen sample_final_part=1 if sample4apart==1 & sample4bpart==1 & sample4cpart==1 & sample4dpart==1 & sample4epart==1 & sample4fpart==1 & sample4gpart==1 & sample4hpart==1 & sample4ipart==1 & sample4jpart==1 & sample4kpart==1 

replace sample_final_part=0 if sample_final_part~=1

tab sample_final_part if HNDwave==1


tab sample_final_part HNDwave


**Final sample selectivity**

mi estimate: logistic sample_final_part w1Age Sex PovStat Race if HNDwave==1 

mi estimate: logistic sample_final_part w1Age  if HNDwave==1
mi estimate: logistic sample_final_part Sex  if HNDwave==1
mi estimate: logistic sample_final_part PovStat  if HNDwave==1
mi estimate: logistic sample_final_part Race  if HNDwave==1

save finaldata_imputed_FINAL, replace

//STEP 21: CREATE HOMOCYSTEINE TERTILE//

use finaldata_imputed_FINAL,clear

capture drop w1HCYtert
xtile w1HCYtert=w1HCY if HNDwave==1 | HNDwave==3,nq(3)


tab w1HCYtert

bysort w1HCYtert: su  w1HCY if HNDwave==1

save finaldata_imputed_FINAL, replace

capture log close

log using "E:\HANDLS_PAPER65_HCY_COGN\OUTPUT\FIGURE1.smcl", replace


*************************MAIN ANALYSIS******************

////////FIGURE 1: PARTICIPANT FLOWCHART, TEXT OF METHODS////


use finaldata_imputed_FINAL,clear


su timew1w3 if HNDwave==3


**Initial sample: N=3,720**

mi estimate: mean w1Age if HNDwave==1
mi estimate: prop Sex if HNDwave==1
mi estimate: prop Race if HNDwave==1
mi estimate: prop PovStat if HNDwave==1

save, replace

tab sample1 if HNDwave==1 & _mi_m==0

**Sample with complete HOMOCYSTEINE data: N=1,460**

tab sample2 if HNDwave==1 & _mi_m==0

**Sample with complete HOMOCYSTEINE data at v1 and TRAJ**

su zw1w3HCYTRAJ if HNDwave==1 & _mi_m==0 & sample2==1


**Samples with complete and reliable cognitive test scores at waves 1 or 3: Report maximum sample sizes for participants and observations in text ***

tab1 sample3*part if HNDwave==1  & _mi_m==0
tab1 sample3*part if HNDwave==3  & _mi_m==0

tab1 sample3*obs if HNDwave==1  & _mi_m==0 | HNDwave==3  & _mi_m==0


**Samples with complete and reliable cognitive test scores at waves 1 or 3 and complete AL exposures: Report ranges for participants and observations***

tab1 sample4*part if HNDwave==1  & _mi_m==0
tab1 sample4*part if HNDwave==3  & _mi_m==0

tab1 sample4*obs if HNDwave==1  & _mi_m==0 | HNDwave==3  & _mi_m==0

save finaldata_imputed_FINAL,replace



capture log close

log using "E:\HANDLS_PAPER65_HCY_COGN\OUTPUT\TABLE1.smcl", replace


//////////////////////////TABLE 1: STUDY CHARACTERISTICS OVERALL AND BY W1 HOMOCYSTEINE TERTILE/////////////////////////////////////

use finaldata_imputed_FINAL,clear


**Total sample with complete MMSE data, exposure and covariates: sample4apart**

mi estimate: mean w1HCY if sample4apart==1 & HNDwave==1
mi estimate: mean R_traj_ProbG2HCY if sample4apart==1 & HNDwave==1


mi estimate: prop Sex  if sample4apart==1 & HNDwave==1
mi estimate: mean w1Age  if sample4apart==1 & HNDwave==1
mi estimate: prop Race  if sample4apart==1 & HNDwave==1
mi estimate: prop PovStat  if sample4apart==1 & HNDwave==1
mi estimate: prop w1edubr  if sample4apart==1 & HNDwave==1
mi estimate: mean w1WRATtotal if sample4apart==1 & HNDwave==1
mi estimate: prop w1currdrugs if sample4apart==1 & HNDwave==1 
mi estimate: prop w1smoke if sample4apart==1 & HNDwave==1
mi estimate: mean w1BMI if sample4apart==1 & HNDwave==1
mi estimate: prop w1SRH if sample4apart==1 & HNDwave==1
mi estimate: mean w1hei2010_total_score if sample4apart==1 & HNDwave==1
mi estimate: mean w1CES if sample4apart==1 & HNDwave==1
mi estimate: prop w1dxHTN if sample4apart==1 & HNDwave==1
mi estimate: prop w1dxDiabetes if sample4apart==1 & HNDwave==1
mi estimate: prop w1CVhighChol  if sample4apart==1 & HNDwave==1
mi estimate: prop w1cvdbr  if sample4apart==1 & HNDwave==1


mi estimate: mean MMStot if sample4apart==1 & HNDwave==1
mi estimate: mean MMStotnorm if sample4apart==1 & HNDwave==1
mi estimate: mean cvltca if sample4bpart==1 & HNDwave==1
mi estimate: mean CVLfrl if sample4cpart==1 & HNDwave==1
mi estimate: mean BVRtot if sample4dpart==1 & HNDwave==1
mi estimate: mean Attention if sample4epart==1 & HNDwave==1
mi estimate: mean FluencyWord if sample4fpart==1 & HNDwave==1
mi estimate: mean DigitSpanFwd if sample4gpart==1 & HNDwave==1
mi estimate: mean DigitSpanBck if sample4hpart==1 & HNDwave==1
mi estimate: mean clock_command if sample4ipart==1 & HNDwave==1
mi estimate: mean LnTrailsAtestSec if sample4jpart==1 & HNDwave==1
mi estimate: mean LnTrailsBtestSec if sample4kpart==1 & HNDwave==1



mi estimate: mean w1w3bayes1MMSE if sample4apart==1 & HNDwave==1
mean w1w3bayes1MMSEnorm if sample4apart==1 & HNDwave==1 & _mi_m==1
mi estimate: mean w1w3bayes1cvltca if sample4bpart==1 & HNDwave==1
mi estimate: mean w1w3bayes1CVLfrl if sample4cpart==1 & HNDwave==1
mi estimate: mean w1w3bayes1BVRtot if sample4dpart==1 & HNDwave==1
mi estimate: mean w1w3bayes1Attention if sample4epart==1 & HNDwave==1
mi estimate: mean w1w3bayes1FluencyWord if sample4fpart==1 & HNDwave==1
mi estimate: mean w1w3bayes1DigitSpanFwd if sample4gpart==1 & HNDwave==1
mi estimate: mean w1w3bayes1DigitSpanBck if sample4hpart==1 & HNDwave==1
mi estimate: mean w1w3bayes1clock_command if sample4ipart==1 & HNDwave==1
mi estimate: mean w1w3bayes1LnTrailsAtestSec if sample4jpart==1 & HNDwave==1
mi estimate: mean w1w3bayes1LnTrailsBtestSec if sample4kpart==1 & HNDwave==1

mi estimate: mean w1Folate if sample4apart==1 & HNDwave==1
mi estimate: mean w1Folate_total if sample4apart==1 & HNDwave==1
mi estimate: mean w1B12 if sample4apart==1 & HNDwave==1
mi estimate: mean w1VitaminB12 if sample4apart==1 & HNDwave==1



save, replace




**************First tertile of HOMOCYSTEINE*****************

mi estimate: mean w1HCY if sample4apart==1 & HNDwave==1 & w1HCYtert==1
mi estimate: mean R_traj_ProbG2HCY if sample4apart==1 & HNDwave==1 & w1HCYtert==1


mi estimate: prop Sex  if sample4apart==1 & HNDwave==1 & w1HCYtert==1
mi estimate: mean w1Age  if sample4apart==1 & HNDwave==1 & w1HCYtert==1
mi estimate: prop Race  if sample4apart==1 & HNDwave==1 & w1HCYtert==1
mi estimate: prop PovStat  if sample4apart==1 & HNDwave==1 & w1HCYtert==1
mi estimate: prop w1edubr  if sample4apart==1 & HNDwave==1 & w1HCYtert==1
mi estimate: mean w1WRATtotal if sample4apart==1 & HNDwave==1 & w1HCYtert==1
mi estimate: prop w1currdrugs if sample4apart==1 & HNDwave==1 & w1HCYtert==1 
mi estimate: prop w1smoke if sample4apart==1 & HNDwave==1 & w1HCYtert==1
mi estimate: mean w1BMI if sample4apart==1 & HNDwave==1 & w1HCYtert==1
mi estimate: prop w1SRH if sample4apart==1 & HNDwave==1 & w1HCYtert==1
mi estimate: mean w1hei2010_total_score if sample4apart==1 & HNDwave==1 & w1HCYtert==1
mi estimate: mean w1CES if sample4apart==1 & HNDwave==1 & w1HCYtert==1
mi estimate: prop w1dxHTN if sample4apart==1 & HNDwave==1 & w1HCYtert==1
mi estimate: prop w1dxDiabetes if sample4apart==1 & HNDwave==1 & w1HCYtert==1
mi estimate: prop w1CVhighChol  if sample4apart==1 & HNDwave==1 & w1HCYtert==1
mi estimate: prop w1cvdbr  if sample4apart==1 & HNDwave==1 & w1HCYtert==1

mi estimate: mean MMStot if sample4apart==1 & HNDwave==1 & w1HCYtert==1
mi estimate: mean MMStotnorm if sample4apart==1 & HNDwave==1 & w1HCYtert==1
mi estimate: mean cvltca if sample4bpart==1 & HNDwave==1 & w1HCYtert==1
mi estimate: mean CVLfrl if sample4cpart==1 & HNDwave==1 & w1HCYtert==1
mi estimate: mean BVRtot if sample4dpart==1 & HNDwave==1 & w1HCYtert==1
mi estimate: mean Attention if sample4epart==1 & HNDwave==1 & w1HCYtert==1
mi estimate: mean FluencyWord if sample4fpart==1 & HNDwave==1 & w1HCYtert==1
mi estimate: mean DigitSpanFwd if sample4gpart==1 & HNDwave==1 & w1HCYtert==1
mi estimate: mean DigitSpanBck if sample4hpart==1 & HNDwave==1 & w1HCYtert==1
mi estimate: mean clock_command if sample4ipart==1 & HNDwave==1 & w1HCYtert==1
mi estimate: mean LnTrailsAtestSec if sample4jpart==1 & HNDwave==1 & w1HCYtert==1
mi estimate: mean LnTrailsBtestSec if sample4kpart==1 & HNDwave==1 & w1HCYtert==1

mi estimate: mean w1w3bayes1MMSE if sample4apart==1 & HNDwave==1 & w1HCYtert==1
mi estimate: mean w1w3bayes1cvltca if sample4bpart==1 & HNDwave==1 & w1HCYtert==1
mi estimate: mean w1w3bayes1CVLfrl if sample4cpart==1 & HNDwave==1 & w1HCYtert==1
mi estimate: mean w1w3bayes1BVRtot if sample4dpart==1 & HNDwave==1 & w1HCYtert==1
mi estimate: mean w1w3bayes1Attention if sample4epart==1 & HNDwave==1 & w1HCYtert==1
mi estimate: mean w1w3bayes1FluencyWord if sample4fpart==1 & HNDwave==1 & w1HCYtert==1
mi estimate: mean w1w3bayes1DigitSpanFwd if sample4gpart==1 & HNDwave==1 & w1HCYtert==1
mi estimate: mean w1w3bayes1DigitSpanBck if sample4hpart==1 & HNDwave==1 & w1HCYtert==1
mi estimate: mean w1w3bayes1clock_command if sample4ipart==1 & HNDwave==1 & w1HCYtert==1
mi estimate: mean w1w3bayes1LnTrailsAtestSec if sample4jpart==1 & HNDwave==1 & w1HCYtert==1
mi estimate: mean w1w3bayes1LnTrailsBtestSec if sample4kpart==1 & HNDwave==1 & w1HCYtert==1

mi estimate: mean w1Folate if sample4apart==1 & HNDwave==1 & w1HCYtert==1
mi estimate: mean w1Folate_total if sample4apart==1 & HNDwave==1 & w1HCYtert==1
mi estimate: mean w1B12 if sample4apart==1 & HNDwave==1 & w1HCYtert==1
mi estimate: mean w1VitaminB12 if sample4apart==1 & HNDwave==1 & w1HCYtert==1


save, replace

**************Second tertile of HOMOCYSTEINE*****************

mean w1HCY if sample4apart==1 & HNDwave==1 & w1HCYtert==2 & _mi_m==1
mi estimate: mean R_traj_ProbG2HCY if sample4apart==1 & HNDwave==1 & w1HCYtert==2

mi estimate: prop Sex  if sample4apart==1 & HNDwave==1 & w1HCYtert==2
mi estimate: mean w1Age  if sample4apart==1 & HNDwave==1 & w1HCYtert==2
mi estimate: prop Race  if sample4apart==1 & HNDwave==1 & w1HCYtert==2
mi estimate: prop PovStat  if sample4apart==1 & HNDwave==1 & w1HCYtert==2
mi estimate: prop w1edubr  if sample4apart==1 & HNDwave==1 & w1HCYtert==2
mi estimate: mean w1WRATtotal if sample4apart==1 & HNDwave==1 & w1HCYtert==2
mi estimate: prop w1currdrugs if sample4apart==1 & HNDwave==1 & w1HCYtert==2 
mi estimate: prop w1smoke if sample4apart==1 & HNDwave==1 & w1HCYtert==2
mi estimate: mean w1BMI if sample4apart==1 & HNDwave==1 & w1HCYtert==2
mi estimate: prop w1SRH if sample4apart==1 & HNDwave==1 & w1HCYtert==2
mi estimate: mean w1hei2010_total_score if sample4apart==1 & HNDwave==1 & w1HCYtert==2
mi estimate: mean w1CES if sample4apart==1 & HNDwave==1 & w1HCYtert==2
mi estimate: prop w1dxHTN if sample4apart==1 & HNDwave==1 & w1HCYtert==2
mi estimate: prop w1dxDiabetes if sample4apart==1 & HNDwave==1 & w1HCYtert==2
mi estimate: prop w1CVhighChol  if sample4apart==1 & HNDwave==1 & w1HCYtert==2
mi estimate: prop w1cvdbr  if sample4apart==1 & HNDwave==1 & w1HCYtert==2

mi estimate: mean MMStot if sample4apart==1 & HNDwave==1 & w1HCYtert==2
mi estimate: mean MMStotnorm if sample4apart==1 & HNDwave==1 & w1HCYtert==2
mi estimate: mean cvltca if sample4bpart==1 & HNDwave==1 & w1HCYtert==2
mi estimate: mean CVLfrl if sample4cpart==1 & HNDwave==1 & w1HCYtert==2
mi estimate: mean BVRtot if sample4dpart==1 & HNDwave==1 & w1HCYtert==2
mi estimate: mean Attention if sample4epart==1 & HNDwave==1 & w1HCYtert==2
mi estimate: mean FluencyWord if sample4fpart==1 & HNDwave==1 & w1HCYtert==2
mi estimate: mean DigitSpanFwd if sample4gpart==1 & HNDwave==1 & w1HCYtert==2
mi estimate: mean DigitSpanBck if sample4hpart==1 & HNDwave==1 & w1HCYtert==2
mi estimate: mean clock_command if sample4ipart==1 & HNDwave==1 & w1HCYtert==2
mi estimate: mean LnTrailsAtestSec if sample4jpart==1 & HNDwave==1 & w1HCYtert==2
mi estimate: mean LnTrailsBtestSec if sample4kpart==1 & HNDwave==1 & w1HCYtert==2

mi estimate: mean w1w3bayes1MMSE if sample4apart==1 & HNDwave==1 & w1HCYtert==2
mi estimate: mean w1w3bayes1cvltca if sample4bpart==1 & HNDwave==1 & w1HCYtert==2
mi estimate: mean w1w3bayes1CVLfrl if sample4cpart==1 & HNDwave==1 & w1HCYtert==2
mi estimate: mean w1w3bayes1BVRtot if sample4dpart==1 & HNDwave==1 & w1HCYtert==2
mi estimate: mean w1w3bayes1Attention if sample4epart==1 & HNDwave==1 & w1HCYtert==2
mi estimate: mean w1w3bayes1FluencyWord if sample4fpart==1 & HNDwave==1 & w1HCYtert==2
mi estimate: mean w1w3bayes1DigitSpanFwd if sample4gpart==1 & HNDwave==1 & w1HCYtert==2
mi estimate: mean w1w3bayes1DigitSpanBck if sample4hpart==1 & HNDwave==1 & w1HCYtert==2
mi estimate: mean w1w3bayes1clock_command if sample4ipart==1 & HNDwave==1 & w1HCYtert==2
mi estimate: mean w1w3bayes1LnTrailsAtestSec if sample4jpart==1 & HNDwave==1 & w1HCYtert==2
mi estimate: mean w1w3bayes1LnTrailsBtestSec if sample4kpart==1 & HNDwave==1 & w1HCYtert==2

mi estimate: mean w1Folate if sample4apart==1 & HNDwave==1 & w1HCYtert==2
mi estimate: mean w1Folate_total if sample4apart==1 & HNDwave==1 & w1HCYtert==2
mi estimate: mean w1B12 if sample4apart==1 & HNDwave==1 & w1HCYtert==2
mi estimate: mean w1VitaminB12 if sample4apart==1 & HNDwave==1 & w1HCYtert==2



save, replace

**************HOMOCYSTEINE, third tertile************************

mi estimate: mean w1HCY if sample4apart==1 & HNDwave==1 & w1HCYtert==3
mi estimate: mean R_traj_ProbG2HCY if sample4apart==1 & HNDwave==1 & w1HCYtert==3

mi estimate: prop Sex  if sample4apart==1 & HNDwave==1 & w1HCYtert==3
mi estimate: mean w1Age  if sample4apart==1 & HNDwave==1 & w1HCYtert==3
mi estimate: prop Race  if sample4apart==1 & HNDwave==1 & w1HCYtert==3
mi estimate: prop PovStat  if sample4apart==1 & HNDwave==1 & w1HCYtert==3
mi estimate: prop w1edubr  if sample4apart==1 & HNDwave==1 & w1HCYtert==3
mi estimate: mean w1WRATtotal if sample4apart==1 & HNDwave==1 & w1HCYtert==3
mi estimate: prop w1currdrugs if sample4apart==1 & HNDwave==1 & w1HCYtert==3 
mi estimate: prop w1smoke if sample4apart==1 & HNDwave==1 & w1HCYtert==3
mi estimate: mean w1BMI if sample4apart==1 & HNDwave==1 & w1HCYtert==3
mi estimate: prop w1SRH if sample4apart==1 & HNDwave==1 & w1HCYtert==3
mi estimate: mean w1hei2010_total_score if sample4apart==1 & HNDwave==1 & w1HCYtert==3
mi estimate: mean w1CES if sample4apart==1 & HNDwave==1 & w1HCYtert==3
mi estimate: prop w1dxHTN if sample4apart==1 & HNDwave==1 & w1HCYtert==3
mi estimate: prop w1dxDiabetes if sample4apart==1 & HNDwave==1 & w1HCYtert==3
mi estimate: prop w1CVhighChol  if sample4apart==1 & HNDwave==1 & w1HCYtert==3
mi estimate: prop w1cvdbr  if sample4apart==1 & HNDwave==1 & w1HCYtert==3

mi estimate: mean MMStot if sample4apart==1 & HNDwave==1 & w1HCYtert==3
mi estimate: mean MMStotnorm if sample4apart==1 & HNDwave==1 & w1HCYtert==3
mi estimate: mean cvltca if sample4bpart==1 & HNDwave==1 & w1HCYtert==3
mi estimate: mean CVLfrl if sample4cpart==1 & HNDwave==1 & w1HCYtert==3
mi estimate: mean BVRtot if sample4dpart==1 & HNDwave==1 & w1HCYtert==3
mi estimate: mean Attention if sample4epart==1 & HNDwave==1 & w1HCYtert==3
mi estimate: mean FluencyWord if sample4fpart==1 & HNDwave==1 & w1HCYtert==3
mi estimate: mean DigitSpanFwd if sample4gpart==1 & HNDwave==1 & w1HCYtert==3
mi estimate: mean DigitSpanBck if sample4hpart==1 & HNDwave==1 & w1HCYtert==3
mi estimate: mean clock_command if sample4ipart==1 & HNDwave==1 & w1HCYtert==3
mi estimate: mean LnTrailsAtestSec if sample4jpart==1 & HNDwave==1 & w1HCYtert==3
mi estimate: mean LnTrailsBtestSec if sample4kpart==1 & HNDwave==1 & w1HCYtert==3

mi estimate: mean w1w3bayes1MMSE if sample4apart==1 & HNDwave==1 & w1HCYtert==3
mi estimate: mean w1w3bayes1cvltca if sample4bpart==1 & HNDwave==1 & w1HCYtert==3
mi estimate: mean w1w3bayes1CVLfrl if sample4cpart==1 & HNDwave==1 & w1HCYtert==3
mi estimate: mean w1w3bayes1BVRtot if sample4dpart==1 & HNDwave==1 & w1HCYtert==3
mi estimate: mean w1w3bayes1Attention if sample4epart==1 & HNDwave==1 & w1HCYtert==3
mi estimate: mean w1w3bayes1FluencyWord if sample4fpart==1 & HNDwave==1 & w1HCYtert==3
mi estimate: mean w1w3bayes1DigitSpanFwd if sample4gpart==1 & HNDwave==1 & w1HCYtert==3
mi estimate: mean w1w3bayes1DigitSpanBck if sample4hpart==1 & HNDwave==1 & w1HCYtert==3
mi estimate: mean w1w3bayes1clock_command if sample4ipart==1 & HNDwave==1 & w1HCYtert==3
mi estimate: mean w1w3bayes1LnTrailsAtestSec if sample4jpart==1 & HNDwave==1 & w1HCYtert==3
mi estimate: mean w1w3bayes1LnTrailsBtestSec if sample4kpart==1 & HNDwave==1 & w1HCYtert==3


mi estimate: mean w1Folate if sample4apart==1 & HNDwave==1 & w1HCYtert==3
mi estimate: mean w1Folate_total if sample4apart==1 & HNDwave==1 & w1HCYtert==3
mi estimate: mean w1B12 if sample4apart==1 & HNDwave==1 & w1HCYtert==3
mi estimate: mean w1VitaminB12 if sample4apart==1 & HNDwave==1 & w1HCYtert==3


save, replace


**************************Differences by HOMOCYSTEINE tertile*********************

mi estimate: reg w1HCY w1HCYtert if sample4apart==1 & HNDwave==1
mi estimate: reg w1HCY i.w1HCYtert if sample4apart==1 & HNDwave==1
mi estimate: reg w1HCY i.w1HCYtert w1Age Sex Race PovStat if sample4apart==1 & HNDwave==1

mi estimate: reg R_traj_ProbG2HCY w1HCYtert if sample4apart==1 & HNDwave==1
mi estimate: reg R_traj_ProbG2HCY i.w1HCYtert if sample4apart==1 & HNDwave==1
mi estimate: reg R_traj_ProbG2HCY i.w1HCYtert w1Age Sex Race PovStat if sample4apart==1 & HNDwave==1


tab Sex w1HCYtert if sample4apart==1 & HNDwave==1, row col chi
mi estimate: mlogit Sex i.w1HCYtert if sample4apart==1 & HNDwave==1, baseoutcome(1)
mi estimate: mlogit Sex i.w1HCYtert w1Age PovStat Race if sample4apart==1 & HNDwave==1, baseoutcome(1)



mi estimate: reg w1Age w1HCYtert if sample4apart==1 & HNDwave==1
mi estimate: reg w1Age i.w1HCYtert if sample4apart==1 & HNDwave==1
mi estimate: reg w1Age w1HCYtert Sex Race PovStat if sample4apart==1 & HNDwave==1


mi estimate: mlogit  Race w1HCYtert if sample4apart==1 & HNDwave==1, baseoutcome(1)
mi estimate: mlogit  Race i.w1HCYtert if sample4apart==1 & HNDwave==1, baseoutcome(1)
mi estimate: mlogit  Race i.w1HCYtert Sex w1Age PovStat if sample4apart==1 & HNDwave==1, baseoutcome(1)


mi estimate: mlogit  PovStat w1HCYtert if sample4apart==1 & HNDwave==1, baseoutcome(1)
mi estimate: mlogit  PovStat i.w1HCYtert if sample4apart==1 & HNDwave==1, baseoutcome(1)
mi estimate: mlogit  PovStat i.w1HCYtert w1Age Sex Race  if sample4apart==1 & HNDwave==1, baseoutcome(1)

mi estimate: mlogit w1edubr w1HCYtert if sample4apart==1 & HNDwave==1, baseoutcome(1)
mi estimate: mlogit w1edubr i.w1HCYtert if sample4apart==1 & HNDwave==1, baseoutcome(1)
mi estimate: mlogit  w1edubr i.w1HCYtert PovStat w1Age Sex Race if sample4apart==1 & HNDwave==1, baseoutcome(1)


mi estimate: reg w1WRATtotal w1HCYtert if sample4apart==1 & HNDwave==1
mi estimate: reg w1WRATtotal i.w1HCYtert if sample4apart==1 & HNDwave==1
mi estimate: reg w1WRATtotal i.w1HCYtert w1Age Sex Race PovStat if sample4apart==1 & HNDwave==1

mi estimate: mlogit w1currdrugs w1HCYtert if sample4apart==1 & HNDwave==1, baseoutcome(1)
mi estimate: mlogit w1currdrugs i.w1HCYtert if sample4apart==1 & HNDwave==1, baseoutcome(1)
mi estimate: mlogit w1currdrugs i.w1HCYtert PovStat w1Age Sex Race if sample4apart==1 & HNDwave==1, baseoutcome(1)

 
mi estimate: mlogit w1smoke w1HCYtert if sample4apart==1 & HNDwave==1, baseoutcome(1)
mi estimate: mlogit w1smoke i.w1HCYtert if sample4apart==1 & HNDwave==1, baseoutcome(1)
mi estimate: mlogit w1smoke i.w1HCYtert PovStat w1Age Sex Race if sample4apart==1 & HNDwave==1, baseoutcome(1)

mi estimate: reg w1BMI w1HCYtert if sample4apart==1 & HNDwave==1
mi estimate: reg w1BMI i.w1HCYtert if sample4apart==1 & HNDwave==1
mi estimate: reg w1BMI i.w1HCYtert w1Age Sex Race PovStat if sample4apart==1 & HNDwave==1

mi estimate: mlogit w1SRH w1HCYtert if sample4apart==1 & HNDwave==1, baseoutcome(1)
mi estimate: mlogit w1SRH i.w1HCYtert if sample4apart==1 & HNDwave==1, baseoutcome(1)
mi estimate: mlogit w1SRH i.w1HCYtert PovStat w1Age Sex Race if sample4apart==1 & HNDwave==1, baseoutcome(1)



mi estimate: reg w1hei2010_total_score w1HCYtert if sample4apart==1 & HNDwave==1
mi estimate: reg w1hei2010_total_score i.w1HCYtert if sample4apart==1 & HNDwave==1
mi estimate: reg w1hei2010_total_score i.w1HCYtert w1Age Sex Race PovStat if sample4apart==1 & HNDwave==1




mi estimate: reg w1CES w1HCYtert if sample4apart==1 & HNDwave==1
mi estimate: reg w1CES i.w1HCYtert if sample4apart==1 & HNDwave==1
mi estimate: reg w1CES i.w1HCYtert w1Age Sex Race PovStat if sample4apart==1 & HNDwave==1


mi estimate: mlogit w1dxHTN w1HCYtert if sample4apart==1 & HNDwave==1, baseoutcome(1)
mi estimate: mlogit w1dxHTN i.w1HCYtert if sample4apart==1 & HNDwave==1, baseoutcome(1)
mi estimate: mlogit w1dxHTN i.w1HCYtert PovStat w1Age Sex Race if sample4apart==1 & HNDwave==1, baseoutcome(1)


mi estimate: mlogit w1dxDiabetes w1HCYtert if sample4apart==1 & HNDwave==1, baseoutcome(1)
mi estimate: mlogit w1dxDiabetes i.w1HCYtert if sample4apart==1 & HNDwave==1, baseoutcome(1)
mi estimate: mlogit w1dxDiabetes i.w1HCYtert PovStat w1Age Sex Race if sample4apart==1 & HNDwave==1, baseoutcome(1)



mi estimate: mlogit w1CVhighChol w1HCYtert if sample4apart==1 & HNDwave==1, baseoutcome(1)
mi estimate: mlogit w1CVhighChol i.w1HCYtert if sample4apart==1 & HNDwave==1, baseoutcome(1)
mi estimate: mlogit w1CVhighChol i.w1HCYtert PovStat w1Age Sex Race if sample4apart==1 & HNDwave==1, baseoutcome(1)


mi estimate: mlogit w1cvdbr w1HCYtert if sample4apart==1 & HNDwave==1, baseoutcome(1)
mi estimate: mlogit w1cvdbr i.w1HCYtert if sample4apart==1 & HNDwave==1, baseoutcome(1)
mi estimate: mlogit w1cvdbr i.w1HCYtert PovStat w1Age Sex Race if sample4apart==1 & HNDwave==1, baseoutcome(1)


***VISIT 1 COGNITIVE TEST SCORES************

mi estimate: reg MMStot w1HCYtert if sample4apart==1 & HNDwave==1
mi estimate: reg MMStot i.w1HCYtert if sample4apart==1 & HNDwave==1
mi estimate: reg MMStot i.w1HCYtert w1Age Sex Race PovStat if sample4apart==1 & HNDwave==1


mi estimate: reg MMStotnorm w1HCYtert if sample4apart==1 & HNDwave==1
mi estimate: reg MMStotnorm i.w1HCYtert if sample4apart==1 & HNDwave==1
mi estimate: reg MMStotnorm i.w1HCYtert w1Age Sex Race PovStat if sample4apart==1 & HNDwave==1



mi estimate: reg cvltca w1HCYtert if sample4bpart==1 & HNDwave==1
mi estimate: reg cvltca i.w1HCYtert if sample4bpart==1 & HNDwave==1
mi estimate: reg cvltca i.w1HCYtert w1Age Sex Race PovStat if sample4bpart==1 & HNDwave==1



mi estimate: reg CVLfrl w1HCYtert if sample4cpart==1 & HNDwave==1
mi estimate: reg CVLfrl i.w1HCYtert if sample4cpart==1 & HNDwave==1
mi estimate: reg CVLfrl i.w1HCYtert w1Age Sex Race PovStat if sample4cpart==1 & HNDwave==1


mi estimate: reg BVRtot w1HCYtert if sample4dpart==1 & HNDwave==1
mi estimate: reg BVRtot i.w1HCYtert if sample4dpart==1 & HNDwave==1
mi estimate: reg BVRtot i.w1HCYtert w1Age Sex Race PovStat if sample4dpart==1 & HNDwave==1



mi estimate: reg Attention w1HCYtert if sample4epart==1 & HNDwave==1
mi estimate: reg Attention i.w1HCYtert if sample4epart==1 & HNDwave==1
mi estimate: reg Attention i.w1HCYtert w1Age Sex Race PovStat if sample4epart==1 & HNDwave==1


mi estimate: reg FluencyWord w1HCYtert if sample4fpart==1 & HNDwave==1
mi estimate: reg FluencyWord i.w1HCYtert if sample4fpart==1 & HNDwave==1
mi estimate: reg FluencyWord i.w1HCYtert w1Age Sex Race PovStat if sample4fpart==1 & HNDwave==1


mi estimate: reg DigitSpanFwd w1HCYtert if sample4gpart==1 & HNDwave==1
mi estimate: reg DigitSpanFwd i.w1HCYtert if sample4gpart==1 & HNDwave==1
mi estimate: reg DigitSpanFwd i.w1HCYtert w1Age Sex Race PovStat if sample4gpart==1 & HNDwave==1


mi estimate: reg DigitSpanBck w1HCYtert if sample4hpart==1 & HNDwave==1
mi estimate: reg DigitSpanBck i.w1HCYtert if sample4hpart==1 & HNDwave==1
mi estimate: reg DigitSpanBck i.w1HCYtert w1Age Sex Race PovStat if sample4hpart==1 & HNDwave==1


mi estimate: reg clock_command w1HCYtert if sample4ipart==1 & HNDwave==1
mi estimate: reg clock_command i.w1HCYtert if sample4ipart==1 & HNDwave==1
mi estimate: reg clock_command i.w1HCYtert w1Age Sex Race PovStat if sample4ipart==1 & HNDwave==1



mi estimate: reg LnTrailsAtestSec w1HCYtert if sample4jpart==1 & HNDwave==1
mi estimate: reg LnTrailsAtestSec i.w1HCYtert if sample4jpart==1 & HNDwave==1
mi estimate: reg LnTrailsAtestSec i.w1HCYtert w1Age Sex Race PovStat if sample4jpart==1 & HNDwave==1



mi estimate: reg LnTrailsBtestSec w1HCYtert if sample4kpart==1 & HNDwave==1
mi estimate: reg LnTrailsBtestSec i.w1HCYtert if sample4kpart==1 & HNDwave==1
mi estimate: reg LnTrailsBtestSec i.w1HCYtert w1Age Sex Race PovStat if sample4kpart==1 & HNDwave==1

********Annual rate of change**************

mi estimate: reg w1w3bayes1MMSE w1HCYtert if sample4apart==1 & HNDwave==1
mi estimate: reg w1w3bayes1MMSE i.w1HCYtert if sample4apart==1 & HNDwave==1
mi estimate: reg w1w3bayes1MMSE i.w1HCYtert w1Age Sex Race PovStat if sample4apart==1 & HNDwave==1

mi estimate: reg w1w3bayes1cvltca w1HCYtert if sample4bpart==1 & HNDwave==1
mi estimate: reg w1w3bayes1cvltca i.w1HCYtert if sample4bpart==1 & HNDwave==1
mi estimate: reg w1w3bayes1cvltca i.w1HCYtert w1Age Sex Race PovStat if sample4bpart==1 & HNDwave==1


mi estimate: reg w1w3bayes1CVLfrl w1HCYtert if sample4cpart==1 & HNDwave==1
mi estimate: reg w1w3bayes1CVLfrl i.w1HCYtert if sample4cpart==1 & HNDwave==1
mi estimate: reg w1w3bayes1CVLfrl i.w1HCYtert w1Age Sex Race PovStat if sample4cpart==1 & HNDwave==1


mi estimate: reg w1w3bayes1BVRtot w1HCYtert if sample4dpart==1 & HNDwave==1
mi estimate: reg w1w3bayes1BVRtot i.w1HCYtert if sample4dpart==1 & HNDwave==1
mi estimate: reg w1w3bayes1BVRtot i.w1HCYtert w1Age Sex Race PovStat if sample4dpart==1 & HNDwave==1

mi estimate: reg w1w3bayes1Attention w1HCYtert if sample4epart==1 & HNDwave==1
mi estimate: reg w1w3bayes1Attention i.w1HCYtert if sample4epart==1 & HNDwave==1
mi estimate: reg w1w3bayes1Attention i.w1HCYtert w1Age Sex Race PovStat if sample4epart==1 & HNDwave==1


mi estimate: reg w1w3bayes1FluencyWord w1HCYtert if sample4fpart==1 & HNDwave==1
mi estimate: reg w1w3bayes1FluencyWord i.w1HCYtert if sample4fpart==1 & HNDwave==1
mi estimate: reg w1w3bayes1FluencyWord i.w1HCYtert w1Age Sex Race PovStat if sample4fpart==1 & HNDwave==1



mi estimate: reg w1w3bayes1DigitSpanFwd w1HCYtert if sample4gpart==1 & HNDwave==1
mi estimate: reg w1w3bayes1DigitSpanFwd i.w1HCYtert if sample4gpart==1 & HNDwave==1
mi estimate: reg w1w3bayes1DigitSpanFwd i.w1HCYtert w1Age Sex Race PovStat if sample4gpart==1 & HNDwave==1


mi estimate: reg w1w3bayes1DigitSpanBck w1HCYtert if sample4hpart==1 & HNDwave==1
mi estimate: reg w1w3bayes1DigitSpanBck i.w1HCYtert if sample4hpart==1 & HNDwave==1
mi estimate: reg w1w3bayes1DigitSpanBck i.w1HCYtert w1Age Sex Race PovStat if sample4hpart==1 & HNDwave==1


mi estimate: reg w1w3bayes1clock_command w1HCYtert if sample4ipart==1 & HNDwave==1
mi estimate: reg w1w3bayes1clock_command i.w1HCYtert if sample4ipart==1 & HNDwave==1
mi estimate: reg w1w3bayes1clock_command i.w1HCYtert w1Age Sex Race PovStat if sample4ipart==1 & HNDwave==1


mi estimate: reg w1w3bayes1LnTrailsAtestSec w1HCYtert if sample4jpart==1 & HNDwave==1
mi estimate: reg w1w3bayes1LnTrailsAtestSec i.w1HCYtert if sample4jpart==1 & HNDwave==1
mi estimate: reg w1w3bayes1LnTrailsAtestSec i.w1HCYtert w1Age Sex Race PovStat if sample4jpart==1 & HNDwave==1


mi estimate: reg w1w3bayes1LnTrailsBtestSec w1HCYtert if sample4kpart==1 & HNDwave==1
mi estimate: reg w1w3bayes1LnTrailsBtestSec i.w1HCYtert if sample4kpart==1 & HNDwave==1
mi estimate: reg w1w3bayes1LnTrailsBtestSec i.w1HCYtert w1Age Sex Race PovStat if sample4kpart==1 & HNDwave==1


*****

mi estimate: reg w1Folate  w1HCYtert if sample4apart==1 & HNDwave==1 
mi estimate: reg w1Folate  i.w1HCYtert if sample4apart==1 & HNDwave==1 
mi estimate: reg w1Folate w1Age Sex Race PovStat i.w1HCYtert if sample4apart==1 & HNDwave==1 


mi estimate: reg w1Folate_total  w1HCYtert if sample4apart==1 & HNDwave==1 
mi estimate: reg w1Folate_total  i.w1HCYtert if sample4apart==1 & HNDwave==1 
mi estimate: reg w1Folate_total w1Age Sex Race PovStat i.w1HCYtert if sample4apart==1 & HNDwave==1 


mi estimate: reg w1B12  w1HCYtert if sample4apart==1 & HNDwave==1 
mi estimate: reg w1B12  i.w1HCYtert if sample4apart==1 & HNDwave==1 
mi estimate: reg w1B12 w1Age Sex Race PovStat i.w1HCYtert if sample4apart==1 & HNDwave==1 

mi estimate: reg w1VitaminB12  w1HCYtert if sample4apart==1 & HNDwave==1 
mi estimate: reg w1VitaminB12  i.w1HCYtert if sample4apart==1 & HNDwave==1 
mi estimate: reg w1VitaminB12 w1Age Sex Race PovStat i.w1HCYtert if sample4apart==1 & HNDwave==1 




save, replace



capture log close

log using "E:\HANDLS_PAPER65_HCY_COGN\OUTPUT\TABLE2.smcl", replace

use finaldata_imputed_FINAL,clear


*******************************TABLE 2: BASELINE HOMOCYSTEINE VS. COGNITIVE CHANGE OVER TIME: OVERALL**************************************

//MODEL 1: INCLUDE ONLY AGE, SEX, RACE AND POVERTY STATUS///
mi estimate: mixed MMStot  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat  c.timew1w3##c.invmillsmms ///
c.timew1w3##c.w1HCYcenter2p15   ///
if sample4aobs==1 || HNDID: timew1w3, cov(un)


mi estimate: mixed MMStotnorm  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat  c.timew1w3##c.invmillsmms ///
c.timew1w3##c.w1HCYcenter2p15   ///
if sample4aobs==1 || HNDID: timew1w3, cov(un)



mi estimate: mixed cvltca  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat  c.timew1w3##c.invmillsmms ///
c.timew1w3##c.w1HCYcenter2p15   ///
if sample4bobs==1 || HNDID: timew1w3



mi estimate: mixed CVLfrl  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat  c.timew1w3##c.invmillsmms ///
c.timew1w3##c.w1HCYcenter2p15   ///
if sample4cobs==1 || HNDID: timew1w3



mi estimate: mixed BVRtot  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat  c.timew1w3##c.invmillsmms ///
c.timew1w3##c.w1HCYcenter2p15   ///
if sample4dobs==1 || HNDID: timew1w3, cov(un)


mi estimate: mixed Attention  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat  c.timew1w3##c.invmillsmms ///
c.timew1w3##c.w1HCYcenter2p15   ///
if sample4eobs==1 || HNDID: timew1w3, cov(un)

mi estimate: mixed FluencyWord  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat  c.timew1w3##c.invmillsmms ///
c.timew1w3##c.w1HCYcenter2p15   ///
if sample4fobs==1 || HNDID: timew1w3, cov(un)

mi estimate: mixed DigitSpanFwd  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat  c.timew1w3##c.invmillsmms ///
c.timew1w3##c.w1HCYcenter2p15   ///
if sample4gobs==1 || HNDID: timew1w3, cov(un)

mi estimate: mixed DigitSpanBck  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat  c.timew1w3##c.invmillsmms ///
c.timew1w3##c.w1HCYcenter2p15   ///
if sample4hobs==1 || HNDID: timew1w3, cov(un)

mi estimate: mixed clock_command  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat  c.timew1w3##c.invmillsmms ///
c.timew1w3##c.w1HCYcenter2p15   ///
if sample4iobs==1 || HNDID: timew1w3, cov(un)

mi estimate: mixed LnTrailsAtestSec  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat  c.timew1w3##c.invmillsmms ///
c.timew1w3##c.w1HCYcenter2p15   ///
if sample4jobs==1 || HNDID: timew1w3

mi estimate: mixed LnTrailsBtestSec  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat  c.timew1w3##c.invmillsmms ///
c.timew1w3##c.w1HCYcenter2p15   ///
if sample4kobs==1  || HNDID: timew1w3, cov(un)


save, replace



//MODEL 2: MODEL 1 + BODY MASS INDEX///

mi estimate: mixed MMStot  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat c.timew1w3##w1edubr c.timew1w3##c.w1WRATtotalcent42   ///
c.timew1w3##w1smoke  c.timew1w3##w1currdrugs c.timew1w3##c.w1hei2010_total_scorecent43  c.timew1w3##c.w1BMIcent30  c.timew1w3##c.invmillsmms ///
c.timew1w3##c.w1HCYcenter2p15   ///
if sample4aobs==1 || HNDID: timew1w3, cov(un)


mi estimate: mixed MMStotnorm  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat c.timew1w3##w1edubr c.timew1w3##c.w1WRATtotalcent42   ///
c.timew1w3##w1smoke  c.timew1w3##w1currdrugs c.timew1w3##c.w1hei2010_total_scorecent43  c.timew1w3##c.w1BMIcent30  c.timew1w3##c.invmillsmms ///
c.timew1w3##c.w1HCYcenter2p15   ///
if sample4aobs==1 || HNDID: timew1w3



mi estimate: mixed cvltca  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat c.timew1w3##w1edubr c.timew1w3##c.w1WRATtotalcent42   ///
c.timew1w3##w1smoke  c.timew1w3##w1currdrugs c.timew1w3##c.w1hei2010_total_scorecent43  c.timew1w3##c.w1BMIcent30  c.timew1w3##c.invmillsmms ///
c.timew1w3##c.w1HCYcenter2p15   ///
if sample4bobs==1 || HNDID: timew1w3



mi estimate: mixed CVLfrl  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat c.timew1w3##w1edubr c.timew1w3##c.w1WRATtotalcent42   ///
c.timew1w3##w1smoke  c.timew1w3##w1currdrugs c.timew1w3##c.w1hei2010_total_scorecent43  c.timew1w3##c.w1BMIcent30  c.timew1w3##c.invmillsmms ///
c.timew1w3##c.w1HCYcenter2p15   ///
if sample4cobs==1 || HNDID: timew1w3



mi estimate: mixed BVRtot  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat c.timew1w3##w1edubr c.timew1w3##c.w1WRATtotalcent42   ///
c.timew1w3##w1smoke  c.timew1w3##w1currdrugs c.timew1w3##c.w1hei2010_total_scorecent43  c.timew1w3##c.w1BMIcent30  c.timew1w3##c.invmillsmms ///
c.timew1w3##c.w1HCYcenter2p15   ///
if sample4dobs==1 || HNDID: timew1w3, cov(un)


mi estimate: mixed Attention  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat c.timew1w3##w1edubr c.timew1w3##c.w1WRATtotalcent42   ///
c.timew1w3##w1smoke  c.timew1w3##w1currdrugs c.timew1w3##c.w1hei2010_total_scorecent43  c.timew1w3##c.w1BMIcent30  c.timew1w3##c.invmillsmms ///
c.timew1w3##c.w1HCYcenter2p15   ///
if sample4eobs==1 || HNDID: timew1w3, cov(un)

mi estimate: mixed FluencyWord  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat c.timew1w3##w1edubr c.timew1w3##c.w1WRATtotalcent42   ///
c.timew1w3##w1smoke  c.timew1w3##w1currdrugs c.timew1w3##c.w1hei2010_total_scorecent43  c.timew1w3##c.w1BMIcent30  c.timew1w3##c.invmillsmms ///
c.timew1w3##c.w1HCYcenter2p15   ///
if sample4fobs==1 || HNDID: timew1w3, cov(un)

mi estimate: mixed DigitSpanFwd  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat c.timew1w3##w1edubr c.timew1w3##c.w1WRATtotalcent42   ///
c.timew1w3##w1smoke  c.timew1w3##w1currdrugs c.timew1w3##c.w1hei2010_total_scorecent43  c.timew1w3##c.w1BMIcent30  c.timew1w3##c.invmillsmms ///
c.timew1w3##c.w1HCYcenter2p15   ///
if sample4gobs==1 || HNDID: timew1w3, cov(un)

mi estimate: mixed DigitSpanBck  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat c.timew1w3##w1edubr c.timew1w3##c.w1WRATtotalcent42   ///
c.timew1w3##w1smoke  c.timew1w3##w1currdrugs c.timew1w3##c.w1hei2010_total_scorecent43  c.timew1w3##c.w1BMIcent30 c.timew1w3##c.invmillsmms ///
c.timew1w3##c.w1HCYcenter2p15   ///
if sample4hobs==1 || HNDID:

mi estimate: mixed clock_command  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat c.timew1w3##w1edubr c.timew1w3##c.w1WRATtotalcent42   ///
c.timew1w3##w1smoke  c.timew1w3##w1currdrugs c.timew1w3##c.w1hei2010_total_scorecent43  c.timew1w3##c.w1BMIcent30  c.timew1w3##c.invmillsmms ///
c.timew1w3##c.w1HCYcenter2p15   ///
if sample4iobs==1 || HNDID: timew1w3, cov(un)

mi estimate: mixed LnTrailsAtestSec  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat c.timew1w3##w1edubr c.timew1w3##c.w1WRATtotalcent42   ///
c.timew1w3##w1smoke  c.timew1w3##w1currdrugs c.timew1w3##c.w1hei2010_total_scorecent43  c.timew1w3##c.w1BMIcent30  c.timew1w3##c.invmillsmms ///
c.timew1w3##c.w1HCYcenter2p15   ///
if sample4jobs==1 || HNDID: timew1w3

mi estimate: mixed LnTrailsBtestSec  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat c.timew1w3##w1edubr c.timew1w3##c.w1WRATtotalcent42   ///
c.timew1w3##w1smoke  c.timew1w3##w1currdrugs c.timew1w3##c.w1hei2010_total_scorecent43  c.timew1w3##c.w1BMIcent30  c.timew1w3##c.invmillsmms ///
c.timew1w3##c.w1HCYcenter2p15   ///
if sample4kobs==1  || HNDID: timew1w3, cov(un)


save, replace


//MODEL 3: FULLY ADJUSTED MODEL: MODEL 2 + HEALTH-RELATED FACTORS///

mi estimate: mixed MMStot  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat c.timew1w3##w1edubr c.timew1w3##c.w1WRATtotalcent42   ///
c.timew1w3##w1smoke  c.timew1w3##w1currdrugs c.timew1w3##c.w1hei2010_total_scorecent43  c.timew1w3##c.w1BMIcent30 c.timew1w3##w1SRH c.timew1w3##c.w1CEScent15 c.timew1w3##w1dxHTN c.timew1w3##w1dxDiabetes c.timew1w3##w1CVhighChol c.timew1w3##w1cvdbr c.timew1w3##c.invmillsmms ///
c.timew1w3##c.w1HCYcenter2p15   ///
if sample4aobs==1 || HNDID: timew1w3, cov(un)


mi estimate: mixed MMStotnorm  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat c.timew1w3##w1edubr c.timew1w3##c.w1WRATtotalcent42   ///
c.timew1w3##w1smoke  c.timew1w3##w1currdrugs c.timew1w3##c.w1hei2010_total_scorecent43  c.timew1w3##c.w1BMIcent30 c.timew1w3##w1SRH c.timew1w3##c.w1CEScent15 c.timew1w3##w1dxHTN c.timew1w3##w1dxDiabetes c.timew1w3##w1CVhighChol c.timew1w3##w1cvdbr c.timew1w3##c.invmillsmms ///
c.timew1w3##c.w1HCYcenter2p15   ///
if sample4aobs==1 || HNDID: timew1w3



mi estimate: mixed cvltca  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat c.timew1w3##w1edubr c.timew1w3##c.w1WRATtotalcent42   ///
c.timew1w3##w1smoke  c.timew1w3##w1currdrugs c.timew1w3##c.w1hei2010_total_scorecent43  c.timew1w3##c.w1BMIcent30 c.timew1w3##w1SRH c.timew1w3##c.w1CEScent15 c.timew1w3##w1dxHTN c.timew1w3##w1dxDiabetes c.timew1w3##w1CVhighChol c.timew1w3##w1cvdbr c.timew1w3##c.invmillsmms ///
c.timew1w3##c.w1HCYcenter2p15   ///
if sample4bobs==1 || HNDID: timew1w3



mi estimate: mixed CVLfrl  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat c.timew1w3##w1edubr c.timew1w3##c.w1WRATtotalcent42   ///
c.timew1w3##w1smoke  c.timew1w3##w1currdrugs c.timew1w3##c.w1hei2010_total_scorecent43  c.timew1w3##c.w1BMIcent30 c.timew1w3##w1SRH c.timew1w3##c.w1CEScent15 c.timew1w3##w1dxHTN c.timew1w3##w1dxDiabetes c.timew1w3##w1CVhighChol c.timew1w3##w1cvdbr c.timew1w3##c.invmillsmms ///
c.timew1w3##c.w1HCYcenter2p15   ///
if sample4cobs==1 || HNDID: timew1w3



mi estimate: mixed BVRtot  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat c.timew1w3##w1edubr c.timew1w3##c.w1WRATtotalcent42   ///
c.timew1w3##w1smoke  c.timew1w3##w1currdrugs c.timew1w3##c.w1hei2010_total_scorecent43  c.timew1w3##c.w1BMIcent30 c.timew1w3##w1SRH c.timew1w3##c.w1CEScent15 c.timew1w3##w1dxHTN c.timew1w3##w1dxDiabetes c.timew1w3##w1CVhighChol c.timew1w3##w1cvdbr c.timew1w3##c.invmillsmms ///
c.timew1w3##c.w1HCYcenter2p15   ///
if sample4dobs==1 || HNDID: timew1w3, cov(un)


mi estimate: mixed Attention  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat c.timew1w3##w1edubr c.timew1w3##c.w1WRATtotalcent42   ///
c.timew1w3##w1smoke  c.timew1w3##w1currdrugs c.timew1w3##c.w1hei2010_total_scorecent43  c.timew1w3##c.w1BMIcent30 c.timew1w3##w1SRH c.timew1w3##c.w1CEScent15 c.timew1w3##w1dxHTN c.timew1w3##w1dxDiabetes c.timew1w3##w1CVhighChol c.timew1w3##w1cvdbr c.timew1w3##c.invmillsmms ///
c.timew1w3##c.w1HCYcenter2p15   ///
if sample4eobs==1 || HNDID: timew1w3, cov(un)

mi estimate: mixed FluencyWord  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat c.timew1w3##w1edubr c.timew1w3##c.w1WRATtotalcent42   ///
c.timew1w3##w1smoke  c.timew1w3##w1currdrugs c.timew1w3##c.w1hei2010_total_scorecent43  c.timew1w3##c.w1BMIcent30 c.timew1w3##w1SRH c.timew1w3##c.w1CEScent15 c.timew1w3##w1dxHTN c.timew1w3##w1dxDiabetes c.timew1w3##w1CVhighChol c.timew1w3##w1cvdbr c.timew1w3##c.invmillsmms ///
c.timew1w3##c.w1HCYcenter2p15   ///
if sample4fobs==1 || HNDID: timew1w3, cov(un)

mi estimate: mixed DigitSpanFwd  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat c.timew1w3##w1edubr c.timew1w3##c.w1WRATtotalcent42   ///
c.timew1w3##w1smoke  c.timew1w3##w1currdrugs c.timew1w3##c.w1hei2010_total_scorecent43  c.timew1w3##c.w1BMIcent30 c.timew1w3##w1SRH c.timew1w3##c.w1CEScent15 c.timew1w3##w1dxHTN c.timew1w3##w1dxDiabetes c.timew1w3##w1CVhighChol c.timew1w3##w1cvdbr c.timew1w3##c.invmillsmms ///
c.timew1w3##c.w1HCYcenter2p15   ///
if sample4gobs==1 || HNDID: timew1w3, cov(un)

mi estimate: mixed DigitSpanBck  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat c.timew1w3##w1edubr c.timew1w3##c.w1WRATtotalcent42   ///
c.timew1w3##w1smoke  c.timew1w3##w1currdrugs c.timew1w3##c.w1hei2010_total_scorecent43  c.timew1w3##c.w1BMIcent30 c.timew1w3##w1SRH c.timew1w3##c.w1CEScent15 c.timew1w3##w1dxHTN c.timew1w3##w1dxDiabetes c.timew1w3##w1CVhighChol c.timew1w3##w1cvdbr c.timew1w3##c.invmillsmms ///
c.timew1w3##c.w1HCYcenter2p15   ///
if sample4hobs==1 || HNDID: timew1w3, cov(un)

mi estimate: mixed clock_command  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat c.timew1w3##w1edubr c.timew1w3##c.w1WRATtotalcent42   ///
c.timew1w3##w1smoke  c.timew1w3##w1currdrugs c.timew1w3##c.w1hei2010_total_scorecent43  c.timew1w3##c.w1BMIcent30 c.timew1w3##w1SRH c.timew1w3##c.w1CEScent15 c.timew1w3##w1dxHTN c.timew1w3##w1dxDiabetes c.timew1w3##w1CVhighChol c.timew1w3##w1cvdbr c.timew1w3##c.invmillsmms ///
c.timew1w3##c.w1HCYcenter2p15   ///
if sample4iobs==1 || HNDID: timew1w3, cov(un)

mi estimate: mixed LnTrailsAtestSec  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat c.timew1w3##w1edubr c.timew1w3##c.w1WRATtotalcent42   ///
c.timew1w3##w1smoke  c.timew1w3##w1currdrugs c.timew1w3##c.w1hei2010_total_scorecent43  c.timew1w3##c.w1BMIcent30 c.timew1w3##w1SRH c.timew1w3##c.w1CEScent15 c.timew1w3##w1dxHTN c.timew1w3##w1dxDiabetes c.timew1w3##w1CVhighChol c.timew1w3##w1cvdbr c.timew1w3##c.invmillsmms ///
c.timew1w3##c.w1HCYcenter2p15   ///
if sample4jobs==1 || HNDID: timew1w3

mi estimate: mixed LnTrailsBtestSec  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat c.timew1w3##w1edubr c.timew1w3##c.w1WRATtotalcent42   ///
c.timew1w3##w1smoke  c.timew1w3##w1currdrugs c.timew1w3##c.w1hei2010_total_scorecent43  c.timew1w3##c.w1BMIcent30 c.timew1w3##w1SRH c.timew1w3##c.w1CEScent15 c.timew1w3##w1dxHTN c.timew1w3##w1dxDiabetes c.timew1w3##w1CVhighChol c.timew1w3##w1cvdbr c.timew1w3##c.invmillsmms ///
c.timew1w3##c.w1HCYcenter2p15   ///
if sample4kobs==1  || HNDID: timew1w3, cov(un)


save, replace

*******************************TABLE 2: HOMOCYSTEINE AT BASELINE VS. COGNITIVE CHANGE OVER TIME: WOMEN**************************************


//MODEL 1: INCLUDE ONLY AGE, SEX, RACE AND POVERTY STATUS///
mi estimate: mixed MMStot  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat  c.timew1w3##c.invmillsmms ///
c.timew1w3##c.w1HCYcenter2p15   ///
if sample4aobs==1 & Sex==1 || HNDID: timew1w3, cov(un)


mi estimate: mixed MMStotnorm  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat  c.timew1w3##c.invmillsmms ///
c.timew1w3##c.w1HCYcenter2p15   ///
if sample4aobs==1 & Sex==1 || HNDID: timew1w3, cov(un)



mi estimate: mixed cvltca  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat  c.timew1w3##c.invmillsmms ///
c.timew1w3##c.w1HCYcenter2p15   ///
if sample4bobs==1 & Sex==1 || HNDID: timew1w3



mi estimate: mixed CVLfrl  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat  c.timew1w3##c.invmillsmms ///
c.timew1w3##c.w1HCYcenter2p15   ///
if sample4cobs==1 & Sex==1 || HNDID: timew1w3



mi estimate: mixed BVRtot  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat  c.timew1w3##c.invmillsmms ///
c.timew1w3##c.w1HCYcenter2p15   ///
if sample4dobs==1 & Sex==1 || HNDID: timew1w3, cov(un)


mi estimate: mixed Attention  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat  c.timew1w3##c.invmillsmms ///
c.timew1w3##c.w1HCYcenter2p15   ///
if sample4eobs==1 & Sex==1 || HNDID: timew1w3, cov(un)

mi estimate: mixed FluencyWord  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat  c.timew1w3##c.invmillsmms ///
c.timew1w3##c.w1HCYcenter2p15   ///
if sample4fobs==1 & Sex==1 || HNDID: timew1w3, cov(un)

mi estimate: mixed DigitSpanFwd  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat  c.timew1w3##c.invmillsmms ///
c.timew1w3##c.w1HCYcenter2p15   ///
if sample4gobs==1 & Sex==1 || HNDID: timew1w3, cov(un)

mi estimate: mixed DigitSpanBck  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat  c.timew1w3##c.invmillsmms ///
c.timew1w3##c.w1HCYcenter2p15   ///
if sample4hobs==1 & Sex==1 || HNDID: timew1w3

mi estimate: mixed clock_command  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat  c.timew1w3##c.invmillsmms ///
c.timew1w3##c.w1HCYcenter2p15   ///
if sample4iobs==1 & Sex==1 || HNDID: timew1w3, cov(un)

mi estimate: mixed LnTrailsAtestSec  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat  c.timew1w3##c.invmillsmms ///
c.timew1w3##c.w1HCYcenter2p15   ///
if sample4jobs==1 & Sex==1 || HNDID: timew1w3

mi estimate: mixed LnTrailsBtestSec  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat  c.timew1w3##c.invmillsmms ///
c.timew1w3##c.w1HCYcenter2p15   ///
if sample4kobs==1  & Sex==1 || HNDID: timew1w3, cov(un)


save, replace



//MODEL 2: MODEL 1 + BODY MASS INDEX///

mi estimate: mixed MMStot  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat c.timew1w3##w1edubr c.timew1w3##c.w1WRATtotalcent42   ///
c.timew1w3##w1smoke  c.timew1w3##w1currdrugs c.timew1w3##c.w1hei2010_total_scorecent43  c.timew1w3##c.w1BMIcent30  c.timew1w3##c.invmillsmms ///
c.timew1w3##c.w1HCYcenter2p15   ///
if sample4aobs==1 & Sex==1 || HNDID: timew1w3, cov(un)


mi estimate: mixed MMStotnorm  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat c.timew1w3##w1edubr c.timew1w3##c.w1WRATtotalcent42   ///
c.timew1w3##w1smoke  c.timew1w3##w1currdrugs c.timew1w3##c.w1hei2010_total_scorecent43  c.timew1w3##c.w1BMIcent30  c.timew1w3##c.invmillsmms ///
c.timew1w3##c.w1HCYcenter2p15   ///
if sample4aobs==1 & Sex==1 || HNDID: timew1w3, cov(un)



mi estimate: mixed cvltca  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat c.timew1w3##w1edubr c.timew1w3##c.w1WRATtotalcent42   ///
c.timew1w3##w1smoke  c.timew1w3##w1currdrugs c.timew1w3##c.w1hei2010_total_scorecent43  c.timew1w3##c.w1BMIcent30  c.timew1w3##c.invmillsmms ///
c.timew1w3##c.w1HCYcenter2p15   ///
if sample4bobs==1 & Sex==1 || HNDID: timew1w3



mi estimate: mixed CVLfrl  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat c.timew1w3##w1edubr c.timew1w3##c.w1WRATtotalcent42   ///
c.timew1w3##w1smoke  c.timew1w3##w1currdrugs c.timew1w3##c.w1hei2010_total_scorecent43  c.timew1w3##c.w1BMIcent30  c.timew1w3##c.invmillsmms ///
c.timew1w3##c.w1HCYcenter2p15   ///
if sample4cobs==1 & Sex==1 || HNDID: timew1w3



mi estimate: mixed BVRtot  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat c.timew1w3##w1edubr c.timew1w3##c.w1WRATtotalcent42   ///
c.timew1w3##w1smoke  c.timew1w3##w1currdrugs c.timew1w3##c.w1hei2010_total_scorecent43  c.timew1w3##c.w1BMIcent30  c.timew1w3##c.invmillsmms ///
c.timew1w3##c.w1HCYcenter2p15   ///
if sample4dobs==1 & Sex==1 || HNDID: timew1w3, cov(un)


mi estimate: mixed Attention  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat c.timew1w3##w1edubr c.timew1w3##c.w1WRATtotalcent42   ///
c.timew1w3##w1smoke  c.timew1w3##w1currdrugs c.timew1w3##c.w1hei2010_total_scorecent43  c.timew1w3##c.w1BMIcent30  c.timew1w3##c.invmillsmms ///
c.timew1w3##c.w1HCYcenter2p15   ///
if sample4eobs==1 & Sex==1 || HNDID: timew1w3, cov(un)

mi estimate: mixed FluencyWord  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat c.timew1w3##w1edubr c.timew1w3##c.w1WRATtotalcent42   ///
c.timew1w3##w1smoke  c.timew1w3##w1currdrugs c.timew1w3##c.w1hei2010_total_scorecent43  c.timew1w3##c.w1BMIcent30  c.timew1w3##c.invmillsmms ///
c.timew1w3##c.w1HCYcenter2p15   ///
if sample4fobs==1 & Sex==1 || HNDID: timew1w3, cov(un)

mi estimate: mixed DigitSpanFwd  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat c.timew1w3##w1edubr c.timew1w3##c.w1WRATtotalcent42   ///
c.timew1w3##w1smoke  c.timew1w3##w1currdrugs c.timew1w3##c.w1hei2010_total_scorecent43  c.timew1w3##c.w1BMIcent30  c.timew1w3##c.invmillsmms ///
c.timew1w3##c.w1HCYcenter2p15   ///
if sample4gobs==1 & Sex==1 || HNDID: timew1w3, cov(un)

mi estimate: mixed DigitSpanBck  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat c.timew1w3##w1edubr c.timew1w3##c.w1WRATtotalcent42   ///
c.timew1w3##w1smoke  c.timew1w3##w1currdrugs c.timew1w3##c.w1hei2010_total_scorecent43  c.timew1w3##c.w1BMIcent30 c.timew1w3##c.invmillsmms ///
c.timew1w3##c.w1HCYcenter2p15   ///
if sample4hobs==1 & Sex==1 || HNDID: timew1w3, cov(un)

mi estimate: mixed clock_command  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat c.timew1w3##w1edubr c.timew1w3##c.w1WRATtotalcent42   ///
c.timew1w3##w1smoke  c.timew1w3##w1currdrugs c.timew1w3##c.w1hei2010_total_scorecent43  c.timew1w3##c.w1BMIcent30  c.timew1w3##c.invmillsmms ///
c.timew1w3##c.w1HCYcenter2p15   ///
if sample4iobs==1 & Sex==1 || HNDID: timew1w3, cov(un)

mi estimate: mixed LnTrailsAtestSec  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat c.timew1w3##w1edubr c.timew1w3##c.w1WRATtotalcent42   ///
c.timew1w3##w1smoke  c.timew1w3##w1currdrugs c.timew1w3##c.w1hei2010_total_scorecent43  c.timew1w3##c.w1BMIcent30  c.timew1w3##c.invmillsmms ///
c.timew1w3##c.w1HCYcenter2p15   ///
if sample4jobs==1 & Sex==1 || HNDID: timew1w3

mi estimate: mixed LnTrailsBtestSec  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat c.timew1w3##w1edubr c.timew1w3##c.w1WRATtotalcent42   ///
c.timew1w3##w1smoke  c.timew1w3##w1currdrugs c.timew1w3##c.w1hei2010_total_scorecent43  c.timew1w3##c.w1BMIcent30  c.timew1w3##c.invmillsmms ///
c.timew1w3##c.w1HCYcenter2p15   ///
if sample4kobs==1  & Sex==1 || HNDID: timew1w3, cov(un)


save, replace


//MODEL 3: FULLY ADJUSTED MODEL: MODEL 2 + HEALTH-RELATED FACTORS///

mi estimate: mixed MMStot  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat c.timew1w3##w1edubr c.timew1w3##c.w1WRATtotalcent42   ///
c.timew1w3##w1smoke  c.timew1w3##w1currdrugs c.timew1w3##c.w1hei2010_total_scorecent43  c.timew1w3##c.w1BMIcent30 c.timew1w3##w1SRH c.timew1w3##c.w1CEScent15 c.timew1w3##w1dxHTN c.timew1w3##w1dxDiabetes c.timew1w3##w1CVhighChol c.timew1w3##w1cvdbr c.timew1w3##c.invmillsmms ///
c.timew1w3##c.w1HCYcenter2p15   ///
if sample4aobs==1 & Sex==1 || HNDID: timew1w3, cov(un)


mi estimate: mixed MMStotnorm  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat c.timew1w3##w1edubr c.timew1w3##c.w1WRATtotalcent42   ///
c.timew1w3##w1smoke  c.timew1w3##w1currdrugs c.timew1w3##c.w1hei2010_total_scorecent43  c.timew1w3##c.w1BMIcent30 c.timew1w3##w1SRH c.timew1w3##c.w1CEScent15 c.timew1w3##w1dxHTN c.timew1w3##w1dxDiabetes c.timew1w3##w1CVhighChol c.timew1w3##w1cvdbr c.timew1w3##c.invmillsmms ///
c.timew1w3##c.w1HCYcenter2p15   ///
if sample4aobs==1 & Sex==1 || HNDID: timew1w3, cov(un)



mi estimate: mixed cvltca  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat c.timew1w3##w1edubr c.timew1w3##c.w1WRATtotalcent42   ///
c.timew1w3##w1smoke  c.timew1w3##w1currdrugs c.timew1w3##c.w1hei2010_total_scorecent43  c.timew1w3##c.w1BMIcent30 c.timew1w3##w1SRH c.timew1w3##c.w1CEScent15 c.timew1w3##w1dxHTN c.timew1w3##w1dxDiabetes c.timew1w3##w1CVhighChol c.timew1w3##w1cvdbr c.timew1w3##c.invmillsmms ///
c.timew1w3##c.w1HCYcenter2p15   ///
if sample4bobs==1 & Sex==1 || HNDID: timew1w3



mi estimate: mixed CVLfrl  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat c.timew1w3##w1edubr c.timew1w3##c.w1WRATtotalcent42   ///
c.timew1w3##w1smoke  c.timew1w3##w1currdrugs c.timew1w3##c.w1hei2010_total_scorecent43  c.timew1w3##c.w1BMIcent30 c.timew1w3##w1SRH c.timew1w3##c.w1CEScent15 c.timew1w3##w1dxHTN c.timew1w3##w1dxDiabetes c.timew1w3##w1CVhighChol c.timew1w3##w1cvdbr c.timew1w3##c.invmillsmms ///
c.timew1w3##c.w1HCYcenter2p15   ///
if sample4cobs==1 & Sex==1 || HNDID:



mi estimate: mixed BVRtot  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat c.timew1w3##w1edubr c.timew1w3##c.w1WRATtotalcent42   ///
c.timew1w3##w1smoke  c.timew1w3##w1currdrugs c.timew1w3##c.w1hei2010_total_scorecent43  c.timew1w3##c.w1BMIcent30 c.timew1w3##w1SRH c.timew1w3##c.w1CEScent15 c.timew1w3##w1dxHTN c.timew1w3##w1dxDiabetes c.timew1w3##w1CVhighChol c.timew1w3##w1cvdbr c.timew1w3##c.invmillsmms ///
c.timew1w3##c.w1HCYcenter2p15   ///
if sample4dobs==1 & Sex==1 || HNDID: timew1w3, cov(un)


mi estimate: mixed Attention  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat c.timew1w3##w1edubr c.timew1w3##c.w1WRATtotalcent42   ///
c.timew1w3##w1smoke  c.timew1w3##w1currdrugs c.timew1w3##c.w1hei2010_total_scorecent43  c.timew1w3##c.w1BMIcent30 c.timew1w3##w1SRH c.timew1w3##c.w1CEScent15 c.timew1w3##w1dxHTN c.timew1w3##w1dxDiabetes c.timew1w3##w1CVhighChol c.timew1w3##w1cvdbr c.timew1w3##c.invmillsmms ///
c.timew1w3##c.w1HCYcenter2p15   ///
if sample4eobs==1 & Sex==1 || HNDID: timew1w3, cov(un)

mi estimate: mixed FluencyWord  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat c.timew1w3##w1edubr c.timew1w3##c.w1WRATtotalcent42   ///
c.timew1w3##w1smoke  c.timew1w3##w1currdrugs c.timew1w3##c.w1hei2010_total_scorecent43  c.timew1w3##c.w1BMIcent30 c.timew1w3##w1SRH c.timew1w3##c.w1CEScent15 c.timew1w3##w1dxHTN c.timew1w3##w1dxDiabetes c.timew1w3##w1CVhighChol c.timew1w3##w1cvdbr c.timew1w3##c.invmillsmms ///
c.timew1w3##c.w1HCYcenter2p15   ///
if sample4fobs==1 & Sex==1 || HNDID: timew1w3, cov(un)

mi estimate: mixed DigitSpanFwd  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat c.timew1w3##w1edubr c.timew1w3##c.w1WRATtotalcent42   ///
c.timew1w3##w1smoke  c.timew1w3##w1currdrugs c.timew1w3##c.w1hei2010_total_scorecent43  c.timew1w3##c.w1BMIcent30 c.timew1w3##w1SRH c.timew1w3##c.w1CEScent15 c.timew1w3##w1dxHTN c.timew1w3##w1dxDiabetes c.timew1w3##w1CVhighChol c.timew1w3##w1cvdbr c.timew1w3##c.invmillsmms ///
c.timew1w3##c.w1HCYcenter2p15   ///
if sample4gobs==1 & Sex==1 || HNDID: timew1w3, cov(un)

mi estimate: mixed DigitSpanBck  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat c.timew1w3##w1edubr c.timew1w3##c.w1WRATtotalcent42   ///
c.timew1w3##w1smoke  c.timew1w3##w1currdrugs c.timew1w3##c.w1hei2010_total_scorecent43  c.timew1w3##c.w1BMIcent30 c.timew1w3##w1SRH c.timew1w3##c.w1CEScent15 c.timew1w3##w1dxHTN c.timew1w3##w1dxDiabetes c.timew1w3##w1CVhighChol c.timew1w3##w1cvdbr c.timew1w3##c.invmillsmms ///
c.timew1w3##c.w1HCYcenter2p15   ///
if sample4hobs==1 & Sex==1 || HNDID: timew1w3, cov(un)

mi estimate: mixed clock_command  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat c.timew1w3##w1edubr c.timew1w3##c.w1WRATtotalcent42   ///
c.timew1w3##w1smoke  c.timew1w3##w1currdrugs c.timew1w3##c.w1hei2010_total_scorecent43  c.timew1w3##c.w1BMIcent30 c.timew1w3##w1SRH c.timew1w3##c.w1CEScent15 c.timew1w3##w1dxHTN c.timew1w3##w1dxDiabetes c.timew1w3##w1CVhighChol c.timew1w3##w1cvdbr c.timew1w3##c.invmillsmms ///
c.timew1w3##c.w1HCYcenter2p15   ///
if sample4iobs==1 & Sex==1 || HNDID: timew1w3, cov(un)

mi estimate: mixed LnTrailsAtestSec  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat c.timew1w3##w1edubr c.timew1w3##c.w1WRATtotalcent42   ///
c.timew1w3##w1smoke  c.timew1w3##w1currdrugs c.timew1w3##c.w1hei2010_total_scorecent43  c.timew1w3##c.w1BMIcent30 c.timew1w3##w1SRH c.timew1w3##c.w1CEScent15 c.timew1w3##w1dxHTN c.timew1w3##w1dxDiabetes c.timew1w3##w1CVhighChol c.timew1w3##w1cvdbr c.timew1w3##c.invmillsmms ///
c.timew1w3##c.w1HCYcenter2p15   ///
if sample4jobs==1 & Sex==1 || HNDID: timew1w3

mi estimate: mixed LnTrailsBtestSec  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat c.timew1w3##w1edubr c.timew1w3##c.w1WRATtotalcent42   ///
c.timew1w3##w1smoke  c.timew1w3##w1currdrugs c.timew1w3##c.w1hei2010_total_scorecent43  c.timew1w3##c.w1BMIcent30 c.timew1w3##w1SRH c.timew1w3##c.w1CEScent15 c.timew1w3##w1dxHTN c.timew1w3##w1dxDiabetes c.timew1w3##w1CVhighChol c.timew1w3##w1cvdbr c.timew1w3##c.invmillsmms ///
c.timew1w3##c.w1HCYcenter2p15   ///
if sample4kobs==1  & Sex==1 || HNDID: timew1w3, cov(un)


save, replace



*******************************TABLE 2: HOMOCYSTEINE AT BASELINE VS. COGNITIVE CHANGE OVER TIME: MEN**************************************

//MODEL 1: INCLUDE ONLY AGE, SEX, RACE AND POVERTY STATUS///
mi estimate: mixed MMStot  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat  c.timew1w3##c.invmillsmms ///
c.timew1w3##c.w1HCYcenter2p15   ///
if sample4aobs==1 & Sex==2 || HNDID: timew1w3, cov(un)


mi estimate: mixed MMStotnorm  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat  c.timew1w3##c.invmillsmms ///
c.timew1w3##c.w1HCYcenter2p15   ///
if sample4aobs==1 & Sex==2 || HNDID: timew1w3, cov(un)



mi estimate: mixed cvltca  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat  c.timew1w3##c.invmillsmms ///
c.timew1w3##c.w1HCYcenter2p15   ///
if sample4bobs==1 & Sex==2 || HNDID: timew1w3



mi estimate: mixed CVLfrl  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat  c.timew1w3##c.invmillsmms ///
c.timew1w3##c.w1HCYcenter2p15   ///
if sample4cobs==1 & Sex==2 || HNDID: timew1w3



mi estimate: mixed BVRtot  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat  c.timew1w3##c.invmillsmms ///
c.timew1w3##c.w1HCYcenter2p15   ///
if sample4dobs==1 & Sex==2 || HNDID: timew1w3, cov(un)


mi estimate: mixed Attention  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat  c.timew1w3##c.invmillsmms ///
c.timew1w3##c.w1HCYcenter2p15   ///
if sample4eobs==1 & Sex==2 || HNDID: timew1w3, cov(un)

mi estimate: mixed FluencyWord  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat  c.timew1w3##c.invmillsmms ///
c.timew1w3##c.w1HCYcenter2p15   ///
if sample4fobs==1 & Sex==2 || HNDID: timew1w3, cov(un)

mi estimate: mixed DigitSpanFwd  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat  c.timew1w3##c.invmillsmms ///
c.timew1w3##c.w1HCYcenter2p15   ///
if sample4gobs==1 & Sex==2 || HNDID: timew1w3, cov(un)

mi estimate: mixed DigitSpanBck  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat  c.timew1w3##c.invmillsmms ///
c.timew1w3##c.w1HCYcenter2p15   ///
if sample4hobs==1 & Sex==2 || HNDID: timew1w3, cov(un)

mi estimate: mixed clock_command  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat  c.timew1w3##c.invmillsmms ///
c.timew1w3##c.w1HCYcenter2p15   ///
if sample4iobs==1 & Sex==2 || HNDID: timew1w3, cov(un)

mi estimate: mixed LnTrailsAtestSec  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat  c.timew1w3##c.invmillsmms ///
c.timew1w3##c.w1HCYcenter2p15   ///
if sample4jobs==1 & Sex==2 || HNDID: timew1w3

mi estimate: mixed LnTrailsBtestSec  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat  c.timew1w3##c.invmillsmms ///
c.timew1w3##c.w1HCYcenter2p15   ///
if sample4kobs==1  & Sex==2 || HNDID: timew1w3, cov(un)


save, replace



//MODEL 2: MODEL 1 + OTHER FACTORS + BODY MASS INDEX///

mi estimate: mixed MMStot  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat c.timew1w3##w1edubr c.timew1w3##c.w1WRATtotalcent42   ///
c.timew1w3##w1smoke  c.timew1w3##w1currdrugs c.timew1w3##c.w1hei2010_total_scorecent43  c.timew1w3##c.w1BMIcent30  c.timew1w3##c.invmillsmms ///
c.timew1w3##c.w1HCYcenter2p15   ///
if sample4aobs==1 & Sex==2 || HNDID: timew1w3


mi estimate: mixed MMStotnorm  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat c.timew1w3##w1edubr c.timew1w3##c.w1WRATtotalcent42   ///
c.timew1w3##w1smoke  c.timew1w3##w1currdrugs c.timew1w3##c.w1hei2010_total_scorecent43  c.timew1w3##c.w1BMIcent30  c.timew1w3##c.invmillsmms ///
c.timew1w3##c.w1HCYcenter2p15   ///
if sample4aobs==1 & Sex==2 || HNDID: timew1w3, cov(un)


mi estimate: mixed clock_command  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat c.timew1w3##w1edubr c.timew1w3##c.w1WRATtotalcent42   ///
c.timew1w3##w1smoke  c.timew1w3##w1currdrugs c.timew1w3##c.w1hei2010_total_scorecent43  c.timew1w3##c.w1BMIcent30  c.timew1w3##c.invmillsmms ///
c.timew1w3##c.w1HCYcenter2p15   ///
if sample4iobs==1 & Sex==2 || HNDID: timew1w3, cov(un)

mi estimate: mixed LnTrailsAtestSec  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat c.timew1w3##w1edubr c.timew1w3##c.w1WRATtotalcent42   ///
c.timew1w3##w1smoke  c.timew1w3##w1currdrugs c.timew1w3##c.w1hei2010_total_scorecent43  c.timew1w3##c.w1BMIcent30  c.timew1w3##c.invmillsmms ///
c.timew1w3##c.w1HCYcenter2p15   ///
if sample4jobs==1 & Sex==2 || HNDID: timew1w3

mi estimate: mixed LnTrailsBtestSec  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat c.timew1w3##w1edubr c.timew1w3##c.w1WRATtotalcent42   ///
c.timew1w3##w1smoke  c.timew1w3##w1currdrugs c.timew1w3##c.w1hei2010_total_scorecent43  c.timew1w3##c.w1BMIcent30  c.timew1w3##c.invmillsmms ///
c.timew1w3##c.w1HCYcenter2p15   ///
if sample4kobs==1  & Sex==2 || HNDID: timew1w3, cov(un)


save, replace


//MODEL 3: FULLY ADJUSTED MODEL: MODEL 2 + HEALTH-RELATED FACTORS///

mi estimate: mixed MMStot  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat c.timew1w3##w1edubr c.timew1w3##c.w1WRATtotalcent42   ///
c.timew1w3##w1smoke  c.timew1w3##w1currdrugs c.timew1w3##c.w1hei2010_total_scorecent43  c.timew1w3##c.w1BMIcent30 c.timew1w3##w1SRH c.timew1w3##c.w1CEScent15 c.timew1w3##w1dxHTN c.timew1w3##w1dxDiabetes c.timew1w3##w1CVhighChol c.timew1w3##w1cvdbr c.timew1w3##c.invmillsmms ///
c.timew1w3##c.w1HCYcenter2p15   ///
if sample4aobs==1 & Sex==2 || HNDID: timew1w3


mi estimate: mixed MMStotnorm  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat c.timew1w3##w1edubr c.timew1w3##c.w1WRATtotalcent42   ///
c.timew1w3##w1smoke  c.timew1w3##w1currdrugs c.timew1w3##c.w1hei2010_total_scorecent43  c.timew1w3##c.w1BMIcent30 c.timew1w3##w1SRH c.timew1w3##c.w1CEScent15 c.timew1w3##w1dxHTN c.timew1w3##w1dxDiabetes c.timew1w3##w1CVhighChol c.timew1w3##w1cvdbr c.timew1w3##c.invmillsmms ///
c.timew1w3##c.w1HCYcenter2p15   ///
if sample4aobs==1 & Sex==2 || HNDID: timew1w3, cov(un)



mi estimate: mixed cvltca  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat c.timew1w3##w1edubr c.timew1w3##c.w1WRATtotalcent42   ///
c.timew1w3##w1smoke  c.timew1w3##w1currdrugs c.timew1w3##c.w1hei2010_total_scorecent43  c.timew1w3##c.w1BMIcent30 c.timew1w3##w1SRH c.timew1w3##c.w1CEScent15 c.timew1w3##w1dxHTN c.timew1w3##w1dxDiabetes c.timew1w3##w1CVhighChol c.timew1w3##w1cvdbr c.timew1w3##c.invmillsmms ///
c.timew1w3##c.w1HCYcenter2p15   ///
if sample4bobs==1 & Sex==2 || HNDID: timew1w3



mi estimate: mixed CVLfrl  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat c.timew1w3##w1edubr c.timew1w3##c.w1WRATtotalcent42   ///
c.timew1w3##w1smoke  c.timew1w3##w1currdrugs c.timew1w3##c.w1hei2010_total_scorecent43  c.timew1w3##c.w1BMIcent30 c.timew1w3##w1SRH c.timew1w3##c.w1CEScent15 c.timew1w3##w1dxHTN c.timew1w3##w1dxDiabetes c.timew1w3##w1CVhighChol c.timew1w3##w1cvdbr c.timew1w3##c.invmillsmms ///
c.timew1w3##c.w1HCYcenter2p15   ///
if sample4cobs==1 & Sex==2 || HNDID: timew1w3



mi estimate: mixed BVRtot  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat c.timew1w3##w1edubr c.timew1w3##c.w1WRATtotalcent42   ///
c.timew1w3##w1smoke  c.timew1w3##w1currdrugs c.timew1w3##c.w1hei2010_total_scorecent43  c.timew1w3##c.w1BMIcent30 c.timew1w3##w1SRH c.timew1w3##c.w1CEScent15 c.timew1w3##w1dxHTN c.timew1w3##w1dxDiabetes c.timew1w3##w1CVhighChol c.timew1w3##w1cvdbr c.timew1w3##c.invmillsmms ///
c.timew1w3##c.w1HCYcenter2p15   ///
if sample4dobs==1 & Sex==2 || HNDID: timew1w3, cov(un)


mi estimate: mixed Attention  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat c.timew1w3##w1edubr c.timew1w3##c.w1WRATtotalcent42   ///
c.timew1w3##w1smoke  c.timew1w3##w1currdrugs c.timew1w3##c.w1hei2010_total_scorecent43  c.timew1w3##c.w1BMIcent30 c.timew1w3##w1SRH c.timew1w3##c.w1CEScent15 c.timew1w3##w1dxHTN c.timew1w3##w1dxDiabetes c.timew1w3##w1CVhighChol c.timew1w3##w1cvdbr c.timew1w3##c.invmillsmms ///
c.timew1w3##c.w1HCYcenter2p15   ///
if sample4eobs==1 & Sex==2 || HNDID: timew1w3, cov(un)

mi estimate: mixed FluencyWord  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat c.timew1w3##w1edubr c.timew1w3##c.w1WRATtotalcent42   ///
c.timew1w3##w1smoke  c.timew1w3##w1currdrugs c.timew1w3##c.w1hei2010_total_scorecent43  c.timew1w3##c.w1BMIcent30 c.timew1w3##w1SRH c.timew1w3##c.w1CEScent15 c.timew1w3##w1dxHTN c.timew1w3##w1dxDiabetes c.timew1w3##w1CVhighChol c.timew1w3##w1cvdbr c.timew1w3##c.invmillsmms ///
c.timew1w3##c.w1HCYcenter2p15   ///
if sample4fobs==1 & Sex==2 || HNDID: timew1w3, cov(un)

mi estimate: mixed DigitSpanFwd  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat c.timew1w3##w1edubr c.timew1w3##c.w1WRATtotalcent42   ///
c.timew1w3##w1smoke  c.timew1w3##w1currdrugs c.timew1w3##c.w1hei2010_total_scorecent43  c.timew1w3##c.w1BMIcent30 c.timew1w3##w1SRH c.timew1w3##c.w1CEScent15 c.timew1w3##w1dxHTN c.timew1w3##w1dxDiabetes c.timew1w3##w1CVhighChol c.timew1w3##w1cvdbr c.timew1w3##c.invmillsmms ///
c.timew1w3##c.w1HCYcenter2p15   ///
if sample4gobs==1 & Sex==2 || HNDID: timew1w3, cov(un)

mi estimate: mixed DigitSpanBck  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat c.timew1w3##w1edubr c.timew1w3##c.w1WRATtotalcent42   ///
c.timew1w3##w1smoke  c.timew1w3##w1currdrugs c.timew1w3##c.w1hei2010_total_scorecent43  c.timew1w3##c.w1BMIcent30 c.timew1w3##w1SRH c.timew1w3##c.w1CEScent15 c.timew1w3##w1dxHTN c.timew1w3##w1dxDiabetes c.timew1w3##w1CVhighChol c.timew1w3##w1cvdbr c.timew1w3##c.invmillsmms ///
c.timew1w3##c.w1HCYcenter2p15   ///
if sample4hobs==1 & Sex==2 || HNDID: timew1w3

mi estimate: mixed clock_command  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat c.timew1w3##w1edubr c.timew1w3##c.w1WRATtotalcent42   ///
c.timew1w3##w1smoke  c.timew1w3##w1currdrugs c.timew1w3##c.w1hei2010_total_scorecent43  c.timew1w3##c.w1BMIcent30 c.timew1w3##w1SRH c.timew1w3##c.w1CEScent15 c.timew1w3##w1dxHTN c.timew1w3##w1dxDiabetes c.timew1w3##w1CVhighChol c.timew1w3##w1cvdbr c.timew1w3##c.invmillsmms ///
c.timew1w3##c.w1HCYcenter2p15   ///
if sample4iobs==1 & Sex==2 || HNDID: timew1w3

mi estimate: mixed LnTrailsAtestSec  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat c.timew1w3##w1edubr c.timew1w3##c.w1WRATtotalcent42   ///
c.timew1w3##w1smoke  c.timew1w3##w1currdrugs c.timew1w3##c.w1hei2010_total_scorecent43  c.timew1w3##c.w1BMIcent30 c.timew1w3##w1SRH c.timew1w3##c.w1CEScent15 c.timew1w3##w1dxHTN c.timew1w3##w1dxDiabetes c.timew1w3##w1CVhighChol c.timew1w3##w1cvdbr c.timew1w3##c.invmillsmms ///
c.timew1w3##c.w1HCYcenter2p15   ///
if sample4jobs==1 & Sex==2 || HNDID: timew1w3

mi estimate: mixed LnTrailsBtestSec  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat c.timew1w3##w1edubr c.timew1w3##c.w1WRATtotalcent42   ///
c.timew1w3##w1smoke  c.timew1w3##w1currdrugs c.timew1w3##c.w1hei2010_total_scorecent43  c.timew1w3##c.w1BMIcent30 c.timew1w3##w1SRH c.timew1w3##c.w1CEScent15 c.timew1w3##w1dxHTN c.timew1w3##w1dxDiabetes c.timew1w3##w1CVhighChol c.timew1w3##w1cvdbr c.timew1w3##c.invmillsmms ///
c.timew1w3##c.w1HCYcenter2p15   ///
if sample4kobs==1  & Sex==2 || HNDID: timew1w3, cov(un)


save, replace


*******************************TABLE 2: HOMOCYSTEINE AT BASELINE VS. COGNITIVE CHANGE OVER TIME: INTERACTION BY SEX**************************************


//MODEL 1: INCLUDE ONLY AGE, SEX, RACE AND POVERTY STATUS///
mi estimate: mixed MMStot  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat  c.timew1w3##c.invmillsmms ///
c.timew1w3##c.w1HCYcenter2p15##Sex   ///
if sample4aobs==1 || HNDID: timew1w3, cov(un)


mi estimate: mixed MMStotnorm  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat  c.timew1w3##c.invmillsmms ///
c.timew1w3##c.w1HCYcenter2p15##Sex   ///
if sample4aobs==1 || HNDID: timew1w3, cov(un)



mi estimate: mixed cvltca  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat  c.timew1w3##c.invmillsmms ///
c.timew1w3##c.w1HCYcenter2p15##Sex   ///
if sample4bobs==1 || HNDID: timew1w3



mi estimate: mixed CVLfrl  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat  c.timew1w3##c.invmillsmms ///
c.timew1w3##c.w1HCYcenter2p15##Sex   ///
if sample4cobs==1 || HNDID: 



mi estimate: mixed BVRtot  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat  c.timew1w3##c.invmillsmms ///
c.timew1w3##c.w1HCYcenter2p15##Sex   ///
if sample4dobs==1 || HNDID: timew1w3, cov(un)


mi estimate: mixed Attention  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat  c.timew1w3##c.invmillsmms ///
c.timew1w3##c.w1HCYcenter2p15##Sex   ///
if sample4eobs==1 || HNDID: timew1w3, cov(un)

mi estimate: mixed FluencyWord  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat  c.timew1w3##c.invmillsmms ///
c.timew1w3##c.w1HCYcenter2p15##Sex   ///
if sample4fobs==1 || HNDID: timew1w3, cov(un)

mi estimate: mixed DigitSpanFwd  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat  c.timew1w3##c.invmillsmms ///
c.timew1w3##c.w1HCYcenter2p15##Sex   ///
if sample4gobs==1 || HNDID: timew1w3, cov(un)

mi estimate: mixed DigitSpanBck  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat  c.timew1w3##c.invmillsmms ///
c.timew1w3##c.w1HCYcenter2p15##Sex   ///
if sample4hobs==1 || HNDID: timew1w3, cov(un)

mi estimate: mixed clock_command  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat  c.timew1w3##c.invmillsmms ///
c.timew1w3##c.w1HCYcenter2p15##Sex   ///
if sample4iobs==1 || HNDID: timew1w3, cov(un)

mi estimate: mixed LnTrailsAtestSec  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat  c.timew1w3##c.invmillsmms ///
c.timew1w3##c.w1HCYcenter2p15##Sex   ///
if sample4jobs==1 || HNDID: timew1w3

mi estimate: mixed LnTrailsBtestSec  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat  c.timew1w3##c.invmillsmms ///
c.timew1w3##c.w1HCYcenter2p15##Sex   ///
if sample4kobs==1  || HNDID: timew1w3, cov(un)


save, replace


//MODEL 2: MODEL 1 + OTHER FACTORS + BODY MASS INDEX///

mi estimate: mixed MMStot  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat c.timew1w3##w1edubr c.timew1w3##c.w1WRATtotalcent42   ///
c.timew1w3##w1smoke  c.timew1w3##w1currdrugs c.timew1w3##c.w1hei2010_total_scorecent43  c.timew1w3##c.w1BMIcent30  c.timew1w3##c.invmillsmms ///
c.timew1w3##c.w1HCYcenter2p15##Sex   ///
if sample4aobs==1 || HNDID: timew1w3, cov(un)


mi estimate: mixed MMStotnorm  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat c.timew1w3##w1edubr c.timew1w3##c.w1WRATtotalcent42   ///
c.timew1w3##w1smoke  c.timew1w3##w1currdrugs c.timew1w3##c.w1hei2010_total_scorecent43  c.timew1w3##c.w1BMIcent30  c.timew1w3##c.invmillsmms ///
c.timew1w3##c.w1HCYcenter2p15##Sex   ///
if sample4aobs==1 || HNDID: timew1w3, cov(un)



mi estimate: mixed cvltca  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat c.timew1w3##w1edubr c.timew1w3##c.w1WRATtotalcent42   ///
c.timew1w3##w1smoke  c.timew1w3##w1currdrugs c.timew1w3##c.w1hei2010_total_scorecent43  c.timew1w3##c.w1BMIcent30  c.timew1w3##c.invmillsmms ///
c.timew1w3##c.w1HCYcenter2p15##Sex   ///
if sample4bobs==1 || HNDID: timew1w3



mi estimate: mixed CVLfrl  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat c.timew1w3##w1edubr c.timew1w3##c.w1WRATtotalcent42   ///
c.timew1w3##w1smoke  c.timew1w3##w1currdrugs c.timew1w3##c.w1hei2010_total_scorecent43  c.timew1w3##c.w1BMIcent30  c.timew1w3##c.invmillsmms ///
c.timew1w3##c.w1HCYcenter2p15##Sex   ///
if sample4cobs==1 || HNDID: 



mi estimate: mixed BVRtot  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat c.timew1w3##w1edubr c.timew1w3##c.w1WRATtotalcent42   ///
c.timew1w3##w1smoke  c.timew1w3##w1currdrugs c.timew1w3##c.w1hei2010_total_scorecent43  c.timew1w3##c.w1BMIcent30  c.timew1w3##c.invmillsmms ///
c.timew1w3##c.w1HCYcenter2p15##Sex   ///
if sample4dobs==1 || HNDID: timew1w3, cov(un)


mi estimate: mixed Attention  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat c.timew1w3##w1edubr c.timew1w3##c.w1WRATtotalcent42   ///
c.timew1w3##w1smoke  c.timew1w3##w1currdrugs c.timew1w3##c.w1hei2010_total_scorecent43  c.timew1w3##c.w1BMIcent30  c.timew1w3##c.invmillsmms ///
c.timew1w3##c.w1HCYcenter2p15##Sex   ///
if sample4eobs==1 || HNDID: timew1w3, cov(un)

mi estimate: mixed FluencyWord  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat c.timew1w3##w1edubr c.timew1w3##c.w1WRATtotalcent42   ///
c.timew1w3##w1smoke  c.timew1w3##w1currdrugs c.timew1w3##c.w1hei2010_total_scorecent43  c.timew1w3##c.w1BMIcent30  c.timew1w3##c.invmillsmms ///
c.timew1w3##c.w1HCYcenter2p15##Sex   ///
if sample4fobs==1 || HNDID: timew1w3, cov(un)

mi estimate: mixed DigitSpanFwd  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat c.timew1w3##w1edubr c.timew1w3##c.w1WRATtotalcent42   ///
c.timew1w3##w1smoke  c.timew1w3##w1currdrugs c.timew1w3##c.w1hei2010_total_scorecent43  c.timew1w3##c.w1BMIcent30  c.timew1w3##c.invmillsmms ///
c.timew1w3##c.w1HCYcenter2p15##Sex   ///
if sample4gobs==1 || HNDID: timew1w3, cov(un)

mi estimate: mixed DigitSpanBck  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat c.timew1w3##w1edubr c.timew1w3##c.w1WRATtotalcent42   ///
c.timew1w3##w1smoke  c.timew1w3##w1currdrugs c.timew1w3##c.w1hei2010_total_scorecent43  c.timew1w3##c.w1BMIcent30 c.timew1w3##c.invmillsmms ///
c.timew1w3##c.w1HCYcenter2p15##Sex   ///
if sample4hobs==1 || HNDID: timew1w3

mi estimate: mixed clock_command  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat c.timew1w3##w1edubr c.timew1w3##c.w1WRATtotalcent42   ///
c.timew1w3##w1smoke  c.timew1w3##w1currdrugs c.timew1w3##c.w1hei2010_total_scorecent43  c.timew1w3##c.w1BMIcent30  c.timew1w3##c.invmillsmms ///
c.timew1w3##c.w1HCYcenter2p15##Sex   ///
if sample4iobs==1 || HNDID: timew1w3, cov(un)

mi estimate: mixed LnTrailsAtestSec  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat c.timew1w3##w1edubr c.timew1w3##c.w1WRATtotalcent42   ///
c.timew1w3##w1smoke  c.timew1w3##w1currdrugs c.timew1w3##c.w1hei2010_total_scorecent43  c.timew1w3##c.w1BMIcent30  c.timew1w3##c.invmillsmms ///
c.timew1w3##c.w1HCYcenter2p15##Sex   ///
if sample4jobs==1 || HNDID: timew1w3

mi estimate: mixed LnTrailsBtestSec  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat c.timew1w3##w1edubr c.timew1w3##c.w1WRATtotalcent42   ///
c.timew1w3##w1smoke  c.timew1w3##w1currdrugs c.timew1w3##c.w1hei2010_total_scorecent43  c.timew1w3##c.w1BMIcent30  c.timew1w3##c.invmillsmms ///
c.timew1w3##c.w1HCYcenter2p15##Sex   ///
if sample4kobs==1  || HNDID: timew1w3, cov(un)


save, replace


//MODEL 3: FULLY ADJUSTED MODEL: MODEL 2 + HEALTH-RELATED FACTORS///

mi estimate: mixed MMStot  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat c.timew1w3##w1edubr c.timew1w3##c.w1WRATtotalcent42   ///
c.timew1w3##w1smoke  c.timew1w3##w1currdrugs c.timew1w3##c.w1hei2010_total_scorecent43  c.timew1w3##c.w1BMIcent30 c.timew1w3##w1SRH c.timew1w3##c.w1CEScent15 c.timew1w3##w1dxHTN c.timew1w3##w1dxDiabetes c.timew1w3##w1CVhighChol c.timew1w3##w1cvdbr c.timew1w3##c.invmillsmms ///
c.timew1w3##c.w1HCYcenter2p15##Sex   ///
if sample4aobs==1 || HNDID: timew1w3


mi estimate: mixed MMStotnorm  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat c.timew1w3##w1edubr c.timew1w3##c.w1WRATtotalcent42   ///
c.timew1w3##w1smoke  c.timew1w3##w1currdrugs c.timew1w3##c.w1hei2010_total_scorecent43  c.timew1w3##c.w1BMIcent30 c.timew1w3##w1SRH c.timew1w3##c.w1CEScent15 c.timew1w3##w1dxHTN c.timew1w3##w1dxDiabetes c.timew1w3##w1CVhighChol c.timew1w3##w1cvdbr c.timew1w3##c.invmillsmms ///
c.timew1w3##c.w1HCYcenter2p15##Sex   ///
if sample4aobs==1 || HNDID: timew1w3, cov(un)



mi estimate: mixed cvltca  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat c.timew1w3##w1edubr c.timew1w3##c.w1WRATtotalcent42   ///
c.timew1w3##w1smoke  c.timew1w3##w1currdrugs c.timew1w3##c.w1hei2010_total_scorecent43  c.timew1w3##c.w1BMIcent30 c.timew1w3##w1SRH c.timew1w3##c.w1CEScent15 c.timew1w3##w1dxHTN c.timew1w3##w1dxDiabetes c.timew1w3##w1CVhighChol c.timew1w3##w1cvdbr c.timew1w3##c.invmillsmms ///
c.timew1w3##c.w1HCYcenter2p15##Sex   ///
if sample4bobs==1 || HNDID: timew1w3



mi estimate: mixed CVLfrl  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat c.timew1w3##w1edubr c.timew1w3##c.w1WRATtotalcent42   ///
c.timew1w3##w1smoke  c.timew1w3##w1currdrugs c.timew1w3##c.w1hei2010_total_scorecent43  c.timew1w3##c.w1BMIcent30 c.timew1w3##w1SRH c.timew1w3##c.w1CEScent15 c.timew1w3##w1dxHTN c.timew1w3##w1dxDiabetes c.timew1w3##w1CVhighChol c.timew1w3##w1cvdbr c.timew1w3##c.invmillsmms ///
c.timew1w3##c.w1HCYcenter2p15##Sex   ///
if sample4cobs==1 || HNDID: 



mi estimate: mixed BVRtot  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat c.timew1w3##w1edubr c.timew1w3##c.w1WRATtotalcent42   ///
c.timew1w3##w1smoke  c.timew1w3##w1currdrugs c.timew1w3##c.w1hei2010_total_scorecent43  c.timew1w3##c.w1BMIcent30 c.timew1w3##w1SRH c.timew1w3##c.w1CEScent15 c.timew1w3##w1dxHTN c.timew1w3##w1dxDiabetes c.timew1w3##w1CVhighChol c.timew1w3##w1cvdbr c.timew1w3##c.invmillsmms ///
c.timew1w3##c.w1HCYcenter2p15##Sex   ///
if sample4dobs==1 || HNDID: timew1w3, cov(un)


mi estimate: mixed Attention  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat c.timew1w3##w1edubr c.timew1w3##c.w1WRATtotalcent42   ///
c.timew1w3##w1smoke  c.timew1w3##w1currdrugs c.timew1w3##c.w1hei2010_total_scorecent43  c.timew1w3##c.w1BMIcent30 c.timew1w3##w1SRH c.timew1w3##c.w1CEScent15 c.timew1w3##w1dxHTN c.timew1w3##w1dxDiabetes c.timew1w3##w1CVhighChol c.timew1w3##w1cvdbr c.timew1w3##c.invmillsmms ///
c.timew1w3##c.w1HCYcenter2p15##Sex   ///
if sample4eobs==1 || HNDID: timew1w3, cov(un)

mi estimate: mixed FluencyWord  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat c.timew1w3##w1edubr c.timew1w3##c.w1WRATtotalcent42   ///
c.timew1w3##w1smoke  c.timew1w3##w1currdrugs c.timew1w3##c.w1hei2010_total_scorecent43  c.timew1w3##c.w1BMIcent30 c.timew1w3##w1SRH c.timew1w3##c.w1CEScent15 c.timew1w3##w1dxHTN c.timew1w3##w1dxDiabetes c.timew1w3##w1CVhighChol c.timew1w3##w1cvdbr c.timew1w3##c.invmillsmms ///
c.timew1w3##c.w1HCYcenter2p15##Sex   ///
if sample4fobs==1 || HNDID: timew1w3, cov(un)

mi estimate: mixed DigitSpanFwd  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat c.timew1w3##w1edubr c.timew1w3##c.w1WRATtotalcent42   ///
c.timew1w3##w1smoke  c.timew1w3##w1currdrugs c.timew1w3##c.w1hei2010_total_scorecent43  c.timew1w3##c.w1BMIcent30 c.timew1w3##w1SRH c.timew1w3##c.w1CEScent15 c.timew1w3##w1dxHTN c.timew1w3##w1dxDiabetes c.timew1w3##w1CVhighChol c.timew1w3##w1cvdbr c.timew1w3##c.invmillsmms ///
c.timew1w3##c.w1HCYcenter2p15##Sex   ///
if sample4gobs==1 || HNDID: timew1w3, cov(un)

mi estimate: mixed DigitSpanBck  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat c.timew1w3##w1edubr c.timew1w3##c.w1WRATtotalcent42   ///
c.timew1w3##w1smoke  c.timew1w3##w1currdrugs c.timew1w3##c.w1hei2010_total_scorecent43  c.timew1w3##c.w1BMIcent30 c.timew1w3##w1SRH c.timew1w3##c.w1CEScent15 c.timew1w3##w1dxHTN c.timew1w3##w1dxDiabetes c.timew1w3##w1CVhighChol c.timew1w3##w1cvdbr c.timew1w3##c.invmillsmms ///
c.timew1w3##c.w1HCYcenter2p15##Sex   ///
if sample4hobs==1 || HNDID: timew1w3, cov(un)

mi estimate: mixed clock_command  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat c.timew1w3##w1edubr c.timew1w3##c.w1WRATtotalcent42   ///
c.timew1w3##w1smoke  c.timew1w3##w1currdrugs c.timew1w3##c.w1hei2010_total_scorecent43  c.timew1w3##c.w1BMIcent30 c.timew1w3##w1SRH c.timew1w3##c.w1CEScent15 c.timew1w3##w1dxHTN c.timew1w3##w1dxDiabetes c.timew1w3##w1CVhighChol c.timew1w3##w1cvdbr c.timew1w3##c.invmillsmms ///
c.timew1w3##c.w1HCYcenter2p15##Sex   ///
if sample4iobs==1 || HNDID: timew1w3, cov(un)

mi estimate: mixed LnTrailsAtestSec  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat c.timew1w3##w1edubr c.timew1w3##c.w1WRATtotalcent42   ///
c.timew1w3##w1smoke  c.timew1w3##w1currdrugs c.timew1w3##c.w1hei2010_total_scorecent43  c.timew1w3##c.w1BMIcent30 c.timew1w3##w1SRH c.timew1w3##c.w1CEScent15 c.timew1w3##w1dxHTN c.timew1w3##w1dxDiabetes c.timew1w3##w1CVhighChol c.timew1w3##w1cvdbr c.timew1w3##c.invmillsmms ///
c.timew1w3##c.w1HCYcenter2p15##Sex   ///
if sample4jobs==1 || HNDID: timew1w3

mi estimate: mixed LnTrailsBtestSec  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat c.timew1w3##w1edubr c.timew1w3##c.w1WRATtotalcent42   ///
c.timew1w3##w1smoke  c.timew1w3##w1currdrugs c.timew1w3##c.w1hei2010_total_scorecent43  c.timew1w3##c.w1BMIcent30 c.timew1w3##w1SRH c.timew1w3##c.w1CEScent15 c.timew1w3##w1dxHTN c.timew1w3##w1dxDiabetes c.timew1w3##w1CVhighChol c.timew1w3##w1cvdbr c.timew1w3##c.invmillsmms ///
c.timew1w3##c.w1HCYcenter2p15##Sex   ///
if sample4kobs==1  || HNDID: timew1w3, cov(un)


save, replace


*******************************TABLE 2: HOMOCYSTEINE AT BASELINE VS. COGNITIVE CHANGE OVER TIME: WHITE**************************************



//MODEL 1: INCLUDE ONLY AGE, SEX, RACE AND POVERTY STATUS///
mi estimate: mixed MMStot  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat  c.timew1w3##c.invmillsmms ///
c.timew1w3##c.w1HCYcenter2p15   ///
if sample4aobs==1 & Race==1 || HNDID: timew1w3, cov(un)


mi estimate: mixed MMStotnorm  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat  c.timew1w3##c.invmillsmms ///
c.timew1w3##c.w1HCYcenter2p15   ///
if sample4aobs==1 & Race==1 || HNDID: timew1w3, cov(un)



mi estimate: mixed cvltca  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat  c.timew1w3##c.invmillsmms ///
c.timew1w3##c.w1HCYcenter2p15   ///
if sample4bobs==1 & Race==1 || HNDID: timew1w3



mi estimate: mixed CVLfrl  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat  c.timew1w3##c.invmillsmms ///
c.timew1w3##c.w1HCYcenter2p15   ///
if sample4cobs==1 & Race==1 || HNDID: 



mi estimate: mixed BVRtot  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat  c.timew1w3##c.invmillsmms ///
c.timew1w3##c.w1HCYcenter2p15   ///
if sample4dobs==1 & Race==1 || HNDID: timew1w3, cov(un)


mi estimate: mixed Attention  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat  c.timew1w3##c.invmillsmms ///
c.timew1w3##c.w1HCYcenter2p15   ///
if sample4eobs==1 & Race==1 || HNDID: timew1w3, cov(un)

mi estimate: mixed FluencyWord  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat  c.timew1w3##c.invmillsmms ///
c.timew1w3##c.w1HCYcenter2p15   ///
if sample4fobs==1 & Race==1 || HNDID: timew1w3, cov(un)

mi estimate: mixed DigitSpanFwd  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat  c.timew1w3##c.invmillsmms ///
c.timew1w3##c.w1HCYcenter2p15   ///
if sample4gobs==1 & Race==1 || HNDID: timew1w3, cov(un)

mi estimate: mixed DigitSpanBck  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat  c.timew1w3##c.invmillsmms ///
c.timew1w3##c.w1HCYcenter2p15   ///
if sample4hobs==1 & Race==1 || HNDID: timew1w3, cov(un)

mi estimate: mixed clock_command  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat  c.timew1w3##c.invmillsmms ///
c.timew1w3##c.w1HCYcenter2p15   ///
if sample4iobs==1 & Race==1 || HNDID: timew1w3, cov(un)

mi estimate: mixed LnTrailsAtestSec  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat  c.timew1w3##c.invmillsmms ///
c.timew1w3##c.w1HCYcenter2p15   ///
if sample4jobs==1 & Race==1 || HNDID: timew1w3

mi estimate: mixed LnTrailsBtestSec  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat  c.timew1w3##c.invmillsmms ///
c.timew1w3##c.w1HCYcenter2p15   ///
if sample4kobs==1  & Race==1 || HNDID: timew1w3, cov(un)


save, replace


//MODEL 2: MODEL 1 + OTHER FACTORS + BODY MASS INDEX///

mi estimate: mixed MMStot  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat c.timew1w3##w1edubr c.timew1w3##c.w1WRATtotalcent42   ///
c.timew1w3##w1smoke  c.timew1w3##w1currdrugs c.timew1w3##c.w1hei2010_total_scorecent43  c.timew1w3##c.w1BMIcent30  c.timew1w3##c.invmillsmms ///
c.timew1w3##c.w1HCYcenter2p15   ///
if sample4aobs==1 & Race==1 || HNDID: timew1w3, cov(un)


mi estimate: mixed MMStotnorm  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat c.timew1w3##w1edubr c.timew1w3##c.w1WRATtotalcent42   ///
c.timew1w3##w1smoke  c.timew1w3##w1currdrugs c.timew1w3##c.w1hei2010_total_scorecent43  c.timew1w3##c.w1BMIcent30  c.timew1w3##c.invmillsmms ///
c.timew1w3##c.w1HCYcenter2p15   ///
if sample4aobs==1 & Race==1 || HNDID: timew1w3



mi estimate: mixed cvltca  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat c.timew1w3##w1edubr c.timew1w3##c.w1WRATtotalcent42   ///
c.timew1w3##w1smoke  c.timew1w3##w1currdrugs c.timew1w3##c.w1hei2010_total_scorecent43  c.timew1w3##c.w1BMIcent30  c.timew1w3##c.invmillsmms ///
c.timew1w3##c.w1HCYcenter2p15   ///
if sample4bobs==1 & Race==1 || HNDID: timew1w3



mi estimate: mixed CVLfrl  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat c.timew1w3##w1edubr c.timew1w3##c.w1WRATtotalcent42   ///
c.timew1w3##w1smoke  c.timew1w3##w1currdrugs c.timew1w3##c.w1hei2010_total_scorecent43  c.timew1w3##c.w1BMIcent30  c.timew1w3##c.invmillsmms ///
c.timew1w3##c.w1HCYcenter2p15   ///
if sample4cobs==1 & Race==1 || HNDID: 



mi estimate: mixed BVRtot  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat c.timew1w3##w1edubr c.timew1w3##c.w1WRATtotalcent42   ///
c.timew1w3##w1smoke  c.timew1w3##w1currdrugs c.timew1w3##c.w1hei2010_total_scorecent43  c.timew1w3##c.w1BMIcent30  c.timew1w3##c.invmillsmms ///
c.timew1w3##c.w1HCYcenter2p15   ///
if sample4dobs==1 & Race==1 || HNDID: timew1w3, cov(un)


mi estimate: mixed Attention  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat c.timew1w3##w1edubr c.timew1w3##c.w1WRATtotalcent42   ///
c.timew1w3##w1smoke  c.timew1w3##w1currdrugs c.timew1w3##c.w1hei2010_total_scorecent43  c.timew1w3##c.w1BMIcent30  c.timew1w3##c.invmillsmms ///
c.timew1w3##c.w1HCYcenter2p15   ///
if sample4eobs==1 & Race==1 || HNDID: timew1w3, cov(un)

mi estimate: mixed FluencyWord  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat c.timew1w3##w1edubr c.timew1w3##c.w1WRATtotalcent42   ///
c.timew1w3##w1smoke  c.timew1w3##w1currdrugs c.timew1w3##c.w1hei2010_total_scorecent43  c.timew1w3##c.w1BMIcent30  c.timew1w3##c.invmillsmms ///
c.timew1w3##c.w1HCYcenter2p15   ///
if sample4fobs==1 & Race==1 || HNDID: timew1w3, cov(un)

mi estimate: mixed DigitSpanFwd  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat c.timew1w3##w1edubr c.timew1w3##c.w1WRATtotalcent42   ///
c.timew1w3##w1smoke  c.timew1w3##w1currdrugs c.timew1w3##c.w1hei2010_total_scorecent43  c.timew1w3##c.w1BMIcent30  c.timew1w3##c.invmillsmms ///
c.timew1w3##c.w1HCYcenter2p15   ///
if sample4gobs==1 & Race==1 || HNDID: timew1w3, cov(un)

mi estimate: mixed DigitSpanBck  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat c.timew1w3##w1edubr c.timew1w3##c.w1WRATtotalcent42   ///
c.timew1w3##w1smoke  c.timew1w3##w1currdrugs c.timew1w3##c.w1hei2010_total_scorecent43  c.timew1w3##c.w1BMIcent30 c.timew1w3##c.invmillsmms ///
c.timew1w3##c.w1HCYcenter2p15   ///
if sample4hobs==1 & Race==1 || HNDID: timew1w3, cov(un)

mi estimate: mixed clock_command  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat c.timew1w3##w1edubr c.timew1w3##c.w1WRATtotalcent42   ///
c.timew1w3##w1smoke  c.timew1w3##w1currdrugs c.timew1w3##c.w1hei2010_total_scorecent43  c.timew1w3##c.w1BMIcent30  c.timew1w3##c.invmillsmms ///
c.timew1w3##c.w1HCYcenter2p15   ///
if sample4iobs==1 & Race==1 || HNDID: timew1w3

mi estimate: mixed LnTrailsAtestSec  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat c.timew1w3##w1edubr c.timew1w3##c.w1WRATtotalcent42   ///
c.timew1w3##w1smoke  c.timew1w3##w1currdrugs c.timew1w3##c.w1hei2010_total_scorecent43  c.timew1w3##c.w1BMIcent30  c.timew1w3##c.invmillsmms ///
c.timew1w3##c.w1HCYcenter2p15   ///
if sample4jobs==1 & Race==1 || HNDID: timew1w3

mi estimate: mixed LnTrailsBtestSec  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat c.timew1w3##w1edubr c.timew1w3##c.w1WRATtotalcent42   ///
c.timew1w3##w1smoke  c.timew1w3##w1currdrugs c.timew1w3##c.w1hei2010_total_scorecent43  c.timew1w3##c.w1BMIcent30  c.timew1w3##c.invmillsmms ///
c.timew1w3##c.w1HCYcenter2p15   ///
if sample4kobs==1  & Race==1 || HNDID: timew1w3, cov(un)


save, replace


//MODEL 3: FULLY ADJUSTED MODEL: MODEL 2 + HEALTH-RELATED FACTORS///

mi estimate: mixed MMStot  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat c.timew1w3##w1edubr c.timew1w3##c.w1WRATtotalcent42   ///
c.timew1w3##w1smoke  c.timew1w3##w1currdrugs c.timew1w3##c.w1hei2010_total_scorecent43  c.timew1w3##c.w1BMIcent30 c.timew1w3##w1SRH c.timew1w3##c.w1CEScent15 c.timew1w3##w1dxHTN c.timew1w3##w1dxDiabetes c.timew1w3##w1CVhighChol c.timew1w3##w1cvdbr c.timew1w3##c.invmillsmms ///
c.timew1w3##c.w1HCYcenter2p15   ///
if sample4aobs==1 & Race==1 || HNDID: timew1w3, cov(un)


mi estimate: mixed MMStotnorm  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat c.timew1w3##w1edubr c.timew1w3##c.w1WRATtotalcent42   ///
c.timew1w3##w1smoke  c.timew1w3##w1currdrugs c.timew1w3##c.w1hei2010_total_scorecent43  c.timew1w3##c.w1BMIcent30 c.timew1w3##w1SRH c.timew1w3##c.w1CEScent15 c.timew1w3##w1dxHTN c.timew1w3##w1dxDiabetes c.timew1w3##w1CVhighChol c.timew1w3##w1cvdbr c.timew1w3##c.invmillsmms ///
c.timew1w3##c.w1HCYcenter2p15   ///
if sample4aobs==1 & Race==1 || HNDID: timew1w3, cov(un)



mi estimate: mixed cvltca  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat c.timew1w3##w1edubr c.timew1w3##c.w1WRATtotalcent42   ///
c.timew1w3##w1smoke  c.timew1w3##w1currdrugs c.timew1w3##c.w1hei2010_total_scorecent43  c.timew1w3##c.w1BMIcent30 c.timew1w3##w1SRH c.timew1w3##c.w1CEScent15 c.timew1w3##w1dxHTN c.timew1w3##w1dxDiabetes c.timew1w3##w1CVhighChol c.timew1w3##w1cvdbr c.timew1w3##c.invmillsmms ///
c.timew1w3##c.w1HCYcenter2p15   ///
if sample4bobs==1 & Race==1 || HNDID: timew1w3



mi estimate: mixed CVLfrl  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat c.timew1w3##w1edubr c.timew1w3##c.w1WRATtotalcent42   ///
c.timew1w3##w1smoke  c.timew1w3##w1currdrugs c.timew1w3##c.w1hei2010_total_scorecent43  c.timew1w3##c.w1BMIcent30 c.timew1w3##w1SRH c.timew1w3##c.w1CEScent15 c.timew1w3##w1dxHTN c.timew1w3##w1dxDiabetes c.timew1w3##w1CVhighChol c.timew1w3##w1cvdbr c.timew1w3##c.invmillsmms ///
c.timew1w3##c.w1HCYcenter2p15   ///
if sample4cobs==1 & Race==1 || HNDID: 



mi estimate: mixed BVRtot  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat c.timew1w3##w1edubr c.timew1w3##c.w1WRATtotalcent42   ///
c.timew1w3##w1smoke  c.timew1w3##w1currdrugs c.timew1w3##c.w1hei2010_total_scorecent43  c.timew1w3##c.w1BMIcent30 c.timew1w3##w1SRH c.timew1w3##c.w1CEScent15 c.timew1w3##w1dxHTN c.timew1w3##w1dxDiabetes c.timew1w3##w1CVhighChol c.timew1w3##w1cvdbr c.timew1w3##c.invmillsmms ///
c.timew1w3##c.w1HCYcenter2p15   ///
if sample4dobs==1 & Race==1 || HNDID: timew1w3, cov(un)


mi estimate: mixed Attention  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat c.timew1w3##w1edubr c.timew1w3##c.w1WRATtotalcent42   ///
c.timew1w3##w1smoke  c.timew1w3##w1currdrugs c.timew1w3##c.w1hei2010_total_scorecent43  c.timew1w3##c.w1BMIcent30 c.timew1w3##w1SRH c.timew1w3##c.w1CEScent15 c.timew1w3##w1dxHTN c.timew1w3##w1dxDiabetes c.timew1w3##w1CVhighChol c.timew1w3##w1cvdbr c.timew1w3##c.invmillsmms ///
c.timew1w3##c.w1HCYcenter2p15   ///
if sample4eobs==1 & Race==1 || HNDID: timew1w3, cov(un)

mi estimate: mixed FluencyWord  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat c.timew1w3##w1edubr c.timew1w3##c.w1WRATtotalcent42   ///
c.timew1w3##w1smoke  c.timew1w3##w1currdrugs c.timew1w3##c.w1hei2010_total_scorecent43  c.timew1w3##c.w1BMIcent30 c.timew1w3##w1SRH c.timew1w3##c.w1CEScent15 c.timew1w3##w1dxHTN c.timew1w3##w1dxDiabetes c.timew1w3##w1CVhighChol c.timew1w3##w1cvdbr c.timew1w3##c.invmillsmms ///
c.timew1w3##c.w1HCYcenter2p15   ///
if sample4fobs==1 & Race==1 || HNDID: timew1w3, cov(un)

mi estimate: mixed DigitSpanFwd  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat c.timew1w3##w1edubr c.timew1w3##c.w1WRATtotalcent42   ///
c.timew1w3##w1smoke  c.timew1w3##w1currdrugs c.timew1w3##c.w1hei2010_total_scorecent43  c.timew1w3##c.w1BMIcent30 c.timew1w3##w1SRH c.timew1w3##c.w1CEScent15 c.timew1w3##w1dxHTN c.timew1w3##w1dxDiabetes c.timew1w3##w1CVhighChol c.timew1w3##w1cvdbr c.timew1w3##c.invmillsmms ///
c.timew1w3##c.w1HCYcenter2p15   ///
if sample4gobs==1 & Race==1 || HNDID: timew1w3, cov(un)

mi estimate: mixed DigitSpanBck  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat c.timew1w3##w1edubr c.timew1w3##c.w1WRATtotalcent42   ///
c.timew1w3##w1smoke  c.timew1w3##w1currdrugs c.timew1w3##c.w1hei2010_total_scorecent43  c.timew1w3##c.w1BMIcent30 c.timew1w3##w1SRH c.timew1w3##c.w1CEScent15 c.timew1w3##w1dxHTN c.timew1w3##w1dxDiabetes c.timew1w3##w1CVhighChol c.timew1w3##w1cvdbr c.timew1w3##c.invmillsmms ///
c.timew1w3##c.w1HCYcenter2p15   ///
if sample4hobs==1 & Race==1 || HNDID: timew1w3

mi estimate: mixed clock_command  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat c.timew1w3##w1edubr c.timew1w3##c.w1WRATtotalcent42   ///
c.timew1w3##w1smoke  c.timew1w3##w1currdrugs c.timew1w3##c.w1hei2010_total_scorecent43  c.timew1w3##c.w1BMIcent30 c.timew1w3##w1SRH c.timew1w3##c.w1CEScent15 c.timew1w3##w1dxHTN c.timew1w3##w1dxDiabetes c.timew1w3##w1CVhighChol c.timew1w3##w1cvdbr c.timew1w3##c.invmillsmms ///
c.timew1w3##c.w1HCYcenter2p15   ///
if sample4iobs==1 & Race==1 || HNDID: timew1w3

mi estimate: mixed LnTrailsAtestSec  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat c.timew1w3##w1edubr c.timew1w3##c.w1WRATtotalcent42   ///
c.timew1w3##w1smoke  c.timew1w3##w1currdrugs c.timew1w3##c.w1hei2010_total_scorecent43  c.timew1w3##c.w1BMIcent30 c.timew1w3##w1SRH c.timew1w3##c.w1CEScent15 c.timew1w3##w1dxHTN c.timew1w3##w1dxDiabetes c.timew1w3##w1CVhighChol c.timew1w3##w1cvdbr c.timew1w3##c.invmillsmms ///
c.timew1w3##c.w1HCYcenter2p15   ///
if sample4jobs==1 & Race==1 || HNDID: timew1w3

mi estimate: mixed LnTrailsBtestSec  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat c.timew1w3##w1edubr c.timew1w3##c.w1WRATtotalcent42   ///
c.timew1w3##w1smoke  c.timew1w3##w1currdrugs c.timew1w3##c.w1hei2010_total_scorecent43  c.timew1w3##c.w1BMIcent30 c.timew1w3##w1SRH c.timew1w3##c.w1CEScent15 c.timew1w3##w1dxHTN c.timew1w3##w1dxDiabetes c.timew1w3##w1CVhighChol c.timew1w3##w1cvdbr c.timew1w3##c.invmillsmms ///
c.timew1w3##c.w1HCYcenter2p15   ///
if sample4kobs==1  & Race==1 || HNDID: timew1w3, cov(un)


save, replace



*******************************TABLE 2: HOMOCYSTEINE AT BASELINE VS. COGNITIVE CHANGE OVER TIME: AA**************************************


//MODEL 1: INCLUDE ONLY AGE, SEX, RACE AND POVERTY STATUS///
mi estimate: mixed MMStot  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat  c.timew1w3##c.invmillsmms ///
c.timew1w3##c.w1HCYcenter2p15   ///
if sample4aobs==1 & Race==2 || HNDID: timew1w3


mi estimate: mixed MMStotnorm  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat  c.timew1w3##c.invmillsmms ///
c.timew1w3##c.w1HCYcenter2p15   ///
if sample4aobs==1 & Race==2 || HNDID: timew1w3, cov(un)



mi estimate: mixed cvltca  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat  c.timew1w3##c.invmillsmms ///
c.timew1w3##c.w1HCYcenter2p15   ///
if sample4bobs==1 & Race==2 || HNDID: timew1w3



mi estimate: mixed CVLfrl  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat  c.timew1w3##c.invmillsmms ///
c.timew1w3##c.w1HCYcenter2p15   ///
if sample4cobs==1 & Race==2 || HNDID: 



mi estimate: mixed BVRtot  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat  c.timew1w3##c.invmillsmms ///
c.timew1w3##c.w1HCYcenter2p15   ///
if sample4dobs==1 & Race==2 || HNDID: timew1w3, cov(un)


mi estimate: mixed Attention  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat  c.timew1w3##c.invmillsmms ///
c.timew1w3##c.w1HCYcenter2p15   ///
if sample4eobs==1 & Race==2 || HNDID: timew1w3, cov(un)

mi estimate: mixed FluencyWord  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat  c.timew1w3##c.invmillsmms ///
c.timew1w3##c.w1HCYcenter2p15   ///
if sample4fobs==1 & Race==2 || HNDID: timew1w3, cov(un)

mi estimate: mixed DigitSpanFwd  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat  c.timew1w3##c.invmillsmms ///
c.timew1w3##c.w1HCYcenter2p15   ///
if sample4gobs==1 & Race==2 || HNDID: timew1w3, cov(un)

mi estimate: mixed DigitSpanBck  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat  c.timew1w3##c.invmillsmms ///
c.timew1w3##c.w1HCYcenter2p15   ///
if sample4hobs==1 & Race==2 || HNDID: timew1w3, cov(un)

mi estimate: mixed clock_command  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat  c.timew1w3##c.invmillsmms ///
c.timew1w3##c.w1HCYcenter2p15   ///
if sample4iobs==1 & Race==2 || HNDID: timew1w3, cov(un)

mi estimate: mixed LnTrailsAtestSec  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat  c.timew1w3##c.invmillsmms ///
c.timew1w3##c.w1HCYcenter2p15   ///
if sample4jobs==1 & Race==2 || HNDID: timew1w3

mi estimate: mixed LnTrailsBtestSec  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat  c.timew1w3##c.invmillsmms ///
c.timew1w3##c.w1HCYcenter2p15   ///
if sample4kobs==1  & Race==2 || HNDID: timew1w3, cov(un)


save, replace


//MODEL 2: MODEL 1 + BODY MASS INDEX///

mi estimate: mixed MMStot  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat c.timew1w3##w1edubr c.timew1w3##c.w1WRATtotalcent42   ///
c.timew1w3##w1smoke  c.timew1w3##w1currdrugs c.timew1w3##c.w1hei2010_total_scorecent43  c.timew1w3##c.w1BMIcent30  c.timew1w3##c.invmillsmms ///
c.timew1w3##c.w1HCYcenter2p15   ///
if sample4aobs==1 & Race==2 || HNDID: timew1w3, cov(un)


mi estimate: mixed MMStotnorm  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat c.timew1w3##w1edubr c.timew1w3##c.w1WRATtotalcent42   ///
c.timew1w3##w1smoke  c.timew1w3##w1currdrugs c.timew1w3##c.w1hei2010_total_scorecent43  c.timew1w3##c.w1BMIcent30  c.timew1w3##c.invmillsmms ///
c.timew1w3##c.w1HCYcenter2p15   ///
if sample4aobs==1 & Race==2 || HNDID: timew1w3, cov(un)



mi estimate: mixed cvltca  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat c.timew1w3##w1edubr c.timew1w3##c.w1WRATtotalcent42   ///
c.timew1w3##w1smoke  c.timew1w3##w1currdrugs c.timew1w3##c.w1hei2010_total_scorecent43  c.timew1w3##c.w1BMIcent30  c.timew1w3##c.invmillsmms ///
c.timew1w3##c.w1HCYcenter2p15   ///
if sample4bobs==1 & Race==2 || HNDID: timew1w3



mi estimate: mixed CVLfrl  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat c.timew1w3##w1edubr c.timew1w3##c.w1WRATtotalcent42   ///
c.timew1w3##w1smoke  c.timew1w3##w1currdrugs c.timew1w3##c.w1hei2010_total_scorecent43  c.timew1w3##c.w1BMIcent30  c.timew1w3##c.invmillsmms ///
c.timew1w3##c.w1HCYcenter2p15   ///
if sample4cobs==1 & Race==2 || HNDID: 



mi estimate: mixed BVRtot  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat c.timew1w3##w1edubr c.timew1w3##c.w1WRATtotalcent42   ///
c.timew1w3##w1smoke  c.timew1w3##w1currdrugs c.timew1w3##c.w1hei2010_total_scorecent43  c.timew1w3##c.w1BMIcent30  c.timew1w3##c.invmillsmms ///
c.timew1w3##c.w1HCYcenter2p15   ///
if sample4dobs==1 & Race==2 || HNDID: timew1w3, cov(un)


mi estimate: mixed Attention  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat c.timew1w3##w1edubr c.timew1w3##c.w1WRATtotalcent42   ///
c.timew1w3##w1smoke  c.timew1w3##w1currdrugs c.timew1w3##c.w1hei2010_total_scorecent43  c.timew1w3##c.w1BMIcent30  c.timew1w3##c.invmillsmms ///
c.timew1w3##c.w1HCYcenter2p15   ///
if sample4eobs==1 & Race==2 || HNDID: timew1w3, cov(un)

mi estimate: mixed FluencyWord  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat c.timew1w3##w1edubr c.timew1w3##c.w1WRATtotalcent42   ///
c.timew1w3##w1smoke  c.timew1w3##w1currdrugs c.timew1w3##c.w1hei2010_total_scorecent43  c.timew1w3##c.w1BMIcent30  c.timew1w3##c.invmillsmms ///
c.timew1w3##c.w1HCYcenter2p15   ///
if sample4fobs==1 & Race==2 || HNDID: timew1w3, cov(un)

mi estimate: mixed DigitSpanFwd  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat c.timew1w3##w1edubr c.timew1w3##c.w1WRATtotalcent42   ///
c.timew1w3##w1smoke  c.timew1w3##w1currdrugs c.timew1w3##c.w1hei2010_total_scorecent43  c.timew1w3##c.w1BMIcent30  c.timew1w3##c.invmillsmms ///
c.timew1w3##c.w1HCYcenter2p15   ///
if sample4gobs==1 & Race==2 || HNDID: timew1w3, cov(un)

mi estimate: mixed DigitSpanBck  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat c.timew1w3##w1edubr c.timew1w3##c.w1WRATtotalcent42   ///
c.timew1w3##w1smoke  c.timew1w3##w1currdrugs c.timew1w3##c.w1hei2010_total_scorecent43  c.timew1w3##c.w1BMIcent30 c.timew1w3##c.invmillsmms ///
c.timew1w3##c.w1HCYcenter2p15   ///
if sample4hobs==1 & Race==2 || HNDID: timew1w3, cov(un)

mi estimate: mixed clock_command  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat c.timew1w3##w1edubr c.timew1w3##c.w1WRATtotalcent42   ///
c.timew1w3##w1smoke  c.timew1w3##w1currdrugs c.timew1w3##c.w1hei2010_total_scorecent43  c.timew1w3##c.w1BMIcent30  c.timew1w3##c.invmillsmms ///
c.timew1w3##c.w1HCYcenter2p15   ///
if sample4iobs==1 & Race==2 || HNDID: timew1w3

mi estimate: mixed LnTrailsAtestSec  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat c.timew1w3##w1edubr c.timew1w3##c.w1WRATtotalcent42   ///
c.timew1w3##w1smoke  c.timew1w3##w1currdrugs c.timew1w3##c.w1hei2010_total_scorecent43  c.timew1w3##c.w1BMIcent30  c.timew1w3##c.invmillsmms ///
c.timew1w3##c.w1HCYcenter2p15   ///
if sample4jobs==1 & Race==2 || HNDID: timew1w3

mi estimate: mixed LnTrailsBtestSec  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat c.timew1w3##w1edubr c.timew1w3##c.w1WRATtotalcent42   ///
c.timew1w3##w1smoke  c.timew1w3##w1currdrugs c.timew1w3##c.w1hei2010_total_scorecent43  c.timew1w3##c.w1BMIcent30  c.timew1w3##c.invmillsmms ///
c.timew1w3##c.w1HCYcenter2p15   ///
if sample4kobs==1  & Race==2 || HNDID: timew1w3, cov(un)


save, replace




//MODEL 3: FULLY ADJUSTED MODEL: MODEL 2 + HEALTH-RELATED FACTORS///

mi estimate: mixed MMStot  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat c.timew1w3##w1edubr c.timew1w3##c.w1WRATtotalcent42   ///
c.timew1w3##w1smoke  c.timew1w3##w1currdrugs c.timew1w3##c.w1hei2010_total_scorecent43  c.timew1w3##c.w1BMIcent30 c.timew1w3##w1SRH c.timew1w3##c.w1CEScent15 c.timew1w3##w1dxHTN c.timew1w3##w1dxDiabetes c.timew1w3##w1CVhighChol c.timew1w3##w1cvdbr c.timew1w3##c.invmillsmms ///
c.timew1w3##c.w1HCYcenter2p15   ///
if sample4aobs==1 & Race==2 || HNDID: timew1w3, cov(un)


mi estimate: mixed MMStotnorm  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat c.timew1w3##w1edubr c.timew1w3##c.w1WRATtotalcent42   ///
c.timew1w3##w1smoke  c.timew1w3##w1currdrugs c.timew1w3##c.w1hei2010_total_scorecent43  c.timew1w3##c.w1BMIcent30 c.timew1w3##w1SRH c.timew1w3##c.w1CEScent15 c.timew1w3##w1dxHTN c.timew1w3##w1dxDiabetes c.timew1w3##w1CVhighChol c.timew1w3##w1cvdbr c.timew1w3##c.invmillsmms ///
c.timew1w3##c.w1HCYcenter2p15   ///
if sample4aobs==1 & Race==2 || HNDID: timew1w3, cov(un)



mi estimate: mixed cvltca  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat c.timew1w3##w1edubr c.timew1w3##c.w1WRATtotalcent42   ///
c.timew1w3##w1smoke  c.timew1w3##w1currdrugs c.timew1w3##c.w1hei2010_total_scorecent43  c.timew1w3##c.w1BMIcent30 c.timew1w3##w1SRH c.timew1w3##c.w1CEScent15 c.timew1w3##w1dxHTN c.timew1w3##w1dxDiabetes c.timew1w3##w1CVhighChol c.timew1w3##w1cvdbr c.timew1w3##c.invmillsmms ///
c.timew1w3##c.w1HCYcenter2p15   ///
if sample4bobs==1 & Race==2 || HNDID: timew1w3



mi estimate: mixed CVLfrl  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat c.timew1w3##w1edubr c.timew1w3##c.w1WRATtotalcent42   ///
c.timew1w3##w1smoke  c.timew1w3##w1currdrugs c.timew1w3##c.w1hei2010_total_scorecent43  c.timew1w3##c.w1BMIcent30 c.timew1w3##w1SRH c.timew1w3##c.w1CEScent15 c.timew1w3##w1dxHTN c.timew1w3##w1dxDiabetes c.timew1w3##w1CVhighChol c.timew1w3##w1cvdbr c.timew1w3##c.invmillsmms ///
c.timew1w3##c.w1HCYcenter2p15   ///
if sample4cobs==1 & Race==2 || HNDID: 



mi estimate: mixed BVRtot  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat c.timew1w3##w1edubr c.timew1w3##c.w1WRATtotalcent42   ///
c.timew1w3##w1smoke  c.timew1w3##w1currdrugs c.timew1w3##c.w1hei2010_total_scorecent43  c.timew1w3##c.w1BMIcent30 c.timew1w3##w1SRH c.timew1w3##c.w1CEScent15 c.timew1w3##w1dxHTN c.timew1w3##w1dxDiabetes c.timew1w3##w1CVhighChol c.timew1w3##w1cvdbr c.timew1w3##c.invmillsmms ///
c.timew1w3##c.w1HCYcenter2p15   ///
if sample4dobs==1 & Race==2 || HNDID: timew1w3, cov(un)


mi estimate: mixed Attention  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat c.timew1w3##w1edubr c.timew1w3##c.w1WRATtotalcent42   ///
c.timew1w3##w1smoke  c.timew1w3##w1currdrugs c.timew1w3##c.w1hei2010_total_scorecent43  c.timew1w3##c.w1BMIcent30 c.timew1w3##w1SRH c.timew1w3##c.w1CEScent15 c.timew1w3##w1dxHTN c.timew1w3##w1dxDiabetes c.timew1w3##w1CVhighChol c.timew1w3##w1cvdbr c.timew1w3##c.invmillsmms ///
c.timew1w3##c.w1HCYcenter2p15   ///
if sample4eobs==1 & Race==2 || HNDID: timew1w3, cov(un)

mi estimate: mixed FluencyWord  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat c.timew1w3##w1edubr c.timew1w3##c.w1WRATtotalcent42   ///
c.timew1w3##w1smoke  c.timew1w3##w1currdrugs c.timew1w3##c.w1hei2010_total_scorecent43  c.timew1w3##c.w1BMIcent30 c.timew1w3##w1SRH c.timew1w3##c.w1CEScent15 c.timew1w3##w1dxHTN c.timew1w3##w1dxDiabetes c.timew1w3##w1CVhighChol c.timew1w3##w1cvdbr c.timew1w3##c.invmillsmms ///
c.timew1w3##c.w1HCYcenter2p15   ///
if sample4fobs==1 & Race==2 || HNDID: timew1w3, cov(un)

mi estimate: mixed DigitSpanFwd  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat c.timew1w3##w1edubr c.timew1w3##c.w1WRATtotalcent42   ///
c.timew1w3##w1smoke  c.timew1w3##w1currdrugs c.timew1w3##c.w1hei2010_total_scorecent43  c.timew1w3##c.w1BMIcent30 c.timew1w3##w1SRH c.timew1w3##c.w1CEScent15 c.timew1w3##w1dxHTN c.timew1w3##w1dxDiabetes c.timew1w3##w1CVhighChol c.timew1w3##w1cvdbr c.timew1w3##c.invmillsmms ///
c.timew1w3##c.w1HCYcenter2p15   ///
if sample4gobs==1 & Race==2 || HNDID: timew1w3

mi estimate: mixed DigitSpanBck  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat c.timew1w3##w1edubr c.timew1w3##c.w1WRATtotalcent42   ///
c.timew1w3##w1smoke  c.timew1w3##w1currdrugs c.timew1w3##c.w1hei2010_total_scorecent43  c.timew1w3##c.w1BMIcent30 c.timew1w3##w1SRH c.timew1w3##c.w1CEScent15 c.timew1w3##w1dxHTN c.timew1w3##w1dxDiabetes c.timew1w3##w1CVhighChol c.timew1w3##w1cvdbr c.timew1w3##c.invmillsmms ///
c.timew1w3##c.w1HCYcenter2p15   ///
if sample4hobs==1 & Race==2 || HNDID: timew1w3

mi estimate: mixed clock_command  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat c.timew1w3##w1edubr c.timew1w3##c.w1WRATtotalcent42   ///
c.timew1w3##w1smoke  c.timew1w3##w1currdrugs c.timew1w3##c.w1hei2010_total_scorecent43  c.timew1w3##c.w1BMIcent30 c.timew1w3##w1SRH c.timew1w3##c.w1CEScent15 c.timew1w3##w1dxHTN c.timew1w3##w1dxDiabetes c.timew1w3##w1CVhighChol c.timew1w3##w1cvdbr c.timew1w3##c.invmillsmms ///
c.timew1w3##c.w1HCYcenter2p15   ///
if sample4iobs==1 & Race==2 || HNDID: timew1w3, cov(un)

mi estimate: mixed LnTrailsAtestSec  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat c.timew1w3##w1edubr c.timew1w3##c.w1WRATtotalcent42   ///
c.timew1w3##w1smoke  c.timew1w3##w1currdrugs c.timew1w3##c.w1hei2010_total_scorecent43  c.timew1w3##c.w1BMIcent30 c.timew1w3##w1SRH c.timew1w3##c.w1CEScent15 c.timew1w3##w1dxHTN c.timew1w3##w1dxDiabetes c.timew1w3##w1CVhighChol c.timew1w3##w1cvdbr c.timew1w3##c.invmillsmms ///
c.timew1w3##c.w1HCYcenter2p15   ///
if sample4jobs==1 & Race==2 || HNDID: timew1w3

mi estimate: mixed LnTrailsBtestSec  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat c.timew1w3##w1edubr c.timew1w3##c.w1WRATtotalcent42   ///
c.timew1w3##w1smoke  c.timew1w3##w1currdrugs c.timew1w3##c.w1hei2010_total_scorecent43  c.timew1w3##c.w1BMIcent30 c.timew1w3##w1SRH c.timew1w3##c.w1CEScent15 c.timew1w3##w1dxHTN c.timew1w3##w1dxDiabetes c.timew1w3##w1CVhighChol c.timew1w3##w1cvdbr c.timew1w3##c.invmillsmms ///
c.timew1w3##c.w1HCYcenter2p15   ///
if sample4kobs==1  & Race==2 || HNDID: timew1w3, cov(un)


save, replace


*******************************TABLE 2: HOMOCYSTEINE AT BASELINE VS. COGNITIVE CHANGE OVER TIME: INTERACTION BY Race**************************************


//MODEL 1: INCLUDE ONLY AGE, SEX, RACE AND POVERTY STATUS///
mi estimate: mixed MMStot  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat  c.timew1w3##c.invmillsmms ///
c.timew1w3##c.w1HCYcenter2p15##Race   ///
if sample4aobs==1 || HNDID: timew1w3, cov(un)


mi estimate: mixed MMStotnorm  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat  c.timew1w3##c.invmillsmms ///
c.timew1w3##c.w1HCYcenter2p15##Race   ///
if sample4aobs==1 || HNDID: timew1w3, cov(un)



mi estimate: mixed cvltca  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat  c.timew1w3##c.invmillsmms ///
c.timew1w3##c.w1HCYcenter2p15##Race   ///
if sample4bobs==1 || HNDID: timew1w3



mi estimate: mixed CVLfrl  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat  c.timew1w3##c.invmillsmms ///
c.timew1w3##c.w1HCYcenter2p15##Race   ///
if sample4cobs==1 || HNDID: 



mi estimate: mixed BVRtot  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat  c.timew1w3##c.invmillsmms ///
c.timew1w3##c.w1HCYcenter2p15##Race   ///
if sample4dobs==1 || HNDID: timew1w3, cov(un)


mi estimate: mixed Attention  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat  c.timew1w3##c.invmillsmms ///
c.timew1w3##c.w1HCYcenter2p15##Race   ///
if sample4eobs==1 || HNDID: timew1w3, cov(un)

mi estimate: mixed FluencyWord  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat  c.timew1w3##c.invmillsmms ///
c.timew1w3##c.w1HCYcenter2p15##Race   ///
if sample4fobs==1 || HNDID: timew1w3, cov(un)

mi estimate: mixed DigitSpanFwd  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat  c.timew1w3##c.invmillsmms ///
c.timew1w3##c.w1HCYcenter2p15##Race   ///
if sample4gobs==1 || HNDID: timew1w3, cov(un)

mi estimate: mixed DigitSpanBck  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat  c.timew1w3##c.invmillsmms ///
c.timew1w3##c.w1HCYcenter2p15##Race   ///
if sample4hobs==1 || HNDID: timew1w3, cov(un)

mi estimate: mixed clock_command  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat  c.timew1w3##c.invmillsmms ///
c.timew1w3##c.w1HCYcenter2p15##Race   ///
if sample4iobs==1 || HNDID: timew1w3, cov(un)

mi estimate: mixed LnTrailsAtestSec  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat  c.timew1w3##c.invmillsmms ///
c.timew1w3##c.w1HCYcenter2p15##Race   ///
if sample4jobs==1 || HNDID: timew1w3

mi estimate: mixed LnTrailsBtestSec  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat  c.timew1w3##c.invmillsmms ///
c.timew1w3##c.w1HCYcenter2p15##Race   ///
if sample4kobs==1  || HNDID: timew1w3, cov(un)


save, replace


//MODEL 2: MODEL 1 + OTHER FACTORS + BODY MASS INDEX///

mi estimate: mixed MMStot  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat c.timew1w3##w1edubr c.timew1w3##c.w1WRATtotalcent42   ///
c.timew1w3##w1smoke  c.timew1w3##w1currdrugs c.timew1w3##c.w1hei2010_total_scorecent43  c.timew1w3##c.w1BMIcent30  c.timew1w3##c.invmillsmms ///
c.timew1w3##c.w1HCYcenter2p15##Race   ///
if sample4aobs==1 || HNDID: timew1w3, cov(un)


mi estimate: mixed MMStotnorm  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat c.timew1w3##w1edubr c.timew1w3##c.w1WRATtotalcent42   ///
c.timew1w3##w1smoke  c.timew1w3##w1currdrugs c.timew1w3##c.w1hei2010_total_scorecent43  c.timew1w3##c.w1BMIcent30  c.timew1w3##c.invmillsmms ///
c.timew1w3##c.w1HCYcenter2p15##Race   ///
if sample4aobs==1 || HNDID: timew1w3, cov(un)



mi estimate: mixed cvltca  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat c.timew1w3##w1edubr c.timew1w3##c.w1WRATtotalcent42   ///
c.timew1w3##w1smoke  c.timew1w3##w1currdrugs c.timew1w3##c.w1hei2010_total_scorecent43  c.timew1w3##c.w1BMIcent30  c.timew1w3##c.invmillsmms ///
c.timew1w3##c.w1HCYcenter2p15##Race   ///
if sample4bobs==1 || HNDID: timew1w3



mi estimate: mixed CVLfrl  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat c.timew1w3##w1edubr c.timew1w3##c.w1WRATtotalcent42   ///
c.timew1w3##w1smoke  c.timew1w3##w1currdrugs c.timew1w3##c.w1hei2010_total_scorecent43  c.timew1w3##c.w1BMIcent30  c.timew1w3##c.invmillsmms ///
c.timew1w3##c.w1HCYcenter2p15##Race   ///
if sample4cobs==1 || HNDID: 



mi estimate: mixed BVRtot  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat c.timew1w3##w1edubr c.timew1w3##c.w1WRATtotalcent42   ///
c.timew1w3##w1smoke  c.timew1w3##w1currdrugs c.timew1w3##c.w1hei2010_total_scorecent43  c.timew1w3##c.w1BMIcent30  c.timew1w3##c.invmillsmms ///
c.timew1w3##c.w1HCYcenter2p15##Race   ///
if sample4dobs==1 || HNDID: timew1w3, cov(un)


mi estimate: mixed Attention  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat c.timew1w3##w1edubr c.timew1w3##c.w1WRATtotalcent42   ///
c.timew1w3##w1smoke  c.timew1w3##w1currdrugs c.timew1w3##c.w1hei2010_total_scorecent43  c.timew1w3##c.w1BMIcent30  c.timew1w3##c.invmillsmms ///
c.timew1w3##c.w1HCYcenter2p15##Race   ///
if sample4eobs==1 || HNDID: timew1w3, cov(un)

mi estimate: mixed FluencyWord  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat c.timew1w3##w1edubr c.timew1w3##c.w1WRATtotalcent42   ///
c.timew1w3##w1smoke  c.timew1w3##w1currdrugs c.timew1w3##c.w1hei2010_total_scorecent43  c.timew1w3##c.w1BMIcent30  c.timew1w3##c.invmillsmms ///
c.timew1w3##c.w1HCYcenter2p15##Race   ///
if sample4fobs==1 || HNDID: timew1w3, cov(un)

mi estimate: mixed DigitSpanFwd  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat c.timew1w3##w1edubr c.timew1w3##c.w1WRATtotalcent42   ///
c.timew1w3##w1smoke  c.timew1w3##w1currdrugs c.timew1w3##c.w1hei2010_total_scorecent43  c.timew1w3##c.w1BMIcent30  c.timew1w3##c.invmillsmms ///
c.timew1w3##c.w1HCYcenter2p15##Race   ///
if sample4gobs==1 || HNDID: timew1w3, cov(un)

mi estimate: mixed DigitSpanBck  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat c.timew1w3##w1edubr c.timew1w3##c.w1WRATtotalcent42   ///
c.timew1w3##w1smoke  c.timew1w3##w1currdrugs c.timew1w3##c.w1hei2010_total_scorecent43  c.timew1w3##c.w1BMIcent30 c.timew1w3##c.invmillsmms ///
c.timew1w3##c.w1HCYcenter2p15##Race   ///
if sample4hobs==1 || HNDID: timew1w3

mi estimate: mixed clock_command  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat c.timew1w3##w1edubr c.timew1w3##c.w1WRATtotalcent42   ///
c.timew1w3##w1smoke  c.timew1w3##w1currdrugs c.timew1w3##c.w1hei2010_total_scorecent43  c.timew1w3##c.w1BMIcent30  c.timew1w3##c.invmillsmms ///
c.timew1w3##c.w1HCYcenter2p15##Race   ///
if sample4iobs==1 || HNDID: timew1w3, cov(un)

mi estimate: mixed LnTrailsAtestSec  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat c.timew1w3##w1edubr c.timew1w3##c.w1WRATtotalcent42   ///
c.timew1w3##w1smoke  c.timew1w3##w1currdrugs c.timew1w3##c.w1hei2010_total_scorecent43  c.timew1w3##c.w1BMIcent30  c.timew1w3##c.invmillsmms ///
c.timew1w3##c.w1HCYcenter2p15##Race   ///
if sample4jobs==1 || HNDID: timew1w3

mi estimate: mixed LnTrailsBtestSec  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat c.timew1w3##w1edubr c.timew1w3##c.w1WRATtotalcent42   ///
c.timew1w3##w1smoke  c.timew1w3##w1currdrugs c.timew1w3##c.w1hei2010_total_scorecent43  c.timew1w3##c.w1BMIcent30  c.timew1w3##c.invmillsmms ///
c.timew1w3##c.w1HCYcenter2p15##Race   ///
if sample4kobs==1  || HNDID: timew1w3, cov(un)


save, replace


//MODEL 3: FULLY ADJUSTED MODEL: MODEL 2 + HEALTH-RELATED FACTORS///

mi estimate: mixed MMStot  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat c.timew1w3##w1edubr c.timew1w3##c.w1WRATtotalcent42   ///
c.timew1w3##w1smoke  c.timew1w3##w1currdrugs c.timew1w3##c.w1hei2010_total_scorecent43  c.timew1w3##c.w1BMIcent30 c.timew1w3##w1SRH c.timew1w3##c.w1CEScent15 c.timew1w3##w1dxHTN c.timew1w3##w1dxDiabetes c.timew1w3##w1CVhighChol c.timew1w3##w1cvdbr c.timew1w3##c.invmillsmms ///
c.timew1w3##c.w1HCYcenter2p15##Race   ///
if sample4aobs==1 || HNDID: timew1w3


mi estimate: mixed MMStotnorm  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat c.timew1w3##w1edubr c.timew1w3##c.w1WRATtotalcent42   ///
c.timew1w3##w1smoke  c.timew1w3##w1currdrugs c.timew1w3##c.w1hei2010_total_scorecent43  c.timew1w3##c.w1BMIcent30 c.timew1w3##w1SRH c.timew1w3##c.w1CEScent15 c.timew1w3##w1dxHTN c.timew1w3##w1dxDiabetes c.timew1w3##w1CVhighChol c.timew1w3##w1cvdbr c.timew1w3##c.invmillsmms ///
c.timew1w3##c.w1HCYcenter2p15##Race   ///
if sample4aobs==1 || HNDID: timew1w3



mi estimate: mixed cvltca  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat c.timew1w3##w1edubr c.timew1w3##c.w1WRATtotalcent42   ///
c.timew1w3##w1smoke  c.timew1w3##w1currdrugs c.timew1w3##c.w1hei2010_total_scorecent43  c.timew1w3##c.w1BMIcent30 c.timew1w3##w1SRH c.timew1w3##c.w1CEScent15 c.timew1w3##w1dxHTN c.timew1w3##w1dxDiabetes c.timew1w3##w1CVhighChol c.timew1w3##w1cvdbr c.timew1w3##c.invmillsmms ///
c.timew1w3##c.w1HCYcenter2p15##Race   ///
if sample4bobs==1 || HNDID: timew1w3



mi estimate: mixed CVLfrl  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat c.timew1w3##w1edubr c.timew1w3##c.w1WRATtotalcent42   ///
c.timew1w3##w1smoke  c.timew1w3##w1currdrugs c.timew1w3##c.w1hei2010_total_scorecent43  c.timew1w3##c.w1BMIcent30 c.timew1w3##w1SRH c.timew1w3##c.w1CEScent15 c.timew1w3##w1dxHTN c.timew1w3##w1dxDiabetes c.timew1w3##w1CVhighChol c.timew1w3##w1cvdbr c.timew1w3##c.invmillsmms ///
c.timew1w3##c.w1HCYcenter2p15##Race   ///
if sample4cobs==1 || HNDID: 



mi estimate: mixed BVRtot  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat c.timew1w3##w1edubr c.timew1w3##c.w1WRATtotalcent42   ///
c.timew1w3##w1smoke  c.timew1w3##w1currdrugs c.timew1w3##c.w1hei2010_total_scorecent43  c.timew1w3##c.w1BMIcent30 c.timew1w3##w1SRH c.timew1w3##c.w1CEScent15 c.timew1w3##w1dxHTN c.timew1w3##w1dxDiabetes c.timew1w3##w1CVhighChol c.timew1w3##w1cvdbr c.timew1w3##c.invmillsmms ///
c.timew1w3##c.w1HCYcenter2p15##Race   ///
if sample4dobs==1 || HNDID: timew1w3, cov(un)


mi estimate: mixed Attention  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat c.timew1w3##w1edubr c.timew1w3##c.w1WRATtotalcent42   ///
c.timew1w3##w1smoke  c.timew1w3##w1currdrugs c.timew1w3##c.w1hei2010_total_scorecent43  c.timew1w3##c.w1BMIcent30 c.timew1w3##w1SRH c.timew1w3##c.w1CEScent15 c.timew1w3##w1dxHTN c.timew1w3##w1dxDiabetes c.timew1w3##w1CVhighChol c.timew1w3##w1cvdbr c.timew1w3##c.invmillsmms ///
c.timew1w3##c.w1HCYcenter2p15##Race   ///
if sample4eobs==1 || HNDID: timew1w3, cov(un)

mi estimate: mixed FluencyWord  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat c.timew1w3##w1edubr c.timew1w3##c.w1WRATtotalcent42   ///
c.timew1w3##w1smoke  c.timew1w3##w1currdrugs c.timew1w3##c.w1hei2010_total_scorecent43  c.timew1w3##c.w1BMIcent30 c.timew1w3##w1SRH c.timew1w3##c.w1CEScent15 c.timew1w3##w1dxHTN c.timew1w3##w1dxDiabetes c.timew1w3##w1CVhighChol c.timew1w3##w1cvdbr c.timew1w3##c.invmillsmms ///
c.timew1w3##c.w1HCYcenter2p15##Race   ///
if sample4fobs==1 || HNDID: timew1w3, cov(un)

mi estimate: mixed DigitSpanFwd  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat c.timew1w3##w1edubr c.timew1w3##c.w1WRATtotalcent42   ///
c.timew1w3##w1smoke  c.timew1w3##w1currdrugs c.timew1w3##c.w1hei2010_total_scorecent43  c.timew1w3##c.w1BMIcent30 c.timew1w3##w1SRH c.timew1w3##c.w1CEScent15 c.timew1w3##w1dxHTN c.timew1w3##w1dxDiabetes c.timew1w3##w1CVhighChol c.timew1w3##w1cvdbr c.timew1w3##c.invmillsmms ///
c.timew1w3##c.w1HCYcenter2p15##Race   ///
if sample4gobs==1 || HNDID: timew1w3, cov(un)

mi estimate: mixed DigitSpanBck  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat c.timew1w3##w1edubr c.timew1w3##c.w1WRATtotalcent42   ///
c.timew1w3##w1smoke  c.timew1w3##w1currdrugs c.timew1w3##c.w1hei2010_total_scorecent43  c.timew1w3##c.w1BMIcent30 c.timew1w3##w1SRH c.timew1w3##c.w1CEScent15 c.timew1w3##w1dxHTN c.timew1w3##w1dxDiabetes c.timew1w3##w1CVhighChol c.timew1w3##w1cvdbr c.timew1w3##c.invmillsmms ///
c.timew1w3##c.w1HCYcenter2p15##Race   ///
if sample4hobs==1 || HNDID: timew1w3, cov(un)

mi estimate: mixed clock_command  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat c.timew1w3##w1edubr c.timew1w3##c.w1WRATtotalcent42   ///
c.timew1w3##w1smoke  c.timew1w3##w1currdrugs c.timew1w3##c.w1hei2010_total_scorecent43  c.timew1w3##c.w1BMIcent30 c.timew1w3##w1SRH c.timew1w3##c.w1CEScent15 c.timew1w3##w1dxHTN c.timew1w3##w1dxDiabetes c.timew1w3##w1CVhighChol c.timew1w3##w1cvdbr c.timew1w3##c.invmillsmms ///
c.timew1w3##c.w1HCYcenter2p15##Race   ///
if sample4iobs==1 || HNDID: timew1w3, cov(un)

mi estimate: mixed LnTrailsAtestSec  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat c.timew1w3##w1edubr c.timew1w3##c.w1WRATtotalcent42   ///
c.timew1w3##w1smoke  c.timew1w3##w1currdrugs c.timew1w3##c.w1hei2010_total_scorecent43  c.timew1w3##c.w1BMIcent30 c.timew1w3##w1SRH c.timew1w3##c.w1CEScent15 c.timew1w3##w1dxHTN c.timew1w3##w1dxDiabetes c.timew1w3##w1CVhighChol c.timew1w3##w1cvdbr c.timew1w3##c.invmillsmms ///
c.timew1w3##c.w1HCYcenter2p15##Race   ///
if sample4jobs==1 || HNDID: timew1w3

mi estimate: mixed LnTrailsBtestSec  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat c.timew1w3##w1edubr c.timew1w3##c.w1WRATtotalcent42   ///
c.timew1w3##w1smoke  c.timew1w3##w1currdrugs c.timew1w3##c.w1hei2010_total_scorecent43  c.timew1w3##c.w1BMIcent30 c.timew1w3##w1SRH c.timew1w3##c.w1CEScent15 c.timew1w3##w1dxHTN c.timew1w3##w1dxDiabetes c.timew1w3##w1CVhighChol c.timew1w3##w1cvdbr c.timew1w3##c.invmillsmms ///
c.timew1w3##c.w1HCYcenter2p15##Race   ///
if sample4kobs==1  || HNDID: timew1w3, cov(un)


save, replace



capture log close


capture log close

log using "E:\HANDLS_PAPER65_HCY_COGN\OUTPUT\TABLE3.smcl", replace

*******************************TABLE 3: HOMOCYSTEINE TRAJECTORY BETWEEN WAVES 1 AND 3 VS. COGNITIVE CHANGE OVER TIME: OVERALL**************************************

//MODEL 1: INCLUDE ONLY AGE, SEX, RACE AND POVERTY STATUS///
mi estimate: mixed MMStot  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat  c.timew1w3##c.invmillsmms ///
c.timew1w3##c.zw1w3HCYTRAJ   ///
if sample4aobs==1 || HNDID: timew1w3, cov(un)


mi estimate: mixed MMStotnorm  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat  c.timew1w3##c.invmillsmms ///
c.timew1w3##c.zw1w3HCYTRAJ   ///
if sample4aobs==1 || HNDID: timew1w3, cov(un)



mi estimate: mixed cvltca  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat  c.timew1w3##c.invmillsmms ///
c.timew1w3##c.zw1w3HCYTRAJ   ///
if sample4bobs==1 || HNDID: timew1w3



mi estimate: mixed CVLfrl  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat  c.timew1w3##c.invmillsmms ///
c.timew1w3##c.zw1w3HCYTRAJ   ///
if sample4cobs==1 || HNDID: timew1w3



mi estimate: mixed BVRtot  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat  c.timew1w3##c.invmillsmms ///
c.timew1w3##c.zw1w3HCYTRAJ   ///
if sample4dobs==1 || HNDID: timew1w3, cov(un)


mi estimate: mixed Attention  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat  c.timew1w3##c.invmillsmms ///
c.timew1w3##c.zw1w3HCYTRAJ   ///
if sample4eobs==1 || HNDID: timew1w3, cov(un)

mi estimate: mixed FluencyWord  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat  c.timew1w3##c.invmillsmms ///
c.timew1w3##c.zw1w3HCYTRAJ   ///
if sample4fobs==1 || HNDID: timew1w3, cov(un)

mi estimate: mixed DigitSpanFwd  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat  c.timew1w3##c.invmillsmms ///
c.timew1w3##c.zw1w3HCYTRAJ   ///
if sample4gobs==1 || HNDID: timew1w3, cov(un)

mi estimate: mixed DigitSpanBck  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat  c.timew1w3##c.invmillsmms ///
c.timew1w3##c.zw1w3HCYTRAJ   ///
if sample4hobs==1 || HNDID: timew1w3, cov(un)

mi estimate: mixed clock_command  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat  c.timew1w3##c.invmillsmms ///
c.timew1w3##c.zw1w3HCYTRAJ   ///
if sample4iobs==1 || HNDID: timew1w3, cov(un)

mi estimate: mixed LnTrailsAtestSec  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat  c.timew1w3##c.invmillsmms ///
c.timew1w3##c.zw1w3HCYTRAJ   ///
if sample4jobs==1 || HNDID: timew1w3

mi estimate: mixed LnTrailsBtestSec  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat  c.timew1w3##c.invmillsmms ///
c.timew1w3##c.zw1w3HCYTRAJ   ///
if sample4kobs==1  || HNDID: timew1w3, cov(un)


save, replace



//MODEL 2: MODEL 1 + BODY MASS INDEX///

mi estimate: mixed MMStot  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat c.timew1w3##w1edubr c.timew1w3##c.w1WRATtotalcent42   ///
c.timew1w3##w1smoke  c.timew1w3##w1currdrugs c.timew1w3##c.w1hei2010_total_scorecent43  c.timew1w3##c.w1BMIcent30  c.timew1w3##c.invmillsmms ///
c.timew1w3##c.zw1w3HCYTRAJ   ///
if sample4aobs==1 || HNDID: timew1w3


mi estimate: mixed MMStotnorm  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat c.timew1w3##w1edubr c.timew1w3##c.w1WRATtotalcent42   ///
c.timew1w3##w1smoke  c.timew1w3##w1currdrugs c.timew1w3##c.w1hei2010_total_scorecent43  c.timew1w3##c.w1BMIcent30  c.timew1w3##c.invmillsmms ///
c.timew1w3##c.zw1w3HCYTRAJ   ///
if sample4aobs==1 || HNDID: timew1w3, cov(un)



mi estimate: mixed cvltca  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat c.timew1w3##w1edubr c.timew1w3##c.w1WRATtotalcent42   ///
c.timew1w3##w1smoke  c.timew1w3##w1currdrugs c.timew1w3##c.w1hei2010_total_scorecent43  c.timew1w3##c.w1BMIcent30  c.timew1w3##c.invmillsmms ///
c.timew1w3##c.zw1w3HCYTRAJ   ///
if sample4bobs==1 || HNDID: timew1w3



mi estimate: mixed CVLfrl  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat c.timew1w3##w1edubr c.timew1w3##c.w1WRATtotalcent42   ///
c.timew1w3##w1smoke  c.timew1w3##w1currdrugs c.timew1w3##c.w1hei2010_total_scorecent43  c.timew1w3##c.w1BMIcent30  c.timew1w3##c.invmillsmms ///
c.timew1w3##c.zw1w3HCYTRAJ   ///
if sample4cobs==1 || HNDID: timew1w3



mi estimate: mixed BVRtot  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat c.timew1w3##w1edubr c.timew1w3##c.w1WRATtotalcent42   ///
c.timew1w3##w1smoke  c.timew1w3##w1currdrugs c.timew1w3##c.w1hei2010_total_scorecent43  c.timew1w3##c.w1BMIcent30  c.timew1w3##c.invmillsmms ///
c.timew1w3##c.zw1w3HCYTRAJ   ///
if sample4dobs==1 || HNDID: timew1w3, cov(un)


mi estimate: mixed Attention  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat c.timew1w3##w1edubr c.timew1w3##c.w1WRATtotalcent42   ///
c.timew1w3##w1smoke  c.timew1w3##w1currdrugs c.timew1w3##c.w1hei2010_total_scorecent43  c.timew1w3##c.w1BMIcent30  c.timew1w3##c.invmillsmms ///
c.timew1w3##c.zw1w3HCYTRAJ   ///
if sample4eobs==1 || HNDID: timew1w3, cov(un)

mi estimate: mixed FluencyWord  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat c.timew1w3##w1edubr c.timew1w3##c.w1WRATtotalcent42   ///
c.timew1w3##w1smoke  c.timew1w3##w1currdrugs c.timew1w3##c.w1hei2010_total_scorecent43  c.timew1w3##c.w1BMIcent30  c.timew1w3##c.invmillsmms ///
c.timew1w3##c.zw1w3HCYTRAJ   ///
if sample4fobs==1 || HNDID: timew1w3, cov(un)

mi estimate: mixed DigitSpanFwd  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat c.timew1w3##w1edubr c.timew1w3##c.w1WRATtotalcent42   ///
c.timew1w3##w1smoke  c.timew1w3##w1currdrugs c.timew1w3##c.w1hei2010_total_scorecent43  c.timew1w3##c.w1BMIcent30  c.timew1w3##c.invmillsmms ///
c.timew1w3##c.zw1w3HCYTRAJ   ///
if sample4gobs==1 || HNDID: timew1w3, cov(un)

mi estimate: mixed DigitSpanBck  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat c.timew1w3##w1edubr c.timew1w3##c.w1WRATtotalcent42   ///
c.timew1w3##w1smoke  c.timew1w3##w1currdrugs c.timew1w3##c.w1hei2010_total_scorecent43  c.timew1w3##c.w1BMIcent30 c.timew1w3##c.invmillsmms ///
c.timew1w3##c.zw1w3HCYTRAJ   ///
if sample4hobs==1 || HNDID: timew1w3

mi estimate: mixed clock_command  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat c.timew1w3##w1edubr c.timew1w3##c.w1WRATtotalcent42   ///
c.timew1w3##w1smoke  c.timew1w3##w1currdrugs c.timew1w3##c.w1hei2010_total_scorecent43  c.timew1w3##c.w1BMIcent30  c.timew1w3##c.invmillsmms ///
c.timew1w3##c.zw1w3HCYTRAJ   ///
if sample4iobs==1 || HNDID: timew1w3, cov(un)

mi estimate: mixed LnTrailsAtestSec  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat c.timew1w3##w1edubr c.timew1w3##c.w1WRATtotalcent42   ///
c.timew1w3##w1smoke  c.timew1w3##w1currdrugs c.timew1w3##c.w1hei2010_total_scorecent43  c.timew1w3##c.w1BMIcent30  c.timew1w3##c.invmillsmms ///
c.timew1w3##c.zw1w3HCYTRAJ   ///
if sample4jobs==1 || HNDID: timew1w3

mi estimate: mixed LnTrailsBtestSec  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat c.timew1w3##w1edubr c.timew1w3##c.w1WRATtotalcent42   ///
c.timew1w3##w1smoke  c.timew1w3##w1currdrugs c.timew1w3##c.w1hei2010_total_scorecent43  c.timew1w3##c.w1BMIcent30  c.timew1w3##c.invmillsmms ///
c.timew1w3##c.zw1w3HCYTRAJ   ///
if sample4kobs==1  || HNDID: timew1w3, cov(un)


save, replace


//MODEL 3: FULLY ADJUSTED MODEL: MODEL 2 + HEALTH-RELATED FACTORS///

mi estimate: mixed MMStot  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat c.timew1w3##w1edubr c.timew1w3##c.w1WRATtotalcent42   ///
c.timew1w3##w1smoke  c.timew1w3##w1currdrugs c.timew1w3##c.w1hei2010_total_scorecent43  c.timew1w3##c.w1BMIcent30 c.timew1w3##w1SRH c.timew1w3##c.w1CEScent15 c.timew1w3##w1dxHTN c.timew1w3##w1dxDiabetes c.timew1w3##w1CVhighChol c.timew1w3##w1cvdbr c.timew1w3##c.invmillsmms ///
c.timew1w3##c.zw1w3HCYTRAJ   ///
if sample4aobs==1 || HNDID: timew1w3, cov(un)


mi estimate: mixed MMStotnorm  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat c.timew1w3##w1edubr c.timew1w3##c.w1WRATtotalcent42   ///
c.timew1w3##w1smoke  c.timew1w3##w1currdrugs c.timew1w3##c.w1hei2010_total_scorecent43  c.timew1w3##c.w1BMIcent30 c.timew1w3##w1SRH c.timew1w3##c.w1CEScent15 c.timew1w3##w1dxHTN c.timew1w3##w1dxDiabetes c.timew1w3##w1CVhighChol c.timew1w3##w1cvdbr c.timew1w3##c.invmillsmms ///
c.timew1w3##c.zw1w3HCYTRAJ   ///
if sample4aobs==1 || HNDID: timew1w3



mi estimate: mixed cvltca  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat c.timew1w3##w1edubr c.timew1w3##c.w1WRATtotalcent42   ///
c.timew1w3##w1smoke  c.timew1w3##w1currdrugs c.timew1w3##c.w1hei2010_total_scorecent43  c.timew1w3##c.w1BMIcent30 c.timew1w3##w1SRH c.timew1w3##c.w1CEScent15 c.timew1w3##w1dxHTN c.timew1w3##w1dxDiabetes c.timew1w3##w1CVhighChol c.timew1w3##w1cvdbr c.timew1w3##c.invmillsmms ///
c.timew1w3##c.zw1w3HCYTRAJ   ///
if sample4bobs==1 || HNDID: timew1w3



mi estimate: mixed CVLfrl  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat c.timew1w3##w1edubr c.timew1w3##c.w1WRATtotalcent42   ///
c.timew1w3##w1smoke  c.timew1w3##w1currdrugs c.timew1w3##c.w1hei2010_total_scorecent43  c.timew1w3##c.w1BMIcent30 c.timew1w3##w1SRH c.timew1w3##c.w1CEScent15 c.timew1w3##w1dxHTN c.timew1w3##w1dxDiabetes c.timew1w3##w1CVhighChol c.timew1w3##w1cvdbr c.timew1w3##c.invmillsmms ///
c.timew1w3##c.zw1w3HCYTRAJ   ///
if sample4cobs==1 || HNDID: timew1w3



mi estimate: mixed BVRtot  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat c.timew1w3##w1edubr c.timew1w3##c.w1WRATtotalcent42   ///
c.timew1w3##w1smoke  c.timew1w3##w1currdrugs c.timew1w3##c.w1hei2010_total_scorecent43  c.timew1w3##c.w1BMIcent30 c.timew1w3##w1SRH c.timew1w3##c.w1CEScent15 c.timew1w3##w1dxHTN c.timew1w3##w1dxDiabetes c.timew1w3##w1CVhighChol c.timew1w3##w1cvdbr c.timew1w3##c.invmillsmms ///
c.timew1w3##c.zw1w3HCYTRAJ   ///
if sample4dobs==1 || HNDID: timew1w3, cov(un)


mi estimate: mixed Attention  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat c.timew1w3##w1edubr c.timew1w3##c.w1WRATtotalcent42   ///
c.timew1w3##w1smoke  c.timew1w3##w1currdrugs c.timew1w3##c.w1hei2010_total_scorecent43  c.timew1w3##c.w1BMIcent30 c.timew1w3##w1SRH c.timew1w3##c.w1CEScent15 c.timew1w3##w1dxHTN c.timew1w3##w1dxDiabetes c.timew1w3##w1CVhighChol c.timew1w3##w1cvdbr c.timew1w3##c.invmillsmms ///
c.timew1w3##c.zw1w3HCYTRAJ   ///
if sample4eobs==1 || HNDID: timew1w3, cov(un)

mi estimate: mixed FluencyWord  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat c.timew1w3##w1edubr c.timew1w3##c.w1WRATtotalcent42   ///
c.timew1w3##w1smoke  c.timew1w3##w1currdrugs c.timew1w3##c.w1hei2010_total_scorecent43  c.timew1w3##c.w1BMIcent30 c.timew1w3##w1SRH c.timew1w3##c.w1CEScent15 c.timew1w3##w1dxHTN c.timew1w3##w1dxDiabetes c.timew1w3##w1CVhighChol c.timew1w3##w1cvdbr c.timew1w3##c.invmillsmms ///
c.timew1w3##c.zw1w3HCYTRAJ   ///
if sample4fobs==1 || HNDID: timew1w3, cov(un)

mi estimate: mixed DigitSpanFwd  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat c.timew1w3##w1edubr c.timew1w3##c.w1WRATtotalcent42   ///
c.timew1w3##w1smoke  c.timew1w3##w1currdrugs c.timew1w3##c.w1hei2010_total_scorecent43  c.timew1w3##c.w1BMIcent30 c.timew1w3##w1SRH c.timew1w3##c.w1CEScent15 c.timew1w3##w1dxHTN c.timew1w3##w1dxDiabetes c.timew1w3##w1CVhighChol c.timew1w3##w1cvdbr c.timew1w3##c.invmillsmms ///
c.timew1w3##c.zw1w3HCYTRAJ   ///
if sample4gobs==1 || HNDID: timew1w3, cov(un)

mi estimate: mixed DigitSpanBck  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat c.timew1w3##w1edubr c.timew1w3##c.w1WRATtotalcent42   ///
c.timew1w3##w1smoke  c.timew1w3##w1currdrugs c.timew1w3##c.w1hei2010_total_scorecent43  c.timew1w3##c.w1BMIcent30 c.timew1w3##w1SRH c.timew1w3##c.w1CEScent15 c.timew1w3##w1dxHTN c.timew1w3##w1dxDiabetes c.timew1w3##w1CVhighChol c.timew1w3##w1cvdbr c.timew1w3##c.invmillsmms ///
c.timew1w3##c.zw1w3HCYTRAJ   ///
if sample4hobs==1 || HNDID: timew1w3, cov(un)

mi estimate: mixed clock_command  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat c.timew1w3##w1edubr c.timew1w3##c.w1WRATtotalcent42   ///
c.timew1w3##w1smoke  c.timew1w3##w1currdrugs c.timew1w3##c.w1hei2010_total_scorecent43  c.timew1w3##c.w1BMIcent30 c.timew1w3##w1SRH c.timew1w3##c.w1CEScent15 c.timew1w3##w1dxHTN c.timew1w3##w1dxDiabetes c.timew1w3##w1CVhighChol c.timew1w3##w1cvdbr c.timew1w3##c.invmillsmms ///
c.timew1w3##c.zw1w3HCYTRAJ   ///
if sample4iobs==1 || HNDID: timew1w3, cov(un)

mi estimate: mixed LnTrailsAtestSec  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat c.timew1w3##w1edubr c.timew1w3##c.w1WRATtotalcent42   ///
c.timew1w3##w1smoke  c.timew1w3##w1currdrugs c.timew1w3##c.w1hei2010_total_scorecent43  c.timew1w3##c.w1BMIcent30 c.timew1w3##w1SRH c.timew1w3##c.w1CEScent15 c.timew1w3##w1dxHTN c.timew1w3##w1dxDiabetes c.timew1w3##w1CVhighChol c.timew1w3##w1cvdbr c.timew1w3##c.invmillsmms ///
c.timew1w3##c.zw1w3HCYTRAJ   ///
if sample4jobs==1 || HNDID: timew1w3

mi estimate: mixed LnTrailsBtestSec  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat c.timew1w3##w1edubr c.timew1w3##c.w1WRATtotalcent42   ///
c.timew1w3##w1smoke  c.timew1w3##w1currdrugs c.timew1w3##c.w1hei2010_total_scorecent43  c.timew1w3##c.w1BMIcent30 c.timew1w3##w1SRH c.timew1w3##c.w1CEScent15 c.timew1w3##w1dxHTN c.timew1w3##w1dxDiabetes c.timew1w3##w1CVhighChol c.timew1w3##w1cvdbr c.timew1w3##c.invmillsmms ///
c.timew1w3##c.zw1w3HCYTRAJ   ///
if sample4kobs==1  || HNDID: timew1w3, cov(un)


save, replace

*******************************TABLE 3: HOMOCYSTEINE TRAJECTORY VS. COGNITIVE CHANGE OVER TIME: WOMEN**************************************


//MODEL 1: INCLUDE ONLY AGE, SEX, RACE AND POVERTY STATUS///
mi estimate: mixed MMStot  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat  c.timew1w3##c.invmillsmms ///
c.timew1w3##c.zw1w3HCYTRAJ   ///
if sample4aobs==1 & Sex==1 || HNDID: timew1w3, cov(un)


mi estimate: mixed MMStotnorm  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat  c.timew1w3##c.invmillsmms ///
c.timew1w3##c.zw1w3HCYTRAJ   ///
if sample4aobs==1 & Sex==1 || HNDID: timew1w3, cov(un)



mi estimate: mixed cvltca  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat  c.timew1w3##c.invmillsmms ///
c.timew1w3##c.zw1w3HCYTRAJ   ///
if sample4bobs==1 & Sex==1 || HNDID: timew1w3



mi estimate: mixed CVLfrl  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat  c.timew1w3##c.invmillsmms ///
c.timew1w3##c.zw1w3HCYTRAJ   ///
if sample4cobs==1 & Sex==1 || HNDID: timew1w3



mi estimate: mixed BVRtot  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat  c.timew1w3##c.invmillsmms ///
c.timew1w3##c.zw1w3HCYTRAJ   ///
if sample4dobs==1 & Sex==1 || HNDID: timew1w3, cov(un)


mi estimate: mixed Attention  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat  c.timew1w3##c.invmillsmms ///
c.timew1w3##c.zw1w3HCYTRAJ   ///
if sample4eobs==1 & Sex==1 || HNDID: timew1w3, cov(un)

mi estimate: mixed FluencyWord  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat  c.timew1w3##c.invmillsmms ///
c.timew1w3##c.zw1w3HCYTRAJ   ///
if sample4fobs==1 & Sex==1 || HNDID: timew1w3, cov(un)

mi estimate: mixed DigitSpanFwd  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat  c.timew1w3##c.invmillsmms ///
c.timew1w3##c.zw1w3HCYTRAJ   ///
if sample4gobs==1 & Sex==1 || HNDID: timew1w3, cov(un)

mi estimate: mixed DigitSpanBck  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat  c.timew1w3##c.invmillsmms ///
c.timew1w3##c.zw1w3HCYTRAJ   ///
if sample4hobs==1 & Sex==1 || HNDID: timew1w3

mi estimate: mixed clock_command  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat  c.timew1w3##c.invmillsmms ///
c.timew1w3##c.zw1w3HCYTRAJ   ///
if sample4iobs==1 & Sex==1 || HNDID: timew1w3, cov(un)

mi estimate: mixed LnTrailsAtestSec  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat  c.timew1w3##c.invmillsmms ///
c.timew1w3##c.zw1w3HCYTRAJ   ///
if sample4jobs==1 & Sex==1 || HNDID: timew1w3

mi estimate: mixed LnTrailsBtestSec  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat  c.timew1w3##c.invmillsmms ///
c.timew1w3##c.zw1w3HCYTRAJ   ///
if sample4kobs==1  & Sex==1 || HNDID: timew1w3, cov(un)


save, replace



//MODEL 2: MODEL 1 + BODY MASS INDEX///

mi estimate: mixed MMStot  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat c.timew1w3##w1edubr c.timew1w3##c.w1WRATtotalcent42   ///
c.timew1w3##w1smoke  c.timew1w3##w1currdrugs c.timew1w3##c.w1hei2010_total_scorecent43  c.timew1w3##c.w1BMIcent30  c.timew1w3##c.invmillsmms ///
c.timew1w3##c.zw1w3HCYTRAJ   ///
if sample4aobs==1 & Sex==1 || HNDID: timew1w3, cov(un)


mi estimate: mixed MMStotnorm  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat c.timew1w3##w1edubr c.timew1w3##c.w1WRATtotalcent42   ///
c.timew1w3##w1smoke  c.timew1w3##w1currdrugs c.timew1w3##c.w1hei2010_total_scorecent43  c.timew1w3##c.w1BMIcent30  c.timew1w3##c.invmillsmms ///
c.timew1w3##c.zw1w3HCYTRAJ   ///
if sample4aobs==1 & Sex==1 || HNDID: timew1w3, cov(un)



mi estimate: mixed cvltca  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat c.timew1w3##w1edubr c.timew1w3##c.w1WRATtotalcent42   ///
c.timew1w3##w1smoke  c.timew1w3##w1currdrugs c.timew1w3##c.w1hei2010_total_scorecent43  c.timew1w3##c.w1BMIcent30  c.timew1w3##c.invmillsmms ///
c.timew1w3##c.zw1w3HCYTRAJ   ///
if sample4bobs==1 & Sex==1 || HNDID: timew1w3



mi estimate: mixed CVLfrl  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat c.timew1w3##w1edubr c.timew1w3##c.w1WRATtotalcent42   ///
c.timew1w3##w1smoke  c.timew1w3##w1currdrugs c.timew1w3##c.w1hei2010_total_scorecent43  c.timew1w3##c.w1BMIcent30  c.timew1w3##c.invmillsmms ///
c.timew1w3##c.zw1w3HCYTRAJ   ///
if sample4cobs==1 & Sex==1 || HNDID: timew1w3



mi estimate: mixed BVRtot  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat c.timew1w3##w1edubr c.timew1w3##c.w1WRATtotalcent42   ///
c.timew1w3##w1smoke  c.timew1w3##w1currdrugs c.timew1w3##c.w1hei2010_total_scorecent43  c.timew1w3##c.w1BMIcent30  c.timew1w3##c.invmillsmms ///
c.timew1w3##c.zw1w3HCYTRAJ   ///
if sample4dobs==1 & Sex==1 || HNDID: timew1w3, cov(un)


mi estimate: mixed Attention  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat c.timew1w3##w1edubr c.timew1w3##c.w1WRATtotalcent42   ///
c.timew1w3##w1smoke  c.timew1w3##w1currdrugs c.timew1w3##c.w1hei2010_total_scorecent43  c.timew1w3##c.w1BMIcent30  c.timew1w3##c.invmillsmms ///
c.timew1w3##c.zw1w3HCYTRAJ   ///
if sample4eobs==1 & Sex==1 || HNDID: timew1w3, cov(un)

mi estimate: mixed FluencyWord  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat c.timew1w3##w1edubr c.timew1w3##c.w1WRATtotalcent42   ///
c.timew1w3##w1smoke  c.timew1w3##w1currdrugs c.timew1w3##c.w1hei2010_total_scorecent43  c.timew1w3##c.w1BMIcent30  c.timew1w3##c.invmillsmms ///
c.timew1w3##c.zw1w3HCYTRAJ   ///
if sample4fobs==1 & Sex==1 || HNDID: timew1w3, cov(un)

mi estimate: mixed DigitSpanFwd  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat c.timew1w3##w1edubr c.timew1w3##c.w1WRATtotalcent42   ///
c.timew1w3##w1smoke  c.timew1w3##w1currdrugs c.timew1w3##c.w1hei2010_total_scorecent43  c.timew1w3##c.w1BMIcent30  c.timew1w3##c.invmillsmms ///
c.timew1w3##c.zw1w3HCYTRAJ   ///
if sample4gobs==1 & Sex==1 || HNDID: timew1w3

mi estimate: mixed DigitSpanBck  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat c.timew1w3##w1edubr c.timew1w3##c.w1WRATtotalcent42   ///
c.timew1w3##w1smoke  c.timew1w3##w1currdrugs c.timew1w3##c.w1hei2010_total_scorecent43  c.timew1w3##c.w1BMIcent30 c.timew1w3##c.invmillsmms ///
c.timew1w3##c.zw1w3HCYTRAJ   ///
if sample4hobs==1 & Sex==1 || HNDID: timew1w3, cov(un)

mi estimate: mixed clock_command  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat c.timew1w3##w1edubr c.timew1w3##c.w1WRATtotalcent42   ///
c.timew1w3##w1smoke  c.timew1w3##w1currdrugs c.timew1w3##c.w1hei2010_total_scorecent43  c.timew1w3##c.w1BMIcent30  c.timew1w3##c.invmillsmms ///
c.timew1w3##c.zw1w3HCYTRAJ   ///
if sample4iobs==1 & Sex==1 || HNDID: timew1w3, cov(un)

mi estimate: mixed LnTrailsAtestSec  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat c.timew1w3##w1edubr c.timew1w3##c.w1WRATtotalcent42   ///
c.timew1w3##w1smoke  c.timew1w3##w1currdrugs c.timew1w3##c.w1hei2010_total_scorecent43  c.timew1w3##c.w1BMIcent30  c.timew1w3##c.invmillsmms ///
c.timew1w3##c.zw1w3HCYTRAJ   ///
if sample4jobs==1 & Sex==1 || HNDID: timew1w3

mi estimate: mixed LnTrailsBtestSec  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat c.timew1w3##w1edubr c.timew1w3##c.w1WRATtotalcent42   ///
c.timew1w3##w1smoke  c.timew1w3##w1currdrugs c.timew1w3##c.w1hei2010_total_scorecent43  c.timew1w3##c.w1BMIcent30  c.timew1w3##c.invmillsmms ///
c.timew1w3##c.zw1w3HCYTRAJ   ///
if sample4kobs==1  & Sex==1 || HNDID: timew1w3, cov(un)


save, replace


//MODEL 3: FULLY ADJUSTED MODEL: MODEL 2 + HEALTH-RELATED FACTORS///

mi estimate: mixed MMStot  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat c.timew1w3##w1edubr c.timew1w3##c.w1WRATtotalcent42   ///
c.timew1w3##w1smoke  c.timew1w3##w1currdrugs c.timew1w3##c.w1hei2010_total_scorecent43  c.timew1w3##c.w1BMIcent30 c.timew1w3##w1SRH c.timew1w3##c.w1CEScent15 c.timew1w3##w1dxHTN c.timew1w3##w1dxDiabetes c.timew1w3##w1CVhighChol c.timew1w3##w1cvdbr c.timew1w3##c.invmillsmms ///
c.timew1w3##c.zw1w3HCYTRAJ   ///
if sample4aobs==1 & Sex==1 || HNDID: timew1w3, cov(un)


mi estimate: mixed MMStotnorm  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat c.timew1w3##w1edubr c.timew1w3##c.w1WRATtotalcent42   ///
c.timew1w3##w1smoke  c.timew1w3##w1currdrugs c.timew1w3##c.w1hei2010_total_scorecent43  c.timew1w3##c.w1BMIcent30 c.timew1w3##w1SRH c.timew1w3##c.w1CEScent15 c.timew1w3##w1dxHTN c.timew1w3##w1dxDiabetes c.timew1w3##w1CVhighChol c.timew1w3##w1cvdbr c.timew1w3##c.invmillsmms ///
c.timew1w3##c.zw1w3HCYTRAJ   ///
if sample4aobs==1 & Sex==1 || HNDID: timew1w3, cov(un)



mi estimate: mixed cvltca  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat c.timew1w3##w1edubr c.timew1w3##c.w1WRATtotalcent42   ///
c.timew1w3##w1smoke  c.timew1w3##w1currdrugs c.timew1w3##c.w1hei2010_total_scorecent43  c.timew1w3##c.w1BMIcent30 c.timew1w3##w1SRH c.timew1w3##c.w1CEScent15 c.timew1w3##w1dxHTN c.timew1w3##w1dxDiabetes c.timew1w3##w1CVhighChol c.timew1w3##w1cvdbr c.timew1w3##c.invmillsmms ///
c.timew1w3##c.zw1w3HCYTRAJ   ///
if sample4bobs==1 & Sex==1 || HNDID: timew1w3



mi estimate: mixed CVLfrl  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat c.timew1w3##w1edubr c.timew1w3##c.w1WRATtotalcent42   ///
c.timew1w3##w1smoke  c.timew1w3##w1currdrugs c.timew1w3##c.w1hei2010_total_scorecent43  c.timew1w3##c.w1BMIcent30 c.timew1w3##w1SRH c.timew1w3##c.w1CEScent15 c.timew1w3##w1dxHTN c.timew1w3##w1dxDiabetes c.timew1w3##w1CVhighChol c.timew1w3##w1cvdbr c.timew1w3##c.invmillsmms ///
c.timew1w3##c.zw1w3HCYTRAJ   ///
if sample4cobs==1 & Sex==1 || HNDID: timew1w3



mi estimate: mixed BVRtot  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat c.timew1w3##w1edubr c.timew1w3##c.w1WRATtotalcent42   ///
c.timew1w3##w1smoke  c.timew1w3##w1currdrugs c.timew1w3##c.w1hei2010_total_scorecent43  c.timew1w3##c.w1BMIcent30 c.timew1w3##w1SRH c.timew1w3##c.w1CEScent15 c.timew1w3##w1dxHTN c.timew1w3##w1dxDiabetes c.timew1w3##w1CVhighChol c.timew1w3##w1cvdbr c.timew1w3##c.invmillsmms ///
c.timew1w3##c.zw1w3HCYTRAJ   ///
if sample4dobs==1 & Sex==1 || HNDID: timew1w3, cov(un)


mi estimate: mixed Attention  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat c.timew1w3##w1edubr c.timew1w3##c.w1WRATtotalcent42   ///
c.timew1w3##w1smoke  c.timew1w3##w1currdrugs c.timew1w3##c.w1hei2010_total_scorecent43  c.timew1w3##c.w1BMIcent30 c.timew1w3##w1SRH c.timew1w3##c.w1CEScent15 c.timew1w3##w1dxHTN c.timew1w3##w1dxDiabetes c.timew1w3##w1CVhighChol c.timew1w3##w1cvdbr c.timew1w3##c.invmillsmms ///
c.timew1w3##c.zw1w3HCYTRAJ   ///
if sample4eobs==1 & Sex==1 || HNDID: timew1w3, cov(un)

mi estimate: mixed FluencyWord  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat c.timew1w3##w1edubr c.timew1w3##c.w1WRATtotalcent42   ///
c.timew1w3##w1smoke  c.timew1w3##w1currdrugs c.timew1w3##c.w1hei2010_total_scorecent43  c.timew1w3##c.w1BMIcent30 c.timew1w3##w1SRH c.timew1w3##c.w1CEScent15 c.timew1w3##w1dxHTN c.timew1w3##w1dxDiabetes c.timew1w3##w1CVhighChol c.timew1w3##w1cvdbr c.timew1w3##c.invmillsmms ///
c.timew1w3##c.zw1w3HCYTRAJ   ///
if sample4fobs==1 & Sex==1 || HNDID: timew1w3, cov(un)

mi estimate: mixed DigitSpanFwd  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat c.timew1w3##w1edubr c.timew1w3##c.w1WRATtotalcent42   ///
c.timew1w3##w1smoke  c.timew1w3##w1currdrugs c.timew1w3##c.w1hei2010_total_scorecent43  c.timew1w3##c.w1BMIcent30 c.timew1w3##w1SRH c.timew1w3##c.w1CEScent15 c.timew1w3##w1dxHTN c.timew1w3##w1dxDiabetes c.timew1w3##w1CVhighChol c.timew1w3##w1cvdbr c.timew1w3##c.invmillsmms ///
c.timew1w3##c.zw1w3HCYTRAJ   ///
if sample4gobs==1 & Sex==1 || HNDID: timew1w3, cov(un)

mi estimate: mixed DigitSpanBck  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat c.timew1w3##w1edubr c.timew1w3##c.w1WRATtotalcent42   ///
c.timew1w3##w1smoke  c.timew1w3##w1currdrugs c.timew1w3##c.w1hei2010_total_scorecent43  c.timew1w3##c.w1BMIcent30 c.timew1w3##w1SRH c.timew1w3##c.w1CEScent15 c.timew1w3##w1dxHTN c.timew1w3##w1dxDiabetes c.timew1w3##w1CVhighChol c.timew1w3##w1cvdbr c.timew1w3##c.invmillsmms ///
c.timew1w3##c.zw1w3HCYTRAJ   ///
if sample4hobs==1 & Sex==1 || HNDID: timew1w3, cov(un)

mi estimate: mixed clock_command  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat c.timew1w3##w1edubr c.timew1w3##c.w1WRATtotalcent42   ///
c.timew1w3##w1smoke  c.timew1w3##w1currdrugs c.timew1w3##c.w1hei2010_total_scorecent43  c.timew1w3##c.w1BMIcent30 c.timew1w3##w1SRH c.timew1w3##c.w1CEScent15 c.timew1w3##w1dxHTN c.timew1w3##w1dxDiabetes c.timew1w3##w1CVhighChol c.timew1w3##w1cvdbr c.timew1w3##c.invmillsmms ///
c.timew1w3##c.zw1w3HCYTRAJ   ///
if sample4iobs==1 & Sex==1 || HNDID: timew1w3, cov(un)

mi estimate: mixed LnTrailsAtestSec  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat c.timew1w3##w1edubr c.timew1w3##c.w1WRATtotalcent42   ///
c.timew1w3##w1smoke  c.timew1w3##w1currdrugs c.timew1w3##c.w1hei2010_total_scorecent43  c.timew1w3##c.w1BMIcent30 c.timew1w3##w1SRH c.timew1w3##c.w1CEScent15 c.timew1w3##w1dxHTN c.timew1w3##w1dxDiabetes c.timew1w3##w1CVhighChol c.timew1w3##w1cvdbr c.timew1w3##c.invmillsmms ///
c.timew1w3##c.zw1w3HCYTRAJ   ///
if sample4jobs==1 & Sex==1 || HNDID: timew1w3

mi estimate: mixed LnTrailsBtestSec  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat c.timew1w3##w1edubr c.timew1w3##c.w1WRATtotalcent42   ///
c.timew1w3##w1smoke  c.timew1w3##w1currdrugs c.timew1w3##c.w1hei2010_total_scorecent43  c.timew1w3##c.w1BMIcent30 c.timew1w3##w1SRH c.timew1w3##c.w1CEScent15 c.timew1w3##w1dxHTN c.timew1w3##w1dxDiabetes c.timew1w3##w1CVhighChol c.timew1w3##w1cvdbr c.timew1w3##c.invmillsmms ///
c.timew1w3##c.zw1w3HCYTRAJ   ///
if sample4kobs==1  & Sex==1 || HNDID: timew1w3, cov(un)


save, replace



*******************************TABLE 3: HOMOCYSTEINE TRAJECTORY VS. COGNITIVE CHANGE OVER TIME: MEN**************************************

//MODEL 1: INCLUDE ONLY AGE, SEX, RACE AND POVERTY STATUS///
mi estimate: mixed MMStot  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat  c.timew1w3##c.invmillsmms ///
c.timew1w3##c.zw1w3HCYTRAJ   ///
if sample4aobs==1 & Sex==2 || HNDID: timew1w3, cov(un)


mi estimate: mixed MMStotnorm  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat  c.timew1w3##c.invmillsmms ///
c.timew1w3##c.zw1w3HCYTRAJ   ///
if sample4aobs==1 & Sex==2 || HNDID: timew1w3, cov(un)



mi estimate: mixed cvltca  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat  c.timew1w3##c.invmillsmms ///
c.timew1w3##c.zw1w3HCYTRAJ   ///
if sample4bobs==1 & Sex==2 || HNDID: timew1w3



mi estimate: mixed CVLfrl  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat  c.timew1w3##c.invmillsmms ///
c.timew1w3##c.zw1w3HCYTRAJ   ///
if sample4cobs==1 & Sex==2 || HNDID: timew1w3



mi estimate: mixed BVRtot  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat  c.timew1w3##c.invmillsmms ///
c.timew1w3##c.zw1w3HCYTRAJ   ///
if sample4dobs==1 & Sex==2 || HNDID: timew1w3, cov(un)


mi estimate: mixed Attention  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat  c.timew1w3##c.invmillsmms ///
c.timew1w3##c.zw1w3HCYTRAJ   ///
if sample4eobs==1 & Sex==2 || HNDID: timew1w3, cov(un)

mi estimate: mixed FluencyWord  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat  c.timew1w3##c.invmillsmms ///
c.timew1w3##c.zw1w3HCYTRAJ   ///
if sample4fobs==1 & Sex==2 || HNDID: timew1w3, cov(un)

mi estimate: mixed DigitSpanFwd  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat  c.timew1w3##c.invmillsmms ///
c.timew1w3##c.zw1w3HCYTRAJ   ///
if sample4gobs==1 & Sex==2 || HNDID: timew1w3, cov(un)

mi estimate: mixed DigitSpanBck  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat  c.timew1w3##c.invmillsmms ///
c.timew1w3##c.zw1w3HCYTRAJ   ///
if sample4hobs==1 & Sex==2 || HNDID: timew1w3, cov(un)

mi estimate: mixed clock_command  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat  c.timew1w3##c.invmillsmms ///
c.timew1w3##c.zw1w3HCYTRAJ   ///
if sample4iobs==1 & Sex==2 || HNDID: timew1w3, cov(un)

mi estimate: mixed LnTrailsAtestSec  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat  c.timew1w3##c.invmillsmms ///
c.timew1w3##c.zw1w3HCYTRAJ   ///
if sample4jobs==1 & Sex==2 || HNDID: timew1w3

mi estimate: mixed LnTrailsBtestSec  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat  c.timew1w3##c.invmillsmms ///
c.timew1w3##c.zw1w3HCYTRAJ   ///
if sample4kobs==1  & Sex==2 || HNDID: timew1w3, cov(un)


save, replace



//MODEL 2: MODEL 1 + OTHER FACTORS + BODY MASS INDEX///

mi estimate: mixed MMStot  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat c.timew1w3##w1edubr c.timew1w3##c.w1WRATtotalcent42   ///
c.timew1w3##w1smoke  c.timew1w3##w1currdrugs c.timew1w3##c.w1hei2010_total_scorecent43  c.timew1w3##c.w1BMIcent30  c.timew1w3##c.invmillsmms ///
c.timew1w3##c.zw1w3HCYTRAJ   ///
if sample4aobs==1 & Sex==2 || HNDID: timew1w3, cov(un)


mi estimate: mixed MMStotnorm  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat c.timew1w3##w1edubr c.timew1w3##c.w1WRATtotalcent42   ///
c.timew1w3##w1smoke  c.timew1w3##w1currdrugs c.timew1w3##c.w1hei2010_total_scorecent43  c.timew1w3##c.w1BMIcent30  c.timew1w3##c.invmillsmms ///
c.timew1w3##c.zw1w3HCYTRAJ   ///
if sample4aobs==1 & Sex==2 || HNDID: timew1w3, cov(un)



mi estimate: mixed cvltca  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat c.timew1w3##w1edubr c.timew1w3##c.w1WRATtotalcent42   ///
c.timew1w3##w1smoke  c.timew1w3##w1currdrugs c.timew1w3##c.w1hei2010_total_scorecent43  c.timew1w3##c.w1BMIcent30  c.timew1w3##c.invmillsmms ///
c.timew1w3##c.zw1w3HCYTRAJ   ///
if sample4bobs==1 & Sex==2 || HNDID: timew1w3



mi estimate: mixed CVLfrl  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat c.timew1w3##w1edubr c.timew1w3##c.w1WRATtotalcent42   ///
c.timew1w3##w1smoke  c.timew1w3##w1currdrugs c.timew1w3##c.w1hei2010_total_scorecent43  c.timew1w3##c.w1BMIcent30  c.timew1w3##c.invmillsmms ///
c.timew1w3##c.zw1w3HCYTRAJ   ///
if sample4cobs==1 & Sex==2 || HNDID: timew1w3



mi estimate: mixed BVRtot  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat c.timew1w3##w1edubr c.timew1w3##c.w1WRATtotalcent42   ///
c.timew1w3##w1smoke  c.timew1w3##w1currdrugs c.timew1w3##c.w1hei2010_total_scorecent43  c.timew1w3##c.w1BMIcent30  c.timew1w3##c.invmillsmms ///
c.timew1w3##c.zw1w3HCYTRAJ   ///
if sample4dobs==1 & Sex==2 || HNDID: timew1w3, cov(un)


mi estimate: mixed Attention  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat c.timew1w3##w1edubr c.timew1w3##c.w1WRATtotalcent42   ///
c.timew1w3##w1smoke  c.timew1w3##w1currdrugs c.timew1w3##c.w1hei2010_total_scorecent43  c.timew1w3##c.w1BMIcent30  c.timew1w3##c.invmillsmms ///
c.timew1w3##c.zw1w3HCYTRAJ   ///
if sample4eobs==1 & Sex==2 || HNDID: timew1w3, cov(un)

mi estimate: mixed FluencyWord  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat c.timew1w3##w1edubr c.timew1w3##c.w1WRATtotalcent42   ///
c.timew1w3##w1smoke  c.timew1w3##w1currdrugs c.timew1w3##c.w1hei2010_total_scorecent43  c.timew1w3##c.w1BMIcent30  c.timew1w3##c.invmillsmms ///
c.timew1w3##c.zw1w3HCYTRAJ   ///
if sample4fobs==1 & Sex==2 || HNDID: timew1w3

mi estimate: mixed DigitSpanFwd  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat c.timew1w3##w1edubr c.timew1w3##c.w1WRATtotalcent42   ///
c.timew1w3##w1smoke  c.timew1w3##w1currdrugs c.timew1w3##c.w1hei2010_total_scorecent43  c.timew1w3##c.w1BMIcent30  c.timew1w3##c.invmillsmms ///
c.timew1w3##c.zw1w3HCYTRAJ   ///
if sample4gobs==1 & Sex==2 || HNDID: timew1w3, cov(un)

mi estimate: mixed DigitSpanBck  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat c.timew1w3##w1edubr c.timew1w3##c.w1WRATtotalcent42   ///
c.timew1w3##w1smoke  c.timew1w3##w1currdrugs c.timew1w3##c.w1hei2010_total_scorecent43  c.timew1w3##c.w1BMIcent30 c.timew1w3##c.invmillsmms ///
c.timew1w3##c.zw1w3HCYTRAJ   ///
if sample4hobs==1 & Sex==2 || HNDID: timew1w3, cov(un)

mi estimate: mixed clock_command  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat c.timew1w3##w1edubr c.timew1w3##c.w1WRATtotalcent42   ///
c.timew1w3##w1smoke  c.timew1w3##w1currdrugs c.timew1w3##c.w1hei2010_total_scorecent43  c.timew1w3##c.w1BMIcent30  c.timew1w3##c.invmillsmms ///
c.timew1w3##c.zw1w3HCYTRAJ   ///
if sample4iobs==1 & Sex==2 || HNDID: timew1w3, cov(un)

mi estimate: mixed LnTrailsAtestSec  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat c.timew1w3##w1edubr c.timew1w3##c.w1WRATtotalcent42   ///
c.timew1w3##w1smoke  c.timew1w3##w1currdrugs c.timew1w3##c.w1hei2010_total_scorecent43  c.timew1w3##c.w1BMIcent30  c.timew1w3##c.invmillsmms ///
c.timew1w3##c.zw1w3HCYTRAJ   ///
if sample4jobs==1 & Sex==2 || HNDID: timew1w3

mi estimate: mixed LnTrailsBtestSec  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat c.timew1w3##w1edubr c.timew1w3##c.w1WRATtotalcent42   ///
c.timew1w3##w1smoke  c.timew1w3##w1currdrugs c.timew1w3##c.w1hei2010_total_scorecent43  c.timew1w3##c.w1BMIcent30  c.timew1w3##c.invmillsmms ///
c.timew1w3##c.zw1w3HCYTRAJ   ///
if sample4kobs==1  & Sex==2 || HNDID: timew1w3, cov(un)


save, replace


//MODEL 3: FULLY ADJUSTED MODEL: MODEL 2 + HEALTH-RELATED FACTORS///

mi estimate: mixed MMStot  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat c.timew1w3##w1edubr c.timew1w3##c.w1WRATtotalcent42   ///
c.timew1w3##w1smoke  c.timew1w3##w1currdrugs c.timew1w3##c.w1hei2010_total_scorecent43  c.timew1w3##c.w1BMIcent30 c.timew1w3##w1SRH c.timew1w3##c.w1CEScent15 c.timew1w3##w1dxHTN c.timew1w3##w1dxDiabetes c.timew1w3##w1CVhighChol c.timew1w3##w1cvdbr c.timew1w3##c.invmillsmms ///
c.timew1w3##c.zw1w3HCYTRAJ   ///
if sample4aobs==1 & Sex==2 || HNDID: timew1w3, cov(un)


mi estimate: mixed MMStotnorm  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat c.timew1w3##w1edubr c.timew1w3##c.w1WRATtotalcent42   ///
c.timew1w3##w1smoke  c.timew1w3##w1currdrugs c.timew1w3##c.w1hei2010_total_scorecent43  c.timew1w3##c.w1BMIcent30 c.timew1w3##w1SRH c.timew1w3##c.w1CEScent15 c.timew1w3##w1dxHTN c.timew1w3##w1dxDiabetes c.timew1w3##w1CVhighChol c.timew1w3##w1cvdbr c.timew1w3##c.invmillsmms ///
c.timew1w3##c.zw1w3HCYTRAJ   ///
if sample4aobs==1 & Sex==2 || HNDID: timew1w3, cov(un)



mi estimate: mixed cvltca  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat c.timew1w3##w1edubr c.timew1w3##c.w1WRATtotalcent42   ///
c.timew1w3##w1smoke  c.timew1w3##w1currdrugs c.timew1w3##c.w1hei2010_total_scorecent43  c.timew1w3##c.w1BMIcent30 c.timew1w3##w1SRH c.timew1w3##c.w1CEScent15 c.timew1w3##w1dxHTN c.timew1w3##w1dxDiabetes c.timew1w3##w1CVhighChol c.timew1w3##w1cvdbr c.timew1w3##c.invmillsmms ///
c.timew1w3##c.zw1w3HCYTRAJ   ///
if sample4bobs==1 & Sex==2 || HNDID: timew1w3



mi estimate: mixed CVLfrl  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat c.timew1w3##w1edubr c.timew1w3##c.w1WRATtotalcent42   ///
c.timew1w3##w1smoke  c.timew1w3##w1currdrugs c.timew1w3##c.w1hei2010_total_scorecent43  c.timew1w3##c.w1BMIcent30 c.timew1w3##w1SRH c.timew1w3##c.w1CEScent15 c.timew1w3##w1dxHTN c.timew1w3##w1dxDiabetes c.timew1w3##w1CVhighChol c.timew1w3##w1cvdbr c.timew1w3##c.invmillsmms ///
c.timew1w3##c.zw1w3HCYTRAJ   ///
if sample4cobs==1 & Sex==2 || HNDID: timew1w3



mi estimate: mixed BVRtot  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat c.timew1w3##w1edubr c.timew1w3##c.w1WRATtotalcent42   ///
c.timew1w3##w1smoke  c.timew1w3##w1currdrugs c.timew1w3##c.w1hei2010_total_scorecent43  c.timew1w3##c.w1BMIcent30 c.timew1w3##w1SRH c.timew1w3##c.w1CEScent15 c.timew1w3##w1dxHTN c.timew1w3##w1dxDiabetes c.timew1w3##w1CVhighChol c.timew1w3##w1cvdbr c.timew1w3##c.invmillsmms ///
c.timew1w3##c.zw1w3HCYTRAJ   ///
if sample4dobs==1 & Sex==2 || HNDID: timew1w3, cov(un)


mi estimate: mixed Attention  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat c.timew1w3##w1edubr c.timew1w3##c.w1WRATtotalcent42   ///
c.timew1w3##w1smoke  c.timew1w3##w1currdrugs c.timew1w3##c.w1hei2010_total_scorecent43  c.timew1w3##c.w1BMIcent30 c.timew1w3##w1SRH c.timew1w3##c.w1CEScent15 c.timew1w3##w1dxHTN c.timew1w3##w1dxDiabetes c.timew1w3##w1CVhighChol c.timew1w3##w1cvdbr c.timew1w3##c.invmillsmms ///
c.timew1w3##c.zw1w3HCYTRAJ   ///
if sample4eobs==1 & Sex==2 || HNDID: timew1w3, cov(un)

mi estimate: mixed FluencyWord  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat c.timew1w3##w1edubr c.timew1w3##c.w1WRATtotalcent42   ///
c.timew1w3##w1smoke  c.timew1w3##w1currdrugs c.timew1w3##c.w1hei2010_total_scorecent43  c.timew1w3##c.w1BMIcent30 c.timew1w3##w1SRH c.timew1w3##c.w1CEScent15 c.timew1w3##w1dxHTN c.timew1w3##w1dxDiabetes c.timew1w3##w1CVhighChol c.timew1w3##w1cvdbr c.timew1w3##c.invmillsmms ///
c.timew1w3##c.zw1w3HCYTRAJ   ///
if sample4fobs==1 & Sex==2 || HNDID: timew1w3

mi estimate: mixed DigitSpanFwd  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat c.timew1w3##w1edubr c.timew1w3##c.w1WRATtotalcent42   ///
c.timew1w3##w1smoke  c.timew1w3##w1currdrugs c.timew1w3##c.w1hei2010_total_scorecent43  c.timew1w3##c.w1BMIcent30 c.timew1w3##w1SRH c.timew1w3##c.w1CEScent15 c.timew1w3##w1dxHTN c.timew1w3##w1dxDiabetes c.timew1w3##w1CVhighChol c.timew1w3##w1cvdbr c.timew1w3##c.invmillsmms ///
c.timew1w3##c.zw1w3HCYTRAJ   ///
if sample4gobs==1 & Sex==2 || HNDID: timew1w3, cov(un)

mi estimate: mixed DigitSpanBck  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat c.timew1w3##w1edubr c.timew1w3##c.w1WRATtotalcent42   ///
c.timew1w3##w1smoke  c.timew1w3##w1currdrugs c.timew1w3##c.w1hei2010_total_scorecent43  c.timew1w3##c.w1BMIcent30 c.timew1w3##w1SRH c.timew1w3##c.w1CEScent15 c.timew1w3##w1dxHTN c.timew1w3##w1dxDiabetes c.timew1w3##w1CVhighChol c.timew1w3##w1cvdbr c.timew1w3##c.invmillsmms ///
c.timew1w3##c.zw1w3HCYTRAJ   ///
if sample4hobs==1 & Sex==2 || HNDID: timew1w3, cov(un)

mi estimate: mixed clock_command  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat c.timew1w3##w1edubr c.timew1w3##c.w1WRATtotalcent42   ///
c.timew1w3##w1smoke  c.timew1w3##w1currdrugs c.timew1w3##c.w1hei2010_total_scorecent43  c.timew1w3##c.w1BMIcent30 c.timew1w3##w1SRH c.timew1w3##c.w1CEScent15 c.timew1w3##w1dxHTN c.timew1w3##w1dxDiabetes c.timew1w3##w1CVhighChol c.timew1w3##w1cvdbr c.timew1w3##c.invmillsmms ///
c.timew1w3##c.zw1w3HCYTRAJ   ///
if sample4iobs==1 & Sex==2 || HNDID: timew1w3

mi estimate: mixed LnTrailsAtestSec  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat c.timew1w3##w1edubr c.timew1w3##c.w1WRATtotalcent42   ///
c.timew1w3##w1smoke  c.timew1w3##w1currdrugs c.timew1w3##c.w1hei2010_total_scorecent43  c.timew1w3##c.w1BMIcent30 c.timew1w3##w1SRH c.timew1w3##c.w1CEScent15 c.timew1w3##w1dxHTN c.timew1w3##w1dxDiabetes c.timew1w3##w1CVhighChol c.timew1w3##w1cvdbr c.timew1w3##c.invmillsmms ///
c.timew1w3##c.zw1w3HCYTRAJ   ///
if sample4jobs==1 & Sex==2 || HNDID: timew1w3

mi estimate: mixed LnTrailsBtestSec  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat c.timew1w3##w1edubr c.timew1w3##c.w1WRATtotalcent42   ///
c.timew1w3##w1smoke  c.timew1w3##w1currdrugs c.timew1w3##c.w1hei2010_total_scorecent43  c.timew1w3##c.w1BMIcent30 c.timew1w3##w1SRH c.timew1w3##c.w1CEScent15 c.timew1w3##w1dxHTN c.timew1w3##w1dxDiabetes c.timew1w3##w1CVhighChol c.timew1w3##w1cvdbr c.timew1w3##c.invmillsmms ///
c.timew1w3##c.zw1w3HCYTRAJ   ///
if sample4kobs==1  & Sex==2 || HNDID: timew1w3, cov(un)


save, replace


*******************************TABLE 3: HOMOCYSTEINE TRAJECTORY VS. COGNITIVE CHANGE OVER TIME: INTERACTION BY SEX**************************************


//MODEL 1: INCLUDE ONLY AGE, SEX, RACE AND POVERTY STATUS///
mi estimate: mixed MMStot  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat  c.timew1w3##c.invmillsmms ///
c.timew1w3##c.zw1w3HCYTRAJ##Sex   ///
if sample4aobs==1 || HNDID: timew1w3, cov(un)


mi estimate: mixed MMStotnorm  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat  c.timew1w3##c.invmillsmms ///
c.timew1w3##c.zw1w3HCYTRAJ##Sex   ///
if sample4aobs==1 || HNDID: timew1w3, cov(un)



mi estimate: mixed cvltca  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat  c.timew1w3##c.invmillsmms ///
c.timew1w3##c.zw1w3HCYTRAJ##Sex   ///
if sample4bobs==1 || HNDID: timew1w3



mi estimate: mixed CVLfrl  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat  c.timew1w3##c.invmillsmms ///
c.timew1w3##c.zw1w3HCYTRAJ##Sex   ///
if sample4cobs==1 || HNDID: 



mi estimate: mixed BVRtot  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat  c.timew1w3##c.invmillsmms ///
c.timew1w3##c.zw1w3HCYTRAJ##Sex   ///
if sample4dobs==1 || HNDID: timew1w3, cov(un)


mi estimate: mixed Attention  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat  c.timew1w3##c.invmillsmms ///
c.timew1w3##c.zw1w3HCYTRAJ##Sex   ///
if sample4eobs==1 || HNDID: timew1w3, cov(un)

mi estimate: mixed FluencyWord  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat  c.timew1w3##c.invmillsmms ///
c.timew1w3##c.zw1w3HCYTRAJ##Sex   ///
if sample4fobs==1 || HNDID: timew1w3, cov(un)

mi estimate: mixed DigitSpanFwd  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat  c.timew1w3##c.invmillsmms ///
c.timew1w3##c.zw1w3HCYTRAJ##Sex   ///
if sample4gobs==1 || HNDID: timew1w3, cov(un)

mi estimate: mixed DigitSpanBck  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat  c.timew1w3##c.invmillsmms ///
c.timew1w3##c.zw1w3HCYTRAJ##Sex   ///
if sample4hobs==1 || HNDID: timew1w3, cov(un)

mi estimate: mixed clock_command  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat  c.timew1w3##c.invmillsmms ///
c.timew1w3##c.zw1w3HCYTRAJ##Sex   ///
if sample4iobs==1 || HNDID: timew1w3, cov(un)

mi estimate: mixed LnTrailsAtestSec  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat  c.timew1w3##c.invmillsmms ///
c.timew1w3##c.zw1w3HCYTRAJ##Sex   ///
if sample4jobs==1 || HNDID: timew1w3

mi estimate: mixed LnTrailsBtestSec  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat  c.timew1w3##c.invmillsmms ///
c.timew1w3##c.zw1w3HCYTRAJ##Sex   ///
if sample4kobs==1  || HNDID: timew1w3, cov(un)


save, replace


//MODEL 2: MODEL 1 + OTHER FACTORS + BODY MASS INDEX///

mi estimate: mixed MMStot  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat c.timew1w3##w1edubr c.timew1w3##c.w1WRATtotalcent42   ///
c.timew1w3##w1smoke  c.timew1w3##w1currdrugs c.timew1w3##c.w1hei2010_total_scorecent43  c.timew1w3##c.w1BMIcent30  c.timew1w3##c.invmillsmms ///
c.timew1w3##c.zw1w3HCYTRAJ##Sex   ///
if sample4aobs==1 || HNDID: timew1w3, cov(un)


mi estimate: mixed MMStotnorm  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat c.timew1w3##w1edubr c.timew1w3##c.w1WRATtotalcent42   ///
c.timew1w3##w1smoke  c.timew1w3##w1currdrugs c.timew1w3##c.w1hei2010_total_scorecent43  c.timew1w3##c.w1BMIcent30  c.timew1w3##c.invmillsmms ///
c.timew1w3##c.zw1w3HCYTRAJ##Sex   ///
if sample4aobs==1 || HNDID: timew1w3, cov(un)



mi estimate: mixed cvltca  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat c.timew1w3##w1edubr c.timew1w3##c.w1WRATtotalcent42   ///
c.timew1w3##w1smoke  c.timew1w3##w1currdrugs c.timew1w3##c.w1hei2010_total_scorecent43  c.timew1w3##c.w1BMIcent30  c.timew1w3##c.invmillsmms ///
c.timew1w3##c.zw1w3HCYTRAJ##Sex   ///
if sample4bobs==1 || HNDID: timew1w3



mi estimate: mixed CVLfrl  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat c.timew1w3##w1edubr c.timew1w3##c.w1WRATtotalcent42   ///
c.timew1w3##w1smoke  c.timew1w3##w1currdrugs c.timew1w3##c.w1hei2010_total_scorecent43  c.timew1w3##c.w1BMIcent30  c.timew1w3##c.invmillsmms ///
c.timew1w3##c.zw1w3HCYTRAJ##Sex   ///
if sample4cobs==1 || HNDID: timew1w3



mi estimate: mixed BVRtot  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat c.timew1w3##w1edubr c.timew1w3##c.w1WRATtotalcent42   ///
c.timew1w3##w1smoke  c.timew1w3##w1currdrugs c.timew1w3##c.w1hei2010_total_scorecent43  c.timew1w3##c.w1BMIcent30  c.timew1w3##c.invmillsmms ///
c.timew1w3##c.zw1w3HCYTRAJ##Sex   ///
if sample4dobs==1 || HNDID: timew1w3, cov(un)


mi estimate: mixed Attention  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat c.timew1w3##w1edubr c.timew1w3##c.w1WRATtotalcent42   ///
c.timew1w3##w1smoke  c.timew1w3##w1currdrugs c.timew1w3##c.w1hei2010_total_scorecent43  c.timew1w3##c.w1BMIcent30  c.timew1w3##c.invmillsmms ///
c.timew1w3##c.zw1w3HCYTRAJ##Sex   ///
if sample4eobs==1 || HNDID: timew1w3, cov(un)

mi estimate: mixed FluencyWord  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat c.timew1w3##w1edubr c.timew1w3##c.w1WRATtotalcent42   ///
c.timew1w3##w1smoke  c.timew1w3##w1currdrugs c.timew1w3##c.w1hei2010_total_scorecent43  c.timew1w3##c.w1BMIcent30  c.timew1w3##c.invmillsmms ///
c.timew1w3##c.zw1w3HCYTRAJ##Sex   ///
if sample4fobs==1 || HNDID: timew1w3, cov(un)

mi estimate: mixed DigitSpanFwd  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat c.timew1w3##w1edubr c.timew1w3##c.w1WRATtotalcent42   ///
c.timew1w3##w1smoke  c.timew1w3##w1currdrugs c.timew1w3##c.w1hei2010_total_scorecent43  c.timew1w3##c.w1BMIcent30  c.timew1w3##c.invmillsmms ///
c.timew1w3##c.zw1w3HCYTRAJ##Sex   ///
if sample4gobs==1 || HNDID: timew1w3, cov(un)

mi estimate: mixed DigitSpanBck  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat c.timew1w3##w1edubr c.timew1w3##c.w1WRATtotalcent42   ///
c.timew1w3##w1smoke  c.timew1w3##w1currdrugs c.timew1w3##c.w1hei2010_total_scorecent43  c.timew1w3##c.w1BMIcent30 c.timew1w3##c.invmillsmms ///
c.timew1w3##c.zw1w3HCYTRAJ##Sex   ///
if sample4hobs==1 || HNDID: timew1w3

mi estimate: mixed clock_command  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat c.timew1w3##w1edubr c.timew1w3##c.w1WRATtotalcent42   ///
c.timew1w3##w1smoke  c.timew1w3##w1currdrugs c.timew1w3##c.w1hei2010_total_scorecent43  c.timew1w3##c.w1BMIcent30  c.timew1w3##c.invmillsmms ///
c.timew1w3##c.zw1w3HCYTRAJ##Sex   ///
if sample4iobs==1 || HNDID: timew1w3, cov(un)

mi estimate: mixed LnTrailsAtestSec  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat c.timew1w3##w1edubr c.timew1w3##c.w1WRATtotalcent42   ///
c.timew1w3##w1smoke  c.timew1w3##w1currdrugs c.timew1w3##c.w1hei2010_total_scorecent43  c.timew1w3##c.w1BMIcent30  c.timew1w3##c.invmillsmms ///
c.timew1w3##c.zw1w3HCYTRAJ##Sex   ///
if sample4jobs==1 || HNDID: timew1w3

mi estimate: mixed LnTrailsBtestSec  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat c.timew1w3##w1edubr c.timew1w3##c.w1WRATtotalcent42   ///
c.timew1w3##w1smoke  c.timew1w3##w1currdrugs c.timew1w3##c.w1hei2010_total_scorecent43  c.timew1w3##c.w1BMIcent30  c.timew1w3##c.invmillsmms ///
c.timew1w3##c.zw1w3HCYTRAJ##Sex   ///
if sample4kobs==1  || HNDID: timew1w3, cov(un)


save, replace


//MODEL 3: FULLY ADJUSTED MODEL: MODEL 2 + HEALTH-RELATED FACTORS///

mi estimate: mixed MMStot  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat c.timew1w3##w1edubr c.timew1w3##c.w1WRATtotalcent42   ///
c.timew1w3##w1smoke  c.timew1w3##w1currdrugs c.timew1w3##c.w1hei2010_total_scorecent43  c.timew1w3##c.w1BMIcent30 c.timew1w3##w1SRH c.timew1w3##c.w1CEScent15 c.timew1w3##w1dxHTN c.timew1w3##w1dxDiabetes c.timew1w3##w1CVhighChol c.timew1w3##w1cvdbr c.timew1w3##c.invmillsmms ///
c.timew1w3##c.zw1w3HCYTRAJ##Sex   ///
if sample4aobs==1 || HNDID: timew1w3


mi estimate: mixed MMStotnorm  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat c.timew1w3##w1edubr c.timew1w3##c.w1WRATtotalcent42   ///
c.timew1w3##w1smoke  c.timew1w3##w1currdrugs c.timew1w3##c.w1hei2010_total_scorecent43  c.timew1w3##c.w1BMIcent30 c.timew1w3##w1SRH c.timew1w3##c.w1CEScent15 c.timew1w3##w1dxHTN c.timew1w3##w1dxDiabetes c.timew1w3##w1CVhighChol c.timew1w3##w1cvdbr c.timew1w3##c.invmillsmms ///
c.timew1w3##c.zw1w3HCYTRAJ##Sex   ///
if sample4aobs==1 || HNDID: timew1w3, cov(un)



mi estimate: mixed cvltca  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat c.timew1w3##w1edubr c.timew1w3##c.w1WRATtotalcent42   ///
c.timew1w3##w1smoke  c.timew1w3##w1currdrugs c.timew1w3##c.w1hei2010_total_scorecent43  c.timew1w3##c.w1BMIcent30 c.timew1w3##w1SRH c.timew1w3##c.w1CEScent15 c.timew1w3##w1dxHTN c.timew1w3##w1dxDiabetes c.timew1w3##w1CVhighChol c.timew1w3##w1cvdbr c.timew1w3##c.invmillsmms ///
c.timew1w3##c.zw1w3HCYTRAJ##Sex   ///
if sample4bobs==1 || HNDID: timew1w3



mi estimate: mixed CVLfrl  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat c.timew1w3##w1edubr c.timew1w3##c.w1WRATtotalcent42   ///
c.timew1w3##w1smoke  c.timew1w3##w1currdrugs c.timew1w3##c.w1hei2010_total_scorecent43  c.timew1w3##c.w1BMIcent30 c.timew1w3##w1SRH c.timew1w3##c.w1CEScent15 c.timew1w3##w1dxHTN c.timew1w3##w1dxDiabetes c.timew1w3##w1CVhighChol c.timew1w3##w1cvdbr c.timew1w3##c.invmillsmms ///
c.timew1w3##c.zw1w3HCYTRAJ##Sex   ///
if sample4cobs==1 || HNDID: timew1w3



mi estimate: mixed BVRtot  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat c.timew1w3##w1edubr c.timew1w3##c.w1WRATtotalcent42   ///
c.timew1w3##w1smoke  c.timew1w3##w1currdrugs c.timew1w3##c.w1hei2010_total_scorecent43  c.timew1w3##c.w1BMIcent30 c.timew1w3##w1SRH c.timew1w3##c.w1CEScent15 c.timew1w3##w1dxHTN c.timew1w3##w1dxDiabetes c.timew1w3##w1CVhighChol c.timew1w3##w1cvdbr c.timew1w3##c.invmillsmms ///
c.timew1w3##c.zw1w3HCYTRAJ##Sex   ///
if sample4dobs==1 || HNDID: timew1w3, cov(un)


mi estimate: mixed Attention  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat c.timew1w3##w1edubr c.timew1w3##c.w1WRATtotalcent42   ///
c.timew1w3##w1smoke  c.timew1w3##w1currdrugs c.timew1w3##c.w1hei2010_total_scorecent43  c.timew1w3##c.w1BMIcent30 c.timew1w3##w1SRH c.timew1w3##c.w1CEScent15 c.timew1w3##w1dxHTN c.timew1w3##w1dxDiabetes c.timew1w3##w1CVhighChol c.timew1w3##w1cvdbr c.timew1w3##c.invmillsmms ///
c.timew1w3##c.zw1w3HCYTRAJ##Sex   ///
if sample4eobs==1 || HNDID: timew1w3, cov(un)

mi estimate: mixed FluencyWord  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat c.timew1w3##w1edubr c.timew1w3##c.w1WRATtotalcent42   ///
c.timew1w3##w1smoke  c.timew1w3##w1currdrugs c.timew1w3##c.w1hei2010_total_scorecent43  c.timew1w3##c.w1BMIcent30 c.timew1w3##w1SRH c.timew1w3##c.w1CEScent15 c.timew1w3##w1dxHTN c.timew1w3##w1dxDiabetes c.timew1w3##w1CVhighChol c.timew1w3##w1cvdbr c.timew1w3##c.invmillsmms ///
c.timew1w3##c.zw1w3HCYTRAJ##Sex   ///
if sample4fobs==1 || HNDID: timew1w3, cov(un)

mi estimate: mixed DigitSpanFwd  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat c.timew1w3##w1edubr c.timew1w3##c.w1WRATtotalcent42   ///
c.timew1w3##w1smoke  c.timew1w3##w1currdrugs c.timew1w3##c.w1hei2010_total_scorecent43  c.timew1w3##c.w1BMIcent30 c.timew1w3##w1SRH c.timew1w3##c.w1CEScent15 c.timew1w3##w1dxHTN c.timew1w3##w1dxDiabetes c.timew1w3##w1CVhighChol c.timew1w3##w1cvdbr c.timew1w3##c.invmillsmms ///
c.timew1w3##c.zw1w3HCYTRAJ##Sex   ///
if sample4gobs==1 || HNDID: timew1w3, cov(un)

mi estimate: mixed DigitSpanBck  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat c.timew1w3##w1edubr c.timew1w3##c.w1WRATtotalcent42   ///
c.timew1w3##w1smoke  c.timew1w3##w1currdrugs c.timew1w3##c.w1hei2010_total_scorecent43  c.timew1w3##c.w1BMIcent30 c.timew1w3##w1SRH c.timew1w3##c.w1CEScent15 c.timew1w3##w1dxHTN c.timew1w3##w1dxDiabetes c.timew1w3##w1CVhighChol c.timew1w3##w1cvdbr c.timew1w3##c.invmillsmms ///
c.timew1w3##c.zw1w3HCYTRAJ##Sex   ///
if sample4hobs==1 || HNDID: timew1w3, cov(un)

mi estimate: mixed clock_command  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat c.timew1w3##w1edubr c.timew1w3##c.w1WRATtotalcent42   ///
c.timew1w3##w1smoke  c.timew1w3##w1currdrugs c.timew1w3##c.w1hei2010_total_scorecent43  c.timew1w3##c.w1BMIcent30 c.timew1w3##w1SRH c.timew1w3##c.w1CEScent15 c.timew1w3##w1dxHTN c.timew1w3##w1dxDiabetes c.timew1w3##w1CVhighChol c.timew1w3##w1cvdbr c.timew1w3##c.invmillsmms ///
c.timew1w3##c.zw1w3HCYTRAJ##Sex   ///
if sample4iobs==1 || HNDID: timew1w3, cov(un)

mi estimate: mixed LnTrailsAtestSec  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat c.timew1w3##w1edubr c.timew1w3##c.w1WRATtotalcent42   ///
c.timew1w3##w1smoke  c.timew1w3##w1currdrugs c.timew1w3##c.w1hei2010_total_scorecent43  c.timew1w3##c.w1BMIcent30 c.timew1w3##w1SRH c.timew1w3##c.w1CEScent15 c.timew1w3##w1dxHTN c.timew1w3##w1dxDiabetes c.timew1w3##w1CVhighChol c.timew1w3##w1cvdbr c.timew1w3##c.invmillsmms ///
c.timew1w3##c.zw1w3HCYTRAJ##Sex   ///
if sample4jobs==1 || HNDID: timew1w3

mi estimate: mixed LnTrailsBtestSec  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat c.timew1w3##w1edubr c.timew1w3##c.w1WRATtotalcent42   ///
c.timew1w3##w1smoke  c.timew1w3##w1currdrugs c.timew1w3##c.w1hei2010_total_scorecent43  c.timew1w3##c.w1BMIcent30 c.timew1w3##w1SRH c.timew1w3##c.w1CEScent15 c.timew1w3##w1dxHTN c.timew1w3##w1dxDiabetes c.timew1w3##w1CVhighChol c.timew1w3##w1cvdbr c.timew1w3##c.invmillsmms ///
c.timew1w3##c.zw1w3HCYTRAJ##Sex   ///
if sample4kobs==1  || HNDID: timew1w3, cov(un)


save, replace


*******************************TABLE 3: HOMOCYSTEINE TRAJECTORY VS. COGNITIVE CHANGE OVER TIME: WHITE**************************************



//MODEL 1: INCLUDE ONLY AGE, SEX, RACE AND POVERTY STATUS///
mi estimate: mixed MMStot  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat  c.timew1w3##c.invmillsmms ///
c.timew1w3##c.zw1w3HCYTRAJ   ///
if sample4aobs==1 & Race==1 || HNDID: timew1w3, cov(un)


mi estimate: mixed MMStotnorm  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat  c.timew1w3##c.invmillsmms ///
c.timew1w3##c.zw1w3HCYTRAJ   ///
if sample4aobs==1 & Race==1 || HNDID: timew1w3, cov(un)



mi estimate: mixed cvltca  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat  c.timew1w3##c.invmillsmms ///
c.timew1w3##c.zw1w3HCYTRAJ   ///
if sample4bobs==1 & Race==1 || HNDID: timew1w3



mi estimate: mixed CVLfrl  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat  c.timew1w3##c.invmillsmms ///
c.timew1w3##c.zw1w3HCYTRAJ   ///
if sample4cobs==1 & Race==1 || HNDID: timew1w3



mi estimate: mixed BVRtot  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat  c.timew1w3##c.invmillsmms ///
c.timew1w3##c.zw1w3HCYTRAJ   ///
if sample4dobs==1 & Race==1 || HNDID: timew1w3, cov(un)


mi estimate: mixed Attention  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat  c.timew1w3##c.invmillsmms ///
c.timew1w3##c.zw1w3HCYTRAJ   ///
if sample4eobs==1 & Race==1 || HNDID: timew1w3, cov(un)

mi estimate: mixed FluencyWord  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat  c.timew1w3##c.invmillsmms ///
c.timew1w3##c.zw1w3HCYTRAJ   ///
if sample4fobs==1 & Race==1 || HNDID: timew1w3, cov(un)

mi estimate: mixed DigitSpanFwd  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat  c.timew1w3##c.invmillsmms ///
c.timew1w3##c.zw1w3HCYTRAJ   ///
if sample4gobs==1 & Race==1 || HNDID: timew1w3, cov(un)

mi estimate: mixed DigitSpanBck  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat  c.timew1w3##c.invmillsmms ///
c.timew1w3##c.zw1w3HCYTRAJ   ///
if sample4hobs==1 & Race==1 || HNDID: timew1w3, cov(un)

mi estimate: mixed clock_command  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat  c.timew1w3##c.invmillsmms ///
c.timew1w3##c.zw1w3HCYTRAJ   ///
if sample4iobs==1 & Race==1 || HNDID: timew1w3, cov(un)

mi estimate: mixed LnTrailsAtestSec  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat  c.timew1w3##c.invmillsmms ///
c.timew1w3##c.zw1w3HCYTRAJ   ///
if sample4jobs==1 & Race==1 || HNDID: timew1w3

mi estimate: mixed LnTrailsBtestSec  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat  c.timew1w3##c.invmillsmms ///
c.timew1w3##c.zw1w3HCYTRAJ   ///
if sample4kobs==1  & Race==1 || HNDID: timew1w3, cov(un)


save, replace


//MODEL 2: MODEL 1 + OTHER FACTORS + BODY MASS INDEX///

mi estimate: mixed MMStot  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat c.timew1w3##w1edubr c.timew1w3##c.w1WRATtotalcent42   ///
c.timew1w3##w1smoke  c.timew1w3##w1currdrugs c.timew1w3##c.w1hei2010_total_scorecent43  c.timew1w3##c.w1BMIcent30  c.timew1w3##c.invmillsmms ///
c.timew1w3##c.zw1w3HCYTRAJ   ///
if sample4aobs==1 & Race==1 || HNDID: timew1w3, cov(un)


mi estimate: mixed MMStotnorm  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat c.timew1w3##w1edubr c.timew1w3##c.w1WRATtotalcent42   ///
c.timew1w3##w1smoke  c.timew1w3##w1currdrugs c.timew1w3##c.w1hei2010_total_scorecent43  c.timew1w3##c.w1BMIcent30  c.timew1w3##c.invmillsmms ///
c.timew1w3##c.zw1w3HCYTRAJ   ///
if sample4aobs==1 & Race==1 || HNDID: timew1w3, cov(un)



mi estimate: mixed cvltca  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat c.timew1w3##w1edubr c.timew1w3##c.w1WRATtotalcent42   ///
c.timew1w3##w1smoke  c.timew1w3##w1currdrugs c.timew1w3##c.w1hei2010_total_scorecent43  c.timew1w3##c.w1BMIcent30  c.timew1w3##c.invmillsmms ///
c.timew1w3##c.zw1w3HCYTRAJ   ///
if sample4bobs==1 & Race==1 || HNDID: timew1w3



mi estimate: mixed CVLfrl  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat c.timew1w3##w1edubr c.timew1w3##c.w1WRATtotalcent42   ///
c.timew1w3##w1smoke  c.timew1w3##w1currdrugs c.timew1w3##c.w1hei2010_total_scorecent43  c.timew1w3##c.w1BMIcent30  c.timew1w3##c.invmillsmms ///
c.timew1w3##c.zw1w3HCYTRAJ   ///
if sample4cobs==1 & Race==1 || HNDID: timew1w3



mi estimate: mixed BVRtot  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat c.timew1w3##w1edubr c.timew1w3##c.w1WRATtotalcent42   ///
c.timew1w3##w1smoke  c.timew1w3##w1currdrugs c.timew1w3##c.w1hei2010_total_scorecent43  c.timew1w3##c.w1BMIcent30  c.timew1w3##c.invmillsmms ///
c.timew1w3##c.zw1w3HCYTRAJ   ///
if sample4dobs==1 & Race==1 || HNDID: timew1w3, cov(un)


mi estimate: mixed Attention  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat c.timew1w3##w1edubr c.timew1w3##c.w1WRATtotalcent42   ///
c.timew1w3##w1smoke  c.timew1w3##w1currdrugs c.timew1w3##c.w1hei2010_total_scorecent43  c.timew1w3##c.w1BMIcent30  c.timew1w3##c.invmillsmms ///
c.timew1w3##c.zw1w3HCYTRAJ   ///
if sample4eobs==1 & Race==1 || HNDID: timew1w3, cov(un)

mi estimate: mixed FluencyWord  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat c.timew1w3##w1edubr c.timew1w3##c.w1WRATtotalcent42   ///
c.timew1w3##w1smoke  c.timew1w3##w1currdrugs c.timew1w3##c.w1hei2010_total_scorecent43  c.timew1w3##c.w1BMIcent30  c.timew1w3##c.invmillsmms ///
c.timew1w3##c.zw1w3HCYTRAJ   ///
if sample4fobs==1 & Race==1 || HNDID: timew1w3, cov(un)

mi estimate: mixed DigitSpanFwd  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat c.timew1w3##w1edubr c.timew1w3##c.w1WRATtotalcent42   ///
c.timew1w3##w1smoke  c.timew1w3##w1currdrugs c.timew1w3##c.w1hei2010_total_scorecent43  c.timew1w3##c.w1BMIcent30  c.timew1w3##c.invmillsmms ///
c.timew1w3##c.zw1w3HCYTRAJ   ///
if sample4gobs==1 & Race==1 || HNDID: timew1w3, cov(un)

mi estimate: mixed DigitSpanBck  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat c.timew1w3##w1edubr c.timew1w3##c.w1WRATtotalcent42   ///
c.timew1w3##w1smoke  c.timew1w3##w1currdrugs c.timew1w3##c.w1hei2010_total_scorecent43  c.timew1w3##c.w1BMIcent30 c.timew1w3##c.invmillsmms ///
c.timew1w3##c.zw1w3HCYTRAJ   ///
if sample4hobs==1 & Race==1 || HNDID: timew1w3, cov(un)

mi estimate: mixed clock_command  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat c.timew1w3##w1edubr c.timew1w3##c.w1WRATtotalcent42   ///
c.timew1w3##w1smoke  c.timew1w3##w1currdrugs c.timew1w3##c.w1hei2010_total_scorecent43  c.timew1w3##c.w1BMIcent30  c.timew1w3##c.invmillsmms ///
c.timew1w3##c.zw1w3HCYTRAJ   ///
if sample4iobs==1 & Race==1 || HNDID: timew1w3

mi estimate: mixed LnTrailsAtestSec  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat c.timew1w3##w1edubr c.timew1w3##c.w1WRATtotalcent42   ///
c.timew1w3##w1smoke  c.timew1w3##w1currdrugs c.timew1w3##c.w1hei2010_total_scorecent43  c.timew1w3##c.w1BMIcent30  c.timew1w3##c.invmillsmms ///
c.timew1w3##c.zw1w3HCYTRAJ   ///
if sample4jobs==1 & Race==1 || HNDID: timew1w3

mi estimate: mixed LnTrailsBtestSec  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat c.timew1w3##w1edubr c.timew1w3##c.w1WRATtotalcent42   ///
c.timew1w3##w1smoke  c.timew1w3##w1currdrugs c.timew1w3##c.w1hei2010_total_scorecent43  c.timew1w3##c.w1BMIcent30  c.timew1w3##c.invmillsmms ///
c.timew1w3##c.zw1w3HCYTRAJ   ///
if sample4kobs==1  & Race==1 || HNDID: timew1w3, cov(un)


save, replace


//MODEL 3: FULLY ADJUSTED MODEL: MODEL 2 + HEALTH-RELATED FACTORS///

mi estimate: mixed MMStot  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat c.timew1w3##w1edubr c.timew1w3##c.w1WRATtotalcent42   ///
c.timew1w3##w1smoke  c.timew1w3##w1currdrugs c.timew1w3##c.w1hei2010_total_scorecent43  c.timew1w3##c.w1BMIcent30 c.timew1w3##w1SRH c.timew1w3##c.w1CEScent15 c.timew1w3##w1dxHTN c.timew1w3##w1dxDiabetes c.timew1w3##w1CVhighChol c.timew1w3##w1cvdbr c.timew1w3##c.invmillsmms ///
c.timew1w3##c.zw1w3HCYTRAJ   ///
if sample4aobs==1 & Race==1 || HNDID: timew1w3, cov(un)


mi estimate: mixed MMStotnorm  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat c.timew1w3##w1edubr c.timew1w3##c.w1WRATtotalcent42   ///
c.timew1w3##w1smoke  c.timew1w3##w1currdrugs c.timew1w3##c.w1hei2010_total_scorecent43  c.timew1w3##c.w1BMIcent30 c.timew1w3##w1SRH c.timew1w3##c.w1CEScent15 c.timew1w3##w1dxHTN c.timew1w3##w1dxDiabetes c.timew1w3##w1CVhighChol c.timew1w3##w1cvdbr c.timew1w3##c.invmillsmms ///
c.timew1w3##c.zw1w3HCYTRAJ   ///
if sample4aobs==1 & Race==1 || HNDID: timew1w3, cov(un)



mi estimate: mixed cvltca  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat c.timew1w3##w1edubr c.timew1w3##c.w1WRATtotalcent42   ///
c.timew1w3##w1smoke  c.timew1w3##w1currdrugs c.timew1w3##c.w1hei2010_total_scorecent43  c.timew1w3##c.w1BMIcent30 c.timew1w3##w1SRH c.timew1w3##c.w1CEScent15 c.timew1w3##w1dxHTN c.timew1w3##w1dxDiabetes c.timew1w3##w1CVhighChol c.timew1w3##w1cvdbr c.timew1w3##c.invmillsmms ///
c.timew1w3##c.zw1w3HCYTRAJ   ///
if sample4bobs==1 & Race==1 || HNDID: timew1w3



mi estimate: mixed CVLfrl  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat c.timew1w3##w1edubr c.timew1w3##c.w1WRATtotalcent42   ///
c.timew1w3##w1smoke  c.timew1w3##w1currdrugs c.timew1w3##c.w1hei2010_total_scorecent43  c.timew1w3##c.w1BMIcent30 c.timew1w3##w1SRH c.timew1w3##c.w1CEScent15 c.timew1w3##w1dxHTN c.timew1w3##w1dxDiabetes c.timew1w3##w1CVhighChol c.timew1w3##w1cvdbr c.timew1w3##c.invmillsmms ///
c.timew1w3##c.zw1w3HCYTRAJ   ///
if sample4cobs==1 & Race==1 || HNDID: timew1w3



mi estimate: mixed BVRtot  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat c.timew1w3##w1edubr c.timew1w3##c.w1WRATtotalcent42   ///
c.timew1w3##w1smoke  c.timew1w3##w1currdrugs c.timew1w3##c.w1hei2010_total_scorecent43  c.timew1w3##c.w1BMIcent30 c.timew1w3##w1SRH c.timew1w3##c.w1CEScent15 c.timew1w3##w1dxHTN c.timew1w3##w1dxDiabetes c.timew1w3##w1CVhighChol c.timew1w3##w1cvdbr c.timew1w3##c.invmillsmms ///
c.timew1w3##c.zw1w3HCYTRAJ   ///
if sample4dobs==1 & Race==1 || HNDID: timew1w3, cov(un)


mi estimate: mixed Attention  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat c.timew1w3##w1edubr c.timew1w3##c.w1WRATtotalcent42   ///
c.timew1w3##w1smoke  c.timew1w3##w1currdrugs c.timew1w3##c.w1hei2010_total_scorecent43  c.timew1w3##c.w1BMIcent30 c.timew1w3##w1SRH c.timew1w3##c.w1CEScent15 c.timew1w3##w1dxHTN c.timew1w3##w1dxDiabetes c.timew1w3##w1CVhighChol c.timew1w3##w1cvdbr c.timew1w3##c.invmillsmms ///
c.timew1w3##c.zw1w3HCYTRAJ   ///
if sample4eobs==1 & Race==1 || HNDID: timew1w3, cov(un)

mi estimate: mixed FluencyWord  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat c.timew1w3##w1edubr c.timew1w3##c.w1WRATtotalcent42   ///
c.timew1w3##w1smoke  c.timew1w3##w1currdrugs c.timew1w3##c.w1hei2010_total_scorecent43  c.timew1w3##c.w1BMIcent30 c.timew1w3##w1SRH c.timew1w3##c.w1CEScent15 c.timew1w3##w1dxHTN c.timew1w3##w1dxDiabetes c.timew1w3##w1CVhighChol c.timew1w3##w1cvdbr c.timew1w3##c.invmillsmms ///
c.timew1w3##c.zw1w3HCYTRAJ   ///
if sample4fobs==1 & Race==1 || HNDID: timew1w3, cov(un)

mi estimate: mixed DigitSpanFwd  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat c.timew1w3##w1edubr c.timew1w3##c.w1WRATtotalcent42   ///
c.timew1w3##w1smoke  c.timew1w3##w1currdrugs c.timew1w3##c.w1hei2010_total_scorecent43  c.timew1w3##c.w1BMIcent30 c.timew1w3##w1SRH c.timew1w3##c.w1CEScent15 c.timew1w3##w1dxHTN c.timew1w3##w1dxDiabetes c.timew1w3##w1CVhighChol c.timew1w3##w1cvdbr c.timew1w3##c.invmillsmms ///
c.timew1w3##c.zw1w3HCYTRAJ   ///
if sample4gobs==1 & Race==1 || HNDID: timew1w3, cov(un)

mi estimate: mixed DigitSpanBck  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat c.timew1w3##w1edubr c.timew1w3##c.w1WRATtotalcent42   ///
c.timew1w3##w1smoke  c.timew1w3##w1currdrugs c.timew1w3##c.w1hei2010_total_scorecent43  c.timew1w3##c.w1BMIcent30 c.timew1w3##w1SRH c.timew1w3##c.w1CEScent15 c.timew1w3##w1dxHTN c.timew1w3##w1dxDiabetes c.timew1w3##w1CVhighChol c.timew1w3##w1cvdbr c.timew1w3##c.invmillsmms ///
c.timew1w3##c.zw1w3HCYTRAJ   ///
if sample4hobs==1 & Race==1 || HNDID: timew1w3, cov(un)

mi estimate: mixed clock_command  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat c.timew1w3##w1edubr c.timew1w3##c.w1WRATtotalcent42   ///
c.timew1w3##w1smoke  c.timew1w3##w1currdrugs c.timew1w3##c.w1hei2010_total_scorecent43  c.timew1w3##c.w1BMIcent30 c.timew1w3##w1SRH c.timew1w3##c.w1CEScent15 c.timew1w3##w1dxHTN c.timew1w3##w1dxDiabetes c.timew1w3##w1CVhighChol c.timew1w3##w1cvdbr c.timew1w3##c.invmillsmms ///
c.timew1w3##c.zw1w3HCYTRAJ   ///
if sample4iobs==1 & Race==1 || HNDID: timew1w3, cov(un)

mi estimate: mixed LnTrailsAtestSec  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat c.timew1w3##w1edubr c.timew1w3##c.w1WRATtotalcent42   ///
c.timew1w3##w1smoke  c.timew1w3##w1currdrugs c.timew1w3##c.w1hei2010_total_scorecent43  c.timew1w3##c.w1BMIcent30 c.timew1w3##w1SRH c.timew1w3##c.w1CEScent15 c.timew1w3##w1dxHTN c.timew1w3##w1dxDiabetes c.timew1w3##w1CVhighChol c.timew1w3##w1cvdbr c.timew1w3##c.invmillsmms ///
c.timew1w3##c.zw1w3HCYTRAJ   ///
if sample4jobs==1 & Race==1 || HNDID: timew1w3

mi estimate: mixed LnTrailsBtestSec  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat c.timew1w3##w1edubr c.timew1w3##c.w1WRATtotalcent42   ///
c.timew1w3##w1smoke  c.timew1w3##w1currdrugs c.timew1w3##c.w1hei2010_total_scorecent43  c.timew1w3##c.w1BMIcent30 c.timew1w3##w1SRH c.timew1w3##c.w1CEScent15 c.timew1w3##w1dxHTN c.timew1w3##w1dxDiabetes c.timew1w3##w1CVhighChol c.timew1w3##w1cvdbr c.timew1w3##c.invmillsmms ///
c.timew1w3##c.zw1w3HCYTRAJ   ///
if sample4kobs==1  & Race==1 || HNDID: timew1w3, cov(un)


save, replace



*******************************TABLE 3: HOMOCYSTEINE TRAJ  VS. COGNITIVE CHANGE OVER TIME: AA**************************************


//MODEL 1: INCLUDE ONLY AGE, SEX, RACE AND POVERTY STATUS///
mi estimate: mixed MMStot  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat  c.timew1w3##c.invmillsmms ///
c.timew1w3##c.zw1w3HCYTRAJ   ///
if sample4aobs==1 & Race==2 || HNDID: timew1w3, cov(un)


mi estimate: mixed MMStotnorm  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat  c.timew1w3##c.invmillsmms ///
c.timew1w3##c.zw1w3HCYTRAJ   ///
if sample4aobs==1 & Race==2 || HNDID: timew1w3, cov(un)



mi estimate: mixed cvltca  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat  c.timew1w3##c.invmillsmms ///
c.timew1w3##c.zw1w3HCYTRAJ   ///
if sample4bobs==1 & Race==2 || HNDID: timew1w3



mi estimate: mixed CVLfrl  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat  c.timew1w3##c.invmillsmms ///
c.timew1w3##c.zw1w3HCYTRAJ   ///
if sample4cobs==1 & Race==2 || HNDID: timew1w3



mi estimate: mixed BVRtot  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat  c.timew1w3##c.invmillsmms ///
c.timew1w3##c.zw1w3HCYTRAJ   ///
if sample4dobs==1 & Race==2 || HNDID: timew1w3, cov(un)


mi estimate: mixed Attention  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat  c.timew1w3##c.invmillsmms ///
c.timew1w3##c.zw1w3HCYTRAJ   ///
if sample4eobs==1 & Race==2 || HNDID: timew1w3, cov(un)

mi estimate: mixed FluencyWord  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat  c.timew1w3##c.invmillsmms ///
c.timew1w3##c.zw1w3HCYTRAJ   ///
if sample4fobs==1 & Race==2 || HNDID: timew1w3, cov(un)

mi estimate: mixed DigitSpanFwd  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat  c.timew1w3##c.invmillsmms ///
c.timew1w3##c.zw1w3HCYTRAJ   ///
if sample4gobs==1 & Race==2 || HNDID: timew1w3, cov(un)

mi estimate: mixed DigitSpanBck  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat  c.timew1w3##c.invmillsmms ///
c.timew1w3##c.zw1w3HCYTRAJ   ///
if sample4hobs==1 & Race==2 || HNDID: timew1w3, cov(un)

mi estimate: mixed clock_command  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat  c.timew1w3##c.invmillsmms ///
c.timew1w3##c.zw1w3HCYTRAJ   ///
if sample4iobs==1 & Race==2 || HNDID: timew1w3, cov(un)

mi estimate: mixed LnTrailsAtestSec  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat  c.timew1w3##c.invmillsmms ///
c.timew1w3##c.zw1w3HCYTRAJ   ///
if sample4jobs==1 & Race==2 || HNDID: timew1w3

mi estimate: mixed LnTrailsBtestSec  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat  c.timew1w3##c.invmillsmms ///
c.timew1w3##c.zw1w3HCYTRAJ   ///
if sample4kobs==1  & Race==2 || HNDID: timew1w3, cov(un)


save, replace


//MODEL 2: MODEL 1 + BODY MASS INDEX///

mi estimate: mixed MMStot  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat c.timew1w3##w1edubr c.timew1w3##c.w1WRATtotalcent42   ///
c.timew1w3##w1smoke  c.timew1w3##w1currdrugs c.timew1w3##c.w1hei2010_total_scorecent43  c.timew1w3##c.w1BMIcent30  c.timew1w3##c.invmillsmms ///
c.timew1w3##c.zw1w3HCYTRAJ   ///
if sample4aobs==1 & Race==2 || HNDID: timew1w3, cov(un)


mi estimate: mixed MMStotnorm  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat c.timew1w3##w1edubr c.timew1w3##c.w1WRATtotalcent42   ///
c.timew1w3##w1smoke  c.timew1w3##w1currdrugs c.timew1w3##c.w1hei2010_total_scorecent43  c.timew1w3##c.w1BMIcent30  c.timew1w3##c.invmillsmms ///
c.timew1w3##c.zw1w3HCYTRAJ   ///
if sample4aobs==1 & Race==2 || HNDID: timew1w3, cov(un)



mi estimate: mixed cvltca  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat c.timew1w3##w1edubr c.timew1w3##c.w1WRATtotalcent42   ///
c.timew1w3##w1smoke  c.timew1w3##w1currdrugs c.timew1w3##c.w1hei2010_total_scorecent43  c.timew1w3##c.w1BMIcent30  c.timew1w3##c.invmillsmms ///
c.timew1w3##c.zw1w3HCYTRAJ   ///
if sample4bobs==1 & Race==2 || HNDID: timew1w3



mi estimate: mixed CVLfrl  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat c.timew1w3##w1edubr c.timew1w3##c.w1WRATtotalcent42   ///
c.timew1w3##w1smoke  c.timew1w3##w1currdrugs c.timew1w3##c.w1hei2010_total_scorecent43  c.timew1w3##c.w1BMIcent30  c.timew1w3##c.invmillsmms ///
c.timew1w3##c.zw1w3HCYTRAJ   ///
if sample4cobs==1 & Race==2 || HNDID: timew1w3



mi estimate: mixed BVRtot  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat c.timew1w3##w1edubr c.timew1w3##c.w1WRATtotalcent42   ///
c.timew1w3##w1smoke  c.timew1w3##w1currdrugs c.timew1w3##c.w1hei2010_total_scorecent43  c.timew1w3##c.w1BMIcent30  c.timew1w3##c.invmillsmms ///
c.timew1w3##c.zw1w3HCYTRAJ   ///
if sample4dobs==1 & Race==2 || HNDID: timew1w3


mi estimate: mixed Attention  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat c.timew1w3##w1edubr c.timew1w3##c.w1WRATtotalcent42   ///
c.timew1w3##w1smoke  c.timew1w3##w1currdrugs c.timew1w3##c.w1hei2010_total_scorecent43  c.timew1w3##c.w1BMIcent30  c.timew1w3##c.invmillsmms ///
c.timew1w3##c.zw1w3HCYTRAJ   ///
if sample4eobs==1 & Race==2 || HNDID: timew1w3, cov(un)

mi estimate: mixed FluencyWord  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat c.timew1w3##w1edubr c.timew1w3##c.w1WRATtotalcent42   ///
c.timew1w3##w1smoke  c.timew1w3##w1currdrugs c.timew1w3##c.w1hei2010_total_scorecent43  c.timew1w3##c.w1BMIcent30  c.timew1w3##c.invmillsmms ///
c.timew1w3##c.zw1w3HCYTRAJ   ///
if sample4fobs==1 & Race==2 || HNDID: timew1w3, cov(un)

mi estimate: mixed DigitSpanFwd  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat c.timew1w3##w1edubr c.timew1w3##c.w1WRATtotalcent42   ///
c.timew1w3##w1smoke  c.timew1w3##w1currdrugs c.timew1w3##c.w1hei2010_total_scorecent43  c.timew1w3##c.w1BMIcent30  c.timew1w3##c.invmillsmms ///
c.timew1w3##c.zw1w3HCYTRAJ   ///
if sample4gobs==1 & Race==2 || HNDID: timew1w3

mi estimate: mixed DigitSpanBck  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat c.timew1w3##w1edubr c.timew1w3##c.w1WRATtotalcent42   ///
c.timew1w3##w1smoke  c.timew1w3##w1currdrugs c.timew1w3##c.w1hei2010_total_scorecent43  c.timew1w3##c.w1BMIcent30 c.timew1w3##c.invmillsmms ///
c.timew1w3##c.zw1w3HCYTRAJ   ///
if sample4hobs==1 & Race==2 || HNDID: timew1w3, cov(un)

mi estimate: mixed clock_command  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat c.timew1w3##w1edubr c.timew1w3##c.w1WRATtotalcent42   ///
c.timew1w3##w1smoke  c.timew1w3##w1currdrugs c.timew1w3##c.w1hei2010_total_scorecent43  c.timew1w3##c.w1BMIcent30  c.timew1w3##c.invmillsmms ///
c.timew1w3##c.zw1w3HCYTRAJ   ///
if sample4iobs==1 & Race==2 || HNDID: timew1w3, cov(un)

mi estimate: mixed LnTrailsAtestSec  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat c.timew1w3##w1edubr c.timew1w3##c.w1WRATtotalcent42   ///
c.timew1w3##w1smoke  c.timew1w3##w1currdrugs c.timew1w3##c.w1hei2010_total_scorecent43  c.timew1w3##c.w1BMIcent30  c.timew1w3##c.invmillsmms ///
c.timew1w3##c.zw1w3HCYTRAJ   ///
if sample4jobs==1 & Race==2 || HNDID: timew1w3

mi estimate: mixed LnTrailsBtestSec  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat c.timew1w3##w1edubr c.timew1w3##c.w1WRATtotalcent42   ///
c.timew1w3##w1smoke  c.timew1w3##w1currdrugs c.timew1w3##c.w1hei2010_total_scorecent43  c.timew1w3##c.w1BMIcent30  c.timew1w3##c.invmillsmms ///
c.timew1w3##c.zw1w3HCYTRAJ   ///
if sample4kobs==1  & Race==2 || HNDID: timew1w3, cov(un)


save, replace


//MODEL 3: FULLY ADJUSTED MODEL: MODEL 2 + HEALTH-RELATED FACTORS///

mi estimate: mixed MMStot  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat c.timew1w3##w1edubr c.timew1w3##c.w1WRATtotalcent42   ///
c.timew1w3##w1smoke  c.timew1w3##w1currdrugs c.timew1w3##c.w1hei2010_total_scorecent43  c.timew1w3##c.w1BMIcent30 c.timew1w3##w1SRH c.timew1w3##c.w1CEScent15 c.timew1w3##w1dxHTN c.timew1w3##w1dxDiabetes c.timew1w3##w1CVhighChol c.timew1w3##w1cvdbr c.timew1w3##c.invmillsmms ///
c.timew1w3##c.zw1w3HCYTRAJ   ///
if sample4aobs==1 & Race==2 || HNDID: timew1w3, cov(un)


mi estimate: mixed MMStotnorm  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat c.timew1w3##w1edubr c.timew1w3##c.w1WRATtotalcent42   ///
c.timew1w3##w1smoke  c.timew1w3##w1currdrugs c.timew1w3##c.w1hei2010_total_scorecent43  c.timew1w3##c.w1BMIcent30 c.timew1w3##w1SRH c.timew1w3##c.w1CEScent15 c.timew1w3##w1dxHTN c.timew1w3##w1dxDiabetes c.timew1w3##w1CVhighChol c.timew1w3##w1cvdbr c.timew1w3##c.invmillsmms ///
c.timew1w3##c.zw1w3HCYTRAJ   ///
if sample4aobs==1 & Race==2 || HNDID: timew1w3



mi estimate: mixed cvltca  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat c.timew1w3##w1edubr c.timew1w3##c.w1WRATtotalcent42   ///
c.timew1w3##w1smoke  c.timew1w3##w1currdrugs c.timew1w3##c.w1hei2010_total_scorecent43  c.timew1w3##c.w1BMIcent30 c.timew1w3##w1SRH c.timew1w3##c.w1CEScent15 c.timew1w3##w1dxHTN c.timew1w3##w1dxDiabetes c.timew1w3##w1CVhighChol c.timew1w3##w1cvdbr c.timew1w3##c.invmillsmms ///
c.timew1w3##c.zw1w3HCYTRAJ   ///
if sample4bobs==1 & Race==2 || HNDID: timew1w3



mi estimate: mixed CVLfrl  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat c.timew1w3##w1edubr c.timew1w3##c.w1WRATtotalcent42   ///
c.timew1w3##w1smoke  c.timew1w3##w1currdrugs c.timew1w3##c.w1hei2010_total_scorecent43  c.timew1w3##c.w1BMIcent30 c.timew1w3##w1SRH c.timew1w3##c.w1CEScent15 c.timew1w3##w1dxHTN c.timew1w3##w1dxDiabetes c.timew1w3##w1CVhighChol c.timew1w3##w1cvdbr c.timew1w3##c.invmillsmms ///
c.timew1w3##c.zw1w3HCYTRAJ   ///
if sample4cobs==1 & Race==2 || HNDID: timew1w3



mi estimate: mixed BVRtot  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat c.timew1w3##w1edubr c.timew1w3##c.w1WRATtotalcent42   ///
c.timew1w3##w1smoke  c.timew1w3##w1currdrugs c.timew1w3##c.w1hei2010_total_scorecent43  c.timew1w3##c.w1BMIcent30 c.timew1w3##w1SRH c.timew1w3##c.w1CEScent15 c.timew1w3##w1dxHTN c.timew1w3##w1dxDiabetes c.timew1w3##w1CVhighChol c.timew1w3##w1cvdbr c.timew1w3##c.invmillsmms ///
c.timew1w3##c.zw1w3HCYTRAJ   ///
if sample4dobs==1 & Race==2 || HNDID: timew1w3, cov(un)


mi estimate: mixed Attention  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat c.timew1w3##w1edubr c.timew1w3##c.w1WRATtotalcent42   ///
c.timew1w3##w1smoke  c.timew1w3##w1currdrugs c.timew1w3##c.w1hei2010_total_scorecent43  c.timew1w3##c.w1BMIcent30 c.timew1w3##w1SRH c.timew1w3##c.w1CEScent15 c.timew1w3##w1dxHTN c.timew1w3##w1dxDiabetes c.timew1w3##w1CVhighChol c.timew1w3##w1cvdbr c.timew1w3##c.invmillsmms ///
c.timew1w3##c.zw1w3HCYTRAJ   ///
if sample4eobs==1 & Race==2 || HNDID: timew1w3, cov(un)

mi estimate: mixed FluencyWord  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat c.timew1w3##w1edubr c.timew1w3##c.w1WRATtotalcent42   ///
c.timew1w3##w1smoke  c.timew1w3##w1currdrugs c.timew1w3##c.w1hei2010_total_scorecent43  c.timew1w3##c.w1BMIcent30 c.timew1w3##w1SRH c.timew1w3##c.w1CEScent15 c.timew1w3##w1dxHTN c.timew1w3##w1dxDiabetes c.timew1w3##w1CVhighChol c.timew1w3##w1cvdbr c.timew1w3##c.invmillsmms ///
c.timew1w3##c.zw1w3HCYTRAJ   ///
if sample4fobs==1 & Race==2 || HNDID: timew1w3, cov(un)

mi estimate: mixed DigitSpanFwd  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat c.timew1w3##w1edubr c.timew1w3##c.w1WRATtotalcent42   ///
c.timew1w3##w1smoke  c.timew1w3##w1currdrugs c.timew1w3##c.w1hei2010_total_scorecent43  c.timew1w3##c.w1BMIcent30 c.timew1w3##w1SRH c.timew1w3##c.w1CEScent15 c.timew1w3##w1dxHTN c.timew1w3##w1dxDiabetes c.timew1w3##w1CVhighChol c.timew1w3##w1cvdbr c.timew1w3##c.invmillsmms ///
c.timew1w3##c.zw1w3HCYTRAJ   ///
if sample4gobs==1 & Race==2 || HNDID: timew1w3

mi estimate: mixed DigitSpanBck  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat c.timew1w3##w1edubr c.timew1w3##c.w1WRATtotalcent42   ///
c.timew1w3##w1smoke  c.timew1w3##w1currdrugs c.timew1w3##c.w1hei2010_total_scorecent43  c.timew1w3##c.w1BMIcent30 c.timew1w3##w1SRH c.timew1w3##c.w1CEScent15 c.timew1w3##w1dxHTN c.timew1w3##w1dxDiabetes c.timew1w3##w1CVhighChol c.timew1w3##w1cvdbr c.timew1w3##c.invmillsmms ///
c.timew1w3##c.zw1w3HCYTRAJ   ///
if sample4hobs==1 & Race==2 || HNDID: timew1w3, cov(un)

mi estimate: mixed clock_command  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat c.timew1w3##w1edubr c.timew1w3##c.w1WRATtotalcent42   ///
c.timew1w3##w1smoke  c.timew1w3##w1currdrugs c.timew1w3##c.w1hei2010_total_scorecent43  c.timew1w3##c.w1BMIcent30 c.timew1w3##w1SRH c.timew1w3##c.w1CEScent15 c.timew1w3##w1dxHTN c.timew1w3##w1dxDiabetes c.timew1w3##w1CVhighChol c.timew1w3##w1cvdbr c.timew1w3##c.invmillsmms ///
c.timew1w3##c.zw1w3HCYTRAJ   ///
if sample4iobs==1 & Race==2 || HNDID: timew1w3, cov(un)

mi estimate: mixed LnTrailsAtestSec  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat c.timew1w3##w1edubr c.timew1w3##c.w1WRATtotalcent42   ///
c.timew1w3##w1smoke  c.timew1w3##w1currdrugs c.timew1w3##c.w1hei2010_total_scorecent43  c.timew1w3##c.w1BMIcent30 c.timew1w3##w1SRH c.timew1w3##c.w1CEScent15 c.timew1w3##w1dxHTN c.timew1w3##w1dxDiabetes c.timew1w3##w1CVhighChol c.timew1w3##w1cvdbr c.timew1w3##c.invmillsmms ///
c.timew1w3##c.zw1w3HCYTRAJ   ///
if sample4jobs==1 & Race==2 || HNDID: timew1w3

mi estimate: mixed LnTrailsBtestSec  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat c.timew1w3##w1edubr c.timew1w3##c.w1WRATtotalcent42   ///
c.timew1w3##w1smoke  c.timew1w3##w1currdrugs c.timew1w3##c.w1hei2010_total_scorecent43  c.timew1w3##c.w1BMIcent30 c.timew1w3##w1SRH c.timew1w3##c.w1CEScent15 c.timew1w3##w1dxHTN c.timew1w3##w1dxDiabetes c.timew1w3##w1CVhighChol c.timew1w3##w1cvdbr c.timew1w3##c.invmillsmms ///
c.timew1w3##c.zw1w3HCYTRAJ   ///
if sample4kobs==1  & Race==2 || HNDID: timew1w3, cov(un)


save, replace


*******************************TABLE 3: HOMOCYSTEINE TRAJ VS. COGNITIVE CHANGE OVER TIME: INTERACTION BY RACE**************************************

//MODEL 1: INCLUDE ONLY AGE, SEX, RACE AND POVERTY STATUS///
mi estimate: mixed MMStot  c.timew1w3##c.w1Agecent48 c.timew1w3##Race c.timew1w3##Race  c.timew1w3##PovStat  c.timew1w3##c.invmillsmms ///
c.timew1w3##c.zw1w3HCYTRAJ##Race   ///
if sample4aobs==1 || HNDID: timew1w3, cov(un)


mi estimate: mixed MMStotnorm  c.timew1w3##c.w1Agecent48 c.timew1w3##Race c.timew1w3##Race  c.timew1w3##PovStat  c.timew1w3##c.invmillsmms ///
c.timew1w3##c.zw1w3HCYTRAJ##Race   ///
if sample4aobs==1 || HNDID: timew1w3, cov(un)



mi estimate: mixed cvltca  c.timew1w3##c.w1Agecent48 c.timew1w3##Race c.timew1w3##Race  c.timew1w3##PovStat  c.timew1w3##c.invmillsmms ///
c.timew1w3##c.zw1w3HCYTRAJ##Race   ///
if sample4bobs==1 || HNDID: timew1w3



mi estimate: mixed CVLfrl  c.timew1w3##c.w1Agecent48 c.timew1w3##Race c.timew1w3##Race  c.timew1w3##PovStat  c.timew1w3##c.invmillsmms ///
c.timew1w3##c.zw1w3HCYTRAJ##Race   ///
if sample4cobs==1 || HNDID: timew1w3



mi estimate: mixed BVRtot  c.timew1w3##c.w1Agecent48 c.timew1w3##Race c.timew1w3##Race  c.timew1w3##PovStat  c.timew1w3##c.invmillsmms ///
c.timew1w3##c.zw1w3HCYTRAJ##Race   ///
if sample4dobs==1 || HNDID: timew1w3, cov(un)


mi estimate: mixed Attention  c.timew1w3##c.w1Agecent48 c.timew1w3##Race c.timew1w3##Race  c.timew1w3##PovStat  c.timew1w3##c.invmillsmms ///
c.timew1w3##c.zw1w3HCYTRAJ##Race   ///
if sample4eobs==1 || HNDID: timew1w3, cov(un)

mi estimate: mixed FluencyWord  c.timew1w3##c.w1Agecent48 c.timew1w3##Race c.timew1w3##Race  c.timew1w3##PovStat  c.timew1w3##c.invmillsmms ///
c.timew1w3##c.zw1w3HCYTRAJ##Race   ///
if sample4fobs==1 || HNDID: timew1w3, cov(un)

mi estimate: mixed DigitSpanFwd  c.timew1w3##c.w1Agecent48 c.timew1w3##Race c.timew1w3##Race  c.timew1w3##PovStat  c.timew1w3##c.invmillsmms ///
c.timew1w3##c.zw1w3HCYTRAJ##Race   ///
if sample4gobs==1 || HNDID: timew1w3, cov(un)

mi estimate: mixed DigitSpanBck  c.timew1w3##c.w1Agecent48 c.timew1w3##Race c.timew1w3##Race  c.timew1w3##PovStat  c.timew1w3##c.invmillsmms ///
c.timew1w3##c.zw1w3HCYTRAJ##Race   ///
if sample4hobs==1 || HNDID: timew1w3, cov(un)

mi estimate: mixed clock_command  c.timew1w3##c.w1Agecent48 c.timew1w3##Race c.timew1w3##Race  c.timew1w3##PovStat  c.timew1w3##c.invmillsmms ///
c.timew1w3##c.zw1w3HCYTRAJ##Race   ///
if sample4iobs==1 || HNDID: timew1w3, cov(un)

mi estimate: mixed LnTrailsAtestSec  c.timew1w3##c.w1Agecent48 c.timew1w3##Race c.timew1w3##Race  c.timew1w3##PovStat  c.timew1w3##c.invmillsmms ///
c.timew1w3##c.zw1w3HCYTRAJ##Race   ///
if sample4jobs==1 || HNDID: timew1w3

mi estimate: mixed LnTrailsBtestSec  c.timew1w3##c.w1Agecent48 c.timew1w3##Race c.timew1w3##Race  c.timew1w3##PovStat  c.timew1w3##c.invmillsmms ///
c.timew1w3##c.zw1w3HCYTRAJ##Race   ///
if sample4kobs==1  || HNDID: timew1w3, cov(un)


save, replace


//MODEL 2: MODEL 1 + OTHER FACTORS + BODY MASS INDEX///

mi estimate: mixed MMStot  c.timew1w3##c.w1Agecent48 c.timew1w3##Race c.timew1w3##Race  c.timew1w3##PovStat c.timew1w3##w1edubr c.timew1w3##c.w1WRATtotalcent42   ///
c.timew1w3##w1smoke  c.timew1w3##w1currdrugs c.timew1w3##c.w1hei2010_total_scorecent43  c.timew1w3##c.w1BMIcent30  c.timew1w3##c.invmillsmms ///
c.timew1w3##c.zw1w3HCYTRAJ##Race   ///
if sample4aobs==1 || HNDID: timew1w3, cov(un)


mi estimate: mixed MMStotnorm  c.timew1w3##c.w1Agecent48 c.timew1w3##Race c.timew1w3##Race  c.timew1w3##PovStat c.timew1w3##w1edubr c.timew1w3##c.w1WRATtotalcent42   ///
c.timew1w3##w1smoke  c.timew1w3##w1currdrugs c.timew1w3##c.w1hei2010_total_scorecent43  c.timew1w3##c.w1BMIcent30  c.timew1w3##c.invmillsmms ///
c.timew1w3##c.zw1w3HCYTRAJ##Race   ///
if sample4aobs==1 || HNDID: timew1w3, cov(un)



mi estimate: mixed cvltca  c.timew1w3##c.w1Agecent48 c.timew1w3##Race c.timew1w3##Race  c.timew1w3##PovStat c.timew1w3##w1edubr c.timew1w3##c.w1WRATtotalcent42   ///
c.timew1w3##w1smoke  c.timew1w3##w1currdrugs c.timew1w3##c.w1hei2010_total_scorecent43  c.timew1w3##c.w1BMIcent30  c.timew1w3##c.invmillsmms ///
c.timew1w3##c.zw1w3HCYTRAJ##Race   ///
if sample4bobs==1 || HNDID: timew1w3



mi estimate: mixed CVLfrl  c.timew1w3##c.w1Agecent48 c.timew1w3##Race c.timew1w3##Race  c.timew1w3##PovStat c.timew1w3##w1edubr c.timew1w3##c.w1WRATtotalcent42   ///
c.timew1w3##w1smoke  c.timew1w3##w1currdrugs c.timew1w3##c.w1hei2010_total_scorecent43  c.timew1w3##c.w1BMIcent30  c.timew1w3##c.invmillsmms ///
c.timew1w3##c.zw1w3HCYTRAJ##Race   ///
if sample4cobs==1 || HNDID: timew1w3



mi estimate: mixed BVRtot  c.timew1w3##c.w1Agecent48 c.timew1w3##Race c.timew1w3##Race  c.timew1w3##PovStat c.timew1w3##w1edubr c.timew1w3##c.w1WRATtotalcent42   ///
c.timew1w3##w1smoke  c.timew1w3##w1currdrugs c.timew1w3##c.w1hei2010_total_scorecent43  c.timew1w3##c.w1BMIcent30  c.timew1w3##c.invmillsmms ///
c.timew1w3##c.zw1w3HCYTRAJ##Race   ///
if sample4dobs==1 || HNDID: timew1w3, cov(un)


mi estimate: mixed Attention  c.timew1w3##c.w1Agecent48 c.timew1w3##Race c.timew1w3##Race  c.timew1w3##PovStat c.timew1w3##w1edubr c.timew1w3##c.w1WRATtotalcent42   ///
c.timew1w3##w1smoke  c.timew1w3##w1currdrugs c.timew1w3##c.w1hei2010_total_scorecent43  c.timew1w3##c.w1BMIcent30  c.timew1w3##c.invmillsmms ///
c.timew1w3##c.zw1w3HCYTRAJ##Race   ///
if sample4eobs==1 || HNDID: timew1w3, cov(un)

mi estimate: mixed FluencyWord  c.timew1w3##c.w1Agecent48 c.timew1w3##Race c.timew1w3##Race  c.timew1w3##PovStat c.timew1w3##w1edubr c.timew1w3##c.w1WRATtotalcent42   ///
c.timew1w3##w1smoke  c.timew1w3##w1currdrugs c.timew1w3##c.w1hei2010_total_scorecent43  c.timew1w3##c.w1BMIcent30  c.timew1w3##c.invmillsmms ///
c.timew1w3##c.zw1w3HCYTRAJ##Race   ///
if sample4fobs==1 || HNDID: timew1w3, cov(un)

mi estimate: mixed DigitSpanFwd  c.timew1w3##c.w1Agecent48 c.timew1w3##Race c.timew1w3##Race  c.timew1w3##PovStat c.timew1w3##w1edubr c.timew1w3##c.w1WRATtotalcent42   ///
c.timew1w3##w1smoke  c.timew1w3##w1currdrugs c.timew1w3##c.w1hei2010_total_scorecent43  c.timew1w3##c.w1BMIcent30  c.timew1w3##c.invmillsmms ///
c.timew1w3##c.zw1w3HCYTRAJ##Race   ///
if sample4gobs==1 || HNDID: timew1w3, cov(un)

mi estimate: mixed DigitSpanBck  c.timew1w3##c.w1Agecent48 c.timew1w3##Race c.timew1w3##Race  c.timew1w3##PovStat c.timew1w3##w1edubr c.timew1w3##c.w1WRATtotalcent42   ///
c.timew1w3##w1smoke  c.timew1w3##w1currdrugs c.timew1w3##c.w1hei2010_total_scorecent43  c.timew1w3##c.w1BMIcent30 c.timew1w3##c.invmillsmms ///
c.timew1w3##c.zw1w3HCYTRAJ##Race   ///
if sample4hobs==1 || HNDID: timew1w3

mi estimate: mixed clock_command  c.timew1w3##c.w1Agecent48 c.timew1w3##Race c.timew1w3##Race  c.timew1w3##PovStat c.timew1w3##w1edubr c.timew1w3##c.w1WRATtotalcent42   ///
c.timew1w3##w1smoke  c.timew1w3##w1currdrugs c.timew1w3##c.w1hei2010_total_scorecent43  c.timew1w3##c.w1BMIcent30  c.timew1w3##c.invmillsmms ///
c.timew1w3##c.zw1w3HCYTRAJ##Race   ///
if sample4iobs==1 || HNDID: timew1w3, cov(un)

mi estimate: mixed LnTrailsAtestSec  c.timew1w3##c.w1Agecent48 c.timew1w3##Race c.timew1w3##Race  c.timew1w3##PovStat c.timew1w3##w1edubr c.timew1w3##c.w1WRATtotalcent42   ///
c.timew1w3##w1smoke  c.timew1w3##w1currdrugs c.timew1w3##c.w1hei2010_total_scorecent43  c.timew1w3##c.w1BMIcent30  c.timew1w3##c.invmillsmms ///
c.timew1w3##c.zw1w3HCYTRAJ##Race   ///
if sample4jobs==1 || HNDID: timew1w3

mi estimate: mixed LnTrailsBtestSec  c.timew1w3##c.w1Agecent48 c.timew1w3##Race c.timew1w3##Race  c.timew1w3##PovStat c.timew1w3##w1edubr c.timew1w3##c.w1WRATtotalcent42   ///
c.timew1w3##w1smoke  c.timew1w3##w1currdrugs c.timew1w3##c.w1hei2010_total_scorecent43  c.timew1w3##c.w1BMIcent30  c.timew1w3##c.invmillsmms ///
c.timew1w3##c.zw1w3HCYTRAJ##Race   ///
if sample4kobs==1  || HNDID: timew1w3, cov(un)


save, replace


//MODEL 3: FULLY ADJUSTED MODEL: MODEL 2 + HEALTH-RELATED FACTORS///

mi estimate: mixed MMStot  c.timew1w3##c.w1Agecent48 c.timew1w3##Race c.timew1w3##Race  c.timew1w3##PovStat c.timew1w3##w1edubr c.timew1w3##c.w1WRATtotalcent42   ///
c.timew1w3##w1smoke  c.timew1w3##w1currdrugs c.timew1w3##c.w1hei2010_total_scorecent43  c.timew1w3##c.w1BMIcent30 c.timew1w3##w1SRH c.timew1w3##c.w1CEScent15 c.timew1w3##w1dxHTN c.timew1w3##w1dxDiabetes c.timew1w3##w1CVhighChol c.timew1w3##w1cvdbr c.timew1w3##c.invmillsmms ///
c.timew1w3##c.zw1w3HCYTRAJ##Race   ///
if sample4aobs==1 || HNDID: timew1w3, cov(un)


mi estimate: mixed MMStotnorm  c.timew1w3##c.w1Agecent48 c.timew1w3##Race c.timew1w3##Race  c.timew1w3##PovStat c.timew1w3##w1edubr c.timew1w3##c.w1WRATtotalcent42   ///
c.timew1w3##w1smoke  c.timew1w3##w1currdrugs c.timew1w3##c.w1hei2010_total_scorecent43  c.timew1w3##c.w1BMIcent30 c.timew1w3##w1SRH c.timew1w3##c.w1CEScent15 c.timew1w3##w1dxHTN c.timew1w3##w1dxDiabetes c.timew1w3##w1CVhighChol c.timew1w3##w1cvdbr c.timew1w3##c.invmillsmms ///
c.timew1w3##c.zw1w3HCYTRAJ##Race   ///
if sample4aobs==1 || HNDID: timew1w3, cov(un)



mi estimate: mixed cvltca  c.timew1w3##c.w1Agecent48 c.timew1w3##Race c.timew1w3##Race  c.timew1w3##PovStat c.timew1w3##w1edubr c.timew1w3##c.w1WRATtotalcent42   ///
c.timew1w3##w1smoke  c.timew1w3##w1currdrugs c.timew1w3##c.w1hei2010_total_scorecent43  c.timew1w3##c.w1BMIcent30 c.timew1w3##w1SRH c.timew1w3##c.w1CEScent15 c.timew1w3##w1dxHTN c.timew1w3##w1dxDiabetes c.timew1w3##w1CVhighChol c.timew1w3##w1cvdbr c.timew1w3##c.invmillsmms ///
c.timew1w3##c.zw1w3HCYTRAJ##Race   ///
if sample4bobs==1 || HNDID: timew1w3



mi estimate: mixed CVLfrl  c.timew1w3##c.w1Agecent48 c.timew1w3##Race c.timew1w3##Race  c.timew1w3##PovStat c.timew1w3##w1edubr c.timew1w3##c.w1WRATtotalcent42   ///
c.timew1w3##w1smoke  c.timew1w3##w1currdrugs c.timew1w3##c.w1hei2010_total_scorecent43  c.timew1w3##c.w1BMIcent30 c.timew1w3##w1SRH c.timew1w3##c.w1CEScent15 c.timew1w3##w1dxHTN c.timew1w3##w1dxDiabetes c.timew1w3##w1CVhighChol c.timew1w3##w1cvdbr c.timew1w3##c.invmillsmms ///
c.timew1w3##c.zw1w3HCYTRAJ##Race   ///
if sample4cobs==1 || HNDID: timew1w3



mi estimate: mixed BVRtot  c.timew1w3##c.w1Agecent48 c.timew1w3##Race c.timew1w3##Race  c.timew1w3##PovStat c.timew1w3##w1edubr c.timew1w3##c.w1WRATtotalcent42   ///
c.timew1w3##w1smoke  c.timew1w3##w1currdrugs c.timew1w3##c.w1hei2010_total_scorecent43  c.timew1w3##c.w1BMIcent30 c.timew1w3##w1SRH c.timew1w3##c.w1CEScent15 c.timew1w3##w1dxHTN c.timew1w3##w1dxDiabetes c.timew1w3##w1CVhighChol c.timew1w3##w1cvdbr c.timew1w3##c.invmillsmms ///
c.timew1w3##c.zw1w3HCYTRAJ##Race   ///
if sample4dobs==1 || HNDID: timew1w3, cov(un)


mi estimate: mixed Attention  c.timew1w3##c.w1Agecent48 c.timew1w3##Race c.timew1w3##Race  c.timew1w3##PovStat c.timew1w3##w1edubr c.timew1w3##c.w1WRATtotalcent42   ///
c.timew1w3##w1smoke  c.timew1w3##w1currdrugs c.timew1w3##c.w1hei2010_total_scorecent43  c.timew1w3##c.w1BMIcent30 c.timew1w3##w1SRH c.timew1w3##c.w1CEScent15 c.timew1w3##w1dxHTN c.timew1w3##w1dxDiabetes c.timew1w3##w1CVhighChol c.timew1w3##w1cvdbr c.timew1w3##c.invmillsmms ///
c.timew1w3##c.zw1w3HCYTRAJ##Race   ///
if sample4eobs==1 || HNDID: timew1w3, cov(un)

mi estimate: mixed FluencyWord  c.timew1w3##c.w1Agecent48 c.timew1w3##Race c.timew1w3##Race  c.timew1w3##PovStat c.timew1w3##w1edubr c.timew1w3##c.w1WRATtotalcent42   ///
c.timew1w3##w1smoke  c.timew1w3##w1currdrugs c.timew1w3##c.w1hei2010_total_scorecent43  c.timew1w3##c.w1BMIcent30 c.timew1w3##w1SRH c.timew1w3##c.w1CEScent15 c.timew1w3##w1dxHTN c.timew1w3##w1dxDiabetes c.timew1w3##w1CVhighChol c.timew1w3##w1cvdbr c.timew1w3##c.invmillsmms ///
c.timew1w3##c.zw1w3HCYTRAJ##Race   ///
if sample4fobs==1 || HNDID: timew1w3, cov(un)

mi estimate: mixed DigitSpanFwd  c.timew1w3##c.w1Agecent48 c.timew1w3##Race c.timew1w3##Race  c.timew1w3##PovStat c.timew1w3##w1edubr c.timew1w3##c.w1WRATtotalcent42   ///
c.timew1w3##w1smoke  c.timew1w3##w1currdrugs c.timew1w3##c.w1hei2010_total_scorecent43  c.timew1w3##c.w1BMIcent30 c.timew1w3##w1SRH c.timew1w3##c.w1CEScent15 c.timew1w3##w1dxHTN c.timew1w3##w1dxDiabetes c.timew1w3##w1CVhighChol c.timew1w3##w1cvdbr c.timew1w3##c.invmillsmms ///
c.timew1w3##c.zw1w3HCYTRAJ##Race   ///
if sample4gobs==1 || HNDID: timew1w3, cov(un)

mi estimate: mixed DigitSpanBck  c.timew1w3##c.w1Agecent48 c.timew1w3##Race c.timew1w3##Race  c.timew1w3##PovStat c.timew1w3##w1edubr c.timew1w3##c.w1WRATtotalcent42   ///
c.timew1w3##w1smoke  c.timew1w3##w1currdrugs c.timew1w3##c.w1hei2010_total_scorecent43  c.timew1w3##c.w1BMIcent30 c.timew1w3##w1SRH c.timew1w3##c.w1CEScent15 c.timew1w3##w1dxHTN c.timew1w3##w1dxDiabetes c.timew1w3##w1CVhighChol c.timew1w3##w1cvdbr c.timew1w3##c.invmillsmms ///
c.timew1w3##c.zw1w3HCYTRAJ##Race   ///
if sample4hobs==1 || HNDID: timew1w3, cov(un)

mi estimate: mixed clock_command  c.timew1w3##c.w1Agecent48 c.timew1w3##Race c.timew1w3##Race  c.timew1w3##PovStat c.timew1w3##w1edubr c.timew1w3##c.w1WRATtotalcent42   ///
c.timew1w3##w1smoke  c.timew1w3##w1currdrugs c.timew1w3##c.w1hei2010_total_scorecent43  c.timew1w3##c.w1BMIcent30 c.timew1w3##w1SRH c.timew1w3##c.w1CEScent15 c.timew1w3##w1dxHTN c.timew1w3##w1dxDiabetes c.timew1w3##w1CVhighChol c.timew1w3##w1cvdbr c.timew1w3##c.invmillsmms ///
c.timew1w3##c.zw1w3HCYTRAJ##Race   ///
if sample4iobs==1 || HNDID: timew1w3, cov(un)

mi estimate: mixed LnTrailsAtestSec  c.timew1w3##c.w1Agecent48 c.timew1w3##Race c.timew1w3##Race  c.timew1w3##PovStat c.timew1w3##w1edubr c.timew1w3##c.w1WRATtotalcent42   ///
c.timew1w3##w1smoke  c.timew1w3##w1currdrugs c.timew1w3##c.w1hei2010_total_scorecent43  c.timew1w3##c.w1BMIcent30 c.timew1w3##w1SRH c.timew1w3##c.w1CEScent15 c.timew1w3##w1dxHTN c.timew1w3##w1dxDiabetes c.timew1w3##w1CVhighChol c.timew1w3##w1cvdbr c.timew1w3##c.invmillsmms ///
c.timew1w3##c.zw1w3HCYTRAJ##Race   ///
if sample4jobs==1 || HNDID: timew1w3

mi estimate: mixed LnTrailsBtestSec  c.timew1w3##c.w1Agecent48 c.timew1w3##Race c.timew1w3##Race  c.timew1w3##PovStat c.timew1w3##w1edubr c.timew1w3##c.w1WRATtotalcent42   ///
c.timew1w3##w1smoke  c.timew1w3##w1currdrugs c.timew1w3##c.w1hei2010_total_scorecent43  c.timew1w3##c.w1BMIcent30 c.timew1w3##w1SRH c.timew1w3##c.w1CEScent15 c.timew1w3##w1dxHTN c.timew1w3##w1dxDiabetes c.timew1w3##w1CVhighChol c.timew1w3##w1cvdbr c.timew1w3##c.invmillsmms ///
c.timew1w3##c.zw1w3HCYTRAJ##Race   ///
if sample4kobs==1  || HNDID: timew1w3, cov(un)


save, replace


capture log close


capture log close

log using "E:\HANDLS_PAPER65_HCY_COGN\OUTPUT\TABLES2.smcl", replace

use finaldata_imputed_FINAL,clear


************************************INTERACTION WITH FOLATE AND B12: BASELINE HCY************************************************************



*******************************TABLE S1: HOMOCYSTEINE AT BASELINE VS. COGNITIVE CHANGE OVER TIME: INTERACTION BY FOL**************************************


//MODEL 1: INCLUDE ONLY AGE, SEX, RACE AND POVERTY STATUS///
mi estimate: mixed MMStot  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat  c.timew1w3##c.invmillsmms ///
c.timew1w3##c.w1HCYcenter2p15##c.w1Folatecenter14p3   ///
if sample4aobs==1 || HNDID: timew1w3


mi estimate: mixed MMStotnorm  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat  c.timew1w3##c.invmillsmms ///
c.timew1w3##c.w1HCYcenter2p15##c.w1Folatecenter14p3   ///
if sample4aobs==1 || HNDID: timew1w3



mi estimate: mixed cvltca  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat  c.timew1w3##c.invmillsmms ///
c.timew1w3##c.w1HCYcenter2p15##c.w1Folatecenter14p3   ///
if sample4bobs==1 || HNDID: timew1w3



mi estimate: mixed CVLfrl  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat  c.timew1w3##c.invmillsmms ///
c.timew1w3##c.w1HCYcenter2p15##c.w1Folatecenter14p3   ///
if sample4cobs==1 || HNDID: 



mi estimate: mixed BVRtot  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat  c.timew1w3##c.invmillsmms ///
c.timew1w3##c.w1HCYcenter2p15##c.w1Folatecenter14p3   ///
if sample4dobs==1 || HNDID: timew1w3


mi estimate: mixed Attention  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat  c.timew1w3##c.invmillsmms ///
c.timew1w3##c.w1HCYcenter2p15##c.w1Folatecenter14p3   ///
if sample4eobs==1 || HNDID: timew1w3

mi estimate: mixed FluencyWord  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat  c.timew1w3##c.invmillsmms ///
c.timew1w3##c.w1HCYcenter2p15##c.w1Folatecenter14p3   ///
if sample4fobs==1 || HNDID: timew1w3

mi estimate: mixed DigitSpanFwd  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat  c.timew1w3##c.invmillsmms ///
c.timew1w3##c.w1HCYcenter2p15##c.w1Folatecenter14p3   ///
if sample4gobs==1 || HNDID: timew1w3

mi estimate: mixed DigitSpanBck  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat  c.timew1w3##c.invmillsmms ///
c.timew1w3##c.w1HCYcenter2p15##c.w1Folatecenter14p3   ///
if sample4hobs==1 || HNDID: timew1w3

mi estimate: mixed clock_command  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat  c.timew1w3##c.invmillsmms ///
c.timew1w3##c.w1HCYcenter2p15##c.w1Folatecenter14p3   ///
if sample4iobs==1 || HNDID: timew1w3

mi estimate: mixed LnTrailsAtestSec  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat  c.timew1w3##c.invmillsmms ///
c.timew1w3##c.w1HCYcenter2p15##c.w1Folatecenter14p3   ///
if sample4jobs==1 || HNDID: timew1w3

mi estimate: mixed LnTrailsBtestSec  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat  c.timew1w3##c.invmillsmms ///
c.timew1w3##c.w1HCYcenter2p15##c.w1Folatecenter14p3   ///
if sample4kobs==1  || HNDID: timew1w3


save, replace


//MODEL 2: MODEL 1 + OTHER FACTORS + BODY MASS INDEX///

mi estimate: mixed MMStot  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat c.timew1w3##w1edubr c.timew1w3##c.w1WRATtotalcent42   ///
c.timew1w3##w1smoke  c.timew1w3##w1currdrugs c.timew1w3##c.w1hei2010_total_scorecent43  c.timew1w3##c.w1BMIcent30  c.timew1w3##c.invmillsmms ///
c.timew1w3##c.w1HCYcenter2p15##c.w1Folatecenter14p3   ///
if sample4aobs==1 || HNDID: timew1w3


mi estimate: mixed MMStotnorm  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat c.timew1w3##w1edubr c.timew1w3##c.w1WRATtotalcent42   ///
c.timew1w3##w1smoke  c.timew1w3##w1currdrugs c.timew1w3##c.w1hei2010_total_scorecent43  c.timew1w3##c.w1BMIcent30  c.timew1w3##c.invmillsmms ///
c.timew1w3##c.w1HCYcenter2p15##c.w1Folatecenter14p3   ///
if sample4aobs==1 || HNDID: timew1w3



mi estimate: mixed cvltca  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat c.timew1w3##w1edubr c.timew1w3##c.w1WRATtotalcent42   ///
c.timew1w3##w1smoke  c.timew1w3##w1currdrugs c.timew1w3##c.w1hei2010_total_scorecent43  c.timew1w3##c.w1BMIcent30  c.timew1w3##c.invmillsmms ///
c.timew1w3##c.w1HCYcenter2p15##c.w1Folatecenter14p3   ///
if sample4bobs==1 || HNDID: timew1w3



mi estimate: mixed CVLfrl  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat c.timew1w3##w1edubr c.timew1w3##c.w1WRATtotalcent42   ///
c.timew1w3##w1smoke  c.timew1w3##w1currdrugs c.timew1w3##c.w1hei2010_total_scorecent43  c.timew1w3##c.w1BMIcent30  c.timew1w3##c.invmillsmms ///
c.timew1w3##c.w1HCYcenter2p15##c.w1Folatecenter14p3   ///
if sample4cobs==1 || HNDID: timew1w3



mi estimate: mixed BVRtot  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat c.timew1w3##w1edubr c.timew1w3##c.w1WRATtotalcent42   ///
c.timew1w3##w1smoke  c.timew1w3##w1currdrugs c.timew1w3##c.w1hei2010_total_scorecent43  c.timew1w3##c.w1BMIcent30  c.timew1w3##c.invmillsmms ///
c.timew1w3##c.w1HCYcenter2p15##c.w1Folatecenter14p3   ///
if sample4dobs==1 || HNDID: timew1w3


mi estimate: mixed Attention  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat c.timew1w3##w1edubr c.timew1w3##c.w1WRATtotalcent42   ///
c.timew1w3##w1smoke  c.timew1w3##w1currdrugs c.timew1w3##c.w1hei2010_total_scorecent43  c.timew1w3##c.w1BMIcent30  c.timew1w3##c.invmillsmms ///
c.timew1w3##c.w1HCYcenter2p15##c.w1Folatecenter14p3   ///
if sample4eobs==1 || HNDID: timew1w3

mi estimate: mixed FluencyWord  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat c.timew1w3##w1edubr c.timew1w3##c.w1WRATtotalcent42   ///
c.timew1w3##w1smoke  c.timew1w3##w1currdrugs c.timew1w3##c.w1hei2010_total_scorecent43  c.timew1w3##c.w1BMIcent30  c.timew1w3##c.invmillsmms ///
c.timew1w3##c.w1HCYcenter2p15##c.w1Folatecenter14p3   ///
if sample4fobs==1 || HNDID: timew1w3

mi estimate: mixed DigitSpanFwd  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat c.timew1w3##w1edubr c.timew1w3##c.w1WRATtotalcent42   ///
c.timew1w3##w1smoke  c.timew1w3##w1currdrugs c.timew1w3##c.w1hei2010_total_scorecent43  c.timew1w3##c.w1BMIcent30  c.timew1w3##c.invmillsmms ///
c.timew1w3##c.w1HCYcenter2p15##c.w1Folatecenter14p3   ///
if sample4gobs==1 || HNDID: timew1w3

mi estimate: mixed DigitSpanBck  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat c.timew1w3##w1edubr c.timew1w3##c.w1WRATtotalcent42   ///
c.timew1w3##w1smoke  c.timew1w3##w1currdrugs c.timew1w3##c.w1hei2010_total_scorecent43  c.timew1w3##c.w1BMIcent30 c.timew1w3##c.invmillsmms ///
c.timew1w3##c.w1HCYcenter2p15##c.w1Folatecenter14p3   ///
if sample4hobs==1 || HNDID: timew1w3

mi estimate: mixed clock_command  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat c.timew1w3##w1edubr c.timew1w3##c.w1WRATtotalcent42   ///
c.timew1w3##w1smoke  c.timew1w3##w1currdrugs c.timew1w3##c.w1hei2010_total_scorecent43  c.timew1w3##c.w1BMIcent30  c.timew1w3##c.invmillsmms ///
c.timew1w3##c.w1HCYcenter2p15##c.w1Folatecenter14p3   ///
if sample4iobs==1 || HNDID: timew1w3

mi estimate: mixed LnTrailsAtestSec  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat c.timew1w3##w1edubr c.timew1w3##c.w1WRATtotalcent42   ///
c.timew1w3##w1smoke  c.timew1w3##w1currdrugs c.timew1w3##c.w1hei2010_total_scorecent43  c.timew1w3##c.w1BMIcent30  c.timew1w3##c.invmillsmms ///
c.timew1w3##c.w1HCYcenter2p15##c.w1Folatecenter14p3   ///
if sample4jobs==1 || HNDID: timew1w3

mi estimate: mixed LnTrailsBtestSec  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat c.timew1w3##w1edubr c.timew1w3##c.w1WRATtotalcent42   ///
c.timew1w3##w1smoke  c.timew1w3##w1currdrugs c.timew1w3##c.w1hei2010_total_scorecent43  c.timew1w3##c.w1BMIcent30  c.timew1w3##c.invmillsmms ///
c.timew1w3##c.w1HCYcenter2p15##c.w1Folatecenter14p3   ///
if sample4kobs==1  || HNDID: timew1w3


save, replace


//MODEL 3: FULLY ADJUSTED MODEL: MODEL 2 + HEALTH-RELATED FACTORS///

mi estimate: mixed MMStot  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat c.timew1w3##w1edubr c.timew1w3##c.w1WRATtotalcent42   ///
c.timew1w3##w1smoke  c.timew1w3##w1currdrugs c.timew1w3##c.w1hei2010_total_scorecent43  c.timew1w3##c.w1BMIcent30 c.timew1w3##w1SRH c.timew1w3##c.w1CEScent15 c.timew1w3##w1dxHTN c.timew1w3##w1dxDiabetes c.timew1w3##w1CVhighChol c.timew1w3##w1cvdbr c.timew1w3##c.invmillsmms ///
c.timew1w3##c.w1HCYcenter2p15##c.w1Folatecenter14p3   ///
if sample4aobs==1 || HNDID: timew1w3


mi estimate: mixed MMStotnorm  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat c.timew1w3##w1edubr c.timew1w3##c.w1WRATtotalcent42   ///
c.timew1w3##w1smoke  c.timew1w3##w1currdrugs c.timew1w3##c.w1hei2010_total_scorecent43  c.timew1w3##c.w1BMIcent30 c.timew1w3##w1SRH c.timew1w3##c.w1CEScent15 c.timew1w3##w1dxHTN c.timew1w3##w1dxDiabetes c.timew1w3##w1CVhighChol c.timew1w3##w1cvdbr c.timew1w3##c.invmillsmms ///
c.timew1w3##c.w1HCYcenter2p15##c.w1Folatecenter14p3   ///
if sample4aobs==1 || HNDID: timew1w3



mi estimate: mixed cvltca  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat c.timew1w3##w1edubr c.timew1w3##c.w1WRATtotalcent42   ///
c.timew1w3##w1smoke  c.timew1w3##w1currdrugs c.timew1w3##c.w1hei2010_total_scorecent43  c.timew1w3##c.w1BMIcent30 c.timew1w3##w1SRH c.timew1w3##c.w1CEScent15 c.timew1w3##w1dxHTN c.timew1w3##w1dxDiabetes c.timew1w3##w1CVhighChol c.timew1w3##w1cvdbr c.timew1w3##c.invmillsmms ///
c.timew1w3##c.w1HCYcenter2p15##c.w1Folatecenter14p3   ///
if sample4bobs==1 || HNDID: timew1w3



mi estimate: mixed CVLfrl  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat c.timew1w3##w1edubr c.timew1w3##c.w1WRATtotalcent42   ///
c.timew1w3##w1smoke  c.timew1w3##w1currdrugs c.timew1w3##c.w1hei2010_total_scorecent43  c.timew1w3##c.w1BMIcent30 c.timew1w3##w1SRH c.timew1w3##c.w1CEScent15 c.timew1w3##w1dxHTN c.timew1w3##w1dxDiabetes c.timew1w3##w1CVhighChol c.timew1w3##w1cvdbr c.timew1w3##c.invmillsmms ///
c.timew1w3##c.w1HCYcenter2p15##c.w1Folatecenter14p3   ///
if sample4cobs==1 || HNDID: timew1w3



mi estimate: mixed BVRtot  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat c.timew1w3##w1edubr c.timew1w3##c.w1WRATtotalcent42   ///
c.timew1w3##w1smoke  c.timew1w3##w1currdrugs c.timew1w3##c.w1hei2010_total_scorecent43  c.timew1w3##c.w1BMIcent30 c.timew1w3##w1SRH c.timew1w3##c.w1CEScent15 c.timew1w3##w1dxHTN c.timew1w3##w1dxDiabetes c.timew1w3##w1CVhighChol c.timew1w3##w1cvdbr c.timew1w3##c.invmillsmms ///
c.timew1w3##c.w1HCYcenter2p15##c.w1Folatecenter14p3   ///
if sample4dobs==1 || HNDID: timew1w3


mi estimate: mixed Attention  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat c.timew1w3##w1edubr c.timew1w3##c.w1WRATtotalcent42   ///
c.timew1w3##w1smoke  c.timew1w3##w1currdrugs c.timew1w3##c.w1hei2010_total_scorecent43  c.timew1w3##c.w1BMIcent30 c.timew1w3##w1SRH c.timew1w3##c.w1CEScent15 c.timew1w3##w1dxHTN c.timew1w3##w1dxDiabetes c.timew1w3##w1CVhighChol c.timew1w3##w1cvdbr c.timew1w3##c.invmillsmms ///
c.timew1w3##c.w1HCYcenter2p15##c.w1Folatecenter14p3   ///
if sample4eobs==1 || HNDID: timew1w3

mi estimate: mixed FluencyWord  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat c.timew1w3##w1edubr c.timew1w3##c.w1WRATtotalcent42   ///
c.timew1w3##w1smoke  c.timew1w3##w1currdrugs c.timew1w3##c.w1hei2010_total_scorecent43  c.timew1w3##c.w1BMIcent30 c.timew1w3##w1SRH c.timew1w3##c.w1CEScent15 c.timew1w3##w1dxHTN c.timew1w3##w1dxDiabetes c.timew1w3##w1CVhighChol c.timew1w3##w1cvdbr c.timew1w3##c.invmillsmms ///
c.timew1w3##c.w1HCYcenter2p15##c.w1Folatecenter14p3   ///
if sample4fobs==1 || HNDID: timew1w3

mi estimate: mixed DigitSpanFwd  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat c.timew1w3##w1edubr c.timew1w3##c.w1WRATtotalcent42   ///
c.timew1w3##w1smoke  c.timew1w3##w1currdrugs c.timew1w3##c.w1hei2010_total_scorecent43  c.timew1w3##c.w1BMIcent30 c.timew1w3##w1SRH c.timew1w3##c.w1CEScent15 c.timew1w3##w1dxHTN c.timew1w3##w1dxDiabetes c.timew1w3##w1CVhighChol c.timew1w3##w1cvdbr c.timew1w3##c.invmillsmms ///
c.timew1w3##c.w1HCYcenter2p15##c.w1Folatecenter14p3   ///
if sample4gobs==1 || HNDID: timew1w3

mi estimate: mixed DigitSpanBck  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat c.timew1w3##w1edubr c.timew1w3##c.w1WRATtotalcent42   ///
c.timew1w3##w1smoke  c.timew1w3##w1currdrugs c.timew1w3##c.w1hei2010_total_scorecent43  c.timew1w3##c.w1BMIcent30 c.timew1w3##w1SRH c.timew1w3##c.w1CEScent15 c.timew1w3##w1dxHTN c.timew1w3##w1dxDiabetes c.timew1w3##w1CVhighChol c.timew1w3##w1cvdbr c.timew1w3##c.invmillsmms ///
c.timew1w3##c.w1HCYcenter2p15##c.w1Folatecenter14p3   ///
if sample4hobs==1 || HNDID: timew1w3

mi estimate: mixed clock_command  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat c.timew1w3##w1edubr c.timew1w3##c.w1WRATtotalcent42   ///
c.timew1w3##w1smoke  c.timew1w3##w1currdrugs c.timew1w3##c.w1hei2010_total_scorecent43  c.timew1w3##c.w1BMIcent30 c.timew1w3##w1SRH c.timew1w3##c.w1CEScent15 c.timew1w3##w1dxHTN c.timew1w3##w1dxDiabetes c.timew1w3##w1CVhighChol c.timew1w3##w1cvdbr c.timew1w3##c.invmillsmms ///
c.timew1w3##c.w1HCYcenter2p15##c.w1Folatecenter14p3   ///
if sample4iobs==1 || HNDID: timew1w3

mi estimate: mixed LnTrailsAtestSec  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat c.timew1w3##w1edubr c.timew1w3##c.w1WRATtotalcent42   ///
c.timew1w3##w1smoke  c.timew1w3##w1currdrugs c.timew1w3##c.w1hei2010_total_scorecent43  c.timew1w3##c.w1BMIcent30 c.timew1w3##w1SRH c.timew1w3##c.w1CEScent15 c.timew1w3##w1dxHTN c.timew1w3##w1dxDiabetes c.timew1w3##w1CVhighChol c.timew1w3##w1cvdbr c.timew1w3##c.invmillsmms ///
c.timew1w3##c.w1HCYcenter2p15##c.w1Folatecenter14p3   ///
if sample4jobs==1 || HNDID: timew1w3

mi estimate: mixed LnTrailsBtestSec  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat c.timew1w3##w1edubr c.timew1w3##c.w1WRATtotalcent42   ///
c.timew1w3##w1smoke  c.timew1w3##w1currdrugs c.timew1w3##c.w1hei2010_total_scorecent43  c.timew1w3##c.w1BMIcent30 c.timew1w3##w1SRH c.timew1w3##c.w1CEScent15 c.timew1w3##w1dxHTN c.timew1w3##w1dxDiabetes c.timew1w3##w1CVhighChol c.timew1w3##w1cvdbr c.timew1w3##c.invmillsmms ///
c.timew1w3##c.w1HCYcenter2p15##c.w1Folatecenter14p3   ///
if sample4kobs==1  || HNDID: timew1w3


save, replace




*******************************TABLE S1: HOMOCYSTEINE AT BASELINE VS. COGNITIVE CHANGE OVER TIME: INTERACTION BY B12**************************************


//MODEL 1: INCLUDE ONLY AGE, SEX, RACE AND POVERTY STATUS///
mi estimate: mixed MMStot  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat  c.timew1w3##c.invmillsmms ///
c.timew1w3##c.w1HCYcenter2p15##c.w1B12center522   ///
if sample4aobs==1 || HNDID: timew1w3


mi estimate: mixed MMStotnorm  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat  c.timew1w3##c.invmillsmms ///
c.timew1w3##c.w1HCYcenter2p15##c.w1B12center522   ///
if sample4aobs==1 || HNDID: timew1w3



mi estimate: mixed cvltca  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat  c.timew1w3##c.invmillsmms ///
c.timew1w3##c.w1HCYcenter2p15##c.w1B12center522   ///
if sample4bobs==1 || HNDID: timew1w3



mi estimate: mixed CVLfrl  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat  c.timew1w3##c.invmillsmms ///
c.timew1w3##c.w1HCYcenter2p15##c.w1B12center522   ///
if sample4cobs==1 || HNDID: 



mi estimate: mixed BVRtot  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat  c.timew1w3##c.invmillsmms ///
c.timew1w3##c.w1HCYcenter2p15##c.w1B12center522   ///
if sample4dobs==1 || HNDID: timew1w3


mi estimate: mixed Attention  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat  c.timew1w3##c.invmillsmms ///
c.timew1w3##c.w1HCYcenter2p15##c.w1B12center522   ///
if sample4eobs==1 || HNDID: timew1w3

mi estimate: mixed FluencyWord  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat  c.timew1w3##c.invmillsmms ///
c.timew1w3##c.w1HCYcenter2p15##c.w1B12center522   ///
if sample4fobs==1 || HNDID: timew1w3

mi estimate: mixed DigitSpanFwd  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat  c.timew1w3##c.invmillsmms ///
c.timew1w3##c.w1HCYcenter2p15##c.w1B12center522   ///
if sample4gobs==1 || HNDID: timew1w3

mi estimate: mixed DigitSpanBck  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat  c.timew1w3##c.invmillsmms ///
c.timew1w3##c.w1HCYcenter2p15##c.w1B12center522   ///
if sample4hobs==1 || HNDID: timew1w3

mi estimate: mixed clock_command  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat  c.timew1w3##c.invmillsmms ///
c.timew1w3##c.w1HCYcenter2p15##c.w1B12center522   ///
if sample4iobs==1 || HNDID: timew1w3

mi estimate: mixed LnTrailsAtestSec  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat  c.timew1w3##c.invmillsmms ///
c.timew1w3##c.w1HCYcenter2p15##c.w1B12center522   ///
if sample4jobs==1 || HNDID: timew1w3

mi estimate: mixed LnTrailsBtestSec  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat  c.timew1w3##c.invmillsmms ///
c.timew1w3##c.w1HCYcenter2p15##c.w1B12center522   ///
if sample4kobs==1  || HNDID: timew1w3


save, replace


//MODEL 2: MODEL 1 + OTHER FACTORS + BODY MASS INDEX///

mi estimate: mixed MMStot  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat c.timew1w3##w1edubr c.timew1w3##c.w1WRATtotalcent42   ///
c.timew1w3##w1smoke  c.timew1w3##w1currdrugs c.timew1w3##c.w1hei2010_total_scorecent43  c.timew1w3##c.w1BMIcent30  c.timew1w3##c.invmillsmms ///
c.timew1w3##c.w1HCYcenter2p15##c.w1B12center522   ///
if sample4aobs==1 || HNDID: timew1w3


mi estimate: mixed MMStotnorm  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat c.timew1w3##w1edubr c.timew1w3##c.w1WRATtotalcent42   ///
c.timew1w3##w1smoke  c.timew1w3##w1currdrugs c.timew1w3##c.w1hei2010_total_scorecent43  c.timew1w3##c.w1BMIcent30  c.timew1w3##c.invmillsmms ///
c.timew1w3##c.w1HCYcenter2p15##c.w1B12center522   ///
if sample4aobs==1 || HNDID: timew1w3



mi estimate: mixed cvltca  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat c.timew1w3##w1edubr c.timew1w3##c.w1WRATtotalcent42   ///
c.timew1w3##w1smoke  c.timew1w3##w1currdrugs c.timew1w3##c.w1hei2010_total_scorecent43  c.timew1w3##c.w1BMIcent30  c.timew1w3##c.invmillsmms ///
c.timew1w3##c.w1HCYcenter2p15##c.w1B12center522   ///
if sample4bobs==1 || HNDID: timew1w3



mi estimate: mixed CVLfrl  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat c.timew1w3##w1edubr c.timew1w3##c.w1WRATtotalcent42   ///
c.timew1w3##w1smoke  c.timew1w3##w1currdrugs c.timew1w3##c.w1hei2010_total_scorecent43  c.timew1w3##c.w1BMIcent30  c.timew1w3##c.invmillsmms ///
c.timew1w3##c.w1HCYcenter2p15##c.w1B12center522   ///
if sample4cobs==1 || HNDID: 



mi estimate: mixed BVRtot  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat c.timew1w3##w1edubr c.timew1w3##c.w1WRATtotalcent42   ///
c.timew1w3##w1smoke  c.timew1w3##w1currdrugs c.timew1w3##c.w1hei2010_total_scorecent43  c.timew1w3##c.w1BMIcent30  c.timew1w3##c.invmillsmms ///
c.timew1w3##c.w1HCYcenter2p15##c.w1B12center522   ///
if sample4dobs==1 || HNDID: timew1w3


mi estimate: mixed Attention  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat c.timew1w3##w1edubr c.timew1w3##c.w1WRATtotalcent42   ///
c.timew1w3##w1smoke  c.timew1w3##w1currdrugs c.timew1w3##c.w1hei2010_total_scorecent43  c.timew1w3##c.w1BMIcent30  c.timew1w3##c.invmillsmms ///
c.timew1w3##c.w1HCYcenter2p15##c.w1B12center522   ///
if sample4eobs==1 || HNDID: timew1w3

mi estimate: mixed FluencyWord  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat c.timew1w3##w1edubr c.timew1w3##c.w1WRATtotalcent42   ///
c.timew1w3##w1smoke  c.timew1w3##w1currdrugs c.timew1w3##c.w1hei2010_total_scorecent43  c.timew1w3##c.w1BMIcent30  c.timew1w3##c.invmillsmms ///
c.timew1w3##c.w1HCYcenter2p15##c.w1B12center522   ///
if sample4fobs==1 || HNDID: timew1w3

mi estimate: mixed DigitSpanFwd  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat c.timew1w3##w1edubr c.timew1w3##c.w1WRATtotalcent42   ///
c.timew1w3##w1smoke  c.timew1w3##w1currdrugs c.timew1w3##c.w1hei2010_total_scorecent43  c.timew1w3##c.w1BMIcent30  c.timew1w3##c.invmillsmms ///
c.timew1w3##c.w1HCYcenter2p15##c.w1B12center522   ///
if sample4gobs==1 || HNDID: timew1w3

mi estimate: mixed DigitSpanBck  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat c.timew1w3##w1edubr c.timew1w3##c.w1WRATtotalcent42   ///
c.timew1w3##w1smoke  c.timew1w3##w1currdrugs c.timew1w3##c.w1hei2010_total_scorecent43  c.timew1w3##c.w1BMIcent30 c.timew1w3##c.invmillsmms ///
c.timew1w3##c.w1HCYcenter2p15##c.w1B12center522   ///
if sample4hobs==1 || HNDID: timew1w3

mi estimate: mixed clock_command  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat c.timew1w3##w1edubr c.timew1w3##c.w1WRATtotalcent42   ///
c.timew1w3##w1smoke  c.timew1w3##w1currdrugs c.timew1w3##c.w1hei2010_total_scorecent43  c.timew1w3##c.w1BMIcent30  c.timew1w3##c.invmillsmms ///
c.timew1w3##c.w1HCYcenter2p15##c.w1B12center522   ///
if sample4iobs==1 || HNDID: timew1w3

mi estimate: mixed LnTrailsAtestSec  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat c.timew1w3##w1edubr c.timew1w3##c.w1WRATtotalcent42   ///
c.timew1w3##w1smoke  c.timew1w3##w1currdrugs c.timew1w3##c.w1hei2010_total_scorecent43  c.timew1w3##c.w1BMIcent30  c.timew1w3##c.invmillsmms ///
c.timew1w3##c.w1HCYcenter2p15##c.w1B12center522   ///
if sample4jobs==1 || HNDID: timew1w3

mi estimate: mixed LnTrailsBtestSec  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat c.timew1w3##w1edubr c.timew1w3##c.w1WRATtotalcent42   ///
c.timew1w3##w1smoke  c.timew1w3##w1currdrugs c.timew1w3##c.w1hei2010_total_scorecent43  c.timew1w3##c.w1BMIcent30  c.timew1w3##c.invmillsmms ///
c.timew1w3##c.w1HCYcenter2p15##c.w1B12center522   ///
if sample4kobs==1  || HNDID: timew1w3


save, replace


//MODEL 3: FULLY ADJUSTED MODEL: MODEL 2 + HEALTH-RELATED FACTORS///

mi estimate: mixed MMStot  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat c.timew1w3##w1edubr c.timew1w3##c.w1WRATtotalcent42   ///
c.timew1w3##w1smoke  c.timew1w3##w1currdrugs c.timew1w3##c.w1hei2010_total_scorecent43  c.timew1w3##c.w1BMIcent30 c.timew1w3##w1SRH c.timew1w3##c.w1CEScent15 c.timew1w3##w1dxHTN c.timew1w3##w1dxDiabetes c.timew1w3##w1CVhighChol c.timew1w3##w1cvdbr c.timew1w3##c.invmillsmms ///
c.timew1w3##c.w1HCYcenter2p15##c.w1B12center522   ///
if sample4aobs==1 || HNDID: timew1w3


mi estimate: mixed MMStotnorm  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat c.timew1w3##w1edubr c.timew1w3##c.w1WRATtotalcent42   ///
c.timew1w3##w1smoke  c.timew1w3##w1currdrugs c.timew1w3##c.w1hei2010_total_scorecent43  c.timew1w3##c.w1BMIcent30 c.timew1w3##w1SRH c.timew1w3##c.w1CEScent15 c.timew1w3##w1dxHTN c.timew1w3##w1dxDiabetes c.timew1w3##w1CVhighChol c.timew1w3##w1cvdbr c.timew1w3##c.invmillsmms ///
c.timew1w3##c.w1HCYcenter2p15##c.w1B12center522   ///
if sample4aobs==1 || HNDID: timew1w3



mi estimate: mixed cvltca  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat c.timew1w3##w1edubr c.timew1w3##c.w1WRATtotalcent42   ///
c.timew1w3##w1smoke  c.timew1w3##w1currdrugs c.timew1w3##c.w1hei2010_total_scorecent43  c.timew1w3##c.w1BMIcent30 c.timew1w3##w1SRH c.timew1w3##c.w1CEScent15 c.timew1w3##w1dxHTN c.timew1w3##w1dxDiabetes c.timew1w3##w1CVhighChol c.timew1w3##w1cvdbr c.timew1w3##c.invmillsmms ///
c.timew1w3##c.w1HCYcenter2p15##c.w1B12center522   ///
if sample4bobs==1 || HNDID: timew1w3



mi estimate: mixed CVLfrl  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat c.timew1w3##w1edubr c.timew1w3##c.w1WRATtotalcent42   ///
c.timew1w3##w1smoke  c.timew1w3##w1currdrugs c.timew1w3##c.w1hei2010_total_scorecent43  c.timew1w3##c.w1BMIcent30 c.timew1w3##w1SRH c.timew1w3##c.w1CEScent15 c.timew1w3##w1dxHTN c.timew1w3##w1dxDiabetes c.timew1w3##w1CVhighChol c.timew1w3##w1cvdbr c.timew1w3##c.invmillsmms ///
c.timew1w3##c.w1HCYcenter2p15##c.w1B12center522   ///
if sample4cobs==1 || HNDID: timew1w3



mi estimate: mixed BVRtot  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat c.timew1w3##w1edubr c.timew1w3##c.w1WRATtotalcent42   ///
c.timew1w3##w1smoke  c.timew1w3##w1currdrugs c.timew1w3##c.w1hei2010_total_scorecent43  c.timew1w3##c.w1BMIcent30 c.timew1w3##w1SRH c.timew1w3##c.w1CEScent15 c.timew1w3##w1dxHTN c.timew1w3##w1dxDiabetes c.timew1w3##w1CVhighChol c.timew1w3##w1cvdbr c.timew1w3##c.invmillsmms ///
c.timew1w3##c.w1HCYcenter2p15##c.w1B12center522   ///
if sample4dobs==1 || HNDID: timew1w3


mi estimate: mixed Attention  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat c.timew1w3##w1edubr c.timew1w3##c.w1WRATtotalcent42   ///
c.timew1w3##w1smoke  c.timew1w3##w1currdrugs c.timew1w3##c.w1hei2010_total_scorecent43  c.timew1w3##c.w1BMIcent30 c.timew1w3##w1SRH c.timew1w3##c.w1CEScent15 c.timew1w3##w1dxHTN c.timew1w3##w1dxDiabetes c.timew1w3##w1CVhighChol c.timew1w3##w1cvdbr c.timew1w3##c.invmillsmms ///
c.timew1w3##c.w1HCYcenter2p15##c.w1B12center522   ///
if sample4eobs==1 || HNDID: timew1w3

mi estimate: mixed FluencyWord  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat c.timew1w3##w1edubr c.timew1w3##c.w1WRATtotalcent42   ///
c.timew1w3##w1smoke  c.timew1w3##w1currdrugs c.timew1w3##c.w1hei2010_total_scorecent43  c.timew1w3##c.w1BMIcent30 c.timew1w3##w1SRH c.timew1w3##c.w1CEScent15 c.timew1w3##w1dxHTN c.timew1w3##w1dxDiabetes c.timew1w3##w1CVhighChol c.timew1w3##w1cvdbr c.timew1w3##c.invmillsmms ///
c.timew1w3##c.w1HCYcenter2p15##c.w1B12center522   ///
if sample4fobs==1 || HNDID: timew1w3

mi estimate: mixed DigitSpanFwd  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat c.timew1w3##w1edubr c.timew1w3##c.w1WRATtotalcent42   ///
c.timew1w3##w1smoke  c.timew1w3##w1currdrugs c.timew1w3##c.w1hei2010_total_scorecent43  c.timew1w3##c.w1BMIcent30 c.timew1w3##w1SRH c.timew1w3##c.w1CEScent15 c.timew1w3##w1dxHTN c.timew1w3##w1dxDiabetes c.timew1w3##w1CVhighChol c.timew1w3##w1cvdbr c.timew1w3##c.invmillsmms ///
c.timew1w3##c.w1HCYcenter2p15##c.w1B12center522   ///
if sample4gobs==1 || HNDID: timew1w3

mi estimate: mixed DigitSpanBck  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat c.timew1w3##w1edubr c.timew1w3##c.w1WRATtotalcent42   ///
c.timew1w3##w1smoke  c.timew1w3##w1currdrugs c.timew1w3##c.w1hei2010_total_scorecent43  c.timew1w3##c.w1BMIcent30 c.timew1w3##w1SRH c.timew1w3##c.w1CEScent15 c.timew1w3##w1dxHTN c.timew1w3##w1dxDiabetes c.timew1w3##w1CVhighChol c.timew1w3##w1cvdbr c.timew1w3##c.invmillsmms ///
c.timew1w3##c.w1HCYcenter2p15##c.w1B12center522   ///
if sample4hobs==1 || HNDID: timew1w3

mi estimate: mixed clock_command  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat c.timew1w3##w1edubr c.timew1w3##c.w1WRATtotalcent42   ///
c.timew1w3##w1smoke  c.timew1w3##w1currdrugs c.timew1w3##c.w1hei2010_total_scorecent43  c.timew1w3##c.w1BMIcent30 c.timew1w3##w1SRH c.timew1w3##c.w1CEScent15 c.timew1w3##w1dxHTN c.timew1w3##w1dxDiabetes c.timew1w3##w1CVhighChol c.timew1w3##w1cvdbr c.timew1w3##c.invmillsmms ///
c.timew1w3##c.w1HCYcenter2p15##c.w1B12center522   ///
if sample4iobs==1 || HNDID: timew1w3

mi estimate: mixed LnTrailsAtestSec  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat c.timew1w3##w1edubr c.timew1w3##c.w1WRATtotalcent42   ///
c.timew1w3##w1smoke  c.timew1w3##w1currdrugs c.timew1w3##c.w1hei2010_total_scorecent43  c.timew1w3##c.w1BMIcent30 c.timew1w3##w1SRH c.timew1w3##c.w1CEScent15 c.timew1w3##w1dxHTN c.timew1w3##w1dxDiabetes c.timew1w3##w1CVhighChol c.timew1w3##w1cvdbr c.timew1w3##c.invmillsmms ///
c.timew1w3##c.w1HCYcenter2p15##c.w1B12center522   ///
if sample4jobs==1 || HNDID: timew1w3

mi estimate: mixed LnTrailsBtestSec  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat c.timew1w3##w1edubr c.timew1w3##c.w1WRATtotalcent42   ///
c.timew1w3##w1smoke  c.timew1w3##w1currdrugs c.timew1w3##c.w1hei2010_total_scorecent43  c.timew1w3##c.w1BMIcent30 c.timew1w3##w1SRH c.timew1w3##c.w1CEScent15 c.timew1w3##w1dxHTN c.timew1w3##w1dxDiabetes c.timew1w3##w1CVhighChol c.timew1w3##w1cvdbr c.timew1w3##c.invmillsmms ///
c.timew1w3##c.w1HCYcenter2p15##c.w1B12center522   ///
if sample4kobs==1  || HNDID: timew1w3


save, replace




capture log close

log using "E:\HANDLS_PAPER65_HCY_COGN\OUTPUT\TABLES3.smcl", replace

use finaldata_imputed_FINAL,clear


************************************INTERACTION WITH FOLATE AND B12: BASELINE HCY************************************************************



*******************************TABLE S1: HOMOCYSTEINE AT BASELINE VS. COGNITIVE CHANGE OVER TIME: INTERACTION BY FOL**************************************


//MODEL 1: INCLUDE ONLY AGE, SEX, RACE AND POVERTY STATUS///
mi estimate: mixed MMStot  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat  c.timew1w3##c.invmillsmms ///
c.timew1w3##c.zw1w3HCYTRAJ##c.w1Folatecenter14p3   ///
if sample4aobs==1 || HNDID: timew1w3


mi estimate: mixed MMStotnorm  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat  c.timew1w3##c.invmillsmms ///
c.timew1w3##c.zw1w3HCYTRAJ##c.w1Folatecenter14p3   ///
if sample4aobs==1 || HNDID: timew1w3



mi estimate: mixed cvltca  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat  c.timew1w3##c.invmillsmms ///
c.timew1w3##c.zw1w3HCYTRAJ##c.w1Folatecenter14p3   ///
if sample4bobs==1 || HNDID: timew1w3



mi estimate: mixed CVLfrl  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat  c.timew1w3##c.invmillsmms ///
c.timew1w3##c.zw1w3HCYTRAJ##c.w1Folatecenter14p3   ///
if sample4cobs==1 || HNDID: 



mi estimate: mixed BVRtot  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat  c.timew1w3##c.invmillsmms ///
c.timew1w3##c.zw1w3HCYTRAJ##c.w1Folatecenter14p3   ///
if sample4dobs==1 || HNDID: timew1w3


mi estimate: mixed Attention  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat  c.timew1w3##c.invmillsmms ///
c.timew1w3##c.zw1w3HCYTRAJ##c.w1Folatecenter14p3   ///
if sample4eobs==1 || HNDID: timew1w3

mi estimate: mixed FluencyWord  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat  c.timew1w3##c.invmillsmms ///
c.timew1w3##c.zw1w3HCYTRAJ##c.w1Folatecenter14p3   ///
if sample4fobs==1 || HNDID: timew1w3

mi estimate: mixed DigitSpanFwd  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat  c.timew1w3##c.invmillsmms ///
c.timew1w3##c.zw1w3HCYTRAJ##c.w1Folatecenter14p3   ///
if sample4gobs==1 || HNDID: timew1w3

mi estimate: mixed DigitSpanBck  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat  c.timew1w3##c.invmillsmms ///
c.timew1w3##c.zw1w3HCYTRAJ##c.w1Folatecenter14p3   ///
if sample4hobs==1 || HNDID: timew1w3

mi estimate: mixed clock_command  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat  c.timew1w3##c.invmillsmms ///
c.timew1w3##c.zw1w3HCYTRAJ##c.w1Folatecenter14p3   ///
if sample4iobs==1 || HNDID: timew1w3

mi estimate: mixed LnTrailsAtestSec  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat  c.timew1w3##c.invmillsmms ///
c.timew1w3##c.zw1w3HCYTRAJ##c.w1Folatecenter14p3   ///
if sample4jobs==1 || HNDID: timew1w3

mi estimate: mixed LnTrailsBtestSec  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat  c.timew1w3##c.invmillsmms ///
c.timew1w3##c.zw1w3HCYTRAJ##c.w1Folatecenter14p3   ///
if sample4kobs==1  || HNDID: timew1w3


save, replace


//MODEL 2: MODEL 1 + OTHER FACTORS + BODY MASS INDEX///

mi estimate: mixed MMStot  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat c.timew1w3##w1edubr c.timew1w3##c.w1WRATtotalcent42   ///
c.timew1w3##w1smoke  c.timew1w3##w1currdrugs c.timew1w3##c.w1hei2010_total_scorecent43  c.timew1w3##c.w1BMIcent30  c.timew1w3##c.invmillsmms ///
c.timew1w3##c.zw1w3HCYTRAJ##c.w1Folatecenter14p3   ///
if sample4aobs==1 || HNDID: timew1w3


mi estimate: mixed MMStotnorm  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat c.timew1w3##w1edubr c.timew1w3##c.w1WRATtotalcent42   ///
c.timew1w3##w1smoke  c.timew1w3##w1currdrugs c.timew1w3##c.w1hei2010_total_scorecent43  c.timew1w3##c.w1BMIcent30  c.timew1w3##c.invmillsmms ///
c.timew1w3##c.zw1w3HCYTRAJ##c.w1Folatecenter14p3   ///
if sample4aobs==1 || HNDID: timew1w3



mi estimate: mixed cvltca  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat c.timew1w3##w1edubr c.timew1w3##c.w1WRATtotalcent42   ///
c.timew1w3##w1smoke  c.timew1w3##w1currdrugs c.timew1w3##c.w1hei2010_total_scorecent43  c.timew1w3##c.w1BMIcent30  c.timew1w3##c.invmillsmms ///
c.timew1w3##c.zw1w3HCYTRAJ##c.w1Folatecenter14p3   ///
if sample4bobs==1 || HNDID: timew1w3



mi estimate: mixed CVLfrl  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat c.timew1w3##w1edubr c.timew1w3##c.w1WRATtotalcent42   ///
c.timew1w3##w1smoke  c.timew1w3##w1currdrugs c.timew1w3##c.w1hei2010_total_scorecent43  c.timew1w3##c.w1BMIcent30  c.timew1w3##c.invmillsmms ///
c.timew1w3##c.zw1w3HCYTRAJ##c.w1Folatecenter14p3   ///
if sample4cobs==1 || HNDID: timew1w3



mi estimate: mixed BVRtot  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat c.timew1w3##w1edubr c.timew1w3##c.w1WRATtotalcent42   ///
c.timew1w3##w1smoke  c.timew1w3##w1currdrugs c.timew1w3##c.w1hei2010_total_scorecent43  c.timew1w3##c.w1BMIcent30  c.timew1w3##c.invmillsmms ///
c.timew1w3##c.zw1w3HCYTRAJ##c.w1Folatecenter14p3   ///
if sample4dobs==1 || HNDID: timew1w3


mi estimate: mixed Attention  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat c.timew1w3##w1edubr c.timew1w3##c.w1WRATtotalcent42   ///
c.timew1w3##w1smoke  c.timew1w3##w1currdrugs c.timew1w3##c.w1hei2010_total_scorecent43  c.timew1w3##c.w1BMIcent30  c.timew1w3##c.invmillsmms ///
c.timew1w3##c.zw1w3HCYTRAJ##c.w1Folatecenter14p3   ///
if sample4eobs==1 || HNDID: timew1w3

mi estimate: mixed FluencyWord  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat c.timew1w3##w1edubr c.timew1w3##c.w1WRATtotalcent42   ///
c.timew1w3##w1smoke  c.timew1w3##w1currdrugs c.timew1w3##c.w1hei2010_total_scorecent43  c.timew1w3##c.w1BMIcent30  c.timew1w3##c.invmillsmms ///
c.timew1w3##c.zw1w3HCYTRAJ##c.w1Folatecenter14p3   ///
if sample4fobs==1 || HNDID: timew1w3

mi estimate: mixed DigitSpanFwd  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat c.timew1w3##w1edubr c.timew1w3##c.w1WRATtotalcent42   ///
c.timew1w3##w1smoke  c.timew1w3##w1currdrugs c.timew1w3##c.w1hei2010_total_scorecent43  c.timew1w3##c.w1BMIcent30  c.timew1w3##c.invmillsmms ///
c.timew1w3##c.zw1w3HCYTRAJ##c.w1Folatecenter14p3   ///
if sample4gobs==1 || HNDID: timew1w3

mi estimate: mixed DigitSpanBck  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat c.timew1w3##w1edubr c.timew1w3##c.w1WRATtotalcent42   ///
c.timew1w3##w1smoke  c.timew1w3##w1currdrugs c.timew1w3##c.w1hei2010_total_scorecent43  c.timew1w3##c.w1BMIcent30 c.timew1w3##c.invmillsmms ///
c.timew1w3##c.zw1w3HCYTRAJ##c.w1Folatecenter14p3   ///
if sample4hobs==1 || HNDID: timew1w3

mi estimate: mixed clock_command  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat c.timew1w3##w1edubr c.timew1w3##c.w1WRATtotalcent42   ///
c.timew1w3##w1smoke  c.timew1w3##w1currdrugs c.timew1w3##c.w1hei2010_total_scorecent43  c.timew1w3##c.w1BMIcent30  c.timew1w3##c.invmillsmms ///
c.timew1w3##c.zw1w3HCYTRAJ##c.w1Folatecenter14p3   ///
if sample4iobs==1 || HNDID: timew1w3

mi estimate: mixed LnTrailsAtestSec  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat c.timew1w3##w1edubr c.timew1w3##c.w1WRATtotalcent42   ///
c.timew1w3##w1smoke  c.timew1w3##w1currdrugs c.timew1w3##c.w1hei2010_total_scorecent43  c.timew1w3##c.w1BMIcent30  c.timew1w3##c.invmillsmms ///
c.timew1w3##c.zw1w3HCYTRAJ##c.w1Folatecenter14p3   ///
if sample4jobs==1 || HNDID: timew1w3

mi estimate: mixed LnTrailsBtestSec  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat c.timew1w3##w1edubr c.timew1w3##c.w1WRATtotalcent42   ///
c.timew1w3##w1smoke  c.timew1w3##w1currdrugs c.timew1w3##c.w1hei2010_total_scorecent43  c.timew1w3##c.w1BMIcent30  c.timew1w3##c.invmillsmms ///
c.timew1w3##c.zw1w3HCYTRAJ##c.w1Folatecenter14p3   ///
if sample4kobs==1  || HNDID: timew1w3


save, replace


//MODEL 3: FULLY ADJUSTED MODEL: MODEL 2 + HEALTH-RELATED FACTORS///

mi estimate: mixed MMStot  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat c.timew1w3##w1edubr c.timew1w3##c.w1WRATtotalcent42   ///
c.timew1w3##w1smoke  c.timew1w3##w1currdrugs c.timew1w3##c.w1hei2010_total_scorecent43  c.timew1w3##c.w1BMIcent30 c.timew1w3##w1SRH c.timew1w3##c.w1CEScent15 c.timew1w3##w1dxHTN c.timew1w3##w1dxDiabetes c.timew1w3##w1CVhighChol c.timew1w3##w1cvdbr c.timew1w3##c.invmillsmms ///
c.timew1w3##c.zw1w3HCYTRAJ##c.w1Folatecenter14p3   ///
if sample4aobs==1 || HNDID: timew1w3


mi estimate: mixed MMStotnorm  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat c.timew1w3##w1edubr c.timew1w3##c.w1WRATtotalcent42   ///
c.timew1w3##w1smoke  c.timew1w3##w1currdrugs c.timew1w3##c.w1hei2010_total_scorecent43  c.timew1w3##c.w1BMIcent30 c.timew1w3##w1SRH c.timew1w3##c.w1CEScent15 c.timew1w3##w1dxHTN c.timew1w3##w1dxDiabetes c.timew1w3##w1CVhighChol c.timew1w3##w1cvdbr c.timew1w3##c.invmillsmms ///
c.timew1w3##c.zw1w3HCYTRAJ##c.w1Folatecenter14p3   ///
if sample4aobs==1 || HNDID: timew1w3



mi estimate: mixed cvltca  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat c.timew1w3##w1edubr c.timew1w3##c.w1WRATtotalcent42   ///
c.timew1w3##w1smoke  c.timew1w3##w1currdrugs c.timew1w3##c.w1hei2010_total_scorecent43  c.timew1w3##c.w1BMIcent30 c.timew1w3##w1SRH c.timew1w3##c.w1CEScent15 c.timew1w3##w1dxHTN c.timew1w3##w1dxDiabetes c.timew1w3##w1CVhighChol c.timew1w3##w1cvdbr c.timew1w3##c.invmillsmms ///
c.timew1w3##c.zw1w3HCYTRAJ##c.w1Folatecenter14p3   ///
if sample4bobs==1 || HNDID: timew1w3



mi estimate: mixed CVLfrl  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat c.timew1w3##w1edubr c.timew1w3##c.w1WRATtotalcent42   ///
c.timew1w3##w1smoke  c.timew1w3##w1currdrugs c.timew1w3##c.w1hei2010_total_scorecent43  c.timew1w3##c.w1BMIcent30 c.timew1w3##w1SRH c.timew1w3##c.w1CEScent15 c.timew1w3##w1dxHTN c.timew1w3##w1dxDiabetes c.timew1w3##w1CVhighChol c.timew1w3##w1cvdbr c.timew1w3##c.invmillsmms ///
c.timew1w3##c.zw1w3HCYTRAJ##c.w1Folatecenter14p3   ///
if sample4cobs==1 || HNDID: timew1w3



mi estimate: mixed BVRtot  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat c.timew1w3##w1edubr c.timew1w3##c.w1WRATtotalcent42   ///
c.timew1w3##w1smoke  c.timew1w3##w1currdrugs c.timew1w3##c.w1hei2010_total_scorecent43  c.timew1w3##c.w1BMIcent30 c.timew1w3##w1SRH c.timew1w3##c.w1CEScent15 c.timew1w3##w1dxHTN c.timew1w3##w1dxDiabetes c.timew1w3##w1CVhighChol c.timew1w3##w1cvdbr c.timew1w3##c.invmillsmms ///
c.timew1w3##c.zw1w3HCYTRAJ##c.w1Folatecenter14p3   ///
if sample4dobs==1 || HNDID: timew1w3


mi estimate: mixed Attention  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat c.timew1w3##w1edubr c.timew1w3##c.w1WRATtotalcent42   ///
c.timew1w3##w1smoke  c.timew1w3##w1currdrugs c.timew1w3##c.w1hei2010_total_scorecent43  c.timew1w3##c.w1BMIcent30 c.timew1w3##w1SRH c.timew1w3##c.w1CEScent15 c.timew1w3##w1dxHTN c.timew1w3##w1dxDiabetes c.timew1w3##w1CVhighChol c.timew1w3##w1cvdbr c.timew1w3##c.invmillsmms ///
c.timew1w3##c.zw1w3HCYTRAJ##c.w1Folatecenter14p3   ///
if sample4eobs==1 || HNDID: timew1w3

mi estimate: mixed FluencyWord  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat c.timew1w3##w1edubr c.timew1w3##c.w1WRATtotalcent42   ///
c.timew1w3##w1smoke  c.timew1w3##w1currdrugs c.timew1w3##c.w1hei2010_total_scorecent43  c.timew1w3##c.w1BMIcent30 c.timew1w3##w1SRH c.timew1w3##c.w1CEScent15 c.timew1w3##w1dxHTN c.timew1w3##w1dxDiabetes c.timew1w3##w1CVhighChol c.timew1w3##w1cvdbr c.timew1w3##c.invmillsmms ///
c.timew1w3##c.zw1w3HCYTRAJ##c.w1Folatecenter14p3   ///
if sample4fobs==1 || HNDID: timew1w3

mi estimate: mixed DigitSpanFwd  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat c.timew1w3##w1edubr c.timew1w3##c.w1WRATtotalcent42   ///
c.timew1w3##w1smoke  c.timew1w3##w1currdrugs c.timew1w3##c.w1hei2010_total_scorecent43  c.timew1w3##c.w1BMIcent30 c.timew1w3##w1SRH c.timew1w3##c.w1CEScent15 c.timew1w3##w1dxHTN c.timew1w3##w1dxDiabetes c.timew1w3##w1CVhighChol c.timew1w3##w1cvdbr c.timew1w3##c.invmillsmms ///
c.timew1w3##c.zw1w3HCYTRAJ##c.w1Folatecenter14p3   ///
if sample4gobs==1 || HNDID: timew1w3

mi estimate: mixed DigitSpanBck  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat c.timew1w3##w1edubr c.timew1w3##c.w1WRATtotalcent42   ///
c.timew1w3##w1smoke  c.timew1w3##w1currdrugs c.timew1w3##c.w1hei2010_total_scorecent43  c.timew1w3##c.w1BMIcent30 c.timew1w3##w1SRH c.timew1w3##c.w1CEScent15 c.timew1w3##w1dxHTN c.timew1w3##w1dxDiabetes c.timew1w3##w1CVhighChol c.timew1w3##w1cvdbr c.timew1w3##c.invmillsmms ///
c.timew1w3##c.zw1w3HCYTRAJ##c.w1Folatecenter14p3   ///
if sample4hobs==1 || HNDID: timew1w3

mi estimate: mixed clock_command  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat c.timew1w3##w1edubr c.timew1w3##c.w1WRATtotalcent42   ///
c.timew1w3##w1smoke  c.timew1w3##w1currdrugs c.timew1w3##c.w1hei2010_total_scorecent43  c.timew1w3##c.w1BMIcent30 c.timew1w3##w1SRH c.timew1w3##c.w1CEScent15 c.timew1w3##w1dxHTN c.timew1w3##w1dxDiabetes c.timew1w3##w1CVhighChol c.timew1w3##w1cvdbr c.timew1w3##c.invmillsmms ///
c.timew1w3##c.zw1w3HCYTRAJ##c.w1Folatecenter14p3   ///
if sample4iobs==1 || HNDID: timew1w3

mi estimate: mixed LnTrailsAtestSec  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat c.timew1w3##w1edubr c.timew1w3##c.w1WRATtotalcent42   ///
c.timew1w3##w1smoke  c.timew1w3##w1currdrugs c.timew1w3##c.w1hei2010_total_scorecent43  c.timew1w3##c.w1BMIcent30 c.timew1w3##w1SRH c.timew1w3##c.w1CEScent15 c.timew1w3##w1dxHTN c.timew1w3##w1dxDiabetes c.timew1w3##w1CVhighChol c.timew1w3##w1cvdbr c.timew1w3##c.invmillsmms ///
c.timew1w3##c.zw1w3HCYTRAJ##c.w1Folatecenter14p3   ///
if sample4jobs==1 || HNDID: timew1w3

mi estimate: mixed LnTrailsBtestSec  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat c.timew1w3##w1edubr c.timew1w3##c.w1WRATtotalcent42   ///
c.timew1w3##w1smoke  c.timew1w3##w1currdrugs c.timew1w3##c.w1hei2010_total_scorecent43  c.timew1w3##c.w1BMIcent30 c.timew1w3##w1SRH c.timew1w3##c.w1CEScent15 c.timew1w3##w1dxHTN c.timew1w3##w1dxDiabetes c.timew1w3##w1CVhighChol c.timew1w3##w1cvdbr c.timew1w3##c.invmillsmms ///
c.timew1w3##c.zw1w3HCYTRAJ##c.w1Folatecenter14p3   ///
if sample4kobs==1  || HNDID: timew1w3


save, replace




*******************************TABLE S1: HOMOCYSTEINE AT BASELINE VS. COGNITIVE CHANGE OVER TIME: INTERACTION BY B12**************************************


//MODEL 1: INCLUDE ONLY AGE, SEX, RACE AND POVERTY STATUS///
mi estimate: mixed MMStot  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat  c.timew1w3##c.invmillsmms ///
c.timew1w3##c.zw1w3HCYTRAJ##c.w1B12center522   ///
if sample4aobs==1 || HNDID: timew1w3


mi estimate: mixed MMStotnorm  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat  c.timew1w3##c.invmillsmms ///
c.timew1w3##c.zw1w3HCYTRAJ##c.w1B12center522   ///
if sample4aobs==1 || HNDID: timew1w3



mi estimate: mixed cvltca  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat  c.timew1w3##c.invmillsmms ///
c.timew1w3##c.zw1w3HCYTRAJ##c.w1B12center522   ///
if sample4bobs==1 || HNDID: timew1w3



mi estimate: mixed CVLfrl  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat  c.timew1w3##c.invmillsmms ///
c.timew1w3##c.zw1w3HCYTRAJ##c.w1B12center522   ///
if sample4cobs==1 || HNDID: 



mi estimate: mixed BVRtot  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat  c.timew1w3##c.invmillsmms ///
c.timew1w3##c.zw1w3HCYTRAJ##c.w1B12center522   ///
if sample4dobs==1 || HNDID: timew1w3


mi estimate: mixed Attention  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat  c.timew1w3##c.invmillsmms ///
c.timew1w3##c.zw1w3HCYTRAJ##c.w1B12center522   ///
if sample4eobs==1 || HNDID: timew1w3

mi estimate: mixed FluencyWord  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat  c.timew1w3##c.invmillsmms ///
c.timew1w3##c.zw1w3HCYTRAJ##c.w1B12center522   ///
if sample4fobs==1 || HNDID:

mi estimate: mixed DigitSpanFwd  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat  c.timew1w3##c.invmillsmms ///
c.timew1w3##c.zw1w3HCYTRAJ##c.w1B12center522   ///
if sample4gobs==1 || HNDID: timew1w3

mi estimate: mixed DigitSpanBck  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat  c.timew1w3##c.invmillsmms ///
c.timew1w3##c.zw1w3HCYTRAJ##c.w1B12center522   ///
if sample4hobs==1 || HNDID: timew1w3

mi estimate: mixed clock_command  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat  c.timew1w3##c.invmillsmms ///
c.timew1w3##c.zw1w3HCYTRAJ##c.w1B12center522   ///
if sample4iobs==1 || HNDID: timew1w3

mi estimate: mixed LnTrailsAtestSec  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat  c.timew1w3##c.invmillsmms ///
c.timew1w3##c.zw1w3HCYTRAJ##c.w1B12center522   ///
if sample4jobs==1 || HNDID: timew1w3

mi estimate: mixed LnTrailsBtestSec  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat  c.timew1w3##c.invmillsmms ///
c.timew1w3##c.zw1w3HCYTRAJ##c.w1B12center522   ///
if sample4kobs==1  || HNDID: timew1w3


save, replace


//MODEL 2: MODEL 1 + OTHER FACTORS + BODY MASS INDEX///

mi estimate: mixed MMStot  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat c.timew1w3##w1edubr c.timew1w3##c.w1WRATtotalcent42   ///
c.timew1w3##w1smoke  c.timew1w3##w1currdrugs c.timew1w3##c.w1hei2010_total_scorecent43  c.timew1w3##c.w1BMIcent30  c.timew1w3##c.invmillsmms ///
c.timew1w3##c.zw1w3HCYTRAJ##c.w1B12center522   ///
if sample4aobs==1 || HNDID: timew1w3


mi estimate: mixed MMStotnorm  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat c.timew1w3##w1edubr c.timew1w3##c.w1WRATtotalcent42   ///
c.timew1w3##w1smoke  c.timew1w3##w1currdrugs c.timew1w3##c.w1hei2010_total_scorecent43  c.timew1w3##c.w1BMIcent30  c.timew1w3##c.invmillsmms ///
c.timew1w3##c.zw1w3HCYTRAJ##c.w1B12center522   ///
if sample4aobs==1 || HNDID: timew1w3



mi estimate: mixed cvltca  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat c.timew1w3##w1edubr c.timew1w3##c.w1WRATtotalcent42   ///
c.timew1w3##w1smoke  c.timew1w3##w1currdrugs c.timew1w3##c.w1hei2010_total_scorecent43  c.timew1w3##c.w1BMIcent30  c.timew1w3##c.invmillsmms ///
c.timew1w3##c.zw1w3HCYTRAJ##c.w1B12center522   ///
if sample4bobs==1 || HNDID: timew1w3



mi estimate: mixed CVLfrl  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat c.timew1w3##w1edubr c.timew1w3##c.w1WRATtotalcent42   ///
c.timew1w3##w1smoke  c.timew1w3##w1currdrugs c.timew1w3##c.w1hei2010_total_scorecent43  c.timew1w3##c.w1BMIcent30  c.timew1w3##c.invmillsmms ///
c.timew1w3##c.zw1w3HCYTRAJ##c.w1B12center522   ///
if sample4cobs==1 || HNDID: timew1w3



mi estimate: mixed BVRtot  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat c.timew1w3##w1edubr c.timew1w3##c.w1WRATtotalcent42   ///
c.timew1w3##w1smoke  c.timew1w3##w1currdrugs c.timew1w3##c.w1hei2010_total_scorecent43  c.timew1w3##c.w1BMIcent30  c.timew1w3##c.invmillsmms ///
c.timew1w3##c.zw1w3HCYTRAJ##c.w1B12center522   ///
if sample4dobs==1 || HNDID: timew1w3


mi estimate: mixed Attention  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat c.timew1w3##w1edubr c.timew1w3##c.w1WRATtotalcent42   ///
c.timew1w3##w1smoke  c.timew1w3##w1currdrugs c.timew1w3##c.w1hei2010_total_scorecent43  c.timew1w3##c.w1BMIcent30  c.timew1w3##c.invmillsmms ///
c.timew1w3##c.zw1w3HCYTRAJ##c.w1B12center522   ///
if sample4eobs==1 || HNDID: timew1w3

mi estimate: mixed FluencyWord  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat c.timew1w3##w1edubr c.timew1w3##c.w1WRATtotalcent42   ///
c.timew1w3##w1smoke  c.timew1w3##w1currdrugs c.timew1w3##c.w1hei2010_total_scorecent43  c.timew1w3##c.w1BMIcent30  c.timew1w3##c.invmillsmms ///
c.timew1w3##c.zw1w3HCYTRAJ##c.w1B12center522   ///
if sample4fobs==1 || HNDID: timew1w3

mi estimate: mixed DigitSpanFwd  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat c.timew1w3##w1edubr c.timew1w3##c.w1WRATtotalcent42   ///
c.timew1w3##w1smoke  c.timew1w3##w1currdrugs c.timew1w3##c.w1hei2010_total_scorecent43  c.timew1w3##c.w1BMIcent30  c.timew1w3##c.invmillsmms ///
c.timew1w3##c.zw1w3HCYTRAJ##c.w1B12center522   ///
if sample4gobs==1 || HNDID: timew1w3

mi estimate: mixed DigitSpanBck  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat c.timew1w3##w1edubr c.timew1w3##c.w1WRATtotalcent42   ///
c.timew1w3##w1smoke  c.timew1w3##w1currdrugs c.timew1w3##c.w1hei2010_total_scorecent43  c.timew1w3##c.w1BMIcent30 c.timew1w3##c.invmillsmms ///
c.timew1w3##c.zw1w3HCYTRAJ##c.w1B12center522   ///
if sample4hobs==1 || HNDID: timew1w3

mi estimate: mixed clock_command  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat c.timew1w3##w1edubr c.timew1w3##c.w1WRATtotalcent42   ///
c.timew1w3##w1smoke  c.timew1w3##w1currdrugs c.timew1w3##c.w1hei2010_total_scorecent43  c.timew1w3##c.w1BMIcent30  c.timew1w3##c.invmillsmms ///
c.timew1w3##c.zw1w3HCYTRAJ##c.w1B12center522   ///
if sample4iobs==1 || HNDID: timew1w3

mi estimate: mixed LnTrailsAtestSec  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat c.timew1w3##w1edubr c.timew1w3##c.w1WRATtotalcent42   ///
c.timew1w3##w1smoke  c.timew1w3##w1currdrugs c.timew1w3##c.w1hei2010_total_scorecent43  c.timew1w3##c.w1BMIcent30  c.timew1w3##c.invmillsmms ///
c.timew1w3##c.zw1w3HCYTRAJ##c.w1B12center522   ///
if sample4jobs==1 || HNDID: timew1w3

mi estimate: mixed LnTrailsBtestSec  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat c.timew1w3##w1edubr c.timew1w3##c.w1WRATtotalcent42   ///
c.timew1w3##w1smoke  c.timew1w3##w1currdrugs c.timew1w3##c.w1hei2010_total_scorecent43  c.timew1w3##c.w1BMIcent30  c.timew1w3##c.invmillsmms ///
c.timew1w3##c.zw1w3HCYTRAJ##c.w1B12center522   ///
if sample4kobs==1  || HNDID: timew1w3


save, replace


//MODEL 3: FULLY ADJUSTED MODEL: MODEL 2 + HEALTH-RELATED FACTORS///

mi estimate: mixed MMStot  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat c.timew1w3##w1edubr c.timew1w3##c.w1WRATtotalcent42   ///
c.timew1w3##w1smoke  c.timew1w3##w1currdrugs c.timew1w3##c.w1hei2010_total_scorecent43  c.timew1w3##c.w1BMIcent30 c.timew1w3##w1SRH c.timew1w3##c.w1CEScent15 c.timew1w3##w1dxHTN c.timew1w3##w1dxDiabetes c.timew1w3##w1CVhighChol c.timew1w3##w1cvdbr c.timew1w3##c.invmillsmms ///
c.timew1w3##c.zw1w3HCYTRAJ##c.w1B12center522   ///
if sample4aobs==1 || HNDID: timew1w3


mi estimate: mixed MMStotnorm  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat c.timew1w3##w1edubr c.timew1w3##c.w1WRATtotalcent42   ///
c.timew1w3##w1smoke  c.timew1w3##w1currdrugs c.timew1w3##c.w1hei2010_total_scorecent43  c.timew1w3##c.w1BMIcent30 c.timew1w3##w1SRH c.timew1w3##c.w1CEScent15 c.timew1w3##w1dxHTN c.timew1w3##w1dxDiabetes c.timew1w3##w1CVhighChol c.timew1w3##w1cvdbr c.timew1w3##c.invmillsmms ///
c.timew1w3##c.zw1w3HCYTRAJ##c.w1B12center522   ///
if sample4aobs==1 || HNDID: timew1w3



mi estimate: mixed cvltca  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat c.timew1w3##w1edubr c.timew1w3##c.w1WRATtotalcent42   ///
c.timew1w3##w1smoke  c.timew1w3##w1currdrugs c.timew1w3##c.w1hei2010_total_scorecent43  c.timew1w3##c.w1BMIcent30 c.timew1w3##w1SRH c.timew1w3##c.w1CEScent15 c.timew1w3##w1dxHTN c.timew1w3##w1dxDiabetes c.timew1w3##w1CVhighChol c.timew1w3##w1cvdbr c.timew1w3##c.invmillsmms ///
c.timew1w3##c.zw1w3HCYTRAJ##c.w1B12center522   ///
if sample4bobs==1 || HNDID: timew1w3



mi estimate: mixed CVLfrl  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat c.timew1w3##w1edubr c.timew1w3##c.w1WRATtotalcent42   ///
c.timew1w3##w1smoke  c.timew1w3##w1currdrugs c.timew1w3##c.w1hei2010_total_scorecent43  c.timew1w3##c.w1BMIcent30 c.timew1w3##w1SRH c.timew1w3##c.w1CEScent15 c.timew1w3##w1dxHTN c.timew1w3##w1dxDiabetes c.timew1w3##w1CVhighChol c.timew1w3##w1cvdbr c.timew1w3##c.invmillsmms ///
c.timew1w3##c.zw1w3HCYTRAJ##c.w1B12center522   ///
if sample4cobs==1 || HNDID: timew1w3



mi estimate: mixed BVRtot  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat c.timew1w3##w1edubr c.timew1w3##c.w1WRATtotalcent42   ///
c.timew1w3##w1smoke  c.timew1w3##w1currdrugs c.timew1w3##c.w1hei2010_total_scorecent43  c.timew1w3##c.w1BMIcent30 c.timew1w3##w1SRH c.timew1w3##c.w1CEScent15 c.timew1w3##w1dxHTN c.timew1w3##w1dxDiabetes c.timew1w3##w1CVhighChol c.timew1w3##w1cvdbr c.timew1w3##c.invmillsmms ///
c.timew1w3##c.zw1w3HCYTRAJ##c.w1B12center522   ///
if sample4dobs==1 || HNDID: timew1w3


mi estimate: mixed Attention  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat c.timew1w3##w1edubr c.timew1w3##c.w1WRATtotalcent42   ///
c.timew1w3##w1smoke  c.timew1w3##w1currdrugs c.timew1w3##c.w1hei2010_total_scorecent43  c.timew1w3##c.w1BMIcent30 c.timew1w3##w1SRH c.timew1w3##c.w1CEScent15 c.timew1w3##w1dxHTN c.timew1w3##w1dxDiabetes c.timew1w3##w1CVhighChol c.timew1w3##w1cvdbr c.timew1w3##c.invmillsmms ///
c.timew1w3##c.zw1w3HCYTRAJ##c.w1B12center522   ///
if sample4eobs==1 || HNDID: timew1w3

mi estimate: mixed FluencyWord  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat c.timew1w3##w1edubr c.timew1w3##c.w1WRATtotalcent42   ///
c.timew1w3##w1smoke  c.timew1w3##w1currdrugs c.timew1w3##c.w1hei2010_total_scorecent43  c.timew1w3##c.w1BMIcent30 c.timew1w3##w1SRH c.timew1w3##c.w1CEScent15 c.timew1w3##w1dxHTN c.timew1w3##w1dxDiabetes c.timew1w3##w1CVhighChol c.timew1w3##w1cvdbr c.timew1w3##c.invmillsmms ///
c.timew1w3##c.zw1w3HCYTRAJ##c.w1B12center522   ///
if sample4fobs==1 || HNDID: timew1w3

mi estimate: mixed DigitSpanFwd  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat c.timew1w3##w1edubr c.timew1w3##c.w1WRATtotalcent42   ///
c.timew1w3##w1smoke  c.timew1w3##w1currdrugs c.timew1w3##c.w1hei2010_total_scorecent43  c.timew1w3##c.w1BMIcent30 c.timew1w3##w1SRH c.timew1w3##c.w1CEScent15 c.timew1w3##w1dxHTN c.timew1w3##w1dxDiabetes c.timew1w3##w1CVhighChol c.timew1w3##w1cvdbr c.timew1w3##c.invmillsmms ///
c.timew1w3##c.zw1w3HCYTRAJ##c.w1B12center522   ///
if sample4gobs==1 || HNDID: timew1w3

mi estimate: mixed DigitSpanBck  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat c.timew1w3##w1edubr c.timew1w3##c.w1WRATtotalcent42   ///
c.timew1w3##w1smoke  c.timew1w3##w1currdrugs c.timew1w3##c.w1hei2010_total_scorecent43  c.timew1w3##c.w1BMIcent30 c.timew1w3##w1SRH c.timew1w3##c.w1CEScent15 c.timew1w3##w1dxHTN c.timew1w3##w1dxDiabetes c.timew1w3##w1CVhighChol c.timew1w3##w1cvdbr c.timew1w3##c.invmillsmms ///
c.timew1w3##c.zw1w3HCYTRAJ##c.w1B12center522   ///
if sample4hobs==1 || HNDID: timew1w3

mi estimate: mixed clock_command  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat c.timew1w3##w1edubr c.timew1w3##c.w1WRATtotalcent42   ///
c.timew1w3##w1smoke  c.timew1w3##w1currdrugs c.timew1w3##c.w1hei2010_total_scorecent43  c.timew1w3##c.w1BMIcent30 c.timew1w3##w1SRH c.timew1w3##c.w1CEScent15 c.timew1w3##w1dxHTN c.timew1w3##w1dxDiabetes c.timew1w3##w1CVhighChol c.timew1w3##w1cvdbr c.timew1w3##c.invmillsmms ///
c.timew1w3##c.zw1w3HCYTRAJ##c.w1B12center522   ///
if sample4iobs==1 || HNDID: timew1w3

mi estimate: mixed LnTrailsAtestSec  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat c.timew1w3##w1edubr c.timew1w3##c.w1WRATtotalcent42   ///
c.timew1w3##w1smoke  c.timew1w3##w1currdrugs c.timew1w3##c.w1hei2010_total_scorecent43  c.timew1w3##c.w1BMIcent30 c.timew1w3##w1SRH c.timew1w3##c.w1CEScent15 c.timew1w3##w1dxHTN c.timew1w3##w1dxDiabetes c.timew1w3##w1CVhighChol c.timew1w3##w1cvdbr c.timew1w3##c.invmillsmms ///
c.timew1w3##c.zw1w3HCYTRAJ##c.w1B12center522   ///
if sample4jobs==1 || HNDID: timew1w3

mi estimate: mixed LnTrailsBtestSec  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat c.timew1w3##w1edubr c.timew1w3##c.w1WRATtotalcent42   ///
c.timew1w3##w1smoke  c.timew1w3##w1currdrugs c.timew1w3##c.w1hei2010_total_scorecent43  c.timew1w3##c.w1BMIcent30 c.timew1w3##w1SRH c.timew1w3##c.w1CEScent15 c.timew1w3##w1dxHTN c.timew1w3##w1dxDiabetes c.timew1w3##w1CVhighChol c.timew1w3##w1cvdbr c.timew1w3##c.invmillsmms ///
c.timew1w3##c.zw1w3HCYTRAJ##c.w1B12center522   ///
if sample4kobs==1  || HNDID: timew1w3


save, replace




capture log close
cd "E:\HANDLS_PAPER65_HCY_COGN\DATA\"

log using "E:\HANDLS_PAPER65_HCY_COGN\OUTPUT\FIGURE3.smcl", replace


//////////////////////////////////////FIGURE 4: HCY AT V1 VS. CES-D, TOTAL POPULATION///////////////////////



use finaldata_imputed_FINAL, clear


mi extract 1
save final_imputed_one, replace


mixed LnTrailsAtestSec  c.timew1w3##c.w1Agecent48 c.timew1w3##Sex c.timew1w3##Race  c.timew1w3##PovStat  c.timew1w3##c.invmillsmms ///
c.timew1w3##c.w1HCYcenter2p15   ///
if sample4jobs==1 || HNDID: timew1w3

margins, at(c.timew1w3=(0(1)8) c.w1HCYcenter2p15=(-1(1)1)) 


marginsplot, recast(line) recastci(rarea) ciopt(color(gs10) alwidth(none) fintensity(90)) ci1opt(color(gs15) alwidth(none) fintensity(90)) ci2opt(color(gs12) alwidth(none) fintensity(90)) plotopts(lc(gs0) lpattern(solid)) plot1opts(lc(gs0) lpattern(dot)) plot2opts(lc(gs0) lpattern(dash)) legend(order(1 "w1HCYcenter2p15=-1" 2 "w1HCYcenter2p15=0" 3 "w1HCYcenter2p15=1") ) 

graph save "FIGURE4.gph",replace 


su w1HCYcenter2p15 if HNDwave==1

capture log close


