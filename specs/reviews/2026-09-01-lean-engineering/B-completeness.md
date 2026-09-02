# Territory B: Completeness, Consequence & Compactness — Findings

## 1. Architecture assessment (≤ 1 page)

The layer is in good shape mathematically and, at the *vocabulary* level, has already been
collapsed onto `FrameClass`-indexed primitives. `Semantics/Validity.lean` owns `ValidOnFrames` →
`ValidIn` → `{valid, ValidDense, ValidDiscrete, ValidDedekindDense}` and `ConsequenceOnFrames` →
`SemanticConsequenceIn` → the four finite-context relations; `Metalogic/SetConsequence.lean` mirrors
this for `Γ : Set Formula` with `SetConsequenceOnFrames` → `SetSemanticConsequenceOn` and the
four-row family `SatisfiableSet` / `ModelExistence` / `Compact` / `StrongCompleteness`. The single
source of truth for "what does class `fc` quantify over" is `FrameClass.Sat`
(`Semantics/FrameClassValidity.lean`), and every predicate in the territory reads it. That is the
right design and it is done.

The unfinished half of the collapse is the **theorems**. Every *definition* is generic; almost no
*proof* is. Four independent `semantic_deduction_*` proofs
(`StrongCompleteness.lean:256, 632, 762, 907`), four byte-identical `soundness_*_consequence` proofs
(`:525, 675, 805, 948`), four `consequence_completeness_*`, four `completeness_*`, two
near-identical ultraproduct model-existence proofs (`Compactness.lean:84, 121`), and four
copies of the non-compactness refutation skeleton (`DiscreteNonCompactness.lean:249, 278`;
`DedekindNonCompactness.lean:431, 459`). Each is a per-class instance of a theorem that is
provable once, generically, in ≤ 6 lines. Roughly 230 lines of proof text in the territory are
mechanical `fc`-instantiations.

The second gap is mathematical rather than mechanical. Three textbook facts are missing as
declarations, and their absence is what forces the duplication above:

* `StrongCompleteness fc → Compact fc` (soundness direction) — absent. Without it, the two
  `strongCompleteness*_refuted` theorems must redo the witness argument instead of composing.
* `Compact fc ↔ ModelExistence fc` — only `→` exists (`compact_of_modelExistence`).
* `WeakCompleteness fc := ∀ ψ, ValidIn fc ψ → Derivable fc [] ψ` — never named, so the engine
  hypothesis is written out longhand at three sites and the four `BXCanonical` engines are not
  visibly one family.

With those three added, "strong completeness = weak completeness + compactness" becomes a single
`iff` and the whole layer reads like a textbook chapter.

Third: **four modules in this territory are outside the build graph** —
`Metalogic/SpWitness.lean`, `Metalogic/TMCompletenessReduction.lean`,
`Metalogic/Z1Countermodel.lean`, `Semantics/LexCarrier.lean` — and none of them is in
`scripts/module-invariants-manifest.txt`, which the C6 rot guard requires. A headline refutation
(`Z1Countermodel.tmCompleteDiscrete_refuted`) is therefore never compiled by `lake build`. This is
the one Critical finding.

