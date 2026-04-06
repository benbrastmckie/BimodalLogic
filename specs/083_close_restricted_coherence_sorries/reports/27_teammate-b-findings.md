# Teammate B Findings: Disadvantages of Mixed Semantics

**Task**: 83 - Close Restricted Coherence Sorries
**Assignment**: Identify all disadvantages, risks, and problems with mixed semantics (reflexive G/H with >=, strict U/S with >)
**Date**: 2026-04-06

## Executive Summary

The mixed semantics proposal has **no fatal logical inconsistencies** but carries **significant implementation risk** (20+ files affected), introduces **operator meaning changes that cascade through derived theorems**, and creates **several redundancies in the axiom system**. The most dangerous risks are (1) the temp_l / always operator redundancy chain that silently changes proof obligations, (2) the historical precedent of Task 81 where reflexive semantics was abandoned, and (3) the density axiom becoming trivially valid.

**Overall Assessment**: The disadvantages are manageable but non-trivial. The migration is viable if executed carefully with Phase 1 prototype validation.

---

## 1. Logical/Semantic Issues

### 1.1 Derived Operator Meaning Changes

**Confidence: HIGH**

Under mixed semantics, the following operators change meaning:

| Operator | Current (strict) | Proposed (mixed) | Change |
|----------|------------------|-------------------|--------|
| G(phi) at t | phi at all s > t | phi at all s >= t | Includes present |
| H(phi) at t | phi at all s < t | phi at all s <= t | Includes present |
| F(phi) = neg(G(neg(phi))) | exists s > t, phi(s) | exists s >= t, phi(s) | **Includes present** |
| P(phi) = neg(H(neg(phi))) | exists s < t, phi(s) | exists s <= t, phi(s) | **Includes present** |
| X(phi) = bot U phi | exists s > t (strict) | exists s > t (strict) | **Unchanged** |
| Y(phi) = bot S phi | exists s < t (strict) | exists s < t (strict) | **Unchanged** |

**Critical change for F/P**: Under mixed semantics, `F(phi)` becomes true if `phi` holds NOW (take s = t). This means:
- `phi -> F(phi)` becomes valid (trivially: take witness s = t)
- `phi -> P(phi)` becomes valid (same reasoning)
- Any formula phi trivially implies its own future/past existence

This is a **semantic weakening** of F and P -- they no longer express "strictly future/past occurrence" but "present-or-future/past occurrence."

### 1.2 The `always` Operator Becomes Redundant

**Confidence: HIGH**

Currently: `always(phi) = H(phi) AND phi AND G(phi)` (Formula.lean line 326)

Under mixed semantics:
- G(phi) at t already implies phi(t) (since t >= t)
- H(phi) at t already implies phi(t) (since t <= t)

Therefore `always(phi) = H(phi) AND G(phi)` -- the middle conjunct `phi` is **strictly redundant**.

**Impact**: The `always` definition in Formula.lean does not need to change syntactically (the redundancy is harmless for correctness), but:
1. The temp_l axiom (`always(phi) -> G(H(phi))`) simplifies -- the proof in Soundness.lean (lines 211-236) currently unpacks the three-way conjunction via `and_of_not_imp_not`. Under mixed semantics, `G(phi)` already provides `phi(t)`, so the argument simplifies.
2. Documentation and comments referencing "the middle conjunct covers the present" become misleading.
3. Any proof that Pattern-matches on the structure of `always` may need adjustment.

### 1.3 G(phi) -> F(phi) Becomes Trivially True

**Confidence: HIGH**

Under strict semantics, `G(phi) -> F(phi)` requires seriality (NoMaxOrder) -- this is the `seriality_future` axiom. Under mixed semantics:
- G(phi) at t implies phi(t) (reflexivity)
- F(phi) at t is satisfied by witness s = t

So `G(phi) -> F(phi)` is trivially valid without any frame condition. The `seriality_future` axiom becomes **redundant for the G->F direction**.

### 1.4 G(phi) <-> phi AND X(G(phi)) -- Does It Still Hold?

**Confidence: HIGH**

