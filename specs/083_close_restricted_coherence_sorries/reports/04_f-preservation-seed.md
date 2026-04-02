# Research Report: F-Preservation Seed Approach for forward_F

**Task**: 83 (Close Restricted Coherence Sorries)
**Session**: sess_1775170512_2ed80d
**Date**: 2026-04-02
**Focus**: Augmented targeted seed with F-formula preservation

## Executive Summary

The F-preservation seed approach -- augmenting the targeted successor seed with
`{F(a) | F(a) in M, a in DC, a != target}` -- is **viable but requires a
non-trivial multi-target consistency proof**. The individual consistency argument
generalizes naturally from `single_target_with_g_content_consistent`, but the
joint consistency of multiple F-formulas with g_content faces the same
counterexample from handoff 03 unless carefully restricted.

A cleaner approach exists: **use the full MCS targeted chain (TargetedChain.lean)
with a refined convergence argument**, avoiding DRM entirely. This is the
recommended path.

## Question 1: Augmented Seed Consistency

### The Proposed Seed

```
augmented_seed(M, target) = {target} ∪ g_content(M) ∪ {F(a) | F(a) ∈ M, a ∈ DC, a ≠ target}
```

### Analysis: Is This a Subset of M?

**No, not in general.** The elements of this seed are:
- `target`: has `F(target) ∈ M`, but `target` itself may not be in M
- `g_content(M)`: these are `{phi | G(phi) ∈ M}`, so phi may not be in M
  (though G(phi) is). For a full MCS, `G(phi) -> phi` by the T-axiom, so
  `g_content(M) ⊆ M`. But for DRM, this depends on phi being in deferralClosure.
- `F(a)` for various a: these ARE in M by construction

**For full MCS (SetMaximalConsistent)**:
- `g_content(M) ⊆ M` holds by T-axiom (G(phi) -> phi is a theorem)
- `F(a) ∈ M` by hypothesis
- Only `target` is potentially not in M

So the augmented seed = `{target} ∪ (stuff already in M)`. Since M is consistent
and `{target} ∪ g_content(M)` is consistent (proven by
`forward_temporal_witness_seed_consistent`), we need to check whether adding
`{F(a) | ...}` to this seed preserves consistency.

### Key Insight: F-formulas from M are harmless

For a full MCS M:
- `g_content(M) ⊆ M` by T-axiom
- `{F(a) | F(a) ∈ M} ⊆ M`
- So `g_content(M) ∪ {F(a) | F(a) ∈ M} ⊆ M`, which is consistent

The augmented seed is `{target} ∪ (subset of M)`. By the same G-wrapping
argument used in `single_target_with_g_content_consistent`:

Given `L ⊆ {target} ∪ g_content(M) ∪ F_set` with `L ⊢ bot`:
- Partition L into `L_target` (= {target} if present) and `L_rest`
- `L_rest ⊆ g_content(M) ∪ F_set ⊆ M` (by T-axiom and F-membership)

**Case 1**: target in L. By deduction, `L_rest ⊢ neg(target)`.
The G-wrapping argument needs `G(chi) ∈ M` for all chi in L_rest.
- For chi in g_content(M): `G(chi) ∈ M` by definition -- works.
- For chi = F(a) in F_set: we need `G(F(a)) ∈ M` -- THIS IS THE PROBLEM.

