# GoExplore — Retail Performance & Market Expansion Analysis

An end-to-end business intelligence project analyzing GoExplore, a camping and hiking equipment supplier, using SQL (BigQuery), spreadsheet analysis, and a live Looker Studio dashboard.

**[View the live dashboard →] [https://datastudio.google.com/reporting/013caa41-de79-48ae-ab0f-ad5c37556181]**

## Business Questions

1. **Store performance:** Do specialty stores (Golf Shop, Eyewear Store) perform differently from general stores (Sports Store, Department Store)?
2. **Market expansion:** What is the estimated market size for four new countries — Czech Republic, Norway, Poland, and Portugal — that GoExplore does not yet operate in?

## Key Findings

- Raw revenue totals favor general stores (more retailers = more total revenue), but this is misleading. Once normalized by **average order value**, specialty stores outperform: **Golf Shop (€82,968) and Warehouse Store (€109,682)** generate the highest value per transaction in the business — even higher than Department Store.
- **Takeaway:** Specialty stores don't underperform — they operate on a fewer-but-larger-transaction model, which raw order counts and total revenue alone obscure.
- For market sizing, each target country was matched to a comparable existing market ("twin") and scaled using population and per-capita revenue, cross-checked against GDP per capita, Gini Index, HDI, household consumption, and labor cost to validate comparability.

## Tech Stack

- **BigQuery** — SQL joins across a star-schema data model (fact table: `daily_sales`; dimensions: `retailers`, `products`, `methods`)
- **Google Sheets** — initial exploratory analysis, pivot tables, formula-based validation
- **Looker Studio** — interactive dashboard connected live to BigQuery

## Data Model

A star schema: `daily_sales` (fact table) joined to three dimension tables via foreign keys (`Retailer code`, `Product number`, `Order method code`).

An "order" is defined as a unique combination of **retailer + date + order method** — multiple products purchased by the same retailer, on the same day, through the same channel count as one order with multiple line items, not separate orders. This definition was validated against real transaction patterns in the data before use.

## Key SQL Logic

```sql
-- Combined reporting table: joins all 4 tables, computes revenue and order_id
SELECT
  r.`Retailer name` AS retailer_name,
  r.`type` AS retailer_type,
  r.country,
  CASE
    WHEN r.country IN ('France','Switzerland','Germany','Sweden','Netherlands','Italy',
      'Spain','Denmark','Finland','United Kingdom','Belgium','Austria') THEN 'Europe'
    WHEN r.country IN ('Canada','United States','Mexico') THEN 'North America'
    WHEN r.country IN ('Japan','Korea','Singapore','China') THEN 'East Asia'
    WHEN r.country = 'Australia' THEN 'South Pacific'
    WHEN r.country = 'Brazil' THEN 'South America'
    ELSE 'UNSPECIFIED'
  END AS region,
  p.`Product line` AS product_line,
  ds.`Quantity ` * ds.`Unit sale price` AS revenue,
  CONCAT(CAST(ds.`Retailer code` AS STRING), '_', CAST(ds.Date AS STRING), '_',
    CAST(ds.`Order method code` AS STRING)) AS order_id
FROM `goexplore.daily_sales` AS ds
JOIN `goexplore.Retailers` AS r USING (`Retailer code`)
JOIN `goexplore.products` AS p USING (`Product number`)
JOIN `goexplore.methods` AS m USING (`Order method code`);
```

Average order value required a two-step aggregation (not a single AVG):
1. Sum `revenue` **per order** (grouping multiple product-line rows into one order total)
2. Average those order totals **by store type**

## Dashboard Pages

1. **Retailer Overview** — headline KPIs, top retailers, revenue by country
2. **Product Overview** — revenue and margin by product line, top brands
3. **Store Type Performance** — the four core KPIs answering business question 1
4. **Market Expansion Analysis** — country comparison, economic indices, tiered recommendations for business question 2

## Methodology Notes

- All calculated metrics were cross-validated between Google Sheets and BigQuery to catch aggregation errors (e.g. pivot table calculated fields aggregating before multiplying, causing incorrect revenue figures if used directly).
- Market size estimates use a per-capita scaling method: `(twin country revenue ÷ twin population) × target population`, cross-checked against GDP per capita and other development indices to validate the comparison country choice.

## Limitations

- Market size estimates assume similar per-capita spending behavior between target and twin countries; this is a starting estimate, not a validated forecast.
- One retailer category (Equipment Rental Store) has zero recorded transactions in the dataset — flagged as a data gap, not a performance finding.
