//nft exchange
pragma solidity ^0.8.0;
import "@openzeppelin/contracts/token/ERC721/utils/ERC721Holder.sol";
import "./ColorMinter.sol";

contract Exchange is ColorMinter, ERC721Holder { 
    
    uint256 _tokenId;
    address tokenOwner;
    uint256 tokenSalePrice;
    receive() external payable {}
    fallback() external payable {}
        event TokenPurchased(
        uint256 indexed tokenId,
        address indexed buyer,
        address indexed seller
    );
    event TokenTransferredToExchange(
        address indexed from,
        uint256 indexed tokenId,
        uint256 price
    );
    event ReceivedEther(address indexed from, uint256 amount);
    struct TokenSeller {
        address tokenOwner;
        uint256 tokenId;
        uint256 tokenSalePrice;}
        
     mapping(uint256 => TokenSeller) private _tokenInfo;   
     
     
     
    function getTokenSellData(uint256 _tokenId)
        public
        view
        returns (TokenSeller memory)
    {
        return _tokenInfo[_tokenId];
    }
    
        function mintNFT(string memory _tokenUri) public payable {
        require(msg.value == 1e12, "Amount sent must be 1e12.");
        uint256 tokenId = mint(_tokenUri);
        _setTokenURI(tokenId, _tokenUri);
    }
      function sellNFT(uint256 _tokenId, uint256 _sellPrice) public {
        require(
            _sellPrice >= 2e12,
            "Sale Error: Sell price must be 2e12 (2 szabos) or greater."
        );
        safeTransferFrom(msg.sender, address(this), _tokenId);
        emit TokenTransferredToExchange(msg.sender, _tokenId, _sellPrice);

        _tokenInfo[_tokenId] = TokenSeller(msg.sender, _tokenId, _sellPrice);
    }
      function getTokenBack(uint256 _tokenId) external {
        address tokenOwner = _tokenInfo[_tokenId].tokenOwner;
        require(
            msg.sender == tokenOwner,
            "You are not the owner of this token."
        );
        this.safeTransferFrom(address(this), msg.sender, _tokenId);
        delete _tokenInfo[_tokenId];
    }   
     function buyToken(uint256 _tokenId) external payable {
        TokenSeller memory tokenData = getTokenSellData(_tokenId);
        address tokenOwner = tokenData.tokenOwner;
        require(msg.sender != tokenOwner, "You can't purchase your own token!"); // Needs test
        uint256 tokenSalePrice = tokenData.tokenSalePrice;
        require(
            msg.value == tokenSalePrice,
            "Purchase amount doesn't equal the selling price."
         );
    }
     
    function payycontract()private{
        this.safeTransferFrom(address(this), msg.sender, _tokenId);
        emit TokenPurchased(_tokenId, msg.sender, address(tokenOwner));
        _paySellerAfterPurchase(tokenOwner,tokenSalePrice);
        delete _tokenInfo[_tokenId];
        
    }
       

    /**
     * @dev Pays the seller (the owner of the NFT that created the listing)
     * the sell price they offered the NFT for minus the commission fee.
     */
    function _paySellerAfterPurchase(
        address _tokenOwner,
        uint256 _tokenSalePrice
    ) private {
        uint256 payAmount = _tokenSalePrice - 1e12;
        (bool success, ) = _tokenOwner.call{value: payAmount}("");
        require(success, "Transaction failed.");
    }

    // Sends ether to contract from the address that calls this function
    function payContract() public payable {
        (bool success, ) = payable(address(this)).call{value: msg.value}("");
        require(success, "Transaction failed.");
        emit ReceivedEther(msg.sender, msg.value);
    }

    // Owner of contract can withdraw all contract's ether
    function withdrawAll() external onlyOwner {
        address payable _owner = payable(owner());
        (bool success, ) = _owner.call{value: address(this).balance}("");
        require(success, "Transaction failed.");
    }
            
    
        
}       

##if it dosent work tell me becouse i copy paste it and maybe it have problem from copy past 
