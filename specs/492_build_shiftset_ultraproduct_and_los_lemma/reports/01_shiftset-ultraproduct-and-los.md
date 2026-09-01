# The ShiftSet Ultraproduct and the Łoś Lemma

**Scope**: steps S2 (build the ultraproduct of shift sets) and S3 (Łoś for `TruthAt`).
**Carrier route**: (a), the bespoke quotient of the Pi group — settled upstream, not reopened.
**Verification basis**: a 216-line prototype and a 62-line index-filter prototype, both compiled
sorry-free against the live tree (Lean v4.33.0-rc1, Mathlib `79d0395a`) with `lean_run_code`, at
`specs/492_build_shiftset_ultraproduct_and_los_lemma/prototype/UltraproductLos.lean` and
`.../prototype/IndexFilter.lean`.

---

## Headline

**The whole of S2 and S3 is proved.** Not sketched — proved, and the proof is in the prototype
directory. Every declaration named below elaborated sorry-free, and `#print axioms` on `uSep`,
`uShiftSet`, `los`, `los_truthAt` and `eventually_mem` reports exactly

```
[propext, Classical.choice, Quot.sound]
```

with no `sorryAx`. This report is therefore not a plan for finding a proof; it is a transcription
target plus the four places where the naive transcription breaks.

| Obligation | Status | Where |
|---|---|---|
| Ultrafilter on the index type | **proved** | `IndexFilter.lean` (62 lines) |
| `ShiftSet.sep` on the ultraproduct | **proved** (`uSep`) | `UltraproductLos.lean:71` |
| `carrier_nonempty` and the valuation `A` | **proved** (fields of `uShiftSet`) | `:98` |
| The ultraproduct shift set, all 7 fields | **proved** (`uShiftSet`) | `:98` |
| Łoś for `ShiftTruth`, six cases | **proved** (`los`) | `:123` |
| Łoś for `TruthAt` | **proved** (`los_truthAt`) | `:203` |

### The one architectural finding

Do **not** attack Łoś at `TruthAt` directly. Route it through `ShiftTruth` and conjugate by
`ShiftSet.forward_repr`:

```
TruthAt (uShiftSet φ S).model ((uShiftSet φ S).hist (omk f)) (mk x) χ
  ↔ ShiftTruth (uShiftSet φ S) (omk f) (mk x) χ            -- forward_repr
  ↔ ∀ᶠ i in φ, ShiftTruth (S i) (f i) (x i) χ              -- los
  ↔ ∀ᶠ i in φ, TruthAt (S i).model ((S i).hist (f i)) (x i) χ  -- forward_repr, pointwise
```

This is `los_truthAt`, and it is a three-line term proof. The reason it matters is **risk R2**.
The task brief locates R2 in a choice-function argument over total world-histories, because
`TruthAt`'s `box` clause reads `∀ (σ : WorldHistory F), σ.IsTotal → …`
(`FormalSystem/Semantics/Truth.lean:164`) — not a pointwise-definable family. That is correct
about `TruthAt` and it is why the direct route is hard. But `ShiftTruth`'s `box` clause reads
`∀ v : S.Carrier, ShiftTruth S v t φ` (`FormalSystem/Semantics/ShiftSet.lean:265`) — a
quantifier over the *carrier sort*, which on the ultraproduct is `UOmega φ Ω`, every element of
which is `omk` of a section (`omk_surjective`, probe `:224`). The choice extraction there is
routine. The gap between the two `box` clauses is closed once and for all, already, by
`forward_repr`'s own `box` case (`ShiftSet.lean:286-292`), using `hist_isTotal` (`:226`) and
`total_eq_orbit` (`:245`) — both existing, both sorry-free.

**R2 is therefore discharged by reuse, not by a new argument.** The choice-function work that
remains is over the carrier and duration sorts, where it is easy.

### The one correction to the task brief

> "Five are mechanical. The box case is the real content."

Measured against the prototype, **three** cases need a choice-function extraction, not one:

| Case | Choice extraction needed? | Where |
|---|---|---|
| `atom` | no — `Iff.rfl` | — |
| `bot` | no | — |
| `imp` | no — `Ultrafilter.eventually_imp` | — |
| `box` | **yes**, one, in `→` | counterexample section over `(S i).Carrier` |
| `untl` | **yes**, two, one per direction | witness section over `↑(T i)` in `←`; counterexample section for the inner bounded `∀` in `→` |
| `snce` | **yes**, two, one per direction | same, mirrored |

The reason is structural: `ShiftTruth`'s `untl`/`snce` clauses (`ShiftSet.lean:266-269`) carry
*both* an `∃ s : D` and a bounded `∀ r : D` over the duration sort. The `∃` needs a witness
section when passing from the pointwise statement to the ultraproduct; the bounded `∀` needs a
counterexample section when passing the other way. `box` has only the second. A plan that sizes
`untl`/`snce` as "mechanical transport, like `forward_repr`" will be wrong by roughly 20 lines
per case and will hit the harder of the two extractions first.

