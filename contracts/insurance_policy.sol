/* This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <https://www.gnu.org/licenses/>.
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

    function recieveClaim() public payable returns(uint) {
        require(tx.origin == owner, "Must be the vendor who created the policy to issue claim");
        require(block.timestamp < expirationTime, "Contract Expired");
        require(claimed == false, "Policy can not be claimed twice");

        //!FIX?
        //TWO DEPOSITS THAT CUMULATIVELY SUM TO PAYOUT_AMOUNT 
        //WILL NOT FILL CONDITION
        // if(address(this).balance >= payout_amount){
        claimed=true;
        // }

        //TODO: Allow beneficiary access to money
        return(msg.value);
    }

    function getPayoutBalance() public view returns (uint){
        return(address(this).balance);
    }
}