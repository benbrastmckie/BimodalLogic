# Implementation Plan: Effective Periodic Extension over Finite ℤ-Frames

- **Task**: 441 - effective_periodic_extension_over_finite_frames
- **Status**: [IMPLEMENTING]
- **Effort**: 16 hours
- **Dependencies**: None blocking. Coordinates with task 417 (concurrently `[IMPLEMENTING]`) — see "Concurrency Contract with Task 417" below.
- **Research Inputs**: `specs/441_effective_periodic_extension_over_finite_frames/reports/01_effective-periodic-extension.md`
- **Artifacts**: plans/01_effective-periodic-extension.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: false

## Overview

Strengthen `thm:extension` for the finite-`WorldState`, `D = ℤ` case from a Zorn-backed existence
result into an effective one: a finite lasso certificate a model checker can emit and re-verify.
The already-landed `BiLasso` structure is the Deliverable-2 datatype and is reused unchanged; the
work is (a) an additive origin offset so a window at arbitrary absolute times is representable,
(b) a choice-free computable successor/predecessor selection, (c) the orbit rho-decomposition that
*produces* a lasso from a window, (d) the two-tier `extend_periodic` statement, and (e) the
agreement lemma with its three limits stated prominently.

Definition of done: Tier A (`IntPresentation.extend_periodic`) and Tier B
(`TaskFrame.extend_periodic`) both proved sorry-free; the agreement lemma proved; the module
docstring carrying the measured `#print axioms` output, the three limits, and the literature
quotation; a machine-checked axiom-evidence test module; zero modifications to
`BiLasso/Basic.lean`.

### Research Integration

The research report is integrated as follows: `BiLasso` is named outright as the Deliverable-2
datatype (report §"Already exists"), the origin-offset gap is resolved in the plan rather than
mid-proof (§5), the choice measurements are carried into the docstring-wording constraints of
Phase 5 (§6), the third limit on Deliverable 3 is added to the two the task description names
(§7), and the contiguous-window-first sequencing is fixed as the phase order (§3). The report's
nine suggested phases map to Phases 1-10 here, with its "orbit rho decomposition" phase split
forward/backward to keep each phase inside a single agent run.

### Prior Plan Reference

No prior plan for task 441. Task 417's plan
(`specs/417_semantic_fmp_finite_worldstate_over_z/plans/05_annotated-bi-lasso-decision-layer.md`)
was read for coordination only — see the concurrency contract below. Nothing is copied from it.

### Roadmap Alignment

No `specs/ROADMAP.md` in this repository; no roadmap phases added.

---

## Decisions Settled Before Phase 1

These are settled here so no phase re-litigates them. Deviating from any of them is a `[BLOCKED]`
escalation, not an implementer judgment call (see `.claude/rules/plan-compliance.md`).

### D-1. The `FiniteTaskFrame Int` / `IntPresentation` level mismatch — resolved as two tiers

`Finite` is a non-constructive `Prop`; `IntPresentation` is data. They are not interchangeable, and
no bridge between them is written by this task. Two separate theorems are proved, each with its own
name, each docstring naming the other:

| Tier | Name | Carrier | Content |
|---|---|---|---|
| **A (effective, the payload)** | `IntPresentation.extend_periodic` | `P : IntPresentation` | Produces a `PlacedBiLasso P` — three `List (Fin P.card)` plus an `ℤ` origin — with `coherent` decidable, plus the proof that its decoding is a step path extending the given window. This is what ModelChecker consumes. |
| **B (literal, the task's wording)** | `TaskFrame.extend_periodic` | `F : TaskFrame ℤ` with `[Finite F.WorldState]` | The existential the task description states: `∃ σ : F.HF, Extends σ.val.toPartialHistory τ ∧ ∃ n₀ p₀ n₁ p₁ : ℤ, 0 < p₀ ∧ 0 < p₁ ∧ p₀ ≤ Nat.card F.WorldState ∧ p₁ ≤ Nat.card F.WorldState ∧ (∀ x, n₁ ≤ x → σ.path (x + p₁) = σ.path x) ∧ (∀ x, x ≤ n₀ → σ.path (x - p₀) = σ.path x)`. |

Binding consequences:

- **MUST NOT** write any `FiniteTaskFrame ℤ → IntPresentation` extraction. Extracting an
  equivalence to `Fin n` out of a `Prop`-level `∃`, plus decidability of a `Prop`-valued relation,
  is `Classical.choice` in its most literal role and produces a non-computable presentation — it
  destroys exactly the property this task exists to obtain.
- **MUST NOT** derive Tier B from Tier A. Tier B is proved **directly** from
  `exists_repeat_of_card_lt` + `exists_iter_fwd` / `exists_iter_bwd` + `TaskFrame.HFofStepPath`,
  with no presentation anywhere in its proof.
- Tier B uses `[Finite F.WorldState]` as an **instance**, not `FiniteTaskFrame`'s `finite_world`
  **field** (the field needs a `haveI` at every use site — `TaskFrame.lean`'s own
  definitional-content check flags this).
- A Tier-A-to-Tier-B corollary *for presented frames specifically* is permitted and cheap; it is
  a bonus, never the route by which Tier B is obtained.

### D-2. Contiguous window first, gapped domain second — and the gapped case is Tier B only

The paper's remark concerns a **bounded world history** (`WorldHistory` carries a `convex` field,
so no holes). The task description says a **finite domain**, and `PartialHistory.domain : D → Prop`
is arbitrary, so `{0, 5}` is a legal domain with a four-time hole.

- Phases 1-7 handle the **contiguous** window only. The window is handed to the Tier A
  construction as data: `w : List (Fin P.card)` plus `origin : ℤ` plus a pairwise-adjacency
  hypothesis. The `PartialHistory`-on-`Set.Icc a b` interface is a wrapper built in Phase 5, not
  the core input.
- Phase 8 handles the **gapped** finite domain, by filling each consecutive-pair gap:
  `respects_task a b` → `F.TaskRel (τ a) (b - a) (τ b)` → `taskRel_eq_iter` → `exists_path_of_iter`
  gives an explicit filler.
- **MUST NOT** attempt the gapped case before the contiguous one. The gap bookkeeping (ordering
  the finite domain, iterating consecutive pairs, concatenating fillers) is most of the work and
  none of the insight, and doing it first buries the lasso construction the task is actually about.
- **The gapped case is delivered at Tier B only.** `exists_path_of_iter` yields a `Prop`-level
  existential filler, so a gapped **Tier A** certificate would not be data. A computable gap filler
  would need a bounded path search over the presentation; that is deliberately out of scope and is
  recorded in Phase 10 as a follow-up, not silently omitted. Tier A stays contiguous-window-only,
  and its docstring says so.

### D-3. Seriality is already discharged — `extend_periodic` takes no seriality hypothesis

The task description's "Given a `FiniteTaskFrame Int` **with a serial relation**" describes a
hypothesis that is already a structure field:

