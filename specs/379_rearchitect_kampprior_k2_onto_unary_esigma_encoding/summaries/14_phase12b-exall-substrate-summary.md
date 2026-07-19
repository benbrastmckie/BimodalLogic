# Phase 12b (δ ex/all closure, path (c)) — Execution Summary

**Task**: 379 · **Phase**: 12b · **Agent**: lean-implementation-hard-agent · **Status**: PARTIAL
**Build**: `lake build` EXIT 0 @1770 jobs · **Spine**: `completeness_discrete` axiom set unchanged

## What was delivered

The complete **eval-side + pin-rank substrate** that report 14's path (c) requires to close the
`ex`/`all` cases of `translate_correct`, all landed **axiom-clean** (`[propext, Classical.choice,
Quot.sound]`) and **off the live import path**, in `Prop43Translate.lean` §0:

| Object | Statement | Role |
|---|---|---|
| `MonadicFormula.rename` + `eval_rename` | `eval M env' (α.rename ρ) = eval M (env' ∘ ρ) α` | variable reindexing + eval-naturality (generalizes landed `lift`/`lift_eval`) |
| `MonadicFormula.size` + `size_rename` | `(α.rename ρ).size = α.size` | rename-preserving well-founded measure (auto-`sizeOf` is not, it counts `Fin` indices) |
| `MonadicFormula.subst0` + `eval_subst0` + `size_subst0` | `eval env (α.subst0 i) = eval (Fin.cons (env i) env) α` | tie substitution `x = env i`, closes the `m` tie positions |
| `ExistsForallFormula.renamePin` + `efSat_renamePin` + `veeSat_renamePin` | `efSat N env (ψ.renamePin σ) ↔ efSat N (env ∘ σ.symm) ψ` | ∃∀-side free-variable permutation — pushes a gap witness to rank 0 |

`renamePin`/`veeSat_renamePin` **discharge report 14 §4's single flagged UNVERIFIED / highest-risk
item** (the per-gap reindex-then-∃-close pin-rank bookkeeping). It turned out to be a clean ~15-line
reindex because `efSat`'s environment enters only through the pin clause.

## What remains (the residual strategic sorries)

`translate_correct` still carries its two pre-existing tracked strategic sorries (`all` at :375,
`ex` at :384), now precisely scoped. The residual is the **assembly**, not any missing substrate:

1. Restructure `translate_correct` from structural `induction φ` to **well-founded induction on
   `MonadicFormula.size`** (needed even for ties: `α.subst0 i` / `α.rename σ_p` are size-smaller but
   not structural subterms of `.ex α`).
2. Two remaining new lemmas: the concrete insertion permutation `σ_p : Equiv.Perm (Fin (m+1))` with
   `Fin.cons a env = insertEnv ⟨p,_⟩ a env ∘ σ_p`, and `insertEnv`-StrictMono (`a` in gap `p` ⟹
   `StrictMono (insertEnv p a env)`).
3. The `∃ x` order-type split (m ties + m+1 gaps) with two-direction disjunction assembly; `all` via
   the eval `¬∃¬` De Morgan bridge + two landed `veeSat_negation`.

## Why deferred (bounded-attempt discipline)

The assembly (~200-300 lines of Fin-permutation bookkeeping, report 14 rated Medium/UNVERIFIED)
exceeds one bounded dispatch. Completing it requires restructuring the proven `translate_correct`; a
partial restructure risks leaving it RED, and recovery discipline forbids reverting landed work. Per
the bounded-attempt clause, the substrate was landed and committed incrementally (3 green commits)
and the residual left as the tracked strategic sorries with a precise handoff.

## Verification

- `sorry_count` = 2 (both tracked strategic, off live path, lines 375/384) · `vacuous_count` = 0 ·
  `axiom_count_new` = 0
- Full `lake build` EXIT 0 @1770 jobs (baseline)
- `completeness_discrete` axioms byte-identical to baseline; sole on-path `sorryAx` remains
  `KampPrior.lean:562` (Phase 13)
- Import audit: no module imports `Prop43Translate`

## Plan deviations

None from Phase 12b's path-(c) mandate. Landed the specified substrate exactly (rename, size,
subst0, renamePin). The assembly step was deferred (not altered/substituted) per the bounded-attempt
clause; `StrictMono` gate not dropped; BLOCKED `Prop43.lean` not revived.
