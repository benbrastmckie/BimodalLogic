# Implementation Plan: Discharge the `UniverseClosed` residual

- **Task**: 432 - Discharge `UniverseClosed fc U` on the totality terminus `buildTableauAt_isSome_of_budget`
- **Status**: PARTIAL
- **Effort**: 15 hours
- **Dependencies**: None (parent task 428's terminus is landed and is read-only input here)
- **Research Inputs**: `specs/432_discharge_universeclosed_residual/reports/01_spawn-inherited-research.md`
- **Artifacts**: plans/01_universeclosed-clause2-verdict-instantiation.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md, plan-compliance.md
- **Type**: lean4
- **Lean Intent**: false

## Overview

`UniverseClosed fc U` is one of four residual hypotheses on the totality terminus. It has two
conjuncts: closure of `U` under `expandOnceUnblocked`'s unordered successors (clause 1) and closure
of `U` under `Branch.identifyTime` (clause 2). Planning **machine-checked both halves of the clause-2
question**: clause 2 as literally stated is **false at every nonempty `U`**, and the repaired form —
the same statement with the merge target `t₁` required to be a time the branch already knows — is
**true at `U = signedUniverse C L` under an explicit time-merge closure condition on `L`**. Both
proofs compiled green against the current build before this plan was written (see Research
Integration). The plan therefore lands: the refutation with its witness, the repaired predicate with
a strengthening record, the concrete instantiation, the honest maximum on clause 1, and a register
entry for each statement it refutes.

Done means every new declaration is sorry-free, axiom-free (`propext`/`Classical.choice`/`Quot.sound`
only), `lake build` green over the full project, the three md5-pinned frozen files byte-identical,
and no landed statement withdrawn.

### Research Integration

The inherited research is a spawn stub. The load-bearing findings below were established during
planning, with two Lean files compiled green against the current `.olean` set. They are recorded
here because no report carries them. Copies of both probes are in the session scratchpad; their
content is reproduced in the phases that consume them.

1. **Clause (2) as literally stated is refutable at every nonempty `U`. VERIFIED GREEN in planning.**
   Clause 2 quantifies `t₁` and `t₂` universally over `TimeIndex` with no constraint tying either to
   the branch. Instantiate at the singleton branch `b = [x]` for any `x ∈ U`, with `t₂ = x.label.time`
   and `t₁` arbitrary: `Branch.identifyTime` is
   `(b.map fun sf => if sf.label.time == src then {sf with label := {sf.label with time := tgt}} else sf).eraseDups`,
   so `[x].identifyTime x.label.time t = [retime x t]`, and clause 2 forces `retime x t ∈ U` for
   **every** `t : TimeIndex`. `t ↦ retime x t` is injective (`Label` is a two-field structure
   `⟨world, time⟩` with `DecidableEq`), so `U` would have to be infinite. The pigeonhole is
   `Finset.exists_ne_map_eq_of_card_lt_of_maps_to` at `Finset.range (U.card + 1)`. The probe proved
   `False` from `U.Nonempty` plus clause 2, with no frame-class hypothesis at all.

2. **The repaired clause (2) is true at `signedUniverse C L` under time-merge closure. VERIFIED GREEN
   in planning.** With the candidate condition
   `TimeMergeClosed L := ∀ l ∈ L, ∀ l' ∈ L, (⟨l.world, l'.time⟩ : Label) ∈ L`, the statement
   "for every `b` confined to `signedUniverse C L` and every `t₂`, and every `t₁ ∈ b.knownTimes`,
   `b.identifyTime t₂ t₁` is confined" compiled green. The proof is short: each member of
   `b.identifyTime t₂ t₁` is either an untouched member of `b` or a retimed one; the formula
   coordinate is untouched either way, and the retimed label is `⟨z.label.world, t₁⟩`, which
   `TimeMergeClosed` supplies once `t₁` is exhibited as `y.label.time` for some `y ∈ b`.
   **Only `t₁ ∈ b.knownTimes` is needed** — `t₂` may stay unconstrained, which keeps the repaired
   predicate as strong as possible.

3. **The repaired form is free at every usage site.** `firstIncomparablePair_spec` (`Fuel.lean:1023`)
   returns `t₁ ∈ b.knownTimes ∧ t₂ ∈ b.knownTimes ∧ t₂ ≠ t₁ ∧ …`, and every consumer of clause 2
   reaches `t₁, t₂` only through `expandOnceUnblocked_splitOrdered_shape`, which returns exactly that
   trigger. So restricting clause 2 to `t₁ ∈ b.knownTimes` leaks **no new hypothesis** into the
   terminus — the restriction is discharged locally at each site.

4. **`signedUniverse` has no forward membership lemma.** `mem_signedUniverse` (`Fuel.lean:385`) is
   the `mpr` direction only. The `mp` direction is needed by every phase below and is four lines
   (`simp only [signedUniverse, Finset.mem_image, Finset.mem_product, …]` then destructure). It must
   be added **in `MintBound.lean`**, because `Fuel.lean` is md5-pinned frozen.

5. **Clause (1)'s label dimension has a fresh-label obstruction, and the relevant machinery already
   exists.** `applyRule_boxNeg_emitted_world` and `applyRule_diamondPos_emitted_world` (MintBound.lean
   ~2190, ~2214) prove those two rules emit **only** at `Branch.nextWorld`, and
   `applyRule_emitted_world_mem` (~2145) proves the other 34 rules stay inside `b.worldFinset`. There
   is **no time-dimension analogue** — `MintPaysForTime`'s own docstring names its absence, and notes
   that `densityRule` and the active arms of `untlNeg`/`snceNeg` introduce times without being in
   `ruleMintsFreshLabel`. Since clause 1 quantifies over *every* `U`-confined branch and *every*
   tracker, a branch sitting at the top of `L`'s world (or time) range has a successor outside any
   fixed finite `L`. Phase 5 settles this with a machine-checked verdict rather than assuming it.

6. **Line numbers in the task description are stale.** `MintBound.lean` is 5191 lines. Current
   anchors, by name: `UniverseClosed` ~3904, `difficultyBounded_of_stepLengthBounded` ~4198,
   `buildTableauAt_isSome_of_budget` ~5007, register section C9 ~5110.

### Prior Plan Reference

No prior plan for this task. The **sibling** task 431 discharged `DifficultyBounded` on the same
terminus, and its shape is the template followed here: refute the literal statement with a witness,
name the repaired satisfiable form, prove the repaired form equivalent-or-stronger where possible,
land a sibling terminus at the repaired shape, and add a register entry. Effort there was 11.5 hours
over 7 phases against the same file; this task is larger because clause 1 is a second, independent
dimension, hence 15 hours over 9 phases.

Two calibration lessons carried over from 431:

- A `list`-vs-`toFinset` / unconstrained-quantifier asymmetry is the known failure mode on this
  terminus. It recurred here: clause 2's unconstrained `t₁` is the same class of defect.
- Do not silently weaken a statement to make it close. Retain the refuted statement verbatim, add
  the repaired one alongside, and record the direction of the change.

### Roadmap Alignment

No `specs/ROADMAP.md` in this repository; `roadmap_flag` was not set. No roadmap phases are added.

## Goals & Non-Goals

**Goals**:

- Land the clause-2 verdict as a machine-checked theorem, whichever way it goes.
- Land the repaired predicate `UniverseClosedAt`, with a lemma recording that it is *weaker* than
  `UniverseClosed` (so assuming it is a strengthening of every theorem that assumes it).
- Land `TimeMergeClosed L`, a nonempty satisfying instance, and the proof that the repaired clause 2
  holds at `signedUniverse C L` under it.
- Deliver the honest maximum on clause 1: the formula dimension proved outright for both `.extended`
  and `.split`, and the label dimension either proved under explicit conditions or refuted with a
  witness plus a named repair carrying an obligation map.
- Land a composite theorem at the concrete instantiation `U = signedUniverse C L`, and a terminus
  corollary stated at whatever predicate the composite actually establishes.
- Add a register entry for every statement this task refutes.

**Non-Goals**:

- Editing `Fuel.lean`, `Saturation.lean`, or `Tableau.lean`. All three are md5-pinned frozen by the
  parent plan; every new lemma goes in `MintBound.lean`.
- Discharging `MintPaysForTime`, `DifficultyBounded`, or `PostBlockingSettles`. Those are tasks 434,
  431 (done), and 433. In particular the **time-dimension analogue of `applyRule_emitted_world_mem`**
  is 434's territory; this plan may *consume* it if it lands first but must not author it.
- Re-attempting anything in the do-not-re-attempt register, in particular entry 6 (a lower bound on
  `(b.identifyTime t₂ t₁).toFinset.card`, dead by definition) and entry 3 (a `.splitOrdered`
  cardinality twin).
- Withdrawing, weakening, or restating any landed statement. `UniverseClosed` stays verbatim.
- Widening any `private` marker. Register entry 9 records why that is never the fix here.

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Clause 1 turns out refutable at every finite `L`, so no unconditional `UniverseClosed`-shaped theorem exists | H | H | Pre-declared in Phase 5's branch (b): land the refutation plus a *named* branch-side headroom condition with an obligation map, following the `StepLengthGrowth` precedent. The deliverable is then conditional but explicit, and the task is not blocked. |
| Generalizing 10 theorem signatures from `UniverseClosed` to `UniverseClosedAt` breaks a downstream proof in a non-obvious place | M | M | Only 4 sites actually *use* the hypothesis (`hUcl.1`/`hUcl.2`); the other 6 only thread it. Change the 4 first, `lake build` after each, then thread. Retain original-shaped corollaries so nothing is withdrawn. |
| Territory collision with tasks 433/434, which also edit `MintBound.lean` | M | M | Confine every edit to the `UniverseClosed` block and the register. Do not touch `MintPaysForTime`, `DifficultyBounded`, or the blocking lemmas. Re-read the file before the final gate and reconcile if it has moved. |
| The `.split` formula dimension needs a bridge Fuel.lean does not export | M | M | `applyRule_subformula_closed` (`SubformulaProperty.lean:1338`) is stated over `RuleResult.emitted`, which covers all five result shapes including `.branching`; `expandOnceUnblocked_split_shape` gives `bs = bss.map (· ++ b)`. Both are already public. `pick_result_mem` covers only `.linear`/`.persistent`, so the `.branching` case goes through `applyRule_subformula_closed` directly. |
| Heartbeat blowups on the 36-arm case splits | L | M | The existing 34×2 split already carries `set_option maxHeartbeats 4000000`. Reuse that budget; do not attempt a single monolithic `cases` over rule × sign without it. |
| A phase's proof lands but silently uses `native_decide` or an added axiom | H | L | Phase 9 runs `lean_verify` on every new declaration and asserts the axiom set and a zero `native_decide` count, as 431's gate did. |

## Implementation Phases

**Dependency Analysis**:

| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2, 5 | 1 |
| 3 | 3, 4 | 2 |
| 4 | 6 | 5 |
| 5 | 7 | 5, 6 |
| 6 | 8 | 3, 4, 7 |
| 7 | 9 | 8 |

Phases within the same wave can execute in parallel. Phases 2 and 5 are both **verdict gates**: each
ends with an explicit written verdict, and the phases behind it branch on that verdict.

---

### Phase 1: Ground truth, register audit, and the missing forward membership lemma [COMPLETED]

**Goal**: Re-anchor every target by name rather than by the stale line numbers, read the register
before writing anything, and land the one small lemma every later phase needs.

**Tasks**:
- [x] Read the do-not-re-attempt register (section C9 of `MintBound.lean`, located by the heading
      text `## C9. The do-not-re-attempt register`) in full. Record its entry count. *(completed —
      **nine** entries, heading at line 5110. New entries start at 10.)*
- [x] Re-locate by name and record current line numbers for: `UniverseClosed`,
      `difficultyBounded_of_stepLengthBounded`, `difficultyBoundedAt_ceiling`,
      `buildTableauAt_isSome_of_budget`, and every theorem whose signature contains
      `(hUcl : UniverseClosed`. *(completed — see the anchor table in the completion note below.)*
- [x] Record the md5 of `Fuel.lean`, `Saturation.lean`, and `Tableau.lean` as the baseline for the
      Phase 9 frozen-file check. *(completed — baseline recorded in the completion note.)*
- [x] Land `mem_signedUniverse_iff` (or `formula_label_of_mem_signedUniverse`) in `MintBound.lean`:
      `x ∈ signedUniverse C L → x.formula ∈ C ∧ x.label ∈ L`. Proof verified green in planning:
      `simp only [signedUniverse, Finset.mem_image, Finset.mem_product, Finset.mem_insert,
      Finset.mem_singleton] at h; obtain ⟨p, ⟨-, hf, hl⟩, rfl⟩ := h; exact ⟨hf, hl⟩`.
      Docstring must say why it lives here and not next to `mem_signedUniverse`: `Fuel.lean` is
      frozen.

**Timing**: 1 hour

**Depends on**: none

**Verification Tier**: local

**Scope Hypothesis**: "the register has nine entries, so the first new one is 10, and there are ten
theorem signatures carrying `hUcl : UniverseClosed` of which exactly four use it." Confirm by
`grep -c` on the register's numbered items and by `grep -n "hUcl\."` before relying on either count
in Phase 3 or Phase 9.

**Files to modify**:
- `FormalSystem/Metalogic/Decidability/Verified/Termination/MintBound.lean` — add the forward
  membership lemma near the `UniverseClosed` block.

**Verification**:
- `lake build FormalSystem.Metalogic.Decidability.Verified.Termination.MintBound` green.
- The recorded anchors and counts are written into the phase's completion note.

#### Phase 1 completion note — recorded ground truth

Baseline `lake build` over the whole project: **green** (2333 jobs) before any edit.

Frozen-file md5 baseline:

| File | md5 |
|------|-----|
| `Verified/Termination/Fuel.lean` | `8a395bd7117a682c1f8302a2ac5f0f1f` |
| `Saturation.lean` | `ae47004e06e77f2846cc3e1dfa408382` |
| `Tableau.lean` | `cfd82332c8e400ac97ab709ece5dfb4a` |

Anchors, pre-edit (`MintBound.lean` was 5191 lines):

| Target | Line |
|--------|------|
| `UniverseClosed` (def) | 3904 |
| `difficultyBounded_of_stepLengthBounded` | 4198 |
| `difficultyBoundedAt_ceiling` | 4331 |
| `buildTableauAt_isSome_of_budget` | 5009 |
| register heading `## C9.` | 5110 |

`hUcl : UniverseClosed` signature count: **10** — scope hypothesis confirmed.

`hUcl.` projection sites: **6** occurrences (`hUcl.1` at 4203, 4338, 4554; `hUcl.2` at 4213, 4348,
4667), distributed over **exactly 4 consuming theorems** — the ones at 4198, 4331, 4546, 4622. The
plan's scope hypothesis said "4 hits" for `grep -n "hUcl\."`; the raw grep count is 6 because two of
the four theorems project both conjuncts. **The scope claim is confirmed at theorem granularity**
(four consuming theorems), which is the granularity Phase 3 edits at; the raw-hit figure is
corrected here rather than absorbed.

`UniverseClosed` appears in exactly one file (`MintBound.lean`), so the Phase 3 sweep is
file-local.

Additional ground truth needed by later phases, read during Phase 1:
- `Branch.identifyTime b src tgt = (b.map fun sf => if sf.label.time == src then {sf with label :=
  {sf.label with time := tgt}} else sf).eraseDups` — so in clause 2's `b.identifyTime t₂ t₁`, the
  **source** is `t₂` and the **target** is `t₁`.
- `expandOnceUnblocked_splitOrdered_shape` returns arm 3 as `(b.identifyTime t₂ t₁, …)` together
  with `firstIncomparablePair b ord = some (t₁, t₂)`, and `firstIncomparablePair_spec` turns that
  into `t₁ ∈ b.knownTimes ∧ t₂ ∈ b.knownTimes ∧ …`. So the target `t₁` is always a known time at
  every consuming site — this is what makes Phase 3's restriction free.
- `Label` is `structure Label where world : WorldIndex; time : TimeIndex` with `DecidableEq`;
  `WorldIndex = TimeIndex = Nat`. `Branch := List SignedFormula` (no `Nodup`).

**Landed**: `formula_label_of_mem_signedUniverse`.

---

### Phase 2: Clause (2) satisfiability verdict [COMPLETED]

**Goal**: Settle, with a machine-checked theorem, whether clause 2 of `UniverseClosed` is provable,
repairable, or refutable as literally stated. **This is the pivot gate for Phases 3 and 4.**

**Tasks**:
- [x] Land the refutation `universeClosed_identify_retime_false`: from `U.Nonempty` and clause 2 of
      `UniverseClosed` (stated as the standalone proposition, not via the conjunction), derive
      `False`. The planning probe compiled green and is the intended proof:
      instantiate clause 2 at `b = [x]`, `t₂ = x.label.time`, `t₁ = t` to obtain
      `⟨x.sign, x.formula, ⟨x.label.world, t⟩⟩ ∈ U` for every `t`, then apply
      `Finset.exists_ne_map_eq_of_card_lt_of_maps_to` at `Finset.range (U.card + 1)` and close with
      injectivity of the retiming. No frame-class hypothesis is needed and none should be added.
- [x] Land the corollary `universeClosed_nonempty_false`: `U.Nonempty → ¬ UniverseClosed fc U`, by
      projecting `.2` and applying the above.
- [x] Land the complementary fact that makes the refutation informative rather than merely negative:
      clause 2 *does* hold at `U = ∅` (vacuously, since confinement forces `b = []`). This is what
      shows the residual is not merely unproved but **satisfiable only where the terminus is
      vacuous**. *(landed as `universeClosed_identify_empty`.)*
- [x] Write the verdict into the phase's completion note in one of exactly three forms:
      **(a) provable as stated** — then Phase 3 is skipped and Phase 4 proves clause 2 directly;
      **(b) repairable** — the expected outcome; Phases 3 and 4 proceed as written;
      **(c) neither** — stop and mark the phase `[BLOCKED]` with the goal state reached.
- [x] Extend `UniverseClosed`'s docstring with the refutation, in the same register-citing style the
      `DifficultyBounded` docstring uses: name the witness, name the cause in one line (the merge
      target `t₁` is unconstrained, so a `Finset` universe would have to contain a retiming of one of
      its own members at every one of infinitely many times), and state that the definition is
      retained verbatim because the landed terminus is stated against it.

**Timing**: 1.5 hours

**Depends on**: 1

**Verification Tier**: full

**Commit Mode**: per-substep

**Scope Hypothesis**: "the refutation goes through with `U` universally quantified and no frame-class
hypothesis, exactly as the planning probe did." Confirm by reproducing the probe inside
`MintBound.lean` before generalizing anything; if the in-file version needs a hypothesis the probe
did not, record the difference rather than absorbing it.

**Files to modify**:
- `FormalSystem/Metalogic/Decidability/Verified/Termination/MintBound.lean` — the refutation, the
  corollary, the `U = ∅` complement, and the `UniverseClosed` docstring extension.

**Verification**:
- `lake build` scoped to the module, green.
- `lean_verify` on both new theorems: zero sorries, zero added axioms, no `native_decide`.
- The written verdict is one of the three pre-declared forms.

#### Phase 2 completion note — VERDICT

**Verdict: (b) repairable.** Clause 2 of `UniverseClosed` is **refutable as literally stated**, at
every nonempty `U`, and the repair named in the plan is the right one. Phases 3 and 4 proceed as
written.

Machine-checked, green, axiom set exactly `{propext, Classical.choice, Quot.sound}` on all three:

| Declaration | Content |
|-------------|---------|
| `universeClosed_identify_retime_false` | `U.Nonempty` + clause 2 standalone → `False` |
| `universeClosed_nonempty_false` | `U.Nonempty → ¬ UniverseClosed fc U` |
| `universeClosed_identify_empty` | clause 2 holds at `U = ∅`, vacuously |

**The scope hypothesis is confirmed exactly**: the refutation went through with `U` universally
quantified and **no frame-class hypothesis** — `fc` does not appear in
`universeClosed_identify_retime_false` at all. The in-file version needed nothing the planning probe
did not.

**The satisfiability set of clause 2 is exactly `{∅}`**, by the conjunction of the refutation and the
empty-universe complement. Since `signedUniverse C L` is empty only when `C` or `L` is, the residual
as stated is satisfiable only where the terminus has nothing to say. This is the same class of defect
as `difficultyBounded_multiplicity_false` (register entry 9) in a different coordinate: there the
unconstrained quantity was the branch's list length, here it is the identification's merge target.

`UniverseClosed`'s docstring was extended with the refutation, the retention rationale, and a
forward pointer to `UniverseClosedAt`. It also now **corrects** its own earlier claim that the
definition "is a statement about `L`" for `U = signedUniverse C L`: true for clause 2's repaired
form, false for clause 1's label dimension (Phase 5 settles that).

---

### Phase 3: The repaired predicate, and the chain generalization [COMPLETED]

**Goal**: Introduce `UniverseClosedAt` — clause 1 unchanged, clause 2 restricted to
`t₁ ∈ b.knownTimes` — record that it is strictly weaker than `UniverseClosed`, and generalize the
existing chain to assume it, without withdrawing any landed statement.

**Tasks**:
- [x] Define `UniverseClosedAt fc U`: clause 1 verbatim from `UniverseClosed`, clause 2 as
      `∀ (b : Branch) (t₁ t₂ : TimeIndex), (∀ x ∈ b, x ∈ U) → t₁ ∈ b.knownTimes →
      ∀ x ∈ b.identifyTime t₂ t₁, x ∈ U`. Do **not** also constrain `t₂` — planning verified `t₂` is
      not needed, and constraining it would weaken the predicate for no gain. *(landed exactly as
      specified; `t₂` left free.)*
- [x] Land `universeClosedAt_of_universeClosed : UniverseClosed fc U → UniverseClosedAt fc U`. Its
      docstring must state the direction explicitly: the new hypothesis is weaker, so every theorem
      restated against it is a **strengthening**, in the same sense `ordTimesLeMaxTime_of_ordTimesKnown`
      records for the run invariant. Note that the converse is false by Phase 2's refutation whenever
      `U` is nonempty, so the two are genuinely not interchangeable.
- [x] Generalize the four theorems that *use* the hypothesis to take `UniverseClosedAt`, supplying
      `t₁ ∈ b.knownTimes` locally from `firstIncomparablePair_spec` applied to the trigger returned by
      `expandOnceUnblocked_splitOrdered_shape`. Change one site at a time and build after each.
      *(deviation: altered — done **additively**, as four new `…_at` theorems rather than four
      in-place signature changes. The local `t₁ ∈ b.knownTimes` supply was factored into the named
      bridge `universeClosedAt_identify_at_trigger`. See the mechanism divergence below.)*
- [x] Thread the weakened hypothesis through the remaining signatures up to and including the
      terminus, so the whole chain assumes `UniverseClosedAt`. *(deviation: altered — the spine is
      threaded through six new `…_at` theorems; the six originals are byte-unchanged.)*
- [x] Retain every original-shaped statement as a corollary obtained by composing with
      `universeClosedAt_of_universeClosed`, so no landed statement is withdrawn and the landed
      terminus's original signature remains available by name. *(deviation: altered — the originals
      are retained **as themselves**, byte-identical, which is strictly stronger than retaining them
      as re-derived corollaries: their statements AND their proof terms are unchanged. No composition
      through the bridge was needed, and `universeClosedAt_of_universeClosed` is landed anyway
      because it is what records the direction of the change.)*

