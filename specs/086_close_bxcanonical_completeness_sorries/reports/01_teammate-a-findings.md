# Teammate A Findings: Redefine bx_le Using Until-Witness Ordering

**Task**: #86 - Close BXCanonical completeness sorries
**Approach**: Redefine bx_le to enable BX7 linearity for eventuality resolution
**Date**: 2026-04-08

---

## Key Findings

### Finding 1: Current bx_le definition and the 5 sorry sites

**Confidence**: HIGH

The current definition at `Frame.lean:61-62`:
```lean
def bx_le (w v : BXPoint) : Prop :=
  g_content w.formulas ⊆ v.formulas
```

This means `bx_le w v` iff `forall phi, G(phi) in w -> phi in v`. The 4 Frame.lean sorry sites are:

| Sorry | File:Line | Signature |
|-------|-----------|-----------|
| `bx_until_eventuality_resolution` | Frame.lean:541-562 | `phi U psi in w, psi notin w -> exists v >= w, psi in v, guard on [w,v)` |
| `bx_until_backward` | Frame.lean:573-584 | `v >= w, psi in v, guard on [w,v) -> phi U psi in w` |
| `bx_since_eventuality_resolution` | Frame.lean:592-599 | Mirror of above for Since |
| `bx_since_backward` | Frame.lean:606-613 | Mirror of above for Since |

The 5th sorry in `Completeness.lean:144` is the canonical model embedding (TaskModel construction). This is downstream of the Frame.lean sorries but architecturally separate.

### Finding 2: Redefining bx_le would BREAK the G truth lemma

**Confidence**: HIGH

The G truth lemma (`TruthLemma.lean:124-132`) critically depends on the g_content definition of bx_le:

**Forward direction** (`bx_G_forward`, Frame.lean:192-195):
```lean
theorem bx_G_forward {w v : BXPoint} {phi : Formula}
    (h_le : bx_le w v) (h_G : Formula.all_future phi in w.formulas) :
    phi in v.formulas :=
  h_le h_G  -- THIS IS LITERALLY THE DEFINITION OF bx_le
```

The forward direction is a one-liner *because* `bx_le w v` IS `g_content w.formulas subseteq v.formulas`. Any redefinition must still prove this as a theorem, not rely on it definitionally.

**Backward direction** (`bx_G_backward`, Frame.lean:208-257): Constructs witness via `{neg phi} union g_content(w)` seed + Lindenbaum. The resulting MCS M satisfies `g_content(w) subseteq M` by construction, which IS `bx_le w M`.

If bx_le were redefined (e.g., via Until-witness chains), we would need:
1. `bx_le w v -> (G(phi) in w -> phi in v)` -- for `bx_G_forward`
2. `g_content(w) subseteq v.formulas -> bx_le w v` -- for `bx_G_backward` (the Lindenbaum witness)
3. `not_G(phi) in w -> exists v, bx_le w v and phi notin v` -- for `bx_G_backward`

Property (1) is the key constraint: any new ordering must still imply g_content inclusion. Property (2) requires the new ordering to be weaker than or equal to g_content inclusion. Together, (1) and (2) force `bx_le w v <-> g_content(w) subseteq v.formulas`, which means any redefinition must be *equivalent* to the current one.

**Bottom line**: The g_content definition is not a design choice that can be swapped -- it is forced by the G truth lemma. Redefining bx_le is NOT viable unless the new definition is provably equivalent to g_content inclusion.

### Finding 3: BX7 gives linearity of Until witnesses, NOT of g_content ordering

**Confidence**: HIGH

BX7 (`Axioms.lean:177-184`):
```
(phi U psi) AND (chi U theta) ->
  ((phi AND chi) U (psi AND theta)) OR
  ((phi AND chi) U (psi AND chi)) OR
  ((phi AND chi) U (phi AND theta))
```

This says: if two Until-formulas hold at w, their witnesses are ordered. The three disjuncts correspond to: witnesses coincide, first resolves first, second resolves first.

However, this does NOT give us linearity of bx_le. Consider MCS points u, v with `bx_le w u` and `bx_le w v`. BX7 tells us nothing about whether `bx_le u v` or `bx_le v u`, because bx_le is about G-content, not Until resolution. Two points u, v can both be >= w in g_content ordering without being comparable.

To use BX7, we would need: `phi U psi in w, psi notin w` implies we can find v with `bx_le w v` and `psi in v` such that for every u with `bx_le w u` and `bx_lt u v`, we can show `phi in u`. But the problem is precisely that `bx_lt u v` (g_content ordering) does not correspond to "u is before v in the Until resolution ordering."

### Finding 4: The fundamental obstacle is propagation of Until along g_content chains

