/*******************************************************************************
Program: MGT 287 Final Project
Author: Steven Yee
Date: 2/22/21
Purpose:
Update: 
*******************************************************************************/
clear all
cap log close
cap log using  "mgt287_log", text

***************************************************
* Import all messages with one cashtag and user labeled sentiment

import delimited "/Users/stevenyee/Documents/UCSD/UCSDEconomics/Winter2021/MGT287/finalProject/data/raw_transactions.csv", colrange(1:5) clear

* Remove duplicates
sort message_id
quietly by message_id: gen dup = cond(_N==1,0,_n)
drop if dup > 1
drop dup

* Convert sentiment to 1 if "Bullish" and 0 if "Bearish"
gen sentiment2 = sentiment == "Bullish"
drop sentiment
rename sentiment2 sentiment

* Symbol_ID is dropped since SYMBOL is more useful
drop symbol_id

save message_sentiment, replace
***************************************************


***************************************************
* Import info on all messages to merge dates into sentiment_sample

import delimited "/Users/stevenyee/Documents/UCSD/UCSDEconomics/Winter2021/MGT287/finalProject/data/messagesother.csv", encoding(ISO-8859-2) colrange(1:4) clear 

* Only keep "create" versions of each message
keep if action == "create"
drop action

* Remove duplicates
sort message_id
quietly by message_id: gen dup = cond(_N==1,0,_n)
drop if dup > 1
drop dup

save message_details, replace
***************************************************


***************************************************
* Merge message_sentiment and message_details on message_id to get the time stamp

use message_sentiment
merge 1:1 message_id using message_details
keep if _merge == 3
drop _merge

save message_complete, replace
***************************************************


***************************************************
* Clean data
// drop message_id

* Create a numeric ID for each symbol. Original symbol_id was not constant
egen symbol_id = group(symbol)

* Format date into DD/MM/YYYY
gen date = dofc(clock(time, "YMDhms"))
format date %td

gen month = month(date)
gen year = year(date)

save message_complete, replace
***************************************************


***************************************************
* Create sub sample of data
// keep if month == 6 & year == 2016
// save message_complete_sample, replace
***************************************************

// use message_complete_sample

***************************************************
* Create sentiment measures

* Identify each user-date-symbol combination
egen user_symbol_date_id = group(user_id symbol date)

* Create sentiment average for each user-date-symbol combination
egen user_symbol_date_sentiment = mean(sentiment), by(user_symbol_date_id)
label variable user_symbol_date_sentiment "individual user sentiment for symbol-date"

by symbol date user_id, sort: gen nvals = _n == 1

* Count the number of users tweeting about a symbol-day
egen symbol_date_user_count = sum(nvals), by(symbol date)
label variable symbol_date_user_count "number of users tweeting for symbol-date"

* Get the average sentiment for symbol-day where each user is weighted equally regardless of tweets
egen symbol_date_sentiment = mean(user_symbol_date_sentiment) if nvals == 1, by(symbol date)
label variable symbol_date_sentiment "user-weighted sentiment for symbol-date"

drop nvals

// save message_complete, replace
save message_complete_sample2, replace
***************************************************


***************************************************
* Calculate the change in sentiment for each stock from day to day

* Only keep one instance of each symbol-date
by symbol date, sort: gen dups = _n != 1
drop if dups == 1


* Compare stock sentiments to SPY sentiment
gen flag_spy = symbol == "SPY"
bysort date (flag_spy): gen spy_difference = symbol_date_sentiment - symbol_date_sentiment[_N]

xtset symbol_id date


* Compute changes in sentiment
gen sentiment_change_raw = D.symbol_date_sentiment
label variable sentiment_change_raw "raw change in sentiment"
gen sentiment_change_percentage = D.symbol_date_sentiment/L.symbol_date_sentiment
label variable sentiment_change_percentage "percentage change in sentiment"

gen sentiment_raw_week = symbol_date_sentiment - L7.symbol_date_sentiment
label variable sentiment_raw_week "week raw change in sentiment"
gen sentiment_percentage_week = sentiment_raw_week/L7.symbol_date_sentiment
label variable sentiment_percentage_week "week percentage change in sentiment"

