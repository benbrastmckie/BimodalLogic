# Research Report: Task #107 — Root Blocker Resolution: g_ordered and Non-Domain Extension

**Task**: 107 - Burgess chronicle construction for BX representation theorem
**Date**: 2026-04-25
**Mode**: Team Research (4 teammates)
**Session**: sess_1777132417_a3f143

## Summary

Four teammates rigorously analyzed Options A (two-sided seeds), B (Cantor isomorphism), and discovered Option C (C4+C0 forward_G). **The C4+C0 argument (Option C) is WRONG** — a critical error in the proof sketch was identified by the Critic. **Option A (two-sided seeds with duality) is the viable path** for the root blocker, combined with **Option B (Cantor isomorphism) for non-domain extension**. The key mathematical insight: the duality theorems (`g_content_sub_imp_h_content_sub` / `h_content_sub_imp_g_content_sub`) plus `lemma_2_5b` transitivity make g_ordered maintainable as an inductive invariant — but seed consistency must be proved using the C2' invariant's g(x,y) as witness.

## Key Findings

### 1. CRITICAL: The C4+C0 Forward_G Argument is WRONG (Teammate C — DEFINITIVE)

The proof sketch from research report 23 (and endorsed by Teammate D) claims:

> G(φ) = ¬(⊤ U ¬φ) ∈ f(x). Suppose ¬φ ∈ f(y). ⊤ ∈ f(y). By C4: ∃z with ⊥ ∈ f(z). Contradiction.

**This is incorrect.** C4 (ChronicleTypes.lean:304-309) states:

```
¬(γ U δ) ∈ f(x) ∧ γ ∈ f(y) → ∃z: δ.neg ∈ f(z)
```

With γ = ⊤, δ = φ.neg: `δ.neg = (φ.neg).neg = φ.neg.neg` (Formula.lean:294: `neg φ = φ.imp bot`).

C4 gives **φ.neg.neg ∈ f(z)** (double negation), NOT ⊥ ∈ f(z). By DNE in MCS, φ ∈ f(z) — but this is φ at an INTERMEDIATE point z, not at y. Repeating the argument with (x, z) instead of (x, y) produces an infinite descending sequence z > z' > z'' > ... converging to x but never reaching y. **No contradiction is obtained.**

**Verdict**: forward_G genuinely requires g_ordered (or equivalent). The C4+C0 "shortcut" does not work. Report 23's claim that "g_content_chain_property can be DELETED" and "forward_G/backward_H follow from C4/C4' + C0" must be **retracted**. The comment at ChronicleConstruction.lean:819 ("forward_G is a consequence of the truth lemma, not an INPUT to it") is aspirational but unimplemented — the actual dependency is linear: g_ordered → limit_forward_G → chronicle_fmcs.forward_G → box_stable → dd_countermodel.

### 2. Two-Sided Seeds ARE Viable via Duality (Teammates A + C — HIGH)

**The critical insight**: When inserting z between adjacent x and y with a two-sided seed:

```
Seed(z) = {target} ∪ g_content(f(x)) ∪ h_content(f(y))
```

The duality theorem chain gives FULL g_ordered preservation:

| Property needed | Source | Proof |
|----------------|--------|-------|
| g_content(f(x)) ⊆ f(z) | Seed construction | Direct: seed ⊆ f(z) |
| h_content(f(y)) ⊆ f(z) | Seed construction | Direct: seed ⊆ f(z) |
| g_content(f(z)) ⊆ f(y) | Duality | h_content(f(y)) ⊆ f(z) ⟹ g_content(f(z)) ⊆ f(y) |
| h_content(f(z)) ⊆ f(x) | Duality | g_content(f(x)) ⊆ f(z) ⟹ h_content(f(z)) ⊆ f(x) |
| g_content(f(w)) ⊆ f(z) for w < x | lemma_2_5b | g_content(f(w)) ⊆ f(x) [IH] + g_content(f(x)) ⊆ f(z) [seed] |
| g_content(f(z)) ⊆ f(w) for w > y | lemma_2_5b | g_content(f(z)) ⊆ f(y) [duality] + g_content(f(y)) ⊆ f(w) [IH] |

**Key theorems used** (all sorry-free in codebase):
- `g_content_sub_imp_h_content_sub` (ChronicleConstruction.lean:701): g_content(A) ⊆ B ⟹ h_content(B) ⊆ A
- `h_content_sub_imp_g_content_sub` (ChronicleConstruction.lean:748): h_content(B) ⊆ A ⟹ g_content(A) ⊆ B
- `lemma_2_5b` (PointInsertion.lean:262): g_content transitivity via temp_4 (G(φ) → G(G(φ)))
- `lemma_2_5b_past` (PointInsertion.lean:283): h_content transitivity via past_4

**Why insertion between adjacent points avoids the "intermediate old point" problem**: At insertion time, z is between ADJACENT x and y. By definition of adjacent, no old domain point exists between x and y. So the only new pairs involving z are (w, z) with w ≤ x and (z, w) with w ≥ y — exactly the cases covered above.

