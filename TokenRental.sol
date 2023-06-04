// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/Strings.sol";


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

//TODO: in requests "cancelled" field is added this also need a check in necessary places




//@@@@@@ Done and needs reviews version 2222
//Review: //TODO: when the response is given as false then the paid amount should be refunded
//Review: //TODO: when the response is given as true then the paid ammount should be 
//                transferred to the member
//Review: //TODO: eğer request atarlarken gönderdikleri ücret toplam rental ücretinden 
//                fazla ise o gelen fazla amount u direkt geri gönderme
//Review: //TODO: Cancel request function --> canceling the request 
//                ( it may be done before start time and before it is responded!
//Review: //TODO: when a request is not responded after its start time you should refund it
//     * writefunction: request refund if start time is past and responded is false 
//                       AND renter is msg.sender AND request is not cancelled before already
 
//Review: 



// Done and needs reviews
//Review: //TODO: check enough payment made in request
//Review: //TODO: add base fee to assets ++++ also setting base fee implemented setRentalPrice function
//Review: //TODO: asset info return rentable implemented and rentPrice is also returned at info function
//Review: //TODO: improve toggleAssetAvailability error messages, e.g. when there is no asset 
//Review: //TODO: add error message: no request exists in respondRentalContractRequest ---> implemented by checking the value of assetRenter address in request struct
//Review: //TODO: get requestInfo function implementation ===>   it was already implemented
//Review: //TODO: get rentalcontractinfo function implementation  ===> it was already implemented
//Review: //TODO: return contractid when responded, return -1 if rejected ===> returning 0 instead of -1 due to using uint type everywhere,(every valid contractID > 0)
//Review: //TODO: when approving you should check whether the start time of the request is already past, make refund 
            /// only the cheking whether the start time is already in the past is implemented
            /// whole refund policy should be treated toghether and accordingly
