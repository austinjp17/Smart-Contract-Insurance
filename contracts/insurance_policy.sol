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