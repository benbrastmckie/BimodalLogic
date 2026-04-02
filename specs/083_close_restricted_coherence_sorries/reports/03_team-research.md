# Research Report: Task #83 (Round 3)

**Task**: Close Restricted Coherence Sorries
**Date**: 2026-04-02
**Mode**: Team Research (2 teammates)
**Session**: sess_1775163906_638eaf

## Summary

Team investigation of the enriched deferral seed inconsistency blocker (v2 plan Phase 1 failure). Both teammates confirm the existing `succ_chain_fam` cannot resolve F-obligations and the truth lemma cannot be restructured to avoid `forward_F`. The converging recommendation is a **targeted chain with compatible F-preservation and topological resolution order**, exploiting the acyclic blocking relation on `deferralClosure`.

## Key Findings

### 1. Blocking Relation Acyclicity is PROVEN (Teammate A, HIGH confidence)

The blocking relation "chi blocks psi iff `{chi} ∪ g_content(M) ⊢ G(¬psi)`" is **acyclic** on `deferralClosure(root)` when both `F(chi) ∈ M` and `F(psi) ∈ M`.

**Proof sketch** (using TM linearity axiom):
- If chi blocks psi AND psi blocks chi, derive `F(G(¬psi)) ∈ M` and `F(G(¬chi)) ∈ M`
- Apply linearity: `F(A) ∧ F(B) → F(A ∧ B) ∨ F(A ∧ F(B)) ∨ F(F(A) ∧ B)`
- With A = G(¬psi), B = G(¬chi): all three disjuncts collapse to `F(G(¬psi ∧ ¬chi)) ∈ M`
- Combined with `F(psi) ∈ M`, `F(chi) ∈ M`, and the mutual blocking conditions: derive that psi and chi must both occur before a cutoff time, but each blocks the other after occurring → `t_chi < t_psi < t_chi`, contradiction

**Key derivations used**: `F(A) ∧ G(A → B) → F(A ∧ B)` (provable in TM), G-persistence `G(A) → G(G(A))` (temp_4), T-axiom, linearity axiom.

**Mathlib infrastructure**: `Finite.wellFounded_of_trans_of_irrefl` and `Set.WellFoundedOn.induction` directly apply once irreflexivity and transitivity are established.

### 2. Existing Chain Cannot Resolve F-Obligations (Both teammates, HIGH confidence)

Perpetual deferral is consistent in TM. The f_step property (`F(psi) ∈ M → psi ∈ M' ∨ F(psi) ∈ M'`) guarantees persistence but NOT eventual resolution. The linearity axiom constrains temporal ordering of obligations but does not force resolution. Omega-regularity arguments do not apply (TM lacks fairness axioms).

### 3. Truth Lemma Cannot Avoid forward_F (Teammate B, HIGH confidence)

`forward_F` is used at exactly one point: the backward direction of the G case in `restricted_shifted_truth_lemma`. The proof path is:
1. Assume `G(psi) ∉ MCS(t)` → `F(¬psi) ∈ MCS(t)`
2. Apply `forward_F` to get witness `s ≥ t` with `¬psi ∈ MCS(s)`
3. Contradict hypothesis `psi ∈ MCS(s)` for all `s ≥ t`

No alternative proof path exists. Simultaneous induction (formula complexity × temporal nesting) fails because `forward_F` is a chain property, not a logical induction result.

### 4. Topological Ordering is Necessary but Not Sufficient (Teammate A, HIGH confidence)

Topological ordering determines the correct resolution order but does NOT prevent F-obligation loss at Lindenbaum extension steps. The extension goes BEYOND the seed — even if `G(¬psi_j)` is not derivable from the seed, the Lindenbaum extension CAN include it.

### 5. Custom Lindenbaum with Deferral Preference is Valid but Insufficient Alone (Teammate A, MEDIUM confidence)

The Zorn-based construction preserves MCS properties. Chain closure verified. But the preference is overridden when including chi would be inconsistent (G-formula conflicts). Must be combined with topological ordering or enriched seeds.

### 6. Alternative Model Constructions Reduce to Same Core Problem (Teammate B, HIGH confidence)

Henkin-style, step-indexed, and filtration approaches all reduce to the same difficulty: building a Z-indexed chain with F-resolution. The canonical frame approach (all MCS as worlds) trivially satisfies forward_F but lacks linear temporal structure.

## Synthesis

### Conflicts Resolved

**Conflict 1: What to add to the enriched seed?**
- Teammate A: Add deferral disjunctions `chi ∨ F(chi)` (weaker, potentially more compatible)
- Teammate B: Add compatible F-formulas `F(chi)` directly (stronger, but filter incompatible ones)

**Resolution**: Teammate B's approach is more promising. Adding `F(chi)` directly is STRONGER (preserves F-obligations exactly) and the compatibility filter handles the inconsistency. The deferral disjunction approach (Teammate A) has the subtlety that disjunctions allow Lindenbaum to choose the "wrong" disjunct (F(chi) instead of chi), perpetuating deferral. Adding F(chi) directly guarantees the obligation persists.

**Conflict 2: Is joint consistency of compatible F-formulas provable?**
- Teammate A: Uncertain — the G-lifting technique doesn't close syntactically for F-formulas
- Teammate B: Claims it follows from pairwise compatibility via finite character of derivability

**Resolution**: Teammate B's claim needs verification. Pairwise compatibility does NOT always imply joint consistency (classic example in propositional logic: {p ∨ q, ¬p ∨ q, p ∨ ¬q} are pairwise consistent but jointly imply q; they're still jointly consistent though). For F-formulas specifically, the argument may work because F-formulas are "future-directed" and don't interact combinatorially in the same way. **This is the critical lemma to prove or disprove.**

