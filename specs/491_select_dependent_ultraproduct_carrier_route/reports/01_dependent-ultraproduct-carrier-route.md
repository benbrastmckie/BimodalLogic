# Selecting the Dependent Ultraproduct Carrier Route

**Scope**: which construction the ultraproduct step (`S2`) should use for the duration carrier
and the history carrier, given that both families are dependent on the index.
**Verification basis**: a 230-line prototype, compiled sorry-free with `lake env lean` against
the live tree (Lean v4.33.0-rc1, Mathlib `79d0395a`), at
`specs/491_select_dependent_ultraproduct_carrier_route/prototype/DependentUltraproduct.lean`.
**Out of scope by instruction**: the Łoś lemma. Nothing here proves it or any clause of it.

---

## Headline

| Question | Answer | Evidence |
|---|---|---|
| Route (a) — bespoke dependent quotient | **SELECTED**, and already verified in prototype | `DependentUltraproduct.lean` compiles; `#print axioms` clean on three probes |
| Route (b) — carrier normalization first | **NO-GO** | §3: the only normalization theorem in the tree is Discrete-only, and Discrete is exactly where compactness is *refuted* |
| Instance burden of route (a) | **5 instances** (6 for the Dense branch), not ~15 | §2.2, measured |
| Mathlib build cost of `Filter.Germ`/`FilterProduct` | **8 seconds, 5 modules** — measured, and the import is *not needed* anyway | §4 |

The design document's risk R1 (`specs/archive/361_.../design/02_compactness-route.md:209`, "the single
largest unknown in the whole estimate") is **retired**. It is not the largest unknown; it is a
half-day of mechanical quotient plumbing, and the plumbing is written.

---

## 1. The dependency is real, and it is on *both* sorts

`SatisfiableBaseSet` (`FormalSystem/Metalogic/SetConsequence.lean:227`) binds the duration
carrier existentially *per instance*:

```lean
def SatisfiableBaseSet (Γ : Set Formula) : Prop :=
  ∃ (D : Type) (_ : AddCommGroup D) (_ : LinearOrder D) (_ : IsOrderedAddMonoid D)
    (_ : Nontrivial D)
    (F : TaskFrame D) (M : TaskModel F)
    (τ : WorldHistory F) (_ : τ.IsTotal) (t : D),
    ∀ ψ ∈ Γ, TruthAt M τ t ψ
```

So the hypothesis of `ModelExistenceBase` (`:239`) supplies, for each `L` in the index type
`I := {L : List Formula // ∀ ψ ∈ L, ψ ∈ Γ}`, a *separately chosen* `D_L`. Nothing forces two
indices to agree.

The second sort is dependent for an independent reason: `ShiftSet.Carrier`
(`FormalSystem/Semantics/ShiftSet.lean:80`) is a **field** of the structure, so even at a fixed
`D` the family `(Ω_L)` varies. Route (b) would have to normalize both, not one.

Mathlib's position, re-verified this session:

- `Filter.Germ` (non-dependent) carries the full stack — `LinearOrder` at
  `Mathlib/Order/Filter/FilterProduct.lean:92` (via `Lattice.toLinearOrder`, `Classical`),
  `IsOrderedAddMonoid` via `to_additive` on `Mathlib/Order/Filter/Germ/OrderedMonoid.lean:32`.
- `Filter.Product` (the dependent version, `Mathlib/Order/Filter/Germ/Basic.lean:93`) carries
  **exactly two** instances in the whole of Mathlib: `Product.coeTC` (`:100`) and
  `Product.instInhabited` (`:103`). No algebra, no order. Confirmed by reading the file, not by
  search.

## 2. Route (a) — selected, and verified

### 2.1 The finding that changes the cost: `AddCommGroup` is free

The design document assumed a raw `Quotient` of a setoid, which forces every group field to be
hand-lifted. It does not have to be a raw setoid. Define the **eventually-zero subgroup** of the
Pi group and quotient by it:

```lean
def evZero : AddSubgroup (∀ i, D i) where
  carrier := {f | ∀ᶠ i in φ, f i = 0}
  zero_mem' := Eventually.of_forall fun _ => rfl
  add_mem'  := ...
  neg_mem'  := ...

abbrev UD := (∀ i, D i) ⧸ evZero φ D
```

`Pi.addCommGroup` supplies the group on `∀ i, D i`; `QuotientAddGroup.Quotient.addCommGroup`
(the `to_additive` image of `QuotientGroup/Defs.lean:152`) then supplies `AddCommGroup (UD φ D)`
with **no hand-written fields at all** — no `add`, `neg`, `sub`, `nsmul`, `zsmul`, and none of
their ~11 axioms. `QuotientAddGroup.eq` gives the extensional characterization in two lines
(`mk_eq_mk` in the prototype).

`ShiftSet.lean` **already imports** `Mathlib.GroupTheory.QuotientGroup.Basic` (`:10`), so this
costs zero new dependencies.

### 2.2 The exact instance list route (a) requires

Measured against the compiled prototype, not estimated:

| # | Obligation | Status | Prototype site | Notes |
|---|---|---|---|---|
| — | `AddCommGroup (UD φ D)` | **free** | — | `QuotientAddGroup.Quotient.addCommGroup` |
| 1 | `AddSubgroup` `evZero` (3 fields) | hand | `:28` | `zero_mem'`, `add_mem'`, `neg_mem'`; 8 lines |
| 2 | `LE (UD φ D)` | hand | `:57` | `Quotient.liftOn₂'` + one well-definedness proof; 9 lines |
| 3 | `LinearOrder (UD φ D)` | hand | `:69` | 5 fields: `le_refl`, `le_trans`, `le_antisymm`, `le_total`, `toDecidableLE := Classical.decRel _`. `lt`, `min`, `max`, `compare` all take defaults. 31 lines |
| 4 | `IsOrderedAddMonoid (UD φ D)` | hand | `:101` | **one** field, `add_le_add_left`; 9 lines |
| 5 | `Nontrivial (UD φ D)` | hand | `:129` | needs `[∀ i, Nontrivial (D i)]` + `φ.neBot`; 5 lines |
| 6 | `DenselyOrdered (UD φ D)` | hand | `:136` | **Dense branch only**; needs `[∀ i, DenselyOrdered (D i)]`; 14 lines |

Support lemmas the instances need (all short, all compiled): `mem_evZero` (`:38`),
`mk_eq_mk` (`:47`), `mk_le_mk` (`:66`, `Iff.rfl`), `not_eventually_false` (`:113`),
`mk_lt_mk` (`:117`, the one place the *ultrafilter* property is used besides `le_total`).

**Only two proofs anywhere in the file need `φ` to be an ultrafilter rather than a filter**:
`le_total` and the `→` half of `mk_lt_mk`, both via `Ultrafilter.em`. Everything else is filter-generic.

**Corrected estimate**: 5 instances (6 with Dense) + 1 subgroup + 5 support lemmas. The design
doc's "roughly 15 hand-supplied instances" over-counts by about 3×, because it priced the group
structure that `QuotientAddGroup` gives away.

### 2.3 The history carrier

`Ω*` needs no algebra at all — a plain eventual-equality `Setoid` on `∀ i, Ω i`, six lines
(`carrierSetoid`, `:154`). The shift action lifts through `Quotient.liftOn₂'` (`shU`, `:176`),
and **both** shift-set action laws are then free:

- `shU_zero` (`:187`) — discharges `ShiftSet.sh_zero`
- `shU_add` (`:194`) — discharges `ShiftSet.sh_add`

### 2.4 R3 (`Type`, not `Type*`) is discharged at the quotient

