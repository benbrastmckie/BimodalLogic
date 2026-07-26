/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

-- Imports verbatim: the union of the two source files' import blocks.
-- From Chronicle/ChronicleToCountermodel.lean:
import Bimodal.Metalogic.BXCanonical.Chronicle.ChronicleToCountermodelBasic
import Bimodal.Metalogic.WeakCanonical.IntegerModel.GoodStructuresModelSurgery
-- From WeakCanonical/Transfer.lean:
import Bimodal.Metalogic.WeakCanonical.IntegerModel.GoodStructures
import Bimodal.Metalogic.WeakCanonical.IntegerModel.ShiftAndGlue
import Bimodal.Metalogic.WeakCanonical.OrderedSum
import Bimodal.Metalogic.Algebraic.ParametricCanonical
import Bimodal.Metalogic.Algebraic.ParametricHistory
import Bimodal.Metalogic.Algebraic.ParametricCompleteness
import Bimodal.Metalogic.Algebraic.RestrictedParametricTruthLemma
import Bimodal.Metalogic.BXCanonical.Chronicle.ChronicleToCountermodel
import Bimodal.Metalogic.WeakCanonical.Expressiveness.Theorem6
import Bimodal.Semantics.Validity
import Mathlib.Data.Int.SuccPred

/-!
ARCHIVED (Boneyard) — never compiled.

The `chronicle_gap_contradiction` `sorryAx` closure, excised as ONE unit from two live files.

Origin:
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/ChronicleToCountermodel.lean` (9 declarations)
- `Theories/Bimodal/Metalogic/WeakCanonical/Transfer.lean` (1 declaration)

## The closure

```
chronicle_gap_contradiction  (private; the sole `sorry` token in the chain)
  → succ_cofinal                        (private)
  → limitDomSubtype_isSuccArchimedean
  → succ_embed_surjective               (letI binding inside its proof)
  → cantor_bfmcs_discrete_restricted_tc  and  cantor_bfmcs_discrete_restricted_fuc
  → dd_countermodel_chronicle_discrete   (0 consumers)
  → countermodel_discrete_reynolds       (Transfer.lean; 0 consumers)
```

Two adjacent sorry-free private helpers, `limit_f_some_future_of_lt` and
`limit_f_not_G_neg_of_mem`, sat inside the same contiguous section with no call sites outside
it, and moved with it. Total: 10 declarations. The closure did not grow during excision —
`lake build` was green on the first attempt after the tails were removed, so the audited
fixpoint was already closed.

## Why it is dead

Both heads of the chain have zero consumers. `dd_countermodel_chronicle_discrete` and
`countermodel_discrete_reynolds` were referenced only from comments. The live discrete
completeness path does not touch this chain at all: `completeness_discrete` goes through
`countermodel_discrete_reynolds_v2` (`WeakCanonical/IntegerModel/ReynoldsBridge.lean`), which
bypasses `succ_embed_surjective` and the `IsSuccArchimedean` requirement entirely — and which
is `sorryAx`-free, independently confirming the bypass.

A whole-environment `Lean.collectAxioms` scan over 19,442 `Bimodal.*` constants isolated these
8 tainted names as a closed island: nothing outside the island inherited their taint.

## Why it was not archived earlier

`ChronicleToCountermodel.lean` carried an in-file note asserting these declarations were
"compile-LIVE … excising any of them breaks `lake build` — keep them". The note was right about
*piecemeal* excision and wrong in its conclusion, because the consumer it named,
`countermodel_discrete_enriched`, had itself already been archived (to the sibling
`TransferDead.lean` in this directory). With that consumer gone, both surviving heads were dead
and the whole closure could move together.

Note also that `Transfer.lean` claimed `countermodel_discrete_reynolds` "is now sorry-free".
`#print axioms` refuted this: the theorem was `sorryAx`-tainted via
`cantor_bfmcs_discrete_restricted_tc`/`_fuc`. The sorry-free discrete theorem is the
differently-named `countermodel_discrete_reynolds_v2`.

## Orphans deliberately left live

Removing this closure orphaned several sorry-free declarations. They were **deliberately left
in live code**, because removing sorry-free declarations widens the diff without retiring a
sorry:

- `cantor_bfmcs_discrete_restricted_buc` — its only two consumers
  (`dd_countermodel_chronicle_discrete` and `countermodel_discrete_reynolds`) both left, but it
  is sorry-free
- `succ_embed_squeeze`, `succ_embed_squeeze_strict`, `succ_embed_no_gap` — fed
  `succ_embed_surjective`
- `limitDomSubtype_succOrder` / `limitDomSubtype_predOrder` and the surrounding collapse
  machinery, which remain reachable from the live `cantor_bfmcs_discrete` /
  `rooted_succ_discrete_fmcs` path

Orphan cleanup is a separate, optional concern.

## What stayed

`WeakCanonical.countermodel_discrete` — which sits immediately after
`countermodel_discrete_reynolds` in `Transfer.lean` — was NOT archived. It is the sole `sorryAx`
source reaching `BXCanonical.completeness` and is a live proof obligation, not dead code. It
carries a direct terminal `sorry` (axiom set `[propext, sorryAx]`, with no inherited taint) and
must be discharged by a genuinely new construction; the BX-pipeline route archived here is
provably unavailable, since it terminates in `succ_cofinal`, refuted by the ℤ+ℤ counterexample
documented in `../BXPipelineGapAnalysis/`.

Import lines above are historical text and are not repaired.

Do not import from live code.
-/

#exit

/- ============================================================================
   SOURCE: Theories/Bimodal/Metalogic/BXCanonical/Chronicle/ChronicleToCountermodel.lean
   Section: `## Chronicle Gap Elimination via Model Surgery`
   Declarations: limit_f_some_future_of_lt, limit_f_not_G_neg_of_mem,
                 chronicle_gap_contradiction, succ_cofinal,
                 limitDomSubtype_isSuccArchimedean
   ============================================================================ -/

/-! ## Chronicle Gap Elimination via Model Surgery

Reynolds' Theorem 14 adapted to the chronicle level using sorry-free model
surgery from `GoodStructuresModelSurgery.lean`.

The proof uses `gap_contradicts_prior` / `gap_contradicts_prior_below` together
with `no_boundary_at_successor` from GoodStructures.lean to derive a contradiction
from the existence of a bounded successor orbit.

## Strategy

Given `a < b` with `∀ n, succ^[n](a) < b`:

1. Build an `OrderedMonadicStructure` on `LimitDomSubtype` with `interp p x :=
   (atomMap_rev p) ∈ limit_f(x.val)`, where the signature is a singleton
   `{ψ}` for a formula ψ distinguishing `limit_f(a.val)` from `limit_f(b.val)`.

2. Prove `semantic_prior_UZ/SZ` for this structure using the MCS-level Prior-UZ/SZ
   (from `h_fc : Discrete ≤ fc`) together with C4/C5 coherence.

3. By `no_boundary_at_successor`: the contemp_equiv class of `a` is succ-closed.

4. Since `a` and `b` are NOT contemp_equiv (ψ distinguishes them), `b` bounds the
   class of `a` above. By `gap_contradicts_prior`: False.

## Constant-MCS Case

When `limit_f(a.val) = limit_f(b.val)`, no formula distinguishes a and b, so
contemp_equiv holds for all sig/k. The Z+Z counterexample shows this case
cannot be resolved by abstract model surgery alone. A chronicle-specific argument
(showing constant MCS implies the succ-orbit covers the entire domain) is needed.
This case has a sorry pending resolution.
-/

/--
Helper: if `ψ ∈ limit_f(y)` and `x < y`, then `F(ψ) ∈ limit_f(x)`.
More precisely, `some_future ψ ∈ limit_f(x)`.

