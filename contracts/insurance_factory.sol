/*   SPDX-License-Identifier: GPL-3.0-or-later
 *   Copyright (C) Nightfall.
 *   Permission is granted to copy, distribute and/or modify this document
 *   under the terms of the GNU Free Documentation License, Version 1.3
 *   or any later version published by the Free Software Foundation;
 *   with no Invariant Sections, no Front-Cover Texts, and no Back-Cover Texts.
 *   A copy of the license is included in the section entitled "GNU
 *   Free Documentation License".
 */


import "./insurance_policy.sol";
pragma solidity ^0.8.0;


contract Insurance_Factory {

    address public owner;

    uint public premiumHaircut;
    
    address[] allowedCreatorsList;
    mapping (address => bool) allowedCreators;
    mapping (address => Insurance_Policy[]) CreatorsPolicyMap;

    constructor(address[] memory _allowedCreators, uint _premiumHaircut) {
        owner = msg.sender;

        premiumHaircut = _premiumHaircut;
        //Initalize Allowed Creator Structures
        for (uint i = 0; i < _allowedCreators.length; i++) {

            //add address to key list
            allowedCreatorsList.push(_allowedCreators[i]);

            // add address to key mapping
            allowedCreators[_allowedCreators[i]] = true;

            // add key to creator claims map
            CreatorsPolicyMap[_allowedCreators[i]] = new Insurance_Policy[](0);
        }
    }

    //MODIFIERS

    modifier onlyOwner(){
        // factory owner only
        require(msg.sender == owner,
        "This function may only be called by the owners");
        _;
    }

    modifier checkVendor() {
        // approved vendor or factory owner
        require(allowedCreators[msg.sender] == true || msg.sender == owner, 
        "Not a permission Vendor or owner");
        _;
    }

    //FUNCTIONS

    //Funds Pool Interaction Functions
    function getPoolBalance() onlyOwner public view returns (uint){
        return(address(this).balance);
    }

    function poolDeposit() payable public returns(uint256) {
        return(msg.value);
    }
    
    //Vendor Interaction Functions
    function getVendorPolicies(address creator) onlyOwner public view returns(Insurance_Policy[] memory) {
        return(CreatorsPolicyMap[creator]);
    } 

    function getVendors() public view returns (address[] memory) {
        return allowedCreatorsList;
    }

    function addVendor(address creator) onlyOwner public {
        allowedCreatorsList.push(creator);
        allowedCreators[creator] = true;
        CreatorsPolicyMap[creator] = new Insurance_Policy[](0);
    }

    //TODO: HANDLE OPEN POLICIES OF REMOVED CREATORS
    function removeVendor(address creator) onlyOwner public {
        allowedCreators[creator] = false;
        delete CreatorsPolicyMap[creator];

        for (uint i = 0; i < allowedCreatorsList.length; i++) {
            if (allowedCreatorsList[i] == creator) {
                allowedCreatorsList[i] == allowedCreatorsList[allowedCreatorsList.length - 1];
            }
        }
        allowedCreatorsList.pop();
    }

    //PAY CLAIM
    function payClaim(address payable claimAddr) public {
        // can only be called by the vendor who originated the contract

        // GET POLICY INFO
        uint claimAmt = Insurance_Policy(claimAddr).payout_amount();
        bool claimPaid = Insurance_Policy(claimAddr).claimed();
        address policyOriginator = Insurance_Policy(claimAddr).owner();
        address payable beneficiary = Insurance_Policy(claimAddr).beneficiary();
        
        // CHECKS
        assert(policyOriginator == msg.sender);
        // assert(address(this).balance > claimAmt);
        assert(claimPaid == false);

        if(address(this).balance < claimAmt) {

        }

        // SEND PAYOUT TO BENEFICIARY
        // Insurance_Policy(claimAddr).recieveClaim{value:claimAmt}();
        // Insurance_Policy(claimAddr).setClaimed();
        //!? Send to beneficiary instead of policy contract? 
        beneficiary.transfer(claimAmt);

        // UPDATE POLICY CLAIMED STATE
        // Insurance_Policy(claimAddr).setClaimed();
    }

    //CREATE POLICY
    function createPolicy(
        uint productPrice, 
        address payable _beneficiary, 
        uint8 _durationInDays 
        ) 
            checkVendor public returns(address) {
        uint coverage = (premiumHaircut*productPrice)/10;
        Insurance_Policy newPolicy = new Insurance_Policy(
            coverage,
            _beneficiary,
            _durationInDays,
            owner);
        CreatorsPolicyMap[msg.sender].push(newPolicy);
        return(address(newPolicy));
    }


    
}