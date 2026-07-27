# Implementation Plan: Task #406

- **Task**: 406 - Prove semantic validity of the Sep axiom over real flow (Reynolds 1992 section 7, lemma 10)
- **Status**: COMPLETED
- **Effort**: 3 hours
- **Dependencies**: 391 (parent), 405 (landed)
- **Research Inputs**: `specs/406_prove_semantic_validity_of_the_sep_axiom_over_real_flow_reynolds_1992_section_7_lemma_10/reports/01_sep-axiom-validity-real-flow.md`
- **Artifacts**: plans/01_sep-validity-transcription.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md, `.claude/rules/lean4.md`, `.claude/rules/plan-compliance.md`, `.claude/rules/no-task-references-in-deliverables.md`
- **Type**: lean4
- **Lean Intent**: false

## Overview

This is a **transcription-and-verify** plan, not a proof-search plan. Research did not merely
scope the problem: it wrote and machine-verified complete, sorry-free proofs of both target
lemmas against this tree's Lean/Mathlib pin (`lake env lean`, EXIT=0; `#print axioms` returning
`[propext, Classical.choice, Quot.sound]` with no `sorryAx`). The verbatim tactic text lives in
**section 7 of the research report** and is the single authoritative source for every line of
Lean this task writes.

The work is: create `FormalSystem/Metalogic/SoundnessLemmas/Separability.lean` holding the
separability machinery (report 7.2) and the order-theoretic core (report 7.3); then replace the
two `sorry` bodies in `Soundness.lean` with the glue lemmas (report 7.4) and apply the comment
and docstring cleanup (report 7.5). Three phases, each independently buildable.

**The implementer's job is to transcribe, not to re-derive.** `.claude/rules/plan-compliance.md`
applies with full force. If a transcribed block does not compile, the correct response is to
check for a transcription typo against report section 7 — not to invent a replacement tactic
sequence. Every tactic in section 7 was chosen against a recorded failure of the obvious
alternative (report section 9: `linarith` fails on the ordered group, `ring` fails on the
`AddCommGroup`, `exact?` was needed to find `le_of_nsmul_le_nsmul_right`).

### Research Integration

The report is fully integrated: section 7.2 is Phase 1's content, section 7.3 is Phase 2's,
section 7.4 + 7.5 are Phase 3's. Report sections 5, 6, 8, 9, 10, 11 supply the non-transferable
constraints reproduced below.

### Prior Plan Reference

No prior plan for this task. The immediately preceding sibling task (405, Prior gap axioms)
landed and supplies `exists_isGLB_of_lub`, the binder-set precedent, and the sorry baseline —
but see the **hard non-transferable** below: 405's central methodological observation must NOT
be carried into this task.

### Roadmap Alignment

No `roadmap_path` was supplied in the delegation context and no `roadmap_flag` was set, so no
roadmap phases are included. `specs/ROADMAP.md` exists but was not consulted and must not be
modified by this task.

---

## HARD NON-TRANSFERABLE: the trap that will burn dispatches

**Sep is FALSE over order-only dense Dedekind-complete flows.** Read this before writing a line.

Task 405 proved its two Prior gap lemmas from `LinearOrder` + the LUB hypothesis alone, and its
report recorded the observation that "density and the algebraic binders are unused, so these
would also establish the stronger `ValidDedekind`." **That observation does not transfer to
Sep, and an implementer who carries it over will spend the whole task on an unprovable goal.**

Counterexample (report section 5.1, hand-checked): take `D = [0,1] ×lex [0,1]`, the
lexicographic square — densely ordered, Dedekind complete, not an ordered group. With
`t = (0,1)` and `P = {(a,0) : 0 < a < 1}`: the antecedent of Sep holds at `t` (`K⁺p` holds; no
`Start` point exists anywhere) while the consequent fails everywhere (no point above `t` is even
a right limit point of `P`). Sep is refuted.

Sep is true over `ValidDedekindDense` **only because** the `AddCommGroup` / `IsOrderedAddMonoid`
/ `DenselyOrdered` / `Nontrivial` binders force the flow to be Archimedean, hence separable
(a countable order-dense subset exists). Every one of those binders is consumed:

| Binder | Where consumed |
|---|---|
| `AddCommGroup`, `IsOrderedAddMonoid` | `arch_of_lub`, `exists_half_le`, `exists_null_seq`, `exists_countable_order_dense` (Phase 1) |
| `DenselyOrdered` | `exists_half_le`; and step 5 of the argument (non-degeneracy of the `I_u` intervals) inside `sep_order` (Phase 2) |
| `Nontrivial` | supplies the `a > 0` that seeds the null sequence (Phase 1) |
| LUB hypothesis | `arch_of_lub` (Phase 1) and the `sup a_n` in `nested_core` (Phase 2) |

**Consequences for the implementer**: do not attempt an order-only proof; do not weaken the
statement to `ValidDedekind`; do not "simplify" Phase 1 away as scaffolding. Phase 1 is the
mathematical heart of the task, not boilerplate.

---

## Goals & Non-Goals

**Goals**:
- `sep_valid` and `sep_swap_valid` in `FormalSystem/Metalogic/Soundness.lean` both sorry-free,
  with statements **unchanged** (so the two call sites need no edit).
- The two lemmas remain **two separate lemmas**. They are consumed at different call sites
  (`axiom_dedekind_valid` and `axiom_dedekind_swap_valid`); bundling them into a conjunction
  misreports two obligations as one and was already tried and reverted upstream. Do not bundle.
- The deliberate fidelity deviation from Reynolds' cardinality endgame is **recorded in the
  `sep_valid` docstring**.
- `lake build` AND `lake build BimodalTest` both green.
- In-closure `sorry` count drops from **3** to **1**.

**Non-Goals**:
- No change to `ValidDedekindDense`, `ValidDedekind`, `FrameClass`, or either dispatcher.
- No formalization of the section 5.1 lexicographic-square counterexample (it is documentation,
  not a proof obligation).
- No restatement or re-proof of the Prior gap lemmas.
- No new axioms, no new `sorry`, no vacuous definitions.
- No touching `FormalSystem/Metalogic/WeakCanonical/` — including the remaining
  `Transfer.lean:1242` sorry, which is out of scope — and specifically **not**
  `WeakCanonical/Kamp/`, which is concurrent work.

---

## Corrected DONE-WHEN arithmetic (the task description is stale)

The task description's DONE-WHEN clause was written against the task-391 exit baseline of 5
sorries and has not been updated. Task 405 has since landed and discharged 2. **Use these
numbers, not the description's:**

| | Value |
|---|---|
| Current in-closure `sorry` count (verified at plan time) | **3** |
| Locations | `Soundness.lean:1582`, `Soundness.lean:1605`, `WeakCanonical/Transfer.lean:1242` |
| Correct post-task target | **1** (`WeakCanonical/Transfer.lean` only) |
| Delta | −2, as the description says — but measured from 3, not 5 |

Counting command:
```
grep -rn '^\s*sorry\s*$' --include=*.lean FormalSystem | grep -v Boneyard
```

---

## VERIFICATION TOOLING (read before verifying anything)

1. **`lean_run_code` (MCP) is untrustworthy in this environment.** It reported
   `success: true, diagnostics: []` for `example : 1 = 2 := by rfl`. It silently swallows
   diagnostics. **Do not use it, and do not treat its output as evidence of anything.**
2. **`import Mathlib` does not resolve in this project** — only individual Mathlib modules are
   built. Scratch files must import the specific modules they need.
3. **Ground truth is `lake env lean <absolute-path>` run FROM THE PROJECT ROOT**
   (`/home/benjamin/Projects/BimodalLogic`). A `cd` into a scratch directory breaks `lake env`
   module resolution. Read the exit code.
4. **`lake build` alone is NOT sufficient evidence for DONE.** `lake build BimodalTest` must
   also be green, because `FormalSystem/Metalogic/Decidability/TraceExport.lean` sits outside
   the default target's import closure.

---

## Anchor-text edits only

Line numbers in `Soundness.lean` have shifted since the research report was partly written
(task 405 landed; the file is now 1836 lines and the two Sep sorries are at `:1582` and `:1605`).
Any further edit in Phase 3 shifts them again. **All edits in this plan MUST be performed by
matching unique anchor text, never by line number.** Line numbers appear below only as
navigation hints; if a hint disagrees with the file, trust the anchor text and re-locate.

