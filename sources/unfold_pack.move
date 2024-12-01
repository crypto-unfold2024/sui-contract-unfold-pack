/// This module illustrates a Closed Loop unfold_pack Token. The `Token` is sent to
/// users as a reward for their loyalty by the application Admin. The `Token`
/// can be used to redeem a gift (e.g., Swiggy, Ola, Uber coupon) in the shop.
///
/// Actions:
/// - spend - spend the token in the shop
module unfold_pack::loyalty;

use sui::{coin::{Self, TreasuryCap}, random::{Random}, token::{Self, ActionRequest, Token}};
use sui::url;

/// Price for a gift
const GIFT_PRICE: u64 = 10;

/// Gift Types (e.g., Swiggy, Ola, Uber coupons)
public enum GiftType has copy, drop, store {
    SwiggyCoupon,
    OlaCoupon,
    UberCoupon,
}

/// The Gift object - can be redeemed for tokens.
public struct Gift has key, store {
    id: UID,
    gift_type: GiftType, // Type of the gift
}

/// Token amount does not match the `GIFT_PRICE`.
const EIncorrectAmount: u64 = 0;

/// The OTW for the Token / Coin.
public struct LOYALTY has drop {}

/// This is the Rule requirement for the `GiftShop`. The Rules don't need
/// to be separate applications, some rules make sense to be part of the
/// application itself, like this one.
public struct GiftShop has drop {}

/// Determine the gift type based on a random number.
fun determine_gift_type(random_number: u32): GiftType {
    match (random_number) {
        0 => GiftType::SwiggyCoupon,
        1 => GiftType::OlaCoupon,
        2 => GiftType::UberCoupon,
        _ => GiftType::SwiggyCoupon, 
    }
}

/// Initialize the loyalty token and set up the shop.
fun init(otw: LOYALTY, ctx: &mut TxContext) {
    let (treasury_cap, coin_metadata) = coin::create_currency(
        otw,
        0, // no decimals
        b"UCDCX", // symbol
        b"unfold_pack Token", // name
        b"Loyalty Pack for UNFOLD 2024", // description
        option::some(url::new_unsafe_from_bytes(b"https://violet-gentle-cow-510.mypinata.cloud/ipfs/QmdFHqPUoLR3BvZDkjwne9dFYXThFYK221yHfaAYc8Zeix")),
        ctx,
    );

    let (mut policy, policy_cap) = token::new_policy(&treasury_cap, ctx);

    // Constrain spend by this shop:
    token::add_rule_for_action<LOYALTY, GiftShop>(
        &mut policy,
        &policy_cap,
        token::spend_action(),
        ctx,
    );

    token::share_policy(policy);

    transfer::public_freeze_object(coin_metadata);
    transfer::public_transfer(policy_cap, tx_context::sender(ctx));
    transfer::public_transfer(treasury_cap, tx_context::sender(ctx));
}

/// Reward users with loyalty tokens. This function is intended for admin use.
public fun reward_user(
    cap: &mut TreasuryCap<LOYALTY>,
    amount: u64,
    recipient: address,
    ctx: &mut TxContext,
) {
    let token = token::mint(cap, amount, ctx);
    let req = token::transfer(token, recipient, ctx);
    token::confirm_with_treasury_cap(cap, req, ctx);
}

/// Private helper function to generate a random number using `sui::random`.
fun generate_random_number(r: &Random, ctx: &mut TxContext): u32 {
    // Create a RandomGenerator
    let mut generator = sui::random::new_generator(r, ctx);
    // Generate a random number in the range [0, 3)
    generator.generate_u32_in_range(0, 3)
}
#[allow(lint(public_random))]
public fun redeem_unfold_pack(
    token: Token<LOYALTY>,
    r: &Random, // Pass Random as a parameter
    ctx: &mut TxContext,
): (Gift, ActionRequest<LOYALTY>) {
    // Validate the token amount
    assert!(token::value(&token) == GIFT_PRICE, EIncorrectAmount);

    // Generate a random number for the gift type
    let random_number = generate_random_number(r, ctx);

    // Determine the gift type
    let gift_type = determine_gift_type(random_number);

    // Create the gift with the determined type
    let gift = Gift {
        id: object::new(ctx),
        gift_type,
    };

    // Burn the loyalty token by creating a spending request
    let mut req = token::spend(token, ctx);

    // Add approval because of the set rule
    token::add_approval(GiftShop {}, &mut req, ctx);

    // Return the gift and the action request
    (gift, req)
}





