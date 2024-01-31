// Initialize Web3 and connect to the Ethereum network
const Web3 = window.Web3;
const web3 = new Web3(window.ethereum);

// Store the connected MetaMask account
let connectedAccount;

// Store GameToken & NFT Contract info
let gameTokenContract;
let nftContract;

// Fetch GameToken contract ABI and address, and initialize the contract
fetch('./build/contracts/GameToken.json')
  .then(response => response.json())
  .then(contractData => {
    const contractABI = contractData.abi;
    const contractAddress = contractData.networks['5777'].address; // '5777' is the network ID for Ganache
    gameTokenContract = new web3.eth.Contract(contractABI, contractAddress);
  })
  .catch(error => console.error('Could not fetch contract data:', error));

// Fetch NFT contract ABI and address, and initialize the contract
fetch('./build/contracts/NFT.json')
.then(response => response.json())
.then(contractData => {
  const contractABI = contractData.abi;
  const contractAddress = contractData.networks['5777'].address; // '5777' is the network ID for Ganache
  nftContract = new web3.eth.Contract(contractABI, contractAddress);
})
.catch(error => console.error('Could not fetch contract data:', error));


// MetaMask Connection
// Check if MetaMask connection is available
if (typeof window.ethereum !== 'undefined') {
    const connectWalletButton = document.getElementById('connect-wallet');
  
    // Event Listener for Connect Wallet button
    connectWalletButton.addEventListener('click', async () => {
      try {
        // Request access to the user's Ethereum account
        await window.ethereum.request({ method: 'eth_requestAccounts' });
  
        // Retrieve and store the user's account
        const accounts = await web3.eth.getAccounts();
        connectedAccount = accounts[0];
        document.getElementById('connect-wallet').textContent = 'Connected';
        console.log(`Connected with address: ${connectedAccount}`);

        updateBalanceDisplay();
  
      } catch (error) {
        console.error('Error connecting wallet:', error);
      }
    });
  } else {
    console.error('MetaMask is not installed.');
  }

  // Show GT Token Balance for Connected Wallet
  async function updateBalanceDisplay() {
    try {
      // Fetch the balance in the smallest unit (like wei for ETH)
      const rawBalance = await gameTokenContract.methods.balanceOf(connectedAccount).call();
  
      // Convert the balance to GT (assuming 18 decimal places)
      const balanceInGT = rawBalance;
  
      // Format the balance to a fixed number of decimal places for readability
      const formattedBalance = Number(balanceInGT).toLocaleString(undefined, { maximumFractionDigits: 2 });
  
      document.getElementById('balanceDisplay').innerText = `GT Balance: ${formattedBalance} GT`;
    } catch (error) {
      console.error('Error fetching balance:', error);
      document.getElementById('balanceDisplay').innerText = 'Error fetching balance';
    }
  }


// Set to track processed event identifiers
let processedEvents = new Set();

// Mint button listener
document.getElementById('mintButton').addEventListener('click', async () => {
  try {
    // Set up the event listener
    let eventProcessed = false; // Flag to track if event is processed
    nftContract.events.Transfer({
      filter: { _to: connectedAccount },
      fromBlock: 'latest'
    })
    .on('data', (event) => {
      // Create a unique identifier for the event
      let eventId = event.transactionHash + "_" + event.logIndex;

      // Process the event if it's not already processed
      if (!processedEvents.has(eventId) && !eventProcessed) {
        processedEvents.add(eventId);
        eventProcessed = true; // Set the flag as processed

        let nftId = event.returnValues.tokenId;
        let rarity = event.returnValues.tokenRarity;
        let ownerAddress = event.returnValues.to;
  
        console.log(`Minted NFT ID: ${nftId}`);
        console.log(`Rarity: ${rarity}`);
        console.log(`Owner Address: ${ownerAddress}`);

        // Prepare data to be sent to backend
        const tokenData = {
          tokenId: nftId,
          rarity: rarity,
          ownerAddress: ownerAddress
        };

        // Send the data to the backend
        sendDataToBackend(tokenData);

        // Popup message to the user on the frontend after successfully minting an NFT
        // NOTE should be changed to a better looking popup instead of using the browser default
        alert('NFT minted successfully!\n\n' + 'Mint ID: ' + nftId + '\n' + 'Rarity: ' + rarity);
      }
    })
    .on('error', console.error);

    // Mint the NFT
    const result = await nftContract.methods.mint(connectedAccount).send({ from: connectedAccount });
    console.log('NFT minted successfully', result);

  } catch (error) {
    console.error('Error minting NFT', error);
  }
});




// Send minted NFT data to backend database
async function sendDataToBackend(tokenData) {
  try {
    const response = await fetch('http://localhost:3000/logNFT', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
      },
      body: JSON.stringify(tokenData),
    });

    if (response.ok) {
      console.log("Data sent successfully to the backend.");
    } else {
      console.error("Failed to send data to the backend.");
    }
  } catch (error) {
    console.error("Error sending data to the backend:", error);
  }
}



