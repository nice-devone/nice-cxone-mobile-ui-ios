# Case Study: Chat Configuration

## Overview

The CXoneChatUI module supports advanced customization through the `ChatConfiguration` object, allowing integrators to provide additional custom fields for both the customer and the case (contact). These fields are passed to the chat session and are visible to agents during the conversation, enabling deeper personalization and integration with external systems.

## How It Works

When initializing the `ChatCoordinator`, you can supply a `ChatConfiguration` instance containing:

- `additionalCustomerCustomFields`: Key-value pairs representing extra information about the customer (e.g., user ID, membership level).
- `additionalContactCustomFields`: Key-value pairs representing extra information about the case or conversation (e.g., order number, support topic).

These custom fields are sent to the backend and made available to agents in the agent console.

## ⚠️ Integration Responsibility

It is the responsibility of the integrator to ensure that the keys provided in these dictionaries match the custom field definitions configured in the brand settings on the CXone platform. If a key does not match a defined custom field, the value will be ignored or may cause chat initialization to fail.

## Example Usage

```swift
let configuration = ChatConfiguration(
    additionalCustomerCustomFields: [
        "customerId": "12345",
        "membershipLevel": "gold"
    ],
    additionalContactCustomFields: [
        "caseId": "A-98765",
        "topic": "Order Support"
    ]
)
...
class MyChatCoordinator: ChatCoordinator {

    // MARK: - Init
    
    init() {
        super.init(chatConfiguration: configuration)
    }

    ...
}
