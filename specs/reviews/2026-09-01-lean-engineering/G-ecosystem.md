# Territory G: Ecosystem Survey — Mathlib, CSLib, FFL and Best Practices

Scope note: everything below was checked against locally-resolved Mathlib
(`/home/benjamin/Projects/BimodalLogic/.lake/packages/mathlib/Mathlib`, tag `v4.33.0-rc1`), against
files actually fetched from GitHub via `gh api`, or against the target repository itself. Line
numbers for Mathlib are from the local checkout. Anything I could not confirm is marked
**UNVERIFIED**.

---

## 1. Executive summary

The ten conventions worth adopting, ordered by payoff.

1. **Make `Th`/`Mod` a real `GaloisConnection` into `OrderDual`.** Mathlib already ships this exact
   shape twice, for exactly this kind of antitone theory/model pair: `PrimeSpectrum.gc`
   (`Mathlib/RingTheory/Spectrum/Prime/Basic.lean:185`) and
   `MvPolynomial.zeroLocus_vanishingIdeal_galoisConnection`
   (`Mathlib/RingTheory/Nullstellensatz.lean:87`). Six of the ten theorems in
   `FormalSystem/Semantics/Correspondence/Galois.lean` become one-line projections, and the file
   *gains* `Mod (S₁ ∪ S₂) = Mod S₁ ∩ Mod S₂` and the `⋃`/`⋂` version for free
   (`Mathlib/Order/GaloisConnection/Basic.lean:91,102`). §3.

2. **Collapse the per-frame-class definition families.** 123 top-level declarations in the repo
   have a name ending in a frame-class tag, and the biggest families are pure four-way copies of a
   parametric definition that *already exists*: `SetSemanticConsequenceOn fc` at
   `FormalSystem/Metalogic/SetConsequence.lean:107` is immediately followed by four hand-written
   specializations plus eight `.of_forall`/`.apply` lemmas and four `_mono` lemmas, one per tag.
   Mathlib's model theory never does this: there is one `Theory.IsSatisfiable`
   (`Mathlib/ModelTheory/Satisfiability.lean:65`), and `FrameClass`-like variation is carried by
   the argument, not by the name. §2, finding G-02.

3. **Adopt FFL's `Sound`/`Complete`/`Canonical` typeclass triple, indexed by `(logic, frameClass)`.**
   `FormalizedFormalLogic/ModalLogic`'s `ModalLogicArchive/Modal/Kripke/Logic/S5.lean` states
   soundness, consistency, canonicity and completeness for S5 in **four `instance` lines**, with
   `Complete Modal.S5 FrameClass.S5 := inferInstance` derived from `Canonical`. The repo's
   equivalent (`completeness_base`, `completeness_dense`, `completeness_dedekind`,
   `soundness_*_consequence`, …) is four hand-copied theorem chains. §4, finding G-04.

4. **Bundle the model witness, à la `Theory.ModelType`.** `Mathlib/ModelTheory/Bundled.lean:73`
   defines a `structure ModelType` carrying carrier + instances, and
   `IsSatisfiable := Nonempty (ModelType T)`. The repo's `SatisfiableSet`
   (`SetConsequence.lean:154`) is a bare existential over an unbundled frame/model/history tuple,
   which is why it needs four `SatisfiableSet.*_of_forall` constructors. §2, finding G-01.

5. **State compactness as an `iff` with finite satisfiability, not as an implication.**
   `isSatisfiable_iff_isFinitelySatisfiable`
   (`Mathlib/ModelTheory/Satisfiability.lean:100`) is the canonical form; the easy direction
   (`IsSatisfiable.isFinitelySatisfiable`, line 95) is one line and makes the statement symmetric
   and quotable. §2, finding G-03.

6. **Adopt CSLib's repository furniture wholesale.** `Cslib/Init.lean` (a single root imported by
   every file, carrying the linter set), `lake exe checkInitImports`, `lake exe mk_all`,
   `lake shake`, `lake exe lint-style`, `ORGANISATION.md`, `NOTATION.md`, `references.bib`, and a
   `README.md` per top-level directory. All verified in the `leanprover/cslib` tree. The target
   repo has none of these except per-directory READMEs. §5, findings G-08, G-09.

7. **Run `#lint` in CI.** Mathlib ships 30 linters under `Mathlib/Tactic/Linter/`, wired through
   `Mathlib/Init.lean`; `docBlame`/`docBlameThm` are what enforce the "every declaration has a
   docstring" rule. The repo's `.github/workflows/ci.yml` explicitly sets `lint: false` and skips
   CI entirely on push unless the commit message contains `[ci]`. ~7% of the repo's 8,982
   definition-shaped declarations have no immediately-preceding docstring. §6, finding G-10.

8. **Normalize `lemma` → `theorem`.** Mathlib uses `theorem` throughout. The repo is at
   7,031 `theorem` / 141 `lemma` — the 141 are noise, not a distinction. §6, finding G-11.

9. **Publish with `docgen-action` + `CITATION.cff` + a "main theorems" page.** The
   `leanprover-community/docgen-action` action builds doc-gen4 API docs, a Jekyll homepage and
   (optionally) a leanblueprint, and deploys to GitHub Pages in about ten lines of YAML. `teorth/pfr`
   is the reference layout: `CITATION.cff`, `blueprint/src/`, `.github/workflows/push.yml`. §8,
   finding G-14.

10. **Keep mining Mathlib's order theory rather than re-deriving it.** The repo already does this
    well in one place — `FormalSystem/Semantics/DurationClassification.lean` imports
    `Mathlib.GroupTheory.ArchimedeanDensely` and its classification is
    `LinearOrderedAddCommGroup.discrete_or_denselyOrdered`
    (`Mathlib/GroupTheory/ArchimedeanDensely.lean:230`) — but its own header records a `private`
    duplicate of the Archimedean argument in `Metalogic/SoundnessLemmas/Separability.lean`. §7,
    finding G-13.

---

## 2. Mathlib `ModelTheory` patterns and their TM transfer (Q1)

All of `Mathlib/ModelTheory/{Basic,Syntax,Semantics,Satisfiability,Ultraproducts,Bundled,ElementaryMaps,Complexity}.lean`
exist locally (VERIFIED by `ls`). The relevant declarations, verbatim:

| Mathlib declaration | Path:line | Statement |
|---|---|---|
| `Theory.Model` (class) | `Semantics.lean:727` | `class Theory.Model (T : L.Theory) : Prop where realize_of_mem : ∀ φ ∈ T, M ⊨ φ` |
| `⊨` for theories | `Semantics.lean:732` | `infixl:51 " ⊨ " => Theory.Model` |
| `Theory.ModelType` | `Bundled.lean:73` | `structure ModelType where Carrier : Type w; [struc]; [is_model]; [nonempty']` |
| `ModelType.of` | `Bundled.lean:93` | smart constructor from a type with instances |
| `Theory.IsSatisfiable` | `Satisfiability.lean:65` | `def IsSatisfiable : Prop := Nonempty (ModelType.{u,v,max u v} T)` |
| `Theory.IsFinitelySatisfiable` | `Satisfiability.lean:69` | `∀ T0 : Finset L.Sentence, ↑T0 ⊆ T → IsSatisfiable ↑T0` |
| `IsSatisfiable.mono` | `Satisfiability.lean:78` | `T'.IsSatisfiable → T ⊆ T' → T.IsSatisfiable` |
| `IsSatisfiable.isFinitelySatisfiable` | `Satisfiability.lean:95` | `fun _ => h.mono` — one line |
| **compactness** | `Satisfiability.lean:100` | `theorem isSatisfiable_iff_isFinitelySatisfiable {T : L.Theory} : T.IsSatisfiable ↔ T.IsFinitelySatisfiable` |
| `Theory.ModelsBoundedFormula` (`⊨ᵇ`) | `Satisfiability.lean:278` | consequence, quantified over `ModelType` |
| `models_iff_not_satisfiable` | `Satisfiability.lean:296` | `T ⊨ᵇ φ ↔ ¬IsSatisfiable (T ∪ {φ.not})` |
| `models_iff_finset_models` | `Satisfiability.lean:368` | consequence reduces to finite subsets |
| `Theory.IsComplete` | `Satisfiability.lean:385` | satisfiable + decides every sentence |
| `Theory.IsMaximal` | `Satisfiability.lean:455` | `IsMaximal.isComplete` at 458 |
| `Ultraproduct.sentence_realize` (Łoś) | `Ultraproducts.lean:154` | `(u : Filter α).Product M ⊨ φ ↔ ∀ᶠ a in u, M a ⊨ φ` |
| `Ultraproduct.boundedFormula_realize_cast` | `Ultraproducts.lean:95` | the induction that Łoś is proved by |

### 2.1 How the compactness proof is structured, and why it matters here

