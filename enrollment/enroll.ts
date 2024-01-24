import { getFullnodeUrl, SuiClient } from "@mysten/sui.js/client";
import { Ed25519Keypair } from "@mysten/sui.js/keypairs/ed25519";
import { bcs} from "@mysten/sui.js/bcs";
import { TransactionBlock } from '@mysten/sui.js/transactions';
import wallet from "./dev-wallet.json"

const enrollment_object_id = "0x5927f2574f0a5e2afa574e24bca462269d31cf29bdd2215d908b90b691ea5747";
const cohort = "0xa85910892fca1bedde91ec6a1379bcf71f4106adbe390ccd67fb696c802d99ab";


// Parse the privateKey string into an array of numbers
const privateKeyArray = wallet.privateKey.split(',').map(num => parseInt(num, 10));

// Convert the array of numbers into a Uint8Array
const privateKeyBytes = new Uint8Array(privateKeyArray);

// Create the keypair
const keypair = Ed25519Keypair.fromSecretKey(privateKeyBytes);

// Create a devnet client
const client = new SuiClient({ url: getFullnodeUrl("devnet") });

// Create a testnet client
// const client = new SuiClient({ url: getFullnodeUrl("testnet") });

const txb = new TransactionBlock();


// Github account
const github = new Uint8Array(Buffer.from("ecorey"));
let serialized_github = txb.pure(bcs.vector(bcs.u8()).serialize(github));



let enroll = txb.moveCall({
    target: `${enrollment_object_id}::enrollment::enroll`,
    arguments: [txb.object(cohort), serialized_github],
});



// MOVE FUNCTION BEING CALLED:
// public entry fun enroll(cohort: &mut Cohort, github: vector<u8>, ctx: &mut TxContext) {
//     internal_enroll(cohort, &github, ctx);
//     let name = from_ascii(ascii::string(github));
//     let cadet = Cadet {
//          id: object::new(ctx),
//          github:name,
//          cohort: object::id(cohort),
//     };

//     event::emit(CadetEvent {
//         id: object::id(&cadet),
//         github:name,
//         cohort: object::id(cohort)
//     });