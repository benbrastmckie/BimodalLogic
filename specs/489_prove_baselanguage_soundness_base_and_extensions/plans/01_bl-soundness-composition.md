# Implementation Plan: BL (TM) Soundness by Composition

- **Task**: 489 - Prove soundness for the BaseLanguage (BL) proof system at `FrameClass.Base` and its Dense/Discrete/Dedekind extensions
- **Status**: [COMPLETED]
- **Effort**: 6 hours
- **Dependencies**: None (research complete; all obligations prototype-verified)
- **Research Inputs**: `specs/489_prove_baselanguage_soundness_base_and_extensions/reports/01_bl-soundness-by-composition.md`
- **Artifacts**: plans/01_bl-soundness-composition.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: true

## Overview

Define a native BL semantics `BLTruthAt` by recursion on `BLFormula`, prove the truth-transfer
bridge `TruthAt M τ t (tr φ) ↔ BLTruthAt M τ t φ` by induction, and obtain four BL soundness
theorems by composing `Metalogic.Conservativity.translate` with the four existing BL⁺ soundness
theorems and crossing the bridge. The research report elaborated every one of these obligations
against the built library with `lake env lean`, sorry-free, at `#print axioms` exactly
`[propext, Classical.choice, Quot.sound]` — so this plan is a transcription-and-placement
exercise, not proof search. Definition of done: all four soundness theorems, the four
empty-context validity forms, both consistency corollaries and the bridge are sorry-free with the
pinned axiom profile; `lake build` is green; `scripts/check-module-invariants.sh` still reports
ALL CHECKS PASSED; and every docstring claiming a BL semantics does not exist has been amended.

### Research Integration

The report (`reports/01_bl-soundness-by-composition.md`) supplies verbatim verified Lean source
for every deliverable, and settles three decisions this plan adopts unchanged:

1. **Placement**: the new modules go **outside** `FormalSystem/BaseLanguage/` —
   `Semantics/BLTruth.lean`, `Semantics/BLValidity.lean`, `Metalogic/BaseLanguageSoundness.lean`.
   The `BaseLanguage/ → Semantics/` module invariant therefore stays literally true; only a
   clarifying *directional* sentence is added to it, no weakening.
2. **Atom clause**: `BLTruthAt`'s atom case carries the `∃ (ht : τ.domain t), …` domain conjunct
   identical to `TruthAt`'s (Decision A of `specs/decisions/total-history-validity-decisions.md`).
   This is the deliberate divergence from `def:BL-semantics` and is exactly what makes the atom
   case of the bridge `Iff.rfl`. Do not "correct" it away.
3. **Dedekind target**: `BLValidDedekindDense` (with `[DenselyOrdered D]`), never a density-free
   `BLValidDedekind`. The BL-native refutation witness is `Axiom.dn` (`GGφ → Gφ`) on `ℤ`.

The report also identifies four now-false claims in `Metalogic/Conservativity.lean` and a stale
"reflexive convention" note in `Semantics/Truth.lean`; both are carried as required phases here,
not as optional cleanup.

### Prior Plan Reference

No prior plan. This is the first plan for this task.

### Roadmap Alignment

No `roadmap_path` was provided in the delegation context and no roadmap phases were requested;
roadmap consultation is skipped.

## Goals & Non-Goals

**Goals**:
- A **native** `BLTruthAt : TaskModel F → WorldHistory F → D → BLFormula → Prop` defined by
  six-clause recursion on `BLFormula`, transcribing `def:BL-semantics`.
- Four BL validity predicates mirroring `Semantics/Validity.lean` binder-for-binder:
  `BLValid`, `BLValidDense`, `BLValidDiscrete`, `BLValidDedekindDense` (plus
  `BLSemanticConsequence` for mirror completeness).
- The bridge `truthAt_tr` **proved by induction**, with its two corollaries `truthAt_trCtx` and
  `blValid_iff_valid_tr`.
- Four soundness theorems `bl_soundness{,_dense,_discrete,_dedekind}` by composition through
  `Conservativity.translate`, their four empty-context validity forms, and two consistency
  corollaries `bl_not_derivable_nil_bot{,_discrete}`.
