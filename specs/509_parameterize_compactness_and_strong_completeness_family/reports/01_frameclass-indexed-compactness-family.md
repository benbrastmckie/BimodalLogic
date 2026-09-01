# Research: FrameClass-indexed compactness / strong-completeness family

**Task**: 509 — parameterize the compactness and strong-completeness layer by `FrameClass`
**Type**: lean4 (restructuring; discharges nothing)
**Date**: 2026-09-01
**Tree state**: `HEAD = 732f2c2f3` ("task 508: complete implementation"). `FormalSystem/` clean;
the only uncommitted paths are task-management artifacts (`specs/`, `typst/generated/status.typ`,
`.claude-extensions.json`) plus two untracked files (`.syncprotect`, a `__pycache__` blob). No
foreign commits or `FormalSystem/` modifications appeared during this run.

**Headline**: the restructuring is verified end-to-end by a compiled probe. All four indexed
definitions, both collapsed theorems, and every Base/Dense/Discrete instantiation compile with
axiom profile exactly `[propext, Classical.choice, Quot.sound]` — identical to the C14 baseline.
The Dedekind row falls out for free and is also compiled. Exactly **two** friction points exist,
both with verified one-line repairs.

---

## 1. Anchor verification (the brief's inventory is stale — corrected here)

The brief's line citations predate task 508's collapse. Re-derived by grep against the live tree:

| Brief's claim | Actual state |
|---|---|
| `SetConsequence.lean` defines the consequence family "once per class by hand" at `:214,:222,:230,:245` etc. | **Superseded.** Task 508 already collapsed the *consequence* relations onto `SetConsequenceOnFrames P` (`SetConsequence.lean:91`) and `SetSemanticConsequenceOn fc` (`:98`). The four per-class names are already one-line abbreviations at `:103`, `:107`, `:112`, `:117`. |
| "Dedekind ENTIRELY ABSENT" | **False for consequence.** `SetSemanticConsequenceDedekindDense` exists (`SetConsequence.lean:117`), with `.of_forall`/`.apply` adapters at `:179`/`:188`. Dedekind *is* absent from the compactness/satisfiability/model-existence/strong-completeness rows. |
| Negative results at `DiscreteNonCompactness.lean:250`, `:280` | **Confirmed exact.** `discrete_consequence_not_compact:250`, `strongCompletenessDiscrete_refuted:280`. |
| Task 493 added `Metalogic/Compactness.lean` (~166 lines) | **Confirmed.** 166 lines; `modelExistenceBase:81`, `modelExistenceDense:107`, `compactBase:127`, `compactDense:131`, `strongCompletenessBase:141`, `strongCompletenessDense:148`. The `engine` parameters are retained on both reductions. |
| Indexed validity is at frame level, `FrameClass.Sat` | **Confirmed.** `FrameClass.Sat` at `Semantics/FrameClassValidity.lean:112`; `ValidOnFrames` at `Semantics/Validity.lean:326`, `ValidIn` at `:337`. |

### The genuinely load-bearing discovery (task 507's legacy)

`Semantics/Validity.lean` already defines every class-restricted validity predicate **as a plain
`def` over `ValidIn`**, not as a separately-written binder list:

- `valid φ := ValidIn .Base φ` (`:377`)
- `ValidDense φ := ValidIn .Dense φ` (`:521`)
- `ValidDiscrete φ := ValidIn .Discrete φ` (`:595`)
- `ValidDedekindDense φ := ValidIn .Dedekind φ` (`:752`)

Because these are definitional, `Compact fc` stated with `ValidIn fc (...)` is **definitionally
equal** to today's `CompactBase`/`CompactDense`/`CompactDiscrete` on the nose. That is what
collapses this task from a rewrite into a re-indexing.

(`ValidDedekind := ValidOnFrames TaskFrame.IsComplete` at `:698` is deliberately *not* a `ValidIn`
— the bare Complete clause, which `ℤ` satisfies. It is not part of this family and must stay out.)

---

## 2. Current shape: what is hand-copied and what is not

| Row | `.Base` | `.Dense` | `.Discrete` | `.Dedekind` |
|---|---|---|---|---|
| Set consequence | `:103` (already collapsed) | `:107` | `:112` | `:117` |
| `StrongCompleteness*` | `:310` | `:361` | `:415` | **absent** |
| `Compact*` | `:319` | `:368` | `:441` | **absent** |
| `Satisfiable*Set` | `:327` | `:376` | `:429` | **absent** |
| `ModelExistence*` | `:342` | `:390` | *correctly absent (refuted)* | **absent** |

