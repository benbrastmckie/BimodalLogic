# Teammate C Research: Dovetailed Algebraic Approach (No FMP Dependency)

**Task**: 58 - Wire Completeness to Frame Conditions
**Role**: Teammate C - Dovetailed Algebraic Approach (No FMP Dependency)
**Date**: 2026-03-26
**Focus**: Revisiting Approach 6 with pure algebraic construction, avoiding FMP machinery

---

## Key Findings

After thorough analysis of the codebase — specifically `UltrafilterChain.lean`,
`ParametricTruthLemma.lean`, `AlgebraicRepresentation.lean`, and `CanonicalTaskRelation.lean` —
the algebraic approach to Approach 6 has a **decisive breakthrough** that the previous
research missed: the `boxClassFamilies_bundle_forward_F` and `boxClassFamilies_bundle_backward_P`
theorems (lines 2643-2725 of `UltrafilterChain.lean`) are **already sorry-free** and provide
bundle-level temporal coherence without ANY FMP machinery.

The critical insight is:

> The algebraic approach doesn't need family-level coherence. The `BFMCS_Bundle` structure
> (lines 2758-2785) with bundle-level F/P witnesses is mathematically sufficient for
> completeness — the only barrier is connecting it to the `parametric_shifted_truth_lemma`,
> which requires family-level coherence via `BFMCS.temporally_coherent`.

This is not a barrier to completeness; it is a gap in the truth lemma. The gap can be
closed by proving a **bundle truth lemma** for `BFMCS_Bundle`.

---

## Sub-Case (b) Re-analysis with Task Relation

The previous research identified "sub-case (b)" as the core blocker: when `F(phi) ∈ backward_chain(n)`
and `G(neg phi) ∈ M0`, no same-family witness exists for phi.

### The CanonicalTask Relation Does NOT Resolve Sub-Case (b)

Reading `CanonicalTaskRelation.lean`, the `CanonicalTask(u, n, v)` relation simply tracks
n-step reachability via the `Succ` relation. The 3-place structure gives:

```
CanonicalTask u (negative_n) v  ↔  CanonicalTask_backward u |negative_n| v
                                ↔  exists chain v = w_0 → w_1 → ... → w_{|n|} = u
```

This says v is the "past" of u in the Succ chain. For sub-case (b):

- u is at time -n (negative time, in backward chain)
- We have `F(phi) ∈ u`
- We need v at some time -n < t ≤ 0 with `phi ∈ v`
- The backward chain was built by H-witnesses (preserving H-theory, not G-theory)

**The problem remains**: the backward chain's intermediate MCSes may contain `G(neg phi)`
(inherited from M0 which has `G(neg phi)`). If G(neg phi) is in every backward-chain MCS,
then phi cannot be in any of them, because G(neg phi) → H(neg phi) and phi ∧ neg phi is
inconsistent.

Wait — the backward chain preserves H-theory from M0 propagating backward, but NOT G-theory.
More precisely: the backward chain is built via `past_theory_witness_exists`, which ensures
H(a) ∈ M → H(a) ∈ W. The question is whether G(neg phi) survives into the backward chain.

The answer is YES: `G_of_box_theory` shows that box_theory elements have their G in M.
Since `G(neg phi)` is not necessarily a box formula, it need not be in any seed. But the
backward chain's MCS at time -k was built from M0's backward seed `{F_top} ∪ H_theory(M_{k-1})`.
The seed does NOT include `G(neg phi)`, so the backward chain MCS at -k might or might
not contain `G(neg phi)`.

**Refined conclusion**: Sub-case (b) is only a problem when `G(neg phi) ∈ M_n` for all n
in the backward chain. This would require `G(neg phi)` to be preserved through all past
witnesses. Since `G(neg phi)` is not in the seed (H_theory ∪ box_theory), it can fail
to be in the witness MCS — but the witness MCS is an arbitrary extension, so it MIGHT
contain `G(neg phi)` or it might not.

**Precise obstacle**: The current backward chain uses `omega_step_backward` which resolves
`P_top` at each step. It does NOT specifically ensure that `G(neg phi)` is excluded from
the witness. An arbitrary extension of `{P_top} ∪ H_theory(M0) ∪ box_theory(M0)` could
consistently include `G(neg phi)` (if G(neg phi) is consistent with that seed).

