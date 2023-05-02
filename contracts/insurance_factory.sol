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

import "./insurance_policy.sol";

contract Insurance_Factory {

    address owner;

    uint poolBalance = 0;
    
    address[] allowedCreatorsList;
    mapping (address => bool) allowedCreators;
    mapping (address => Insurance_Policy[]) CreatorsPolicyMap;

    constructor(address[] memory _allowedCreators) {
        //Initalize Allowed Creator Structures
        for (uint i = 0; i < _allowedCreators.length; i++) {
            owner = msg.sender;

            //add address to key list
            allowedCreatorsList.push(_allowedCreators[i]);

            // add address to key mapping
            allowedCreators[_allowedCreators[i]] = true;

            // add key to creator claims map
            CreatorsPolicyMap[_allowedCreators[i]] = new Insurance_Policy[](0);
        }

        //Create Insurance Pool Contract
        // pool = new Insurance_Pool(allowedCreatorsList);
    }

    //MODIFIERS

    modifier checkOwner(){
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

    //Pool Interaction Functions
    function getPoolBalance() public view returns (uint){
        return(address(this).balance);
    }

    function poolDeposit() payable public returns(uint256) {
        poolBalance += msg.value;
        return(msg.value);
    }

    function poolWithdraw(uint amount) checkVendor external {
        poolBalance -= amount;
        require(address(this).balance > amount, "Not enough to cover claim");
        payable(msg.sender).transfer(amount);

    }

    
    //Vendor Interaction Functions
    function getVendorPolicies(address creator) public view returns(Insurance_Policy[] memory) {
        return(CreatorsPolicyMap[creator]);
    } 

    function getVendors() public view returns (address[] memory) {
        return allowedCreatorsList;
    }

    function addVendor(address creator) checkOwner public {
        allowedCreatorsList.push(creator);
        allowedCreators[creator] = true;
        CreatorsPolicyMap[creator] = new Insurance_Policy[](0);
    }

    //Create Policy
    function createPolicy() checkVendor public returns(address) {
        Insurance_Policy newPolicy = new Insurance_Policy(1, 31);
        CreatorsPolicyMap[msg.sender].push(newPolicy);
        return(address(newPolicy));
    }


    
}