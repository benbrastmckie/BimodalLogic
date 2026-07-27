# Research Report: Semantic Finite Model Property for TM

| Field | Value |
|-------|-------|
| Task | 165 — `establish_semantic_finite_model_property` |
| Task type | `lean4` |
| Session | `sess_1785192047_8c5899` |
| Date | 2026-07-27 |
| Mode | hard (H2 anti-analysis, H3 reference grounding, H4 adversarial verification; H5 not triggered) |
| Grounding tier | Tier 3 (implementation-backed), with Tier 1 cross-references |
| Status | researched |
| Toolchain | Lean v4.33.0-rc1, Mathlib tag `v4.33.0-rc1` (commit `79d0395a`) |

## Executive Summary

The semantic FMP for TM is **substantially easier than the task charter assumes**, and the
charter's central premise is wrong in a way that changes the whole plan.

The charter says: *"Prove the filtration lemma for all formula constructors including Until/Since
(known to be problematic for naive filtration)."* That difficulty is real for standard temporal
Kripke semantics, where **time points are the worlds** and filtration collapses them. It does not
arise in this repository's semantics. Here a point of evaluation is a pair `(τ, t)` of a
`WorldHistory` and a time `t : D`; `TruthAt` for `untl`/`snce` quantifies over times in the
**ambient ordered group `D`, along a fixed history**. A filtration that quotients only *world
states* and leaves `D` untouched therefore has nothing to break.

I confirmed this by compiling the full construction and the complete six-constructor filtration
lemma against the live tree (`lean_run_code`, success, zero diagnostics beyond four
`unusedSimpArgs` lints). The `untl` and `snce` cases are three-line term proofs.

Two consequences reshape the plan:

1. **The hard obligation is not the filtration lemma.** It is deciding what "finite model" means,
   because I verified that `D` **can never be finite**: `Nontrivial D` + the ordered-group binders
   force `Infinite D` (Mathlib closes it by `infer_instance`). What is achievable is the **finite
   *frame* property**: `Finite F'.WorldState` with `Nat.card = 2 ^ |cl(φ)|` exactly. The set of
   admissible histories `Ω'` remains infinite. This is a genuine FMP-shaped theorem and matches
   the existing `Semantics.FiniteTaskFrame` / `FiniteTaskModel` target types, but it is **not**
   a decision procedure by model enumeration.

2. **Compositionality across TM's extensions is free.** I read all five validity predicates and
   they differ *only* in typeclass/hypothesis binders on `D` — `valid`, `ValidDense`,
   `ValidDiscrete`, `ValidDedekind`, `ValidDedekindDense` place no constraint whatsoever on `F`,
   `M`, or `Omega`. A `D`-preserving filtration preserves `DenselyOrdered`, `SuccOrder`,
   `PredOrder`, `IsSuccArchimedean`, `IsPredArchimedean` and the LUB hypothesis *by construction*,
   because it never touches `D`. One construction plus one truth lemma yields the FMP for every
   frame class as a one-line corollary. This is exactly the "elegant, maintainable long-term
   infrastructure" the focus prompt asks for, and it is available without any parametrisation
   machinery.

## Findings

### F1. The existing FMP is purely syntactic — confirmed by exhaustive grep

`grep -rn 'TruthAt' FormalSystem/Metalogic/Decidability/FMP/` returns **zero hits**. Nothing in
the five FMP modules mentions `TaskModel`, `WorldHistory`, or `Omega`. The construction quotients
`ClosureMCSBundle φ` (sets of formulas) by agreement on `subformulaClosure φ` and proves the
quotient finite. It is a filtration of *syntax*, not of a model.

The repo's own curated documentation already says this:
`typst/chapters/p2-decidability-practice.typ:26-28` — *"the bridge connecting 'true in every
closure MCS bundle' to semantic validity in the task-frame sense is an open problem."*

### F2. Two live theorems are vacuous and violate the project's own rule

`.claude/rules/lean4.md` prohibits `theorem Foo := trivial`-shaped placeholders as "semantically
equivalent to `sorry`". Two shipped FMP theorems are exactly that:

- `FormalSystem/Metalogic/Decidability/FMP/FMP.lean:183` `filtered_world_bound` —
  `∃ n, n ≤ 2 ^ (subformulaClosure phi).card ∧ ∀ (_S : FilteredWorld phi), True`
- `FormalSystem/Metalogic/Decidability/FMP/FMP.lean:237` `fmp_size_bound` —
  `∃ bound, bound = 2 ^ (subformulaClosure phi).card ∧ True`

The advertised `2^|cl(φ)|` bound is **not proved anywhere**, despite being cited as established
in `latex/subfiles/04-Metalogic.tex:350-352` and `typst/chapters/p2-decidability-practice.typ:42`.

### F3. The semantics never quotients time — this is the crux

`FormalSystem/Semantics/Truth.lean:128-137`:

```lean
def TruthAt (M : TaskModel F) (Omega : Set (WorldHistory F))
    (τ : WorldHistory F) (t : D) : Formula → Prop
  | Formula.atom p => ∃ (ht : τ.domain t), M.valuation (τ.states t ht) p
  | Formula.bot => False
  | Formula.imp φ ψ => TruthAt M Omega τ t φ → TruthAt M Omega τ t ψ
  | Formula.box φ => ∀ (σ : WorldHistory F), σ ∈ Omega → TruthAt M Omega σ t φ
  | Formula.untl φ ψ => ∃ s : D, t < s ∧ TruthAt M Omega τ s φ ∧
      ∀ r : D, t < r → r < s → TruthAt M Omega τ r ψ
  | Formula.snce φ ψ => ∃ s : D, s < t ∧ TruthAt M Omega τ s φ ∧
      ∀ r : D, s < r → r < t → TruthAt M Omega τ r ψ
```

