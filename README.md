# Unfold Pack Loyalty Contract

This Move module (`unfold_pack::loyalty`) implements a loyalty program using `LOYALTY` tokens on the Sui blockchain. The tokens are awarded by the application admin and can be redeemed by users for gifts like Swiggy, Ola, or Uber coupons.

## Features

### 1. **LOYALTY Token**
- The `LOYALTY` token is minted by the admin to reward user loyalty.
- Symbol: `UCDCX`, Description: "Loyalty Pack for UNFOLD 2024".
- Includes a 3D asset attached as metadata, stored on IPFS.

### 2. **Gift Redemption**
- Users can redeem their tokens via the `redeem_unfold_pack` function to receive random gifts.
- Gift options include: `SwiggyCoupon`, `OlaCoupon`, and `UberCoupon`.

### 3. **On-Chain Randomness**
- The gift type is determined using on-chain randomness (`sui::random`), ensuring fairness.

### 4. **Token Policy**
- A token policy restricts token spending to the `GiftShop` context.
- Admin can reward users using `reward_user`, and users can redeem rewards for real-world assets.

## Functions

- **`init`**: Initializes the loyalty token and sets up the token policy.
- **`reward_user`**: Allows the admin to reward users with tokens.
- **`redeem_unfold_pack`**: Users redeem tokens for random gifts, with the type determined using on-chain randomness.

## Extensibility
- **New Gifts**: Add more real-world assets or coupons.
- **Metadata**: Attach additional information to each gift.

## Contract Tracking Devnet
https://devnet.suivision.xyz/txblock/6nnoqU3nHsXoQNaDoUQWBpDtAds5LcwyFRifxjKRKXNh


This contract bridges blockchain rewards with real-world incentives using a fair and decentralized approach.
