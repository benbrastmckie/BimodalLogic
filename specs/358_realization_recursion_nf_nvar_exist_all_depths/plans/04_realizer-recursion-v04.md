# Implementation Plan: Realization Recursion `nf_nvar_exist_all_depths` — Depth>=1 Supply Re-Keyed to Task 363 (v04)

- **Task**: 358 - Retire the two remaining `nf_nvar_exist_all_depths` open arms (KampPrior.lean:519 k>=2 residual, :522 arity-lift) by supplying the depth>=1 interior/exterior fiber-marking obligations, re-keyed to task 363's landed fiber-consistency interface
- **Status**: [NOT STARTED]
- **Effort**: 18-28 hours remaining (6 phases: 1 interface-pin + 5 build/rewrite; Phases 1-2/6 of the old scope plus the k=0/k=1 arms already landed and frozen)
- **Dependencies**: 349 (completed — consumer stack + obligation ledger), 356 (completed), 357 (completed), 360 (completed — slice re-key + m=0 supply), 363 (completed — depth-graded fiber-consistency interface restatement; UNBLOCKED 2026-07-14)
- **Research Inputs**:
  - reports/06_remaining-work-and-plan-revision.md (round 6, 2026-07-14 — AUTHORITATIVE driver for this revision: two-live-sorry map, blocker adjudication, ordered decomposition G2->G1->arm rewrites, verification bar; supersedes report 04's phase status)
  - specs/363_restate_depth1_fibermarking_interface_and_reprobe_g1g2/summaries/01_interface-restatement-summary.md (the re-keying contract — FINAL PREDICATE SIGNATURE `kvE_fiberElemConsistent` / `kvE_fiberConsistent`, exterior conjunct-2 shape, interior antecedent PAIR shape, `kvE_fiberConsistent_of_realized` discharge key)
  - reports/04_post-360-gap-map-and-route.md (gap map G1-G4, route notes R1-R5; still authoritative for the *mathematics* of each gap, superseded only on phase status)
  - reports/02_literature-proof-method-survey.md (Rabinovich 2014 Cor 5.4(1)⇐; grounds the LANDED Phases 1-2 realizer engine)
- **Artifacts**: plans/04_realizer-recursion-v04.md (this file)
- **Standards**:
  - .claude/context/formats/plan-format.md
  - .claude/rules/artifact-formats.md
  - .claude/rules/state-management.md
  - .claude/rules/lean4.md (Literature Fidelity; Vacuous Definitions PROHIBITED; zero-debt terminus)
- **Type**: lean4

## Overview

Retire the LAST TWO live Kamp-path sorries in
`Theories/Bimodal/Metalogic/WeakCanonical/Kamp/KampPrior.lean`:
- **S1** at `:519` — the `| _k + 2, _sub_nf =>` **k>=2 residual** of the `| 1 =>` arm (the k=0 and
  k=1 legs are ALREADY discharged and frozen — see Preserved Assets);
- **S2** at `:522` — the `| n + 2 =>` **arity-lift arm** (off critical path, in-scope for zero-debt).

Both sorries need depth>=1 fiber-marking supply theorems (interior ledger rows 5-6, exterior
ledger rows 8-11) whose obligation shapes were previously **machine-refuted FALSE at m=1** by three
sorry-free countermodel probes. Task **363 has now landed** the depth-graded fiber-consistency
interface that overturns those countermodels: the D7 doppelganger-tail fake `s*` is excluded by a
per-fiber consistency guard (`kvE_fiberConsistent`) placed inside the exterior admissibility
conjunct and threaded as an interior antecedent pair. This revision **re-keys** 358's Phase 7/8
supply theorems to 363's recorded predicate signature and drops the now-landed k<=1 work.

The mathematical method (Rabinovich 2014 Cor 5.4(1)⇐, constructive Until + two-way `min`/case-split)
is SETTLED and its engine is LANDED sorry-free (KampPrior.lean:1192-1649, task 358 Phases 1-2). The
work that remains is exactly the depth>=1 *supply* of the interior/exterior obligations plus the two
arm rewrites that consume them.

**Definition of done** (binding): `:519` and `:522` both sorry-free; all 11 ledger rows discharged
at the `kampPrior_site_rungK_gate_match` recursion site over 363's fiber-consistent population; full-tree
`lake build` GREEN; `#print axioms nf_nvar_exist_all_depths` and `#print axioms completeness_discrete`
= `[propext, Classical.choice, Quot.sound]` (+ acceptable `ofReduceBool`/`trustCompiler` from
`native_decide` in the Syntax layer) with **NO `sorryAx`**. `:522` CANNOT be silently deferred.

### Research Integration

Newly integrated this revision (v03 -> v04):

- **reports/06_remaining-work-and-plan-revision.md** (round 6). Integration effects:
  1. **The source advanced past plan v3.** When v3 was written the whole `| 1 =>` arm was a single
     strategic sorry at `:361`. Since then task 309 v10 P20-21 (`kampPrior_case1_arm_k1`) and task 358
     P5.1 (`kampPrior_case1_arm_k0`), over task 350's six landed `kampArm_*_{k0,k1}_correct` carriers,
     **discharged the k=0 and k=1 legs**. The two live sorries are now precisely `:519` (k>=2 residual)
     and `:522` (arity-lift). v3's Phases 4-5 are therefore SUBSUMED and dropped; their remaining
     general-k content lives inside S1.
  2. **v3 Phases 7-8 are no longer hard-blocked.** They were blocked on the interface defect D7 (the
     three `kvE_probeM1_*` NO-GO countermodels). Task 363 landed the fix. This plan's P2-P4 re-key those
     supply theorems to 363's interface.
  3. **Recommended flow adopted:** resume at G2 (exterior) -> G1 (interior) -> arm rewrites retiring
     `:519` then `:522` (report 06 §4.2).
- **specs/363/summaries/01_interface-restatement-summary.md** (the re-keying contract). Integration
  effects: the supply-theorem statements of P2-P4 are keyed to the FINAL PREDICATE SIGNATURE
  (`kvE_fiberElemConsistent` / `kvE_fiberConsistent`, direction-agnostic), the exterior conjunct-2
  in-body placement, and the interior antecedent PAIR (`_hfiberCons` binder + per-sigma
  `kvE_fiberConsistent sigma = true ->` antecedent on both `_hreal` and `_hexcl`). The honest-population
  discharge key is `kvE_fiberConsistent_of_realized`.

### Preserved Assets (ALREADY LANDED — FROZEN, OUT OF SCOPE, do NOT re-open)

Green; consumed by name; MUST NOT regress, be re-derived, or overwritten.

| Landed asset | Interface (by name) | File:line | Owner |
|---|---|---|---|
| **k=0 arm of `| 1 =>`** (depth-2 milestone) | `kampPrior_case1_arm_k0` | KampPrior.lean:271 | task 358 P5.1 — **FROZEN** |
| **k=1 arm of `| 1 =>`** | `kampPrior_case1_arm_k1` | KampPrior.lean:301 | task 309 P20 — **FROZEN** |
| Off-diagonal carriers (k0/k1) | `kampArm_{past,diag,future}_{k0,k1}(_correct)` | AggregateHookDischarge.lean | task 350 — **FROZEN** |
| Realizer engine (Cor 5.4⇐) | `kampPrior_fChain_realize_from/_bracket/_cons`, `kampPrior_{fut,past}Realizer_assemble/_of_pos` | KampPrior.lean:1192/1292/1426/1479/1506/1539/1598 | task 358 P1-2 — [COMPLETED] sorry-free |
| Consumer stack | `endIntervalStepPrior`/`endIntervalPrior`/`EndIntervalCorrectPrior`/`endInterval_step_correct`/`endInterval_correct` | EndIntervalConsumerK.lean:55/70/97/185/220 | 357+349 |
| Obligation-disposition ledger (BINDING) | 11-row table | EndIntervalConsumerK.lean | 349 |
| Site seam (single-depth providers) | `kampPrior_site_rungK_gate_match` | KampPrior.lean:924+ | 349 (363-mirrored antecedents) |
| Provider shim | `kampPrior_existProviders_of_ih` (+`_correct`/`_existF0_char`/`_exist1`/`_one_of_ih`/`_zero`) | KampPrior.lean:985-1122 | [COMPLETED] |
| Trichotomy assemble | `kampPrior_case1_trichotomy_assemble` | KampPrior.lean:1146 | [COMPLETED] |
| **m=0 slice supply** (360) | `kvE_hsliceFut_supply_zero`/`kvE_hexclSliceFut_supply_zero` (+Past) | ExteriorPinnedConverseK.lean:1301/1242; PastK:822/769 | 360 — **FROZEN, byte-unchanged by 363** |
| Slice-id/uniqueness kernels (m=0) | `kvE_{fut,past}SliceId_of_end_zero`/`kvE_{fut,past}SliceUnique_zero` | ExteriorPinnedConverseK.lean:891; PastK:530 | 360 — **FROZEN** |
| hbr* refutation regression guard | `kvE_futPinned_of_end_zero_refuted` | ExteriorPinnedConverseK.lean:500 | do NOT delete/weaken |
| **363 fiber-consistency predicate** | `kvE_fiberElemConsistent`/`kvE_fiberConsistent` (+`_zero`, `_of_realized`, `kvE_nf_mem_univ_toList`) | NfMultiAnchorBridge/ExteriorFiberConsistencyK.lean | **363 — the re-keying contract; consume by name** |
| 363 exterior guard | `kvE_futAdmissible`/`kvE_pastAdmissible` conjunct-2 body + `kvE_fut/pastRealizer_admissible` + `kvE_futAdmissible_fiber_dichotomy` | ExteriorNegation{K,PastK}.lean; ExteriorConverter{K,PastK}.lean | **363 — FROZEN** |
| 363 re-probe certificates | `kvE_probe363_*` (sigma_inadmissible / tau_admissible / qnfG1_antecedent_fails) | ExteriorFiberConsistencyProbeK.lean | **363 — the GREEN re-probe evidence** |
| Superseded/retained NO-GO record | `kvE_probeM1_sliceId_superseded`; retained `kvE_probeM1_interiorHreal_NOGO`, `kvE_probeM1_interiorGuard_identical` | ExteriorPinnedProbeM1K.lean | 363 — residual, NOT regressions |
| n=0 / k=0 target arms | `nf_nvar_exist_all_depths` `| 0 =>` (:224), `| k+1, 0 =>` (:335-346) | KampPrior.lean | do NOT touch |

**Task 360's m=0 supply proofs and statements are byte-unchanged by 363** (git-diff verified in 363's
summary); this plan MUST keep them so. The k<=1 rungs and `kampPrior_case1_arm_k0` are in 363's frozen
table and untouched.

