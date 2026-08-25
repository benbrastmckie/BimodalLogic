# Implementation Plan: Completeness Capstone — Consequence Completeness for All Classes

- **Task**: 362 - completeness capstone: consequence completeness for all classes, strong where compact
- **Status**: [IMPLEMENTING]
- **Effort**: 4.75 hours
- **Dependencies**: None live. See "Dependency Status" below — the declared edges (361, 375, 170, 424) are either archived, landed, or non-existent as tasks; no unlanded dependency is assumed anywhere in this plan.
- **Research Inputs**: `specs/362_completeness_capstone_consequence_all_classes_strong_where_compact/reports/01_completeness-capstone-reachability.md`
- **Artifacts**: plans/01_consequence-completeness-all-classes.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: false

## Overview

The research report is a REACHABILITY analysis, and this plan is scoped strictly to what it
found reachable. Leg A — finite-context CONSEQUENCE completeness for `FrameClass.Base`,
`FrameClass.Dense` and `FrameClass.Discrete` — was prototyped end to end against the real build
and compiled sorry-free at exactly `[propext, Classical.choice, Quot.sound]`; it lands here in
three phases. Leg B's substantive result (genuine strong completeness from possibly-infinite
`Γ : Set Formula`) is NOT reachable in this task and is not attempted; only its cheap Base
set-layer mirror lands, and the substance is recorded as a spawn recommendation for the
unspawned successors S2–S5. Legs C and D reduce to documentation currency, including three
false claims about the Lean tree in `latex/subfiles/04-Metalogic.tex`.

Definition of done: `lake build` green; every new Lean terminus audited by `#print axioms` at
exactly `[propext, Classical.choice, Quot.sound]`; zero `sorry` introduced anywhere; the
tracking table in `FormalSystem/Metalogic.lean` and the LaTeX metalogic subfile factually
current with the tree.

### Terminology Discipline (SETTLED 2026-07-27) — binding on every phase

"Strong completeness" is reserved for consequence from possibly-infinite premise sets
(`Γ : Set Formula`) with finitary set-derivability. Every statement in Phases 1–3 takes
`Γ : Context = List Formula` and is therefore **CONSEQUENCE completeness, never strong**. No
docstring, section header, `Metalogic.lean` entry, or LaTeX sentence produced by this plan may
call a finite-context result "strong". Phase 4's `StrongCompletenessBase` is a `Prop`-valued
name for an OPEN obligation over `Set Formula` — the one place the word is correct, and it is
not discharged here.

### Dependency Status — no unlanded dependency is assumed

The task's declared `dependencies` array is `[361, 375, 170, 424]`. The research report
established by machine check (not by reading task metadata) that:

- 361 is **completed and archived** at `specs/archive/361_strong_completeness_architecture_and_weak_terminus_gap_analysis/`.
- 424 is `[COMPLETED]` with a **PASSED** gate verdict.
- 169 (base weak), 170 (dense weak), 375 (discrete weak): the only artifacts leg A consumes
  from them — `BXCanonical.completeness`, `completeness_dense`, `completeness_discrete` — are
  already in the tree and already sorry-free at `[propext, Classical.choice, Quot.sound]`.
- 361, 375 and 170 do not exist as live task entries; `specs/TODO.md:2240`'s "all NOT complete"
  block is stale and self-contradicting.

**Consequence for this plan**: leg A has zero remaining dependencies, and no phase below waits
on, assumes, or references unlanded work. The implementer must NOT re-litigate this from
`specs/TODO.md`; re-verify by symbol with `lean_verify` if verification is wanted.

### Research Integration

Every load-bearing decision below comes from the report and is adopted verbatim:

1. **Base needs no new consequence relation.** `SemanticConsequence`
   (`Semantics/Validity.lean:125`) already binds exactly `valid`'s binder list with
   `(∀ ψ ∈ Γ, TruthAt M τ t ψ) →` inserted, which is precisely the prescribed surgery. Do NOT
   introduce a `SemanticConsequenceBase` synonym — it would be a gratuitous defeq duplicate of
   a definition that already owns the `Γ ⊨ φ` notation (`Validity.lean:135`). The Base section
   therefore has **four** declarations, not Dedekind's six.
2. **No import change is required.** `StrongCompleteness.lean` already reaches
   `BXCanonical.Completeness` transitively through its `BXCanonical.CompletenessDedekind`
   import; the report verified this by deleting the explicit import from the prototype and
   recompiling (exit 0). **The plan must not add an import line.**
3. **The `completeness_dense` / `completeness_discrete` short-name collision is benign** —
   measured, not assumed. The enclosing-namespace declaration wins over `open`, an ambiguity
   probe compiled clean, every out-of-file reference is docstring prose rather than a call
   site, and the two forms have identical types. Worth one sentence in the module docstring;
   not a blocker.