Theorems currently duplicated across Base and Dense:

- `strongCompletenessBase_of_compact` (`StrongCompleteness.lean:347`) and
  `strongCompletenessDense_of_compact` (`:375`) — **byte-identical four-line proofs**.
- `compactBase_of_modelExistence` (`:414`) and `compactDense_of_modelExistenceDense` (`:462`) —
  identical apart from `valid.of_not` vs `ValidDense.of_not` and one witness-tuple component.

---

## 3. Recommended design (all four verified compiling)

Placed in `Metalogic/SetConsequence.lean`, beside `SetSemanticConsequenceOn`:

```lean
def SatisfiableSet (fc : FrameClass) (Γ : Set Formula) : Prop :=
  ∃ (F : TaskFrame) (_ : fc.Sat F) (M : TaskModel F)
    (τ : WorldHistory F) (_ : τ.IsTotal) (t : F.Duration),
    ∀ ψ ∈ Γ, TruthAt M τ t ψ

def ModelExistence (fc : FrameClass) : Prop :=
  ∀ Γ : Set Formula,
    (∀ L : List Formula, (∀ ψ ∈ L, ψ ∈ Γ) → SatisfiableSet fc {ψ | ψ ∈ L}) →
    SatisfiableSet fc Γ

def Compact (fc : FrameClass) : Prop :=
  ∀ (Γ : Set Formula) (φ : Formula), SetSemanticConsequenceOn fc Γ φ →
    ∃ L : List Formula, (∀ ψ ∈ L, ψ ∈ Γ) ∧ ValidIn fc (L.foldr Formula.imp φ)

def StrongCompleteness (fc : FrameClass) : Prop :=
  ∀ (Γ : Set Formula) (φ : Formula),
    SetSemanticConsequenceOn fc Γ φ → SetDerivable fc Γ φ
```

`SatisfiableSet` uses `fc.Sat F` rather than an inlined binder list, exactly as
`SetConsequenceOnFrames` and `ValidOnFrames` do. That is the whole point of the collapse, and it
is what makes the Dedekind row free.

### Definitional-equality audit (each line below is a compiled `rfl` in `probe_509.lean`)

| Claim | Result |
|---|---|
| `Compact .Base = CompactBase` | **defeq** |
| `Compact .Dense = CompactDense` | **defeq** |
| `Compact .Discrete = CompactDiscrete` | **defeq** |
| `StrongCompleteness .Base = StrongCompletenessBase` | **defeq** |
| `StrongCompleteness .Dense = StrongCompletenessDense` | **defeq** |
| `StrongCompleteness .Discrete = StrongCompletenessDiscrete` | **defeq** |
| `SatisfiableSet .Dense = SatisfiableDenseSet` | **defeq** (`IsDense F` *is* `DenselyOrdered F.Duration`, `FrameProperty.lean:71`) |
| `ModelExistence .Dense = ModelExistenceDense` | **defeq** |
| `SatisfiableSet .Base` vs `SatisfiableBaseSet` | **equivalent, not defeq** — one extra `∃ _ : True` binder |
| `SatisfiableSet .Discrete` vs `SatisfiableDiscreteSet` | **equivalent, not defeq** — `IsSuccArchDiscrete` bundles the four witnesses as `∃ _ _, _ ∧ _` (`FrameProperty.lean:118`), today's version has four flat `∃` |

So **eight of the ten** per-class statements are recovered with literally zero statement change.
The two that shift are `SatisfiableBaseSet` and `SatisfiableDiscreteSet`, and they shift in
exactly the way task 507 already shifted `valid` — an added frame-condition slot, absorbed by
binder-shape adapters. That precedent is the tree's own, established convention.

---

## 4. The two collapsed theorems (both compiled)

Replacing `strongCompletenessBase_of_compact` + `strongCompletenessDense_of_compact`:

```lean
theorem strongCompleteness_of_compact {fc : FrameClass} (hc : Compact fc)
    (engine : ∀ ψ : Formula, ValidIn fc ψ → Derivable fc [] ψ) :
    StrongCompleteness fc := by
  intro Γ φ h
  obtain ⟨L, hL, hvalid⟩ := hc Γ φ h
  exact ⟨L, hL, (derivable_foldr_imp_iff L φ).mpr (engine _ hvalid)⟩
```

`derivable_foldr_imp_iff` (`StrongCompleteness.lean:297`) is already generic in `fc`, so this is
the existing proof with the class tag lifted to a variable. The `engine` parameter stays live, as
the brief requires.

