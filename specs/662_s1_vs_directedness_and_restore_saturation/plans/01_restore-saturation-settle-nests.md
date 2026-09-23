# Implementation Plan: Restore *Saturation* as `def:frame`'s fourth constraint, and settle nests

- **Task**: 662 - Settle whether plain S1 suffices or directedness is forced, search for a better
  fourth frame constraint, and otherwise restore Saturation as the def:frame constraint in place
  of Completion
- **Status**: [NOT STARTED]
- **Effort**: 15 hours
- **Dependencies**: 661 (completed — supplies both witnesses and the *Completion* results this
  plan re-sites); 659, 657 (completed, upstream of 661)
- **Research Inputs**:
  `specs/662_s1_vs_directedness_and_restore_saturation/reports/01_s1-vs-directedness-restore-saturation.md`
- **Artifacts**: plans/01_restore-saturation-settle-nests.md (this file);
  summaries/01_restore-saturation-settle-nests-summary.md
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: true

## Overview

Research answered all three questions and the answers point one way: *Saturation* stays, in its
`⊇`-directed `S₁ᵈ` form, and *Completion* becomes what it actually is — a **derived** condition
recording exactly how little of the axiom `lem:step` consumes. The Lean tree never stopped being
`Saturation`-based (`FrameOver.IsRegular.saturation` is still the operative field, and
`TaskFrame.Completion` is used at no field or instance site), so the reversal undoes no
mathematics: it is prose, siting, and four new pieces of mathematics that convert the prior
wave's advocacy into a **sharpness result**. Done means: the nest condition `S₁` exists in the
library as a named predicate with `S₁ᵈ → S₁` machine-checked; both existing witnesses are known
to refute `S₁` and not merely `S₁ᵈ`; the exact regime in which `S₁` suffices for `lem:step` is
stated and proved (countable domains, which covers every `ℤ`- and `ℚ`-time history); every
in-tree prose region that presents *Completion* as `def:frame`'s proposed fourth constraint says
instead that it is the derived condition the minimality is recorded at; and `lake build` is
green, sorry-free and warning-free with the full gate set passing.

### Research Integration

The report settles all three questions and measures the reversal surface rather than estimating
it. Six findings shape the phase structure:

- **Question 1 is answered "keep `S₁ᵈ`", on the governing criterion, with the mathematics split.**
  `S₁` provably suffices for `lem:step` wherever the two sides of `z` have matching cofinal
  character — which every duration type this development instantiates satisfies. It does **not**
  suffice in general, and the obstruction is exact (mismatched one-sided cofinal characters, which
  need a non-archimedean `D` of uncountable coinitiality). Adopting `S₁` would therefore either
  push an order-character hypothesis on `D` into `def:frame`'s adequacy — a property of the
  *index*, not of `⟨W, D, ⇒⟩`, and so precisely the aboutness failure the criterion forbids — or
  silently narrow `thm:extension`. `S₁ᵈ` is also a *named* member of the same Ćmiel–Kuhlmann–
  Kuhlmann hierarchy, not a bespoke strengthening, and `lem:constraint` **produces a `⊇`-directed
  family**, so `S₁ᵈ` is the exact shape of what the development hands the axiom.
- **A standing assumption was wrong and the correction is cheap.** Both existing `¬ Saturation`
  witnesses fail **`S₁` as well as `S₁ᵈ`**: their straddle families contain a cofinal nest, and
  both of its sequences (`RationalTwoOrigins.nt` descending to `√2`, `phi` ascending to it) are
  already fully proved in the tree. So neither witness says anything about directedness, and that
  is worth landing as a theorem rather than left as a tempting inference.
- **The `S₁`-sufficiency result must be stated as a property of `Constraints τ z`, never as a
  frame-level `S₁ → Saturation`.** The frame-level implication is false. The true statement is:
  `S₁` plus a cofinal `⊆`-chain inside `Constraints τ z` gives what `step` consumes, and the
  cofinal chain is discharged separately per carrier.
- **Do not route the carrier discharge through `Archimedean D`.** Mathlib has no Hölder embedding
  (`lean_local_search` confirmed: the only `LinearOrderedAddCommGroup.exists…` hit is
  `Subgroup.exists_neg_generator`), so that route costs a theorem before it starts. Use a directly
  stated order property, following the tree's own `NearestAt`/`HasNearest` pattern. This plan uses
  **countability of the history's own domain**, which is automatic for `D = ℤ` and `D = ℚ` and so
  covers both instantiated carriers with no hypothesis on `D` at all.
- **Question 2: nothing better is available.** Saturation is the only candidate with two
  recognized genus memberships carrying transferable theory (ball spaces; BdRV Def. 5.65 /
  Prop. 5.83(v) compactness). Every alternative fails at least one criterion, and `TotalComp`,
  `Triangle` and determinism were already rejected on compiled grounds. One new sharpness fact is
  available and **flagged plausible-not-verified**: segments are load-bearing, i.e. a fibers-only
  `S₁ᵈ` is inadequate, with `SeparatingFrame` very likely the witness.
- **The reversal surface is measured: 15 `.lean` prose regions across 5 files, 3 markdown regions,
  0 ADR sites, 0 manuscript sites, 0 code changes.** `Extension/Completion.lean`'s
  architecture-target block is the canonical site every other advocacy site echoes, so it is
  rewritten first within its phase.

### Prior Plan Reference

No prior plan exists for task 662. Task 661's plan is a **reference only** and is not inherited:
it executed under a settled decision (R4) that this task's governing criterion supersedes. Three
things are carried across from it as calibration, not as content:

- **Effort calibration.** 661 budgeted 8 hours for a comparable mix (one core-module `def`
  triggering a whole-library rebuild, two witness promotions, a hypothesis-weakening refactor,
  prose sweeps, docs, and a source-store context note) and that shape held. This plan is larger
  by the four new mathematical results, hence 15 hours.
- **A validated pattern: hypothesis weakening by primed sibling, never by signature change.**
  661's `completion_of_nearest_at` weakened `completion_of_hasNearest` by splitting out the
  pointwise form and leaving the original as a corollary. Phase 3 reuses that shape exactly.
- **A validated risk.** Adding a `def` to `FormalSystem/Semantics/TaskFrame.lean` triggers a
  whole-library rebuild. 661 budgeted one phase for it and paid it once; Phase 1 does the same.

### Roadmap Alignment

No `roadmap_path` was supplied with this dispatch and no roadmap flag was set; `specs/ROADMAP.md`
was not consulted and is not written to.

### The Governing Criterion, and What It Settles

The dispatch's criterion overrides minimality: a frame constraint must be a property of
`⟨W, D, ⇒⟩` **as such**; tight hypotheses belong in theorems, natural closure conditions belong in
definitions; the test is what a condition is *about*, not what vocabulary it is written in.

Applied, it settles three things this plan does not re-litigate:

1. *Completion* loses. Its hypothesis clause **is** `def:world-history`'s clause verbatim, and
   `completion_iff_onePointExtension` makes it provably equivalent to "the construction
   `thm:extension` performs succeeds" — an axiom in the shape of its own theorem.
2. `S₁ᵈ` is kept over `S₁`. `S₁`'s adequacy is a fact about the *cofinal character of subsets of
   `D`*; `S₁ᵈ`'s is a fact about the ball geometry `⇒` induces. Only the second is about the
   structure.
3. The `Saturation → Completion` results are **not** deleted or weakened. They are the sharpness
   result, and they are re-sited rather than re-argued.

### Three Strength Relations, Only Two Settled

This distinction is the single easiest thing to get wrong in the prose phases, so it is fixed
here and every rewritten docstring is checked against it:

| Relation | Status | Evidence |
|---|---|---|
| *Saturation* → *Completion* | **settled true** | `completion_of_isRegular` |
| *Completion* → *Saturation* | **settled false** | `SeparatingFrame.srel_completion` + `not_srel_saturation` |
| `S₁ᵈ` → `S₁` | **settled true** (this task) | `nestSaturation_of_saturation`, Phase 1 |
| `S₁` → `S₁ᵈ` | **OPEN** | no witness exists; see Non-Goals |

The in-source instruction at `TaskFrame.lean:614-617` — *do not restore "strictly stronger"* in
the ball-space footnote's rendering — survives every rewrite **verbatim**. Nothing this task
lands licenses restoring it; if anything, the `S₁`-sufficiency result weakens the case for
strictness.

## Goals & Non-Goals

**Goals**:

- Give the library the **nest condition `S₁`** as a named bare-relation predicate beside
  *Saturation*, and machine-check the ball-space footnote's asserted implication `S₁ᵈ → S₁`,
  so that the hierarchy the footnote cites is present in the tree rather than only in prose.
- **Correct the standing assumption** that the existing `¬ Saturation` witnesses separate the
  directed form from the nest form: exhibit the cofinal nest inside `SeparatingFrame.straddle`
  and conclude that the separating frame refutes `S₁` outright.
- **State and prove the regime in which `S₁` suffices for `lem:step`**, as a property of
  `Constraints τ z` (a cofinal `⊆`-chain) rather than as a frame-level implication, and discharge
  that property for every history with a countable domain — which is automatic for `ℤ`-time and
  `ℚ`-time.
