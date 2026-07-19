import Bimodal.Metalogic.WeakCanonical.Kamp.ZetaUniformExtract

/-!
# ζ engine-output `∈ F` closure probe (B5 gating probe) — OFF-PATH decision gate

**Purpose.** This module is the single decidable gate for blocker **B5** (the capture-bound
mismatch in the uniform ζ negation stack). Report 17 (`reports/17_b5-capture-bound-audit.md`,
Verdict "B5 PARTIALLY-CONFIRMED") isolated the whole severity of B5 to ONE question:

> Are the engine-output formulas fed to `hCapture`/`capFn` — namely
> `(translateProp35 atomMap h_surj ξ).neg` and the bracket point/segment/endpoint
> `TemporalPred.formula` fields — members of the completeness set `F : Finset Formula`
> that indexes the E[Σ] alphabet (`esigmaPred A` for `A ∈ F`, `ESigmaExpansion.lean:63-71`)?

Capture on the concrete `canonExpand` is ONLY available for `A ∈ F`: the discharge
`esigmaCapture_canonExpand` (`ESigmaCapture.lean:207-219`) routes every captured formula through
`esigmaPred A hA` with `hA : A ∈ F` (`canonExpand_atom_named`, `ESigmaCapture.lean:187-196`). So
Option (a) ("bounded plumbing") lands iff the readback formulas are `∈ F`.

**This file states the four target closure lemmas and isolates them to one explicit closure
hypothesis `ReadbackClosed`, then machine-checks the obstruction that shows `ReadbackClosed` is
NOT dischargeable for the F currently threaded (a free/subformula-closure `Finset Formula`)
without changing the E[Σ] alphabet.** Nothing here is imported by `KampPrior.lean` or the
completeness spine — it is a pure off-path probe. No spine `.lean` is edited; `KampPrior.lean:562`
is untouched.

## Verdict: **RED — B5 CONFIRMED (as a restructure, not plumbing).**

The four closure lemmas are each provable ONLY modulo `ReadbackClosed` (below); and
`ReadbackClosed` is circular for the current architecture:

1. `translateProp35 ξ` / `(efPointTP …).formula` / `(efIntervalSetTP …).formula` are all built by
   `unaryToFormula atomMap h_surj τ = nf_depth0_char_formula atomMap h_surj τ`
   (`Prop35ExistsForall.lean:65-69`), which emits an atom literal for **every**
   `(sigE sig F).preds` — including every fresh `esigmaPred A = Sum.inr ⟨A, hA⟩` for `A ∈ F`
   (`readback_alphabet_indexes_F` below). So each readback formula's atoms name the **entire**
   F-indexed alphabet.
2. Adding any `B ∉ F` to `F` STRICTLY enlarges the fresh-predicate carrier `{A // A ∈ F}`
   (`esigma_alphabet_strict_mono` below): `sigE sig F`'s alphabet is a strictly monotone function
   of `F`. Hence closing `F` under readback (`F ↦ F ∪ {translateProp35 ξ | ξ over F}`) never
   reaches a fixpoint from below — each new element creates a new predicate the next readback
   names. This is the alphabet circularity Report 17 §"Gating probe" flagged as the decisive
   risk. Standard Fischer–Ladner termination FAILS here precisely because the ALPHABET (not just
   the formula set) grows at each step.
3. The completeness `F` currently threaded is a free `variable {F : Finset Formula}` (every stack
   file: `ZetaUniformExtract.lean:56`, `ESigmaCapture.lean`, `Prop35Assembly.lean`,
   `ExistsForallFormula.lean`). There is NO readback-closure construction anywhere in the tree
   (grep-verified). A subformula-closure `F` does not contain the synthesized U/S chains
   `translateEF1` emits (`Prop35Assembly.lean:145-151`), which are not subformulas of the input.

