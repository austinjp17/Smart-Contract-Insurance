/*   SPDX-License-Identifier: GPL-3.0-or-later
 *   Copyright (C) Nightfall.
 *   Permission is granted to copy, distribute and/or modify this document
 *   under the terms of the GNU Free Documentation License, Version 1.3
 *   or any later version published by the Free Software Foundation;
 *   with no Invariant Sections, no Front-Cover Texts, and no Back-Cover Texts.
 *   A copy of the license is included in the section entitled "GNU
 *   Free Documentation License".
 */
 
pragma solidity ^0.8.0;

contract Insurance_Policy {

    //Contract Owner
    address public owner;

    //Factory Owner
    address public factoryOwner;

    //Beneficiary
    address payable public beneficiary;

    //Amt to payout on claim
    uint public payout_amount;

    // The time at which the policy expires
    uint public expirationTime;

    // Claimed bool
    bool public claimed = false;

    // Duration extended bool
    uint8 public extensions = 0;

    constructor(uint _payout, address payable _beneficiary, uint8 _durationInDays, address _factoryOwner){
        require(_durationInDays < 2**8 - 1, "Duration too long");
        factoryOwner = _factoryOwner;
        owner = address(tx.origin);
        //owner is vendor who initiates policy creation
        //msg.sender = factory contract

        beneficiary = payable(_beneficiary);
        payout_amount = _payout;
        expirationTime = block.timestamp + (_durationInDays * 1 days);
    }

    function setClaimed() public {
        claimed = true;
    }

    function extendDuration(uint8 extentionInDays) public {
        require(extentionInDays < 2**8 - 1, "Duration too long");
        
        //Restricted to factoryOwner calls if expired
        if(block.timestamp < expirationTime){
            assert(msg.sender == owner || msg.sender == factoryOwner);
        } else {
            assert(msg.sender == factoryOwner);
        }
        
        //3 extensions allowed
        assert(extensions < 1);


        expirationTime += (extentionInDays * 1 days);
        extensions += 1;
    }


}