`shiftSetOnUD` (`:213`) elaborates `ShiftSet (UD φ D)` — which is only well-typed if
`UD φ D : Type`, since `ShiftSet` binds `(D : Type)` (`ShiftSet.lean:77`). With `I : Type` and
each `D i : Type`, the Pi type and its quotient stay in `Type`. R3 is therefore checked by the
compiler here, not asserted.

### 2.5 Axiom audit of the prototype

```
'UProto.shiftSetOnUD'            depends on axioms: [propext, Classical.choice, Quot.sound]
'UProto.shU_add'                 depends on axioms: [propext, Classical.choice, Quot.sound]
'UProto.instDenselyOrderedUD'    depends on axioms: [propext, Classical.choice, Quot.sound]
```

No `sorryAx`; `grep -c sorry` returns 0. `Classical.choice` enters through
`toDecidableLE := Classical.decRel _` and the two `choose` calls in `Nontrivial`/`DenselyOrdered`
— expected and acceptable at this repository's standard, matching `reverse_repr`'s own profile.

## 3. Route (b) — NO-GO

### 3.1 What task 475 actually supplies

`FormalSystem/Semantics/IntTransfer.lean` is a genuine, well-built transport of the *entire*
semantic stack: `TaskFrame.map` (`:88`), `TaskModel.map` (`:140`), `WorldHistory.map` (`:147`),
`Aligned` (`:178`), `WorldHistory.comap` (`:203`), `truthAt_map` (`:254`), and the headline
`validDiscrete_iff_validInt` (`:356`).

**Every one of these is indexed by `e : D ≃+o E` — an isomorphism.** There is no embedding
variant anywhere in the file, and `comap` (`:203`) is built from `e.symm`, so the isomorphism is
load-bearing rather than incidental.

### 3.2 Why that machinery cannot normalize this family — three independent reasons

**(i) The normalization theorem it composes with is Discrete-only.** The isomorphism that
`validDiscrete_iff_validInt` consumes is `intIso : D ≃+o ℤ`
(`FormalSystem/Semantics/DurationClassification.lean:252`), stated inside
`section SuccessorBranch` under `[SuccOrder D]` and `[IsSuccArchimedean D]`. Neither binder is
available for `FrameClass.Base` or `FrameClass.Dense`, whose carriers are arbitrary nontrivial
ordered abelian groups. There is no analogous classification for them, in this tree or in
Mathlib.

**(ii) The one class where normalization exists is the one where compactness is false.**
`FormalSystem/Metalogic/DiscreteNonCompactness.lean:250` proves
`discrete_consequence_not_compact : ¬ CompactDiscrete`, and `:280` proves
`strongCompletenessDiscrete_refuted`. So route (b)'s only working instance normalizes into a
class where the target theorem is refuted. This is not a coincidence to be worked around —
Archimedean-successor structure is precisely what both makes `intIso` possible and makes the set
`{F p} ∪ {¬Xⁿ p}` unsatisfiable.

**(iii) A class-wide normalization is impossible on cardinality grounds.** `SatisfiableBaseSet`
binds `D : Type`, i.e. `Type 0`, which contains nontrivial linearly ordered abelian groups of
unboundedly large cardinality (free abelian groups of arbitrary rank under a lexicographic order
on a well-ordering of the basis). For any candidate common carrier `D₀ : Type`, there is a
`D : Type` with `|D| > |D₀|`, so no `D ≃+o D₀` and indeed no injection. A common carrier for the
whole class does not exist.

### 3.3 The weakened form of (b) does not survive either

One could weaken "isomorphism to a fixed `D₀`" to "order-and-group **embedding** into a
per-family `D₀`" (e.g. Hahn embedding — Mathlib does have
`Mathlib/Algebra/Order/Module/HahnEmbedding.lean`). This fails for a reason that is about the
semantics, not the algebra: transporting a task model along a *proper* embedding `D ↪ D₀`
requires interpreting the task relation at the **new** durations in `D₀ \ D`, and
`WorldHistory.IsTotal` demands the history be defined at every one of them. That is a genuine
model-construction obligation — of the same order of difficulty as the ultraproduct itself, and
subject to the same `limit`/`comp` obstructions. It is not a transport, and 475 supplies nothing
for it.