**The CanonicalTask relation at best provides**: "there is a chain connecting u and v of
length n." It does not ensure that the formulas in intermediate chain nodes avoid G(neg phi).

**Conclusion**: The CanonicalTask 3-place relation does not resolve sub-case (b). The obstacle
is genuine: we cannot generally guarantee that phi appears in the same backward chain family
when `G(neg phi) ∈ M0`.

---

## Algebraic Representation Theorem Connection

The `AlgebraicRepresentation.lean` file proves:

```lean
theorem algebraic_representation_theorem (φ : Formula) :
    AlgSatisfiable φ ↔ AlgConsistent φ
```

This is entirely sorry-free and proves that consistent formulas have ultrafilter witnesses.
However, it proves **algebraic** satisfiability (existence of ultrafilter with [phi] ∈ U),
NOT semantic satisfiability in a TaskFrame model.

The gap: `AlgSatisfiable phi` means there is an ultrafilter of `LindenbaumAlg` containing
`[phi]`. For completeness of TM, we need a **semantic model** — a TaskFrame where phi is
true at some world-time pair.

The representation theorem path requires:
1. From `AlgSatisfiable phi`: get ultrafilter U with `[phi] ∈ U`
2. Build a TaskFrame model from ultrafilters
3. Show semantic truth in the ultrafilter model corresponds to algebraic membership
4. Prove the ultrafilter model satisfies TaskFrame axioms

Step 4 is where the temporal coherence problem resurfaces: the ultrafilter model must
satisfy `∀ (U : AlgWorld), R_G U V → ∃ t, t > current_time ∧ phi_true_at t`. This is
isomorphic to the family-level coherence problem in disguise.

**Key insight from the algebraic approach**: The Lindenbaum algebra approach converts the
problem from "find phi in the SAME chain" to "find an ultrafilter U' with phi ∈ U' and
U' in the R_G-future of U." In S5-modal + tense logic, R_G is the temporal accessibility
relation on ultrafilters. The question becomes: does every ultrafilter U with F(phi) ∈ U
have an R_G-successor V with phi ∈ V?

**This is provable**: The `temporal_theory_witness_consistent` theorem (lines 1108-1147)
proves that `{phi} ∪ G_theory(U) ∪ box_theory(U)` is consistent when `F(phi) ∈ U`, so
there IS an MCS/ultrafilter V with phi ∈ V and G_theory preserved from U. This means
R_G(U, V) and phi ∈ V.

But this witness V is in the BUNDLE, not necessarily in the SAME chain as U. The algebraic
approach gives bundle-level coherence, not family-level coherence.

---

## Proposed Non-FMP Construction

The codebase already implements a clean algebraic construction that avoids FMP entirely.
The key files are `UltrafilterChain.lean` (lines 2496-2945) and `AlgebraicRepresentation.lean`.

### The Sorry-Free Construction Path

The current state of the code shows a **complete, sorry-free** bundle-level construction:

**Already sorry-free:**
- `temporal_theory_witness_consistent` (lines 1108-1147): F(phi) ∈ M → {phi} ∪ seed consistent
- `temporal_theory_witness_exists` (lines 1153-1185): Gives MCS W with phi, G-agree, box-agree
- `boxClassFamilies_bundle_forward_F` (lines 2643-2681): SORRY-FREE bundle forward F
- `boxClassFamilies_bundle_backward_P` (lines 2688-2725): SORRY-FREE bundle backward P
- `boxClassFamilies_modal_forward` (lines 1595-1639): SORRY-FREE modal forward
- `boxClassFamilies_modal_backward` (lines 1641+): SORRY-FREE modal backward
- `construct_bfmcs_bundle` (lines 2853-2864): SORRY-FREE BFMCS_Bundle construction
- `algebraic_representation_theorem` (lines 180-182): SORRY-FREE

**The sorry-free construction**:

```
1. phi not provable
   ↓
2. neg(phi) consistent (algebraic_representation_theorem / not_provable_implies_consistent)
   ↓
3. Extend to MCS M0 (set_lindenbaum: SORRY-FREE)
   ↓
4. neg(phi) ∈ M0
   ↓
5. Build construct_bfmcs_bundle M0 h_mcs: BFMCS_Bundle (SORRY-FREE)
   ↓
6. eval_family.mcs 0 = M0, so neg(phi) ∈ eval_family.mcs 0
   ↓
7. phi ∉ eval_family.mcs 0 (by consistency)
   ↓
8. Need: truth_at model tau 0 phi is FALSE
   ← REQUIRES: bundle truth lemma for BFMCS_Bundle
   ↓
9. phi is not universally valid
```

Step 8 is the only missing piece. The current `parametric_shifted_truth_lemma` requires
a `BFMCS D` with `temporally_coherent` (family-level), but we have a `BFMCS_Bundle` with
only bundle-level coherence.

### The Bundle Truth Lemma

The needed theorem is:

```lean
theorem bundle_truth_lemma (B : BFMCS_Bundle)
    (fam : FMCS Int) (hfam : fam ∈ B.families)
    (t : Int) (phi : Formula) :
    phi ∈ fam.mcs t ↔
    truth_at BundleModel BundleOmega (parametric_to_history fam) t phi
```

Where `BundleModel` and `BundleOmega` are defined using bundle-level coherence rather
than family-level coherence.

**Critical question**: Can this truth lemma be proved for `all_future` (G) and `all_past` (H)?

**Forward direction (G)**: `G(phi) ∈ fam.mcs t → ∀ s ≥ t, phi ∈ fam.mcs s`
- This uses `fam.forward_G` which is in the FMCS structure (sorry-free)
- So the forward direction of G holds

**Backward direction (G)**: `∀ s ≥ t, truth_at s phi → G(phi) ∈ fam.mcs t`
- This requires `temporal_backward_G`: if phi is in fam.mcs s for all s strictly greater
  than t, then G(phi) ∈ fam.mcs t
- `temporal_backward_G` requires `TemporalCoherentFamily` which requires `forward_F`
- `forward_F` needs: F(phi) ∈ fam.mcs t → ∃ s > t, phi ∈ fam.mcs s (SAME family)
- **This is the blocked claim**

**The sub-case (b) problem resurfaces here**: The backward direction of G requires
family-level F-witnesses. The bundle truth lemma fails at this point for the same reason
as the original `parametric_shifted_truth_lemma` does.

### What "Bundle Semantics" Would Solve

If we define truth for `G(phi)` using bundle-level coherence:

```
truth_at_bundle B tau t (G phi) ↔
  ∀ tau' ∈ B.families, ∀ s ≥ t, truth_at_bundle B tau' s phi
```

This is NOT the standard semantics of TM. Standard TM uses the SAME history tau:
```
truth_at M Omega tau t (G phi) ↔ ∀ s ≥ t, truth_at M Omega tau s phi
```

So the bundle approach would prove completeness for a DIFFERENT logic — one where
"G" means "inevitably true in all histories." This is Bundled Kripke semantics,
which Teammate D correctly identified in Approach 4 as changing the logic.

---

## Why the Previous Blockers Persist

### Blocker 1: Family-Level Coherence for Backward Direction of G

The `temporal_backward_G` theorem requires:

```lean
theorem temporal_backward_G (fam : TemporalCoherentFamily D) (t : D) (phi : Formula)
    (h : ∀ s : D, t < s → phi ∈ fam.mcs s) : Formula.all_future phi ∈ fam.mcs t
```

The proof strategy (from `TemporalCoherence.lean`) is:
1. By contraposition: assume G(phi) ∉ fam.mcs t
2. Then F(neg phi) ∈ fam.mcs t (MCS negation completeness)
3. By `forward_F`: ∃ s > t, neg(phi) ∈ fam.mcs s (SAME family)
4. By IH: truth_at ... s (neg phi) is true, contradicting phi true at all s > t

Step 3 REQUIRES family-level `forward_F`. Bundle-level coherence only gives:
∃ fam' ∈ bundle, ∃ s > t, neg(phi) ∈ fam'.mcs s

And fam' might be different from fam. The IH contradiction doesn't follow because
we have truth at s in fam' but the assumption is truth at s in fam (same history).

**This is the genuine mathematical obstacle**: the backward direction of the truth lemma
for `all_future (G)` inherently requires family-level F-witnesses.

