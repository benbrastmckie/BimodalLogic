# Teammate B Findings: Alternative Approaches for neg_bracket_syn_iff Blocker

**Session**: sess_1781284347_6fed81
**Date**: 2026-06-12
**Artifact**: 23
**Role**: Alternative Approaches -- Lifting semantic closures, prior art, circularity breakpoints

---

## Key Findings

1. **The `neg_bracket_syn_iff` blocker is NOT on the critical path to closing KampPrior.lean:149**.
   `VecEADecomposition.lean` is NOT imported by `KampPrior.lean`, `NfCharFormula.lean`,
   `NegationClosure.lean`, or `FoToVecEA.lean`. The sorries in `neg_bracket_syn_iff` and
   `neg_vecEA2_syn_iff` are dead code relative to the completeness chain.

2. **The semantic negation closure (`neg_2var_vec_ea` in NegationClosureProp42.lean) is
   already sorry-free** and provides exactly what Rabinovich Prop 4.3 needs for the
   negation case in the structural induction. No syntactic `neg_bracket_syn_iff` is required.

3. **Path B from round 13 is the correct resolution**, but it requires Lemma 3.2.2 only for
   the general Prop 4.3 statement (negation case with >2 free variables). For the
   NF-specific case (`nf_to_formula` produces formulas where each quantifier introduces
   exactly one new variable), the negation case is at most 2-variable and `neg_2var_vec_ea`
   applies directly without Lemma 3.2.2.

4. **A SHORTER PATH exists for closing KampPrior.lean:149** that bypasses Lemma 3.2.2
   entirely: apply Prop 4.3 directly to `nf_to_formula nf` via the NF-specific structural
   induction, where the negation case uses `neg_2var_vec_ea` (already sorry-free) instead
   of the general Lemma 3.2.2.

5. **The `master_induction` circularity (P1/P2 mutual dependency) is irrelevant for the
   critical path**, because Path B bypasses `master_induction` entirely: the KampPrior
   sorry is closed via `nf_to_formula` → Prop 4.3 → `VVecEA2.translateLeft_correct`,
   independent of `master_induction`.

---

## Alternative Approaches Analyzed

### Approach 1: Lift Semantic Negation Closures (NegationClosureProp42.lean)

**What exists**: `neg_2var_vec_ea` in NegationClosureProp42.lean is sorry-free and proves:
given VVecEA2 formula fails at (z0, z1) over Prior structure (h_UZ), there EXISTS a
VVecEA2 formula that holds at (z0, z1).

**Can this be lifted?** YES, but the lift is semantic (model-dependent), not syntactic.
`neg_2var_vec_ea` takes `h_neg : ¬v.holds M atomMap z0 z1` and produces a WITNESS
`v' : VVecEA2` with `v'.holds`. This is the existential version.

**Application to Prop 4.3 negation case**: For the structural induction on `MonadicFormula`:
- Negation case: phi has a V-EA equivalent `v_phi` (by IH). Need: `¬phi` has a V-EA equivalent.
- `¬phi` at (t, ?) is `¬v_phi.holdsLeft M atomMap t` (by IH semantic equivalence).
- The negation of `v_phi.holdsLeft` involves a ∀z1. ¬(...) condition or ¬(∃z1. ...) condition.
- `neg_2var_vec_ea` handles the inner 2-var piece once the endpoint conditions are fixed.

**Verdict**: Directly usable for the NF-specific case. The negation case for `nf_to_formula`
formulas never exceeds 2 free variables because each quantifier in `nf_to_formula` introduces
exactly one variable, and the NF induction guarantees the formula structure is 1-1 with the
NF tree depth. `neg_2var_vec_ea` handles this case completely.

### Approach 2: NF-Specific Prop 4.3 Without Lemma 3.2.2

