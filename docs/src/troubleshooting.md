# Troubleshooting

These are some common issues that you might face while running the library.

### 1. Sometimes the fuzz tests might fail when run together. So, in order to verify if failing tests are actually failing, run them individually.

### 2. Error: (code: -32000, message: insufficient funds for gas \* price + value, data: None)

- _Cause_: The account used to deploy the contract does not have enough balance to pay for the gas. You are using:

```
gas = 41000
price = 20 * 1e9
value = result
```

- _Solution_:
  - Add more network token (ETH) to the account.
  - Reduce the gas price in the config file.
