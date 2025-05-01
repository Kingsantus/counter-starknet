// import library
use snforge_std::{declare, DeclareResultTrait, ContractClassTrait };
use starknet::ContractAddress;

const ZERO_COUNT: u32 = 0;

fn OWNER() -> ContractAddress {
    'OWNER'.try_into().unwrap();
}

// util deploy function
fn __deploy__() {
    // declare
    let contract_class = declare("Counter").unwrap().contract_class();
    // serialize constructor
    let mut calldata: Array<felt252> = array![];
    ZERO_COUNT.serialize(ref calldata);
    OWNER().serialize(ref calldata);
    // deploy contract
    contract_class.deploy(@calldata).expect('Failed to deploy contract');
}