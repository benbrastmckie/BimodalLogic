import Bimodal.Metalogic.WeakCanonical.Kamp.EANegationFix.NegFix
import Bimodal.Metalogic.WeakCanonical.Kamp.VecEAConjFull

namespace Bimodal.Metalogic.WeakCanonical.Kamp

open Bimodal.Syntax
open Bimodal.Metalogic.WeakCanonical

/-! # Prop 4.2 / 4.3 De Morgan fold: `VecEA2.negFix` and `VVecEA2.negFix`


**Correspondence guard.** `VVecEA2.negFix_iff` below is Rabinovich's Prop 4.2 / 4.3 De Morgan
fold (**PDF p.6**, proved in Section 5, pp.7-11). The full page-cited Section 5 correspondence
table — and `prop42_contentful_of_attained`, which wires this theorem to the contentful Prop 4.2
target of `Prop42Contentful.lean` — is `Kamp/Section5Correspondence.lean`, reachable from
`Theories/Bimodal.lean` and so CI-protected. **Consult it before planning any Section 5 work.**
Cite by PDF page only: the former `chunk_0012` citation here pointed into the companion `.md`
conversion, which is corrupt (drops displayed equations, inverts `k ≠ m` to `k = m`).

**Carrier delta.** `VVecEA2.negFix_iff` assumes `HasAttainedINF`/`HasAttainedSUP` — strictly
stronger than the Dedekind completeness Rabinovich's Prop 4.2 is claimed over, and stronger even
than `HasDefinableINF`, machine-refuted as already too strong by `hasDefinableINF_excludes_kplus`
(`Lemma53.lean:282`). What is proved here is Prop 4.2 *restricted to attained structures*.

Negation closure at the disjunction-of-`→∃∀` level (Rabinovich Prop 4.2 /
4.3, PDF p.6). A `VecEA2` disjunct is the two-free-variable canonical form

  `ψ₀(z0) ∧ ψ₁(z1) ∧ [β0, α0, …, βn](z0, z1)`,

so its negation splits three ways (Lemma 3.2(2) two-free-variable split
composed with Prop 4.2):

  `¬ψ₀(z0) ∨ ¬ψ₁(z1) ∨ ¬[β0, α0, …, βn](z0, z1)`.

- The endpoint legs `¬ψ₀` / `¬ψ₁` are one-free-variable negations, atomic in
  the canonical TL expansion (chunk_0011): each becomes a single `VecEA2`
  disjunct with the negated endpoint predicate, a `top` opposite endpoint,
  and the trivial `top` bracket.
- The bracket leg is the delivered Lemma 5.1 recursion
  `BracketFormula.negFix` (Phase 10). Its gated Case-2/Case-3 disjuncts
  carry the **two-sided `B_i` nuance**: the negation of an interior segment
  type surfaces as `¬B_i = ¬Bi⁻ ∨ ¬Bi⁺` — an anchored left-failure mirror
  (`negBoundedLeftFixAnchored`, the `⁻` side) or a pinned right-recursion
  failure (`negFixList` on the right split, the `⁺` side). At this level we
  consume that structure opaquely through `BracketFormula.negFix_iff`.

The negation of a whole `VVecEA2` disjunction `∨ᵢ ϕᵢ` is then the De Morgan
fold `∧ᵢ ¬ϕᵢ`, closed back into `VVecEA2` by the Lemma 3.4 conjunction
`VVecEA2.conjFull` (Phase 7), with `VVecEA2.trivialTrue` as the neutral
element of the fold.
-/

/-! ## Per-disjunct negation (Prop 4.2, two-free-variable case) -/

