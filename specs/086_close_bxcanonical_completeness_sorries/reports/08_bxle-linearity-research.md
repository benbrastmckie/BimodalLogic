# Research Report: Task #86 -- bx_le Linearity and Eventuality Resolution

**Task**: 86 -- Close BXCanonical completeness sorries
**Date**: 2026-04-09
**Session**: sess_1775758350_13b22b
**Focus**: Close bx_le linearity in Frame.lean to enable non-constant-history canonical models

## Summary

After careful analysis of the Frame.lean sorry sites, the bx_le definition, BX7 semantics, and the broader proof architecture, this report reaches the following conclusions:

1. **Global bx_le linearity is FALSE and UNPROVABLE** -- the current definition (`g_content(w) subseteq v`) admits non-comparable MCS pairs, and BX7 only constrains Until witnesses, not arbitrary g_content relationships.

2. **A concrete low-effort win exists**: the `until_witness_seed_consistent` and `since_witness_seed_consistent` sorries in WitnessSeed.lean (lines 450, 569) can be closed trivially using BX10/BX10' without Until-induction. This removes 2 sorries from the codebase.

3. **The Frame.lean eventuality resolution sorries (lines 646, 668, 683, 697) are genuinely hard** -- they require the guard condition to hold for ALL BXPoints in an interval, not just chain points. Without bx_le linearity, off-chain points can violate the guard.

4. **Redefining bx_le will not help** -- making the ordering more restrictive (harder to satisfy) doesn't create linearity. Making it less restrictive (easier to satisfy) makes the guard quantification harder.

5. **The dovetailed chain approach IS viable** but requires restructuring: replace the universal guard quantification with a chain-specific guard that only considers points on the constructed chain.

## Detailed Analysis

### 1. bx_le Definition and Properties

```lean
def bx_le (w v : BXPoint) : Prop :=
  g_content w.formulas ⊆ v.formulas
```

Where `g_content M = {phi | G(phi) in M}`.

**Established properties** (sorry-free):
- Reflexive: `bx_le_refl` (from BX1: G(phi) -> phi)
- Transitive: `bx_le_trans` (from temp_4: G(phi) -> G(G(phi)))
- Box preservation: `box_preserved_along_bx_le` (from temp_future + S5)
- Modal equivalence: `bx_modal_equiv_of_bx_le` (corollary of box preservation)

**NOT established**: Linearity (totality), antisymmetry.

### 2. Why bx_le Linearity Is False Globally

Consider two MCS w and v where:
- `G(p) in w`, `p not-in v` (so NOT bx_le w v)
- `G(q) in v`, `q not-in w` (so NOT bx_le v w)

Such MCS can exist because the axioms don't force all MCS to be g_content-comparable. The `temp_linearity` axiom (F(phi) and F(psi) -> F(phi and psi) or ...) which would force this was REMOVED in the BX refactoring. BX7 (linearity of Until witnesses) only applies to MCS that share Until formulas, not to arbitrary pairs.

**Evidence from codebase**: `LinearityDerivedFacts.lean` explicitly states that temp_linearity is NOT derivable from the base TM axioms, and was added as a separate axiom (`temp_l`), which was subsequently removed in BX.

### 3. What BX7 Actually Gives

BX7: `(phi U psi) and (chi U theta) -> ((phi and chi) U (psi and theta)) or ((phi and chi) U (psi and chi)) or ((phi and chi) U (phi and theta))`

This is a formula-level constraint within a SINGLE MCS. It says: if two Until formulas hold at the same point, then some combined Until formula holds that captures the ordering of their witnesses. It does NOT produce any relationship between the g_content sets of different MCS.

Semantically, BX7 ensures that Until witnesses are linearly ordered on any given history. But in the canonical model, the bx_le ordering is NOT determined by Until witnesses -- it is determined by G-formula content.

**The gap**: BX7 constrains Until-witness ORDER. bx_le constrains G-content INCLUSION. These are different structural properties. No bridge exists in the current axiom system.

### 4. Concrete Low-Effort Win: Close WitnessSeed.lean Sorries

**Finding**: The sorries at WitnessSeed.lean:450 and WitnessSeed.lean:569 can be closed without Until-induction, using a much simpler argument.

