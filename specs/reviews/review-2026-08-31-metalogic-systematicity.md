# Code Review Report

**Date**: 2026-08-31
**Scope**: Metalogic infrastructure — soundness, completeness, compactness, frame characterization, and the structure of frame validity
**Reviewed by**: Claude

## Summary

- Total files reviewed: 471 live `.lean` files surveyed; 18 read in detail
- Critical issues: 0
- High priority issues: 3
- Medium priority issues: 4
- Low priority issues: 2

**Headline.** The tree is in far better *verification* health than its metrics suggest: `lake build`
exits 0, `check-module-invariants.sh` passes every check, and C3 asserts a **structural sorry
inventory of ZERO** across `FormalSystem/` outside `Boneyard/`. The 989 grep-level `sorry` hits are
all documentation prose.

The real deficits are **architectural, not evidential**. They reduce to one root cause:

> The **proof side is fully parameterized by `FrameClass`; the semantic side is not.**
> `Derivable (fc : FrameClass)` is a single relation with a `PartialOrder` and a monotonicity
> `lift`. Validity is 15 hand-copied predicates with no index, and every downstream
> notion — semantic consequence, soundness, set-consequence, compactness, strong
> completeness — is duplicated once per frame class beneath it.

Everything below is a consequence of that asymmetry, and the user's stated goal (derive strong
completeness from compactness + weak completeness, uniformly) is *already the settled
architecture* — it is simply implemented three times by hand with the fourth row missing.

---

## High Priority Issues

### H1. The semantic layer is not indexed by `FrameClass`, while the proof layer is

**File**: `FormalSystem/Metalogic/SetConsequence.lean:72` vs `:79,:87,:97,:106`

**Description**: The proof side is exemplary and already does what the semantic side does not:

| Construct | File:line | Parameterized? |
|---|---|---|
| `inductive FrameClass` (Base/Dense/Discrete/Dedekind) | `ProofSystem/Axioms.lean:531` | — |
| `PartialOrder FrameClass` | `ProofSystem/Axioms.lean:551` | yes |
| `Axiom.minFrameClass : Axiom φ → FrameClass` | `ProofSystem/Axioms.lean:~600` | yes ("single source of truth") |
| `DerivationTree (fc : FrameClass)` | `ProofSystem/Derivation.lean:91` | **yes** |
| `DerivationTree.lift : fc₁ ≤ fc₂ → …` | `ProofSystem/Derivation.lean:184` | **yes** |
| `Derivable (fc : FrameClass)` | `ProofSystem/Derivable.lean:69` | **yes** |
| `SetDerivable (fc : FrameClass)` | `Metalogic/SetConsequence.lean:72` | **yes** |
| `setDerivable_mono {fc : FrameClass}` | `Metalogic/SetConsequence.lean:118` | **yes** |
| — semantic side below — | | |
| `valid`, `ValidDense`, `ValidDiscrete`, `ValidDedekind`, `ValidDedekindDense` | `Semantics/Validity.lean:94,206,248,301,336` | **no — 5 copies** |
| `SetSemanticConsequence{Base,Dense,Discrete,DedekindDense}` | `SetConsequence.lean:79,87,97,106` | **no — 4 copies** |
| `setSemanticConsequence*_mono` ×4 | `SetConsequence.lean:124,130,136,144` | **no — 4 copies** |

The clearest evidence sits inside a single 346-line file: `SetDerivable` is `fc`-indexed with one
monotonicity lemma, and directly beneath it four semantic-consequence definitions are written out
longhand with four copied monotonicity lemmas.

The four definitions are **byte-identical except for one binder line**:

```lean
def SetSemanticConsequenceBase (Γ : Set Formula) (φ : Formula) : Prop :=
  ∀ (D : Type) [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D] [Nontrivial D]
    (F : TaskFrame D) (M : TaskModel F) (τ : WorldHistory F) (_ : τ.IsTotal) (t : D),
    (∀ ψ ∈ Γ, TruthAt M τ t ψ) → TruthAt M τ t φ
--                              ^ these three lines are verbatim in all four
```

Only the typeclass binder list varies (`[DenselyOrdered D]`; `[SuccOrder D] [PredOrder D]
[IsSuccArchimedean D] [IsPredArchimedean D]`; a Prop-valued LUB hypothesis). Their own docstrings
already say so — each cross-references the `Valid*` whose binder list it copies.

**Full duplication tally (live code, `Boneyard/` excluded):**

- **15** validity predicates: 5 in `Semantics/Validity.lean`, 4 in `Semantics/BLValidity.lean`,
  1 `ValidInt` in `Semantics/IntTransfer.lean`, 5 in `FrameConditions/Validity.lean`
