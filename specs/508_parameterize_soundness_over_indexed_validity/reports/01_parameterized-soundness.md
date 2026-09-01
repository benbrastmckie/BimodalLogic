# Research: Collapse the soundness family onto one `FrameClass`-parameterized theorem

**Status**: researched
**Verification basis**: every line number below re-derived against the working tree at
`2fcc66f4e`; a full `lake build` (2564 modules, exit 0) established the baseline; a compiled,
sorry-free reference implementation of the whole collapse was built and its axiom profile
compared against the four existing theorems.

---

## 1. Headline finding

**The collapse is verified, not merely feasible.** A complete reference implementation —
one parameterized soundness theorem, one uniform valid/swap-valid recursion, two 45-case
per-axiom leaf lemmas, and all four existing statements recovered as one-line corollaries —
was written, compiled sorry-free against the live tree, and audited for axiom profile. It is
saved verbatim at:

`/home/benjamin/Projects/BimodalLogic/specs/508_parameterize_soundness_over_indexed_validity/reports/01_verified-reference-implementation.lean`

That file is 239 lines and is the implementation, not a sketch. It was built as
`FormalSystem/Probe508.lean` (`lake build FormalSystem.Probe508`, exit 0, zero `sorry`
warnings) and then removed from the tree; the working tree is unmodified outside `specs/`.

**Axiom profile audit (measured, not asserted)** — all seven new declarations and all four
existing ones report the identical profile:

```
'Probe508.soundness_in'            depends on axioms: [propext, Classical.choice, Quot.sound]
'Probe508.soundness''              depends on axioms: [propext, Classical.choice, Quot.sound]
'Probe508.soundness_dense''        depends on axioms: [propext, Classical.choice, Quot.sound]
'Probe508.soundness_discrete''     depends on axioms: [propext, Classical.choice, Quot.sound]
'Probe508.soundness_dedekind''     depends on axioms: [propext, Classical.choice, Quot.sound]
'Probe508.axiom_validIn_min'       depends on axioms: [propext, Classical.choice, Quot.sound]
'Probe508.axiom_swap_validIn_min'  depends on axioms: [propext, Classical.choice, Quot.sound]
'FormalSystem.Metalogic.soundness'           ... [propext, Classical.choice, Quot.sound]
'FormalSystem.Metalogic.soundness_dense'     ... [propext, Classical.choice, Quot.sound]
'FormalSystem.Metalogic.soundness_discrete'  ... [propext, Classical.choice, Quot.sound]
'FormalSystem.Metalogic.soundness_dedekind'  ... [propext, Classical.choice, Quot.sound]
```

The acceptance criterion "axiom profiles preserved on all flagship soundness results" is
therefore already discharged at the design level.

---

## 2. Corrections to the task brief (all verified)

The brief's line citations are stale, and two of its scope claims are superseded by work that
has already landed.

### 2.1 Stale line numbers

| Brief said | Actual (verified) |
|---|---|
| `Soundness.lean` `soundness`:1100 | **1152** |
| `soundness_dense`:1274 | **1329** |
| `soundness_discrete`:1420 | **1477** |
| `soundness_dedekind`:1947 | **2014** |
| `*_valid` variants :1205, :1368, :1928 | `soundness_dense_valid` **1256**, `soundness_discrete_valid` **1421**, `soundness_dedekind_valid` **1995** |
| `StrongCompleteness.lean` :667, :771, :879, :524 | `soundness_base_consequence` **676**, `soundness_dense_consequence` **781**, `soundness_discrete_consequence` **891**, `soundness_dedekind_consequence` **530** |
| `BaseLanguageSoundness.lean` :168–252 | `bl_soundness` **201**, `_dense` **215**, `_discrete` **229**, `_dedekind` **249**; `*_valid` **264/269/274/280** |
| `FrameClassVariants.lean` "1041 lines" | 1041 lines — **correct** |
| `Validity.lean:301` dedekind-target docstring | the `ValidDedekindDense` discussion is at **634–699**; `ValidDedekind` at **645**, `ValidDedekindDense` at **699**. Line 301 is inside the `valid` docstring. |

### 2.2 `FrameConditions/` — confirmed deleted

`FormalSystem/FrameConditions/` does not exist. `soundness_over` / `soundness_linear` /
`soundness_dense` / `soundness_discrete` / `soundness_Int` are gone from the tree. That row of
the review's H2 table is already resolved; it is **not** in scope.