- Every docstring that currently asserts "this repository has no BL semantics / no BL soundness
  theorem" amended to state what is now true, without softening the still-refuted forward
  conservativity direction.

**Non-Goals**:
- Defining `BLTruthAt` as `TruthAt (tr φ)` — the forbidden design; the standing guard against it
  is the three native spot-check `example`s in Phase 3.
- A density-free `BLValidDedekind` "for symmetry" — it is refutable.
- Dense and Dedekind consistency corollaries — deliberately absent on the BL⁺ side too (no
  dense/complete witness frame exists in the tree); the asymmetry gets a docstring sentence, not
  a proof attempt.
- The CEB/CEF countermodels, or any attempt on the forward conservativity direction. Those are
  downstream work; this task only changes which prerequisites are missing.
- Any BL-side per-axiom validity lemma. Composition inherits axiom validity from
  `Soundness.lean` and `BaseLanguage/AxiomDischarge.lean`.

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| `Conservativity.lean`'s four stale claims left unamended | H | M | Phase 4 is a required phase with its own verification, not a cleanup afterthought; the file is the exact one downstream countermodel work reads next |
| Invariant docstrings left silently false | H | M | Phase 4 amends both `BaseLanguage.lean` and `BaseLanguage/Formula.lean:46`; Phase 6 re-runs the `grep -rn 'FormalSystem.Semantics' FormalSystem/BaseLanguage/` check that must still return nothing |
| A density-free `BLValidDedekind` added "for symmetry" | H | L | Phase 2 defines exactly four predicates; the `Axiom.dn`-on-`ℤ` refutation witness is written into the `BLValidDedekindDense` docstring |
| `BLTruthAt` defined as `TruthAt (tr φ)` | H | L | Phase 1 transcribes the six-clause recursion verbatim; Phase 3's three native `example` spot checks fail to elaborate under the forbidden design |
| Atom clause "corrected" to drop the domain conjunct | M | L | Breaks the bridge's `Iff.rfl` atom case immediately; Decision A inheritance is documented in the Phase 1 docstring |
| New modules not registered in the aggregators (C6 rot guard fails) | M | M | Registration is a checklist item inside each of Phases 1-3; do **not** add them to `scripts/module-invariants-manifest.txt` |
| Task-number citations in new `.lean`/`.md` text (C9, enforced) | M | M | Cite `Conservativity.lean` section names and `Soundness.lean` theorem names instead; Phase 6 runs the full gate |
| C14(i) stale-count regex tripped by a written-out axiom count | L | L | BL's `Axiom` has 16 constructors; avoid writing bare counts like "the 21 BL axiom constructors" in new docstrings |
| `push_neg` deprecation warnings added to the tree | L | M | Use `push Not` in the three classical `¬∀¬ ↔ ∃` lemmas |
| Transient `FAIL C6` with no corresponding module change | L | L | Observed once during research and did not reproduce; re-run the gate before treating it as real |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2 | 1 |
| 3 | 3 | 2 |
| 4 | 4, 5 | 3 |
| 5 | 6 | 4, 5 |

Phases within the same wave can execute in parallel. Phases 4 and 5 touch disjoint file sets
(Phase 4: `.lean` docstrings; Phase 5: markdown inventories) and may run concurrently.

---

### Phase 1: `Semantics/BLTruth.lean` — native BL truth [COMPLETED]

**Goal**: Land `BLTruthAt` as a native six-clause recursion on `BLFormula`, together with the
`BLTruth.*` characterization lemmas, and register the module in the `Semantics` aggregator.

**Tasks**:
- [x] Create `FormalSystem/Semantics/BLTruth.lean` importing `FormalSystem.Semantics.Truth` and
      `FormalSystem.BaseLanguage.Formula` (and nothing else from `BaseLanguage/`).
- [x] Copy the variable bundle character-for-character from `Semantics/Truth.lean` (`{D : Type*}
      [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D] [Nontrivial D] {F : TaskFrame D}`).
- [x] Transcribe the six `BLTruthAt` clauses verbatim from the research report §3.1. No
      `termination_by`, no `decreasing_by` — the equation compiler handles the `box`/temporal
      recursions exactly as it already does for `TruthAt`.
