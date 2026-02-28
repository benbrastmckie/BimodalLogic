# Research Report: Task #945 (research-006)

**Task**: 945 - Design canonical model construction for TruthLemma
**Started**: 2026-02-27T12:00:00Z
**Completed**: 2026-02-27T13:30:00Z
**Effort**: High (first-principles design of direct canonical construction without BFMCS intermediate)
**Dependencies**: Semantics (Truth.lean, Validity.lean, TaskFrame.lean, WorldHistory.lean), Axioms.lean, existing BFMCS infrastructure (TruthLemma.lean, BFMCS.lean, FMCS.lean, CanonicalFrame.lean)
**Sources/Inputs**: Codebase analysis of all semantics and metalogic modules
**Artifacts**: This report
**Standards**: report-format.md, return-metadata-file.md

## Executive Summary

- The direct TruthLemma (without `bmcs_truth_at` intermediate) IS achievable and produces a cleaner architecture.
- The key insight: `bmcs_truth_at` is structurally identical to `truth_at` when the canonical definitions are chosen correctly. The bridge theorem is definitionally trivial.
- Therefore `bmcs_truth_at` provides NO essential value -- it is a redundant intermediate. The entire proof can be performed directly at the `truth_at` level.
- The direct proof requires exactly the same mathematical content as the current proof. The difficulty is not redistributed; it is localized in exactly the same places (modal coherence, temporal saturation).
- This report provides the complete direct construction with Lean 4 pseudocode for all definitions and a case-by-case proof sketch.

## Context & Scope

Reports 001-005 progressively refined the canonical model construction for TM. Report 005 identified the correct approach: Z-indexed timelines, TaskFrame with WorldState = MCS, and a two-step TruthLemma via bridge theorem from `bmcs_truth_at` to `truth_at`.

The user's question for this report: **Can we skip `bmcs_truth_at` entirely and prove the TruthLemma directly at the `truth_at` level?**

The answer is YES, and the result is actually cleaner. This report designs the complete direct construction.

## Findings

### Part 1: What `bmcs_truth_at` Provides (And Why It Is Redundant)

#### The Current Architecture

The existing completeness proof has this structure:

```
phi in fam.mcs t
  <-> bmcs_truth_at B fam t phi       (by bmcs_truth_lemma, in TruthLemma.lean)
  <-> truth_at M Omega tau t phi       (by bridge theorem, to be proven)
```

The `bmcs_truth_at` definition (from BFMCSTruth.lean) is:

```lean
def bmcs_truth_at (B : BFMCS D) (fam : FMCS D) (t : D) : Formula -> Prop
  | Formula.atom p     => Formula.atom p in fam.mcs t
  | Formula.bot        => False
  | Formula.imp phi psi => bmcs_truth_at B fam t phi -> bmcs_truth_at B fam t psi
  | Formula.box phi    => forall fam' in B.families, bmcs_truth_at B fam' t phi
  | Formula.all_past phi  => forall s, s <= t -> bmcs_truth_at B fam s phi
  | Formula.all_future phi => forall s, t <= s -> bmcs_truth_at B fam s phi
```

The standard `truth_at` (from Truth.lean) is:

```lean
def truth_at (M : TaskModel F) (Omega : Set (WorldHistory F))
    (tau : WorldHistory F) (t : D) : Formula -> Prop
  | Formula.atom p     => exists (ht : tau.domain t), M.valuation (tau.states t ht) p
  | Formula.bot        => False
  | Formula.imp phi psi => truth_at M Omega tau t phi -> truth_at M Omega tau t psi
  | Formula.box phi    => forall (sigma : WorldHistory F), sigma in Omega ->
                            truth_at M Omega sigma t phi
  | Formula.all_past phi  => forall (s : D), s <= t -> truth_at M Omega tau s phi
  | Formula.all_future phi => forall (s : D), t <= s -> truth_at M Omega tau s phi
```

#### Case-by-Case Comparison

| Case | `bmcs_truth_at B fam t` | `truth_at M Omega tau t` | Isomorphic? |
|------|------------------------|--------------------------|-------------|
| atom p | `atom p in fam.mcs t` | `exists ht, M.valuation (tau.states t ht) p` | YES (when domain = True, valuation = MCS membership) |
| bot | `False` | `False` | IDENTICAL |
| imp | pointwise | pointwise | IDENTICAL (by IH) |
| box phi | `forall fam' in B.families, ...fam'...` | `forall sigma in Omega, ...sigma...` | YES (when Omega = {to_history fam' \| fam' in B.families}) |
| all_past phi | `forall s, s <= t, ...fam s...` | `forall s, s <= t, ...tau s...` | YES (when tau = to_history fam) |
| all_future phi | `forall s, t <= s, ...fam s...` | `forall s, t <= s, ...tau s...` | YES (when tau = to_history fam) |

