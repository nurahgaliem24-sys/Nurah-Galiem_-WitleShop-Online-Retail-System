# Nurah-Galiem-WitleShop-Online-Retail-System
WitleShop Online Retail System Data
WitleShop Online Retail System
Entity Relationship Diagram (ERD) Assignment
Introduction
WitleShop (Pty) Ltd is a South African online retail company that sells electronics, clothing and home appliances through a web and mobile platform. The company requires a database system to manage customers, products, orders, payments, deliveries and suppliers.
The purpose of this assignment is to identify the entities required for the WitleShop database, identify the primary and foreign keys, establish the relationships between entities, determine the cardinality of each relationship, and design a complete Entity Relationship Diagram (ERD).
________________________________________
**1. Identify All Entities**

Based on the business requirements, the following entities are required:
1.	Customer 
2.	Address 
3.	Product 
4.	Category 
5.	Supplier 
6.	Order 
7.	OrderItem 
8.	Payment 
9.	Delivery


**Explanation of the entities**

| Entity        | Description                                                        |
| ------------- | ------------------------------------------------------------------ |
| **Customer**  | Stores information about customers who register with WitleShop.    |
| **Address**   | Stores the delivery addresses registered by customers.             |
| **Product**   | Stores information about products sold by WitleShop.               |
| **Category**  | Stores product categories.                                         |
| **Supplier**  | Stores information about suppliers providing products.             |
| **Order**     | Stores information about orders placed by customers.               |
| **OrderItem** | Links products to orders and resolves the M:N relationship.        |
| **Payment**   | Stores payment information for an order.                           |
| **Delivery**  | Stores delivery information for an order and its delivery address. |

________________________________________
**2. Identify Primary Keys**
   
| Entity    | Primary Key     | Description                                    |
| --------- | --------------- | ---------------------------------------------- |
| Customer  | **CustomerID**  | Uniquely identifies each customer.             |
| Address   | **AddressID**   | Uniquely identifies each address.              |
| Product   | **ProductID**   | Uniquely identifies each product.              |
| Category  | **CategoryID**  | Uniquely identifies each category.             |
| Supplier  | **SupplierID**  | Uniquely identifies each supplier.             |
| Order     | **OrderID**     | Uniquely identifies each order.                |
| OrderItem | **OrderItemID** | Uniquely identifies each item within an order. |
| Payment   | **PaymentID**   | Uniquely identifies each payment.              |
| Delivery  | **DeliveryID**  | Uniquely identifies each delivery.             |

________________________________________
**3. Entity Attributes and Primary Keys**

3.1 The Customer entity stores information about customers who register before placing orders.

| Attribute        | Description                  | Key        |
| ---------------- | ---------------------------- | ---------- |
| CustomerID       | Unique customer identifier   | **PK**     |
| FullName         | Customer's full name         | —          |
| Email            | Customer's email address     | **Unique** |
| PhoneNumber      | Customer's phone number      | —          |
| RegistrationDate | Date the customer registered | —          |

________________________________________
**3.2 Address**

A customer can have multiple delivery addresses. Therefore, Address must be a separate entity.

| Attribute       | Description                                  | Key    |
| --------------- | -------------------------------------------- | ------ |
| AddressID       | Unique address identifier                    | **PK** |
| CustomerID      | Identifies the customer who owns the address | **FK** |
| DeliveryAddress | Customer's registered delivery address       | —      |

Relationship: Customer → Address = 1:M
________________________________________
**3.3 Product**

The Product entity stores the products sold by WitleShop.

| Attribute     | Description                     | Key    |
| ------------- | ------------------------------- | ------ |
| ProductID     | Unique product identifier       | **PK** |
| ProductName   | Name of the product             | —      |
| Description   | Description of the product      | —      |
| Price         | Price of the product            | —      |
| StockQuantity | Quantity currently in stock     | —      |
| CategoryID    | Identifies the product category | **FK** |
| SupplierID    | Identifies the product supplier | **FK** |

________________________________________
**3.4 Category**

The Category entity stores the categories to which products belong.

| Attribute    | Description                | Key    |
| ------------ | -------------------------- | ------ |
| CategoryID   | Unique category identifier | **PK** |
| CategoryName | Name of the category       | —      |
 
