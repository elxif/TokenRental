// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

/*
 * 
• Anyone should be able to rent their tokens.
• The contract should provide a way to temporarily transfer the ownership of the
tokens.
• The contract should provide a way to do exchanges of the tokens, therefore per-
manently transferring the ownership of the tokens.
• The contract should override some of the standard ERC-721 functions, such as
transfer functions.
• The contract should perform feasibly under the load of users on the scale of
millions.
• The contract should implement a data structure that has low complexity for
search, add, edit, delete and detect collision operations to hold the intervals of
time of rental periods.
• The contract functions should be efficient so that the gas fees of the functions are
reasonable.
• The contract should support different kinds of rental periods such as minutes,
hours, days, months etc.
 * 
 */

//TODO: adapt to erc721
//TODO: add base fee to assets
//TODO: check enough payment made in request
//TODO: asset info return rentable
//TODO: write view functions: membercount, assetcount etc
//TODO: improve toggleAssetAvailability error messages, e.g. when there is no asset
//TODO: add error message: no request exists in respondRentalContractRequest
//TODO: when the response is given as false then the paid amount should be refunded
//TODO: get requestInfo function implementation
//TODO: get rentalcontractinfo function implementation
//TODO: return contractid when responded, return -1 if rejected 
//TODO: when approving you should check whether the start time of the request is already past, make refund
//TODO: when a request is not responded till its start time you should refund it
//     * writefunction: request refund if start time is past and responded is false AND renter is msg.sender
//TODO:
//TODO:





