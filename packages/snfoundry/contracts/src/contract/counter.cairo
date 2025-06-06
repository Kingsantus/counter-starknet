#[starknet::contract]
pub mod Counter {
    
    use crate::interface::counter::ICounter;
    use OwnableComponent::InternalTrait;
    use starknet::{ ContractAddress, get_caller_address };
    use openzeppelin_access::ownable::OwnableComponent;
    use starknet::storage::{StoragePointerWriteAccess, StoragePointerReadAccess};

    component!(path: OwnableComponent, storage: ownable, event: OwnableEvent);

    // Ownable Mixin
    #[abi(embed_v0)]
    impl OwnableMixinImpl = OwnableComponent::OwnableMixinImpl<ContractState>;
    impl OwnableTwoStepImpl = OwnableComponent::OwnableTwoStepImpl<ContractState>;

    #[storage]
    pub struct Storage {
        counter: u32,
        #[substorage(v0)]
        ownable: OwnableComponent::Storage
    }

    #[constructor]
    fn constructor(ref self: ContractState, init_value: u32, owner: ContractAddress) {
        self.counter.write(init_value);
        self.ownable.initializer(owner);
    }

    #[event]
    #[derive(Drop, starknet::Event)]
    pub enum Event {
        Increased: Increased,
        Decreased: Decreased,
        #[flat]
        OwnableEvent: OwnableComponent::Event
    }

    #[derive(Drop, starknet::Event)]
    pub struct Increased {
        pub account: ContractAddress,
    }

    #[derive(Drop, starknet::Event)]
    pub struct Decreased {
        pub account: ContractAddress,
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
            self.ownable.assert_only_owner();
            self.counter.write(0);
        }
    }

}