## Goals & Non-Goals

- **Goals**:
  - Re-key and prove the depth>=1 exterior slice supply (G2 — ledger rows 8-11) at general m,
    against 363's strengthened `kvE_futAdmissible`/`kvE_pastAdmissible` conjunct-2 (fiber-consistent
    population only).
  - Re-key and prove the depth>=1 interior supply (G1 — ledger rows 5-6) against 363's interior
    antecedent PAIR (`_hfiberCons` binder + per-sigma `kvE_fiberConsistent` antecedent), discharging
    `hfiberCons` on honest/realized ambients via `kvE_fiberConsistent_of_realized`.
  - Rewrite the `| _k + 2, _sub_nf =>` body to discharge all 11 ledger rows and replace the `:519` sorry.
  - Adjudicate and rewrite the `| n + 2 =>` arity-lift arm, replacing the `:522` sorry.
  - Terminal: `nf_nvar_exist_all_depths` AND `completeness_discrete` sorryAx-free (floor axioms only).
- **Non-Goals**:
  - Do NOT re-open, re-derive, or modify any Preserved Asset (esp. k<=1 arms, task 350 carriers, task
    360 m=0 supply, task 363 predicate/guard/probes).
  - Do NOT restate the 363 interface itself — consume it exactly as landed.
  - Do NOT route exterior discharge through `kvE_{fut,past}Bundle_of_realizer` (machine-refuted v2 route).
  - Do NOT re-introduce any `hbr*`-shaped universal binder; do NOT delete the refutation regression guard.
  - No `simp`/`omega`/`aesop` past literature-mapped case-splits; Formula `A` must be M-independent.

