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


// PATTERNS 
// CAPABILITIES

module prer::item_two {

    use sui::transfer;
    use sui::object::{Self, UID};
    use std::string::{Self, String};
    use sui::tx_context::{Self, TxContext};

    
    struct AdminCap has key { id: UID }

    struct Item has key, store { id: UID, name: String }

    fun init(ctx: &mut TxContext) {
        transfer::transfer(AdminCap {
            id: object::new(ctx)
        }, tx_context::sender(ctx))
    }

    public fun create_and_send(
            _: &AdminCap, name: vector<u8>, to: address, ctx: &mut TxContext
        ) {
            transfer::transfer(Item {
                id: object::new(ctx),
                name: string::utf8(name)
            }, to)
        }
}

// WITNESS
module prer::gaurdian {

    use sui::object::{Self, UID};
    use sui::tx_context::{Self, TxContext};

    struct Gaurdian<phantom T: drop> has key, store {
        id: UID,
    }

    public fun create_guardian<T: drop> (
        _witness: T, ctx: &mut TxContext
    ): Gaurdian<T> {
        Gaurdian { id: object::new(ctx) }
    }

}


module prer::peace_guardian {

    use sui::transfer;
    use sui::tx_context::{Self, TxContext};


    use prer::gaurdian;

    struct PEACE has drop {}

    
    fun init(ctx: &mut TxContext) {
        transfer::public_transfer(
            gaurdian::create_guardian(PEACE {}, ctx), tx_context::sender(ctx)
        )
    }

}



// STORABLE WITNESS

module prer::transferable_witness {

    use sui::transfer;
    use sui::object::{Self, UID};
    use sui::tx_context::{Self, TxContext};



    struct WITNESS has drop, store {}

    struct WitnessCarrier  has key { id: UID, witness: WITNESS}

    fun init(ctx: &mut TxContext) {
        transfer::transfer(
            WitnessCarrier { id: object::new(ctx), witness: WITNESS {} },
            tx_context::sender(ctx)
        )
    }


    public fun get_witness(carrier: WitnessCarrier): WITNESS {
        let WitnessCarrier { id, witness } = carrier;
        object::delete(id);
        witness
    }


}




// HOT POTATO

module prer::trade_in {


    use sui::transfer;
    use sui::sui::SUI;
    use sui::coin::{Self, Coin};
    use sui::object::{Self, UID};
    use sui::tx_context::{Self, TxContext};

    
    const MODEL_ONE_PRICE: u64 = 10000;


    const MODEL_TWO_PRICE: u64 = 20000;

    const EWrongModel: u64 = 1;

    const EIncorrectAmount: u64 = 2;



    struct Phone has key, store { id: UID, model: u8 }

    // hp
    struct Receipt { price: u64 }


    public fun buy_phone(model: u8, ctx: &mut TxContext): (Phone, Receipt) {
        assert!(model == 1 || model == 2, EWrongModel);

        let price = if (model == 1) MODEL_ONE_PRICE else MODEL_TWO_PRICE;

        (
            Phone { id: object::new(ctx), model },
            Receipt { price }
        )
    }


    public fun pay_full(receipt: Receipt, payment: Coin<SUI>) {
    
    let Receipt { price } = receipt;
    assert!(coin::value(&payment) == price, EIncorrectAmount);

    transfer::public_transfer(payment, @prer);
    }


    public fun trade_in(receipt: Receipt, old_phone: Phone, payment: Coin<SUI>) {
    let Receipt { price } = receipt;
    let tradein_price = if (old_phone.model == 1) {
        MODEL_ONE_PRICE
    } else {
        MODEL_TWO_PRICE
    };
    let to_pay = price - (tradein_price / 2);

    assert!(coin::value(&payment) == to_pay, EIncorrectAmount);

    transfer::public_transfer(old_phone, @prer);
    transfer::public_transfer(payment, @prer);
    }

}

module prer::lock_and_key {

    use sui::object::{Self, ID, UID};
    use sui::transfer;
    use sui::tx_context::{Self, TxContext};
    use std::option::{Self, Option};


    const ELockIsEmpty: u64 = 0;

    const EKeyMismatch: u64 = 1;


    const ELockIsFull: u64 = 2;


    struct Lock<T: store + key> has key {
        id: UID, 
        locked: Option<T>
    }



    struct Key<phantom T: store + key> has key, store {
        id: UID,
        for: ID
    }


    public fun key_for<T: store + key>(key: &Key<T>): ID {
        key.for
    }


    public fun create<T: store + key>(obj: T, ctx: &mut TxContext): Key<T> {
        let id = object::new(ctx);
        let for = object::uid_to_inner(&id);

        transfer::share_object(Lock<T> {
            id,
            locked: option::some(obj),
        });

        Key<T>{ id: object::new(ctx), for }
    }


