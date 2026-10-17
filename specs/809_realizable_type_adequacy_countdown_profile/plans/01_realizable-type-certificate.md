# Implementation Plan: Task #809

- **Task**: 809 - Realizable-type adequacy of the countdown profile: the certificate presentation, its existential fulfilment condition, and the compiled separation from local coherence
- **Status**: [IMPLEMENTING]
- **Effort**: 12 hours
- **Dependencies**: 761 (parent, stays `[BLOCKED]`; this task does not touch it); 806 (predecessor; its fixture, local relation and profile are ported, not imported); 805 (refuted predecessor; its coprime-cycle object reaches here through 806)
- **Research Inputs**: specs/809_realizable_type_adequacy_countdown_profile/reports/01_realizable-type-adequacy.md
- **Artifacts**: plans/01_realizable-type-certificate.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md, plan-compliance.md (Statement Fidelity)
- **Type**: lean4
- **Lean Intent**: true

## Overview

The research round re-costed the adequacy obligation against the tree and found its residue to be
two things: a **strength choice** between a universal and an existential fulfilment condition, and
**one missing algorithm** under the universal-rejecting half. It compiled the gap witness (a
`coh6`-coherent 3-cycle carrying `ev = T U psi2` at every position and `psi2` at none) and named the
route that avoids the missing algorithm. This plan executes exactly that route and nothing beyond
it: it lands **one new wired evidence probe** that (i) builds the existential until-fixpoint
operator as the decision procedure for a bounded discharge condition, (ii) states the chain-to-ray
composition theorem the restriction could have silently broken, (iii) defines the certificate
presentation as a candidate realizable set with seven decidable fields **including the `box` and
`stab` clauses**, and (iv) exhibits the separation that makes the whole exercise non-vacuous: a set
of product states that **local coherence accepts and the certificate rejects**, on the same fixture
the predecessor round's gate table was run on.

**The strength choice is made here, in the plan, and is not left to the implementation** (research
Recommendation 2): the fulfilment condition is **existential** — "this product state lies on some
guarded `coh`-path inside the candidate set that delivers the event" — and `ULive`, whose landed
forcing theorem makes it the cheapest-looking move in the tree, is **never** transplanted. The
research compiled the reason: `evRay` is an infinite chain in the deferral graph of `ev`, so a
`ULive`-shaped condition on the object-closure product fails on a fixture whose types are
realizable through the 2-cycle exit `a -> d -> a`, and
`PlusWitnessFamily/Limits/NoCertificate.lean`'s verdict on that mechanism is quoted exactly because
it forecloses the obvious repair: *"The defect is not a missing bound and no bound repairs it."*

**Route B (check it) is chosen over Route A (decide it)** (research Recommendation 1). Route A's
missing piece is generalized-Buchi nonemptiness per state — a nested fixpoint nothing in this tree
decides — and entering it without a decision record is how the tuple-widening loop was entered.
Route B's conditions are bounded and decidable field by field, and its shape is the one three
separate subtrees already use (`Cons`'s eleven fields, `AnchorCons`, `PlusCertifies`'s six checked
components). The existential until-fixpoint built in Phases 1-2 is **not** Route A's algorithm: it
decides *one* eventuality's bounded discharge inside the candidate set, which is Route B's
condition (3), not "does some chain discharge every eventuality it carries".

Definition of done: one sorry-free probe at
`specs/evidence/seam-gluing-ray-product/realizable-type-certificate.lean`, registered in
`scripts/check-evidence-probes.sh`, carrying the eighteen Goal theorems below; the complete gate set
green; one summary. Nothing under `FormalSystem/` or `Tests/` is touched.

**What this plan does NOT do.** It does not claim adequacy is discharged: the dovetailing argument
that Route B's conditions are *sufficient* for realizability stays an argument in the research
report (marked [NOT COMPILED] there) and is not stated as a theorem here. It does not construct
`EUFix` inside the library, port `AUFix` in place, or edit `Realize.lean`. It does not state
`ladderRealized`, `LadderCons`, `ladderCons_localRun`, or a same-named weaker substitute, under
those names or any others — and in particular states no `LadderCons` at all, hence none without the
`box`/`stab` clause. It proposes no seventh tuple coordinate and re-presents no threshold or period
as an index coordinate. It does not re-derive eventual periodicity of the countdown over the
object-closure product, which the dispatch settles on compiled ground (the seventeenth probe).

### Research Integration

- **The strength question (report §4)** is the plan's organising decision; it fixes the
  `euStep`/`euLfp` operator as existential at the definition, and Phase 2 compiles the distinction
  itself as `au_lfp_ne_eu_lfp_on_exit_graph` — a concrete cycle-with-an-exit graph on which the
  landed universal operator and this plan's existential one give **different** fixpoints. The
  report's §4 translation of `evRay` into `Realize.lean`'s letter-level `sig.preds` notation is
  marked [NOT COMPILED] there and is deliberately **not** attempted here; the compiled separation
  above is the statable form of the same point.
- **Route B's six conditions (report §6)** become the certificate's fields verbatim, including the
  report's explicit "inside `R`" on conditions (3) and (4): `certFwd`/`certBwd` run the fixpoint
  with `V := R` and `succ := succR R`/`preR R`, so no path outside `R` can discharge anything. The
  report names weakening this to "a path somewhere in the carrier" as a named risk; the Challenge
  block pins the stronger form.
- **`AUFix` is the substrate and the port is a one-quantifier edit (report §6, Recommendation 5)**:
  every lemma of `AUFix` reads only monotonicity in `X`, never the quantifier. Phase 1 ports the
  four load-bearing ones under `eu`-prefixed names in the probe's own namespace. The port lives in
  the probe, not in `FormalSystem/`, because this task's scope forbids library edits — recorded as
  a deliberate consequence, not an oversight.
- **The composition theorem (report §7, Recommendation 4)** is `untl_propagates_along_coh`, stated
  generically over `Q` and `φ` so it covers both `coh` and, through `cohR_le_coh`, the restricted
  relation. The report names it as "the place the restriction to `R` could silently fail".
- **Gate 7 (report §5)** is passed in the same definability-plus-non-vacuity form the eighteenth
  probe used: every certificate field is a computable `Bool` built from `(Q5, step5, pend5, lab6,
  chi)` and the candidate set alone, naming no history, world, model or cell; and
  `cert_accepts_Rchi` lands a non-empty instance **before** every negative statement about what the
  certificate rejects.
- **Gate 8 (report §5, Recommendation 3)** is renamed, not attacked: it is the standing
  `BoxStabFree` scope line of the anchor/run layer, which `Realize.lean` buys its whole bundle under
  and which the probe collection sidesteps at the same place. The `stab` and `box` clauses are
  nonetheless **present** as checked biconditionals on the candidate datum, following
  `BoxOracleSound`/`StabFaithful`/`AnchorCons` (specification, not construction), and
  `chi_closure_box_snce_stab_free` compiles the reason they are unexercised on this fixture. Every
  `stab` verdict in this line stays SIDESTEPPED.
- **Carried verdicts (report, Executive Summary final bullet)**: gate 3 stays CARRIED, gates 1 and
  2 stay NOT ADDRESSED with the compiled n-side qualification, gate 9 stays OPEN, obligations (b),
  (c) and (d) stay named and unmet. Phase 6's header and the summary reproduce each as carried.