Residual references to the retired layer survive only in `FormalSystem/Boneyard/`
(`SoundnessVariants/DenseSoundness.lean:52`, `SoundnessVariants/DiscreteSoundness.lean:54`,
`StrictSemanticsLegacy/DiscreteCompleteness.lean:142`). **Boneyard is not compiled** — there is
no `.lake/build/lib/lean/FormalSystem/Boneyard/` output and no root imports it — so those
references impose no constraint on the collapse.

### 2.3 The BL-side definition collapse has ALREADY landed, and NOT in the shape the brief describes

This is the most important scope correction. The brief (following review M3) prescribes
`BLValidOn fc φ := ValidOn fc (tr φ)`, routed through `blValid_iff_valid_tr`. **The tree took a
different and deliberately-argued route, and it is already done:**

| Declaration | Location | Shape |
|---|---|---|
| `TaskFrame.BLValidOn` | `Semantics/BLValidity.lean:96` | native over `BLTruthAt` |
| `BLValidOnFrames` | `:102` | `∀ F, P F → F.BLValidOn φ` |
| `BLValidIn` | `:107` | `BLValidOnFrames fc.Sat φ` |
| `BLValid` | `:123` | `BLValidIn .Base` |
| `BLValidDense` | `:159` | `BLValidIn .Dense` |
| `BLValidDiscrete` | `:184` | `BLValidIn .Discrete` |
| `BLValidDedekindDense` | `:245` | `BLValidIn .Dedekind` |

The docstring at `BLValidity.lean:81-86` states the reason for not going through `tr`: "`BLTruthAt`
is defined natively on `BLFormula`'s six constructors per `def:BL-semantics`, not via
`untl`/`snce` — but it shares one and the same `FrameClass.Sat`, so the frame classes the two
languages are indexed by are literally the same classes and not two parallel copies."

**Recommendation: do not re-open this.** Defining `BLValidOn fc φ := ValidOn fc (tr φ)` would
replace a natively-anchored BL semantics with a translation-defined one, contradicting
`def:BL-semantics` and the recorded rationale. Review M3's *definitional* half is discharged; what
remains of M3 is only the eight `bl_soundness*` theorems, which collapse mechanically (§5).

The `blValid_implies_*` bridges the brief lists at `:153,:157,:162` are now at **`:283`, `:287`,
`:291`** and are one-liners over `BLValidIn.mono` (`:147`) — already collapsed.

### 2.4 `bl_soundness_discrete_succ` genuinely does not collapse

`BaseLanguageSoundness.lean:381` (+ `_valid` at `:413`) and `BLValidDiscreteSucc`
(`BLValidity.lean:221`) are **not** instances of the schema and must be preserved as-is. The
docstring at `BLValidity.lean:210-214` gives the reason: "there is no `FrameClass.Sat` variant
bundling `SuccOrder`+`PredOrder` alone (`TaskFrame.IsSuccArchDiscrete` bundles all four)". And
`BaseLanguageSoundness.lean:293-297` records that `bl_soundness_discrete_succ` "cannot be obtained
by translating and invoking `Soundness.soundness_discrete`, because that theorem's own binder
bundle carries the very two Archimedean instances being dropped here." It runs its own induction
against `BLTruthAt`. Leave it alone; it is a genuine 24th theorem, not a 24th copy.

### 2.5 The `Formula`-side validity layer has also already landed

Task 507 delivered exactly the substrate this task needs:

| Declaration | Location |
|---|---|
| `FrameClass` | `ProofSystem/Axioms.lean:531` |
| `Axiom.minFrameClass` | `ProofSystem/Axioms.lean:600` |
| `FrameClass.base_le` | `ProofSystem/Axioms.lean:618` |
| `FrameClass.Sat` | `Semantics/FrameClassValidity.lean:112` |
| `FrameClass.Sat.anti` | `:131` |
| `ValidOnFrames` | `Semantics/Validity.lean:273` |
| `ValidIn` | `:284` |
| `ValidIn.mono` | `:413` |
| `ValidIn.of_forall_total` / `.apply_total` | `:441` / `:448` |
| `valid := ValidIn .Base` | `:324` |
| `ValidDense/Discrete/DedekindDense` | `:468` / `:542` / `:699` |
| `SetConsequenceOnFrames` / `SetSemanticConsequenceOn` | `Metalogic/SetConsequence.lean:91` / `:98` |