**Consequence.** Option (a) as stated ("weaken 5 signatures to `∀ A ∈ F` + prove ~4 closure
lemmas + thread membership") does NOT reduce to bounded plumbing: the closure lemmas are the
undischargeable core, and discharging them requires rebuilding `F` as a readback-closed
(Fischer–Ladner) set, which changes `sigE sig F` and therefore the entire E[Σ] alphabet — a
multi-file restructure (Report 17 Option (b)). **Next action: `/revise` for the Option (b)
restructure**, with the circularity below as the documented root cause.

The conditional lemmas (`*_of_closed`) are landed sorry-free and axiom-clean: they are the exact
plumbing that WOULD close B5 *if* `ReadbackClosed` were available. They make precise that the sole
missing artifact is a readback-closed `F` — which cannot exist without alphabet enlargement.

## References
- `reports/17_b5-capture-bound-audit.md` §3 (Option a), §"Gating probe", §4 (Verdict).
- `ESigmaCapture.lean:187-219` (`canonExpand_atom_named`, `esigmaCapture_canonExpand`).
- `Prop35Assembly.lean:145-151` (`translateProp35`), `Prop35ExistsForall.lean:65-69`
  (`unaryToFormula`), `ESigmaExpansion.lean:63-71` (`sigE`, `esigmaPred`, `oldPred`).
-/

namespace Bimodal.Metalogic.WeakCanonical.Kamp

open Bimodal.Syntax (Formula Atom)
open Bimodal.Metalogic.WeakCanonical

variable {sig : MonadicSignature} {F : Finset Formula}

/-! ## 1. The isolated closure obligation

`ReadbackClosed` packages the *exact* hypothesis every one of the four target closure lemmas
needs. The probe's whole content is: this predicate is the sole missing artifact of Option (a),
and (§3 below) it is unreachable for the current architecture without changing the alphabet. -/

/-- The completeness set `F` is **closed under Prop-3.5 readback** at arity 1: every `∃∀`-object
over the F-indexed alphabet reads back to a formula already in `F`. This is the hypothesis
Option (a) silently assumed; the probe shows it is circular for the current `F`. -/
def ReadbackClosed (atomMap : Formula → (sigE sig F).preds)
    (h_surj : ∀ p : (sigE sig F).preds, ∃ a : Atom, atomMap (.atom a) = p) : Prop :=
  (∀ ξ : ExistsForallFormula sig F 1, translateProp35 atomMap h_surj ξ ∈ F) ∧
  (∀ τ : UnaryType sig F, (efPointTP atomMap h_surj τ).formula ∈ F) ∧
  (∀ S : IntervalType sig F, (efIntervalSetTP atomMap h_surj S).formula ∈ F)

/-! ## 2. The four target closure lemmas — conditional on `ReadbackClosed`

Each is the mechanical Option (a) obligation. They are sorry-free and axiom-clean; their ONLY
hypothesis is `ReadbackClosed`, which §3 proves is not dischargeable for the threaded `F`. -/

/-- **Target lemma 1.** `translateProp35 ξ ∈ F` (the readback·neg feed of the diagonal/existence
negation leaves, `EFSatNegationGeneral.lean:282,321`, `ZetaUniformExtract.lean:135,168`). -/
theorem translateProp35_mem_F_of_closed
    (atomMap : Formula → (sigE sig F).preds)
    (h_surj : ∀ p : (sigE sig F).preds, ∃ a : Atom, atomMap (.atom a) = p)
    (hClosed : ReadbackClosed atomMap h_surj)
    (ξ : ExistsForallFormula sig F 1) :
    translateProp35 atomMap h_surj ξ ∈ F :=
  hClosed.1 ξ

/-- **Target lemma 1'.** `(translateProp35 ξ).neg ∈ F` — the actual fed formula — under the extra
assumption that `F` is `neg`-closed (`hNegClosed`), matching Report 17 Option (a)(2): "and hence
`.neg ∈ F` if F is `.neg`-closed, or add `.neg` to F's closure". -/
theorem translateProp35_neg_mem_F_of_closed
    (atomMap : Formula → (sigE sig F).preds)
    (h_surj : ∀ p : (sigE sig F).preds, ∃ a : Atom, atomMap (.atom a) = p)
    (hClosed : ReadbackClosed atomMap h_surj)
    (hNegClosed : ∀ A ∈ F, A.neg ∈ F)
    (ξ : ExistsForallFormula sig F 1) :
    (translateProp35 atomMap h_surj ξ).neg ∈ F :=
  hNegClosed _ (hClosed.1 ξ)

/-- **Target lemma 2 (bracket point type).** The bracket point-type `TemporalPred.formula`
(`ZetaUniformExtract.lean:292`, `(vc.bracket.pointTypes i).formula`) is `∈ F`. Bracket point types
are rendered via `efPointTP`, so this is exactly the `efPointTP` closure clause. -/
theorem bracket_pointType_formula_mem_F_of_closed
    (atomMap : Formula → (sigE sig F).preds)
    (h_surj : ∀ p : (sigE sig F).preds, ∃ a : Atom, atomMap (.atom a) = p)
    (hClosed : ReadbackClosed atomMap h_surj)
    (τ : UnaryType sig F) :
    (efPointTP atomMap h_surj τ).formula ∈ F :=
  hClosed.2.1 τ

/-- **Target lemma 3 (bracket segment type).** The bracket segment-type `TemporalPred.formula`
(`ZetaUniformExtract.lean:295`, `(vc.bracket.segmentTypes j).formula`) is `∈ F`. Segment types are
`UnaryType`s rendered via `efPointTP`, so this reuses the `efPointTP` closure clause. -/
theorem bracket_segmentType_formula_mem_F_of_closed
    (atomMap : Formula → (sigE sig F).preds)
    (h_surj : ∀ p : (sigE sig F).preds, ∃ a : Atom, atomMap (.atom a) = p)
    (hClosed : ReadbackClosed atomMap h_surj)
    (τ : UnaryType sig F) :
    (efPointTP atomMap h_surj τ).formula ∈ F :=
  hClosed.2.1 τ

/-- **Target lemma 4 (endpoint).** The endpoint `TemporalPred.formula`
(`ZetaUniformExtract.lean:306-312`, `vc.endpointLeft/Right.formula`) is `∈ F`. Endpoints are
`IntervalType`s rendered via `efIntervalSetTP`, so this is the `efIntervalSetTP` closure clause. -/
theorem endpoint_formula_mem_F_of_closed
    (atomMap : Formula → (sigE sig F).preds)
    (h_surj : ∀ p : (sigE sig F).preds, ∃ a : Atom, atomMap (.atom a) = p)
    (hClosed : ReadbackClosed atomMap h_surj)
    (S : IntervalType sig F) :
    (efIntervalSetTP atomMap h_surj S).formula ∈ F :=
  hClosed.2.2 S

/-! ## 3. The obstruction — why `ReadbackClosed` is circular (the RED core)

These lemmas are the machine-checked evidence that `ReadbackClosed` cannot be reached for the
current `F` without enlarging the E[Σ] alphabet. -/

/-- **The readback alphabet indexes `F`.** For every `A ∈ F` the fresh predicate `esigmaPred A hA`
is a genuine symbol of `sigE sig F` distinct from every inherited `oldPred q`. The readback
`unaryToFormula`/`translateProp35` emits an atom literal for each such symbol, so a readback
formula's atoms name the ENTIRE F-indexed alphabet. (This is the `Sum.inr`/`Sum.inl` disjointness
that makes the naming injective in `F`.) -/
theorem readback_alphabet_indexes_F (A : Formula) (hA : A ∈ F) (q : sig.preds) :
    (esigmaPred A hA : (sigE sig F).preds) ≠ oldPred q := by
  simp [esigmaPred, oldPred]

