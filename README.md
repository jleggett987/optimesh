# OptiMesh

**Opt-in distributed browser compute platform built with Flutter Web, Web Workers, WebAssembly, and AWS serverless.**

OptiMesh is an experimental platform that explores how modern browsers can participate in transparent, user-consented distributed computing networks. Instead of hidden background mining or opaque resource usage, OptiMesh is designed around **ethical participation, bounded workloads, and full user control**.

This project is being developed as a **systems architecture portfolio project**, demonstrating distributed platform design, serverless infrastructure, browser compute execution, and transparent task orchestration.

---

# Why OptiMesh Exists

Modern browsers are powerful compute environments, but they are rarely used for coordinated distributed workloads.

OptiMesh explores a model where users can **voluntarily contribute idle browser compute** toward useful workloads such as:

- simulation tasks
- data processing
- AI inference batches
- analytics workloads
- distributed research experiments

Key principles of the project:

- **Opt-in participation**
- **Transparent compute usage**
- **Bounded workloads**
- **User visibility and control**
- **No hidden crypto mining**

---

# High-Level Architecture

OptiMesh is composed of four major components.

### 1. Browser Client (Flutter Web)

The client application provides the user interface and controls participation in the network.

Responsibilities include:

- task opt-in / opt-out
- compute usage display
- workload status
- node registration
- communication with the control plane

Technologies:

- Flutter Web
- Dart
- Web Workers
- IndexedDB / local state

---

### 2. Execution Layer

Workloads are executed safely inside the browser.

Technologies:

- Web Workers for background processing
- WebAssembly for high-performance execution
- sandboxed compute tasks

This layer ensures workloads are:

- isolated
- bounded
- interruptible
- verifiable

---

### 3. Control Plane (AWS Serverless)

The control plane coordinates tasks across participating nodes.

Possible infrastructure components:

- AWS API Gateway
- AWS Lambda
- AWS DynamoDB
- AWS SQS / task queues
- lightweight orchestration services

Responsibilities:

- task distribution
- node registration
- workload assignment
- results collection
- usage accounting

---

### 4. Verification & Rewards Layer

OptiMesh experiments with mechanisms to ensure compute results are trustworthy.

Potential approaches include:

- redundant task execution
- probabilistic verification
- deterministic workloads

Future versions may explore **tokenized reward systems or compute credits**.

---

# Repository Structure

Planned repository layout:

optimesh/

    docs/
      architecture.md
      roadmap.md
      system-overview.md — high-level platform flow and component summary
      architecture-diagram.md — notes and structure for the visual architecture diagram
    frontend/
      flutter_web/
        README.md
        pubspec.yaml
        lib/
          main.dart   
    wasm/
      engine/
    infra/
      aws/
    scripts/

---

# Development Roadmap

### Phase 1 — Architecture

- Project documentation
- system architecture
- repo structure
- technical design

### Phase 2 — Browser Client

- Flutter Web interface
- opt-in participation UI
- compute status dashboard

### Phase 3 — Execution Engine

- Web Worker task execution
- WebAssembly integration
- sandbox compute runtime

### Phase 4 — Control Plane

- serverless task distribution
- node registration
- workload orchestration

### Phase 5 — Portfolio Demonstration

- interactive demo
- architecture diagrams
- example workloads

---

# Ethical Design

OptiMesh is intentionally designed to avoid the problematic practices often associated with browser compute platforms.

This project explicitly avoids:

- hidden crypto mining
- non-consensual compute usage
- background execution without visibility

Participation must always be **transparent and user-controlled**.

---

# Current Status

Early architecture and repository structure.

Implementation will proceed incrementally with a focus on clear system design and modular components.

---

# Author

Jason Leggett  
Software Engineer / Engineering Leader  

Technologies used throughout my work include:

- Flutter
- AWS serverless platforms
- distributed systems
- platform architecture
- blockchain systems
- AI / ML systems

---

# License

MIT License
