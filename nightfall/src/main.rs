use ethers::{providers::{Http, Provider}};
use ethers::signers::LocalWallet;
use ethers::prelude::*;
use std::convert::TryFrom;
use rand;


fn main() {
    let provider = Provider::<Http>::try_from("http://localhost:8545").unwrap();
    let mut rng = &mut rand::thread_rng();
    let wallet = LocalWallet::new(&mut rng);
    // let signer  = wallet::SigningKey::connect(provider.clone()).await.unwrap();
}
