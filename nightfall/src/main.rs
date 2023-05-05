use ethers::{providers::{Http, Provider}};
use ethers::prelude::*;
use ethers::abi;
use ethers::contract::{Contract, EthEvent};

use ethers_core::{abi::Abi, types::{Address, U256, H160}};
use tokio::sync::futures;

use std::{convert::TryFrom, io::Read};
use std::fs::File;
use std::sync::Arc;

use serde_json::{self, Number, Value};

const factory_contract_addr : &str = "0xdf5dA1d9e2A5cEC8550eEe3705Bd8c68eD771656";

/// This event is generated by the contract when the value is changed.
/// For `simple_storage.sol`, this corresponds to the `ValueChanged` event.
#[derive(Debug, Clone, EthEvent)]
pub struct ValueChanged {
    pub new_value: U256,
}

async fn accounts(provider: &Provider<Http>) -> Result<Vec<H160>, Box<dyn std::error::Error>> {
    let accounts = provider.get_accounts().await?;
    for account in &accounts {
        println!("Account: {}", account);
    }
    Ok(accounts)
}


async fn event_test(provider: &Provider<Http>, abi: &Abi) -> Result<(), Box<dyn std::error::Error>> {
    let contract_addr = match factory_contract_addr.parse::<Address>() {
        Ok(addr) => addr,
        Err(e) => panic!("Unable to parse address: {:?}", e),
    };
    println!("Contract address: {:?}", contract_addr);

    let contract = Contract::new(contract_addr, abi.clone(), Arc::new(provider));

    let call = contract.event::<ValueChanged>();
    println!("Event: {:?}", call);

    Ok(())
}

fn load_abi() -> Result<Abi, Box<dyn std::error::Error>> {
    println!("ABI:");
    let mut file = File::open("/home/preston/DEV/Smart-Contract-Insurance/build/contracts/SimpleStorage.json")?;
    let mut file_str = String::new();
    file.read_to_string(&mut file_str);

    let mut contract_json = serde_json::from_str::<Value>(&file_str).unwrap();

    let abi: Abi = serde_json::from_value(contract_json["abi"].take()).unwrap();
    // println!("ABI: {:?}", abi);
    Ok(abi)
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
    let abi: Abi = load_abi().unwrap();
    let ret = event_test(&provider, &abi).await;
}