**Timing**: 2.5 hours

**Depends on**: 2

**Verification Tier**: full

**Commit Mode**: atomic-batch

**Scope Hypothesis**: "exactly four proof sites consume `hUcl`, and the remaining six signatures only
thread it, so the generalization is four local edits plus a mechanical signature sweep." Confirm with
`grep -n "hUcl\."` (expected: 4 hits) and `grep -n "(hUcl : UniverseClosed"` (expected: 10 hits)
before starting. If a fifth consuming site exists, or if any site reaches `t₁` other than through
`expandOnceUnblocked_splitOrdered_shape`, stop and record it — that site would leak a genuinely new
hypothesis into the terminus and changes the shape of this phase.

**Files to modify**:
- `FormalSystem/Metalogic/Decidability/Verified/Termination/MintBound.lean` — the predicate, the
  bridge, four proof edits, the signature sweep, the retained corollaries.

**Verification**:
- `lake build` full project green (this phase touches the terminus chain).
- Every original-shaped statement still resolves by name, with the same statement text.
- `lean_verify` on the terminus: still sorry-free and axiom-free.

#### Phase 3 completion note

Full `lake build` **green** (2333 jobs). Frozen-file md5s re-checked and unchanged.
`lean_verify` on `buildTableauAt_isSome_at_seed_lengthBudget_at`: axioms exactly
`{propext, Classical.choice, Quot.sound}`.

