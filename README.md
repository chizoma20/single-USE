# single-USE Clarity Contract

## Overview

This Clarity smart contract enables **one-time actions per user** (per principal address). Each address can perform a designated action exactly **once**. After the action is performed, the same address cannot repeat it.  
Common use cases include:
- Airdrop claims
- One-time registrations
- One-time votes
- One-time rewards


## Key Features

- **Persistent Storage:** Tracks user action status using a Clarity `define-map`.
- **Error Handling:** Returns error code `u100` if a user attempts to repeat the action.
- **Public Functions:**  
  - `perform-action`: Allows a user to perform the action once.
- **Read-Only Functions:**  
  - `has-acted`: Checks if a user has already performed the action.
  - `get-status`: Returns the raw map entry for educational purposes.


## Contract Functions

### `perform-action`
- **Type:** Public (state-changing)
- **Description:** Allows the transaction sender to perform the action one time only.
- **Returns:**  
  - `(ok true)` if successful  
  - `(err u100)` if already performed

### `has-acted`
- **Type:** Read-only
- **Description:** Checks if a given principal has already performed the action.
- **Returns:**  
  - `true` if acted  
  - `false` if not

### `get-status`
- **Type:** Read-only
- **Description:** Returns the raw map entry for a principal.
- **Returns:**  
  - `(some true)` if acted  
  - `none` if not


## Error Codes

- `u100` (`ERR-ALREADY-ACTED`): User has already performed the action.


## Usage Example

clarity
;; Perform the action (only once per address)
(perform-action)

;; Check if a user has acted
(has-acted 'SP123...')

;; Get raw status for a user
(get-status 'SP123...')


