# Implementation Plan: Task #154 - Sum Preservation via Joint NF Induction (Revised)

- **Task**: 154 - sum_preservation_ef_games
- **Status**: [NOT STARTED]
- **Effort**: 12 hours
- **Dependencies**: None (NormalForm.lean infrastructure already complete; Phase 1 already completed)
- **Research Inputs**: specs/154_sum_preservation_ef_games/reports/02_team-research.md, specs/154_sum_preservation_ef_games/reports/03_team-research.md
- **Artifacts**: plans/03_sum-preservation-plan.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: true

## Overview

Prove `sum_preservation` (NEquivalence.lean) and `doets_lemma_1_4` (OrderedSum.lean): k-equivalence is preserved under ordered sums of monadic structures. Phase 1 (orderedSum definition with `Sigma.Lex.linearOrder` carrier order) is already completed. The previous implementation attempt (plan 02) built ~375 lines of `sum_nf_agree` with 4 remaining sorries, all in the order atom case for extended environments. Team research (report 03, 4 teammates) confirmed the blocker is fundamental: the per-element 1-variable NF invariant (`h_elem`) cannot encode pairwise order relationships because `AtomKind sig 1` has zero order atoms. The fix is to completely rewrite `sum_nf_agree` with a joint multi-variable NF characteristic equality as the induction invariant, mirroring how `nf_agreement_monotone` (NormalForm.lean:339-421) handles the same challenge within a single structure. This revision replaces the blocked Phases 2-3 with a restructured proof approach and adjusts Phase 4 accordingly.

### Research Integration

- **Report 02** (team-research.md, round 2): Established normal form induction as the correct strategy, identified carrier_order type-signature blocker, estimated 250-400 lines. Integrated in plan version 02.
- **Report 03** (team-research.md, round 3): Confirmed order atom blocker is genuine. Key findings: `AtomKind sig 1` has zero order atoms (Teammate C); 3 of 4 sub-cases per sorry are closable but 1 is structurally stuck (Teammate C); joint multi-variable NF characteristic equality is the consensus fix (all 4 teammates); finite index sets suffice for the Reynolds pipeline as a fallback (Teammate D). Integrated in this plan version.

### Prior Plan Reference

Plan 02 (specs/154_sum_preservation_ef_games/plans/02_sum-preservation-plan.md): Phase 1 completed, Phases 2-3 blocked on order atom gap, Phase 4 partially completed (doets_lemma_1_4 closed but transitively sorry-dependent). This plan supersedes plan 02 with restructured Phases 2-3.

### Roadmap Alignment

No explicit ROADMAP.md items reference task 154. This task advances the Reynolds pipeline infrastructure: `sum_preservation` is required by `very_good_implies_good` (Reynolds Lemma 16) which feeds `chronicle_is_good` and ultimately `doets_countermodel_discrete`. Not on the critical path (chronicle fallback provides discrete completeness) but enables the Reynolds pipeline as the primary path.

## Goals & Non-Goals

**Goals**:
- Rewrite `sum_nf_agree` in NEquivalence.lean using a joint ordered-sum NF characteristic equality invariant instead of the broken `h_atoms` + `h_elem` per-element invariant
- Close all 4 remaining sorries in NEquivalence.lean (lines 264, 334, 400, 459)
- Verify that `sum_preservation_proof` and `KEquivalenceFramework.sum_preservation` compile sorry-free
- Verify that `doets_lemma_1_4` in OrderedSum.lean is transitively sorry-free
- Clean `lake build` with no new sorries