### 3. Seed Consistency: The KEY Open Question (Teammates A + C — MEDIUM)

The two-sided seed `S = {target} ∪ g_content(f(x)) ∪ h_content(f(y))` must be consistent (deductively closable to an MCS) for the approach to work.

**What we know**:
- By duality (IH → g_ordered at stage n → g_content(f(x)) ⊆ f(y)): h_content(f(y)) ⊆ f(x)
- So h_content(f(y)) ⊆ f(x), meaning h_content adds no formulas outside f(x)
- The existing seed `{target} ∪ g_content(f(x))` is proved consistent (forward_temporal_witness_seed_consistent)
- Adding h_content(f(y)) ⊆ f(x) to the seed adds formulas that are in f(x)

**The consistency proof strategy via C2'**: The ChronicleInvariant maintains C2': R3Maximal(f(x), g(x,y), f(y)) for adjacent x < y. The g(x,y) value is an MCS. If g_content(f(x)) ⊆ g(x,y) and h_content(f(y)) ⊆ g(x,y), then the base seed g_content(f(x)) ∪ h_content(f(y)) is consistent as a subset of the consistent set g(x,y).

**Open sub-question**: Does R3Maximal(f(x), g(x,y), f(y)) imply g_content(f(x)) ⊆ g(x,y)? The rRelation constrains positive Until formulas, but g_content contains elements with G(φ) ∈ f(x), and G(φ) = ¬(⊤ U ¬φ) is a NEGATION of Until. The rRelation does not directly constrain negated Until formulas. **This needs investigation** — if g_content(f(x)) ⊆ g(x,y) does NOT follow from R3Maximal alone, then the consistency proof needs a different approach.

**Alternative consistency argument**: Since h_content(f(y)) ⊆ f(x) (by duality), the two-sided seed is:
```
{target} ∪ g_content(f(x)) ∪ (subset of f(x))
```
The existing C5 seed consistency proof constructs an MCS D ⊇ {target} ∪ g_content(f(x)) via the r3Relation (Lindenbaum extension). If we can show this D also contains h_content(f(y)) — which is a subset of f(x) — the proof extends. This requires analyzing whether the specific D constructed by r3Relation/Lindenbaum inherits f(x) membership for h_content formulas.

### 4. Option B (Cantor Isomorphism) is Sound but Partial (Teammate B — HIGH)

**What Option B solves**: The non-domain extension problem. After Cantor isomorphism, every rational is a domain point, eliminating the `chronicle_fmcs.forward_G` sorry at ChronicleToCountermodel.lean:195.

**What Option B does NOT solve**: `omega_chain_g_ordered` (the root blocker). The Cantor isomorphism renames domain points but doesn't change the mathematical dependency on g_ordered.

**Mathlib API confirmed**: `Order.iso_of_countable_dense` (Mathlib.Order.CountableDenseLinearOrder) produces `Nonempty (α ≃o β)` given `LinearOrder`, `Countable`, `DenselyOrdered`, `NoMinOrder`, `NoMaxOrder`, `Nonempty` on both types. All instances provable for the limit_dom subtype.

**Implementation sketch (Option B1)**: Transport limit_f to all of ℚ via `cantor_f(q) = limit_f(iso.symm(q).val)`. This preserves Rat's AddCommGroup for shifting. Estimated 8-10 hours beyond g_ordered resolution.

**Sorry sites solved by Option B**: 3 of 13 (chronicle_fmcs forward_G/backward_H + restricted_tc)
**Sorry sites NOT solved by Option B**: 10 of 13 (g_ordered x2, C4 hard cases x2, lemma_2_6_full, restricted coherence x6)

### 5. C5 Elimination Needs Architectural Change (Teammate C — HIGH)

Current C5 elimination places witnesses BEYOND all domain points. For g_ordered to hold, the seed must include g_content(f(max_dom)), but the current seed only contains g_content(f(ce.x)) where ce.x may not be max_dom.

**Fix**: Place C5 witnesses BETWEEN existing points using two-sided seeds (g_content of left neighbor + h_content of right neighbor), rather than at the boundary. This changes the C5 elimination architecture but is consistent with the two-sided seed approach.

**Alternative fix**: When placing beyond all points, use g_content(f(max_dom)) in the seed. This requires F(beta) ∈ f(max_dom), which follows from G(F(beta)) ∈ f(ce.x) (via BX4 + g_ordered IH propagation to max_dom). Needs careful verification.

### 6. No Escape from g_ordered (Teammate C — HIGH)

All alternative approaches to avoid g_ordered were examined and found blocked:

| Approach | Why It Fails |
|----------|--------------|
| C4+C0 forward_G | C4 gives φ.neg.neg not ⊥; infinite descent doesn't terminate |
| C2 rRelation | rRelation constrains positive Until formulas; G(φ) = ¬(⊤ U ¬φ) is negative |
| C3 interval containment | Needs g_content(f(x)) ⊆ g(x,y) which doesn't follow from R3Maximal alone |
| Direct limit proof | Reduces to finite-stage g_ordered by f-immutability |

