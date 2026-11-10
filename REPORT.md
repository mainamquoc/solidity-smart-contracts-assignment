# Smart Contract Development Report

**Name:** Mai Nam Quốc  
**Student ID:** 29211145181

This report follows Section 6 of the [assignment](../Smart_Contract_Assignment.pdf): purpose, key concept, tests, and evidence for each contract.

## Environment and Evidence

- The contracts use Solidity ^0.8.20. Automated tests use solc, ethers, and Ganache at RPC http://127.0.0.1:7545.
- The [saved test results](test-results.txt) record **15 tests passed, 0 failed**. Test descriptions below refer to the corresponding [automated test cases](../test/contracts.test.cjs); the tests were not rerun during this documentation update.
- [Deployment records](deployments.json) contain contract addresses, deployment transaction hashes, and block numbers from automated testing, rather than manual Remix deployments.
- There are currently **11 screenshot files**: two each for contracts 01–02 and one each for contracts 03–09. No screenshots are present for contracts 10–15. The links below reference existing files; their visual contents have not been reviewed during this update.
- The assignment also requires compilation and deployment through Remix connected to Ganache, with at least two screenshots per contract. Automated tests support logic verification; the remaining Remix evidence still needs to be added.

## 01 Storage

- **What it does:** Stores a uint256 initialized in the constructor, updates it through set(), and reads it through get().
- **Key concept:** State variables, view functions, and the ValueSet event. Reading through eth_call does not create a transaction. No require condition is needed because every uint256 value is valid.
- **Tested:** Initialized with 42, updated to 100, and checked ValueSet; also stored and retrieved zero and the maximum uint256 value.
- **Ganache/Remix evidence:** [Compilation/deployment](../screenshots/01_compile_deploy.png), [test](../screenshots/01_test.png). Automated test 01 passed.

## 02 Greeting

- **What it does:** Stores a publicly readable greeting; only the owner can update it or reset it to Hello, World!.
- **Key concept:** The onlyOwner modifier checks access with require; GreetingChanged records updates.
- **Tested:** Read the initial greeting, changed it to GM Ganache, and reset it. Non-owner updates and resets reverted with Not the owner; checked the update event.
- **Ganache/Remix evidence:** [Compilation/deployment](../screenshots/02_compile_deploy.png), [test](../screenshots/02_test.png). Add an access-control error screenshot if needed. Automated test 02 passed.

## 03 Counter

- **What it does:** Increments, decrements, and resets a counter within the range 0–100.
- **Key concept:** Boundary checks before state changes; Incremented, Decremented, and Reset events.
- **Tested:** Decrementing at zero reverted with Count is zero; incrementing past 100 reverted with Max limit reached. Decrement and reset succeeded; checked all three event types.
- **Ganache/Remix evidence:** [Compilation/deployment](../screenshots/03_compile_deploy.png). Add a successful test screenshot and preferably both boundary errors. Automated test 03 passed.

## 04 Ownable / ProtectedVault

- **What it does:** ProtectedVault inherits Ownable; anyone can deposit ETH, while only the owner can withdraw or transfer ownership.
- **Key concept:** The onlyOwner modifier centralizes access checks and avoids duplicating them in each function. Withdrawals reduce treasure before the external call and use a reentrancy lock.
- **Tested:** Deposited 1 ETH; rejected unauthorized withdrawals, a zero-address owner, and excessive withdrawals. Transferred ownership; the new owner sent 1 ETH to another account, whose balance increased by exactly 1 ETH, leaving the vault empty.
- **Ganache/Remix evidence:** [Contract 04 screenshot](../screenshots/04_compile_deploy.png). Confirm it shows ProtectedVault and add ownership-transfer/withdrawal evidence. Automated test 04 passed.

## 05 SimpleBank

- **What it does:** Maintains individual ETH balances, supports deposits and withdrawals, and reports the total bank balance.
- **Key concept:** Checks-Effects-Interactions checks the balance, reduces the mapping, and then sends ETH using call. A callback cannot reuse the same credited funds; require(ok) reverts the operation if payment fails.
- **Tested:** Two users deposited 2 and 3 ETH with separate balances. Zero deposits and a 10 ETH withdrawal reverted. A 1 ETH withdrawal increased the caller's wallet by 1 ETH minus receipt.fee and left 4 ETH in the bank; checked Deposited/Withdrawn.
- **Ganache/Remix evidence:** [Compilation/deployment](../screenshots/05_compile_deploy.png). Add successful operations and balance/gas evidence. Automated test 05 passed.