---

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Implementer carries over 405's "algebra unused" observation and attempts an order-only proof | H | M | The HARD NON-TRANSFERABLE section above, front-loaded; Phase 1 gate requires the separability lemma to exist before Phase 2 starts |
| Implementer re-derives its own decomposition instead of transcribing report section 7 | H | M | `plan-compliance.md`; every phase says "transcribe verbatim from report §7.x"; the report is the single authoritative copy of the tactic text |
| `Formula.untl` / `Formula.snce` argument order mis-transcribed | M | L | Report section 4 documents the trap: the **first** argument is the target, the second is the guard. The tree already matches Reynolds. Do not "fix" the encoding |
| `Dᵒᵈ` instance friction in `sep_order_mirror` | M | L | Must use explicit `OrderDual.toDual` / `OrderDual.ofDual` exactly as in report §7.3. A bare `exact h` and the `OrderDual.toDual_lt_toDual` rewrite **both fail** with instance-defeq errors. Do not attempt either |
| `exists_isGLB_of_lub` is `private` in `Soundness.lean` and unreachable from the new file | M | H (certain) | Phase 1 re-declares it (private) in `Separability.lean`; the `Soundness.lean` copy stays in place for `prior_S_gap_valid`. Deliberate duplication, noted in a comment |
| Two new Mathlib imports perturb the build graph | L | L | Verified: exactly `Mathlib.Algebra.Order.Archimedean.Basic` and `Mathlib.Data.Set.Countable` are needed and sufficient; full assembly compiles in ~4s |
| New docstrings reintroduce task-number citations | L | M | `.claude/rules/no-task-references-in-deliverables.md`: the replacement docstrings MUST cite Reynolds §7 lemma 10, not any task number. The existing `follow-up: task 406` text is being deleted, not preserved |
| Concurrent-session edits collide | L | L | Stage only the files this task owns; do not touch `WeakCanonical/` |

---

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2 | 1 |
| 3 | 3 | 2 |

Strictly sequential: Phase 2 appends to the file Phase 1 creates, and Phase 3 imports it.
Phases within the same wave could run in parallel; here each wave holds one phase.

---

### Phase 1: Separability of the flow [COMPLETED]

**Goal**: Establish that the `ValidDedekindDense` binder set forces a countable order-dense
subset to exist — the single mathematical input that makes Sep true (see HARD NON-TRANSFERABLE).

**Tasks**:
- [x] Create `FormalSystem/Metalogic/SoundnessLemmas/Separability.lean` with the standard
      Apache-2.0 file header (copy the shape from `SoundnessLemmas/DenseValidity.lean`).
- [x] Imports: `Mathlib.Algebra.Order.Archimedean.Basic` and `Mathlib.Data.Set.Countable`.
      These two are required and sufficient — do not add others speculatively. This file needs
      no `FormalSystem` import: its content is pure order/group theory with no `Formula` or
      `TruthAt` dependency.
- [x] Open `namespace FormalSystem.Metalogic.SoundnessLemmas` (matching the sibling modules).
- [x] Add a module docstring (`/-! # ... -/`) stating what the file provides and **why** — that
      the algebraic binders of `ValidDedekindDense` are load-bearing for Sep, unlike the Prior
      gap lemmas. Cite Reynolds §7 lemma 10 as the source. **No task numbers.**
- [x] Re-declare `exists_isGLB_of_lub` here as `private`, verbatim from
      `Soundness.lean` (anchor: `private theorem exists_isGLB_of_lub`). Leave the
      `Soundness.lean` copy untouched — `prior_S_gap_valid` still uses it. Add a one-line comment
      recording that this is a deliberate duplicate of the `Soundness.lean` helper, needed
      because that one is `private`.
- [x] Transcribe **verbatim from research report §7.2**, in order:
      `exists_half_le`, `arch_of_lub`, `exists_null_seq`, `exists_countable_order_dense`.
      The first three are `private`; `exists_countable_order_dense` is public (Phase 3 does not
      need it from outside, but Phase 2 does).
- [x] Verify: `lake build FormalSystem.Metalogic.SoundnessLemmas.Separability` green, zero
      warnings, zero `sorry`.

**Timing**: 1 hour

**Depends on**: none

**Files to modify**:
- `FormalSystem/Metalogic/SoundnessLemmas/Separability.lean` — new file, ~120 lines

**Verification**:
- `lake build FormalSystem.Metalogic.SoundnessLemmas.Separability` exits 0 with no warnings.
- `grep -n 'sorry' FormalSystem/Metalogic/SoundnessLemmas/Separability.lean` returns nothing.
- Spot-check against report §7.2: `arch_of_lub`'s closing step is
  `exact absurd hle (not_le_of_gt h2)` reached via `sub_lt_iff_lt_add.mp` — **not** `linarith`,
  which fails here (ordered group, no multiplication). `c + (a - c) = a` closes with `abel`,
  **not** `ring`.