**Confidence**: HIGH

The core problem for `bx_until_eventuality_resolution`:
- We have `phi U psi in w` and `psi notin w`.
- BX9 gives `phi in w`. BX10 gives `F(psi) in w`. Via `bx_forward_witness`, get v with `bx_le w v` and `psi in v`.
- BX5 gives `(phi AND (phi U psi)) U psi in w` (self-accumulation).
- BX4 gives `phi -> G(P(phi))`, so `P(phi U psi) in u` for any `bx_le w u`.

But we need `phi in u` for all u with `bx_le w u` and `bx_lt u v`. The available tools are:
- `P(phi U psi) in u`: tells us some predecessor of u has `phi U psi`, but not u itself.
- `phi U psi in w` does NOT propagate forward through g_content: `phi U psi in w` does NOT imply `G(phi U psi) in w`.
- Without Until-induction or some way to propagate `phi U psi` forward, we cannot establish the guard.

This is the SAME fundamental obstacle identified in task 85 phase 4.

### Finding 5: The standard completeness proof requires Until-induction

**Confidence**: HIGH

The standard Burgess (1984) / Goldblatt (1992) completeness proof for Until-Since temporal logic uses an Until-induction axiom:

```
G(psi -> chi) AND G((phi AND X(chi)) -> chi) -> ((phi U psi) -> chi)
```

(where X is the next-time operator, or more generally, an induction principle). This was previously in the axiom system as `until_induction` but was "removed in BX refactoring" per `Frame.lean:510` and `WitnessSeed.lean` comments.

The BX system replaces Until-induction with BX5 (self-accumulation) + BX6 (absorption) + BX7 (linearity). The question is whether these three axioms together can DERIVE Until-induction.

**BX5 + BX6 give a form of well-foundedness**: BX5 says the Until formula propagates along its own guard (enriching it). BX6 says you cannot infinitely defer: if the deferred eventuality resolution itself satisfies the guard, it collapses. Together, they prevent infinite chains of deferrals.

However, deriving Until-induction from BX5+BX6+BX7 in the formal system is non-trivial and appears to be an open proof engineering challenge for this project.

### Finding 6: An alternative approach -- prove guard directly without redefining bx_le

**Confidence**: MEDIUM

Instead of redefining bx_le, one could try to prove the guard condition directly using BX5 and the specific structure of `bx_forward_witness`.

**Sketch for forward Until**:
1. From `phi U psi in w`, BX5 gives `(phi AND (phi U psi)) U psi in w`.
2. BX10 gives `F(psi) in w`. Use `bx_forward_witness` to get v with `bx_le w v, psi in v`.
3. For the guard: take any u with `bx_le w u, bx_lt u v`.
4. We need `phi in u`. We know `P(phi U psi) in u` (from BX4 + phi U psi in w).
5. KEY GAP: `P(phi U psi) in u` means some predecessor of u has `phi U psi`. But that predecessor might be w itself (not u). We need `phi U psi in u` to extract `phi in u` (via BX9, since if `psi in u` then we could take u as the witness instead of v).

The gap is: does `bx_le w u` and `phi U psi in w` imply `phi U psi in u`?

This would follow if `phi U psi in g_content(w)`, i.e., `G(phi U psi) in w`. But `phi U psi in w` does NOT imply `G(phi U psi) in w` in general. The formula `phi U psi` is NOT globally persistent -- it resolves eventually.

**However**, BX5 gives us `(phi AND (phi U psi)) U psi in w`. At intermediate points (before psi resolves), BOTH phi and `phi U psi` hold. The challenge is formalizing "intermediate points before psi resolves" in terms of g_content ordering.

### Finding 7: The Completeness.lean sorry (5th sorry) is architecturally independent

**Confidence**: HIGH

The sorry at `Completeness.lean:144` needs the canonical TaskModel embedding: constructing a TaskFrame from BXPoints with bx_le as temporal ordering, and showing the truth lemma transfers. This requires:
1. A TaskFrame (linear temporal order + state space)
2. An embedding of BXPoints as "world histories"
3. The truth lemma (which depends on the 4 Frame.lean sorries)

This sorry is blocked on the Frame.lean sorries but involves additional work (the model construction itself). It should be treated as a separate follow-up.

---

## Concrete Proof Sketch

**APPROACH 1 (redefine bx_le) is NOT viable.** The G truth lemma forces `bx_le = g_content inclusion`. Any alternative definition must be equivalent, providing no benefit.

**Instead, the viable approach is to derive Until-induction from BX5+BX6+BX7**, then use it in the standard Burgess/Goldblatt proof. Here is a sketch:

### Step 1: Derive a propagation lemma