- **Tactic survey (report)**: `decide` on concrete closure facts only, never `native_decide`
  (Decision 7, which would add `ofReduceBool`); closure types built with `mkT` as a `filter`, never
  by `decide` on `Finset.powerset`; `% 3` case splits settled by `omega`.

### Prior Plan Reference

No prior plan for this task. The calibration is the predecessor round's
`specs/806_set_valued_cell_quotient_index/plans/01_closure-profile-gate-rerun.md`, whose six phases
at roughly an hour to two each ran to plan: its port-then-state-then-gate-then-register-then-sweep
ordering is reused here, as is its discipline of compiling the `## Lean Challenge Statements` block
before the plan is written. Two lessons are taken from it specifically: closure types are built as
`filter`s because `decide` on `Finset.powerset` membership hits `maxRecDepth` on this closure; and
the header/registration work is real work, not a formality, so it is given its own task list rather
than being folded into a proof phase as an afterthought.

### Roadmap Alignment

Not consulted: the dispatch context carries no `roadmap_path`, and this task modifies no roadmap
file.

## Goals & Non-Goals

**Goals** (the identifier set equals the eighteen `theorem` declarations in
`## Lean Challenge Statements`; all land in
`specs/evidence/seam-gluing-ray-product/realizable-type-certificate.lean`, namespace `Probe809C`):
- `eu_step_mono`
- `eu_lfp_fixed`
- `eu_mem_lfp_iff`
- `eu_lfp_least`
- `eu_mem_lfp_iff_exists_path`
- `eu_lfp_eq_empty_of_no_event`
- `au_lfp_ne_eu_lfp_on_exit_graph`
- `untl_propagates_along_coh`
- `cohR_le_coh`
- `chi_closure_box_snce_stab_free`
- `cert_fwd_iff_eu_lfp`
- `cert_accepts_Rchi`
- `coh_accepts_Rev`
- `rev_eu_lfp_empty`
- `cert_rejects_Rev`
- `profR_period_three`
- `profR_fibre_a_witness`
- `profR_separates_gate6_pair`

Plus, not Goals (ports carrying no new statement): the fixture layer of the eighteenth and twentieth
probes — `pA`/`rA`/`aA`, `p`, `la`, `nextPow`, `pa`, `psi2`, `chi`, `Q5`, `pend5`, `step5`, `lab6`,
`a5`/`b5`/`c5`, `ClType`, `ProdState`, `prodPreStep`, `locPred`, `linkPred`, `locCoh`, `untlLink`,
`coh`, `coh6`, `mkT`, `Ea`, the formula abbreviations (`top`, `xpa`, `xxpa`, `bb`, `cc`, `ev`,
`evnn`, `dd`) and the six type lists — which move across label-generically, as the dispatch records.
Any supporting lemma the proofs need (one-step unfoldings of `locCoh`/`untlLink`, `prof` successor
rewrites) is free to exist in the file without being a Goal, exactly as the eighteenth probe's
`loc_bot`/`loc_atom`/`link_untl` do.

**Non-Goals**:
- Any adequacy or sufficiency CLAIM: that Route B's conditions are sufficient for realizability is
  the report's dovetailing argument, not a theorem of this probe, and the header says so.
- Route A: generalized-Buchi nonemptiness per state, a nested fixpoint, or any claim that the
  existential operator built here decides "some chain discharges every eventuality it carries".
- Any transplant of `ULive`, `UCoh`, `Disch`, `SLive` or `DischBwd` onto the product, and any
  universal-strength fulfilment condition anywhere in the probe.
- Any declaration named `ladderRealized`, `LadderCons`, `ladderCons_localRun`, or a same-named
  weaker substitute, in any file; no `LadderCons` is stated at all, hence none without the
  `box`/`stab` clause.
- Any edit under `FormalSystem/`, `Tests/`, `docs/`, or the RaySummary README; any edit to the
  parent task 761's records; any edit to `ladder-counter-observables.md` (a source-store file whose
  change is the research round's Context Extension Recommendation and needs its own commit outside
  this repository).
- A seventh tuple coordinate, or any re-presentation of the profile's threshold or period as index
  coordinates.
- Re-deriving eventual periodicity of the countdown over the object-closure product, the finiteness
  and bound on the SET of cells (`anchorCells_finite`, `anchorCells_ncard_le`), or any of the four
  refuted tuple-shaped index shapes.