- **Restore *Saturation* as `def:frame`'s fourth constraint in the tree's own account of itself**:
  no in-tree region may present *Completion* as the proposed, recommended or pending replacement.
  *Completion* is the condition `lem:step` actually consumes, derived immediately before it, and
  the site at which the minimality is recorded.
- Keep every theorem and both witnesses. Nothing is deleted, weakened or re-proved; the
  `Completion` results become a sharpness result about a definition worth keeping.
- Keep the tree green, sorry-free and warning-free at every phase boundary, with the theorem
  index, module READMEs and every invariant gate updated and passing.
- Declarations pinned by `## Lean Challenge Statements`: `TaskFrame.NestSaturation`,
  `TaskFrame.nestSaturation_of_saturation`, `StateTopology.RationalTwoOrigins.phi_sq_lt_two`,
  `StateTopology.RationalTwoOrigins.one_le_phi_add_two`, `StateTopology.SeparatingFrame.nest`,
  `StateTopology.SeparatingFrame.not_srel_nestSaturation`,
  `PartialHistory.fib_subset_fib_of_compositional`,
  `PartialHistory.fib_subset_fib_of_compositional'`,
  `PartialHistory.seg_subset_seg_of_compositional`, `PartialHistory.HasCofinalNest`,
  `PartialHistory.sInter_constraints_nonempty_of_nestSaturation`,
  `PartialHistory.hasCofinalNest_of_countable`,
  `PartialHistory.sInter_constraints_nonempty_of_countable`.

**Non-Goals**:

- **The `S₁`-vs-`S₁ᵈ` separating frame.** It needs a Hahn group `⊕_{α<ω₁} ℝ` as duration type,
  a bespoke `W` and `⇒`, and `S₁` verified against *all* nests of fibers and segments, with
  Mathlib supplying neither spherical completeness nor the ordered-group machinery. This is a
  research-scale construction and an **explicit non-goal** (research D2). Phase 1 records the
  construction recipe in the `Saturation` docstring so it is recoverable, and records that
  `S₁ → S₁ᵈ` therefore stays **open**. No `sorry` and no placeholder stands in for it.
- **Formalizing the `ω × ω₁` no-cofinal-chain argument.** It is the negative half of Question 1
  and no deliverable depends on it. It is recorded as prose — the *reason* directedness is not
  provably redundant — and is not pulled into Lean.
- **Any manuscript edit.** The task description says so outright, and `def:frame` is a pinned
  anchor with a recorded checksum. Nothing may touch a `verbatim:` block or a `sha256:` line.
  The manuscript still says *Saturation*, so this task's outcome re-aligns tree and paper without
  touching the paper; Phase 10 proves it did not by running `check-paper-definitions.sh`.
- **Any `FrameOver.IsRegular` field change.** The field is already `saturation` and stays
  `saturation`. No field swap, no `completion` field, no new `nestSaturation` field, and no
  changes at the five transport sites (`FrameOver.rev_isRegular`, `FrameOver.map`,
  `FrameOver.translationProduct`, `regionFrame_saturation`, `zTaskFrameV2_saturation`).
- **Deleting, weakening or re-proving any *Completion* result.** `TaskFrame.Completion`,
  `completion_of_isRegular`, `extension_of_completion`, `completion_iff_onePointExtension`,
  `completion_of_hasNearest` and both witnesses all stay exactly as they are. Only their framing
  moves.
- **Restoring "strictly stronger" in the ball-space footnote's in-tree rendering** (research D7).
- **Re-exploring recorded dead ends**: no finitary or two-point form of *Completion*, no
  dense-time drift separator, and no re-assessment of `TotalComp`, `Triangle`, determinism, or
  compactness of the induced state topology. All are closed with recorded reasons.
- **An `Archimedean D` or Hölder-embedding route** to the carrier discharge (research D3).
- **A new module.** All new declarations are sited in existing files; see the Phase 4 risk row
  for the one pre-authorised exception and its trigger.

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| `IsChain` is not in scope in `TaskFrame.lean` (it imports `Mathlib.Order.Minimal` and `Mathlib.Data.Set.Lattice`, not `Mathlib.Order.Preorder.Chain` directly) | L | M | Confirmed hypothesis, not assumption: if elaboration fails, add `import Mathlib.Order.Preorder.Chain` at the top of `TaskFrame.lean`. `IsChain (· ⊆ ·)` is already used elsewhere in the tree (`Metalogic/Core/MaximalConsistent.lean`, `RestrictedMCS/Basic.lean`), so the spelling is the tree's own and needs no invention |
| The prose reversal asserts more than is settled, e.g. that `S₁ᵈ` is strictly stronger than `S₁` | **H** | M | The four-row strength table above is the checklist. Phase 10 greps the whole tree for the phrase pattern `strictly stronger` within 5 lines of a `NestSaturation`/`S₁` mention, and for any surviving occurrence of "proposed"/"recommended"/"replacement" within a *Completion* docstring. The in-source instruction at `TaskFrame.lean:614-617` is copied forward verbatim, not paraphrased |
| The prose reversal over-corrects and deletes a true, machine-checked framing | M | M | Two framings are **kept**, not reversed: *Completion* is what `step` actually consumes, and `Completion → Saturation` is false. What changes is the modal register only — "proposed fourth constraint" becomes "derived condition", "recommended in place of" becomes "records the minimality", "could have been assumed instead" becomes "is the exact strength the axiom is spent at". Each rewritten region is diffed against this rule before commit |
| `phi n ^ 2 < 2` does not fall out of the existing invariants | M | L | Worked through during planning and it does: with `e = (1/2)^n` and `x = nt n`, `nt_err` gives `x² - 2 ≤ e/4` and `nt_one_le` gives `x ≥ 1`, so `(x-e)² - 2 ≤ e(1/4 - 2x + e) ≤ -3e/4 < 0`. `nlinarith` with `nt_err n`, `nt_one_le n` and `pow_le_one` bounds on `e` is the expected discharge; `nlinarith` hint list is pre-computed in Phase 2's tasks |
| `1 ≤ phi n` is false at `n = 0, 1` (`phi 0 = 1/2`, `phi 1 = 11/12`), silently breaking `straddle` membership | M | **H** | This is exactly why the nest is indexed `phi (n + 2)`, not `phi n`. `phi 2 = 475/408 > 1` by `norm_num [phi, nt]` and `phi_mono` lifts it to all `n + 2`. The `1 ≤ a` conjunct of `straddle` is load-bearing and the file's own comment at `ConstraintWitnesses.lean:1097-1101` already warns that it is easy to lose |
| `hasCofinalNest_of_countable` is larger than budgeted: four regimes (domain below only, above only, straddling, and the `A`-has-max / `B`-has-min degenerate cases) | M | M | The regimes are not four independent proofs. `IsPaired`'s own docstring records the global collapse — a domain straddling `z` gives segments only, a one-sided domain gives fibers only — so there are exactly **two** regimes, and the one-sided one is a chain already by monotonicity with no construction at all. Only the straddling regime needs the diagonal. If the phase overruns, split at that boundary: the one-sided regime lands first as `hasCofinalNest_of_one_sided` and the straddling regime follows |
| The three monotonicity lemmas are `[F.IsRegular]`-bound, so any proof using them drags *Saturation* back in and makes the `S₁`-sufficiency result vacuous | **H** | **H** (certain, unless mitigated) | This is the central honesty hazard of Phases 3–5 and Phase 3 exists solely to close it. `fib_subset_fib_of_le_of_le`, `fib_subset_fib_of_le_of_le'` and `seg_subset_seg` consume `F.forward_comp` and `F.reflection` only — `Compositional F.TaskRel` plus a `FrameOver` field, never `F.saturation`. Phase 3 restates each with an explicit `hcomp` hypothesis and keeps the old name as a one-line corollary, so no call site changes. **No theorem downstream of Phase 3 may carry `[F.IsRegular]`** |
| Adding a `def` to `TaskFrame.lean` triggers a whole-library rebuild | M | **H** | Expected and accepted, not avoided: the bare-relation axiom section's docstring claims all the frame axioms live there, and siting `NestSaturation` elsewhere would falsify it. Phase 1 is budgeted for the rebuild and does nothing else, so the cost is paid once |
| `Extension/Completion.lean` (543 lines) crosses the 1500-line `longFile` limit once Phases 4, 5 and 6 land | L | L | Measured hypothesis, confirmed in Phase 5. Headroom is ~950 lines against an expected ~250. If crossed, the pre-authorised response is an in-source `set_option linter.style.longFile N` baseline after the module docstring, exactly as `StateTopology/Counterexamples.lean` does — the sanctioned form under invariant C30. A new sibling module is the fallback only if the baseline is refused |
| `ConstraintWitnesses.lean` (1372 lines) crosses the same limit in Phases 2 and 8 | M | **H** | Same mitigation, and the exposure is higher because the file is already close. If an in-source baseline is already present, raise it; do **not** split the module — `docs/ARCHITECTURE.md` records that nothing under `FormalSystem/` imports these modules, and a new sibling importing `ConstraintWitnesses` would falsify that |
| The fibers-only sharpness claim (Phase 8) does not verify | L | M | Explicitly flagged plausible-not-verified by the research. Planning checked the two feared cases and both resolve (a singleton fiber forces the whole directed family through it; widths `≥ 2` force `inf right ≥ sup left + 2`, and a real interval of length `≥ 2` contains a rational), but the argument needs `ℝ`-valued `sSup`/`sInf` over an arbitrary family and may cost more than budgeted. Phase 8 is the **last** substantive phase, depends on nothing, and is pre-authorised to close `[COMPLETED WITH EXCLUSIONS]` with a `#### Reasoned Exclusions` record. No other phase depends on it |
| A new theorem-index row fails invariant C15 | L | M | C15 requires the named declaration's own `/--` doc comment to carry a `Paper:` line whose value is the row's anchor, or `—` plus a one-clause reason. Every phase that introduces a declaration writes its `Paper:` line **in the same sub-step as the declaration**, so Phase 9 adds rows to already-compliant declarations rather than retrofitting doc comments |
| `unusedSectionVars` or `autoImplicit` fires on the new `TaskFrame.NestSaturation` | L | L | `Saturation` sits in the same variable block and is clean, and `NestSaturation` has the same signature shape. If the linter does fire, scope an `omit` exactly as the neighbouring `Fib`/`Seg` lemmas do — never a blanket `set_option`, which invariant C30 forbids |

