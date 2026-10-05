
# ============================================================
# STEP 2 - CATEGORY WEIGHTS
# ============================================================

category_weights = {

    "Electronics": 30,

    "Industrial": 25,

    "Automotive": 18,

    "Office": 15,

    "Packaging": 12
}


# ============================================================
# STEP 3 - CATEGORY → SUB-CATEGORY MAPPING
# ============================================================

subcategory_map = {

    "Electronics": {

        "Computer Accessories": 30,

        "Mobile Accessories": 25,

        "Networking": 20,

        "Audio": 15,

        "Storage": 10
    },


    "Industrial": {

        "Safety Equipment": 30,

        "Tools": 25,

        "Machinery Parts": 20,

        "Electrical Components": 25
    },


    "Automotive": {

        "Engine Parts": 30,

        "Brake Components": 25,

        "Electrical Parts": 25,

        "Accessories": 20
    },


    "Office": {

        "Stationery": 40,

        "Office Equipment": 30,

        "Furniture": 30
    },


    "Packaging": {

        "Boxes": 35,

        "Plastic Packaging": 30,

        "Labels": 20,

        "Wrapping Material": 15
    }
}


# ============================================================
# STEP 4 - CATEGORY → BRAND MAPPING
# ============================================================

category_brand_map = {

    "Electronics": {

        "Samsung": 20,

        "LG": 15,

        "Dell": 15,

        "HP": 15,

        "Lenovo": 15,

        "Philips": 10,

        "Generic": 10
    },


    "Industrial": {

        "Bosch": 25,

        "Siemens": 20,

        "SKF": 20,

        "Havells": 15,

        "Tata": 10,

        "Generic": 10
    },


    "Automotive": {

        "Tata": 30,

        "Bosch": 25,

        "SKF": 20,

        "Bajaj": 15,

        "Generic": 10
    },


    "Office": {

        "Godrej": 25,

        "HP": 20,

        "Philips": 15,

        "Tata": 10,

        "Generic": 30
    },


    "Packaging": {

        "Tata": 20,

        "Godrej": 15,

        "Generic": 50,

        "Bosch": 5,

        "Havells": 10
    }
}


# ============================================================
# STEP 5 - UNIT OF MEASURE
# ============================================================

unit_weights = {

    "Piece": 45,

    "Box": 15,

    "Kg": 15,

    "Liter": 5,

    "Meter": 5,

    "Pack": 10,

    "Set": 5
}


# ============================================================
# STEP 6 - PRODUCT STATUS
# ============================================================

product_statuses = [

    "Active",

    "Inactive",

    "Discontinued"
]

product_status_weights = [

    70,

    20,

    10
]
subcategory_rules = {

    "Computer Accessories": {
        "unit_cost": (200, 15000),
        "reorder_level": (50, 500)
    },

    "Mobile Accessories": {
        "unit_cost": (50, 5000),
        "reorder_level": (100, 1000)
    },

    "Networking": {
        "unit_cost": (500, 30000),
        "reorder_level": (20, 300)
    },

    "Audio": {
        "unit_cost": (300, 50000),
        "reorder_level": (20, 300)
    },

    "Storage": {
        "unit_cost": (300, 40000),
        "reorder_level": (30, 400)
    },

    "Safety Equipment": {
        "unit_cost": (100, 15000),
        "reorder_level": (50, 500)
    },

    "Tools": {
        "unit_cost": (200, 50000),
        "reorder_level": (20, 300)
    },

    "Machinery Parts": {
        "unit_cost": (1000, 150000),
        "reorder_level": (10, 150)
    },

    "Electrical Components": {
        "unit_cost": (100, 50000),
        "reorder_level": (30, 500)
    },

    "Engine Parts": {
        "unit_cost": (500, 100000),
        "reorder_level": (10, 200)
    },

    "Brake Components": {
        "unit_cost": (300, 30000),
        "reorder_level": (20, 300)
    },

    "Electrical Parts": {
        "unit_cost": (200, 50000),
        "reorder_level": (20, 300)
    },

    "Accessories": {
        "unit_cost": (100, 20000),
        "reorder_level": (50, 500)
    },

    "Stationery": {
        "unit_cost": (10, 5000),
        "reorder_level": (100, 2000)
    },

    "Office Equipment": {
        "unit_cost": (500, 80000),
        "reorder_level": (20, 300)
    },

    "Furniture": {
        "unit_cost": (1000, 100000),
        "reorder_level": (10, 100)
    },

    "Boxes": {
        "unit_cost": (5, 2000),
        "reorder_level": (200, 5000)
    },

    "Plastic Packaging": {
        "unit_cost": (5, 5000),
        "reorder_level": (200, 5000)
    },

    "Labels": {
        "unit_cost": (1, 1000),
        "reorder_level": (500, 10000)
    },

    "Wrapping Material": {
        "unit_cost": (5, 3000),
        "reorder_level": (200, 5000)
    }
}
# markup_rules = {
#
#     "Computer Accessories": (1.15, 1.40),
#
#     "Mobile Accessories": (1.20, 1.70),
#
#     "Networking": (1.10, 1.35),
#
#     "Audio": (1.15, 1.50),
#
#     "Storage": (1.10, 1.35),
#
#     "Machinery Parts": (1.08, 1.25),
#
#     "Stationery": (1.20, 1.80),
#
#     "Labels": (1.30, 2.00)
# }