## Risks & Mitigations

- **Risk: 363's interface closed only a slice-list-equality tweak, not the anchor-content (x/t) variant
  ("P17-frozen-interface-gap").** If the pinned coordinates the G1 driver transfer inputs
  (`hreal`/`hsat`, KampPrior:1546-1554) require are still projected away, G1 remains unservable.
  **Mitigation**: P1 is a hard gate — confirm by name that `kvE_fiberConsistent`'s depth recursion
  carries the fiber's inner-form content (per 363 summary: `kvE_fiberElemConsistent` recurses on `.2`
  and mate-checks the atom layer), and that `kvE_fiberConsistent_of_realized` supplies exactly the
  transfer inputs the drivers consume. If P1 finds the anchor-content variant NOT closed, escalate
  [BLOCKED] + spawn a follow-up 363-style interface task (see Rollback/Contingency).
- **Risk: general-m slice identification kernel (G2-1/G2-2) does not generalize off m=0.** This was the
  honest risk flagged in v3. **Mitigation**: build the uniqueness/readback kernel ONCE (route R3);
  G1's `hexcl` consumes the same kernel. Verify each conjunct against the FROZEN m=0 layer
  conjunct-by-conjunct (route R2) so m=0 stays byte-unregressed.
- **Risk: the exterior conjunct is INSIDE `kvE_futAdmissible` conjunct-2's body**, so destructor access
  paths differ from a top-level `&&`. **Mitigation**: read conjunct-2 via
  `kvE_futAdmissible_fiber_dichotomy` (363, `rw [Bool.or_eq_true, Bool.and_eq_true, decide_eq_true_eq]`);
  do not hand-roll a fifth-conjunct destructure.