## Implementation Phases

**Dependency Analysis**:

| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1, 3 | -- |
| 2 | 2, 4 | 1, 3 |
| 3 | 5, 7 | 1, 2, 4 |
| 4 | 6, 8 | 2, 5, 7 |
| 5 | 9 | 6, 8 |
| 6 | 10 | 9 |

Phases within the same wave can execute in parallel. The waves are also **file-disjoint by
construction**, which is why they are parallel-safe: wave 1 touches `TaskFrame.lean` and
`Extension/Constraint.lean`; wave 2 touches `ConstraintWitnesses.lean` and
`Extension/Completion.lean`; wave 3 touches `Extension/Completion.lean` and
(`TaskFrame.lean` + `ConstraintWitnesses.lean`); wave 4 touches
(`Extension/Completion.lean` + `Step.lean` + `Extension.lean`) and `ConstraintWitnesses.lean`.
Phases 2 and 7 both touch `ConstraintWitnesses.lean` but sit in different waves, as do 5, 6 and
`Extension/Completion.lean`.

---

### Phase 1: The nest condition `S₁` in the library [NOT STARTED]

**Goal**: Make the ball-space hierarchy the footnote cites present in the tree rather than only
in prose: `S₁` as a named bare-relation predicate beside *Saturation*, with the footnote's
asserted implication `S₁ᵈ → S₁` machine-checked, and with the `S₁`-vs-`S₁ᵈ` question recorded as
**open** together with the recipe for the witness that would close it.

**Tasks**:

- [ ] In `FormalSystem/Semantics/TaskFrame.lean`, inside the `## The frame axioms in
      bare-relation form` section and immediately after `Saturation`, add
      `def NestSaturation {W : Type} (R : W → D → W → Prop) : Prop` quantifying over
      `S : Set (Set W)` with `S.Nonempty`, `IsChain (· ⊆ ·) S`, and the same member condition
      `Saturation` uses (`(IsFiber R s ∨ IsSegment R s) ∧ s.Nonempty`), concluding
      `(⋂₀ S).Nonempty`. The member condition must be **character-for-character** the one in
      `Saturation`, so the two differ in exactly one clause.
- [ ] If `IsChain` does not elaborate, add `import Mathlib.Order.Preorder.Chain` and nothing else.
- [ ] Give `NestSaturation` a docstring recording: (a) that this is `S₁`, the standard *spherical
      completeness* condition of the Ćmiel–Kuhlmann–Kuhlmann ball-space hierarchy, over the ball
      space of nonempty fibers and segments; (b) that it differs from `Saturation` in exactly one
      clause — a nest in place of a `⊇`-directed family — and that the nest restriction is a
      condition on **how the family is indexed**, not on the geometry; (c) a `Paper:` line citing
      `def:frame#Saturation`'s ball-space footnote (C15).
- [ ] Add `theorem nestSaturation_of_saturation {W : Type} {R : W → D → W → Prop}
      (h : Saturation R) : NestSaturation R`, proved by showing a nonempty chain is a
      `DirectedFamily`: `S.Nonempty` is the hypothesis, and for `S₁ S₂ ∈ S` the chain gives
      `S₁ ⊆ S₂` or `S₂ ⊆ S₁` (with the `S₁ = S₂` case handled by `eq_or_ne`), so the smaller of
      the two is itself the required refinement. Docstring records that this is the footnote's
      asserted implication, now machine-checked.
- [ ] Extend the `Saturation` docstring's ball-space paragraph — **without altering the existing
      "do not restore *strictly stronger*" instruction, which is copied forward verbatim** — to
      record: (i) that `S₁` is now present as `NestSaturation` and `S₁ᵈ → S₁` is machine-checked;
      (ii) that the converse `S₁ → S₁ᵈ` is **open**, and that neither existing witness bears on
      it (forward reference to `not_srel_nestSaturation`, Phase 2); (iii) **why the directedness
      is kept although it is not forced over any instantiated carrier**: `lem:constraint` produces
      a `⊇`-directed family, and the segments straddling `z` are indexed by a *pair* `(t, s)`
      directed by `(max t, min s)` — a genuinely two-dimensional index, confirmed machine-checked
      at `Extension/Constraint.lean`'s `exists_mem_subset_inter` — so `S₁ᵈ` is the exact algebraic
      shadow of a history constraining a moment from both sides at once; (iv) that a separating
      frame would need a duration type with **mismatched one-sided cofinal characters**, hence a
      non-archimedean `D` of uncountable coinitiality (a Hahn group `⊕_{α<ω₁} ℝ`, with
      `A = {z - eₙ : n < ω}` and `B = {z + e_α : α < ω₁}` giving an index `≅ ω × ω₁`, which has no
      cofinal chain), and that this is an explicit **non-goal** recorded so the recipe is
      recoverable, not a deferral.
- [ ] `lake build` green, sorry-free, warning-free; `#print axioms
      FormalSystem.Semantics.TaskFrame.nestSaturation_of_saturation` reports exactly `propext`,
      `Classical.choice`, `Quot.sound`. Commit.

**Timing**: 1.5 hours (most of it the whole-library rebuild).

**Depends on**: none

**Verification Tier**: full

**Files to modify**:
- `FormalSystem/Semantics/TaskFrame.lean` — `NestSaturation`, `nestSaturation_of_saturation`,
  extended `Saturation` docstring, possibly one new Mathlib import

**Verification**:
- `lake build` exits 0 with zero `error:` and zero `warning:` lines.
- The module is silent under
  `lake env lean -D weak.linter.mathlibStandardSet=true -D autoImplicit=false`.
- `grep -c 'strictly stronger' FormalSystem/Semantics/TaskFrame.lean` is unchanged from its
  pre-phase value, and the "Do not restore" sentence is byte-identical.

---

### Phase 2: Both existing witnesses refute `S₁`, not merely `S₁ᵈ` [NOT STARTED]

**Goal**: Correct the standing assumption that `SeparatingFrame` separates the directed form from
the nest form. Exhibit the cofinal nest inside `straddle` and conclude
`¬ TaskFrame.NestSaturation srel`, which sharpens the existing separation from "satisfies
*Completion*, fails `S₁ᵈ`" to "satisfies *Completion*, fails `S₁`".

**Tasks**:

- [ ] In `FormalSystem/Semantics/StateTopology/ConstraintWitnesses.lean`, in the
      `RationalTwoOrigins` namespace beside the existing `phi` lemmas, add
      `theorem phi_sq_lt_two (n : ℕ) : phi n ^ 2 < 2`. Expected discharge: `nlinarith` with
      `nt_err n`, `nt_one_le n`, `pow_pos` and `pow_le_one` bounds on `(1/2 : ℚ)^n`. The algebra,
      pre-computed: with `e = (1/2)^n` and `x = nt n`, `x² - 2 ≤ e/4` and `x ≥ 1` and `e ≤ 1` give
      `(x - e)² - 2 ≤ e(1/4 - 2x + e) ≤ -3e/4 < 0`.
- [ ] Add `theorem one_le_phi_add_two (n : ℕ) : 1 ≤ phi (n + 2)`, from `phi_mono (le_add_self)`
      and `phi 2 = 475/408 ≥ 1` by `norm_num [phi, nt]`. Record in a one-line comment **why the
      index is shifted by two** — `phi 0 = 1/2` and `phi 1 = 11/12` both fail `straddle`'s
      load-bearing `1 ≤ a` conjunct, the same trap the file's existing comment at the `straddle`
      definition already warns about.
- [ ] In the `SeparatingFrame` namespace, add
      `def nest : Set (Set ℚ) := {s | ∃ n : ℕ, s = Seg srel (RationalTwoOrigins.nt n - 1)
      (RationalTwoOrigins.phi (n + 2) + 1) 1 1}` — i.e. the intervals
      `[phi (n+2), nt n]` in the `mem_sseg` realisation. Cross-namespace reference to
      `RationalTwoOrigins` is the file's own established idiom (`not_srel_saturation` already
      cites `RationalTwoOrigins.sq_ne_two`).
