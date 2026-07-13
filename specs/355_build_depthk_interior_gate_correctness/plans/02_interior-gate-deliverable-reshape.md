# Implementation Plan (v2): Task #355 — depth-k interior gate correctness (deliverable-shape reshape)

- **Task**: 355 - Build the depth-k INTERIOR gate correctness lemma for general k, by recursion
- **Status**: [COMPLETED] (all 8 phases GREEN and COMMITTED; re-frozen obligation-carrying DoD fully delivered: ∀-k `bracketEndChar_kv_correct_prior` assembled, axiom-clean, full-tree green, 13 frozen files byte-identical. The obligation-FREE ∀-k CLEAN close remains out of scope as channel-unprovable.)
- **Effort**: ~22 hours total (~19h already delivered across Phases 1-6; ~3h remaining across Phases 7-8)
- **Dependencies**: None (self-contained; all cited templates/clause-layer assets already committed and frozen)
- **Research Inputs**: specs/355_.../reports/01_rabinovich-faithfulness-and-deliverable-shape.md (NEW, adversarial H3+H4 — LOAD-BEARING); specs/349_.../reports/11_recent-completion-consumption.md; specs/349_.../reports/12_spawn-analysis.md; specs/349_.../.orchestrator-handoff.json; specs/349_.../plans/08_consume-depthk-clause-layer.md (Phase 5-7 RESUME POINT)
- **reports_integrated**: 01_rabinovich-faithfulness-and-deliverable-shape.md
- **Artifacts**: plans/02_interior-gate-deliverable-reshape.md (this file); plans/01_depthk-interior-gate-correctness.md (superseded v1); reports/01_rabinovich-faithfulness-and-deliverable-shape.md; summaries/01_depthk-interior-gate-correctness-summary.md
- **Standards**: plan-format.md; status-markers.md; artifact-management.md; tasks.md; lean4.md
- **Type**: lean4
- **Lean Intent**: false

## Overview

This is **plan v2** — a deliverable-shape reshape of plan v1, synthesizing the delivered green
implementation (Phases 1-5 + 6.1) with the new adversarial research report
`01_rabinovich-faithfulness-and-deliverable-shape.md`. The engineering is essentially done: the full
depth-`k` interior-gate proof engine is delivered GREEN and committed, culminating in the
obligation-carrying symbolic-`k+1` correctness biconditional `bracketEndChar_kv_step_correct`
(`InteriorGateGeneralK.lean:1165`), sorry-free, axioms exactly `[propext, Classical.choice,
Quot.sound]`, full-tree build passing, all 13 task-349 frozen files byte-identical.

Plan v1's Definition of Done aimed at the CLEAN, obligation-FREE ∀-`k` close
(`bracketEndChar_kv_correct_prior` against `InteriorGateTarget` = `BracketCarrierCorrectVPrior`). The
∀-`k` close hit a **legitimate `[BLOCKED]`** — but the block is a *deliverable-shape* issue, not a
proof failure. The adversarial research round (report 01) calibrated the picture and the DoD is now
**re-frozen** to the achievable, faithful, ALREADY-DELIVERED shape.

### What changed vs plan v1 (re-frozen Definition of Done)

1. **DoD re-frozen to the obligation-carrying deliverable.** The task-355 deliverable is the
   obligation-carrying `bracketEndChar_kv_step_correct` (`InteriorGateGeneralK.lean:1165`,
   symbolic-`k+1` correctness biconditional, DELIVERED GREEN) plus the base rungs
   `interiorGateTarget_zero` (`:89`) / `interiorGateTarget_one` (`:102`), and — newly IN-SCOPE — a
   ∀-`k` *obligation-carrying* wrapper assembled from them (Phase 7).
2. **The CLEAN obligation-FREE ∀-`k` close is REMOVED from scope** as *channel-unprovable* at
   `k ≥ 2` (report 01 §Q2; carrier only builds `P.existF 0`, never `existF 3`, witnessed sorry-free by
   `bracketEndChar_kv_factors`, `CarrierKv.lean:422`). Precise status: **channel-unprovable / carrier
   information-blind**, NOT "machine-checked false" — there is no landed counterexample theorem
   (report 01 tempers the earlier "F1-refuted" wording).
3. **Faithfulness CONFIRMED** (report 01 §Q1): the obligation-carrying reconstruction is faithful to
   Rabinovich 2014. `hreal`/`hexcl` are *within-bracket* moves (Cor 5.4 single-bracket `[x,t]`
   interior gate, bounded interior witness `(∃z)^{<z1}_{>z0}`); `hexclExt` is Lemma 7.6 *adjacency
   composition*, a genuine **NON-goal** of the interior gate belonging to the exterior-bracket layer.