Under mixed semantics:
- Forward: G(phi) implies phi (T-axiom) and G(G(phi)) (temp_4). G(G(phi)) at t means G(phi) at all s >= t, so in particular at succ(t) (i.e., X(G(phi))). So G(phi) -> phi AND X(G(phi)). **Valid.**
- Backward: phi AND X(G(phi)) means phi(t) AND G(phi)(t+1). G(phi)(t+1) means phi(s) for all s >= t+1. Combined with phi(t), we get phi(s) for all s >= t, which is G(phi). **Valid.**

So this equivalence survives. No issue here.

### 1.5 Seriality Becomes Trivially Valid

**Confidence: HIGH**

`seriality_future`: `G(phi) -> F(phi)`. Under mixed semantics, F(phi) includes s = t. Since G(phi) -> phi(t) and phi(t) -> F(phi) (take s=t), seriality is trivially valid.

`seriality_past`: `H(phi) -> P(phi)`. Same argument symmetrically.

`F(top)` = `exists s >= t, True` = True (always, take s = t). Similarly `P(top)` = True.

**Impact**: Seriality no longer encodes `NoMaxOrder`/`NoMinOrder`. These frame conditions must be enforced elsewhere if needed (they ARE needed for X(top) and Y(top) to hold).

### 1.6 Density Axiom (GG(phi) -> G(phi)) Becomes Trivially Valid

**Confidence: HIGH**

Under strict semantics, density requires DenselyOrdered: for t < s, find r with t < r < s, then apply GG to get phi(s).

Under mixed semantics: G(phi) at t means phi(s) for all s >= t. GG(phi) at t means G(phi)(s) for all s >= t, i.e., phi(r) for all r >= s for all s >= t. In particular, for any s >= t, take r = s to get phi(s). So GG(phi) -> G(phi) trivially.

**Impact**: The density axiom no longer encodes DenselyOrdered. This is a **loss of frame correspondence information**. If the project needs density for frame correspondence arguments (canonicity), this is problematic.

---

## 2. Axiom System Concerns

### 2.1 Axioms That Become Redundant

**Confidence: HIGH**

| Axiom | Under Strict | Under Mixed | Reason |
|-------|-------------|-------------|--------|
| `seriality_future` (G(phi)->F(phi)) | Encodes NoMaxOrder | Trivially valid | G(phi)->phi->F(phi) |
| `seriality_past` (H(phi)->P(phi)) | Encodes NoMinOrder | Trivially valid | H(phi)->phi->P(phi) |
| `density` (GG(phi)->G(phi)) | Encodes DenselyOrdered | Trivially valid | GG(phi) at t gives phi(s) for all s >= t |

These three axioms lose their frame correspondence. Under strict semantics, they encode meaningful frame conditions. Under mixed semantics, they become tautologies.

### 2.2 Axioms That Remain Valid (No Issues)

**Confidence: HIGH**

| Axiom | Status Under Mixed | Reason |
|-------|--------------------|--------|
| temp_4 (G->GG) | Still valid | If phi at all s >= t, then G(phi) at all s >= t |
| temp_a (phi -> G(P(phi))) | Still valid | If phi(t), for all s >= t, P(phi)(s) (witness r=t, t <= s) |
| temp_a_dual (phi -> H(F(phi))) | Still valid | Symmetric |
| temp_l (always(phi) -> G(H(phi))) | Still valid | Stronger premise, weaker conclusion |
| Until/Since axioms | Still valid | U/S keep strict semantics |
| Modal axioms (MT, M4, MB, MK, M5) | Unchanged | Box is independent of temporal change |

### 2.3 Axioms That Could Become INVALID

**Confidence: MEDIUM**

I found no axiom that becomes INVALID under the mixed semantics. The key risk was with Until/Since interaction axioms, but since U/S keep strict semantics, their axioms remain valid. The `discreteness_forward` axiom `(F(top) AND phi AND H(phi)) -> F(H(phi))` remains valid because:
- F(top) is now trivially true (take s=t)
- phi AND H(phi) means phi at all s <= t
- F(H(phi)) needs H(phi) at some s >= t; take s = t, then H(phi)(t) means phi at all r <= t, which follows from the hypothesis

However, the premise `F(top)` becomes vacuous, simplifying the axiom to `(phi AND H(phi)) -> F(H(phi))`, which may change proof search behavior.

### 2.4 Proof Search and Automation Impact

**Confidence: MEDIUM**