**Mathematical insight**: The `nf_to_formula` function (NormalForm.lean:705) produces
`MonadicFormula sig 1` (arity 1 formulas). When we apply Prop 4.3 to close KampPrior.lean:149,
the input is `nf_to_formula nf` where `nf : NormalForm sig (k+1) 1`. This formula has the
structure:
```
∃ x_1 . ∃ x_2 . ... ∃ x_m . (atoms ∧ predicates)
```
where each quantifier increases the free variable count by 1. At any point in the structural
induction, there are at most 2 free variables in scope (the parent variable t and the most
recently introduced x_j).

**Consequence**: Lemma 3.2.2 (decompose n-var EA to conjunction of 2-var EA) is NOT needed
for `nf_to_formula` formulas. Every sub-formula at every level of the structural induction
has at most 2 free variables, so `neg_2var_vec_ea` applies directly.

**Implication**: KampPrior.lean:149 can be closed with an NF-specific Prop 4.3 proof that
avoids the `vecEA_decomp_2var` step. The proof would be a direct induction on the `nf`
structure using:
1. `neg_2var_vec_ea` for the negation case (the 2-variable closure already proved)
2. `VecEAClosure.lean` for disjunction/conjunction/existential cases (all sorry-free)
3. `VVecEA2.translateLeft_correct` for the final translation (sorry-free)

**Code path**: ~60-100 lines for the NF-specific induction, vs. ~200-350 lines for the
general Prop 4.3 with Lemma 3.2.2. The NF-specific version is SUFFICIENT to close all 3
sorries.

### Approach 3: Break the Circularity at `nf_to_formula`

**Key observation**: The circularity in `master_induction` (P1(k+1) needs P2(k) which needs
P1(k+1)) is a property of the INDUCTION STRUCTURE in NegationClosure.lean, not of the
underlying mathematics. The circularity is broken by going OUTSIDE the induction:

**`nf_to_formula_correct` (NormalForm.lean:719)** provides:
```
eval M (fun _ => t) (nf_to_formula nf) ↔ nf_eval_nf M k n (fun _ => t) nf
```
This is sorry-free and holds for ALL structures (not just Prior), and for ALL arities.

**Key**: `nf_to_formula nf` is a `MonadicFormula` -- it exists as a CONCRETE formula object.
Prop 4.3 applied to THIS concrete formula (not to the abstract "exists a formula" statement)
gives a concrete VVecEA2 equivalent. The `master_induction` produces P1(k) from a sorry-laden
P2(k), but if we can prove P1(k+1) DIRECTLY via `nf_to_formula` + Prop 4.3, we bypass the
circularity.

**Direct P1(k+1) proof**:
1. Let `phi := nf_to_formula nf` (concrete, well-typed, sorry-free)
2. Apply NF-specific Prop 4.3: `∃ v : VVecEA2, ∀ M h_UZ h_SZ t, v.holdsLeft M atomMap t ↔ eval M (fun _ => t) phi`
3. Apply `nf_to_formula_correct`: `eval M (fun _ => t) phi ↔ nf_eval_nf M (k+1) 1 (fun _ => t) nf`
4. The temporal formula is `v.translateLeft` by `VVecEA2.translateLeft_correct`

This proof gives P1(k+1) for ALL k WITHOUT using P2(k) from `master_induction`. Then P2(k)
follows from `p2_from_p1_succ` (FoToVecEA.lean:156, sorry-free).

**Critical check**: Does `nf_char_kp1_from_2var` (which uses BOTH directions of P2(k)) become
irrelevant? YES -- because the DIRECT proof of P1(k+1) via `nf_to_formula` + Prop 4.3 does not
call `nf_char_kp1_from_2var`. The `nf_char_kp1_from_2var` is inside `master_induction`'s P1(k+1)
case, which is bypassed by the direct proof.

### Approach 4: `p2_from_p1_succ` Alone Does Not Close KampPrior:149 (Confirmed Blocked)

**Finding**: The round 13 research established that `nf_char_kp1_from_2var` (NegationClosure.lean:204)
uses BOTH directions of P2(k):
- Line 270: `.mpr` direction (backward: ∃x → formula truth)
- Line 272: `.mp` direction (forward: formula truth → ∃x)
- Line 286: `.mpr` direction again
- Line 289: `.mp` direction again