________________________________________
**3.5 Supplier**

The Supplier entity stores suppliers that provide products to WitleShop.

| Attribute    | Description                | Key    |
| ------------ | -------------------------- | ------ |
| SupplierID   | Unique supplier identifier | **PK** |
| SupplierName | Name of the supplier       | —      |

The case study only specifies that each product has a supplier. Therefore, SupplierName is sufficient for the ERD.
________________________________________
**3.6 Order**

The Order entity stores information about orders placed by customers.

**Order**
| Attribute   | Description                   | Key    |
| ----------- | ----------------------------- | ------ |
| OrderID     | Unique order identifier       | **PK** |
| CustomerID  | Customer who placed the order | **FK** |
| OrderDate   | Date the order was placed     | —      |
| OrderStatus | Current status of the order   | —      |
| TotalAmount | Total amount of the order     | —      |

The allowed order statuses are:

•	Pending 

•	Shipped 

•	Delivered 

•	Cancelled 
________________________________________
**3.7 **OrderItem****

An order can contain multiple products.

and:

A product can appear in multiple orders.

This creates a many-to-many (M:N) relationship between Order and Product.

A separate entity called OrderItem is therefore required to resolve the M:N relationship.

ORDER_ITEM

| Attribute   | Description                  | Key    |
| ----------- | ---------------------------- | ------ |
| OrderItemID | Unique order item identifier | **PK** |
| OrderID     | Identifies the order         | **FK** |
| ProductID   | Identifies the product       | **FK** |

The OrderItem entity allows the database to record which products belong to each order.
________________________________________
**3.8 Payment**

The Payment entity stores payment information for each order.

**PAYMENT**
| Attribute     | Description                         | Key    |
| ------------- | ----------------------------------- | ------ |
| PaymentID     | Unique payment identifier           | **PK** |
| OrderID       | Identifies the order being paid for | **FK** |
| PaymentDate   | Date payment was made               | —      |
| PaymentMethod | Method used for payment             | —      |
| PaymentStatus | Status of the payment               | —      |
| AmountPaid    | Amount paid                         | —      |

Payment methods are:

•Card

•EFT

•PayFast
________________________________________
**3.9 Delivery**

The Delivery entity stores information about the delivery of an order.

**DELIVERY**

| Attribute      | Description                                           | Key    |
| -------------- | ----------------------------------------------------- | ------ |
| DeliveryID     | Unique delivery identifier                            | **PK** |
| OrderID        | Identifies the order being delivered                  | **FK** |
| AddressID      | Identifies the customer's registered delivery address | **FK** |
| DeliveryDate   | Date of delivery                                      | —      |
| DeliveryStatus | Current delivery status                               | —      |
| CourierName    | Name of the courier                                   | —      |
| TrackingNumber | Delivery tracking number                              | —      |

The AddressID foreign key ensures that the delivery is linked to one of the customer's registered addresses.
________________________________________
**4. Identify Foreign Keys**

A foreign key (FK) is an attribute that links one entity to another entity's primary key.

| Entity    | Foreign Key    | References           |
| --------- | -------------- | -------------------- |
| Address   | **CustomerID** | Customer(CustomerID) |
| Product   | **CategoryID** | Category(CategoryID) |
| Product   | **SupplierID** | Supplier(SupplierID) |
| Order     | **CustomerID** | Customer(CustomerID) |
| OrderItem | **OrderID**    | Order(OrderID)       |
| OrderItem | **ProductID**  | Product(ProductID)   |
| Payment   | **OrderID**    | Order(OrderID)       |
| Delivery  | **OrderID**    | Order(OrderID)       |
| Delivery  | **AddressID**  | Address(AddressID)   |

________________________________________
**5. Identify Relationships**

The following relationships exist in the WitleShop database.

Relationship 1: Customer – Address

A customer can have multiple delivery addresses.

Cardinality: 1:M

Customer 1 ───────── M Address

One customer can have many addresses, but each address belongs to one customer.
________________________________________
**Relationship 2: Customer – Order**

A customer can place multiple orders.

