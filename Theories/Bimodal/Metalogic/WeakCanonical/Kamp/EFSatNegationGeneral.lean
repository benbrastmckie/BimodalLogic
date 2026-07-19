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

## Status

The two low-arity negation objects are now **LANDED sorry-free** (axiom-clean). No reverse Prop 3.5
syntactic map (`Formula → VeeExistsForall sig F 1`) was needed: the reverse direction is discharged
*semantically* by `hCapture` + degenerate single-point objects (`pointEF1`, `univSentence`) disjoined
over admissible completions — the same device the landed arity-2 `vvecea2_collapse_bridge` uses.

1. `efSat_negation_diagonal` — arity-1 negation object. **LANDED** (capture + `pointEF1` route).
2. `efSat_negation_existence` — arity-0 negation object. **LANDED** (capture + `univSentence` +
   order-trichotomy route). Gained a mandatory `Nonempty N.carrier` hypothesis: the theorem is
   provably FALSE on an empty carrier (see its docstring).
3. `efSat_negation_general` — the trichotomy assembly over `pairwiseProjections` chaining
   `veeSat_append`/`veeSat_flatMap` + the three class lemmas + the `k > l` symmetry fold + the
   `efSat_negation_demorgan` decomposition, consuming 1 and 2. **LANDED sorry-free** (axiom-clean
   `[propext, Classical.choice, Quot.sound]`); threads `hne` to supply `efSat_negation_existence`
   at the Phase-ζ discharge site.

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

/-- Every disjunct of `liftSentenceV Ψ` has a strictly monotone pin. -/
theorem liftSentenceV_pin_strictMono {r : Nat} (Ψ : VeeExistsForall sig F 0)
    (φ : ExistsForallFormula sig F r) (hφ : φ ∈ liftSentenceV (r := r) Ψ) : StrictMono φ.pin := by
  unfold liftSentenceV at hφ
  rw [List.mem_flatMap] at hφ
  obtain ⟨ξ, _, hφξ⟩ := hφ
  exact liftSentence_pin_strictMono ξ φ hφξ

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

/-! ## 3. The two low-arity negation objects (LANDED, capture-disjunction route)

Both are constructed sorry-free via the degenerate single-point objects of section 2a disjoined over
the admissible completions supplied by `hCapture` (Rabinovich Prop 3.5 negation-closure at arity
0/1). No reverse Prop 3.5 syntactic map was needed. Each threads (never discharges) `hCapture`. -/

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

/-- **Arity-0 negation object (LANDED).** For the arity-0 existence sentence `ξ` (in practice
`existenceSentence ψ`), a `VeeExistsForall sig F 0` realizing `¬ efSat N ![] ξ`.

**Signature note — the `Nonempty N.carrier` hypothesis is mandatory (not optional).** On an empty
carrier the theorem-as-originally-stated is FALSE: `¬ efSat N ![] ξ = True` (no witness chain
exists) while every `veeSat N ![] Φ = False` (same reason), so the biconditional is `True ↔ False`.
`HasAttainedINF`/`HasAttainedSUP` are `∀ z0 z1, z0 < z1 → …`, vacuous on the empty carrier, and do
not supply nonemptiness. The consumer (`efSat_negation_general`) threads `hne` from `env 0` at
`r ≥ 1`. Grounding: report 13, H4 section.

