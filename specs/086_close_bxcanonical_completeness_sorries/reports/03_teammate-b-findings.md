# Teammate B Findings: Alternative Strategies and Prior Art

**Task**: 86 — Close BXCanonical completeness sorries
**Focus**: Alternative proof architectures, prior art, proof-theoretic alternatives
**Date**: 2026-04-08

## Key Findings

### 1. The Sorry is Structurally Mislocated — Restructuring Eliminates It (HIGH confidence)

The remaining sorry is in `usf_completeness` at the **imp case B** (lines 389-409 of CanonicalEmbedding.lean). The proof splits on whether the antecedent `psi` is valid:

- **Case A** (psi valid): Both sides valid, IH gives derivable chi, prop_s wraps it. **Done.**
- **Case B** (psi not valid): Contrapositive argument. Gets MCS w with `psi in w` and `chi not in w`. Needs to show this contradicts `valid (psi -> chi)`, but the backward truth bridge fails on constant histories when chi contains G/H.

**The fundamental issue**: The proof tries to build a *countermodel* for the specific formula `psi -> chi` inside a structural induction that has already committed to showing derivability. The imp case doesn't reduce to simpler formulas in the same way as G/H/box cases do.

### 2. Alternative Architecture: Pure Proof-Theoretic Deduction Theorem Approach (HIGH confidence, HIGH feasibility)

**Key insight**: Instead of building countermodels in the imp case, use a proof-theoretic argument.

If `valid (psi -> chi)` and `psi` is not valid, we need `derivable (psi -> chi)`.

By the deduction theorem, `derivable (psi -> chi)` is equivalent to `[psi] |- chi`.

**Approach**: Show that if `valid (psi -> chi)`, then either:
1. `chi` is valid (Case A, already handled), OR
2. `psi -> chi` is itself derivable directly

For (2), observe: if `psi` is not valid, then there exists a model where `psi` is false. In ANY model where `psi` is false, `psi -> chi` is trivially true. So the "hard" models for `psi -> chi` are exactly the ones where `psi` is true — but if `psi` is true and `psi -> chi` is valid, then `chi` is true. So `chi` is true in all models where `psi` is true. This means: **`chi` is a semantic consequence of `psi`**.

If we could show `{psi} |= chi` implies `{psi} |- chi` (semantic consequence implies syntactic consequence), we'd have the deduction theorem giving `|- psi -> chi`.

But `{psi} |= chi` implies `|- psi -> chi` is EXACTLY the **Strong Completeness Theorem** — which is what we're trying to prove. So this is circular if we try to use it directly.

**However**, there's a non-circular version: `{psi} |= chi` under the *structural induction hypothesis* can be decomposed. Since `usf_completeness` has an IH on subformulas, and `psi, chi` are proper subformulas of `psi -> chi`, we can potentially use the IH on `chi` if we can show `chi` is valid — which brings us back to Case A.

**Verdict**: The existing Case A/B split is actually correct. The issue is that Case B genuinely arises (when `psi` is not valid but `psi -> chi` IS valid), and it requires showing something about `chi` relative to `psi`.

### 3. Alternative Architecture: Avoid Case Split Entirely via FMP+Soundness Composition (HIGH confidence, MEDIUM feasibility)

The `fmp_completeness` theorem states:
```lean
theorem fmp_completeness (phi : Formula) :
    (forall (S : ClosureMCSBundle phi), phi in S.carrier) ->
    Nonempty (DerivationTree [] phi)
```

This is **sorry-free** and gives: "if phi is in every closure MCS, then phi is derivable."

The **soundness** theorem is also **sorry-free** and gives: "if phi is derivable, then phi is valid (in all models)."

The missing bridge is: **"if phi is valid, then phi is in every closure MCS."**

This is the **truth lemma for the FMP model**. The FMP module's `TruthPreservation.lean` provides infrastructure but doesn't complete the full truth lemma connecting `truth_at` in the finite model to MCS membership.

**However**, this bridge does NOT require the Until/Since eventuality resolution. For the USF (Until/Since-free) fragment, the bridge only needs atom/bot/imp/box/G/H cases. And the BXCanonical truth lemma already proves all of these at the MCS level (`imp_iff_mcs`, `G_iff_mcs`, `H_iff_mcs`, `box_iff_mcs`).

