const express = require('express');
const mysql = require('mysql');
const cors = require('cors');

const app = express();
const port = 3000;

app.use(cors());
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// MySQL database connection credentials
const dbConnection = mysql.createConnection({
    host: 'localhost',
    user: 'root',
    password: 'password',
    database: 'tokennft'
  });

  // Connect to the database
dbConnection.connect(err => {
    if (err) {
        console.error('Error connecting: ' + err.stack);
        return;
    }
    console.log('Connected to database as ID ' + dbConnection.threadId);
});

app.get('/', (req, res) => {
  res.send('Hello World!');
});



// Receive NFT mint data from frontend  
app.post('/logNFT', (req, res) => {
  const { tokenId, rarity, ownerAddress } = req.body;

  // Construct the SQL query
  const query = 'INSERT INTO tokens (tokenID, rarityID, ownerAddress) VALUES (?, ?, ?)';

  // Execute the query
  dbConnection.query(query, [tokenId, rarity, ownerAddress], (err, result) => {
    if (err) {
      console.error('Error inserting data into the database:', err);
      res.status(500).send('Error inserting data into the database');
    } else {
      console.log('NFT data inserted successfully:', result);
      res.status(200).send('NFT data inserted successfully');
    }
  });
});

// Start the Express server
app.listen(port, () => {
  console.log(`Server is running on port ${port}`);
});
