# Implementation Plan: Task #154 - Sum Preservation via Normal Form Induction

- **Task**: 154 - sum_preservation_ef_games
- **Status**: [NOT STARTED]
- **Effort**: 10 hours
- **Dependencies**: None (NormalForm.lean infrastructure already complete)
- **Research Inputs**: specs/154_sum_preservation_ef_games/reports/02_team-research.md
- **Artifacts**: plans/02_sum-preservation-plan.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: true

## Overview

Prove `sum_preservation` (NEquivalence.lean:190) and `doets_lemma_1_4` (OrderedSum.lean:45): k-equivalence is preserved under ordered sums of monadic structures. The approach is normal form induction using the existing NormalForm.lean infrastructure (`nf_eval_nf`, `nf_exists_unique`, `nf_characteristic`, `nf_agreement_monotone`), NOT Ehrenfeucht-Fraisse games. A prerequisite refactoring step must first replace the `carrier_order := sorry` in the ordered sum construction with a proper lexicographic order using Mathlib's `Sigma.Lex` infrastructure.

### Research Integration

Team research (4 teammates, report 02) established unanimous consensus on normal form induction as the correct strategy. Key findings integrated:
- `carrier_order := sorry` is embedded in the TYPE signature, not just the proof body -- must be refactored before any proof work (Teammate C critical finding)
- Proof structure mirrors `nf_agreement_monotone` (NormalForm.lean:339-421): strong induction on depth k with compatible environments
- Effort revised upward to 250-400 lines (Teammate C correction accounting for Fin.cons transport and multi-variable order atoms)
- Scope narrowed to three deliverables only: carrier_order fix, sum_preservation proof, doets_lemma_1_4 corollary

### Prior Plan Reference

No prior plan.

### Roadmap Alignment

No explicit ROADMAP.md items reference task 154 or sum_preservation directly. This task advances the Reynolds pipeline infrastructure (NEquivalence.lean, OrderedSum.lean) which is a prerequisite for the dense completeness path. The chronicle fallback currently provides discrete completeness, so this is not on the critical path but enables the Reynolds pipeline as the primary path.

## Goals & Non-Goals

**Goals**:
- Define `orderedSum` helper that constructs an `OrderedMonadicStructure` for the lexicographic sum using Mathlib's `Sigma.Lex` linear order
- Replace all `carrier_order := sorry` occurrences in NEquivalence.lean and OrderedSum.lean with the proper `orderedSum` construction
- Prove `sum_preservation` in the default `KEquivalenceFramework` instance via normal form induction
- Close `doets_lemma_1_4` as a direct application of the framework field
- Verify clean `lake build` with no new sorries

**Non-Goals**:
- Proving `doets_lemma_1_5` (type-matching variant, not on discrete critical path)
- Closing downstream sorries: `finite_structures_good`, `contemp_equiv_is_equiv` transitivity, `no_gaps_discrete`, `very_good_implies_good`, `chronicle_is_good`
- Implementing EF games (no Mathlib infrastructure; normal form induction is superior)
- Refactoring the `KEquivalenceFramework` typeclass structure beyond what is needed for the proof

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| `Sigma.Lex.linearOrder` not directly available or requires manual construction | M | M | Fall back to explicit `LinearOrder` instance on `Sigma fun i => (ms i).carrier` using Mathlib's lexicographic order primitives |
| Fin.cons transport lemmas create excessive type coercion bureaucracy | H | H | Budget 30-60 extra lines; use `Fin.cons` lemmas from Mathlib; define targeted transport helpers |
| Cross-component order atoms require careful case analysis (same vs different component) | M | H | The lexicographic order on Sigma handles this: same-component uses component order, different-component uses index order. atom_eval already evaluates `env i < env j` which resolves correctly under lex order |
| Compatible environments formalization harder than expected at n >= 2 variables | H | M | Start with the n=0 sentence case (k_equiv) which avoids environments entirely, then generalize. Follow nf_agreement_monotone pattern closely |
| Proof exceeds 400 lines, risking context exhaustion | M | L | Decompose into helper lemmas in a dedicated section; use `have` blocks for intermediate goals |

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

### Phase 1: Define orderedSum and Fix carrier_order Sorries [NOT STARTED]

**Goal**: Replace all `carrier_order := sorry` with a proper lexicographic order construction, eliminating the structural blocker.