4. **Consumer mismatch REFUTED the trivial fix** (report 01 §Q3): the actual task-349 consumer is the
   UNCONDITIONAL `EndIntervalCorrect` (`CarrierK1V.lean:2179`); there is **no `EndIntervalCorrectPrior`
   in the tree** (grep: 0 hits). Wiring the delivered lemma into task 349 requires re-freezing
   task-349's byte-frozen `CarrierK1V.lean` consumer contract and routing obligation discharge up to
   `KampPrior.lean:351` (itself an open `sorry` at general `k`). **That consumer-side reshape edits
   task-349 frozen files, which task 355 is FORBIDDEN to touch** — so it is cleanly re-scoped as a
   follow-up (see "Out-of-Task-355 Follow-Ups" below), NOT folded into task 355.

### The ∀-k obligation-carrying close IS in-scope (concrete determination)

Plan v1's Phase 6 blocked because it targeted the CLEAN target. The v2 in-scope path targets the
*obligation-carrying* ∀-`k` statement, which is provable additively with **no frozen-file edit and no
consumer change**. Concretely:

- The delivered step `bracketEndChar_kv_step_correct` proves the obligation-carrying biconditional at
  symbolic `k+1` **without consuming the arity-3 IH** — Phases 4 and 5 both realize interior content
  via the provider `P` (`interiorGate_hck` under `hcharK`, and `hreal`'s `P.existF 3` channel), NOT
  via the depth-`k` inductive hypothesis (see the Phase 4/5 deviation notes, delivered).
- Therefore the ∀-`k` obligation-carrying wrapper is a **case assembly** (`Nat.casesOn`/`Nat.rec`),
  not a genuine IH-threading induction: `k=0 → interiorGateTarget_zero`, `k=1 → interiorGateTarget_one`,
  `k=(n+1) → bracketEndChar_kv_step_correct`. The base rungs prove the CLEAN (stronger) statement, and
  CLEAN ⟹ obligation-carrying by weakening (discard the unused obligation binders), so they discharge
  the obligation-carrying base cleanly.
- The obligation binders (`P`, `hcharK`, `h_UZ`, `h_SZ`, `hreal`, `hexcl`, `hexclExt`) are level-`k`
  hypotheses uniformly quantified in the ∀-`k` motive; the wrapper is a *standalone* obligation-
  carrying deliverable (its obligations are handed-in hypotheses). **Discharging** those obligations
  for a real consumer is the out-of-scope task-349/exterior work — but *assembling* the ∀-`k`
  obligation-carrying lemma is well-typed and provable inside `InteriorGateGeneralK.lean`.

This is why an implement dispatch remains for task 355 (Phase 7 + Phase 8), rather than the task being
complete-on-delivery.

### Research Integration

- **Report 01 (NEW — adversarial, Tier 1 Rabinovich-grounded, H3+H4)** is the load-bearing input for
  this revision. Its verdicts, encoded above and throughout:
  - **Q1 (faithfulness): CONFIRMED** — division of labor (Cor 5.4 single bracket vs Lemma 7.6
    adjacency) verified against Rabinovich chunks `_0013`/`_0015`/`_0021`/`_0022`; `hexclExt` is a
    faithful encoding of the paper's seam, not a formalization artifact.
  - **Q2 (F1 obstruction): CONFIRMED, calibrated** — obligation-free target is channel-unprovable at
    `k ≥ 2` (machine-witnessed information-blindness via `bracketEndChar_kv_factors`); NOT a landed
    counterexample. Wording moved from "refuted" to "channel-unprovable / information-blind."
  - **Q3 (consumer acceptance): REFUTED as stated** — frozen `EndIntervalCorrect`
    (`CarrierK1V.lean:2179`) is unconditional; no `EndIntervalCorrectPrior` exists; two-sided reshape
    (task-349-scoped, touches frozen files) required and re-scoped as a follow-up.
  - **Q4: revise** — re-freeze the DoD to the delivered obligation-carrying engine; spawn the
    exterior `hexclExt` discharge separately.
- **Report 11 / Report 12 / Handoff JSON (from parent task 349)** — retained from plan v1: the
  depth-`k` clause/bracket layer (351/352/354) is the EXTERIOR residue; this task is the interior
  half. Axiom target and hole locations fixed there.

### Prior Plan Reference

Plan v1 (`plans/01_depthk-interior-gate-correctness.md`) is superseded but preserved for history. Its
Phases 1-5 + 6.1 delivered the entire interior-gate engine GREEN; v2 preserves every delivered asset
verbatim and only reshapes the DoD (Phase 6 ∀-`k` clean close) and adds the in-scope obligation-
carrying close (Phase 7).

### Roadmap Alignment

No ROADMAP.md consulted (roadmap flag not set). This task advances the parent task 349 recursion by
delivering its blocking interior lemma in its maximal provable (obligation-carrying) shape.

## Goals & Non-Goals

**Goals**:
- **Re-frozen DoD**: deliver the general-`k` interior gate correctness in its maximal provable,
  Rabinovich-faithful shape — the obligation-carrying `bracketEndChar_kv_step_correct` (symbolic
  `k+1`, DELIVERED GREEN) + base rungs `interiorGateTarget_zero`/`_one` (DELIVERED GREEN) + a ∀-`k`
  obligation-carrying wrapper `bracketEndChar_kv_correct_prior` assembling them (Phase 7, IN-SCOPE).
- All deliverables green, sorry-free, axiom-clean (`[propext, Classical.choice, Quot.sound]`), every
  task-349 frozen file byte-identical at every commit.
- Document the obligation-carrying consumability shape for the task-349 junction (Phase 8), and flag
  the two out-of-scope follow-ups for the orchestrator/user.

**Non-Goals** (unchanged from v1, plus the newly-clarified scope boundary):
- NOT the CLEAN obligation-FREE ∀-`k` close (`InteriorGateTarget` = `BracketCarrierCorrectVPrior`) —
  **REMOVED from scope**, channel-unprovable at `k ≥ 2` (report 01 §Q2; `bracketEndChar_kv_factors`).
- NOT the task-349 consumer reshape (`EndIntervalCorrect` → `EndIntervalCorrectPrior` + KampPrior
  obligation routing) — touches task-349 frozen files; **re-scoped as follow-up (i)** below.
- NOT the general-`k` `hexclExt` exterior-adjacency discharge (Rabinovich Lemma 7.6) — exterior-
  bracket-layer scope; **re-scoped as follow-up (ii)** below.
- NOT filling task 349's `endIntervalStep` body (`CarrierK1V.lean:2144`) — task 349 Phase 5's job.
- NOT editing CarrierKv.lean or CarrierK1V.lean; NOT re-deriving the 351/352/354 clause/bracket layer
  or the Rabinovich lemmas — cite and consume only.

## Out-of-Task-355 Follow-Ups (flagged for orchestrator/user — do NOT create here)

These are the residual pieces the reshape surfaces. Both are **out of interior-gate scope** and must
NOT be folded into task 355. Recommend `/spawn`-ing them with **parent task 349**:

1. **Consumer reshape (task-349 scope)** — `bracketEndChar_kv_step_correct` does not slot into the
   frozen unconditional `EndIntervalCorrect` (`CarrierK1V.lean:2179`). Replace it with an obligation-
   carrying `EndIntervalCorrectPrior` over `endInterval` whose `Nat.rec` step is
   `bracketEndChar_kv_step_correct` and whose base is `endInterval_zero_correct`
   (`CarrierK1V.lean:2199`), routing the obligation discharge up to the `KampPrior.lean` recursion
   (`nf_nvar_exist_all_depths`, KampPrior:330+) where the `ExistProviders` bundle + UZ/SZ live.
   **Touches task-349 byte-frozen `CarrierK1V.lean`** — confirm task-349 ownership; grep confirms
   `EndIntervalCorrect` is currently unconsumed, so no other consumer breaks.
2. **General-`k` `hexclExt` exterior-adjacency discharge (exterior-bracket-layer scope)** — an atomic
   `bracketEndChar_kv_hexclExt_discharge`: "an unmarked depth-`k` arity-4 sub is realized at no
   strictly-exterior `x1`", via Rabinovich Lemma 7.6 adjacent-bracket composition
   `(∃z1)^{<z2}_{>z0}(φ1 ∧ φ2)` across the shared endpoint. This is the exterior-bracket layer
   (tasks 348/351/352/354 family) and is what the open `sorry` at `KampPrior.lean:351` (general-`k+1`,
   n=1) consumes. Spawn only when the ∀-`k` Kamp close needs the general-`k` exterior mechanism.

**Do NOT create these tasks in this revision.** They are surfaced in `.orchestrator-handoff.json`
`followup_tasks` for the orchestrator/user to `/spawn`.

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| ∀-`k` obligation-carrying motive cannot uniformly quantify the per-`k` obligation binders (typing mismatch between the step's `k+1` shape and a uniform ∀-`k` motive) | H | L | Phase 7 first defines the uniform obligation bundle and validates the base+step fit BEFORE the wrapper proof; if the binders genuinely cannot be uniformly quantified without a frozen-file/consumer change, mark Phase 7 `[BLOCKED]` and re-scope it out too (documenting precisely why) — task 355 would then be complete-on-delivery with the delivered step + base rungs |
| Base rungs (proved against CLEAN target) do not weaken to the obligation-carrying base | M | L | CLEAN is strictly stronger (fewer hypotheses); weakening = discard unused obligation binders; validate by discharging the obligation-carrying `k=0`/`k=1` instances from `interiorGateTarget_zero`/`_one` before the wrapper |
| Accidental frozen-file edit | H | L | Per-phase acceptance criterion: `git diff` on all frozen paths EMPTY; land in the NEW module only |
| Forbidden `nf_char3_deeper_split` route creeps in | H | L | Per-phase grep audit; refuted route (report 02 §4.1) |
| Rabinovich chain step bypassed by simp/omega/aesop (G5) | M | L | Manual bridges only; per-phase G5 audit; literature-fidelity policy |
| New leaf module not built by full-tree `lake build` | M | L | Already wired and full-tree GREEN (summary: 1724 jobs); Phase 8 re-confirms |

## Implementation Phases

**Dependency Analysis** (Waves 1-6 = DELIVERED; Waves 7-8 remain):
| Wave | Phases | Blocked by | State |
|------|--------|------------|-------|
| 1 | 1 | -- | COMPLETED |
| 2 | 2, 3 | 1 | COMPLETED |
| 3 | 4 | 2, 3 | COMPLETED |
| 4 | 5 | 4 | COMPLETED |
| 5 | 6 | 4, 5 | COMPLETED (step biconditional; CLEAN ∀-k close removed from scope) |
| 6 | 7 | 6 | NOT STARTED (in-scope) |
| 7 | 8 | 7 | NOT STARTED |

Phases 7 and 8 are serialized (8 audits 7). Both append to the single new module
`InteriorGateGeneralK.lean`.

**Global per-phase acceptance criteria** (apply to EVERY phase; carried verbatim from task 349 — HARD
CONSTRAINTS, unchanged):
- **Additive only**: `git diff` MUST be EMPTY on all frozen paths — the seven providers
  (`SharedWitness.lean`, `SubBracket2V.lean`, `OuterGate.lean`, `ExteriorBracket.lean`,
  `ExteriorZoneTriage.lean`, `ExteriorNegation.lean`, `ExteriorNegationPast.lean`), plus
  `KampPrior.lean`, `ExteriorBracketK.lean`, and `PriorInterface.lean` (the
  `ExistProviders.existF`/`.correct` + `P.correct` interface). Also do NOT edit `CarrierKv.lean`,
  `CarrierK1V.lean`, or `ExteriorBracketAssembleK.lean` (all task-349-owned).
- **G1**: no arity-1 interior collapse (no `nfk_projFresh` in new proof code driving interior
  content; the carrier's own fiber-classification use of `nfk_projFresh` inside `bracketEndChar_kv`
  is the sanctioned Rabinovich bucketing per report 11 §5, not a violation).
- **G2/G4**: anchors strictly ⊆ {x,t}, at most 2; `w` never a third free anchor (it is bound
  `∃ w`); exterior `x1` and fiber witness `v` quantified, never free.
- **G3**: non-trivial segment only (reuse `seg`; never `TemporalPred.top`).
- **G5**: no simp/omega/aesop shortcut of a Rabinovich chain step — manual `rw`/`obtain`/`constructor`
  bridges only.
- **FORBIDDEN**: `nf_char3_deeper_split` (refuted route, report 02 §4.1) — grep clean.
- **Axioms**: `lean_verify` on every new lemma reports exactly `[propext, Classical.choice,
  Quot.sound]`; sorry-free (no `sorry`/`admit`), no vacuous `True`/`Unit`/`trivial` defs.
- **Scoped build**: `lake build Bimodal.Metalogic.WeakCanonical.Kamp.NfMultiAnchorBridge.InteriorGateGeneralK`
  GREEN at phase end.
- **BLOCKED-escalation contingency** (every phase): if a sub-piece cannot close green, do NOT land a
  `sorry` or vacuous/empty-disjunction placeholder for a lemma that is claimed proved. Mark the phase
  `[BLOCKED]`, capture the exact `lean_goal` at the stuck position, record what was tried, and
  escalate per the lean4 vacuous-definitions/escalation rule (return `status: partial`,
  `requires_user_review: true`, or `/spawn 355` for the specific missing sub-lemma). Commit any
  already-green sub-piece first.

---

### Phase 1: Statement freeze + module setup + base-rung reconciliation [COMPLETED]

**Goal**: Create the new module and freeze the general-`k` statement shape, reconciling the F1
factors-refutation with the provider-guarded shape the consumer expects. Statement compiles
sorry-free; k=0/k=1 instances discharge against the existing base lemmas.

**Delivered**:
- Created `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge/InteriorGateGeneralK.lean`
  (NEW), importing `CarrierKv`, `PriorInterface`, and the OuterGate template family (import-only).
- `InteriorGateTarget atomMap h_surj charF k := BracketCarrierCorrectVPrior atomMap (bracketEndChar_kv
  atomMap h_surj charF k)` — the frozen provider-guarded shape (F1-mandated).
- `interiorGateTarget_zero` (`:89`) / `interiorGateTarget_one` (`:102`): validate the freeze by
  discharging the k=0/k=1 instances against `bracketEndChar_kv_correct_zero_prior`/`_one_prior`
  (`PriorInterface.lean:80/95`). Freeze confirmed before any step proof.

**Note (v2 re-scope)**: `InteriorGateTarget` (the CLEAN obligation-free `BracketCarrierCorrectVPrior`)
remains the frozen *base-rung* validator, but it is **no longer the ∀-`k` DoD target** — the ∀-`k`
CLEAN close is removed from scope (channel-unprovable at `k ≥ 2`; see Overview). The base rungs are
retained and reused, now as the base cases of the obligation-carrying wrapper (Phase 7).

**Verification** (delivered): statement + base-rung reconciliation green; scoped build GREEN;
`lean_verify` axiom-clean; frozen diffs EMPTY.

---

### Phase 2: Depth-k provider / char-layer truth bridges [COMPLETED]

**Goal**: Generalize the k=2 char-formula truth bridges to depth `k`: the atom-layer bridge
`temporal_truth M atomMap u (charF k χ) ↔ nf_eval_nf M k 1 (fun _ => u) χ` under
`ExistProviders.correct` + `semantic_prior_UZ`/`SZ` and the `Fin 0` env collapse.

**Delivered**:
- `interiorGate_hck` — general-`k` analog of `bracketEndChar_kvE2_hck` (`OuterGate.lean:123`): from
  `P.correct` at n=0 + the `insertEnv`/`Fin.elim0` env collapse.
- `interiorGate_hcb` — depth-0-general char-base bridge (re-export of `bracketEndChar_kvE2_hcb`,
  fold-depth-independent).
- Confirmed these compose to the per-fiber point-type truth equivalence the step proof consumes.

**Verification** (delivered): both bridges green + sorry-free; `lean_verify` axiom-clean; scoped build
GREEN; frozen diffs EMPTY; G5 (manual).

---

### Phase 3: Body-destructuring `holds_iff` at depth k [COMPLETED]

**Goal**: Expose the successor carrier's `.holds` structurally as the conjunction of the off-fiber gate
and the per-fiber fold-bit disjunction, keeping the fold-bit read FIBER-EXISTENTIAL (per
`bracketEndChar_kv`'s definition at `CarrierKv.lean:248`); do NOT collapse to a pointwise read (that
collapse is only valid at k=1 and is exactly the information F1 says is lost at `k ≥ 2`).

**Delivered**:
- `bracketEndChar_kv_succ_holds_iff`: `(bracketEndChar_kv … (k+1) qnf).holds M atomMap x t` unfolds to
  the off-fiber gate conjunct ∧ the fiber-class disjunction of realized-marked subs. *(deviation: the
  public replica `igBody` is proved defeq to the frozen private `kv_body` via `simp only
  [bracketEndChar_kv]; rfl`; `igFoldBit` reproduces the frozen nested `Decidable` instance
  byte-for-byte. Delivered `igBody`/`igGate`/`igSL`/`igSR`/`igMkDisjunct` public pieces,
  `bracketEndChar_kv_succ_eq` defeq bridge, `igBody_holds_iff`, and the deliverable.)*
- `igFoldBit_iff` — fiber-witness extraction/introduction (kept existential), the general-`k`
  existential analog of `bracketEndChar_kv_one_eq`'s `hbit`.
- Confirmed the destructuring composes with Phase 2's point-type bridges.

**Verification** (delivered): `holds_iff` + fiber helpers green + sorry-free; `lean_verify`
axiom-clean; scoped build GREEN; frozen diffs EMPTY; G1 (sanctioned bucketing, not interior collapse).

---

### Phase 4: Inductive step — ⇐ completeness (realizer → carrier holds) [COMPLETED]

**Goal**: Prove the completeness half of the k→k+1 step (`bracketEndChar_kv_step_complete`): from a
depth-`(k+1)` realizer conclude the successor carrier `.holds`. This direction is NOT obstructed by F1
(a genuine realizer supplies the fiber content), so it landed first as a green milestone.

**Delivered** (all axiom-clean `[propext, Classical.choice, Quot.sound]`):
- `igZone3_consistent` — generic seven-zone order trichotomy over `[w,x,t]`.
- `bracketEndChar_kv_step_gate` (4a) — the honest gate from a genuine realizer.
- `igFoldBit_realize_iff` (4b) — the fold-realization biconditional, kept FIBER-EXISTENTIAL (F1
  channel preserved).
- `igk_sorted_realization` (4b) — general-`k` arrangement selection.
- `bracketEndChar_kv_step_complete` (4b main) — faithful depth-`k` transcription of the depth-1 engine
  `bracketEndChar_k1v_complete` (reused private helpers via `open private`).

**Design deviation (delivered)**: completeness realizes the arity-1 interior 1-types via the PROVIDER
(`interiorGate_hck` under `hcharK : charF k = fun χ => P.existF 0 χ`), NOT the arity-3 IH; carries
`(P : ExistProviders sig atomMap k)`, `hcharK`, UZ/SZ, mirroring the k=2 template
`bracketEndChar_kvE2_complete_two_prior`. **The IH is not consumed at the step** (load-bearing for the
Phase 7 in-scope determination).

**Verification** (delivered): scoped + full-tree `lake build` GREEN (1724 jobs); axiom-clean;
0 sorry/admit, 0 vacuous, 0 forbidden `nf_char3_deeper_split`; all 13 frozen files byte-identical.

---

### Phase 5: Inductive step — ⇒ soundness (carrier holds + provider obligations → realizer) [COMPLETED]

**Goal**: Prove the soundness half of the k→k+1 step (`bracketEndChar_kv_step_sound`): under
`semantic_prior_UZ`/`SZ` and the depth-`k` provider obligations, from the successor carrier `.holds`
conclude a depth-`(k+1)` realizer. **F1-critical direction**: the carrier's fold data is lossy
(`bracketEndChar_kv_factors`), so the realizer is reconstructed using the provider obligations, which
supply the exact fiber content F1 shows is not intrinsic.

**Delivered**: `bracketEndChar_kv_step_sound` green, sorry-free, axiom-clean `[propext,
Classical.choice, Quot.sound]`, all 13 frozen files byte-identical. Route:
`bracketEndChar_kv_succ_holds_iff.mp` → destructure gate + arrangement disjunct → (open private)
`k1v_bracket_extract` yields bracket witness `w` (`x<w<t`) + `igPtW` eval → endpoint/witness char
heads via `interiorGate_hcb` → (open private) `k1v_reconstruct_nf3` rebuilds the depth-0 atom layer →
per-sub fold biconditional (defeq via `nf_eval_nfk_iff_efold`'s internal `Iff.rfl`, `NfEFold.lean:643`)
= `hreal` forward, `hexcl`+`hexclExt` backward. The lossy fold BITS are never read (F1 channel intact).

It carries three named provider obligations `hreal`/`hexcl`/`hexclExt` (mirroring the k=2 template's
`hrealI`/`hrealB`/`hexcl`/`hexclExt`), with `hexclExt` threaded OUTWARD verbatim as the
task-348/351/352/354 exterior-bracket hand-off (Rabinovich Lemma 7.6 adjacency — a task-355 NON-goal).
**The arity-3 IH is not consumed** — interior content rides the named provider realization obligation
`hreal` (`P.existF 3`), exactly as the k=2 template `P`-realizes rather than IH-realizes.

**Faithfulness (report 01 §Q1, CONFIRMED)**: `hreal`/`hexcl` are within-`[x,t]` moves (Cor 5.4 bounded
interior witness `(∃z)^{<z1}_{>z0}`); `hexclExt` (`¬(x ≤ x1 ∧ x1 ≤ t)`) is Lemma 7.6 exterior
adjacency, genuinely out-of-class for one bracket (`(z0,z1)`-formulas not closed under negation,
chunk_0022:3). The binder is a faithful encoding of Rabinovich's seam.

**Verification** (delivered): `bracketEndChar_kv_step_sound` green + sorry-free; `lean_verify`
axiom-clean; scoped build GREEN; frozen diffs EMPTY; G1-G5 audit; FORBIDDEN grep clean.

---

### Phase 6: Step biconditional assembly (symbolic k+1) [COMPLETED]

**Goal**: Assemble the step biconditional `bracketEndChar_kv_step_correct` = ⟨sound (Phase 5),
complete (Phase 4)⟩ at symbolic `k+1`.

**Delivered**: `bracketEndChar_kv_step_correct` (`InteriorGateGeneralK.lean:1165`) — GREEN, axiom-clean
`[propext, Classical.choice, Quot.sound]`, obligation-carrying (`P`/`hcharK`/UZ/SZ +
`hreal`/`hexcl`/`hexclExt`), mirroring the k=2 assembly `bracketEndChar_kvE2_correct_two_prior_frag`
(`OuterGate.lean:359`). This is the **maximal green general-`k` interior-gate engine** and the primary
re-frozen task-355 deliverable.

**REMOVED FROM SCOPE (v2 decision — was the v1 Phase 6 `[BLOCKED]` item)**: the CLEAN obligation-FREE
∀-`k` close `bracketEndChar_kv_correct_prior` against `InteriorGateTarget` =
`BracketCarrierCorrectVPrior`. Report 01 §Q2 confirms this is **channel-unprovable at `k ≥ 2`**: the
carrier builds only `P.existF 0` literals, never invokes `P.existF 3`, so `.holds` + UZ/SZ alone has
no channel to the arity-4 fiber content the ⇒ direction needs (machine-witnessed by
`bracketEndChar_kv_factors`, `CarrierKv.lean:422`, sorry-free). Precise status: **channel-unprovable /
carrier information-blind**, NOT "machine-checked false" — no landed counterexample theorem exists
(report 01 tempers the earlier "F1-refuted" wording). Even at k=2 only the obligation-carrying
`_correct_two_prior_frag` exists; a clean `BracketCarrierCorrectVPrior` was NEVER delivered at
`k ≥ 2`. This is faithful to Rabinovich (report 01 §Q1): the clean target asks the carrier to encode
per-σ interior realizability with NO access to the adjacent context, which the paper never claims for
one bracket in isolation. The v1 BLOCKER's verbatim stuck `lean_goal` and full analysis are preserved
in `plans/01_depthk-interior-gate-correctness.md` (Phase 6 BLOCKER) and
`summaries/01_*-summary.md`.

**Verification** (delivered): `bracketEndChar_kv_step_correct` green + sorry-free; `lean_verify`
axiom-clean; scoped + full-tree build GREEN; frozen diffs EMPTY.

---

### Phase 7: ∀-k obligation-carrying recursion close [COMPLETED]

**Goal**: Assemble the ∀-`k` **obligation-carrying** correctness `bracketEndChar_kv_correct_prior`
(the general-`k` analog of the k=2 `_correct_two_prior_frag`) from the delivered step biconditional +
base rungs, by `Nat.casesOn`/`Nat.rec`. This is the maximal provable ∀-`k` interior-gate deliverable
and is IN-SCOPE (additive; no frozen-file edit; no consumer change) — see the "concrete determination"
in the Overview.

**Tasks**:
- [x] Define the uniform ∀-`k` obligation-carrying statement (working name
      `bracketEndChar_kv_correct_prior` / `InteriorGateStepPrior`) *(deviation: altered — the flat
      uniform signature hits the R1 typing tension (obligations reference `qnf.1`/`igFoldBit qnf`,
      successor-depth-only), so the well-typed realization is a `k`-cased motive `def InteriorGateAllK`:
      `k=0 → BracketCarrierCorrectVPrior` (clean), `k=n+1 → obligation-carrying biconditional`. No
      `True`/vacuous branch. Statement compiles sorry-free.)*: `∀ (k) (qnf : NormalForm sig k 3)
      (M) (x t) (six order bits) (P : ExistProviders sig atomMap k) (hcharK) (h_UZ) (h_SZ) (hreal)
      (hexcl) (hexclExt), (bracketEndChar_kv atomMap h_surj charF k qnf).holds M atomMap x t ↔
      ∃ w, nf_eval_nf M k 3 [w,x,t] qnf`. The obligation binders are the level-`k` obligations,
      uniformly quantified. Compile the statement sorry-free BEFORE the proof; docstring records that
      obligations are handed-in hypotheses (their discharge for a real consumer is the out-of-scope
      task-349/exterior work).
- [x] **Validate base fit**: the `k=0` motive branch IS `BracketCarrierCorrectVPrior atomMap
      (bracketEndChar_kv atomMap h_surj charF 0)`, discharged verbatim by `interiorGateTarget_zero`
      (defeq, no weakening needed). *(deviation: `k=1` is subsumed by the successor branch at `n=0`
      — the step `bracketEndChar_kv_step_correct` is fully general in its `{k}` — so
      `interiorGateTarget_one` is not special-cased.)*
- [x] **Assemble the wrapper**: `Nat.casesOn` on `k` — `k=0 → interiorGateTarget_zero`,
      `k=(n+1) → bracketEndChar_kv_step_correct` at `n`. Case assembly, not IH-threading.
- [x] Confirm the ∀-`k` obligation-carrying lemma is green + axiom-clean *(axioms exactly
      `[propext, Classical.choice, Quot.sound]`; scoped build GREEN 1020 jobs)*.

**BLOCKED contingency (specific to this phase)**: if the per-`k` obligation binders genuinely cannot
be uniformly quantified in a single ∀-`k` motive without a frozen-file/consumer change (e.g. a typing
mismatch between the step's `k+1` obligation shape and a uniform ∀-`k` motive that cannot be bridged
additively), mark this phase `[BLOCKED]`, capture the exact `lean_goal`, and **re-scope the ∀-`k`
close out of task 355 too** — documenting precisely why. In that (assessed-unlikely) case task 355 is
complete-on-delivery with the delivered step biconditional + base rungs, and the ∀-`k` close routes to
the follow-up consumer reshape. Never land a `sorry`/vacuous placeholder.

**Timing**: ~2 hours. **Estimated output**: ~50-150 lines.

**Depends on**: 6 (delivered).

**Files to modify**: `NfMultiAnchorBridge/InteriorGateGeneralK.lean` (additive).

**Verification**: `bracketEndChar_kv_correct_prior` (∀-`k` obligation-carrying) green + sorry-free;
obligation-carrying `k=0`/`k=1` reconciliation green; `lean_verify` axiom-clean on the top-level
lemma; scoped build GREEN; frozen diffs EMPTY. **BLOCKED-escalation** as global + the phase-specific
re-scope contingency above.

---

### Phase 8: Axiom audit + full-tree build + consumability check [COMPLETED]

**Goal**: Final gate. Confirm the re-frozen DoD deliverables meet acceptance and document the
obligation-carrying consumability shape for the task-349 junction.

**Tasks**:
- [x] `lean_verify` the deliverables (`bracketEndChar_kv_step_correct`, the ∀-`k`
      `bracketEndChar_kv_correct_prior`, base rungs `interiorGateTarget_zero`/`_one`): all report
      axioms EXACTLY `[propext, Classical.choice, Quot.sound]`; module `sorry`/`admit` = 0, vacuous
      defs = 0.
- [x] `git diff` on all 13 frozen paths — all EMPTY (byte-identical).
- [x] FORBIDDEN `nf_char3_deeper_split` grep clean; G1-G5 route audit recorded (interior content
      provider-realized, fold bit fiber-existential, anchors ⊆ {x,t}, no simp/omega/aesop chain
      shortcut in the additive wrapper — pure term-mode `Nat.casesOn`).
- [x] `lake build` (full-tree) GREEN — 1724 jobs.
- [x] **Consumability shape doc (NOT wiring)**: added the documented `example` +
      `## Phase 8 — consumability shape` doc-comment recording the seven-obligation interface
      (`P`, `hcharK`, `h_UZ`, `h_SZ`, `hreal`, `hexcl`, `hexclExt`) the task-349 junction must supply,
      and pointing at follow-ups (i) (`EndIntervalCorrectPrior` reshape) / (ii) (`hexclExt` discharge).
      No consumer wiring attempted (out of scope; touches frozen files).

**Timing**: ~1.5 hours. **Estimated output**: ~50-150 lines (audit + documented shape-match).

**Depends on**: 7.

**Files to modify**: `NfMultiAnchorBridge/InteriorGateGeneralK.lean` (additive example/audit).

**Verification**: axioms exactly `[propext, Classical.choice, Quot.sound]`; sorry-free; frozen diffs
EMPTY; FORBIDDEN grep clean; full-tree build GREEN; consumability shape documented. **BLOCKED-
escalation** as global.

## Testing & Validation

- [ ] `lake build Bimodal.Metalogic.WeakCanonical.Kamp.NfMultiAnchorBridge.InteriorGateGeneralK`
      GREEN at every phase end (scoped, authoritative gate for the new leaf module).
- [ ] `lake build` (full-tree) GREEN at Phase 8 (module already wired; delivered GREEN at 1724 jobs).
- [ ] `lean_verify` on `bracketEndChar_kv_step_correct` and the ∀-`k` `bracketEndChar_kv_correct_prior`
      reports EXACTLY `[propext, Classical.choice, Quot.sound]`.
- [ ] `grep -rn "sorry\|admit"` on the new module: 0 matches; no vacuous `True`/`Unit`/`trivial` defs.
- [ ] `git diff` on all frozen paths: EMPTY at every commit.
- [ ] `grep -rn "nf_char3_deeper_split"` on the new module: 0 matches (FORBIDDEN route).
- [ ] Guards G1-G5 audit passes on every new lemma.
- [ ] Consumability: a documented shape-match records the obligation-carrying interface the task-349
      junction must accept (and the two follow-ups it depends on).

## Artifacts & Outputs

- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge/InteriorGateGeneralK.lean`
  (DELIVERED + additive Phases 7-8): the frozen statement, provider/char bridges, `holds_iff`, the
  ⇐/⇒ step halves, the step biconditional `bracketEndChar_kv_step_correct` (primary deliverable), and
  — remaining — the ∀-`k` obligation-carrying `bracketEndChar_kv_correct_prior` + audit/consumability
  doc.
- `specs/355_.../plans/02_interior-gate-deliverable-reshape.md` (this plan, v2).
- `specs/355_.../plans/01_depthk-interior-gate-correctness.md` (v1, superseded; BLOCKER analysis
  preserved).
- `specs/355_.../reports/01_rabinovich-faithfulness-and-deliverable-shape.md` (load-bearing research).
- `specs/355_.../summaries/01_*-summary.md` (delivered work record).
- `specs/355_.../.orchestrator-handoff.json` (planned; overwritten by this revision).

## Rollback/Contingency

- Work is entirely additive in ONE new module. To revert, delete/blank `InteriorGateGeneralK.lean`;
  no frozen file is ever touched, so no other module is affected.
- If Phase 7 blocks (assessed unlikely): re-scope the ∀-`k` close out of task 355 (documenting why),
  leaving task 355 complete-on-delivery with the delivered step biconditional + base rungs; route the
  ∀-`k` close to the follow-up consumer reshape.
- If any phase blocks: mark it `[BLOCKED]`, capture the exact `lean_goal`, commit any already-green
  sub-piece (green-substep mandate), and escalate per the lean4 vacuous-definitions/escalation rule
  (`status: partial`, `requires_user_review: true`, or `/spawn 355` for the specific missing
  sub-lemma). Never land a `sorry`, a vacuous `True`/`Unit`/`trivial`, or an empty-disjunction
  placeholder in a lemma claimed proved.
- Because the deliverable is a leaf consumed only by task 349 (not yet wired), a block leaves the rest
  of the tree green; task 349 stays [BLOCKED] on 355 (and on the two follow-ups) exactly as it is now.