Every case matches structurally. The bridge theorem is definitionally trivial once the canonical definitions are correct. This means `bmcs_truth_at` adds NO mathematical content -- it is a notational convenience that duplicates `truth_at` with different variable names.

#### Conclusion

`bmcs_truth_at` is redundant. We can and should prove the TruthLemma directly as:

```
phi in tau.states t ht <-> truth_at CanonicalTaskModel CanonicalOmega tau t phi
```

### Part 2: The Direct Construction

#### Definition A: Canonical TaskFrame

```lean
-- D = Int (the integers)
-- WorldState = MCS (maximal consistent sets, as a subtype)

def CanonicalWorldState : Type :=
  { M : Set Formula // SetMaximalConsistent M }

def CanonicalTaskFrame : TaskFrame Int where
  WorldState := CanonicalWorldState

  -- The canonical task relation.
  -- task_rel M d N holds iff:
  --   d >= 0 implies GContent(M.val) subset N.val (forward coherence)
  --   d <= 0 implies HContent(N.val) subset M.val (backward coherence)
  task_rel M d N :=
    (d >= 0 -> GContent M.val ⊆ N.val) /\
    (d <= 0 -> HContent N.val ⊆ M.val)

  -- Nullity: task_rel M 0 M
  -- d = 0 is both >= 0 and <= 0, so we need:
  --   GContent(M.val) subset M.val  (by T-axiom: G(phi) -> phi)
  --   HContent(M.val) subset M.val  (by T-axiom: H(phi) -> phi)
  nullity := fun M => by
    constructor
    . intro _; exact canonicalR_reflexive M.val M.property
    . intro _; exact canonicalR_past_reflexive M.val M.property

  -- Compositionality: task_rel M x N /\ task_rel N y V -> task_rel M (x+y) V
  -- For x+y >= 0: need GContent(M.val) subset V.val
  --   Case 1: x >= 0 and y >= 0: GContent(M) subset N, GContent(N) subset V
  --     By temporal 4: G(phi) in M -> GG(phi) in M -> G(phi) in N -> phi in V
  --     i.e., canonicalR_transitive
  --   Case 2: x < 0 and x+y >= 0: then y > 0 and y >= -(x)
  --     HContent(N) subset M (from d=x <= 0) and GContent(N) subset V (from d=y >= 0)
  --     Need GContent(M) subset V -- this requires temporal interaction axioms
  --   Case 3: x >= 0 and y < 0 and x+y >= 0: similar
  -- For x+y <= 0: symmetric
  compositionality := fun M N V x y hMN hNV => by
    sorry -- This requires detailed case analysis using temporal 4 and interaction axioms
```

**Critical observation about compositionality**: The compositionality proof for the canonical task relation is nontrivial when the signs of x and y differ (Cases 2 and 3 above). This requires the modal-temporal interaction axioms MF (`Box(phi) -> Box(G(phi))`) and TF (`Box(phi) -> G(Box(phi))`), plus temporal 4 (`G(phi) -> GG(phi)`). However, for the direct TruthLemma, compositionality of the task relation is NOT needed -- it is only needed for the well-formedness of the TaskFrame. The `truth_at` definition does not use `task_rel` at all (only `tau.states`, `tau.domain`, `M.valuation`, and `Omega` membership appear in truth_at).

**This is a crucial finding**: task_rel does NOT appear in the truth_at definition. It appears only in:
1. The `WorldHistory.respects_task` constraint (ensuring histories are well-formed)
2. The `TaskFrame` structure (requiring nullity + compositionality)

For the TruthLemma proof itself, only the history's states matter. The task relation is a structural requirement on the frame but does not participate in truth evaluation.

#### Definition B: Canonical TaskModel

```lean
def CanonicalTaskModel : TaskModel CanonicalTaskFrame where
  valuation M p := Formula.atom p in M.val
```

This is simple: an atom p is true at world-state M iff `atom p in M`.

#### Definition C: Canonical World-History (from an FMCS)

Given an FMCS `fam : FMCS Int` (a family of MCS indexed by Int):

