# Research Report: Task #823

**Task**: 823 - update_context_verum_falsum_notation
**Started**: 2026-02-03T12:00:00Z
**Completed**: 2026-02-03T12:15:00Z
**Effort**: Small (context documentation update)
**Dependencies**: None
**Sources/Inputs**: IdentityAboutness.tex (lines 106-109, 494), ConstitutiveFoundation.tex (line 357+), logos-notation.sty, notation-standards.sty, notation-conventions.md
**Artifacts**: This research report
**Standards**: report-format.md

## Executive Summary

- **Key finding**: In bilateral semantics with two partial orders, there are FOUR distinct elements: `\top`, `\bot` (top/bottom for one order) and `\Top`, `\Bot` (top/bottom for the other order)
- **Critical relationship**: `\Top := \neg\top` (verum) and `\Bot := \neg\bot` (falsum) - these are defined via negation
- **Recommended terminology**: Reserve "verum" for `\Top` (negation of top), "falsum" for `\Bot` (negation of bot)
- **Implementation**: Add `\Top` and `\Bot` symbol definitions to logos-notation.sty; update notation-conventions.md

## Context & Scope

### Problem Statement

The NOTE tag at line 357 in ConstitutiveFoundation.tex identifies that `\top` and `\bot` are NOT interdefinable in bilateral semantics. This creates confusion because:

1. Standard notation uses `\top` for "verum" (truth constant) and `\bot` for "falsum" (falsity constant)
2. In bilateral semantics with TWO orderings, there are actually FOUR distinct constants
3. The current documentation conflates "Verum (Top)" as section headers but these are distinct concepts

### Research Questions

1. What are the exact notation conventions in IdentityAboutness.tex?
2. How should the four elements be named and symbolized?
3. What files need updating for consistency?

## Findings

### 1. IdentityAboutness.tex Notation Conventions

**Symbol Definitions (lines 106-109)**:

```latex
% \Top - a top with a bar through it (strikethrough top symbol)
\newcommand{\Top}{%
  {\ensuremath{\mathbin{\mathrel{\ooalign{\hss$\top$\hss\cr%
  \kern0ex\raise.7ex\hbox{\scalebox{1}{$-$}}}}}}}}

% \Bot - \Top rotated 180 degrees (strikethrough bot symbol)
\newcommand{\Bot}{{\ensuremath{\mathbin{\rotatebox[origin=c]{180}{$\Top$}}}}}
```

**Semantic Definitions (footnote at line 494)**:

The footnote explains the four-element structure:

> "Were one to add top and bottom elements to the language, s-models must assign:
> - `|\top| = (S, emptyset)` - top with respect to the **ground ordering** (`<=`)
> - `|\bot| = (emptyset, {null})` - bottom with respect to the **ground ordering** (`<=`)
> - `\Top := \neg\top` - top with respect to the **parthood ordering** (`sqsubseteq`)
> - `\Bot := \neg\bot` - bottom with respect to the **parthood ordering** (`sqsubseteq`)"

### 2. Two Orderings, Four Constants

In bilateral semantics, propositions are ordered by TWO distinct relations:

| Ordering | Symbol | Top Element | Bottom Element |
|----------|--------|-------------|----------------|
| Ground (<=) | conjunctive containment | `\top` | `\bot` |
| Parthood (sqsubseteq) | disjunctive containment | `\Top` (verum) | `\Bot` (falsum) |

The critical insight: **`\Top` and `\Bot` are defined as negations**:
- `\Top := \neg\top` (the verum)
- `\Bot := \neg\bot` (the falsum)

### 3. Current Documentation Issues

**ConstitutiveFoundation.tex (lines 359-385)** currently has:
- Section `\subsubsection{Verum (Top)}` using `\top`
- Section `\subsubsection{Falsum (Bottom)}` using `\bot`

This conflates the terminology. The NOTE tag requests:
- Reserve "verum" for `\Top` (the `\neg\bot` element)
- Reserve "top" for `\top`
- Reserve "falsum" for `\Bot` (the `\neg\top` element)
- Reserve "bottom" for `\bot`

### 4. Files Requiring Updates

| File | Current State | Required Changes |
|------|---------------|------------------|
| `Theories/Logos/latex/assets/logos-notation.sty` | No `\Top`, `\Bot`, `\ver`, `\fal` macros | Add symbol definitions from IdentityAboutness.tex |
| `.claude/context/project/latex/standards/notation-conventions.md` | Has `\fullstate` and `\nullstate` but no verum/falsum | Add Bilateral Top/Bottom section with four-element documentation |
| `.claude/context/project/typst/standards/notation-conventions.md` | Has `$bot$` as `falsum` | Add distinction between top/bot and verum/falsum |
| `Theories/Logos/latex/subfiles/02-ConstitutiveFoundation.tex` | Section headers conflate terms | Rename sections and add derived constants section |

