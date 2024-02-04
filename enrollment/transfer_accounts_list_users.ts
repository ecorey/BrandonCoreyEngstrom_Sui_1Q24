// imports
import { getFullnodeUrl, SuiClient } from "@mysten/sui.js/client";
import { Ed25519Keypair } from "@mysten/sui.js/keypairs/ed25519";
import { TransactionBlock } from "@mysten/sui.js/transactions";
import wallet from "./dev-wallet.json"; 

// generate a keypair
const privateKeyArray = wallet.privateKey.split(',').map(num => parseInt(num, 10));
const privateKeyBytes = new Uint8Array(privateKeyArray);
const keypair = Ed25519Keypair.fromSecretKey(privateKeyBytes);

// client for testnet
const client = new SuiClient({
    url: getFullnodeUrl('testnet'),
});

// Users data - created for task
const users = [
    { publicKey: 'user1PublicKey', otherDetails: '...' },
    { publicKey: 'user2PublicKey', otherDetails: '...' },
    
];

// tx block
(async () => {
    try {
        // package object id for bank
        const packageObjectId = '0x40bff03fc40cfda9659f37f0d1902154e5822352c5b9c84dcfe02151cc71ba15';

        for (const user of users) {
            
            // create Transaction Block
            const txb = new TransactionBlock();

            // Create new account
            txb.moveCall({
                target: `${packageObjectId}::bank::new_account`,
                arguments: [],
                typeArguments: []
            });

            // Transfer objects / funds to the new account - Modify as per your transfer logic
            // txb.transferObjects([coin], user.publicKey);

            // finalize 
            let txid = await client.signAndExecuteTransactionBlock({
                signer: keypair,
                transactionBlock: txb,
            });

            console.log(`Transaction result for user ${user.publicKey}: ${JSON.stringify(txid, null, 2)}`);
            console.log(`success: https://suiexplorer.com/txblock/${txid.digest}?network=testnet`);
        }
    } catch (e) {
        console.error(`error: ${e}`);
    }
})();
