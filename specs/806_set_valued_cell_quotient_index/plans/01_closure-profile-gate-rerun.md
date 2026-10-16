# Implementation Plan: Task #806

- **Task**: 806 - Set-valued cell over a quotient index: promote the closure-indexed periodicity prototype to a wired probe, and re-run the gate table against the countdown profile on the coprime-cycle fixture
- **Status**: [NOT STARTED]
- **Effort**: 9 hours
- **Dependencies**: 761 (parent, stays `[BLOCKED]`; this task does not touch it); 805 (predecessor, refuted; its fixture is ported, not imported)
- **Research Inputs**: specs/806_set_valued_cell_quotient_index/reports/01_closure-indexed-periodicity-gate.md
- **Artifacts**: plans/01_closure-profile-gate-rerun.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md, plan-compliance.md (Statement Fidelity)
- **Type**: lean4
- **Lean Intent**: true

## Overview

The research round discharged the cheap half of step (1) on compiled ground — eventual periodicity
of the countdown over the object-closure product, in a 238-line sorry-free prototype — named the
candidate presentation (the closure-indexed countdown profile, a SUBSET of `Q × ClType φ`, quotiented
by the kernel of the profile map, with no parameter), and rebuilt the gate table against it with two
new rows (gate 7 non-circularity, gate 8 `stab` self-reference). What it left for implementation is
exactly two things, both of which this plan lands as wired evidence probes under
`specs/evidence/seam-gluing-ray-product/`:

1. **Promote the prototype** to the collection and register it in `scripts/check-evidence-probes.sh`
   (research Recommendation 1). It currently sits in a task directory, which is the precise position
   from which four earlier probes were lost to `.gitignore` on archival.