Replacing `compactBase_of_modelExistence` + `compactDense_of_modelExistenceDense`:

```lean
theorem compact_of_modelExistence {fc : FrameClass} (h : ModelExistence fc) : Compact fc := by
  classical
  intro Γ φ hcons
  by_contra hno
  push Not at hno
  have hfin : ∀ L : List Formula, (∀ ψ ∈ L, ψ ∈ insert φ.neg Γ) →
      SatisfiableSet fc {ψ | ψ ∈ L} := by
    intro L hL
    have hsub : ∀ ψ ∈ L.filter (fun ψ => decide (ψ ∈ Γ)), ψ ∈ Γ := by
      intro ψ hψ
      exact of_decide_eq_true (List.mem_filter.mp hψ).2
    have hnv := ValidIn.of_not (hno _ hsub)
    push Not at hnv
    obtain ⟨F, hF, M, τ, hτ, t, hfalse⟩ := hnv
    rw [truthAt_foldr_imp] at hfalse
    push Not at hfalse
    obtain ⟨hall, hnφ⟩ := hfalse
    refine ⟨F, hF, M, τ, hτ, t, ?_⟩
    intro ψ hψ
    by_cases hg : ψ ∈ Γ
    · exact hall ψ (List.mem_filter.mpr ⟨hψ, decide_eq_true hg⟩)
    · rcases hL ψ hψ with rfl | hmem
      · exact fun hp => hnφ hp
      · exact absurd hmem hg
  obtain ⟨F, hF, M, τ, hτ, t, hsat⟩ := h _ hfin
  exact hsat φ.neg (Set.mem_insert _ _)
    (hcons F hF M τ hτ t (fun ψ hψ => hsat ψ (Set.mem_insert_of_mem _ hψ)))
```

Note `hcons F hF M τ hτ t` applies **directly** — no `.apply` adapter — because
`SetSemanticConsequenceOn fc` already exposes `fc.Sat F` as an explicit argument (task 508's
doing). The Base and Dense versions each needed a class-specific `.apply`.

### One prerequisite lemma is missing and must be added

`Semantics/Validity.lean` has `valid.of_not:405`, `ValidDense.of_not:548`,
`ValidDiscrete.of_not:623`, `ValidDedekindDense.of_not:774` — but **no generic
`ValidIn.of_not`**, even though `ValidIn.of_forall_total:494` and `ValidIn.apply_total:501`
already exist. Add, beside them:

```lean
theorem ValidIn.of_not {fc : ProofSystem.FrameClass} {φ : Formula} (h : ¬ ValidIn fc φ) :
    ¬ ∀ (F : TaskFrame), fc.Sat F → ∀ (M : TaskModel F) (τ : WorldHistory F),
        τ.IsTotal → ∀ t : F.Duration, TruthAt M τ t φ :=
  fun h' => h (ValidIn.of_forall_total h')
```

This is the only edit required outside `Metalogic/`.

---

## 5. Complete call-site inventory (every site, greped)

### Zero-change sites (defeq carries them)

- `Compactness.lean:127,131,141,148` — `compactBase`, `compactDense`, `strongCompletenessBase`,
  `strongCompletenessDense`. Compiled unchanged in the probe against the new reductions.
- `DiscreteNonCompactness.lean:250` (`discrete_consequence_not_compact`) and `:280`
  (`strongCompletenessDiscrete_refuted`) — their `CompactDiscrete` / `StrongCompletenessDiscrete`
  targets are defeq. Their **internal** `SatisfiableDiscreteSet` tuples do change; see below.
- All `SetSemanticConsequence*` sites — untouched by this task.

### Friction point 1 — `SatisfiableDiscreteSet`, three tuple shapes