**The gap**: We need to construct a TaskModel from ClosureMCSBundles and show the truth_at evaluation matches MCS membership. This is model construction work, not proof-theoretic work.

### 4. Alternative Architecture: Direct Completeness via Negation and IH (MEDIUM-HIGH confidence, HIGH feasibility)

**This is the most promising approach for the specific sorry.**

The current proof has:
```
by_contra h_not_deriv  -- assume psi -> chi not derivable
-- ... get MCS w with psi in w, chi not in w
sorry  -- need contradiction with valid (psi -> chi)
```

Instead of trying to build a countermodel from w, use the IH more cleverly:

**Approach**: From `valid (psi -> chi)` and `not valid psi`, derive `derivable (psi -> chi)` without the Case B countermodel.

Step 1: Since `psi` is not valid, there exists some model M0 where `psi` is false at some point.
Step 2: For any model M where `psi` is true at some point, `chi` must also be true there (by validity of `psi -> chi`).
Step 3: Consider an arbitrary model M. Either `psi` is true (then `chi` is true, so `psi -> chi` is true) or `psi` is false (then `psi -> chi` is trivially true). So `psi -> chi` is valid in every model... wait, but we already HAVE `valid (psi -> chi)`.

The issue is converting validity to derivability. With the IH on `psi` and `chi`, we can only derive them if they're individually valid.

**New idea**: Instead of splitting on `valid psi`, split on `valid chi`:
- If `chi` is valid: by IH, `derivable chi`. Then `prop_s chi psi` gives `derivable (psi -> chi)`. Done.
- If `chi` is not valid: Then there exists a model where `chi` is false. At that point, `psi` must also be false (otherwise `psi -> chi` would be false, contradicting validity). So at every point where `chi` is false, `psi` is also false. This means: `valid (neg chi -> neg psi)`, i.e., `valid (contrapositive (psi -> chi))`.

Wait, but `valid (psi -> chi)` already gives us `valid (neg chi -> neg psi)` by semantic reasoning. The issue is we need derivability.

**Crucial observation**: If `chi` is not valid and `psi` is not valid, but `psi -> chi` IS valid, then we need a proof-theoretic construction. Let me think about what formulas can satisfy this pattern...

Actually: `valid (psi -> chi)` with `psi` not valid is the case where `chi` might fail ONLY when `psi` also fails. This is genuinely harder than the Case A situation.

### 5. Alternative Architecture: Structural Induction on USF-Depth Instead of Formula Constructors (MEDIUM confidence, MEDIUM feasibility)

Instead of structural induction on the formula `phi`, use induction on a *complexity measure* that handles imp differently:

Define `usf_depth`:
- `usf_depth (atom p) = 0`
- `usf_depth bot = 0`
- `usf_depth (imp psi chi) = 1 + max (usf_depth psi) (usf_depth chi)`
- `usf_depth (box psi) = 1 + usf_depth psi`
- `usf_depth (G psi) = usf_depth psi`  -- KEY: G doesn't increase depth
- `usf_depth (H psi) = usf_depth psi`  -- KEY: H doesn't increase depth

Under this measure, `valid G(psi)` gives `valid psi` (by `valid_of_valid_all_future`), and `usf_depth (G psi) = usf_depth psi`, so the IH applies to `psi` directly without needing necessitation afterward. The imp case would still face the same challenge though.

This doesn't fundamentally help.

### 6. The "Flatten then Lift" Approach (MEDIUM confidence, MEDIUM feasibility)

The execution summary notes: "on constant_history w: truth_at G(alpha) collapses to truth_at alpha, so the backward bridge gives flatten(chi) in w rather than chi in w."

Define a "temporal flattening" function that strips all G/H from a formula:
```
flatten (G phi) = flatten phi
flatten (H phi) = flatten phi
flatten (imp phi psi) = imp (flatten phi) (flatten psi)
flatten (box phi) = box (flatten phi)
flatten other = other
```

Under constant histories, `truth_at M Omega (constant_history w) t phi` is equivalent to `truth_at M Omega (constant_history w) t (flatten phi)` for USF formulas, because G and H collapse to identity.