4. **No `_of_engine` layer for Base/Dense/Discrete.** Unlike Dedekind at the time its section
   was written, all three engines already exist — go straight to unconditional.
5. **The `intro` placeholder count is the single likely failure mode.** It is tabulated in
   Phases 1–3 and must be copied from the table, not re-derived.

### Prior Plan Reference

No prior plan.

### Roadmap Alignment

No `roadmap_path` was supplied in the delegation context; `specs/ROADMAP.md` was not consulted
and is not modified by this plan.

## Goals & Non-Goals

**Goals**:
- Land unconditional finite-context consequence completeness for `FrameClass.Base`,
  `FrameClass.Dense` and `FrameClass.Discrete` in `FormalSystem/Metalogic/StrongCompleteness.lean`,
  each with its soundness guard and weak corollary, sorry-free.
- Replace the three "Reserved / intentionally absent" section-header prose blocks, which become
  false the moment the material lands.
- Close the visible Base/Dense asymmetry in the set layer by adding the four missing Base
  definitions and `strongCompletenessBase_of_compact`, reducing leg B to exactly one named
  obligation per class (**scope extension** — see Phase 4).
- Soften the Dedekind non-compactness prose so "unavailable on the primary source's own terms"
  is not read as "machine-refuted", a status only Discrete actually has.
- Bring `FormalSystem/Metalogic.lean`'s tracking table current with four new entries.
- Correct three false claims about the Lean tree in `latex/subfiles/04-Metalogic.tex` and
  refresh four adjacent currency edits (**scope extension** — see Phase 6).

**Non-Goals**:
- **S2–S5 are not attempted.** The ultraproduct carrier, the Łoś lemma for `TruthAt`,
  `ModelExistenceBase`/`ModelExistenceDense` hence `CompactBase`/`CompactDense`, and genuine
  strong completeness for Base and Dense are, by 361's own decomposition
  (`design/04_subtask-decomposition.md`), separate multi-phase tasks. **They do not exist as
  tasks.** 361's GATING RULE is explicit that 424's PASSED verdict *authorizes their creation
  and nothing more*. Attempting them here would violate both the gating rule's spawn protocol
  and phase-sizing discipline. This plan records the authorization and recommends spawning
  them; that recommendation belongs in the task summary, **not in a `sorry`**.
- Not discharging the `engine` hypothesis in `strongCompletenessBase_of_compact`. It is kept
  live deliberately, exactly as the Dense version keeps it, so that `CompactBase` is isolated
  as the whole of the remaining obligation. Note in the docstring that it is *now*
  dischargeable at `BXCanonical.completeness` — but do not discharge it.
- Not formalizing a Dedekind non-compactness witness. Out of scope and not obviously cheap: the
  Discrete witness leans on `IsSuccArchimedean`, which Dedekind does not have. Phase 4 takes
  the prose-softening option instead.
- No new `sorry` anywhere, and no `sorry` is permitted. Every Lean obligation in Phases 1–5 was
  compiled to completion against the real build by the research prototype.
- No import lines added to `StrongCompleteness.lean` (finding 2 above).

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Wrong `intro` placeholder count (one `_` per instance binder) — the report names this as *the* likely failure mode | M | M | Copy the per-class count from the table in each phase (Base 4, Dense 5, Discrete 8); on mismatch read the goal with `lean_goal` rather than guessing |
| Implementer adds `import FormalSystem.Metalogic.BXCanonical.Completeness` | L | M | Explicit MUST NOT in Phases 1–3; the transitive import was verified by deletion + recompile |
| Implementer introduces a `SemanticConsequenceBase` synonym against the report's recommendation | M | M | Phase 1 states the reuse decision and its reason; the Base section is four declarations by construction |
| `completeness_dense`/`completeness_discrete` short-name shadowing surprises a downstream file | L | L | Measured benign (ambiguity probe exit 0; all out-of-file refs are prose; identical types). Phases 2–3 carry `interface` tier and build direct dependents |
| Scope extension (Phase 4 `SetConsequence.lean`, Phase 6 `latex/`) beyond the declared `file_scope` | M | H (certain) | Both are called out as explicit, user-visible decisions in their phase bodies with a stated decline path; declining either leaves every other phase unaffected |
| A finite-context result gets described as "strong" somewhere in prose | M | M | Terminology Discipline section above is binding; Phase 5 and 6 verification steps grep for it |
| Drift toward attempting S2–S5 when leg B looks close | H | L | Non-Goals is explicit; Phase 4 lands only the mirror and keeps `engine` live |
| LaTeX edits break the document build | L | L | Phase 6 verification compiles `latex/BimodalReference.tex` with `latexmk` |

