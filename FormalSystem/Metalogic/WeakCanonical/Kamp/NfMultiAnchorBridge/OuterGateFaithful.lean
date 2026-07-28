/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Metalogic.WeakCanonical.Kamp.NfMultiAnchorBridge.OuterGate
import FormalSystem.Metalogic.WeakCanonical.Kamp.NfMultiAnchorBridge.PriorInterfaceFaithful

/-!
# The k = 2 outer gate at the faithful eq (5.2) carrier

`OuterGate.lean` states the k = 2 outer gate against `SemanticPriorUZ` / `SemanticPriorSZ`. This
module restates it against `HasFaithfulDedekindINF` / `HasFaithfulDedekindSUP`
(`Kamp/KPlusFaithful.lean:320`, `:339`), consuming `PriorInterfaceFaithful.lean`'s
`ExistProvidersFaithful` in place of `ExistProviders`.

`OuterGate.lean` sits on `SharedWitness.lean`, which mentions no completeness carrier at all, so —
together with `PriorInterface.lean` — it is one of the two roots of the `NfMultiAnchorBridge`
UZ/SZ subgraph. `ExteriorBracket.lean` imports it directly and the `ExteriorBracketK` /
`ExteriorFiberK` / `InteriorGateGeneralK` layer sits above that.

## Where the carrier is actually consumed, as measured

`OuterGate.lean` has three `SemanticPriorUZ`/`SemanticPriorSZ` binder sites (`:135`, `:168`,
`:406`). All three route to a single leaf: `ExistProviders.correct` inside
`bracketEndChar_kvE2_hck` (`:138`). The other two thread. So the re-base below is one redirected
step — `ExistProvidersFaithful.correct` in place of `ExistProviders.correct` — plus restatement.

**A finding worth recording**: the ⇒ half, `bracketEndChar_kvE2_sound_two_prior_frag` (`:297`), is
*already carrier-free*. Despite the `_prior` in its name it binds no `SemanticPriorUZ` at all — the
fragment restriction `hfrag` and the four provider obligations `hrealI`/`hrealB`/`hexcl`/`hexclExt`
carry the whole ⇒ direction, and the provider enters only through `P.existF 0`. It therefore needs
**no faithful sibling**: `bracketEndChar_kvE2_correct_two_prior_frag_faithful` below reuses it
verbatim at `P.toExistProviders`, whose `existF` field is definitionally `P.existF`. Only the ⇐
half was ever carrier-conditional. Recorded so a later dispatch does not manufacture a sibling for
it, and so the re-base's true cost at this rung is on record as one lemma, not three.

## Nothing is removed and nothing is renamed

Every declaration of `OuterGate.lean` stands byte-identical; this module only adds faithful
siblings. The `KvE2SepFragment` predicate and the carrier `bracketEndCharKvE2` are *reused*, not
duplicated: neither mentions a completeness carrier, and `bracketEndCharKvE2` depends on its
provider bundle only through `existF`.

## Source status of this module

**The re-basing itself has no source**, exactly as at `PriorInterfaceFaithful.lean`: Rabinovich
draws no distinction between the attained first-occurrence property and the eq (5.2) dichotomy
(PDF p.8), so the choice of carrier is this tree's own. The statements ride their originals'
citations — Cor 5.4 clause (v) and its ⇐ direction (PDF p.9) for the gate and the bounded interior
witnesses, Prop 4.3 re-flatten / Lemma 7.6 adjacency for the exterior residue hand-off, and Lemma
3.2(2) (PDF p.4) plus the §5 bracket notation (PDF p.7) for the two-fixed-endpoint framing.
-/

namespace FormalSystem.Metalogic.WeakCanonical.Kamp

open FormalSystem.Syntax
open FormalSystem.Metalogic.WeakCanonical
open FormalSystem.Metalogic.WeakCanonical.Separation
  (nfDepth0CharFormula nf_depth0_char_formula_correct
   formulaConjList formula_conjList_iff)

/-- **⇐ completeness bridge for the provider layer, at the faithful carrier** — the faithful
sibling of `bracketEndChar_kvE2_hck` (`OuterGate.lean:131`), and the one place in this module where
the carrier is consumed rather than threaded.