```lean
def to_history (fam : FMCS Int) : WorldHistory CanonicalTaskFrame where
  -- Full domain: every integer time is in the domain
  domain := fun _ => True

  -- Convexity is trivial for full domain
  convex := fun _ _ _ _ _ _ _ => True.intro

  -- States: the MCS at time t IS the world-state
  states := fun t _ => ⟨fam.mcs t, fam.is_mcs t⟩

  -- Respects task: for s <= t, task_rel (fam.mcs s) (t - s) (fam.mcs t)
  -- This reduces to:
  --   t - s >= 0 (true since s <= t) implies GContent(fam.mcs s) subset fam.mcs t
  --   t - s <= 0 implies HContent(fam.mcs t) subset fam.mcs s
  -- The first follows from forward_G coherence of the FMCS.
  -- The second is only required when t - s <= 0, i.e., s >= t.
  --   Combined with s <= t, this means s = t, and then it's reflexivity.
  respects_task := fun s t hs ht hst => by
    constructor
    . intro _hge
      -- GContent(fam.mcs s) subset fam.mcs t
      -- For any phi: G(phi) in fam.mcs s -> phi in fam.mcs t
      -- This is exactly fam.forward_G s t phi hst
      intro phi hG; exact fam.forward_G s t phi hst hG
    . intro hle
      -- t - s <= 0 combined with s <= t means s = t
      have heq : s = t := le_antisymm hst (by omega)
      subst heq
      -- HContent(fam.mcs s) subset fam.mcs s: reflexivity via T-axiom
      intro phi hH; exact canonicalR_past_reflexive (fam.mcs s) (fam.is_mcs s) hH
```

Note: `respects_task` requires that the task relation hold for ALL s, t in the domain, not just s <= t. Looking at the actual definition in WorldHistory.lean:

```lean
respects_task : forall (s t : D) (hs : domain s) (ht : domain t),
    s <= t -> F.task_rel (states s hs) (t - s) (states t ht)
```

It DOES require s <= t. So we only need the forward direction. Good -- this avoids the cross-sign problem entirely for `respects_task`.

#### Definition D: Canonical Omega

```lean
-- The set of canonical world-histories is the image of the bundle families
-- under to_history
def CanonicalOmega (B : BFMCS Int) : Set (WorldHistory CanonicalTaskFrame) :=
  { tau | exists fam in B.families, tau = to_history fam }
```

This set must be ShiftClosed. The `time_shift` of `to_history fam` by delta is:

```
(time_shift (to_history fam) delta).states z hz = (to_history fam).states (z + delta) _
                                                 = fam.mcs (z + delta)
```

So `time_shift (to_history fam) delta = to_history (shift_fam fam delta)` where `shift_fam fam delta` is the FMCS with `mcs t = fam.mcs (t + delta)`.

**ShiftClosed requires**: For every `fam in B.families` and every `delta : Int`, the shifted family `shift_fam fam delta` must also be in `B.families`.

This is a condition on the BFMCS construction. The current BFMCS structure does NOT guarantee shift-closure. However, we can handle this in two ways:

**Option 1 (Recommended): Expand the bundle to include all shifts.**

Define `CanonicalOmega` as the closure under shifts:

```lean
def CanonicalOmega (B : BFMCS Int) : Set (WorldHistory CanonicalTaskFrame) :=
  { tau | exists fam in B.families, exists delta : Int, tau = time_shift (to_history fam) delta }
```

This is ShiftClosed by construction. The key question: does the TruthLemma still hold for shifted families?

**Option 2: Prove the box case without ShiftClosed.**

The box case of `truth_at` quantifies over ALL sigma in Omega at time t. ShiftClosed is NOT needed for the box case -- it is only needed for `time_shift_preserves_truth`. Since the TruthLemma is a statement about truth at a specific history and time, we do not need time-shift preservation for the TruthLemma itself. ShiftClosed is needed for SOUNDNESS of the MF and TF axioms, not for the TruthLemma.

**Resolution**: For the TruthLemma, ShiftClosed is NOT required. We can use Option 1 for the full completeness proof (where ShiftClosed is needed for the connection to standard validity), but the TruthLemma itself works with any Omega. The critical requirement is that Omega has the right modal saturation properties.

#### Definition E: The Direct TruthLemma Statement

