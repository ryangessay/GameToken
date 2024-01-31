USE tokennft;
SHOW databases;
SHOW TABLES;
DESC tokens;
SELECT * FROM tokens;


ALTER TABLE tokens
CHANGE COLUMN tokenID tokenID INT NOT NULL;

ALTER TABLE listings
DROP FOREIGN KEY listings_ibfk_1;

ALTER TABLE transactions
DROP FOREIGN KEY transactions_ibfk_2;

SHOW CREATE TABLE transactions;


ALTER TABLE listings
ADD FOREIGN KEY (tokenID) REFERENCES tokens(tokenID);


ALTER TABLE transactions
ADD FOREIGN KEY (tokenID) REFERENCES tokens(tokenID);




CREATE TABLE tokens (
    tokenID INT PRIMARY KEY AUTO_INCREMENT,
    ownerAddress VARCHAR(42) NOT NULL, 
    rarityID INT NOT NULL,
    mintDate TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (rarityID) REFERENCES rarities(rarityID)
);

CREATE TABLE rarities (
    rarityID INT PRIMARY KEY,
    rarityName VARCHAR(20) NOT NULL UNIQUE
);

INSERT INTO rarities (rarityID, rarityName) VALUES 
(0, 'Common'),
(1, 'Uncommon'),
(2, 'Rare'),
(3, 'UltraRare');

CREATE TABLE listings (
    listingID INT PRIMARY KEY AUTO_INCREMENT,
    tokenID INT NOT NULL,
    listDate TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    buyoutPrice DECIMAL(9,2) DEFAULT NULL,
    forSale BOOLEAN NOT NULL DEFAULT FALSE,
    FOREIGN KEY (tokenID) REFERENCES tokens(tokenID)
);

CREATE TABLE bids (
    bidID INT PRIMARY KEY AUTO_INCREMENT,
    listingID INT NOT NULL,
    bidderAddress VARCHAR(42) NOT NULL,
    bidAmount DECIMAL(9,2) NOT NULL,
    bidDate TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (listingID) REFERENCES listings(listingID)
);

CREATE TABLE transactions (
    transactionID INT PRIMARY KEY AUTO_INCREMENT,
    listingID INT,
    tokenID INT NOT NULL,
    sellerAddress VARCHAR(42) NOT NULL,
    buyerAddress VARCHAR(42) NOT NULL,
    finalPrice DECIMAL (9,2),
    transactionDate TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (listingID) REFERENCES listings(listingID),
    FOREIGN KEY (tokenID) REFERENCES tokens(tokenID)
);

CREATE INDEX idx_ownerAddress ON tokens(ownerAddress);
CREATE INDEX idx_bidderAddress ON bids(bidderAddress);
CREATE INDEX idx_tokenID_listings ON listings(tokenID);
CREATE INDEX idx_listingID_transactions ON transactions(listingID);
CREATE INDEX idx_tokenID_transactions ON transactions(tokenID);

UPDATE listings SET forSale = FALSE WHERE listingID = [the_listing_id];