- [ ] Add `theorem not_srel_nestSaturation : ¬ TaskFrame.NestSaturation srel`, assembling:
      (a) `nest.Nonempty` — witness `n = 0`; (b) `IsChain (· ⊆ ·) nest` — for `m ≤ n`,
      `phi (m+2) ≤ phi (n+2)` by `phi_mono` and `nt n ≤ nt m` by `nt_antitone`, then `mem_sseg`
      on both sides with the width bound `nt n - phi (n+2) ≤ 2` from `nt_le_start` and
      `one_le_phi_add_two`; (c) members are segments and nonempty — `IsSegment` by the same
      `⟨b-1, a+1, 1, 1, _, _, rfl⟩` shape `not_srel_saturation` uses, nonemptiness from
      `lt_of_straddle` applied to `phi_sq_lt_two` and `nt_sq_gt`; (d) the intersection is empty —
      any `q` in every member satisfies `phi (n+2) ≤ q ≤ nt n` for all `n`, so `q² ≤ 2` and
      `q² ≥ 2` by two `exists_pow_lt_of_lt_one` squeezes (the same lemma the file already uses at
      `not_rel_completion`), hence `q² = 2`, refuted by `sq_ne_two`.
- [ ] Docstring on `not_srel_nestSaturation` records the correction explicitly: the separating
      frame satisfies *Seriality*, *Compositionality*, *Limit* and *Completion* and fails **`S₁`**,
      so the existing sharpness result is about the nest condition and **says nothing about
      directedness**. Add the `Paper:` line (`def:frame#Saturation`) for C15.
- [ ] Attempt the `RationalTwoOrigins` analogue `¬ TaskFrame.NestSaturation rel` opportunistically
      — the same `nt`/`phi` sequences live in that namespace and `straddleFamily`'s endpoints are
      `{t : ℚ // 0 < t}`, so no `1 ≤ a` guard is needed. **It is not a committed deliverable**: if
      it does not fall out within 20 minutes, stop and record one line in the module docstring
      saying the `SeparatingFrame` result already establishes the correction.
- [ ] Confirm the `longFile` hypothesis below; apply the pre-authorised in-source baseline if
      crossed. `lake build` green, sorry-free, warning-free; `#print axioms` clean on the three new
      declarations. Commit.

**Timing**: 2 hours

**Depends on**: 1

**Verification Tier**: local

**Scope Hypothesis**: this phase asserts (a) that it adds **4 committed declarations**
(`phi_sq_lt_two`, `one_le_phi_add_two`, `nest`, `not_srel_nestSaturation`) plus at most one
opportunistic fifth, and (b) that `ConstraintWitnesses.lean`, currently **1372 lines**, stays
under the 1500-line `longFile` limit after them. Confirm (a) by `grep -c` on the four names after
the edit; confirm (b) by `wc -l` on the file before commit, and apply the in-source
`set_option linter.style.longFile N` baseline (invariant C30's sanctioned form) if it is crossed.
Both are hypotheses, not facts.

**Files to modify**:
- `FormalSystem/Semantics/StateTopology/ConstraintWitnesses.lean` — the four new declarations,
  the corrected module-docstring sentence, and any `longFile` baseline

**Verification**:
- `lake build` exits 0, zero warnings, and the module is silent under the package linter set.
- `#print axioms FormalSystem.Semantics.StateTopology.SeparatingFrame.not_srel_nestSaturation`
  reports exactly `propext`, `Classical.choice`, `Quot.sound`.
- `grep -rn 'sorry' FormalSystem/Semantics/StateTopology/ConstraintWitnesses.lean` returns
  nothing.

---

### Phase 3: Weaken the three monotonicity lemmas off `[F.IsRegular]` [NOT STARTED]

**Goal**: Close the central honesty hazard before it can contaminate Phases 4 and 5. The fiber and
segment monotonicity lemmas consume *Compositionality* and the `FrameOver` reflection field and
nothing else, but they are stated at `[F.IsRegular]`, which carries `saturation`. Any
`S₁`-sufficiency result proved through them would be vacuous. Restate each with an explicit
hypothesis and keep the existing names as corollaries, so no call site changes.

**Tasks**:

- [ ] In `FormalSystem/Semantics/Extension/Constraint.lean`, add
      `theorem fib_subset_fib_of_compositional {τ : PartialHistory F} {z a b : F.Duration}
      (hcomp : TaskFrame.Compositional F.TaskRel) (ha : τ.domain a) (hb : τ.domain b)
      (hab : a ≤ b) (hbz : b ≤ z) : Fib F.TaskRel (τ.states b hb) (z - b) ⊆
      Fib F.TaskRel (τ.states a ha) (z - a)`, transcribing the existing proof with
      `F.forward_comp` replaced by the composition half projected out of `hcomp`.
- [ ] Add the mirror `fib_subset_fib_of_compositional'` the same way (its extra ingredient,
      `F.reflection`, is a `FrameOver` field and needs no instance).
- [ ] Add `seg_subset_seg_of_compositional`, transcribing `seg_subset_seg` over the two new fiber
      lemmas.
- [ ] Rewrite `fib_subset_fib_of_le_of_le`, `fib_subset_fib_of_le_of_le'` and `seg_subset_seg` as
      **one-line corollaries** applying the new lemmas to `F.comp`. Their names, statements and
      implicit-argument order must be unchanged — that is what makes this phase a hypothesis
      weakening rather than an interface change, and it is verified by every downstream call site
      still compiling untouched.
- [ ] Record in each new docstring that the hypothesis actually consumed is *Compositionality*
      alone, that the split exists so the `S₁`-sufficiency results can be stated without
      `[F.IsRegular]` (forward reference to Phase 5), and the `Paper:` line each inherits from its
      corollary.
- [ ] `lake build` green, sorry-free, warning-free. Commit.

**Timing**: 1 hour

**Depends on**: none

**Verification Tier**: interface

**Scope Hypothesis**: this phase asserts that the three renamed lemmas have **no call sites
outside `Extension/Constraint.lean` that need editing**, because the old names survive as
corollaries with identical signatures. Confirm at implementation time with
`grep -rn 'fib_subset_fib_of_le_of_le\|seg_subset_seg' FormalSystem/ --include=*.lean` before and
after: the occurrence set must be identical except for the new declarations themselves, and a
full `lake build` must pass with no edit to any consuming module.

**Files to modify**:
- `FormalSystem/Semantics/Extension/Constraint.lean` — three new `_of_compositional` lemmas, three
  existing lemmas demoted to corollaries

**Verification**:
- `lake build` exits 0, zero warnings; every module importing `Constraint.lean` compiles with no
  edit.
- `grep -n 'IsRegular' FormalSystem/Semantics/Extension/Constraint.lean` shows the instance binder
  only on the corollaries and the untouched declarations, never on the three new ones.

---

### Phase 4: `HasCofinalNest` and the reduction of `lem:step` to `S₁` [NOT STARTED]

**Goal**: State the `S₁`-sufficiency result the only way it is true — as a property of
`Constraints τ z`, never as a frame-level `S₁ → Saturation`, which is false — and prove the
reduction: `S₁` plus a cofinal `⊆`-chain inside the constraints plus nonempty members gives
exactly what `step` consumes.

**Tasks**:

- [ ] In `FormalSystem/Semantics/Extension/Completion.lean`, open a new section
      `## The nest condition and `lem:step`` after the existing *Completion* material, and add
      `def HasCofinalNest (τ : PartialHistory F) (z : F.Duration) : Prop` saying: there is
      `C ⊆ Constraints τ z` with `C.Nonempty`, `IsChain (· ⊆ ·) C`, and
      `∀ c ∈ Constraints τ z, ∃ c' ∈ C, c' ⊆ c`.
- [ ] Docstring records: this is the exact indexing property that makes the nest form as strong as
      the directed form **at one history and one target**; it is a property of the constraint
      family, not of the frame; and `nonempty_Constraints` (which needs no frame constraint at all,
      only `τ.nonempty_domain`) is why demanding `C.Nonempty` costs nothing.
- [ ] Add `theorem sInter_constraints_nonempty_of_nestSaturation
      (hS1 : TaskFrame.NestSaturation F.TaskRel) (τ : PartialHistory F) (z : F.Duration)
      (hne : ∀ c ∈ Constraints τ z, c.Nonempty) (hcof : HasCofinalNest τ z) :
      (⋂₀ Constraints τ z).Nonempty`. Proof: apply `hS1` to `C` (members are fibers or segments by
      `isFiber_or_isSegment_of_mem_Constraints` through `C ⊆ Constraints τ z`, and nonempty by
      `hne`), obtain `u ∈ ⋂₀ C`, then for arbitrary `c ∈ Constraints τ z` take the cofinal
      `c' ∈ C` with `c' ⊆ c` and conclude `u ∈ c`.
- [ ] **No `[F.IsRegular]` binder on this theorem or anything below it in this section.** The
      nonemptiness hypothesis is explicit precisely so that the caller supplies it from
      *Seriality* + *Compositionality* + *Limit* (what `constraint` actually uses) rather than
      from the instance.
- [ ] Docstring on the reduction records the shape rule as a standing instruction: **never state a
      frame-level `S₁ → Saturation`** — the general implication is false, because an uncountable
      directed family of balls need not reduce to a nest — and cite the correct statement shape
      for any future extension.
- [ ] Add the `Paper:` line on both declarations (`—` plus a one-clause reason: the manuscript has
      no anchor for the nest reduction, exactly as `NearestAt` in the same file is handled).
- [ ] `lake build` green, sorry-free, warning-free. Commit.

**Timing**: 1 hour

**Depends on**: 1, 3

**Verification Tier**: local

**Files to modify**:
- `FormalSystem/Semantics/Extension/Completion.lean` — new section with `HasCofinalNest` and
  `sInter_constraints_nonempty_of_nestSaturation`

**Verification**:
- `lake build` exits 0, zero warnings; module silent under the package linter set.
- `#print axioms
  FormalSystem.Semantics.PartialHistory.sInter_constraints_nonempty_of_nestSaturation` reports
  exactly `propext`, `Classical.choice`, `Quot.sound`, and the printed statement contains no
  `IsRegular`.

---

### Phase 5: `S₁` suffices over every countable domain — hence over `ℤ`- and `ℚ`-time [NOT STARTED]

**Goal**: Discharge `HasCofinalNest` from a directly stated order property, following the tree's
own `NearestAt`/`HasNearest` pattern and **not** routing through `Archimedean D` (Mathlib has no
Hölder embedding). The property chosen is countability of the history's own domain, which is
automatic for `D = ℤ` and `D = ℚ` and therefore covers both instantiated carriers with no
hypothesis on `D` at all.

**Tasks**:

- [ ] Add `theorem hasCofinalNest_of_countable (hcomp : TaskFrame.Compositional F.TaskRel)
      (τ : PartialHistory F) (z : F.Duration) (hcount : {t : F.Duration | τ.domain t}.Countable) :
      HasCofinalNest τ z`, using **only** the Phase 3 `_of_compositional` monotonicity lemmas.
- [ ] Split on `IsPaired`'s recorded global collapse rather than on four ad hoc cases. There are
      exactly two regimes, and the docstring must say so:
      - **One-sided domain** (no `t ∈ X` is paired): `Constraints τ z` is fibers only, and
        `fib_subset_fib_of_compositional` (below `z`) or its primed mirror (above `z`) makes the
        whole family a chain. Take `C = Constraints τ z`; cofinality is `c' = c`. No construction,
        no countability.
      - **Straddling domain** (every `t ∈ X` is paired): `Constraints τ z` is segments only,
        indexed by `A × Bᵒᵖ` with `A = X ∩ (-∞, z)` and `B = X ∩ (z, ∞)`. Use `hcount` to get
        `a : ℕ → D` and `b : ℕ → D` enumerating `A` and `B`, define the running extrema
        `a' n = max_{i ≤ n} a i` and `b' n = min_{i ≤ n} b i` (both in the domain, since each is
        one of the enumerated values), and take `C = {Seg … (a' n) (b' n) | n : ℕ}`. Chain-ness is
        `seg_subset_seg_of_compositional` against `a'` monotone and `b'` antitone; cofinality is:
        given `(t, s)`, pick `n` past both indices.
- [ ] Docstring records **why this is the right hypothesis shape**: it is a property of the
      history's domain, stated directly, in the idiom of `NearestAt`; it is *not* a property of
      `D` smuggled into the frame; and it deliberately avoids `Archimedean D`, which Mathlib
      cannot discharge without a Hölder embedding it does not have.
- [ ] Add `theorem sInter_constraints_nonempty_of_countable
      (hS1 : TaskFrame.NestSaturation F.TaskRel) (hcomp : TaskFrame.Compositional F.TaskRel)
      (τ : PartialHistory F) (z : F.Duration) (hne : ∀ c ∈ Constraints τ z, c.Nonempty)
      (hcount : {t : F.Duration | τ.domain t}.Countable) : (⋂₀ Constraints τ z).Nonempty`, the
      composition of Phase 4's reduction with the discharge. This is the headline: **over any
      history with countably many times, `S₁` buys exactly what `S₁ᵈ` buys at `lem:step`.**
- [ ] Add two `example`s as acceptance tests — not pinned theorems — recording that a subset of
      `ℤ` and a subset of `ℚ` are automatically countable, so the hypothesis is free at both
      instantiated carriers. Keep them in the tree's existing `example` idiom (`TaskFrame.lean`'s
      field-invariant examples are the model).
