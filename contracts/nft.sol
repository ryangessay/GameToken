//SPDX-License-Identifier: MIT
pragma solidity >= 0.5.0 < 0.9.0;

contract NFT {

    // Enums, Constants, Structs
    enum Rarity { Common, Uncommon, Rare, UltraRare}
    uint256 private constant Total_NFT = 50;
    struct NFTData {
        uint256 id;
        Rarity rarity;
    }

    // State Variables
    NFTData[Total_NFT] public nfts;
    uint256 private mintCounter = 0;
    address public contractOwner;

    // Mappings
    mapping(uint256 => address) private _owners;
    mapping(address => uint256) private _balances;
    mapping(uint256 => address) private _tokenApprovals; 

    // Events
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId, uint256 tokenRarity);
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);

    constructor() public {contractOwner = msg.sender;}

    // Mint a new NFT
    function mint(address to) public payable {
        require(to != address(0), "Mint to the zero address");
        require(mintCounter < Total_NFT, "All NFTs minted");

        uint256 nftIndex = mintCounter;
        mintCounter++;
        Rarity rarity = assignRarity();
        nfts[nftIndex] = NFTData(nftIndex + 1, rarity);
        _owners[nfts[nftIndex].id] = to;
        _balances[to] += 1;

        emit Transfer(address(0), to, nfts[nftIndex].id, uint256(nfts[nftIndex].rarity));
    }

    // Rarity assigned to the newly minted NFT
    function assignRarity() internal view returns (Rarity) {
        uint256 random = pseudoRandom();
        if (random < 50) return Rarity.Common;
        if (random < 75) return Rarity.Uncommon;
        if (random < 92) return Rarity.Rare;
        return Rarity.UltraRare;
    }

    // RNG for assigning rarity
    // NOTE: In a real world environment, this would use Chainlink VRF
    function pseudoRandom() public view returns (uint256) {
        return uint256(keccak256(abi.encodePacked(block.difficulty, block.timestamp, block.number, msg.sender))) % 100;
    }


    // Transfer a token from one address to another
    function transferFrom(address from, address to, uint256 tokenId) public {
        require(isApprovedOrOwner(msg.sender, tokenId), "ERC721: transfer caller is not owner nor approved");
        require(from == _owners[tokenId], "ERC721: transfer of token that is not own");
        require(to != address(0), "ERC721: transfer to the zero address");

        _owners[tokenId] = to;
        _balances[from]--;
        _balances[to]++;

        emit Transfer(from, to, tokenId, uint256(nfts[tokenId].rarity));
    }

    // Approve an address to transfer a specific token
    function approve(address to, uint256 tokenId) public {
        address owner = _owners[tokenId];
        require(owner == msg.sender, "ERC721: approve caller is not the owner");
        _tokenApprovals[tokenId] = to;
        emit Approval(owner, to, tokenId);
    }

    // Query an approved address for a specific token
    function getApproved(uint256 tokenId) public view returns (address) {
        require(_owners[tokenId] != address(0), "ERC721: approved query for nonexistent token");
        return _tokenApprovals[tokenId];
    }

    // Check if an address is the owner or approved for a specific token
    function isApprovedOrOwner(address spender, uint256 tokenId) public view returns (bool) {
        require(_owners[tokenId] != address(0), "ERC721: operator query for nonexistent token");
        address owner = _owners[tokenId];
        return (spender == owner || getApproved(tokenId) == spender);
    }

    // See how many NFTs an address owns
    function balanceOf(address owner) public view returns (uint256) {
        require(owner != address(0), "Address zero is not a valid owner");
        return _balances[owner];
    }

    // See the owner and rarity of an NFT
    function getNFTData(uint256 tokenId) public view returns (uint256, Rarity, address) {
        require(tokenId >= 1 && tokenId <= Total_NFT, "NFTs are numbered from 1 to 50");
        NFTData storage nft = nfts[tokenId - 1];
        address owner = _owners[nft.id];
        return (nft.id, nft.rarity, owner);
    }

    // See all NFTs by rarity
    function getNFTsByRarity(Rarity rarity) public view returns (uint256[] memory) {
        uint256[] memory ids = new uint256[](Total_NFT);
        uint256 count = 0;

        for (uint256 i = 0; i < Total_NFT; i++) {
            if (nfts[i].rarity == rarity) {
                ids[count] = nfts[i].id;
                count++;
            }
        }

        // Resize the array to fit the actual number of found NFTs
        uint256[] memory foundIds = new uint256[](count);
        for (uint256 i = 0; i < count; i++) {
            foundIds[i] = ids[i];
        }
        return foundIds;
    }
}