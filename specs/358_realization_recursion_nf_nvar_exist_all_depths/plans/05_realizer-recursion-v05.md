# Implementation Plan: Realization Recursion `nf_nvar_exist_all_depths` — G2 Supply Re-Keyed to Task 364's Co-Realization Interface (v05)

- **Task**: 358 - Retire the two remaining `nf_nvar_exist_all_depths` open arms (KampPrior.lean:519 k>=2 residual, :522 arity-lift) by supplying the depth>=1 interior/exterior fiber-marking obligations, re-keyed to task 364's landed co-realization mate-check strengthening
- **Status**: [NOT STARTED]
- **Effort**: 18-29 hours remaining (Phase 1 [COMPLETED]; 5 build/rewrite phases; the v04 Phase 2 blocker is DISSOLVED by task 364 — the G2 re-key is a routing change plus lemma citations, not new mathematics)
- **Dependencies**: 349 (completed — consumer stack + obligation ledger), 356 (completed), 357 (completed), 360 (completed — slice re-key + m=0 supply), 363 (completed — depth-graded fiber-consistency interface restatement), 364 (completed, commits ca1a40f90..5dbda1905 — co-realization mate-check strengthening; UNBLOCKS Phase 2, 2026-07-14)
- **Research Inputs**:
  - reports/08_g2-rekey-against-364-interface.md (round 8, 2026-07-14 — AUTHORITATIVE driver for this revision: the new joint co-realization obligation, the three byte-stable discharge lemmas, arity/depth alignment, the concrete G2-1/G2-2 re-key step list, frozen-layer confirmation)
  - reports/06_remaining-work-and-plan-revision.md (round 6 — two-live-sorry map, ordered decomposition G2->G1->arm rewrites, verification bar; still authoritative for overall flow)
  - specs/363_restate_depth1_fibermarking_interface_and_reprobe_g1g2/summaries/01_interface-restatement-summary.md (predicate signature baseline `kvE_fiberElemConsistent`/`kvE_fiberConsistent`; task 364 strengthened bodies only — statements byte-stable)
  - reports/04_post-360-gap-map-and-route.md (gap map G1-G4, route notes R1-R5; authoritative for the *mathematics* of each gap)
  - reports/02_literature-proof-method-survey.md (Rabinovich 2014 Cor 5.4(1)⇐; grounds the LANDED Phases 1-2 realizer engine)
- **Reports Integrated**: 08_g2-rekey-against-364-interface.md (v05), 06_remaining-work-and-plan-revision.md (v04), 04_post-360-gap-map-and-route.md (v03/v04), 02_literature-proof-method-survey.md (v02)
- **Artifacts**: plans/05_realizer-recursion-v05.md (this file)
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
ledger rows 8-11). Plan v04's Phase 2 was **[BLOCKED]**: the G2 exterior slice supply was
machine-refuted (probe `kvE_probe358_eP_atomMate_present`) because task 363's
`kvE_fiberElemConsistent` mate check was **atom-row-only**, admitting a planted unrealizable
interior mate (`.2 = fun _ => false`) that restored admissibility of the `s*`-carrying slice σ₂.
**Task 364 has now landed the fix** (commits ca1a40f90..5dbda1905): the mate check additionally
requires a **joint co-realization witness** `⟨M, env, u⟩` of σ and the mate in one model
(`nf_eval_nf M (j+2) n env σ ∧ nf_eval_nf M (j+1) (n+1) (Fin.cons u env) s'`). The σ₂ plant is
now rejected at all three guard levels (`kvE_probe364_sigma2_{sstar_inconsistent,
slice_inconsistent, inadmissible}`), and `kvE_probe364_sstar_honest_unrealizable` collapses the
u-class enumeration the v04 blocker left research-scale: no mate supply can service any class
inside an unrealizable ambient, so "σ carries a realizer or it is inadmissible."

