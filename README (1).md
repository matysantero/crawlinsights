-- CrawlInsights: Screaming Frog export table
-- Upload the Screaming Frog CSV export to S3 before running this DDL

CREATE EXTERNAL TABLE IF NOT EXISTS crawlinsights.screaming_frog (
  address             STRING,
  content_type        STRING,
  status_code         STRING,
  indexability        STRING,
  indexability_status STRING,
  title               STRING,
  canonical_link      STRING,
  robots_1            STRING
)
ROW FORMAT SERDE 'org.apache.hadoop.hive.serde2.OpenCSVSerde'
WITH SERDEPROPERTIES (
  'separatorChar' = ',',
  'quoteChar'     = '"',
  'escapeChar'    = '\\'
)
STORED AS TEXTFILE
LOCATION 's3://your-bucket-name/crawl-data/'
TBLPROPERTIES (
  'has_encrypted_data' = 'false',
  'skip.header.line.count' = '1'
);
