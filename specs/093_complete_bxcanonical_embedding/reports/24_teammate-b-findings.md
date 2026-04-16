# Teammate B Findings: Alternative Approaches (Round 24)

## Research Focus

Alternative approaches from the literature and novel strategies NOT yet tried for closing the 6 sorry sites in RootScopedChain.lean. Deep dive into published proof techniques, existing quasimodel infrastructure reuse, and concrete Lean-level proposals.

---

## Key Finding 1: Published Proofs Universally Avoid Syntactic Chain-Level F-Resolution

After web research on Burgess 1982/1984, Goldblatt 1992, GHR 1994, Reynolds 1996/2003, Venema 1993, and the Amsterdam constructive method (de Jongh-Veltman-Verbrugge 2004), the core finding is:

**No published completeness proof for Since/Until tense logics over linear orders builds an Int-indexed MCS chain with syntactic F-eventuality resolution.** All published proofs use one of three families:

**Family A: Full Canonical Model + Bulldozing (Segerberg-style)**
Build ALL MCS worlds as the canonical model. The truth lemma holds on this full model. Then use "bulldozing" (frame surgery from Segerberg, described in Venema's survey and Hodkinson-Reynolds Chapter 11 of Handbook of Modal Logic) to reshape the partial order into a linear order. F-eventualities are automatic: `F(psi) in w` implies `bx_forward_witness` produces `v >= w` with `psi in v`. No chain construction needed.

**Family B: Step-by-Step Construction (Amsterdam school)**
Build the chain incrementally, but the seed at each step includes all needed formulas. The consistency of enriched seeds is proved via compactness + finite model property. This differs from the current approach in that the FMP gives a *model-theoretic* guarantee that the enriched seed is consistent.

**Family C: Quasimodel/Mosaic + Unwinding (Reynolds, Burgess)**
Build a finite quasimodel with local coherence, verify eventuality discharge via well-founded defect counting, then unwind to an infinite model. This is exactly what the sorry-free Quasimodel/ infrastructure implements.

**The ROAD_MAP (line 700) correctly identifies this**: "Standard completeness proofs handle forward_F semantically, not syntactically." The current `rr_fwd_chain` approach is a non-standard technique without published validation.

---

## Key Finding 2: The Quasimodel Infrastructure Already Solves F-Eventuality at BXPoint Level

The sorry-free infrastructure (2,289 lines, 9 files) provides:

| Function | Signature | Status |
|----------|-----------|--------|
| `bx_forward_witness` | `F(psi) in w -> exists v, bx_le w v and psi in v` | Sorry-free |
| `bx_backward_witness` | `P(psi) in w -> exists v, bx_le v w and psi in v` | Sorry-free |
| `bx_until_eventuality_resolution` | `phi U psi in w, psi not in w -> exists v >= w, psi in v, phi in w` | Sorry-free |
| `bx_since_eventuality_resolution` | Mirror for Since | Sorry-free |

These produce **abstract BXPoint witnesses**, not chain indices. The gap: converting abstract witnesses to chain members.

---

## Key Finding 3: Dependency Analysis Reveals Sorry 5 May Be Independently Provable

The 6 sorries have this dependency structure:

```
rr_fwd_chain_forward_F (sorry 1)  <-- PRIMARY BLOCKER
    |
    +-> dd_fmcs_forward_F (sorry 2)  [reduces to sorry 1 for t >= 0]
    +-> dd_fmcs_backward_P (sorry 3) [symmetric]
         |
         +-> dd_bfmcs_restricted_tc (sorry 4)  [follows from 2+3]
              |
              +-> dd_bfmcs_restricted_fuc (sorry 6) [needs sorry 1 + guard]
              +-> dd_bfmcs_restricted_buc (sorry 5) [MAY BE INDEPENDENT]
```

**Sorry 5 (restricted_backward_until_since_coherent)** asks: if the *semantic* Until condition holds at chain(t) (i.e., there exists `s >= t` with `psi in chain(s)` and guard `phi` at all intermediate points), does `phi U psi in chain(t)`?

This is a *membership* question about an MCS. The BX axioms (BX8 reflexive intro + BX5 self-accumulation + BX6 absorption) provide tools to derive Until membership from witnesses. If `g_content(chain(t)) subset chain(s)` (which holds for t <= s), and we can show the right formulas propagate... this might be provable from existing infrastructure without sorry 1.

**Concrete proof sketch for sorry 5 (backward Until coherence)**:

Given: `s >= t`, `psi in chain(s)`, `phi in chain(r)` for all `r in [t, s)`.

Case s = t: `psi in chain(t)`, so by BX8: `phi U psi in chain(t)`.

Case s > t: We need `phi U psi in chain(t)`. Since `phi in chain(t)` (from the guard at r = t) and `F(psi) in chain(t)` (by BX4': `psi in chain(s)` and `bx_le chain(t) chain(s)` gives `H(F(psi)) in chain(s)` which gives `F(psi) in chain(t)`), we can try BX12 (`F(psi) -> top U psi`) to get `top U psi in chain(t)`, then BX2 (left monotonicity) to strengthen from `top` to `phi`...

But BX2 requires `G(top -> phi) in chain(t)`, which means `G(phi) in chain(t)`. We don't have that -- we only have `phi in chain(r)` for `r in [t, s)`, not `G(phi)` anywhere.

**Conclusion**: Sorry 5 is NOT easily provable independently. The guard-to-Until backward direction is non-trivial even with the semantic witnesses available.

---

## Key Finding 4: Two-Phase Architecture (Most Promising Novel Approach)

### Core Idea

Separate chain construction from eventuality resolution:

**Phase A (Finite Quasimodel Segment)**: For each F-obligation `F(psi)` at M0 where `psi in deferralClosure(root)`, use the quasimodel defect-discharge machinery to build a finite BXPoint chain segment that resolves psi.

**Phase B (Assembly)**: Combine the finite segments into an Int-indexed chain, using g_content propagation as glue.

### Why this differs from all dead ends

- Dead End 13: Tried enriched seeds with f_carry. This avoids f_carry entirely.
- Dead End 14: Tried fuel-based recursion. This uses quasimodel's well-founded recursion on defect count.
- Dead End 16: Tried to show existing chain resolves. This builds a new chain from quasimodel segments.
- Dead End 20: Tried BX12 reformulation. This uses the full quasimodel machinery, not just individual axioms.

### Concrete construction

```
chain(0) = M0
chain(1..k1) = quasimodel segment resolving psi_1
chain(k1+1..k2) = quasimodel segment resolving psi_2
...
chain(k_{m-1}+1..k_m) = quasimodel segment resolving psi_m
chain(k_m+1..) = repeat for any new F-obligations at chain(k_m)
```

At each quasimodel segment boundary, the connection works because `bx_forward_witness` ensures `g_content(chain(k_i)) subset chain(k_i + 1)`.

### Key difficulty: Segment boundaries

At each segment boundary, we need the NEW segment to begin from a point that extends the PREVIOUS segment's endpoint. The quasimodel builds chains starting from an arbitrary BXPoint. Can it start from a specific chain(k_i)?

**Yes**: `bx_forward_witness` takes any MCS with `F(psi) in M` and produces a BXPoint v with `g_content(M) subset v` and `psi in v`. The resulting v can serve as the starting point for the next segment.

### Key difficulty: New obligations at segment endpoints

After resolving psi_1 at chain(k1), the endpoint chain(k1) may contain new `F(chi)` for chi in deferralClosure(root). These need resolution too. Since deferralClosure(root) is finite, the total number of distinct formulas needing resolution is bounded. But the SAME formula can have its F-obligation regenerated.

**This is the same problem as sorry 1.** The finite quasimodel segment resolves psi, but F(psi) can reappear at the endpoint.

### Assessment: 35% chance of working as described

The reappearance problem may make this no easier than the direct approach. However, the quasimodel's defect-discharge gives something the round-robin doesn't: at each segment, defect_count STRICTLY DECREASES. If we track the GLOBAL defect count across all segments, it eventually hits zero.

**But**: Global defect count can increase at segment boundaries when new F-obligations appear. The quasimodel's well-founded recursion is LOCAL (within a segment), not GLOBAL.

---

## Key Finding 5: Semantic Coherence Via Restructured Truth Lemma

### The insight

Instead of proving chain-level F-resolution (sorry 1) and deriving temporal coherence (sorries 4-6), restructure the parametric truth lemma to use abstract BXPoint witnesses directly.

### How it would work

The `restricted_parametric_truth_lemma` currently requires `restricted_temporally_coherent` as a hypothesis. This hypothesis demands F-eventuality resolution within each FMCS family (i.e., at chain indices).

**Alternative**: Modify the truth lemma to use BXPoint-level witnesses instead of chain-level witnesses. Since `bx_forward_witness` already gives `v >= w` with `psi in v`, and the truth lemma relates formula membership to semantic truth, we could potentially:

1. Prove: `F(psi) in chain(t)` implies `truth_at M Omega tau t (F psi)` (by truth lemma for F)
2. From semantic truth of F(psi): there exists `s >= t` with `truth_at M Omega tau s psi`
3. From truth of psi at s: `psi in chain(s)` (by truth lemma converse)

**Circularity risk**: Steps 1 and 3 both invoke the truth lemma. The truth lemma proof by formula induction already handles F = neg(G(neg)) via the G case. The question is whether the inductive structure allows this.

**For the G case**: `truth_at (G phi) at t <-> forall s >= t, truth_at phi at s`. The forward direction uses `g_content(chain(t)) subset chain(s)` (which IS proved). The backward direction uses `restricted_temporally_coherent` (which is sorry 4).

**So**: The truth lemma for G needs restricted_tc (sorry 4), which needs forward_F (sorry 1). The circularity is real.

### Assessment: 25% chance

Would require non-trivial restructuring of the truth lemma proof. The inductive structure seems to prevent bypassing the chain-level coherence requirement.

---

## Key Finding 6: Alternative D -- Lexicographic Product Z x N

### The idea

Instead of D = Int (Z), use D = Z x N with lexicographic order. Each "main" time point is (n, 0), and resolution sub-steps are (n, 1), (n, 2), etc.

### How it helps

At main point (n, 0), if F(psi) is present, insert a resolution sub-chain at (n, 1), (n, 2), ..., (n, k) using the quasimodel defect-discharge. The main chain continues at (n+1, 0).

Since the sub-chain is finite (bounded by defect count), and Z x N is still a linear order, this gives:
- Each F-obligation is resolved within the sub-chain at that time step
- The main chain continues independently

### Why this was NOT already tried

Dead ends focus on Int-indexed chains. Z x N gives strictly more insertion points. The quasimodel segments fit naturally into the sub-chains.

### Key difficulty

D must be a totally ordered abelian group (for the TaskModel). Z x N is not an abelian group (N has no additive inverses). Z x Z with lexicographic order IS an abelian group, but then the "sub-chain" dimension is infinite, which doesn't help.

**Alternative**: Use Q (rationals). Between any two rationals, there are infinitely many more, so resolution sub-chains can be inserted. But this requires D = Q, and the canonical model construction would need to work over Q.

**Problem**: The current `dd_countermodel` uses D = Int. Changing to Q would require proving all the parametric infrastructure works over Q. The `ParametricCanonicalTaskFrame` is already parametric in D, so this might be feasible.

### Assessment: 20% chance

Changing D is a significant architectural change. The parametric infrastructure IS parametric in D, but all the current chain construction (rr_fwd_chain, rr_bwd_chain, dd_chain) assumes D = Int implicitly through the Nat-indexed recursion.

---

## Key Finding 7: Restricted Seed Consistency (Refined Analysis)

### The question

Is `{target} union g_content(M) union {F(chi) | chi in sigma_list, F(chi) in M}` consistent when `F(target) in M`?

### Dead End 13 revisited

Dead End 13 shows `{target} union g_content(M) union f_carry(M)` is inconsistent in general. The counterexample: `G(F(alpha) -> neg psi) in M`, `F(alpha) in M`, `F(psi) in M`.

With the restricted finite set, the counterexample still applies IF alpha and psi are both in sigma_list and G(F(alpha) -> neg psi) is in M.

**But**: In the restricted case, we can check whether such a G-formula can exist in M when F(target) is also in M. If `G(F(alpha) -> neg target) in M` and `F(alpha) in M` and `F(target) in M`, then:
- `F(alpha) -> neg target` in M (by BX1 on the G-formula)
- So `neg target in M` or `neg F(alpha) in M` (by contrapositive)
- If `neg target in M`: contradicts `F(target) in M`... no, F(target) = neg(G(neg target)), which can coexist with neg target.
- Actually `F(target) in M` and `neg target in M` are compatible! F(target) means neg(G(neg target)), which is consistent with neg(target) being in M.

So the counterexample DOES apply to the restricted case. Dead End 13 is real for any finite restriction.

### Assessment: 10% chance. Dead End 13 is definitive.

---

## Recommended Approach

**Primary**: Two-Phase Architecture (Finding 4) with the quasimodel defect-discharge for finite segments, combined with a careful analysis of whether the global defect count can be made to decrease across segment boundaries.

**Secondary**: Investigate sorry 5 (backward Until coherence) in depth. Even though Finding 3 shows it's not trivially independent, a more sophisticated argument using BX5 (self-accumulation) and g_content propagation might work. Reducing from 6 to 5 sorries would be progress.

**Tertiary**: Explore whether the parametric truth lemma can be restructured to weaken the `restricted_temporally_coherent` hypothesis, perhaps requiring only "eventual resolution within the full BFMCS family" rather than "within each individual FMCS."

---

## Confidence Level

**Overall: 40%** that a viable approach exists among these alternatives.

- 35%: Two-Phase Architecture (Finding 4)
- 25%: Semantic coherence restructuring (Finding 5)
- 20%: Alternative D (Finding 6)
- 10%: Restricted seed consistency (Finding 7)
- 45%: Sorry 5 independently provable (Finding 3) -- revised down after detailed analysis

The fundamental obstacle remains: Classical.choice in Lindenbaum gives no control over which F-formulas persist, and no published proof technique works at the syntactic chain level.

---

## Sources

- [Burgess-Xu Axiomatic System (SEP supplement)](https://seop.illc.uva.nl/entries/logic-temporal/burgess-xu.html)
- [Temporal Logic (Stanford Encyclopedia of Philosophy)](https://plato.stanford.edu/entries/logic-temporal/)
- [Completeness by Construction (de Jongh, Veltman, Verbrugge)](https://festschriften.illc.uva.nl/D65/verbrugge.pdf)
- [Temporal Logic Handbook Chapter (Hodkinson, Reynolds)](https://cgi.csc.liv.ac.uk/~frank/MLHandbook/11.pdf)
- [Venema - Temporal Logic survey](https://staff.science.uva.nl/y.venema/papers/TempLog.pdf)
- [GHR 1994 - Temporal Logic (Gabbay, Hodkinson, Reynolds)](https://global.oup.com/academic/product/temporal-logic-9780198537694)
- [Goldblatt 1992 - Logics of Time and Computation](https://csli.sites.stanford.edu/publications/csli-lecture-notes/logics-time-and-computation)
