import Bimodal.Metalogic.WeakCanonical.Kamp.LiftPair
import Bimodal.Metalogic.WeakCanonical.Kamp.EFSatNegation

/-!
# General `∃∀`-object negation at the `∨∃∀` type (Rabinovich Prop 4.3, ¬-case, PDF p.6) — assembly

This module assembles `efSat_negation_general` (β at the `VeeExistsForall` type): the negation
`¬ efSat N env ψ` of a general `r`-free-variable `∃∀`-object realized as a `VeeExistsForall` (`∨∃∀`)
object, threading the capture hypothesis `hCapture` (never discharging it — that is Phase ζ/10P). It
is a **CONDITIONAL** orphan gated on `hCapture`, off the live import path.

## Strategy (Prop 4.3, ¬-case, p.6) and what is landed here

The De Morgan decomposition `efSat_negation_demorgan` (`EFSatNegation.lean`) gives
```
¬ efSat N env ψ ↔ (∃ p ∈ pairwiseProjections ψ, ¬ efSat N ![env p.1, env p.2.1] p.2.2)
                    ∨ ¬ efSat N ![] (existenceSentence ψ)
```
where `pairwiseProjections ψ` ranges over **all** ordered pairs `(k, l) ∈ Fin r × Fin r`. The assembly
splits this into three pair classes:

- **`k < l` (main case):** `efSat_negation_pair` gives a `VeeExistsForall sig F 2` negation object,
  lifted to arity `r` by `liftPairV` (`liftPairV_iff`, gate `k < l` from `StrictMono env`). LANDED.
- **`k > l` (redundant):** folded to its `l < k` counterpart by `pairProject_swap_efSat`. LANDED.
- **`k = l` (diagonal):** a genuine one-free-variable condition. Reduced here (`diagProject`,
  `diagProject_efSat_iff`, LANDED green) to `¬ efSat N ![env k] (diagProject ψ k)`, then negated by
  the arity-1 negation object `efSat_negation_diagonal` and lifted by `liftSingleV`
  (`liftSingleV_iff`, no order gate). LANDED lifts; the arity-1 negation object is a strategic sorry.
- **Existence sentence (`r = 0`):** negated by the arity-0 negation object `efSat_negation_existence`
  and lifted by `liftSentenceV` (`liftSentenceV_iff`, LANDED green here).

## Remaining obligations (strategic sorries — this dispatch's precise division boundary)

Two negation objects are **genuinely unmapped** in the current tree (verified by a bounded
lean-search/loogle/grep pass this dispatch): there is no arity-0 or arity-1 `VeeExistsForall`-valued
negation engine, and no reverse Prop 3.5 (`Formula → VeeExistsForall sig F 1`). The only landed
`VeeExistsForall`-valued negation is the arity-2 `prop42_efSat_negation_general ∘
vvecea2_collapse_bridge` composition (`EFSatNegation.efSat_negation_pair`). Deriving the arity-1 and
arity-0 objects is the Prop 3.5 negation-closure content at low arity, not yet built:

1. `efSat_negation_diagonal` — arity-1 negation object.
2. `efSat_negation_existence` — arity-0 negation object.
3. `efSat_negation_general` — the trichotomy assembly over `pairwiseProjections` chaining
   `veeSat_append`/`veeSat_flatMap` + the three class lemmas + the `k > l` symmetry fold + the
   `efSat_negation_demorgan` decomposition, consuming 1 and 2.

## References

- Rabinovich, *A Proof of Kamp's Theorem* (2014), Prop 4.3 ¬-case (PDF p.6), Prop 3.5 (p.5). Cited by
  PDF page; the companion markdown transcription is corrupt.
- `EFSatNegation.lean`: `efSat_negation_pair`, `efSat_negation_demorgan`, `pairProject_swap_efSat`.
- `LiftPair.lean`: `liftPairV`/`liftPairV_iff`, `liftSingleV`/`liftSingleV_iff`,
  `liftSentence`/`liftSentence_iff`.
- `Prop35Assembly.lean` / `Prop35ExistsForall.lean` / `Prop35VeeLift.lean`: the forward Prop 3.5
  translation (`translateProp35_correct`, arity 1) — the reverse of which the arity-1 negation object
  requires.

OFF the live import path: nothing here is imported by `KampPrior.lean` or the completeness spine.
-/

namespace Bimodal.Metalogic.WeakCanonical.Kamp

open Bimodal.Syntax (Formula Atom)
open Bimodal.Metalogic.WeakCanonical

variable {sig : MonadicSignature} {F : Finset Formula}

/-! ## 1. Diagonal reduction: the `k = l` projection is a one-free-variable object (LANDED green) -/

