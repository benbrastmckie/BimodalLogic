# Implementation Plan: Task #815

- **Task**: 815 - Certificate sufficiency: dovetailing, realizability (the SUFFICIENCY half of realizable-type adequacy)
- **Status**: [COMPLETED]
- **Effort**: 5.5 hours
- **Dependencies**: 809 (predecessor; its certificate is restated, not imported, in this task's probe); 806 (the countdown-profile round; untouched); 761 (parent, stays `[BLOCKED]` in state; this task edits no record of it except the roadmap paragraphs that name its gate)
- **Research Inputs**: specs/815_certificate_sufficiency_dovetailing_realizability/reports/01_certificate-sufficiency-dovetailing.md
- **Artifacts**: plans/01_certificate-sufficiency-dovetailing.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md, plan-compliance.md (Statement Fidelity)
- **Type**: lean4
- **Lean Intent**: true

## Overview

The research round did not stop at scoping: it compiled all three open items of the dispatch as
the twenty-third wired probe, `specs/evidence/seam-gluing-ray-product/certificate-sufficiency-dovetailing.lean`
(namespace `Probe815`, 1655 lines, thirteen printed theorems, axioms
`[propext, Classical.choice, Quot.sound]` on every one, tracked by commit `aba02ff69`). (a) The
dovetailing argument is a theorem over an arbitrary finite graph (`exists_dovetail_chain`), and its
forward instance for the compiled certificate is forward-only sufficiency, labelled as such
(`forward_chain_of_certAdm`). (b) Condition (3)'s `|R|` bound is derived, not assumed
(`eu_mem_lfp_path_le_card`), and nothing consumes it. (c) The backward arm fails for the compiled
relation, compiled: `sufficiency_refuted` is the section-6 claim with its quantifiers as stated and
it is false, on `R3 = {x0, x1, x2}` over `(⊤ S a1) ∧ (⊤ S a2)`; the repair is the one arm `coh`
lacks (`cohBi = coh && snceLink`, the strict-since link `linkPredB`), under which the certificate
IS sufficient at the label level (`realizes_of_certAdm_cohBi`), at no cost on a `snce`-free
closure (`cohBi_eq_coh_of_snce_free`).

What the research round left on the table is one gap and three pieces of follow-through, and this
plan does exactly those. The gap: **the two-sided theorem has no non-vacuous compiled instance**.
Every fixture in the collection exercises at most one arm (`chi`: `untl` only; `phi3`: `snce`
only), so nothing yet shows that `certAdm lab (cohBi ...) R = true` is satisfiable by a non-empty
set whose members carry both an `untl` and a `snce` obligation -- and a sufficiency theorem for a
condition nothing satisfies would be the "antecedent failure" the repository's standing non-vacuity
obligation exists to forbid. Phase 1 lands that fixture: `phi4 = (⊤ U b) ∧ (⊤ S a1)` over a
three-state object `2 → 0 → 1` with self-loops at `2` and `1`, the candidate set `R4 = {y0, y1, y2}`,
`cert_accepts_R4`, and the realized instance `realizes_y0_R4` as a corollary of the two-sided
theorem. **The fixture was compiled and measured at plan time** (see `## Lean Challenge
Statements`): `certAdm lab4 cohBi4 R4` evaluates to `true`, so Phase 1's risk is proof labour, not
a false statement. The follow-through: the probe's header and guard decision row carry the new
rows (Phase 2); the roadmap paragraphs that still say sufficiency is NOT STARTED and gate the
parent on it are rewritten to the verdict (Phase 3); and the complete gate set, the summary and
the return close the task (Phase 4).

Definition of done: the probe compiles sorry-free with seventeen printed theorems, every one on
`[propext, Classical.choice, Quot.sound]`; the six pinned signatures below are byte-unchanged; the
guard still reports `all 41 wired probe(s) compile`; `specs/ROADMAP.md` records the verdict and the
two rulings it carries; nothing under `FormalSystem/` or `Tests/` is touched; one summary.

**What this plan does NOT do.** It does not claim semantic adequacy: every realizability statement
here is LABEL-LEVEL (a bi-infinite `cohR`-chain fulfilling every `untl`/`snce` obligation), and the
step from a fulfilling label chain to membership of a type in a cell is standing obligation (d),
untouched. It does not exercise `certStab`/`certBox`: `phi4`'s closure has no `box` or `stab`
member, so gate 8 stays SIDESTEPPED and the `stab` fixture stays a separate deliverable. It does
not upstream the generic existential fixpoint or the dovetailing theorem into `FormalSystem/`
(research Recommendation 6 -- a move, a separate task). It does not state `ladderRealized`,
`LadderCons`, `ladderCons_localRun` or any same-named weaker substitute, hence no `LadderCons`
without the `box`/`stab` clause. It does not restate section 7 of the predecessor's report, and it
does not edit that report: the false mirror sentence is on the issue log (`minor`), and the correct
sentence goes into the roadmap and the summary.

### Research Integration

- **Recommendation 1 (adopt `cohBi` by name; pin the two headline signatures)** is done here in
  the plan: `## Lean Challenge Statements` pins `realizes_of_certAdm_cohBi` and
  `sufficiency_refuted` verbatim, together with `exists_dovetail_chain`,
  `eu_mem_lfp_path_le_card`, `forward_chain_of_certAdm` and `cohBi_eq_coh_of_snce_free`, so that
  none of the six can drift into a same-named weaker statement while Phase 1 appends to the file.
  Route B's relation is `cohBi`, named as such in the roadmap paragraph Phase 3 writes.
- **Recommendation 2 (never restate the mirror sentence)**: the roadmap paragraph and the summary
  carry the correct sentence -- the mirror holds for `cohBi` through `link_snce`; for `coh` there
  is a compiled counterexample -- and no artifact of this task cites `snce_propagates_to_start` as
  a product-layer fact.
- **Recommendation 3 (a fixture carrying BOTH arms)** is Phase 1, the plan's one proof phase. The
  report names it as "the next deliverable" and separates it from the `stab` fixture gate 8 needs;
  this plan keeps them separate and lands only the first.
- **Recommendation 4 (say "label-level" everywhere)**: the Overview, Phase 2's header edit,
  Phase 3's roadmap text and Phase 4's summary each carry the qualifier, and the summary names the
  semantic step as the remaining adequacy obligation.
- **Recommendation 5 (both arms stay existential)**: `cohBi4` is `cohBi`, a one-step Hintikka link
  in each direction; no `ULive`/`SLive`/`Disch`/`DischBwd` appears in anything this plan adds, and
  Phase 4 greps for them.
- **Recommendation 7 (track the probe by a scoped commit)**: already done by the research round
  (`aba02ff69`); Phase 1's edits land on an already-tracked file, so the guard's `untracked` class
  cannot fire. Each phase commits through `.claude/scripts/git-commit-scoped.sh` with an explicit
  file list.
- **Findings 6 (the bound)**: `eu_mem_lfp_path_le_card` is pinned and consumed by nothing; this
  plan neither drops the phrase from condition (3)'s prose nor builds on it.
- **Tactic survey (report)**: `decide` only on concrete closure memberships, concrete `cohBi4` edge
  facts and bounded quantifications over ONE closure type; never over `R4` or `ClType phi4`; never
  `native_decide`; `decide_eq_true`/`of_decide_eq_true` rather than `simpa [argsOf]` for the
  `decide (...) = true` conversions; `rw [splice, if_neg h]; simp` shapes are not needed here.
  The Mathlib facts recorded under External Resources (`le_or_gt`/`lt_or_ge` at this pin,
  implicit-argument `List.mem_cons_self`, `omega` on `Int.toNat`) apply if `realizes_y0_R4` is
  unfolded, which it must not be -- it is a corollary, see Phase 1.

### Prior Plan Reference

No prior plan for this task. The calibration is the predecessor's
`specs/809_realizable_type_adequacy_countdown_profile/plans/01_realizable-type-certificate.md`:
six phases at one to two hours each ran to plan, with two recorded deviations this plan
pre-empts -- the guard prints `WIRED + WIRED_REPO` (so 41 here, not 40), and
`lean-challenge-snapshot.sh --check` exits 71 when no manifest exists, in which case the sanctioned
substitute is a declaration-by-declaration diff of the file against the `## Lean Challenge
Statements` block. Its discipline of compiling the Challenge block at plan time is reused and
extended: this plan's block was not only compiled but `#eval`-measured, so Phase 1's Scope
Hypothesis is a measurement rather than a hand computation.

### Roadmap Alignment

The dispatch context carries no `roadmap_path` and no `roadmap_flag`, so the mandated
snapshot/update wrap phases are not generated. `specs/ROADMAP.md` was nonetheless read at plan
time because it names this task, in four places, as THE critical path and as the gate on `761`
("do not dispatch 761 until 815 returns"; "NOT STARTED; filed as 815"). Leaving those paragraphs
standing after this task completes would misdirect the next `/orchestrate` run, so Phase 3
rewrites exactly those paragraphs to the verdict. This is a content decision, recorded here, with
the precedent of the closed-out predecessor record whose own phase 2 made a scoped roadmap edit
through a task commit; it is not a `user_decision`, because the roadmap's own stated purpose
("batch ordering and the rulings that gate it") is what the verdict changes. Items advanced: the
Stage 1 critical path (sufficiency returned; `761` costable); the `cohBi` ruling; the label-level
qualification that `761` inherits. Items NOT advanced and said so: gate 8 (`stab` fixture), gates
1, 2, 3, 9, obligations (b), (c), (d).

## Goals & Non-Goals

**Goals** (the identifier set equals the ten `theorem` declarations in
`## Lean Challenge Statements`; all live in
`specs/evidence/seam-gluing-ray-product/certificate-sufficiency-dovetailing.lean`, namespace
`Probe815`):

Pinned -- already compiled by the research round, re-verified byte-unchanged at the end of this task:
- `eu_mem_lfp_path_le_card`
- `exists_dovetail_chain`
- `forward_chain_of_certAdm`
- `cohBi_eq_coh_of_snce_free`
- `sufficiency_refuted`
- `realizes_of_certAdm_cohBi`

New -- landed by Phase 1:
- `phi4_closure_both_arms`
- `y0_carries_both`
- `cert_accepts_R4`
- `realizes_y0_R4`

Plus, not Goals (definitions carrying no statement): `bA`, `atomB`, `untB`, `phi4`, `step4`,
`lab4`, `cohBi4`, `mkT4`, `U0`/`U1`/`U2`, `y0`/`y1`/`y2`, `R4`, and the supporting membership
lemmas (`mem_R4`, `y0_mem_R4`, `y1_mem_R4`, `y2_mem_R4`) and the six per-condition lemmas
(`certLoc_R4` ... `certBox_R4`), which are free to exist in the file exactly as `mem_R3` and
`certLoc_R3` ... `certBox_R3` do. The names `a1A`, `atom1`, `topF`, `sig1`, `Q3` and `pend3` are
REUSED from the existing fixture, not redefined: the Challenge block below restates them only so
that it type-checks standalone.

**Non-Goals**:
- Any semantic realizability claim: no declaration added mentions `PlusTruthAt`, `tpOf`, `cellAt`,
  `anchorCells`, a `WorldHistory`, a world, a model or a cell; obligation (d) is untouched.
- Exercising `certStab`/`certBox`, or any fixture whose closure has a `stab` or `box` member; gate 8
  stays SIDESTEPPED and is not reported as passed. Gates 1, 2, 3 and 9 are untouched.
- Upstreaming `euStep` ... `eu_mem_lfp_path_le_card` or `LinkStep` ... `exists_dovetail_chain`
  into `FormalSystem/`; any edit under `FormalSystem/`, `Tests/`, `docs/`, or the RaySummary README.
- Any edit to the predecessor's report, to the parent task's own records, or to the lean4 context
  tree (the research round's Context Extension Recommendation needs its own commit outside this
  repository).
- Route A; any transplant of `ULive`, `SLive`, `Disch`, `DischBwd`; any universal-strength
  fulfilment condition; any backward propagation theorem claimed for `coh`.
- Any declaration named `ladderRealized`, `LadderCons`, `ladderCons_localRun`, or a same-named
  weaker substitute; no `LadderCons` is stated, hence none without the `box`/`stab` clause.
- A second new probe file: the fixture is appended to the existing probe, because probes do not
  import probes and a new file would restate a thousand lines to add two hundred.
- A tuple coordinate, a modulus, a threshold, the `sig.preds` translation of `evRay`, or any
  re-derivation of the finiteness of the SET of cells.
- Dispatching, re-costing or re-planning `761`; Phase 3 only records what `761` now inherits.

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| `cert_accepts_R4` is false because the plan-time fixture is wrong | H | L | Measured, not computed: the Challenge block compiled standalone at plan time and `#eval certAdm lab4 cohBi4 R4` printed `true`, with the six conditions individually `true` and the four intended `cohBi4` edges `true`. Phase 1 re-runs the same `#eval`s in-file before proving anything; a mismatch blocks the phase, it never prompts a weaker statement. |
| `realizes_y0_R4` is closed by a hand-built chain or by `decide` instead of as the corollary of `realizes_of_certAdm_cohBi` | H | M | The whole point of the Goal is that it instantiates the two-sided theorem non-vacuously; Phase 1's task says `exact realizes_of_certAdm_cohBi step4 pend3 lab4 R4 cert_accepts_R4 y0 y0_mem_R4` (modulo the `cohBi4` unfolding) and Phase 1's verification greps the proof body for the theorem name. `plan-compliance.md` forbids the substitution. |
| One of the six pinned signatures drifts while Phase 1 appends to the file (an added hypothesis, a specialised quantifier, a dropped `0 < n`) | H | L | The signatures are pinned below; Phase 4 diffs each against the block; `plan-compliance.md` Statement Fidelity governs; a genuine defect in a pinned statement blocks the phase and is raised, never repaired by editing the block. |
| `decide` is attempted on a goal quantifying over `R4` or over `ClType phi4` and hits `maxRecDepth` or times out | M | M | The six conditions are proved by hand through `mem_R4`, exactly in the shape of `certLoc_R3` ... `certBox_R3`; `decide` closes concrete memberships, concrete `cohBi4 yi yj` facts and bounded quantifications over ONE closure type (`phi4_closure_both_arms`), nothing else; no `native_decide`, no `maxRecDepth`. |
| `realizes_y0_R4` is read as semantic adequacy discharged, or `cert_accepts_R4` as gate 8 progress | H | M | Header, roadmap text and summary all say "label-level" and "stab/box-free closure; gate 8 still SIDESTEPPED"; Phase 2 adds a "What this does NOT say" bullet for exactly this reading. |
| The roadmap edit overreaches -- rewrites ordering it has no verdict on, or removes the still-true gate-8/gate-3 sentences | M | M | Phase 3 enumerates the paragraphs it may touch and the sentences it must keep; its verification is a diff read-through against that list; everything outside the list is out of scope for the edit. |
| The guard's printed total is misread as a regression (`41` when `WIRED` has 40) | L | M | `WIRED` holds 40 entries and `WIRED_REPO` one, both counted at plan time; no entry is added by this task (same file), so the guard prints `all 41 wired probe(s) compile` before and after. |
| `lean-challenge-snapshot.sh --check 815 .` exits 71 for want of a manifest | L | H | Advisory only; the predecessor's recorded substitute applies -- a mechanical declaration-by-declaration diff of the probe against the Challenge block, reported in the summary as the check actually run. |
| A seventh mechanism exists that none of this exercises | H | M | The standing lesson binds: a gate probing one coordinate certifies one coordinate only; this plan changes no gate verdict and says so in every artifact. |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2, 3 | 1 |
| 3 | 4 | 2, 3 |

Phases within the same wave can execute in parallel. Phases 2 and 3 touch disjoint files (the
probe and the guard script; the roadmap) and both describe what Phase 1 landed, so they share a
wave; Phase 4 observes all of them.

### Phase 1: The Two-Arm Fixture and the Non-Vacuous Instance of the Two-Sided Theorem [COMPLETED]

**Goal**: Give `realizes_of_certAdm_cohBi` a compiled instance whose candidate set is accepted
with BOTH arms non-vacuous -- a closure carrying an `untl` and a `snce` member, every member of
the set carrying both -- so that the strengthened certificate is shown satisfiable where the
compiled one's refutation lives, and the two-sided theorem is not a theorem about an empty
condition.

**Tasks**:
- [x] In `specs/evidence/seam-gluing-ray-product/certificate-sufficiency-dovetailing.lean`, after
  `end Full` and before the `#print axioms` block, open a section
  `/-! ## Non-vacuity of the two-sided theorem: a fixture carrying BOTH arms -/` and define, with
  the bodies exactly as the Challenge block spells them: `bA`, `atomB`, `untB` (`⊤ U b`), `phi4`
  (`untB.and sig1`), `step4` (`2 → 2`, `2 → 0`, `0 → 1`, `1 → 1`, nothing else), `lab4` (`a1`
  true at `2`, `b` true at `1`), `cohBi4 := cohBi step4 pend3 lab4 phi4`, `mkT4` (a `filter`, as
  `mkT3`), `U0 = mkT4 [phi4, untB, sig1, topF]`, `U1 = mkT4 [phi4, untB, sig1, topF, atomB]`,
  `U2 = mkT4 [phi4, untB, sig1, topF, atom1]`, `y0 = (0, U0)`, `y1 = (1, U1)`, `y2 = (2, U2)`,
  `R4 = {y0, y1, y2}`. Reuse `a1A`, `atom1`, `topF`, `sig1`, `Q3`, `pend3`; do not redefine them.
- [x] Re-run the plan-time measurements in-file and keep the one `#eval` the collection's
  discipline keeps: `#eval (plusSubformulaClosure phi4).card` (expected `9`); confirm, by `#eval`
  during development and then by the theorems, that `cohBi4 y2 y2`, `cohBi4 y2 y0`, `cohBi4 y0 y1`,
  `cohBi4 y1 y1` are `true` and that `U0.1.card = 4`, `U1.1.card = 5`, `U2.1.card = 5`.
- [x] Prove `mem_R4`, `y0_mem_R4`, `y1_mem_R4`, `y2_mem_R4` as `mem_R3` and its three corollaries
  are proved.
- [x] Prove `phi4_closure_both_arms` by `decide` (one bounded quantification over the nine-member
  closure) and `y0_carries_both` by `decide`.
- [x] Prove `certLoc_R4`, `certBiInf_R4`, `certFwd_R4`, `certBwd_R4`, `certStab_R4`, `certBox_R4`
  by hand through `mem_R4`, in the shape of the `R3` block. `certFwd_R4`: the only `untl` member
  is `untB`; `y1` is in the fixpoint through `eu_mem_lfp_iff` with witness `y1` (event `atomB`);
  `y0` through witness `y1`; `y2` through witness `y0` (guard `topF` and `y0 ∈` the fixpoint) --
  a two-step discharge, which is the point of the fixture. `certBwd_R4`: the only `snce` member is
  `sig1`; `y2` through witness `y2` (event `atom1`); `y0` through witness `y2`; `y1` through
  witness `y0` (guard, and `y0 ∈` the fixpoint). `certStab_R4`/`certBox_R4` through
  `phi4_closure_both_arms`'s third conjunct exactly as `certStab_R3`/`certBox_R3` go through
  `phi3_closure_untl_box_stab_free`.
- [x] Prove `cert_accepts_R4` as the conjunction, and `realizes_y0_R4` AS THE COROLLARY:
  `realizes_of_certAdm_cohBi step4 pend3 lab4 R4 cert_accepts_R4 y0 y0_mem_R4` (unfolding
  `cohBi4` if the elaborator needs it). Do not build the chain by hand and do not `decide` it.
- [x] Append four `#print axioms` lines (`phi4_closure_both_arms`, `y0_carries_both`,
  `cert_accepts_R4`, `realizes_y0_R4`), bringing the block from thirteen lines to seventeen.
- [x] Commit (explicit file list: the probe).

**Timing**: 2 hours

**Depends on**: none

**Verification Tier**: local

**Commit Mode**: per-substep

**Scope Hypothesis**: `plusSubformulaClosure phi4` has 9 members; `U0`/`U1`/`U2` have 4/5/5
members; exactly the four edges `y2→y2`, `y2→y0`, `y0→y1`, `y1→y1` are `cohBi4`-edges among the
seven pairs tried (`y0→y0`, `y1→y0`, `y0→y2` are not); the six conditions and `certAdm lab4
cohBi4 R4` are all `true`. These are MEASURED figures from a standalone `lake env lean` compile of
the Challenge block at plan time (2.7 s wall-clock, exit 0, ten `declaration uses 'sorry'`
warnings, no other diagnostic), not hand computations and not carried from another record;
confirm by re-running the same `#eval`s in-file before proving the Goals. The `9` is the one
`#eval` kept in the committed file.

**Tier Justification**: `bash .claude/scripts/lake-build-guard.sh build --timeout 600 -- env lean specs/evidence/seam-gluing-ray-product/certificate-sufficiency-dovetailing.lean` exiting 0 with zero errors and zero warnings is the complete covering check -- the phase appends to one standalone probe that no library module imports, so it has no blast radius beyond the file.

**Files to modify**:
- `specs/evidence/seam-gluing-ray-product/certificate-sufficiency-dovetailing.lean` - the two-arm fixture section, its ten supporting declarations, the four Goals, four `#print axioms` lines

**Verification**:
- The single-file compile above exits 0, zero `sorry` (`bash .claude/scripts/lean-sorry-census.sh` reports 0 for the file), zero warnings; seventeen `#print axioms` lines each at most `[propext, Classical.choice, Quot.sound]`; `grep -c native_decide` is 0; `grep -c maxRecDepth` is 0; `grep -c "^axiom "` is 0.
- The `#eval` prints `9`; the development-time `#eval`s matched the Scope Hypothesis before any Goal was proved; a mismatch blocked the phase.
- `grep -n "realizes_of_certAdm_cohBi" ` over the proof body of `realizes_y0_R4` matches: the Goal is the theorem's instance, not a re-proof.
- No `decide` is applied to a goal quantifying over `R4` or over `ClType phi4`: reviewed by reading each `decide` site, and mechanically by `grep -c "decide$"` on the six condition lemmas being 0 (they are hand proofs through `mem_R4`).
- The four new signatures and the six pinned ones match the Challenge block byte for byte modulo whitespace (`diff` of each declaration's statement against the block).
- `grep -n "a1A\|atom1\|topF\|sig1\|Q3\|pend3" ` over the new section shows uses only, never a second `def` of any of them (a duplicate would fail to compile, which is the self-check).

**Verification notes (run 2026-10-17, this dispatch)**: single-file compile through the guard exit 0, zero errors, zero warnings; dev-time `#eval`s matched the Scope Hypothesis exactly before any Goal was proved (`9`; `(true, true, true, true, false, false, false)`; `(4, 5, 5)`; six conditions `true`; `certAdm` `true`); seventeen `#print axioms` lines all `[propext, Classical.choice, Quot.sound]`; `lean-sorry-census.sh` 0; `^axiom ` 0; `realizes_y0_R4`'s body is `realizes_of_certAdm_cohBi step4 pend3 lab4 R4 cert_accepts_R4 y0 y0_mem_R4`; the ten Goal statements match the Challenge block; no second `def` of a reused name. Two mechanical criteria read substantively rather than literally, recorded on the issue log (minor): `native_decide`/`maxRecDepth` each match once, in the pre-existing header sentence that says neither occurs, with no code use; `certLoc_R4` closes its three per-member concrete `locCoh` goals by `decide` exactly as `certLoc_R3` does, and no `decide` is applied to a goal over `R4` or `ClType phi4`.

---

### Phase 2: Header and Guard Decision Row [COMPLETED]

**Goal**: Make the probe's header and the guard's decision row say what the file now proves --
that the two-sided theorem has a compiled, two-arm, non-vacuous instance -- without letting
either say more than that.

**Tasks**:
- [x] In the probe's header docstring: (i) add to the verdict paragraph one sentence that the
  strengthened certificate is SATISFIABLE with both arms live (`cert_accepts_R4` on
  `phi4 = (⊤ U b) ∧ (⊤ S a1)`, every member of `R4` carrying both obligations) and that
  `realizes_y0_R4` is `realizes_of_certAdm_cohBi`'s instance there; (ii) in `## The figures,
  confirmed in the file rather than carried`, add `phi4`'s closure cardinality (9), the three type
  cardinalities (4/5/5), and the four `cohBi4` edges, each named with the theorem or `#eval` that
  confirms it; (iii) in `## What this does NOT say`, add one bullet: the two-arm instance is
  LABEL-LEVEL like everything else here, its closure has no `box` or `stab` member, so it exercises
  neither `certStab` nor `certBox` and gate 8 stays SIDESTEPPED; it shows the repair is not
  vacuous, not that adequacy is discharged. Leave `## Gates` unchanged.
- [x] In `scripts/check-evidence-probes.sh`, in this probe's boxed decision-row comment block
  (the block directly above `WIRED=(`, beginning
  `# seam-gluing-ray-product/certificate-sufficiency-dovetailing | SUFFICIENCY, SPLIT`), add the
  non-vacuity rows after the `cohBi_eq_coh_of_snce_free` clause -- the strengthened certificate
  accepts a two-arm set (`cert_accepts_R4`) and the two-sided theorem has a compiled instance on
  it (`realizes_y0_R4`) -- and change `thirteen printed theorems` to `seventeen printed theorems`.
  Add NO `WIRED` entry: the probe is already the fortieth.
- [x] `bash -n scripts/check-evidence-probes.sh`; compile the probe once more (the header is a
  docstring and a malformed one is a compile error).
- [x] Record on the issue log anything that arose in Phases 1-2, or attest in the phase notes that
  nothing did beyond the plan-time entry already logged.
- [x] Commit (explicit file list: the probe, the guard script).

**Timing**: 1 hour

**Depends on**: 1

**Verification Tier**: local

**Commit Mode**: per-substep

**Scope Hypothesis**: the guard's `WIRED` array holds 40 entries and `WIRED_REPO` 1 before and
after this phase (counted at plan time with
`sed -n '/^WIRED=(/,/^)/p' scripts/check-evidence-probes.sh | grep -c '^  "'`); the probe's
`#print axioms` block holds 17 lines after Phase 1 (13 counted at plan time, plus Phase 1's four).
Re-count both before editing the decision row's figure rather than trusting this.

**Tier Justification**: the single-file probe compile exiting 0 (the header is Lean docstring text) together with `bash -n scripts/check-evidence-probes.sh` exiting 0 is the complete covering check -- the guard edit is inside a comment block, adds no array entry, and no other file reads either edit.

**Files to modify**:
- `specs/evidence/seam-gluing-ray-product/certificate-sufficiency-dovetailing.lean` - header docstring only
- `scripts/check-evidence-probes.sh` - the probe's decision-row comment block only

**Verification**:
- Probe compile exits 0, zero warnings; `bash -n scripts/check-evidence-probes.sh` exits 0.
- `git diff -- scripts/check-evidence-probes.sh` touches only lines beginning with `#` inside this probe's block; `sed -n '/^WIRED=(/,/^)/p' scripts/check-evidence-probes.sh | grep -c '^  "'` still prints 40.
- `grep -n "label-level\|LABEL-LEVEL" ` on the header matches the new bullet; `grep -n "gate 8" ` on the header still reads SIDESTEPPED; `grep -c "seventeen" scripts/check-evidence-probes.sh` is at least 1 within the block and `thirteen` no longer appears in it.
- `grep -n "snce_propagates_to_start" ` on the header matches only the existing `## What was asked` sentence that quotes the predecessor's claim as the thing refuted -- never a new sentence asserting it.

**Verification notes (run 2026-10-17, this dispatch)**: probe recompile through the guard exit 0, zero diagnostics, seventeen `#print axioms` lines; `bash -n scripts/check-evidence-probes.sh` exit 0; `git diff -- scripts/check-evidence-probes.sh` changes comment lines only, inside this probe's block; `WIRED` 40 and `WIRED_REPO` 1 before and after (re-counted); `#print axioms` lines 17 (re-counted); `seventeen` 1 and `thirteen` 0 in the block; header `LABEL-LEVEL` matches the new bullet, `gate 8` still reads SIDESTEPPED, `snce_propagates_to_start` matches only the pre-existing `## What was asked` quotation. Carried-figure honesty in the header: the type cardinalities 4/5/5 and the three non-edges are named as development-time `#eval` measurements re-confirmed by no theorem; the four edges are closed by `decide` inside the theorems that use them. Issue log for Phases 1-2: one `win` (Scope Hypothesis confirmed in-file) and one `minor` issue (two over-strict mechanical criteria) recorded as they arose; nothing further arose.

---

### Phase 3: The Roadmap Verdict and the Two Rulings the Parent Inherits [COMPLETED]

**Goal**: Rewrite the four places in `specs/ROADMAP.md` that still describe sufficiency as NOT
STARTED and gate `761` on it, so the next `/orchestrate` run reads the verdict rather than the
question -- and nothing else in that file.

**Tasks**:
- [x] Read `specs/ROADMAP.md` in full first; the four edit sites are, by their current opening
  text: (A) the `## Run these next` code block's line `/orchestrate 815 --hard --lit`; (B) the
  two paragraphs beginning `**The gate is now SUFFICIENCY, filed as \`815\`.**` and `What \`809\`
  did **not** discharge`; (C) the paragraph beginning `**The likeliest way \`815\` fails is the
  backward arm**` and the paragraph beginning `` `761` reads as dispatchable and **is not** ``;
  (D) in `## Next batches`, the Stage 1 lines for `815` and `761`, and in the Stage 1 narrative
  bullet the passage beginning `**What remains, and what gates everything after it: sufficiency**`
  together with the `761` bullet's sentence `Substantively it waits on the **sufficiency verdict**
  above, now owned by \`815\``.
- [x] (A): replace the `815` line with `/orchestrate 761 --hard --lit` and a comment naming it the
  critical path, now costable, with its relation `cohBi`.
- [x] (B): replace with one paragraph headed `**SUFFICIENCY RETURNED (\`815\`, 2026-10-17).**`
  stating, with theorem names: the dovetailing argument is a theorem (`exists_dovetail_chain`);
  forward-only sufficiency holds for the compiled relation (`forward_chain_of_certAdm`, labelled);
  the two-sided claim for `coh` is REFUTED (`sufficiency_refuted`, on
  `R3` over `(⊤ S a1) ∧ (⊤ S a2)`, backward arm only); the repair is the strict-since link
  (`cohBi`), under which the certificate IS sufficient at the LABEL level
  (`realizes_of_certAdm_cohBi`), at no cost on a `snce`-free closure
  (`cohBi_eq_coh_of_snce_free`), with a compiled two-arm non-vacuous instance (`cert_accepts_R4`,
  `realizes_y0_R4`); condition (3)'s `|R|` bound is derived (`eu_mem_lfp_path_le_card`). Then the
  rulings: Route B's relation is `cohBi`, by name; no backward propagation theorem is ever to be
  claimed for `coh`, and the predecessor report's section-7 mirror sentence is false for it; both
  arms stay existential (`ULive`/`SLive` remain the wrong strength); realizability here is
  label-level, and the semantic step (obligation (d)) is what remains of adequacy. Keep the
  following `Also still open from that round: **gate 8 stays SIDESTEPPED**` paragraph verbatim.
- [x] (C): replace the first paragraph with the realized outcome in two sentences (the backward
  arm did fail, compiled, and was repaired by strengthening the relation rather than by a mirror
  claimed from `coh`; the forward-only result is labelled forward-only), keeping the probe's
  quoted phrase. Replace the `761` paragraph: its edges are discharged AND the sufficiency verdict
  is in, so it is now costable; it inherits the `cohBi` ruling and the label-level qualification;
  the infrastructure-repair sentence about `810`, `812`, `813`, `814` stays as it is.
- [x] (D): remove the Stage 1 `/orchestrate 815` line; change `761`'s comment to say sufficiency
  returned and the relation is `cohBi`; rewrite the narrative passage and the `761` bullet's
  sentence to the same verdict in compact form, keeping every sentence about gates 8, 3, 1, 2, 9,
  `anchorCells_ncard_le` and the declined R2 alternative verbatim.
- [x] Do not touch Stages 2-4, the coverage appendix, the guardrails paragraph, or the "Not on
  the critical path" paragraph. Update the `last edited` date in the first line only if the day
  differs from the one already there.
- [x] Commit (explicit file list: `specs/ROADMAP.md`).

**Timing**: 1 hour

**Depends on**: 1

**Verification Tier**: prose

**Commit Mode**: per-substep

**Scope Hypothesis**: exactly four regions of `specs/ROADMAP.md` name this task's gate (listed in
the first task above, located at plan time by reading the file); confirm by
`grep -n "815" specs/ROADMAP.md` before editing and compare the hit list against the four
regions -- a hit outside them is reviewed, not silently rewritten.

**Tier Justification**: every touched path lies under `specs/**`, so the honest covering check is the `prose` row's diff read-through of `git diff -- specs/ROADMAP.md` against the four enumerated regions (plan-format.md's `__FULL_SWEEP__` sub-case (a): `specs/**` is the task-reference lint's own exempt tree and doc-lint has no bearing on it).

**Files to modify**:
- `specs/ROADMAP.md` - the four regions enumerated above, nothing else

**Verification**:
- `git diff -- specs/ROADMAP.md` read through hunk by hunk: every hunk lies inside one of the four regions; the gate-8, gate-3, gates-1/2, gate-9, `anchorCells_ncard_le` and R2 sentences survive verbatim (`grep -c` each phrase before and after agree).
- `grep -n "NOT STARTED" specs/ROADMAP.md` matches no line about sufficiency or `815`.
- `grep -n "snce_propagates_to_start" specs/ROADMAP.md` either matches nothing or matches only a sentence saying the mirror claim through it is false for `coh`.
- `grep -n "label-level\|label level" specs/ROADMAP.md` matches the new paragraph.
- `grep -n "do NOT dispatch\|Do not dispatch it until" specs/ROADMAP.md` no longer matches a sentence gating `761` on `815`.

**Verification notes (run 2026-10-17, this dispatch)**: `grep -n "815" specs/ROADMAP.md` before editing returned nine hits; eight lie in the four enumerated regions and the ninth (line 196, `**Adequacy — SUFFICIENCY is the open gate, owned by \`815\`.**`) is the heading of the same Stage 1 narrative bullet whose passage region (D) names -- reviewed and rewritten to the verdict as part of that bullet rather than left contradicting it. `git diff -- specs/ROADMAP.md` read through hunk by hunk: seven hunks, every one inside regions (A)-(D). The gate-8, gate-3, gates-1/2, gate-9, `anchorCells_ncard_le`, R2 and "one coordinate" sentence counts agree before and after (1/1/2/3/1/1/1/2). `NOT STARTED` matches no sufficiency or `815` line (its one remaining hit is an unrelated task record). `snce_propagates_to_start` matches only the sentence saying the mirror claim through it is false for `coh`. `label-level` matches the new paragraph. No `do NOT dispatch`/`Do not dispatch it until`/`Do not batch it until` sentence gating `761` on `815` remains. The `last edited` date already read 2026-10-17 and was left as is. Stages 2-4, the coverage appendix, the guardrails paragraph and the "Not on the critical path" paragraph are untouched. Nothing arose for the issue log in this phase.

---

### Phase 4: The Complete Gate Set, Summary, Return [COMPLETED]

**Goal**: Discharge the complete gate set on the task's whole edit set, write the summary with
the label-level qualifier and the carried-figure note, and return `implemented` with the parent
untouched in state.

**Tasks**:
- [x] Run every command under **Verification** below, checking each exit status, never only its
  output; detached long runs use a bounded waiter per `context/patterns/bounded-build-waiter.md`.
- [x] Diff the ten Goal declarations' statements against `

**Verification notes (run 2026-10-17, this dispatch; the complete set DEFERRED to the batch stage per the dispatch's `## Batch Gate Deferral` directive, this field left `full` as written)**: the scoped tier actually run -- `scripts/check-evidence-probes.sh` exit 0 (`all 41 wired probe(s) compile`, this probe `PASS`); `bash -n scripts/check-evidence-probes.sh` exit 0; `scripts/check-module-invariants.sh` exit 1 on `INV` only (three stale generated module-inventory blocks in `README.md`, `FormalSystem/README.md`, `FormalSystem/Metalogic/README.md`, none touched by this task, which added no module -- concurrent sibling drift, recorded on the issue log as a gate collision; `C9` PASSES); `.claude/scripts/check-task-references.sh --quiet` exit 0; full `lake build` through the guard, detached, `Build completed successfully (2875 jobs)`, guard exit 0, `error:` count 0, no touched lake module for the `.olean` tier; probe compile exit 0, seventeen `#print axioms` lines all `[propext, Classical.choice, Quot.sound]`, `#eval` prints `9` twice; `lean-sorry-census.sh` 0 over the resolved roots and over the probe; vacuous grep 0 for this task's files (one pre-existing library hit at `HEAD~3`, issue log); `^axiom ` 14 over the roots before and after, 0 in the probe; `git ls-files --error-unmatch` on the probe exit 0; `git diff --stat HEAD~3 -- FormalSystem/ Tests/ docs/` empty; `ladderRealized|LadderCons`, `ULive|DischBwd|SLive`, `PlusTruthAt|tpOf|cellAt|anchorCells|WorldHistory` match only header/section prose; the ten Goal statements match the Challenge block declaration by declaration, `lean-challenge-snapshot.sh --check 815 .` attempted first and exited 71 (no manifest); `validate-artifact.sh ... summary` exit 0; `git status --short` shows no modified file outside the union of the `Files to modify` sets plus the task directory's own `.return-meta.json`/`issues.jsonl`/`handoffs/` and the orchestrator-owned `specs/TODO.md`/`state.json`/`events.jsonl`. NOT run by this dispatch, owed by the batch stage: `.claude/scripts/verify-deploy.sh` and `tests/run-all.sh` in full -- the one non-`specs/` file touched, `scripts/check-evidence-probes.sh`, resolves to `__FULL_SWEEP__` under `suite-selection-lib.sh` (unmappable to any agent-system suite), so no narrowing `--only`/`--only-gate` invocation covers it, and its covering checks are the project-root scripts above. `typst/generated/status.typ` was not regenerated by any hook (no diff).

## Lean Challenge Statements`
  (declaration by declaration; this is the substitute the predecessor recorded for
  `lean-challenge-snapshot.sh --check` when no manifest exists -- try the script first and record
  which check actually ran).
- [ ] Write `specs/815_certificate_sufficiency_dovetailing_realizability/summaries/01_certificate-sufficiency-dovetailing-summary.md`
  per summary-format.md: the probe path and its seventeen theorems grouped as the research round's
  thirteen plus this task's four; the verdict in the three-part form (theorem; refutation for
  `coh`, backward arm only; repair `cohBi`, label-level, now non-vacuous in both arms); the
  explicit statement that realizability is LABEL-LEVEL and that the semantic step (obligation (d))
  is the remaining adequacy obligation; gate 8 SIDESTEPPED, gates 1, 2, 3, 9 as carried, obligations
  (b), (c), (d) untouched; the roadmap edit and the two rulings it records; the carried-figure
  note naming every verdict read from an earlier probe's header rather than re-run; the check
  actually run in place of the challenge snapshot; and an explicit attestation of the issue-log
  entries made (or that none arose beyond those logged).
- [ ] Commit the summary; return.

**Timing**: 1.5 hours

**Depends on**: 2, 3

**Verification Tier**: full

**Commit Mode**: per-substep

**Scope Hypothesis**: the guard prints `all 41 wired probe(s) compile` (40 `WIRED` + 1
`WIRED_REPO`, both counted at plan time, no entry added by this task); the probe has seventeen
`#print axioms` lines. Re-count at run time. The `N` in the `git diff --stat HEAD~N` check below is
this task's own commit count at the time the check runs, counted then, not predicted here.

**Files to modify**:
- `specs/815_certificate_sufficiency_dovetailing_realizability/summaries/01_certificate-sufficiency-dovetailing-summary.md` - the implementation summary (new)
- `typst/generated/status.typ` - only if regenerated by the pre-commit hook (no diff expected)

**Verification** (the complete gate set -- every command's exit status is checked, never only its
output):
- `bash .claude/scripts/lake-build-guard.sh build --timeout 600 -- env lean specs/evidence/seam-gluing-ray-product/certificate-sufficiency-dovetailing.lean` exits 0: seventeen `#print axioms` lines, each at most `[propext, Classical.choice, Quot.sound]`; zero errors; zero warnings; the one `#eval` prints `9` (and the pre-existing one prints `9` for `phi3`).
- `bash -n scripts/check-evidence-probes.sh` exits 0; `bash scripts/check-evidence-probes.sh` exits 0 reporting `all 41 wired probe(s) compile`, with the probe's own line `PASS`; run detached with a bounded waiter (about two minutes at the research round's measurement).
- `git ls-files --error-unmatch specs/evidence/seam-gluing-ray-product/certificate-sufficiency-dovetailing.lean` exits 0.
- `bash scripts/check-module-invariants.sh` exits 0, run detached with a bounded waiter (C9 in particular: the decision-row edit cites theorem names and the probe filename, never a task number).
- `bash .claude/scripts/check-task-references.sh --quiet` exits 0 (the roadmap and the summary are under `specs/**`, the exempt tree; the guard-script comment is not, and cites no task number).
- Full `lake build` via `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build`, detached per `context/project/lean4/operations/long-builds.md`, exits 0 -- expected a no-op success, since no library `.lean` file changes, but mandatory before the return.
- Lean Final Verification Stage over the probe: `bash .claude/scripts/lean-sorry-census.sh` reports 0 for the file; the vacuous-definition grep (`def .* := True`, `:= trivial`, `:= Unit`) matches nothing; `grep -c "^axiom "` is 0; `grep -c native_decide` is 0; `grep -c maxRecDepth` is 0.
- `git diff --stat HEAD~N -- FormalSystem/ Tests/ docs/` (N = this task's commit count) is empty.
- `grep -rn "ladderRealized\|LadderCons" specs/evidence/seam-gluing-ray-product/certificate-sufficiency-dovetailing.lean` matches only header lines under `## What this does NOT say`.
- `grep -rn "ULive\|DischBwd\|SLive" specs/evidence/seam-gluing-ray-product/certificate-sufficiency-dovetailing.lean` matches only header prose -- never a definition or a theorem statement.
- `grep -n "PlusTruthAt\|tpOf\|cellAt\|anchorCells\|WorldHistory" specs/evidence/seam-gluing-ray-product/certificate-sufficiency-dovetailing.lean` matches nothing outside header prose (the label-level mechanical check).
- Each of the ten Goal statements, extracted from the file, agrees with its Challenge-block statement modulo whitespace; `bash .claude/scripts/lean-challenge-snapshot.sh --check 815 .` is attempted first and its exit recorded (ADVISORY: a drift finding is investigated and, if a recorded statement is genuinely wrong, the phase is marked `[BLOCKED]` and raised -- never silenced by editing this plan's block).
- `bash .claude/scripts/verify-deploy.sh` exits 0.
- `bash .claude/scripts/validate-artifact.sh specs/815_certificate_sufficiency_dovetailing_realizability/summaries/01_certificate-sufficiency-dovetailing-summary.md summary` exits 0.
- `git status --short` shows no modified files outside the union of this plan's `Files to modify` sets.

## Lean Challenge Statements

The ten `theorem` declarations are the Goals and carry `sorry` bodies. Six are pinned from the
compiled probe (their signatures copied from the file at plan time, so a later drift is a diff
against this block); four are new. Everything above the first `theorem` is supporting context
declared with `def`/`abbrev`, written out because the snapshot tool swallows non-`theorem` text
sitting between two `theorem` declarations into the preceding `:= sorry`. The definitional bodies
are part of the contract: in particular `certFwd`/`certBwd` run the fixpoint at `V := R` with
`succ := succR rel R`/`preR rel R` (inside `R`), `certAdm` conjoins the `stab` and `box` clauses,
`cohBi` is `coh` AND `snceLink`, and `Realizes` demands BOTH `FwdFulfilling` and `BwdFulfilling`
over `ℤ`. `a1A`, `atom1`, `topF`, `sig1`, `Q3`, `pend3` and every ported declaration are restated
here ONLY so the block type-checks standalone; in the probe they already exist and are reused.
**This block was compiled through `lake env lean` at plan time: exit 0, ten `declaration uses
'sorry'` warnings and no other diagnostic, 2.7 s wall-clock; with `#eval`s appended after
`end Probe815` (not part of the block) it printed `9` for the closure cardinality,
`(true, true, true, true, false, false, false)` for `(cohBi4 y2 y2, cohBi4 y2 y0, cohBi4 y0 y1,
cohBi4 y1 y1, cohBi4 y0 y0, cohBi4 y1 y0, cohBi4 y0 y2)`, `(true, true, true, true, true, true)`
for the six conditions on `R4`, `true` for `certAdm lab4 cohBi4 R4`, and `(4, 5, 5)` for the
three type cardinalities.**

```lean
import FormalSystem.Metalogic.Decidability.RaySummary.AnchorLayer
import FormalSystem.Metalogic.Decidability.WitnessFamily.Sharing.Fulfil

open FormalSystem.Syntax FormalSystem.PlusLanguage FormalSystem.Metalogic.Decidability

namespace Probe815

variable {α : Type*} [DecidableEq α]
variable {β : Type*} {ε : Type*}

def euStep (V : Finset α) (succ : α → Finset α) (isE isG : α → Bool) (X : Finset α) :
    Finset α :=
  V.filter (fun v => ∃ w ∈ succ v, isE w = true ∨ (isG w = true ∧ w ∈ X))

def euIter (V : Finset α) (succ : α → Finset α) (isE isG : α → Bool) : ℕ → Finset α
  | 0 => ∅
  | n + 1 => euStep V succ isE isG (euIter V succ isE isG n)

def euLfp (V : Finset α) (succ : α → Finset α) (isE isG : α → Bool) : Finset α :=
  euIter V succ isE isG (V.card + 1)

def LinkStep (succ : β → Finset β) (car : β → Prop) (evt grd : β → Bool) : Prop :=
  ∀ v w, w ∈ succ v → car v → evt w = true ∨ (grd w = true ∧ car w)

def HasDischargePath (V : Finset β) (succ : β → Finset β) (evt grd : β → Bool) (v : β) : Prop :=
  ∃ (n : ℕ) (h : ℕ → β), 0 < n ∧ h 0 = v ∧ (∀ i < n, h i ∈ V) ∧
    (∀ i < n, h (i + 1) ∈ succ (h i)) ∧ evt (h n) = true ∧
    (∀ i, 0 < i → i < n → grd (h i) = true)

abbrev ClType (φ : PlusFormula) : Type :=
  {T : Finset PlusFormula // T ∈ (plusSubformulaClosure φ).powerset}

abbrev ProdState (Q : Type) (φ : PlusFormula) : Type := Q × ClType φ

def locPred {Q : Type} (lab : Q → Atom → Bool) (q : Q) (T : Finset PlusFormula) :
    PlusFormula → Bool
  | ψ@(.atom a) => decide (ψ ∈ T) == lab q a
  | ψ@.bot => decide (ψ ∉ T)
  | ψ@(.imp α β) => decide (ψ ∈ T) == (!(decide (α ∈ T)) || decide (β ∈ T))
  | _ => true

def linkPred (T T' : Finset PlusFormula) : PlusFormula → Bool
  | ψ@(.untl g e) =>
      decide (ψ ∈ T) == (decide (e ∈ T') || (decide (g ∈ T') && decide (ψ ∈ T')))
  | _ => true

def locCoh {Q : Type} (lab : Q → Atom → Bool) (φ : PlusFormula) (x : ProdState Q φ) : Bool :=
  decide (∀ ψ ∈ plusSubformulaClosure φ, locPred lab x.1 x.2.1 ψ = true)

def untlLink (φ : PlusFormula) (T T' : ClType φ) : Bool :=
  decide (∀ ψ ∈ plusSubformulaClosure φ, linkPred T.1 T'.1 ψ = true)

def coh {Q : Type} (step : Q → Q → Bool) (pend : Q → Bool) (lab : Q → Atom → Bool)
    (φ : PlusFormula) (x y : ProdState Q φ) : Bool :=
  step x.1 y.1 && pend x.1 && pend y.1 && locCoh lab φ x && locCoh lab φ y &&
    untlLink φ x.2 y.2

def isUntl : PlusFormula → Bool
  | .untl _ _ => true
  | _ => false

def isSnce : PlusFormula → Bool
  | .snce _ _ => true
  | _ => false

def isBox : PlusFormula → Bool
  | .box _ => true
  | _ => false

def isStab : PlusFormula → Bool
  | .stab _ => true
  | _ => false

def argsOf : PlusFormula → PlusFormula × PlusFormula
  | .untl g e => (g, e)
  | .snce g e => (g, e)
  | _ => (.bot, .bot)

def argOf : PlusFormula → PlusFormula
  | .box σ => σ
  | .stab σ => σ
  | _ => .bot

variable {Q : Type} [Fintype Q] [DecidableEq Q] {φ : PlusFormula}

def succR (rel : ProdState Q φ → ProdState Q φ → Bool) (R : Finset (ProdState Q φ))
    (x : ProdState Q φ) : Finset (ProdState Q φ) :=
  R.filter (fun y => rel x y = true)

def preR (rel : ProdState Q φ → ProdState Q φ → Bool) (R : Finset (ProdState Q φ))
    (x : ProdState Q φ) : Finset (ProdState Q φ) :=
  R.filter (fun y => rel y x = true)

def cohR (rel : ProdState Q φ → ProdState Q φ → Bool) (R : Finset (ProdState Q φ))
    (x y : ProdState Q φ) : Bool :=
  rel x y && decide (x ∈ R) && decide (y ∈ R)

def certLoc (lab : Q → Atom → Bool) (R : Finset (ProdState Q φ)) : Bool :=
  decide (∀ x ∈ R, locCoh lab φ x = true)

def certBiInf (rel : ProdState Q φ → ProdState Q φ → Bool) (R : Finset (ProdState Q φ)) : Bool :=
  decide (∀ x ∈ R, 0 < (succR rel R x).card ∧ 0 < (preR rel R x).card)

def certFwd (rel : ProdState Q φ → ProdState Q φ → Bool) (R : Finset (ProdState Q φ)) : Bool :=
  decide (∀ x ∈ R, ∀ ψ ∈ x.2.1, isUntl ψ = true →
    x ∈ euLfp R (succR rel R) (fun w => decide ((argsOf ψ).2 ∈ w.2.1))
                              (fun w => decide ((argsOf ψ).1 ∈ w.2.1)))

def certBwd (rel : ProdState Q φ → ProdState Q φ → Bool) (R : Finset (ProdState Q φ)) : Bool :=
  decide (∀ x ∈ R, ∀ ψ ∈ x.2.1, isSnce ψ = true →
    x ∈ euLfp R (preR rel R) (fun w => decide ((argsOf ψ).2 ∈ w.2.1))
                             (fun w => decide ((argsOf ψ).1 ∈ w.2.1)))

def stabOk (R : Finset (ProdState Q φ)) (x : ProdState Q φ) (ψ : PlusFormula) : Bool :=
  decide (ψ ∈ x.2.1) == decide (∀ y ∈ R, y.1 = x.1 → argOf ψ ∈ y.2.1)

def certStab (R : Finset (ProdState Q φ)) : Bool :=
  decide (∀ x ∈ R, ∀ ψ ∈ plusSubformulaClosure φ, isStab ψ = true → stabOk R x ψ = true)

def certBox (R : Finset (ProdState Q φ)) : Bool :=
  decide (∀ x ∈ R, ∀ ψ ∈ plusSubformulaClosure φ, isBox ψ = true →
    (decide (ψ ∈ x.2.1) == decide (∀ y ∈ R, argOf ψ ∈ y.2.1)) = true)

def certAdm (lab : Q → Atom → Bool) (rel : ProdState Q φ → ProdState Q φ → Bool)
    (R : Finset (ProdState Q φ)) : Bool :=
  certLoc lab R && certBiInf rel R && certFwd rel R && certBwd rel R && certStab R && certBox R

def linkPredB (T T' : Finset PlusFormula) : PlusFormula → Bool
  | ψ@(.snce g e) =>
      decide (ψ ∈ T') == (decide (e ∈ T) || (decide (g ∈ T) && decide (ψ ∈ T)))
  | _ => true

def snceLink (φ : PlusFormula) (T T' : ClType φ) : Bool :=
  decide (∀ ψ ∈ plusSubformulaClosure φ, linkPredB T.1 T'.1 ψ = true)

def cohBi {Q : Type} (step : Q → Q → Bool) (pend : Q → Bool) (lab : Q → Atom → Bool)
    (φ : PlusFormula) (x y : ProdState Q φ) : Bool :=
  coh step pend lab φ x y && snceLink φ x.2 y.2

def IsChain (rel : ProdState Q φ → ProdState Q φ → Bool) (R : Finset (ProdState Q φ))
    (f : ℤ → ProdState Q φ) : Prop :=
  ∀ z, cohR rel R (f z) (f (z + 1)) = true

def FwdFulfilling (f : ℤ → ProdState Q φ) : Prop :=
  ∀ z (g e : PlusFormula), PlusFormula.untl g e ∈ (f z).2.1 →
    ∃ j, z < j ∧ e ∈ (f j).2.1 ∧ ∀ r, z < r → r < j → g ∈ (f r).2.1

def BwdFulfilling (f : ℤ → ProdState Q φ) : Prop :=
  ∀ z (g e : PlusFormula), PlusFormula.snce g e ∈ (f z).2.1 →
    ∃ j, j < z ∧ e ∈ (f j).2.1 ∧ ∀ r, j < r → r < z → g ∈ (f r).2.1

def Realizes (rel : ProdState Q φ → ProdState Q φ → Bool) (R : Finset (ProdState Q φ))
    (x : ProdState Q φ) : Prop :=
  ∃ f : ℤ → ProdState Q φ, f 0 = x ∧ IsChain rel R f ∧ FwdFulfilling f ∧ BwdFulfilling f

def a1A : Atom := ⟨"a1", none⟩
def bA : Atom := ⟨"b", none⟩
def atom1 : PlusFormula := .atom a1A
def atomB : PlusFormula := .atom bA
def topF : PlusFormula := .imp .bot .bot
def sig1 : PlusFormula := .snce topF atom1
def untB : PlusFormula := .untl topF atomB
def phi4 : PlusFormula := untB.and sig1

abbrev Q3 : Type := Fin 3

def pend3 : Q3 → Bool := fun _ => true

def step4 : Q3 → Q3 → Bool := fun q q' =>
  (q == 2 && (q' == 2 || q' == 0)) || (q == 0 && q' == 1) || (q == 1 && q' == 1)

def lab4 : Q3 → Atom → Bool := fun q at_ =>
  if at_ = a1A then q == 2 else if at_ = bA then q == 1 else false

def cohBi4 : ProdState Q3 phi4 → ProdState Q3 phi4 → Bool := cohBi step4 pend3 lab4 phi4

def mkT4 (L : List PlusFormula) : ClType phi4 :=
  ⟨(plusSubformulaClosure phi4).filter (fun ψ => ψ ∈ L),
    Finset.mem_powerset.mpr (Finset.filter_subset _ _)⟩

def U0 : ClType phi4 := mkT4 [phi4, untB, sig1, topF]
def U1 : ClType phi4 := mkT4 [phi4, untB, sig1, topF, atomB]
def U2 : ClType phi4 := mkT4 [phi4, untB, sig1, topF, atom1]

def y0 : ProdState Q3 phi4 := ((0 : Fin 3), U0)
def y1 : ProdState Q3 phi4 := ((1 : Fin 3), U1)
def y2 : ProdState Q3 phi4 := ((2 : Fin 3), U2)

def R4 : Finset (ProdState Q3 phi4) := {y0, y1, y2}

theorem eu_mem_lfp_path_le_card (V : Finset α) (succ : α → Finset α) (isE isG : α → Bool)
    (v : α) (hv : v ∈ euLfp V succ isE isG) :
    ∃ (n : ℕ) (f : ℕ → α), 0 < n ∧ n ≤ V.card ∧ f 0 = v ∧ (∀ i < n, f i ∈ V) ∧
      (∀ i < n, f (i + 1) ∈ succ (f i)) ∧ isE (f n) = true ∧
      (∀ i, 0 < i → i < n → isG (f i) = true) := sorry

theorem exists_dovetail_chain (V : Finset β) (succ : β → Finset β) (car : ε → β → Prop)
    (evt grd : ε → β → Bool)
    (hV : ∀ v ∈ V, ∀ w ∈ succ v, w ∈ V) (hne : ∀ v ∈ V, (succ v).Nonempty)
    (L : List ε) (hlink : ∀ ψ ∈ L, LinkStep succ (car ψ) (evt ψ) (grd ψ))
    (hdis : ∀ ψ ∈ L, ∀ v ∈ V, car ψ v → HasDischargePath V succ (evt ψ) (grd ψ) v)
    (x : β) (hx : x ∈ V) :
    ∃ f : ℕ → β, f 0 = x ∧ (∀ k, f k ∈ V) ∧ (∀ k, f (k + 1) ∈ succ (f k)) ∧
      ∀ k, ∀ ψ ∈ L, car ψ (f k) →
        ∃ j, k < j ∧ evt ψ (f j) = true ∧ ∀ r, k < r → r < j → grd ψ (f r) = true := sorry

theorem forward_chain_of_certAdm (step : Q → Q → Bool) (pend : Q → Bool) (lab : Q → Atom → Bool)
    (R : Finset (ProdState Q φ)) (hadm : certAdm lab (coh step pend lab φ) R = true)
    (x : ProdState Q φ) (hx : x ∈ R) :
    ∃ f : ℕ → ProdState Q φ, f 0 = x ∧
      (∀ k, cohR (coh step pend lab φ) R (f k) (f (k + 1)) = true) ∧
      ∀ k (g e : PlusFormula), PlusFormula.untl g e ∈ (f k).2.1 →
        ∃ j, k < j ∧ e ∈ (f j).2.1 ∧ ∀ r, k < r → r < j → g ∈ (f r).2.1 := sorry

theorem cohBi_eq_coh_of_snce_free {Q : Type} (step : Q → Q → Bool) (pend : Q → Bool)
    (lab : Q → Atom → Bool) (φ : PlusFormula)
    (hfree : ∀ ψ ∈ plusSubformulaClosure φ, isSnce ψ = false) (x y : ProdState Q φ) :
    cohBi step pend lab φ x y = coh step pend lab φ x y := sorry

theorem sufficiency_refuted :
    ¬ ∀ (Q : Type) [Fintype Q] [DecidableEq Q] (step : Q → Q → Bool) (pend : Q → Bool)
        (lab : Q → Atom → Bool) (φ : PlusFormula) (R : Finset (ProdState Q φ)),
        certAdm lab (coh step pend lab φ) R = true →
          ∀ x ∈ R, Realizes (coh step pend lab φ) R x := sorry

theorem realizes_of_certAdm_cohBi (step : Q → Q → Bool) (pend : Q → Bool)
    (lab : Q → Atom → Bool) (R : Finset (ProdState Q φ))
    (hadm : certAdm lab (cohBi step pend lab φ) R = true)
    (x : ProdState Q φ) (hx : x ∈ R) : Realizes (cohBi step pend lab φ) R x := sorry

theorem phi4_closure_both_arms :
    untB ∈ plusSubformulaClosure phi4 ∧ sig1 ∈ plusSubformulaClosure phi4 ∧
      ∀ ψ ∈ plusSubformulaClosure phi4, isBox ψ = false ∧ isStab ψ = false := sorry

theorem y0_carries_both : untB ∈ y0.2.1 ∧ sig1 ∈ y0.2.1 := sorry

theorem cert_accepts_R4 : certAdm lab4 cohBi4 R4 = true := sorry

theorem realizes_y0_R4 : Realizes cohBi4 R4 y0 := sorry

end Probe815
```

## Testing & Validation

- [ ] The probe compiles through `bash .claude/scripts/lake-build-guard.sh build --timeout 600 -- env lean specs/evidence/seam-gluing-ray-product/certificate-sufficiency-dovetailing.lean` with exit 0, zero errors and zero warnings.
- [ ] Zero `sorry`: `bash .claude/scripts/lean-sorry-census.sh` reports 0 for the file.
- [ ] No new axiom: `#print axioms` on all seventeen printed theorems reports at most `[propext, Classical.choice, Quot.sound]`; no `sorryAx`, no `ofReduceBool`, no `native_decide`, no `maxRecDepth` anywhere in the file.
- [ ] The six pinned Goal signatures are byte-unchanged modulo whitespace from the Challenge block; the four new ones match it.
- [ ] `realizes_y0_R4`'s proof body names `realizes_of_certAdm_cohBi`.
- [ ] `bash scripts/check-evidence-probes.sh` exits 0 reporting `all 41 wired probe(s) compile`; `WIRED` still has 40 entries.
- [ ] The label-level mechanical check passes: no `WorldHistory`, `PlusTruthAt`, `tpOf`, `cellAt` or `anchorCells` outside header prose.
- [ ] `specs/ROADMAP.md`'s diff lies entirely inside the four enumerated regions and keeps the gate-8/3/1/2/9, `anchorCells_ncard_le` and R2 sentences verbatim.
- [ ] `bash scripts/check-module-invariants.sh`, `bash .claude/scripts/check-task-references.sh --quiet` and `bash .claude/scripts/verify-deploy.sh` each exit 0.
- [ ] Full `lake build` exits 0 (expected no-op: no library file changes).
- [ ] `git diff --stat` over `FormalSystem/`, `Tests/` and `docs/` across this task's commits is empty.
- [ ] `bash .claude/scripts/lean-challenge-snapshot.sh --check 815 .` attempted and its outcome recorded; on exit 71 (no manifest) the declaration-by-declaration diff is the recorded substitute (advisory).

## Artifacts & Outputs

- `specs/evidence/seam-gluing-ray-product/certificate-sufficiency-dovetailing.lean` -- the twenty-third wired evidence probe, extended by the two-arm non-vacuity fixture: seventeen printed theorems (the research round's thirteen plus `phi4_closure_both_arms`, `y0_carries_both`, `cert_accepts_R4`, `realizes_y0_R4`), sorry-free, no new axiom; header updated.
- `scripts/check-evidence-probes.sh` -- the probe's decision-row comment block extended with the non-vacuity rows and the corrected theorem count; no `WIRED` change (40 entries before and after; the guard prints 41).
- `specs/ROADMAP.md` -- the four regions naming this task's gate rewritten to the verdict and the two rulings the parent inherits.
- `specs/815_certificate_sufficiency_dovetailing_realizability/plans/01_certificate-sufficiency-dovetailing.md` -- this plan.
- `specs/815_certificate_sufficiency_dovetailing_realizability/summaries/01_certificate-sufficiency-dovetailing-summary.md` -- the implementation summary.

## Rollback/Contingency

- **Per phase**: each phase edits one or two files and commits on its own green sub-steps through `.claude/scripts/git-commit-scoped.sh`, so a failed phase is reverted by `git revert` of its own commits; no rollback of the working tree is required and none is to be taken as a routine precaution.
- **If a Goal cannot be proved as pinned**: mark the phase `[BLOCKED]`, record what was tried and the goal state reached, and raise it. Do NOT substitute a same-named weaker statement, add a hypothesis, specialise a quantifier, drop a certificate field, or swap `cohBi4` for `coh` in `cert_accepts_R4` -- `plan-compliance.md` Statement Fidelity governs every signature in `## Lean Challenge Statements`, and a `cert_accepts_R4` over the one-arm relation would be exactly the vacuity the fixture exists to rule out.
- **If a Scope Hypothesis is falsified** (the closure cardinality, a type cardinality, a `cohBi4` edge, a condition value): the phase is blocked and the figure re-derived, never worked around by restating the Goal that depended on it. Since every Phase 1 figure was measured at plan time by `#eval`, a falsification means the committed probe and the plan-time block differ -- find the difference before anything else. A genuine overcount elsewhere (a roadmap region that turns out not to exist) is closed with `[COMPLETED WITH EXCLUSIONS]` and a `#### Reasoned Exclusions` record whose Evidence column cites the grep that falsified it.
- **If a genuine rollback of uncommitted work becomes necessary**: take the snapshot first per `context/contracts/recovery.md`'s rollback rung, then run the destructive command; a bare `git-snapshot.sh 815` is not a start-of-phase precaution, and an ordinary defensive checkpoint uses `--no-revert`.
- **Whole-task contingency**: the research round's verdicts stand regardless of this task's outcome -- they are compiled and tracked. If the two-arm fixture cannot be landed as pinned, the task returns `partial` with the gap recorded as what it is (the two-sided theorem still lacks a non-vacuous instance), the roadmap text says so in place of the non-vacuity sentence, and no same-named substitute is stated.
