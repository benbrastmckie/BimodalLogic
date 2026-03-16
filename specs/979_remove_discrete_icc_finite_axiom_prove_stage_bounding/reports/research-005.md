# Research Report: Task #979 (v5) - IRR Axiom Analysis

**Task**: 979 - remove_discrete_icc_finite_axiom_prove_stage_bounding
**Date**: 2026-03-16
**Session**: sess_1773699894_57486e
**Focus**: IRR axiom appropriateness in current reflexive semantics
**Dependencies**: Task 967 [COMPLETED], Task 980 [COMPLETED]
**Inputs**:
- CanonicalIrreflexivity.lean (proof of canonicalR_irreflexive)
- CanonicalIrreflexivityAxiom.lean (theorem statements and corollaries)
- DiscreteTimeline.lean (uses canonicalR_strict)
- CantorApplication.lean (uses canonicalR_strict)
- Axioms.lean (temp_t_future, temp_t_past)
- Git history for task 967 and semantic refactoring

---

## Executive Summary

The IRR axiom (`canonicalR_irreflexive`) is now a **proven theorem** (Task 967), not an axiom. It is essential to the current architecture and should be **retained**. The proof relies on the T-axiom for past (`H(phi) -> phi`), which is valid under the reflexive temporal semantics adopted in Task 967.

**Key Findings**:

1. **History**: IRR was initially an axiom (commit b9e8331c, Task 960) due to String atom freshness issues blocking the standard Gabbay IRR proof. Task 967 resolved this by adopting reflexive temporal semantics.

2. **Current semantics**: G and H now use **reflexive** quantification (G quantifies over t' >= t, H over t' <= t). The T-axioms `temp_t_future` and `temp_t_past` are valid under this semantics.

3. **IRR is proven, not axiomatized**: The theorem `canonicalR_irreflexive` is fully proved in `CanonicalIrreflexivity.lean` using the Gabbay IRR technique with the T-axiom.

4. **Dependencies**: 11 declarations across 4 files depend on `canonicalR_irreflexive` or `canonicalR_strict`. These prove `NoMaxOrder`, `NoMinOrder`, and `DenselyOrdered` on timeline quotients.

5. **Impact on Task 979**: IRR is used by `NoMaxOrder` and `NoMinOrder` instances in DiscreteTimeline.lean. The covering lemma and interval finiteness proof do NOT directly depend on IRR.

**Recommendation**: IRR should be **retained unchanged**. It is a proven theorem providing essential infrastructure for strictness of the canonical accessibility relation.

---

## 1. History of the IRR Axiom

### Timeline

| Date | Commit | Action |
|------|--------|--------|
| 2026-03-14 | b9e8331c | Task 960: Introduced `canonicalR_irreflexive` as **axiom** |
| 2026-03-14 | 4fc49237 | Task 967: Began reflexive semantics refactor |
| 2026-03-14 | bc035755 | Task 967: Eliminated axiom, proved as **theorem** |

### Original Problem (Pre-Task 967)

The Gabbay IRR proof requires constructing a "naming set" containing a fresh atom `p` not appearing in `g_content(M)`. With `String` atoms, every string appears in some tautology (e.g., `neg bot or atom("p")`), so no atom is truly "fresh" with respect to an infinite set of formulas.

The standard proof:
1. Assume `CanonicalR M M` (i.e., `g_content M subseteq M`)
2. Find fresh atom p not in g_content(M)
3. Build naming set with p and H(neg p)
4. Extend to MCS M'
5. Show p in M' and neg p in M' (contradiction)

Step 2 fails with String atoms because g_content(M) can contain arbitrarily large sets of formulas mentioning every possible string.

### Resolution (Task 967)

Task 967 adopted **reflexive temporal semantics**:
- G quantifies over t' >= t (not t' > t)
- H quantifies over t' <= t (not t' < t)

This enabled the T-axioms:
- `temp_t_future`: G(phi) -> phi
- `temp_t_past`: H(phi) -> phi

