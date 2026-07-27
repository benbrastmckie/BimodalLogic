# Implementation Summary: Task #406

- **Task**: 406 - Prove semantic validity of the Sep axiom over real flow (Reynolds 1992 §7 lemma 10)
- **Plan**: `specs/406_prove_semantic_validity_of_the_sep_axiom_over_real_flow_reynolds_1992_section_7_lemma_10/plans/01_sep-validity-transcription.md`
- **Status**: COMPLETED (all 3 phases)
- **Type**: lean4

## What Was Done

Both `sorry` bodies in the Dedekind soundness chain are discharged. The in-closure `sorry` count
dropped from 3 to 1; the single survivor is `FormalSystem/Metalogic/WeakCanonical/Transfer.lean:1242`,
which the plan places out of scope.

### Phase 1 — Separability of the flow

Created `FormalSystem/Metalogic/SoundnessLemmas/Separability.lean` (new module, no `FormalSystem`
import; only `Mathlib.Algebra.Order.Archimedean.Basic` and `Mathlib.Data.Set.Countable`). Contents:

- `exists_isGLB_of_lub` (private) — deliberate duplicate of the `Soundness.lean` helper, which is
  `private` there and must stay for `prior_S_gap_valid`.
- `exists_half_le`, `arch_of_lub`, `exists_null_seq` (private) — the ordered-group route to
  Archimedean-ness. There is no Mathlib route: the available instance covers fields only.
- `exists_countable_order_dense` (public) — the flow has a countable order-dense subset.

### Phase 2 — The order-theoretic core

Appended `nested_core`, `sep_order`, `sep_order_mirror`. `sep_order_mirror` instantiates
`sep_order` at `Dᵒᵈ` with explicit `OrderDual.toDual`/`ofDual` coercions (about 20 lines instead of
a ~130-line hand-mirror), and the `h_lub` hypothesis transports via `exists_isGLB_of_lub`.

### Phase 3 — The two validity lemmas and comment cleanup

- `Soundness.lean` gained `import FormalSystem.Metalogic.SoundnessLemmas.Separability`.
- `sep_valid` and `sep_swap_valid` proved, statements unchanged, kept as two separate lemmas.
  Both call sites (`axiom_dedekind_valid`, `axiom_dedekind_swap_valid`) are unedited.
- `sep_valid`'s docstring records the source (Reynolds §7 lemma 10), the separability input and
  why the algebraic binders are load-bearing, and the fidelity deviation.
- `sep_swap_valid`'s docstring keeps the existing "genuinely separate semantic fact / not a
  conjunction" paragraph and adds the `sep_order_mirror` reuse note.
- The section-comment debt paragraph was deleted wholesale; the two now-false comments
  ("strategic-sorry lemmas", "the only debt in this theorem") were corrected.
- `SoundnessLemmas/README.md` gained the `Separability.lean` row; date refreshed.

## Recorded Fidelity Deviation

Reynolds' step 7 (thin `S` to a countable dense order, invoke Cantor's `≅ ℚ` theorem, count gaps,
compare cardinals) is replaced by an equivalent Baire-style nested-interval construction over ℕ
(`nested_core`). Steps 1-6 are followed as written. The substitution uses the same essential input
— separability — repackaged as "each `I_u` contains a point of a fixed countable dense `Q`", which
is the standard proof of Reynolds' cardinality step. Adopted because the `≅ ℚ` route needs
Cantor's back-and-forth theorem and would drag `Cardinal` into the soundness chain. This is
recorded in the `sep_valid` docstring, per the plan's requirement that the divergence not be silent.

## Non-Transferable Constraint Honoured

Sep is FALSE over order-only dense Dedekind-complete flows (lexicographic-square counterexample).
No attempt was made to weaken the binder set to `ValidDedekind` or to reuse the Prior lemmas'
"density/algebra unused" observation. Every algebraic binder is consumed in Phase 1.

## Verification

| Check | Result |
|---|---|
| `lake build` | EXIT=0 |
| `lake build BimodalTest` | EXIT=0 |
| In-closure `sorry` count | 1 (`WeakCanonical/Transfer.lean:1242` only) |
| `#print axioms sep_valid` | `[propext, Classical.choice, Quot.sound]` |
| `#print axioms sep_swap_valid` | `[propext, Classical.choice, Quot.sound]` |
| `#print axioms axiom_dedekind_valid` / `_swap_valid` | clean |
| New `axiom` declarations | 0 |
| Task-number citations in touched `.lean` files | none |
| `WeakCanonical/` touched | no |

Axiom checks were run through a scratch file with `lake env lean` from the project root, per the
plan's verification-tooling section; `lean_run_code` was not used.

## Plan Deviations

- **Phase 2 verification criterion** *(altered)*: the plan asserts no `simp`-family tactic appears
  in `nested_core` or `sep_order`. Report §7.3, the authoritative tactic text, itself uses
  `simp_all` twice — in the `| zero =>` base cases of `hmonoA`/`hmonoB` inside `nested_core` —
  where it closes the ℕ-induction bookkeeping goal `m ≤ 0 → (seq m).1 ≤ (seq 0).1`, not an
  order-theoretic step. Transcribed verbatim per plan-compliance; annotated inline in the plan.
  No `aesop`/`omega`/`decide` appears anywhere, and no mathematical step is automated.
- **Namespace qualification in report §7.4** *(altered)*: because Phases 1-2 landed in a separate
  module rather than inline (the placement the plan chose), the three cross-module references in
  the Phase 3 glue are written `SoundnessLemmas.exists_countable_order_dense`,
  `SoundnessLemmas.sep_order`, `SoundnessLemmas.sep_order_mirror` instead of bare. The report's
  verification file held everything in one namespace. No tactic text changed.

## Artifacts

- `FormalSystem/Metalogic/SoundnessLemmas/Separability.lean` (new, 346 lines)
- `FormalSystem/Metalogic/Soundness.lean` (modified)
- `FormalSystem/Metalogic/SoundnessLemmas/README.md` (modified)
