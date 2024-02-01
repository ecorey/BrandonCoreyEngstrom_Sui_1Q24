import { getFullnodeUrl, SuiClient } from "@mysten/sui.js/client";
import { Ed25519Keypair } from "@mysten/sui.js/keypairs/ed25519";
import { TransactionBlock } from "@mysten/sui.js/transactions";

// generate a new Ed25519 keypair
const keypair = new Ed25519Keypair();

const client = new SuiClient({
    url: getFullnodeUrl('testnet'),
});

// ptb
const tx = new TransactionBlock();


// tx
tx.transferObjects(
    [ "0x0000000"],
    "0x0000000",
);

// const result = await client.signAndExecuteTransactionBlock({
//     signer: keypair,
//     transactionBlock: tx,
// });
    

// console.log({result});