---

## 1. What the probe provides vs. what S2 owed

`Tests/BimodalTest/Semantics/DependentUltraproductProbe.lean`, namespace
`BimodalTest.DependentUltraproductProbe`, under section variables

```lean
variable {I : Type} {φ : Ultrafilter I} {D : I → Type}
  [∀ i, AddCommGroup (D i)] [∀ i, LinearOrder (D i)] [∀ i, IsOrderedAddMonoid (D i)]
```

### 1.1 Provided (16 declarations, all reusable verbatim)

| # | Declaration | Signature / content | Line |
|---|---|---|---|
| 1 | `evZero` | `AddSubgroup (∀ i, D i)`, carrier `{f | ∀ᶠ i in φ, f i = 0}` | `:80` |
| 2 | `mem_evZero` | `f ∈ evZero φ D ↔ ∀ᶠ i in φ, f i = 0` — `Iff.rfl`, `@[simp]` | `:90` |
| 3 | `UD` | `abbrev UD := (∀ i, D i) ⧸ evZero φ D` | `:94` |
| 4 | `mk` | `(f : ∀ i, D i) → UD φ D` | `:97` |
| 5 | `mk_eq_mk` | `mk f = mk g ↔ ∀ᶠ i in φ, f i = g i` | `:99` |
| 6 | `instLE` | `LE (UD φ D)` via `Quotient.liftOn₂'` | `:109` |
| 7 | `mk_le_mk` | `mk f ≤ mk g ↔ ∀ᶠ i in φ, f i ≤ g i` — `Iff.rfl` | `:118` |
| 8 | `instLinearOrder` | `LinearOrder (UD φ D)`, 5 fields, `toDecidableLE := Classical.decRel _` | `:121` |
| 9 | `instIsOrderedAddMonoid` | one field, `add_le_add_left` | `:153` |
| 10 | `not_eventually_false` | `(∀ᶠ i in φ, p i) → (∀ i, ¬ p i) → False` | `:165` |
| 11 | `mk_lt_mk` | `mk f < mk g ↔ ∀ᶠ i in φ, f i < g i` | `:169` |
| 12 | `instNontrivial` | needs `[∀ i, Nontrivial (D i)]` | `:181` |
| 13 | `instDenselyOrderedUD` | needs `[∀ i, DenselyOrdered (D i)]` — **the Dense branch** | `:188` |
| 14 | `carrierSetoid` / `UOmega` / `omk` / `omk_eq_omk` / `omk_surjective` | eventual-equality quotient on `∀ i, Ω i` | `:206`–`:225` |
| 15 | `shU` / `shU_mk` | the lifted shift action; `shU_mk` is `rfl`, `@[simp]` | `:228` / `:236` |
| 16 | `shU_zero` / `shU_add` | the two action laws, given their pointwise forms | `:239` / `:246` |

`AddCommGroup (UD φ D)` is inherited free from `QuotientAddGroup.Quotient.addCommGroup`; it is
not a declaration in the probe and does not need to be written.

### 1.2 Owed — and now supplied by the prototype (9 new declarations)

| # | Declaration | Signature | Prototype line |
|---|---|---|---|
| 1 | `exists_section` | `[∀ i, Nonempty (Ω i)] → (∀ᶠ i in φ, ∃ v, P i v) → ∃ f : ∀ i, Ω i, ∀ᶠ i in φ, P i (f i)` | `:28` |
| 2 | `mk_surjective` | `(a : UD φ D) → ∃ f : ∀ i, D i, mk f = a` | `:33` |
| 3 | `mk_zero` | `mk (0 : ∀ i, D i) = 0` — `rfl` | `:41` |
| 4 | `mk_max` | `max (mk f) (mk g) = mk (fun i => max (f i) (g i))` | `:43` |
| 5 | `mk_abs` | `|mk f| = mk (fun i => |f i|)` | `:53` |
| 6 | `UT` | `@[reducible] noncomputable def UT : TemporalOrder := TemporalOrder.of (UD φ (fun i => ↑(T i)))` | `:66` |
| 7 | `uSep` | the `sep` field on the ultraproduct | `:71` |
| 8 | `uShiftSet` | `(S : ∀ i, ShiftSet (T i)) → ShiftSet (UT φ T)`, all 7 fields | `:98` |
| 9 | `los` / `los_truthAt` | the Łoś lemma, both forms | `:123` / `:203` |

Plus, in `IndexFilter.lean`: `Idx`, `tailFilter`, `mem_tailFilter`, `tailFilter_neBot`, `idxUF`,
`eventually_mem`.