## 06 Voting

- **What it does:** Allows the chairperson to authorize voters, accepts one vote per voter, and returns the candidate with the most votes.
- **Key concept:** Structs, arrays, and mappings store authorization and voting state. Ties select the candidate with the lower index.
- **Tested:** Created Alice/Bob/Carol, authorized three voters, and confirmed Bob won with two votes. Unauthorized authorization, an invalid index, repeated voting, and voting without authorization reverted; checked Authorized/Voted.
- **Ganache/Remix evidence:** [Compilation/deployment](../screenshots/06_compile_deploy.png). Add vote totals, the winner, and preferably a repeated-vote error. Automated test 06 passed.

## 07 MyToken

- **What it does:** Implements an ERC-20-style token with transfer, approve, and transferFrom without external libraries.
- **Key concept:** balanceOf tracks holdings and allowance limits delegated transfers. The token has 18 decimals; constructor supply uses whole tokens, while transfers and approvals use base units. Approval does not itself transfer tokens.
- **Tested:** Created 1,000,000 tokens, transferred 500, approved 200, and used a spender to transfer 200 to another recipient. The source retained 300 and allowance became zero. Insufficient allowance/balance and zero-address transfers reverted; checked Transfer/Approval.
- **Ganache/Remix evidence:** [Compilation/deployment](../screenshots/07_compile_deploy.png). Add transfer, approval, transferFrom, and allowance results. Automated test 07 passed.

## 08 Crowdfunding

- **What it does:** Accepts contributions before a deadline; afterward, the owner claims a successful campaign or contributors refund a failed campaign.
- **Key concept:** Timestamps, the claimed flag, and CEI: contributions are cleared before refunds. raised records historical contributions and does not decrease after claims or refunds.
- **Tested:** A 1 ETH goal campaign reached its target and was claimed; a 2 ETH goal campaign received only 1 ETH and was refunded. Zero contributions, early/unauthorized claims, refunds after success, repeated claims/refunds, and claims below the goal reverted; checked Contributed/Claimed/Refunded.
- **Ganache/Remix evidence:** [Compilation/deployment](../screenshots/08_compile_deploy.png). Add both claim and refund outcomes. Automated test 08 passed; Ganache time advancement was used to pass deadlines.

## 09 Lottery

- **What it does:** Accepts the exact entry fee, lets the manager select a winner who receives the full pot, and resets the player list for another round.
- **Key concept:** Arrays, access control, and ETH transfers. Blockhash-based randomness is unsuitable for production lotteries: block producers can influence block selection and the manager can exploit selection timing. Chainlink VRF is a better alternative.
- **Tested:** Five accounts entered with 0.01 ETH each. Incorrect fees, manager entry, insufficient players, and unauthorized winner selection reverted. WinnerSelected recorded 0.05 ETH, the winner received exactly that amount, the player count reset, and a new entry succeeded.
- **Ganache/Remix evidence:** [Compilation/deployment](../screenshots/09_compile_deploy.png). Add the winner, payout, and Ganache balance evidence. Automated test 09 passed.

## 10 TimeLockVault

- **What it does:** Accepts ETH and lets the beneficiary extend the lock and withdraw after unlockTime; deposits do not extend the lock.
- **Key concept:** Timestamp conditions, beneficiary access control, and a reentrancy lock during withdrawal.
- **Tested:** Deployed a 120-second lock and deposited 1 ETH. Early/unauthorized withdrawals reverted. Extended by 30 seconds, advanced node time by 151 seconds, checked timeRemaining was zero, and withdrew; repeated withdrawal reverted with Empty vault. Checked Deposited/Withdrawn.
- **Ganache/Remix evidence:** Automated test 10 passed; no screenshots are present. Add compilation/deployment, successful withdrawal, and a block timestamp after expiry.

## 11 Escrow

- **What it does:** Holds the buyer's deployment payment until delivery confirmation, a refund, or an arbiter's dispute resolution.
- **Key concept:** Enum states and stateCheck enforce valid transitions; state changes precede ETH transfers. Deployment requires payment, so the initial active state is AwaitingDelivery.
- **Tested:** Used four instances for delivery, refund, dispute-to-seller, and dispute-to-buyer; verified final states and zero escrow balances. Unauthorized confirmation/resolution and confirmation while Disputed reverted; checked StateChanged/Paid where asserted in the test.
- **Ganache/Remix evidence:** Automated test 11 passed; no screenshots are present. Add compilation/deployment and outcome screenshots, preferably covering all four paths.

