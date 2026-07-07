# Implementation Plan: Redesign k=2 Sub-Bracket + Arity-4 Correctness Pair

- **Task**: 324 - redesign_k2_subbracket_arity4_correctness_pair
- **Status**: [NOT STARTED]
- **Effort**: 10-14 hours
- **Dependencies**: None (standalone; parent task 321 resumes via /revise 321 after completion)
- **Research Inputs**:
  - specs/324_redesign_k2_subbracket_arity4_correctness_pair/reports/01_adversarial-verification.md (H4-verified ground truth; OVERRIDES spawn analysis on conflict)
  - specs/321_implement_corrected_k2_carrier_and_close_the_correctness_gate_f4_resolution/reports/02_spawn-analysis.md (decomposition rationale)
  - specs/321_implement_corrected_k2_carrier_and_close_the_correctness_gate_f4_resolution/reports/01_blocker-research-successor-k.md Section 2 (Q1-Q3, binding amended design spec)
- **Artifacts**: plans/01_arity4-correctness-pair-plan.md (this file)
- **Standards**:
  - .claude/context/formats/plan-format.md
  - .claude/rules/artifact-formats.md
  - .claude/rules/state-management.md
  - .claude/rules/git-workflow.md
- **Type**: lean4

## Overview

Task 321's Phase 8 is machine-grounded BLOCKED: the landed `kvE_subBracket`/`kvE_subChain`
(NfMultiAnchorBridge.lean:5779/:5807) supply only a strictly-upward `Until` chain anchored at the
interior σ-witness slot `u`, which structurally cannot express a witness in `zXU = (x,v,u)` lying
*below* the anchor; and the sole connector `kvE_subBracket_implies_subChain` (:5824) runs
bracket-holds → chain-at-point (wrong direction for soundness). No arity-4 sub-bracket correctness
pair exists among landed assets (C3, machine-confirmed).

This task delivers, **standalone against `nf_eval_nf M 1 4` and NOT wired into the outer gate**:
(1) a corrected, additively-named sub-bracket construction (`kvE_subBracket2`/`kvE_subChain2`, exact
names at implementer discretion) whose chain(s) reach **all three** interior zones
`[zXU, zUW, zWT]` (`kvE_subInteriorZones` :5751), plus one machine-verified reachability lemma per
zone; (2) the soundness direction (holds → `∃ x1, nf_eval_nf M 1 4`); (3) the completeness
direction (reverse), the arity-4 analog of `bracketEndChar_k1v_sound` (:2338) / `_complete`
(:2979). Definition of done: both correctness lemmas compile **sorry-free**, are **axiom-clean**
(`propext`, `Classical.choice`, `Quot.sound` only), use no forbidden tactics, and the new chain's
reach of every interior zone is proven (not merely type-checked/probed).

**Critical divergence lesson (from adversarial verification Correction 1):** the defect is
**read-back geometry**, NOT a missing zone. `kvE_subInteriorZones` already lists `[zXU, zUW, zWT]`
and `kvE_subBracket` already emits `posSlots` for `zXU`. Do NOT "fix" by editing the zone list. The
fix must make a witness **below the anchor** expressible — the preferred remedy is
**anchor-at-`x`** (lift the landed k1v lower-endpoint bracket geometry — `bracketEndChar_k1v`
anchors over `(x,t)` at the lower endpoint `x`, so a single upward `fChainPred` reaches every
interior zone — one arity up), with **Since+Until pair** (Prop 3.5 two-sided translation) as the
pre-analysed fallback. The geometry choice MUST be validated by driving the correctness proof
through it (Phase 2 kill-switch), never accepted on type-check/probe grounds — this is exactly how
the original `kvE_subBracket` defect went undiscovered.

### Preserved Assets

The following landed work is COMPLETE and must remain byte-identical and unreferenced by new work
(do-not-edit list, verbatim from the task description):

