

import  random
import pandas as pd
from faker import Faker


TOTAL_SUPPLIERS= 200000
random.seed(100)
Faker.seed(100)
fake=Faker("en_IN")

# step 2 to 8
from utils.mappings import(
    supplier_type_weights,country_weights,country_state_map,
    state_city_map,payment_terms,supplier_statuses,supplier_status_weights
    ,rating_weights
)
# step 9 - id generator

def generate_supplier_id(number):
    return f"SUP{number:06d}"

# step 10 - generate records

rows=[]
for i in range(1, TOTAL_SUPPLIERS +1):
    supplier_id = generate_supplier_id(i)
    #supplier type
    supplier_type=random.choices(
        list(supplier_type_weights.keys()),
        weights=list(supplier_type_weights.values())

    )[0]

    #country
    country=random.choices(
        list(country_weights.keys()),
        weights=list(country_weights.values())
    )[0]

    #state/region

    state_weights=(country_state_map[country])
    state=random.choices(
        list(state_weights.keys()),
        weights=list(state_weights.values())
    )[0]

    #city
    city_weights=(state_city_map[state])
    city=random.choices(
        list(city_weights.keys()),
        weights=list(city_weights.values())
    )[0]

    #supplier name
    supplier_name=(fake.company())
    contact_person=(fake.name())
    email=(fake.user_name()+str(i)+"@supplier.com").lower()
    #phone
    if country =="India":
        phone=str(random.randint(6000000000,9999999999))
    else:
        phone=fake.phone_number()
    #payment terems
    payment_term=random.choices(
        list(payment_terms.keys()),
        weights=list(payment_terms.values())
    )[0]

    #lead time
    if country=="India":
        lead_time_days = random.randint(2,30)
    elif country in ["china","Singapore","United Arab Emirates"]:
        lead_time_days = random.randint(7,40)
    else:
        lead_time_days = random.randint(10,60)

    # supplier rating

    rating=random.choices(
        list(rating_weights.keys()),
        weights=list(rating_weights.values())
    )[0]

    #status
    status=random.choices(
        supplier_statuses,
        weights=supplier_status_weights
    )[0]

    # create record
    rows.append({
        "supplier_id":supplier_id,

        "supplier_name":supplier_name,

        "supplier_type":supplier_type,

        "contact_person":contact_person,

        "email":email,

        "phone":phone,

        "country":country,

        "state":state,

        "city":city,

        "payment_terms":payment_term,

        "lead_time_days":lead_time_days,

        "supplier_rating":rating,

        "supplier_status":status
    })

# step 11- create dataframe

supplier_df=pd.DataFrame(rows)

print("Cleaned data generated ")
print("dirty data generating")

# duplicate rows
duplicate_rows=supplier_df.sample(1111,random_state=42)
supplier_df=pd.concat([supplier_df,duplicate_rows],ignore_index=True)
# supplier name blank
blank_namne=random.sample(range(len(supplier_df)),1200)
supplier_df.loc[blank_namne,"supplier_name"]=""

many=random.sample(range(len(supplier_df)),999)
supplier_df.loc[many,"supplier_name"]=[random.choice([
    value.upper(),value.lower(), f" {value}",f" {value} ",f"{value} "
])
for value in supplier_df.loc[many,"supplier_name"]]

# dirty contact person
idx = random.sample(

    range(len(supplier_df)),

    500
)

supplier_df.loc[
    idx,
    "contact_person"
] = [

    random.choice([

        value,

        value.upper(),

        value.lower(),

        f" {value}",

        f"{value} ",

        None

    ])
for value in supplier_df.loc[idx,"contact_person"]]

#dirty email


dirty_emails = [

    None,

    "",

    "unknown",

    "N/A",

    "invalid@email",

    "missing@",

    "test@",

    "not_available"

]
bad_email=random.sample(range(len(supplier_df)),1451)
supplier_df.loc[bad_email,"email"]=[
    random.choice(dirty_emails)
    for _ in bad_email
]
# bad phone

dirty_phones = [

    None,

    "",

    "0000000000",

    "12345",

    "999999999999999",

    "unknown",

    "N/A",

    "98765ABCDE"

]
bad_phone=random.sample(range(len(supplier_df)),1251)
supplier_df.loc[bad_phone,"phone"]=[
    random.choice(dirty_phones)
    for _ in bad_phone
]
# wrong country
wrong_country_name=["Pakistan","Bhikaristan","Engrez","Dakshin korea", None]
wrong_country=random.sample(range(len(supplier_df)),1551)
supplier_df.loc[wrong_country,"country"]=[random.choice(wrong_country_name)
                                          for _ in wrong_country]

# dirty state=
wrong_state=["Kabul","Unknown","",None,"N/A"]
rows=random.sample(range(len(supplier_df)),951)
supplier_df.loc[rows,"state"]=[
    random.choice(wrong_state)
    for _ in rows
]
# dirty city
idx=random.sample(range(len(supplier_df)),1008)

dirty_cities= ["","Darganhalli","Mulagav","Shelagi","saat Rssata"]

supplier_df.loc[idx,"city"]=[random.choice(dirty_cities)
        for _ in idx]

# dirty supplier rating
idx=random.sample(range(len(supplier_df)),555)
supplier_df.loc[idx,"supplier_rating"]=[
    random.choice([0,6,-1,None,-999999])
    for _ in idx
]

# save cssv

supplier_df.to_csv("../../data/raw/suppliers.csv",index=False)
print("Dirty Dara Generated ")
print(f"Total Records : {supplier_df}")

