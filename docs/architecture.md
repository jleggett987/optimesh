# OptiMesh Architecture

## Overview

OptiMesh is an opt-in distributed browser compute platform concept designed to coordinate transparent, user-consented workloads across participating browser clients.

The platform is intentionally positioned around ethical distributed execution rather than hidden background resource usage. Users explicitly choose whether to participate, what level of compute to allow, and when to stop.

At a high level, OptiMesh consists of four primary layers:

1. Browser Client
2. Execution Layer
3. Control Plane
4. Verification and Rewards Layer

---

## 1. Browser Client

The Browser Client is the user-facing application built with Flutter Web.

Its responsibilities include:

- user opt-in and opt-out controls
- workload visibility
- participation settings
- local task status display
- communication with backend coordination services

This layer is responsible for user trust. It should make compute participation visible, understandable, and interruptible at all times.

### Planned technologies

- Flutter Web
- Dart
- local browser storage
- HTTP / WebSocket communication as needed

---

## 2. Execution Layer

The Execution Layer is where bounded workloads actually run inside the browser.

This layer is intended to support:

- Web Workers for background isolation
- WebAssembly modules for high-performance execution
- task interruption and lifecycle management
- bounded runtime and resource constraints

The purpose of this layer is to safely execute useful compute tasks without exposing the user to hidden or uncontrolled activity.

### Planned technologies

- Web Workers
- WebAssembly
- JavaScript interop where necessary

---

## 3. Control Plane

The Control Plane coordinates participating clients and distributes workloads across the network.

Its responsibilities include:

- node registration
- heartbeat or availability updates
- workload assignment
- task queue coordination
- result collection
- basic accounting and usage tracking

This layer should remain lightweight and serverless-oriented for portfolio clarity and cost efficiency.

### Planned AWS services

- API Gateway
- Lambda
- DynamoDB
- SQS
- CloudWatch

---

## 4. Verification and Rewards Layer

Because distributed workloads require trust, OptiMesh includes a conceptual verification layer to improve confidence in returned results.

Possible approaches include:

- redundant execution
- deterministic validation tasks
- probabilistic spot-checking
- simple reputation scoring

A future version may also explore a reward model such as:

- compute credits
- contribution scoring
- tokenized incentives

This layer is exploratory and should only be introduced after the core platform flow is working clearly.

---

## Core Flow

A simplified platform flow looks like this:

1. User opens the OptiMesh client
2. User explicitly opts in to participate
3. Client registers with the control plane
4. Control plane assigns an eligible workload
5. Browser executes the workload in a worker / WASM context
6. Result is returned to the control plane
7. Verification logic accepts, rejects, or rechecks the result
8. Usage and contribution data are recorded

---

## Design Principles

OptiMesh is guided by a few core principles:

### Ethical participation
All compute participation must be transparent, user-controlled, and revocable.

### Bounded execution
Tasks should have clear limits for time, memory, and expected behavior.

### Modular architecture
The platform should be understandable as separate layers that can evolve independently.

### Portfolio-grade clarity
This repository is intentionally structured to demonstrate architecture, trade-offs, and implementation decisions clearly.

---

## Early Non-Goals

To keep the project focused, the following are not part of the initial implementation target:

- stealth background execution
- hidden browser mining
- unrestricted third-party code execution
- overly complex distributed scheduling
- production-grade economic models in V1

---

## Initial Candidate Use Cases

Potential demonstration workloads may include:

- chunked mathematical computations
- simulation batches
- lightweight inference tasks
- analytics transforms
- controlled benchmark workloads

The best early workloads are deterministic, bounded, and easy to explain in a portfolio setting.

---

## Planned Repository Alignment

The architecture maps to the repository roughly as follows:

- `frontend/flutter_web/` → Browser Client
- `wasm/engine/` → Execution Layer
- `infra/aws/` → Control Plane
- `docs/` → architecture, roadmap, and design notes

---

## Status

Current status: architecture and repository planning.

Implementation will begin with a narrow proof of concept:
- basic Flutter Web shell
- opt-in UI
- simple task polling
- local worker execution
- stubbed AWS control plane integration
