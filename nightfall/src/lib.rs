mod contract;
pub use contract::NFContract;

use std::{convert::TryFrom, io::Read};
use std::fs::File;
use std::sync::Arc;

use ethers::{providers::{Http, Provider}};
use ethers::prelude::*;
use ethers_core::{abi::Abi, types::{Address, U256, H160}};

use serde_json::{self, Number, Value};
use std::fmt::Debug;



const factory_contract_addr : &str = "0x633F543Df238e88E41cd6E660223C76788158371";

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

fn contract_listen_to_events() {
    let provider = Provider::<Http>::try_from("http://localhost:8545").unwrap();

    let contract_addr = match factory_contract_addr.parse::<Address>() {
        Ok(addr) => addr,
        Err(e) => panic!("Unable to parse address: {:?}", e),
    };
    println!("Contract address: {:?}", contract_addr);	

    let abi: Abi = load_abi().unwrap();
	let nf_contract = NFContract::new(contract_addr, abi, &provider);



	assert_eq!(4, 4);
}


#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn contract_listen_to_events() {

    }
}
