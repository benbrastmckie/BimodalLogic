# Teammate A Findings: Strategy C Deep Dive and Recommended Approaches

**Task**: 93 - Complete BXCanonical embedding
**Role**: Primary approach analysis
**Date**: 2026-04-14

## Key Findings

1. **Strategy C Attack Vector C (discharge_single_step at visit) is definitively dead.** The chain is already defined via `enriched_fwd_step`; we cannot substitute a different step function at a specific index. This is not a mathematical obstacle but an architectural one.

2. **Strategy C Attack Vector B (pigeonhole) fails.** The defect set is constant but the *resolved* set fluctuates. A formula can be resolved at step m (chi in chain(m+1)) and then become unresolved again at step m+2 (chi not in chain(m+2)) while F(chi) persists. Pigeonhole gives no contradiction because the same formula can be resolved and unresolved infinitely often.

3. **Strategy C Attack Vector A (visit-step analysis) reaches a genuine mathematical wall.** At psi's visit step, if psi is not directly resolved, some chi displaced it via BX11 Case 3. But chi's identity changes at each visit step (the BX11 ordering depends on the current MCS). No structural invariant constrains which chi displaces psi. The displacement is consistent with the axiom system.

4. **Approach A (target-prioritized fold) is the most promising path forward**, but it requires a NEW chain definition. Confidence: 55%.

5. **Approach C (different chain with discharge_single_step) has a fatal F-propagation gap** that circles back to the original problem.

6. **The "correct approach" comment (lines 1254-1268) was right about the GOAL but wrong about the METHOD.** The seed `{target} union g_content(M) union f_carry(M)` is provably inconsistent (Task #69). However, the goal of getting BOTH target resolution AND F-preservation in one step IS the right goal. Approach A achieves this differently.

## Analysis of Each Approach

### Approach A: Target-Prioritized Fold

**Exact proof obligation**: Construct a step function `prioritized_fwd_step` such that when `F(target) in M` and `target in sigma_list`:
- `target in M'` (guaranteed, not disjunctive)
- `g_content(M) subset M'`
- For all chi in sigma_list with F(chi) in M: `chi in M' OR F(chi) in M'`

**Analysis**: The idea is to keep target SEPARATE from the BX11 fold compound. Instead of folding target into the compound (where Case 3 can push it under F), we:
1. Fold only the OTHER F-defects into a compound beta using the existing `enriched_fwd_fold`
2. Get F(beta) in M where beta encodes all non-target F-obligations
3. Use BX11 on F(target) and F(beta) to get one of:
   - F(target AND beta) in M -- seed {target, beta} union g_content(M) works
   - F(target AND F(beta)) in M -- seed {target, F(beta)} union g_content(M) works
   - F(F(target) AND beta) in M -- THIS IS THE PROBLEM: target is under F

In Cases 1 and 2, target is a direct conjunct, so `enriched_resolving_seed_consistent` gives `{target, alpha} union g_content(M)` consistent, and Lindenbaum gives `target in M'`.

In Case 3, we have `F(F(target) AND beta) in M`. The seed would need to be `{F(target), beta} union g_content(M)`, giving `F(target) in M'` but NOT `target in M'`.

**Obstruction for Case 3**: This is the same Case 3 problem, but now it applies to the FINAL BX11 application (target vs compound) rather than within the fold. The question is: can we avoid Case 3 at this final step?

**Critical insight**: We CAN'T avoid Case 3 in general. But we can handle it by ITERATION. If Case 3 fires (F(target) in M' but not target), we still have F(target) in M' and can try again at the next step. The key question is whether Case 3 fires INFINITELY OFTEN.

**Sub-argument**: At each visit step for psi where Case 3 fires, we get F(F(psi) AND beta) in chain(step). This means some formula in beta has an "earlier" BX11 witness than psi. But beta changes at each step (different MCS, different F-defect set... wait, the F-defect set is CONSTANT). So the same set of formulas competes with psi every time. The BX11 ordering between psi and the compound beta can vary, but it reduces to a single binary choice: is psi earlier than the compound, or not?

**Deeper issue**: The compound beta aggregates ALL other F-defects. BX11 between F(psi) and F(beta) depends on the relationship between psi and the *aggregate* of all other obligations. This is a single BX11 application, not a fold. Case 3 firing means the aggregate's witness comes before psi's. This CAN happen at every step -- there's no pigeonhole or exhaustion argument because the aggregate is always "the rest."