All new material was placed in one contiguous new section, **`C10`, immediately before the `C9`
register** — chosen for territory isolation, since tasks 433 and 434 also edit this file and the
`MintPaysForTime` / blocking blocks are theirs.

Landed (11 declarations):

| Declaration | Role |
|-------------|------|
| `UniverseClosedAt` | the repaired predicate; clause 1 verbatim, clause 2 with `t₁ ∈ b.knownTimes` |
| `universeClosedAt_of_universeClosed` | the direction record (weaker hypothesis ⇒ strengthening) |
| `universeClosedAt_identify_at_trigger` | the freeness bridge: clause 2 at an ordered split's trigger |
| `difficultyBounded_of_stepLengthBounded_at` | consumer 1 |
| `difficultyBoundedAt_ceiling_at` | consumer 2 |
| `budgetPotential_step_unordered_at` | consumer 3 (clause 1 only) |
| `budgetPotential_step_splitOrdered_at` | consumer 4 (the only clause-2 payment site) |
| `stepDecreases_budgetPotential_at` | spine |
| `expandBranchWithFuel_isSome_of_budget_at` | spine |
| `buildTableauAt_isSome_of_budget_at`, `buildTableauAt_isSome_at_seed_at` | terminus |
| `buildTableauAt_isSome_of_lengthBudget_at`, `buildTableauAt_isSome_at_seed_lengthBudget_at` | terminus, length-budget siblings |

