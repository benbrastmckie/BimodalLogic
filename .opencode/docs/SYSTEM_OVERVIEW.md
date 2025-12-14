# System Overview: LEAN 4 Development Suite

This document provides a high-level overview of the AI-powered LEAN 4 Development Suite contained within this `.opencode` directory.

## Purpose

The primary purpose of this system is to provide a comprehensive, context-aware AI assistant for the entire lifecycle of formal verification in LEAN 4. It is designed to act as an expert partner for mathematicians, logicians, and computer scientists, automating and assisting with tasks ranging from initial research to final documentation.

## Core Capabilities

The system is built around a 5-stage workflow that mirrors the human process of formal methods development:

1.  **Research**: Automatically gather relevant definitions, theorems, and proof strategies from web sources, academic papers (arXiv), and the Mathlib library.
2.  **Planning**: Generate detailed, structured proof outlines from high-level theorem statements.
3.  **Revision**: Analyze feedback and compiler errors to intelligently revise and repair proof plans.
4.  **Implementation**: Translate the proof plans into correct, idiomatic LEAN 4 code.
5.  **Documentation & Management**: Manage the codebase, document proofs, and ensure the project remains clean and well-structured.

## Key Features

-   **Hierarchical Agent Architecture**: A main orchestrator manages a team of 8 specialized primary agents, who in turn delegate tasks to over 20 subagents. This ensures tasks are handled by experts and preserves context.
-   **Modular Context**: All domain-specific knowledge (LEAN 4 syntax, mathematical concepts, style guides) is stored in easily editable markdown files in `.opencode/context/lean4/`.
-   **Workflow Automation**: The system automates the complex, multi-step process of proving a theorem from scratch.
-   **Extensibility**: The entire system is defined by the text files in this directory, making it transparent and easy to customize or extend.
