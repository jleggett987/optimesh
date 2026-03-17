# OptiMesh Flutter Web Client

This directory contains the frontend client for OptiMesh.

The frontend is planned as a Flutter Web application that provides:

- opt-in participation controls
- workload visibility
- compute status display
- task lifecycle feedback
- communication with the OptiMesh control plane

## Purpose

This client is intentionally designed to emphasize transparency and user control.

OptiMesh is not a hidden background compute system. The frontend should make participation explicit, understandable, and interruptible.

## Early Scope

The first frontend milestone will focus on:

- a landing shell
- participation toggle
- node status display
- mock task assignment state
- basic activity panel

## Planned Tech

- Flutter Web
- Dart
- Web Workers
- browser storage for local state
- API integration with AWS serverless services

## Status

Frontend shell in progress.
