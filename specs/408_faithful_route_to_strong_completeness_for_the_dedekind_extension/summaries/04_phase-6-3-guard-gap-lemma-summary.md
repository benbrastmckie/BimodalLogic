# Phase 6.3 Summary — The guard gap lemma

- **Plan**: `plans/04_strong-completeness-dedekind-v4.md`, Phase 6.3 (now `[COMPLETED]`)
- **Commit**: `bfdd87a6f`

## Phases executed

Phase 6.3 only (single-phase dispatch). Phases completed: 9 of 12.

## Declarations landed

| Declaration | File | Status |
|---|---|---|
| `limitGuardBelow_of_priorS` | `FormalSystem/Metalogic/BXCanonical/Chronicle/ChronicleLimitGuardWitness.lean` (new, 207 lines) | sorry-free |
| `cantor_bfmcs_dense_limit_guard_below` | same | sorry-free |
| `BFMCS.LimitGuardBelow` | `FormalSystem/Metalogic/Bundle/RealExtensionBundle.lean` (appended def + docstring only) | definition |

One import line added to `FormalSystem/Metalogic/BXCanonical.lean` (the real `Chronicle/`
aggregator).

## Proof shape

Exactly as specified: a direct two-case split on `ψ.neg.somePast ∈ m t` at a rational
`t ∈ (r, c)`. Case 1 (`P(¬ψ) ∉ m t`) contraposes backward Since coherence and needs no axiom.
Case 2 assembles the Prior-S antecedent `S(⊤, ψ) ∧ P(¬ψ)` — the guard hypothesis supplies
`S(⊤, ψ)` for free — applies `Axiom.prior_S_gap` at `ψ` via `theorem_in_mcs`/`conj_mcs`/
`implication_property`, then reads the consequent backwards through forward Since coherence and
places the resulting rational `w` strictly below `r` by trichotomy. Unselectedness of `r` is used
exactly once, to exclude `(w : ℝ) = r`. No outer `by_contra`, no Step-D double-negation dance.

## Literature grounding

Reynolds 1992 printed p.175 (`γ⁻` / right gaps) was read verbatim from the local corpus
(`sources/reynolds_1992/sec06_5-expressive-dedekind-completeness.md`) and matches the plan's quote
character for character; the Theorem 3 Prior-U/Prior-S contradiction passage (printed p.176) was
likewise verified in place. Burgess 1982 I (printed pp.369, 372-373) and Burgess 1984 (printed
pp.109-110) are cited in the module docstring by printed page, never by `md:NN`. The
expressive-completeness non-inheritance caveat (Reynolds' §6 Lemma 2, printed p.177) is recorded:
`ψ` is a hypothesis binder here, never a constructed formula.

## Verification

- `lake build FormalSystem.Metalogic.BXCanonical.Chronicle.ChronicleLimitGuardWitness`: green on
  the first attempt, no failed proof attempts.
- Full `lake build`: green.
- Live sorries outside `Boneyard/`: exactly `WeakCanonical/Transfer.lean:1242` — unchanged.
- Vacuous definitions introduced: 0. New axioms: 0.
- `#print axioms limitGuardBelow_of_priorS` = `[propext, Classical.choice, Quot.sound]`
- `#print axioms cantor_bfmcs_dense_limit_guard_below` = `[propext, Classical.choice, Quot.sound]`

## Sorry inventory

Empty.

## Plan deviations

None. All three statements landed at the exact signatures the plan specifies, in the specified
files, with the specified decomposition. `BFMCS.LimitGuardBelow` carries no closure hypothesis and
no `root` argument, as required.