**Anti-pattern for this phase**: attempting to source Archimedean-ness from Mathlib. There is no
usable route: `ConditionallyCompleteLinearOrderedField.to_archimedean` covers fields only, and
`SecondCountableTopology.of_separableSpace_orderTopology` needs `TopologicalSpace` + `OrderTopology`
instances this tree does not carry — introducing `Preorder.topology` locally would add
instance-unification risk to every downstream `[LinearOrder D]` lemma. Both were investigated and
rejected. `arch_of_lub` is proved locally in 13 lines.

---

### Phase 2: The order-theoretic core [COMPLETED]

**Goal**: Prove the abstract order-theoretic content of Reynolds §7 lemma 10 and its past-directed
mirror, with no reference to formulas or truth.

**Tasks**:
- [x] Append **verbatim from research report §7.3** to `Separability.lean`, in order:
      `nested_core`, `sep_order`, `sep_order_mirror`. All three are public.
- [x] `nested_core` implements the nested-interval endgame (step 8 of the report's step map);
      `sep_order` is steps 1-6 plus the call into `nested_core`; `sep_order_mirror` is
      `sep_order` instantiated at `Dᵒᵈ`.
- [x] **`sep_order_mirror` is ~20 lines, not a ~130-line hand-mirror.** Instantiating the forward
      core at `Dᵒᵈ` is the whole technique. This deliberately differs from task 405's approach
      (which hand-dualised its `prior_S` lemma) because there the dualised body was ~25 lines and
      here it is ~130.
- [x] In `sep_order_mirror`, the `OrderDual` coercions **must be written explicitly**
      (`OrderDual.toDual` / `OrderDual.ofDual`), exactly as in the report. A bare `exact h` and
      the `OrderDual.toDual_lt_toDual` rewrite were both tried and **both fail** with an
      instance-defeq error. Do not retry them.
- [x] Add docstrings to all three lemmas explaining their role in the §7 lemma 10 argument.
      **No task numbers.**
- [x] Verify with the same scoped build.

**Timing**: 1 hour

**Depends on**: 1

**Files to modify**:
- `FormalSystem/Metalogic/SoundnessLemmas/Separability.lean` — append ~140 lines

**Verification**:
- `lake build FormalSystem.Metalogic.SoundnessLemmas.Separability` exits 0, no warnings.
- No `sorry` in the file.
- No automation (`simp`/`aesop`/`omega`/`decide`) appears anywhere in `nested_core` or
  `sep_order` — the goals are `∃`/`∀` over an abstract `LinearOrder` with an opaque set, so
  automation is not merely discouraged here, it does not apply. If a transcription attempt
  produces a goal that `simp` closes, the transcription is wrong.
  *(deviation: altered — this criterion overstates report §7.3, which itself uses `simp_all`
  twice, in the `| zero =>` base cases of `hmonoA`/`hmonoB` inside `nested_core`. Those close
  the `ℕ`-induction bookkeeping goal `m ≤ 0 → (seq m).1 ≤ (seq 0).1`, not any order-theoretic
  step. Transcribed verbatim per plan-compliance; no `aesop`/`omega`/`decide` anywhere, and no
  mathematical step is automated.)*

---

### Phase 3: The two validity lemmas, and comment cleanup [COMPLETED]

**Goal**: Discharge both `sorry` bodies in `Soundness.lean` and remove every comment that the
discharge falsifies.

**Tasks**:
- [x] Add `import FormalSystem.Metalogic.SoundnessLemmas.Separability` to `Soundness.lean`'s
      import block (anchor: the existing
      `import FormalSystem.Metalogic.SoundnessLemmas.FrameClassVariants` line). **This task DOES
      change `Soundness.lean`'s imports** — unlike task 405, which touched none.
- [x] Replace the `sorry` body of `sep_valid` with the proof from research report **§7.4**,
      transcribed verbatim. *(deviation: altered — the three cross-module references are written
      `SoundnessLemmas.exists_countable_order_dense` / `SoundnessLemmas.sep_order` /
      `SoundnessLemmas.sep_order_mirror` rather than bare, since Phases 1-2 landed in a separate
      module as this plan directed while the report's verification file was single-namespace. No
      tactic text changed.)* Anchor on the theorem statement, not the line number. **The theorem
      statement is unchanged** — do not touch the signature.
- [x] Replace the `sorry` body of `sep_swap_valid` with the proof from report §7.4, verbatim.
      Statement unchanged. Keep it a **separate lemma**; do not merge with `sep_valid`.
- [x] Neither call site needs an edit: `axiom_dedekind_valid`'s `| sep φ => exact sep_valid φ`
      and `axiom_dedekind_swap_valid`'s `| sep ψ => exact sep_swap_valid ψ` already typecheck.
      Confirm they are untouched.
- [x] **Docstring rewrite — `sep_valid`.** Delete the whole `-- sorry: assumes Sep is
      semantically valid on real flow; ... follow-up: task 406.` block (anchor:
      `-- sorry: assumes Sep is semantically valid`). Replace with proof-summary prose that MUST
      record all of:
      - the source: Reynolds 1992 §7 lemma 10;
      - the separability input (a countable order-dense subset, derived from the algebraic
        binders via Archimedean-ness) and that the algebraic binders are therefore load-bearing;
      - **the deliberate fidelity deviation** (see below).
      Follow the shape task 405 used for the Prior docstrings. **No task-number citations** —
      `.claude/rules/no-task-references-in-deliverables.md` applies to `.lean` files.
- [x] **Docstring rewrite — `sep_swap_valid`.** Delete its `-- sorry: assumes the temporal dual
      ... follow-up: task 406.` block (anchor: `-- sorry: assumes the temporal dual of Sep`).
      Keep the existing prose above it explaining why the swap is a genuinely separate semantic
      fact and why it is not folded into a conjunction — that paragraph is still true and still
      wanted. Add a sentence recording that the proof reuses the forward core via
      `sep_order_mirror`, i.e. `sep_order` at `Dᵒᵈ`.
- [x] **Section-comment cleanup.** Delete the trailing debt paragraph of the section comment
      (anchor: `The two Prior gap lemmas are proved below` through
      `This paragraph can be deleted outright once they are discharged.`). Task 405's implementer
      wrote it as a self-contained block naming `sep_valid`/`sep_swap_valid` specifically so it
      could be deleted wholesale rather than edited around. **Delete it wholesale.** Replace with
      a single sentence recording that the Dedekind soundness chain is now sorry-free.
- [x] **Two now-false comments.** Fix both:
      - anchor `the 3 Reynolds axioms route to the strategic-sorry lemmas above` — they no longer
        route to strategic sorries;
      - anchor `-- The three Reynolds Dedekind axioms: the only debt in this theorem.` — there is
        no debt in this theorem any more.
- [x] Update `FormalSystem/Metalogic/SoundnessLemmas/README.md`: add the `Separability.lean` row
      to the Modules table with its line count and a one-line description, and refresh the
      `*Last verified*` date.

**Timing**: 1 hour

**Depends on**: 2

**Files to modify**:
- `FormalSystem/Metalogic/Soundness.lean` — 1 import added, 2 `sorry` bodies replaced (~70 lines
  in), 2 docstrings rewritten, 1 section paragraph deleted, 2 comments corrected
- `FormalSystem/Metalogic/SoundnessLemmas/README.md` — one table row plus date

**Verification** (all four are required; none alone is sufficient):
- `lake build` exits 0.
- `lake build BimodalTest` exits 0. **Required** — `Metalogic/Decidability/TraceExport.lean` sits
  outside the default target's import closure, so `lake build` alone would miss a regression there.
- `grep -rn '^\s*sorry\s*$' --include=*.lean FormalSystem | grep -v Boneyard` returns exactly
  **1** line, and it is `WeakCanonical/Transfer.lean:1242`.
- `#print axioms FormalSystem.Metalogic.sep_valid` and
  `#print axioms FormalSystem.Metalogic.sep_swap_valid` each report
  `[propext, Classical.choice, Quot.sound]` — no `sorryAx`. Run via a scratch file and
  `lake env lean` from the project root, per VERIFICATION TOOLING above.

---

## The documented fidelity deviation (must be recorded in the `sep_valid` docstring)

`.claude/rules/lean4.md` requires following a cited literature source step-by-step, so this
deviation is deliberate, bounded, and **must not be left silent**.

**What is followed exactly.** Reynolds' lemma 10 is followed step-for-step through his `S`
construction, his relative-density condition, his `I_u` adjacent-interval construction, and his
separation observation (steps 1-6 of the report's step map). Nothing is skipped or automated.

**What is replaced.** Reynolds' endgame (his step 7) thins `S` to a countable subset, invokes
Cantor's theorem that a countable dense linear order without endpoints is isomorphic to ℚ,
observes that ℚ has uncountably many gaps, and derives an uncountable pairwise-disjoint family of
non-degenerate intervals — impossible in ℝ. That is replaced by an equivalent Baire-style nested
interval construction over ℕ (`nested_core`), which uses the *same* essential input — separability
of the flow — packaged as "each `I_u` contains a point of a fixed countable dense `Q`". The two
packagings are the same fact; the second is the standard proof of the first.

**Why.** Reynolds' route needs Cantor's back-and-forth theorem (a substantial development not in
this tree) and cardinal arithmetic on gaps, which would drag `Cardinal` into the soundness chain.
Reynolds' "no last point" condition is also dropped, since it exists only to secure order type ℚ.

**Why this is not a prohibited shortcut.** No automation is used anywhere in the core; the source
is followed to step 6; and the substitution is a mathematically equivalent restructuring of the
source's own final move, adopted for a stated formalization reason rather than after a tactic
failure.

**A silent divergence from the cited source is not acceptable.** A future reader comparing the
Lean against Reynolds §7 must not be left wondering where `S ≅ ℚ` went. The `sep_valid` docstring
is where that is recorded.

---

## Testing & Validation

- [x] `lake build` green.
- [x] `lake build BimodalTest` green.
- [x] In-closure `sorry` count is exactly 1 (`WeakCanonical/Transfer.lean:1242`).
- [x] `#print axioms` on both target lemmas shows no `sorryAx`.
- [x] Both `sep_valid` and `sep_swap_valid` still exist as two separate theorems with unchanged
      statements; both call sites unedited.
- [x] No `sorry` and no `axiom` introduced in `Separability.lean`.
- [x] `grep -niE 'task [0-9]|tasks [0-9]' FormalSystem/Metalogic/Soundness.lean
      FormalSystem/Metalogic/SoundnessLemmas/Separability.lean` returns nothing (the
      no-task-references rule applies outside `specs/**`).
- [x] The section-comment debt paragraph is gone, and neither of the two now-false comments
      survives.
- [x] `FormalSystem/Metalogic/WeakCanonical/` is untouched (`git status --short` shows no file
      under it).

## Artifacts & Outputs

- `FormalSystem/Metalogic/SoundnessLemmas/Separability.lean` (new, ~260 lines)
- `FormalSystem/Metalogic/Soundness.lean` (modified: import, two proof bodies, docstrings, comments)
- `FormalSystem/Metalogic/SoundnessLemmas/README.md` (modified: one module row)
- `specs/406_.../summaries/01_*-summary.md` (implementation summary)

## Rollback/Contingency

Each phase is independently green-buildable and should be committed as it lands
(`task 406 phase {P}: {name}`), so rollback is per-phase `git revert`.

- **Phase 1 or 2 fails to compile**: the failure is a transcription typo, not a mathematical
  problem — the exact text compiled at research time with EXIT=0 against this same pin. Diff the
  written block against report §7.2/§7.3 character by character before changing any tactic.
  Do **not** substitute an alternative tactic; report section 9 records that the obvious
  alternatives (`linarith`, `ring`, `gcongr` in the wrong spot, `le_of_nsmul_le_nsmul`) fail or
  do not exist.
- **Phase 3 glue fails**: the `simp only [...]` unfolding lists in §7.4 are exact and include
  `Formula.swapTemporal` for the swap lemma. A `TruthAt` goal that will not unfold usually means
  a missing entry in that list, not a wrong proof.
- **`lake build` green but `lake build BimodalTest` red**: do not declare done. Fix forward; the
  new module is pure order theory and should not affect `TraceExport.lean`, so a red test build
  points at an import-graph surprise worth understanding before proceeding.
- **Contingency on the file-placement choice**: report §7.1 records a verified alternative —
  inline all of Phases 1 and 2 into `Soundness.lean` immediately before `sep_valid`, with the two
  Mathlib imports at its top. The import-graph change is identical either way. Falling back to
  this is acceptable if the new module hits an unexpected build-graph problem; it is not a reason
  to re-derive anything.