- **Risk: `:522` arity-lift does not close green under either reduction route.** **Mitigation**: G4-1
  route adjudication at P6 start; if neither closes, escalate [BLOCKED] + spawn an isolated arity-lift
  task, keep S1 landed — NEVER a carried sorry.
- **Risk: touching 360's m=0 proofs or the k<=1 rungs.** **Mitigation**: per-phase `git diff` audit
  against the frozen table; scoped `lake build` per phase; full-tree build at terminus.

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2 | 1 |
| 3 | 3, 4 | 2 |
| 4 | 5 | 3, 4 |
| 5 | 6 | 5 |

Phases within the same wave can execute in parallel. (P3 and P4 are independent given P2's shared
kernel: P3 finishes the exterior supply family, P4 the interior supply; both consume the P2 readback
kernel and the 363 predicate but write disjoint territory — ExteriorPinnedConverse{K,PastK} vs.
KampPrior/interior leaf.)

### Phase 1: Consume and pin the task-363 interface [COMPLETED]

> **P1 outcome (2026-07-14, sess_1784045100_2e3ffe)**: all six checklist items executed —
> signatures/conjunct-2/antecedent-pair pinned by name; three re-probe certificates
> lean_verify GREEN at floor axioms; target signatures recorded in
> handoffs/phase-1-handoff-20260714.md. **Anchor-content gate: PASSED-WITH-ADVERSE-FINDING** —
> the interface is exactly as contracted, but an analytical residual countermodel against the
> G2 rows-8-11 binder at m=1 was identified (const-false interior-zone planted mate `s'#`
> restores restated admissibility of the s*-augmented slice). Machine adjudication routed to
> P2's probe gate per route R2; see the handoff §5 for the full construction.
- **Goal:** Bind 363's landed fiber-consistency interface by name and confirm it is the anchor-content
  resolution the G1/G2 supply theorems require — no Lean code written, an interface-pin gate.