**Non-Goals**:
- Proving `doets_lemma_1_5` (type-matching variant, not on discrete critical path)
- Closing downstream sorries: `finite_structures_good`, `contemp_equiv_is_equiv` transitivity, `no_gaps_discrete`, `very_good_implies_good`, `chronicle_is_good`
- Implementing EF games (no Mathlib infrastructure; normal form induction is superior)
- Refactoring `KEquivalenceFramework` typeclass structure
- Restricting `sum_preservation` to finite index sets (proving the full generality)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Joint NF invariant requires extracting same-component sub-environments from `Fin n -> Sigma ...`, which is awkward in dependent type theory | H | H | Define a dedicated `same_comp_env` helper that filters and re-indexes the environment; use `Finset.filter` on `Fin n` to identify same-component positions |
| The ordered-sum-level NF transfer requires relating component-level quantifier transfer to ordered-sum-level NF satisfaction, involving non-trivial term construction | H | M | Follow `nf_agreement_monotone` pattern exactly: use `nf_exists_unique` to get the unique NF, transfer via quantifier part, apply `nf_agreement_from_shared_nf` |
| Fin.cons transport and sigma lex type coercions create excessive bureaucracy in the rewritten proof | M | H | Budget extra lines for transport helpers; define reusable simp lemmas for `orderedSum` atom evaluation |
| The complete rewrite of `sum_nf_agree` exceeds 400 lines | M | M | Decompose into clearly-scoped helper lemmas: atom evaluation decomposition, component NF transfer, same-component sub-environment extraction |
| Proof exceeds context window during implementation | M | L | Phase 2 produces helper infrastructure in isolation; Phase 3 assembles the main proof using those helpers |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2 | 1 |
| 3 | 3 | 2 |
| 4 | 4 | 3 |

Phases are sequential: each phase depends on the previous one.

---

### Phase 1: Define orderedSum and Fix carrier_order Sorries [COMPLETED]

**Goal**: Replace all `carrier_order := sorry` with a proper lexicographic order construction using Mathlib's `Sigma.Lex.linearOrder`.

**Tasks**:
- [x] Import `Mathlib.Data.Sigma.Order` in NEquivalence.lean
- [x] Define `orderedSum` helper function with `Sigma.Lex.linearOrder`
- [x] Replace inline `carrier_order := sorry` in `sum_preservation` field with `orderedSum`
- [x] Replace inline `carrier_order := sorry` in `doets_lemma_1_4` and `doets_lemma_1_5` with `orderedSum`
- [x] Run `lake build` and verify no errors from carrier_order changes

**Timing**: 2 hours (completed)