- [x] Write the `BLTruth` namespace characterization lemmas: `bot_false`, `imp_iff`, `box_iff`,
      `future_iff`, `past_iff`, `neg_iff`, `top_true` (each `Iff.rfl`/`id`); `and_iff`, `or_iff`
      (`simp only [...]; tauto`); `diamond_iff`, `someFuture_iff`, `somePast_iff` (the classical
      `¬∀¬ ↔ ∃` step); `always_iff` (from `and_iff` + `past_iff` + `future_iff`).
- [x] Use `push Not`, not `push_neg`, in the three classical lemmas.
- [x] Module docstring: cite `def:BL-semantics`; state that the atom clause's domain conjunct is
      inherited knowingly from Decision A of
      `specs/decisions/total-history-validity-decisions.md`; state explicitly that this is a
      native recursion and **not** `TruthAt ∘ tr`. No task-number citations (C9).
- [x] Add `import FormalSystem.Semantics.BLTruth` to `FormalSystem/Semantics.lean` and a
      submodule bullet to its docstring list.
- [x] `lake build` green.

**Timing**: 1 hour

**Depends on**: none

**Verification Tier**: full

**Scope Hypothesis**: the report enumerates **twelve** `BLTruth.*` characterization lemmas plus
`always_iff`. Confirm at implementation time by counting the `theorem`/`lemma` declarations
actually landed in the `BLTruth` namespace and recording the number in the phase's progress
entry; if the derived-operator set in `BaseLanguage/Formula.lean` yields more or fewer, adjust the
count rather than forcing it, and note the discrepancy.

*Measured*: **13** declarations landed in the `BLTruth` namespace — the twelve the report
enumerated (`bot_false`, `imp_iff`, `box_iff`, `past_iff`, `future_iff`, `neg_iff`, `top_true`,
`and_iff`, `or_iff`, `diamond_iff`, `somePast_iff`, `someFuture_iff`) plus `always_iff`. No
discrepancy against the derived-operator set in `BaseLanguage/Formula.lean`; `iff` and `swapBL`
are the only derived items without a truth-characterization lemma, and neither has a `Truth`
namespace counterpart on the BL⁺ side either.

**Files to modify**:
- `FormalSystem/Semantics/BLTruth.lean` - new; `BLTruthAt` + `BLTruth.*` lemmas
- `FormalSystem/Semantics.lean` - add the import and a submodule docstring bullet

**Verification**:
- `lake build` green, zero `sorry`.
- `grep -n 'TruthAt M τ t (tr' FormalSystem/Semantics/BLTruth.lean` returns nothing (the
  forbidden-design guard: the definition must not mention `tr` at all).
- `grep -rn 'FormalSystem.Semantics' FormalSystem/BaseLanguage/` still returns nothing.

---

### Phase 2: `Semantics/BLValidity.lean` — the four validity predicates [COMPLETED]

**Goal**: Land the BL validity predicates as binder-for-binder mirrors of
`Semantics/Validity.lean`, with the inclusion lemmas, and register the module.

**Tasks**:
- [x] Create `FormalSystem/Semantics/BLValidity.lean` importing
      `FormalSystem.Semantics.BLTruth` and `FormalSystem.Semantics.Validity`.
- [x] Transcribe `BLValid`, `BLValidDense`, `BLValidDiscrete`, `BLValidDedekindDense` verbatim
      from the report §3.3, mirroring `valid`, `ValidDense`, `ValidDiscrete`,
      `ValidDedekindDense`. Use `Type` (not `Type*`), per the universe note on `valid`.
- [x] Add `BLSemanticConsequence`, mirroring `SemanticConsequence`.
- [x] Add the inclusion lemmas mirroring `Validity.valid_implies_valid_dense` and its siblings,
      matching whatever set `Validity.lean` actually carries.
- [x] `BLValidDedekindDense` docstring: record the Dedekind asymmetry with the **BL-native**
      witness — `(Axiom.dn φ).minFrameClass = .Dense`, `FrameClass.Dense ≤ FrameClass.Dedekind`,
      and `dn` (`GGφ → Gφ`) is false on `ℤ` (take `φ` true exactly at times `≥ t + 2`) — rather
      than paraphrasing `Validity.lean`'s BL⁺ `dense_indicator` argument. State that a
      density-free `BLValidDedekind` is deliberately not defined because it would be refutable.