**Tasks**:
- [ ] Import `Mathlib.Data.Sigma.Order` (or appropriate Mathlib module providing `Sigma.Lex` linear order) in NEquivalence.lean
- [ ] Define `orderedSum` helper function in NEquivalence.lean (near the `KEquivalenceFramework` definition):
  ```
  noncomputable def orderedSum (sig : MonadicSignature) (I : Type) [LinearOrder I]
      (ms : I → OrderedMonadicStructure sig) : OrderedMonadicStructure sig where
    carrier := Sigma fun i => (ms i).carrier
    interp := fun p x => (ms x.1).interp p x.2
    carrier_order := Sigma.Lex.linearOrder
  ```
  If `Sigma.Lex.linearOrder` is not directly available, construct the `LinearOrder` instance manually using `Sigma.Lex` and the component orders.
- [ ] Replace the inline `{ carrier := ..., interp := ..., carrier_order := sorry }` in `sum_preservation` field (NEquivalence.lean:139-144) with `orderedSum sig I ms` and `orderedSum sig I ms'`
- [ ] Replace the inline `{ carrier := ..., interp := ..., carrier_order := sorry }` in `doets_lemma_1_4` (OrderedSum.lean:39-44) with `orderedSum sig I m` and `orderedSum sig I m'`
- [ ] Replace the inline `{ carrier := ..., interp := ..., carrier_order := sorry }` in `doets_lemma_1_5` (OrderedSum.lean:63-68) with `orderedSum sig I m` and `orderedSum sig J m'`
- [ ] Run `lake build` and verify no errors from the carrier_order changes (the `sorry` in the proof body of `sum_preservation` is expected to remain)

**Timing**: 2 hours