`FrameClass.Sat` (`FrameClassValidity.lean:112`):

```lean
def FrameClass.Sat : FrameClass → TaskFrame → Prop
  | .Base, _ => True
  | .Dense, F => F.IsDense
  | .Discrete, F => F.IsSuccArchDiscrete
  | .Dedekind, F => F.IsDedekind
```

The binder bundles line up **definitionally** with the four existing soundness theorems' binder
lists — this is the fact that makes the corollaries one-liners, and it was verified by
compilation:

| `fc` | `Sat fc F` unfolds to | existing theorem's binders | corollary's `hF` argument |
|---|---|---|---|
| `.Base` | `True` | (none) | `trivial` |
| `.Dense` | `DenselyOrdered F.Duration` | `[DenselyOrdered F.Duration]` | `inst` |
| `.Discrete` | `∃ (_:SuccOrder)(_:PredOrder), IsSuccArchimedean ∧ IsPredArchimedean` | four instance binders | `⟨so, po, hsa, hpa⟩` |
| `.Dedekind` | `IsDense ∧ IsComplete` | `[DenselyOrdered]` + `h_lub` | `⟨inst, h_lub⟩` |

---

## 3. The verified architecture

Four declarations replace the whole family. Full text in
`reports/01_verified-reference-implementation.lean`.

### 3.1 `axiom_validIn_min` — per-axiom validity, once

```lean
theorem axiom_validIn_min {φ : Formula} (ax : Axiom φ) : ValidIn ax.minFrameClass φ
```

45 arms, each a one-line `exact` against a validity lemma that **already exists**:

- 37 Base arms → the `*_valid` lemmas at `Soundness.lean:140–895` (`⊨ φ` *is* `ValidIn .Base φ`
  definitionally, so no adapter is needed). Two naming traps: `serial_future ↦
  serial_future_axiom_valid`, `serial_past ↦ serial_past_axiom_valid`.
- `density` → `density_valid` (`:439`); `dense_indicator` → `dense_indicator_valid` (`:427`)
- `prior_UZ/SZ/z1` → `prior_UZ_valid` (`:895`), `prior_SZ_valid` (`:903`), `z1_valid` (`:910`)
- `prior_U_gap/prior_S_gap/sep` → `prior_U_gap_valid` (`:1575`), `prior_S_gap_valid` (`:1625`),
  `sep_valid` (`:1696`)

Then `axiom_validIn ax h_fc := ValidIn.mono h_fc (axiom_validIn_min ax)` covers every `fc`.
This single lemma is what replaces the 4 × 45-case dispatch in `axiom_valid` (`:925`),
`axiom_dense_valid` (`:979`), `axiom_discrete_valid` (`:1040`), `axiom_dedekind_valid` (`:1819`).

### 3.2 `axiom_swap_validIn_min` — per-axiom swap-validity, once

```lean
theorem axiom_swap_validIn_min {φ : Formula} (ax : Axiom φ) :
    ValidIn ax.minFrameClass φ.swapTemporal
```

Proved by `by_cases hbase : ax.minFrameClass ≤ FrameClass.Base`:

- **Base branch** (37 axioms in one arm): `le_antisymm hbase (FrameClass.base_le _)` rewrites the
  index to `.Base`, then delegates to `SoundnessLemmas.axiom_swap_valid_general`
  (`FrameClassVariants.lean:45`) at `D := F.Duration` through `F.toFibre`.
- `density` / `dense_indicator` → `SoundnessLemmas.axiom_swap_valid`
  (`DenseValidity.lean:296`), under `ValidDense.of_forall`. **Trap**: the `h_fc` argument must be
  `trivial`, not `by decide` — `by decide` fails with *"Expected type must not contain free
  variables"* because the goal mentions `(Axiom.density a0).minFrameClass`. This was hit and fixed
  during verification.
- `prior_UZ/SZ/z1` → `prior_SZ_is_valid` (`:782`), `prior_UZ_is_valid` (`:742`), `z1_past_is_valid`
  (`:883`) at `.swapTemporal`, under `ValidDiscrete.of_forall`.
- `prior_U_gap/prior_S_gap` → each other's forward lemma at `.swapTemporal` (the swap is
  definitional); `sep` → `sep_swap_valid` (`:1763`).
- `| _ => exact absurd trivial hbase` closes the 37 Base constructors in the non-base branch.

