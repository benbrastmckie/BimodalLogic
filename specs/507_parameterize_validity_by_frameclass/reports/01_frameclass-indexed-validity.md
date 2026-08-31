# Research: FrameClass-Indexed Semantic Validity (ROOT FIX for H1)

**Task type**: lean4
**Grounding**: `specs/reviews/review-2026-08-31-metalogic-systematicity.md` issue H1
**Status**: researched — the complete design is **prototyped and compiles sorry-free** against the
current tree (14 probes, `lake env lean`, zero errors).

---

## Executive summary

The root fix is available and is smaller than the issue description implies. A four-case
`FrameClass → Prop`-on-carrier interpretation, one `ValidIn` definition, and one antitonicity
lemma reproduce every existing predicate and every existing monotonicity lemma. All of it was
written out and **compiled green** during this research pass; the exact source is reproduced in
§4 and can be pasted into the implementation.

Four findings change the shape of the plan versus the task description:

1. **The marker-typeclass layer named as "the missing ingredient" is the wrong ingredient**, and
   consuming it verbatim would be a semantic change (§3.1). Its binder lists do not match the
   `Valid*` binder lists: `SerialFrame` adds `[NoMaxOrder] [NoMinOrder]`, and
   `DiscreteTemporalFrame` *omits* `[IsPredArchimedean]` which `ValidDiscrete` binds. The correct
   move is a fresh `FrameClass.Sat` stated directly against the Mathlib predicates that the
   `Valid*` binder lists already use. (Mitigating fact, verified: `NoMaxOrder D` and
   `NoMinOrder D` **are derivable by `infer_instance`** from the `valid` binder set, so that half
   of the mismatch is harmless — but `IsPredArchimedean` is not.)
2. **`FrameConditions/Validity.lean` is almost entirely dead code.** `ValidLinear`,
   `ValidDenseFc`, `ValidDiscreteFc`, `ValidOverInt` and all nine of its bridge theorems have
   **zero consumers** outside their own file. Only `ValidOver` is used (by
   `FrameConditions/Soundness.lean` and `FrameConditions/Compatibility.lean`). This is not a layer
   to extend; it is a layer to delete and replace. `DedekindTemporalFrame`'s own docstring already
   concedes the point: *"this class is a side-car, not the load-bearing layer."*
3. **The migration is 92 code sites across 15 files, not 272.** The raw grep count (272) is
   dominated by docstring prose. Comment-stripped counts are in §2.3.
4. **`ValidInt φ = ValidOverInt φ` is a definitional duplicate** — verified by `rfl`. Two names,
   one predicate, in two different files.

The hazard the task targets closes structurally: once `.Dedekind ↦ DenselyOrdered ∧ LUB`, the
`soundness_dedekind` binder list is *derived* and the refutable variant is unwritable.
`ValidDedekind` (the density-free TM⁺_c predicate) is then revealed as what it is — a predicate
with no frame class — and it has only **3 code occurrences** (its own `def` plus two lemmas), so
renaming it out of the `Dedekind` namespace is nearly free (§5.3).

---

## 1. The asymmetry, confirmed

Proof side (all present, all correct):

| Construct | Location |
|---|---|
| `inductive FrameClass` (Base/Dense/Discrete/Dedekind) | `ProofSystem/Axioms.lean:536` |
| `instance : LE FrameClass` / `PartialOrder FrameClass` | `ProofSystem/Axioms.lean:543,556` |
| order-shape regression `example`s | `ProofSystem/Axioms.lean:~577-586` |
| `Axiom.minFrameClass` (declared single source of truth) | `ProofSystem/Axioms.lean:~611` |
| `FrameClass.base_le` | `ProofSystem/Axioms.lean:~640` |
| `DerivationTree (fc : FrameClass)` / `.lift` | `ProofSystem/Derivation.lean:91,184` |
| `Derivable (fc : FrameClass)` | `ProofSystem/Derivable.lean:69` |
| `SetDerivable (fc : FrameClass)` + `setDerivable_mono` | `Metalogic/SetConsequence.lean:72,118` |

