//SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.0;

contract Insurance_Policy {

    //Contract Owner
    address public owner;

    //Factory Owner
    address public factoryOwner;

    //Beneficiary
    address payable public beneficiary;

    //Amt to payout on claim
    uint16 public payout_amount;

    // The time at which the policy expires
    uint public expirationTime;

    // Claimed bool
    bool public claimed = false;

    // Duration extended bool
    uint8 public extensions = 0;

    constructor(uint16 _payout, address payable _beneficiary, uint8 _durationInDays, address _factoryOwner){
        require(_durationInDays < 2**8 - 1, "Duration too long");
        require(_payout < 2**16 - 1, "Payout too high");

        factoryOwner = _factoryOwner;
        owner = address(tx.origin);
        //owner is vendor who initiates policy creation
        //msg.sender = factory contract

        beneficiary = payable(_beneficiary);
        payout_amount = _payout;
        expirationTime = block.timestamp + (_durationInDays * 1 days);
    }

    function setClaimed() external {
        claimed = true;
    }

    function extendDuration(uint8 extentionInDays) external {
        //1 extensions allowed
        assert(extensions < 1);

        require(extentionInDays < 2**8 - 1, "Duration too long");
        
        //Restricted to factoryOwner calls if expired
        if(block.timestamp < expirationTime){
            assert(msg.sender == owner || msg.sender == factoryOwner);
        } else {
            assert(msg.sender == factoryOwner);
        }
        
        


        expirationTime += (extentionInDays * 1 days);
        extensions += 1;
    }


}