- [ ] Docstring records the **boundary of the result**, in the register the strength table fixes:
      `ℝ`-time histories may have uncountable domains, and the `ℝ` case needs a separate
      order-separability argument that is **not** attempted here; a genuine failure of
      `HasCofinalNest` needs mismatched one-sided cofinal characters, hence a non-archimedean `D`
      of uncountable coinitiality, which is this task's recorded non-goal. Do **not** write this
      as settling `S₁ → S₁ᵈ`.
- [ ] Confirm the `longFile` hypothesis below. `lake build` green, sorry-free, warning-free;
      `#print axioms` clean. Commit.

**Timing**: 2 hours

**Depends on**: 4

**Verification Tier**: local

**Scope Hypothesis**: this phase asserts (a) that the discharge has exactly **two** regimes, not
four, on the strength of `IsPaired`'s recorded global collapse, and (b) that
`Extension/Completion.lean` — **543 lines** before Phase 4 — stays under the 1500-line `longFile`
limit after Phases 4, 5 and 6 (expected growth ~250 lines, headroom ~950). Confirm (a) by the
proof's own case structure at implementation time: if a third regime appears, the collapse claim
is wrong and the docstring must be corrected rather than the case added silently. Confirm (b) by
`wc -l` before commit.

**Files to modify**:
- `FormalSystem/Semantics/Extension/Completion.lean` — `hasCofinalNest_of_countable`,
  `sInter_constraints_nonempty_of_countable`, the two `example` acceptance tests

**Verification**:
- `lake build` exits 0, zero warnings; module silent under the package linter set.
- `#print axioms FormalSystem.Semantics.PartialHistory.sInter_constraints_nonempty_of_countable`
  reports exactly `propext`, `Classical.choice`, `Quot.sound`, and the printed statement contains
  no `IsRegular` and no `Saturation`.
- `grep -n 'Archimedean' FormalSystem/Semantics/Extension/Completion.lean` returns nothing new.

---

### Phase 6: Prose reversal in the extension chain [NOT STARTED]

**Goal**: Stop the extension chain's own account of itself from presenting *Completion* as
`def:frame`'s proposed fourth constraint. *Completion* is the derived condition `lem:step`
consumes and the site where the minimality is recorded; *Saturation* is the constraint. The
canonical site is rewritten **first**, because every other advocacy region echoes it.

**Tasks**:

- [ ] **First**, rewrite `Extension/Completion.lean`'s architecture-target block (the "Two things
      this module deliberately does not do" block, currently naming a pending manuscript pass and
      a pending `IsRegular` field swap). Replace it with the settled architecture: `def:frame`
      carries *Saturation*; `completion_of_isRegular` **derives** *Completion* in the bare form
      immediately before `lem:step`; `extension_of_completion` takes *Completion* as an explicit
      hypothesis — and already elaborates with **no `[F.IsRegular]` instance binder**, which is
      the machine-checked form of exactly that claim; and the manuscript already says *Saturation*,
      so no manuscript pass is pending. Nothing is "until those two land" any more.
- [ ] Rewrite the "**The primitives-level reading favours the bare `TaskFrame.Completion` clause
      as `def:frame`'s fourth constraint**" block. It must become the **sharpness** statement: the
      bare clause is available at the primitives level, which is what makes the comparison
      meaningful; and the comparison's verdict, under the governing criterion, is that *Completion*
      loses — its hypothesis clause **is** `def:world-history`'s clause verbatim, so stating it
      `Fib`-free removes the word and not the aboutness, and
      `completion_iff_onePointExtension` makes it provably equivalent, under *Seriality* and
      *Limit*, to "the construction `thm:extension` performs succeeds", i.e. an axiom in the shape
      of its own theorem. Add: *Saturation* looks backward instead, to `def:task-relation`, and
      `Fib`/`Seg` are the relation repackaged as subsets, not new constructions.
- [ ] Rewrite the module docstring regions that site *Completion* at `def:frame`'s level, and the
      `CoherentCompletion` docstring's "the audit's recommendation is that it should be".
- [ ] Rewrite the two later regions ("*Completion* witness in place of the *Saturation* witness";
      "`thm:extension` in full, with *Saturation* replaced by *Completion*") into the derived
      register.
- [ ] Add a **remark region** recording that *Saturation* is strictly stronger than *Completion*,
      citing `SeparatingFrame.srel_completion` + `not_srel_saturation` as the witness, with the
      ball-space footnote attached there — the dispatch's target architecture, and the one place
      the "strictly stronger" phrase is **correct** (it is about *Saturation* vs *Completion*,
      never about `S₁ᵈ` vs `S₁`).
- [ ] Rewrite `Extension/Step.lean`'s two regions. Keep "What `step` actually consumes:
      *Completion*" — it is true and machine-checked. Change only the closing register: "the only
      thing `def:frame`'s *Saturation* buys the development, it buys through a strictly weaker
      condition that **could have been assumed instead**" becomes a statement that the measurement
      records **the exact strength the axiom is spent at**, with the minimality recorded in
      `thm:extension`'s hypothesis rather than migrated into `def:frame`.
