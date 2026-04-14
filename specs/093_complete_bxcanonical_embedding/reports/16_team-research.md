# Research Report: Task #93 Round 16 — Team Synthesis

**Task**: 93 - Close BXCanonical embedding (6 sorry sites in RootScopedChain.lean)
**Date**: 2026-04-14
**Mode**: Team Research (4 teammates)
**Session**: sess_1776204581_003400
**Focus**: Deep mathematical analysis of the forward_F obstruction, rigorous study of all strategies

## Executive Summary

This round uncovered a **fundamental flaw** in Plan v15's core assumption while simultaneously clarifying the **correct mathematical path forward**. The 4 teammates produced 3 critical discoveries:

1. **BX11 3-cycles are real** (Teammate A): A concrete semantic counterexample proves that `bx11_earlier` is non-transitive and can have 3-cycles. This means a "BX11-minimum" (element earlier than ALL others) may not exist, invalidating Plan v15's Phase 2.

2. **The ψ → F(ψ) derivation is via BX8+BX10, not temp_t** (Teammate D): Prior handoffs incorrectly cited temp_t (G(φ) → φ) contrapositive as giving φ → F(φ). The correct derivation is BX8 (ψ → (⊤ U ψ)) + BX10 ((⊤ U ψ) → F(ψ)). This confirms F-obligations are stable but changes the defect-counting analysis.

3. **All alternative approaches are inferior** (Teammate B): Six alternative strategies were systematically analyzed and rejected. The f_carry seed enrichment is provably impossible (confirmed by Boneyard counterexample). FMP/canonical model approaches would require 2000+ LOC rewrite.

### The Central Conflict and Its Resolution

Teammates A and C identified that `target_stays_direct_in_fold`'s precondition (`h_earliest : ∀ χ, χ ∈ others → bx11_earlier M target χ`) may be unsatisfiable due to 3-cycles. Teammate D argued the defect-counting works anyway. The resolution:

**The defect-counting argument has a subtle gap**: While defects (F(χ) ∈ M, χ ∉ M) do decrease when the direct witness is a defect, the enriched fold can also CONVERT non-defects to defects by F-wrapping a formula that was present in M but absent in M'. The net defect change per step is not guaranteed negative.

**However**, the F-obligation set {χ | F(χ) ∈ M} is exactly constant (not just non-increasing). This follows from two facts: (a) no_new_f_defects prevents new F-obligations; (b) the enriched fold preserves F(χ) for every χ in the fold (either χ ∈ M' giving F(χ) ∈ M' via BX8+BX10, or F(χ) ∈ M' directly from the fold's F-wrapping). So the set of formulas "at risk" is fixed and finite — the question is purely about their defect/non-defect status oscillation.

### Recommended Path Forward