    public fun lock<T: store + key> (
        obj: T,
        lock: &mut Lock<T>,
        key: &Key<T>,
    ) {
        assert!(option::is_none(&lock.locked), ELockIsFull);
        assert!(&key.for == object::borrow_id(lock), EKeyMismatch);

        option::fill(&mut lock.locked, obj);
    }


    public fun unlock<T: store + key> (
        lock: &mut Lock<T>,
        key: &Key<T>,
    ) : T {
        assert!(option::is_some(&lock.locked), ELockIsEmpty);
        assert!(&key.for == object::borrow_id(lock), EKeyMismatch);

        option::extract(&mut lock.locked)
    }

}



//NFT EXAMPLE

module prer::devnet_nft {

    use sui::url::{Self, Url};
    use std::string;
    use sui::object::{Self, UID, ID};
    use sui::event;
    use sui::transfer;
    use sui::tx_context::{Self, TxContext};




    struct DevNetNFT has key, store {

        id: UID,
        name: string::String,
        description: string::String,
        url: Url

    }


    struct NFTMinted has copy, drop {

        object_id: ID,
        creator: address,
        name: string::String,

    }



    public fun name( nft: &DevNetNFT ): &string::String {
        &nft.name
    }


    public fun description ( nft: &DevNetNFT ): &string::String {
        &nft.description
    }


    public fun url ( nft: &DevNetNFT ): &Url {
        &nft.url
    }

}

// ------------------------------------------------------------
// DISPLAY AND NFT MUSCLE MEMORY EXERCISES


module prer::muscle_memory {

    use sui::tx_context::{sender, TxContext};
    use std::string::{utf8, String};
    use sui::transfer;
    use sui::object::{Self, UID};

    // used together
    use sui::package;
    use sui::display;

    struct Cat has key, store {
        id: UID, 
        name: String, 
        img_url: String,

    }


    // OTW
    struct MUSCLE_MEMORY has drop {}


    fun init(otw: MUSCLE_MEMORY, ctx: &mut TxContext) {
        let keys = vector[
            utf8(b"name"),
            utf8(b"link"),
            utf8(b"image_url"),
            utf8(b"description"),
            utf8(b"project_url"),
            utf8(b"creator"),
        ];

        let values = vector[
            utf8(b"{name}"),
            utf8(b"https://sui-heroes.io/hero/{id}"),
            utf8(b"ipfs://{img_url}"),
            utf8(b"A true Hero of the Sui ecosystem!"),
            utf8(b"https://sui-heroes.io"),
            utf8(b"Unknown Sui Fan")
        ];

        let publisher = package::claim(otw, ctx);

        let display = display::new_with_fields<Cat>(
            &publisher, keys, values, ctx
        );

        display::update_version(&mut display);

        transfer::public_transfer(publisher, sender(ctx));
        transfer::public_transfer(display, sender(ctx));
    }


    public fun mint(name: String, img_url: String, ctx: &mut TxContext): Cat {
        let id = object::new(ctx);
        Cat {
            id, name, img_url
        }
    }


}



module prer::puppy {

    use std::string::String;
    use std::vector;
    use sui::tx_context::{Self, TxContext};
    use sui::object::{Self, ID, UID};
    use sui::event;


    struct Puppy has key, store {

        id: UID, 
        name: String, 
        traits: vector<String>,
        url: String,

    }

    // event
    struct PuppyMinted has copy, drop {
        puppy_id: ID, 
        minted_by: address,
    }



    public fun mint(
        name: String, 
        traits: vector<String>,
        url: String, 
        ctx: &mut TxContext
    ) : Puppy {
        let id = object::new(ctx);

        event::emit( PuppyMinted {
            puppy_id: object::uid_to_inner(&id),
            minted_by: tx_context::sender(ctx),
        });

        Puppy { id, name, traits, url }

    }



}





// DINO EGG

module prer::dino_nft {

    use sui::url::{Self, Url};
    use std::string;
    use std::option::{Self, Option};
    use sui::object::{Self, ID, UID};
    use sui::coin::{Self, Coin};
    use sui::balance::{Self, Balance};
    use sui::event;
    use sui::transfer;
    use sui::tx_context::{Self, TxContext};
    use sui::sui::SUI;



    const EWrongAmount: u64 = 0;


    struct DinoNFT has key, store {

        id: UID,
        description: string::String,
        url: Url,
        dino_egg: Option<ID>,

    }


    // mint capability
    struct MinterCap has key { id: UID }


    // event
    struct MinterNFTEvent has copy, drop {  
        object_id: ID, 
        creator: address, 
        name: string::String,
    }



    // shared object
    struct MintingTreasury has key {
        id: UID,
        balance: Balance<SUI>,
        mintingfee: u64,
    }



    fun init (ctx: &mut TxContext) {

        transfer::transfer( MinterCap {
            id: object::new(ctx)
        }, tx_context::sender(ctx));


        transfer::share_object(MintingTreasury {
            id: object::new(ctx),
            balance: balance::zero<SUI>(),
            mintingfee: 5000000
        })


    }





}