The original's proof body verbatim, with its single carrier-consuming step
`P.correct 0 χ M h_UZ h_SZ u` redirected to `ExistProvidersFaithful.correct`, which takes
`HasFaithfulDedekindINF` / `HasFaithfulDedekindSUP` instead. The `Fin 0 → M.carrier` env collapse
(`insertEnv` on the empty env is `fun _ => u`) is unchanged. -/
theorem bracketEndChar_kvE2_hck_faithful {sig : MonadicSignature} [Fintype sig.preds]
    [DecidableEq sig.preds]
    (atomMap : Formula → sig.preds)
    (P : ExistProvidersFaithful sig atomMap 1)
    (M : OrderedMonadicStructure sig)
    (h_INF : HasFaithfulDedekindINF M atomMap) (h_SUP : HasFaithfulDedekindSUP M atomMap)
    (χ : NormalForm sig 1 1) (u : M.carrier) :
    TemporalTruth M atomMap u (P.existF 0 χ) ↔ NfEvalNf M 1 1 (fun _ => u) χ := by
  rw [P.correct 0 χ M h_INF h_SUP u]
  constructor
  · rintro ⟨env, henv⟩
    have heq : insertEnv env u = (fun _ => u) := by
      funext i
      simp only [insertEnv]
      rw [dif_neg (by omega)]
    rwa [heq] at henv
  · intro h
    exact ⟨Fin.elim0, by rw [insertEnv_zero]; exact h⟩

/-- **⇐ completeness half of the k=2 gate, at the faithful carrier** — the faithful sibling of
`bracketEndChar_kvE2_complete_two_prior` (`OuterGate.lean:155`).

