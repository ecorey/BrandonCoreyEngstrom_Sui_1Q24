module bank::bank{

    use sui::object::{Self, UID};
    use sui::tx_context::{Self, TxContext};

    use sui::sui::SUI;
    use sui::coin::{Self, Coin};

    use sui::dynamic_field as df;
    use sui::transfer;
    use sui::balance::{Self, Balance};


    struct Bank has key {
        id: UID,
    }

    struct OwnerCap has key, store {
        id: UID,
    }

    struct UserBalance has copy, drop, store { user: address }
    struct AdminBalance has copy, drop, store {  }




    const FEE: u128 = 5;


    fun init(ctx: &mut TxContext) {
        let bank = Bank { id: object::new(ctx)};
        df::add(&mut bank.id, AdminBalance { user: balance::zero<SUI>() });

        transfer::shared_object(bank);

        let ownercap = OwnerCap { id: object::new(ctx)};

        transfer::transfer(ownercap, tx_context::sender(ctx));
        
    }


    public fun deposit( self: &mut Bank, token: Coin<SUI>, ctx: &mut TxContext) {

        let deposit_val = coin::value(&token);
        let admin_fee = (((deposit_val as u128) * FEE / 100) as u64);
        let deposit_val = deposit_val - admin_fee;


        let value = df::borrow_mut<AdminBalance, Balance<SUI>>{
            &mut self.id, 
            AdminBalance{}
        };

        // split coin
        let admin_coin = coin::split<SUI>{( &mut token , admin_fee, ctx) };

    

        let admin_balance = coin::into_balance(admin_coin);

        balance::join(value, admin_balance);

        let _exists = df::exists_(&self.id, UserBalance{ tx_context::sender(ctx) }); 


        if (_exists) {
            let user_balance = coin::into_balance(token);
            let user_value = df::borrow_mut<UserBalance, Balance<SUI>>(
                &mut self.id, 
                UserBalance{}
            ) 
        } else {

        }


    }



    // same logic opposite as above
    // public fun withdraw(self: &mut Bank, ctx: &mut TxContext) : Coin<SUI> {
            
            
    // }





    // public fun claim(_: &OwnerCap, self: &mut Bank, ctx: &mut TxContext) : Coin<SUI> {


    // }




}