Three structural facts follow, and together they dissolve the Until/Since problem:

- **`TruthAt` never mentions `TaskRel`.** The frame relation enters truth *only* indirectly, via
  the `respects_task` well-formedness field of `WorldHistory`. Consequently the coarseness of the
  filtered task relation is irrelevant to the truth lemma.
- **`box` quantifies over `Omega` at the *same* time `t`.** It is a universal (S5) modality with
  no accessibility relation to filter. If `Ω'` is defined as the image of `Ω`, the `box` case of
  the filtration lemma is immediate — there is no filtration condition to check at all.
- **`untl`/`snce` quantify over `D` along a *fixed* `τ`.** If the induction hypothesis is
  generalised over all `τ ∈ Ω` and all `t : D` (which it must be anyway for `box`), the
  `untl`/`snce` cases are a mechanical repackaging of the existential.

The classical Gabbay obstruction ("Until is not preserved by filtration") concerns temporal Kripke
frames where time points *are* the worlds being collapsed. It does not apply to a construction
that quotients only the `WorldState` component.

### F4. VERIFIED: the temporal type `D` can never be finite

```lean
example (D : Type) [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D] [Nontrivial D] :
    Infinite D := by infer_instance
```
compiles (`lean_run_code`, success, zero diagnostics). `Nontrivial D` is a binder of `valid`
(`Validity.lean:80`) and of every extension predicate. Therefore:

- "φ is satisfiable in a finite task model" **cannot** mean a model with finitely many time
  points, on pain of vacuity.
- The correct target is `Semantics.FiniteTaskFrame` (`TaskFrame.lean:293`), whose `finite_world`
  field constrains only `WorldState`. That structure already exists and is already the declared
  FMP packaging target (`TaskFrame.lean:290-291`).
- Any plan step phrased as "bound the model size" must be read as "bound the world-state count".

### F5. VERIFIED: the frame classes constrain only `D`, so the FMP is compositional for free

Read verbatim at `FormalSystem/Semantics/Validity.lean:79, 169, 187, 231, 255`. The binder lists:

| Predicate | Extra binders beyond `AddCommGroup/LinearOrder/IsOrderedAddMonoid/Nontrivial` |
|-----------|-------------------------------------------------------------------------------|
| `valid` | — |
| `ValidDense` | `[DenselyOrdered D]` |
| `ValidDiscrete` | `[SuccOrder D] [PredOrder D] [IsSuccArchimedean D] [IsPredArchimedean D]` |
| `ValidDedekind` | `(_ : ∀ s : Set D, s.Nonempty → BddAbove s → ∃ x, IsLUB s x)` |
| `ValidDedekindDense` | the above `+ [DenselyOrdered D]` |

**Every extra binder is on `D` alone.** `F : TaskFrame D`, `M : TaskModel F`,
`Omega : Set (WorldHistory F)` are unconstrained in all five. Since the filtration keeps `D` and
its instances literally unchanged, each class-specific FMP is a corollary requiring no new
mathematics. This is the single most important architectural finding for the focus prompt: the
compositional infrastructure the user wants is obtained by *not parametrising*, rather than by
building a parametrised filtration framework.

`FrameClass` itself (`FormalSystem/ProofSystem/Axioms.lean:449-482`) already carries a
`PartialOrder` (`Base ≤ all`, `Dense ≤ Dedekind`, `Discrete` incomparable), so a future
`fmp_of_frameClass` indexed by `fc : FrameClass` has a ready-made lattice to hang off if a
uniform statement is later wanted.

### F6. VERIFIED: the complete construction and six-constructor filtration lemma compile

I compiled the following against the live tree via `lean_run_code`. **Result: success, zero
errors**; the only diagnostics were four `linter.unusedSimpArgs` warnings inside the frame-axiom
proof. This is machine-checked evidence, not a sketch.

```lean
/-- Largest-filtration frame: universal task relation away from duration 0.
    Generalises the existing `RefinedFilteredTaskFrame` to an arbitrary world type. -/
def univFrame (D : Type) [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D]
    (W : Type) : TaskFrame D where
  WorldState := W
  TaskRel := fun w d u => if d = 0 then w = u else True
  nullity_identity := ...   -- `by intro w u; simp`
  forward_comp := ...       -- x,y ≥ 0 and x+y=0 forces x=y=0
  converse := ...           -- case split on d = 0

/-- The filtered world type: subsets of the closure. -/
abbrev FiltW (cl : Finset Formula) : Type := Set {χ : Formula // χ ∈ cl}

/-- The semantic type of the point `(τ, t)` relative to `cl`. -/
def ptType {F : TaskFrame D} (M : TaskModel F) (Om : Set (WorldHistory F))
    (cl : Finset Formula) (τ : WorldHistory F) (t : D) : FiltW cl :=
  fun χ => TruthAt M Om τ t χ.1

def filtFrame (D) (cl : Finset Formula) : TaskFrame D := univFrame D (FiltW cl)

def filtModel ... : TaskModel (filtFrame D cl) where
  valuation := fun A p => ∃ h : (Formula.atom p) ∈ cl, A ⟨Formula.atom p, h⟩

def filtHist ... (τ : WorldHistory F) : WorldHistory (filtFrame D cl) where
  domain := fun _ => True
  convex := by intros; trivial
  states := fun t _ => ptType M Om cl τ t
  respects_task := ...      -- `t - s = 0` forces `s = t`; otherwise `True`

def filtOm ... : Set (WorldHistory (filtFrame D cl)) := (fun τ => filtHist M Om cl τ) '' Om

structure SubClosed (cl : Finset Formula) : Prop where
  imp  : ∀ a b, a.imp b ∈ cl → a ∈ cl ∧ b ∈ cl
  box  : ∀ a, a.box ∈ cl → a ∈ cl
  untl : ∀ a b, a.untl b ∈ cl → a ∈ cl ∧ b ∈ cl
  snce : ∀ a b, a.snce b ∈ cl → a ∈ cl ∧ b ∈ cl

/-- **Filtration lemma** (semantic). PROVED, all six constructors. -/
theorem filtration_lemma {F : TaskFrame D} (M : TaskModel F) (Om : Set (WorldHistory F))
    (cl : Finset Formula) (hcl : SubClosed cl) :
    ∀ (χ : Formula), χ ∈ cl → ∀ τ ∈ Om, ∀ t : D,
      (TruthAt M Om τ t χ ↔
        TruthAt (filtModel M Om cl) (filtOm M Om cl) (filtHist M Om cl τ) t χ)
```

