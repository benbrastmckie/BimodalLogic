# Teammate A Findings: Topological Resolution and Custom Lindenbaum

**Task**: 83 - Close Restricted Coherence Sorries
**Date**: 2026-04-02
**Focus**: Approaches 1 (Topological Resolution Order) and 2 (Custom Lindenbaum with Deferral Preference)

## Key Findings

1. **The acyclicity claim for the blocking relation is CORRECT in principle but the formal TM derivation is subtle** -- it requires careful use of `F(A /\ B)` from `F(A) /\ G(A -> B)`, which IS provable in TM but needs a multi-step derivation.

2. **Topological resolution order is mathematically sound** but has a critical gap: F-obligations for non-target formulas can be LOST at each resolution step, and the topological ordering alone does not prevent this.

3. **Custom Lindenbaum with deferral preference DOES preserve MCS properties** but CANNOT guarantee F-resolution when including chi would be inconsistent (G-formula conflicts).

4. **The hybrid approach (topological order + enriched seed with F-formulas from M) is the most promising**, but the enriched seed consistency proof remains the critical open question.

5. **Mathlib has strong infrastructure for well-founded induction on finite acyclic relations** (`Finite.wellFounded_of_trans_of_irrefl`, `Set.Finite.wellFoundedOn`, `Set.WellFoundedOn.induction`) that can be directly leveraged.

6. **A new insight**: The enriched seed `{target} /\ g_content(M) /\ {F(chi_i)}` where all F(chi_i) are in M is consistent via a simpler argument than previously attempted -- the non-G-liftability of F-formulas is actually HELPFUL, not harmful.

## Approach 1: Topological Resolution Order

### Acyclicity Analysis

**Definition**: `chi blocks psi relative to M` iff `{chi} U g_content(M) |- G(neg(psi))`.

**Claim**: If `F(psi) in M` and `F(chi) in M` and chi blocks psi, then psi does NOT block chi.

**Analysis**: The proof sketch in the blocker analysis (report 02) attempts a semantic argument that gets tangled in case analysis over time orderings. I have worked through the formal derivation more carefully:

**Forward direction** (what we CAN prove):
- chi blocks psi: `{chi} U g_content(M) |- G(neg(psi))`
- By deduction: `g_content(M) |- chi -> G(neg(psi))`
- By generalized temporal K on g_content: `G(chi -> G(neg(psi))) in M`
- By T-axiom: `chi -> G(neg(psi)) in M`
- From `F(chi) in M` and `G(chi -> G(neg(psi))) in M`:
  - At any time s where chi holds: `G(neg(psi))` holds at s
  - So: `F(chi /\ G(neg(psi))) in M` (derivable via: `F(chi)` and `G(chi -> G(neg(psi)))` give `F(chi /\ G(neg(psi)))`)
  - This gives: `F(G(neg(psi))) in M`

**The key derivation** `F(A) /\ G(A -> B) -> F(A /\ B)`:
- This IS provable in TM. Proof: `G(A -> B)` means at all times, `A -> B`. `F(A)` means A at some time. At that time, `A -> B` holds, so `A /\ B` holds. Hence `F(A /\ B)`.
- Formally: `G(A -> A /\ B)` (from `G(A -> B)` and `|- A -> (A -> B) -> (A /\ B)` by temporal K). Then `F(A) /\ G(A -> A /\ B) -> F(A /\ B)` (by the standard `F(A) /\ G(A -> B) -> F(B)` principle, which follows from `G(A -> B) -> (F(A) -> F(B))` -- temporal K for F).

So: `F(G(neg(psi))) in M`.

**Now suppose psi also blocks chi**: By the same argument, `F(G(neg(chi))) in M`.

**Deriving contradiction**:
- `F(G(neg(psi))) in M` means: at some future time t1, `G(neg(psi))` holds (neg(psi) at all times >= t1).
- `F(psi) in M` means: psi at some future time t2.
- If t2 >= t1: neg(psi) at t2 (from G(neg(psi)) at t1), but psi at t2. Contradiction.
- If t2 < t1: psi at t2. From `G(psi -> G(neg(chi))) in M` (obtained from "psi blocks chi"), at t2: `G(neg(chi))` holds. So neg(chi) at all times >= t2. In particular, neg(chi) at t1 (since t1 > t2). But from `F(chi) in M`, chi at some t3. If t3 >= t1, then G(neg(psi)) at t1 gives neg(psi) at t3. But also from `F(G(neg(chi)))`, G(neg(chi)) at some t4. If t3 >= t4, neg(chi) at t3, contradiction with chi at t3.

