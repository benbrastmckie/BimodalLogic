# Module Docstring Quality Standard

This document defines the four-tier quality standard for module docstrings in the
`Theories/Bimodal/` library. All `.lean` files must meet at minimum the tier appropriate
for their file type.

**Last verified: 2026-05-29**

---

## Quality Tiers

### Tier 1 (Minimal) — Re-export Aggregators

**Applies to**: Files that only re-export definitions from other modules
(typically `Module.lean` root files like `WeakCanonical.lean`, `Core.lean`, etc.)

**Requirement**: Title + 1-sentence scope description

**Template**:
```lean
/-!
# ModuleName

Re-export module for `SubDir/`. Provides a unified import point for all
`SubDir` definitions and theorems.
-/
```

**Appropriate for** (~5 files): `Metalogic/WeakCanonical.lean`, `Metalogic/Core.lean`,
`Metalogic/BXCanonical.lean`, `Metalogic/Decidability.lean`, similar aggregators.

---

### Tier 2 (Standard) — Definition-Bearing Files

**Applies to**: Files containing definitions, theorems, or instances (the majority of files)

**Requirement**: Must include both "Main Definitions" and "Main Results" sections (where applicable)

**Template**:
```lean
/-!
# ModuleName

One paragraph describing the module's purpose and its role in the library.

## Main Definitions

- `TypeOrDef`: What it represents or computes.
- `AnotherDef`: What it represents or computes.

## Main Results

- `theorem_name`: Statement in plain English.
- `another_theorem`: Statement in plain English.
-/
```

**Minimum line count**: Approximately 10 lines for the docstring.

---

### Tier 3 (Rich) — Complex Implementation Files

**Applies to**: Files with non-trivial algorithms, canonical model constructions,
or significant design decisions worth preserving.

**Requirement**: Standard (Tier 2) + "Implementation Notes" or "References" section

**Additional sections**:
```lean
/-!
  ...

  ## Implementation Notes

  - Key design decision or algorithm choice
  - Non-obvious Lean encoding or tactic choice

  ## References

  - Author, Title, Year (theorem/chapter reference)
-/
```

---

### Tier 4 (Extensive) — Metalogic and Completeness Files

**Applies to**: Files in `Metalogic/` proving soundness, completeness, decidability,
or establishing canonical models.

**Requirement**: Rich (Tier 3) + proof strategy overview, plus one or more of:
dependency flowchart, literature references, sorry status

**Additional content**:
```lean
/-!
  ...

  ## Proof Strategy

  Brief overview of the proof approach used in this file.

  ## Sorry Status

  - `theorem_name`: sorry (reason: ...)

  ## Dependencies

  Depends on: `Core/MaximalConsistent.lean`, `Bundle/FMCS.lean`
-/
```

---

## Section Ordering

When multiple sections are present, use this canonical order:

1. Title and scope paragraph
2. Main Definitions
3. Main Results
4. Implementation Notes
5. Proof Strategy
6. Sorry Status
7. Dependencies
8. References

---

## API Docstrings

In addition to module-level docstrings (`/-! ... -/`), **all public definitions**
should have term-level docstrings (`/-- ... -/`):

```lean
/-- The main inductive type for TM bimodal logic formulas.
    Constructors: `atom`, `bot`, `imp`, `box`, `all_past`, `all_future`. -/
inductive Formula : Type where
  ...
```

**Exceptions**: Re-export lines (`open`, `export`, `variable`) do not need docstrings.
Re-export aggregator files need only the module-level docstring.

---

## Thin-Docstring Detection

Use this command to find files with fewer than 10 lines of module docstring:

```bash
# Files with thin module docstrings (less than 10 lines)
for f in $(find Theories/Bimodal -name "*.lean" | grep -v Boneyard); do
  count=$(sed -n '/^\/\-\!/,/^\-\//p' "$f" | wc -l)
  if [ "$count" -lt 10 ]; then echo "$count $f"; fi
done | sort -n
```

---

## Mathlib Alignment

Module docstring style follows Mathlib 4 conventions:
- Use `/-! ... -/` for module-level docstrings (not `--`)
- Use `/-- ... -/` for definition-level docstrings
- Section headers use `##` (not `###`)
- Lean identifiers are backtick-quoted in docstrings
