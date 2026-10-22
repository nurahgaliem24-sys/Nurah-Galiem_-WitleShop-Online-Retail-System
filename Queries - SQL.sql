-- ============================================================================
-- Sizwe Coffee - SQL Assignment (Databricks SQL; also close to PostgreSQL/DuckDB)
-- FY2024 = orders placed 2023-07-01 to 2024-06-30 | FY2025 = after 2024-06-30
-- ============================================================================

-- Task 1: Channel performance
WITH channel_fy AS (
    SELECT
        o.channel,
        SUM(CASE WHEN o.order_date <= DATE '2024-06-30' THEN sl.line_revenue ELSE 0 END) AS fy2024_revenue,
        SUM(CASE WHEN o.order_date >  DATE '2024-06-30' THEN sl.line_revenue ELSE 0 END) AS fy2025_revenue
    FROM sales_orders o
    JOIN sales_lines  sl ON sl.order_id = o.order_id
    GROUP BY o.channel
)
SELECT
    channel,
    ROUND(fy2024_revenue, 2) AS fy2024_revenue,
    ROUND(fy2025_revenue, 2) AS fy2025_revenue,
    ROUND(100.0 * (fy2025_revenue - fy2024_revenue) / fy2024_revenue, 2) AS growth_pct
FROM channel_fy
ORDER BY channel;
-- Answer: Both channels grew by almost exactly the same rate: Wholesale rose 8.85% (R308.2m to R335.4m) and Subscription 8.84% (R132.8m to R144.6m). Total revenue went from R441.0m to R480.0m, so the 70/30 channel split is unchanged and growth is not coming from either channel outpacing the other. (Orders.channel and customers.channel agree on every order - 0 mismatches - because a customer belongs to exactly one channel.)

-- Task 2: Where the profit actually comes from
SELECT
    p.product_line,
    ROUND(SUM(sl.line_revenue), 2)                                   AS revenue,
    ROUND(SUM(sl.cogs), 2)                                           AS cost_of_goods,
    ROUND(SUM(sl.line_revenue - sl.cogs), 2)                         AS gross_profit,
    ROUND(100.0 * SUM(sl.line_revenue - sl.cogs) / SUM(sl.line_revenue), 2) AS gross_margin_pct
FROM sales_lines sl
JOIN products    p ON p.sku = sl.sku
GROUP BY p.product_line
ORDER BY gross_profit DESC;
-- Answer: House Blend earns the most gross profit (R107.1m) but it is not the highest-margin line: Single Origin earns the best margin (44.3%) on a much smaller revenue base (R75.3m profit). Bulk Commercial is the second-largest line by revenue (R271.8m) yet earns only a 19.9% margin, so it ranks third on profit.

-- Task 3: The collections problem
SELECT
    c.channel,
    COUNT(*)                                                         AS invoices,
    COUNT(a.settlement_date)                                         AS settled,
    COUNT(*) - COUNT(a.settlement_date)                              AS still_open,
    ROUND(AVG(DATEDIFF(a.settlement_date, a.invoice_date)), 1)                AS avg_days_to_settle,
    ROUND(SUM(a.invoice_amount - a.amount_settled), 2)               AS outstanding_value
FROM ar_ledger a
JOIN customers c ON c.customer_id = a.customer_id
GROUP BY c.channel
ORDER BY c.channel;
-- Answer: Subscription customers pay almost immediately (3.8 days on average, 44 open invoices worth R0.75m), while Wholesale takes 68.7 days on average against 60-day terms and holds 3,454 open invoices worth R87.8m, about 99% of everything outstanding. Splitting Wholesale by year shows the slowdown Nomsa suspects: average days to settle rose from 56.9 in FY2024 to 84.1 in FY2025, and every open invoice is from FY2025. I would investigate Wholesale first, starting with Independent Cafes, which carry the largest outstanding balance (about R36.7m). (Note the average only covers settled invoices, so it understates the true delay.)

-- Task 4: The ten accounts that matter most (FY2025)
-- LEFT JOIN to reps so a customer without a sales rep is not dropped.
SELECT
    c.trading_name,
    c.segment,
    c.province,
    COALESCE(r.rep_name, 'Unassigned')  AS sales_rep,
    ROUND(SUM(sl.line_revenue), 2)      AS fy2025_revenue
FROM customers    c
JOIN sales_orders o  ON o.customer_id = c.customer_id
                    AND o.order_date  > DATE '2024-06-30'
JOIN sales_lines  sl ON sl.order_id   = o.order_id
LEFT JOIN reps    r  ON r.rep_id      = c.rep_id
GROUP BY c.customer_id, c.trading_name, c.segment, c.province, r.rep_name
ORDER BY fy2025_revenue DESC
LIMIT 10;

-- Task 5: A commercial gap - top Wholesale customers with no trade promotion
-- Revenue is across the full two years. NOT EXISTS is NULL-safe.
SELECT
    c.trading_name,
    c.segment,
    c.province,
    ROUND(SUM(sl.line_revenue), 2) AS total_revenue