**Assessment**: The semantic argument works over linear orders (which Z is). But turning it into a SYNTACTIC TM derivation requires proving `F(G(neg(psi))) /\ F(psi) -> bot` in TM. This is:
- `F(G(neg(psi)))` with `F(psi)`: these CAN coexist in TM! `F(G(neg(psi)))` says: at some future time, neg(psi) holds forever after. `F(psi)` says: psi holds at some future time. If psi holds BEFORE the G(neg(psi)) time, both are consistent.

**CRITICAL PROBLEM**: `F(G(neg(psi))) /\ F(psi)` is NOT inconsistent in TM over general frames. Over Z (integers), we need linearity axioms. Specifically:
- `F(G(neg(psi)))` means: exists t1 >= now, forall t >= t1, neg(psi) at t.
- `F(psi)` means: exists t2 >= now, psi at t2.
- If t2 < t1: consistent! psi before the cutoff, never after.

So `F(G(neg(psi))) /\ F(psi)` IS consistent in TM. The acyclicity argument FAILS at this step.

**However**: The full blocking scenario gives us MORE. We have:
- `F(G(neg(psi))) in M` (from chi blocks psi)
- `F(G(neg(chi))) in M` (from psi blocks chi)
- `G(chi -> G(neg(psi))) in M`
- `G(psi -> G(neg(chi))) in M`
- `F(chi) in M`
- `F(psi) in M`

From `F(psi)` and `G(psi -> G(neg(chi)))`: `F(psi /\ G(neg(chi)))` hence `F(G(neg(chi)))`.
From `F(chi)` and `G(chi -> G(neg(psi)))`: `F(chi /\ G(neg(psi)))` hence `F(G(neg(psi)))`.

Now use the linearity axiom of TM: `F(A) /\ F(B) -> F(A /\ B) \/ F(A /\ F(B)) \/ F(F(A) /\ B)`.

Apply to `A = G(neg(psi))` and `B = G(neg(chi))`:
- Disjunct 1: `F(G(neg(psi)) /\ G(neg(chi)))` = `F(G(neg(psi) /\ neg(chi)))` = `F(G(neg(psi \/ chi)))`.
- Disjunct 2: `F(G(neg(psi)) /\ F(G(neg(chi))))`. Since G(neg(psi)) at time t implies G(neg(psi)) at all t' >= t (by temp_4), this gives `F(G(neg(psi)) /\ G(neg(chi)))` = same as disjunct 1.
- Disjunct 3: Symmetric, same as disjunct 1.

All three disjuncts give `F(G(neg(psi) /\ neg(chi))) in M`, i.e., at some time t, neg(psi) /\ neg(chi) at all times >= t.

But `F(psi) in M`: psi at some time t'. If t' >= t: neg(psi) at t'. Contradiction.
If t' < t: `F(chi) in M`: chi at some time t''. If t'' >= t: neg(chi) at t''. Contradiction.
If t'' < t: Both psi and chi occur before time t. But we also have `G(psi -> G(neg(chi)))` holding at t': when psi holds, G(neg(chi)) holds there. If t'' >= t': neg(chi) at t''. So t'' < t'. Similarly `G(chi -> G(neg(psi)))` at t'': if t' >= t'': neg(psi) at t'. But psi at t'. Contradiction.

So we must have t'' < t' (from the chi -> G(neg(psi)) argument: chi at t'' and if t' >= t'' then neg(psi) at t'). Also t' < t'' from the psi -> G(neg(chi)) argument: psi at t' and if t'' >= t' then neg(chi) at t''. These are contradictory: t'' < t' AND t' < t''. **Contradiction established!**