Fourth: documentation. `StrongCompleteness.lean` is 69% prose, `Conservativity.lean` 80%, and 45
of those prose lines are refactoring archaeology ("before this collapse there were four
byte-identical definitions", "pre-collapse binder shape"). Six of the sixteen `file.lean:NNN`
citations in the five main files point at the wrong line. The status ledger exists in three
mutually-drifting copies (`Metalogic.lean`, `Metalogic/README.md`, and the module docstrings).

`Core/` is a separate story: it is not consumed by the strong-completeness route at all (the
ultraproduct path bypasses MCS entirely), and it carries the territory's two largest verbatim
duplications — the Zorn/Lindenbaum argument (twice) and the F/P-mirror boundedness lemmas
(byte-identical modulo renaming).

---

## 2. Frame-class duplication table (Q1)

Generic primitive → per-class names. "Abbrev" = per-class name is a one-line `def X := Generic fc`.
"Indep." = independently proved, no generic exists.

| Family | Generic (home) | Base | Dense | Discrete | Dedekind | Status |
|---|---|---|---|---|---|---|
| Validity | `ValidIn` (`Validity.lean:337`) | `valid` :377 | `ValidDense` :534 | `ValidDiscrete` :608 | `ValidDedekindDense` | **Abbrev ✓** |
| Validity adapters | `ValidIn.of_forall_total` :494, `.apply_total` :501, `.of_not` :514 | ×3 | ×3 | ×3 | ×3 | 12 hand-written wrappers |
| Finite-ctx consequence | `SemanticConsequenceIn` (`Validity.lean:92`) | `SemanticConsequence` :120 | `SemanticConsequenceDense` (`SC.lean:734`) | `…Discrete` :873 | `…DedekindDense` :206 | **Abbrev ✓** |
| …its adapters | — | 2 (`Validity.lean:140,147`) | 2 (`SC:739,747`) | 2 (`SC:880,891`) | 2 (`SC:211,220`) | 8 wrappers |
| Set consequence | `SetSemanticConsequenceOn` (`SetC.lean:107`) over `SetConsequenceOnFrames` :100 | :112 | :116 | :121 | :126 | **Abbrev ✓** |
| …its adapters | — | 2 (:222,229) | 2 (:236,244) | 2 (:252,263) | 2 (:272,281) | 8 wrappers; **6 of 8 unused** |
| **Semantic deduction** | **none** | `semantic_deduction_base` :632 | `_dense` :762 | `_discrete` :907 | `_dedekind_dense` :256 | **Indep. ✗ (B-01)** |
| **Consequence completeness** | **none** | `consequence_completeness_base` :658 | `_dense` :787 | `_discrete` :930 | `_dedekind` :568 (+`_of_engine` :504) | **Indep. ✗ (B-03)** |
| **Soundness guard** | **none** (`soundness_in` exists, unused as such) | `soundness_base_consequence` :675 | `_dense_` :805 | `_discrete_` :948 | `_dedekind_` :525 | **Indep., 4 byte-identical bodies ✗ (B-02)** |
| **Weak corollary** | **none** | `completeness_base` :688 | `_dense` :822 | `_discrete` :966 | `_dedekind` :587 | **Indep. ✗ (B-03)** |
| Satisfiability | `SatisfiableSet` (`SetC.lean:154`) | `SatisfiableBaseSet` :469 | `SatisfiableDenseSet` :508 | `SatisfiableDiscreteSet` :562 | `SatisfiableDedekindSet` :625 | **Abbrev ✓** |
| …intro adapters | — | `.base_of_forall` :301 | `.dense_` :307 | `.discrete_` :317 | `.dedekind_` :327 | 4 wrappers, all used |
| Model existence | `ModelExistence` :164 | `ModelExistenceBase` :481 | `…Dense` :520 | — | `…Dedekind` :636 (unused) | **Abbrev ✓** |
| Compactness | `Compact` :175 | `CompactBase` :456 | `CompactDense` :502 | `CompactDiscrete` :569 | `CompactDedekind` :609 | **Abbrev ✓** |
| Strong completeness | `StrongCompleteness` :185 | `StrongCompletenessBase` :449 | `…Dense` :497 | `…Discrete` :542 | `…Dedekind` :601 | **Abbrev ✓** |
| Set-consequence monotonicity | `setConsequenceOnFrames_mono` :346 | :360 | :365 | :370 | :376 | Abbrev ✓ but **all 4 unused** |
| **Model-existence proof** | **none** | `modelExistenceBase` (`Compactness:84`) | `modelExistenceDense` :121 | — | — | **Indep., 2 near-identical ✗ (B-06)** |
| Compactness proof | `compact_of_modelExistence` (`SC:423`) ✓ | `compactBase` :143 | `compactDense` :146 | — | — | ✓ one-liners |
| SC proof | `strongCompleteness_of_compact` (`SC:375`) ✓ | `strongCompletenessBase` :156 | `…Dense` :163 | — | — | ✓ one-liners |
| **Non-compactness refutation** | **none** | — | — | `discrete_consequence_not_compact` :249, `strongCompletenessDiscrete_refuted` :278 | `dedekind_…_not_compact` :431, `strongCompletenessDedekind_refuted` :459 | **Indep. ×4 ✗ (B-04, B-05)** |
| Weak-completeness engine | **none** (shape `ValidIn fc ψ → Derivable fc [] ψ`) | `BXCanonical.completeness` :196 | `…_dense` :255 | `…_discrete` :296 | `completeness_dedekind_engine` (`CompletenessDedekind:591`) | **Unnamed family ✗ (B-10)** |
| Backward conservativity | `derivable_translate` (`Conservativity:281`) ✓ | `ceb_backward` :297 | `ced_backward` :319 | `cef_backward` :309 | `cec_backward` :340 | ✓ one-liners |
| TM-completeness ↔ forward | **none** | `TMCompleteBase`/`ForwardBase` + iff (`TMCR:82,89,104`) | — | `…Discrete` ×3 (:122,129,143) | — | **Indep. ×2 ✗ (B-22)** |

**Which per-class copies can be deleted or become one-liners**: every row marked ✗ above. Concretely
— 4 `semantic_deduction_*` bodies (≈ 44 lines → 4 one-liners), 4 `soundness_*_consequence` bodies
(≈ 12 lines → 4 one-liners or deletion), 4 `consequence_completeness_*` + 4 `completeness_*`
(≈ 30 lines → 8 one-liners), 1 of `modelExistence{Base,Dense}` (≈ 16 lines), and the 4 refutation
skeletons (≈ 44 lines → 4 two-liners). Plus outright deletion of ≈ 110 lines of unused API (B-07).

---

## 3. Findings

### B-01. The semantic deduction theorem is proved four times instead of once

- **Severity**: High
- **Category**: duplication
- **Anchors**: `FormalSystem/Metalogic/StrongCompleteness.lean:256` (`semantic_deduction_dedekind_dense`), `:632` (`semantic_deduction_base`), `:762` (`semantic_deduction_dense`), `:907` (`semantic_deduction_discrete`); `FormalSystem/Semantics/Validity.lean:92` (`SemanticConsequenceIn`), `:337` (`ValidIn`)
- **Description**: All four proofs are the same seven-line `constructor` / `refine …of_forall ?_` /
  `intro F … M τ hτ t` / `exact (truthAt_foldr_imp M τ t Γ φ).mpr (h.apply …)` script. They differ
  only in (a) which per-class `of_forall`/`apply` adapter is named and (b) how many `_` the `intro`
  consumes for the class binders. `truthAt_foldr_imp` (`:238`) is already stated at the bare
  `TaskModel` binder set precisely so that no frame condition enters — its own docstring says so —
  and both `SemanticConsequenceIn fc` and `ValidIn fc` carry the class condition in the *same*
  explicit `fc.Sat F` slot. There is nothing left to vary.
- **Impact**: 44 lines of proof text, four declarations to keep in step, and the adapters exist
  partly to serve these four proofs. A fifth frame class costs a fifth copy.
- **Recommendation**: prove it once, at the primitive, and make the four per-class names one-liners.

  ```lean
  theorem semantic_deduction_in {fc : FrameClass} (Γ : Context) (φ : Formula) :
      SemanticConsequenceIn fc Γ φ ↔ ValidIn fc (Γ.foldr Formula.imp φ) := by
    constructor
    · intro h; exact ValidIn.of_forall_total fun F hF M τ hτ t =>
        (truthAt_foldr_imp M τ t Γ φ).mpr (h F hF M τ hτ t)
    · intro h; exact fun F hF M τ hτ t =>
        (truthAt_foldr_imp M τ t Γ φ).mp (h.apply_total F hF M τ hτ t)

  theorem semantic_deduction_base (Γ φ) : SemanticConsequence Γ φ ↔ valid (Γ.foldr Formula.imp φ) :=
    semantic_deduction_in Γ φ
  -- …and three more, identically
  ```
  (The `of_forall_total`/`apply_total` step is needed only because `ValidOnFrames` goes through the
  bundled `TaskFrame.HF` while `ConsequenceOnFrames` uses the unbundled pair — see
  `Validity.lean:475-504`. That mismatch is itself worth removing, but this finding does not
  require it.)
- **Effort**: S
- **Depends on**: -

### B-02. Four byte-identical soundness guards

- **Severity**: High
- **Category**: duplication
- **Anchors**: `StrongCompleteness.lean:525` (`soundness_dedekind_consequence`), `:675` (`soundness_base_consequence`), `:805` (`soundness_dense_consequence`), `:948` (`soundness_discrete_consequence`); `Metalogic/Soundness.lean:1438` (`soundness_in`)
- **Description**: All four bodies are, character for character:
  ```lean
    intro F hF M τ hτ t h_ctx
    exact h.elim fun d => soundness_in Γ φ d F hF M τ hτ t h_ctx
  ```
  Only the `FrameClass` literal in the statement differs, and each carries a 12-line docstring
  explaining that it is "the guard that keeps the completeness target honest". That guard function
  is now discharged structurally — every one of these docstrings says so itself ("the guard is now
  structural rather than a matter of two binder lists being kept in step",
  `StrongCompleteness.lean:800`). Once the guard is structural, four separate instances of it
  guard nothing four different ways.
- **Impact**: 12 lines of proof plus ≈ 50 lines of near-identical docstring, for a statement that
  is `soundness_in` re-typed.
- **Recommendation**: one generic declaration, four one-line corollaries kept only if downstream
  call sites name them.
  ```lean
  theorem soundness_consequence {fc : FrameClass} (Γ : Context) (φ : Formula)
      (h : Derivable fc Γ φ) : SemanticConsequenceIn fc Γ φ :=
    fun F hF M τ hτ t h_ctx => h.elim fun d => soundness_in Γ φ d F hF M τ hτ t h_ctx
  ```
  Note this is exactly `soundness_setConsequence` (`:1004`) at a finite context; the two should be
  stated as one pair, adjacent.
- **Effort**: S
- **Depends on**: -

### B-03. `consequence_completeness_*` and `completeness_*` are eight instances of two theorems

- **Severity**: Medium
- **Category**: duplication
- **Anchors**: `StrongCompleteness.lean:504` (`consequence_completeness_dedekind_of_engine`), `:543` (`completeness_dedekind_of_engine`), `:568`, `:587`, `:658`, `:688`, `:787`, `:822`, `:930`, `:966`
- **Description**: The Dedekind section already has the right shape — an `_of_engine` layer plus
  an instantiation. The other three classes inline the engine, so the shared structure is invisible.
  Every one of the eight bodies is `(derivable_foldr_imp_iff Γ φ).mpr (engine _ ((semantic_deduction_X Γ φ).mp h))`
  or its `Γ := []` specialisation.
- **Impact**: Ten declarations where two generic ones plus eight one-liners would do; the Dedekind
  section's `_of_engine` layer looks like a special case when it is in fact the general one.
- **Recommendation**: with B-01 and B-10 in hand:
  ```lean
  theorem consequence_completeness_of_engine {fc : FrameClass} (engine : WeakCompleteness fc)
      (Γ : Context) (φ : Formula) (h : SemanticConsequenceIn fc Γ φ) : Derivable fc Γ φ :=
    (derivable_foldr_imp_iff Γ φ).mpr (engine _ ((semantic_deduction_in Γ φ).mp h))

  theorem completeness_of_engine {fc : FrameClass} (engine : WeakCompleteness fc) :
      WeakCompleteness fc := engine   -- i.e. the Γ = [] corollary collapses entirely
  ```
  The last line is the point: once `WeakCompleteness fc` is named, `completeness_base` /
  `_dense` / `_discrete` / `_dedekind` are *definitionally the engines they consume*, and the
  "recorded here so the weak form has exactly one proof in the tree" docstrings (`:538`, `:685`,
  `:815`) become true by type rather than by convention.
- **Effort**: M
- **Depends on**: B-01, B-10

### B-04. `StrongCompleteness fc → Compact fc` is missing, so both refutations re-derive it

- **Severity**: High
- **Category**: math-insight
- **Anchors**: `DiscreteNonCompactness.lean:249` vs `:278`; `DedekindNonCompactness.lean:431` vs `:459`; `StrongCompleteness.lean:375` (`strongCompleteness_of_compact`), `:316` (`derivable_foldr_imp_iff`), `Soundness.lean:1438` (`soundness_in`)
- **Description**: For a finitary proof system with a sound calculus, strong completeness *implies*
  compactness — this is the standard textbook observation and it is entirely generic here. It is
  not stated. Consequently `strongCompletenessDiscrete_refuted` (`:278-290`) repeats the first eight
  lines of `discrete_consequence_not_compact` (`:249-262`) verbatim and then finishes through
  `soundness_discrete` instead of `truthAt_foldr_imp`; the Dedekind pair (`:431-444` / `:459-471`)
  does the same. Four proofs where there should be two plus a composition.
- **Impact**: The single most important structural fact about the layer — that compactness is
  *exactly* the gap between weak and strong completeness — is stated in one direction only
  (`strongCompleteness_of_compact`, whose docstring at `:344` explicitly claims to "record in the
  type that compactness is the whole of the gap"). The converse half of that claim is not in the
  type at all.
- **Recommendation**:
  ```lean
  theorem compact_of_strongCompleteness {fc : FrameClass} (h : StrongCompleteness fc) :
      Compact fc := by
    intro Γ φ hcons
    obtain ⟨L, hL, hd⟩ := h Γ φ hcons
    refine ⟨L, hL, ValidIn.of_forall_total fun F hF M τ hτ t => ?_⟩
    exact ((derivable_foldr_imp_iff L φ).mp hd).elim fun d =>
      soundness_in [] _ d F hF M τ hτ t (by simp)

  /-- **Strong completeness = weak completeness + compactness.** -/
  theorem strongCompleteness_iff_compact {fc : FrameClass} (engine : WeakCompleteness fc) :
      StrongCompleteness fc ↔ Compact fc :=
    ⟨compact_of_strongCompleteness, fun hc => strongCompleteness_of_compact hc engine⟩
  ```
  Then `strongCompletenessDiscrete_refuted := fun h => discrete_consequence_not_compact
  (compact_of_strongCompleteness h)` and likewise for Dedekind — two lines each, and the
  soundness argument lives in one place.
- **Effort**: S
- **Depends on**: B-10 (for the `iff` form only)

### B-05. No shared non-compactness witness skeleton

- **Severity**: High
- **Category**: abstraction
- **Anchors**: `DiscreteNonCompactness.lean:249-262`, `:278-290`; `DedekindNonCompactness.lean:431-444`, `:459-471`
- **Description**: All four refutations execute the identical five-step script: (1) `set` an atom;
  (2) build `hcons : SetSemanticConsequence… W ⊥` from `¬ Satisfiable W` via the class `.of_forall`
  adapter and `absurd`; (3) apply the compactness/strong-completeness hypothesis to get a finite
  `L`; (4) apply `*_finitely_satisfiable` to get a model of `L`; (5) contradict via
  `truthAt_foldr_imp` or `soundness_*`. Step (2) alone is a five-line block written out four times.
  The two files' module docstrings both say only "the *file shape* … carries over"
  (`DedekindNonCompactness.lean:31-32`) — but in fact the entire *proof* shape carries over; only
  the two witness lemmas differ.
- **Impact**: 44 lines of duplicated proof; a third non-compactness result would cost a third copy;
  and the shared step (2) — "an unsatisfiable set is a vacuous consequence of anything" — is a
  general fact about the semantics that is nowhere named.
- **Recommendation**: two generic lemmas in `SetConsequence.lean` (step 2) and
  `StrongCompleteness.lean` (the skeleton):
  ```lean
  /-- An unsatisfiable premise set entails anything, vacuously. -/
  theorem setConsequence_of_not_satisfiable {fc : FrameClass} {Γ : Set Formula} {φ : Formula}
      (h : ¬ SatisfiableSet fc Γ) : SetSemanticConsequenceOn fc Γ φ :=
    fun F hF M τ hτ t hall => absurd ⟨F, hF, M, τ, hτ, t, hall⟩ h

  /-- **Non-compactness from a finitely-satisfiable-but-unsatisfiable witness.** -/
  theorem not_compact_of_witness {fc : FrameClass} {W : Set Formula}
      (hfin : ∀ L : List Formula, (∀ ψ ∈ L, ψ ∈ W) → SatisfiableSet fc {ψ | ψ ∈ L})
      (hunsat : ¬ SatisfiableSet fc W) : ¬ Compact fc := by
    intro hc
    obtain ⟨L, hL, hvalid⟩ := hc W Formula.bot (setConsequence_of_not_satisfiable hunsat)
    obtain ⟨F, hF, M, τ, hτ, t, hsat⟩ := hfin L hL
    exact (truthAt_foldr_imp M τ t L Formula.bot).mp (hvalid.apply_total F hF M τ hτ t) hsat

  theorem not_strongCompleteness_of_witness {fc : FrameClass} {W : Set Formula}
      (hfin : …) (hunsat : …) : ¬ StrongCompleteness fc :=
    fun h => not_compact_of_witness hfin hunsat (compact_of_strongCompleteness h)
  ```
  Note that the generic form needs **no class adapter at all** — `SatisfiableSet` and
  `SetSemanticConsequenceOn` both carry `fc.Sat F` as an explicit slot, exactly as
  `compact_of_modelExistence`'s docstring already observes for its own case
  (`StrongCompleteness.lean:400-405`). Each of the four refutations then becomes one line.
- **Effort**: M
- **Depends on**: B-04

### B-06. `modelExistenceBase` and `modelExistenceDense` differ only by a typeclass that already exists

- **Severity**: High
- **Category**: abstraction
- **Anchors**: `Compactness.lean:84-99` vs `:121-138`; `Semantics/Ultraproduct/Carrier.lean:182` (`instance [∀ i, DenselyOrdered (D i)] : DenselyOrdered (UD φ D)`); `Ultraproduct/Los.lean:154`, `Ultraproduct/IndexFilter.lean:54,85,89`
- **Description**: The two proofs are line-for-line identical apart from three tokens: `choose`
  extracts one extra component (`hd`), a `haveI` reinstalls it, and the second tuple slot is
  `trivial` versus a type-ascribed `inferInstance`. The final seven lines
  (`intro ψ hψ` … `ShiftSet.reverse_repr …`) are byte-identical. The ultraproduct layer beneath is
  fully generic — `Idx` is over any `Set α`, `los`/`los_truthAt` over any index type and any
  ultrafilter — so the specialisation is entirely in this file. Crucially, the *only* mathematical
  content that differs is "the ultraproduct of dense orders is dense", and that is already isolated
  as an instance at `Carrier.lean:182`.
- **Impact**: 16 duplicated lines, and — more importantly — the *reason* compactness holds for Base
  and Dense but fails for Discrete and Dedekind is invisible. It is exactly that `fc.Sat` is
  preserved by ultraproducts for the first two and not the last two (ultraproducts of Archimedean
  orders need not be Archimedean; of Dedekind-complete orders need not be complete). Stating that
  hypothesis turns four scattered results into one theorem with four instantiations, two positive
  and two negative.
- **Recommendation**:
  ```lean
  /-- Model existence at any frame class whose defining condition survives an ultraproduct. -/
  theorem modelExistence_of_satPreserved {fc : FrameClass}
      (hpres : ∀ {I : Type} (u : Ultrafilter I) (T : I → TemporalOrder) (S : ∀ i, ShiftSet (T i)),
                 (∀ i, fc.Sat (S i).frame) → fc.Sat (uShiftSet u S).frame) :
      ModelExistence fc

  theorem modelExistenceBase  : ModelExistenceBase  := modelExistence_of_satPreserved (by …trivial)
  theorem modelExistenceDense : ModelExistenceDense := modelExistence_of_satPreserved (by …inferInstance)
  ```
  and add a docstring on `modelExistence_of_satPreserved` recording that `hpres` is *false* at
  `.Discrete` and `.Dedekind` — with `discrete_consequence_not_compact` /
  `dedekind_consequence_not_compact` cited as the machine-checked proof that no route around it
  exists. That single docstring replaces the status prose currently spread over four modules.
- **Effort**: M
- **Depends on**: -

### B-07. ≈ 110 lines of `SetConsequence.lean` have no consumer anywhere in the tree

- **Severity**: Medium
- **Category**: organization
- **Anchors**: `SetConsequence.lean:222` (`SetSemanticConsequenceBase.of_forall`), `:229` (`.apply`), `:244` (`SetSemanticConsequenceDense.apply`), `:263` (`…Discrete.apply`), `:281` (`…DedekindDense.apply`), `:338` (`setDerivable_mono`), `:346`+`:360`,`:365`,`:370`,`:376` (the four `*_mono` corollaries), `:354` (`setSemanticConsequenceOn_mono_fc`), `:385` (`setDerivable_iff_exists_finite` — used once, inside `soundness_setConsequence`), `:390` (`setDerivable_of_derivable`), `:400` (`derivable_of_setDerivable_contextToSet`), `:408` (`setDerivable_of_mem`), `:418` (`not_setConsistent_of_setDerivable_bot`); `StrongCompleteness.lean:1004` (`soundness_setConsequence`, itself unused)
- **Description**: A repo-wide grep for each of these names, excluding the defining file and
  Boneyards, returns nothing but docstring prose. Fifteen declarations. Two of them
  (`setDerivable_of_derivable`, `not_setConsistent_of_setDerivable_bot`) are the *only* reason
  `SetConsequence.lean:11` imports `Core.MaximalConsistent` — a 538-line module with its own
  transitive closure — for the sake of a one-line `def contextToSet` and one `def SetConsistent`.
  `SetSemanticConsequenceBase` and `SetSemanticConsequenceDense` themselves have no call sites at
  all outside their own definitions; only the Discrete and Dedekind relations are consumed (by the
  refutations).
- **Impact**: A "vocabulary only" module carrying 15 dead declarations, an unnecessary heavyweight
  import, and — for doc-gen — a public API surface twice the size of what is actually used.
- **Recommendation**: delete the four `*_mono` corollaries and `setSemanticConsequenceOn_mono_fc`
  (keeping `setConsequenceOnFrames_mono`, which `soundness_setConsequence` uses); delete the six
  unused `.of_forall`/`.apply` adapters, restoring any on demand; move `setDerivable_of_derivable`,
  `derivable_of_setDerivable_contextToSet` and `not_setConsistent_of_setDerivable_bot` to whichever
  module first needs them, and drop the `Core.MaximalConsistent` import with them. Keep
  `soundness_setConsequence` — B-02 will make it load-bearing.
- **Effort**: S
- **Depends on**: -

### B-08. Four territory modules are outside the build graph and absent from the C6 rot-guard manifest

- **Severity**: Critical
- **Category**: organization
- **Anchors**: `FormalSystem/Metalogic/SpWitness.lean`, `FormalSystem/Metalogic/TMCompletenessReduction.lean`, `FormalSystem/Metalogic/Z1Countermodel.lean`, `FormalSystem/Semantics/LexCarrier.lean`; `scripts/module-invariants-manifest.txt`; `scripts/check-module-invariants.sh:14` (C6), `:355-357`; `lakefile.lean` (`lean_lib FormalSystem` with `roots := #[\`FormalSystem]`, no globs); `FormalSystem/Metalogic.lean:8-19` (import list)
- **Description**: A reachability walk from `FormalSystem.FormalSystem` over the live tree (434
  modules, 403 reachable) leaves these four unreachable. `SpWitness` and `Z1Countermodel` have
  **zero** importers anywhere in `FormalSystem/` or `Tests/`; `TMCompletenessReduction` is imported
  only by `Z1Countermodel`; `LexCarrier` only by `Z1Countermodel`. `Metalogic.lean` does not import
  any of the three Metalogic ones. `lake build` therefore never compiles them — corroborated by the
  build artifacts: `SpWitness.olean` is timestamped `Sep 1 10:37` and
  `Z1Countermodel.olean`/`TMCompletenessReduction.olean` `12:31`, while every other module in
  `Metalogic/` carries `17:54`.

  `scripts/module-invariants-manifest.txt` — whose header states "C6 FAILS if an unreachable live
  module is missing from this file" — lists none of the four.
- **Impact**: `Z1Countermodel.tmCompleteDiscrete_refuted` (`:199`) is a headline result: it
  machine-refutes `TMCompleteDiscrete`, hence (via `tmCompleteDiscrete_iff_forwardDiscrete`) the
  CEF row of the forward-conservativity table. `Conservativity.lean:159-166` and `:78-79` cite it
  as closing CEF "with both halves machine-checked". That claim currently rests on an `.olean`
  produced by an ad-hoc invocation hours before the rest of the tree was rebuilt, guarded by
  nothing. Any breaking change upstream (e.g. to `BaseLanguageSoundness` or `Algebraic/FlowFrame`)
  silently invalidates it. Either C6 is currently failing or it has not been re-run since these
  modules landed.
- **Recommendation**: wire them in. Add `import FormalSystem.Metalogic.Z1Countermodel` and
  `import FormalSystem.Metalogic.SpWitness` to `FormalSystem/Metalogic.lean` (or, per B-21, to a
  new `Metalogic/Conservativity.lean` aggregator) — that pulls `TMCompletenessReduction` and
  `LexCarrier` in transitively and removes the need for any manifest entry. Then re-run
  `bash scripts/check-module-invariants.sh` and confirm C6 passes. If wiring is deferred for an
  independent reason, add all four to the manifest in the same commit.
- **Effort**: S
- **Depends on**: -

### B-09. Compactness is not stated as an equivalence; `Compact fc ↔ ModelExistence fc` is half-present

- **Severity**: Medium
- **Category**: math-insight
- **Anchors**: `StrongCompleteness.lean:423` (`compact_of_modelExistence`); `SetConsequence.lean:164` (`ModelExistence`), `:175` (`Compact`), `:627-636` (`ModelExistenceDedekind` docstring)
- **Description**: Only `ModelExistence fc → Compact fc` exists. The converse is equally routine
  (given `Compact fc` and a finitely satisfiable `Γ`, `Γ ⊭ ⊥`, so some model of `Γ` exists) and
  its absence has a visible cost: the `ModelExistenceDedekind` docstring (`:627-636`) has to say in
  prose that "`ModelExistenceDedekind` is refutable as an immediate corollary. That corollary is
  simply not drawn here." With the `iff` in place it would be drawn by `rfl`-level composition, and
  the Dedekind row of the family would be as complete as the others.
- **Impact**: The classical presentation "compactness ⟺ model existence ⟺ (with weak completeness)
  strong completeness" is spread across three one-directional implications and a paragraph of
  prose. A reader cannot see the chain from the declarations.
- **Recommendation**: add `modelExistence_of_compact` and package:
  ```lean
  theorem compact_iff_modelExistence {fc : FrameClass} : Compact fc ↔ ModelExistence fc
  ```
  then draw the Dedekind corollary (`¬ ModelExistenceDedekind`) and delete the paragraph.
  Together with B-04's `strongCompleteness_iff_compact`, the whole layer becomes a two-line chain.
- **Effort**: M
- **Depends on**: -

### B-10. The weak-completeness engine shape is never named

- **Severity**: Medium
- **Category**: api-ergonomics
- **Anchors**: `StrongCompleteness.lean:376` (`engine : ∀ ψ, ValidIn fc ψ → Derivable fc [] ψ`), `:505`, `:544`; `BXCanonical/Completeness.lean:196`, `:255`, `:296`; `BXCanonical/CompletenessDedekind.lean:591`
- **Description**: The four `BXCanonical` engines all have the shape
  `ValidIn fc ψ → Derivable fc [] ψ` (since `valid = ValidIn .Base`, `ValidDense = ValidIn .Dense`,
  etc. — `Validity.lean:377,534,608`). The shape is written out longhand at three hypothesis sites
  in `StrongCompleteness.lean` and nowhere named. The module docstring devotes a paragraph
  (`:43-46`) to "the engine contract … stated once, here, because it is easy to get backwards" —
  which is precisely what a `def` fixes.
- **Impact**: The four engines are not visibly one family; the engine hypothesis cannot be
  discharged uniformly; and the Q2 question "should there be a `CompletenessEngine fc` structure
  bundling weak completeness + soundness?" answers itself in the negative only because soundness is
  *already* generic (`soundness_in`) — but that is not discoverable from the types.
- **Recommendation**: a one-line `def` in `SetConsequence.lean`, beside `StrongCompleteness`:
  ```lean
  /-- **Weak completeness at `fc`** — the single-formula engine contract. -/
  def WeakCompleteness (fc : FrameClass) : Prop := ∀ ψ : Formula, ValidIn fc ψ → Derivable fc [] ψ
  ```
  No structure is needed: soundness is already `fc`-generic, so bundling it would add a field that
  is always `soundness_in`. Re-type the three `engine` hypotheses against it, and state the four
  `BXCanonical` engines' corollaries as `WeakCompleteness .Base` etc.
- **Effort**: S
- **Depends on**: -

### B-11. `restricted_lindenbaum` re-proves `set_lindenbaum`'s Zorn argument

- **Severity**: Medium
- **Category**: duplication
- **Anchors**: `Core/MaximalConsistent.lean:286` (`ConsistentSupersets`), `:292`, `:264` (`consistent_chain_union`), `:303` (`set_lindenbaum`, 50-line proof); `Core/RestrictedMCS/Basic.lean:274` (`RestrictedConsistentSupersets`), `:281`, `:289`, `:316` (`restricted_lindenbaum`, 59-line proof)
- **Description**: Comparing `MaximalConsistent.lean:305-352` against `RestrictedMCS/Basic.lean:319-374`:
  the `have hchain : ∀ C ⊆ CS, IsChain … → C.Nonempty → ∃ ub ∈ CS, …` block, the `use ⋃₀ C`, the
  `obtain ⟨T, hT⟩ := hCne; Set.Subset.trans hST (Set.subset_sUnion_of_mem hT)` step, the
  `zorn_subset_nonempty` application, and the maximality-to-`insert` argument are the same lines in
  the same order, with `SetConsistent` replaced by `RestrictedConsistent phi` throughout. The only
  genuine difference is a four-line closure-preservation obligation on the `insert` branch
  (`:361-365`) and the quantifier `∀ psi ∈ closureWithNeg phi` in place of `∀ φ`.
- **Impact**: ≈ 110 lines carrying one mathematical idea; the *actual* content of
  `restricted_lindenbaum` (that the restriction is preserved) is four of those lines and is buried.
- **Recommendation**: one Zorn lemma over an arbitrary chain-closed predicate, in
  `Core/MaximalConsistent.lean`:
  ```lean
  theorem exists_maximal_of_chainClosed {P : Set Formula → Prop} {A : Set Formula}
      (hchain : ∀ C : Set (Set Formula), (∀ T ∈ C, P T) → IsChain (· ⊆ ·) C → C.Nonempty → P (⋃₀ C))
      (S : Set Formula) (hS : P S) :
      ∃ M, S ⊆ M ∧ P M ∧ ∀ ψ ∈ A, ψ ∉ M → ¬ P (insert ψ M)
  ```
  `set_lindenbaum` is this at `P := SetConsistent`, `A := Set.univ`;
  `restricted_lindenbaum` at `P := RestrictedConsistent phi`, `A := closureWithNeg phi`, with the
  closure-preservation step supplied as the four lines it genuinely is.
- **Effort**: M
- **Depends on**: -

### B-12. `restricted_mcs_F_bounded` and `restricted_mcs_P_bounded` are byte-identical modulo renaming

- **Severity**: High
- **Category**: duplication
- **Anchors**: `Core/RestrictedMCS/Basic.lean:469` (`restricted_mcs_iter_F_bound`), `:488` (`restricted_mcs_F_bounded`), `:573` (`restricted_mcs_iter_P_bound`), `:593` (`restricted_mcs_P_bounded`)
- **Description**: Applying the substitution `iterF↔iterP`, `closureFBound↔closurePBound`,
  `someFuture↔somePast`, `_F_↔_P_` to lines 488-564 and 593-664 and diffing yields a **single**
  differing line — a comment (`-- First, show ITER 1 phi = F(phi) ∈ M` vs `… = P(phi) ∈ M`). The
  two 8-line `iter_*_bound` lemmas are likewise identical modulo the same substitution. This is
  ≈ 155 lines of proof carrying one argument. The `P_bounded` docstring even says "Symmetric to
  restricted_mcs_F_bounded" (`:588`) without acting on it.
- **Impact**: The largest verbatim duplication in the territory. Any change to the boundedness
  argument must be made twice, and a divergence between the copies would be invisible.
- **Recommendation**: abstract over the iteration family. The proof uses only: an iterator
  `it : ℕ → Formula → Formula`, a bound `b : Formula → ℕ`, an escape lemma
  `it (b φ) φ ∉ closureWithNeg φ`, and a base equation `it 1 φ = op φ`.
  ```lean
  theorem restricted_mcs_iter_bounded {it : ℕ → Formula → Formula} {b : Formula → ℕ}
      {op : Formula → Formula}
      (hescape : ∀ φ, it (b φ) φ ∉ (closureWithNeg φ : Set Formula))
      (hone : ∀ φ, it 1 φ = op φ)
      (phi : Formula) (M : Set Formula) (h_mcs : RestrictedMCS phi M fc) (h_in : op phi ∈ M) :
      ∃ d : Nat, d ≥ 1 ∧ it d phi ∈ M ∧ it (d + 1) phi ∉ M
  ```
  `restricted_mcs_F_bounded` and `_P_bounded` become one-line instantiations; both `iter_*_bound`
  lemmas fold into `hescape`.
- **Effort**: M
- **Depends on**: -

### B-13. `truth_and_iff` exists in three places and is missing from where it belongs

- **Severity**: Medium
- **Category**: organization
- **Anchors**: `DedekindNonCompactness.lean:158` (`truth_and_iff'`, with an explicit "local copy is kept deliberately" comment at `:154-157`); `Semantics/Correspondence/DurationFrames.lean:298` (`truth_and_iff`); `Semantics/BLTruth.lean:145` (the BL analogue); `Semantics/Truth.lean:249,266,283,301,320,334` (the `@[simp]` characterization block that has no `and`/`or`/`neg` entry)
- **Description**: `Semantics/Truth.lean` carries a deliberate namespace of `@[simp]`
  characterization lemmas — `some_future_iff`, `some_past_iff`, `future_iff`, `past_iff`,
  `strong_release_iff`, `strong_trigger_iff` — and its own module docstring (`:82`, `:122`)
  advertises them as the API. `and` is absent. The lemma was consequently first written far
  downstream in `Correspondence/DurationFrames.lean`, and `DedekindNonCompactness.lean` then made a
  third copy rather than widen its import closure "for three lines". The same file's docstring
  (`:39-49`) records that `truthAt_next_iff` / `truthAt_next_iterate`
  (`DiscreteNonCompactness.lean:65`, `:79`) are in the identical position — "their natural eventual
  home is the `Truth` namespace … kept here for now because `Truth.lean` sits near the root".
- **Impact**: Three copies of a two-line fact; two non-compactness modules each carrying semantics
  lemmas that belong upstream; a `Truth` API whose advertised completeness is not real.
- **Recommendation**: promote `Truth.and_iff` (and its `or`/`neg` siblings if they arise) into
  `Semantics/Truth.lean` beside `future_iff`, delete `truth_and_iff'` and re-point
  `DurationFrames.lean`'s nine use sites. Promote `truthAt_next_iff`/`truthAt_next_iterate` in the
  same pass — the "one consumer" argument no longer holds once B-05's generic skeleton makes the
  witness lemmas the only class-specific content. Keep them non-`@[simp]` as
  `DiscreteNonCompactness.lean:48-49` requires.
- **Effort**: S
- **Depends on**: -

### B-14. The four-row status ledger exists in three drifting copies, and they now disagree

- **Severity**: High
- **Category**: documentation
- **Anchors**: `FormalSystem/Metalogic.lean:37-149` (the ledger), `FormalSystem/Metalogic/README.md:142-151` (the file table), and the module docstrings of `StrongCompleteness.lean:16-168`, `SetConsequence.lean:13-69`, `Compactness.lean:11-69`, `DiscreteNonCompactness.lean:9-50`, `DedekindNonCompactness.lean:10-94`, `Conservativity.lean:9-231`
- **Description**: The same four-row proved/refuted table is restated at least six times. It has
  already drifted:
  * `Metalogic.lean:45-47` says the conservativity refutation's remaining prerequisites are that
    "the two countermodels remain outstanding". `Conservativity.lean:159-166` says the CEF
    countermodel is "**now landed**" and the row is "machine-checked, not merely documented", via
    `Z1Countermodel.lean`. `Metalogic.lean` does not mention `Z1Countermodel` at all, nor
    `tmCompleteDiscrete_refuted`.
  * `Metalogic.lean:110-113` contains an editing artifact — "obtained by instantiating the
    reductions / the single `FrameClass`-generic reduction `strongCompleteness_of_compact` with …" —
    a dangling fragment from a partial rewrite.
  * `Metalogic/README.md` line counts are stale: `StrongCompleteness.lean` listed as 1,002 (actual
    1025), `Compactness.lean` as 179 (actual 181), `Z1Countermodel.lean` as 194 (actual 202).
- **Impact**: A reader cannot tell which copy is authoritative, and at least one copy is now wrong
  about a headline result. For publication this is the highest-risk documentation defect in the
  territory.
- **Recommendation**: adopt a single-source-of-truth policy — **the ledger lives in
  `FormalSystem/Metalogic.lean` and nowhere else**. Module docstrings state what *their own module*
  proves and link by declaration name; they must not restate the status of other classes or other
  modules. `Metalogic/README.md`'s file table should carry a one-line purpose only, with line counts
  either dropped or generated by `scripts/readme-inventory.sh`. Add a C-check asserting that the
  strings "proved"/"refuted" adjacent to a class name appear in `Metalogic.lean` only (the existing
  C14 tripwire mechanism at `check-module-invariants.sh:703` is the right vehicle). Fix the
  `Metalogic.lean:45-47` staleness and the `:110-113` fragment in the same pass.
- **Effort**: M
- **Depends on**: -

### B-15. Line-number citations in docstrings: 6 of 16 in the main files are wrong

- **Severity**: Medium
- **Category**: documentation
- **Anchors**: verified individually —
  * `SetConsequence.lean:54` cites `StrongCompleteness.lean:129` for `SemanticConsequenceDedekindDense` — actual `:206`
  * `SetConsequence.lean:505` cites `Validity.lean:190` for `FormulaSatisfiable` — actual `:203`
  * `SetConsequence.lean:494` cites `ProofSystem/Axioms.lean:519` for `FrameClass` — actual `:531`
  * `StrongCompleteness.lean:366` cites `Algebraic/FlowFrame.lean:791` for `bundleFlow_completeness_from_neg_membership` — actual `:803`
  * `StrongCompleteness.lean:713` cites `Soundness.lean:1254` for `soundness_dense` — actual `:1582`
  * `StrongCompleteness.lean:857` cites `Soundness.lean:1400` for `soundness_discrete` — actual `:1619`

  Correct at time of review: `Derivable.lean:69`/`:147`, `Derivation.lean:105`,
  `MaximalConsistent.lean:96`/`:123`, `BXCanonical/Completeness.lean:196`/`:255`/`:296`,
  `ShiftSet.lean:226`/`:245`/`:261-265`/`:278`.
- **Description**: `SetConsequence.lean:88-92` already diagnoses this exact failure mode — "each
  carrying a hand-maintained binder list plus a docstring citing the `Semantics/Validity.lean` line
  its list was copied from. Three of those four line citations had since gone stale" — and then the
  replacement docstrings reintroduce six more.
- **Impact**: A 38% error rate on the citations a reader would use to navigate. Every one of them
  points a doc-gen reader at an unrelated line.
- **Recommendation**: a standing convention — **cite declaration names, never `file:line`**. Lean's
  doc-gen hyperlinks backtick-quoted declaration names automatically, so `` `soundness_dense`
  (`Metalogic/Soundness.lean`) `` is strictly better than a line number *and* cannot rot. A grep
  lint (`grep -n '\.lean:[0-9]' FormalSystem/**/*.lean`) added to
  `scripts/check-module-invariants.sh` would enforce it in one line; there are 16 occurrences in
  the five main files to clean up.
- **Effort**: S
- **Depends on**: -

### B-16. Refactoring archaeology in publication-facing docstrings

- **Severity**: Medium
- **Category**: documentation
- **Anchors**: 45 occurrences of "before the collapse" / "pre-collapse" / "pre-abbreviation" / "used to" / "no longer" — 20 in `StrongCompleteness.lean`, 25 in `SetConsequence.lean`. Representative: `SetConsequence.lean:88-96` ("before this collapse there were four byte-identical definitions here … Three of those four line citations had since gone stale"), `:189-211` ("### What the per-class recoveries cost"), `:213-219`, `StrongCompleteness.lean:196-204` ("Where the binder guard now lives"), `:334-337`, `:407-409`, `:107-110` ("The third status this section used to record … is superseded, not softened")
- **Description**: Comment density is 69% in `StrongCompleteness.lean` (708 of 1025 lines), 62% in
  `SetConsequence.lean`, 80% in `Conservativity.lean`. A substantial fraction is not documenting
  the mathematics but narrating a refactor: what the code used to look like, why a binder moved,
  which of two former copies survived. `StrongCompleteness.lean` has 317 lines of Lean under 708
  lines of prose.
- **Impact**: doc-gen output will show future readers "before this collapse there were four
  byte-identical definitions here" about code they have never seen. It also actively obscures the
  mathematics: the module's genuinely interesting docstrings (`:344-373`, on why the chronicle
  machinery structurally cannot reach `CompactBase`) are buried among them.
- **Recommendation**: two-tier policy. **Docstrings state what a declaration means and why it is
  stated that way**; anything of the form "this used to be X" belongs in the commit message or a
  `docs/` design note, not in `/--`. Concretely: delete the "### What the per-class recoveries cost"
  and "### Binder-shape adapters" narrative sections
  (`SetConsequence.lean:189-219`, ≈ 30 lines), the "Where the binder guard now lives" paragraphs
  (three copies, `StrongCompleteness.lean:196-204`, `:728-732`, `:865-871`), and the
  "Before the collapse this was two proofs identical apart from the class tag" notes (`:334-337`,
  `:407-409`). Keep every paragraph that explains a *mathematical* or *elaboration* constraint —
  the `TaskFrame.IsDense`-is-invisible-to-instance-search notes (`Compactness.lean:111-119`) and
  the `haveI`-breaks-defeq warnings (`SetConsequence.lean:558-561`) are exactly right and should
  stay.
- **Effort**: M
- **Depends on**: B-14

### B-17. Stale prose inside `Conservativity.lean` contradicts its own module docstring

- **Severity**: Medium
- **Category**: documentation
- **Anchors**: `Conservativity.lean:347-349` and `:354-357` versus `:70-79` and `:159-166`
- **Description**: The section header at `:347-349` says the CEF witness "says nothing about
  `TM_f ⊢ Z1`, which is the half that fails and which needs a BL-side soundness theorem to
  establish", and the `Z1` docstring at `:354-357` says it "is not a `TM_f` theorem, the latter by
  soundness over `ℤ ×_lex ℤ` — an argument this repository cannot yet formalize". Both are
  superseded by the same file's module docstring: `:70-79` states the countermodel is over
  **`ℚ ×_lex ℤ`**, explicitly "**not** `ℤ ×_lex ℤ` as an earlier draft of this section … suggested",
  and `:159-166` states the argument is "**now landed**" as
  `Z1Countermodel.not_bl_derivable_z1`. So the file names the wrong carrier and denies its own
  result, in two places, ten lines apart from the correction.
- **Impact**: A reader reaching `def Z1` — the natural entry point — is told the refutation is
  impossible, when it is proved two modules away.
- **Recommendation**: rewrite `:347-349` and `:354-357` to point at
  `Z1Countermodel.not_bl_derivable_z1` and `Z1Countermodel.tmCompleteDiscrete_refuted`. Fold
  together with B-14's ledger consolidation, since the `Metalogic.lean` copy of this claim is stale
  in the same direction.
- **Effort**: S
- **Depends on**: B-14

### B-18. Naming incoherence across the compactness family

- **Severity**: Medium
- **Category**: naming
- **Anchors**: `Compactness.lean:143` (`compactBase`), `:146` (`compactDense`), `:156` (`strongCompletenessBase`) versus `DiscreteNonCompactness.lean:249` (`discrete_consequence_not_compact`), `:278` (`strongCompletenessDiscrete_refuted`), `DedekindNonCompactness.lean:431` (`dedekind_consequence_not_compact`), `:459` (`strongCompletenessDedekind_refuted`)
- **Description**: The same family of results uses three naming schemes. Positive results are
  lowerCamelCase mirroring the `Prop` they inhabit (`compactBase : CompactBase`). Negative
  compactness results are snake_case with the class *first* and a different word order
  (`discrete_consequence_not_compact : ¬ CompactDiscrete`). Negative strong-completeness results
  are lowerCamelCase with a snake_case suffix (`strongCompletenessDiscrete_refuted`). Reading the
  four-row table off the declaration names is impossible.
- **Impact**: A reader looking for "is Dedekind compact?" must know to search three different
  spellings. Mathlib convention would put the `Prop` name first in all four cases.
- **Recommendation**: settle on `not_<PropName>` for refutations, mirroring the positive form:
  `notCompactDiscrete`, `notStrongCompletenessDiscrete`, `notCompactDedekind`,
  `notStrongCompletenessDedekind` (or, in Mathlib snake style throughout,
  `compact_base` / `not_compact_discrete`). Keep the current names as deprecated aliases if
  downstream cites them — a grep shows the only external citations are docstring prose, so a
  straight rename is safe.
- **Effort**: S
- **Depends on**: -

### B-19. The BL-vs-TM group has no directory and no aggregator, against the stated convention

- **Severity**: Medium
- **Category**: organization
- **Anchors**: `FormalSystem/Metalogic.lean:226` ("Every subdirectory carries exactly one sibling aggregator `X.lean` beside `X/`"); `Metalogic/Conservativity.lean` (382), `Metalogic/TMCompletenessReduction.lean` (155), `Metalogic/SpWitness.lean` (128), `Metalogic/Z1Countermodel.lean` (202), `Metalogic/BaseLanguageSoundness.lean` (506)
- **Description**: Five loose top-level files form one coherent story — the backward bridge, its
  soundness composition, the forward prohibition, and the two row witnesses — with mutual
  cross-references in every docstring and a clearly intended reading order
  (`TMCompletenessReduction.lean:13` opens "**Read `Metalogic/Conservativity.lean`'s module
  docstring first**"). There is no entry point, no aggregator, and — per B-08 — three of the five
  are not even in the build graph. Every other multi-file group in `Metalogic/` (Core, Bundle,
  Algebraic, BXCanonical, WeakCanonical, Decidability, SoundnessLemmas) is a directory with a
  sibling aggregator.
- **Impact**: The reading order exists only in prose; the group is the one place in `Metalogic/`
  where the stated convention is not followed; and its absence from the aggregator hierarchy is
  what let B-08 happen.
- **Recommendation**: create `Metalogic/Conservativity/` containing `Backward.lean` (today's
  `Conservativity.lean` body), `TMCompletenessReduction.lean`, `SpWitness.lean`,
  `Z1Countermodel.lean` and `BaseLanguageSoundness.lean`, with a sibling
  `Metalogic/Conservativity.lean` aggregator carrying the module docstring's narrative — which is
  what 231 of its current 382 lines already are. Import the aggregator from `Metalogic.lean`. This
  discharges B-08 as a side effect and gives the prohibition prose a single home.
- **Effort**: M
- **Depends on**: B-08

### B-20. `dedWitness_core` is a 51-line proof mixing four separate arguments

- **Severity**: Medium
- **Category**: proof-elegance
- **Anchors**: `DedekindNonCompactness.lean:215-264`
- **Description**: The single longest proof in the non-Core part of the territory. It interleaves:
  (i) a *successor* lemma — `qAlpha q (n+1)` at `a` yields the next `q`-point `s` satisfying every
  `qAlpha q n`, via the `lt_trichotomy` uniqueness step `hss` (`:222-238`, 17 lines); (ii) an
  iterate/`Exists.choose` chain construction over the invariant subtype (`:239-247`); (iii) the
  boundedness and least-upper-bound extraction (`:251-257`); (iv) the gap contradiction
  (`:258-264`). Step (i) is a self-contained fact about `qNext` and step (ii) a generic
  "strictly-increasing chain from a step function" construction that has nothing to do with the
  logic.
- **Impact**: The interesting mathematics — that *the invariant "satisfies every `αₙ`" propagates*
  — is a `have step :` buried mid-proof and is not citable. The `lt_trichotomy` uniqueness step,
  which is where `qNext`'s `q ∧ _` conjunct earns its keep (the module docstring makes much of this
  at `:56-58`), is invisible from outside.
- **Recommendation**: extract two lemmas.
  ```lean
  /-- The next `q`-point after a point satisfying every `αₙ` again satisfies every `αₙ`. -/
  theorem qAlpha_step (q : Atom) (M : TaskModel F) (τ : WorldHistory F) (a : F.Duration)
      (ha : ∀ n, TruthAt M τ a (qAlpha q n)) :
      ∃ s, a < s ∧ TruthAt M τ s (Formula.atom q) ∧ ∀ n, TruthAt M τ s (qAlpha q n)

  /-- The strictly increasing chain of `q`-points generated by `qAlpha_step`. -/
  theorem exists_strictMono_qPoints (q : Atom) … :
      ∃ ch : ℕ → F.Duration, StrictMono ch ∧ ∀ n, TruthAt M τ (ch n) (Formula.atom q)
  ```
  `dedWitness_core` then reads: get the chain, bound it by `qBound`, take the sup, contradict
  `qGap` — about 12 lines, matching the four-sentence argument its own docstring gives at
  `:207-214`.
- **Effort**: M
- **Depends on**: -

### B-21. No tactic or `simp` set for the recurring witness-membership and satisfiability idioms

- **Severity**: Medium
- **Category**: tactic-automation
- **Anchors**: `DiscreteNonCompactness.lean:202` and `DedekindNonCompactness.lean:402-403` (the `simp only [<witness>, Set.mem_union, Set.mem_singleton_iff, Set.mem_setOf_eq]` incantation); `DiscreteNonCompactness.lean:229`, `:259`, `:288` and `DedekindNonCompactness.lean:271`, `:441`, `:469` (the `rintro ⟨F, ⟨…⟩, M, τ, hτ, t, h⟩` destructuring); `SetConsequence.lean:552-561` (a 10-line docstring explaining how to write that pattern by hand)
- **Description**: Three idioms recur across the two witness modules and are each hand-written
  every time: (a) unfolding witness-set membership into its two or three cases; (b) destructuring
  a `SatisfiableSet fc` existential with the class-dependent nesting; (c) reinstalling a
  destructured frame condition as an instance (`haveI : DenselyOrdered F.Duration := hd`, twice in
  `DedekindNonCompactness.lean`, at `:442` and `:470`). Case (b) is delicate enough that
  `SatisfiableDiscreteSet`'s docstring devotes ten lines to warning that the four binders must stay
  anonymous or definitional equality breaks (`SetConsequence.lean:558-561`).
- **Impact**: A documented-in-prose calling convention that the elaborator does not enforce; six
  hand-written destructurings, each a chance to get the nesting wrong.
- **Recommendation**: two cheap moves rather than a custom tactic.
  1. Give each witness set a `@[simp]` membership characterisation next to its definition —
     `mem_archWitness_iff`, `mem_dedWitness_iff` — replacing the inline `simp only` lists.
  2. Add elimination adapters mirroring the existing `SatisfiableSet.*_of_forall` introduction ones:
     `SatisfiableSet.discrete_elim`, `.dedekind_elim`, taking a continuation in the flat
     pre-collapse binder shape. That makes the anonymity discipline the adapter's problem instead
     of the caller's, and lets the ten-line warning docstring be replaced by "use
     `SatisfiableSet.discrete_elim`".

  Both become largely moot at the four refutation sites once B-05 lands, but the witness lemmas
  themselves still destructure.
- **Effort**: S
- **Depends on**: -

### B-22. `TMCompleteBase`/`ForwardBase` and their Discrete siblings are an unindexed 2× duplication

- **Severity**: Low
- **Category**: duplication
- **Anchors**: `TMCompletenessReduction.lean:82`, `:89`, `:104`, `:122`, `:129`, `:143`
- **Description**: `TMCompleteBase`/`TMCompleteDiscrete` and `ForwardBase`/`ForwardDiscrete` are
  the same two `Prop`s at two `FrameClass` tags, and `tmCompleteBase_iff_forwardBase` /
  `tmCompleteDiscrete_iff_forwardDiscrete` are the same four-line proof twice — modulo which
  soundness theorem and which BL-validity bridge is named. The module is otherwise exemplary: the
  "unasserted `def`, never a theorem conclusion" discipline is clearly stated (`:28-33`) and
  clearly followed.
- **Impact**: Small in absolute terms (≈ 30 lines), but it blocks the natural generalisation: the
  equivalence holds at *any* `fc` for which a `WeakCompleteness fc` engine and a BL/BL⁺ validity
  bridge exist, which would let the Dense and Dedekind rows be named for free.
- **Recommendation**:
  ```lean
  def TMComplete (fc : FrameClass) : Prop :=
    ∀ φ : BLFormula, BLValidIn fc φ → BaseLanguage.Derivable fc [] φ
  def Forward (fc : FrameClass) : Prop :=
    ∀ φ : BLFormula, ProofSystem.Derivable fc [] (tr φ) → BaseLanguage.Derivable fc [] φ

  theorem tmComplete_iff_forward {fc : FrameClass} (engine : WeakCompleteness fc)
      (bridge : ∀ φ, BLValidIn fc φ ↔ ValidIn fc (tr φ)) : TMComplete fc ↔ Forward fc
  ```
  keeping the four existing names as instantiations so the prohibition prose still resolves.
  Requires a `BLValidIn` counterpart on the BL side; check whether `Semantics/BLValidity.lean`
  already indexes over `FrameClass` before committing to this.
- **Effort**: M
- **Depends on**: B-10

### B-23. 45 in-file `#print axioms` commands duplicate an external check

- **Severity**: Low
- **Category**: organization
- **Anchors**: `StrongCompleteness.lean:598-599`, `:1011-1023` (14 total); `Compactness.lean:174-179` (6); `DiscreteNonCompactness.lean:292-297` (12 incl. the transcribed block at `:302-313`); `DedekindNonCompactness.lean:473-478` (13 incl. `:485-496`); `scripts/check-module-invariants.sh:155-158` (C2 runs `#print axioms` externally against a recorded baseline)
- **Description**: 64 across the live tree, 45 in this territory. Each emits an info-level message
  on every build. C2 already runs the same check externally for the flagship theorems against a
  recorded baseline, which is the form that can actually *fail*; the in-file ones cannot — they
  print, and a drift would be noticed only by a human reading build output. Two of the four modules
  additionally transcribe the expected output into a prose block immediately below
  (`DiscreteNonCompactness.lean:302-313`, `DedekindNonCompactness.lean:485-496`), which is a
  hand-maintained copy of machine output.
- **Impact**: Build-log noise and a second, non-failing copy of an assertion the invariants script
  owns. The transcribed blocks are exactly the kind of thing that silently goes stale.
- **Recommendation**: keep `#print axioms` on the *termini* only — `strongCompletenessBase`,
  `strongCompletenessDense`, `discrete_consequence_not_compact`,
  `dedekind_consequence_not_compact`, `consequence_completeness_dedekind` — and move the rest into
  `scripts/check-module-invariants.sh`'s C2 manifest, where drift fails the build. Delete the
  transcribed-output prose blocks; the script's baseline file is their proper home.
- **Effort**: S
- **Depends on**: -

---

## 4. Proposed core utilities

Ranked by leverage (lines and findings discharged per line added).

1. **`semantic_deduction_in {fc} (Γ φ) : SemanticConsequenceIn fc Γ φ ↔ ValidIn fc (Γ.foldr Formula.imp φ)`**
   *Home*: `Metalogic/StrongCompleteness.lean`, immediately after `truthAt_foldr_imp`.
   *Discharges*: B-01, and unblocks B-03. ≈ 6 lines added, ≈ 44 removed.

2. **`compact_of_strongCompleteness {fc} : StrongCompleteness fc → Compact fc`** and
   **`strongCompleteness_iff_compact {fc} (engine : WeakCompleteness fc) : StrongCompleteness fc ↔ Compact fc`**
   *Home*: `Metalogic/StrongCompleteness.lean`, beside `strongCompleteness_of_compact`.
   *Discharges*: B-04; halves B-05; makes the layer's headline fact a single declaration (Q9).
   ≈ 10 lines added, ≈ 25 removed.

3. **`not_compact_of_witness` / `not_strongCompleteness_of_witness` / `setConsequence_of_not_satisfiable`**
   *Home*: the first two in `Metalogic/StrongCompleteness.lean`, the third in
   `Metalogic/SetConsequence.lean`.
   *Discharges*: B-05, most of B-21. ≈ 15 lines added, ≈ 44 removed; both non-compactness modules
   shrink to witness-construction only.

4. **`modelExistence_of_satPreserved {fc} (hpres : ultraproduct-closure of `fc.Sat`) : ModelExistence fc`**
   *Home*: `Metalogic/Compactness.lean`.
   *Discharges*: B-06; and its docstring becomes the single place where "why Base and Dense but not
   Discrete and Dedekind" is explained, retiring several paragraphs covered by B-14/B-16.
   ≈ 20 lines added, ≈ 16 removed, large conceptual gain.

5. **`WeakCompleteness (fc : FrameClass) : Prop := ∀ ψ, ValidIn fc ψ → Derivable fc [] ψ`**
   *Home*: `Metalogic/SetConsequence.lean`, beside `StrongCompleteness`.
   *Discharges*: B-10; prerequisite for B-03, B-04's `iff`, B-22. 2 lines added; collapses the four
   `completeness_*` corollaries to identities.

6. **`soundness_consequence {fc} (Γ φ) : Derivable fc Γ φ → SemanticConsequenceIn fc Γ φ`**
   *Home*: `Metalogic/StrongCompleteness.lean`, beside `soundness_setConsequence`.
   *Discharges*: B-02. 3 lines added, ≈ 12 lines and ≈ 50 docstring lines removed.

7. **`Truth.and_iff` (and `neg_iff`, `or_iff` if wanted)**
   *Home*: `Semantics/Truth.lean`, in the `@[simp]` characterization block.
   *Discharges*: B-13; retires `truth_and_iff'` and re-points nine sites in
   `Correspondence/DurationFrames.lean`. 3 lines added, 3 copies → 1.

8. **`exists_maximal_of_chainClosed {P} {A} : …`**
   *Home*: `Metalogic/Core/MaximalConsistent.lean`.
   *Discharges*: B-11. ≈ 45 lines added, ≈ 110 removed; `restricted_lindenbaum` becomes its
   four-line closure-preservation obligation plus an application.

9. **`restricted_mcs_iter_bounded {it b op} : …`**
   *Home*: `Metalogic/Core/RestrictedMCS/Basic.lean`.
   *Discharges*: B-12. ≈ 80 lines added, ≈ 155 removed; the F/P mirror disappears.

---

## 5. Metrics

| Metric | Value |
|---|---|
| Territory files read in full | 14 (`StrongCompleteness`, `SetConsequence`, `Compactness`, `DiscreteNonCompactness`, `DedekindNonCompactness`, `TMCompletenessReduction`, `Conservativity`, `Core.lean` + 4 `Core/` modules; `SpWitness`/`Z1Countermodel` by declaration index) |
| Territory lines | 5,645 |
| Declarations in territory | 226 |
| Structural `sorry` in territory | **0** (all 7 grep hits are prose about `sorry`) |
| Files skimmed for context | `Semantics/Validity.lean`, `Semantics/FrameClassValidity.lean`, `Semantics/Truth.lean`, `Semantics/Ultraproduct/{Los,IndexFilter,Carrier,ShiftSetProduct}.lean`, `BXCanonical/Completeness*.lean`, `Metalogic/Soundness.lean` (signatures), `Metalogic.lean`, `Metalogic/README.md`, `lakefile.lean`, `scripts/check-module-invariants.sh`, `scripts/module-invariants-manifest.txt` |
| Findings | 23 (Critical 1, High 6, Medium 12, Low 4) |
| ×4 per-class families identified | 21 (see §2); 5 generic, 5 independently proved, 11 abbreviation-only |
| Duplicated proof lines (estimate) | ≈ 230 in `Metalogic/*.lean`, ≈ 265 in `Core/` |
| Dead declarations found | 15 (all in `SetConsequence.lean`) |
| Modules unreachable from `lake build` and unmanifested | 4 |
| Stale `file.lean:NNN` citations | 6 of 16 in the five main files (38%) |
| Comment density | `StrongCompleteness` 69%, `Conservativity` 80%, `SetConsequence` 62%, `Compactness` 60% |
| Refactor-archaeology prose lines | 45 (20 + 25 in the two main files) |
| Declarations with proof body > 45 lines | 12 (10 of them in `Core/`) |
| In-file `#print axioms` | 45 in territory, 64 tree-wide |
