# SRCX CYBORG-OS — Global Autobot Configuration

## Architecture Rules
- Modular, event-driven architecture.
- Core modules: ledger, accounts, transactions, routing, providers, bank-rails, audit.
- No business logic inside controllers.
- Domain logic lives in /core or /domain.
- Integrations live in /adapters.

## Naming Conventions
- Files: kebab-case
- Classes: PascalCase
- Functions: camelCase
- Events: snake_case
- Tables: snake_case plural

## Event Pipeline
payment_requested  
payment_validated  
payment_routed  
payment_executed  
payment_settled  

## Ledger Rules
- Double-entry
- Immutable entries
- No negative balances unless allowed

## Provider Rules
- Must implement ProviderInterface
- No provider-specific logic outside adapters

## Bank Rail Rules
- Must implement BankRailInterface

## Security
- No sensitive logs
- All secrets in env vars
- Timeout + retry required

## Autobot Mode
- Enforce naming
- Enforce event pipeline
- Enforce ledger rules
- Detect missing correlation_id
- Detect missing error handling
- Suggest folder structure fixes
