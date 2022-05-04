// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;
import  "./IERC721.sol";


contract Market{
    

    enum ListingStatus{
        Actiave,
        Sold,
        Cancelled
    }

    struct Listing {
        ListingStatus stauts;
        address seller;
        address token;
        uint idToken;
        uint price;
    }


    uint private _listingId = 0;

    event Listed (
        uint listingId,
        address seller,
        address token,
        uint tokenId,
        uint price
    );

    event Sale (
        uint listingId,
        address buyer,
        address token,
        uint tokenId,
        uint price
    );

    event Cancel(    
        uint listingId,
        address seller
    );

    mapping(uint => Listing) private _listings;

    function getListing(uint listingId) public view returns(Listing memory){
        return _listings[listingId];
    }

    function listToken(address token, uint idToken, uint price) external {
        IERC721(token).transferFrom(msg.sender, address(this) , idToken);
        Listing memory listing = Listing(ListingStatus.Actiave ,
            msg.sender,token,idToken,price);
        _listings[_listingId++]  = listing;

        emit Listed(_listingId, msg.sender, token, idToken, price);
    }

    function buyToken(uint listingId) external payable {
        Listing storage listing = _listings[listingId];

        require(listing.stauts == ListingStatus.Actiave, 
            "Listing is not actiave");

        // if(listing.stauts != ListingStatus.Actiave){
        //     revert("Listing is not actiave");
        // }

        require(listing.seller != msg.sender, 
            "seller can not be buyer");
        

        
        require(msg.value >= listing.price, 
            "insufficent payment");
        IERC721(listing.token).transferFrom(address(this), msg.sender, 
            listing.idToken);

        payable(listing.seller).transfer(listing.price);

        emit Sale(listingId, msg.sender, listing.token, listing.idToken, listing.price);  
    }

    function cancel(uint listingId) public{
        Listing storage listing = _listings[listingId];
        // msg.sender is the caller of this functoin.
        require(listing.stauts == ListingStatus.Actiave, "Listing is not activate");
        require(listing.seller == msg.sender, "Only seller can cancel listing");

        listing.stauts = ListingStatus.Cancelled;
        IERC721(listing.token).transferFrom(address(this), msg.sender, 
            listing.idToken);

        emit Cancel(listingId, msg.sender);
    }
}