- [ ] Rewrite `Extension/Extension.lean`'s "*Completion* may stand in for *Saturation*" region to
      the same register.
- [ ] Cross-check every rewritten region against the four-row strength table in this plan's
      Overview. `lake build` green (docstring edits can break elaboration if a hunk escapes a
      comment boundary — this is exactly the `prose` tier's named blind spot, so the build is run
      regardless). Commit.

**Timing**: 1.5 hours

**Depends on**: 2, 5

**Verification Tier**: prose

**Scope Hypothesis**: the research measured **9 prose regions across these three files**
(`Extension/Completion.lean`: `:14-19`, `:26-30`, `:104-110`, `:112-125`, `:164-170`, `:213-215`,
`:271`; `Extension/Step.lean`: `:58-63`, `:68-75`; `Extension/Extension.lean`: `:241-243`) — line
numbers as of the research dispatch and therefore stale the moment Phases 4 and 5 land. Confirm
by content, never by line number: `grep -n 'proposed\|recommend\|replacement\|stand in for'` over
the three files must return an empty advocacy set afterwards. If the grep finds regions the
research did not enumerate, the count was an undercount — fix them and record the correction in
the phase notes.

**Files to modify**:
- `FormalSystem/Semantics/Extension/Completion.lean` — module docstring, the two advocacy blocks,
  `CoherentCompletion`'s docstring, the two later regions, and the new strictness remark
- `FormalSystem/Semantics/Extension/Step.lean` — the two relative-strength regions
- `FormalSystem/Semantics/Extension/Extension.lean` — the stand-in region