Proof by contradiction using C4. If `F(ψ) ∉ limit_f(x)`, then `¬F(ψ) = (U(ψ, ⊤)).neg
∈ limit_f(x)`. By C4 with event `ψ` at `y` and guard `⊤`, we get `z` with
`x < z < y` and `⊤.neg ∈ limit_f(z)`, i.e., `⊥ ∈ limit_f(z)`. But `⊥` is never in
an MCS. Contradiction.
-/
private theorem limit_f_some_future_of_lt (fc : FrameClass) (A : Set Formula)
    (h_mcs : SetMaximalConsistent (fc := fc) A)
    (x y : Rat) (hx : x ∈ limit_dom fc A h_mcs) (hy : y ∈ limit_dom fc A h_mcs)
    (hxy : x < y) (ψ : Formula) (hψ : ψ ∈ limit_f fc A h_mcs y) :
    Formula.some_future ψ ∈ limit_f fc A h_mcs x := by
  by_contra h_neg
  have h_mcs_x := limit_c0 fc A h_mcs x hx
  have h_neg_F : (Formula.some_future ψ).neg ∈ limit_f fc A h_mcs x :=
    (SetMaximalConsistent.negation_complete h_mcs_x _).resolve_left h_neg
  -- some_future ψ = U(ψ, ⊤). So (some_future ψ).neg = (U(ψ, ⊤)).neg
  -- C4 with η = ψ, ξ = ⊤: ¬U(ψ,⊤) ∈ f(x) and ψ ∈ f(y) gives z with ⊤.neg ∈ f(z)
  -- Use change to make the types match exactly
  set top := Formula.bot.imp Formula.bot with htop_def
  have h_neg_until : (Formula.untl ψ top).neg ∈ limit_f fc A h_mcs x := h_neg_F
  obtain ⟨z, hz, _, _, h_top_neg⟩ :=
    limit_satisfies_c4 fc A h_mcs x y hx hy hxy top ψ h_neg_until hψ
  -- ⊤.neg = (⊥ → ⊥).neg ∈ f(z). But ⊤ = ⊥ → ⊥ is in every MCS.
  have h_mcs_z := limit_c0 fc A h_mcs z hz
  have h_top_in : top ∈ limit_f fc A h_mcs z :=
    theorem_in_mcs h_mcs_z (identity Formula.bot)
  exact set_consistent_not_both h_mcs_z.1 top h_top_in h_top_neg

/--
Helper: if `ψ ∈ limit_f(y)` and `x < y`, then `G(ψ.neg) ∉ limit_f(x)`.
Contrapositive of `limit_forward_G`: if `G(ψ.neg) ∈ limit_f(x)` and `x < y`,
then `ψ.neg ∈ limit_f(y)`, contradicting `ψ ∈ limit_f(y)`.
-/
private theorem limit_f_not_G_neg_of_mem (fc : FrameClass) (A : Set Formula)
    (h_mcs : SetMaximalConsistent (fc := fc) A)
    (x y : Rat) (hx : x ∈ limit_dom fc A h_mcs) (hy : y ∈ limit_dom fc A h_mcs)
    (hxy : x < y) (ψ : Formula) (hψ : ψ ∈ limit_f fc A h_mcs y) :
    Formula.all_future ψ.neg ∉ limit_f fc A h_mcs x := by
  intro h_G_neg
  have h_neg_y := limit_forward_G fc A h_mcs x y hx hy hxy ψ.neg h_G_neg
  exact SetMaximalConsistent.neg_excludes (limit_c0 fc A h_mcs y hy) ψ h_neg_y hψ

/--
**Core gap elimination**: If the chronicle domain has a bounded successor orbit,
derive a contradiction.

**Status**: SORRY. Extensive analysis (6 approaches tried) shows this is
a genuinely difficult theorem requiring a novel proof technique. The approaches
investigated and their failure modes are recorded below.

**Approaches investigated and their failure modes**:
1. Model surgery via contemp_equiv: Trivially true for bounded intervals at any
   EF-game depth k (confirmed by research).
2. Stage induction via succ_reaches_dom_N: Boundary cases irresolvable (limit-level
   successor may not appear until arbitrarily later stage).
3. Z1 direct instantiation: Orbit membership is second-order, not expressible as
   a temporal formula. G(Gψ→ψ) unverifiable for distinguishing formulas at gap
   boundary points.
4. Pred/succ cancellation descent: Circular (requires IsPredArchimedean = IsSuccArchimedean).
5. Dom(N) stage counting: Gives succ^K(a) ≤ b but not ≥ b (orbit may advance slower
   than dom(N) spacing due to intermediate insertions).
6. Boneyard expressive completeness approach: Requires semantic Prior-UZ/SZ for
   orbit-membership structure, which is the gap this theorem is trying to fill.

**Helper lemmas added**: `limit_f_some_future_of_lt` and `limit_f_not_G_neg_of_mem`
(both sorry-free) provide F(ψ) ∈ limit_f(x) from ψ ∈ limit_f(y) when x < y, and
the contrapositive of limit_forward_G.

**What is needed**: A proof technique that either (a) expresses orbit membership
in the temporal language (possibly using Reynolds expressive completeness with a
different structure), (b) uses the chronicle construction's enumeration directly
to show the orbit reaches b, or (c) bypasses chronicle_gap_contradiction entirely
via Strategy B (completing ReynoldsBridge.lean:489).
-/
private theorem chronicle_gap_contradiction (fc : FrameClass) (A : Set Formula)
    (h_mcs : SetMaximalConsistent (fc := fc) A)
    (h_fc : FrameClass.Discrete ≤ fc)
    (h_discrete : ∀ x ∈ limit_dom fc A h_mcs, next_top ∈ limit_f fc A h_mcs x)
    (a b : LimitDomSubtype fc A h_mcs) (hab : a < b)
    (h_orbit_bounded : ∀ n : ℕ,
      (limitDomSubtype_succ fc A h_mcs h_discrete)^[n] a < b) :
    False := by
  sorry

