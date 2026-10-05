import random
import pandas as pd
from faker import Faker
from datetime import date
# from pandas.conftest import dropna

# ============================================================
# STEP 1 - CONFIGURATION
# ============================================================

TOTAL_ORDERS = 500000

random.seed(400)

Faker.seed(400)

fake = Faker("en_IN")


# ============================================================
# STEP 2 - LOAD PRODUCT DATA
# ============================================================

product_df = pd.read_csv(
    "../../data/raw/products_master.csv"
)


# ============================================================
# STEP 3 - LOAD SUPPLIER DATA
# ============================================================

supplier_df = pd.read_csv(
    "../../data/raw/suppliers.csv"
)

# step 4 get product id
# product_ids=product_df["product_id"].dropna().drop_duplicates().tolist()
product_ids=(
    product_df["product_id"]
    .dropna().astype(str).loc[lambda x: x.str.match(r"^PRD\d{6}$")].drop_duplicates().tolist()
)
# step 5 - get supplier ids
# supplier_ids=supplier_df["supplier_id"].dropna().drop_duplicates().tolist()
supplier_ids=(
    supplier_df["supplier_id"]
    .dropna().astype(str).loc[lambda x: x.str.match(r"^SUP\d{6}$")].drop_duplicates().tolist()
)
clean_product_df=product_df[
    product_df["product_id"].notna()
    &
    product_df["product_id"].astype(str).str.match(r"^PRD\d{6}$")
].copy()
# step 6 - product price lookup
if "unit_cost" in product_df.columns:
    product_price_map=dict(
        zip(
            clean_product_df["product_id"],
            clean_product_df["unit_cost"]
        )
    )
elif "selling_price" in product_df.columns:
    product_price_map=dict(
        zip(
            clean_product_df["product_id"],
            clean_product_df["selling_price"]
        )
    )
else:
    product_price_map={}

# step 7 - supplier lead timer lookup
clean_supplier_df=supplier_df[
    supplier_df["supplier_id"].notna()
    &
    supplier_df["supplier_id"].astype(str).str.match(r"^SUP\d{6}$")
].copy()
supplier_lead_time_map = dict(
    zip(
        clean_supplier_df[
            "supplier_id"
        ],
        clean_supplier_df[
            "lead_time_days"
        ]
    )
)

# step 8 - order status
order_statuses=[
    "pending","Confirmed","Processing","Shipped","Delivered","Cancelled"

]
order_status_weights=[8,15,15,20,35,7]

# ============================================================
# STEP 9 - PAYMENT TERMS
# ============================================================

payment_methods = [

    "Bank Transfer",

    "Credit",

    "UPI",

    "Cheque",

    "Cash",

    "NEFT",

    "RTGS"

]


payment_method_weights = [

    30,

    20,

    10,

    10,

    5,

    15,

    10

]

start_date = date(2022, 1, 1)
end_date = date(2026, 8, 19)
# ============================================================
# STEP 10 - CURRENCY
# ============================================================

currency = "INR"

# step 11- order id
def generate_order_id(number):
    return f"ORD{number:07d}"

