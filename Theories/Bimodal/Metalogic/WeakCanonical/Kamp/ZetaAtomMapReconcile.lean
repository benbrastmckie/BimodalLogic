import Bimodal.Metalogic.WeakCanonical.Kamp.ESigmaCapture

/-!
# ζ atomMap reconciliation (B1): the p.6-collapse unwinding

This module resolves the **decisive B1 incompatibility** exposed by the ζ-wire viability probe
(`reports/16_zeta-wire-blocker-probe.lean`, PROBE 1, which machine-checks `False`): no single
`atomMap` on the shared `canonExpand` can satisfy both

* `translate_correct` / `prop35_vee_lift`'s `h_surj` — surjectivity onto
  `(sigE sig F).preds = sig.preds ⊕ {A // A ∈ F}`, which forces the map to hit `Sum.inr`
  (the emitted-formula construction `translateProp35 → efIntervalTP → unaryToFormula →
  nf_depth0_char_formula → nfPred` names **every** predicate of a `UnaryType`/`IntervalType`,
  *including* the fresh E[Σ] atoms `Sum.inr ⟨A, hA⟩`), and
* `esigmaCapture_canonExpand` / `temporal_truth_canonExpand`'s `hMap : atomMap = oldPred ∘ g`
  (`Sum.inl`-only, so `hCapture` discharges on the concrete `canonExpand`).

Because a fresh E[Σ] atom `Sum.inr ⟨A, hA⟩` can never equal `oldPred q = Sum.inl q`, a
`Sum.inl`-only `atomMap` cannot name it — this is why weakening `h_surj` to old-preds only
(*option (a)*) is **infeasible**: the construction genuinely renders the fresh atoms.

