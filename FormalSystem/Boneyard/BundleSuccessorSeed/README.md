# BundleSuccessorSeed -- Dead Successor/Predecessor Seed Construction

Archived from `FormalSystem/Metalogic/Bundle/SuccExistence.lean`.

## Purpose of the Archived Code

This file attempted to prove successor and predecessor *existence* for the canonical Succ
relation: for any MCS `u` with `F(⊤) ∈ u` there exists an MCS `v` with `Succ(u, v)`, and dually
for `P(⊤) ∈ u`. The construction went through **deferral seeds**:

```
successor deferral seed:   g_content(u) ∪ {φ ∨ F(φ) | F(φ) ∈ u}
predecessor deferral seed: h_content(u) ∪ {φ ∨ P(φ) | P(φ) ∈ u}
```

Consistency of the seed was the load-bearing step; everything downstream (Lindenbaum extension,
`Succ` verification, f-step / p-step / persistence lemmas) followed mechanically from it.

## File Inventory

| File | Lines | Declarations | Sorries |
|------|------:|-------------:|--------:|
| `SuccExistence.lean` | 1,218 (1,178 original + archive header) | 72 | 3 |

## Why It Is Dead

**Zero live consumers, anywhere.** All 72 declarations were grepped by word boundary across
`FormalSystem/` and `Tests/`. The file's two headline results, `successor_exists` and
`predecessor_exists`, have no code references at all. The only external occurrences of any name
defined here are prose inside docstrings and `--` comments:

```
SuccRelation.lean:443,480,491,509,516   -- prose about the deferral seeds
CanonicalTaskRelation.lean:694          -- prose about predecessor_satisfies_p_step
```

This is confirmed independently by a whole-environment `Lean.collectAxioms` taint scan: the three
sorries here taint a 36-declaration closure that is *entirely contained* in this file plus
`Bundle/SuccRelation.lean`. Had any Chronicle or WeakCanonical declaration consumed
`successor_exists`, it would have appeared in the tainted set. None did.

`Metalogic/Core/RestrictedMCS/Basic.lean` did `import FormalSystem.Metalogic.Bundle.SuccExistence`,
but used no declaration from it — a stale import edge, not a dependency. That import line was
deleted when this file was archived.

## The Three Sorries and Their Shared Root Cause

| Declaration | Hole |
|-------------|------|
| `constrained_successor_seed_consistent` | `g_content u ⊆ u` |
| `successor_deferral_seed_consistent_axiom` | `g_content u ⊆ u` |
| `predecessor_deferral_seed_consistent_axiom` | `h_content u ⊆ u` |

All three are literally the same obligation:

```lean
have h_g_content_in_u : g_content u ⊆ u := by
  sorry
```

`g_content u ⊆ u` is `G φ ∈ u → φ ∈ u` — the **T-axiom for `G`** (dually `H`). It is not merely
unproven; it is *false* under the current open-guard `(t,s)` irreflexive semantics, and is
already recorded as unsound in `../TAxiomDependentCode/`. The equivalent standalone statements
`g_content_subset_mcs` / `h_content_subset_mcs` were excised from `Bundle/SuccRelation.lean` in
the same archival pass and now live in
`../SorriedDeclExcisions/BundleUntilSinceStep.lean`.

Each enclosing docstring still reads "**Status**: PROVEN under BX1 (reflexive G)". That is stale
text predating BX1's removal; the proof route it names no longer exists.

## Why the Two `..._axiom` Declarations Were Not Axiomatized

The `_axiom` suffix on `successor_deferral_seed_consistent_axiom` and
`predecessor_deferral_seed_consistent_axiom` suggested they might be intended assumptions worth
promoting to declared Lean `axiom`s. That was considered and **rejected**, for two independent
reasons:

1. **Nothing live consumes them.** An axiom exists to discharge an obligation something else
   needs. Declaring an axiom no live result uses adds trust surface for zero benefit — strictly
   worse than archiving.
2. **The justification is itself unsound.** Both bodies reduce to the T-axiom for `G`/`H`, and
   the only written support for them is the removed BX1. The *statements* (that the deferral
   seeds are consistent) may well be true for other reasons — the standard seriality argument —
   but nothing in this file establishes that. Axiomatizing a claim whose sole written
   justification is a deleted, unsound axiom is exactly the failure mode the Boneyard convention
   exists to prevent.

## Relationship to Active Code

Nothing active depends on this directory. The live canonical-model path does not use deferral
seeds at all.

See the sibling `../RestrictedMCSDeferral/`, which archives the deferral-restricted MCS
(`deferralClosure`) variant of this same successor-seed construction, also for having no live
consumers. The two directories are the two halves of one abandoned approach; consult both
together if this route is ever revisited.

## Build Policy

Never compiled. `#exit` sits immediately after the import block and the archive docstring. The
import lines are historical text kept verbatim and are not repaired.
