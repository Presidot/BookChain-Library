# BookChain Library

A decentralized digital library platform built on the Stacks blockchain that connects authors, readers, and librarians in a transparent book lending ecosystem.

## Overview

BookChain Library revolutionizes digital book distribution by enabling authors to publish directly to readers while maintaining complete lending history and verification through blockchain technology.

## Features

- Publish digital books with detailed metadata and rental pricing
- Borrow books using STX tokens with direct author compensation
- Track complete lending history for each publication
- Librarian verification system for quality assurance
- Immutable record of all borrowing activities and transactions

## Smart Contract Functions

### Public Functions

- `publish-book`: Authors can publish new books with title, synopsis, and rental fee
- `borrow-book`: Readers can borrow books by paying rental fees to authors
- `verify-book`: Head librarian can verify book authenticity and quality

### Read-Only Functions

- `get-book`: Retrieve complete book information and metadata
- `get-lending-record`: View specific lending transaction details
- `get-record-count`: Check total number of lending records for a book

## Development

Built using Clarity smart contracts on the Stacks blockchain for transparent book lending.

### Prerequisites

- [Clarinet](https://github.com/hirosystems/clarinet)
- [Stacks CLI](https://github.com/blockstack/stacks.js)

### Testing

Run tests using Clarinet:

```bash
clarinet test