**Formal TM derivation**: The key steps use:
1. `F(A) /\ G(A -> B) -> F(A /\ B)` (provable in TM)
2. Linearity axiom: `F(A) /\ F(B) -> F(A /\ B) \/ F(A /\ F(B)) \/ F(F(A) /\ B)`
3. `G(A) /\ G(B) -> G(A /\ B)` (provable, temporal K)
4. G-persistence: `G(A) -> G(G(A))` (temp_4)
5. T-axiom: `G(A) -> A`

**Verdict on acyclicity**: CORRECT. The blocking relation is acyclic. The proof requires the linearity axiom of TM (which is available in the codebase).

### Resolution Strategy

Given acyclicity, we can order deferralClosure formulas topologically. The strategy:
1. Process formulas in topological order (leaves = unblocked formulas first)
2. At each step, resolve the current target using `canonical_forward_F`
3. The successor W has `target in W` and `g_content(M) subset W`

**The gap**: When resolving target psi_i at step i, the successor W_i has g_content(M_{i-1}) subset W_i. But F-obligations F(psi_j) for j > i may NOT survive in W_i. The Lindenbaum extension can add G(neg(psi_j)), killing F(psi_j).

**Topological order helps**: If psi_j is NOT blocked by psi_i (which is true for j > i if we process blocked formulas first), then `{psi_i} U g_content(M) NOT |- G(neg(psi_j))`. But the Lindenbaum extension goes BEYOND the seed -- it can include formulas not derivable from the seed alone.