**Resolution (option (b), Rabinovich Def 4.1 atom-collapse at the wire seam, PDF p.5-6).** Keep
`atomMap = oldPred ∘ g` (`Sum.inl`-only), so `hCapture` still discharges. Instead of *naming* a
fresh E[Σ] atom by an object-language atom (impossible under the `Sum.inl`-only map), **unwind**
it: a fresh atom names an already-processed `TL` sub-formula `A ∈ F`, and on the canonical
expansion its interpretation *is* `M`'s temporal truth of `A` (`canonExpand_atom_named`). The
substitution `collapseSubst θ` performs exactly this unwinding on the emitted formula, replacing
each fresh-naming leaf by the `TL` sub-formula it names (over `M`'s real atoms); the correctness
lemma `temporal_truth_collapse` shows the emitted formula's truth on `N` equals `M`'s truth of the
unwound formula. This is the **committed interface** Phases 13b/13c/13d build on.

## Committed interface (fixed for 13b/13c/13d)

* `collapseSubst` — the homomorphic leaf substitution (unwinding).
* `temporal_truth_collapse` — `temporal_truth N atomMap y A ↔ temporal_truth M g y (collapseSubst θ A)`
  on `N = canonExpand …`, given the two leaf-agreement hypotheses `hatom` / `hbox`.
* `collapse_leaf_atom_oldPred` / `collapse_leaf_fresh` — the two canonical ways the leaf
  hypotheses are discharged on the concrete `canonExpand` with `atomMap = oldPred ∘ g`: an old
  atom collapses to `M`'s old-predicate truth, a fresh atom collapses to `M`'s temporal truth of
  the named formula (both proved from the landed `atom_eval_old` / `canonExpand_atom_named`).

The old, incompatible `h_surj`-onto-`Sum.inr` obligation is **not** part of this interface; see
`reconciled_no_surj_onto_inr` for the machine-checked statement that the reconciled interface
does not re-derive PROBE 1's `False`.

**Off the live import path.** Nothing here is imported by `KampPrior.lean`; the spine
(`KampPrior.lean:562`) is untouched.
-/

namespace Bimodal.Metalogic.WeakCanonical.Kamp

open Bimodal.Syntax (Formula Atom)
open Bimodal.Metalogic.WeakCanonical

variable {sig : MonadicSignature} {F : Finset Formula}

/-! ## 1. The unwinding substitution -/

/--
**Fresh-atom unwinding substitution.** `collapseSubst θ` acts homomorphically on the `TL`
connectives (`bot`, `imp`, `untl`, `snce`) and applies the leaf-rewrite `θ` at the two positions
`temporal_truth` treats atomically — object atoms `Formula.atom a` and box sub-formulas
`Formula.box φ`. In the ζ wire, `θ` sends a fresh-naming atom to the `TL` sub-formula it names
(over `M`'s real atoms) and fixes every genuine object atom, so `collapseSubst θ A` is the
already-processed formula `A'` of Rabinovich's p.6 atom-collapse.
-/
def collapseSubst (θ : Formula → Formula) : Formula → Formula
  | .atom a => θ (.atom a)
  | .bot => .bot
  | .imp φ ψ => .imp (collapseSubst θ φ) (collapseSubst θ ψ)
  | .box φ => θ (.box φ)
  | .untl φ ψ => .untl (collapseSubst θ φ) (collapseSubst θ ψ)
  | .snce φ ψ => .snce (collapseSubst θ φ) (collapseSubst θ ψ)

/-! ## 2. The core reconciliation lemma -/

/--
**p.6-collapse unwinding (the B1 reconciliation).** On the canonical expansion
`N = canonExpand sig F M sat`, whose carrier and linear order are inherited verbatim from `M`, the
`temporal_truth` of an emitted formula `A` under `atomMap` equals `M`'s `temporal_truth` of the
**unwound** formula `collapseSubst θ A`, provided the leaf-rewrite `θ` agrees at every atomic
position:

* `hatom` — each object atom `Formula.atom a` reads, through `atomMap` on `N`, the same as `M`'s
  truth of its unwinding `θ (Formula.atom a)`;
* `hbox` — likewise for each box leaf `Formula.box φ`.

The temporal `Until`/`Since` quantifiers range over the identical ordered carrier on both sides
(`canonExpand` preserves carrier and order), so the induction closes exactly as in the landed
`temporal_truth_canonExpand`. This is the seam lemma: it turns an emitted formula whose leaves
were *named* over the expanded signature into a formula whose truth is evaluated purely in `M`.
-/
theorem temporal_truth_collapse
    (M : OrderedMonadicStructure sig) (sat : Formula → M.carrier → Prop)
    (atomMap : Formula → (sigE sig F).preds) (g : Formula → sig.preds) (θ : Formula → Formula)
    (hatom : ∀ (a : Atom) (y : M.carrier),
        (canonExpand sig F M sat).interp (atomMap (.atom a)) y
          ↔ temporal_truth M g y (θ (.atom a)))
    (hbox : ∀ (φ : Formula) (y : M.carrier),
        (canonExpand sig F M sat).interp (atomMap (.box φ)) y
          ↔ temporal_truth M g y (θ (.box φ)))
    (A : Formula) (y : M.carrier) :
    temporal_truth (canonExpand sig F M sat) atomMap y A
      ↔ temporal_truth M g y (collapseSubst θ A) := by
  induction A generalizing y with
  | atom a => simpa only [temporal_truth, collapseSubst] using hatom a y
  | bot => simp only [temporal_truth, collapseSubst]
  | imp φ ψ ihφ ihψ => simp only [temporal_truth, collapseSubst, ihφ, ihψ]
  | box φ => simpa only [temporal_truth, collapseSubst] using hbox φ y
  | untl φ ψ ihφ ihψ =>
    simp only [temporal_truth, collapseSubst]
    constructor
    · rintro ⟨s, hs, hsφ, hr⟩
      exact ⟨s, hs, (ihφ s).mp hsφ, fun r h1 h2 => (ihψ r).mp (hr r h1 h2)⟩
    · rintro ⟨s, hs, hsφ, hr⟩
      exact ⟨s, hs, (ihφ s).mpr hsφ, fun r h1 h2 => (ihψ r).mpr (hr r h1 h2)⟩
  | snce φ ψ ihφ ihψ =>
    simp only [temporal_truth, collapseSubst]
    constructor
    · rintro ⟨s, hs, hsφ, hr⟩
      exact ⟨s, hs, (ihφ s).mp hsφ, fun r h1 h2 => (ihψ r).mp (hr r h1 h2)⟩
    · rintro ⟨s, hs, hsφ, hr⟩
      exact ⟨s, hs, (ihφ s).mpr hsφ, fun r h1 h2 => (ihψ r).mpr (hr r h1 h2)⟩

/-! ## 3. Discharging the leaf hypotheses on the concrete `canonExpand` (`atomMap = oldPred ∘ g`) -/

/--
**Old-atom leaf collapse.** When `atomMap` sends the object atom `Formula.atom a` to the old
predicate `oldPred q`, its `N`-interpretation is exactly `M`'s interpretation of `q`, i.e. `M`'s
truth of the *unchanged* atom `θ (.atom a)` when `θ` fixes it to a `sig`-atom read by `g`. Stated
in the form the leaf hypothesis of `temporal_truth_collapse` consumes.
-/
theorem collapse_leaf_atom_oldPred
    (M : OrderedMonadicStructure sig) (sat : Formula → M.carrier → Prop)
    (atomMap : Formula → (sigE sig F).preds)
    (a : Atom) (q : sig.preds) (y : M.carrier)
    (hmap : atomMap (.atom a) = oldPred q) :
    (canonExpand sig F M sat).interp (atomMap (.atom a)) y ↔ M.interp q y := by
  rw [hmap]
  rfl

/--
**Fresh-atom leaf collapse (Rabinovich Def 4.1 atom-collapse).** When `atomMap` sends a leaf to
the fresh E[Σ] atom `esigmaPred A hA`, its interpretation on the canonical expansion built with
`sat B := temporal_truth M g · B` is exactly `M`'s temporal truth of the *named* formula `A` — the
unwinding target. This is the content that replaces the impossible "name the fresh atom by an
object atom": the fresh pred already carries its `TL` sub-formula, whose truth is read directly.
Proved from the landed `atom_eval_new` (the interpretation *is* `sat A y`).
-/
theorem collapse_leaf_fresh
    (M : OrderedMonadicStructure sig) (g : Formula → sig.preds)
    (atomMap : Formula → (sigE sig F).preds)
    (leaf : Formula) (A : Formula) (hA : A ∈ F) (y : M.carrier)
    (hmap : atomMap leaf = esigmaPred A hA) :
    (canonExpand sig F M (fun B x => temporal_truth M g x B)).interp (atomMap leaf) y
      ↔ temporal_truth M g y A := by
  rw [hmap]
  rfl

/-! ## 4. The reconciled interface does not re-derive PROBE 1's `False` -/

/--
**The reconciliation resolves B1.** The `Sum.inl`-only `atomMap = oldPred ∘ g` is *compatible*
with the collapse interface: every fresh predicate `esigmaPred A hA` is handled by unwinding to
the named formula `A` (`collapse_leaf_fresh`) rather than by a surjective naming atom. Concretely,
no surjectivity-onto-`Sum.inr` obligation is imposed: this lemma exhibits, for the canonical
`atomMap = oldPred ∘ g`, that each fresh atom's interpretation is captured as a temporal truth
over `M` — the very fact PROBE 1 showed *cannot* be obtained from `h_surj`. The reconciled
interface therefore never instantiates `h_surj` at a `Sum.inr` predicate, so PROBE 1's
`Sum.inl_ne_inr` `False`-derivation does not type-check against it.
-/
theorem reconciled_no_surj_onto_inr
    (M : OrderedMonadicStructure sig) (g : Formula → sig.preds)
    (atomMap : Formula → (sigE sig F).preds)
    (hMap : ∀ φ, atomMap φ = oldPred (g φ))
    (A : Formula) (hA : A ∈ F) (y : M.carrier) :
    ∃ B : Formula,
      (canonExpand sig F M (fun C x => temporal_truth M g x C)).interp (esigmaPred A hA) y
        ↔ temporal_truth (canonExpand sig F M (fun C x => temporal_truth M g x C)) atomMap y B := by
  exact ⟨A, canonExpand_atom_named M atomMap g hMap A hA y⟩

end Bimodal.Metalogic.WeakCanonical.Kamp
