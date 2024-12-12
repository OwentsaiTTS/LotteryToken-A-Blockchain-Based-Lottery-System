# LotteryToken-A-Blockchain-Based-Lottery-System

LotteryToken is a blockchain-based lottery system implemented as an Ethereum smart contract. This project demonstrates how to combine ERC20 token functionality with a decentralized lottery mechanism, allowing users to buy tickets, participate in draws, and win rewards.

## Features

- **Custom ERC20 Token**: `LotteryToken (LTT)` is used for transactions.
- **Faucet**: Users claim free tokens periodically.
- **Lottery Tickets**: Purchase tickets to join prize draws.
- **Fair Randomness**: Random numbers generated using blockchain data.
- **Prize Pool**: Winners share tokens from the jackpot.

## How It Works

1. **Token Distribution**:
   - Users can claim free tokens using the faucet function (once every 30 seconds).
   - Tokens are required to buy lottery tickets.

2. **Buying Tickets**:
   - Users purchase tickets by selecting three unique numbers between 1 and 46.
   - Ticket purchases contribute to the jackpot prize pool.

3. **Drawing the Lottery**:
   - The contract creator can initiate a draw once every 2 minutes.
   - Three random winning numbers are generated.
   - Winners are determined based on matching numbers, and the prize pool is equally distributed among winners.

4. **Resetting**:
   - After each draw, the ticket list is cleared, and the jackpot is reset.

## Smart Contract Details

- **Name**: LotteryToken
- **Symbol**: LTT
- **Decimals**: 0 (No fractional tokens for simplicity)
- **Total Supply**: 1,000,000 LTT
- **Ticket Price**: 100 LTT
- **Reward Pool Contribution**: 90% of ticket price

## Requirements

To interact with this smart contract, you need:
- **Ethereum Development Environment**:
  - [Remix IDE](https://remix.ethereum.org/)
- **Wallet**:
  - MetaMask or another Ethereum wallet for testing and transactions.
- **Solidity Compiler Version**: 0.8.19