- **Tasks:**
  - [ ] Read `ExteriorFiberConsistencyK.lean` and pin the exact signatures of `kvE_fiberElemConsistent`,
        `kvE_fiberConsistent`, `kvE_fiberElemConsistent_zero`/`kvE_fiberConsistent_zero`,
        `kvE_fiberElemConsistent_of_realized`/`kvE_fiberConsistent_of_realized`, `kvE_nf_mem_univ_toList`.
  - [ ] Pin the exterior conjunct-2 body shape in `kvE_futAdmissible`/`kvE_pastAdmissible` and the
        destructor `kvE_futAdmissible_fiber_dichotomy` (`ExteriorConverterK.lean`).
  - [ ] Pin the interior antecedent PAIR text in `EndIntervalConsumerK.lean` (m+2 arm) and
        `kampPrior_site_rungK_gate_match` (`KampPrior.lean`): the `_hfiberCons` binder plus the per-sigma
        `kvE_fiberConsistent sigma = true ->` antecedents on `_hreal` and `_hexcl`.
  - [ ] Re-verify the three re-probe certificates (`kvE_probe363_sigma_inadmissible`,
        `kvE_probe363_tau_admissible`, `kvE_probe363_qnfG1_antecedent_fails`) are GREEN / do not apply
        to the restated interface (this is 363's DoD; v04 confirms before building supply).
  - [ ] **Anchor-content gate**: confirm `kvE_fiberElemConsistent`'s depth recursion (on `.2`, with the
        atom-layer mate check) carries the pinned fiber content the drivers `kampPrior_{fut,past}Realizer_of_pos`
        transfer inputs (`hreal`/`hsat`, KampPrior:1546-1554/1605-1613) consume, and that
        `kvE_fiberConsistent_of_realized` supplies exactly those inputs. If NOT -> [BLOCKED] escalation.
  - [ ] Record, in the phase handoff, the exact supply-theorem target signatures for P2-P4 (G2-1/2/3,
        G1-1/2/3) keyed to the pinned interface.
- **Timing:** 1-2 hours.
- **Depends on:** none.

### Phase 2: G2 slice-identification + uniqueness kernel at general m [BLOCKED]

**BLOCKER** (Phase 2):
- **What failed**: The G2 general-m exterior slice supply (rows 8-11) cannot be built green
  against task 363's landed fiber-consistency interface. The m=1 doppelgänger countermodel that
  363 was spawned to dissolve ADAPTS to the restated interface via a planted interior mate.
- **What was tried**: Machine probe (route R2, plan-mandated) in
  `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge/ExteriorPinnedProbe358K.lean`.
  The decisive certificate `kvE_probe358_eP_atomMate_present` is sorry-free, `lake build` green,
  `lean_verify` = `[propext, Classical.choice, Quot.sound]`, clean source scan.
- **Why it's stuck (minimal failing obligation shape)**: `kvE_fiberElemConsistent`'s mate check
  (`ExteriorFiberConsistencyK.lean:52-55`) is `mergeNF e.atom_assgn ⟨1,_⟩ = s'.atom_assgn` over a
  σ-marked `s'` — an **atom-row-only** comparison with NO realizability / consistency-nontriviality
  / fresh-projection constraint on the mate. Task 363 rejected `σ = τ ⊕ s*` because `s*`'s inner
  witness `e_P` had no atom-mate (`kvE_probe363_fake_elem_inconsistent`). Planting
  `mate := (mergeNF e_P.atom_assgn ⟨1,_⟩, fun _ => false)` — an unrealizable, interior-zoned,
  vacuously-consistent, on-fiber fiber — supplies exactly that missing atom row. The certificate
  exhibits it in `σ₂ := τ ⊕ s* ⊕ mate`, negating the load-bearing step of 363's rejection. The
  full σ₂-level admissibility (every `s*`-marked inner has a mate: u=20 via the plant, all other
  order-classes via honest τ-fibers under the doppelgänger order-remap) is argued by u-class
  enumeration in the probe docstring; its full mechanization is itself research-scale and is the
  escalation task's deliverable, not this gate's.
