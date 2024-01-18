module prer::pre_r {

    use sui::transfer;
    use sui::tx_context::TxContext;
    use sui::object::{Self, UID};
    use sui::sui::SUI;
    use sui::coin::{Self, Coin};
    use sui::balance::{Self, Balance};
    

    struct ExampleObject has key { 
        id: UID
    }

    // non-entry create function
    public fun create(ctx: &mut TxContext): ExampleObject {
        ExampleObject { id: object::new(ctx) }
    }

    // entry create and transfer
    entry fun create_and_transfer(to: address, ctx: &mut TxContext) {
        transfer::transfer(create(ctx), to)
    }

    // SHARED OBJECT EXAMPLE
    const ENotEnough: u64 = 0;

    struct ExampleObjectCap has key { id: UID }

    struct ExampleObjectShop has key {

        id: UID,
        price: u64,
        balance: Balance<SUI>

    }


  fun init(ctx: &mut TxContext) {
        transfer::transfer(ExampleObjectCap {
            id: object::new(ctx)
        }, tx_context::sender(ctx));

        // Share the object 
        transfer::share_object(ExampleObjectShop {
            id: object::new(ctx),
            price: 1000,
            balance: balance::zero()
        })
    }

    public fun buy_example_object (
        shop: &mut ExampleObjectShop, payment: &mut COIN<SUI>, ctx: &mut TxContext    
    ) {
        assert!(coin::value(payment) >= shop.price, ENotEnough);

        let coin_balance = coin::balance_mut(payment);
        let paid = balance::split(coin_balance, shop.price);

        balance::join(&mut shop.balance, paid);

        transfer::transfer(ExampleObject {
            id: object::new(ctx)
        }, tx_context::sender(ctx))
    }

    // deconstruct and delete object
    public fun delete_example_object(e: ExampleObject) {
        let ExampleObject { id } = e;
        object::delete(id);
    }


    public fun collect_profits (
        _: &ExampleObjectCap, shop: &mut ExampleObjectShop, ctx: &mut TxContext
    ) : Coin<SUI> {

        let amount = balance::value(&shop.balance);
        coin::take(&mut shop.balance, amount, ctx)

    }





}