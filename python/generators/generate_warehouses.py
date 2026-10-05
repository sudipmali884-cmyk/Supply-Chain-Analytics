import  random
import pandas as pd
from faker import Faker

from generators.generate_suppliers import state_weights, city_weights

# step 1 - configuration
TOTAL_WAREHOUSES= 200000
random.seed(100)
Faker.seed(100)

fake=Faker("en_IN")

# step 2-8 mappings
from utils.mappings import (
    warehouse_type_weights,country_weights,country_state_map,
    state_city_map,storage_type_weights,warehouse_statuses,warehouse_status_weights
)
# step 9 - warehouse id

def generate_warehouse_id(number):
    return f"WH{number:06d}"

# step 10 - generate warehouse records
rows=[]
for i in range(1, TOTAL_WAREHOUSES +1):
    warehouse_id=generate_warehouse_id(i)

    warehouse_type=random.choices(
        list(warehouse_type_weights.keys()),
        weights=list(warehouse_type_weights.values())
    )[0]

    # country
    country=random.choices(
        list(country_weights.keys()),
        weights=list(country_weights.values())
    )[0]

    # state/region

    state_weights=(country_state_map[country])
    state=random.choices(
        list(state_weights.keys()),
        weights=list(state_weights.values())
    )[0]

    # city
    city_weights=(state_city_map[state])

    city=random.choices(
        list(city_weights.keys()),
        weights=list(city_weights.values())
    )[0]
    # warehouse name
    warehouse_name=(
        f"{city} "
        f"{warehouse_type} "
        f"{random.randint(100,99999)}"

    )

    # storage type

    storage_type=random.choices(
        list(storage_type_weights.keys()),
        weights=list(storage_type_weights.values())
    )[0]
    # capacity


    if warehouse_type=="Distribution Center":
        capacity_units=random.randint(
            50000,500000
        )

    elif warehouse_type == "Fulfillment Center":

        capacity_units = random.randint(
            30000,
            300000
        )

    elif warehouse_type == "Regional Warehouse":

        capacity_units = random.randint(
            10000,
            150000
        )


    elif warehouse_type == "Cold Storage":

        capacity_units = random.randint(
            5000,
            100000
        )

    else:

        capacity_units = random.randint(
            1000,
            50000
        )
    # contact phone
    if country =="India":
        phone=str(random.randint(
            6000000000,9999999999
        ))
    else:
        phone=fake.phone_number()

    # postal code
    postal_code=fake.postcode()

    # warehouse status

    warehouse_status=random.choices(
        warehouse_statuses,
        weights=warehouse_status_weights
    )[0]

    # create record
    warehouse = {
        "warehouse_id":
            warehouse_id,

        "warehouse_name":
            warehouse_name,

        "warehouse_type":
            warehouse_type,

        "storage_type":
            storage_type,

        "country":
            country,

        "state":
            state,

        "city":
            city,

        "postal_code":
            postal_code,

        "capacity_units":
            capacity_units,

        "phone":
            phone,

        "warehouse_status":
            warehouse_status
    }
    rows.append(warehouse)

# step 11 create dataframes
warehouse_df=pd.DataFrame(rows)
print("Cleaned Data generated")
print("Dirty data generating ")

# duplicate rows step 12

duplicate_rows=warehouse_df.sample(
    1500,random_state=100
)
warehouse_df=pd.concat([warehouse_df,duplicate_rows],ignore_index=True)

# step 13 dirty warehouse_name
bwn=random.sample(range(len(warehouse_df)),1200)
warehouse_df.loc[bwn,"warehouse_name"]=[
    random.choice([
        value.upper(),value.lower(),
        f" {value}",f" {value} ",f"{value} "
    ])
    for value in warehouse_df.loc[
        bwn,"warehouse_name"
    ]
]
blank_rows=random.sample(range(len(warehouse_df)),999)
warehouse_df.loc[blank_rows,"warehouse_status"]=""

# step 14 dirty warehouse type
dwt=random.sample(range(len(warehouse_df)),1001)
dirty_warehouse_types = [

    "asjokrjher",
    "37rksfk",
    "234398539"
    "unknown",

    "N/A",

    "",

    None

]
warehouse_df.loc[dwt,"warehouse_type"]=[random.choice(
    dirty_warehouse_types
)
for _ in dwt
]

# step 15 - dirty storage type
rows=random.sample(range(len(warehouse_df)),400)
bad_storage=["very hot","very bad","unknown","","Faltu",None]
warehouse_df.loc[rows,"storage_type"]=[
    random.choice(bad_storage)
    for _ in rows
]
# wrong country
idx=random.sample(range(len(warehouse_df)),700)
wc=["Pakistan","Iran","America","solapur"]

warehouse_df.loc[idx,"country"]=[
    random.choice(wc)
    for _ in idx
]

# spaces in country

es=random.sample(range(len(warehouse_df)),300)
warehouse_df.loc[es,"country"]=(" # "+ warehouse_df.loc[es,"country"].astype(str) + " # ")

# wrong case
wc=random.sample(range(len(warehouse_df)),600)
warehouse_df.loc[wc,"city"]=(warehouse_df.loc[wc,"city"].astype(str).str.upper())


# wrong postal code
wrong_pc=random.sample(range(len(warehouse_df)),700)
warehouse_df.loc[wrong_pc,"postal_code"]=[random.choice([
    "","ABCDEF","123qwe","123456",None
])
for _ in wrong_pc]

# bad phone
print(warehouse_df["phone"].dtype)

warehouse_df["phone"] = warehouse_df["phone"].astype("object")
bad_phone=["","4532sfasd","1234562345",1231231234,None]
idx=random.sample(range(len(warehouse_df)),800)
warehouse_df.loc[idx,"phone"]=[
    random.choice(bad_phone)
    for _ in idx
]
print(warehouse_df["phone"].dtype)

# wrong status
bad_status=["Unknown","Deleivered","N/A","","Not Active"]
bad_s=random.sample(range(len(warehouse_df)),600)
warehouse_df.loc[bad_s,"warehouse_status"]=[
    random.choice(bad_status)
    for _ in bad_s
]

# save csv step 23
warehouse_df.to_csv("../../data/raw/warehouses.csv",index=False)
print("all generated ")
print(f"Total bad status: {len(bad_s)}")
