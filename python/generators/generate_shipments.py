
import random

import pandas as pd
from datetime import  date
from faker import Faker


# ============================================================
# STEP 1 - CONFIGURATION
# ============================================================

TOTAL_SHIPMENTS = 500000

random.seed(500)

Faker.seed(500)

fake = Faker("en_IN")


# ============================================================
# STEP 2 - LOAD ORDERS
# ============================================================

order_df = pd.read_csv(
    "../../data/raw/orders.csv"
)


# ============================================================
# STEP 3 - REMOVE NULL ORDER IDs
# ============================================================
valid_orders = order_df[
    order_df["order_id"]
    .notna()
    &
    order_df["order_id"]
    .astype(str)
    .str.match(r"^ORD\d{7}$")
    ].copy()


# step 4 - remove duplicate order ids
valid_orders=valid_orders.drop_duplicates(subset=["order_id"])

# get clean order id

order_ids=(valid_orders["order_id"].tolist())

# step 5 - orders id list
# order_ids=valid_orders["order_id"].tolist()


# step 6 - orderr date lookup

order_date_map= dict(
    zip(
        valid_orders["order_id"],
        pd.to_datetime(
            valid_orders["order_date"],
            errors="coerce"
        )
    )
)
# step 7 - expected delivary date lookup
expected_delivery_map = dict(
  zip(
      valid_orders["order_id"],
      pd.to_datetime(
          valid_orders["expected_delivery_date"],
          errors="coerce"


      )
  )
)

# step 8,9,10 - carriers
from utils.mappings import (
category_weights,shipment_statuses,shipment_status_weights,shipping_methods,
shipping_method_weights
)

# step 11 - shipment id generator

def generate_shipment_id(number):
    return f"SHP{number:07d}"

# step 12 - tracking number generator

def generate_tracking_number(
        carrier,number
):
    prefix_map={
        "Delhivery": "DEL",

        "Blue Dart": "BLU",

        "DHL": "DHL",

        "FedEx": "FED",

        "Ecom Express": "ECM",

        "DTDC": "DTC",

        "XpressBees": "XPR",

        "Ekart": "EKT",

        "Shadowfax": "SHF"
    }

    prefix=prefix_map.get(
        carrier,"TRK"
    )
    return (f"{prefix}"
            f"{number:010d}"
    )

    # step 13 - generate sshipment records

rows=[]
for i in range(1,TOTAL_SHIPMENTS + 1):
    shipment_id = generate_shipment_id(i)
    order_id=random.choice(order_ids)
    order_date=order_date_map.get(order_id)
    if pd.isna(order_date):
        order_date = pd.Timestamp("2024-01-01")

    carrier = random.choices(
        list(category_weights.keys()),
        weights=list(category_weights.values())
    )[0]

    shipping_method=random.choices(
        shipping_methods,
        weights=shipping_method_weights
    )[0]

    pickup_delay = random.randint(0,5)
    shipment_date = (order_date + pd.Timedelta(
        days=pickup_delay
    ))

    expected_delivery_date = (
      expected_delivery_map.get(
          order_id
      )
    )

    # --------------------------------------------------------
    # IF EXPECTED DELIVERY DATE INVALID
    # --------------------------------------------------------

    if pd.isna(
        expected_delivery_date
    ):
        expected_delivery_date = (
            shipment_date + pd.Timedelta(
            days=random.randint(2,10)
        )
        )

    # actual delivery date
    actual_delivery_date = None

    shipment_status= random.choices(
        shipment_statuses,weights= shipment_status_weights
    )[0]
    # delivery date based on status
    if shipment_status == "Delivered":
        delivery_delay = random.randint(
            -2 , 7
        )
        actual_delivery_date=(
            expected_delivery_date + pd.Timedelta(days=delivery_delay)
        )

    elif shipment_status=="Delayed":
        delivery_delay= random.randint(3,20)
        actual_delivery_date=(expected_delivery_date +
                              pd.Timedelta(days=delivery_delay))

    # tracking number

    tracking_number = generate_tracking_number(
        carrier,i
    )

    # shipping cost
    if shipping_method =="Same Day":
        shipping_cost = round(
            random.uniform(
                500,2500
            ),2
        )

    elif shipping_method =="Express":
        shipping_cost = round(
            random.uniform(
                300,1800
            ),2
        )
    elif shipping_method == "Air":
        shipping_cost= round(
            random.uniform(
                400,2500
            ),2
        )
    elif shipping_method == "Economy":
        shipping_cost=round(
            random.uniform(
                80,500
            ),2
        )
    else:
        shipping_cost=round(random.uniform(100,1000),2)
    # create record
    rows.append({
        "shipment_id":
            shipment_id,

        "order_id":
            order_id,

        "carrier":
            carrier,

        "shipping_method":
            shipping_method,

        "tracking_number":
            tracking_number,

        "shipment_date":
            shipment_date.date(),

        "expected_delivery_date":
            expected_delivery_date.date(),

        "actual_delivery_date":
            (
                actual_delivery_date.date()
                if not pd.isna(
                    actual_delivery_date
                )
                else None
            ),

        "shipping_cost":
            shipping_cost,

        "shipment_status":shipment_status
    })

