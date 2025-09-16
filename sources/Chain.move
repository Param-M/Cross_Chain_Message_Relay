module MyModule::CrossChainMessageRelay {
    use aptos_framework::signer;
    use aptos_framework::timestamp;
    use std::string::{Self, String};

    /// Struct representing a cross-chain message
    struct Message has store, key {
        content: String,           // Message content
        source_chain: String,      // Chain where message originated
        destination_chain: String, // Target chain for the message
        timestamp: u64,           // When message was created
        relayed: bool,            // Whether message has been relayed
    }

    /// Error codes
    const E_MESSAGE_ALREADY_RELAYED: u64 = 1;
    const E_MESSAGE_NOT_FOUND: u64 = 2;

    /// Function to send a cross-chain message
    public fun send_message(
        sender: &signer,
        content: String,
        source_chain: String,
        destination_chain: String
    ) {
        let message = Message {
            content,
            source_chain,
            destination_chain,
            timestamp: timestamp::now_seconds(),
            relayed: false,
        };
        move_to(sender, message);
    }

    /// Function to relay/mark a message as delivered
    public fun relay_message(relayer: &signer, message_owner: address) 
        acquires Message {
        let message = borrow_global_mut<Message>(message_owner);
        
        // Ensure message hasn't been relayed yet
        assert!(!message.relayed, E_MESSAGE_ALREADY_RELAYED);
        
        // Mark message as relayed
        message.relayed = true;
    }

    /// View function to check if message exists and is relayed
    #[view]
    public fun is_message_relayed(message_owner: address): bool 
        acquires Message {
        if (exists<Message>(message_owner)) {
            let message = borrow_global<Message>(message_owner);
            message.relayed
        } else {
            false
        }
    }
}