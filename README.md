# Insurance Smart Contract

A basic Ethereum smart contract for issuing, managing, and claiming insurance policies.

---

## 📄 Description

This smart contract enables:

* Insurers to issue policies to users
* Policyholders to pay premiums
* Policyholders to submit claims
* Insurer to approve/reject claims and make payouts

---

## 📅 Features

* `issuePolicy` by insurer
* `payPremium` by policyholder
* `submitClaim` with enum reasons (Hospitalization, Accident, Surgery)
* `approveClaim`, `rejectClaim` logic based on policy activity and validity
* `payClaim` to transfer claim amount after approval

---

## 👥 Roles

* `insurer`: Deployer of the contract, authorized to issue policies and process claims
* `policyHolder`: Address that receives the insurance policy and interacts with it

---

## ⚖️ Enums

```solidity
enum Reason { Hospitalization, Accident, Surgery }
enum ClaimStatus { Pending, Approved, Rejected, Paid }
```

---

## 🔍 How It Works

### Issue Policy

```solidity
function issuePolicy(address PolicyHolder, uint premiumAmount, uint coverageAmount, uint duration)
```

### Pay Premium

```solidity
function payPremium(uint policyId) public payable
```

### Submit Claim

```solidity
function submitClaim(uint policyId, uint claimAmount, Reason reason)
```

### Approve/Reject Claim

```solidity
function approveClaim(uint claimId)
function rejectClaim(uint claimId)
```

### Pay Claim

```solidity
function payClaim(uint claimId) public payable
```

---

## 🏢 Contract Structure

### `Policy`

```solidity
struct Policy {
    uint premiumAmount;
    uint coverageAmount;
    address policyHolder;
    uint startTime;
    uint duration;
    bool isActive;
    bool isPremiumPaid;
}
```

### `Claim`

```solidity
struct Claim {
    uint policyId;
    Reason reason;
    uint claimAmount;
    ClaimStatus status;
}
```

---

## ⚠️ Security and Access Control

* `onlyInsurer` modifier ensures only deployer manages policies and claims.
* `onlyPolicyHolder` modifier ensures only rightful holder can pay or claim.

---

## 🔔 Events

```solidity
PolicyIssued(uint policyId, address policyHolder);
PremiumPaid(uint policyId, address policyHolder, uint amount);
ClaimSubmitted(uint claimId, uint policyId, address policyHolder);
ClaimApproved(uint claimId);
ClaimRejected(uint claimId);
ClaimPaid(uint claimId, uint amount);
```

---

## 🌐 Example Deployment

* Deploy using Remix IDE or Hardhat
* Use MetaMask + Sepolia testnet for testing interactions
* Set initial insurer as `msg.sender`

---

## 🔐 License

MIT License

---

## 🚀 Future Enhancements

* Add rejection reasons as enums
* Add support for multiple claims per policy
* Frontend integration with Web3.js or Ethers.js
* Store claim history and timestamps
