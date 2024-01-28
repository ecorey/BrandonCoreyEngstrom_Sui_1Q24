// #[test_only] 
// module bank::bank_tests {

//     use sui::sui::SUI;
//     use sui::transfer;
//     use sui::coin::{Self, Coin};
//     use sui::object::{Self, UID};
//     use sui::dynamic_field as df;
//     use sui::balance::{Self, Balance};
//     use sui::tx_context::{Self, TxContext};


//     use sui::test_utils::assert_eq;
//     use sui::coin::{mint_for_testing, burn_for_testing};
//     use sui::test_scenario::{Self, Scenario};
    
//     use bank::bank::{Self, BankStruct, init_for_testing};

     

    

    // #[test]
    // public fun init_for_testing(ctx: &mut TxContext) : test_scenario::Scenario {

       

    //     let admin: address = @0xBEEF;

    //     let alice: address = @0x1337;    

    //     let scenario_val = test_scenario::begin(admin);

    //     let scenario = &mut scenario_val;
        
    //     {
    //         test_scenario::init_for_testing(test_scenario::ctx(scenario));
    //     };
        
    //     scenario_val
    // }


    // #[test]
    // fun test_deposit() {
    //     let scenario_val = init_test_helper();
    //     let scenario = &mut scenario_val;

    //     deposit_test_helper(scenario, alice, 100, 5);

    //     test_scenario::end(scenario_val);
    // }


    // #[test]
    // fun deposit_test_helper(scenario: &mut test_scenario::Scenario, addr:address, amount:u64, fee_percent:u8) {
    //     test_scenario::next_tx(scenario, addr);
    //     {
    //     let bank = test_scenario::take_shared<Bank>(scenario);
    //     bank::deposit(&mut bank, mint_for_testing(amount, test_scenario::ctx(scenario)), test_scenario::ctx(scenario));

    //     let (user_amount, admin_amount) = calculate_fee_helper(amount, fee_percent);

    //     assert_eq(bank::user_balance(&bank, addr), user_amount);
    //     assert_eq(bank::admin_balance(&bank), admin_amount);
        
    //     test_scenario::return_shared(bank);
    //     };
    // }


   
    // #[expected_failure]
    // fun test_deposit_fail() {
    //     let scenario_val = init_test_helper();
    //     let scenario = &mut scenario_val;

    //     deposit_test_helper(scenario, alice, 100, 6);

    //     test_scenario::end(scenario_val);
    // }




// }