//Review:   //TODO: write view functions: membercount, assetcount etc --- implemented at the bottom
//Review:
//Review:




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
        uint assetID;
        address assetRenter;
        bool ownerPaid;
    }
  
    struct RentalContractRequest {
        uint startTime;
        uint endTime;
        uint assetID;
        address assetRenter;
        bool responded;
        uint rentalContractID;
        bool cancelled;
        bool refunded;
    }

    struct Asset {
        string assetName;
        bool rentable;
        bool isRealEstate;
        int latitude; // X coordinate
        int longitude; // Y coordinate
        uint[] contractList;
        uint rentPrice; // per unit time
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
    return ownerOf(assetID);
    }
  
    function createAsset(string memory assetName, 
                        bool isRealEstate, 
                        int latitude, 
                        int longitude, 
                        bool rentable,
                        uint rentPrice) public onlyActiveMember(msg.sender) returns(uint assetID) {
      assetCount++;
          assetID = assetCount;
      assets[assetID].assetName = assetName;
      assets[assetID].isRealEstate = isRealEstate;
      assets[assetID].latitude = latitude;
      assets[assetID].longitude = longitude;
      assets[assetID].rentable = rentable;
      assets[assetID].rentPrice = rentPrice;
      _mint(msg.sender, assetID);

      members[msg.sender].assetList.push(assetID);
      return assetID;
    }
  
    function toggleAssetAvailability(uint assetID) public onlyActiveMember(msg.sender) returns(bool rentable) {
      Asset storage a = assets[assetID];
      require(ownerOf(assetID) == msg.sender, "You are not the owner of this asset.");
      a.rentable = !a.rentable;
      return a.rentable;
      
    }

    function setAssetRentPrice(uint assetID, uint rentPrice) public onlyActiveMember(msg.sender) {
      Asset storage a = assets[assetID];
      require(ownerOf(assetID) == msg.sender, "You are not the owner of this asset.");
      a.rentPrice = rentPrice;    
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
  
    function getAssetInfo(uint assetID) public view returns(string memory assetName, address assetOwner, bool isRealEstate, int latitude, int longitude, bool rentable, uint rentPrice){
        Asset storage a = assets[assetID];
      return (a.assetName, ownerOf(assetID), a.isRealEstate, a.latitude, a.longitude, a.rentable, a.rentPrice);
    }
  
    function getMemberInfo(address memberAddress) public view returns(bool isActive, bool isBanned, uint[] memory assetList) {
        Member storage m = members[memberAddress];
        return(m.isActive, m.isBanned, m.assetList);
    }

    function getRentalContractInfo(uint rentalContractID) public view returns(uint startTime, uint endTime, 
                                                                                 address assetOwner, address assetRenter,uint assetID) {
        RentalContract storage r = rentalContracts[rentalContractID];
        return(r.startTime, r.endTime, ownerOf(r.assetID), r.assetRenter, r.assetID);
    }
  
      function getRequestInfo(uint requestID) public view returns(uint assetID, bool responded, address assetRenter, 
                                                                  uint startTime, uint endTime, uint rentalContractID) {
        RentalContractRequest storage r = rentalRequests[requestID];
        return(r.assetID, r.responded, r.assetRenter, r.startTime, r.endTime, r.rentalContractID);
    }
  
    function respondRentalContractRequest(uint requestID, bool RentalContractResponse) public onlyActiveMember(msg.sender) returns(uint contractID){
        //Member storage m = members[msg.sender];
        RentalContractRequest storage r = rentalRequests[requestID];
        require(r.assetRenter != address(0), "The rental request does not exist!");
        require(ownerOf(r.assetID) == msg.sender, "You are not the owner of this asset.");
        require(!r.cancelled, "This request is cancelled! You cannot respond to a cancelled request!");
        require(!r.responded, "This request has already been responded.");
        require(r.startTime > block.timestamp, "You cannot respond to a rental request that rental period starts in the past!");
        r.responded = true;
        if(RentalContractResponse) {
            r.rentalContractID = approveRentalContractRequest(requestID);
            //payable(ownerOf(r.assetID)).transfer(assets[r.assetID].rentPrice*(r.endTime-r.startTime));
            return r.rentalContractID;
        }
        r.rentalContractID = 0;  // means contract not created, request rejected
        //return the rentalPrice*(endTime-startTime) to the r.assetRenter
        payable(r.assetRenter).transfer(assets[r.assetID].rentPrice*(r.endTime-r.startTime));
        return r.rentalContractID; 
    }
  
    function approveRentalContractRequest(uint requestID) private returns(uint rentalContractID){
        rentalContractCount++;
        rentalContractID = rentalContractCount;
        RentalContractRequest storage req = rentalRequests[requestID];
        rentalContracts[rentalContractID].startTime = req.startTime;
        rentalContracts[rentalContractID].endTime = req.endTime;
        rentalContracts[rentalContractID].assetID = req.assetID;
        rentalContracts[rentalContractID].assetRenter = req.assetRenter;
        assets[rentalRequests[requestID].assetID].contractList.push(rentalContractID);
        return rentalContractID;    
    }

    function makeRentalContractRequest(uint assetID, uint startTime, uint endTime) public payable onlyActiveMember(msg.sender) returns(uint requestID){
        //Member storage requester = members[msg.sender];
        Asset storage a = assets[assetID];
        require(msg.sender != ownerOf(assetID), "You cannot rent your own assets!");
        uint rentalFee = a.rentPrice * (endTime - startTime);
        require(msg.value >= rentalFee, string.concat(string.concat("You should pay at least ", Strings.toString(rentalFee)), " wei."));
        if(msg.value >= rentalFee){  
          // pay back the extra eth back to the renter immediately
          payable(msg.sender).transfer(msg.value - rentalFee);
        }
        require(startTime >= block.timestamp, "Start time cannot be in the past.");
        require(endTime > startTime, "Start time cannot be later than end time.");
        require(a.rentable, "Asset is not available for renting.");
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

    function cancelRequest(uint requestID) public{
      RentalContractRequest memory r = rentalRequests[requestID];
      require(r.assetRenter == msg.sender, "Only the members who made the request can cancel the request!");
      require(!r.responded, "This request is already responded! You cannot cancel a responded request!");
      require(r.startTime > block.timestamp, "You cannot cancel a request that starts in past! Ask for refund if the request is not responded.");
      require(!r.cancelled, "This request is already cancelled!");
      r.cancelled = true;
      payable(r.assetRenter).transfer(assets[r.assetID].rentPrice*(r.endTime-r.startTime));
    }

    function requestForNotResponded(uint requestID) public{
      RentalContractRequest memory r = rentalRequests[requestID];
      require(r.assetRenter == msg.sender, "Only the members who made the request can ask for refund!");
      require(!r.responded, "This request is already responded! You cannot cancel a responded request!");
      require(!r.cancelled, "This request already cancelled before the rental period! When cancelling the refund is made!");
      require(r.startTime < block.timestamp, "This request still has time to be responded! Ask for a cancel if you want to cancel!");
      require(!r.refunded, "The refund of this request is already been made!");
      r.refunded = true;
      payable(r.assetRenter).transfer(assets[r.assetID].rentPrice*(r.endTime-r.startTime));
    }
  
    function getRentalFee(uint rentalContractID) public{
      RentalContract memory r = rentalContracts[rentalContractID];
      require(ownerOf(r.assetID) == msg.sender, "Only the owner of the asset can ask for payment.");
      require(r.endTime <= block.timestamp, "You cannot get pait until the end of the contract!");
      require(!r.ownerPaid, "Owner is already paid for this contract!");
      r.ownerPaid = true;
      payable(ownerOf(r.assetID)).transfer(assets[r.assetID].rentPrice*(r.endTime-r.startTime));
    }

    // view functions

    function getNoOfMembers () public view returns(uint numMembers){
       numMembers = memberCount;
       return numMembers;
    }

    function getNoOfAssets () public view returns(uint numAssets){
       numAssets = assetCount;
       return numAssets;
    }

    function getNoOfRentalContracts () public view returns(uint numRentalContracts){
       numRentalContracts = rentalContractCount;
       return numRentalContracts;
    }
  
}
