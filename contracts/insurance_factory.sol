pragma solidity ^0.8.0;

// Factory contract that creates new instances of InsurancePolicy
contract InsuranceFactory {

    // Array of addresses that are allowed to create new policies
    address[] private allowedCreators;

    // Array to keep track of all the policies that have been created
    address payable[] private allPolicies;
    
    // Modifier that checks if the caller is allowed to create new policies
    modifier onlyAllowedCreators() {
        bool allowed = false;
        for (uint256 i = 0; i < allowedCreators.length; i++) {
            if (allowedCreators[i] == msg.sender) {
                allowed = true;
                break;
            }
        }
        require(allowed, "Only allowed creators can create new policies");
        _;
    }

    // Constructor function that sets the initial set of allowed creators
    constructor(address[] memory _allowedCreators) {
        allowedCreators = _allowedCreators;
    }

    // Function to add a new address to the allowed creators list
    function addAllowedCreator(address newCreator) public onlyAllowedCreators {
        allowedCreators.push(newCreator);
    }

    // Function to remove an address from the allowed creators list
    function removeAllowedCreator(address creator) public onlyAllowedCreators {
        for (uint256 i = 0; i < allowedCreators.length; i++) {
            if (allowedCreators[i] == creator) {
                allowedCreators[i] = allowedCreators[allowedCreators.length - 1];
                allowedCreators.pop();
                break;
            }
        }
    }

    // Function to create a new instance of InsurancePolicy with an initial premium
    function createInsurancePolicy(address payable _beneficiary, uint _premiumAmount, uint _payoutAmount, uint _durationInDays) public onlyAllowedCreators returns (address) {
        
        // Create a new instance of InsurancePolicy using the provided initial premium
        InsurancePolicy newPolicy = new InsurancePolicy(_beneficiary, _premiumAmount, _payoutAmount, _durationInDays);

        allPolicies.push(address(newPolicy));

        // Return the address of the new instance of InsurancePolicy
        return address(newPolicy);
    }
    
    // Function to view all currently open policies
    function viewOpenPolicies() public view returns (address[] memory) {
        uint openPolicyCount = 0;
        for (uint256 i = 0; i < allPolicies.length; i++) {
            if (InsurancePolicy(allPolicies[i]).isActive()) {
                openPolicyCount++;
            }
        }
        address[] memory openPolicies = new address[](openPolicyCount);
        uint openPolicyIndex = 0;
        for (uint256 i = 0; i < allPolicies.length; i++) {
            if (InsurancePolicy(allPolicies[i]).isActive()) {
                openPolicies[openPolicyIndex] = allPolicies[i];
                openPolicyIndex++;
            }
        }
        return openPolicies;
    }
    
    

}


// Contract representing an insurance policy
contract InsurancePolicy {
    // The owner of the contract
    address payable public owner;

    // The beneficiary of the insurance policy
    address payable public beneficiary;

    // The amount of the insurance premium
    uint public premiumAmount;

    // The amount to be paid out if the risk occurs
    uint public payoutAmount;

    // The time at which the policy expires
    uint public expirationTime;

    // True if the policy has been activated
    bool public activated;

    // True if the risk has occurred
    bool public riskOccurred;

    // The constructor function - sets the owner, beneficiary, premium amount, and payout amount
    constructor(address payable _beneficiary, uint _premiumAmount, uint _payoutAmount, uint _durationInDays) {
        owner = payable(msg.sender);
        beneficiary = _beneficiary;
        premiumAmount = _premiumAmount;
        payoutAmount = _payoutAmount;
        expirationTime = block.timestamp + (_durationInDays * 1 days);
    }

    // The function to activate the insurance policy
    function activate() public payable {
        require(msg.sender == owner, "Only the owner can activate the policy.");
        require(msg.value == premiumAmount, "Premium amount must be paid to activate the policy.");
        require(!activated, "Policy has already been activated.");
        activated = true;
    }

    // The function to check if the policy is still active
    function isActive() public view returns (bool) {
        return (activated && !riskOccurred && block.timestamp < expirationTime);
    }

    // The function to report that the risk has occurred
    function reportRisk() public {
        require(msg.sender == beneficiary, "Only the beneficiary can report a risk.");
        require(activated, "Policy has not been activated.");
        require(!riskOccurred, "Risk has already been reported.");
        require(block.timestamp < expirationTime, "Policy has expired.");
        riskOccurred = true;
    }

    // The function to pay out the insured amount if the risk occurs
    function payout() public {
        require(msg.sender == owner, "Only the owner can pay out the insured amount.");
        require(activated, "Policy has not been activated.");
        require(riskOccurred, "Risk has not occurred.");
        require(block.timestamp < expirationTime, "Policy has expired.");
        payable(beneficiary).transfer(payoutAmount);
    }

    // The fallback function - refunds any excess Ether sent to the contract
    fallback() external payable {
        require(msg.value > 0, "No Ether sent.");
        owner.transfer(msg.value);
    }
}
