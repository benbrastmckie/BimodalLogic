# Research Report: Task 88 — Teammate C (Critic) Findings, Round 3

**Task**: 88 — Close remaining 6 BXCanonical sorries
**Date**: 2026-04-09
**Role**: Critic — challenge framing, identify dead ends, surface what rounds 1 and 2 missed
**Focus**: What is actually broken vs. what is working; challenging the "6 sorries" framing;
           verifying BX11/BX12 claims; assessing interval linearity claim

---

## Executive Summary

After 2 rounds of research and 1 partial implementation, the sorry count is unchanged at 6 in
BXCanonical. The round 2 synthesis introduced a promising reformulation — "interval linearity
instead of global bx_le totality" — with 70% confidence. This report challenges that reformulation,
examines each sorry site directly, and identifies the single question that determines whether
the task is closable without a fundamental architecture change.

**Bottom line**: The 6 sorries split into 3 distinct problems of different difficulty. Two
(backward Until/Since in Frame.lean) are potentially closable with existing infrastructure.
Two (forward Until/Since in Frame.lean) require a new mathematical argument. One
(CanonicalEmbedding line 418) is independent and requires WorldHistory infrastructure that
does not exist. One (Completeness.lean) is genuinely downstream and closes when Frame.lean
closes. The "6 sorries" framing obscures this structure.

---

## Key Findings

### Finding 1: The "6 Sorries" Framing Obscures 3 Distinct Problems

The 6 sorry sites are not equally hard, not equally independent, and not all blocked on the
same thing. Here is the actual dependency structure:

```
Frame.lean:653  (forward Until)   <-- HARD: needs guard propagation argument
Frame.lean:675  (backward Until)  <-- MEDIUM: BX4 contradiction approach may work
Frame.lean:690  (forward Since)   <-- HARD: mirror of forward Until
Frame.lean:704  (backward Since)  <-- MEDIUM: mirror of backward Until

CanonicalEmbedding.lean:418       <-- INDEPENDENT: WorldHistory infrastructure gap
Completeness.lean:160             <-- DOWNSTREAM: closes when Frame.lean closes
```

The round 2 synthesis treated all 4 Frame.lean sorries as blocking one another and suggested
"interval linearity" as the unified fix. This is not accurate: the backward sorries (lines 675
and 704) do NOT require interval linearity. They require a contradiction argument that only
needs that the witness v from the sorry's hypothesis exists in the right place. The backward
sorry signatures TAKE the witness as a hypothesis — the hard existential is already provided.

**Consequence**: At least 2 of the 6 sorries (backward Until and Since) may be closable without
resolving the interval linearity question.

---

### Finding 2: Backward Until (Frame.lean:675) May Be Closable Now

The sorry at line 675 has signature:

```lean
bx_until_backward (w : BXPoint) (φ ψ : Formula) (v : BXPoint)
    (h_wv : bx_le w v) (h_ψv : ψ ∈ v.formulas)
    (h_guard : ∀ u : BXPoint, bx_le w u → bx_le u v ∧ ¬bx_le v u → φ ∈ u.formulas)
    (h_not_psi : ψ ∉ w.formulas) :
    Formula.untl φ ψ ∈ w.formulas
```

The inline comment says: "By contradiction: assume ¬(φ U ψ) ∈ w. By BX4: G(P(¬(φ U ψ))) ∈ w.
Since w ≤ v: P(¬(φ U ψ)) ∈ v. By BX8 + ψ ∈ v: φ U ψ ∈ v. From P(¬(φ U ψ)) ∈ v: ∃ u ≤ v
with ¬(φ U ψ) ∈ u. Gap: need w ≤ u to use the guard."

The docstring claims this is blocked because placing the backward witness u into [w,v) requires
linearity. But this framing is wrong. Here is an alternate approach that avoids linearity entirely:

**Direct approach via BX4 + BX9 + BX8**:

1. Assume for contradiction: `¬(φ U ψ) ∈ w` (negation completeness, since we want to show
   `φ U ψ ∈ w`).