- [x] Add `import FormalSystem.Semantics.BLValidity` to `FormalSystem/Semantics.lean` plus a
      submodule docstring bullet.
- [x] `lake build` green.

**Timing**: 0.75 hours

**Depends on**: 1

**Verification Tier**: full

**Scope Hypothesis**: this phase asserts **four** validity predicates plus
`BLSemanticConsequence` plus an inclusion-lemma set mirroring `Validity.lean`. The inclusion set
is the unconfirmed part: enumerate the actual `valid_implies_*` family in
`FormalSystem/Semantics/Validity.lean` at implementation time and mirror exactly that set,
recording the count. Do not invent a mirror for a lemma that has no BL⁺ counterpart.

*Measured*: `Validity.lean` carries a five-member inclusion family —
`valid_implies_valid_dense`, `valid_implies_valid_discrete`, `valid_implies_validDedekind`,
`valid_implies_validDedekindDense`, `validDedekindDense_of_validDedekind`. **Three** were
mirrored (`blValid_implies_blValidDense`, `blValid_implies_blValidDiscrete`,
`blValid_implies_blValidDedekindDense`). The two omitted both mention `ValidDedekind`, whose BL
counterpart is deliberately not defined; mirroring them would require introducing the refutable
`BLValidDedekind` this plan forbids. The omission and its reason are recorded in the
`BLValidity` namespace docstring. One further mirror was added beyond the inclusion family,
`blValid_iff_empty_consequence`, as the "trivial unfolding lemma" the research report
recommends alongside `BLSemanticConsequence`.

**Files to modify**:
- `FormalSystem/Semantics/BLValidity.lean` - new; five predicates + inclusion lemmas
- `FormalSystem/Semantics.lean` - add the import and a submodule docstring bullet

**Verification**:
- `lake build` green, zero `sorry`.
- `grep -n 'BLValidDedekind\b' FormalSystem/Semantics/BLValidity.lean` returns nothing (no
  density-free variant).
- Each of the four predicates' binder lists diffs cleanly against its `Validity.lean`
  counterpart with only `Formula`/`TruthAt` → `BLFormula`/`BLTruthAt` substituted.

---

### Phase 3: `Metalogic/BaseLanguageSoundness.lean` — bridge, soundness, consistency [COMPLETED]

**Goal**: Prove the bridge by induction and land all four soundness theorems, their validity
forms, both consistency corollaries, and the three native spot checks.

**Tasks**:
- [x] Create `FormalSystem/Metalogic/BaseLanguageSoundness.lean` importing
      `FormalSystem.Metalogic.Soundness`, `FormalSystem.Metalogic.Conservativity`,
      `FormalSystem.Semantics.BLValidity`.
- [x] Prove `truthAt_tr` by `induction φ generalizing τ t` per report §4. `generalizing τ t` is
      mandatory — the `box` case needs the IH at `σ`, the temporal cases at `s`, so each use site
      applies it explicitly (`ih σ t`, `ih τ s`).
- [x] Prove the corollaries `truthAt_trCtx` (the side-condition discharger) and
      `blValid_iff_valid_tr` (stated **as a theorem**, precisely so the distinction from the
      forbidden definitional shortcut is visible in the file).
- [x] Transcribe `bl_soundness` and its `_dense`/`_discrete`/`_dedekind` siblings from report §5,
      substituting `soundness_dense` / `soundness_discrete` / `soundness_dedekind` and copying
      each one's binder bundle; thread `soundness_dedekind`'s `h_lub` through in the same position
      (between `D` and `F`).
- [x] Transcribe the four empty-context validity forms
      `bl_soundness{,_dense,_discrete,_dedekind}_valid`.