Semantic side: 15 validity predicates, 8 consequence variants, **and three more the review did not
count** — `SatisfiableBaseSet` / `SatisfiableDenseSet` / `SatisfiableDiscreteSet`
(`Metalogic/SetConsequence.lean:230,277,329`), which are the same four-way binder split in
existential form. `SatisfiableDedekindDenseSet` does not exist, which is itself the H3 "missing
fourth row" showing up in a second place.

Complete live inventory (Boneyard excluded), enumerated by `grep '^def Valid\|^def valid\|…'`:

**Validity (15)** — matches the task's count exactly:
- `Semantics/Validity.lean:94,206,248,301,336` — `valid`, `ValidDense`, `ValidDiscrete`,
  `ValidDedekind`, `ValidDedekindDense`
- `Semantics/BLValidity.lean:77,102,115,132` — `BLValid`, `BLValidDense`, `BLValidDiscrete`,
  `BLValidDedekindDense`
- `Semantics/IntTransfer.lean:336` — `ValidInt`
- `FrameConditions/Validity.lean:59,79,89,100,199` — `ValidOver`, `ValidLinear`, `ValidDenseFc`,
  `ValidDiscreteFc`, `ValidOverInt`

**Consequence (8 + 1 BL)**:
- `Metalogic/SetConsequence.lean:79,87,97,106` (set-level, 4)
- `Semantics/Validity.lean:125` — `SemanticConsequence`
- `Metalogic/StrongCompleteness.lean:171,719,828` — `SemanticConsequence{DedekindDense,Dense,Discrete}`
- `Semantics/BLValidity.lean:89` — `BLSemanticConsequence`

**Satisfiability (3, uncounted by the review)**: `Metalogic/SetConsequence.lean:230,277,329`

---

## 2. Call-site census (measured, not estimated)

### 2.1 Monotonicity lemmas to be replaced

| Lemma | Location | External call sites |
|---|---|---|
| `valid_implies_valid_dense` | `Validity.lean:349` | 38 in `Soundness.lean` (`axiom_dense_valid`), 1 in `Decidability/Correctness.lean:152` |
| `valid_implies_valid_discrete` | `Validity.lean:356` | 39 in `Soundness.lean` (`axiom_discrete_valid`), 1 in `Correctness.lean:159` |
| `valid_implies_validDedekind` | `Validity.lean:364` | **0** |
| `valid_implies_validDedekindDense` | `Validity.lean:371` | ~38 in `Soundness.lean:1763ff`, 1 in `Correctness.lean` |
| `validDedekindDense_of_validDedekind` | `Validity.lean:383` | **0** |
| `validDedekindDense_of_validDense` | `Soundness.lean:1469` (**`private`**) | internal only |

**Key structural observation.** Nearly every call site of the first, second and fourth lemmas sits
inside `axiom_dense_valid` (`Soundness.lean:929`), `axiom_discrete_valid` (`:990`) and the Dedekind
analogue (`:1753ff`) — three ~40-line `cases h with` blocks that each apply one monotonicity lemma
to the *same 37 base-axiom validity lemmas* that `axiom_valid` (`:875`) uses directly. That triple
is the single largest concrete payoff of this task; see Phase 5 in §6.

`validDedekindDense_of_validDense` is currently **`private` inside `Soundness.lean`** — it is the
`Dense ≤ Dedekind` instance of the very lemma this task introduces, hand-written a second time
because no general form existed. Verified in probe 13 that it becomes a one-liner.

### 2.2 The four `SetSemanticConsequence*_mono` copies

`SetConsequence.lean:124,130,136,144`. External consumers: 3 in `StrongCompleteness.lean`, 2 in
`DiscreteNonCompactness.lean`, plus 20 internal in `SetConsequence.lean` itself.