`isSatisfiable_iff_isFinitelySatisfiable` (`Satisfiability.lean:100-118`) is built out of exactly
three moving parts: index by `Finset T`, take `Ultrafilter.of (Filter.atTop)`, form
`Filter.Product`, then apply `Ultraproduct.sentence_realize` pointwise and push the eventual filter
with `Filter.eventually_atTop`. The target repo has independently built the same three parts:

- `FormalSystem/Semantics/Ultraproduct/IndexFilter.lean:54` — `abbrev Idx (Γ : Set α) := {L : List α // ∀ ψ ∈ L, ψ ∈ Γ}`,
  `tailFilter` at `:57`, `tailFilter_neBot` at `:77`, `eventually_mem` at `:89`. This is Mathlib's
  `Filter.atTop` on `Finset T` with `List` in place of `Finset`.
- `FormalSystem/Semantics/Ultraproduct/Carrier.lean` — `UD` (`:88`), `UOmega` (`:207`),
  the order/group instances at `:103-182`.
- `FormalSystem/Semantics/Ultraproduct/Los.lean` — the Łoś statement.

**Transfer verdict.** The *machinery* correctly does not reuse `FirstOrder.Language`: TM is not a
first-order theory over a single-sorted structure, and `Filter.Product` requires an
`L.Prestructure`. What transfers is the **API surface shape**, not the implementation. Concretely:

### 2.2 Signature proposals

Current (`FormalSystem/Metalogic/SetConsequence.lean:154,164,175,185`):

```lean
def SatisfiableSet     (fc : FrameClass) (Γ : Set Formula) : Prop := ...   -- bare ∃
def ModelExistence     (fc : FrameClass) : Prop := ...
def Compact            (fc : FrameClass) : Prop := ...
def StrongCompleteness (fc : FrameClass) : Prop := ...
```

followed at `:449-469` (and onward) by `StrongCompletenessBase`, `CompactBase`,
`SatisfiableBaseSet`, … one per tag.

Proposed, following `Bundled.lean:73` + `Satisfiability.lean:65,69,100`:

```lean
/-- A bundled pointed model of `Γ` in frame class `fc`: a frame, a model on it,
a total history and a time at which every member of `Γ` is true. -/
structure PointedModel (fc : FrameClass) (Γ : Set Formula) where
  Frame   : TaskFrame
  inClass : fc.Holds Frame
  Model   : TaskModel Frame
  hist    : WorldHistory Frame
  htotal  : hist.IsTotal
  time    : Frame.D
  models  : ∀ φ ∈ Γ, Model.TruthAt hist time φ

/-- `Γ` is satisfiable in `fc`. Mirrors `FirstOrder.Language.Theory.IsSatisfiable`. -/
def SatisfiableSet (fc : FrameClass) (Γ : Set Formula) : Prop := Nonempty (PointedModel fc Γ)

/-- Mirrors `Theory.IsFinitelySatisfiable`. -/
def FinitelySatisfiableSet (fc : FrameClass) (Γ : Set Formula) : Prop :=
  ∀ Γ₀ : Finset Formula, ↑Γ₀ ⊆ Γ → SatisfiableSet fc ↑Γ₀

theorem SatisfiableSet.mono (h : SatisfiableSet fc Δ) (hs : Γ ⊆ Δ) : SatisfiableSet fc Γ
theorem SatisfiableSet.finitelySatisfiable (h : SatisfiableSet fc Γ) :
    FinitelySatisfiableSet fc Γ := fun _ => h.mono          -- one line, as in Mathlib

/-- Compactness for `fc`, stated as an iff. Compare `isSatisfiable_iff_isFinitelySatisfiable`. -/
theorem satisfiableSet_iff_finitelySatisfiable {fc} (h : CompactClass fc) {Γ} :
    SatisfiableSet fc Γ ↔ FinitelySatisfiableSet fc Γ
```

Three consequences of the bundling:

- The four `SatisfiableSet.base_of_forall` / `dense_of_forall` / `discrete_of_forall` /
  `dedekind_of_forall` constructors (`SetConsequence.lean:301,307,317,327`) become one
  `PointedModel.mk` plus, if wanted, one `PointedModel.of` smart constructor — exactly
  `ModelType.of` (`Bundled.lean:93`).
- `.mono` is inherited rather than re-proved per tag (compare `IsSatisfiable.mono`,
  `Satisfiability.lean:78`).
- Bundling is the enabler for the typeclass form in §4: `Complete L fc` needs a *single* type of
  witness to talk about.

The `models_iff_not_satisfiable` shape (`Satisfiability.lean:296`) is also worth stating —
`SetSemanticConsequenceOn fc Γ φ ↔ ¬ SatisfiableSet fc (Γ ∪ {φ.neg})` — because it is the bridge
that lets one compactness theorem serve both consequence and satisfiability, which is currently
done by hand per tag in `StrongCompleteness.lean`.

The `IsComplete`/`IsMaximal` pair (`Satisfiability.lean:385,455`, with `IsMaximal.isComplete` at
458 and `IsMaximal.mem_iff_models` at 469) is a directly-usable naming and API template for
`Metalogic/Core/`'s MCS machinery — in particular `mem_iff_models` is exactly the truth-lemma
membership characterization, and `mem_or_not_mem` (line 461) the maximality primitive.

---

## 3. Galois connection reuse (Q2) — mapping table

**Current state (VERIFIED):** `grep -rn "GaloisConnection\|GaloisInsertion" FormalSystem` over the
non-Boneyard tree returns **zero hits**. `ClosureOperator` appears only in
`FormalSystem/Metalogic/Algebraic/InteriorOperators.lean`. So the whole of
`FormalSystem/Semantics/Correspondence/Galois.lean` is hand-rolled.

### 3.1 The exact Mathlib shape for an antitone connection

Mathlib does not have a separate `AntitoneGaloisConnection`; it uses `OrderDual` at the type
ascription. Two verified precedents, both theory/model pairs:

```lean
-- Mathlib/RingTheory/Spectrum/Prime/Basic.lean:185
theorem gc : @GaloisConnection (Ideal R) (Set (PrimeSpectrum R))ᵒᵈ _ _
    (fun I => zeroLocus I) fun t => vanishingIdeal t :=
  fun I t => subset_zeroLocus_iff_le_vanishingIdeal t I

-- Mathlib/RingTheory/Nullstellensatz.lean:87
theorem zeroLocus_vanishingIdeal_galoisConnection :
    @GaloisConnection (Ideal (MvPolynomial σ k)) (Set (σ → K))ᵒᵈ _ _
      (zeroLocus K) (vanishingIdeal k) :=
  GaloisConnection.monotone_intro (fun _ _ ↦ vanishingIdeal_anti_mono)
    (fun _ _ ↦ zeroLocus_anti_mono) le_vanishingIdeal_zeroLocus zeroLocus_vanishingIdeal_le
```

The Nullstellensatz form is the one to copy, because its four arguments are *literally* the repo's
four existing lemmas. The proposed declaration:

```lean
-- FormalSystem/Semantics/Correspondence/Galois.lean
/-- `Mod` and `Th` form an (antitone) Galois connection between formula sets and frame classes.
Compare `PrimeSpectrum.gc` and `MvPolynomial.zeroLocus_vanishingIdeal_galoisConnection`. -/
theorem mod_th_gc : @GaloisConnection (Set Formula) (Set TaskFrame)ᵒᵈ _ _ Mod Th :=
  GaloisConnection.monotone_intro
    (fun _ _ h => th_anti h) (fun _ _ h => mod_anti h) subset_th_mod subset_mod_th
```

Unfolding: `GaloisConnection l u := ∀ a b, l a ≤ b ↔ a ≤ u b`
(`Mathlib/Order/GaloisConnection/Defs.lean:41`). With `b : (Set TaskFrame)ᵒᵈ` the `≤` reverses, so
this reads `K ⊆ Mod S ↔ S ⊆ Th K` — the adjunction the file's docstring already asserts in prose.

### 3.2 Mapping table

| Repo declaration | `Galois.lean` line | Mathlib replacement | Mathlib path:line |
|---|---|---|---|
| `th_anti` | 107 | `mod_th_gc.monotone_u` | `Order/GaloisConnection/Defs.lean:82` |
| `mod_anti` | 111 | `mod_th_gc.monotone_l` (`monotone_intro` input) | `Defs.lean:56` |
| `subset_mod_th` | 115 | `mod_th_gc.l_u_le` | `Defs.lean` (`l_u_le`, dual of `le_u_l`) |
| `subset_th_mod` | 119 | `mod_th_gc.le_u_l` | `Defs.lean:78` |
| `th_mod_th` | 127 | `mod_th_gc.u_l_u_eq_u` | `Defs.lean:103` |
| `mod_th_mod` | 123 | `mod_th_gc.dual.u_l_u_eq_u` (+ `OrderDual` `simp` cleanup) | `Defs.lean:62` (`GaloisConnection.dual`), `:103` |
| `galoisClosed_mod` | 139 | corollary of the above | — |
| `GaloisClosed` (def) | 136 | keep as-is; optionally `∈ mod_th_gc.dual.lowerAdjoint.closed` | `Order/Closure.lean:519, 381` |
| `galoisClosed_of_indicator` | 158 | **keep — genuinely repo-specific** | — |
| `AxiomSet`, `densitySchema` | 172, 180 | **keep — repo-specific reifications** | — |