### Blocker 2: Z_chain Forward G Has Sorries

The Z_chain construction (lines 2297-2370) has two sorry cases:
- When t < 0 and t' ≥ 0: "crossing" from backward to forward chain
- When both t < 0 and t' < 0: G-formulas not preserved by H-witnesses

These reflect the fundamental asymmetry: the forward chain preserves G-theory, but
the backward chain does NOT preserve G-theory. So G(phi) at negative time t does not
imply G(phi) at 0 or positive times.

**This cannot be fixed**: an MCS at time -k was chosen as an H-witness from M_{-k+1},
which only means H(a) ∈ M_{-k+1} propagates. Nothing forces G(phi) ∈ M_{-k} to
propagate forward. A counterexample: M_{-k} could contain G(neg phi) even if G(phi) ∈ M0,
because the H-witness for M_{-k} might extend a seed that is compatible with both.

---

## The Algebraic Path That Actually Works

After careful analysis, the algebraic path to sorry-free completeness requires a careful
separation between what the bundle gives and what the truth lemma needs.

### Key Observation: Only Forward Direction is Needed for Completeness

Completeness requires: "if phi is valid, then phi is provable."

By contraposition: "if phi is not provable, then phi is not valid."

"Not valid" means: ∃ model M, ∃ Omega, ∃ tau, ∃ t, ¬ truth_at M Omega tau t phi.

The FORWARD direction of the truth lemma suffices:
- If neg(phi) ∈ M0 (the base MCS), then neg(phi) is TRUE at (eval_family, time 0)
- This means phi is FALSE at (eval_family, time 0)
- So phi is not universally valid

The forward truth lemma (MCS membership → semantic truth) does NOT require family-level
F-witnesses. It only uses:
- `forward_G`: G(phi) ∈ fam.mcs t → phi ∈ fam.mcs s for all s ≥ t (sorry-free FMCS property)
- `backward_H`: H(phi) ∈ fam.mcs t → phi ∈ fam.mcs s for all s ≤ t (sorry-free FMCS property)
- `modal_forward`: Box(phi) in one family → phi in all families (sorry-free)

Neither forward truth direction needs `forward_F` (family-level).

### The `succ_chain_completeness` Path

Looking at the existing code comment at line 1843:
> **For completeness proofs**: Use `succ_chain_completeness` instead, which only requires
> the forward direction of the truth lemma and does NOT depend on temporal coherence.

This is precisely the right path. The forward-only truth lemma for SuccChainFMCS gives:

```
phi ∈ (SuccChainFMCS M0).mcs t → truth_at ... phi
```

By induction on formula, all cases use only sorry-free lemmas. This gives a sorry-free
countermodel: for non-provable phi, neg(phi) ∈ M0, and neg(phi) is true at time 0 in
the canonical model, so phi is false there.

**But what truth lemma exactly?** The `succ_chain_completeness` approach needs:

1. Build `BFMCS_Bundle B` from `boxClassFamilies M0 h_mcs` (sorry-free: `construct_bfmcs_bundle`)
2. Prove forward-only truth lemma for `BFMCS_Bundle` (needed: new theorem)
3. neg(phi) true at eval_family, time 0 → phi not universally valid

The forward-only bundle truth lemma can be stated as:

```lean
theorem bundle_forward_truth_lemma (B : BFMCS_Bundle)
    (fam : FMCS Int) (hfam : fam ∈ B.families)
    (t : Int) (phi : Formula) :
    phi ∈ fam.mcs t →
    truth_at BundleSemanticModel BundleCanonicalOmega (parametric_to_history fam) t phi
```

### Why the Forward-Only Bundle Truth Lemma is Provable

The forward direction proof by induction:

**atom**: trivial by definition of valuation.

**bot**: fam.mcs t is consistent, so bot ∉ fam.mcs t → impossible to be in hypothesis.

**imp**: if (psi → chi) ∈ fam.mcs t and truth psi, then psi ∈ fam.mcs t (by IH backward
on psi, which IS the backward direction of psi — but wait, psi is a subformula).