**Depends on**: none

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/NEquivalence.lean`
- `Theories/Bimodal/Metalogic/WeakCanonical/OrderedSum.lean`

**Verification**:
- `lake build` succeeds with no new errors
- `grep -n "carrier_order := sorry"` returns no matches
- Completed in plan 02 implementation round

---

### Phase 2: Define Helper Infrastructure for Joint NF Proof [NOT STARTED]

**Goal**: Define the helper lemmas and infrastructure needed by the restructured `sum_nf_agree`, including ordered-sum atom evaluation decomposition, component-level NF transfer extraction, and the key `sum_nf_agree_core` lemma that replaces the broken proof.

**Tasks**:
- [ ] Delete the existing `sum_nf_agree` proof body (lines 153-469 of NEquivalence.lean) and replace with the restructured version. The new `sum_nf_agree` must have the SAME type signature (same hypotheses) but a different proof strategy internally.
- [ ] Define `orderedSum_atom_pred` simp lemma: `atom_eval (orderedSum sig I ms) env (.pred p j) = (ms (env j).1).interp p (env j).2`. This simplifies predicate atom goals in the ordered sum.
- [ ] Define `orderedSum_atom_order` simp lemma: `atom_eval (orderedSum sig I ms) env (.order i j h) = ((env i) < (env j))` where `<` is the sigma lex order. This simplifies order atom goals.
- [ ] Define the key insight lemma `sum_env_nf_transfer`: given component-wise (k+1)-equivalence at sentence level, for any environment `env_M : Fin n -> (orderedSum sig I ms).carrier` and its characteristic NF `char := nf_characteristic (orderedSum sig I ms) k n env_M`, show that `nf_eval_nf (orderedSum sig I ms') k n env_N char` when `env_N` has matching component indices and matching component-level NF characteristics. This is the core transfer lemma.

  The proof strategy for `sum_env_nf_transfer`:
  - By induction on k, generalizing over n.
  - **Base case (k=0)**: The NF at depth 0 is just atom assignments. Predicate atoms transfer via component k-equivalence. Order atoms transfer because: (a) cross-component order depends only on indices (matching by hypothesis), (b) same-component order is encoded in the joint NF characteristic (which the environment pair shares).
  - **Inductive step (k+1)**: Atoms transfer as in the base case. For quantifier transfer: given witness `x = (i, a)` in `orderedSum ms`, use the component `(ms i)`'s quantifier transfer to find `b` in `ms' i` such that `(ms i, Fin.cons a sub_env_M_i)` and `(ms' i, Fin.cons b sub_env_N_i)` share the same depth-k NF for the same-component sub-environment. Then the extended ordered-sum environments `Fin.cons (i,a) env_M` and `Fin.cons (i,b) env_N` agree on depth-k NFs by the IH.

- [ ] Verify all helper lemmas type-check without sorry via `lake build`

**Timing**: 4 hours

**Depends on**: 1

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/NEquivalence.lean` - Replace sum_nf_agree, add helper lemmas

**Verification**:
- Helper simp lemmas type-check without sorry
- `lake build` passes (the main `sum_nf_agree` may still have sorry during this phase as the core proof is being built incrementally)

**Detailed proof structure for the rewritten `sum_nf_agree`**:

The new proof replaces the separate `h_atoms` + `h_elem` invariant with a unified approach that mirrors `nf_agreement_monotone` exactly. The key change is in how witnesses are selected during the quantifier transfer step:

```
CURRENT (broken):
  Witness b selected by: 1-var component NF matching
  Problem: b has no order constraints relative to existing env elements

NEW (fixed):
  Witness b selected by: multi-var component NF matching
  using the JOINT characteristic of [a, same_comp_env_M(i)] in ms(i)
  transferred to ms'(i) via component (k+1)-equivalence
  Result: b satisfies same joint NF as a, which INCLUDES order atoms
```

The proof proceeds as follows. Given:
- `h_comp`: component-wise k-equivalence at sentence level (0 free vars)
- `env_M`, `env_N`: environments with matching indices (`h_idx`)
- Goal: `nf_eval_nf (orderedSum ms) k n env_M nf <-> nf_eval_nf (orderedSum ms') k n env_N nf`

**Step 1**: Compute `char_sum := nf_characteristic (orderedSum ms) k n env_M`. By `nf_characteristic_satisfies`, the ordered sum with `env_M` satisfies `char_sum`.

**Step 2**: Show `nf_eval_nf (orderedSum ms') k n env_N char_sum`. This is the core transfer. If established, then `nf_agreement_from_shared_nf` gives the desired biconditional for all NFs.

**Step 3** (proving Step 2 by induction on k):
- **k = 0**: `char_sum` at depth 0 is an atom assignment. Each atom in `env_N` evaluates identically to `env_M` because: predicates transfer via component equivalence, and order atoms transfer because (a) cross-component: same indices, (b) same-component: the joint NF hypothesis captures the ordering.

  However, at the TOP level (the initial call from `sum_preservation_proof` with n=0), there are NO atoms (AtomKind sig 0 has no pred atoms with `Fin 0` index and no order atoms), so the base case is trivially true.

- **k+1**: Need atoms AND quantifier transfer for the ordered sum.
  - Atoms: same as k=0 case but for n variables.
  - Quantifiers: given `exists (i,a), nf_eval_nf (orderedSum ms) k (n+1) (Fin.cons (i,a) env_M) sub_nf`, need to find `(i,b)` such that `nf_eval_nf (orderedSum ms') k (n+1) (Fin.cons (i,b) env_N) sub_nf`.

    The critical innovation: instead of selecting `b` by 1-var component NF, select `b` using the JOINT characteristic NF of `(a, same_comp_env_M_i)` in component `ms(i)`. This joint NF includes all pairwise order atoms between `a` and the existing same-component environment elements. Component (k+1)-equivalence transfers this joint characteristic to `ms'(i)`, yielding `b` that preserves ALL order relationships with existing same-component elements.

    Then apply the IH (at depth k, n+1 variables) to get the sub-NF transfer. The IH hypotheses are satisfied because:
    - Index matching: `h_idx` plus the new witness has the same component `i`
    - The new hypothesis for the IH is that `env_M'` and `env_N'` have matching ordered-sum-level NF characteristics at depth k, which follows from the joint component NF matching plus the cross-component structure.

**Alternative simpler approach (recommended for implementation)**: Instead of explicitly extracting same-component sub-environments, use the ordered sum's OWN existential transfer derived from component equivalence. Specifically:

1. From component (k+1)-equivalence, derive that the ordered sums are (k+1)-equivalent at 0 free variables. (This is what `sum_nf_agree` itself proves, but we can bootstrap: the n=0 case requires no order atoms and is trivially provable.)
2. From the ordered sum's (k+1)-equivalence at 0 vars, extract the quantifier part to get existential transfer at depth k.
3. Use this to find witnesses that satisfy the same depth-k NF in the ordered sum, which automatically includes order atoms.
4. Apply `nf_agreement_from_shared_nf` for the extended environment.

This "bootstrap" approach avoids the same-component sub-environment construction entirely. It works by building up the equivalence level by level:
- n=0: no atoms, trivially equivalent
- n -> n+1: use the n=0 equivalence to get quantifier transfer, find witnesses, apply IH

This is mathematically identical to `nf_agreement_monotone`'s structure, adapted to the ordered sum setting.

---

### Phase 3: Complete sum_nf_agree Proof [NOT STARTED]

**Goal**: Close all 4 sorry sites by completing the rewritten `sum_nf_agree` using the joint NF invariant approach.

**Tasks**:
- [ ] Implement the base case (k=0): at depth 0, `nf_eval_nf` reduces to atom assignment matching. For the initial call (n=0), `AtomKind sig 0` is empty so both sides vacuously match. For the recursive calls (n > 0), atom transfer follows from: (a) predicate atoms via component equivalence, (b) cross-component order atoms via `h_idx`, (c) same-component order atoms via the joint NF characteristic hypothesis.
- [ ] Implement the inductive step (k+1) atom transfer: show that for each atom `a : AtomKind sig n`, `atom_eval (orderedSum ms) env_M a <-> atom_eval (orderedSum ms') env_N a`. Use component equivalence for predicates, `h_idx` for cross-component order, and the joint NF invariant for same-component order.
- [ ] Implement the quantifier transfer: given witness `(i, a)` satisfying `sub_nf` in orderedSum ms, find `(i, b)` satisfying `sub_nf` in orderedSum ms'. The witness selection uses a multi-variable component NF transfer:
  1. Identify same-component positions: `S_i := { j : Fin n | (env_M j).1 = i }`
  2. Form the joint environment in component `ms i`: `joint_env := [a] ++ [(env_M j).2 | j in S_i]`
  3. Compute the joint characteristic: `nf_characteristic (ms i) k |S_i|+1 joint_env`
  4. Transfer to `ms' i` via component (k+1)-equivalence quantifier part
  5. The transferred witness `b` satisfies the same joint NF, so `nf_agreement_from_shared_nf` gives order atom agreement for all same-component pairs

  Alternatively, if the same-component sub-environment extraction proves too complex in Lean, use the bootstrap approach: derive ordered-sum (k+1)-equivalence at 0 vars (from a separate lemma `sum_nf_agree_sentence`), extract the quantifier transfer, and use `nf_agreement_from_shared_nf` at the ordered-sum level directly.

- [ ] Apply the inductive hypothesis at depth k for the extended environments `Fin.cons (i,a) env_M` and `Fin.cons (i,b) env_N`
- [ ] Verify all 4 sorry locations are eliminated
- [ ] Run `lake build` to confirm NEquivalence.lean compiles sorry-free (except `doets_lemma_1_5` in OrderedSum.lean which is out of scope)

**Timing**: 4 hours

**Depends on**: 2

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/NEquivalence.lean` - Complete sum_nf_agree proof

**Verification**:
- `lean_goal` at the end of the proof shows no remaining goals
- `grep -n "sorry" NEquivalence.lean` shows zero sorries
- `lake build` succeeds for NEquivalence.lean

---

### Phase 4: Verify doets_lemma_1_4 and Final Build [NOT STARTED]

**Goal**: Verify that `doets_lemma_1_4` is transitively sorry-free now that `sum_nf_agree` has no sorries, and run a clean full build.

**Tasks**:
- [ ] Verify `doets_lemma_1_4` in OrderedSum.lean still compiles (it already delegates to `KEquivalenceFramework.sum_preservation` which delegates to `sum_preservation_proof` which calls `sum_nf_agree`)
- [ ] Run `grep -rn "sorry" Theories/Bimodal/Metalogic/WeakCanonical/NEquivalence.lean` and confirm zero sorries
- [ ] Run `grep -rn "sorry" Theories/Bimodal/Metalogic/WeakCanonical/OrderedSum.lean` and confirm only `doets_lemma_1_5` sorry remains (out of scope)
- [ ] Run full `lake build` to verify no regressions across the entire project
- [ ] Update docstrings in NEquivalence.lean: remove "4 remaining sorries" and "blocker" references from `sum_nf_agree` docstring and `sum_preservation` instance comment
- [ ] Verify total sorry count has decreased by 4 compared to pre-implementation state

**Timing**: 2 hours

**Depends on**: 3

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/NEquivalence.lean` - Update docstrings
- `Theories/Bimodal/Metalogic/WeakCanonical/OrderedSum.lean` - Verify build, update docstrings if needed

**Verification**:
- `lake build` succeeds with exit code 0
- `doets_lemma_1_4` is sorry-free (transitively)
- Only remaining sorry in these two files is `doets_lemma_1_5` (explicitly out of scope)
- No new sorries introduced anywhere in the project

## Testing & Validation

- [ ] `lake build` succeeds with exit code 0
- [ ] `grep -rn "sorry" Theories/Bimodal/Metalogic/WeakCanonical/NEquivalence.lean` shows zero sorries
- [ ] `grep -rn "sorry" Theories/Bimodal/Metalogic/WeakCanonical/OrderedSum.lean` shows only `doets_lemma_1_5` sorry
- [ ] `grep -rn "carrier_order := sorry" Theories/` returns no matches
- [ ] The `orderedSum` construction type-checks and produces an `OrderedMonadicStructure` with proper lexicographic order
- [ ] No downstream regressions: files importing NEquivalence.lean and OrderedSum.lean continue to build

## Artifacts & Outputs

- `specs/154_sum_preservation_ef_games/plans/03_sum-preservation-plan.md` (this file)
- Modified: `Theories/Bimodal/Metalogic/WeakCanonical/NEquivalence.lean` (rewritten sum_nf_agree, closed sum_preservation)
- Modified: `Theories/Bimodal/Metalogic/WeakCanonical/OrderedSum.lean` (doets_lemma_1_4 transitively sorry-free, updated docstrings)

## Rollback/Contingency

- Git revert to pre-implementation commit restores all files
- If the full general proof (arbitrary linear order I) exceeds budget, prove `sum_preservation` restricted to `[Fintype I]` as a fallback. Teammate D confirmed that `very_good_implies_good` (Reynolds Lemma 16) only uses `sum_preservation` with a finite index set (the condensation quotient by `contemp_equiv` has finitely many equivalence classes bounded by `Fintype.card (KType sig k)`). This is mathematically sufficient to activate the entire Reynolds pipeline.
- If the same-component sub-environment extraction approach proves too complex in Lean dependent types, switch to the bootstrap approach: prove sentence-level (n=0) ordered-sum equivalence first (trivial, no atoms), then use the ordered sum's own quantifier transfer to find witnesses.
- If the complete rewrite of `sum_nf_agree` exceeds 500 lines, factor out reusable lemmas into a `SumPreservation` section or a dedicated helper file.
