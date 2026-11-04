# Implementation Plan: Task #849

- **Task**: 849 - Discharge or regime-restrict the named hypothesis HasForwardSlack, then land the exact-shift iterated deletion the cell-level downward inclusion still needs
- **Status**: [IMPLEMENTING]
- **Effort**: 13 hours (Phases 1-8 at 1.5 / 2 / 1 / 2 / 1.5 / 1.5 / 2 / 1.5)
- **Dependencies**: None at the `state.json` level. Predecessor record: `specs/844_reanchored_deletion_half_depth_zero_cell/` (its five landed declarations are consumed, none edited)
- **Research Inputs**: `specs/849_forward_slack_discharge_and_exact_shift_iteration/reports/01_forward-slack-exact-shift.md`, with its two compiled prototypes `prototype/climb-witness.lean` and `prototype/helpers-compiled.lean`
- **Artifacts**: plans/01_forward-slack-exact-shift.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: false

## Overview

Piece 1 of the task is decided by the research with a compiled object: the climbing-register
path is a ladder path, pending forever into the past, satisfying the single-block assembly's gap,
and violating `HasForwardSlack` -- so there is no "landed source for the missing lower bound on the
register's climb" to find, and the deliverable is route (b): the regime, stated with its finite
witness, equipped with entry lemmas, a transport lemma, a wired refutation of the unconditional
claim, and a non-vacuity inhabitant. Piece 2 is a reformulation: every landed deletion lemma is
length-agnostic, so `d` deletions of an `l`-block are one deletion of a `d · l`-block, and the real
obstacle is EXACTNESS (a pigeonhole never returns a prescribed length). It is solved by
"overshoot-then-up": delete sampled blocks at spacing `l` until at least `m · (P + 1)` positions
are gone (overshooting by fewer than `budget` blocks of length `l`), then raise by the overshoot
with the register-held iterated duplication of the original pigeonhole block. The cell-level
statement is then made on the witnessing path, which is the only sound form under a path-level
regime. Definition of done: the seven pinned declarations under `## Lean Challenge Statements`
plus the named unpinned ones below are landed in `LadderChain.lean` with no `sorry`, the full
gate is green, the README and docstrings describe the new state, and the reserved name
`cellLE_zero_const_of_kappa_eq` is still claimed by nothing.

Three facts fixed at authoring time, re-derived in source rather than carried:

- **Placement.** `LadderChain.lean` imports `LadderPump.lean` (not the reverse); the lift being
  conjugated lives in `LadderChain.lean`'s `Assembly` section; `LadderPump.lean` is at 1,485 of
  its 1,500 `longFile` lines (`lakefile.toml`); `LadderChain.lean` is at 959 lines. Every new
  declaration goes into `LadderChain.lean`. Settled by the task; not reopened.
- **The seven pinned statements elaborate.** The block under `## Lean Challenge Statements` was
  elaborated standalone against the built library at authoring (`lake env lean` on the block with
  `sorry` bodies: exit 0, seven `declaration uses 'sorry'` warnings, no errors). Five of the seven
  are verbatim from `prototype/helpers-compiled.lean`, whose bodies compiled during research; the
  other two (the exact-shift theorem and the cell inclusion) are new statements whose proofs this
  plan specifies.
- **The landed iteration under-exposes types.** `exists_iterSpliced_ladderPath_of_pend_past`
  (`LadderPump.lean`, section `Iterate`) exposes `tpOf` only below `u + l` and at `u + l`, never at
  the copy boundaries or above the run. That is why the exact-shift construction is
  deletions-first: it needs nothing from the run's interior, at the cost of `budget²` extra slack in
  both the gap and the regime hypothesis. The clean up-first hypotheses are a non-goal here.

### Research Integration

- Route (a) of Piece 1 is closed: `prototype/climb-witness.lean` compiles the refuting path on the
  two-state object (`IsLadderPath`, pending for `p ≤ 0`, the gap with `P = 0`, `¬ HasForwardSlack`).
  Phase 2 wires it into the library under the task's placement rule.
- The five helper statements compiled in `prototype/helpers-compiled.lean` are pinned verbatim
  (Phases 1 and 3); the implementer copies their bodies and adjusts only the surrounding section
  context.
- The research's loop design (spaced pigeonhole at spacing `l`, room `b · (b + 1) ≤ Tc` from `(K2)`
  alone, slack transport by exactly the deleted length, overshoot `< b` blocks, raise by the
  overshoot) is adopted as Phases 5-7, with one change: the loop preserves the object walk and the
  realized types at every position `v ≤ w₀` (inclusive), sampling from `w₀` itself, because the
  deletion type lemma's endpoint equality already preserves the type AT the deleted block's start.
  This removes an off-by-one in the room arithmetic.
- Spacing `P + 1` is rejected (its room `b · (P + 2) ≤ Tc` is not derivable from `ParamsOk`);
  spacing `l` with `l ∣ P + 1` is used.
- The research's "uniqueness lemma for the witness `I`" is folded into Phase 2's inhabitant proof
  (where it is needed concretely) and not landed as a separate general lemma.

### Prior Plan Reference

No prior plan for this task. The predecessor's plan
(`specs/844_reanchored_deletion_half_depth_zero_cell/plans/01_reanchored-deletion-half.md`) is
referenced for three conventions kept here: every phase builds scoped, runs
`scripts/typst-sync-check.sh --fix`, and commits `typst/generated/status.typ` with the `.lean`
file; uncertain statements are not pinned; and the reserved name is never claimed. Its effort
calibration (1-2 hours per additive theorem of 40-120 lines in this module) is reused.

### Roadmap Alignment

No `roadmap_path` was provided to this dispatch; `specs/ROADMAP.md` was not consulted.

## Goals & Non-Goals

- **Goals**:
  - `hasForwardSlack_mono` -- the regime is monotone in the deleted amount (Phase 1).
  - `hasForwardSlack_of_next_region_cnt_le` -- the regime from a bound on the countdown of the
    first region start above the anchor's region, its finite witness (Phase 1).
  - `hasForwardSlack_del` -- the regime transports across a deletion inside the anchor's region,
    decreased by exactly the deleted length (Phase 1).
  - `budget_mul_succ_le_Tc` -- the room bound from (K2) alone (Phase 3).
  - `exists_typeBlock_of_spacing` -- the spaced type pigeonhole (Phase 3).
  - `exists_ladderPath_through_deleted_exact_of_pend_past` -- the exact-shift theorem: the
    countdown lowered by exactly m times (P + 1), register and object state held, realized
    stab-free type held, under the regime at amount m times (P + 1) plus budget squared (Phase 7).
  - `mem_cellAt_of_shift_of_hasForwardSlack` -- the slack-restricted downward cell inclusion,
    stated on the witnessing path (Phase 7).
  - Not pinned, named deliverables: the vacuity entry lemma (idle forever above the region), the
    wired refutation of the unconditional claim on the two-state object, the plateau inhabitant
    (Phase 2), the register-held iterated duplication of a GIVEN block (Phase 4), the one-step
    deletion lemma (Phase 5), and the overshoot loop (Phase 6). Their suggested names are given in
    their phases; they are not pinned because their exact hypothesis lists are expected to be
    adjusted at the goal state.
- **Non-Goals**:
  - Any statement under the reserved name `cellLE_zero_const_of_kappa_eq`, and any cell-level
    statement quantified over the STATE rather than the witnessing path. The research shows no
    state-level hypothesis can replace the path-level regime (the climbing path passes through a
    pending-forever state satisfying every state-level hypothesis the consumer carries).
  - The up-first ordering with the clean hypotheses `HasForwardSlack g z (m · (P + 1)) n` and
    `n + 2 ≤ c`; it needs copy-boundary types the landed iteration does not expose and would mean
    re-deriving the iteration in `LadderChain.lean`. A follow-up, not this task.
  - A compiled proof that no finite deletion-derivative of the tight (doubling) chain lifts; the
    research argues it, and it is recorded as argued, not compiled.
  - Any edit to `LadderPump.lean`, `LadderPin.lean`, `RunLayer.lean`, or `LadderAgree.lean`'s
    proofs; `LadderAgree.lean` receives a docstring-only edit in Phase 8.
  - Re-litigating that `(K1)` does not constrain a spanning block's length.

### Decisions

- **Every new declaration lands in `LadderChain.lean`.** Sections, in file order: the room bound
  joins `section Budget`; the spaced pigeonhole joins a new `section Spacing` directly after
  `section Bridge`; the given-block iterated duplication joins `section AssemblyFin` before the
  regime-A assembly; the regime lemmas go in a new `section Slack` directly after `section DelNxt`;
  the refutation and inhabitant go in a new `namespace ClimbWitness` directly after
  `section Slack`; the one-step deletion, the loop, the exact-shift theorem and the cell inclusion
  go in a new `section DelNxtIter` directly after `section DelNxtFin`, before
  `cellAt_subset_of_shift_of_pend_past`.