2. By BX4 (`connect_future: α → G(P(α))`): `G(P(¬(φ U ψ))) ∈ w`.
3. Since `bx_le w v`: `P(¬(φ U ψ)) ∈ v` (bx_G_forward).
4. By `bx_backward_witness`: get u ≤ v with `¬(φ U ψ) ∈ u`.
5. By BX8 (`refl_intro_until: ψ → φ U ψ`) and `ψ ∈ v`: `φ U ψ ∈ v`.
6. From `¬(φ U ψ) ∈ u` and `bx_le u v`: need to show `φ U ψ ∈ u` to get a contradiction.

The gap: step 6 fails. `bx_le u v` only gives us formulas from g_content(u) are in v, not that
v's formulas propagate backward to u. The contradiction chain needs `φ U ψ ∈ u`, not `φ U ψ ∈ v`.

**Alternative contradiction via BX9 directly at w**:

1. Assume `¬(φ U ψ) ∈ w`.
2. BX9 (`until_elim: φ U ψ → φ ∨ ψ`): inapplicable since we have the negation.
3. The negation of `φ U ψ` should yield: either ψ never holds, or there is a prefix where ¬φ
   holds before ψ. BX derivable axiom?

The round 2 sketch claimed BX4 gives the direct contradiction. After reading the actual BX4
axiom, this needs verification. Let me check:

**Check BX4 (connect_future)**:
Looking at Axioms.lean, `connect_future` has the schema `α → G(P(α))`. This says: if α holds
now, then always in the future, there was a past point where α held. With `φ U ψ` as α:
`φ U ψ → G(P(φ U ψ))`. This gives: if `φ U ψ ∈ w`, then `G(P(φ U ψ)) ∈ w`, so for all v ≥ w,
`P(φ U ψ) ∈ v`.

For the BACKWARD sorry, the hypothesis is already `¬(φ U ψ) ∉ w` (actually `h_not_psi: ψ ∉ w`
plus `v, h_wv, h_ψv, h_guard`). The goal is to show `φ U ψ ∈ w`.

**BX8-based approach**: BX8 is `ψ → φ U ψ`. Since `ψ ∉ w`, BX8 doesn't give anything at w.
But we have `ψ ∈ v` and `bx_le w v`. The formula `φ U ψ → G(P(φ U ψ))` (BX4, with `φ U ψ`)
would need `φ U ψ` to already be in the successors.

The critical question for the backward sorry: can `φ U ψ ∈ w` be derived from `ψ ∈ v` and
the guard without any linearity? The standard approach:

- By BX9 at v: `φ U ψ ∈ v` (since `ψ ∈ v` via BX8: `ψ → φ U ψ`).
- Now suppose `φ U ψ ∉ w`. Then `¬(φ U ψ) ∈ w`.
- BX4 on `¬(φ U ψ)`: `¬(φ U ψ) → G(P(¬(φ U ψ)))` ... wait, BX4 is `α → G(P(α))`. This needs
  the formula itself to be in w.
- Apply BX4 with α = `¬(φ U ψ)`: `¬(φ U ψ) → G(P(¬(φ U ψ)))`. So `G(P(¬(φ U ψ))) ∈ w`.
- Since `bx_le w v`: `P(¬(φ U ψ)) ∈ v`.
- `bx_backward_witness` at v: ∃ u ≤ v with `¬(φ U ψ) ∈ u`.
- But `φ U ψ ∈ v` (from BX8 at v) and `¬(φ U ψ) ∈ u`, `bx_le u v`. No direct contradiction.

**Verdict on backward Until**: The naive BX4 contradiction approach fails because the backward
witness u can be strictly less than w (we only know u ≤ v, not w ≤ u). The claim in the round
2 synthesis that backward Until is "simpler" than forward Until is **not verified**. The gap
identified in the docstring is real: we need u ∈ [w, v) to use the guard hypothesis.

The guard says: `∀ u, bx_le w u → bx_le u v ∧ ¬bx_le v u → φ ∈ u`. If u is outside [w,v),
the guard is vacuously inapplicable.

