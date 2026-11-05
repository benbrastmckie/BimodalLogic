# Research Report: One-sided ▷/◁ type transport against the refuted two-sided shape

**Task**: 855 - Probe the one-sided ▷/◁ type transport against the refuted two-sided shape
**Started**: 2026-11-04T00:00:00Z
**Completed**: 2026-11-04T00:00:00Z
**Effort**: one probe (as recorded)
**Dependencies**: None
**Sources/Inputs**:
- Codebase: `FormalSystem/Metalogic/Decidability/RaySummary/` (`LadderAgree.lean`, `LadderModel.lean`, `AnchorLayer.lean`, `LadderChain.lean`, `LadderPump.lean`, `README.md`)
- Codebase: `FormalSystem/PlusLanguage/PlusRayFibre.lean`, `FormalSystem/PlusLanguage/PlusPasting.lean`, `FormalSystem/OpenLanguage/OpenTruth.lean`
- Compiled probes: `specs/evidence/seam-gluing-ray-product/{ladder-cell-refutation,ladder-cell-index-obstructions,ladder-residue-index-refutation,ladder-joint-index-refutation,ladder-splice-type-refutation,ladder-cell-agreement-refutation}.lean`
- Compiled probe: `specs/559_nondeterministic_canonical_model_tm_star_completeness/probes/05_stab-definable-from-open-modals.lean`
- lean-lsp MCP: not used; evidence tier is **compiled probe** (`lake env lean` under the build-guard flock) plus source reading
**Artifacts**:
- `specs/855_one_sided_open_modal_type_transport_probe/reports/01_one-sided-open-modal-transport.md`
- `specs/855_one_sided_open_modal_type_transport_probe/probes/01_one-sided-count-move.lean` (sorry-free, exit 0, no warnings)
**Standards**: report-format.md, subagent-return.md

## Executive Summary

- **VERDICT: NEGATIVE.** The one-sided factorization given by ▷/◁ does not crack the transport
  condition. All six recorded refutation mechanisms survive the one-sided relaxation, and two of
  them survive it in a *strictly stronger* form than they were recorded in.
- **The reason is one fact, and it is now compiled.** The ladder's `c` is forward-determined and
  so is every separating formula in the refutation collection. `cntAt_eq_of_pend_eq`'s own proof
  reads its hypothesis only at positions **at or above** the compared one, so the countdown
  rigidity holds under a **forward-only** pend-profile agreement:
  `Probe855.cntAt_eq_of_pend_eq_fwd`. The refutations were never two-sided in their *mechanism*;
  `ladder-cell-refutation.lean` says so in its own words — "the witness is forward-only, as every
  probe in this collection is".
- **The pincer.** The ◁-shaped relaxation (future atom row preserved, **whole past freed**) is
  refuted outright: `Probe855.futAtomPreservingCountMove_refuted`, from which the recorded
  two-sided `atomPreservingCountMove_refuted` is a corollary
  (`Probe855.atomPreservingCountMove_refuted_via_fwd`). The ▷-shaped relaxation (past atom row
  preserved, **whole future freed**) does move the countdown — and is already refuted as a
  *type*-preserving transport by `Probe761S.splice_type_invariance_refuted`, because the landed
  splice `exists_spliced_ladderPath_of_pend_past` **is** a ▷-shaped count move.
- **Structural reason the factorization could not have helped.** `⊡`, ▷ and ◁ all quantify inside
  the fibre over a **fixed** seam world state (`plusStab_iff_rays`, `StabFibre`), and
  `AgreeUpTo τ σ t` / `AgreeFrom τ σ t` both include `s = t`, so each fixes the full ladder state
  `(q, c, n)` at the evaluation point. `cellAt` is *defined* by that same fibre quantifier. So
  `⊡φ ↔ ▷◁φ` factors the quantifier that **defines one cell**; it supplies no move **between**
  two cells, which is what `cellAt … (q,c,n) = cellAt … (q,c',n')` asks for. This matches the
  honest prior exactly: the ← half supplies no closure principle, only a decomposition.
- **Recommended consequence**: the open-modal idea is closed on the decidability front; the owed
  `tpOf` pumping-lemma record proceeds **unchanged** (this measurement does not change the terms
  under which it can be stated); the main argument for retargeting Stage 1's object language on
  *decidability* grounds is removed. No decidability consequence is claimed either way.

## Context & Scope

