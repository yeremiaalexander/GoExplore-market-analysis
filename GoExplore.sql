SELECT
  r.`Retailer name` AS retailer_name,
  r.`type` AS retailer_type,
  r.country,
  CASE
    WHEN r.country IN ('France','Switzerland','Germany','Sweden','Netherlands','Italy','Spain','Denmark','Finland','United Kingdom','Belgium','Austria') THEN 'Europe'
    WHEN r.country IN ('Canada','United States','Mexico') THEN 'North America'
    WHEN r.country IN ('Japan','Korea','Singapore','China') THEN 'East Asia'
    WHEN r.country = 'Australia' THEN 'South Pacific'
    WHEN r.country = 'Brazil' THEN 'South America'
    ELSE 'UNSPECIFIED'
  END AS region,
  p.`Product line` AS product_line,
  p.`Product type` AS product_type,
  p.product,
  p.`Product brand` AS product_brand,
  p.`Product color` AS product_color,
  ROUND(p.`Unit cost`, 2) AS unit_cost,
  ROUND(p.`Unit price`, 2) AS unit_suggested_price,
  m.`Order method type` AS order_method_type,
  ds.Date AS date,
  ds.`Quantity ` AS quantity,
  ROUND(ds.`Unit price`, 2) AS unit_full_price,
  ROUND(ds.`Unit sale price`, 2) AS unit_sale_price,
  ROUND(ds.`Quantity ` * ds.`Unit sale price`, 2) AS revenue,
  CONCAT(CAST(ds.`Retailer code` AS STRING), '_', CAST(ds.Date AS STRING), '_', CAST(ds.`Order method code` AS STRING)) AS order_id
FROM `goexplore.daily_sales` AS ds
JOIN `goexplore.Retailers` AS r USING (`Retailer code`)
JOIN `goexplore.products` AS p USING (`Product number`)
JOIN `goexplore.methods` AS m USING (`Order method code`);