### 3.3 `derivable_valid_and_swap_validIn` — one recursion for all four classes

```lean
theorem derivable_valid_and_swap_validIn {fc : FrameClass} {φ : Formula}
    (d : DerivationTree fc [] φ) : ValidIn fc φ ∧ ValidIn fc φ.swapTemporal
```

Structurally identical to `derivable_valid_and_swap_valid_dedekind` (`Soundness.lean:1919`) with
`ValidDedekindDense.of_forall/.apply` swapped for `ValidIn.of_forall_total/.apply_total` and the
`hF : fc.Sat F` threaded through. Same `termination_by d.height` / `decreasing_by` block, verbatim.
It replaces four separate copies of this recursion:

| Existing | Location |
|---|---|
| `derivable_valid_and_swap_valid_general` | `FrameClassVariants.lean:683` |
| `derivable_valid_and_swap_valid_discrete` | `FrameClassVariants.lean:994` |
| `derivable_valid_and_swap_valid` (dense) | `DenseValidity.lean:1320` |
| `derivable_valid_and_swap_valid_dedekind` | `Soundness.lean:1919` |

### 3.4 `soundness_in` — the single theorem

```lean
theorem soundness_in {fc : FrameClass} (Γ : Context) (φ : Formula)
    (d : DerivationTree fc Γ φ)
    (F : TaskFrame) (hF : fc.Sat F) (M : TaskModel F)
    (τ : WorldHistory F) (h_mem : τ.IsTotal) (t : F.Duration)
    (h_ctx : ∀ ψ ∈ Γ, TruthAt M τ t ψ) :
    TruthAt M τ t φ
```

Seven induction arms, all one or two lines. `axiom` is
`(axiom_validIn h_ax h_fc).apply_total F hF M τ h_mem t`; `temporal_duality` is
`((derivable_valid_and_swap_validIn d').2).apply_total F hF M τ h_mem t`.

The `temporal_duality` case is the one place the four existing proofs genuinely diverge (Base uses
`derivable_implies_swap_valid_general`, Dense `derivable_implies_swap_valid`, Discrete
`derivable_implies_swap_valid_discrete`, Dedekind `derivable_valid_and_swap_valid_dedekind`);
§3.3 is what makes it uniform. This was the principal technical risk and it is retired.

The empty-context form is `soundness_validIn d := (derivable_valid_and_swap_validIn d).1`,
replacing `soundness_dense_valid` / `soundness_discrete_valid` / `soundness_dedekind_valid`.

---

## 4. The 23 → corollary map (verified compiling for the four `Formula`-side headliners)

| # | Existing theorem | Location | Becomes |
|---|---|---|---|
| 1 | `soundness` | `Soundness.lean:1152` | `soundness_in Γ φ d F trivial M τ h t hc` |
| 2 | `soundness_dense` | `:1329` | `soundness_in Γ φ d F inst M τ h t hc` |
| 3 | `soundness_discrete` | `:1477` | `soundness_in Γ φ d F ⟨so,po,hsa,hpa⟩ M τ h t hc` |
| 4 | `soundness_dedekind` | `:2014` | `soundness_in Γ φ d F ⟨inst,h_lub⟩ M τ h t hc` |
| 5 | `soundness_dense_valid` | `:1256` | `soundness_validIn d` |
| 6 | `soundness_discrete_valid` | `:1421` | `soundness_validIn d` |
| 7 | `soundness_dedekind_valid` | `:1995` | `soundness_validIn d` |
| 8 | `axiom_valid` | `:925` | `axiom_validIn h h_fc` |
| 9 | `axiom_dense_valid` | `:979` | `axiom_validIn h h_fc` |
| 10 | `axiom_discrete_valid` | `:1040` | `axiom_validIn h h_fc` |
| 11 | `axiom_dedekind_valid` | `:1819` | `axiom_validIn h h_fc` |
| 12 | `axiom_dedekind_swap_valid` | `:1888` | `axiom_swap_validIn h h_fc` |
| 13 | `derivable_valid_and_swap_valid_dedekind` | `:1919` | `derivable_valid_and_swap_validIn d` |
| 14 | `soundness_base_consequence` | `StrongCompleteness.lean:676` | `fun … => soundness_in …` |
| 15 | `soundness_dense_consequence` | `:781` | ditto |
| 16 | `soundness_discrete_consequence` | `:891` | ditto |
| 17 | `soundness_dedekind_consequence` | `:530` | ditto |
| 18 | `bl_soundness` | `BaseLanguageSoundness.lean:201` | `bl_soundness_in … trivial …` |
| 19 | `bl_soundness_dense` | `:215` | `bl_soundness_in … inst …` |
| 20 | `bl_soundness_discrete` | `:229` | `bl_soundness_in … ⟨so,po,hsa,hpa⟩ …` |
| 21 | `bl_soundness_dedekind` | `:249` | `bl_soundness_in … ⟨inst,h_lub⟩ …` |
| 22–25 | `bl_soundness{,_dense,_discrete,_dedekind}_valid` | `:264,269,274,280` | `bl_soundness_validIn d` |
| — | `bl_soundness_discrete_succ{,_valid}` | `:381,:413` | **PRESERVE UNCHANGED** (§2.4) |
| — | `derivable_valid_and_swap_valid_general` | `FrameClassVariants.lean:683` | deletable |
| — | `derivable_implies_swap_valid_general` | `:726` | deletable |
| — | `axiom_locally_valid_general` (private) | `:393` | deletable (290 lines) |
| — | `axiom_locally_valid_discrete` (private) | `:972` | deletable |
| — | `axiom_swap_valid_discrete` (private) | `:939` | deletable |
| — | `derivable_valid_and_swap_valid_discrete` | `:994` | deletable |
| — | `derivable_implies_swap_valid_discrete` | `:1034` | deletable |
| — | `derivable_valid_and_swap_valid` (dense) | `DenseValidity.lean:1320` | deletable |
| — | `derivable_locally_valid` | `:1362` | deletable (no call sites) |
| — | `derivable_implies_swap_valid` | `:1369` | deletable |