| Component | File / Location | Status | Verified |
|-----------|-----------------|--------|----------|
| Task-321 Stage A construction (`kvE_subFoldBits`, `kvE_subInteriorZones`, `kvE_subBracket`, `kvE_subChain`, `kvE_subBracket_implies_subChain`) | NfMultiAnchorBridge.lean:5728-5835 | [COMPLETED] byte-identical | report 01 (2026-07-07) |
| Task-321 enriched body + carrier (`kvE2_body` + gate-fail, `bracketEndChar_kvE2`, `bracketEndChar_kvE2_two_eq`) | :5859 / :5957 / :5972 | [COMPLETED] byte-identical; do NOT re-point | report 01 |
| Task-321 Stage B discrimination (`kvE_subBracket_witnessCount`, `_ne_of_witnessCount_ne`) | :5999 / :6016 | [COMPLETED] byte-identical | report 01 |
| k1v correctness templates (`bracketEndChar_k1v_sound` / `_complete`) | :2338 / :2979 | [COMPLETED] structural reference; consume, do not rebuild | report 01 C4 |
| k1v helper kit | :2028-2825 | [COMPLETED] consume, do not rebuild | report 01 C4 |
| `BracketCarrierCorrectVPrior`, `ExistProviders`, task-310/311 material, task-320 probes | NfMultiAnchorBridge.lean | [COMPLETED] byte-identical | task description |

**Explicit exception (this task only, not a general license):** add NEW, separately-named
definitions; the originals stay byte-identical and unreferenced by the new work. Do NOT edit
`kvE2_body`/`bracketEndChar_kvE2` to re-point at the new construction — that re-pointing is task
321's own resumption work (a future /revise 321), out of scope here.

### Source-to-Implementation Mapping (Tier 1 literature + Tier 3 landed assets)

Every load-bearing chain step must cite Rabinovich per Guard G5. Literature source:
`~/Projects/Literature/sources/rabinovich_2014/Rabinovich_2014_Proof_of_Kamps_Theorem.pdf` (md
sibling for section reads).

| Load-bearing decision | Source (Tier 1 / Tier 3) | Consumed asset / citation |
|-----------------------|--------------------------|---------------------------|
| All-three-zones reachability requirement | Rabinovich Def 3.1 (md:61-74), Prop 3.5 (md:87-94) | `kvE_subInteriorZones` :5751 |
| Below-anchor witness needs Since half OR anchor-at-x | Prop 3.5 two-sided translation (md:87-94); Cor 5.4 (md:154-157) | k1v geometry :2338 (anchor at `x`) |
| Sub-level fold-bit read `σ.2 ∘ nf0_assemble` at j=0 | report 01 §2 Q2 (:90-155) | `nf0_assemble` (NfEFold.lean:180), `nf_eval_depth1_fold_iff` :5187 |
| Zone-bit routing (interior slots / point conjuncts / exterior Since-Until / segment exclusion) | Def 3.1 (md:61-74), Def 4.1 fold; report 01 §2 Q2 table (:110-116) | `bracketEndChar_k1v` routing :1940, `bracketFromLists` :1896 |
| Soundness read-back (chain-at-point → reconstruct nf_eval_nf) | k1v soundness template | `k1v_bracket_extract` :2150, `k1v_reconstruct_nf3` :2268, `bracket_implies_fChainPred` (EANegation:660), template :2338 |
| Completeness `IntervalPattern.holds` construction | Rabinovich Lemma 5.3 (md:137-152), Lemma 5.1 (md:134-135), Prop 4.2 (md:100-101) | `k1v_bracket_construct` :2838, template :2979, `existsBounded_right` (VecEAClosure:265) |
| Successor-parameterized read compatibility | report 01 §2 Q1 (:45-88) | carrier `BracketEndCharCarrierV sig (j+2)`, `two_eq` `rfl` bridge at j=0 |

### Research Integration

The plan integrates report 01 (adversarial verification, the H4-verified ground truth whose eight
Planning Constraints are binding and OVERRIDE the spawn analysis on any conflict) and report 01 §2
Q1-Q3 of task 321 (the binding amended design spec). The staged A/B/C/D structure from Q3
(:170-193) is mapped onto the eight phases below.

## Postmortem Constraints

Binding rules for all implementation dispatches. Derived from the machine-grounded blocker record,
adversarial verification, and the task description's binding constraints.