### 2.3 Comment-stripped occurrence counts (the real migration size)

| Name | code-only | Name | code-only |
|---|---|---|---|
| `ValidDiscrete` | 28 | `SetSemanticConsequenceDiscrete` | 7 |
| `ValidDedekindDense` | 23 | `SetSemanticConsequenceBase` | 5 |
| `ValidDense` | 18 | `SetSemanticConsequenceDense` | 5 |
| `ValidDedekind` | **3** | `SetSemanticConsequenceDedekindDense` | 3 |

**Total 92**, distributed: `Soundness.lean` 23, `SetConsequence.lean` 20,
`StrongCompleteness.lean` 11, `Semantics/Validity.lean` 10, `Decidability/BiLasso/Assembly.lean` 9,
`FrameConditions/Validity.lean` 5, `Decidability/Correctness.lean` 3, and eight files with 1-2 each
(`BXCanonical/Completeness.lean`, `BXCanonical/CompletenessDedekind.lean`,
`DiscreteNonCompactness.lean`, `Decidability/Verified/Bridge/{DenseTruth,IntTruth}.lean`,
`SoundnessLemmas/CoValidity.lean`, `Semantics/IntTransfer.lean`,
`Tests/BimodalTest/TableauConformance.lean`).

---

## 3. Design decisions, with the reasoning

### 3.1 Do NOT consume the marker typeclasses verbatim

`FrameConditions/FrameClass.lean` defines `LinearTemporalFrame` (:88), `SerialFrame` (:103),
`DenseTemporalFrame` (:124), `DiscreteTemporalFrame` (:148), `DedekindTemporalFrame` (:182). The
task calls this "exactly the binder-list-as-predicate-on-D that a FrameClass-indexed validity
needs." **It is not, in two places:**

- `SerialFrame` (and therefore every class above it) binds `[Nontrivial D] [NoMaxOrder D]
  [NoMinOrder D]`. The `Valid*` predicates bind only `[Nontrivial D]`.
- `DiscreteTemporalFrame` binds `[SuccOrder D] [PredOrder D] [IsSuccArchimedean D]` but **not**
  `[IsPredArchimedean D]`, which `ValidDiscrete` (`Validity.lean:248`) does bind.

The first mismatch turns out to be harmless — **verified**: `NoMaxOrder D` and `NoMinOrder D` are
both discharged by `infer_instance` from `[AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D]
[Nontrivial D]` alone (a nontrivial linearly ordered abelian group has neither endpoint). The
second is a genuine widening of the carrier class, and retargeting `soundness_discrete` at it
would be an unforced semantic change on a flagship-adjacent theorem.

Compounding this: the marker layer is **fully orphaned**. `import FormalSystem.FrameConditions`
appears exactly once outside the subtree, in the top-level aggregator `FormalSystem/FormalSystem.lean`.
No `Semantics/` or `Metalogic/` module imports it. `DedekindTemporalFrame` (10 occurrences, all in
its own file) has *zero* consumers of any kind.

**Recommendation**: define `FrameClass.Sat` fresh against the raw Mathlib predicates, matching the
existing `Valid*` binder sets on the nose (so the migration is provably content-free), then either
retire the marker classes or re-derive them from `Sat` in a follow-up. Do not route the load-bearing
predicates through them in this task.

### 3.2 `Sat` must be a plain `Prop`-valued `def`, not a marker class

Two constraints force this:

- `SuccOrder` and `PredOrder` are **data-carrying** classes, so the Discrete constraint cannot be a
  bare instance-implicit marker. It is expressed as an existential over the instances:
  `∃ (s : SuccOrder D) (p : PredOrder D), @IsSuccArchimedean D _ s ∧ @IsPredArchimedean D _ p`.
  This is sound to eliminate because the payload (`TruthAt … φ`) is a `Prop` that does not mention
  the instances, so `(∃ i, Q i) → P` and `∀ i, Q i → P` are interderivable. Both directions are
  proved in probe `validIn_discrete_iff`.