```
TaskFrame.Serial R := ∀ (w : W) (x : D), 0 ≤ x → (∃ u, R w x u) ∧ (∃ v, R v x w)
```

(`FormalSystem/Semantics/TaskFrame.lean:358`), and `TaskFrame.serial` is a `TaskFrame` field
(`:556`). Instantiating at `x = 1` gives forward *and* backward one-step seriality directly. On the
Tier A side the corresponding licences are the `IntPresentation` fields `P.fwd` and `P.bwd`.

- **MUST NOT** add a seriality hypothesis to `extend_periodic` at either tier. Doing so duplicates
  a field and diverges from the frame-intrinsic discipline `Extension.lean`'s docstring is explicit
  about (`cor:occurrence` was deliberately converted to frame-intrinsic form for this reason).
- Both docstrings **MUST** state that the absence of a seriality hypothesis is deliberate and name
  where seriality actually comes from, so a reader does not read the absence as an omission.

### D-4. `BiLasso` is the Deliverable-2 datatype; the origin offset is additive

`FormalSystem/Metalogic/Decidability/BiLasso/Basic.lean` already contains the prefix-plus-cycle-in-
each-direction structure (`back`/`mid`/`fwd`/`back_ne`/`fwd_ne`/`coherent`), `unrollOf`/`unroll`,
both periodicity lemmas, `unroll_isStepPath`, and `toHF`. It is reused, not rebuilt or duplicated.

`unrollOf` hard-codes `mid` to `[0, |mid|)`, so a window at times `[-7, -3]` is unrepresentable
(the negatives are covered by the periodic `back`). The fix is **additive and lives in a new
file**: `PlacedBiLasso P := { lasso : BiLasso P, origin : ℤ }` with
`PlacedBiLasso.unroll L t := L.lasso.unroll (t - L.origin)`. Shift-invariance is free and
choice-free (research spike, `[propext, Quot.sound]`):

```lean
theorem isStepPath_shift {F : TaskFrame ℤ} {f : ℤ → F.WorldState} (h : IsStepPath F f) (k : ℤ) :
    IsStepPath F (fun t => f (t - k)) := by
  intro n
  have := h (n - k)
  simpa [show n + 1 - k = (n - k) + 1 by omega] using this
```

**MUST NOT** re-normalize the origin to 0 by rotating `back`/`mid`/`fwd`. That is a
seam-and-wraparound exercise with no compensating benefit, and it makes the serialized certificate
harder for a model checker to produce (it emits a window at whatever absolute times its search
used).

### D-5. Docstring wording constraints on ON CHOICE

Measured at HEAD during research. `Classical.choice` **is** unavoidable in practice for
`extend_periodic` as it will actually be written, from two sources, **neither of which is the
successor selection**:

1. **Mathlib's finiteness API.** Every route to "a repeat exists" carries it — including
   `Finset.card_le_card`, the most primitive counting statement in the library — so every derived
   counting lemma does too, `exists_repeat_of_card_lt` included.
2. **The reused `BiLasso` lemmas.** `unroll_isStepPath` and both `unroll_*` periodicity lemmas
   already measure `[propext, Classical.choice, Quot.sound]`; it enters incidentally through
   `BiLasso.length_pos_int`'s `exact_mod_cast`/`Nat.pos_of_ne_zero` step, not through anything
   about ℤ or about the frame. That file is frozen (see the concurrency contract), so it is not
   scrubbable by this task.

The one part of the task's ON CHOICE hope that *does* cash out: a deterministic `succOf` via
`List.find?` over `List.finRange P.card` measures `[propext, Quot.sound]`, is genuinely computable
(no `Classical.dec`, no `Finset.min'`), and is `#eval`-able.

The docstring **MUST**:

- paste the **literal** `#print axioms` output for `IntPresentation.extend_periodic`, not a
  paraphrase of it;
- name both choice sources above, and say explicitly that the successor selection is **not** one of
  them, citing `succOf` and its measured `[propext, Quot.sound]`;
- state that the obstruction is **an API fact, not a proved logical one** — pigeonhole over a
  carrier with decidable equality is constructively valid; Mathlib simply provides no choice-free
  route because `Finset.card` is built on `Multiset`/`Quot` machinery that pulls `Classical.choice`
  in at the base;
- draw the contrast with `TaskFrame.spherical_of_finite`, where the obstruction **is** logical and
  proved: WLEM is derivable from *Spherical* at carrier `Bool` over `D = ℤ` from
  `[propext, Quot.sound]` alone (`wlem_of_spherical`, in
  `Tests/BimodalTest/Semantics/SphericalFiniteAxiomTest.lean`), so a choice-free proof there would
  prove WLEM in Lean's intuitionistic core and cannot exist;
- **claim neither constructivity nor impossibility** for `extend_periodic`. No logical obstruction
  is known and none is asserted either way;
