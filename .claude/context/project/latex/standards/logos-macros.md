# Logos Macro Conventions

## Purpose

This document defines macro conventions for consistent typography of Logos-specific terms across all LaTeX documentation. These macros should be defined in `logos-notation.sty` and used throughout the reference manual.

## Core Macros

### Product Name: \logos

| Macro | Output | Definition |
|-------|--------|------------|
| `\logos` | *Logos* | `\emph{Logos}` |

**Usage**: Use `\logos` whenever referring to the Logos system as a proper noun.

**When to Use**:
- Introducing the system: "The \logos addresses these limitations..."
- Describing capabilities: "The \logos provides two complementary mechanisms..."
- Referencing extensions: "The \logos Foundations model how..."

**When NOT to Use**:
- In italicized contexts where double-emphasis would occur
- In section titles (use plain "Logos")
- When referring to the general concept rather than the system

### Examples

```latex
% CORRECT: Using \logos for the system name
The \logos addresses these limitations by implementing a formal logic.
Implementing the \logos generates mathematically verified reasoning data.
The \logos is organized into two \textit{Logos Foundations}.

% INCORRECT: Plain text instead of macro
The Logos addresses these limitations by implementing a formal logic.

% INCORRECT: Manual emphasis instead of macro
The \emph{Logos} addresses these limitations by implementing a formal logic.
```

## Tool Macros

### Proof-Checker: \proofchecker

| Macro | Output | Definition |
|-------|--------|------------|
| `\proofchecker` | Proof-Checker | `Proof-Checker` (with proper hyphenation) |

**Usage**: Use `\proofchecker` when referring to the Lean 4-based proof verification system.

**When to Use**:
- Describing the verification architecture: "The \proofchecker{} is implemented in Lean 4's type system..."
- Discussing proof certificates: "The \proofchecker{} generates a positive RL signal..."
- Cross-referencing implementations: "The implementation can be found in the \proofchecker{} repository..."

### Model-Checker: \modelchecker

| Macro | Output | Definition |
|-------|--------|------------|
| `\modelchecker` | Model-Checker | `Model-Checker` (with proper hyphenation) |

**Usage**: Use `\modelchecker` when referring to the Z3-based semantic verification system.

**When to Use**:
- Describing countermodel generation: "The \modelchecker{} leverages the Z3 satisfiability solver..."
- Discussing corrective signals: "The \modelchecker{} generates a corrective RL signal..."
- Explaining refutation: "The \modelchecker{} constructs explicit countermodels..."

### Examples

```latex
% CORRECT: Using tool macros
The \proofchecker{} is implemented in Lean 4's type system to certify derivations.
The \modelchecker{} leverages the Z3 solver to refute invalid claims.

% INCORRECT: Plain text with inconsistent formatting
The Proof-Checker is implemented in Lean 4's type system to certify derivations.
The Model Checker leverages the Z3 solver to refute invalid claims.
```

## Combined Usage

When discussing the dual verification architecture, use both macros consistently:

```latex
% CORRECT: Consistent macro usage
The \proofchecker{} generates a positive RL signal by providing Lean proof receipts,
while the \modelchecker{} generates corrective signals through Z3 counterexamples.

% INCORRECT: Mixed macro and plain text
The Proof-Checker generates a positive RL signal by providing Lean proof receipts,
while the \modelchecker{} generates corrective signals through Z3 counterexamples.
```

## Implementation Notes

These macros should be defined in `latex/assets/logos-notation.sty`:

```latex
% Logos product name
\newcommand{\logos}{\emph{Logos}}

% Verification tools
\newcommand{\proofchecker}{Proof-Checker}
\newcommand{\modelchecker}{Model-Checker}
```

**Note**: The NOTE: tags in `latex/subfiles/01-Introduction.tex` indicate these macros are intended but may not yet be defined in the .sty file. If compilation errors occur, either:
1. Add the macro definitions to `logos-notation.sty`
2. Use the expanded form temporarily until macros are defined

## Related Context

- `standards/notation-conventions.md` - General mathematical notation
- `standards/latex-style-guide.md` - Document formatting rules
- `../../rules/latex.md` - LaTeX development rules (auto-loaded)
