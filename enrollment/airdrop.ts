import { Ed25519Keypair } from "@mysten/sui.js/keypairs/ed25519";
import { getFaucetHost, requestSuiFromFaucetV0 } from "@mysten/sui.js/faucet";
import { fromHEX } from "@mysten/sui.js/utils";

import wallet from "./dev-wallet.json"


// Convert the hex string to a Uint8Array
const privateKeyBytes = fromHEX(wallet.privateKey);

// We're going to import our keypair from the wallet file
const keypair = Ed25519Keypair.fromSecretKey(new Uint8Array(privateKeyBytes));

(async () => {
    try {
        let res = await requestSuiFromFaucetV0({
            host: getFaucetHost("devnet"),
            recipient: keypair.toSuiAddress(),
          });
          console.log(`Success! Check our your TX here:
          https://suiscan.xyz/devnet/object/${res.transferredGasObjects[0].id}`);
    } catch(e) {
        console.error(`Oops, something went wrong: ${e}`)
    }
})();