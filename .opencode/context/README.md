# Context README

This directory contains the modular knowledge base for the LEAN 4 Development Suite. The system is designed to provide agents with just-in-time context, ensuring they have the information they need without being overloaded.

## Organization

The context is divided into four categories:

-   **/domain**: Contains core knowledge about the LEAN 4 language, `mathlib`, and key mathematical concepts. This is the foundational knowledge for the system.
-   **/processes**: Describes standard workflows and best practices, such as the end-to-end proof process or project structuring.
-   **/standards**: Holds quality guidelines, including the LEAN 4 style guide, documentation standards, and criteria for what makes a proof "readable."
-   **/templates**: Provides boilerplate for common file types, such as new `.lean` files or proof structures.

## How It's Used

When the `lean-dev-orchestrator` assigns a task to a specialist agent, it also determines which context files are relevant to that task. It then provides these files to the agent, ensuring the agent's response is grounded in the established domain knowledge and best practices.