Caveat marked honestly: `l_u_l_eq_l` does **not** appear by that name in the local
`Order/GaloisConnection/Defs.lean` (VERIFIED by grep); the dual route via
`GaloisConnection.dual` (`Defs.lean:62`) is the safe one, and will need a `Function.comp` /
`OrderDual.toDual` `simp` unfold. Budget one extra line for `mod_th_mod`.

### 3.3 What the repo *gains* (this is the real argument, not the six-line saving)

`GaloisConnection` in `Mathlib/Order/GaloisConnection/Basic.lean` supplies, for free, lemmas that
`Galois.lean` currently does not state at all and which are directly relevant to the axiom-set and
sandwich work in `Metalogic/Independence/`:

| Mathlib lemma | Path:line | Reads here as |
|---|---|---|
| `GaloisConnection.l_sup` | `Basic.lean:91` | `Mod (S₁ ∪ S₂) = Mod S₁ ∩ Mod S₂` |
| `GaloisConnection.l_iSup` | `Basic.lean:102` | `Mod (⋃ i, Sᵢ) = ⋂ i, Mod Sᵢ` |
| `GaloisConnection.l_iSup₂` | `Basic.lean:109` | the indexed-family version |
| `GaloisConnection.u_top` / `u_l_top` | `Defs.lean:139, 143` | `Th ∅ = univ` and the closure of the empty class |
| `GaloisConnection.u_eq` | `Defs.lean:121` | a universal characterization of `Th K` |
| `GaloisConnection.lt_iff_lt` | `Defs.lean:153` | strict-inclusion transfer, useful for "provably distinct without characterizing" |

`l_sup`/`l_iSup` in particular are the natural lemmas for reasoning about `AxiomSet fc` as a union
of per-axiom instance sets, which the `Mod (AxiomSet fc)` sandwich statements need.

`Mathlib/Order/Closure.lean` additionally offers `ClosureOperator` (`:60`), `ClosureOperator.mk'`
(`:176`), `ClosureOperator.ofPred` (`:196`), `LowerAdjoint` (`:309`), `LowerAdjoint.closed`
(`:381`), `mem_closed_iff_closure_le` (`:395`), `GaloisConnection.lowerAdjoint` (`:519`), and
`GaloisConnection.closureOperator` (`:527`). My recommendation is to take the `GaloisConnection`
step but **not** the `ClosureOperator` step: on the dual side the coercions cost more than the four
lines of `GaloisClosed` API they would replace, and `galoisClosed_of_indicator` — the file's actual
contribution — has no Mathlib analogue either way.

---

## 4. FFL / lean4-logic organizational patterns (Q3)

**Current layout (VERIFIED via `gh api`, 2026-09).** `FormalizedFormalLogic/Foundation` (master,
285 tree entries) now holds only `Foundation/{FirstOrder,Logic,Propositional,SecondOrder,Syntax,Meta,Vorspiel}`.
The modal development moved to a **separate repository**, `FormalizedFormalLogic/ModalLogic`
(pushed 2026-08-01, 798 tree entries), where it lives under `ModalLogicArchive/Modal/**` alongside
a newer `Neighborhood/**` development. The `ModalLogicArchive` prefix signals a refactor in
progress — treat the patterns as proven-in-practice but the paths as unstable. The organization
also maintains `NonClassicalModalLogic`, `ProvabilityLogic`,
`ModalLogicNeighborhoodSemantics`, `LabelledSystem`, and `awesome-logic-formalization`.

### The seven patterns worth borrowing

**P1 — `Sound` / `Complete` / `Canonical` as typeclasses indexed by `(logic, frameClass)`.**
From `ModalLogicArchive/Modal/Kripke/Logic/S5.lean` (fetched VERBATIM):

```lean
instance : Sound Modal.S5 FrameClass.S5 := instSound_of_validates_axioms $ by
  apply FrameClass.validates_with_AxiomK_of_validates
  constructor
  rintro _ (rfl | rfl) F ⟨_, _⟩
  . exact validate_AxiomT_of_reflexive
  . exact validate_AxiomFive_of_euclidean

instance : Entailment.Consistent Modal.S5 := consistent_of_sound_frameclass FrameClass.S5 $ by
  use whitepoint; constructor

instance : Canonical Modal.S5 FrameClass.S5 := ⟨by constructor⟩
instance : Complete Modal.S5 FrameClass.S5 := inferInstance
```

The whole metatheory of S5 relative to its frame class, in four instances, with completeness
*derived by instance resolution* from canonicity. This is the single most transferable idea for a
repo with four frame classes and a per-class copy of every completeness theorem.

**P2 — Frame properties as `class`es on the frame, frame classes as `{F | F.IsX}`.** Same file:

```lean
protected class Frame.IsS5 (F : Frame) extends F.IsReflexive, F.IsEuclidean
protected class Frame.IsFiniteS5 (F : Frame) extends F.IsFinite, F.IsS5
protected abbrev FrameClass.S5 : FrameClass := { F | F.IsS5 }
```

with the inclusion order carried by instances rather than by an `LE` match:

```lean
instance [F.IsS5] : F.IsKD45 where
instance [F.IsS5] : F.IsKB4 where
```

Compare `FormalSystem/ProofSystem/Axioms.lean:531-580`, where `FrameClass` is a four-constructor
inductive with a hand-written `LE` match and a `PartialOrder` instance proved by a 64-case
`cases … <;> trivial`. The inductive tag is fine as an *index for derivations* (it must be, since
`DerivationTree` is indexed by it and needs `DecidableEq`), but the *semantic* side would be
better served by `TaskFrame.IsDense`, `TaskFrame.IsDiscrete`, `TaskFrame.IsDedekind` classes with
`instance [F.IsDedekind] : F.IsDense` doing the ordering work — at which point
`FrameClass.Holds` is `{F | F.IsX}` and the incomparability of `Discrete` and `Dedekind` is
simply the absence of an instance rather than a `False` branch in a match. The repo already has
`TaskFrame.Is<FC>` and `TaskFrame.IsSuccArch<FC>` families (22 and 42 occurrences respectively,
VERIFIED by grep), so this is half-done.

**P3 — One file per logic under `Kripke/Logic/`.** `ModalLogicArchive/Modal/Kripke/Logic/`
contains 40+ files named `K.lean`, `KT.lean`, `S4.lean`, `S5.lean`, `GL/Soundness.lean`,
`GL/Completeness.lean`, … Each file holds *all* the metatheory for one logic. The generic
machinery lives one level up in `Kripke/Basic.lean`, `Kripke/Completeness.lean`. The repo's
analogue would be `Metalogic/Class/{Base,Dense,Discrete,Dedekind}.lean`, each holding that class's
`Sound`/`Canonical`/`Complete` instances and nothing else, with `Metalogic/Class/Basic.lean`
holding the generic-in-`fc` theorems.

**P4 — Generic canonical model over an abstract entailment.** From
`ModalLogicArchive/Modal/Kripke/Completeness.lean`:

```lean
variable {S} [Entailment S (Formula ℕ)]
variable {𝓢 : S} [Entailment.Consistent 𝓢] [Entailment.K 𝓢]

abbrev canonicalFrame (𝓢 : S) [Entailment.Consistent 𝓢] [Entailment.K 𝓢] : Kripke.Frame where
  World := MaximalConsistentTableau 𝓢
  Rel t₁ t₂ := □⁻¹'t₁.1.1 ⊆ t₂.1.1

abbrev canonicalModel (𝓢 : S) [...] : Model where
  toFrame := canonicalFrame 𝓢
  Val a t := (atom a) ∈ t.1.1

lemma truthlemma : ((φ ∈ t.1.1) ↔ t ⊧ φ) ∧ ((φ ∈ t.1.2) ↔ ¬t ⊧ φ)
lemma iff_valid_on_canonicalModel_deducible : (canonicalModel 𝓢) ⊧ φ ↔ 𝓢 ⊢ φ
```

The truth lemma is proved **once**, generically in `𝓢`, and every logic reuses it. The repo's
`Metalogic/Bundle/` and `Metalogic/BXCanonical/TruthLemma.lean` should be checked against this:
if the truth lemma is stated per class rather than generically in `fc`, that is a large avoidable
duplication.

