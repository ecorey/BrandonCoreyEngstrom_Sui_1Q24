import { getFullnodeUrl, SuiClient } from "@mysten/sui.js/client";
import { Ed25519Keypair } from "@mysten/sui.js/keypairs/ed25519";
import { TransactionBlock } from "@mysten/sui.js/transactions";
import wallet from "./dev-wallet.json";

// generate a keypair
// Parse the privateKey string into an array of numbers
const privateKeyArray = wallet.privateKey.split(',').map( num => parseInt(num, 10));

// Convert the array of numbers into a Uint8Array
const privateKeyBytes = new Uint8Array(privateKeyArray);

// Create the keypair
const keypair = Ed25519Keypair.fromSecretKey(privateKeyBytes);


const client = new SuiClient({
    url: getFullnodeUrl('devnet'),
});


(async () => {
    try {

        //create Transaction Block.
        const txb = new TransactionBlock();
       


        // finalize
        let txid = await client.signAndExecuteTransactionBlock({ signer: keypair, transactionBlock: txb });
        console.log(`Success! Check our your TX here:
        https://suiexplorer.com/txblock/${txid.digest}?network=devnet`);

        
    } catch(e) {
        console.error(`Oops, something went wrong: ${e}`)
    }
})();

