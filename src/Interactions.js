import {React, useState, useEffect} from 'react'
import {BigNumber, ethers} from 'ethers'
import styles from './Wallet.module.css'

const Interactions = (props) => {
    const [assetOwner, setAssetOwner] = useState(null);
    const [assetInfo, setAssetInfo] = useState(null);
    const [memberInfo, setMemberInfo] = useState(null);
    const [assetID, setAssetID] = useState(null);


    const assetOwnerViewer = async (e) => {
        e.preventDefault();
        let id = e.target.assetID.value;
        id=parseInt(id);
        console.log("assetID: " + id);
        let tx = await props.contract.getAssetOwner(id);
        console.log(tx);
        if(tx === "0x0000000000000000000000000000000000000000"){
            tx = "No such project!";
        }
        setAssetOwner(tx);
    }

    const assetInfoViewer = async (e) => {
        e.preventDefault();
        let id = e.target.assetID.value;
        id=parseInt(id);
        console.log("assetID: " + id);
        let tx = await props.contract.getAssetInfo(id);
        let assetName = tx[0];
        //ownerOf(assetID), a.isRealEstate, a.latitude, a.longitude, a.rentable, a.rentPrice)
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

        console.log(assetName, isRealEstate, latitude, longitude, rentable, rentPrice);
        let tx = await props.contract.createAsset(assetName, isRealEstate, latitude, longitude, rentable, rentPrice);
        console.log(tx);
        
        setAssetID(tx["logs"]);
    }
	



    return(
        <div className={styles.interactionsCard}>

            <div className="column"></div>

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



        </div>
    )
}

export default Interactions;