## Implementation Phases

**Dependency Analysis**:

| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2 | 1 |
| 3 | 3 | 2 |
| 4 | 4 | 3 |
| 5 | 5, 6 | 4 |

Phases within the same wave can execute in parallel. Phases 1–4 are serialized because 1–3 all
write adjacent reserved sections of the same file (`StrongCompleteness.lean`) and 4 writes it
again; the serialization is file-contention, not mathematical dependency. Phases 5 and 6 are
genuinely parallel — disjoint files (`FormalSystem/Metalogic.lean` vs
`latex/subfiles/04-Metalogic.tex`) — and both need the Lean facts from 1–4 to be true before
they can be asserted.

---

### Phase 1: Base consequence block [COMPLETED]

**Goal**: Land unconditional finite-context consequence completeness for `FrameClass.Base`,
reusing the existing `SemanticConsequence` relation, and replace the section's "Reserved" prose.

**Tasks**:
- [x] Confirm by symbol (`lean_local_search` / `lean_hover_info`) that `truthAt_foldr_imp`,
      `derivable_foldr_imp_iff`, `SemanticConsequence`, `soundness` and
      `BXCanonical.completeness` are present with the signatures the report recorded.
- [x] Replace the "Reserved. Two layers are expected here, and both are intentionally absent
      rather than stubbed" prose under `/-! ## Consequence and strong completeness for
      \`FrameClass.Base\`` (currently near :401) — **replace, do not append**: the claim becomes
      false the moment the block lands.
- [x] In the new prose, state the reuse decision explicitly: Base does not get a
      `SemanticConsequenceBase` synonym because `SemanticConsequence` quantifies over *all*
      carriers and for Base "all carriers" **is** the class. The `SemanticConsequenceDedekindDense`
      docstring's warning is correct for Dedekind/Dense/Discrete and inapplicable here.
- [x] Add `semantic_deduction_base` — the `SemanticConsequence Γ φ ↔ valid (Γ.foldr Formula.imp φ)`
      biconditional, both directions transporting `truthAt_foldr_imp` across the shared binder
      list. **`intro` takes `D` then 4 placeholders**, then `F M τ hτ t`.
- [x] Add `consequence_completeness_base` — `(derivable_foldr_imp_iff Γ φ).mpr` applied to
      `BXCanonical.completeness _ ((semantic_deduction_base Γ φ).mp h)`.
- [x] Add `soundness_base_consequence` — the guard, a two-line proof off
      `soundness` (`Soundness.lean:1080`), whose binder shape `(Γ) (φ) (d) (D) [binders] (F) (M)
      (τ) (h_mem) (t) (h_ctx)` already matches. This is **not** optional decoration: it is what
      stops a mis-stated consequence relation from making the terminus vacuous, the role
      `soundness_dedekind_consequence` already plays for Dedekind.
- [x] Add `completeness_base` — the weak corollary at `Γ := []`, discharging the vacuous
      `∀ ψ ∈ [], _` binder with `simpa using h`.
- [x] MUST NOT add any `import` line (transitive reach verified by deletion + recompile).
- [x] MUST NOT add an `_of_engine` layer — `BXCanonical.completeness` already exists.

**Timing**: 0.75 hours

**Depends on**: none

**Verification Tier**: local

**Commit Mode**: per-substep

**Scope Hypothesis**: This phase asserts **exactly four new declarations** in one file
(`semantic_deduction_base`, `consequence_completeness_base`, `soundness_base_consequence`,
`completeness_base`) and **zero** new definitions — Base reuses `SemanticConsequence`. Confirm
at implementation time by counting `theorem`/`def` keywords added to the Base section against
this figure before closing the phase; if a fifth declaration seems needed, stop and re-read the
report's finding (1) rather than adding a relation.

**Files to modify**:
- `FormalSystem/Metalogic/StrongCompleteness.lean` — replace the Base section's Reserved prose
  (near :401) and add the four declarations under it.

**Verification**:
- `lake build FormalSystem.Metalogic.StrongCompleteness` exits 0 with zero errors.
- Grep the new hunk for `sorry`: zero matches.
- `#print axioms consequence_completeness_base` and `#print axioms completeness_base` each report
  exactly `[propext, Classical.choice, Quot.sound]` (add the audits in Phase 3 alongside the
  Dense/Discrete ones, or provisionally via `lean_verify`).
- The word "strong" does not appear describing any of the four new declarations.

---

### Phase 2: Dense consequence block [COMPLETED]

**Goal**: Land the same four-layer shape for `FrameClass.Dense`, plus the new
`SemanticConsequenceDense` relation it requires.

