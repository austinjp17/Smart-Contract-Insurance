// const { default: Accounts } = require("web3-eth-accounts");

const factory = artifacts.require("Insurance_Factory");
const policy = artifacts.require("Insurance_Policy");
//assert.equal(actual, expected)
contract("factory", () => {

    

    before(async () => {
        factoryInstance = await factory.deployed()
        accounts = await web3.eth.getAccounts();
        
        alice = accounts[1]
        bob = accounts[2]
        claim_beneficiary = accounts[3]
        owner = await factoryInstance.owner.call()
        
        deposit_amt = 30;
        claim_amt = 5;
    })

    beforeEach(async () => {
        // factoryInstance = await factory.deployed()
        
        // alice = accounts[0];
    });

    // Deposit Test
    it("Deposit into Pool", async () => {
        
        //Get balance before
        const init_balance = (await factoryInstance.getPoolBalance()).words[0]
        
        //Deposit
        await factoryInstance.poolDeposit({value: deposit_amt})
        
        //Get balance after
        const post_balance = (await factoryInstance.getPoolBalance()).words[0]
        assert.equal(post_balance - init_balance, deposit_amt, "accounts don't match")
        // assert.equal(balance, deposit_amt, "Pool doesn't match deposit amount.")
    })

    //addVendor: random
    it("Outsider Adds Vendor", async () => {
        try {
            await factoryInstance.addVendor(bob, {from: alice});
            assert.fail("Commoner Add Vendor Error");
        } catch (error) {
            assert.include(
                error.message,
                "revert",
                "Expected revert error"
            );
        }
        const actual = await factoryInstance.getVendors()
        assert.notInclude(actual, alice, "Vendor shouldn't have been added")
    })

    //addVendor: Owner
    it("Owner Add Vendor", async () => {
        await factoryInstance.addVendor(alice)
        const actual = await factoryInstance.getVendors()

        assert.include(actual, alice, "Vendor should have been added")
    })

    //addVendor: Privliged Vendor
    it("Privaleged Vendor CAN'T add Vendor", async () => {
        try {
            await factoryInstance.addVendor(bob, {from: alice})
            assert.fail("Commoner Add Vendor Error");
        } catch (error) {
            assert.include(
                error.message,
                "revert",
                "Expected revert error"
            );
        }
        const actual = await factoryInstance.getVendors()

        assert.notInclude(actual, bob, "Vendor shouldn't be added")
    })

    //Create Policy: Owner
    it("Owner Policy Creation", async () => {
        await factoryInstance.createPolicy(claim_amt);
        policyAddr = (await factoryInstance.getVendorPolicies(owner))[0]
        actualPolicies = await factoryInstance.getVendorPolicies(owner)
        assert.include(actualPolicies, policyAddr, "Policy not found in owners policies")
        assert.equal(actualPolicies.length, 1, "Array doesn't contain 1 element")
    })

    //Create Policy: Privilged User
    it("Priviliged Vendor Policy Creation", async () => {
        
        await factoryInstance.createPolicy(claim_amt, {from: alice});
        policyAddr = (await factoryInstance.getVendorPolicies(alice))[0]
        
        
        actualPolicies = await factoryInstance.getVendorPolicies(alice)
        assert.include(actualPolicies, policyAddr, "Policy not found in owners policies")
        assert.equal(actualPolicies.length, 1, "Array doesn't contain 1 element")
    })

    //Create Policy: Common User
    it("Common User Policy Creation", async () => {
        
        try{
            await factoryInstance.createPolicy(claim_amt, {from: bob});
            assert.fail("Unprivilaged User can't create policy.")
            policyAddr = (await factoryInstance.getVendorPolicies(alice))[0]
        } catch (error) {
            assert.include(
                error.message,
                "revert",
                "Expected revert error"
            );
        }
    })

    //Can Pay Test Claim
    it("Pool Balance Covers Claim", async () => {
        policyAddr = (await factoryInstance.getVendorPolicies(owner))[0]
        policyInstance = await policy.at(policyAddr)

        policyAmt = (await policyInstance.payout_amount()).words[0]
        factoryBal = (await factoryInstance.getPoolBalance()).words[0]
        assert(policyAmt < factoryBal, "Can't payout test claim")
    })

    // Pay Claim: Owner
    it("Pay Test Claim", async () => {
        policyAddr = (await factoryInstance.getVendorPolicies(owner))[0]
        policyInstance = await policy.at(policyAddr)

        const init_balance = await web3.eth.getBalance(policyAddr)

        await factoryInstance.payClaim(policyAddr)

        const finalBalance = await web3.eth.getBalance(policyAddr)

        policyBal = (await policyInstance.getPayoutBalance()).words[0]
        assert.equal(finalBalance - init_balance, claim_amt, "Amount sent doesn't match claim amount")
    })

    //Attempt to pay out same claim
    it("Twice Claimed Policy", async () => {
        policyAddr = (await factoryInstance.getVendorPolicies(owner))[0]
        policyInstance = await policy.at(policyAddr)

        try{
            await factoryInstance.payClaim(policyAddr)
            assert.fail("Shouldn't be able to send 2nd claim request for same policy")
        } catch (error) {
            assert.include(
                error.message,
                "revert",
                "Expected revert error"
            );
        }
    })


});