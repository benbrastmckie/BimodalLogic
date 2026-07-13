# Implementation Plan: Realization Recursion `nf_nvar_exist_all_depths` — Post-360 Gap Closure (v3)

- **Task**: 358 - Retire the `nf_nvar_exist_all_depths` open arms (KampPrior.lean:361, :364) via the post-360 gap decomposition G1-G4, consuming the landed Phases 1-2 realizer engine
- **Status**: [IMPLEMENTING]
- **Effort**: 21-33 hours remaining (8 phases: 2 probes + 6 build; ~5-8 hours already landed in Phases 1-2)
- **Dependencies**: 356 (completed), 357 (completed), 360 (completed — slice re-key + m=0 supply), 349 (completed — consumer stack + obligation ledger); 341 (planned, serialized AFTER 358)
- **Research Inputs**:
  - reports/04_post-360-gap-map-and-route.md (AUTHORITATIVE for the remaining work — gap map G1-G4, route notes R1-R5, phase decomposition §6; supersedes stale framings in reports 01-03)
  - reports/02_literature-proof-method-survey.md (proof method — Rabinovich Cor 5.4(1) ⇐; grounds the LANDED Phases 1-2)
  - reports/03 adversarial probes C3/C8 (C8 validated by 360's green m=0 landings; C3 = Phase 6 probe)
  - reports/01_realization-recursion-realizer.md (statement pinning; obligation map now PARTIALLY STALE — see Research Integration)
- **Artifacts**: plans/03_post-360-gap-closure.md (this file)
- **Standards**:
  - .claude/context/formats/plan-format.md
  - .claude/rules/artifact-formats.md
  - .claude/rules/state-management.md
  - .claude/rules/lean4.md (Literature Fidelity; Vacuous Definitions PROHIBITED)
- **Type**: lean4

## Overview

Retire the two open arms of `nf_nvar_exist_all_depths` in
`Theories/Bimodal/Metalogic/WeakCanonical/Kamp/KampPrior.lean` (the `| 1 =>` arm at :361 and the
`| n+2 =>` arm at :364) — the last live Kamp-path sorries (grep-verified at `f4d7b70ff`, full
build GREEN, 1736 jobs). The mathematical method (Rabinovich 2014 Cor 5.4(1) ⇐, constructive
Until + two-way `min`/case-split) is SETTLED and its engine is LANDED sorry-free by this task's
own Phases 1-2 (KampPrior.lean:1192-1649). The landscape shifted decisively since plan v2's
Phase-3 blocker: task 360 machine-refuted and RETIRED the four exterior `hbr*` obligations
repo-wide, re-keying them to the slice interface (`hslice*`/`hexclSlice*`) with four green m=0
supply theorems; tasks 357+349 landed the obligation-carrying consumer stack with a binding
11-row obligation-disposition ledger (EndIntervalConsumerK.lean:235-247).

The remaining work decomposes into four gaps (report 04 §3):
- **G1** — interior `hreal`/`hexcl` supply at general depth (ledger rows 5-6; the dominant new
  mathematics — the Cor 5.4 ⇐ level-descent, consuming the recursion's IH through the landed
  drivers and `_realize_bracket`);
- **G2** — general-m slice supply (rows 8-11; structured extension of 360's m=0 theorems; the
  m≥1 identification kernel is the honest risk — probe C0 mandated);
- **G3** — the hook/fold assembly (the un-owned task-309 P18/19 frontier: carrier→formula fold
  into the `h_quant`/diag hooks + the trichotomy assemble + the arm rewrite; design question
  Q-fold — probe A0 mandated);
- **G4** — the :364 arity lift (serialized strictly last).

**Definition of done** (unchanged from v2, binding): :361 and :364 both sorry-free; all 11
ledger rows discharged at the KampPrior recursion site; full-tree `lake build` GREEN;
`#print axioms completeness_discrete` = `[propext, Classical.choice, Quot.sound]` (+ acceptable
`ofReduceBool`/`trustCompiler` from `native_decide` in the Syntax layer). :364 CANNOT be
silently deferred.

**Binding route decision (R1)**: use `kampPrior_site_rungK_gate_match` (single-depth providers
`P` at k+1, `Pbr` at k) at the recursion site, NOT `endInterval_correct` — its total provider
family `Pfam : (j : Nat) → ExistProviders …` cannot be instantiated inside the `| k+1 =>` arm
(depths > k are not structurally available). Arms k=0/k=1 are unconditional (rung0/rung1), so
G3 alone closes the depth-2 instance end-to-end — the natural first green milestone (Phases
3-5) that de-risks the fold before the G1/G2 mathematics lands.

### Research Integration

Newly integrated this revision:
- **reports/04_post-360-gap-map-and-route.md** (round 4, 2026-07-13) — the post-360 gap map.
  Integration effects on this plan:
  1. **v2 Phase 3 [BLOCKED] is SUPERSEDED and removed.** Its blocker (Finding 1, the pinning
     gap: `hbr*` obligations unexecutable for unmarked σ) was resolved AT THE INTERFACE LEVEL by
     task 360: 0 live `hbr*` binders repo-wide (360 Phase-6 audit; regression guard
     `kvE_futPinned_of_end_zero_refuted`, ExteriorPinnedConverseK.lean:500). Finding 2 (arm
     assembly) is now precisely locatable as G3 (Phases 3-5, 9). The blocker record survives in
     plans/02 and handoffs/phase-3-blocker-20260712.md.
  2. **The exterior discharge seam is re-keyed**: `kvE_{fut,past}Bundle_of_realizer` is no
     longer the discharge route (it survives only as the exact inverse the Phase-2 assemblers
     mirror). Exterior obligations = ledger rows 8-11 (`hslice*`/`hexclSlice*`), m=0 discharged
     by 360, general m = Phase 7.
  3. **File scope is widened** from v2's single-file constraint: Phase 7 edits
     ExteriorPinnedConverse{K,PastK}.lean (the 360 territory); everything else stays in
     KampPrior.lean (or a new leaf under Kamp/ for fold lemmas if KampPrior grows unwieldy).
  4. **Probe-first discipline**: two open design questions (Q-fold, C3 general-m
     identification) get cheap probe phases with GO/NO-GO gates BEFORE their build phases.
  5. Report 01's obligation→converter map ("`hbrFutReal` ← `kvE_futBundle_of_realizer hσ .1`")
     is STALE — do not consult it for discharge routing; use report 04 §1.6 + §3 only.

### Preserved Assets

Complete/green; MUST NOT regress. Consumed by name (do not re-derive, re-implement, or
overwrite). Task 341 is serialized after 358.

| Component | Interface (by name) | File:line | Status |
|-----------|---------------------|-----------|--------|
| Task 358 Phases 1-2: chain-link prepend | `kampPrior_fChain_realize_cons` | KampPrior.lean:1192 | [COMPLETED] sorry-free |
| Cor 5.4(1)⇐ suffix induction (min/case-split, verbatim Rabinovich chunk_0015:19-37) | `kampPrior_fChain_realize_from` | KampPrior.lean:1292 | [COMPLETED] sorry-free |
| Within-bracket witness `z ∈ (z0,z1]` | `kampPrior_fChain_realize_bracket` | KampPrior.lean:1426 | [COMPLETED] sorry-free |
| σ-level `hσ` fold at an anchor | `kampPrior_{fut,past}Realizer_assemble` | KampPrior.lean:1479/:1506 | [COMPLETED] sorry-free |
| Drivers: anchor selection + `hσ` from `kvE_{fut,past}Pos` (arity-generic) | `kampPrior_{fut,past}Realizer_of_pos` | KampPrior.lean:1539/:1598 | [COMPLETED] sorry-free |
| Consumer stack | `endIntervalStepPrior`/`endIntervalPrior`/`EndIntervalCorrectPrior`/`endInterval_step_correct`/`endInterval_correct` | EndIntervalConsumerK.lean:55/:70/:97/:185/:220 | [COMPLETED] (357+349) |
| Obligation-disposition ledger (BINDING) | 11-row table | EndIntervalConsumerK.lean:235-247 | [COMPLETED] (349) |
| Site seam (single-depth providers) | `kampPrior_site_rungK_gate_match` | KampPrior.lean:818-888 | [COMPLETED] |
| Rung ladder (arm 0 unconditional; arm 1 `h0` only; arms ≥2 rungK) | rung0/rung1/rung2/rungK | KampPrior.lean:707/:733/:761/:818 | [COMPLETED] |
| Provider shim + concrete depth-0 instance | `kampPrior_existProviders_of_ih` (+`_correct`,`_existF0_char`,`_exist1`,`_one_of_ih`,`_zero`) | KampPrior.lean:985-1122 | [COMPLETED] |
| Trichotomy assemble (`Formula.or` fold) | `kampPrior_case1_trichotomy_assemble` | KampPrior.lean:1146 | [COMPLETED] |
| Site bridges | `kampPrior_site_env_bridge`/`_site_trichotomy`/`_site_perQnf_seam` | KampPrior.lean:650/:677/:694 | [COMPLETED] |
| m=0 slice supply (360) | `kvE_hsliceFut_supply_zero`/`kvE_hexclSliceFut_supply_zero` (+ Past mirrors) | ExteriorPinnedConverseK.lean:1301/:1242; PastK:822/:769 | [COMPLETED] (360) |
| Slice-id + uniqueness kernels (m=0) | `kvE_{fut,past}SliceId_of_end_zero`/`kvE_{fut,past}SliceUnique_zero` | ExteriorPinnedConverseK.lean:891; PastK:530 | [COMPLETED] (360) |
| hbr* refutation regression guard | `kvE_futPinned_of_end_zero_refuted` | ExteriorPinnedConverseK.lean:500 | [COMPLETED] — do not delete |
| Arm formula builders + hooks | `nf_char2_{past,future}_formula`/`_correct` (hook `h_quant`); `A_diag`/`A_diag_correct` (hooks) | Base.lean:1239/:1262/:1270-1273; ~:1430; :741/:758/:765-773 | [COMPLETED] (309 P3-P5); hooks UNDISCHARGED (= G3) |
| Concrete depth-0 provider pattern | probe instance | ExteriorFiberProbeK.lean:252 | [COMPLETED] reference |
| n=0 / k=0 arms of the target | `nf_nvar_exist_all_depths` `\| 0 =>` (:224), `\| k+1, 0 =>` (:335-346) | KampPrior.lean | [COMPLETED] — do not touch |
| Chain destructors + converters (Phase-1 pins) | `kvE_{fut,past}ChainDestruct*`; `kvE_{fut,past}Bundle_of_realizer` | ExteriorNegationK.lean:293; PastK:353; ExteriorConverterK.lean:208; PastK:177 | [COMPLETED] — converters no longer a discharge seam |

### Source-to-Implementation Mapping (H3, Tier 1 — Literature-Backed)

Authoritative source: **Rabinovich, *A Proof of Kamp's Theorem* (2014)**, per-repo sub-index
(`~/Projects/Literature/sources/rabinovich_2014/`, chunks 0013-0016, 0021-0023). Verified this
round by report 04 §2:

| Paper step | Source | Lean status |
|---|---|---|
| Cor 5.4(1) ⇐ induction, two-way `min`/case-split ("If y2 ≤ xn+1 then z = y2 … otherwise xn+1 ∈ (y1,y2) … z = xn+1") | chunk_0015:9-37 | **LANDED verbatim** — `kampPrior_fChain_realize_from` (:1292), `_bracket` (:1426) |
| Cor 5.4(1) `¬F0(z0) ∨ On(…)` chain device | chunk_0015:39-41 | LANDED — `kvE_futPos`/chain layer |
| Cor 5.4(2) mirror re-anchoring; Lemma 5.1 Cases 1-3 (first-point `inf` r0, `INF` definability) | chunk_0015:43-59, chunk_0016:17-19, chunk_0014 | LANDED at k=2/m=0 (360's slice-id converses); general m = **Phase 7** |
| Induction on quantifier depth (canonical-expansion level descent; Def 7.7/7.13 adjacent-anchor discipline) | chunks 0021-0023 | The recursion's IH at depths ≤ k IS this descent; **Phases 7-8** are its two consumption points |

Fidelity note (report 04 §2): every hypothesis consumed in G1's route is a truth at pinned
coordinates (endpoint/interval/case-condition), never a free→pinned inference; 360's slice
re-key restored exactly the Def 7.13 discipline the refuted `hbr*` shapes violated.

## Postmortem Constraints

Binding for all implementation dispatches. Derived from report 04 (route notes R1-R5), the v2
constraints that remain live, the phase-3 blocker postmortem, and lean4.md.

**Do NOT**:
- Do NOT route exterior obligation discharge through `kvE_{fut,past}Bundle_of_realizer` — that
  is the v2 Phase-3 route that was machine-refuted and retired. Rows 8-11 are the slice family;
  their general-m supply is Phase 7.
- Do NOT use `endInterval_correct` at the recursion site (R1) — its total provider family
  cannot be instantiated inside the `| k+1 =>` arm. Use `kampPrior_site_rungK_gate_match`.
- Do NOT delete or weaken the refutation regression guard
  (`kvE_futPinned_of_end_zero_refuted`) or re-introduce any `hbr*`-shaped universal binder.
- Do NOT land a build phase before its probe gate is GO (Phase 4 needs Phase 3 GO; Phase 7
  needs Phase 6 GO). On NO-GO: the escalation is an interface-restatement SPAWN per the 360
  precedent (Base.lean hook shape for Q-fold; slice-kernel shape for C3) — NEVER a sorry, never
  a vacuous def, never forcing the fold (R5).
- Do NOT `simp`/`omega`/`aesop` past literature-mapped case-splits (house style enforced in
  this territory — see `kampPrior_fChain_realize_from` docstring :1289-1291).
- Do NOT re-derive, re-implement, or overwrite any Preserved Asset. The Phases 1-2 engine
  (:1192-1649) is consumed AS IS; its remaining INPUTS (the `hreal`/`hsat` at-anchor transfer
  hypotheses, :1546-1554/:1605-1613) are what Phase 8 supplies.
- Do NOT edit files outside the declared per-phase territory: KampPrior.lean (+ an optional new
  leaf under Kamp/ for fold lemmas) for Phases 3-5, 8-10; ExteriorPinnedConverse{K,PastK}.lean
  for Phases 6-7. A genuinely needed edit elsewhere (e.g. Base.lean hook restatement) is an
  escalation → [BLOCKED] + spawn, not an inline edit.
- Do NOT silently defer :364 (carries `sorryAx` into the completeness footprint; Phase 10 axiom
  audit would fail). Serialize it strictly after :361 (report 04 G4).
- Do NOT land a strategic `sorry` or vacuous `def X := True`/`Unit`/`trivial` anywhere.
  Zero-debt terminus: clean `#print axioms`. Every phase below has a green landing shape (R5).
- Do NOT choose an M-dependent arm formula: the formula A returned by the `| 1 =>` arm must be
  M-independent — fold over the FINITE qnf population with per-qnf formulas from the carriers
  (constructions are already formula-level; correctness is where M enters). (Report 04 G3(c).)

**MUST preserve**:
- All Preserved-Assets rows, including the v2-landed Phases 1-2 engine and 360's m=0 layer
  (frozen as the conjunct-by-conjunct reference for Phase 7, per R2).
- The n=0 arm (:335-346) and k=0 base (:224) — sorry-free; do not touch.
- Full-tree green status of every module outside the declared per-phase territory.
- Line-citation hygiene (R4): the arm rewrite (Phase 9) lands LAST in its phase and updates the
  fencing note (KampPrior:352-360) in the same edit (pre-authorized by the Phase-16 note
  :959-961).

**Design decisions SETTLED** (do not re-open without a concrete counterexample):
- Method = Rabinovich Cor 5.4(1) ⇐ (landed). Site route = `kampPrior_site_rungK_gate_match`
  with single-depth providers (R1). Provider instantiation = the Phase-16 arm-rewrite move:
  `kampPrior_existProviders_of_ih … (fun n sub => nf_nvar_exist_all_depths atomMap h_surj j n
  sub)` at `j = k'+1, k'` — structurally decreasing recursive calls (KampPrior:955-958).
- G2 methodology = the 360 template: machine probe (ExteriorPinnedProbeK pattern) BEFORE
  landing; frozen k=2/m=0 layer as reference (R2).
- `hexcl` and the `hexclSlice*` general-m proofs share the uniqueness/readback kernel — build
  it ONCE in Phase 7, consume in Phase 8 (R3).
- Depth-2-first milestone: arms k=0/1 are unconditional (rung0/rung1), so Phases 3-5 close the
  depth-2 instance before any G1/G2 mathematics (report 04 §4).

## Goals & Non-Goals

- **Goals**:
  - `nf_nvar_exist_all_depths` sorry-free at :361 and :364; zero live sorries in KampPrior.lean.
  - Discharge all 11 obligation-ledger rows at the recursion site: rows 1-2 by provider
    instantiation (Phase 9), rows 3-4 ambient, rows 5-6 by Phase 8 (G1), row 7 internal (356),
    rows 8-11 by 360's m=0 + Phase 7 general-m (G2).
  - Land the hook/fold assembly (G3): quantEnd/seg + diag hooks from the rung biconditionals,
    the obligation-carrying arm lemma, and the final arm rewrite.
  - Full-tree `lake build` GREEN; `#print axioms completeness_discrete` =
    `[propext, Classical.choice, Quot.sound]` (+ acceptable `ofReduceBool`/`trustCompiler`).
- **Non-Goals**:
  - Refactoring `NfMultiAnchorBridge/` (task 341, serialized after 358).
  - Re-deriving any Preserved Asset; re-opening the settled method/route decisions.
  - Restating the Base.lean hooks or the slice kernels IN THIS TASK if a probe returns NO-GO
    (that is a spawned interface-restatement task per R5).
  - Off-path documented sorries (EANegation.lean:1090/:1249, NfDepth0Generalized.lean:751) —
    superseded/quarantined per their in-source notes; NOT in scope.

## Risks & Mitigations

- **Risk (PRIMARY, report 04 G2/C3)**: the general-m slice identification kernel
  (`kvE_{fut,past}SliceId_of_end` at m ≥ 1) may be ambiguous — walked-point/endpoint types must
  be rendered through `charF`/providers (level descent), and report 03's adversarial pass
  flagged exactly this (C3). **Mitigation**: Phase 6 is a mandated cheap machine probe
  (countermodel attempt at m=1) BEFORE Phase 7; NO-GO → spawn a slice-kernel restatement task
  (360 precedent), parent [BLOCKED]; the m=0 layer stays frozen as reference either way.
- **Risk (report 04 Q-fold)**: the rung delivers TWO-anchor carrier content
  (`carrier.holds M atomMap x t`) while the `h_quant` hook slots are (point at x) ∧ (segment on
  (x,t)); the `VVecEA2` decomposition into that shape is the load-bearing design decision.
  **Mitigation**: Phase 3 probe renders ONE concrete per-qnf biconditional in hook shape at
  k=0, using the candidate landed assets (sorry-free VecEA2 temporal translation
  VecEADecomp:877-895, `bracketBuildLeft/Right_correct`, NavigatedEndChar). NO-GO → the repair
  is a Base.lean `h_quant` restatement (caller-supplied hypothesis, one consumer) SPAWNED as
  its own task — never forcing the fold.
- **Risk (G1 novelty)**: the fold-bit → chain-firing bridge (igFoldBit content into
  `kvE_*Pos`/F-chain shape) and per-level IH plumbing are the genuinely new mathematics.
  **Mitigation**: the two `w` populations split the work — ⇒-direction ws are DEFINITIONAL
  (free `hreal`/`hexcl`); only igPtW-selected ws need reconstruction, and each σ-zone case maps
  to an already-landed device (exterior-zone → drivers; interior-zone → `_realize_bracket`;
  `hexcl` → the Phase-7 readback kernel). Depth-0 base fully atomic
  (ExteriorFiberProbeK.lean:252 pattern; the k=1/m=0 rung is where 360's supply theorems
  already run this).
- **Risk (G4 arity lift)**: route (i) iterated one-variable reduction needs an arity-general
  restatement of the currently arity-2-specific trichotomy/nf_char2 layer; route (ii) is the
  docstring bootstrap (KampPrior:323-331). **Mitigation**: the realizer engine and drivers are
  already arity-generic (`BracketFormula (n+1)`, KampPrior:1183-1185); Phase 10 adjudicates
  (i) vs (ii) at phase start; if neither closes green → [BLOCKED] + spawn an isolated
  arity-lift task; :361 stays landed and committed; never a carried sorry.
- **Risk**: cross-phase churn on shared KampPrior.lean. **Mitigation**: single-dispatch phases
  (~100-500 lines each, report 04 §6); scoped `lake build` per phase; the only parallel wave
  (Phases 3+6) has disjoint territory (KampPrior/Base fold seams vs ExteriorPinnedConverse*);
  commit every green sub-step.
- **Risk**: line-number drift in this plan's citations as phases land code. **Mitigation**:
  interfaces are pinned BY NAME (the contract); re-locate with `lean_local_search` if a cited
  line has moved; R4 governs the fencing-note update.

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2 | 1 |
| 3 | 3, 6 | 2 |
| 4 | 4, 7 | 3; 6 |
| 5 | 5, 8 | 4; 7 |
| 6 | 9 | 5, 7, 8 |
| 7 | 10 | 9 |

Phases within the same wave can execute in parallel (Phases 3+6 and 4+7 have disjoint
territory: KampPrior.lean fold seams vs ExteriorPinnedConverse{K,PastK}.lean). Phase 8 depends
on Phase 7 because `hexcl` consumes the shared uniqueness/readback kernel (R3). Each phase is
one dispatch (~100-500 lines); Phases 3 and 6 are cheap probe dispatches.

### Phase 1: Interface pin + constructive Until-witness verification (escalation gate) [COMPLETED]
- **Goal:** Confirm the caveats are satisfied BEFORE any construction: (a) all nine
  Preserved-Asset interfaces (v2 table) resolve by name; (b) the project's `Until` truth-lemma
  exposes the Until-witness CONSTRUCTIVELY on the target discrete/integer (Reynolds) model.
- **Tasks:** (all done 2026-07-12; preserved verbatim from plan v2)
  - [x] Pin the nine v2 Preserved-Asset interfaces by name with recorded signatures. One
        relocation found: `kampPrior_existProviders_of_ih` is a 3-lemma family at
        KampPrior.lean:989/:1013/:1043 (located by name, not edited).
  - [x] Locate the `Until` truth-lemma: DEFINITIONAL —
        `Bimodal.Metalogic.WeakCanonical.temporal_truth`, Table.lean:182; `.untl` case
        :190-191 unfolds to `∃ s, t < s ∧ … ∧ ∀ r, t < r → r < s → …` — exactly the Rabinovich
        witness shape; `.snce` dual :192-193. Consumed via the k=1 template
        (`simp only [temporal_truth]` + `obtain`, EANegation.lean:594-611, :637-647).
  - [x] Constructivity verdict: CONSTRUCTIVE-VIABLE, verified by machine probe
        `until_witness_probe` (lean_run_code) transcribing the exact Cor 5.4(1) ⇐ inductive
        step, compiling green with axiom closure `[propext, Classical.choice, Quot.sound]` —
        IDENTICAL to the ambient baseline (bare `Exists.intro` over these types shows the SAME
        closure via the Mathlib `LinearOrder` floor). Extraction is Prop-level `Exists.elim`;
        case-split uses `le_total`/`le_or_gt` from the bundled `LinearOrder`
        (`OrderedMonadicStructure.carrier_order`, MonadicFO.lean:103-109). Grounded against
        Rabinovich chunk 0015 lines 25-35.
  - [x] GO/NO-GO: **GO** — all nine interfaces resolve; Until-witness constructive-viable; no
        new lemma needed outside KampPrior.lean; no sorry introduced.

  Implementation notes carried forward: (a) `le_or_lt` is deprecated in this toolchain — use
  `le_or_gt`; (b) do not project `M.carrier_order.decidableLE` directly — use
  `le_total`/`le_or_gt`/`inferInstance`; (c) the axiom-floor for ALL green assets is
  `[propext, Classical.choice, Quot.sound]` — the `lean_verify` bar is "no axiom beyond this
  floor, no `sorryAx`", not literal absence of `Classical.choice`.
- **Timing:** 1-2 hours (done)
- **Depends on:** none
- **Completed:** 2026-07-12

### Phase 2: Produce the realizer `hσ` — Cor 5.4(1) ⇐ base + one Until-link (arity-generic) [COMPLETED]
- **Goal:** Construct the genuine within-bracket realizer following the §2.4 recipe: the landed
  `fChainFrom` base extended by Until-driven chain-links with the two-way `min`/case-split,
  arity-generic so the arity lift is thin.
- **Tasks:** (all done 2026-07-12; preserved verbatim from plan v2)
  - [x] Anchor from the destructors: consumed inside the drivers
        `kampPrior_{fut,past}Realizer_of_pos` — the positive-existence reading of the
        `kvE_extNeg{Fut,Past}_complete` bodies, emitting the SELECTED anchor, the endpoint
        description `kvE_{fut,past}End`, and `hσ`.
  - [x] Until-witness extraction: `kampPrior_fChain_realize_from` extracts the witness of each
        link through the landed `fChainFrom_step` characterization (the definitional
        `temporal_truth` `.untl` reading in the template's packaged form).
  - [x] The decidable `min`/case-split: TWO explicit two-way case-splits landed — per-link
        `le_or_gt y (x (i+1))` in `_realize_from` (invariant `w a ≤ x (i+a)` keeping both
        branches in-bracket) and endpoint `le_or_gt s z1` in `_realize_bracket`. This is the
        bounded resolution of the EANegation.lean:1249 Until-unboundedness obstruction; both
        case-splits are explicit `rcases le_or_gt`.
  - [x] Atom layer + fold into `hσ`: `kampPrior_{fut,past}Realizer_assemble` — atom layer via
        `kvE_{fut,past}Atom_of_bundle` on a designated bit-true self-zone fiber, off-fiber
        falsity via `kvE_{fut,past}Admissible_offFiber`, fold via `nf_eval_nfk_iff_efold`;
        exact inverses of `kvE_{fut,past}Bundle_of_realizer`.
  - [x] Scoped build green (1032 jobs); `lean_verify` on the three head theorems: axiom closure
        exactly `[propext, Classical.choice, Quot.sound]`; file sorries remain exactly the
        inherited :361/:364.

  Deliverables (all sorry-free, KampPrior.lean:1192-1649): `kampPrior_fChain_realize_cons`,
  `_realize_from`, `_realize` (i=0 instance), `_realize_bracket`,
  `kampPrior_{fut,past}Realizer_assemble`, `kampPrior_{fut,past}Realizer_of_pos`. The chain
  realizer is stated for every `BracketFormula (n+1)` (arity-generic) so Phase 10 reuses it
  verbatim. The drivers' remaining INPUTS are the at-anchor transfer hypotheses
  (`hreal`/`hsat`, :1546-1554/:1605-1613) — supplied by Phase 8.
- **Timing:** 4-6 hours (done)
- **Depends on:** 1
- **Completed:** 2026-07-12

### Phase 3: Probe A0 — Q-fold hook-shape decomposition at k=0 (GO/NO-GO gate) [COMPLETED]
- **Goal:** Settle the load-bearing G3 design question BEFORE building the fold: can the rung's
  TWO-anchor `VVecEA2` carrier content (`carrier.holds M atomMap x t`) be decomposed into the
  `h_quant` hook shape (point-eval `quantEnd.eval_at x` ∧ segment `seg.holds x t`,
  Base.lean:1270-1273)?

**VERDICT (2026-07-13, sess_1783979891_6ad95e_358): NO-GO for the literal `(quantEnd, seg)`
hook shape — machine-refuted; the question was ANSWERED BY LANDED MACHINE EVIDENCE (task 350,
`NfMultiAnchorBridge/AggregateHookDischarge.lean`), no new probe file needed.**

1. **Literal hook shape REFUTED** (350 R1 verdict, AggregateHookDischarge.lean:12-28): a
   `BracketFormula 0` has NO point slots (`IntervalPattern.holds` at `n = 0` is purely the
   universal segment form), so interior-POSITIVE population fibers (`∃ v, x < v ∧ v < t ∧ …`)
   escape the `(quantEnd, seg)` pair for ANY choice. The diag per-point hooks (`A_diag_correct`,
   Base.lean:765-773) are separately world-locality-refuted by the sorry-free pair
   `endCharN0_correct_world_local_obstruction` / `endCharN0_correct_infeasible`
   (Base.lean:1777/1811) — 350 R2 verdict.
2. **The asset that carries the decomposition is Route V** (`VVecEA2.translateRight_correct` /
   `translateLeft_correct`), delivering the SKELETON-SHAPED conclusions (the exact
   `kampPrior_case1_trichotomy_assemble` binder shapes) directly, bypassing the hook binders:
   `kampArm_{past,diag,future}_k0(_correct)` (k=0, all three) and `kampArm_diag_k1(_correct)`
   are LANDED; `lean_verify` re-run this session: all four = exactly
   `[propext, Classical.choice, Quot.sound]`, no sorryAx. Shape certificates at generic-site
   indices `0+1`/`1+1` compile verbatim (AggregateHookDischarge.lean:1758-1781).
   `KampPrior.lean` already imports the aggregator, so these are consumable in-territory.
3. **The general-k fold residual is BLOCKED on missing primitives** (350 Phase-4 structured
   blocker, plans/01 §Phase 4): the k=1 OFF-DIAGONAL aggregate (and a fortiori every k ≥ 1
   off-diagonal fold, including the k'+2 arms) requires (i) `VVecEA2.conjFull` — structural
   conjunction in FULL IFF form (Rabinovich Lemma 3.4), (ii) a fixed-formula (syntactic)
   negation closure for the single-interior-witness VVecEA2 fragment, (iii) per-qnf k=1
   exterior/point VVecEA2 encodings. All three are absent from the landed stack (adversarially
   established: `conj_struct` one-directional, `neg_2var_vec_ea` model-dependent, depth-2
   re-fibering unsound via the F1 information-loss channel `bracketEndChar_kv_factors`).
4. **NO-GO consequence, adapted (no duplicate spawn):** the plan's prescribed escalation — "spawn
   a hook-restatement task" — is ALREADY INSTANTIATED as task 350 itself (the restatement =
   consume skeleton-shaped conclusions instead of the binder; partially delivered, remainder
   blocked on (i)-(iii) with `/spawn 350` recommended in its own blocker record; task 350 under
   active hard-mode research this session). Spawning a second task would duplicate it. The
   A-branch BUILD phases (4-5) are therefore [BLOCKED] on 350's missing primitives, NOT
   re-attempted here; the C-branch (Phases 6-7) and the supply mathematics (Phase 8, whose
   shapes are fixed by the ledger, not by the fold) proceed independently.

- **Tasks:**
  - [x] Render ONE concrete per-qnf carrier biconditional in (quantEnd, seg) hook shape at k=0
        *(deviation: altered — rendered by consuming task 350's landed adjudication + lemmas
        instead of a new probe file; the literal shape is machine-refuted (R1/R2), the Route-V
        skeleton-shaped k=0 conclusions are landed and verified this session)*
  - [x] Exercise the candidate landed decomposition assets. *(Route V:
        `VVecEA2.translateRight/Left_correct` carries the decomposition — verified via
        `lean_verify` on the four landed `kampArm_*` lemmas; the VecEADecomp/NavigatedEndChar
        candidates are subsumed by 350's aggregation verdict)*
  - [x] Record the GO/NO-GO verdict IN THE PLAN with the probe evidence.
  - [x] On NO-GO: STOP the A-branch. *(deviation: altered — no new spawn: the restatement task
        exists as task 350 (active, [PARTIAL] with structured blocker + its own /spawn 350
        recommendation); A-branch build phases marked [BLOCKED] referencing 350; task 358 itself
        NOT marked [BLOCKED] because the C-branch + Phase 8 proceed per this phase's own
        protocol)*
- **Timing:** 1-2 hours (cheap probe dispatch)
- **Depends on:** 2
- **Done when:** GO/NO-GO recorded with machine evidence; no sorry introduced; probe artifact
  committed (`task 358 phase 3: Q-fold probe GO/NO-GO`).
- **Completed:** 2026-07-13

### Phase 4: Fold/hook assembly at arms 0-1 (G3a+b) [BLOCKED]
- **Goal:** Build `quantEnd`/`seg` + the `A_diag` hooks from the rung0/rung1 per-qnf
  biconditionals, discharging `h_quant` (Base.lean:1270-1273 + future mirror) and the diag
  hooks (Base.lean:765-773) for arms k=0 and k=1.

**BLOCKER** (Phase 4; Phase-3 NO-GO consequence — see the Phase-3 verdict for full evidence):
- **What failed**: the phase's stated construction (`quantEnd : TemporalPred` +
  `seg : BracketFormula 0` folding the per-qnf rung biconditionals; per-point diag hooks) is
  machine-refuted — 350 R1 (interior-positive fibers escape the pair shape) and R2
  (world-locality refutation, Base.lean:1777/1811). This phase's goal shape cannot exist.
- **What was tried**: nothing new landed here — the refutations and the working alternative
  (Route V) are already machine-established in task 350's AggregateHookDischarge.lean; its k=0
  layer + k=1 diag are landed and verified this session (floor axioms, no sorryAx).
- **Why it's stuck**: the surviving deliverable of this phase (arm facts at k=1 off-diagonal,
  and the general-k fold) requires `VVecEA2.conjFull` (Lemma 3.4 iff form) + a syntactic
  negation closure + per-qnf k=1 exterior/point carriers — task 350's Phase-4 blocker, missing
  from the landed stack.
- **What is needed**: task 350's spawn chain to deliver the three primitives (its own blocker
  record recommends `/spawn 350`); then arms k=0/1 assemble per 350's recipe and this phase
  reduces to consumption (k=0 is ALREADY consumable now via `kampArm_*_k0_correct`).
- **Prohibited workarounds**: no `sorry`, no vacuous def, no re-derivation of 350's territory
  (AggregateHookDischarge.lean is a frozen consumer seam for this task).
- **Tasks:**
  - [ ] G3(a): construct `quantEnd : TemporalPred` and `seg : BracketFormula 0` from the
        per-qnf rung biconditionals — positives from the rung `.mpr`, negatives from `.mp`
        contrapositive; the ∀qnf agreement is a finite conjunction over the
        `NormalForm sig k 3` fintype. Use the Phase-3-validated decomposition route.
  - [ ] G3(b): the `A_diag` hooks — `diagChar` as an all-diagonal instance (servable by
        `charF`/fold); `pastEnd`/`futureEnd` as pinned endpoint characterizations (the diag
        case's smaller version of (a)).
  - [ ] Land as new fold lemmas in KampPrior.lean (or a new leaf under Kamp/ if KampPrior grows
        unwieldy — declare the choice in the phase commit). Formula-level constructions must be
        M-independent.
  - [ ] Scoped `lake build` green; `lean_verify` on the head fold lemmas (floor axioms only);
        commit (`task 358 phase 4: quantEnd/seg + diag hooks, arms 0-1`).
- **Timing:** 3-5 hours
- **Depends on:** 3
- **Done when:** `h_quant` (both mirrors) and the diag hooks discharged at arms 0-1 as named
  green lemmas; no sorry.

### Phase 5: Arm skeleton — `kampPrior_case1_arm_of_obligations` (depth-2 milestone) [BLOCKED]

**BLOCKER** (Phase 5; inherited from Phase 4 / the Phase-3 NO-GO): the skeleton's k=1 arm
needs `kampArm_{past,future}_k1` (350-blocked on `VVecEA2.conjFull` et al.), and its k'+2 arm
needs the general-k fold (same missing primitives). The k=0 slice IS closable now — landed as
the reduced-scope green sub-step `kampPrior_case1_arm_k0` (KampPrior.lean, this session):
the ambient-k=0 instance of the `| 1 =>` arm statement, closed end-to-end via
`kampPrior_case1_trichotomy_assemble` + `kampArm_{past,diag,future}_k0_correct`. The DEPTH-2
milestone (ambient k=1) unblocks when 350 lands its off-diagonal k=1 pair; the consumption
recipe is identical (assemble + the three k=1 arm facts).
- **Goal:** Land the k-case-split skeleton as an ADDITIVE NAMED LEMMA (not an arm edit): arms
  k=0/1 closed unconditionally via Phase 4's folds + rung0/rung1 +
  `kampPrior_case1_trichotomy_assemble` (:1146); k ≥ 2 routed through the rungK seam with the
  11 obligations as EXPLICIT HYPOTHESES. This closes the depth-2 instance end-to-end — the
  first green milestone — and fixes the exact obligation shapes Phases 7-8 must supply.
- **Tasks:**
  - [ ] State and prove `kampPrior_case1_arm_of_obligations`: case-split ambient k
        (`0` / `1` / `k'+2`); arms 0-1 discharged outright; the `k'+2` branch takes the rungK
        obligation rows (5-6, 8-11 — the still-open rows) as hypotheses and closes via
        `kampPrior_site_rungK_gate_match` + the Phase-4 folds + the trichotomy assemble.
  - [ ] Verify the obligation hypothesis shapes match the ledger rows verbatim
        (EndIntervalConsumerK.lean:235-247) and the rungK binders (KampPrior:835-846) — these
        are the supply contracts for Phases 7-8; record them in the phase notes.
  - [ ] Scoped `lake build` green; `lean_verify` (floor axioms only, no `sorryAx`); commit
        (`task 358 phase 5: obligation-carrying arm skeleton, depth-2 closed`).
- **Timing:** 2-3 hours
- **Depends on:** 4
- **Done when:** the named lemma is green with arms 0-1 unconditional and k≥2
  obligation-carrying; the depth-2 instance is derivable end-to-end; no sorry; :361 itself
  UNCHANGED (the arm edit is Phase 9).

### Phase 6: Probe C0 — general-m slice identification at m=1 (GO/NO-GO gate) [NOT STARTED]
- **Goal:** Settle G2's honest risk BEFORE building: does the endpoint slice identification
  (`kvE_{fut,past}SliceId_of_end_zero` pattern, ExteriorPinnedConverseK.lean:891 / PastK:530)
  extend to m = 1, where walked-point/endpoint types must be rendered through
  `charF`/providers (level descent)? Report 03's mandated C3 probe; its sibling C8 is already
  VALIDATED by 360's green m=0 landings.
- **Tasks:**
  - [ ] Attempt the m=1 identification statement AND a countermodel attempt against it
        (adversarial both ways — the 360 methodology, ExteriorPinnedProbeK pattern). Territory:
        ExteriorPinnedConverse{K,PastK} probe files only.
  - [ ] Record the GO/NO-GO verdict in the plan with machine evidence (compiling identification
        instance at m=1, or the concrete ambiguity/countermodel).
  - [ ] On NO-GO: STOP the C-branch — mark task [BLOCKED], spawn a slice-kernel restatement
        task (the 360 precedent, which handled exactly this shape of failure); never a sorry.
        (The A-branch, Phases 3-5, may proceed independently.)
- **Timing:** 1-2 hours (cheap probe dispatch; parallel to Phase 3 — disjoint territory)
- **Depends on:** 2
- **Done when:** GO/NO-GO recorded with machine evidence; no sorry; probe committed
  (`task 358 phase 6: general-m slice identification probe`).

### Phase 7: G2 — general-m slice supply (rows 8-11) [NOT STARTED]
- **Goal:** Extend 360's four m=0 supply theorems to general m, lifting the two m-sensitive
  kernels. The proof SHAPES generalize verbatim (the `hexclSlice*` proofs consume only carried
  `hreal` + slice uniqueness + admissibility zone readback; the `hslice*` proofs consume the
  destructor + slice identification).
- **Tasks:**
  - [ ] Generalize the identification kernel: `kvE_{fut,past}SliceId_of_end` at general m
        (walked-point/endpoint types rendered through `charF`/providers — the same IH
        consumption as the drivers' inputs), following the Phase-6-validated route.
  - [ ] Generalize the uniqueness kernel: `kvE_{fut,past}SliceUnique` at general m. Build the
        uniqueness/readback kernel ONCE — Phase 8's `hexcl` consumes it too (R3).
  - [ ] Lift the four supply theorems (`kvE_hsliceFut_supply` / `kvE_hexclSliceFut_supply` +
        Past mirrors) to general m, conjunct-by-conjunct against the frozen m=0 layer (R2).
        Territory: ExteriorPinnedConverse{K,PastK}.lean; the m=0 theorems stay untouched.
  - [ ] Scoped `lake build` green; `lean_verify` on the four lifted theorems (floor axioms
        only); commit (`task 358 phase 7: general-m slice supply, rows 8-11`).
- **Timing:** 4-6 hours
- **Depends on:** 6
- **Done when:** four general-m supply theorems green, matching the Phase-5 obligation
  hypothesis shapes for rows 8-11; m=0 layer unregressed; no sorry.

### Phase 8: G1 — interior `hreal`/`hexcl` supply at general depth (rows 5-6) [NOT STARTED]
- **Goal:** The dominant new mathematics — depth-graded supply theorems
  `kampPrior_hreal_supply` / `kampPrior_hexcl_supply` for the rungK interior obligations
  (binders KampPrior:835-846), consuming the recursion's IH providers. This also supplies the
  Phase-2 drivers' remaining `hreal`/`hsat` transfer inputs (:1546-1554/:1605-1613).
- **Tasks:**
  - [ ] Split the `w` population (report 04 G1): ⇒-direction ws (ambient
        `nf_eval_nf M (k+2) 3 [w,x,t] qnf` in scope) — the ∀σ agreement is DEFINITIONAL;
        discharge outright.
  - [ ] ⇐-direction ws (igPtW-selected): render w's realization of the arity-1 fold
        `igFoldBit qnf` via `hcharK` + `P.correct` + `_existF0_char` (KampPrior:1026;
        fiber-existential read InteriorGateGeneralK.lean:318/:387). Then per marked σ:
        - exterior-zone σ: the fold bit fires `kvE_{fut,past}Pos (Pbr) σ`; the landed drivers
          select `x1` and emit `hσ`; their transfer inputs are the SAME statement one fiber
          level down (σ's fibers `s : NormalForm sig k 5`) — close by the recursion's IH at
          depth k (level descent), depth-0 base fully atomic (ExteriorFiberProbeK.lean:252
          pattern).
        - interior-zone σ (`x1 ∈ (x,t)` prescribed by σ's zone spec): the within-bracket case —
          `kampPrior_fChain_realize_bracket` (:1426) with F-chain firing from the fold-bit
          fiber content, bracket endpoints `(x,t)`.
  - [ ] `hexcl`: the contrapositive channel — a within-`[x,t]` realizer of a bit-false σ
        back-propagates through the fold (`nf_eval_nfk_iff_efold`, off-fiber falsity from
        admissibility) to contradict the igPtW fold agreement, via the Phase-7
        uniqueness/readback kernel (R3).
  - [ ] Territory: KampPrior.lean (or the Phase-4 leaf). Scoped build green; `lean_verify`
        (floor axioms only); commit (`task 358 phase 8: interior hreal/hexcl supply`).
- **Timing:** 4-6 hours
- **Depends on:** 7
- **Done when:** `kampPrior_hreal_supply` / `kampPrior_hexcl_supply` green, matching the
  Phase-5 obligation hypothesis shapes for rows 5-6; no sorry.

### Phase 9: G3(c) — the `| 1 =>` arm rewrite, retire :361 [NOT STARTED]
- **Goal:** The edit that retires :361: instantiate providers inside the arm, discharge all 11
  ledger rows, and close via the Phase-5 skeleton.
- **Tasks:**
  - [ ] In the `| 1 =>` body: instantiate providers via `kampPrior_existProviders_of_ih …
        (fun n sub => nf_nvar_exist_all_depths atomMap h_surj j n sub)` at `j = k'+1, k'`
        (structurally decreasing recursive calls — the documented Phase-16 move,
        KampPrior:955-958). Rows 1-2 discharged.
  - [ ] Discharge rows 5-6 via Phase 8, rows 8-11 via 360's m=0 + Phase 7; rows 3-4 ambient;
        row 7 internal. Apply `kampPrior_case1_arm_of_obligations` (Phase 5) to close the arm.
  - [ ] Replace the :361 `sorry`. Update the fencing note (KampPrior:352-360) in the SAME edit
        (R4; pre-authorized by :959-961). Land this arm edit LAST in the phase.
  - [ ] Scoped `lake build` green; `lean_verify` on `nf_nvar_exist_all_depths` — `sorryAx`
        remaining ONLY from :364; commit (`task 358 phase 9: retire :361 | 1 => arm`).
- **Timing:** 3-4 hours
- **Depends on:** 5, 7, 8
- **Done when:** :361 gone; scoped build green; the only `sorryAx` source in the file is :364.

### Phase 10: G4 — retire :364 + full-tree green + axiom audit [NOT STARTED]
- **Goal:** Retire the `| n+2 =>` arm and verify the zero-debt terminus.
- **Tasks:**
  - [ ] Adjudicate the route AT PHASE START (report 04 G4): (i) iterated one-variable reduction
        — peel `∃ env : Fin (n+2)` one variable at a time through the `| 1 =>` machinery
        (`Fin.cons x (insertEnv env t) = insertEnv (Fin.cons x env) t`, KampPrior:235; needs an
        arity-general restatement of the currently arity-2-specific trichotomy/nf_char2 layer)
        vs (ii) the docstring bootstrap (KampPrior:323-331): disjunction over good depth-(k+1+n)
        arity-1 NFs built iteratively from `char_k1` upward via `doets_lemma_1_1`-style
        reduction. The realizer engine and drivers are already arity-generic.
  - [ ] Execute the chosen route; replace the :364 `sorry`. If NEITHER route closes green:
        STOP — mark task [BLOCKED], spawn an isolated arity-lift task; :361 stays landed;
        never a carried sorry, parent never [COMPLETED] with debt.
  - [ ] Full `lake build` (whole project) — GREEN, zero live sorries in KampPrior.lean
        (grep-verify).
  - [ ] `lean_verify` on fully-qualified `completeness_discrete`:
        `#print axioms completeness_discrete` = `[propext, Classical.choice, Quot.sound]`
        (+ acceptable `ofReduceBool`/`trustCompiler`). Any OTHER axiom (esp. `sorryAx`) is a
        FAIL → return to the offending phase.
  - [ ] Final commit (`task 358: complete implementation`) + summary artifact
        (summaries/03_post-360-gap-closure-summary.md).
- **Timing:** 3-5 hours (route-dependent; escalate rather than expand)
- **Depends on:** 9
- **Done when:** :364 sorry-free; full-tree GREEN; axiom audit clean — OR task [BLOCKED] with a
  spawned isolated arity-lift task and :361 preserved.

## Testing & Validation
- [ ] Scoped `lake build Bimodal.Metalogic.WeakCanonical.Kamp.KampPrior` (and
      `…NfMultiAnchorBridge.ExteriorPinnedConverseK`/`PastK` for Phases 6-7) green after every
      build phase; full `lake build` green in Phase 10.
- [ ] Both probe phases (3, 6) record GO/NO-GO verdicts with machine evidence before their
      build phases dispatch.
- [ ] `lean_verify` per phase on head lemmas: axiom closure exactly
      `[propext, Classical.choice, Quot.sound]` (floor), no `sorryAx`, no new axiom.
- [ ] `lean_verify completeness_discrete` final footprint = floor (+ acceptable
      `ofReduceBool`/`trustCompiler`); NO `sorryAx`.
- [ ] Zero live `sorry` in KampPrior.lean at terminus (grep); no `sorry`/`admit`/vacuous
      `def X := True`/`Unit`/`trivial` introduced anywhere at any phase.
- [ ] No files modified outside per-phase territory: KampPrior.lean + optional Kamp/ leaf
      (Phases 3-5, 8-10); ExteriorPinnedConverse{K,PastK}.lean + probe files (Phases 6-7).
- [ ] 360's m=0 layer and the refutation regression guard unregressed (Phase 7 diff review).
- [ ] Commit every green sub-step (git-workflow mandate).

## Artifacts & Outputs
- plans/03_post-360-gap-closure.md (this file)
- Theories/Bimodal/Metalogic/WeakCanonical/Kamp/KampPrior.lean (fold lemmas, skeleton, supply
  theorems, arm rewrites at :361/:364; possibly a new leaf under Kamp/ for fold lemmas)
- Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge/ExteriorPinnedConverseK.lean
  and ExteriorPinnedConversePastK.lean (general-m kernels + supply theorems; probe files)
- summaries/03_post-360-gap-closure-summary.md (on completion)

## Rollback/Contingency
- Each phase commits its own green sub-step; a failed phase leaves prior phases committed and
  green. The depth-2 milestone (Phase 5) is independently valuable and survives any later
  blockage.
- Probe NO-GO (Phase 3 or 6): task [BLOCKED] + spawn the interface-restatement task (Base.lean
  `h_quant` hook shape / slice-kernel shape respectively — the 360 precedent); the sibling
  branch may continue; no code debt landed.
- Phase 10 both routes blocked: task [BLOCKED] + spawn isolated arity-lift task; :361 stays
  landed and committed; :364 stays a visible sorry under a [BLOCKED] parent — never
  [COMPLETED] with a carried sorry.
- Zero-debt invariant: at no point land a strategic `sorry` or vacuous `def`. Escalate via
  [BLOCKED] + spawn instead (recovery ladder: .claude/context/contracts/recovery.md).