Proof shape per constructor, as compiled:

| Constructor | Proof | Notes |
|-------------|-------|-------|
| `atom p` | `⟨fun h => ⟨trivial, hp, h⟩, fun ⟨_, _, h⟩ => h⟩` | Domain-partiality of `τ` is absorbed into the type; `filtHist` may safely take a **total** domain. |
| `bot` | `simp only [TruthAt]` | Both sides `False`. |
| `imp` | `imp_congr (iha ..) (ihb ..)` | |
| `box` | `rintro h σ' ⟨σ, hσ, rfl⟩` / `Set.mem_image` | **No filtration condition**; follows from `Ω' = image Ω`. |
| `untl` | `⟨s, hts, (iha ..).mp hsa, fun r h1 h2 => (ihb ..).mp (hguard r h1 h2)⟩` | IH applied at other times along the **same** `τ`. |
| `snce` | mirror of `untl` | |

Design decisions this settles:
- `filtHist.domain := fun _ => True` is sound and strictly simplifies `convex` and
  `respects_task`. Atom domain-sensitivity is already recorded in `ptType`.
- `FiltW cl := Set ↥cl` (the **full** powerset, not the image subtype) is the right world type:
  it is `Prop`-valued so no decidability or `Classical` machinery is needed anywhere, and
  `nullity_identity` still holds because the universal relation is used.
- `univFrame` should be extracted as a **reusable combinator**; the existing
  `RefinedFilteredTaskFrame` (`Filtration.lean:197-249`) becomes `univFrame D (FilteredWorld phi)`
  with its proof reused verbatim.

### F7. VERIFIED: the required closure conditions already exist in the repo

```lean
theorem subformulaClosure_subClosed (φ : Formula) : SubClosed (subformulaClosure φ) where
  imp  := fun a b h => ⟨closure_imp_left φ a b h, closure_imp_right φ a b h⟩
  box  := fun a h => closure_box φ a h
  untl := fun a b h => ⟨closure_untl_left φ a b h, closure_untl_right φ a b h⟩
  snce := fun a b h => ⟨closure_snce_left φ a b h, closure_snce_right φ a b h⟩
```
**Compiles.** Every discharging lemma is an existing sorry-free declaration in
`FormalSystem/Syntax/SubformulaClosure/Closure.lean` (lines 241, 251, 261, 291, 301, 311, 321).

Critically: the semantic filtration needs **only subformula closure**. It does *not* need negation
closure (`closureWithNeg`), G/H enrichment (`ghEnrichment`), Fischer–Ladner unwinding
(`extendedDeferralClosure`), or `neg_pairing`. Those are required for *maximal-consistent-set*
constructions, where a world is a set of formulas that must decide each member. Here a world is a
`Set` (a `Prop`-valued predicate) read off from an existing model, so it decides everything
automatically. The `¬¬ψ`-escapes-the-closure hazard recorded at
`Boneyard/BXCanonicalQuasimodel/EnrichedClosure.lean:60-65` therefore **does not arise**.

### F8. VERIFIED: the exact `2 ^ |cl(φ)|` bound is immediately provable

```lean
example (φ : Formula) :
    Nat.card (Set {χ : Formula // χ ∈ subformulaClosure φ})
      = 2 ^ (subformulaClosure φ).card := by
  rw [Nat.card_eq_fintype_card, Fintype.card_set, Fintype.card_coe]
```
**Compiles.** Note this is an **equality**, stronger than the `≤` the charter asks for. For an
image-subtype world type the `≤` version goes through `Nat.card_le_card_of_injective` (also
verified). This directly replaces the vacuous `fmp_size_bound` (F2).

### F9. VERIFIED: `Ω'` is shift-closed, via an existing repo lemma

```lean
example ... (h_sc : ShiftClosed Om) (τ : WorldHistory F) (Δ t : D) (χ : Formula) :
    TruthAt M Om (WorldHistory.timeShift τ Δ) t χ ↔ TruthAt M Om τ (t + Δ) χ := by
  have h := FormalSystem.Semantics.TimeShift.time_shift_preserves_truth M Om h_sc τ t (t + Δ) χ
  simpa using h
```
**Compiles.** Since `ptType M Om cl (timeShift τ Δ) t = ptType M Om cl τ (t + Δ)` follows, we get
`filtHist (timeShift τ Δ) = timeShift (filtHist τ) Δ` and hence `ShiftClosed (filtOm M Om cl)`
whenever `ShiftClosed Om`. This matters because `valid` and every extension predicate carry a
`ShiftClosed Omega` binder; without it the FMP would not be the converse of soundness.

