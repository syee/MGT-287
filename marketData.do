/*******************************************************************************
Program: MGT 287 Final Project - Market Data
Author: Steven Yee
Date: 3/11/21
Purpose:
Update: 
*******************************************************************************/
clear all
cap log close
cap log using  "mgt287_market_log", text

use "/Users/stevenyee/Documents/UCSD/UCSDEconomics/Winter2021/MGT287/finalProject/data/cboe.dta"
rename Date date
tset date
gen vix_daily_change = vix - vix[_n-1]
gen vix_daily_percent_change = vix_daily_change/vix[_n-1]

rangestat (mean) vix_weekly_change = vix_daily_change, interval(date -6 0) by(date)
rangestat (mean) vix_weekly_percent_change = vix_daily_percent_change, interval(date -6 0) by(date)
rangestat (mean) vix_monthly_change = vix_daily_change, interval(date -29 0) by(date)
rangestat (mean) vix_monthly_percent_change = vix_daily_percent_change, interval(date -29 0) by(date)
rangestat (mean) vix_weekly_raw = vix, interval(date -6 0) by(date)
rangestat (mean) vix_monthly_raw = vix, interval(date -29 0) by(date)

save cboe_full, replace


use "/Users/stevenyee/Documents/UCSD/UCSDEconomics/Winter2021/MGT287/finalProject/data/market_returns.dta"
rename DATE date
tset date

gen mrkt_ret_daily_change = vwretd - vwretd[_n-1]
gen mrkt_ret_daily_perc_change = mrkt_ret_daily_change/vwretd[_n-1]

rangestat (mean) mrkt_ret_week_change = mrkt_ret_daily_change, interval(date -6 0) by(date)
rangestat (mean) mrkt_ret_week_perc_change = mrkt_ret_daily_perc_change, interval(date -6 0) by(date)
rangestat (mean) mrkt_ret_mnth_change = mrkt_ret_daily_change, interval(date -29 0) by(date)
rangestat (mean) mrkt_ret_mnth_perc_change = mrkt_ret_daily_perc_change, interval(date -29 0) by(date)
rangestat (mean) mrkt_ret_weekly_raw = vwretd, interval(date -6 0) by(date)
rangestat (mean) mrkt_ret_mnth_raw = vwretd, interval(date -29 0) by(date)

gen spy_ret_daily_change = sprtrn - sprtrn[_n-1]
gen spy_ret_daily_perc_change = spy_ret_daily_change/sprtrn[_n-1]

rangestat (mean) spy_ret_week_change = spy_ret_daily_change, interval(date -6 0) by(date)
rangestat (mean) spy_ret_week_perc_change = spy_ret_daily_perc_change, interval(date -6 0) by(date)
rangestat (mean) spy_ret_mnth_change = mrkt_ret_daily_change, interval(date -29 0) by(date)
rangestat (mean) spy_ret_mnth_perc_change = spy_ret_daily_perc_change, interval(date -29 0) by(date)
rangestat (mean) spy_ret_weekly_raw = sprtrn, interval(date -6 0) by(date)
rangestat (mean) spy_ret_mnth_raw = sprtrn, interval(date -29 0) by(date)

save market_returns_full, replace

merge 1:1 date using cboe_full
drop _merge

save market_ret_cboe, replace