### 1.3 One stale citation in the upstream report, corrected

`specs/archive/491_select_dependent_ultraproduct_carrier_route/reports/01_…md` §1 quotes
`SatisfiableBaseSet` as binding `(D : Type) (_ : AddCommGroup D) (_ : LinearOrder D) …`. That
is **no longer the live signature.** `FormalSystem/Metalogic/SetConsequence.lean:225-228` now
reads:

```lean
def SatisfiableBaseSet (Γ : Set Formula) : Prop :=
  ∃ (F : TaskFrame) (M : TaskModel F)
    (τ : WorldHistory F) (_ : τ.IsTotal) (t : F.Duration),
    ∀ ψ ∈ Γ, TruthAt M τ t ψ
```

The four algebra binders were absorbed into `TemporalOrder`
(`FormalSystem/Semantics/TemporalOrder.lean:76`), and `TaskFrame`
(`FormalSystem/Semantics/TaskFrame.lean:1608`) is now `⟨Duration : TemporalOrder, toFibre :
FrameOver Duration⟩`. **The dependency the route was chosen for is unaffected** — each index
still supplies its own `F.Duration : TemporalOrder` — but every signature in the plan must be
written against `T : I → TemporalOrder`, not `D : I → Type` plus binders. The probe itself is
still in the `D : I → Type` + binders form and works unchanged, because `TemporalOrder`'s four
projections are instances (`TemporalOrder.lean:91`), so `∀ i, AddCommGroup ↑(T i)` synthesizes.
Both `example`s confirming this are in the prototype.

---

## 2. The ultrafilter on the index type

### 2.1 Recommended: hand-built up-set filter (verified, 16 lines for the filter itself)

`Filter.atTop` is the textbook route and the one the upstream report named, but it requires a
`Preorder` **instance** on `{L : List Formula // ∀ ψ ∈ L, ψ ∈ Γ}` plus `IsDirectedOrder` and
`Nonempty` (`Filter.atTop_neBot`, verified signature: `∀ {α} [Preorder α] [IsDirectedOrder α]
[Nonempty α], atTop.NeBot`, `Mathlib/Order/Filter/AtTopBot/Basic.lean:66`). Registering a
`Preorder` instance on a `List`-subtype is a global instance-graph commitment for a
single-use order. **Build the filter directly instead.** From `IndexFilter.lean`:

```lean
def tailFilter (Γ : Set α) : Filter (Idx Γ) where
  sets := {s | ∃ L : Idx Γ, {L' : Idx Γ | ∀ ψ ∈ L.val, ψ ∈ L'.val} ⊆ s}
  univ_sets := ⟨⟨[], by simp⟩, fun _ _ => trivial⟩
  sets_of_superset := …            -- transitivity of ⊆
  inter_sets := …                  -- the witness is L1.val ++ L2.val
```

`NeBot` is three lines: `∅ ∈ tailFilter Γ` would give an `L` with `{L' | L ⊆ L'} ⊆ ∅`, refuted
by `L` itself. Then

```lean
noncomputable def idxUF (Γ : Set α) : Ultrafilter (Idx Γ) := Ultrafilter.of (tailFilter Γ)
```

### 2.2 The exact Mathlib lemmas, all verified by `#check`

| Lemma | Verified signature | Source |
|---|---|---|
| `Ultrafilter.of` | `(f : Filter α) → [f.NeBot] → Ultrafilter α` | `Mathlib/Order/Filter/Ultrafilter/Defs.lean:302` |
| `Ultrafilter.of_le` | `∀ (f : Filter α) [f.NeBot], ↑(Ultrafilter.of f) ≤ f` | `:305` |
| `Ultrafilter.em` | `(f : Ultrafilter α) (p) : (∀ᶠ x in f, p x) ∨ ∀ᶠ x in f, ¬p x` | `:158` |
| `Ultrafilter.eventually_not` | `(∀ᶠ x in ↑f, ¬p x) ↔ ¬∀ᶠ x in ↑f, p x` | `:165` |
| `Ultrafilter.eventually_imp` | `(∀ᶠ x in ↑f, p x → q x) ↔ ((∀ᶠ x in ↑f, p x) → ∀ᶠ x in ↑f, q x)` | `:169` |
| `Filter.mem_bot` | `s ∈ (⊥ : Filter α)` | Mathlib |
| `Filter.Eventually.exists` | `[f.NeBot] → (∀ᶠ x in f, p x) → ∃ x, p x` | Mathlib |
| `Filter.eventually_congr` | `(∀ᶠ x in f, p x ↔ q x) → ((∀ᶠ x in f, p x) ↔ ∀ᶠ x in f, q x)` | Mathlib |
| `Classical.skolem` | `(∀ x, ∃ y, p x y) ↔ ∃ f, ∀ x, p x (f x)` | core |
| `Classical.axiomOfChoice` | `(∀ x, ∃ y, r x y) → ∃ f, ∀ x, r x (f x)` | core |