# step 11- generate order records
rows=[]
for i in range(1,TOTAL_ORDERS+1):
    order_id=generate_order_id(i)
    product_id=random.choice(product_ids)
    supplier_id=random.choice(supplier_ids)

    # phone=str(random.randint(6000000000,9999999999))
    quantity=(random.randint(1,200))

    unit_price = product_price_map.get(
        product_id
    )
    if pd.isna(unit_price) or unit_price is None:
        unit_price = round(
            random.uniform(
                100,10000
            ),2
        )
    unit_price = round(
        float(unit_price),2
    )

    order_amount=round(
        quantity * unit_price,2
    )

    order_date=fake.date_between(
        start_date=start_date,
        end_date=end_date
        # start_date=date(2022, 1, 1),
        # end_date=date(2026, 8, 19)
    )

    supplier_lead_time=(
        supplier_lead_time_map.get(
            supplier_id
        )
    )

    if pd.isna(
        supplier_lead_time
    ) or supplier_lead_time is None:
        supplier_lead_time= random.randint(
    2,60
    )
    else:
        supplier_lead_time= int(supplier_lead_time)

    expected_delivery_date = (
        order_date + pd.Timedelta(
            days=supplier_lead_time
        )
    )
    expected_delivery_date=(
        expected_delivery_date
    )

    order_status=random.choices(
        order_statuses,
        weights=order_status_weights
    )[0]
    # payment method
    payment_method=random.choices(
        payment_methods,
        weights=payment_method_weights
    )[0]

    # create record
    rows.append({

        "order_id":
            order_id,

        "product_id":
            product_id,

        "supplier_id":
            supplier_id,

        "order_date":
            order_date,

        "quantity":
            quantity,

        "unit_price":
            unit_price,

        "order_amount":
            order_amount,

        "currency":
            currency,

        "payment_method":
            payment_method,

        "expected_delivery_date":
            expected_delivery_date,

        "order_status":
            order_status
    })

#step 13 - create dataframe
order_df=pd.DataFrame(rows)

print(
    "Cleaned data generated"
)

print(
    "Dirty data generating"
)
# step 14 - duplicate rows
duplicate_rows=order_df.sample(2100,random_state=100)
order_df=pd.concat([order_df,duplicate_rows],ignore_index=True)
print(f"Total duplicate rows: {len(duplicate_rows)}")

# step 15 - dirty product id
wpi=random.sample(range(len(order_df)),2000)
bad_product=["PRO1234ewq","1234567","wrong","Unknown","PRODUCT1223"]
order_df.loc[wpi,"product_id"]=[
    random.choice(bad_product)
    for _ in wpi
]
print(f"Total Bad Product ids: {len(wpi)}")

# ============================================================
# STEP 16 - DIRTY SUPPLIER ID
# ============================================================

wsi=random.sample(range(len(order_df)),2001)
bad_supplier_id=["SUP1234567890","SUPPLIER123","1234SSFF",None,""]
order_df.loc[wsi,"supplier_id"]=[
    random.choice(bad_supplier_id)
    for _ in wsi
]
print(f"Total Bad Supplier Id : {len(wsi)}")

# wrong quantity
order_df["quantity"]=order_df["quantity"].astype("object")
wq=random.sample(range(len(order_df)),2002)
wrong_quantity=[0,-1,-10,1000000,None,""]
order_df.loc[wq,"quantity"]=[
    random.choice(wrong_quantity)
    for _ in wq
]

print(f"Total Wrong Quantity : {len(wq)}")

# step 19 - wrong unit price
up=random.sample(range(len(order_df)),1501)
wrong_unit_price=[0,1,99999999999,]
order_df.loc[up,"unit_price"]=[
    random.choice(wrong_unit_price)
    for _ in up

]
print("Total wrong unit price : ",len(up))

# bad order amount
order_df["order_amount"]=order_df["order_amount"].astype("object")
oa=random.sample(range(len(order_df)),3000)
order_amount_bad=[ 0,

    -100,

    -9999,

    999999999,

    None,

    ]
order_df.loc[oa,"order_amount"]=[
    random.choice(order_amount_bad)
    for _ in oa
]
print(f"wrong amount GEnerated : {len(oa)}")

# wrong currency
wc=random.sample(range(len(order_df)),1111)
wrong_currecy=[
    "USD","EURO","YEN","$",""
]
order_df.loc[wc,"currency"]=[
    random.choice(wrong_currecy)
    for _ in wc
]

print(f"Total Wrong Currency: {len(wc)}")


# step 22 payment method
# blank payment payment_methods

blank_payment=random.sample(range(len(order_df)),2000)
order_df.loc[blank_payment,"payment_method"]=""


# save csv
order_df.to_csv("../../data/raw/orders.csv",index=False)

