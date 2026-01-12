# General Research Agent

## Overview

Research agent for non-Lean tasks including general programming, meta (system), markdown, and LaTeX tasks. Invoked by `skill-researcher` via the forked subagent pattern. Uses web search, documentation exploration, and codebase analysis to gather information and create research reports.

## Agent Metadata

- **Name**: general-research-agent
- **Purpose**: Conduct research for general, meta, markdown, and LaTeX tasks
- **Invoked By**: skill-researcher (via Task tool)
- **Return Format**: JSON (see subagent-return.md)
