# Research Report: Task #65

**Task**: Build TaskModel from Restricted Construction
**Date**: 2026-03-26
**Mode**: Team Research (2 teammates)
**Session**: sess_1774561991_04af05

## Summary

Option C (Alternative Completeness Path via Restricted Construction) is mathematically sound and the most tractable path to eliminating the 3 target sorries in `FrameConditions/Completeness.lean`. The `RestrictedTemporallyCoherentFamily` construction provides family-level F/P coherence (witnesses in the SAME chain), which solves the bundle-level coherence mismatch that blocks the standard approach. Building a TaskModel from this construction requires defining `RestrictedOmega` as time-shifts of a single history, proving shift-closure, and establishing a semantic truth lemma bridging chain membership to `truth_at`. No counterexamples were found, and no theoretical blockers were identified.

## Key Findings

### 1. RestrictedTemporallyCoherentFamily Provides Exactly What's Needed

**Source**: `SuccChainFMCS.lean:4191-4202`

The structure packages a single Int-indexed chain with family-level coherence:
- `forward_F`: F-witnesses exist in the SAME chain (not a different family)
- `backward_P`: P-witnesses exist in the SAME chain

This is constructed via `build_restricted_tc_family` (lines 4210-4270) from a `DeferralRestrictedSerialMCS`, handling forward chain (positive Int), backward chain (negative Int), and the 0 transition.

**Critical difference from bundle**: Bundle construction allows F-witnesses to cross families (box classes). The restricted construction confines witnesses to one chain, which is exactly what the truth lemma backward cases require for the contradiction argument.

### 2. TaskModel Infrastructure: Reuse ParametricCanonicalTaskFrame

**Source**: `TaskFrame.lean:93-122`, `TaskModel.lean:43-49`

**Recommended approach**: Extend DRMs to full MCSes via `restricted_chain_ext` (RestrictedTruthLemma.lean:163-175), then reuse `ParametricCanonicalTaskFrame Int`:

| Component | Definition | Source |
|-----------|-----------|--------|
| WorldState | Full MCS (Lindenbaum-extended from DRM) | `restricted_chain_ext` |
| task_rel | `parametric_canonical_task_rel` (g_content subset) | ParametricCanonical.lean |
| valuation | `atom p in M.val` | Standard |
| TaskFrame | `ParametricCanonicalTaskFrame Int` | ParametricCanonical.lean:150+ |

**Trade-off**: Using full MCS via extension adds a layer of indirection but enables reuse of all existing parametric infrastructure. Both teammates agreed this is the right trade-off.

### 3. RestrictedOmega: Shifts of a Single History

**Both teammates converged on the same definition**:

```lean
def RestrictedOmega (phi : Formula) (tc_fam : RestrictedTemporallyCoherentFamily phi) :
    Set (WorldHistory (ParametricCanonicalTaskFrame Int)) :=
  { sigma | exists (delta : Int), sigma = WorldHistory.time_shift (restricted_to_history phi tc_fam) delta }
```

Where `restricted_to_history` converts the chain to a `WorldHistory`:
- Domain: `fun _ => True` (all integers)
- States: `fun t _ => restricted_chain_ext phi tc_fam t` (Lindenbaum-extended)
- `respects_task`: requires proving `forward_G` is preserved by extension

**Why this works**: Since there's only one base history, Omega is just its time-shifts. This makes:
- Shift-closure trivial (shift of shift = shift with added offset)
- Box quantification manageable (quantify over shifts of one history)
- The overall construction much simpler than the bundle approach

### 4. Shift-Closure Is Straightforward

**Proof sketch**:
```
Given sigma in RestrictedOmega, sigma = time_shift(base, delta)
time_shift(sigma, delta') = time_shift(time_shift(base, delta), delta')
                          = time_shift(base, delta + delta')  -- by composition lemma
```

The composition lemma already exists: `time_shift_parametric_to_history_compose` (ParametricHistory.lean:131-142) and `time_shift_to_history_compose` (CanonicalConstruction.lean:345-357).

### 5. Semantic Truth Lemma Gap

**Current**: `restricted_truth_lemma` (RestrictedTruthLemma.lean:268-280) establishes DRM-to-extended-MCS equivalence for formulas in `subformulaClosure phi`.

**Needed**: `restricted_truth_lemma_semantic` bridging chain membership to `truth_at`:
```lean
psi in restricted_succ_chain_fam phi tc_fam.seed n <->
truth_at M RestrictedOmega (restricted_to_history phi tc_fam) n psi
```

**Proof by structural induction on formula** (follows `parametric_truth_lemma_shifted` template):

| Case | Strategy | Difficulty |
|------|----------|------------|
| Atom | By valuation definition | Trivial |
| Bot | Both sides false | Trivial |
| Imp | IH on subformulas | Easy |
| Box | Box-persistence + single-family Omega | Medium |
| G (all_future) | Uses `forward_F` coherence for backward direction | Medium |
| H (all_past) | Uses `backward_P` coherence for backward direction | Medium |

**Box case detail** (resolved conflict): With single-family Omega, `Box(psi) in chain(n)` requires `psi true at all sigma in Omega at time n`. Since Omega only contains shifts of one history, this reduces to checking `psi` at all shifted times. Box-persistence along the chain (`succ_chain_box_persistent` pattern) handles this.

### 6. Completeness Contrapositive Argument

**Step-by-step**:

1. **phi not provable** -> `neg(phi)` consistent (via `not_provable_implies_neg_consistent`)
2. **Extend** `neg(phi)` to `DeferralRestrictedSerialMCS phi` (Lindenbaum + deferral construction)
3. **Build** `RestrictedTemporallyCoherentFamily phi` from the seed (via `build_restricted_tc_family`)
4. **Build** `RestrictedTaskModel` with Lindenbaum-extended chain states
5. **Define** `RestrictedOmega` as shifts of the single history
6. **Apply** `restricted_truth_lemma_semantic`: `neg(phi) in chain(0)` implies `neg(phi)` true at time 0
7. **Therefore** `phi` NOT true at time 0 in this model -> not `valid_over Int phi`
8. **Contrapositive**: `valid_over Int phi -> Nonempty ([] |- phi)`

**Connection to target sorries**: This directly provides `bundle_validity_implies_provability`. The dense/discrete variants follow via `dense_implies_int` and `discrete_implies_int`.

**Why restriction suffices**: The contrapositive only needs phi and neg(phi) in `subformulaClosure(phi)`, which is guaranteed by reflexivity and closure_neg. No formulas outside the restricted set are needed.

## Synthesis

### Conflicts Found and Resolved

**1. Confidence Level (HIGH vs MEDIUM)**

- Teammate A: HIGH confidence (90% infrastructure exists, clear path)
- Teammate B: MEDIUM confidence (existing sorries concerning, estimate may be optimistic)

**Resolution**: The approach is mathematically sound (HIGH confidence on correctness). Implementation risk is MEDIUM due to existing sorries. Reconciled as: **HIGH confidence on approach viability, MEDIUM confidence on effort estimate**.

**2. Effort Estimate (5-8 hours vs 6-10 hours)**

- Teammate A: 5-8 hours across 3 phases
- Teammate B: 6-10 hours accounting for sorries and edge cases

**Resolution**: Adopt **6-8 hours** as working estimate. The existing sorries in RestrictedTruthLemma.lean (G/H propagation) may require workarounds but are not blocking the main path.

### Gaps Identified

**1. `respects_task` proof for restricted history**
- Does `restricted_chain_ext` preserve `forward_G` needed for `respects_task`?
- Teammate A: "Likely yes - Lindenbaum extension preserves derivability"
- **Action**: Verify during implementation; if blocked, use direct proof rather than through extension

**2. Box-persistence for restricted chain**
- Need `succ_chain_box_persistent` or equivalent for `restricted_chain_ext`
- Critical for Box case of semantic truth lemma
- **Action**: Check if existing lemma applies or needs restricted variant

**3. Existing sorries inventory**
- RestrictedTruthLemma.lean lines 106, 115, 135: G/H propagation sorries
- SuccChainFMCS.lean lines 3420, 3973, 4154: chain construction / termination sorries
- **Assessment**: G/H propagation sorries may need resolution for the semantic truth lemma G/H cases. Termination sorries are non-blocking (affect well-foundedness, not correctness).
- **Action**: Document impact; resolve G/H sorries if they're in the critical path

**4. `restricted_validity_gives_seed_membership` milestone**
- Teammate B recommends proving this as an early milestone before full infrastructure
- ```lean
  valid_over Int phi -> phi in restricted_succ_chain_fam phi tc_fam.seed 0
  ```
- **Action**: Include as verification checkpoint in implementation plan

### Recommendations

1. **PROCEED with Option C** - Both teammates agree this is the most tractable path
2. **Reuse ParametricCanonicalTaskFrame** - Don't define new TaskFrame; extend DRMs to MCSes
3. **RestrictedOmega = shifts of single history** - Both converged on this definition
4. **Prioritize semantic truth lemma** - This is the hardest new work; most infrastructure exists
5. **Document existing sorries** - Inventory sorries and assess which are blocking vs non-blocking
6. **Add verification checkpoint** - Prove `restricted_validity_gives_seed_membership` early to validate the path before full implementation

## Teammate Contributions

| Teammate | Angle | Status | Confidence | Key Contribution |
|----------|-------|--------|------------|------------------|
| A (primary-approach) | Primary implementation path | Completed | HIGH | Detailed infrastructure blueprint, phase-by-phase plan |
| B (alternatives-risks) | Risks and alternatives | Completed | MEDIUM | Sorry inventory, counterexample testing, dependency analysis |

## References

| Component | Location | Status |
|-----------|----------|--------|
| RestrictedTemporallyCoherentFamily | SuccChainFMCS.lean:4191-4270 | Complete |
| restricted_succ_chain_fam | SuccChainFMCS.lean:3640-3661 | Complete |
| restricted_truth_lemma | RestrictedTruthLemma.lean:268-280 | Complete (with 3 sorries in helpers) |
| restricted_chain_ext | RestrictedTruthLemma.lean:163-175 | Complete |
| ParametricCanonicalTaskFrame | ParametricCanonical.lean:150+ | Complete |
| parametric_to_history | ParametricHistory.lean:61-89 | Template for restricted_to_history |
| time_shift_compose | ParametricHistory.lean:131-142 | Complete |
| ShiftClosed | Truth.lean:237 | Definition exists |
| truth_at | Truth.lean:118-125 | Complete |
| valid_over | Validity.lean:53-58 | Complete |
| bundle_validity_implies_provability | Completeness.lean:186-214 | **Target sorry** |
| dense_completeness_fc | Completeness.lean:115-120 | **Target sorry** |
| discrete_completeness_fc | Completeness.lean:158-163 | **Target sorry** |