**Do NOT**:
- **Do NOT fix by editing the zone list.** `kvE_subInteriorZones` already lists all three zones;
  re-listing them reproduces nothing. The defect is read-back geometry — a witness *below* the
  anchor must become expressible (adversarial verification Correction 1).
- **Do NOT accept a type-checking / probe-clean construction as done.** The original
  `kvE_subBracket` type-checked and probed clean but had a latent soundness gap discovered only
  when the proof was driven. Validate the geometry by closing BOTH directions per zone with concrete
  reachability lemmas (Correction 2 / Constraint 5).
- **Do NOT edit any do-not-edit asset** (see Preserved Assets). Originals stay byte-identical and
  unreferenced. Add separately-named defs only.
- **Do NOT re-point `kvE2_body` / `bracketEndChar_kvE2`** at the new construction — that is task
  321's future /revise work, out of scope here.
- **Do NOT consume `EANegation.lean:1090` or `:1249`** — both are machine-confirmed live `sorry`s;
  consuming them imports proof debt onto this task's live path.
- **Do NOT use `simp` / `omega` / `aesop` on chain-construction steps.** `by omega` is permitted
  ONLY for `Fin`-index typing in signatures. Every chain step follows Cor 5.4 / Prop 3.5
  step-by-step with a Rabinovich citation (Guard G5).
- **Do NOT leave `sorry` on any live path, including intermediate WIP.** Keep unfinished work
  uncommitted until green.
- **Do NOT pin the provider (Amendment F3):** the provider disappears from the joint path; no
  `w = e 1` / `x = e 2` residual equation.
- **Do NOT collapse into the refuted flat shape:** every positional fact must ride a bracket witness
  slot / nested-Until chain, never a single-point relative-position assertion (F1-F4 litmus).

**MUST preserve**:
- All Preserved Assets byte-identical and unreferenced by new work.
- Existing scoped `lake build` green — the module must compile after every committed lemma.
- Guards G1-G6 + Corrected Anchor-Cap: anchor count ≤ 2, fixed endpoints `{x, t}`; carrier stays
  the two-anchor bracket characteristic (source: specs/309.../plans/07_offdiag-fi-chain-plan.md:230-260).
- Compatibility with the successor-parameterized read (report 01 §2 Q1-Q2): `j+1` layer,
  `σ.2 ∘ nf0_assemble` read fixed at gate instance `j=0`; `two_eq`-style `rfl` bridge preserved.

**Design decisions are SETTLED** (do not re-open without a concrete counterexample):
- **The defect is read-back geometry, not a missing zone** (Correction 1). Settled by machine read
  of `kvE_subChain` :5807 = upward-only `fChainPred`, anchored at `u` in `kvE2_body` :5919.
- **Two geometry options only: anchor-at-`x` (preferred) or Since+Until pair (fallback).** Both are
  literature-grounded (C6). The choice is decided by proof-driving, resolved at the Phase 2
  kill-switch, not re-litigated per phase.
- **New, separately-named additive definitions** — the byte-identical-originals constraint is not
  negotiable; there is no in-place edit path.
- **Completeness is a genuine, unbudgeted, proof-driven risk** (Correction 2 / Constraint 5),
  sized as multi-phase here — a single "prove the pair" phase is forbidden (repeats the plan-v1
  sizing error).

## Goals & Non-Goals

- **Goals**:
  - A corrected additive sub-bracket construction (`kvE_subBracket2`/`kvE_subChain2`) whose
    chain(s) reach all three interior zones `[zXU, zUW, zWT]`.
  - One machine-verified reachability lemma per interior zone (concrete evidence, not a probe).
  - A soundness lemma: `holds → ∃ x1, nf_eval_nf M 1 4 (Fin.cons x1 [w,x,t]) σ` (standalone; may
    assume an explicit outer gate-shaped hypothesis analogous to `kvE_gate`).
  - A completeness lemma: the reverse direction, standalone against `nf_eval_nf M 1 4`.
  - Both lemmas sorry-free, axiom-clean, no forbidden tactics, Rabinovich-cited at every chain step.
