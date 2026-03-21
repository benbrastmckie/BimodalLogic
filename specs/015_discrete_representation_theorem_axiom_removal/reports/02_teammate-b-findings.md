# Teammate B Findings: Singleton BFMCS Cleanup

**Task**: 15 - discrete_representation_theorem_axiom_removal
**Date**: 2026-03-21
**Focus**: Singleton BFMCS artifacts cleanup and ROAD_MAP.md deadend documentation

---

## Key Findings

### 1. The Sorry in SuccChainBFMCS.lean is Definitively Unprovable

`SingletonBFMCS.modal_backward` (line 94 of `Theories/Bimodal/Metalogic/Bundle/SuccChainBFMCS.lean`) contains a `sorry` that is mathematically impossible to prove. The goal is:

> `phi ∈ MCS → Box(phi) ∈ MCS`

This is the converse of the T-axiom (`Box(phi) → phi`), which TM logic does NOT have. The comment on lines 76-93 documents this failure explicitly: "This axiom is semantically justified for the intended use case... sorry". The code even references "Option B" (the sorry-deferral pattern from the research report), which is the exact pattern Task 15 was meant to resolve.

### 2. This Is a Known Pattern Already Documented in ROAD_MAP.md

ROAD_MAP.md already has TWO dead end entries documenting why singleton/single-family approaches fail modal_backward:

- **"Dead End: Single-Family BFMCS modal_backward"** (lines 916-938): Documents the general failure — `phi → Box(phi)` is not a theorem of TM logic.
- **"Dead End: Singleton Bundle Modal Saturation"** (lines 941-968): Documents Task 1002/1003's attempt specifically with the CanonicalMCS singleton — fails because `Diamond(psi) ∈ t.world → psi ∈ t.world` is false in S5.

The `SuccChainBFMCS.lean` file was created by Task 15's implementation phase AFTER these dead ends were documented, repeating the same fundamental error.

### 3. The File Contains Misleading Comments

`SuccChainBFMCS.lean` contains comments (lines 17-19) presenting singleton modal coherence as "trivial":

```
## Key Insight
A singleton BFMCS has trivial modal coherence:
- modal_backward: phi in all families (just itself) implies Box phi by MCS T-axiom closure
```

This is **false**. The T-axiom closure gives `Box(phi) → phi`, not `phi → Box(phi)`. The file's own sorry (line 94) contradicts this "trivial" claim.

### 4. DiscreteInstantiation.lean Documents the Sorry Dependency

`DiscreteInstantiation.lean` lines 187 explicitly lists:
```
- `SingletonBFMCS.modal_backward`: Singleton modal coherence (sorry)
```

So the sorry propagates all the way to `discrete_representation_unconditional`, making that theorem depend on an unprovable axiom.

### 5. Research Report (01) Recommended Option B — Which Is Now Blocked

The original research report (`reports/01_discrete-rep-research.md`, lines 208-220) recommended "Option B: Accept Axioms as Semantic Debt" with the note "The axioms are mathematically sound". However, `modal_backward` is NOT semantically sound in the general case — it fails for contingent formulas. This makes Option B (the current implementation) fundamentally flawed for modal coherence.

### 6. Files Referencing Singleton BFMCS Approach (Active Tree)

| File | Line | Reference Type |
|------|------|----------------|
| `Theories/Bimodal/Metalogic/Bundle/SuccChainBFMCS.lean` | Full file | Core singleton implementation (has sorry) |
| `Theories/Bimodal/Metalogic/Algebraic/DiscreteInstantiation.lean` | 2, 178, 181-188 | Imports and uses SuccChainBFMCS |
| `specs/015_discrete_representation_theorem_axiom_removal/plans/01_discrete-rep-plan.md` | 28, 79 | Describes singleton as plan goal |
| `specs/015_discrete_representation_theorem_axiom_removal/reports/01_discrete-rep-research.md` | 123, 241, 243 | Recommends Option B / singleton approach |

---

## Recommended Cleanup Actions

### Action 1: Mark SuccChainBFMCS.lean as Deprecated

Add a DEPRECATED banner at the top of `Theories/Bimodal/Metalogic/Bundle/SuccChainBFMCS.lean`:

```lean
/-!
# DEPRECATED: Singleton BFMCS Construction

This module attempts to wrap a SuccChainFMCS as a singleton BFMCS. The approach
is a DEAD END because `SingletonBFMCS.modal_backward` requires `phi → Box(phi)`,
which is not a theorem of TM logic.

See ROAD_MAP.md: "Dead End: Singleton BFMCS for Discrete Representation"

**Do not use**: SingletonBFMCS, SuccChainBFMCS, construct_bfmcs_impl
**Status**: Archived pending task cleanup
-/
```