/-- The **arity-1 diagonal projection** of an `∃∀`-formula `ψ` at free variable `k`: the same ordered
chain, point types, and interval types, pinning `ψ`'s single free variable to `x_{ψ.pin k}`. It is the
one-free-variable object underlying the `k = l` diagonal of `pairwiseProjections`: `pairProject ψ k k`
duplicates one pin, so its content is genuinely one-free-variable. -/
def diagProject {r : Nat} (ψ : ExistsForallFormula sig F r) (k : Fin r) :
    ExistsForallFormula sig F 1 where
  n := ψ.n
  pin := ![ψ.pin k]
  pointType := ψ.pointType
  intervalType := ψ.intervalType

/-- **Diagonal reduction (LANDED).** The diagonal pair projection on `![env k, env k]` holds exactly
when the arity-1 diagonal projection holds on `![env k]`: `pairProject ψ k k` pins both variables to
the same `x_{ψ.pin k}`, so its two identical pin clauses collapse to the single pin clause of
`diagProject ψ k`. Same witness chain, point types, and interval clauses (all `k`-independent). -/
theorem diagProject_efSat_iff {r : Nat} (N : OrderedMonadicStructure (sigE sig F))
    (env : Fin r → N.carrier) (ψ : ExistsForallFormula sig F r) (k : Fin r) :
    efSat N ![env k, env k] (pairProject ψ k k) ↔ efSat N ![env k] (diagProject ψ k) := by
  constructor
  · rintro ⟨x, hmono, hpin, hpt, hb, hm, ha⟩
    refine ⟨x, hmono, Fin.forall_fin_one.mpr ?_, hpt, hb, hm, ha⟩
    simpa [diagProject] using hpin 0
  · rintro ⟨x, hmono, hpin, hpt, hb, hm, ha⟩
    refine ⟨x, hmono, Fin.forall_fin_two.mpr ⟨?_, ?_⟩, hpt, hb, hm, ha⟩
    · simpa [pairProject] using hpin 0
    · simpa [pairProject] using hpin 0

/-! ## 2. Disjunctive sentence lift wrapper (LANDED green) -/

/-- **Disjunctive sentence lift.** Lift an arity-0 `∨∃∀`-object `Ψ` (in practice the existence-sentence
negation object) to arity `r` by lifting each disjunct with `liftSentence` and flattening. -/
noncomputable def liftSentenceV {r : Nat} (Ψ : VeeExistsForall sig F 0) :
    VeeExistsForall sig F r :=
  Ψ.flatMap (fun ξ => liftSentence (r := r) ξ)

/-- **Correctness of the disjunctive sentence lift (LANDED).** For a strictly increasing environment,
`liftSentenceV Ψ` is satisfied at `env` exactly when the arity-0 `Ψ` is satisfiable. Per-disjunct
`liftSentence_iff` pushed through `veeSat_flatMap`. -/
theorem liftSentenceV_iff {r : Nat} (N : OrderedMonadicStructure (sigE sig F))
    (env : Fin r → N.carrier) (h : StrictMono env) (Ψ : VeeExistsForall sig F 0) :
    veeSat N env (liftSentenceV (r := r) Ψ) ↔ veeSat N ![] Ψ := by
  unfold liftSentenceV
  rw [veeSat_flatMap]
  constructor
  · rintro ⟨ξ, hξmem, hξsat⟩
    exact ⟨ξ, hξmem, (liftSentence_iff N env h ξ).mp hξsat⟩
  · rintro ⟨ξ, hξmem, hξsat⟩
    exact ⟨ξ, hξmem, (liftSentence_iff N env h ξ).mpr hξsat⟩

/-! ## 3. The two genuinely-unmapped low-arity negation objects (strategic sorries)

Both are **deliberate skeleton division points** (Rabinovich Prop 3.5 negation-closure at arity 0/1),
not stuck proofs. A bounded lean-search/loogle/grep pass this dispatch confirmed no arity-0/1
`VeeExistsForall`-valued negation engine and no reverse Prop 3.5 exist in the tree yet. Each is tightly
scoped to one lemma, threads (never discharges) `hCapture`, and is tracked in the handoff
`sorry_inventory` with a follow-up owner. -/

/-- **Arity-1 negation object (STRATEGIC SORRY).** For a one-free-variable `∃∀`-object `ξ` (in practice
`diagProject ψ k`), a `VeeExistsForall sig F 1` realizing `¬ efSat N env ξ`.
`-- sorry: assumes the Prop 3.5 negation-closure at arity 1 (reverse of translateProp35_correct:
`Formula → VeeExistsForall sig F 1`); deferred because that reverse map is genuinely unmapped in the
current tree (only the arity-2 prop42_efSat_negation_general ∘ vvecea2_collapse_bridge composition is
landed); follow-up: a dedicated arity-1 negation-object research+build sub-phase (report-11 unmapped
piece). hCapture threaded, never discharged.` -/
theorem efSat_negation_diagonal
    (N : OrderedMonadicStructure (sigE sig F))
    (atomMap : Formula → (sigE sig F).preds)
    (h_surj : ∀ p : (sigE sig F).preds, ∃ a : Atom, atomMap (.atom a) = p)
    (h_INF : HasAttainedINF N atomMap) (h_SUP : HasAttainedSUP N atomMap)
    (hCapture : ∀ A : Formula, ∃ S : IntervalType sig F,
        ∀ y : N.carrier, intervalHolds N S y ↔ temporal_truth N atomMap y A)
    (ξ : ExistsForallFormula sig F 1) :
    ∃ Φ : VeeExistsForall sig F 1, ∀ env : Fin 1 → N.carrier,
      (veeSat N env Φ ↔ ¬ efSat N env ξ) := by
  sorry

