// imports
import { getFullnodeUrl, SuiClient } from "@mysten/sui.js/client";
import { Ed25519Keypair } from "@mysten/sui.js/keypairs/ed25519";
import { TransactionBlock } from "@mysten/sui.js/transactions";
import wallet from "./dev-wallet.json";


// generate a keypair
const privateKeyArray = wallet.privateKey.split(',').map( num => parseInt(num, 10));
const privateKeyBytes = new Uint8Array(privateKeyArray);
const keypair = Ed25519Keypair.fromSecretKey(privateKeyBytes);




// client
const client = new SuiClient({
    url: getFullnodeUrl('devnet'),
});



// tx block
(async () => {
    try {

        // package object id
        const packageObjectId = '0x...';

        // create Transaction Block
        const txb = new TransactionBlock();

        // move call arguments
        let color = txb.pure("Some data", "String");
        let weight = txb.pure("50", "u32");
        
        txb.moveCall({
            target: `${packageObjectId}::nft::mint`,
            arguments:  [color, weight],
            typeArguments: []
        });


        // finalize 
        let txid = await client.signAndExecuteTransactionBlock({
            signer: keypair, 
            transactionBlock: txb,
        });
        console.log(`success: https://suiexplorer.com/txblock/${txid.digest}?network=devnet`);

    } catch(e) {
        console.error(`error: ${e}`)
    }
})();