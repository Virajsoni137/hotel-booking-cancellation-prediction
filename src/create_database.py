import sqlite3
import pandas as pd

df = pd.read_csv("data/hotel_bookings.csv")

conn = sqlite3.connect("data/hotel_bookings.db")
df.to_sql("bookings", conn, if_exists="replace", index=False)
conn.close()

print(f"Saved {len(df)} rows to data/hotel_bookings.db (table: bookings)")