**DIVERGENCE, recorded — mechanism, not substance.** The plan wrote this phase as an in-place
generalization of the ten `hUcl : UniverseClosed fc U` signatures followed by original-shaped
corollaries. It was done additively instead: the ten originals are **byte-identical**, and the chain
at the repaired predicate is added alongside under `…_at` names. Reasons:

1. The dispatch constraint "all edits additive; previously-landed terminus proof terms must stay
   byte-unchanged" is non-negotiable, and an in-place hypothesis-type change alters ten landed
   statements including the terminus.
2. The plan's own Testing & Validation criterion — "every pre-existing theorem statement still
   resolves by name with the same statement" — is **better** served this way: statements *and* proof
   terms are unchanged, rather than statements preserved via re-derivation.

The substance of the phase is fully delivered: the whole chain is available at `UniverseClosedAt`, up
to and including four termini. Nothing is weakened; the divergence is recorded in the `C10` section
preamble in the file as well, in the house "DIVERGENCE, recorded" style.

**Cost of the divergence, stated plainly**: the two arithmetic step lemmas
(`budgetPotential_step_unordered`, `budgetPotential_step_splitOrdered`, ~65 lines each) are restated
rather than shared, because sharing them would require rewriting the landed proofs into one-liners
over factored-out confinement hypotheses. The `C10` preamble names that refactor and says why it was
not done.

**Scope hypothesis, confirmed and corrected.** Four consuming theorems (as Phase 1 recorded), ten
signatures. Both clause-2 consumers reach `t₁` **only** through
`expandOnceUnblocked_splitOrdered_shape`, so no site leaks a new hypothesis — confirmed
constructively by `universeClosedAt_identify_at_trigger` closing both. No fifth consuming site
exists. One refinement on the plan's inventory: `budgetPotential_step_unordered` consumes **clause 1
only**, so it needed no bridge at all.

---

### Phase 4: `TimeMergeClosed`, an instance, and the repaired clause 2 at `signedUniverse C L` [COMPLETED]

**Goal**: State the closure condition on the label set the task asks for, exhibit a nonempty family
satisfying it, and prove the repaired clause 2 at the concrete universe.

**Tasks**:
- [x] Define `TimeMergeClosed (L : Finset Label) : Prop :=
      ∀ l ∈ L, ∀ l' ∈ L, (⟨l.world, l'.time⟩ : Label) ∈ L`. Docstring: this is exactly what clause 2
      reduces to at `U = signedUniverse C L`, because identification moves the *time* coordinate of a
      label and leaves the world coordinate and the formula alone.
- [x] Land `timeMergeClosed_product`: any label set of the form
      `(Ws ×ˢ Ts).image (fun p => ⟨p.1, p.2⟩)` satisfies it. This is the condition's satisfiability
      witness — without it the condition could be vacuous, which is the failure mode 431 warns about.
- [x] Optionally land `timeMergeClosed_iff_product`: a `TimeMergeClosed` `L` *is* the product of its
      world and time projections. If it does not close within the phase's time budget, drop it and
      record that it was dropped — it is a characterization, not a dependency.
- [x] Land `identifyTime_confined_signedUniverse`: under `TimeMergeClosed L`, for every `b` confined
      to `signedUniverse C L`, every `t₂`, and every `t₁ ∈ b.knownTimes`, `b.identifyTime t₂ t₁` is
      confined to `signedUniverse C L`. The planning probe compiled green; its structure is: obtain
      `y ∈ b` with `y.label.time = t₁` from `Branch.knownTimes`'s
      `(b.map (·.label.time)).eraseDups` shape, destructure membership in `b.identifyTime` through
      `List.mem_eraseDups` and `List.mem_map`, case on `z.label.time = t₂`, and close each branch with
      `mem_signedUniverse` — the retimed case using `TimeMergeClosed` at `z.label` and `y.label`.
- [x] State the result as "clause 2 of `UniverseClosedAt` at `signedUniverse C L`" so Phase 8 can
      consume it directly.

**Timing**: 2 hours

**Depends on**: 2

**Verification Tier**: full

**Scope Hypothesis**: "`TimeMergeClosed` as written is the exact reduction of clause 2 at
`signedUniverse C L` — neither stronger nor weaker than needed." Confirm by checking that the proof
uses the condition exactly once, at the retimed case, and that removing it breaks the proof. If the
proof needs a second appeal, the condition is understated and must be restated rather than patched at
the call site.

**Files to modify**:
- `FormalSystem/Metalogic/Decidability/Verified/Termination/MintBound.lean`

**Verification**:
- Module build green.
- `timeMergeClosed_product` instantiated at a concrete nonempty `Ws`, `Ts` by `decide` or by direct
  application, demonstrating the condition is satisfiable and the family nonempty.
- `lean_verify` on all new declarations.

#### Phase 4 completion note

Module build **green**. `lean_verify` on `timeMergeClosed_identifyTime_signedUniverse` and
`timeMergeClosed_concrete_nonempty`: axioms exactly `{propext, Classical.choice, Quot.sound}`.

Landed:

| Declaration | Role |
|-------------|------|
| `TimeMergeClosed` | the closure condition on `L` |
| `timeMergeClosed_product` | satisfiability witness: every rectangle `Ws ×ˢ Ts` qualifies |
| `timeMergeClosed_iff_product` | the optional characterization — **it closed**, so it is kept |
| `timeMergeClosed_identifyTime_signedUniverse` | clause 2 of `UniverseClosedAt` at `signedUniverse C L` |
| `timeMergeClosed_concrete`, `timeMergeClosed_concrete_nonempty` | a concrete nonempty instance, the latter by `decide` |

**Scope hypothesis, confirmed.** `TimeMergeClosed` is the exact reduction: the proof appeals to `hL`
**exactly once**, in the retimed case, and never elsewhere. No second appeal was needed, so the
condition is not understated. `t₂` is genuinely unconstrained in the proof — the source time is only
ever tested against, never used to build a label — which confirms the planning finding that
constraining `t₂` would weaken the predicate for nothing.