- **Non-Goals**:
  - Wiring the new construction into the outer gate (`kvE2_body`/`bracketEndChar_kvE2` re-point) —
    task 321's /revise work.
  - The depth-`j` fold-engine generalization — only the gate instance `j=0` (landed `nf0_assemble`)
    is in scope; the successor-parameterized header must stay *compatible*, not fully general.
  - Editing or re-deriving any Preserved Asset.
  - Resolving parent task 321 — that resumes after this task completes.

## Risks & Mitigations

**Risk register:**

- **R1 — Design-choice validation risk (HIGH, kill-switch gated).** The chosen read-back geometry
  (anchor-at-`x` vs Since+Until pair) may fail to make a below-anchor `zXU` witness expressible
  when the correctness proof is actually driven — the exact failure mode that hid in the original
  `kvE_subBracket`. *Mitigation:* Phase 2 is an explicit **kill-switch**: it proves one concrete
  reachability lemma per interior zone against the *chosen* geometry before ANY soundness/
  completeness work. If anchor-at-`x` fails to close the `zXU` reachability lemma, STOP and pivot to
  the Since+Until pair (build the `fChainFrom`-analog for the Since direction) within the same phase
  before proceeding. No downstream phase starts until all three reachability lemmas are green.
- **R2 — Unprobed completeness at k≥2 (HIGH, unbudgeted per Correction 2).** Report §2/Q3 (:164-168)
  flags that the reverse direction — `nf_eval_nf` inner witnesses ⇒ `IntervalPattern.holds` data
  (monotone enumeration, range/point/segment conditions, Lemma 5.3 style) — is genuinely unprobed
  at k≥2. Neither geometry option has been machine-driven through completeness. *Mitigation:*
  completeness is decomposed into three phases (5-7), phase-per-lemma with commit-per-green.
  Pre-authorized fallback (report §2, :188-193): if Phase 6 or 7 hits a genuine obstruction (not
  mere effort), land Phases 1-4 + the reachability lemmas as a *partial GO with recorded progress*
  and spawn the completeness direction as its own task — this is NOT an F-defect. Do not pre-spawn;
  the decision point is a Phase 6/7 blocker, if any. (No strategic `sorry` is placed: the
  no-sorry-on-live-path rule forbids it; the fallback is a task spawn, not a skeleton.)
- **R3 — Successor-parameterization drift (MEDIUM).** The new construction must remain compatible
  with the `j+1` layer and close `two_eq` by `rfl` at `j=0` (report §2 Q1). *Mitigation:* Phase 1
  includes a `two_eq`-style `rfl` compatibility check at `j=0` as an exit criterion; drift is caught
  before any proof work.
- **R4 — Accidental Preserved-Asset edit / forbidden-tactic slip (MEDIUM).** A single in-place edit
  or a `simp`/`omega`/`aesop` on a chain step voids the deliverable. *Mitigation:* every phase's
  verification includes a `git diff` byte-identical check on the do-not-edit ranges and a grep for
  forbidden tactics on new chain-construction blocks; Phase 8 re-runs both globally.
- **R5 — Axiom leakage (LOW).** A consumed lemma may drag a non-clean axiom. *Mitigation:*
  per-phase `lean_verify` axiom check on each new lemma; Phase 8 confirms the pair is axiom-clean
  (`propext`, `Classical.choice`, `Quot.sound` only).

## Implementation Phases

All new code is appended to `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge.lean`
(same module — `private` helpers are reachable per report §2 Q1 naming note). Suggested new names
(implementer discretion): `kvE_subBracket2`, `kvE_subChain2`, `kvE_subBracket2_reaches_zXU/_zUW/_zWT`,
`kvE_subBracket2_sound`, `kvE_subBracket2_complete`.