`time_shift_preserves_truth` (`Truth.lean:446`) is also the **structural template** for the
filtration lemma — same `induction φ generalizing x y σ` shape, same six cases, already proved
sorry-free in this tree.

### F10. VERIFIED: Mathlib offers nothing for modal filtration

- `lean_leansearch "filtration of a Kripke model in modal logic, finite model property"` returns
  only `Mathlib.RingTheory.FilteredAlgebra.Basic` (`IsFiltration`, filtered rings) — unrelated.
- `lean_leanfinder "modal logic Kripke frame semantics accessibility relation"` returns
  `Mathlib.ModelTheory.*` (first-order model theory) and `Mathlib.Order.WellFounded` — unrelated.

Mathlib has no modal logic. All filtration content must be built in-repo. What Mathlib *does*
supply, and what is verified above as sufficient: `Quotient`/`Setoid`, `Set.instFinite`,
`Fintype.card_set`, `Fintype.card_coe`, `Nat.card_eq_fintype_card`,
`Nat.card_le_card_of_injective`, `Finite.of_injective`, `Finset.fintypeCoeSort`.

### F11. Repo health baseline

Exactly **one** live `sorry` outside `Boneyard/`: `FormalSystem/Metalogic/WeakCanonical/Transfer.lean:1242`
(body of `countermodel_discrete`). `Semantics/`, `Syntax/`, and the whole `Decidability/` tree are
sorry-free and axiom-clean. New FMP work lands on a clean base and must keep it that way
(zero-debt policy).

### F12. What this construction does **not** give — the honest boundary

The filtered structure has finitely many world states but:

- `D` is infinite (F4), so there are infinitely many evaluation points.
- `Ω' ⊆ WorldHistory (filtFrame D cl)` is in general infinite — each element is essentially a
  function `D → Set ↥cl`.
- `TaskRel'` is universal away from duration `0`, so the frame carries no temporal information;
  all semantic content lives in `Ω'`.

Therefore this yields the **finite frame property**, not a finite object one can enumerate, and
it does **not** by itself give a decision procedure. That is fine: decidability already comes
from the proof-theoretic route in `Decidability/`. But the plan must not claim otherwise, and the
prose in `latex/subfiles/04-Metalogic.tex` / `typst/chapters/p2-decidability-practice.typ` should
be corrected rather than reinforced.

Getting from here to an *enumerable* finite representation requires finitising `Ω'`, which is
where the genuine Until/Since difficulty reappears (eventuality fulfilment). The standard
techniques are the mosaic method (Marx–Mikulás–Reynolds; Gabbay–Hodkinson–Reynolds 1994) and
quasimodel decomposition (Reynolds 2003). The repo already has the corresponding machinery in
`BXCanonical/Quasimodel/` and `BXCanonical/Chronicle/`, and `DefectChain.lean:73,79`
(`sigmaDefectCount`, `sigma_defect_count_bounded`) is the eventuality-defect counter such an
argument consumes. This should be a **separate task**, not part of task 165.

## H3 Reference Grounding — Lemma Mapping Table

Tier 3 (implementation-backed): the primary sources are the live Lean tree and the
already-compiled prototype. Literature rows are marked and are advisory only.

