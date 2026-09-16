*******************************************************
* Financial Market Anomalies and Uncertainty
* The Friday Effect - NIFTY 100
* Stata Analysis
*
* Main procedures:
* 1. Data preparation and log returns
* 2. Time-series declaration
* 3. PACF and ACF diagnostics
* 4. ADF unit-root test
* 5. AR(1) and ARMA models
* 6. Friday and volatility dummy variables
* 7. Interaction model and simplified models
* 8. Export of graphs
*******************************************************

clear all
set more off

*------------------------------------------------------*
* 0. WORKING DIRECTORY
*------------------------------------------------------*
* Change this to the location of your GitHub project.
cd "YOUR_PROJECT_FOLDER"

*------------------------------------------------------*
* 1. IMPORT DATA
*------------------------------------------------------*
* Change the filename/sheet if required.
import excel "data/NIFTY100.xlsx", firstrow clear

* Check the imported variables
describe
summarize

*------------------------------------------------------*
* 2. DATA PREPARATION
*------------------------------------------------------*
* IMPORTANT:
* The code below assumes the dataset contains:
*   Date  = trading date
*   Close = NIFTY 100 closing price
*
* If your variables have different names, replace Date/Close
* throughout this file.

* Convert date if it is stored as a string.
capture confirm string variable Date
if !_rc {
    gen date = daily(Date,"YMD")
    replace date = daily(Date,"DMY") if missing(date)
    replace date = daily(Date,"MDY") if missing(date)
    format date %td
}
else {
    gen date = Date
    format date %td
}

* Keep observations with valid prices
drop if missing(Close) | Close<=0

sort date

* Log price and daily log return
gen log_close = ln(Close)
gen log_return = D.log_close

label variable log_return "Daily Log Return"

*------------------------------------------------------*
* 3. DECLARE TIME SERIES
*------------------------------------------------------*
tsset date

* Check for gaps and time-series structure
tsreport

*------------------------------------------------------*
* 4. DAY-OF-WEEK / FRIDAY DUMMY
*------------------------------------------------------*
gen day_of_week = dow(date)

label define daylbl 0 "Sunday" 1 "Monday" 2 "Tuesday" ///
                    3 "Wednesday" 4 "Thursday" 5 "Friday" 6 "Saturday"
label values day_of_week daylbl

gen friday = (day_of_week==5)
label variable friday "Friday Dummy"

*------------------------------------------------------*
* 5. DESCRIPTIVE STATISTICS
*------------------------------------------------------*
summarize Close log_return, detail

* Mean returns by day of week
tabstat log_return, by(day_of_week) statistics(n mean sd min max)

* Simple weekday comparison
reg log_return i.day_of_week

* Friday-only mean comparison
ttest log_return, by(friday)

*------------------------------------------------------*
* 6. PACF AND ACF DIAGNOSTIC TESTS
*------------------------------------------------------*
* PACF - used to identify the autoregressive order
pac log_return, lags(40)

graph export "graphs/01_PACF_Test.png", replace

* ACF - used to examine serial correlation
ac log_return, lags(40)

graph export "graphs/02_ACF_Test.png", replace

*------------------------------------------------------*
* 7. ADF UNIT-ROOT TEST
*------------------------------------------------------*
dfuller log_return, lags(1)

* If required, test with a different lag length:
* dfuller log_return, lags(5)

*------------------------------------------------------*
* 8. AR(1) MODEL
*------------------------------------------------------*
arima log_return, arima(1,0,0)

estimates store AR1

*------------------------------------------------------*
* 9. ARMA(1,1) MODEL
*------------------------------------------------------*
arima log_return, arima(1,0,1)

estimates store ARMA11

* Compare information criteria
estat ic

*------------------------------------------------------*
* 10. CREATE VOLATILITY MEASURE
*------------------------------------------------------*
* A rolling standard deviation is used as a simple
* measure of changing market volatility.