**Scoped verification command (per phase):** `lake build Theories.Bimodal.Metalogic.WeakCanonical.Kamp.NfMultiAnchorBridge`
(or the project's scoped-build target for this module), plus `lean_verify` on each phase's named
lemma, plus a forbidden-tactic grep and a do-not-edit `git diff` check.

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2 | 1 |
| 3 | 3, 5 | 2 |
| 4 | 4, 6 | 3 (for 4); 5 (for 6) |
| 5 | 7 | 6 |
| 6 | 8 | 4, 7 |

Phases within the same wave are logically independent (the soundness branch 3→4 and the
completeness branch 5→6→7 both root at the Phase 2 kill-switch and rejoin at Phase 8). **However,
all phases append to a single Lean file**; to avoid merge/territory conflicts under H7, dispatch
them serially (recommended order 1,2,3,4,5,6,7,8) OR enforce strict append-only, non-overlapping
line-range ownership if a parallel dispatch is attempted. The wave table documents the true
logical parallelism; sequential execution is the safe default.

### Phase 1: Corrected sub-bracket construction (`kvE_subBracket2`/`kvE_subChain2`) [COMPLETED]
- **Goal:** Add the additive, redesigned-geometry construction reaching all three interior zones,
  preferring anchor-at-`x` (lift the landed k1v lower-endpoint bracket geometry one arity up), with
  the successor-parameterized header compatible at `j=0`.
- **Tasks:**
  - [ ] Define `kvE_subBracket2 : ... → Σ m, BracketFormula (m+1)` with the zone-bit routing of
        report §2 Q2 (interior zones → extra bracket witness slots adjacent to the anchor;
        point-coincidence → point-type conjuncts; exterior → Since/Until literals in epL/epR;
        negative bits → segment exclusion conjuncts), anchored at the LOWER endpoint `x` so a single
        upward `fChainPred` reaches `zXU`, `zUW`, `zWT`. Cite Rabinovich Def 3.1 (md:61-74) / Def 4.1
        at each routed slot.
  - [ ] Define `kvE_subChain2 σ := (kvE_subBracket2 ... σ).2.fChainPred` (the `(m+1)` shape
        guarantees `fChainPred` availability, report §2 probe 6).
  - [ ] Provide the successor-parameterized header form (carrier `BracketEndCharCarrierV sig (j+2)`,
        each sub `σ : NormalForm sig (j+1) 4`), read via `σ.2 ∘ nf0_assemble` at gate instance `j=0`.
  - [ ] Confirm the `two_eq`-style `rfl` bridge holds at `j=0` (R3 compatibility check).
  - [ ] `git diff` confirm all Preserved-Asset ranges byte-identical.
- **Estimated output:** ~200-280 lines.
- **Done when:** `kvE_subBracket2`, `kvE_subChain2`, and the successor-parameterized header all
  elaborate with zero diagnostics; the `j=0` `two_eq` `rfl` check compiles; scoped `lake build`
  green; `git diff` shows no edits to do-not-edit ranges.
- **Verification:** `lake build` (scoped) green; `lean_verify` on `kvE_subBracket2`/`kvE_subChain2`;
  forbidden-tactic grep clean on new blocks; do-not-edit `git diff` clean.
- **Commit point:** `task 324 phase 1: corrected sub-bracket construction (kvE_subBracket2/kvE_subChain2)`
- **Depends on:** none

### Phase 2: Per-zone reachability kill-switch (`_reaches_zXU/_zUW/_zWT`) [NOT STARTED]
- **Goal:** Prove one concrete, machine-verified reachability lemma per interior zone against the
  chosen geometry — the mandatory design-validation gate (R1). This is a KILL-SWITCH: no downstream
  phase begins until all three are green.
- **Tasks:**
  - [ ] Prove `kvE_subBracket2_reaches_zXU`: the new chain expresses a witness in `zXU = (x,v,u)`
        BELOW the anchor (this is the exact obligation the original `kvE_subChain` could not meet).
  - [ ] Prove `kvE_subBracket2_reaches_zUW` and `_reaches_zWT` (above-anchor zones; expected to reuse
        the proven upward `fChainFrom` machinery unchanged if anchor-at-`x` was chosen).
  - [ ] Each lemma is a real proof (holds/reach statement), NOT a `#eval`/type-check probe. Cite
        Rabinovich Prop 3.5 (md:87-94) at each chain step.
  - [ ] **KILL-SWITCH:** if `_reaches_zXU` cannot close under anchor-at-`x`, STOP; pivot to the
        Since+Until pair (implement the `fChainFrom`-analog for the `Since` direction — `Formula.snce`
        already used at `kvE2_body` :5893), redo `kvE_subBracket2`/`kvE_subChain2` accordingly in
        Phase 1's block, and re-attempt all three reachability lemmas before proceeding.
- **Estimated output:** ~150-250 lines (or more if the Since+Until pivot fires).
- **Done when:** all three `_reaches_z*` lemmas compile sorry-free; scoped `lake build` green;
  `lean_verify` axiom-clean on each.
- **Verification:** `lake build` (scoped) green; `lean_verify` on the three lemmas; forbidden-tactic
  grep clean; do-not-edit `git diff` clean.
- **Commit point:** `task 324 phase 2: per-zone reachability lemmas (kill-switch passed)`
- **Depends on:** 1

### Phase 3: Soundness — atom-layer recovery + interior-fold ≤ per zone [NOT STARTED]
- **Goal:** Recover σ.1's full atom layer (order + predicate bits over the chain's evaluation
  points) from the new construction, and close the interior-fold `≤` direction for each of the
  now-reachable `zXU`, `zUW`, `zWT`.
