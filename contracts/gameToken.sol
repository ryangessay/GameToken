//SPDX-License-Identifier: MIT
pragma solidity >= 0.5.0 < 0.9.0;

contract GameToken {

    string public constant name = "GameToken";
    string public constant symbol = "GT";
    uint8 public constant decimals = 18;
    uint256 public totalSupply;
    uint256 public exchangeRate = 100; // 1 Ether = 100 Game Token

    address public owner;

    // For noReentrant modifier.
    bool private locked;

    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    constructor(uint256 _initialSupply) public {
        totalSupply = _initialSupply * 10**18;

        // Allocate 25% of total supply to contract for swapping
        uint256 contractAllocation = _initialSupply * 25 / 100;
        balanceOf[address(this)] = contractAllocation;

        // Allocate 75% of total supply to the owner
        uint256 ownerAllocation = _initialSupply - contractAllocation;
        balanceOf[msg.sender] = ownerAllocation;

        emit Transfer(address(0), address(this), contractAllocation);
        emit Transfer(address(0), msg.sender, ownerAllocation);

        owner = msg.sender;
    }

    // Prevent Re-entrancy Attacks.
    modifier noReentrant() {
        require(!locked, "No reentrancy");
        locked = true;
        _;
        locked = false;
    }

    function transfer(address _to, uint256 _value) public returns (bool success) {
        require(_to != address(0), "Invalid address");
        require(balanceOf[msg.sender] >= _value, "Sending amount exceeds supply amount!");

        balanceOf[msg.sender] -= _value;
        balanceOf[_to] += _value;
        emit Transfer(msg.sender, _to, _value);
        return true;
    }

    function approve(address _spender, uint256 _value) public returns (bool success) {
        require(_spender != address(0), "Invalid address");

        allowance[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
        require(_value <= balanceOf[_from], "Sending amount exceeds supply amount!");
        require(_value <= allowance[_from][msg.sender], "Amount cannot exceed allowance!");
        balanceOf[_from] -= _value;
        balanceOf[_to] += _value;
        allowance[_from][msg.sender] = _value;
        emit Transfer(_from, _to, _value);
        return true;
    }

    function swap() public payable noReentrant {
        require(msg.value > 0, "Send Ether to swap for Game Token");

        uint256 transferAmount = (msg.value * exchangeRate) / 1 ether; // GameToken received
        require(balanceOf[address(this)] >= transferAmount, "Insufficient Game Token balance in Contract");

        balanceOf[msg.sender] += transferAmount;
        balanceOf[address(this)] -= transferAmount;

        emit Transfer(address(this), msg.sender, transferAmount);
    }

    function fundContract(uint256 _value) public noReentrant {
        require(msg.sender == owner, "You must be the owner to send funds");
        require(_value > 0, "To fund the contract, please send more than 0 tokens");
        require(balanceOf[msg.sender] >= _value, "Insufficient balance to fund contract");

        balanceOf[msg.sender] -= _value;
        balanceOf[address(this)] += _value;

        emit Transfer(msg.sender, address(this), _value);
    }

    // Add Staking Options?
    // Add Transfer Owner?
}