| Source concept | Source location | Lean declaration target | Existing Lean asset | Status |
|---|---|---|---|---|
| Point type / characteristic set | Blackburn–de Rijke–Venema §2.3 (cited at `FMP/Filtration.lean:43-44`) | `ptType : ... → WorldHistory F → D → Set ↥cl` | `characteristicSet` (`FiniteModel.lean:55`) — syntactic analogue only | **New**; prototype compiles |
| Largest filtration (universal relation) | `FMP/Filtration.lean:172-181` (design note) | `univFrame (D) (W : Type) : TaskFrame D` | `refinedFilteredTaskRel` (`Filtration.lean:190`), `RefinedFilteredTaskFrame` (`Filtration.lean:197`) — proof reusable verbatim | **Generalise**; prototype compiles |
| Filtered valuation | charter step (3) | `filtModel : TaskModel (filtFrame D cl)` | none — no `TaskModel` exists over any filtered frame | **New**; prototype compiles |
| Filtered history | charter step (3) | `filtHist : WorldHistory F → WorldHistory (filtFrame D cl)` | pattern from `parametricToHistory` (`Algebraic/ParametricHistory.lean:68`) | **New**; prototype compiles |
| Filtered admissible set | `Truth.lean:333` `ShiftClosed` | `filtOm := filtHist '' Om` | pattern from `ShiftClosedParametricCanonicalOmega` (`ParametricHistory.lean:124`) | **New**; prototype compiles |
| Subformula-closure conditions | charter step (2) | `SubClosed`, `subformulaClosure_subClosed` | `closure_imp_left/right` (`Closure.lean:241,251`), `closure_box` (`:261`), `closure_untl_left/right` (`:291,301`), `closure_snce_left/right` (`:311,321`) | **Verified sufficient**; compiles (F7) |
| Filtration lemma, all 6 constructors | charter step (2) | `filtration_lemma` | `filtration_lemma_bot` (`TruthPreservation.lean:108`), `filtration_imp_forward` (`:171`), `filtration_box_forward` (`:238`) — all *syntactic*, `untl`/`snce` never attempted | **Verified provable**; compiles (F6) |
| Quotient frame is a valid task frame | charter step (3) | `filtFrame` frame axioms | `RefinedFilteredTaskFrame` frame-axiom proofs (`Filtration.lean:200-249`) | **Reusable**; compiles (F6) |
| Finiteness of world type | charter step (4) | `Finite (FiltW cl)` | `set_finite` (`FiniteModel.lean:129`), `FilteredWorld.finite` (`:137`), `subformulaClosureFintype` (`:121`) | **Reusable directly** |
| Size bound `2^|cl(φ)|` | charter step (4); `latex/subfiles/04-Metalogic.tex:350-352` | `filtW_card` | `fmp_size_bound` (`FMP.lean:237`) — **vacuous**; `filtered_world_bound` (`FMP.lean:183`) — **vacuous** | **Verified provable as equality** (F8) |
| Shift-closure of `Ω'` | `Validity.lean:82` binder | `filtOm_shiftClosed` | `time_shift_preserves_truth` (`Truth.lean:446`), `Set.univ_shift_closed` (`Truth.lean:339`), `shiftClosedParametricCanonicalOmega_is_shift_closed` (`ParametricHistory.lean:152`) | **Verified provable** (F9) |
| Semantic-FMP statement | charter headline | `semantic_fmp` | `FormulaSatisfiable` (`Validity.lean:154`), `FiniteTaskFrame` (`TaskFrame.lean:293`), `FiniteTaskModel` (`TaskModel.lean:97`) | **Target types exist**; statement new |
| Class transfer (Dense/Discrete/Dedekind) | `Validity.lean:169,187,231,255` | `semantic_fmp_dense/_discrete/_dedekind` | `valid_implies_valid_dense` (`Validity.lean:269`), `valid_implies_valid_discrete` (`:276`) | **Free by `D`-preservation** (F5) |
| Eventuality finitisation (out of scope) | *Literature*: Gabbay–Hodkinson–Reynolds 1994 (mosaics); Reynolds 2003 (quasimodels); Wolper 1983 (PLTL tableaux) | — | `BXCanonical/Quasimodel/`, `Chronicle/`, `sigmaDefectCount` (`DefectChain.lean:73`) | **Deferred to a separate task** (F12) |

*Literature caveat.* `specs/literature/README.md:146` records
`Hodkinson_Reynolds_2006_Temporal_Logic_Handbook_Ch11` — the single most relevant survey — as
**truncated (3 of 66 pages)**. Goldblatt 1992 is **not acquired**. No literature claim in this
report is load-bearing; every load-bearing claim is grounded in compiled Lean.

## H4 Adversarial Self-Verification

I re-read the draft with a mandate to refute each load-bearing claim, and ran additional Lean
checks specifically designed to break them. Three claims were revised; one subagent
recommendation was overturned.

### Claim Verification Table