- Obligations (b) region-length pumping, (c) `Drift` coupling of the next deadline, (d) the
  `box`/`stab` letters through `box_mem_tpOf_iff`/`stab_mem_tpOf_iff`; gates 1, 2, 3 and 9.

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| `decide` is attempted over the whole carrier (`2^18` closure types x 8 object states) and times out or hits `maxRecDepth` | H | M | Every Goal quantifying over `ClType chi` is proved by hand through the one-step unfoldings, as the eighteenth probe does; `decide` is used only on the three-element candidate sets `Rchi`/`Rev`, on concrete closure memberships, on the 18-member closure, and on the four-state `exitSucc` graph. Types are built with `mkT` (a `filter`), never by `decide` on `Finset.powerset`. |
| `au_lfp_ne_eu_lfp_on_exit_graph` is attempted by `decide` and the iterated `Finset.filter` reduction is too heavy | M | M | Fall back to the pointwise form: show `(0 : Fin 4) ∉ AUFix.lfp ...` through `AUFix.mem_lfp_iff` (vertex `1`'s obligation is never discharged) and `(0 : Fin 4) ∈ euLfp ...` through `eu_mem_lfp_iff` (vertex `3` delivers the event in one step). The pinned statement is unchanged either way; only the proof route changes, which is not a Statement Fidelity concern. |
| The fulfilment condition is silently weakened to "a path somewhere in the carrier" rather than "inside `R`" — strictly weaker and still type-correct | H | M | `certFwd`/`certBwd` are pinned in the Challenge block with `V := R` and `succ := succR R`/`preR R`; `cert_fwd_iff_eu_lfp` states the unfolding so the quantifier structure is visible in a theorem, not only in a definition; `plan-compliance.md` Statement Fidelity governs every pinned signature. |
| The existential operator is read as Route A's missing algorithm, i.e. "adequacy decided" | H | M | The Overview states the distinction; the probe header's "What this does NOT say" repeats it; no theorem in the Goal set quantifies over the set of eventualities a state carries. |
| `cert_accepts_Rchi` turns out false because some member of `Ta`/`Tb`/`Tc` is an `untl` whose event is not delivered by the next member of the 3-cycle | H | L | Traced at plan time: `Tb` carries `xxpa = .untl .bot xpa` and its `Rchi`-successor `(c5, Tc)` carries `xpa`; `Tc` carries `xpa = .untl .bot pa` and its successor `(a5, Ta)` carries `pa`; `Ta` carries no `untl` member (`chi`, `psi2.neg`, `ev.neg`, `top`, `bb`, `xxpa.neg` are all `imp`-built, `p`/`la` are atoms). If the trace is wrong the phase is `[BLOCKED]` and raised, never repaired by weakening the witness or dropping a field. |
| Gate 8 is marked passed because the resolution pattern was found | H | M | The pattern resolves the DEFINITIONAL circularity only; `chi`'s closure has no `stab` member, so the clause is present and unexercised. Phase 4 compiles `chi_closure_box_snce_stab_free` and Phase 6's header records gate 8 as SIDESTEPPED, with the `BoxStabFree` rename stated. |
| The certificate's rejection of `Rev` is read as a refutation of the countdown profile, or as a claim that `(a5, evTa)` is non-realizable | M | M | Neither is claimed: `Rev` is rejected as a CANDIDATE REALIZABLE SET, and `psi2` is deliverable on this object through the 2-cycle `a -> d -> a`, which `Rev` excludes by construction. The header says both, as the twentieth probe's header already does. |
| The restricted profile's gate-6 separation is mistaken for a NEW gate-6 pass | M | L | `profR_separates_gate6_pair` is the predecessor round's negative result re-run against the smaller relation, recorded as "survives the refinement", never as a new verdict; gate 6's own row stays as the eighteenth probe left it. |
| A seventh mechanism exists that none of this exercises | H | M | The standing lesson binds: a gate probing one coordinate certifies one coordinate only. Every carried verdict is marked carried in the header and the summary. |

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

Phases within the same wave can execute in parallel. Every wave here holds one phase: all five
proof phases append to the same probe file, so they are serialized by territory, not by choice.

### Phase 1: The Existential Until-Fixpoint Operator and Its Fixpoint API [COMPLETED]

**Goal**: Land the existential dual of `AUFix` in the probe's own namespace — the operator, its
iteration, its stabilized fixpoint, and the four load-bearing lemmas — generic over an arbitrary
`DecidableEq` carrier and mentioning no formula, so that the condition it will decide cannot be
confused with a formula-specific hack.

**Tasks**:
- [x] Create `specs/evidence/seam-gluing-ray-product/realizable-type-certificate.lean` with a
  placeholder header, the two imports of the Challenge block, `open FormalSystem.Syntax
  FormalSystem.PlusLanguage FormalSystem.Metalogic.Decidability`, and `namespace Probe809C`.
- [x] Define `euStep`, `euIter`, `euLfp` exactly as the Challenge block spells them. The only
  difference from `AUFix.step` is `∃ w ∈ succ v` in place of `∀ w ∈ succ v`; do not take the
  opportunity to restructure the definition.
- [x] Prove `eu_step_mono` (monotonicity in `X`, the only property the iteration needs) and the
  supporting `eu_step_subset`/`eu_iter_subset`/`eu_iter_succ_mono`/`eu_iter_mono`/`eu_iter_stab`/
  `eu_exists_stab` ports as needed — each a one-quantifier edit of the `AUFix` original, which must
  be read side by side rather than reinvented.
- [x] Prove `eu_lfp_fixed`, `eu_mem_lfp_iff`, `eu_lfp_least`.
- [ ] Commit (explicit file list: the probe).

**Timing**: 2 hours

**Depends on**: none

**Verification Tier**: local

**Commit Mode**: per-substep

**Scope Hypothesis**: the four Goals of this phase need at most the six `AUFix` supporting lemmas
named above and no new Mathlib lemma; confirm by compiling the file and by `grep -c "^theorem\|^lemma"` on it before the commit. Carried from the research report's §6 claim that
`step_mono`/`iter`/`iter_stab`/`exists_stab`/`lfp`/`lfp_fixed`/`lfp_least`/`mem_lfp_iff`/
`lfp_induction` "read only monotonicity in `X`, never the quantifier"
[CARRIED-UNVERIFIED: `specs/809_realizable_type_adequacy_countdown_profile/reports/01_realizable-type-adequacy.md` §6, Route A paragraph; the four `AUFix` proofs were read at plan time but not re-run].

**Tier Justification**: `bash .claude/scripts/lake-build-guard.sh build --timeout 600 -- env lean specs/evidence/seam-gluing-ray-product/realizable-type-certificate.lean` exiting 0 with zero errors and zero warnings is the complete covering check — the phase creates one new standalone file that no library module imports, so it has no blast radius beyond itself.

**Files to modify**:
- `specs/evidence/seam-gluing-ray-product/realizable-type-certificate.lean` - new file: imports, namespace, the `eu` operator and its fixpoint API

**Verification**:
- The single-file compile above exits 0, with zero `sorry` (`bash .claude/scripts/lean-sorry-census.sh` reports 0 for this file) and zero warnings.
- `#print axioms` on each of the four Goals reports at most `[propext, Classical.choice, Quot.sound]`; `grep -c native_decide` is 0; `grep -c "^axiom "` is 0.
- `grep -n "PlusFormula\|Atom" ` over the `eu` section matches nothing: the operator is language-agnostic, which is the property that makes it the dual of `AUFix` rather than a fixture device.
- The four pinned signatures match the Challenge block byte for byte modulo whitespace.

---

### Phase 2: The Guarded-Path Characterization, the Emptiness Lemma, and the Compiled Universal-Versus-Existential Separation [NOT STARTED]

**Goal**: Give the fixpoint its meaning as a path statement, give it the one negative lemma the
rejection proof consumes, and compile the strength distinction the research round identified as the
single most expensive thing in this line to rediscover.

**Tasks**:
- [ ] Prove `eu_mem_lfp_iff_exists_path`. Forward: induct along `euIter` (the existential analogue of
  `AUFix.lfp_induction`), reading off the path index by index. Backward: a path of length `n` puts
  `f 0` in `euIter n`, and `eu_iter_stab` with `eu_exists_stab` gives `euIter n ⊆ euLfp` for EVERY
  `n` — so no path-shortening argument is needed, and none is to be invented.
- [ ] Prove `eu_lfp_eq_empty_of_no_event` through `eu_lfp_least` at `X := ∅`.
- [ ] Define the four-state cycle-with-an-exit graph `exitSucc`/`exitIsE`/`exitIsG` and prove
  `au_lfp_ne_eu_lfp_on_exit_graph`. Expected values, computed at plan time and to be confirmed, not
  trusted: the universal fixpoint is `{3}` and the existential one is `Finset.univ`. Try `decide`
  first; on a reduction blow-up use the pointwise route in the Risks table.
- [ ] Commit (explicit file list: the probe).

**Timing**: 2 hours

**Depends on**: 1

**Verification Tier**: local

**Commit Mode**: per-substep

**Scope Hypothesis**: `AUFix.lfp Finset.univ exitSucc exitIsE exitIsG = {3}` and
`euLfp Finset.univ exitSucc exitIsE exitIsG = Finset.univ` on the four-state graph; confirm by
`#eval` on both sides before proving the inequality, and record the two values in the probe header.
This is a plan-time hand computation, not a measured figure.

**Tier Justification**: the same single-file compile as Phase 1 exiting 0 is the complete covering check — the phase still touches only the one new standalone file, and `AUFix` is consumed as an unmodified import whose own module is not edited.

**Files to modify**:
- `specs/evidence/seam-gluing-ray-product/realizable-type-certificate.lean` - the path characterization, the emptiness lemma, the exit-graph separation

**Verification**:
- Single-file compile exits 0, zero `sorry`, zero warnings; `#print axioms` on the three new Goals reports at most `[propext, Classical.choice, Quot.sound]`.
- `#eval` confirms the two fixpoint values named in the Scope Hypothesis before `au_lfp_ne_eu_lfp_on_exit_graph` is proved; a mismatch blocks the phase rather than prompting a restatement.
- `eu_mem_lfp_iff_exists_path`'s statement still requires `0 < n` and `isE (f n) = true` at a STRICTLY later index than `f 0`: `grep` the statement and compare against the Challenge block, because dropping `0 < n` would turn strict until into weak until silently.

---

### Phase 3: Fixture Port, the Restricted Relation, and the Chain-to-Ray Composition Theorem [NOT STARTED]

**Goal**: Port the coprime-cycle fixture and the LOCAL coherence relation label-generically, define
the restriction of that relation to a candidate set, and prove the one new statement the restriction
could have silently broken: an `untl` obligation carried at an interior position of a `coh`-chain is
either discharged inside the chain or still carried at its end with the guard holding throughout.

**Tasks**:
- [ ] Port, byte for byte from the eighteenth and twentieth probes: the atoms, `p`, `la`, `nextPow`,
  `pa`, `psi2`, `chi`, `Q5`, `pend5`, `step5`, `lab6`, `a5`/`b5`/`c5`, `ClType`, `ProdState`,
  `prodPreStep`, `locPred`, `linkPred`, `locCoh`, `untlLink`, `coh`, `coh6`, `mkT`, `Ea`, the formula
  abbreviations and the six type lists (`TaL`/`TbL`/`TcL`, `evTaL`/`evTbL`/`evTcL`) with `Ta`/`Tb`/
  `Tc` and `evTa`/`evTb`/`evTc`. The ports carry no new statement and are not Goals; the fixture is
  label-generic and the frame/regularity/history layer ports verbatim, as the dispatch records.
- [ ] Re-land the one-step unfolding lemmas the proofs need (the eighteenth probe's `loc_bot`,
  `loc_atom`, `loc_imp`, `loc_neg`, `link_untl` shapes) as supporting lemmas, not Goals.
- [ ] Define `cohR` (the local relation restricted to a candidate set at both endpoints) and prove
  `cohR_le_coh`.
- [ ] Prove `untl_propagates_along_coh` by induction on `n - i` through the `untl` link
  biconditional. Do NOT state a `snce` mirror: `linkPred` constrains no `snce` arm, so a backward
  propagation theorem is not available from this relation, and claiming one would be a strictly
  weaker statement wearing a stronger name.
- [ ] Commit (explicit file list: the probe).

**Timing**: 2 hours

**Depends on**: 2

**Verification Tier**: local

**Commit Mode**: per-substep

**Scope Hypothesis**: `plusSubformulaClosure chi` has 18 members and `linkPred` constrains exactly
the `untl` arm of it; confirm with `#eval (plusSubformulaClosure chi).card` and by re-running the
eighteenth probe's `chi_closure_untl_only`-shaped `decide` in this file. Both figures are carried
[CARRIED-UNVERIFIED: `specs/806_set_valued_cell_quotient_index/plans/01_closure-profile-gate-rerun.md`, Overview, plan-time measurement paragraph].

**Tier Justification**: the same single-file compile exiting 0 is the complete covering check — the ported declarations are new names inside `Probe809C` that shadow nothing outside the file, and no library module imports the probe.

**Files to modify**:
- `specs/evidence/seam-gluing-ray-product/realizable-type-certificate.lean` - the fixture port, the supporting unfoldings, `cohR`, and the composition theorem

**Verification**:
- Single-file compile exits 0, zero `sorry`, zero warnings.
- `#eval` on the closure cardinality matches the Scope Hypothesis; a mismatch blocks the phase.
- `diff` of each ported declaration against its source in `closure-profile-gate-rerun.lean` / `realizable-type-adequacy-gap.lean` shows only the renames this plan's Challenge block already fixes (`B`/`C`/`Xpa`/`XXpa` to `bb`/`cc`/`xpa`/`xxpa`); no port silently changes a definition.
- `grep -n "snce" ` over the file matches only `isSnce`, `certBwd`, `argsOf`, `chi_closure_box_snce_stab_free` and header prose — never a claimed `snce` propagation theorem.

---

### Phase 4: The Certificate: Seven Decidable Fields Including the Box and Stab Clauses, and the Non-Vacuity Witness [NOT STARTED]

**Goal**: Define the certificate presentation as a candidate realizable set with the research
report's six conditions as decidable fields — with `box` and `stab` PRESENT as checked
biconditionals, not omitted — compile the reason this fixture does not exercise them, and land a
non-empty instance before any statement about what the certificate rejects.

**Tasks**:
- [ ] Define `isUntl`, `isSnce`, `isBox`, `isStab`, `argsOf`, `argOf`, `succR`, `preR`.
- [ ] Define the fields exactly as the Challenge block spells them: `certLoc` (condition 1),
  `certBiInf` (condition 2, a successor AND a predecessor inside `R`), `certFwd` (condition 3,
  the existential discharge of every `untl` member through `euLfp R (succR R)`), `certBwd`
  (condition 4, the `snce` mirror through `euLfp R (preR R)`), `stabOk`/`certStab` (condition 5,
  the `⊡ψ ∈ T ↔ ∀ y ∈ R with the same object state, ψ ∈ y`, read against `R`'s own fibre), `certBox`
  (condition 6, the global bit read against `R`), and `certAdm` as their conjunction. The `stab` and
  `box` fields are NOT optional and are not to be dropped because the fixture makes them vacuous.
- [ ] Prove `chi_closure_box_snce_stab_free` by `decide` over the 18-member closure — the compiled
  statement of the gate-8 sidestep, and the reason conditions (4), (5) and (6) have no content here.
- [ ] Prove `cert_fwd_iff_eu_lfp`, the unfolding that puts condition (3)'s quantifier structure
  inside a theorem rather than only inside a definition.
- [ ] Prove `cert_accepts_Rchi` — the gate-7 non-vacuity obligation, landed BEFORE every negative
  statement, as the collection's discipline requires. Define `Rchi` as the eighteenth probe's
  `chi`-carrying 3-cycle.
- [ ] Commit (explicit file list: the probe).

**Timing**: 2 hours

**Depends on**: 3

**Verification Tier**: local

**Commit Mode**: per-substep

**Scope Hypothesis**: `certAdm Rchi = true` holds with `certBwd`/`certStab`/`certBox` vacuous and
`certFwd` discharged by exactly two `untl` members (`xxpa` in `Tb`, `xpa` in `Tc`); confirm with
`#eval (Ta.1.filter (fun ψ => isUntl ψ = true)).card` and the `Tb`/`Tc` analogues before proving the
Goal, and record the three cardinalities in the probe header.

**Tier Justification**: the same single-file compile exiting 0 is the complete covering check — every field is a new `Bool`-valued definition inside `Probe809C` with no caller outside the file.

**Files to modify**:
- `specs/evidence/seam-gluing-ray-product/realizable-type-certificate.lean` - the certificate fields, the modal-free closure fact, the condition-(3) unfolding, and the non-vacuity witness

**Verification**:
- Single-file compile exits 0, zero `sorry`, zero warnings; `#print axioms` on the three new Goals reports at most `[propext, Classical.choice, Quot.sound]`.
- `grep -c "certStab\|certBox" ` on the `certAdm` definition is 2: both clauses are conjuncts of the certificate, which is the compiled form of "no datum is stated without the box/stab clause".
- The gate-7 mechanical check passes on the whole file: `grep -n "WorldHistory\|PlusTruthAt\|tpOf\|cellAt\|anchorCells" ` matches nothing outside header prose, so every field is built from `(Q5, step5, pend5, lab6, chi)` and the candidate set alone.
- `cert_accepts_Rchi` precedes every theorem whose statement is a negation or an inequality, checked by line number.

---

### Phase 5: The Adequacy Separation and the Restricted Countdown Profile [NOT STARTED]

**Goal**: Exhibit the separation that is this round's substantive deliverable — a set of product
states local coherence accepts and the certificate rejects, with the rejection proved structurally
rather than by brute force — and show the predecessor round's gate-6 win survives the restriction.

**Tasks**:
- [ ] Define `Rev` as the twentieth probe's `ev`-carrying 3-cycle and `ProfR` as the countdown
  profile of the restricted relation from the fibre `Ea ∩ R`.
- [ ] Prove `coh_accepts_Rev`: local coherence and bi-infinity hold on `Rev`. This is the half that
  makes the rejection informative rather than trivial, so it lands first.
- [ ] Prove `rev_eu_lfp_empty` through `eu_lfp_eq_empty_of_no_event` — `succR Rev x ⊆ Rev` gives the
  closure hypothesis and no member of `Rev` contains `psi2` gives the no-event hypothesis. Prove it
  this way, not by `decide`: the structural proof is what shows the mechanism rather than the number.
- [ ] Prove `cert_rejects_Rev` from `rev_eu_lfp_empty` and `cert_fwd_iff_eu_lfp` at `ψ := ev`.
- [ ] Prove `profR_period_three` (the restricted relation on `Rchi` is exactly the 3-cycle, so the
  backward-reachability operator has period 3), `profR_fibre_a_witness`, and
  `profR_separates_gate6_pair` from the three concrete values.
- [ ] Commit (explicit file list: the probe).

**Timing**: 2 hours

**Depends on**: 4

**Verification Tier**: local

**Commit Mode**: per-substep

**Scope Hypothesis**: `ProfR Rchi k` is the singleton `{(a5, Ta)}`, `{(c5, Tc)}`, `{(b5, Tb)}` at
`k % 3 = 0, 1, 2` respectively, and `Ea ∩ Rchi = {(a5, Ta)}`; confirm with `#eval` on `ProfR Rchi k`
for `k = 0, 1, 2, 3` before proving the periodicity Goal. These are plan-time hand computations of
the restricted graph, not measured figures.

**Tier Justification**: the same single-file compile exiting 0 is the complete covering check — the phase adds theorems and two definitions to the one standalone probe file and changes nothing any other file reads.

**Files to modify**:
- `specs/evidence/seam-gluing-ray-product/realizable-type-certificate.lean` - `Rev`, `ProfR`, the separation, and the restricted-profile statements

**Verification**:
- Single-file compile exits 0, zero `sorry`, zero warnings; `#print axioms` on the six new Goals reports at most `[propext, Classical.choice, Quot.sound]`; `grep -c native_decide` is 0.
- `#eval` on `ProfR Rchi k` for `k = 0, 1, 2, 3` matches the Scope Hypothesis; a mismatch blocks the phase rather than prompting a weaker statement.
- `rev_eu_lfp_empty`'s proof term mentions `eu_lfp_eq_empty_of_no_event`: `grep` the proof body, because a `decide`-closed version would satisfy the signature while abandoning the plan's decomposition.
- The eventual periodicity of the UNRESTRICTED countdown is not restated anywhere in the file: `grep -n "eventually_periodic" ` matches only header prose citing the seventeenth probe.

---

### Phase 6: Header, Registration, the Complete Gate Set, Summary, Return [NOT STARTED]

**Goal**: Write the probe's header in the collection's convention, wire it into the guard, discharge
the complete gate set, write the summary, and return `implemented` with the parent 761 untouched and
still `[BLOCKED]`.

**Tasks**:
- [ ] Replace the placeholder header with the convention: a capitalised verdict paragraph (THE
  CERTIFICATE PRESENTATION SEPARATES REALIZABLE-TYPE CANDIDATES FROM MERELY LOCALLY COHERENT ONES ON
  THE COPRIME-CYCLE FIXTURE: the fulfilment condition is EXISTENTIAL and is decided inside the
  candidate set by the existential dual of `AUFix`; a set local coherence accepts is rejected by the
  certificate at the eventuality `ev`; the universal and existential operators are compiled as
  DIFFERENT on a cycle with an exit; the `box` and `stab` clauses are present as checked
  biconditionals and are UNEXERCISED on this `stab`-free fixture, so gate 8 is SIDESTEPPED, not
  passed; adequacy is NOT discharged -- sufficiency of these conditions is an argument in the
  research report, not a theorem here); `## What was asked`; `## The verdict`; one section per gate
  1-9 in the research's order, each stating which theorems exhibit it or that nothing does;
  `## What this does NOT say`.
- [ ] The `## What this does NOT say` section must contain, at minimum: the conditions are NOT
  proved sufficient for realizability (the dovetailing argument is uncompiled); this is NOT Route A
  and nothing here decides generalized-Buchi nonemptiness; `(a5, evTa)` is NOT claimed
  non-realizable, and `psi2` is deliverable on this object through the 2-cycle `a -> d -> a` which
  `Rev` excludes by construction; gate 8 is SIDESTEPPED on a `stab`-free fixture and is the standing
  `BoxStabFree` scope line of the anchor/run layer, not a presentation-specific obstruction; gate 3
  is CARRIED; gates 1 and 2 are NOT ADDRESSED, with the compiled n-side qualification that the
  refuted tuple n-side coordinates pass gates 1 and 2 and remain blind to the shift the datum has to
  see; gate 9 is OPEN; obligations (b), (c) and (d) are untouched; eventual periodicity of the
  unrestricted countdown is SETTLED elsewhere and is neither re-derived nor claimed here; no
  `ladderRealized` or `LadderCons` in any form, hence none without the `box`/`stab` clause; no
  seventh tuple coordinate; no modulus, threshold or index is computed or claimed computable; a gate
  probing one coordinate certifies one coordinate only. Then the `Compile:` line.
- [ ] In `scripts/check-evidence-probes.sh`, add the boxed decision-row comment block directly below
  the twentieth probe's row, listing every Goal against what it exhibits, the "what it withholds"
  list, and the axioms; add `"seam-gluing-ray-product/realizable-type-certificate"` as the last
  `WIRED` entry.
- [ ] Run every command under **Verification** below, checking each exit status, never only its
  output.
- [ ] Write `specs/809_realizable_type_adequacy_countdown_profile/summaries/01_realizable-type-certificate-summary.md`
  per summary-format.md: the probe path; the per-gate verdict table copied from the header; the
  explicit statement that adequacy's SUFFICIENCY half and obligations (b), (c), (d) are NOT started
  and belong to a successor record; the Route A / Route B decision and why Route B was taken; the
  carried-figure note naming every verdict read from an earlier probe's header rather than re-run.
- [ ] Record issues and wins in the task's issue log as they arose, or attest explicitly in the
  summary that there were none beyond those already logged.
- [ ] Commit the header, registration and summary; return.

**Timing**: 2 hours

**Depends on**: 5

**Verification Tier**: full

**Commit Mode**: per-substep

**Scope Hypothesis**: `scripts/check-evidence-probes.sh`'s `WIRED` array holds 37 entries before
this phase and 38 after, so the guard reports `all 38 wired probe(s) compile`; confirm with
`sed -n '/^WIRED=(/,/^)/p' scripts/check-evidence-probes.sh | grep -c '^  "'` before and after the
edit. The 37 is a plan-time measurement of the current tree, re-measured at implementation time
rather than trusted. The `N` in the `git diff --stat HEAD~N` check below is this task's own commit
count at the time the check runs, counted then, not predicted here.

**Files to modify**:
- `specs/evidence/seam-gluing-ray-product/realizable-type-certificate.lean` - header only
- `scripts/check-evidence-probes.sh` - one decision-row comment block, one `WIRED` entry
- `specs/809_realizable_type_adequacy_countdown_profile/summaries/01_realizable-type-certificate-summary.md` - the implementation summary (new)
- `typst/generated/status.typ` - only if regenerated by the pre-commit hook (no diff expected)

**Verification** (the complete gate set — every command's exit status is checked, never only its
output):
- `bash .claude/scripts/lake-build-guard.sh build --timeout 600 -- env lean specs/evidence/seam-gluing-ray-product/realizable-type-certificate.lean` exits 0: eighteen `#print axioms` lines, each at most `[propext, Classical.choice, Quot.sound]`; zero errors; zero warnings.
- `bash -n scripts/check-evidence-probes.sh` exits 0; `bash scripts/check-evidence-probes.sh` exits 0 reporting `all 38 wired probe(s) compile`.
- `git ls-files --error-unmatch specs/evidence/seam-gluing-ray-product/realizable-type-certificate.lean` exits 0 after the commit, which the guard additionally requires.
- `bash scripts/check-module-invariants.sh` exits 0, run detached with a bounded waiter per `context/patterns/bounded-build-waiter.md` (C9 in particular: zero task-number citations under `FormalSystem/`, `docs/`, `scripts/` — the new decision row cites the probe filename and theorem names, never a task number).
- `bash .claude/scripts/check-task-references.sh --quiet` exits 0.
- Full `lake build` via `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build`, detached per `context/project/lean4/operations/long-builds.md`, exits 0 — expected a no-op success, since no library `.lean` file changes, but mandatory before the return.
- Lean Final Verification Stage over the probe: `bash .claude/scripts/lean-sorry-census.sh` reports 0 for the file; the vacuous-definition grep (`def .* := True`, `:= trivial`, `:= Unit`) matches nothing; `grep -c "^axiom "` is 0; `grep -c native_decide` is 0.
- `git diff --stat HEAD~N -- FormalSystem/ Tests/ docs/` (N = this task's commit count) is empty.
- `grep -rn "ladderRealized\|LadderCons" specs/evidence/seam-gluing-ray-product/realizable-type-certificate.lean` matches only header lines under "What this does NOT say".
- `grep -rn "ULive\|DischBwd\|SLive" specs/evidence/seam-gluing-ray-product/realizable-type-certificate.lean` matches only header prose explaining why the universal condition is not transplanted — never a definition or a theorem statement.
- `bash .claude/scripts/verify-deploy.sh` exits 0.
- `bash .claude/scripts/lean-challenge-snapshot.sh --check 809 .` reports no drift (ADVISORY: a drift finding is investigated and, if the recorded statement is genuinely wrong, the phase is marked `[BLOCKED]` and raised — never silenced by editing this plan's Challenge block to match what was implemented).
- `git status --short` shows no modified files outside this plan's `Files to modify` set.

## Lean Challenge Statements

The eighteen `theorem` declarations are the Goals and carry `sorry` bodies. Everything above them is
supporting context declared with `def`/`abbrev`, which the snapshot tool
(`lean-challenge-snapshot.sh`) neither counts as a Goal nor rewrites — but it DOES swallow
non-`theorem` text sitting between two `theorem` declarations into the preceding `:= sorry`, so
every definition precedes the first `theorem`. The definitional bodies of `euStep`, `euIter`,
`euLfp`, the `exit*` graph, the ported fixture, the certificate fields, `cohR`, `Rchi`, `Rev` and
`ProfR` are part of the contract and are written out: in particular `certFwd` and `certBwd` run the
fixpoint at `V := R` with `succ := succR R` / `preR R`, which is the "inside `R`" the research
report insists on, and `certAdm` conjoins the `stab` and `box` clauses rather than omitting them.
This block was compiled through `lake env lean` at plan time: exit 0, eighteen `declaration uses
'sorry'` warnings and no other diagnostic.

```lean
import FormalSystem.Metalogic.Decidability.RaySummary.AnchorLayer
import FormalSystem.Metalogic.Decidability.WitnessFamily.Sharing.Fulfil

open FormalSystem.Syntax FormalSystem.PlusLanguage FormalSystem.Metalogic.Decidability

namespace Probe809C

variable {α : Type*} [DecidableEq α]

def euStep (V : Finset α) (succ : α → Finset α) (isE isG : α → Bool) (X : Finset α) :
    Finset α :=
  V.filter (fun v => ∃ w ∈ succ v, isE w = true ∨ (isG w = true ∧ w ∈ X))

def euIter (V : Finset α) (succ : α → Finset α) (isE isG : α → Bool) : ℕ → Finset α
  | 0 => ∅
  | n + 1 => euStep V succ isE isG (euIter V succ isE isG n)

def euLfp (V : Finset α) (succ : α → Finset α) (isE isG : α → Bool) : Finset α :=
  euIter V succ isE isG (V.card + 1)

def exitSucc : Fin 4 → Finset (Fin 4) := fun i =>
  if i = 0 then {1, 3} else if i = 1 then {2} else if i = 2 then {0} else {3}

def exitIsE : Fin 4 → Bool := fun i => i == 3

def exitIsG : Fin 4 → Bool := fun _ => true

def pA : Atom := ⟨"p", none⟩
def rA : Atom := ⟨"r", none⟩
def aA : Atom := ⟨"a", none⟩
def p : PlusFormula := .atom pA
def la : PlusFormula := .atom aA

def nextPow : ℕ → PlusFormula → PlusFormula
  | 0, chi => chi
  | k + 1, chi => .untl .bot (nextPow k chi)

def pa : PlusFormula := p.and la
def psi2 : PlusFormula := pa.and (nextPow 2 pa)
def chi : PlusFormula := psi2.neg.and (PlusFormula.untl (.imp .bot .bot) psi2).neg

abbrev Q5 : Type := Bool × Fin 4

def pend5 : Q5 → Bool := fun q => q.1

def step5 : Q5 → Q5 → Bool := fun x y =>
  if x.1 then
    (if y.1 then
      ((x.2 == 0 && (y.2 == 1 || y.2 == 3)) || (x.2 == 1 && y.2 == 2) ||
        (x.2 == 2 && y.2 == 0) || (x.2 == 3 && y.2 == 0))
     else (y.2 == x.2))
  else (!y.1 && (y.2 == x.2))

def lab6 : Q5 → Atom → Bool := fun q at_ =>
  if at_ = pA then q.1 else if at_ = rA then !q.1 else (q.2 == 0)

def a5 : Q5 := (true, 0)
def b5 : Q5 := (true, 1)
def c5 : Q5 := (true, 2)

abbrev ClType (φ : PlusFormula) : Type :=
  {T : Finset PlusFormula // T ∈ (plusSubformulaClosure φ).powerset}

abbrev ProdState (Q : Type) (φ : PlusFormula) : Type := Q × ClType φ

def prodPreStep {Q : Type} [Fintype Q] [DecidableEq Q] {φ : PlusFormula}
    (pstep : ProdState Q φ → ProdState Q φ → Bool) (S : Finset (ProdState Q φ)) :
    Finset (ProdState Q φ) :=
  Finset.univ.filter (fun x => ∃ y ∈ S, pstep x y = true)

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

def coh6 : ProdState Q5 chi → ProdState Q5 chi → Bool := coh step5 pend5 lab6 chi

def mkT (L : List PlusFormula) : ClType chi :=
  ⟨(plusSubformulaClosure chi).filter (fun ψ => ψ ∈ L),
    Finset.mem_powerset.mpr (Finset.filter_subset _ _)⟩

def Ea : Finset (ProdState Q5 chi) := Finset.univ.filter (fun x => x.1 = a5)

def top : PlusFormula := .imp .bot .bot
def xpa : PlusFormula := nextPow 1 pa
def xxpa : PlusFormula := nextPow 2 pa
def bb : PlusFormula := pa.imp xxpa.neg
def cc : PlusFormula := p.imp la.neg
def ev : PlusFormula := PlusFormula.untl top psi2
def evnn : PlusFormula := ev.neg.neg
def dd : PlusFormula := psi2.neg.imp evnn

def TaL : List PlusFormula := [chi, psi2.neg, ev.neg, top, bb, pa, xxpa.neg, p, la]
def TbL : List PlusFormula := [chi, psi2.neg, ev.neg, top, bb, xxpa, cc, p, la.neg]
def TcL : List PlusFormula := [chi, psi2.neg, ev.neg, top, bb, xxpa.neg, xpa, cc, p, la.neg]

def Ta : ClType chi := mkT TaL
def Tb : ClType chi := mkT TbL
def Tc : ClType chi := mkT TcL

def evTaL : List PlusFormula := [psi2.neg, ev, evnn, dd, top, bb, pa, xxpa.neg, p, la]
def evTbL : List PlusFormula := [psi2.neg, ev, evnn, dd, top, bb, xxpa, cc, p, la.neg]
def evTcL : List PlusFormula := [psi2.neg, ev, evnn, dd, top, bb, xxpa.neg, xpa, cc, p, la.neg]

def evTa : ClType chi := mkT evTaL
def evTb : ClType chi := mkT evTbL
def evTc : ClType chi := mkT evTcL

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

def succR (R : Finset (ProdState Q5 chi)) (x : ProdState Q5 chi) :
    Finset (ProdState Q5 chi) :=
  R.filter (fun y => coh6 x y = true)

def preR (R : Finset (ProdState Q5 chi)) (x : ProdState Q5 chi) :
    Finset (ProdState Q5 chi) :=
  R.filter (fun y => coh6 y x = true)

def certLoc (R : Finset (ProdState Q5 chi)) : Bool :=
  decide (∀ x ∈ R, locCoh lab6 chi x = true)

def certBiInf (R : Finset (ProdState Q5 chi)) : Bool :=
  decide (∀ x ∈ R, 0 < (succR R x).card ∧ 0 < (preR R x).card)

def certFwd (R : Finset (ProdState Q5 chi)) : Bool :=
  decide (∀ x ∈ R, ∀ ψ ∈ x.2.1, isUntl ψ = true →
    x ∈ euLfp R (succR R) (fun w => decide ((argsOf ψ).2 ∈ w.2.1))
                          (fun w => decide ((argsOf ψ).1 ∈ w.2.1)))

def certBwd (R : Finset (ProdState Q5 chi)) : Bool :=
  decide (∀ x ∈ R, ∀ ψ ∈ x.2.1, isSnce ψ = true →
    x ∈ euLfp R (preR R) (fun w => decide ((argsOf ψ).2 ∈ w.2.1))
                         (fun w => decide ((argsOf ψ).1 ∈ w.2.1)))

def stabOk (R : Finset (ProdState Q5 chi)) (x : ProdState Q5 chi) (ψ : PlusFormula) : Bool :=
  decide (ψ ∈ x.2.1) == decide (∀ y ∈ R, y.1 = x.1 → argOf ψ ∈ y.2.1)

def certStab (R : Finset (ProdState Q5 chi)) : Bool :=
  decide (∀ x ∈ R, ∀ ψ ∈ plusSubformulaClosure chi, isStab ψ = true → stabOk R x ψ = true)

def certBox (R : Finset (ProdState Q5 chi)) : Bool :=
  decide (∀ x ∈ R, ∀ ψ ∈ plusSubformulaClosure chi, isBox ψ = true →
    (decide (ψ ∈ x.2.1) == decide (∀ y ∈ R, argOf ψ ∈ y.2.1)) = true)

def certAdm (R : Finset (ProdState Q5 chi)) : Bool :=
  certLoc R && certBiInf R && certFwd R && certBwd R && certStab R && certBox R

def cohR (R : Finset (ProdState Q5 chi)) (x y : ProdState Q5 chi) : Bool :=
  coh6 x y && decide (x ∈ R) && decide (y ∈ R)

def Rchi : Finset (ProdState Q5 chi) := {(a5, Ta), (b5, Tb), (c5, Tc)}

def Rev : Finset (ProdState Q5 chi) := {(a5, evTa), (b5, evTb), (c5, evTc)}

def ProfR (R : Finset (ProdState Q5 chi)) (k : ℕ) : Finset (ProdState Q5 chi) :=
  (prodPreStep (cohR R))^[k] (Ea ∩ R)

theorem eu_step_mono (V : Finset α) (succ : α → Finset α) (isE isG : α → Bool)
    {X Y : Finset α} (h : X ⊆ Y) :
    euStep V succ isE isG X ⊆ euStep V succ isE isG Y := sorry

theorem eu_lfp_fixed (V : Finset α) (succ : α → Finset α) (isE isG : α → Bool) :
    euStep V succ isE isG (euLfp V succ isE isG) = euLfp V succ isE isG := sorry

theorem eu_mem_lfp_iff (V : Finset α) (succ : α → Finset α) (isE isG : α → Bool) (v : α) :
    v ∈ euLfp V succ isE isG ↔
      v ∈ V ∧ ∃ w ∈ succ v, isE w = true ∨ (isG w = true ∧ w ∈ euLfp V succ isE isG) :=
  sorry

theorem eu_lfp_least (V : Finset α) (succ : α → Finset α) (isE isG : α → Bool)
    {X : Finset α} (h : euStep V succ isE isG X ⊆ X) : euLfp V succ isE isG ⊆ X := sorry

theorem eu_mem_lfp_iff_exists_path (V : Finset α) (succ : α → Finset α) (isE isG : α → Bool)
    (v : α) :
    v ∈ euLfp V succ isE isG ↔
      ∃ (n : ℕ) (f : ℕ → α), 0 < n ∧ f 0 = v ∧ (∀ i < n, f i ∈ V) ∧
        (∀ i < n, f (i + 1) ∈ succ (f i)) ∧ isE (f n) = true ∧
        (∀ i, 0 < i → i < n → isG (f i) = true) := sorry

theorem eu_lfp_eq_empty_of_no_event (V : Finset α) (succ : α → Finset α) (isE isG : α → Bool)
    (hclosed : ∀ v ∈ V, ∀ w ∈ succ v, w ∈ V) (hno : ∀ w ∈ V, isE w = false) :
    euLfp V succ isE isG = ∅ := sorry

theorem au_lfp_ne_eu_lfp_on_exit_graph :
    AUFix.lfp Finset.univ exitSucc exitIsE exitIsG
      ≠ euLfp Finset.univ exitSucc exitIsE exitIsG := sorry

theorem untl_propagates_along_coh {Q : Type} [Fintype Q] [DecidableEq Q]
    (step : Q → Q → Bool) (pend : Q → Bool) (lab : Q → Atom → Bool) (φ : PlusFormula)
    (g : ℕ → ProdState Q φ) (hg : ∀ k, coh step pend lab φ (g k) (g (k + 1)) = true)
    (u e : PlusFormula) (hmem : PlusFormula.untl u e ∈ plusSubformulaClosure φ)
    (i n : ℕ) (hin : i ≤ n) (hcar : PlusFormula.untl u e ∈ (g i).2.1) :
    (∃ j, i < j ∧ j ≤ n ∧ e ∈ (g j).2.1 ∧ ∀ r, i < r → r < j → u ∈ (g r).2.1) ∨
      (PlusFormula.untl u e ∈ (g n).2.1 ∧ ∀ r, i < r → r ≤ n → u ∈ (g r).2.1) := sorry

theorem cohR_le_coh (R : Finset (ProdState Q5 chi)) (x y : ProdState Q5 chi)
    (h : cohR R x y = true) : coh6 x y = true ∧ x ∈ R ∧ y ∈ R := sorry

theorem chi_closure_box_snce_stab_free :
    ∀ ψ ∈ plusSubformulaClosure chi,
      isBox ψ = false ∧ isSnce ψ = false ∧ isStab ψ = false := sorry

theorem cert_fwd_iff_eu_lfp (R : Finset (ProdState Q5 chi)) :
    certFwd R = true ↔
      ∀ x ∈ R, ∀ ψ ∈ x.2.1, isUntl ψ = true →
        x ∈ euLfp R (succR R) (fun w => decide ((argsOf ψ).2 ∈ w.2.1))
                              (fun w => decide ((argsOf ψ).1 ∈ w.2.1)) := sorry

theorem cert_accepts_Rchi : certAdm Rchi = true := sorry

theorem coh_accepts_Rev : certLoc Rev = true ∧ certBiInf Rev = true := sorry

theorem rev_eu_lfp_empty :
    euLfp Rev (succR Rev) (fun w => decide (psi2 ∈ w.2.1)) (fun w => decide (top ∈ w.2.1))
      = ∅ := sorry

theorem cert_rejects_Rev : certAdm Rev = false := sorry

theorem profR_period_three (k : ℕ) : ProfR Rchi (k + 3) = ProfR Rchi k := sorry

theorem profR_fibre_a_witness (k : ℕ) (hk : 3 ∣ k) : (a5, Ta) ∈ ProfR Rchi k := sorry

theorem profR_separates_gate6_pair (C P : ℕ) (hC : 3 ∣ C) (h3 : ¬ 3 ∣ (P + 1)) :
    ProfR Rchi C ≠ ProfR Rchi (C + (P + 1)) := sorry

end Probe809C
```

## Testing & Validation

- [ ] The probe compiles through `bash .claude/scripts/lake-build-guard.sh build --timeout 600 -- env lean specs/evidence/seam-gluing-ray-product/realizable-type-certificate.lean` with exit 0, zero errors and zero warnings.
- [ ] Zero `sorry`: `bash .claude/scripts/lean-sorry-census.sh` reports 0 for the file.
- [ ] No new axiom: `#print axioms` on all eighteen Goals reports at most `[propext, Classical.choice, Quot.sound]`; no `sorryAx`, no `ofReduceBool`, no `native_decide` anywhere in the file.
- [ ] `bash scripts/check-evidence-probes.sh` exits 0 reporting `all 38 wired probe(s) compile`, and the probe is git-tracked.
- [ ] The gate-7 mechanical check passes: no `WorldHistory`, `PlusTruthAt`, `tpOf`, `cellAt` or `anchorCells` outside header prose.
- [ ] `cert_accepts_Rchi` precedes every negative or inequality statement in the file, by line number.
- [ ] `bash scripts/check-module-invariants.sh`, `bash .claude/scripts/check-task-references.sh --quiet` and `bash .claude/scripts/verify-deploy.sh` each exit 0.
- [ ] Full `lake build` exits 0 (expected no-op: no library file changes).
- [ ] `git diff --stat` over `FormalSystem/`, `Tests/` and `docs/` across this task's commits is empty.
- [ ] `bash .claude/scripts/lean-challenge-snapshot.sh --check 809 .` reports no drift (advisory).

## Artifacts & Outputs

- `specs/evidence/seam-gluing-ray-product/realizable-type-certificate.lean` — the twenty-first wired evidence probe: the existential until-fixpoint, the guarded-path characterization, the compiled universal-versus-existential separation, the chain-to-ray composition theorem, the certificate presentation with its `box` and `stab` clauses, the non-vacuity witness, the adequacy separation, and the restricted countdown profile. Eighteen Goal theorems, sorry-free, no new axiom.
- `scripts/check-evidence-probes.sh` — one boxed decision-row comment block and one `WIRED` entry (37 entries before, 38 after).
- `specs/809_realizable_type_adequacy_countdown_profile/plans/01_realizable-type-certificate.md` — this plan.
- `specs/809_realizable_type_adequacy_countdown_profile/summaries/01_realizable-type-certificate-summary.md` — the implementation summary.

## Rollback/Contingency

- **Per phase**: each proof phase appends to one new file and commits on its own green sub-steps, so a failed phase is reverted by `git revert` of its own commits; no rollback of the working tree is required and none is to be taken as a routine precaution.
- **If a Goal cannot be proved as pinned**: mark the phase `[BLOCKED]`, record what was tried and the goal state reached, and raise it. Do NOT substitute a same-named weaker statement, add a hypothesis, specialise a quantifier, or drop a certificate field — `plan-compliance.md` Statement Fidelity governs every signature in `## Lean Challenge Statements`, and a weakened `certFwd`/`certBwd` ("a path somewhere in the carrier") or a `certAdm` missing its `stab`/`box` conjunct is exactly the defect that rule exists to catch.
- **If a Scope Hypothesis is falsified** (a closure cardinality, a fixpoint value, a `ProfR` value, an `untl`-member count): the phase is blocked and the figure is re-derived, never worked around by restating the Goal that depended on it. A genuine overcount is closed with `[COMPLETED WITH EXCLUSIONS]` and a `#### Reasoned Exclusions` record whose Evidence column cites the `#eval` that falsified it.
- **If a genuine rollback of uncommitted work becomes necessary**: take the snapshot first per `context/contracts/recovery.md`'s rollback rung, then run the destructive command; a bare `git-snapshot.sh 809` is not a start-of-phase precaution, and an ordinary defensive checkpoint uses `--no-revert`.
- **Whole-task contingency**: a refutation is an acceptable and successful outcome. If the certificate presentation turns out to be refuted on this fixture — for instance if no non-empty candidate set satisfies all seven fields — the probe records the refutation with its witness, the header's verdict paragraph is rewritten as a refutation, and the task returns `implemented`. It does NOT return a weakened, same-named substitute for the certificate, and it does not fall back to the universal condition whose transplant the research round already foreclosed.
