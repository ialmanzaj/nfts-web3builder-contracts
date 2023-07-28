// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract Web3Builder is ERC721, ERC721Enumerable, Pausable, Ownable {
    using Counters for Counters.Counter;

    uint public constant MAX_SUPPLY = 999;
    uint public constant COST = 0.01 ether;

    bool public allowListMintOpen = false;
    bool public allowListPublicMintOpen = false;
    mapping(address => bool) public reservedList;

    uint private _tokenIdCounter;

    constructor() ERC721("Web3Builder", "WEB3") {}

    function _baseURI() internal pure override returns (string memory) {
        return "ipfs://QmY5rPqGTN1rZxMQg2ApiSZc7JiBNs1ryDzXPZpQhC1ibm/";
    }

    function pause() public onlyOwner {
        _pause();
    }

    function unpause() public onlyOwner {
        _unpause();
    }

    function isAddressReserved(address addr) public view returns (bool) {
        return reservedList[addr];
    }

    function editMintWindows(
        bool _allowListMintOpen, 
        bool _allowListPublicMintOpen) external onlyOwner{
        allowListMintOpen = _allowListMintOpen;
        allowListPublicMintOpen = _allowListPublicMintOpen;
    }

    // add Payment
    // add limiting of supply
    function publicMint() public payable {
        require(allowListPublicMintOpen, "Not open the public mint");
        internalMint();
    }

    function setAllowList(address[] calldata addresses) external onlyOwner {
        for(uint i; i< addresses.length;i++) {
            reservedList[addresses[i]] = true;
        }
    }

    // add Payment
    // add limiting of supply
    function allowListMint() public  payable {
        require(allowListMintOpen, "Not open the public mint");
        require(reservedList[msg.sender], "You are not in the VIP list");
        internalMint();
    }

    function internalMint() internal  {
        require(msg.value == COST, "Not enough funds");
        require(totalSupply() < MAX_SUPPLY, "We sold out");
        uint tokenId = _tokenIdCounter;
        _tokenIdCounter++;
        _safeMint(msg.sender, tokenId);
    }

    function _beforeTokenTransfer(address from, address to, uint256 tokenId, uint256 batchSize)
        internal
        whenNotPaused
        override(ERC721, ERC721Enumerable)
    {
        super._beforeTokenTransfer(from, to, tokenId, batchSize);
    }

    // The following functions are overrides required by Solidity.

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC721, ERC721Enumerable)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }
}