**Conclusion**: g_ordered must be maintained inductively. The two-sided seed + duality is the correct mechanism.

## Synthesis

### Conflicts Resolved

1. **C4+C0 viability (Teammates C vs D)**: Teammate D endorses Option C (forward_G from C4+C0). Teammate C proves the argument is flawed. **Resolution: Teammate C is correct.** C4 produces φ.neg.neg (double negation), not ⊥. The infinite descent argument on dense domains fails. Teammate D's analysis is retracted.

2. **Two-sided seed viability (Teammates A vs C)**: Teammate A claims two-sided seeds fail (Case 3: uncontrolled G-formulas from Lindenbaum). Teammate C's Gap A3 analysis shows the duality theorem DOES control g_content(f(z)): h_content(f(y)) ⊆ f(z) implies g_content(f(z)) ⊆ f(y). **Resolution: Both are partly right.** Teammate A missed the duality argument for Case 3, but correctly identified seed consistency as the remaining open question.

3. **Whether Option B is sufficient (all teammates)**: Unanimous agreement: Option B solves non-domain extension ONLY, not the root blocker. **It must be combined with Option A.**

### Gaps Identified

1. **Seed consistency via C2'**: Does R3Maximal(f(x), g(x,y), f(y)) guarantee g_content(f(x)) ⊆ g(x,y)? If yes, g(x,y) witnesses consistency. If no, need alternative consistency proof. **This is the single remaining mathematical question.**

2. **C5 elimination architecture**: Must be redesigned to either (a) place witnesses between existing points with two-sided seeds, or (b) use g_content(f(max_dom)) for boundary placement. Both are viable but need implementation.

3. **C4 hard case (δ ∈ both endpoints)**: With two-sided seeds and g(x,y) from C2', the hard case reduces to: find an MCS D between f(x) and f(y) with ¬δ ∈ D. This is exactly Lemma 2.6 (lemma_2_6_full, currently sorry'd in PointInsertion.lean:762). The two-sided seed consistency makes Lemma 2.6 the critical path for the C4 hard case.

### Recommendations

**Immediate (1-2 hours)**: Verify whether g_content(f(x)) ⊆ g(x,y) follows from R3Maximal + g_ordered. Check the r3Relation definition and properties. If confirmed, the seed consistency argument is complete. If not, investigate alternative consistency proofs.

**Phase 1 (5-8 hours)**: Implement two-sided seeds for all elimination functions:
- Modify C4/C4' elimination to use two-sided seed (resolve the hard case)
- Modify density elimination to use two-sided seed
- Modify C5/C5' elimination architecture
- Prove g_ordered inductive step using duality + lemma_2_5b

**Phase 2 (8-10 hours)**: Apply Option B (Cantor isomorphism):
- Prove limit_dom subtype instances (Countable, DenselyOrdered, NoMinOrder, NoMaxOrder)
- Define cantor_f via Order.iso_of_countable_dense
- Rewire chronicle_fmcs to use cantor_f
- Eliminate non-domain extension entirely

**Phase 3 (5-8 hours)**: Close remaining sorry sites (restricted coherence conditions, downstream wiring).

**Total estimated effort**: 20-30 hours (with 50% buffer for false lemma discoveries: 30-45 hours).

## Teammate Contributions

| Teammate | Angle | Status | Confidence | Key Contribution |
|----------|-------|--------|------------|------------------|
| A | Two-sided seeds | completed | HIGH | Proved duality gives seed consistency (g_content ∪ h_content); identified Lindenbaum uncontrolled G-formulas; showed C2+C3 alternative |
| B | Cantor isomorphism | completed | MEDIUM-HIGH | Confirmed Mathlib API; proved Option B solves 3/13 sorries; identified AddCommGroup obstacle resolved by B1 |
| C | Critic | completed | HIGH | **DEBUNKED C4+C0 argument** (φ.neg.neg not ⊥); proved no escape from g_ordered; confirmed duality resolves Case 3; identified C5 architecture gap |
| D | Horizons | completed | HIGH (strategic) | Effort audit (70-75h spent, 20-50h remaining); no existing Lean 4 temporal completeness; MVP analysis; roadmap alignment |

## Critical Retraction

**Report 23 Claim (RETRACTED)**: "g_content_chain_property can be DELETED" and "forward_G/backward_H follow from C4/C4' + C0."

**Corrected**: forward_G requires g_ordered. The C4+C0 argument produces φ.neg.neg at intermediate points (not ⊥), and infinite descent on dense domains does not terminate. g_ordered must be maintained inductively via two-sided seeds + duality.

## References

- ChronicleConstruction.lean:701-784 — Duality theorems (sorry-free)
- PointInsertion.lean:262-291 — lemma_2_5b/lemma_2_5b_past (sorry-free)
- ChronicleTypes.lean:304-309 — C4 definition (δ.neg, not ⊥)
- Formula.lean:294 — `neg φ = φ.imp bot` (φ.neg.neg ≠ φ syntactically)
- Mathlib.Order.CountableDenseLinearOrder — Order.iso_of_countable_dense API
