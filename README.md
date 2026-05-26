# 🥤 Vending Machine Optimization: Low-Light & High-Traffic Zone Analysis

## 📌 Business Overview
This project focuses on optimizing vending machine operations within a hospital environment, specifically targeting machines located in **low-light/walkway areas** during late-night shifts (**23:00 - 05:00**). 

The goal is to evaluate two main hypotheses to maximize sales revenue and operational efficiency:
1. **Visibility Impact (The "Light" Hypothesis):** Installing LED strips on dark-zone machines to boost impulse buying and improve the customer experience.
2. **Product Assortment Impact (The "Caffeine" Hypothesis):** Reallocating product slot ratios to favor high-demand caffeine drinks during night shifts, preventing stockouts.

---

## 📊 Data Architecture (Relational Schema)
The database is structured into a star-like schema to optimize analytical queries:
* `Fact_Sales`: Stores granular transaction data including timestamps, quantities, topping selections, and revenue.
* `Dim_Products`: Master data for beverages (`Caffeine`, `Soft Drinks`, `Juices`) and service types (`Hot`/`Cold`).
* `Dim_Toppings`: Tailored add-ons for drinks to analyze upselling performance.
* `Dim_Vending_Machines`: Captures environmental factors (`location_zone`, `is_low_light`, `has_led_strip`).

---

## 🔍 Key Insights from SQL Analysis

### 1. Visibility Performance (A/B Testing Result)
By querying sales performance in low-light areas, we compared dark machines against LED-retrofitted machines. The data proves that **improving machine visibility increases total revenue substantially** without needing to change the core product mix. 

### 2. Late-Night Category Demand
Time-series filtering confirmed that between **23:00 and 05:00**, the `Caffeine` category outperforms all other beverages by a wide margin, justifying a permanent slot reallocation for these high-margin items during night shifts.

### 3. Add-on Optimization (Topping Analysis)
Cross-analysis of transaction data revealed a notable attachment rate for specific toppings. This indicates a strong opportunity for upselling, proving that customers are willing to customize their drinks even during late-night hours.

---

## 💡 Recommended Actions

* **Implement LED Retrofitting:** Deploy LED strips across all remaining low-light and walkway vending machines. Enhanced visibility not only drives impulse purchases but also improves the perceived safety of customers and hospital staff during late-night hours.
* **Optimize Product Assortment:** Reallocate slot ratios to increase the inventory capacity of **Caffeine products** in high-traffic, late-night zones to eliminate stockout risks during peak hospital shift hours.
* **Leverage Upselling Opportunities:** Keep high-demand **toppings** fully stocked, and consider bundling them into automated promotions on the machine's interface to increase the average transaction value (ATV).
