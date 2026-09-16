# Financial Market Anomalies and Uncertainty: The Friday Effect

A time-series study investigating the **Friday Effect** (a day-of-the-week calendar anomaly) in financial markets and its relationship with market uncertainty, using **Stata**.

---

## 📌 Overview

Financial market anomalies challenge the Efficient Market Hypothesis (EMH) by showing patterns in returns that should not exist if markets were fully efficient. This project examines the **Friday Effect** — the tendency for stock market returns to behave differently (typically higher) on Fridays compared to other trading days — and explores whether this anomaly is linked to underlying market uncertainty.

The analysis is built entirely in **Stata**, using time-series econometric techniques to test for the presence, significance, and persistence of the anomaly across the sample period.

---

## 🎯 Objectives

- Test for the existence of the Friday Effect in daily stock market returns
- Examine day-of-the-week seasonality in returns and volatility
- Assess whether market uncertainty (e.g., volatility clustering) explains part of the anomaly
- Evaluate whether the anomaly is stable over time or has weakened/disappeared in recent years

---

## 🗂️ Repository Structure

```
Financial-Market-Anomalies-and-Uncertainty-The-Friday-Effect/
│
├── data/                # Raw and cleaned datasets used in the analysis
├── stata-code/          # Stata .do files (data cleaning, models, tests)
├── graphs/              # Exported charts and visualizations
├── dashboard/           # Summary dashboard of results
├── output/              # Regression outputs, logs, and tables
├── README.md            # Project documentation (this file)
└── LICENSE
```

---

## 🧮 Stata Code

**Language:** Stata

Folder: `stata-code/`

All analysis is performed through `.do` files, run in the following order:

| File | Purpose |
|------|---------|
| `01_data_cleaning.do` | Import raw data, handle missing values, generate day-of-week dummy variables |
| `02_descriptive_stats.do` | Compute mean returns, standard deviation, and volatility by trading day |
| `03_regression_models.do` | OLS regressions with day-of-week dummies to test the Friday Effect |
| `04_garch_volatility.do` | ARCH/GARCH models to capture time-varying volatility/uncertainty |
| `05_robustness_checks.do` | Sub-period and rolling-window analysis to test stability of the effect |

*(Rename/reorder to match your actual `.do` files.)*

**Key Stata commands/packages used:** `tsset`, `regress`, `arch`, `newey`, `graph export`, `esttab` / `outreg2` for tabulating results.

**How to run:**
1. Clone the repo and open Stata.
2. Set the working directory to the cloned folder.
3. Run the `.do` files in `stata-code/` in numerical order.
4. Outputs (tables, logs) save to `output/`; charts save to `graphs/`.

**Requirements:** Stata 14+ and any user-written packages used (e.g., `outreg2`, `estout`) — install via `ssc install <package>`.

---

## 📊 Data

- **Frequency:** Daily (or weekly, if applicable)
- **Variables:** Closing price, daily returns, day-of-week indicators, volatility measures
- **Source:** *(add data source — e.g., Yahoo Finance, NSE/BSE, Bloomberg)*
- **Sample Period:** *(add start–end dates)*

---

## 📉 Graphs

Folder: `graphs/`

All charts generated during the analysis, exported directly from Stata using `graph export` (`.png`/`.pdf`).

| File | Description |
|------|-------------|
| `mean_returns_by_day.png` | Bar chart comparing average returns across each day of the week |
| `return_distribution.png` | Histogram/density plot of daily return distributions |
| `volatility_timeline.png` | Time-series plot of estimated conditional volatility (ARCH/GARCH) |
| `friday_effect_subperiods.png` | Comparison of the Friday effect across different sub-sample periods |
| `rolling_estimates.png` | Rolling-window regression estimates showing how the anomaly evolves over time |

*(Update with actual file names once added. File naming convention: `topic_description.extension`.)*

---

## 🖥️ Dashboard

Folder: `dashboard/`

A consolidated, one-page summary of the key results — useful for presentations or sharing with non-technical audiences.

| File | Description |
|------|-------------|
| `summary_dashboard.png` / `.pdf` | Visual summary combining key statistics, regression results, and charts |
| `key_metrics.xlsx` | Table of summary statistics (mean returns by day, significance levels, volatility measures) |

*(Update with actual file names once added. Compiled from the outputs in `output/` and charts in `graphs/`.)*

---

## 📈 Key Findings

*(Summarize main results here once finalized, e.g.:)*
- Average Friday returns are significantly higher than other weekdays at the X% level.
- The effect appears stronger during periods of low market uncertainty.
- The anomaly shows signs of weakening in the post-2015 sub-sample.

---

## 👤 Author

**Suvankar Das**
M.Sc. Economics (Data Analytics)
[Portfolio](https://suvankar-d.github.io/Portfolio/) • [LinkedIn](https://www.linkedin.com/in/suvankar-das-99a2b736a)

---

## 📄 License

This project is open for academic and educational use. Please cite/credit if you use any part of this work.
