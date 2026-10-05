import random
import pandas as pd
from faker import Faker
from datetime import  date


# ============================================================
# STEP 1 - CONFIGURATION
# ============================================================

TOTAL_INVENTORY = 500000

random.seed(300)

Faker.seed(300)

fake = Faker("en_IN")


# ============================================================
# STEP 2 - LOAD PRODUCT DATA
# ============================================================

product_df = pd.read_csv(
    "../../data/raw/products_master.csv"
)


# ============================================================
# STEP 3 - LOAD WAREHOUSE DATA
# ============================================================

warehouse_df = pd.read_csv(
    "../../data/raw/warehouses.csv"
)
# step 4 - get valid products ids
# product_ids=(product_df["product_id"].dropna().drop_duplicates().tolist())
product_ids=(
    product_df["product_id"]
    .dropna().astype(str).loc[
        lambda x:x.str.match(r"^PRD\d{6}$")
    ].drop_duplicates()
    .tolist()
)
# ger valid warehouse ids
# warehouse_ids=(
#     warehouse_df["warehouse_id"].dropna().drop_duplicates().tolist()
# )
warehouse_ids=(
    warehouse_df["warehouse_id"]
    .dropna().astype(str).loc[
        lambda x:x.str.match(r"^WH\d{6}$")
    ]
    .drop_duplicates()
    .tolist()
)


# ============================================================
# STEP 6 - CREATE PRODUCT COST LOOKUP
# ============================================================
clean_product_df = product_df[
    product_df["product_id"]
    .notna()
    &
    product_df["product_id"]
    .astype(str)
    .str.match(r"^PRD\d{6}$")
    &
    (product_df["unit_cost"]>0)
    &
    (product_df["unit_cost"] <=150000)
].copy()

if "unit_cost" in clean_product_df.columns:

    product_cost_lookup = (
        clean_product_df
        .drop_duplicates(subset=["product_id"])
        .set_index("product_id")["unit_cost"]
        .to_dict()
    )

elif "cost_price" in product_df.columns:

    clean_product_df=product_df[
        product_df["product_id"]
        .notna()
        &
        product_df["product_id"]
        .astype(str)
        .str.match(r"^PRD\d{6}$")
        &
        product_df["cost_price"]
        .notna()
        &
        (product_df["cost_price"] > 0)
        &
        (product_df["cost_price"] <= 150000)
    ].copy()
    product_cost_lookup = (
        clean_product_df
        .drop_duplicates(subset=["product_id"])
        .set_index("product_id")["cost_price"]
        .to_dict()
    )

else:

    product_cost_lookup = {}

# ============================================================
# STEP 6 - INVENTORY STATUS
# ============================================================

inventory_statuses = [

    "Healthy",

    "Low Stock",

    "Out of Stock",

    "Overstock",

    "Reserved"
]


inventory_status_weights = [

    55,

    20,

    8,

    12,

    5
]


# ============================================================
# STEP 7 - STOCK CONDITION
# ============================================================

stock_conditions = [

    "Good",

    "Damaged",

    "Expired",

    "Under Inspection"
]


stock_condition_weights = [

    90,

    4,

    2,

    4
]

# step 8 - inventory date range

start_date = date(2022, 1, 1)
end_date = date(2026, 8, 19)

# step 9 - id generator

def generate_inventory_id(number):
    return  f"INV{number:07d}"

