# sql-sales-performance-analysis
## Business Problem
Which regions, products, and sales reps are driving the most revenue,
and where is performance falling short?

## Dataset
~1,230 rows of sales order data covering region, product, sales rep,
order status, revenue, and order dates. The raw data was intentionally
messy: 4 different date formats, split product categories (e.g.
"Webcam" vs "Web Cam"), and currency-formatted revenue stored as text.

## Approach
- Cleaned inconsistent date formats using CASE WHEN + STR_TO_DATE
- Merged split product category labels
- Stripped currency symbols/commas and converted revenue to numeric
- Ran 8 analytical SQL queries covering regional performance, top
  products, sales rep rankings, monthly trends, and order status

## Key Findings
1. Kano generates the highest regional revenue (₦79.9M), while
   Port-Harcourt trails all regions (₦46.2M).
2. Laptops are the single biggest revenue driver (₦116.7M).
3. Four of six regions perform above the company average revenue.
4. Only 26.12% of orders reach Completed status; 51.55% are lost to
   Cancellations and Refunds combined.
5. Sales rep performance varies significantly within regions in
   Abuja, the top performer generated over 3x the lowest-ranked rep.

## Recommendations
1. Investigate the Cancelled/Refunded rate first, likely the
   highest-impact issue in the dataset.
2. Investigate underperformance in Port-Harcourt and Enugu.
3. Prioritize Laptops in inventory/marketing given their revenue share.
4. Review sales rep training to address significant within-region performance gaps.

## SQL Queries
See `sales_analysis.sql` for the full set of queries with comments.