- **What is needed**: A strengthened fiber-consistency mate check — realizability-anchored (the
  mate must be a genuinely realizable fiber, not an atom-row plant) or depth-recursive mate
  CONTENT comparison (compare the mate's `.2` marking / fresh projection, not only its atom row).
  This is a 363-style interface restatement task; `/spawn 358` to allocate it.
- **Prohibited workarounds**: Do NOT use `sorry`, `def X := True`, or any vacuous placeholder;
  do NOT weaken the rows-8-11 binder to make the FALSE obligation provable.
- **Scope note**: G1 (rows 5-6, interior) is NOT re-broken by this cast — the planted mate is
  projection-visible, so `igFoldBit (qnf ⊕ σ₂) ≠ igFoldBit (honest qnf)` and 363's interior-leg
  separation stands. The blocker is exterior-leg (G2) only. Phases 3-6 are downstream of P2 and
  remain [NOT STARTED].
- **Goal:** Generalize the m=0 slice-id and uniqueness kernels off m=0, re-keyed to 363's
  fiber-consistent admissible population — the shared readback kernel (route R3) that both G2's supply
  and G1's `hexcl` consume.
- **Tasks:**
  - [ ] **G2-1**: prove `kvE_{fut,past}SliceId_of_end` at general m *(deviation: blocked — the
        premise "every admissible sigma is fiber-consistent, so `s*`-class fakes are outside the
        population" is FALSE against 363's interface; the R2 probe `kvE_probe358_eP_atomMate_present`
        (ExteriorPinnedProbe358K.lean) shows the atom-row-only mate check admits a planted interior
        mate that restores admissibility of the `s*`-carrying slice)*.
  - [ ] **G2-2**: prove `kvE_{fut,past}SliceUnique` at general m *(deviation: blocked — downstream of
        G2-1; not attempted)*.
  - [x] Verify the FROZEN m=0 kernels (`_zero`) remain byte-unchanged *(completed: no production file
        touched; only the additive leaf probe `ExteriorPinnedProbe358K.lean` was added)*.
  - [x] R2 probe gate executed *(completed: NO-GO; `kvE_probe358_eP_atomMate_present` sorry-free,
        lean_verify floor axioms, clean source scan)*.
- **Timing:** 4-6 hours.
- **Depends on:** 1.

### Phase 3: G2 four supply theorems at general m [NOT STARTED]
- **Goal:** Prove the four `kvE_hsliceFut_supply` / `kvE_hexclSliceFut_supply` (+ Past mirrors) at
  general m (ledger rows 8-11), conjunct-by-conjunct against the frozen m=0 layer (route R2), reading
  363's conjunct-2 via `kvE_futAdmissible_fiber_dichotomy`.
- **Tasks:**
  - [ ] **G2-3**: prove the four supply theorems. `hslice*` consume the destructor + G2-1; `hexclSlice*`
        consume carried `hreal` + G2-2 uniqueness + the admissibility-zone readback; all read the fiber
        guard via the 363 dichotomy destructor.
  - [ ] Confirm the four m=0 supplies (`kvE_hsliceFut_supply_zero` etc.) are unregressed (byte-identical
        statements AND proofs — git-diff audit).
  - [ ] Scoped build of `ExteriorPinnedConverse{K,PastK}`; `lean_verify` at floor axioms.
- **Timing:** 4-6 hours.
- **Depends on:** 2.
- **Territory:** `ExteriorPinnedConverseK.lean`, `ExteriorPinnedConversePastK.lean` (m=0 frozen; append general-m only).

### Phase 4: G1 interior `hreal`/`hexcl` supply at general depth [NOT STARTED]
- **Goal:** Prove `kampPrior_hreal_supply` / `kampPrior_hexcl_supply` (ledger rows 5-6) over the
  fiber-consistent population, plus discharge `hfiberCons` on honest/realized ambients — the dominant
  new mathematics (Rabinovich Cor 5.4(1)⇐ level descent, chunks 0021-0023 IH).
- **Tasks:**
  - [ ] **G1-1**: split the `w` population. The `=>`-direction ws (ambient `nf_eval_nf M (k+2) 3 [w,x,t] qnf`
        in scope): forall-sigma agreement is DEFINITIONAL — discharge outright. The `<=`-direction ws
        (igPtW-selected): render w's realization of `igFoldBit qnf` via `hcharK` + `P.correct` +
        `kampPrior_existProviders_of_ih_existF0_char` under 363's pinned seam.
  - [ ] **G1-2**: per marked sigma, the fold-bit -> chain-firing bridge. Exterior-zone sigma: fold bit fires
        `kvE_{fut,past}Pos (Pbr) sigma`; drivers `kampPrior_{fut,past}Realizer_of_pos` select `x1` and emit
        `hsigma`; their transfer inputs are the SAME statement one fiber level down — close by the recursion's
        IH at depth k (level descent; depth-0 base atomic, ExteriorFiberProbeK.lean:252 pattern).
        Interior-zone sigma (`x1 ∈ (x,t)`): `kampPrior_fChain_realize_bracket` with F-chain firing from the
        fold-bit fiber content, bracket endpoints `(x,t)`.
  - [ ] **G1-3**: `hexcl` contrapositive channel — a within-`[x,t]` realizer of a bit-false sigma
        back-propagates through the fold (`nf_eval_nfk_iff_efold`) to contradict the igPtW agreement, via
        the P2 (G2-2) uniqueness/readback kernel.
  - [ ] Discharge `hfiberCons`: on honest/realized ambient qnf, apply `kvE_fiberConsistent_of_realized`;
        the fake `qnfG1` fails the antecedent and is outside the population (363's guard).
  - [ ] Deliver `kampPrior_hreal_supply`, `kampPrior_hexcl_supply` matching the restated rows-5-6
        antecedent shapes. Scoped build; `lean_verify` at floor axioms.
- **Timing:** 6-9 hours (the heaviest phase; if it exceeds one agent run, split G1-1/G1-2 from G1-3
  along the `hreal`/`hexcl` boundary — both consume the P2 kernel).
- **Depends on:** 2 (shared readback kernel). May run in parallel with 3.
- **Territory:** `KampPrior.lean` (or a new leaf under `Kamp/` if it grows unwieldy).

### Phase 5: Arm rewrite — retire S1 (`:519`, the k>=2 residual) [NOT STARTED]
- **Goal:** Rewrite the `| _k + 2, _sub_nf =>` body to discharge all 11 ledger rows and replace the
  `:519` sorry (route R4).
- **Tasks:**
  - [ ] **G3c-1**: instantiate providers via `kampPrior_existProviders_of_ih … (fun n sub =>
        nf_nvar_exist_all_depths atomMap h_surj j n sub)` at `j = k'+1, k'` (structurally decreasing
        recursive calls — the documented Phase-16 move, KampPrior:955-958). Rows 1-2 discharged.
  - [ ] **G3c-2**: discharge rows 5-6 via P4 (G1) + `hfiberCons`; rows 8-11 via 360's m=0 + P3 (G2-3);
        rows 3-4 ambient; row 7 internal (task 356). Close via `kampPrior_case1_trichotomy_assemble` +
        `kampPrior_site_rungK_gate_match` (single-depth providers, route R1 — NOT `endInterval_correct`).
  - [ ] Replace the `:519` sorry; update the fencing note (KampPrior:352-360 + the residual comment
        :507-517 naming `P17-frozen-interface-gap`) in the SAME edit to record the 363 resolution.
  - [ ] Scoped build of `KampPrior`; confirm `:519` gone; `lean_verify nf_nvar_exist_all_depths` shows
        only `:522` still contributing `sorryAx` (S1 retired).
- **Timing:** 3-5 hours.
- **Depends on:** 3, 4.

### Phase 6: G4 — retire S2 (`:522`, the arity-lift arm) + terminal audit [NOT STARTED]
- **Goal:** Adjudicate and rewrite the `| n + 2 =>` arity-lift arm, replace the `:522` sorry, and
  perform the terminal full-tree + axiom audit.
- **Tasks:**
  - [ ] **G4-1** route adjudication (report 04 §3 G4): (i) iterated one-variable reduction through the
        `| 1 =>` machinery (`Fin.cons x (insertEnv env t) = insertEnv (Fin.cons x env) t`, KampPrior:235;
        needs an arity-general restatement of the arity-2-specific trichotomy/nf_char2 layer) vs.
        (ii) docstring bootstrap (KampPrior:323-331). The realizer engine/drivers are already
        arity-generic (`BracketFormula (n+1)`, KampPrior:1183-1185).
  - [ ] Rewrite the `| n + 2 =>` arm; replace the `:522` sorry.
  - [ ] **If neither route closes green** -> [BLOCKED] + spawn an isolated arity-lift task; S1 stays
        landed; NEVER a carried sorry (see Rollback/Contingency).
  - [ ] **Terminal audit**: full-tree `lake build` GREEN; `grep -n "sorry" KampPrior.lean` shows no
        live sorry; `#print axioms nf_nvar_exist_all_depths` and `#print axioms completeness_discrete`
        = `[propext, Classical.choice, Quot.sound]` (+ acceptable native_decide axioms), NO `sorryAx`.
  - [ ] Confirm downstream unlock: retiring `:519`/`:522` fully retires task 309's `:361` and unblocks
        task 307 Phase 7 (note in the completion summary; do not action here).
- **Timing:** 2-4 hours.
- **Depends on:** 5.

## Testing & Validation

- [ ] **Per-phase scoped `lake build`**: `Bimodal.Metalogic.WeakCanonical.Kamp.KampPrior` +
      `ExteriorPinnedConverse{K,PastK}` for the G2 phases (P2, P3).
- [ ] **Interface re-probe GREEN (P1 gate)**: `kvE_probe363_sigma_inadmissible`,
      `kvE_probe363_tau_admissible`, `kvE_probe363_qnfG1_antecedent_fails` confirmed to hold /
      the retained `kvE_probeM1_*` residuals confirmed non-regressive against 363's interface.
- [ ] **Frozen-boundary audit**: per-phase `git diff` confirms zero changes to task 360's m=0 supply
      statements+proofs, the k<=1 rungs, `kampPrior_case1_arm_k0`, and 363's predicate/guard/probe
      declarations.
- [ ] **Zero live sorries at terminus**: `grep -n "sorry" KampPrior.lean` shows only doc/comment
      occurrences (currently exactly two live: `:519`, `:522`).
- [ ] **Axiom transcript**: `lean_verify` / `#print axioms` on `nf_nvar_exist_all_depths`,
      `nf_characterizable_temporal_prior` (KampPrior:407), and `completeness_discrete` =
      `[propext, Classical.choice, Quot.sound]` with NO `sorryAx`. Any `sorryAx` is a FAIL.
- [ ] **Per-phase `lean_verify`**: each new supply theorem / arm rewrite at floor axioms, no new axiom.
- [ ] **Full-tree `lake build` GREEN** at the terminal phase (baseline: ~1752 jobs post-363).

## Artifacts & Outputs

- plans/04_realizer-recursion-v04.md (this file)
- summaries/04_realizer-recursion-v04-summary.md (on implementation completion)
- Lean edits (no new plan files): general-m supply theorems in `ExteriorPinnedConverse{K,PastK}.lean`;
  `kampPrior_hreal_supply`/`kampPrior_hexcl_supply` in `KampPrior.lean` (or a new `Kamp/` leaf); the
  two arm rewrites replacing `:519` and `:522`.

## Rollback/Contingency

- **Per-phase green commits** (git-workflow.md mandate): each verified-green sub-step is committed as it
  lands (`task 358 phase P.O: {objective}`), so any failure rolls back to the last green milestone
  without losing landed supply theorems.
- **P1 anchor-content gate fails** (363 closed only the slice-list variant, not the x/t anchor-content
  variant): do NOT attempt G1/G2 build-out. Set 358 [BLOCKED] with `blockers` naming a NEW follow-up
  interface task (363-style anchor-content restatement); `/spawn 358` to allocate it; escalate. Never
  force supply against an unservable driver transfer input.
- **A G2 or G1 supply obligation cannot close green against 363's interface** (a residual countermodel
  survives, or a conjunct is FALSE-as-restated): mark the specific supply theorem's phase [BLOCKED],
  record the minimal failing obligation shape, `/spawn 358` an isolated interface-refinement task, and
  keep all prior-phase green landings intact. NEVER land a sorry or a vacuous def to reach a build.
- **P6 `:522` arity-lift cannot close** under either route (i)/(ii): mark P6 [BLOCKED], spawn an isolated
  arity-lift task, leave S1 (`:519`) landed and committed. S1 retirement is itself a shippable
  milestone (nf_nvar_exist_all_depths sorryAx-free at the k>=2 depth arm; only the arity-lift arm
  remains).
- **Regression detected** (m=0 layer, refutation guard, or k<=1 rungs changed): revert the offending
  edit via targeted `git checkout` of that file to the last green commit (snapshot first per
  git-workflow.md), re-run the scoped build, and re-attempt within the phase territory only.
