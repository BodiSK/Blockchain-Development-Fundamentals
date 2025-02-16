# Staking Pool System

A decentralized staking pool system consisting of an ERC20 token (StakingToken) and a StakingPool contract.

## Contracts

### ERC20 token

- ERC20 token with 8 decimals
- Initial supply: 5,000,000 STX
- Symbol: STX
- Name: StakeX

### StakingPool
- Reward rate of 5% calculated per second
- Minter Role granted after deploy

## Installation

1. Install dependencies

```bash
npm install
```

2. Create `.env` file

```bash
SEPOLIA_URL=your_sepolia_rpc_url
PRIVATE_KEY=your_private_key
ETHERSCAN_API_KEY=your_etherscan_api_key
```

## Testing

Run the test suite:

```bash
npx hardhat test
```

Run test coverage:

```bash
npx hardhat coverage
```

## Deployment

Deploy both contracts to Sepolia:

```bash
npx hardhat deploy --network sepolia --stakingTokenOwner <owner-of-token > --stakingPoolOwner <owner-of-staking-pool>
```

### Deployment Parameters

- `stakingTokenOwner`(optional): address of owner of the ERC20 token
- `stakingPoolOwner`(optional): address of owner of the Staking Pool contract

## Contract Verification

Contracts are manualy verified after deploy on Sepolia testnet.

### Verified Contracts (Sepolia)

- StakingToken: [0x7296b729a1e646043e60Da4Bd66f06E4f3307372 ](https://sepolia.etherscan.io/address/0x7296b729a1e646043e60Da4Bd66f06E4f3307372#code)
- StakingPool: [0xf564b73E4b38e193F2A371E598BCdA0096573a3A ](https://sepolia.etherscan.io/address/0xf564b73E4b38e193F2A371E598BCdA0096573a3A#code)