gen sentiment_raw_month = symbol_date_sentiment - L30.symbol_date_sentiment
label variable sentiment_raw_month "month raw change in sentiment"
gen sentiment_percentage_month = sentiment_raw_month/L30.symbol_date_sentiment
label variable sentiment_percentage_month "month percentage change in sentiment"

gen sentiment_raw_2month = symbol_date_sentiment - L60.symbol_date_sentiment
label variable sentiment_raw_2month "2 month raw change in sentiment"
gen sentiment_percentage_2month = sentiment_raw_2month/L60.symbol_date_sentiment
label variable sentiment_percentage_2month "2 month percentage change in sentiment"

gen sentiment_raw_3month = symbol_date_sentiment - L90.symbol_date_sentiment
label variable sentiment_raw_3month "3 month raw change in sentiment"
gen sentiment_percentage_3month = sentiment_raw_3month/L90.symbol_date_sentiment
label variable sentiment_percentage_3month "3 month percentage change in sentiment"


* Compute average sentiment
gen sentiment_avg_week = symbol_date_sentiment
forval i = 1/6{
	bysort symbol (date): replace sentiment_avg_week = sentiment_avg_week + symbol_date_sentiment[_n-`i']
}
replace sentiment_avg_week = sentiment_avg_week/7
label variable sentiment_avg_week "week average sentiment"

gen sentiment_avg_month = symbol_date_sentiment
forval i = 1/29{
	bysort symbol (date): replace sentiment_avg_month = sentiment_avg_month + symbol_date_sentiment[_n-`i']
}
replace sentiment_avg_month = sentiment_avg_month/30
label variable sentiment_avg_month "month average sentiment"

gen sentiment_avg_2month = symbol_date_sentiment
forval i = 1/59{
	bysort symbol (date): replace sentiment_avg_2month = sentiment_avg_2month + symbol_date_sentiment[_n-`i']
}
replace sentiment_avg_2month = sentiment_avg_2month/60
label variable sentiment_avg_2month "2 month average sentiment"

gen sentiment_avg_3month = symbol_date_sentiment
forval i = 1/89{
	bysort symbol (date): replace sentiment_avg_3month = sentiment_avg_3month + symbol_date_sentiment[_n-`i']
}
replace sentiment_avg_3month = sentiment_avg_3month/90
label variable sentiment_avg_3month "3 month average sentiment"


* Compute average sentiment relative to SPY
gen sentiment_spy_avg_week = spy_difference
forval i = 1/6{
	bysort symbol (date): replace sentiment_spy_avg_week = sentiment_spy_avg_week + spy_difference[_n-`i']
}
replace sentiment_spy_avg_week = sentiment_spy_avg_week/7
label variable sentiment_spy_avg_week "week average spy sentiment difference"

gen sentiment_spy_avg_month = spy_difference
forval i = 1/29{
	bysort symbol (date): replace sentiment_spy_avg_month = sentiment_spy_avg_month + spy_difference[_n-`i']
}
replace sentiment_spy_avg_month = sentiment_spy_avg_month/30
label variable sentiment_spy_avg_month "month average spy sentiment difference"

gen sentiment_spy_avg_2month = spy_difference
forval i = 1/59{
	bysort symbol (date): replace sentiment_spy_avg_2month = sentiment_spy_avg_2month + spy_difference[_n-`i']
}
replace sentiment_spy_avg_2month = sentiment_spy_avg_2month/60
label variable sentiment_spy_avg_2month "2 month average spy sentiment difference"

gen sentiment_spy_avg_3month = spy_difference
forval i = 1/89{
	bysort symbol (date): replace sentiment_spy_avg_3month = sentiment_spy_avg_3month + spy_difference[_n-`i']
}
replace sentiment_spy_avg_3month = sentiment_spy_avg_3month/90
label variable sentiment_spy_avg_3month "3 month average spy sentiment difference"




// collapse (sum) marketcap*sentiment marketcap, by(date)
// gen marketcap*sentiment/marketcap


* This .dta has a single observation for each symbol-date
save message_complete_flat_sample, replace
***************************************************


***************************************************
* Import stock data
use "/Users/stevenyee/Documents/UCSD/UCSDEconomics/Winter2021/MGT287/finalProject/data/compustat_full.dta"

* For sample
rename tic TICKER
rename datadate date
// keep if TICKER == "AAPL" | TICKER == "TSLA"
gen year = year(date)
gen month = month(date)
keep if year == 2016 & month == 6

* Only keep one instance of each symbol-date. Unclear why there are duplicates :(
by TICKER date, sort: gen dups = _n != 1
drop if dups == 1
drop dups

* Create market capitalization and share turnover variables
gen marketcap = prccd*cshoc
gen shareturnover = cshtrd/cshoc

* Convert stirng sic code to float
gen num_sic = real(sic)
drop sic
rename num_sic sic

* Identify SICCD on last day of data in case SICCD changes over time
bysort TICKER (date): gen nvals = (_n == _N)
egen sic2 = sum(sic) if nvals == 1, by(TICKER)
egen sic3 = sum(sic2), by(TICKER)
drop sic2
drop nvals
rename sic sic_old
rename sic3 sic
label variable sic "Standard Industrial Code on last day of data"


save compustat_full_sample, replace

use "/Users/stevenyee/Documents/UCSD/UCSDEconomics/Winter2021/MGT287/finalProject/data/famafrench3factor_log.dta"

rename DATE date
gen year = year(date)
gen month = month(date)

* For sample
// keep if TICKER == "AAPL" | TICKER == "TSLA"
keep if year == 2016 & month == 6
drop if missing(TICKER)

* Only keep one instance of each symbol-date. Unclear why there are duplicates :(
by TICKER date, sort: gen dups = _n != 1
drop if dups == 1
drop dups

save famafrench3_log_sample, replace

* Merge Compustat data with Fama French data to get excess returns and total volatility
merge 1:1 TICKER date using compustat_full_sample
keep if _merge == 3
drop _merge


egen ticker_id = group(TICKER)
xtset ticker_id date

* Get average changes in excess returns
bysort TICKER (date): gen exreturn_raw_week = exret - exret[_n-5]
label variable exreturn_raw_week "week raw change in excess returns"
bysort TICKER (date): gen exreturn_percentage_week = exreturn_raw_week/exret[_n-5]
label variable exreturn_percentage_week "week percentage change in excess returns"

bysort TICKER (date): gen exreturn_raw_month = exret - exret[_n-20]
label variable exreturn_raw_month "month raw change in excess returns"
bysort TICKER (date): gen exreturn_percentage_month = exreturn_raw_month/exret[_n-20]
label variable exreturn_percentage_month "month percentage change in excess returns"


* Get average excess returns
gen exreturn_avg_raw_week = exret
forval i = 1/4{
	bysort TICKER (date): replace exreturn_avg_raw_week = exreturn_avg_raw_week + exret[_n-`i']
}
replace exreturn_avg_raw_week = exreturn_avg_raw_week/5
label variable exreturn_avg_raw_week "week average excess returns"

gen exreturn_avg_raw_month = exret
forval i = 1/20{
	bysort TICKER (date): replace exreturn_avg_raw_month = exreturn_avg_raw_month + exret[_n-`i']
}
replace exreturn_avg_raw_month = exreturn_avg_raw_month/20
label variable exreturn_avg_raw_month "month average excess returns"

save compu_ff3_log_sample, replace
***************************************************


***************************************************
* Get value weighted sentiment
rename TICKER symbol


merge m:1 symbol date using message_complete_flat_sample
keep if _merge == 3
gen value_weighted_sentiment = marketcap*symbol_date_sentiment
save test_compu_ff3_log_sample, replace

collapse (sum) value_weighted_sentiment marketcap cshoc cshtrd, by(date)
gen market_sentiment = value_weighted_sentiment/marketcap
gen market_turnover = cshtrd/cshoc

save market_sentiment, replace

merge 1:m date using test_compu_ff3_log_sample, generate(_merge2)
drop value_weighted_sentiment

save complete_sample, replace
