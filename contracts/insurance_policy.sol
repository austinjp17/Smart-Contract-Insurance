pragma solidity ^0.8.0;

contract Insurance_Policy {

    //Contract Owner
    address payable public owner;

    //Beneficiary
    address payable public beneficiary;

    //Amt to payout on claim
    uint public payout_amount;

    // The time at which the policy expires
    uint public expirationTime;

    constructor(address payable _benficiary, uint _payout, uint _durationInDays){
        owner = payable(msg.sender);
        beneficiary = payable(_benficiary);
        payout_amount = _payout;
        expirationTime = block.timestamp + (_durationInDays * 1 days);
    }

    function payout() public {
        require(msg.sender == owner);
        beneficiary.transfer(payout_amount);
    }
}