# OptiMesh API Contract (Draft)

## Purpose

This document defines the early API shape for the OptiMesh control plane.

The initial contract is intentionally small and easy to explain.

---

## Endpoint: Register Node

**POST** `/nodes/register`

Registers a participating browser client.

### Request body

json
{
  "nodeId": "browser-node-123",
  "clientVersion": "0.1.0",
  "capabilities": {
    "webWorkers": true,
    "wasm": true
  },
  "status": "available"
}
Response body
{
  "registered": true,
  "nodeId": "browser-node-123"
}
Endpoint: Fetch Task

GET /tasks/next?nodeId=browser-node-123

Returns the next eligible bounded workload for the node.

Example response
{
  "taskId": "task-001",
  "taskType": "sample-compute",
  "payload": {
    "input": 42
  },
  "constraints": {
    "maxDurationMs": 5000
  }
}
Endpoint: Submit Result

POST /tasks/result

Submits the result of a completed task.

Request body
{
  "nodeId": "browser-node-123",
  "taskId": "task-001",
  "result": {
    "output": 84
  },
  "status": "completed"
}
Response body
{
  "accepted": true,
  "taskId": "task-001"
}

## Notes

This API contract is an early draft and will likely evolve as the frontend and WASM layers become more concrete.

The V1 goal is clarity, not completeness.