**Naming divergence (cosmetic).** The plan named this lemma
`identifyTime_confined_signedUniverse`; it is landed as
`timeMergeClosed_identifyTime_signedUniverse`, so the name leads with the condition it consumes,
matching the file's existing `timeMergeClosed_*` / `ordTimesKnown_*` convention. Same statement.

**The optional characterization was not dropped.** `timeMergeClosed_iff_product` closed inside
budget, and it is worth keeping: it says the rectangles are the *only* time-merge closed label sets,
so a caller has no design decision to make beyond choosing the two projections.

---

### Phase 5: Clause (1) satisfiability verdict at `signedUniverse C L` [COMPLETED]

**Goal**: Settle whether clause 1 can hold at a fixed finite `signedUniverse C L`, given that
`boxNeg` and `diamondPos` emit only at `Branch.nextWorld` and that at least three rules introduce
fresh times. **This is the pivot gate for Phases 6 and 7.**

**Tasks**:
- [x] Read `applyRule_emitted_world_mem`, `applyRule_boxNeg_emitted_world`, and
      `applyRule_diamondPos_emitted_world` and record precisely what each gives.
- [x] Determine whether a branch confined to `signedUniverse C L` can be arranged so that
      `expandOnceUnblocked` picks a fresh-world or fresh-time rule whose emitted label escapes `L`.
      The argument to check: `b` confined implies every world of `b` is a world of `L`, so
      `b.nextWorld` is one past `b.maxWorld`; choose `b` realizing the largest world of `L` and a
      `C` containing a `boxNeg`-triggering formula. Blocking cannot be relied on to prevent this,
      because clause 1 quantifies over **every** tracker `tr` and `blocking_fires_of_card_lt`
      requires an `allEventualitiesFulfilledOrDuplicated` guard the caller must supply.
- [x] Land the verdict as a theorem, in whichever of these forms is true:
      **(b) refutable** (expected) — a machine-checked witness in the style of
      `ordTimes_identifyTime_arm3_false`: exhibit concrete `C`, `L`, `b`, `ord`, `tr` and decide that
      the step's successor contains a formula outside `signedUniverse C L`. Prefer a `decide`-based
      witness; `native_decide` is **not** acceptable (Phase 9 asserts a zero count).
      **(a) provable under conditions** — then state the conditions on `C` and `L` explicitly and
      proceed to prove them in Phase 7.
      **(c) undecided within budget** — mark `[BLOCKED]` with the configurations tried.
- [x] Write the verdict into the phase's completion note, naming which of Phase 7's two branches it
      selects.

**Timing**: 2 hours

**Depends on**: 1

**Verification Tier**: full

**Scope Hypothesis**: "a concrete refuting configuration is reachable by `decide` on a
single-formula branch." Confirm early with `#eval` on `expandOnceUnblocked` at the candidate
configuration to see the emitted labels *before* investing in a `decide` proof. If `decide` times
out on the engine, fall back to a general argument from `applyRule_boxNeg_emitted_world` plus a
`pick`-level bridge, and record the change of route.

**Files to modify**:
- `FormalSystem/Metalogic/Decidability/Verified/Termination/MintBound.lean`

**Verification**:
- Module build green; the verdict theorem is sorry-free and free of `native_decide`.
- The written verdict names one of the three pre-declared forms and selects a Phase 7 branch.

#### Phase 5 completion note — VERDICT

**Verdict: (b) refutable.** Clause 1 is **refutable at a fixed finite `signedUniverse C L`**, at every
frame class and every tracker. **This selects Phase 7 branch (b).**

Module build **green**; `lean_verify` on `universeClosed_fresh_world_escapes` and
`worldHeadroom_fixed_finite_false`: axioms exactly `{propext, Classical.choice, Quot.sound}`. **No
`native_decide` anywhere** — the witness runs on `rfl`-level rule computations plus one `simp`
short-circuit, and is generic in `fc` and `tr` rather than decided at one concrete frame class.

What the three world-emission lemmas give (task 1 of the phase, recorded):

| Lemma | Content |
|-------|---------|
| `applyRule_emitted_world_mem` | the other 34 rules emit only inside `b.worldFinset` |
| `applyRule_boxNeg_emitted_world` | `boxNeg` emits **only** at `Branch.nextWorld` |
| `applyRule_diamondPos_emitted_world` | same for `diamondPos` |
| `nextWorld_not_mem_worldFinset` (pre-existing) | `Branch.nextWorld` is not a world of `b` |

Landed (section `FreshWorldRefutation`):

| Declaration | Role |
|-------------|------|
| `freshWorldWitness`, `freshWorldBranch`, `freshWorldEmitted`, `freshWorldStock`, `freshWorldLabels` | the configuration: `F(□p)@⟨0,0⟩`, `C = {□p, p}`, `L = {⟨0,0⟩}` |
| `findApplicableRule_freshWorldWitness` | `.boxNeg` is the pick, at **every** frame class |
| `expandOnceUnblocked_freshWorldBranch` | the step is `.extended`, emitting at world `1` |
| `freshWorldBranch_confined` | the witness branch is `signedUniverse C L`-confined |
| `universeClosed_fresh_world_escapes` | **the verdict**: clause 1 is false there, at every `fc` |
| `universeClosedAt_fresh_world_escapes` | hence `¬ UniverseClosedAt fc (signedUniverse …)` too |
| `worldHeadroom_fixed_finite_false` | **no** nonempty finite `L` supplies world headroom |

**Scope hypothesis, confirmed with a route change recorded.** The plan expected "a concrete refuting
configuration reachable by `decide` on a single-formula branch", with `#eval` first. The `#eval`
confirmed the configuration immediately: the step at `[F(□p)@⟨0,0⟩]` emits `F(p)@⟨1,0⟩`. But the
final proof is **not** `decide` — it follows the plan's own named fallback, "a general argument from
`applyRule_boxNeg_emitted_world` plus a `pick`-level bridge", in the `multWitness` template's style:
nine `isApplicable … = false` facts by `rfl`, generic in `fc`. **The route change is an
improvement**, and is recorded here as the plan required: a `decide` witness would have been pinned
to one concrete frame class, whereas this one is universally quantified in both `fc` and `tr`, which
is what closes off "some other frame class might behave differently".

**Two findings beyond what the phase asked for, both load-bearing for Phases 7-9:**

1. **The clause-2 repair does not rescue clause 1.** `UniverseClosed` and `UniverseClosedAt` carry
   clause 1 **verbatim**, so one witness refutes the first conjunct of both.
   `universeClosedAt_fresh_world_escapes` states this outright. Any docstring claiming
   `UniverseClosedAt` is simply "satisfiable" is imprecise and must be corrected in Phase 9 — the
   precise claim is that its *fatal* defect (clause 2, unsatisfiable except at `U = ∅`) is repaired,
   while clause 1 needs an additional branch-side hypothesis.
2. **The obstruction provably cannot be moved into `L`.** `worldHeadroom_fixed_finite_false` is
   general over all nonempty finite `L`, so this is not "we did not find a closure condition" but
   "no closure condition on `L` exists". That is exactly the asymmetry with clause 2, where
   `TimeMergeClosed` closes the gap outright: identification moves a label *within* the existing
   coordinates, whereas `boxNeg` moves it *past* them.

---

### Phase 6: Clause (1), formula dimension, for both `.extended` and `.split` [COMPLETED]

**Goal**: Prove the half of clause 1 that is unconditionally available: a step out of a
`C`-confined branch keeps every successor's formulas in `C`, across both unordered successor shapes.

**Tasks**:
- [x] `.extended` case: reuse `expandOnceUnblocked_extended_mem` (`Fuel.lean:305`) directly. It needs
      `TableauClosed C`, `∀ x ∈ b, x.formula ∈ C`, and `TrichClosed C b`; the last comes from
      `TrichStock C` via `trichClosed_of_trichStock`, exactly as
      `expandOnceUnblocked_extended_stock` does it.