The ordered discharge approach remains the ONLY viable path (Teammate B's comprehensive rejection of alternatives), but Plan v15 needs revision to address the 3-cycle gap. Three specific strategies are identified for closing this gap, ranked by feasibility.

## Part 1: The 3-Cycle Counterexample (Teammate A)

### 1.1 Construction

On integer time with MCS M at time 0:
- Formula a holds at times {1, 4}, b at {2}, c at {3}

This produces:
| Formula | In M? | Why |
|---------|-------|-----|
| F(a ∧ F(b)) | YES | a at 1, F(b) at 1 (b at 2) |
| F(a ∧ b) | NO | no time with both a and b |
| F(b ∧ F(c)) | YES | b at 2, F(c) at 2 (c at 3) |
| F(b ∧ c) | NO | no time with both b and c |
| F(c ∧ F(a)) | YES | c at 3, F(a) at 3 (a at 4) |
| F(c ∧ a) | NO | a at 1 (c not), a at 4 (c not) |

Result: strict bx11_earlier forms a 3-cycle: a ≻ b ≻ c ≻ a. No element satisfies `h_earliest` for the full defect list {a, b, c}.

### 1.2 Consequences

- `target_stays_direct_in_fold` (line 1009, proved, sorry-free) is CORRECTLY proved but has a precondition that may be VACUOUSLY satisfied — `h_earliest` cannot always be met
- The compound-construction trick (replacing chi with target.and alpha_chi in the fold) REQUIRES `bx11_earlier M target chi` for each chi to obtain `F(target ∧ alpha_chi) ∈ M`
- Without transitivity, finding a global minimum over n > 2 elements is impossible in the presence of 3-cycles

### 1.3 Impact on Plan v15

Plan v15 Phase 2 states: "find the BX11-earliest F-defect using bx11_earlier_total" and "each step strictly decreases defect count by 1." Both claims are undermined:
- There may be no BX11-earliest defect (3-cycle)
- Even with ordered_discharge_step, the defect count can fluctuate (non-defects becoming defects)

## Part 2: The Defect-Counting Analysis

### 2.1 F-Obligation Set Is Exactly Constant

**Claim**: The set O(n) = {χ ∈ sigma_list | F(χ) ∈ chain(n)} is the same for all n.

**Proof sketch**:
- **Non-growing**: `no_new_f_defects` (OrderedSeedConsistency.lean:232): if G(¬α) ∈ M, then F(α) ∉ M'. Contrapositive: F(α) ∈ M' → G(¬α) ∉ M → F(α) ∈ M. So O(n+1) ⊆ O(n).
- **Non-shrinking**: The enriched fold processes all χ ∈ sigma_list with F(χ) ∈ M. For each such χ, `enriched_fwd_step_preserves` (line 604) gives χ ∈ M' ∨ F(χ) ∈ M'. In the direct case (χ ∈ M'), BX8+BX10 gives F(χ) ∈ M'. In the F-wrapped case, F(χ) ∈ M' directly. Either way, F(χ) ∈ M'. So O(n) ⊆ O(n+1).

### 2.2 Defect Count Can Fluctuate

**Definition**: Defect set D(n) = {χ ∈ O(n) | χ ∉ chain(n)}.

At each enriched step:
- **Direct witness w**: w ∈ M', so w leaves D(n+1) (if it was in D(n))
- **F-wrapped formulas**: F(χ) ∈ M' but possibly χ ∉ M'. If χ ∈ M (non-defect at step n) but χ ∉ M' (dropped by Lindenbaum), then χ ENTERS D(n+1)

**Net effect**: |D(n+1)| = |D(n)| - (defects resolved) + (non-defects that became defects)

The net change is NOT guaranteed negative. A step could create more new defects than it resolves.

### 2.3 Critical Correction of Prior Handoffs

Handoffs 02 and 15 both state: "φ ∈ M → F(φ) ∈ M for any MCS M, by contrapositive of temp_t: G(¬φ) → ¬φ."

**This reasoning is WRONG.** temp_t is G(φ) → φ. Contrapositive: ¬φ → ¬G(φ) = F(¬φ). This gives ¬φ → F(¬φ), NOT φ → F(φ).

The **correct** derivation of φ → F(φ) is:
- BX8: ψ → (⊤ U ψ) (via `psi_imp_until`, TemporalDerived.lean:229)
- BX10: (⊤ U ψ) → F(ψ) (via `until_implies_some_future`, TemporalDerived.lean:190)
- Chain: ψ → F(ψ)

The conclusion (F-obligations are stable) is correct, but the justification was wrong. This is important because it clarifies the exact axiomatic foundation.

## Part 3: Why Alternatives Are All Worse (Teammate B)

| Strategy | Verdict | Key Reason |
|----------|---------|------------|
| Per-formula chain | Partial | Can't merge into single Int-indexed chain |
| f_carry seed enrichment | **DEAD** | Seed `{ψ} ∪ g_content(M) ∪ f_carry(M)` provably inconsistent (Boneyard Task 69 counterexample); G(F(χ)) not derivable from F(χ) |
| Two-phase chain | Same problem | F-loss during Phase 2 steps = same core issue |
| G(F(ψ)) axiom | **DEAD** | F(ψ) → G(F(ψ)) false in linear frames (counterexample: ψ only at t=1) |
| Finite Model Property | Not viable | Would replace 2000+ LOC infrastructure |
| Direct canonical model | Not viable | Reduces to the same chain problem |

**Conclusion**: The ordered discharge approach with `target_stays_direct_in_fold` is the ONLY viable path. All alternatives either have the same core problem or require prohibitive architectural changes.

## Part 4: Literature Alignment (Teammate D)

### 4.1 How Burgess/Goldblatt/Xu Handle This

The standard literature proofs use the same basic strategy — resolve the BX11-earliest F-defect, carry the rest forward. However, they **leave the non-transitivity issue implicit**:

- **Burgess (1984)**: Uses BX11 to determine resolution order but doesn't address whether a minimum exists in the presence of 3-cycles
- **Goldblatt (1992)**: Uses dovetailing enumeration with implicit appeal to BX11 ordering
- **Xu (1988)**: Same strategy, same implicit assumption

**Critical insight**: The paper proofs work because they argue SEMANTICALLY — in the intended model (integers with standard ordering), F-witnesses have a well-ordered temporal structure. The BX11 axiom captures a SYNTACTIC approximation of this semantic ordering, but the syntactic relation is weaker (non-transitive, admits 3-cycles).

### 4.2 No Prior Lean 4 Formalization

No existing Lean 4 formalization of temporal logic completeness exists:
- FormalizedFormalLogic/Foundation: propositional, first-order, modal — NO temporal
- LeanearTemporalLogic: LTL syntax/semantics only, no completeness
- Lentil: TLA model-checking, not completeness

**This project would be the first**, making it publishable at ITP or CPP.

## Part 5: Critical Gaps and Unstated Assumptions (Teammate C)

### 5.1 Gaps Identified

1. **BX11-earliest existence** (FATAL for Plan v15 as written)
2. **Defect count monotonicity** (incorrect — see Section 2.2)
3. **Chain interchangeability** (replacing rr_fwd_chain with ordered_fwd_chain requires re-proving ~30 downstream theorems)
4. **Past-directed BX11'** (needed for backward_P but may not be formalized)
5. **t < 0 case** (no mechanism for F-propagation in backward chain)
6. **backward_P NOT symmetric** (backward chain uses bwd_pred, not enriched step; no enriched_bwd_step exists)

### 5.2 What IS Solid

- `target_stays_direct_in_fold` (proved, line 1009)
- `enriched_resolving_seed_consistent` (proved, OrderedSeedConsistency.lean)
- `bx11_earlier_total` (proved, line 912)
- `enriched_fwd_step_preserves` (proved, line 604)
- `rr_fwd_chain_F_propagate` (proved, line 1124)
- `no_new_f_defects` (proved, OrderedSeedConsistency.lean:232)
- `discharge_single_step` (proved, line 955)
- `discharge_two_step` (proved, line 969)

## Part 6: Strategies to Close the 3-Cycle Gap

### Strategy A: Prove bx11_earlier Is Acyclic (HIGH priority, MEDIUM confidence 50%)

Even without transitivity, if the STRICT part of bx11_earlier (where bx11_earlier M a b AND NOT bx11_earlier M b a) is acyclic on finite sets, a topological sort gives a minimum element.

**Investigation needed**: Teammate A constructed a semantic counterexample showing strict 3-cycles. But this is a SEMANTIC argument on integer models. The question is whether such a configuration can actually arise in an MCS of the BX proof system. The BX axioms might rule out 3-cycles syntactically, even though they are semantically possible over integers.

**Approach**: Attempt to construct a Lean proof that bx11_earlier is acyclic. If it fails, try to construct an explicit 3-formula MCS exhibiting the 3-cycle in Lean (this would be a definitive refutation).

### Strategy B: Fold with Partial Domination (MEDIUM priority, MEDIUM confidence 45%)

Instead of requiring `h_earliest` for ALL others, use `target_stays_direct_in_fold` with only the formulas where bx11_earlier holds, and handle the remaining formulas separately.

**Sketch**: For defects {ψ₁, ..., ψₖ} and target ψ:
- Partition into "good" = {χ | bx11_earlier M ψ χ} and "bad" = {χ | NOT bx11_earlier M ψ χ}
- Apply target_stays_direct_in_fold with target = ψ, others = good list
- This gives ψ ∈ M', g_content(M) ⊆ M', and disjunctive for good formulas
- For bad formulas: they are NOT in the fold, so F-preservation is not guaranteed

**Gap**: Bad formulas' F-obligations are not preserved. This might be acceptable if we can show that the bad set is eventually empty (ψ eventually dominates all others), but this circles back to the ordering-across-steps problem.

### Strategy C: Direct Witness Argument on Existing Chain (HIGHEST priority, MEDIUM-HIGH confidence 60%)

This is the most promising direction, synthesized from Teammates C and D:

**Argument sketch**:
1. `rr_fwd_chain_F_propagate` (proved): F(ψ) in chain(n) → for all m ≥ n, either ψ ∈ chain(s) for some n < s ≤ m+1, or F(ψ) ∈ chain(m+1)
2. Suppose for contradiction: ψ ∉ chain(s) for all s > n. Then F(ψ) ∈ chain(m) for ALL m ≥ n.
3. At each step m, `enriched_fwd_step_resolves_one` (proved, line 622) gives: some w from sigma_list with F(w) ∈ chain(m) is in chain(m+1). The direct witness w is determined by the BX11 fold.
4. **The key new claim**: If F(ψ) persists forever (ψ is never resolved), then at psi's visit steps, the fold's direct witness w satisfies w ≠ ψ. But w is determined by BX11 Case 3 displacements. Case 3 fires for ψ when some other formula χ has an earlier BX11 witness. If ψ is NEVER resolved, it means at every visit step, some χ displaces ψ via Case 3.
5. Each displacement means F(F(ψ ∧ acc) ∧ χ) ∈ M for some χ. By FF_imp_F (proved, line 59): F(ψ ∧ acc) collapses under F.
6. **Open question**: Does this imply a structural constraint on ψ that leads to contradiction? For example, if ψ is displaced at every step, the fold witnesses form a pattern that might violate MCS consistency or finite sigma_list structure.

**This strategy avoids the 3-cycle problem entirely** — it doesn't require finding a BX11-minimum. Instead, it argues that the fold MUST eventually resolve ψ because the alternative (permanent displacement) leads to contradiction.

### Strategy D: Enriched Fold Over Defects Only (MEDIUM priority, MEDIUM confidence 50%)

Modify the enriched fold to process ONLY defects (not non-defects). Then:
- The direct witness w is necessarily a defect (since only defects are in the fold)
- The defect w becomes non-defect at M' (w ∈ M')
- No new defects arise from the fold (non-defects' F-formulas are not in the fold and cannot appear via no_new_f_defects)
- Defect count strictly decreases by 1

**Gap**: Non-defect formulas' F-obligations might not be preserved (they're not in the fold). If F(χ) ∈ M with χ ∈ M (non-defect), the fold doesn't protect F(χ). If F(χ) disappears from M', that's fine (fewer obligations). If F(χ) ∈ M' but χ ∉ M' (new defect)... but wait, χ is NOT in the fold, so the fold doesn't directly cause F(χ) ∈ M'. F(χ) ∈ M' would have to come from the Lindenbaum extension freely adding it. By no_new_f_defects, F(χ) ∈ M' → F(χ) ∈ M (which is true by assumption). But F(χ) ∈ M' is not GUARANTEED by the fold — it depends on the Lindenbaum extension. So F(χ) might or might not survive. If it survives without χ, that's a new defect. If it doesn't survive, that's fine.

**The defect-only fold cannot prevent Lindenbaum from creating new defects from non-defect F-obligations.** So this strategy doesn't cleanly guarantee defect count decrease.

## Part 7: Synthesis and Recommendations

### 7.1 Consensus Points (All 4 Teammates Agree)

1. The ordered discharge approach using `target_stays_direct_in_fold` is the only viable framework
2. f_carry seed enrichment is provably dead
3. G(F(ψ)) is not derivable from F(ψ) — no G-level F-propagation
4. The F-obligation set is exactly constant (via BX8+BX10 for non-shrinking, no_new_f_defects for non-growing)
5. `target_stays_direct_in_fold` is correctly proved but its precondition may not always be satisfiable
6. This would be the first Lean 4 formalization of temporal logic completeness — a publishable contribution

### 7.2 Key Unresolved Question

**Can we guarantee that a SPECIFIC formula ψ is directly resolved at SOME step of the chain?**

- `enriched_fwd_step_resolves_one` guarantees SOME formula is resolved but not which one
- `target_stays_direct_in_fold` guarantees a SPECIFIC formula but requires `h_earliest` (potentially unsatisfiable)
- `discharge_single_step` guarantees a SPECIFIC formula but doesn't preserve other F-formulas

The gap is at the intersection: we need BOTH specificity (resolve ψ) AND preservation (keep other F-formulas alive for later steps).

### 7.3 Recommended Investigation Priority

1. **Strategy C (Direct witness argument)**: Investigate whether the assumption "ψ is never resolved" leads to contradiction via structural analysis of the BX11 fold witnesses. This is the most novel and promising direction, avoids the 3-cycle problem, and works with the existing chain infrastructure.

2. **Strategy A (Acyclicity proof)**: Attempt to prove bx11_earlier is acyclic in Lean. If successful, the rest of Plan v15 works. If a counterexample is found in Lean, this is definitively closed.

3. **Strategy D (Defects-only fold)**: Investigate whether the Lindenbaum extension can be constrained to prevent new defects from non-defect F-obligations.

4. **Strategy B (Partial domination)**: Lowest priority — only useful if Strategies A-C all fail.

### 7.4 Revised Confidence Assessment

| Sorry | Plan v15 Confidence | Revised Confidence | Change Reason |
|-------|--------------------|--------------------|---------------|
| #1 rr_fwd_chain_forward_F | 90% | **55%** | 3-cycle gap real; Strategy C promising but unproven |
| #2 dd_fmcs_forward_F (t<0) | 60% | 50% | No new insight; depends on #1 |
| #3 dd_fmcs_backward_P | 80% | 60% | backward chain lacks enriched step infrastructure |
| #4 dd_bfmcs_restricted_tc | 85% | 55% | Depends on #1 + #3 |
| #5 dd_bfmcs_restricted_buc | 45% | 40% | Independent, no known approach |
| #6 dd_bfmcs_restricted_fuc | 75% | 55% | Depends on #1 |
| Overall (5 of 6) | 85% | **50%** | 3-cycle gap cascades to all dependents |
| Overall (6 of 6) | 40% | **30%** | Compounded uncertainty |

### 7.5 Recommended Next Steps

1. **Before any implementation**: Resolve the 3-cycle question definitively
   - Attempt Strategy A: prove `bx11_earlier` acyclicity in Lean (3-4 hours focused investigation)
   - If it fails: attempt Strategy C contradiction argument (4-6 hours)

2. **If Strategy A succeeds**: Plan v15 Phase 2 becomes viable. Proceed with implementation.

3. **If Strategy A fails but Strategy C succeeds**: Revise plan to use the direct witness argument on the EXISTING chain (avoids ordered_fwd_chain and ~30 theorem re-proofs).

4. **If both fail**: Consider spawning a dedicated task for novel mathematical research on this specific obstruction. The literature leaves this gap implicit and no prior formalization has confronted it.

## Teammate Contributions

| Teammate | Angle | Status | Confidence | Key Contribution |
|----------|-------|--------|------------|------------------|
| A | Primary analysis | completed | MEDIUM (50%) | Concrete 3-cycle counterexample; definitive proof h_earliest may be unsatisfiable; pairwise discharge analysis |
| B | Alternatives | completed | HIGH | All 6 alternatives rejected; f_carry impossibility re-confirmed; G(F(ψ)) counterexample |
| C | Critic | completed | LOW (25%) | 6 critical gaps identified; backward_P asymmetry exposed; chain interchangeability cost identified |
| D | Horizons | completed | HIGH (90%) | BX8+BX10 derivation of ψ→F(ψ) correction; literature deep dive; publishability assessment; defect-counting framework (valid but incomplete) |

## Conflicts Resolved

### Conflict 1: Defect Counting Validity (A/C vs D)

**Teammate D**: "Defect count strictly decreases. After |sigma_list| steps, all defects gone."
**Teammates A/C**: "Defect count fluctuates. Resolved formulas reappear as defects."

**Resolution**: Both are partially right. D correctly identifies that BX8+BX10 (not temp_t) gives ψ → F(ψ), and that resolved formulas become non-defects at the current step. A/C correctly identify that non-defects can become defects at subsequent steps when Lindenbaum drops them. The NET defect change per step is not guaranteed negative. The defect-counting argument needs additional constraints (e.g., defects-only fold) to work cleanly, and even then has gaps.

### Conflict 2: Plan v15 Viability (A/C vs B/D)

**Teammates A/C**: "Plan has fatal gap, approach may not work."
**Teammates B/D**: "No alternative is better, approach is essentially correct."

**Resolution**: Both correct at different levels. The FRAMEWORK (ordered discharge with BX11 fold) is the only viable approach (B/D). But the SPECIFIC implementation in Plan v15 (finding BX11-minimum at each step) has a real gap (A/C). The plan needs revision to address the 3-cycle problem, not abandonment.

## References

- Burgess, J.P. (1984) "Basic Tense Logic" in Handbook of Philosophical Logic
- Goldblatt, R. (1992) "Logics of Time and Computation" 2nd ed.
- Xu, M. (1988) "On some U, S-tense logics"
- Verbrugge, de Jongh, Veltman (2004) "Completeness by Construction for Tense Logics"
- Venema, Y. (1993) "Completeness via Completeness: Since and Until"
- FormalizedFormalLogic/Foundation (Lean 4) — no temporal logic completeness
- LeanearTemporalLogic (Lean 4 LTL) — syntax/semantics only
- Boneyard Task 69: f_carry counterexample
- Reports 13-15, Handoffs 01-15 (task 93 prior research)