**Verdict**: Approach A reduces the problem from "Case 3 in a multi-step fold" to "Case 3 in a single BX11 application." This is a simplification but does NOT eliminate the fundamental obstruction. The same non-transitivity and cycling issues apply. **Confidence: 35% (downgraded from initial 55%)**.

**What would make it work**: If we could prove that when Case 3 fires for the final target-vs-compound BX11, the compound beta's "direct witness" formula w satisfies w in M' AND F(w) is still preserved. Then w is genuinely resolved, reducing the defect count by 1. After |O| steps of Case 3, all other defects would be resolved, and psi would have no competitors. But this requires a MONOTONE DECREASE in the defect count, which we know fails (resolved formulas can become defects again).

---

### Approach B: Iterative Refinement (Sequence of Lindenbaum Extensions)

**Exact proof obligation**: Given F(psi) in M, construct a sequence of MCSs M_0 = M, M_1, M_2, ... such that:
- g_content(M_i) subset M_{i+1} for all i
- psi in M_k for some finite k
- The sequence is compatible with being embedded as a subsequence of the round-robin chain

**Analysis**:
Step 1: Start with seed {psi} union g_content(M). Lindenbaum gives M_1 with psi in M_1 and g_content(M) subset M_1. But Lindenbaum is non-constructive -- we cannot verify which other formulas are in M_1.

Step 2: The problem is that M_1 might have G(neg chi) for some chi with F(chi) in M. This permanently kills F(chi) in all future successors (by no_new_f_defects + g_content propagation). This is acceptable IF we only need forward_F for psi (which we do -- forward_F is per-formula). We got psi in M_1 and that suffices for the witness.

**Wait -- this IS the argument.** If we could use discharge_single_step as the chain's step function at psi's visit step, we'd immediately get psi in M'. The problem is that the chain ALREADY uses enriched_fwd_step and we can't change it.

**The real question**: Can we prove that `enriched_fwd_step M h_mcs psi sigma_list` already puts psi in M' when psi is the target and F(psi) in M?

