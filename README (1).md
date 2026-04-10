CrawlInsights — Server Log Analysis Pipeline on AWS
> Turning raw server logs into crawl budget intelligence — and AI Overview eligibility signals.
![AWS](https://img.shields.io/badge/AWS-S3%20%7C%20Athena-orange?logo=amazon-aws)
[![Status](https://img.shields.io/badge/Status-Used%20with%20real%20client-brightgreen)]()
---
The Problem
Every crawl budget audit starts the same way: download server logs, open Excel, manually classify thousands of URLs by status code, bot type, and frequency. It takes days and doesn't scale.
CrawlInsights automates that pipeline on AWS — from raw log ingestion to a classified, queryable dataset — and adds a layer most SEO tools miss: which URLs are eligible to appear in AI-generated responses (Google AI Overviews, ChatGPT, Gemini).
---
How It Works
No custom ETL servers. No code to deploy. The pipeline runs entirely on managed AWS services:
```
Client delivers logs (Apache / Nginx / CDN)
         │
         ▼
┌─────────────────────┐
│     Amazon S3       │  ← raw logs stored date-partitioned
│  (raw partition)    │
└────────┬────────────┘
         │
         ▼
┌─────────────────────┐     ┌──────────────────────────┐
│   Amazon Athena     │ ◀── │  Screaming Frog export   │
│  (SQL over S3)      │     │  (crawl status, index-   │
│                     │     │   ability, titles)        │
└────────┬────────────┘     └──────────────────────────┘
         │
         ▼
┌─────────────────────┐
│  Classified views   │  ← URL categories, crawl waste,
│  + Analysis tabs    │    AI eligibility signals
└────────┬────────────┘
         │
         ▼
   CSV Report → Client
```
The key step is the cross-reference between server logs and the Screaming Frog crawl export: logs tell you what Googlebot actually visited and how often; Screaming Frog tells you whether those URLs should have been visited at all (indexability, canonical, noindex status).
---
URL Classification
Category	Description
`crawlable`	Successfully crawled, indexable, no issues
`blocked`	Disallowed by robots.txt or noindex — but still being crawled
`redirected`	301/302 — crawl budget spent on redirect chains
`ai_eligible`	High frequency + indexable + structured content signals
`error`	4xx / 5xx responses receiving crawl budget
`orphan`	Crawled but absent from sitemap
`waste`	Probes and attacks (/.env, /.git, /cgi-bin, wp-login)
The `waste` and `blocked` categories are where most crawl budget leaks hide. The `ai_eligible` classification is the differentiator — it identifies pages with the crawl signals that correlate with appearance in AI-generated answers.
---
Stack
Service	Role
Amazon S3	Raw log storage (date-partitioned) and processed output
Amazon Athena	Serverless SQL queries directly over S3
Screaming Frog	Full-site crawl export (CSV) — cross-referenced in Athena
AWS IAM	Least-privilege roles for S3 read/write and Athena execution
No servers provisioned. No ETL pipeline to maintain. Query cost on Athena for a 500k-line log file: under $0.01.
---
Sample Queries
Two illustrative queries are shown below. The full classification framework — including crawl waste detection, AI eligibility scoring, and the cross-reference methodology with Screaming Frog — is part of the proprietary CrawlInsights analysis framework and is not published here.
```sql
-- KPI summary: total hits and error rate
WITH base AS (
  SELECT
    COUNT(*) AS total_hits,
    SUM(CASE WHEN try_cast(status AS integer) >= 400 THEN 1 ELSE 0 END) AS err_hits
  FROM crawlinsights.logs_raw
)
SELECT 'total_hits' AS metric, CAST(total_hits AS varchar) AS value FROM base
UNION ALL
SELECT 'err_pct', CAST(ROUND(100.0 * err_hits / NULLIF(total_hits, 0), 2) AS varchar) FROM base;
```
```sql
-- Top error URLs by crawl frequency
SELECT
  path,
  hits,
  log_status
FROM crawlinsights.v_high_hits_errors
ORDER BY hits DESC
LIMIT 50;
```
---
Analysis Output
Each audit produces a structured workbook with the following tabs:
Tab	Content
README	Priority legend, column definitions, owner assignments
KPIs	Total hits, error rate, key metrics for client presentation
Top Errors	Actionable 4xx/5xx list ordered by crawl frequency
SEO Critical	Non-indexable URLs receiving significant crawl budget
Waste / Attack	Crawl budget drained by probes and vulnerability scanners
SEO Real	Clean crawl view — legitimate traffic separated from noise
Action Plan	Prioritized backlog (P0→P3) with owner, SLA, and validation
---
Results
Reduced manual audit time from ~3 days to ~2 hours for a 500k-line log file
Identified 12% of crawl budget wasted on redirected, blocked, and probe URLs
Surfaced AI-eligible pages before the client had encountered the term "AI Overviews"
> Used with a real paying client in 2024. The methodology behind this pipeline became the foundation for [GEOscore](https://github.com/matysantero/geoscore).
---
Setup (replicate the pipeline)
Prerequisites
AWS account with S3 and Athena enabled
Screaming Frog (any version with CSV export)
AWS CLI configured (`aws configure`)
Steps
```bash
# 1. Upload server logs to S3 (date-partitioned)
aws s3 cp access.log s3://your-bucket/logs/year=2024/month=01/day=15/

# 2. Create Athena database and table pointing to S3 partition
# See sql/create_table.sql for the DDL

# 3. Upload Screaming Frog export to S3
aws s3 cp screaming_frog_export.csv s3://your-bucket/crawl-data/

# 4. Create Athena table for Screaming Frog data
# See sql/create_sf_table.sql

# 5. Run analysis — start with sql/kpis.sql
```
---
Screenshots
S3 bucket — `crawlinsights-mvp-matias`  
Two root folders: `logs/` for raw server logs and `crawl/` for Screaming Frog exports.
![S3 bucket structure](screenshots/s3-bucket.png)
Athena — KPI query  
Database `crawlinsights` with 3 tables and 3 views. KPI query returning total hits, error hits, and error rate from real log data.
![Athena KPI query](screenshots/athena-kpis.png)
Athena — Waste/Attack classification query  
32,265 rows classified across `waste_env_probe`, `waste_random_path`, and other categories. Identifies crawl budget drain from vulnerability scanners and bots.
![Athena waste classification](screenshots/athena-waste.png)
---
Project Context
CrawlInsights started as a manual process: download logs, paste into Excel, classify by hand. Every audit took days. Building this pipeline on AWS turned a 3-day process into 2 hours — and revealed patterns that manual analysis consistently missed, like the correlation between crawl frequency and AI Overview appearance.
That same problem-solving approach — automate what's repetitive, instrument what matters — is what drives my transition from technical SEO to cloud engineering.
---
Related Projects
GEOscore — AWS-native pipeline that scores AI visibility using Bedrock. CrawlInsights is its analytical foundation.
Loft Gigóia — Real business site on AWS Lightsail + CloudFront. Live GEO proof of concept.
BIA — HA containerized app on ECS Fargate with full CI/CD.
---
Author
Matias Santero · Technical SEO & AWS  
linkedin.com/in/matias-santero-ojeda · loftgigoiarj.com.br