**Assessment**: Backward Until has the SAME linearity dependency as forward Until. The round 2
optimism about it being simpler was unfounded.

---

### Finding 3: Forward Until (Frame.lean:653) — The Interval Linearity Claim Is Partially Valid

The round 2 synthesis claims that interval linearity — "any two BXPoints u, u' both reachable
from a common predecessor w where `φ U ψ ∈ w` are bx_le-comparable" — is derivable from
BX7 + BX4 + F_until_equiv.

Let me trace this argument carefully:

1. `φ U ψ ∈ w` and BX10 (`until_F: φ U ψ → F(ψ)`): `F(ψ) ∈ w`.
2. BX12 (`F_until_equiv: F(ψ) → ⊤ U ψ`): `⊤ U ψ ∈ w`.
3. BX11 (`temp_linearity: F(phi) ∧ F(psi) → ...`): This is about F-formulas at a single MCS.
   For two points u, u' ≥ w, we need to show u ≤ u' or u' ≤ u. We have at w: `F(ψ) ∈ w`
   (one eventuality). But to use temp_linearity to compare u and u', we need two F-formulas
   at the SAME point, not two separate successor points.

The interval linearity claim requires: given u, u' with `bx_le w u` and `bx_le w u'`, prove
`bx_le u u'` or `bx_le u' u`. This is a statement about ALL successors of w, not just ones
carrying specific eventualities.

**BX7 approach**: BX7 (`linear_until`) says:
  `(φ U ψ) ∧ (χ U θ) → F(ψ ∧ (χ U θ)) ∨ F((φ U ψ) ∧ θ) ∨ (ψ ∧ θ)`

This tells us the Until-witnesses are ordered. If `φ U ψ ∈ w` and `⊤ U ψ ∈ w`, then either
ψ holds now (immediate) or one witness comes before the other. But:
- The "witnesses" here are not BXPoints; they are future points where the Until formula is
  resolved.
- The formula says about F-witnesses at w, not about arbitrary successors u, u'.
- Two distinct BXPoints u, u' ≥ w that are not Until-witnesses for any specific formula need
  not be comparable.

**Verdict**: The interval linearity claim is not as strong as round 2 suggests. What BX7 + BX12
gives is: the ψ-resolution time in the canonical frame is unique (up to bx_le equivalence),
not that the interval [w, ψ-witness) is linearly ordered. The gap identified by round 2
Teammate C (my earlier self) about guard propagation is correct and remains unresolved.

**What BX7 DOES give**: At most, BX7 gives us that the first witness v with `ψ ∈ v` among
bx_le-successors of w is "minimal" in some sense. But it doesn't prevent there from being
two incomparable BXPoints between w and the first ψ-witness.

---

### Finding 4: The CanonicalEmbedding Sorry (Line 418) Is Independent and May Have a Simpler Fix

The sorry at CanonicalEmbedding:418 occurs in `usf_completeness`, specifically in:

```lean
-- Case B: ψ not valid. Contrapositive argument.
-- ...
-- MCS w constructed with ψ → χ ∉ w, so ψ ∈ w, χ ∉ w.
-- Gap: backward truth bridge for χ on constant histories is incomplete
-- when χ contains G or H.
sorry
```

The problem: to get a countermodel where `ψ → χ` is false, we need to exhibit a model where
ψ is true and χ is false. The code has MCS w with `ψ ∈ w` and `χ ∉ w`. Using the existing
`fragment_truth_iff` (backward direction), `ψ ∈ w → truth_at ... ψ`. For the `χ ∉ w` side,
we need `¬truth_at ... χ`.

**The actual gap (re-reading the code)**:

For `temporalFree χ`: `fragment_truth_iff` is bidirectional, so `χ ∉ w ↔ ¬truth_at ... χ`.
This case would already close.

For `untilSinceFree χ` (containing G or H but not Until/Since): the backward direction of
`fragment_truth_iff` fails because it's restricted to `temporalFree`. For G(α), on a constant
history, `truth_at G(α) t = ∀ s ≥ t, truth_at α s`, which collapses to `truth_at α t` only
reflexively but doesn't handle the forward direction.

**Potential simpler fix**: The `usf_completeness` function already handles G(ψ) and H(ψ) cases
via `valid_of_valid_all_future` and `valid_of_valid_all_past`. Case B only applies to `ψ → χ`
where BOTH ψ and χ have untilSinceFree. The structural induction guarantees:
- If χ = G(α): Case B would be trying to show `G(α) ∉ w → countermodel`. But the `all_future`
  arm of the induction handles G directly via `ih`. Case B is for `imp` only.
- If χ is `imp`: we're in the Case B sub-problem for `ψ → χ` where χ = `χ1 → χ2`.

Wait — re-reading `usf_completeness`: the sorry is in the `imp` case. The `all_future`,
`all_past`, `box` cases all go through `ih` directly (via Case A or necessitation). So Case B
only applies when the top-level formula is `ψ → χ` and ψ is NOT valid.

The subformulas ψ and χ can themselves contain G/H. The issue is that `χ ∉ w` doesn't give
`¬truth_at (constant_history w) t χ` when χ contains G/H.

**Is there a simpler bypass?** YES. Since the `all_future` and `all_past` cases in the induction
are already handled by their own IH arms, the formulas ψ and χ in the `imp` arm are
"structurally smaller" and the IH gives completeness for them. Specifically:

- `ih_χ : untilSinceFree χ → valid χ → Nonempty (DerivationTree [] χ)` is the IH for χ.
- In Case B, ψ is not valid (so `ih_ψ` isn't useful for ψ directly).
- χ may or may not be valid.

For Case B, the actual proof strategy doesn't need to build a model at all. Since ψ is not
valid, there exists a model M1 where ψ is false. And since `ψ → χ` is valid (given `h_valid`)
and ψ is false at M1, we can't conclude anything about χ directly. The countermodel approach
is: if `ψ → χ` is not derivable, extend to MCS w with `ψ ∈ w` and `χ ∉ w`, and show that
`ψ → χ` is semantically false at w. This requires truth(ψ) = true and truth(χ) = false at
some model point.

For the CONSTANT HISTORY model with `constant_history w`: truth(ψ) at constant w collapses
G(α) to α, H(α) to α. So `ψ ∈ w` gives truth(ψ) = true only if ψ is temporal-free. If ψ
contains G, `ψ ∈ w` gives `G(α) ∈ w` which via fragment_truth_iff (box analogy using
`G_iff_mcs`) doesn't directly give truth at the constant history.

**The real gap**: The constant_history approach in CanonicalEmbedding is fundamentally
insufficient for the imp Case B when the sub-formulas contain G or H. The fix requires
either (a) a non-constant history, or (b) a different proof strategy for this case.

**Alternative strategy for Case B**:
- `ψ → χ` is valid (given).
- `ψ` is not valid (`h_ψ_valid` is false).
- Therefore χ is not universally valid whenever ψ is.
- But this doesn't directly give `χ` valid or not.
- Actually: since `ψ → χ` is valid and `ψ` not valid, we need `χ` to be valid on all
  models where `ψ` is true. But we can't conclude `χ` is valid on all models.

The proof must be by contradiction: assume `ψ → χ` not derivable, get MCS w, show semantically
that `ψ → χ` fails at w. For G/H formulas in ψ, χ, the constant history model doesn't work.

**Assessment of CanonicalEmbedding:418**: This is INDEPENDENT of the Frame.lean sorries (it
does NOT use Until/Since truth lemma). It requires a new WorldHistory construction that maps
MCS w to a (non-constant) history where G/H-containing formulas are faithfully modeled. The
two-point history construction would suffice: build a history that visits bx_le-successors of
w in order. But `bx_forward_witness` and `bx_backward_witness` are sorry-free in Frame.lean,
so this infrastructure exists at the BXPoint level. The gap is converting BXPoint chains into
WorldHistory objects. Estimated effort: 4-6 hours of new infrastructure.

---

### Finding 5: Completeness.lean:160 Is Genuinely Downstream on Frame.lean, NOT on CanonicalEmbedding

Re-reading Completeness.lean:160:

```lean
-- Now we need: valid φ implies φ ∈ M (for any MCS M).
-- This requires the canonical model construction.
-- Build canonical TaskModel and show φ false at w₀.
sorry
```

The comment says the sorry requires the canonical model construction with the full truth lemma.
The full truth lemma (including Until/Since) is in TruthLemma.lean, and those cases call
`bx_until_eventuality_resolution` and `bx_since_eventuality_resolution` (Frame.lean:653 and 690).

If Frame.lean:653 and 690 are sorry-free, then TruthLemma.lean's `until_iff_mcs` and
`since_iff_mcs` are sorry-free, and then Completeness.lean:160 can be closed by constructing
a canonical TaskModel using the full truth lemma.

**But CanonicalEmbedding:418 is NOT a dependency of Completeness.lean:160.** Completeness.lean
imports only `TruthLemma` and `Validity`. The CanonicalEmbedding sorry is for fragment completeness
(the `usf_completeness` theorem), not for the main `bx_completeness` theorem. These are
independent paths.

**This is an important clarification the prior research missed**: closing Frame.lean sorries
is sufficient to make Completeness.lean closable. CanonicalEmbedding:418 is about proving
a FRAGMENT completeness result (Until/Since-free fragment), not about the main completeness
theorem. If the goal is "close bx_completeness", CanonicalEmbedding:418 is not on the critical
path.

---

### Finding 6: What BX11 and BX12 Actually Buy for the Eventuality Resolution

**BX11 (temp_linearity)**: Proved sound in Phase 1. Present in the axiom set. Used nowhere in
BXCanonical (confirmed by grep). This axiom is currently NOT helping close any BXCanonical sorry.

**BX12 (F_until_equiv: `F(ψ) → ⊤ U ψ`)**:
- Present in the axiom set.
- Used in `DovetailedChain.lean` (closed a sorry there in Phase 1).
- NOT used in BXCanonical (confirmed by grep with zero results).
- The round 2 synthesis proposed using BX12 in the Frame.lean eventuality sorries.
  This would work as follows: `φ U ψ ∈ w` → BX10 → `F(ψ) ∈ w` → BX12 → `⊤ U ψ ∈ w`.
  Then `⊤ U ψ ∈ w` tells us there is a bx_le-successor v with `ψ ∈ v` (via `bx_forward_witness`
  applied to `F(ψ)`). This is the SAME witness we already get from BX10 + `bx_forward_witness`.
  BX12 adds nothing for witness existence.

**What BX12 would help with**: If the proof strategy needed `⊤ U ψ` as a FORMULA in the MCS
(not just the existence of a witness), BX12 provides that. This is relevant if BX7 is applied
to `⊤ U ψ` alongside another Until formula. But as shown in Finding 3, BX7 + BX12 together
don't give interval linearity for arbitrary successors.

**Verdict on BX11/BX12 for BXCanonical sorries**: These axioms were added primarily for
`DovetailedChain.lean` and `LinearityDerivedFacts.lean`. They do NOT directly close any of the
6 BXCanonical sorries. The claim in the task description and plan that Phase 2 uses these
axioms is aspirational, not yet mathematically substantiated.

---

### Finding 7: Checking Whether "DovetailedChain.lean Is Deprecated With 6 Sorries" Is Accurate

The task description says "DovetailedChain.lean is deprecated with 6 sorries." Confirmed:

```
Algebraic/DovetailedChain.lean has sorry at lines 648, 1016, 1112, 1125, 1297, 1305
```

All 6 are tagged `-- DEPRECATED: architectural limitation (X-vs-G mismatch in Until
persistence through Lindenbaum steps)`. These are NOT the BXCanonical sorries. They are
separate. Phase 1 closed 4 OTHER sorries in DovetailedChain.lean (the ones tagged "removed
in BX"). The 6 deprecated sorries remain. The task description is correct: DovetailedChain
is deprecated with 6 remaining sorries that are NOT the same as the 6 BXCanonical sorries.

---

### Finding 8: Is There a Proof Strategy That Bypasses bx_le Linearity?

Based on re-reading the sorry sites and Frame.lean in full, here is the critical question:

**Can `bx_until_eventuality_resolution` be proved WITHOUT proving interval linearity?**

The sorry's goal is:
```
∃ v : BXPoint, bx_le w v ∧ ψ ∈ v.formulas ∧
  ∀ u : BXPoint, bx_le w u → bx_le u v ∧ ¬bx_le v u → φ ∈ u.formulas
