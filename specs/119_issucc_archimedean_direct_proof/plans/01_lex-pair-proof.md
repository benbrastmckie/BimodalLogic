# Implementation Plan: Task #119

- **Task**: 119 - Prove IsSuccArchimedean via Direct Connectivity Extraction
- **Status**: [NOT STARTED]
- **Effort**: 5 hours
- **Dependencies**: None (all prerequisite infrastructure exists in ChronicleConstruction.lean and CounterexampleElimination.lean)
- **Research Inputs**: specs/119_issucc_archimedean_direct_proof/reports/01_connectivity-proof-research.md
- **Artifacts**: plans/01_lex-pair-proof.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: true

## Overview

Replace the sorry in `limitDomSubtype_isSuccArchimedean` (ChronicleToCountermodel.lean:1068) with a complete proof using well-founded induction on the lexicographic pair `(domN_count, birth_stage)`. The key enabling lemma is birth-monotonicity (`birth(succ(z)) > birth(z)`), proven by contradiction using the C5 walk's sealing property. The proof descends from `b` to `pred(b)`, showing the lex-pair measure strictly decreases in each step: either the domN count drops (inter-gap case) or birth stage drops (intra-gap case). This avoids the gap lemma entirely, which was the source of task 118's failure.

### Research Integration

The research report (01_connectivity-proof-research.md) identified the lex-pair `(domN_count, birth_stage)` as the correct WF measure, demonstrated that task 118's WF measure `birth(q) - birth(current)` is undefined (negative for gap elements), and verified that all needed Lean infrastructure compiles (Nat.find, Finset.card, WellFounded.prod_lex, Function.iterate_add_apply). The birth-monotonicity contradiction argument uses the C5 forward walk to show that if `succ(z).val` were in `dom_{birth(z)}`, a midpoint would be inserted between z and succ(z), contradicting the successor property.

### Prior Plan Reference

No prior plan for task 119. Task 118 had a plan using `birth(q) - birth(current)` as WF measure, which was identified as incorrect. The lex-pair approach is a clean replacement that avoids the flawed measure entirely.

### Roadmap Alignment

This task closes the `limitDomSubtype_isSuccArchimedean` sorry in ChronicleToCountermodel.lean. While not directly listed in the ROADMAP sorry inventory (which tracks the 1 remaining density g-value consistency sorry at CE:3570 and the 19 BXCanonical sorries), closing this sorry is required for the `discrete_iso` function (line 1081) which provides the Z-isomorphism needed for the non-dense completeness branch.

## Goals & Non-Goals

**Goals**:
- Close the sorry at ChronicleToCountermodel.lean:1068 with a complete proof
- Define `birth_stage` function using `Nat.find` on limit_dom membership
- Prove birth-monotonicity: `birth(succ(z)) > birth(z)`
- Complete the `limitDomSubtype_isSuccArchimedean` theorem using lex-pair WF induction
- Ensure `lake build` passes with no new sorries

**Non-Goals**:
- Modifying the dense case or Cantor iso pathway (task 117 scope)
- Changing the SuccOrder/PredOrder definitions
- Proving DenselyOrdered or any density-related lemmas
- Refactoring the C5 walk infrastructure in CounterexampleElimination.lean

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Birth-monotonicity formalization harder than estimated (C5 walk extraction requires many intermediate lemmas) | H | M | If > 80 lines, factor into helper lemmas; fallback: sorry the birth-monotonicity and complete main theorem first, then revisit |
| Nat.find definitional equality issues with simp/set | M | L | Use Nat.find_spec and Nat.find_min directly; avoid unfolding |
| Finset.card bookkeeping verbose (subset/filter manipulation) | L | M | Use Finset.card_lt_card and Finset.card_le_card with explicit subset proofs |
| dom_new_unique extraction from C5ForwardWalkResult requires careful parameter threading | M | M | Study existing uses of C5ForwardWalkResult in ChronicleConstruction.lean for parameter patterns |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2 | 1 |
| 3 | 3 | 2 |

Phases within the same wave can execute in parallel.

### Phase 1: Birth-Stage Infrastructure [NOT STARTED]

**Goal**: Define the birth_stage function and prove its basic properties (spec, minimality, monotonicity with respect to domain membership).

**Tasks**:
- [ ] Define `birth_stage` using `Nat.find` with `Classical.dec` on the existential `∃ n, x ∈ (omega_chain_val A h_mcs n).dom`
- [ ] Prove `birth_stage_spec`: `x.val ∈ (omega_chain_val A h_mcs (birth_stage x)).dom`
- [ ] Prove `birth_stage_le_of_mem`: `x.val ∈ (omega_chain_val A h_mcs n).dom → birth_stage x ≤ n`
- [ ] Prove `birth_stage_not_mem_of_lt`: `m < birth_stage x → x.val ∉ (omega_chain_val A h_mcs m).dom`
- [ ] Verify all definitions compile with `lake build`

**Timing**: 1 hour