### 3.4 What of 475 *is* worth reusing

Not machinery — a **template**. `truthAt_map` (`:254`) is a completed six-case induction over
`Formula` (`atom`, `bot`, `imp`, `box`, `untl`, `snce`) transferring `TruthAt` across a change of
carrier, with the `box` case handled explicitly at `:283-290`. The Łoś lemma of `S3` has the same
shape, and two things there transfer directly:

- the `←` direction of the `box` case is `comap`-shaped in both settings;
- the two recorded tactic traps (`:286` — `simpa` fails where the domain equality is
  definitional; and the `linarith`-does-not-fire note carried in the 475 summary) apply verbatim
  to a proof written the same way.

The `→` direction of Łoś's `box` case is *not* covered — that is R2's choice-function argument,
and `truthAt_map` gets it for free only because `e` is invertible. This should be stated plainly
in the plan so nobody mistakes the template for a solution.

## 4. Mathlib build cost — measured, and the concern is retired

Transitive-import closure of `Mathlib.Order.Filter.FilterProduct`, computed against this
checkout: **1328 Mathlib modules, of which 1323 already had oleans.** The five missing were
`Order.Filter.Germ.Basic` (765 LOC), `Order.Filter.FilterProduct` (137), `Order.Filter.Ring`
(60), `Order.Filter.Germ.OrderedMonoid` (49), `Data.Sym.Sym2.Init` (19).

Measured build, via `lake-build-guard.sh build -- build +Mathlib.Order.Filter.FilterProduct`:

```
✔ [716/719] Built Mathlib.Order.Filter.Germ.Basic (1.8s)
✔ [717/719] Built Mathlib.Order.Filter.Germ.OrderedMonoid (501ms)
✔ [718/719] Built Mathlib.Order.Filter.Ring (512ms)
✔ [719/719] Built Mathlib.Order.Filter.FilterProduct (919ms)
Build completed successfully (719 jobs).   exit=0  elapsed=8s
```

**Eight seconds.** The premise that importing these "triggers a Mathlib build" is true only in
the trivial sense. *Side effect to record*: those five oleans now exist in the checkout; the
Mathlib olean count went from 1840 to 1845. Nothing else changed.

**Recommendation nonetheless: do not import them.** The 8 seconds buys `Filter.Product`, which
has only `coeTC` and `Inhabited` — nothing route (a) needs. `Mathlib.Order.Filter.Ultrafilter.Basic`
and `.Defs` are already built and supply everything used (`Ultrafilter.em`, `Ultrafilter.of`,
`Filter.exists_ultrafilter_le`). The prototype imports exactly
`FormalSystem.Semantics.ShiftSet` + `Mathlib.Order.Filter.Ultrafilter.Basic`.

## 5. What `S2` still owes after this decision (explicitly not done here)

Named so the plan sizes them, not because this report attempts them:

1. **The ultrafilter on the index type.** Give `I := {L : List Formula // ∀ ψ ∈ L, ψ ∈ Γ}` the
   preorder `L ≤ L' := L.val ⊆ L'.val`; it is `Nonempty` (`[]`) and directed (`++`), so
   `Filter.atTop_neBot` (`Mathlib/Order/Filter/AtTopBot/Basic.lean:66`, olean present) applies and
   `Ultrafilter.of` (`Ultrafilter/Defs.lean:302`) with `Ultrafilter.of_le` (`:305`) yields a `φ`
   containing every up-set `{L' | L ⊆ L'}`. This is the step that makes each `ψ ∈ Γ` eventually
   true.