**Depends on**: none

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/NEquivalence.lean` - Add import, define `orderedSum`, refactor `sum_preservation` field signature
- `Theories/Bimodal/Metalogic/WeakCanonical/OrderedSum.lean` - Refactor `doets_lemma_1_4` and `doets_lemma_1_5` to use `orderedSum`

**Verification**:
- `lake build` succeeds with no new errors
- `grep -n "carrier_order := sorry"` returns no matches in the two files
- The only remaining sorry in the two files is the proof body of `sum_preservation` (line ~190) and `doets_lemma_1_4`/`doets_lemma_1_5` proof bodies

---

### Phase 2: Prove sum_preservation Base Case and Helper Lemmas [NOT STARTED]

**Goal**: Establish the base case (k=0) and define key helper lemmas needed for the inductive step of `sum_preservation`.

**Tasks**:
- [ ] Prove `orderedSum_atom_eval` lemma: for the ordered sum structure, `atom_eval (orderedSum sig I ms) env a` decomposes as expected:
  - For `AtomKind.pred p i`: `(ms (env i).1).interp p (env i).2`
  - For `AtomKind.order i j h`: `(env i) < (env j)` under lexicographic order (same component uses component `<`, different component uses index `<`)
- [ ] Prove `orderedSum_nf_eval_base` lemma: at depth 0, `nf_eval_nf (orderedSum sig I ms) 0 n env nf` iff all atoms evaluate correctly under the component-wise structure
- [ ] Prove the base case of sum_preservation: when k=0, `AtomKind sig 0` is empty (no predicates or order atoms with 0 free variables), so both sides vacuously satisfy the unique depth-0 normal form. This should be essentially `rfl` or follow from `Fin.elim0`
- [ ] Define `sum_env_compatible` predicate (or equivalent formalization): given environments `env_M : Fin n → (orderedSum sig I ms).carrier` and `env_N : Fin n → (orderedSum sig I ms').carrier`, they are "compatible" when each element maps to the same component index and the within-component pair shares the same depth-k NF characteristic

**Timing**: 2 hours

**Depends on**: 1

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/NEquivalence.lean` - Add helper lemmas near `sum_preservation`, prove base case

**Verification**:
- Helper lemmas type-check without sorry
- Base case proof (k=0, n=0) is sorry-free
- `lean_goal` at the sum_preservation sorry shows the remaining obligation is the inductive step

---

### Phase 3: Prove sum_preservation Inductive Step [NOT STARTED]

**Goal**: Complete the inductive step of `sum_preservation` using the normal form induction pattern from `nf_agreement_monotone`.

**Tasks**:
- [ ] Structure the main proof as strong induction on k (or well-founded induction) matching the `nf_agreement_monotone` pattern (NormalForm.lean:339-421)
- [ ] Prove the atom transfer step: for any atom `a : AtomKind sig n`, `atom_eval (orderedSum sig I ms) env a ↔ atom_eval (orderedSum sig I ms') env' a` when environments are compatible. The predicate case follows from component k-equivalence; the order case follows because compatible environments preserve component indices and the lexicographic order respects both index order and within-component order
- [ ] Prove the quantifier transfer step: for each `sub_nf : NormalForm sig k (n+1)`, show `(exists x in orderedSum ms, nf_eval_nf ... (Fin.cons x env) sub_nf) iff (exists y in orderedSum ms', nf_eval_nf ... (Fin.cons y env') sub_nf)`:
  - Given witness `x = (i, a)` in `orderedSum ms`, use component k-equivalence `h i` to find witness `(i, b)` in `orderedSum ms'`
  - The extended environments `Fin.cons (i, a) env` and `Fin.cons (i, b) env'` remain compatible because `a` and `b` share the same depth-(k-1) NF characteristic (from the component k-equivalence)
  - Apply IH to get the NF transfer at depth k for the extended environments
- [ ] Handle the Fin.cons type coercions: `Fin.cons x env` where `x : Sigma fun i => (ms i).carrier` and `env : Fin n → Sigma fun i => (ms i).carrier`. Define transport lemmas as needed to mediate between sum-level and component-level environments
- [ ] Assemble the full proof: combine base case, atom transfer, and quantifier transfer into the complete `sum_preservation` proof
- [ ] Remove the `sorry` from the `sum_preservation` field in the `KEquivalenceFramework` instance

**Timing**: 4 hours

**Depends on**: 2

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/NEquivalence.lean` - Complete sum_preservation proof body

**Verification**:
- `lean_goal` at the end of the proof shows no remaining goals
- `grep -n "sorry" NEquivalence.lean` shows no sorries in the sum_preservation proof
- `lake build` succeeds for NEquivalence.lean

---

### Phase 4: Close doets_lemma_1_4 and Final Verification [NOT STARTED]

**Goal**: Close `doets_lemma_1_4` as a direct corollary of the framework `sum_preservation` field, and verify the full build.

**Tasks**:
- [ ] Prove `doets_lemma_1_4` in OrderedSum.lean: this should follow directly from the default `KEquivalenceFramework` instance's `sum_preservation` field, since `k_equiv sig k` is the `equiv_at` of the default instance and the ordered sum construction matches
- [ ] Update the docstrings in NEquivalence.lean and OrderedSum.lean: remove "sorried" status markers and "TODO" comments for sum_preservation and doets_lemma_1_4
- [ ] Run full `lake build` to verify no regressions across the entire project
- [ ] Verify sorry count: run `grep -rn "sorry" Theories/Bimodal/Metalogic/WeakCanonical/NEquivalence.lean Theories/Bimodal/Metalogic/WeakCanonical/OrderedSum.lean` to confirm only `doets_lemma_1_5` sorry remains (out of scope)

**Timing**: 2 hours

**Depends on**: 3

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/OrderedSum.lean` - Prove doets_lemma_1_4, update docstrings
- `Theories/Bimodal/Metalogic/WeakCanonical/NEquivalence.lean` - Update docstrings and status comments

**Verification**:
- `lake build` succeeds with no errors
- `doets_lemma_1_4` is sorry-free
- Only remaining sorry in these two files is `doets_lemma_1_5` (explicitly out of scope)
- No new sorries introduced anywhere in the project

## Testing & Validation

- [ ] `lake build` succeeds with exit code 0
- [ ] `grep -rn "sorry" Theories/Bimodal/Metalogic/WeakCanonical/NEquivalence.lean` shows no sorries in `sum_preservation` proof
- [ ] `grep -rn "sorry" Theories/Bimodal/Metalogic/WeakCanonical/OrderedSum.lean` shows only `doets_lemma_1_5` sorry
- [ ] `grep -rn "carrier_order := sorry" Theories/` returns no matches
- [ ] The `orderedSum` construction type-checks and produces an `OrderedMonadicStructure` with proper lexicographic order
- [ ] No downstream regressions: files importing NEquivalence.lean and OrderedSum.lean continue to build

## Artifacts & Outputs

- `specs/154_sum_preservation_ef_games/plans/02_sum-preservation-plan.md` (this file)
- Modified: `Theories/Bimodal/Metalogic/WeakCanonical/NEquivalence.lean` (orderedSum def, sum_preservation proof)
- Modified: `Theories/Bimodal/Metalogic/WeakCanonical/OrderedSum.lean` (doets_lemma_1_4 proof, carrier_order fix)

## Rollback/Contingency

- Git revert to pre-implementation commit restores all files
- If Phase 1 (carrier_order fix) causes downstream breakage, the `orderedSum` helper can be defined locally within the proof rather than refactoring the signatures
- If the full inductive proof exceeds context, Phase 3 can be split: first prove for n=0 (sentence-level k_equiv, no environments), then generalize to n>0 environments
- If `Sigma.Lex.linearOrder` is unavailable, construct the `LinearOrder` instance manually via `LinearOrder.lift` on `Sigma.Lex` or define the ordering directly