- **Tasks:**
  - [ ] Atom-layer recovery channel: σ.1's order + predicate bits recoverable from `kvE_subChain2`
        holding, via `bracket_implies_fChainPred` (EANegation:660) instantiated at the *constructed*
        `kvE_subBracket2` (report §2 probe 6), plus `k1v_bracket_extract` (:2150).
  - [ ] Interior-fold `≤` per zone: for each `zXU`, `zUW`, `zWT`, the positive fold bit is realized
        by the reachability evidence from Phase 2. Cite Cor 5.4 (md:154-157) step-by-step.
  - [ ] No `simp`/`omega`/`aesop` on chain steps (`by omega` only for `Fin`-index typing).
- **Estimated output:** ~200-300 lines.
- **Done when:** the atom-layer recovery lemma and the three interior-fold `≤` lemmas compile
  sorry-free; scoped `lake build` green.
- **Verification:** `lake build` (scoped) green; `lean_verify` on each new lemma; forbidden-tactic
  grep clean; do-not-edit `git diff` clean.
- **Commit point:** `task 324 phase 3: soundness atom-layer recovery + interior-fold`
- **Depends on:** 2

### Phase 4: Soundness — off-fiber falsity + assemble `kvE_subBracket2_sound` [NOT STARTED]
- **Goal:** Handle off-fiber falsity via an explicit gate-shaped hypothesis and assemble the full
  standalone soundness lemma.
- **Tasks:**
  - [ ] State the explicit outer gate-shaped hypothesis (analogous to `kvE_gate`) as a hypothesis of
        this lemma — NOT wired to the real outer gate.
  - [ ] Close off-fiber falsity: points off the honest fiber falsify the carrier under that
        hypothesis.
  - [ ] Assemble `kvE_subBracket2_sound : holds → ∃ x1, nf_eval_nf M 1 4 (Fin.cons x1 [w,x,t]) σ`,
        reusing the :2338 template shape (`k1v_bracket_extract` :2150 + `k1v_reconstruct_nf3` :2268
        one arity up). Cite Rabinovich per chain step.
  - [ ] Amendment F3 check: no provider-side pinning; provider absent from the joint path.
- **Estimated output:** ~200-320 lines.
- **Done when:** `kvE_subBracket2_sound` compiles sorry-free standalone; scoped `lake build` green;
  `lean_verify` axiom-clean.
- **Verification:** `lake build` (scoped) green; `lean_verify` on `kvE_subBracket2_sound`;
  forbidden-tactic grep clean; do-not-edit `git diff` clean; F3 residual-equation grep clean.
- **Commit point:** `task 324 phase 4: soundness lemma kvE_subBracket2_sound closed`
- **Depends on:** 3

### Phase 5: Completeness — fold extraction of inner witnesses [NOT STARTED]
- **Goal:** Fold `nf_eval_depth1_fold_iff` (:5187) at `n=4` to extract σ's inner witnesses per zone
  from an honest `nf_eval_nf M 1 4` realization — the raw material for the reverse direction.
- **Tasks:**
  - [ ] Apply `nf_eval_depth1_fold_iff` (:5187) at `n=4` to decompose the honest realization into
        per-zone inner witnesses (`nf0_assemble` NfEFold.lean:180; `nf_quant_layer_fold_iff`
        NfEFold:391). Cite Rabinovich Def 4.1 / Prop 4.2 (md:100-101).
  - [ ] Extract the monotone witness enumeration data needed by Phase 6.
  - [ ] No `simp`/`omega`/`aesop` on chain steps.