rolling_sd20 = .
quietly {
    forvalues i = 21/`=_N' {
        quietly summarize log_return in `=`i'-19'/`i''
        replace rolling_sd20 = r(sd) in `i'
    }
}

label variable rolling_sd20 "20-day Rolling Volatility"

* Alternative absolute-return proxy
gen abs_return = abs(log_return)

* Inspect volatility distribution
summarize rolling_sd20, detail

*------------------------------------------------------*
* 11. NORMAL VS VOLATILE REGIME
*------------------------------------------------------*
* The median rolling volatility is used as the cutoff.
* If your project used a different cutoff, replace the
* value below with that threshold.

summarize rolling_sd20, detail
scalar volatility_cutoff = r(p50)

gen volatility = (rolling_sd20 > volatility_cutoff) if !missing(rolling_sd20)
label variable volatility "Volatile Period Dummy"

label define vollbl 0 "Normal" 1 "Volatile"
label values volatility vollbl

tabulate volatility

*------------------------------------------------------*
* 12. FRIDAY-VOLATILITY INTERACTION
*------------------------------------------------------*
gen friday_volatility = friday*volatility
label variable friday_volatility "Friday x Volatility"

*------------------------------------------------------*
* 13. AR(1) WITH FRIDAY DUMMY
*------------------------------------------------------*
arima log_return friday, arima(1,0,0)

estimates store AR1_Friday

*------------------------------------------------------*
* 14. AR(1) WITH FRIDAY + VOLATILITY
*------------------------------------------------------*
arima log_return friday volatility, arima(1,0,0)

estimates store AR1_Fri_Vol

*------------------------------------------------------*
* 15. FULL ARMA MODEL
*     Friday + Volatility + Interaction
*------------------------------------------------------*
arima log_return friday volatility friday_volatility, arima(1,0,1)

estimates store ARMA_Full

*------------------------------------------------------*
* 16. SIMPLIFIED MODEL - DROP INTERACTION
*------------------------------------------------------*
arima log_return friday volatility, arima(1,0,1)

estimates store ARMA_NoInteraction

*------------------------------------------------------*
* 17. MODEL WITH FRIDAY ONLY
*------------------------------------------------------*
arima log_return friday, arima(1,0,1)

estimates store ARMA_Friday

*------------------------------------------------------*
* 18. MODEL COMPARISON
*------------------------------------------------------*
estimates table AR1 ARMA11 AR1_Friday AR1_Fri_Vol ///
    ARMA_Full ARMA_NoInteraction ARMA_Friday, ///
    stats(N ll)

*------------------------------------------------------*
* 19. FRIDAY EFFECT IN NORMAL PERIODS
*------------------------------------------------------*
arima log_return friday if volatility==0, arima(1,0,1)

estimates store Normal_Period

*------------------------------------------------------*
* 20. FRIDAY EFFECT IN VOLATILE PERIODS
*------------------------------------------------------*
arima log_return friday if volatility==1, arima(1,0,1)

estimates store Volatile_Period

*------------------------------------------------------*
* 21. GRAPH: LOG RETURNS
*------------------------------------------------------*
tsline log_return, ///
    title("NIFTY 100 Daily Log Returns") ///
    ytitle("Log Return") ///
    xtitle("Date")

graph export "graphs/06_Log_Returns_Regression.png", replace

*------------------------------------------------------*
* 22. GRAPH: VOLATILITY OVER TIME
*------------------------------------------------------*
tsline rolling_sd20, ///
    title("20-Day Rolling Volatility") ///
    ytitle("Rolling Standard Deviation") ///
    xtitle("Date")

graph export "graphs/Volatility_Timeline.png", replace

*------------------------------------------------------*
* 23. GRAPH: FRIDAY VS NON-FRIDAY RETURNS
*------------------------------------------------------*
graph box log_return, over(friday) ///
    title("Returns: Friday vs Non-Friday") ///
    ytitle("Log Return")

graph export "graphs/Friday_vs_NonFriday.png", replace

*------------------------------------------------------*
* 24. GRAPH: NORMAL VS VOLATILE PERIODS
*------------------------------------------------------*
graph box log_return, over(volatility) ///
    title("Returns: Normal vs Volatile Periods") ///
    ytitle("Log Return")

graph export "graphs/Normal_vs_Volatile.png", replace

*------------------------------------------------------*
* 25. SAVE CLEANED DATA
*------------------------------------------------------*
save "data/NIFTY100_cleaned.dta", replace

*******************************************************
* END OF DO-FILE
*******************************************************