#  for suppliers
# ///////////////////////////////////////////////



# ============================================================
# STEP 2 - SUPPLIER TYPES
# ============================================================

supplier_type_weights = {

    "Manufacturer": 35,

    "Distributor": 25,

    "Wholesaler": 20,

    "Importer": 10,

    "Local Supplier": 10
}


# ============================================================
# STEP 3 - COUNTRY WEIGHTS
# ============================================================

country_weights = {

    "India": 65,

    "China": 12,

    "United States": 6,

    "Germany": 5,

    "Japan": 4,

    "United Kingdom": 3,

    "Singapore": 3,

    "United Arab Emirates": 2
}


# ============================================================
# STEP 4 - COUNTRY → STATE / REGION MAPPING
# ============================================================

country_state_map = {

    "India": {

        "Maharashtra": 25,

        "Karnataka": 15,

        "Gujarat": 12,

        "Tamil Nadu": 12,

        "Telangana": 8,

        "Uttar Pradesh": 8,

        "Delhi": 5,

        "Rajasthan": 5,

        "West Bengal": 5,

        "Punjab": 5
    },


    "China": {

        "Guangdong": 30,

        "Jiangsu": 20,

        "Zhejiang": 20,

        "Shandong": 15,

        "Fujian": 15
    },


    "United States": {

        "California": 30,

        "Texas": 20,

        "New York": 15,

        "Florida": 15,

        "Illinois": 10,

        "Ohio": 10
    },


    "Germany": {

        "Bavaria": 30,

        "North Rhine-Westphalia": 25,

        "Baden-Württemberg": 20,

        "Hesse": 15,

        "Saxony": 10
    },


    "Japan": {

        "Tokyo": 30,

        "Osaka": 25,

        "Aichi": 20,

        "Kanagawa": 15,

        "Hyogo": 10
    },


    "United Kingdom": {

        "England": 60,

        "Scotland": 15,

        "Wales": 15,

        "Northern Ireland": 10
    },


    "Singapore": {

        "Central Region": 40,

        "East Region": 20,

        "West Region": 20,

        "North Region": 10,

        "North-East Region": 10
    },


    "United Arab Emirates": {

        "Dubai": 40,

        "Abu Dhabi": 30,

        "Sharjah": 20,

        "Ajman": 10
    }
}


# ============================================================
# STEP 5 - STATE → CITY MAPPING
# ============================================================