2. **Run gate 6 on the real fixture** (research Recommendation 2, "the single most informative thing
   the next round can do"): define the LOCAL coherence relation for `chi`'s closure on the
   coprime-cycle object with `d` label-identical to `b`, and prove — by hand, not by `decide` over the
   carrier — that the `chi`-consistent part of the product never passes through `d`, that its
   `a`-to-`a` chains have length divisible by three, and therefore that the countdown profile
   SEPARATES the exact pair gate 6 used to refute the sixth index (`x5`/`y5`, countdowns `C` and
   `C + (P+1)` with `3 ∣ C`, `3 ∤ P+1`) for EVERY such `P` — with no parameter to choose. Gate 5's
   disarming is exhibited on the same fixture against the ported `reach5_eventually_constant`
   (object period 1 vs. profile period not 1). Gate 7 is passed in its definability form (the datum
   is a computable `Bool` relation built from `(Q, step, pend, lab, φ)` with no quantification over
   histories, checked mechanically) and witnessed non-vacuous (an explicit coherent 3-cycle of types).
   Gate 8 is SIDESTEPPED, not passed: `chi`'s closure has no `box`/`snce`/`stab` member
   (`chi_closure_untl_only`), so the unconstrained arms of the local coherence relation are never
   exercised on this fixture; the probe's header says so. Gates 1 and 2 are NOT addressed and are
   recorded as reducing to obligation (c) and to adequacy respectively.

Every count below was measured at plan time by compiling a scratch file through `lake env lean`
(8 s wall): `chi`'s closure has 18 elements; `decide` closes concrete coherence facts over it in
seconds; `decide` on `Finset.powerset` membership over it hits `maxRecDepth`, so closure types are
built as `filter`s with `Finset.mem_powerset.mpr (Finset.filter_subset _ _)`. The `## Lean Challenge
Statements` block below was compiled sorry-bodied with exit 0 before this plan was written; its
eleven theorem signatures are the contract.

What this plan does NOT do, by the dispatch's own ordering: it does not attempt sufficiency; it does
not construct the ADEQUATE (fulfilment-aware) coherence relation — only the local one, which
over-approximates realizability and is named as such in both probe headers; it does not start
obligations (b), (c), (d); it does not state `ladderRealized`, `LadderCons`, or any same-named
substitute, with or without the `box`/`stab` clause; it does not propose a seventh coordinate; it
touches nothing under `FormalSystem/` or `Tests/`.

### Research Integration

- **Step (1) split** (report §2): periodicity is the cheap half and is already compiled; adequacy
  (claim 3) is the expensive half and stays open. Both probe headers carry that split verbatim so
  the promotion cannot be read as "step (1) is done".
- **The datum and its quotient** (report §4): the countdown profile `Prof(k) := pre^[k] E` over
  `Q × ClType φ`, quotient by the kernel of the profile map. Phase 4 defines exactly this on the
  fixture (`Prof6 k := (prodPreStep coh6)^[k] Ea`, `Ea` the fibre over pending `a`, the state
  `endA` makes the region's last pending state).
- **Why gate 6 does not re-refute** (report §6): the pattern `psi2` and `⊤ U psi2` are subformulas
  of `chi`, hence closure members, hence tracked by the product. Phase 3 makes this compiled fact
  (`coh6_no_a_d_a`, `coh6_chain_a_to_a_mod3`).
- **Gate table rows 7 and 8** (report §7): gate 7 is run FIRST among the new rows (research
  Recommendation 3), as a definability-plus-non-vacuity exhibit in Phase 2; gate 8 is kept out of
  obligation (d) and recorded as sidestepped on a `stab`-free fixture (Recommendation 4).
- **In-repo precedent** (report §8): `Profile.lean`'s set-valued datum. Transferred: `Fintype`
  instances by `inferInstance` (confirmed at plan time — no hand-holding needed here, unlike the
  three-nested-function case), cardinalities kept as counts. Not transferred: nothing about
  bi-infinite rays or fulfilment is claimed.
- **Costing of step (4)** (report §9): registration shape — one boxed decision-row comment block
  above the `WIRED` array plus one string entry; the guard requires the file to be git-TRACKED.
  Measured at plan time: `WIRED` holds 33 entries; this plan brings it to 35.
- **Tactic survey** (report): `decide` not `native_decide` (Decision 6); state concrete periodicity
  claims with concrete bounds so `decide` can disprove a wrong one.

### Prior Plan Reference

No prior plan for this task. The closest sibling plan in shape is the parent's
`specs/761_ladder_realization_theorem/plans/01_ladder-realization-blocked-probe.md`, which landed a
prototype as a wired probe in the same collection; its port-wire-gate phase structure and its
final-gate command list are the calibration for Phases 1, 5 and 6 here (its three Lean phases ran to
plan at roughly the hour each this plan allots).

### Roadmap Alignment

Not consulted: the dispatch context carries no `roadmap_path`, and this task modifies no roadmap.

## Goals & Non-Goals

**Goals** (identifier set equals the eleven `theorem` declarations in `## Lean Challenge Statements`;
all land in `specs/evidence/seam-gluing-ray-product/closure-profile-gate-rerun.lean`, namespace
`Probe806`):
- `chi_closure_untl_only`
- `coh6_liesOver`
- `coh6_cycle_witness`
- `coh6_chi_propagates`
- `coh6_no_a_d_a`
- `coh6_chain_a_to_a_mod3`
- `prof6_fibre_a_of_mem`
- `prof6_fibre_a_witness`
- `prof6_separates_gate6_pair`
- `prof6_period_not_one`
- `reach5_eventually_constant`

Plus, not Goals (ports with no new statement): the seven theorems of the promoted prototype
(`iterate_eventually_periodic`, `prodReachN_eventually_periodic`, `prodPreN_eventually_periodic`,
`prodReach_fst_subset`, `strict_object_period_one`, `strict_product_period_three`,
`strict_product_not_period_one`) move byte-for-byte to
`specs/evidence/seam-gluing-ray-product/closure-indexed-periodicity.lean`.

**Non-Goals**:
- Any sufficiency claim, factorization lemma, or cell index; any declaration named `ladderRealized`,
  `LadderCons`, `ladderCons_localRun`, or a same-named weaker substitute — in any file.
- The ADEQUATE coherence relation (fulfilment of `untl`/`snce` eventualities; report §2 claim 3).
  `coh` is LOCAL coherence and both probe headers say it over-approximates realizability.
- Obligations (b) region-length pumping, (c) `Drift` coupling of the next deadline, (d) `box`/`stab`
  through `box_mem_tpOf_iff`/`stab_mem_tpOf_iff`. Gate 1 (needs (c)) and gate 2 (reduces to
  adequacy) are recorded as NOT ADDRESSED, never as passed.
- A seventh tuple coordinate, or any re-presentation of the profile's threshold/period as index
  coordinates (report §5, final paragraph).
- Any edit under `FormalSystem/`, `Tests/`, `docs/`, or the RaySummary README; any edit to the
  parent task 761's records; any edit to `ladder-counter-observables.md` (source-store file, its own
  commit outside this repository — report's Context Extension Recommendation, deferred).
- Re-deriving any of the four refuted shapes or the finiteness of the cell set.

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| `decide` attempted over the whole carrier (`2^18` closure types × 8 object states) or over `Finset.powerset` membership — times out or hits `maxRecDepth` (observed at plan time for the latter) | H | M | Every Goal quantifying over `ClType chi` is proved by hand through `coh_iff` and per-formula instantiation; `decide` is used only on concrete types (`Ta`/`Tb`/`Tc`), concrete closure memberships, and the 8-state object graph. Types are built with `mkT` (a `filter`), never by `decide` on `powerset`. |
| The local coherence relation is read as the adequacy construction, i.e. "step (1) done" | H | M | Both headers state `coh` is LOCAL and over-approximates; the eighteenth probe's "what this does NOT say" names claim 3 as open and names the fulfilment-flag repair as the reason periodicity survives it. |
| `coh6` accidentally vacuous (a definition bug makes it always `false`), so `coh6_no_a_d_a` and the chain lemma are trivially true — gate 7's characteristic failure | H | L | `coh6_cycle_witness` (Phase 2) is a non-vacuity theorem proved by `decide` on explicit types and is a hard Goal; it is landed BEFORE any negative lemma. |
| `abbrev` vs. `def` drift between the Challenge block (which must use `abbrev` for supporting context so the snapshot tool does not count it) and the probe (which uses `def`, as the collection does) makes `lean-challenge-snapshot.sh --check` report drift | L | M | The theorem HEADERS are identical in both; `--check` is advisory per plan-compliance.md. If a drift finding appears, investigate, do not edit the Challenge block to match. |
| `git mv` of the prototype leaves the report's cited path `prototype/closure-indexed-periodicity.lean` stale | L | H | Expected and acceptable: the report is a dated record; the summary (Phase 6) records the move and the new path. Do not edit the report. |
| Port of `pred_of_d`/`succ_of_d`/`step5_cyc`/`cyc` lemmas from the sixteenth probe is done by re-typing and introduces a transcription error | M | L | Copy the fixture block (object layer only) verbatim from `ladder-joint-index-refutation.lean`; it is label-generic per the dispatch; `decide` re-proves each ported object fact. |
| The probe guard's shared build lock is held by a concurrent `lake` process; `check-evidence-probes.sh` reports an environment `FAIL`, not probe rot | M | L | Read the script's THREE DIAGNOSTIC CLASSES header before repairing anything; re-run after the lock clears; never hand-edit the probe to "fix" an environment failure. |
| A seventh mechanism exists that this fixture does not exercise | M | M | The eighteenth probe's header restates the standing lesson (a gate probing one coordinate certifies one coordinate) and lists exactly which gates are exhibited, sidestepped, or not addressed. The verdict wording is "survives this round's gates", never "survives". |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1, 2 | -- |
| 2 | 3 | 2 |
| 3 | 4 | 3 |
| 4 | 5 | 1, 4 |
| 5 | 6 | 5 |

Phases within the same wave can execute in parallel. Phase 1 and Phase 2 touch disjoint files
(Phase 1 edits `check-evidence-probes.sh`; Phase 5 edits it again, which is why Phase 5 depends on
Phase 1 — the new decision row goes directly below the promoted probe's row).

---

### Phase 1: Promote the Periodicity Prototype to the Seventeenth Wired Probe [NOT STARTED]

**Goal**: Move `prototype/closure-indexed-periodicity.lean` into the evidence collection, rewrite its
header from "PROTOTYPE TEST (not a wired probe)" to the collection's probe convention, register it in
`scripts/check-evidence-probes.sh`, and confirm the guard compiles it from its new, tracked path.

**Tasks**:
- [ ] `git mv specs/806_set_valued_cell_quotient_index/prototype/closure-indexed-periodicity.lean specs/evidence/seam-gluing-ray-product/closure-indexed-periodicity.lean` (the `prototype/` directory becomes empty and disappears; do not recreate it).
- [ ] Rewrite the header block only (nothing below `import`): replace the opening "PROTOTYPE TEST (not a wired probe)" line with the collection's shape — a one-paragraph capitalised verdict line, then `## What was asked`, `## What is settled` (the three items already in the header: generic periodicity; closure-indexed carrier finite, both operators eventually periodic; refinement strict), `## What this does NOT say` (keep the existing four bullets verbatim — product step is a PARAMETER, no modulus computed, strictness is a witness not a classification, the three remaining obligations untouched — and add one sentence that the eighteenth probe, `closure-profile-gate-rerun.lean`, constructs the LOCAL relation on one fixture and leaves adequacy open). Update the `Compile:` line to the new path. No declaration, proof, or `#print axioms` line changes.
- [ ] In `scripts/check-evidence-probes.sh`, add a boxed decision-row comment block directly below the `ladder-joint-index-refutation` row (same `# <path> | <decision>` column layout, wrapped at the same width), naming: the seven theorems; the decision held in place ("a modulus must cover the period of the OBJECT-CLOSURE PRODUCT, not the object's graph: the two periods are independent, `strict_object_period_one`/`strict_product_period_three`/`strict_product_not_period_one`; the closure-indexed carrier is finite and both countdown operators are eventually periodic, `prodPreN_eventually_periodic`"); what it withholds (no coherence relation, no modulus, no adequacy, no index, no library declaration); axioms `[propext, Classical.choice, Quot.sound]` on all seven.
- [ ] Add `"seam-gluing-ray-product/closure-indexed-periodicity"` as the last entry of the `WIRED` array.
- [ ] Commit the move, the header, and the registration as one green sub-step via `bash .claude/scripts/git-commit-scoped.sh` (explicit file list: the moved file, the removed prototype path, `scripts/check-evidence-probes.sh`).

**Timing**: 1 hour

**Depends on**: none

**Verification Tier**: local

**Scope Hypothesis**: The prototype has 238 lines and exactly seven `#print axioms` lines, and `WIRED` has 33 entries before this phase (all three measured at plan time via `wc -l`, `grep -c '^#print axioms'`, and a `sed`/`grep -c` over the array); confirm each at implementation time with the same commands, and expect `WIRED` to hold 34 entries after this phase.

**Tier Justification**: `bash .claude/scripts/lake-build-guard.sh build --timeout 600 -- env lean specs/evidence/seam-gluing-ray-product/closure-indexed-periodicity.lean` (exit 0, zero errors, zero warnings, seven axiom lines each `[propext, Classical.choice, Quot.sound]`) plus `bash scripts/check-evidence-probes.sh` (exit 0, `PASS  all 34 wired probe(s) compile`) is the complete covering check — the file lies outside the Lake build graph so no module depends on it, and the registration script is its own only consumer.

**Files to modify**:
- `specs/evidence/seam-gluing-ray-product/closure-indexed-periodicity.lean` - new path (via `git mv`); header rewritten to probe convention
- `specs/806_set_valued_cell_quotient_index/prototype/closure-indexed-periodicity.lean` - removed by the move
- `scripts/check-evidence-probes.sh` - one decision-row comment block, one `WIRED` entry

**Verification**:
- `git ls-files --error-unmatch specs/evidence/seam-gluing-ray-product/closure-indexed-periodicity.lean` exits 0 after the commit (the guard's TRACKED test).
- Guarded `lake env lean` of the moved file exits 0 with no `sorry`, no `native_decide`, no new axiom (seven `#print axioms` lines unchanged).
- `bash scripts/check-evidence-probes.sh` exits 0 and reports 34 wired probes.
- `grep -c "ladderRealized\|LadderCons" specs/evidence/seam-gluing-ray-product/closure-indexed-periodicity.lean` reports 0 outside the header's negative mentions (header may name them only in "what this does NOT say").

---

### Phase 2: Fixture Port, the Local Coherence Relation, and the Non-Vacuity Witness [NOT STARTED]

**Goal**: Start `closure-profile-gate-rerun.lean` with the coprime-cycle object (object layer only),
`chi`'s formulas, gate 6's labelling, the closure-indexed carrier restated, the generic LOCAL
coherence relation `coh` built from `(Q, step, pend, lab, φ)` alone, its fixture instance `coh6`, the
fragment check `chi_closure_untl_only`, the lies-over fact `coh6_liesOver`, and the explicit coherent
3-cycle of types `coh6_cycle_witness`. This phase is the gate-7 exhibit: definability without
histories, and non-vacuity.

**Tasks**:
- [ ] Create `specs/evidence/seam-gluing-ray-product/closure-profile-gate-rerun.lean` with a placeholder header (`/- EIGHTEENTH PROBE -- header written in Phase 5 -/`), `import FormalSystem.Metalogic.Decidability.RaySummary.AnchorLayer`, `open FormalSystem.Syntax FormalSystem.PlusLanguage`, `namespace Probe806`. Probes do not import probes: everything below is restated.
- [ ] Port VERBATIM from `ladder-joint-index-refutation.lean` (object layer only, no frame/history/model layer — no `F5`, `M6`, `hist_path5`, `g5Ref`, `WorldHistory`): the atoms `pA rA aA bA` and their inequality lemmas; `p`, `la`, `nextPow`, `pa`, `psi2`, `chi` (`chi := psi2.neg.and (PlusFormula.untl (.imp .bot .bot) psi2).neg`); `Q5`, `pend5`, `step5`, `nxt`, `prv`, `step5_nxt`, `step5_prv`; `cyc`, `cyc_cases`, `cyc_ne_three`, `step5_cyc_succ`, `step5_cyc`, `cyc_zero`, `dvd_of_cyc_zero`, `pred_of_d`, `succ_of_d`; `lab6`, `lab6_p`, `lab6_r`, `lab6_a`; `reachStep`, `a5`, `reach5_four`, `reachStep5_univ`. Add `b5 := (true, 1)`, `c5 := (true, 2)`, `d5 := (true, 3)` as `def`s.
- [ ] Restate from the seventeenth probe: `ClType`, `ProdState`, `prodPreStep` (the countdown operator; `prodReachStep` is not needed here). The `Fintype`/`DecidableEq` instances resolve by `inferInstance`; do not declare named instances.
- [ ] Define, exactly as in `## Lean Challenge Statements` but as `def`s: `noModalArm`, `locPred`, `linkPred`, `locCoh`, `untlLink`, `coh`, `coh6`. `locPred` is the Hintikka condition per closure formula at a labelled object state (atom bit equals the labelling; `bot` absent; `imp α β` present iff `α` absent or `β` present; every other constructor unconstrained). `linkPred` is `PlusTruthAt`'s STRICT-until unfolding across one step (`untl g e ∈ T ↔ e ∈ T' ∨ (g ∈ T' ∧ untl g e ∈ T')`); every other constructor unconstrained. `coh` conjoins the object step, pending-ness of BOTH endpoints (the countdown profile lives on the pending sub-object: `Count`'s `py ∧ px → c' + 1 = c` clause), local coherence at both endpoints, and the link. Add a docstring on each unconstrained arm saying it is a deliberate over-approximation and that gate 8 is therefore not addressed by this relation.
- [ ] Prove the unfolding lemma `coh_iff` (statement: `coh step pend lab φ x y = true ↔ step x.1 y.1 = true ∧ pend x.1 = true ∧ pend y.1 = true ∧ (∀ ψ ∈ plusSubformulaClosure φ, locPred lab x.1 x.2.1 ψ = true) ∧ (∀ ψ ∈ plusSubformulaClosure φ, locPred lab y.1 y.2.1 ψ = true) ∧ (∀ ψ ∈ plusSubformulaClosure φ, linkPred x.2.1 y.2.1 ψ = true)`; proof `simp [coh, locCoh, untlLink, Bool.and_eq_true, and_assoc]` — confirmed at plan time). This is the workhorse for every hand proof in Phases 3-4.
- [ ] Prove `chi_closure_untl_only` by `decide` (confirmed at plan time) and `coh6_liesOver` from `coh_iff`.
- [ ] Define `top`, `Xpa := nextPow 1 pa`, `XXpa := nextPow 2 pa`, `B := pa.imp XXpa.neg`, `C := p.imp la.neg`, `ev := PlusFormula.untl top psi2`, the three membership lists `TaL`/`TbL`/`TcL` exactly as in the Challenge block, `mkT`, `Ta`, `Tb`, `Tc`. Prove `coh6_cycle_witness` by `decide` on each conjunct (plan-time compile: each closes in well under a second; `#print axioms` reports `[propext, Classical.choice, Quot.sound]`).
- [ ] Add `#print axioms` lines for `chi_closure_untl_only`, `coh6_liesOver`, `coh6_cycle_witness` at the end of the file (the axiom block grows in Phases 3-4); commit as a green sub-step.

**Timing**: 2 hours

**Depends on**: none

**Verification Tier**: local

**Scope Hypothesis**: `plusSubformulaClosure chi` has exactly 18 elements, and `Ta`/`Tb`/`Tc` have 9/9/10 elements respectively (measured at plan time by `#eval` on a scratch file and by hand truth-tabling the 3-cycle run); confirm at implementation time with `#eval (plusSubformulaClosure chi).card` and `#eval Ta.1.card` etc. in a scratch file, never left in the probe.

**Tier Justification**: `bash .claude/scripts/lake-build-guard.sh build --timeout 600 -- env lean specs/evidence/seam-gluing-ray-product/closure-profile-gate-rerun.lean` exiting 0 with zero errors is the complete covering check — the probe is outside the Lake graph, is imported by nothing, and this phase edits no other file.

**Files to modify**:
- `specs/evidence/seam-gluing-ray-product/closure-profile-gate-rerun.lean` - new file: fixture port, carrier, `coh`/`coh6`, `coh_iff`, three Goals

**Verification**:
- Guarded `lake env lean` of the probe exits 0; `grep -c sorry` reports 0; `grep -c native_decide` reports 0.
- `grep -nE "WorldHistory|tpOf|cellAt|PlusTruthAt|IsSlicedStepPath" specs/evidence/seam-gluing-ray-product/closure-profile-gate-rerun.lean` reports 0 hits outside comments — the gate-7 mechanical check that the datum quantifies over no history and mentions no cell.
- The three Goal signatures match `## Lean Challenge Statements` exactly.
- `#print axioms` on the three Goals: `[propext, Classical.choice, Quot.sound]` at most.

---

### Phase 3: The chi-Consistent Product Never Passes Through d, and Its a-to-a Chains Have Length Divisible by Three [NOT STARTED]

**Goal**: Prove the three hand lemmas that convert report §6 from claim to compiled fact:
`coh6_chi_propagates`, `coh6_no_a_d_a`, `coh6_chain_a_to_a_mod3`.

**Tasks**:
- [ ] `coh6_chi_propagates`: from `coh_iff` take the local condition at `x`, the local condition at `y`, and the link. Instantiate each `∀ ψ ∈ closure` at a concrete formula with membership by `decide` (`chi`, `psi2.neg.imp ev.neg.neg`, `psi2.neg`, `ev.neg.neg`, `ev.neg`, `ev`, `top`, `psi2`, `.bot` — all closure members; confirmed at plan time for `chi` and `ev`). Chain: `chi ∈ T` ⇒ `(psi2.neg.imp ev.neg.neg) ∉ T` ⇒ `psi2.neg ∈ T ∧ ev.neg.neg ∉ T` ⇒ `ev.neg ∈ T` ⇒ `ev ∉ T`; link on `ev = untl top psi2` ⇒ `psi2 ∉ T' ∧ ¬(top ∈ T' ∧ ev ∈ T')`; `top ∈ T'` by the `imp` clause on `.bot`; so `ev ∉ T'`, `psi2.neg ∈ T'`, `ev.neg ∈ T'`, `ev.neg.neg ∉ T'`, `(psi2.neg.imp ev.neg.neg) ∉ T'`, hence `chi ∈ T'`. Each step is `simp only [locPred, linkPred, beq_iff_eq, decide_eq_true_eq, ...]` on one instantiated hypothesis.
- [ ] `coh6_no_a_d_a`: at `a5`, local coherence of `T` forces `p ∈ T`, `la ∈ T`, hence `la.neg ∉ T`, `C ∉ T`, `pa ∈ T`; likewise `pa ∈ T''`. Link `T'`–`T''` on `Xpa = untl .bot pa` gives `Xpa ∈ T'` (`.bot ∉ T''`); link `T`–`T'` on `XXpa = untl .bot Xpa` gives `XXpa ∈ T`; so `XXpa.neg ∉ T`, `B ∉ T`, `psi2 ∈ T`, `psi2.neg ∉ T`, `(psi2.neg.imp ev.neg.neg) ∈ T`, hence `chi ∉ T`. Note `d5`'s labelling is irrelevant here — only `a5`'s atoms are read — which is the compiled form of "the pattern forbids no letter".
- [ ] A ported, ℕ-indexed walk lemma `chain_cyc`: for `g : ℕ → ProdState Q5 chi` with `coh6 (g i) (g (i+1)) = true` for `i < k`, `(g 0).1 = a5`, and `(g j).1 ≠ d5` for all `j ≤ k`, conclude `(g i).1 = (true, cyc (i : ℤ))` for all `i ≤ k` — induction on `i` using `coh6_liesOver`, the `pend` conjunct of `coh_iff` (both endpoints pending), and the ported `step5_cyc`. This is `walk_mod3`'s shape with the `Rlad` run replaced by a `coh6` chain.
- [ ] `coh6_chain_a_to_a_mod3`: first `chi ∈ (g i).2.1` for all `i ≤ k` by induction with `coh6_chi_propagates`; then d-freeness: if `(g j).1 = d5` with `j ≤ k`, then `j ≠ 0` (`g 0` is `a5`) and `j ≠ k` (`g k` is `a5`), so `1 ≤ j < k`; `pred_of_d` on `coh6_liesOver (g (j-1)) (g j)` (with the pending conjunct to split the pair) gives `(g (j-1)).1 = a5`, `succ_of_d` gives `(g (j+1)).1 = a5`, and `coh6_no_a_d_a` contradicts `chi ∈ (g (j-1)).2.1`; finally `chain_cyc` at `k` with `hk` gives `cyc (k : ℤ) = 0`, and `dvd_of_cyc_zero` closes.
- [ ] Append `#print axioms` for the three new Goals; commit as a green sub-step.

**Timing**: 2 hours

**Depends on**: 2

**Verification Tier**: local

**Tier Justification**: Guarded `lake env lean` of `closure-profile-gate-rerun.lean` exiting 0 with zero errors is the complete covering check — same single-file, no-dependents situation as Phase 2.

**Files to modify**:
- `specs/evidence/seam-gluing-ray-product/closure-profile-gate-rerun.lean` - three Goals plus the `chain_cyc` helper

**Verification**:
- Guarded `lake env lean` exits 0; `grep -c sorry` reports 0.
- The three Goal signatures match `## Lean Challenge Statements` exactly; `#print axioms` on each reports `[propext, Classical.choice, Quot.sound]` at most.
- No `decide` call is applied to a goal quantifying over `ClType chi` (grep the proofs of the three Goals for `decide` and confirm each occurrence is a closure-membership fact or an object-graph fact).

---

### Phase 4: The Countdown Profile Separates Gate 6's Pair and Is Not Period 1 [NOT STARTED]

**Goal**: Define the countdown profile on the fixture and prove the four profile Goals plus the
ported object contrast: `prof6_fibre_a_of_mem`, `prof6_fibre_a_witness`,
`prof6_separates_gate6_pair`, `prof6_period_not_one`, `reach5_eventually_constant`.

**Tasks**:
- [ ] Define `Ea : Finset (ProdState Q5 chi) := Finset.univ.filter (fun x => x.1 = a5)` and `Prof6 (k : ℕ) := (prodPreStep coh6)^[k] Ea` as `def`s, with a docstring: `Ea` is the fibre over the pending `a` that `endA` makes the region's last pending state; `Prof6 k` is the set of product states from which a `coh6`-chain of length `k` reaches that fibre — the countdown profile at distance `k`, parameter-free.
- [ ] Prove `mem_prof6_succ (x) (k) : x ∈ Prof6 (k+1) ↔ ∃ y ∈ Prof6 k, coh6 x y = true` via `Function.iterate_succ_apply'`, `Finset.mem_filter`, `Finset.mem_univ`.
- [ ] Prove `prof6_chain (x) (k) (h : x ∈ Prof6 k) : ∃ g : ℕ → ProdState Q5 chi, g 0 = x ∧ (∀ i, i < k → coh6 (g i) (g (i+1)) = true) ∧ (g k).1 = a5` by induction on `k` generalising `x` (prepend `x` to the chain the inductive hypothesis returns: `g' 0 := x`, `g' (i+1) := g i`).
- [ ] `prof6_fibre_a_of_mem`: `prof6_chain` then `coh6_chain_a_to_a_mod3`.
- [ ] `prof6_fibre_a_witness`: induction on `m` with `k = 3 * m`; the step uses `mem_prof6_succ` three times with the witness cycle `(a5,Ta) → (b5,Tb) → (c5,Tc) → (a5,Ta)` from `coh6_cycle_witness`; the base is `(a5, Ta) ∈ Ea` by `Finset.mem_filter`.
- [ ] `prof6_separates_gate6_pair`: `(a5, Ta) ∈ Prof6 C` by the witness; if `Prof6 C = Prof6 (C + (P+1))` then `(a5, Ta) ∈ Prof6 (C + (P+1))`, so `3 ∣ C + (P+1)` by `prof6_fibre_a_of_mem` with `chi ∈ Ta.1` (from `coh6_cycle_witness`), contradicting `3 ∣ C` and `¬ 3 ∣ P+1` by `omega`. These are exactly the countdowns of the sixteenth probe's `x5 T P B` and `y5 T P B` (`c5 T P` and `c5 T P + (P+1)`, with `c5_dvd`), at every `P` for which that probe's `cell6_ne` holds.
- [ ] `prof6_period_not_one`: same shape with `k` and `k+1`.
- [ ] `reach5_eventually_constant`: port the proof verbatim from the sixteenth probe (it depends only on the ported `reach5_four` and `reachStep5_univ`). This is the gate-5 contrast: the object's full-graph reach set has period 1 from threshold 4; the profile's `a`-fibre is nonempty at exactly the multiples of 3 for `chi`-types.
- [ ] Append `#print axioms` for the five Goals; commit as a green sub-step.

**Timing**: 2 hours

**Depends on**: 3

**Verification Tier**: local

**Tier Justification**: Guarded `lake env lean` of `closure-profile-gate-rerun.lean` exiting 0 with zero errors is the complete covering check — single file, no dependents, no other file edited.

**Files to modify**:
- `specs/evidence/seam-gluing-ray-product/closure-profile-gate-rerun.lean` - `Ea`, `Prof6`, two helpers, five Goals

**Verification**:
- Guarded `lake env lean` exits 0; `grep -c sorry` reports 0; `grep -c native_decide` reports 0.
- All eleven Goal signatures now present and matching `## Lean Challenge Statements` exactly; eleven `#print axioms` lines, each `[propext, Classical.choice, Quot.sound]` at most.
- `prof6_separates_gate6_pair` has NO hypothesis naming a threshold, modulus, or clip bound — only `3 ∣ C` and `¬ 3 ∣ P + 1`, which describe the PAIR, not the index.

---

### Phase 5: Header, Gate Table Verdict, and Registration of the Eighteenth Probe [NOT STARTED]

**Goal**: Write the probe's header in the collection's convention and wire it into the guard, so the
verdict of dispatch items (3) and (4) is a machine-checked, tracked, CI-guarded record.

**Tasks**:
- [ ] Replace the placeholder header with the convention: a capitalised verdict paragraph ("THE CLOSURE-INDEXED COUNTDOWN PROFILE SURVIVES THIS ROUND'S GATES ON THE COPRIME-CYCLE FIXTURE: gate 6's pattern is tracked by the closure and the pair it separated is separated by the profile with no parameter; gate 5's object period does not bind the profile; gate 7 is passed in its definability form and witnessed non-vacuous; gate 8 is SIDESTEPPED on a stab-free fixture, not passed; gates 1 and 2 are NOT ADDRESSED; adequacy is OPEN and nothing here is a factorization lemma, a cell index, or any part of one"); `## What was asked` (dispatch items 2-4, the research's gate table); `## The verdict`; one section per gate 1-8 in the research's §7 order stating exactly which theorems exhibit it or that nothing does; `## What this does NOT say` — at minimum: `coh` is LOCAL coherence and over-approximates realizability (claim 3 open; the fulfilment-flag repair keeps the carrier finite); no modulus, threshold or index is computed or claimed computable; the datum is defined for a `stab`-free `φ` only in the sense that the `box`/`snce`/`stab` arms are unconstrained (gate 8 open, `chi_closure_untl_only` is why it does not bite here); gate 1 needs obligation (c), gate 2 reduces to adequacy; a seventh mechanism is not excluded; obligations (b), (c), (d) untouched; no `ladderRealized`/`LadderCons` in any form; nothing about `HitPresented`; no library declaration. Then the `Compile:` line.
- [ ] In `scripts/check-evidence-probes.sh`, add the decision-row comment block directly below the seventeenth probe's row (Phase 1), listing all eleven theorem names against the gate each exhibits, the "what it withholds" list, and the axioms; add `"seam-gluing-ray-product/closure-profile-gate-rerun"` as the last `WIRED` entry.
- [ ] Run `bash scripts/check-evidence-probes.sh` and confirm `PASS  all 35 wired probe(s) compile`.
- [ ] Re-run the gate-7 mechanical check (Phase 2's grep) on the finished file.
- [ ] Commit (explicit file list: the probe, `scripts/check-evidence-probes.sh`).

**Timing**: 1 hour

**Depends on**: 1, 4

**Verification Tier**: local

**Scope Hypothesis**: `WIRED` holds 34 entries after Phase 1 and 35 after this phase; confirm with `sed -n '/^WIRED=(/,/^)/p' scripts/check-evidence-probes.sh | grep -c '^  "'`.

**Tier Justification**: `bash scripts/check-evidence-probes.sh` exiting 0 with `PASS  all 35 wired probe(s) compile`, plus `bash -n scripts/check-evidence-probes.sh`, is the complete covering check — the header edit has no compile surface beyond the probe the script already compiles, and the script is the registration's only consumer.

**Files to modify**:
- `specs/evidence/seam-gluing-ray-product/closure-profile-gate-rerun.lean` - header only
- `scripts/check-evidence-probes.sh` - one decision-row comment block, one `WIRED` entry

**Verification**:
- `bash -n scripts/check-evidence-probes.sh` exits 0; `bash scripts/check-evidence-probes.sh` exits 0 reporting 35.
- `git ls-files --error-unmatch` on both new probe paths exits 0 after the commit.
- The header's gate sections name every Goal exactly once and name no theorem that does not exist in the file (`grep` each backticked identifier in the header against the file's declarations).
- The header contains the literal phrases "LOCAL coherence", "NOT ADDRESSED" (for gates 1 and 2), "SIDESTEPPED" (gate 8), and "adequacy" under "What this does NOT say".

---

### Phase 6: Run the Full Gate, Write the Summary, Return [NOT STARTED]

**Goal**: Discharge the complete gate set over the two new probes and the registration edit, write
the implementation summary, and return `implemented` with the parent 761 untouched and still
`[BLOCKED]`.

**Tasks**:
- [ ] Run every command under **Verification** below, checking each exit status.
- [ ] Write `specs/806_set_valued_cell_quotient_index/summaries/01_closure-profile-gate-rerun-summary.md` per summary-format.md: the two probe paths; the per-gate verdict table (exhibited / sidestepped / not addressed) copied from the eighteenth probe's header; the explicit statement that step (1)'s adequacy half and dispatch item (5) (obligations b, c, d) are NOT started and belong to a successor record; the prototype's move and the report's now-historical path citation; the carried-figure note that the sixteenth probe's gate outcomes were read from its header, not re-run.
- [ ] Record issues and wins in the task's issue log as they arose (per the dispatch's Issue Log section), or attest explicitly in the summary that there were none beyond those already logged.
- [ ] Commit the summary; return.

**Timing**: 1 hour

**Depends on**: 5

**Verification Tier**: full

**Commit Mode**: per-substep

**Files to modify**:
- `specs/806_set_valued_cell_quotient_index/summaries/01_closure-profile-gate-rerun-summary.md` - the implementation summary (new)
- `typst/generated/status.typ` - only if regenerated by the pre-commit hook (no diff expected)

**Verification** (the complete gate set — every command's exit status is checked, never only its
output):
- `bash .claude/scripts/lake-build-guard.sh build --timeout 600 -- env lean specs/evidence/seam-gluing-ray-product/closure-indexed-periodicity.lean` exits 0 (seven `#print axioms` lines, each `[propext, Classical.choice, Quot.sound]`).
- `bash .claude/scripts/lake-build-guard.sh build --timeout 600 -- env lean specs/evidence/seam-gluing-ray-product/closure-profile-gate-rerun.lean` exits 0 (eleven `#print axioms` lines, each `[propext, Classical.choice, Quot.sound]` at most; zero warnings).
- `bash scripts/check-evidence-probes.sh` exits 0 with `PASS  all 35 wired probe(s) compile`.
- `bash scripts/check-module-invariants.sh` exits 0 (run detached with a bounded waiter per `context/patterns/bounded-build-waiter.md`; C9 in particular — zero task-number citations under `FormalSystem/`, `docs/`, `scripts/` — the new `check-evidence-probes.sh` rows must cite probe filenames and theorem names, never "task 806").
- `bash .claude/scripts/check-task-references.sh --quiet` exits 0.
- Full `lake build` via `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build`, detached (`Bash(run_in_background: true)`) per `context/project/lean4/operations/long-builds.md`, exits 0 — expected a no-op success, since no library `.lean` file changes, but mandatory before the return.
- Lean agent Final Verification Stage over the two probe files: `bash .claude/scripts/lean-sorry-census.sh` count 0; vacuous-definition grep (`def .* := True`, `:= trivial`) count 0; `grep -c "^axiom "` count 0 in both probes; `grep -c native_decide` count 0 in both probes.
- `git diff --stat HEAD~N -- FormalSystem/ Tests/ docs/` (N = this task's commit count) is empty.
- `grep -rn "ladderRealized\|LadderCons" specs/evidence/seam-gluing-ray-product/closure-indexed-periodicity.lean specs/evidence/seam-gluing-ray-product/closure-profile-gate-rerun.lean` matches only header lines under "What this does NOT say".
- `bash .claude/scripts/verify-deploy.sh` exits 0.
- `bash .claude/scripts/lean-challenge-snapshot.sh --check 806 .` reports no drift (advisory; a drift finding is investigated, never silenced by editing the Challenge block).
- `git status --short` shows no stray modified files outside this plan's `Files to modify` set; the `prototype/` directory no longer exists.

## Lean Challenge Statements

The eleven `theorem` declarations are the Goals and carry `sorry` bodies. Everything above them is
supporting context declared with `abbrev`, which the snapshot tool (`lean-challenge-snapshot.sh`)
neither counts as a Goal nor rewrites — but it DOES swallow any non-`theorem` text that sits
between two `theorem` declarations into the preceding `:= sorry`, so every `abbrev` precedes the
first `theorem`. The probe itself uses `def` for all of these, as the collection does, and uses the
ported recursive `nextPow` where this block spells `Xpa`/`XXpa` out (the terms are identical after
unfolding). The definitional bodies of `coh`, `coh6`, `mkT`, the three type lists, `Ea`, and `Prof6`
are part of the contract and are written out. This block was compiled through `lake env lean` at plan
time: exit 0, eleven `declaration uses 'sorry'` warnings, no errors.

```lean
import FormalSystem.Metalogic.Decidability.RaySummary.AnchorLayer

open FormalSystem.Syntax FormalSystem.PlusLanguage

namespace Probe806

abbrev pA : Atom := ⟨"p", none⟩
abbrev rA : Atom := ⟨"r", none⟩
abbrev aA : Atom := ⟨"a", none⟩
abbrev bA : Atom := ⟨"b", none⟩
abbrev p : PlusFormula := .atom pA
abbrev la : PlusFormula := .atom aA
abbrev pa : PlusFormula := p.and la
abbrev Xpa : PlusFormula := .untl .bot pa
abbrev XXpa : PlusFormula := .untl .bot Xpa
abbrev psi2 : PlusFormula := pa.and XXpa
abbrev top : PlusFormula := .imp .bot .bot
abbrev ev : PlusFormula := .untl top psi2
abbrev chi : PlusFormula := psi2.neg.and ev.neg

abbrev Q5 : Type := Bool × Fin 4
abbrev pend5 : Q5 → Bool := fun q => q.1
abbrev step5 : Q5 → Q5 → Bool := fun x y =>
  if x.1 then
    (if y.1 then
      ((x.2 == 0 && (y.2 == 1 || y.2 == 3)) || (x.2 == 1 && y.2 == 2) ||
        (x.2 == 2 && y.2 == 0) || (x.2 == 3 && y.2 == 0))
     else (y.2 == x.2))
  else (!y.1 && (y.2 == x.2))
abbrev lab6 : Q5 → Atom → Bool := fun q at_ =>
  if at_ = pA then q.1 else if at_ = rA then !q.1
  else if at_ = aA then (q.2 == 0) else if at_ = bA then !(q.2 == 0) else false
abbrev a5 : Q5 := (true, 0)
abbrev b5 : Q5 := (true, 1)
abbrev c5 : Q5 := (true, 2)
abbrev d5 : Q5 := (true, 3)

abbrev ClType (φ : PlusFormula) : Type :=
  {T : Finset PlusFormula // T ∈ (plusSubformulaClosure φ).powerset}
abbrev ProdState (Q : Type) (φ : PlusFormula) : Type := Q × ClType φ
abbrev reachStep {Q : Type} [Fintype Q] [DecidableEq Q] (step : Q → Q → Bool) (S : Finset Q) :
    Finset Q :=
  S.biUnion (fun q => Finset.univ.filter (fun q' => step q q' = true))
abbrev prodPreStep {Q : Type} [Fintype Q] [DecidableEq Q] {φ : PlusFormula}
    (pstep : ProdState Q φ → ProdState Q φ → Bool) (S : Finset (ProdState Q φ)) :
    Finset (ProdState Q φ) :=
  Finset.univ.filter (fun x => ∃ y ∈ S, pstep x y = true)

abbrev noModalArm : PlusFormula → Bool
  | .box _ => false | .snce _ _ => false | .stab _ => false | _ => true
abbrev locPred {Q : Type} (lab : Q → Atom → Bool) (q : Q) (T : Finset PlusFormula) :
    PlusFormula → Bool
  | ψ@(.atom a) => decide (ψ ∈ T) == lab q a
  | ψ@.bot => decide (ψ ∉ T)
  | ψ@(.imp α β) => decide (ψ ∈ T) == (!(decide (α ∈ T)) || decide (β ∈ T))
  | _ => true
abbrev linkPred (T T' : Finset PlusFormula) : PlusFormula → Bool
  | ψ@(.untl g e) =>
      decide (ψ ∈ T) == (decide (e ∈ T') || (decide (g ∈ T') && decide (ψ ∈ T')))
  | _ => true
abbrev locCoh {Q : Type} (lab : Q → Atom → Bool) (φ : PlusFormula) (x : ProdState Q φ) : Bool :=
  decide (∀ ψ ∈ plusSubformulaClosure φ, locPred lab x.1 x.2.1 ψ = true)
abbrev untlLink (φ : PlusFormula) (T T' : ClType φ) : Bool :=
  decide (∀ ψ ∈ plusSubformulaClosure φ, linkPred T.1 T'.1 ψ = true)
abbrev coh {Q : Type} (step : Q → Q → Bool) (pend : Q → Bool) (lab : Q → Atom → Bool)
    (φ : PlusFormula) (x y : ProdState Q φ) : Bool :=
  step x.1 y.1 && pend x.1 && pend y.1 && locCoh lab φ x && locCoh lab φ y &&
    untlLink φ x.2 y.2
abbrev coh6 : ProdState Q5 chi → ProdState Q5 chi → Bool := coh step5 pend5 lab6 chi

abbrev B : PlusFormula := pa.imp XXpa.neg
abbrev C : PlusFormula := p.imp la.neg
abbrev TaL : List PlusFormula := [chi, psi2.neg, ev.neg, top, B, pa, XXpa.neg, p, la]
abbrev TbL : List PlusFormula := [chi, psi2.neg, ev.neg, top, B, XXpa, C, p, la.neg]
abbrev TcL : List PlusFormula := [chi, psi2.neg, ev.neg, top, B, XXpa.neg, Xpa, C, p, la.neg]
abbrev mkT (L : List PlusFormula) : ClType chi :=
  ⟨(plusSubformulaClosure chi).filter (fun ψ => ψ ∈ L),
    Finset.mem_powerset.mpr (Finset.filter_subset _ _)⟩
abbrev Ta : ClType chi := mkT TaL
abbrev Tb : ClType chi := mkT TbL
abbrev Tc : ClType chi := mkT TcL
abbrev Ea : Finset (ProdState Q5 chi) := Finset.univ.filter (fun x => x.1 = a5)
abbrev Prof6 (k : ℕ) : Finset (ProdState Q5 chi) := (prodPreStep coh6)^[k] Ea

theorem chi_closure_untl_only : ∀ ψ ∈ plusSubformulaClosure chi, noModalArm ψ = true := sorry

theorem coh6_liesOver : ∀ x y : ProdState Q5 chi, coh6 x y = true → step5 x.1 y.1 = true := sorry

theorem coh6_cycle_witness :
    chi ∈ Ta.1 ∧ coh6 (a5, Ta) (b5, Tb) = true ∧ coh6 (b5, Tb) (c5, Tc) = true ∧
      coh6 (c5, Tc) (a5, Ta) = true := sorry

theorem coh6_chi_propagates (x y : ProdState Q5 chi) (h : coh6 x y = true)
    (hc : chi ∈ x.2.1) : chi ∈ y.2.1 := sorry

theorem coh6_no_a_d_a (T T' T'' : ClType chi) (h1 : coh6 (a5, T) (d5, T') = true)
    (h2 : coh6 (d5, T') (a5, T'') = true) : chi ∉ T.1 := sorry

theorem coh6_chain_a_to_a_mod3 (g : ℕ → ProdState Q5 chi) (k : ℕ)
    (hg : ∀ i, i < k → coh6 (g i) (g (i + 1)) = true) (h0 : (g 0).1 = a5)
    (hchi : chi ∈ (g 0).2.1) (hk : (g k).1 = a5) : 3 ∣ k := sorry

theorem prof6_fibre_a_of_mem (k : ℕ) (T : ClType chi) (hT : chi ∈ T.1)
    (h : (a5, T) ∈ Prof6 k) : 3 ∣ k := sorry

theorem prof6_fibre_a_witness (k : ℕ) (hk : 3 ∣ k) : (a5, Ta) ∈ Prof6 k := sorry

theorem prof6_separates_gate6_pair (C P : ℕ) (hC : 3 ∣ C) (h3 : ¬ 3 ∣ (P + 1)) :
    Prof6 C ≠ Prof6 (C + (P + 1)) := sorry

theorem prof6_period_not_one (k : ℕ) (hk : 3 ∣ k) : Prof6 (k + 1) ≠ Prof6 k := sorry

theorem reach5_eventually_constant :
    ∀ k : ℕ, 4 ≤ k → (reachStep step5)^[k + 1] {a5} = (reachStep step5)^[k] {a5} := sorry

end Probe806
```

## Testing & Validation

- [ ] Both probes compile sorry-free under the guarded `lake env lean`, with no `native_decide`, no `axiom`, and every `#print axioms` line `[propext, Classical.choice, Quot.sound]` at most.
- [ ] `bash scripts/check-evidence-probes.sh` reports `PASS  all 35 wired probe(s) compile`; both probe files are git-tracked.
- [ ] The eleven Goal declarations match the Lean Challenge Statements block exactly (`lean-challenge-snapshot.sh --check 806 .`, advisory).
- [ ] `coh6_cycle_witness` is proved (non-vacuity) BEFORE `coh6_no_a_d_a` lands (git log order of the sub-step commits).
- [ ] The gate-7 mechanical check: zero non-comment hits for `WorldHistory|tpOf|cellAt|PlusTruthAt|IsSlicedStepPath` in `closure-profile-gate-rerun.lean`.
- [ ] `prof6_separates_gate6_pair` carries no threshold/modulus/clip-bound hypothesis.
- [ ] Nothing under `FormalSystem/`, `Tests/`, `docs/` changed; no `ladderRealized`/`LadderCons` declaration anywhere; `prototype/` directory gone.
- [ ] `check-module-invariants.sh`, `check-task-references.sh --quiet`, full `lake build`, and `verify-deploy.sh` all exit 0.
- [ ] The eighteenth probe's header marks gates 1 and 2 NOT ADDRESSED, gate 8 SIDESTEPPED, adequacy OPEN.

## Artifacts & Outputs

- `specs/evidence/seam-gluing-ray-product/closure-indexed-periodicity.lean` — the seventeenth wired probe (promoted prototype, seven theorems, header rewritten).
- `specs/evidence/seam-gluing-ray-product/closure-profile-gate-rerun.lean` — the eighteenth wired probe (eleven theorems, `Probe806` namespace, gate-table verdict header).
- `scripts/check-evidence-probes.sh` — two new decision rows, two new `WIRED` entries (33 → 35).
- `specs/806_set_valued_cell_quotient_index/summaries/01_closure-profile-gate-rerun-summary.md` — implementation summary with the per-gate verdict table and the named successor work (adequacy; obligations b, c, d).

## Rollback/Contingency

Each phase commits as green sub-steps, so a failed later phase leaves earlier work intact and
reverting is `git revert` of the offending sub-step commits — no destructive reset is needed. If a
Goal in Phase 3 or 4 cannot be closed as stated (for example the chain lemma turns out to need a
hypothesis the Challenge block does not carry), do NOT weaken or rename it: mark the phase
`[BLOCKED]` with what was tried and the goal state reached, keep the already-proved Goals and their
`#print axioms` lines, leave the file compiling (a blocked Goal is removed from the file, never left
as `sorry`, and is listed in the handoff's `blockers` with its verbatim signature), and return
`partial` — plan-compliance.md's escalate-rather-than-substitute route. If Phase 1's `git mv` must be
undone, `git mv` it back; the prototype path is still cited by the research report, so nothing
else references the new path until Phase 5 registers it. Should a genuine whole-tree rollback ever be
needed, follow `context/contracts/recovery.md`'s rollback rung (snapshot first via
`git-snapshot.sh 806`, then the reset) — never a bare precautionary snapshot at phase start.
