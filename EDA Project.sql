-- Exploratory Data Analysis on Layoffs Dataset

-- View all data
SELECT *
FROM layoffs_staging5;

-- Find maximum total layoffs and maximum layoff percentage
SELECT MAX(total_laid_off), MAX(percentage_laid_off)
FROM layoffs_staging5;

-- Companies with 100% layoffs, ordered by funds raised
SELECT *
FROM layoffs_staging5
WHERE percentage_laid_off = 1
ORDER BY funds_raised_millions DESC;

-- Total layoffs by company (most affected companies)
SELECT company, SUM(total_laid_off) AS total_layoffs
FROM layoffs_staging5
GROUP BY company
ORDER BY total_layoffs DESC;

-- Date range of the layoffs
SELECT MIN(`date`) AS first_layoff_date, MAX(`date`) AS last_layoff_date
FROM layoffs_staging5;

-- Total layoffs by industry
SELECT industry, SUM(total_laid_off) AS total_layoffs
FROM layoffs_staging5
GROUP BY industry
ORDER BY total_layoffs DESC;

-- Total layoffs by year
SELECT YEAR(`date`) AS year, SUM(total_laid_off) AS total_layoffs
FROM layoffs_staging5
GROUP BY year
ORDER BY total_layoffs DESC;

-- Total layoffs by funding stage
SELECT stage, SUM(total_laid_off) AS total_layoffs
FROM layoffs_staging5
GROUP BY stage
ORDER BY total_layoffs DESC;

-- Monthly layoffs
SELECT SUBSTRING(`date`, 1, 7) AS month, SUM(total_laid_off) AS monthly_layoffs
FROM layoffs_staging5
WHERE SUBSTRING(`date`, 1, 7) IS NOT NULL
GROUP BY month
ORDER BY month ASC;

-- Rolling total layoffs by month
WITH Rolling_Total AS (
    SELECT SUBSTRING(`date`, 1, 7) AS month, SUM(total_laid_off) AS total_off
    FROM layoffs_staging5
    WHERE SUBSTRING(`date`, 1, 7) IS NOT NULL
    GROUP BY month
)
SELECT month, total_off,
       SUM(total_off) OVER (ORDER BY month) AS rolling_total
FROM Rolling_Total;

-- Yearly layoffs per company
SELECT company, YEAR(`date`) AS year, SUM(total_laid_off) AS yearly_layoffs
FROM layoffs_staging5
GROUP BY company, year
ORDER BY yearly_layoffs DESC;

-- Top 5 companies with the most layoffs per year
WITH Company_Year AS (
    SELECT company, YEAR(`date`) AS year, SUM(total_laid_off) AS total_laid_off
    FROM layoffs_staging5
    GROUP BY company, year
),
Company_Year_Rank AS (
    SELECT *,
           DENSE_RANK() OVER (PARTITION BY year ORDER BY total_laid_off DESC) AS ranking
    FROM Company_Year
    WHERE year IS NOT NULL
)
SELECT *
FROM Company_Year_Rank
WHERE ranking <= 5;