**Current proof structure**: The proof assumes {psi} union g_content(M) is inconsistent, derives G(neg psi) in M, then tries to apply Until-induction (sorry'd) to get contradiction.

**Simpler proof**: From `phi U psi in M`, apply BX10 (`until_F`) to get `F(psi) in M`. Since `F(psi) = (psi.neg.all_future).neg`, we have `(G(neg psi)).neg in M`. Combined with `G(neg psi) in M`, this contradicts MCS consistency via `set_consistent_not_both`.

**Concretely**: The proof at line 450 has hypotheses:
- `h_U : phi.untl psi in M`
- `h_G_neg_psi : psi.neg.all_future in M` (= G(neg psi) in M)

From `h_U` + BX10: `psi.some_future in M` (= F(psi) in M).
Since `psi.some_future = psi.neg.all_future.neg` (definitional), we get `(psi.neg.all_future).neg in M`.
Apply `set_consistent_not_both h_mcs.1 psi.neg.all_future h_G_neg_psi <F(psi) in M>`.

This closes the sorry. The entire Until-induction machinery (h_and_xbot_imp_bot, h_G_and_xbot, h_G_and_xbot_in_M, h_conj_in_M, h_ind) is unnecessary and can be removed.

**Same approach for Since**: BX10' (`since_P`) gives `P(psi) in M` from `phi S psi in M`. Since `P(psi) = psi.neg.all_past.neg`, contradiction with `H(neg psi) in M`.

**Impact**: Closes 2 sorries, making `until_witness_seed_consistent` and `since_witness_seed_consistent` sorry-free. Also makes `canonical_forward_U` and `canonical_backward_S` in CanonicalFrame.lean sorry-free.

### 5. Frame.lean Eventuality Resolution: Structural Analysis

The 4 Frame.lean sorries have this structure:

**Forward Until** (line 646):
```
Given: phi U psi in w, psi not-in w
Need: exists v >= w, psi in v, and forall u in [w,v), phi in u
```

**Backward Until** (line 668):
```
Given: w <= v, psi in v, guard (forall u in [w,v), phi in u), psi not-in w
Need: phi U psi in w
```

The guard condition `forall u : BXPoint, bx_le w u -> bx_lt u v -> phi in u` quantifies over ALL BXPoints, not just a specific chain. This is the fundamental difficulty.

**Forward direction obstruction**: We can find v >= w with psi in v (via BX10 + bx_forward_witness). But showing phi in u for EVERY u between w and v requires knowing that every such u has phi. Since u is an arbitrary MCS with g_content(w) subseteq u and g_content(u) subseteq v, there's no mechanism to force phi in u.

Even enriching the seed (adding phi U psi to the successor construction) only ensures phi U psi propagates along a specific CHAIN, not at all intermediate BXPoints.

**Backward direction obstruction**: By contradiction, assume neg(phi U psi) in w. By BX4: G(P(neg(phi U psi))) in w. Since w <= v: P(neg(phi U psi)) in v. By backward witness: exists u <= v with neg(phi U psi) in u. The gap: we need w <= u to apply the guard. With bx_le linearity on [w,v], since both w <= v and u <= v, we'd get w <= u or u <= w. Without linearity, u could be incomparable with w.

### 6. Viable Path Forward: Chain-Specific Eventuality Resolution

Instead of proving the guard for ALL BXPoints, restructure the proof to work with a specific constructed chain.

**Approach A: Redefine the Truth Lemma**

Replace `until_iff_mcs` (which uses global bx_le) with a chain-specific version:

```
chain_until_iff (chain : Int -> BXPoint) (s : Int) (phi psi : Formula) :
    phi.untl psi in (chain s).formulas <->
      exists r >= s, psi in (chain r).formulas and
        forall t, s <= t -> t < r -> phi in (chain t).formulas
```

This only quantifies over chain points, which is sufficient for the completeness proof (the canonical model IS the chain). The guard can then be proved by construction (ensure phi U psi propagates along the chain until psi is resolved).

**Approach B: Prove Interval-Specific bx_le Linearity**

For the specific interval [w, v] where v is the Until witness, prove that the interval is linear. This would require showing that the BX axioms force all MCS between w and v (in the bx_le sense) to be g_content-comparable.

This approach is blocked: there's no known mechanism to derive g_content comparability from BX7 (Until-witness linearity).

**Approach C: Add bx_le Linearity as an Axiom**

Add temp_linearity back to the axiom set. This is sound (proven in Soundness.lean) and would immediately give bx_le linearity:

From `F(phi) and F(psi) -> F(phi and psi) or F(phi and F(psi)) or F(F(phi) and psi)`:
- bx_le linearity follows because F-witnesses are linearly ordered, and bx_le is equivalent to the F-witness ordering in the presence of temp_linearity.

However, this was explicitly removed in the BX refactoring to keep the axiom set minimal (BX7 is supposed to subsume temp_linearity).

### 7. Analysis of the "Derive temp_linearity from BX7" Path

Can temp_linearity be derived from BX7?

temp_linearity: `F(phi) and F(psi) -> F(phi and psi) or F(phi and F(psi)) or F(F(phi) and psi)`

Applying BX7 with guards = top and targets = phi, psi gives:
`(top U phi) and (top U psi) -> (top U (phi and psi)) or (top U phi) or (top U psi)`

This is trivially true and gives nothing useful. With non-trivial guards we get useful constraints, but only for Until formulas that actually appear in the MCS.

**The fundamental gap**: F(phi) = neg G(neg phi) is NOT the same as top U phi in the BX axiom system. Under reflexive Until semantics they're semantically equivalent, but proof-theoretically `F(phi) -> top U phi` appears underivable without temp_linearity.

**Verdict**: Deriving temp_linearity from BX axioms is almost certainly impossible without additional infrastructure. The BX axiom system may be incomplete for linear time without temp_linearity (or equivalently, without the ability to derive `F(phi) <-> top U phi`).

### 8. Relationship to CanonicalEmbedding.lean Sorry (Line 418)

The CanonicalEmbedding sorry (imp Case B of usf_completeness) is a DIFFERENT problem from the Frame.lean sorries. It is about the backward truth bridge for G/H on constant histories, specifically: on a constant history, `truth_at G(alpha) = truth_at alpha`, so the backward bridge gives `flatten(chi) in w` rather than `chi in w`.

Closing the Frame.lean sorries would NOT automatically close the CanonicalEmbedding sorry. However, if the Frame.lean sorries were closed, the full truth lemma (including Until/Since) would be complete, and the completeness proof could be restructured to use non-constant-history canonical models where G and H are non-trivial.

## Recommendations

### Tier 1: Immediate (< 2 hours, high confidence)

**Close WitnessSeed.lean sorries using BX10/BX10'**. This is a straightforward refactoring that removes 2 sorries and makes `canonical_forward_U` and `canonical_backward_S` sorry-free. The proof is:

1. At WitnessSeed.lean:450, replace the sorry and preceding Until-induction infrastructure with:
   - Derive `F(psi) in M` from `phi U psi in M` using BX10 (until_F axiom)
   - Note `F(psi) = psi.neg.all_future.neg` definitionally
   - Apply `set_consistent_not_both h_mcs.1 psi.neg.all_future h_G_neg_psi <F(psi)_proof>`

2. Mirror for WitnessSeed.lean:569 using BX10' (since_P).

### Tier 2: Medium-term (8-16 hours, medium confidence)

**Restructure eventuality resolution to use chain-specific guards** (Approach A from Section 6). This requires:
1. Define `chain_until_iff` / `chain_since_iff` for a specific constructed chain
2. Build the chain with Until-formula propagation (seed enrichment)
3. Prove the chain-specific guard by construction
4. Either replace the current Frame.lean sorries with chain-specific versions, or add the chain-specific lemmas as NEW lemmas alongside the sorry'd global ones

This avoids needing bx_le linearity entirely.

### Tier 3: Strategic (16+ hours, uncertain)

**Re-add temp_linearity to the axiom set** or **prove F(phi) <-> top U phi from BX axioms**. The first option is straightforward but goes against the BX refactoring philosophy. The second option would bridge the gap between F/P-based reasoning and Until/Since-based reasoning, enabling BX7 to yield bx_le linearity.

### NOT RECOMMENDED

- Attempting to prove global bx_le linearity from current axioms (mathematically blocked)
- Attempting to derive Until-induction from BX5+BX6+BX7 (likely requires F <-> top U, which is the same problem)
- Combined F-seed approaches (invalidated by report 07)
- Constant-history approaches (invalidated by report 07)

## Key Files

- `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic/BXCanonical/Frame.lean` -- 4 sorry sites (lines 646, 668, 683, 697)
- `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic/BXCanonical/Completeness.lean` -- 1 sorry site (line 153)
- `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic/BXCanonical/CanonicalEmbedding.lean` -- 1 sorry site (line 418)
- `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic/Bundle/WitnessSeed.lean` -- 2 closable sorries (lines 450, 569)
- `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/ProofSystem/Axioms.lean` -- BX axiom definitions
- `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/ProofSystem/LinearityDerivedFacts.lean` -- temp_linearity analysis (sorry'd)

## References

- Burgess 1984: "Basic tense logic" (canonical model with Until-induction)
- Goldblatt 1992: "Logics of Time and Computation" (completeness construction)
- Xu 1988: PhD thesis on completeness for Until/Since logics
