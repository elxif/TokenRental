import {React, useState, useEffect} from 'react'
import {BigNumber, ethers} from 'ethers'
import styles from './Wallet.module.css'

const Interactions = (props) => {
    const [assetOwner, setAssetOwner] = useState(null);
    const [assetInfo, setAssetInfo] = useState(null);
    const [memberInfo, setMemberInfo] = useState(null);
    const [assetID, setAssetID] = useState(null);
    const [rentalContractID, setRentalContractID] = useState(null);
    const [requestID, setRequestID] = useState(null);
    const [requestInfo, setRequestInfo] = useState(null);
    const [contractInfo, setContractInfo] = useState(null);
    const [assetCount, setAssetCount] = useState(null);	
    const [memberCount, setMemberCount] = useState(null);	


    const Contract = props.contract;

    function parse(response) {
        return response["events"][0]["args"][2]["_hex"];
    }
    
    			
    const noOfAssetsViewer = async (e) => {	
        e.preventDefault();	
        let count_string = await props.contract.getNoOfAssets();	
        let count = Number(count_string);	
        setAssetCount(count);	
    }	
    	
    const noOfMembersViewer = async (e) => {	
        e.preventDefault();	
        let count_string = await props.contract.getNoOfMembers();	
        let count = Number(count_string);	
        setMemberCount(count);

    }

    const assetOwnerViewer = async (e) => {
        e.preventDefault();
        let id = e.target.assetID.value;
        id=parseInt(id);
        let tx = await props.contract.getAssetOwner(id);
        if(tx === "0x0000000000000000000000000000000000000000"){
            tx = "No such project!";
        }
        setAssetOwner(tx);
    }

    const assetInfoViewer = async (e) => {
        e.preventDefault();
        let id = e.target.assetID.value;
        id=parseInt(id);
        let tx = await props.contract.getAssetInfo(id);
        let assetName = tx[0];
        let assetowner = tx[1];
        let isRealEstate = tx[2];
        let latitude = parseInt(tx[3]);
        let longitude = parseInt(tx[4]);
        let rentable = parseInt(tx[5]);
        let rentPrice = Number(tx[6]);
        let info = "Asset Name: " + assetName + "\nAsset Owner: " + assetowner + (isRealEstate ? ("\nLatitude: " + latitude + " Longitude: " + longitude) : "") +
        (rentable ? "\nRentable" : "\nNot Rentable") + "\nPrice: " + rentPrice;

        setAssetInfo(info);
    }

    const createAssetHandler = async (e) => {
        e.preventDefault();
        let assetName = e.target.assetName.value;
        let isRealEstate = e.target.isRealEstate.value;
        let latitude = e.target.latitude.value;
        let longitude = e.target.longitude.value;
        let rentable = e.target.rentable.value;
        let rentPrice = e.target.rentPrice.value;

        let transactionResponse = await Contract.createAsset(assetName, isRealEstate, latitude, longitude, rentable, rentPrice);
        let transactionReceipt = await transactionResponse.wait(2);
        setAssetID(Number(parse(transactionReceipt)));
        //setAssetID(tx["logs"]);
    }


    //TODO: finish this
    const getRentalFeeHandler = async (e) => {
        e.preventDefault();
        let contractID = e.target.contractID.value;
        
    }

    const respondRentalContractRequest = async (e) => {
        e.preventDefault();
        let requestID = e.target.requestID.value;
        let approved = e.target.approved.value;
        let transactionResponse = await props.contract.respondRentalContractRequest(requestID, approved);
        let transactionReceipt = await transactionResponse.wait(2);
        setRentalContractID(Number(parse(transactionReceipt)));
        //setAssetID(tx["logs"]);
    }

    const GL = 550000;

    const rentalContractRequestmakerHandler = async (e) => {
        e.preventDefault();

        let assetID = e.target.r_assetID.value;
        let startTime = e.target.r_startTime.value;
        let endTime = e.target.r_endTime.value;
        let amount = e.target.r_amount.value;

        console.log(assetID, startTime, endTime, amount);
        let transactionResponse = await props.contract.makeRentalContractRequest(assetID, startTime, endTime,  {value:amount, gasLimit: GL});
        let transactionReceipt = await transactionResponse.wait(1);

        console.log(transactionResponse);
        console.log(transactionReceipt);


        console.log(transactionReceipt["events"][0]["args"][2]["_hex"]);
        let hex10 = Number(transactionReceipt["events"][0]["args"][2]["_hex"]);
        setRequestID(hex10);

    }

   

    const requestInfoViewer = async (e) => {
        e.preventDefault();
        let id = e.target.r_v_requestID.value;
        id=parseInt(id);
        let tx = await props.contract.getRequestInfo(id);
        let assetID = tx[0];
        let responded = tx[1];
        let assetRenter = tx[2];
        let startTime = parseInt(tx[3]);
        let endTime = parseInt(tx[4]);
        let rentalContractID = parseInt(tx[5]);
        let info = "Asset ID: " + assetID + ".\nAsset Renter: " + assetRenter + ".\n Responded ?" + (responded ? ".\n Yes it is Responded " : " Not Responded yet") 
        + ".\nStart Time: " + startTime + ".\n End Time" + "\n End Time" + endTime+ ".\n Rental Contract ID (if it is created it is greater than 0)" 
        + rentalContractID;

        setRequestInfo(info);
    }

    
	const rentalContractInfoViewer = async (e) => {
        e.preventDefault();
        let id = e.target.r_v_contractID.value;
        id=parseInt(id);
        let tx = await props.contract.getRentalContractInfo(id);
        let startTime = parseInt(tx[0]);
        let endTime = parseInt(tx[1]);
        let assetOwner = tx[2];
        let assetRenter = tx[3];
        let assetID = tx[4];
        
        let info = "Asset ID: " + assetID + ".\nAsset Renter: " + assetRenter + ".\nAsset Owner: " + assetOwner  
        + ".\nStart Time: " + startTime + ".\n End Time" + "\n End Time" + endTime;

        setContractInfo(info);
    }

    const rentalRequestCancellationHandler = async (e) => {
        e.preventDefault();
        let id = e.target.cancel_requestID.value;
        id=parseInt(id);
        let tx = await props.contract.cancelRequest(id);

        console.log(tx);

    }

    const askRefundNotRespondedRequest = async (e) => {
        e.preventDefault();
        let id = e.target.refund_requestID.value;
        id=parseInt(id);
        let tx = await props.contract.requestForNotResponded(id);

        console.log(tx);

    }

    const getApprovedRentalFee = async (e) => {
        e.preventDefault();
        let id = e.target.rentalfee_contractID.value;
        id=parseInt(id);
        let tx = await props.contract.getRentalFee(id);

        console.log(tx);

    }

    return(
        <div className={styles.interactionsCard}>

            <div className="column"></div>

            <form onSubmit={noOfMembersViewer}>	
                <a>Get number of members: </a>	
                <button type='submit'>✔</button>	
                <a>  {memberCount}</a>	
            </form>	
            <form onSubmit={noOfAssetsViewer}>	
                <a>Get number of assets: </a>	
                <button type='submit'>✔</button>	
                <a>  {assetCount}</a>	
            </form>

            <form onSubmit={assetOwnerViewer}>
                <p>Get asset owner by its id:</p>          
                <input type='number' id='assetID'/>
                <button type='submit'>✔</button> 
                <p><br></br> {assetOwner}</p>
            </form>

            <form onSubmit={assetInfoViewer}>
                <p>Get asset info by its id:</p>          
                <input type='number' id='assetID'/>
                <button type='submit'>✔</button> 
                <p><br></br>{assetInfo}</p>
            </form>

            <form onSubmit={createAssetHandler}>
                <h3>Submit Project Proposal:</h3>
                <a>Asset Name:</a>
                <input type='text' id='assetName'/>
                <a><br></br></a>
                <a>Is it Real estate ? true or false:</a>
                <input type='text' id='isRealEstate'/>
                <a><br></br></a>
                {/* bunlara uzerine gelince hint ekle virgulle ayrilacak diye */}
                <a>latitude:</a>
                <input type='text' id='latitude'/>
                <a><br></br></a>
                <a>longitude:</a>
                <input type='text' id='longitude'/>
                <a><br></br></a>
                <a>Is it rentable ? true or false:</a>
                <input type='text' id='rentable'/>
                <a><br></br></a>
                <a>Rent price per second in wei:</a>
                <input type='text' id='rentPrice'/>
                <a><br></br></a>
                <button type='submit' className={styles.button6}>Submit</button>
                {/* <a>  response**</a> */}
                <p><br></br> {assetID}</p>
            </form>

            <form onSubmit={respondRentalContractRequest}>
                <h3>Approve rental contract request by its request ID:</h3>          
                <input type='number' id='requestID'/>
                <br></br>
                <p>Do you approve? true or false:</p>
                <input type='text' id='approved'/>
                <button type='submit'>✔</button> 
                <p><br></br>{rentalContractID}</p>
            </form>


            <form onSubmit={rentalContractRequestmakerHandler}>
                <h3>Make a rental contract request !</h3>
                <p></p>          
                <a>Asset ID:</a>
                <input type='text' id='r_assetID'/>
                <a><br></br></a>
                <a>Start Time in unix time unit:</a>
                <input type='text' id='r_startTime'/>
                <a><br></br></a>
                <a>End Time in unix time unit:</a>
                <input type='text' id='r_endTime'/>
                <a><br></br></a>
                <a>Amount of wei you are paying:</a>
                <a><br></br></a>
                <a>Note: you should pay at least the rental priceper unit time * duration:</a>
                <input type='text' id='r_amount'/>
                <a><br></br></a>
                <button type='submit' className={styles.button6}>Submit</button>
                <a><br></br></a>
                <a>Request is sent! requestID: </a>
                <a>{requestID}</a>
                <a><br></br></a>
            </form>

            <form onSubmit={requestInfoViewer}>
                <h3>Get Request info by its id:</h3>
                <input type='number' id='r_v_requestID'/>
                <button type='submit'>✔</button> 
                <p><br></br>{requestInfo}</p>
                <a><br></br></a>
            </form>

            <form onSubmit={rentalContractInfoViewer}>
                <h3>Get Rental Contract info by its id:</h3>
                <input type='number' id='r_v_contractID'/>
                <button type='submit'>✔</button> 
                <p><br></br>{contractInfo}</p>
                <a><br></br></a>
            </form>


            <form onSubmit={rentalRequestCancellationHandler}>
                <h3>For Renters</h3>
                <h5>Cancel your non responded rental requests:</h5>
                <a3>Requestid: </a3>
                <input type='number' id='cancel_requestID'/>
                <button type='submit'>✔</button> 
                
                <a><br></br></a>
            </form>


            <form onSubmit={askRefundNotRespondedRequest}>
                <h3>For Renters</h3>
                <h5>Get your money back for requests </h5>
                <h5>that Is  not responded by the request start time :</h5>
                <a3>Request ID: </a3>
                <input type='number' id='refund_requestID'/>
                <button type='submit'>✔</button> 
                
                <a><br></br></a>
            </form>



            <form onSubmit={getApprovedRentalFee}>
                <h3>For Owners</h3>
                <h5>Get your rental fee after the rental period end time:</h5>
                <a3>Contract ID: </a3>
                <input type='number' id='rentalfee_contractID'/>
                <button type='submit'>✔</button> 
                <a><br></br></a>
                <a><br></br></a>
                <a><br></br></a>
            </form>






        </div>
    )
}

export default Interactions;