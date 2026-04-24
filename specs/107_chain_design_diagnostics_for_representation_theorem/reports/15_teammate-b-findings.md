# Research Report: Task 107 Teammate B -- The Box Case and BFMCS Structure over Sparse X

**Task**: 107 - Chain design diagnostics for representation theorem
**Date**: 2026-04-24
**Focus**: How the BFMCS works, where AddCommGroup is required, and whether the Box case can work over sparse X without shifting

---

## 1. BFMCS Structure Analysis

### Fields and Constraints

`BFMCS D` (in `Bundle/BFMCS.lean`) requires only `[Preorder D]` on the type parameter:

```
structure BFMCS where
  families : Set (FMCS D)
  nonempty : families.Nonempty
  modal_forward : forall fam in families, forall phi t,
    Box(phi) in fam.mcs(t) -> forall fam' in families, phi in fam'.mcs(t)
  modal_backward : forall fam in families, forall phi t,
    (forall fam' in families, phi in fam'.mcs(t)) -> Box(phi) in fam.mcs(t)
  eval_family : FMCS D
  eval_family_mem : eval_family in families
```

`FMCS D` (in `Bundle/FMCSDef.lean`) also requires only `[Preorder D]`:

```
structure FMCS where
  mcs : D -> Set Formula
  is_mcs : forall t, SetMaximalConsistent (mcs t)
  forward_G : forall t t' phi, t < t' -> G(phi) in mcs(t) -> phi in mcs(t')
  backward_H : forall t t' phi, t' < t -> H(phi) in mcs(t) -> phi in mcs(t')
```

**Key finding**: Neither BFMCS nor FMCS structurally requires AddCommGroup. The Preorder constraint suffices for the data structures themselves.

### Diamond Witness Families

The BFMCS families represent "parallel timelines" -- one root timeline plus one per diamond witness needed. The diamond witness theorem (`BFMCS.diamond_witness`) shows:

```
neg(Box(neg(phi))) in fam.mcs(t) ->
  exists fam' in B.families, phi in fam'.mcs(t)
```

This is proved purely from `modal_forward`, `modal_backward`, and MCS properties -- no addition/subtraction needed.

---

## 2. How chronicle_bfmcs Is Constructed

In `ChronicleToCountermodel.lean`, `chronicle_bfmcs` is constructed as:

```
families := { fam | exists N h_N s,
    (forall phi, Box(phi) in M0 <-> Box(phi) in N) /\
    fam = shifted_chronicle_fmcs N h_N s }
```

Where `shifted_chronicle_fmcs` shifts a timeline by rational offset `s`:

```
shifted_chronicle_fmcs A h_mcs s :=
  mcs(t) := extended_limit_f A h_mcs (t - s)
```

**Critical dependency on subtraction**: The shift mechanism `t - s` requires `Sub Rat` (and hence additive group structure). This is used to:

1. Place the witness MCS N at the correct time position t (via `shifted_chronicle_fmcs N h_N t`)
2. Prove `shifted_chronicle_fmcs_at_s`: the shifted timeline has `mcs(s) = N`

### Why shifting exists

The `modal_backward` proof in `chronicle_bfmcs` uses `bx_modal_witness` to get a diamond witness MCS `v` with `neg(phi) in v.formulas`. It then needs a family member where `neg(phi)` appears at time `t`. The shifted FMCS `shifted_chronicle_fmcs v.formulas v.is_mcs t` achieves this because `mcs(t) = v.formulas` (by `shifted_chronicle_fmcs_at_s`).

---

## 3. Where AddCommGroup Is Actually Required

### Layer 1: BFMCS/FMCS -- NOT required

Both structures only need `[Preorder D]`. The modal coherence conditions, S5 properties, and diamond witness theorem are all AddCommGroup-free.

### Layer 2: Truth lemma box case -- REQUIRES AddCommGroup

The box case in `restricted_parametric_shifted_truth_lemma` (line 365-388 of RestrictedParametricTruthLemma.lean) uses:

**Forward direction** (Box(psi) in fam.mcs(t) -> truth_at(Box(psi), t)):
```
h_box_shifted : Box(psi) in fam.mcs(t + delta) :=
  parametric_box_persistent fam psi t (t + delta) h_box
h_psi_fam' : psi in fam'.mcs(t + delta) :=
  B.modal_forward fam hfam psi (t + delta) h_box_shifted fam' hfam'
```
Then uses `time_shift_preserves_truth` and `add_sub_cancel_left t delta`.

**Backward direction** (truth_at(Box(psi), t) -> Box(psi) in fam.mcs(t)):
```
h_mem := parametricCanonicalOmega_subset_shiftClosed B ...
```
Then applies `ih` with `fam'` and `t` directly.

The forward direction needs:
- `t + delta` (addition)
- `add_sub_cancel_left t delta` (group property)
- `time_shift_preserves_truth` which uses `y - x` (subtraction)

### Layer 3: Omega and ShiftClosed -- REQUIRES AddCommGroup

The S5 box semantics quantifies over **all histories in Omega**. The `ShiftClosedParametricCanonicalOmega` includes time-shifted copies:

```
{ sigma | exists fam in B.families, exists delta,
    sigma = WorldHistory.time_shift (parametric_to_history fam) delta }
```

The `time_shift` construction uses `t + delta` (in domain definition) and `y - x` (in `time_shift_preserves_truth`).

### Layer 4: TaskFrame/task_rel -- REQUIRES AddCommGroup

`parametric_canonical_task_rel` uses sign-based case analysis on duration `d`:
- d > 0: ExistsTask M N (forward)
- d = 0: M = N
- d < 0: ExistsTask N M (converse)

The `forward_comp` proof uses `add_pos`, `add_zero`, `zero_add` -- all group operations.

---

## 4. Analysis: BFMCS over Sparse X Without Shifting

### The Proposal