- record what **is** preserved from the paper's claim: **no Zorn.** `extend_periodic` does not
  route through `PartialHistory.exists_maximal_extension`. This is checkable (see the mechanical
  criterion in Phase 5's verification) and is a real, non-vacuous difference from `thm:extension`.

### D-6. Deliverable 3 has three limits, not two

The task description names two. Research found a third, and sharpened the first. All three go in
the module docstring **before** the theorem statement (the task asks for "PROMINENTLY … and not
merely in passing"; a reader skimming for the theorem must hit the limits first).

1. **`box φ` — window agreement is the wrong instrument, not merely insufficient.** `TruthAt`'s box
   clause quantifies over all of `H_F` (`FormalSystem/Semantics/Truth.lean:164`), not over the
   constructed `σ`. Sharper: `TruthAt.box_const` (`Truth.lean:740`) and `TruthAt.box_time_const`
   (`:753`) prove a boxed formula's truth value is independent of the history **and** of the time.
   Box facts are a property of the model, computed once; no window certificate bears on them at all.
   State it this way, not as "agreement on a window is insufficient for box".
2. **`Past φ` / `Future φ` do not transfer.** `untl`/`snce` quantify over all `s : D`
   (`Truth.lean:165-167`), not over the window. Agreement on `dom τ` says nothing about times
   outside it.
3. **No bound on the temporal witness is computable from the lasso, and path periodicity does not
   induce truth periodicity.** The declaration `no_formula_independent_scan_bound` exhibits, for
   **every** integer `N`, a formula whose earliest witness after `t = -1` exceeds `N`, on **one
   fixed** bi-lasso with `|back| = 1`, `|mid| = 0`, `|fwd| = 1` (witness family `prevⁿ p`, whose
   truth set along that path is exactly `[n, ∞)`). Since `N` ranges over every quantity computable
   from the segment lengths and the time, no scan bound that is a function of the lasso alone can
   be correct. **Required corollary sentence in the docstring**: nobody may read "the history is
   eventually periodic with period `p₁`" as licensing "truth of `φ` is eventually periodic with
   period `p₁`". It is not.

Plus the misuse to foreclose by name: the agreement lemma licenses *existential* claims about the
found window (this bounded history really is a fragment of a possible world) and licenses
**nothing** about universal obligations. A design that drops abundance wholesale and cites
`thm:extension` as cover is wrong.

**Citation mechanics for limit 3 — read this before writing the docstring.** The sorry-free
refutation lives at
`specs/417_semantic_fmp_finite_worldstate_over_z/evidence/phase3-scan-bound-is-false.lean`. That
path is available to the implementer here (this plan is under `specs/**`, which is exempt) but
**MUST NOT** be written into any `.lean` file or any other deliverable: the path embeds a task
number, `.claude/rules/no-task-references-in-deliverables.md` forbids it outside `specs/**`, and
`hooks/validate-no-task-references.sh` is a **blocking** write-time gate that will reject the
write. Cite the declaration name `no_formula_independent_scan_bound` and restate in one line what
it exhibits. Do not cite it by numbered path.

### D-7. Literature citation — the footnote is unanchorable; take the fallback deliberately

The source is a `\footnote` at `possible_worlds.tex:1648` with **no `\label`**:

> In this case the conclusion of **\ref{thm:extension}** becomes effective without appeal to Zorn's
> lemma: since $W$ is finite, the forward and backward orbits extending a bounded world history must
> each revisit a world state, so every bounded world history extends to a possible world that is
> eventually periodic in both directions— a finite prefix plus a finite cycle each way— and is
> therefore finitely representable, licensing a finite certificate that a given bounded history is a
> fragment of a possible world.

Research recommended adding a tracked entry under a synthetic key to
`specs/paper-definitions-of-record.md`. **That is not mechanically possible and the plan takes the
fallback instead**, with evidence: `scripts/check-paper-definitions.sh`'s `resolve_text` supports
exactly two anchor kinds — `env` (resolved by `grep -nF "\label{$label}"`) and `aitem` (resolved by
`\aitem{...}`) — and errors on any other kind. Both require a marker that this footnote does not
have, and the paper is read-only input to this repository, so adding a `\label` is not an option
either.

Fallback, executed in Phase 10: quote the footnote verbatim in the Deliverable-3 module docstring,
labelled explicitly as an **unanchored** footnote in `possible_worlds.tex` §discussion, and add a
short prose "Untracked sources" note to `specs/paper-definitions-of-record.md` recording the
quotation, its location, and the fact that it is untracked **by design** because it carries no
resolvable anchor. **MUST NOT** invent a synthetic manifest row that the checker cannot resolve —
that produces a dangling anchor and a failing check.

---

## Concurrency Contract with Task 417

Task 417 is `[IMPLEMENTING]` concurrently against
`specs/417_semantic_fmp_finite_worldstate_over_z/plans/05_annotated-bi-lasso-decision-layer.md`.
That plan **freezes** `BiLasso/Basic.lean`, asserting `git diff --exit-code` on that path at every
phase close, precisely so that task 441 can consume it. This plan honours the freeze symmetrically.

| Rule | Detail |
|---|---|
| **`Basic.lean` is frozen for this task too** | **MUST NOT** modify `FormalSystem/Metalogic/Decidability/BiLasso/Basic.lean`. Every phase's verification includes `git diff --exit-code FormalSystem/Metalogic/Decidability/BiLasso/Basic.lean` returning 0. |
| **`Periodic.lean` is 417's filename** | 417's Phase 5 creates `FormalSystem/Metalogic/Decidability/BiLasso/Periodic.lean` for generic `cyc`/`unrollOf` helpers over an arbitrary carrier. **MUST NOT** create that file. |
| **Reuse-if-landed check (explicit, Phase 1 opens with it)** | Run `ls FormalSystem/Metalogic/Decidability/BiLasso/` and `grep -rn "structure .*Lasso\|extend_periodic\|periodicExtension\|def cyc" FormalSystem/ --include=*.lean \| grep -v Boneyard`. **If `Periodic.lean` exists**: import it and reuse its generic helpers rather than defining a second copy; record the decision in the phase notes. **If it does not exist**: proceed without it, keep any needed arithmetic local to this task's own new files, and record the duplication as a deliberate, known, post-merge unification follow-up (Phase 10). Re-run this check at the start of Phase 3 as well, since 417 may land it mid-flight. |
| **No shared aggregator edit** | `BiLasso.Basic` is deliberately **not** registered in `FormalSystem/Metalogic/Decidability.lean` (verified: the aggregator's import list does not mention it). This task's new modules match that: **MUST NOT** add them to `Decidability.lean` while 417 is in flight. Aggregator registration is a post-merge follow-up recorded in Phase 10. Build them by explicit module name instead. |
| **`BiLasso/README.md`** | Not frozen by 417's plan, but 417 authored it. Phase 10 may append a section only after confirming `git diff --exit-code` on it is clean; otherwise defer the README note to the task summary and record it as a follow-up. |

### Territory owned by this task (new files only)

- `FormalSystem/Metalogic/Decidability/BiLasso/Extend.lean`
- `FormalSystem/Metalogic/Decidability/BiLasso/Successor.lean`
- `FormalSystem/Metalogic/Decidability/BiLasso/Orbit.lean`
- `FormalSystem/Metalogic/Decidability/BiLasso/Agreement.lean`
- `FormalSystem/Semantics/Extension/PeriodicExtension.lean`
- `Tests/BimodalTest/Metalogic/PeriodicExtensionAxiomTest.lean`

Plus, in Phase 10 only: `specs/paper-definitions-of-record.md` and (conditionally)
`FormalSystem/Metalogic/Decidability/BiLasso/README.md`.

---

## Goals & Non-Goals

**Goals**:

- Tier A `IntPresentation.extend_periodic`: from a contiguous window, construct a `PlacedBiLasso P`
  whose decoding is a step path of `P.toTaskFrame` extending the window, with `coherent` decidable.
- Tier B `TaskFrame.extend_periodic`: the literal existential of the task description over
  `TaskFrame ℤ` with `[Finite F.WorldState]`, proved directly, no presentation.
- Choice-free, computable `succOf` / `predOf` with correctness lemmas, and machine-checked axiom
  evidence in a test module.
- Deliverable 3: the agreement lemma against the existing `Extends` relation, plus a module
  docstring carrying all three limits before the theorem.
- The gapped finite-domain case at Tier B.
- Zero `sorry`, zero new axiom, zero vacuous definition.

**Non-Goals**:

- Any modification to `BiLasso/Basic.lean`, or creation of `BiLasso/Periodic.lean`.
- Any `FiniteTaskFrame ℤ → IntPresentation` extraction (D-1).
- A computable gap filler / gapped **Tier A** certificate (D-2) — recorded as a follow-up.
- Replacing or weakening `PartialHistory.extension`. This task strengthens the finite case; the
  general Zorn theorem remains exactly as it is for arbitrary `W` and `D`.
- Re-baselining the three pre-existing red `BimodalTest` modules (`BoxSpreadProbe`,
  `RegionGateProbe`, `TableauConformance` — `#guard_msgs` mismatches failing identically against
  HEAD). Inherited and out of scope.
- Scrubbing `Classical.choice` out of `BiLasso.length_pos_int` (frozen file).
- Registering the new modules in `Decidability.lean` while 417 is in flight.

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Duplicating `BiLasso` because it landed concurrently and is easy to miss | H | M | D-4 names it outright as the D2 datatype; Phase 1 opens by reading `Basic.lean`; the reuse-if-landed check is a Phase 1 and Phase 3 gate |
| Colliding with task 417 on `Basic.lean` or `Periodic.lean` | H | M | Concurrency contract above: `git diff --exit-code` on `Basic.lean` at every phase close; `Periodic.lean` filename forbidden; no aggregator edit |
| Discovering the origin-offset gap mid-proof and redesigning | H | L | Resolved in D-4: additive `PlacedBiLasso` in `Extend.lean`, shift lemma spike-verified |
| Attempting the gapped domain first and drowning in bookkeeping | M | M | D-2 fixes the order; Phase 8 is last of the required phases and is Tier B only |
| Over-claiming (or under-claiming) constructivity in the docstring | H | M | D-5 gives exact wording constraints; `#print axioms` output pasted literally; axiom evidence lives in a test module, not only in prose |
| Understating or burying the three limits | H | M | D-6; limits go before the theorem statement; each cites a named declaration rather than asserting in prose |
| Writing a `specs/417_...` path into a `.lean` file, tripping the blocking no-task-references hook | M | M | D-6 citation mechanics: cite `no_formula_independent_scan_bound` by declaration name only |
| Treating the optional choice-free pigeonhole as required | M | M | Phase 9 is explicitly optional, depends on nothing downstream, and Phase 10 does not depend on it; its failure is a recorded finding, never a blocker |
| Adding a seriality hypothesis that duplicates a frame field | M | M | D-3; both docstrings must state the absence is deliberate |
| Confusing pre-existing `BimodalTest` redness for a regression | M | M | Baseline named in Non-Goals; phase verification is scoped to explicit module names, never bare `lake build BimodalTest` |
| Phase 3/4 orbit decomposition larger than one agent run | M | M | Split forward (Phase 3) / backward + assembly (Phase 4); each carries a Scope Hypothesis line |

## Implementation Phases

**Dependency Analysis**:

| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1, 2 | -- |
| 2 | 3 | 2 |
| 3 | 4 | 1, 3 |
| 4 | 5 | 4 |
| 5 | 6, 7 | 5 |
| 6 | 8, 9 | 6, 7 (Phase 8); 5 (Phase 9) |
| 7 | 10 | 6, 8 |

Phases within the same wave can execute in parallel.

---

### Phase 1: `Extend.lean` — origin offset and placement [COMPLETED]

**Goal**: A new module giving a `BiLasso` an origin, so a window at arbitrary absolute times on ℤ
is representable, with the decoding proved to be a step path and to land in `H_F`.

**Tasks**:
- [x] Run the reuse-if-landed check from the concurrency contract (`ls` on the `BiLasso/`
      directory plus the `grep` for existing lasso/periodic declarations). Record the outcome and
      the resulting decision (reuse `Periodic.lean` vs. proceed without it) in the phase notes.
      *(outcome: `Periodic.lean` HAS landed; decision recorded in the Phase 1 note below — not
      importable for this phase's purpose, no duplication introduced)*
- [x] Read `FormalSystem/Metalogic/Decidability/BiLasso/Basic.lean` in full before writing anything.
- [x] Create `FormalSystem/Metalogic/Decidability/BiLasso/Extend.lean` with a module docstring
      stating that it is additive over the frozen `Basic.lean` and why the origin field exists
      (`unrollOf` pins `mid` to `[0, |mid|)`; a window at negative times is otherwise
      unrepresentable).
- [x] `structure PlacedBiLasso (P : IntPresentation) where lasso : BiLasso P; origin : ℤ`.
- [x] `def PlacedBiLasso.unroll (L : PlacedBiLasso P) (t : ℤ) : Fin P.card := L.lasso.unroll (t - L.origin)`.
- [x] `theorem isStepPath_shift` — transcribe the spike verbatim (D-4).
- [x] `theorem PlacedBiLasso.unroll_isStepPath` via `isStepPath_shift` and
      `BiLasso.unroll_isStepPath`.
- [x] `def PlacedBiLasso.toHF` via `TaskFrame.HFofStepPath`.
- [x] Restate both periodicity lemmas at the offset: `PlacedBiLasso.unroll_sub_back_length`
      (thresholded at `t < L.origin`) and `PlacedBiLasso.unroll_add_fwd_length` (thresholded at
      `L.origin + |mid| ≤ t`).
- [x] `#print axioms` on `isStepPath_shift`; confirm it is `[propext, Quot.sound]` and record it.
      *(measured: `[propext, Quot.sound]`. `PlacedBiLasso.unroll_isStepPath` measures
      `[propext, Classical.choice, Quot.sound]`, inherited from `BiLasso.unroll_isStepPath` —
      D-5 source 2, expected.)*

#### Phase 1 Note — reuse-if-landed outcome

`ls FormalSystem/Metalogic/Decidability/BiLasso/` shows eight modules landed by task 417 since
this plan was written, `Periodic.lean` among them. **Decision: do not import it here, and no
duplication is thereby incurred.** `Periodic.lean` supplies `cyc` / `unrollOf` and the two
periodicity lemmas at an arbitrary `[Inhabited α]`, but `BiLasso`'s `coherent` field and
`BiLasso.unroll` are stated against `Basic.lean`'s own `Fin P.card`-specialised copies, not
against the generic ones. Everything this phase needs — `unroll_sub_back_length`,
`unroll_add_fwd_length`, `unroll_isStepPath` — is therefore consumed **from `Basic.lean`
directly**, and no arithmetic is restated here at all: `Extend.lean` adds only the shift, and
routes every periodicity claim through `Basic.lean`'s. `Periodic.lean`'s own docstring records the
Basic/Periodic unification as a follow-up owned by whichever task introduces a shared abstraction;
this task does not introduce one, so that follow-up is unaffected.

**Scope Hypothesis check**: asserted "exactly one new file, no more than seven declarations".
Actual: one new file, **nine** declarations — the seven planned plus `PlacedBiLasso.unroll_def`
and `PlacedBiLasso.unroll_mid`. Both are rewriting conveniences consumed by later phases
(`unroll_mid` is what Phase 6's agreement lemma reads the window through); recorded here rather
than spilled forward, as the Scope Hypothesis directs.

**Manifest**: `FormalSystem.Metalogic.Decidability.BiLasso.Extend` added to
`scripts/module-invariants-manifest.txt`, holding invariant C6 at its baseline count — the new
module is unreachable from every Lake target root, exactly as 417's eight are.

**Timing**: 1.5 hours

**Depends on**: none

**Verification Tier**: local

**Scope Hypothesis**: this phase asserts it creates exactly one new file and adds no more than
seven declarations. Confirm at implementation time by listing the declarations actually added; if
the placed periodicity restatements need auxiliary arithmetic lemmas, add them here rather than
spilling into a later phase, and record the count difference.

**Files to modify**:
- `FormalSystem/Metalogic/Decidability/BiLasso/Extend.lean` — new

**Verification**:
- `lake build FormalSystem.Metalogic.Decidability.BiLasso.Extend` succeeds.
- `git diff --exit-code FormalSystem/Metalogic/Decidability/BiLasso/Basic.lean` exits 0.
- `FormalSystem/Metalogic/Decidability/BiLasso/Periodic.lean` was not created by this task.
- No `sorry` in the new file.

---

### Phase 2: `Successor.lean` — choice-free computable successor selection [COMPLETED]

**Goal**: Deterministic, computable, choice-free `succOf` / `predOf` on an `IntPresentation`, with
correctness lemmas — the honest residue of the task's "visibly cheaper than the general one".

**Tasks**:
- [x] Create `FormalSystem/Metalogic/Decidability/BiLasso/Successor.lean`.
- [x] `def IntPresentation.succOf (P : IntPresentation) (w : Fin P.card) : Fin P.card` via
      `(List.finRange P.card).find? (fun u => P.step w u)`, with the `none` branch discharged from
      `P.fwd` using `List.find?_eq_none.mp` and `List.mem_finRange`. Transcribe the research spike.
- [x] `theorem IntPresentation.succOf_step : P.step w (P.succOf w) = true`.
- [x] `def IntPresentation.predOf` and `theorem IntPresentation.predOf_step`, the mirror via
      `P.bwd` (search over `fun v => P.step v w`).
- [x] `def IntPresentation.iterSucc (P) (w : Fin P.card) : ℕ → Fin P.card` and `iterPred`, plus
      their one-step unfolding lemmas. *(the one-step lemmas are `iterSucc_zero`/`iterSucc_succ`/
      `iterPred_zero`/`iterPred_succ`, plus the adjacency forms `iterSucc_step`/`iterPred_step`
      that Phases 3-4 consume)*
- [x] `#print axioms` on all four of `succOf`, `succOf_step`, `predOf`, `predOf_step`; each must be
      `[propext, Quot.sound]`. Record the literal output.
- [x] `#eval` `succOf` on a small concrete presentation to demonstrate computability (no
      `Classical.dec`, no `Finset.min'` in the term). *(landed as four `#guard_msgs`-gated `#eval`
      blocks, so computability is build-breaking evidence rather than a one-off observation)*

#### Phase 2 Note — measured axiom profiles

Literal output, all six choice-free as required:

```
'FormalSystem.Metalogic.Decidability.IntPresentation.succOf' depends on axioms: [propext, Quot.sound]
'FormalSystem.Metalogic.Decidability.IntPresentation.succOf_step' depends on axioms: [propext, Quot.sound]
'FormalSystem.Metalogic.Decidability.IntPresentation.predOf' depends on axioms: [propext, Quot.sound]
'FormalSystem.Metalogic.Decidability.IntPresentation.predOf_step' depends on axioms: [propext, Quot.sound]
'FormalSystem.Metalogic.Decidability.IntPresentation.iterSucc' depends on axioms: [propext, Quot.sound]
'FormalSystem.Metalogic.Decidability.IntPresentation.iterPred' depends on axioms: [propext, Quot.sound]
```

**Manifest**: `FormalSystem.Metalogic.Decidability.BiLasso.Successor` added to
`scripts/module-invariants-manifest.txt`.

**Timing**: 1 hour

**Depends on**: none

**Verification Tier**: local

**Verification**:
- `lake build FormalSystem.Metalogic.Decidability.BiLasso.Successor` succeeds.
- All four `#print axioms` results are `[propext, Quot.sound]` — if any shows `Classical.choice`,
  the definition took a non-`find?` route and must be corrected before the phase closes.
- The `#eval` produces a value (proving genuine computability, not merely a choice-free proof).
- `git diff --exit-code` on `Basic.lean` exits 0.

---

### Phase 3: `Orbit.lean` — forward orbit repeat and rho decomposition [NOT STARTED]

**Goal**: The substantive construction, forward half: iterate `succOf` from the window's right
endpoint, apply pigeonhole to force a revisit, and extract a forward tail plus a non-empty forward
cycle as `List (Fin P.card)` with adjacency along each.

**Tasks**:
- [ ] Re-run the reuse-if-landed check (417 may have landed `Periodic.lean` since Phase 1).
- [ ] Create `FormalSystem/Metalogic/Decidability/BiLasso/Orbit.lean`.
- [ ] `theorem orbit_repeat`: the forward orbit `fun n => P.iterSucc w n` restricted to
      `[0, P.card]` has a repeat — `∃ i j, i < j ∧ j ≤ P.card ∧ iterSucc w i = iterSucc w j`. Route
      via `by_contra` + `Fintype.card_le_of_injective` (research-surveyed as succeeding). Expect
      `[propext, Classical.choice, Quot.sound]`; this is D-5 source 1 and is expected, not a defect.
- [ ] Extract the rho decomposition: `fwdTail` (the pre-period list, `iterSucc w 0 .. i-1`) and
      `fwdCycle` (`iterSucc w i .. j-1`), both as `List (Fin P.card)`.
- [ ] `theorem fwdCycle_ne_nil` from `i < j`.
- [ ] Adjacency lemmas: `P.step` holds between consecutive entries of `fwdTail ++ fwdCycle`, and
      wraps from the last entry of `fwdCycle` back to its first.
- [ ] Length bound: `fwdCycle.length ≤ P.card`.

**Timing**: 2 hours

**Depends on**: 2

**Verification Tier**: local

**Scope Hypothesis**: this phase asserts the forward half is ~5-7 declarations in one new file and
that `Fintype.card_le_of_injective` closes the pigeonhole. Confirm by building; if that route
fails, try `Fintype.exists_ne_map_eq_of_card_lt` or
`Finset.exists_ne_map_eq_of_card_lt_of_maps_to` (both research-measured as available, both
carrying `Classical.choice` identically) before escalating.

**Files to modify**:
- `FormalSystem/Metalogic/Decidability/BiLasso/Orbit.lean` — new

**Verification**:
- `lake build FormalSystem.Metalogic.Decidability.BiLasso.Orbit` succeeds.
- `#print axioms orbit_repeat` recorded (expected `[propext, Classical.choice, Quot.sound]`).
- No `sorry`; no vacuous definition.
- `git diff --exit-code` on `Basic.lean` exits 0.

---

### Phase 4: Backward mirror and window assembly into a `PlacedBiLasso` [NOT STARTED]

**Goal**: The backward mirror of Phase 3, and the assembly function that turns a contiguous window
plus both orbit decompositions into a `PlacedBiLasso P` with `coherent` discharged.

**Tasks**:
- [ ] `orbit_repeat_pred`, `bwdTail`, `bwdCycle`, `bwdCycle_ne_nil`, and the mirrored adjacency and
      length lemmas — the exact mirror of Phase 3 via `predOf` / `iterPred`.
- [ ] Fix the segment layout explicitly and document it in a comment, since `BiLasso`'s field
      conventions are positional: `back := bwdCycle` (indexed left-to-right in time,
      `back[|back|-1]` at `t = -1` relative to the lasso origin), `mid := reverse bwdTail ++ window
      ++ fwdTail`, `fwd := fwdCycle` (`fwd[0]` at `t = |mid|`).
- [ ] `def lassoOfWindow (P) (w : List (Fin P.card)) (hw : pairwise adjacency along w)
      (hne : w ≠ []) : BiLasso P` — assembling the three lists and discharging `back_ne`, `fwd_ne`,
      and `coherent`. Discharge `coherent` from the per-segment adjacency lemmas plus the seam
      lemmas (tail-to-window, window-to-tail, cycle wraparound), reusing
      `BiLasso.step_of_mem_window`'s shape as the model for index arithmetic.
- [ ] `def placedOfWindow (P) (w) (hw) (hne) (origin : ℤ) : PlacedBiLasso P` — `lassoOfWindow`
      paired with the origin adjusted for the backward tail's length, so that the window's first
      entry sits at the caller's absolute time.
- [ ] `theorem placedOfWindow_unroll_window`: for every index `k` into `w`, the placed decoding at
      the corresponding absolute time equals `w[k]`. This is the fidelity lemma Phase 6 consumes.

**Timing**: 2 hours

**Depends on**: 1, 3

**Verification Tier**: interface

**Scope Hypothesis**: this phase asserts the backward half mirrors Phase 3 declaration-for-
declaration and that `coherent` is dischargeable from per-segment adjacency plus three seam
lemmas. Confirm by building; if the seam count differs, record the actual seam lemmas added rather
than silently absorbing them.

**Files to modify**:
- `FormalSystem/Metalogic/Decidability/BiLasso/Orbit.lean` — backward half plus assembly
- `FormalSystem/Metalogic/Decidability/BiLasso/Extend.lean` — only if `placedOfWindow` needs an
  API adjustment on `PlacedBiLasso`; note any such change explicitly

**Verification**:
- `lake build FormalSystem.Metalogic.Decidability.BiLasso.Orbit` and
  `... .BiLasso.Extend` both succeed.
- `placedOfWindow_unroll_window` proved sorry-free.
- `git diff --exit-code` on `Basic.lean` exits 0.

---

### Phase 5: Tier A `extend_periodic` and machine-checked axiom evidence [NOT STARTED]

**Goal**: The Deliverable-1 effective statement over an `IntPresentation` for a contiguous window,
with the ON CHOICE result measured, pasted literally, and machine-checked in a test module.

**Tasks**:
- [ ] In `Extend.lean` (or `Orbit.lean`, whichever holds `placedOfWindow`), state and prove
      `IntPresentation.extend_periodic`: given a non-empty window `w : List (Fin P.card)` with
      pairwise adjacency and an `origin : ℤ`, produce `L : PlacedBiLasso P` such that
      `IsStepPath P.toTaskFrame L.unroll`, `L` agrees with `w` at every window time, and both
      periodicity conclusions hold with periods bounded by `P.card`.
- [ ] **No seriality hypothesis** (D-3). Docstring states the absence is deliberate and names
      `P.fwd` / `P.bwd` as where seriality actually comes from.
- [ ] Add the contiguous-window wrapper: a `PartialHistory` on `Set.Icc a b` converted into the
      list-plus-origin form, so the statement is reachable from the `PartialHistory` vocabulary.
      Docstring states Tier A is contiguous-window-only and why (D-2).
- [ ] Run `#print axioms FormalSystem.Metalogic.Decidability.IntPresentation.extend_periodic` and
      paste the **literal** output into the docstring.
- [ ] Write the ON CHOICE docstring paragraph to the exact constraints in D-5 — both sources named,
      successor selection excluded, API-fact-not-theorem stated, `spherical_of_finite` /
      `wlem_of_spherical` contrast drawn, no claim either way, "no Zorn" recorded.
- [ ] Create `Tests/BimodalTest/Metalogic/PeriodicExtensionAxiomTest.lean`, mirroring
      `Tests/BimodalTest/Semantics/SphericalFiniteAxiomTest.lean`'s role for the 440 result: assert
      the axiom profiles of `succOf`, `succOf_step`, `isStepPath_shift` (choice-free) and of
      `extend_periodic` (choice-carrying), so the ON CHOICE claim is machine-checked rather than
      prose-only.

**Timing**: 2 hours

**Depends on**: 4

**Verification Tier**: interface

**Scope Hypothesis**: this phase asserts one theorem plus one wrapper plus one new test module.
Confirm at implementation time; if the `Set.Icc` wrapper needs its own supporting lemmas about
`PartialHistory.domain`, record them rather than deferring them to Phase 8.

**Files to modify**:
- `FormalSystem/Metalogic/Decidability/BiLasso/Extend.lean` — the Tier A theorem and its docstring
- `Tests/BimodalTest/Metalogic/PeriodicExtensionAxiomTest.lean` — new

**Verification**:
- `lake build FormalSystem.Metalogic.Decidability.BiLasso.Extend` and
  `lake build BimodalTest.Metalogic.PeriodicExtensionAxiomTest` both succeed. **Do not** run bare
  `lake build BimodalTest` as a gate — it is red at three pre-existing modules (see Non-Goals).
- The docstring contains the literal `#print axioms` string, not a paraphrase.
- **"No Zorn" mechanical criterion**: `grep -c "exists_maximal_extension\|PartialHistory.extension"`
  returns 0 across every file this task created, and none of them imports
  `FormalSystem.Semantics.Extension.Extension`. (`Extends` and `PartialHistory` come from
  `FormalSystem/Semantics/PartialHistory.lean`, which carries no Zorn route.)
- `git diff --exit-code` on `Basic.lean` exits 0.

---

### Phase 6: Deliverable 3 — the agreement lemma and its three limits [NOT STARTED]

**Goal**: The theorem ModelChecker consumes, plus the module docstring that makes misusing it hard.

**Tasks**:
- [ ] Create `FormalSystem/Metalogic/Decidability/BiLasso/Agreement.lean`.
- [ ] State agreement at the level of **states**, against the existing `Extends` relation so it
      composes with `thm:extension`'s own vocabulary:
      `Extends (placedToHF L origin).val.toPartialHistory τ` — i.e. `dom τ ⊆ ℤ` (free; the
      constructed history is total) plus `∀ t ∈ dom τ, decoded t = τ t`. Prove it from
      `placedOfWindow_unroll_window`.
- [ ] Add a `decide`-ability note/lemma: on a presentation, pointwise agreement over the finite
      window is decidable, which is what makes this a *certificate* rather than an assurance.
- [ ] Write the module docstring with the three limits of D-6 **before** the theorem statement, in
      this order: (1) box — window agreement is the wrong instrument, citing `TruthAt.box_const`
      and `TruthAt.box_time_const` by name; (2) `Past`/`Future` — `untl`/`snce` quantify over all
      `s : D`; (3) no formula-independent scan bound, citing `no_formula_independent_scan_bound` by
      **declaration name only** (D-6 citation mechanics — never the `specs/417_...` path), with the
      required corollary sentence that path periodicity does not induce truth periodicity.
- [ ] Add the misuse-foreclosure paragraph: the lemma licenses existential claims about the found
      window and licenses nothing about universal obligations; dropping abundance wholesale and
      citing `thm:extension` as cover is wrong.

**Timing**: 1.5 hours

**Depends on**: 5

**Verification Tier**: interface

**Files to modify**:
- `FormalSystem/Metalogic/Decidability/BiLasso/Agreement.lean` — new

**Verification**:
- `lake build FormalSystem.Metalogic.Decidability.BiLasso.Agreement` succeeds.
- The docstring's limits section precedes the theorem statement in the file.
- All three limits cite a named declaration; none is asserted in bare prose.
- `grep -n "417\|task [0-9]" FormalSystem/Metalogic/Decidability/BiLasso/Agreement.lean` returns
  nothing (the no-task-references hook is blocking; this confirms the write will not be rejected).
- `git diff --exit-code` on `Basic.lean` exits 0.

---

### Phase 7: Tier B — the literal `FiniteTaskFrame ℤ` statement [NOT STARTED]

**Goal**: The task description's literal wording, over a general finite frame, proved directly with
no presentation anywhere in the proof.

**Tasks**:
- [ ] Create `FormalSystem/Semantics/Extension/PeriodicExtension.lean`.
- [ ] State `TaskFrame.extend_periodic` over `{F : TaskFrame ℤ} [Finite F.WorldState]` exactly as
      written in D-1's Tier B row. Use the `[Finite F.WorldState]` **instance**, not
      `FiniteTaskFrame.finite_world`.
- [ ] Prove it directly: `exists_iter_fwd` / `exists_iter_bwd` for orbit existence,
      `exists_repeat_of_card_lt` for the revisit, `TaskFrame.HFofStepPath` to land in `F.HF`.
      **MUST NOT** route through Tier A or through any presentation.
- [ ] **No seriality hypothesis** (D-3). Docstring states the absence is deliberate, names
      `TaskFrame.serial` instantiated at `x = 1` as the source, and points at the frame-intrinsic
      discipline `Extension.lean`'s docstring sets out.
- [ ] Docstring states the relation to `thm:extension` explicitly: this **strengthens** the finite
      discrete case and does not replace the general theorem, which remains as it is for arbitrary
      `W` and `D`.
- [ ] Docstring cross-references Tier A by name as the effective, certificate-bearing counterpart,
      and states why the two are different theorems rather than one (D-1: `Finite` is
      non-constructive, `IntPresentation` is data).
- [ ] Optional and cheap: the Tier-A-to-Tier-B corollary for presented frames specifically.

**Timing**: 1.5 hours

**Depends on**: 5

**Verification Tier**: local

**Files to modify**:
- `FormalSystem/Semantics/Extension/PeriodicExtension.lean` — new

**Verification**:
- `lake build FormalSystem.Semantics.Extension.PeriodicExtension` succeeds.
- The proof term references no `IntPresentation` declaration (grep the file).
- `FormalSystem/Semantics/Extension/Extension.lean` is unmodified.
- `git diff --exit-code` on `Basic.lean` exits 0.

---

### Phase 8: The gapped finite domain (Tier B) [NOT STARTED]

**Goal**: The task's literal "partial history on a FINITE domain" wording, permitting holes, derived
from the contiguous result.

**Tasks**:
- [ ] State `TaskFrame.extend_periodic_of_finite_domain` over a `PartialHistory` whose domain is
      finite but not necessarily convex.
- [ ] Order the finite domain and iterate over consecutive pairs. For each pair `a < b`:
      `respects_task` gives `F.TaskRel (τ a) (b - a) (τ b)`, `taskRel_eq_iter` turns that into
      `iter F.step (b - a) (τ a) (τ b)`, and `exists_path_of_iter` produces an explicit filler with
      adjacency at every index.
- [ ] Concatenate the fillers into a contiguous window over `[min dom, max dom]`, then apply
      Phase 7's contiguous result.
- [ ] Docstring records that this is **Tier B only**: a gapped Tier A certificate is not delivered
      because `exists_path_of_iter` yields a `Prop`-level existential filler, so the result would
      not be data. Name the computable-gap-filler bounded search as the follow-up that would be
      needed.

**Timing**: 1.5 hours

**Depends on**: 6, 7

**Verification Tier**: local

**Scope Hypothesis**: this phase asserts the gapped case costs one extra theorem plus the
ordering/concatenation bookkeeping, not a redesign. Confirm at implementation time; if the
concatenation needs its own list-adjacency lemmas, record them.

**Files to modify**:
- `FormalSystem/Semantics/Extension/PeriodicExtension.lean` — gapped-domain theorem

**Verification**:
- `lake build FormalSystem.Semantics.Extension.PeriodicExtension` succeeds.
- No `sorry`.
- `git diff --exit-code` on `Basic.lean` exits 0.

---

### Phase 9: OPTIONAL — hand-rolled choice-free pigeonhole [NOT STARTED]

**Goal**: Attempt to remove D-5's source 1 by proving pigeonhole on `Fin N` directly from
`DecidableEq (Fin N)` by induction on the bound, and measure the effect on the Tier A axiom profile.

**This phase is OPTIONAL and gates nothing.** No later phase depends on it. Phase 10 does not
depend on it. If it fails, that is a **recorded finding**, not a blocker: close the phase as
`[COMPLETED WITH EXCLUSIONS]` with the attempt, the goal state reached, and the reason recorded in
a `#### Reasoned Exclusions` table. **MUST NOT** leave a `sorry` behind, and **MUST NOT** let a
failure here change the status of any other phase.

**Tasks**:
- [ ] Prove a choice-free pigeonhole on `Fin N` (~40 lines expected: induction on the bound using
      `DecidableEq (Fin N)`), in this task's own file — **not** in `Basic.lean`.
- [ ] Re-route `orbit_repeat` through it and re-measure `#print axioms`.
- [ ] Record the result honestly either way. Note that D-5 source 2 (`BiLasso.length_pos_int`'s
      `exact_mod_cast`) is **not** removable by this task, since `Basic.lean` is frozen — so even a
      fully successful pigeonhole may leave `Classical.choice` on any conclusion routed through
      `unroll_isStepPath` or the `unroll_*` periodicity lemmas.
- [ ] Update the D-5 docstring paragraph with whatever was actually measured. Under no
      circumstances weaken the "no claim either way" constraint into a constructivity claim.

**Timing**: 2 hours

**Depends on**: 5

**Verification Tier**: interface

**Scope Hypothesis**: this phase asserts ~40 lines and a real chance of failure. Confirm or refute
at implementation time and record which; a materially larger effort is grounds to stop and record
the finding rather than continue.

**Files to modify**:
- `FormalSystem/Metalogic/Decidability/BiLasso/Orbit.lean` — the pigeonhole and the re-route
- `Tests/BimodalTest/Metalogic/PeriodicExtensionAxiomTest.lean` — updated assertions if the profile
  changed

**Verification**:
- Whatever is landed builds and is sorry-free, or nothing is landed and the finding is recorded.
- If landed, the axiom test module reflects the new measured profile.
- `git diff --exit-code` on `Basic.lean` exits 0.

---

### Phase 10: Citation record, follow-ups, and final verification [NOT STARTED]

**Goal**: Discharge the citation-of-record gap per D-7, record the deliberate follow-ups, and run
the full gate set.

**Tasks**:
- [ ] Add the verbatim footnote quotation to the Deliverable-3 module docstring in
      `Agreement.lean`, labelled explicitly as an **unanchored** footnote in `possible_worlds.tex`
      §discussion — never as if it were a resolvable anchor.
- [ ] Add a short "Untracked sources" prose note to `specs/paper-definitions-of-record.md`
      recording the quotation, its location, and the fact that it carries no `\label`/`\aitem` and
      is therefore untracked by design. **MUST NOT** add a manifest row the checker cannot resolve.
- [ ] Run `bash scripts/check-paper-definitions.sh` and confirm no dangling anchor was introduced.
- [ ] Record the deliberate follow-ups in the implementation summary: (a) registering the new
      modules in `FormalSystem/Metalogic/Decidability.lean` once 417 lands; (b) unifying any
      arithmetic duplicated against 417's `Periodic.lean`; (c) the computable gap filler for a
      gapped Tier A certificate; (d) scrubbing `Classical.choice` from `BiLasso.length_pos_int`,
      which requires unfreezing `Basic.lean`.
- [ ] Conditionally append a section to `FormalSystem/Metalogic/Decidability/BiLasso/README.md`
      describing the new modules — **only** if `git diff --exit-code` on that file is clean at that
      moment. Otherwise defer it to the summary as a follow-up.
- [ ] Final verification sweep (below).

**Timing**: 1 hour

**Depends on**: 6, 8

**Verification Tier**: full

**Scope Hypothesis**: this phase asserts four follow-up items and one conditional README edit.
Confirm the follow-up list against what actually happened in Phases 1-9 and adjust; the list is a
plan-time hypothesis, not a fact.

**Files to modify**:
- `FormalSystem/Metalogic/Decidability/BiLasso/Agreement.lean` — literature quotation
- `specs/paper-definitions-of-record.md` — untracked-source note
- `FormalSystem/Metalogic/Decidability/BiLasso/README.md` — conditional

**Verification**: the full gate set in Testing & Validation below.

---

## Testing & Validation

- [ ] `lake build FormalSystem.Metalogic.Decidability.BiLasso.Extend` succeeds.
- [ ] `lake build FormalSystem.Metalogic.Decidability.BiLasso.Successor` succeeds.
- [ ] `lake build FormalSystem.Metalogic.Decidability.BiLasso.Orbit` succeeds.
- [ ] `lake build FormalSystem.Metalogic.Decidability.BiLasso.Agreement` succeeds.
- [ ] `lake build FormalSystem.Semantics.Extension.PeriodicExtension` succeeds.
- [ ] `lake build BimodalTest.Metalogic.PeriodicExtensionAxiomTest` succeeds.
- [ ] `lake build` (full project) succeeds. The three pre-existing red `BimodalTest` modules
      (`BoxSpreadProbe`, `RegionGateProbe`, `TableauConformance`) are **inherited** `#guard_msgs`
      mismatches failing identically against HEAD — confirm they fail identically and do **not**
      re-baseline them.
- [ ] `grep -rn "sorry" ` across all files created by this task returns nothing.
- [ ] No vacuous definitions (`:= True`, `:= trivial`, `:= Unit`) in any file created by this task.
- [ ] `git diff --exit-code FormalSystem/Metalogic/Decidability/BiLasso/Basic.lean` exits 0.
- [ ] `FormalSystem/Metalogic/Decidability/BiLasso/Periodic.lean` was not created by this task.
- [ ] `FormalSystem/Metalogic/Decidability.lean` is unmodified.
- [ ] `FormalSystem/Semantics/Extension/Extension.lean` is unmodified.
- [ ] "No Zorn" criterion holds: no file created by this task imports
      `FormalSystem.Semantics.Extension.Extension`, and none mentions `exists_maximal_extension`.
- [ ] No `.lean` file created by this task contains a task-number reference (the blocking
      no-task-references hook must have nothing to reject).
- [ ] The Tier A docstring contains the literal `#print axioms` output.
- [ ] The Deliverable-3 docstring's three limits precede the theorem statement.
- [ ] `bash scripts/check-paper-definitions.sh` reports no dangling anchor.

## Artifacts & Outputs

- `FormalSystem/Metalogic/Decidability/BiLasso/Extend.lean` (new) — `PlacedBiLasso`, origin offset,
  shift-invariance, Tier A `extend_periodic`
- `FormalSystem/Metalogic/Decidability/BiLasso/Successor.lean` (new) — choice-free computable
  `succOf` / `predOf`
- `FormalSystem/Metalogic/Decidability/BiLasso/Orbit.lean` (new) — pigeonhole, rho decomposition,
  window assembly
- `FormalSystem/Metalogic/Decidability/BiLasso/Agreement.lean` (new) — Deliverable 3 and the three
  limits
- `FormalSystem/Semantics/Extension/PeriodicExtension.lean` (new) — Tier B, contiguous and gapped
- `Tests/BimodalTest/Metalogic/PeriodicExtensionAxiomTest.lean` (new) — machine-checked ON CHOICE
  evidence
- `specs/paper-definitions-of-record.md` (edited) — untracked-source note
- `specs/441_effective_periodic_extension_over_finite_frames/summaries/01_effective-periodic-extension-summary.md`

## Rollback/Contingency

Every file this task creates is **new**, and the only edits to pre-existing files are the Phase 10
note in `specs/paper-definitions-of-record.md` and the conditional `BiLasso/README.md` append.
Rollback is therefore per-phase and cheap: delete the new module and revert the two edits. Nothing
task 417 owns is touched, so no rollback here can damage its in-flight work, and no rollback of its
work can damage this task's beyond forcing the reuse-if-landed check to be re-run.

Per-phase contingency:
- **Phase 3/4** (the substantive phases): if `coherent` proves undischargeable at the chosen segment
  layout, mark the phase `[BLOCKED]` with the goal state recorded. **Do not** substitute a
  different decomposition — that is a `plan-compliance.md` violation on a `.lean` file and must be
  escalated, not annotated.
- **Phase 9**: failure is expected-possible and is a recorded finding, never a rollback trigger.
- **Zero-debt**: no `sorry`, no new axiom, no Option-B deferral is planned anywhere. If a phase
  proves uncompletable, the correct response is `[BLOCKED]` with the goal state recorded, not a
  placeholder.
