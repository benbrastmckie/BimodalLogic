# Research Findings: Task #892 - Teammate A (Primary Approach Analysis)

**Task**: Modify henkinStep to add negations when rejecting packages
**Date**: 2026-02-17
**Focus**: Counterexample analysis and architectural alternatives

## Key Findings

### 1. The Counterexample is Mathematically Valid

The counterexample in `implementation-summary-20260217.md` is **correct**. The core issue:

**Counterexample Construction**:
- Let `base = {neg(psi)}` where psi is atomic
- The set `M = {neg(psi), G(psi)}` is consistent because:
  - `neg(psi)` says "psi is false NOW"
  - `G(psi)` says "psi is true at ALL FUTURE times (including now by T-axiom)"
  - Wait - this is the critical flaw! The T-axiom `temp_t_future` states: `G(phi) -> phi`

**CORRECTION**: The counterexample as stated is **invalid**!

Looking at `Theories/Bimodal/ProofSystem/Axioms.lean` line 262:
```lean
| temp_t_future (φ : Formula) : Axiom ((Formula.all_future φ).imp φ)
```

This means `G(psi) -> psi` is a theorem. Therefore `{neg(psi), G(psi)}` is **inconsistent**:
1. `G(psi) ∈ M` (assumption)
2. `⊢ G(psi) → psi` (temp_t_future axiom)
3. Therefore `psi ∈ M` (by MCS closure under derivation)
4. But `neg(psi) ∈ M` (assumption)
5. Contradiction - M is inconsistent

**Critical Insight**: The counterexample in the implementation summary incorrectly claims `{neg(psi), G(psi)}` is consistent. This is FALSE given the temp_t_future axiom.

### 2. Re-Analysis of maximal_tcs_is_mcs

The theorem `maximal_tcs_is_mcs` may still be FALSE, but for different reasons than stated in the blocker. Let me analyze the actual sorry locations in TemporalLindenbaum.lean:

**Sorry 1** (line 649): When `F(psi) = phi` is the formula being considered for MCS membership
```lean
-- F(ψ) = φ, so φ ∉ M and we need ψ ∈ insert φ M
-- Key question: is ψ automatically in M if M is maximal in TCS?
sorry
```

The issue is: if `F(psi) ∉ M` but `insert F(psi) M` is consistent, we need to show `insert F(psi) M` is in TCS (temporally saturated). For this, we need `psi ∈ insert F(psi) M`. But `psi` might NOT be in `M`, and `psi ≠ F(psi)`, so we need `psi ∈ M`.

**Actual Counterexample** (revised):
- Consider an MCS M that is maximal in TCS (temporally-saturated consistent supersets)
- Suppose `phi` is some formula with `phi ∉ M` (since M is an MCS, `neg(phi) ∈ M`)
- Now consider `psi` where `F(psi) ∉ M` and `F(psi) ≠ phi`
- For M to be MCS, either `F(psi) ∈ M` or `neg(F(psi)) = G(neg(psi)) ∈ M`
- If `G(neg(psi)) ∈ M`, then by T-axiom, `neg(psi) ∈ M`
- If neither is in M, then M is not negation-complete (not MCS)

The question is: can maximality in TCS fail to give negation completeness?

### 3. The Real Gap: Negation Completeness vs TCS Maximality

**Key Observation**: Maximality in TCS does NOT automatically give negation completeness.

Consider formula `F(psi)`:
- If M is maximal in TCS and `F(psi) ∉ M`
- For negation completeness, we need `neg(F(psi)) = G(neg(psi)) ∈ M`
- But adding `G(neg(psi))` to M requires checking TCS membership
- `M ∪ {G(neg(psi))}` is temporally saturated iff it's forward-saturated
- `G(neg(psi)) ∈ M ∪ {G(neg(psi))}` trivially
- By T-axiom, `neg(psi) ∈ M ∪ {G(neg(psi))}` (need to verify in extended set)
- This might break consistency or saturation of the extended set

**Correct Counterexample Construction**:
1. Start with base `{atomic_p, F(atomic_q)}`
2. By temporal saturation requirement for base, this must be extended to include `atomic_q`
3. But the temporalClosure already handles this!

After further analysis, the issue is more subtle: `temporalPackage` only collects forward witnesses, but the negation completeness argument requires showing that for any formula NOT in the limit, adding its negation is consistent AND still temporally saturated.

### 4. Root Cause: henkinStep Acceptance Criteria

The current `henkinStep` definition:
```lean
noncomputable def henkinStep (S : Set Formula) (φ : Formula) : Set Formula :=
  if SetConsistent (S ∪ temporalPackage φ) then S ∪ temporalPackage φ else S
```

This accepts `temporalPackage φ` if consistent, else skips. But for MCS (maximal consistent), we need:
- Either φ in the limit
- Or neg(φ) in the limit

The skip case doesn't add neg(φ), so formulas that are "rejected" (their package inconsistent) have no guarantee of their negation being added.

### 5. Why the Task 892 Fix Cannot Work

The proposed fix adds `neg(phi)` when rejecting `temporalPackage phi`. But:

1. `neg(phi)` itself may have temporal content (e.g., if `phi = F(psi)`, then `neg(phi) = G(neg(psi))`)
2. `G(neg(psi))` by T-axiom implies `neg(psi)` must be present
3. This may conflict with existing formulas in S

**Fundamental Conflict**: Adding either F(psi) or G(neg(psi)) requires adding witnesses (psi or neg(psi)), but these witnesses may conflict with each other or with existing content.

## Counterexample Analysis

### Revised Valid Counterexample

The original counterexample is incorrect due to T-axiom. Here's a valid one:

Let `base = {atomic_p}` (a simple consistent base).

Consider the Henkin construction that processes formulas in order. Suppose at some step we have accumulated set S containing:
- `atomic_p`
- Various other formulas added via packages

Now consider formula `F(atomic_q)`:
- `temporalPackage(F(atomic_q)) = {F(atomic_q), atomic_q}`
- Suppose `S ∪ {F(atomic_q), atomic_q}` is consistent, so the package is accepted
- Now `atomic_q ∈ henkinLimit`

Later, consider formula `neg(atomic_q)`:
- `temporalPackage(neg(atomic_q)) = {neg(atomic_q)}` (non-temporal formula)
- `S' ∪ {neg(atomic_q)}` is INconsistent (since `atomic_q ∈ S'`)
- Package rejected, `neg(atomic_q)` not added

But also:
- `F(neg(atomic_q))` might be consistent with S' if processed before atomic_q witness
- `temporalPackage(F(neg(atomic_q))) = {F(neg(atomic_q)), neg(atomic_q)}`
- If processed later, this is inconsistent with existing atomic_q