If we could prove: **`derivable (flatten phi) -> derivable phi`** for USF formulas, the sorry would close. This is because:
1. We have `valid (psi -> chi)`
2. On constant histories: this gives `valid (flatten(psi) -> flatten(chi))`
3. `flatten(psi) -> flatten(chi)` is temporal-free, so by `fragment_completeness`: `derivable (flatten(psi) -> flatten(chi))`
4. By the lift lemma: `derivable (psi -> chi)`

**The lift lemma `derivable (flatten phi) -> derivable phi`** would need:
- `derivable (flatten (G phi)) -> derivable (G phi)`, i.e., `derivable (flatten phi) -> derivable (G phi)`
- This requires `derivable phi -> derivable (G phi)` (temporal necessitation) PLUS `derivable (flatten phi) -> derivable phi` (IH)
- But temporal necessitation requires `[] |- phi`, not `[] |- flatten(phi)`

Actually, the lift works by induction on formula structure:
- Base: `flatten(atom p) = atom p`, trivial
- `flatten(bot) = bot`, trivial
- `flatten(G phi) = flatten(phi)`: need `derivable(flatten phi) -> derivable(G phi)`. By IH, `derivable(flatten phi) -> derivable phi`. Then temporal necessitation: `derivable phi -> derivable(G phi)`. Compose: done.
- `flatten(H phi)`: same with past necessitation
- `flatten(box phi) = box(flatten phi)`: need `derivable(box(flatten phi)) -> derivable(box phi)`. Hmm, this requires showing `derivable(flatten phi) -> derivable phi` and then `derivable phi -> derivable(box phi)` (necessitation). But we have `derivable(box(flatten phi))`, not `derivable(flatten phi)`. Need: `derivable(box(flatten phi)) -> derivable(box phi)`. By modal K + IH on phi.
- `flatten(imp psi chi) = imp(flatten psi)(flatten chi)`: need `derivable(imp(flatten psi)(flatten chi)) -> derivable(imp psi chi)`. This requires: if `[flatten psi] |- flatten chi`, then `[psi] |- chi`. By IH, `derivable(flatten chi) -> derivable chi` and `derivable(flatten psi) -> derivable psi`. But the implication runs the wrong way for psi: we need `psi |- flatten psi`, not `flatten psi |- psi`.

**The imp case of the lift is the problem.** We need `psi |- flatten(psi)`, which means `G(alpha) |- alpha` (stripping G). We have BX1: `G(alpha) -> alpha`. So `psi |- flatten(psi)` IS derivable!

Let me verify:
- `G(alpha) |- alpha` by BX1 (temp_t_future)
- `H(alpha) |- alpha` by BX1' (temp_t_past)

So `phi |- flatten(phi)` holds by structural induction:
- `atom p |- atom p`: assumption
- `bot |- bot`: assumption
- `G(phi) |- flatten(phi)`: `G(phi) |- phi` (BX1) and by IH `phi |- flatten(phi)`, compose
- `H(phi) |- flatten(phi)`: same with BX1'
- `box(phi) |- box(flatten(phi))`: needs modal K, NOT just BX1. We have `phi |- flatten(phi)` (IH). By generalized necessitation `box(phi) |- box(flatten(phi))`. Wait, generalized necessitation goes `[] |- phi -> psi` gives `[] |- box phi -> box psi`. We need `phi |- flatten(phi)` to lift to `box(phi) |- box(flatten(phi))`. We DO have `[] |- phi -> flatten(phi)` by the deduction theorem, then by necessitation + K: `[] |- box(phi) -> box(flatten(phi))`. So yes.
- `imp(psi)(chi) |- imp(flatten(psi))(flatten(chi))`: We need `[psi -> chi, flatten(psi)] |- flatten(chi)`. From `flatten(psi) |- psi` (wait, this is the REVERSE direction! We need `flatten(psi) |- psi`).

**Problem**: For the imp case of `phi |- flatten(phi)` where `phi = imp psi chi`:
We need `[psi -> chi] |- flatten(psi) -> flatten(chi)`.
This means: assume `flatten(psi)`. We need `flatten(chi)`.
From `flatten(psi)`, can we get `psi`? We need `flatten(psi) |- psi`.