state_city_map = {

    # --------------------------------------------------------
    # INDIA
    # --------------------------------------------------------

    "Maharashtra": {

        "Mumbai": 25,

        "Pune": 20,

        "Nashik": 8,

        "Nagpur": 12,

        "Aurangabad": 6,

        "Solapur": 12,

        "Kolhapur": 5,

        "Thane": 7,

        "Navi Mumbai": 5
    },


    "Karnataka": {

        "Bengaluru": 40,

        "Mysuru": 15,

        "Mangaluru": 12,

        "Hubli": 10,

        "Belagavi": 8,

        "Ballari": 5,

        "Tumakuru": 10
    },


    "Gujarat": {

        "Ahmedabad": 30,

        "Surat": 25,

        "Vadodara": 15,

        "Rajkot": 12,

        "Bhavnagar": 8,

        "Jamnagar": 5,

        "Gandhinagar": 5
    },


    "Tamil Nadu": {

        "Chennai": 35,

        "Coimbatore": 20,

        "Madurai": 12,

        "Tiruppur": 10,

        "Salem": 8,

        "Trichy": 8,

        "Hosur": 7
    },


    "Telangana": {

        "Hyderabad": 60,

        "Warangal": 15,

        "Nizamabad": 10,

        "Karimnagar": 8,

        "Khammam": 7
    },


    "Uttar Pradesh": {

        "Lucknow": 20,

        "Noida": 20,

        "Kanpur": 15,

        "Agra": 12,

        "Ghaziabad": 12,

        "Meerut": 10,

        "Varanasi": 6,

        "Prayagraj": 5
    },


    "Delhi": {

        "New Delhi": 70,

        "Delhi": 30
    },


    "Rajasthan": {

        "Jaipur": 35,

        "Jodhpur": 15,

        "Udaipur": 12,

        "Kota": 12,

        "Ajmer": 10,

        "Bikaner": 8,

        "Alwar": 8
    },


    "West Bengal": {

        "Kolkata": 60,

        "Howrah": 15,

        "Durgapur": 10,

        "Siliguri": 8,

        "Asansol": 7
    },


    "Punjab": {

        "Ludhiana": 30,

        "Amritsar": 20,

        "Jalandhar": 20,

        "Patiala": 15,

        "Mohali": 15
    },


    # --------------------------------------------------------
    # CHINA
    # --------------------------------------------------------

    "Guangdong": {

        "Guangzhou": 35,

        "Shenzhen": 30,

        "Dongguan": 20,

        "Foshan": 15
    },


    "Jiangsu": {

        "Nanjing": 30,

        "Suzhou": 35,

        "Wuxi": 20,

        "Nantong": 15
    },


    "Zhejiang": {

        "Hangzhou": 35,

        "Ningbo": 30,

        "Wenzhou": 20,

        "Jinhua": 15
    },


    "Shandong": {

        "Qingdao": 35,

        "Jinan": 30,

        "Yantai": 20,

        "Weifang": 15
    },


    "Fujian": {

        "Xiamen": 40,

        "Fuzhou": 30,

        "Quanzhou": 20,

        "Putian": 10
    },


    # --------------------------------------------------------
    # UNITED STATES
    # --------------------------------------------------------

    "California": {

        "Los Angeles": 35,

        "San Francisco": 25,

        "San Diego": 20,

        "San Jose": 20
    },


    "Texas": {

        "Houston": 35,

        "Dallas": 30,

        "Austin": 20,

        "San Antonio": 15
    },


    "New York": {

        "New York City": 60,

        "Buffalo": 15,

        "Rochester": 15,

        "Albany": 10
    },


    "Florida": {

        "Miami": 35,

        "Orlando": 25,

        "Tampa": 25,

        "Jacksonville": 15
    },


    "Illinois": {

        "Chicago": 60,

        "Aurora": 15,

        "Rockford": 15,

        "Naperville": 10
    },


    "Ohio": {

        "Columbus": 35,

        "Cleveland": 25,

        "Cincinnati": 25,

        "Toledo": 15
    },


    # --------------------------------------------------------
    # GERMANY
    # --------------------------------------------------------

    "Bavaria": {

        "Munich": 40,

        "Nuremberg": 25,

        "Augsburg": 20,

        "Regensburg": 15
    },


    "North Rhine-Westphalia": {

        "Cologne": 35,

        "Dusseldorf": 30,

        "Dortmund": 20,

        "Essen": 15
    },


    "Baden-Württemberg": {

        "Stuttgart": 40,

        "Mannheim": 25,

        "Karlsruhe": 20,

        "Freiburg": 15
    },


    "Hesse": {

        "Frankfurt": 50,

        "Wiesbaden": 20,

        "Kassel": 15,

        "Darmstadt": 15
    },


    "Saxony": {

        "Dresden": 40,

        "Leipzig": 35,

        "Chemnitz": 25
    },


    # --------------------------------------------------------
    # JAPAN
    # --------------------------------------------------------

    "Tokyo": {

        "Tokyo": 70,

        "Hachioji": 15,

        "Machida": 15
    },


    "Osaka": {

        "Osaka": 60,

        "Sakai": 20,

        "Higashiosaka": 20
    },


    "Aichi": {

        "Nagoya": 60,

        "Toyota": 25,

        "Okazaki": 15
    },


    "Kanagawa": {

        "Yokohama": 60,

        "Kawasaki": 25,

        "Sagamihara": 15
    },


    "Hyogo": {

        "Kobe": 60,

        "Himeji": 25,

        "Nishinomiya": 15
    },


    # --------------------------------------------------------
    # UNITED KINGDOM
    # --------------------------------------------------------

    "England": {

        "London": 35,

        "Manchester": 20,

        "Birmingham": 15,

        "Liverpool": 10,

        "Leeds": 10,

        "Bristol": 10
    },


    "Scotland": {

        "Glasgow": 40,

        "Edinburgh": 35,

        "Aberdeen": 15,

        "Dundee": 10
    },


    "Wales": {

        "Cardiff": 50,

        "Swansea": 25,

        "Newport": 25
    },


    "Northern Ireland": {

        "Belfast": 70,

        "Derry": 20,

        "Lisburn": 10
    },


    # --------------------------------------------------------
    # SINGAPORE
    # --------------------------------------------------------

    "Central Region": {

        "Singapore City": 100
    },


    "East Region": {

        "Bedok": 40,

        "Tampines": 35,

        "Pasir Ris": 25
    },


    "West Region": {

        "Jurong": 40,

        "Clementi": 30,

        "Bukit Batok": 30
    },


    "North Region": {

        "Woodlands": 50,

        "Yishun": 30,

        "Sembawang": 20
    },


    "North-East Region": {

        "Hougang": 40,

        "Sengkang": 35,

        "Punggol": 25
    },


    # --------------------------------------------------------
    # UAE
    # --------------------------------------------------------

    "Dubai": {

        "Dubai": 100
    },


    "Abu Dhabi": {

        "Abu Dhabi": 70,

        "Al Ain": 30
    },


    "Sharjah": {

        "Sharjah": 100
    },


    "Ajman": {

        "Ajman": 100
    }
}


