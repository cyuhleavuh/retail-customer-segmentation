import pandas as pd
import sqlite3

conn = sqlite3.connect("retail.db")

tables = {
    "cln_sales": "data/cln_sales.parquet",  # main table: revenue, orders, RFM
    "sales": "data/sales.parquet",          # completed orders, for cancellation rate (Q3)
    "cncld": "data/cncld.parquet",          # cancellations (Q3)
}

for name, path in tables.items():
    df = pd.read_parquet(path)
    df = df.rename(columns={"Customer ID": "CustomerID"})   # rename so the column can be used in SQL without quotes
    df.to_sql(name, conn, if_exists="replace", index=False)
    print(f"{name}: {len(df):,} rows loaded")

conn.close()