- **Estimated output:** ~180-280 lines.
- **Done when:** the fold-extraction lemma(s) compile sorry-free; scoped `lake build` green.
- **Verification:** `lake build` (scoped) green; `lean_verify` on each new lemma; forbidden-tactic
  grep clean; do-not-edit `git diff` clean.
- **Commit point:** `task 324 phase 5: completeness fold-extraction of inner witnesses`
- **Depends on:** 2

### Phase 6: Completeness — `IntervalPattern.holds` construction (Rabinovich Lemma 5.3) [NOT STARTED]
- **Goal:** Build the `IntervalPattern.holds` data (monotone enumeration, range/point/segment
  conditions) from the extracted inner witnesses — the novel, highest-risk order-theoretic work
  (R2).
- **Tasks:**
  - [ ] Construct `IntervalPattern.holds` witnesses in the Lemma 5.3 (md:137-152) order-theoretic
        style: monotone enumeration, range condition, point condition, segment condition. Cite
        Lemma 5.1 (md:134-135) and Lemma 5.3 per condition.
  - [ ] Use `k1v_bracket_construct` (:2838) one arity up and `existsBounded_right`
        (VecEAClosure:265) as the construction primitives (consume, do not rebuild).
  - [ ] **R2 decision point:** if a genuine obstruction (not mere effort) blocks the construction,
        do NOT place a `sorry`; STOP and invoke the pre-authorized fallback (land Phases 1-4 as a
        partial-GO deliverable and spawn completeness as its own task — see Rollback/Contingency).
- **Estimated output:** ~250-350 lines.
- **Done when:** the `IntervalPattern.holds` construction lemma(s) compile sorry-free; scoped
  `lake build` green.
- **Verification:** `lake build` (scoped) green; `lean_verify` on each new lemma; forbidden-tactic
  grep clean; do-not-edit `git diff` clean.
- **Commit point:** `task 324 phase 6: completeness IntervalPattern.holds construction`
- **Depends on:** 5

### Phase 7: Completeness — arrangement-disjunct closure + assemble `kvE_subBracket2_complete` [NOT STARTED]
- **Goal:** Close the arrangement-disjunct (the k1v :2979 template re-derived at arity 4) and
  assemble the full standalone completeness lemma.
- **Tasks:**
  - [ ] Re-derive the arrangement-disjunct closure at arity 4 following the `bracketEndChar_k1v_complete`
        (:2979) template pattern, using the Phase 6 `IntervalPattern.holds` data.
  - [ ] Assemble `kvE_subBracket2_complete : (∃ w, nf_eval_nf M 1 4 ...) → holds`, standalone against
        `nf_eval_nf M 1 4`. Cite Rabinovich per chain step (Cor 5.4 / Prop 3.5).
  - [ ] Confirm the pair `(kvE_subBracket2_sound, kvE_subBracket2_complete)` is the arity-4 analog of
        `(bracketEndChar_k1v_sound, bracketEndChar_k1v_complete)`.
- **Estimated output:** ~250-350 lines.
- **Done when:** `kvE_subBracket2_complete` compiles sorry-free standalone; scoped `lake build`
  green; `lean_verify` axiom-clean.
- **Verification:** `lake build` (scoped) green; `lean_verify` on `kvE_subBracket2_complete`;
  forbidden-tactic grep clean; do-not-edit `git diff` clean.
- **Commit point:** `task 324 phase 7: completeness lemma kvE_subBracket2_complete closed`
- **Depends on:** 6

### Phase 8: Final verification + correctness-pair packaging [NOT STARTED]
- **Goal:** Confirm the full correctness pair is sorry-free, axiom-clean, forbidden-tactic-free, and
  the do-not-edit invariant held throughout.
