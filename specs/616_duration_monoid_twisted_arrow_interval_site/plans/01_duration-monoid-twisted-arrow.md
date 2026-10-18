# Implementation Plan: Task #616

- **Task**: 616 - Formalize the duration monoid `BD⁺`, its twisted-arrow category, and `lem:interval-twisted-arrow`
- **Status**: [IMPLEMENTING]
- **Effort**: 4.5 hours
- **Dependencies**: Task 563 (landed — `FormalSystem/Semantics/Presheaf/Site.lean` exists and fixes the encoding this plan extends)
- **Research Inputs**: specs/616_duration_monoid_twisted_arrow_interval_site/reports/01_duration-monoid-twisted-arrow.md
- **Artifacts**: plans/01_duration-monoid-twisted-arrow.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: false

## Overview

One new module, `FormalSystem/Semantics/Presheaf/Duration.lean`, built on `Site.lean` alone and
importing nothing new: the duration monoid `BD⁺` (`Dur`), the factorization category of a
duration (`Factorization`, `Factorization.Hom`) with both halves of factorization-linearity, the
twisted-arrow category `Tw(BD⁺)` (`Tw`) with its three category laws, the hom-set bijection
`Tw.toTr`/`Tw.ofTr` with the interval site's translations, its functoriality, and the Johnstone
coverage on `Tw` together with the two transport equations that make the isomorphism one of sites.
The research report prototyped every one of these declarations end to end in a compiled probe
against `import FormalSystem.Semantics.Presheaf.Site`, with zero sorries and no axiom beyond
`propext`, so implementation is transcription of a verified shape, not discovery.