The re-key is a **routing change, not new mathematics**: the G2 supply's only new obligation is to
carry a realizer `nf_eval_nf M (m+1) n env σ` (free for the realizer-derived supply population —
σ's built from `nf_characteristic`/`kvE_futRealizer_*`) and discharge the mate/admissibility
obligation exclusively through three BYTE-STABLE lemmas (task 364 re-proved bodies only;
statements unchanged): `kvE_fiberElemConsistent_of_realized` (ExteriorFiberConsistencyK.lean:149),
`kvE_fiberConsistent_of_realized` (:238), `kvE_futRealizer_admissible` (ExteriorNegationK.lean:131).
Arity aligns without a cast: `kvE_futRealizer_admissible` is fixed at n=4 with the pinned env
`(x1,w,x,t)` — exactly the G2 exterior-slice supply population — and `_of_realized` is stated
`∀ {k n}` with induction on k, covering every rung the G2 supply reaches. No depth-offset gap.

The mathematical method (Rabinovich 2014 Cor 5.4(1)⇐, constructive Until + two-way `min`/case-split)
is SETTLED and its engine is LANDED sorry-free (KampPrior.lean:1192-1649, task 358 Phases 1-2). The
work that remains is exactly the depth>=1 *supply* of the interior/exterior obligations plus the two
arm rewrites that consume them.

**Definition of done** (binding, carried unchanged from v04): `:519` and `:522` both sorry-free;
all 11 ledger rows discharged at the `kampPrior_site_rungK_gate_match` recursion site over the
fiber-consistent (now co-realization-anchored) population; full-tree `lake build` GREEN;
`#print axioms nf_nvar_exist_all_depths` and `#print axioms completeness_discrete`
= `[propext, Classical.choice, Quot.sound]` (+ acceptable `ofReduceBool`/`trustCompiler` from
`native_decide` in the Syntax layer) with **NO `sorryAx`**. `:522` CANNOT be silently deferred.

### GLOBAL ROUTING CONSTRAINT (binding on Phases 2-6)

**Never unfold the strengthened guard body.** Any proof that does `rw [kvE_fiberElemConsistent]`
(or `unfold`/`simp only [kvE_fiberElemConsistent]`) and attacks the new `decide (∃ …)`
co-realization conjunct by hand re-opens the plantability surface task 364 closed. All consumption
of `kvE_fiberElemConsistent` / `kvE_fiberConsistent` / the `kvE_futAdmissible` conjunct-2 fiber
guard MUST route through the byte-stable discharge lemmas:
- `kvE_fiberElemConsistent_of_realized` (ExteriorFiberConsistencyK.lean:149) — element level; it
  constructs the joint co-realization witness internally (lines 159-208, feeding
  `⟨M, env, u, hσ, nf_characteristic_satisfies …⟩` into the decide-conjunct);
- `kvE_fiberConsistent_of_realized` (ExteriorFiberConsistencyK.lean:238) — fiber level: a realizer
  of σ makes `kvE_fiberConsistent σ = true`;
- `kvE_futRealizer_admissible` (ExteriorNegationK.lean:131) — top-level entry point: the pinned
  4-variable realizer `(x1,w,x,t)` with strict order chain `x<w<t<x1` returns
  `kvE_futAdmissible σ = true` directly (zone-marking + 3-conjunct on-fiber/consistency legs);
- reading direction only: `kvE_futAdmissible_fiber_dichotomy` (363, unchanged) for destructuring.

This constraint propagates to EVERY phase below; each phase's verification includes a source scan
for `rw [kvE_fiberElemConsistent]` / `unfold kvE_fiberElemConsistent` in newly added proofs (zero
occurrences allowed).

### Research Integration

Newly integrated this revision (v04 -> v05):

- **reports/08_g2-rekey-against-364-interface.md** (round 8, 2026-07-14). Integration effects:
  1. **Phase 2 UNBLOCKED.** The v04 blocker premise — "every admissible σ is fiber-consistent, so
     `s*`-class fakes are outside the population" was FALSE against 363's atom-row-only interface —
     is now TRUE against 364's interface: `kvE_probe364_sigma2_inadmissible` proves
     `kvE_futAdmissible m2sigma = false`, i.e. the `s*`-carrying planted slice is excluded from the
     admissible population at guard level. Phase 2 is restated [NOT STARTED] with the blocker
     resolution recorded (see Phase 2's resolution record).
  2. **G2-1/G2-2 re-keyed** to route the mate/admissibility discharge through
     `kvE_futRealizer_admissible` / `_of_realized` — the supply constructs the pinned realizer
     `(x1,w,x,t)` for each honest exterior slice and applies the lemma, rather than matching atom
     rows. New explicit instruction: never `rw [kvE_fiberElemConsistent]`.
  3. **U-class enumeration closed.** `kvE_probe364_sstar_honest_unrealizable` (ANY slice marking
     `s*` + one honest fiber is realized in no model) is cited as the closure for the enumeration
     the v04 phase-2 handoff left research-scale.
  4. **Routing rule propagated to Phases 3-6** (see GLOBAL ROUTING CONSTRAINT above) — downstream
     supply theorems, G1 `hexcl`, and the arm rewrites consume the strengthened guard only through
     the byte-stable lemmas.
  5. **Re-probe gate redefined**: the Phase 2 R2 gate becomes re-run
     `kvE_probe358_eP_atomMate_present` (still TRUE — the atom row IS present) AND confirm
     `kvE_probe364_sigma2_inadmissible` (guard-level rejection). The atom row no longer sufficing
     is the definition of the blocker being closed.
  6. **Frozen layers confirmed untouched**: the re-key introduces NO edit to rung0/rung1, task 360
     m=0 supply, `kampPrior_case1_arm_k0`, or the 363/364 predicate/guard/probes; task 364 already
     verified all five consumer modules compile against the strengthened guard with zero statement
     changes.

Carried from v04 (still integrated): reports/06 (flow G2 -> G1 -> arm rewrites; two-live-sorry
map), specs/363 summary (predicate signature), reports/04 (gap mathematics), reports/02
(Rabinovich engine grounding).

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
| **m=0 slice supply** (360) | `kvE_hsliceFut_supply_zero`/`kvE_hexclSliceFut_supply_zero` (+Past) | ExteriorPinnedConverseK.lean:1301/1242; PastK:822/769 | 360 — **FROZEN, byte-unchanged by 363/364** |
| Slice-id/uniqueness kernels (m=0) | `kvE_{fut,past}SliceId_of_end_zero`/`kvE_{fut,past}SliceUnique_zero` | ExteriorPinnedConverseK.lean:891; PastK:530 | 360 — **FROZEN** |
| hbr* refutation regression guard | `kvE_futPinned_of_end_zero_refuted` | ExteriorPinnedConverseK.lean:500 | do NOT delete/weaken |
| 363 fiber-consistency predicate (statements) | `kvE_fiberElemConsistent`/`kvE_fiberConsistent` (+`_zero`, `kvE_nf_mem_univ_toList`) | NfMultiAnchorBridge/ExteriorFiberConsistencyK.lean | 363, **body strengthened by 364** — consume by name, NEVER unfold |
| **364 co-realization mate check** | strengthened `kvE_fiberElemConsistent` succ-arm body (joint `decide (∃ M env u, …)` conjunct) | ExteriorFiberConsistencyK.lean | **364 (ca1a40f90..5dbda1905) — the re-keying contract; FROZEN** |
| **364 byte-stable discharge lemmas** | `kvE_fiberElemConsistent_of_realized` (:149), `kvE_fiberConsistent_of_realized` (:238), `kvE_futRealizer_admissible` (ExteriorNegationK.lean:131) | ExteriorFiberConsistencyK.lean; ExteriorNegationK.lean | **364 — the ONLY sanctioned discharge route; statements unchanged from 363** |
| **364 rejection certificates** | `kvE_probe364_sigma2_{sstar_inconsistent, slice_inconsistent, inadmissible}`, `kvE_probe364_sstar_honest_unrealizable` | 364 probe leaf | **364 — the GREEN blocker-dissolution evidence; cite, do not modify** |
| 363 exterior guard | `kvE_futAdmissible`/`kvE_pastAdmissible` conjunct-2 body + `kvE_futAdmissible_fiber_dichotomy` | ExteriorNegation{K,PastK}.lean; ExteriorConverter{K,PastK}.lean | 363/364 — **FROZEN** |
| 363 re-probe certificates | `kvE_probe363_*` (sigma_inadmissible / tau_admissible / qnfG1_antecedent_fails) | ExteriorFiberConsistencyProbeK.lean | 363 |
| 358 P2 refutation probe (historical) | `kvE_probe358_eP_atomMate_present` | ExteriorPinnedProbe358K.lean | 358 P2 — retained as regression record (atom row present; no longer sufficient under 364) |
| Superseded/retained NO-GO record | `kvE_probeM1_sliceId_superseded`; retained `kvE_probeM1_interiorHreal_NOGO`, `kvE_probeM1_interiorGuard_identical` | ExteriorPinnedProbeM1K.lean | 363 — residual, NOT regressions |
| n=0 / k=0 target arms | `nf_nvar_exist_all_depths` `| 0 =>` (:224), `| k+1, 0 =>` (:335-346) | KampPrior.lean | do NOT touch |

**Task 360's m=0 supply proofs and statements are byte-unchanged by 363 AND 364** (git-diff
verified in both summaries); this plan MUST keep them so. The k<=1 rungs and
`kampPrior_case1_arm_k0` are untouched by the re-key (report 08 §5).

## Goals & Non-Goals

- **Goals**:
  - Re-key and prove the depth>=1 exterior slice supply (G2 — ledger rows 8-11) at general m,
    against 364's co-realization-strengthened `kvE_futAdmissible`/`kvE_pastAdmissible` conjunct-2,
    carrying a realizer per honest σ and routing discharge through the three byte-stable lemmas.
  - Re-key and prove the depth>=1 interior supply (G1 — ledger rows 5-6) against the interior
    antecedent PAIR (`_hfiberCons` binder + per-sigma `kvE_fiberConsistent` antecedent), discharging
    `hfiberCons` on honest/realized ambients via `kvE_fiberConsistent_of_realized`.
  - Rewrite the `| _k + 2, _sub_nf =>` body to discharge all 11 ledger rows and replace the `:519` sorry.
  - Adjudicate and rewrite the `| n + 2 =>` arity-lift arm, replacing the `:522` sorry.
  - Terminal: `nf_nvar_exist_all_depths` AND `completeness_discrete` sorryAx-free (floor axioms only).
- **Non-Goals**:
  - Do NOT re-open, re-derive, or modify any Preserved Asset (esp. k<=1 arms, task 350 carriers, task
    360 m=0 supply, task 363/364 predicate/guard/probes/discharge lemmas).
  - Do NOT unfold the strengthened guard body (see GLOBAL ROUTING CONSTRAINT) — consume it exactly
    as landed, via `_of_realized` / `kvE_futRealizer_admissible` / the dichotomy destructor.
  - Do NOT route exterior discharge through `kvE_{fut,past}Bundle_of_realizer` (machine-refuted v2 route).
  - Do NOT re-introduce any `hbr*`-shaped universal binder; do NOT delete the refutation regression
    guard or the retained probe certificates (`kvE_probe358_*`, `kvE_probe364_*`).
  - No `simp`/`omega`/`aesop` past literature-mapped case-splits; Formula `A` must be M-independent.

## Risks & Mitigations

- **Risk: a G2 supply σ is NOT realizer-derived** (some honest slice in the admissible population
  lacks an in-scope realizer term), making the new co-realization obligation non-free.
  **Mitigation**: report 08 §3 confirms the actual G2 supply population consists of σ's built from
  `nf_characteristic`/`kvE_futRealizer_*` where the realizer is already in scope. Phase 2's first
  task verifies this per supply site before building; if a non-realizer-derived σ appears, obtain
  its realizer via `nf_characteristic_satisfies` (the same engine `_of_realized` uses internally)
  — never by unfolding the guard. If genuinely unservable, escalate [BLOCKED] per Rollback.
- **Risk: general-m slice identification kernel (G2-1/G2-2) does not generalize off m=0.** Honest
  risk carried from v03/v04 — now REDUCED: uniqueness runs against the realizability-anchored
  population, so the `s*` fake can no longer be a second slice witness (it is inadmissible,
  `kvE_probe364_sigma2_inadmissible`). **Mitigation**: build the uniqueness/readback kernel ONCE
  (route R3); G1's `hexcl` consumes the same kernel. Verify each conjunct against the FROZEN m=0
  layer conjunct-by-conjunct (route R2) so m=0 stays byte-unregressed.
- **Risk: the exterior conjunct is INSIDE `kvE_futAdmissible` conjunct-2's body**, so destructor
  access paths differ from a top-level `&&` — and the body now carries the 3-conjunct
  co-realization check. **Mitigation**: reading direction via `kvE_futAdmissible_fiber_dichotomy`
  (unchanged by 364); proving direction ONLY via `kvE_futRealizer_admissible` / `_of_realized`.
  Do not hand-roll a destructure of the strengthened body.
- **Risk: accidental guard unfolding re-opens the plantability surface.** **Mitigation**: the
  GLOBAL ROUTING CONSTRAINT is verified per phase by source scan (zero
  `rw/unfold/simp only [kvE_fiberElemConsistent]` in new proofs).
- **Risk: `:522` arity-lift does not close green under either reduction route.** **Mitigation**: G4-1
  route adjudication at P6 start; if neither closes, escalate [BLOCKED] + spawn an isolated arity-lift
  task, keep S1 landed — NEVER a carried sorry.
- **Risk: touching 360's m=0 proofs, the k<=1 rungs, or 364's guard/lemmas/probes.**
  **Mitigation**: per-phase `git diff` audit against the frozen table; scoped `lake build` per
  phase; full-tree build at terminus.

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
kernel and the 364-strengthened guard via the byte-stable lemmas, but write disjoint territory —
ExteriorPinnedConverse{K,PastK} vs. KampPrior/interior leaf.)

