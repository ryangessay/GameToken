// Initialize Web3 and connect to the Ethereum network
const Web3 = window.Web3;
const web3 = new Web3(window.ethereum);

// Exchange rate for 1 Ethereum to equal 100 Game Token
const exchangeRate = 100;

// Store GameToken contract
let contract;

// Store the connected MetaMask account
let connectedAccount;


// Fetch contract ABI and address, and initialize the contract
fetch('./build/contracts/GameToken.json')
  .then(response => response.json())
  .then(contractData => {
    const contractABI = contractData.abi;
    const contractAddress = contractData.networks['5777'].address; // '5777' is the network ID for Ganache
    contract = new web3.eth.Contract(contractABI, contractAddress);

  })
  .catch(error => console.error('Could not fetch contract data:', error));


// Listener for swap function to automatically calculate exchange rate between tokens
function updateGameTokenAmount() {
    const ethereumAmount = parseFloat(document.getElementById('ethereumAmount').value) || 0;
    document.getElementById('gameTokenAmount').value = ethereumAmount * exchangeRate;
}

function updateEthereumAmount() {
    const gameTokenAmount = parseFloat(document.getElementById('gameTokenAmount').value) || 0;
    document.getElementById('ethereumAmount').value = gameTokenAmount / exchangeRate;
}

document.getElementById('ethereumAmount').addEventListener('input', updateGameTokenAmount);
document.getElementById('gameTokenAmount').addEventListener('input', updateEthereumAmount);


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
      const rawBalance = await contract.methods.balanceOf(connectedAccount).call();
  
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
  
  
// Swap Button Listener
document.getElementById('swapButton').addEventListener('click', async function() {
  const etherAmount = document.getElementById('ethereumAmount').value;
  if (isValidEtherAmount(etherAmount)) {
    await performSwap(etherAmount);
    displayErrorMessage('');
  } else {
    displayErrorMessage('*Invalid Ethereum amount entered*');
  }
});


// Swap Button Functionality
async function performSwap(etherAmount) {
  const accounts = await web3.eth.getAccounts();
  const amountInWei = web3.utils.toWei(etherAmount, 'ether');

  console.log("performSwap called with etherAmount:", etherAmount);

  contract.methods.swap().send({ from: connectedAccount, value: amountInWei })
  .then(function(receipt) {
      console.log("Swap successful!", receipt);
      displaySuccessMessage("Swap successful!");
      displayErrorMessage(''); // Clear any error message
      updateBalanceDisplay();
  })
  .catch(function(error) {
      console.error("Error during swap", error);
      displayErrorMessage("Error during swap");
      displaySuccessMessage(''); // Clear any success message
  });
}


// Validation Function
function isValidEtherAmount(amount) {
  // Check if the amount is a number, is not empty, and is greater than zero
  const valid = amount && !isNaN(amount) && Number(amount) > 0;

  console.log(`isValidEtherAmount(${amount}) returned ${valid}`);

  return valid;
}

// Function to Display Success Message
function displaySuccessMessage(message) {
  document.getElementById('successMessage').innerText = message;
}

// Function to Display Error Message
function displayErrorMessage(message) {
  document.getElementById('errorMessage').innerText = message;
}