- **Pinned headers are copied character-for-character, including their implicit binders.**
  `lean-challenge-snapshot.sh --check` compares the whitespace-normalized header text (from the
  `theorem` keyword to `:=`) of the pinned declaration against the working tree's same-named
  declaration. A header that relies on a section `variable` for `{Q : Type}` or `{pend : Q → Bool}`
  therefore reads as drift. Each pinned declaration is stated with the binders exactly as the
  Challenge block writes them; shadowing a section variable with an explicit binder is permitted
  and harmless in Lean 4.
- **Deletions-first, then the raise.** Chosen over up-first for the exposure reason under
  Overview. The price is the `b · b` summand in the gap and slack hypotheses of the exact-shift
  theorem, where `b` is the type-pigeonhole budget
  `Fintype.card Q * 2 ^ (plusSubformulaClosure φ).card`.
- **The regime-A assembly keeps its statement verbatim** when Phase 4 refactors its body into a
  given-block lemma; it becomes a short corollary. Its statement is not in the Challenge block (a
  same-named declaration in a module importing `LadderChain` would not elaborate), so Phase 4
  verifies fidelity by extracting the header text before and after the edit and diffing it.
- **The concrete two-state witness lives in the library module**, under the task's placement rule,
  on the research's recommendation that the FAIL verdict be a library fact. If a repository lint
  run in Phase 8 rejects a concrete object in `LadderChain.lean`, the sanctioned contingency is to
  relocate ONLY the `ClimbWitness` namespace to a wired probe under
  `specs/evidence/seam-gluing-ray-product/` following `ladder-cell-obligation-refutation.lean`'s
  shape, keeping every regime lemma in the library; this branch is pre-authorized here and is not
  a plan deviation.

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| The loop's bookkeeping (Phases 5-6) is the dominant cost and overruns | M | M | The one-step lemma (Phase 5) is proved separately from the loop (Phase 6); the step mirrors the landed single-block assembly line by line, and the loop is a strong induction whose only new content is composing agreement, slack and histories |
| `ℕ`/`ℤ` cast arithmetic (`Nat.cast_sub`, `toNat`) dominates the probe iterations | M | H | The compiled prototypes carry the working rewrites (`push_cast [Nat.cast_sub …]; ring`, `Int.natCast_nonneg`); copy them. State the loop's slack amount as `R * l + b * l - t * l` with `t * l ≤ R * l + b * l` kept as a hypothesis of every `omega` call |
| Refactoring the regime-A assembly drifts its signature | H | L | Phase 4 diffs the extracted header text before and after; the original statement is kept verbatim and only its body changes |
| A same-named weaker statement slips in under a pinned name | H | L | The seven pinned headers elaborated standalone at authoring; `lean-challenge-snapshot.sh --check` is run in Phase 8 (advisory, exit 0 expected) |
| The parametric plateau inhabitant fights `split_ifs`/`omega` on `% 2` with `C` a variable | M | M | Fallback inside Phase 2: land the inhabitant with a literal `C` (say `3`) and the instances `l ≤ 4`, record the narrowing in the docstring and the issue log, keep the headline existential at that literal; the regime is still shown non-vacuous |
| A repository lint rejects a concrete object (`Bool`, `stepT`, `pendT`) in a library module | M | L | The pre-authorized relocation branch under Decisions; regime lemmas unaffected |
| `typst-sync-check.sh --fix` needs a built library and the pre-commit gate refuses a `.lean` commit without a fresh `status.typ` | M | H | Every phase builds before committing, runs `bash scripts/typst-sync-check.sh --fix`, and names `typst/generated/status.typ` in its pathspec; the gate's own message names the same remedy |
| `lean_local_search` reports `index: error` (as during research) | L | M | Treat an empty result as not proof of absence; every name consumed here was re-opened in source at authoring and is cited with its file and section |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2 | 1 |
| 3 | 3 | 2 |
| 4 | 4 | 3 |
| 5 | 5 | 4 |
| 6 | 6 | 5 |
| 7 | 7 | 6 |
| 8 | 8 | 7 |

Phases within the same wave can execute in parallel. The chain is deliberately linear: Phases 2,
3 and 4 are logically independent of Phase 1, but every phase edits `LadderChain.lean`, so they are
serialized on file territory rather than run concurrently. Phase 8 is the final phase: a terminal
node that depends transitively on every other phase.

**Build command used throughout** (scoped; raise the Bash tool `timeout` to `600000`):

```bash
timeout 590 bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build FormalSystem.Metalogic.Decidability.RaySummary.LadderChain
```

**Commit discipline used throughout**: after the scoped build is green, run
`bash scripts/typst-sync-check.sh --fix` (it needs the built library) and include
`typst/generated/status.typ` in the commit pathspec alongside the `.lean` file; a commit touching
`FormalSystem/**/*.lean` without it is refused by `.githooks/pre-commit`.

**Budget abbreviation used throughout**: `b` stands for
`Fintype.card Q * 2 ^ (plusSubformulaClosure φ).card`, written out in full in every statement
(the module does not define an abbreviation for it, and the pinned statements write it out).

---

### Phase 1: The regime lemmas [COMPLETED]

**Goal**: A new `section Slack` directly after `section DelNxt` holds the three pinned regime
lemmas and the vacuity entry lemma, so that `HasForwardSlack` has an entry point with a finite
witness, is monotone, transports across a deletion, and holds trivially when nothing follows the
anchor's region.

**Tasks**:
- [x] Open `section Slack` with `variable {Q : Type} {step : Q → Q → Bool} {pend : Q → Bool}`
  after `end DelNxt`. State `hasForwardSlack_mono`, `hasForwardSlack_of_next_region_cnt_le`, and
  `hasForwardSlack_del` with the headers EXACTLY as pinned under `## Lean Challenge Statements`
  (explicit `{Q : Type} …` binders included; see Decisions). Copy the three bodies from
  `specs/849_forward_slack_discharge_and_exact_shift_iteration/prototype/helpers-compiled.lean`.
- [x] `hasForwardSlack_of_idle_above` (name suggested, not pinned): for `g`, `z`, `l`, `n`, if
  `∀ i : ℕ, pend (objAt g (z + (cntAt g z : ℤ) + 1 + (i : ℤ))) = false` then
  `HasForwardSlack g z l n`. Proof: `intro I hI hidle hnext`; `hnext` contradicts the hypothesis
  at `i := I` (`Bool.false_ne_true`).
- [x] Docstrings: `hasForwardSlack_of_next_region_cnt_le` names the finite witness (the countdown
  of the first region start above `z`'s region, read at the idle position before it by
  `cntAt_eq_nxtAt_of_idle_pend`); `hasForwardSlack_del` says the transported amount is exactly
  `L - l`; the vacuity lemma says the regime is empty-handed when no region follows.
- [x] `lean_verify` on each fully qualified name: axioms a subset of
  `[propext, Classical.choice, Quot.sound]`, no `sorry`.
- [x] Scoped build green; `typst-sync-check.sh --fix`; commit with both files.

**Timing**: 1.5 hours

**Depends on**: none

**Verification Tier**: local

**Scope Hypothesis**: Four new theorems, no new imports, `LadderChain.lean` grows by roughly 110
lines (from 959; the `longFile` limit is 1500). Confirm by `wc -l` after the edit and by the
scoped build showing no new import edge. The three prototype bodies are expected to compile
unchanged inside the module's own `open` context; confirm by the absence of any edit to a proof
line beyond indentation.

**Tier Justification**: The scoped guarded build of
`FormalSystem.Metalogic.Decidability.RaySummary.LadderChain` plus `lean_verify` on each new name is
the complete covering check -- the edit adds declarations to one module and changes no existing
signature, so no dependent can break.

**Files to modify**:
- `FormalSystem/Metalogic/Decidability/RaySummary/LadderChain.lean` - add `section Slack` after `section DelNxt`
- `typst/generated/status.typ` - regenerated by `scripts/typst-sync-check.sh --fix` before the commit

**Verification**:
- `lean_goal` shows no remaining goals at the end of each proof; the scoped build exits 0 through the guard.
- `lean_verify` on each of the four names reports axioms within the standard profile and no `sorry`.
- The three pinned headers match the Challenge block character-for-character after whitespace normalization (`diff <(sed -n '/^theorem hasForwardSlack_mono/,/:= by/p' LadderChain.lean | sed '$d' | tr -s ' \n' ' ') <(…same extraction from the plan's block…)`, or an equivalent by-eye comparison recorded in the phase notes).

