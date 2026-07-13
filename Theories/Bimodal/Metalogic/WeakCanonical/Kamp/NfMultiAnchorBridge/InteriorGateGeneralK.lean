import Bimodal.Metalogic.WeakCanonical.Kamp.NfMultiAnchorBridge.PriorInterface
import Bimodal.Metalogic.WeakCanonical.Kamp.NfMultiAnchorBridge.OuterGate

/-!
# General-`k` INTERIOR gate correctness (task 355)

A NEW **leaf sibling** of `PriorInterface.lean` / `OuterGate.lean` inside `NfMultiAnchorBridge/`.
It is **purely additive**: nothing here re-proves or edits the task-349 frozen carrier
`bracketEndChar_kv` (`CarrierKv.lean:238`), the provider interface `ExistProviders` /
`BracketCarrierCorrectVPrior` (`PriorInterface.lean:38/60`), or the k=2 template family in
`OuterGate.lean`. Those are treated as verified INPUTS; this file only *applies* them.

## What this file delivers (task 355)

The general-`k` interior gate correctness lemma `bracketEndChar_kv_correct_prior`, provider-guarded,
sorry-free, and axiom-clean, so task 349 Phase 5 can fill the `endIntervalStep` body
(`CarrierK1V.lean:2144`) and Phases 6-7 can induct on it.

## CRITICAL — the general-`k` statement is PROVIDER-GUARDED, not unconditional (finding F1)

`bracketEndChar_kv_factors` (`CarrierKv.lean:422`) proves the depth-`k` carrier factors through ONLY
the atom layer + the off-fiber Prop + the fiber-EXISTENTIAL fold bits: two quant layers agreeing on
that data yield EQUAL carriers even when they disagree on the marking of individual depth-`k` arity-4
subs inside a shared `(zoneSpec, projFresh)` fiber. That machine-checks the ISOLATION half of F1 —
the UNCONDITIONAL k ≥ 2 soundness direction is REFUTED (a lossy carrier cannot recover which marked
sub realized a fiber). Therefore the deliverable is the **provider-guarded** shape: the target
predicate is `BracketCarrierCorrectVPrior` (`PriorInterface.lean:60`) — the UZ/SZ-relativized,
provider-conditional variant — mirroring the k=2 template `bracketEndChar_kvE2_sound_two_prior_frag`
(`OuterGate.lean:268`) / `bracketEndChar_kvE2_complete_two_prior` (`OuterGate.lean:147`) and the
consumer's `EndIntervalCorrectPrior` (task 349 Phase 5). An unconditional general-`k` statement is a
known dead end (F1) and MUST NOT be pursued.

## Recursion structure

- **Base k = 0 / k = 1** (delivered upstream, CONSUMED not rebuilt): the target predicate is
  discharged by `bracketEndChar_kv_correct_zero_prior` (`PriorInterface.lean:80`) and
  `bracketEndChar_kv_correct_one_prior` (`PriorInterface.lean:95`). Phase 1 (this file) validates the
  FREEZE by re-deriving those two base rungs against the frozen `InteriorGateTarget` Prop.
- **Step k → k + 1** (the substantial construction, Phases 2-5): provider/char truth bridges, the
  `holds_iff` destructuring of the successor carrier, the ⇐ completeness half, and the F1-critical ⇒
  soundness half (provider obligations reconstruct the lost fiber content).
- **General-`k` close** (Phase 6): `Nat`-induction assembling the base rungs and the step gate.
-/

namespace Bimodal.Metalogic.WeakCanonical.Kamp

open Bimodal.Syntax
open Bimodal.Metalogic.WeakCanonical
open Bimodal.Metalogic.WeakCanonical.Separation (nf_depth0_char_formula)

/-! ## Phase 1 — frozen general-`k` statement + base-rung reconciliation

`InteriorGateTarget` freezes the provider-guarded deliverable shape: the target predicate is the
UZ/SZ-relativized `BracketCarrierCorrectVPrior` (`PriorInterface.lean:60`) applied to the depth-`k`
carrier `bracketEndChar_kv`. This is the byte-quotable conclusion the consumer (task 349 Phase 5
`endIntervalStep` / `EndIntervalCorrectPrior`) consumes, and the conclusion the k=2 template
`bracketEndChar_kvE2_correct_two_prior_frag` (`OuterGate.lean:359`) already delivers at `k = 2` under
its fragment/provider binders. Freezing it as a `def` (not a `theorem`) records the target without a
proof obligation; the `∀ k` theorem is assembled in Phase 6.

The base-rung reconciliation lemmas below VALIDATE the freeze (Risk R1 mitigation): the k = 0 and
k = 1 instances of the frozen `InteriorGateTarget` discharge cleanly from the landed base rungs
`bracketEndChar_kv_correct_zero_prior` / `_one_prior`, confirming the frozen predicate is the correct
provider-guarded shape BEFORE any step proof is attempted. -/