The module is wrapped by the companion edits any new `FormalSystem/` module forces: three
`DANGLING` anchor rows in `docs/reference/paper-definitions-of-record.md` BEFORE any docstring
cites them (C15, enforced; `REFERENCE_NORMAL_FORM.md`'s row-before-citation rule), the
aggregator import plus `## Modules` bullet in `FormalSystem/Semantics/Presheaf.lean` (C24 root
closure), a regenerated `FormalSystem.lean` (C33, byte-exact `lake exe mk_all --lib FormalSystem`
output), and the `Presheaf/README.md` module-table row and declaration entries.

### Research Integration

- **Encoding decision is a reconciliation, not a fresh choice.** `Site.lean`'s Implementation
  Notes record "concrete structures, no `Mathlib.CategoryTheory`" with three reasons and nominate
  `BD⁺` and the twisted-arrow description as the places to reconcile with that note. Mathlib has no
  twisted-arrow category, no factorization category and no factorization-linearity (`loogle
  "Twisted"` returns nothing), and `CategoryTheory.SingleObj` is multiplicative where `BD⁺` is
  additive. The plan follows `Site.lean`'s decision and writes the reconciliation into
  `Duration.lean`'s module docstring, as the task description requires.
- **Task 563 landed only `Int(D)`**, so this task does not narrow: no factorization, twisted-arrow
  or duration-monoid declaration exists under `Presheaf/` (only `Site.lean`'s docstring forward
  references). Full scope stands.
- **Two compiled-probe pitfalls carried into the phases**: name the factorization category
  `Factorization`, never `Fact` (Mathlib's `Fact : Prop → Prop` class); prove `hom_unique` by a
  commuted `add_left_cancel`, not `add_right_cancel`, which drags `Classical.choice` into the
  axiom footprint the Presheaf README publishes per declaration.
- **Index the `Tw` coverage by the cut point `p` with `q := l - p`**, mirroring `Site.lean`'s
  `coverRight` source object `⟨l.val - p, _⟩`, so both transport equations close by `ext; rfl`
  without a transport.
- **`Factorization.Hom` is its own declaration**, not folded into the two linearity theorems: the
  verification report of record (`~/Philosophy/Papers/PossibleWorlds/specs/archive/111_verify_interval_twisted_arrow_lemma/reports/01_verify-twisted-arrow-lemma.md`)
  records the omission of this identification as defect D1 of an earlier paper draft.
- **Stale dispatch paths, re-resolved by research**: the paper anchors live in
  `~/Philosophy/Papers/PossibleWorlds/JPL/appendix_cut_material.tex` (lines 250–313), commented,
  under `app:Structure`; the verification report is under `specs/archive/`. Nothing in
  `possible_worlds.tex` defines these labels any more.

### Prior Plan Reference

No prior plan.

### Roadmap Alignment

No `roadmap_path` was supplied to this dispatch, so `specs/ROADMAP.md` was not consulted as an
input. (Its orchestrate queue does list this task's duration-monoid/twisted-arrow module ahead
of the path-category work, which is consistent with the "land early, self-contained" posture the
task description takes.)

## Goals & Non-Goals

- **Goals**: the Challenge identifiers below, harvested as bare names: `comp`, `id`, `id_comp`,
  `comp_id`, `comp_assoc`, `comp_comm`, `ext`, `hom_unique`, `homOfLe`, `hom_total`, `fst_le`,
  `ofCut`, `ofCut_fst`, `ofCut_fst_self`, `toTr`, `ofTr`, `toTr_ofTr`, `ofTr_toTr`, `toTr_comp`,
  `toTr_id`, `coverLeft`, `coverRight`, `toTr_coverLeft`, `toTr_coverRight`.
- **Non-Goals**:
  - Declaring a `CategoryTheory.Category` instance on `Obj D`, or importing any
    `Mathlib.CategoryTheory` module — the decision is recorded and reversible (see Risks).
  - Importing `Mathlib.Algebra.Order.Nonneg.Basic` to make `BD⁺` literally Mathlib's
    `AddCommMonoid` on the positive cone; recorded as the import to add later if the cluster
    wants subtype arithmetic, with no definition here changing when it is.
  - The path category `Path(F)`, `def:conduche`, `fact:conduche-equivalence`,
    `cor:path-fibration` — the next task on this front, not this one.
  - Pinning any of the three paper anchors: the appendix is cut and commented, so every row is
    `DANGLING` and unpinnable by `check-paper-definitions.sh --resolve`.
  - Widening this task's `file_scope` to the aggregator or the root (the dispatch is explicit
    that doing so would make the collision gate defer the whole front every cycle).

## Lean Challenge Statements

The identifier set declared here equals the `- **Goals**:` list above (bare names, deduplicated
across the `Dur`/`Factorization`/`Tw` namespaces exactly as `lean-challenge-snapshot.sh`
deduplicates them). This block was typechecked as-is against the current tree, with only
`declaration uses sorry` warnings.

```lean
import FormalSystem.Semantics.Presheaf.Site

namespace FormalSystem.Semantics.Presheaf

variable {D : TemporalOrder}

abbrev Dur (D : TemporalOrder) : Type := TemporalOrder.PositiveCone D

namespace Dur

def comp (a b : Dur D) : Dur D := sorry
def id : Dur D := sorry
theorem id_comp (a : Dur D) : comp id a = a := sorry
theorem comp_id (a : Dur D) : comp a id = a := sorry
theorem comp_assoc (a b c : Dur D) : comp (comp a b) c = comp a (comp b c) := sorry
theorem comp_comm (a b : Dur D) : comp a b = comp b a := sorry

end Dur

structure Factorization (l : Obj D) where
  fst : ↑D
  snd : ↑D
  fst_nonneg : 0 ≤ fst
  snd_nonneg : 0 ≤ snd
  add_eq : fst + snd = l.val

namespace Factorization

@[ext] theorem ext {l : Obj D} {a b : Factorization l} (h : a.fst = b.fst) : a = b := sorry

structure Hom {l : Obj D} (a b : Factorization l) where
  z : ↑D
  z_nonneg : 0 ≤ z
  left : z + a.fst = b.fst
  right : a.snd = z + b.snd

theorem hom_unique {l : Obj D} {a b : Factorization l} (f g : Hom a b) : f = g := sorry
def homOfLe {l : Obj D} {a b : Factorization l} (h : a.fst ≤ b.fst) : Hom a b := sorry
theorem hom_total {l : Obj D} (a b : Factorization l) :
    Nonempty (Hom a b) ∨ Nonempty (Hom b a) := sorry
theorem fst_le {l : Obj D} (a : Factorization l) : a.fst ≤ l.val := sorry
def ofCut (l : Obj D) (p : ↑D) (hp : 0 ≤ p) (hpl : p ≤ l.val) : Factorization l := sorry
theorem ofCut_fst (l : Obj D) (p : ↑D) (hp : 0 ≤ p) (hpl : p ≤ l.val) :
    (ofCut l p hp hpl).fst = p := sorry
theorem ofCut_fst_self {l : Obj D} (a : Factorization l) :
    ofCut l a.fst a.fst_nonneg a.fst_le = a := sorry

end Factorization

structure Tw (l' l : Obj D) where
  pre : ↑D
  post : ↑D
  pre_nonneg : 0 ≤ pre
  post_nonneg : 0 ≤ post
  factors : pre + l'.val + post = l.val

namespace Tw

@[ext] theorem ext {l' l : Obj D} {f g : Tw l' l} (h₁ : f.pre = g.pre) (h₂ : f.post = g.post) :
    f = g := sorry
def id (l : Obj D) : Tw l l := sorry
def comp {l'' l' l : Obj D} (f : Tw l' l) (g : Tw l'' l') : Tw l'' l := sorry
theorem id_comp {l' l : Obj D} (f : Tw l' l) : comp (id l) f = f := sorry
theorem comp_id {l' l : Obj D} (f : Tw l' l) : comp f (id l') = f := sorry
theorem comp_assoc {l₃ l₂ l₁ l : Obj D} (f : Tw l₁ l) (g : Tw l₂ l₁) (h : Tw l₃ l₂) :
    comp (comp f g) h = comp f (comp g h) := sorry
def toTr {l' l : Obj D} (f : Tw l' l) : Tr l' l := sorry
def ofTr {l' l : Obj D} (f : Tr l' l) : Tw l' l := sorry
theorem toTr_ofTr {l' l : Obj D} (f : Tr l' l) : toTr (ofTr f) = f := sorry
theorem ofTr_toTr {l' l : Obj D} (f : Tw l' l) : ofTr (toTr f) = f := sorry
theorem toTr_comp {l'' l' l : Obj D} (f : Tw l' l) (g : Tw l'' l') :
    toTr (comp f g) = Tr.comp (toTr f) (toTr g) := sorry
theorem toTr_id (l : Obj D) : toTr (id l) = Tr.id l := sorry
def coverLeft (l : Obj D) (p : ↑D) (hp : 0 ≤ p) (hpl : p ≤ l.val) : Tw ⟨p, hp⟩ l := sorry
def coverRight (l : Obj D) (p : ↑D) (hp : 0 ≤ p) (hpl : p ≤ l.val) :
    Tw ⟨l.val - p, sub_nonneg.mpr hpl⟩ l := sorry
theorem toTr_coverLeft (l : Obj D) (p : ↑D) (hp : 0 ≤ p) (hpl : p ≤ l.val) :
    toTr (coverLeft l p hp hpl) = Presheaf.coverLeft l p hp hpl := sorry
theorem toTr_coverRight (l : Obj D) (p : ↑D) (hp : 0 ≤ p) (hpl : p ≤ l.val) :
    toTr (coverRight l p hp hpl) = Presheaf.coverRight l p hp hpl := sorry

end Tw

end FormalSystem.Semantics.Presheaf
```

Reading the statements against the paper: `Factorization.hom_unique` and `Factorization.hom_total`
together are factorization-linearity (`lem:factorization-linear`, the first conjunct of
`lem:interval-twisted-arrow`); `Tw.toTr_ofTr`/`Tw.ofTr_toTr` are the hom-set bijection and
`Tw.toTr_comp`/`Tw.toTr_id` its functoriality (identity on objects plus bijective on homs — the
isomorphism of categories); `Factorization.fst_le`/`ofCut`/`ofCut_fst`/`ofCut_fst_self` are the
bijection between factorizations of `l` and cut points `p ∈ [0, l]`; and `Tw.toTr_coverLeft`/
`Tw.toTr_coverRight` carry the Johnstone coverage of `Tw(BD⁺)` onto that of `Int(D)`, which
together with the cut-point bijection upgrades the isomorphism to one of sites (the step the
verification report's defect D2 found missing from an earlier draft).

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| `add_right_cancel` at `↑D` widens the axiom footprint of `hom_unique` to `[propext, Classical.choice, Quot.sound]`, and the Presheaf README publishes a per-declaration footprint table | M | M | Use the commuted `add_left_cancel` form (probe-verified `[propext]`); `lean_verify` every new theorem before closing Phases 2 and 3 |
| `Fact` shadows Mathlib's `Fact` class inside the namespace | M | H if named `Fact` | Name the structure `Factorization`; name freedom of `Factorization`/`Tw` was established by compiled `#check` probe |
| The aggregator `Presheaf.lean` and the root `FormalSystem.lean` are shared touches with every task on this front (siblings 566 and 617 are in flight on `Worlds.lean` and `Reflection.lean`), invisible to the collision gate because they are in no task's `file_scope` | H | M | Phase 4 re-reads both immediately before editing, runs `git status --short -- FormalSystem/` before `mk_all` and STOPS (reports, does not proceed) on any foreign untracked or modified `.lean`, stages only this task's own files by explicit path, and re-runs the build after the aggregator edit |
| `FormalSystem.lean` hand-edited rather than regenerated fails C33's byte-exact check | M | L | Phase 4 runs `lake exe mk_all --lib FormalSystem` and commits its output verbatim; `--check` is the cross-check |
| A docstring cites an anchor with no row and C15 fails the gate | M | M | Phase 1 adds all three `DANGLING` rows before any Lean docstring is written (row-before-citation rule) |
| `lean-challenge-snapshot.sh --check` resolves identifiers tree-wide by bare name, and `comp`/`id`/`ext`/`id_comp`/`comp_id`/`comp_assoc` already exist as `Tr.*` in `Site.lean` (and elsewhere), so `--check` exits 71 "resolves to more than one declaration" for those names regardless of this plan's naming | L | H | `--check` is advisory-only per `rules/plan-compliance.md`; statement fidelity is verified instead by `lean_hover_info` on each new declaration against the pinned block above. Renaming to dodge the tool would abandon the `Tr`-mirroring names `Site.lean`'s note asks the categorical packaging to share, so the names stay |
| The paper anchors are unpinnable (commented, cut, bare `% CHECK`), so correspondence to the paper rests on a record, not live text | L | certain | Same posture as `Site.lean`: say so at each citation site, cite `docs/reference/paper-definitions-of-record.md` as the source of record, note the mathematics is Lean-checked regardless of the appendix's fate |
| The README module table sits inside a `BEGIN GENERATED: inventory` block | L | M | Phase 4 regenerates via `scripts/readme-inventory.sh` (read its `--help` first) rather than hand-editing; hand-add a row in the generated shape only if the script does not write this table |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2 | 1 |
| 3 | 3 | 2 |
| 4 | 4 | 1, 2, 3 |

Phases within the same wave can execute in parallel. This plan is fully sequential: Phase 2's
docstrings cite the anchors Phase 1 records, Phase 3 extends the file Phase 2 creates, and Phase 4
wires the finished module into the aggregator and root and runs the complete gate set.

### Phase 1: Record the three paper anchors as DANGLING rows [COMPLETED WITH EXCLUSIONS]

**Goal**: Give `def:twisted-arrow`, `lem:factorization-linear` and `lem:interval-twisted-arrow`
each a `KNOWN-ANCHORS` row in `docs/reference/paper-definitions-of-record.md`, so that C15 can
resolve the citations Phases 2 and 3 will write, and correct the prose paragraph that currently
counts these three among the untracked appendix anchors.

**Tasks**:
- [x] Confirm the hypothesis: `grep -nE '^(def:twisted-arrow|lem:factorization-linear|lem:interval-twisted-arrow)\|' docs/reference/paper-definitions-of-record.md` returns nothing (a sibling may have added one — skip any row that already exists) *(completed — grep returned nothing; all three rows were missing)*
- [x] Add three `DANGLING` rows inside the `<!-- KNOWN-ANCHORS:BEGIN -->` block, in the block's existing code-point ordering beside the `def:interval-site`/`def:behavior-presheaf` rows, each in the shape `anchor_id|DANGLING|note`. Each note records: what the anchor states (the twisted-arrow category / factorization-linearity / the isomorphism of sites `Int(D) ≅ Tw(BD⁺)`), that `app:Structure` was cut IN FULL under `% SECTION CUT` with a bare `% CHECK` and the anchor went with it, that the statement of record now lives in `JPL/appendix_cut_material.tex` and the archived verification report, the Lean counterpart (`FormalSystem/Semantics/Presheaf/Duration.lean`: `Tw`/`Tw.comp`; `Factorization.hom_unique`/`hom_total`; `Tw.toTr`/`ofTr` with `toTr_coverLeft`/`toTr_coverRight`), and `NOT PINNABLE, as for app:Structure`. No task numbers in any note. *(completed — `def:twisted-arrow` after `def:strongest`; `lem:factorization-linear` before and `lem:interval-twisted-arrow` after `lem:fibers`)*
- [x] Update the "Twelve new appendix anchors deliberately NOT pinned" paragraph: the "remaining nine" now excludes `lem:factorization-linear` and `lem:interval-twisted-arrow` (and `def:twisted-arrow`, which that paragraph never listed — name it alongside), recording that `Duration.lean` formalizes them and that all three carry `DANGLING` rows for the same unpinnability reason as the four already recorded *(completed — "remaining seven")*
- [x] Run the covering checks named under Verification and commit: `task 616 phase 1: record the twisted-arrow anchors` *(completed — see Reasoned Exclusions for the one criterion that is red at this boundary by construction)*

**Timing**: 0.5 hours

**Depends on**: none

**Verification Tier**: local

**Scope Hypothesis**: exactly three rows are missing and one paragraph needs amending (research grep of the record file); confirm with the first task's grep before editing, and read the paragraph to confirm no later edit has already restated it.

**Tier Justification**: `bash scripts/check-module-invariants.sh --no-build` (C15 re-parses the `KNOWN-ANCHORS` block this phase edits and must stay PASS) together with `bash .claude/scripts/verify-deploy.sh --only-gate 4` (task-reference lint on a consumer-tree doc) is the complete covering check — no Lean surface is touched, and the `prose` tier is wrong here because the row block is load-bearing input to an enforced gate.

**Files to modify**:
- `docs/reference/paper-definitions-of-record.md` - three `DANGLING` rows in the `KNOWN-ANCHORS` block; one prose paragraph amended

**Verification**:
- `grep -cE '^(def:twisted-arrow|lem:factorization-linear|lem:interval-twisted-arrow)\|DANGLING\|' docs/reference/paper-definitions-of-record.md` prints `3`
- `bash scripts/check-module-invariants.sh --no-build` exits 0 with `PASS C15` (check the exit status, not just the printed line)
- `bash .claude/scripts/verify-deploy.sh --only-gate 4` passes
- Diff read-through: no `task N` reference in any new row or amended sentence

**Observed at closure**: the row-count grep printed `3`; `PASS C15` on both assertions (88 citations, 313 theorem-index rows); `verify-deploy.sh --only-gate 4` exited 0; the diff carries no task-number reference. The harness itself exited 1 — on C12 alone, see below.

#### Reasoned Exclusions

| Item | Reason | Evidence |
|------|--------|----------|
| The `exits 0` half of the criterion `check-module-invariants.sh --no-build` exits 0 with `PASS C15` | C12 (unresolved slash-shaped source paths under `docs/`) fails every mention of `FormalSystem/Semantics/Presheaf/Duration.lean` in the three new rows and the amended paragraph, because the module is created in Phase 2. The plan's own ordering forces this: C15's row-before-citation rule places the rows in Phase 1, while C12 needs the file to exist first, and the rows cite the Lean counterpart by path exactly as the sibling `def:interval-site` row cites `Site.lean`. Rewording the rows to dodge C12 would make them inconsistent with every other `FORMALIZED as ... (path)` row in the block. The criterion is not dropped: Phase 2's verification re-runs the same `--no-build` harness after the module exists and observes exit 0 there, within this dispatch. | `FAIL C12 4 unresolved slash-shaped source path(s) in docs/ + README.md` naming `paper-definitions-of-record.md:996`, `:2519`, `:2520`, `:2522`, each `FormalSystem/Semantics/Presheaf/Duration.lean`; `PASS C15` on both assertions in the same run; every other check group PASS |

---

### Phase 2: `Duration.lean`, part A — the duration monoid and factorization-linearity [NOT STARTED]

**Goal**: Create `FormalSystem/Semantics/Presheaf/Duration.lean` with its module docstring (the
encoding decision reconciled with `Site.lean`'s note, the paper-state caveat, and a `## References`
block in normal form), the duration monoid `Dur` with its four laws, the factorization category
`Factorization`/`Factorization.Hom`, both halves of factorization-linearity, and the cut-point
bijection — building green on its own with zero sorries.

**Tasks**:
- [ ] Create the file with the repository copyright header, `import FormalSystem.Init` and `import FormalSystem.Semantics.Presheaf.Site`, `namespace FormalSystem.Semantics.Presheaf`, `variable {D : TemporalOrder}`, and the closing `assert_not_exists FormalSystem.ProofSystem.Axiom FormalSystem.ProofSystem.DerivationTree` footer `Site.lean` uses (same layering lock)
- [ ] Write the module docstring: `# The duration monoid BD⁺ and the twisted-arrow site`; Main Definitions / Main Results lists; **Implementation Notes** recording (a) the concrete-structures decision as a reconciliation with `Site.lean`'s note — Mathlib supplies no twisted-arrow category, no factorization category and no factorization-linearity so all four are hand-rolled either way, `SingleObj` is multiplicative where `BD⁺` is additive, the concrete route keeps the module buildable from `Site.lean` alone, and `Tw.id`/`Tw.comp` plus the three laws are exactly the fields a `Category` instance would need so the decision stays reversible; (b) why `Mathlib.Algebra.Order.Nonneg.Basic` is not imported and when it would be; (c) why the name is `Factorization`, not `Fact`; (d) why `Factorization.Hom` is its own declaration (the verification report's defect D1); (e) the paper-state caveat in `Site.lean`'s wording — anchors resolve against `docs/reference/paper-definitions-of-record.md`, all `DANGLING`, unpinnable
- [ ] Write the `## References` block in `docs/development/REFERENCE_NORMAL_FORM.md`'s form: `* [P. Schultz, D. I. Spivak and C. Vasilakopoulou, *Dynamical Systems and Sheaves*][schultz2020]`, `* [P. T. Johnstone, *A Note on Discrete Conduché Fibrations*][johnstone1999]` (both keys already resolve in the root `references.bib`), then the JPL anchors `def:interval-site`, `def:twisted-arrow`, `lem:factorization-linear`, `lem:interval-twisted-arrow`, `app:Structure`, each marked **`DANGLING`** with the one-line cut record, then the `Site.lean` and `TemporalOrder.lean` pointers
- [ ] `Dur`: `abbrev Dur (D) := TemporalOrder.PositiveCone D` (equal to `Obj D` by design; the alias names the role in play), `Dur.comp a b := ⟨a.val + b.val, add_nonneg a.2 b.2⟩`, `Dur.id := ⟨0, le_refl 0⟩`, `@[simp]` `rfl` lemmas `comp_val`/`id_val`, then `id_comp`/`comp_id`/`comp_assoc`/`comp_comm` each `by ext; simp [add_assoc]`/`[add_comm]` as needed
- [ ] `Factorization l`: the five-field structure as pinned above; `@[ext] theorem ext` on `fst` ALONE (a factorization is determined by its first summand via `add_left_cancel` from the two `add_eq` fields — `obtain`/`subst`, footprint `[propext]`)
- [ ] `Factorization.Hom a b`: the four-field structure as pinned; `hom_unique` via a **commuted `add_left_cancel`** on the two `left` fields (`z + a.fst = b.fst`, rewrite both sides to `a.fst + z` form) — NOT `add_right_cancel`; then `Hom.ext`-style closing on `z`
- [ ] `homOfLe (h : a.fst ≤ b.fst) : Hom a b` with `z := b.fst - a.fst`: `z_nonneg` is `sub_nonneg.mpr h`, `left` is `sub_add_cancel`, `right` is `rw [sub_add_eq_add_sub, eq_sub_iff_add_eq, add_comm a.snd a.fst]` then `a.add_eq.trans b.add_eq.symm`; `hom_total` by `rcases le_total a.fst b.fst with h | h` and `homOfLe` in each branch (`linarith`/`abel` are NOT available in this import closure — do not reach for them)
- [ ] `fst_le`, `ofCut l p hp hpl := ⟨p, l.val - p, hp, sub_nonneg.mpr hpl, add_sub_cancel⟩`, `ofCut_fst` (`rfl`), `ofCut_fst_self` (`ext; rfl` or `ext; simp [ofCut]`)
- [ ] `lean_verify` (or `#print axioms` in a scratch probe) on `Factorization.ext`, `hom_unique`, `hom_total`, `ofCut_fst_self`: each at most `[propext]`; record the footprints for Phase 4's README rows
- [ ] Scoped build green; commit `task 616 phase 2: duration monoid and factorization-linearity`

**Timing**: 1.25 hours

**Depends on**: 1

**Verification Tier**: local

**Scope Hypothesis**: one new file, roughly 15 declarations in part A (research items 1–7); the implementer confirms by the scoped build and the identifier list in `## Lean Challenge Statements` (the `Dur`/`Factorization` subset).

**Tier Justification**: `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build FormalSystem.Semantics.Presheaf.Duration` is the complete covering check — the module is new and not yet imported by the aggregator or the root, so no other module can observe it, and the full-gate checks that do observe it (C24, C33, C15 on its citations) are Phase 4's.

**Files to modify**:
- `FormalSystem/Semantics/Presheaf/Duration.lean` - new module: header, docstring, references, `Dur`, `Factorization`, `Factorization.Hom`, factorization-linearity, cut-point bijection

**Verification**:
- `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build FormalSystem.Semantics.Presheaf.Duration` exits 0 with no `sorry` warning and no new warning class (C28 budget is measured in Phase 4; keep the file warning-free now)
- `grep -c sorry FormalSystem/Semantics/Presheaf/Duration.lean` prints `0`
- `lean_hover_info` on `hom_unique`, `hom_total`, `homOfLe`, `fst_le`, `ofCut`, `ofCut_fst`, `ofCut_fst_self`, `Dur.comp`, `Dur.id` and the four `Dur` laws matches the pinned signatures in `## Lean Challenge Statements` (the `--check` route is ambiguous on bare names — see Risks)
- `lean_verify` footprints: every part-A theorem ≤ `[propext]`
- Every `[key]` in the `## References` block is `schultz2020` or `johnstone1999`; every paper anchor cited has a row from Phase 1

---

### Phase 3: `Duration.lean`, part B — `Tw(BD⁺)`, the isomorphism with `Int(D)`, and coverage transport [NOT STARTED]

**Goal**: Add the twisted-arrow category `Tw` with its three category laws, the hom-set bijection
with `Tr` in both directions, functoriality, the Johnstone coverage on `Tw` indexed by the cut
point, and the two transport equations onto `Site.lean`'s `coverLeft`/`coverRight` — completing
`lem:interval-twisted-arrow` with the module still green and sorry-free.

**Tasks**:
- [ ] `Tw l' l`: the five-field structure as pinned (`pre`, `post`, nonnegativity, `factors : pre + l'.val + post = l.val`); `@[ext] theorem ext` on BOTH components
- [ ] `Tw.id l := ⟨0, 0, le_refl 0, le_refl 0, by simp⟩`; `Tw.comp f g := ⟨f.pre + g.pre, g.post + f.post, add_nonneg …, add_nonneg …, factors⟩` with the second component in the paper's order `(p + p', q' + q)`, and `factors` closed by a three-step `calc` whose first step is `by simp only [add_assoc]` (a plain `rw [add_assoc, …]` leaves a goal — probe-verified)
- [ ] `@[simp]` `rfl` lemmas `comp_pre`, `comp_post`, `id_pre`, `id_post`; then `id_comp`/`comp_id`/`comp_assoc` each `by ext <;> simp [add_assoc]`
- [ ] `Tw.toTr f := ⟨f.pre, f.pre_nonneg, by rw [← f.factors]; exact le_add_of_nonneg_right f.post_nonneg⟩`; `Tw.ofTr f := ⟨f.shift, l.val - f.shift - l'.val, f.shift_nonneg, sub_nonneg.mpr (le_sub_iff_add_le'.mpr f.shift_add_le), by rw [sub_sub, add_sub_cancel]⟩`
- [ ] `toTr_ofTr` by `ext; simp`; `ofTr_toTr` by `ext` then — for the `post` goal — `change l.val - f.pre - l'.val = f.post` (use `change`, not `show`: `show` trips the style linter), `rw [sub_sub, ← f.factors]`, `add_sub_cancel_left`
- [ ] `toTr_comp`, `toTr_id` by `ext; simp` — functoriality; with `toTr_ofTr`/`ofTr_toTr` this is the identity-on-objects, bijective-on-homs isomorphism of categories
- [ ] `Tw.coverLeft l p hp hpl : Tw ⟨p, hp⟩ l := ⟨0, l.val - p, …⟩` and `Tw.coverRight l p hp hpl : Tw ⟨l.val - p, sub_nonneg.mpr hpl⟩ l := ⟨p, 0, …⟩` — indexed by the cut point `p` with `q := l - p`, so the source objects are definitionally `Site.lean`'s
- [ ] `toTr_coverLeft`, `toTr_coverRight` by `ext; rfl` — the coverage transport; add a docstring sentence tying these plus `Factorization.ofCut`/`ofCut_fst_self` to the "covering families correspond bijectively" step (the paper proof's final paragraph; verification report defect D2)
- [ ] Extend the module docstring's Main Definitions / Main Results for part B; `lean_verify` every part-B theorem (expect `[propext]` or none); scoped build green; commit `task 616 phase 3: twisted-arrow category and coverage transport`

**Timing**: 1.5 hours

**Depends on**: 2

**Verification Tier**: local

**Scope Hypothesis**: the same single file, roughly 20 further declarations (research items 8–15); confirmed by the scoped build and the `Tw` subset of the pinned identifier list.

**Tier Justification**: `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build FormalSystem.Semantics.Presheaf.Duration` is the complete covering check for the same reason as Phase 2 — the module is still unimported by the aggregator and the root until Phase 4, so nothing outside it can observe this edit.

**Files to modify**:
- `FormalSystem/Semantics/Presheaf/Duration.lean` - append `Tw`, its laws, `toTr`/`ofTr` and the bijection, functoriality, `Tw.coverLeft`/`Tw.coverRight`, the two transport theorems; extend the docstring

**Verification**:
- Scoped guarded build exits 0, no `sorry` warning, no new warnings
- `grep -c sorry FormalSystem/Semantics/Presheaf/Duration.lean` prints `0`
- `lean_hover_info` on every `Tw.*` declaration matches the pinned signatures in `## Lean Challenge Statements`
- `toTr_coverLeft`/`toTr_coverRight` close by `ext; rfl` with no `Eq.mpr`/cast in the elaborated term (confirms the cut-point indexing)
- `lean_verify` footprints: every part-B theorem ≤ `[propext]`

---

### Phase 4: Wire the module into the cluster and run the complete gate set [NOT STARTED]

**Goal**: Make `Duration.lean` part of the build closure and the published documentation —
aggregator import and `## Modules` bullet, regenerated root, README row and declaration entries —
then run the full gate set: `lake build FormalSystem`, `check-module-invariants.sh` (C15, C24,
C28, C31, C33 among them), `mk_all --check`, and `verify-deploy.sh`.

**Tasks**:
- [ ] Territory check FIRST: `git status --short -- FormalSystem/ FormalSystem.lean` — if any `.lean` other than `FormalSystem/Semantics/Presheaf/Duration.lean` is untracked or modified, or `git log -1` shows a commit you did not make, STOP and report (a sibling is in flight on this tree); do not fold a foreign module into the regenerated root
- [ ] Re-read `FormalSystem/Semantics/Presheaf.lean` immediately before editing; add `import FormalSystem.Semantics.Presheaf.Duration` in the aggregator's existing (alphabetical) import order and a `## Modules` bullet: `- \`Presheaf.Duration\` — the duration monoid \`BD⁺\`, the factorization category of a duration and factorization-linearity, the twisted-arrow category \`Tw(BD⁺)\`, and its coverage-preserving isomorphism with \`Int(D)\``
- [ ] Regenerate the root: `lake exe mk_all --lib FormalSystem`; confirm the only diff to `FormalSystem.lean` is the one new import line; `lake exe mk_all --lib FormalSystem --check` exits 0
- [ ] `FormalSystem/Semantics/Presheaf/README.md`: regenerate the `## Modules` inventory table via `scripts/readme-inventory.sh` (read `--help` first; hand-add the `Duration.lean` row in the generated shape only if the script does not write this table); add `## Key Definitions` entries (`Dur`, `Factorization`, `Factorization.Hom`, `Tw`, `Tw.toTr`/`Tw.ofTr`, `Tw.coverLeft`/`Tw.coverRight`), `## Key Results` entries (`Factorization.hom_unique`/`hom_total` as factorization-linearity, `Tw.toTr_ofTr`/`ofTr_toTr`/`toTr_comp`/`toTr_id` as the isomorphism, `toTr_coverLeft`/`toTr_coverRight` as the coverage transport), the axiom-footprint rows measured in Phases 2–3, and a `## Dependencies`/`## Related Documentation` pointer to `Site.lean`; a one-sentence note that the encoding decision is reconciled in `Duration.lean`'s Implementation Notes
- [ ] Full guarded build: `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build` (foreground `timeout` form if it fits, else detached per `context/project/lean4/operations/long-builds.md`); re-run after the aggregator edit if any sibling activity was observed
- [ ] `bash scripts/check-module-invariants.sh` (with build) exits 0 — read C15 (new citations resolve), C24 (`Duration` in the root closure via `Init`), C28 (no warning-budget regression; if the new file trips a budget row, fix the warning rather than raising the budget), C31 (both bib keys resolve), C33 (root byte-exact)
- [ ] `bash .claude/scripts/verify-deploy.sh` passes (the complete agent-system gate set); `bash .claude/scripts/verify-deploy.sh --only-gate 4` is NOT a substitute here
- [ ] Record issues/wins for this task via `issue-record.sh`, write the summary, stage by explicit path only (`git add -- FormalSystem/Semantics/Presheaf/Duration.lean FormalSystem/Semantics/Presheaf.lean FormalSystem.lean FormalSystem/Semantics/Presheaf/README.md`), review `git diff --staged`, commit `task 616 phase 4: wire Duration into the Presheaf cluster`

**Timing**: 1 hour

**Depends on**: 1, 2, 3

**Verification Tier**: full

**Scope Hypothesis**: four companion files beyond the module (aggregator, root, README, the record edited in Phase 1), per the research's gate-by-gate table; `check-module-invariants.sh`'s output is the confirmation — any further FAIL row names an additional file this hypothesis missed.

**Files to modify**:
- `FormalSystem/Semantics/Presheaf.lean` - one import line and one `## Modules` bullet (shared touch — re-read before editing, stage only this hunk)
- `FormalSystem.lean` - regenerated by `lake exe mk_all --lib FormalSystem`, never hand-edited
- `FormalSystem/Semantics/Presheaf/README.md` - module-table row, Key Definitions, Key Results, axiom-footprint rows, pointers

**Verification**:
- `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build` exits 0; `grep -rn sorry FormalSystem/Semantics/Presheaf/Duration.lean` is empty
- `lake exe mk_all --lib FormalSystem --check` exits 0
- `bash scripts/check-module-invariants.sh` exits 0 with PASS on C15, C24, C28, C31, C33 (check the shell exit status, not only the printed lines)
- `bash .claude/scripts/verify-deploy.sh` exits 0 — the complete gate set, unchanged by the cheaper in-phase tiers of Phases 1–3
- `grep -n "Presheaf.Duration" FormalSystem.lean FormalSystem/Semantics/Presheaf.lean` shows exactly one hit in each
- `git status --short` after the commit shows no stray modification outside this task's four files plus `specs/616_*`

## Testing & Validation

- [ ] Scoped guarded build of `FormalSystem.Semantics.Presheaf.Duration` green at the end of Phases 2 and 3, zero `sorry`
- [ ] Full guarded build `lake build FormalSystem` green at the end of Phase 4 (the task constraint: green with no new sorry at the end of every phase — Phase 1 touches no Lean, so its build state is unchanged from HEAD)
- [ ] `lean_verify`: every new theorem's footprint ≤ `[propext]`; in particular `Factorization.hom_unique` carries no `Classical.choice`
- [ ] `lean_hover_info` on each of the 24 pinned identifiers matches `## Lean Challenge Statements` (the snapshot tool's `--check` is expected to report bare-name ambiguity on `comp`/`id`/`ext`-family names — advisory, see Risks)
- [ ] `bash scripts/check-module-invariants.sh` exits 0 (C15, C24, C28, C31, C33 observed PASS); `lake exe mk_all --lib FormalSystem --check` exits 0
- [ ] `bash .claude/scripts/verify-deploy.sh` exits 0
- [ ] No `task N` reference in `Duration.lean`, the README, the aggregator, or the record rows (`bash .claude/scripts/verify-deploy.sh --only-gate 4`)

## Artifacts & Outputs

- `FormalSystem/Semantics/Presheaf/Duration.lean` — the new module (the task's declared `file_scope`)
- `docs/reference/paper-definitions-of-record.md` — three `DANGLING` rows and an amended paragraph
- `FormalSystem/Semantics/Presheaf.lean` — one import and one `## Modules` bullet
- `FormalSystem.lean` — regenerated
- `FormalSystem/Semantics/Presheaf/README.md` — module row, declaration entries, footprint rows
- `specs/616_duration_monoid_twisted_arrow_interval_site/summaries/01_duration-monoid-twisted-arrow-summary.md` — implementation summary (written at completion)

## Rollback/Contingency

Each phase commits on its own, so a failure in Phase N leaves Phases 1..N-1 committed and green.
Phases 2–3 cannot break the tree at HEAD because `Duration.lean` is unimported until Phase 4: if
a part-B proof resists, leave the file compiling at the Phase 2 commit, mark Phase 3 `[BLOCKED]`
with the goal state reached, and escalate per `rules/plan-compliance.md` — never substitute a
weaker statement under a pinned name, and never a vacuous placeholder. If Phase 4's full build
fails on a file outside this task's four, treat it first as a sibling's in-flight edit (check
`git log`/`git status`) rather than a regression here. A genuine rollback of uncommitted
Phase 4 edits uses the snapshot-then-rollback rung of `context/contracts/recovery.md` (the
reverting `git-snapshot.sh 616` form with its out-of-scope override only because the aggregator
and root are outside `file_scope`), never a bare `git checkout -- FormalSystem.lean` on a dirty
tree; a defensive checkpoint before the root regeneration, if wanted, is
`bash .claude/scripts/git-snapshot.sh --no-revert 616`.