**Target**: `phi U psi in w, G(phi) in w, psi notin w -> G(phi U psi) in w` (Until persists as long as the guard holds globally)

This does NOT follow from BX axioms directly, and in fact is FALSE: `phi U psi` says psi will hold EVENTUALLY, but `G(phi)` means phi holds forever. If phi holds forever and psi never holds, then `phi U psi` is false (psi never comes). So this specific statement is wrong.

### Step 2 (revised): Use BX5 iteratively

From `phi U psi in w`:
- BX5: `(phi AND (phi U psi)) U psi in w`
- BX5 again on the enriched Until: we get increasingly enriched guards
- BX6 prevents infinite enrichment

The proof technique should be: construct the witness v and the guard simultaneously via a Zorn/well-ordering argument on the set of MCS that contain `phi U psi`, ordered by bx_le.

### Step 3: Zorn-based eventuality resolution

Define `S = {u : BXPoint | bx_le w u AND phi U psi in u AND psi notin u}`. This set:
- Contains w (by hypothesis)
- Is partially ordered by bx_le
- For any chain C in S and any u in C: phi in u (by BX9, since psi notin u)

If S has a maximal element m:
- phi U psi in m, psi notin m
- BX10: F(psi) in m, so exists v with bx_le m v, psi in v
- Need: phi U psi does NOT hold at v (otherwise v in S, contradicting maximality unless bx_le m v but not bx_le v m... but there's no reason v should be in S)

**Problem**: The maximal element m satisfies `phi U psi in m`, so F(psi) in m, and there exists a successor with psi. But we need the chain from w to v to have phi everywhere, and maximality of m does not give this.

**The fundamental issue remains**: without a way to guarantee that every point between w and v in the g_content ordering satisfies `phi U psi`, we cannot extract the guard.

---

## Gaps and Risks

### Gap 1: Until-induction derivability from BX5+BX6+BX7 (CRITICAL)
The entire completeness proof for Until/Since hinges on this. The standard proof uses Until-induction as a primitive. BX5+BX6+BX7 were introduced as replacements but no derivation has been carried out. This is likely the key mathematical challenge for this project.

**Risk**: Until-induction may NOT be derivable from BX5+BX6+BX7 alone. These axioms are semantically complete (they axiomatize the same logic), but deriving Until-induction proof-theoretically may require substantial effort.

### Gap 2: bx_le is a preorder, not a linear order
Even if Until-induction is derived, the canonical ordering bx_le is only a preorder (reflexive + transitive). It is NOT antisymmetric (different MCS can have the same g_content). The Until semantics requires a LINEAR order. Establishing linearity on intervals (or at least on relevant chains) is a separate challenge.

### Gap 3: Model embedding (5th sorry)
Even after closing the 4 Frame.lean sorries, the Completeness.lean sorry requires building a TaskModel, which involves constructing a linear temporal order from the preorder of BXPoints. This requires quotienting by bx_le equivalence classes and showing the quotient is linear.

---

## Confidence

**Approach 1 (redefine bx_le): NOT VIABLE (confidence: HIGH)**

The G truth lemma forces bx_le to be equivalent to g_content inclusion. Redefining it gains nothing and risks breaking existing proofs.

**Overall assessment for closing the 5 sorry sites**: The path requires either:
1. Deriving Until-induction from BX5+BX6+BX7 (hard, open problem)
2. Abandoning the canonical model approach and using filtration/quasimodels instead
3. Re-adding Until-induction as a primitive axiom (simplest, but the BX refactoring removed it for a reason)

---

## Recommendation

**Approach 1 (redefine bx_le) should be ABANDONED.**

Instead, the task should pursue one of:

**(A) Derive Until-induction from BX5+BX6+BX7**: This is the mathematically correct path. BX5+BX6+BX7 are semantically equivalent to the original axiom set (same logic), so Until-induction IS derivable in principle. The derivation likely uses BX7 linearity to show that any counterexample to Until-induction leads to a contradiction via BX5 self-accumulation and BX6 absorption. This is a purely proof-theoretic task -- no semantic or model-theoretic reasoning needed.

**(B) Re-add Until-induction as a primitive axiom**: If deriving it is too hard, simply re-add it. The BX axiom set was introduced for cleaner axiomatics, but if it blocks the completeness proof, pragmatism favors having the proof go through. The soundness of Until-induction on linear orders is straightforward.

**(C) Alternative completeness proof strategy**: Instead of the standard canonical model, use a filtration or finite model property argument. The FMP machinery already exists in the codebase (Algebraic/). This avoids the Until-induction issue entirely by working with finite structures.

My recommendation is **(A)** first (2-4 hours of proof engineering), falling back to **(B)** if blocked.