Redundant axioms do not cause logical problems (adding valid formulas to a consistent system preserves consistency). However:
- Proof search tactics that enumerate axioms will have more instances to try
- Seriality instantiations become trivially applicable, potentially cluttering search
- The `always` redundancy means proofs using `always` may have unnecessarily complex intermediate goals

This is a minor inconvenience, not a correctness risk.

---

## 3. Implementation/Migration Risks

### 3.1 Sorry Count in Current Codebase

**Confidence: HIGH**

The grep analysis shows **349 occurrences of `sorry`** across 50 files. However, many are in documentation (markdown, tex, typst). The key sorry-bearing Lean files in the Algebraic/ directory:

| File | Sorry Count | Impact |
|------|-------------|--------|
| DeterministicChain.lean | 1 | Old code comment only |
| DeterministicFMCS.lean | 10 | Active sorries |
| DovetailedChain.lean | 9 | Active sorries |
| RestrictedTruthLemma.lean | 7 | Active sorries |
| FiniteDeferral.lean | 5 | Active sorries |
| UltrafilterChain.lean | 14 | **Primary target** (forward_F, backward_P) |

**DeterministicChain.lean is SORRY-FREE** for its core theorems (forward_G_int, backward_H_int). These are the chain coherence proofs. They use `t < s` in their statements, which would change to `t <= s`.

### 3.2 DeterministicChain.lean forward_G Change Analysis

**Confidence: HIGH**

The `forward_G_nat` theorem (line 435) states:
```
G(phi) in chain(n), n < m -> phi in chain(m)
```

Under mixed semantics, the FMCS forward_G field changes from `t < t'` to `t <= t'`:
```
forward_G : forall t t' phi, t <= t' -> G(phi) in mcs(t) -> phi in mcs(t')
```

The `n < m` hypothesis in `forward_G_nat` would need to become `n <= m`. The existing proof works by:
1. G(phi) persists forward via temp_4 + G_implies_X
2. At each step, G(phi) in chain(k) -> G(phi) in chain(k+1)
3. At the final step, G(phi) -> X(phi) gives phi in chain(m)

**For the `n = m` case** (new under <=): G(phi) in chain(n) implies phi in chain(n) directly via the T-axiom. This is a **simpler** proof, not a harder one. The existing chain-stepping machinery is not needed.

**Net impact**: The proof GENERALIZES cleanly. The existing sorry-free forward_G_nat proof works for `n < m`, and the `n = m` case adds trivially via T-axiom. **Low risk.**

### 3.3 CanonicalIrreflexivity.lean Impact

**Confidence: HIGH**

This module (CanonicalIrreflexivity.lean) provides the infrastructure for proving `NOT ExistsTask W M` (i.e., W != M in the canonical frame). Its core argument:
1. Find phi with G(phi) in W but phi NOT in M
2. Apply `strict_of_formula_in_g_content_not_in_source`

Under mixed semantics, `G(phi) in M -> phi in M` (T-axiom). So finding `G(phi) in W` with `phi NOT in M` requires `W != M` in a different way -- **but this module is about W != M, so it is the infrastructure for proving irreflexivity of the accessibility relation, NOT reflexivity**.

**Key question**: Is `ExistsTask M M` now VALID under mixed semantics?

Under mixed semantics, g_content(M) = {phi | G(phi) in M} is a SUBSET of M (by T-axiom: G(phi) -> phi). So `g_content(M) ⊆ M`, which means `ExistsTask M M` DOES hold. The canonical accessibility relation becomes reflexive.

**Impact**: The entire CanonicalIrreflexivity module becomes **obsolete** for its original purpose. Its infrastructure for proving `NOT ExistsTask W M` is still useful for proving strict inequality where needed, but the per-construction strictness pattern is no longer the primary use case.

### 3.4 The `always` Operator Definition

**Confidence: HIGH**

The definition `always(phi) = H(phi) AND phi AND G(phi)` (Formula.lean line 326) does NOT need to change syntactically. The redundancy of the middle conjunct is harmless -- it just means the definition is unnecessarily verbose. Changing it would require updating every reference to `always`, which is high churn for no functional benefit.

**Recommendation**: Leave the definition unchanged; add a comment noting the redundancy under reflexive semantics.