| Claim | Source / attempted counterexample | Verification method | Confidence |
|---|---|---|---|
| `Decidability/FMP/` contains no semantic content | Attempted refutation: maybe truth preservation is stated elsewhere in `Decidability/`. Grep across the whole subtree found `TruthAt` only in `Propositional/Decidable.lean` (propositional fragment). | Exhaustive `grep -rn 'TruthAt\|TaskModel\|WorldHistory'` over `Decidability/` | High |
| `fmp_size_bound` and `filtered_world_bound` are vacuous | Read the full bodies; both conclude with a `∧ True` conjunct and `trivial`/`intro _; trivial`. | Direct read, `FMP.lean:183-189, 237-242` | High |
| `D` is necessarily infinite when `Nontrivial` | Attempted refutation: perhaps some exotic ordered abelian group is finite. Mathlib closes `Infinite D` by `infer_instance`, so no such instance can exist. | `lean_run_code` — compiles, zero diagnostics | High |
| The frame classes constrain only `D` | Attempted refutation: maybe `ValidDiscrete` or `ValidDedekind` smuggles a constraint onto `F` or `Omega`. Read all five binder lists verbatim; every extra binder is on `D`. | Direct read, `Validity.lean:79, 169, 187, 231, 255` | High |
| The six-constructor filtration lemma is provable, `untl`/`snce` included | Attempted refutation: build the construction and try to make the `untl` case fail. It does not fail — the IH generalised over `(τ, t)` closes it in three lines. | `lean_run_code` — full construction + lemma compile; zero errors | High |
| Only subformula closure is needed (no negation/FL closure) | Attempted refutation: try to find a constructor case needing `¬χ ∈ cl`. None: worlds are `Prop`-valued `Set`s, so `¬` is handled by `imp`+`bot`, both already closed. | Compiled `filtration_lemma`; `SubClosed` has exactly four fields and no negation field | High |
| Existing repo lemmas discharge `SubClosed (subformulaClosure φ)` | Constructed the instance from named lemmas only. | `lean_run_code` — compiles (F7) | High |
| `Nat.card (Set ↥cl) = 2 ^ cl.card` | Attempted refutation: maybe only `≤` is available. Equality holds. | `lean_run_code` — compiles (F8) | High |
| `Ω'` is shift-closed when `Ω` is | Attempted refutation: the `box` case of the shift lemma needs `ShiftClosed Om` — confirmed it is a hypothesis and is available from `valid`'s binder. | `lean_run_code` — transport lemma compiles (F9) | High |
| Mathlib has no modal filtration | Two independent searches (`lean_leansearch`, `lean_leanfinder`); both returned only unrelated algebra / first-order model theory. | Named search-tool results | High |
| Exactly one live `sorry` outside `Boneyard/` | Two independent counts (mine and a subagent's) agree on `Transfer.lean:1242`; all other grep hits are prose containing "sorry-free". | `grep` + manual inspection of each hit | High |
| The construction yields the finite *frame* property, not an enumerable finite model | Attempted refutation: is `Ω'` perhaps finite? Each element is essentially `D → Set ↥cl` with `D` infinite, so no. | Structural argument from F4 + the definition of `filtOm` | Medium-High (not machine-checked; argued, not formalised) |
| Until/Since finitisation needs mosaics/quasimodels | Literature-based, and the relevant survey is truncated in this repo (`specs/literature/README.md:146`). | Prose sources only; corroborated by `Boneyard/RoundRobinChain/ProofSketch_Sections1to30.lean:2065-2074` | **Low-Medium** — flagged as advisory, not load-bearing |

### Contradiction Log

**C1 — RESOLVED.** A codebase-mapping subagent recommended: *"Replace `refinedFilteredTaskRel`
(currently `if d = 0 then w = u else True` — too coarse for `untl`/`snce`) with a relation derived
from `Bundle.ExistsTask`/`Bundle.Succ`."* The `FMP/Filtration.lean:178-181` design note agrees in
spirit (*"A more refined 'smallest filtration' could be used"*).

This is **wrong for the semantic filtration**, and my compiled prototype refutes it. `TruthAt`
never mentions `TaskRel` (F3); the frame relation enters only through the `respects_task` field of
`WorldHistory`, i.e. purely as a well-formedness side condition. The universal relation makes
`respects_task` trivial and costs the truth lemma nothing. Building a refined relation from
`ExistsTask` would add substantial proof obligations (`forward_comp` for a composed relation
requires an amalgamation argument that is genuinely hard — see the risk note below) for **zero**
gain in the truth lemma.

Resolution precedence: machine-checked compilation over agent inference and over a stale in-code
design note. **Recommendation modified accordingly** — keep the universal relation; generalise it
rather than replace it.

**C2 — RESOLVED.** `specs/archive/064_critical_path_review/reports/09_teammate-b-findings.md:123`
records a fatal-looking objection: *"filtration requires a FINITE set of subformulas, and an
arbitrary MCS can contain `{F^n(p)}` for all `n`, requiring infinitely many distinct time points."*

This objection is sound but **targets a different construction**. It concerns *building* a model
from a maximal consistent set (the completeness/decidability direction), where time points must be
manufactured. The semantic FMP *starts from a given model* and never manufactures time points —
`D` is carried across unchanged and is infinite by design (F4). The objection therefore applies to
the Layer-2 finitisation (F12), not to Layer 1. Recorded so the plan does not mistakenly treat
Layer 1 as blocked.

**C3 — RESOLVED (charter correction).** The task charter asserts Until/Since filtration is "known
to be problematic". True for time-point-quotienting filtrations; false here (F3, F6). The plan
should record this correction explicitly so a future reader does not re-derive the charter's
assumption. This is not a criticism of the charter — the assumption is the correct default for
temporal logic; this semantics is simply unusual in separating histories from times.

### Recommendations Modified After Verification

1. **Dropped**: "define a refined/smallest filtration task relation" (C1).
2. **Dropped**: "extend the closure with Fischer–Ladner unwinding / `extendedDeferralClosure`"
   — a subagent's shortest-path recommendation. Verified unnecessary for the semantic route (F7);
   it is needed only for MCS-based constructions.
3. **Added**: explicit `Infinite D` finding (F4) and the consequent restatement of the FMP as a
   finite-*frame* property, with the `Ω'`-infinite caveat stated in the theorem's docstring.
4. **Added**: the class-transfer corollaries as near-zero-cost deliverables (F5).
5. **Rescoped**: eventuality finitisation moved out of task 165 (F12).

No revision of search direction was required; no `## Revised Direction` section is needed.

## Recommendations

### Proposed module layout

A new subtree, kept deliberately separate from the syntactic `FMP/` so the two are never confused:

```
FormalSystem/Metalogic/Decidability/SemanticFMP/
├── UnivFrame.lean          -- `univFrame`; generalised from RefinedFilteredTaskFrame
├── Closure.lean            -- `SubClosed`; `subformulaClosure_subClosed`
├── PointType.lean          -- `ptType`, `filtModel`, `filtHist`, `filtOm`
├── FiltrationLemma.lean    -- `filtration_lemma` (the six-case induction)
├── SizeBound.lean          -- `filtW_card`, `finite_filtW`, `FiniteTaskFrame` packaging
├── SemanticFMP.lean        -- `semantic_fmp` + per-class corollaries
└── README.md
```

Rationale for a new subtree rather than editing `FMP/`: `FMP/` is load-bearing for the tableau
decision procedure and is imported by `Decidability.lean`; the semantic route has different world
types and different obligations. Cross-link the two READMEs. Separately, `univFrame` should be
back-substituted into `FMP/Filtration.lean:197` so there is one combinator, not two copies.

### Phase sizing (each phase is one agent run, all prototype-backed)

| Phase | Deliverable | Evidence it will close |
|---|---|---|
| 1 | `UnivFrame.lean` + `Closure.lean`; retrofit `RefinedFilteredTaskFrame := univFrame D (FilteredWorld phi)` | Both compile in the prototype (F6, F7) |
| 2 | `PointType.lean` — `ptType`, `filtModel`, `filtHist`, `filtOm` | Compiles (F6) |
| 3 | `FiltrationLemma.lean` — the six-case induction | Compiles (F6); template is `time_shift_preserves_truth` (`Truth.lean:446`) |
| 4 | `SizeBound.lean` — `Nat.card = 2 ^ cl.card`, `Finite`, `FiniteTaskFrame` packaging; **replace** the two vacuous theorems in `FMP.lean:183,237` | Bound compiles (F8); finiteness assets exist (`FiniteModel.lean:121-143`) |
| 5 | `filtOm_shiftClosed` | Transport lemma compiles (F9) |
| 6 | `SemanticFMP.lean` — headline theorem + four class corollaries | Corollaries are free by `D`-preservation (F5) |
| 7 | Documentation truth-up: `FMP/README.md`, `BXCanonical/Filtration/README.md`, `latex/subfiles/04-Metalogic.tex:350-352,529`, `typst/chapters/p2-decidability-practice.typ:42,44`, `specs/ROADMAP.md:798-800` | Defect list below |

### Headline theorem — Lean-ready statement

```lean
/-- **Semantic finite model property for TM.**

    If `φ` is satisfiable in some task model over a shift-closed admissible set, then `φ` is
    satisfiable in a task model whose *world-state type* is finite, with exactly
    `2 ^ |subformulaClosure φ|` states, over the SAME temporal type `D`.

    Caveat, deliberately stated: `D` is necessarily infinite (a nontrivial linearly ordered
    abelian group is infinite), and the admissible set `Omega'` is in general infinite. This is
    the finite *frame* property; it is not an enumerable finite object and does not by itself
    yield a decision procedure. -/
theorem semantic_fmp
    (D : Type) [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D] [Nontrivial D]
    {F : TaskFrame D} (M : TaskModel F) (Om : Set (WorldHistory F)) (h_sc : ShiftClosed Om)
    (τ : WorldHistory F) (hτ : τ ∈ Om) (t : D) (φ : Formula)
    (h : TruthAt M Om τ t φ) :
    ∃ (F' : FiniteTaskFrame D) (M' : FiniteTaskModel F')
      (Om' : Set (WorldHistory F'.toTaskFrame)) (_ : ShiftClosed Om')
      (τ' : WorldHistory F'.toTaskFrame) (_ : τ' ∈ Om') (t' : D),
      TruthAt M' Om' τ' t' φ ∧
      Nat.card F'.WorldState = 2 ^ (subformulaClosure φ).card
```

Class corollaries (each expected to be a one-liner, since `D` and its instances are untouched):

```lean
theorem semantic_fmp_dense    [DenselyOrdered D] ... -- same conclusion
theorem semantic_fmp_discrete [SuccOrder D] [PredOrder D] [IsSuccArchimedean D]
                              [IsPredArchimedean D] ...
theorem semantic_fmp_dedekind (hlub : ∀ s : Set D, s.Nonempty → BddAbove s → ∃ x, IsLUB s x) ...
```

### Risks and open design decisions

| Risk | Assessment |
|---|---|
| `WorldHistory` equality for `filtOm_shiftClosed` needs `ext` across proof-carrying fields | Low. `WorldHistory` fields are `domain`/`convex`/`states`/`respects_task`; with a total domain, `funext` + `proof_irrel` should suffice. `states_eq_of_time_eq` (`WorldHistory.lean:302`) is available if not. **Not yet machine-checked** — the one prototype gap. |
| Universe levels: `TaskFrame.WorldState : Type` but `FiltW cl = Set ↥cl : Type` | None. Verified: the prototype compiles with `TaskFrame D` at `Type`. |
| The `≤` vs `=` form of the bound | Prefer `=` (verified, F8) for the full-powerset world type. If a future refinement uses the image subtype, switch to `≤` via `Nat.card_le_card_of_injective` (also verified). |
| Overclaiming in the theorem name | Real. Mitigate by naming it `semantic_fmp` with the caveat in the docstring, and by **not** deleting the caveat during doc cleanup. Consider `semantic_finite_frame_property` as an alias. |
| Regression risk from retrofitting `RefinedFilteredTaskFrame` | Low but real — `FMP/` is imported by `Decidability.lean` and consumed by the tableau. Phase 1 must end with a full `lake build`. |
| Temptation to chase `forward_comp` for a refined relation | Explicitly out of scope (C1). If a future task wants a refined relation, note that `forward_comp` for the image relation **genuinely fails** — two witnesses may be different histories, so it needs an amalgamation argument. That is real mathematics and should be its own task. |
| Literature grounding for Layer 2 | The key survey is truncated in-repo (`specs/literature/README.md:146`) and Goldblatt 1992 is unacquired. Acquire before opening a mosaic/quasimodel task. |

### Documentation defects found (read-only; recommend a cleanup phase)

| Location | Defect |
|---|---|
| `FormalSystem/Metalogic/BXCanonical/Filtration/README.md:3-7,17,22-23` | Describes a quotient-by-closure construction and a `defect_chain` declaration; the directory contains neither. Imports/importers listed are wrong. |
| `FormalSystem/Metalogic/Decidability/FMP/README.md:21-22` | Advertises `filtration_is_finite` and `truth_preserved_under_filtration`; neither exists. |
| `FormalSystem/Metalogic/Decidability/FMP/README.md:31-33` | Names `fmp_dense`/`fmp_discrete`; actual archived names are `dense_mcs_finite_model_property`/`discrete_mcs_finite_model_property`. |
| `FormalSystem/Metalogic/BXCanonical/Quasimodel/README.md` | Lists `EnrichedClosure.lean` (158 lines) as present; the file is archived to `Boneyard/BXCanonicalQuasimodel/`. |
| `latex/subfiles/04-Metalogic.tex:350-352` | States the `2^{|cl(φ)|}` bound as established; it is vacuous (F2). Will become true after Phase 4. |
| `latex/subfiles/04-Metalogic.tex:529` | References `finite_model_property` — no such declaration. |
| `typst/chapters/p2-decidability-practice.typ:44` | Points at `FMP/DenseFMP.lean`, `FMP/DiscreteFMP.lean` — now in `Boneyard/`. |
| `typst/chapters/04-metalogic.typ:108` | Calls `BXCanonical/Filtration/` a filtration; it is an Until-defect counter. |
| `specs/ROADMAP.md:798-800, 686-690` | Lists `Filtration/SigmaOrdering.lean` as live (Boneyard'd) and a `DefectChain → SigmaOrdering` edge that no longer exists. |
| `FormalSystem/Metalogic.lean:85` | Tree comment `└── Filtration/ 1 file # Sigma ordering` — the remaining file is not the sigma ordering. |

## References

**Semantics (target types).**
`FormalSystem/Semantics/TaskFrame.lean:99` (`TaskFrame`), `:293` (`FiniteTaskFrame`), `:306` (`Coe`);
`FormalSystem/Semantics/TaskModel.lean:49` (`TaskModel`), `:97` (`FiniteTaskModel`);
`FormalSystem/Semantics/WorldHistory.lean:75` (`WorldHistory`), `:246` (`timeShift`), `:302` (`states_eq_of_time_eq`);
`FormalSystem/Semantics/Truth.lean:128-137` (`TruthAt`), `:333` (`ShiftClosed`), `:339` (`Set.univ_shift_closed`), `:446` (`time_shift_preserves_truth`);
`FormalSystem/Semantics/Validity.lean:79` (`valid`), `:129` (`satisfiable`), `:154` (`FormulaSatisfiable`), `:169` (`ValidDense`), `:187` (`ValidDiscrete`), `:231` (`ValidDedekind`), `:255` (`ValidDedekindDense`), `:269,276` (class-transfer lemmas).

**Syntax and closure.**
`FormalSystem/Syntax/Formula.lean:76-91` (6 constructors), `:118-161` (derived operators);
`FormalSystem/Syntax/Subformulas.lean:44` (`subformulas`);
`FormalSystem/Syntax/SubformulaClosure/Closure.lean:36` (`subformulaClosure`), `:50` (decidability instance), `:71` (`closureWithNeg`), `:241,251,261,291,301,311,321` (the seven closure lemmas used in F7).

**Existing (syntactic) FMP.**
`FormalSystem/Metalogic/Decidability/FMP/Filtration.lean:66` (`MCSFiltrationEquiv`), `:120` (`ClosureMCSBundle`), `:158` (`FilteredWorld`), `:190` (`refinedFilteredTaskRel`), `:197-249` (`RefinedFilteredTaskFrame` + frame-axiom proofs);
`FormalSystem/Metalogic/Decidability/FMP/FiniteModel.lean:55,88,96,121,129,137,159`;
`FormalSystem/Metalogic/Decidability/FMP/TruthPreservation.lean:63,108,171,238` (syntactic filtration cases; no `untl`/`snce`);
`FormalSystem/Metalogic/Decidability/FMP/FMP.lean:183,237` (**the two vacuous theorems**), `:204,217`.

**Canonical-model patterns worth imitating.**
`FormalSystem/Metalogic/Algebraic/ParametricHistory.lean:68` (`parametricToHistory`), `:124,152` (shift-closed Omega);
`FormalSystem/Metalogic/Algebraic/ParametricTruthLemma.lean:108,240`;
`FormalSystem/Metalogic/Algebraic/RestrictedParametricTruthLemma.lean:119` (closure-restricted truth lemma — the closest existing analogue in *shape*).

**Frame classes.** `FormalSystem/ProofSystem/Axioms.lean:449-482`; `FormalSystem/ProofSystem/Derivable.lean:69`.

**Repo health.** `FormalSystem/Metalogic/WeakCanonical/Transfer.lean:1225,1242` (the single live `sorry`).

**Prose sources on the Until/Since finitisation problem (advisory only).**
`Boneyard/RoundRobinChain/ProofSketch_Sections1to30.lean:2065-2074` (Burgess 1984; Gabbay–Hodkinson–Reynolds 1994 mosaics; Reynolds 2003 quasimodels);
`specs/archive/064_critical_path_review/reports/09_teammate-b-findings.md:110-135` (the `{F^n(p)}` objection, see C2);
`Boneyard/BXCanonicalQuasimodel/EnrichedClosure.lean:12-19,60-65` (Fischer–Ladner closure; `¬¬g` escape hazard);
`specs/literature/README.md:146,169` (both key surveys unavailable/truncated).

**Mathlib assets verified as sufficient.**
`Fintype.card_set`, `Fintype.card_coe`, `Nat.card_eq_fintype_card`, `Nat.card_le_card_of_injective`,
`Finset.fintypeCoeSort`, `Set.instFinite`, `Finite.of_injective`.
Verified absent: any modal-logic filtration (F10).
