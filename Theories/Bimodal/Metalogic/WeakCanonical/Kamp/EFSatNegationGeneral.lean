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

/-! ## 2a. Degenerate single-point `∃∀`-objects (plumbing for the capture-disjunction route)

The reverse of Prop 3.5 that the low-arity negation objects need is *semantic*, not syntactic: for a
target formula `A`, `hCapture A` supplies an `IntervalType S` with `intervalHolds N S y ↔
temporal_truth N atomMap y A`. Each admissible completion `τ ∈ S` is realized by a **degenerate
single-point** `∃∀`-object whose `efSat` collapses to `unaryHolds τ`. Disjoining over `τ ∈ S` gives a
`VeeExistsForall` whose `veeSat` equals `intervalHolds N S = temporal_truth ... A`. This is the same
"expand-into-a-disjunction-over-admissible-completions" move the landed arity-2 bridge performs, at a
single point instead of a bracket. -/

/-- **Degenerate single-point arity-1 object.** One existential point (`n := 0`), the single free
variable pinned to it, point type `τ`, both unbounded caps trivial (`intervalTop`). Its `efSat`
collapses to `unaryHolds τ (env 0)` (`pointEF1_efSat`). -/
def pointEF1 (τ : UnaryType sig F) : ExistsForallFormula sig F 1 where
  n := 0
  pin := ![0]
  pointType := ![τ]
  intervalType := ![intervalTop sig F, intervalTop sig F]

/-- **Correctness of `pointEF1`.** The degenerate single-point object holds at `env` exactly when its
point type is realized at `env 0`: the single witness is `env 0`, `StrictMono` on `Fin 1` is trivial,
and both unbounded caps are vacuous (`intervalHolds_intervalTop`). -/
theorem pointEF1_efSat (N : OrderedMonadicStructure (sigE sig F))
    (τ : UnaryType sig F) (env : Fin 1 → N.carrier) :
    efSat N env (pointEF1 τ) ↔ unaryHolds N τ (env 0) := by
  constructor
  · rintro ⟨x, _, hpin, hpt, _, _, _⟩
    have h0 := hpt 0
    have hp0 := hpin 0
    simp only [pointEF1, Matrix.cons_val_zero] at h0 hp0
    rw [hp0]; exact h0
  · intro h
    haveI : Subsingleton (Fin ((pointEF1 τ).n + 1)) :=
      inferInstanceAs (Subsingleton (Fin 1))
    refine ⟨fun _ => env 0, ?_, ?_, ?_, ?_, ?_, ?_⟩
    · intro a b hab
      exact absurd (Subsingleton.elim a b) (ne_of_lt hab)
    · intro k
      rw [Subsingleton.elim k 0]
    · intro j
      rw [Subsingleton.elim j 0]
      simpa [pointEF1] using h
    · intro y _
      simpa [pointEF1] using intervalHolds_intervalTop N y
    · intro i; exact i.elim0
    · intro y _
      simpa [pointEF1] using intervalHolds_intervalTop N y

/-- **Pin an arity-0 sentence to a single free variable.** Same ordered chain, point types, and
interval types as `ξ`, but with one free variable pinned to the first existential point. `efSat N ![]
ξ` becomes `∃ z, efSat N ![z] (pinFirst ξ)` (`pinFirst_efSat`). -/
def pinFirst (ξ : ExistsForallFormula sig F 0) : ExistsForallFormula sig F 1 where
  n := ξ.n
  pin := ![0]
  pointType := ξ.pointType
  intervalType := ξ.intervalType

/-- **Sentence ↔ ∃-pin.** An arity-0 sentence is satisfiable exactly when its `pinFirst` pin is
satisfiable for some anchor `z`: the `∃ z` absorbs the `z = x 0` pin clause; every other clause is
identical (same chain, point types, interval types). -/
theorem pinFirst_efSat (N : OrderedMonadicStructure (sigE sig F))
    (ξ : ExistsForallFormula sig F 0) :
    efSat N ![] ξ ↔ ∃ z : N.carrier, efSat N ![z] (pinFirst ξ) := by
  constructor
  · rintro ⟨x, hmono, _, hpt, hb, hm, ha⟩
    refine ⟨x 0, x, hmono, ?_, hpt, hb, hm, ha⟩
    intro k
    rw [Subsingleton.elim k 0]
    simp [pinFirst]
  · rintro ⟨z, x, hmono, _, hpt, hb, hm, ha⟩
    exact ⟨x, hmono, fun k => k.elim0, hpt, hb, hm, ha⟩

/-- **Universal single-point sentence.** An arity-0 object with one existential point (`n := 0`),
point type `τ`, and both unbounded caps carrying the captured set `S` (not `intervalTop`). Its `efSat`
collapses to: some `x0` realizes `τ`, and `S` holds strictly below and strictly above `x0`
(`univSentence_efSat`). -/
def univSentence (τ : UnaryType sig F) (S : IntervalType sig F) : ExistsForallFormula sig F 0 where
  n := 0
  pin := Fin.elim0
  pointType := ![τ]
  intervalType := ![S, S]