**P5 — Two-sided (tableau) MCS.** FFL uses `MaximalConsistentTableau` — a *pair* `(t.1.1, t.1.2)`
of a positive and a negative set — rather than a single maximal consistent set. The truth lemma is
correspondingly a conjunction of two biconditionals, and each induction case splits cleanly into
"in the positive part" and "in the negative part". For a logic with `Until`/`Since` this halves the
`push_neg` bookkeeping. Worth evaluating against `Metalogic/Core/`'s MCS machinery, though I have
not read enough of the repo's MCS layer to call it a defect — flagged as an option, not a finding.

**P6 — A `Semantics` notation typeclass plus Tarski-condition mixins.** From
`ModalLogicArchive/Logic/Semantics.lean`:

```lean
class Semantics (M : Type*) (F : outParam Type*) where Models : M → F → Prop
infix:45 " ⊧ " => Models
protected class Semantics.Top  where models_verum  (𝓜 : M) : 𝓜 ⊧ (⊤ : F)
protected class Semantics.Imp  where models_imply {𝓜 φ ψ} : 𝓜 ⊧ φ 🡒 ψ ↔ (𝓜 ⊧ φ → 𝓜 ⊧ ψ)
class Tarski extends Semantics.Top M, Semantics.Bot M, Semantics.And M,
  Semantics.Or M, Semantics.Imp M, Semantics.Not M
attribute [simp, grind] Top.models_verum Bot.models_falsum Not.models_not
  And.models_and Or.models_or Imp.models_imply
```

Everything downstream (`models_list_conj`, `models_finset_disj`, `Valid`, `Satisfiable`,
`Consequence`, `class Compact`) is stated once against `Semantics` + `Tarski` and applies to frame
validity, model validity, world satisfaction and the canonical model alike. The repo has
`ValidOnFrames` / `ValidIn` / `TruthAt` / `SetConsequenceOnFrames` as four unrelated definitions
with hand-copied monotonicity lemmas; a `Semantics`-style class would make `_mono` a single lemma.

**P7 — `class Compact` as a property of a semantics, not a per-class theorem.** Same file,
`class Compact : Prop`. Structurally identical to the proposal in §2.2.

**Temporal work in FFL:** none found. Grep over the full 798-entry `ModalLogic` tree for
`temporal|LTL|Until|Since` returns nothing. TM's temporal layer has no FFL precedent to borrow.

---

## 5. CSLib (Q4)

**What it contains (VERIFIED, `leanprover/cslib` `main` tree, 2026-09).** Top level: `Cslib/`
{`Algorithms`, `Computability`, `Crypto`, `Foundations`, `Languages`, `Logics`, `MachineLearning`,
`Probability`, `Tactic`, `Init.lean`}, plus `CslibTests/`, `scripts/`, `GOVERNANCE.md`,
`ORGANISATION.md`, `NOTATION.md`, `CONTRIBUTING.md`, `AGENTS.md`, `references.bib`,
`lakefile.toml`.

Directly relevant contents:

- `Cslib/Logics/Modal/{Basic,Cube,Denotation,LogicalEquivalence}.lean` — propositional modal logic
  with Kripke models, `Satisfies`, and a `Judgement` structure.
- `Cslib/Logics/{LinearLogic/CLL/**, HML/**, Propositional/NaturalDeduction/**}`.
- `Cslib/Foundations/Logic/{InferenceSystem,LogicalEquivalence,Operators}.lean` — the shared
  abstractions all logics instantiate.
- `Cslib/Foundations/Data/OmegaSequence/{Defs,Flatten,InfOcc,Init,Temporal,Topology}.lean` — ω-words
  with a `Temporal.lean`. This is the closest thing to LTL in the library today.
- `Cslib/Computability/Automata/{DA/Buchi,NA/BuchiEquiv,Acceptors/OmegaAcceptor}.lean` and
  `Cslib/Computability/Languages/{OmegaLanguage,OmegaRegularLanguage,SafetyLiveness}.lean` — the
  ω-automata side of a future LTL development.
- **`ORGANISATION.md` explicitly lists `Cslib.Logic.LinearTemporalLogic` as a planned directory**
  alongside `HoareLogic` and `LinearLogic` (VERIFIED, quoted from the fetched file). No such
  directory exists in the tree yet. **This is an open, named slot that TM's temporal fragment could
  contribute into.**

**Conventions (from `CONTRIBUTING.md`, `Cslib/Logics/README.md`, `Cslib/Init.lean`, all fetched):**

- *Style:* "We generally follow the mathlib style for coding and documentation" — so the Mathlib
  rules in §6 apply transitively.
- *Docstrings:* "Document your definitions and theorems to ease both use and reviewing. When
  formalising a concept that is explained in a published resource, please reference the resource in
  your documentation." → `references.bib` at the repo root.
- *`theorem` vs `lemma`:* not distinguished in CONTRIBUTING; the code uses both (`Modal/Basic.lean`
  uses `lemma` for `simp`/`grind` unfolding lemmas). Mathlib's `theorem`-everywhere is the stricter
  and safer rule.
- *Namespaces:* one root namespace `Cslib`, then `Cslib.Logic.Modal`, etc. Judgement notation is
  wrapped in a per-logic tag to avoid clashes — `Modal[m,w ⊨ φ]` — explicitly because "the library
  hosts a number of languages with their own syntax and semantics."
- *Aggregator files:* `Cslib.lean` imports every file, enforced in CI by `lake exe mk_all`. Every
  top-level directory has a `README.md` stating its principles (`Cslib/Logics/README.md`,
  `Cslib/Foundations/README.md`, …).
- *`Cslib/Init.lean`:* a single root imported by *virtually all* files, carrying the linter set —
  "Similar to Mathlib.Init, this file imports linters that should be active by default." Enforced
  by `lake exe checkInitImports` (`scripts/CheckInitImports.lean`).
- *Reuse as a stated design principle:* "New definitions should instantiate existing abstractions
  whenever appropriate: a labelled transition system should use `LTS`, etc."
- *Proof relevance:* proof systems default to `Type`, not `Prop`, "so it is easy to define
  computations on derivations, e.g., to compute their height, display them, or make tools that show
  how they can be transformed." The target repo's `DerivationTree` already follows this, which
  makes `Automation/`'s proof-step exporters possible — worth recording as a deliberate alignment.
- *CI:* PR titles must start with `feat|fix|doc|style|refactor|test|chore|perf`; `lake test`,
  `lake exe checkInitImports`, `lake lint` / `#lint`, `lake exe lint-style`,
  `lake shake --add-public --keep-implied --keep-prefix`, `lake exe mk_all`. Workflows include
  `weekly-lints.yml`, `docs.yml`, `shellcheck.yml`, `pr-title.yml`.
- *AI disclosure:* CSLib inherits Mathlib's policy — explain in the PR description which tools were
  used and how. Relevant to this repository's provenance story.

---

## 6. Mathlib style conventions: checklist with repo compliance status (Q5)

Sources: `leanprover-community.github.io/contribute/style.html` and `.../doc.html` and
`.../naming.html` (all three fetched, VERIFIED); `Mathlib/Tactic/Linter/*` and `Mathlib/Init.lean`
(local, VERIFIED).