The **key property** that makes the whole construction do work is

```lean
theorem eventually_mem (Γ : Set α) {ψ : α} (hψ : ψ ∈ Γ) :
    ∀ᶠ L in (idxUF Γ : Filter (Idx Γ)), ψ ∈ L.val
```

proved by `Ultrafilter.of_le` applied to the basic set at `L := ⟨[ψ], _⟩`. This is what turns
"each finite sublist is satisfiable at its own model" into "each `ψ ∈ Γ` holds eventually", and
hence — by Łoś — into "each `ψ ∈ Γ` holds in the ultraproduct". **Do not import
`Mathlib.Order.Filter.AtTopBot.*`** on this route; only `Mathlib.Order.Filter.Ultrafilter.Basic`
is needed, and it is already built.

### 2.3 Genericity

`IndexFilter.lean` is stated over `α : Type u` and `Γ : Set α`. Nothing about it is specific to
`Formula`. The implementation may instantiate at `Formula` in the signature or keep the generic
form; the prototype's proofs are unchanged either way.

---

## 3. The precise statement shapes

### 3.1 `ShiftTruth` form (the one that is proved by induction)

```lean
theorem los (S : ∀ i, ShiftSet (T i)) (χ : Formula) :
    ∀ (f : ∀ i, (S i).Carrier) (x : ∀ i, ↑(T i)),
      ShiftTruth (uShiftSet φ S) (omk f) (mk x) χ ↔
        ∀ᶠ i in φ, ShiftTruth (S i) (f i) (x i) χ
```

**The binder order is load-bearing.** `χ` must come before `f` and `x` — either as written above
(with `f` and `x` under a `∀` in the conclusion and `intro f x` opening each case), or via
`induction χ generalizing f x`. The `box` case instantiates the IH at an arbitrary carrier
section `g ≠ f`; the `untl`/`snce` cases instantiate it at arbitrary duration sections `σ`, `ρ`.
An IH fixed at `f`, `x` closes none of the three.

### 3.2 `TruthAt` form (the deliverable the task named)

```lean
theorem los_truthAt (S : ∀ i, ShiftSet (T i)) (f : ∀ i, (S i).Carrier) (x : ∀ i, ↑(T i))
    (χ : Formula) :
    TruthAt (uShiftSet φ S).model ((uShiftSet φ S).hist (omk f)) (mk x) χ ↔
      ∀ᶠ i in φ, TruthAt (S i).model ((S i).hist (f i)) (x i) χ :=
  (ShiftSet.forward_repr _ _ _ _).trans ((los S χ f x).trans
    (eventually_congr (Eventually.of_forall fun i =>
      (ShiftSet.forward_repr (S i) (f i) (x i) χ).symm)))
```

Checked against `TruthAt`'s live signature, `FormalSystem/Semantics/Truth.lean:161-162`:
`TruthAt (M : TaskModel F) (τ : WorldHistory F) (t : F.Duration) : Formula → Prop`. Here
`M := (uShiftSet φ S).model` (`ShiftSet.lean:229`), `τ := (uShiftSet φ S).hist (omk f)`
(`:215`), and `t := mk x : ↑(UT φ T) = (uShiftSet φ S).frame.Duration`.

**Why this is the right `TruthAt` statement and not a weaker one.** It quantifies only over
histories of the form `S.hist w` — the orbits. That is not a restriction: `total_eq_orbit`
(`ShiftSet.lean:245`) proves every total history of `S.frame` *is* an orbit, so the orbits are
exactly `H_F`. A statement over arbitrary total histories of the ultraproduct frame would be
equivalent, and strictly more painful to state, since it would need `total_eq_orbit` re-applied
at the use site anyway.

### 3.3 The `sep` field statement

```lean
theorem uSep (S : ∀ i, ShiftSet (T i)) (w u : UOmega φ (fun i => (S i).Carrier))
    (h : ∀ x : ↑(UT φ T), 0 < x → ∃ y, |y| < x ∧ u = shU (fun i => (S i).sh) w y) : u = w
```

matching `ShiftSet.sep`'s field type (`ShiftSet.lean:110`).

---

## 4. The choice-function arguments, spelled out

All three go through one lemma:

```lean
theorem exists_section {Ω : I → Type} [∀ i, Nonempty (Ω i)] {P : ∀ i, Ω i → Prop}
    (h : ∀ᶠ i in φ, ∃ v, P i v) : ∃ f : ∀ i, Ω i, ∀ᶠ i in φ, P i (f i) := by
  classical
  refine ⟨fun i => if hi : ∃ v, P i v then hi.choose else Classical.arbitrary _, ?_⟩
  exact h.mono (fun i hi => by simp only [dif_pos hi]; exact hi.choose_spec)
```

