SELECT COUNT(*) AS total_bookings
FROM bookings;

-- Q1: Cancellation rate by hotel
SELECT hotel,
       COUNT(*) AS total_bookings,
       SUM(is_canceled) AS cancelled,
       ROUND(AVG(is_canceled) * 100, 1) AS cancel_rate_pct
FROM bookings
GROUP BY hotel
ORDER BY cancel_rate_pct DESC;

-- Q2: Cancellation rate by deposit type
SELECT deposit_type,
       COUNT(*) AS total_bookings,
       ROUND(AVG(is_canceled) * 100, 1) AS cancel_rate_pct
FROM bookings
GROUP BY deposit_type
ORDER BY cancel_rate_pct DESC;

-- Q3: Who makes non-refundable bookings?
SELECT market_segment,
       COUNT(*) AS total_bookings,
       ROUND(AVG(is_canceled) * 100, 1) AS cancel_rate_pct
FROM bookings
WHERE deposit_type = 'Non Refund'
GROUP BY market_segment
ORDER BY total_bookings DESC;

-- Q4: Cancellation rate by lead time
SELECT CASE
         WHEN lead_time <= 7   THEN '0-7 days'
         WHEN lead_time <= 30  THEN '8-30 days'
         WHEN lead_time <= 90  THEN '31-90 days'
         WHEN lead_time <= 180 THEN '91-180 days'
         ELSE '181+ days'
       END AS lead_time_group,
       COUNT(*) AS total_bookings,
       ROUND(AVG(is_canceled) * 100, 1) AS cancel_rate_pct
FROM bookings
GROUP BY lead_time_group
ORDER BY MIN(lead_time);

-- Setup: lookup table to put months in calendar order
CREATE TABLE IF NOT EXISTS months (
    month_name TEXT PRIMARY KEY,
    month_num  INTEGER
);

INSERT OR IGNORE INTO months (month_name, month_num) VALUES
('January',1), ('February',2), ('March',3), ('April',4),
('May',5), ('June',6), ('July',7), ('August',8),
('September',9), ('October',10), ('November',11), ('December',12);

SELECT * FROM months;

-- Q5: Cancellation rate by arrival month (calendar order)
SELECT m.month_num,
       b.arrival_date_month AS month,
       COUNT(*) AS total_bookings,
       ROUND(AVG(b.is_canceled) * 100, 1) AS cancel_rate_pct
FROM bookings AS b
JOIN months AS m
  ON b.arrival_date_month = m.month_name
GROUP BY m.month_num, b.arrival_date_month
ORDER BY m.month_num;

-- Q6: Estimated revenue lost to cancellations (in millions of euros)
SELECT hotel,
       ROUND(SUM(CASE WHEN is_canceled = 1
                      THEN adr * (stays_in_weekend_nights + stays_in_week_nights)
                      ELSE 0 END) / 1000000.0, 2) AS lost_revenue_millions,
       ROUND(SUM(CASE WHEN is_canceled = 0
                      THEN adr * (stays_in_weekend_nights + stays_in_week_nights)
                      ELSE 0 END) / 1000000.0, 2) AS earned_revenue_millions
FROM bookings
GROUP BY hotel
ORDER BY lost_revenue_millions DESC;