- Monotonicity requires **recovering** the constraint content (`Dense ≤ Dedekind` must extract
  `DenselyOrdered D` from the Dedekind constraint). A marker class with instance-implicit
  arguments discards that content and makes `Sat.anti` unprovable.

### 3.3 Module placement

`FrameClass` lives in `ProofSystem/Axioms.lean` (imports only `Syntax.Formula`).
`Semantics/Validity.lean` does not import `ProofSystem`. The new definitions need both.

Verified acyclic: `ProofSystem.Axioms` transitively imports nothing from `Semantics/` or
`Metalogic/`.

**Recommendation: a new module `FormalSystem/Semantics/FrameClassValidity.lean`**, importing
`FormalSystem.Semantics.Validity` + `FormalSystem.ProofSystem.Axioms`. Rationale:

- It must sit in `Semantics/` (not `Metalogic/`) so that `Semantics/BLValidity.lean` can import it
  for the BL⁺ mirror — `Metalogic/` is downstream of `Semantics/`.
- It must be a *new* file, not an addition to `Semantics/Validity.lean`, so that the
  `Semantics → ProofSystem` seam is confined to one explicitly-documented module rather than
  imposed on every consumer of `Validity.lean`.
- `FrameConditions/Validity.lean` is the wrong home despite already importing the marker layer:
  `Metalogic/SetConsequence.lean` and `Semantics/BLValidity.lean` would then both have to import
  `FrameConditions/`, inverting the current direction (`FrameConditions/Soundness.lean` imports
  `Metalogic/Soundness.lean`).

Housekeeping for `check-module-invariants.sh`: add the new module to `FormalSystem/Semantics.lean`
(C8 aggregator convention — the aggregator currently lists 18 imports, lines 7-24).

Alternative considered and rejected for this task: relocating `inductive FrameClass` itself into a
shared low-level module so neither side imports the other. Cleaner layering, but it moves a
namespace that ~45 axiom constructors and every `DerivationTree`/`Derivable` signature reference.
Recommend as a separate follow-up if the seam proves unpopular.

### 3.4 Naming: prefer `ValidIn`, not `ValidOn`

`TaskFrame.ValidOn` already exists (`Semantics/Validity.lean:561`, `def:frame-validity`, 16
occurrences), and six `Semantics/` modules carry a bare `open TaskFrame`
(`TaskFrame.lean:1457`, `TaskModel.lean:91`, `Extension/{Constraint,Admissible,Step,Extension}.lean`).
A sibling `FormalSystem.Semantics.ValidOn` would be ambiguous inside those files.

Recommend `ValidIn (fc : FrameClass) (φ : Formula)` and
`SetSemanticConsequenceOn (fc) (Γ) (φ)`. Also recommend introducing **no new notation**: `⊨[D]`
(`FrameConditions/Validity.lean:66`) is already taken by `ValidOver`, and `⊨` by `valid`.

---

## 4. The verified prototype

Every declaration below was compiled against the current tree via `lake env lean` with **zero
errors and zero sorries**. Reproduce verbatim.

### 4.1 The interpretation and the ONE monotonicity lemma