**Tasks**:
- [x] Replace the "Reserved, same two-layer shape as the Base section above" prose under
      `/-! ## Consequence and strong completeness for \`FrameClass.Dense\`` (currently near :413)
      — replace, do not append.
- [x] Add `def SemanticConsequenceDense`: this is `SetSemanticConsequenceDense`
      (`SetConsequence.lean:70–105` range) with `Γ : Set Formula` changed to `Γ : Context` and
      **nothing else**.
- [x] Add `semantic_deduction_dense`, `consequence_completeness_dense`,
      `soundness_dense_consequence`, `completeness_dense`, mirroring Phase 1 against
      `ValidDense` / `soundness_dense` (`Soundness.lean:1254`) / `BXCanonical.completeness_dense`.
- [x] **`intro` takes `D` then 5 placeholders** — Base's four plus `[DenselyOrdered D]`. This is
      the only thing that varies from Phase 1; copy the count from the table, do not re-derive.
- [x] Add one sentence to the module docstring noting that re-exposing the weak form as
      `FormalSystem.Metalogic.completeness_dense` shadows
      `FormalSystem.Metalogic.BXCanonical.completeness_dense` at `open` sites, that the
      enclosing-namespace declaration wins, and that the two have identical types so a
      re-pointing would be semantically inert.
- [x] MUST NOT add any `import` line.

**Timing**: 0.75 hours

**Depends on**: 1

**Verification Tier**: interface

**Commit Mode**: per-substep

**Scope Hypothesis**: This phase asserts **five new declarations** (one `def`
`SemanticConsequenceDense` plus four theorems) and that the Dense proof text differs from
Phase 1's **only** in the `ValidDense` binder list, the `_dense`-suffixed engine/soundness
lemmas, and one extra `intro` placeholder. Confirm both at implementation time: count the added
declarations, and diff the Dense block against the Base block to check that no third axis of
variation crept in.

**Files to modify**:
- `FormalSystem/Metalogic/StrongCompleteness.lean` — Dense section near :413.

**Verification**:
- `lake build FormalSystem.Metalogic.StrongCompleteness` exits 0.
- Build the module's direct dependents (`FormalSystem.Metalogic`, and any module a
  `grep -rn "completeness_dense" --include=*.lean` shows importing it) to confirm the short-name
  shadowing breaks nothing — the report's repo-wide grep found every out-of-file occurrence to be
  docstring prose, so the expected result is that this check is uneventful; run it anyway.
- Zero `sorry` in the new hunk.

---

### Phase 3: Discrete consequence block and the axiom audit [COMPLETED]

**Goal**: Land the Discrete consequence layer and add the `#print axioms` audit covering all
three new class termini.

**Tasks**:
- [x] Replace the "Reserved — the finite-context consequence layer only" prose under
      `/-! ## Consequence completeness for \`FrameClass.Discrete\`` (currently near :419) —
      replace, do not append.
- [x] Add `def SemanticConsequenceDiscrete`: `SetSemanticConsequenceDiscrete` with
      `Γ : Set Formula` changed to `Γ : Context`, nothing else.
- [x] Add `semantic_deduction_discrete`, `consequence_completeness_discrete`,
      `soundness_discrete_consequence`, `completeness_discrete` against `ValidDiscrete` /
      `soundness_discrete` (`Soundness.lean:1400`) / `BXCanonical.completeness_discrete`.
- [x] **`intro` takes `D` then 8 placeholders** — Base's four plus `[SuccOrder D] [PredOrder D]
      [IsSuccArchimedean D] [IsPredArchimedean D]`.
- [x] Add a `/-! ### Axiom audit -/` block, in the style of the existing one at :392–399,
      carrying `#print axioms` for all six new termini and corollaries from Phases 1–3.
- [x] Note in the Discrete section prose that consequence completeness for Discrete is a
      finite-context result and that the infinitary statement for this class is not merely
      unproved but **machine-refuted** (`discrete_consequence_not_compact`,
      `strongCompletenessDiscrete_refuted`, `DiscreteNonCompactness.lean`) — Discrete is the one
      class where that phrasing is earned.
- [x] MUST NOT add any `import` line.

**Timing**: 0.75 hours

**Depends on**: 2

**Verification Tier**: interface

**Commit Mode**: per-substep

**Scope Hypothesis**: This phase asserts **five new declarations** plus one audit block, and
that leg A totals **twelve** new declarations across Phases 1–3 (4 + 5 + 5, since Base reuses
`SemanticConsequence`) — matching the twelve the research prototype compiled. Confirm the running
total before closing the phase; a count other than twelve means a class picked up an unplanned
relation or lost a soundness guard.