```lean
theorem canonical_truth_lemma
    (B : BFMCS Int) (h_tc : B.temporally_coherent)
    (fam : FMCS Int) (hfam : fam in B.families)
    (t : Int) (phi : Formula) :
    phi in fam.mcs t <->
      truth_at CanonicalTaskModel (CanonicalOmega B) (to_history fam) t phi
```

### Part 3: The Direct TruthLemma Proof Sketch

The proof proceeds by structural induction on phi.

#### Case: atom p

**Goal**: `atom p in fam.mcs t <-> truth_at M Omega (to_history fam) t (atom p)`

By definition:
```
truth_at M Omega tau t (atom p) = exists (ht : tau.domain t), M.valuation (tau.states t ht) p
```

Since `(to_history fam).domain t = True`, the existential is trivially satisfiable:
```
exists ht, M.valuation ((to_history fam).states t ht) p
  <-> M.valuation (fam.mcs t, fam.is_mcs t) p    (by definition of to_history)
  <-> atom p in (fam.mcs t, fam.is_mcs t).val     (by definition of canonical valuation)
  <-> atom p in fam.mcs t
```

**Difficulty**: None. This is definitional.

#### Case: bot

**Goal**: `bot in fam.mcs t <-> False`

Forward: bot in fam.mcs t contradicts MCS consistency.
Backward: False implies anything.

**Difficulty**: None. Same as current proof.

#### Case: imp phi psi

**Goal**: `(phi -> psi) in fam.mcs t <-> (truth_at ... phi -> truth_at ... psi)`

By IH: `phi in fam.mcs t <-> truth_at ... phi` and `psi in fam.mcs t <-> truth_at ... psi`.

Forward: If `(phi -> psi) in MCS` and `truth_at phi`, then by IH backward `phi in MCS`, then by MCS modus ponens `psi in MCS`, then by IH forward `truth_at psi`.

Backward: If `truth_at phi -> truth_at psi`, assume for contradiction `(phi -> psi) not in MCS`. Then by MCS maximality, `neg(phi -> psi) in MCS`. Classically derive `phi in MCS` and `neg(psi) in MCS`. By IH, `truth_at phi`. By hypothesis, `truth_at psi`. By IH backward, `psi in MCS`. Contradiction with `neg(psi) in MCS`.

**Difficulty**: None beyond current proof. The cross-dependency (forward direction uses backward IH) is inherent.

#### Case: box phi

**Goal**: `box phi in fam.mcs t <-> forall sigma in CanonicalOmega B, truth_at ... sigma t phi`

This is THE crucial case. Let us unpack it.

**Forward (box phi in MCS -> forall sigma in Omega, truth_at sigma t phi)**:

Suppose `box phi in fam.mcs t`. Let `sigma in CanonicalOmega B`. Then `sigma = to_history fam'` for some `fam' in B.families` (ignoring shifts for now -- see below).

By `B.modal_forward`: `box phi in fam.mcs t` implies `phi in fam'.mcs t` for all `fam' in B.families`.

By IH: `phi in fam'.mcs t` implies `truth_at M Omega (to_history fam') t phi`.

So `truth_at M Omega sigma t phi`.

**Backward (forall sigma in Omega, truth_at sigma t phi -> box phi in MCS)**:

Suppose for all `sigma in CanonicalOmega B`, `truth_at M Omega sigma t phi`. In particular, for each `fam' in B.families`, taking `sigma = to_history fam'`:

`truth_at M Omega (to_history fam') t phi`

By IH backward: `phi in fam'.mcs t`.

Since this holds for ALL `fam' in B.families`, by `B.modal_backward`: `box phi in fam.mcs t`.

**The shift complication**: If `CanonicalOmega` includes shifted histories, then we also need to handle `sigma = time_shift (to_history fam') delta` for arbitrary `delta`. The truth at time t in a shifted history is truth at time `t + delta` in the original history. So:

```
truth_at M Omega (time_shift (to_history fam') delta) t phi
```

This is NOT the same as `truth_at M Omega (to_history fam') t phi` in general (it involves `fam'.mcs (t + delta)` for atom evaluation, not `fam'.mcs t`).

**Resolution**: The forward direction works because `box phi in fam.mcs t` implies (by MF axiom: `Box(phi) -> Box(G(phi))`) that `Box(G(phi)) in fam.mcs t`, and by TF axiom `Box(phi) -> G(Box(phi))`, we get `G(Box(phi)) in fam.mcs t`. But this still quantifies over the bundle families, not over shifted histories at different times.

Actually, the issue is simpler. In the standard `truth_at` definition, the box case is:

```
truth_at M Omega tau t (box phi) = forall sigma in Omega, truth_at M Omega sigma t phi
```

Note: box evaluates phi at ALL sigma in Omega at THE SAME time t. So for a shifted history `sigma' = time_shift sigma delta`:

```
truth_at M Omega sigma' t (box phi) = forall rho in Omega, truth_at M Omega rho t phi
```

The box modality does NOT shift the time -- it keeps the same time t and changes the history. So the shift is irrelevant for the box case! All sigma' in Omega at time t will have the same box-truth, because box quantifies universally over Omega.

But wait -- the inner `truth_at M Omega sigma t phi` for atom p is:

```
exists (ht : sigma.domain t), M.valuation (sigma.states t ht) p
```

For `sigma = time_shift (to_history fam') delta`, the state at t is `fam'.mcs (t + delta)`, which is a DIFFERENT MCS than `fam'.mcs t`. So the forward direction of the box case requires:

`box phi in fam.mcs t` implies `phi in fam'.mcs (t + delta)` for all `fam' in B.families` and all `delta : Int`.

This is NOT what `B.modal_forward` gives us. `B.modal_forward` gives: `box phi in fam.mcs t` implies `phi in fam'.mcs t` for all `fam' in B.families` (at the SAME time t).

**This is a genuine problem with including shifts in Omega.** The solution has two paths:

**Path A: Don't include shifts in Omega (use only unshifted histories).**

Define:
```lean
def CanonicalOmega (B : BFMCS Int) : Set (WorldHistory CanonicalTaskFrame) :=
  { tau | exists fam in B.families, tau = to_history fam }
```

This is NOT ShiftClosed. But as noted above, ShiftClosed is not needed for the TruthLemma. It IS needed for soundness of MF/TF. But the TruthLemma only needs the box case to work, which it does when Omega = {to_history fam | fam in B.families}.

The completeness statement then says: there exists SOME Omega (not necessarily ShiftClosed) and some model such that the formula is true. This is sufficient because `satisfiable` only requires the existence of some model, and the valid definition... actually, `valid` requires ShiftClosed Omega. So the completeness result would be relative to BFMCS-validity, not standard validity. This is exactly what the current approach does.

To bridge to standard validity, we need ShiftClosed Omega. This requires **Path B**.

**Path B: Ensure the BFMCS is shift-closed.**

Augment the BFMCS construction so that B.families is closed under time-shifts: for every `fam in B.families` and `delta : Int`, the shifted family `shift_fam fam delta` (with `mcs t = fam.mcs (t + delta)`) is also in `B.families`.

If the BFMCS is shift-closed in this sense, then:
- `CanonicalOmega = {to_history fam | fam in B.families}` IS ShiftClosed
- The box case works: `box phi in fam.mcs t` implies `phi in fam'.mcs t` for all fam' in the (shift-closed) bundle, and all histories in Omega are `to_history fam'` for some such fam'.
- No shifted histories outside the bundle appear in Omega.

The key property: when the bundle is shift-closed, the modal coherence conditions at time t automatically cover all time-shifts, because every shifted family IS a bundle family, and modal coherence applies to all bundle families at any time.

**Assessment**: Path B is the correct approach. The BFMCS must be shift-closed. This is a construction requirement (on the BFMCS builder), not a proof obligation for the TruthLemma.

For NOW (the TruthLemma design), we can assume the BFMCS is shift-closed and proceed with Path B.

**Revised Omega definition**:

```lean
-- Assuming B is shift-closed (forall fam in B.families, forall delta,
--   shift_fam fam delta in B.families)
def CanonicalOmega (B : BFMCS Int) : Set (WorldHistory CanonicalTaskFrame) :=
  { tau | exists fam in B.families, tau = to_history fam }