### 3.5 Truth.lean Lemma Breakage

**Confidence: HIGH**

Truth.lean contains these key lemmas that need updating:

| Lemma | Current | After Change | Effort |
|-------|---------|-------------|--------|
| `past_iff` (line 220) | `s < t` | `s <= t` | Trivial (change `<` to `<=`) |
| `future_iff` (line 232) | `t < s` | `t <= s` | Trivial |
| `time_shift_preserves_truth` (line 371) | Uses `<` in all_past/all_future cases | Uses `<=` | **Proof still works** -- the time-shift argument is order-agnostic |
| All `truth_double_shift_cancel` inductive cases | Pattern on `<` | Pattern on `<=` | **Proof still works** -- same reasoning with `<=` |

The truth lemmas in Truth.lean are **mechanically updatable**. Change `<` to `<=` in `truth_at` definition, then fix the 2-3 places where the ordering is explicitly mentioned. The structural induction proofs (time_shift_preserves_truth, truth_double_shift_cancel) go through unchanged because they pattern-match on formula structure, not on the ordering relation.

### 3.6 Soundness.lean Proof Changes

**Confidence: HIGH**

The 20 individual axiom validity lemmas need review:

| Soundness Lemma | Impact | Effort |
|-----------------|--------|--------|
| `temp_4_valid` | Proof simplifies (uses `<=` transitivity) | Trivial |
| `temp_a_valid` | Proof simplifies (witness r=t for P(phi) at s >= t) | Trivial |
| `temp_a_dual_valid` | Symmetric | Trivial |
| `temp_l_valid` | Proof simplifies (always has redundant middle) | Minor |
| `density_valid` | Proof trivializes (no DenselyOrdered needed) | Trivial |
| `seriality_future_valid` | Proof trivializes (no NoMaxOrder needed) | Trivial |
| `seriality_past_valid` | Proof trivializes | Trivial |
| `discreteness_forward_valid` | F(top) premise trivializes | Minor |
| `disc_next_valid` | Unchanged (uses Order.succ) | None |
| `disc_prev_valid` | Unchanged (uses Order.pred) | None |
| Until/Since validity lemmas | Unchanged (U/S stay strict) | None |
| Modal lemmas | Unchanged | None |

**NEW proofs needed**:
- `temp_t_future_valid`: Prove `G(phi) -> phi` is valid under `s >= t` semantics. Trivial: take s = t.
- `temp_t_past_valid`: Prove `H(phi) -> phi` is valid. Same.

**Total effort**: Low. Most proofs simplify or remain unchanged.

---

## 4. Interactions with Until/Since

### 4.1 G(phi) <-> phi AND (phi U G(phi)) -- DOES NOT HOLD

**Confidence: HIGH**

Under mixed semantics with strict U:
- G(phi) at t means phi(s) for all s >= t
- phi U G(phi) at t means exists s > t with G(phi)(s) and phi(r) for all t < r < s

Forward direction: G(phi) -> phi (T-axiom). G(phi) -> phi U G(phi) requires a strict witness s > t. By seriality (which is now trivially valid in the axiom system but requires NoMaxOrder semantically), such s exists. But **semantically**, the truth of `phi U G(phi)` requires a STRICT witness s > t where G(phi)(s) holds. G(phi) at t gives phi at all s >= t, so G(phi) at any s >= t, so take any s > t.

Actually wait -- G(phi) at t implies G(phi) at s for all s >= t (by temp_4 applied reflexively). And phi at all r in (t, s) comes from G(phi) at t. So G(phi) -> phi AND (phi U G(phi)) IS valid as long as there exists s > t (NoMaxOrder).

Backward direction: phi AND (phi U G(phi)) -> G(phi)? phi(t) is given. phi U G(phi) gives witness s > t with G(phi)(s) (phi at all r >= s) and phi at all r in (t, s). Combined with phi(t): phi at all r in [t, s) and phi at all r >= s gives phi at all r >= t, i.e., G(phi). **Valid.**

So the equivalence `G(phi) <-> phi AND (phi U G(phi))` HOLDS (assuming NoMaxOrder). This is not a problem.

### 4.2 Until Induction Axiom Under Mixed Semantics

**Confidence: HIGH**