### 4.1 Which form of choice, and why not `Classical.skolem`

The extraction is **not** `Classical.axiomOfChoice` or `Classical.skolem` applied directly.
Those need `∀ i, ∃ v, P i v` — a *total* existential. What the filter gives is `∀ᶠ i in φ, ∃ v,
P i v`, which is existential only on a `φ`-large set. The section must still be **total**, so
the off-set indices need a junk value; that is what `Classical.arbitrary` supplies and why the
`[∀ i, Nonempty (Ω i)]` binder is mandatory. The underlying choice principle is
`Classical.choice`, entering twice: once through `Exists.choose` (`hi.choose`) and once through
`Classical.arbitrary`. `Classical.propDecidable` (from `classical`) supplies the `dif`.

### 4.2 What is chosen, over what index, in each case

| Site | Index | Chosen from | Nonempty witness |
|---|---|---|---|
| `box`, `→` | all `i : I` | `(S i).Carrier`, a `v` with `¬ ShiftTruth (S i) v (x i) ψ` | `(S i).carrier_nonempty` — install with `haveI : ∀ i, Nonempty ((S i).Carrier) := fun i => (S i).carrier_nonempty` **before** `induction` |
| `untl`/`snce`, `→` (inner bounded `∀`) | all `i : I` | `↑(T i)`, an `r` in the open interval with `¬ ShiftTruth (S i) (f i) r ψ` | `⟨0⟩` — the duration sort is a group |
| `untl`/`snce`, `←` (the `∃ s`) | all `i : I` | `↑(T i)`, the witnessing time `s` | `⟨0⟩` |
| `uSep` | all `i : I` | `↑(T i)`, a separating radius `x` with no admissible shift inside it | `haveI : ∀ i, Nonempty ↑(T i) := fun i => ⟨0⟩` |

### 4.3 The `box` case in full

```lean
| box ψ ih =>
  intro f x
  constructor
  · intro h                                    -- ⊢ ∀ᶠ i, ∀ v, ShiftTruth (S i) v (x i) ψ
    by_contra hc
    have h2 : ∀ᶠ i in φ, ∃ v, ¬ ShiftTruth (S i) v (x i) ψ :=
      (Ultrafilter.eventually_not.mpr hc).mono (fun i hi => not_forall.mp hi)
    obtain ⟨g, hg⟩ := exists_section h2
    obtain ⟨j, hj1, hj2⟩ := (((ih g x).mp (h (omk g))).and hg).exists
    exact hj2 hj1
  · intro h v                                  -- the easy direction
    obtain ⟨g, rfl⟩ := omk_surjective v
    exact (ih g x).mpr (h.mono fun i hi => hi (g i))
```

The `→` direction is by contradiction; the ultrafilter enters at exactly one point,
`Ultrafilter.eventually_not.mpr`, which turns `¬ ∀ᶠ P` into `∀ᶠ ¬P`. This is the **only** step
in the whole `box` case that a mere filter could not do. The `←` direction uses no choice and no
ultrafilter property: `omk_surjective` is `Quotient.exists_rep`.

### 4.4 The `untl` case's inner bounded `∀`

The subtlety that costs the extra 20 lines:

```lean
have h3 : ∀ᶠ i in φ, ∀ r, x i < r → r < σ i → ShiftTruth (S i) (f i) r ψ := by
  by_contra hc
  have h4 : ∀ᶠ i in φ, ∃ r, x i < r ∧ r < σ i ∧ ¬ ShiftTruth (S i) (f i) r ψ :=
    (Ultrafilter.eventually_not.mpr hc).mono (fun i hi => by
      obtain ⟨r, hr⟩ := not_forall.mp hi; exact ⟨r, by tauto⟩)
  obtain ⟨ρ, hρ⟩ := exists_section h4
  have hx := (ihψ f ρ).mp (hg (mk ρ) (mk_lt_mk.mpr (hρ.mono fun i hi => hi.1))
    (mk_lt_mk.mpr (hρ.mono fun i hi => hi.2.1)))
  obtain ⟨j, hj1, hj2⟩ := (hx.and hρ).exists
  exact hj2.2.2 hj1
```

The chosen section `ρ` has to satisfy *three* pointwise conditions at once (`x i < ρ i`,
`ρ i < σ i`, and the negation), because `mk ρ` must land strictly inside the open interval
`(mk x, mk σ)` before `hg` can be applied to it. `tauto` discharges the shuffling of
`not_forall` through two nested implications; a hand-written `push_neg` chain also works.

### 4.5 `uSep`