-- This is ShiftClosed when B is shift-closed:
-- time_shift (to_history fam) delta = to_history (shift_fam fam delta)
-- shift_fam fam delta in B.families (by B shift-closed)
-- So time_shift (to_history fam) delta in CanonicalOmega B
```

**Box case with shift-closed B**:

Forward: `box phi in fam.mcs t` implies for all `fam' in B.families`, `phi in fam'.mcs t` (by `B.modal_forward`). Since every `sigma in CanonicalOmega B` is `to_history fam'` for some `fam' in B.families`, by IH, `truth_at M Omega sigma t phi`.

Backward: For all `sigma in CanonicalOmega B`, `truth_at M Omega sigma t phi`. Each such sigma is `to_history fam'` for some `fam' in B.families`. By IH, `phi in fam'.mcs t`. Since this holds for all `fam' in B.families`, by `B.modal_backward`, `box phi in fam.mcs t`.

**Difficulty**: Same as the current bmcs_truth_lemma box case. No additional difficulty.

#### Case: all_future phi (G phi)

**Goal**: `G phi in fam.mcs t <-> forall s, t <= s -> truth_at M Omega (to_history fam) s phi`

**Forward**: If `G phi in fam.mcs t`, then for all `s >= t`, by `fam.forward_G`, `phi in fam.mcs s`. By IH, `truth_at M Omega (to_history fam) s phi`.

**Backward**: Suppose for all `s >= t`, `truth_at M Omega (to_history fam) s phi`. By IH backward, for all `s >= t`, `phi in fam.mcs s`. We need `G phi in fam.mcs t`.

This is the temporal backward direction. By contraposition: if `G phi not in fam.mcs t`, then by MCS maximality, `neg(G phi) in fam.mcs t`. Since `neg(G phi)` is `(G phi) -> bot`, which via duality is equivalent to `F(neg phi) in fam.mcs t` (using temporal duality infrastructure from TemporalCoherentConstruction.lean). By `forward_F` (from `B.temporally_coherent`), there exists `s >= t` with `neg(phi) in fam.mcs s`. But `phi in fam.mcs s` (from hypothesis), contradicting MCS consistency.

**Difficulty**: Same as current proof. Requires `h_tc` (temporally coherent) which provides `forward_F`.

#### Case: all_past phi (H phi)

Symmetric to the all_future case, using `backward_H` for forward and `backward_P` (from `h_tc`) for the backward direction via contraposition.

**Difficulty**: Same as current proof.

### Part 4: Where BFMCS Was Providing Value

The BFMCS/bmcs_truth_at intermediate provided three things:

1. **Notational convenience**: `bmcs_truth_at B fam t phi` avoids threading the `TaskModel`, `Omega`, `WorldHistory` through the proof. Instead, it works directly with `fam.mcs t`.

2. **Abstraction from domain proofs**: The `bmcs_truth_at` atom case is `atom p in fam.mcs t` (no domain proof needed). The `truth_at` atom case is `exists (ht : tau.domain t), M.valuation (tau.states t ht) p`. With full domain (domain = True), the existential is trivially satisfiable, but it still must be explicitly constructed.

3. **Abstraction from Omega/ShiftClosed**: The BFMCS box case quantifies over families, not histories. This avoids dealing with the WorldHistory type and ShiftClosed condition during the TruthLemma proof.

**How the direct approach handles each**:

1. **Notation**: The direct proof is slightly more verbose but not fundamentally harder. The key terms `M.valuation (tau.states t ht) p` and `forall sigma in Omega` replace `atom p in fam.mcs t` and `forall fam' in B.families`.

2. **Domain proofs**: With `domain = fun _ => True`, the domain proof is `True.intro`. The existential in the atom case becomes `Exists.intro True.intro (...)`. This is 1-2 extra lines per atom case.

3. **Omega/ShiftClosed**: When B is shift-closed, `CanonicalOmega = {to_history fam | fam in B.families}` bijects with B.families, so the quantification over Omega is equivalent to quantification over families. No additional complexity.

**Conclusion**: The BFMCS intermediate provides minor notational convenience but no mathematical substance. The direct proof is slightly more verbose but structurally identical.

### Part 5: The Three Critical Obligations

#### Obligation 1: Modal Forward (box phi in MCS -> phi at all histories)

**In BFMCS approach**: `B.modal_forward fam hfam phi t h_box fam' hfam'` gives `phi in fam'.mcs t`.

**In direct approach**: Identical. `B.modal_forward` gives `phi in fam'.mcs t` for all `fam' in B.families`. Since every sigma in Omega is `to_history fam'` for some such fam', the IH converts this to `truth_at M Omega sigma t phi`.

**Mathematical content**: The same. Both rely on the `modal_forward` coherence condition of the BFMCS.

#### Obligation 2: Modal Backward / Saturation (phi at all histories -> box phi in MCS)

**In BFMCS approach**: `B.modal_backward fam hfam phi t h_all_mcs` gives `box phi in fam.mcs t`.

**In direct approach**: Identical. For each `fam' in B.families`, we have `truth_at M Omega (to_history fam') t phi`. By IH backward, `phi in fam'.mcs t`. Then `B.modal_backward` gives `box phi in fam.mcs t`.