Cardinality: 1:M

Customer 1 ───────── M Order

One customer can place many orders, but each order belongs to one customer.
________________________________________
**Relationship 3: Category – Product**

Each product belongs to one category, while a category can contain many products.

Cardinality: 1:M

Category 1 ───────── M Product
________________________________________
**Relationship 4: Supplier – Product**

Each product is supplied by one supplier, while a supplier can supply many products.

Cardinality: 1:M

Supplier 1 ───────── M Product
________________________________________
**Relationship 5: Order – Product**

An order can contain multiple products, and a product can appear in multiple orders.

Cardinality: M:N

Order M ───────── N Product

A direct M:N relationship is not normally implemented directly in a relational database. Therefore, the OrderItem entity is used.

The relationship becomes:

Order 1 ───────── M OrderItem M ───────── 1 Product
________________________________________
**Relationship 6: Order – Payment**

Each order has one payment record, and each payment belongs to one order.

Cardinality: 1:1

Order 1 ───────── 1 Payment
________________________________________
**Relationship 7: Order – Delivery**

Each order has one delivery record, and each delivery belongs to one order.

Cardinality: 1:1

Order 1 ───────── 1 Delivery
________________________________________
**Relationship 8: Address – Delivery**

A delivery must be linked to one of the customer's registered addresses.

Cardinality: 1:M

Address 1 ───────── M Delivery

One registered address may be used for deliveries for multiple orders, while each delivery uses one address.
________________________________________
**6. Cardinality Summary**

| Relationship        | Cardinality | Explanation                                                              |
| ------------------- | ----------- | ------------------------------------------------------------------------ |
| Customer → Address  | **1:M**     | One customer can have multiple addresses.                                |
| Customer → Order    | **1:M**     | One customer can place multiple orders.                                  |
| Category → Product  | **1:M**     | One category can contain many products.                                  |
| Supplier → Product  | **1:M**     | One supplier can supply many products.                                   |
| Order → OrderItem   | **1:M**     | One order can contain multiple order items.                              |
| Product → OrderItem | **1:M**     | One product can appear in multiple order items.                          |
| Order → Product     | **M:N**     | Orders can contain many products and products can appear in many orders. |
| Order → Payment     | **1:1**     | Each order has one payment.                                              |
| Order → Delivery    | **1:1**     | Each order has one delivery.                                             |
| Address → Delivery  | **1:M**     | An address can be used for multiple deliveries.                          |



**7. Complete ERD**

The following is the complete logical structure of the WitleShop ERD.

<img width="517" height="707" alt="WitleShop_Database_ERD " src="https://github.com/user-attachments/assets/b1d24d27-27a5-4a8f-9e90-48b231f3f552" />








**8. Final Entity List**

The completed WitleShop database therefore contains:
| Entity        | PK          | Main FKs               |
| ------------- | ----------- | ---------------------- |
| **Customer**  | CustomerID  | —                      |
| **Address**   | AddressID   | CustomerID             |
| **Category**  | CategoryID  | —                      |
| **Supplier**  | SupplierID  | —                      |
| **Product**   | ProductID   | CategoryID, SupplierID |
| **Order**     | OrderID     | CustomerID             |
| **OrderItem** | OrderItemID | OrderID, ProductID     |
| **Payment**   | PaymentID   | OrderID                |
| **Delivery**  | DeliveryID  | OrderID, AddressID     |

		
**10.Conclusion**

The WitleShop Online Retail System requires nine entities to represent the business requirements: Customer, Address, Product, Category, Supplier, Order, OrderItem, Payment and Delivery.

Primary keys are used to uniquely identify records within each entity, while foreign keys are used to establish relationships between entities.

The database contains several one-to-many (1:M) relationships, including Customer to Order, Customer to Address, Category to Product and Supplier to Product. It also contains two one-to-one (1:1) relationships, namely Order to Payment and Order to Delivery.

The relationship between Order and Product is a many-to-many (M:N) relationship because an order can contain multiple products and a product can appear in multiple orders. This relationship is resolved using the OrderItem entity.

The resulting ERD provides a complete database structure that satisfies the requirements given for the WitleShop Online Retail System.