```lean
namespace FormalSystem.ProofSystem

/-- Semantic reading of the proof-side `FrameClass` tag: the constraint a duration carrier
    must satisfy for a `fc`-derivation to be sound over it. -/
def FrameClass.Sat (fc : FrameClass) (D : Type) [AddCommGroup D] [LinearOrder D]
    [IsOrderedAddMonoid D] : Prop :=
  match fc with
  | .Base     => True
  | .Dense    => DenselyOrdered D
  | .Discrete => ∃ (s : SuccOrder D) (p : PredOrder D),
      @IsSuccArchimedean D _ s ∧ @IsPredArchimedean D _ p
  | .Dedekind => DenselyOrdered D ∧ ∀ S : Set D, S.Nonempty → BddAbove S → ∃ x, IsLUB S x

/-- `Sat` is ANTITONE in the frame class: a larger class constrains carriers more. -/
theorem FrameClass.Sat.anti {fc₁ fc₂ : FrameClass} (h : fc₁ ≤ fc₂)
    {D : Type} [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D]
    (hs : fc₂.Sat D) : fc₁.Sat D := by
  cases fc₁ <;> cases fc₂ <;> simp_all [FrameClass.Sat, LE.le]

end FormalSystem.ProofSystem

/-- Validity indexed by frame class, defined ONCE. -/
def ValidIn (fc : FrameClass) (φ : Formula) : Prop :=
  ∀ (D : Type) [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D] [Nontrivial D],
    fc.Sat D → ValidOver D φ

/-- THE monotonicity lemma. Points the same direction as `DerivationTree.lift`. -/
theorem validIn_mono {fc₁ fc₂ : FrameClass} (h : fc₁ ≤ fc₂) {φ : Formula}
    (hv : ValidIn fc₁ φ) : ValidIn fc₂ φ :=
  fun D _ _ _ _ hs => hv D (FrameClass.Sat.anti h hs)
```

`ValidOver` is `FormalSystem.FrameConditions.ValidOver` (`FrameConditions/Validity.lean:59`) —
the one genuinely load-bearing definition in that dead layer. If the import direction argued in
§3.3 is preferred, inline its three-line body instead and retire `ValidOver`.

Note that `Sat` does **not** bind `[Nontrivial D]`; `ValidIn` supplies it. This matches every
existing `Valid*` predicate and keeps `Sat` reusable by the BL⁺ mirror unchanged.

### 4.2 The four bridges (all proved)

```lean
theorem validIn_base_iff (φ : Formula) : ValidIn .Base φ ↔ valid φ :=
  ⟨fun h D _ _ _ _ F M τ hτ t => h D trivial F M τ hτ t,
   fun h D _ _ _ _ _ F M τ hτ t => h D F M τ hτ t⟩

theorem validIn_dense_iff (φ : Formula) : ValidIn .Dense φ ↔ ValidDense φ :=
  ⟨fun h D _ _ _ _ _ F M τ hτ t => h D ‹DenselyOrdered D› F M τ hτ t,
   fun h D _ _ _ _ hd F M τ hτ t => @h D _ _ _ hd _ F M τ hτ t⟩

theorem validIn_discrete_iff (φ : Formula) : ValidIn .Discrete φ ↔ ValidDiscrete φ := by
  constructor
  · intro h D _ _ _ _ _ _ _ _ F M τ hτ t
    exact h D ⟨inferInstance, inferInstance, ‹_›, ‹_›⟩ F M τ hτ t
  · intro h D _ _ _ _ hs F M τ hτ t
    obtain ⟨s, p, ha, hb⟩ := hs; exact @h D _ _ _ s p ha hb _ F M τ hτ t

theorem validIn_dedekind_iff (φ : Formula) : ValidIn .Dedekind φ ↔ ValidDedekindDense φ := by
  constructor
  · intro h D _ _ _ _ _ hlub F M τ hτ t; exact h D ⟨‹DenselyOrdered D›, hlub⟩ F M τ hτ t
  · intro h D _ _ _ _ hs F M τ hτ t
    obtain ⟨hd, hlub⟩ := hs; exact @h D _ _ _ hd _ hlub F M τ hτ t
```

### 4.3 The five existing lemmas re-derived from the one (all proved)