Construction (capture route): pin `ξ` to one free variable (`pinFirst`); a sentence is satisfiable
iff its pin is (`pinFirst_efSat`), so `¬ efSat N ![] ξ ↔ ∀ z, ¬ efSat N ![z] (pinFirst ξ)`. Translate
forward + negate + capture as an `IntervalType S`, giving `∀ z, intervalHolds N S z`. On the object
side, disjoin the universal single-point sentences `univSentence τ S` over `τ ∈ S`; `veeSat` collapses
(order trichotomy, `order_point_forall_iff`) to the same `∀ z, intervalHolds N S z`. `hCapture`
threaded, never discharged. -/
theorem efSat_negation_existence
    (N : OrderedMonadicStructure (sigE sig F))
    (atomMap : Formula → (sigE sig F).preds)
    (h_surj : ∀ p : (sigE sig F).preds, ∃ a : Atom, atomMap (.atom a) = p)
    (h_INF : HasAttainedINF N atomMap) (h_SUP : HasAttainedSUP N atomMap)
    (hCapture : ∀ A : Formula, ∃ S : IntervalType sig F,
        ∀ y : N.carrier, intervalHolds N S y ↔ temporal_truth N atomMap y A)
    (hne : Nonempty N.carrier)
    (ξ : ExistsForallFormula sig F 0) :
    ∃ Φ : VeeExistsForall sig F 0, veeSat N ![] Φ ↔ ¬ efSat N ![] ξ := by
  obtain ⟨S, hS⟩ := hCapture (translateProp35 atomMap h_surj (pinFirst ξ)).neg
  refine ⟨S.toList.map (fun τ => univSentence τ S), ?_⟩
  have hRHS : (¬ efSat N ![] ξ) ↔ (∀ z : N.carrier, intervalHolds N S z) := by
    rw [pinFirst_efSat N ξ, not_exists]
    apply forall_congr'
    intro z
    rw [translateProp35_correct N atomMap h_surj ![z] (pinFirst ξ), ← temporal_truth_neg,
      ← hS (![z] 0)]
    simp
  have hLHS : veeSat N ![] (S.toList.map (fun τ => univSentence τ S)) ↔
      (∀ z : N.carrier, intervalHolds N S z) := by
    rw [← order_point_forall_iff N hne (intervalHolds N S)]
    have step : veeSat N ![] (S.toList.map (fun τ => univSentence τ S)) ↔
        ∃ τ ∈ S, efSat N ![] (univSentence τ S) := by
      simp only [veeSat, List.mem_map, Finset.mem_toList]
      constructor
      · rintro ⟨ψ, ⟨τ, hτ, rfl⟩, hsat⟩; exact ⟨τ, hτ, hsat⟩
      · rintro ⟨τ, hτ, hsat⟩; exact ⟨univSentence τ S, ⟨τ, hτ, rfl⟩, hsat⟩
    rw [step]
    simp only [univSentence_efSat]
    constructor
    · rintro ⟨τ, hτ, x0, hτx0, hb, ha⟩
      exact ⟨x0, ⟨τ, hτ, hτx0⟩, hb, ha⟩
    · rintro ⟨x0, hx0, hb, ha⟩
      obtain ⟨τ, hτ, hτx0⟩ := hx0
      exact ⟨τ, hτ, x0, hτx0, hb, ha⟩
  rw [hLHS, hRHS]

/-! ## 4. The general negation assembly (LANDED sorry-free)

All lifts and the De Morgan decomposition are landed; the remaining content is (i) the two low-arity
negation objects above, and (ii) the finite trichotomy reindexing over `pairwiseProjections`
(`k < l` via `liftPairV ∘ efSat_negation_pair`; `k > l` folded by `pairProject_swap_efSat`; `k = l`
via `diagProject_efSat_iff` + `liftSingleV ∘ efSat_negation_diagonal`; existence via `liftSentenceV ∘
efSat_negation_existence`), assembled by
`Φ := (pairs k<l).flatMap (liftPairV (neg-pair) k l) ++ (diag k).flatMap (liftSingleV (neg-diag) k)
      ++ liftSentenceV (neg-exist)`
and chained `veeSat_append ×2 + veeSat_flatMap` ↔ `efSat_negation_demorgan`. -/

/-- **`efSat_negation_general` (β at the `∨∃∀` type — LANDED sorry-free).** The negation of a
general `r`-free-variable `∃∀`-object as a `VeeExistsForall`, threading `hCapture` and `hne` (never
discharged). CONDITIONAL orphan gated on `hCapture` until Phase ζ.

Both low-arity negation objects it consumes are LANDED (`efSat_negation_diagonal`,
`efSat_negation_existence`). The assembly builds
`Φ := (pairs k<l).flatMap (liftPairV (neg-pair) k l) ++ (diag k).flatMap (liftSingleV (neg-diag) k)
      ++ liftSentenceV (neg-exist)`