/-  OLD PROOF (blocked by import cycle, replaced above):
  letI : SuccOrder (LimitDomSubtype fc A h_mcs) :=
    limitDomSubtype_succOrder fc A h_mcs h_discrete
  letI : PredOrder (LimitDomSubtype fc A h_mcs) :=
    limitDomSubtype_predOrder fc A h_mcs h_discrete
  -- Case split on whether limit_f distinguishes a and b
  by_cases h_mcs_eq : limit_f fc A h_mcs a.val = limit_f fc A h_mcs b.val
  · -- Case B: constant MCS at a and b. Chronicle-specific argument needed.
    -- The Z+Z counterexample shows this cannot be resolved by abstract
    -- model surgery. A proof that constant MCS + chronicle structure implies
    -- the succ-orbit covers the domain (making this case vacuously false)
    -- requires induction on the omega-chain construction.
    sorry
  · -- Case A: limit_f differs at a and b. Pick a distinguishing formula.
    -- There exists ψ in the symmetric difference of limit_f(a.val) and limit_f(b.val).
    -- h_mcs_eq : ¬(limit_f ... a.val = limit_f ... b.val), i.e., the sets differ
    have h_ne : ∃ ψ, ψ ∈ limit_f fc A h_mcs a.val ∧ ψ ∉ limit_f fc A h_mcs b.val ∨
        ψ ∈ limit_f fc A h_mcs b.val ∧ ψ ∉ limit_f fc A h_mcs a.val := by
      by_contra h_all
      push_neg at h_all
      exact h_mcs_eq (Set.eq_of_subset_of_subset
        (fun x hx => by_contra h; exact (h_all x).1 hx h)
        (fun x hx => by_contra h; exact (h_all x).2 hx h))
    -- Build a single-predicate OrderedMonadicStructure on LimitDomSubtype.
    -- sig has one predicate; interp maps that predicate to ψ-membership.
    -- The signature: a single predicate p₀
    let sig : Bimodal.Metalogic.WeakCanonical.MonadicSignature := {
      preds := Unit
      fintypePreds := inferInstance
      decEqPreds := inferInstance
    }
    -- Choose a ψ that distinguishes a and b, preferring ψ ∈ limit_f(a.val) \ limit_f(b.val)
    -- to ensure the class of a (where ψ holds) is bounded above by b (where ψ doesn't hold).
    obtain ⟨ψ, hψ⟩ := h_ne
    rcases hψ with ⟨hψ_in, hψ_not⟩ | ⟨hψ_in, hψ_not⟩
    · -- ψ ∈ limit_f(a.val) but ψ ∉ limit_f(b.val)
      -- Build the OrderedMonadicStructure
      let M : Bimodal.Metalogic.WeakCanonical.OrderedMonadicStructure sig := {
        carrier := LimitDomSubtype fc A h_mcs
        interp := fun () x => ψ ∈ limit_f fc A h_mcs x.val
        carrier_order := inferInstance
      }
      -- atomMap: maps all formulas to the single predicate
      let atomMap : Formula → sig.preds := fun _ => ()
      -- h_surj: trivially true for a single-predicate signature
      have h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p := by
        intro (); exact ⟨⟨0⟩, rfl⟩
      -- Prove semantic_prior_UZ for this structure.
      -- For any ψ' and t: if ∃ s > t, temporal_truth s ψ', then ∃ first such s.
      -- temporal_truth depends on ψ' recursively. For atoms, it's ψ-membership.
      -- The proof adapts chronicle_semantic_prior_UZ from Transfer.lean.
      -- Key: effectiveFormula maps any formula ψ' to a formula whose MCS membership
      -- equals temporal_truth M atomMap t ψ'. We define it inline.
      -- effectiveFormula for a single-pred sig: atom a ↦ ψ, bot ↦ bot, etc.
      -- The effective formula is: replace all atoms and boxes in ψ' with ψ.
      let eff : Formula → Formula := fun f => match f with
        | .atom _ => ψ | .bot => .bot
        | .imp f₁ f₂ => .imp (eff f₁) (eff f₂)
        | .box _ => ψ  -- box maps to the single predicate too
        | .untl f₁ f₂ => .untl (eff f₁) (eff f₂)
        | .snce f₁ f₂ => .snce (eff f₁) (eff f₂)
      -- We need: temporal_truth M atomMap t f ↔ eff(f) ∈ limit_f(t.val)
      -- This requires a nontrivial proof by induction on f, using C4/C5.
      -- For the MCS bridge: eff(f) ∈ limit_f(t.val) is governed by the MCS properties.
      -- The proof of semantic_prior_UZ then follows the Transfer.lean pattern:
      --   temporal_truth t ψ' → eff(ψ') ∈ fmcs(t) → F(eff(ψ')) ∈ fmcs(t)
      --   → U(eff(ψ'), eff(ψ').neg) ∈ fmcs(t) [by Prior-UZ axiom]
      --   → C5 gives first witness → convert back to temporal_truth
      --
      -- This is a substantial inline proof. For now, we use the direct approach:
      -- since limit_f(a.val) ≠ limit_f(b.val) and ψ distinguishes them,
      -- we know a and b are NOT contemp_equiv at k=0 (0-equiv checks only
      -- predicate agreement, not quantifier depth). Then no_gaps_discrete_model_surgery
      -- gives ∃ boundary at successor, contradicting no_boundary_at_successor.
      --
      -- Actually, we can bypass semantic_prior_UZ entirely: we only need
      -- no_boundary_at_successor (which doesn't require prior_UZ/SZ) to get succ-closure,
      -- then gap_contradicts_prior (which does require prior_UZ/SZ).
      -- So we DO need semantic_prior_UZ/SZ. Let's prove it.
      --
      -- The proof follows the chronicle_semantic_prior_UZ pattern but operates on
      -- the raw limit_f/limit_c0/limit_satisfies_c5_strong/limit_satisfies_c4 directly.
      have h_temporal_truth_eff : ∀ (t : LimitDomSubtype fc A h_mcs) (f : Formula),
          Bimodal.Metalogic.WeakCanonical.temporal_truth M atomMap t f ↔
          eff f ∈ limit_f fc A h_mcs t.val := by
        intro t f
        induction f generalizing t with
        | atom _ => show (ψ ∈ limit_f fc A h_mcs t.val) ↔ (ψ ∈ limit_f fc A h_mcs t.val); exact Iff.rfl
        | bot =>
          constructor
          · exact False.elim
          · intro h; exact absurd h (bot_not_in_mcs (limit_c0 fc A h_mcs t.val t.property))
        | imp f₁ f₂ ih₁ ih₂ =>
          simp only [Bimodal.Metalogic.WeakCanonical.temporal_truth, eff]
          rw [ih₁ t, ih₂ t]
          exact (Bimodal.Metalogic.BXCanonical.imp_iff_mcs (limit_c0 fc A h_mcs t.val t.property) _ _).symm
        | box _ => show (ψ ∈ limit_f fc A h_mcs t.val) ↔ (ψ ∈ limit_f fc A h_mcs t.val); exact Iff.rfl
        | untl f₁ f₂ ih₁ ih₂ =>
          simp only [Bimodal.Metalogic.WeakCanonical.temporal_truth, eff]
          constructor
          · -- Forward: temporal Until → MCS Until
            intro ⟨s, hts, hf₁s, h_guard⟩
            have h₁ : eff f₁ ∈ limit_f fc A h_mcs s.val := (ih₁ s).mp hf₁s
            have h₂ : ∀ r : LimitDomSubtype fc A h_mcs, t < r → r < s →
                eff f₂ ∈ limit_f fc A h_mcs r.val :=
              fun r htr hrs => (ih₂ r).mp (h_guard r htr hrs)
            by_contra h_neg
            have h_neg_until : (Formula.untl (eff f₁) (eff f₂)).neg ∈
                limit_f fc A h_mcs t.val :=
              (SetMaximalConsistent.negation_complete
                (limit_c0 fc A h_mcs t.val t.property) _).resolve_left h_neg
            obtain ⟨z, hz, htz, hzs, h_neg_guard⟩ :=
              limit_satisfies_c4 fc A h_mcs t.val s.val t.property s.property hts
                (eff f₂) (eff f₁) h_neg_until h₁
            exact absurd (h₂ ⟨z, hz⟩ htz hzs)
              (SetMaximalConsistent.neg_excludes (limit_c0 fc A h_mcs z hz) _ h_neg_guard)
          · -- Backward: MCS Until → temporal Until
            intro h_until
            obtain ⟨y, hy, hty, hf₁y, h_guard⟩ :=
              limit_satisfies_c5_strong fc A h_mcs t.val t.property (eff f₂) (eff f₁) h_until
            exact ⟨⟨y, hy⟩, hty, (ih₁ ⟨y, hy⟩).mpr hf₁y,
              fun r htr hrs => (ih₂ r).mpr (h_guard r.val r.property htr hrs)⟩
        | snce f₁ f₂ ih₁ ih₂ =>
          simp only [Bimodal.Metalogic.WeakCanonical.temporal_truth, eff]
          constructor
          · -- Forward: temporal Since → MCS Since
            intro ⟨s, hst, hf₁s, h_guard⟩
            have h₁ : eff f₁ ∈ limit_f fc A h_mcs s.val := (ih₁ s).mp hf₁s
            have h₂ : ∀ r : LimitDomSubtype fc A h_mcs, s < r → r < t →
                eff f₂ ∈ limit_f fc A h_mcs r.val :=
              fun r hsr hrt => (ih₂ r).mp (h_guard r hsr hrt)
            by_contra h_neg
            have h_neg_since : (Formula.snce (eff f₁) (eff f₂)).neg ∈
                limit_f fc A h_mcs t.val :=
              (SetMaximalConsistent.negation_complete
                (limit_c0 fc A h_mcs t.val t.property) _).resolve_left h_neg
            obtain ⟨z, hz, hsz, hzt, h_neg_guard⟩ :=
              limit_satisfies_c4' fc A h_mcs t.val s.val t.property s.property hst
                (eff f₂) (eff f₁) h_neg_since h₁
            exact absurd (h₂ ⟨z, hz⟩ hsz hzt)
              (SetMaximalConsistent.neg_excludes (limit_c0 fc A h_mcs z hz) _ h_neg_guard)
          · -- Backward: MCS Since → temporal Since
            intro h_since
            obtain ⟨y, hy, hyt, hf₁y, h_guard⟩ :=
              limit_satisfies_c5'_strong fc A h_mcs t.val t.property (eff f₂) (eff f₁) h_since
            exact ⟨⟨y, hy⟩, hyt, (ih₁ ⟨y, hy⟩).mpr hf₁y,
              fun r hsr hrt => (ih₂ r).mpr (h_guard r.val r.property hsr hrt)⟩
      -- Now prove semantic_prior_UZ
      have h_prior_UZ : Bimodal.Metalogic.WeakCanonical.semantic_prior_UZ M atomMap := by
        intro t ψ' ⟨s, hts, h_ψ_s⟩
        let eff_ψ := eff ψ'
        have h_eff_s : eff_ψ ∈ limit_f fc A h_mcs s.val :=
          (h_temporal_truth_eff s ψ').mp h_ψ_s
        -- F(eff_ψ) ∈ fmcs(t)
        have h_F_eff : Formula.some_future eff_ψ ∈ limit_f fc A h_mcs t.val := by
          by_contra h_neg
          have h_neg_F : (Formula.some_future eff_ψ).neg ∈ limit_f fc A h_mcs t.val :=
            (SetMaximalConsistent.negation_complete (limit_c0 fc A h_mcs t.val t.property) _).resolve_left h_neg
          simp only [Formula.some_future] at h_neg_F
          obtain ⟨z, hz, htz, hzs, h_neg_top⟩ :=
            limit_satisfies_c4 fc A h_mcs t.val s.val t.property s.property hts _ _ h_neg_F h_eff_s
          have h_top : Formula.imp Formula.bot Formula.bot ∈ limit_f fc A h_mcs z :=
            (Bimodal.Metalogic.BXCanonical.imp_iff_mcs (limit_c0 fc A h_mcs z hz) _ _).mpr (fun h => h)
          have h_bot : Formula.bot ∈ limit_f fc A h_mcs z :=
            (Bimodal.Metalogic.BXCanonical.imp_iff_mcs (limit_c0 fc A h_mcs z hz) _ _).mp h_neg_top h_top
          exact absurd h_bot (bot_not_in_mcs (limit_c0 fc A h_mcs z hz))
        -- Prior-UZ axiom: F(eff_ψ) → U(eff_ψ, ¬eff_ψ) in every MCS
        have h_prior := theorem_in_mcs (limit_c0 fc A h_mcs t.val t.property)
          (DerivationTree.axiom [] _ (Axiom.prior_UZ eff_ψ) h_fc)
        have h_until : Formula.untl eff_ψ eff_ψ.neg ∈ limit_f fc A h_mcs t.val :=
          (Bimodal.Metalogic.BXCanonical.imp_iff_mcs (limit_c0 fc A h_mcs t.val t.property) _ _).mp h_prior h_F_eff
        -- C5 forward
        obtain ⟨s', hs', hts', h_eff_s', h_guard⟩ :=
          limit_satisfies_c5_strong fc A h_mcs t.val t.property eff_ψ.neg eff_ψ h_until
        refine ⟨⟨s', hs'⟩, hts', ?_, ?_⟩
        · exact (h_temporal_truth_eff ⟨s', hs'⟩ ψ').mpr h_eff_s'
        · intro r htr hrs
          simp only [Formula.neg, Bimodal.Metalogic.WeakCanonical.temporal_truth]
          intro h_ψ_r
          have h_eff_r : eff_ψ ∈ limit_f fc A h_mcs r.val :=
            (h_temporal_truth_eff r ψ').mp h_ψ_r
          exact absurd h_eff_r
            (SetMaximalConsistent.neg_excludes (limit_c0 fc A h_mcs r.val r.property) _ (h_guard r.val r.property htr hrs))
      -- Prove semantic_prior_SZ (symmetric)
      have h_prior_SZ : Bimodal.Metalogic.WeakCanonical.semantic_prior_SZ M atomMap := by
        intro t ψ' ⟨s, hst, h_ψ_s⟩
        let eff_ψ := eff ψ'
        have h_eff_s : eff_ψ ∈ limit_f fc A h_mcs s.val :=
          (h_temporal_truth_eff s ψ').mp h_ψ_s
        have h_P_eff : Formula.some_past eff_ψ ∈ limit_f fc A h_mcs t.val := by
          by_contra h_neg
          have h_neg_P : (Formula.some_past eff_ψ).neg ∈ limit_f fc A h_mcs t.val :=
            (SetMaximalConsistent.negation_complete (limit_c0 fc A h_mcs t.val t.property) _).resolve_left h_neg
          simp only [Formula.some_past] at h_neg_P
          obtain ⟨z, hz, hsz, hzt, h_neg_top⟩ :=
            limit_satisfies_c4' fc A h_mcs t.val s.val t.property s.property hst _ _ h_neg_P h_eff_s
          have h_top : Formula.imp Formula.bot Formula.bot ∈ limit_f fc A h_mcs z :=
            (Bimodal.Metalogic.BXCanonical.imp_iff_mcs (limit_c0 fc A h_mcs z hz) _ _).mpr (fun h => h)
          have h_bot : Formula.bot ∈ limit_f fc A h_mcs z :=
            (Bimodal.Metalogic.BXCanonical.imp_iff_mcs (limit_c0 fc A h_mcs z hz) _ _).mp h_neg_top h_top
          exact absurd h_bot (bot_not_in_mcs (limit_c0 fc A h_mcs z hz))
        have h_prior := theorem_in_mcs (limit_c0 fc A h_mcs t.val t.property)
          (DerivationTree.axiom [] _ (Axiom.prior_SZ eff_ψ) h_fc)
        have h_since : Formula.snce eff_ψ eff_ψ.neg ∈ limit_f fc A h_mcs t.val :=
          (Bimodal.Metalogic.BXCanonical.imp_iff_mcs (limit_c0 fc A h_mcs t.val t.property) _ _).mp h_prior h_P_eff
        obtain ⟨s', hs', hst', h_eff_s', h_guard⟩ :=
          limit_satisfies_c5'_strong fc A h_mcs t.val t.property eff_ψ.neg eff_ψ h_since
        refine ⟨⟨s', hs'⟩, hst', ?_, ?_⟩
        · exact (h_temporal_truth_eff ⟨s', hs'⟩ ψ').mpr h_eff_s'
        · intro r hsr hrt
          simp only [Formula.neg, Bimodal.Metalogic.WeakCanonical.temporal_truth]
          intro h_ψ_r
          have h_eff_r : eff_ψ ∈ limit_f fc A h_mcs r.val :=
            (h_temporal_truth_eff r ψ').mp h_ψ_r
          exact absurd h_eff_r
            (SetMaximalConsistent.neg_excludes (limit_c0 fc A h_mcs r.val r.property) _ (h_guard r.val r.property hsr hrt))
      -- Succ-closure: class of a is succ-closed by no_boundary_at_successor + transitivity
      have h_succ_closed : ∀ c, Bimodal.Metalogic.WeakCanonical.contemp_equiv sig 0 M a c →
          Bimodal.Metalogic.WeakCanonical.contemp_equiv sig 0 M a (Order.succ c) :=
        fun c hac => (Bimodal.Metalogic.WeakCanonical.contemp_equiv_is_equiv sig 0 M).trans hac
          (Bimodal.Metalogic.WeakCanonical.no_boundary_at_successor sig 0 M c)
      -- Bounded above: b is NOT in a's class (ψ distinguishes them at k=0)
      have h_not_equiv_ab : ¬ Bimodal.Metalogic.WeakCanonical.contemp_equiv sig 0 M a b := by
        intro h_equiv
        -- contemp_equiv at k=0 means all subintervals have the same 0-type.
        -- In particular, the structure at a and b must agree on all predicates.
        -- Since sig has one predicate (ψ membership), a and b must both have ψ
        -- or both lack ψ. But ψ ∈ limit_f(a.val) and ψ ∉ limit_f(b.val).
        -- The 0-equivalence implies identical predicate assignments.
        simp only [Bimodal.Metalogic.WeakCanonical.contemp_equiv] at h_equiv
        -- The subinterval [min(a,b), max(a,b)] = [a, b] has good(0) for M.
        -- Good at depth 0 means all pairs of elements in [a,b] have the same
        -- predicate values. Since a, b ∈ [a, b], interp () a = interp () b.
        -- But interp () a = (ψ ∈ limit_f(a.val)) = True and
        --     interp () b = (ψ ∈ limit_f(b.val)) = False.
        have hab_le := le_of_lt hab
        rw [min_eq_left hab_le, max_eq_right hab_le] at h_equiv
        have h_good := h_equiv a b ⟨le_refl a, hab_le⟩
        -- h_good : good sig 0 (M.subinterval sig a b)
        -- At depth 0, good means for any two elements c, d of the subinterval,
        -- M.subinterval.interp p c = M.subinterval.interp p d.
        -- The subinterval has carrier = {x | a ≤ x ∧ x ≤ b}.
        -- We need elements: ⟨a, ⟨le_refl, hab_le⟩⟩ and ⟨b, ⟨hab_le, le_refl⟩⟩.
        -- Then M.subinterval.interp () ⟨a,...⟩ = ψ ∈ limit_f(a.val) = True
        --  and M.subinterval.interp () ⟨b,...⟩ = ψ ∈ limit_f(b.val) = False.
        -- good at 0 should give these are equal, contradiction.
        -- Actually, good(0) only says k_equiv depth 0, which requires
        -- evaluating all sentences of quantifier depth 0. A sentence of depth 0
        -- is a Boolean combination of atoms. The atoms are the predicates applied
        -- to the (0 free) variables -- but there are no free variables in a sentence!
        -- So depth 0 is about closed formulas, which don't reference specific elements.
        -- This means good(0) is trivially true. We need k ≥ 1!
        -- Let me use k = 1 instead.
        sorry
      -- Apply gap_contradicts_prior
      exact Bimodal.Metalogic.WeakCanonical.gap_contradicts_prior sig 0 M atomMap h_surj
        h_prior_UZ h_prior_SZ a h_succ_closed ⟨b, hab, h_not_equiv_ab⟩
    · -- ψ ∈ limit_f(b.val) but ψ ∉ limit_f(a.val)
      -- Symmetric case: b has ψ, a doesn't.
      -- The class of a (where ψ is absent) is bounded above by some point where ψ appears.
      -- Use gap_contradicts_prior_below or rearrange the argument.
      -- Actually, we can use the same argument: a's class contains points where ψ ∉ limit_f.
      -- b is NOT in a's class. Since b > a, a's class is bounded above.
      let M : Bimodal.Metalogic.WeakCanonical.OrderedMonadicStructure sig := {
        carrier := LimitDomSubtype fc A h_mcs
        interp := fun () x => ψ ∈ limit_f fc A h_mcs x.val
        carrier_order := inferInstance
      }
      let atomMap : Formula → sig.preds := fun _ => ()
      have h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p := by
        intro (); exact ⟨⟨0⟩, rfl⟩
      -- Same semantic_prior_UZ/SZ proofs apply (they don't depend on the direction)
      -- For brevity, we sorry the symmetric case and note it follows by the same pattern
      sorry
-/

/--
Succ-iterates are cofinal: for any `a < b` in `LimitDomSubtype`, there exists `n`
such that `succ^[n](a) ≥ b`. Combined with `succ_orbit_convex`, this gives
`IsSuccArchimedean`.

Proof: by contradiction using `chronicle_gap_contradiction`. If succ^[n](a) < b
for all n, then the successor orbit is bounded, creating a Dedekind cut that
contradicts Prior-SZ at the chronicle level (Reynolds Theorem 14 at chronicle level).
-/
private theorem succ_cofinal (fc : FrameClass) (A : Set Formula) (h_mcs : SetMaximalConsistent (fc := fc) A)
    (h_fc : FrameClass.Discrete ≤ fc)
    (h_discrete : ∀ x ∈ limit_dom fc A h_mcs, next_top ∈ limit_f fc A h_mcs x)
    (a b : LimitDomSubtype fc A h_mcs) (hab : a < b) :
    ∃ n, b ≤ (limitDomSubtype_succ fc A h_mcs h_discrete)^[n] a := by
  by_contra h_not_cofinal
  push_neg at h_not_cofinal
  exact chronicle_gap_contradiction fc A h_mcs h_fc h_discrete a b hab h_not_cofinal
/--
`IsSuccArchimedean` instance for `LimitDomSubtype` in the discrete case.
Uses `succ_cofinal`, which has a sorry via `chronicle_gap_contradiction`.
Compile-live: `succ_embed_surjective` binds this definition (`letI`) in its
proof — do not excise.
-/
noncomputable def limitDomSubtype_isSuccArchimedean (fc : FrameClass)
    (A : Set Formula) (h_mcs : SetMaximalConsistent (fc := fc) A)
    (h_fc : FrameClass.Discrete ≤ fc)
    (h_discrete : ∀ x ∈ limit_dom fc A h_mcs, next_top ∈ limit_f fc A h_mcs x) :
    @IsSuccArchimedean (LimitDomSubtype fc A h_mcs)
      inferInstance
      (limitDomSubtype_succOrder fc A h_mcs h_discrete) :=
  @IsSuccArchimedean.mk _ _ (limitDomSubtype_succOrder fc A h_mcs h_discrete) <| by
    intro a b hab
    change ∃ n, (limitDomSubtype_succ fc A h_mcs h_discrete)^[n] a = b
    set s := limitDomSubtype_succ fc A h_mcs h_discrete
    rcases eq_or_lt_of_le hab with rfl | hab_lt
    · exact ⟨0, rfl⟩
    · -- a < b. By succ_cofinal: ∃ n, b ≤ s^[n](a).
      obtain ⟨n, hn⟩ := succ_cofinal fc A h_mcs h_fc h_discrete a b hab_lt
      -- By succ_orbit_convex: ∃ j ≤ n, s^[j](a) = b.
      exact (succ_orbit_convex fc A h_mcs h_discrete a b n (le_of_lt hab_lt) hn).imp
        fun j ⟨_, hj⟩ => hj

/- ============================================================================
   SOURCE: Theories/Bimodal/Metalogic/BXCanonical/Chronicle/ChronicleToCountermodel.lean
   Declaration: succ_embed_surjective
   ============================================================================ -/

/--
Surjectivity of `succ_embed`: every point in `LimitDomSubtype` is an embedded point.

Uses `IsSuccArchimedean` for `LimitDomSubtype`: given any `w`, we split on
`root ≤ w` vs `w < root` and apply `exists_succ_iterate_of_le` to get `n` with
`Order.succ^[n] root = w` (or `Order.succ^[n] w = root` for the negative case).
Since `Order.succ = limitDomSubtype_succ` (definitional equality from
`SuccOrder.ofSuccLeIff`), this gives `succ_embed n = w` via the correspondence
between `succ^[n](root)` and `succ_embed(n)`.
-/
theorem succ_embed_surjective (fc : FrameClass) (A : Set Formula) (h_mcs : SetMaximalConsistent (fc := fc) A)
    (h_fc : FrameClass.Discrete ≤ fc)
    (h_discrete : ∀ x ∈ limit_dom fc A h_mcs, next_top ∈ limit_f fc A h_mcs x)
    (w : LimitDomSubtype fc A h_mcs) :
    ∃ n : ℤ, succ_embed fc A h_mcs h_discrete n = w := by
  letI succOrd := limitDomSubtype_succOrder fc A h_mcs h_discrete
  letI predOrd := limitDomSubtype_predOrder fc A h_mcs h_discrete
  letI := limitDomSubtype_isSuccArchimedean fc A h_mcs h_fc h_discrete
  set root : LimitDomSubtype fc A h_mcs := ⟨0, zero_mem_limit_dom fc A h_mcs⟩
  set s := limitDomSubtype_succ fc A h_mcs h_discrete
  set p := limitDomSubtype_pred fc A h_mcs h_discrete
  -- Helper: succ_embed(n) = s^[n](root) for n ≥ 0
  have h_succ_embed_nat : ∀ (n : ℕ),
      succ_embed fc A h_mcs h_discrete (↑n) = s^[n] root := by
    intro n; unfold succ_embed; simp [Int.toNat_natCast]; rfl
  -- Helper: succ_embed(-n) = p^[n](root) for n ≥ 0
  have h_succ_embed_neg : ∀ (n : ℕ),
      succ_embed fc A h_mcs h_discrete (-(↑n)) = p^[n] root := by
    intro n
    unfold succ_embed
    cases n with
    | zero => simp; rfl
    | succ n =>
      simp only [Nat.cast_succ, show ¬(0 ≤ -(↑(n + 1) : ℤ)) from by omega, dite_false]
      congr 1
  -- Case split: root ≤ w or w < root
  rcases le_or_gt root w with h_le | h_gt
  · -- Case root ≤ w: use IsSuccArchimedean to get n with succ^[n](root) = w
    obtain ⟨n, hn⟩ := exists_succ_iterate_of_le h_le
    -- Order.succ^[n] root = w, and Order.succ = s (definitional)
    exact ⟨↑n, by rw [h_succ_embed_nat]; exact hn⟩
  · -- Case w < root: use IsSuccArchimedean on w ≤ root to get n with succ^[n](w) = root
    obtain ⟨n, hn⟩ := exists_succ_iterate_of_le h_gt.le
    -- succ^[n](w) = root, so w = pred^[n](root) = succ_embed(-n)
    -- We need to show: w = pred^[n](root)
    -- Proof: succ^[n](w) = root. Apply pred^[n] to both sides.
    -- pred^[n](succ^[n](w)) = w (by pred_succ cancellation iterated)
    -- pred^[n](root) = succ_embed(-n)
    have h_w_eq : w = p^[n] root := by
      -- pred^[n](succ^[n](w)) = w, and succ^[n](w) = root, so w = pred^[n](root)
      suffices h_cancel : ∀ (m : ℕ) (x : LimitDomSubtype fc A h_mcs),
          (limitDomSubtype_pred fc A h_mcs h_discrete)^[m]
            ((limitDomSubtype_succ fc A h_mcs h_discrete)^[m] x) = x by
        rw [← hn]; exact (h_cancel n w).symm
      intro m x
      induction m with
      | zero => rfl
      | succ m ih =>
        -- pred^[m+1](succ^[m+1](x)) = pred^[m+1](succ(succ^[m](x)))
        -- = pred(pred^[m](succ(succ^[m](x))))
        -- We want: pred^[m](succ(succ^[m](x))) = succ^[m](x)... not quite
        -- Better: use pred_succ cancellation first, then IH
        -- pred^[m+1](succ^[m+1](x))
        -- = pred^[m](pred(succ(succ^[m](x))))  [unfold outer pred]
        -- = pred^[m](succ^[m](x))  [by pred_succ]
        -- = x  [by IH]
        conv_lhs =>
          rw [Function.iterate_succ_apply'
            (limitDomSubtype_succ fc A h_mcs h_discrete) m x]
        -- Now the succ part is: succ(succ^[m](x))
        -- And pred^[m+1] of that
        rw [show (limitDomSubtype_pred fc A h_mcs h_discrete)^[m + 1] =
          (limitDomSubtype_pred fc A h_mcs h_discrete)^[m] ∘
            (limitDomSubtype_pred fc A h_mcs h_discrete) from
            (Function.iterate_succ (limitDomSubtype_pred fc A h_mcs h_discrete) m).symm]
        simp only [Function.comp_apply]
        rw [limitDomSubtype_pred_succ fc A h_mcs h_discrete
          ((limitDomSubtype_succ fc A h_mcs h_discrete)^[m] x)]
        exact ih
    exact ⟨-(↑n), by rw [h_succ_embed_neg]; exact h_w_eq.symm⟩

/- ============================================================================
   SOURCE: Theories/Bimodal/Metalogic/BXCanonical/Chronicle/ChronicleToCountermodel.lean
   Declarations: cantor_bfmcs_discrete_restricted_tc, cantor_bfmcs_discrete_restricted_fuc
   ============================================================================ -/

/--
Restricted temporal coherence for `cantor_bfmcs_discrete`.
F(phi) ∈ fam.mcs(t) → ∃ s > t, phi ∈ fam.mcs(s) and symmetric for P.

Uses `succ_embed_surjective` to map `limit_F_resolution` / `limit_P_resolution`
witnesses back to integers. The surjectivity lemma guarantees that every domain
point corresponds to an embedded integer, enabling the same proof pattern as
the dense case (which uses the Cantor isomorphism for the same purpose).
-/
theorem cantor_bfmcs_discrete_restricted_tc (fc : FrameClass) (A : Set Formula) (h_mcs : SetMaximalConsistent (fc := fc) A)
    (h_fc : FrameClass.Discrete ≤ fc)
    (h_box_discrete : Formula.box next_top ∈ A)
    (root : Formula)
    (_ : ∀ ψ, ψ ∈ deferralClosure root → ψ ∈ (extendedDeferralClosure root).toList) :
    (cantor_bfmcs_discrete fc A h_mcs h_box_discrete).restricted_temporally_coherent root := by
  intro fam hfam
  obtain ⟨N, h_N, h_box_N, s, h_eqN, rfl⟩ := hfam
  set h_discrete_N := box_discrete_gives_discreteness fc N h_N h_box_N
  set offset := (-s : ℤ)
  have h_mcs_eq : ∀ t : ℤ, (rooted_succ_discrete_fmcs fc N h_N h_box_N s).mcs t =
      limit_f fc N h_N (succ_embed fc N h_N h_discrete_N (t + offset)).val := by
    intro t; rfl
  constructor
  · -- Forward F direction: F(φ) ∈ fam.mcs(t) → ∃ s > t, φ ∈ fam.mcs(s)
    intro t φ _ h_F
    rw [h_mcs_eq] at h_F
    obtain ⟨y, hy, hlt, hφy⟩ := limit_F_resolution fc N h_N
      (succ_embed fc N h_N h_discrete_N (t + offset)).val
      (succ_embed fc N h_N h_discrete_N (t + offset)).property φ h_F
    obtain ⟨m, hm⟩ := succ_embed_surjective fc N h_N h_fc h_discrete_N ⟨y, hy⟩
    refine ⟨m - offset, ?_, ?_⟩
    · have h_lt' : succ_embed fc N h_N h_discrete_N (t + offset) <
          succ_embed fc N h_N h_discrete_N m := hm ▸ hlt
      have := succ_embed_strictMono fc N h_N h_discrete_N |>.lt_iff_lt.mp h_lt'
      omega
    · rw [h_mcs_eq, show m - offset + offset = m from by omega]
      show φ ∈ limit_f fc N h_N (succ_embed fc N h_N h_discrete_N m).val
      rw [show (succ_embed fc N h_N h_discrete_N m).val = y from congrArg Subtype.val hm]
      exact hφy
  · -- Backward P direction: P(φ) ∈ fam.mcs(t) → ∃ s < t, φ ∈ fam.mcs(s)
    intro t φ _ h_P
    rw [h_mcs_eq] at h_P
    obtain ⟨y, hy, hlt, hφy⟩ := limit_P_resolution fc N h_N
      (succ_embed fc N h_N h_discrete_N (t + offset)).val
      (succ_embed fc N h_N h_discrete_N (t + offset)).property φ h_P
    obtain ⟨m, hm⟩ := succ_embed_surjective fc N h_N h_fc h_discrete_N ⟨y, hy⟩
    refine ⟨m - offset, ?_, ?_⟩
    · have h_lt' : succ_embed fc N h_N h_discrete_N m <
          succ_embed fc N h_N h_discrete_N (t + offset) := hm ▸ hlt
      have := succ_embed_strictMono fc N h_N h_discrete_N |>.lt_iff_lt.mp h_lt'
      omega
    · rw [h_mcs_eq, show m - offset + offset = m from by omega]
      show φ ∈ limit_f fc N h_N (succ_embed fc N h_N h_discrete_N m).val
      rw [show (succ_embed fc N h_N h_discrete_N m).val = y from congrArg Subtype.val hm]
      exact hφy

/--
Restricted forward Until/Since coherence for `cantor_bfmcs_discrete`.
U(phi,psi) ∈ fam.mcs(t) → ∃ s > t, phi ∈ fam.mcs(s) ∧ guard(t,s).

Uses `succ_embed_surjective` to map `limit_satisfies_c5_strong` / `c5'_strong`
witnesses back to integers. The guard transfers via `succ_embed_squeeze_strict`:
any integer between t and s maps to a domain point between the source and witness,
which is covered by the C5 guard.
-/
theorem cantor_bfmcs_discrete_restricted_fuc (fc : FrameClass) (A : Set Formula) (h_mcs : SetMaximalConsistent (fc := fc) A)
    (h_fc : FrameClass.Discrete ≤ fc) (h_box_discrete : Formula.box next_top ∈ A) (root : Formula) :
    (cantor_bfmcs_discrete fc A h_mcs h_box_discrete).restricted_forward_until_since_coherent root := by
  intro fam hfam
  obtain ⟨N, h_N, h_box_N, s, h_eqN, rfl⟩ := hfam
  set h_discrete_N := box_discrete_gives_discreteness fc N h_N h_box_N
  set offset := (-s : ℤ)
  have h_mcs_eq : ∀ t : ℤ, (rooted_succ_discrete_fmcs fc N h_N h_box_N s).mcs t =
      limit_f fc N h_N (succ_embed fc N h_N h_discrete_N (t + offset)).val := by
    intro t; rfl
  constructor
  · -- Until forward: untl(φ,ψ) ∈ fam.mcs t → ∃ u > t, φ ∈ fam.mcs u ∧ guard
    intro t φ ψ _ h_until
    rw [h_mcs_eq] at h_until
    obtain ⟨y, hy, hxty, hφy, h_guard⟩ := limit_satisfies_c5_strong fc N h_N
      (succ_embed fc N h_N h_discrete_N (t + offset)).val
      (succ_embed fc N h_N h_discrete_N (t + offset)).property ψ φ h_until
    obtain ⟨m, hm⟩ := succ_embed_surjective fc N h_N h_fc h_discrete_N ⟨y, hy⟩
    refine ⟨m - offset, ?_, ?_, ?_⟩
    · have h_lt' : succ_embed fc N h_N h_discrete_N (t + offset) <
          succ_embed fc N h_N h_discrete_N m := hm ▸ hxty
      have := succ_embed_strictMono fc N h_N h_discrete_N |>.lt_iff_lt.mp h_lt'
      omega
    · rw [h_mcs_eq, show m - offset + offset = m from by omega]
      show φ ∈ limit_f fc N h_N (succ_embed fc N h_N h_discrete_N m).val
      rw [show (succ_embed fc N h_N h_discrete_N m).val = y from congrArg Subtype.val hm]
      exact hφy
    · -- Guard: all integers r between t and (m - offset) have ψ in their MCS.
      intro r htr hru
      rw [h_mcs_eq]
      -- r + offset is between t + offset and m, so succ_embed(r + offset) is
      -- between succ_embed(t + offset) and succ_embed(m) = ⟨y, hy⟩.
      have h_lt1 : succ_embed fc N h_N h_discrete_N (t + offset) <
          succ_embed fc N h_N h_discrete_N (r + offset) :=
        succ_embed_strictMono fc N h_N h_discrete_N (show t + offset < r + offset by omega)
      have h_lt2 : succ_embed fc N h_N h_discrete_N (r + offset) <
          succ_embed fc N h_N h_discrete_N m :=
        succ_embed_strictMono fc N h_N h_discrete_N (show r + offset < m by omega)
      have h_lt2' : (succ_embed fc N h_N h_discrete_N (r + offset)) < ⟨y, hy⟩ := by
        rw [← hm]; exact h_lt2
      exact h_guard (succ_embed fc N h_N h_discrete_N (r + offset)).val
        (succ_embed fc N h_N h_discrete_N (r + offset)).property h_lt1 h_lt2'
  · -- Since forward: snce(φ,ψ) ∈ fam.mcs t → ∃ u < t, φ ∈ fam.mcs u ∧ guard
    intro t φ ψ _ h_since
    rw [h_mcs_eq] at h_since
    obtain ⟨y, hy, hyxt, hφy, h_guard⟩ := limit_satisfies_c5'_strong fc N h_N
      (succ_embed fc N h_N h_discrete_N (t + offset)).val
      (succ_embed fc N h_N h_discrete_N (t + offset)).property ψ φ h_since
    obtain ⟨m, hm⟩ := succ_embed_surjective fc N h_N h_fc h_discrete_N ⟨y, hy⟩
    refine ⟨m - offset, ?_, ?_, ?_⟩
    · have h_lt' : succ_embed fc N h_N h_discrete_N m <
          succ_embed fc N h_N h_discrete_N (t + offset) := hm ▸ hyxt
      have := succ_embed_strictMono fc N h_N h_discrete_N |>.lt_iff_lt.mp h_lt'
      omega
    · rw [h_mcs_eq, show m - offset + offset = m from by omega]
      show φ ∈ limit_f fc N h_N (succ_embed fc N h_N h_discrete_N m).val
      rw [show (succ_embed fc N h_N h_discrete_N m).val = y from congrArg Subtype.val hm]
      exact hφy
    · -- Guard: all integers r between (m - offset) and t have ψ in their MCS.
      intro r hyr hrt
      rw [h_mcs_eq]
      have h_lt1 : (⟨y, hy⟩ : LimitDomSubtype fc N h_N) <
          succ_embed fc N h_N h_discrete_N (r + offset) := by
        rw [← hm]
        exact succ_embed_strictMono fc N h_N h_discrete_N (show m < r + offset by omega)
      have h_lt2 : succ_embed fc N h_N h_discrete_N (r + offset) <
          succ_embed fc N h_N h_discrete_N (t + offset) :=
        succ_embed_strictMono fc N h_N h_discrete_N (show r + offset < t + offset by omega)
      exact h_guard (succ_embed fc N h_N h_discrete_N (r + offset)).val
        (succ_embed fc N h_N h_discrete_N (r + offset)).property h_lt1 h_lt2

/- ============================================================================
   SOURCE: Theories/Bimodal/Metalogic/BXCanonical/Chronicle/ChronicleToCountermodel.lean
   Declaration: dd_countermodel_chronicle_discrete
   ============================================================================ -/

/-! ## Discrete Countermodel

The main integration theorem for the discrete case: constructs a countermodel
from any MCS containing neg(phi) and box(U(T,bot)), using the succ-based
chronicle construction.
-/

/--
Discrete countermodel: given MCS A with `neg(phi) in A` and `box(U(T,bot)) in A`,
build a countermodel on `Int` where `phi` is false.

Uses `cantor_bfmcs_discrete` (sorry-free BFMCS) with the three restricted
coherence conditions (BUC, TC, FUC), all proved via `succ_embed_surjective`
and `succ_embed_squeeze`/`succ_embed_squeeze_strict`. The eval family is
`rooted_succ_discrete_fmcs fc A h_mcs h_box_discrete 0` which has `mcs 0 = A`,
so `neg(phi) in eval_family.mcs 0`.
-/
theorem dd_countermodel_chronicle_discrete (fc : FrameClass) (A : Set Formula) (h_mcs : SetMaximalConsistent (fc := fc) A)
    (h_fc : FrameClass.Discrete ≤ fc)
    (φ : Formula) (h_neg_in : φ.neg ∈ A)
    (h_box_discrete : Formula.box next_top ∈ A) :
    ∃ (D : Type) (_ : AddCommGroup D) (_ : LinearOrder D) (_ : IsOrderedAddMonoid D)
      (_ : Nontrivial D) (F : TaskFrame D) (TM : TaskModel F)
      (Omega : Set (WorldHistory F)) (_ : ShiftClosed Omega)
      (τ : WorldHistory F) (_ : τ ∈ Omega) (t : D),
      ¬truth_at TM Omega τ t φ := by
  refine ⟨Int, inferInstance, inferInstance, inferInstance, inferInstance,
    ParametricCanonicalTaskFrame Int, ParametricCanonicalTaskModel Int,
    ShiftClosedParametricCanonicalOmega (cantor_bfmcs_discrete fc A h_mcs h_box_discrete),
    shiftClosedParametricCanonicalOmega_is_shift_closed _,
    parametric_to_history (rooted_succ_discrete_fmcs fc A h_mcs h_box_discrete 0),
    parametricCanonicalOmega_subset_shiftClosed _
      ⟨rooted_succ_discrete_fmcs fc A h_mcs h_box_discrete 0,
       ⟨A, h_mcs, h_box_discrete, 0, fun _ => Iff.rfl, rfl⟩, rfl⟩,
    0, ?_⟩
  have h_neg_fam : φ.neg ∈ (rooted_succ_discrete_fmcs fc A h_mcs h_box_discrete 0).mcs 0 := by
    rw [rooted_succ_discrete_fmcs_at_s]; exact h_neg_in
  exact fully_restricted_parametric_completeness_from_neg_membership
    (cantor_bfmcs_discrete fc A h_mcs h_box_discrete) φ
    (cantor_bfmcs_discrete_restricted_tc fc A h_mcs h_fc h_box_discrete φ
      (fun ψ hψ => Finset.mem_toList.mpr (deferralClosure_subset_extendedDeferralClosure φ hψ)))
    (cantor_bfmcs_discrete_restricted_buc fc A h_mcs h_box_discrete φ)
    (cantor_bfmcs_discrete_restricted_fuc fc A h_mcs h_fc h_box_discrete φ)
    φ (self_mem_subformulaClosure φ)
    (rooted_succ_discrete_fmcs fc A h_mcs h_box_discrete 0)
    ⟨A, h_mcs, h_box_discrete, 0, fun _ => Iff.rfl, rfl⟩ 0 h_neg_fam

/- ============================================================================
   SOURCE: Theories/Bimodal/Metalogic/WeakCanonical/Transfer.lean
   Declaration: countermodel_discrete_reynolds (plus its two preceding doc blocks,
   the first of which is the stale "is now sorry-free" claim)
   ============================================================================ -/

/-!
`countermodel_discrete_reynolds` is now sorry-free (task 155, plan v52).
The Z-interval-to-TaskFrame packaging sorry was resolved by using the parametric
canonical model construction directly. The Reynolds pipeline steps (chronicle →
good → Z-interval → truth_transfer) are bypassed; the countermodel uses the same
`ParametricCanonicalTaskFrame` / `ParametricCanonicalTaskModel` / `BFMCS` approach
as `countermodel_discrete_enriched` in Completeness.lean.

**Note**: The theorem's axiom dependencies still include `sorryAx` due to upstream
sorries in `cantor_bfmcs_discrete_restricted_tc` and `cantor_bfmcs_discrete_restricted_fuc`
(via `succ_embed_surjective`). These are separate issues from the packaging sorry
that was closed here.
-/

/-! ## Reynolds Pipeline: countermodel_discrete_reynolds -/

/--
Reynolds pipeline countermodel construction (sorry-free).

For any MCS A containing ¬φ and □(next_top) (discrete box-class),
constructs a countermodel on ℤ where φ is false.

**Pipeline Architecture**:
Uses the parametric canonical model construction. Given the discrete MCS A
with ¬φ ∈ A and □(next_top) ∈ A:
1. Build BFMCS bundle via `cantor_bfmcs_discrete` (box-equivalent families)
2. Construct parametric TaskFrame/TaskModel on ℤ
3. Build ShiftClosed Omega from all time-shifted families
4. Use restricted parametric truth lemma to show ¬truth_at φ

Does NOT use `IsSuccArchimedean`, `succ_cofinal`, or `dd_countermodel_chronicle_discrete`.
-/
theorem countermodel_discrete_reynolds
    (A : Set Formula)
    (h_mcs : SetMaximalConsistent (fc := FrameClass.Discrete) A)
    (φ : Formula) (h_neg_in : φ.neg ∈ A)
    (h_box_discrete : Formula.box next_top ∈ A) :
    ∃ (D : Type) (_ : AddCommGroup D) (_ : LinearOrder D) (_ : IsOrderedAddMonoid D)
      (_ : Nontrivial D) (_ : SuccOrder D) (_ : PredOrder D)
      (_ : IsSuccArchimedean D) (_ : IsPredArchimedean D)
      (F : TaskFrame D) (TM : TaskModel F)
      (Omega : Set (WorldHistory F)) (_ : ShiftClosed Omega)
      (τ : WorldHistory F) (_ : τ ∈ Omega) (t : D),
      ¬truth_at TM Omega τ t φ := by
  -- Construct BFMCS bundle and root family
  let bfmcs := Bimodal.Metalogic.BXCanonical.Chronicle.cantor_bfmcs_discrete
    FrameClass.Discrete A h_mcs h_box_discrete
  let fam₀ := Bimodal.Metalogic.BXCanonical.Chronicle.rooted_succ_discrete_fmcs
    FrameClass.Discrete A h_mcs h_box_discrete 0
  -- Package as existential with parametric canonical model
  refine ⟨ℤ, inferInstance, inferInstance, inferInstance, inferInstance,
    inferInstance, inferInstance, inferInstance, inferInstance,
    Bimodal.Metalogic.Algebraic.ParametricCanonical.ParametricCanonicalTaskFrame ℤ,
    Bimodal.Metalogic.Algebraic.ParametricTruthLemma.ParametricCanonicalTaskModel ℤ,
    Bimodal.Metalogic.Algebraic.ParametricHistory.ShiftClosedParametricCanonicalOmega bfmcs,
    Bimodal.Metalogic.Algebraic.ParametricHistory.shiftClosedParametricCanonicalOmega_is_shift_closed bfmcs,
    Bimodal.Metalogic.Algebraic.ParametricHistory.parametric_to_history fam₀,
    Bimodal.Metalogic.Algebraic.ParametricHistory.parametricCanonicalOmega_subset_shiftClosed bfmcs
      ⟨fam₀, ⟨A, h_mcs, h_box_discrete, 0, fun _ => Iff.rfl, rfl⟩, rfl⟩,
    0, ?_⟩
  -- Show φ.neg ∈ fam₀.mcs 0 (root family at origin contains ¬φ)
  have h_neg_fam : φ.neg ∈ fam₀.mcs 0 := by
    -- Two separate reasons the bare `rw` no longer fires (Lean 4.31): it cannot see
    -- through the `let`-bound `fam₀` at reducible transparency, and even once `show`
    -- exposes the definition the metavariable pattern still fails to match, because
    -- `h_mcs`'s implicit `fc` is only definitionally `FrameClass.Discrete`. Supplying
    -- the lemma's arguments explicitly removes both problems.
    show φ.neg ∈ (Bimodal.Metalogic.BXCanonical.Chronicle.rooted_succ_discrete_fmcs
      FrameClass.Discrete A h_mcs h_box_discrete 0).mcs 0
    rw [Bimodal.Metalogic.BXCanonical.Chronicle.rooted_succ_discrete_fmcs_at_s
      FrameClass.Discrete A h_mcs h_box_discrete 0]
    exact h_neg_in
  -- Apply restricted parametric truth lemma to get ¬truth_at φ
  exact Bimodal.Metalogic.Algebraic.RestrictedParametricTruthLemma.fully_restricted_parametric_completeness_from_neg_membership
    bfmcs φ
    (Bimodal.Metalogic.BXCanonical.Chronicle.cantor_bfmcs_discrete_restricted_tc
      FrameClass.Discrete A h_mcs (le_refl _) h_box_discrete φ
      (fun ψ hψ => Finset.mem_toList.mpr
        (deferralClosure_subset_extendedDeferralClosure φ hψ)))
    (Bimodal.Metalogic.BXCanonical.Chronicle.cantor_bfmcs_discrete_restricted_buc
      FrameClass.Discrete A h_mcs h_box_discrete φ)
    (Bimodal.Metalogic.BXCanonical.Chronicle.cantor_bfmcs_discrete_restricted_fuc
      FrameClass.Discrete A h_mcs (le_refl _) h_box_discrete φ)
    φ (self_mem_subformulaClosure φ)
    fam₀ ⟨A, h_mcs, h_box_discrete, 0, fun _ => Iff.rfl, rfl⟩ 0 h_neg_fam
