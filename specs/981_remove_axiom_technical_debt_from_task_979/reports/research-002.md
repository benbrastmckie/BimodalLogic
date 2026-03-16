# Research Report: Task #981 — Remove Axiom Technical Debt from Task 979

**Task**: 981 — remove_axiom_technical_debt_from_task_979
**Date**: 2026-03-16
**Mode**: Team Research (3 teammates)
**Session**: sess_1773703227_76434d
**Run**: 002
**Domain**: Logic (tense logic / modal logic)

---

## Executive Summary

All three research teammates confirm the same core diagnosis: **the covering lemma cannot be proven using the current proof strategy** (proving coverage for an arbitrarily defined canonical model). However, Teammate A's literature review of tense logic completeness proofs reveals a **concrete and well-supported alternative path**: the *constructive method*, used in Segerberg/Verbrugge-style proofs, where the immediate successor is **constructed** with a specific "blocking formula seed" so that covering holds by definition, not by subsequent proof.

**Critical Decision**: Accepting the axiom is **not the right answer**. The right answer is to adopt the constructive method, which is standard in the tense logic completeness literature and directly solves the problem.

---

## Conflict Analysis

| Position | Teammates | Reasoning |
|----------|-----------|-----------|
| Accept the axiom | B, C | Current approaches all blocked; gap is fundamental |
| Adopt constructive method | A | Literature shows the standard approach CONSTRUCTS covering, not proves it |

**Resolution**: Teammates B and C are correct that the *current* proof strategy (proving covering for an arbitrary canonical model) cannot succeed. However, they implicitly assume the proof strategy is fixed. It is not. Teammate A's literature review shows that standard discrete tense logic completeness proofs **never attempt to prove covering for an arbitrary canonical model** — they sidestep this entirely by constructing the model to have the covering property.

The axiom acceptance recommendations from B and C are based on a search for proofs *within the current architecture*. The constructive method requires changing the architecture of the immediate successor construction.

---

## Key Findings

### Finding 1: The Standard Approach Avoids the Problem Entirely (Teammate A — HIGH confidence)

Discrete tense logic completeness proofs (Segerberg 1970, Verbrugge et al., Burgess 1979, Goldblatt 1992) use the **completeness by construction** method:

> "At each odd stage of the completeness proof, an immediate successor and an immediate predecessor is assigned to each point... the associated set of the immediate successor u is constructed for some t in such a way that in the union these points will still be immediate successors."
> — Verbrugge et al., *Completeness by construction for tense logics of linear time*

The critical seed for the immediate successor is:

```
discreteImmediateSuccSeed(M) =
  g_content(M) ∪ {¬ψ ∨ ¬G(ψ) | ¬G(ψ) ∈ M}
```

The second component — the **blocking formulas** — is the key innovation. For each `G(ψ)` that is NOT in M (equivalently, `F(¬ψ)` is in M), the successor is forced to include `¬ψ ∨ ¬G(ψ)`. This prevents any MCS between M and the constructed successor from satisfying all of M's G-commitments, ensuring no intermediate can exist.

### Finding 2: ProofChecker's Approach is Non-Standard (Teammate A — HIGH confidence)

The comparison is stark:

| Aspect | Standard Constructive Method | ProofChecker (current) |
|--------|------------------------------|------------------------|
| Order construction | Incremental at odd stages | Canonical model first |
| Successor definition | Constructed with blocking seed | Lindenbaum from plain seed |
| Covering property | Holds by construction | Must be proven as lemma |
| Which MCS is successor | Explicitly chosen | Non-deterministic |

ProofChecker's forward witness is constructed from `{ψ} ∪ g_content(M)` — this seed has **no blocking formulas** and does not force the Lindenbaum extension to be an immediate successor. This is the root of the axiom.

### Finding 3: DF is Trivially Valid Under Reflexive Semantics (Teammate C — HIGH confidence)

A critical architectural observation: under the current reflexive semantics (Task 967 transition), the DF axiom `(F(⊤) ∧ φ ∧ H(φ)) → F(H(φ))` is trivially valid by taking the current time as witness. **DF provides no semantic constraint under reflexive semantics.**

This means:
- The discreteness of the construction does NOT come from DF's semantic content
- It comes from the ABSENCE of density witness insertion in the staged build
- The blocking formula approach is purely syntactic and does not depend on DF's semantic validity

**Important implication**: The consistency proof for `discreteImmediateSuccSeed(M)` cannot rely on DF's semantic content. It must be a purely syntactic argument about MCS membership.

