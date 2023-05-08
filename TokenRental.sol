// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

contract TokenRentalSystem is ERC721 {

    address public owner;

    constructor() ERC721("TokenRental", "TRS") {
        owner = msg.sender;
    }

    struct Member {
        string Name;
    }

    struct Asset {
        string name;
        address assetAddress;
        address ownerAddress;
    }

    struct Payment {
        uint paymentId;
        uint paymentDateTime;
        uint paymentAmount;
        address whoPays;
        address whoGetPaid;
    }
 
}
 