`IsSuccArchDiscrete` is a plain `def` wrapping `∃ (_ : SuccOrder D) (_ : PredOrder D), _ ∧ _`.
The anonymous constructor does **not** unfold it, so today's flat 10-component tuples stop
elaborating (recorded verbatim, with Lean's errors, in `probe_509b_negative_control.lean`).

Verified repair — insert exactly one nesting pair at each of three sites:

| Site | Today | Repair |
|---|---|---|
| `DiscreteNonCompactness.lean:197` (in `archWitness_finitely_satisfiable`, `:194`) | `refine ⟨F, inferInstance, inferInstance, inferInstance, inferInstance, M, …⟩` | `refine ⟨F, ⟨inferInstance, inferInstance, inferInstance, inferInstance⟩, M, …⟩` |
| `:230` (in `archWitness_not_satisfiable`, `:229`) | `rintro ⟨F, _, _, _, _, M, τ, hτ, t, h⟩` | `rintro ⟨F, ⟨_, _, _, _⟩, M, τ, hτ, t, h⟩` |
| `:258` and `:288` (the two `absurd ⟨…⟩` tuples) | `⟨F, inferInstance, ×4, M, …⟩` | `⟨F, ⟨inferInstance, ×4⟩, M, …⟩` |

Recommended instead of touching them at all: add a `SatisfiableSet.discrete_of_forall` adapter
(compiled in `probe_509c.lean` §C0/C1') mirroring the existing
`SetSemanticConsequenceDiscrete.of_forall` at `SetConsequence.lean:159`, so the call sites keep
reading in the pre-collapse binder shape. Either route is verified; the adapter route is more
consistent with what tasks 507 and 508 established.

### Friction point 2 — `modelExistenceDense`'s bare `inferInstance`

`Compactness.lean:113` passes `inferInstance` for the density slot. Against `Sat .Dense F` that
fails: `Sat .Dense F` unfolds to `TaskFrame.IsDense F`, whose head symbol is not `DenselyOrdered`,
so instance search cannot see it. This is the *same* invisibility already documented on
`SetSemanticConsequenceDense.of_forall` (`SetConsequence.lean:143`).

Verified repair — ascribe the type (`probe_509c.lean` §C3):

```lean
    (inferInstance : DenselyOrdered
      (uShiftSet (idxUF Γ) (fun i => ShiftSet.ofModel (F i) (M i))).frame.Duration),
```

`choose` on the hypothesis still works unchanged, and the `haveI : ∀ i, DenselyOrdered …` step is
still accepted, because `hd i : Sat .Dense (F i)` is defeq to `DenselyOrdered (F i).Duration`
(§C4).

### `modelExistenceBase` — one word

`Compactness.lean:85`'s `refine ⟨frame, model, hist, …⟩` gains `trivial` in second position for
the `Sat .Base` slot. The rest of the ultraproduct proof is verbatim
(`probe_509b_negative_control.lean` §B4, which **succeeds** with a clean axiom profile).

### Documentation with stale line citations that will shift again

Already stale today (they cite `SetConsequence.lean:306/:314/:335/:352/:359`; the live values are
`:310/:319/:342/:361/:368`), and this task moves them once more:

- `docs/user-guide/architecture.md:824-826`
- `docs/reference/API_REFERENCE.md:704-706`, `:736`, `:738`
- `docs/project-info/known-limitations.md:37`
- `FormalSystem/Metalogic.lean:109-118`, `:158-175` (prose naming the two reductions and two
  bridges, which become one and one)
- `FormalSystem/Semantics/Ultraproduct/Carrier.lean:15` (names `SatisfiableBaseSet`)
- `FormalSystem/Metalogic/README.md:142,147` (line counts)

---

## 6. Probe results

Three files under `specs/509_.../reports/`. `FormalSystem/` was not modified; all were run with
`lake env lean <file>` against the current build.

| File | Status | What it establishes |
|---|---|---|
| `probe_509.lean` | **compiles clean** | The four indexed definitions; ten defeq/equivalence checks; both collapsed theorems; Base/Dense/Discrete recovered as instantiations; the whole Dedekind row |
| `probe_509c.lean` | **compiles clean** | The verified repair for each of the two friction points, plus the three adapter theorems |
| `probe_509b_negative_control.lean` | **expected to fail** (annotated) | Records verbatim which four call-site shapes break and Lean's exact errors, so the implementer does not rediscover them |

Axiom profiles reported by the probe, all identical to the C14 baseline
`[propext, Classical.choice, Quot.sound]`:

```
Probe509.compactBase'                 [propext, Classical.choice, Quot.sound]
Probe509.compactDense'                [propext, Classical.choice, Quot.sound]
Probe509.strongCompletenessBase'      [propext, Classical.choice, Quot.sound]
Probe509.strongCompletenessDense'     [propext, Classical.choice, Quot.sound]
Probe509.compact_of_modelExistence    [propext, Classical.choice, Quot.sound]
Probe509.strongCompleteness_of_compact[propext, Classical.choice, Quot.sound]
Probe509C.modelExistenceDense'        [propext, Classical.choice, Quot.sound]
```

`sorryAx` is absent throughout the two green probes.

---

## 7. What the follow-on Dedekind task's Part 1 becomes

This is the shape to inherit. All six declarations below are **compiled** in `probe_509.lean`
Part E, today, with no new obligation:

```lean
abbrev SatisfiableDedekindDenseSet : Set Formula → Prop := SatisfiableSet FrameClass.Dedekind
abbrev ModelExistenceDedekindDense : Prop := ModelExistence FrameClass.Dedekind
abbrev CompactDedekindDense        : Prop := Compact FrameClass.Dedekind
abbrev StrongCompletenessDedekindDense : Prop := StrongCompleteness FrameClass.Dedekind

theorem compactDedekindDense_of_modelExistence (h : ModelExistenceDedekindDense) :
    CompactDedekindDense := compact_of_modelExistence h

theorem strongCompletenessDedekindDense_of_compact (hc : CompactDedekindDense) :
    StrongCompletenessDedekindDense :=
  strongCompleteness_of_compact hc (fun ψ hψ => completeness_dedekind ψ hψ)
```

Two consequences worth flagging to that task:

1. Its Part 1 is **four `abbrev`s and two one-line theorems**, not a fourth hand copy of a
   ten-declaration group. The engine argument is already available:
   `completeness_dedekind` (`StrongCompleteness.lean:624`) has exactly the required shape, since
   `ValidDedekindDense = ValidIn .Dedekind` definitionally.
2. Its Part 2 (the non-compactness witness) remains the only real work, and the report's
   Discrete finding sharpens why `archWitness` cannot be reused: the `.Dedekind` satisfiability
   slot is `IsDedekind F = IsDense F ∧ IsComplete F` (`FrameProperty.lean:172`) — an `And`, with
   no successor structure at all — so the `Order.succ^[n]` machinery `archWitness_not_satisfiable`
   turns on has nothing to act on. The Dedekind adapter's binder shape is
   `⟨F, ⟨inst, hlub⟩, M, τ, hτ, t, h⟩`, compiled in `probe_509c.lean` §B6.

---

## 8. Suggested phase decomposition

Each phase is one agent run and ends at a green `lake build`.

1. **`ValidIn.of_not`** — add the one missing generic lemma to `Semantics/Validity.lean` beside
   `ValidIn.of_forall_total:494`. ~10 lines.
2. **The indexed family** — add `SatisfiableSet`, `ModelExistence`, `Compact`,
   `StrongCompleteness` to `SetConsequence.lean`; redefine the ten per-class names as
   instantiations; add the three `SatisfiableSet.*_of_forall` binder adapters. ~120 lines
   including docstrings.
3. **The two collapsed theorems** — replace the four theorems in `StrongCompleteness.lean` with
   `strongCompleteness_of_compact` and `compact_of_modelExistence`; keep the old names as
   deprecated-free one-line corollaries *only if* an external consumer needs them (grep says none
   does outside `Compactness.lean`, so prefer outright replacement).
4. **Call-site repairs** — `Compactness.lean` (`trivial`, ascribed `inferInstance`, and the two
   reduction call sites) and `DiscreteNonCompactness.lean` (three tuple shapes, or the adapter
   route). ~15 lines touched.
5. **Documentation** — the citation list in §5 above, plus `Metalogic.lean`'s prose about "the
   two reductions" and "the two bridges" (now one each).
6. **Tree-wide acceptance** — `lake build`, `#print axioms` audit, `check-module-invariants.sh`,
   `readme-lint.sh` against the recorded pre-existing baseline.

---

## 9. Zero-debt and scope notes

- No step requires `sorry`; every non-trivial step is compiled above.
- No new axiom is introduced; all seven audited declarations report exactly
  `[propext, Classical.choice, Quot.sound]`.
- **Nothing is discharged.** `ModelExistenceBase`/`ModelExistenceDense` keep their current
  ultraproduct proofs; `CompactDiscrete`/`StrongCompletenessDiscrete` stay refuted;
  `CompactDedekind` stays unproved and *unstated* (that is the follow-on task's Part 1).
- The `engine` parameters on the strong-completeness reduction stay live, per the brief.

## 10. Pre-existing gate failures — recorded, not absorbed

Both confirmed present on the current tree **before** any change:

- `scripts/check-module-invariants.sh` **C6**: `4 unreachable live module(s) absent from
  scripts/module-invariants-manifest.txt` (plus 2 manifested as known-broken).
- `scripts/readme-lint.sh` **check 1**: `MISSING: FormalSystem/Semantics/Ultraproduct/README.md
  (4 .lean files)` → `RESULT: FAIL (1 missing READMEs, 0 broken references)`. Six informational
  missing-date warnings accompany it.

Neither is in this task's scope. Acceptance for this task should be measured against these as
the baseline, not against a clean run.
