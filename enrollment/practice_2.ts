import { getFullnodeUrl, SuiClient } from "@mysten/sui.js/client";

const client = new SuiClient({url: getFullnodeUrl('testnet')});

(async () => {
    await client.getCoins({owner: "0xf0e708980e6c1c65405ddd75ebe57bba61fc9dfd91b4ad55cf88be8df26e5472"});
})();