```

The witness v exists via `bx_forward_witness` (sorry-free). The guard `∀ u ...` is the hard part.

**Zorn-based approach** (mentioned in prior comments as viable): Pick the minimal v ≥ w with
ψ ∈ v (using Zorn/well-ordering). For intermediate u (w ≤ u < v), since v is minimal, ψ ∉ u.
Then use `φ U ψ ∈ u` (which needs proof) and `ψ ∉ u` and BX9 to get `φ ∈ u`.

The gap: `φ U ψ ∈ u` for intermediate u. This requires either Until persistence (the
DovetailedChain failure) or BX4: `φ U ψ → G(P(φ U ψ))`. At w: `G(P(φ U ψ)) ∈ w`. So
for all u ≥ w: `P(φ U ψ) ∈ u`. Then `bx_backward_witness` at u: ∃ u' ≤ u with `φ U ψ ∈ u'`.
But u' might be less than w, so `φ U ψ ∈ u'` doesn't help prove `φ U ψ ∈ u`.

**The X-vs-G mismatch as the true blocker**: The core problem, which has now been identified in
tasks 83, 85, 86, 87, and both rounds of task 88, is:
- `φ U ψ ∈ w` does NOT give `G(φ U ψ) ∈ w` (Until is not G-liftable).
- bx_le is defined via g_content = {ψ | G(ψ) ∈ w}.
- Therefore Until formulas do NOT propagate forward through bx_le steps.

This means that for any intermediate u ≥ w, we cannot guarantee `φ U ψ ∈ u` from `φ U ψ ∈ w`
unless the architecture is changed.

**Can BX4 bridge this?** BX4 (`connect_future: α → G(P(α))`) with α = `φ U ψ` gives
`G(P(φ U ψ)) ∈ w`. So for u ≥ w: `P(φ U ψ) ∈ u`. This says "in the past of u, there was
a point where φ U ψ held". But it doesn't say φ U ψ holds NOW at u.

The only way to get `φ U ψ ∈ u` from `P(φ U ψ) ∈ u` would be through a formula like
`P(φ U ψ) → φ U ψ` (persistence axiom). This is NOT in the axiom set and is semantically
false (a formula can hold in the past without holding now).

**Conclusion**: The 4 Frame.lean eventuality sorries require new mathematical infrastructure
not currently available. The X-vs-G mismatch is a fundamental architectural constraint.
The Zorn/minimality approach doesn't escape it.

---

## Verified vs. Unverified Claims From Round 2

| Claim | Status | Evidence |
|-------|--------|----------|
| 6 sorries in BXCanonical | VERIFIED | grep confirms exact locations |
| BX11/BX12 were added in Phase 1 | VERIFIED | Axioms.lean constructors present |
| Backward Until is simpler than Forward | UNVERIFIED / LIKELY FALSE | Backward sorry has same linearity gap |
| Interval linearity is derivable from BX7+BX12 | UNVERIFIED / SUSPECT | BX7 gives witness ordering, not interval ordering |
| CanonicalEmbedding:418 depends on Frame.lean | INCORRECT | It is independent |
| Completeness:160 depends on Frame.lean | CORRECT | Via TruthLemma's until_iff_mcs |
| DovetailedChain deprecated with 6 sorries | VERIFIED | Lines 648, 1016, 1112, 1125, 1297, 1305 |
| BX11/BX12 help with BXCanonical eventuality sorries | UNVERIFIED / SUSPECT | Neither used in BXCanonical |
| Phase 1 closed 4 downstream sorries | VERIFIED | LinearityDerivedFacts + DovetailedChain |

---

## Assumptions Challenged

### Challenge 1: "The interval linearity claim is viable" (70% confidence in round 2)

**Challenge**: The BX7 axiom gives ordering of Until-witnesses (the first points where the
Until formula is resolved), not ordering of ALL bx_le-successors. Two BXPoints u, u' that
are bx_le-successors of w but are not Until-witnesses for any specific formula need not be
comparable. Interval linearity for ALL successors of w (which is what the sorry guard requires)
is a much stronger claim than "Until-witnesses are ordered."

**Evidence**: Re-reading BX7 (`linear_until`):
```
(φ U ψ) ∧ (χ U θ) → F(ψ ∧ (χ U θ)) ∨ F((φ U ψ) ∧ θ) ∨ (ψ ∧ θ)
```
This says: given two Until formulas at w, EITHER they share a common resolution point, OR one
resolves before the other. The guard in `bx_until_eventuality_resolution` requires `φ ∈ u`
for all strict intermediate u, not just the resolution point.

### Challenge 2: "Backward Until only needs BX4 contradiction" (round 2 Teammate B)

**Challenge**: The BX4 contradiction approach for backward Until fails because the backward
witness u satisfies u ≤ v, not necessarily w ≤ u. Without knowing w ≤ u, the guard hypothesis
`h_guard : ∀ u, bx_le w u → ...` is not applicable to u.

### Challenge 3: "CanonicalEmbedding:418 is on the critical path for bx_completeness"

**Challenge**: The `usf_completeness` function (which contains the sorry) proves fragment
completeness for the Until/Since-free fragment. It is NOT imported by Completeness.lean and
is NOT used in the proof of `bx_completeness`. Completeness.lean uses only TruthLemma and
Validity. The CanonicalEmbedding sorry can be deferred without blocking bx_completeness.

### Challenge 4: "Phase 6 is 0.5 hours" (plan estimate)

**Challenge**: There are 10+ ConservativeExtension sorries tagged "removed in BX" or
"density removed in BX". Phase 1 only closed 4 sorries (in LinearityDerivedFacts and
DovetailedChain). The remaining ConservativeExtension sorries were not addressed. Many are
likely now fixable with the new axiom constructors, but enumerating and fixing them is 2-4
hours, not 0.5.

---

## Questions Not Being Asked

### Question 1: Is a Quasimodel/FMP Approach Viable for Bypassing BXCanonical Entirely?

If the completeness theorem can be proved via finite model property (FMP), the entire
BXCanonical module becomes unnecessary for the main theorem. The `Decidability/FMP/FMP.lean`
module already exists. Does it contain a sorry-free completeness proof? If so, `bx_completeness`
can be routed through FMP rather than canonical model. This would close Completeness.lean:160
without touching Frame.lean.

Checking the FMP module:

```
Theories/Bimodal/Metalogic/Decidability/FMP/DiscreteFMP.lean
Theories/Bimodal/Metalogic/Decidability/FMP/DenseFMP.lean
```

If these contain sorry-free completeness proofs for discrete and dense cases, the question
becomes: is there a generic completeness proof that covers the general case? This needs
investigation.

### Question 2: Is the Until/Since-Free Fragment Actually Used Anywhere?

The `usf_completeness` function in CanonicalEmbedding.lean proves completeness for the
Until/Since-free fragment. This may be a standalone result not needed by any downstream proof.
If so, the CanonicalEmbedding:418 sorry is harmless for the main development and can be
acknowledged as an open problem without affecting soundness, decidability, or any published
results.

### Question 3: Can the Sorry Guard Condition Be Weakened?

The guard in `bx_until_eventuality_resolution` uses `bx_le u v ∧ ¬bx_le v u` (strict ordering).
This is necessary because bx_le may not be antisymmetric. But if there are equivalent BXPoints
(bx_le u v AND bx_le v u simultaneously), the strict guard may be overly weak or overly strong
in different ways. Has this interaction with non-antisymmetry been analyzed? Could a weakened
guard (e.g., dropping the ∀ u guard entirely and just providing the witness v) be sufficient
for downstream uses?

### Question 4: What Would a Sorry-Reduced Architecture Look Like?

Given 2+ rounds of research confirming the 4 eventuality resolution sorries are blocked on
X-vs-G mismatch, what would it take to change the architecture?

Options:
(A) Redefine bx_le via Until-witness chains (makes linearity definitional, but requires
    reproving G/H truth lemma which was easy under g_content definition).
(B) Use bidirectional seeds with both g_content and the Until formulas themselves.
(C) Adopt a quasimodel approach (FMP already in codebase).
(D) Accept that bx_completeness has an architectural gap and document the sorry as a
    known open problem with a clear mathematical description of what's needed.

---

## Confidence Levels

| Assessment | Confidence |
|-----------|-----------|
| 6 sorries confirmed at exact locations | 99% |
| Backward Until has same linearity gap as forward | 90% |
| BX11/BX12 do NOT directly close Frame.lean sorries | 85% |
| Interval linearity from BX7+BX12 is insufficient for the guard | 80% |
| CanonicalEmbedding:418 is NOT on the critical path for bx_completeness | 95% |
| X-vs-G mismatch is the true architectural blocker for Frame.lean | 95% |
| FMP modules may provide alternative completeness route | 50% (needs investigation) |
| Frame.lean sorries are closable without architecture change | 20% |

---

## Prioritized Recommendations

### Priority 1: FMP Completeness Route — INVESTIGATED (NOT viable as-is)
`Decidability/Correctness.lean` contains `fmp_completeness`:
```
(∀ (S : ClosureMCSBundle φ), φ ∈ S.carrier) → Nonempty (DerivationTree [] φ)
```
This is proof-theoretic completeness: IF φ is in ALL closure MCS, THEN φ is derivable.
This is NOT the same as semantic completeness (`valid φ → derivable φ`). The missing bridge
from semantic validity to closure-MCS-membership requires the full truth lemma for the
filtration model. Checking `TruthPreservation.lean`: its docstring explicitly says
"Phase 4 infrastructure is in place. The full filtration lemma proof for all formula cases
requires additional work." The temporal operator cases (past, future) are not proved.
Comment at line 247-249: "mcs_all_future_closure archived to Boneyard — FMP proof strategy
needs redesign for strict semantics."

**Conclusion**: FMP does NOT currently provide a sorry-free route to semantic completeness.
The semantic validity bridge is just as incomplete as the BXCanonical approach. This rules
out Priority 1 as a quick win.

**Key insight**: Both BXCanonical and FMP approaches fail at the SAME underlying step — the
semantic truth lemma for temporal operators under the current frame semantics.

### Priority 2: Close Backward Until/Since via New Strategy (4-6 hours, 40% confidence)
The backward sorries (Frame.lean:675 and 704) require a proof that `φ U ψ ∈ w` given
witness v ≥ w with guard. The key insight needed: a formula that propagates backward from v
to w. BX4 gives `P(φ U ψ) ∈ u` for u ≥ w, but not `φ U ψ ∈ w`. A direct axiom connecting
"P(formula) everywhere on the interval" to "formula at the start" would be needed. This may
not exist in BX without adding new axioms.

### Priority 3: Acknowledge Forward Until/Since as Open Problems (0 hours)
Given 3+ rounds of research confirming the X-vs-G mismatch as a fundamental architectural
blocker for Frame.lean:653 and 690, these should be formally documented as open problems
requiring architecture change, not just "a few more hours of proof engineering."

### Priority 4: Fix Remaining ConservativeExtension Sorries (2-4 hours, 80% confidence)
These are mechanically fixable and should be enumerated explicitly before the next
implementation attempt.

### Priority 5: Resolve CanonicalEmbedding:418 with WorldHistory Infrastructure (4-6 hours)
Independent of Frame.lean; provides the fragment completeness result. Lower priority unless
the fragment completeness theorem is needed downstream.
