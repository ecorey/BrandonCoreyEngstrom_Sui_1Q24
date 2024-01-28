module bank::bank {


  use sui::sui::SUI;
  use sui::transfer;
  use sui::coin::{Self, Coin};
  use sui::object::{Self, UID};
  use sui::dynamic_field as df;
  use sui::balance::{Self, Balance};
  use sui::tx_context::{Self, TxContext};

  

  struct BankStruct has key {
    id: UID
  }

  struct OwnerCap has key, store {
    id: UID
  }

  struct UserBalance has copy, drop, store { user: address }
  struct AdminBalance has copy, drop, store {}

  const FEE: u128 = 5;

  fun init(ctx: &mut TxContext) {
    let bank = BankStruct { id: object::new(ctx) };

    df::add(&mut bank.id, AdminBalance {}, balance::zero<SUI>());

    transfer::share_object(
      bank
    );

    transfer::transfer(OwnerCap { id: object::new(ctx) }, tx_context::sender(ctx));
  }
  
  public fun deposit(self: &mut BankStruct, token: Coin<SUI>, ctx: &mut TxContext) {
    let value = coin::value(&token);
    let deposit_value = value - (((value as u128) * FEE / 100) as u64);
    let admin_fee = value - deposit_value;

    let admin_coin = coin::split(&mut token, admin_fee, ctx);
    balance::join(df::borrow_mut<AdminBalance, Balance<SUI>>(&mut self.id, AdminBalance {}), coin::into_balance(admin_coin));

    let sender = tx_context::sender(ctx);

    if (df::exists_(&self.id, UserBalance { user: sender })) {
      balance::join(df::borrow_mut<UserBalance, Balance<SUI>>(&mut self.id, UserBalance { user: sender }), coin::into_balance(token));
    } else {
      df::add(&mut self.id, UserBalance { user: sender }, coin::into_balance(token));
    };
  }

  public fun withdraw(self: &mut BankStruct, ctx: &mut TxContext): Coin<SUI> {
    let sender = tx_context::sender(ctx);

    if (df::exists_(&self.id, UserBalance { user: sender })) {
      coin::from_balance(df::remove(&mut self.id, UserBalance { user: sender }), ctx)
    } else {
       coin::zero(ctx)
    }
  }

  public fun claim(_: &OwnerCap, self: &mut BankStruct, ctx: &mut TxContext): Coin<SUI> {
    let balance_mut = df::borrow_mut<AdminBalance, Balance<SUI>>(&mut self.id, AdminBalance {});
    let total_admin_bal = balance::value(balance_mut);
    coin::take(balance_mut, total_admin_bal, ctx)
  }    

     

  #[test_only]
    public fun init_for_testing(ctx: &mut TxContext) {
        init(ctx);
    }




}



#[test_only] 
module bank::bank_tests {

    use sui::sui::SUI;
    use sui::transfer;
    use sui::coin::{Self, Coin};
    use sui::object::{Self, UID};
    use sui::dynamic_field as df;
    use sui::balance::{Self, Balance};
    use sui::tx_context::{Self, TxContext};

    use sui::test_utils;
    use sui::test_scenario;
    
    
    use bank::bank::{Self, BankStruct, OwnerCap};

     

    

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




}
