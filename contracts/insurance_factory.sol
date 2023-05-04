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


import "./insurance_policy.sol";
pragma solidity ^0.8.0;


contract Insurance_Factory {

    address public owner;
    
    address[] allowedCreatorsList;
    mapping (address => bool) allowedCreators;
    mapping (address => Insurance_Policy[]) CreatorsPolicyMap;

    constructor(address[] memory _allowedCreators) {
        owner = msg.sender;
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
    function getPoolBalance() public view returns (uint){
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
        assert(address(this).balance > claimAmt);
        assert(claimPaid == false);

        // SEND PAYOUT TO BENEFICIARY
        // Insurance_Policy(claimAddr).recieveClaim{value:claimAmt}();
        // Insurance_Policy(claimAddr).setClaimed();
        //!? Send to beneficiary instead of policy contract? 
        beneficiary.transfer(claimAmt);

        // UPDATE POLICY CLAIMED STATE
        Insurance_Policy(claimAddr).setClaimed();
    }

    //CREATE POLICY
    function createPolicy(uint _payoutAmt, address payable _beneficiary) checkVendor public returns(address) {
        Insurance_Policy newPolicy = new Insurance_Policy(
            _payoutAmt,
            _beneficiary,
            31);
        CreatorsPolicyMap[msg.sender].push(newPolicy);
        return(address(newPolicy));
    }


    
}