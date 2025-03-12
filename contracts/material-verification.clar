;; Material Verification Contract
;; Tracks the quality and origin of construction materials

(define-data-var counter uint u0)

(define-map materials
  { id: uint }
  {
    name: (string-ascii 64),
    manufacturer: principal,
    active: bool
  }
)

(define-map batches
  { material-id: uint, batch-id: (string-ascii 32) }
  {
    quantity: uint,
    certification: (string-ascii 64),
    verified: bool
  }
)

;; Register a new material
(define-public (register-material (name (string-ascii 64)))
  (let ((new-id (+ (var-get counter) u1)))
    ;; Update counter
    (var-set counter new-id)

    ;; Store material data
    (map-set materials
      { id: new-id }
      {
        name: name,
        manufacturer: tx-sender,
        active: true
      }
    )

    (ok new-id)
  )
)

;; Register a batch of material
(define-public (register-batch
                (material-id uint)
                (batch-id (string-ascii 32))
                (quantity uint)
                (certification (string-ascii 64)))
  (let ((material (map-get? materials { id: material-id })))

    ;; Material must exist
    (asserts! (is-some material) (err u1))

    ;; Only manufacturer can register batches
    (asserts! (is-eq tx-sender (get manufacturer (unwrap-panic material))) (err u2))

    ;; Store batch data
    (map-set batches
      { material-id: material-id, batch-id: batch-id }
      {
        quantity: quantity,
        certification: certification,
        verified: false
      }
    )

    (ok true)
  )
)

;; Verify a batch
(define-public (verify-batch
                (material-id uint)
                (batch-id (string-ascii 32)))
  (let ((batch (map-get? batches { material-id: material-id, batch-id: batch-id })))

    ;; Batch must exist
    (asserts! (is-some batch) (err u1))

    ;; Store verified batch
    (map-set batches
      { material-id: material-id, batch-id: batch-id }
      (merge (unwrap-panic batch) { verified: true })
    )

    (ok true)
  )
)

;; Get material details
(define-read-only (get-material (material-id uint))
  (map-get? materials { id: material-id })
)

;; Get batch details
(define-read-only (get-batch (material-id uint) (batch-id (string-ascii 32)))
  (map-get? batches { material-id: material-id, batch-id: batch-id })
)

