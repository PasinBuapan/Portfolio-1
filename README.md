# 🥤 Vending Machine Optimization: Low-Light & High-Traffic Zone Analysis

## 📌 Business Overview
This project focuses on optimizing vending machine operations within a hospital environment, specifically targeting machines located in **low-light/walkway areas** during late-night shifts (23:00 - 05:00). 

The goal is to test two main hypotheses to maximize sales revenue and operation efficiency:
1. **Visibility Impact (The "Light" Hypothesis):** Installing LED strips on dark-zone machines to boost impulse buying.
2. **Product Assortment Impact (The "Caffeine" Hypothesis):** Permanently adjusting product slot ratios to favor high-demand caffeine drinks during night shifts, preventing stockouts.

---

## 📊 Data Architecture (Relational Schema)
The database is structured into a star-like schema to optimize analytical queries:
- `Fact_Sales`: Stores granular transaction data including timestamps and quantities.
- `Dim_Products`: Master data for beverages (Caffeine, Soft Drinks, Juices).
- `Dim_Toppings`: Tailored add-ons for drinks.
- `Dim_Vending_Machines`: Captures environmental factors (`is_low_light`, `has_led_strip`).

---

## 🔍 Key Insights from SQL Analysis

### 1. Visibility Performance (A/B Testing Result)
By querying sales performance between a completely dark machine (`M001`) and an LED-retrofitted machine (`M002`), we proved that **improving machine visibility increases total revenue substantially** without changing the product mix.

### 2. Late-Night Category Demand
Time-series filtering confirmed that between **23:00 and 05:00**, the `Caffeine` category outperforms all other beverages by a wide margin, justifying a permanent slot reallocation for these high-margin items.
