# 🥤 Vending Machine Optimization: Low-Light & High-Traffic Zone Analysis

## 📌 Business Overview
This project focuses on optimizing vending machine operations within a hospital environment, specifically targeting machines located in **low-light/walkway areas** during late-night shifts (**23:00 - 05:00**). Targeting late-night hospital shifts, primarily medical staff and shift workers who require high caffeine intake to sustain alert operations.

The goal is to evaluate two main hypotheses to maximize sales revenue and operational efficiency:
1. **Visibility Impact (The "Light" Hypothesis):** Installing LED strips on dark-zone machines to boost impulse buying and improve the customer experience.
2. **Product Assortment Impact (The "Caffeine" Hypothesis):** Reallocating product slot ratios to favor high-demand caffeine drinks during night shifts, preventing stockouts.

---

## 📊 Data Architecture (Relational Schema)
The database is structured into a star-like schema to optimize analytical queries using our simulated dataset (`vending_machine_sales_mock.csv`):
* `Fact_Sales`: Stores granular transaction data including timestamps, quantities, topping selections, and revenue.
* `Dim_Products`: Master data for beverages (`Caffeine`, `Soft Drinks`, `Juices`) and service types (`Hot` / `Cold`).
* `Dim_Toppings`: Tailored add-ons for drinks to analyze upselling performance.
* `Dim_Vending_Machines`: Captures environmental factors (`location_zone`, `is_low_light`, `has_led_strip`).

---

## 🔍 Key Insights from SQL Analysis (Verified Metrics) 
🔗 [Click here to view Live Demo & Run Code on Google Colab](https://colab.research.google.com/drive/15jbEH3-GUm7wu2E5CMUJinTVOpVuKLNi#scrollTo=GPKmbvI0olzZ)

<img width="558" height="393" alt="Mock data (Graph)" src="https://github.com/user-attachments/assets/56d48669-92d3-40f5-94ac-99f73201269e" />


### 1. 💡 Visibility Performance (A/B Testing Result)
By querying sales performance in low-light areas, we compared a completely dark machine against an LED-retrofitted machine. Based on our 1,200 simulated transactions, the data proves that **improving machine visibility increases total revenue substantially** without needing to change the core product mix:
* **LED-Retrofitted Machine (M002):** Generated **23,820.00 THB** (535 cups sold) with an average of 1.09 cups per transaction.
* **Non-LED Machine (M001 - Dark Zone):** Generated only **12,320.00 THB** (288 cups sold).
* **Business Impact:** Installing LED strips nearly doubled the sales revenue (**~93.3% increase**), validating the visibility hypothesis for low-light hospital walkways.

### 2. ☕ Late-Night Category Demand (23:00 - 05:00)
Time-series filtering confirmed that between **23:00 and 05:00**, the `Caffeine` category outperforms all other beverages by a wide margin, justifying a permanent slot reallocation for these high-margin items during night shifts:
* **Caffeine:** Earned **13,330.00 THB** (256 cups sold across 234 transactions).
* **Soft Drinks:** Earned **2,410.00 THB** (61 cups sold).[🔗 Click here to view Live Demo & Run Code on Google Colab]
* **Juices:** Earned **385.00 THB** (11 cups sold).
* **Business Impact:** Caffeine products represent **~82.6% of late-night revenue**, fully justifying a permanent inventory adjustment during peak medical shift hours.

### 3. 🎯 Add-on Optimization (Topping Analysis)
Cross-analysis of transaction data revealed a notable attachment rate for specific toppings. This indicates a strong opportunity for upselling, proving that customers are willing to customize their drinks even during late-night hours:
* **Extra Espresso Shot (T01):** Captured a **14.42% attachment rate** (173 orders), contributing an additional **2,745.00 THB** in extra revenue.
* **Boba/Jelly (T02):** Captured an **8.08% attachment rate** (97 orders), contributing **1,050.00 THB**.

---

## 💡 Recommended Actions

* **Implement LED Retrofitting:** Deploy LED strips across all remaining low-light and walkway vending machines. Enhanced visibility not only drives impulse purchases (**potential 93% revenue lift** based on A/B test data) but also improves the perceived safety of customers and hospital staff during late-night hours.
* **Optimize Product Assortment:** Reallocate slot ratios to increase the inventory capacity of **Caffeine products** to 80% in high-traffic, late-night zones to eliminate stockout risks during peak hospital shift hours.
* **Leverage Upselling Opportunities:** Keep high-demand **toppings** fully stocked (especially Extra Espresso Shots), and consider bundling them into automated promotions on the machine's interface to increase the average transaction value (ATV).