- [x] Transcribe the two consistency corollaries `bl_not_derivable_nil_bot` and
      `bl_not_derivable_nil_bot_discrete`. Document in the module docstring why Dense and
      Dedekind corollaries are deliberately absent (no dense/complete witness frame in the tree;
      the same asymmetry `Soundness.lean`'s own docstring records).
- [x] Land the three native spot-check `example`s (TK, T4, MT) from report §5 — these are the
      standing evidence that `BLTruthAt` carries real content independently of the composition,
      and MT is the informative one (it goes through because `τ` is itself total, the `H_F`
      reading of the box clause).
- [x] Module docstring: state what composition does and does not certify (per-axiom validity is
      inherited from `Soundness.lean` and `BaseLanguage/AxiomDischarge.lean`; no BL axiom is
      evaluated directly against `BLTruthAt` except by the three spot checks). Note that
      `Conservativity.translate` is `noncomputable` but appears only inside `Prop`-valued proof
      terms, so the axiom profile is unaffected. No task-number citations (C9).
- [x] Add `import FormalSystem.Metalogic.BaseLanguageSoundness` to `FormalSystem/Metalogic.lean`.
- [x] `lake build` green.

**Timing**: 1.5 hours

**Depends on**: 2

**Verification Tier**: full

**Files to modify**:
- `FormalSystem/Metalogic/BaseLanguageSoundness.lean` - new; bridge + 4 soundness theorems + 4
  validity forms + 2 consistency corollaries + 3 spot checks
- `FormalSystem/Metalogic.lean` - add the import

**Verification**:
- `lake build` green, zero `sorry`.
- `#print axioms` on all seven headline results (`bl_soundness`, `bl_soundness_dense`,
  `bl_soundness_discrete`, `bl_soundness_dedekind`, `bl_not_derivable_nil_bot`,
  `bl_not_derivable_nil_bot_discrete`, `truthAt_tr`) each reports exactly
  `[propext, Classical.choice, Quot.sound]`.
- The three spot-check `example`s elaborate (they are the guard: under a `TruthAt ∘ tr`
  definition of `BLTruthAt` the intended tactic scripts would not go through as written).
- `bl_soundness_dedekind` targets `BLValidDedekindDense`.

---

### Phase 4: Lean docstring amendments — the invariant and the four stale claims [COMPLETED]

**Goal**: Amend every `.lean` docstring that now asserts something false, and make the
`BaseLanguage/` module invariant directional rather than silently ambiguous.

**Tasks**:
- [x] `FormalSystem/BaseLanguage.lean` ("## Module Invariant") and
      `FormalSystem/BaseLanguage/Formula.lean:46` (the same block): keep the invariant — it is
      still literally true — and make it **directional** in words. State that the invariant
      forbids `BaseLanguage/ → Semantics/`, and that the converse edge
      (`Semantics/BLTruth.lean` importing `BaseLanguage.Formula`) is permitted and is how the BL
      semantics is sited. Keep the `grep -rn 'FormalSystem.Semantics' FormalSystem/BaseLanguage/`
      check sentence.
- [x] `FormalSystem/Metalogic/Conservativity.lean` — amend the four now-false claims:
      (a) the "## No semantics" diagram's left-arrow annotation `⟸[BL soundness, not built]`
      (line ~139); (b) "## What a machine-checked refutation would need" — "None of the three
      exists in this repository" (lines ~100-101): two of the three now exist, only the
      countermodels remain; (c) the CEF section's "That half needs a BL-side semantics and
      soundness theorem, which this repository does not have" (line ~65); (d) the CEB section's
      "needs a BL-side semantics this repository does not have" (line ~87). Point each at
      `FormalSystem/Metalogic/BaseLanguageSoundness.lean` by module path, never by task number.
- [x] **The forward direction stays refuted** and must still not be stated or `sorry`-ed. The
      amendments must not read as softening it — what changes is only which prerequisites are
      missing.
- [x] `FormalSystem/Semantics/Truth.lean` (module docstring, ~lines 25-36): the "(past,
      reflexive)" / "(future, reflexive)" clause descriptions and the "a refinement of the
      paper's reflexive convention" sentence are stale — the pinned anchor `def:BL-semantics` has
      `y < x` and `x < y` on the nose, so the tree matches the paper exactly rather than refining
      it. Correct both.
