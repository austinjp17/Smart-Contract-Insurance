use ethers::{providers::{Http, Provider}};
use ethers::signers::LocalWallet;
use ethers::prelude::*;
use ethers::abi::Contract;
use ethers::abi;
use std::convert::TryFrom;
use std::fs::File;
use rand;

struct Insurance_Factory {
    address: Address,
}

const factory_contract_addr : &str = "0x886280e7f3b366c9d40e59628114ce63c7038587a19c2c674eef6bc28e0be3f0";

async fn accounts(provider: &Provider<Http>) -> Result<(), Box<dyn std::error::Error>> {
    let accounts = provider.get_accounts().await?;
    println!("Accounts: {:?}", accounts);
    Ok(())
}

async fn get_contract(provider: &Provider<Http>) -> Result<(), Box<dyn std::error::Error>> {
    let json_abi = match File::open("/home/preston/DEV/Smart-Contract-Insurance/build/contracts/Insurance_Factory.json") {
        Ok(file) => file,
        Err(e) => panic!("Unable to open file: {:?}", e),
    };

    let abi = match Contract::load(json_abi) {
        Ok(abi) => abi,
        Err(e) => panic!("Unable to load ABI: {:?}", e),
    };
    println!("ABI: {:?}", abi);
    Ok(())
}

async fn event_test(provider: &Provider<Http>) -> Result<(), Box<dyn std::error::Error>> {
    let contract_addr = match factory_contract_addr.parse::<Address>() {
        Ok(addr) => addr,
        Err(e) => panic!("Unable to parse address: {:?}", e),
    };
    
    let contract = Contract::from_json

    Ok(())
}


// async fn test_transaction(provider: &Provider<Http>) -> Result<(), Box<dyn std::error::Error>> {
//     let accounts = provider.get_accounts().await?;
//     let wallet = LocalWallet::new(&mut rand::thread_rng());
//     let client = SignerMiddleware::new(provider, wallet);
//     let tx = TransactionRequest::new().to(accounts[1]).value(10000);
//     let pending_tx = client.send_transaction(tx, None).await?;
//     println!("Pending transaction: {:?}", pending_tx);
//     Ok(())
// }

#[tokio::main]
async fn main() {
    let provider = Provider::<Http>::try_from("http://localhost:8545").unwrap();
    let get_contract = get_contract(&provider).await;
}
