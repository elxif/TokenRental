// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

contract TokenRentalSystem is ERC721 {

    address public owner;

    struct Member {
        string fullName;
        uint memberID;
    }

    struct RentalContract {
        uint startTime;
        uint endTime;
        Member owner;
        Member renter;
        Asset rentalAsset;
    }

    struct Asset {
        string name;
        address assetAddress;
        Member owner;
    }

    struct Payment {
        uint paymentId;
        uint paymentDateTime;
        uint paymentAmount;
        address whoPays;
        address whoGetPaid;
    }

    mapping(uint => Member) public members;
    mapping(uint => Asset) public assets;

    constructor() ERC721("TokenRental", "TRS") {
        owner = msg.sender;
    }

   function getAssetOwner(uint assetID) public view returns(string memory fullname){
       Asset storage a = assets[assetID];
       return a.owner.fullName;
   }

 
}
 