**Depends on**: none

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/ChronicleToCountermodel.lean` - Add birth_stage definitions and lemmas above the `limitDomSubtype_isSuccArchimedean` definition (before line ~1048)

**Verification**:
- `lake build` passes
- `lean_goal` at each theorem shows no remaining goals
- Birth stage lemmas have no sorry

---

### Phase 2: Birth-Monotonicity Lemma [NOT STARTED]

**Goal**: Prove `succ_birth_gt`: `birth_stage(succ(z)) > birth_stage(z)` for any `z : LimitDomSubtype`. This is the key enabling lemma for the main theorem.

**Tasks**:
- [ ] State `succ_birth_gt` theorem with full type signature
- [ ] Prove by contradiction: assume `succ(z).val ∈ dom_{birth(z)}`
- [ ] Show `succ(z).val` is the dom-successor of `z.val` in `dom_s` for any `s ≥ birth(z)` (using successor property: no limit_dom elements between z and succ(z))
- [ ] Construct the C5 counterexample `U(⊤, ⊥)` at `z.val` and show it is unresolved at any stage `s ≥ birth(z)` (condition (i) requires `⊥ ∈ g(z, succ(z))`, impossible since g-values are consistent/MCS)
- [ ] Use `counterexample_enum_surjective_above` to get a processing stage `s ≥ birth(z)` for this counterexample
- [ ] Show the C5 walk inserts a midpoint in `(z.val, succ(z).val)` via the split case (since condition (i) fails)
- [ ] Derive contradiction: new limit_dom element between z and succ(z) violates the successor property
- [ ] Derive corollary `pred_birth_lt`: `birth_stage(pred(b)) < birth_stage(b)` from `succ_birth_gt` applied to `z = pred(b)` and `succ(pred(b)) = b`

**Timing**: 2.5 hours

**Depends on**: 1

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/ChronicleToCountermodel.lean` - Add `succ_birth_gt` and `pred_birth_lt` after the birth_stage infrastructure

**Verification**:
- `lake build` passes
- `succ_birth_gt` and `pred_birth_lt` have no sorry
- `lean_goal` confirms proof completion

---

### Phase 3: Main IsSuccArchimedean Theorem via Lex-Pair Induction [NOT STARTED]

**Goal**: Complete the `limitDomSubtype_isSuccArchimedean` proof by replacing the sorry with well-founded induction on the lexicographic pair `(domN_count, birth_stage)`.

**Tasks**:
- [ ] Define `domN_count`: `fun z => (Finset.filter (fun q => a.val < q && q ≤ z.val) (omega_chain_val A h_mcs N).dom).card`
- [ ] Define `measure`: `fun z => (domN_count z, birth_stage z)` as a `Nat × Nat`
- [ ] Set up WF induction using `WellFounded.induction (WellFounded.prod_lex wellFounded_lt wellFounded_lt)`
- [ ] Handle base case: if `a = pred(b)`, then `succ(a) = succ(pred(b)) = b`, so `n = 1` works (use `⟨1, rfl⟩` after rewriting)
- [ ] Handle inductive case: apply IH to `pred(b)` with `a ≤ pred(b)` (from `a < b → a ≤ pred(b)`)
- [ ] Prove measure descent Case 1 (inter-gap): when `b.val ∈ domN`, show `domN_count(pred(b)) < domN_count(b)` using `Finset.card_lt_card` (b.val is in the filter for b but not for pred(b))
- [ ] Prove measure descent Case 2 (intra-gap): when `b.val ∉ domN`, show domN_count is non-increasing AND `birth_stage(pred(b)) < birth_stage(b)` using `pred_birth_lt`
- [ ] Combine iteration counts: from IH get `⟨n, hn⟩` with `succ^[n] a = pred(b)`, then `succ^[n+1] a = succ(succ^[n] a) = succ(pred(b)) = b`, so `⟨n+1, ...⟩` works (use `Function.iterate_add_apply`)
- [ ] Verify the complete `limitDomSubtype_isSuccArchimedean` has no sorry
- [ ] Run `lake build` to confirm everything compiles

**Timing**: 1.5 hours

**Depends on**: 2

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/ChronicleToCountermodel.lean` - Replace sorry at line 1068 with the complete proof

**Verification**:
- `lake build` passes with no errors
- `grep -r "sorry" ChronicleToCountermodel.lean` shows no new sorries (only pre-existing ones in other theorems)
- `lean_verify limitDomSubtype_isSuccArchimedean` confirms axiom-soundness

## Testing & Validation

- [ ] `lake build` passes with no new errors
- [ ] `grep -c "sorry" ChronicleToCountermodel.lean` shows same or fewer sorries than before
- [ ] `lean_goal` at the end of `limitDomSubtype_isSuccArchimedean` shows "no goals"
- [ ] `discrete_iso` (line 1081) still compiles (depends on `limitDomSubtype_isSuccArchimedean`)
- [ ] `dd_countermodel_chronicle_nondense_sorry` (line 825) still compiles

## Artifacts & Outputs

- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/ChronicleToCountermodel.lean` - Modified: sorry replaced with complete proof, birth_stage infrastructure added
- `specs/119_issucc_archimedean_direct_proof/plans/01_lex-pair-proof.md` - This plan file

## Rollback/Contingency

If the proof encounters unexpected difficulties:
1. **Birth-monotonicity fallback**: If `succ_birth_gt` proves too difficult to formalize (C5 walk extraction), leave it as sorry and complete the main theorem around it. The sorry would be localized to a single clear mathematical claim rather than the sprawling `limitDomSubtype_isSuccArchimedean`.
2. **Git revert**: All changes are in a single file (ChronicleToCountermodel.lean). `git checkout -- Theories/Bimodal/Metalogic/BXCanonical/Chronicle/ChronicleToCountermodel.lean` restores the original sorry.
3. **Alternative approach**: If lex-pair induction has unexpected Lean issues, consider the simpler (but less elegant) approach of two nested inductions: outer on domN_count, inner on birth_stage within the same domN_count.