FROM customers    c
JOIN sales_orders o  ON o.customer_id = c.customer_id
JOIN sales_lines  sl ON sl.order_id   = o.order_id
WHERE c.channel = 'Wholesale'
  AND NOT EXISTS (SELECT 1 FROM trade_promotions tp WHERE tp.customer_id = c.customer_id)
GROUP BY c.customer_id, c.trading_name, c.segment, c.province
ORDER BY total_revenue DESC
LIMIT 15;
-- Answer: Recommend putting the top three (Umhlanga Fresh 108, Ridgeway Foods 308 and Kalahari Kitchen 42 - each R4.4m-R6.2m over two years) on a structured promotion such as a volume rebate, with their reps booking a review visit, because they are large accounts getting no commercial support and are at risk of being poached by competitors.

-- Task 6: Are the sales representatives hitting target?
-- Driven from reps with LEFT JOINs (date filter in the ON clause) so every rep appears.
SELECT
    r.rep_name,
    r.territory,
    r.target_monthly,
    ROUND(COALESCE(SUM(sl.line_revenue), 0) / 12, 2)                      AS fy2025_monthly_avg,
    ROUND(100.0 * COALESCE(SUM(sl.line_revenue), 0) / 12 / r.target_monthly, 1) AS pct_of_target
FROM reps r
LEFT JOIN sales_orders o  ON o.rep_id = r.rep_id
                         AND o.order_date > DATE '2024-06-30'
LEFT JOIN sales_lines  sl ON sl.order_id = o.order_id
GROUP BY r.rep_id, r.rep_name, r.territory, r.target_monthly
ORDER BY pct_of_target DESC;
-- Answer: 16 of 18 reps average above target in FY2025 (Karabo van Wyk and Kagiso Mkhize at about 250%); only Sipho Steyn (98.0%) and Johan Naidoo (77.6%) fall short. Targets summing to R25.4m a month against about R40m actual suggest targets are stale and should be reset.

-- Task 7: The shape of the year
-- Rolling average is NULL for the first two months (fewer than 3 months of history).
WITH monthly AS (
    SELECT
        DATE_TRUNC('month', o.order_date)::date AS month,
        SUM(sl.line_revenue)                    AS revenue
    FROM sales_orders o
    JOIN sales_lines  sl ON sl.order_id = o.order_id
    GROUP BY 1
)
SELECT
    month,
    ROUND(revenue, 2) AS revenue,
    ROUND(100.0 * (revenue - LAG(revenue) OVER (ORDER BY month))
          / LAG(revenue) OVER (ORDER BY month), 2) AS mom_change_pct,
    CASE WHEN ROW_NUMBER() OVER (ORDER BY month) >= 3
         THEN ROUND(AVG(revenue) OVER (ORDER BY month ROWS BETWEEN 2 PRECEDING AND CURRENT ROW), 2)
    END AS rolling_3m_avg
FROM monthly
ORDER BY month;
-- Answer: Yes, there is a clear and repeating seasonal pattern: revenue falls from July to December in both years, then climbs steadily from January to a June peak. The quietest month is December (R29.9m in Dec 2023, R32.6m in Dec 2024), with a drop of about 13% on November each year.

-- Task 8: Why has the margin moved?
WITH line_fy AS (
    SELECT
        p.product_line,
        CASE WHEN o.order_date <= DATE '2024-06-30' THEN 'FY2024' ELSE 'FY2025' END AS fy,
        SUM(sl.line_revenue) AS revenue,
        SUM(sl.cogs)         AS cogs
    FROM sales_lines  sl
    JOIN sales_orders o ON o.order_id = sl.order_id
    JOIN products     p ON p.sku      = sl.sku
    GROUP BY 1, 2
)
SELECT
    product_line,
    fy,
    ROUND(revenue, 2)                                              AS revenue,
    ROUND(100.0 * (revenue - cogs) / revenue, 2)                   AS gross_margin_pct,
    ROUND(100.0 * revenue / SUM(revenue) OVER (PARTITION BY fy), 2) AS share_of_revenue_pct
FROM line_fy
ORDER BY product_line, fy;
-- Answer: The decline is a product-mix effect, not a pricing or cost problem. Every line's own margin is essentially unchanged between years (Bulk Commercial 19.89% to 19.91%, House Blend 38.32% to 38.34%, Single Origin 44.24% to 44.31%, Capsules 39.01% to 38.79%, Decaf 35.85% to 35.81%). What changed is the mix: Bulk Commercial, the lowest-margin line at about 19.9%, grew from R110.3m to R161.5m (+46%) and its share of revenue rose from 25.0% to 33.7%, while every other line's revenue shrank and its share fell. Bulk Commercial added R51.2m while the other four lines lost R12.2m combined, so all of the R39.0m growth came from the thinnest-margin line. Applying FY2024 line margins to FY2025 revenue mix gives 33.0%, exactly the reported FY2025 margin.