`G(F(a)) ∈ M` does NOT follow from `F(a) ∈ M`. In general,
`F(a) ∈ M` does not imply `G(F(a)) ∈ M` (this would mean "F(a) holds at all
future times", which is much stronger).

**Case 2**: target not in L. Then `L ⊆ M`, and `L ⊢ bot` contradicts M's consistency.

### Refined Analysis

The G-wrapping argument fails because F-formulas are not in g_content. However,
Case 2 saves us: if target is not in L, consistency follows from M's consistency.

For Case 1 where target is in L, we need a different argument. The elements of
L_rest that are F-formulas cannot be G-wrapped. But they are IN M.

**Alternative proof for Case 1**: Since `L_rest ⊆ M` and `L_rest ⊢ neg(target)`,
by MCS closure `neg(target) ∈ M`. But `F(target) ∈ M`, and
`F(target) = neg(G(neg(target)))`. We need G(neg(target)) to get a contradiction.
From `neg(target) ∈ M` alone, we cannot derive `G(neg(target)) ∈ M`.

**This means the augmented seed is NOT obviously consistent.** The proof breaks
down because we cannot G-wrap the F-formulas.

### But Wait: The Seed IS a Subset of M (for Full MCS)

For a **full** MCS M (not DRM):
- `{target} ∪ g_content(M) ∪ {F(a) | F(a) ∈ M}`: the non-target part is a
  subset of M (by T-axiom for g_content, and by hypothesis for F-formulas)
- If target is also in M, the entire seed is a subset of M -- trivially consistent
- If target is NOT in M but F(target) ∈ M: we are adding target to a subset of M

For DRM this fails because g_content(M) may not be a subset of M (the T-axiom
`G(phi) -> phi` only guarantees phi ∈ M when phi ∈ deferralClosure, and
g_content elements may fall outside DC).

**Critical distinction**: For the TargetedChain.lean approach which uses FULL
MCS (via `canonical_forward_F` and `forward_temporal_witness_seed_consistent`),
the g_content elements are guaranteed to be in M by the T-axiom. So:

```
augmented_seed \ {target} ⊆ M
```

And the consistency proof reduces to: `{target} ∪ (subset of M)` is consistent
when `F(target) ∈ M`. This is EXACTLY `forward_temporal_witness_seed_consistent`!

### Conclusion for Question 1

**For full MCS**: The augmented seed `{target} ∪ g_content(M) ∪ {F(a) | F(a) ∈ M}`
is consistent, because it equals `{target} ∪ S` where `S ⊆ M`, and this reduces
to `forward_temporal_witness_seed_consistent` (since `{target} ∪ g_content(M)` is
consistent and `S` is a larger set that is still a subset of `{target} ∪ M`).

Actually, we need to be more careful. `forward_temporal_witness_seed_consistent`
proves `{psi} ∪ g_content(M)` is consistent. Our seed is `{target} ∪ g_content(M) ∪ F_set`.
Since `F_set ⊆ M` and `g_content(M) ⊆ M` (by T-axiom), the seed is `{target} ∪ S`
where `S ⊆ M`. Any L ⊆ {target} ∪ S with L ⊢ bot:
- If target not in L: L ⊆ S ⊆ M, contradicts M's consistency
- If target in L: L_rest ⊆ M, so L_rest ⊢ neg(target) gives neg(target) ∈ M.
  But F(target) ∈ M and neg(target) ∈ M are compatible! (F(target) says target
  holds EVENTUALLY, neg(target) says target is false NOW.)

So the proof technique from `forward_temporal_witness_seed_consistent` does NOT
directly apply -- it used G-wrapping specifically. We need the same G-wrapping
approach, which requires all non-target elements to be in g_content(M).

**VERDICT**: The augmented seed is consistent IFF we can show
`{target} ∪ g_content(M) ∪ {F(a) | F(a) ∈ M}` is consistent. The F-formulas
prevent direct G-wrapping. However, there is a workaround:

Since `g_content(M) ∪ {F(a) | F(a) ∈ M} ⊆ M`, and M is consistent, any
`L ⊆ M` is consistent. The only issue is when target (possibly not in M) is
in L. In that case, `L \ {target} ⊆ M` and `L \ {target}, target ⊢ bot`,
so `L \ {target} ⊢ neg(target)`, so `neg(target) ∈ M` (by MCS closure).
But `F(target) = neg(G(neg(target))) ∈ M` and `neg(target) ∈ M` are NOT
contradictory -- they are both consistent in an MCS.

**The augmented seed is NOT provably consistent by the G-wrapping argument.**
The counterexample: M = {neg(p), F(p), F(q), ...}, target = p. Then
{p, F(q)} is a subset of the seed, and {p, F(q)} is indeed consistent.
But the point is we cannot derive a CONTRADICTION from the seed's inconsistency
assumption using G-wrapping when F-formulas are present.

Actually, let me reconsider. The original proof of
`forward_temporal_witness_seed_consistent` does prove `{target} ∪ g_content(M)`
is consistent. The augmented seed CONTAINS this as a subset, plus F-formulas
from M. Adding formulas from a consistent set to a consistent set may create
inconsistency.

**Example**: M = consistent MCS. `{p} ∪ g_content(M)` consistent.
`{p} ∪ g_content(M) ∪ {F(neg(p))}` -- is this consistent? F(neg(p)) says
neg(p) holds eventually. p says p holds now. These are compatible semantically.
But they might derive a contradiction syntactically... No, they cannot, because
there IS a model where p holds now and neg(p) holds later.

**Revised verdict**: The augmented seed should be consistent because it is
satisfiable in any model where M is realized at the current time and target
is realized at some future time. But proving this FORMALLY requires more than
G-wrapping.

**Proof approach**: Assume `{target} ∪ g_content(M) ∪ {F(a_1), ..., F(a_k)}` is
inconsistent. Then there exist L with `L ⊢ bot`. Since `{target} ∪ g_content(M)`
is consistent (proven), L must contain at least one F(a_i). Since
`g_content(M) ∪ {F(a_1), ..., F(a_k)} ⊆ M` and M is consistent, L must
contain target. So: `target, L_gc, F(a_i1), ..., F(a_ij) ⊢ bot` where
`L_gc ⊆ g_content(M)`. By deduction:
`L_gc, F(a_i1), ..., F(a_ij) ⊢ neg(target)`.
All elements of the LHS are in M. By MCS closure, `neg(target) ∈ M`.
Then by G-wrapping on just the g_content part:

Actually, we CANNOT G-wrap because the F(a_i) elements are not in g_content.

**This is the same blocker as the v3 plan.** Joint F-formula consistency with
a target cannot be proven by G-wrapping.

## Question 2: F-Preservation Across Steps (Moot)

Since Question 1 shows the augmented seed consistency proof is blocked,
Question 2 is partially moot. However, for completeness:

IF we could build a successor from the augmented seed, then:
- The seed contains F(a) for each a with F(a) ∈ M and a in DC
- The Lindenbaum extension would extend this to a full MCS W
- F(a) ∈ W by seed extension
- g_content(M) ⊆ W by seed extension
- target ∈ W by seed extension

So F-obligations WOULD persist. The convergence argument would work:
each step resolves one target, and F-obligations for non-targets persist.
After at most |DC| steps, all would be resolved.

## Question 3: Alternative Approaches

### Approach A: TargetedChain.lean with Convergence (RECOMMENDED)

The existing `TargetedFMCS` in `TargetedChain.lean` already has:
- Sorry-free forward_G, backward_H (FMCS structure)
- One-step resolution: if F(psi) ∈ chain(n) and psi is scheduled at step n,
  then psi ∈ chain(n+1)
- Round-robin scheduling over a target list

**The missing piece is proving forward_F.** The claim:

> If F(psi) ∈ chain(t) and psi ∈ targets, then there exists s > t with
> psi ∈ chain(s).

**Proof sketch**:
1. By round-robin, psi is scheduled at infinitely many steps n_0, n_1, n_2, ...
2. At each scheduled step n_i >= t:
   - If F(psi) ∈ chain(n_i), then psi ∈ chain(n_i + 1) -- DONE
   - If F(psi) ∉ chain(n_i), we need to show this case eventually fails

The difficulty: we need F(psi) to PERSIST until some n_i. But the targeted
chain only guarantees g_persistence, not F-persistence.

**Key question**: Does F(psi) ∈ chain(t) and g_persistence at each step imply
F(psi) ∈ chain(t+1)?

Answer: NO in general. The successor is a Lindenbaum extension of
`{schedule_target} ∪ g_content(chain(t))`. The extension is within all MCS,
so it may add neg(F(psi)) = G(neg(psi)). This is compatible with having
g_content(chain(t)) in the successor.

**But**: If G(neg(psi)) ∈ chain(t+1), then neg(psi) ∈ g_content(chain(t+1)).
By g_persistence: neg(psi) ∈ chain(t+2), chain(t+3), etc.
Also G(neg(psi)) ∈ chain(t+1) implies (by temp_4) G(G(neg(psi))) ∈ chain(t+1),
so G(neg(psi)) ∈ chain(t+2), chain(t+3), etc. This means neg(psi) is in all
future chain elements. So psi is in no future chain element. So F(psi) is
"wrongly lost".

**Can this actually happen?** We have F(psi) ∈ chain(t). Can chain(t+1) contain
G(neg(psi))? The successor seed is `{alpha} ∪ g_content(chain(t))` for some
target alpha. The Lindenbaum extension adds maximal consistent formulas. It
COULD add G(neg(psi)) if this is consistent with the seed.

Is `{alpha} ∪ g_content(chain(t)) ∪ {G(neg(psi))}` consistent? We have
`F(psi) ∈ chain(t)`, so `neg(G(neg(psi))) ∈ chain(t)`, so
`G(neg(psi)) ∉ chain(t)`. But g_content(chain(t)) doesn't include G(neg(psi))
-- it includes neg(psi) only if G(neg(psi)) ∈ chain(t), which is false.
So neg(psi) is NOT necessarily in g_content(chain(t)).

Can the Lindenbaum extension add G(neg(psi))? Only if it's consistent with the
seed. Since g_content doesn't force neg(psi), and the seed doesn't directly
exclude G(neg(psi))... yes, the Lindenbaum extension CAN add G(neg(psi)).

**This is the perpetual deferral problem.**

### Approach B: TargetedChain with F-Tracking Invariant

Instead of trying to preserve F-formulas in the seed, track them logically.

**Claim**: In the targeted chain, if F(psi) ∈ chain(0) and psi ∈ targets,
then F(psi) ∈ chain(n) for all n until psi is resolved.

This would need to be proven by an invariant on the chain. The invariant:
"Either psi has been resolved (psi ∈ chain(m) for some m <= n) or F(psi) ∈ chain(n)."

Proof of invariant at n+1:
- If psi was resolved at m <= n, done (first disjunct)
- If F(psi) ∈ chain(n) and schedule(n) = psi, then psi ∈ chain(n+1), done
- If F(psi) ∈ chain(n) and schedule(n) != psi, need F(psi) ∈ chain(n+1)

The third case is exactly what we cannot prove. The successor of chain(n)
targeting a different formula may "lose" F(psi).

### Approach C: Use Full MCS Semantics (Not Chain-Based)

**Fundamental insight**: The problem with ALL chain-based approaches is that
Lindenbaum extensions are non-constructive and can add G(neg(psi)), killing
F-obligations. This is an inherent limitation of the linear chain approach.

**Alternative**: Use the canonical frame approach from CanonicalFrame.lean
directly. In the canonical frame:
- Worlds = all MCS
- Future relation = ExistsTask (g_content subset)
- `canonical_forward_F` trivially gives F-witnesses (each F gets its own MCS)

The challenge: the canonical frame has TOO MANY worlds (all MCS, not a single
linear chain). For TM semantics, we need a single world history (linear
temporal ordering).

**Key mathematical question**: Can we extract a LINEAR sub-chain from the
canonical frame that satisfies all the temporal coherence properties?

This is the **path extraction problem**: given that each MCS has F-witnesses
in the canonical frame (non-linearly), extract a linear chain that realizes
all F-obligations.

### Approach D: Direct Semantic Argument (Henkin-Style)

Build the model directly without going through chains:
1. Start with MCS M_0 with F(psi) ∈ M_0
2. M_0 has a canonical F-witness W for psi (by canonical_forward_F)
3. W has g_content(M_0) ⊆ W (ExistsTask)
4. Define chain(0) = M_0, chain(1) = W for psi's resolution
5. For other F-obligations in M_0, chain(1) = W may have them
6. Continue building chain(2), chain(3), etc.

This is essentially the targeted chain but choosing the successor MORE carefully
-- not just any Lindenbaum extension, but specifically the canonical_forward_F
witness.

**But**: canonical_forward_F uses `forward_temporal_witness_seed_consistent` to get
`{psi} ∪ g_content(M)` consistent, then Lindenbaum-extends. The Lindenbaum
extension may or may not include F(a) for other obligations. We have no control
over which formulas Lindenbaum adds.

### Approach E: Modify Lindenbaum to Preserve F-Formulas

The root cause: standard Lindenbaum extension adds formulas in an arbitrary
enumeration order and may add G(neg(psi)) before considering F(psi). If we
modify the enumeration to prioritize F-formulas, we can ensure F-persistence.

**Sketch**: Define a variant `f_preserving_lindenbaum` that:
1. Takes a seed S and a set F_oblig of F-obligations to preserve
2. In the enumeration, processes F-formulas from F_oblig FIRST
3. Each F(a) is either already implied by the current accumulator, or is
   added (since it's consistent with the accumulator -- because the original
   MCS contained it)

**Why this might work**: At each step of the Lindenbaum enumeration, we have
an accumulator Acc that is consistent. F(a) was in the original MCS M, and
Acc ⊆ {target} ∪ M (since g_content(M) ⊆ M and we only add formulas consistent
with the accumulator). If F(a) is consistent with Acc, we add it. If not, then
Acc ⊢ neg(F(a)) = G(neg(a)), meaning G(neg(a)) is derivable from Acc. Since
Acc ⊆ {target} ∪ M, this means... hmm, target could be the cause of the
inconsistency.

**Potential counterexample**: M = {neg(p), F(p), F(q), G(p -> neg(q)), ...}.
Seed = {p} ∪ g_content(M). Lindenbaum adds p first (from seed). Then G(neg(q))
might be derivable: from `p -> neg(q)` (which is in g_content since
G(p -> neg(q)) ∈ M), and p in the seed, we get neg(q). This doesn't yet kill
F(q). But if we also derive G(neg(q)) somehow... Actually from p and
`p -> neg(q)` we get neg(q), but not G(neg(q)). G(neg(q)) would need G-wrapping.

So the F-preserving Lindenbaum approach may actually work because the seed
elements cannot derive G-formulas that kill F-obligations without already having
those G-formulas in g_content(M).

**Actually**, this is promising. Let me formalize:

**Theorem (F-preservation in Lindenbaum extension)**: Given MCS M with
F(a) ∈ M, and seed S = {target} ∪ g_content(M), the Lindenbaum extension
W of S is an MCS with S ⊆ W. Claim: F(a) ∈ W.

Proof: Suppose F(a) ∉ W. Then neg(F(a)) = G(neg(a)) ∈ W (by MCS completeness).
Since W is an MCS, G(neg(a)) ∈ W implies neg(a) ∈ W (by T-axiom).
Also g_content(M) ⊆ W, so for any phi with G(phi) ∈ M, phi ∈ W.

Now, F(a) ∈ M means neg(G(neg(a))) ∈ M, so G(neg(a)) ∉ M.
By MCS completeness of M: neg(G(neg(a))) ∈ M, i.e., F(a) ∈ M (which we knew).

We need to derive a contradiction from G(neg(a)) ∈ W.

**Key observation**: The Lindenbaum extension W of `{target} ∪ g_content(M)` is
a FULL MCS (SetMaximalConsistent), not just a DRM. So W has full negation
completeness.

Can G(neg(a)) ∈ W be consistent with the seed `{target} ∪ g_content(M)`?

- From g_content(M): for any phi, G(phi) ∈ M implies phi ∈ seed
- G(neg(a)) ∈ W means neg(a) ∈ W (by T-axiom)
- This is compatible with g_content(M) in the seed as long as `a` is not in
  g_content(M). And `a ∈ g_content(M)` iff `G(a) ∈ M`.

If `G(a) ∈ M`, then `a ∈ g_content(M) ⊆ W`. But also `neg(a) ∈ W` from
`G(neg(a)) ∈ W`. Contradiction with W's consistency. So `G(neg(a)) ∉ W`, hence
`F(a) ∈ W`.

If `G(a) ∉ M`, then `a ∉ g_content(M)`, so `a` is NOT forced into the seed.
The Lindenbaum extension CAN add either `a` or `neg(a)`, and CAN add
`G(neg(a))`. No contradiction arises.

**So F(a) is preserved in W if and only if G(a) ∈ M.**

This means: F-preservation holds exactly for those a where BOTH F(a) and G(a)
are in M. For obligations where F(a) ∈ M but G(a) ∉ M, the obligation CAN be
lost.

**Example where F is lost**: M contains F(p) but not G(p). The targeted
successor seed is `{q} ∪ g_content(M)` (targeting q, not p). Since `p` is not
forced into the seed, the Lindenbaum extension may add G(neg(p)), killing F(p).

**This confirms the fundamental blocker.**

### Approach F: The Correct Path -- Targeted Chain with Full MCS (Recommended)

After this analysis, the correct approach uses the following insight:

**The TargetedFMCS already resolves F-obligations one-at-a-time.** The problem
is not resolution but F-persistence between resolution steps. However, we do
NOT need F-persistence if we can argue about the SCHEDULING directly.

**Claim**: In the targeted forward chain with targets = [a_1, ..., a_k],
if F(a_i) ∈ chain(0), then a_i ∈ chain(n) for some n.

**Proof by contradiction using temporal logic WITHIN the chain**:

Assume a_i ∉ chain(n) for all n >= 0. The chain has forward_G (proven).

At each scheduled step n where schedule(targets, n) = a_i:
- If F(a_i) ∈ chain(n), then a_i ∈ chain(n+1) by resolution. Contradiction
  with our assumption (a_i ∈ chain(n+1)).
- So F(a_i) ∉ chain(n) at every scheduled step n >= some n_0.

What happens at non-scheduled steps? F(a_i) may be gained or lost.

**The key is that F(a_i) ∈ chain(0) but F(a_i) must vanish at some point.**
When F(a_i) first vanishes (at step m), chain(m) has F(a_i) but chain(m+1)
does not. The successor chain(m+1) has g_content(chain(m)) ⊆ chain(m+1).

F(a_i) ∉ chain(m+1) means G(neg(a_i)) ∈ chain(m+1) (by MCS completeness).
Then by forward_G: neg(a_i) ∈ chain(n) for all n >= m+1.
And G(neg(a_i)) ∈ chain(n) for all n >= m+1 (by temp_4 + forward_G).
So F(a_i) ∉ chain(n) for all n >= m+1 (since F = neg(G(neg))).

**Now**: G(neg(a_i)) ∈ chain(m+1), so neg(a_i) ∈ g_content(chain(m+1)).
By g_content ⊆ chain(m+2): neg(a_i) ∈ chain(m+2). Etc.

BUT: F(a_i) ∈ chain(m) and G(neg(a_i)) ∈ chain(m+1). Is this consistent?
chain(m+1) was built from `{alpha} ∪ g_content(chain(m))` where alpha is
the scheduled target at step m. The seed is consistent (proven). The
Lindenbaum extension may add G(neg(a_i)). But does this contradict anything
in g_content(chain(m))?

G(neg(a_i)) is consistent with g_content(chain(m)) as long as neg(a_i)
doesn't contradict anything derivable from g_content(chain(m)). Since
G(a_i) ∉ chain(m) (otherwise a_i ∈ chain(m+1) via g_content), a_i ∉ g_content(chain(m)).
So neg(a_i) doesn't contradict anything in g_content.

**This analysis shows F-loss IS possible.** The chain construction cannot
prevent it.

### Approach G: Enumerate-All-Obligations (Novel Construction)

**Core idea**: Instead of round-robin on a fixed target list, at each step:
1. Collect ALL unresolved F-obligations: `{a | F(a) ∈ chain(n), a ∉ chain(n)}`
2. Use `canonical_forward_F` to resolve the first one
3. Accept that other F-obligations may be lost
4. But ALSO accept that the resolved obligation is PERMANENT (by forward_G
   argument after resolution)

**The convergence argument**:
- The number of formulas in deferralClosure is finite, say |DC| = N
- At each step, one obligation is resolved (its target becomes permanent)
- New obligations may appear, but they are bounded by N
- A resolved obligation stays resolved: if a_i ∈ chain(m), then by forward_G
  (if G(a_i) can be derived)... Wait, a_i ∈ chain(m) does NOT imply
  a_i ∈ chain(m+1). Only g_content propagates, and a_i ∈ chain(m) doesn't
  mean G(a_i) ∈ chain(m).

**This approach also fails** because resolved obligations can be lost too.

### Approach H: The Fischer-Ladner / Filtration Approach

Use the **Finite Model Property** (FMP) path instead. The existing
`semantic_weak_completeness` (via FMP) may already provide a sorry-free
completeness theorem. Check whether this path is complete.

## Recommendation

After exhaustive analysis, here are the approaches ranked by viability:

### Tier 1: Most Viable

**H. Check if FMP completeness is already sorry-free.** If the FMP/decidability
path already gives completeness without the forward_F sorry, this is the path
of least resistance. The `restricted_shifted_truth_lemma` approach through
BFMCS requires forward_F, but there may be a parallel completeness proof via
FMP that avoids it entirely.

### Tier 2: Viable with Significant Work

**E. F-preserving Lindenbaum with ordering.** Modify the Lindenbaum
construction to enumerate F-formulas from the original MCS before other
formulas. This ensures F(a) ∈ W whenever F(a) ∈ M AND the accumulated context
doesn't derive G(neg(a)). The key theorem would be:

"If F(a) ∈ M and the seed is `{target} ∪ g_content(M)`, and the Lindenbaum
enumeration processes F(a) early, then F(a) ∈ W unless `{target} ∪ g_content(M) ⊢ G(neg(a))`."

Proving that `{target} ∪ g_content(M) ⊬ G(neg(a))` when `F(a) ∈ M` requires:
from `{target} ∪ g_content(M) ⊢ G(neg(a))`, G-wrap to get `G(G(neg(a))) ∈ M`
(using the target), then `G(neg(a)) ∈ M` (by T-axiom applied to G(G(neg(a)))),
then `F(a) = neg(G(neg(a))) ∉ M`. Contradiction with F(a) ∈ M.

Wait -- this argument actually works! Let me spell it out:

Suppose `{target, g_1, ..., g_k} ⊢ G(neg(a))` where each g_i ∈ g_content(M).
Then `{g_1, ..., g_k} ⊢ target -> G(neg(a))`.
By generalized temporal K: `{G(g_1), ..., G(g_k)} ⊢ G(target -> G(neg(a)))`.
Each G(g_i) ∈ M by definition of g_content.
By MCS closure: `G(target -> G(neg(a))) ∈ M`.
By T-axiom: `target -> G(neg(a)) ∈ M`.
Since `F(target) ∈ M`, and `target -> G(neg(a)) ∈ M`, we have:
if target ∈ M, then G(neg(a)) ∈ M, so F(a) ∉ M. Contradiction.
But target may NOT be in M! F(target) ∈ M just means target holds eventually.

Hmm, so the implication `target -> G(neg(a))` is in M but we cannot conclude
G(neg(a)) ∈ M without target ∈ M.

However! From `G(target -> G(neg(a))) ∈ M` and the temp_k distribution axiom:
`G(target -> G(neg(a))) -> (G(target) -> G(G(neg(a))))` is a theorem.
So `G(target) -> G(G(neg(a))) ∈ M`.
If `G(target) ∈ M`, then `G(G(neg(a))) ∈ M`, so `G(neg(a)) ∈ M`, contradiction.
But `G(target) ∉ M` is possible even when `F(target) ∈ M`.

So the G-wrapping argument gives: if `G(target) ∈ M`, then F(a) ∉ M. But we
only have `F(target) ∈ M`, which is weaker. The argument is inconclusive.

**This means Approach E does not clearly work either.**

### Tier 3: Requires Fundamental Redesign

**C. Path extraction from canonical frame** and **D. Direct Henkin construction**
both require significantly rethinking the completeness architecture.

## Final Assessment

The F-preservation seed approach is **blocked** by the same fundamental issue as
all prior attempts: Lindenbaum extensions are non-constructive and can kill
F-obligations. The G-wrapping proof technique only works when ALL non-target
seed elements are in g_content(M), which excludes F-formulas.

The most productive next step is to:

1. **Check the FMP/decidability path** for sorry-free completeness
2. **Investigate whether the DRM bounded_witness approach can be rescued** by
   proving a DRM-specific version of `single_step_forcing` that works within
   deferralClosure (using DRM negation completeness for DC-formulas instead of
   full MCS negation completeness)

### Specific Technical Question for Next Research Round

The DRM approach (handoff 03) was blocked because `FF(psi) ∉ deferralClosure`
prevents getting `neg(FF(psi))` via DRM negation completeness. But we can ask:

**Is `GG(neg(psi))` in deferralClosure?** If `F(psi) ∈ deferralClosure(phi)`,
is `G(neg(psi)) ∈ deferralClosure(phi)`? And `G(G(neg(psi))) ∈ deferralClosure`?

From the definition: deferralClosure = closureWithNeg ∪ deferralDisjunctionSet ∪
backwardDeferralSet ∪ serialityFormulas.

If `F(psi) = neg(G(neg(psi))) ∈ closureWithNeg(phi)`, then `G(neg(psi)) ∈ subformulaClosure(phi)`
(since neg(G(neg(psi))) is in closureWithNeg implies G(neg(psi)) is a subformula of phi or
its negation is). So `G(neg(psi)) ∈ closureWithNeg ⊆ deferralClosure`.

But `G(G(neg(psi)))` -- is this in subformulaClosure(phi)? Only if G(G(neg(psi))) is
a subformula of phi. For `G(psi)` to be in subformulaClosure, we need G(psi) as a
subformula of phi. Then F(psi) = neg(G(neg(psi))), and G(neg(psi)) is a subformula.
But G(G(neg(psi))) is NOT a subformula unless specifically present in phi.

So `GG(neg(psi)) ∉ deferralClosure` in general. This confirms the DRM approach blocker.

**However**: We don't need `GG(neg(psi))`. We need `single_step_forcing` at the
DRM level. The DRM version would need `F(F(psi)) ∉ u` (DRM). If `F(F(psi)) ∉ deferralClosure`,
then trivially `F(F(psi)) ∉ u` (since u ⊆ deferralClosure). So the hypothesis
`F(F(psi)) ∉ u` is satisfied! The problem is the NEXT step: getting `neg(F(F(psi))) ∈ u`,
which requires MCS negation completeness for `F(F(psi))`, but `F(F(psi)) ∉ deferralClosure`
so DRM negation completeness doesn't apply.

**BUT**: We don't actually need `neg(F(F(psi))) ∈ u`. We need `GG(neg(psi)) ∈ u`.
The chain was: `neg(FF(psi)) ∈ u` -> `GG(neg(psi)) ∈ u` (formula equivalence).
But we can try to establish `GG(neg(psi)) ∈ u` directly if `GG(neg(psi)) ∈ deferralClosure`.
As shown above, it generally isn't.

**Alternative for DRM**: A custom `drm_single_step_forcing` that avoids
`neg(FF(psi))`:

Given F(psi) ∈ u (DRM), Succ u v, and F(psi) at max nesting (i.e.,
iter_F n psi ∈ u but iter_F (n+1) psi ∉ u). We want psi ∈ v.

By f_step: psi ∈ v or F(psi) ∈ v. If F(psi) ∈ v, then iter_F 1 psi ∈ v.
But iter_F (n+1) psi ∉ u, and by `succ_propagates_F_not`, iter_F (n+1) psi ∉ v?

Actually `succ_propagates_F_not` says: if `F(F(psi)) ∉ u` then `F(psi) ∉ v`.
This is because `GG(neg(psi)) ∈ u` -> `G(neg(psi)) ∈ v` -> `F(psi) ∉ v`.
But the derivation `F(F(psi)) ∉ u` -> `GG(neg(psi)) ∈ u` requires MCS
negation completeness for `F(F(psi))`.

For the DRM case with n = 1 (F(psi) ∈ u, FF(psi) ∉ u):
- FF(psi) ∉ u because FF(psi) ∉ deferralClosure (for large enough nesting)
- We need: F(psi) ∈ v or psi ∈ v (from f_step)
- We want to show psi ∈ v (not just F(psi) ∈ v)
- To eliminate the F(psi) ∈ v case, we need G(neg(psi)) ∈ v somehow

`G(neg(psi))` IS in deferralClosure (as shown above). So DRM can reason about it.
From `FF(psi) ∉ deferralClosure` we know `FF(psi) ∉ u`. But we cannot derive
`neg(FF(psi)) ∈ u` or `GG(neg(psi)) ∈ u` via DRM negation completeness.

**Direct approach**: Can we show `G(neg(psi)) ∈ g_content(u)`? This means
`G(G(neg(psi))) ∈ u`. Since `GG(neg(psi)) ∉ deferralClosure` (in general),
this fails.

**What about the bounded witness at n = 0?** If F^0(psi) = psi ∈ u, then psi ∈ v
trivially (n=0 case of bounded_witness). The non-trivial case is n >= 1.

For n = 1: F(psi) ∈ u, F(F(psi)) ∉ u. Want psi ∈ v (one Succ step).
f_step gives psi ∈ v or F(psi) ∈ v.
If F(psi) ∈ v: then F(psi) ∈ v, and we'd need to rule this out.
By `bounded_witness` at v with n=1 again? No, we need F(F(psi)) ∉ v, which
we cannot establish.

**This is a genuine impasse for the DRM chain approach.**

## Summary of Findings

1. **Augmented seed consistency**: BLOCKED. Adding F-formulas to the targeted seed
   prevents G-wrapping. The proof technique fails because F-formulas are not in
   g_content.

2. **F-preservation across steps**: Would work IF the seed were consistent, but
   the seed consistency is blocked (see #1).

3. **Convergence**: Would follow from F-preservation + round-robin scheduling,
   but depends on #2.

4. **Alternative approaches**: All chain-based approaches face the same
   fundamental issue: Lindenbaum extensions can kill F-obligations. The DRM
   approach faces a parallel issue: bounded_witness requires MCS-level negation
   completeness for formulas outside deferralClosure.

5. **Most promising path**: Check FMP/decidability path for sorry-free
   completeness, or develop a custom DRM single-step-forcing that avoids the
   neg(FF) step.