The Until Induction axiom:
```
G(psi -> chi) AND G(phi AND X(chi) -> chi) -> ((phi U psi) -> X(chi))
```

The premises are under G (now reflexive: holds at all s >= t). The Until operator is strict. The conclusion X(chi) is strict.

Under mixed semantics:
- G(psi -> chi) at t: for all s >= t, psi(s) -> chi(s). In particular at the witness s_0 > t from phi U psi.
- G(phi AND X(chi) -> chi) at t: for all s >= t, (phi(s) AND X(chi)(s)) -> chi(s). In particular at all intermediate points.

The induction proceeds: start from witness s_0 where psi holds (so chi holds by premise 1). Walk backward: at s_0 - 1, phi holds and X(chi)(s_0-1) = chi(s_0) holds, so chi(s_0-1) by premise 2. Continue to t+1 = X(chi) at t.

**This works unchanged.** The reflexive G just strengthens the premises (they also hold at t itself), which is harmless for the induction argument. **No issue.**

### 4.3 Until Unfold/Intro Under Mixed Semantics

**Confidence: HIGH**

Until Unfold: `(phi U psi) -> X(psi OR (phi AND (phi U psi)))`
Until Intro: `X(psi OR (phi AND (phi U psi))) -> (phi U psi)`

These use X (strict) and U (strict). G/H don't appear. **Completely unaffected by the semantics change.**

### 4.4 Connectedness Axioms

**Confidence: HIGH**

`until_connectedness`: `phi AND (chi U psi) -> chi U (psi AND (chi S phi))`
`since_connectedness`: `phi AND (chi S psi) -> chi S (psi AND (chi U phi))`

These only involve U and S (both strict). **Unaffected.**

---

## 5. Philosophical/Design Concerns

### 5.1 Is Mixed Semantics "Natural" for Task Semantics?

**Confidence: MEDIUM**

The project models business processes (tasks). The question: does "all future times include the present" make sense?

**Argument FOR**: When a manager says "the system will always satisfy invariant I", they typically mean "starting now and continuing into the future" -- the reflexive reading. The strict reading ("I holds at all times after now, but maybe not now") is counterintuitive for process specifications.

**Argument AGAINST**: The temporal distinction between "now" and "future" is important for process semantics. A task that has JUST completed should not be conflated with tasks that will complete in the future. The strict reading preserves this temporal precision.

**Assessment**: Both readings are defensible. The literature (Burgess 1984, GHR 1994, Goldblatt 1992) uses reflexive G/H as the default for tense logic. The mixed semantics (reflexive G/H, strict U/S) is the standard approach in the discrete temporal logic literature.

### 5.2 JPL Paper Alignment

**Confidence: MEDIUM**

The JPL paper (referenced in Truth.lean lines 22-51) defines temporal operators. The current code comments say:
> "Our implementation uses strict temporal quantification (a refinement of the paper's reflexive convention)"

This suggests the paper ITSELF uses reflexive semantics. Switching back to reflexive would actually **improve** alignment with the paper. This is a point in FAVOR of the change, not against it.

### 5.3 Loss of Expressive Power

**Confidence: MEDIUM**

Under mixed semantics:
- We lose the ability to express "phi at all strictly future times" using G alone (need `X(G(phi))` instead, which on Z means phi at all s >= t+1)
- We lose the ability to express "phi at some strictly future time" using F alone (need `X(F(phi))` or use `top U phi` instead)

The derived operators `weak_future` (phi AND G(phi)) and `weak_past` (phi AND H(phi)) in Formula.lean lines 337-352 become **identical in meaning** to G(phi) and H(phi) respectively under mixed semantics. Their definitions remain syntactically different but semantically equivalent.

---

## 6. Historical Risk

### 6.1 Task 81 Precedent

**Confidence: HIGH**

The project switched from reflexive to strict semantics in Task 81 (March 2026). The README in Boneyard/TAxiomDependentCode/ documents what broke:

**What broke**:
1. `targeted_forward_chain_forward_G`: G(phi) propagation used T-axiom at final step
2. `targeted_backward_chain_backward_H`: H(phi) propagation used T-axiom
3. `restricted_tc_family_to_fmcs.forward_G`: FMCS field requiring T-axiom for G-propagation across **independent Lindenbaum extensions**
4. `mcs_all_future_closure`: "G(psi) in closure MCS implies psi in closure MCS" -- **false under strict semantics**
5. `filtration_all_future_forward`: Filtration lemma depending on closure

