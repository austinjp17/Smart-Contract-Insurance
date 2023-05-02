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
    address payable public owner;

    //Beneficiary
    address payable public beneficiary;

    //Amt to payout on claim
    uint public payout_amount;

    // The time at which the policy expires
    uint public expirationTime;

    // Claimed bool
    bool public claimed = false;

    constructor(uint _payout, uint _durationInDays){
        owner = payable(msg.sender);
        // beneficiary = payable(_benficiary);
        payout_amount = _payout;
        expirationTime = block.timestamp + (_durationInDays * 1 days);
    }

    function payout() public {
        require(msg.sender == owner);
        require(block.timestamp < expirationTime);
        claimed = true;

        //TODO: Deposit money into contract

        //TODO: Allow beneficiary to access money
    }
}