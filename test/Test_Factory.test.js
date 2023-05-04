// const { default: Accounts } = require("web3-eth-accounts");

const factory = artifacts.require("Insurance_Factory");
const policy = artifacts.require("Insurance_Policy");
//assert.equal(actual, expected)
contract("factory", () => {

    

    before(async () => {
        factoryInstance = await factory.deployed()
        policyInstance = await policy.deployed()
        accounts = await web3.eth.getAccounts();
        
        alice = accounts[1]
        bob = accounts[2]
        claim_beneficiary = accounts[3]
        owner = await factoryInstance.owner.call()
        
        deposit_amt = 12;
        claim_amt = 10;
        policyDuration = 31;
        daysExtension = 5;
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
        await factoryInstance.addVendor(bob)
        const actual = await factoryInstance.getVendors()

        assert.include(actual, alice, "Vendor should have been added")
        assert.include(actual, bob, "Vendor should have been added")
    })

    //removeVendor: Owner
    it("Owner Remove Vendor", async () => {
        await factoryInstance.removeVendor(bob)
        const actual = await factoryInstance.getVendors()

        assert.notInclude(actual, bob, "Vendor should have been removed")
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

    //removeVendor: Privliged Vendor
    it("Privliged Vendor CAN'T Remove Vendor", async () => {
        try {
            await factoryInstance.removeVendor(alice, {from:alice})
            assert.fail("Vendor shouldn't be removed")
        } catch (error) {
            assert.include(
                error.message,
                "revert",
                "Expected revert error"
            );
        }
        const actual = await factoryInstance.getVendors()

        assert.notInclude(actual, bob, "Vendor should have been removed")
    })

    //Create Policy: Owner
    it("Owner Policy Creation", async () => {
        await factoryInstance.createPolicy(claim_amt, claim_beneficiary, policyDuration);
        policyAddr = (await factoryInstance.getVendorPolicies(owner))[0]
        actualPolicies = await factoryInstance.getVendorPolicies(owner)
        assert.include(actualPolicies, policyAddr, "Policy not found in owners policies")
        assert.equal(actualPolicies.length, 1, "Array doesn't contain 1 element")
    })

    //Create Policy: Privilged User
    it("Priviliged Vendor Policy Creation", async () => {
        
        await factoryInstance.createPolicy(claim_amt,claim_beneficiary, 5, {from: alice});
        policyAddr = (await factoryInstance.getVendorPolicies(alice))[0]
        
        
        actualPolicies = await factoryInstance.getVendorPolicies(alice)
        assert.include(actualPolicies, policyAddr, "Policy not found in owners policies")
        assert.equal(actualPolicies.length, 1, "Array doesn't contain 1 element")
    })

    //Create Policy: Common User
    it("Common User CAN'T Create Policy", async () => {
        
        try{
            await factoryInstance.createPolicy(claim_amt, claim_beneficiary, policyDuration,{from: bob});
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

    // Pay Claim: Owner
    it("Owner Pay Claim", async () => {
        policyAddr = (await factoryInstance.getVendorPolicies(owner))[0]
        policyInstance = await policy.at(policyAddr)
        haircut = await factoryInstance.premiumHaircut()
        claim_amt = (claim_amt * haircut)/10

        const beneficiary = await policyInstance.beneficiary()
        assert.equal(beneficiary, claim_beneficiary, "Unexpected beneficiary")
        
        const init_balance = BigInt(await web3.eth.getBalance(claim_beneficiary))
        
        await factoryInstance.payClaim(policyAddr)

        const finalBalance = BigInt(await web3.eth.getBalance(claim_beneficiary))
        
        const difference = finalBalance - init_balance

        assert.equal(Number(difference), claim_amt, "Amount sent doesn't match claim amount")
    })

    //Attempt to pay out same claim
    it("Twice Claimed Policy Failure", async () => {
        policyAddr = (await factoryInstance.getVendorPolicies(owner))[0]
        policyInstance = await policy.at(policyAddr)

        try {
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

    //Paying claim in seperate deposits
    it("Split Deposit Claim Payment", async () => {
        await factoryInstance.createPolicy(50, claim_beneficiary, policyDuration);
        policyAddr = (await factoryInstance.getVendorPolicies(owner))[1]
        policyInstance = await policy.at(policyAddr)

        await factoryInstance.poolDeposit({value:30})
        await factoryInstance.poolDeposit({value:20})
        await factoryInstance.payClaim(policyAddr)

    })

    //Vendor calls different vendor claim
    it("Cross-Vendor Claim Call Failue", async () => {
        await factoryInstance.createPolicy(100, claim_beneficiary, policyDuration,{from: alice})
        // alices 2nd claim created

        policyAddr = (await factoryInstance.getVendorPolicies(alice))[1]
        policyOriginator = await (await policy.at(policyAddr)).owner()
        assert.notEqual(policyOriginator, owner, "Someone other than originator should call for claim")
        // assert.equal(1, policyOriginator, "?")
        try {
            await factoryInstance.payClaim(policyAddr, {from: owner})
            assert.fail("Shouldn't issue claim")
        } catch(error) {
            assert.include(
                error.message,
                "revert",
                "Expected revert error"
            );
        }

    })

    //First Policy Extension
    it("First Policy Extension", async () => {

        const init_expiration = await policyInstance.expirationTime()
        await policyInstance.extendDuration(daysExtension);
        const first_expiration = await policyInstance.expirationTime()

        const dayDifference = (first_expiration - init_expiration)/86400

        assert.equal(dayDifference, daysExtension)
    })

    
    // //Second Policy Extension
    // it("Second Policy Extension From Originator", async () => {
    //     const originator = await policyInstance.owner()
    //     const init_expiration = await policyInstance.expirationTime()
    //     await policyInstance.extendDuration(daysExtension, {from: originator});
    //     const first_expiration = await policyInstance.expirationTime()

    //     const dayDifference = (first_expiration - init_expiration)/86400

    //     assert.equal(dayDifference, daysExtension)
    // })

    // //Third Policy Extension
    // it("Third Policy Extension", async () => {

    //     const init_expiration = await policyInstance.expirationTime()
    //     await policyInstance.extendDuration(daysExtension);
    //     const first_expiration = await policyInstance.expirationTime()

    //     const dayDifference = (first_expiration - init_expiration)/86400

    //     assert.equal(dayDifference, daysExtension)
    // })

    //Fourth Policy Extensio:
    it("Fourth Policy Extension Failure", async () => {

        try {
            await policyInstance.extendDuration(daysExtension);
            assert.fail("4th Policy Extension should fail")

        } catch (error) {
            assert.include(
                error.message,
                "revert",
                "Expected revert error"
            );
        } 
    })


});