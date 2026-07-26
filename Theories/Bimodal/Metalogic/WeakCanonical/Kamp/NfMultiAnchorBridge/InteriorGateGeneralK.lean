/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import Bimodal.Metalogic.WeakCanonical.Kamp.NfMultiAnchorBridge.PriorInterface
import Bimodal.Metalogic.WeakCanonical.Kamp.NfMultiAnchorBridge.OuterGate
import Bimodal.Metalogic.WeakCanonical.Kamp.NfMultiAnchorBridge.ExteriorBracketK

/-!
# General-`k` INTERIOR gate correctness

A NEW **leaf sibling** of `PriorInterface.lean` / `OuterGate.lean` inside `NfMultiAnchorBridge/`.
It is **purely additive**: nothing here re-proves or edits the frozen carrier
`bracketEndChar_kv` (`CarrierKv.lean:238`), the provider interface `ExistProviders` /
`BracketCarrierCorrectVPrior` (`PriorInterface.lean:38/60`), or the k=2 template family in
`OuterGate.lean`. Those are treated as verified INPUTS; this file only *applies* them.

## What this file delivers

The general-`k` interior gate correctness lemma `bracketEndChar_kv_correct_prior`, provider-guarded,
sorry-free, and axiom-clean, consumed by the consumer-side reshape `endIntervalStepPrior`
(`EndIntervalConsumerK.lean`) and the induction built on it. (The original in-carrier
`endIntervalStep` skeleton was superseded and is archived at
`Kamp/Boneyard/NfMultiAnchorBridgeRetired/EndIntervalSkeleton.lean`.)

## CRITICAL — the general-`k` statement is PROVIDER-GUARDED, not unconditional (finding F1)

`bracketEndChar_kv_factors` (`CarrierKv.lean:422`) proves the depth-`k` carrier factors through ONLY
the atom layer + the off-fiber Prop + the fiber-EXISTENTIAL fold bits: two quant layers agreeing on
that data yield EQUAL carriers even when they disagree on the marking of individual depth-`k`
arity-4
subs inside a shared `(zoneSpec, projFresh)` fiber. That machine-checks the ISOLATION half of F1 —
the UNCONDITIONAL k ≥ 2 soundness direction is REFUTED (a lossy carrier cannot recover which marked
sub realized a fiber). Therefore the deliverable is the **provider-guarded** shape: the target
predicate is `BracketCarrierCorrectVPrior` (`PriorInterface.lean:60`) — the UZ/SZ-relativized,
provider-conditional variant — mirroring the k=2 template `bracketEndChar_kvE2_sound_two_prior_frag`
(`OuterGate.lean:268`) / `bracketEndChar_kvE2_complete_two_prior` (`OuterGate.lean:147`) and the
consumer's `EndIntervalCorrectPrior`. An unconditional general-`k` statement is a
known dead end (F1) and MUST NOT be pursued.

## Recursion structure

- **Base k = 0 / k = 1** (delivered upstream, CONSUMED not rebuilt): the target predicate is
  discharged by `bracketEndChar_kv_correct_zero_prior` (`PriorInterface.lean:80`) and
  `bracketEndChar_kv_correct_one_prior` (`PriorInterface.lean:95`). Phase 1 (this file) validates
  the
  FREEZE by re-deriving those two base rungs against the frozen `InteriorGateTarget` Prop.
- **Step k → k + 1** (the substantial construction, Phases 2-5): provider/char truth bridges, the
  `holds_iff` destructuring of the successor carrier, the ⇐ completeness half, and the F1-critical ⇒
  soundness half (provider obligations reconstruct the lost fiber content).
- **General-`k` close** (Phase 6): `Nat`-induction assembling the base rungs and the step gate.
-/

namespace Bimodal.Metalogic.WeakCanonical.Kamp

open Bimodal.Syntax
open Bimodal.Metalogic.WeakCanonical
open Bimodal.Metalogic.WeakCanonical.Separation
  (nf_depth0_char_formula formula_conjList formula_conjList_iff)

/-! ## Phase 1 — frozen general-`k` statement + base-rung reconciliation

`InteriorGateTarget` freezes the provider-guarded deliverable shape: the target predicate is the
UZ/SZ-relativized `BracketCarrierCorrectVPrior` (`PriorInterface.lean:60`) applied to the depth-`k`
carrier `bracketEndChar_kv`. This is the byte-quotable conclusion the consumer (the consumer-side
reshape `endIntervalStepPrior` in `EndIntervalConsumerK.lean` / `EndIntervalCorrectPrior`)
consumes, and the conclusion the k=2 template
`bracketEndChar_kvE2_correct_two_prior_frag` (`OuterGate.lean:359`) already delivers at `k = 2`
under
its fragment/provider binders. Freezing it as a `def` (not a `theorem`) records the target without a
proof obligation; the `∀ k` theorem is assembled in Phase 6.

The base-rung reconciliation lemmas below VALIDATE the freeze (Risk R1 mitigation): the k = 0 and
k = 1 instances of the frozen `InteriorGateTarget` discharge cleanly from the landed base rungs
`bracketEndChar_kv_correct_zero_prior` / `_one_prior`, confirming the frozen predicate is the
correct
provider-guarded shape BEFORE any step proof is attempted. -/

/-- **Frozen general-`k` interior-gate target predicate**. The provider-guarded
    deliverable shape: `BracketCarrierCorrectVPrior atomMap (bracketEndChar_kv atomMap h_surj charF
    k)`
    — the UZ/SZ-relativized carrier correctness at the FIXED anchor pair `(x, t)`
    (`PriorInterface.lean:60`). Frozen per finding F1 (see the file header): the UNCONDITIONAL k ≥ 2
    variant is refuted by `bracketEndChar_kv_factors` (`CarrierKv.lean:422`), so the deliverable is
    the provider-conditional predicate, mirroring the k=2 template's `_two_prior` shape and the task
    349 Phase 5 consumer `EndIntervalCorrectPrior`. -/
