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


//   fun init(ctx: &mut TxContext) {
//         transfer::transfer(ExampleObjectCap {
//             id: object::new(ctx)
//         }, tx_context::sender(ctx));

//         // Share the object 
//         transfer::share_object(ExampleObjectShop {
//             id: object::new(ctx),
//             price: 1000,
//             balance: balance::zero()
//         })
//     }








}