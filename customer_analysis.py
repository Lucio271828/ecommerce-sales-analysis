#Import Pandas
import pandas as pd

#Load the dataset
sales_data = pd.read_csv("messy_ecommerce_sales_data.csv")

#Display all columns and rows
pd.set_option('display.max_columns', None)
pd.set_option('display.max_rows', None)

#Inspect the dataset
sales_data.head()
sales_data.tail()
sales_data.shape

#type of data in each column
print(sales_data.dtypes)

#Using isnull for counting the NAN values in each column
print('This shows, for each column, how many missing values there are')
print(sales_data.isnull().sum())

#Is is necessaty to check out if there are Duplicate rows
print("Duplicate rows:", sales_data.duplicated().sum())

#According to the previous result, we need to be sure if the duplicated rows are the same (same data)
print(sales_data[sales_data['ID']==146])

#One exact duplicate was identified and removed.
sales_data = sales_data.drop_duplicates()

#Cleaning the space between names in Category Column
sales_data.columns = sales_data.columns.str.strip()

#Fixing the names category issues
sales_data['Category'] = sales_data['Category'].str.strip().str.title() #ELECTRONIC or electronics will turn Electronic and Electronics
sales_data['Category'] = sales_data['Category'].replace({'Electronic' : 'Electronics'}) #Remplace Electronic with Electronics


#Now we are going to clean and fix the price column
sales_data['Price_original'] = sales_data['Price']#First of all, saving original data
sales_data['Quantity_original']= sales_data['Quantity']
sales_data['total_original'] = sales_data['Total']
sales_data['Order_Date_original']=sales_data['Order_Date']

sales_data['Price'] = sales_data['Price'].replace({'four hundred' : '400', '300$': '300'})#Fixing the data in price column

sales_data['Price'] = pd.to_numeric(sales_data['Price'], errors='coerce') #turn type of data object to numeric and coerce becomes abc to NAN 

sales_data.loc[sales_data['Price'] < 0, 'Price'] = pd.NA

sales_data['Quantity']=pd.to_numeric(sales_data['Quantity'], errors='coerce')
sales_data.loc[sales_data['Quantity']<0, 'Quantity']= sales_data.loc[sales_data['Quantity']<0, 'Quantity'].abs()

sales_data['Total'] = sales_data['Quantity'] * sales_data['Price']

sales_data['Order_Date']=pd.to_datetime(sales_data['Order_Date'], errors='coerce')

sales_data.loc[sales_data['Order_Date_original']=='Jan 5 2023', 'Order_Date']= pd.Timestamp('2023-01-05')

category_map = {
    'Biography': 'Books',
    'Headphones': 'Electronics',
    'Laptop': 'Electronics',
    'Smartphone': 'Electronics',
    'Shoes': 'Clothing',
    'Jeans': 'Clothing',
    'Basketball': 'Sports',
    'Vacuum': 'Home'}

sales_data['Category'] = sales_data['Category'].fillna(
    sales_data['Product'].map(category_map))



sales_data['Total_calculated'] = sales_data['Quantity'] * sales_data['Price']

print(
    sales_data[
        sales_data['Total'].notna() &
        sales_data['Total_calculated'].notna() &
        (sales_data['Total'] != sales_data['Total_calculated'])
    ][
        ['ID', 'Quantity', 'Price', 'Total', 'Total_calculated']
    ]
)

sales_data.drop(columns=['Total_calculated', 'Price_original', 'Quantity_original', 'total_original', 'Order_Date_original'],  inplace=True)

#Replace missing values with NULL for SQL import
sales_data.to_csv(
    'cleaned_ecommerce_sales_data_mysql.csv',
    index=False,
    na_rep='NULL',
    encoding='utf-8'
)
















