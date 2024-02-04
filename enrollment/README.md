**All DEVNET**
**Note Secure for Learning Only, Never expose PK**

# keygen:

    You've generated a new Sui wallet: 0xb3d4cb714181fec39c22d820c963da9cfac970d3ab77c464b0dea06ce673c3e5

    To save your wallet, copy and paste the following into a JSON file:

    [205,135,82,122,92,191,230,26,186,193,84,37,231,224,134,137,88,91,210,10,145,131,234,192,175,104,252,61,220,0,124,86]


    You can use the below HEX to import the key into a web wallet:

    cd87527a5cbfe61abac15425e7e08689585bd20a9183eac0af68fc3ddc007c56

# airdrop:

    Success! Check out your TX here:
            https://suiscan.xyz/devnet/object/0xe549b151fa8e5230c015fd7e46c6d8beb11de90a729e77a4cbba4d045dbcb7d5


![airdrop](./airdrop.png)


# transfer:

    Success! Check our your TX here:
        https://suiexplorer.com/txblock/GfNGEGQ3dfRgTQpKrfnvsohj4B58PUtffGHYKxB3whMw?network=devnet
    Oops, something went wrong: Error: Failed to sign transaction by a quorum of validators because of locked objects. Retried a conflicting transaction Some(TransactionDigest(GfNGEGQ3dfRgTQpKrfnvsohj4B58PUtffGHYKxB3whMw)), success: Some(true)


![transfer](./transfer.png)



# enrolled:

![enrolled success](./enroll.png)


---


to switch between devnet and testnet on cli

sui client envs
sui client switch --env testnet
sui client active-env




sui client publish --gas-budget 10000000 /home/ub/SUI_PROJECTS/WBA-SUI/enrollment/bank  --skip-dependency-verification

sui client account-info 0x9d08a49d57a2e21fc154d2ddb7fce524b3c598bf5c3f3a7b4bc9dd06a886e640


Published Bank Objects:                                                                                                                  │
│  ┌──                                                                                                                                │
│  │ PackageID: 0x40bff03fc40cfda9659f37f0d1902154e5822352c5b9c84dcfe02151cc71ba15                                                    │
│  │ Version: 1                                                                                                                       │
│  │ Digest: GfLonG9g7DBmGPjbUmmrwo3Nq5FZJ3mvgrWdNDFDnseD                                                                             │
│  │ Modules: amm, bank, lending, oracle, sui_dollar                                                                                                       