2. **`ShiftSet.sep` on the ultraproduct** — the one structure field the prototype leaves as a
   hypothesis (`shiftSetOnUD`'s `hsep`). It is first-order (that is `424`'s gate finding), so it
   *is* Łoś-preserved, but the `∀x ∃y` alternation needs the same pointwise-choice extraction as
   the `box` case. Belongs with `S3`'s machinery, not before it.
3. `carrier_nonempty` and the valuation `A` on `Ω*` — both routine given a per-index witness.

## 6. Verified anchors (all read against the live tree this session)

| Symbol | Location | Note |
|---|---|---|
| `SatisfiableBaseSet` / `ModelExistenceBase` | `Metalogic/SetConsequence.lean:227` / `:239` | `D` bound per instance — the source of the dependency |
| `SatisfiableDenseSet` / `ModelExistenceDense` | `:271` / `:283` | adds `DenselyOrdered` |
| `structure ShiftSet` | `Semantics/ShiftSet.lean:77-107` | `(D : Type)`, 4 instance binders, `Carrier : Type` as a **field** |
| `ShiftSet.forward_repr` / `reverse_repr` | `:263` / `:362` | the representation `S2`/`S3` build on |
| `Filter.Product` | `Mathlib/Order/Filter/Germ/Basic.lean:93` | instances present: `coeTC` (`:100`), `Inhabited` (`:103`). Nothing else |
| `Filter.Germ.instLinearOrder` | `Mathlib/Order/Filter/FilterProduct.lean:92` | non-dependent only |
| `Filter.Germ.instIsOrderedAddMonoid` | `Mathlib/Order/Filter/Germ/OrderedMonoid.lean:32` | non-dependent only |
| `QuotientGroup.Quotient.commGroup` | `Mathlib/GroupTheory/QuotientGroup/Defs.lean:152` | `to_additive` image is the free `AddCommGroup` |
| `IsOrderedAddMonoid` | `Mathlib/Algebra/Order/Monoid/Defs.lean:27` | one required field |
| `Ultrafilter.of` / `.of_le` / `Filter.exists_ultrafilter_le` | `Mathlib/Order/Filter/Ultrafilter/Defs.lean:302` / `:305` / `:293` | olean present |
| `Filter.atTop_neBot` | `Mathlib/Order/Filter/AtTopBot/Basic.lean:66` | olean present |
| `intIso` | `Semantics/DurationClassification.lean:252` | inside `section SuccessorBranch` (`:173`), `[IsSuccArchimedean D]` |
| `TaskFrame.map` / `truthAt_map` | `Semantics/IntTransfer.lean:88` / `:254` | both require `e : D ≃+o E` |
| `discrete_consequence_not_compact` | `Metalogic/DiscreteNonCompactness.lean:250` | Discrete compactness refuted |

## 7. Rejected variants, recorded so they are not reopened

- **Mathlib `Filter.Product` + hand instances.** Same hand-instance burden as route (a), plus a
  new import, minus the free `AddCommGroup` (its setoid is not a subgroup quotient). Strictly worse.
- **Make the family non-dependent by re-typing every `D_i` to a fixed type of the same
  cardinality.** Even granting the bijections, the *operations* still vary per index, so
  `Filter.Germ`'s instances — which are built from one fixed algebraic structure on `β` — still
  do not apply. No gain.
- **Mathlib `FirstOrder.Language`.** Already rejected upstream (`design/02_compactness-route.md`):
  single-sorted, and the two-sorted encoding cost dominates. Nothing found this session changes that.
- **Downward Löwenheim–Skolem to bound the carriers first.** Not available for this bespoke
  two-sorted setting, and would be strictly more work than route (a) even if it were.

## 8. Zero-debt note

No `sorry` and no new axiom appears anywhere in the prototype, and none is required by the route
it selects. The three obligations listed in §5 are *unstarted work with known routes*, not gaps
being deferred: each names the Mathlib or tree anchor that discharges it.