### 5. Recommended Terminology

| Symbol | LaTeX Command | Name | Definition | Ordering |
|--------|---------------|------|------------|----------|
| Standard top | `\top` | top | primitive | top for ground (<=) |
| Standard bot | `\bot` | bottom | primitive | bottom for ground (<=) |
| Strikethrough top | `\Top` or `\ver` | verum | `\neg\bot` | top for parthood |
| Strikethrough bot | `\Bot` or `\fal` | falsum | `\neg\top` | bottom for parthood |

The NOTE requests `\ver` for verum and `\fal` for falsum as shorthand commands.

## Recommendations

### Phase 1: Add Macros to logos-notation.sty

Add the following to logos-notation.sty (Bilateral Top/Bottom section):

```latex
% --- Bilateral Top and Bottom ---
% In bilateral semantics, there are TWO orderings:
%   - Ground ordering (<=): \top and \bot are top/bottom
%   - Parthood ordering (sqsubseteq): \Top and \Bot are top/bottom
% The verum and falsum are defined via negation:
%   - \ver (verum) := \neg\bot, symbolized by \Top
%   - \fal (falsum) := \neg\top, symbolized by \Bot

% Strikethrough top symbol (top with bar)
\newcommand{\Top}{%
  {\ensuremath{\mathbin{\mathrel{\ooalign{\hss$\top$\hss\cr%
  \kern0ex\raise.7ex\hbox{\scalebox{1}{$-$}}}}}}}}

% Strikethrough bot symbol (\Top rotated 180 degrees)
\newcommand{\Bot}{{\ensuremath{\mathbin{\rotatebox[origin=c]{180}{$\Top$}}}}}

% Semantic aliases
\newcommand{\ver}{\Top}   % Verum: \neg\bot, top for parthood
\newcommand{\fal}{\Bot}   % Falsum: \neg\top, bottom for parthood
```

Note: Requires `\RequirePackage{graphicx}` for `\rotatebox`.

### Phase 2: Update notation-conventions.md

Add a new section "Bilateral Top/Bottom Elements":

| Concept | Macro | Symbol | Definition | Usage |
|---------|-------|--------|------------|-------|
| Top | `\top` | T | primitive | Top element for ground ordering |
| Bottom | `\bot` | perp | primitive | Bottom element for ground ordering |
| Verum | `\ver` or `\Top` | T-bar | neg bot | Top element for parthood ordering |
| Falsum | `\fal` or `\Bot` | perp-bar | neg top | Bottom element for parthood ordering |

### Phase 3: Update ConstitutiveFoundation.tex

1. Rename section "Verum (Top)" to "Top Constant"
2. Rename section "Falsum (Bottom)" to "Bottom Constant"
3. Add new section "Verum and Falsum (Derived Constants)" after negation, explaining:
   - `\ver := \neg\bot` with verification: verified by all states, falsified by none
   - `\fal := \neg\top` with verification: verified by none, falsified by all states

## Decisions

1. **Adopt IdentityAboutness.tex conventions** as the authoritative source
2. **Use strikethrough symbols** (`\Top`, `\Bot`) as distinct from standard (`\top`, `\bot`)
3. **Add aliases** `\ver` and `\fal` for readability in semantic definitions
4. **Preserve backward compatibility** - existing uses of `\top` and `\bot` remain valid

## Risks & Mitigations

| Risk | Mitigation |
|------|------------|
| Symbol collision with existing LaTeX packages | Test compilation after adding macros |
| Confusion in existing documentation | Add explanatory comments in notation files |
| Missing graphicx package for rotatebox | Add RequirePackage directive |

## Appendix

### Search Queries Used

- Grep for `verum|falsum|\\top|\\bot|\\Top|\\Bot` in ProofChecker
- Glob for `**/*notation*.sty`
- Read of IdentityAboutness.tex lines 106-109 and 494

### Key Reference

From IdentityAboutness.tex footnote (line 494):

> "Were one to add top and bottom elements to the language, s-models must assign `|\top| = (S, emptyset)` and `|\bot| = (emptyset, {null})` which are the top and bottom elements with respect to `<=`, letting `\Top := \neg\top` and `\Bot := \neg\bot` be the top and bottom elements with respect to `sqsubseteq`."

This establishes the canonical relationship between the four constants in bilateral semantics.
