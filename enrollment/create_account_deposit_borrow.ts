// imports
import { getFullnodeUrl, SuiClient } from "@mysten/sui.js/client";
import { Ed25519Keypair } from "@mysten/sui.js/keypairs/ed25519";
import { TransactionBlock } from "@mysten/sui.js/transactions";
import wallet from "./dev-wallet.json"; 

// generate a keypair
const privateKeyArray = wallet.privateKey.split(',').map(num => parseInt(num, 10));
const privateKeyBytes = new Uint8Array(privateKeyArray);
const keypair = Ed25519Keypair.fromSecretKey(privateKeyBytes);

// client
const client = new SuiClient({
    url: getFullnodeUrl('testnet'),
});

// package object id for bank and lending
const packageObjectId = '0x40bff03fc40cfda9659f37f0d1902154e5822352c5b9c84dcfe02151cc71ba15';

// tx block
(async () => {
    try {
        // deposit and borrow amounts
        const depositAmount = 1000; 
        const borrowAmount = 500; 
        
        // create Transaction Block
        const txb = new TransactionBlock();

        // Create new account
        txb.moveCall({
            target: `${packageObjectId}::bank::new_account`,
            arguments: [], // Add necessary arguments
            typeArguments: [] // Add necessary type arguments
        });

        // Deposit funds to the account
        txb.moveCall({
            target: `${packageObjectId}::bank::deposit`,
            arguments: [],
            typeArguments: [] 
        });

        // Borrow funds from the account using lending contract
        txb.moveCall({
            target: `${packageObjectId}::lending::borrow`,
            arguments: [],
            typeArguments: [] 
        });

        // finalize
        let txid = await client.signAndExecuteTransactionBlock({
            signer: keypair,
            transactionBlock: txb,
        });

        console.log(`Transaction result: ${JSON.stringify(txid, null, 2)}`);
        console.log(`success: https://suiexplorer.com/txblock/${txid.digest}?network=testnet`);

    } catch (e) {
        console.error(`error: ${e}`);
    }
})();
