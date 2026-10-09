-- HR Analytics Project
-- Compatible with MySQL 8+
-- Import the Employee_Data sheet as table: employees

CREATE DATABASE IF NOT EXISTS hr_analytics;
USE hr_analytics;

CREATE TABLE IF NOT EXISTS employees (
    EmployeeID VARCHAR(20) PRIMARY KEY,
    Age INT,
    Gender VARCHAR(20),
    Education VARCHAR(30),
    Department VARCHAR(50),
    JobRole VARCHAR(80),
    JobLevel VARCHAR(30),
    TenureYears DECIMAL(5,1),
    PerformanceScore DECIMAL(3,1),
    EngagementScore DECIMAL(3,1),
    SatisfactionScore DECIMAL(3,1),
    SalaryINR INT,
    Overtime VARCHAR(10),
    RemoteWork VARCHAR(10),
    MaritalStatus VARCHAR(20),
    Attrition VARCHAR(10)
);

-- 1. Overall HR KPIs
SELECT
    COUNT(*) AS total_employees,
    SUM(Attrition = 'Yes') AS attrition_count,
    ROUND(100 * SUM(Attrition = 'Yes') / COUNT(*), 2) AS attrition_rate_pct,
    ROUND(AVG(PerformanceScore), 2) AS avg_performance,
    ROUND(AVG(EngagementScore), 2) AS avg_engagement,
    ROUND(AVG(TenureYears), 2) AS avg_tenure
FROM employees;

-- 2. Department-wise headcount and attrition
SELECT
    Department,
    COUNT(*) AS headcount,
    SUM(Attrition = 'Yes') AS attrition_count,
    ROUND(100 * SUM(Attrition = 'Yes') / COUNT(*), 2) AS attrition_rate_pct,
    ROUND(AVG(PerformanceScore), 2) AS avg_performance,
    ROUND(AVG(EngagementScore), 2) AS avg_engagement
FROM employees
GROUP BY Department
ORDER BY attrition_rate_pct DESC;

-- 3. Sales vs non-Sales attrition risk
WITH rates AS (
    SELECT
        CASE WHEN Department = 'Sales' THEN 'Sales' ELSE 'Non-Sales' END AS group_name,
        AVG(Attrition = 'Yes') AS attrition_rate
    FROM employees
    GROUP BY CASE WHEN Department = 'Sales' THEN 'Sales' ELSE 'Non-Sales' END
)
SELECT
    MAX(CASE WHEN group_name='Sales' THEN attrition_rate END) AS sales_attrition_rate,
    MAX(CASE WHEN group_name='Non-Sales' THEN attrition_rate END) AS non_sales_attrition_rate,
    ROUND(
        100 * (
            MAX(CASE WHEN group_name='Sales' THEN attrition_rate END) /
            MAX(CASE WHEN group_name='Non-Sales' THEN attrition_rate END) - 1
        ), 2
    ) AS sales_relative_risk_pct
FROM rates;

-- 4. Attrition by tenure band
SELECT
    CASE
        WHEN TenureYears < 2 THEN '0-2 Years'
        WHEN TenureYears < 5 THEN '2-5 Years'
        WHEN TenureYears < 10 THEN '5-10 Years'
        ELSE '10+ Years'
    END AS tenure_band,
    COUNT(*) AS headcount,
    ROUND(100 * AVG(Attrition = 'Yes'), 2) AS attrition_rate_pct
FROM employees
GROUP BY tenure_band
ORDER BY attrition_rate_pct DESC;

-- 5. Performance vs attrition
SELECT
    PerformanceScore,
    COUNT(*) AS employees,
    ROUND(100 * AVG(Attrition = 'Yes'), 2) AS attrition_rate_pct
FROM employees
GROUP BY PerformanceScore
ORDER BY PerformanceScore;

-- 6. Engagement vs attrition
SELECT
    ROUND(EngagementScore, 0) AS engagement_band,
    COUNT(*) AS employees,
    ROUND(100 * AVG(Attrition = 'Yes'), 2) AS attrition_rate_pct
FROM employees
GROUP BY ROUND(EngagementScore, 0)
ORDER BY engagement_band;

-- 7. Overtime risk
SELECT
    Overtime,
    COUNT(*) AS employees,
    ROUND(100 * AVG(Attrition = 'Yes'), 2) AS attrition_rate_pct
FROM employees
GROUP BY Overtime;

-- 8. High-risk employee segment
SELECT
    EmployeeID, Department, JobRole, TenureYears,
    PerformanceScore, EngagementScore, SatisfactionScore,
    Overtime, Attrition
FROM employees
WHERE EngagementScore <= 2.5
  AND SatisfactionScore <= 2.5
  AND TenureYears < 3
ORDER BY EngagementScore, SatisfactionScore;

-- 9. Department performance
SELECT
    Department,
    COUNT(*) AS headcount,
    ROUND(AVG(PerformanceScore), 2) AS avg_performance,
    ROUND(AVG(EngagementScore), 2) AS avg_engagement,
    ROUND(AVG(SatisfactionScore), 2) AS avg_satisfaction
FROM employees
GROUP BY Department
ORDER BY avg_performance DESC;