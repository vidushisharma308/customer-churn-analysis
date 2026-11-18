# Customer Churn Analysis

An end-to-end customer churn analysis project using SQL and Power BI to explore churn patterns, understand potential drivers, quantify revenue impact, and develop retention recommendations.

## Project Overview

Customer churn affects recurring revenue and long-term customer relationships. This project brings together customer, churn, subscription revenue, product usage, and support interaction data to examine where churn is concentrated and which behaviours are associated with it.

### Project Snapshot

| Metric | Project figure |
|---|---:|
| Analysis period | January 2023 – December 2024 |
| Customers | 500 |
| Churned customers | 110 |
| Overall churn rate | ~22% |
| Data sources | 5 tables |

*Figures are taken from the current project documentation.*

## Objectives

- Measure overall churn and compare churn across customer segments.
- Explore churn by plan, country, industry, signup cohort, and tenure.
- Examine product usage and customer support patterns in relation to churn.
- Assess subscription revenue and revenue impact.
- Translate findings into practical customer-retention recommendations.

## Tools

- **SQL:** Data exploration, joins, aggregations, cohort analysis, and churn analysis.
- **Power BI:** Data modelling, DAX, interactive reporting, and visual analysis.
- **Excel:** Initial data handling.

## Dataset Overview

The `Data/` directory contains five CSV files:

| File | Description |
|---|---|
| `customer_dimension.csv` | Customer and account attributes |
| `churn_fact.csv` | Churn events and recorded churn reasons |
| `subscription_revenue_fact.csv` | Subscription and revenue information |
| `usage_fact.csv` | Product usage activity |
| `support_interaction_fact.csv` | Customer support interactions |

## Analysis Coverage

The SQL analysis includes:

- Customer distribution and churn rates by country and industry.
- Plan-wise churn and signup-cohort analysis.
- Customer lifetime and tenure-based churn analysis.
- Usage-level comparisons.
- Support response, satisfaction, and resolution-time analysis.
- Revenue comparisons by customer status, country, and industry.

## Key Findings

The current analysis documents the following findings:

1. Overall churn is approximately 22% across plan tiers.
2. Customers with low or no product usage show higher churn.
3. Support resolution times above 48 hours are associated with higher churn.
4. Germany has the highest churn rate, while the US has the largest revenue impact.
5. Organic acquisition users show lower churn than paid-channel users.
6. Churn patterns differ across industries.

See [detailed insights and retention recommendations](Insights/churn_insights.md).

## Power BI Dashboard

The repository includes the Power BI report file:

[Open the Power BI dashboard file](Dashboard/customer%20churn%20dashboard.pbix)

A dashboard preview is shown below.

<img width="1601" height="902" alt="Customer churn Power BI dashboard preview" src="https://github.com/user-attachments/assets/0b71733d-00e1-4c53-b1cb-2881107d96f9" />

## Repository Structure

```text
customer-churn-analysis/
├── Dashboard/
│   └── customer churn dashboard.pbix
├── Data/
│   ├── churn_fact.csv
│   ├── customer_dimension.csv
│   ├── subscription_revenue_fact.csv
│   ├── support_interaction_fact.csv
│   └── usage_fact.csv
├── Insights/
│   └── churn_insights.md
├── Sql/
│   ├── queries.analysis.sql
│   └── schema.sql
├── .gitignore
├── LICENSE
└── README.md
```

## How to Explore

1. Review the datasets in `Data/`.
2. Open the SQL scripts in `Sql/` to explore the analysis queries and schema.
3. Read the findings and recommendations in `Insights/churn_insights.md`.
4. Download and open the `.pbix` report using Power BI Desktop.

## Notes

- The dashboard source file is provided in Power BI `.pbix` format.
- The SQL scripts are provided as project analysis artifacts; review table and column references against the included datasets and your database setup before executing them.
- Customer-level CSV files are included as project data files. Use them responsibly if redistributing this repository.

## License

This project is licensed under the MIT License. See [LICENSE](LICENSE).
