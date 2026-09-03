# Independence — underivability results

Underivability results, established by exhibiting a model of the assumptions in which the
target formula fails.

Three results are carried here, over six modules:

1. The paper's `CO` principle does **not** derive Reynolds' `Axiom.prior_U_gap` over the dense
   base. The converse direction — Reynolds' triple *does* derive `CO` — is
   `FormalSystem.Theorems.DedekindDerived.co_derived`, so the two settle the relationship in both
   directions.
2. `Sat .Dedekind ⊊ Mod (AxiomSet .Dedekind)`, witnessed by the static frame over `ℚ`.
3. `Sat .Discrete ⊊ Mod (AxiomSet .Discrete)`, witnessed by the static frame over `ℤ ×ₗ ℤ`.

Results 2 and 3 are the two halves of the finding that the frame-class *narrowings* are not
Galois-closed, in contrast with the paper's bare classes — which are closed, by
`Semantics/Correspondence/Indicator.lean`'s `galoisClosed_sat_dense` and `galoisClosed_isDiscrete`.

Every result here follows the same four steps: build a concrete frame satisfying every
structural axiom of the semantics; prove a truth-invariance lemma for it (a symmetry or
periodicity constraining *every* formula uniformly, by induction on `Formula` with the history
universally quantified **inside** the induction, so the `□` case can apply the inductive
hypothesis); derive validity of the assumptions; and exhibit a valuation refuting the target.

## Modules

| File | Lines | Description |
|------|-------|-------------|
| `ClockFrame.lean` | 236 | The periodic clock frame: temporal order `D = ℚ`, world-state carrier the rational circle `W = ℚ ⧸ ℤ`, task relation the deterministic translation flow. All `TaskFrame` obligations discharged, with a reference total history. |
| `CoNotPriorU.lean` | 552 | The symmetric irrational arc valuation on the clock frame, the refutation of `Axiom.prior_U_gap` in that model, and the two independence statements. |
| `LoopingDuration.lean` | 235 | The reusable content. A frame carrying a *looping duration* (a nonzero `π` whose task relation is the identity) has periodic histories, hence periodic truth, hence validates `Hψ → Gψ` and every instance of `CO`. Proved for an arbitrary such frame. |
| `StaticFrame.lean` | 323 | The static frame at an arbitrary duration group: every nonzero duration loops, so truth is time-invariant, and the `untl`/`snce` clauses collapse into a small constant-truth calculus (general, dense and discrete forms, plus `K⁺`/`K⁻` and `Axiom.z1`). Turns every later axiom check into a rewrite. |
| `RationalWitness.lean` | 200 | `rat_not_complete` — `ℚ` is not Dedekind-complete, written out because Mathlib carries no statement in this shape — and the static frame over `ℚ` as a member of `Mod (AxiomSet .Dedekind)` outside `Sat .Dedekind`, with the Dedekind sandwich. |
| `LexIntWitness.lean` | 200 | The discrete, non-Archimedean carrier `ℤ ×ₗ ℤ`, the static frame over it as a member of `Mod (AxiomSet .Discrete)` outside `Sat .Discrete`, the semantic upper-bound engine `validOn_nextTop_of_mem_mod_discrete`, and the Discrete sandwich. |

## Key Results

- `co_not_derives_prior_U` and its companion (`CoNotPriorU.lean`) — the independence
  statements.
- `states_add_of_looping` and `truthAt_add_period` (`LoopingDuration.lean`) — history
  periodicity and truth periodicity from a looping duration alone.
- `clockFrame` (`ClockFrame.lean`) — the witness frame, with every structural axiom discharged.
- `static_time_invariant` and the `static_untl_iff*` family (`StaticFrame.lean`) — the
  constant-truth calculus both non-closure witnesses run on.
- `sat_dedekind_ssubset_mod_axiomSet` (`RationalWitness.lean`) and
  `sat_discrete_ssubset_mod_axiomSet` (`LexIntWitness.lean`) — `Sat .Dedekind` and
  `Sat .Discrete` are strictly smaller than the model classes of their axiom sets, hence not
  Galois-closed.

## Dependencies

- **Imports from**: `FormalSystem.Semantics` (including
  `Semantics.Correspondence.{Galois, Indicator}` for the two sandwich statements),
  `FormalSystem.Metalogic.Soundness`, `FormalSystem.ProofSystem`, Mathlib's `ℚ ⧸ ℤ`
- **Imported by**: `FormalSystem.Metalogic.Independence` (the sibling aggregator)

## Related Documentation

- [Metalogic README](../README.md)
- [Theorems README](../../Theorems/README.md) — `DedekindDerived.co_derived`, the converse
  direction

---

**Last verified**: 2026-09-02
