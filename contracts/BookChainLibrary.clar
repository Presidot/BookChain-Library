;; BookChain Library: Decentralized digital book lending and ownership platform
;; Enables authors to publish, readers to borrow, and librarians to curate collections

(define-data-var head-librarian principal tx-sender)
(define-map book-catalog
  { book-id: uint }
  {
    author: principal,
    rental-fee: uint,
    title: (string-ascii 50),
    synopsis: (string-ascii 500),
    publication-year: uint,
    verified: bool
  }
)

(define-map lending-records
  { book-id: uint, record-id: uint }
  {
    borrower: principal,
    checkout-time: uint,
    activity: (string-ascii 20)
  }
)

(define-data-var next-book-id uint u1)
(define-map record-counter-map 
  { book-id: uint }
  { count: uint }
)

;; Publish a new book
(define-public (publish-book (title-input (string-ascii 50)) (synopsis-input (string-ascii 500)) (year-input uint) (fee-input uint))
  (let
    (
      (book-id (var-get next-book-id))
      (record-id u0)
      (title title-input)
      (synopsis synopsis-input)
      (year year-input)
      (fee fee-input)
    )
    ;; Input validation
    (asserts! (> fee u0) (err u1))
    (asserts! (> (len title) u0) (err u5))
    (asserts! (> (len synopsis) u0) (err u6))
    (asserts! (> year u0) (err u7))
    
    (map-set book-catalog
      { book-id: book-id }
      {
        author: tx-sender,
        rental-fee: fee,
        title: title,
        synopsis: synopsis,
        publication-year: year,
        verified: false
      }
    )
    (map-set lending-records
      { book-id: book-id, record-id: record-id }
      {
        borrower: tx-sender,
        checkout-time: book-id,
        activity: "published"
      }
    )
    (map-set record-counter-map 
      { book-id: book-id }
      { count: u1 }
    )
    (var-set next-book-id (+ book-id u1))
    (ok book-id)
  )
)

;; Borrow a book
(define-public (borrow-book (book-id-input uint))
  (let
    (
      (book-id book-id-input)
      (book-entry (unwrap! (map-get? book-catalog { book-id: book-id }) (err u2)))
      (fee (get rental-fee book-entry))
      (author (get author book-entry))
      (record-data (default-to { count: u0 } (map-get? record-counter-map { book-id: book-id })))
      (record-id (get count record-data))
      (new-record-id (+ record-id u1))
    )
    ;; Input validation
    (asserts! (> book-id u0) (err u8))
    (asserts! (not (is-eq tx-sender author)) (err u3))
    
    (try! (stx-transfer? fee tx-sender author))
    (map-set lending-records
      { book-id: book-id, record-id: record-id }
      {
        borrower: tx-sender,
        checkout-time: (var-get next-book-id),
        activity: "borrowed"
      }
    )
    (map-set record-counter-map 
      { book-id: book-id }
      { count: new-record-id }
    )
    (ok true)
  )
)

;; Verify a book (librarian only)
(define-public (verify-book (book-id-input uint))
  (let
    (
      (book-id book-id-input)
      (book-entry (unwrap! (map-get? book-catalog { book-id: book-id }) (err u2)))
      (record-data (default-to { count: u0 } (map-get? record-counter-map { book-id: book-id })))
      (record-id (get count record-data))
      (new-record-id (+ record-id u1))
    )
    ;; Input validation
    (asserts! (> book-id u0) (err u8))
    (asserts! (is-eq tx-sender (var-get head-librarian)) (err u4))
    
    (map-set book-catalog
      { book-id: book-id }
      (merge book-entry { verified: true })
    )
    (map-set lending-records
      { book-id: book-id, record-id: record-id }
      {
        borrower: (get author book-entry),
        checkout-time: (var-get next-book-id),
        activity: "verified"
      }
    )
    (map-set record-counter-map 
      { book-id: book-id }
      { count: new-record-id }
    )
    (ok true)
  )
)

;; Get book details
(define-read-only (get-book (book-id uint))
  (map-get? book-catalog { book-id: book-id })
)

;; Get lending history
(define-read-only (get-lending-record (book-id uint) (record-id uint))
  (map-get? lending-records { book-id: book-id, record-id: record-id })
)

;; Get total lending records for a book
(define-read-only (get-record-count (book-id uint))
  (let
    (
      (record-data (default-to { count: u0 } (map-get? record-counter-map { book-id: book-id })))
    )
    (get count record-data)
  )
)
