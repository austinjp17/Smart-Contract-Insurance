//SPDX-License-Identifier: UNLICENSED

import "./insurance_policy.sol";
pragma solidity ^0.8.0;

contract Insurance_Factory {
    
    struct Permissioned_User {
        bool active;
        uint8 premiumHaircut;
        Insurance_Policy[] policies;
        
    }
    
    mapping (address => Permissioned_User) public allowedCreators;

    address[] allowedCreatorsList;

    address payable public owner;

    // CONTRUCTOR
    constructor(address[] memory _allowedCreators, uint8[] memory _premiumHaircut) {
        require(_allowedCreators.length == _premiumHaircut.length, "Initialization arrays must be same length");
        
        owner = payable(msg.sender);
        allowedCreatorsList.push(owner);
        //Initalize Allowed Creator Structures
        for (uint i = 0; i < _allowedCreators.length; i++) {
            Permissioned_User memory creatorEntry = Permissioned_User({
                active:true,
                premiumHaircut:_premiumHaircut[i],
                policies: new Insurance_Policy[](0)
        });
            
            allowedCreators[_allowedCreators[i]] = creatorEntry;
            allowedCreatorsList.push(_allowedCreators[i]);
        }
    }

    // EVENTS
    event NewPolicyCreated(
        address indexed policyAddr,
        address indexed policyOriginator
    );
    
    event PolicyClaimed(
        address indexed policyAddr,
        address indexed policyOriginator,
        uint claimAmt
    );

    event PoolDeposit(
        address from,
        uint amt
    );

    //MODIFIERS
    modifier onlyOwner() {
        // factory owner only
        require(
            msg.sender == owner,
            "This function may only be called by the owners"
        );
        _;
    }

    modifier checkVendor() {
        // approved vendor or factory owner
        require(
            allowedCreators[msg.sender].active == true || msg.sender == owner,
            "Not a permission Vendor or owner"
        );
        _;
    }

    

    //FUNCTIONS

    receive() external payable {
        emit PoolDeposit(msg.sender, msg.value);
    }

    //Vendor Interaction Functions
    function getVendorPolicies(
        address creator
    ) external view onlyOwner returns (Insurance_Policy[] memory) {
        return (allowedCreators[creator].policies);
    }

    function getVendors() external view returns (address[] memory) {
        return allowedCreatorsList;
    }

    function addVendor(address creator, uint8 haircut) external onlyOwner {
        Permissioned_User memory tempCreator = Permissioned_User(
                true,
                haircut,
                new Insurance_Policy[](0)
            );
        allowedCreators[creator] = tempCreator;
        allowedCreatorsList.push(creator);
    }

    
    function removeVendor(address creator) external onlyOwner {
        require(allowedCreators[creator].active == true, "Vendor not active");
        // remove creator
        allowedCreators[creator].active = false;
        for(uint16 i = 0; i<allowedCreatorsList.length; i++ ) {
            if(allowedCreatorsList[i] == creator) {
                allowedCreatorsList[i] = allowedCreatorsList[allowedCreatorsList.length-1];
                allowedCreatorsList.pop();
            }
        }
        
    }

    function setHaircut(address vendor, uint8 haircut) external onlyOwner {
        allowedCreators[vendor].premiumHaircut = haircut;
    }

    //PAY CLAIM
    function payClaim(address payable claimAddr) external {
        // can only be called by the vendor who originated the contract

        // GET POLICY INFO
        uint claimAmt = Insurance_Policy(claimAddr).payout_amount();
        bool claimPaid = Insurance_Policy(claimAddr).claimed();
        address policyOriginator = Insurance_Policy(claimAddr).owner();
        address payable beneficiary = Insurance_Policy(claimAddr).beneficiary();

        // CHECKS
        assert(policyOriginator == msg.sender);
        // require(policyOriginator == msg.sender, "??");
        assert(address(this).balance > claimAmt);
        assert(claimPaid == false);
        // require(claimPaid == false, "claim already paid");

        // if (address(this).balance < claimAmt) {
            // revert();
        // }

        // transfer
        beneficiary.transfer(claimAmt);

        // UPDATE POLICY CLAIMED STATE
        Insurance_Policy(claimAddr).setClaimed();

        //Emit claim event
        emit PolicyClaimed(claimAddr, policyOriginator, claimAmt);
    }

    //CREATE POLICY
    function createPolicy(
        uint productPrice,
        address payable _beneficiary,
        uint8 _durationInDays
    ) external checkVendor {

        require(_durationInDays < 2**8 - 1, "Duration too long");

        uint16 coverage = uint16(((100-allowedCreators[msg.sender].premiumHaircut) * productPrice) / 100);
        
        Insurance_Policy newPolicy = new Insurance_Policy(
            coverage,
            _beneficiary,
            _durationInDays,
            owner
        );
        allowedCreators[msg.sender].policies.push(newPolicy);

        // emit newpolicy event
        emit NewPolicyCreated(address(newPolicy), msg.sender);
    }

    //FALLBACK
    fallback() external payable {
        emit PoolDeposit(msg.sender, msg.value);
    }

    //KILL CONTRACT
    function kill() onlyOwner external {
        selfdestruct(payable(msg.sender));
    }
}