## 12 SimpleNFT

- **What it does:** Mints up to 100 NFTs at 0.01 ETH each, supports direct/approved transfers, and lets the owner withdraw mint revenue.
- **Key concept:** ownerOf, balances, per-token approvals, and clearing approvals after transfers. This is an educational ERC-721-style subset. Only the current token owner may approve a spender.
- **Tested:** Two users minted; incorrect payment reverted. Transferred token 0, approved and transferred token 1, verified ownership/balances and cleared approval. The owner withdrew the first two mint payments; unauthorized withdrawal reverted. Minting beyond 100 reverted with Sold out.
- **Ganache/Remix evidence:** Automated test 12 passed; no screenshots are present. Add compilation/deployment, mint/transfers, and revenue withdrawal. The test checks Minted, TransferNFT, Approval, and PaymentsWithdrawn.

## 13 EnglishAuction

- **What it does:** Runs a timed auction with the assignment's 5% increment formula; losing bidders withdraw refunds, and anyone can end the auction after expiry to pay the seller.
- **Key concept:** Pull payments record pendingReturns instead of sending ETH inside bid(), so a previous bidder rejecting ETH cannot block new bids. This reduces external-call exposure in bid(); as in SimpleBank, withdrawal still uses CEI by clearing the refundable amount before call.
- **Tested:** Started at 0.1 ETH, accepted 0.11 and 0.12, rejected 0.121, and refunded 0.11. Repeated refunds and early ending reverted; after expiry the seller received 0.12 and further bids failed. A no-bid auction also ended successfully; checked NewBid/PendingWithdrawn/AuctionEnded.
- **Ganache/Remix evidence:** Automated test 13 passed; no screenshots are present. Add compilation/deployment, pending refunds, and auction completion.

## 14 MultisigWallet

- **What it does:** Requires M confirmations from N owners for an ETH transfer and executes each transaction once.
- **Key concept:** Owner/confirmation mappings, confirmation counts, and setting executed before payment. Submission includes the submitter's confirmation. Reaching the threshold auto-executes when funded; otherwise confirmations remain for execution after a deposit.
- **Tested:** Funded a 2-of-3 wallet with 2 ETH; submitting a 1 ETH transfer did not pay immediately, while a second owner's confirmation paid exactly 1 ETH. Rejected insufficient confirmations, duplicate/post-execution confirmations, non-owners, and duplicate owners. A pending underfunded transfer executed after a top-up; checked Deposit/Submission/Execution.
- **Ganache/Remix evidence:** Automated test 14 passed; no screenshots are present. Add compilation/deployment, confirmation counts before/after the threshold, and recipient balances.

## 15 StakingRewards

- **What it does:** Rewards ETH staking over time; claims preserve principal, unstaking returns principal plus rewards, and the owner funds the pool or changes the rate. Insufficient reward funding causes a revert.
- **Key concept:** Checkpoints preserve accrued rewardDebt before adding stake; rewardIndex preserves historical rates without retroactive changes. The code divides by 1 ether and interprets the rate as reward wei per staked ETH per second, matching the assignment example of 60,000 wei for 1 ETH at rate 1000 over 60 seconds; the assignment's written units/formula are inconsistent with that example. Uses CEI/nonReentrant; the optional one-day minimum lock is not implemented.
- **Tested:** Seeded a 5 ETH pool at rate 1000, staked 1/2 ETH, and verified rewards against block timestamps after advancing 60 seconds. Claimed while retaining principal, added stake, changed the rate to 2000, and verified historical accrual. Tested unstaking, repeated unstaking, unauthorized management, and insufficient-pool reverts preserving the stake; checked balance = totalStaked + rewardPool and Staked/RewardClaimed/Unstaked.
- **Ganache/Remix evidence:** Automated test 15 passed; no screenshots are present. Add compilation/deployment, rewards with actual timestamps, claims, and unstaking.

## Remaining Submission Work

- Contracts 01–02 have the minimum number of screenshot files; verify that their contents demonstrate compilation/deployment and successful testing.
- Contracts 03–09 need at least one additional screenshot each, and contracts 10–15 need at least two each: **at least 19 additional screenshots** are required with the current files.
- Add Ganache account, successful-operation, revert, event, and balance evidence as appropriate; update the links using real files. Fifteen passing tests do not imply that every public getter or event has been individually checked.
- Add the email address to the README, verify all documentation, publish the repository as Public on GitHub, and submit its URL.
