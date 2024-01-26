module bank::bank_tests {
    // use sui::test_utils::assert_eq;
    // use sui::coin::{mint_for_testing, burn_for_testing};
    
     

    #[test_only] use sui::test_scenario as ts;

    #[test]
    public fun init_for_testing(ctx: &mut TxContext) : ts::Scenario {

        use bank::bank::{Self, Bank};

        let ADMIN: address = @0xBEEF;

        let ALICE: address = @0x1337;    

        let scenario_val = ts::begin(ADMIN);

        let scenario = &mut scenario_val;
        
        {
            init_for_testing(ts::ctx(scenario));
        };
        
        scenario_val
    }
}
