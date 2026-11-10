# Solidity Smart Contract Assignment

**Name:** Mai Nam Quốc  
**Student ID:** 29211145181  
**Email:** To be added

Fifteen Solidity contracts, from basic storage to staking rewards, implemented for the [Smart Contract Development Assignment](Smart_Contract_Assignment.pdf).

## Project Structure

```text
Assignment15/
├── contracts/              # 15 Solidity source files
├── screenshots/            # Remix and Ganache evidence
├── report/
│   ├── REPORT.md           # Per-contract report
│   ├── REMIX_GUIDE.md      # Existing Remix setup guide
│   ├── test-results.txt    # Saved automated test output
│   └── deployments.json    # Automated deployment records
├── scripts/compile.cjs
├── test/contracts.test.cjs
└── package.json
```

## Contract Status

The [saved results](report/test-results.txt) record 15 passing automated Ganache tests and zero failures. The following screenshot inventory reflects existing files; manual Remix completion and screenshot contents still need verification.

| # | Contract | Level | Automated Ganache Tests | Screenshot Files |
|---|---|---|---|---|
| 01 | Storage | Basic | PASS | [Deploy](screenshots/01_compile_deploy.png), [test](screenshots/01_test.png) |
| 02 | Greeting | Basic | PASS | [Deploy](screenshots/02_compile_deploy.png), [test](screenshots/02_test.png) |
| 03 | Counter | Basic | PASS | [Deploy](screenshots/03_compile_deploy.png); test image pending |
| 04 | Ownable / ProtectedVault | Medium | PASS | [Deploy](screenshots/04_compile_deploy.png); test image pending |
| 05 | SimpleBank | Medium | PASS | [Deploy](screenshots/05_compile_deploy.png); test image pending |
| 06 | Voting | Medium | PASS | [Deploy](screenshots/06_compile_deploy.png); test image pending |
| 07 | MyToken | Medium | PASS | [Deploy](screenshots/07_compile_deploy.png); test image pending |
| 08 | Crowdfunding | Advanced | PASS | [Deploy](screenshots/08_compile_deploy.png); test image pending |
| 09 | Lottery | Advanced | PASS | [Deploy](screenshots/09_compile_deploy.png); test image pending |
| 10 | TimeLockVault | Advanced | PASS | Pending |
| 11 | Escrow | Advanced | PASS | Pending |
| 12 | SimpleNFT | Advanced | PASS | Pending |
| 13 | EnglishAuction | Expert | PASS | Pending |
| 14 | MultisigWallet | Expert | PASS | Pending |
| 15 | StakingRewards | Expert | PASS | Pending |

There are currently 11 screenshots. At least 19 additional screenshots are needed to meet the minimum of two per contract. Automated deployment records do not establish that every contract was compiled and deployed manually through Remix.

## Run Locally

Use Node.js/npm and run these commands from this directory:

```powershell
npm ci
npm run compile
```

Start Ganache GUI with RPC `http://127.0.0.1:7545`, or start the bundled CLI in a separate terminal:

```powershell
npm run ganache
```

Use one Ganache instance on that port. With Ganache running:

```powershell
npm test
```

The compiler is pinned to **Solidity 0.8.30**, with the optimizer enabled for **200 runs** and EVM target **paris** for compatibility with older Ganache GUI versions.

Tests send transactions to Ganache using its local test accounts. Time-dependent tests use `evm_increaseTime` and `evm_mine`. To use a different RPC endpoint:

```powershell
$env:GANACHE_URL = "http://127.0.0.1:7545"
npm test
```

Running tests updates `report/deployments.json`; terminal output is not automatically saved to `report/test-results.txt`.

## Compile and Deploy in Remix

1. Open the Solidity files in Remix, or run `npm run remix` and connect to the shared local contracts directory.
2. Select compiler 0.8.30, optimizer 200 runs, and EVM target paris; compile the selected file.
3. Start Ganache at `http://127.0.0.1:7545`.
4. In Deploy & Run, select Custom - External Http Provider and enter the Ganache RPC URL.
5. Select a Ganache account and the appropriate contract. For contract 04, deploy **ProtectedVault**.
6. Supply constructor arguments and set transaction Value only when sending ETH to a payable constructor or function.
7. Test successful and invalid operations; check Ganache transactions, event logs, account balances, and gas fees.
8. Save at least two screenshots per contract: compilation/deployment with a Ganache account visible, and a successful test result.

Most automated negative tests check revert messages during gas estimation, so they may not create mined failed transactions. Capture the visible error in Remix for manual evidence.

## Reports and Evidence

- [Contract report](report/REPORT.md): purpose, concepts, tests, and evidence for all 15 contracts.
- [Saved test results](report/test-results.txt): output from the recorded automated run.
- [Deployment records](report/deployments.json): addresses, deployment hashes, and block numbers from automated testing.
- [Existing Remix guide](report/REMIX_GUIDE.md): setup and constructor reference.

## Implementation Decisions

- **MyToken:** Constructor supply is expressed in whole tokens; transfers and approvals use base units with 18 decimals. A supply of 1,000,000 creates 1,000,000 × 10^18 base units.
- **StakingRewards:** The rate means reward wei per staked ETH per second, matching the assignment example: 1 ETH at rate 1000 for 60 seconds earns 60,000 wei. The assignment's per-wei wording conflicts with that example. Checkpoints round down fractional wei, and rate changes preserve historical accrual. If the pool is insufficient, claims and unstaking revert until the owner adds funding.
- **MultisigWallet:** Submission includes the submitter's confirmation. A second owner reaches the 2-of-3 threshold. Underfunded transactions retain confirmations and can execute after a top-up.
- **SimpleNFT:** Only the current token owner can approve a spender. The assignment example describing another account approving token 1 must be interpreted using its actual owner. This is an educational ERC-721-style subset.
- **Voting:** Ties select the earlier candidate in the array.
- **Lottery:** Uses blockhash as required by the exercise; it is unsuitable for production lotteries. The report explains the limitation and names Chainlink VRF as an alternative.
- **Storage:** Every uint256 value is valid, so there is no artificial require-revert case.

## Submission Checklist

- [x] Add student name and student ID.
- [ ] Add email address.
- [ ] Verify manual Remix compilation/deployment for all 15 contracts against Ganache.
- [ ] Save at least two valid screenshots per contract, 30 in total.
- [ ] Update evidence links and confirm they match the actual tests.
- [ ] Publish a Public GitHub repository named `solidity-smart-contracts-assignment` with meaningful commits.
- [ ] Submit the repository URL to the instructor.