/-- **Frozen general-`k` interior-gate target predicate** (task 355 Phase 1). The provider-guarded
    deliverable shape: `BracketCarrierCorrectVPrior atomMap (bracketEndChar_kv atomMap h_surj charF k)`
    — the UZ/SZ-relativized carrier correctness at the FIXED anchor pair `(x, t)`
    (`PriorInterface.lean:60`). Frozen per finding F1 (see the file header): the UNCONDITIONAL k ≥ 2
    variant is refuted by `bracketEndChar_kv_factors` (`CarrierKv.lean:422`), so the deliverable is
    the provider-conditional predicate, mirroring the k=2 template's `_two_prior` shape and the task
    349 Phase 5 consumer `EndIntervalCorrectPrior`. -/
def InteriorGateTarget {sig : MonadicSignature}
    (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    (charF : (j : Nat) → NormalForm sig j 1 → Formula)
    (k : Nat) : Prop :=
  BracketCarrierCorrectVPrior atomMap (bracketEndChar_kv atomMap h_surj charF k)

/-- **Base-rung reconciliation, k = 0** (task 355 Phase 1 — freeze validation). The k = 0 instance
    of the frozen `InteriorGateTarget` is discharged by the landed base rung
    `bracketEndChar_kv_correct_zero_prior` (`PriorInterface.lean:80`) verbatim. This confirms the
    frozen provider-guarded predicate weakens cleanly to the unconditional depth-0 base (the k = 0
    provider obligations are vacuously satisfiable). No chain step is shortcut (G5): pure
    consumption. -/
theorem interiorGateTarget_zero {sig : MonadicSignature}
    (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    (charF : (j : Nat) → NormalForm sig j 1 → Formula) :
    InteriorGateTarget atomMap h_surj charF 0 :=
  bracketEndChar_kv_correct_zero_prior atomMap h_surj charF

/-- **Base-rung reconciliation, k = 1** (task 355 Phase 1 — freeze validation). The k = 1 instance
    of the frozen `InteriorGateTarget`, under the depth-0 provider agreement `h0` (satisfied by the
    Phase-14 instantiation by construction, `KampPrior:397` at depth 0), is discharged by the landed
    base rung `bracketEndChar_kv_correct_one_prior` (`PriorInterface.lean:95`) verbatim. This
    confirms the frozen provider-guarded predicate weakens cleanly to the first successor base rung.
    No chain step is shortcut (G5): pure consumption. -/
theorem interiorGateTarget_one {sig : MonadicSignature}
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
`P.existF 0` to an arbitrary-depth `P : ExistProviders sig atomMap k` via the `ExistProviders.correct`
field at `n = 0` and the `insertEnv`/`Fin.elim0` env collapse (`insertEnv` on the empty env is
`fun _ => u`). Manual bridge only — no simp/omega/aesop shortcut of a Rabinovich chain step (G5); the
`insertEnv` collapse is pure `Fin 0` bookkeeping, not a fold step. -/

/-- **Depth-`k` provider-layer truth bridge** (task 355 Phase 2; general-`k` analog of
    `bracketEndChar_kvE2_hck`, `OuterGate.lean:123`). For a depth-`k` provider bundle
    `P : ExistProviders sig atomMap k`, the depth-`k` existential provider formula `P.existF 0 χ` is
    truth-equivalent to the arity-1 depth-`k` evaluation, via `ExistProviders.correct` at `n = 0` and
    the `Fin 0 → M.carrier` env collapse. This is the per-fiber point-type truth equivalence the step
    proof (Phases 4-5) consumes at the endpoint/pivot `charK` literals. -/
theorem interiorGate_hck {sig : MonadicSignature} {k : Nat}
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

/-- **Depth-0 char-base truth bridge** (task 355 Phase 2; re-export of the depth-0-general
    `bracketEndChar_kvE2_hcb`, `OuterGate.lean:102`). The standard-instantiation depth-0
    characteristic formula is truth-equivalent to the arity-1 depth-0 evaluation. Depth-0 and
    fold-depth-independent, so it is the SAME bridge at every `k` — named here for the step proof's
    endpoint/witness base types (`xType`/`tType`/`ptW`, the depth-0 atom-layer projections). -/
theorem interiorGate_hcb {sig : MonadicSignature}
    (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    (M : OrderedMonadicStructure sig) (χ : NormalForm sig 0 1) (u : M.carrier) :
    temporal_truth M atomMap u (nf_depth0_char_formula atomMap h_surj χ) ↔
      nf_eval_nf M 0 1 (fun _ => u) χ :=
  bracketEndChar_kvE2_hcb atomMap h_surj M χ u

end Bimodal.Metalogic.WeakCanonical.Kamp