/-- **Arity-0 negation object (STRATEGIC SORRY).** For the arity-0 existence sentence `ξ` (in practice
`existenceSentence ψ`), a `VeeExistsForall sig F 0` realizing `¬ efSat N ![] ξ`.
`-- sorry: assumes the Prop 3.5 negation-closure at arity 0 (the existence-sentence negation object,
plan note "at arity 0/2"); deferred because the arity-0 VeeExistsForall-valued negation is genuinely
unmapped (same missing reverse Prop 3.5 as the arity-1 case); follow-up: a dedicated arity-0/1
negation-object research+build sub-phase (report-11 unmapped piece). hCapture threaded, never
discharged.` -/
theorem efSat_negation_existence
    (N : OrderedMonadicStructure (sigE sig F))
    (atomMap : Formula → (sigE sig F).preds)
    (h_surj : ∀ p : (sigE sig F).preds, ∃ a : Atom, atomMap (.atom a) = p)
    (h_INF : HasAttainedINF N atomMap) (h_SUP : HasAttainedSUP N atomMap)
    (hCapture : ∀ A : Formula, ∃ S : IntervalType sig F,
        ∀ y : N.carrier, intervalHolds N S y ↔ temporal_truth N atomMap y A)
    (ξ : ExistsForallFormula sig F 0) :
    ∃ Φ : VeeExistsForall sig F 0, veeSat N ![] Φ ↔ ¬ efSat N ![] ξ := by
  sorry

/-! ## 4. The general negation assembly (strategic sorry skeleton)

All lifts and the De Morgan decomposition are landed; the remaining content is (i) the two low-arity
negation objects above, and (ii) the finite trichotomy reindexing over `pairwiseProjections`
(`k < l` via `liftPairV ∘ efSat_negation_pair`; `k > l` folded by `pairProject_swap_efSat`; `k = l`
via `diagProject_efSat_iff` + `liftSingleV ∘ efSat_negation_diagonal`; existence via `liftSentenceV ∘
efSat_negation_existence`), assembled by
`Φ := (pairs k<l).flatMap (liftPairV (neg-pair) k l) ++ (diag k).flatMap (liftSingleV (neg-diag) k)
      ++ liftSentenceV (neg-exist)`
and chained `veeSat_append ×2 + veeSat_flatMap` ↔ `efSat_negation_demorgan`. -/

/-- **`efSat_negation_general` (β at the `∨∃∀` type — STRATEGIC SORRY skeleton).** The negation of a
general `r`-free-variable `∃∀`-object as a `VeeExistsForall`, threading `hCapture` (never discharged).
CONDITIONAL orphan gated on `hCapture` until Phase ζ.
`-- sorry: assumes efSat_negation_diagonal + efSat_negation_existence (the two unmapped low-arity
negation objects above) plus the finite trichotomy reindex over pairwiseProjections; deferred because
the two negation objects are strategic sorries this dispatch, so the assembly cannot be sorry-free yet;
follow-up: land efSat_negation_diagonal/efSat_negation_existence, then the trichotomy assembly
(veeSat_append/veeSat_flatMap chain + pairProject_swap_efSat fold). hCapture threaded, never
discharged.` -/
theorem efSat_negation_general
    (N : OrderedMonadicStructure (sigE sig F))
    (atomMap : Formula → (sigE sig F).preds)
    (h_surj : ∀ p : (sigE sig F).preds, ∃ a : Atom, atomMap (.atom a) = p)
    (h_INF : HasAttainedINF N atomMap) (h_SUP : HasAttainedSUP N atomMap)
    (hCapture : ∀ A : Formula, ∃ S : IntervalType sig F,
        ∀ y : N.carrier, intervalHolds N S y ↔ temporal_truth N atomMap y A)
    {r : Nat} (ψ : ExistsForallFormula sig F r) :
    ∃ Φ : VeeExistsForall sig F r, ∀ env : Fin r → N.carrier, StrictMono env →
      (¬ efSat N env ψ ↔ veeSat N env Φ) := by
  sorry

end Bimodal.Metalogic.WeakCanonical.Kamp
