# base-vesting-contracts

> Token Vesting & Distribution Contracts for Base L2

Production-ready vesting contracts for Base. Supports cliff + linear vesting, milestone unlocks, batch airdrops with Merkle proofs, and revocable allocations.

## Vesting Types
- ⏰ **Linear**: tokens unlock continuously over a duration
- 🪨 **Cliff + Linear**: locked period then linear unlock
- 🎯 **Milestone**: unlock upon reaching on-chain goals
- 📋 **Batch Airdrop**: Merkle-proof based mass distribution

## Features
- Multi-beneficiary management
- Revocable by admin (for team tokens)
- ERC20 token support (any token on Base)
- Emergency pause
- Claim dashboard UI (React)

## Installation
```bash
git clone https://github.com/fabt31/base-vesting-contracts
forge install && forge build && forge test
```

## Usage
```solidity
// Create a 1-year linear vest with 3-month cliff
vestingFactory.createVesting(
    beneficiary,
    tokenAddress,
    totalAmount,
    block.timestamp,       // start
    90 days,               // cliff
    365 days,              // duration
    true                   // revocable
);
```

## License
MIT