Set D = { x : Rat // x in limit_dom }, a sparse subtype. Each FMCS is defined over this domain. No shifting needed because diamond-witness timelines are separate chronicles over the same X.

### Problem 1: Different Chronicles Produce Different Domains

If we build chronicle(N) from witness MCS N, its `limit_dom(N)` may differ from `limit_dom(M0)`. The Burgess construction adds domain points opportunistically based on which formulas need witnesses. There is no reason `limit_dom(M0) = limit_dom(N)`.

**Severity**: Fatal for the "BFMCS over X" approach if X varies per family member.

### Problem 2: The Truth Lemma Box Case Needs time_shift

Even if we solve Problem 1, the truth lemma's box forward case uses:

```
truth_at M Omega (time_shift (parametric_to_history fam') (y-x)) x psi
  <-> truth_at M Omega (parametric_to_history fam') y psi
```

This `time_shift_preserves_truth` is the bridge between "Box(psi) holds at time t+delta in family fam'" and "psi is true at (shifted fam') at time t". Without AddCommGroup on D, this bridge does not exist.

### Problem 3: ShiftClosed Omega Needs Addition

The set Omega must be shift-closed for the box case. The definition `WorldHistory.time_shift sigma delta` requires `domain(z) := sigma.domain(z + delta)`, which needs addition on D. For a sparse subtype `{ x : Rat // x in X }`, we would need `x + delta in X` whenever `x in X` -- i.e., X must be closed under translation by every element of D. A sparse countable X cannot be translation-closed.

**Severity**: Fatal. ShiftClosed is a structural requirement of the semantics, not an artifact.

---

## 5. Box Stability Analysis

### Existing Proof: box_stable_in_int_chain

The proof in `CanonicalModel.lean` (lines 310-374) shows `Box(phi) in int_chain(t) <-> Box(phi) in M0` using:

**Forward (chain(t) -> M0)**: Contraposition. If Box(phi) not in M0, then neg(Box(phi)) in M0. By S5 negative introspection, Box(neg(Box(phi))) in M0. Propagate to chain(t) via G (future) or H (past). Extract neg(Box(phi)) at t via modal_t. Contradiction.

**Backward (M0 -> chain(t))**: By temp_future axiom: Box(phi) -> G(Box(phi)). For t > 0, propagate via forward_G. For t < 0, use modal_4 + box_to_past to get H(Box(phi)), then backward_H.

### Chronicle Version: box_stable_in_chronicle_fmcs (SORRY)

The sorry at line 234 of `ChronicleToCountermodel.lean` needs the same argument but over Rat instead of Int. The proof structure should be identical because it only uses:
- MCS properties (negation_complete, implication_property)
- S5 axioms (temp_future, modal_4, modal_t)
- FMCS forward_G and backward_H

**Key dependency**: forward_G and backward_H of `chronicle_fmcs` are themselves sorry'd (lines 192, 196). Box stability CANNOT be proved until these are resolved.

### Adaptability for Chronicles

The box stability proof does NOT need `time_shift` or addition. It works purely at the MCS level using:
1. Axiom schemas (temp_future, modal_4, box_to_past, modal_t)
2. MCS closure under modus ponens
3. forward_G / backward_H of the FMCS

So it is adaptable to any FMCS construction, including sparse X, IF forward_G/backward_H hold.

---

## 6. The Box Case in the Truth Lemma

### What the Restricted Truth Lemma Uses

The box case (lines 365-388 of `RestrictedParametricTruthLemma.lean`) proceeds:

**Forward**: Box(psi) in fam.mcs(t) -> for all sigma in Omega, truth_at(sigma, t, psi)
1. sigma in ShiftClosedOmega, so sigma = time_shift(parametric_to_history(fam'), delta) for some fam', delta
2. Box(psi) persists to t + delta via `parametric_box_persistent`
3. modal_forward: psi in fam'.mcs(t + delta)
4. IH: truth_at(fam', t + delta, psi)
5. time_shift_preserves_truth: truth_at(time_shift(fam', delta), t, psi)

**Backward**: for all sigma in Omega, truth_at(sigma, t, psi) -> Box(psi) in fam.mcs(t)
1. For each fam' in B.families, parametric_to_history(fam') in ShiftClosedOmega (take delta=0)
2. By hypothesis, truth_at(fam', t, psi)
3. IH: psi in fam'.mcs(t)
4. modal_backward: Box(psi) in fam.mcs(t)

### Critical Observation: The Backward Direction Is Simple

The backward direction does NOT use time_shift at all. It only uses:
- IH at delta=0 (no shifting)
- modal_backward (BFMCS property)

### The Forward Direction Needs time_shift

The forward direction must handle SHIFTED histories sigma = time_shift(fam', delta). The issue is that S5 box semantics quantifies over ALL sigma in Omega, not just the unshifted ones. A shifted history evaluates the formula at a shifted time, so the proof must relate truth at shifted times to MCS membership at unshifted times.

### Can the Forward Direction Work Without time_shift?

If Omega contained ONLY unshifted histories (no shift closure), the forward direction would simplify to:
1. Box(psi) in fam.mcs(t)
2. modal_forward: psi in fam'.mcs(t) for all fam'
3. IH: truth_at(fam', t, psi)

This works! But then Omega is NOT shift-closed, which violates the `ShiftClosed` constraint needed for the `truth_at` definition to match the paper's semantics.

---

## 7. Sketch of the Box Case for a Direct Truth Lemma

### The Direct Approach (No time_shift)

Suppose we define a "restricted truth" function `truth_at_X` that:
- Uses sparse X as the temporal domain
- Quantifies G/H only over points in X (not all of D)
- Quantifies Box only over families in the BFMCS (not over shifted histories)

Then the box case becomes:

**Forward**: Box(phi) in fam.mcs(t)
-> (box_stable) Box(phi) in every fam'.mcs(t) for fam' in B.families
-> (modal_t) phi in every fam'.mcs(t)
-> (IH) truth_at_X(phi, t) for every fam'
-> truth_at_X(Box(phi), t)

Wait -- this doesn't work. `truth_at_X(Box(phi), t)` should mean "for all sigma in Omega, truth_at_X(sigma, t, phi)". If sigma ranges over BFMCS families (not shifted histories), then the forward direction is:
1. Box(phi) in fam.mcs(t) -> modal_forward -> phi in fam'.mcs(t) for all fam'
2. IH: truth_at_X(fam', t, phi) for all fam' in B.families
3. If Omega = { parametric_to_history(fam') | fam' in B.families }, done.

**Backward**: For all sigma in Omega, truth_at_X(sigma, t, phi)
-> For each fam' in B.families (since Omega is exactly the family histories), truth_at_X(fam', t, phi)
-> IH: phi in fam'.mcs(t) for all fam'
-> modal_backward: Box(phi) in fam.mcs(t)

### This Works IF Omega = Unshifted Families Only

The proof sketch is clean and needs NO time_shift, NO AddCommGroup. But there is a catch.

### The Catch: Soundness Compatibility

The completeness theorem must produce a countermodel that the soundness theorem accepts. Soundness is proved for models with ShiftClosed Omega (see `Soundness.lean`). If the direct truth lemma uses a non-shift-closed Omega, the countermodel may not satisfy the premises of the soundness theorem.

However, completeness is an EXISTENTIAL statement: "if consistent, then satisfiable". It only needs to produce ONE model. The question is whether the notion of "satisfiable" requires ShiftClosed Omega.

### Checking the Definition of Validity

Looking at `truth_at`:
```
| Formula.box phi => forall sigma in Omega, truth_at M Omega sigma t phi
```

The paper's semantics requires Omega to be a ShiftClosed set. If we weaken this to allow non-ShiftClosed Omega, we change the logic.

**Resolution**: The countermodel's Omega MUST be ShiftClosed for the completeness result to be sound. This is because the axiom system (particularly the temp_future axiom `Box(phi) -> G(Box(phi))`) is sound only when Omega is ShiftClosed.

---

## 8. The Alternative: D = X as Subtype, Keep Shifting

### Proposal

Set `D = { x : Rat // x in limit_dom M0 }` as a subtype. This has:
- LinearOrder (inherited from Rat)
- Preorder (from LinearOrder)
- Dense ordering (if the chronicle is constructed with density -- which the Burgess construction provides)

**But NOT AddCommGroup**, because X is not closed under addition.

### Where This Fails

The parametric framework (`ParametricTruthLemma.lean`, `ParametricCanonical.lean`, `ParametricHistory.lean`) ALL have:

```
variable {D : Type*} [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D]
```

To use the parametric framework with D = sparse X, we would need to either:

1. **Refactor the entire parametric layer** to remove AddCommGroup -- massive, since it pervades TaskFrame, WorldHistory, time_shift, truth_at, ShiftClosed, and all soundness proofs.

2. **Embed X into Rat** and use Rat as D -- this is exactly what the existing code does, with the extension (`extended_limit_f`) handling non-domain points.

3. **Build a parallel truth lemma** that doesn't go through the parametric framework -- possible but duplicates hundreds of lines.

---

## 9. Summary of Findings

### What BFMCS Needs from D

| Component | Minimum D constraint | Actually uses |
|-----------|---------------------|---------------|
| FMCS structure | Preorder | `<` for forward_G/backward_H |
| BFMCS structure | Preorder | Only FMCS constraints |
| Box stability | Preorder | Only MCS + forward_G/backward_H |
| modal_forward/backward | Preorder | Only MCS properties |
| Truth lemma (G/H cases) | Preorder | `<` for quantification |
| Truth lemma (box case) | **AddCommGroup** | `t + delta`, `time_shift` |
| ShiftClosed Omega | **AddCommGroup** | `t + delta` in domain |
| TaskFrame axioms | **AddCommGroup** | `x + y`, `-d`, `0` |
| time_shift_preserves_truth | **AddCommGroup** | `y - x`, `neg_add_cancel` |

### The Fundamental Tension

The BFMCS itself is AddCommGroup-free, but the SEMANTIC FRAMEWORK it plugs into requires AddCommGroup. The box case of the truth lemma is the nexus: it needs to relate MCS membership (BFMCS level, no group needed) to semantic truth (framework level, group needed).

### Viable Paths for Box Case Without AddCommGroup on X

**Path A: Keep D=Rat, extend chronicle to all of Rat (CURRENT APPROACH)**

This is what `extended_limit_f` does. Non-domain points get M0 as fallback. The sorry sites are in forward_G/backward_H of `chronicle_fmcs` and `box_stable_in_chronicle_fmcs`.

- Pro: No framework refactoring needed
- Con: Must prove forward_G/backward_H across domain/non-domain boundaries

**Path B: Direct truth lemma with unshifted Omega**

Define a custom truth function where Box quantifies over BFMCS families directly (not shifted histories). This sidesteps the AddCommGroup requirement entirely.

- Pro: Conceptually cleanest, no extension needed
- Con: Must prove this custom truth function equals the standard one, or accept a different validity notion. Soundness compatibility is the main risk.

**Path C: Use Rat as D but restrict coherence to domain points**

The "fully restricted" truth lemma already restricts temporal/Until/Since coherence to subformulas of root. If we could also restrict the BOX quantification to only consider unshifted families, the box case simplifies.

- Pro: Minimal changes to existing framework
- Con: Changing what Box quantifies over changes the logic

### Recommendation

**Path A is the most pragmatic**. The current `extended_limit_f` approach (D=Rat, non-domain fallback to M0) is sound. The sorry sites are:

1. `chronicle_fmcs.forward_G` -- needs proof that G(phi) propagates across extended_limit_f
2. `chronicle_fmcs.backward_H` -- needs proof that H(phi) propagates similarly
3. `box_stable_in_chronicle_fmcs` -- needs (1) and (2) first

For (1) and (2), the key insight is: if both t and t' are in `limit_dom`, the chronicle's g_content/h_content structure provides the propagation directly. The hard cases involve transitions between domain and non-domain points:

- **Domain to non-domain**: G(phi) in limit_f(t), t' not in domain, so mcs(t') = M0. Need G(phi) in M0. This follows if G(phi) is "globally stable" (i.e., G(G(phi)) in limit_f(t), which by backward propagation to 0, gives G(phi) in M0).
- **Non-domain to domain**: G(phi) in M0, t' in domain. Need phi in limit_f(t'). This requires g_content(M0) subset limit_f(t'), which follows from the chronicle's construction (limit_f starts from M0).
- **Non-domain to non-domain**: G(phi) in M0, t' not in domain, mcs(t') = M0. Need phi in M0. This follows from G(phi) in M0 and the T axiom G(phi) -> phi... wait, that's only for t < t' (strict). G(phi) -> phi is NOT valid under strict semantics. We need reflexivity: G(phi) at t implies phi at t. But G is STRICT future only.

**Potential gap in Path A**: The non-domain-to-non-domain case for forward_G may fail because G(phi) in M0 does NOT imply phi in M0 under strict semantics (G quantifies over strictly future times only). This suggests the M0 fallback for non-domain points is potentially broken for forward_G when both points are outside the domain.

This gap may explain why `chronicle_fmcs.forward_G` remains sorry'd. A more careful non-domain extension (e.g., using g_content-derived MCS at each non-domain point rather than M0 itself) may be needed.

---

## 10. Gaps in the Proposed Box Case Proof Sketch

The sketch from the task description:

> Forward: Box(phi) in fam.mcs(t) -> by box_stable -> Box(phi) in every family member at every time -> by modal_t -> phi in every family member at every time -> by IH -> truth_at_X(phi, s) for all s

**Gap**: "Box(phi) in every family member at every time" is not what modal_forward gives. modal_forward gives: Box(phi) in fam.mcs(t) -> phi in fam'.mcs(t) (same time t, different family). To get "at every time", you need box_stable first: Box(phi) in fam.mcs(t) <-> Box(phi) in fam.mcs(t') for all t', via box stability. Then modal_forward at each t'. This is correct but requires box_stable, which is currently sorry'd for chronicles.

> Backward: truth_at_X(phi, s) for all s -> need Box(phi) in fam.mcs(t). By contraposition: if Diamond(neg(phi)) in fam.mcs(t), the BFMCS has a family member k where neg(phi) in fam_k.mcs(t), so truth_at_X(neg(phi), t), contradicting truth_at_X(phi, t).

**Gap**: This sketch conflates two things. Diamond(neg(phi)) means neg(Box(neg(neg(phi)))) = neg(Box(phi)). The BFMCS.diamond_witness gives: exists fam' where neg(phi) in fam'.mcs(t). By IH, truth_at_X(neg(phi), t) at fam'. But we need truth_at_X(phi, t) at fam' (from the box hypothesis). The contradiction is: phi and neg(phi) both hold at fam' at time t, which contradicts consistency. This is actually correct, but the proof needs to be more precise about which history truth is evaluated at.

The backward direction in the existing code is simpler: just use IH at delta=0 for each family, then modal_backward. No contraposition needed.
