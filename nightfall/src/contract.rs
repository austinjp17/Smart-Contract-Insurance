use ethers::{providers::{Http, Provider}};
use ethers::prelude::*;
use ethers::abi;
use ethers::contract::{Contract, EthEvent};

use ethers_core::{abi::Abi, types::{Address, U256, H160}};
use ethers_contract::*;
use tokio::sync::futures;

// use core::abi::Event;
use std::{convert::TryFrom, io::Read};
use std::fs::File;
use std::sync::Arc;
use std::rc::Rc;
use std::fmt::Debug;

use serde_json::{self, Number, Value};



pub struct NFEvent {
	pub name: String,
	pub event: ethers_contract::Event,
	pub handler: Box<dyn FnMut(String, Event)>,
}

pub struct NFContract {
	pub contract_addr: Address,
	pub abi: Abi,
	pub contract_instance: Contract<Provider<Http>>,
	pub events: Vec<NFEvent>,
}

impl NFContract {
	pub fn new(contract_addr: Address, abi: Abi, provider: &Provider<Http>) -> Result<Self, Box<dyn std::error::Error>> {
		let contract_instance = Contract::new(contract_addr, abi.clone(), Arc::new(provider.clone()));
		Ok(Self {
			contract_addr,
			abi,
			contract_instance,
			events: Vec::new(),
		})
	}

	pub fn add_event_listener<T: EthEvent>(&mut self, event_name: String, event: T, handler: Box<dyn FnMut(T)>) {
		let event_filter = self.contract_instance.event::<T>();
		self.events.push(NFEvent {
			name: event_name.clone(),
			event: event_filter,
			handler,
		});
	}
	
	pub async fn event_stream(&mut self) -> Result<(), Box<dyn std::error::Error>> {
		let mut event_stream = event_filter.stream().await.unwrap();
		while let Some(Ok(event)) = event_stream.next().await {
			// println!("event_stream() Event: {:?}", event);
			println!("Some kinda event happened!");
			// for nf_event in &mut self.events {
			// 	if event == nf_event.event {
			// 		(nf_event.handler)(event.clone());
			// 	}
			// }
		}
		Ok(())
	}
}