| # | Rule | Source | Repo status |
|---|---|---|---|
| 1 | Copyright header: notice, license, `Authors:` line, no trailing periods | style.html | **PASS** — 433/434 non-Boneyard files have it (1 missing) |
| 2 | Module docstring `/-! # Title … -/` after imports | doc.html | **PASS** — 430/434; missing in `Metalogic/WeakCanonical.lean`, `Metalogic/Decidability.lean`, `Metalogic/WeakCanonical/RealModel/OrderIsoReal.lean`, `Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge.lean` |
| 3 | Docstring sections: `## Main definitions`, `## Main results`/`Main statements`, `## Notation`, `## Implementation notes`, `## References`, `## Tags` | doc.html | **PARTIAL** — `Semantics/Validity.lean` has Main Definitions / Main Results / Implementation Notes / References but no `## Tags`; `Correspondence/Galois.lean` has `## Main results` and rich implementation prose but no `## Tags` and no `## References` heading. `## Tags` is absent repo-wide. Cheap fix, real doc-gen4 search payoff |
| 4 | Docstring on every definition and major theorem; enforced by `docBlame`/`docBlameThm` | doc.html; `Mathlib/Tactic/Linter/DocString.lean` | **PARTIAL** — ~647 of 8,982 definition-shaped declarations (7%) have no immediately-preceding `/-- -/` |
| 5 | `theorem` everywhere, not `lemma` | Mathlib practice (`Mathlib.Tactic.Lemma` exists but style is `theorem`) | **PARTIAL** — 7,031 `theorem` vs 141 `lemma` (+1 `private lemma`) |
| 6 | UpperCamelCase types/Props/structures; snake_case theorems; lowerCamelCase other terms | naming.html | **PASS** on inspection — `Th`, `Mod`, `GaloisClosed`, `AxiomSet`, `densitySchema`, `th_anti`, `mod_th_mod` are all correct |
| 7 | `_iff`, `_of_`, `_left`/`_right`, `mono`/`antitone` suffixes | naming.html | **PARTIAL** — the repo uses `_anti` where Mathlib uses `anti_mono` (`th_anti` / `mod_anti`); Mathlib's own naming for this shape is `vanishingIdeal_anti_mono` / `zeroLocus_anti_mono` (`Nullstellensatz.lean:75`), so `th_anti_mono` would be closer. Low priority |
| 8 | Line length ≤ 100 | style.html | not measured (**UNVERIFIED**) |
| 9 | Terminal `simp` calls should not be squeezed | style.html | not measured (**UNVERIFIED**) |
| 10 | Every structure/class field carries a docstring | style.html | not measured (**UNVERIFIED**) |
| 11 | `library_note` for cross-cutting design decisions | doc.html | **NOT USED** — the repo puts equivalent prose in module docstrings, which is defensible but not discoverable across files |
| 12 | `assert_not_exists` for import-layering discipline | Mathlib practice — used in 889 Mathlib files (VERIFIED by grep) | **NOT USED** — zero occurrences. Directly relevant: `Correspondence/Galois.lean`'s "Import seam" section argues in prose that no new `Semantics → ProofSystem` edge is opened; `assert_not_exists` would make that machine-checked |
| 13 | `#lint` / `runLinter` in CI | `Mathlib/Init.lean`, `Mathlib/Tactic/Linter/*` (30 linters) | **NOT USED** — `.github/workflows/ci.yml` sets `lint: false` |
| 14 | `#print axioms` on headline results | Mathlib/project practice | **PASS, and unusually good** — `Metalogic/DiscreteNonCompactness.lean:292-312` and `Metalogic/DedekindNonCompactness.lean:473-490` run `#print axioms` on the six headline declarations each *and record the verbatim output in a docstring*. This is better than most research repos do |
| 15 | A `Mathlib.Init`-style root imported everywhere, carrying linter config | `Mathlib/Init.lean`; CSLib `Cslib/Init.lean` | **NOT USED** — `FormalSystem.lean` is an aggregator (imports `FormalSystem.FormalSystem`) but not a linter root, and nothing enforces that every file imports it |
| 16 | `@[simp]` normal form discipline / `simps` | style.html | not audited (**UNVERIFIED**) |
| 17 | CI runs on every push | — | **FAIL by design** — `ci.yml` skips push events unless the commit message contains `[ci]`. Fine for a solo repo, a blocker for a public one |

Notably good and worth *keeping*: `lakefile.lean` sets `autoImplicit := false` for both libraries,
which Mathlib also does globally and which most research repos forget.

---

## 7. Other formalizations & Mathlib order-theory reuse (Q6)

### 7.1 Modal logic in Lean 4

| Project | What it does | One idea to borrow / avoid |
|---|---|---|
| `FormalizedFormalLogic/ModalLogic` (and `Foundation`) | K through S5, GL, Grz, Geach axioms, neighborhood semantics, canonical models, undefinability | **Borrow:** the `Sound`/`Complete`/`Canonical` instance triple (§4 P1). **Avoid:** the `ModalLogicArchive` naming and the split across five repositories — path instability makes it hard to cite |
| `FormalizedFormalLogic/NonClassicalModalLogic`, `ProvabilityLogic`, `ModalLogicNeighborhoodSemantics`, `LabelledSystem` | sibling developments in the same organization | **Borrow:** the "one logic family per repository, shared `Foundation` dependency" model if TM ever splits |
| `leanprover/cslib` `Cslib/Logics/Modal/` | propositional modal logic on `InferenceSystem` | **Borrow:** per-logic notation tags (`Modal[m,w ⊨ φ]`) to prevent `⊨` clashes across the four frame classes |
| Bentzen, "A Henkin-style completeness proof for the modal logic S5" | Lean 3 (**UNVERIFIED** — I did not locate a maintained Lean 4 port; searches returned only the paper and FFL) | — |
| `catskillsresearch/hybrid_logic_lean_revisited` + arXiv 2606.19761, "Finishing Oltean's Completeness Proof in Lean 4 for Hybrid Logic L(∀)" | hybrid logic completeness (**UNVERIFIED** — surfaced by search, not fetched) | possibly relevant to nominal/`@`-style reasoning |

### 7.2 Temporal logic in Lean 4

| Project | What it does | Idea |
|---|---|---|
| `LeanLTL` (UCSC Formal Methods; arXiv 2507.01780; ITP 2025 paper) | A unifying framework for LTL and LTLf over finite and infinite traces, with embeddings of both into a common core, plus a `PushLTL` tactic. Tree VERIFIED via `gh api`: `LeanLTL/{Init,ForMathlib}.lean`, `LeanLTL/Trace/{Defs,Basic}.lean`, `LeanLTL/TraceFun/{Defs,Basic,Operations}.lean`, `LeanLTL/TraceSet/{Defs,Basic,Notation,ToFun}.lean`, `LeanLTL/Logics/{LTL,LTLf,LTLfMT,Notation}.lean`, `LeanLTL/Tactic/PushLTL.lean`, `LeanLTL/Util/SimpAttrs.lean`, plus a separate `LeanLTLExamples/` library | **Three ideas.** (a) *One semantic core, several object logics as embeddings* — `Trace`/`TraceSet`/`TraceFun` is the core, `Logics/LTL.lean` and `Logics/LTLf.lean` are thin. The TM analogue: one `TaskFrame`/history core, four frame classes as thin instantiations — the same argument as §4 P1 from a different direction. (b) *A dedicated `Util/SimpAttrs.lean`* declaring the library's own simp sets, which the repo's `Automation/` layer would benefit from. (c) *A separate examples library* (`LeanLTLExamples`) rather than examples inside the main library — compare `FormalSystem/Examples/`, which is inside the default build target |
| `mrigankpawagi/LeanearTemporalLogic` | LTL syntax/semantics, transition systems, LT properties (**UNVERIFIED** — search result, not fetched) | — |
| Kamp's theorem | No Lean formalization found (**UNVERIFIED negative**). The target repo has `Metalogic/WeakCanonical/Kamp/`, which would then be novel | — |

### 7.3 Mathlib order theory the repo could (further) reuse

**Already correctly reused — record this as a positive, not a gap.**
`FormalSystem/Semantics/DurationClassification.lean` imports
`Mathlib.GroupTheory.ArchimedeanDensely` and `Mathlib.Order.SuccPred.Archimedean`, and its
`complete_duration_discrete_or_dense` (`:157`) / `complete_not_dense_iso_int` (`:173`) sit directly
on top of Mathlib's:

- `LinearOrderedAddCommGroup.discrete_or_denselyOrdered` — `Mathlib/GroupTheory/ArchimedeanDensely.lean:230`
  — `Nonempty (G ≃+o ℤ) ∨ DenselyOrdered G` for `[AddCommGroup G] [LinearOrder G] [IsOrderedAddMonoid G] [Archimedean G]`
- `LinearOrderedAddCommGroup.discrete_iff_not_denselyOrdered` — same file `:250` — the exclusivity
- `LinearOrderedAddCommGroup.isAddCyclic_iff_not_denselyOrdered` — `:265`
- `LinearOrderedAddCommGroup.int_orderAddMonoidIso_of_isLeast_pos` — `:187` — the `≃+o ℤ` builder
- `Archimedean.of_locallyFiniteOrder` — `:215`

The file's own docstring is exemplary about what it does *not* prove (the `≃+o ℝ` packaging) and
records the exact four-step composition path through
`Archimedean.exists_orderAddMonoidHom_real_injective` (`Mathlib/Data/Real/Embedding.lean`) and
`AddSubgroup.dense_or_cyclic` (`Mathlib/Topology/Algebra/Order/Archimedean.lean`). Both paths are
plausible but I did **not** verify those two Mathlib declarations exist under those names —
**UNVERIFIED**, worth a five-minute check.

**The one gap it names itself:** "That file carries a `private` copy of the same Archimedean
argument (`arch_of_lub`)" in `Metalogic/SoundnessLemmas/Separability.lean`. Deduplicate against
`archimedean_of_lub` (`DurationClassification.lean:125`). See finding G-13.

---

## 8. Publication packaging recipe (Q7)

