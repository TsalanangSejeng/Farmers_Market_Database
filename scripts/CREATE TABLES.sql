-- Using the database "FarmerMarketDB"
USE FarmersMarket_DB;
GO

-- Drop tables if they already exist
DROP TABLE IF EXISTS Price_history;
DROP TABLE IF EXISTS Reviews;
DROP TABLE IF EXISTS Orders;
DROP TABLE IF EXISTS Buyers;
DROP TABLE IF EXISTS Produce_listings;
DROP TABLE IF EXISTS Categories;
DROP TABLE IF EXISTS Farmers;
DROP TABLE IF EXISTS Provinces;
DROP TABLE IF EXISTS Buyer_types;
DROP TABLE IF EXISTS Order_statuses;

-- Create lookup tables
CREATE TABLE Provinces (
    province_id     INT PRIMARY KEY IDENTITY(1,1),
    province_name   VARCHAR(100) NOT NULL UNIQUE
);

CREATE TABLE Categories (
    category_id     INT PRIMARY KEY IDENTITY(1,1),
    category_name   VARCHAR(100) NOT NULL UNIQUE
);

CREATE TABLE Order_statuses (
    status_id       INT PRIMARY KEY IDENTITY(1,1),
    status_name     VARCHAR(50) NOT NULL UNIQUE
);

CREATE TABLE Buyer_types (
    buyer_type_id   INT PRIMARY KEY IDENTITY(1,1),
    type_names      VARCHAR(100) NOT NULL UNIQUE
);

CREATE TABLE Farmers (
    farmer_id   INT PRIMARY KEY IDENTITY(1,1),
    full_name   VARCHAR(150) NOT NULL,
    email       VARCHAR(255) NOT NULL UNIQUE,
    phone_number VARCHAR(20) NOT NULL,
    farm_name   VARCHAR(200) NOT NULL,
    location    VARCHAR(200) NOT NULL,
    province_id INT NOT NULL FOREIGN KEY REFERENCES Provinces(province_id),
    rating      DECIMAL(3,2) NOT NULL DEFAULT 0.00 
                             CHECK(rating BETWEEN 0.00 AND 5.00),
    is_verified BIT NOT NULL DEFAULT 0,
    created_at  DATETIME NOT NULL DEFAULT GETDATE()
);

CREATE TABLE Product_listings (
    listing_id   INT PRIMARY KEY IDENTITY(1,1),
    farmer_id    INT NOT NULL FOREIGN KEY REFERENCES Farmers(farmer_id),
    product_name VARCHAR(200) NOT NULL CHECK(LEN(product_name) >= 3),
    category_id  INT NOT NULL FOREIGN KEY REFERENCES Categories(category_id),
    price_per_kg DECIMAL(10,2) NOT NULL CHECK(price_per_kg > 0),
    quantity_kg  DECIMAL(10,2) NOT NULL CHECK(quantity_kg > 0),
    is_available BIT NOT NULL DEFAULT 1,
    harvest_date DATETIME,
    date_listed  DATETIME NOT NULL DEFAULT GETDATE(),
    description  VARCHAR(500) NULL
    -- PostgreSQL: LEN() , LENGTH(); GETDATE() , NOW()
);

CREATE TABLE Buyers (
    buyer_id      INT PRIMARY KEY IDENTITY(1,1),
    full_name     VARCHAR(150) NOT NULL,
    email         VARCHAR(255) NOT NULL UNIQUE,
    phone_number  VARCHAR(20) NOT NULL,
    buyer_type_id INT NOT NULL FOREIGN KEY REFERENCES Buyer_types(buyer_type_id),
    location      VARCHAR(200) NOT NULL,
    created_at    DATETIME DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE Orders (
    order_id         INT PRIMARY KEY IDENTITY(1,1),
    buyer_id         INT NOT NULL FOREIGN KEY REFERENCES Buyers(buyer_id),
    listing_id       INT NOT NULL FOREIGN KEY REFERENCES Product_listings(listing_id),
    quantity_ordered DECIMAL(10,2) NOT NULL 
                        CHECK(quantity_ordered > 0),
    total_price      DECIMAL(12,2) NOT NULL,
    status_id        INT NOT NULL FOREIGN KEY REFERENCES Order_statuses(status_id),
    order_date       DATETIME DEFAULT CURRENT_TIMESTAMP,
    collection_date  DATETIME NULL,
    notes            VARCHAR(500) NULL
);

CREATE TABLE Reviews (
    review_id   INT PRIMARY KEY IDENTITY(1,1),
    buyer_id    INT NOT NULL FOREIGN KEY REFERENCES Buyers(buyer_id),
    farmer_id   INT NOT NULL FOREIGN KEY REFERENCES Farmers(farmer_id),
    order_id    INT NOT NULL UNIQUE FOREIGN KEY REFERENCES Orders(order_id),
    rating      TINYINT NOT NULL 
                    CHECK(rating BETWEEN 1 AND 5),
    comment     VARCHAR(1000) NULL,
    date_posted DATETIME DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE Price_history (
    history_id  INT PRIMARY KEY IDENTITY(1,1),
    listing_id  INT NOT NULL FOREIGN KEY REFERENCES Product_listings(listing_id),
    old_price   DECIMAL(10,2) NOT NULL,
    new_price   DECIMAL(10,2) NOT NULL,
    changed_at  DATETIME DEFAULT CURRENT_TIMESTAMP,
    changed_by  VARCHAR(150) NULL
);

INSERT INTO Provinces(province_name) VALUES
('Gauteng'), ('Western Cape'), ('KwaZulu–Natal'),
('Limpopo'), ('Mpumalanga'), ('North West'),
('Free State'), ('Northern Cape'), ('Eastern Cape');

INSERT INTO Categories(category_name) VALUES
('Vegetables'), ('Fruit'), ('Grain'), ('Dairy'), ('Other');

INSERT INTO Order_statuses(status_name) VALUES
('Pending'), ('Confirmed'), ('Collected'), ('Cancelled');

INSERT INTO Buyer_types(type_names) VALUES
('Individual'), ('SpazaShop'), ('Restaurant'), ('School'), ('Other');