```lean
theorem valid_implies_valid_dense {φ : Formula} (h : valid φ) : ValidDense φ :=
  (validIn_dense_iff φ).mp (validIn_mono (by decide) ((validIn_base_iff φ).mpr h))
theorem valid_implies_valid_discrete {φ : Formula} (h : valid φ) : ValidDiscrete φ :=
  (validIn_discrete_iff φ).mp (validIn_mono (by decide) ((validIn_base_iff φ).mpr h))
theorem valid_implies_validDedekindDense {φ : Formula} (h : valid φ) : ValidDedekindDense φ :=
  (validIn_dedekind_iff φ).mp (validIn_mono (by decide) ((validIn_base_iff φ).mpr h))
-- the currently-`private` Soundness.lean:1469 lemma, now an instance of the same one:
theorem validDedekindDense_of_validDense {φ : Formula} (h : ValidDense φ) : ValidDedekindDense φ :=
  (validIn_dedekind_iff φ).mp (validIn_mono (by decide) ((validIn_dense_iff φ).mpr h))
```

Because the *statements* are unchanged, all ~115 application sites in `Soundness.lean` and
`Correctness.lean` keep working untouched. This is what makes the axiom-profile acceptance
criterion safe: the migration is additive first, subtractive second.

### 4.4 Set-level consequence, likewise (all proved)

```lean
def SetSemanticConsequenceOn (fc : FrameClass) (Γ : Set Formula) (φ : Formula) : Prop :=
  ∀ (D : Type) [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D] [Nontrivial D],
    fc.Sat D → ∀ (F : TaskFrame D) (M : TaskModel F) (τ : WorldHistory F) (_ : τ.IsTotal) (t : D),
      (∀ ψ ∈ Γ, TruthAt M τ t ψ) → TruthAt M τ t φ

theorem setSemanticConsequenceOn_mono {fc : FrameClass} {Γ Δ : Set Formula} {φ : Formula}
    (h_sub : Γ ⊆ Δ) (h : SetSemanticConsequenceOn fc Γ φ) : SetSemanticConsequenceOn fc Δ φ := by
  intro D _ _ _ _ hs F M τ hτ t h_all
  exact h D hs F M τ hτ t (fun ψ hψ => h_all ψ (h_sub hψ))

theorem setSemanticConsequenceOn_mono_fc {fc₁ fc₂ : FrameClass} (hle : fc₁ ≤ fc₂)
    {Γ : Set Formula} {φ : Formula} (h : SetSemanticConsequenceOn fc₁ Γ φ) :
    SetSemanticConsequenceOn fc₂ Γ φ :=
  fun D _ _ _ _ hs => h D (FrameClass.Sat.anti hle hs)
```

Plus `ssc_{base,dense,discrete,dedekind}_iff`, structurally identical to §4.2 with the `h_all`
argument threaded — all four compiled.

The two monotonicity lemmas here are the exact analogue of `setDerivable_mono`
(`SetConsequence.lean:118`) and `DerivationTree.lift` (`Derivation.lean:184`), which is the
symmetry the review asked for.

### 4.5 Definitional-duplicate check

```lean
example (φ : Formula) : ValidInt φ = ValidOverInt φ := rfl   -- compiles
```

`Semantics/IntTransfer.lean:336` and `FrameConditions/Validity.lean:199` are the same predicate.
`ValidOverInt` has zero external consumers; retire it and keep `ValidInt`.

---

## 5. Hazard analysis

### 5.1 The `ValidDedekind` trap, and how the fix closes it

`Validity.lean:301`'s docstring warns that retargeting `soundness_dedekind` at `ValidDedekind`
gives a refutable theorem, because `FrameClass.Dedekind > FrameClass.Dense` makes `density` and
`dense_indicator` admissible in a `.Dedekind` derivation while `ℤ` satisfies every
`ValidDedekind` binder.

With `FrameClass.Sat .Dedekind = DenselyOrdered D ∧ LUB`, the binder list for the `.Dedekind`
soundness target is *computed from the frame class*. There is no longer a syntactically adjacent
"simpler" predicate to slip into: the only way to state `.Dedekind` validity is `ValidIn .Dedekind`,
and it is the dense one by construction. The trap is closed by making the wrong statement
unwritable rather than by warning against it.

