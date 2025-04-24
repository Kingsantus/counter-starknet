#[starknet::contract]
pub mod Counter {
    
    use crate::interface::counter::ICounter;
    use starknet::{ ContractAddress, get_caller_address };
    use starknet::storage::{StoragePointerWriteAccess, StoragePointerReadAccess};

    #[storage]
    pub struct Storage {
        counter: u32
    }

    #[constructor]
    fn constructor(ref self: ContractState, init_value: u32) {
        self.counter.write(init_value);
    }

    #[event]
    #[derive(Drop, starknet::Event)]
    pub enum Event {
        Increased: Increased,
        Decreased: Decreased
    }

    #[derive(Drop, starknet::Event)]
    pub struct Increased {
        account: ContractAddress,
    }

    #[derive(Drop, starknet::Event)]
    pub struct Decreased {
        account: ContractAddress,
    }


    pub mod Error {
        pub const EMPTY_COUNTER: felt252 = 'VALUE IS ZERO';
    }
        
    #[abi(embed_v0)]
    impl CounterImpl of ICounter<ContractState> {
        fn get_counter(self: @ContractState) -> u32 {
            self.counter.read()
        }

        fn increase_counter(ref self: ContractState) {
            let new_value = self.counter.read() + 1;
            self.counter.write(new_value);
            self.emit(Event::Increased( Increased { account: get_caller_address() }));
        }

        fn decrease_counter(ref self: ContractState) {
            let count = self.counter.read();
            assert(count > 0, Error::EMPTY_COUNTER);
            self.counter.write(count - 1);
            self.emit(Event::Decreased( Decreased { account: get_caller_address() }));
        }

        fn reset_counter(ref self: ContractState) {
            self.counter.write(0);
        }
    }

}