/-- **Prop 4.2 per-disjunct negation**: the three-way split
`¬ψ₀(z0) ∨ ¬ψ₁(z1) ∨ ¬bracket(z0, z1)` of a single `VecEA2` disjunct, as a
`VVecEA2`. The endpoint legs are one-free-variable negations with trivial
brackets; the bracket leg maps the disjuncts of `BracketFormula.negFix`
(which carry the two-sided `¬B_i = ¬Bi⁻ ∨ ¬Bi⁺` gate structure) under `top`
endpoints. -/
def VecEA2.negFix {n : Nat} (vea : VecEA2 n) : VVecEA2 :=
  { disjuncts :=
      ⟨0, { endpointLeft := vea.endpointLeft.neg
            endpointRight := TemporalPred.top
            bracket := BracketFormula.trivial TemporalPred.top }⟩ ::
      ⟨0, { endpointLeft := TemporalPred.top
            endpointRight := vea.endpointRight.neg
            bracket := BracketFormula.trivial TemporalPred.top }⟩ ::
      vea.bracket.negFix.disjuncts.map fun bf =>
        ⟨bf.1, { endpointLeft := TemporalPred.top
                 endpointRight := TemporalPred.top
                 bracket := bf.2 }⟩ }

/-- **Prop 4.2 per-disjunct iff** (gated): on attained structures,
`vea.negFix` holds on `(z0, z1)` iff the disjunct `vea` fails on
`(z0, z1)`. The bracket leg reduces to `BracketFormula.negFix_iff`. -/
theorem VecEA2.negFix_iff {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (h_INF : HasAttainedINF M atomMap) (h_SUP : HasAttainedSUP M atomMap)
    {n : Nat} (vea : VecEA2 n) (z0 z1 : M.carrier) (h_lt : z0 < z1) :
    vea.negFix.holds M atomMap z0 z1 ↔ ¬ vea.holds M atomMap z0 z1 := by
  have hbr := BracketFormula.negFix_iff M atomMap h_INF h_SUP
    vea.bracket z0 z1 h_lt
  constructor
  · rintro ⟨d, hmem, hh⟩
    simp only [negFix, List.mem_cons, List.mem_map] at hmem
    rcases hmem with rfl | rfl | ⟨⟨m, bf⟩, hmbf, rfl⟩
    · -- Left-endpoint leg: ¬ψ₀(z0)
      simp only [VecEA2.holds] at hh
      obtain ⟨hel, -, -⟩ := hh
      rw [TemporalPred.eval_at_neg'] at hel
      rintro ⟨hl, -, -⟩
      exact hel hl
    · -- Right-endpoint leg: ¬ψ₁(z1)
      simp only [VecEA2.holds] at hh
      obtain ⟨-, her, -⟩ := hh
      rw [TemporalPred.eval_at_neg'] at her
      rintro ⟨-, hr, -⟩
      exact her hr
    · -- Bracket leg: some disjunct of `vea.bracket.negFix` holds
      simp only [VecEA2.holds] at hh
      obtain ⟨-, -, hbf⟩ := hh
      have hneg : vea.bracket.negFix.holds M atomMap z0 z1 :=
        ⟨⟨m, bf⟩, hmbf, hbf⟩
      rintro ⟨-, -, hb⟩
      exact (hbr.mp hneg) hb
  · intro hne
    by_cases hl : vea.endpointLeft.eval_at M atomMap z0
    · by_cases hr : vea.endpointRight.eval_at M atomMap z1
      · -- Both endpoints hold, so the bracket must fail: bracket leg
        have hb : ¬ vea.bracket.holds M atomMap z0 z1 :=
          fun hb => hne ⟨hl, hr, hb⟩
        obtain ⟨⟨m, bf⟩, hmbf, hbf⟩ := hbr.mpr hb
        refine ⟨⟨m, { endpointLeft := TemporalPred.top
                      endpointRight := TemporalPred.top
                      bracket := bf }⟩, ?_,
                TemporalPred.eval_at_top M atomMap z0,
                TemporalPred.eval_at_top M atomMap z1, hbf⟩
        simp only [negFix, List.mem_cons, List.mem_map]
        exact Or.inr (Or.inr ⟨⟨m, bf⟩, hmbf, rfl⟩)
      · -- Right endpoint fails: right-endpoint leg
        refine ⟨⟨0, { endpointLeft := TemporalPred.top
                      endpointRight := vea.endpointRight.neg
                      bracket := BracketFormula.trivial TemporalPred.top }⟩,
                ?_, TemporalPred.eval_at_top M atomMap z0, ?_, ?_⟩
        · simp [negFix]
        · exact (TemporalPred.eval_at_neg' M atomMap _ z1).mpr hr
        · rw [BracketFormula.trivial_holds]
          intro y _ _
          exact TemporalPred.eval_at_top M atomMap y
    · -- Left endpoint fails: left-endpoint leg
      refine ⟨⟨0, { endpointLeft := vea.endpointLeft.neg
                    endpointRight := TemporalPred.top
                    bracket := BracketFormula.trivial TemporalPred.top }⟩,
              ?_, ?_, TemporalPred.eval_at_top M atomMap z1, ?_⟩
      · simp [negFix]
      · exact (TemporalPred.eval_at_neg' M atomMap _ z0).mpr hl
      · rw [BracketFormula.trivial_holds]
        intro y _ _
        exact TemporalPred.eval_at_top M atomMap y

/-! ## The De Morgan fold (Prop 4.3) -/

/-- **Prop 4.3 De Morgan fold**: the negation of a `VVecEA2` disjunction
`∨ᵢ ϕᵢ` is the conjunction `∧ᵢ ¬ϕᵢ` of the per-disjunct negations, closed
back into `VVecEA2` by the Lemma 3.4 conjunction `VVecEA2.conjFull`, with
`VVecEA2.trivialTrue` as the neutral element. -/
def VVecEA2.negFix (v : VVecEA2) : VVecEA2 :=
  v.disjuncts.foldr (fun d acc => d.2.negFix.conjFull acc) VVecEA2.trivialTrue

/-- List form of the De Morgan fold: the fold holds iff every disjunct in
the list fails. Induction on the list; the cons step is
`VVecEA2.conjFull_iff` + `VecEA2.negFix_iff`. -/
theorem vecEANegFixFold_iff {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (h_INF : HasAttainedINF M atomMap) (h_SUP : HasAttainedSUP M atomMap)
    (z0 z1 : M.carrier) (h_lt : z0 < z1) (l : List (Σ n, VecEA2 n)) :
    (l.foldr (fun d acc => d.2.negFix.conjFull acc)
      VVecEA2.trivialTrue).holds M atomMap z0 z1 ↔
    ∀ d ∈ l, ¬ d.2.holds M atomMap z0 z1 := by
  induction l with
  | nil =>
    simp only [List.foldr_nil]
    constructor
    · intro _ d hd
      exact absurd hd (by simp)
    · intro _
      exact VVecEA2.trivialTrue_holds M atomMap z0 z1
  | cons d ds ih =>
    rw [List.foldr_cons, VVecEA2.conjFull_iff,
        VecEA2.negFix_iff M atomMap h_INF h_SUP d.2 z0 z1 h_lt, ih,
        List.forall_mem_cons]

/-- **Prop 4.2 / 4.3** (Rabinovich 2014, gated): on attained structures, the
De Morgan fold `v.negFix` holds on `(z0, z1)` iff the `VVecEA2` disjunction
`v` fails on `(z0, z1)`. -/
theorem VVecEA2.negFix_iff {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (h_INF : HasAttainedINF M atomMap) (h_SUP : HasAttainedSUP M atomMap)
    (v : VVecEA2) (z0 z1 : M.carrier) (h_lt : z0 < z1) :
    v.negFix.holds M atomMap z0 z1 ↔ ¬ v.holds M atomMap z0 z1 := by
  refine (vecEANegFixFold_iff M atomMap h_INF h_SUP z0 z1 h_lt
    v.disjuncts).trans ?_
  simp only [VVecEA2.holds, not_exists, not_and]

end Bimodal.Metalogic.WeakCanonical.Kamp