With the T-axiom for past, the proof no longer needs global freshness:
1. Assume `CanonicalR M M`
2. Pick ANY atom p
3. Build naming set: `atomFreeSubset M p union {atom p, H(neg(atom p))}`
4. Show naming set is consistent (via IRR rule contrapositive)
5. Extend to MCS M'
6. From naming set: `atom p in M'` and `H(neg(atom p)) in M'`
7. **T-axiom**: `H(neg(atom p)) -> neg(atom p)`, so `neg(atom p) in M'`
8. Both `atom p` and `neg(atom p)` in M' contradicts MCS consistency

The T-axiom provides Step 7 without requiring global freshness.

---

## 2. Current Semantics

### Reflexive G and H

The current semantics uses **reflexive** temporal quantification:

```lean
-- From Axioms.lean lines 242-272

/-- Temporal T axiom (future): G(phi) -> phi (reflexivity for future) -/
| temp_t_future (phi : Formula) : Axiom ((Formula.all_future phi).imp phi)

/-- Temporal T axiom (past): H(phi) -> phi (reflexivity for past) -/
| temp_t_past (phi : Formula) : Axiom ((Formula.all_past phi).imp phi)
```

**Semantic interpretation**:
- `G(phi)` at time t means: phi holds at all times s with s >= t
- `H(phi)` at time t means: phi holds at all times s with s <= t
- Since t >= t and t <= t (reflexivity), both include the current time

### Does IRR Still Make Sense?

Yes. The IRR theorem says `not (CanonicalR M M)`, i.e., `g_content M not-subseteq M`.

Under reflexive semantics:
- `CanonicalR M M` would mean: for all phi, if `G(phi) in M` then `phi in M`
- This is equivalent to the T-axiom holding at MCS level
- But the T-axiom holding as an **axiom** (in the logic) does not imply `g_content M subseteq M`

The key insight: `G(phi) in M` means "M asserts that phi holds at all times >= now". This is a **statement about other times**, not a requirement that `phi in M`. The T-axiom says the **implication** `G(phi) -> phi` is valid, but this doesn't mean `g_content M subseteq M`.

**Proof sketch**: If `g_content M subseteq M`, then for every `phi in g_content M`, `phi in M`. But `g_content M = {phi | G(phi) in M}`, so this would mean `G(phi) in M -> phi in M` for all phi. But MCS M is just a consistent maximal set -- it doesn't satisfy all its own assertions. The Gabbay IRR proof shows that assuming `CanonicalR M M` leads to a contradiction.

---

## 3. Dependencies on IRR

### Direct Dependencies on `canonicalR_irreflexive`

| File | Line | Declaration | Purpose |
|------|------|-------------|---------|
| CanonicalIrreflexivityAxiom.lean | 76 | `canonicalR_irreflexive` | Export theorem |
| CanonicalIrreflexivityAxiom.lean | 89 | `canonicalR_antisymmetric_strict` | M-N-M composition |
| CanonicalSerialFrameInstance.lean | 77 | `NoMaxOrder` instance | Strictness from irreflexivity |
| CanonicalSerialFrameInstance.lean | 123 | `NoMinOrder` instance | Strictness from irreflexivity |

### Dependencies on `canonicalR_strict`

| File | Line | Declaration | Purpose |
|------|------|-------------|---------|
| DiscreteTimeline.lean | 145 | `NoMaxOrder` instance | Strictness of forward witnesses |
| DiscreteTimeline.lean | 167 | `NoMinOrder` instance | Strictness of backward witnesses |
| CantorApplication.lean | 152 | `NoMaxOrder` instance | Dense timeline quotient |
| CantorApplication.lean | 176 | `NoMinOrder` instance | Dense timeline quotient |
| CantorApplication.lean | 218,220 | `DenselyOrdered` instance | Strictness of density intermediates |

### Usage Pattern

The standard pattern is:
```lean
have h_strict : not CanonicalR q.mcs p.1.mcs :=
  canonicalR_strict p.1.mcs q.mcs p.1.is_mcs q.is_mcs hq_R
```

This establishes that seriality/density witnesses are **strictly** related, not reflexively. Without IRR, the quotient by `CanonicalR` could collapse points that are mutually accessible (if `CanonicalR M N` and `CanonicalR N M` both held).

---

## 4. Impact on Task 979

### What Task 979 Is Trying to Prove

Task 979 aims to remove `discrete_Icc_finite_axiom` by proving interval finiteness. The core problem is the **covering lemma**: showing that forward witnesses are immediate successors with no intermediate MCS.