- [x] `.split` case: land the missing analogue in `MintBound.lean`. Route:
      `expandOnceUnblocked_split_shape` gives `bs = bss.map (· ++ b)`; the pick bridges give a rule
      and a trigger `sf ∈ b`; `applyRule_subformula_closed` (`SubformulaProperty.lean:1338`) is
      stated over `RuleResult.emitted` and so covers `.branching` as well as the two shapes
      `pick_result_mem` handles. Assemble into
      `expandOnceUnblocked_split_mem : … → ∀ nb ∈ bs, ∀ x ∈ nb, x.formula ∈ C`.
- [x] Combine into a single statement over `unorderedSuccessorBranches`, since that is the shape
      clause 1 is written at: `unorderedSuccessorBranches` is `[nb]` on `.extended`, `bs` on
      `.split`, and `[]` otherwise, so the `.splitOrdered` and `.saturated` cases are vacuous here.
- [x] Do **not** attempt the label dimension in this phase. Keeping the two dimensions separate is
      what makes Phase 7's verdict-dependent branch tractable.

**Timing**: 2 hours

**Depends on**: 5

**Verification Tier**: full

**Scope Hypothesis**: "`applyRule_subformula_closed` covers the `.branching` shape, so the `.split`
analogue needs no new per-rule case analysis — only the pick-stage destructuring
`expandOnceUnblocked_extended_mem` already demonstrates." Confirm by checking
`RuleResult.emitted`'s definition covers `.branching` before writing the proof. If it does not, the
phase grows a 36-arm case split and must be re-timed rather than rushed.

**Files to modify**:
- `FormalSystem/Metalogic/Decidability/Verified/Termination/MintBound.lean`

**Verification**:
- Module build green; both cases sorry-free.
- `lean_verify` on the combined statement.

#### Phase 6 completion note

Module build **green**; `lean_verify` on `unorderedSuccessor_formula_mem`: axioms exactly
`{propext, Classical.choice, Quot.sound}`.

Landed:

| Declaration | Role |
|-------------|------|
| `pick_split'` (private) | `Fuel.lean`'s `private pick_split`, restated because it is not exported |
| `expandOnceUnblocked_split_mem` | **the missing `.split` analogue** of `expandOnceUnblocked_extended_mem` |
| `unorderedSuccessor_formula_mem` | the combined statement, at clause 1's own shape, from `TableauClosed C` + `TrichStock C` + confinement |

**Scope hypothesis, confirmed.** `RuleResult.emitted` (`SubformulaProperty.lean`) is defined on all
five result shapes and sends `.branching bss` to `bss.flatten`, so `applyRule_subformula_closed`
already covers the branching arms. **No 36-arm case split was needed** and the phase did not need
re-timing. The only work was the pick-stage destructuring, which is
`expandOnceUnblocked_extended_mem`'s own three-stage `rcases` with `pick_result_mem` (linear /
persistent only) replaced by `applyRule_subformula_closed` directly — exactly the route the plan
named.

One implementation detail worth recording: the three pick bridges used are MintBound's own
`findApplicable{,Serial,Linearity}Rule_applyRule_pair` (section A4) rather than `Fuel.lean`'s
`…_applyRule_eq`, because the `.branching` case needs the ordering component to match
`(RuleResult.branching bss, o)` as a pair.

**The `.splitOrdered` and `.saturated` shapes are vacuous** in the combined statement, since
`unorderedSuccessorBranches` is `[]` on both — so the statement is complete, not partial.

**Reading of the result, stated so Phase 7 is not misread**: clause 1's *formula* coordinate is
unconditionally safe. The refutation in Phase 5 is entirely about the *label* coordinate. Separating
the two is what makes that precise.

---

### Phase 7: Clause (1), label dimension, per Phase 5's verdict [BLOCKED]

**Goal**: Land the honest maximum on the label dimension, on whichever of two pre-declared branches
Phase 5 selected. Do not choose a third route.

**Branch (a) — Phase 5 found clause 1 provable under conditions**:
- [ ] State the conditions on `C` and `L` explicitly as a named predicate.
- [ ] Prove the world component from `applyRule_emitted_world_mem` plus the two `nextWorld` lemmas.
- [ ] Prove the time component. If it requires the time-dimension analogue of
      `applyRule_emitted_world_mem`, **stop**: that is task 434's territory. Record the dependency and
      mark this sub-branch `[BLOCKED]` on it rather than authoring the analogue here.
- [ ] Combine with Phase 6 into clause 1 at `signedUniverse C L`.

**Branch (b) — Phase 5 refuted clause 1 at every fixed finite `L`** (expected) — **THIS IS THE
BRANCH THAT RAN**, per Phase 5's written verdict:
- [x] Land the refutation from Phase 5 as the definitive statement, with its witness named.
      *(`universeClosed_fresh_world_escapes`, with `universeClosedAt_fresh_world_escapes` recording
      that the clause-2 repair does not rescue it.)*
- [x] Name the repaired condition. The repair is a **branch-side headroom** hypothesis, not a further
      closure condition on `L`: a fixed finite universe cannot absorb fresh labels, because each
      enlargement of `L` raises the reachable `maxWorld`/`maxTime` and re-opens the gap. State it as
      such, and say plainly that this is why the condition cannot be moved into `L`.
      *(`FreshWorldHeadroom`, with `freshWorldHeadroom_not_universal` **proving** — not merely
      asserting — that it cannot be moved into `L`, at every nonempty finite `L`.)*
- [x] Record the obligation map for the headroom condition, in the style
      `StepLengthGrowth`'s docstring uses: what each rule shape needs, which existing lemma supplies
      it, and which piece is missing (the time-dimension analogue, owned elsewhere).
      *(On `UnorderedSuccessorLabelClosed`'s docstring, per coordinate. The world coordinate is
      backed by a new lemma, `applyRule_emitted_world_dichotomy`, rather than by prose.)*
- [ ] State clause 1 at `signedUniverse C L` **with** the headroom hypothesis, so Phase 8 has a
      concrete composite to assemble. The hypothesis stays explicit and named; it is not absorbed.
      *(deviation: PARTIAL — clause 1 is stated and proved at `signedUniverse C L` reduced to the
      **label coordinate alone** (`unorderedSuccessor_confined_signedUniverse_of_headroom`), with the
      formula coordinate discharged outright. It is **not** proved from `FreshWorldHeadroom`, because
      doing so requires the missing time-coordinate lemma — see the blocker below. The label
      coordinate is instead carried as the named residual `UnorderedSuccessorLabelClosed`.)*

**Timing**: 2 hours

**Depends on**: 5, 6

**Verification Tier**: full

**Scope Hypothesis**: "the headroom condition is expressible over `b` alone, without reference to the
run's remaining budget." Confirm by writing the statement and checking it does not need `σ` or
`Tmax`. If it does, the condition belongs to the budget story and this phase records that finding
instead of forcing a branch-local form.

**Files to modify**:
- `FormalSystem/Metalogic/Decidability/Verified/Termination/MintBound.lean`

**Verification**:
- Module build green; every new declaration sorry-free.
- The chosen branch matches Phase 5's written verdict, and the phase note says which branch ran.

**BLOCKER** (Phase 7):
- **What failed**: proving clause 1's label dimension at `signedUniverse C L` from the branch-side
  headroom condition `FreshWorldHeadroom`. Specifically, discharging `∀ x ∈ nb, x.label ∈ L` for
  every unordered successor `nb` requires bounding **both** label coordinates of every emitted
  formula. The **world** coordinate is fully available. The **time** coordinate has no supporting
  lemma anywhere in the development.
- **What was tried**: the world coordinate was assembled and landed as
  `applyRule_emitted_world_dichotomy` — every emitted formula sits at a world of `b` or at
  `Branch.nextWorld`, no third case — from `applyRule_emitted_world_mem` (34 rules) plus
  `applyRule_boxNeg_emitted_world` and `applyRule_diamondPos_emitted_world`. Searched for a time
  analogue: `lean_local_search` on `nextTime` and a grep for `emitted_time` / `_time_mem` across
  `FormalSystem/` return nothing. The eight-rule `ruleMintsFreshLabel` list was checked and is **not**
  the list of time-introducing rules — `densityRule` interpolates a fresh time while being absent
  from it, and the active arms of `untlNeg`/`snceNeg` introduce times while being classified
  `ruleSelfGuarded`.
