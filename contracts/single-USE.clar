;; =====================================================================
;; ONE-TIME ACTION PER USER - ELABORATE CLARINET CONTRACT
;; =====================================================================
;; PURPOSE
;; -------
;; This contract allows each blockchain address to perform a specific
;; action exactly ONE time.
;;
;; After the action is performed, the same address can never perform
;; it again.
;;
;; This pattern is extremely common in real smart contracts:
;; - Airdrop claims
;; - One-time registrations
;; - One-time votes
;; - One-time rewards
;;
;; =====================================================================
;; IMPORTANT CLARITY CONCEPTS USED
;; ---------------------------------------------------------------------
;; - define-map        : persistent on-chain storage
;; - tx-sender        : address calling the contract
;; - asserts!         : validation and error handling
;; - define-read-only : safe read-only queries
;; =====================================================================


;; ---------------------------------------------------------------------
;; SECTION 1: ERROR CODES
;; ---------------------------------------------------------------------
;; Error codes are unsigned integers (uint)
;; They are returned inside (err uXXX)

;; u100 -> user has already performed the action
(define-constant ERR-ALREADY-ACTED u100)


;; ---------------------------------------------------------------------
;; SECTION 2: DATA STORAGE
;; ---------------------------------------------------------------------
;; We store whether a user has already performed the action.
;;
;; Map structure:
;;   key   : user address (principal)
;;   value : boolean flag
;;
;; If the user is NOT in the map:
;;   -> they have NOT performed the action
;;
;; If the user IS in the map:
;;   -> they HAVE performed the action
;;

(define-map user-action-status
  principal
  bool)


;; ---------------------------------------------------------------------
;; SECTION 3: PRIVATE HELPERS (OPTIONAL)
;; ---------------------------------------------------------------------
;; Private functions can only be used inside this contract.
;; They help keep public functions clean and readable.

;; Check whether a user has already acted
(define-private (already-acted? (who principal))
  (default-to false
    (map-get? user-action-status who)))


;; ---------------------------------------------------------------------
;; SECTION 4: PUBLIC FUNCTIONS (STATE-CHANGING)
;; ---------------------------------------------------------------------

;; --------------------------------------------------
;; perform-action
;; --------------------------------------------------
;; This function allows the transaction sender to perform
;; the action ONE TIME ONLY.
;;
;; FLOW:
;; -----
;; 1. Check if sender already acted
;; 2. If yes -> fail with error
;; 3. If no  -> record action
;; 4. Return success
;;
;; RETURNS:
;; --------
;; (ok true)  -> action performed successfully
;; (err u100) -> user already performed action
;; --------------------------------------------------

(define-public (perform-action)
  (begin
    ;; STEP 1:
    ;; Ensure the sender has NOT already acted
    (asserts!
      (not (already-acted? tx-sender))
      (err ERR-ALREADY-ACTED))

    ;; STEP 2:
    ;; Record that the sender has now performed the action
    (map-set user-action-status tx-sender true)

    ;; STEP 3:
    ;; Return confirmation
    (ok true)))


;; ---------------------------------------------------------------------
;; SECTION 5: READ-ONLY FUNCTIONS (SAFE QUERIES)
;; ---------------------------------------------------------------------

;; --------------------------------------------------
;; has-acted
;; --------------------------------------------------
;; Public read-only function for checking if a user
;; has already performed the action.
;;
;; This does NOT modify blockchain state.
;;
;; RETURNS:
;; --------
;; true  -> user has acted
;; false -> user has NOT acted
;; --------------------------------------------------

(define-read-only (has-acted (who principal))
  (already-acted? who))


;; --------------------------------------------------
;; get-status
;; --------------------------------------------------
;; Returns the raw map entry for educational purposes.
;;
;; RETURNS:
;; --------
;; (some true) or none
;; --------------------------------------------------

(define-read-only (get-status (who principal))
  (map-get? user-action-status who))