What was researched: whether the ONE-SIDED factorization `⊡φ ↔ ▷◁φ ↔ ◁▷φ` (compiled, choice-free,
`Probe559R05.stab_iff_ofut_opast` / `stab_iff_opast_ofut`) yields a type-preserving transport
condition on the deadline ladder that escapes the recorded refutations of the two-sided pointwise
shape.

Constraints honoured: no `sorry`, no new axiom, no vacuous definition, no finite-fibre and no
finite-width assumption (`not_finite_width_fmp` stands untouched), no decidability consequence
claimed, no recorded Challenge statement weakened, nothing written under `FormalSystem/` or
`Tests/`. The prototype probe was placed under **this task's** `probes/` directory rather than
`specs/evidence/seam-gluing-ray-product/`, to respect the declared contention with the live
ladder-realization task and its same-round `scripts/check-evidence-probes.sh` wiring obligation.
Precedent for a task-record prototype rather than a wired probe: `tight-chain-regime-b.lean` and
`spanning-divisibility.lean`, both recorded as such in `RaySummary/README.md`.

Evidence tier: compiled. The probe was compiled with `lean` on the repository's own oleans while
holding `flock` on `.lake/build-guard.lock` — the same mechanism and the same lock
`scripts/check-evidence-probes.sh` takes, so no unguarded `.lake` read occurred. lean-lsp MCP was
not consulted; no claim below rests on an LSP index result.

## Findings

### The two projections, pinned to the declarations that exist

`OpenTruth.lean`'s clauses (lines 92–93) fix the directions with no room for interpretation:

| Modal | Clause | Quantification domain | Which half-line is FIXED |
|-------|--------|----------------------|--------------------------|
| `▷φ` (`.ofut`) | `∀ σ, AgreeUpTo τ σ t → φ at (σ,t)` | histories agreeing with `τ` at every `s ≤ t` | the **past**; the future varies |
| `◁φ` (`.opast`) | `∀ σ, AgreeFrom τ σ t → φ at (σ,t)` | histories agreeing with `τ` at every `t ≤ s` | the **future**; the past varies |

So the ▷ projection **constrains the future factor**: a ▷-transport is a replacement of the future
half of a ladder path at a frozen past. ◁ is the mirror. This is `plusStab_iff_rays` read in the
object language: `⊡` quantifies over `PastRay × FutRay` glued at the seam state, ▷ projects onto
the `FutRay` factor and ◁ onto the `PastRay` factor (`seamOmegaEquiv`, `BwdSeq × FwdSeq`).

**First finding, and it is structural.** `AgreeUpTo τ σ t` is `∀ s ≤ t, τ.state s = σ.state s`,
including `s = t`; `AgreeFrom` likewise. On `ladderFrameAdm` a world state is
`(t, ⟨(q, c, n), h⟩)`, so **both** projections fix the countdown `c` and the register `n` at the
evaluation point. The literal ▷ and ◁ quantifiers therefore give **no count move at all**: they
are sub-quantifiers of `⊡`, and `⊡`'s own quantification domain is precisely the set `cellAt`
quantifies over (`cellAt M φ w z = {T | ∃ σ, σ.state z = w ∧ tpOf M φ σ z = T}`,
`AnchorLayer.lean`). `⊡φ ↔ ▷◁φ` factors the quantifier that defines **one** cell. The transport
the ladder front needs is cross-fibre — `cellAt … (q,c,n) = cellAt … (q,c',n')`, the shape of the
reserved `cellLE_zero_const_of_kappa_eq` / `CellLEZeroConstOfKappaEq` — and no factorization of a
single fibre's quantifier produces one.

To get a transport *at all*, the one-sided condition must relax "state agreement on a half-line"
to "**atom-row** agreement on a half-line" (the valuation of `ladderModel` reads the object
component `q` only). That relaxation is the honest one-sided reading, and it is what was measured.

### The one-sided transport conditions, stated against the existing declarations

Compiled in `probes/01_one-sided-count-move.lean` against `AtomPreservingCountMove`
(`LadderAgree.lean:2640`), with `objAt`/`cntAt`/`nxtAt`/`IsLadderPath`/`Adm` from `LadderAgree.lean`
and `LadderModel.lean`:

- **▷-shaped** (past fixed, future free) — `Probe855.PastAtomPreservingCountMove`: identical to
  `AtomPreservingCountMove` except the atom-row clause reads `∀ v ≤ z, ∀ p, lab (objAt g' v) p = lab (objAt g v) p`.