*(Confirmed at implementation time, with one correction to the plan's own arithmetic: the three
per-phase counts land exactly as specified — Base 4, Dense 5, Discrete 5 — but their sum is
**fourteen**, not twelve. `4 + 5 + 5 = 14`; the "twelve" figure is an arithmetic slip in this
plan, not a discrepancy in the implementation. Measured leg-A declarations:
`semantic_deduction_base`, `consequence_completeness_base`, `soundness_base_consequence`,
`completeness_base`; `SemanticConsequenceDense`, `semantic_deduction_dense`,
`consequence_completeness_dense`, `soundness_dense_consequence`, `completeness_dense`;
`SemanticConsequenceDiscrete`, `semantic_deduction_discrete`,
`consequence_completeness_discrete`, `soundness_discrete_consequence`, `completeness_discrete`.
No class picked up an unplanned relation and none lost a soundness guard.)*

**Files to modify**:
- `FormalSystem/Metalogic/StrongCompleteness.lean` — Discrete section near :419, plus the new
  audit block.

**Verification**:
- `lake build FormalSystem.Metalogic.StrongCompleteness` exits 0, then `lake build` full-tree
  green (leg A's acceptance gate).
- Every `#print axioms` in the new audit block reports exactly
  `[propext, Classical.choice, Quot.sound]` — no `sorryAx`, no `Lean.ofReduceBool`.
- `grep -c sorry` over the phase's diff: zero.
- No "Reserved"/"intentionally absent" prose survives in any of the three sections.

---

### Phase 4: Base set-layer mirror, and the Dedekind prose softening [COMPLETED]

**Goal**: Close the Base/Dense asymmetry in `SetConsequence.lean` by adding the four missing Base
definitions and `strongCompletenessBase_of_compact`, and soften the Dedekind non-compactness
claim so it no longer outruns its evidence.

**SCOPE EXTENSION TAKEN.** The delegation context for the implementing dispatch directed this
phase to land "ONLY the cheap Base set-layer mirror (4 defs in SetConsequence.lean +
`strongCompletenessBase_of_compact` with the engine hypothesis kept live), and softening the
Dedekind non-compactness prose", so the extension below was authorised and is taken in full.

**SCOPE EXTENSION — explicit decision, not a silent one.** The task's declared `file_scope` is
`FormalSystem/Metalogic/StrongCompleteness.lean` and `FormalSystem/Metalogic.lean`. This phase
additionally writes `FormalSystem/Metalogic/SetConsequence.lean`. The research report recommends
it (cheap, prototyped, closes a visible asymmetry, reduces leg B to exactly one named obligation
per class) and recommends that the extension be user-visible rather than assumed. **If the
extension is declined**, this phase reduces to the Dedekind prose softening in
`StrongCompleteness.lean` alone, and *nothing else in this plan is affected* — Phases 1–3, 5 and
6 are independent of it, except that Phase 6's "Base and Dense: open" bullet then has no
`CompactBase` symbol to cite.

**Tasks**:
- [x] Add the four missing Base set-layer definitions to `SetConsequence.lean`:
      `StrongCompletenessBase`, `CompactBase`, `SatisfiableBaseSet`, `ModelExistenceBase`. Each
      is its Dense sibling (near :198–229) with `SetSemanticConsequenceBase` (already present at
      :73) / `valid` in place of `SetSemanticConsequenceDense` / `ValidDense`, and the
      `[DenselyOrdered D]` binder dropped.
- [x] Carry each definition's docstring discipline over from its Dense sibling: these are
      `Prop`-valued names for **open obligations**, and the module docstring already says so for
      Dense — say it for Base too.
- [x] Add `strongCompletenessBase_of_compact` to `StrongCompleteness.lean`, next to
      `strongCompletenessDense_of_compact` (near :259): destructure `hc Γ φ h` to `⟨L, hL, hvalid⟩`
      and close with `(derivable_foldr_imp_iff L φ).mpr (engine _ hvalid)`.
- [x] **Keep the `engine` hypothesis live.** Do not discharge it, even though it is now
      dischargeable at `BXCanonical.completeness`. Say so in the docstring — as the Dense
      docstring already does for `completeness_dense` — and state that keeping it live isolates
      `CompactBase` as the entire remaining obligation for Base strong completeness.
