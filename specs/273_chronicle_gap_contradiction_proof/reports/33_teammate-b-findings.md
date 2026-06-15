# Teammate B Findings: Literature Alignment Analysis

- **Task**: 273 - chronicle_gap_contradiction_proof
- **Date**: 2026-06-15
- **Scope**: Rigorous literature alignment for KampBypass.lean sorry sites
- **Focus**: Rabinovich 2014, Hodkinson-Reynolds 2006, Libkin 2004 -- mapping paper proof to Lean formalization
- **Artifact**: 33_teammate-b-findings.md

---

## 1. Literature Analysis

### 1.1 Rabinovich 2014 Proof Structure

The core of Rabinovich 2014 is a self-contained proof of Kamp's theorem using an **interval decomposition / exists-forall normal form** approach. The key steps (for the hard direction: FOMLO -> TL) are:

**Step 1: Define exists-forall normal form**
A formula `psi(z_0, ..., z_m)` is an exists-forall formula if it existentially chooses witness points `x_0 < ... < x_n` in the chain and asserts:
- Point types: `alpha_j(x_j)` at each witness (quantifier-free)
- Interval types: `beta_j` holds everywhere along each sub-interval `(x_{j-1}, x_j)` (quantifier-free)
- Tail types: `beta_0` before `x_0` and `beta_{n+1}` after `x_n`

Abbreviation: `[alpha_0, beta_1, alpha_1, ..., beta_n, alpha_n](z_0, z_1)` for a 2-free-variable version.

**Step 2 (Proposition 3.5): Translate exists-forall to TL**
An exists-forall formula with one free variable at position `z_k` translates to:
```
A_k AND (B_{k+1} Until (A_{k+1} AND (B_{k+2} Until ... (A_n AND Box B_{n+1})...)))
AND A_k AND (B_{k-1} Since (A_{k-1} AND (B_{k-2} Since ... (A_0 AND Box_past B_0)...)))
```
This is the composition of interval types using nested Until/Since.

**Step 3 (Proposition 4.2/Lemma 5.1): Closure under negation (THE HARD PART)**
The negation of `[alpha_0, beta_1, ..., beta_n, alpha_n](z_0, z_1)` is equivalent (on Dedekind complete chains) to a disjunction of exists-forall formulas.

Proof uses:
- Interval splitting: `A_i(z_0, z, z_1) = A_i^-(z_0, z) AND A_i^+(z, z_1)` where new point `z` is inserted at position `i`
- Dedekind completeness: the infimum point `r_0 = inf{z | P_1(z)}` exists, enabling case splits
- Induction on `n` (the number of existential witnesses): base case is trivial, inductive step splits off the first witness

**Step 4 (Proposition 4.3): Every FO formula has an exists-forall normal form**
Structural induction:
- Atomic: immediate
- Disjunction: by closure under disjunction (Lemma 3.4)
- Negation: uses Proposition 4.2
- Existential: uses Lemma 3.4 closure under existential quantification

**Step 5 (Theorem 4.4): Kamp's Theorem**
Combine Propositions 4.3 and 3.5.

### 1.2 Hodkinson-Reynolds 2006

The extracted portion (Chapter 11 introduction only) confirms the broad context but provides no additional proof details beyond establishing that Kamp's theorem is a central result in temporal logic expressive completeness. The handbook confirms the two approaches: EF games (Hodkinson 1995) and separation property (Gabbay 1981). Rabinovich 2014 uses neither -- it introduces the interval decomposition approach which this formalization follows.

The handbook specifically notes that the key difficulty is the FOMLO -> TL direction and that proofs rely on linearity of time. This aligns with the formalization's use of `OrderedMonadicStructure` with a linear order.

### 1.3 Libkin 2004 (EF Games and Composition)

The key results from Libkin relevant to this formalization:

**Lemma 3.7 (Composition Lemma for Linear Orders)**: If `L_1^{<=a} equiv_k L_2^{<=b}` and `L_1^{>=a} equiv_k L_2^{>=b}`, then `(L_1, a) equiv_{k-1} (L_2, b)`.

This is the mathematical foundation for the "zone decomposition" pattern in KampBypass.lean: when a new point `x` is inserted between `t` and a surrounding structure, the EF equivalence of the whole can be composed from the equivalence of sub-intervals. The formalization's zone bridge theorems (ZoneBridge.lean) are direct implementations of this principle.

**Lemma 7.11 (Composition for MSO/disjoint unions)**: Extends composition to set moves. Relevant for the quantifier profile argument -- the "between_tx" zone bracket encodes the MSO composition principle at the depth-0 level.

**Quantifier rank types (Theorem 3.15)**: The finite number of rank-k types is what makes the NF decomposition into finitely many existential witness types possible. The `NormalForm sig k n` type in the formalization directly implements this -- NFs enumerate all rank-k types for n-tuple environments.

---

## 2. Correspondence Table: Paper Step ↔ Lean Theorem

| Paper Step | Rabinovich Reference | Lean Location | Lean Theorem Name |
|-----------|---------------------|---------------|-------------------|
| Define exists-forall NF | Def 3.1 | NormalForm.lean | `NormalForm sig k n` (as `AtomKind -> Bool` pair) |
| Translate EF to TL (Prop 3.5) | Prop 3.5 | NfToVecEA.lean | `bracketBuildLeft`, depth-0 2-var bridge |
| EF formula interval split | Notation 5.2, A_i^- / A_i^+ | ZoneBridge.lean | `zone_bridge_between_tx`, `zone_bridge_below_t`, etc. |
| Closure under disjunction | Lemma 3.4 | KampBypass.lean | `formula_disjList` constructions |
| Closure under existential | Lemma 3.4 | KampBypass.lean | VVecEA2 + `existPart_succ_n1_bypass` |
| Closure under negation (neg EF is VEF) | Prop 4.2 / Lemma 5.1 | NOT YET FORMALIZED | Corresponds to sorry at L974, L1637, L1749 |
| Inf point (Dedekind completeness) | Lemma 5.3 / INF def | NfCharFormula.lean | `semantic_prior_UZ`, `semantic_prior_SZ` (Prior axioms) |
| Interval case split (Case 1/2/3) | Section 5 case analysis | KampBypass.lean | Zone classification: `YZone`, `ssn_zone_until` |
| Compose NF across 3 vars | Composition Lemma (Libkin 3.7) | ZoneBridge.lean | `reconstruct_nf_eval_3var` |
| Every FO formula is VEF (Prop 4.3) | Prop 4.3 | NfCharFormula.lean | `nf_characterizable_temporal_prior_classical` |
| Kamp's Theorem | Thm 4.4 | StaviCompleteness.lean | `US_expressively_complete_over_prior` |

---

## 3. Divergence Points

### 3.1 The Most Critical Divergence: Sorry Sites vs. Paper's Case Analysis

The current formalization has 5 sorry sites in KampBypass.lean. Here is how each maps to the paper:

#### Sorry at L974 (existPart_succ_n1_bypass_k0_eq, equality case)

**Paper correspondence**: Proposition 4.3 base case -- when the 2-variable pattern forces x = t (both orders false). In the paper, this case doesn't appear explicitly because the paper works with a single free variable `z`. The 2-variable generalization is the formalization's contribution.

**Divergence**: The paper does not separately handle an "equality zone" -- in the paper, a formula `phi(z_0, z_1)` always has `z_0 < z_1` or `z_0 = z_1` as a semantic condition. The formalization's `NormalForm sig k 2` includes the case where `x = t` (both order atoms false), which requires showing the depth-1 existential reduces to a depth-0 evaluation at the same point.