- **◁-shaped** (future fixed, past free) — `Probe855.FutAtomPreservingCountMove`: the same with
  `∀ v, z ≤ v → …`.

Both are **genuine relaxations**, compiled: `futAtomPreservingCountMove_of_twoSided` and
`pastAtomPreservingCountMove_of_twoSided`. So refuting either is strictly stronger than the
recorded refutation of the two-sided schema, and showing the two-sided mechanism bites one of them
is a real measurement, not a restatement.

### The load-bearing new fact: the countdown rigidity is forward-only

`Probe855.cntAt_eq_of_pend_eq_fwd` (sorry-free, `[propext, Classical.choice, Quot.sound]`):

```lean
theorem cntAt_eq_of_pend_eq_fwd (g g' : ℤ → LadderState Q pend)
    (hg : IsLadderPath step pend g) (hg' : IsLadderPath step pend g') (u : ℤ)
    (hpend : ∀ v : ℤ, u ≤ v → pend (objAt g v) = pend (objAt g' v)) :
    cntAt g u = cntAt g' u
```

This is `cntAt_eq_of_pend_eq`'s own proof at the hypothesis it actually consumes. Every position
the proof touches is `u` itself or `u + cntAt _ u + 1`, both `≥ u`: at a pending position the
countdown is the distance to the region's last pending position (`cntAt_sub_of_pend`,
`not_pend_of_count`), at an idle one it is `0` (`cntAt_eq_zero_of_idle`). The landed theorem is
untouched; nothing is weakened.

Its atom-row reading, `Probe855.cntAt_eq_of_lab_eq_fwd_of_pendFactorsLab`, is the one-sided form of
`cntAt_eq_of_lab_eq_of_pendFactorsLab`.

### Mechanism-by-mechanism measurement

The question asked is not "is the one-sided form literally the refuted statement" but "does the
MECHANISM still bite". Row 6 is the pointwise-transport line named in the task description; rows
1–5 are the index/transport line of the `RaySummary/README.md` record.

