module prer::pre_r {

    use sui::transfer;
    use sui::tx_context::TxContext;
    use sui::object::{Self, UID};
    
    
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

    
}

module prer::object_example {

    use sui::transfer;
    use sui::sui::SUI;
    use sui::coin::{Self, Coin};
    use sui::object::{Self, UID};
    use sui::balance::{Self, Balance};
    use sui::tx_context::{Self, TxContext};

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
        // transfer::share_object(ExampleObjectShop {
        //     id: object::new(ctx),
        //     price: 1000,
        //     balance: balance::zero()
        // })
    }

    public fun buy_example_object (
        shop: &mut ExampleObjectShop, payment: &mut Coin<SUI>, ctx: &mut TxContext    
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



module prer::wrapper {

    use sui::object::{Self, UID};
    use sui::tx_context::TxContext;

    struct Wrapper<T: store> has key, store {
        id: UID, 
        contents: T
    }


    public fun contents<T: store>(c: &Wrapper<T>) : &T {
        &c.contents
    }


    public fun create<T: store> (
        contents: T, ctx: &mut TxContext
    ) : Wrapper<T> {
            Wrapper {
                contents, 
                id: object::new(ctx),
            }
    }


    public fun destroy<T: store> (c: Wrapper<T>) : T {
        let Wrapper { id, contents } = c;
        object::delete(id);
        contents
    }
    
}



module prer::profile {
    use sui::url::{Self, Url};
    use std::string::{Self, String};
    use sui::tx_context::TxContext;


    use prer::wrapper::{Self, Wrapper};


    struct ProfileInfo has store {
        name: String, 
        url: Url
    }


    public fun name(info: &ProfileInfo) : &String {
        &info.name
    }

    public fun url(info: &ProfileInfo) : &Url {
        &info.url
    }


    public fun create_profile(
        name: vector<u8>, url: vector<u8>, ctx: &mut TxContext
    ) : Wrapper<ProfileInfo> {

        let container = wrapper::create(ProfileInfo {
            name: string::utf8(name),
            url: url::new_unsafe_from_bytes(url)
        }, ctx);

        container
    }
    
}


module prer::restricted_transfer {

    use sui::tx_context::{Self, TxContext};
    use sui::balance::{Self, Balance};
    use sui::coin::{Self, Coin};
    use sui::object::{Self, UID};
    use sui::transfer;
    use sui::sui::SUI;


    const EWrongAmount: u64 = 0;


    struct GovernmentCapability has key { id: UID }


    struct TitleDeed has key {
        id: UID,
    }

    struct LandRegistry has key {
        id: UID,
        balance: Balance<SUI>,
        fee: u64   
    }


    fun init(ctx: &mut TxContext) {

        transfer::transfer(GovernmentCapability {
            id: object::new(ctx)
        }, tx_context::sender(ctx));

        transfer::share_object( LandRegistry {
            id: object::new(ctx),
            balance: balance::zero<SUI>(),
            fee: 10000
        })

    }


    public fun issue_title_deed(
        _: &GovernmentCapability,
        for: address, 
        ctx: &mut TxContext
    ) {
        transfer::transfer( TitleDeed {
            id: object::new(ctx)
        }, for)
    }

    public fun transfer_ownership (
        registry: &mut LandRegistry,
        paper: TitleDeed,
        fee: Coin<SUI>,
        to: address
    ) {

        assert!(coin::value(&fee) == registry.fee, EWrongAmount);

        balance::join(&mut registry.balance, coin::into_balance(fee));

        transfer::transfer(paper, to)

    }

}



//EVENTS
module prer::objects_with_events {

    use sui::transfer;
    use sui::sui::SUI;
    use sui::coin::{Self, Coin};
    use sui::object::{Self, ID, UID};
    use sui::balance::{Self, Balance};
    use sui::tx_context::{Self, TxContext};

    use sui::event;
    

    const ENotEnough: u64 = 0;

    struct StoreOwnerCap has key { id: UID }

    struct ExampleObject has key { id: UID }

    struct Store has key {
        id: UID, 
        price: u64, 
        balance: Balance<SUI>
    }


    struct ObjectBought has copy, drop {
        id: ID
    }


    struct ProfitsCollected has copy, drop {
        amount: u64
    }


    fun init(ctx: &mut TxContext) {

        transfer::transfer(StoreOwnerCap {
            id: object::new(ctx),
        }, tx_context::sender(ctx));

        transfer::share_object(Store {
            id: object::new(ctx),
            price: 1000,
            balance: balance::zero()
        })

    }



    public fun buy_example_object(
        shop: &mut Store, payment: &mut Coin<SUI>, ctx: &mut TxContext
    ) {
        assert!(coin::value(payment) >= shop.price, ENotEnough);

        let coin_balance = coin::balance_mut(payment);
        let paid = balance::split(coin_balance, shop.price);
        let id = object::new(ctx);

        balance::join(&mut shop.balance, paid);

        event::emit(ObjectBought { id: object::uid_to_inner(&id) });
        transfer::transfer(ExampleObject {id}, tx_context::sender(ctx))

    }


    public fun destroy_object(o: ExampleObject) {
        let ExampleObject { id } = o;
        object::delete(id);
    }


    public fun collect_profits (
        _: &StoreOwnerCap, shop: &mut Store, ctx: &mut TxContext
    ) : Coin<SUI> {

        let amount = balance::value(&shop.balance);

        event::emit(ProfitsCollected { amount });
        coin::take(&mut shop.balance, amount, ctx)
    }

}





// OTW
module prer::one_time_witness_registry {

    use sui::tx_context::TxContext;
    use sui::object::{Self, UID};
    use std::string::String;
    use sui::transfer;

    use sui::types;

    const ENotOneTimeWitness: u64 = 0;



    struct UniqueTypeError<phantom T> has key {
        id: UID,
        name: String
    }


    // public fun add_record<T: drop>(
    //     witness: T,
    //     name: String, 
    //     ctx: &mut TxContext
    // ) {
    //     assert!(types::is_one_time_witness(&witness), ENotEnough);

    //     transfer::share_object(UniqueTypeRecord<T> {
    //         id: object::new(ctx),
    //         name
    //     });
    // }

}



// module prer::my_otw {

//     use std::string;
//     use sui::tx_context::TxContext;
//     use examples::one_time_witness_registry as registry;


//     struct MY_OTW has drop {}


//     fun init(witness: MY_OTW, ctx: &mut TxContext) {
//         registry::add_record (
//             witness,
//             string::utf8(b"My Record"),
//             ctx
//         )
//     }

// }



// DISPLAY
module prer::my_hero {

    use sui::tx_context::{sender, TxContext};
    use std::string::{utf8, String};
    use sui::transfer;
    use sui::object::{Self, UID};



    use sui::package;
    use sui::display;


    struct Hero has key, store {
        id: UID,
        name: String,
        img_url: String
    }


    struct MY_HERO has drop {}


    fun init(otw: MY_HERO, ctx: &mut TxContext) {
        let keys = vector[
            utf8(b"name"),
            utf8(b"link"),
            utf8(b"image_url"),
            utf8(b"description"),
            utf8(b"project_url"),
            utf8(b"creatpr"),
        ];


        let values = vector [
            utf8(b"{name}"),
            utf8(b"https://something.io/hero/{id}"),
            utf8(b"ipfs://{img_url}"),
            utf8(b"A true Hero of the Sui Bootcamp!"),
            utf8(b"https://something.io"),
            utf8(b"John Sui")
        ];


        let publisher = package::claim(otw, ctx);

        let display = display::new_with_fields<Hero>(
            &publisher, keys, values, ctx
        );

        display::update_version(&mut display);


        transfer::public_transfer(publisher, sender(ctx));
        transfer::public_transfer(display, sender(ctx));

    }


    public fun mint(name: String, img_url: String, ctx: &mut TxContext ) : Hero {
        let id = object::new(ctx);
        Hero { id, name, img_url }
    }

    }




// CAPABILITY
module prer::item {

    use sui::transfer;
    use sui::object::{Self, UID};
    use std::string::{Self, String};
    use sui::tx_context::{Self, TxContext};


    struct Admincap has key { id: UID }

    struct Item has key, store { id: UID, name: String}


    fun init(ctx: &mut TxContext ) {
        transfer::transfer( Admincap {
            id: object::new(ctx)
        }, tx_context::sender(ctx))
    }


    public fun create_and_send (
        _: &Admincap, name: vector<u8>, to: address, ctx: &mut TxContext
    ) {
        transfer::transfer(  Item {
            id: object::new(ctx),
            name: string::utf8(name)
        }, to)
    }

}