Reference layout: `teorth/pfr` (VERIFIED via `gh api`) — root carries `CITATION.cff`, `README.md`,
`PFR.lean` (aggregator), `blueprint/{src/chapter/*.tex, src/plastex.cfg, src/latexmkrc, requirements.txt}`,
`.github/workflows/{push,update,lean-release-tag}.yml`. `leanprover-community/docgen-action`
(README fetched, VERIFIED) does the doc-gen4 + Jekyll + blueprint build and Pages deploy.

Minimal recipe for this repository, in dependency order:

**Step 1 — a linter root (0.5 day).** Add `FormalSystem/Init.lean` importing `Mathlib.Init` plus
any repo-specific linter config, make every `FormalSystem/**` file import it, and add a
`checkInitImports`-style script. Model: `Cslib/Init.lean` + `scripts/CheckInitImports.lean`.

**Step 2 — turn CI on (0.5 day).** Delete the `[ci]`-gated `if:` from
`.github/workflows/ci.yml`, set `lint: true` on `leanprover/lean-action@v1`, and add `#lint` /
`lake exe mk_all` / `lake exe lint-style` steps modelled on CSLib's `weekly-lints.yml`.

**Step 3 — `references.bib` (0.5 day).** The repo cites Reynolds, Blackburn–de Rijke–Venema, Kamp
and others in prose (e.g. `ProofSystem/Axioms.lean`'s `sep` docstring quotes a printed page). Move
those into a root `references.bib` and cite as `[Reynolds2003]` in `## References` sections; this
is what `docgen-action`'s `references` input (default `references.bib`) consumes.

**Step 4 — doc-gen4 on Pages (0.5 day).** Settings → Pages → Source: GitHub Actions, then append
to the build workflow:

```yaml
permissions:
  contents: read
  id-token: write
  pages: write

- name: Build project documentation
  uses: leanprover-community/docgen-action@main
  with:
    blueprint: false      # flip to true once step 6 exists
    api-docs: true
    references: references.bib
```

Output lands at `https://<user>.github.io/<repo>/docs`.

**Step 5 — a "Main results" page + axiom audit (1 day).** A single
`FormalSystem/MainResults.lean` (or a `docs/` Jekyll page generated from one) that `import`s the
headline theorems, restates them as `example`s or `#check`s, and runs `#print axioms` on each. The
repo already does exactly this locally in `Metalogic/DiscreteNonCompactness.lean:292-312` and
`Metalogic/DedekindNonCompactness.lean:473-490` — generalize that pattern to soundness,
completeness, compactness, decidability and the two refutations, in one file, with the verbatim
axiom output recorded as it already is. This is the single highest-value artefact for a referee.

**Step 6 — `CITATION.cff` (1 hour) and, optionally, `leanblueprint` (1–2 weeks).** The blueprint is
worth it only if the LaTeX/Typst sources under `typst/` and `latex/` are to become the paper; if so,
`blueprint/src/` + `blueprint: true` links every informal statement to its formal counterpart.
There is already a `lake exe machine_appendix` target emitting a machine-readable axiomatization
appendix (`lakefile.lean`), which is halfway to a blueprint's `\lean{}` annotations.

**Step 7 — clean the `lakefile.lean` (2 hours).** Eleven of its twelve `lean_exe` docstrings end
with a parenthesized reference to an internal tracker item. Those are ephemeral task-management
metadata sitting in a deliverable file that ships to users; per the repository's own
`no-task-references-in-deliverables` rule they should be replaced with durable descriptions of what
each executable produces.

---

## 9. Findings

### G-01. `SatisfiableSet` should carry a bundled model witness
- **Severity**: High
- **Category**: abstraction
- **Source**: `Mathlib/ModelTheory/Bundled.lean:73` (`structure ModelType`), `:93` (`ModelType.of`); `Mathlib/ModelTheory/Satisfiability.lean:65` (`IsSatisfiable := Nonempty (ModelType T)`), `:78` (`IsSatisfiable.mono`)
- **Anchors in repo**: `FormalSystem/Metalogic/SetConsequence.lean:154` (`SatisfiableSet`), `:301,307,317,327` (four `*_of_forall` constructors)
- **Recommendation**: introduce `structure PointedModel (fc : FrameClass) (Γ : Set Formula)` bundling frame + class-membership + model + total history + time + the truth condition, define `SatisfiableSet fc Γ := Nonempty (PointedModel fc Γ)`, and replace the four `*_of_forall` constructors with one `PointedModel.of`. Signature in §2.2.
- **Effort**: M

### G-02. Four-way per-frame-class duplication of parametric definitions
- **Severity**: High
- **Category**: abstraction
- **Source**: `Mathlib/ModelTheory/Satisfiability.lean` (one `IsSatisfiable`, no per-theory copies); `FormalizedFormalLogic/ModalLogic` `ModalLogicArchive/Modal/Kripke/Logic/S5.lean` (four instances per logic, zero copied theorems)
- **Anchors in repo**: `FormalSystem/Metalogic/SetConsequence.lean:107` defines `SetSemanticConsequenceOn fc` and lines `:112,116,121,126` immediately specialize it four ways; `:222-289` are eight hand-copied `.of_forall`/`.apply` lemmas; `:360-381` four `_mono` lemmas; `:449-469` and onward the `*Base`/`*Dense` families. `FormalSystem/Metalogic/StrongCompleteness.lean` repeats the pattern for `SemanticConsequence*`, `semantic_deduction_*`, `consequence_completeness_*`, `soundness_*_consequence`, `completeness_*`. Repo-wide: 123 top-level declarations whose name ends in a frame-class tag; the largest tag-suffixed families are `SetSemanticConsequence<FC>` (59 occurrences), `SemanticConsequence<FC>` (57), `Compact<FC>` (53), `StrongCompleteness<FC>` (43), `ModelExistence<FC>` (20)
- **Recommendation**: keep exactly one parametric definition per concept (`SetSemanticConsequenceOn fc`, `Compact fc`, `StrongCompleteness fc`, `ModelExistence fc` — all four already exist), demote the per-tag names to `abbrev`s where a short name is genuinely wanted, and state each `.of_forall` / `.apply` / `_mono` **once**, generic in `fc`. Expected deletion: on the order of 40–60 declarations with no loss of statement strength.
- **Effort**: M

### G-03. State compactness as an iff with finite satisfiability
- **Severity**: Medium
- **Category**: api-ergonomics
- **Source**: `Mathlib/ModelTheory/Satisfiability.lean:100` (`isSatisfiable_iff_isFinitelySatisfiable`), `:95` (the trivial direction, one line)
- **Anchors in repo**: `FormalSystem/Metalogic/SetConsequence.lean:175` (`Compact`), `FormalSystem/Metalogic/Compactness.lean:143,146` (`compactBase`, `compactDense`)
- **Recommendation**: add `FinitelySatisfiableSet` and `SatisfiableSet.finitelySatisfiable` (one line, `fun _ => h.mono`), then restate `Compact fc` so the headline theorem is a biconditional. The reverse direction is the existing content; the forward direction makes the statement self-describing and quotable in a paper.
- **Effort**: S

### G-04. Adopt `Sound` / `Canonical` / `Complete` typeclasses indexed by frame class
- **Severity**: High
- **Category**: abstraction
- **Source**: `FormalizedFormalLogic/ModalLogic`, `ModalLogicArchive/Modal/Kripke/Logic/S5.lean` (fetched verbatim; four `instance` lines give soundness, consistency, canonicity and completeness, with `Complete Modal.S5 FrameClass.S5 := inferInstance`)
- **Anchors in repo**: `FormalSystem/Metalogic/StrongCompleteness.lean:587` (`completeness_dedekind`), `:688` (`completeness_base`), `:822` (`completeness_dense`), `:525,675,805` (`soundness_*_consequence`)
- **Recommendation**: define `class Sound (fc : FrameClass)`, `class Canonical (fc : FrameClass)`, `class Complete (fc : FrameClass)`, prove `instance [Canonical fc] : Complete fc` once from the generic canonical-model construction, and reduce each class's file to instance declarations. Pair with G-05.
- **Effort**: L

### G-05. Frame properties as classes; frame-class inclusion as instances
- **Severity**: Medium
- **Category**: abstraction
- **Source**: `ModalLogicArchive/Modal/Kripke/Logic/S5.lean` — `protected class Frame.IsS5 extends F.IsReflexive, F.IsEuclidean`; `protected abbrev FrameClass.S5 : FrameClass := { F | F.IsS5 }`; `instance [F.IsS5] : F.IsKD45 where`
- **Anchors in repo**: `FormalSystem/ProofSystem/Axioms.lean:531` (the `FrameClass` inductive), `:537-570` (hand-written `LE` match, `DecidableRel`, `PartialOrder` with a 64-case `le_trans`, and eight `example … by decide` order-shape regression checks). Existing `TaskFrame.Is<FC>` (22 occurrences) and `TaskFrame.IsSuccArch<FC>` (42) families
- **Recommendation**: keep the inductive `FrameClass` — `DerivationTree` genuinely needs a `DecidableEq` index — but move the *semantic* side to `TaskFrame.IsDense` / `IsDiscrete` / `IsDedekind` classes with `instance [F.IsDedekind] : F.IsDense`, so instance resolution carries the inclusion order. The eight `by decide` regression examples then become redundant, and the `Discrete`/`Dedekind` incomparability is expressed by the absence of an instance rather than a `False` branch.
- **Effort**: L

### G-06. `Th`/`Mod` is a Mathlib `GaloisConnection` into `OrderDual`
- **Severity**: High
- **Category**: abstraction
- **Source**: `Mathlib/RingTheory/Spectrum/Prime/Basic.lean:185` (`PrimeSpectrum.gc`), `Mathlib/RingTheory/Nullstellensatz.lean:87` (built by `GaloisConnection.monotone_intro`); `Mathlib/Order/GaloisConnection/Defs.lean:41,56,62,78,82,103,121,139,153`; `Mathlib/Order/GaloisConnection/Basic.lean:91,102,109`
- **Anchors in repo**: `FormalSystem/Semantics/Correspondence/Galois.lean:93-139` (`Th`, `Mod`, `th_anti`, `mod_anti`, `subset_mod_th`, `subset_th_mod`, `mod_th_mod`, `th_mod_th`, `galoisClosed_mod`). Zero `GaloisConnection` occurrences repo-wide
- **Recommendation**: add `theorem mod_th_gc : @GaloisConnection (Set Formula) (Set TaskFrame)ᵒᵈ _ _ Mod Th := GaloisConnection.monotone_intro …` and derive the six round-trip lemmas from it (table in §3.2). Keep `galoisClosed_of_indicator`, `AxiomSet` and `densitySchema` — those are the file's real content. The gain is not the six deleted lines but the free `l_sup` / `l_iSup` / `u_top` / `lt_iff_lt` API for the `Metalogic/Independence/` sandwich work.
- **Effort**: S

### G-07. Missing module docstrings and `## Tags` sections
- **Severity**: Low
- **Category**: documentation
- **Source**: `leanprover-community.github.io/contribute/doc.html` (VERIFIED fetch)
- **Anchors in repo**: `FormalSystem/Metalogic/WeakCanonical.lean`, `FormalSystem/Metalogic/Decidability.lean`, `FormalSystem/Metalogic/WeakCanonical/RealModel/OrderIsoReal.lean`, `FormalSystem/Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge.lean` (no `/-!` block in the first 40 lines); `## Tags` absent repo-wide, including `FormalSystem/Semantics/Validity.lean` and `FormalSystem/Semantics/Correspondence/Galois.lean`
- **Recommendation**: add the four missing module docstrings; add a `## Tags` line to the ~30 files a reader would search for (`modal logic, temporal logic, Kripke semantics, completeness, compactness, Galois connection, ultraproduct`). doc-gen4's search indexes these.
- **Effort**: S

### G-08. No linter root and no `#lint` in CI
- **Severity**: Medium
- **Category**: organization
- **Source**: `Mathlib/Init.lean` (local, VERIFIED — imports 25 linters from `Mathlib/Tactic/Linter/`, of which 30 files exist); CSLib `Cslib/Init.lean` + `scripts/CheckInitImports.lean` + `CONTRIBUTING.md` §Linting (fetched, VERIFIED)
- **Anchors in repo**: `.github/workflows/ci.yml` (`lint: false`, and the `if:` that skips CI on push unless the message contains `[ci]`); `FormalSystem.lean` is an aggregator, not a linter root
- **Recommendation**: add `FormalSystem/Init.lean` importing `Mathlib.Init`, require it from every file with a `checkInitImports`-style script, enable `lint: true` on `leanprover/lean-action@v1`, and drop the `[ci]` gate. `docBlame`/`docBlameThm` will then surface the ~647 undocumented declarations from G-12 continuously rather than as a one-off audit.
- **Effort**: M

### G-09. Repository furniture: `references.bib`, `ORGANISATION.md`, `NOTATION.md`, `CITATION.cff`
- **Severity**: Medium
- **Category**: organization
- **Source**: `leanprover/cslib` root tree (fetched, VERIFIED: `ORGANISATION.md`, `NOTATION.md`, `GOVERNANCE.md`, `references.bib`, per-directory `README.md`); `teorth/pfr` root tree (fetched, VERIFIED: `CITATION.cff`, `blueprint/`); CSLib `CONTRIBUTING.md` ("please reference the resource in your documentation")
- **Anchors in repo**: no `references.bib`, no `CITATION.cff`; `docs/` exists with subdirectories but no doc-gen4 output; `FormalSystem/Semantics/Correspondence/README.md` shows the per-directory README habit is already present
- **Recommendation**: add `references.bib` (Reynolds, Blackburn–de Rijke–Venema, Kamp, Prior — all already cited in prose, e.g. `ProofSystem/Axioms.lean`'s `sep` docstring), `CITATION.cff`, and a root `ORGANISATION.md` explaining the `Syntax` / `ProofSystem` / `Semantics` / `Metalogic` / `Automation` layering and the one documented `Semantics → ProofSystem` edge.
- **Effort**: S

### G-10. `#print axioms` discipline is a strength — generalize it into one publishable page
- **Severity**: Medium
- **Category**: documentation
- **Source**: repo practice, plus `leanprover-community/docgen-action` README (fetched, VERIFIED) for the hosting mechanism
- **Anchors in repo**: `FormalSystem/Metalogic/DiscreteNonCompactness.lean:292-312`, `FormalSystem/Metalogic/DedekindNonCompactness.lean:473-490` (six `#print axioms` each, with verbatim output recorded in a following docstring)
- **Recommendation**: create one `FormalSystem/MainResults.lean` restating soundness, completeness (per class), compactness, decidability and the two refutations, each followed by `#print axioms`, with the output recorded as those two files already do. Then wire `docgen-action` so the page is public. This is the artefact a referee reads first.
- **Effort**: S

### G-11. Normalize `lemma` → `theorem`
- **Severity**: Low
- **Category**: naming
- **Source**: Mathlib practice (`theorem` throughout; `lemma` exists only via `Mathlib.Tactic.Lemma`, imported in `Mathlib/Init.lean`); `leanprover-community.github.io/contribute/style.html` draws no distinction
- **Anchors in repo**: 141 `lemma` + 1 `private lemma` against 7,031 `theorem` + 1,082 `private theorem`
- **Recommendation**: mechanical rename of the 142. Zero semantic effect; removes a "is this distinction meaningful?" question from every reader.
- **Effort**: S

### G-12. ~7% of declarations lack docstrings
- **Severity**: Medium
- **Category**: documentation
- **Source**: `leanprover-community.github.io/contribute/doc.html` — "Every definition and major theorem is required to have a doc string"; enforced by `docBlame` / `docBlameThm`
- **Anchors in repo**: 647 of 8,982 `theorem`/`def`/`structure`/`inductive`/`class`/`abbrev`/`instance` declarations have no `/-- -/` in the three lines above them (script-measured; the count over-reports for declarations documented by an enclosing `/-! -/` section comment, so treat it as an upper bound)
- **Recommendation**: land G-08 first so `#lint only docBlame docBlameThm` produces the authoritative list, then work it down. Prioritize `def`s over `theorem`s — Mathlib's own bar is "every definition and *major* theorem".
- **Effort**: L

### G-13. Deduplicate the Archimedean argument
- **Severity**: Low
- **Category**: math-insight
- **Source**: `Mathlib/GroupTheory/ArchimedeanDensely.lean:230` (`LinearOrderedAddCommGroup.discrete_or_denselyOrdered`), `:250`, `:265`, `:187`, `:215` — all VERIFIED locally
- **Anchors in repo**: `FormalSystem/Semantics/DurationClassification.lean:125` (`archimedean_of_lub`) and its own header, which records that `FormalSystem/Metalogic/SoundnessLemmas/Separability.lean` carries a `private` copy named `arch_of_lub`
- **Recommendation**: delete the private copy and import. Separately, verify the two Mathlib declarations the header's four-step composition path names (`Archimedean.exists_orderAddMonoidHom_real_injective` in `Mathlib/Data/Real/Embedding.lean`, `AddSubgroup.dense_or_cyclic` in `Mathlib/Topology/Algebra/Order/Archimedean.lean`) — I did not confirm either, and if they exist the "~100-200 line" `≃+o ℝ` gap the file scopes out may be considerably smaller than estimated.
- **Effort**: S

### G-14. Publication packaging is absent
- **Severity**: High (publication blocker)
- **Category**: organization
- **Source**: `leanprover-community/docgen-action` README (fetched, VERIFIED — exact YAML, inputs, permissions in §8); `teorth/pfr` tree (fetched, VERIFIED)
- **Anchors in repo**: `lakefile.lean` (no docs target), `.github/workflows/ci.yml` (build only), no `CITATION.cff`, no Pages deployment
- **Recommendation**: execute §8 steps 1–6. Steps 1–4 and 6a are under three days total and get a citable documentation site; the blueprint (6b) only if `typst/`/`latex/` become the paper.
- **Effort**: M

### G-15. `assert_not_exists` would make the documented import seam machine-checked
- **Severity**: Low
- **Category**: organization
- **Source**: `assert_not_exists` appears in 889 Mathlib files (VERIFIED by `grep -rl`)
- **Anchors in repo**: `FormalSystem/Semantics/Correspondence/Galois.lean` "## Import seam" section argues in prose that `Validity.lean` → `FrameClassValidity.lean` is "the single documented `Semantics → ProofSystem` edge" and that no new seam is opened here; `FormalSystem/Semantics/FrameClassValidity.lean:58` records a related layering decision, also in prose
- **Recommendation**: add `assert_not_exists` lines naming the `ProofSystem` declarations that must *not* be reachable from the lower `Semantics` files. Turns two carefully-argued docstring paragraphs into build-time invariants.
- **Effort**: S

### G-16. Adopt CSLib conventions if contribution there is a goal
- **Severity**: Low
- **Category**: organization
- **Source**: `leanprover/cslib` `ORGANISATION.md` (fetched, VERIFIED — lists `Cslib.Logic.LinearTemporalLogic` as a planned directory that does not yet exist in the tree); `CONTRIBUTING.md` §"Before you start" (major developments should be discussed on Zulip first); `Cslib/Logics/README.md` (instantiate `InferenceSystem` and `LogicalEquivalence`; per-logic judgement notation tags; proof systems in `Type` not `Prop`)
- **Anchors in repo**: `FormalSystem/ProofSystem/Derivation.lean` (`DerivationTree` is already `Type`-valued, matching CSLib's stated default, which is what makes `FormalSystem/Automation/ProofStepExtractor.lean` possible)
- **Recommendation**: the temporal fragment of TM is a plausible fit for CSLib's open `LinearTemporalLogic` slot, and `Cslib/Foundations/Data/OmegaSequence/Temporal.lean` plus the ω-automata directory are the natural neighbours. If pursued, open a Zulip thread first as `CONTRIBUTING.md` requires, and expect to instantiate `Cslib.Logic.InferenceSystem` and use a `TM[...]` judgement notation tag. Independent of any contribution decision, the notation-tag convention is worth adopting locally, since the repo carries four `⊨`-shaped consequence relations.
- **Effort**: M (contribution) / S (notation convention only)

---

## 10. Sources

### Local Mathlib (`/home/benjamin/Projects/BimodalLogic/.lake/packages/mathlib/Mathlib/`), all VERIFIED by `ls`/`grep`/`sed`
- `ModelTheory/Satisfiability.lean` — lines 65, 69, 74, 78, 95, 100–118, 278, 296, 368, 385, 455, 458, 461, 469
- `ModelTheory/Bundled.lean` — lines 73, 88, 93, 100, 166, 179
- `ModelTheory/Semantics.lean` — lines 630, 703, 727, 732, 737, 754, 772
- `ModelTheory/Ultraproducts.lean` — lines 49, 74, 95, 146, 154
- `ModelTheory/` directory listing (Basic, Syntax, Semantics, Satisfiability, Ultraproducts, Complexity, Bundled, ElementaryMaps, Definability, Fraisse, Skolem, Types, … all present)
- `Order/GaloisConnection/Defs.lean` — lines 41, 56, 62, 70, 74, 78, 82, 103, 111, 117, 121, 139, 143, 153, 205, 219, 243, 302
- `Order/GaloisConnection/Basic.lean` — lines 1–60 (module docstring), 91 (`l_sup`), 102 (`l_iSup`), 109 (`l_iSup₂`)
- `Order/Closure.lean` — lines 60, 127, 132, 136, 176, 186, 196, 262, 309, 336, 362, 381, 395, 519, 527, 543
- `RingTheory/Spectrum/Prime/Basic.lean` — lines 185 (`gc`), 192 (`gc_set`), 205, 232
- `RingTheory/Nullstellensatz.lean` — lines 75–92
- `GroupTheory/ArchimedeanDensely.lean` — lines 187, 215, 230, 250, 265, 274, 303
- `Init.lean` — the linter import set
- `Tactic/Linter/` — 30 linter files including `DocString.lean`, `Style.lean`, `Header.lean`, `MinImports.lean`
- `assert_not_exists` present in 889 files (`grep -rl`)
- **UNVERIFIED**: `Mathlib/Data/Real/Embedding.lean` `Archimedean.exists_orderAddMonoidHom_real_injective`; `Mathlib/Topology/Algebra/Order/Archimedean.lean` `AddSubgroup.dense_or_cyclic` — cited in the repo's own docstring, not checked by me

### Target repository (`/home/benjamin/Projects/BimodalLogic/`), all VERIFIED
- `FormalSystem/Semantics/Correspondence/Galois.lean` — full read
- `FormalSystem/Semantics/Validity.lean` — header
- `FormalSystem/Semantics/DurationClassification.lean` — header + declaration list
- `FormalSystem/Metalogic/SetConsequence.lean`, `Metalogic/StrongCompleteness.lean`, `Metalogic/Compactness.lean` — declaration lists
- `FormalSystem/Semantics/Ultraproduct/{Carrier,IndexFilter,Los,ShiftSetProduct}.lean` — declaration lists
- `FormalSystem/ProofSystem/Axioms.lean:525-600` — `FrameClass` inductive, `LE`, `PartialOrder`, order regression examples, `Axiom.minFrameClass`
- `FormalSystem/Metalogic/{DiscreteNonCompactness,DedekindNonCompactness}.lean` — `#print axioms` blocks
- `lakefile.lean`, `.github/workflows/ci.yml`, `FormalSystem.lean`
- Repo-wide counts: 434 non-Boneyard `.lean` files; 4 without module docstrings; 1 without copyright; 7,031 `theorem` / 141 `lemma`; 8,982 declaration-shaped lines with 647 lacking an immediately-preceding docstring; 123 declarations with a frame-class-suffixed name; zero `GaloisConnection`, zero `assert_not_exists`, zero `#lint`

### GitHub, fetched via `gh api` (VERIFIED)
- `leanprover/cslib` — full `main` tree; `CONTRIBUTING.md`; `ORGANISATION.md`; `Cslib/Init.lean`; `Cslib/Logics/README.md`; `Cslib/Foundations/Logic/InferenceSystem.lean`; `Cslib/Logics/Modal/Basic.lean`
- `FormalizedFormalLogic/Foundation` — full `master` tree (285 entries; no `Foundation/Modal`)
- `FormalizedFormalLogic` org repo list (20 repos with descriptions and push dates)
- `FormalizedFormalLogic/ModalLogic` — full `master` tree (798 entries); `ModalLogicArchive/Modal/Kripke/Basic.lean`; `ModalLogicArchive/Modal/Kripke/Completeness.lean`; `ModalLogicArchive/Modal/Kripke/Logic/S5.lean`; `ModalLogicArchive/Logic/Semantics.lean`; `Neighborhood/Semantics/Basic.lean` (outline)
- `teorth/pfr` — root tree and `.github/workflows/` listing
- `UCSCFormalMethods/LeanLTL` — full `main` tree

### Web (fetched, VERIFIED)
- https://leanprover-community.github.io/contribute/style.html
- https://leanprover-community.github.io/contribute/naming.html
- https://leanprover-community.github.io/contribute/doc.html
- https://github.com/leanprover-community/docgen-action
- https://github.com/leanprover/cslib

### Web (search results only, NOT fetched — UNVERIFIED)
- https://arxiv.org/abs/2507.01780 — LeanLTL paper; https://drops.dagstuhl.de/entities/document/10.4230/LIPIcs.ITP.2025.37 — ITP 2025 version
- https://github.com/mrigankpawagi/LeanearTemporalLogic
- https://arxiv.org/pdf/2606.19761 — "Finishing Oltean's Completeness Proof in Lean 4 for Hybrid Logic L(∀)"
- https://github.com/catskillsresearch/hybrid_logic_lean_revisited
- https://formalizedformallogic.github.io/Book/ — FFL documentation site
- https://arxiv.org/abs/2602.04846 (CSLib whitepaper), https://arxiv.org/abs/2602.15078 ("Computer Science as Infrastructure") — cited in CSLib's `CONTRIBUTING.md`
- https://github.com/PatrickMassot/leanblueprint
- Bentzen, "A Henkin-style completeness proof for the modal logic S5" — paper located by search; no maintained Lean 4 port found