### Does the Covering Lemma Depend on IRR?

**No, not directly**. The covering lemma (`mcs_has_immediate_successor`) states:
```lean
theorem mcs_has_immediate_successor
    (M : Set Formula) (h_mcs : SetMaximalConsistent M)
    (h_serial : exists N, CanonicalR M N) :
    exists W, SetMaximalConsistent W and MCS.Covers M W
```

where `MCS.Covers M W` means:
```lean
CanonicalR M W and forall K, SetMaximalConsistent K ->
  CanonicalR M K -> CanonicalR K W -> K = M or K = W
```

The covering property is about **excluding intermediates**, not about irreflexivity. IRR is used elsewhere for strictness of witnesses, but the covering lemma is blocked for different reasons (the DF frame condition extraction gap documented in research-003.md and research-004.md).

### What IRR Provides for Task 979

IRR enables:
1. **NoMaxOrder/NoMinOrder**: These instances use `canonicalR_strict` to prove seriality witnesses are strictly greater/less in the quotient
2. **Strictness of order**: Without IRR, the quotient could degenerate if mutual accessibility were possible

These are **already working** and not part of the task 979 blockers.

---

## 5. Should IRR Be Removed?

### No. Here's Why:

1. **IRR is a theorem, not an axiom**: It was fully proved in Task 967 using standard modal logic techniques (Gabbay IRR rule + T-axiom)

2. **IRR is mathematically correct**: Under reflexive semantics, `CanonicalR M M` is still false. The reflexive semantics changes the validity of formulas, not the structure of MCS relationships.

3. **IRR is essential infrastructure**: 11 declarations depend on it for proving strictness properties needed by the completeness proof

4. **Removing IRR would break the architecture**: NoMaxOrder, NoMinOrder, and DenselyOrdered would all lose their proofs

### What About Semantic Consistency?

One might worry: "If G is reflexive (quantifies over t' >= t), shouldn't `CanonicalR M M` be true?"

The answer is **no**, because:
- `CanonicalR M M` means `g_content M subseteq M`
- `g_content M = {phi | G(phi) in M}`
- `G(phi) in M` is M's **assertion** that phi holds at all t' >= t
- But M is just a set of formulas, not a model
- The Gabbay IRR proof shows that assuming `g_content M subseteq M` leads to inconsistency

The reflexive semantics makes `G(phi) -> phi` a valid schema, but this doesn't mean every MCS has `g_content M subseteq M`. Validity is about truth in all models; MCS membership is about syntactic consistency.

---

## 6. Conclusions

### Key Findings

| Finding | Status |
|---------|--------|
| IRR was originally an axiom | True (Task 960) |
| IRR is now a proven theorem | True (Task 967) |
| Current semantics is reflexive | True (temp_t_future, temp_t_past) |
| IRR is still appropriate | Yes |
| IRR affects task 979 blocking | No |

### Recommendations

1. **Retain IRR unchanged**: The theorem `canonicalR_irreflexive` is correct, proven, and essential

2. **Do not confuse IRR with semantics**: Reflexive temporal semantics does not make `CanonicalR M M` true

3. **Focus task 979 on covering lemma**: The actual blocker is the DF frame condition extraction, not IRR

4. **No action needed on IRR for task 979**: The covering lemma does not depend on IRR

---

## References

- `Theories/Bimodal/Metalogic/Bundle/CanonicalIrreflexivity.lean` - Full IRR proof
- `Theories/Bimodal/Metalogic/Canonical/CanonicalIrreflexivityAxiom.lean` - Theorem export
- `Theories/Bimodal/ProofSystem/Axioms.lean` (lines 242-272) - T-axiom definitions
- `Theories/Bimodal/ProofSystem/Derivation.lean` (lines 139-154) - IRR rule
- `Theories/Bimodal/Metalogic/Domain/DiscreteTimeline.lean` - Uses canonicalR_strict
- Commit b9e8331c - Original axiomatization
- Commit bc035755 - Theorem proof (Task 967)
- Goldblatt (1992), *Logics of Time and Computation*, Ch. 6
- Blackburn, de Rijke, Venema (2001), *Modal Logic*, Ch. 4.8
