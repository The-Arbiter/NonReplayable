# NonReplayable

## What is this?

I think that PoW ETH is going to keep a `chainId` of 1.

If they do, you can (potentially) use this to make certain transactions replay attack resistant on one chain.

## How does it work?

> Post-merge, the DIFFICULTY opcode gets renamed to PREVRANDAO, and stores the prevRandao field from the beacon chain state.

By checking if difficulty is more than 2^64, we can determine whether we are on proof of stake (true) or proof of work (false). Current difficulty on PoW ETH (pre-merge) is around 2^54.

Concerns have been raised about whether this will cause random failures or not. From [EIP-4399](https://eips.ethereum.org/EIPS/eip-4399#definitions).

```
Using 2**64 threshold to determine PoS blocks

The probability of RANDAO value to fall into the range between 0 and 2**64 and, thus, to be mixed with PoW difficulty values, is drastically low. Though, proposed threshold might seem to have insufficient distance from difficulty values on Ethereum Mainnet (they are currently around 2**54), it requires a thousand times increase of the hashrate to make this threshold insecure. Such an increase is considered impossible to occur before the upcoming consensus upgrade.
```

[Existing projects](https://gist.github.com/m1guelpf/6d09b85d70a1dfd00d394b2acf789eeb) have used this method and I feel confident copying it.

## Credits

Credit to @amxx for expanding functionality from raw ETH to include ERC20, ERC721 and ERC1155 tokens. 

Credit to @PCaversaccio for the original idea - check it out [here](https://gist.github.com/pcaversaccio/87b4666b2131ad950bf9ee97573447be) and his deployed on-chain oracle for merge detection [here](https://etherscan.io/address/0x17fef0d05ffed818af08ae00bec06b65c4319618).