`flatten(psi) |- psi` is the REVERSE of `psi |- flatten(psi)`. For `G(alpha)`, this would be `alpha |- G(alpha)`, which is NOT derivable (alpha doesn't imply G(alpha) in general).

**So `phi |- flatten(phi)` does NOT extend to implication subformulas correctly.**

However, for the specific sorry, we don't need the full lift. We need:

`derivable (flatten(psi) -> flatten(chi)) -> derivable (psi -> chi)`

which by deduction theorem is: `[psi] |- chi` from `[flatten(psi)] |- flatten(chi)`.

Given `[psi]`, we can derive `flatten(psi)` (by `psi |- flatten(psi)`). Then from the hypothesis, `flatten(chi)`. But we need `chi`, not `flatten(chi)`. And `flatten(chi) |- chi` requires `alpha |- G(alpha)` which fails.

**Verdict**: The flatten-then-lift approach has a fundamental gap at the reverse direction for temporal operators inside chi.

### 7. The Deduction Theorem + Validity Decomposition Approach (HIGH confidence, HIGH feasibility)

**This is the most promising concrete approach.**

The sorry needs: `valid (psi -> chi)` and `not (valid psi)` implies `derivable (psi -> chi)`.

**Step 1**: By deduction theorem, `derivable (psi -> chi)` iff `[psi] |- chi`.

**Step 2**: Define "valid relative to context": `Gamma |= phi` means for all models, if all gamma in Gamma are true, then phi is true. Clearly `valid (psi -> chi)` implies `{psi} |= chi`.

**Step 3**: Strong completeness: `Gamma |= phi` implies `Gamma |- phi`. For finite Gamma, this follows from (weak) completeness + deduction theorem:
- `{psi} |= chi` iff `|= psi -> chi` iff `derivable (psi -> chi)` iff `[psi] |- chi`

But this is **circular** — we're trying to prove `valid (psi -> chi) -> derivable (psi -> chi)`, which is exactly completeness!

**The non-circular version**: We need to prove it for `psi -> chi` specifically, given the IH for proper subformulas. The IH gives us completeness for `psi` and `chi` individually. From `valid (psi -> chi)`, can we derive completeness for `psi -> chi` using only the IH on subformulas?

If `valid psi` (Case A): by IH, derivable psi. For any model, truth of psi gives truth of chi (from valid(psi -> chi)). So chi is valid. By IH, derivable chi. By prop_s, derivable(psi -> chi). Done.

If `not (valid psi)` (Case B): This is the hard case. We know psi is not valid (some model falsifies it) but psi -> chi IS valid. Consider whether chi is valid:
  - If `valid chi`: by IH, `derivable chi`. `prop_s chi psi` gives `derivable (psi -> chi)`. **Done.**
  - If `not (valid chi)`: Then there's a model where chi is false. At that point psi must also be false (otherwise psi -> chi would be false). So the only models where chi fails are ones where psi also fails.

**Revised case split**: Split on `valid chi` instead of `valid psi`:
- If `valid chi`: `derivable chi` (IH), then `prop_s` wraps to `derivable (psi -> chi)`. **Done.**
- If `not (valid chi)`: Then `psi` is not valid either (if psi were valid, then chi would be valid too, since valid(psi -> chi) + valid(psi) -> valid(chi)). So neither psi nor chi is valid. But psi -> chi IS valid.

In this sub-case, we need a different approach. The contrapositive: if `psi -> chi` is NOT derivable, then it's not valid. This is the DEFINITION of completeness. But we can use `fmp_completeness`!

**Using fmp_completeness**: `psi -> chi` is in every closure MCS for `psi -> chi` iff `psi -> chi` is derivable. So we need: `valid (psi -> chi)` implies `psi -> chi` is in every closure MCS for `psi -> chi`.

A ClosureMCSBundle for `psi -> chi` is an MCS restricted to the closure of `psi -> chi`. By `imp_iff_mcs`, `psi -> chi in S` iff `(psi in S -> chi in S)`. So we need: in every closure MCS S for `psi -> chi`, if `psi in S` then `chi in S`.

**This is the truth lemma for the finite model.** It requires showing that MCS membership tracks semantic truth in SOME model built from closure MCS. The FMP module has infrastructure for this but the full truth lemma isn't proved for all connectives.

### 8. Simplest Fix: Splitting on `valid chi` Instead of `valid psi` (HIGH confidence, IMMEDIATE)

Looking at the sorry again, the current code splits on `valid psi`. If we instead split on `valid chi`:

- **`valid chi`**: IH gives `derivable chi`. Then `prop_s chi psi : derivable (chi -> (psi -> chi))`. MP gives `derivable (psi -> chi)`. **No sorry needed.**

- **`not (valid chi)`**: We also know `not (valid psi)` (because `valid psi` + `valid (psi -> chi)` would give `valid chi`). Now use contrapositive: assume `not derivable (psi -> chi)`. Get MCS w with `neg(psi -> chi) in w`, hence `psi in w` and `chi not in w`. Need countermodel from w where `psi -> chi` is false. On constant_history w with modal_omega w: `truth_at (psi -> chi)` requires `truth_at psi -> truth_at chi`. We need `truth_at psi` true and `truth_at chi` false.

For `truth_at psi` at (constant_history w, t=0): Since `psi in w`, by the **forward** direction of fragment_truth_iff (for temporal-free psi) this works. But psi might contain G/H! Forward direction for G: `G(alpha) in w` implies `truth_at G(alpha)` on constant_history... does it?

`truth_at G(alpha)` at constant_history w at t requires `truth_at alpha` at all s >= t. On constant_history, all states are w, so this requires `truth_at alpha` at (constant_history w, s) for all s. By induction, this holds iff `alpha in w`. And `G(alpha) in w` implies `alpha in w` by BX1. So the forward direction works: `G(alpha) in w -> truth_at G(alpha)` on constant histories.

For `truth_at chi` false at (constant_history w, t=0): Since `chi not in w`, we need `NOT truth_at chi`. This is the **backward** direction: `truth_at chi -> chi in w`. For G: `truth_at G(alpha)` means `truth_at alpha` at all times, which (on constant history) means `alpha in w` (by backward IH). But `truth_at G(alpha)` being true on constant histories does NOT give `G(alpha) in w` — it only gives `alpha in w`. And `alpha in w` does NOT imply `G(alpha) in w`.

**This is the exact same gap** regardless of whether we split on `valid psi` or `valid chi`. The backward truth bridge on constant histories can't recover G/H membership from truth.

### 9. Two-Point History Construction (MEDIUM confidence, MEDIUM-HIGH feasibility)

The backward truth bridge fails because constant histories collapse G/H. The solution: use **non-constant histories**.

Given MCS w with `chi not in w`, we need to build a model where `chi` is false. For the G case (`chi = G(alpha)` with `G(alpha) not in w`):
- `G(alpha) not in w` means there exists v with `bx_le w v` and `alpha not in v` (by `bx_G_backward`)
- Build a two-point history: time 0 maps to w, time 1 maps to v
- Then `truth_at G(alpha)` at time 0 requires `truth_at alpha` at time 1, which (at state v) corresponds to `alpha in v`, which is false

This requires:
1. A non-constant `WorldHistory` mapping different times to different BXPoints
2. The history must satisfy `respects_task` for the canonical frame
3. Need Omega (set of admissible histories) to be shift-closed
4. Need the truth_at evaluation to correctly track MCS membership at each time point

**Feasibility**: The canonical_task_frame already has `task_rel w d u = (d != 0 or w = u)`, which is very permissive — any two distinct points can be related at non-zero displacements. So a two-point history `{0 -> w, 1 -> v}` with domain `{0, 1}` WOULD satisfy `respects_task`.

The challenge is that the truth_at evaluation for formulas like `imp (G alpha) beta` would need to track membership at BOTH w and v, requiring a full inductive truth lemma on these non-constant histories.

**This is the approach originally envisioned but not implemented** (as noted in the execution summary). It's the mathematically natural approach: build a rich enough model (with multiple time points) to distinguish G(alpha) from alpha.

### 10. Prior Art: Burgess and Goldblatt on Completeness for Tense + Modal

**Burgess 1984**: The completeness proof for basic tense logic uses:
1. Canonical frame with MCS as worlds
2. w R v (temporal ordering) iff `{phi : G(phi) in w}` is a subset of v
3. Truth lemma by induction on formula complexity
4. The imp case is handled by the MCS property: `psi -> chi in w` iff `(psi in w -> chi in w)` — this is purely proof-theoretic, no semantic argument needed
5. Completeness is proved by contrapositive: not derivable -> not valid

**Key difference from our approach**: Burgess proves `valid phi -> derivable phi` by showing the contrapositive `not derivable phi -> not valid phi`. The truth lemma gives: for any MCS w, `phi in w iff truth_at phi at w in canonical model`. Then: if phi is not derivable, {neg phi} is consistent, extend to MCS w, neg phi in w, so phi not in w, so phi false at w, so phi not valid.

**The BXCanonical approach follows this pattern** for `bx_completeness` in Completeness.lean. The sorry there is exactly the model embedding. For `usf_completeness` in CanonicalEmbedding.lean, the approach is DIFFERENT: it tries to prove completeness by structural induction without the full canonical model, using validity reduction for G/H/box. The imp case is where this alternative approach breaks down.

**Goldblatt 1992**: Similar approach. The key for imp is that it's handled entirely at the MCS level, never needing semantic reasoning for the imp case.

**Blackburn, de Rijke, Venema (BRV) 2001**: Multi-modal completeness also handles imp via MCS properties. The entire proof goes: build canonical model, prove truth lemma, use contrapositive. The imp case of the truth lemma is the simplest case because MCS have the implication property.

**Conclusion from prior art**: The standard approach does NOT use validity reduction for imp. It uses the canonical model truth lemma directly. The current `usf_completeness` takes a non-standard approach (validity reduction) that works for G/H/box but fails for imp. The fix should either:
1. Complete the canonical model construction (the standard approach), or
2. Find a way to make the validity reduction work for imp (novel, harder)

## Alternative Approaches (Ranked by Feasibility)

### Rank 1: Complete the Canonical Model Truth Lemma for USF Fragment (HIGH feasibility)

**What**: Build a canonical TaskModel from BXPoints with non-constant histories, prove the full truth lemma for {atom, bot, imp, box, G, H}, then use contrapositive completeness.

**Why it works**: The truth lemma handles imp via `imp_iff_mcs`, which is ALREADY PROVED. The backward bridge for G/H needs non-constant histories (two-point or chain construction). The canonical_task_frame's permissive task_rel makes this straightforward.

**Effort**: 4-8 hours. Main work is constructing WorldHistories that respect the bx_le ordering and proving the truth lemma's G/H backward direction on these histories.

**Advantage**: This is the standard textbook approach. It would simultaneously close the sorry in `usf_completeness` AND make progress on `bx_completeness`.

### Rank 2: Use fmp_completeness + Closure MCS Truth Lemma (MEDIUM-HIGH feasibility)

**What**: Show `valid phi -> phi in S` for every ClosureMCSBundle S, using the already-proved fmp_completeness.

**Why it works**: `fmp_completeness` is sorry-free. The bridge `valid phi -> phi in every closure MCS` is the filtration truth lemma, which for USF formulas only needs atom/bot/imp/box/G/H cases. The imp case is trivial (MCS implication property). The G/H cases need the same MCS-level truth lemma that's already proved.

**Effort**: 6-10 hours. Need to construct a TaskModel from closure MCS and prove truth_at correspondence.

**Advantage**: Avoids non-constant histories entirely. Works at MCS level.

**Disadvantage**: Still requires a model construction, just a different one (finite model rather than canonical model).

### Rank 3: Non-Constant History Construction for CanonicalEmbedding (MEDIUM feasibility)

**What**: Replace constant_history in the imp Case B with a two-point (or chain) history that distinguishes G(alpha) from alpha.

**Why it works**: The backward truth bridge failure is specifically about constant histories collapsing G. A two-point history `{0 -> w, 1 -> v}` where v witnesses `alpha not in v` for some `G(alpha) not in w` would fix the bridge.

**Effort**: 6-12 hours. The main challenge is that the countermodel needs to handle arbitrary USF chi, not just `G(alpha)`. For deeply nested formulas, the history might need to be longer (chain of BXPoints).

**Advantage**: Minimal changes to existing code structure. Stays within CanonicalEmbedding.lean.

### Rank 4: Abandon Validity Reduction for imp, Use Standard Contrapositive (HIGH feasibility but restructures code)

**What**: Rewrite `usf_completeness` to NOT use structural induction with validity reduction. Instead:
1. Build canonical model for USF fragment (WorldHistories through chains of BXPoints)
2. Prove truth lemma for USF fragment
3. Use standard contrapositive: not derivable -> consistent -> MCS -> false in model -> not valid

**Why it works**: This is the textbook approach. The imp case of the truth lemma is trivial.

**Effort**: 8-16 hours. Essentially a rewrite of the completeness proof architecture.

**Advantage**: Eliminates the problematic approach entirely. Mathematically cleanest.

**Disadvantage**: Significant code rewrite. May require non-constant histories anyway for G/H truth lemma.

### Rank 5: Derive Until-Induction from BX5+BX6+BX7 (LOW feasibility for this sorry)

**What**: Derive the Until-induction principle from existing BX axioms.

**Why it's low rank for THIS sorry**: Until-induction would close the Frame.lean sorries (#1-#4), enabling full `bx_completeness`. But the current sorry in `usf_completeness` is about the imp case in the USF fragment, which doesn't involve Until/Since at all. Until-induction is orthogonal to this specific sorry.

## Evidence/Examples

### Evidence for Rank 1 (Canonical Model with Non-Constant Histories)

The canonical_task_frame has `task_rel w d u = (d != 0 or w = u)`. This means for ANY two BXPoints w, u and ANY non-zero displacement d, `task_rel w d u` holds. So a WorldHistory can jump between arbitrary BXPoints at consecutive time steps.

Example: Given MCS w with `G(alpha) not in w`:
1. By `bx_G_backward`: exists v with `bx_le w v` and `alpha not in v`
2. Define history: `states(t) = w` for t <= 0, `states(t) = v` for t > 0`
3. Domain = all of Z (full domain)
4. `truth_at G(alpha)` at time 0 requires `truth_at alpha` at time 1 (at state v)
5. `truth_at alpha` at v corresponds to `alpha in v` (by atom-level truth), which is false

### Evidence for Standard Approach (from BRV 2001, Ch 4.2)

The standard canonical model completeness proof:
```
Theorem: If phi is valid, then phi is derivable.
Proof (contrapositive): Assume phi not derivable.
  1. {neg phi} is consistent
  2. Extend to MCS w0 with neg phi in w0
  3. Define canonical model M_c:
     - Worlds = all MCS
     - R w v iff {phi : box phi in w} subset v  [modal]
     - < w v iff {phi : G phi in w} subset v    [temporal]
     - V(p, w) iff p in w                        [valuation]
  4. Truth Lemma: for all phi, all MCS w:
       phi in w iff M_c, w |= phi
     Proof by induction on phi:
     - atom: by definition of V
     - bot: MCS never contains bot
     - imp: phi->psi in w iff (phi in w -> psi in w) iff (w|=phi -> w|=psi) iff w|=phi->psi
     - box: by definition of R and Lindenbaum
     - G/H: by definition of < and Lindenbaum
  5. neg phi in w0, so phi not in w0, so M_c, w0 |/= phi
  6. phi is not valid.
```

The imp case (step 4, third sub-case) uses ONLY the MCS implication property — no semantic reasoning about models needed.

## Confidence Level

- **Overall**: HIGH confidence that the sorry is closable
- **Rank 1 approach**: HIGH confidence (standard textbook technique)
- **Rank 2 approach**: MEDIUM-HIGH confidence (requires model construction, may have subtle issues with closure restriction)
- **Rank 3 approach**: MEDIUM confidence (requires careful handling of arbitrary formula depth)
- **Timeline**: 4-8 hours for Rank 1 approach, which subsumes the current sorry and advances toward full completeness

## Summary

The remaining sorry is a consequence of using an **non-standard proof architecture** (validity reduction + structural induction) that works well for G/H/box but fundamentally cannot handle imp without additional model-theoretic infrastructure. The standard completeness proof handles imp trivially via MCS properties. The fix is to either:

1. **Add non-constant histories** to the existing CanonicalEmbedding framework (minimal change, addresses the backward truth bridge gap), or
2. **Use the standard contrapositive approach** with the full canonical model (more work but mathematically cleaner and addresses `bx_completeness` too), or
3. **Bridge through fmp_completeness** by proving the finite model truth lemma for USF formulas (avoids non-constant histories but requires different model construction)

All three approaches ultimately require some form of model construction where the truth_at evaluation correctly tracks MCS membership for ALL formula connectives including G/H. The constant-history shortcut that works for temporal-free formulas cannot extend to the full USF fragment.