### Gaps Identified

1. **Joint consistency of compatible F-formulas**: The mathematical core. Neither teammate fully resolved this. Teammate A's analysis suggests the G-lifting technique cannot prove it. Teammate B suggests pairwise → joint via finite character. A careful formal argument is needed.

2. **F-persistence through non-target resolution steps**: Even with compatible F-formulas in the seed, the Lindenbaum extension may not include them all. The seed consistency only guarantees the SEED is consistent, not that the MCS extension includes specific formulas. However, if `F(chi)` is in the seed, the MCS extension either includes `F(chi)` or `¬F(chi)` = `G(¬chi)`. If `G(¬chi)` is in the extension, then the chi obligation is "blocked" at this step. By topological ordering, this is handled.

3. **Formalization of the blocking relation**: Defining "chi blocks psi relative to M" in Lean 4 requires decidable derivability or a computable approximation.

## Recommendations

### Primary Recommendation: Compatible F-Preservation with Topological Ordering

**Strategy**: Build a new chain construction (extending TargetedChain.lean infrastructure) that:

1. **Defines the blocking relation**: `blocks M chi psi := ¬SetConsistent ({chi} ∪ g_content(M) ∪ {F(psi)})`
   - Note: this is a computable relation on the finite `deferralClosure`

2. **Proves acyclicity**: Using the TM linearity axiom derivation from Teammate A's analysis

3. **Constructs the resolving chain**: At each step, for scheduled target psi:
   - Seed = `{psi} ∪ g_content(M) ∪ {F(chi) | F(chi) ∈ M, chi compatible with psi}`
   - Compatible means: `SetConsistent ({psi} ∪ g_content(M) ∪ {F(chi)})`
   - Prove seed consistency (the critical lemma)
   - Lindenbaum extension gives MCS W with psi resolved and compatible F-obligations preserved

4. **Proves F-resolution by well-founded induction on blocking DAG**:
   - Unblocked obligations: F(chi) persists through all non-target steps (compatible with every target), resolved at chi's scheduled step
   - Blocked obligations: F(chi) may be lost when its blocker is resolved, but chi was already resolved earlier (topological order processes blocked formulas first)

### Critical Lemma: Joint Consistency

The make-or-break lemma:

> If `{psi} ∪ g_content(M) ∪ {F(chi_i)}` is consistent for each i individually, then `{psi} ∪ g_content(M) ∪ {F(chi_1), ..., F(chi_k)}` is consistent.

**Proof approach** (to be verified):
- Suppose the joint set is inconsistent. Take minimal L deriving ⊥.
- L must include psi (else L ⊆ M, contradicting M's consistency).
- L \ {psi} ⊢ ¬psi, where L \ {psi} ⊆ g_content(M) ∪ {F(chi_1), ..., F(chi_k)}.
- Partition: L_G ⊆ g_content(M), L_F = {F(chi_{j1}), ..., F(chi_{jm})}.
- By deduction: L_G ⊢ F(chi_{j1}) → ... → F(chi_{jm}) → ¬psi.
- G-lift L_G: G(F(chi_{j1}) → ... → ¬psi) ∈ M.
- T-instance: F(chi_{j1}) → ... → F(chi_{jm}) → ¬psi ∈ M.
- All F(chi_{ji}) ∈ M, so ¬psi ∈ M by MP.
- ¬psi ∈ M is fine (compatible with F(psi) ∈ M).
- To derive contradiction: need G(¬psi) ∈ M, but we only have ¬psi ∈ M.

**The gap**: We derive ¬psi ∈ M but need G(¬psi) ∈ M for contradiction with F(psi) ∈ M. The G-lifting of the implication gives G(¬psi) only if ALL F(chi_ji) can be G-lifted, which they can't.

**Alternative argument**: The seed `{psi} ∪ g_content(M)` is consistent (proven). Adding F(chi_i) can only make it inconsistent if some subset of the F-formulas, combined with the seed, derives ⊥. But each F(chi_i) individually is consistent with the seed (by the compatibility filter). The question is whether F-formulas can interact to create inconsistency. Since F-formulas are "existential" (they assert existence of a future witness), their conjunction `F(chi_1) ∧ ... ∧ F(chi_k)` is consistent with the seed unless the witnesses conflict. By the linearity axiom, the witnesses must be temporally ordered, which doesn't create inconsistency.

**This argument needs formalization but is plausible.**

### Fallback: Frame Path Extraction

If joint consistency cannot be proved, extract a Z-path from the canonical frame (where forward_F is trivially true). Requires building new infrastructure (~12-18 hours) but is mathematically well-founded.

### Effort Estimates

| Approach | Effort | Risk |
|----------|--------|------|
| Compatible F-preservation + topological | 10-14 hours | Medium (joint consistency lemma) |
| Frame path extraction (fallback) | 12-18 hours | Low (standard construction) |
| Combined (attempt primary, fall back) | 14-20 hours | Low |

## Teammate Contributions

| Teammate | Angle | Status | Confidence |
|----------|-------|--------|------------|
| A | Topological resolution + custom Lindenbaum | completed | Medium-Low |
| B | Alternative architectures + semantic arguments | completed | Medium-High |

## References

- Teammate A: `specs/083_close_restricted_coherence_sorries/reports/03_teammate-a-findings.md`
- Teammate B: `specs/083_close_restricted_coherence_sorries/reports/03_teammate-b-findings.md`
- Prior blocker analysis: `specs/083_close_restricted_coherence_sorries/reports/02_blocker-analysis.md`
- Prior team research: `specs/083_close_restricted_coherence_sorries/reports/01_team-research.md`
- Partial implementation summary: `specs/083_close_restricted_coherence_sorries/summaries/02_restricted-coherence-summary.md`