def InteriorGateTarget {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds]
    (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    (charF : (j : Nat) → NormalForm sig j 1 → Formula)
    (k : Nat) : Prop :=
  BracketCarrierCorrectVPrior atomMap (bracketEndChar_kv atomMap h_surj charF k)

/-- **Base-rung reconciliation, k = 0**. The k = 0 instance
    of the frozen `InteriorGateTarget` is discharged by the landed base rung
    `bracketEndChar_kv_correct_zero_prior` (`PriorInterface.lean:80`) verbatim. This confirms the
    frozen provider-guarded predicate weakens cleanly to the unconditional depth-0 base (the k = 0
    provider obligations are vacuously satisfiable). No chain step is shortcut (G5): pure
    consumption. -/
theorem interiorGateTarget_zero {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds]
    (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    (charF : (j : Nat) → NormalForm sig j 1 → Formula) :
    InteriorGateTarget atomMap h_surj charF 0 :=
  bracketEndChar_kv_correct_zero_prior atomMap h_surj charF

/-- **Base-rung reconciliation, k = 1**. The k = 1 instance
    of the frozen `InteriorGateTarget`, under the depth-0 provider agreement `h0` (satisfied by the
    Phase-14 instantiation by construction, `KampPrior:397` at depth 0), is discharged by the landed
    base rung `bracketEndChar_kv_correct_one_prior` (`PriorInterface.lean:95`) verbatim. This
    confirms the frozen provider-guarded predicate weakens cleanly to the first successor base rung.
    No chain step is shortcut (G5): pure consumption. -/
theorem interiorGateTarget_one {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds]
    (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    (charF : (j : Nat) → NormalForm sig j 1 → Formula)
    (h0 : charF 0 = nf_depth0_char_formula atomMap h_surj) :
    InteriorGateTarget atomMap h_surj charF 1 :=
  bracketEndChar_kv_correct_one_prior atomMap h_surj charF h0

/-! ## Phase 2 — depth-`k` provider / char-layer truth bridges

The general-`k` analogs of the k=2 char-formula bridges `bracketEndChar_kvE2_hcb`
(`OuterGate.lean:102`) and `_hck` (`OuterGate.lean:123`). The char-BASE bridge `_hcb` is already
depth-0-general (it is about `nf_depth0_char_formula`, independent of the fold depth), so it is
consumed directly from `OuterGate.lean` — the atom-layer point-type bridge for the endpoint/pivot
`E[Σ]` literals. The provider bridge `_hck` is generalized here from the hard-wired depth-1
`P.existF 0` to an arbitrary-depth `P : ExistProviders sig atomMap k` via the
`ExistProviders.correct`
field at `n = 0` and the `insertEnv`/`Fin.elim0` env collapse (`insertEnv` on the empty env is
`fun _ => u`). Manual bridge only — no simp/omega/aesop shortcut of a Rabinovich chain step (G5);
the
`insertEnv` collapse is pure `Fin 0` bookkeeping, not a fold step. -/

/-- **Depth-`k` provider-layer truth bridge** (general-`k` analog of
    `bracketEndChar_kvE2_hck`, `OuterGate.lean:123`). For a depth-`k` provider bundle
    `P : ExistProviders sig atomMap k`, the depth-`k` existential provider formula `P.existF 0 χ` is
    truth-equivalent to the arity-1 depth-`k` evaluation, via `ExistProviders.correct` at `n = 0`
    and
    the `Fin 0 → M.carrier` env collapse. This is the per-fiber point-type truth equivalence the
    step
    proof (Phases 4-5) consumes at the endpoint/pivot `charK` literals. -/
theorem interiorGate_hck {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds]
    {k : Nat}
    (atomMap : Formula → sig.preds)
    (P : ExistProviders sig atomMap k)
    (M : OrderedMonadicStructure sig)
    (h_UZ : semantic_prior_UZ M atomMap) (h_SZ : semantic_prior_SZ M atomMap)
    (χ : NormalForm sig k 1) (u : M.carrier) :
    temporal_truth M atomMap u (P.existF 0 χ) ↔ nf_eval_nf M k 1 (fun _ => u) χ := by
  rw [P.correct 0 χ M h_UZ h_SZ u]
  constructor
  · rintro ⟨env, henv⟩
    have heq : insertEnv env u = (fun _ => u) := by
      funext i
      simp only [insertEnv]
      rw [dif_neg (by omega)]
    rwa [heq] at henv
  · intro h
    exact ⟨Fin.elim0, by rw [insertEnv_zero]; exact h⟩

/-- **Depth-0 char-base truth bridge** (re-export of the depth-0-general
    `bracketEndChar_kvE2_hcb`, `OuterGate.lean:102`). The standard-instantiation depth-0
    characteristic formula is truth-equivalent to the arity-1 depth-0 evaluation. Depth-0 and
    fold-depth-independent, so it is the SAME bridge at every `k` — named here for the step proof's
    endpoint/witness base types (`xType`/`tType`/`ptW`, the depth-0 atom-layer projections). -/
theorem interiorGate_hcb {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds]
    (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    (M : OrderedMonadicStructure sig) (χ : NormalForm sig 0 1) (u : M.carrier) :
    temporal_truth M atomMap u (nf_depth0_char_formula atomMap h_surj χ) ↔
      nf_eval_nf M 0 1 (fun _ => u) χ :=
  bracketEndChar_kvE2_hcb atomMap h_surj M χ u

/-! ## Phase 3 — body-destructuring `holds_iff` at depth `k`

The successor carrier `bracketEndChar_kv … (k+1)` is DEFINITIONALLY `kv_body` at the depth-`k`
providers (`CarrierKv.lean:244-249`), but `kv_body` is a `private noncomputable def` in the FROZEN
`CarrierKv.lean:152` — its `let`-bound internal structure (`gate`, `S_L`/`S_R`, `mkDisjunct`,
`epL`/`epR`/`segL`/`segR`/`ptW`) cannot be referenced by name from this sibling module, and no
public
holds-unfold lemma for `bracketEndChar_kv (k+1)` exists. So this section builds a PUBLIC BODY
REPLICA
(`igBody`) from named public pieces (`igGate`, `igSL`, `igSR`, `igMkDisjunct`, …), each a verbatim
copy of the corresponding `kv_body` `let`. The replica is proved DEFINITIONALLY EQUAL to the frozen
successor carrier by `rfl` (`bracketEndChar_kv_succ_eq`) — the `@dite _ gate (Classical.dec gate)`
decidability instance is reproduced EXACTLY so the defeq goes through. Once exposed, the carrier's
`.holds` destructures (via the already-available `VVecEA2.holds_flatMap_map`,
`NavigatedSpine.lean:220`)
into the off-fiber gate conjunct ∧ the `S_L`/`S_R` permutation-arrangement disjunction
(`bracketEndChar_kv_succ_holds_iff`). The fold-bit read is kept FIBER-EXISTENTIAL (`igFoldBit`,
`decide (∃ sub, …)`) — NOT collapsed pointwise (that collapse is valid only at `k = 1` via
`bracketEndChar_kv_one_eq`, and is exactly the F1 information loss at `k ≥ 2`). -/

noncomputable section

/-- Zone-order bit `<` (verbatim from `kv_body`'s `ltz`, `CarrierKv.lean:160`). -/
def igLtz : Bool × Bool := (true, false)
/-- Zone-order bit `=` (verbatim from `kv_body`'s `eqz`, `CarrierKv.lean:161`). -/
def igEqz : Bool × Bool := (false, false)
/-- Zone-order bit `>` (verbatim from `kv_body`'s `gtz`, `CarrierKv.lean:162`). -/
def igGtz : Bool × Bool := (false, true)
/-- Zone-spec builder for env `[w, x, t]` (verbatim from `kv_body`'s `mk3`,
`CarrierKv.lean:163`). -/
def igMk3 (pw px pt : Bool × Bool) : ZoneSpec 3 := Fin.cons pw (Fin.cons px (fun _ => pt))
/-- Zone `x_1 < x` (verbatim from `kv_body`'s `zPastX`, `CarrierKv.lean:165`). -/
def igZPastX : ZoneSpec 3 := igMk3 igLtz igLtz igLtz
/-- Zone `x_1 = x` (verbatim from `kv_body`'s `zAtX`, `CarrierKv.lean:166`). -/
def igZAtX : ZoneSpec 3 := igMk3 igLtz igEqz igLtz
/-- Zone `x < x_1 < w` (verbatim from `kv_body`'s `zXW`, `CarrierKv.lean:167`). -/
def igZXW : ZoneSpec 3 := igMk3 igLtz igGtz igLtz
/-- Zone `x_1 = w` (verbatim from `kv_body`'s `zAtW`, `CarrierKv.lean:168`). -/
def igZAtW : ZoneSpec 3 := igMk3 igEqz igGtz igLtz
/-- Zone `w < x_1 < t` (verbatim from `kv_body`'s `zWT`, `CarrierKv.lean:169`). -/
def igZWT : ZoneSpec 3 := igMk3 igGtz igGtz igLtz
/-- Zone `x_1 = t` (verbatim from `kv_body`'s `zAtT`, `CarrierKv.lean:170`). -/
def igZAtT : ZoneSpec 3 := igMk3 igGtz igGtz igEqz
/-- Zone `t < x_1` (verbatim from `kv_body`'s `zFutT`, `CarrierKv.lean:171`). -/
def igZFutT : ZoneSpec 3 := igMk3 igGtz igGtz igGtz

/-- Enumeration of complete depth-`k` 1-types (verbatim from `kv_body`'s `allTypes`,
    `CarrierKv.lean:172`). -/
def igAllTypes (sig : MonadicSignature) [Fintype sig.preds] [DecidableEq sig.preds] (k : Nat) :
    List (NormalForm sig k 1) := Finset.univ.toList
/-- Biconditional literal at an anchor (verbatim from `kv_body`'s `lit`, `CarrierKv.lean:174`). -/
def igLit (bit : Bool) (f : Formula) : Formula := if bit then f else f.neg

/-- Left endpoint predicate `epL` at the fixed left endpoint `x` (verbatim from `kv_body`,
    `CarrierKv.lean:178-182`). -/
def igEpL {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds] {k : Nat}
    (charBase : NormalForm sig 0 1 → Formula) (charK : NormalForm sig k 1 → Formula)
    (r : NormalForm sig 0 3) (b : ZoneSpec 3 → NormalForm sig k 1 → Bool) : TemporalPred :=
  ⟨formula_conjList
    (charBase (nf_x_proj3 r)
      :: (igAllTypes sig k).map (fun χ => igLit (b igZPastX χ) (Formula.snce (charK χ) Formula.top))
      ++ (igAllTypes sig k).map (fun χ => igLit (b igZAtX χ) (charK χ)))⟩

/-- Right endpoint predicate `epR` at the fixed right endpoint `t` (verbatim from `kv_body`,
    `CarrierKv.lean:183-187`). -/
def igEpR {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds] {k : Nat}
    (charBase : NormalForm sig 0 1 → Formula) (charK : NormalForm sig k 1 → Formula)
    (r : NormalForm sig 0 3) (b : ZoneSpec 3 → NormalForm sig k 1 → Bool) : TemporalPred :=
  ⟨formula_conjList
    (charBase (nf_t_proj3 r)
      :: (igAllTypes sig k).map (fun χ => igLit (b igZAtT χ) (charK χ))
      ++ (igAllTypes sig k).map (fun χ => igLit (b igZFutT χ)
          (Formula.untl (charK χ) Formula.top)))⟩

/-- Left segment exclusion `segL` (verbatim from `kv_body`, `CarrierKv.lean:189-191`). -/
def igSegL {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds] {k : Nat}
    (charK : NormalForm sig k 1 → Formula) (b : ZoneSpec 3 → NormalForm sig k 1 → Bool) :
    TemporalPred :=
  ⟨formula_conjList ((igAllTypes sig k).map (fun χ =>
    if b igZXW χ then Formula.top else (charK χ).neg))⟩

/-- Right segment exclusion `segR` (verbatim from `kv_body`, `CarrierKv.lean:192-194`). -/
def igSegR {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds] {k : Nat}
    (charK : NormalForm sig k 1 → Formula) (b : ZoneSpec 3 → NormalForm sig k 1 → Bool) :
    TemporalPred :=
  ⟨formula_conjList ((igAllTypes sig k).map (fun χ =>
    if b igZWT χ then Formula.top else (charK χ).neg))⟩

/-- Witness point type `ptW` at the interior anchor `w` (verbatim from `kv_body`,
    `CarrierKv.lean:197-200`). -/
def igPtW {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds] {k : Nat}
    (charBase : NormalForm sig 0 1 → Formula) (charK : NormalForm sig k 1 → Formula)
    (r : NormalForm sig 0 3) (b : ZoneSpec 3 → NormalForm sig k 1 → Bool) : TemporalPred :=
  ⟨formula_conjList
    (charBase (nf_y_proj r)
      :: (igAllTypes sig k).map (fun χ => igLit (b igZAtW χ) (charK χ)))⟩

/-- The gate Prop: off-fiber honesty ∧ order-conflict falsity (verbatim from `kv_body`'s `gate`,
    `CarrierKv.lean:206-208`, with `consistent` inlined, `CarrierKv.lean:202-203`). -/
def igGate {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds] {k : Nat}
    (offFiber : Prop) (b : ZoneSpec 3 → NormalForm sig k 1 → Bool) : Prop :=
  offFiber ∧
  (∀ (zs : ZoneSpec 3) (χ : NormalForm sig k 1),
    ¬ (zs = igZPastX ∨ zs = igZAtX ∨ zs = igZXW ∨ zs = igZAtW ∨ zs = igZWT ∨ zs = igZAtT ∨
        zs = igZFutT) →
      b zs χ = false)

/-- Interior-positive left enumeration `S_L` (verbatim from `kv_body`, `CarrierKv.lean:210`). -/
def igSL {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds] {k : Nat}
    (b : ZoneSpec 3 → NormalForm sig k 1 → Bool) : List (NormalForm sig k 1) :=
  (igAllTypes sig k).filter (fun χ => b igZXW χ)

/-- Interior-positive right enumeration `S_R` (verbatim from `kv_body`, `CarrierKv.lean:211`). -/
def igSR {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds] {k : Nat}
    (b : ZoneSpec 3 → NormalForm sig k 1 → Bool) : List (NormalForm sig k 1) :=
  (igAllTypes sig k).filter (fun χ => b igZWT χ)

/-- Per-type witness predicate `charP` (verbatim from `kv_body`, `CarrierKv.lean:212`). -/
def igCharP {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds] {k : Nat}
    (charK : NormalForm sig k 1 → Formula) : NormalForm sig k 1 → TemporalPred :=
  fun χ => ⟨charK χ⟩

/-- One arrangement disjunct (verbatim from `kv_body`'s `mkDisjunct`, `CarrierKv.lean:215-220`). -/
def igMkDisjunct {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds] {k : Nat}
    (charBase : NormalForm sig 0 1 → Formula) (charK : NormalForm sig k 1 → Formula)
    (r : NormalForm sig 0 3) (b : ZoneSpec 3 → NormalForm sig k 1 → Bool)
    (lL lR : List (NormalForm sig k 1)) : Σ n, VecEA2 n :=
  ⟨(lL.map (igCharP charK)).length + 1 + (lR.map (igCharP charK)).length,
    { endpointLeft := igEpL charBase charK r b
      endpointRight := igEpR charBase charK r b
      bracket := bracketFromLists (lL.map (igCharP charK)) (igPtW charBase charK r b)
        (lR.map (igCharP charK)) (igSegL charK b) (igSegR charK b) }⟩

/-- **PUBLIC body replica of `kv_body`'s successor branch**. Verbatim copy of
    the frozen private `kv_body` (`CarrierKv.lean:221-226`) at the `@dite _ gate (Classical.dec
    gate)`
    gate, built from the named public pieces above so its internal structure is referenceable.
    Proved
    definitionally equal to `bracketEndChar_kv … (k+1)` by `rfl` in `bracketEndChar_kv_succ_eq`. -/
def igBody {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds] {k : Nat}
    (charBase : NormalForm sig 0 1 → Formula) (charK : NormalForm sig k 1 → Formula)
    (r : NormalForm sig 0 3) (offFiber : Prop) (b : ZoneSpec 3 → NormalForm sig k 1 → Bool) :
    VVecEA2 :=
  @dite _ (igGate offFiber b) (Classical.dec (igGate offFiber b))
    (fun _ =>
      { disjuncts :=
          (igSL b).permutations.flatMap (fun lL =>
            (igSR b).permutations.map (fun lR => igMkDisjunct charBase charK r b lL lR)) })
    (fun _ => { disjuncts := [] })

/-- The off-fiber-honesty conjunct of the successor carrier's gate at `qnf` (verbatim from
    `bracketEndChar_kv`'s `k+1` branch, `CarrierKv.lean:246-247`). -/
def igOffFiber {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds] {k : Nat}
    (qnf : NormalForm sig (k + 1) 3) : Prop :=
  ∀ sub : NormalForm sig k 4, nf0_dropFresh (NormalForm.atom_assgn sub) ≠ qnf.1 → qnf.2 sub = false

/-- The FIBER-EXISTENTIAL fold-bit read of the successor carrier at `qnf` (verbatim from
    `bracketEndChar_kv`'s `k+1` branch, `CarrierKv.lean:248-249`). Kept existential (a `decide` of
    `∃ sub, …`), never collapsed pointwise — the F1 information channel at `k ≥ 2`.

    The `Decidable` instance is written EXPLICITLY to match the frozen carrier's fold bit BYTE FOR
    BYTE: the frozen `bracketEndChar_kv` is elaborated under `open Classical in` in a module where
    no `DecidableEq (ZoneSpec 3)` instance is in scope, so its `nf0_zoneSpec … = zs` conjunct is
    decided by `Classical.propDecidable`. This sibling module DOES have `DecidableEq (ZoneSpec 3)`
    in scope, so a plain `decide` would pick the real instance and the carriers would fail to be
    definitionally equal. Reproducing the exact nested instance
    (`Fintype.decidableExistsFintype` over `And` of `instDecidableEqBool` /
    `Classical.propDecidable`
    (the ZoneSpec eq) / `normalForm_decEq`) makes `bracketEndChar_kv_succ_eq` a `rfl`. -/
noncomputable def igFoldBit {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds]
    {k : Nat} (qnf : NormalForm sig (k + 1) 3) :
    ZoneSpec 3 → NormalForm sig k 1 → Bool :=
  fun zs χ =>
    @decide (∃ sub : NormalForm sig k 4, qnf.2 sub = true ∧
        nf0_zoneSpec (NormalForm.atom_assgn sub) = zs ∧ nfk_projFresh sub = χ)
      (@Fintype.decidableExistsFintype (NormalForm sig k 4)
        (fun sub => qnf.2 sub = true ∧ nf0_zoneSpec (NormalForm.atom_assgn sub) = zs ∧
          nfk_projFresh sub = χ)
        (fun a => @instDecidableAnd (qnf.2 a = true)
          (nf0_zoneSpec (NormalForm.atom_assgn a) = zs ∧ nfk_projFresh a = χ)
          (instDecidableEqBool (qnf.2 a) true)
          (@instDecidableAnd (nf0_zoneSpec (NormalForm.atom_assgn a) = zs) (nfk_projFresh a = χ)
            (Classical.propDecidable (nf0_zoneSpec (NormalForm.atom_assgn a) = zs))
            (normalForm_decEq sig k 1 (nfk_projFresh a) χ)))
        (normalForm_fintype sig k 4))

set_option maxHeartbeats 1600000 in
-- `bracketEndChar_kv_succ_eq` elaborates the general-`k` interior gate composition together with
-- its full provider inventory in a single declaration; the default 200000-heartbeat budget is
-- not enough to typecheck it.
/-- **Defeq bridge: the successor carrier IS the public replica**. The `k+1`
    branch of `bracketEndChar_kv` (`CarrierKv.lean:244-249`) is `kv_body` at the depth-`k`
    providers,
    and `igBody` is a verbatim copy of `kv_body`'s body, so the two are DEFINITIONALLY EQUAL — pure
    `rfl`, no semantics. This exposes the frozen private carrier's structure for destructuring. -/
theorem bracketEndChar_kv_succ_eq {sig : MonadicSignature} [Fintype sig.preds]
    [DecidableEq sig.preds] {k : Nat}
    (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    (charF : (j : Nat) → NormalForm sig j 1 → Formula)
    (qnf : NormalForm sig (k + 1) 3) :
    bracketEndChar_kv atomMap h_surj charF (k + 1) qnf =
      igBody (nf_depth0_char_formula atomMap h_surj) (charF k) qnf.1
        (igOffFiber qnf) (igFoldBit qnf) := by
  -- `bracketEndChar_kv (k+1)` reduces (equation lemma) to the frozen private `kv_body` at these
  -- args; `igBody` is a verbatim public copy at the SAME args (the fold-bit instance is matched
  -- byte-for-byte by `igFoldBit`), so the two are definitionally equal. Pure `rfl`, no semantics.
  simp only [bracketEndChar_kv]
  rfl

/-- **`holds` destructuring of the public replica**. The replica's `VVecEA2.holds`
    splits into the gate conjunct ∧ the `S_L`/`S_R` permutation-arrangement disjunction. On-gate the
    body is the `flatMap`/`map` disjunct list (destructured by `VVecEA2.holds_flatMap_map`,
    `NavigatedSpine.lean:220`); off-gate it is the empty disjunction `⟨[]⟩` whose `holds` is `False`
    (matching the failed gate on the RHS). No chain step is shortcut (G5): pure list-membership and
    `dite` computation. -/
theorem igBody_holds_iff {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds]
    {k : Nat}
    (charBase : NormalForm sig 0 1 → Formula) (charK : NormalForm sig k 1 → Formula)
    (r : NormalForm sig 0 3) (offFiber : Prop) (b : ZoneSpec 3 → NormalForm sig k 1 → Bool)
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds) (x t : M.carrier) :
    (igBody charBase charK r offFiber b).holds M atomMap x t ↔
      igGate offFiber b ∧
      ∃ lL ∈ (igSL b).permutations, ∃ lR ∈ (igSR b).permutations,
        (igMkDisjunct charBase charK r b lL lR).2.holds M atomMap x t := by
  unfold igBody
  by_cases hg : igGate offFiber b
  · rw [dif_pos hg,
      VVecEA2.holds_flatMap_map M atomMap (igSL b).permutations (igSR b).permutations
        (igMkDisjunct charBase charK r b) x t]
    exact ⟨fun h => ⟨hg, h⟩, fun h => h.2⟩
  · rw [dif_neg hg]
    constructor
    · intro h
      obtain ⟨vea, hmem, -⟩ := h
      exact (List.not_mem_nil hmem).elim
    · intro h
      exact (hg h.1).elim

/-- **Depth-`k` fold-bit fiber-existential characterization**. The successor
    carrier's fold bit `igFoldBit qnf zs χ = true` iff there EXISTS a marked depth-`k` arity-4 sub
    in
    the `(zs, χ)` fiber — the extraction/introduction interface Phases 4-5 consume, kept existential
    (never pointwise-collapsed). Pure `decide_eq_true_iff`. -/
theorem igFoldBit_iff {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds] {k : Nat}
    (qnf : NormalForm sig (k + 1) 3) (zs : ZoneSpec 3) (χ : NormalForm sig k 1) :
    igFoldBit qnf zs χ = true ↔
      ∃ sub : NormalForm sig k 4, qnf.2 sub = true ∧
        nf0_zoneSpec (NormalForm.atom_assgn sub) = zs ∧ nfk_projFresh sub = χ := by
  unfold igFoldBit
  simp only [decide_eq_true_iff]

/-- **Successor carrier `holds` destructuring**. Combines the
    defeq bridge `bracketEndChar_kv_succ_eq` with the replica destructuring `igBody_holds_iff`: the
    successor carrier's `.holds` at the fixed anchor pair `(x, t)` is the gate conjunct ∧ the
    `S_L`/`S_R` permutation-arrangement disjunction of realized-marked-sub brackets. The fold-bit
    read
    is FIBER-EXISTENTIAL (`igFoldBit`); the destructuring composes with the Phase-2 point-type
    bridges
    (`interiorGate_hck`/`_hcb`) at the endpoint/pivot literals. This is the structural entry point
    for
    Phase 4 (⇐ completeness) and Phase 5 (⇒ soundness). -/
theorem bracketEndChar_kv_succ_holds_iff {sig : MonadicSignature} [Fintype sig.preds]
    [DecidableEq sig.preds] {k : Nat}
    (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    (charF : (j : Nat) → NormalForm sig j 1 → Formula)
    (qnf : NormalForm sig (k + 1) 3)
    (M : OrderedMonadicStructure sig) (x t : M.carrier) :
    (bracketEndChar_kv atomMap h_surj charF (k + 1) qnf).holds M atomMap x t ↔
      igGate (igOffFiber qnf) (igFoldBit qnf) ∧
      ∃ lL ∈ (igSL (igFoldBit qnf)).permutations, ∃ lR ∈ (igSR (igFoldBit qnf)).permutations,
        (igMkDisjunct (nf_depth0_char_formula atomMap h_surj) (charF k) qnf.1 (igFoldBit qnf)
          lL lR).2.holds M atomMap x t := by
  rw [bracketEndChar_kv_succ_eq atomMap h_surj charF qnf]
  exact igBody_holds_iff (nf_depth0_char_formula atomMap h_surj) (charF k) qnf.1
    (igOffFiber qnf) (igFoldBit qnf) M atomMap x t

/-! ## Phase 4a — the honest gate (`igGate` from a genuine realizer)

The completeness half's first milestone: from a genuine depth-`(k+1)` realizer at bracket witness
`w` (`x < w < t`), the successor carrier's gate `igGate (igOffFiber qnf) (igFoldBit qnf)` holds.
Both
conjuncts are the general-`k` analogs of the k=2 gate `kvE2_sepGate_holds_of_honest`
(`SharedWitness.lean:2797`, parts i/ii):

- **Off-fiber honesty** (`igOffFiber`) is delivered VERBATIM by the generic whole-evaluation fold
  bridge `nf_eval_nfk_iff_efold` (`NfEFold.lean`): its off-fiber conjunct
  `∀ sub, nfk_dropFresh sub ≠ qnf.1 → qnf.2 sub = false` IS `igOffFiber qnf` (defeq, since
  `nfk_dropFresh sub = nf0_dropFresh sub.atom_assgn`).
- **Order-conflict falsity** (the seven-zone gate) is the depth-`k` analog of part (ii): a marked
sub
  is realized at some `x1` over `[x1,w,x,t]`, so its atom-layer zone `nf0_zoneSpec (atom_assgn sub)`
  is one of the seven order-consistent zones (`igZone3_consistent`, the generic trichotomy below,
  modeled on `kvE2_sep_zone3_consistent`). No chain step is shortcut (G5): pure order trichotomy and
  the atom-layer bridge `nf_eval_nf_atom_layer`. -/

/-- **Generic seven-zone order consistency** (general-`k` restatement of
    `kvE2_sep_zone3_consistent`, `SharedWitness.lean:2611`). Any zone realized at a point `u` over
    the
    bracket env `[w,x,t]` with `x < w < t` is one of the seven bracket-order-consistent zones. Pure
    order trichotomy on `u` against `x`, `w`, `t`; `k1v_bool_eq_false` converts each strict-order
    negation to a Bool bit. -/
theorem igZone3_consistent {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds]
    (M : OrderedMonadicStructure sig) (w x t u : M.carrier)
    (hxw : x < w) (hwt : w < t) (zs : ZoneSpec 3)
    (hz : zoneHolds M (Fin.cons w (Fin.cons x (fun _ => t))) zs u) :
    zs = igZPastX ∨ zs = igZAtX ∨ zs = igZXW ∨ zs = igZAtW ∨ zs = igZWT ∨ zs = igZAtT ∨
      zs = igZFutT := by
  have h0 := hz ⟨0, by omega⟩
  have h1 := hz ⟨1, by omega⟩
  have h2 := hz ⟨2, by omega⟩
  simp only [Fin.cons] at h0 h1 h2
  have hzs : ∀ (p0 p1 p2 : Bool × Bool),
      zs ⟨0, by omega⟩ = p0 → zs ⟨1, by omega⟩ = p1 → zs ⟨2, by omega⟩ = p2 →
      zs = Fin.cons p0 (Fin.cons p1 (fun _ => p2)) := by
    intro p0 p1 p2 e0 e1 e2
    funext i
    match i with
    | ⟨0, _⟩ => exact e0
    | ⟨1, _⟩ => exact e1
    | ⟨2, _⟩ => exact e2
  have hxt : x < t := hxw.trans hwt
  rcases lt_trichotomy u x with hux | rfl | hux
  · -- u < x : zPastX
    have huw : u < w := hux.trans hxw
    have hut : u < t := hux.trans hxt
    exact Or.inl (hzs _ _ _
      (Prod.ext_iff.mpr ⟨h0.1.mp huw, k1v_bool_eq_false h0.2 (lt_asymm huw)⟩)
      (Prod.ext_iff.mpr ⟨h1.1.mp hux, k1v_bool_eq_false h1.2 (lt_asymm hux)⟩)
      (Prod.ext_iff.mpr ⟨h2.1.mp hut, k1v_bool_eq_false h2.2 (lt_asymm hut)⟩))
  · -- u = x : zAtX
    exact Or.inr (Or.inl (hzs _ _ _
      (Prod.ext_iff.mpr ⟨h0.1.mp hxw, k1v_bool_eq_false h0.2 (lt_asymm hxw)⟩)
      (Prod.ext_iff.mpr ⟨k1v_bool_eq_false h1.1 (lt_irrefl _),
        k1v_bool_eq_false h1.2 (lt_irrefl _)⟩)
      (Prod.ext_iff.mpr ⟨h2.1.mp hxt, k1v_bool_eq_false h2.2 (lt_asymm hxt)⟩)))
  · -- x < u : split against w
    rcases lt_trichotomy u w with huw | rfl | huw
    · -- x < u < w : zXW
      have hut : u < t := huw.trans hwt
      exact Or.inr (Or.inr (Or.inl (hzs _ _ _
        (Prod.ext_iff.mpr ⟨h0.1.mp huw, k1v_bool_eq_false h0.2 (lt_asymm huw)⟩)
        (Prod.ext_iff.mpr ⟨k1v_bool_eq_false h1.1 (lt_asymm hux), h1.2.mp hux⟩)
        (Prod.ext_iff.mpr ⟨h2.1.mp hut, k1v_bool_eq_false h2.2 (lt_asymm hut)⟩))))
    · -- u = w : zAtW
      exact Or.inr (Or.inr (Or.inr (Or.inl (hzs _ _ _
        (Prod.ext_iff.mpr ⟨k1v_bool_eq_false h0.1 (lt_irrefl _),
          k1v_bool_eq_false h0.2 (lt_irrefl _)⟩)
        (Prod.ext_iff.mpr ⟨k1v_bool_eq_false h1.1 (lt_asymm hux), h1.2.mp hux⟩)
        (Prod.ext_iff.mpr ⟨h2.1.mp hwt, k1v_bool_eq_false h2.2 (lt_asymm hwt)⟩)))))
    · -- w < u : split against t
      rcases lt_trichotomy u t with hut | rfl | hut
      · -- w < u < t : zWT
        exact Or.inr (Or.inr (Or.inr (Or.inr (Or.inl (hzs _ _ _
          (Prod.ext_iff.mpr ⟨k1v_bool_eq_false h0.1 (lt_asymm huw), h0.2.mp huw⟩)
          (Prod.ext_iff.mpr ⟨k1v_bool_eq_false h1.1 (lt_asymm hux), h1.2.mp hux⟩)
          (Prod.ext_iff.mpr ⟨h2.1.mp hut, k1v_bool_eq_false h2.2 (lt_asymm hut)⟩))))))
      · -- u = t : zAtT
        exact Or.inr (Or.inr (Or.inr (Or.inr (Or.inr (Or.inl (hzs _ _ _
          (Prod.ext_iff.mpr ⟨k1v_bool_eq_false h0.1 (lt_asymm huw), h0.2.mp huw⟩)
          (Prod.ext_iff.mpr ⟨k1v_bool_eq_false h1.1 (lt_asymm hux), h1.2.mp hux⟩)
          (Prod.ext_iff.mpr ⟨k1v_bool_eq_false h2.1 (lt_irrefl _),
            k1v_bool_eq_false h2.2 (lt_irrefl _)⟩)))))))
      · -- t < u : zFutT
        exact Or.inr (Or.inr (Or.inr (Or.inr (Or.inr (Or.inr (hzs _ _ _
          (Prod.ext_iff.mpr ⟨k1v_bool_eq_false h0.1 (lt_asymm huw), h0.2.mp huw⟩)
          (Prod.ext_iff.mpr ⟨k1v_bool_eq_false h1.1 (lt_asymm hux), h1.2.mp hux⟩)
          (Prod.ext_iff.mpr ⟨k1v_bool_eq_false h2.1 (lt_asymm hut), h2.2.mp hut⟩)))))))

/-- **Honest gate at depth `k+1`** (the completeness first milestone). From a
    genuine realizer at bracket witness `w` (`x < w < t`), the successor carrier's gate holds. The
    off-fiber conjunct is delivered by the generic fold bridge `nf_eval_nfk_iff_efold`; the
    seven-zone
    conjunct routes each marked sub through its atom-layer zone via `nf_eval_nf_atom_layer` +
    `igZone3_consistent`. General-`k` analog of `kvE2_sepGate_holds_of_honest` (parts i/ii). No
    chain
    step is shortcut (G5). -/
theorem bracketEndChar_kv_step_gate {sig : MonadicSignature} [Fintype sig.preds]
    [DecidableEq sig.preds] {k : Nat}
    (qnf : NormalForm sig (k + 1) 3)
    (M : OrderedMonadicStructure sig)
    (w x t : M.carrier) (hxw : x < w) (hwt : w < t)
    (h : nf_eval_nf M (k + 1) 3 (Fin.cons w (Fin.cons x (fun _ => t))) qnf) :
    igGate (igOffFiber qnf) (igFoldBit qnf) := by
  refine ⟨((nf_eval_nfk_iff_efold M _ qnf).mp h).2, ?_⟩
  -- Seven-zone order-conflict falsity: an off-consistent zone marks no realized sub.
  intro zs χ hncons
  cases hbit : igFoldBit qnf zs χ with
  | false => rfl
  | true =>
    obtain ⟨sub, hmark, hzone, _hproj⟩ := (igFoldBit_iff qnf zs χ).mp hbit
    -- The marked sub is realized at some `x1` over `[x1,w,x,t]` (fold conjunct of the realizer).
    obtain ⟨x1, hx1⟩ := (h.2 sub).mpr hmark
    have hatom := nf_eval_nf_atom_layer M (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t)))) sub
        hx1
    -- Read the atom-layer zone of `x1` against `[w,x,t]`.
    have hz : zoneHolds M (Fin.cons w (Fin.cons x (fun _ => t)))
        (nf0_zoneSpec (NormalForm.atom_assgn sub)) x1 := by
      intro i
      refine ⟨?_, ?_⟩
      · have h1 := hatom (.order 0 i.succ (Fin.succ_ne_zero i).symm)
        simp only [atom_eval, Fin.cons_zero, Fin.cons_succ] at h1
        exact h1
      · have h1 := hatom (.order i.succ 0 (Fin.succ_ne_zero i))
        simp only [atom_eval, Fin.cons_zero, Fin.cons_succ] at h1
        exact h1
    rw [hzone] at hz
    exact absurd (igZone3_consistent M w x t x1 hxw hwt zs hz) hncons

/-! ## Phase 4b — the fold-realization biconditional (fiber bits ↔ model witnesses)

The engine that converts the successor carrier's fiber-existential fold bit into a genuine interval
witness (and back). This is the general-`k` analog of the depth-1 `hzone'` fold biconditional inside
`bracketEndChar_k1v_complete` (`CarrierK1V.lean:1655`), where the pointwise `efold_of_nf1` read is
replaced by the fiber-existential `igFoldBit`:

`igFoldBit qnf zs χ = true ↔ ∃ u, zoneHolds M [w,x,t] zs u ∧ nf_eval_nf M k 1 (fun _ => u) χ`.

- **⇒** (bit → witness): a marked sub in the `(zs, χ)` fiber is realized at some `x1` over
  `[x1,w,x,t]` (realizer fold conjunct); its atom-layer zone is `zs` (`nf0_zoneSpec`) and its fresh
  projection realizes `χ` at `x1` (`nf_eval_projFresh`, `ExteriorBracketK.lean:163`, with
  `nfk_projFresh sub = χ`).
- **⇐** (witness → bit): the characteristic depth-`k` sub at `[u,w,x,t]`
  (`nf_characteristic_satisfies`) is marked (realizer forward), sits in zone `zs` (its atom layer
  reads `u`'s order against `[w,x,t]` = `zoneHolds`), and its fresh projection equals `χ`
  (`nf_eval_unique` against the given realization). No chain step is shortcut (G5); the fold bit is
  read FIBER-EXISTENTIALLY throughout (F1 channel preserved). -/

/-- **Fold-realization biconditional at depth `k+1`**.
    The successor carrier's fiber-existential fold bit is TRUE exactly when the model realizes the
    interior 1-type `χ` at some point in zone `zs` relative to `[w,x,t]`. Consumes
    `nf_eval_projFresh`
    (⇒) and `nf_characteristic_satisfies` + `nf_eval_unique` (⇐). -/
theorem igFoldBit_realize_iff {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds]
    {k : Nat}
    (qnf : NormalForm sig (k + 1) 3)
    (M : OrderedMonadicStructure sig)
    (w x t : M.carrier)
    (h : nf_eval_nf M (k + 1) 3 (Fin.cons w (Fin.cons x (fun _ => t))) qnf)
    (zs : ZoneSpec 3) (χ : NormalForm sig k 1) :
    igFoldBit qnf zs χ = true ↔
      ∃ u : M.carrier, zoneHolds M (Fin.cons w (Fin.cons x (fun _ => t))) zs u ∧
        nf_eval_nf M k 1 (fun _ => u) χ := by
  constructor
  · -- ⇒ : a marked fiber sub is realized; read its zone and fresh projection.
    intro hbit
    obtain ⟨sub, hmark, hzone, hproj⟩ := (igFoldBit_iff qnf zs χ).mp hbit
    obtain ⟨x1, hx1⟩ := (h.2 sub).mpr hmark
    have hatom := nf_eval_nf_atom_layer M (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t)))) sub
        hx1
    refine ⟨x1, ?_, ?_⟩
    · intro i
      refine ⟨?_, ?_⟩
      · have h1 := hatom (.order 0 i.succ (Fin.succ_ne_zero i).symm)
        simp only [atom_eval, Fin.cons_zero, Fin.cons_succ] at h1
        rw [← hzone]; exact h1
      · have h1 := hatom (.order i.succ 0 (Fin.succ_ne_zero i))
        simp only [atom_eval, Fin.cons_zero, Fin.cons_succ] at h1
        rw [← hzone]; exact h1
    · rw [← hproj]
      exact nf_eval_projFresh M (Fin.cons w (Fin.cons x (fun _ => t))) x1 sub hx1
  · -- ⇐ : the characteristic sub at `[u,w,x,t]` is a marked fiber witness for `(zs, χ)`.
    rintro ⟨u, hu, hχ⟩
    set env4 : Fin 4 → M.carrier := Fin.cons u (Fin.cons w (Fin.cons x (fun _ => t))) with henv4
    set csub : NormalForm sig k 4 := nf_characteristic M k 4 env4 with hcsub
    have hcsat : nf_eval_nf M k 4 env4 csub := nf_characteristic_satisfies M k 4 env4
    have hcatom := nf_eval_nf_atom_layer M env4 csub hcsat
    apply (igFoldBit_iff qnf zs χ).mpr
    refine ⟨csub, ?_, ?_, ?_⟩
    · -- marked: the realizer's forward direction (csub is realized at `u`).
      exact (h.2 csub).mp ⟨u, hcsat⟩
    · -- zoneSpec = zs: the atom layer reads `u`'s order against `[w,x,t]`, which `hu` pins to `zs`.
      funext i
      have h0 := hcatom (.order 0 i.succ (Fin.succ_ne_zero i).symm)
      have h1 := hcatom (.order i.succ 0 (Fin.succ_ne_zero i))
      simp only [atom_eval, henv4, Fin.cons_zero, Fin.cons_succ] at h0 h1
      have hb0 : (NormalForm.atom_assgn csub) (.order 0 i.succ (Fin.succ_ne_zero i).symm)
          = (zs i).1 := by
        rw [Bool.eq_iff_iff]; exact h0.symm.trans (hu i).1
      have hb1 : (NormalForm.atom_assgn csub) (.order i.succ 0 (Fin.succ_ne_zero i))
          = (zs i).2 := by
        rw [Bool.eq_iff_iff]; exact h1.symm.trans (hu i).2
      exact Prod.ext hb0 hb1
    · -- projFresh = χ: both realize the same 1-type at `u`; uniqueness.
      exact nf_eval_unique M k 1 (fun _ => u) (nfk_projFresh csub) χ
        (nf_eval_projFresh M (Fin.cons w (Fin.cons x (fun _ => t))) u csub hcsat) hχ

/-! ## Phase 4b — reused depth-1 completeness machinery (private helpers + depth-`k` sort)

The depth-1 completeness engine `bracketEndChar_k1v_complete` (`CarrierK1V.lean:1629`) is built from
several PRIVATE helpers that are DEPTH-AGNOSTIC (the arrangement insertion sort `k1v_sorted_insert`,
generic over the point-type `α`; the bracket assembler `k1v_bracket_construct`, over
`List TemporalPred`; the arity-3 endpoint 1-type extractors `k1v_extract_x_nf3`/`_t_nf3`/`_y_nf`,
over `qnf.1 : NormalForm sig 0 3`; and the zone-reader `k1v_zoneHolds_cons_iff`). They are opened
here
via `open private` — pure consumption, no re-proof, no edit to the frozen `CarrierK1V.lean`. Only
the
arrangement-selection wrapper `k1v_sorted_realization` is depth-0-hardwired (its point types are
`NormalForm sig 0 1`), so its general-`k` analog `igk_sorted_realization` is re-derived below over
`NormalForm sig k 1` (byte-for-byte the same insertion induction, `nf_eval_unique` at depth `k`). -/

open private k1v_sorted_insert k1v_zoneHolds_cons_iff k1v_extract_x_nf3 k1v_extract_t_nf3
  k1v_extract_y_nf k1v_bracket_construct from
  Bimodal.Metalogic.WeakCanonical.Kamp.NfMultiAnchorBridge.CarrierK1V

/-- **Depth-`k` arrangement selection** (general-`k` analog of
    `k1v_sorted_realization`, `CarrierK1V.lean:1447`). Every list of complete depth-`k` 1-types each
    realized somewhere strictly inside `(a, b)` admits a simultaneous arrangement — a permutation
    tagged with realizing points in strictly increasing model order. Distinctness is automatic:
    distinct complete `k`-types exclude each other at any single point (`nf_eval_unique M k 1`).
    Same
    insertion induction as the depth-1 original, over the generic insert helper
    `k1v_sorted_insert`. -/
theorem igk_sorted_realization {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds]
    {k : Nat}
    (M : OrderedMonadicStructure sig)
    (a b : M.carrier)
    (S : List (NormalForm sig k 1)) (hnd : S.Nodup)
    (hreal : ∀ χ ∈ S, ∃ u, a < u ∧ u < b ∧ nf_eval_nf M k 1 (fun _ => u) χ) :
    ∃ ps : List (NormalForm sig k 1 × M.carrier),
      List.Perm (ps.map Prod.fst) S ∧
      (ps.map Prod.snd).Pairwise (· < ·) ∧
      ∀ p ∈ ps, (a < p.2 ∧ p.2 < b) ∧ nf_eval_nf M k 1 (fun _ => p.2) p.1 := by
  induction S with
  | nil => exact ⟨[], by simp, by simp, by simp⟩
  | cons χ S' ih =>
    obtain ⟨u, hau, hub, huχ⟩ := hreal χ List.mem_cons_self
    obtain ⟨ps', hperm', hsort', hprops'⟩ :=
      ih (List.nodup_cons.mp hnd).2 (fun χ' h' => hreal χ' (List.mem_cons_of_mem _ h'))
    have hne : ∀ p ∈ ps', p.2 ≠ u := by
      intro p hp heq
      have hev : nf_eval_nf M k 1 (fun _ => u) p.1 := heq ▸ (hprops' p hp).2
      have hpq : p.1 = χ := nf_eval_unique M k 1 _ p.1 χ hev huχ
      have : χ ∈ S' := hperm'.mem_iff.mp (hpq ▸ List.mem_map_of_mem hp)
      exact (List.nodup_cons.mp hnd).1 this
    obtain ⟨qs, hqperm, hqsort⟩ := k1v_sorted_insert M (χ, u) ps' hsort' hne
    refine ⟨qs, ?_, hqsort, ?_⟩
    · have h1 : List.Perm (qs.map Prod.fst) (((χ, u) :: ps').map Prod.fst) := hqperm.map _
      rw [List.map_cons] at h1
      exact h1.trans (hperm'.cons χ)
    · intro p hp
      rcases List.mem_cons.mp (hqperm.mem_iff.mp hp) with rfl | hp'
      · exact ⟨⟨hau, hub⟩, huχ⟩
      · exact hprops' p hp'

/-! ## Phase 4b — ⇐ completeness (realizer → successor carrier holds)

The completeness half of the k→k+1 step. From a genuine depth-`(k+1)` realizer at bracket witness
`w`, the successor carrier `.holds` at the FIXED endpoints `(x, t)`. This is the general-`k`
transcription of `bracketEndChar_k1v_complete` (`CarrierK1V.lean:1629`) with three substitutions:

1. the pointwise depth-1 fold bit `(efold_of_nf1 qnf).2 (zs, χ)` → the fiber-existential
   `igFoldBit qnf zs χ`, its fold biconditional supplied by `igFoldBit_realize_iff` (Phase 4b);
2. the depth-0 interior point type `char χ` → `charF k χ`, its realization supplied by
   `interiorGate_hck` (Phase 2) under the provider agreement `hcharK : charF k = fun χ => P.existF
   0 χ`
   (the general-`k` analog of the k=2 template's `P`-parameterization, `OuterGate.lean:147`);
3. the fixed endpoints' base 1-types stay depth-0 (`interiorGate_hcb`), the arity-3 extractors
   (`k1v_extract_*`) and the bracket assembler (`k1v_bracket_construct`) are reused verbatim.

The gate conjunct is discharged by `bracketEndChar_kv_step_gate` (Phase 4a). This is NOT
F1-obstructed:
a genuine realizer supplies the fiber content (Rabinovich Cor 5.4 endpoint characteristic chain, §5
bracket placement PDF p.7). No chain step is shortcut (G5); interior content rides bracket WITNESS
slots at FULL arity (G1/N4). -/

set_option maxHeartbeats 1600000 in
-- `bracketEndChar_kv_step_complete` elaborates the general-`k` interior gate composition
-- together with its full provider inventory in a single declaration; the default
-- 200000-heartbeat budget is not enough to typecheck it.
/-- **Inductive step ⇐ completeness**. From the arity-3 realizer at bracket
    witness `w`, the successor carrier `.holds` at `(x, t)`, via
    `bracketEndChar_kv_succ_holds_iff`'s
    RHS: the honest gate (Phase 4a) plus ONE sorted `S_L`/`S_R` arrangement whose `igMkDisjunct`
    bracket holds. Provider-guarded (`P`, `hcharK`, UZ/SZ) so the interior point types realize via
    `interiorGate_hck`. -/
theorem bracketEndChar_kv_step_complete {sig : MonadicSignature} [Fintype sig.preds]
    [DecidableEq sig.preds] {k : Nat}
    (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    (charF : (j : Nat) → NormalForm sig j 1 → Formula)
    (P : ExistProviders sig atomMap k)
    (hcharK : charF k = fun χ => P.existF 0 χ)
    (qnf : NormalForm sig (k + 1) 3)
    (h_xy : qnf.1 (.order ⟨1, by omega⟩ ⟨0, by omega⟩ (by decide)) = true)
    (h_yt : qnf.1 (.order ⟨0, by omega⟩ ⟨2, by omega⟩ (by decide)) = true)
    (M : OrderedMonadicStructure sig)
    (h_UZ : semantic_prior_UZ M atomMap) (h_SZ : semantic_prior_SZ M atomMap)
    (x t : M.carrier) :
    (∃ w : M.carrier, nf_eval_nf M (k + 1) 3 (Fin.cons w (Fin.cons x (fun _ => t))) qnf) →
      (bracketEndChar_kv atomMap h_surj charF (k + 1) qnf).holds M atomMap x t := by
  rintro ⟨w, hw⟩
  -- Atom layer + bracket order facts.
  have h_atom : nf_eval_nf M 0 3 (Fin.cons w (Fin.cons x (fun _ => t))) qnf.1 :=
    nf_eval_nf_atom_layer M _ qnf hw
  have hxw : x < w := by
    have h1 := h_atom (.order ⟨1, by omega⟩ ⟨0, by omega⟩ (by decide))
    simp only [atom_eval, Fin.cons] at h1
    exact h1.mpr h_xy
  have hwt : w < t := by
    have h1 := h_atom (.order ⟨0, by omega⟩ ⟨2, by omega⟩ (by decide))
    simp only [atom_eval, Fin.cons] at h1
    exact h1.mpr h_yt
  have hxt : x < t := hxw.trans hwt
  -- Point-type realization bridges: interior (depth `k`, provider) and endpoint base (depth 0).
  have hchar : ∀ (χ : NormalForm sig k 1) (u : M.carrier),
      temporal_truth M atomMap u (charF k χ) ↔ nf_eval_nf M k 1 (fun _ => u) χ := by
    intro χ u; simp only [hcharK]; exact interiorGate_hck atomMap P M h_UZ h_SZ χ u
  have hcharB : ∀ (χ : NormalForm sig 0 1) (u : M.carrier),
      temporal_truth M atomMap u (nf_depth0_char_formula atomMap h_surj χ) ↔
        nf_eval_nf M 0 1 (fun _ => u) χ :=
    fun χ u => interiorGate_hcb atomMap h_surj M χ u
  -- Endpoint/witness arity-1 base evaluations (fixed points, reused arity-3 extractors).
  have h_y_nf := k1v_extract_y_nf M qnf.1 w x t h_atom
  have h_x_nf := k1v_extract_x_nf3 M qnf.1 w x t h_atom
  have h_t_nf := k1v_extract_t_nf3 M qnf.1 w x t h_atom
  -- Fold biconditional (fiber bit ↔ interval witness), specialized to this realizer.
  have hz' : ∀ (zs : ZoneSpec 3) (χ : NormalForm sig k 1),
      igFoldBit qnf zs χ = true ↔
        ∃ u : M.carrier, zoneHolds M (Fin.cons w (Fin.cons x (fun _ => t))) zs u ∧
          nf_eval_nf M k 1 (fun _ => u) χ :=
    fun zs χ => igFoldBit_realize_iff qnf M w x t hw zs χ
  -- Zone-membership constructors at the seven consistent zones (Def 3.1 ordering channel).
  have hzPastX : ∀ u, u < x → zoneHolds M (Fin.cons w (Fin.cons x (fun _ => t)) : Fin 3 → M.carrier)
      igZPastX u := by
    intro u hux
    have huw : u < w := hux.trans hxw
    have hut : u < t := huw.trans hwt
    rw [show igZPastX = Fin.cons (true, false) (Fin.cons (true, false) (fun _ => (true, false)))
        from rfl, k1v_zoneHolds_cons_iff]
    exact ⟨⟨iff_of_true huw rfl, iff_of_false (lt_asymm huw) (by simp)⟩,
      ⟨iff_of_true hux rfl, iff_of_false (lt_asymm hux) (by simp)⟩,
      ⟨iff_of_true hut rfl, iff_of_false (lt_asymm hut) (by simp)⟩⟩
  have hzAtX : zoneHolds M (Fin.cons w (Fin.cons x (fun _ => t)) : Fin 3 → M.carrier) igZAtX x := by
    rw [show igZAtX = Fin.cons (true, false) (Fin.cons (false, false) (fun _ => (true, false)))
        from rfl, k1v_zoneHolds_cons_iff]
    exact ⟨⟨iff_of_true hxw rfl, iff_of_false (lt_asymm hxw) (by simp)⟩,
      ⟨iff_of_false (lt_irrefl x) (by simp), iff_of_false (lt_irrefl x) (by simp)⟩,
      ⟨iff_of_true hxt rfl, iff_of_false (lt_asymm hxt) (by simp)⟩⟩
  have hzXW : ∀ u, x < u → u < w →
      zoneHolds M (Fin.cons w (Fin.cons x (fun _ => t)) : Fin 3 → M.carrier) igZXW u := by
    intro u hxu huw
    have hut : u < t := huw.trans hwt
    rw [show igZXW = Fin.cons (true, false) (Fin.cons (false, true) (fun _ => (true, false)))
        from rfl, k1v_zoneHolds_cons_iff]
    exact ⟨⟨iff_of_true huw rfl, iff_of_false (lt_asymm huw) (by simp)⟩,
      ⟨iff_of_false (lt_asymm hxu) (by simp), iff_of_true hxu rfl⟩,
      ⟨iff_of_true hut rfl, iff_of_false (lt_asymm hut) (by simp)⟩⟩
  have hzAtW : zoneHolds M (Fin.cons w (Fin.cons x (fun _ => t)) : Fin 3 → M.carrier) igZAtW w := by
    rw [show igZAtW = Fin.cons (false, false) (Fin.cons (false, true) (fun _ => (true, false)))
        from rfl, k1v_zoneHolds_cons_iff]
    exact ⟨⟨iff_of_false (lt_irrefl w) (by simp), iff_of_false (lt_irrefl w) (by simp)⟩,
      ⟨iff_of_false (lt_asymm hxw) (by simp), iff_of_true hxw rfl⟩,
      ⟨iff_of_true hwt rfl, iff_of_false (lt_asymm hwt) (by simp)⟩⟩
  have hzWT : ∀ u, w < u → u < t →
      zoneHolds M (Fin.cons w (Fin.cons x (fun _ => t)) : Fin 3 → M.carrier) igZWT u := by
    intro u hwu hut
    have hxu : x < u := hxw.trans hwu
    rw [show igZWT = Fin.cons (false, true) (Fin.cons (false, true) (fun _ => (true, false)))
        from rfl, k1v_zoneHolds_cons_iff]
    exact ⟨⟨iff_of_false (lt_asymm hwu) (by simp), iff_of_true hwu rfl⟩,
      ⟨iff_of_false (lt_asymm hxu) (by simp), iff_of_true hxu rfl⟩,
      ⟨iff_of_true hut rfl, iff_of_false (lt_asymm hut) (by simp)⟩⟩
  have hzAtT : zoneHolds M (Fin.cons w (Fin.cons x (fun _ => t)) : Fin 3 → M.carrier) igZAtT t := by
    rw [show igZAtT = Fin.cons (false, true) (Fin.cons (false, true) (fun _ => (false, false)))
        from rfl, k1v_zoneHolds_cons_iff]
    exact ⟨⟨iff_of_false (lt_asymm hwt) (by simp), iff_of_true hwt rfl⟩,
      ⟨iff_of_false (lt_asymm hxt) (by simp), iff_of_true hxt rfl⟩,
      ⟨iff_of_false (lt_irrefl t) (by simp), iff_of_false (lt_irrefl t) (by simp)⟩⟩
  have hzFutT : ∀ u, t < u →
      zoneHolds M (Fin.cons w (Fin.cons x (fun _ => t)) : Fin 3 → M.carrier) igZFutT u := by
    intro u htu
    have hwu : w < u := hwt.trans htu
    have hxu : x < u := hxw.trans hwu
    rw [show igZFutT = Fin.cons (false, true) (Fin.cons (false, true) (fun _ => (false, true)))
        from rfl, k1v_zoneHolds_cons_iff]
    exact ⟨⟨iff_of_false (lt_asymm hwu) (by simp), iff_of_true hwu rfl⟩,
      ⟨iff_of_false (lt_asymm hxu) (by simp), iff_of_true hxu rfl⟩,
      ⟨iff_of_false (lt_asymm htu) (by simp), iff_of_true htu rfl⟩⟩
  -- Interior-positive realization: each positive interior fold bit yields an interval witness.
  have hLreal : ∀ χ : NormalForm sig k 1, igFoldBit qnf igZXW χ = true →
      ∃ u, x < u ∧ u < w ∧ nf_eval_nf M k 1 (fun _ => u) χ := by
    intro χ hbit
    obtain ⟨u, hzu, hev⟩ := (hz' igZXW χ).mp hbit
    rw [show igZXW = Fin.cons (true, false) (Fin.cons (false, true) (fun _ => (true, false)))
        from rfl, k1v_zoneHolds_cons_iff] at hzu
    exact ⟨u, hzu.2.1.2.mpr rfl, hzu.1.1.mpr rfl, hev⟩
  have hRreal : ∀ χ : NormalForm sig k 1, igFoldBit qnf igZWT χ = true →
      ∃ u, w < u ∧ u < t ∧ nf_eval_nf M k 1 (fun _ => u) χ := by
    intro χ hbit
    obtain ⟨u, hzu, hev⟩ := (hz' igZWT χ).mp hbit
    rw [show igZWT = Fin.cons (false, true) (Fin.cons (false, true) (fun _ => (true, false)))
        from rfl, k1v_zoneHolds_cons_iff] at hzu
    exact ⟨u, hzu.1.2.mpr rfl, hzu.2.2.1.mpr rfl, hev⟩
  -- Segment exclusions on ALL of `(x, w)` / `(w, t)`.
  have hsegL_all : ∀ u, x < u → u < w → (igSegL (charF k) (igFoldBit qnf)).eval_at M atomMap u := by
    intro u hxu huw
    simp only [igSegL, TemporalPred.eval_at]
    rw [formula_conjList_iff]
    intro f hf
    obtain ⟨χ, -, rfl⟩ := List.mem_map.mp hf
    cases hb : igFoldBit qnf igZXW χ with
    | true => rw [if_pos rfl]; exact fun hfa => hfa
    | false =>
      rw [if_neg (by simp)]
      intro hch
      have hbit := (hz' igZXW χ).mpr ⟨u, hzXW u hxu huw, (hchar χ u).mp hch⟩
      rw [hb] at hbit; exact Bool.noConfusion hbit
  have hsegR_all : ∀ u, w < u → u < t → (igSegR (charF k) (igFoldBit qnf)).eval_at M atomMap u := by
    intro u hwu hut
    simp only [igSegR, TemporalPred.eval_at]
    rw [formula_conjList_iff]
    intro f hf
    obtain ⟨χ, -, rfl⟩ := List.mem_map.mp hf
    cases hb : igFoldBit qnf igZWT χ with
    | true => rw [if_pos rfl]; exact fun hfa => hfa
    | false =>
      rw [if_neg (by simp)]
      intro hch
      have hbit := (hz' igZWT χ).mpr ⟨u, hzWT u hwu hut, (hchar χ u).mp hch⟩
      rw [hb] at hbit; exact Bool.noConfusion hbit
  -- Endpoint predicate at the FIXED left endpoint `x` (exterior Since literals, zPastX/zAtX).
  have hepL : (igEpL (nf_depth0_char_formula atomMap h_surj) (charF k) qnf.1
      (igFoldBit qnf)).eval_at M atomMap x := by
    simp only [igEpL, igLit, TemporalPred.eval_at]
    rw [formula_conjList_iff]
    intro f hf
    rcases List.mem_append.mp hf with hf | hf
    · rcases List.mem_cons.mp hf with rfl | hf
      · exact (hcharB _ x).mpr h_x_nf
      · obtain ⟨χ, -, rfl⟩ := List.mem_map.mp hf
        cases hb : igFoldBit qnf igZPastX χ with
        | true =>
          rw [if_pos rfl]
          obtain ⟨u, hzu, hev⟩ := (hz' igZPastX χ).mp hb
          rw [show igZPastX = Fin.cons (true, false)
              (Fin.cons (true, false) (fun _ => (true, false)))
              from rfl, k1v_zoneHolds_cons_iff] at hzu
          exact ⟨u, hzu.2.1.1.mpr rfl, (hchar χ u).mpr hev, fun r _ _ hfa => hfa⟩
        | false =>
          rw [if_neg (by simp)]
          rintro ⟨s, hsx, hsχ, -⟩
          have hbit := (hz' igZPastX χ).mpr ⟨s, hzPastX s hsx, (hchar χ s).mp hsχ⟩
          rw [hb] at hbit; exact Bool.noConfusion hbit
    · obtain ⟨χ, -, rfl⟩ := List.mem_map.mp hf
      cases hb : igFoldBit qnf igZAtX χ with
      | true =>
        rw [if_pos rfl]
        obtain ⟨u, hzu, hev⟩ := (hz' igZAtX χ).mp hb
        rw [show igZAtX = Fin.cons (true, false) (Fin.cons (false, false) (fun _ => (true, false)))
            from rfl, k1v_zoneHolds_cons_iff] at hzu
        have hueq : u = x := le_antisymm
          (not_lt.mp (k1v_not_of_iff_false hzu.2.1.2))
          (not_lt.mp (k1v_not_of_iff_false hzu.2.1.1))
        exact (hchar χ x).mpr (hueq ▸ hev)
      | false =>
        rw [if_neg (by simp)]
        intro hch
        have hbit := (hz' igZAtX χ).mpr ⟨x, hzAtX, (hchar χ x).mp hch⟩
        rw [hb] at hbit; exact Bool.noConfusion hbit
  -- Endpoint predicate at the FIXED right endpoint `t` (exterior Until literals, zAtT/zFutT).
  have hepR : (igEpR (nf_depth0_char_formula atomMap h_surj) (charF k) qnf.1
      (igFoldBit qnf)).eval_at M atomMap t := by
    simp only [igEpR, igLit, TemporalPred.eval_at]
    rw [formula_conjList_iff]
    intro f hf
    rcases List.mem_append.mp hf with hf | hf
    · rcases List.mem_cons.mp hf with rfl | hf
      · exact (hcharB _ t).mpr h_t_nf
      · obtain ⟨χ, -, rfl⟩ := List.mem_map.mp hf
        cases hb : igFoldBit qnf igZAtT χ with
        | true =>
          rw [if_pos rfl]
          obtain ⟨u, hzu, hev⟩ := (hz' igZAtT χ).mp hb
          rw [show igZAtT = Fin.cons (false, true)
              (Fin.cons (false, true) (fun _ => (false, false)))
              from rfl, k1v_zoneHolds_cons_iff] at hzu
          have hueq : u = t := le_antisymm
            (not_lt.mp (k1v_not_of_iff_false hzu.2.2.2))
            (not_lt.mp (k1v_not_of_iff_false hzu.2.2.1))
          exact (hchar χ t).mpr (hueq ▸ hev)
        | false =>
          rw [if_neg (by simp)]
          intro hch
          have hbit := (hz' igZAtT χ).mpr ⟨t, hzAtT, (hchar χ t).mp hch⟩
          rw [hb] at hbit; exact Bool.noConfusion hbit
    · obtain ⟨χ, -, rfl⟩ := List.mem_map.mp hf
      cases hb : igFoldBit qnf igZFutT χ with
      | true =>
        rw [if_pos rfl]
        obtain ⟨u, hzu, hev⟩ := (hz' igZFutT χ).mp hb
        rw [show igZFutT = Fin.cons (false, true) (Fin.cons (false, true) (fun _ => (false, true)))
            from rfl, k1v_zoneHolds_cons_iff] at hzu
        exact ⟨u, hzu.2.2.2.mpr rfl, (hchar χ u).mpr hev, fun r _ _ hfa => hfa⟩
      | false =>
        rw [if_neg (by simp)]
        rintro ⟨s, hts, hsχ, -⟩
        have hbit := (hz' igZFutT χ).mpr ⟨s, hzFutT s hts, (hchar χ s).mp hsχ⟩
        rw [hb] at hbit; exact Bool.noConfusion hbit
  -- Witness point type at `w` (complete type + equality-zone literals ONLY, rule N4).
  have hptW : (igPtW (nf_depth0_char_formula atomMap h_surj) (charF k) qnf.1
      (igFoldBit qnf)).eval_at M atomMap w := by
    simp only [igPtW, igLit, TemporalPred.eval_at]
    rw [formula_conjList_iff]
    intro f hf
    rcases List.mem_cons.mp hf with rfl | hf
    · exact (hcharB _ w).mpr h_y_nf
    · obtain ⟨χ, -, rfl⟩ := List.mem_map.mp hf
      cases hb : igFoldBit qnf igZAtW χ with
      | true =>
        rw [if_pos rfl]
        obtain ⟨u, hzu, hev⟩ := (hz' igZAtW χ).mp hb
        rw [show igZAtW = Fin.cons (false, false) (Fin.cons (false, true) (fun _ => (true, false)))
            from rfl, k1v_zoneHolds_cons_iff] at hzu
        have hueq : u = w := le_antisymm
          (not_lt.mp (k1v_not_of_iff_false hzu.1.2))
          (not_lt.mp (k1v_not_of_iff_false hzu.1.1))
        exact (hchar χ w).mpr (hueq ▸ hev)
      | false =>
        rw [if_neg (by simp)]
        intro hch
        have hbit := (hz' igZAtW χ).mpr ⟨w, hzAtW, (hchar χ w).mp hch⟩
        rw [hb] at hbit; exact Bool.noConfusion hbit
  -- Sorted arrangements of the interior-positive enumerations.
  obtain ⟨psL, hpermL, hsortL, hpropsL⟩ :=
    igk_sorted_realization M x w (igSL (igFoldBit qnf))
      ((Finset.nodup_toList _).filter _)
      (fun χ hχ => hLreal χ (by simpa only [igSL, igAllTypes, decide_eq_true_eq]
        using (List.mem_filter.mp hχ).2))
  obtain ⟨psR, hpermR, hsortR, hpropsR⟩ :=
    igk_sorted_realization M w t (igSR (igFoldBit qnf))
      ((Finset.nodup_toList _).filter _)
      (fun χ hχ => hRreal χ (by simpa only [igSR, igAllTypes, decide_eq_true_eq]
        using (List.mem_filter.mp hχ).2))
  -- Combined witness list is sorted: left points < w < right points.
  have hsortFull : (psL.map Prod.snd ++ w :: psR.map Prod.snd).Pairwise (· < ·) := by
    rw [List.pairwise_append]
    refine ⟨hsortL, ?_, ?_⟩
    · rw [List.pairwise_cons]
      refine ⟨?_, hsortR⟩
      intro b hb
      obtain ⟨p, hp, rfl⟩ := List.mem_map.mp hb
      exact (hpropsR p hp).1.1
    · intro a ha b hb
      obtain ⟨p, hp, rfl⟩ := List.mem_map.mp ha
      have haw : p.2 < w := (hpropsL p hp).1.2
      rcases List.mem_cons.mp hb with rfl | hb
      · exact haw
      · obtain ⟨q, hq, rfl⟩ := List.mem_map.mp hb
        exact haw.trans (hpropsR q hq).1.1
  -- Enter the carrier via the Phase-3 destructuring; gate + the (psL, psR) arrangement disjunct.
  rw [bracketEndChar_kv_succ_holds_iff atomMap h_surj charF qnf M x t]
  refine ⟨bracketEndChar_kv_step_gate qnf M w x t hxw hwt hw,
    psL.map Prod.fst, List.mem_permutations.mpr hpermL,
    psR.map Prod.fst, List.mem_permutations.mpr hpermR, hepL, hepR, ?_⟩
  -- The bracket: assembled by the reused construction lemma from the sorted realizations.
  refine k1v_bracket_construct M atomMap _ _ _ _ _ x w t hxw hwt
    (psL.map Prod.snd) (psR.map Prod.snd) (by simp) (by simp) hsortFull
    ?_ ?_ hptW ?_ ?_ hsegL_all hsegR_all
  · intro u hu
    obtain ⟨p, hp, rfl⟩ := List.mem_map.mp hu
    exact (hpropsL p hp).1
  · intro u hu
    obtain ⟨p, hp, rfl⟩ := List.mem_map.mp hu
    exact (hpropsR p hp).1
  · intro i hi
    have hi' : i < psL.length := by simpa using hi
    have h1 : (List.map (igCharP (charF k)) (psL.map Prod.fst))[i]'hi =
        igCharP (charF k) ((psL[i]'hi').1) := by simp only [List.getElem_map]
    have h2 : (psL.map Prod.snd)[i]'(by simpa using hi') = (psL[i]'hi').2 := by
      simp only [List.getElem_map]
    rw [h1, h2]
    simp only [igCharP, TemporalPred.eval_at]
    exact (hchar _ _).mpr (hpropsL _ (List.getElem_mem _)).2
  · intro i hi
    have hi' : i < psR.length := by simpa using hi
    have h1 : (List.map (igCharP (charF k)) (psR.map Prod.fst))[i]'hi =
        igCharP (charF k) ((psR[i]'hi').1) := by simp only [List.getElem_map]
    have h2 : (psR.map Prod.snd)[i]'(by simpa using hi') = (psR[i]'hi').2 := by
      simp only [List.getElem_map]
    rw [h1, h2]
    simp only [igCharP, TemporalPred.eval_at]
    exact (hchar _ _).mpr (hpropsR _ (List.getElem_mem _)).2

/-! ## Phase 5 — ⇒ soundness (successor carrier holds + provider obligations → realizer)

The F1-critical half of the k→k+1 step. From `(bracketEndChar_kv … (k+1) qnf).holds M atomMap x t`,
under the depth-`k` PROVIDER OBLIGATIONS, reconstruct the arity-3 realizer
`∃ w, nf_eval_nf M (k+1) 3 [w,x,t] qnf`. This is the general-`k` analog of the k=2 template
`bracketEndChar_kvE2_sound_two_prior_frag` (`OuterGate.lean:268`), one fold-layer deeper.

**The F1 information channel (`bracketEndChar_kv_factors`, `CarrierKv.lean:422`).** The successor
carrier's fold data is fiber-EXISTENTIAL (`igFoldBit`): from the carrier's `.holds` one recovers
only
*that some* marked depth-`k` arity-4 sub sits in a `(zone, χ)` fiber, never *which* sub — the
arity-4
relational content of a fiber is NOT intrinsic to the carrier (two carriers agreeing on all
fiber-existential fold bits are EQUAL yet may disagree on per-sub marking). Reconstructing the
per-sub fold biconditional `∀ σ, (∃ x1, nf_eval_nf M k 4 [x1,w,x,t] σ) ↔ qnf.2 σ = true`
(`nf_eval_nfk_iff_efold`'s internal `Iff.rfl`, `NfEFold.lean:643`) therefore requires the fiber
content the provider obligations supply — exactly the k=2 template's design:

- `hreal` (marked → realizable): the depth-`k` provider realizes each marked sub `σ` (`qnf.2 σ =
true`)
  at some `x1` — the arity-`(3+1)` provider `P.existF 3` channel (`PriorInterface.lean:41`), gated
  on
  the pivot `igPtW` holding at the bracket witness `w`. Mirrors the k=2 `hrealI`/`hrealB`.
- `hexcl` (cone) + `hexclExt` (exterior): an UNMARKED sub (`qnf.2 σ = false`) is realized at NO `x1`
  — split at the fixed cone `x ≤ x1 ≤ t` (`hexcl`, dischargeable by the Phase-14 provider) and the
  strictly-exterior residue (`hexclExt`, the Rabinovich Prop-4.3 re-flatten / Lemma 7.6 adjacency
  hand-off, `OuterGate.lean:312`; the exterior-bracket layer — a
  NON-goal, threaded OUTWARD verbatim as the k=2 template does).

Given those obligations, the reconstruction is direct and does NOT read the lossy fold bits: extract
the bracket witness `w` + its `igPtW` eval (`k1v_bracket_extract`, depth-agnostic), reconstruct the
depth-0 atom layer from the endpoint/witness char heads (`k1v_reconstruct_nf3` +
`interiorGate_hcb`),
then assemble the per-sub biconditional (`hreal` forward, `hexcl`+`hexclExt` backward). No chain
step
is shortcut (G5); the fold stays fiber-existential (F1 channel intact — the obligations, not a
pointwise collapse, supply the fiber content). -/

open private k1v_bracket_extract k1v_reconstruct_nf3 from
  Bimodal.Metalogic.WeakCanonical.Kamp.NfMultiAnchorBridge.CarrierK1V

set_option maxHeartbeats 1600000 in
-- `bracketEndChar_kv_step_sound` elaborates the general-`k` interior gate composition together
-- with its full provider inventory in a single declaration; the default 200000-heartbeat budget
-- is not enough to typecheck it.
/-- **Inductive step ⇒ soundness**. From the
    successor carrier `.holds` at the FIXED endpoints `(x, t)`, under the depth-`k` provider
    realization/exclusion obligations, the arity-3 realizer `∃ w, nf_eval_nf M (k+1) 3 [w,x,t] qnf`.
    General-`k` analog of `bracketEndChar_kvE2_sound_two_prior_frag` (`OuterGate.lean:268`), NOT
    fragment-restricted: under the named obligations the arrangement structure is not read for the
    per-sub fold biconditional, so the full `S_L`/`S_R` permutation disjunction is admissible. The
    exterior-marked residue rides `hexclExt` outward (the exterior-bracket
    hand-off, Rabinovich Lemma 7.6 adjacency composition — a task-355 NON-goal). No `sorry`/`admit`;
    the exterior residue is a NAMED binder, not a hole. -/
theorem bracketEndChar_kv_step_sound {sig : MonadicSignature} [Fintype sig.preds]
    [DecidableEq sig.preds] {k : Nat}
    (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    (charF : (j : Nat) → NormalForm sig j 1 → Formula)
    (qnf : NormalForm sig (k + 1) 3)
    (h_xy : qnf.1 (.order ⟨1, by omega⟩ ⟨0, by omega⟩ (by decide)) = true)
    (h_yt : qnf.1 (.order ⟨0, by omega⟩ ⟨2, by omega⟩ (by decide)) = true)
    (h_xt : qnf.1 (.order ⟨1, by omega⟩ ⟨2, by omega⟩ (by decide)) = true)
    (h_yx : qnf.1 (.order ⟨0, by omega⟩ ⟨1, by omega⟩ (by decide)) = false)
    (h_ty : qnf.1 (.order ⟨2, by omega⟩ ⟨0, by omega⟩ (by decide)) = false)
    (h_tx : qnf.1 (.order ⟨2, by omega⟩ ⟨1, by omega⟩ (by decide)) = false)
    (M : OrderedMonadicStructure sig) (x t : M.carrier)
    (hreal : ∀ w : M.carrier, x < w → w < t →
      (igPtW (nf_depth0_char_formula atomMap h_surj) (charF k) qnf.1 (igFoldBit qnf)).eval_at
        M atomMap w →
      ∀ σ : NormalForm sig k 4, qnf.2 σ = true →
        ∃ x1 : M.carrier,
          nf_eval_nf M k 4 (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t)))) σ)
    (hexcl : ∀ w : M.carrier, x < w → w < t →
      (igPtW (nf_depth0_char_formula atomMap h_surj) (charF k) qnf.1 (igFoldBit qnf)).eval_at
        M atomMap w →
      ∀ σ : NormalForm sig k 4, qnf.2 σ = false →
        ∀ x1 : M.carrier, x ≤ x1 → x1 ≤ t →
          ¬ nf_eval_nf M k 4 (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t)))) σ)
    (hexclExt : ∀ w : M.carrier, x < w → w < t →
      (igPtW (nf_depth0_char_formula atomMap h_surj) (charF k) qnf.1 (igFoldBit qnf)).eval_at
        M atomMap w →
      ∀ σ : NormalForm sig k 4, qnf.2 σ = false →
        ∀ x1 : M.carrier, ¬ (x ≤ x1 ∧ x1 ≤ t) →
          ¬ nf_eval_nf M k 4 (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t)))) σ) :
    (bracketEndChar_kv atomMap h_surj charF (k + 1) qnf).holds M atomMap x t →
      ∃ w : M.carrier, nf_eval_nf M (k + 1) 3 (Fin.cons w (Fin.cons x (fun _ => t))) qnf := by
  intro h_holds
  -- Enter the carrier via the Phase-3 destructuring: gate + one arrangement disjunct.
  rw [bracketEndChar_kv_succ_holds_iff atomMap h_surj charF qnf M x t] at h_holds
  obtain ⟨_hgate, lL, _hlL, lR, _hlR, hveah⟩ := h_holds
  obtain ⟨hepL, hepR, hbr⟩ := hveah
  -- Extract the bracket witness `w` (`x < w < t`) and its `igPtW` eval (the obligation gate).
  obtain ⟨w, hxw, hwt, hptWe, -, -, -, -⟩ :=
    k1v_bracket_extract M atomMap _ _ _ _ _ x t hbr
  have hxt : x < t := hxw.trans hwt
  -- Depth-0 endpoint/witness char bridge.
  have hcharB : ∀ (χ : NormalForm sig 0 1) (u : M.carrier),
      temporal_truth M atomMap u (nf_depth0_char_formula atomMap h_surj χ) ↔
        nf_eval_nf M 0 1 (fun _ => u) χ :=
    fun χ u => interiorGate_hcb atomMap h_surj M χ u
  -- Endpoint/witness complete types (heads of the conjunction lists). `hptWe` is kept RAW for the
  -- provider obligations; the witness head is read off a copy.
  have hxT : temporal_truth M atomMap x
      (nf_depth0_char_formula atomMap h_surj (nf_x_proj3 qnf.1)) := by
    have h := hepL
    simp only [igMkDisjunct, igEpL, TemporalPred.eval_at] at h
    rw [formula_conjList_iff] at h
    exact h _ (List.mem_append_left _ List.mem_cons_self)
  have htT : temporal_truth M atomMap t
      (nf_depth0_char_formula atomMap h_surj (nf_t_proj3 qnf.1)) := by
    have h := hepR
    simp only [igMkDisjunct, igEpR, TemporalPred.eval_at] at h
    rw [formula_conjList_iff] at h
    exact h _ (List.mem_append_left _ List.mem_cons_self)
  have hyW : temporal_truth M atomMap w
      (nf_depth0_char_formula atomMap h_surj (nf_y_proj qnf.1)) := by
    have h := hptWe
    simp only [igPtW, TemporalPred.eval_at] at h
    rw [formula_conjList_iff] at h
    exact h _ List.mem_cons_self
  -- Reconstruct the depth-0 atom layer at `[w, x, t]` (Chain step 2, rule N1 framing).
  have h_atom : nf_eval_nf M 0 3 (Fin.cons w (Fin.cons x (fun _ => t))) qnf.1 :=
    k1v_reconstruct_nf3 M qnf.1 w x t
      ((hcharB _ w).mp hyW) ((hcharB _ x).mp hxT) ((hcharB _ t).mp htT)
      (iff_of_false (lt_asymm hxw) (by simp only [h_yx]; decide))
      (iff_of_true hwt h_yt)
      (iff_of_true hxw h_xy)
      (iff_of_true hxt h_xt)
      (iff_of_false (lt_asymm hwt) (by simp only [h_ty]; decide))
      (iff_of_false (lt_asymm hxt) (by simp only [h_tx]; decide))
  -- Assemble the realizer: atom layer + the per-sub fold biconditional (defeq, `NfEFold.lean:643`).
  refine ⟨w, h_atom, ?_⟩
  intro sub
  constructor
  · -- realizable → marked: an unmarked sub is realized at NO point (cone `hexcl` ∪ exterior
    -- `hexclExt` cover every `x1`), contradicting the given realizer.
    rintro ⟨x1, hx1⟩
    by_contra hne
    have hf : qnf.2 sub = false := by
      cases hb : qnf.2 sub with
      | true => exact absurd hb hne
      | false => rfl
    by_cases hcone : x ≤ x1 ∧ x1 ≤ t
    · exact hexcl w hxw hwt hptWe sub hf x1 hcone.1 hcone.2 hx1
    · exact hexclExt w hxw hwt hptWe sub hf x1 hcone hx1
  · -- marked → realizable: the provider realizes each marked sub (`hreal`, gated on `igPtW` at
  -- `w`).
    intro hmark
    exact hreal w hxw hwt hptWe sub hmark

/-! ## Phase 6 — step biconditional (assembly of Phases 4 + 5)

The k→k+1 step biconditional `bracketEndChar_kv_step_correct` = ⟨sound (Phase 5), complete (Phase
4)⟩
at symbolic `k+1`. It carries the UNION of the two halves' hypotheses: the completeness half's
provider agreement `hcharK` + `semantic_prior_UZ`/`SZ` (⇐), and the soundness half's provider
realization/exclusion obligations `hreal`/`hexcl`/`hexclExt` (⇒). This mirrors the k=2 assembly
`bracketEndChar_kvE2_correct_two_prior_frag` (`OuterGate.lean:359`), which likewise carries
`P`/`h_UZ`/`h_SZ`/`hrealI`/`hrealB`/`hexcl`/`hexclExt`.

**Shape note (the Phase 6 ∀-`k` open frontier).** This step biconditional is provider-OBLIGATION
carrying. The frozen `InteriorGateTarget` (`BracketCarrierCorrectVPrior`, `PriorInterface.lean:60`)
is
the CLEAN, obligation-FREE biconditional. Per finding F1 (`bracketEndChar_kv_factors`,
`CarrierKv.lean:422`) the clean biconditional is REFUTED at `k ≥ 2` (the lossy fold determines
`.holds` but not the realizer), and even at `k = 2` only the obligation-carrying fragment
`_correct_two_prior_frag` exists — never a clean `BracketCarrierCorrectVPrior` instance. Assembling
the ∀-`k` `InteriorGateTarget` deliverable by `Nat.rec` would require DISCHARGING `hreal`/`hexcl`/
`hexclExt` from `.holds` + `P` alone, which the F1 loss forbids (`hexclExt` is the
exterior-arrangement
/ Lemma 7.6 adjacency residue, the exterior-bracket layer — a NON-goal here). This step
biconditional is the green terminus of the interior-gate construction; the ∀-`k` clean close is the
documented construction gap. -/

set_option maxHeartbeats 1600000 in
-- `bracketEndChar_kv_step_correct` elaborates the general-`k` interior gate composition together
-- with its full provider inventory in a single declaration; the default 200000-heartbeat budget
-- is not enough to typecheck it.
/-- **k→k+1 step biconditional**. `⟨sound (Phase 5), complete (Phase 4)⟩` at
    symbolic `k+1`, carrying the union of both halves' hypotheses. Mirrors the k=2 assembly
    `bracketEndChar_kvE2_correct_two_prior_frag`. Provider-obligation carrying (`hreal`/`hexcl`/
    `hexclExt`), NOT the clean obligation-free `InteriorGateTarget` shape (F1-refuted at `k ≥ 2`;
    see
    the section note). -/
theorem bracketEndChar_kv_step_correct {sig : MonadicSignature} [Fintype sig.preds]
    [DecidableEq sig.preds] {k : Nat}
    (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    (charF : (j : Nat) → NormalForm sig j 1 → Formula)
    (P : ExistProviders sig atomMap k)
    (hcharK : charF k = fun χ => P.existF 0 χ)
    (qnf : NormalForm sig (k + 1) 3)
    (h_xy : qnf.1 (.order ⟨1, by omega⟩ ⟨0, by omega⟩ (by decide)) = true)
    (h_yt : qnf.1 (.order ⟨0, by omega⟩ ⟨2, by omega⟩ (by decide)) = true)
    (h_xt : qnf.1 (.order ⟨1, by omega⟩ ⟨2, by omega⟩ (by decide)) = true)
    (h_yx : qnf.1 (.order ⟨0, by omega⟩ ⟨1, by omega⟩ (by decide)) = false)
    (h_ty : qnf.1 (.order ⟨2, by omega⟩ ⟨0, by omega⟩ (by decide)) = false)
    (h_tx : qnf.1 (.order ⟨2, by omega⟩ ⟨1, by omega⟩ (by decide)) = false)
    (M : OrderedMonadicStructure sig)
    (h_UZ : semantic_prior_UZ M atomMap) (h_SZ : semantic_prior_SZ M atomMap)
    (x t : M.carrier)
    (hreal : ∀ w : M.carrier, x < w → w < t →
      (igPtW (nf_depth0_char_formula atomMap h_surj) (charF k) qnf.1 (igFoldBit qnf)).eval_at
        M atomMap w →
      ∀ σ : NormalForm sig k 4, qnf.2 σ = true →
        ∃ x1 : M.carrier,
          nf_eval_nf M k 4 (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t)))) σ)
    (hexcl : ∀ w : M.carrier, x < w → w < t →
      (igPtW (nf_depth0_char_formula atomMap h_surj) (charF k) qnf.1 (igFoldBit qnf)).eval_at
        M atomMap w →
      ∀ σ : NormalForm sig k 4, qnf.2 σ = false →
        ∀ x1 : M.carrier, x ≤ x1 → x1 ≤ t →
          ¬ nf_eval_nf M k 4 (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t)))) σ)
    (hexclExt : ∀ w : M.carrier, x < w → w < t →
      (igPtW (nf_depth0_char_formula atomMap h_surj) (charF k) qnf.1 (igFoldBit qnf)).eval_at
        M atomMap w →
      ∀ σ : NormalForm sig k 4, qnf.2 σ = false →
        ∀ x1 : M.carrier, ¬ (x ≤ x1 ∧ x1 ≤ t) →
          ¬ nf_eval_nf M k 4 (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t)))) σ) :
    (bracketEndChar_kv atomMap h_surj charF (k + 1) qnf).holds M atomMap x t ↔
      ∃ w : M.carrier, nf_eval_nf M (k + 1) 3 (Fin.cons w (Fin.cons x (fun _ => t))) qnf :=
  ⟨bracketEndChar_kv_step_sound atomMap h_surj charF qnf
      h_xy h_yt h_xt h_yx h_ty h_tx M x t hreal hexcl hexclExt,
    bracketEndChar_kv_step_complete atomMap h_surj charF P hcharK qnf h_xy h_yt M h_UZ h_SZ x t⟩

/-! ## Phase 7 — ∀-`k` obligation-carrying recursion close

The maximal provable ∀-`k` interior-gate deliverable, assembled from the delivered step
biconditional `bracketEndChar_kv_step_correct` (`:1165`, symbolic `k+1`, obligation-carrying) and
the
base rung `interiorGateTarget_zero` (`:89`), by `Nat.casesOn` on `k`. Per plan v2's concrete
determination, this is a **case assembly, NOT an IH-threading induction**: the step does NOT consume
the arity-3 depth-`k` inductive hypothesis (Phases 4/5 realize interior content via the provider
`P`,
not the IH), so the wrapper introduces no recursive obligation dependency.

The obligation binders `hreal`/`hexcl`/`hexclExt` (and `P`/`hcharK`) reference `qnf.1` and
`igFoldBit qnf`, which only typecheck at successor depth `k = n+1`. A single *flat* uniform ∀-`k`
signature therefore cannot quantify them (the R1 typing tension in plan v2). The well-typed
realization is a **`k`-cased motive** `InteriorGateAllK`: at `k = 0` it is the clean obligation-free
`BracketCarrierCorrectVPrior` (which holds unconditionally — the `k = 0` carrier is not lossy, F1
bites only at `k ≥ 2`), discharged verbatim by `interiorGateTarget_zero`; at `k = n+1` it is the
obligation-carrying biconditional, discharged verbatim by `bracketEndChar_kv_step_correct` at `n`.
The `k = 1` rung (`interiorGateTarget_one`) is subsumed by the successor branch at `n = 0` (the step
is fully general in its `{k}`), so it need not be special-cased. There is no `True`/vacuous branch:
the `k = 0` branch carries the genuine clean predicate.

The obligations are handed-in hypotheses; **discharging** them for a real consumer is the
out-of-scope consumer reshape (follow-up (i)) and the exterior-adjacency `hexclExt`
discharge (follow-up (ii)) — see the plan's out-of-scope follow-ups. Assembling the ∀-`k`
obligation-carrying lemma is well-typed and provable additively inside this module. -/

/-- **∀-`k` obligation-carrying interior-gate motive**. The `k`-cased target
    Prop for the ∀-`k` interior-gate correctness. At `k = 0` it is the clean, obligation-free
    `BracketCarrierCorrectVPrior` on the depth-0 carrier (the `k = 0` carrier is
    information-complete,
    so no provider obligation is needed — F1 lossiness bites only at `k ≥ 2`). At `k = n+1` it is
    the
    obligation-carrying biconditional exactly as `bracketEndChar_kv_step_correct` (`:1165`) delivers
    it: the six atom-layer order bits on `qnf.1`, the provider bundle `P` + agreement `hcharK`, the
    UZ/SZ Prior hypotheses, and the interior/exterior realization obligations
    `hreal`/`hexcl`/`hexclExt`. The obligation binders reference `qnf.1`/`igFoldBit qnf`, which are
    successor-depth-only; the case split is what makes the ∀-`k` statement well-typed. -/
def InteriorGateAllK {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds]
    (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    (charF : (j : Nat) → NormalForm sig j 1 → Formula) :
    (k : Nat) → Prop
  | 0 => BracketCarrierCorrectVPrior atomMap (bracketEndChar_kv atomMap h_surj charF 0)
  | (n + 1) =>
      ∀ (qnf : NormalForm sig (n + 1) 3)
        (_h_xy : qnf.1 (.order ⟨1, by omega⟩ ⟨0, by omega⟩ (by decide)) = true)
        (_h_yt : qnf.1 (.order ⟨0, by omega⟩ ⟨2, by omega⟩ (by decide)) = true)
        (_h_xt : qnf.1 (.order ⟨1, by omega⟩ ⟨2, by omega⟩ (by decide)) = true)
        (_h_yx : qnf.1 (.order ⟨0, by omega⟩ ⟨1, by omega⟩ (by decide)) = false)
        (_h_ty : qnf.1 (.order ⟨2, by omega⟩ ⟨0, by omega⟩ (by decide)) = false)
        (_h_tx : qnf.1 (.order ⟨2, by omega⟩ ⟨1, by omega⟩ (by decide)) = false)
        (P : ExistProviders sig atomMap n)
        (_hcharK : charF n = fun χ => P.existF 0 χ)
        (M : OrderedMonadicStructure sig)
        (_h_UZ : semantic_prior_UZ M atomMap) (_h_SZ : semantic_prior_SZ M atomMap)
        (x t : M.carrier)
        (_hreal : ∀ w : M.carrier, x < w → w < t →
          (igPtW (nf_depth0_char_formula atomMap h_surj) (charF n) qnf.1 (igFoldBit qnf)).eval_at
            M atomMap w →
          ∀ σ : NormalForm sig n 4, qnf.2 σ = true →
            ∃ x1 : M.carrier,
              nf_eval_nf M n 4 (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t)))) σ)
        (_hexcl : ∀ w : M.carrier, x < w → w < t →
          (igPtW (nf_depth0_char_formula atomMap h_surj) (charF n) qnf.1 (igFoldBit qnf)).eval_at
            M atomMap w →
          ∀ σ : NormalForm sig n 4, qnf.2 σ = false →
            ∀ x1 : M.carrier, x ≤ x1 → x1 ≤ t →
              ¬ nf_eval_nf M n 4 (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t)))) σ)
        (_hexclExt : ∀ w : M.carrier, x < w → w < t →
          (igPtW (nf_depth0_char_formula atomMap h_surj) (charF n) qnf.1 (igFoldBit qnf)).eval_at
            M atomMap w →
          ∀ σ : NormalForm sig n 4, qnf.2 σ = false →
            ∀ x1 : M.carrier, ¬ (x ≤ x1 ∧ x1 ≤ t) →
              ¬ nf_eval_nf M n 4 (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t)))) σ),
        (bracketEndChar_kv atomMap h_surj charF (n + 1) qnf).holds M atomMap x t ↔
          ∃ w : M.carrier, nf_eval_nf M (n + 1) 3 (Fin.cons w (Fin.cons x (fun _ => t))) qnf

set_option maxHeartbeats 1600000 in
-- `bracketEndChar_kv_correct_prior` elaborates the general-`k` interior gate composition
-- together with its full provider inventory in a single declaration; the default
-- 200000-heartbeat budget is not enough to typecheck it.
/-- **∀-`k` obligation-carrying interior-gate correctness** (the re-frozen ∀-`k`
    deliverable). Assembles `InteriorGateAllK` for every `k` by `Nat.casesOn`: `k = 0` is discharged
    by the base rung `interiorGateTarget_zero`; `k = n+1` is discharged by the step biconditional
    `bracketEndChar_kv_step_correct` at `n`. This is a case assembly (the step does NOT thread the
    arity-3 IH — Phases 4/5 realize interior content via the provider `P`), so no recursive
    obligation
    dependency is introduced. The obligation binders are handed-in hypotheses; discharging them for
    a
    real consumer is the out-of-scope consumer reshape + exterior `hexclExt` discharge
    (plan v2 follow-ups (i)/(ii)). Sorry-free, axioms `[propext, Classical.choice, Quot.sound]`. -/
theorem bracketEndChar_kv_correct_prior {sig : MonadicSignature} [Fintype sig.preds]
    [DecidableEq sig.preds]
    (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    (charF : (j : Nat) → NormalForm sig j 1 → Formula) :
    ∀ k : Nat, InteriorGateAllK atomMap h_surj charF k
  | 0 => interiorGateTarget_zero atomMap h_surj charF
  | (_n + 1) => fun qnf h_xy h_yt h_xt h_yx h_ty h_tx P hcharK M h_UZ h_SZ x t
      hreal hexcl hexclExt =>
    bracketEndChar_kv_step_correct atomMap h_surj charF P hcharK qnf
      h_xy h_yt h_xt h_yx h_ty h_tx M h_UZ h_SZ x t hreal hexcl hexclExt

/-! ## Phase 8 — consumability shape

The obligation-carrying interface a downstream consumer must supply to consume the
general-`k` interior gate at successor depth `k = n+1`. The `example` below is a **documented
shape-match, NOT the consumer wiring** (wiring `bracketEndChar_kv_correct_prior` into the
frozen unconditional `EndIntervalCorrect` at `CarrierK1V.lean:2179` requires an obligation-carrying
`EndIntervalCorrectPrior` reshape that edits the byte-frozen files — plan v2 follow-up (i), out
of the interior-gate scope). It records that, once a consumer provides the seven obligations

  1. `P : ExistProviders sig atomMap n`             — the depth-`n` existential provider bundle
  2. `hcharK : charF n = fun χ => P.existF 0 χ`     — char-layer / provider agreement
  3. `h_UZ  : semantic_prior_UZ M atomMap`          — Prior UZ (universal-zone) hypothesis
  4. `h_SZ  : semantic_prior_SZ M atomMap`          — Prior SZ (self-zone) hypothesis
  5. `hreal`    — interior realization (`P.existF 3` channel; Rabinovich Cor 5.4, within-bracket
                  bounded interior witness `(∃z)^{<z1}_{>z0}`)
  6. `hexcl`    — within-`[x,t]` exclusion (Rabinovich Cor 5.4)
  7. `hexclExt` — strictly-exterior exclusion (Rabinovich Lemma 7.6 adjacency composition; the
                  exterior-bracket-layer hand-off, plan v2 follow-up (ii) — a NON-goal here)

together with the six atom-layer order bits and `M`/`x`/`t`, the depth-`(n+1)` interior-gate
biconditional `holds ↔ ∃ w, nf_eval_nf M (n+1) 3 [w,x,t] qnf` is delivered by
`bracketEndChar_kv_correct_prior (n+1)`. Discharging obligations 1-2 / 5-7 for a real consumer is
the
out-of-scope consumer reshape + exterior `hexclExt` discharge (follow-ups (i)/(ii)). -/
example {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds] {n : Nat}
    (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    (charF : (j : Nat) → NormalForm sig j 1 → Formula) :
    InteriorGateAllK atomMap h_surj charF (n + 1) :=
  bracketEndChar_kv_correct_prior atomMap h_surj charF (n + 1)

/-! ## M2 (Option B) — DE-FOLDED public replicas (sibling of `igBody`)

Byte-parallel siblings of the public replicas above (`igEpL`..`igBody`, `:209-299`, and the fold bit
`igFoldBit`, `:318-332`), re-keyed from the arity-1 1-type `χ : NormalForm sig k 1` onto the FULL
arity-4 fiber `σ : NormalForm sig k 4`. These are the public destructuring surface for the de-folded
carrier `bracketEndChar_kvFib` (CarrierKv). The non-projecting fold bit `igFoldBitFib` keeps the
whole
fiber live (NO `nfk_projFresh` collapse — the F1 channel the frozen `igFoldBit` loses). The
`igBodyFib`↔carrier defeq bridge is Phase 2 (and, per the plan, need NOT be `rfl`); Phase 1 only
lands
these type-correct, sorry-free parallel defs. The frozen replicas and both `rfl` bridges are
untouched. -/

/-- De-folded enumeration of complete depth-`k` arity-4 fibers (arity-4 analog of `igAllTypes`,
    `:203`). -/
def igAllSubs (sig : MonadicSignature) [Fintype sig.preds] [DecidableEq sig.preds] (k : Nat) : List
    (NormalForm sig k 4) := Finset.univ.toList

/-- **The NON-PROJECTING fiber fold-bit read** (de-folded analog of `igFoldBit`,
    `:318-332`). Keyed on the FULL arity-4 fiber `sub : NormalForm sig k 4`: TRUE iff `sub` is
    marked
    and its atom-layer zone is `zs`. Unlike `igFoldBit`, there is NO `nfk_projFresh sub = χ`
    collapse
    — the whole fiber `sub` is retained (the F1 channel M2 preserves). The `Decidable` instance is
    `Classical.propDecidable`, matching the sibling carrier `bracketEndChar_kvFib`'s `open
    Classical`
    fold bit. -/
def igFoldBitFib {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds] {k : Nat}
    (qnf : NormalForm sig (k + 1) 3) :
    ZoneSpec 3 → NormalForm sig k 4 → Bool :=
  fun zs sub =>
    @decide (qnf.2 sub = true ∧ nf0_zoneSpec (NormalForm.atom_assgn sub) = zs)
      (Classical.propDecidable _)

/-- Left endpoint predicate, de-folded (arity-4 analog of `igEpL`, `:209-215`). -/
def igEpLFib {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds] {k : Nat}
    (charBase : NormalForm sig 0 1 → Formula) (charFib : NormalForm sig k 4 → Formula)
    (r : NormalForm sig 0 3) (b : ZoneSpec 3 → NormalForm sig k 4 → Bool) : TemporalPred :=
  ⟨formula_conjList
    (charBase (nf_x_proj3 r)
      :: (igAllSubs sig k).map (fun σ => igLit (b igZPastX σ)
          (Formula.snce (charFib σ) Formula.top))
      ++ (igAllSubs sig k).map (fun σ => igLit (b igZAtX σ) (charFib σ)))⟩

/-- Right endpoint predicate, de-folded (arity-4 analog of `igEpR`, `:219-225`). -/
def igEpRFib {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds] {k : Nat}
    (charBase : NormalForm sig 0 1 → Formula) (charFib : NormalForm sig k 4 → Formula)
    (r : NormalForm sig 0 3) (b : ZoneSpec 3 → NormalForm sig k 4 → Bool) : TemporalPred :=
  ⟨formula_conjList
    (charBase (nf_t_proj3 r)
      :: (igAllSubs sig k).map (fun σ => igLit (b igZAtT σ) (charFib σ))
      ++ (igAllSubs sig k).map (fun σ => igLit (b igZFutT σ)
          (Formula.untl (charFib σ) Formula.top)))⟩

/-- Left segment exclusion, de-folded (arity-4 analog of `igSegL`, `:228-232`). -/
def igSegLFib {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds] {k : Nat}
    (charFib : NormalForm sig k 4 → Formula) (b : ZoneSpec 3 → NormalForm sig k 4 → Bool) :
    TemporalPred :=
  ⟨formula_conjList ((igAllSubs sig k).map (fun σ =>
    if b igZXW σ then Formula.top else (charFib σ).neg))⟩

/-- Right segment exclusion, de-folded (arity-4 analog of `igSegR`, `:235-239`). -/
def igSegRFib {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds] {k : Nat}
    (charFib : NormalForm sig k 4 → Formula) (b : ZoneSpec 3 → NormalForm sig k 4 → Bool) :
    TemporalPred :=
  ⟨formula_conjList ((igAllSubs sig k).map (fun σ =>
    if b igZWT σ then Formula.top else (charFib σ).neg))⟩

/-- Witness point type at `w`, de-folded (arity-4 analog of `igPtW`, `:243-248`). -/
def igPtWFib {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds] {k : Nat}
    (charBase : NormalForm sig 0 1 → Formula) (charFib : NormalForm sig k 4 → Formula)
    (r : NormalForm sig 0 3) (b : ZoneSpec 3 → NormalForm sig k 4 → Bool) : TemporalPred :=
  ⟨formula_conjList
    (charBase (nf_y_proj r)
      :: (igAllSubs sig k).map (fun σ => igLit (b igZAtW σ) (charFib σ)))⟩

/-- The gate Prop, de-folded (arity-4 analog of `igGate`, `:252-258`). -/
def igGateFib {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds] {k : Nat}
    (offFiber : Prop) (b : ZoneSpec 3 → NormalForm sig k 4 → Bool) : Prop :=
  offFiber ∧
  (∀ (zs : ZoneSpec 3) (σ : NormalForm sig k 4),
    ¬ (zs = igZPastX ∨ zs = igZAtX ∨ zs = igZXW ∨ zs = igZAtW ∨ zs = igZWT ∨ zs = igZAtT ∨
        zs = igZFutT) →
      b zs σ = false)

/-- Interior-positive left enumeration `S_L`, de-folded (arity-4 analog of `igSL`, `:261-263`). -/
def igSLFib {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds] {k : Nat}
    (b : ZoneSpec 3 → NormalForm sig k 4 → Bool) : List (NormalForm sig k 4) :=
  (igAllSubs sig k).filter (fun σ => b igZXW σ)

/-- Interior-positive right enumeration `S_R`, de-folded (arity-4 analog of `igSR`, `:266-268`). -/
def igSRFib {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds] {k : Nat}
    (b : ZoneSpec 3 → NormalForm sig k 4 → Bool) : List (NormalForm sig k 4) :=
  (igAllSubs sig k).filter (fun σ => b igZWT σ)

/-- Per-fiber witness predicate `charP`, de-folded (arity-4 analog of `igCharP`, `:271-273`). -/
def igCharPFib {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds] {k : Nat}
    (charFib : NormalForm sig k 4 → Formula) : NormalForm sig k 4 → TemporalPred :=
  fun σ => ⟨charFib σ⟩

/-- One arrangement disjunct, de-folded (arity-4 analog of `igMkDisjunct`, `:276-284`). -/
def igMkDisjunctFib {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds] {k : Nat}
    (charBase : NormalForm sig 0 1 → Formula) (charFib : NormalForm sig k 4 → Formula)
    (r : NormalForm sig 0 3) (b : ZoneSpec 3 → NormalForm sig k 4 → Bool)
    (lL lR : List (NormalForm sig k 4)) : Σ n, VecEA2 n :=
  ⟨(lL.map (igCharPFib charFib)).length + 1 + (lR.map (igCharPFib charFib)).length,
    { endpointLeft := igEpLFib charBase charFib r b
      endpointRight := igEpRFib charBase charFib r b
      bracket := bracketFromLists (lL.map (igCharPFib charFib)) (igPtWFib charBase charFib r b)
        (lR.map (igCharPFib charFib)) (igSegLFib charFib b) (igSegRFib charFib b) }⟩

/-- **De-folded public body replica** (arity-4 analog of `igBody`, `:290-299`).
    The gate-guarded `S_L`/`S_R` permutation-arrangement disjunction, built from the de-folded
    arity-4 pieces above. This is the public structural surface Phase 2 destructures (`igBodyFib`
    `.holds ↔ …`) and the sibling carrier `bracketEndChar_kvFib` mirrors. -/
def igBodyFib {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds] {k : Nat}
    (charBase : NormalForm sig 0 1 → Formula) (charFib : NormalForm sig k 4 → Formula)
    (r : NormalForm sig 0 3) (offFiber : Prop) (b : ZoneSpec 3 → NormalForm sig k 4 → Bool) :
    VVecEA2 :=
  @dite _ (igGateFib offFiber b) (Classical.dec (igGateFib offFiber b))
    (fun _ =>
      { disjuncts :=
          (igSLFib b).permutations.flatMap (fun lL =>
            (igSRFib b).permutations.map (fun lR => igMkDisjunctFib charBase charFib r b lL lR)) })
    (fun _ => { disjuncts := [] })

/-- **De-folded `holds` destructuring of the public replica** (arity-4 analog of
    `igBody_holds_iff`, `:359-379`). Byte-parallel clone re-keyed onto the de-folded arity-4 pieces:
    the replica's `VVecEA2.holds` splits into the gate conjunct ∧ the `S_L`/`S_R` permutation
    disjunction; off-gate it is the empty disjunction `⟨[]⟩` whose `holds` is `False`. No chain step
    is shortcut: pure list-membership and `dite` computation. -/
theorem igBodyFib_holds_iff {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds]
    {k : Nat}
    (charBase : NormalForm sig 0 1 → Formula) (charFib : NormalForm sig k 4 → Formula)
    (r : NormalForm sig 0 3) (offFiber : Prop) (b : ZoneSpec 3 → NormalForm sig k 4 → Bool)
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds) (x t : M.carrier) :
    (igBodyFib charBase charFib r offFiber b).holds M atomMap x t ↔
      igGateFib offFiber b ∧
      ∃ lL ∈ (igSLFib b).permutations, ∃ lR ∈ (igSRFib b).permutations,
        (igMkDisjunctFib charBase charFib r b lL lR).2.holds M atomMap x t := by
  unfold igBodyFib
  by_cases hg : igGateFib offFiber b
  · rw [dif_pos hg,
      VVecEA2.holds_flatMap_map M atomMap (igSLFib b).permutations (igSRFib b).permutations
        (igMkDisjunctFib charBase charFib r b) x t]
    exact ⟨fun h => ⟨hg, h⟩, fun h => h.2⟩
  · rw [dif_neg hg]
    constructor
    · intro h
      obtain ⟨vea, hmem, -⟩ := h
      exact (List.not_mem_nil hmem).elim
    · intro h
      exact (hg h.1).elim

/-- **De-folded defeq bridge: the successor de-folded carrier IS the public replica** (the
    Phase 2; arity-4 analog of the FROZEN `bracketEndChar_kv_succ_eq`, `:339-351`). The `k+1` branch
    of the sibling `bracketEndChar_kvFib` (`CarrierKv.lean:582-587`) feeds the private `kvFib_body`
    the depth-`k` arity-4 providers, the atom-layer off-fiber conjunct, and the NON-PROJECTING fold
    bit; `igBodyFib` is a verbatim public copy of `kvFib_body`'s body at the SAME args, and the fold
    bit is matched byte-for-byte by `igFoldBitFib` (both `Classical.propDecidable`). Per the plan
    the
    parallel-to-frozen bridge need NOT be `rfl`, but here it IS a pure `rfl` — the sibling carrier
    and
    its replica were built byte-parallel in Phase 1. Frozen `bracketEndChar_kv` untouched. -/
theorem bracketEndChar_kvFib_succ_eq {sig : MonadicSignature} [Fintype sig.preds]
    [DecidableEq sig.preds] {k : Nat}
    (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    (charFib : (j : Nat) → NormalForm sig j 4 → Formula)
    (qnf : NormalForm sig (k + 1) 3) :
    bracketEndChar_kvFib atomMap h_surj charFib (k + 1) qnf =
      igBodyFib (nf_depth0_char_formula atomMap h_surj) (charFib k) qnf.1
        (∀ sub : NormalForm sig k 4,
          nf0_dropFresh (NormalForm.atom_assgn sub) ≠ qnf.1 → qnf.2 sub = false)
        (igFoldBitFib qnf) := by
  -- The carrier's fold bit and `igFoldBitFib` compute the SAME Bool but under different `Decidable`
  -- instances (CarrierKv has no `DecidableEq (ZoneSpec 3)` in scope, so its `And` uses
  -- `instDecidableAnd (instDecidableEqBool) (Classical.propDecidable)`; `igFoldBitFib` uses
  -- `Classical.propDecidable` on the whole `And`). They are propositionally equal by
  -- decide-instance
  -- irrelevance (`Subsingleton.elim` on `Decidable`), so the bridge is a proven `Eq`, not `rfl`.
  have hfold : igFoldBitFib qnf =
      (fun (zs : ZoneSpec 3) (sub : NormalForm sig k 4) =>
        @decide (qnf.2 sub = true ∧ nf0_zoneSpec (NormalForm.atom_assgn sub) = zs)
          (@instDecidableAnd (qnf.2 sub = true) (nf0_zoneSpec (NormalForm.atom_assgn sub) = zs)
            (instDecidableEqBool (qnf.2 sub) true)
            (Classical.propDecidable _))) := by
    funext zs sub
    unfold igFoldBitFib
    exact congrArg _ (Subsingleton.elim _ _)
  simp only [bracketEndChar_kvFib, hfold]
  rfl

/-- **Successor de-folded carrier `holds` destructuring** (the deliverable;
    arity-4 analog of the FROZEN `bracketEndChar_kv_succ_holds_iff`, `:400-413`). Combines the
    de-folded defeq bridge `bracketEndChar_kvFib_succ_eq` with the replica destructuring
    `igBodyFib_holds_iff`: the successor de-folded carrier's `.holds` at the fixed anchor pair
    `(x, t)` is the gate conjunct ∧ the `S_L`/`S_R` permutation-arrangement disjunction. Unlike the
    frozen version, the fold bit is the NON-PROJECTING `igFoldBitFib` (full arity-4 fiber, no
    `nfk_projFresh` collapse — the F1 channel M2 preserves). This is the de-folded structural entry
    point for Phase 3 (render-free extraction) and Phases 4-5. -/
theorem bracketEndChar_kvFib_succ_holds_iff {sig : MonadicSignature} [Fintype sig.preds]
    [DecidableEq sig.preds] {k : Nat}
    (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    (charFib : (j : Nat) → NormalForm sig j 4 → Formula)
    (qnf : NormalForm sig (k + 1) 3)
    (M : OrderedMonadicStructure sig) (x t : M.carrier) :
    (bracketEndChar_kvFib atomMap h_surj charFib (k + 1) qnf).holds M atomMap x t ↔
      igGateFib (∀ sub : NormalForm sig k 4,
          nf0_dropFresh (NormalForm.atom_assgn sub) ≠ qnf.1 → qnf.2 sub = false)
          (igFoldBitFib qnf) ∧
      ∃ lL ∈ (igSLFib (igFoldBitFib qnf)).permutations,
        ∃ lR ∈ (igSRFib (igFoldBitFib qnf)).permutations,
        (igMkDisjunctFib (nf_depth0_char_formula atomMap h_surj) (charFib k) qnf.1
          (igFoldBitFib qnf) lL lR).2.holds M atomMap x t := by
  rw [bracketEndChar_kvFib_succ_eq atomMap h_surj charFib qnf]
  exact igBodyFib_holds_iff (nf_depth0_char_formula atomMap h_surj) (charFib k) qnf.1
    (∀ sub : NormalForm sig k 4,
      nf0_dropFresh (NormalForm.atom_assgn sub) ≠ qnf.1 → qnf.2 sub = false)
    (igFoldBitFib qnf) M atomMap x t

/-! ## Phase 3 — render-free endpoint→arity-4 realizer extraction (replaces `igFoldBit_realize_iff`)

THE load-bearing decircularizing move of the M2 redesign. The frozen bridge
`igFoldBit_realize_iff` (`:563`) turns fold content into a model realizer but REQUIRES the deep
render `nf_eval_nf M (k+1) 3 [w,x,t] qnf` as an explicit hypothesis — the very render this content
is
upstream of (produced at `ExteriorGateAssembleK.lean:337-338`), making the firing route for
`kampPrior_hreal_supply` (`InteriorHrealSupplyK.lean:53-116`) machine-confirmed CIRCULAR.

The de-folded carrier fixes this at the source: unlike the frozen `igFoldBit` (which lossily
`∃`-projects the arity-4 fiber to `(zone, χ:NF k 1)`), the sibling `igFoldBitFib` keeps the WHOLE
`σ:NF k 4` live, and the de-folded endpoint predicates (`igEpRFib`/`igEpLFib`, `:1365`/`:1356`)
carry
the FULL arity-4 characteristic formula `charFib σ` in their per-σ literals. So the σ-realizer is
readable DIRECTLY off the endpoint eval — no render.

The two extraction lemmas below (future@t via `igEpRFib`'s `untl` literal, past@x via `igEpLFib`'s
`snce` literal) take the de-folded endpoint eval and a render-FREE characteristic-soundness seam
`hcharFib` (the arity-4 analog of `interiorGate_hck`/`P.correct`; supplied by the provider `P` at
the
Phase-7 discharge site — it mentions NO `nf_eval_nf M _ 3 [...] qnf` render), and produce the
genuine
arity-4 realizer. NO chain step is shortcut (G5): the `untl`/`snce` firing is native temporal
semantics, the fiber content rides the full-arity `charFib σ` literal (G1/N4). -/

set_option maxHeartbeats 1600000 in
-- `bracketEndChar_kvFib_realize_futT` elaborates the general-`k` interior gate composition
-- together with its full provider inventory in a single declaration; the default
-- 200000-heartbeat budget is not enough to typecheck it.
/-- **Render-free FUTURE endpoint→arity-4 realizer extraction** (the deliverable;
    de-folded, render-free analog of `igFoldBit_realize_iff`, `:563`). From the de-folded RIGHT
    endpoint eval at `t` (`igEpRFib`) and a marked σ in the future-of-`t` zone (`b igZFutT σ =
    true`),
    reads the realizer `∃ x1 > t, nf_eval_nf M k 4 [x1,w,x,t] σ` DIRECTLY: the endpoint literal
    `Formula.untl (charFib σ) ⊤` fires a future point where the arity-4 characteristic formula
    holds,
    and the render-FREE soundness seam `hcharFib` turns that into the genuine realizer. The
    signature
    contains NO deep render `nf_eval_nf M _ 3 [...] qnf` hypothesis — this is the decircularizing
    edit
    (cf. the circular route diagnosed at `InteriorHrealSupplyK.lean:88-107`). -/
theorem bracketEndChar_kvFib_realize_futT {sig : MonadicSignature} [Fintype sig.preds]
    [DecidableEq sig.preds] {k : Nat}
    (charBase : NormalForm sig 0 1 → Formula) (charFib : NormalForm sig k 4 → Formula)
    (qnf : NormalForm sig (k + 1) 3)
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (w x t : M.carrier) (hxw : x < w) (hwt : w < t)
    -- ZONE-GUARDED render-free soundness seam: the marked-fiber
    -- guard `qnf.2 τ = true` and the `zoneHolds` guard block the cross-anchor-context transport
    -- refuted for the old unguarded `hcharFib`.
    (hcharFibSound : ∀ (τ : NormalForm sig k 4), qnf.2 τ = true →
      ∀ (x1 : M.carrier),
        zoneHolds M (Fin.cons w (Fin.cons x (fun _ => t)))
          (nf0_zoneSpec (NormalForm.atom_assgn τ)) x1 →
        temporal_truth M atomMap x1 (charFib τ) →
        nf_eval_nf M k 4 (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t)))) τ)
    (σ : NormalForm sig k 4) (hz : igFoldBitFib qnf igZFutT σ = true)
    (hepR : (igEpRFib charBase charFib qnf.1 (igFoldBitFib qnf)).eval_at M atomMap t) :
    ∃ x1 : M.carrier, t < x1 ∧
      nf_eval_nf M k 4 (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t)))) σ := by
  -- Enter the right-endpoint conjunction: every literal holds at `t`.
  simp only [igEpRFib, TemporalPred.eval_at] at hepR
  rw [formula_conjList_iff] at hepR
  -- The futT literal for our marked σ is `untl (charFib σ) ⊤` (in the RIGHT `++` block).
  have hlit : temporal_truth M atomMap t (Formula.untl (charFib σ) Formula.top) := by
    apply hepR
    apply List.mem_append_right
    refine List.mem_map.mpr ⟨σ, by simp [igAllSubs], ?_⟩
    simp only [igLit, hz, if_true]
  -- Fire the `until`: a future `x1 > t` where the arity-4 characteristic formula holds.
  simp only [temporal_truth] at hlit
  obtain ⟨x1, htx1, hgoal, -⟩ := hlit
  -- Decode the fold bit: σ is marked and its declared zone is igZFutT.
  have hdec : qnf.2 σ = true ∧ nf0_zoneSpec (NormalForm.atom_assgn σ) = igZFutT := by
    simpa only [igFoldBitFib, decide_eq_true_eq] using hz
  -- The zone witness: `t < x1` with `x < w < t` realizes igZFutT structurally.
  have hwx1 : w < x1 := hwt.trans htx1
  have hxx1 : x < x1 := hxw.trans hwx1
  have hzh : zoneHolds M (Fin.cons w (Fin.cons x (fun _ => t)))
      (nf0_zoneSpec (NormalForm.atom_assgn σ)) x1 := by
    rw [hdec.2, show igZFutT = Fin.cons (false, true) (Fin.cons (false, true)
        (fun _ => (false, true))) from rfl, k1v_zoneHolds_cons_iff]
    exact ⟨⟨iff_of_false (lt_asymm hwx1) (by simp), iff_of_true hwx1 rfl⟩,
      ⟨iff_of_false (lt_asymm hxx1) (by simp), iff_of_true hxx1 rfl⟩,
      ⟨iff_of_false (lt_asymm htx1) (by simp), iff_of_true htx1 rfl⟩⟩
  exact ⟨x1, htx1, hcharFibSound σ hdec.1 x1 hzh hgoal⟩

set_option maxHeartbeats 1600000 in
-- `bracketEndChar_kvFib_realize_pastX` elaborates the general-`k` interior gate composition
-- together with its full provider inventory in a single declaration; the default
-- 200000-heartbeat budget is not enough to typecheck it.
/-- **Render-free PAST endpoint→arity-4 realizer extraction**.
    From the de-folded LEFT endpoint eval at `x` (`igEpLFib`) and a marked σ in the past-of-`x` zone
    (`b igZPastX σ = true`), reads the realizer `∃ x1 < x, nf_eval_nf M k 4 [x1,w,x,t] σ` off the
    endpoint literal `Formula.snce (charFib σ) ⊤`. Render-free (same `hcharFib` seam). Symmetric to
    `bracketEndChar_kvFib_realize_futT`; supplies the past arm of the Phase-7 discharge. -/
theorem bracketEndChar_kvFib_realize_pastX {sig : MonadicSignature} [Fintype sig.preds]
    [DecidableEq sig.preds] {k : Nat}
    (charBase : NormalForm sig 0 1 → Formula) (charFib : NormalForm sig k 4 → Formula)
    (qnf : NormalForm sig (k + 1) 3)
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (w x t : M.carrier) (hxw : x < w) (hwt : w < t)
    -- ZONE-GUARDED render-free soundness seam.
    (hcharFibSound : ∀ (τ : NormalForm sig k 4), qnf.2 τ = true →
      ∀ (x1 : M.carrier),
        zoneHolds M (Fin.cons w (Fin.cons x (fun _ => t)))
          (nf0_zoneSpec (NormalForm.atom_assgn τ)) x1 →
        temporal_truth M atomMap x1 (charFib τ) →
        nf_eval_nf M k 4 (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t)))) τ)
    (σ : NormalForm sig k 4) (hz : igFoldBitFib qnf igZPastX σ = true)
    (hepL : (igEpLFib charBase charFib qnf.1 (igFoldBitFib qnf)).eval_at M atomMap x) :
    ∃ x1 : M.carrier, x1 < x ∧
      nf_eval_nf M k 4 (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t)))) σ := by
  simp only [igEpLFib, TemporalPred.eval_at] at hepL
  rw [formula_conjList_iff] at hepL
  -- The pastX literal for our marked σ is `snce (charFib σ) ⊤` (in the LEFT `++` block, first map).
  have hlit : temporal_truth M atomMap x (Formula.snce (charFib σ) Formula.top) := by
    apply hepL
    apply List.mem_append_left
    apply List.mem_cons_of_mem
    refine List.mem_map.mpr ⟨σ, by simp [igAllSubs], ?_⟩
    simp only [igLit, hz, if_true]
  simp only [temporal_truth] at hlit
  obtain ⟨x1, hx1x, hgoal, -⟩ := hlit
  -- Decode the fold bit: σ is marked and its declared zone is igZPastX.
  have hdec : qnf.2 σ = true ∧ nf0_zoneSpec (NormalForm.atom_assgn σ) = igZPastX := by
    simpa only [igFoldBitFib, decide_eq_true_eq] using hz
  -- The zone witness: `x1 < x` with `x < w < t` realizes igZPastX structurally.
  have hx1w : x1 < w := hx1x.trans hxw
  have hx1t : x1 < t := hx1w.trans hwt
  have hzh : zoneHolds M (Fin.cons w (Fin.cons x (fun _ => t)))
      (nf0_zoneSpec (NormalForm.atom_assgn σ)) x1 := by
    rw [hdec.2, show igZPastX = Fin.cons (true, false) (Fin.cons (true, false)
        (fun _ => (true, false))) from rfl, k1v_zoneHolds_cons_iff]
    exact ⟨⟨iff_of_true hx1w rfl, iff_of_false (lt_asymm hx1w) (by simp)⟩,
      ⟨iff_of_true hx1x rfl, iff_of_false (lt_asymm hx1x) (by simp)⟩,
      ⟨iff_of_true hx1t rfl, iff_of_false (lt_asymm hx1t) (by simp)⟩⟩
  exact ⟨x1, hx1x, hcharFibSound σ hdec.1 x1 hzh hgoal⟩

/-! ## Phase 4 — de-folded ⇐ completeness (realizer → sibling carrier holds)

The de-folded analog of `bracketEndChar_kv_step_complete` (`:693`), re-keyed from
the arity-1 1-type `χ : NormalForm sig k 1` onto the FULL arity-4 fiber `σ : NormalForm sig k 4`.
Given a genuine depth-`(k+1)` realizer at bracket witness `w`, the SIBLING de-folded carrier
`bracketEndChar_kvFib`'s `.holds` at the fixed endpoints `(x, t)`.

Two structural differences from the folded original, both consequences of the non-projecting fold:

1. **Fold biconditional is render-native, not projection-mediated.** The de-folded fold bit
   `igFoldBitFib qnf zs σ = decide (qnf.2 σ = true ∧ nf0_zoneSpec (atom_assgn σ) = zs)` reads the
   WHOLE fiber σ, so the fold-realization biconditional `igFoldBitFib qnf zs σ = true ↔ ∃ u,
   zoneHolds M [w,x,t] zs u ∧ nf_eval_nf M k 4 [u,w,x,t] σ` is proved DIRECTLY off the render's
   per-sub conjunct `(hw.2 σ)` — NO `nfk_projFresh`/`nf_characteristic`/`nf_eval_unique` roundtrip
   (the frozen `igFoldBit_realize_iff`, `:563`, needs all three because it must rebuild the dropped
   fiber). This is the F1 channel M2 preserves, here in completeness form.
2. **Interior point-type seam is arity-4 and w-gated.** The interior char bridge `hcharFib` relates
   `temporal_truth M atomMap u (charFib k σ) ↔ nf_eval_nf M k 4 [u,w,x,t] σ` — an arity-4 seam that,
   unlike the folded arity-1 `interiorGate_hck`, depends on the bracket witness `w`; it is supplied
   as a hypothesis GATED on the render (only asserted at `w`'s that realize `qnf`, where `charFib`
   is meaningful). The base endpoint seam stays the depth-0 `interiorGate_hcb`.

No chain step is shortcut (G5); the fold rides the full arity-4 fiber throughout (F1/N4). -/

set_option maxHeartbeats 1600000 in
-- `igk_sorted_realization_fib` elaborates the general-`k` interior gate composition together
-- with its full provider inventory in a single declaration; the default 200000-heartbeat budget
-- is not enough to typecheck it.
/-- **Depth-`k` arity-4 arrangement selection** (arity-4 analog of
    `igk_sorted_realization`, `:637`). Every list of complete depth-`k` arity-4 fibers each realized
    somewhere strictly inside `(a, b)` over the fixed frame `[·,w,x,t]` admits a simultaneous
    arrangement — a permutation tagged with realizing points in strictly increasing model order.
    Distinctness is automatic: distinct complete arity-4 fibers exclude each other at any single
    frame point (`nf_eval_unique M k 4`). Same insertion induction as the arity-1 original. -/
theorem igk_sorted_realization_fib {sig : MonadicSignature} [Fintype sig.preds]
    [DecidableEq sig.preds] {k : Nat}
    (M : OrderedMonadicStructure sig)
    (w x t : M.carrier)
    (a b : M.carrier)
    (S : List (NormalForm sig k 4)) (hnd : S.Nodup)
    (hreal : ∀ σ ∈ S, ∃ u, a < u ∧ u < b ∧
      nf_eval_nf M k 4 (Fin.cons u (Fin.cons w (Fin.cons x (fun _ => t)))) σ) :
    ∃ ps : List (NormalForm sig k 4 × M.carrier),
      List.Perm (ps.map Prod.fst) S ∧
      (ps.map Prod.snd).Pairwise (· < ·) ∧
      ∀ p ∈ ps, (a < p.2 ∧ p.2 < b) ∧
        nf_eval_nf M k 4 (Fin.cons p.2 (Fin.cons w (Fin.cons x (fun _ => t)))) p.1 := by
  induction S with
  | nil => exact ⟨[], by simp, by simp, by simp⟩
  | cons σ S' ih =>
    obtain ⟨u, hau, hub, huσ⟩ := hreal σ List.mem_cons_self
    obtain ⟨ps', hperm', hsort', hprops'⟩ :=
      ih (List.nodup_cons.mp hnd).2 (fun σ' h' => hreal σ' (List.mem_cons_of_mem _ h'))
    have hne : ∀ p ∈ ps', p.2 ≠ u := by
      intro p hp heq
      have hev : nf_eval_nf M k 4 (Fin.cons u (Fin.cons w (Fin.cons x (fun _ => t)))) p.1 :=
        heq ▸ (hprops' p hp).2
      have hpq : p.1 = σ := nf_eval_unique M k 4 _ p.1 σ hev huσ
      have : σ ∈ S' := hperm'.mem_iff.mp (hpq ▸ List.mem_map_of_mem hp)
      exact (List.nodup_cons.mp hnd).1 this
    obtain ⟨qs, hqperm, hqsort⟩ := k1v_sorted_insert M (σ, u) ps' hsort' hne
    refine ⟨qs, ?_, hqsort, ?_⟩
    · have h1 : List.Perm (qs.map Prod.fst) (((σ, u) :: ps').map Prod.fst) := hqperm.map _
      rw [List.map_cons] at h1
      exact h1.trans (hperm'.cons σ)
    · intro p hp
      rcases List.mem_cons.mp (hqperm.mem_iff.mp hp) with rfl | hp'
      · exact ⟨⟨hau, hub⟩, huσ⟩
      · exact hprops' p hp'

/-- **De-folded gate holder** (arity-4 analog of `bracketEndChar_kv_step_gate`,
    `:510`). From a genuine realizer at bracket witness `w`, the sibling carrier's gate holds: the
    off-fiber conjunct via `nf_eval_nfk_iff_efold`; the seven-zone conjunct routes each marked fiber
    `σ` through its atom-layer zone via `nf_eval_nf_atom_layer` + `igZone3_consistent`. Simpler than
    the folded gate: `igFoldBitFib` carries `nf0_zoneSpec (atom_assgn σ) = zs` directly, so no
    `igFoldBit_iff`/`nfk_projFresh` destructuring. -/
theorem bracketEndChar_kvFib_step_gate {sig : MonadicSignature} [Fintype sig.preds]
    [DecidableEq sig.preds] {k : Nat}
    (qnf : NormalForm sig (k + 1) 3)
    (M : OrderedMonadicStructure sig)
    (w x t : M.carrier) (hxw : x < w) (hwt : w < t)
    (h : nf_eval_nf M (k + 1) 3 (Fin.cons w (Fin.cons x (fun _ => t))) qnf) :
    igGateFib (∀ sub : NormalForm sig k 4,
        nf0_dropFresh (NormalForm.atom_assgn sub) ≠ qnf.1 → qnf.2 sub = false)
      (igFoldBitFib qnf) := by
  refine ⟨((nf_eval_nfk_iff_efold M _ qnf).mp h).2, ?_⟩
  intro zs σ hncons
  cases hbit : igFoldBitFib qnf zs σ with
  | false => rfl
  | true =>
    have hdec : qnf.2 σ = true ∧ nf0_zoneSpec (NormalForm.atom_assgn σ) = zs := by
      simpa only [igFoldBitFib, decide_eq_true_eq] using hbit
    obtain ⟨hmark, hzone⟩ := hdec
    obtain ⟨x1, hx1⟩ := (h.2 σ).mpr hmark
    have hatom := nf_eval_nf_atom_layer M (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t)))) σ hx1
    have hz : zoneHolds M (Fin.cons w (Fin.cons x (fun _ => t)))
        (nf0_zoneSpec (NormalForm.atom_assgn σ)) x1 := by
      intro i
      refine ⟨?_, ?_⟩
      · have h1 := hatom (.order 0 i.succ (Fin.succ_ne_zero i).symm)
        simp only [atom_eval, Fin.cons_zero, Fin.cons_succ] at h1
        exact h1
      · have h1 := hatom (.order i.succ 0 (Fin.succ_ne_zero i))
        simp only [atom_eval, Fin.cons_zero, Fin.cons_succ] at h1
        exact h1
    rw [hzone] at hz
    exact absurd (igZone3_consistent M w x t x1 hxw hwt zs hz) hncons

set_option maxHeartbeats 1600000 in
-- `bracketEndChar_kvFib_step_complete` elaborates the general-`k` interior gate composition
-- together with its full provider inventory in a single declaration; the default
-- 200000-heartbeat budget is not enough to typecheck it.
/-- **De-folded inductive step ⇐ completeness** (the deliverable; arity-4 analog
    of `bracketEndChar_kv_step_complete`, `:693`). From the arity-3 realizer at bracket witness `w`,
    the SIBLING de-folded carrier `bracketEndChar_kvFib`'s `.holds` at `(x, t)`, via
    `bracketEndChar_kvFib_succ_holds_iff`'s RHS: the de-folded gate
    (`bracketEndChar_kvFib_step_gate`)
    plus ONE sorted `S_L`/`S_R` arrangement whose `igMkDisjunctFib` bracket holds. The interior
    fiber
    types realize via the render-gated arity-4 seam `hcharFib`; the fold-realization biconditional
    is
    read DIRECTLY off the render (non-projecting fiber, F1 channel preserved). -/
theorem bracketEndChar_kvFib_step_complete {sig : MonadicSignature} [Fintype sig.preds]
    [DecidableEq sig.preds] {k : Nat}
    (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    (charFib : (j : Nat) → NormalForm sig j 4 → Formula)
    (qnf : NormalForm sig (k + 1) 3)
    (h_xy : qnf.1 (.order ⟨1, by omega⟩ ⟨0, by omega⟩ (by decide)) = true)
    (h_yt : qnf.1 (.order ⟨0, by omega⟩ ⟨2, by omega⟩ (by decide)) = true)
    (M : OrderedMonadicStructure sig)
    (x t : M.carrier)
    (hcharFib : ∀ (w : M.carrier),
      nf_eval_nf M (k + 1) 3 (Fin.cons w (Fin.cons x (fun _ => t))) qnf →
      ∀ (σ : NormalForm sig k 4) (u : M.carrier),
        temporal_truth M atomMap u (charFib k σ) ↔
          nf_eval_nf M k 4 (Fin.cons u (Fin.cons w (Fin.cons x (fun _ => t)))) σ) :
    (∃ w : M.carrier, nf_eval_nf M (k + 1) 3 (Fin.cons w (Fin.cons x (fun _ => t))) qnf) →
      (bracketEndChar_kvFib atomMap h_surj charFib (k + 1) qnf).holds M atomMap x t := by
  rintro ⟨w, hw⟩
  -- Atom layer + bracket order facts.
  have h_atom : nf_eval_nf M 0 3 (Fin.cons w (Fin.cons x (fun _ => t))) qnf.1 :=
    nf_eval_nf_atom_layer M _ qnf hw
  have hxw : x < w := by
    have h1 := h_atom (.order ⟨1, by omega⟩ ⟨0, by omega⟩ (by decide))
    simp only [atom_eval, Fin.cons] at h1
    exact h1.mpr h_xy
  have hwt : w < t := by
    have h1 := h_atom (.order ⟨0, by omega⟩ ⟨2, by omega⟩ (by decide))
    simp only [atom_eval, Fin.cons] at h1
    exact h1.mpr h_yt
  have hxt : x < t := hxw.trans hwt
  -- Interior arity-4 seam (render-gated) and depth-0 base seam.
  have hchar := hcharFib w hw
  have hcharB : ∀ (χ : NormalForm sig 0 1) (u : M.carrier),
      temporal_truth M atomMap u (nf_depth0_char_formula atomMap h_surj χ) ↔
        nf_eval_nf M 0 1 (fun _ => u) χ :=
    fun χ u => interiorGate_hcb atomMap h_surj M χ u
  -- Endpoint/witness arity-1 base evaluations (fixed points, reused arity-3 extractors).
  have h_y_nf := k1v_extract_y_nf M qnf.1 w x t h_atom
  have h_x_nf := k1v_extract_x_nf3 M qnf.1 w x t h_atom
  have h_t_nf := k1v_extract_t_nf3 M qnf.1 w x t h_atom
  -- Fold-realization biconditional (fiber bit ↔ interval witness), read DIRECTLY off the render.
  have hz' : ∀ (zs : ZoneSpec 3) (σ : NormalForm sig k 4),
      igFoldBitFib qnf zs σ = true ↔
        ∃ u : M.carrier, zoneHolds M (Fin.cons w (Fin.cons x (fun _ => t))) zs u ∧
          nf_eval_nf M k 4 (Fin.cons u (Fin.cons w (Fin.cons x (fun _ => t)))) σ := by
    intro zs σ
    constructor
    · intro hbit
      have hdec : qnf.2 σ = true ∧ nf0_zoneSpec (NormalForm.atom_assgn σ) = zs := by
        simpa only [igFoldBitFib, decide_eq_true_eq] using hbit
      obtain ⟨hmark, hzone⟩ := hdec
      obtain ⟨x1, hx1⟩ := (hw.2 σ).mpr hmark
      have hatom := nf_eval_nf_atom_layer M (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t)))) σ
          hx1
      refine ⟨x1, ?_, hx1⟩
      intro i
      refine ⟨?_, ?_⟩
      · have h1 := hatom (.order 0 i.succ (Fin.succ_ne_zero i).symm)
        simp only [atom_eval, Fin.cons_zero, Fin.cons_succ] at h1
        rw [← hzone]; exact h1
      · have h1 := hatom (.order i.succ 0 (Fin.succ_ne_zero i))
        simp only [atom_eval, Fin.cons_zero, Fin.cons_succ] at h1
        rw [← hzone]; exact h1
    · rintro ⟨u, hu, hev⟩
      have hmark : qnf.2 σ = true := (hw.2 σ).mp ⟨u, hev⟩
      have hatom := nf_eval_nf_atom_layer M (Fin.cons u (Fin.cons w (Fin.cons x (fun _ => t)))) σ
          hev
      have hzone : nf0_zoneSpec (NormalForm.atom_assgn σ) = zs := by
        funext i
        have h0 := hatom (.order 0 i.succ (Fin.succ_ne_zero i).symm)
        have h1 := hatom (.order i.succ 0 (Fin.succ_ne_zero i))
        simp only [atom_eval, Fin.cons_zero, Fin.cons_succ] at h0 h1
        have hb0 : (NormalForm.atom_assgn σ) (.order 0 i.succ (Fin.succ_ne_zero i).symm)
            = (zs i).1 := by
          rw [Bool.eq_iff_iff]; exact h0.symm.trans (hu i).1
        have hb1 : (NormalForm.atom_assgn σ) (.order i.succ 0 (Fin.succ_ne_zero i))
            = (zs i).2 := by
          rw [Bool.eq_iff_iff]; exact h1.symm.trans (hu i).2
        exact Prod.ext hb0 hb1
      simp only [igFoldBitFib, decide_eq_true_eq]
      exact ⟨hmark, hzone⟩
  -- Zone-membership constructors at the seven consistent zones (identical to the folded original).
  have hzPastX : ∀ u, u < x → zoneHolds M (Fin.cons w (Fin.cons x (fun _ => t)) : Fin 3 → M.carrier)
      igZPastX u := by
    intro u hux
    have huw : u < w := hux.trans hxw
    have hut : u < t := huw.trans hwt
    rw [show igZPastX = Fin.cons (true, false) (Fin.cons (true, false) (fun _ => (true, false)))
        from rfl, k1v_zoneHolds_cons_iff]
    exact ⟨⟨iff_of_true huw rfl, iff_of_false (lt_asymm huw) (by simp)⟩,
      ⟨iff_of_true hux rfl, iff_of_false (lt_asymm hux) (by simp)⟩,
      ⟨iff_of_true hut rfl, iff_of_false (lt_asymm hut) (by simp)⟩⟩
  have hzAtX : zoneHolds M (Fin.cons w (Fin.cons x (fun _ => t)) : Fin 3 → M.carrier) igZAtX x := by
    rw [show igZAtX = Fin.cons (true, false) (Fin.cons (false, false) (fun _ => (true, false)))
        from rfl, k1v_zoneHolds_cons_iff]
    exact ⟨⟨iff_of_true hxw rfl, iff_of_false (lt_asymm hxw) (by simp)⟩,
      ⟨iff_of_false (lt_irrefl x) (by simp), iff_of_false (lt_irrefl x) (by simp)⟩,
      ⟨iff_of_true hxt rfl, iff_of_false (lt_asymm hxt) (by simp)⟩⟩
  have hzXW : ∀ u, x < u → u < w →
      zoneHolds M (Fin.cons w (Fin.cons x (fun _ => t)) : Fin 3 → M.carrier) igZXW u := by
    intro u hxu huw
    have hut : u < t := huw.trans hwt
    rw [show igZXW = Fin.cons (true, false) (Fin.cons (false, true) (fun _ => (true, false)))
        from rfl, k1v_zoneHolds_cons_iff]
    exact ⟨⟨iff_of_true huw rfl, iff_of_false (lt_asymm huw) (by simp)⟩,
      ⟨iff_of_false (lt_asymm hxu) (by simp), iff_of_true hxu rfl⟩,
      ⟨iff_of_true hut rfl, iff_of_false (lt_asymm hut) (by simp)⟩⟩
  have hzAtW : zoneHolds M (Fin.cons w (Fin.cons x (fun _ => t)) : Fin 3 → M.carrier) igZAtW w := by
    rw [show igZAtW = Fin.cons (false, false) (Fin.cons (false, true) (fun _ => (true, false)))
        from rfl, k1v_zoneHolds_cons_iff]
    exact ⟨⟨iff_of_false (lt_irrefl w) (by simp), iff_of_false (lt_irrefl w) (by simp)⟩,
      ⟨iff_of_false (lt_asymm hxw) (by simp), iff_of_true hxw rfl⟩,
      ⟨iff_of_true hwt rfl, iff_of_false (lt_asymm hwt) (by simp)⟩⟩
  have hzWT : ∀ u, w < u → u < t →
      zoneHolds M (Fin.cons w (Fin.cons x (fun _ => t)) : Fin 3 → M.carrier) igZWT u := by
    intro u hwu hut
    have hxu : x < u := hxw.trans hwu
    rw [show igZWT = Fin.cons (false, true) (Fin.cons (false, true) (fun _ => (true, false)))
        from rfl, k1v_zoneHolds_cons_iff]
    exact ⟨⟨iff_of_false (lt_asymm hwu) (by simp), iff_of_true hwu rfl⟩,
      ⟨iff_of_false (lt_asymm hxu) (by simp), iff_of_true hxu rfl⟩,
      ⟨iff_of_true hut rfl, iff_of_false (lt_asymm hut) (by simp)⟩⟩
  have hzAtT : zoneHolds M (Fin.cons w (Fin.cons x (fun _ => t)) : Fin 3 → M.carrier) igZAtT t := by
    rw [show igZAtT = Fin.cons (false, true) (Fin.cons (false, true) (fun _ => (false, false)))
        from rfl, k1v_zoneHolds_cons_iff]
    exact ⟨⟨iff_of_false (lt_asymm hwt) (by simp), iff_of_true hwt rfl⟩,
      ⟨iff_of_false (lt_asymm hxt) (by simp), iff_of_true hxt rfl⟩,
      ⟨iff_of_false (lt_irrefl t) (by simp), iff_of_false (lt_irrefl t) (by simp)⟩⟩
  have hzFutT : ∀ u, t < u →
      zoneHolds M (Fin.cons w (Fin.cons x (fun _ => t)) : Fin 3 → M.carrier) igZFutT u := by
    intro u htu
    have hwu : w < u := hwt.trans htu
    have hxu : x < u := hxw.trans hwu
    rw [show igZFutT = Fin.cons (false, true) (Fin.cons (false, true) (fun _ => (false, true)))
        from rfl, k1v_zoneHolds_cons_iff]
    exact ⟨⟨iff_of_false (lt_asymm hwu) (by simp), iff_of_true hwu rfl⟩,
      ⟨iff_of_false (lt_asymm hxu) (by simp), iff_of_true hxu rfl⟩,
      ⟨iff_of_false (lt_asymm htu) (by simp), iff_of_true htu rfl⟩⟩
  -- Interior-positive realization: each positive interior fold bit yields an interval witness.
  have hLreal : ∀ σ : NormalForm sig k 4, igFoldBitFib qnf igZXW σ = true →
      ∃ u, x < u ∧ u < w ∧ nf_eval_nf M k 4 (Fin.cons u (Fin.cons w (Fin.cons x (fun _ => t))))
          σ := by
    intro σ hbit
    obtain ⟨u, hzu, hev⟩ := (hz' igZXW σ).mp hbit
    rw [show igZXW = Fin.cons (true, false) (Fin.cons (false, true) (fun _ => (true, false)))
        from rfl, k1v_zoneHolds_cons_iff] at hzu
    exact ⟨u, hzu.2.1.2.mpr rfl, hzu.1.1.mpr rfl, hev⟩
  have hRreal : ∀ σ : NormalForm sig k 4, igFoldBitFib qnf igZWT σ = true →
      ∃ u, w < u ∧ u < t ∧ nf_eval_nf M k 4 (Fin.cons u (Fin.cons w (Fin.cons x (fun _ => t))))
          σ := by
    intro σ hbit
    obtain ⟨u, hzu, hev⟩ := (hz' igZWT σ).mp hbit
    rw [show igZWT = Fin.cons (false, true) (Fin.cons (false, true) (fun _ => (true, false)))
        from rfl, k1v_zoneHolds_cons_iff] at hzu
    exact ⟨u, hzu.1.2.mpr rfl, hzu.2.2.1.mpr rfl, hev⟩
  -- Segment exclusions on ALL of `(x, w)` / `(w, t)`.
  have hsegL_all : ∀ u, x < u → u < w →
      (igSegLFib (charFib k) (igFoldBitFib qnf)).eval_at M atomMap u := by
    intro u hxu huw
    simp only [igSegLFib, TemporalPred.eval_at]
    rw [formula_conjList_iff]
    intro f hf
    obtain ⟨σ, -, rfl⟩ := List.mem_map.mp hf
    cases hb : igFoldBitFib qnf igZXW σ with
    | true => rw [if_pos rfl]; exact fun hfa => hfa
    | false =>
      rw [if_neg (by simp)]
      intro hch
      have hbit := (hz' igZXW σ).mpr ⟨u, hzXW u hxu huw, (hchar σ u).mp hch⟩
      rw [hb] at hbit; exact Bool.noConfusion hbit
  have hsegR_all : ∀ u, w < u → u < t →
      (igSegRFib (charFib k) (igFoldBitFib qnf)).eval_at M atomMap u := by
    intro u hwu hut
    simp only [igSegRFib, TemporalPred.eval_at]
    rw [formula_conjList_iff]
    intro f hf
    obtain ⟨σ, -, rfl⟩ := List.mem_map.mp hf
    cases hb : igFoldBitFib qnf igZWT σ with
    | true => rw [if_pos rfl]; exact fun hfa => hfa
    | false =>
      rw [if_neg (by simp)]
      intro hch
      have hbit := (hz' igZWT σ).mpr ⟨u, hzWT u hwu hut, (hchar σ u).mp hch⟩
      rw [hb] at hbit; exact Bool.noConfusion hbit
  -- Endpoint predicate at the FIXED left endpoint `x` (exterior Since literals, zPastX/zAtX).
  have hepL : (igEpLFib (nf_depth0_char_formula atomMap h_surj) (charFib k) qnf.1
      (igFoldBitFib qnf)).eval_at M atomMap x := by
    simp only [igEpLFib, igLit, TemporalPred.eval_at]
    rw [formula_conjList_iff]
    intro f hf
    rcases List.mem_append.mp hf with hf | hf
    · rcases List.mem_cons.mp hf with rfl | hf
      · exact (hcharB _ x).mpr h_x_nf
      · obtain ⟨σ, -, rfl⟩ := List.mem_map.mp hf
        cases hb : igFoldBitFib qnf igZPastX σ with
        | true =>
          rw [if_pos rfl]
          obtain ⟨u, hzu, hev⟩ := (hz' igZPastX σ).mp hb
          rw [show igZPastX = Fin.cons (true, false)
              (Fin.cons (true, false) (fun _ => (true, false)))
              from rfl, k1v_zoneHolds_cons_iff] at hzu
          exact ⟨u, hzu.2.1.1.mpr rfl, (hchar σ u).mpr hev, fun r _ _ hfa => hfa⟩
        | false =>
          rw [if_neg (by simp)]
          rintro ⟨s, hsx, hsσ, -⟩
          have hbit := (hz' igZPastX σ).mpr ⟨s, hzPastX s hsx, (hchar σ s).mp hsσ⟩
          rw [hb] at hbit; exact Bool.noConfusion hbit
    · obtain ⟨σ, -, rfl⟩ := List.mem_map.mp hf
      cases hb : igFoldBitFib qnf igZAtX σ with
      | true =>
        rw [if_pos rfl]
        obtain ⟨u, hzu, hev⟩ := (hz' igZAtX σ).mp hb
        rw [show igZAtX = Fin.cons (true, false) (Fin.cons (false, false) (fun _ => (true, false)))
            from rfl, k1v_zoneHolds_cons_iff] at hzu
        have hueq : u = x := le_antisymm
          (not_lt.mp (k1v_not_of_iff_false hzu.2.1.2))
          (not_lt.mp (k1v_not_of_iff_false hzu.2.1.1))
        exact (hchar σ x).mpr (hueq ▸ hev)
      | false =>
        rw [if_neg (by simp)]
        intro hch
        have hbit := (hz' igZAtX σ).mpr ⟨x, hzAtX, (hchar σ x).mp hch⟩
        rw [hb] at hbit; exact Bool.noConfusion hbit
  -- Endpoint predicate at the FIXED right endpoint `t` (exterior Until literals, zAtT/zFutT).
  have hepR : (igEpRFib (nf_depth0_char_formula atomMap h_surj) (charFib k) qnf.1
      (igFoldBitFib qnf)).eval_at M atomMap t := by
    simp only [igEpRFib, igLit, TemporalPred.eval_at]
    rw [formula_conjList_iff]
    intro f hf
    rcases List.mem_append.mp hf with hf | hf
    · rcases List.mem_cons.mp hf with rfl | hf
      · exact (hcharB _ t).mpr h_t_nf
      · obtain ⟨σ, -, rfl⟩ := List.mem_map.mp hf
        cases hb : igFoldBitFib qnf igZAtT σ with
        | true =>
          rw [if_pos rfl]
          obtain ⟨u, hzu, hev⟩ := (hz' igZAtT σ).mp hb
          rw [show igZAtT = Fin.cons (false, true)
              (Fin.cons (false, true) (fun _ => (false, false)))
              from rfl, k1v_zoneHolds_cons_iff] at hzu
          have hueq : u = t := le_antisymm
            (not_lt.mp (k1v_not_of_iff_false hzu.2.2.2))
            (not_lt.mp (k1v_not_of_iff_false hzu.2.2.1))
          exact (hchar σ t).mpr (hueq ▸ hev)
        | false =>
          rw [if_neg (by simp)]
          intro hch
          have hbit := (hz' igZAtT σ).mpr ⟨t, hzAtT, (hchar σ t).mp hch⟩
          rw [hb] at hbit; exact Bool.noConfusion hbit
    · obtain ⟨σ, -, rfl⟩ := List.mem_map.mp hf
      cases hb : igFoldBitFib qnf igZFutT σ with
      | true =>
        rw [if_pos rfl]
        obtain ⟨u, hzu, hev⟩ := (hz' igZFutT σ).mp hb
        rw [show igZFutT = Fin.cons (false, true) (Fin.cons (false, true) (fun _ => (false, true)))
            from rfl, k1v_zoneHolds_cons_iff] at hzu
        exact ⟨u, hzu.2.2.2.mpr rfl, (hchar σ u).mpr hev, fun r _ _ hfa => hfa⟩
      | false =>
        rw [if_neg (by simp)]
        rintro ⟨s, hts, hsσ, -⟩
        have hbit := (hz' igZFutT σ).mpr ⟨s, hzFutT s hts, (hchar σ s).mp hsσ⟩
        rw [hb] at hbit; exact Bool.noConfusion hbit
  -- Witness point type at `w` (complete type + equality-zone literals ONLY, rule N4).
  have hptW : (igPtWFib (nf_depth0_char_formula atomMap h_surj) (charFib k) qnf.1
      (igFoldBitFib qnf)).eval_at M atomMap w := by
    simp only [igPtWFib, igLit, TemporalPred.eval_at]
    rw [formula_conjList_iff]
    intro f hf
    rcases List.mem_cons.mp hf with rfl | hf
    · exact (hcharB _ w).mpr h_y_nf
    · obtain ⟨σ, -, rfl⟩ := List.mem_map.mp hf
      cases hb : igFoldBitFib qnf igZAtW σ with
      | true =>
        rw [if_pos rfl]
        obtain ⟨u, hzu, hev⟩ := (hz' igZAtW σ).mp hb
        rw [show igZAtW = Fin.cons (false, false) (Fin.cons (false, true) (fun _ => (true, false)))
            from rfl, k1v_zoneHolds_cons_iff] at hzu
        have hueq : u = w := le_antisymm
          (not_lt.mp (k1v_not_of_iff_false hzu.1.2))
          (not_lt.mp (k1v_not_of_iff_false hzu.1.1))
        exact (hchar σ w).mpr (hueq ▸ hev)
      | false =>
        rw [if_neg (by simp)]
        intro hch
        have hbit := (hz' igZAtW σ).mpr ⟨w, hzAtW, (hchar σ w).mp hch⟩
        rw [hb] at hbit; exact Bool.noConfusion hbit
  -- Sorted arrangements of the interior-positive enumerations.
  obtain ⟨psL, hpermL, hsortL, hpropsL⟩ :=
    igk_sorted_realization_fib M w x t x w (igSLFib (igFoldBitFib qnf))
      ((Finset.nodup_toList _).filter _)
      (fun σ hσ => hLreal σ (by simpa only [igSLFib, igAllSubs, decide_eq_true_eq]
        using (List.mem_filter.mp hσ).2))
  obtain ⟨psR, hpermR, hsortR, hpropsR⟩ :=
    igk_sorted_realization_fib M w x t w t (igSRFib (igFoldBitFib qnf))
      ((Finset.nodup_toList _).filter _)
      (fun σ hσ => hRreal σ (by simpa only [igSRFib, igAllSubs, decide_eq_true_eq]
        using (List.mem_filter.mp hσ).2))
  -- Combined witness list is sorted: left points < w < right points.
  have hsortFull : (psL.map Prod.snd ++ w :: psR.map Prod.snd).Pairwise (· < ·) := by
    rw [List.pairwise_append]
    refine ⟨hsortL, ?_, ?_⟩
    · rw [List.pairwise_cons]
      refine ⟨?_, hsortR⟩
      intro b hb
      obtain ⟨p, hp, rfl⟩ := List.mem_map.mp hb
      exact (hpropsR p hp).1.1
    · intro a ha b hb
      obtain ⟨p, hp, rfl⟩ := List.mem_map.mp ha
      have haw : p.2 < w := (hpropsL p hp).1.2
      rcases List.mem_cons.mp hb with rfl | hb
      · exact haw
      · obtain ⟨q, hq, rfl⟩ := List.mem_map.mp hb
        exact haw.trans (hpropsR q hq).1.1
  -- Enter the sibling carrier via the Phase-2 destructuring; gate + the (psL, psR) arrangement.
  rw [bracketEndChar_kvFib_succ_holds_iff atomMap h_surj charFib qnf M x t]
  refine ⟨bracketEndChar_kvFib_step_gate qnf M w x t hxw hwt hw,
    psL.map Prod.fst, List.mem_permutations.mpr hpermL,
    psR.map Prod.fst, List.mem_permutations.mpr hpermR, hepL, hepR, ?_⟩
  -- The bracket: assembled by the reused construction lemma from the sorted realizations.
  refine k1v_bracket_construct M atomMap _ _ _ _ _ x w t hxw hwt
    (psL.map Prod.snd) (psR.map Prod.snd) (by simp) (by simp) hsortFull
    ?_ ?_ hptW ?_ ?_ hsegL_all hsegR_all
  · intro u hu
    obtain ⟨p, hp, rfl⟩ := List.mem_map.mp hu
    exact (hpropsL p hp).1
  · intro u hu
    obtain ⟨p, hp, rfl⟩ := List.mem_map.mp hu
    exact (hpropsR p hp).1
  · intro i hi
    have hi' : i < psL.length := by simpa using hi
    have h1 : (List.map (igCharPFib (charFib k)) (psL.map Prod.fst))[i]'hi =
        igCharPFib (charFib k) ((psL[i]'hi').1) := by simp only [List.getElem_map]
    have h2 : (psL.map Prod.snd)[i]'(by simpa using hi') = (psL[i]'hi').2 := by
      simp only [List.getElem_map]
    rw [h1, h2]
    simp only [igCharPFib, TemporalPred.eval_at]
    exact (hchar _ _).mpr (hpropsL _ (List.getElem_mem _)).2
  · intro i hi
    have hi' : i < psR.length := by simpa using hi
    have h1 : (List.map (igCharPFib (charFib k)) (psR.map Prod.fst))[i]'hi =
        igCharPFib (charFib k) ((psR[i]'hi').1) := by simp only [List.getElem_map]
    have h2 : (psR.map Prod.snd)[i]'(by simpa using hi') = (psR[i]'hi').2 := by
      simp only [List.getElem_map]
    rw [h1, h2]
    simp only [igCharPFib, TemporalPred.eval_at]
    exact (hchar _ _).mpr (hpropsR _ (List.getElem_mem _)).2

/-! ## Phase 5 — de-folded step_sound analog + re-keyed binders

The de-folded analog of `bracketEndChar_kv_step_sound` (`:1043`), re-keyed from the
arity-1 1-type `χ : NormalForm sig k 1` onto the FULL arity-4 fiber `σ : NormalForm sig k 4`. From
the
SIBLING de-folded carrier `bracketEndChar_kvFib`'s `.holds` at the fixed endpoints `(x, t)`, a
genuine
depth-`(k+1)` realizer at bracket witness `w`.

The soundness body is byte-parallel to the folded original — the fiber-realization biconditional it
produces is about the TARGET `qnf` (arity-3), so the `refine ⟨w, h_atom, ?_⟩ / intro sub /
constructor`
core is IDENTICAL. Two things change, both purely the sibling re-key:

1. **Carrier entry.** Destructuring goes through `bracketEndChar_kvFib_succ_holds_iff` (`:1515`)
and the
   `igMkDisjunctFib`/`igEpLFib`/`igEpRFib`/`igPtWFib` de-folded pieces; the generic bracket
   extractor
   `k1v_bracket_extract` is reused verbatim (it is abstract in `lL lR ptW segL segR`).
2. **Re-keyed provider binders.** The `hreal`/`hexcl`/`hexclExt` obligation binders are gated on
   `igPtWFib (…) (charFib k) qnf.1 (igFoldBitFib qnf)` at `w` (the extracted `hptWe`), the arity-4
   analog of the folded `igPtW (…) (charF k) qnf.1 (igFoldBit qnf)` gate. The realizer/exclusion
   payloads (`∃ x1, nf_eval_nf M k 4 [x1,w,x,t] σ` and its negation) are the SAME arity-4
   statements the
   folded binders already carried — the fold was never the loss point for the binders; only the gate
   they hang off is re-keyed to the non-projecting fiber. No chain step is shortcut (G5). -/

set_option maxHeartbeats 1600000 in
-- `bracketEndChar_kvFib_step_sound` elaborates the general-`k` interior gate composition
-- together with its full provider inventory in a single declaration; the default
-- 200000-heartbeat budget is not enough to typecheck it.
/-- **De-folded inductive step ⇒ soundness** (the deliverable; arity-4 analog of
    `bracketEndChar_kv_step_sound`, `:1043`). From the SIBLING de-folded carrier
    `bracketEndChar_kvFib`'s `.holds` at `(x, t)`, a genuine depth-`(k+1)` realizer at a bracket
    witness `w`. The `hreal`/`hexcl`/`hexclExt` provider binders are re-keyed onto the
    non-projecting
    fiber gate `igPtWFib (…) (charFib k) qnf.1 (igFoldBitFib qnf)`; the fiber-realization
    biconditional
    on the target `qnf` is proved identically to the folded original. -/
theorem bracketEndChar_kvFib_step_sound {sig : MonadicSignature} [Fintype sig.preds]
    [DecidableEq sig.preds] {k : Nat}
    (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    (charFib : (j : Nat) → NormalForm sig j 4 → Formula)
    (qnf : NormalForm sig (k + 1) 3)
    (h_xy : qnf.1 (.order ⟨1, by omega⟩ ⟨0, by omega⟩ (by decide)) = true)
    (h_yt : qnf.1 (.order ⟨0, by omega⟩ ⟨2, by omega⟩ (by decide)) = true)
    (h_xt : qnf.1 (.order ⟨1, by omega⟩ ⟨2, by omega⟩ (by decide)) = true)
    (h_yx : qnf.1 (.order ⟨0, by omega⟩ ⟨1, by omega⟩ (by decide)) = false)
    (h_ty : qnf.1 (.order ⟨2, by omega⟩ ⟨0, by omega⟩ (by decide)) = false)
    (h_tx : qnf.1 (.order ⟨2, by omega⟩ ⟨1, by omega⟩ (by decide)) = false)
    (M : OrderedMonadicStructure sig) (x t : M.carrier)
    -- Render-free char-soundness seam (by-design, `w`-universal; the arity-4 analog of the folded
    -- `P`/`hcharK`, threaded like `hreal`). Supplies the `hreal` obligation's per-`w` char seam.
    (hcharFibSoundP : ∀ (w : M.carrier) (τ : NormalForm sig k 4) (x1 : M.carrier),
      temporal_truth M atomMap x1 (charFib k τ) →
      nf_eval_nf M k 4 (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t)))) τ)
    (hreal : ∀ w : M.carrier, x < w → w < t →
      (igPtWFib (nf_depth0_char_formula atomMap h_surj) (charFib k) qnf.1
          (igFoldBitFib qnf)).eval_at
        M atomMap w →
      (igEpLFib (nf_depth0_char_formula atomMap h_surj) (charFib k) qnf.1
          (igFoldBitFib qnf)).eval_at
        M atomMap x →
      (igEpRFib (nf_depth0_char_formula atomMap h_surj) (charFib k) qnf.1
          (igFoldBitFib qnf)).eval_at
        M atomMap t →
      (∀ (τ : NormalForm sig k 4) (x1 : M.carrier),
        temporal_truth M atomMap x1 (charFib k τ) →
        nf_eval_nf M k 4 (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t)))) τ) →
      (∀ σ : NormalForm sig k 4, igFoldBitFib qnf igZXW σ = true →
        ∃ x1 : M.carrier, x < x1 ∧ x1 < w ∧
          nf_eval_nf M k 4 (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t)))) σ) →
      (∀ σ : NormalForm sig k 4, igFoldBitFib qnf igZWT σ = true →
        ∃ x1 : M.carrier, w < x1 ∧ x1 < t ∧
          nf_eval_nf M k 4 (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t)))) σ) →
      (∀ σ : NormalForm sig k 4, qnf.2 σ = true →
        nf0_zoneSpec (NormalForm.atom_assgn σ) = igZPastX ∨
        nf0_zoneSpec (NormalForm.atom_assgn σ) = igZAtX ∨
        nf0_zoneSpec (NormalForm.atom_assgn σ) = igZXW ∨
        nf0_zoneSpec (NormalForm.atom_assgn σ) = igZAtW ∨
        nf0_zoneSpec (NormalForm.atom_assgn σ) = igZWT ∨
        nf0_zoneSpec (NormalForm.atom_assgn σ) = igZAtT ∨
        nf0_zoneSpec (NormalForm.atom_assgn σ) = igZFutT) →
      ∀ σ : NormalForm sig k 4, qnf.2 σ = true →
        ∃ x1 : M.carrier,
          nf_eval_nf M k 4 (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t)))) σ)
    (hexcl : ∀ w : M.carrier, x < w → w < t →
      (igPtWFib (nf_depth0_char_formula atomMap h_surj) (charFib k) qnf.1
          (igFoldBitFib qnf)).eval_at
        M atomMap w →
      ∀ σ : NormalForm sig k 4, qnf.2 σ = false →
        ∀ x1 : M.carrier, x ≤ x1 → x1 ≤ t →
          ¬ nf_eval_nf M k 4 (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t)))) σ)
    (hexclExt : ∀ w : M.carrier, x < w → w < t →
      (igPtWFib (nf_depth0_char_formula atomMap h_surj) (charFib k) qnf.1
          (igFoldBitFib qnf)).eval_at
        M atomMap w →
      ∀ σ : NormalForm sig k 4, qnf.2 σ = false →
        ∀ x1 : M.carrier, ¬ (x ≤ x1 ∧ x1 ≤ t) →
          ¬ nf_eval_nf M k 4 (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t)))) σ) :
    (bracketEndChar_kvFib atomMap h_surj charFib (k + 1) qnf).holds M atomMap x t →
      ∃ w : M.carrier, nf_eval_nf M (k + 1) 3 (Fin.cons w (Fin.cons x (fun _ => t))) qnf := by
  intro h_holds
  -- Enter the sibling carrier via the Phase-2 destructuring: gate + one arrangement disjunct.
  rw [bracketEndChar_kvFib_succ_holds_iff atomMap h_surj charFib qnf M x t] at h_holds
  obtain ⟨hgate, lL, hlL, lR, hlR, hveah⟩ := h_holds
  obtain ⟨hepL, hepR, hbr⟩ := hveah
  -- Extract the bracket witness `w` (`x < w < t`), its `igPtWFib` eval, and the interior
  -- `S_L`/`S_R`
  -- realizers (KEPT, not dropped — they supply the `igZXW`/`igZWT` interior seams `hIntL`/`hIntR`).
  obtain ⟨w, hxw, hwt, hptWe, hlLreal, hlRreal, -, -⟩ :=
    k1v_bracket_extract M atomMap _ _ _ _ _ x t hbr
  have hxt : x < t := hxw.trans hwt
  -- Depth-0 endpoint/witness char bridge (arity-1, reused verbatim from the folded original).
  have hcharB : ∀ (χ : NormalForm sig 0 1) (u : M.carrier),
      temporal_truth M atomMap u (nf_depth0_char_formula atomMap h_surj χ) ↔
        nf_eval_nf M 0 1 (fun _ => u) χ :=
    fun χ u => interiorGate_hcb atomMap h_surj M χ u
  -- Endpoint/witness complete types (heads of the de-folded conjunction lists). `hptWe` is kept RAW
  -- for the provider obligations; the witness head is read off a copy.
  have hxT : temporal_truth M atomMap x
      (nf_depth0_char_formula atomMap h_surj (nf_x_proj3 qnf.1)) := by
    have h := hepL
    simp only [igMkDisjunctFib, igEpLFib, TemporalPred.eval_at] at h
    rw [formula_conjList_iff] at h
    exact h _ (List.mem_append_left _ List.mem_cons_self)
  have htT : temporal_truth M atomMap t
      (nf_depth0_char_formula atomMap h_surj (nf_t_proj3 qnf.1)) := by
    have h := hepR
    simp only [igMkDisjunctFib, igEpRFib, TemporalPred.eval_at] at h
    rw [formula_conjList_iff] at h
    exact h _ (List.mem_append_left _ List.mem_cons_self)
  have hyW : temporal_truth M atomMap w
      (nf_depth0_char_formula atomMap h_surj (nf_y_proj qnf.1)) := by
    have h := hptWe
    simp only [igPtWFib, TemporalPred.eval_at] at h
    rw [formula_conjList_iff] at h
    exact h _ List.mem_cons_self
  -- Reconstruct the depth-0 atom layer at `[w, x, t]` (Chain step 2, rule N1 framing).
  have h_atom : nf_eval_nf M 0 3 (Fin.cons w (Fin.cons x (fun _ => t))) qnf.1 :=
    k1v_reconstruct_nf3 M qnf.1 w x t
      ((hcharB _ w).mp hyW) ((hcharB _ x).mp hxT) ((hcharB _ t).mp htT)
      (iff_of_false (lt_asymm hxw) (by simp only [h_yx]; decide))
      (iff_of_true hwt h_yt)
      (iff_of_true hxw h_xy)
      (iff_of_true hxt h_xt)
      (iff_of_false (lt_asymm hwt) (by simp only [h_ty]; decide))
      (iff_of_false (lt_asymm hxt) (by simp only [h_tx]; decide))
  -- Assemble the realizer: atom layer + the per-sub fiber biconditional (about the target `qnf`).
  refine ⟨w, h_atom, ?_⟩
  intro sub
  constructor
  · -- realizable → marked: an unmarked sub is realized at NO point (cone `hexcl` ∪ exterior
    -- `hexclExt` cover every `x1`), contradicting the given realizer.
    rintro ⟨x1, hx1⟩
    by_contra hne
    have hf : qnf.2 sub = false := by
      cases hb : qnf.2 sub with
      | true => exact absurd hb hne
      | false => rfl
    by_cases hcone : x ≤ x1 ∧ x1 ≤ t
    · exact hexcl w hxw hwt hptWe sub hf x1 hcone.1 hcone.2 hx1
    · exact hexclExt w hxw hwt hptWe sub hf x1 hcone hx1
  · -- marked → realizable: the de-folded `hreal` now receives the endpoint evals, the render-free
    -- char seam (`hcharFibSoundP w`), the two interior bracket realizer seams (`hIntL`/`hIntR`,
    -- read
    -- off `S_L`/`S_R`), and the zone-consistency seam (`hzcons`, from the gate) — all in scope here
    -- from the carrier's `.holds`.
    intro hmark
    have hIntL : ∀ σ : NormalForm sig k 4, igFoldBitFib qnf igZXW σ = true →
        ∃ x1 : M.carrier, x < x1 ∧ x1 < w ∧
          nf_eval_nf M k 4 (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t)))) σ := by
      intro σ' hbit
      have hσmem : σ' ∈ igSLFib (igFoldBitFib qnf) := by
        simp only [igSLFib, igAllSubs, List.mem_filter]
        exact ⟨Finset.mem_toList.mpr (Finset.mem_univ σ'), hbit⟩
      have hσlL : σ' ∈ lL := (List.mem_permutations.mp hlL).mem_iff.mpr hσmem
      obtain ⟨u, hxu, huw, hpu⟩ := hlLreal (igCharPFib (charFib k) σ') (List.mem_map_of_mem hσlL)
      have htt : temporal_truth M atomMap u (charFib k σ') := by
        simpa only [igCharPFib, TemporalPred.eval_at] using hpu
      exact ⟨u, hxu, huw, hcharFibSoundP w σ' u htt⟩
    have hIntR : ∀ σ : NormalForm sig k 4, igFoldBitFib qnf igZWT σ = true →
        ∃ x1 : M.carrier, w < x1 ∧ x1 < t ∧
          nf_eval_nf M k 4 (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t)))) σ := by
      intro σ' hbit
      have hσmem : σ' ∈ igSRFib (igFoldBitFib qnf) := by
        simp only [igSRFib, igAllSubs, List.mem_filter]
        exact ⟨Finset.mem_toList.mpr (Finset.mem_univ σ'), hbit⟩
      have hσlR : σ' ∈ lR := (List.mem_permutations.mp hlR).mem_iff.mpr hσmem
      obtain ⟨u, hwu, hut, hpu⟩ := hlRreal (igCharPFib (charFib k) σ') (List.mem_map_of_mem hσlR)
      have htt : temporal_truth M atomMap u (charFib k σ') := by
        simpa only [igCharPFib, TemporalPred.eval_at] using hpu
      exact ⟨u, hwu, hut, hcharFibSoundP w σ' u htt⟩
    have hzcons : ∀ σ : NormalForm sig k 4, qnf.2 σ = true →
        nf0_zoneSpec (NormalForm.atom_assgn σ) = igZPastX ∨
        nf0_zoneSpec (NormalForm.atom_assgn σ) = igZAtX ∨
        nf0_zoneSpec (NormalForm.atom_assgn σ) = igZXW ∨
        nf0_zoneSpec (NormalForm.atom_assgn σ) = igZAtW ∨
        nf0_zoneSpec (NormalForm.atom_assgn σ) = igZWT ∨
        nf0_zoneSpec (NormalForm.atom_assgn σ) = igZAtT ∨
        nf0_zoneSpec (NormalForm.atom_assgn σ) = igZFutT := by
      intro σ' hm
      by_contra hcon
      obtain ⟨-, hgate2⟩ := hgate
      have hfalse := hgate2 (nf0_zoneSpec (NormalForm.atom_assgn σ')) σ' hcon
      have htrue : igFoldBitFib qnf (nf0_zoneSpec (NormalForm.atom_assgn σ')) σ' = true := by
        simp only [igFoldBitFib, decide_eq_true_eq]; exact ⟨hm, trivial⟩
      rw [htrue] at hfalse
      exact absurd hfalse (by decide)
    exact hreal w hxw hwt hptWe hepL hepR (hcharFibSoundP w) hIntL hIntR hzcons sub hmark

set_option maxHeartbeats 1600000 in
-- `bracketEndChar_kvFib_step_correct` elaborates the general-`k` interior gate composition
-- together with its full provider inventory in a single declaration; the default
-- 200000-heartbeat budget is not enough to typecheck it.
/-- **De-folded k→k+1 step biconditional** (the pairing; arity-4 analog of
    `bracketEndChar_kv_step_correct`, `:1165`). `⟨sound (Phase 5), complete (Phase 4)⟩` at symbolic
    `k+1` for the SIBLING de-folded carrier, carrying the union of both halves' seams: the
    completeness
    half's render-gated arity-4 char seam `hcharFib`, and the soundness half's re-keyed provider
    obligations `hreal`/`hexcl`/`hexclExt` (gated on `igPtWFib`). Unlike the folded
    `bracketEndChar_kv_step_correct`, the completeness half consumes the render-gated `hcharFib`
    seam in
    place of the arity-1 provider bundle `P`/`hcharK` + `h_UZ`/`h_SZ` — there is no arity-4
    `interiorGate_hck`. -/
theorem bracketEndChar_kvFib_step_correct {sig : MonadicSignature} [Fintype sig.preds]
    [DecidableEq sig.preds] {k : Nat}
    (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    (charFib : (j : Nat) → NormalForm sig j 4 → Formula)
    (qnf : NormalForm sig (k + 1) 3)
    (h_xy : qnf.1 (.order ⟨1, by omega⟩ ⟨0, by omega⟩ (by decide)) = true)
    (h_yt : qnf.1 (.order ⟨0, by omega⟩ ⟨2, by omega⟩ (by decide)) = true)
    (h_xt : qnf.1 (.order ⟨1, by omega⟩ ⟨2, by omega⟩ (by decide)) = true)
    (h_yx : qnf.1 (.order ⟨0, by omega⟩ ⟨1, by omega⟩ (by decide)) = false)
    (h_ty : qnf.1 (.order ⟨2, by omega⟩ ⟨0, by omega⟩ (by decide)) = false)
    (h_tx : qnf.1 (.order ⟨2, by omega⟩ ⟨1, by omega⟩ (by decide)) = false)
    (M : OrderedMonadicStructure sig) (x t : M.carrier)
    (hcharFib : ∀ (w : M.carrier),
      nf_eval_nf M (k + 1) 3 (Fin.cons w (Fin.cons x (fun _ => t))) qnf →
      ∀ (σ : NormalForm sig k 4) (u : M.carrier),
        temporal_truth M atomMap u (charFib k σ) ↔
          nf_eval_nf M k 4 (Fin.cons u (Fin.cons w (Fin.cons x (fun _ => t)))) σ)
    (hcharFibSoundP : ∀ (w : M.carrier) (τ : NormalForm sig k 4) (x1 : M.carrier),
      temporal_truth M atomMap x1 (charFib k τ) →
      nf_eval_nf M k 4 (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t)))) τ)
    (hreal : ∀ w : M.carrier, x < w → w < t →
      (igPtWFib (nf_depth0_char_formula atomMap h_surj) (charFib k) qnf.1
          (igFoldBitFib qnf)).eval_at
        M atomMap w →
      (igEpLFib (nf_depth0_char_formula atomMap h_surj) (charFib k) qnf.1
          (igFoldBitFib qnf)).eval_at
        M atomMap x →
      (igEpRFib (nf_depth0_char_formula atomMap h_surj) (charFib k) qnf.1
          (igFoldBitFib qnf)).eval_at
        M atomMap t →
      (∀ (τ : NormalForm sig k 4) (x1 : M.carrier),
        temporal_truth M atomMap x1 (charFib k τ) →
        nf_eval_nf M k 4 (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t)))) τ) →
      (∀ σ : NormalForm sig k 4, igFoldBitFib qnf igZXW σ = true →
        ∃ x1 : M.carrier, x < x1 ∧ x1 < w ∧
          nf_eval_nf M k 4 (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t)))) σ) →
      (∀ σ : NormalForm sig k 4, igFoldBitFib qnf igZWT σ = true →
        ∃ x1 : M.carrier, w < x1 ∧ x1 < t ∧
          nf_eval_nf M k 4 (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t)))) σ) →
      (∀ σ : NormalForm sig k 4, qnf.2 σ = true →
        nf0_zoneSpec (NormalForm.atom_assgn σ) = igZPastX ∨
        nf0_zoneSpec (NormalForm.atom_assgn σ) = igZAtX ∨
        nf0_zoneSpec (NormalForm.atom_assgn σ) = igZXW ∨
        nf0_zoneSpec (NormalForm.atom_assgn σ) = igZAtW ∨
        nf0_zoneSpec (NormalForm.atom_assgn σ) = igZWT ∨
        nf0_zoneSpec (NormalForm.atom_assgn σ) = igZAtT ∨
        nf0_zoneSpec (NormalForm.atom_assgn σ) = igZFutT) →
      ∀ σ : NormalForm sig k 4, qnf.2 σ = true →
        ∃ x1 : M.carrier,
          nf_eval_nf M k 4 (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t)))) σ)
    (hexcl : ∀ w : M.carrier, x < w → w < t →
      (igPtWFib (nf_depth0_char_formula atomMap h_surj) (charFib k) qnf.1
          (igFoldBitFib qnf)).eval_at
        M atomMap w →
      ∀ σ : NormalForm sig k 4, qnf.2 σ = false →
        ∀ x1 : M.carrier, x ≤ x1 → x1 ≤ t →
          ¬ nf_eval_nf M k 4 (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t)))) σ)
    (hexclExt : ∀ w : M.carrier, x < w → w < t →
      (igPtWFib (nf_depth0_char_formula atomMap h_surj) (charFib k) qnf.1
          (igFoldBitFib qnf)).eval_at
        M atomMap w →
      ∀ σ : NormalForm sig k 4, qnf.2 σ = false →
        ∀ x1 : M.carrier, ¬ (x ≤ x1 ∧ x1 ≤ t) →
          ¬ nf_eval_nf M k 4 (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t)))) σ) :
    (bracketEndChar_kvFib atomMap h_surj charFib (k + 1) qnf).holds M atomMap x t ↔
      ∃ w : M.carrier, nf_eval_nf M (k + 1) 3 (Fin.cons w (Fin.cons x (fun _ => t))) qnf :=
  ⟨bracketEndChar_kvFib_step_sound atomMap h_surj charFib qnf
      h_xy h_yt h_xt h_yx h_ty h_tx M x t hcharFibSoundP hreal hexcl hexclExt,
    bracketEndChar_kvFib_step_complete atomMap h_surj charFib qnf h_xy h_yt M x t hcharFib⟩

end

end Bimodal.Metalogic.WeakCanonical.Kamp