- **Tasks:**
  - [ ] Full scoped `lake build` green from a clean state.
  - [ ] `lean_verify` on both `kvE_subBracket2_sound` and `kvE_subBracket2_complete`: axioms ⊆
        `{propext, Classical.choice, Quot.sound}`.
  - [ ] `grep`-confirm zero `sorry` on the new live path (including no WIP `sorry`).
  - [ ] Forbidden-tactic grep over ALL new chain-construction blocks (`simp`/`omega`/`aesop`; allow
        `by omega` only in `Fin`-index typing positions).
  - [ ] `git diff` over all Preserved-Asset ranges: byte-identical, unreferenced by new work.
  - [ ] Confirm the three `_reaches_z*` lemmas are concrete proofs (not probes) and reach all three
        interior zones.
- **Estimated output:** ~30-60 lines (mostly a packaging/doc-comment lemma bundling the pair; no new
  proof obligations).
- **Done when:** all checks pass; the deliverable is a green, axiom-clean arity-4 correctness pair.
- **Verification:** as listed in Tasks.
- **Commit point:** `task 324: complete implementation (arity-4 sub-bracket correctness pair)`
- **Depends on:** 4, 7

## Testing & Validation

- [ ] Scoped `lake build` green after EACH committed phase (never commit a red or sorry-carrying state).
- [ ] `lean_verify` axiom check on every new lemma: axioms ⊆ `{propext, Classical.choice, Quot.sound}`.
- [ ] Three per-zone reachability lemmas are concrete proofs reaching `zXU` (below anchor), `zUW`,
      `zWT` — machine-verified, not type-check/probe-only.
- [ ] Soundness lemma `holds → ∃ x1, nf_eval_nf M 1 4` closes standalone, sorry-free.
- [ ] Completeness lemma (reverse) closes standalone, sorry-free.
- [ ] Forbidden-tactic grep clean on all new chain-construction blocks (no `simp`/`omega`/`aesop`;
      `by omega` only for `Fin`-index typing).
- [ ] Amendment F3: no provider-side pinning / residual `w = e 1` / `x = e 2` equation.
- [ ] `git diff` confirms all Preserved-Asset ranges byte-identical and unreferenced by new work.
- [ ] `two_eq`-style `rfl` bridge preserved at `j=0` (successor-parameterization compatibility).

## Artifacts & Outputs

- plans/01_arity4-correctness-pair-plan.md (this file)
- New additive definitions and lemmas appended to
  `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge.lean`:
  `kvE_subBracket2`, `kvE_subChain2`, `kvE_subBracket2_reaches_zXU/_zUW/_zWT`,
  `kvE_subBracket2_sound`, `kvE_subBracket2_complete` (names at implementer discretion).
- summaries/NN_arity4-correctness-pair-summary.md (on completion)

## Rollback/Contingency

- **Per-phase rollback:** each phase commits only when green (scoped build + axiom-clean + no sorry).
  A failed phase leaves the prior green commit intact; nothing partial is committed. If a build goes
  red mid-phase, fix forward (correct the source) — never discard uncommitted changes to reach a
  passing build. If a rollback is genuinely required, run `bash .claude/scripts/git-snapshot.sh`
  first (per git-workflow.md "No Destructive Git on Uncommitted Work").
- **Phase 2 kill-switch (R1):** if anchor-at-`x` fails the `zXU` reachability lemma, pivot to the
  Since+Until pair within Phase 2 (rebuild the Phase 1 block). Do not proceed to soundness/
  completeness until all three reachability lemmas are green.
- **Phase 6/7 completeness fallback (R2, pre-authorized by report §2 :188-193):** if the
  `IntervalPattern.holds` construction or arrangement-disjunct closure hits a GENUINE obstruction
  (not mere effort), do NOT place a strategic `sorry` (the no-sorry-on-live-path rule forbids it).
  Instead: keep Phases 1-4 + the reachability lemmas as the committed deliverable (a *partial GO with
  recorded progress*, NOT an F-defect), record the obstruction, and spawn the completeness direction
  as its own task via `/spawn 324`. Do not pre-spawn — the decision point is a Phase 6/7 blocker only.
- **After completion:** resume parent task 321 via `/revise 321` (fold this task's delivered
  construction + correctness pair into a v4 phase decomposition that re-points 321's Phase 8 and
  Phases 9-15 at it), then `/implement 321`.