**Observation**: The "forward truth lemma" is the (→) direction of the biconditional, i.e.,
"phi ∈ fam.mcs t → truth_at ... phi". But the `imp` case in this direction requires the
BACKWARD direction for the antecedent (psi). This is the classic structural issue in
Henkin completeness proofs: the forward direction of implication uses the backward direction
of the antecedent.

If the backward direction of the antecedent formula psi fails (because psi contains G),
the forward direction of the implication (psi → chi) also fails.

**However**: The FORWARD direction for all atomic formulas, bot, and box is unproblematic.
The issue only arises for G-formulas when they appear as antecedents of implications
nested in the formula being evaluated.

**The fix**: The forward truth lemma works perfectly for formulas that don't require
the backward direction of G as a subcase. This covers:
- All propositional formulas (no G/H)
- Formulas where G appears only positively (under even number of negations)
- The specific case needed for completeness: `neg(phi)` being true

For the specific completeness use case, we only need truth of `neg(phi)` at time 0.
If phi is a positive formula (which are the formulas one typically asks about),
`neg(phi)` is `phi → bot`, and the forward truth lemma for negation works cleanly.

**Actually, for GENERAL phi**: The truth lemma needs to handle all formulas. The key is
what the semantics of G are in the bundle model. If we use standard semantics
(G phi = true iff phi true at all s ≥ t in the SAME history), then the backward direction
for G is blocked. But the forward direction for G:
- G(phi) ∈ fam.mcs t → phi ∈ fam.mcs s for all s ≥ t (by FMCS.forward_G, sorry-free)
- → truth_at ... s phi (by IH on phi)
- → truth_at ... t (G phi) (by definition of truth for G)

This IS sorry-free! The backward direction (truth of G phi → G phi in MCS) is blocked,
but the FORWARD direction (G phi in MCS → truth of G phi) is fine.

**The issue in the imp case**: Forward truth for (psi → chi) requires:
Given (psi → chi) ∈ fam.mcs t and truth_at psi: prove truth_at chi.
- (psi → chi) ∈ MCS and psi ∈ MCS → chi ∈ MCS (MCS closure)
- But we need: truth_at psi → psi ∈ MCS (BACKWARD direction of psi)

So the forward truth lemma for `psi → chi` requires the BACKWARD direction of psi.
This creates a mutual dependency. For the FORWARD truth lemma to be self-contained,
we'd need to ALSO have the backward direction for psi.

**Resolution**: The forward truth lemma for GENERAL formulas requires the FULL bidirectional
truth lemma for all subformulas. This is the standard induction structure. You can't
separate them.

The ONLY clean escape is:
1. Prove the full truth lemma (both directions) — requires family-level F-witnesses
2. OR use only the forward truth lemma for atomic/ground formulas (trivially sorry-free)
3. OR change the semantics (bundle semantics) — changes the logic

---

## Summary: The Precise Mathematical Blockade

### What the Algebraic Approach Successfully Proves (All Sorry-Free)

1. **Consistent formulas have ultrafilter witnesses**: `consistent_implies_satisfiable` (AlgebraicRepresentation.lean)
2. **F-witnesses exist in the box class**: `temporal_theory_witness_exists` (UltrafilterChain.lean)
3. **Bundle-level temporal coherence**: `boxClassFamilies_bundle_temporally_coherent` (UltrafilterChain.lean)
4. **Modal coherence**: `boxClassFamilies_modal_forward`, `boxClassFamilies_modal_backward`
5. **The canonical BFMCS_Bundle is constructible**: `construct_bfmcs_bundle`

### What the Algebraic Approach Cannot Prove Without FMP or Restriction

**Family-level forward F**: `F(phi) ∈ fam.mcs t → ∃ s > t, phi ∈ fam.mcs s`
where the witness s is in the SAME family (same history).

This is mathematically FALSE for arbitrary MCS and arbitrary SuccChainFMCS families.
Counter-example: M0 = {F^n(p) | n ∈ Nat} ∪ {G(neg p)}. This is consistent and extends
to an MCS. The omega chain forward starting from M0 always resolves F_top, but at each
step the new MCS inherits G(neg p) from the temporal seed (G(neg p) is propagated via
G_theory preservation). So neg p ∈ all forward chain members, meaning p is never in the
same chain.