# step 14 - create data frame
shipment_df = pd.DataFrame(rows)

print(
    "Cleaned data generated"
)

print(
    "Dirty data generating"
)

# step 15 - duplicate rows
duplicate_rows=shipment_df.sample(2000,random_state=100)
shipment_df=pd.concat([
    shipment_df,duplicate_rows
],ignore_index=True)


#  step 16 - dirty order id
shipment_df["order_id"]=shipment_df["order_id"].astype("object")
oi=random.sample(range(len(shipment_df)),2500)
bad_oi=["",12345678,"ORD123qwer","ABCDEF","ORD99999999"]
shipment_df.loc[oi,"order_id"]=[
    random.choice(bad_oi)
    for _ in oi
]

print("Total dirty order id : ",len(oi))

# carier

dc=random.sample(range(len(shipment_df)),1800)
dirty_carriers = [

    "",

    None,

    "delhivery",

    "DELHIVERY",

    " Delhivery",

    "Delhivery ",

    "BlueDart",

    "unknown",

    "N/A",

    "Fake Express"

]
shipment_df.loc[dc,"carrier"]=[
    random.choice(dirty_carriers)
    for _ in dc
]

print(f"Total dirty carriers : {len(dc)}")

# wrong case shipping method

idx=random.sample(range(len(shipment_df)), 1700)
shipment_df.loc[idx,"shipping_method"]= shipment_df.loc[idx,"shipping_method"].astype(str).str.upper()
print(f"wrong case date shipment_method: {len(idx)}")

# dirty tracking number

tn=random.sample(range(len(shipment_df)),2551)
bad_tracking=["","Unknown","123456","ABCDEFGH"]
shipment_df.loc[tn,"tracking_number"]=[
    random.choice(bad_tracking)
    for _ in tn
]
print(f"TOtal wrong tracking number : {len(tn)}")
# dirty shipping cost
shipment_df["shipping_cost"]=shipment_df["shipping_cost"].astype("object")
sc=random.sample(range(len(shipment_df)),1000)
bad_cost=[
    0,-50,-500, 1000000,None,
]
shipment_df.loc[sc,"shipping_cost"]=[random.choice(
    bad_cost)
    for _ in sc
]
print(f"Total cost : {len(sc)}")
# shipment_status
rows=random.sample(range(len(shipment_df)), 500)
shipment_df.loc[rows,"shipment_status"]=[random.choice([

    value.upper(),
    value.lower(),f" {value}", f"{value} ",f" {value} ",value.replace(" ","  ")

    ]
)
for value in shipment_df.loc[rows,"shipment_status"]
]
print(f"Total dirty date : {len(rows)}")
shipment_df.to_csv("../../data/raw/shipments.csv",index=False)
print(f"Total Records : {len(shipment_df)}")
