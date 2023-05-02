// const { default: Accounts } = require("web3-eth-accounts");

const factory = artifacts.require("Insurance_Factory");
//assert.equal(actual, expected)
contract("factory", () => {

    

    before(async () => {
        factoryInstance = await factory.deployed()
        accounts = await web3.eth.getAccounts();
        alice = accounts[1]
        bob = accounts[2]
    })

    beforeEach(async () => {
        // factoryInstance = await factory.deployed()
        owner = await factoryInstance.owner.call()
        // alice = accounts[0];
    });

    // Deposit Test
    it("Deposit into Pool", async () => {
        const deposit_amt = 30;
        
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

    //


});