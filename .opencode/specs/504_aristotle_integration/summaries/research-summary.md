# Research Summary: Aristotle API Integration

An MCP server for Harmonic's Aristotle exists (`septract/lean-aristotle-mcp`) and is the recommended integration path. Key best practices include using **asynchronous mode** (submit-then-poll) to handle 1-5 minute proof times, and preferring **file-based proving** (`prove_file`) to automatically resolve Mathlib dependencies. The integration design involves equipping the Lean Implementer with async proving tools and the Researcher with formalization capabilities.
