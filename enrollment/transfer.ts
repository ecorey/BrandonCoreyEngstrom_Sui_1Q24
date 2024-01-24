import { getFullnodeUrl, SuiClient } from "@mysten/sui.js/client";
import { Ed25519Keypair } from "@mysten/sui.js/keypairs/ed25519";
import { TransactionBlock } from '@mysten/sui.js/transactions';

import wallet from "./dev-wallet.json"



// Parse the privateKey string into an array of numbers
const privateKeyArray = wallet.privateKey.split(',').map(num => parseInt(num, 10));

// Convert the array of numbers into a Uint8Array
const privateKeyBytes = new Uint8Array(privateKeyArray);

// Create the keypair
const keypair = Ed25519Keypair.fromSecretKey(privateKeyBytes);


// Updated WBA SUI Address 
const to = "0xf0e708980e6c1c65405ddd75ebe57bba61fc9dfd91b4ad55cf88be8df26e5472";


//Create a Sui devnet client
const client = new SuiClient({ url: getFullnodeUrl("devnet")});


// sent 1000 mist to above address from dev-wallet
(async () => {
    try {
        //create Transaction Block.
        const txb = new TransactionBlock();
        //Split coins
        let [coin] = txb.splitCoins(txb.gas, [1000]);
        //Add a transferObject transaction
        txb.transferObjects([coin, txb.gas], to);
        let txid = await client.signAndExecuteTransactionBlock({ signer: keypair, transactionBlock: txb });
        console.log(`Success! Check our your TX here:
        https://suiexplorer.com/txblock/${txid.digest}?network=devnet`);
    } catch(e) {
        console.error(`Oops, something went wrong: ${e}`)
    }
})();



// get remaining devnet sui
(async () => {
    try {
        //create Transaction Block.
        const txb = new TransactionBlock();
        //Add a transferObject transaction
        txb.transferObjects([txb.gas], to);
        let txid = await client.signAndExecuteTransactionBlock({ signer: keypair, transactionBlock: txb });
        console.log(`Success! Check our your TX here:
        https://suiexplorer.com/txblock/${txid.digest}?network=devnet`);
    } catch(e) {
        console.error(`Oops, something went wrong: ${e}`)
    }
})();