**Mathematical content**: The same. Both rely on `modal_backward` coherence, which in turn relies on the BFMCS being constructed with sufficient modal saturation (diamond witnesses for each diamond obligation).

#### Obligation 3: Temporal Backward (phi at all future times -> G phi in MCS)

**In BFMCS approach**: Uses `temporal_backward_G` via `TemporalCoherentFamily`, which requires `forward_F` from `h_tc`.

**In direct approach**: Identical. The `truth_at` at all future times gives (by IH backward) `phi in fam.mcs s` for all `s >= t`. The contraposition argument then proceeds identically to produce `G phi in fam.mcs t`.

**Mathematical content**: The same. Both rely on `forward_F` from temporal coherence.

### Part 6: The Role of task_rel in the Semantics

A critical finding: **task_rel does NOT appear in the definition of truth_at.**

Looking at Truth.lean:
- `truth_at` references `tau.domain`, `tau.states`, `M.valuation`, and `Omega`
- It does NOT reference `F.task_rel`

The task_rel appears only in:
- `TaskFrame` structure (nullity + compositionality constraints)
- `WorldHistory.respects_task` (structural well-formedness of histories)

This means:
1. The TruthLemma proof does not need task_rel AT ALL
2. task_rel is needed only for constructing a well-typed `TaskFrame` and `WorldHistory`
3. The compositionality of task_rel can be proven SEPARATELY from the TruthLemma

**Practical consequence**: We can define `CanonicalTaskFrame` with `sorry` for compositionality (or prove it separately) and still prove the TruthLemma. The compositionality obligation is orthogonal to the truth lemma.

### Part 7: Assessment: Direct vs BFMCS Approach

| Criterion | BFMCS (current) | Direct (proposed) |
|-----------|------------------|-------------------|
| Mathematical content | TruthLemma + Bridge | TruthLemma only |
| Lines of proof | ~400 (TruthLemma) + ~100 (Bridge) | ~450 (Direct TruthLemma) |
| Intermediate definitions | bmcs_truth_at, bmcs_valid, bmcs_consequence | None (uses standard truth_at, valid, semantic_consequence) |
| Domain proof overhead | None | Trivial (True.intro) |
| Completeness target | BFMCS-validity (custom) | Standard validity (from Validity.lean) |
| ShiftClosed requirement | Not needed for TruthLemma | Not needed for TruthLemma; needed for Omega |
| Dependency on BFMCS module | Yes (BFMCS.lean, BFMCSTruth.lean) | Yes (BFMCS.lean for modal coherence; NOT BFMCSTruth.lean) |
| Reusability | Limited (BFMCS-specific) | Direct (uses standard semantics) |

**Verdict**: The direct approach is slightly more verbose but eliminates one intermediate layer (bmcs_truth_at) and one additional theorem (bridge). It produces a completeness result directly in terms of the standard semantics (Validity.lean), which is the actual target. The mathematical difficulty is identical.

**Recommendation**: Use the direct approach. Keep the existing bmcs_truth_lemma and BFMCSTruth.lean as legacy/reference, but build the new direct TruthLemma as the primary completeness path.

## ROAD_MAP.md Reflection

### Pitfalls Checked

| Dead End | Relevance | Impact on Recommendations |
|----------|-----------|--------------------------|
| Single-History FDSM | LOW | Direct approach still uses multi-family BFMCS for modal saturation. Not affected. |
| Single-Family BFMCS modal_backward | LOW | Direct approach still requires multi-family bundle. Not affected. |
| Constant Witness Family | LOW | Direct approach uses time-varying FMCS from DovetailingChain. Not affected. |
| MCS-Membership Semantics for Box | MEDIUM | The direct approach uses recursive truth_at (standard), NOT MCS membership for box. Aligns with this lesson. |
| CanonicalReachable/CanonicalQuotient | LOW | Direct approach uses Z-indexed timelines from step-by-step construction. Not affected. |

### Strategy Alignment

| Strategy | Status | Relevance |
|----------|--------|-----------|
| Indexed MCS Family Approach | ACTIVE | The direct approach builds on FMCS/BFMCS. It removes the bmcs_truth_at layer but keeps the BFMCS as the source of modal coherence. |
| Representation-First Architecture | CONCLUDED | The direct TruthLemma IS the representation theorem (MCS membership <-> standard truth). Fully aligned. |