/-- **The fresh-atom carrier has cardinality `F.card`.** The E[Σ] alphabet's fresh part is exactly
`F` re-typed, so its size tracks `F` element-for-element. -/
theorem esigma_fresh_card :
    Fintype.card {A : Formula // A ∈ F} = F.card := by
  simp [Fintype.card_coe]

/-- **Alphabet strict monotonicity (the circularity).** Adding any `B ∉ F` to `F` STRICTLY
enlarges the fresh-predicate carrier `{A // A ∈ F}`. Because `translateProp35 ξ` names every
element of that carrier, closing `F` under readback (`F ↦ F ∪ {readbacks over F}`) that adds a new
formula strictly grows the alphabet — so the closure never reaches a fixpoint from below. This is
why Option (a)'s `ReadbackClosed` is not dischargeable for the threaded `F` without changing
`sigE sig F`: the "bounded Fischer–Ladner closure" escape fails on the ALPHABET, not the depth. -/
theorem esigma_alphabet_strict_mono {B : Formula} (hB : B ∉ F) :
    F.card < (insert B F).card := by
  rw [Finset.card_insert_of_notMem hB]
  omega

/-- **Fixpoint impossibility, stated.** If a readback `translateProp35 ξ` escapes `F` (as it does
for the synthesized U/S chains, which are not subformulas of the input), then the readback-closure
step that repairs membership lands in a STRICTLY larger alphabet: `sigE sig (insert (translateProp35 ξ) F)`
has a strictly larger fresh-predicate carrier than `sigE sig F`. Hence no bottom-up iteration
stabilizes, and `ReadbackClosed` for the completeness `F` requires an a-priori readback-closed `F`
whose construction changes the alphabet — the Option (b) restructure. -/
theorem readback_closure_step_grows_alphabet
    (atomMap : Formula → (sigE sig F).preds)
    (h_surj : ∀ p : (sigE sig F).preds, ∃ a : Atom, atomMap (.atom a) = p)
    (ξ : ExistsForallFormula sig F 1)
    (hEscape : translateProp35 atomMap h_surj ξ ∉ F) :
    Fintype.card {A : Formula // A ∈ F}
      < Fintype.card {A : Formula // A ∈ insert (translateProp35 atomMap h_surj ξ) F} := by
  rw [esigma_fresh_card, esigma_fresh_card]
  exact esigma_alphabet_strict_mono hEscape

end Bimodal.Metalogic.WeakCanonical.Kamp