**Answer**: No. enriched_fwd_step uses resolving_enriched_fwd_exists.choose, which picks an ARBITRARY MCS satisfying the existential. The existential guarantees `target in M' OR F(target) in M'`, and `.choose` might consistently pick the right disjunct (F(target) in M'). We cannot force the choice.

**Could we replace enriched_fwd_step with a step function that uses discharge_single_step when it's a visit step?** This would require redefining `rr_fwd_chain`, which triggers the "30+ theorem re-proof" problem (Report 17 Lesson 2).

**Variant**: What if we DON'T change the chain but prove that the EXISTING chain's `.choose` must eventually put psi directly in some M'? This would require showing that across infinitely many visit steps for psi, `.choose` cannot always pick the F(psi) disjunct. But `.choose` is a Hilbert epsilon -- it's deterministic given the same inputs. If the MCS at each visit step is different (which it generally is, since the chain evolves), the `.choose` result can differ. But there's no guarantee it ever picks the target-direct disjunct.

**Verdict**: Approach B doesn't work as stated. The iterative refinement idea is sound mathematically (Lindenbaum can always extend {psi} union g_content(M) consistently), but it requires changing the chain definition. **Confidence: 20%**.

---

### Approach C: Different Chain with discharge_single_step

**Exact proof obligation**: Define a new chain `alt_fwd_chain` where each step uses `fwd_succ` (which uses discharge_single_step in the resolving branch). Then prove forward_F for this chain.

**Analysis**:
At psi's visit step n: F(psi) in alt_chain(n), target = psi. `fwd_succ` resolving branch uses seed `{psi} union g_content(alt_chain(n))`. Lindenbaum gives M' with psi in M' and g_content(alt_chain(n)) subset M'. So psi in alt_chain(n+1). Forward_F for psi is immediate!

**But**: F-formulas of OTHER formulas are NOT preserved. At a resolving step for chi, the seed is `{chi} union g_content(M)`. F(alpha) for alpha != chi might not be in M'. Worse, G(neg alpha) might enter M', permanently killing F(alpha).

**The F-propagation gap**: For forward_F of psi, we need F(psi) in chain(n) to SURVIVE until psi's visit step. Between step n and psi's visit, there are up to |sigma_list| - 1 other resolving steps. At each, F(psi) might be destroyed.

How could F(psi) be destroyed? If at step k (resolving chi), the Lindenbaum extension of `{chi} union g_content(chain(k))` puts G(neg psi) in chain(k+1). Then F(psi) not in chain(k+1) and F(psi) never returns (by no_new_f_defects).

Can G(neg psi) enter chain(k+1)? We need to show `{chi} union g_content(chain(k))` is consistent with neg(G(neg psi)), i.e., consistent with F(psi). Is it? Not necessarily. g_content(chain(k)) contains G(phi) for all phi where G(phi) in chain(k). If G(neg psi) in chain(k), then G(G(neg psi)) in chain(k) (by temp_4), so G(neg psi) in g_content(chain(k)), and F(psi) is inconsistent with the seed. But if G(neg psi) NOT in chain(k), then neg(G(neg psi)) = F(psi) in chain(k) (by MCS completeness). So F(psi) in chain(k) means G(neg psi) not in chain(k), but Lindenbaum might ADD G(neg psi) freely (it's not in the seed, so there's no constraint preventing it).

**This is the fundamental gap**: Lindenbaum extends a consistent seed to an MCS, and the MCS can contain ANY formula consistent with the seed. Since the seed doesn't include F(psi), Lindenbaum might extend to an MCS containing G(neg psi), killing F(psi) permanently.

**To prevent this**: We'd need to include F(psi) in the seed at every step. But that's the f_carry approach, which Task #69 proved inconsistent.

**Verdict**: Approach C has the same fatal gap as the current chain but in a different location. Instead of "psi might never be directly resolved" (current chain), it becomes "F(psi) might be killed before psi's visit" (Approach C chain). **Confidence: 10%**.

---

### Strategy C Attack Vector A: Visit-Step Analysis

**Exact proof obligation**: Assume for contradiction that psi is never in chain(s) for any s > n. Show this leads to contradiction.

**Established facts under the contradiction assumption**:
- F(psi) in chain(m) for ALL m >= n (by F-obligation constancy + the assumption that psi never appears)
- At each visit step v_k = n + k*|sigma_list| + j (where j is psi's index), psi is the scheduled target
- F(psi) in chain(v_k), so the enriched fold fires with psi as target
- enriched_fwd_step_resolves_one gives some w in chain(v_k + 1) with F(w) in chain(v_k)
- Under our assumption, w != psi (since psi not in chain(v_k + 1))

**What we know about w**: w in sigma_list, F(w) in chain(v_k), w in chain(v_k + 1). The fold's direct witness slot went to w instead of psi. This means BX11 Case 3 fired at some point during the fold: some formula had an earlier BX11 witness than psi's accumulator.

**Can we derive a contradiction?**

Attempt 1: w is resolved at step v_k, but w might not stay resolved. At step v_k + 1, w in chain(v_k + 1), so F(w) in chain(v_k + 1) (by phi_in_mcs_imp_F_phi). The defect for w is "resolved" at v_k + 1 (w in chain AND F(w) in chain), but w might leave the chain at v_k + 2. So w cycles between resolved and unresolved. No monotone decrease.

Attempt 2: At EVERY visit step for psi, some w displaces psi. The displacing w can be different each time. Over infinitely many visits, infinitely many displacements occur. But there are only finitely many formulas in sigma_list. So some formula w_0 displaces psi infinitely often. Does this lead to a contradiction? w_0 is resolved infinitely often (it takes the direct slot infinitely often). Between resolutions, w_0 might become unresolved. This is consistent -- w_0 oscillates.

Attempt 3: Since psi is NEVER resolved but has F(psi) at every step, and at every visit some OTHER formula is resolved instead, we accumulate infinitely many "resolution events" for other formulas but ZERO for psi. Is the asymmetry contradictory? No -- the other formulas cycle (resolved then unresolved), while psi remains perpetually unresolved. This is semantically consistent: imagine a timeline where psi's witness is always "just beyond" the current step, while other formulas' witnesses are closer.

**Verdict**: No contradiction can be derived from the visit-step analysis. The scenario where psi is perpetually displaced is consistent with the BX axiom system. **Confidence of attack vector succeeding: 5%**.

---

### Strategy C Attack Vector B: Pigeonhole on sigma_list

**Exact proof obligation**: Use the finiteness of sigma_list and the constancy of the F-obligation set to derive a contradiction from psi being perpetually unresolved.

**The counting argument**:
- |O| = number of formulas with F-obligations (constant across all steps)
- At each resolving step (every step where the target has F-obligation), at least one formula is directly resolved
- Over N steps, at least N * (fraction of resolving steps) resolutions occur
- Only |O| distinct formulas can be resolved
- By pigeonhole, some formula is resolved at least N/(|O|) times (growing with N)

**Where this fails**: Being "resolved" at step m (w in chain(m)) does NOT prevent w from becoming unresolved at step m+1 (w not in chain(m+1)). The same formula can be resolved and unresolved alternately. The total count of resolutions is unbounded, but this is not contradictory -- it just means formulas cycle.

**Could we bound the CYCLING?** If each cycle (resolve then unresolve) consumed some finite resource, we could derive exhaustion. But no such resource exists: the MCS at each step is freshly constructed via Lindenbaum, and there's no monotonically decreasing quantity.

**Verdict**: Pigeonhole fails because resolution is not monotone. **Confidence: 5%**.

---

### Strategy C Attack Vector C: discharge_single_step at Visit

**Exact proof obligation**: At psi's visit step, use `discharge_single_step` to get M' with psi in M'.

**Fatal obstruction**: The chain is defined as `rr_fwd_chain` which uses `enriched_fwd_step` at every step. We cannot substitute a different step function at a specific index. The chain is already constructed; we must prove properties about the EXISTING chain.

This is not a mathematical obstacle but a definitional one. To use discharge_single_step, we'd need to REDEFINE the chain, triggering 30+ theorem re-proofs.

**Verdict**: Architecturally impossible without chain replacement. **Confidence: 0%**.

---

### The "Correct Approach" Comment (Lines 1254-1268)

**What it proposed**: Seed = {target} union g_content(M) union f_carry(M).

**Why Task #69 proved it wrong**: The seed is INCONSISTENT. Concrete counterexample: if `G(F(alpha) -> neg(psi)) in M`, `F(alpha) in M` (so `F(alpha) in f_carry(M)`), and `F(psi) in M` (so `psi` is the target), then the seed contains:
- psi (from {target})
- G(F(alpha) -> neg(psi)) stripped to F(alpha) -> neg(psi) (from g_content)
- F(alpha) (from f_carry)

From F(alpha) and F(alpha) -> neg(psi), we derive neg(psi). But psi is also in the seed. Contradiction.

**Is there a variant that works?** The comment's key insight was correct: we need a step that BOTH resolves the target AND preserves F-formulas. The obstacle is that g_content can contain formulas that, combined with f_carry, are inconsistent with the target.

**Variant 1**: Use a FILTERED f_carry: only include F(chi) where adding F(chi) doesn't create inconsistency. But consistency checking is not computable in the proof, and "consistent subsets of f_carry" is not a well-defined constructive notion in Lean.

**Variant 2**: Use the BX11 compound instead of raw f_carry. This is exactly what `enriched_fwd_step` does -- and it gives only a disjunctive guarantee. We've come full circle.

**Variant 3**: Include f_carry but EXCLUDE the problematic g_content formulas. The seed would be `{target} union g_content_safe(M) union f_carry(M)`, where g_content_safe excludes formulas that conflict with f_carry+target. But g_content_safe might not propagate correctly (g_content propagation requires ALL G-formulas).

**Verdict**: No viable variant of the f_carry seed approach exists. The inconsistency is fundamental, not accidental.

## Recommended Approach

**Primary recommendation**: Approach A (target-prioritized fold) with a MODIFIED chain definition, accepting the 30+ theorem re-proof cost.

**Confidence level**: 35%

**Rationale**: All approaches that work with the EXISTING chain are dead (Strategy C vectors A, B, C all fail). Approaches B and C have worse gaps than Approach A. Approach A at least simplifies the problem to a single BX11 binary choice (target vs compound) rather than a multi-step fold, even though it doesn't fully solve it.

**Alternative recommendation**: If Approach A's Case 3 obstruction proves fatal, the correct path may be to abandon the round-robin chain entirely and use a SEMANTIC construction. Specifically:
1. Build a quasimodel (already done in `Quasimodel/`)
2. Realize the quasimodel on integers (partially done in `Quasimodel/Realization.lean`)
3. Use the realization directly for the BFMCS, bypassing the defect-discharge chain

This "quasimodel bridge" approach was rejected as Approach #6 in the failed approaches catalog, but the specific objection ("sigma_le incompatible with g_content") may be addressable with the now-sorry-free Frame.lean infrastructure.

## Evidence/Examples

### Concrete scenario where psi is permanently displaced

Consider sigma_list = [psi, chi] with |O| = 2 (both have F-obligations).

At every visit step for psi:
- F(psi) in M, F(chi) in M
- BX11 gives F(psi AND chi), F(psi AND F(chi)), or F(F(psi) AND chi)
- If Case 3 consistently fires: F(F(psi) AND chi) in M at every visit
- The fold's direct witness is chi (from right conjunct of F(psi) AND chi)
- psi gets only F(psi) in M' (from left conjunct under F + FF_imp_F)
- psi is never directly in M'

At visit steps for chi:
- BX11 between chi and psi might give Case 1 or 2, resolving chi
- chi cycles: resolved at its visits, possibly unresolved at psi's visits
- psi is perpetually unresolved

This scenario is semantically consistent: on the integers, psi's witness is at time +infinity (never reached), while chi's witness oscillates between nearby finite times.

### Why the "correct approach" seed is inconsistent

Let M be an MCS with:
- F(psi) in M (making psi the target)
- F(alpha) in M (so F(alpha) in f_carry(M))
- G(neg psi OR neg(F(alpha))) in M (a G-formula, so neg psi OR neg(F(alpha)) in g_content(M))

Seed = {psi} union g_content(M) union f_carry(M) contains:
- psi
- neg psi OR neg(F(alpha))
- F(alpha)

From psi, derive neg(neg psi). From neg(neg psi) and (neg psi OR neg(F(alpha))), derive neg(F(alpha)) (disjunctive syllogism doesn't directly apply in this direction -- let me be more precise).

Actually, from psi and (neg psi OR neg(F(alpha))): if neg psi holds, contradiction with psi. So neg(F(alpha)) must hold. But F(alpha) is in the seed. Contradiction.

Is `G(neg psi OR neg(F(alpha))) in M` compatible with `F(psi) in M` and `F(alpha) in M`? Yes: G(A OR B) in M means A OR B holds at all future times. F(psi) in M means psi holds at SOME future time. These are compatible: at the time psi holds, neg(F(alpha)) must hold there (since neg psi doesn't hold there). At the time alpha holds (F(alpha) in M gives this), neg psi must hold there. Both constraints are satisfiable on a linear order with distinct witness times.

This confirms the seed is genuinely inconsistent -- the inconsistency is not an artifact.

## Precise Mathematical Obstructions

| Approach | Precise Obstruction |
|----------|-------------------|
| Strategy C, Vector A | BX11 ordering is step-dependent and admits permanent displacement. No structural invariant prevents the same formula from being displaced at every visit. Semantically consistent with BX axioms. |
| Strategy C, Vector B | Resolution is non-monotone. Resolved formulas can become unresolved. No well-founded measure decreases. |
| Strategy C, Vector C | Chain already defined; cannot substitute step function. Architectural, not mathematical. |
| Approach A | Final BX11 between target and compound can fire Case 3, giving F(target) in M' instead of target in M'. Same displacement problem in single-step form. |
| Approach B | Requires chain redefinition. The iterative Lindenbaum sequence is sound but not compatible with existing chain architecture. |
| Approach C | F-formulas not preserved across non-target resolving steps. Lindenbaum can add G(neg psi), killing F(psi) permanently. Same core gap as original problem. |
| f_carry seed | Provably inconsistent (Task #69). G-formulas in g_content can conflict with F-formulas in f_carry when combined with target. |

## Summary Assessment

The forward_F problem for the existing round-robin chain appears to be **genuinely unprovable**. The chain's use of `enriched_fwd_step` with non-deterministic Lindenbaum choice creates an existential that is too weak: it guarantees `target in M' OR F(target) in M'`, and no argument within the BX axiom system can force the first disjunct. All three Strategy C attack vectors and all three recommended approaches either fail outright or require chain redefinition.

The most viable path forward is **chain redefinition** using one of:
1. A target-prioritized step function (Approach A variant)
2. A quasimodel-based construction that bypasses defect-discharge entirely

Both require significant re-proof effort (~30 theorems, 200+ LOC) but may be the only paths to a correct formalization. The literature avoids this problem by working semantically on integer models, where the well-ordering of natural numbers provides the induction principle that BX11 cannot syntactically capture.