Contrapositive: assume `¬ (omk g = omk f)`, so `∀ᶠ i, g i ≠ f i` by `Ultrafilter.eventually_not`.
At each such `i`, `(S i).sep` in contrapositive form yields a radius `x` with no admissible
shift inside it — this is where `push_neg` turns `¬ ∃ x, 0 < x ∧ ∀ y, |y| < x → g i ≠ sh (f i) y`
into exactly `sep`'s hypothesis. `exists_section` gives the radius section `ξ`; `mk ξ` is
positive by `mk_zero` + `mk_lt_mk`; the ultraproduct hypothesis at `mk ξ` returns a shift
`mk η` with `|mk η| < mk ξ`, and `mk_abs` converts that to `∀ᶠ i, |η i| < ξ i`. Intersecting the
three eventual sets and taking one index (`Eventually.exists`, using `NeBot`) contradicts the
choice of `ξ j`.

---

## 5. Concrete file layout

### 5.1 New modules

| Module | Contents | Imports | Est. lines |
|---|---|---|---|
| `FormalSystem/Semantics/Ultraproduct/Carrier.lean` | probe items 1–16 of §1.1, **promoted verbatim**, plus `exists_section`, `mk_surjective`, `mk_zero`, `mk_max`, `mk_abs` | `FormalSystem.Semantics.TemporalOrder`, `Mathlib.GroupTheory.QuotientGroup.Basic`, `Mathlib.Order.Filter.Ultrafilter.Basic` | ~230 |
| `FormalSystem/Semantics/Ultraproduct/ShiftSetProduct.lean` | `UT`, `uSep`, `uShiftSet` | `…Ultraproduct.Carrier`, `FormalSystem.Semantics.ShiftSet` | ~90 |
| `FormalSystem/Semantics/Ultraproduct/Los.lean` | `los`, `los_truthAt` | `…Ultraproduct.ShiftSetProduct` | ~110 |
| `FormalSystem/Semantics/Ultraproduct/IndexFilter.lean` | `Idx`, `tailFilter`, `mem_tailFilter`, `tailFilter_neBot`, `idxUF`, `eventually_mem` | `Mathlib.Order.Filter.Ultrafilter.Basic` (and `FormalSystem.Syntax.Formula` only if instantiated at `Formula`) | ~65 |

Namespace: `FormalSystem.Semantics.Ultraproduct` throughout.

### 5.2 Attachment to the build

Add four lines to `FormalSystem/Semantics.lean` (the aggregator, currently
`FormalSystem/Semantics.lean:7-25`), after `import FormalSystem.Semantics.ShiftSet` (`:21`):

```lean
import FormalSystem.Semantics.Ultraproduct.Carrier
import FormalSystem.Semantics.Ultraproduct.IndexFilter
import FormalSystem.Semantics.Ultraproduct.ShiftSetProduct
import FormalSystem.Semantics.Ultraproduct.Los
```

`FormalSystem/Semantics.lean` is reached from `FormalSystem.lean` via
`FormalSystem/FormalSystem.lean`, so this puts the new modules under the `@[default_target]`
`lean_lib FormalSystem` (`lakefile.lean:16-20`) and `lake build` covers them. No lakefile change.

### 5.3 The probe must be retired, not left in parallel

