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

    //Funds Pool Address
    address fundPool;

    //Beneficiary
    address payable public beneficiary;

    //Amt to payout on claim
    uint public payout_amount;

    // The time at which the policy expires
    uint public expirationTime;

    // Claimed bool
    bool public claimed = false;

    constructor(uint _payout, uint _durationInDays){
        require(_durationInDays < 2**256 - 1, "Duration too long");

        owner = address(tx.origin);
        //owner is vendor who initiates policy creation
        //msg.sender = factory contract

        // beneficiary = payable(_beneficiary);
        payout_amount = _payout;
        expirationTime = block.timestamp + (_durationInDays * 1 days);
    }

    function payout() public {
        require(msg.sender == owner, "Not permissioned");
        require(block.timestamp < expirationTime, "Contact expired");
        require(claimed == false, "Contract has already paid out");

        claimed = true;

        //TODO: Allow beneficiary to access money
    }

    function recieveClaim() public payable returns(uint) {
        require(tx.origin == owner, "Must be the vendor who created the policy to issue claim");
        require(block.timestamp < expirationTime, "Contract Expired");
        require(claimed == false, "Policy can not be claimed twice");

        //!FIX!
        //TWO DEPOSITS THAT CUMULATIVELY SUM TO PAYOUT_AMOUNT 
        //WILL NOT FILL CONDITION
        // if(address(this).balance >= payout_amount){
        claimed=true;
        // }
        return(msg.value);
    }

    function getPayoutBalance() public view returns (uint){
        return(address(this).balance);
    }
}