# generate inventory records step 10
rows=[]
for i in range(1,TOTAL_INVENTORY +1):
    inventory_id = generate_inventory_id(i)
    product_id=random.choice(product_ids)

    warehouse_id=random.choice(warehouse_ids)

    inventory_date = fake.date_between(
        start_date=date(2022, 1, 1),
        end_date=date(2026, 8, 19)
    )

    reorder_level=random.randint(20,1000)

    # quantity in habd
    quantity_on_hand=random.randint(
        0,5000
    )

    reserved_quantity=random.randint(0,min(quantity_on_hand,1000))
    available_quantity=(quantity_on_hand - reserved_quantity)

    # --------------------------------------------------------
    # STOCK STATUS
    #
    # Business logic instead of random status
    # --------------------------------------------------------

    if quantity_on_hand == 0:

        inventory_status = "Out of Stock"

    elif quantity_on_hand < reorder_level:

        inventory_status = "Low Stock"

    elif quantity_on_hand > (
            reorder_level * 5
    ):

        inventory_status = "Overstock"

    else:

        inventory_status = "Healthy"


    stock_condition = random.choices(
        stock_conditions,weights=stock_condition_weights
    )[0]

    #unit cost
    unit_cost=product_cost_lookup.get(
        product_id
    )
    if unit_cost is None or pd.isna(unit_cost):

        unit_cost=round(
            random.uniform(100,50000),2
        )



    inventory_value=round(
        quantity_on_hand * float(unit_cost),2
    )

    # last restock date

    last_restock_date=fake.date_between(
        start_date=start_date,
        end_date=inventory_date

    )
    rows.append({
        "inventory_id":
            inventory_id,

        "product_id":
            product_id,

        "warehouse_id":
            warehouse_id,

        "inventory_date":
            inventory_date,

        "quantity_on_hand":
            quantity_on_hand,

        "reserved_quantity":
            reserved_quantity,

        "available_quantity":
            available_quantity,

        "reorder_level":
            reorder_level,

        "unit_cost":
            round(
                float(unit_cost),
                2
            ),

        "inventory_value":
            inventory_value,

        "last_restock_date":
            last_restock_date,

        "inventory_status":
            inventory_status,

        "stock_condition":
            stock_condition
    })
# step 11- create dataframe
inventory_df=pd.DataFrame(rows)
print("Clean data generated ")

duplicate_rows=inventory_df.sample(1500,random_state=100)
inventory_df=pd.concat(
    [inventory_df,duplicate_rows],ignore_index=True
)
print("Duplicate rows added")
print(f"total duplicate rows{len(duplicate_rows)}")

# dirty product id

dp=random.sample(range(len(inventory_df)),2000)
bad_product_id=[
    "",None,"PROD99999999","239874hjsf","abc123"
]
inventory_df.loc[dp,"product_id"]=[random.choice(bad_product_id)
                                   for _ in dp]

print(f"Total Bad Product id: {len(dp)}")

# dirt warehouse id
bad_warehouse_id=["WH123asd","",None,"WH9999999j","Unknown"]
idx=random.sample(range(len(inventory_df)),2001)
inventory_df.loc[idx,"warehouse_id"]=[
    random.choice(bad_warehouse_id)
    for _ in idx
]
print(f"Total Wrong Warehouse id : {len(idx)}")

# dirty quantity on hand

print(inventory_df["quantity_on_hand"].dtype)
inventory_df["quantity_on_hand"] = inventory_df["quantity_on_hand"].astype("Int64")
rows=random.sample(range(len(inventory_df)),1500)
dirty_quantities=[-10,-50,-999,9999999,0,None]
inventory_df.loc[rows,"quantity_on_hand"]=[
    random.choice(dirty_quantities)
    for _ in rows
]
print(f"Total dirty quantity on hand : {len(rows)}")

# ============================================================
# STEP 21 - DIRTY INVENTORY VALUE
# ============================================================
print(inventory_df["inventory_value"].dtype)
inventory_df["inventory_value"]=inventory_df["inventory_value"].astype("object")
inventory_value_bad=random.sample(range(len(inventory_df)),1500)
dirty_quantities=[-100,-50,-999,99788999,0,None]
inventory_df.loc[inventory_value_bad,"inventory_value"]=[
    random.choice(dirty_quantities)
    for _ in inventory_value_bad
]
print(inventory_df["inventory_value"].dtype)

print(f"Total dirty inventory value : {len(inventory_value_bad)}")



# wrong inventoru status
bad_status=["Not Healthy","High stock","big stock","Unknown"]
wrong_status=random.sample(range(len(inventory_df)),1200)
inventory_df.loc[wrong_status,"inventory_status"]=[
    random.choice(bad_status)
    for _ in wrong_status
]
print(f"Total Bad Status : {len(wrong_status)}")

# extra space in stock condition
es=random.sample(range(len(inventory_df)),1450)
inventory_df.loc[es,"stock_condition"]=( "  "+inventory_df.loc[es,"stock_condition"].astype(str)+ "  ")
print(f"Total extra spaces date : {len(es)}")

print("Dirty Date GEnerated ")
print(f"Total records : {len(inventory_df)}")
inventory_df.to_csv("../../data/raw/inventory.csv",index=False)

print("All is Well")