**Duplication the brief under-counted**: `axiom_locally_valid_general`
(`FrameClassVariants.lean:393–682`, ~290 lines) is a *third* full copy of base-axiom validity — the
same 37 facts already stated as `*_valid` at `Soundness.lean:140–895` and re-dispatched by
`axiom_valid` at `:925`. It is `private` and its only consumers are the two
`derivable_valid_and_swap_valid_*` recursions in the same file, so it dies with them.

**What must survive in `FrameClassVariants.lean`** (genuine semantic content, not duplication):
`axiom_swap_valid_general` (`:45`, ~348 lines of per-axiom swap proofs), `prior_UZ_is_valid`
(`:742`), `prior_SZ_is_valid` (`:782`), `z1_is_valid` (`:821`), `z1_past_is_valid` (`:883`). The
file shrinks from 1041 to roughly 500 lines rather than disappearing; the module stays in
`SoundnessLemmas.lean:10` and needs no manifest change.

---

## 5. BL side — mechanical, no new semantic content

The four `bl_soundness*` are already one-expression compositions
(`translate` → BL⁺ soundness → `truthAt_tr`). Parameterizing is a copy of §3.4's binder change:

```lean
theorem bl_soundness_in {fc : FrameClass} (Γ : BaseLanguage.Context) (φ : BLFormula)
    (d : BaseLanguage.DerivationTree fc Γ φ)
    (F : TaskFrame) (hF : fc.Sat F) (M : TaskModel F)
    (τ : WorldHistory F) (h_mem : τ.IsTotal) (t : F.Duration)
    (h_ctx : ∀ ψ ∈ Γ, BLTruthAt M τ t ψ) : BLTruthAt M τ t φ :=
  (truthAt_tr M φ τ t).mp
    (soundness_in (trCtx Γ) (tr φ) (Conservativity.translate d) F hF M τ h_mem t
      (truthAt_trCtx M τ t h_ctx))
```

`Conservativity.translate` is already `fc`-polymorphic (it is applied at all four tags today), and
`truthAt_tr` (`:110`) / `truthAt_trCtx` (`:131`) carry no frame condition. The four `*_valid`
forms become `bl_soundness_validIn d : BLValidIn fc φ` via `BLValidIn.of_forall_total` — **`BLValidIn.of_forall_total` /
`.apply_total` do NOT exist — verified**: `BLValidity.lean` carries only `BLValidOnFrames.mono`
(`:141`) and `BLValidIn.mono` (`:147`) at the generic layer, plus `BLValid.of_forall_total`
(`:128`) and the per-class `.of_forall`/`.apply` pairs. The generic adapters must be added by
mirroring `Validity.lean:426-450`. This is the one small piece of new code the BL side
needs.

