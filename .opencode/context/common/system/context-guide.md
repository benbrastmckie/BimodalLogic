# Context Directory Structure Guide

This guide outlines the standardized directory structure for the `.opencode/context/` directory. The goal is to create a consistent and scalable structure for managing context files across different projects.

## Root Directory

The `.opencode/context/` directory is the root for all context files. It contains two key overview files:

-   **`README.md`**: Provides a high-level overview of the context organization, usage guidelines, maintenance procedures, and the context protection pattern. It is the main entry point for understanding the context system.
-   **`index.md`**: A quick reference map for AI agents to efficiently load the correct context files. It includes keyword triggers, dependencies, and priority levels for different tasks.

## Top-Level Directories

The context directory is organized into two main top-level directories:

-   `common/`: Contains context files that are common across all repositories and not specific to any single project. This is for universal, boilerplate context.
-   `project/`: Contains context files that are specific to the current repository. This allows for project-specific context without cluttering the common context.

### `.opencode/context/` Directory Structure

```
.opencode/context/
├── common/
│   ├── standards/
│   ├── system/
│   ├── templates/
│   └── workflows/
├── project/
│   ├── lean4/
│   ├── logic/
│   ├── math/
│   ├── physics/
│   └── repo/
├── README.md
└── index.md
```

### Common Directory Structure

The `common/` directory contains subdirectories for different types of common context:

-   `common/standards/`: Defines standards for code, documentation, testing, and analysis.
-   `common/system/`: Contains general system-level context, such as this guide, artifact management, and state schemas.
-   `common/templates/`: Provides templates for agents, orchestrators, and other system components.
-   `common/workflows/`: Outlines standard workflows for delegation, review, and task breakdown.

### Project-Specific Directory Structure

The `project/` directory contains subdirectories that are specific to the needs of the project. These directories are generally topic-specific and not predefined, with the exception of the `repo` directory.

-   **Topic-Specific Directories**: These directories contain context for specific domains. Examples in this project include:
    -   `project/lean4/`: For projects related to Lean 4.
    -   `project/logic/`: For projects involving formal logic.
    -   `project/math/`: For mathematical domain knowledge.
    -   `project/physics/`: For physics-related concepts.

-   **`project/repo/`**: This directory is a standard project-specific directory that contains context related to the repository itself, such as the project overview.

This structure provides a clear separation between common and project-specific context, making it easier to manage and scale the context files.

## Context Loading and Self-Healing

### Context File References

Commands and agents reference context files using the `@` prefix in their context loading sections:

```markdown
Context Loaded:
@.opencode/specs/TODO.md
@.opencode/specs/state.json
@.opencode/context/common/system/status-markers.md
```

### Self-Healing Infrastructure

The OpenCode system implements **automatic self-healing** for missing infrastructure files. When a command needs state.json or errors.json and they don't exist, they are automatically created from templates using data from .opencode/specs/TODO.md.

**File Types**:
- **Auto-Created**: state.json, errors.json (created from templates)
- **Required**: .opencode/specs/TODO.md, context files (fail with clear error if missing)
- **Optional**: Project-specific configs (skip if missing)

**User Experience**: On first run or after file deletion, you'll see:
```
Note: Created .opencode/specs/state.json from template
Initialized with 37 tasks from .opencode/specs/TODO.md
```

**For Details**: See `.opencode/context/common/system/self-healing-guide.md`