- **Why it's stuck**: the missing statement is a time-coordinate analogue of
  `applyRule_emitted_world_mem` — a 36-arm accounting over `applyRule` bounding emitted *times* by
  `b.knownTimes` with the time-minting rules separated out. Its absence is named on
  `MintPaysForTime`'s own docstring, which places it in the mint/time story.
- **What is needed**: that lemma. **It is explicitly out of scope for this task** — the plan's
  Non-Goals name it as another task's territory ("the time-dimension analogue of
  `applyRule_emitted_world_mem` is 434's territory; this plan may *consume* it if it lands first but
  must not author it"), and it had not landed at dispatch time. The plan's branch (b) instruction is
  followed literally: "If it requires the time-dimension analogue of `applyRule_emitted_world_mem`,
  **stop**: that is task 434's territory. Record the dependency and mark this sub-branch `[BLOCKED]`
  on it rather than authoring the analogue here."
- **Prohibited workarounds**: no `sorry`, no `def X := True`, no vacuous placeholder was used. In
  particular the label residual was **not** defined as something trivially true, and it is not
  circular window-dressing: `unorderedSuccessorLabelClosed_not_universal` proves it **fails** at a
  concrete `L`, so it is a genuine condition and the composite that assumes it is genuinely
  conditional rather than vacuous.

#### Phase 7 completion note — branch (b), partially delivered

**Branch (b) ran**, matching Phase 5's written verdict. Module build **green**; every new declaration
sorry-free and axiom-free.

Landed:

| Declaration | Role |
|-------------|------|
| `applyRule_emitted_world_dichotomy` | **new**: the complete world-coordinate accounting, `b.worldFinset ∨ b.nextWorld`, no third case |
| `FreshWorldHeadroom` | the named branch-side headroom condition (moved into Phase 5's section so `freshWorldHeadroom_not_universal` can be stated at it) |
| `freshWorldHeadroom_not_universal` | **proof** that the condition cannot be moved into `L`, at every nonempty finite `L` |
| `UnorderedSuccessorLabelClosed` | clause 1's label coordinate as a named residual, carrying the per-coordinate obligation map |
| `unorderedSuccessor_confined_signedUniverse_of_headroom` | clause 1 at `signedUniverse C L`, reduced to the label coordinate alone |
| `unorderedSuccessorLabelClosed_not_universal` | the residual is a genuine condition: it **fails** at `freshWorldLabels` |

**Scope hypothesis, confirmed.** "The headroom condition is expressible over `b` alone, without
reference to the run's remaining budget." Confirmed: `FreshWorldHeadroom L b` mentions only `L` and
`b` — no `σ`, no `Tmax`, no fuel. So the condition does not belong to the budget story.

**Refinement made to Phase 5's landed material** (additive, within this task's own new code):
`worldHeadroom_fixed_finite_false` was restated as `freshWorldHeadroom_not_universal`, quantifying the
headroom over `t ∈ b.knownTimes` rather than over all `t : TimeIndex`. This is a **stronger**
theorem — it refutes a weaker headroom assumption — and it makes `FreshWorldHeadroom` load-bearing
rather than decorative. Two docstring cross-references were updated to the new name.

---

### Phase 8: The composite theorem, and the terminus corollary [COMPLETED]

**Goal**: Land the deliverable — a theorem establishing the repaired closure predicate at the
concrete, useful instantiation `U = signedUniverse C L` — and a terminus corollary stated at it.

**Tasks**:
- [x] Land `universeClosedAt_signedUniverse`: `UniverseClosedAt fc (signedUniverse C L)` from
      `TableauClosed C`, `TrichStock C`, `TimeMergeClosed L`, and whatever Phase 7 left explicit.
      Clause 2 comes from Phase 4; clause 1 from Phases 6 and 7.
- [x] Land the terminus corollary: `buildTableauAt_isSome_of_budget` (or, if the length-budget
      sibling is the live one, `buildTableauAt_isSome_of_lengthBudget`) with the `UniverseClosedAt`
      hypothesis discharged at `signedUniverse C L`, leaving only the other residuals. This is the
      statement that shows the residual is actually *paid* rather than merely renamed.
- [x] Write a docstring on the composite naming precisely which residuals remain on the corollary,
      so a reader is not misled into thinking the terminus is now unconditional.
- [x] If Phase 7 ran branch (b), state on the corollary that the headroom hypothesis is the residue
      and where its obligation map lives.

**Timing**: 1.5 hours

**Depends on**: 3, 4, 7

**Verification Tier**: full

**Commit Mode**: per-substep

**Scope Hypothesis**: "the composite needs exactly the three named conditions plus Phase 7's residue,
and no additional side condition surfaces during assembly." Confirm by assembling with explicit
hypotheses and letting the elaborator report anything missing; add any surfaced condition to the
statement rather than to a `simp` set.

**Files to modify**:
- `FormalSystem/Metalogic/Decidability/Verified/Termination/MintBound.lean`

**Verification**:
- `lake build` full project green.
- `lean_verify` on the composite and the corollary: sorry-free, axiom-free, no `native_decide`.

#### Phase 8 completion note

Module build **green**; `lean_verify` on `universeClosedAt_signedUniverse_of_headroom` and
`buildTableauAt_isSome_at_seed_lengthBudget_signedUniverse`: axioms exactly
`{propext, Classical.choice, Quot.sound}`.

Landed:

| Declaration | Role |
|-------------|------|
| `universeClosedAt_signedUniverse_of_headroom` | the composite: `UniverseClosedAt fc (signedUniverse C L)` from `TableauClosed C`, `TrichStock C`, `TimeMergeClosed L`, and the one named residual |
| `buildTableauAt_isSome_of_lengthBudget_signedUniverse` | the terminus with the closure residual paid at `signedUniverse C L` |
| `buildTableauAt_isSome_at_seed_lengthBudget_signedUniverse` | the caller-facing form, every number read off |

**The composite is conditional, and the plan's naming is adjusted to say so.** The plan named it
`universeClosedAt_signedUniverse`, i.e. unconditional. Because Phase 7 is blocked on the missing
time-coordinate lemma, the honest statement carries the named residual
`UnorderedSuccessorLabelClosed fc L`, and the declaration is named
`universeClosedAt_signedUniverse_of_headroom` to make the conditionality visible at the call site
rather than hidden in a hypothesis list. *(deviation: altered — conditional form and `_of_headroom`
suffix, forced by Phase 7's blocker; the plan pre-declared this outcome in its Risks table and in
branch (b).)*

**The length-budget sibling is the live one**, so the corollary is stated there rather than at
`buildTableauAt_isSome_of_budget` — the plan's own parenthetical permits exactly this choice, and
`DifficultyBounded` being refutable at every `D` (`difficultyBounded_multiplicity_false`) is why.

**Scope hypothesis, confirmed.** "The composite needs exactly the three named conditions plus Phase
7's residue, and no additional side condition surfaces during assembly." Confirmed: the composite is
a two-line anonymous-constructor term and the elaborator surfaced nothing beyond
`TableauClosed C`, `TrichStock C`, `TimeMergeClosed L`, and `UnorderedSuccessorLabelClosed fc L`. No
condition was hidden in a `simp` set.

**What the terminus corollary actually pays, stated exactly** (and written onto its docstring):
clause 2 in full — the conjunct that was unsatisfiable at every nonempty universe is now a rectangle
condition on the label set — plus clause 1's formula coordinate. What remains of this residual is
clause 1's **label** coordinate and nothing else. The three unrelated residuals
(`MintPaysForTime`, `PostBlockingSettles`, `β ≥ 3`) and `StepLengthBounded` are carried across
unaltered.

---

### Phase 9: Register entries, cross-references, and the full gate [COMPLETED]

**Goal**: Record every refuted statement in the do-not-re-attempt register, reconcile the
docstrings, and run the complete verification gate.

**Tasks**:
- [x] Add a register entry for clause 2 of `UniverseClosed`: refuted, not merely unproved, by
      Phase 2's witness; cause in one line (unconstrained merge target `t₁` forces a finite universe
      to contain infinitely many retimings of one of its own members); the repaired form is
      `UniverseClosedAt`, and `universeClosedAt_of_universeClosed` records the direction. Follow the
      register's existing conventions: cite by declaration name, never by task number.