- [x] Soften the Dedekind non-compactness prose in the `StrongCompleteness.lean` module docstring
      and in the `consequence_completeness_dedekind_of_engine` docstring (fact 2). The current
      text asserts "It is refuted, not merely unproved" for Dedekind, but **no refutation exists
      in the tree**: there is no `CompactDedekind` definition and no refuting theorem; the claim
      rests on Reynolds 1992 Thm 7 being weak-only. Rewrite to distinguish "unavailable on the
      primary source's own terms" (Dedekind) from "machine-refuted" (Discrete), and flag the
      asymmetry explicitly rather than letting the two classes read as sharing a status —
      `SetConsequence.lean` already models this discipline for Dense vs. Discrete ("The Dense and
      Discrete statements must not be read as sharing a status").
- [x] Record, in prose in the docstring (NOT as a `sorry`), that 424's gate is PASSED and that
      the remaining route is the bespoke ultraproduct decomposed as S2–S5, which **do not exist
      as tasks** and are deliberately not attempted here.
      *(deviation: altered — recorded in the `strongCompletenessBase_of_compact` docstring
      without the task numbers. `.claude/rules/no-task-references-in-deliverables.md` forbids
      task-number citations outside `specs/**`, and `FormalSystem/**` is a deliverable. The
      substance is carried in full: the gate is recorded as passed, the four-step ultraproduct
      route is named, the deliberate non-attempt is stated, and the structural reason the
      chronicle machinery cannot be extended is given. The numbered S2–S5 / 424 references live
      in the task summary, where they are permitted.)*

**Timing**: 1.0 hours

**Depends on**: 3

**Verification Tier**: interface

**Commit Mode**: per-substep

**Scope Hypothesis**: This phase asserts **four new definitions** in `SetConsequence.lean` plus
**one new theorem** in `StrongCompleteness.lean`, and that the Base definitions differ from their
Dense siblings only by the relation/validity symbol and the dropped `[DenselyOrdered D]` binder.
Confirm by diffing each new Base definition against the Dense sibling it mirrors before closing;
any third axis of variation means the mirror is wrong.

**Files to modify**:
- `FormalSystem/Metalogic/SetConsequence.lean` — four Base definitions (**scope extension**).
- `FormalSystem/Metalogic/StrongCompleteness.lean` — `strongCompletenessBase_of_compact`; module
  docstring and `consequence_completeness_dedekind_of_engine` docstring softening.

**Verification**:
- `lake build FormalSystem.Metalogic.SetConsequence` then
  `lake build FormalSystem.Metalogic.StrongCompleteness` both exit 0; then full `lake build`.
- `#print axioms strongCompletenessBase_of_compact` reports exactly
  `[propext, Classical.choice, Quot.sound]`.
- `grep -n "refuted, not merely unproved" FormalSystem/Metalogic/StrongCompleteness.lean` returns
  no hit in a Dedekind context.
- `CompactBase` appears in exactly one place as a hypothesis of
  `strongCompletenessBase_of_compact`, and `engine` is still an explicit argument.
- Zero `sorry` introduced.

---

### Phase 5: Tracking-table update in `FormalSystem/Metalogic.lean` [COMPLETED]

**Goal**: Bring the repo-root aggregator's "Publication-Ready Results" list and "Key Components"
bullet current with what Phases 1–4 landed.

**Note on the file**: this is `FormalSystem/Metalogic.lean` (the aggregator beside
`FormalSystem/Metalogic/`), **not** `FormalSystem/Metalogic/Metalogic.lean`. The content edited
lives inside the single module docstring spanning roughly :17–157.

**Tasks**:
- [x] Add entries to "Publication-Ready Results" (currently :44–75) for the new consequence
      termini, each with its axiom set stated as exactly `propext`, `Classical.choice`,
      `Quot.sound`, in the style of the existing entries.
- [x] Generalize the existing "Consequence completeness (Dedekind)" entry (near :62) to record
      that the finite-context consequence form now exists for **all four** classes.
- [x] Preserve that entry's terminology caveat verbatim in spirit: `Context` is `List Formula`,
      so these are inter-derivable with the weak forms through the deduction theorem and are
      **not** strong completeness. Extend the caveat to cover the three new classes, noting that
      the infinitary statement is machine-refuted for Discrete, open for Base and Dense, and
      unavailable-on-Reynolds's-terms for Dedekind — three distinct statuses that must not be
      collapsed.
- [x] Update the `StrongCompleteness.lean` bullet under "Key Components" (near :101) to mention
      the per-class consequence layer alongside the Dedekind terminus.
- [x] If Phase 4's scope extension landed, mention the Base set-layer mirror
      (`CompactBase` / `StrongCompletenessBase` as named open obligations) in the same bullet.

**Timing**: 0.5 hours

**Depends on**: 4

**Verification Tier**: local

**Commit Mode**: per-substep

**Scope Hypothesis**: This phase asserts **four new list entries** plus **two edited entries**
(the Dedekind consequence entry and the `StrongCompleteness.lean` Key Components bullet), all
inside one docstring in one file. Confirm at implementation time by diffing the docstring: if the
edit touches Lean code rather than docstring text, the tier is wrong and the phase must be
re-verified at `full`.

**Files to modify**:
- `FormalSystem/Metalogic.lean` — module docstring only.

**Verification**:
- `lake build FormalSystem.Metalogic` exits 0 (a malformed `/-! -/` block would fail here — this
  is why the tier is `local` and not `prose`).
- Every claimed axiom set in a new entry matches the corresponding `#print axioms` output from
  Phase 3's audit block; no entry claims SORRY-FREE without that backing.
- No new entry describes a `Context`-based result as "strong completeness".

---

### Phase 6: LaTeX currency in `latex/subfiles/04-Metalogic.tex` [NOT STARTED]

**Goal**: Correct the three false claims the file makes about the Lean tree, and apply four
adjacent currency edits.

**SCOPE EXTENSION — explicit decision.** `latex/` is outside the task's declared `file_scope`
even though leg D is inside the task's SCOPE. Same treatment as Phase 4's: this is a visible
decision. **If declined**, Phases 1–5 are unaffected and the file simply remains stale — but note
that three of its assertions are demonstrably FALSE about the current tree, so declining leaves
known-false published claims in place.

**What leg D as literally briefed no longer requires**: the "Note on Infinite Contexts" TODO the
brief asks to resolve **does not exist** — a grep of the whole `latex/` tree for "Infinite
Context" returns zero matches. The terminology work it was to gate is already done:
`\subsubsection{Consequence Completeness}` (:235) and `\subsubsection{Strong Completeness and
Compactness}` (:267) already implement the settled 2026-07-27 discipline, and :243 already states
that "strong completeness" is reserved for the infinite-premise statement. Do not re-do it.

**Tasks**:
- [ ] `:487` — delete the claim that `completeness` (Base) "carries exactly **one** live
      `sorryAx`, sourced from the deprecated `WeakCanonical.countermodel_discrete` fallback".
      **FALSE**: verified at `[propext, Classical.choice, Quot.sound]`, no `sorryAx`.
      `FormalSystem/Metalogic.lean:48` already records the correction.
- [ ] `:489` — delete the claim that an unconditional `completeness_dedekind` "does not exist"
      and that only `…_of_engine` forms are landed. **FALSE**: `completeness_dedekind` and
      `consequence_completeness_dedekind` are landed unconditionally at
      `StrongCompleteness.lean:398–399` with `#print axioms` audits in the file.
- [ ] `:493` — remove the whole "The one remaining sorry has a specific, named blocker…"
      paragraph. **Moot**: no such sorry.
- [ ] `:536–538` — remove the summary-table footnote restating the same defect ("the Base-class
      instance additionally carries the single live sorry described above"). **FALSE**.
- [ ] `:246–250` — repoint the Consequence Completeness footnote from
      `consequence_completeness_dedekind_of_engine` at the now-unconditional per-class theorems,
      and correct "three-declaration shape": Base is **four** declarations and reuses
      `SemanticConsequence`; Dense and Discrete are **five** each.
- [ ] `:275–290` — in the "Base and Dense: open" bullet, record 424's PASSED gate and the
      ultraproduct route, and add 361's **Q2** finding, which is the more informative half and is
      currently absent: the existing BXCanonical chronicle machinery **structurally cannot** reach
      model existence for arbitrary `SetConsistent` sets, because every countermodel routes
      through `fully_restricted_parametric_completeness_from_neg_membership`, whose three
      coherence hypotheses are root-relative and quantify over `subformulaClosure` /
      `deferralClosure`, both `Finset`-valued; an infinite `Γ` needs coherence over
      `⋃_{ψ ∈ Γ} subformulaClosure ψ`, which is not a `Finset`. This is why the recommended route
      abandons the chronicle rather than extending it. Note also that Q1 (is `⊨_Base`/`⊨_Dense`
      compact?) is **likely but not proved**, and that S2–S5 are authorized-but-unspawned.
- [ ] `:288–296` — in the "Discrete: provably unavailable" bullet, replace prose with citations
      to `discrete_consequence_not_compact` and `strongCompletenessDiscrete_refuted` by name,
      noting the `#print axioms` audits at `DiscreteNonCompactness.lean:295–315`.
- [ ] `:296–302` — apply Phase 4's Dedekind softening to the Dedekind bullet, so Dedekind and
      Discrete do not read as sharing a status.

**Timing**: 1.0 hours

**Depends on**: 4

**Verification Tier**: local

**Commit Mode**: per-substep

**Scope Hypothesis**: This phase asserts **three false claims** (at :487, :489, :536–538, with
:493 moot as a consequence of the first) and **four currency edits** (:246–250, :275–290,
:288–296, :296–302), against a 545-line file. Line numbers are hints from the research pass and
will drift as edits land — re-locate each by its surrounding text, not by line number, and
re-count the false claims found: if a fourth surfaces, fix it and record the discrepancy in the
task summary rather than silently widening the phase.

**Files to modify**:
- `latex/subfiles/04-Metalogic.tex` (**scope extension**).

**Verification**:
- `latexmk` on `latex/BimodalReference.tex` compiles without new errors.
- `grep -in "sorryax\|live sorry\|remaining sorry" latex/subfiles/04-Metalogic.tex` returns no
  claim that contradicts the audited axiom sets.
- Every Lean symbol newly cited in the file exists — check each by `lean_local_search` or
  `grep -rn --include=*.lean`.
- No sentence describes a `Context`-based result as strong completeness.

---

## Testing & Validation

- [ ] `lake build FormalSystem.Metalogic.StrongCompleteness` exits 0 after each of Phases 1–4.
- [ ] `lake build` (full-tree acceptance) exits 0 at the end of Phase 3, Phase 4, and Phase 5.
- [ ] Every new terminus and corollary reports exactly `[propext, Classical.choice, Quot.sound]`
      under `#print axioms` — no `sorryAx`, no `Lean.ofReduceBool`, no `Lean.trustCompiler`.
- [ ] `grep -rn "sorry" ` over the task's full diff shows **zero** additions. No phase requires a
      `sorry` and none is permitted.
- [x] Fourteen new leg-A declarations exist (Base 4, Dense 5, Discrete 5 — the plan's
      "twelve" was an arithmetic slip; the per-class counts are exactly as specified).
- [ ] No "Reserved"/"intentionally absent" prose survives in the three
      `StrongCompleteness.lean` sections that received content.
- [ ] `latexmk` on `latex/BimodalReference.tex` compiles clean (Phase 6 only).
- [ ] Terminology audit: no finite-context (`Context = List Formula`) result is called "strong
      completeness" in any file touched.

## Artifacts & Outputs

- `FormalSystem/Metalogic/StrongCompleteness.lean` — three populated class sections (12 new
  declarations), `strongCompletenessBase_of_compact`, an extended axiom-audit block, and softened
  Dedekind prose.
- `FormalSystem/Metalogic/SetConsequence.lean` — four Base set-layer definitions (scope
  extension).
- `FormalSystem/Metalogic.lean` — refreshed Publication-Ready Results and Key Components.
- `latex/subfiles/04-Metalogic.tex` — three false claims removed, four currency edits (scope
  extension).
- Task summary — must record: (a) the spawn recommendation for S2–S5 under 361's now-satisfied
  gate, with 424's PASSED verdict as the authorization and 361's Q2 finding as the reason the
  chronicle route is not extendable; (b) whether each scope extension was taken or declined; and
  (c) the stale-dependency finding for `specs/TODO.md:2240`. The S2–S5 recommendation belongs
  here and **nowhere in the Lean tree**.

## Rollback/Contingency

Every phase is a self-contained, independently revertible commit against a currently-green tree
(`lake build FormalSystem.Metalogic.StrongCompleteness` is green at 2254 jobs before any of this
lands). Contingencies:

- **A leg-A proof does not close**: the failure is almost certainly the `intro` placeholder count.
  Read the goal with `lean_goal` and match the count to the phase's table. Do not reach for
  `simp`/`aesop`/`omega` — the research prototype compiled every obligation by `exact` term
  application against existing lemmas, with `constructor`/`intro` for the biconditionals and one
  `simpa using h` per weak corollary. No premise search should be needed.
- **The short-name shadowing does break a downstream file** (contrary to measurement): rename the
  weak corollaries to `completeness_dense_consequence_corollary` etc., or follow Dedekind's
  precedent and suffix the engine reference; the consequence termini keep their names either way.
- **Phase 4's scope extension is declined**: revert `SetConsequence.lean` and
  `strongCompletenessBase_of_compact`, keep the Dedekind prose softening, and drop the
  `CompactBase` citation from Phase 6's Base/Dense bullet. No other phase changes.
- **Phase 6's scope extension is declined**: revert `latex/subfiles/04-Metalogic.tex` entirely.
  Phases 1–5 stand alone; record in the summary that three known-false claims about the Lean tree
  remain in the LaTeX source.
- **Full rollback**: `git revert` the phase commits in reverse order. No phase mutates existing
  proofs — Phases 1–4 add declarations and replace reserved-section prose; Phases 5–6 edit
  documentation only — so reverting cannot break a pre-existing result.