### 5.2 `ValidDedekind` has no frame class, and must stop looking like it does

`ValidDedekind` is the paper's TM⁺_c (complete simpliciter, model class `{ℤ, ℝ}` up to `≃+o`),
and `ProofSystem/Axioms.lean:519-524` states explicitly that no `FrameClass` element picks it out.
It therefore cannot join the `ValidIn` family. Verified: `valid → ValidDedekind` and
`ValidDedekind → ValidDedekindDense` remain hand-written (probe 14 compiles them unchanged).

**Recommendation**: rename `ValidDedekind → ValidComplete` (and
`valid_implies_validDedekind → valid_implies_validComplete`,
`validDedekindDense_of_validDedekind → validDedekindDense_of_validComplete`). Cost is 3 code sites
and ~15 prose references. Benefit: the name no longer shares a stem with `FrameClass.Dedekind`,
which is the surface the docstring hazard lives on. This is the cheapest available closure of the
trap and should be part of the task, not deferred.

### 5.3 Implementation hazards to carry into the plan

- **Existential instance binders.** `SetConsequence.lean:322-328` carries an explicit warning: when
  destructuring the `Satisfiable*Set` existentials, use bare `_` names for the class binders and let
  instance synthesis recover them; naming them and re-installing with `haveI` **breaks definitional
  equality with the instances baked into `F`'s and `M`'s types**. The `Sat .Discrete` existential
  has the same shape. The `obtain ⟨s, p, ha, hb⟩ := hs; exact @h D _ _ _ s p ha hb _ …` pattern in
  §4.2 sidesteps this by passing the instances positionally with `@` rather than re-installing them
  — use that pattern, not `haveI`.
- **C14 (`check-module-invariants.sh`)** scans `FormalSystem/**/*.lean` **docstrings** for stale
  axiom counts (`\b(14|21|42|44)\s+(axiom|constructor)`). New and rewritten docstrings must say 45.
- **C15** pins paper-anchor citations against `specs/paper-definitions-of-record.md`. New docstrings
  should reuse existing anchors (`def:logical-consequence`, `def:frame-validity`) or cite none.
- **C2/C14 axiom baselines** cover `BXCanonical.completeness{,_dense,_discrete}`,
  `Chronicle.countermodel_dense`, `Decidability.sound_of_isValid`, `completeness_dedekind`. All six
  sit downstream of `ValidDense`/`ValidDiscrete`/`ValidDedekindDense`. Keeping the old *statements*
  as derived corollaries (§4.3) is what makes those baselines safe; verify with
  `bash scripts/check-module-invariants.sh` at every phase boundary.
- **`decide` on `FrameClass` order goals.** `FrameClass` has `DecidableEq` and a `DecidableRel` for
  `≤` (`Axioms.lean:549`), and `by decide` discharges every closed order goal — used in §4.3 and
  already used by the regression `example`s.

---

## 6. Recommended phase decomposition

Sized so each phase is one agent run and ends at a green `lake build`.

**Phase 1 — introduce the layer (additive, zero call-site churn).**
Create `FormalSystem/Semantics/FrameClassValidity.lean` with §4.1, §4.2, §4.4 verbatim. Add it to
`FormalSystem/Semantics.lean`. Gate: `lake build`, `check-module-invariants.sh`.

**Phase 2 — collapse the monotonicity lemmas.**
Replace the bodies of `valid_implies_valid_dense/_discrete/_validDedekindDense`
(`Validity.lean:349,356,371`) with the §4.3 one-liners, **statements unchanged**. Delete the
`private validDedekindDense_of_validDense` (`Soundness.lean:1469`) in favour of the general one.
Replace the four `setSemanticConsequence*_mono` bodies with `setSemanticConsequenceOn_mono` +
bridges. Gate: axiom profiles must be byte-identical to baseline.