- [x] Add a register entry for whatever Phase 5 refuted, if it refuted anything, with its witness. *(entry 11.)*
- [x] Add a register entry warning against the tempting-but-wrong repair of clause 2 — constraining
      `t₂` instead of `t₁`, or constraining both. Planning verified `t₁` alone suffices; a reader who
      constrains both has needlessly weakened the predicate.
- [x] Reconcile every docstring that describes `UniverseClosed` as a caller's obligation about the
      label set. That description is now partly wrong: for clause 2 it is right and Phase 4 supplies
      the condition; for clause 1's label dimension it understates the situation. Update the
      `UniverseClosed` docstring and the `.splitOrdered` note on
      `difficultyBounded_of_stepLengthBounded`.
- [x] Run the full gate: `lake build` over the whole project; `lean_verify` on every declaration this
      task added; grep for `sorry`, `native_decide`, and the vacuous-definition patterns; confirm the
      three frozen files' md5s match the Phase 1 baseline; confirm the landed terminus's original
      statements still resolve; run `.claude/scripts/check-task-references.sh` so no task number
      leaks into `FormalSystem/**`.
- [x] Write the task summary to
      `specs/432_discharge_universeclosed_residual/summaries/01_universeclosed-clause2-verdict-instantiation-summary.md`,
      separating what is **landed** from what is **named but not discharged**.

**Timing**: 1.5 hours

**Depends on**: 8

**Verification Tier**: full

**Scope Hypothesis**: "the register has nine entries, so the new ones start at 10." Confirm against
Phase 1's recorded count; if the register grew because task 433 or 434 landed first, renumber to
follow theirs rather than colliding.

**Files to modify**:
- `FormalSystem/Metalogic/Decidability/Verified/Termination/MintBound.lean` — register entries and
  docstring reconciliation.
- `specs/432_discharge_universeclosed_residual/summaries/01_universeclosed-clause2-verdict-instantiation-summary.md` — new.

**Verification**:
- Full `lake build` green.
- Zero sorries, zero vacuous definitions, zero `native_decide`, axiom set limited to
  `propext`, `Classical.choice`, `Quot.sound`.
- Frozen-file md5s unchanged.
- `check-task-references.sh` passes.

#### Phase 9 completion note — the full gate

Register entries **10, 11, 12** added; preamble updated "Nine statements" -> "Twelve statements".

| Entry | Content |
|-------|---------|
| 10 | clause 2 of `UniverseClosed` at any nonempty `U`: refuted, witness `universeClosed_identify_retime_false`, satisfiability set exactly `{∅}`, repair `UniverseClosedAt` |
| 11 | clause 1 of **both** predicates at a fixed finite `signedUniverse C L`: refuted, witness `universeClosed_fresh_world_escapes`; **and** any `L`-side repair of it, refuted by `freshWorldHeadroom_not_universal` |
| 12 | the tempting-but-wrong repairs of clause 2: constraining `t₂` instead of `t₁` (repairs nothing) or constraining both (needlessly weaker) |

Docstrings reconciled: `UniverseClosed` (the refutation, the retention rationale, and a **correction**
of its own earlier claim that the definition "is a statement about `L`" — true for clause 2's repaired
form, false for clause 1's label coordinate); `UniverseClosedAt` (precise statement of what the repair
does and does not fix, since clause 1 is refuted at it too); and
`difficultyBounded_of_stepLengthBounded`'s `.splitOrdered` note (its closure antecedent is
unsatisfiable; the `_at` sibling is the usable one).

**Scope hypothesis, confirmed.** The register had nine entries at Phase 1, so the new ones started at
10. Tasks 433/434 had not landed register entries in the interim — verified by re-reading the register
before writing.

**Gate results:**

| Check | Result |
|-------|--------|
| full `lake build` | **green**, 2333 jobs |
| sorries in `MintBound.lean` | **0** (the single grep hit is the word "admits" in prose) |
| sorries introduced anywhere | **0** — the census's hits are all pre-existing `FormalSystem/Boneyard/` legacy |
| `native_decide` in `MintBound.lean` | **0** |
| vacuous definitions | **0** |
| new axioms | **0** (`grep '^axiom '` finds only two prose lines in `Boneyard` docstrings) |
| `lean_verify` axiom sets | exactly `{propext, Classical.choice, Quot.sound}` on all 12 spot-checked declarations, including all four `…_at` termini and both `signedUniverse` corollaries |
| frozen-file md5s | **all three identical** to the Phase 1 baseline |
| `check-task-references.sh` | **PASS**, 0 occurrences; `FormalSystem/**` separately grepped clean |

**Landed statements preserved — verified by diff, not by assertion.** Diffing `MintBound.lean` against
the true session baseline (`742a1b26d`) shows **exactly six deleted lines**, every one of them a
docstring tail displaced by the three plan-sanctioned docstring extensions plus the register preamble
edit. **Zero statement lines and zero proof-term lines were deleted.** So all ten
`hUcl : UniverseClosed` theorems — the terminus among them — are byte-identical in both statement and
proof.

*(Note recorded for accuracy: an initial diff was taken against `4cb7652c7`, the HEAD reported in the
session's opening git snapshot. That was the wrong baseline — task 431's seven commits landed between
that snapshot and this task's first command, so the diff attributed 431's docstring corrections and
its register entry 9 to this task. Re-run against `742a1b26d`, the commit immediately preceding Phase
1.)*

---

## Testing & Validation

- [ ] `lake build` green over the full project at Phases 3, 8, and 9.
- [ ] Every new declaration passes `lean_verify` with zero sorries and no added axioms.
- [ ] No `native_decide` anywhere in the new code.
- [ ] No vacuous definitions (`def X := True`, `theorem X := trivial`, and the rest of the prohibited
      set in `rules/lean4.md`).
- [ ] `Fuel.lean`, `Saturation.lean`, `Tableau.lean` byte-identical to the Phase 1 md5 baseline.
- [ ] `UniverseClosed`'s definition text unchanged; every pre-existing theorem statement still
      resolves by name with the same statement.
- [ ] Every refuted statement has a register entry citing its witness by declaration name.
- [ ] `TimeMergeClosed` demonstrated satisfiable at a concrete nonempty instance, so the condition is
      not vacuous.
- [ ] `.claude/scripts/check-task-references.sh` passes — no task numbers in `FormalSystem/**`.

## Artifacts & Outputs

- `FormalSystem/Metalogic/Decidability/Verified/Termination/MintBound.lean` — the forward membership
  lemma, the clause-2 refutation and its corollaries, `UniverseClosedAt` with its strengthening
  record, the generalized chain, `TimeMergeClosed` with an instance, the repaired clause 2 at
  `signedUniverse C L`, clause 1's formula dimension for both successor shapes, clause 1's label
  dimension per verdict, the composite theorem, the terminus corollary, and the new register entries.
- `specs/432_discharge_universeclosed_residual/plans/01_universeclosed-clause2-verdict-instantiation.md`
  — this file, with per-phase status markers and verdicts recorded inline.
- `specs/432_discharge_universeclosed_residual/summaries/01_universeclosed-clause2-verdict-instantiation-summary.md`
  — landed versus named, at close.
- `specs/432_discharge_universeclosed_residual/.orchestrator-handoff.json` and `.return-meta.json`.

## Rollback/Contingency

Every phase is additive within a single file, and the only phase that edits existing proofs is
Phase 3. If Phase 3's generalization destabilizes the terminus chain, revert that phase's commits
only: Phases 2, 4, 5, 6, and 7 stand alone as new declarations and remain valuable without it, and
the composite in Phase 8 can be restated against `UniverseClosed` directly at the cost of being
vacuous by Phase 2's refutation — which is itself a reportable outcome rather than a failure.

If Phase 2's verdict is (c) — clause 2 neither provable nor refutable within budget — mark the task
`[BLOCKED]`, keep the forward membership lemma from Phase 1, and report the goal state reached. Do
not substitute a weakened `UniverseClosed` to make a proof close; 431's precedent and the task
constraints both forbid it.

If Phase 5's verdict is (c), Phases 6 and 8 can still land the formula dimension and a composite
conditional on clause 1 as a named hypothesis; only Phase 7 stalls.