### Finding 4: All Reformulations are Equivalent (Teammates B and C — HIGH confidence)

The following are all equivalent reformulations of the covering lemma:
- `LocallyFiniteOrder` instance on the quotient
- `SuccOrder` + `PredOrder` instance
- `CovBy` predicate between consecutive MCSes
- Stage-bounding for Icc elements
- Well-foundedness of CanonicalR on bounded intervals

No reformulation bypasses the core difficulty. Stage-bounding is additionally **proven false** (task 979 research-003).

### Finding 5: Density-to-Covering Inversion is Impossible (Teammate B — HIGH confidence)

The density proof constructs intermediates using NEGATIVE constraints (`¬CanonicalR M' M`) to CREATE witnesses. The covering proof has POSITIVE constraints (`CanonicalR M K`) and needs to EXCLUDE them. This is a structural asymmetry:

- **Density**: negative constraint → find formula → construct witness
- **Covering**: positive constraints → ??? → contradiction

The transformations are fundamentally incompatible. The density proof template cannot be inverted.

### Finding 6: Segerberg's Original Lindenbaum-Based Proof was Incomplete (Teammate A — HIGH confidence)

> "Professor Segerberg's original proof idea turned out to be incomplete because it used the Lindenbaum lemma, as is usual in canonical model proofs, but because of the infinitary rules involved, immediate access to the Lindenbaum lemma was not available."
> — Sundholm, *Discrete tense logic with infinitary inference rules*

This is precisely why the constructive method was developed: Lindenbaum-based canonical model proofs have fundamental difficulties with discrete logics. ProofChecker is in the same situation.

---

## The Recommended Solution: Adopt the Constructive Method

### Core Idea

Replace the current forward witness construction with a **discrete immediate successor construction** that includes blocking formulas. Covering then holds *by definition* rather than requiring a proof.

### Concretely

**Step 1**: Define `discreteImmediateSuccSeed`:

```lean
def discreteImmediateSuccSeed (M : Set Formula) : Set Formula :=
  g_content M ∪
  {Formula.or (Formula.neg ψ) (Formula.neg (Formula.all_future ψ)) |
   (ψ : Formula) (h : Formula.neg (Formula.all_future ψ) ∈ M)}
```

**Step 2**: Prove consistency of this seed.

This is the critical step. We need: `¬Formula.bot ∉ discreteImmediateSuccSeed M` (or a finite subcollection is consistent). The argument:
- `g_content M` is consistent (M is an MCS)
- The blocking formulas `{¬ψ ∨ ¬G(ψ) | ¬G(ψ) ∈ M}` do not contradict `g_content M`
- Proof: if `G(δ) ∈ g_content M`, then `G(δ) ∈ M`, so `¬G(δ) ∉ M` (by MCS consistency), so the blocking formula for `δ` is not triggered
- The seed is consistent by a finite-subcollection argument using MCS consistency

**Step 3**: Define `discreteImmediateSucc M` as the Lindenbaum extension of this seed.

**Step 4**: Prove covering *by construction*:

The blocking formulas guarantee: for any MCS `K` with `CanonicalR M K` and `CanonicalR K (discreteImmediateSucc M)`, we have `K = M` or `K = discreteImmediateSucc M`. The argument:
- Suppose `K` is strictly between M and its successor W
- Since `CanonicalR M K`, we have `g_content M ⊆ K`
- Since `K ≠ W`, there exists `δ ∈ K` with `¬δ ∈ W`... (the blocking formula forces a contradiction)

**Step 5**: From covering, derive `SuccOrder` instance directly (without LocallyFiniteOrder).

**Step 6**: Remove `discrete_Icc_finite_axiom`.

### Why This Works (and Why Previous Attempts Failed)

The previous attempts tried to prove covering for the **existing** forward witness (which uses a plain Lindenbaum seed). The blocking formula seed changes which MCS is constructed. The Lindenbaum extension of the blocking seed is a *different* MCS than the current forward witness — one that by construction has no intermediates.

### Dependency on DF

The consistency of the blocking seed requires that `g_content M` and the blocking formulas are compatible. This is a purely syntactic MCS argument. The DF axiom's membership in M is NOT needed for this step — the consistency follows from MCS maximality alone.

*Note*: DF membership may be needed for a different step — proving that the blocking seed's Lindenbaum extension is a valid forward witness (i.e., `CanonicalR M (discreteImmediateSucc M)` holds). This requires verifying that the successor contains the F-obligations of M.

