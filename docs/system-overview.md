# OptiMesh System Overview

## Purpose

This document provides a simple, recruiter-friendly overview of how OptiMesh is intended to work at a system level.

OptiMesh is an opt-in distributed browser compute platform concept. Participating browser clients voluntarily receive bounded workloads, execute them in an isolated environment, and return results to a lightweight AWS-based control plane.

The design is intentionally transparent and user-controlled.

---

## Core System Components

### Browser Client
The Flutter Web client provides the user interface, participation controls, system status, and communication with backend services.

### Worker / Execution Runtime
The browser executes workloads using Web Workers and, later, WebAssembly modules for higher-performance tasks.

### Control Plane
AWS serverless infrastructure coordinates task assignment, node registration, and result submission.

### Verification Layer
Returned results can be checked using deterministic validation, duplicate execution, or spot-checking approaches.

---

## Simplified Flow

1. User opens OptiMesh
2. User explicitly opts in
3. Client registers with backend services
4. Task is assigned
5. Task runs in worker / WASM context
6. Result is submitted
7. Backend records outcome and usage

---

## Diagram Status

A visual system overview diagram will be added in `docs/assets/`.