**Phase 3 — retire the dead `FrameConditions/Validity.lean` surface.**
Delete `ValidLinear`, `ValidDenseFc`, `ValidDiscreteFc`, `ValidOverInt` and the nine bridge
theorems (all zero-consumer). Keep `ValidOver`. Rewrite the module docstring to point at the new
layer. Optionally retire the marker classes in `FrameConditions/FrameClass.lean` or re-derive them
from `Sat`. Gate: `lake build` (this phase should touch nothing outside `FrameConditions/`).

**Phase 4 — `ValidDedekind → ValidComplete` rename + `ValidInt`/`ValidOverInt` dedup.**
3 + 2 code sites, ~20 prose references. Gate: C14/C15.

**Phase 5 — collapse `axiom_dense_valid` / `axiom_discrete_valid` / the Dedekind analogue into one
`axiom_validIn {φ} (h : Axiom φ) (fc) (h_fc : h.minFrameClass ≤ fc) : ValidIn fc φ`.**
This is the largest concrete win: three ~40-line `cases` blocks (`Soundness.lean:929,990,~1753`)
plus `axiom_valid` (`:875`) become one 45-case match where the 37 Base rows are
`validIn_mono (FrameClass.base_le fc) ((validIn_base_iff _).mpr (…_valid …))`. **Off-ramp**: if this
does not converge inside one dispatch, stop after Phase 4 — Phases 1-4 already satisfy the task's
four stated deliverables.

**Phase 6 — migrate remaining call sites and retire the copied definitions.**
Redefine `ValidDense`/`ValidDiscrete`/`ValidDedekindDense` and the four
`SetSemanticConsequence*` as `def X := ValidIn .Y` (or delete outright), fixing the 92 code sites.
Highest-churn files: `Soundness.lean` (23), `SetConsequence.lean` (20),
`StrongCompleteness.lean` (11), `BiLasso/Assembly.lean` (9).

**Explicitly out of scope (follow-ups to file):**
- Unifying the four `soundness_*` inductions into
  `Derivable fc Γ φ → SetSemanticConsequenceOn fc Γ φ` (review issue H2, ~23 theorems across four
  files, incl. `SoundnessLemmas/FrameClassVariants.lean` at 1041 lines). The present task supplies
  the *vocabulary* that theorem needs; proving it is a task of its own.
- The BL⁺ mirror (`BLValid*`, 4 predicates + 3 lemmas). Cheap, because `Sat` is language-agnostic:
  `BLValidIn fc φ := ∀ D [insts], fc.Sat D → ∀ F M τ hτ t, BLTruthAt M τ t φ` reuses the same
  interpretation with `BLTruthAt` swapped in. Fold in if Phases 1-6 land with room.
- `SatisfiableBaseSet/DenseSet/DiscreteSet` → `SatisfiableSetOn fc` (the ∃-dual; also supplies the
  missing `SatisfiableDedekindDenseSet` row that H3 reports).

---

## 7. Zero-debt compliance

No step of this plan requires a `sorry` or a new axiom. Every mathematically non-trivial
obligation — the antitonicity of `Sat`, all four `ValidIn` bridges, all four
`SetSemanticConsequenceOn` bridges, and all five re-derived monotonicity lemmas — was **proved and
compiled** during this research pass (§4). The remaining work is mechanical migration behind
statements that do not change. The one phase with genuine uncertainty (Phase 5) has an explicit
off-ramp that leaves the task's stated deliverables complete.

## 8. Reproduction

The probes were compiled with:

```
lake env lean <scratch>/Probe.lean    # probes 1-6:   Sat, anti, ValidIn, mono, 4 bridges
lake env lean <scratch>/Probe2.lean   # probes 7-11:  SetSemanticConsequenceOn, 2 monos, 4 bridges, ValidInt=ValidOverInt
lake env lean <scratch>/Probe3.lean   # probes 12-14: the 5 re-derived lemmas
```

All three exited 0 with no output. The full sources are reproduced in §4.