The original's proof body verbatim: the bracket-range recovery of `x < w < t` from `qnf`'s own atom
layer is unchanged (bracket range, NOT a chain), the landed honest-gate lemma
`kvE2_sepGate_holds_of_honest` and completeness engine `kvE2_sepBody_holds_of_honest` are consumed
unchanged, and only the provider-layer bridge is redirected to
`bracketEndChar_kvE2_hck_faithful`. The carrier is taken at `P.toExistProviders`, whose `existF`
field is definitionally `P.existF`, so the formula produced is literally the original's. -/
theorem bracketEndChar_kvE2_complete_two_prior_faithful {sig : MonadicSignature}
    [Fintype sig.preds] [DecidableEq sig.preds]
    (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    (P : ExistProvidersFaithful sig atomMap 1)
    (qnf : NormalForm sig 2 3)
    (h_xy : qnf.atomAssgn (.order ⟨1, by omega⟩ ⟨0, by omega⟩ (by decide)) = true)
    (h_yt : qnf.atomAssgn (.order ⟨0, by omega⟩ ⟨2, by omega⟩ (by decide)) = true)
    (_h_xt : qnf.atomAssgn (.order ⟨1, by omega⟩ ⟨2, by omega⟩ (by decide)) = true)
    (_h_yx : qnf.atomAssgn (.order ⟨0, by omega⟩ ⟨1, by omega⟩ (by decide)) = false)
    (_h_ty : qnf.atomAssgn (.order ⟨2, by omega⟩ ⟨0, by omega⟩ (by decide)) = false)
    (_h_tx : qnf.atomAssgn (.order ⟨2, by omega⟩ ⟨1, by omega⟩ (by decide)) = false)
    (M : OrderedMonadicStructure sig)
    (h_INF : HasFaithfulDedekindINF M atomMap) (h_SUP : HasFaithfulDedekindSUP M atomMap)
    (x t : M.carrier) :
    (∃ w : M.carrier, NfEvalNf M 2 3 (Fin.cons w (Fin.cons x (fun _ => t))) qnf) →
      (bracketEndCharKvE2 atomMap h_surj P.toExistProviders qnf).holds M atomMap x t := by
  rintro ⟨w, h⟩
  have hxw : x < w := by
    have := (h.1 (.order ⟨1, by omega⟩ ⟨0, by omega⟩ (by decide))).mpr h_xy
    exact this
  have hwt : w < t := by
    have := (h.1 (.order ⟨0, by omega⟩ ⟨2, by omega⟩ (by decide))).mpr h_yt
    exact this
  have hg : KvE2SepGate qnf := kvE2_sepGate_holds_of_honest qnf M w x t hxw hwt h
  rw [bracketEndChar_kvE2_two_eq]
  exact kvE2_sepBody_holds_of_honest (nfDepth0CharFormula atomMap h_surj)
    (fun χ => P.existF 0 χ) qnf hg M atomMap w x t hxw hwt h
    (fun χ u => bracketEndChar_kvE2_hcb atomMap h_surj M χ u)
    (fun χ u => bracketEndChar_kvE2_hck_faithful atomMap P M h_INF h_SUP χ u)

/-- **Assembled k=2 interior+boundary gate, at the faithful carrier** — the faithful sibling of
`bracketEndChar_kvE2_correct_two_prior_frag` (`OuterGate.lean:393`), and the declaration
`ExteriorBracket.lean`'s rung consumes.

Same assembly as the original: ⇒ is the Phase-B/D soundness half over the pin-anchored fold, ⇐ is
the completeness half. The ⇒ half is `bracketEndChar_kvE2_sound_two_prior_frag` **reused verbatim**
— it binds no completeness carrier at all (see this module's header), so it needs no faithful
sibling and is applied here at `P.toExistProviders`. Only the ⇐ half is redirected, to
`bracketEndChar_kvE2_complete_two_prior_faithful`.

The four provider obligations `hrealI` / `hrealB` / `hexcl` / `hexclExt` keep their landed shapes
character-for-character, including the interval bound `x < x1 < t` on the interior index only
(Rabinovich Cor 5.4 ⇐, PDF p.9) and the outward-threaded exterior residue (Prop 4.3 re-flatten /
Lemma 7.6 adjacency, never discharged on this bracket). -/
theorem bracketEndChar_kvE2_correct_two_prior_frag_faithful {sig : MonadicSignature}
    [Fintype sig.preds] [DecidableEq sig.preds]
    (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    (P : ExistProvidersFaithful sig atomMap 1)
    (qnf : NormalForm sig 2 3)
    (h_xy : qnf.atomAssgn (.order ⟨1, by omega⟩ ⟨0, by omega⟩ (by decide)) = true)
    (h_yt : qnf.atomAssgn (.order ⟨0, by omega⟩ ⟨2, by omega⟩ (by decide)) = true)
    (h_xt : qnf.atomAssgn (.order ⟨1, by omega⟩ ⟨2, by omega⟩ (by decide)) = true)
    (h_yx : qnf.atomAssgn (.order ⟨0, by omega⟩ ⟨1, by omega⟩ (by decide)) = false)
    (h_ty : qnf.atomAssgn (.order ⟨2, by omega⟩ ⟨0, by omega⟩ (by decide)) = false)
    (h_tx : qnf.atomAssgn (.order ⟨2, by omega⟩ ⟨1, by omega⟩ (by decide)) = false)
    (M : OrderedMonadicStructure sig)
    (h_INF : HasFaithfulDedekindINF M atomMap) (h_SUP : HasFaithfulDedekindSUP M atomMap)
    (x t : M.carrier)
    (hfrag : KvE2SepFragment qnf)
    (hrealI : ∀ w : M.carrier, x < w → w < t →
      (kvE2SepPtW (nfDepth0CharFormula atomMap h_surj) (fun χ => P.existF 0 χ) qnf).EvalAt
        M atomMap w →
      ∀ σ ∈ kvE2SepPosI qnf,
        ∃ x1 : M.carrier, (x < x1 ∧ x1 < t) ∧
          NfEvalNf M 1 4 (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t)))) σ)
    (hrealB : ∀ w : M.carrier, x < w → w < t →
      (kvE2SepPtW (nfDepth0CharFormula atomMap h_surj) (fun χ => P.existF 0 χ) qnf).EvalAt
        M atomMap w →
      ∀ σ ∈ kvE2SepPos qnf,
        ¬ (nf0ZoneSpec σ.1 = kvE2SepZXW3 ∨ nf0ZoneSpec σ.1 = kvE2SepZWT3) →
        ∃ x1 : M.carrier,
          NfEvalNf M 1 4 (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t)))) σ)
    (hexcl : ∀ w : M.carrier, x < w → w < t →
      (kvE2SepPtW (nfDepth0CharFormula atomMap h_surj) (fun χ => P.existF 0 χ) qnf).EvalAt
        M atomMap w →
      ∀ σ : NormalForm sig 1 4, qnf.2 σ = false →
        ∀ x1 : M.carrier, x ≤ x1 → x1 ≤ t →
          ¬ NfEvalNf M 1 4 (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t)))) σ)
    (hexclExt : ∀ w : M.carrier, x < w → w < t →
      (kvE2SepPtW (nfDepth0CharFormula atomMap h_surj) (fun χ => P.existF 0 χ) qnf).EvalAt
        M atomMap w →
      ∀ σ : NormalForm sig 1 4, qnf.2 σ = false →
        ¬ (nf0ZoneSpec σ.1 = kvE2SepZXW3 ∨ nf0ZoneSpec σ.1 = kvE2SepZWT3) →
        ∀ x1 : M.carrier, ¬ (x ≤ x1 ∧ x1 ≤ t) →
          ¬ NfEvalNf M 1 4 (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t)))) σ) :
    (bracketEndCharKvE2 atomMap h_surj P.toExistProviders qnf).holds M atomMap x t ↔
      ∃ w : M.carrier, NfEvalNf M 2 3 (Fin.cons w (Fin.cons x (fun _ => t))) qnf := by
  constructor
  · exact bracketEndChar_kvE2_sound_two_prior_frag atomMap h_surj P.toExistProviders qnf
      h_xy h_yt h_xt h_yx h_ty h_tx M x t hfrag hrealI hrealB hexcl hexclExt
  · exact bracketEndChar_kvE2_complete_two_prior_faithful atomMap h_surj P qnf
      h_xy h_yt h_xt h_yx h_ty h_tx M h_INF h_SUP x t