**Key insight**: Items 1-2 broke because strict semantics removed the T-axiom. These will be FIXED by restoring the T-axiom. Item 3 broke because of the "independent extension problem" (G-formulas don't propagate across independent Lindenbaum extensions). This is addressed by the hybrid construction (deterministic chain + Lindenbaum detours).

Items 4-5 are in the FMP (Finite Model Property) path, which is Task 82 (out of scope).

### 6.2 Will the Same Problems Recur?

**Confidence: MEDIUM**

The critical question is whether the "independent extension problem" (item 3 above) recurs. The plan v26 proposes a hybrid construction:
- Deterministic chain (x_content stepping) handles G-propagation -- this did NOT exist during the original reflexive era
- Lindenbaum detours handle F-witness resolution -- T-axiom ensures seed consistency

The infrastructure evolution means the project is NOT returning to the pre-Task 81 state. The deterministic chain construction in DeterministicChain.lean is **sorry-free** and provides G/H propagation that was previously handled (and broken) by independent Lindenbaum extensions.

**Risk assessment**: The independent extension problem is unlikely to recur (20% likelihood) because the deterministic chain backbone eliminates the need for inter-extension G-propagation. The Lindenbaum extensions are only used for F-witness resolution, where the seed consistency argument (guaranteed by T-axiom) ensures the extension contains the needed witness.

---

## 7. Summary of All Disadvantages

### Critical (must address before migration)

| # | Issue | Confidence |
|---|-------|------------|
| C1 | FMCS forward_G/backward_H field signatures change from `<` to `<=`, requiring proof updates in DeterministicFMCS and all FMCS consumers | HIGH |
| C2 | 14 sorries in UltrafilterChain.lean (primary target) need the hybrid construction, not just the semantics switch | HIGH |

### Major (significant effort or design impact)

| # | Issue | Confidence |
|---|-------|------------|
| M1 | F(phi) and P(phi) now include present -- ALL derived theorems involving F/P need semantic review | HIGH |
| M2 | Density axiom loses frame correspondence (GG->G trivial on all frames) | HIGH |
| M3 | Seriality axioms lose frame correspondence (G->F trivial on all frames) | HIGH |
| M4 | CanonicalIrreflexivity.lean module becomes largely obsolete | HIGH |
| M5 | 30+ files with comments referencing "strict semantics" need documentation updates | MEDIUM |

### Minor (low effort or easily handled)

| # | Issue | Confidence |
|---|-------|------------|
| m1 | `always` middle conjunct becomes redundant (cosmetic) | HIGH |
| m2 | `weak_future`/`weak_past` become semantically identical to G/H (cosmetic) | HIGH |
| m3 | Soundness proofs trivialize for density/seriality (less work, actually) | HIGH |
| m4 | Proof search may have more trivially-applicable axiom instances | LOW |
| m5 | Loss of ability to express "strictly future" with G alone (use X(G) instead) | MEDIUM |

### Risks (uncertain outcomes)

| # | Risk | Likelihood | Impact | Confidence |
|---|------|------------|--------|------------|
| R1 | Independent extension problem resurfaces in hybrid construction | 20% | HIGH | MEDIUM |
| R2 | Until persistence breaks through Lindenbaum detours | 30% | HIGH | MEDIUM |
| R3 | Unexpected interaction between reflexive G and strict U in derived theorems | 15% | MEDIUM | MEDIUM |
| R4 | FMP path (Task 82) becomes harder under mixed semantics | 40% | LOW (out of scope) | LOW |

---

## 8. Recommendation

The mixed semantics approach is **viable but not free**. The key advantages (T-axiom enables seed consistency, aligns with literature, fixes the completeness sorries) outweigh the disadvantages (axiom redundancies, documentation churn, frame correspondence loss), **provided the Phase 1 prototype validates the seed consistency argument in Lean**.

The most actionable mitigation: validate Phase 1 (seed consistency lemma) before committing to the full migration. If it compiles sorry-free, proceed. If not, the disadvantages listed here become moot because the approach fails at a more fundamental level.
