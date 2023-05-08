use ethers::{providers::{Http, Provider}};
use ethers::prelude::*;
use ethers::abi;
use ethers::contract::{Contract, EthEvent};

use ethers_core::{abi::Abi, types::{Address, U256, H160}};
use tokio::sync::futures;

use std::{convert::TryFrom, io::Read};
use std::fs::File;
use std::sync::Arc;
use std::rc::Rc;
use std::fmt::Debug;

use serde_json::{self, Number, Value};

pub struct NFEvent<T: Debug + Clone + EthEvent> {
	pub event: T,
	pub handler: Box<dyn FnMut(T)>,
}

pub struct NFContract<T: Debug + Clone + EthEvent, P: ProviderExt + Middleware + Clone> 
{
	pub contract_addr: Address,
	pub abi: Abi,
	pub provider: Rc<P>,
	pub contract_instance: Contract<P>,
	pub events: Vec<NFEvent<T>>,
}

impl<T, P> NFContract<T, P> 
where 
	T : Debug + Clone + EthEvent,
	P : ProviderExt + Middleware + Clone,
{
	pub async fn new(contract_addr: Address, abi: Abi, provider: P) -> Result<Self, Box<dyn std::error::Error>> {
		let contract_instance = Contract::new(contract_addr, abi.clone(), Arc::new(provider.clone()));
		Ok(Self {
			contract_addr,
			abi,
			provider: Rc::new(provider),
			contract_instance,
			events: Vec::new(),
		})
	}

	pub fn add_event_listener(&mut self, event: T, handler: Box<dyn FnMut(T)>) {
		self.events.push(NFEvent {
			event,
			handler,
		});
	}
	

	pub fn add_event(&mut self, event: NFEvent<T>) {
		self.events.push(event);
	}
}

#[cfg(test)]
