// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract insurancePolicy {

    address public insurerAdd;
    uint public policyCounter;
    uint public claimCounter;

    constructor() {
        insurerAdd = msg.sender;
    }

    modifier OnlyInsurer() {
        require(msg.sender == insurerAdd, "ONLY INSURER CAN CALL THIS FUNCTION");
        _;
    }

    modifier OnlyPolicyHolder(address _policyholder) {
        require(msg.sender == _policyholder, "ONLY POLICYHOLDER CAN CALL THIS FUNCTION");
        _;
    }

    struct Policy {
        address policyholder;
        uint premiumAmount;
        uint coverageAmount;
        uint policyDuration;
        uint startTime;
        bool isActive;
    }

    struct Claim {
        uint policyID;
        string reason;
        uint claimAmount;
        bool isApproved;
        bool isPaid;
    }

    mapping(uint => Policy) public InsurancePolicy;
    mapping(uint => Claim) public claims;

    event PolicyIssued(uint policyID, address policyholder);
    event PremiumPaid(uint policyID, uint premium, address payer);
    event ClaimSubmitted(uint policyID, uint claimId, uint amount);
    event ClaimApproved(uint claimID);
    event ClaimPaid(uint claimId);

    function issuePolicy(
        address _PolicyHolderAddress,
        uint _premiumAmount,
        uint _coverageAmount,
        uint _policyDuration
    ) public OnlyInsurer {
        policyCounter++;
        InsurancePolicy[policyCounter] = Policy(
            _PolicyHolderAddress,
            _premiumAmount,
            _coverageAmount,
            _policyDuration,
            block.timestamp,
            true
        );
        emit PolicyIssued(policyCounter, _PolicyHolderAddress);
    }

    function payPremium(uint _policyId) public payable OnlyPolicyHolder(InsurancePolicy[_policyId].policyholder) {
        require(msg.value == InsurancePolicy[_policyId].premiumAmount, "Premium Amount incorrect");
        require(InsurancePolicy[_policyId].isActive, "Policy is not active");
        emit PremiumPaid(_policyId, msg.value, msg.sender);
    }

    function submitClaim(
        uint _policyId,
        string memory _reason,
        uint _claimAmount
    ) public OnlyPolicyHolder(InsurancePolicy[_policyId].policyholder) {
        require(
            block.timestamp <= InsurancePolicy[_policyId].startTime + InsurancePolicy[_policyId].policyDuration,
            "POLICY EXPIRED"
        );
        require(InsurancePolicy[_policyId].isActive, "POLICY IS NOT ACTIVE");

        claimCounter++;
        claims[claimCounter] = Claim(_policyId, _reason, _claimAmount, false, false);
        emit ClaimSubmitted(_policyId, claimCounter, _claimAmount);
    }

    function approveClaim(uint _claimID) public OnlyInsurer {
        require(!claims[_claimID].isApproved, "Claim already approved");
        claims[_claimID].isApproved = true;
        emit ClaimApproved(_claimID);
    }

    function payClaim(uint _claimID) public payable OnlyInsurer {
        require(claims[_claimID].isApproved, "CLAIM IS NOT APPROVED");
        require(!claims[_claimID].isPaid, "CLAIM ALREADY PAID");
        require(msg.value == claims[_claimID].claimAmount, "Incorrect payout amount");

        payable(InsurancePolicy[claims[_claimID].policyID].policyholder).transfer(claims[_claimID].claimAmount);
        claims[_claimID].isPaid = true;
        emit ClaimPaid(_claimID);
    }
}
