# Research Report: Task #733

**Task**: 733 - Probe the backward-dual stability summary on a backward-NONDETERMINISTIC mirror fixture (E1's hard test)
**Started**: 2026-10-09T07:02:28Z
**Completed**: 2026-10-09T07:16:35Z
**Effort**: ~40 minutes (research + compiled prototype)
**Dependencies**: 739 (declared in state.json; the E1 probe it builds on is already landed and wired)
**Sources/Inputs**:
- Codebase: `specs/evidence/seam-gluing-ray-product/backward-dual-asymmetric-fixture.lean` (E1, the template), `finite-graph-stab-summary.lean` (forward factor), `stab-fibre-is-ray-product.lean` (keystone header), `b2b-frame-constructor-branching.lean` (header), `specs/archive/710_sliced_class_incompleteness_characterization/probes/NoFiniteWidthModel.lean` (the original fixture), `scripts/check-evidence-probes.sh` (gate), `specs/archive/718_omega_sequence_decidability_full_lplus/reports/02_ranked-route-analysis.md` (R1 falsifier list), `FormalSystem/Semantics/IntNormalForm.lean`, `FormalSystem/Semantics/TaskFrame.lean`, `FormalSystem/PlusLanguage/Formula.lean`
- Verification: `lake env lean` on a full prototype of the proposed probe (compiled, sorry-free), plus a baseline run of `scripts/check-evidence-probes.sh`
- Mathlib search tools (leansearch/loogle/leanfinder/state_search): not needed -- every cited declaration was verified by compilation, which is a stronger evidence tier than an LSP lookup
- Literature: no literature source is referenced by the task; the Literature Extraction Protocol does not apply
**Artifacts**:
- `specs/733_backward_dual_mirror_fixture_branching_probe/reports/01_backward-dual-mirror-fixture.md` (this report)
- `specs/733_backward_dual_mirror_fixture_branching_probe/prototype/backward-dual-mirror-fixture.proto.lean` (compiled prototype, 550 lines, 73 declarations, 0 `sorry`)
**Standards**: report-format.md, subagent-return.md

## Executive Summary

- **Outcome: POSITIVE, prototype-verified.** On the mirror fixture (Probe710's step graph with every arrow reversed -- forward DETERMINISTIC, backward branching factor **2** at every spine state `aft (k+1)`), the backward stability operator `⊡(P p)` at a seam state is exactly "every backward root path from that state meets the `p`-set" (`pastStab_iff_allBwdPathsMeet`), decided by backward reachability alone and state-dependently: **True at every `aft` state, False at every `x` and `bef` state** (`decide_past_stab`, `decidable_past_stab`). The two-factor ray presentation is **not falsified** at the branching backward factor.
- **The backward factor genuinely branches, machine-checked.** `two_bwd_paths` exhibits two backward root paths from `aft (m+1)` that already differ at their first step (axiom-free); `bwdList_aft_succ_length` records the branching factor 2 by `rfl`. The universal quantifier over backward paths therefore does NOT collapse to one chain as it did in E1; it is closed by an induction on the spine index that handles both branches at every `aft (k+1)` with a uniform depth bound `n ≤ m + 1` (`bwd_reaches_x`).
- **A full prototype compiles today.** 550 lines, `lake env lean` in ~3 s, no errors, no warnings, no `sorry`. Its axiom record has exactly E1's shape: the backward-reachability half is choice-free (`bwd_reaches_x` at `[propext]`, `allBwdPathsMeet_iff` at `[propext, Quot.sound]`); the `⊡` theorems carry `Classical.choice` through the same upstream `FrameOver.worldHistoryOfStepPath` E1 and Probe710 name.
- **Implementation is a header-and-wiring job**: lift the prototype to `specs/evidence/seam-gluing-ray-product/backward-dual-mirror-fixture.lean` (the declared `file_scope` path), write the header the acceptance criteria demand, add one `WIRED` entry and one table row to `scripts/check-evidence-probes.sh`. One phase, one agent run.
- **No C9-style register entry applies** (that clause of the task is conditional on a negative result), and E1's "hard test is a mirror fixture, filed as a follow-up" note becomes dischargeable by pointer from the new probe's header and the gate table -- without editing the E1 probe file.
- **Honest limit to record in the header**: the mirror fixture is finitely branching backward, so the uniform bound is König-shaped; the reason the summary cannot fail here is structural (see Findings), and what remains open is only the finite computability of "all backward paths meet" when backward branching is infinite -- a device question, not a shape question, and out of this probe's scope.

## Context & Scope

- **What was researched**: whether the backward-dual finite-graph `⊡` summary (`⊡(Pp)` ↔ all backward root paths meet the `p`-set, decided by backward reachability) survives on a fixture that is time-asymmetric AND backward-nondeterministic, and how to prove it in Lean within this probe collection's constraints.
- **Hard constraints honoured**: no complexity claim; no automata or determinization; the existing `backward-dual-asymmetric-fixture` probe and every other wired probe left untouched; new probe added beside it; probe imports only `FormalSystem`, never another probe (transcription, not import).
- **Re-read of the E1 header (dispatch instruction)**: the header's "honest limit" paragraph is as the task description reports it -- Probe710's fixture is backward deterministic (`step_inv_pre`, `step_inv_x`, `step_inv_post`), so E1's backward factor is a singleton, and the header names "a **mirror** fixture, backward-branching and forward-deterministic" as the follow-up "deliberately not absorbed here". It also records the `reflectTime` trap: there is no semantic transport theorem relating `PlusTruthAt` to `PlusFormula.reflectTime`, so the mirror result cannot be obtained by reflecting E1; it must be proved directly. The prototype does exactly that.
- **Scheduling / territory**: sibling 747 (`closure_wide_quasimodel_lift_to_validity`, research phase, no `file_scope`) is dispatched this cycle; tasks 720 and 725 are `not_started` and were not dispatched this cycle. The only shared-file hazard for implementation is `scripts/check-evidence-probes.sh`; see Risks.
- **Lean readiness**: lean-lsp registered and reachable per the dispatch context; not exercised, because the compiled prototype is the stronger evidence tier for every claim below. `lake env lean` on the existing E1 probe ran clean in 2.7 s, confirming the `.olean` tree is current (`.lake/build/lib/lean/FormalSystem.olean` dated Oct 8 22:23).

## Findings

### Codebase Patterns

- **E1 is a near-verbatim template.** The whole proof architecture transfers with the `Step` relation reversed. Mapping (E1 → mirror):

  | E1 (`Probe719Backward`) | Mirror (`Probe733Mirror`) | Change |
  |---|---|---|
  | `Node.pre k / x k / post k j` | `Node.bef k j / x k / aft k` | `bef k j` = `j+1` steps before `x k`; `aft k` = spine, reached from `x k` and from `aft (k-1)` |
  | `Step.preDown, preX, xPost, postNext` | `Step.befNext, befX, xAft, aftUp` | every arrow reversed |
  | `step_inv_pre/x/post` (backward determinism) | `step_bef_inv/x_inv/aft_inv` (forward determinism) | roles swap |
  | `step_pre_inv` (two-way forward split) | `step_inv_aft` (two-way **backward** split) | the branching moves to the backward side |
  | `bwdList` singleton, `fwdList` 1-or-2 | `fwdList` singleton, `bwdList` 1-or-2 | `bwdList (aft (k+1)) = [aft k, x (k+1)]` |
  | `canon`: `pre` before, `post` after | `canon`: `bef` before, `aft` after | `aft (k + (s-t-1).toNat)` on the right |
  | `pre_fwd` (forward search to an `x`) | `aft_back` (backward search to an `x`) | the canonicity argument's branching step |
  | `post_back` | `bef_fwd` | deterministic chain |
  | `bwd_reaches_x` (one chain, `j+1` steps) | `bwd_reaches_x` (ALL chains, `≤ m+1` steps) | genuine universal; induction on spine index |
  | `allBwdPathsMeet_iff : _ ↔ ∃ k j, w = post k j` | `allBwdPathsMeet_iff : _ ↔ ∃ m, w = aft m` | True-set is the spine |
  | `stabPast_iff_post` | `stabPast_iff_aft` | identical proof shape |

- **Frame construction route** (verified by compilation): `FrameOver.ofReflectiveRegular` with *Saturation* from `TaskFrame.saturation_of_fib_finite` (`FormalSystem/Semantics/TaskFrame.lean:2222`), fibres finite via `iter`-image finiteness from `fwdList`/`bwdList` (`List.finite_toSet`), `TaskFrame.limit_of_succOrder` (`TaskFrame.lean:1591`), `exists_iter_fwd`/`exists_iter_bwd` (`IntNormalForm.lean:412,422`), `ofStepRel_of_nonneg/nonpos` (`IntNormalForm.lean:396,404`), `iter_add`/`iter_one` (`IntNormalForm.lean:154,141`), `FrameOver.instIsRegularOfReflective`, `FrameOver.ofReflectiveRegular_taskRel_eq` (`TaskFrame.lean:1495,1536`). `FrameOver.ofSlicedStep_isRegular` is unavailable, as in E1, because `Node` is infinite.
- **History identification**: `FrameOver.mem_HF_iff_adjacent` (`IntNormalForm.lean:348`) gives "every possible world is a bi-infinite step path"; `FrameOver.worldHistoryOfStepPath` (`IntNormalForm.lean:323`) builds the converse. These are the only two `Classical.choice`-carrying inputs, exactly as E1's axiom record says.
- **Operators**: `PlusFormula.somePast φ := snce top φ` (`FormalSystem/PlusLanguage/Formula.lean:143`); the backward operator is `PlusFormula.stab (PlusFormula.somePast p)`. The `snce` truth clause destructures as `⟨s', hs' : s' < s, hp, hbetween⟩` (used in `truth_Pp`). No `will`-shaped backward abbreviation exists in the tree (also recorded by sibling task 725's description).
- **Gate mechanics**: `check_probe` in `scripts/check-evidence-probes.sh` only runs `lake env lean "$file"` and reports PASS/FAIL; it does **not** scan for `sorry`. Sorry-freedom is therefore evidenced by the `#print axioms` footer (no `sorryAx`), which every probe in the collection carries. A new probe needs (a) a comment-table row under `# --- WIRED ---` and (b) a string in the `WIRED=( ... )` array; the natural insertion point for both is directly after `seam-gluing-ray-product/backward-dual-asymmetric-fixture`.
- **Collection conventions observed**: header opens with a `/- Probe NNN ... -/` block ending in `Compile-check from the repository root with: lake env lean <path>`; `import FormalSystem` only; `open FormalSystem.Syntax FormalSystem.Semantics FormalSystem.PlusLanguage` (+ `FormalSystem.Metalogic.Decidability` for `iter`/`ofStepRel`); namespace per probe; `#print axioms` footer. Task numbers in probe namespaces (`Probe719Backward`, `Probe718FiniteGraph`) are permitted because `specs/**` is exempt from the no-task-references rule.
- **Citation hygiene inherited from E1**: `decide_will` names declarations in both `Probe718FiniteGraph` and `Probe718PathQuantifier`; cite qualified.

### The Mathematics (why the result is positive, and what the branching actually tests)

- **The fixture.** Carrier `bef k j`, `x k`, `aft k`; steps `bef k (j+1) → bef k j`, `bef k 0 → x k`, `x k → aft k`, `aft k → aft (k+1)`. Every node has exactly one successor; `aft (k+1)` has exactly two predecessors (`aft k`, `x (k+1)`), all other nodes one. Every bi-infinite step path is `… bef k 1, bef k 0, x k, aft k, aft (k+1), …` for one `k` and one position of `x k` (`path_eq_canon`). `p` holds exactly at the `x` states.
- **Backward root paths from `aft m`.** At each `aft (k+1)` encountered going backward the path chooses between exiting to `x (k+1)` and continuing to `aft k`; at `aft 0` it must exit to `x 0`. So from `aft m` there are `m+1` distinct backward root paths (two are exhibited explicitly by `two_bwd_paths`), **every one of which meets an `x` within `m+1` steps** -- `bwd_reaches_x`. Hence `AllBwdPathsMeet (aft m)`. From `x k` and `bef k j` the unique backward chain runs through `bef` states forever and never meets `p` (`not_allBwdPathsMeet_x`, `not_allBwdPathsMeet_bef`).
- **The `⊡` side.** `⊡(Pp)` at `(τ, t)` iff every history through `τ.state t` at `t` has an `x` strictly before `t`; by canonicity that is iff `τ.state t` is an `aft` state (`stabPast_iff_aft`), which composes with `allBwdPathsMeet_iff` into the headline `pastStab_iff_allBwdPathsMeet`.
- **What is new relative to E1.** In E1 the universal quantifier over backward paths was discharged by exhibiting *the* chain (`bwd_reaches_x` there is a statement about one deterministic chain). Here it cannot be: the proof must close both branches of `step_inv_aft` at every spine state, and does so by induction on the spine index with the bound `n ≤ m+1` carried through. This is exactly the backward-branching machinery E1's header says it never touched. The canonicity argument likewise now routes its backward search (`aft_back`) through the two-way split.
- **Why a falsifier was not possible here, stated as analysis (not formalized, out of scope).** On any regular ℤ-frame generated by a bi-serial step relation, histories are exactly bi-infinite step paths (`mem_HF_iff_adjacent`), the restriction of a history to `(-∞, t]` is a backward root path from the seam state, and any backward root path extends to a history by forward seriality. So `⊡(Pp) ↔ AllBwdPathsMeet` is a general fact of the landed semantics, independent of branching; what a fixture can vary is only whether `AllBwdPathsMeet` is *finitely decidable*. With finite backward branching, König's lemma gives a uniform depth bound whenever all paths meet (the `m+1` here); with infinite backward branching no uniform bound need exist. The mirror fixture therefore settles the dual's **shape** at a genuinely branching backward factor; the residual question is computational and belongs to the device-selection record (`device-selection-probe.lean`), not to a further fixture probe. The header should say this plainly so the record does not spawn an open-ended chain of "harder" fixtures.
- **Relation to the finite-width obstruction.** `Probe710.not_finite_width_fmp` stands untouched: the mirror fixture, like Probe710's, has finite fibres on an infinite carrier and is not a `[Finite W]` sliced frame; nothing here bounds width or tail-period.

### External Resources

- Mathlib: `List.finite_toSet`, `Set.Finite.biUnion`, `Set.Finite.subset`, `Set.finite_singleton`, `Set.mem_biUnion`, `Int.natAbs_neg`, `Nat.succ.inj`, `Nat.succ_ne_zero`, `Nat.le_add_left`, `Nat.succ_le_succ`, `Nat.one_pos`, `Nat.succ_pos` -- all resolved by compilation on the pinned Mathlib.
- No external literature is referenced by the task and none is needed: the result is a finite-fixture instance of the landed semantics.

### Recommendations

- **Sorry-free path exists and is already compiled.** Lift `specs/733_backward_dual_mirror_fixture_branching_probe/prototype/backward-dual-mirror-fixture.proto.lean` verbatim (minus its prototype banner) to `specs/evidence/seam-gluing-ray-product/backward-dual-mirror-fixture.lean`, then replace the banner with the collection-style header. Suggested namespace: `Probe733Mirror` (already used by the prototype).
- **Header contents the acceptance criteria require** (all machine-backed by named declarations):
  1. Fixture: Probe710's graph with every arrow reversed; forward deterministic (`step_bef_inv`, `step_x_inv`, `step_aft_inv`); **backward branching factor 2 at every `aft (k+1)`** (`bwdList_aft_succ_length`, `two_preds_aft`), two distinct backward root paths from the state under test (`two_bwd_paths`).
  2. Outcome: POSITIVE and state-dependent -- `pastStab_iff_allBwdPathsMeet`; True at `aft`, False at `x` and `bef` (`past_stab_at_aft`, `not_past_stab_at_x`, `not_past_stab_at_bef`); decision `decide_past_stab` / `decidable_past_stab`.
  3. What it does to the two-factor presentation: not falsified at the backward factor where the finite-width refutation lives; the universal quantifier over backward paths is now genuinely non-singleton and is closed by `bwd_reaches_x`'s uniform bound; discharges E1's "mirror fixture filed as a follow-up" note (cite E1 by file name and declaration, not by editing it).
  4. Honest limit: finite backward branching → König-shaped bound; the open residue is finite computability under infinite backward branching, which is a device-selection matter, not a fixture matter.
  5. What it does NOT do: no width bound, no tail-period, no complexity claim, no automata/determinization, nothing beyond `⊡(Pp)` on this fixture; `not_finite_width_fmp` untouched.
  6. Axiom record (measured on the prototype): `two_bwd_paths` axiom-free; `bwd_reaches_x` `[propext]`; `allBwdPathsMeet_iff` `[propext, Quot.sound]`; `stabPast_iff_aft`, `pastStab_iff_allBwdPathsMeet`, `decide_past_stab` `[propext, Classical.choice, Quot.sound]` via `FrameOver.worldHistoryOfStepPath` (same cause as E1 and Probe710). Keep the six `#print axioms` lines as the footer.
  7. Citation hygiene: qualify `decide_will` (two namespaces).
- **Gate wiring** (`scripts/check-evidence-probes.sh`, in `file_scope`): add `"seam-gluing-ray-product/backward-dual-mirror-fixture"` to `WIRED` directly after the E1 entry, and a comment-table row in the same position summarising: `POSITIVE (backward factor, on the MIRROR fixture -- time-asymmetric AND backward-branching, factor 2 at every spine state): ... True at the aft states, False at x and bef; two distinct backward root paths from the state under test (two_bwd_paths); discharges E1's "mirror fixture filed as a follow-up" note. No automata, no width bound, no complexity claim`. Optionally amend the last clause of the **E1 table row** ("the hard test is a mirror fixture, filed as a follow-up") to point at the new entry; this edits the gate script's comment, not the E1 probe file, and is a pointer update rather than a weakening, so it is within the no-weakening rule -- but it is optional, and the implementer should re-read the script immediately before editing because of the concurrent sibling.
- **Verification**: `lake env lean specs/evidence/seam-gluing-ray-product/backward-dual-mirror-fixture.lean` (expect the six axiom lines and nothing else), then the full `bash scripts/check-evidence-probes.sh` (expect `PASS  all 26 wired probe(s) compile` -- 23 `WIRED` + 3 `WIRED_REPO` after the addition). Neither is a `lake build`; the probe lives outside the build graph, so no build-guard invocation is needed.
- **Lean Challenge Statements to pin in the plan** (signatures as in the prototype): `two_bwd_paths`, `bwd_reaches_x`, `allBwdPathsMeet_iff`, `stabPast_iff_aft`, `pastStab_iff_allBwdPathsMeet`, `decide_past_stab`, `decidable_past_stab`.
- **Plan shape**: a single phase (file lift + header + wiring + verify + scoped commit of exactly the two `file_scope` files). The prototype removes all proof risk; the remaining work is prose and a two-line script edit.
- **Out of scope but worth relaying**: task 725 (`backward_dual_stability_past_finite_graph_probe`, `not_started`) specifies the E1 experiment and carries its own subsumption clause ("IF 719 LANDS E1 FIRST, THIS TASK CLOSES AS SUBSUMED"); the landed E1 probe is Probe 719. 725 appears subsumable; closing it is a task-management action for the user/orchestrator, not for this task.

## Decisions

- **Fixture = exact mirror of Probe710's graph**, not a freshly designed branching graph. The task names "a mirror fixture", E1's header names it as the follow-up, and the exact mirror makes the backward branching the precise dual of Probe710's forward branching at `pre (k+1)`, so the two probes compare clause for clause.
- **Direct proof, no `reflectTime` transport**, per E1's recorded trap (no semantic transport theorem exists).
- **Choice-free backward half adopted.** The first prototype's `bwd_reaches_x` used `omega` for the index arithmetic and picked up `Classical.choice`; replacing `omega` with `Nat.one_pos`, `Nat.le_add_left`, `Nat.succ.inj`, `Nat.succ_ne_zero`, `Nat.succ_le_succ`, `Nat.succ_pos` brought it to `[propext]`, matching E1's record. The recommended file uses the choice-free version.
- **No general theorem attempted.** The analysis that the summary's shape is general for step-generated regular frames is recorded as analysis only; formalizing it is outside "decides nothing beyond this one fixture" and would change the probe's character.
- **No register entry.** The C9-style register clause is conditional on a negative result; the result is positive.
- **Prototype stored under the task directory** (`prototype/`), not under `specs/evidence/`, so this research dispatch touches neither `file_scope` file and leaves the implementer a clean lift.

## Risks & Mitigations

- **Concurrent sibling on the gate script.** Task 747 is dispatched this cycle with no declared `file_scope`. Mitigation: re-read `scripts/check-evidence-probes.sh` immediately before editing; stage only the two `file_scope` files by explicit path; never use `git-snapshot.sh` in reverting mode; treat an unexpected foreign modification as a stop-and-report event.
- **Header drift from the measured record.** Mitigation: the implementer re-runs `lake env lean` on the final file and copies the printed axiom lines into the header verbatim rather than carrying the prototype's figures.
- **Over-reading the result.** A positive mirror result could be cited as "the backward factor is decided". Mitigation: the header's "honest limit" and "what this does NOT do" paragraphs, as specified above; the result is one fixture and one formula shape.
- **E1 table-row amendment misread as touching a wired probe.** Mitigation: keep it optional, confine it to the comment table in the gate script, and leave the E1 `.lean` file byte-identical.
- **Linter noise.** The prototype compile produced no warnings on this pin; if the final header introduces long-line or unused-variable lints, fix forward, do not suppress.

## Tactic Survey Results

The survey was performed by compiling the prototype rather than by `lean_multi_attempt`; each row records what closed the goal in the compiled file.

| Goal | Tactic | Result | Premises/Config |
|------|--------|--------|-----------------|
| Step inverses (`step_inv_aft`, `step_bef_inv`, ...) | `cases h with ...` + `rfl`/`Or.inl`/`Or.inr` | success | constructor case split; axiom-free |
| `bwdList_aft_succ_length` (branching factor 2) | `rfl` | success | definitional |
| `two_preds_aft`, `two_bwd_paths` distinctness | `fun h => by cases h` | success | constructor disjointness; axiom-free |
| `mem_fwdList` / `mem_bwdList` | `simp [fwdList]` / `cases k <;> simp [bwdList]` | success | equation lemmas of the list functions |
| `canon_step` index arithmetic (`toNat` equalities) | `omega` | success | fine here; `Classical.choice` is acceptable in the `canon` layer |
| `canon_of_gt` | `simp [canon, not_lt.mpr h.le, h.ne']` | success | |
| `aft_back`, `bef_fwd`, `fwd_from_x`, `bwd_from_x` cast arithmetic | `push_cast; ring` / `omega` | success | |
| `bwd_reaches_x` (branching reachability, choice-free) | explicit `Nat.*` lemmas instead of `omega` | success | `Nat.one_pos`, `Nat.le_add_left`, `Nat.succ.inj`, `Nat.succ_ne_zero`, `Nat.succ_le_succ`, `Nat.succ_pos` |
| `bwd_reaches_x` with `omega` | `omega` | success but pulls `Classical.choice` | rejected for the axiom record |
| `decide` / `aesop` | not attempted | N/A | goals quantify over `ℕ → Node` and `WorldHistory`; not decidable-by-evaluation |

## Context Extension Recommendations

- **Topic**: Axiom hygiene of `omega` in choice-free probes
- **Gap**: No Lean context file records that on this pin `omega` introduces `Classical.choice` into `#print axioms`, which matters for the evidence probes whose headers advertise choice-free halves.
- **Recommendation**: Add a short note to `.claude/context/project/lean4/` (e.g. a `patterns/axiom-record-hygiene.md`) listing `omega` → use explicit `Nat` lemmas when a declaration's axiom record is part of the recorded result; cite E1 and this probe as the worked examples.

- **Topic**: Evidence-probe authoring checklist
- **Gap**: The conventions (import only `FormalSystem`, header shape, `#print axioms` footer, gate wiring in two places, gate does not scan for `sorry`) are inferable only from reading existing probes and `check-evidence-probes.sh`'s header.
- **Recommendation**: A one-page `context/project/lean4/patterns/evidence-probe-authoring.md` capturing the checklist in the Findings above.

## Appendix

- Commands run (all from the repository root):
  - `lake env lean specs/evidence/seam-gluing-ray-product/backward-dual-asymmetric-fixture.lean` -- exit 0, 2.7 s, four axiom lines as recorded in E1's header.
  - `lake env lean <scratchpad>/mirror-proto.lean` -- first pass exit 0, 3.0 s, no errors/warnings; `bwd_reaches_x` at `[propext, Classical.choice, Quot.sound]`.
  - `lake env lean <scratchpad>/mirror-ax2.lean` -- choice-free variant; after fixing one rewrite direction (`rw [← Nat.succ.inj hk']`), exit 0; `bwd_reaches_x'` at `[propext]`.
  - `lake env lean <scratchpad>/mirror-proto.lean` (final, 550 lines) -- exit 0, 3.1 s; axiom record as stated in the Executive Summary.
  - `bash scripts/check-evidence-probes.sh` (baseline, before any edit) -- exit 0, `PASS  all 25 wired probe(s) compile` (22 `WIRED` + 3 `WIRED_REPO`; 25 PASS lines counted), so the collection is green before the implementer touches the gate script.
- Files read for this report: see Sources/Inputs. The `## Lean Challenge Statements` candidates and the header checklist are in Recommendations; the declaration-level mapping is in Findings.
- Issue log: three `win` entries recorded via `issue-record.sh` (template reuse, first-pass compile, choice-free axiom record); no `issue` entries -- nothing blocking or costly arose.