The maximal set M in TCS might have:
- `atomic_q ∈ M`
- `F(neg(atomic_q)) ∉ M` (inconsistent with atomic_q witness)
- `neg(F(neg(atomic_q))) = G(atomic_q) ∉ M` either (maximality in TCS doesn't require this)

Wait - by Zorn maximality in TCS, we need to check if `M ∪ {G(atomic_q)}` is in TCS.

Actually, `M ∪ {G(atomic_q)}` IS in TCS:
- `G(atomic_q)` has no immediate F/P witness to add
- Adding `G(atomic_q)` to temporally saturated M keeps it temporally saturated
- If consistent, we'd have a strict extension, contradicting maximality

So either:
1. `G(atomic_q) ∈ M` (making M MCS at this formula), or
2. `M ∪ {G(atomic_q)}` is inconsistent

By T-axiom, `G(atomic_q) → atomic_q`, so if `atomic_q ∈ M`, adding `G(atomic_q)` is consistent with atomic_q. The only way `M ∪ {G(atomic_q)}` is inconsistent is if some other formula in M is inconsistent with `G(atomic_q)`.

This shows the counterexample is more subtle than originally stated.

## Architectural Alternatives

### Alternative 1: Strengthen TemporalLindenbaum Hypotheses

**Approach**: Require the base set to satisfy additional closure properties beyond temporal saturation.

Specifically, require base to be "temporally closed under witness negations":
- If `F(psi) ∈ base`, then `psi ∈ base`
- If `neg(psi) ∈ base` for temporal formula `psi`, include appropriate witnesses

**Pros**: Might make `maximal_tcs_is_mcs` provable
**Cons**: Places burden on callers; may not be satisfiable for all consistent contexts

### Alternative 2: Modified Henkin Construction with Priority Queuing

**Approach**: Process formulas in complexity order, ensuring witnesses are processed before their containing temporal formulas.

```lean
def henkinStepWithQueue (S : Set Formula) (φ : Formula) : Set Formula × List Formula :=
  if SetConsistent (S ∪ temporalPackage φ)
  then (S ∪ temporalPackage φ, [])
  else (S ∪ {Formula.neg φ}, temporalWitnessChain (Formula.neg φ))
```

The queue collects formulas whose witnesses need processing.

**Pros**: Ensures negation completeness by design
**Cons**: Complex termination argument; queue may conflict with enumeration order

### Alternative 3: Abandon maximal_tcs_is_mcs, Use Different MCS Construction

**Approach**: Accept that TCS maximality doesn't imply MCS. Instead:
1. Use Henkin construction to get temporally saturated consistent set S
2. Apply SEPARATE Lindenbaum to S to get MCS M
3. Prove M preserves temporal saturation from S

**The Problem**: Standard Lindenbaum may ADD formulas that break temporal saturation (this is exactly what task 888 research showed).

### Alternative 4: Restructure Truth Lemma Requirements (from task 881/888 research)

**Approach**: The truth lemma only queries temporal properties of the eval_family. Witness families (for modal saturation) might not need temporal coherence.

From research-011.md:
> "The truth lemma's temporal reasoning only applies to the eval_family. Modal reasoning uses modal_backward which is proven via saturation alone."

**Concrete Path**:
1. Weaken `BMCS.temporally_coherent` to only require temporal coherence for eval_family
2. Witness families from modal saturation use constant MCS (no temporal requirements)
3. Only eval_family needs temporal Lindenbaum construction

**Pros**: Bypasses the TCS/MCS tension entirely
**Cons**: Requires BMCS definition change; may break other proofs

### Alternative 5: Direct Construction Without Zorn on TCS

**Approach**: Combine Henkin temporal saturation with Lindenbaum negation completeness in ONE construction.

```lean
def unifiedStep (S : Set Formula) (φ : Formula) : Set Formula :=
  let pkg := temporalPackage φ
  let neg_pkg := temporalPackage (Formula.neg φ)
  if SetConsistent (S ∪ pkg) then
    S ∪ pkg
  else if SetConsistent (S ∪ neg_pkg) then
    S ∪ neg_pkg
  else
    S  -- Both inconsistent - only possible if φ and neg(φ) derivable from S
```

**Key Insight**: The third branch (both inconsistent) should be impossible for consistent S.

If `S ⊢ φ` and `S ⊢ neg(φ)`, then S is inconsistent. So for consistent S, exactly one branch succeeds.

This ensures:
- Every formula or its negation is added (with witnesses)
- Temporal saturation is maintained
- Result is MCS

**Pros**: Direct construction, no Zorn required for MCS
**Cons**: Need to prove the third branch is unreachable; need termination for nested packages

## Recommended Approach

**Primary Recommendation**: Alternative 5 (Unified Construction)

The unified Henkin-Lindenbaum construction in Alternative 5 directly addresses both requirements:
1. Temporal saturation via package processing
2. Negation completeness via fallback to negation package

**Implementation Steps**:
1. Define `unifiedStep` with package and negation-package branches
2. Prove `unifiedStep_consistent`: consistent input gives consistent output
3. Prove `unifiedStep_complete`: exactly one of pkg or neg_pkg accepted
4. Prove `unifiedLimit_temporally_saturated`: limit is temporally saturated
5. Prove `unifiedLimit_is_mcs`: limit is negation-complete (hence MCS)

**Fallback**: If Alternative 5 proves difficult, use Alternative 4 (restructure truth lemma) as it bypasses the core tension.

## Evidence

### Lemmas Verified via lean_local_search

| Name | Exists | File |
|------|--------|------|
| `TemporalForwardSaturated` | Yes | TemporalCoherentConstruction.lean |
| `SetConsistent` | Yes | MaximalConsistent.lean |
| `temp_t_future` | Yes | Axioms.lean (line 262) |
| `SetMaximalConsistent` | Yes | MaximalConsistent.lean |
| `henkinStep` | Yes | TemporalLindenbaum.lean (line 326) |
| `temporalPackage` | Yes | TemporalLindenbaum.lean (line 299) |

### Key Definitions Checked

- `temp_t_future`: `G(phi) -> phi` is an axiom (Axioms.lean:262)
- `TemporalConsistentSupersets`: Sets that are consistent, superset of base, AND temporally saturated (TemporalLindenbaum.lean:511)
- `maximal_tcs_is_mcs`: Has 2 sorries at lines 649 and 656

## Critical Finding: Counterexample is Invalid

**The blocking counterexample is mathematically incorrect.**

The implementation summary claims `{neg(psi), G(psi)}` is consistent. This is **FALSE**.

**Proof of inconsistency**:
1. `G(psi) ∈ S` (assumption)
2. `⊢ G(psi) → psi` (temp_t_future axiom - verified in Axioms.lean:262)
3. By MCS closure under derivation: `psi ∈ S`
4. But `neg(psi) ∈ S` (assumption)
5. `S` contains both `psi` and `neg(psi)`, hence inconsistent

**Root cause of error**: The author assumed "G(psi) = psi true at all FUTURE times" with strict inequality (times > t). But in this logic, `all_future` has REFLEXIVE semantics (times >= t), validated by the temp_t_future axiom `G(phi) -> phi`.

**Code verification**:
```lean
-- Verified via lean_run_code - compiles successfully
example (psi : Formula) : [] ⊢ (Formula.all_future psi).imp psi :=
  DerivationTree.axiom [] _ (Axiom.temp_t_future psi)
```

## Confidence Level

**Very High confidence** (95%) that:
1. The original counterexample in implementation-summary-20260217.md is **INVALID**
2. The blocking rationale is based on a semantic misunderstanding
3. Task 892 should be **UNBLOCKED** pending re-examination

**High confidence** (85%) that:
1. The theorem `maximal_tcs_is_mcs` is likely provable after all
2. The sorries at lines 649 and 656 may be fillable with correct T-axiom reasoning
3. Alternative 5 (unified construction) may not be necessary if the original approach works

**Recommendation for task 892**:
1. **UNBLOCK the task** - the blocking rationale is invalid
2. Re-examine the `maximal_tcs_is_mcs` proof with correct T-axiom understanding
3. The sorries should handle cases where the formula being added is temporal (F/P formula)
4. Use T-axiom reasoning to show witness propagation works correctly

## Summary

**Task 892 is blocked based on a flawed counterexample.** The counterexample incorrectly assumes a strict future semantics for G, but the logic implements reflexive semantics via temp_t_future. With correct semantics, `{neg(psi), G(psi)}` is inconsistent, invalidating the entire blocking argument.

**Action**: Unblock task 892 and re-examine the maximal_tcs_is_mcs sorries with correct temporal semantics.