## Context Extension Recommendations

### Discovered Concepts Requiring Documentation

| Concept | Report Section | Currently Documented? | Gap Type |
|---------|----------------|----------------------|----------|
| task_rel non-participation in truth_at | Part 6 | No | extension |
| ShiftClosed vs TruthLemma independence | Part 3 (box case) | No | extension |
| Shift-closed BFMCS | Part 3 (Definition D) | No | extension |

### Existing Context File Extensions

| File | Section to Add/Modify | Content to Add | Priority | Create Task? |
|------|----------------------|----------------|----------|--------------|
| `task-semantics.md` | task_rel role section | Document that task_rel does not appear in truth_at; its role is structural | Medium | No |

### Summary

- **New files needed**: 0
- **Extensions needed**: 1
- **Tasks to create**: 0
- **High priority gaps**: 0

## Decisions

1. **The direct approach IS correct and recommended.** The `bmcs_truth_at` intermediate provides no mathematical substance.
2. **The BFMCS structure is still essential** -- it provides modal coherence (`modal_forward`, `modal_backward`) and temporal coherence (`forward_F`, `backward_P`). The direct approach removes `bmcs_truth_at` but keeps `BFMCS`.
3. **task_rel does not participate in truth_at.** Compositionality can be proven separately or deferred.
4. **ShiftClosed is not needed for the TruthLemma.** It is needed for the bridge to standard validity.
5. **For a shift-closed Omega**, the BFMCS must be shift-closed (closed under time-shifting of families).
6. **The direct TruthLemma statement** should be:
   ```lean
   phi in fam.mcs t <-> truth_at CanonicalTaskModel CanonicalOmega (to_history fam) t phi
   ```

## Risks & Mitigations

1. **Risk**: The atom case has slightly more boilerplate due to domain existential.
   **Mitigation**: With full domain (True), the existential is trivially satisfiable. A helper lemma `truth_at_atom_of_full_domain` can factor this out.

2. **Risk**: Compositionality of CanonicalTaskFrame is nontrivial (cross-sign cases).
   **Mitigation**: task_rel does not appear in truth_at. Compositionality can be proven later or with sorry, without affecting the TruthLemma.

3. **Risk**: ShiftClosed bundle may be hard to construct.
   **Mitigation**: For the TruthLemma, ShiftClosed is not needed. For standard validity bridge, the shift-closure construction can be added as a separate component.

4. **Risk**: Lean 4 dependent type issues with `to_history` (subtype for WorldState, domain proofs).
   **Mitigation**: Full domain eliminates domain complexity. The subtype `{ M : Set Formula // SetMaximalConsistent M }` is standard and well-supported by Lean.

5. **Risk**: The direct approach may seem like duplication of bmcs_truth_lemma.
   **Mitigation**: The direct TruthLemma REPLACES bmcs_truth_lemma on the completeness path. The old bmcs_truth_lemma can be archived or kept as an intermediate result.

## Appendix

### Key Codebase Files Examined

- `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Semantics/Truth.lean` - truth_at definition (6 cases)
- `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Semantics/WorldHistory.lean` - WorldHistory structure, time_shift, respects_task
- `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Semantics/TaskFrame.lean` - TaskFrame structure (WorldState, task_rel, nullity, compositionality)
- `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Semantics/TaskModel.lean` - TaskModel (valuation function)
- `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Semantics/Validity.lean` - valid, ShiftClosed, semantic_consequence
- `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic/Bundle/BFMCSTruth.lean` - bmcs_truth_at definition
- `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic/Bundle/TruthLemma.lean` - bmcs_truth_lemma (all 6 cases proven)
- `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic/Bundle/BFMCS.lean` - BFMCS structure (modal_forward, modal_backward)
- `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic/Bundle/FMCS.lean` - FMCS re-export
- `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic/Bundle/FMCSDef.lean` - FMCS definition (forward_G, backward_H)
- `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic/Bundle/CanonicalFrame.lean` - CanonicalR, canonical_forward_G/F, canonicalR_reflexive/transitive
- `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic/Bundle/TemporalContent.lean` - GContent, HContent definitions
- `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic/Bundle/TemporalCoherentConstruction.lean` - temporal_backward_G/H, G_dne_theorem
- `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic/Bundle/Completeness.lean` - bmcs_representation, bmcs_weak_completeness, bmcs_strong_completeness
- `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/ProofSystem/Axioms.lean` - 17 axiom schemata