---

## Synthesis: What Task 978 Contributes

Task 978 (typeclass-based frame condition architecture) will define `DiscreteTemporalFrame` with `SuccOrder`/`PredOrder`/`LocallyFiniteOrder` constraints. After task 981 proves covering by construction, the `SuccOrder` instance can be derived without `LocallyFiniteOrder`, which can then be removed from the typeclass constraints (or kept as a theorem rather than an assumption).

---

## Risks and Open Questions

### Risk 1: Consistency of Blocking Seed (MEDIUM)

Proving `discreteImmediateSuccSeed M` is consistent requires careful work with the MCS definition. The argument sketched above is plausible but needs Lean verification.

### Risk 2: Covering Proof from Blocking Formulas (MEDIUM-HIGH)

The covering argument at Step 4 is the hardest part. The blocking formulas need to create a contradiction when an intermediate K is assumed. The exact contradiction argument needs to be worked out carefully.

### Risk 3: Structural Disruption (MEDIUM)

Adopting the constructive method may require refactoring `StagedExecution.lean` to produce `discreteImmediateSucc` as a primary construction rather than deriving it from `forwardWitnessPoint`. This could affect other parts of the completeness proof.

### Risk 4: DF Not Needed for Blocking Seed (LOW — POSITIVE)

Teammate C's finding that DF is trivially valid under reflexive semantics means we may not need DF for the blocking seed consistency. This simplifies the proof. The discreteness is architectural (no density intermediates in the construction), not semantic.

---

## Teammate Contributions

| Teammate | Angle | Status | Key Contribution | Confidence |
|----------|-------|--------|-----------------|------------|
| A | Tense logic prior art | Completed | Identified constructive method, blocking formula seed | HIGH |
| B | Alternative constructions | Completed | Confirmed all reformulations reduce to same gap | MEDIUM |
| C | Discreteness axiom leverage | Completed | Critical finding: DF is trivially valid under reflexive semantics | HIGH |

### Conflicts Resolved

1. **Accept vs. restructure**: Teammates B and C recommend accepting the axiom; Teammate A provides a concrete proof path. **Resolution**: Adopt the constructive method. Accepting the axiom assumes the proof strategy is fixed; it is not.

### Gaps Remaining

1. Whether `CanonicalR M (discreteImmediateSucc M)` can be proven (the successor must be a valid forward witness)
2. The exact contradiction argument in Step 4 (covering from blocking formulas)
3. Integration with the broader `StagedExecution.lean` architecture

---

## Recommendations

### Primary Recommendation: Adopt the Constructive Method (Option A)

**Effort estimate**: 4-8 hours of Lean work
**Invasiveness**: Medium (affects immediate successor construction, not the entire staged build)
**Confidence**: MEDIUM that the blocking formula approach will succeed in Lean

Concretely for task 981:
1. Define `discreteImmediateSuccSeed` with blocking formulas
2. Prove consistency of this seed (MCS consistency argument)
3. Define `discreteImmediateSucc` as Lindenbaum extension
4. Prove `CanonicalR M (discreteImmediateSucc M)` (it is a forward witness)
5. Prove covering: no intermediate between M and `discreteImmediateSucc M`
6. Instantiate `SuccOrder` from covering
7. Delete `discrete_Icc_finite_axiom`

### Secondary: Document If Blocked

If the covering proof from blocking formulas fails (Risk 2 materializes), document the specific failure point and escalate to user. Do NOT reintroduce the axiom — mark as `[BLOCKED]`.

---

## References

### Primary Sources
- [Completeness by construction for tense logics of linear time](https://festschriften.illc.uva.nl/D65/verbrugge.pdf) — Verbrugge et al.
- [Discrete tense logic with infinitary inference rules](https://link.springer.com/article/10.1007/BF00357842) — Sundholm
- Segerberg (1970): Original constructive method for tense logic
- Burgess (1979, 1984): Basic tense logic axiomatization

### Task 979 Research
- research-001 through research-005: Multiple failed approaches to covering lemma
- Key confirmed false: stage-bounding, density template inversion

### Task 978 Research
- research-002: LocallyFiniteOrder as bridge (now potentially avoidable via SuccOrder)

### Mathlib References
- `Order.Cover.CovBy` — covering relation
- `Order.SuccPred.Basic.SuccOrder` — immediate successor
- `Order.SuccPred.LinearLocallyFinite.orderIsoIntOfLinearSuccPredArch`