The sequencing note warns against forking a second representation. The same hazard exists
*inside* this task: if `Carrier.lean` copies the probe's declarations while
`Tests/BimodalTest/Semantics/DependentUltraproductProbe.lean` keeps its own, there are two
carrier constructions in one tree. **Reduce the probe to a consumer**: replace its body with an
import of `FormalSystem.Semantics.Ultraproduct.Los` plus the `#print axioms` checks and the
`shiftSetOnUD` elaboration check retargeted at `uShiftSet`. Its docstring's own closing sentence
already licenses this ("Any declaration added here beyond the carrier construction itself is
scope that has leaked out of that work"). The file stays imported from `Tests/BimodalTest.lean`
(`:17`), so the axiom-profile regression check survives.

### 5.4 Out of scope, and where it lands next

`ModelExistenceBase` / `ModelExistenceDense` (`SetConsequence.lean:238`, `:282`) is S4, not this
task. It will need a new module under `FormalSystem/Metalogic/` importing both
`SetConsequence.lean` and `Ultraproduct/Los.lean`, and it consumes: `ShiftSet.ofModel`
(`ShiftSet.lean:360`) and `reverse_repr` (`:377`) to turn each per-index `TaskModel` into a
`ShiftSet`; `idxUF` for the filter; `los_truthAt` for the transfer; `hist_isTotal`
(`ShiftSet.lean:226`) for the `τ.IsTotal` component of `SatisfiableBaseSet`. On the Dense branch
it additionally needs the probe's `DenselyOrdered (UD φ D)` instance (`:188`), which is present
and requires nothing new. Nothing in that list is missing after this task.

---

## 6. Traps recorded from the prototype run

Four things broke on first attempt. All four will break again for anyone transcribing this.

1. **`ShiftTruth` is namespaced.** It is declared inside `namespace ShiftSet`
   (`ShiftSet.lean:114`, def at `:261`), so it is `FormalSystem.Semantics.ShiftSet.ShiftTruth`.
   `open FormalSystem.Semantics` alone is not enough; use
   `open FormalSystem.Semantics.ShiftSet (ShiftTruth)`. Symptom without it: an `autoImplicit`
   error, "Function expected at ShiftTruth but this term has type ?m.1".

2. **`UT` must be `@[reducible]`.** As a plain `noncomputable def`, `(UT φ T).carrier` does not
   reduce to `UD φ (fun i => ↑(T i))` at `rw` motive-typing transparency, and both `rw [← mk_zero]`
   and `rw [mk_abs]` inside `uSep` fail with "Application type mismatch: … expected to have type
   `(UT φ T).carrier`". `TemporalOrder.of` is itself `@[reducible]` for the analogous reason
   (`TemporalOrder.lean:99-102`); `UT` inherits the obligation.

3. **Do not `rw` through `uShiftSet`.** In the `imp` case, `rw [show ShiftTruth (uShiftSet φ S)
   … ↔ _ from Iff.rfl]` fails: `uShiftSet` is semireducible, so `(uShiftSet φ S).Carrier` will
   not reduce during motive typing and `omk f` is rejected as ill-typed. The working form is a
   term-level `Iff.trans`, which checks at default transparency:
   `exact (imp_congr (ihψ f x) (ihχ f x)).trans Ultrafilter.eventually_imp.symm`. The same
   hazard applies anywhere `rw` would need to see through `uShiftSet`'s fields; prefer
   `Iff.trans` / `exact` / `refine` there.

4. **`NeBot` must be in scope for the `bot` case.** `∀ᶠ i in φ, False → False` needs
   `Eventually.exists`, which takes `[f.NeBot]`. It resolves automatically for an
   `Ultrafilter` coercion, but the case is not `Iff.rfl` and a plan that lists `bot` as trivial
   will mis-size it by two lines.

`ShiftSet.lean:286`'s recorded trap (`simpa` failing where the domain equality is definitional)
and the `linarith`-does-not-fire note carried in the `IntTransfer` work did **not** recur, because
`los_truthAt` reuses `forward_repr` rather than re-running a `box` transport by hand.

---

## 7. Adversarial Self-Verification

Every load-bearing claim in this report was re-checked against the live tree or a compiled
prototype. Claims marked `elaborated sorry-free` were produced by `lean_run_code` against the
tree at the session's HEAD, with the reported `#print axioms` output pasted from the tool result.

| Claim | Source / counterexample | Verification method | Confidence |
|---|---|---|---|
| Łoś for `ShiftTruth` is provable, all six cases, no `sorry` | prototype `los` | `lean_run_code`: `'los' depends on axioms: [propext, Classical.choice, Quot.sound]` | High |
| Łoś for `TruthAt` follows in three lines via `forward_repr` | prototype `los_truthAt` | `lean_run_code`, same clean axiom profile | High |
| `ShiftSet.sep` is dischargeable on the ultraproduct with no extra hypothesis | prototype `uSep`; the counterexample to worry about was `sep_not_derivable` (`ShiftSet.lean:498`), which refutes deriving `sep` from the action laws alone — `uSep` does not attempt that, it *transports* each `(S i).sep` | `lean_run_code`, clean axiom profile | High |
| `uShiftSet` discharges all seven `ShiftSet` fields with no hypotheses | prototype `uShiftSet` | `lean_run_code`, clean axiom profile | High |
| The index ultrafilter exists and `eventually_mem` holds | prototype `IndexFilter.lean` | `lean_run_code`: `'eventually_mem' depends on axioms: [propext, Classical.choice, Quot.sound]` | High |
| R2 (choice over total world-histories) does not arise on this route | `ShiftTruth`'s `box` clause quantifies over `S.Carrier` (`ShiftSet.lean:265`), not over histories; `forward_repr`'s `box` case (`:286-292`) closes the gap using `hist_isTotal` (`:226`) and `total_eq_orbit` (`:245`) | Read of `ShiftSet.lean` + compiled `los_truthAt` | High |
| **The task brief's "five cases are mechanical" is wrong** — `untl` and `snce` each need choice too | `ShiftTruth`'s `untl` clause carries `∃ s : D` *and* `∀ r : D` (`ShiftSet.lean:266-267`); the prototype's `untl` case contains two `exists_section` calls | Read of the clause + compiled proof | High |
| `SatisfiableBaseSet` no longer has the signature the upstream 491 report quotes | `SetConsequence.lean:225-228` binds `(F : TaskFrame)` directly; `TaskFrame` is `⟨Duration : TemporalOrder, toFibre⟩` (`TaskFrame.lean:1608`) | Direct `sed` read of both files | High |
| `ShiftSet` is indexed by `TemporalOrder`, not by `Type` + 4 binders | `ShiftSet.lean:83`; the 491 report cites the old `(D : Type)` shape at its §6 anchor table | Direct read | High |
| `Ultrafilter.of`, `of_le`, `em`, `eventually_not`, `eventually_imp` exist with the stated signatures | `Mathlib/Order/Filter/Ultrafilter/Defs.lean:158,165,169,302,305` | `#check` in `lean_run_code`, signatures pasted in §2.2 | High |
| `Filter.atTop_neBot` requires `IsDirectedOrder`, not `IsDirected α (·≤·)` | `#check @Filter.atTop_neBot` returned `[Preorder α] [IsDirectedOrder α] [Nonempty α]`; the 491 report's §5 named `Filter.atTop_neBot` without this binder | `#check` | High |
| `Classical.skolem` / `axiomOfChoice` are the *wrong* form here | both need a total `∀ i, ∃ v`; the filter supplies only `∀ᶠ i, ∃ v`, so a junk value on the complement is unavoidable | `#check` of both + the `[∀ i, Nonempty]` binder being load-bearing in the compiled `exists_section` | High |
| `@[reducible]` on `UT` is required | plain `noncomputable def` produced two `rw` failures in `uSep`, both quoted in §6 | Observed failure then success across two `lean_run_code` runs | High |
| `rw [show … from Iff.rfl]` fails in the `imp` case | observed failure, error message quoted in §6 | Observed failure then success | High |
| Adding four imports to `FormalSystem/Semantics.lean` puts the new modules under `lake build` | `lakefile.lean:16-20` declares `lean_lib FormalSystem` as `@[default_target]` with root `FormalSystem`; `FormalSystem.lean` imports `FormalSystem.FormalSystem` | Direct read of `lakefile.lean`, `FormalSystem.lean`, `FormalSystem/Semantics.lean` | High |
| The prototype's line-count estimates for the new modules | arithmetic on the verified prototype (216 + 62 lines) redistributed across four files, plus module docstrings | Estimate, not measured | **Medium** — the count will move if docstrings are written to this tree's (substantial) standard |
| No full `lake build` was run this session | the prototypes were checked by `lean_run_code`, which elaborates against built oleans but does not exercise the aggregator import or the `autoImplicit := false` / `pp.unicode.fun` `leanOptions` of `lean_lib FormalSystem` (`lakefile.lean:11-14`) | Not performed — out of scope for research | **Flagged**: the implementation's first phase must run `lake build` after adding the imports. `autoImplicit := false` is the specific risk; the prototype ran without it, and any accidentally-implicit variable will surface only under the library options |

### Contradiction log

One contradiction was found and resolved.

- **`untl`/`snce` difficulty.** The task brief says five of six cases are mechanical and only
  `box` is content. The compiled prototype shows `untl` and `snce` each contain two
  `exists_section` calls and are the two longest cases in the file. Precedence: a compiled proof
  outranks a prose estimate. **Resolved in favour of the prototype**; recorded as the §Headline
  correction and reflected in the per-case table.

No unresolved contradictions.

### Recommendations modified after verification

1. The initially-drafted recommendation to build the index filter as `Ultrafilter.of Filter.atTop`
   (following the upstream report's §5) was replaced by the hand-built `tailFilter` after
   `#check @Filter.atTop_neBot` showed it needs a registered `Preorder` **instance** plus
   `IsDirectedOrder` on a `List`-subtype. The hand-built route was then compiled to confirm it is
   not merely cleaner but shorter.
2. The initially-drafted `imp` case (a `rw` through an `Iff.rfl`) was replaced by `Iff.trans`
   after the `rw` failed on the semireducibility of `uShiftSet`.
3. `UT` was changed from `noncomputable def` to `@[reducible] noncomputable def` after two `rw`
   failures inside `uSep`.

---

## 8. Zero-debt note

No `sorry` appears in either prototype and none is required by the route. No new axiom is
introduced. `Classical.choice` is present and expected — it enters through `Exists.choose` and
`Classical.arbitrary` in `exists_section`, through `toDecidableLE := Classical.decRel _` in the
probe's `LinearOrder`, and through `Ultrafilter.of` (the ultrafilter lemma). This matches
`ShiftSet.reverse_repr`'s own profile and the standard recorded in `ShiftSet.lean:56-61`.
`sorryAx` appears nowhere.