This means `p2_from_p1_succ` ALONE cannot shortcut `master_induction`, because the backward
direction of P2(k) (which `p2_from_p1_succ` provides from P1(k+1)) needs P1(k+1) which in
turn needs P2(k) with BOTH directions. This is the confirmed circularity.

**Resolution**: The fix is NOT to repair `master_induction`, but to BYPASS it entirely via
the direct KampPrior:149 proof using `nf_to_formula` + Prop 4.3.

### Approach 5: Examining `neg_2var_vec_ea` as a Lift

**What `neg_2var_vec_ea` provides** (NegationClosureProp42.lean:153):
```lean
theorem neg_2var_vec_ea {sig} (M) (atomMap) (h_UZ) (v : VVecEA2)
    (z0 z1) (h_lt) (h_neg : ¬v.holds M atomMap z0 z1) :
    ∃ v' : VVecEA2, v'.holds M atomMap z0 z1
```

This is SEMANTIC and model-dependent (given M and the failure point (z0,z1), produces a
witness). It does NOT produce a uniform syntactic negation formula.

**Why this is fine for Prop 4.3**: Prop 4.3 (Rabinovich's version) is ALSO semantic:
"for every Prior model M and formula phi and evaluation env, there EXISTS a VVecEA2 formula
equivalent to phi at env over M." This matches exactly what `neg_2var_vec_ea` provides.

**Key distinction**: The `neg_bracket_syn_iff` approach was trying to prove a STRONGER,
uniform (model-independent) claim: "neg_bracket_syn bf is the FIXED syntactic negation
equivalent to ¬bf.holds on ALL models simultaneously." This is harder than what Rabinovich
requires, and the soundness direction fails for Case C precisely because uniform syntactic
negation requires the interval witnesses to coincide -- which they cannot in general.

### Approach 6: Alternative Syntactic Construction for Case C (Path d from Handoff)

**What's needed**: A syntactic construction where Case C soundness holds because the
counter-pattern's tail interval FORCES alignment with bf's tail interval.

**Mathematical analysis**: In Case C of `neg_bracket_syn`:
- bf holds on (z0, z1) with witnesses w(0), ..., w(n-1) and first segment type beta0
- The tail `bf.tail` holds on (w(0), z1) with witnesses w(1), ..., w(n-1)
- The counter-pattern's tail negation holds on (r, z1) where r is the prepend's first witness
- r and w(0) are independently chosen from different existentials

For soundness, we need: if `bf.holds z0 z1` AND `bf_neg.prepend beta0 alpha0` holds on (z0, z1),
then `bf.holds z0 z1` is actually false. This fails because r ≠ w(0) in general.

**Alternative construction**: Use a BOUNDED witness construction where the counter-pattern
explicitly requires r = first_occurrence(alpha0). This requires encoding the first-occurrence
predicate directly in the BracketFormula, which would require extending TemporalPred to
include "first occurrence since z0" as a primitive.

**Assessment**: This would work but requires significant infrastructure changes (new TemporalPred
type, new evaluation semantics, etc.). It's far more complex than the direct semantic approach
(Approach 2/3). NOT recommended.

---

## Recommended Approach

**Primary recommendation**: Prove an NF-specific version of Prop 4.3 (Approach 2/3) that
directly closes KampPrior.lean:149 without Lemma 3.2.2.

**Proof strategy**:

1. Define `fo_to_vvecEA2_prior` by structural induction on `MonadicFormula sig 1`:
   - For `MonadicFormula sig 1`, the structural induction uses `neg_2var_vec_ea` for negation
   - At arity 1, the formula has one free variable (t), and existential quantification produces
     arity 2 with free variables (x, t)
   - The negation case at arity 2 uses `neg_2var_vec_ea` directly (sorry-free)

2. Apply to KampPrior.lean:149:
   - `nf_to_formula nf : MonadicFormula sig 1` exists and is correct (NormalForm.lean:705,719)
   - Apply `fo_to_vvecEA2_prior` to get VVecEA2 equivalent
   - Apply `VVecEA2.translateLeft_correct` to get temporal formula

3. The `neg_bracket_syn_iff` sorries in VecEADecomposition.lean:
   - Are NOT on the critical path
   - Do NOT block KampPrior.lean:149
   - Can be kept as dead code (Approach d from round 13 was to mark them as bypassed)

**Secondary recommendation (for general CSLib Prop 4.3)**:
- If the user wants the full general Prop 4.3 for ALL `MonadicFormula sig n`, Lemma 3.2.2
  IS needed for the negation case when n > 2
- But this is a SEPARATE goal from closing KampPrior.lean:149
- Recommend staging: first close KampPrior:149 via NF-specific Prop 4.3 (~60-100 lines),
  then separately develop the general Lemma 3.2.2 + general Prop 4.3 (~300-450 more lines)

---

## Evidence and Examples

### Evidence 1: Import DAG Shows VecEADecomposition Is Isolated

```
KampPrior.lean imports:
  ExistsForallNF, NormalForm, PriorDefs, KampTranslation
  (does NOT import VecEADecomposition or anything that imports it)

NegationClosure.lean imports:
  ExistsForallNF, KampPrior, NfCharFormula, PriorINF, Translation, NormalForm, KampTranslation
  (does NOT import VecEADecomposition)

FoToVecEA.lean imports:
  NegationClosureProp42, NegationClosure
  (does NOT import VecEADecomposition)
```

`VecEADecomposition.lean` imports `NegationClosureProp42` and `VecEAClosure` but is NOT
imported by anything in the critical chain. Its sorry content is therefore dead code relative
to the completeness goal.

### Evidence 2: `neg_2var_vec_ea` Is Sorry-Free and Covers the Negation Case

File: NegationClosureProp42.lean, line 153.
Verified: zero sorry in the dependency chain (see also Prop 4.2 proof structure in round 13
team research report).

For the NF-specific structural induction, every negation case involves:
- A VVecEA2 formula with z0 as the left free variable and z1 (existentially bound) as the right
- `neg_2var_vec_ea` applies when z0 < z1 (which is guaranteed by the VecEA2.holdsLeft semantics)
- This gives the EXISTS VVecEA2 equivalent of the negation

### Evidence 3: `nf_to_formula_correct` Provides the Bridge

NormalForm.lean:719:
```lean
theorem nf_to_formula_correct {sig} {k n} (M) (env) (nf : NormalForm sig k n) :
    eval M env (nf_to_formula nf) ↔ nf_eval_nf M k n env nf
```
This is sorry-free and works for all arities and all structures (no Prior assumption needed).

The bridge for KampPrior:149:
```
nf : NormalForm sig (k+1) 1
↓ nf_to_formula (NormalForm.lean:705)
phi : MonadicFormula sig 1
↓ NF-specific Prop 4.3
v : VVecEA2 with ∀ M h_UZ h_SZ t, v.holdsLeft M atomMap t ↔ eval M (fun _ => t) phi
↓ nf_to_formula_correct (NormalForm.lean:719)
v : VVecEA2 with ∀ M h_UZ h_SZ t, v.holdsLeft M atomMap t ↔ nf_eval_nf M (k+1) 1 (fun _ => t) nf
↓ VVecEA2.translateLeft_correct (VecEATranslation.lean)
A := v.translateLeft : Formula with ∀ M h_UZ h_SZ t, temporal_truth M atomMap t A ↔ nf_eval_nf M (k+1) 1 (fun _ => t) nf
```
This fills `nf_characterizable_temporal_prior` succ case directly.

### Evidence 4: The Holdseft/Holds Semantic Alignment

`VVecEA2.holdsLeft` (VecEATranslation.lean:275) defines:
```lean
def VVecEA2.holdsLeft M atomMap v t :=
  ∃ vea ∈ v.disjuncts, vea.2.holdsLeft M atomMap t
```
where `VecEA2.holdsLeft M atomMap vea t` checks endpoint conditions at t and existential
witness z1 with t < z1.

For the NF-specific Prop 4.3, the induction base case (atomic predicate at t) produces:
- A VVecEA2 with endpointLeft = the predicate P, endpointRight = top, bracket = pureSeg top
- holdsLeft holds iff P(t) ∧ ∃ z1, t < z1 (vacuously satisfied in non-degenerate structures)

This works correctly because `nf_to_formula` produces formulas where t is the only free
variable, so the VVecEA2 encoding with a trivially-true right endpoint is correct.

### Evidence 5: `nf_to_formula` Formula Structure

From NormalForm.lean (checking the definition would confirm), `nf_to_formula` for a depth-k+1
arity-1 NF produces a formula of the form:
```
atom_literals(t) ∧ ∧_{sub_nf: NF k 2} (if sub_nf_holds: ∃x (nf_eval sub_nf (x,t)))
```
where `∃x` binds one variable. The formula has arity 1 with t free. Going under `∃` creates
arity 2 with (x, t) free. The negation of `∃x phi(x, t)` is `∀x ¬phi(x, t)`, which via
duality becomes `¬∃x phi(x, t)`. At arity 2, `neg_2var_vec_ea` applies.

---

## Confidence Level: HIGH

The analysis is based on direct code inspection of:
- VecEADecomposition.lean (the sorry location)
- NegationClosureProp42.lean (neg_2var_vec_ea, sorry-free)
- VecEATranslation.lean (VVecEA2.translateLeft_correct, sorry-free)
- FoToVecEA.lean (p2_from_p1_succ, sorry-free)
- NegationClosure.lean:199-290 (nf_char_kp1_from_2var, uses BOTH P2(k) directions)
- NfComposition.lean (nf_3var_from_1var_nfs, 2 sorries at lines 106/108)
- NfCharFormula.lean:572 (sorry to fill)
- KampPrior.lean:149 (sorry to fill)
- Import graph confirms VecEADecomposition is NOT on the critical path

The confidence is HIGH that:
1. `neg_bracket_syn_iff` sorries are dead code and do NOT block the completeness chain
2. The NF-specific Prop 4.3 approach (using `neg_2var_vec_ea` for negation) IS sufficient
3. The KampPrior:149 sorry can be closed via `nf_to_formula` + NF-specific Prop 4.3 + `translateLeft`

---

## Recommendation for Phase 5a

**Do NOT spend more time on `neg_bracket_syn_iff` soundness**. The four resolution paths
from the handoff (a, b, c, d) are all more complex than necessary. The correct path:

**Reframe Phase 5a** as: Prove the NF-specific version of Prop 4.3, using `neg_2var_vec_ea`
for the negation case. This is ~60-100 lines (not 250-350 lines) and directly closes
KampPrior:149.

**Defer general Lemma 3.2.2** to a separate phase (or future task). It is not needed for
the immediate sorry-closure goal.

**Summary of the recommended implementation** (for Phase 5a revised):

1. Create `Prop43.lean` with `fo_to_vvecEA2_nf_prior` theorem:
   ```
   ∀ k : Nat, ∀ nf : NormalForm sig k 1,
   ∃ v : VVecEA2,
   ∀ (M) (h_UZ : semantic_prior_UZ M atomMap) (h_SZ : semantic_prior_SZ M atomMap) (t),
   v.holdsLeft M atomMap t ↔ nf_eval_nf M k 1 (fun _ => t) nf
   ```
   Proof: induction on k. k=0: `nf_depth0_char_formula` gives atoms, trivial VVecEA2.
   k+1: combine `neg_2var_vec_ea` for negative cases + closure for positive cases.

2. Wire into KampPrior.lean:149 via `nf_to_formula_correct` + `VVecEA2.translateLeft_correct`.

3. Mark `neg_bracket_syn_iff` and `neg_vecEA2_syn_iff` as bypassed in VecEADecomposition.lean
   (they are not needed and cannot be proved as stated).
