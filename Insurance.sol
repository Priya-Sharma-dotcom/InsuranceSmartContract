// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Insurance {

    address public insurer;

    enum Reason { Hospitalization, Accident, Surgery }
    enum ClaimStatus { Pending, Approved, Rejected, Paid }

    constructor() {
        insurer = msg.sender;
    }

    modifier onlyInsurer() {
        require(msg.sender == insurer, "Only insurer allowed");
        _;
    }

    modifier onlyPolicyHolder(address policyHolder) {
        require(msg.sender == policyHolder, "Only policyholder allowed");
        _;
    }

    struct Policy {
        uint premiumAmount;
        uint coverageAmount;
        address policyHolder;
        uint startTime;
        uint duration;
        bool isActive;
        bool isPremiumPaid;
    }

    struct Claim {
        uint policyId;
        Reason reason;
        uint claimAmount;
        ClaimStatus status;
    }

    mapping(uint => Policy) public policies;
    mapping(uint => Claim) public claims;

    uint public policyCounter;
    uint public claimCounter;

    event PolicyIssued(uint policyId, address policyHolder);
    event PremiumPaid(uint policyId, address policyHolder, uint amount);
    event ClaimSubmitted(uint claimId, uint policyId, address policyHolder);
    event ClaimApproved(uint claimId);
    event ClaimRejected(uint claimId);
    event ClaimPaid(uint claimId, uint amount);

    function issuePolicy(address PolicyHolder,uint premiumAmount, uint coverageAmount, uint duration) public onlyInsurer {
        policyCounter++;
        policies[policyCounter] = Policy(
            premiumAmount,
            coverageAmount,
            PolicyHolder,
            block.timestamp,
            duration,
            true,
            false
        );
        emit PolicyIssued(policyCounter, msg.sender);
    }

    function payPremium(uint policyId) public payable onlyPolicyHolder(policies[policyId].policyHolder) {
        Policy storage policy = policies[policyId];
        require(policy.isActive, "Policy not active");
        require(msg.value == policy.premiumAmount, "Incorrect premium");

        policy.isPremiumPaid = true;
        payable(insurer).transfer(msg.value);

        emit PremiumPaid(policyId, msg.sender, msg.value);
    }

    function submitClaim(uint policyId, uint claimAmount, Reason reason) public onlyPolicyHolder(policies[policyId].policyHolder) {
        claimCounter++;
        claims[claimCounter] = Claim(policyId, reason, claimAmount, ClaimStatus.Pending);
        emit ClaimSubmitted(claimCounter, policyId, msg.sender);
    }

    function approveClaim(uint claimId) public onlyInsurer {
        Claim storage claim = claims[claimId];
        Policy storage policy = policies[claim.policyId];

        require(block.timestamp <= policy.startTime + policy.duration, "Policy expired");
        require(policy.isActive, "Policy inactive");
        require(policy.isPremiumPaid, "Premium not paid");
        require(claim.claimAmount <= policy.coverageAmount, "Claim exceeds coverage");
        require(claim.status == ClaimStatus.Pending, "Already processed");

        claim.status = ClaimStatus.Approved;
        emit ClaimApproved(claimId);
    }

    function rejectClaim(uint claimId) public onlyInsurer {
        Claim storage claim = claims[claimId];
        Policy storage policy = policies[claim.policyId];

        // Rejection if any of the following fails
        if (
            block.timestamp > policy.startTime + policy.duration ||
            !policy.isActive ||
            !policy.isPremiumPaid ||
            claim.claimAmount > policy.coverageAmount
        ) {
            claim.status = ClaimStatus.Rejected;
            emit ClaimRejected(claimId);
        } else {
            revert("Claim cannot be rejected: all conditions are valid");
        }
    }

    function payClaim(uint claimId) public payable onlyInsurer {
        Claim storage claim = claims[claimId];
        Policy storage policy = policies[claim.policyId];

        require(claim.status == ClaimStatus.Approved, "Claim not approved");
        require(msg.value == claim.claimAmount, "Incorrect amount");
        require(claim.status != ClaimStatus.Paid, "Already paid");

        claim.status = ClaimStatus.Paid;
        payable(policy.policyHolder).transfer(msg.value);

        emit ClaimPaid(claimId, msg.value);
    }
}