---

### Phase 2: The wired refutation and the non-vacuity inhabitant [COMPLETED]

**Goal**: The FAIL verdict on the unconditional claim is a library fact about a named object, and
the regime is shown inhabited by a path with a next region at every slack amount, so a consumer of
`HasForwardSlack` can see both that the hypothesis is necessary and that it is not a disguised
`sorry`.

**Tasks**:
- [x] Open `namespace ClimbWitness` directly after `end Slack`. Port
  `prototype/climb-witness.lean` verbatim: `stepT`, `pendT`, `climbRaw` (the prototype's `gRaw`),
  `climbRaw_adm`, `climb` (the prototype's `g`), `climb_isLadderPath`, `climb_pend_past`,
  `climb_gap`, `climb_not_hasForwardSlack`, and the headline
  `hasForwardSlack_refuted_unconditional` with the prototype's `refutation` statement:
  `∃ g : ℤ → LadderState Bool pendT, IsLadderPath stepT pendT g ∧ (∀ p : ℤ, p ≤ 0 → pendT (objAt g p) = true) ∧ nxtAt g 0 + (0 + 1) ≤ cntAt g 0 ∧ ¬ HasForwardSlack g 0 (0 + 1) (nxtAt g 0)`.
  The prototype's proofs (`unfold Rlad Drift Count … ; split_ifs <;> simp_all <;> omega`) compiled
  during research; the one `show`-linter warning is already fixed in the saved file.
- [x] The plateau inhabitant, parametric in `C : ℕ`: `plateauRaw C v := if v ≤ C then (true, (C - v).toNat, 0) else if (v - C) % 2 = 1 then (false, 0, 0) else (true, 0, 0)`
  (register constant `0`; `z = 0`'s region has countdown `C`; then alternating idle / length-`1`
  regions). `plateauRaw_adm`, `plateau C`, `plateau_isLadderPath C` (same tactic script as the
  climb, with `% 2` in place of `% 6`), `plateau_pend_past C : ∀ p ≤ 0, pendT (objAt (plateau C) p) = true`,
  `plateau_gap C l (hl : l ≤ C) : nxtAt (plateau C) 0 + l ≤ cntAt (plateau C) 0`, and
  `hasForwardSlack_plateau C l (hl : l ≤ C + 1) : HasForwardSlack (plateau C) 0 l 0`. For the last:
  `intro I hI hidle hnext`; show `I = 1` (if `2 ≤ I`, `hidle 1` says position `C + 2` is idle,
  but it is pending by definition); then `subst` and `simp [nxtAt, cntAt, plateau, plateauRaw]`
  leaves `0 ≤ 0 + C + 1 - l` over `ℤ`, closed by `omega` from `hl`.
- [x] The headline inhabitant `exists_hasForwardSlack_inhabitant (L : ℕ) : ∃ g : ℤ → LadderState Bool pendT, IsLadderPath stepT pendT g ∧ (∀ p : ℤ, p ≤ 0 → pendT (objAt g p) = true) ∧ nxtAt g 0 + L ≤ cntAt g 0 ∧ HasForwardSlack g 0 L (nxtAt g 0)`
  by `⟨plateau L, …, plateau_gap L L le_rfl, hasForwardSlack_plateau L L (by omega)⟩` (with
  `nxtAt (plateau L) 0 = 0` by `rfl`/`simp`). This is the exact mirror of the refutation's
  statement with the negation removed, which is what makes the pair readable as "necessary and
  satisfiable".
- [ ] FALLBACK (not needed: the parametric plateau closed as planned) (inside this phase, not a deviation): if the parametric `plateau_isLadderPath`
  fights `split_ifs`/`omega` for more than 45 minutes, land `plateau` at the literal `C := 3`
  with `hasForwardSlack_plateau` for `l ≤ 4` and `plateau_gap` for `l ≤ 3`, drop the `∀ L`
  headline, record the narrowing via `issue-record.sh` (`--kind issue --class "landed-lemma exposure gap" --severity minor`),
  and say so in the namespace docstring.
- [x] Namespace docstring: the two-state object; the climbing path realizes the gate's arithmetic
  witness `n = 0, C = 3, I = 1, l = 1, nxtAt g s₀ = 4` exactly; `Drift` admits `n' = n + 1` at
  every step and a pending self-loop realizes any next-region length, so no Drift-level invariant
  bounds the climb; the plateau shows the regime is inhabited at every amount.
- [x] `lean_verify` on the two headline names; scoped build; `--fix`; commit.

**Timing**: 2 hours

**Depends on**: 1

**Verification Tier**: local

**Scope Hypothesis**: Roughly 120 lines; the climb half is a verbatim port (confirm by diffing
against `prototype/climb-witness.lean`: only the namespace line, the names, and indentation
differ), the plateau half is new. Confirm `Fintype Bool` and `DecidableEq Bool` instances are
found without any new import (the scoped build shows no new import edge).

**Tier Justification**: The scoped guarded build of
`FormalSystem.Metalogic.Decidability.RaySummary.LadderChain` plus `lean_verify` on the two headline
names covers the phase -- the namespace is self-contained, consumed by nothing, and touches no
landed signature.

**Files to modify**:
- `FormalSystem/Metalogic/Decidability/RaySummary/LadderChain.lean` - add `namespace ClimbWitness` after `section Slack`
- `typst/generated/status.typ` - regenerated by `scripts/typst-sync-check.sh --fix` before the commit

**Verification**:
- Scoped build exits 0; `lean_verify` on `ClimbWitness.hasForwardSlack_refuted_unconditional` and `ClimbWitness.exists_hasForwardSlack_inhabitant` (fully qualified under the module namespace) reports the standard axiom profile and no `sorry`.
- The refutation's statement is the prototype's `refutation` statement verbatim (names aside).
- Neither headline is vacuous: the refutation exhibits a path and a false regime instance; the inhabitant exhibits a path with a next region (`I = 1`), not an idle-forever path.

---

### Phase 3: The spaced pigeonhole and the room bound [COMPLETED]

**Goal**: The two combinatorial ingredients of the loop are landed: among `b + 1` samples at
spacing `s` inside the anchor's region, two share `(objAt, tpOf)`; and `(K2)` alone gives
`b · (b + 1) ≤ Tc`, the room a `(b + 1)`-sample window at spacing `l ≤ b` needs.

**Tasks**:
- [x] `budget_mul_succ_le_Tc` joins `section Budget` directly after `budget_le_Tc`, header exactly
  as pinned; body from the prototype (`cascadeBound`, `card_prodState`, `tIdle ≥ 1` so
  `3 ≤ tIdle pend + 2`, the induction `b * (b + 1) ≤ 2 ^ b * 3` with the hint
  `Nat.lt_two_pow_self : k < 2 ^ k` in context for `nlinarith`).
- [x] Open `section Spacing` directly after `end Bridge` with
  `variable {Q : Type} [Fintype Q] [Nonempty Q] {step : Q → Q → Bool} {pend : Q → Bool}`;
  state `exists_typeBlock_of_spacing` exactly as pinned (explicit binders, no `hs`); body from
  the prototype (`Fintype.exists_ne_map_eq_of_card_lt` on `Fin (b + 1) → Q × {T // T ∈ powerset}`,
  the `hcnt` region fact from `cntAt_sub_of_pend`, the two symmetric cases on `a < c` / `c < a`
  with `push_cast [Nat.cast_sub …]; ring`).
- [x] Docstrings: the pigeonhole returns a block of length `d · s` with `1 ≤ d ≤ b` lying in the
  sampling window `[w₀, w₀ + b · s]`; the room bound is what makes the window fit when `s ≤ b`.
- [x] `lean_verify` on both names; scoped build; `--fix`; commit.

**Timing**: 1 hour

**Depends on**: 2

**Verification Tier**: local

**Scope Hypothesis**: Two theorems, roughly 95 lines, bodies expected to compile unchanged from
the prototype (the second run of `lean_run_code` during research had only the `hs`
unused-variable warning, which the pinned header already drops). Confirm by the absence of proof
edits beyond indentation.

**Tier Justification**: The scoped guarded build of
`FormalSystem.Metalogic.Decidability.RaySummary.LadderChain` plus `lean_verify` on both names covers
the edit -- additive declarations in one module, no landed signature touched.

**Files to modify**:
- `FormalSystem/Metalogic/Decidability/RaySummary/LadderChain.lean` - extend `section Budget`; add `section Spacing` after `section Bridge`
- `typst/generated/status.typ` - regenerated by `scripts/typst-sync-check.sh --fix` before the commit

**Verification**:
- Scoped build exits 0; `lean_verify` on both names reports the standard axiom profile and no `sorry`.
- Both pinned headers match the Challenge block after whitespace normalization.

---

### Phase 4: The register-held iterated duplication of a given block [COMPLETED]

**Goal**: The regime-A assembly's proof body (from `obtain ⟨g₁, …⟩ := exists_iterSpliced_ladderPath_of_pend_past …`
through the translate-back and the type bullet) is factored into a lemma that takes the block and
the number of copies as inputs, so the raise step of Phase 7 can be applied to the ORIGINAL
pigeonhole block of a path that has since been shortened; the regime-A assembly becomes a short
corollary with its statement unchanged.

**Tasks**:
- [x] Before the edit, extract and save the regime-A assembly's header text:
  `sed -n '/^theorem exists_ladderPath_through_shifted_of_pend_past/,/:= by$/p' FormalSystem/Metalogic/Decidability/RaySummary/LadderChain.lean > /tmp/claude-1000/-home-benjamin-Projects-BimodalLogic/a7c76d9b-f04a-4a0f-8ec1-4e2cb1cb7183/scratchpad/regimeA-header-before.txt` (any scratchpad path; absolute).
- [x] `exists_ladderPath_through_iterSpliced_nxt_of_pend_past` (name suggested, not pinned), in
  `section AssemblyFin` BEFORE the regime-A assembly, with hypotheses
  `(step pend fwd bwd lab φ) (hno) {g} (hg : IsLadderPath step pend g) (z : ℤ) {u : ℤ} {l : ℕ} (hl : 0 < l) (hcl : l ≤ cntAt g u) (hzu : z ≤ u) (hul : u + (l : ℤ) ≤ z + (cntAt g z : ℤ)) (hpast : ∀ p : ℤ, p ≤ u → pend (objAt g p) = true) (hrep : objAt g u = objAt g (u + (l : ℤ))) (σ : WorldHistory …) (hσ : ∀ t, σ.state t = (t, g t)) (hty : tpOf … σ u = tpOf … σ (u + (l : ℤ))) (d : ℕ)`
  and conclusion
  `∃ g', IsLadderPath step pend g' ∧ (∀ v : ℤ, v < u + (l : ℤ) → objAt g' v = objAt g v) ∧ cntAt g' z = cntAt g z + d * l ∧ nxtAt g' z = nxtAt g z ∧ ∀ σ', (∀ t, σ'.state t = (t, g' t)) → tpOf … σ' z = tpOf … σ z`.
  Record the exact hypothesis list chosen at the goal state in this phase's notes.
  *(phase note: landed with binders `{Q : Type} [Finite Q] [Nonempty Q] (step pend fwd bwd lab φ) (hno) {g} (hg) (z) {u} {l} (hl) (hcl) (hzu) (hul) (hpast) (hrep) (σ) (hσ) (hty) (d)` — `[Finite Q]` in place of the section's `[Fintype Q]`, with `Fintype.ofFinite` in the proof, because the `unusedFintypeInType` linter flagged `Fintype` as used only inside a proof in the type; conclusion exactly as planned)*
- [x] Proof: move the regime-A assembly's body from its `obtain ⟨g₁, …⟩ := exists_iterSpliced_ladderPath_of_pend_past …`
  line to its end into the new lemma, with `d` the parameter (no `m * q` substitution), `hpast_u`
  replaced by the hypothesis `hpast`, `hcz` proved from `hcnt₁ z hzu (by omega)` using `hul`, and
  the object-walk agreement below `u + l` read off `hobj₁`. The register rebuild (`w`, `c`,
  `hg₂`, the five clauses, `hn₀` through `habove₁` and `nxtAt_lipschitz_two_sided`), the
  translate-back, and the type bullet are copied, not re-derived.
- [x] Re-prove `exists_ladderPath_through_shifted_of_pend_past` as a corollary: its opening block
  (history, pigeonhole, `hpast_u`, the bridge's `q` with `P + 1 = l * q`) stays; then apply the new
  lemma with `d := m * q` and `hul : u + l ≤ z + cntAt g z` (from the pigeonhole's
  `u + l ≤ z + b` and `b ≤ Tc ≤ cntAt g z`), and finish with `hdl : (m * q) * l = m * (P + 1)` by
  `rw [hq]; ring`. The STATEMENT is not touched.
- [x] After the edit, extract the header again and `diff` it against the saved copy: empty diff
  required.
- [x] Update the `Assembly` section's module docstring sentence that describes the regime-A
  assembly's proof structure, if the factoring changes how it reads (one clause at most).
- [x] `lean_verify` on both names; scoped build; `--fix`; commit.

**Timing**: 2 hours

**Depends on**: 3

**Verification Tier**: interface

**Scope Hypothesis**: The regime-A assembly's body shrinks from roughly 115 lines to roughly 25,
and the new lemma is roughly 95 lines; net growth about 10 lines. The theorem has exactly one
consumer in the library, `cellAt_subset_of_shift_of_pend_past` in the same module, and one
reference in `LadderAgree.lean`'s and `LadderPin.lean`'s docstrings (prose only). Confirm by
`grep -rn exists_ladderPath_through_shifted_of_pend_past FormalSystem/ typst/` before the edit.

**Tier Justification**: The scoped guarded build of
`FormalSystem.Metalogic.Decidability.RaySummary.LadderChain` covers the one consumer of the
refactored theorem (it is in the same module), and the header diff is the covering check for the
statement; nothing outside the module calls the theorem, so the enumerated one-hop dependent set
is the module itself.

**Files to modify**:
- `FormalSystem/Metalogic/Decidability/RaySummary/LadderChain.lean` - add the given-block lemma to `section AssemblyFin`; refactor the regime-A assembly's body
- `typst/generated/status.typ` - regenerated by `scripts/typst-sync-check.sh --fix` before the commit

**Verification**:
- Scoped build exits 0; `lean_verify` on `exists_ladderPath_through_shifted_of_pend_past` and the new lemma reports the standard axiom profile and no `sorry`.
- The before/after header diff of `exists_ladderPath_through_shifted_of_pend_past` is empty.
- `cellAt_subset_of_shift_of_pend_past` compiles unchanged (no edit to its text).

---

### Phase 5: One deletion step, with agreement, register and slack preserved [COMPLETED]

**Goal**: One iteration of the loop is a lemma: sample at spacing `l` from `w₀`, delete the
type-respecting block the pigeonhole returns, and hand back a ladder path that agrees with the
input at every position up to and including `w₀` (object walk and realized type), has the
countdown at `z` lowered by `d · l` with `1 ≤ d ≤ b`, keeps the register at `z`, and carries the
regime at the amount decreased by exactly `d · l`.

**Tasks**:
- [x] Open `section DelNxtIter` directly after `end DelNxtFin` with
  `variable {Q : Type} [Fintype Q] [Nonempty Q] {step : Q → Q → Bool} {pend : Q → Bool}`.
- [x] `exists_deleted_ladderPath_step_of_pend_past` (name suggested, not pinned):
  hypotheses `(step pend fwd bwd lab φ) (hno) {g} (hg) (z : ℤ) (hpast : ∀ p ≤ z, pend (objAt g p) = true) (σ) (hσ : ∀ t, σ.state t = (t, g t)) (w₀ : ℤ) (hzw : z ≤ w₀) (hwb : w₀ ≤ z + (b : ℤ)) (l : ℕ) (hl : 0 < l) (hlb : l ≤ b) (hroom : b * (b + 1) ≤ cntAt g z) {L : ℕ} (hLb : b * l ≤ L) (hgap : nxtAt g z + b * l ≤ cntAt g z) (hslack : HasForwardSlack g z L (nxtAt g z))`;
  conclusion `∃ (g' : ℤ → LadderState Q pend) (d : ℕ), IsLadderPath step pend g' ∧ 0 < d ∧ d ≤ b ∧ (∀ v : ℤ, v ≤ w₀ → objAt g' v = objAt g v) ∧ cntAt g' z + d * l = cntAt g z ∧ nxtAt g' z = nxtAt g z ∧ HasForwardSlack g' z (L - d * l) (nxtAt g z) ∧ ∀ σ', (∀ t, σ'.state t = (t, g' t)) → ∀ v : ℤ, v ≤ w₀ → tpOf … σ' v = tpOf … σ v`.
  Record the exact hypothesis list chosen at the goal state in this phase's notes.
  *(phase note: landed with exactly the hypothesis list and the eight-conjunct conclusion written above, `b` spelled out in full; no adjustment was needed at the goal state)*
- [x] Proof, step by step, mirroring `exists_ladderPath_through_deleted_of_pend_past`:
  `hz` from `hpast`; `exists_typeBlock_of_spacing … σ hg z hz w₀ l hzw (hroom')` with
  `hroom' : w₀ + b * l ≤ z + cntAt g z` by `omega` from `hwb`, `hlb`, `hroom`
  (`b + b * l ≤ b * (b + 1)`), giving `a, d, hd, hdb, hwa, haw, hcl, hrep, hty`; set `L' := d * l`
  with `0 < L'`; `hpast_a` (pending up to `a`: below `z` by `hpast`, from `z` to `a` by
  `cntAt_sub_of_pend`); `hfirst` from `hasForwardSlack_mono … hslack (d * l ≤ L)` and the lower
  direction from `hgap` by `omega` (`nxtAt g z + d * l ≤ cntAt g z` since `d * l ≤ b * l`);
  `hanch := anchor_clause_of_first_region_start g hg z hz (d * l) (nxtAt g z) hfirst a hza hal`
  with `hza : z ≤ a` and `hal : a + d * l ≤ z + cntAt g z` (from `haw` and `hroom'`);
  `obtain ⟨g', hg', hobj', hcnt', hnxt'⟩ := exists_deleted_ladderPath_of_pend_past_nxt hg hd hcl hpast_a hrep z (nxtAt g z) hanch`.
- [x] Conclusions: `cntAt g' z` by `hcnt' z` and `delCnt_sub_of_mem_region hg hd hcl z hza (by omega)`;
  object agreement for `v ≤ w₀ ≤ a` by `hobj' v` and `delObj_eq_of_le hrep v (by omega)`; the slack
  by `hasForwardSlack_del g hg z hd hcl hza hal hslack (by omega) g' hg' hobj' hcnt'` (amount
  `L - d * l`); the types by `tpOf_eq_delIdx_of_tpOf_eq step pend fwd bwd lab φ a (d * l) hd (k := 0) (k' := 0) σ σ' … (fun w => (hobj' w).trans rfl) hno hty_σ v`
  with `hty_σ` the endpoint equality in `σ`'s history (from `hty`, which is already in `σ`), then
  `delIdx_of_lt` for `v < a` and, for `v = a`, `delIdx_of_ge` followed by `hty_σ.symm`.
- [x] Docstring: one step of the overshoot loop; what is preserved and by which landed lemma.
- [x] `lean_verify`; scoped build; `--fix`; commit.

**Timing**: 1.5 hours

**Depends on**: 4

**Verification Tier**: local

**Scope Hypothesis**: Roughly 90 lines, of which the pigeonhole-to-deletion spine (about 30 lines)
is a near-verbatim copy of the single-block assembly with `l` replaced by `d * l` and the
pigeonhole swapped. Confirm by diff against `exists_ladderPath_through_deleted_of_pend_past`'s
body.

**Tier Justification**: The scoped guarded build of
`FormalSystem.Metalogic.Decidability.RaySummary.LadderChain` plus `lean_verify` on the new name
covers the phase -- one additive declaration, consumed by nothing yet, no landed signature touched.

**Files to modify**:
- `FormalSystem/Metalogic/Decidability/RaySummary/LadderChain.lean` - add `section DelNxtIter` with the one-step lemma
- `typst/generated/status.typ` - regenerated by `scripts/typst-sync-check.sh --fix` before the commit

**Verification**:
- Scoped build exits 0; `lean_verify` on the new name reports the standard axiom profile and no `sorry`.
- The lemma's conclusion carries all eight conjuncts listed above; none is weakened to make the proof close (in particular the agreement is `v ≤ w₀`, inclusive).

---

### Phase 6: The overshoot loop [COMPLETED]

**Goal**: Iterating Phase 5 by strong induction on the target number `R` of `l`-units deletes at
least `R · l` positions and fewer than `(R + b) · l`, preserving the object walk and types up to
`w₀`, the register at `z`, and the regime at the decreased amount.

**Tasks**:
- [x] `exists_deleted_ladderPath_overshoot_of_pend_past` (name suggested, not pinned), in
  `section DelNxtIter` after the step lemma: hypotheses as in Phase 5 with `L` replaced by the
  explicit amount -- `(R : ℕ) (hroom : R * l + b * (b + 1) ≤ cntAt g z) (hgap : nxtAt g z + R * l + b * l ≤ cntAt g z) (hslack : HasForwardSlack g z (R * l + b * l) (nxtAt g z))`;
  conclusion `∃ (g' : ℤ → LadderState Q pend) (t : ℕ), IsLadderPath step pend g' ∧ R ≤ t ∧ t < R + b ∧ (∀ v : ℤ, v ≤ w₀ → objAt g' v = objAt g v) ∧ cntAt g' z + t * l = cntAt g z ∧ nxtAt g' z = nxtAt g z ∧ HasForwardSlack g' z (R * l + b * l - t * l) (nxtAt g z) ∧ ∀ σ', (∀ t, σ'.state t = (t, g' t)) → ∀ v : ℤ, v ≤ w₀ → tpOf … σ' v = tpOf … σ v`.
  Record the exact hypothesis list chosen at the goal state in this phase's notes.
  *(phase note: landed with exactly the hypothesis list and conclusion written above; `Nat.strong_induction_on generalizing g σ` worked as sketched)*
- [x] Proof by `induction R using Nat.strong_induction_on generalizing g σ` (so the step's output
  path becomes the next input). Base `R = 0`: `⟨g, 0, hg, le_rfl, by omega, fun _ _ => rfl, by simp, rfl, by simpa using hslack, fun σ' hσ' v _ => tpOf_stabFree_eq_of_objAt_eq … ⟩`
  (two histories of the same path realize the same stab-free type; `hno` is available). Step
  `0 < R`: apply Phase 5 with `L := R * l + b * l` (so `b * l ≤ L`), `hroom` from the loop's
  `hroom`, `hgap` by `omega`; obtain `g₁, d`. Case `R ≤ d`: return `⟨g₁, d, …⟩` with `d < R + b`
  from `d ≤ b` and `0 < R`. Case `d < R`: obtain a history `σ₁` of `g₁` by
  `exists_hist_of_isLadderPath`; apply the induction hypothesis at `R - d < R` to `g₁`, `σ₁`
  with `hpast₁` (agreement below `z ≤ w₀`), `hroom₁ : (R - d) * l + b * (b + 1) ≤ cntAt g₁ z`,
  `hgap₁`, `hslack₁ : HasForwardSlack g₁ z ((R - d) * l + b * l) (nxtAt g₁ z)` (rewrite
  `nxtAt g₁ z = nxtAt g z` and `R * l + b * l - d * l = (R - d) * l + b * l` by
  `Nat.sub_mul`/`omega` with `d ≤ R`); obtain `g₂, t'`; return `⟨g₂, d + t', …⟩`: `R ≤ d + t'`
  and `d + t' < R + b` from `R - d ≤ t' < R - d + b`; agreement composes; `cntAt` by `omega` with
  `(d + t') * l = d * l + t' * l` (`add_mul`); the slack amount by rewriting
  `R * l + b * l - (d + t') * l = (R - d) * l + b * l - t' * l`; the types compose through `σ₁`.
- [x] Keep every `omega` call's `ℕ`-subtraction side conditions explicit (`d * l ≤ R * l + b * l`,
  `d ≤ R` in the second case); state `t * l` products with `Nat.mul_le_mul_right` where `omega`
  cannot see through a variable product.
- [x] Docstring: the overshoot is fewer than `b` blocks of length `l`, hence fewer than `b · l ≤ b²`
  positions, which is what the exact-shift theorem's `b · b` summand pays for.
- [x] `lean_verify`; scoped build; `--fix`; commit. *(deviation: altered — the file crossed the 1500-line `longFile` limit in this phase (the plan's per-phase estimates sum past it); added the repository-sanctioned baseline `set_option linter.style.longFile 1700` after the module docstring per LEAN_STYLE_GUIDE.md, to be re-tightened as the file grows; no statement changed)*

**Timing**: 1.5 hours

**Depends on**: 5

**Verification Tier**: local

**Scope Hypothesis**: Roughly 80 lines; the only new mathematics is the arithmetic of `t`, and
the only new structure is the strong induction generalizing `g` and `σ`. Confirm by the absence of
any new `have` about the ladder relation itself (every path fact comes from Phase 5's conclusion).

**Tier Justification**: The scoped guarded build of
`FormalSystem.Metalogic.Decidability.RaySummary.LadderChain` plus `lean_verify` on the new name
covers the phase -- one additive declaration, consumed by nothing yet, no landed signature touched.

**Files to modify**:
- `FormalSystem/Metalogic/Decidability/RaySummary/LadderChain.lean` - add the loop lemma to `section DelNxtIter`
- `typst/generated/status.typ` - regenerated by `scripts/typst-sync-check.sh --fix` before the commit

**Verification**:
- Scoped build exits 0; `lean_verify` on the new name reports the standard axiom profile and no `sorry`.
- The conclusion's bounds are exactly `R ≤ t ∧ t < R + b`; the regime conjunct is at amount `R * l + b * l - t * l` and is not dropped.

---

### Phase 7: The exact-shift theorem and the slack-restricted cell inclusion [COMPLETED]

**Goal**: The two pinned deliverables of Piece 2 land: through a pending-forever path's state at
`z` with room `Tc + m · (P + 1) ≤ cntAt g z`, under the gap and the regime at amount
`m · (P + 1) + b · b`, a ladder path with the countdown lowered by EXACTLY `m · (P + 1)`, the
object state and register at `z` held, and the realized stab-free type at `z` held; and, as its
consumer, the downward cell inclusion stated on the witnessing path.

**Tasks**:
- [x] `exists_ladderPath_through_deleted_exact_of_pend_past`, header exactly as pinned, in
  `section DelNxtIter` after the loop. Proof: `hz`; `hbud := budget_le_Tc …`;
  `hb2 := budget_mul_succ_le_Tc …`; `σ₀` from `exists_hist_of_isLadderPath`; the block
  `u, l, hl, hlb, hzu, hcl, hul, hrep, hty` from `exists_typeBlock_of_budget_le_cnt_within … σ₀ hg z hz (by omega)`;
  `hpast_u` as in the landed assemblies; `q` with `P + 1 = l * q` from
  `typeBlock_length_dvd_of_paramsOk`; `R := m * q` with `hRl : R * l = m * (P + 1)` by
  `rw [hq]; ring`.
- [x] The loop at `w₀ := u + l` (so `z ≤ w₀` and `w₀ ≤ z + b` from the pigeonhole's `u + l ≤ z + b`),
  with `hroom : R * l + b * (b + 1) ≤ cntAt g z` (from `hRl`, `hb2`, `hTc`),
  `hgap' : nxtAt g z + R * l + b * l ≤ cntAt g z` (from `hRl`, `hgap`, `b * l ≤ b * b`), and
  `hslack' := hasForwardSlack_mono g z hslack (by nlinarith/omega : R * l + b * l ≤ m * (P + 1) + b * b)`;
  obtain `g₁, t, hg₁, hRt, htR, hagree₁, hcnt₁, hnxt₁, hslack₁, hty₁`; set `e := t - R` with
  `e < b`.
- [x] The raise on the ORIGINAL block in `g₁`: `σ₁` from `exists_hist_of_isLadderPath`;
  `hrep₁ : objAt g₁ u = objAt g₁ (u + l)` by rewriting both sides through `hagree₁` (`u ≤ u + l = w₀`)
  to `hrep`; `hty₁' : tpOf … σ₁ u = tpOf … σ₁ (u + l)` by `hty₁ σ₁ hσ₁` at `u` and `u + l` and
  `hty`; `hpast₁ : ∀ p ≤ u, pend (objAt g₁ p) = true` from `hagree₁` and `hpast_u`;
  `hcl₁ : l ≤ cntAt g₁ u` and `hul₁ : u + l ≤ z + cntAt g₁ z` by `cntAt_sub_of_pend g₁ hg₁ z hz₁ (u - z).toNat …`
  and `omega` from `hcnt₁`, `htR`, `hroom` (`cntAt g₁ z ≥ cntAt g z - (R + b - 1) * l ≥ b + l`,
  because `b * (b + 1) - b * l + l ≥ b + l` for `l ≤ b`; keep `Nat.mul_le_mul_right` facts in
  context for `omega`). Apply Phase 4's lemma with `d := e` to get `g₂` with
  `cntAt g₂ z = cntAt g₁ z + e * l`, `nxtAt g₂ z = nxtAt g₁ z`, `objAt g₂ z = objAt g₁ z`
  (`z < u + l`), and the type at `z` equal to `σ₁`'s.
- [x] Conclusions: `objAt` by the two agreements; `cntAt g₂ z + m * (P + 1) = cntAt g z` by `omega`
  from `hcnt₁`, `cntAt g₂ z = cntAt g₁ z + e * l`, `t = R + e`, `hRl` (with `(R + e) * l = R * l + e * l`);
  `nxtAt` by the two register equalities; the type: `tpOf σ' z = tpOf σ₂ z` (two histories of
  `g₂`, `tpOf_stabFree_eq_of_objAt_eq`), `= tpOf σ₁ z` (Phase 4's type clause), `= tpOf σ₀ z`
  (the loop's type clause at `z ≤ w₀`), `= tpOf σ z` (two histories of `g`).
- [x] `mem_cellAt_of_shift_of_hasForwardSlack`, header exactly as pinned, directly after. Proof:
  `hoz, hcz, hnz` by `simp [objAt, cntAt, nxtAt, hgz]`; `hz` by contradiction from
  `h'` (an idle state has countdown `0`, but `n + 2 ≤ c`); `hpast := pend_past_of_nxtAt_lt g hg z hz (by rw [hcz, hnz]; omega)`;
  apply the exact-shift theorem with `hTc' : Tc + m * (P + 1) ≤ cntAt g z` (from `hTc`, `hcz`),
  `hgap'` (from `hslk`, `hcz`, `hnz`), and `hslack` rewritten through `hnz`; obtain `g'`; `τ'`
  from `exists_hist_of_isLadderPath`; `rw [mem_cellAt_ladder_iff]`;
  `refine ⟨g', τ', hg', ?_, hτ', ?_⟩`; the state equality by `Subtype.ext` and
  `change (objAt g' z, cntAt g' z, nxtAt g' z) = (q, c, n)` with `omega` for the countdown
  (`cntAt g' z + m * (P + 1) = c + m * (P + 1)`); the type by the exact-shift's clause at
  `τ τ'`.
- [x] Docstrings: the exact-shift theorem names the overshoot-then-up device and the price
  (`b · b` in both hypotheses); the cell inclusion says the hypothesis is on the WITNESSING PATH,
  that `cellAt` is existential over histories so this is the only sound downward statement under
  a path-level regime, that the reserved name `cellLE_zero_const_of_kappa_eq` remains claimed by
  nothing, and that the gap between this and the obligation is the tight (doubling) chain, no
  finite deletion-derivative of which lifts (argued in the task record, not compiled).
- [x] `lean_verify` on both names; scoped build; `--fix`; commit.

**Timing**: 2 hours

**Depends on**: 6

**Verification Tier**: local

**Scope Hypothesis**: Roughly 130 lines for the two theorems. The exact-shift proof has no new
construction: it is the loop followed by Phase 4's lemma, and its only risk is the `ℕ`
arithmetic connecting `t`, `R`, `e`, `l` and the budget. Confirm by counting `have`s: every path
fact is obtained from a landed or in-task lemma, none from `Rlad` directly.

**Tier Justification**: The scoped guarded build of
`FormalSystem.Metalogic.Decidability.RaySummary.LadderChain` plus `lean_verify` on both names covers
the phase -- additive declarations, consumed by nothing yet, no landed signature touched.

**Files to modify**:
- `FormalSystem/Metalogic/Decidability/RaySummary/LadderChain.lean` - add the exact-shift theorem and the cell inclusion to `section DelNxtIter`
- `typst/generated/status.typ` - regenerated by `scripts/typst-sync-check.sh --fix` before the commit

**Verification**:
- Scoped build exits 0; `lean_verify` on both names reports the standard axiom profile and no `sorry`.
- Both pinned headers match the Challenge block after whitespace normalization; no hypothesis was added and no conclusion weakened to close the proofs (a needed change is a `[BLOCKED]` escalation per `plan-compliance.md`, never a silent edit).
- `grep -n "cellLE_zero_const_of_kappa_eq" FormalSystem/` shows only docstrings and `def CellLEZeroConstOfKappaEq`; nothing claims the reserved name.

---

### Phase 8: Record, sync, and the full gate [NOT STARTED]

**Goal**: The library's own record describes the new state, the Challenge drift check passes,
and the complete gate set runs green.

**Tasks**:
- [ ] `FormalSystem/Metalogic/Decidability/RaySummary/README.md`: the `LadderChain.lean` row --
  re-derive the line count with `wc -l` (the row currently reads `632`, stale since the
  predecessor), and extend the description with: the slack regime (`HasForwardSlack` with its
  entry, monotonicity, transport and vacuity lemmas), the wired refutation and the plateau
  inhabitant, the spaced pigeonhole and the room bound, the register-held iterated duplication of
  a given block, the overshoot loop, the exact-shift theorem, and the slack-restricted cell
  inclusion on the witnessing path; replace the closing "One direction only: no downward
  inclusion" sentence with the honest new state. Add one "exposure" sentence to the
  `LadderPump.lean` row saying which positions `exists_iterSpliced_ladderPath_of_pend_past`
  exposes types at (below `u + l` and at `u + l` only), per the research's context-extension
  recommendation.
- [ ] README, the paragraph "The depth-`0` obligation's status" and the final sentences of
  "(K1) does not constrain a spanning block's length": state that the downward direction is now
  landed at the cell level ON THE WITNESSING PATH under the forward-slack regime, that the regime
  is necessary (the compiled climbing path) and inhabited (the plateau), and that the reserved
  name `cellLE_zero_const_of_kappa_eq` is still claimed by nothing because the obligation
  quantifies over every path through the state and concludes equality. Revise the sentence
  "and so is every regime-restricted variant of it" so it no longer contradicts the landed
  path-level inclusion (a regime-restricted PATH-level inclusion is landed; no STATE-level
  variant is).
- [ ] `LadderChain.lean` docstrings: the module header's "What it holds" paragraph; the
  `Assembly` section docstring's last two sentences ("The cell-level downward inclusion still
  needs the exact-shift iteration of the deletion"); the `DelNxtFin` section docstring and the
  single-block assembly's docstring ("Two pieces still separate this from the cell-level downward
  inclusion"); `cellAt_subset_of_shift_of_pend_past`'s docstring ("the exact-shift iteration of
  the deletion is the piece still missing"). Each is rewritten to point at the new section.
- [ ] `LadderAgree.lean`, the module-level docstring under "The obligation of the cell-level
  agreement, stated and refuted": its sentence "The current state of the second (downward)
  inclusion is the single-block, path-level assembly …" is updated to name the exact-shift
  theorem and the slack-restricted cell inclusion (docstring only; no proof edited).
- [ ] `bash .claude/scripts/lean-challenge-snapshot.sh --check 849 .` from the repository root:
  expected exit 0 (no drift on the seven pinned names). A 65 is advisory: investigate, and if a
  pinned statement was changed, escalate per `plan-compliance.md` rather than editing the
  Challenge.
- [ ] Unscoped guarded build: `timeout 590 bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build`
  (or detached with the bounded waiter if it does not fit one call), exit 0; `sorry` count `0`
  across `FormalSystem/`; `lean_verify` on every name landed in Phases 1-7.
- [ ] `bash scripts/typst-sync-check.sh --fix`; then `bash scripts/typst-sync-check.sh` exits 0.
- [ ] The complete gate set: `bash .claude/scripts/verify-deploy.sh` exits 0.
- [ ] `grep -rn "task 8" FormalSystem/ typst/` returns nothing (no task-number references in
  deliverables); the README and docstrings cite durable anchors only.
- [ ] Commit (`.lean` files, README, `status.typ`); write the implementation summary.

**Timing**: 1.5 hours

**Depends on**: 7

**Verification Tier**: full

**Scope Hypothesis**: Exactly four prose locations in `LadderChain.lean` and one in
`LadderAgree.lean` describe the downward direction as still missing the iteration; confirm by
`grep -n "exact-shift\|still missing\|still needs\|Two pieces" FormalSystem/Metalogic/Decidability/RaySummary/LadderChain.lean FormalSystem/Metalogic/Decidability/RaySummary/LadderAgree.lean`
before editing, and by the same grep returning only the new wording after.

**Files to modify**:
- `FormalSystem/Metalogic/Decidability/RaySummary/LadderChain.lean` - docstrings only
- `FormalSystem/Metalogic/Decidability/RaySummary/LadderAgree.lean` - one docstring sentence
- `FormalSystem/Metalogic/Decidability/RaySummary/README.md` - the `LadderChain.lean` and `LadderPump.lean` rows; the two downward-direction paragraphs
- `typst/generated/status.typ` - regenerated by `scripts/typst-sync-check.sh --fix` before the commit

**Verification**:
- `bash .claude/scripts/verify-deploy.sh` exits 0 (the complete gate set, not a subset).
- The unscoped guarded `lake build` exits 0; `bash scripts/typst-sync-check.sh` exits 0.
- `lean-challenge-snapshot.sh --check 849 .` exits 0.
- `lean_verify` on every new declaration from Phases 1-7 reports a subset of `[propext, Classical.choice, Quot.sound]` and no `sorry`.
- `grep -rn "task 8" FormalSystem/ typst/` returns nothing.

## Lean Challenge Statements

All seven declarations were elaborated standalone at authoring time against the built library
(`lake env lean` on this block with the seven `sorry` bodies: exit 0, seven `declaration uses
'sorry'` warnings, no errors). The first five are verbatim from
`prototype/helpers-compiled.lean`, whose bodies compiled during research. The unpinned
deliverables (Phase 2's refutation and inhabitant, Phase 4's given-block lemma, Phase 5's step,
Phase 6's loop) are deliberately not pinned -- see Decisions. The implementer states each pinned
declaration with the binders exactly as written here.

```lean
import FormalSystem.Metalogic.Decidability.RaySummary.LadderChain

namespace FormalSystem.Metalogic.Decidability.RaySummary

open FormalSystem.Syntax FormalSystem.PlusLanguage FormalSystem.Semantics
open FormalSystem.Metalogic.Decidability

theorem hasForwardSlack_mono {Q : Type} {pend : Q → Bool}
    (g : ℤ → LadderState Q pend) (z : ℤ) {l l' n : ℕ}
    (h : HasForwardSlack g z l n) (hle : l' ≤ l) : HasForwardSlack g z l' n := sorry

theorem hasForwardSlack_of_next_region_cnt_le {Q : Type} {step : Q → Q → Bool} {pend : Q → Bool}
    (g : ℤ → LadderState Q pend)
    (hg : IsLadderPath step pend g) (z : ℤ) (l n : ℕ)
    (hnext : ∀ I : ℕ, 0 < I →
      (∀ i : ℕ, i < I → pend (objAt g (z + (cntAt g z : ℤ) + 1 + (i : ℤ))) = false) →
      pend (objAt g (z + (cntAt g z : ℤ) + 1 + (I : ℤ))) = true →
      (cntAt g (z + (cntAt g z : ℤ) + 1 + (I : ℤ)) : ℤ) ≤ (n : ℤ) + cntAt g z + I - l) :
    HasForwardSlack g z l n := sorry

theorem hasForwardSlack_del {Q : Type} {step : Q → Q → Bool} {pend : Q → Bool}
    (g : ℤ → LadderState Q pend) (hg : IsLadderPath step pend g)
    (z : ℤ) {a : ℤ} {l : ℕ} (hl : 0 < l) (hcl : l ≤ cntAt g a)
    (hza : z ≤ a) (hal : a + (l : ℤ) ≤ z + (cntAt g z : ℤ)) {L n : ℕ}
    (hslack : HasForwardSlack g z L n) (hlL : l ≤ L)
    (g' : ℤ → LadderState Q pend) (hg' : IsLadderPath step pend g')
    (hobj : ∀ v, objAt g' v = delObj g a l v) (hcnt : ∀ v, cntAt g' v = delCnt g a l v) :
    HasForwardSlack g' z (L - l) n := sorry

theorem budget_mul_succ_le_Tc {Q : Type} [Fintype Q] (step : Q → Q → Bool) (pend : Q → Bool)
    (lab : Q → Atom → Bool) (φ : PlusFormula) (Tc Tn P B : ℕ)
    (hp : ParamsOk step pend lab φ Tc Tn P B) :
    Fintype.card Q * 2 ^ (plusSubformulaClosure φ).card *
      (Fintype.card Q * 2 ^ (plusSubformulaClosure φ).card + 1) ≤ Tc := sorry

theorem exists_typeBlock_of_spacing {Q : Type} [Fintype Q] [Nonempty Q]
    (step : Q → Q → Bool) (pend : Q → Bool)
    (fwd : ∀ t x, ∃ y, RladAdm step pend t x y)
    (bwd : ∀ t x, ∃ y, RladAdm step pend (t - 1) y x)
    (lab : Q → Atom → Bool) (φ : PlusFormula) {g : ℤ → LadderState Q pend}
    (σ : WorldHistory (ladderFrameAdm step pend fwd bwd).toTaskFrame)
    (hg : IsLadderPath step pend g) (z : ℤ) (hz : pend (objAt g z) = true)
    (w₀ : ℤ) (s : ℕ) (hzw : z ≤ w₀)
    (hroom : w₀ + ((Fintype.card Q * 2 ^ (plusSubformulaClosure φ).card * s : ℕ) : ℤ)
      ≤ z + (cntAt g z : ℤ)) :
    ∃ (u : ℤ) (d : ℕ), 0 < d ∧
      d ≤ Fintype.card Q * 2 ^ (plusSubformulaClosure φ).card ∧
      w₀ ≤ u ∧
      u + ((d * s : ℕ) : ℤ)
        ≤ w₀ + ((Fintype.card Q * 2 ^ (plusSubformulaClosure φ).card * s : ℕ) : ℤ) ∧
      d * s ≤ cntAt g u ∧
      objAt g u = objAt g (u + ((d * s : ℕ) : ℤ)) ∧
      tpOf (ladderModel step pend fwd bwd lab) φ σ u
        = tpOf (ladderModel step pend fwd bwd lab) φ σ (u + ((d * s : ℕ) : ℤ)) := sorry

theorem exists_ladderPath_through_deleted_exact_of_pend_past
    {Q : Type} [Fintype Q] [Nonempty Q]
    (step : Q → Q → Bool) (pend : Q → Bool)
    (fwd : ∀ t x, ∃ y, RladAdm step pend t x y)
    (bwd : ∀ t x, ∃ y, RladAdm step pend (t - 1) y x)
    (lab : Q → Atom → Bool) (φ : PlusFormula) (Tc Tn P B : ℕ)
    (hp : ParamsOk step pend lab φ Tc Tn P B)
    (hno : ∀ χ : PlusFormula, PlusFormula.stab χ ∉ plusSubformulaClosure φ)
    (g : ℤ → LadderState Q pend) (hg : IsLadderPath step pend g) (z : ℤ)
    (hpast : ∀ p : ℤ, p ≤ z → pend (objAt g p) = true) (m : ℕ)
    (hTc : Tc + m * (P + 1) ≤ cntAt g z)
    (hgap : nxtAt g z + m * (P + 1) +
      Fintype.card Q * 2 ^ (plusSubformulaClosure φ).card *
        (Fintype.card Q * 2 ^ (plusSubformulaClosure φ).card) ≤ cntAt g z)
    (hslack : HasForwardSlack g z
      (m * (P + 1) + Fintype.card Q * 2 ^ (plusSubformulaClosure φ).card *
        (Fintype.card Q * 2 ^ (plusSubformulaClosure φ).card)) (nxtAt g z)) :
    ∃ g' : ℤ → LadderState Q pend, IsLadderPath step pend g' ∧
      objAt g' z = objAt g z ∧ cntAt g' z + m * (P + 1) = cntAt g z ∧
      nxtAt g' z = nxtAt g z ∧
      ∀ (σ σ' : WorldHistory (ladderFrameAdm step pend fwd bwd).toTaskFrame),
        (∀ t : ℤ, σ.state t = (t, g t)) →
        (∀ t : ℤ, σ'.state t = (t, g' t)) →
        tpOf (ladderModel step pend fwd bwd lab) φ σ' z
          = tpOf (ladderModel step pend fwd bwd lab) φ σ z := sorry

theorem mem_cellAt_of_shift_of_hasForwardSlack
    {Q : Type} [Fintype Q] [Nonempty Q]
    (step : Q → Q → Bool) (pend : Q → Bool)
    (fwd : ∀ t x, ∃ y, RladAdm step pend t x y)
    (bwd : ∀ t x, ∃ y, RladAdm step pend (t - 1) y x)
    (lab : Q → Atom → Bool) (φ : PlusFormula) (Tc Tn P B : ℕ)
    (hp : ParamsOk step pend lab φ Tc Tn P B)
    (hno : ∀ χ : PlusFormula, PlusFormula.stab χ ∉ plusSubformulaClosure φ)
    (q : Q) (c n : ℕ) (h : c ∈ Adm pend q) (m : ℕ) (h' : c + m * (P + 1) ∈ Adm pend q)
    (hgap : n + 2 ≤ c)
    (hslk : n + Fintype.card Q * 2 ^ (plusSubformulaClosure φ).card *
      (Fintype.card Q * 2 ^ (plusSubformulaClosure φ).card) ≤ c)
    (hTc : Tc ≤ c) (z : ℤ)
    (g : ℤ → LadderState Q pend) (hg : IsLadderPath step pend g)
    (hgz : g z = ⟨(q, c + m * (P + 1), n), h'⟩)
    (hslack : HasForwardSlack g z
      (m * (P + 1) + Fintype.card Q * 2 ^ (plusSubformulaClosure φ).card *
        (Fintype.card Q * 2 ^ (plusSubformulaClosure φ).card)) n)
    (τ : WorldHistory (ladderFrameAdm step pend fwd bwd).toTaskFrame)
    (hτ : ∀ t : ℤ, τ.state t = (t, g t)) :
    tpOf (ladderModel step pend fwd bwd lab) φ τ z ∈
      cellAt (ladderModel step pend fwd bwd lab) φ
        ((z, ⟨(q, c, n), h⟩) : (ladderFrameAdm step pend fwd bwd).WorldState) z := sorry

end FormalSystem.Metalogic.Decidability.RaySummary
```

## Testing & Validation

- [ ] Each of Phases 1-7: scoped guarded build of `LadderChain` exits 0; `lean_verify` on every new name reports the standard axiom profile and no `sorry`.
- [ ] Phase 2: the refutation's statement is the prototype's verbatim; the inhabitant has a next region (`I = 1`), not an idle-forever path.
- [ ] Phase 4: the before/after header diff of `exists_ladderPath_through_shifted_of_pend_past` is empty.
- [ ] Phases 1, 3, 7: each pinned header matches the Challenge block after whitespace normalization.
- [ ] Phase 8: `verify-deploy.sh`, the unscoped guarded build, and `typst-sync-check.sh` all exit 0; `lean-challenge-snapshot.sh --check 849 .` exits 0.
- [ ] No file under `FormalSystem/` or `typst/` carries a task-number reference; `cellLE_zero_const_of_kappa_eq` is claimed by nothing.

## Artifacts & Outputs

- `FormalSystem/Metalogic/Decidability/RaySummary/LadderChain.lean`: `section Slack` (`hasForwardSlack_mono`, `hasForwardSlack_of_next_region_cnt_le`, `hasForwardSlack_del`, the vacuity lemma); `namespace ClimbWitness` (the refutation and the plateau inhabitant); `budget_mul_succ_le_Tc` in `section Budget`; `section Spacing` (`exists_typeBlock_of_spacing`); the given-block iterated duplication in `section AssemblyFin` with the regime-A assembly as its corollary; `section DelNxtIter` (the step, the loop, `exists_ladderPath_through_deleted_exact_of_pend_past`, `mem_cellAt_of_shift_of_hasForwardSlack`); updated docstrings.
- `FormalSystem/Metalogic/Decidability/RaySummary/LadderAgree.lean`: one docstring sentence.
- `FormalSystem/Metalogic/Decidability/RaySummary/README.md`: two rows and two paragraphs.
- `typst/generated/status.typ`: regenerated.
- `Challenge.lean` at the project root with `specs/849_forward_slack_discharge_and_exact_shift_iteration/challenge/manifest.json`: the Challenge snapshot taken at plan time (so `--check` can run in Phase 8 instead of exiting 71).
- `specs/849_forward_slack_discharge_and_exact_shift_iteration/summaries/01_forward-slack-exact-shift-summary.md`.

## Rollback/Contingency

- Every phase is a self-contained additive edit (Phase 4 excepted: it also rewrites one proof
  body, with the statement pinned by a header diff) committed only when green, so a failed phase is
  reverted by discarding its uncommitted hunk; the repository is never left with a red
  `LadderChain.lean` at a commit boundary. Before any destructive revert on a dirty tree, take
  `bash .claude/scripts/git-snapshot.sh 849` first (the rollback rung of `recovery.md`); do not
  emit it as a routine checkpoint.
- If Phase 2's parametric plateau cannot be closed, the in-phase literal-`C` fallback applies
  (recorded, not a deviation). If a lint rejects the concrete object in the library, the
  pre-authorized relocation to a wired probe under `specs/evidence/seam-gluing-ray-product/`
  applies to the `ClimbWitness` namespace only.
- If Phase 4's refactor cannot reproduce the regime-A assembly's statement verbatim, revert the
  refactor, keep the new lemma as a standalone declaration proved by copying the body (duplicated
  proof, roughly 95 lines; `LadderChain.lean` stays well under 1500), and record the duplication
  in the docstring and the issue log. The statement of the landed theorem is never changed.
- If Phase 6's loop or Phase 7's exact-shift proof cannot be closed, close the phase `[BLOCKED]`
  with the goal state reached, leave every earlier phase's landed theorems in place (each is
  useful on its own), and let Phase 8 record the state honestly; never a `sorry`, never a vacuous
  placeholder, never a statement under the reserved name, never a hypothesis added to a pinned
  statement without a `[BLOCKED]` escalation.