# ============================================================
# STEP 6 - PAYMENT TERMS
# ============================================================

payment_terms = {

    "Net 15": 20,

    "Net 30": 40,

    "Net 45": 15,

    "Net 60": 15,

    "Advance": 5,

    "COD": 5
}


# ============================================================
# STEP 7 - SUPPLIER STATUS
# ============================================================

supplier_statuses = [

    "Active",

    "Inactive",

    "Suspended",

    "Blacklisted"
]

supplier_status_weights = [

    75,

    12,

    8,

    5
]


# ============================================================
# STEP 8 - SUPPLIER RATING
# ============================================================

rating_weights = {

    5: 20,

    4: 40,

    3: 25,

    2: 10,

    1: 5
}

#  for warehouse mappings

# ============================================================
# WAREHOUSE MAPPINGS
# ============================================================

warehouse_type_weights = {

    "Distribution Center": 35,

    "Fulfillment Center": 25,

    "Regional Warehouse": 20,

    "Cold Storage": 10,

    "Storage Warehouse": 10
}


storage_type_weights = {

    "General": 55,

    "Cold": 15,

    "Hazardous": 10,

    "High Value": 10,

    "Temperature Controlled": 10
}


warehouse_statuses = [

    "Active",

    "Inactive",

    "Maintenance",

    "Closed"
]


warehouse_status_weights = [

    75,

    10,

    10,

    5
]
# //////////////////////////
# for shipments
# ============================================================
# STEP 8 - CARRIERS
# ============================================================

carrier_weights = {

    "Delhivery": 25,

    "Blue Dart": 15,

    "DHL": 10,

    "FedEx": 10,

    "Ecom Express": 12,

    "DTDC": 10,

    "XpressBees": 8,

    "Ekart": 6,

    "Shadowfax": 4
}


# ============================================================
# STEP 9 - SHIPMENT STATUS
# ============================================================

shipment_statuses = [

    "Pending",

    "Picked Up",

    "In Transit",

    "Out for Delivery",

    "Delivered",

    "Delayed",

    "Cancelled"

]


shipment_status_weights = [

    5,

    10,

    30,

    15,

    30,

    7,

    3
]


# ============================================================
# STEP 10 - SHIPPING METHODS
# ============================================================

shipping_methods = [

    "Standard",

    "Express",

    "Same Day",

    "Economy",

    "Air",

    "Road"

]


shipping_method_weights = [

    35,

    20,

    5,

    15,

    10,

    15
]

# # ============================================================
# # MASTER VALUES
# # ============================================================
#
# categories = {
#     "Electronics": [
#         "Computer Accessories",
#         "Mobile Accessories",
#         "Networking",
#         "Audio",
#         "Storage"
#     ],
#
#     "Industrial": [
#         "Safety Equipment",
#         "Tools",
#         "Machinery Parts",
#         "Electrical Components"
#     ],
#
#     "Office": [
#         "Stationery",
#         "Office Equipment",
#         "Furniture"
#     ],
#
#     "Packaging": [
#         "Boxes",
#         "Plastic Packaging",
#         "Labels",
#         "Wrapping Material"
#     ],
#
#     "Automotive": [
#         "Engine Parts",
#         "Brake Components",
#         "Electrical Parts",
#         "Accessories"
#     ]
# }
#
# brands = [
#     "Bosch",
#     "Tata",
#     "LG",
#     "Samsung",
#     "Dell",
#     "HP",
#     "Lenovo",
#     "SKF",
#     "Siemens",
#     "Philips",
#     "Havells",
#     "Bajaj",
#     "Godrej",
#     "Voltas",
#     "Generic"
# ]
#
# units = [
#     "Piece",
#     "Box",
#     "Kg",
#     "Liter",
#     "Meter",
#     "Pack",
#     "Set"
# ]
#
# product_statuses = [
#     "Active",
#     "Active",
#     "Active",
#     "Active",
#     "Inactive",
#     "Discontinued"
# ]


'''
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

'''