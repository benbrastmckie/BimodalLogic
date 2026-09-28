/-
Probe 01 for the agreement lemma over all walks.

Question: on the branching frame `SharingWitnessFamily.frame`, does the STABILITY-modal
history quantifier -- "over every history through the present world state" -- collapse to a
FINITE quantifier over the `share`-class of the present index?

If it does, the `stab` case of an L-plus-indexed agreement lemma needs no walk quantifier at
all, and the corresponding certificate condition (C5) is decidable by the same window
reduction that already decides (C0) `AtomCoherent`.

Everything below is stated at the EXISTING `Formula`-indexed device: the stability modal's
*quantifier shape* is expressible there even though the modal itself is not, because the
quantifier is a statement about histories, not about a constructor.
-/

import FormalSystem.Metalogic.Decidability.WitnessFamily.Sharing.Agreement

namespace FormalSystem.Metalogic.Decidability

open FormalSystem.Syntax FormalSystem.Semantics

namespace SharingWitnessFamily

variable {Γ Del : Context}

/--
**The stability quantifier, at the branching frame, over a closure formula.**

`StabQuant S hat σ t ψ` is the semantic content of `⊡ψ` at `(σ, t)`: truth of `ψ` at every
world history agreeing with `σ` on the world state at time `t`. This is `PlusTruthAt`'s `stab`
clause with `PlusFormula` replaced by `Formula`, which is legitimate because the clause never
inspects the formula.
-/
def StabQuant (S : SharingWitnessFamily Γ Del) (hat : S.AtomCoherent)
    (σ : WorldHistory S.frame.toTaskFrame) (t : ℤ) (ψ : Formula) : Prop :=
  ∀ ρ : WorldHistory S.frame.toTaskFrame, σ.state t = ρ.state t →
    TruthAt (S.model hat) ρ t ψ

/--
**The collapse.**

At a thread's trace, the stability quantifier over a closure formula is exactly the finite
conjunction of label membership over the `share`-class of the thread's index at that time.

* `→` instantiates the history quantifier at the CONSTANT thread at each class member, which is
  a history by `Thread.const` + `hist`, and reads truth back as membership by **T1**.
* `←` decomposes an arbitrary history by `total_eq_thread`, extracts `share` from the state
  equality by `share_of_cls_eq`, and reads membership forward as truth by **T1**.

No quantifier over walks survives: the right-hand side ranges over `Fin S.lassos.length`.
-/
theorem stabQuant_iff_share_class (S : SharingWitnessFamily Γ Del)
    (hat : S.AtomCoherent) (hloc : S.LocalCoherentShare) (hful : S.ThreadFulfilling)
    (hbox : S.toWitnessFamily.BoxFaithful)
    (ψ : Formula) (hψ : ψ ∈ closureOf (Γ ++ Del)) (θ : S.Thread) (s t : ℤ) :
    StabQuant S hat (S.hist θ s) t ψ ↔
      ∀ j : Fin S.lassos.length, S.share (s + t) (θ.idx (s + t)) j → ψ ∈ S.L j (s + t) := by
  constructor
  · intro h j hj
    have hst : (S.hist θ s).state t = (S.hist (Thread.const S j) s).state t := by
      show S.cls (θ.idx (s + t)) (s + t) = S.cls ((Thread.const S j).idx (s + t)) (s + t)
      rw [Thread.const_idx]
      exact cls_eq rfl hj
    have := h _ hst
    have hT := (truth_iff_mem S hat hloc hful hbox ψ hψ (Thread.const S j) s t).mp this
    rwa [Thread.const_idx] at hT
  · intro h ρ hρ
    obtain ⟨θ', s', hθ'⟩ := S.total_eq_thread ρ
    have heq : ρ = S.hist θ' s' := WorldHistory.ext_state (fun r => by rw [hθ' r]; rfl)
    subst heq
    have hstate : S.cls (θ.idx (s + t)) (s + t) = S.cls (θ'.idx (s' + t)) (s' + t) := hρ
    obtain ⟨htime, hshare⟩ := share_of_cls_eq hstate
    refine (truth_iff_mem S hat hloc hful hbox ψ hψ θ' s' t).mpr ?_
    have hmem := h _ hshare
    rwa [show s + t = s' + t from by omega] at hmem

/--
**The deterministic cross-check.** When `share u` is equality the class is a singleton, so the
collapse reads `⊡ψ ↔ ψ`, matching `PlusLanguage.stab_iff_of_deterministic`.
-/
theorem stabQuant_iff_self_of_share_eq (S : SharingWitnessFamily Γ Del)
    (hat : S.AtomCoherent) (hloc : S.LocalCoherentShare) (hful : S.ThreadFulfilling)
    (hbox : S.toWitnessFamily.BoxFaithful)
    (hdiag : ∀ (u : ℤ) (i j : Fin S.lassos.length), S.share u i j → i = j)
    (ψ : Formula) (hψ : ψ ∈ closureOf (Γ ++ Del)) (θ : S.Thread) (s t : ℤ) :
    StabQuant S hat (S.hist θ s) t ψ ↔ ψ ∈ S.L (θ.idx (s + t)) (s + t) := by
  rw [stabQuant_iff_share_class S hat hloc hful hbox ψ hψ θ s t]
  constructor
  · intro h; exact h _ (S.share_refl (s + t) _)
  · intro h j hj; rwa [← hdiag (s + t) _ _ hj]

end SharingWitnessFamily

end FormalSystem.Metalogic.Decidability
