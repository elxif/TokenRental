import {React, useState, useEffect} from 'react'
import {BigNumber, ethers} from 'ethers'
import styles from './Wallet.module.css'

const Interactions = (props) => {
    const [assetOwner, setAssetOwner] = useState(null);


    const assetViewer = async (e) => {
        e.preventDefault();
        let id = e.target.assetID.value;
        //id=parseInt(id);
        console.log("assetID: " + id);
        let contractCode = props.contract.provider.getCode(props.contract.contractAddress);
        console.log(contractCode);
        let tx = await props.contract.getAssetOwner(id);
        console.log(tx);
        if(tx === "0x0000000000000000000000000000000000000000"){
            tx = "No such project!";
        }
        setAssetOwner(tx);
    }

    return(
        <div className={styles.interactionsCard}>

            <div class="column"></div>

            <form onSubmit={assetViewer}>
                <p>Get asset owner by its id:</p>          
                <input type='number' id='assetID'/>
                <button type='submit' className={styles.button6}>✔</button> 
                <p><br></br> {assetOwner}</p>
            </form>
        </div>
    )
}

export default Interactions;