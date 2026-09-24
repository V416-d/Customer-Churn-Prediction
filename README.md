# Power BI Dashboard Guide

Power BI Desktop is needed to create the `.pbix` file, so it is **not included** here. Everything required to build it in about an hour is below. After building it, save it as `dashboard/customer_churn_dashboard.pbix` and add screenshots to `images/`.

## 1. Load the data (Home > Get Data > Text/CSV)
| Table name | File | Purpose |
|---|---|---|
| `Customers` | `data/processed/cleaned_customer_churn.csv` | Customer attributes, churn, revenue |
| `Predictions` | `data/predictions/customer_churn_predictions.csv` | Churn probability and risk category |
| `ModelMetrics` (optional) | type in manually from `results.json` | Model performance card |

In Power Query, for `Predictions` keep only `customer_id`, `churn_probability`, `predicted_churn`, `risk_category` (remove the other columns so they don't duplicate `Customers`). Check that `senior_citizen`, `tenure`, `monthly_charges` and `total_charges` have numeric types.

## 2. Data model
Create a **one-to-one** relationship: `Customers[customer_id]` ↔ `Predictions[customer_id]`, cross-filter direction *Both*.

## 3. Calculated column (Customers table)
```DAX
Tenure Group =
SWITCH(
    TRUE(),
    Customers[tenure] <= 12, "0-12",
    Customers[tenure] <= 24, "13-24",
    Customers[tenure] <= 48, "25-48",
    "49-72"
)
```
Set *Sort by column* for a tidy order, or prefix labels "1)", "2)", and so on.

## 4. DAX measures
```DAX
Total Customers = COUNTROWS(Customers)

Churned Customers =
CALCULATE(COUNTROWS(Customers), Customers[churn] = "Yes")

Churn Rate = DIVIDE([Churned Customers], [Total Customers])

Avg Monthly Charges = AVERAGE(Customers[monthly_charges])

Monthly Revenue of Churned Customers =
CALCULATE(SUM(Customers[monthly_charges]), Customers[churn] = "Yes")

% Monthly Revenue Churned =
DIVIDE([Monthly Revenue of Churned Customers], SUM(Customers[monthly_charges]))

High-Risk Customers =
CALCULATE(COUNTROWS(Predictions), Predictions[risk_category] = "High")

Avg Churn Probability = AVERAGE(Predictions[churn_probability])
```
Format `Churn Rate` and `% Monthly Revenue Churned` as percentages.

## 5. Report pages
**Page 1 - Executive Overview:** KPI cards (Total Customers, Churned Customers, Churn Rate, Avg Monthly Charges, Monthly Revenue of Churned Customers, High-Risk Customers); donut chart of churn distribution; clustered bar of `Churn Rate` by `contract`; column chart of `Churn Rate` by `Tenure Group`; bar chart of `Churn Rate` by `payment_method`.

**Page 2 - Customer Churn Analysis:** `Churn Rate` by `senior_citizen`, `Tenure Group`, `contract`, a charge band, `internet_service`, `tech_support`, `online_security` and `payment_method`. Add slicers for contract, internet service and tenure group.

**Page 3 - Churn Risk & ML Insights:** column chart of customers by `risk_category`; a table with customer_id, churn_probability, risk_category, contract, monthly_charges (sorted by probability, top N filter); cards for model ROC-AUC, recall and precision (from `ModelMetrics`); an image of `images/feature_importance.png` for the important features.

## 6. Notes
- Risk categories (Low < 0.40, Medium 0.40-0.70, High >= 0.70) are **project-defined**, not industry standards.
- `Predictions` holds out-of-fold probabilities, so each customer was scored by a model that never saw them during training.