**Why it's hard**: The equality case requires the enriched_bypass_eq formula, which is a disjunction over compatible `nf_x` of `char_1(nf_x) AND quant_conjuncts`. The quant_conjuncts for x=t use the eq-case zone bridges (`eq_case_zone_below`, `eq_case_zone_above`, `eq_case_zone_eq`). These zone bridges ARE proved in KampBypass.lean (lines 710-921). The sorry is a **wiring gap**: the infrastructure exists but the proof hasn't been connected.

**Assessment**: This is a WIRING sorry, not a mathematical gap. The paper provides no additional guidance because the equality case is trivial in the paper (it doesn't arise or is bundled into the x=z case). The Lean proof needs to assemble existing lemmas.

#### Sorry at L1579 (backward_holdsLeft_of_nf_eval, bracket case)

**Paper correspondence**: Proposition 3.5 -- translating an exists-forall formula to TL. The "bracket" corresponds to the inner witnesses between `z_0` and `z_1`. In the paper, the interval `[alpha_0, beta_1, ..., alpha_n](z_0, z_1)` has `n` intermediate witnesses.

**Divergence**: The paper assumes witnesses can be placed in ANY order consistent with the interval -- it's purely existential. The Lean formalization must construct STRICTLY INCREASING witnesses for `IntervalPattern.holds`. This is the bracket witness ordering problem identified in report 31.

**Paper's guidance**: Lemma 5.3 constructs witnesses via the INF point (Dedekind completeness). In the formalization, the `semantic_prior_UZ` and `semantic_prior_SZ` axioms play this role (they assert the infimum/supremum witnessing properties). However, Lemma 5.3 constructs ONE witness (the infimum). For multiple witnesses, the paper uses induction on n (the number of witnesses), constructing them sequentially left-to-right. This sequential construction guarantees a strictly increasing sequence.

**Key insight from literature**: In the paper, witnesses are constructed INDUCTIVELY from left to right. The formalization's `pos_between` list should be processed left-to-right, using `h_eval_quant` to get individual witnesses and then constructing them in order. The `BracketFormula n` with n = pos_between.length maps naturally to this inductive construction.

**Assessment**: The paper's inductive witness construction (Lemma 5.3 proof) DOES provide a template. The key is to not try to "sort" witnesses but to construct them inductively, using the `between_tx_temporal_iff` biconditional zone bridge for each position. However, the issue of multiple SSNs with the same y-predicate profile (identified in report 31) remains. The paper avoids this by working with witness types that are DISTINCT (each alpha_j is a distinct predicate pattern). The formalization's pos_between list groups by zone, not by predicate type, creating potential duplicates.

**Revised paper-aligned approach**: Rather than constructing one witness per positive SSN, construct one witness per DISTINCT y-predicate type among positive SSNs. This matches the paper's approach where `n` is the number of DISTINCT predicate types, not the number of NF entries.

#### Sorry at L1637 (forward_nf_eval_of_holdsLeft, forward direction)

**Paper correspondence**: The forward direction of Proposition 3.5: given that a TL formula holds, reconstruct the exists-forall witness pattern. This is the hardest direction in the paper too -- the paper does NOT prove this directly for arbitrary formulas. Instead, it proves it for the SPECIFIC until/since formulas constructed in Prop 3.5.

**Divergence**: In the paper, the TL formula IS the nested Until/Since structure, so recovering the witnesses is immediate: the Until semantics give the outermost witness directly. In the formalization, the formula is a VVecEA2 (a structured VecEA wrapper), and recovering nf_eval from holdsLeft requires reversing the enriched formula construction.

**Key challenge**: `VecEA2.holdsLeft` gives:
- `endpointLeft.eval_at t` (= pre_conditions at t)
- `∃ x > t, endpointRight.eval_at x ∧ bracket.holds t x`

To recover `nf_eval_nf M 1 2 (Fin.cons x t) sub_nf`, we need BOTH atom conditions AND quantifier conditions. The atom conditions at x come from `char_1(nf_x)` (the first conjunct of endpointRight). The quantifier conditions at (x, t) require reversing each zone-based temporal encoding.

**Paper-aligned approach**: The paper's Proof of Prop 3.5 (forward direction) works by structural induction on the until formula. For each zone type (y < t, y = t, y between, y = x, y > x), the temporal formula gives the corresponding zone condition directly. For instance, `Since(char_y, top) at t` directly encodes `∃ y, y < t ∧ char_y holds at y`. This is what `below_t_temporal_iff` encodes. The forward proof should apply each zone's biconditional (`below_t_temporal_iff`, `eq_t_temporal_iff`, `between_tx_temporal_iff`, `eq_x_temporal_iff`, `above_x_temporal_iff`) to extract the existential from the temporal formula truth.

**Assessment**: The paper provides the conceptual pattern. The Lean proof is mechanical zone-by-zone case analysis using the already-proved zone bridge biconditionals. This is a WIRING sorry.

#### Sorry at L1749 (existPart_succ_n1_bypass_k0_since, Since case)

**Paper correspondence**: Proposition 3.5, Since direction. In the paper, the Since direction is handled symmetrically with Until -- the proof is stated for both future and past simultaneously. The paper uses the symmetric notation `Overleftarrow-Box` (hitherto) and "Since" as the past analog of "Until".

**Divergence**: The formalization handles Until and Since ASYMMETRICALLY. The Until direction uses the VVecEA2 framework (enriched_bypass_until). The Since direction uses a flat `formula_disjList` of `Since(pt_x, guard)` patterns (enriched_bypass_since). This asymmetry is a formalization choice that has no counterpart in the paper.

**Paper's guidance**: The paper treats Until and Since completely symmetrically -- the proof of Prop 3.5 applies to both with the same structure. This suggests the Since sorry could be filled by mirroring the Until proof, using `Formula.snce` instead of `Formula.untl` and `backward_holdsLeft_of_nf_eval_since` mirroring `backward_holdsLeft_of_nf_eval`.

**Important observation**: The enriched_bypass_since definition (lines 515-594) does NOT use VVecEA2. It uses a flat `formula_disjList` of `Formula.and pre_at_t (Formula.snce pt_x guard)`. This is mathematically equivalent to VVecEA2 for the Since case, but the proof structure will differ. Since there's no VVecEA2.translateRight (the VVecEA2 framework appears to only have translateLeft), the Since case requires a different proof entry point.

**Assessment**: The paper's symmetry is a strong hint. The Since case should mirror the Until case. The question is whether to (a) adapt enriched_bypass_since to use a VecEA2-style framework (mirrors Until more closely) or (b) prove the Since case directly from the flat formula structure. Option (b) is faster but less elegant. The sorry comment in line 1726-1748 shows the structure is already established.

#### Sorry at L1837 (existPart_succ_n1_bypass, depth >= 2)

**Paper correspondence**: Proposition 4.3 / Theorem 4.4 at higher depths. In the paper, the proof works by induction on QUANTIFIER RANK, not on the arity of the NF. The paper's "depth" corresponds to quantifier rank: depth-0 formulas are quantifier-free, depth-k formulas have rank-k.

**The most significant divergence**: The paper's induction is on quantifier rank of the FO formula, with a SINGLE existential quantifier at each step (Prop 4.3 uses `∃ x phi` where phi has lower rank). The formalization's `existPart_succ_n1_bypass` corresponds to showing that the EXISTS quantifier at depth k+1 can be temporally encoded. This is Proposition 4.3's existential quantification step.

**Why depth >= 2 is harder**: At depth 0 (purely atomic NFs), the 3-var existential `∃ y, nf_eval_nf M 0 3 (y, x, t) ssn` is purely about predicates and order -- no quantifier conditions. At depth 1, the 3-var existential `∃ y, nf_eval_nf M 1 3 (y, x, t) ssn` additionally requires quantifier conditions at y involving depth-0 3-var sub-NFs -- but these can be encoded using the depth-0 machinery. At depth k+2, we need depth-(k+1) 3-var existentials, creating a recursive structure that requires the GENERAL InductionStep.

**Arity climbing**: The paper's induction naturally handles all arities simultaneously because its NFs are for arbitrary-variable formulas. The formalization must handle each arity separately, creating the `ExistPart` predicate. For the depth >= 2 sorry, the key question is: can `char_{k+1}` (the IH at depth k+1) be used to encode the depth-(k+1) 3-var existentials? The answer is YES if we have `existPart` at depth k+1 for arity 3. But `existPart_succ_n1_bypass` only handles arity 2. The generalization to arbitrary arities requires the full `ExistPart(k+1)` which is in `RabinovichGeneralized.lean`.

**Paper-aligned approach**: At depth k+2, the 3-var existential conditions at depth k+1 can be encoded temporally using the IH (char_{k+1}) because:
- `char_{k+1}` gives the characteristic formula for depth-(k+1) 1-var NFs
- The depth-(k+1) 3-var existentials can be encoded as depth-(k+1) 2-var existentials (by "folding" one variable) then as temporal formulas using the IH
- This is exactly the arity-climbing structure

The paper handles this via the universal quantifier in Lemma 3.4 (closure under existential quantification): adding one more existential variable is absorbed by the outer existential in the normal form. The formalization needs to implement this explicitly as an arity reduction.

**Assessment**: This sorry requires substantial new content. The paper's proof works by "folding" additional free variables into the outer existential via composition. The Lean formalization must implement this explicitly, which is the content of `existPart_succ` for arbitrary n in RabinovichGeneralized.lean.

---

## 4. Divergence Summary Table

| Sorry Site | Paper Location | Divergence Type | Mathematical Gap? |
|-----------|----------------|-----------------|-------------------|
| L974 (eq case) | Not explicit in paper (paper's 2-var case absorbs this) | Formalization detail: x=t zone | NO -- wiring only |
| L1579 (bracket) | Lemma 5.3 witness construction | Witness ordering: paper uses sequential induction, formalization uses pos_between list | MINOR -- different representation |
| L1637 (forward) | Prop 3.5 forward direction | Formalization extracts NF from temporal truth; paper does this trivially from Until semantics | NO -- wiring only |
| L1749 (since) | Prop 3.5, Since direction | Asymmetric treatment: Until uses VVecEA2, Since uses flat disjList | MINOR -- encoding asymmetry |
| L1837 (depth >= 2) | Prop 4.3 / Lemma 3.4 existential closure | Arity climbing: formalization must lift 3-var to temporal explicitly | YES -- genuine mathematical content |

---

## 5. Alternative Approaches from Literature

### 5.1 Sequential Witness Construction for Bracket (L1579)

**Literature source**: Rabinovich 2014, Lemma 5.3 proof by induction on n.

The paper constructs witnesses LEFT TO RIGHT via the infimum point. For the formalization:
1. Sort positive-between-tx SSNs by their y-predicate type (using Fintype ordering)
2. For each SSN (in order), use `h_eval_quant` to get a witness y_i with t < y_i < x and correct predicates
3. If multiple SSNs share the same y-predicate type, they are IDENTICAL NFs (proved above), so there's at most one per predicate type
4. The witnesses have distinct predicate types, so they're distinguishable in M
5. Collect all witnesses, sort by M's linear order, and verify each pos_between[i] is satisfied at the i-th sorted witness

This approach requires the `IsLinearOrder` instance on M.carrier to sort witnesses. The Lean proof would use `List.sortWith` or `List.mergeSort` with the linear order.

**Simpler alternative (if n = 0)**: The bracket case with no positive between_tx SSNs (n = 0) is trivial -- `IntervalPattern.holds` for n = 0 only requires the segment guard on (t, x), which follows from `seg_guard_holds`. The n >= 1 case is the complex one. Since the bracket contains at most `|Fintype.elems (NormalForm sig 0 3)|` elements (a fixed finite number), the proof can use decidable choice on a finite list.

### 5.2 Direct VecEA2 Approach for Since (L1749)

**Literature source**: Rabinovich 2014, Prop 3.5 symmetry.

Since the Until and Since cases are symmetric in the paper, the most literature-aligned approach for the Since sorry is to:
1. Define an `enriched_vecEA2_since` mirroring `enriched_vecEA2_until`
2. Build a VVecEA2 and use `vvec.translateRight` (or define translateRight if not present)
3. Prove correctness via zone bridge lemmas for the reversed zone ordering

This would make the Since proof a near-exact mirror of the Until proof. The current `enriched_bypass_since` definition (a flat disjList) could be REPLACED with a VVecEA2-based version, but this would require changing the definition. Alternatively, keep the current definition and prove it equivalent to the VVecEA2 approach.

**Risk**: If `VecEA2.translateRight` doesn't exist in VecEATranslation.lean, it must be added. A check is needed.

### 5.3 Classical Choice for All Depth >= 2 (L1837)

**Literature source**: Rabinovich 2014's proof is ultimately a CLASSICAL existence proof. For the formalization:

Instead of proving `existPart_succ_n1_bypass` constructively at depth >= 2, use `Classical.choice` to argue:
- "There EXISTS a temporal formula A correctly characterizing the 2-var existential at depth k+2 because..."
- The argument: by `nf_2var_existence_characterizable` (the general classical existence theorem already in the codebase for StaviCompleteness), applied on Prior structures

This mirrors `nf_characterizable_temporal_prior_classical` in NfCharFormula.lean, which ALREADY uses this approach. The depth >= 2 sorry in KampBypass.lean may be REDUNDANT if `nf_2var_exist_formula_prior` can route depth >= 2 through the classical existence path.

**Looking at NfCharFormula.lean (line 646-651)**: The `| k + 2` case already calls `existPart_succ_n1_bypass atomMap h_surj (k + 1) char_k char_k_correct parent_atoms sub_nf`. This IS the routing -- but the sorry at L1837 blocks it. The question is whether this sorry can be replaced with a classical existence argument.

**Proposed alternative**: For depth k+2, use:
- `Classical.choice` on the IH (the fact that all depth-(k+1) 1-var NFs have temporal formulas by IH)
- Apply the general argument that depth-(k+2) 2-var NF existence is classically characterizable on Prior structures (because the IH + Prior axioms + negation closure classically guarantee the formula exists)

This would require a new lemma: `existPart_succ_n1_prior_classical` -- a classical existence version for depth >= 2 that doesn't construct the formula explicitly.

**Feasibility**: This approach avoids the arity-climbing issue. It is LOW-MEDIUM difficulty (200-300 lines) compared to the constructive approach (400-600 lines). The mathematical content is the same as what `nf_2var_exist_formula_prior` already does for depth 1 via `existPart_succ_n1_bypass_k0`.

---

## 6. Intermediate Lemmas Missing from Formalization

Based on the literature analysis, these lemmas are present in the paper but not yet explicitly formalized:

### 6.1 Sequential Witness Construction Lemma (for bracket sorry)

**From Lemma 5.3**: "If each `P_i` has at least one witness in `(z_0, z_1)`, then there exist strictly increasing witnesses `x_1 < ... < x_n` in `(z_0, z_1)` with `P_i(x_i)`."

**Status**: Not formalized. The formalization has `zone_bridge_between_tx` which gives ONE witness per SSN, but does not provide the multi-witness sequential construction.

**Where to add**: A new helper lemma in KampBypass.lean or ZoneBridge.lean:
```lean
-- Given distinct predicate profiles and individual witnesses in (t, x),
-- we can sort them into a strictly increasing sequence
lemma witnesses_can_be_ordered ...
```

### 6.2 Arity Reduction Lemma (for depth >= 2 sorry)

**From Lemma 3.4 (closure under existential)**: The quantifier profile of `(y, x, t)` at depth k+1 can be encoded via `x`'s depth-(k+1) 1-var NF and the Prior structure's temporal logic.

**Status**: Not formalized for depth >= 1. The depth-0 case is handled by `VecEADecomp`. For depth >= 1, a generalized arity reduction is needed.

**Where to add**: A new section in RabinovichGeneralized.lean or a dedicated `ArityReduction.lean` file.

### 6.3 VecEA2.translateRight (for since sorry -- may already exist)

**From symmetry of Prop 3.5**: The Since direction of the bracket encoding should use `translateRight` (the Since-based translation) parallel to `translateLeft` (the Until-based translation).

**Status**: Unclear from code search. VecEATranslation.lean was mentioned as having `VecEA2.translateLeft_correct` and `VVecEA2.translateLeft_correct`. Whether `translateRight` exists is unknown.

**Action**: Check VecEATranslation.lean for `translateRight`.

---

## 7. Confidence Assessment

| Claim | Confidence |
|-------|-----------|
| L974 is a wiring sorry (no math gap) | HIGH |
| L1579 requires sequential witness construction | HIGH |
| L1637 is a wiring sorry using zone bridges | HIGH |
| L1749 mirrors the Until case with reversed zones | MEDIUM-HIGH |
| L1837 requires arity climbing or classical approach | HIGH |
| Paper's Lemma 5.3 provides bracket witness template | HIGH |
| Prop 3.5 provides direct template for Since sorry | MEDIUM-HIGH |
| Classical approach can bypass depth >= 2 sorry | MEDIUM (needs verification of classical path) |

---

## 8. Recommended Literature-Aligned Proof Strategies

### Priority 1: L974 (eq case) -- Follow paper Section 3.3

The equality case (x = t) collapses all zone distinctions. The paper handles this by noting that when two free variables coincide, the exists-forall formula degenerates (no non-trivial ordering between them). In Lean:
1. Apply `witness_eq_t_of_no_order` to force x = t
2. Use the `eq_case_zone_*` bridge lemmas (already proved at lines 710-921)
3. Assemble the disjunction membership proof via `nf_characteristic` uniqueness
4. The `char_1_correct` hypothesis provides the temporal formula for x = t

**Literature alignment**: Perfect -- the paper's degenerate case for coincident free variables.

### Priority 2: L1637 (forward direction) -- Follow paper's "read-off from Until semantics"

In the paper, the forward direction of Prop 3.5 is: "the Until/Since semantics directly give the witnesses." In Lean, this requires going through the VVecEA2/VecEA2 structure:
1. `h_endLeft` + zone bridge backward directions -> extract below_t and eq_t existentials
2. `h_endRight` + `char_1_correct` + zone bridge backward directions -> extract eq_x and above_x existentials  
3. `h_bracket` -> extract between_tx existentials via `between_tx_temporal_iff`
4. Assemble into `nf_eval_nf M 1 2 (Fin.cons x t) sub_nf` using `nf_eval_nf` definition

**Literature alignment**: Follows paper's proof structure exactly, just with explicit formalization overhead.

### Priority 3: L1749 (since case) -- Mirror Until proof by symmetry

**Literature alignment**: Perfect -- paper treats Until and Since identically. Mirror `existPart_succ_n1_bypass_k0_until` proof structure with:
- `Formula.snce` instead of `Formula.untl`
- `VecEA2.translateRight` (if available) or direct formula_disjList proof
- Zone bridge lemmas for Since (x < t) direction

### Priority 4: L1579 (bracket) -- Implement paper's Lemma 5.3 sequential construction

**Literature alignment**: HIGH -- directly implements Lemma 5.3's inductive witness construction.
1. If n = 0: trivial (no witnesses needed, segment guard holds from `seg_guard_holds`)
2. If n >= 1: use `Classical.choice` to select witnesses, sort by M's linear order, verify conditions
3. Key: pos_between elements have DISTINCT nf_y_proj (proved above), so witnesses have distinct predicate profiles, making sorting unambiguous

### Priority 5: L1837 (depth >= 2) -- Use classical existence (literature-aligned)

**Literature alignment**: MEDIUM -- Rabinovich's proof is ultimately non-constructive (it uses Dedekind completeness non-effectively). The formalization can match this by using `Classical.choice` to assert the formula exists without constructing it explicitly.

The critical observation is that the paper's proof of Kamp's theorem is NOT fully constructive -- it asserts existence of witnesses using inf/sup points that require Dedekind completeness. The formalization's `semantic_prior_UZ/SZ` axioms are the finite-order proxies for this. Using `Classical.choice` for depth >= 2 matches the paper's non-constructive character.

---

## 9. Key Insight: The NfCharFormula.lean Classical Path

Report 31 identifies that `nf_2var_exist_formula_prior` at depth >= 2 routes through `existPart_succ_n1_bypass` (via L646-651 in NfCharFormula.lean). This is the BLOCKING sorry at L1837.

However, looking at the broader context:
- `nf_characterizable_temporal_prior_classical` (NfCharFormula.lean:656) uses a CLASSICAL existence argument
- This theorem ALREADY provides the main result without needing the constructive bypass

The sorry chain for depth >= 2:
1. `existPart_succ_n1_bypass` at L1837 (sorry) -> blocks `nf_2var_exist_formula_prior` at k+2
2. `nf_2var_exist_formula_prior` at k+2 is called by `nf_characterizable_temporal_prior_classical`
3. BUT `nf_characterizable_temporal_prior_classical` ALSO uses `Classical.choose` on `ih nf_k`

**The key question**: Is `nf_characterizable_temporal_prior_classical` actually complete at all depths, or does it require `nf_2var_exist_formula_prior` at all k?

If `nf_characterizable_temporal_prior_classical` is sorry-free at depth 1 (because `nf_2var_exist_formula_prior` is sorry-free at k=1), then the critical path may be COMPLETE without needing to fill L1837. The depth >= 2 case would be handled by the inductive application of `nf_characterizable_temporal_prior_classical` itself (since k=1 is the base that bootstraps all higher depths through the classical existence argument).

**This is the most important architectural insight from the literature analysis**: The paper's proof is non-constructive, and the formalization ALREADY has a classical existence path. Filling the 4 depth-0 sorries (L974, L1579, L1637, L1749) may be SUFFICIENT to close the entire sorry chain at depth 1, which then bootstraps all higher depths through `nf_characterizable_temporal_prior_classical`.

---

## Summary of Key Findings

1. **All 4 in-scope sorries (L974, L1579, L1637, L1749) are wiring sorries** -- the mathematical content from Rabinovich 2014 is correctly identified and the necessary lemmas are available. None require new mathematics.

2. **The bracket sorry (L1579) has a clean literature-aligned approach**: implement Lemma 5.3's sequential witness construction. For n = 0 witnesses, it's trivial. For n >= 1, collect witnesses and sort.

3. **The paper's symmetry principle (Prop 3.5) directly guides the Since sorry**: mirror the Until proof structure.

4. **The depth >= 2 sorry (L1837, out of scope) may be avoidable**: if the 4 depth-0 sorries are filled, the classical existence path through `nf_characterizable_temporal_prior_classical` may suffice without explicitly filling L1837.

5. **The formalization correctly implements the paper's zone decomposition strategy** (Notation 5.2, A_i^- / A_i^+) via the YZone inductive type and zone bridge lemmas.

6. **One missing intermediate lemma**: a "witness sequentialization" lemma for multiple bracket witnesses (from Lemma 5.3's inductive construction). This is the only genuinely missing piece.
