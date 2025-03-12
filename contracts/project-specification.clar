;; Project Specification Contract
;; Defines building requirements and standards

(define-data-var counter uint u0)

(define-map projects
  { id: uint }
  {
    name: (string-ascii 64),
    owner: principal,
    active: bool
  }
)

(define-map specifications
  { project-id: uint, spec-id: uint }
  {
    title: (string-ascii 64),
    description: (string-ascii 256),
    approved: bool
  }
)

;; Create a new project
(define-public (create-project (name (string-ascii 64)))
  (let ((new-id (+ (var-get counter) u1)))
    ;; Update counter
    (var-set counter new-id)

    ;; Store project data
    (map-set projects
      { id: new-id }
      {
        name: name,
        owner: tx-sender,
        active: true
      }
    )

    (ok new-id)
  )
)

;; Add a specification
(define-public (add-specification
                (project-id uint)
                (spec-id uint)
                (title (string-ascii 64))
                (description (string-ascii 256)))
  (let ((project (map-get? projects { id: project-id })))

    ;; Project must exist
    (asserts! (is-some project) (err u1))

    ;; Only owner can add specs
    (asserts! (is-eq tx-sender (get owner (unwrap-panic project))) (err u2))

    ;; Store specification
    (map-set specifications
      { project-id: project-id, spec-id: spec-id }
      {
        title: title,
        description: description,
        approved: false
      }
    )

    (ok true)
  )
)

;; Approve a specification
(define-public (approve-specification
                (project-id uint)
                (spec-id uint))
  (let ((project (map-get? projects { id: project-id }))
        (spec (map-get? specifications { project-id: project-id, spec-id: spec-id })))

    ;; Project and spec must exist
    (asserts! (and (is-some project) (is-some spec)) (err u1))

    ;; Only owner can approve specs
    (asserts! (is-eq tx-sender (get owner (unwrap-panic project))) (err u2))

    ;; Store approved specification
    (map-set specifications
      { project-id: project-id, spec-id: spec-id }
      (merge (unwrap-panic spec) { approved: true })
    )

    (ok true)
  )
)

;; Get project details
(define-read-only (get-project (project-id uint))
  (map-get? projects { id: project-id })
)

;; Get specification details
(define-read-only (get-specification (project-id uint) (spec-id uint))
  (map-get? specifications { project-id: project-id, spec-id: spec-id })
)