/-- **Correctness of `univSentence`.** The single-point sentence holds exactly when some `x0` realizes
`τ` and the captured set `S` holds strictly below and strictly above `x0`. -/
theorem univSentence_efSat (N : OrderedMonadicStructure (sigE sig F))
    (τ : UnaryType sig F) (S : IntervalType sig F) :
    efSat N ![] (univSentence τ S) ↔
      ∃ x0 : N.carrier, unaryHolds N τ x0 ∧
        (∀ y : N.carrier, y < x0 → intervalHolds N S y) ∧
        (∀ y : N.carrier, x0 < y → intervalHolds N S y) := by
  constructor
  · rintro ⟨x, _, _, hpt, hb, _, ha⟩
    refine ⟨x 0, ?_, ?_, ?_⟩
    · simpa [univSentence] using hpt 0
    · intro y hy
      simpa [univSentence] using hb y hy
    · intro y hy
      simpa [univSentence] using ha y hy
  · rintro ⟨x0, hτ, hb, ha⟩
    haveI : Subsingleton (Fin ((univSentence τ S).n + 1)) :=
      inferInstanceAs (Subsingleton (Fin 1))
    refine ⟨fun _ => x0, ?_, fun k => k.elim0, ?_, ?_, ?_, ?_⟩
    · intro a b hab
      exact absurd (Subsingleton.elim a b) (ne_of_lt hab)
    · intro j
      rw [Subsingleton.elim j 0]
      simpa [univSentence] using hτ
    · intro y hy
      simpa [univSentence] using hb y hy
    · intro i; exact i.elim0
    · intro y hy
      simpa [univSentence] using ha y hy

/-- **Order-trichotomy bridge.** On a nonempty linear order, a predicate `Q` holding at some point
together with everywhere strictly-below and strictly-above that point is equivalent to `Q` holding
everywhere. The ⟸ direction needs a nonemptiness anchor; ⟹ uses `lt_trichotomy`. -/
theorem order_point_forall_iff (N : OrderedMonadicStructure (sigE sig F))
    (hne : Nonempty N.carrier) (Q : N.carrier → Prop) :
    (∃ x0 : N.carrier, Q x0 ∧ (∀ y, y < x0 → Q y) ∧ (∀ y, x0 < y → Q y)) ↔ ∀ z, Q z := by
  constructor
  · rintro ⟨x0, hx0, hb, ha⟩ z
    rcases lt_trichotomy z x0 with h | h | h
    · exact hb z h
    · exact h ▸ hx0
    · exact ha z h
  · intro h
    obtain ⟨a⟩ := hne
    exact ⟨a, h a, fun y _ => h y, fun y _ => h y⟩

/-! ## 3. The two genuinely-unmapped low-arity negation objects (strategic sorries)

Both are **deliberate skeleton division points** (Rabinovich Prop 3.5 negation-closure at arity 0/1),
not stuck proofs. A bounded lean-search/loogle/grep pass this dispatch confirmed no arity-0/1
`VeeExistsForall`-valued negation engine and no reverse Prop 3.5 exist in the tree yet. Each is tightly
scoped to one lemma, threads (never discharges) `hCapture`, and is tracked in the handoff
`sorry_inventory` with a follow-up owner. -/

/-- **Arity-1 negation object (LANDED).** For a one-free-variable `∃∀`-object `ξ` (in practice
`diagProject ψ k`), a `VeeExistsForall sig F 1` realizing `¬ efSat N env ξ`.

Constructed directly via the capture route (no reverse Prop 3.5 syntactic map): translate `ξ`
forward (`translateProp35_correct`), negate the target formula (`temporal_truth_neg`), capture the
negated truth-set as an `IntervalType S` (`hCapture`), and disjoin the degenerate single-point
objects `pointEF1 τ` over the admissible completions `τ ∈ S`. `veeSat` over that disjunction equals
`intervalHolds N S (env 0) = ¬ efSat N env ξ`. `hCapture` threaded, never discharged. -/
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
  obtain ⟨S, hS⟩ := hCapture (translateProp35 atomMap h_surj ξ).neg
  refine ⟨S.toList.map (fun τ => pointEF1 τ), fun env => ?_⟩
  have hveeLHS : veeSat N env (S.toList.map (fun τ => pointEF1 τ)) ↔
      intervalHolds N S (env 0) := by
    simp only [veeSat, List.mem_map, Finset.mem_toList, intervalHolds]
    constructor
    · rintro ⟨ψ, ⟨τ, hτ, rfl⟩, hsat⟩
      exact ⟨τ, hτ, (pointEF1_efSat N τ env).mp hsat⟩
    · rintro ⟨τ, hτ, hu⟩
      exact ⟨pointEF1 τ, ⟨τ, hτ, rfl⟩, (pointEF1_efSat N τ env).mpr hu⟩
  rw [hveeLHS, hS (env 0), temporal_truth_neg,
    translateProp35_correct N atomMap h_surj env ξ]

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