### Phase 1: Consume and pin the task-363 interface [COMPLETED]

> **P1 outcome (2026-07-14, sess_1784045100_2e3ffe)**: all six checklist items executed —
> signatures/conjunct-2/antecedent-pair pinned by name; three re-probe certificates
> lean_verify GREEN at floor axioms; target signatures recorded in
> handoffs/phase-1-handoff-20260714.md. **Anchor-content gate: PASSED-WITH-ADVERSE-FINDING** —
> the interface is exactly as contracted, but an analytical residual countermodel against the
> G2 rows-8-11 binder at m=1 was identified (const-false interior-zone planted mate `s'#`
> restores restated admissibility of the s*-augmented slice). Machine adjudication routed to
> P2's probe gate per route R2; see the handoff §5 for the full construction.
>
> **v05 note**: the adverse finding was machine-confirmed in v04 P2 (`kvE_probe358_eP_atomMate_present`)
> and subsequently DISSOLVED by task 364's co-realization strengthening. The P1 signature pins
> remain valid — task 364 changed guard BODIES only; all pinned statements are byte-stable
> (report 08 §2, task 364 consumer-module verification).
- **Goal:** Bind 363's landed fiber-consistency interface by name and confirm it is the anchor-content
  resolution the G1/G2 supply theorems require — no Lean code written, an interface-pin gate.
