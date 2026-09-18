# ADR-008: `FrameClass.Sat` Lives in `Semantics/`, and the Seam Stays There

## Status

**Accepted** - 2026-09-07

## Context

`FormalSystem/Semantics/FrameClassValidity.lean` is the **only** module under
`FormalSystem/Semantics/` that imports anything from `FormalSystem/ProofSystem/`. It defines
`FrameClass.Sat : FrameClass -> TaskFrame -> Prop`, the semantic reading of the proof-side
`FrameClass` tag, so that the semantic side can be indexed by the same tag the proof side already
carries instead of by a hand-maintained binder list.

The seam is confined to that one module on purpose: `Sat` is the single point at which a
proof-side tag acquires a semantic meaning, so it is the single point at which the two layers
need to meet. Acyclicity is verified rather than assumed —
`FormalSystem/ProofSystem/Axioms.lean` imports only `FormalSystem.Syntax.Formula`, and no file
anywhere under `FormalSystem/ProofSystem/` imports `FormalSystem.Semantics` or any of its
submodules, so the edge closes no cycle.

## Decision

Keep `FrameClass.Sat` in `Semantics/FrameClassValidity.lean` and the validity layer built on it
(`ValidOnFrames`, `ValidIn`, and the monotonicity and migration lemmas) in
`Semantics/Validity.lean`, which imports it.

The seam has two acceptable resolutions and two rejected relocations. This ADR records the
rejected ones, so that the rationale does not have to live in a module docstring.

### Rejected: relocate `inductive FrameClass` into a shared low-level module

This would remove the `Semantics -> ProofSystem` import edge entirely. It would also move a
namespace carrying the axiom constructors (29 since the primitive set was aligned with the paper), along with every `DerivationTree` / `Derivable`
signature that names them, into a module below both layers. The edge it removes is a single
import of `ProofSystem/Axioms.lean`, which itself imports only `Syntax/Formula.lean`; the churn
it creates touches the whole proof side. Rejected on cost.

### Rejected: relocate the four class-restricted validity predicates

`ValidIn` is defined through `TaskFrame.ValidOn` (`def:frame-validity`), declared in
`Semantics/Validity.lean`, and `Validity.lean`'s own class-restricted predicates (`ValidDense`,
`ValidZTime`, `ValidComplete`, `ValidRTime`) are instances of `ValidIn` / `ValidOnFrames`. Those
two facts cannot both hold with `ValidIn` downstream of `Validity.lean`. Moving the four
predicates into `FrameClassValidity.lean` and re-exporting them would have forced a new import
line into each of the roughly 27 files that consume them today, for no gain in layering.
Rejected on cost.

## Consequences

- One import edge, `Semantics -> ProofSystem.Axioms`, is accepted and documented rather than
  engineered away. It is checked: C4 resolves every import line, and the acyclicity argument
  above is a statement about the tree that a reader can verify with `grep`.
- The four class-restricted validity predicates stay in `Semantics/Validity.lean`, where their
  roughly 27 consumers already find them.
- Because the frame condition is read off the tag rather than inlined, there is nothing to keep
  in sync between a class and its binder list — which is the drift this arrangement exists to
  prevent.

## Related

- `FormalSystem/Semantics/FrameClassValidity.lean` — points here rather than restating this
- `FormalSystem/Semantics/Validity.lean` — the validity layer built on `Sat`
- `FormalSystem/Semantics/FrameProperty.lean` — the frame predicates `Sat` interprets into