and chains `veeSat_append ×2 + veeSat_flatMap` against the `efSat_negation_demorgan` decomposition.
The `k = l` diagonal is routed through `diagProject_efSat_iff`; the `k > l` pairs fold to their
`l < k` counterparts by `pairProject_swap_efSat` (trichotomy `hTri`), so `Φ` carries only `k < l`
pair disjuncts. The `hne : Nonempty N.carrier` hypothesis is threaded (like `hCapture`) because
`efSat_negation_existence` requires it and the existence-sentence negation object is built at
`Φ`-construction time, before any `env` is available — so nonemptiness cannot be derived internally
from `env 0`. The Phase-ζ discharge site supplies it: the concrete completeness structure is always
nonempty (report 13, H4 section). Axiom-clean `[propext, Classical.choice, Quot.sound]`. `hCapture`
and `hne` threaded, never discharged. -/
theorem efSat_negation_general
    (N : OrderedMonadicStructure (sigE sig F))
    (atomMap : Formula → (sigE sig F).preds)
    (h_surj : ∀ p : (sigE sig F).preds, ∃ a : Atom, atomMap (.atom a) = p)
    (h_INF : HasAttainedINF N atomMap) (h_SUP : HasAttainedSUP N atomMap)
    (hCapture : ∀ A : Formula, ∃ S : IntervalType sig F,
        ∀ y : N.carrier, intervalHolds N S y ↔ temporal_truth N atomMap y A)
    (hne : Nonempty N.carrier)
    {r : Nat} (ψ : ExistsForallFormula sig F r) :
    ∃ Φ : VeeExistsForall sig F r, (∀ φ ∈ Φ, StrictMono φ.pin) ∧
      ∀ env : Fin r → N.carrier, StrictMono env →
      (¬ efSat N env ψ ↔ veeSat N env Φ) := by
  classical
  -- Per-pair (`k < l`), per-diagonal (`k = l`), and existence-sentence negation objects.
  have hpair := fun (k l : Fin r) =>
    efSat_negation_pair N atomMap h_surj h_INF h_SUP hCapture (pairProject ψ k l)
  choose P hPspec using hpair
  have hdiag := fun (k : Fin r) =>
    efSat_negation_diagonal N atomMap h_surj h_INF h_SUP hCapture (diagProject ψ k)
  choose D hDspec using hdiag
  obtain ⟨E, hEspec⟩ :=
    efSat_negation_existence N atomMap h_surj h_INF h_SUP hCapture hne (existenceSentence ψ)
  refine ⟨((List.finRange r).flatMap fun k => (List.finRange r).flatMap fun l =>
            if k < l then liftPairV (P k l) k l else [])
          ++ ((List.finRange r).flatMap fun k => liftSingleV (D k) k)
          ++ liftSentenceV E, ?_, fun env h => ?_⟩
  · -- Pin-monotonicity of every disjunct (T1 invariant): each disjunct is a lift disjunct.
    intro φ hφ
    rw [List.mem_append, List.mem_append] at hφ
    rcases hφ with (hφ | hφ) | hφ
    · rw [List.mem_flatMap] at hφ
      obtain ⟨k, _, hφ⟩ := hφ
      rw [List.mem_flatMap] at hφ
      obtain ⟨l, _, hφ⟩ := hφ
      by_cases hkl : k < l
      · rw [if_pos hkl] at hφ
        exact liftPairV_pin_strictMono (P k l) k l φ hφ
      · rw [if_neg hkl] at hφ
        exact absurd hφ List.not_mem_nil
    · rw [List.mem_flatMap] at hφ
      obtain ⟨k, _, hφ⟩ := hφ
      exact liftSingleV_pin_strictMono (D k) k φ hφ
    · exact liftSentenceV_pin_strictMono E φ hφ
  set A := (List.finRange r).flatMap (fun k => (List.finRange r).flatMap fun l =>
            if k < l then liftPairV (P k l) k l else []) with hAdef
  set B := (List.finRange r).flatMap (fun k => liftSingleV (D k) k) with hBdef
  set C := liftSentenceV E with hCdef
  -- The `k < l` pair disjuncts.
  have hA : veeSat N env A ↔
      ∃ k l : Fin r, k < l ∧ ¬ efSat N ![env k, env l] (pairProject ψ k l) := by
    rw [hAdef, veeSat_flatMap]
    constructor
    · rintro ⟨k, -, hk⟩
      rw [veeSat_flatMap] at hk
      obtain ⟨l, -, hl⟩ := hk
      by_cases hkl : k < l
      · rw [if_pos hkl, liftPairV_iff N env h (P k l) k l hkl,
          hPspec k l ![env k, env l] (by simpa using h hkl)] at hl
        exact ⟨k, l, hkl, hl⟩
      · rw [if_neg hkl] at hl
        simp [veeSat] at hl
    · rintro ⟨k, l, hkl, hnp⟩
      refine ⟨k, List.mem_finRange k, ?_⟩
      rw [veeSat_flatMap]
      refine ⟨l, List.mem_finRange l, ?_⟩
      rw [if_pos hkl, liftPairV_iff N env h (P k l) k l hkl,
        hPspec k l ![env k, env l] (by simpa using h hkl)]
      exact hnp
  -- The diagonal (`k = l`) disjuncts.
  have hB : veeSat N env B ↔
      ∃ k : Fin r, ¬ efSat N ![env k, env k] (pairProject ψ k k) := by
    rw [hBdef, veeSat_flatMap]
    constructor
    · rintro ⟨k, -, hk⟩
      rw [liftSingleV_iff N env h (D k) k, hDspec k ![env k],
        ← diagProject_efSat_iff N env ψ k] at hk
      exact ⟨k, hk⟩
    · rintro ⟨k, hk⟩
      refine ⟨k, List.mem_finRange k, ?_⟩
      rw [liftSingleV_iff N env h (D k) k, hDspec k ![env k],
        ← diagProject_efSat_iff N env ψ k]
      exact hk
  -- The existence-sentence disjunct.
  have hC : veeSat N env C ↔ ¬ efSat N ![] (existenceSentence ψ) := by
    rw [hCdef, liftSentenceV_iff N env h E, hEspec]
  -- Reindex the De Morgan pair-part over `pairwiseProjections`.
  have hDemPairs : (∃ p ∈ pairwiseProjections ψ, ¬ efSat N ![env p.1, env p.2.1] p.2.2)
      ↔ ∃ k l : Fin r, ¬ efSat N ![env k, env l] (pairProject ψ k l) := by
    constructor
    · rintro ⟨p, hp, hnp⟩
      unfold pairwiseProjections at hp
      rw [List.mem_flatMap] at hp
      obtain ⟨k, -, hp⟩ := hp
      rw [List.mem_map] at hp
      obtain ⟨l, -, rfl⟩ := hp
      exact ⟨k, l, hnp⟩
    · rintro ⟨k, l, hnp⟩
      refine ⟨(k, l, pairProject ψ k l), ?_, hnp⟩
      unfold pairwiseProjections
      rw [List.mem_flatMap]
      exact ⟨k, List.mem_finRange k, by rw [List.mem_map]; exact ⟨l, List.mem_finRange l, rfl⟩⟩
  -- Trichotomy + swap fold: all ordered pairs reduce to `k < l` pairs plus the diagonal.
  have hTri : (∃ k l : Fin r, ¬ efSat N ![env k, env l] (pairProject ψ k l))
      ↔ (∃ k l : Fin r, k < l ∧ ¬ efSat N ![env k, env l] (pairProject ψ k l))
        ∨ (∃ k : Fin r, ¬ efSat N ![env k, env k] (pairProject ψ k k)) := by
    constructor
    · rintro ⟨k, l, hnp⟩
      rcases lt_trichotomy k l with hkl | hkl | hkl
      · exact Or.inl ⟨k, l, hkl, hnp⟩
      · subst hkl; exact Or.inr ⟨_, hnp⟩
      · refine Or.inl ⟨l, k, hkl, ?_⟩
        rw [← pairProject_swap_efSat N env ψ k l]
        exact hnp
    · rintro (⟨k, l, -, hnp⟩ | ⟨k, hnp⟩)
      · exact ⟨k, l, hnp⟩
      · exact ⟨k, k, hnp⟩
  -- Assemble.
  rw [efSat_negation_demorgan N env ψ, hDemPairs, veeSat_append, veeSat_append,
    hA, hB, hC, hTri]

end Bimodal.Metalogic.WeakCanonical.Kamp
