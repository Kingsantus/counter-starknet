// import library
use snforge_std::{declare, DeclareResultTrait, ContractClassTrait };
use starknet::ContractAddress;
use contracts::interface::counter::{ICounter, ICounterDispatcher, ICounterDispatcherTrait };
use openzeppelin_access::ownable::interface::{IOwnableDispatcher, IOwnableDispatcherTrait};

const ZERO_COUNT: u32 = 0;

// test account
fn OWNER() -> ContractAddress {
    'OWNER'.try_into().unwrap()
}

// util deploy function
fn __deploy__(init_value: u32) -> ( ICounterDispatcher, IOwnableDispatcher ) {
    // declare
    let contract_class = declare("Counter").unwrap().contract_class();
    // serialize constructor
    let mut calldata: Array<felt252> = array![];
    init_value.serialize(ref calldata);
    OWNER().serialize(ref calldata);
    // deploy contract
    let (contract_address, _ ) = contract_class.deploy(@calldata).expect('Failed to deploy contract');
    // initialize contract address to Counter
    let counter = ICounterDispatcher { contract_address: contract_address };
    let ownable = IOwnableDispatcher { contract_address: contract_address };
    (counter, ownable)
}

#[test]
fn test_counter_deployment() {
    let ( counter, ownable ) = __deploy__(0);
    let count_1 = counter.get_counter();
    // check if the initial value is 0
    assert(count_1 == ZERO_COUNT, 'count not set');
    assert(ownable.owner() == OWNER(), 'owner not set');
}

#[test]
fn test_increase_counter() {
    
}