contract TokenRentalSystem is ERC721 {

	address public owner;
	uint memberCount = 0;
  	uint assetCount = 0;
  	uint rentalContractCount = 0;
  	uint rentalContractRequestCount = 0;

    struct Member {
      	bool isActive;
        bool isBanned;
        uint[] assetList; //TODO: what happens to the list when member sells asset?
    }

    struct RentalContract {
        uint startTime;
        uint endTime;
        address assetOwner;
        address assetRenter;
        uint assetID;
    }
  
  	struct RentalContractRequest {
      	uint startTime;
      	uint endTime;
      	uint assetID;
      	address assetRenter;
      	bool responded;
    }

    struct Asset {
        string assetName;
        address assetOwner;
      	bool rentable;
        bool isRealEstate;
        uint latitude; // X coordinate
        uint longitude; // Y coordinate
      	uint[] contractList;
    }

    struct Payment {
        uint paymentID;
        uint paymentDateTime;
        uint paymentAmount;
        address whoPays;
        address whoGetPaid;
    }

    mapping(address => Member) private members;
    mapping(uint => Asset) private assets;
  	mapping(uint => RentalContractRequest) private rentalRequests;
    mapping(uint => RentalContract) private rentalContracts;

    constructor() ERC721("TokenRental", "TRS") {
        owner = msg.sender;
    }

	function getAssetOwner(uint assetID) public view returns(address ownerAddress){
		return assets[assetID].assetOwner;
	}
  
	function createAsset(string memory assetName, bool isRealEstate, uint latitude, uint longitude, bool rentable) public onlyActiveMember(msg.sender) returns(uint assetID) {
        assetCount++;
		assetID = assetCount;
        assets[assetID].assetName = assetName;
        assets[assetID].assetOwner = msg.sender;
        assets[assetID].isRealEstate = isRealEstate;
        assets[assetID].latitude = latitude;
        assets[assetID].longitude = longitude;
      	assets[assetID].rentable = rentable;
      
        members[msg.sender].assetList.push(assetID);
        return assetID;
  	}
  
  	function toggleAssetAvailability(uint assetID) public onlyActiveMember(msg.sender) returns(bool rentable) {
      Asset storage a = assets[assetID];
      require(a.assetOwner == msg.sender, "You are not the owner of this asset.");
      a.rentable = !a.rentable;
      return a.rentable;
      
    }
  
    function createMember() public returns(address memberAddress) {
      	require(!members[msg.sender].isBanned, "Member is banned.");
        memberAddress = msg.sender;
        members[memberAddress].isActive = true;
      	memberCount++;
        return memberAddress;
  	}
  
  	/// Review this function again, private? returns bool?
    function createMemberByAdmin(address memberAddress) private {
     	memberCount++;
        members[memberAddress].isActive = true;
        memberCount++;
  	}
  
   // checks if the member account is active
   modifier onlyActiveMember(address person) {
       require(members[person].isActive && !members[person].isBanned, "Address is not yet a member or is banned!");
       _;
   }
  
	function getAssetInfo(uint assetID) public view returns(string memory assetName, address assetOwner, bool isRealEstate, uint latitude, uint longitude){
    	assetName = assets[assetID].assetName;
        assetOwner = assets[assetID].assetOwner;
        isRealEstate = assets[assetID].isRealEstate;
        latitude = assets[assetID].latitude;
        longitude = assets[assetID].longitude;
        return (assetName, assetOwner, isRealEstate, latitude, longitude);
    }
  
	function getMemberInfo(address memberAddress) public view returns(bool isActive, bool isBanned, uint[] memory assetList) {
      	Member storage m = members[memberAddress];
      	return(m.isActive, m.isBanned, m.assetList);
    }
  
    function getRentalContractInfo(uint rentalContractID) public view returns(uint startTime, uint endTime, 
                                                                                 address assetOwner, address assetRenter,uint assetID) {
      	RentalContract storage r = rentalContracts[rentalContractID];
      	return(r.startTime, r.endTime, r.assetOwner, r.assetRenter, r.assetID);
    }
  
      function getRequestInfo(uint requestID) public view returns(uint assetID, bool responded, address assetRenter, uint startTime, uint endTime) {
        RentalContractRequest storage r = rentalRequests[requestID];
        return(r.assetID, r.responded, r.assetRenter, r.startTime, r.endTime);
    }
  
    function respondRentalContractRequest(uint requestID, bool RentalContractResponse) public onlyActiveMember(msg.sender) {
        //Member storage m = members[msg.sender];
        RentalContractRequest storage r = rentalRequests[requestID];
        Asset storage a = assets[r.assetID];
        //require request does not exist
        require(a.assetOwner == msg.sender, "You are not the owner of this asset.");
        require(!r.responded, "This request has already been responded to.");
      	r.responded = true;
        if(RentalContractResponse) {
          	approveRentalContractRequest(requestID);
        }

    }
  
    function approveRentalContractRequest(uint requestID) private {
        rentalContractCount++;
        uint rentalContractID = rentalContractCount;
        rentalContracts[rentalContractID].startTime = rentalRequests[requestID].startTime;
        rentalContracts[rentalContractID].endTime = rentalRequests[requestID].endTime;
        rentalContracts[rentalContractID].assetID = rentalRequests[requestID].assetID;
        rentalContracts[rentalContractID].assetRenter = rentalRequests[requestID].assetRenter;
        rentalContracts[rentalContractID].assetOwner = assets[rentalRequests[requestID].assetID].assetOwner;
      	assets[rentalRequests[requestID].assetID].contractList.push(rentalContractID);
      	
    }

    function makeRentalContractRequest(uint assetID, uint startTime, uint endTime) public payable onlyActiveMember(msg.sender) returns(uint requestID){
        //Member storage requester = members[msg.sender];
        Asset storage a = assets[assetID];
      	require(a.assetOwner != address(0), "Asset does not exist.");
      	require(startTime >= block.timestamp, "Start time cannot be in the past.");
      	require(endTime > startTime, "Start time cannot be later than end time.");
        require(a.rentable, "Asset is not available for renting.");
      	require(msg.sender != a.assetOwner, "You cannot rent your own assets!");
        for(uint i = 0; i < a.contractList.length; i++) {
            RentalContract storage r = rentalContracts[a.contractList[i]];
            //!(r.startTime <= startTime && r.endTime >= endTime)
            //require(!(startTime >= r.startTime && startTime < r.endTime), "Asset is not available between selected times.");
            //require(!(endTime > r.startTime && endTime <= r.endTime), "Asset is not available between selected times.");
            require(startTime >= r.endTime || endTime <= r.startTime, "Asset is not available between selected times.");
        }
        rentalContractRequestCount++;
        requestID = rentalContractRequestCount;
        rentalRequests[requestID].startTime = startTime;
        rentalRequests[requestID].endTime = endTime;
        rentalRequests[requestID].assetID = assetID;
        rentalRequests[requestID].assetRenter = msg.sender;
        return requestID;

    }
  
}