- **Tasks:** (all executed; retained for record)
  - [x] Read `ExteriorFiberConsistencyK.lean` and pin the exact signatures of `kvE_fiberElemConsistent`,
        `kvE_fiberConsistent`, `kvE_fiberElemConsistent_zero`/`kvE_fiberConsistent_zero`,
        `kvE_fiberElemConsistent_of_realized`/`kvE_fiberConsistent_of_realized`, `kvE_nf_mem_univ_toList`.
  - [x] Pin the exterior conjunct-2 body shape in `kvE_futAdmissible`/`kvE_pastAdmissible` and the
        destructor `kvE_futAdmissible_fiber_dichotomy` (`ExteriorConverterK.lean`).
  - [x] Pin the interior antecedent PAIR text in `EndIntervalConsumerK.lean` (m+2 arm) and
        `kampPrior_site_rungK_gate_match` (`KampPrior.lean`).
  - [x] Re-verify the three re-probe certificates (`kvE_probe363_*`) GREEN.
  - [x] Anchor-content gate executed (adverse finding routed to P2's probe gate; since dissolved by 364).
  - [x] Target signatures recorded in handoffs/phase-1-handoff-20260714.md.
- **Timing:** 1-2 hours (spent).
- **Depends on:** none.
- **Completed:** 2026-07-14 (sess_1784045100_2e3ffe).

### Phase 2: G2 slice-identification + uniqueness kernel at general m, re-keyed to 364 [BLOCKED]

> **BLOCKER** (Phase 2, 2026-07-14, sess_1784054976_3cdaea — route-R2 gate NO-GO on the
> general-m kernel; P2-0 itself PASSED):
> - **What failed**: the G2-1 kernel `kvE_{fut,past}SliceId_of_end` at general m — and with it
>   the rows-8-9 binders (`hsliceFut`/`hslicePast`, EndIntervalConsumerK.lean:154-167) at
>   m ≥ 1. The m=0 proof's load-bearing step, the free-env → pinned upgrade
>   (`kvE_futGapItem_pinned_zero`/`kvE_futRayItem_pinned_zero`, consumed by every zone-list
>   inclusion of `kvE_futSliceId_of_end_zero`), is machine-refuted at fiber depth 1:
>   `kvE_probe358_tailDG_gapItem_pinned_fails`
>   (`ExteriorPinnedProbe358TailK.lean`, sorry-free, floor axioms
>   `[propext, Classical.choice, Quot.sound]`).
> - **What was tried**: (i) P2-0 re-probe gate — PASSED (`kvE_probe358_eP_atomMate_present`
>   still TRUE, `kvE_probe364_sigma2_inadmissible` + `kvE_probe364_sstar_honest_unrealizable`
>   lean_verify GREEN at floor axioms) — the v04 planted-mate blocker IS closed; (ii) P2-1
>   population check — PASSED-WITH-ADVERSE-FINDING: the supply population is realizer-derived
>   as report 08 §3 states (τ := `nf_characteristic` at the destructor endpoint, realizer
>   `nf_characteristic_satisfies` in scope, admissibility via the sanctioned
>   `kvE_futRealizer_admissible`), BUT so is the countermodel — carrying a realizer does not
>   pin the realizer's TAIL; (iii) conjunct-by-conjunct generalization audit of
>   `kvE_futSliceId_of_end_zero` (route R2) — every step generalizes EXCEPT the two
>   free-env → pinned upgrades, which rest essentially on the depth-0 three-channel
>   losslessness `nf_eval_nf0_cons_factor`; machine probe then built at m = 1.
> - **Why it's stuck**: an all-honest **tail-doppelgänger** defeats the upgrade INSIDE the
>   364-strengthened admissible population. `(ℤ, <)`, `R = {10}`, real pinned tuple
>   `[35,5,2,30]`, fake tail `[40,12,8,25]` (depth-0 indistinguishable rows): the honest
>   depth-1 5-type `m3s` of the walk point `32` over the FAKE tail is gap-zoned, on-row at
>   the real tuple, free-env realized at `32` (exactly the `hocc`/`kvE_futItemShift_correct`
>   shape — the clause content is intrinsically env-existential), yet pinned-realizable at
>   the real tuple at NO fresh witness (its marked inner `m3eR` demands an R-point in
>   `(w-slot-below)`: `R ∩ (2,5) = ∅`). The ambient fake slice `m3sigma` (depth-2 4-type of
>   the fake tuple, fully realized) passes `kvE_futAdmissible` through
>   `kvE_futRealizer_admissible` itself, sits on the real ambient's fiber, and marks `m3s`
>   on its gap zone list (`kvE_probe358_tailDG_sigma_in_population`). Task 364's
>   co-realization mate check has no purchase: every cast element is honestly realized —
>   there is no fake fiber and no plant, only a second deeply-different but realized
>   environment. Binder-level closure (analytical, recorded in the probe module docstring
>   per the v04 `eP_atomMate` precedent): on a dense homogeneous order the pure fake
>   characteristic fires the ENTIRE `hsliceFut` antecedent stack at the real `t` while no
>   qnf-marked σ' is slice-equal — rows 8-9 are FALSE-as-restated at m ≥ 1.
> - **What is needed**: a 363/364-style interface-refinement task (`/spawn 358`) that
>   DEEP-anchors the exterior fiber population to the ambient — the depth-recursive
>   content-comparison direction the v04 Phase-2 handoff already named (e.g. a depth-graded
>   on-fiber guard tying σ's marked fibers' TAIL content to qnf's deep marking, so σ's
>   realizers' tails cannot float off the ambient anchors), with the rows-8-9 binder
>   restated against it. G2-2 (`SliceUnique`) is NOT refuted by this cast (both σ's there
>   are pinned over the SAME real tail) but should be built only against the refined
>   interface, since the population it quantifies over will be restated.
> - **Prohibited workarounds**: no `sorry`, no `def X := True`/vacuous placeholder, no
>   forcing the supply against the refuted binder, no unfolding
>   `kvE_fiberElemConsistent` (the probe itself routes admissibility exclusively through
>   `kvE_futRealizer_admissible`).

> **BLOCKER RESOLUTION RECORD (v04 [BLOCKED] -> v05 [NOT STARTED], 2026-07-14)**: v04's Phase 2
> was blocked because `kvE_fiberElemConsistent`'s mate check was atom-row-only
> (pre-364 `ExteriorFiberConsistencyK.lean:52-55`), so the σ₂ planted unrealizable mate
> (`.2 = fun _ => false`) restored admissibility of the `s*`-carrying slice — machine-certified by
> `kvE_probe358_eP_atomMate_present` (ExteriorPinnedProbe358K.lean, sorry-free, floor axioms).
> **Task 364 (commits ca1a40f90..5dbda1905) DISSOLVED this**: the mate check now conjoins a joint
> co-realization witness `decide (∃ M env u, nf_eval_nf M (j+2) n env σ ∧
> nf_eval_nf M (j+1) (n+1) (Fin.cons u env) s')`. The σ₂ plant is rejected at all three guard
> levels (`kvE_probe364_sigma2_{sstar_inconsistent, slice_inconsistent, inadmissible}`), and
> `kvE_probe364_sstar_honest_unrealizable` closes the u-class enumeration the v04 handoff left
> research-scale: no per-class mate supply can service any class inside an unrealizable ambient.
> The v04 premise "every admissible σ is fiber-consistent, so `s*`-class fakes are outside the
> population" is now TRUE at guard level. The landed v04-P2 artifacts (frozen m=0 byte-audit,
> `kvE_probe358_eP_atomMate_present`) are retained as regression records — do not delete.
- **Goal:** Generalize the m=0 slice-id and uniqueness kernels off m=0, re-keyed to 364's
  co-realization-anchored admissible population — the shared readback kernel (route R3) that both
  G2's supply and G1's `hexcl` consume. The re-key is a routing change: carry the realizer, apply
  the byte-stable lemmas, never unfold the guard.
- **Tasks:**
  - [x] **P2-0 (re-probe gate, route R2)**: re-run/confirm `kvE_probe358_eP_atomMate_present`
        (still TRUE — the atom row IS present) AND `kvE_probe364_sigma2_inadmissible`
        (`kvE_futAdmissible m2sigma = false` — guard-level rejection). The atom row no longer
        sufficing for admissibility is the machine definition of the blocker being closed. Both
        certificates `lean_verify` at floor axioms before any supply build.
        *(completed 2026-07-14: both + `kvE_probe364_sstar_honest_unrealizable` GREEN at
        `[propext, Classical.choice, Quot.sound]`, no sorryAx — the v04 planted-mate blocker
        is machine-certified closed)*
  - [x] **P2-1 (population check)**: verify per supply site that each honest σ in the G2 exterior
        slice population is realizer-derived (built from `nf_characteristic`/`kvE_futRealizer_*`
        with the realizer `nf_eval_nf M (m+1) n env σ` in scope, n=4 pinned env `(x1,w,x,t)`).
        Record any exception and its `nf_characteristic_satisfies`-derived realizer.
        *(completed 2026-07-14, PASSED-WITH-ADVERSE-FINDING: population is realizer-derived as
        report 08 §3 states — but the tail-doppelgänger countermodel is realizer-derived TOO;
        carrying a realizer does not pin its tail. See phase BLOCKER above.)*
  - [ ] **G2-1 (re-keyed)**: prove `kvE_{fut,past}SliceId_of_end` at general m. Discharge the
        fiber-consistency/admissibility obligations by constructing the pinned realizer
        `(x1,w,x,t)` (strict chain `x<w<t<x1`) for each honest exterior slice and applying
        `kvE_futRealizer_admissible` (top-level) or `kvE_fiberConsistent_of_realized` /
        `kvE_fiberElemConsistent_of_realized` (fiber/element level) — NOT by matching atom rows,
        and NEVER by `rw [kvE_fiberElemConsistent]`. Cite `kvE_probe364_sigma2_*` +
        `kvE_probe364_sstar_honest_unrealizable` for the discharged premise that `s*`-class fakes
        are outside the admissible population.
        *(deviation: BLOCKED — machine-refuted at m = 1 by
        `kvE_probe358_tailDG_gapItem_pinned_fails` + `kvE_probe358_tailDG_sigma_in_population`
        (ExteriorPinnedProbe358TailK.lean, route R2): the load-bearing free-env → pinned
        upgrade fails at fiber depth ≥ 1 inside the 364 admissible population; rows 8-9
        FALSE-as-restated at m ≥ 1. See phase BLOCKER.)*
  - [ ] **G2-2 (re-keyed)**: prove `kvE_{fut,past}SliceUnique` at general m against the
        realizability-anchored population — the `s*` fake cannot be a second slice witness (it is
        inadmissible). Same routing rule; no separate interface obligation.
        *(deviation: deferred — not refuted by the tail-doppelgänger cast (both σ's pinned over
        the SAME tail), but its population will be restated by the interface-refinement spawn;
        build it only against the refined interface)*
  - [ ] Verify the FROZEN m=0 kernels (`_zero`) remain byte-unchanged (git-diff audit); scoped
        build of `ExteriorPinnedConverse{K,PastK}`; `lean_verify` new kernels at floor axioms;
        source scan: zero guard-unfoldings in new proofs.
        *(deviation: altered — no new kernels were landed (G2-1 refuted). Executed for the probe
        session instead: git-status audit confirms zero production-file edits (only the additive
        probe leaf `ExteriorPinnedProbe358TailK.lean`); scoped `lake build` of the probe leaf
        GREEN (1024 jobs); both probe certificates `lean_verify` at floor axioms; source scan:
        zero guard-unfoldings in the new module.)*
- **Timing:** 3-5 hours (reduced from v04's 4-6: the mathematics is routing, not invention).
- **Depends on:** 1.
- **Territory:** `ExteriorPinnedConverseK.lean`, `ExteriorPinnedConversePastK.lean` (m=0 frozen; append general-m only). Read-only: 363/364 guard/lemma/probe files.

### Phase 3: G2 four supply theorems at general m [NOT STARTED]
- **Goal:** Prove the four `kvE_hsliceFut_supply` / `kvE_hexclSliceFut_supply` (+ Past mirrors) at
  general m (ledger rows 8-11), conjunct-by-conjunct against the frozen m=0 layer (route R2).
  **Routing constraint (binding)**: consume the strengthened guard ONLY via
  `kvE_futAdmissible_fiber_dichotomy` (reading) and `kvE_futRealizer_admissible` /
  `_of_realized` (proving); never unfold `kvE_fiberElemConsistent`.
- **Tasks:**
  - [ ] **G2-3**: prove the four supply theorems. `hslice*` consume the dichotomy destructor + G2-1;
        `hexclSlice*` consume carried `hreal` + G2-2 uniqueness + the admissibility-zone readback.
        Admissibility of each supplied σ is established by its carried realizer via
        `kvE_futRealizer_admissible` (n=4 pinned env), not by guard-body inspection.
  - [ ] Confirm the four m=0 supplies (`kvE_hsliceFut_supply_zero` etc.) are unregressed (byte-identical
        statements AND proofs — git-diff audit).
  - [ ] Scoped build of `ExteriorPinnedConverse{K,PastK}`; `lean_verify` at floor axioms; source
        scan: zero guard-unfoldings.
- **Timing:** 4-6 hours.
- **Depends on:** 2.
- **Territory:** `ExteriorPinnedConverseK.lean`, `ExteriorPinnedConversePastK.lean` (m=0 frozen; append general-m only).

### Phase 4: G1 interior `hreal`/`hexcl` supply at general depth [NOT STARTED]
- **Goal:** Prove `kampPrior_hreal_supply` / `kampPrior_hexcl_supply` (ledger rows 5-6) over the
  co-realization-anchored fiber-consistent population, plus discharge `hfiberCons` on
  honest/realized ambients — the dominant new mathematics (Rabinovich Cor 5.4(1)⇐ level descent,
  chunks 0021-0023 IH). **Routing constraint (binding)**: `hfiberCons` discharge is EXCLUSIVELY
  `kvE_fiberConsistent_of_realized` applied to the ambient realizer; never unfold the guard.
- **Tasks:**
  - [ ] **G1-1**: split the `w` population. The `=>`-direction ws (ambient `nf_eval_nf M (k+2) 3 [w,x,t] qnf`
        in scope): forall-sigma agreement is DEFINITIONAL — discharge outright. The `<=`-direction ws
        (igPtW-selected): render w's realization of `igFoldBit qnf` via `hcharK` + `P.correct` +
        `kampPrior_existProviders_of_ih_existF0_char` under the pinned seam.
  - [ ] **G1-2**: per marked sigma, the fold-bit -> chain-firing bridge. Exterior-zone sigma: fold bit fires
        `kvE_{fut,past}Pos (Pbr) sigma`; drivers `kampPrior_{fut,past}Realizer_of_pos` select `x1` and emit
        `hsigma`; their transfer inputs are the SAME statement one fiber level down — close by the recursion's
        IH at depth k (level descent; depth-0 base atomic, ExteriorFiberProbeK.lean:252 pattern).
        Interior-zone sigma (`x1 ∈ (x,t)`): `kampPrior_fChain_realize_bracket` with F-chain firing from the
        fold-bit fiber content, bracket endpoints `(x,t)`.
  - [ ] **G1-3**: `hexcl` contrapositive channel — a within-`[x,t]` realizer of a bit-false sigma
        back-propagates through the fold (`nf_eval_nfk_iff_efold`) to contradict the igPtW agreement, via
        the P2 (G2-2) uniqueness/readback kernel (now realizability-anchored: the fake second witness
        is inadmissible by `kvE_probe364_sigma2_inadmissible`-class reasoning).
  - [ ] Discharge `hfiberCons`: on honest/realized ambient qnf, apply `kvE_fiberConsistent_of_realized`
        to the ambient realizer; the fake `qnfG1` fails the antecedent and is outside the population
        (guard-level, per 364).
  - [ ] Deliver `kampPrior_hreal_supply`, `kampPrior_hexcl_supply` matching the restated rows-5-6
        antecedent shapes. Scoped build; `lean_verify` at floor axioms; source scan: zero
        guard-unfoldings.
- **Timing:** 6-9 hours (the heaviest phase; if it exceeds one agent run, split G1-1/G1-2 from G1-3
  along the `hreal`/`hexcl` boundary — both consume the P2 kernel).
- **Depends on:** 2 (shared readback kernel). May run in parallel with 3.
- **Territory:** `KampPrior.lean` (or a new leaf under `Kamp/` if it grows unwieldy).

### Phase 5: Arm rewrite — retire S1 (`:519`, the k>=2 residual) [NOT STARTED]
- **Goal:** Rewrite the `| _k + 2, _sub_nf =>` body to discharge all 11 ledger rows and replace the
  `:519` sorry (route R4). **Routing constraint (binding)**: any residual fiber-consistency
  obligation at the site is discharged via the byte-stable lemmas; never unfold the guard.
- **Tasks:**
  - [ ] **G3c-1**: instantiate providers via `kampPrior_existProviders_of_ih … (fun n sub =>
        nf_nvar_exist_all_depths atomMap h_surj j n sub)` at `j = k'+1, k'` (structurally decreasing
        recursive calls — the documented Phase-16 move, KampPrior:955-958). Rows 1-2 discharged.
  - [ ] **G3c-2**: discharge rows 5-6 via P4 (G1) + `hfiberCons` (via `kvE_fiberConsistent_of_realized`);
        rows 8-11 via 360's m=0 + P3 (G2-3); rows 3-4 ambient; row 7 internal (task 356). Close via
        `kampPrior_case1_trichotomy_assemble` + `kampPrior_site_rungK_gate_match` (single-depth
        providers, route R1 — NOT `endInterval_correct`).
  - [ ] Replace the `:519` sorry; update the fencing note (KampPrior:352-360 + the residual comment
        :507-517 naming `P17-frozen-interface-gap`) in the SAME edit to record the 363+364 resolution
        chain (363: fiber-consistency guard; 364: co-realization mate check).
  - [ ] Scoped build of `KampPrior`; confirm `:519` gone; `lean_verify nf_nvar_exist_all_depths` shows
        only `:522` still contributing `sorryAx` (S1 retired); source scan: zero guard-unfoldings.
- **Timing:** 3-5 hours.
- **Depends on:** 3, 4.

### Phase 6: G4 — retire S2 (`:522`, the arity-lift arm) + terminal audit [NOT STARTED]
- **Goal:** Adjudicate and rewrite the `| n + 2 =>` arity-lift arm, replace the `:522` sorry, and
  perform the terminal full-tree + axiom audit. **Routing constraint (binding)**: inherited — any
  guard consumption via byte-stable lemmas only.
- **Tasks:**
  - [ ] **G4-1** route adjudication (report 04 §3 G4): (i) iterated one-variable reduction through the
        `| 1 =>` machinery (`Fin.cons x (insertEnv env t) = insertEnv (Fin.cons x env) t`, KampPrior:235;
        needs an arity-general restatement of the arity-2-specific trichotomy/nf_char2 layer) vs.
        (ii) docstring bootstrap (KampPrior:323-331). The realizer engine/drivers are already
        arity-generic (`BracketFormula (n+1)`, KampPrior:1183-1185). Note: `kvE_futRealizer_admissible`
        is pinned at n=4; if the arity-lift route needs guard admissibility off n=4, route through
        `_of_realized` (stated `∀ {k n}`) — never unfold.
  - [ ] Rewrite the `| n + 2 =>` arm; replace the `:522` sorry.
  - [ ] **If neither route closes green** -> [BLOCKED] + spawn an isolated arity-lift task; S1 stays
        landed; NEVER a carried sorry (see Rollback/Contingency).
  - [ ] **Terminal audit**: full-tree `lake build` GREEN; `grep -n "sorry" KampPrior.lean` shows no
        live sorry; `#print axioms nf_nvar_exist_all_depths` and `#print axioms completeness_discrete`
        = `[propext, Classical.choice, Quot.sound]` (+ acceptable native_decide axioms), NO `sorryAx`;
        tree-wide source scan: zero guard-unfoldings introduced by this task.
  - [ ] Confirm downstream unlock: retiring `:519`/`:522` fully retires task 309's `:361` and unblocks
        task 307 Phase 7 (note in the completion summary; do not action here).
- **Timing:** 2-4 hours.
- **Depends on:** 5.

## Testing & Validation

- [ ] **P2-0 re-probe gate (route R2)**: `kvE_probe358_eP_atomMate_present` still TRUE (atom row
      present) AND `kvE_probe364_sigma2_inadmissible` confirms guard-level rejection — both
      `lean_verify` at floor axioms BEFORE any supply build. This pair is the machine certificate
      that the v04 blocker is closed.
- [ ] **Per-phase scoped `lake build`**: `Bimodal.Metalogic.WeakCanonical.Kamp.KampPrior` +
      `ExteriorPinnedConverse{K,PastK}` for the G2 phases (P2, P3).
- [ ] **Guard-unfolding source scan (per phase, binding)**: `grep` newly added proofs for
      `rw [kvE_fiberElemConsistent]`, `unfold kvE_fiberElemConsistent`,
      `simp only [kvE_fiberElemConsistent]` — zero occurrences allowed; all discharge routed through
      `kvE_fiberElemConsistent_of_realized` / `kvE_fiberConsistent_of_realized` /
      `kvE_futRealizer_admissible` / `kvE_futAdmissible_fiber_dichotomy`.
- [ ] **Frozen-boundary audit**: per-phase `git diff` confirms zero changes to task 360's m=0 supply
      statements+proofs, the k<=1 rungs, `kampPrior_case1_arm_k0`, 363's predicate/guard/probe
      declarations, and 364's strengthened bodies + discharge lemmas + `kvE_probe364_*` certificates.
- [ ] **Zero live sorries at terminus**: `grep -n "sorry" KampPrior.lean` shows only doc/comment
      occurrences (currently exactly two live: `:519`, `:522`).
- [ ] **Axiom transcript**: `lean_verify` / `#print axioms` on `nf_nvar_exist_all_depths`,
      `nf_characterizable_temporal_prior` (KampPrior:407), and `completeness_discrete` =
      `[propext, Classical.choice, Quot.sound]` with NO `sorryAx`. Any `sorryAx` is a FAIL.
- [ ] **Per-phase `lean_verify`**: each new supply theorem / arm rewrite at floor axioms, no new axiom.
- [ ] **Full-tree `lake build` GREEN** at the terminal phase (baseline: ~1752 jobs post-363/364).

## Artifacts & Outputs

- plans/05_realizer-recursion-v05.md (this file)
- summaries/05_realizer-recursion-v05-summary.md (on implementation completion)
- Lean edits (no new plan files): general-m supply theorems in `ExteriorPinnedConverse{K,PastK}.lean`
  routed through 364's byte-stable lemmas; `kampPrior_hreal_supply`/`kampPrior_hexcl_supply` in
  `KampPrior.lean` (or a new `Kamp/` leaf); the two arm rewrites replacing `:519` and `:522`.

## Rollback/Contingency

- **Per-phase green commits** (git-workflow.md mandate): each verified-green sub-step is committed as it
  lands (`task 358 phase P.O: {objective}`), so any failure rolls back to the last green milestone
  without losing landed supply theorems.
- **P2-0 re-probe gate fails** (`kvE_probe364_sigma2_inadmissible` does not verify, or a NEW plant
  survives the co-realization check): do NOT attempt G2 build-out. Set 358 [BLOCKED] with the
  minimal failing obligation shape, `/spawn 358` a 364-style interface follow-up; keep all green
  landings intact. Never force supply against a refuted binder.
- **A G2 supply σ proves non-realizer-derived and unservable** (P2-1 exception with no
  `nf_characteristic_satisfies` realizer): mark P2 [BLOCKED], record the σ construction site,
  `/spawn 358` an isolated realizer-supply task. NEVER unfold the guard to bypass the obligation.
- **A G2 or G1 supply obligation cannot close green against the 364 interface** (a residual
  countermodel survives, or a conjunct is FALSE-as-restated): mark the specific supply theorem's
  phase [BLOCKED], record the minimal failing obligation shape (machine probe, route R2),
  `/spawn 358` an isolated interface-refinement task, and keep all prior-phase green landings
  intact. NEVER land a sorry or a vacuous def to reach a build.
- **P6 `:522` arity-lift cannot close** under either route (i)/(ii): mark P6 [BLOCKED], spawn an isolated
  arity-lift task, leave S1 (`:519`) landed and committed. S1 retirement is itself a shippable
  milestone (nf_nvar_exist_all_depths sorryAx-free at the k>=2 depth arm; only the arity-lift arm
  remains).
- **Regression detected** (m=0 layer, refutation guard, k<=1 rungs, or 363/364 frozen declarations
  changed): revert the offending edit via targeted `git checkout` of that file to the last green
  commit (snapshot first per git-workflow.md), re-run the scoped build, and re-attempt within the
  phase territory only.