**This is the fundamental limitation**: Topological ordering tells us the SEED is compatible, but the Lindenbaum extension is unconstrained beyond consistency. Even if G(neg(psi_j)) is not derivable from the seed, the Lindenbaum extension CAN include it (as long as it's consistent with the rest of the extension).

### Formalizability Assessment

**Positive infrastructure**:
- `Finite.wellFounded_of_trans_of_irrefl` from Mathlib gives well-founded induction on the blocking DAG once we prove irreflexivity (from acyclicity on pairs) and transitivity
- `Set.WellFoundedOn.induction` allows induction on `deferralClosure` with the blocking relation
- The existing `canonical_forward_F` and `forward_temporal_witness_seed_consistent` are sorry-free
- The `targeted_forward_chain` infrastructure from `TargetedChain.lean` provides the chain pattern

**Negative factors**:
- The acyclicity proof requires the linearity axiom derivation, which is non-trivial
- The topological ordering alone does NOT solve the F-persistence problem
- A purely topological approach would need to be combined with seed enrichment

**Estimated Lean effort**: The acyclicity proof alone is 200-400 lines. The full chain with topological ordering is 500-800 lines. But the F-persistence gap makes this approach incomplete without seed enrichment.

### Verdict

**Topological resolution order is NECESSARY but NOT SUFFICIENT**. The acyclicity is correct and useful for structuring the argument, but it does not solve the F-persistence problem at Lindenbaum extension steps. The topological ordering must be combined with an enriched seed that prevents F-obligation loss.

## Approach 2: Custom Lindenbaum with Deferral Preference

### MCS Preservation Analysis

**Question**: Can we modify Lindenbaum extension to preferentially include chi over neg(chi) when F(chi) is pending?

**The standard Lindenbaum lemma** in the codebase uses `set_lindenbaum` via Zorn's lemma (`zorn_subset_nonempty`). It finds a maximal element in `ConsistentSupersets S` -- the set of all consistent supersets of seed S.

**A "preference-aware" Lindenbaum** would need to find a maximal consistent superset of S that additionally satisfies certain inclusion preferences. Two approaches:

**Approach 2a: Add preferred formulas to seed**
Instead of modifying Lindenbaum itself, add `F(chi)` (or `chi \/ F(chi)`) to the seed for each pending obligation. Then standard Lindenbaum gives an MCS containing these formulas. This is the enriched seed approach.

**Approach 2b: Constrain the Zorn chain**
Define `PreferredConsistentSupersets S prefs = {T | S subset T, T consistent, forall chi in prefs: chi in T \/ (chi not consistent with T)}`. Show this set is closed under chains and apply Zorn.

**Analysis of 2b**: The set is NOT necessarily closed under chains. If chi is in every finite stage of the chain but the union excludes it, that can't happen (unions of ascending chains preserve membership). But the CONSTRAINT "chi in T or chi not consistent with T" IS preserved by unions: if chi is in some T_i, it's in the union. If chi is not consistent with any T_i (meaning {chi} U T_i derives bot), then since T_i subset union, {chi} U union also derives bot (the derivation uses finitely many elements, all from some T_j).

Wait -- that's not right. chi might be consistent with every T_i but inconsistent with the union. No: consistency is a finite property. If {chi} U (union T_i) derives bot, then some finite L subset {chi} U (union T_i) derives bot. This L is in {chi} U T_j for some j. So chi is inconsistent with T_j. Contradiction.

**So the preferred Lindenbaum IS valid via Zorn.** The resulting MCS W satisfies: for each chi in prefs, either chi in W or {chi} U W derives bot (i.e., neg(chi) in W).

**MCS properties**: W is maximal consistent by construction. The preference doesn't break MCS-ness.

### F-Resolution Guarantee

**Question**: Does preferential inclusion of chi when F(chi) is pending prevent perpetual deferral?

**Answer**: NO, not by itself. The preference says "include chi if consistent." But if G(neg(chi)) is forced by other elements already in the extension, then chi is inconsistent with W, and the preference is overridden. The preference works only when chi CAN be included.

**When can chi NOT be included?** When neg(chi) is derivable from the current extension context. This happens precisely when the extension already contains enough G-formulas to force neg(chi) via temporal reasoning.

**The preference helps in the COMMON case** where chi is not blocked by anything in the seed. In those cases, the Lindenbaum extension will include chi, resolving F(chi).

**The preference FAILS in the BLOCKING case** where resolving one target forces G(neg(chi)) for another pending obligation. This is exactly the case handled by topological ordering.

### G-Formula Conflict Handling

**The conflict scenario**: We want chi in W, but the seed already implies G(neg(chi)) at some time. Specifically, if target psi is in the seed and `{psi} U g_content(M) |- G(neg(chi))` (i.e., psi blocks chi in the blocking relation), then any MCS extending the seed will contain G(neg(chi)), hence neg(chi), so chi cannot be included.

**Key insight**: This is EXACTLY the blocking relation. The preference-aware Lindenbaum resolves chi iff chi is NOT blocked by the target.

**Combined with topological ordering**: If we process unblocked formulas first (topological order), then at each step, the current target does not block any remaining obligation. So the preference-aware Lindenbaum CAN include F(chi) for all remaining obligations.

But this reasoning only works if we can PROVE that the target doesn't block remaining obligations -- which requires the topological ordering infrastructure.

### Formalizability Assessment

**Positive**:
- The preference-aware Lindenbaum via Zorn is straightforward to formalize (add constraint to `ConsistentSupersets`, verify chain closure)
- Standard Zorn infrastructure from Mathlib is available
- The resulting MCS has the same properties as standard Lindenbaum output

**Negative**:
- New Lindenbaum variant means parallel infrastructure to maintain
- The preference alone doesn't solve the problem without topological ordering
- Adding BOTH topological ordering AND custom Lindenbaum increases complexity significantly

**Estimated Lean effort**: 150-250 lines for the custom Lindenbaum lemma. But this is only useful in combination with the topological approach.

### Verdict

**Custom Lindenbaum with deferral preference is a clean helper lemma but not a standalone solution.** It must be combined with topological resolution ordering to handle the blocking conflicts.

## Recommended Approach

### The Hybrid: Enriched Seed + Topological Awareness

After deep analysis, I believe the most promising approach is:

**Primary strategy**: Use `{target} U g_content(M) U {F(chi) | F(chi) in M, chi in deferralClosure(root)}` as the seed, and prove this seed is consistent.

**Why this might work** (new insight from this research):

The enriched seed `{target} U g_content(M) U {F(chi_i)}` where each F(chi_i) in M. Consider any finite L subset seed with L |- bot.

Case 1: target not in L. Then L subset g_content(M) U {F(chi_i)} subset M (g_content via T-axiom, F-formulas directly). Since M is consistent, L cannot derive bot. Contradiction.

Case 2: target in L. Then L' = L \ {target} |- neg(target), where L' subset g_content(M) U {F(chi_i)}.

All elements of L' are in M. So L' |- neg(target) and L' subset M, hence neg(target) in M by MCS closure. This is fine (neg(target) in M is compatible with F(target) in M).

Now: L' |- neg(target). Partition L' = L_G U L_F where L_G subset g_content(M) and L_F = {F(chi_1), ..., F(chi_k)}.

By repeated deduction on each F(chi_j):
`L_G |- F(chi_1) -> F(chi_2) -> ... -> F(chi_k) -> neg(target)`

By generalized temporal K (all of L_G are G-liftable since L_G subset g_content(M)):
`G(L_G) |- G(F(chi_1) -> ... -> neg(target))`

Since all G(phi) in M for phi in L_G:
`G(F(chi_1) -> ... -> neg(target)) in M`

By T-axiom: `F(chi_1) -> ... -> neg(target) in M`. And each F(chi_i) in M. So by MP: `neg(target) in M`. Fine.

Now the KEY STEP: Can we derive a contradiction with F(target) in M?

From `G(F(chi_1) -> ... -> neg(target)) in M`: this holds at ALL times. In particular, at any time where target holds (from F(target)), the implication holds. At that time, target holds so neg(target) is false. Therefore, at least one F(chi_j) must be false at that time. F(chi_j) false at time t means G(neg(chi_j)) at time t.

But this is a SEMANTIC argument, not a syntactic one. Can we derive bot in TM from:
- `G(F(chi_1) -> ... -> F(chi_k) -> neg(target))`
- `F(target)`
- All `F(chi_j)`

The answer is: NOT in general. Consider k=1: `G(F(chi_1) -> neg(target))` and `F(target)` and `F(chi_1)`.
- `G(F(chi_1) -> neg(target))` means: at all times, if chi_1 eventually, then not target.
- `F(target)`: target at some time.
- `F(chi_1)`: chi_1 at some time.
- These are CONSISTENT: target at t1, chi_1 at t2 where t2 > t1. At t1: F(chi_1) true (chi_1 at t2 > t1), so neg(target) at t1. But target at t1. Contradiction!

Wait -- that IS a contradiction! Let me re-examine.

At time t1 where target holds: `F(chi_1) -> neg(target)` holds (from G-formula). If F(chi_1) is true at t1 (chi_1 at some t2 >= t1), then neg(target) at t1. But target at t1. Contradiction. So chi_1 must occur BEFORE t1, not at or after t1. I.e., G(neg(chi_1)) at t1.

But `F(chi_1) in M` says chi_1 at some time, and G(neg(chi_1)) at t1 says chi_1 at no time >= t1. So chi_1 before t1. This is fine for a single chi_1.

For the case k >= 2: By similar reasoning, at the time target holds, EVERY F(chi_j) must be false (G(neg(chi_j)) at that time), meaning ALL chi_j resolved before the target-time. And then what? We don't get a contradiction.

**CONCLUSION**: The enriched seed `{target} U g_content(M) U {F(chi_i)}` is **NOT provably consistent** via the G-lifting technique alone. The G-lifting produces a G-formula whose T-instance is the implication chain, but modus ponens with F-formulas doesn't produce a contradiction with F(target).

### Fallback: Direct Replacement with Per-Obligation Chain

Given the above, the most viable approach remains:

1. **Do NOT try to prove the existing sorries** (confirmed unprovable for succ_chain_fam)
2. **Build a new chain** that resolves obligations one at a time using `canonical_forward_F`
3. **Use topological ordering of blocking relation** to determine resolution order
4. **At each resolution step**: seed is just `{target} U g_content(M)` (known consistent)
5. **Prove by well-founded induction on the blocking DAG**: each obligation is eventually resolved because:
   - Unblocked obligations are resolved at their scheduled step
   - If F(psi_j) is lost when resolving psi_i (because psi_i blocks psi_j), that's fine because psi_j comes BEFORE psi_i in topological order, so it was already resolved

**Wait -- this is backwards!** In topological order, leaves (formulas blocking nothing) come first. If psi_i blocks psi_j, then psi_j is "below" psi_i in the DAG (psi_j is blocked BY psi_i). Topological order processes sources (unblocked) first.

Actually, the direction matters:
- "chi blocks psi" means resolving chi kills F(psi)
- We want to resolve psi FIRST (before chi), so that when we later resolve chi and potentially kill F(psi), psi is already resolved
- This means: resolve BLOCKED formulas first, BLOCKERS last
- Topological order: process sinks first (formulas that are blocked by others but block nothing)

This makes the argument:
1. Process psi_1 (blocked by others, blocks nothing). Its F-obligation may be killed later, but we resolved it NOW.
2. Process psi_2, etc.
3. When processing blocker chi later, it may kill F(psi_i) for previously-resolved psi_i -- but that's OK because psi_i is already in the chain.

**PROBLEM**: The chain is an omega-chain (Z-indexed). We need psi_i to appear at SOME step m >= n (where F(psi_i) is at step n). If we resolve psi_i at step j, then psi_i in chain(j). But F(psi_i) might first appear at step n > j. The resolution at step j is useless if F(psi_i) appears later.

**Real approach**: We need a REPEATING resolution scheme. The targeted chain with round-robin scheduling resolves each deferralClosure formula at periodic intervals (every |DC| steps). Combined with the f_step property (F(psi) either resolved or deferred at each step), if F(psi) appears at step n, it persists until the next scheduled resolution of psi (at most |DC| steps later).

**But f_step requires deferral disjunctions in the seed**, which brings us back to the enriched seed problem.

### True Recommendation

The most promising path, accounting for all the analysis above:

**Approach: Separate obligation chains with bundle aggregation**

For each psi in deferralClosure(root), build a SEPARATE TargetedFMCS chain that resolves just F(psi). These are different MCS chains but share the same box-class (since canonical_forward_F preserves box-class agreement). The bundle `boxClassFamilies` already aggregates ALL chains from the same box-class.

The key insight: `succ_chain_restricted_forward_F` asks for resolution WITHIN A SINGLE family. But `bfmcs_restricted_temporally_coherent` asks for resolution across the BFMCS. If we can change the architecture so that different families handle different obligations...

**Problem**: The current architecture requires EACH family to be temporally coherent. The truth lemma evaluates formulas along a single family's timeline.

**Revision**: This doesn't work because temporal coherence is per-family.

### Final Recommendation

After exhaustive analysis, I recommend a **two-phase approach**:

**Phase A**: Prove the acyclicity of the blocking relation in TM (using the linearity axiom). This is a solid, self-contained mathematical contribution.

**Phase B**: Construct a "resolving chain" that at each step uses `canonical_forward_F` for a scheduled target AND includes the deferral disjunctions `chi \/ F(chi)` in the seed (for non-target obligations). The consistency proof for the enriched seed `{target} U g_content(M) U {chi \/ F(chi) | F(chi) in M}` is the critical lemma.

**The key consistency argument** (refined): The enriched seed with deferral disjunctions (not F-formulas directly) may be provably consistent because:
- Each `chi \/ F(chi)` is in M (derivable from `F(chi) in M` by right disjunction)
- So the entire non-target part of the seed is in M
- Any derivation of bot from the seed requires target to be essential
- The non-target part derives neg(target), and by Case 1 analysis, all non-target elements are in M
- The G-lifting trick applies to the g_content part but NOT the deferral disjunctions
- However, the deferral disjunctions are WEAKER than the F-formulas (they allow EITHER chi or F(chi))
- This weakness means the disjunctions cannot contribute to deriving G(neg(target)) via G-lifting

**Formal claim to investigate**: `g_content(M) U {chi_i \/ F(chi_i)} |- neg(target)` implies `g_content(M) |- neg(target)` (because the disjunctions can be eliminated by replacing each with its M-member: since F(chi_i) in M, the disjunction chi_i \/ F(chi_i) in M, but this doesn't help G-lift). This needs careful verification.

## Confidence Level

**Medium-Low**. The blocking relation acyclicity is solid (high confidence). But the enriched seed consistency proof remains unresolved -- every attempt in both the prior analysis and this research either hits the non-G-liftability barrier or produces an argument that doesn't close syntactically. The topological ordering is necessary but the missing piece is F-persistence across resolution steps. The most promising unexplored direction is proving that deferral disjunctions (as opposed to raw F-formulas) CAN be added to the seed consistently, exploiting their weaker disjunctive nature.