### Action 2: Decouple DiscreteInstantiation.lean from SuccChainBFMCS

The import `import Bimodal.Metalogic.Bundle.SuccChainBFMCS` in `DiscreteInstantiation.lean` (line 2) should be removed, and `discrete_representation_unconditional` (lines 191-197) should be commented out or changed to use the conditional form only. The conditional theorem `discrete_representation_conditional` is sound and should be preserved.

### Action 3: Correct Misleading Comments in SuccChainBFMCS.lean

The "Key Insight" section (lines 17-19) claiming modal_backward is "trivial" needs to be corrected. The modal_backward property is NOT trivial and NOT provable for a singleton bundle.

### Action 4: Update Research Report Comment

The research report (`01_discrete-rep-research.md`) recommends Option B as if it produces semantically valid results. A note should acknowledge that Option B's modal_backward sorry is NOT semantically sound (not just "debt" but actually false in the general case).

### Action 5: Add to ROAD_MAP.md Dead Ends

Add a new dead end entry specifically documenting the singleton BFMCS for discrete representation (distinct from the existing entries which focused on the standard completeness path).

---

## ROAD_MAP.md Deadend Entry

Insert after the existing "Dead End: Singleton Bundle Modal Saturation" entry (around line 968):

```markdown
### Dead End: Singleton BFMCS for Discrete Representation (Task 15)

**Status**: ABANDONED
**Tried**: 2026-03-21
**Related Tasks**: Task 15 (discrete_representation_theorem_axiom_removal)

*Rationale*: Task 15's implementation plan (Option B from research) attempted to wrap
SuccChainFMCS as a singleton BFMCS to implement the `construct_bfmcs` callback required
by `discrete_representation_conditional`.

**What We Tried**:
Created `SuccChainBFMCS.lean` with `SingletonBFMCS` wrapping a single FMCS family.
`modal_forward` (T-axiom direction) was proven successfully. `modal_backward` was
attempted with the reasoning "phi in all families (just one family) implies Box phi
via MCS T-axiom closure."

**Why It Failed**:
`modal_backward` requires: if phi holds in all families (the singleton), then Box(phi)
holds in that family. This reduces to `phi ∈ MCS → Box(phi) ∈ MCS`, i.e., `phi → Box(phi)`.
This is the CONVERSE of the T-axiom, which TM logic does NOT have. The proof obligation
is mathematically impossible for contingent formulas. This is the same fundamental failure
as the earlier "Single-Family BFMCS modal_backward" dead end.

**Evidence**:
- [SuccChainBFMCS.lean line 94](Theories/Bimodal/Metalogic/Bundle/SuccChainBFMCS.lean) — sorry at modal_backward
- [Task 15 meta](specs/015_discrete_representation_theorem_axiom_removal/.return-meta.json) — sorry_count: 1
- Related dead end: "Single-Family BFMCS modal_backward" above

**Lesson**:
The singleton bundle approach for modal_backward is blocked by the same impossibility
regardless of the underlying FMCS construction. No SuccChain FMCS construction can
circumvent the need for multiple families to witness modal_backward.

**Superseded By**: The `construct_bfmcs` callback for discrete representation requires a
multi-family BFMCS with genuine modal saturation. This is the same infrastructure needed
for standard completeness (see multi-family SaturatedBFMCS approach).

---
```

---

## Confidence Level

**High** — The findings are based on:

1. Direct reading of `SuccChainBFMCS.lean` — the sorry at line 94 with its extended comment (lines 68-93) confirms the failure and its reason.
2. Cross-reference with two existing ROAD_MAP.md dead end entries that independently document the same impossibility from different angles.
3. The mathematical impossibility is elementary: `phi → Box(phi)` fails for contingent formulas in any normal modal logic without the `4`-axiom collapse to necessitarianism.
4. The `.return-meta.json` confirms `sorry_count: 1` and `requires_user_review: true` — the implementation agent itself flagged this as requiring review.
5. `DiscreteInstantiation.lean` explicitly names `SingletonBFMCS.modal_backward` as a sorry dependency in its theorem documentation.

The cleanup actions are clear and unambiguous. The only uncertainty is whether `SuccChainBFMCS.lean` should be deleted vs. deprecated — deletion is cleaner but depends on whether any other in-progress work imports it.
