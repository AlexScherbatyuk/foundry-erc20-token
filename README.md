# ERC20 Token

**Simple ERC20 token based on OpenZeppelin contracts with 100% test coverage.**

## Overview

This project implements a standard ERC20 token using OpenZeppelin's battle-tested contracts. The token includes comprehensive test coverage and follows best practices for smart contract development.

## Prerequisites

- [Foundry](https://getfoundry.sh/) - Ethereum development toolkit
- [Git](https://git-scm.com/) - Version control

## Installation

```shell
make install
```

## Development

### Build

```shell
make build
```

### Test

```shell
make test
```

### Format Code

```shell
make fmt
```

### Gas Snapshots

```shell
make snapshot
```

## Local Development

### Start Local Blockchain

```shell
anvil
```

## Deployment

### Local Deployment

```shell
forge deploy
```

### Sepolia Testnet Deployment

```shell
forge deploy-sepolia
```

## Project Structure

```
├── src/           # Source contracts
├── test/          # Test files
├── script/        # Deployment scripts
├── lib/           # Dependencies
└── out/           # Build artifacts
```

## License

This project is licensed under the MIT License.
