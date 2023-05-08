const { initial } = require("lodash");
const truffleAssert = require("truffle-assertions");



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
        
        deposit_amt = 6;
        //two deposits
        claim_amt = 10;
        policyDuration = 31;
        daysExtension = 5;
        vendorHC = 20;

        assert(owner, accounts[0], "Unexpected Owner")
    })

    beforeEach(async () => {
        // factoryInstance = await factory.deployed()
        
        // alice = accounts[0];
    });

    // Deposit Test: Recieve Function
    it("Deposit into Pool", async () => {
        
        //Get balance before
        const init_balance = await web3.eth.getBalance(factoryInstance.address)
        
        //Deposit
        await factoryInstance.sendTransaction({value: deposit_amt})
        
        //Get balance after
        const post_balance = await web3.eth.getBalance(factoryInstance.address)
        assert.equal(post_balance - init_balance, deposit_amt, "accounts don't match")
        // assert.equal(balance, deposit_amt, "Pool doesn't match deposit amount.")
    })

    //Deposit Test: Fallback Function
    it("Deposit into Pool: Fallback", async () => {
        
        //Get balance before
        const init_balance = await web3.eth.getBalance(factoryInstance.address)
        
        //Deposit
        await factoryInstance.sendTransaction({value: deposit_amt})
        
        //Get balance after
        const post_balance = await web3.eth.getBalance(factoryInstance.address)
        assert.equal(post_balance - init_balance, deposit_amt, "accounts don't match")
        // assert.equal(balance, deposit_amt, "Pool doesn't match deposit amount.")
    })

    //addVendor: random
    it("Outsider Adds Vendor", async () => {
        try {
            await factoryInstance.addVendor(bob, vendorHC, {from: alice});
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
        await factoryInstance.addVendor(alice, vendorHC)
        await factoryInstance.addVendor(bob, vendorHC)
        const actual = await factoryInstance.getVendors()

        assert.include(actual, alice, "Vendor should have been added")
        assert.include(actual, bob, "Vendor should have been added")
    })

    //removeVendor: Privleged User
    it("Privleged User Remove Vendor Fail", async () => {
        try{
            await factoryInstance.removeVendor(bob, {from: alice})
            assert.fail("Vendor removal by priviged user should fail")
        } catch (error) {
            assert.include(
                error.message,
                "revert",
                "Expected revert error"
                );}
            
        const vendorList = await factoryInstance.getVendors()
        assert.include(vendorList, bob, "Vendor should have been removed")
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
            await factoryInstance.addVendor(bob,vendorHC, {from: alice})
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
        newPolicy = await factoryInstance.createPolicy(claim_amt, claim_beneficiary, policyDuration);
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
        // balance = await web3.eth.getBalance(factoryInstance.address)
        
        policyAddr = (await factoryInstance.getVendorPolicies(owner))[0]
        policyInstance = await policy.at(policyAddr)
        claim_amt = await (await policy.at(policyAddr)).payout_amount()
        // console.log("CLAIM:",claim_amt)
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

        await factoryInstance.sendTransaction({value:30})
        await factoryInstance.sendTransaction({value:20})
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
    it("Second Policy Extension Failure", async () => {

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

    it("Gas Cost Estimation:", async () => {

        const factoryCost = await factory.new.estimateGas([owner], [vendorHC])
        // console.log("Factory Creation Gas Estimate:",factoryCost)
        

        const policyCost = await factoryInstance.createPolicy.estimateGas(claim_amt, claim_beneficiary, policyDuration)
        // console.log("Create Policy Gas Cost:",policyCost)
    })

    it("Change Vendor Haircut", async () => {
        new_HC = 42
        init_HC = Number((await factoryInstance.allowedCreators(alice)).premiumHaircut)
        await factoryInstance.setHaircut(alice, new_HC)

        post_HC = Number((await factoryInstance.allowedCreators(alice)).premiumHaircut)
        assert.equal(post_HC, new_HC, "Expected haircut to be changed.")
    })

    //Kill: Unprivleged
    it("Contract Self Destruct: Unprivleged fail", async () => {
        // Get initial balances
        init_code = await web3.eth.getCode(factoryInstance.address);
        assert.notEqual(init_code, '0x', "No contract code found initally")
        truffleAssert.reverts(factoryInstance.kill({from: alice}))
        
    });

    //Kill: Owner
    it("Contract Self Destruct: Owner", async () => {
        // Get initial balances
        init_code = await web3.eth.getCode(factoryInstance.address);
        assert.notEqual(init_code, '0x', "No contract code found initally")
        await factoryInstance.kill()
        assert.equal(await web3.eth.getCode(factoryInstance.address), "0x", "Contract not killed")
    });

});