/-- **The faithful k=2 gate re-supplies the UZ/SZ one.** The D11 coverage record for this rung,
matching `ExistProvidersFaithful.toExistProviders`: a consumer arriving with
`SemanticPriorUZ`/`SemanticPriorSZ` and a faithful provider bundle is served by the faithful gate,
through `prior_hasAttainedINF` / `prior_hasAttainedSUP` and the `toHasFaithfulDedekind*` shims.
`bracketEndChar_kvE2_correct_two_prior_frag` itself is left untouched. There is no converse. -/
theorem bracketEndChar_kvE2_correct_two_prior_frag_faithful_covers_prior
    {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds]
    (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    (P : ExistProvidersFaithful sig atomMap 1)
    (qnf : NormalForm sig 2 3)
    (h_xy : qnf.atomAssgn (.order ⟨1, by omega⟩ ⟨0, by omega⟩ (by decide)) = true)
    (h_yt : qnf.atomAssgn (.order ⟨0, by omega⟩ ⟨2, by omega⟩ (by decide)) = true)
    (h_xt : qnf.atomAssgn (.order ⟨1, by omega⟩ ⟨2, by omega⟩ (by decide)) = true)
    (h_yx : qnf.atomAssgn (.order ⟨0, by omega⟩ ⟨1, by omega⟩ (by decide)) = false)
    (h_ty : qnf.atomAssgn (.order ⟨2, by omega⟩ ⟨0, by omega⟩ (by decide)) = false)
    (h_tx : qnf.atomAssgn (.order ⟨2, by omega⟩ ⟨1, by omega⟩ (by decide)) = false)
    (M : OrderedMonadicStructure sig)
    (h_UZ : SemanticPriorUZ M atomMap) (h_SZ : SemanticPriorSZ M atomMap)
    (x t : M.carrier)
    (hfrag : KvE2SepFragment qnf)
    (hrealI : ∀ w : M.carrier, x < w → w < t →
      (kvE2SepPtW (nfDepth0CharFormula atomMap h_surj) (fun χ => P.existF 0 χ) qnf).EvalAt
        M atomMap w →
      ∀ σ ∈ kvE2SepPosI qnf,
        ∃ x1 : M.carrier, (x < x1 ∧ x1 < t) ∧
          NfEvalNf M 1 4 (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t)))) σ)
    (hrealB : ∀ w : M.carrier, x < w → w < t →
      (kvE2SepPtW (nfDepth0CharFormula atomMap h_surj) (fun χ => P.existF 0 χ) qnf).EvalAt
        M atomMap w →
      ∀ σ ∈ kvE2SepPos qnf,
        ¬ (nf0ZoneSpec σ.1 = kvE2SepZXW3 ∨ nf0ZoneSpec σ.1 = kvE2SepZWT3) →
        ∃ x1 : M.carrier,
          NfEvalNf M 1 4 (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t)))) σ)
    (hexcl : ∀ w : M.carrier, x < w → w < t →
      (kvE2SepPtW (nfDepth0CharFormula atomMap h_surj) (fun χ => P.existF 0 χ) qnf).EvalAt
        M atomMap w →
      ∀ σ : NormalForm sig 1 4, qnf.2 σ = false →
        ∀ x1 : M.carrier, x ≤ x1 → x1 ≤ t →
          ¬ NfEvalNf M 1 4 (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t)))) σ)
    (hexclExt : ∀ w : M.carrier, x < w → w < t →
      (kvE2SepPtW (nfDepth0CharFormula atomMap h_surj) (fun χ => P.existF 0 χ) qnf).EvalAt
        M atomMap w →
      ∀ σ : NormalForm sig 1 4, qnf.2 σ = false →
        ¬ (nf0ZoneSpec σ.1 = kvE2SepZXW3 ∨ nf0ZoneSpec σ.1 = kvE2SepZWT3) →
        ∀ x1 : M.carrier, ¬ (x ≤ x1 ∧ x1 ≤ t) →
          ¬ NfEvalNf M 1 4 (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t)))) σ) :
    (bracketEndCharKvE2 atomMap h_surj P.toExistProviders qnf).holds M atomMap x t ↔
      ∃ w : M.carrier, NfEvalNf M 2 3 (Fin.cons w (Fin.cons x (fun _ => t))) qnf :=
  bracketEndChar_kvE2_correct_two_prior_frag_faithful atomMap h_surj P qnf
    h_xy h_yt h_xt h_yx h_ty h_tx M
    (prior_hasAttainedINF M atomMap h_UZ).toHasFaithfulDedekindINF
    (prior_hasAttainedSUP M atomMap h_SZ).toHasFaithfulDedekindSUP
    x t hfrag hrealI hrealB hexcl hexclExt

end FormalSystem.Metalogic.WeakCanonical.Kamp
