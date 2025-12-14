# .opencode System README

Welcome to the `.opencode` directory. This directory contains a complete, AI-powered system designed to assist with software development.

This document serves as the central entry point and map to the system's infrastructure, agents, commands, and documentation.

---

## 🚀 Getting Started

To get started with the primary features of the LEAN 4 Development Suite, please refer to the **Quick Start Guide**.

- **[➡️ Quick Start Guide](./QUICK-START.md)**

---

## 🗺️ System Components

This AI system is composed of several types of components, each defined in its own directory. Below is a comprehensive list of all agents and commands available.

### LEAN 4 Development Suite

These components were specifically designed for formal verification in LEAN 4.

#### Primary Agents

- **`orchestrator`**: The central coordinator for all LEAN 4 tasks.
- **`researcher`**: Gathers information from Mathlib, arXiv, and the web.
- **`planner`**: Creates structured proof outlines.
- **`reviser`**: Diagnoses and fixes errors in proof plans.
- **`implementer`**: Translates proof plans into LEAN 4 code.
- **`codebase`**: Organizes files and writes documentation.
- **`refactor`**: Improves the readability and structure of existing proofs.
- **`translator`**: Converts between LEAN 4 and LaTeX.
- **`project`**: Manages project state and interacts with Git.

#### Commands

- **`/prove <theorem>`**: Starts the full, end-to-end theorem proving workflow.
- **`/research <topic>`**: Runs a targeted information-gathering task.
- **`/implement <outline_file>`**: Implements a pre-existing proof plan.
- **`/refactor <file_path>`**: Refactors an existing `.lean` file.
- **`/translate <file_path>`**: Translates a file between LEAN 4 and LaTeX.
- **`/manage-project [--status|--organize]`**: Performs project-level tasks.

### General Purpose Utilities

These are general-purpose agents and commands that were part of the existing system.

#### Agents

- **`general`**: General purpose agents for directing tasks.
- **`coder`**: Coding agent for systematic implementation.
- **`builder`**: The agent responsible for generating new `.opencode` systems (it built the LEAN 4 suite).

#### Commands

- **`/build-context-system`**: Command to invoke the builder.
- **`/clean`**: Utilities for cleaning up the project.
- **`/commit`**: Git commit helper for LEAN 4 projects with build validation.
- **`/context`**: Commands for managing the context system.
- **`/optimize`**: Code optimization commands.
- **`/prompt-engineering`**: A suite of tools for improving prompts.
- **`/test`**: Commands for running tests.
- **`/validate-repo`**: Validates the repository's structure and quality.
- **`/worktrees`**: Git worktree management commands.

---

## 📁 File Tree and Infrastructure

_(Abridged for clarity)_

```
.opencode/
├── agent/
│   ├── orchestrator.md
│   ├── coder.md
│   └── subagents/
├── command/
│   ├── prove.md
├── context/
│   ├── lean4/
│   └── core/
├── docs/
│   ├── SYSTEM_OVERVIEW.md
│   └── ...
├── workflows/
│   └── end-to-end-theorem-proving.md
├── QUICK-START.md
└── README.md
```

- **`agent/`**: Contains the definitions for all agents.
- **`command/`**: Defines all the custom slash commands.
- **`context/`**: The knowledge base of the AI.
- **`docs/`**: All system documentation.
- **`workflows/`**: Defines high-level, multi-step plans.

---

## 📚 Detailed Documentation

For a deeper dive, please refer to the full documentation in the `docs/` directory.

- **[System Architecture](./docs/ARCHITECTURE.md)**
- **[Agents Guide](./docs/AGENTS_GUIDE.md)**
- **[Commands Reference](./docs/COMMANDS_REFERENCE.md)**
- **[Context Management Guide](./docs/CONTEXT_MANAGEMENT.md)**
- **[Workflows Guide](./docs/WORKFLOWS.md)**
- **[Testing Guide](./docs/TESTING.md)**