- [x] `FormalSystem/Metalogic/Soundness.lean` module docstring and `FormalSystem/Metalogic.lean`
      (the Conservativity + Soundness status block, ~lines 33-48): add the BL row so the new
      theorems are discoverable from the aggregator.
- [x] No task-number citations anywhere in these edits (C9 is enforced over `FormalSystem/`).
- [x] Avoid bare axiom/constructor counts that would trip C14(i)'s stale-count regex.

**Timing**: 1 hour

**Depends on**: 3

**Verification Tier**: local

**Scope Hypothesis**: this phase asserts **four** stale claims in `Conservativity.lean` at the
approximate lines given. Confirm at implementation time by re-running
`grep -n 'BL soundness, not built\|None of the three exists\|BL-side semantics' FormalSystem/Metalogic/Conservativity.lean`
before and after; the "after" run must return no occurrence still asserting absence. If the grep
surfaces a fifth site, amend it too and record the corrected count.

*Measured*: the grep found the **four** asserted sites and no fifth. A **fifth** edit was made
anyway, in the same "## No semantics" section: its closing sentence "and this module is the
middle arrow only" was extended to say where the left arrow is now built, so the section's
diagram and its prose agree. The "after" grep returns no occurrence still asserting absence of a
BL semantics or BL soundness theorem, and the forward-direction refutation paragraph is present
and unsoftened (`Conservativity.lean:113`, "**forward direction remains refuted**").

**Files to modify**:
- `FormalSystem/BaseLanguage.lean` - directional invariant wording
- `FormalSystem/BaseLanguage/Formula.lean` - same block, same wording
- `FormalSystem/Metalogic/Conservativity.lean` - four stale claims
- `FormalSystem/Semantics/Truth.lean` - stale reflexive-convention note
- `FormalSystem/Metalogic/Soundness.lean` - docstring BL row
- `FormalSystem/Metalogic.lean` - status-block BL row

**Verification**:
- `lake build` green (Lean module docstrings do compile — an unterminated `-/` breaks the file, so
  a build of the touched modules is the minimum, not a diff read-through).
- The `grep` above returns no surviving "does not exist" assertion about BL semantics or BL
  soundness.
- The forward-direction refutation paragraph is still present and unsoftened.
- `bash scripts/check-task-references.sh` (or the C9 leg of the invariants script) clean.

---

### Phase 5: Markdown inventory and documentation sync [COMPLETED]

**Goal**: Register the three new modules in every README/docs inventory that enumerates modules,
so C5 (markdown module paths) and C13 (markdown links) stay green and the layer architecture
mentions `BaseLanguage` explicitly.

**Tasks**:
- [x] `FormalSystem/Semantics/README.md` — add `BLTruth.lean` and `BLValidity.lean` rows to the
      Contents table.
- [x] `FormalSystem/Metalogic/README.md` — add a `BaseLanguageSoundness.lean` row to the file
      table (~line 141 area).
- [x] `FormalSystem/README.md` — add the new modules to the module table (~line 226 area).
- [x] `docs/development/MODULE_ORGANIZATION.md` — add the two Semantics entries (~line 255 area)
      and the Metalogic entry; and amend the five-layer architecture list (~lines 107-129) to
      place `BaseLanguage` explicitly, noting the permitted `Semantics → BaseLanguage.Formula`
      edge, so the next reader does not have to re-derive it.
- [x] `docs/reference/API_REFERENCE.md` — add the new declarations to the BaseLanguage section
      (~line 746 area).
- [x] `docs/project-info/known-limitations.md`, Limitation 8 (~line 260ff) — re-read the "Impact"
      and "Resolution" text against the amended `Conservativity.lean` and update anything it now
      asserts falsely about missing BL semantics.
- [x] All module paths written must name the files as actually created (C5), and any new links
      must resolve (C13). No task-number citations.

**Timing**: 0.75 hours

**Depends on**: 3

**Verification Tier**: prose

**Scope Hypothesis**: this phase asserts **six** markdown sites. Confirm at implementation time
by running
`grep -rln 'Conservativity\|BaseLanguage' FormalSystem/**/README.md docs/` and checking each hit
for a module inventory or a BL-semantics-absence claim; amend any additional site found and
record the corrected count. Line numbers given above are approximate anchors from research, not
guarantees — locate by heading and content.

