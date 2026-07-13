import Bimodal.Metalogic.WeakCanonical.Kamp.NfMultiAnchorBridge.InteriorGateGeneralK
import Bimodal.Metalogic.WeakCanonical.Kamp.NfMultiAnchorBridge.ExteriorBracketAssembleK

/-! # General-`k` `hexclExt` exterior-adjacency discharge (task 356)

The general-`k` mirror of the landed k=2 discharge `bracketEndChar_kvE2Ext_correct_two_prior_frag`
(`ExteriorBracket.lean:1069`), one fold-layer deeper. It composes the general-`k` interior carrier
`bracketEndChar_kv` at depth `(k+2)` with the two adjacent exterior brackets
`kvE_extBracketPast` / `kvE_extBracketFut` (`ExteriorBracketAssembleK.lean`) via `enrichEndpoints`
(the degenerate Rabinovich Lemma 7.6 p.14 adjacency at the shared free anchors `x, t`), discharging
the `hexclExt` obligation that task 355's interior gate `bracketEndChar_kv_step_sound`
(`InteriorGateGeneralK.lean:1043`) carries outward.

This is a purely additive leaf. Every composition input is landed sorry-free:
- `bracketEndChar_kv_step_sound` / `bracketEndChar_kv_step_complete` (`InteriorGateGeneralK.lean`);
- `kvE_extBracketPast_sound` / `kvE_extBracketFut_sound` (D1/D2, AssembleK) — the `hexclExt`
  discharge kernel;
- `kvE_extBracketPast_complete` / `kvE_extBracketFut_complete` (D3/D4, AssembleK) — the ⇐
  re-establishment;
- `kvE_futBundle_of_realizer` / `kvE_pastBundle_of_realizer` (`ExteriorConverter{,Past}K.lean`) —
  the `hreal`/`hsat` discharge templates;
- `VVecEA2.enrichEndpoints` / `_holds` (`ExteriorBracket.lean:623/632`) — reused verbatim (generic
  over `VVecEA2`).

## Deliverables

1. `bracketEndChar_kvExt` — the general-`k` enriched composed gate (def);
2. `bracketEndChar_kvExt_holds_iff` — the anchor-semantics bridge (one-line reuse of
   `enrichEndpoints_holds`);
3. `bracketEndChar_kvExt_correct_prior` — the DoD `hexclExt` discharge lemma: the enriched-gate
   biconditional carrying only `P`, `hcharK`, `Pbr`, `h_UZ`, `h_SZ`, `hreal`, `hexcl` (+ order
   bits), with `hexclExt` discharged internally.

**Scope fence (task 356 only)**: KampPrior.lean:351 wiring, aggregator import threading, and the
site-certificate reshape are task 357. `hreal`/`hexcl` remain threaded (discharged by the KampPrior
provider instantiation). No interior-gate mathematics (task 355). -/

namespace Bimodal.Metalogic.WeakCanonical.Kamp

open Bimodal.Syntax
open Bimodal.Metalogic.WeakCanonical

/-! ## The general-`k` enriched composed gate (degenerate Lemma 7.6 p.14 at the anchors `x, t`) -/

/-- **The general-`k` enriched composed gate** (task 356; Def 7.5 p.13 + degenerate Lemma 7.6 p.14):
    the general-`k` interior carrier `bracketEndChar_kv … (k+2)` with the past-side adjacent bracket
    `kvE_extBracketPast Pbr` conjoined at the LEFT anchor `x` and the future-side adjacent bracket
    `kvE_extBracketFut Pbr` conjoined at the RIGHT anchor `t`, via `enrichEndpoints`. General-`k`
    mirror of `bracketEndChar_kvE2Ext` (`ExteriorBracket.lean:661`), one fold deeper. -/
noncomputable def bracketEndChar_kvExt {sig : MonadicSignature} {k : Nat}
    (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    (charF : (j : Nat) → NormalForm sig j 1 → Formula)
    (Pbr : ExistProviders sig atomMap k) :
    BracketEndCharCarrierV sig (k + 2) :=
  fun qnf =>
    (bracketEndChar_kv atomMap h_surj charF (k + 2) qnf).enrichEndpoints
      (kvE_extBracketPast Pbr qnf)
      (kvE_extBracketFut Pbr qnf)

/-- **Anchor-semantics bridge for the general-`k` enriched gate** (the degenerate Lemma 7.6
    conjunction, exposed): the enriched gate holds at `(x, t)` iff the interior gate holds AND the
    past bracket is true at `x` AND the future bracket is true at `t`. One-line reuse of
    `VVecEA2.enrichEndpoints_holds`. Mirror of `bracketEndChar_kvE2Ext_holds_iff`
    (`ExteriorBracket.lean:674`). -/
theorem bracketEndChar_kvExt_holds_iff {sig : MonadicSignature} {k : Nat}
    (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    (charF : (j : Nat) → NormalForm sig j 1 → Formula)
    (Pbr : ExistProviders sig atomMap k)
    (qnf : NormalForm sig (k + 2) 3)
    (M : OrderedMonadicStructure sig) (x t : M.carrier) :
    (bracketEndChar_kvExt atomMap h_surj charF Pbr qnf).holds M atomMap x t ↔
      ((bracketEndChar_kv atomMap h_surj charF (k + 2) qnf).holds M atomMap x t ∧
       temporal_truth M atomMap x (kvE_extBracketPast Pbr qnf) ∧
       temporal_truth M atomMap t (kvE_extBracketFut Pbr qnf)) :=
  VVecEA2.enrichEndpoints_holds M atomMap _ _ _ x t

end Bimodal.Metalogic.WeakCanonical.Kamp