- **8** semantic-consequence variants: 4 set-level + `SemanticConsequence` +
  `SemanticConsequence{DedekindDense,Dense,Discrete}` (`StrongCompleteness.lean:171,719,828`)
- **~23** soundness theorems (see H2)
- **11** compactness-family definitions covering only 3 of 4 frame classes (see H3)

**Impact**: Adding a fifth frame class (or the two operator extensions already scoped as tasks
#127 and #128) requires touching every one of these sites. Worse, it is a *correctness* surface:
the `ValidDedekind` docstring already warns that "simplifying" `soundness_dedekind` to target it
would yield a refutable theorem — a hazard that only exists because the binder list is inlined
rather than derived from the frame class.

**Recommended fix**: Introduce a semantic interpretation of the existing proof-side tag —
`FrameClass → (carrier constraints on D)` — then define **once**: `ValidOn fc φ`,
`SetSemanticConsequence fc Γ φ`, and their monotonicity. Because `FrameClass` already carries a
`PartialOrder` and derivations already lift along it, the four hand-written
`valid_implies_valid_*` lemmas (`Validity.lean:349,356,364,371`) collapse into a single
`ValidOn`-monotonicity lemma pointing the same direction as `DerivationTree.lift`.

The missing ingredient already exists in the tree — see M1.

---

### H2. Soundness is proven once per logic, not once and instantiated

**File**: `FormalSystem/Metalogic/Soundness.lean:1100,1205,1274,1368,1420,1928,1947`

**Description**: Soundness is stated ~23 times across four files, all instances of one schema:

| File | Theorems |
|---|---|
| `Metalogic/Soundness.lean` | `soundness`, `soundness_dense`, `soundness_discrete`, `soundness_dedekind` + 3 `*_valid` variants |
| `Metalogic/StrongCompleteness.lean` | `soundness_{base,dense,discrete,dedekind}_consequence` (:524,:667,:771,:879) |
| `FrameConditions/Soundness.lean` | `soundness_over`, `soundness_linear`, `soundness_dense`, `soundness_discrete`, `soundness_Int` |
| `Metalogic/BaseLanguageSoundness.lean` | `bl_soundness{,_dense,_discrete,_dedekind}` + 4 `*_valid` variants (:168–:252) |

`FormalSystem/Metalogic/SoundnessLemmas/FrameClassVariants.lean` (1041 lines) exists specifically
to carry the per-frame-class variants of the axiom-validity lemmas.

**Impact**: This is the maintenance cost H1 predicts, realized. It is also why the BL layer
(`BaseLanguage/`) had to replicate the whole 4-fold pattern rather than inherit it.

**Recommended fix**: One theorem, `Derivable fc Γ φ → SetSemanticConsequence fc Γ φ`, by induction
on the derivation with the axiom case discharged from `Axiom.minFrameClass ≤ fc` plus a per-axiom
validity lemma. The existing 23 become one-line corollaries. The BL side already funnels through
`blValid_iff_valid_tr` (`BaseLanguageSoundness.lean:141`), so it collapses for free once the
`Formula` side is parameterized.

---

### H3. Strong completeness is stated but not discharged, and the Dedekind row does not exist

**File**: `FormalSystem/Metalogic/StrongCompleteness.lean:314,340`; `Metalogic/SetConsequence.lean:214–342`

**Description**: The architecture the user proposes — *strong completeness from compactness + weak
completeness* — is already built, correct, and **the settled plan of record**. What is missing is
the discharge and the fourth row.

Present and sorry-free:

- `strongCompletenessBase_of_compact (hc : CompactBase)` — `StrongCompleteness.lean:314`
- `strongCompletenessDense_of_compact (hc : CompactDense)` — `:340`
- `compactBase_of_modelExistence : ModelExistenceBase → CompactBase` — `:378`
- `compactDense_of_modelExistenceDense : ModelExistenceDense → CompactDense` — `:424`
- `discrete_consequence_not_compact : ¬ CompactDiscrete` — `DiscreteNonCompactness.lean:250`
- `strongCompletenessDiscrete_refuted : ¬ StrongCompletenessDiscrete` — `:280`

**Gap 1 — the chain is conditional.** `ModelExistenceBase` and `ModelExistenceDense` are
*unproven*. Therefore `CompactBase`/`CompactDense` are unproven, therefore
`StrongCompletenessBase`/`StrongCompletenessDense` are unproven. The paper's `cor:tm-completeness`
rows 1–2 assert them and attribute them to this repository. Tasks **#492 → #493** scope exactly
this (the ultraproduct/Łoś chain), and task #493's own description records the paper-side
correction as live until it lands.

**Gap 2 — the Dedekind row is entirely absent.** `SetConsequence.lean` defines, per class:

| Class | `StrongCompleteness_` | `Compact_` | `Satisfiable_Set` | `ModelExistence_` |
|---|---|---|---|---|
| Base | :214 | :222 | :230 | :245 |
| Dense | :262 | :269 | :277 | :291 |
| Discrete | :315 | — (:342 `CompactDiscrete`) | :329 | — (correctly absent: refuted) |
| **Dedekind** | **absent** | **absent** | **absent** | **absent** |

Task **#494** scopes this and correctly identifies it as a *refutation* target, noting the critical
constraint that the Discrete witness does not port (`archWitness` turns on `SuccOrder`/
`IsSuccArchimedean`; the Dedekind binder list has no successor).

**Gap 3 — the reductions are themselves duplicated.** `strongCompletenessBase_of_compact` and
`strongCompletenessDense_of_compact` are the same argument twice. Under H1's parameterization they
become one `strongCompleteness_of_compact (fc)`, and #494's Dedekind row becomes an
*instantiation* rather than a fourth hand-written copy.

**Impact**: The programme's headline claim is currently conditional, and the four-class picture the
roadmap describes ("strong completeness holds for Base/Dense, is IMPOSSIBLE for Discrete/Dedekind")
is only 3/4 represented in code.

**Recommended fix**: Land #492 → #493 for the discharge. **Sequence H1's parameterization before
#494**, or #494 will hand-write a fourth copy of a family that is about to be collapsed.

---

## Medium Priority Issues

### M1. `FormalSystem/FrameConditions/` is orphaned — and contains exactly the missing abstraction

**File**: `FormalSystem/FrameConditions/` (4 modules, 906 lines)

**Description**: Measured consumers of this directory outside itself: **one**, the library
aggregator `FormalSystem/FormalSystem.lean:13`. Nothing in `Metalogic/`, `Semantics/`,
`Theorems/`, or `Tests/` references any definition it exports.

Three findings compound:

1. **Silent regression.** Archived task #58 recorded "Wire completeness to FrameConditions —
   wiring is DONE: `completeness_over_Int`, `discrete_completeness_fc`, `dovetailed_bundle`." All
   three identifiers are **absent from the entire live tree today**. The wiring was removed and
   the claim was never retracted.

2. **It holds the key to H1.** `FrameConditions/FrameClass.lean` defines marker typeclasses
   `LinearTemporalFrame` (:88), `SerialFrame` (:103), `DenseTemporalFrame` (:124),
   `DiscreteTemporalFrame` (:148), `DedekindTemporalFrame` (:182) — precisely the
   "binder-list-as-a-predicate-on-`D`" that a `FrameClass`-indexed validity needs. Its own README
   describes the goal as "**Parameterized validity**: `ValidOver` that works with any temporal
   frame." The idea is right; it was built and never wired.

3. **It duplicates the axiom↔class relation.** `FrameConditions/Compatibility.lean:85,93,102`
   defines `AxiomLinearCompatible` / `AxiomDenseCompatible` / `AxiomDiscreteCompatible` with ~40
   hand-written per-axiom instances — while `Axiom.minFrameClass`'s docstring states it is "the
   single source of truth for axiom-frame-class compatibility" and that it "replaces the ad-hoc
   predicates `isBase`, `isDenseCompatible`, `isDiscreteCompatible`." Both encodings are live.

**Impact**: 906 lines of unconsumed code carrying a fourth validity vocabulary and a second
axiom-compatibility encoding. It is a maintenance liability *and* a half-finished version of the
fix for H1 — the worst of both.

**Recommended fix**: Decide explicitly. Either **promote** — make its marker typeclasses the
`FrameClass` interpretation in H1 and let the whole tree consume it — or **delete**. Its README
argues it should stay separate because it sits above `Metalogic/`; that argument is about
*placement* and does not address *zero consumers*. Under the promote path the layering inverts
anyway (the interpretation belongs beside `Semantics/Validity.lean`, below `Metalogic/`). The
`AxiomCompatible` instances should be deleted in either case, as `minFrameClass` supersedes them.

### M2. No frame correspondence or characterization infrastructure exists

**File**: (absent)

**Description**: There is no result anywhere in the live tree of the form *"axiom X is valid on
frame class C **iff** C satisfies condition Y."* Searching `correspond|characteriz|definabl|
Sahlqvist` across live code returns only: `chronicleMonadic_truth_correspondence`
(a chronicle/monadic bridge), `SetMaximalConsistent.ultrafilter_correspondence` (algebraic), and
the `*Definable*` family in `WeakCanonical/EFGames/` — which concerns *definable gaps* in the
Kamp/Ehrenfeucht-Fraïssé machinery, not axiom–frame correspondence.

What exists is the **soundness half only**:
- `Axiom.minFrameClass` declares the intended class per axiom (a definition, not a theorem).
- `SoundnessLemmas/` proves each axiom valid on its class (sufficiency).
- `Metalogic/Independence/` (`ClockFrame.lean`, `LoopingDuration.lean`, `CoNotPriorU.lean`) gives
  three ad hoc non-derivability countermodels — the closest thing to necessity, but per-axiom and
  not organized as a correspondence result.

The converse half — that each frame condition is *necessary*, i.e. the axiom fails on some frame
violating it — is nowhere established systematically. That is the "frame characterization ...
major results" this review's scope names, and it is genuinely absent rather than incomplete.

**Impact**: `Axiom.minFrameClass` is currently an *assertion* about the axiom–class relation with
only one direction proven. Without correspondence, "TM+_d is the logic of dense task frames" is
not a theorem the tree can state.

**Recommended fix**: Research task first — determine which of the 45 axioms admit a correspondence
argument and what the right general statement is for this bimodal setting (Sahlqvist-style
machinery may not transfer directly to task frames with `Until`/`Since`). Then a construction task.
Note task **#495** already asks the adjacent question for the BL language ("if TM is not complete
over task frames, characterize what it IS complete for") and should be sequenced alongside.

### M3. The BaseLanguage layer replicates the full 4-fold duplication

**File**: `FormalSystem/Semantics/BLValidity.lean:77,102,115,132`;
`FormalSystem/Metalogic/BaseLanguageSoundness.lean:168–252`

**Description**: `BLValid`, `BLValidDense`, `BLValidDiscrete`, `BLValidDedekindDense`, plus three
`blValid_implies_*` bridges (:153,:157,:162), plus 8 `bl_soundness*` theorems — the entire
`Formula`-side pattern, mirrored.

**Impact**: Doubles the cost of every change described in H1/H2.

**Recommended fix**: No independent work needed. `blValid_iff_valid_tr`
(`BaseLanguageSoundness.lean:141`) already reduces BL validity to `Formula` validity through the
translation `tr`; once `ValidOn fc` exists, `BLValidOn fc φ := ValidOn fc (tr φ)` collapses all
four definitions and all eight theorems. Fold this into H1/H2's task rather than scoping it apart.

### M4. `ROADMAP.md` Phase 1 is stale in three places

**File**: `specs/ROADMAP.md:53–105`

**Description**:
1. Phase 1 states "the expensive ultraproduct work itself is not yet scoped as tasks." It is now —
   tasks #492, #493, #494 scope it in detail.
2. Two open checkboxes describe tasks 169/95/422 as "proposed for abandonment, **not transitioned**
   by this rewrite ... status transition is a user decision." All three are now `abandoned` and
   archived. The checkboxes should close.
3. This is visible in the tooling: `roadmap-integration.sh` reports 25 open checkboxes and skipped
   22 candidate matches, all `low_confidence`, with 0 annotations applied across this review and
   the preceding `/todo` run.

**Impact**: The roadmap is the stated authority for programme status (this review relies on its
Phase 1 terminology ruling); stale entries there propagate into task planning.

**Recommended fix**: Refresh Phase 1. Low effort, no dependencies.

---

## Low Priority Issues

### L1. `repository_health` reports `critical` while every actual check passes

**File**: `specs/state.json` → `repository_health`

**Description**: `assess-repo-health.sh` reports `build_errors: 25`, `status: "critical"`. Meanwhile
`lake build` exits 0 (2501 jobs, one unused-variable linter warning) and
`check-module-invariants.sh --no-build` reports ALL CHECKS PASSED. The probe measures structural
soundness of shell/JSON files, not this project's build — as its own header documents — but the
field name and the `critical` status read as a build failure in `state.json` and in `/todo` output.

**Recommended fix**: Either scope the field name to what it measures, or have the probe defer to
`lake build` in Lean projects.

### L2. `docs/` carries 138 task-number citations

**File**: `docs/development/PHASED_IMPLEMENTATION.md` (100), `docs/training/PIPELINE.md` (11), others

**Description**: `check-module-invariants.sh` C9D reports these as TODO, not yet exit-code-affecting
(`ENFORCE_C9_DOCS=1` would enforce). Task numbers are renumbered by vault operations, so these
citations decay.

**Recommended fix**: Pre-existing debt, tracked by the invariant script. Clear opportunistically,
then set `ENFORCE_C9_DOCS=1`.

---

## Code Quality Metrics

| Metric | Value | Status |
|--------|-------|--------|
| `lake build` | exit 0, 2501 jobs | **Pass** |
| `check-module-invariants.sh --no-build` | ALL CHECKS PASSED | **Pass** |
| C3 structural sorry inventory | **0** across `FormalSystem/` (Boneyard excluded) | **Pass** |
| Grep-level `sorry` hits (all prose) | 989 total / 334 outside `Boneyard/` | Info |
| Live `.lean` files | 471 (416 FormalSystem / 54 Tests) | Info |
| Unreachable live modules | 17 (all manifested) | OK |
| TODO / FIXME count | 5 / 0 | OK |
| Linter warnings | 1 (`DatasetGenerator.lean:2269`, unused `q`) | Info |
| Validity predicates (should be 1 indexed family) | 15 | **Warning** |
| Soundness theorems (should be 1 + corollaries) | ~23 | **Warning** |
| Compactness matrix coverage | 3 of 4 frame classes | **Warning** |
| Orphaned modules | `FrameConditions/` — 906 lines, 0 consumers | **Warning** |

## Roadmap Progress

### Current Focus

| Phase | Priority | Current Goal | Progress |
|-------|----------|--------------|----------|
| Phase 1 | Low (weak DONE) | Strong-completeness capstone | 5/7 checkboxes |
| Phase 2 | High | Decidability / tableau engine | largest open front |
| Phase 3 | Low | Kamp theorem | DONE |
| Phase 4 | Medium | FMP and decidable model checking | open |
| Phase 5 | Medium | Publication and documentation | open |

### Roadmap Signal

- **Structure**: 7 phases, 39 checkboxes, 60 table rows — parseable: true
- **Warnings**: none
- **Skipped**: 22 items skipped — reasons: `low_confidence` (all)
- **Annotations applied**: 0 (this review and the preceding `/todo` run both applied none;
  no archived task populated `completion_data.roadmap_items`)

### Recommended Next Tasks

1. Parameterize validity by `FrameClass` (Phase 1, High) — unblocks 2–4
2. Parameterize soundness over the indexed validity (Phase 1, High)
3. Resolve `FrameConditions/`: promote or delete (Phase 7, Medium)
4. Parameterize the compactness / strong-completeness family; sequence **before** #494 (Phase 1, High)
5. Research frame correspondence for the 45-axiom set (Phase 1, Medium)

---

## Recommendations

**1. Do the parameterization before the remaining compactness work, not after.**
Tasks #492/#493/#494 are well-scoped and correctly grounded, and #494 in particular is ready to run
today. But #494's deliverable is explicitly "define the missing vocabulary in `SetConsequence.lean`
**mirroring** the Base/Dense/Discrete groups" — i.e. write a fourth hand copy of the family this
review recommends collapsing. Landing the parameterization first turns #494's Part 1 from four new
definitions into one instantiation, and leaves its genuinely hard Part 2 (a new non-compactness
witness that does not rely on successors) untouched.

**2. Treat `Axiom.minFrameClass` as the semantic pivot.** It is already declared the single source
of truth for the axiom↔class relation and is already the side condition on `DerivationTree`'s axiom
constructor. Giving `FrameClass` a semantic interpretation makes it the pivot on *both* sides, which
is what makes one soundness theorem possible and what would eventually make correspondence (M2)
statable.

**3. Resolve `FrameConditions/` as part of the parameterization, not separately.** It is not merely
dead code — it is a previous, unwired attempt at exactly this refactor. Deciding it independently
risks either deleting the marker typeclasses that the refactor needs, or preserving a fourth
validity vocabulary alongside a new fifth one.

**4. The existing task set is strong; the gap is upstream of it.** #492/#493/#494/#495/#500 are
detailed, evidence-grounded, and correctly sequenced among themselves. No existing task addresses
validity parameterization, the soundness collapse, the orphaned `FrameConditions/` layer, or frame
correspondence — verified by scanning all 38 active and 433 archived task descriptions. Those are
the additions this review proposes.

**5. Nothing here warrants abandonment.** The three tasks the roadmap proposed for abandonment
(169, 95, 422) are already abandoned and archived. No active task was found to be redundant,
superseded, or misaligned with the stated aims.
