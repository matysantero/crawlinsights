# Screenshots

## Files expected in this directory

| Filename | Content |
|---|---|
| `s3-bucket.png` | S3 console showing `crawlinsights-mvp-matias` bucket with `crawl/` and `logs/` folders |
| `athena-kpis.png` | Athena query editor — KPI query with results (blur the actual numbers) |
| `athena-waste.png` | Athena query editor — waste classification with 32k+ rows result |

## Before uploading — anonymize sensitive data

**athena-kpis.png:** blur or replace the values in the results panel (`total_hits`, `err_hits`, `err_pct`). Replace with plausible fictitious numbers like `127,450 / 8,920 / 7.01`.

**athena-waste.png:** already clean — no client domain visible. Upload as-is.

**s3-bucket.png:** already clean — bucket name is yours, no client data visible. Upload as-is.

## Tool for blurring on Mac
Preview → Markup tool → Rectangle shape over the values → fill with solid color.