Actually: wait. If G(neg p) ∈ M0 and the forward chain preserves G-theory, then
G(neg p) ∈ omega_chain_forward(n) for all n. But F^1(p) ∈ M0 means p should be somewhere
in the future. The chain CAN'T satisfy both G(neg p) (p is never true) and F(p) (p is
true at some future step). This is a contradiction in the ORIGINAL MCS M0.

**Re-examination**: Is {F(p), G(neg p)} consistent?
- G(neg p) ≡ neg F(p) via the duality F(p) = neg(G(neg p))
- So G(neg p) and F(p) = neg(G(neg p)) are syntactically contradictory
- Therefore {F(p), G(neg p)} is NOT consistent, and no MCS contains both

**This resolves the counterexample!** If F(phi) ∈ M0, then G(neg phi) ∉ M0 (by MCS
consistency, since F(phi) = neg(G(neg phi))). So G(neg phi) is NOT in M0.

**Does G-theory preservation preserve G(neg phi)?** No! G(neg phi) ∉ M0, so the G-theory
seed is `{G(a) | G(a) ∈ M0}` which does NOT include G(neg phi). The temporal witness for
F(phi) uses seed `{phi} ∪ G_theory(M0) ∪ box_theory(M0)`, and G(neg phi) is not in the seed.

**Therefore**: The argument "the forward chain always has G(neg phi)" is WRONG when
F(phi) ∈ M0 (because they are contradictory). The sub-case (b) problem is about the
backward chain, not the forward chain.

### Sub-Case (b) Precise Statement

Sub-case (b): F(phi) ∈ backward_chain(-n) for n > 0, i.e., F(phi) is in an MCS at
NEGATIVE time. We need to find phi at some s > -n, possibly s = 0 or positive.

The backward chain at -k was constructed as a past-witness from -k+1. The seed was
`{neg bot} ∪ H_theory(M_{-k+1}) ∪ box_theory(M0)`.

Since F(phi) ∈ M_{-k}, and F(phi) = neg(G(neg phi)), we have G(neg phi) ∉ M_{-k}.
The forward chain from M_{-k} would resolve F(phi) by placing phi at -k+1. But -k+1
might already be filled by the backward chain's M_{-k+1}.

The issue: M_{-k+1} is in the backward chain and was built WITHOUT regard for
resolving F-obligations from M_{-k}. The backward chain's M_{-k+1} might not contain phi.

**This IS a genuine blocker** for same-family F-witnesses, but it only applies at negative times.

**However, for the FORWARD truth lemma**: We only need:
- G(phi) ∈ fam.mcs t → truth_at ... (G phi)
- This only uses forward_G (sorry-free) and IH on phi
- The backward direction (truth_at G phi → G(phi) ∈ fam.mcs t) is blocked, but not needed for forward

**The forward truth lemma is sorry-free if we only need the (→) direction**:

```lean
theorem bundle_fwd_truth_lemma (B : BFMCS_Bundle) ... :
    phi ∈ fam.mcs t → truth_at_bundle B fam t phi
```

can be proved by induction, BUT only if "truth_at_bundle" for the `imp` case has the
backward direction of subformulas available. The backward direction IS needed for the
`imp` case's forward direction.

### The Induction Dependency

The forward truth lemma for phi requires:
- Forward truth for subformulas: phi → truth
- BACKWARD truth for subformulas of the antecedent in imp: truth_ant → phi_ant

So the forward truth lemma is NOT independent of the backward direction. They are
jointly proved by mutual induction in the standard argument.

**The ONLY clean approach is the full bidirectional truth lemma**, which requires
family-level temporal coherence.

---

## Final Assessment: What Would Actually Work

### Option A: Bundle Semantics (Changes the Logic)

Define `truth_bundle B tau t (G phi)` as `∀ tau' ∈ B.families, ∀ s ≥ t, truth_bundle ... tau' s phi`.

With this semantics, the backward direction works:
- truth_bundle (G phi) at (fam, t) ← all families have phi at all s ≥ t
- G(phi) ∈ fam.mcs t ← phi is in all families (modal_backward) at all s ≥ t

This is sorry-free but proves completeness for BUNDLED semantics, not standard TM semantics.

### Option B: Restricted FMP Path (Changes the MCS)

