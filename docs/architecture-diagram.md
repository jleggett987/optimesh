# OptiMesh Architecture Diagram Notes

## Purpose

This document will accompany the OptiMesh architecture diagram and explain the major platform layers in a quick visual-first format.

The diagram will focus on these four areas:

- Browser Client
- Execution Layer
- AWS Control Plane
- Verification / Rewards Layer

---

## Intended Diagram Sections

### 1. Browser Client
- Flutter Web UI
- opt-in controls
- task status
- participation settings

### 2. Execution Layer
- Web Workers
- WebAssembly modules
- bounded compute tasks
- local task lifecycle

### 3. AWS Control Plane
- API Gateway
- Lambda
- DynamoDB
- SQS
- CloudWatch

### 4. Verification / Rewards
- result validation
- duplicate execution
- contribution accounting
- future reward model

---

## Diagram Goals

The final architecture diagram should make it easy to understand:

- what runs in the browser
- what runs in AWS
- how tasks move through the system
- how OptiMesh remains transparent and opt-in

---

## Diagram Status

Architecture diagram image to be added in `docs/assets/`.
