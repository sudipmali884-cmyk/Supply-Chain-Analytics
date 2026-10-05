# ============================================================

import random

import pandas as pd

from faker import Faker

# ============================================================
# STEP 1 - CONFIGURATION
# ============================================================

TOTAL_DELIVERIES = 500000

random.seed(600)

Faker.seed(600)

fake = Faker("en_IN")


# ============================================================
# STEP 2 - LOAD SHIPMENT DATA
# ============================================================

shipment_df = pd.read_csv(
    "../../data/raw/shipments.csv"
)

# step 3 - valid shipment data
valid_shipments=shipment_df[
    shipment_df["shipment_id"].notna()
].copy()

# step 3 - remove duplicate ids
valid_shipments=shipment_df[
    shipment_df["shipment_id"].notna()
    &
    shipment_df["shipment_id"].astype(str)
    .str.match(r"^SHP\d{7}$")
].copy()

# clean shipment date
valid_shipments["shipment_date"]=pd.to_datetime(
    valid_shipments["shipment_date"],
    errors="coerce"
)
valid_shipments["expected_delivery_date"]=pd.to_datetime(
    valid_shipments["expected_delivery_date"],
    errors="coerce"
) # this both generate pure date formant not other date
# if we want only date use this


# remove invalid dates
valid_shipments=valid_shipments[valid_shipments["shipment_date"].notna()
&
valid_shipments["expected_delivery_date"].notna()
].copy()
# this will remove only NaN/None but date like sdjfksh,w39847u this alsonn print


# remove duplicate shipment ids
valid_shipments=valid_shipments.drop_duplicates(
    subset=["shipment_id"]
)
# shipment id list
shipment_ids=(
    valid_shipments["shipment_id"]
    .tolist()
)

# step 8 - shipment date lookup
shipment_date_map= dict(
    zip(
        valid_shipments["shipment_id"],
        valid_shipments["shipment_date"]
    )
)
# step 9 - exepected delevery date lookup
expected_delivery_map=dict(
    zip(
        valid_shipments["shipment_id"],
        valid_shipments["expected_delivery_date"]
    )
)
# ============================================================
# STEP 6 - SHIPMENT DATE LOOKUP
# ============================================================

'''
this is same for 
shipment_date_map = dict(

    zip(

        valid_shipments[
            "shipment_id"
        ],

        pd.to_datetime(

            valid_shipments[
                "shipment_date"
            ],

            errors="coerce"

        )

    )

)'''

# ============================================================
# STEP 8 - DELIVERY STATUS
# ============================================================

delivery_statuses = [

    "Delivered",

    "Delayed",

    "Out for Delivery",

    "Failed",

    "Returned",

    "Pending"

]


delivery_status_weights = [

    60,

    12,

    8,

    6,

    5,

    9

]


# ============================================================
# STEP 9 - DELIVERY PARTNERS
# ============================================================

delivery_partners = [

    "Delhivery",

    "Blue Dart",

    "DHL",

    "FedEx",

    "Ecom Express",

    "DTDC",

    "XpressBees",

    "Ekart",

    "Shadowfax"

]


# ============================================================
# STEP 10 - DELIVERY PARTNER WEIGHTS
# ============================================================

delivery_partner_weights = [

    25,

    15,

    10,

    10,

    12,

    10,

    8,

    6,

    4

]

# step 11- delivery attempts

def generate_delivery_attempts(
        delivery_status
):
    if delivery_status=="Delivered":
        return  random.choices(
            [1,2,3],
            weights=[85,10,5]
        )[0]

    elif delivery_status=="Failed":
        return random.choices(
            [1,2,3],
            weights=[50,30,20]
        )[0]

    elif delivery_status=="Returned":
        return random.randint(1,3)
    else:
        return 1


# step 12 id generator delivery

def generate_delivery_id(number):
    return f"DEL{number:07d}"

rows=[]
for i in range(1, TOTAL_DELIVERIES + 1):
    delivery_id = generate_delivery_id(i)

    shipment_id=random.choice(shipment_ids)
    shipment_date=shipment_date_map.get(shipment_id)

    #handled invalid shipment date
    if pd.isna(
        shipment_date
    ):
        shipment_date=pd.Timestamp("2024-01-01")
# If somehow the lookup fails, you use:
    #
    # 2024-01-01
    #
    # as a fallback.