Use `DeferralRestrictedMCS` over `deferralClosure(phi)`. This gives family-level coherence
because the F-nesting is bounded. `f_nesting_is_bounded_restricted` and
`restricted_forward_chain_forward_F` are sorry-free. This is what Teammate D recommended.

### Option C: Complete the Z_chain with Tracking (Harder but Fully General)

Fix the two sorry cases in `Z_chain_forward_G` and then prove `Z_chain_forward_F` properly.

For `Z_chain_forward_G` crossing cases:
- Case t < 0, t' ≥ 0: Need G(phi) at negative time to imply G(phi) at 0.
  This requires the backward chain to ALSO preserve G-theory forward. Currently it only
  tracks H-theory. Fix: extend `OmegaBackwardInvariant` to track G-theory too.

  But the H-witnesses do NOT preserve G-theory in general. The fix would require
  a DIFFERENT construction for the backward chain that uses BOTH G-theory and H-theory
  in the seed. But `{psi} ∪ G_theory(M) ∪ H_theory(M) ∪ box_theory(M)` being consistent
  when P(psi) ∈ M requires proving `G_of_H_theory` (every H-formula has its G in M),
  which is FALSE in general (H(a) does not imply G(H(a))).

  **This approach is blocked**.

- Case t < 0, t' < 0, t ≤ t': G(phi) ∈ backward_chain(-|t|) does NOT imply
  G(phi) ∈ backward_chain(-|t'|) for |t'| < |t| (earlier in the backward sequence).
  The backward chain is indexed 0, 1, 2, ... where index n corresponds to time -n.
  So t' > t means |t'| < |t|, meaning t' is EARLIER in the sequence.
  G-monotonicity in the backward chain would require that G-formulas propagate
  toward index 0 (toward M0). The backward chain preserves H-theory BACKWARD (increasing
  index), not G-theory forward (decreasing index).

  **This approach is blocked**.

For `Z_chain_forward_F`:
- The current chain only resolves F_top at each step, not arbitrary F(phi).
- Fixing this requires a **diagonalized construction** where step 2k resolves the k-th
  F-obligation enumerated from the base MCS M0.
- This is the Henkin/Rasiowa-Sikorski style construction and IS mathematically correct.
- The technical challenge: the k-th F-obligation `F(phi_k)` at BASE time 0 gets resolved
  at step k. But what about F-obligations appearing at LATER steps (F(psi) ∈ chain(k)
  that wasn't in chain(0))? The diagonalization must handle all pairs (step, formula),
  not just the initial obligations.
- This requires either:
  a. A two-indexed diagonalization: enumerate all (n, F(phi)) pairs where n is a step
     number and F(phi) is an F-formula. At step k = pairing(n, F(phi)), resolve F(phi)
     from chain(n) assuming we've already extended chain(n) to step k.
  b. This requires more complex bookkeeping but is mathematically sound.
  c. In Lean, this would require a more complex recursive construction with dependent
     types or well-founded recursion.

**This IS potentially sorry-free but requires significant new code**.

### Option D: Forward-Only Truth Lemma for neg(phi) Specifically

Since completeness only requires neg(phi) FALSE in the model (i.e., phi TRUE or neg(phi)
FALSE), and the eval family has neg(phi) ∈ M0, we need neg(phi) TRUE at (eval_fam, 0).

For the specific negation formula `neg(phi) = phi → bot`:
- Forward truth for (phi → bot): Given (phi → bot) ∈ fam.mcs 0, if truth_at phi then truth_at bot
- truth_at bot is always False
- So we need: truth_at phi → False, i.e., NOT truth_at phi

This works if we can show phi is FALSE at (eval_fam, 0). But that's what we're trying to prove.

Actually, for completeness, we DON'T need the forward truth lemma for neg(phi). We need:
- The countermodel witnesses: ∃ model, tau, t, phi is false there
- phi is false iff neg(phi) is true iff neg(phi) ∈ M0 (via full truth lemma)

Without the full truth lemma, we can only say "phi ∉ M0" which doesn't directly give
a semantic countermodel.

**Alternative completeness argument** (purely syntactic):
- phi not provable → neg(phi) consistent → neg(phi) ∈ some MCS M0
- phi ∉ M0 (consistency)
- Therefore not all MCSes contain phi
- If "valid in canonical model" meant "in all MCSes," we'd be done
- But semantic validity (truth in all TaskFrame models) is STRONGER than MCS membership

So we do need the truth lemma to connect MCS membership to semantic truth.

---

## Confidence Level

**Confidence that the algebraic approach (WITHOUT FMP) can yield sorry-free full completeness**:
LOW (20%). The G/H backward directions of the truth lemma genuinely require family-level
temporal coherence, which requires either FMP/restriction or the complex diagonalized
construction.

**Confidence that the bundle-level approach gives sorry-free WEAK completeness
(for bundled semantics)**: HIGH (95%). The `construct_bfmcs_bundle` and `BFMCS_Bundle`
machinery is complete, and a bundle truth lemma for bundled semantics would be sorry-free.

**Confidence that the FMP/restricted path (Teammate D's Approach 6) is the right path
for full standard-semantics completeness**: HIGH (85%). The sorry-free infrastructure
(`f_nesting_is_bounded_restricted`, `restricted_forward_chain_forward_F`) already exists.

**Confidence that the diagonalized Z_chain approach (Option C) is mathematically sound**:
MEDIUM (60%). It's correct in principle (Henkin construction), but the Lean formalization
requires careful well-founded recursion over pairs (time, obligation) and is likely
several hundred lines of new code.

**Concrete recommendation**: The cleanest sorry-free path to completeness for STANDARD
TM semantics remains the FMP/restricted construction (Teammate D's approach). The algebraic
path (this research) gives a sorry-free foundation for everything EXCEPT the family-level
temporal coherence, which is the core difficulty.

**Specific new insight**: The Z_chain forward-G sorry cases can potentially be fixed by
extending the backward chain construction to track G-theory AS WELL AS H-theory in its
invariant. But proving `G(a) ∈ M → G(a) ∈ H-witness-of-M` is not immediate and may
require careful analysis of the H-seed's consistency with G-formulas from M.

---

## References

### Key Files
- `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic/Algebraic/UltrafilterChain.lean`
  - Lines 1108-1147: `temporal_theory_witness_consistent` (SORRY-FREE)
  - Lines 1153-1185: `temporal_theory_witness_exists` (SORRY-FREE)
  - Lines 2297-2370: `Z_chain_forward_G` (HAS SORRY at lines 2347, 2368)
  - Lines 2424-2485: `Z_chain_forward_F` (HAS SORRY at line 2485)
  - Lines 2643-2681: `boxClassFamilies_bundle_forward_F` (SORRY-FREE)
  - Lines 2688-2725: `boxClassFamilies_bundle_backward_P` (SORRY-FREE)
  - Lines 2758-2785: `BFMCS_Bundle` structure (SORRY-FREE)
  - Lines 2853-2864: `construct_bfmcs_bundle` (SORRY-FREE)
  - Lines 2931-2945: `bundle_completeness_contradiction` (SORRY-FREE)
- `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic/Algebraic/AlgebraicRepresentation.lean`
  - Lines 180-182: `algebraic_representation_theorem` (SORRY-FREE)
- `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic/Algebraic/ParametricTruthLemma.lean`
  - Lines 170-310: `parametric_canonical_truth_lemma` (SORRY-FREE given h_tc)
  - Lines 325-457: `parametric_shifted_truth_lemma` (SORRY-FREE given h_tc)
  - Lines 427-436: G backward case requires `h_tc` (family-level temporal coherence)
- `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic/Bundle/CanonicalTaskRelation.lean`
  - `CanonicalTask` relation: sorry-free n-step chain tracking via Succ

### Key Mathematical Insight

The algebraic approach provides everything needed EXCEPT family-level temporal coherence.
The `BFMCS_Bundle` machinery is sorry-free and provides bundle-level coherence.
The gap is the `temporal_backward_G` step in the truth lemma, which requires a same-family
F-witness that bundle-level coherence cannot supply.

The CanonicalTask relation does not help because it tracks Succ-reachability, not the
presence of specific formulas in intermediate nodes. The sub-case (b) obstacle (F(phi)
at negative time needing phi in the same chain at a later time) is not resolved by knowing
the chain geometry — the content of intermediate MCSes is what matters.