| # | Mechanism (probe) | Separating device | Direction it lives in | Bites ▷-shaped? | Bites ◁-shaped? |
|---|-------------------|-------------------|-----------------------|-----------------|-----------------|
| 1 | Counter-pair stabilization refuted (`ladder-cell-refutation.lean`) | `phi := p U (r ∧ X(p ∧ X r))`, with `X χ := ⊥ U χ` — `untl`/`X` only, no `snce` | **forward** (the probe's own note: "the witness is forward-only, as every probe in this collection is"; the past-looking twin `snce ⊤ r` is paper-level and *not* machine-checked) | **YES** — the gap `n - c` is read forward, inside ▷'s varying factor | **YES** — the device is ◁-rigid (pure future), so freezing the future freezes the refutation too |
| 2 | Clipped-coordinate index refuted (`ladder-cell-index-obstructions.lean`) | the region's first idle state at distance **exactly `c + 1`**, where the countdown's parity is observable (`cell_succ_ne`, `ladderIndex_not_factoring`) | **forward** (a distance measured upward from the compared position) | **YES** | **YES** |
| 3 | Residue index refuted at object-only parameters (`ladder-residue-index-refutation.lean`) | `object_only_parameters_refuted` (threshold must be formula-derived: "two per `untl` nesting … **nothing per `snce` (the past of a pending position is the same infinite alternating run on both paths)**"), `reach_period_refuted` (reach sets of the step graph) | **forward**, and the probe states the witnesses are already past-**agreeing** pairs | **YES**, decisively: the two witnesses *already* have identical pasts, so they already inhabit the ▷-congruence class — the one-sided relaxation adds nothing to relax | **YES** |
| 4 | Joint object+formula parameters refuted (`ladder-joint-index-refutation.lean`, gate 6) | the letter-free pattern `(p ∧ l_a) ∧ X X (p ∧ l_a)` forbidden at every position (`chi_forces_dfree`, `period_collision`, `joint_parameters_refuted`) | **forward** (`X X` only) | **YES** | **YES** |
| 5 | Splice type invariance refuted (`ladder-splice-type-refutation.lean`) | `⊤ U (p ∧ ⊤ U p)` counts occurrences at **unbounded** forward distance | **forward** | **YES** — and this is the row that kills the ▷ side; see below | **YES** (the device is pure-future, hence preserved by ◁'s congruence, so no collision is removed) |
| 6 | `AtomPreservingCountMove` refuted (`ladder-cell-agreement-refutation.lean`) | `cntAt_eq_of_pend_eq` + `pendFactorsLab_of_atom` ⟹ `cntAt_eq_of_lab_eq_of_pendFactorsLab` | **forward**, now compiled as such (`cntAt_eq_of_pend_eq_fwd`) | **NO** — freeing the future frees the pend profile forward, hence frees the countdown. This is the one place the one-sided form escapes a recorded mechanism | **YES, strictly harder** — `futAtomPreservingCountMove_refuted` |

### The two sides, and why neither is usable

**◁ side (future fixed, past free): refuted outright.**
`Probe855.futAtomPreservingCountMove_refuted` carries *exactly* the hypotheses the landed
`atomPreservingCountMove_refuted` carries (`g`, `hg`, `z`, `c'`, `hadm : c' ∈ Adm pend (objAt g z)`,
`hne : cntAt g z ≠ c'`) and refutes the strictly weaker ◁-shaped schema. Freeing the **entire
past** buys nothing. `Probe855.atomPreservingCountMove_refuted_via_fwd` derives the recorded
two-sided refutation from it through the relaxation, which is the precise sense in which the ◁
projection removes nothing.

Non-vacuity is **inherited, not re-derived**: those hypotheses are discharged on the two-state
object of `ladder-cell-agreement-refutation.lean` (one pending state, one idle, `step` complete,
the pending bit carried as the atom `p`, so `PendFactorsLab` holds by `pendFactorsLab_of_atom`).
Re-instantiating against that object is a mechanical step for an implement round, not a research
gap.

**▷ side (past fixed, future free): the count move exists and is already refuted as a type
transport.** The ▷-shaped count move is not a new construction to be invented — it is **already
landed**, as `exists_spliced_ladderPath_of_pend_past` (`LadderAgree.lean:1296`):

- `spliceObj_eq_of_le` gives `objAt g' v = objAt g v` at every `v ≤ a` — the atom row, hence the
  valuation, is preserved on the whole past half-line, which is exactly ▷'s congruence;
- `spliced_at_region` gives `cntAt g' v = cntAt g v + l` inside the region — the countdown **moves**;
- the future is where the two paths differ: the splice duplicates the pumped block.

And `Probe761S.splice_type_invariance_refuted`, via `Probe761S.exists_separating_splice`, says
that this ▷-shaped move does **not** preserve the realized stab-free type: at `z = -(TcS)`, with
`hpast : ∀ p ≤ 0, pendS (objAt g p) = true` (pending forever into the past, so the two paths agree
on the object row at every `v ≤ 0`, a fortiori at every `v ≤ z`), the types differ,
non-vacuously (`PlusFormula.top` in both). The countdown displacement at `z` itself follows in one
step from the probe's compiled `∀ v, cntAt g' v = spliceCnt g 0 2 v` together with
`spliceCnt_add_of_mem_region`, the region condition being supplied by the pending-forever regime
(`cntAt_succ_of_pend_pend` iterated); that one step is an inference from landed lemmas and is not
itself a compiled line of that probe.

**The pincer, stated once.** `cntAt g z` is determined by the pend profile on `[z, ∞)`
(`cntAt_eq_of_pend_eq_fwd`). `tpOf M φ σ z` for an `untl`-bearing closure is determined by — and
only by — the same half-line, with **unbounded** reach (mechanism 5). The ladder's counter and
the closure's eventualities read **the same half-line**. One-sidedness separates past from future;
the obstruction is wholly inside the future. Hence:

- freeze the future (◁): the type is preserved and the counter is rigid — nothing to transport;
- free the future (▷): the counter moves and the type is not preserved — nothing transported.

There is no third option: ▷ and ◁ are the only two projections, and `⊡ = ▷◁ = ◁▷` composes them
without introducing anything else (the ← half's only structural input is `[F.IsRegular]`, used
once, through `paste`).

### External Resources

No external search was required and none was performed: the enabling biconditional, all six
refutation mechanisms, and every declaration the condition had to be stated against are in-tree
and compiled. For orientation only, the literature description of this obstruction is already
recorded in `RaySummary/README.md` — Hodkinson–Wolter–Zakharyaschev 2000 Definition 12 /
Theorem 14 (⇐) and Gabbay–Kurucz–Wolter–Zakharyaschev 2003 Theorem 13.6 presuppose a **freely
chosen** state function and run set, which this semantics does not have. That entry is of
UNVERIFIED-summary provenance in the corpus (`hodkinson_wolter_zakharyaschev_2000_decidable_fragments_fotl`),
so it orients the shape and sources no claim here. Nothing in the literature briefing bears on the
one-sided question specifically; the ▷/◁ split is this repository's own object-language device.

### Recommendations

1. **Close the open-modal idea on the decidability front.** The last recorded idea for using ▷/◁
   there is measured and negative. State the verdict as the record, not as a gap.
2. **Land the two compiled facts as a wired probe, not as library code.** An implement round
   should move `probes/01_one-sided-count-move.lean` to
   `specs/evidence/seam-gluing-ray-product/one-sided-count-move-refutation.lean`, instantiate the
   refutation against `ladder-cell-agreement-refutation.lean`'s two-state object to discharge
   non-vacuity in-file, and wire it into `scripts/check-evidence-probes.sh` **in the same round**
   (that script takes the shared build-guard flock; keep it that way). This must run in a cycle of
   its own, never concurrently with the ladder-realization task's dispatch.
   `cntAt_eq_of_pend_eq_fwd` is a strict sharpening of a landed theorem and would be a legitimate
   `LadderAgree.lean` addition later, but that is a library edit this task forbids.
3. **The `tpOf` pumping-lemma record proceeds unchanged.** This measurement explicitly does not
   change the terms under which that lemma can be stated: its obvious shape stays refuted by
   mechanism 5, and the one-sided reading of it is the *same* refuted shape (the splice already is
   the one-sided move). Nothing here is an input to re-planning that record.
4. **Do not restate the refuted shape in a half-line form and call it new.** Any future proposal
   must say which half-line the counter is read from and which the formula is read from. If both
   answers are "forward", the proposal is already refuted; `cntAt_eq_of_pend_eq_fwd` plus
   mechanism 5 is the two-line test.
5. **Where a genuine opening remains** (recorded, not pursued here): the live route is the one
   `LadderChain.lean` already occupies — the upward cell inclusion
   `cellAt_subset_of_shift_of_pend_past` and the path-level downward inclusion
   `mem_cellAt_of_shift_of_hasForwardSlack_exact` under the forward-slack regime, with the gap to
   `CellLEZeroConstOfKappaEq` being the tight (doubling) chain of pins. That gap is **not** a
   one-sidedness gap and is untouched by this report.

## Decisions

1. **The one-sided transport condition is stated as an atom-row relaxation on a half-line**, not
   as a literal instance of the ▷ or ◁ quantifier. Reason: both quantifiers fix the full world
   state at the evaluation point, so neither admits a count move at all; a literal reading would
   have made the task vacuous rather than measured. The relaxation is the strongest form of the
   condition the projection can be read as giving, and it is recorded as a `def` so its refutation
   is a theorem about a named object (the precedent `AtomPreservingCountMove` sets).
2. **Both one-sided forms are measured, not just the ▷ one.** The task description names ▷ as the
   candidate, but ◁ is the other projection of the same biconditional and the forward sharpening
   bears on it; reporting only ▷ would have left the measurement half-done.
3. **The prototype goes under this task's directory, not under `specs/evidence/`.** Reason: the
   declared contention with the live ladder-realization task over `specs/evidence/` and
   `scripts/check-evidence-probes.sh`, plus the same-round wiring obligation. Recorded as an issue.
4. **The ▷-side refutation is attributed to the already-landed `splice_type_invariance_refuted`
   rather than re-proved.** Reason: the splice construction already satisfies the ▷-shaped
   condition verbatim; re-deriving a second witness would add a probe and no information.
5. **No decidability consequence, no weakening, no new axiom.** `not_finite_width_fmp` stands;
   `CellLEZeroConstOfKappaEq`'s status is unchanged (refuted at the one-depth `ParamsOkPre`,
   neither proved nor refuted under `ParamsOk`); `cellLE_zero_const_of_kappa_eq` remains claimed
   by nothing.

## Risks & Mitigations

- **Risk**: the one-sided relaxation chosen here is not the only possible reading of "the ▷
  projection's transport condition"; a reader could propose a different relaxation (e.g. agreement
  on a bounded forward window, or agreement of the *type* rather than the atom row on a half-line).
  **Mitigation**: the pincer is stated at the level of the mechanism, not the schema — any
  condition whose freedom is forward-of-`z` loses the type (mechanism 5, unbounded reach), and any
  condition whose freedom is backward-of-`z` loses the counter move
  (`cntAt_eq_of_pend_eq_fwd`). The two-line test in Recommendation 4 is what makes this
  falsifiable rather than rhetorical.
- **Risk**: the probe's refutation hypotheses are not discharged in-file, so a reader could mistake
  it for a vacuous refutation. **Mitigation**: the hypotheses are *literally* those of the landed
  `atomPreservingCountMove_refuted`, discharged on a compiled object elsewhere; Recommendation 2
  makes in-file instantiation the first implement step.
- **Risk**: the "five recorded refutation mechanisms" are not enumerated under that name anywhere
  in-tree, so a count mismatch is possible. **Mitigation**: six rows are reported — the five
  index/transport rows of the `RaySummary/README.md` record plus the pointwise-transport row the
  task description names — so no mechanism is skipped on a counting disagreement. Each row names
  its probe file and its separating device.
- **Risk**: the countdown-displacement step on the ▷ side is an inference from landed lemmas, not
  a compiled line of the splice probe. **Mitigation**: flagged as such in the text; the ▷-side
  verdict does not depend on it (type non-preservation under past-agreement is compiled on its own).

## Tactic Survey Results

| Goal | Tactic | Result | Premises/Config |
|------|--------|--------|-----------------|
| `cntAt_eq_of_pend_eq_fwd` (forward-only countdown rigidity) | structural: `by_cases` + `Nat.lt_or_ge` + `cntAt_sub_of_pend`/`not_pend_of_count` + `omega`/`push_cast; ring` | success | the landed proof of `cntAt_eq_of_pend_eq`, re-run at the weaker hypothesis; `omega` discharges the `u ≤ u + (cntAt _ u : ℤ) + 1` side goals |
| `futAtomPreservingCountMove_of_twoSided`, `pastAtomPreservingCountMove_of_twoSided` | `intro`/`obtain`/`exact` | success | axiom-free (`does not depend on any axioms`) |
| `futAtomPreservingCountMove_refuted` | `intro`/`obtain` + `cntAt_eq_of_lab_eq_fwd_of_pendFactorsLab` | success | `PendFactorsLab`; no automation needed |
| `atomPreservingCountMove_refuted_via_fwd` | term-mode composition | success | the relaxation lemma |

No search tool (`leansearch`, `loogle`, `leanfinder`, `state_search`, `hammer_premise`) was
invoked: every declaration needed was located by `grep` over the tree and read in source, and no
Mathlib lemma beyond `omega`/`push_cast`/`Nat.lt_or_ge` was required. No rate limit was hit and no
MCP recovery path was exercised. No blocked tool (`lean_diagnostic_messages`, `lean_file_outline`)
was called.

## Context Extension Recommendations

- **Topic**: the half-line test for a proposed ladder transport condition.
  **Gap**: `context/project/lean4/` has no note recording that the ladder's counter and the
  closure's eventualities are both forward-determined, so successive rounds have re-proposed
  transport conditions whose freedom lies forward of the compared position.
  **Recommendation**: add a short pattern note (or a paragraph to
  `FormalSystem/Metalogic/Decidability/RaySummary/README.md` in an implement round that is
  permitted to edit it) stating the two-line test: name the half-line the counter is read from and
  the half-line the formula is read from; if both are forward, `cntAt_eq_of_pend_eq_fwd` plus
  `splice_type_invariance_refuted` already decide the proposal.

## Appendix

**Search queries / greps used** (all in-tree; no web and no Mathlib search):
`AtomPreservingCountMove`, `cntAt_eq_of_pend_eq`, `cntAt_eq_of_obj_eq`, `pendFactorsLab_of_atom`,
`cntAt_eq_of_lab_eq_of_pendFactorsLab`, `tpOf_stabFree_eq_of_splice`,
`splice_type_invariance_refuted`, `plusStab_iff_rays`, `AgreeUpTo`, `AgreeFrom`,
`exists_spliced_ladderPath_of_pend_past`, `spliceObj_eq_of_le`, `spliced_at_region`,
`CellLEZeroConstOfKappaEq`, `cellLE_zero_const_of_kappa_eq`, `anchorCells_ncard_le`,
`not_finite_width_fmp`; `grep -n "^#\{1,4\} "` over `RaySummary/README.md`; the probe-header block
of `scripts/check-evidence-probes.sh` for each `ladder-*` probe's recorded verdict.

**Declarations the verdict rests on**

| Role | Declaration | File |
|------|-------------|------|
| the biconditional | `Probe559R05.stab_iff_ofut_opast`, `stab_iff_opast_ofut`, `openValid_ofut_opast_imp_stab` | `specs/559_…/probes/05_stab-definable-from-open-modals.lean` |
| its metatheoretic original | `PlusLanguage.plusStab_iff_rays`, `seamOmegaEquiv`, `plusStab_iff_omega` | `FormalSystem/PlusLanguage/PlusRayFibre.lean` |
| the two congruences | `AgreeUpTo`, `AgreeFrom`, `paste_agreeUpTo`, `paste_agreeFrom` | `FormalSystem/PlusLanguage/PlusPasting.lean` |
| the modal clauses | `OpenTruthAt` (`.ofut`, `.opast` cases) | `FormalSystem/OpenLanguage/OpenTruth.lean` |
| the ladder carrier and model | `Adm`, `LadderState`, `RladAdm`, `ladderFrameAdm`, `ladderModel` | `RaySummary/LadderModel.lean` |
| types and cells | `tpOf`, `cellAt`, `cellAt_eq_cellAt`, `anchorCells_ncard_le` | `RaySummary/AnchorLayer.lean` |
| countdown rigidity (landed) | `cntAt_eq_of_obj_eq`, `cntAt_eq_of_pend_eq`, `cntAt_eq_of_lab_eq_of_pendFactorsLab`, `PendFactorsLab`, `pendFactorsLab_of_atom`, `not_pend_of_count`, `cntAt_sub_of_pend` | `RaySummary/LadderAgree.lean` |
| the refuted two-sided schema | `AtomPreservingCountMove`, `atomPreservingCountMove_refuted` | `RaySummary/LadderAgree.lean` |
| the ▷-shaped move (landed) | `exists_spliced_ladderPath_of_pend_past`, `spliceObj_eq_of_le`, `spliced_at_region`, `spliceCnt_add_of_mem_region` | `RaySummary/LadderAgree.lean` |
| its type refutation | `Probe761S.SpliceTypeInvariance`, `splice_type_invariance_refuted`, `exists_separating_splice`, `splice_block_not_type_respecting` | `specs/evidence/seam-gluing-ray-product/ladder-splice-type-refutation.lean` |
| the consuming obligation | `CellLEZeroConstOfKappaEq` (reserved name `cellLE_zero_const_of_kappa_eq`, claimed by nothing) | `RaySummary/LadderAgree.lean` |
| what IS landed around it | `cellAt_subset_of_shift_of_pend_past`, `mem_cellAt_of_shift_of_hasForwardSlack_exact`, `HasForwardSlack` | `RaySummary/LadderChain.lean` |
| new, this task | `Probe855.PastAtomPreservingCountMove`, `FutAtomPreservingCountMove`, `cntAt_eq_of_pend_eq_fwd`, `cntAt_eq_of_lab_eq_fwd_of_pendFactorsLab`, `futAtomPreservingCountMove_refuted`, `atomPreservingCountMove_refuted_via_fwd`, `futAtomPreservingCountMove_of_twoSided`, `pastAtomPreservingCountMove_of_twoSided` | `specs/855_…/probes/01_one-sided-count-move.lean` |

**Axiom profile of the new probe** (`#print axioms`, as printed by the compile):
`[propext, Classical.choice, Quot.sound]` on `cntAt_eq_of_pend_eq_fwd`,
`cntAt_eq_of_lab_eq_fwd_of_pendFactorsLab`, `futAtomPreservingCountMove_refuted` and
`atomPreservingCountMove_refuted_via_fwd`; **no axioms at all** on
`futAtomPreservingCountMove_of_twoSided` and `pastAtomPreservingCountMove_of_twoSided`. No
`sorryAx`, no custom axiom, no `native_decide`. Compile: exit 0, no warnings, against the
repository's own oleans under the build-guard flock.

**Reproduction**

```bash
LP=.lake/build/lib/lean; for d in .lake/packages/*/.lake/build/lib/lean; do LP="$LP:$d"; done
flock .lake/build-guard.lock env LEAN_PATH="$LP" \
  ~/.elan/toolchains/leanprover--lean4---v4.33.0-rc1/bin/lean \
  specs/855_one_sided_open_modal_type_transport_probe/probes/01_one-sided-count-move.lean
```