#     expected delivery date

    expected_delivery_date=(
        expected_delivery_map.get(shipment_id)
    )

    if pd.isna(expected_delivery_date):
        expected_delivery_date=(
            shipment_date + pd.Timedelta(
            days=random.randint(2,10)
        )
    )

    delivery_status=random.choices(
        delivery_statuses,
        weights=delivery_status_weights
    )[0]

    delivery_partner= random.choices(
        delivery_partners,
        weights=delivery_partner_weights
    )[0]

    delivery_attempts=(
        generate_delivery_attempts(
            delivery_status
        )
    )


    actual_delivery_date=None
    if delivery_status=="Delivered":
        delay_days=random.randint(
            -2,7
        )
        actual_delivery_date=(
            expected_delivery_date + pd.Timedelta(
            days=delay_days
        )
        )

    elif delivery_status == "Delayed":
        delay_days=random.randint(3,20)
        actual_delivery_date=(
            expected_delivery_date + pd.Timedelta(days=delay_days)
    )
    elif delivery_status=="Returned":
        delay_days=random.randint(2,15)
        actual_delivery_date=(
            expected_delivery_date + pd.Timedelta(days=delay_days)
    )

    if actual_delivery_date is not None:
        delay_days= (
            actual_delivery_date - expected_delivery_date
        ).days
    else:
        delay_days=0

    delivery_city = fake.city()

    recipient_name=fake.name()

    recipient_phone = str(
        random.randint(6000000000,9999999999)
    )
    # create record
    rows.append({
        "delivery_id":
            delivery_id,

        "shipment_id":
            shipment_id,

        "delivery_partner":
            delivery_partner,

        "expected_delivery_date":
            expected_delivery_date.date(),

        "actual_delivery_date":
            (
                actual_delivery_date.date()
                if actual_delivery_date is not None
                else None
            ),

        "delay_days":
            delay_days,

        "delivery_attempts":
            delivery_attempts,

        "delivery_city":
            delivery_city,

        "recipient_name":
            recipient_name,

        "recipient_phone":
            recipient_phone,

        "delivery_status":
            delivery_status
    })

# step 14 - create dataframe
delivery_df=pd.DataFrame(rows)


print(
    "Cleaned data generated"
)

print(
    "Dirty data generating"
)


duplicate_rows=delivery_df.sample(1500,random_state=100)
delivery_df=pd.concat([delivery_df,duplicate_rows],ignore_index=True)

# wrong sjipment id

idx=random.sample(range(len(delivery_df)),1000)
dirty_shipment_ids=["","SHP11111111111","Unknown",None]
delivery_df.loc[idx,"shipment_id"]=[random.choice(
    dirty_shipment_ids
)
for _ in idx]
print(f"Total wrong shipment{len(idx)}")

# dirty delivery partner
ddp=random.sample(range(len(delivery_df)),2000)
bad_partner=["Wrong partner","Unknown","",None,"This partner is not good"]
delivery_df.loc[ddp,"delivery_partner"]=[
    random.choice(bad_partner)
    for _ in ddp
]
print(f"Total bad partner : {len(ddp)}")

# dirty delivery delay_days
print(delivery_df["delay_days"].dtype)
delivery_df["delay_days"]=delivery_df["delay_days"].astype("object")
dd=random.sample(range(len(delivery_df)),1000)
bad_delays=[-100,-10,0,9999,None,]
delivery_df.loc[dd,"delay_days"]=[
    random.choice(bad_delays)
    for _ in dd
]
print(delivery_df["delay_days"].dtype)
print(f"Total bad delays days : {len(dd)}")

# wrong delivery city
wc=random.sample(range(len(delivery_df)),2000)
delivery_df.loc[wc,"delivery_city"]=( "  "+ delivery_df.loc[wc,"delivery_city"].astype(str)+ "  ")
print(f"Total extra spaces data: {len(wc)}")
# # extra space in stock condition
# es=random.sample(range(len(inventory_df)),1450)
# inventory_df.loc[es,"stock_conditon"]=( " # "+inventory_df.loc[es,"stock_condition"].astype(str)+ " # ")
# print(f"Total extra spaces date : {len(es)}")

dc=random.sample(range(len(delivery_df)),5000)
bad_city=["Darganhalli","Shelagi","Akkalkot","",None]

delivery_df.loc[dc,"delivery_city"]=[
    random.choice(bad_city)
    for _ in dc
]
print(f"Total wrong city: {len(dc)}")
# upper casae recipent name
uc=random.sample(range(len(delivery_df)),2500)
delivery_df.loc[uc,"recipient_name"]=(delivery_df.loc[uc,"recipient_name"].astype(str).str.upper())

print(f"Total Wrong Case : {len(uc)}")
# # wrong case
# wc=random.sample(range(len(warehouse_df)),600)
# warehouse_df.loc[wc,"city"]=(warehouse_df.loc[wc,"city"].astype(str).str.upper())

# bad phone
wp=random.sample(range(len(delivery_df)),2150)
bad_phone=["","1234567890","qwerty","80105894231"]
delivery_df.loc[wp,"recipient_phone"]=[
    random.choice(bad_phone)
    for _ in wp
]
print(f"total bad phone : {len(wp)}")
# blank status
bs=random.sample(range(len(delivery_df)),2300)
delivery_df.loc[bs,"delivery_status"]=""
print(f"Total Blank status : {len(bs)}")

# step 26 - saave csv
delivery_df.to_csv("../../data/raw/deliveries.csv",index=False)
print(f"Total Records : {len(delivery_df)}")