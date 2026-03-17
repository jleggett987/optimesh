# AWS Architecture Notes

## Overview

The OptiMesh backend is designed as a lightweight serverless coordination layer rather than a heavy centralized compute platform.

The backend does not perform the primary compute work. Its job is to coordinate participating nodes and track task flow.

---

## Core Backend Responsibilities

### Node Registration
Participating browser clients need a way to register availability and basic capabilities.

### Task Assignment
The control plane should provide a bounded workload that the client can execute safely.

### Result Collection
Once a task is complete, the client should submit results for validation and recording.

### Task Tracking
The platform should track task state such as:

- pending
- assigned
- running
- completed
- failed
- flagged for verification

---

## Candidate Service Mapping

### API Gateway
Used to expose public HTTP endpoints for client interactions.

### AWS Lambda
Used for lightweight orchestration logic and endpoint handling.

### DynamoDB
Used to store task metadata, client registration data, and basic status records.

### SQS
Can be used to model task queues or workload dispatch.

### CloudWatch
Used for logs, monitoring, and debugging during development.

---

## Guiding Principles

### Keep V1 simple
The initial backend should prioritize clarity over sophistication.

### Keep workloads bounded
The backend should only assign tasks that are safe, deterministic, and easy to reason about.

### Keep orchestration lightweight
The project should demonstrate serverless coordination, not overly complex distributed scheduling.

### Keep trust visible
Verification strategies should be understandable from both docs and implementation.

---

## V1 Non-Goals

The initial backend will not attempt to solve:

- large-scale distributed scheduling
- production-grade fraud prevention
- advanced economic models
- multi-region orchestration
- enterprise security hardening

Those may be future design explorations, but they are not required for a strong first portfolio version.
