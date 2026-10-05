import pandas as pd

import  random
from faker import Faker
# step 2 - faker
fake=Faker("en_IN")
random.seed(100)
Faker.seed(100)
# step 3 configuration
TOTAL_PRODUCTS = 50000

# master values - step 4
from utils.mappings import (
    category_weights,subcategory_map,category_brand_map,unit_weights,product_statuses,
    product_status_weights,subcategory_rules
)
# product id generator
def generate_product_id(number):
    return  f"PRD{number:06d}"

# step 6- product name generator

def generate_product_name(
        brand,sub_category
):
    product_number = random.randint(100,9999)
    return ( f"{brand}"
             f"{sub_category}"
             f"{product_number}")

# step 5 generate data
rows = []
for i in range(1, TOTAL_PRODUCTS +1):
    product_id=generate_product_id(i)
    category = random.choices(list(category_weights.keys()),
                              weights=list(category_weights.values()))[0]

    subcategory_weights=(subcategory_map[category])
    sub_category=random.choices(list(subcategory_weights.keys()),
                weights=list(subcategory_weights.values())
                        )[0]

    # brand
    brand_weights=(category_brand_map[category])
    brand=random.choices(list(brand_weights.keys()),
                         weights=list(brand_weights.values()))[0]

    # unit of measure
    unit_of_measure=random.choices(list(unit_weights.keys()),
                                  weights=list(unit_weights.values()))[0]

    # subcategory specifics cost

    cost_min, cost_max = (subcategory_rules[
        sub_category
    ]["unit_cost"])

    unit_cost = round(
        random.uniform(
            cost_min,
            cost_max
        ),
        2
    )

    #selling price
    markup=random.uniform(1.15,1.70)
    selling_price = round(unit_cost * markup, 2)

    #sun category specific reorder level

    recorder_min,recorder_max= (subcategory_rules[
        sub_category]["reorder_level"])
    reorder_level=random.randint(
        recorder_min,recorder_max
    )
    #product status
    product_status=random.choices(product_statuses,weights=product_status_weights)[0]
    product_name=generate_product_name(brand,sub_category)

    # # ============================================================
    # # CREATED / UPDATED TIMESTAMP
    # # ============================================================
    #
    # created_at = fake.date_time_between(
    #     start_date="-15y",
    #     end_date="today"
    # )
    #
    # updated_at = fake.date_time_between(
    #     start_date=created_at,
    #     end_date="today"
    # )
    #append record

    products={
        "product_id":
            product_id,

        "product_name":
            product_name,

        "category":
            category,

        "sub_category":
            sub_category,

        "brand":
            brand,

        "unit_cost":
            unit_cost,

        "selling_price":
            selling_price,

        "reorder_level":
            reorder_level,

        "unit_of_measure":
            unit_of_measure,

        "product_status":
            product_status,
        # "created_at":
        #     created_at,
        #
        # "updated_at":
        #     updated_at
    }
    rows.append(products)

#step 11 - create dataframe

product_df=pd.DataFrame(rows)

print("product data Generated successfully")
print("adding dirty data")
#1 duplicate product name
duplicate_rows = product_df.sample(
    500,
    random_state=42
)

product_df = pd.concat(
    [
        product_df,
        duplicate_rows
    ],
    ignore_index=True
)

#
rows=random.sample(range(len(product_df)), 500)
product_df.loc[rows,"product_name"]=[random.choice([

    value.upper(),
    value.lower(),f" {value}", f"{value} ",f" {value} ",value.replace(" ","  ")

    ]
)
for value in product_df.loc[rows,"product_name"]
]

# es=random.sample(range(len(product_df)),2000)
# for r in es:
#     if pd.notna(
#         product_df.loc[r,"product_name"]):
#         product_df.loc[r,"product_name"] = ("  " + str(product_df.loc[r,"product_name"]) + "  "
#
# )
# dirty brand
rows=random.sample(range(len(product_df)),550)
product_df.loc[rows,"brand"]=[
    random.choice([
        value.upper(),value.lower(),f" {value}",f"{value} ", None
    ])
    for value in product_df.loc[rows,"brand"]
]

# dirty reorder level
print(product_df["reorder_level"].dtype)
product_df["reorder_level"] = product_df["reorder_level"].astype("Int64")
# -- this line because we generating data dirty not onlyinterger other than integer that't why'
product_df["reorder_level"] = product_df["reorder_level"].astype("Int64")
drl=random.sample(range(len(product_df)),450)

product_df.loc[drl,"reorder_level"]=[random.choice([
    0,-10,999999,
])
for _ in drl]
print(product_df["reorder_level"].dtype)

# 4. dirty unit of measure

um=random.sample(range(len(product_df)),350)
dirty_units = [

    "unknown",

    "N/A",

    "unit",

    "pieces",

    "",

    " KG ",

]
product_df.loc[um,"unit_of_measure"]=[random.choice(dirty_units)
             for  _ in um]

# 5. dirty unit cost
print(product_df["unit_cost"].dtype)
product_df["unit_cost"]=product_df["unit_cost"].astype("Float64")
uc=random.sample(range(len(product_df)),410)
product_df.loc[uc,"unit_cost"]=[
    random.choice([-50,0,9999999.99])
    for _ in uc
]
print(product_df["unit_cost"].dtype)
# dirty selling price
print(product_df["selling_price"].dtype)
product_df["selling_price"]=product_df["selling_price"].astype("Float64")
dsp=random.sample(range(len(product_df)),205)
product_df.loc[dsp,"selling_price"]=[
    random.choice([-100,0,1,1234567890])
    for _ in dsp
]
print(product_df["selling_price"].dtype)

# save csv
product_df.to_csv("../../data/raw/products_master.csv",index=False)
print(f"Total records : {len(product_df)}")