---

## 6. Second-order opportunity (recommend in scope; flag if deferred)

The **list-context** consequence layer is still four hand-written binder-list definitions, while
the **set-context** layer was already collapsed by task 507:

| Layer | Status |
|---|---|
| Set (`Set Formula`) | collapsed — `SetConsequenceOnFrames` / `SetSemanticConsequenceOn` at `SetConsequence.lean:91,98`, four names retained as one-line abbreviations, `.of_forall`/`.apply` adapters at `:129–197` |
| List (`Context`) | **not** collapsed — `SemanticConsequence` `Validity.lean:89`, `SemanticConsequenceDense` `StrongCompleteness.lean:729`, `SemanticConsequenceDiscrete` `:839`, `SemanticConsequenceDedekindDense` `:174` |

The same treatment (`ConsequenceOnFrames P Γ φ` / `SemanticConsequenceIn fc Γ φ` plus four
`.of_forall`/`.apply` adapters) makes the four `soundness_*_consequence` theorems one-liners over
`soundness_in`. `SetConsequence.lean:129–197` is the exact template, including the `.Discrete`
adapter's `obtain`-and-`@` idiom (never `haveI`, which breaks definitional equality against
instances baked into `F`'s type).

**Judgment call for the planner**: the four `SemanticConsequence*` docstrings currently justify
themselves as a *guard* — e.g. `StrongCompleteness.lean:521-528`: "it holds *only* because the
definition above reproduces that block verbatim. If a later edit weakens the consequence relation
… this theorem breaks". Collapsing them onto `SemanticConsequenceIn` moves that guard from a
hand-copied binder list to `FrameClass.Sat`, which is strictly better (one source of truth) but
requires rewriting those four docstrings rather than deleting them. Task 507 made exactly this
trade on the Set layer, so there is precedent. If the planner scopes this out, say so explicitly
rather than leaving the asymmetry unremarked.

The review's literal recommended target, `Derivable fc Γ φ → SetSemanticConsequence fc Γ φ`, is
then a further corollary: `SetDerivable fc Γ φ → SetSemanticConsequenceOn fc Γ φ` via
`setDerivable_iff_exists_finite` (`SetConsequence.lean:247`) + `soundness_in` +
`setConsequenceOnFrames_mono` (`:208`). No such theorem exists today; adding it closes H2's stated
form.

---

## 7. Hard constraints re-confirmed against the tree

- **`soundness_dedekind` targets `ValidDedekindDense`, never `ValidDedekind`.** Confirmed at
  `Soundness.lean:2005-2011` and `Semantics/FrameProperty.lean:142-172`: `ValidDedekind` is
  `ValidOnFrames TaskFrame.IsComplete` (the bare Complete clause, which `ℤ` satisfies), whereas
  `Sat .Dedekind = TaskFrame.IsDedekind = IsDense ∧ IsComplete`. `Axiom.density` and
  `Axiom.dense_indicator` are admissible at `.Dedekind` (since `Dense ≤ Dedekind`) and are false on
  `ℤ`, so retargeting is refutable. The verified `soundness_dedekind'` corollary keeps the
  `ValidDedekindDense` binder bundle exactly.
- **`ValidDedekind` cannot become `ValidIn`-anything** and must stay as `ValidOnFrames
  TaskFrame.IsComplete` (`Validity.lean:645`). No `FrameClass` constructor denotes the bare
  Complete class. Its bridge `validDedekindDense_of_validDedekind` (`:813`) also stays.
- **Naming**: the class is `.Dedekind`. `FrameProperty.lean:158-170` records the deviation from the
  paper's "Complete" and why: "complete" is reserved for proof-theoretic completeness.
- **`ValidIn` is frame-level**, not carrier-level, exactly as the brief directs. The verified
  implementation uses `ValidIn fc φ = ∀ F : TaskFrame, fc.Sat F → F.ValidOn φ` throughout. The
  carrier-quantified `SoundnessLemmas.IsValid D` (`Core.lean:42`) is reached only *inside* the leaf
  lemmas, via `F.toFibre` — the same idiom `Soundness.lean:1226` already uses.

---

## 8. Downstream call sites (complete inventory; small blast radius)

Outside the defining modules, only these consume the theorems being collapsed:

| Consumer | Uses |
|---|---|
| `Metalogic/BaseLanguageSoundness.lean:208,222,237,258` | all four `soundness*` |
| `Metalogic/StrongCompleteness.lean:533,784,894` + `:676` body | all four `soundness*` |
| `Metalogic/TMCompletenessReduction.lean:111,149` | `soundness`, `soundness_discrete_valid` |
| `Metalogic/DiscreteNonCompactness.lean:293` | `soundness_discrete` |
| `Metalogic/Z1Countermodel.lean:194` | `soundness_discrete_valid` |
| `Metalogic/Independence/CoNotPriorU.lean:332,557` | `soundness_dense` |
| `Metalogic/Independence/LexIntWitness.lean:182,233` | `axiom_valid`, `axiom_discrete_valid` |
| `Metalogic/Independence/RationalWitness.lean:126,172` | `axiom_dense_valid`, `axiom_dedekind_valid` |
| `Metalogic/Soundness.lean:2073,2100` | `not_derivable_nil_bot{,_discrete}` off `soundness`/`soundness_discrete_valid` |

If the collapsed names are retained as corollaries (recommended), **zero** of these need editing.
`FormalSystem/Boneyard/**` also references `axiom_dense_valid`/`axiom_discrete_valid` but is not
compiled (§2.2).

---

## 9. Baseline and pre-existing gate state

- `lake build`: **green**, exit 0, 2564/2564 modules (run at `2fcc66f4e`).
- `scripts/check-module-invariants.sh`: **FAIL on C6 only** — 4 unreachable live modules absent
  from `scripts/module-invariants-manifest.txt`: `FormalSystem.Metalogic.SpWitness`,
  `FormalSystem.Metalogic.TMCompletenessReduction`, `FormalSystem.Metalogic.Z1Countermodel`,
  `FormalSystem.Semantics.LexCarrier`. Pre-existing, from other tasks, exactly as the brief
  predicted. C14 (axiom baselines) and C15 (47 paper anchors) **pass**.
- `scripts/readme-lint.sh`: **FAIL** — 1 missing README. Confirmed to be
  `FormalSystem/Semantics/Ultraproduct/README.md`. Pre-existing, exactly as the brief predicted.
- No foreign commits or foreign uncommitted modifications to `FormalSystem/` appeared during this
  run. The only working-tree changes are under `specs/`, `.claude-extensions.json`,
  `typst/generated/status.typ`, and two untracked non-source files — all present before this
  dispatch or produced by task-management tooling.

---

## 10. Suggested phase decomposition

Each phase is one agent run, each ends `lake build`-green and committable.

1. **Leaf lemmas** — add `axiom_validIn_min` and `axiom_swap_validIn_min` to `Soundness.lean`
   (after `sep_swap_valid`, `:1763`). Copy verbatim from the reference implementation. Nothing else
   changes; the build must stay green with the old theorems still present.
2. **Uniform recursion + `soundness_in`** — add `axiom_validIn`, `axiom_swap_validIn`,
   `derivable_valid_and_swap_validIn`, `soundness_in`, `soundness_validIn`. Still additive.
3. **Retarget the four `Formula`-side theorems + three `*_valid`** to one-line corollary bodies;
   delete the four `axiom_*_valid` dispatchers, `axiom_dedekind_swap_valid`, and
   `derivable_valid_and_swap_valid_dedekind`. `#print axioms` on all four to confirm the profile is
   unchanged.
4. **Prune `FrameClassVariants.lean` and `DenseValidity.lean`** of the now-dead recursions and
   `axiom_locally_valid_*`; update `SoundnessLemmas/README.md:16`'s line count.
5. **BL side** — add the `BLValidOnFrames`/`BLValidIn` adapters if missing (§5), add
   `bl_soundness_in` / `bl_soundness_validIn`, retarget the eight `bl_soundness*`. Preserve
   `bl_soundness_discrete_succ{,_valid}` untouched.
6. **Consequence layer** (§6) — `SemanticConsequenceIn` + adapters, four
   `soundness_*_consequence` as one-liners, optional `soundness_setConsequence`. Scope-out
   decision to be recorded explicitly if skipped.
7. **Tree-wide acceptance** — full `lake build`, `check-module-invariants.sh`, `readme-lint.sh`,
   `#print axioms` audit, sorry-count check. The two pre-existing failures in §9 must be reported
   as pre-existing, not repaired here.

Phases 1–3 are the load-bearing ones and are already verified to compile.
