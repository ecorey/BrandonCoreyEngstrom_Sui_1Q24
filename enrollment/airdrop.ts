import { Ed25519Keypair } from "@mysten/sui.js/keypairs/ed25519";
import { getFaucetHost, requestSuiFromFaucetV0 } from "@mysten/sui.js/faucet";
import wallet from "./dev-wallet.json";

// Parse the privateKey string into an array of numbers
const privateKeyArray = wallet.privateKey.split(',').map(num => parseInt(num, 10));

// Convert the array of numbers into a Uint8Array
const privateKeyBytes = new Uint8Array(privateKeyArray);

// Create the keypair
const keypair = Ed25519Keypair.fromSecretKey(privateKeyBytes);

(async () => {
    try {
        let res = await requestSuiFromFaucetV0({
            host: getFaucetHost("devnet"),
            recipient: keypair.toSuiAddress(),
        });
        console.log(`Success! Check out your TX here:
        https://suiscan.xyz/devnet/object/${res.transferredGasObjects[0].id}`);
    } catch(e) {
        console.error(`Oops, something went wrong: ${e}`);
    }
})();