*Measured*: **nine** markdown sites, not six. The sweep returned eight files carrying a
`Conservativity`/`BaseLanguage` mention, and `FormalSystem/Semantics/README.md` (which names the
base language only in lower case) is a ninth. **Three sites beyond the plan's six** carried module
inventories and were amended:

- `docs/user-guide/architecture.md` — the `FormalSystem/` directory tree (`Semantics/` and
  `Metalogic/` blocks).
- `docs/project-info/implementation-status.md` — the Layer 1 Semantics and Layer 2 Metalogic
  module tables, plus the "Soundness (✅)" bullet list.
- `FormalSystem/BaseLanguage/README.md` — an earlier pass recorded this file as carrying no
  inventory and left it untouched; that reading was wrong. It carries a `## Modules` table with
  per-file line counts (`Formula.lean`'s was stale by the seven lines the invariant amendment
  added) and a `## Dependencies` section whose "Imported by" line named only
  `Metalogic.Conservativity`, which the new `Semantics.BLTruth` edge falsified. Both were
  corrected, and a `## Where the BL semantics lives` section was added pointing at the three new
  modules, so a reader who arrives at the directory expecting a semantics is told where it is
  rather than concluding none exists.

`FormalSystem/Metalogic/README.md`'s loose-file table also carried a written-out count
("**Five** loose files"), corrected to "**Six**" along with the new row — a count the plan did
not anticipate. That table's per-file **line counts** had also gone stale and were refreshed
against `wc -l`: `Soundness.lean` 2,022 → 2,042 and `Conservativity.lean` 295 → 311 (both drifted
by this task's own Phase 4 docstring amendments), `Metalogic.lean` 199 → 218, and
`StrongCompleteness.lean` 807 → 930 with `SetConsequence.lean` 338 → 346 (these two drifted from
concurrent sibling work on the compactness bridge, not from this task). The aggregator table
above it was checked against `wc -l` too and was already accurate. No invariant check enforces
these counts — C14(i) covers axiom and sorry counts only — so this is a documentation-truth fix,
not a gate requirement.

**Files to modify**:
- `FormalSystem/Semantics/README.md` - two new Contents rows
- `FormalSystem/Metalogic/README.md` - one new file-table row, plus stale line-count refresh
- `FormalSystem/BaseLanguage/README.md` - stale line count, "Imported by", and a new section
  siting the BL semantics (beyond the plan's six)
- `FormalSystem/README.md` - module table rows
- `docs/development/MODULE_ORGANIZATION.md` - module lists plus layer-list amendment
- `docs/reference/API_REFERENCE.md` - BaseLanguage section additions
- `docs/project-info/known-limitations.md` - Limitation 8 re-read

**Verification**:
- Diff read-through confirms every changed hunk is markdown prose or table content.
- Every new module path names a file that exists on disk.
- Every new relative link resolves (confirmed by C13 at the Phase 6 gate).

---

### Phase 6: Full gate [COMPLETED]

**Goal**: Run the complete acceptance gate and record the measured results.

**Tasks**:
- [x] `lake build` — green.
- [x] `#print axioms` on all seven headline results; each must be exactly
      `[propext, Classical.choice, Quot.sound]`.
- [x] `bash scripts/check-module-invariants.sh` — ALL CHECKS PASSED. Pay particular attention to
      C6 (the three new modules must be **reachable** via the two aggregators; do **not** add
      them to `scripts/module-invariants-manifest.txt`), C5, C9, C13, C14(i) and C15.
- [x] If a `FAIL C6` appears with no corresponding module change, re-run before treating it as
      real — a single non-reproducing transient was observed during research.
- [x] Confirm C2/C14(ii) `#print axioms` baselines are unchanged (the six pinned theorems are
      untouched; the new theorems are additions).
- [x] `grep -rn 'FormalSystem.Semantics' FormalSystem/BaseLanguage/` returns nothing.
      *(deviation: altered — as literally written this criterion was never satisfiable. At the
      commit preceding this task's first, the grep already returned two docstring-prose hits
      (`Formula.lean:48`, `AxiomDischarge.lean:67`); it now returns three, the added one being
      Phase 4's directional-invariant sentence. The load-bearing check is the import-level
      `grep -rn '^import.*FormalSystem.Semantics' FormalSystem/BaseLanguage/`, which returns
      nothing — the invariant holds. `BaseLanguage.lean`'s amended docstring now states that
      the grep's only matches are prose.)*
- [x] Record measured gate output in the implementation summary — do not paraphrase.

**Timing**: 0.5 hours

**Depends on**: 4, 5

**Verification Tier**: full

**Files to modify**: none (verification only)

**Verification**:
- `lake build` exit 0.
- `scripts/check-module-invariants.sh` prints ALL CHECKS PASSED.
- The seven `#print axioms` lines match the pinned profile verbatim.

---

## Testing & Validation

- [x] `lake build` green with zero `sorry` in the three new modules.
- [x] `truthAt_tr`, `bl_soundness`, `bl_soundness_dense`, `bl_soundness_discrete`,
      `bl_soundness_dedekind`, `bl_not_derivable_nil_bot`, `bl_not_derivable_nil_bot_discrete`
      each report `#print axioms` exactly `[propext, Classical.choice, Quot.sound]`.
- [x] `bl_soundness_dedekind` targets `BLValidDedekindDense`; no `BLValidDedekind` exists.
- [x] `BLTruthAt`'s definition contains no reference to `tr`.
- [x] The three native spot-check `example`s (TK, T4, MT) elaborate.
- [x] `bash scripts/check-module-invariants.sh` reports ALL CHECKS PASSED, with the three new
      modules reachable (C6) and not manifested.
- [x] `grep -rn 'FormalSystem.Semantics' FormalSystem/BaseLanguage/` returns nothing.
      *(deviation: altered — as literally written this criterion was never satisfiable. At the
      commit preceding this task's first, the grep already returned two docstring-prose hits
      (`Formula.lean:48`, `AxiomDischarge.lean:67`); it now returns three, the added one being
      Phase 4's directional-invariant sentence. The load-bearing check is the import-level
      `grep -rn '^import.*FormalSystem.Semantics' FormalSystem/BaseLanguage/`, which returns
      nothing — the invariant holds. `BaseLanguage.lean`'s amended docstring now states that
      the grep's only matches are prose.)*
- [x] No new `push_neg` deprecation warnings introduced.
- [x] No task-number citations in any file outside `specs/`.

## Artifacts & Outputs

- `FormalSystem/Semantics/BLTruth.lean` (new)
- `FormalSystem/Semantics/BLValidity.lean` (new)
- `FormalSystem/Metalogic/BaseLanguageSoundness.lean` (new)
- `FormalSystem/Semantics.lean`, `FormalSystem/Metalogic.lean` (aggregator registration)
- `FormalSystem/BaseLanguage.lean`, `FormalSystem/BaseLanguage/Formula.lean`,
  `FormalSystem/Metalogic/Conservativity.lean`, `FormalSystem/Semantics/Truth.lean`,
  `FormalSystem/Metalogic/Soundness.lean` (docstring amendments)
- `FormalSystem/Semantics/README.md`, `FormalSystem/Metalogic/README.md`,
  `FormalSystem/README.md`, `docs/development/MODULE_ORGANIZATION.md`,
  `docs/reference/API_REFERENCE.md`, `docs/project-info/known-limitations.md` (inventory sync)
- `specs/489_prove_baselanguage_soundness_base_and_extensions/summaries/01_bl-soundness-composition-summary.md`

## Rollback/Contingency

All three new modules are additions; rollback is deleting them and reverting the two aggregator
import lines. The docstring and markdown amendments (Phases 4-5) are independently revertible by
file and touch no compiled content beyond docstring syntax. Because each phase ends at a green
`lake build`, a failure at any phase leaves the tree buildable at the previous phase's commit.

If Phase 3's composition unexpectedly fails to elaborate — the research report elaborated it, so
this would indicate library drift since the prototype run — do **not** patch it by redefining
`BLTruthAt` as `TruthAt ∘ tr`. Stop, re-run the prototype from report §§3-5 against the current
tree to localize the drift, and report the divergence.