**Verification**:
- Diff read-through confirms every changed hunk lies inside a `/-!`, `/--` or `--` region.
- `lake build` exits 0 with zero warnings (the prose tier's blind spot, closed explicitly).
- `grep -rn 'proposed fourth constraint\|recommended as .def:frame\|proposed replacement'
  FormalSystem/Semantics/Extension/` returns nothing.

---

### Phase 7: Prose reversal in `TaskFrame.lean` and `ConstraintWitnesses.lean` [NOT STARTED]

**Goal**: Finish the reversal at the two remaining `.lean` files: the constraint's own home and
the witnesses' home. After this phase no in-tree `.lean` region presents *Completion* as
`def:frame`'s proposed, recommended or pending fourth constraint.

**Tasks**:

- [ ] `FormalSystem/Semantics/TaskFrame.lean`, four regions: the linter comment naming
      "`TaskFrame.Completion`, the proposed fourth constraint"; the bare-relation section docstring
      ("`Completion`, the **proposed replacement** for the fourth of them"); `def Completion`'s
      opening ("`def:frame`'s **proposed** fourth constraint"); and the strongest advocacy in the
      tree ("the weakest of the two that `thm:extension` can be run from … the clause
      **recommended** as `def:frame`'s fourth constraint in place of *Saturation*") plus its
      `Paper:` line ("a proposed replacement for `def:frame`'s fourth constraint").
- [ ] The replacement register for all four: `Completion` is stated here **beside** the four
      axioms because it is the exact condition the extension chain consumes and the comparison is
      only meaningful at a shared level — a *derived* condition of record, not a candidate
      constraint. Its `Paper:` line becomes `—` with the one-clause reason that the manuscript has
      no anchor for it (C15's sanctioned form), unless an existing anchor already fits.
- [ ] Record, in the `def Completion` docstring, the two reasons it is not `def:frame`'s
      constraint — the `def:world-history` aboutness and the `completion_iff_onePointExtension`
      circularity — so a future reader meets the verdict where the definition is, not only in
      `Extension/Completion.lean`.
- [ ] `FormalSystem/Semantics/StateTopology/ConstraintWitnesses.lean`, four regions calling
      *Completion* "the audit's **proposed replacement** for `def:frame`'s fourth constraint":
      rewrite each to name what the witnesses actually establish — the independence and strictness
      matrix — with a pointer to the `not_srel_nestSaturation` correction landed in Phase 2.
- [ ] Verify the `Saturation` docstring's "do not restore *strictly stronger*" sentence is still
      byte-identical to its pre-task form, and that the Phase 1 additions did not paraphrase it.
- [ ] `lake build` green. Commit.

**Timing**: 1.5 hours

**Depends on**: 1, 2

**Verification Tier**: prose

**Scope Hypothesis**: the research measured **8 prose regions** across these two files
(`TaskFrame.lean`: `:273-274`, `:576-578`, `:723-724`, `:744-750`, `:752-753`;
`ConstraintWitnesses.lean`: `:67-69`, `:107-116`, `:798-799`, `:997-998`) — line numbers stale
after Phases 1 and 2. Confirm by content: `grep -n 'proposed\|recommend\|replacement'` over both
files must return an empty advocacy set afterwards. An undercount is corrected in place and
recorded.

**Files to modify**:
- `FormalSystem/Semantics/TaskFrame.lean` — four prose regions plus one `Paper:` line
- `FormalSystem/Semantics/StateTopology/ConstraintWitnesses.lean` — four prose regions

**Verification**:
- Diff read-through confirms every changed hunk lies inside a comment or docstring region.
- `lake build` exits 0 with zero warnings.
- `grep -rn 'proposed\|recommended' FormalSystem/Semantics/TaskFrame.lean
  FormalSystem/Semantics/StateTopology/ConstraintWitnesses.lean` shows no surviving advocacy for
  *Completion* as a `def:frame` constraint.
- The "Do not restore" sentence is byte-identical to its pre-task form.

---

### Phase 8: Segments are load-bearing — the fibers-only sharpness fact [NOT STARTED]

**Goal**: Land the one genuinely new Question 2 finding if it verifies: a fibers-only `S₁ᵈ` cannot
replace *Saturation*, because the straddling regime of `Constraints τ z` contains no fibers at
all — and `SeparatingFrame` is the witness, satisfying the fiber-only condition while failing the
full one.

**Tasks**:

- [ ] In `ConstraintWitnesses.lean` (or `TaskFrame.lean` if the predicate is wanted beside the
      others — prefer the witnesses file, to avoid a second whole-library rebuild), state the
      fiber-only condition: `Saturation`'s statement with `IsFiber R s` in place of the
      disjunction.
- [ ] Prove `srel` satisfies it. The argument, worked through during planning and recorded here so
      the phase does not restart it: fibers of `srel` are `Fib srel w x = [w - |x|, w + |x|]` with
      `x : ℤ`. **Degenerate case** — if any member is a singleton `{w}` (`x = 0`), directedness
      forces a member inside `{w} ∩ F` for every other member `F`, and that member is nonempty,
      hence `= {w}`, hence `w ∈ F`; so `w` is in the intersection. **Main case** — every member has
      width `≥ 2`, so for any two members `I`, `J` the refining member `K ⊆ I ∩ J` has width `≥ 2`,
      giving `right(I) ≥ left(K) + 2 ≥ left(J) + 2`; taking `L = sSup` of left endpoints and
      `R = sInf` of right endpoints over `ℝ` yields `R ≥ L + 2`, and a real interval of length
      `≥ 2` contains a rational, which lies in every member.
- [ ] Conclude the sharpness statement: `srel` satisfies fiber-only `S₁ᵈ` and fails full `S₁ᵈ`
      (`not_srel_saturation`, already proved), so **segments are load-bearing** and a fibers-only
      constraint is inadequate. Docstring records that this is Question 2's one new finding and
      closes the fibers-only candidate row.
- [ ] Confirm the `longFile` hypothesis again after Phase 2's additions.
- [ ] **Pre-authorised exit**: if the `sSup`/`sInf`-over-an-arbitrary-family machinery costs more
      than the budget, close this phase `[COMPLETED WITH EXCLUSIONS]` with a
      `#### Reasoned Exclusions` table recording the item, the reason (the argument is sound but
      the `ℝ`-valued extrema over a `Set (Set ℚ)` need choice-extraction of centres and radii from
      `IsFiber`, which is disproportionate), and the evidence (the partial proof state or the
      elaboration error). In that case, record the argument as prose in the module docstring so the
      claim survives as a recorded, checkable sketch rather than as nothing. **No other phase
      depends on this one**, and no `sorry` may be left behind either way.
- [ ] `lake build` green, sorry-free, warning-free. Commit.

**Timing**: 1.5 hours

**Depends on**: 7

**Verification Tier**: local

**Scope Hypothesis**: this phase asserts the fibers-only claim is **true and provable**, which the
research flagged as plausible-not-verified. Planning checked the two feared cases (the `x = 0`
singleton fiber, and whether width `≥ 2` really forces a rational in the intersection) and both
resolve, but that is a hypothesis about *provability within budget*, not a fact. Confirm by
landing the theorem; disconfirm by taking the pre-authorised `[COMPLETED WITH EXCLUSIONS]` exit
with evidence.

**Files to modify**:
- `FormalSystem/Semantics/StateTopology/ConstraintWitnesses.lean` — the fiber-only predicate, the
  positive theorem for `srel`, and the sharpness remark

**Verification**:
- `lake build` exits 0, zero warnings; module silent under the package linter set.
- `#print axioms` clean on any new declaration; `grep -rn 'sorry'` over the file returns nothing.
- If the exit was taken: the phase heading reads `[COMPLETED WITH EXCLUSIONS]` and carries a
  `#### Reasoned Exclusions` table with all three columns filled.

---

### Phase 9: Theorem index, module READMEs, and the docs advocacy line [NOT STARTED]

**Goal**: Make the documentation layer say what the tree now says. Three markdown regions carry
the reversal and every new declaration needs an index row.

**Tasks**:

- [ ] `docs/theorem-index.md`: rewrite the one docs advocacy line ("`def:frame`'s proposed fourth
      constraint") and its supporting rows into the derived register, and add rows for every
      declaration landed in Phases 1–5 (and Phase 8 if it landed). Each row's anchor must match
      the `Paper:` line already written in that declaration's doc comment — invariant C15 checks
      both halves, and the doc comments were written in the same sub-step as the declarations
      precisely so this phase never retrofits one.
- [ ] `FormalSystem/Semantics/Extension/README.md`: rewrite the *Completion* section to present
      it as the derived condition, and add the nest-reduction material.
- [ ] `FormalSystem/Semantics/StateTopology/README.md`: rewrite the witnesses section to record
      that both witnesses refute `S₁`, not merely `S₁ᵈ`, with the corrected independence matrix.
- [ ] `FormalSystem/Semantics.lean`'s module-list docstring: check the `Extension.Step` /
      `Extension.Completion` entries for the same advocacy register and correct if present.
- [ ] `bash scripts/readme-lint.sh` and `bash scripts/check-module-invariants.sh` both exit 0.
      Commit.

**Timing**: 1 hour

**Depends on**: 6, 8

**Verification Tier**: prose

**Scope Hypothesis**: the research measured **3 markdown regions** (`docs/theorem-index.md:192`
plus supporting rows `:187-193`, `:227-229`; `Extension/README.md:22-32`;
`StateTopology/README.md:49-56`) and **0 ADR sites** in `docs/architecture/`. Confirm both:
`grep -rn 'proposed fourth constraint\|proposed replacement' docs/ FormalSystem/**/README.md`
must return nothing afterwards, and the claim of zero ADR sites is re-checked with
`grep -rln 'Completion' docs/architecture/` before this phase closes. A hit there means the
research undercounted and the ADR must be handled, not skipped.

**Files to modify**:
- `docs/theorem-index.md`
- `FormalSystem/Semantics/Extension/README.md`
- `FormalSystem/Semantics/StateTopology/README.md`
- `FormalSystem/Semantics.lean` (docstring only, if it carries the register)

**Verification**:
- `bash scripts/readme-lint.sh` exits 0.
- `bash scripts/check-module-invariants.sh` exits 0, C15 included.
- The advocacy grep over `docs/` and the READMEs returns nothing.

---

### Phase 10: Source-store context note, full gate set, and summary [NOT STARTED]

**Goal**: Record the distinctions this task fixed where the next agent will meet them, then prove
the whole tree is green, sorry-free, warning-free and unchanged where it must be unchanged.

**Tasks**:

- [ ] Resolve the source store, do not assume it: read `.claude-extensions.json`, take the
      `formal` extension's `source_dir`, confirm it exists on disk. **Never write under
      `.claude/**`** — it is a disposable deploy artifact and a hand-authored file there is wiped
      by the next regeneration.
- [ ] Extend `<source_dir>/context/project/logic/domain/frame-constraint-landscape.md` (it already
      exists, created by the prior wave) with two additions, not a new file: (i) the **four-row
      strength table** from this plan's Overview, naming which relations are settled, which is
      open, and where the "do not restore *strictly stronger*" instruction lives; (ii) the
      **carrier-hypothesis pattern** — state the order property directly, in the idiom of
      `NearestAt`/`HasNearest`, and do not route through Mathlib structure classes Mathlib does not
      have (no `Archimedean D`, no Hölder embedding).
- [ ] If the file's index entry needs updating, update `<source_dir>/index-entries.json` and
      confirm it parses (`python3 -m json.tool`).
- [ ] Run the full gate set (see Testing & Validation) and fix anything it catches.
- [ ] Write `summaries/01_restore-saturation-settle-nests-summary.md` recording: the three answers,
      the declarations landed, the Phase 8 outcome, the recorded non-goal with its recipe, and the
      fact that no manuscript file was touched.
- [ ] Final commit.

**Timing**: 1.5 hours

**Depends on**: 9

**Verification Tier**: full

**Files to modify**:
- `<source_dir>/context/project/logic/domain/frame-constraint-landscape.md` (resolved, never
  `.claude/`)
- `<source_dir>/index-entries.json` (if needed)
- `specs/662_s1_vs_directedness_and_restore_saturation/summaries/01_restore-saturation-settle-nests-summary.md`

**Verification**:
- Every item under Testing & Validation passes.
- `git status --short` shows no file written under `.claude/`.
- `python3 -m json.tool <source_dir>/index-entries.json` succeeds.

---

## Lean Challenge Statements

```lean
import Mathlib.Order.Preorder.Chain
import FormalSystem.Semantics.TaskFrame
import FormalSystem.Semantics.Extension.Constraint
import FormalSystem.Semantics.Extension.Completion
import FormalSystem.Semantics.StateTopology.ConstraintWitnesses

namespace FormalSystem.Semantics

variable {D : Type} [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D] [Nontrivial D]

/-- The nest condition `S₁` (*spherical completeness*) of the Ćmiel–Kuhlmann–Kuhlmann ball-space
hierarchy, over a bare task relation: `Saturation` with a `⊆`-chain of balls in place of a
`⊇`-directed family. The member condition is character-for-character `Saturation`'s. -/
def TaskFrame.NestSaturation {W : Type} (R : W → D → W → Prop) : Prop := sorry

/-- **The ball-space footnote's asserted implication, machine-checked**: `S₁ᵈ → S₁`. A nonempty
chain is a `⊇`-directed family, since the smaller of any two comparable members refines both.
The converse is **open**; nothing in this development bears on it. -/
theorem TaskFrame.nestSaturation_of_saturation {W : Type} {R : W → D → W → Prop}
    (h : TaskFrame.Saturation R) : TaskFrame.NestSaturation R := sorry

/-- The Newton-minus-gap sequence stays strictly below the cut: `(nt n - (1/2)^n)^2 < 2`. -/
theorem StateTopology.RationalTwoOrigins.phi_sq_lt_two (n : ℕ) :
    StateTopology.RationalTwoOrigins.phi n ^ 2 < 2 := sorry

/-- From index `2` on, `phi` clears `1` — the load-bearing `1 ≤ a` conjunct of `straddle`, which
`phi 0 = 1/2` and `phi 1 = 11/12` both fail. This is why the nest is indexed `phi (n + 2)`. -/
theorem StateTopology.RationalTwoOrigins.one_le_phi_add_two (n : ℕ) :
    1 ≤ StateTopology.RationalTwoOrigins.phi (n + 2) := sorry

/-- The cofinal **nest** inside `straddle`: the intervals `[phi (n+2), nt n]`, decreasing onto the
cut at `√2`. Its existence is what makes the separating frame a witness against `S₁` and not
merely against `S₁ᵈ`. -/
def StateTopology.SeparatingFrame.nest : Set (Set ℚ) := sorry

/-- **Correction of a standing assumption.** The ℚ-over-ℤ drift relation satisfies *Seriality*,
*Compositionality*, *Limit* and *Completion* and fails the **nest** condition `S₁`, not merely the
directed condition `S₁ᵈ`. So neither existing witness separates the two forms, and the existing
sharpness result is about `S₁`. -/
theorem StateTopology.SeparatingFrame.not_srel_nestSaturation :
    ¬ TaskFrame.NestSaturation StateTopology.SeparatingFrame.srel := sorry

namespace PartialHistory

variable {F : TaskFrame}

/-- Fiber monotonicity below `z`, with the hypothesis the proof actually consumes made explicit:
*Compositionality* alone, never the `IsRegular` instance. `fib_subset_fib_of_le_of_le` becomes a
one-line corollary of this. -/
theorem fib_subset_fib_of_compositional {τ : PartialHistory F} {z a b : F.Duration}
    (hcomp : TaskFrame.Compositional F.TaskRel) (ha : τ.domain a) (hb : τ.domain b)
    (hab : a ≤ b) (hbz : b ≤ z) :
    TaskFrame.Fib F.TaskRel (τ.states b hb) (z - b)
      ⊆ TaskFrame.Fib F.TaskRel (τ.states a ha) (z - a) := sorry

/-- Fiber monotonicity above `z`, the mirror image, on *Compositionality* plus the `FrameOver`
reflection field alone. -/
theorem fib_subset_fib_of_compositional' {τ : PartialHistory F} {z a b : F.Duration}
    (hcomp : TaskFrame.Compositional F.TaskRel) (ha : τ.domain a) (hb : τ.domain b)
    (hba : b ≤ a) (hzb : z ≤ b) :
    TaskFrame.Fib F.TaskRel (τ.states b hb) (z - b)
      ⊆ TaskFrame.Fib F.TaskRel (τ.states a ha) (z - a) := sorry

/-- Segment monotonicity on *Compositionality* alone. -/
theorem seg_subset_seg_of_compositional {τ : PartialHistory F} {z t s t' s' : F.Duration}
    (hcomp : TaskFrame.Compositional F.TaskRel)
    (ht : τ.domain t) (hs : τ.domain s) (ht' : τ.domain t') (hs' : τ.domain s')
    (htt' : t ≤ t') (ht'z : t' ≤ z) (hzs' : z ≤ s') (hs's : s' ≤ s) :
    TaskFrame.Seg F.TaskRel (τ.states t' ht') (τ.states s' hs') (z - t') (s' - z)
      ⊆ TaskFrame.Seg F.TaskRel (τ.states t ht) (τ.states s hs) (z - t) (s - z) := sorry

/-- `Constraints τ z` contains a nonempty `⊆`-chain that refines every member. This is the exact
indexing property that makes the nest form as strong as the directed form at one history and one
target — a property of the constraint family, not of the frame. -/
def HasCofinalNest (τ : PartialHistory F) (z : F.Duration) : Prop := sorry

/-- **The reduction.** `S₁`, a cofinal nest, and nonempty members give exactly what `lem:step`
consumes. Stated as a property of `Constraints τ z`: the frame-level `S₁ → Saturation` is
**false** and must never be stated. -/
theorem sInter_constraints_nonempty_of_nestSaturation
    (hS1 : TaskFrame.NestSaturation F.TaskRel) (τ : PartialHistory F) (z : F.Duration)
    (hne : ∀ c ∈ Constraints τ z, c.Nonempty) (hcof : HasCofinalNest τ z) :
    (⋂₀ Constraints τ z).Nonempty := sorry

/-- **The carrier discharge.** A countable domain has a cofinal nest. Two regimes only, by
`IsPaired`'s global collapse: a one-sided domain gives a fiber chain outright, and a straddling
domain gives segments indexed by `A × Bᵒᵖ`, diagonalised through the running extrema of
enumerations of `A` and `B`. No hypothesis on `D`, and no `Archimedean`/Hölder route. -/
theorem hasCofinalNest_of_countable (hcomp : TaskFrame.Compositional F.TaskRel)
    (τ : PartialHistory F) (z : F.Duration)
    (hcount : {t : F.Duration | τ.domain t}.Countable) : HasCofinalNest τ z := sorry

/-- **The headline.** Over any history with countably many times — automatic for `ℤ`-time and
`ℚ`-time, since every subset of `ℤ` or `ℚ` is countable — the nest condition `S₁` buys exactly
what `S₁ᵈ` buys at `lem:step`. The directedness is therefore not *forced* over any carrier this
development instantiates; it is kept on the naturalness criterion, and this theorem is the
sharpness result that records the fact rather than a case for weakening `def:frame`. -/
theorem sInter_constraints_nonempty_of_countable
    (hS1 : TaskFrame.NestSaturation F.TaskRel) (hcomp : TaskFrame.Compositional F.TaskRel)
    (τ : PartialHistory F) (z : F.Duration)
    (hne : ∀ c ∈ Constraints τ z, c.Nonempty)
    (hcount : {t : F.Duration | τ.domain t}.Countable) :
    (⋂₀ Constraints τ z).Nonempty := sorry

end PartialHistory

end FormalSystem.Semantics
```

## Testing & Validation

- [ ] `lake build` exits 0 with zero `error:` and zero `warning:` lines, at every phase boundary.
- [ ] Every modified `FormalSystem/**` module is silent under
      `lake env lean -D weak.linter.mathlibStandardSet=true -D autoImplicit=false` — the package's
      own linter set, which plain `lake env lean` does not apply.
- [ ] `#print axioms` reports exactly `propext`, `Classical.choice`, `Quot.sound` for each of the
      thirteen pinned declarations, and `grep -rn 'sorry' FormalSystem/ --include=*.lean` finds no
      new occurrence.
- [ ] **No theorem introduced by Phases 4 or 5 carries `[F.IsRegular]`.** Verified by reading the
      `#print axioms` statement output and by
      `grep -n 'IsRegular' FormalSystem/Semantics/Extension/Completion.lean` over the new section.
      This is the honesty gate of the whole `S₁`-sufficiency result.
- [ ] `bash scripts/check-module-invariants.sh` passes, including C15 with the new theorem-index
      rows and C30 with any `longFile` baseline added in Phases 2, 5 or 8.
- [ ] `bash scripts/check-paper-definitions.sh` reports no pinned anchor moved, and
      `docs/reference/paper-definitions-of-record.md` is unmodified.
- [ ] `bash scripts/check-evidence-probes.sh`, `bash scripts/check-metalogic-cycles.sh`,
      `bash scripts/check-copyright-headers.sh` and `bash scripts/readme-lint.sh` all exit 0.
- [ ] `git diff --stat` across the task's commits touches only:
      `FormalSystem/Semantics/TaskFrame.lean`,
      `FormalSystem/Semantics/Extension/{Constraint,Completion,Step,Extension}.lean`,
      `FormalSystem/Semantics/StateTopology/ConstraintWitnesses.lean`,
      `FormalSystem/Semantics.lean`, the two module READMEs, `docs/theorem-index.md`,
      `specs/662_s1_vs_directedness_and_restore_saturation/**`, and the resolved source-store paths
      from Phase 10. **No `typst/**` file and no `.claude/**` file appears.**
- [ ] Advocacy sweep: `grep -rn 'proposed fourth constraint\|proposed replacement\|recommended as'
      FormalSystem/ docs/ --include=*.lean --include=*.md` returns nothing referring to
      *Completion* as a `def:frame` constraint.
- [ ] Strength sweep: no in-tree region asserts `S₁ᵈ` is *strictly* stronger than `S₁`, and the
      `TaskFrame.lean` "do not restore *strictly stronger*" instruction is byte-identical to its
      pre-task form.

## Artifacts & Outputs

- `FormalSystem/Semantics/TaskFrame.lean` — `TaskFrame.NestSaturation`,
  `nestSaturation_of_saturation`, the extended `Saturation` ball-space docstring (open question +
  Hahn-group recipe + the directedness motivation), and the reversed *Completion* prose
- `FormalSystem/Semantics/Extension/Constraint.lean` — `fib_subset_fib_of_compositional`,
  `fib_subset_fib_of_compositional'`, `seg_subset_seg_of_compositional`, with the three existing
  lemmas demoted to corollaries
- `FormalSystem/Semantics/Extension/Completion.lean` — `HasCofinalNest`,
  `sInter_constraints_nonempty_of_nestSaturation`, `hasCofinalNest_of_countable`,
  `sInter_constraints_nonempty_of_countable`, the two `ℤ`/`ℚ` acceptance `example`s, the reversed
  architecture-target block, and the new strictness remark carrying the ball-space footnote
- `FormalSystem/Semantics/Extension/Step.lean`, `FormalSystem/Semantics/Extension/Extension.lean` —
  corrected relative-strength prose
- `FormalSystem/Semantics/StateTopology/ConstraintWitnesses.lean` — `phi_sq_lt_two`,
  `one_le_phi_add_two`, `SeparatingFrame.nest`, `not_srel_nestSaturation`, the Phase 8 fibers-only
  material if it landed, and four corrected prose regions
- `docs/theorem-index.md` — the corrected advocacy line plus rows for every new declaration
- `FormalSystem/Semantics/Extension/README.md`,
  `FormalSystem/Semantics/StateTopology/README.md`, `FormalSystem/Semantics.lean` (docstring)
- `<source_dir>/context/project/logic/domain/frame-constraint-landscape.md` and, if needed,
  `<source_dir>/index-entries.json` — resolved source store, never `.claude/`
- `specs/662_s1_vs_directedness_and_restore_saturation/summaries/01_restore-saturation-settle-nests-summary.md`

## Rollback/Contingency

The plan is additive and phase-committed, so rollback is per-phase and cheap: every phase ends in
its own commit and no phase deletes a theorem, so `git revert` of a single phase commit restores a
green tree.

- **A prose phase went too far** (Phases 6, 7, 9): revert that phase's commit and redo it against
  the four-row strength table. No mathematics is at risk, because the prose phases touch no
  executable code.
- **A Lean phase does not close** (Phases 2, 5, 8): the phase's own scope hypothesis or
  pre-authorised exit applies. Phase 8 has an explicit `[COMPLETED WITH EXCLUSIONS]` exit. Phase 5
  splits at the one-sided/straddling boundary. Phase 2's opportunistic `RationalTwoOrigins`
  analogue is droppable by construction. **No `sorry` is left behind in any case** — every
  deliverable in this plan has a sorry-free path, and the one item that does not (the
  `S₁`-vs-`S₁ᵈ` separating frame) is a declared non-goal rather than a deferral.
- **Whole-task rollback**: if the working tree must be reverted wholesale with uncommitted work
  present, take a snapshot first per `context/contracts/recovery.md`'s rollback rung —
  `bash .claude/scripts/git-snapshot.sh 662`, adding `--allow-out-of-scope` for the deliberate
  whole-tree case — and only then run the destructive command. Do **not** emit a bare
  `git-snapshot.sh 662` as a routine start-of-phase checkpoint; an ordinary defensive checkpoint
  before risky work uses `--no-revert`, which is durable without reverting the working tree.
- **Nothing to roll back in the manuscript**: no `typst/**` file is touched by any phase, so a
  failed task leaves the paper exactly as it was — still saying *Saturation*, which is the
  outcome this task is restoring the tree to anyway.
