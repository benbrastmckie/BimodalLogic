# Implementation Plan v2: Faithful slice repair — slice-keyed bracket + exterior-slice identification converse (m=0)

- **Task**: 360 - restate_exterior_hbr_pinned_converse
- **Status**: [IN PROGRESS]
- **Effort**: 22 hours total (9 phases; ~8h landed in Phases 0-2 + Phase-3 salvage, ~14h remaining across 6 open phases, each one agent run)
- **Dependencies**: None (this task unblocks 358 Phase 3 `:361` and 349 v8 Phase 6)
- **Research Inputs**:
  - specs/360_restate_exterior_hbr_pinned_converse/reports/02_faithful-pinned-converse-repair.md (PRIMARY — §2 unsatisfiability finding, §3.3 exact restated signatures, §3.4 interface consequence, §5 m=0 consumption route, §6 H3 table, §7 probes P1-P3, §8 revision deltas)
  - specs/360_restate_exterior_hbr_pinned_converse/handoffs/phase-3-handoff-20260713T190000Z.md (Phase-3 defect record)
  - specs/358_realization_recursion_nf_nvar_exist_all_depths/reports/03_pinned-converse-adjudication.md (§2.3-2.4 SUPERSEDED by report 02 §3.3; §3.2 shrink direction confirmed; §4-5 consumption route still authoritative)
  - specs/360_restate_exterior_hbr_pinned_converse/reports/01_spawn-pointer.md
- **Artifacts**: plans/02_faithful-slice-repair.md (this file; supersedes plans/01_restate-hbr-pinned-converse.md)
- **Standards**: plan-format.md; status-markers.md; artifact-formats.md; state-management.md; lean4.md (literature fidelity, vacuous-def prohibition)
- **Type**: lean4 (hard mode, --lit; ground truth = Rabinovich 2014, `~/Projects/Literature/sources/rabinovich_2014/` chunks 0013-0016, 0021-0023)

## Overview

**Why v2 exists.** Plan v1's Phase 3 target — the report-03 §2.4 full-σ pinned converse
`kvE_futPinned_of_end_zero` — was MACHINE-REFUTED (GREEN theorem
`kvE_futPinned_of_end_zero_refuted`, ExteriorPinnedConverseK.lean:498-617, axioms exactly
`[propext, Classical.choice, Quot.sound]`): the §2.4 hypothesis set reads `σ.2` exclusively
through the three EXTERIOR zone lists, so an interior-marking erasure σ′ passes every hypothesis
while failing pinned realization. Report 02 then proved the deeper structural fact: **per-σ
clause keying is dead** — the honest bracket `kvE_extBracketFut P qnf` conjoins `kvE_futPos P τ`
AND its negation (the machine-proven `hPosEq` step: `kvE_futPos P σ′ = kvE_futPos P τ` as
formulas, with `qnf.2 τ = true`, `qnf.2 σ′ = false`, both admissible), so the bracket is
UNSATISFIABLE for every honest qnf. No binder repair can rescue it: v1 Phase-1's guarded
`hbrFutSat` shape is itself refuted by the same (σ′, e) witness, and two of v1 Phase-5's four
`kvE_hbr*_supply_zero` targets are provably false. Rabinovich adjudication (report 02 §1)
confirms the machine: his Cor 5.4 brackets speak only about the segment `(z0,z)`; negation is
applied per SEGMENT bracket (Lemma 5.1/7.8), never per full type; Def 7.13 keeps a clause's
negation footprint equal to its content footprint. The per-σ keying is THE divergence.

**What v2 does.** Encode the faithful repair (report 02 §3.3, Def 7.13 footprint discipline):
(a) re-key the bracket's per-σ if-then-else from `qnf.2 σ` to `kvE_futSliceMarked qnf σ` ("some
admissible slice-mate of σ is qnf-marked", where slice = atom layer + three exterior zone
lists); (b) replace the refuted converse with the exterior-slice identification theorem
`kvE_futSliceId_of_end_zero` (the honest endpoint characteristic σ★ is qnf-marked,
pinned-realized at `[x1,w,x,t]`, atom-layer- and exterior-zone-equal to σ — full signature in
report 02 §3.3) plus the reconstruction companion `kvE_futSliceUnique_zero` (via
`nf_eval_unique`); (c) ELIMINATE the four `hbr*` obligations from the D3/D4 → gate →
`EndIntervalCorrectPrior` → KampPrior chain, replacing them at general k by ONE true-shaped
slice-honesty obligation per side (`hsliceFut`/`hslicePast`, report 02 §3.4), discharged at
m=0 in Phase 5 — which fully closes task 358's `:361` exterior needs (report 02 §5). Every
statement of the repair is H4-checked against the σ′ witness (report 02 §7: none refuted).

**Definition of done**: probes P1-P3 adjudicated GREEN (Phase 0b hard gate); slice defs +
slice-constancy + `kvE_futSliceId_of_end_zero` + `kvE_futSliceUnique_zero` sorry-free; brackets
re-keyed with D1/D3/D4 and all downstream consumers green and `hreal`/`hsat`/`hbr*` binders
removed from the consumption chain; Past mirror landed; `hsliceFut`/`hslicePast` discharged at
m=0; zero sorries, zero vacuous defs in every touched file; full `lake build` green; audit flag
for the frozen k=2 layer + task-349 interface note recorded in the handoff. If any P1-P3 probe
fails, the terminus is **[BLOCKED] + escalation handoff**, not construction.

### Research Integration

- Report 02 (faithful pinned-converse repair) — integrated fully; this plan's open phases are
  its §8 revision deltas operationalized. It supersedes report-03 §2.3 item 3 / §2.4 (refuted)
  and re-opens v1 "settled decision 4" (interface stays obligation-carrying) per the plan's own
  re-open rule: the refutation + `hPosEq` chain is the required concrete machine counterexample.
- Report 03 (task 358) — §4-5 consumption route and probe conventions remain integrated; §2.4
  signature no longer a target.

### What survives from v1 (phase-level accounting)

| v1 phase | Verdict in v2 | Detail |
|----------|---------------|--------|
| Phase 0 (probe gate C3/C8) | SURVIVES [COMPLETED] | ExteriorPinnedProbeK.lean green; probe lemmas (b)/(c)/(c′) are direct suppliers for the slice-id route (steps 1, 3, 4). C8's gap: interior marking never probed — repaired by the new P1-P3 gate (Phase 0b). |
| Phase 1 (guarded restatement, 5 levels) | SURVIVES [COMPLETED], **partially superseded by Phase 3b** | The committed re-threading stays green at HEAD and is the structural substrate 3b edits: destructor facts now bound (`hgap`/`hocc` — exactly the slice-id inputs), antecedent order fixed, ambient threaded at the ∀-w levels. Phase 3b REMOVES the four guarded `hbr*` binders themselves (the guarded `hbrFutSat`/`hbrPastSat` shapes are refuted by (σ′,e); `hbr*Real` unrefuted but eliminated) and replaces them with `hslice*`. The restated `kvE_extNeg*_complete` converter lemmas may remain as general-k tooling (report 02 §8 delta 2). |
| Phase 2 (atom-layer pinning) | SURVIVES [COMPLETED] | `kvE_futAtomPinned_zero` + 3 helpers reused verbatim as slice-id steps 2 and 5. |
| Phase 3 (full-σ converse) | RESTARTED (revised content) | Target refuted. GREEN salvage preserved: refutation theorem, 4 `*_of_realizer` supply lemmas, 3 invariance lemmas (see Preserved Assets). |
| Phase 4 (Past mirror) | RESTARTED (revised content) | Now mirrors the slice-id theorems, not the refuted converse. |
| Phase 5 (four `hbr*` supply theorems) | RESTARTED (revised content) | Old targets ELIMINATED — `kvE_hbrFutSat_supply_zero`/`kvE_hbrPastSat_supply_zero` are provably false (σ′ witness); new targets are the m=0 discharges of `hsliceFut`/`hslicePast`. |
| Phase 6 (zero-debt gate) | RESTARTED | Same shape, updated checklist + audit/consumer flags. |

### Preserved Assets

All rows are GREEN at HEAD `be5086f6b` and must not regress. "Re-keyed/edited (3b)" means Phase
3b deliberately changes the statement; the theorem must remain sorry-free.

| Component | File | Status | Constraint | Reused by slice route |
|-----------|------|--------|-----------|----------------------|
| `kvE_futPinned_of_end_zero_refuted` | ExteriorPinnedConverseK.lean:498-617 | GREEN | read-only (regression guard) | H4 sanity witness σ′ for every new statement (report 02 §7) |
| 4 realizer→antecedent supply lemmas `kvE_futPos/GapD/End/Occ_of_realizer` (general k) | ExteriorPinnedConverseK.lean | GREEN | read-only | Phase 3b D1 slice-level exclusion; Phase 5 slice-marked positive case (report 02 §5 row 1) |
| 3 invariance lemmas `kvE_subBit_mono`, `kvE_futAdmissible_of_subMarking`, `kvE_fiberZoneList_congr` | ExteriorPinnedConverseK.lean:379-476 | GREEN | read-only | Engine of the clause slice-constancy lemma (Phase 3 task 2; report 02 C10) |
| Phase-2 atom pinning `kvE_futAtomPinned_zero` + `kvE_futSelfZone_coincide`, `kvE_futFreshPinned_of_end`, `kvE_futAdmissible_zoneMark` | ExteriorPinnedConverseK.lean:125-209 | GREEN | read-only | Slice-id steps 2 (atom layer) and 5 (self-zone) |
| Phase-0 probe lemmas (`kvE_probe_endpoint_totality`, `kvE_probe_gapItem_pinned`, `kvE_probe_rayItem_pinned`, `kvE_probe_marking_separated`, `kvE_probe_selfZone_coincide`, `kvE_probe_c3_pair`) | ExteriorPinnedProbeK.lean | GREEN | append-only (Phase 0b adds P1-P3 artifacts) | Slice-id steps 1, 3, 4 mechanisms |
| Phase-1 restated chain (converters, D3/D4, gate, `EndIntervalCorrectPrior`, KampPrior :845-876 mirror) | ExteriorConverter{,Past}K, ExteriorBracketAssembleK, ExteriorGateAssembleK, EndIntervalConsumerK, KampPrior.lean:838-876 | GREEN | re-keyed/edited (3b) | Substrate: destructor-fact binding + ambient threading survive; `hbr*` binders removed |
| `kvE_futChainDestructG` (pinned walk destructor) | ExteriorNegationK.lean:293-331 | GREEN | read-only | Slice-id inputs `hend`/`hgap`/`hocc` |
| Depth-k clause family (`kvE_futPos`/`End`/`GapD`/`ItemShift`/`extNegFut` + correctness) + zone semantics | ExteriorNegationK.lean:333-470 | GREEN | read-only | Clause formulas are slice-only — the fact the whole repair rests on |
| Past mirrors of clause family/destructor | ExteriorNegationPastK.lean | GREEN | read-only | Phase 4 |
| `kvE_futBundle_of_realizer` / Past mirror | ExteriorConverterK.lean:208-225 / ExteriorConverterPastK.lean:174- | GREEN | read-only | Phase 5 content conversion where needed |
| Phase-2 realizer engine `kampPrior_fChain_realize*` (task 358 P2) | KampPrior.lean:1149ff | GREEN | read-only | out of scope; 358 consumes |
| `nf_characteristic` / `_satisfies` / `nf_eval_unique` | Metalogic/WeakCanonical/NormalForm.lean:215/224/245 | GREEN | read-only (small NEW helper lemmas may be appended; existing decls untouched) | σ★ construction (step 1), uniqueness (steps 2-5, `kvE_futSliceUnique_zero`) |
| `nf_eval_nf0_cons_factor` | Metalogic/WeakCanonical/NormalForm.lean | GREEN | read-only | free-env→pinned upgrade (steps 3-4); P3 transfer probe |
| Free-env countermodel probe | ExteriorFiberProbeK.lean | GREEN | read-only | probe model conventions |
| `HasAttainedINF.first_occ` | EANegationClosure.lean:54-66 | GREEN | read-only | — |

## Postmortem Constraints

Binding for all implementation dispatches. Carries v1's rules forward with the Phase-3
refutation lessons added.

**Do NOT**:
- Re-attempt the full-σ pinned converse (report-03 §2.4 shape) in ANY guise, including with
  strengthened antecedents. Machine-refuted (`kvE_futPinned_of_end_zero_refuted`); the paper
  confirms the conclusion must be exterior-slice only (report 02 §1). SETTLED.
- Keep or reintroduce per-σ clause keying (`qnf.2 σ` deciding a clause whose formula is
  slice-only). The honest bracket is unsatisfiable under it (report 02 §2, `hPosEq` chain).
  SETTLED — this supersedes v1 settled decision 4, re-opened by that machine counterexample.
- Attempt an interior-marking supplier antecedent (v1 repair candidate (b)). Unfaithful (no
  Rabinovich counterpart — Def 7.13 keeps interior content in OTHER conjuncts) and unavailable
  (no in-tree discharge site); and it inherits the unsatisfiability kill. SETTLED (report 02 §3.2).
- Prove any of the four v1 `kvE_hbr*_supply_zero` theorems. The two Sat-halves are provably
  FALSE (the (σ′, e) witness satisfies every guard antecedent verbatim); the Real halves are
  eliminated with the interface. Phase 5's targets are the `hslice*` discharges ONLY.
- Start Phase 3 construction before Phase 0b's P1-P3 probes are GREEN. C4/C8/C9 are
  Medium-confidence, not machine-run (report 02 §7); the missing-probe discipline is exactly
  what caused the v1 Phase-3 refutation. A probe failure → [BLOCKED] + escalation handoff, NOT
  construction, NOT statement-weakening on the fly.
- Derive pinned realization from free-env `P.existF 4` content alone (machine-refuted,
  ExteriorFiberProbeK.lean:61). SETTLED since v1.
- Attempt the general-m (m ≥ 1) discharge of `hslice*` / level-descent. At general k the
  obligation is CARRIED (one binder per side); only the m=0 instance is discharged here.
  Out of scope (unchanged from v1 settled decision 2).
- Edit KampPrior.lean arm logic (`| 1 =>` :361, `| n+2 =>` :364) or the realizer engine
  (:1149ff). Only the binder-mirror block :838-876 is in scope in that file.
- Edit the frozen k=2 layer (`kvE2_extBracketFut`, ExteriorBracket.lean:364, and its 348-era
  consumers at KampPrior:351). Same-defect AUDIT is flagged to the orchestrator (Phase 6),
  not performed here.
- Treat "consumer compiles green" as evidence a binder is TRUE (v1 lesson, now with a concrete
  instance: the guarded `hbrFutSat` compiled green through five levels while false).
- Insert `sorry`, vacuous defs, or axioms. Zero-debt contract: un-closable sub-piece → phase
  [BLOCKED] + escalation handoff, never debt.
- Bypass literature-cited steps with `simp`/`omega`/`aesop` shortcuts (lean4.md
  literature-fidelity policy). The proof route is report 02 §3.3 steps 1-5.
- Re-derive statements from memory. When in doubt re-read report 02 §3.3 (signatures are
  normative) and the Rabinovich chunks (`literature-search.sh "Cor 5.4"`, chunk_0015/0016/0022/0023).

**MUST preserve**: every Preserved Assets row; all currently green consumers of touched files
(scoped `lake build` at every phase exit); task 358's green Phase 1-2 work.

**Settled design decisions** (re-open only with a concrete machine counterexample):
1. **Slice = atom layer + three exterior zone lists** (`kvE_futSliceEq`, report 02 §3.3 def) —
   exactly the clause family's expressive footprint (Def 7.13 discipline).
2. **Bracket key = `kvE_futSliceMarked qnf σ`** (some admissible slice-mate marked), pure
   decidable syntax over the NF fintype; slice-mates always receive the SAME clause, killing
   the F ∧ ¬F pair.
3. **The converse conclusion is slice identification** (σ★ marked + pinned-realized +
   atom-layer- and exterior-zone-equal), per report 02 §3.3 signature — NOT full-σ realization,
   NOT bare `qnf.2 σ = true` (both refuted by σ′).
4. **Interface: four obligations → one per side.** `hsliceFut`/`hslicePast` (report 02 §3.4
   shape) carried at general k, discharged at m=0 (Phase 5). σ′ satisfies the obligation
   (σ' := τ) — H4-checked.
5. **New lemmas live in `ExteriorPinnedConverseK.lean` / `ExteriorPinnedConversePastK.lean`**;
   bracket re-key edits stay in the bracket/gate/consumer files. Import direction:
   ExteriorBracketAssembleK imports the PinnedConverse files (they do not import it back — no
   cycle; verify at 3b entry).

**Territory (H7)**: this task owns
`Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge/{ExteriorNegationK,
ExteriorNegationPastK, ExteriorConverterK, ExteriorConverterPastK, ExteriorBracketAssembleK,
ExteriorGateAssembleK, EndIntervalConsumerK, ExteriorPinnedProbeK, ExteriorPinnedConverseK,
ExteriorPinnedConversePastK (new)}.lean` + `KampPrior.lean:838-876` (binder-mirror only) +
append-only access to `Metalogic/WeakCanonical/NormalForm.lean`. ExteriorBracket.lean (frozen
k=2) is explicitly OUTSIDE territory. New-lemma phases (3, 4, 5) write only the PinnedConverse
files; the bracket re-key phase (3b) writes only ExteriorBracketAssembleK,
ExteriorGateAssembleK, EndIntervalConsumerK, KampPrior:838-876 (+ converter files only if the
restated `_complete` lemmas need signature cleanup).

## Source-to-Implementation Mapping (H3, Tier 1)

Condensed from report 02 §6 (full 5-column table there; load-bearing rows only).

| Rabinovich 2014 source | Chunk:lines | Lean target | Status |
|---|---|---|---|
| Cor 5.4(1)⇐ milestone reconstruction — chain truth ⇔ ∃ endpoint realizing the SEGMENT bracket | chunk_0015:11-37 | `kvE_futChainDestructG` (LANDED) + `kvE_futSliceId_of_end_zero` (NEW, Phase 3) | conclusion is segment-slice, NOT full-type — refuted + paper-confirmed |
| `¬F0 ∨ On` negation device — negation of a SEGMENT bracket | chunk_0015:39-41 | `kvE_extNegFut` (LANDED) re-keyed by `kvE_futSliceMarked` (NEW def, Phase 3; wired Phase 3b) | negation footprint must equal content footprint (Lemma 5.1/7.8) — THE repair |
| Cor 5.4(2) re-anchoring | chunk_0015:43, chunk_0016:17 | `kvE_futItemShift_correct` (LANDED); Past mirror (Phase 4) | faithful as landed |
| Def 7.7 canonical expansion — truth at a point = complete pinned datum | chunk_0022:5 | `nf_characteristic`/`_satisfies`/`nf_eval_unique` (LANDED) → σ★ construction + `kvE_futSliceUnique_zero` (NEW, Phase 3) | faithful |
| Def 7.13 adjacent-segment decomposition — interior content lives in OTHER conjuncts | chunk_0023:25 | interior obligations (`hreal`/`hexcl`) already segment-scoped; exterior converse must NOT supply interior marks | rules out candidate (b) |
| Lemma 5.3 first-point re-anchoring | chunk_0014 | `HasAttainedINF.first_occ` (LANDED) | faithful |

## Goals & Non-Goals

- **Goals**:
  - G1. Phase-0b machine adjudication of report 02's three Medium-confidence claims: P1 (C4:
    honest `qnf.2 σ′ = false` on the probe model), P2 (C8: the slice-id composite on the probe
    model), P3 (C9: depth-0 same-witness interior transfer between profile-equal endpoints) —
    the GO/NO-GO gate for all construction.
  - G2. Slice machinery + the two NEW theorems `kvE_futSliceId_of_end_zero` and
    `kvE_futSliceUnique_zero` sorry-free (Phase 3), Past mirrors (Phase 4).
  - G3. Brackets re-keyed to `kvE_*SliceMarked`; D1 (slice-level), D3, D4, gate,
    `EndIntervalCorrectPrior`, KampPrior mirror re-proved with the `hreal`/`hsat`/`hbr*`
    antecedents REMOVED and the single `hsliceFut`/`hslicePast` obligation carried; all
    consumers green (Phase 3b).
  - G4. m=0 discharge theorems for `hsliceFut`/`hslicePast` — the interface 358's `:361` arm
    and 349 v8 Phase 6 consume (Phase 5).
  - G5. Zero-debt terminus + audit flag (frozen k=2 `kvE2_extBracketFut`) + 349-consumer note
    recorded (Phase 6).
- **Non-Goals**:
  - General-m (m ≥ 1) discharge of `hslice*` / level-descent (settled decision 4; future task).
  - KampPrior `:361`/`:364` arm discharge or the carrier→formula fold (task 358).
  - The frozen k=2 layer audit/repair itself (flag only; separate task).
  - `endInterval_correct` endpoint primitive work (task 349 Phases 5-7).
  - Any edit to the depth-k clause family definitions (read-only; only the bracket keying and
    consumers change).

## Risks & Mitigations

- **Risk**: a P1-P3 probe fails (all three are Medium-confidence, not yet machine-run).
  **Mitigation**: Phase 0b is a hard gate with a fixed attempt budget; failure terminus is
  [BLOCKED] + escalation handoff naming the failing goal state verbatim; no construction phase
  runs. This is the same discipline whose absence produced the v1 Phase-3 refutation.
- **Risk**: `kvE_futSliceUnique_zero`'s interior same-witness transfer (report 02 C9) hides a
  depth-0 subtlety (env-dependence beyond the atomic profile). **Mitigation**: P3 probes exactly
  this lemma shape before Phase 3; `nf_eval_nf0_cons_factor` is the landed factoring channel.
- **Risk**: Phase 3b's bracket re-key breaks a consumer not on the map. **Mitigation**: report
  02 grep confirmed the bracket consumers are ExteriorBracketK/GateAssembleK/BracketAssembleK
  only; re-grep `kvE_extBracketFut\|kvE_extBracketPast\|hbrFut\|hbrPast` at 3b entry; scoped
  builds of all chain files + full `lake build` at 3b exit.
- **Risk**: import cycle when ExteriorBracketAssembleK imports ExteriorPinnedConverseK for the
  slice defs. **Mitigation**: settled decision 5 fixes the direction; verify with `lake build`
  of the bracket file first; if a cycle exists, hoist ONLY the two defs + slice-constancy lemma
  into a new leaf file `ExteriorSliceKeyK.lean` (same territory) — record as deviation.
- **Risk**: Phase 3b silently expands into re-proving general-k converse content. **Mitigation**:
  at general k the negative case is discharged by the CARRIED `hslice*` binder directly
  (slice-unmarked + chain fires → obligation yields marked slice-mate → contradiction); no
  destructor-to-slice-id conversion exists at general k and none may be attempted.
- **Risk**: heartbeat blowups in EndIntervalConsumerK (already at `maxHeartbeats 1600000`).
  **Mitigation**: interface delta is binder REMOVAL + one addition — keep proof bodies
  pass-through; raise heartbeats only as last resort and record it.
- **Risk**: task 349/358 dispatches consume the OLD interface mid-flight. **Mitigation**:
  handoff JSON + Phase 6 notes name the new interface explicitly; 349 v8 Phase 6 must consume
  the slice-keyed interface (report 02 §8 delta 5).

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 0, 1, 2 | -- (all [COMPLETED] at HEAD) |
| 2 | 0b | 0 |
| 3 | 3 | 0b |
| 4 | 3b | 3 |
| 5 | 4 | 3, 3b |
| 6 | 5 | 3b, 4 |
| 7 | 6 | 5 |

Open phases are strictly sequential (each depends on its predecessor's artifacts; 4 needs 3's
Future template AND 3b's Past slice defs). Each open phase is one agent run (H8).

### Phase 0: Mandatory machine-probe gate (C3 at m=1, C8 at m=0) [COMPLETED]

Completed 2026-07-13 (sess_1783950096_9d2925); committed at `83fd80e78` lineage. Full record in
plan v1 (plans/01_restate-hbr-pinned-converse.md Phase 0). Verdicts: C8 GO (probe lemmas (a)-(c′)
green in ExteriorPinnedProbeK.lean), C3 Verdict B (core compiled, informative). **v2 annotation**:
the C8 probe validated the honest configuration and gap-marking separation but never probed
interior-marking separation — the gap that Phase 3's refutation exposed and Phase 0b's P1-P3
now close. The probe artifacts themselves remain valid and are consumed by the slice-id route.

### Phase 1: Restate the four exterior obligations through the 5-level interface chain [COMPLETED]

Completed 2026-07-13 (sess_1783950096_9d2925); full record in plan v1 Phase 1; full
`lake build` green (1734 jobs), axiom-clean. **v2 annotation — partially superseded**: the
committed re-threading is the substrate Phase 3b edits. What survives permanently: destructor
facts bound (`hgap`/`hocc` — now the slice-id inputs), l-free `hocc` conversion, ambient
threading at the ∀-w levels, uniform antecedent order, D3/D4 `qnf` quantification. What Phase 3b
removes: the four guarded `hbr*` binders themselves (the guarded `hbrFutSat`/`hbrPastSat` are
FALSE — the (σ′,e) witness satisfies every guard antecedent; `hbr*Real` unrefuted but
eliminated with the interface). The restated `kvE_extNeg*_complete` converter lemmas may remain
as general-k tooling (report 02 §8 delta 2); Phase 3b decides keep-vs-simplify per usage.

### Phase 2: Future pinned converse at m=0 — endpoint atom-layer pinning [COMPLETED]

Completed 2026-07-13 (sess_1783950096_9d2925); full record in plan v1 Phase 2.
`kvE_futAtomPinned_zero` + 3 helpers green and axiom-clean in ExteriorPinnedConverseK.lean.
**v2 annotation**: consumed unchanged as slice-id steps 2 (atom layer, via `nf_eval_unique` at
depth 0) and 5 (self-zone coincidence). σ′ does not touch this phase (atom layers of σ′ and τ
are equal).

### Phase 0b: Probe gate P1-P3 for the slice repair (C4/C8/C9) [COMPLETED]

**VERDICT (2026-07-13, sess_1783950096_9d2925): GO — all three probes GREEN.**

- **P1 (C4) GO**: `kvE_probe_p1_erased_qnf_unmarked` — `p3qnf.2 p3sigmaR = false` for the
  refutation's σ′ (τ with `p3eInt := char [15,25,15,2,18]` erased) on P3M. Route: any
  putative realizer `u` carries 25's complete 4-type (conjunct-1 zone read gives `18 < u`),
  the P3 engine transfers `p3eInt`'s witness 15 to `[15,u,15,2,18]`, and the depth-1 fold
  forces the erased bit. C4 → machine-run High; the §2 honest-bracket-unsatisfiability chain
  is now fully machine-backed. Attempts: 2 of 12.
- **P2 (C8) GO**: `kvE_probe_p2_sliceId` — the §3.3 steps 1-5 composite at `[25,15,2,18]`,
  quantified over ALL admissible on-fiber σ with `hend`/`hgap`/`hocc` (NOT just a single σ
  instance); conclusion with explicit witness σ′ := `p3tau`: marked + pinned-realized +
  `p3tau.1 = σ.1` + per-element exterior-zone marking agreement. All five route steps
  compiled with the plan's exact suppliers (probe (b)/(c) upgrades, Phase-2
  `kvE_futAtomPinned_zero`, conjunct 4 + `nf0_split_assemble`, `nf_eval_unique`).
  Attempts: 2 of 12.
- **P3 (C9) GO**: `kvE_probe_interior_transfer` — abstract (any `OrderedMonadicStructure`),
  the `kvE_futSliceUnique_zero` engine: interior witness (`¬ t < v`) + profile-equal
  endpoints (`x1'` realizes `char [x1,w,x,t]`) ⇒ same-witness transfer. Attempts: 2 of 12.

Verification: scoped + full `lake build` GREEN (1734 jobs); `#print axioms` on all three =
exactly `[propext, Classical.choice, Quot.sound]`; zero sorries in territory.
*(deviation: altered — probe file gained ONE import line, `ExteriorPinnedConverseK`, to
consume the Phase-2 supplier `kvE_futAtomPinned_zero`; leaf-safe, no cycle. Also
`nfk_projFresh_zero` (private, CarrierKv.lean:89) replicated file-locally as
`p3_projFresh_zero` per the `kvE_minPick` precedent.)*

- **Goal:** Machine-adjudicate report 02 §7's three Medium-confidence claims BEFORE any
  construction. Hard GO/NO-GO gate for Phases 3-6.
- **Bounded unit:** three probes, each with a FIXED attempt surface: at most 12
  `lean_run_code`/`lean_multi_attempt` attempts per probe; on exhaustion without a green
  artifact the probe is FAILED. Any probe failure → plan Status [BLOCKED] + escalation handoff
  (failing goal state verbatim) + task status blocked; Phases 3-6 do not run. NOT construction:
  no statement may be weakened or redesigned inside this phase to make a probe pass.
- **Tasks:**
  - [x] Re-read report 02 §2 (C4 argument), §3.3 route steps 1-5 (C8), §3.3 uniqueness route
        (C9); Read ExteriorPinnedProbeK.lean for the P3M probe conventions (anchors
        2 < 15 < 18 < 25, `p3_UZ`/`p3_SZ`, depth-0 provider).
  - [x] **P1 (C4)**: compile `qnf.2 σ′ = false` for the honest
        `qnf := nf_characteristic P3M 2 3 [15,2,18]` and the refutation's σ′ on the P3M model —
        i.e. σ′ is realizable at NO `[y,w,x,t]`: any y satisfying σ′.1 carries x1's complete
        atomic profile, so `e = nf_characteristic P3M 0 5 [w,x1,w,x,t]` transfers to
        `[w,y,w,x,t]` with the same witness `w` and the fold fails at the unmarked e
        (report 02 §2 item 2). Via `lean_run_code`; budget 12.
  - [x] **P2 (C8)**: compile the slice-id composite on the P3M instance: for the destructor
        configuration used by the Phase-0 probes, σ★ := `nf_characteristic P3M 1 4 [25,15,2,18]`
        is qnf-marked + pinned-realized + atom-layer-equal + exterior-zone-list-equal to an
        admissible on-fiber σ satisfying `hend`/`hgap`/`hocc` — the report 02 §3.3 conclusion
        instantiated concretely (a concrete-instance check of steps 1-5 chained, or per-step if
        the composite exceeds one snippet). Via `lean_run_code`; budget 12.
  - [x] **P3 (C9)**: compile the depth-0 same-witness transfer lemma shape: for
        `s : NormalForm sig 0 5` and endpoints x1, x1′ with equal complete atomic profiles
        (`nf_eval_nf M 0 4 [x1,…] π ↔ nf_eval_nf M 0 4 [x1′,…] π` for the profile π), a witness
        v realizing s over `[v,x1,w,x,t]` also realizes it over `[v,x1′,w,x,t]` (same v) —
        the `kvE_futSliceUnique_zero` engine. Prefer stating it abstractly (any linear order),
        as `kvE_probe_selfZone_coincide` precedent. Via `lean_run_code`; budget 12.
  - [x] Persist all green probe artifacts into ExteriorPinnedProbeK.lean (append-only; new
        section header `-- Phase 0b: slice-repair probes P1-P3`); scoped build. *(deviation:
        altered — plus one import line, see verdict block)*
  - [x] Record the three verdicts in `.orchestrator-handoff.json` (`continuation_context`) and
        under this phase's heading; commit `task 360 phase 0b: slice-repair probe gate`.
  - [ ] **NO-GO branch**: on any probe failure, set plan Status [BLOCKED], write the escalation
        handoff naming the probe, the last failing goal state, and the attempted variants; STOP.
        *(deviation: skipped — not triggered; all probes GO)*
- **Done when:** three green persisted probe artifacts (or the NO-GO branch executed); scoped
  `lake build …ExteriorPinnedProbeK` green; verdicts recorded.
- **Estimated output:** ~120-250 lines (probe file section + records).
- **Timing:** 2-3 hours.
- **Depends on:** 0 (probe file + conventions)
- **File scope:** ExteriorPinnedProbeK.lean (append-only); plan file + handoff JSON (records).
  No production-file edits.

### Phase 3: Slice machinery + `kvE_futSliceId_of_end_zero` + `kvE_futSliceUnique_zero` [COMPLETED]

**VERDICT (2026-07-13, sess_1783950096_9d2925): COMPLETED — all deliverables green.**
6 public decls (5 planned + 1 hoist-replica, see deviation) + 5 private helpers appended to
ExteriorPinnedConverseK.lean (+580 lines). Scoped AND full `lake build` GREEN (1734 jobs);
`#print axioms` on all 6 public decls AND the refutation regression guard = exactly
`[propext, Classical.choice, Quot.sound]`; territory sorry count 0; zero vacuous defs; zero
new axioms. H4 phase-exit record: the refutation witness σ′ SATISFIES
`kvE_futSliceId_of_end_zero`'s conclusion (σ' := τ — machine-validated as probe P2 on the
concrete instance) and satisfies `kvE_futSliceUnique_zero` vacuously (σ′ pinned-unrealizable,
probe P1); `kvE_futPinned_of_end_zero_refuted` untouched (append-only diff) and rebuilt green.

- **Goal:** In ExteriorPinnedConverseK.lean, land the Future half of the faithful repair:
  the slice defs, the clause slice-constancy lemma, the exterior-slice identification theorem
  (replacing the refuted converse), and the reconstruction companion.
- **Bounded unit:** 2 defs + 1 constancy lemma + 2 theorems with FIXED signatures (report 02
  §3.3, normative — transcribe, do not redesign) and a FIXED per-zone case list.
- **Tasks:**
  - [x] Transcribe `kvE_futSliceEq` and `kvE_futSliceMarked` verbatim from report 02 §3.3
        (decidable Bool defs over the NF fintype; `Finset.univ.toList` idiom as in
        ExteriorBracketAssembleK). File-head docstring: quote the report 02 §3.3 signatures +
        the Def 7.13 footprint principle (chunk_0023:25). *(deviation: altered — the §3.3
        signatures + Def 7.13 principle are quoted in the Phase-3 SECTION docstring rather
        than the file head; the file head documents the landed Phase-2 content and was left
        untouched per the preserved-assets constraint)*
  - [x] Clause slice-constancy lemma: for admissible σ′, σ with `kvE_futSliceEq σ′ σ = true`,
        the clause formulas agree — `kvE_futPos P σ′ = kvE_futPos P σ`,
        `kvE_futEnd P σ′ = kvE_futEnd P σ`, `kvE_futGapD P σ′ = kvE_futGapD P σ`, and hence
        `kvE_extNegFut P σ′ = kvE_extNegFut P σ`. Engine: the landed `kvE_fiberZoneList_congr`
        pattern generalized from sub-marking to slice-equality (report 02 C10; the σ′/τ
        instances `hPosEq`/`hEndEq`/`hGapDeq` are the template). Landed as
        `kvE_futClause_sliceConstant` (4-way conjunction).
  - [x] `kvE_futSliceId_of_end_zero` with the EXACT report 02 §3.3 signature (hypotheses:
        `hadm`, `hfib : nfk_dropFresh σ = qnf.1`, order facts, ambient `h`, `htx1`, `hend`,
        `hgap`, `hocc`; conclusion: ∃ σ′ marked + pinned-realized at `[x1,w,x,t]` + `σ'.1 = σ.1`
        + exterior-zone marking agreement; no `hpos` antecedent). Proof route steps 1-5
        (report 02 §3.3): σ★ := `nf_characteristic M 1 4 [x1,w,x,t]` via
        `nf_characteristic_satisfies` + `(h.2 σ★).mp` (P2 mechanism); atom layer via Phase-2
        `kvE_futAtomPinned_zero` + `nf_eval_unique` at depth 0; gap-zone agreement both
        inclusions via `hocc`/`hgap` + the `nf_eval_nf0_cons_factor` upgrade
        (probe `kvE_probe_gapItem_pinned` mechanism) + depth-0 uniqueness; ray agreement via
        `hend` ray conjuncts (probe `kvE_probe_rayItem_pinned`) both directions; self agreement
        via `hend` self conjunct + `kvE_futSelfZone_coincide` + admissibility conjunct 4.
        *(the probe upgrade mechanisms are abstracted as private
        `kvE_futGapItem_pinned_zero`/`kvE_futRayItem_pinned_zero`; the private
        `nfk_projFresh_zero` replica landed as `kvE_projFresh_zero` per the probe precedent)*
  - [x] `kvE_futSliceUnique_zero` (report 02 §3.3 second signature): slice-equal σ′, σ both
        pinned-realized (possibly different exterior endpoints x1′, x1 over the same
        `[w,x,t]`) → σ′ = σ. Route: `nf_eval_unique` pins each to its endpoint characteristic;
        slice-equal atom layers give profile-equal endpoints; interior depth-0 elements
        transfer with the SAME witness (P3 lemma); exterior zones agree by hypothesis.
        *(deviation: altered — the P3 engine `kvE_probe_interior_transfer` could NOT be
        consumed from the probe file: ExteriorPinnedProbeK IMPORTS this file (Phase-0b
        deviation), so consumption would create an import cycle. It is replicated here as the
        6th public decl `kvE_futInteriorTransfer_zero` (settled decision 5: this file stays a
        leaf). Two private zone-bookkeeping helpers added for the interior classification:
        `kvE_zoneHolds_unique`, `kvE_futZoneSpec_of_above`)*
  - [x] H4 sanity check (record in phase-exit note, no new file): σ′ from the refutation
        satisfies `kvE_futSliceId_of_end_zero`'s conclusion via σ' := τ; `kvE_futSliceUnique_zero`
        is vacuous at σ′ (unrealizable — P1). Cross-check against
        `kvE_futPinned_of_end_zero_refuted` still green (regression guard untouched).
        Recorded in the VERDICT block above.
  - [x] `lake env lean` `#print axioms` on all 5 new decls (exactly
        `[propext, Classical.choice, Quot.sound]`); scoped build; commit. *(run on all 6
        public decls + the refutation guard — all exactly the three standard axioms)*
- **Done when:** 5 new decls sorry-free + axiom-clean; scoped `lake build
  …ExteriorPinnedConverseK` green; refutation theorem + salvage lemmas untouched.
- **Stopping condition / split trigger:** if after `kvE_futSliceId_of_end_zero` the phase
  exceeds ~350 lines or the dispatch is at 70% budget, commit it green as sub-phase 3.1 and
  finish `kvE_futSliceUnique_zero` as 3.2. If any zone case lacks a supplier among
  {hgap, hocc, hend, ambient, Phase-2 lemmas, P1-P3 artifacts} (goal-state evidence required),
  mark [BLOCKED] + escalate — that is a probe-gate defect; do not invent interface hypotheses.
- **Estimated output:** ~250-400 lines.
- **Timing:** 3-4 hours (up to 2 dispatches via 3.1/3.2).
- **Depends on:** 0b (gate), 2 (atom layer)
- **File scope:** ExteriorPinnedConverseK.lean only (append small generic depth-0
  uniqueness/factoring helpers to Metalogic/WeakCanonical/NormalForm.lean ONLY if missing
  there; existing declarations untouched).

### Phase 3b: Re-key the brackets + re-prove consumers D1/D3/D4 without `hreal`/`hsat`/`hbr*` [COMPLETED]

**DEVIATION RECORD (Phase 3b, interface shape)**: the carried exterior interface is TWO
obligations per side, not one: `hslice{Past,Fut}` (report 02 §3.4 shape verbatim, ⇐-side,
ambient-guarded) PLUS `hexclSlice{Past,Fut}` (⇒-side per-σ exclusion residue for
bit-false-but-slice-MARKED σ, `igPtW`-guarded, `hexcl`-shaped). Reason (goal-state evidence):
the gate's internal `hexclExt` discharge (`bracketEndChar_kv_step_sound`'s per-σ input, fixed
read-only task-355 shape) needs per-σ exclusion; the slice-keyed D1/D2 exclude only
slice-UNMARKED σ; report 02 §3.4's prescribed recovery (`kvE_futSliceUnique_zero` + `hreal`)
is m=0-only while the gate binds general `k`. The carried `hexclSlice*` statement IS the §3.4
recovery's conclusion; at m = 0 it is discharged by exactly that recipe (uniqueness + `hreal`
+ admissibility-zone endpoint positioning). H4: the refutation witness σ′ is
pinned-unrealizable (probe P1), so it satisfies `hexclSlice*` vacuously — unlike the refuted
`hbr*`-Sat shapes. **Phase-5 scope consequence**: FOUR m=0 supply theorems (two `hslice*`,
two `hexclSlice*`), not two; the `hexclSlice*` discharge additionally needs the Phase-4 Past
uniqueness mirror.

- **Goal:** Wire the slice keying through the consumption chain: re-key
  `kvE_extBracket{Fut,Past}` from `qnf.2 σ` to `kvE_*SliceMarked qnf σ`, re-prove D1 (slice
  level) and D3/D4, propagate through the gate, `EndIntervalCorrectPrior`, and the KampPrior
  :845-870 mirror — DROPPING the four `hbr*` binders and the converter `hreal`/`hsat`
  antecedent usage, carrying instead ONE slice-honesty obligation per side
  (`hsliceFut`/`hslicePast`, report 02 §3.4 shape). All consumers green.
- **Bounded unit:** one coherent interface re-key across the (already once re-threaded) chain
  files; the new mathematics is confined to the D1/D3/D4 re-proofs whose routes report 02 §3.4
  fixes.
- **Tasks:**
  - [x] Entry checks: verify import direction (ExteriorBracketAssembleK can import
        ExteriorPinnedConverseK without a cycle — settled decision 5; on failure hoist defs to
        `ExteriorSliceKeyK.lean` and record deviation); re-grep
        `kvE_extBracketFut\|kvE_extBracketPast\|hbrFutReal\|hbrFutSat\|hbrPastReal\|hbrPastSat`
        repo-wide to confirm the consumer map. *(no cycle — ConverseK is a leaf below
        AssembleK, no hoist needed; consumer map = gate + EndIntervalConsumerK + KampPrior
        seam only, confirmed)*
  - [x] Past-side slice defs: create `ExteriorPinnedConversePastK.lean` with `kvE_pastSliceEq`,
        `kvE_pastSliceMarked`, and the Past clause slice-constancy lemma (mechanical mirrors of
        Phase 3's defs/lemma; the slice-id THEOREMS are Phase 4, not here). Needed because this
        phase re-keys BOTH brackets. *(deviation: altered — also added
        `kvE_pastSliceMarked_iff` extraction helper; the Future twin `kvE_futSliceMarked_iff`
        placed in AssembleK to keep the Phase-3 converse file read-only)*
  - [x] `ExteriorBracketAssembleK.lean`: re-key the Future (:53) and Past (:66) bracket
        if-then-else to `kvE_*SliceMarked qnf σ`; re-prove D1 at slice level (positive clause
        for slice-marked σ: marked slice-mate σ' + realizability + `kvE_futPos_of_realizer` +
        slice-constancy transfer; per-σ exclusion recovered where consumed via
        `kvE_futSliceUnique_zero` + the interior-style `hreal` binder — report 02 §3.4 last
        paragraph, the task-348 `hexclExt` shape); re-prove D3/D4 negative case: general-k via
        the CARRIED `hslice*` binder (slice-unmarked + by_contra chain fires → obligation gives
        marked slice-mate → contradiction); DROP the `hreal`/`hsat` antecedent usage.
        *(deviation: altered — D3/D4 also drop `hneg` (subsumed by contraposed `hslice`);
        per-σ exclusion carried as `hexclSlice*` per the phase deviation record, since the
        m=0-only uniqueness recovery cannot run inside the general-k gate)*
  - [x] `ExteriorGateAssembleK.lean`: replace the four `hbr*` binders (:142-167) with
        `hsliceFut`/`hslicePast` (report 02 §3.4 shape, transcribed verbatim; ambient-guarded,
        ∀-w form); rewire applications. *(deviation: altered — four binders
        `hslicePast`/`hsliceFut`/`hexclSlicePast`/`hexclSliceFut` per the phase deviation
        record; ⇒-direction hexclExt discharge = slice-level D1/D2 for unmarked σ +
        `hexclSlice*` for marked bit-false σ)*
  - [x] `EndIntervalConsumerK.lean`: same replacement inside `EndIntervalCorrectPrior`
        ("binder types copied verbatim from ExteriorGateAssembleK" discipline);
        `endInterval_step_correct` re-threads by intro/pass-through.
  - [x] `KampPrior.lean:838-876`: mirror the new binders; pass-through at :875. NO other
        KampPrior lines. *(actual lines :845-904 after Phase-1 drift; pass-through preserved)*
  - [x] Converter files (only if needed): `kvE_extNeg*_complete` may remain as general-k
        tooling (report 02 §8 delta 2) — keep them green; simplify their guarded antecedents
        only if D3/D4 no longer consume them and the simplification is a pure deletion.
        *(deviation: skipped — converters left untouched and green as general-k tooling;
        no deletion performed this dispatch)*
  - [x] H4 sanity check: the honest bracket is now satisfiable at the σ′ conjunct (positive
        clause, `hPosEq`); record in phase-exit note. *(recorded in phase-3b handoff: σ′ is
        slice-marked via τ, receives `kvE_futPos σ′ = kvE_futPos τ` (constancy), true at t on
        the refutation model — no `F ∧ ¬F` conjunct remains)*
  - [x] Scoped builds of all edited files; FULL `lake build` (1736 jobs GREEN); `#print axioms`
        on the re-proved D1/D2/D3/D4, gate, `endInterval_step_correct`,
        `kampPrior_site_rungK_gate_match`, both `_iff` helpers, Past constancy, and the
        preserved refutation guard — all `[propext, Classical.choice, Quot.sound]`; commit.
- **Done when:** brackets slice-keyed; zero occurrences of `hbrFutReal|hbrFutSat|hbrPastReal|hbrPastSat`
  in the consumption chain (grep-verified); `hsliceFut`/`hslicePast` carried at every level;
  full `lake build` green; zero sorries introduced.
- **Stopping condition / split trigger:** if the D1 slice-level re-proof exceeds the dispatch
  (70% budget), commit the re-keyed brackets + D3/D4 green as 3b.1 and finish D1/gate/consumer
  propagation as 3b.2. If a consumer needs per-σ content the slice interface cannot express
  (goal-state evidence), [BLOCKED] + escalate — do not resurrect a per-σ binder.
- **Estimated output:** ~300-450 diff lines across 5-6 files.
- **Timing:** 3-4 hours (up to 2 dispatches via 3b.1/3b.2).
- **Depends on:** 3
- **File scope:** ExteriorBracketAssembleK, ExteriorGateAssembleK, EndIntervalConsumerK,
  KampPrior.lean:838-876, ExteriorPinnedConversePastK.lean (new, defs+constancy only),
  ExteriorConverter{,Past}K (conditional, deletion-only).

### Phase 4: Past mirror — `kvE_pastSliceId_of_end_zero` + `kvE_pastSliceUnique_zero` [COMPLETED]

**BLOCKER RESOLVED (Phase 4a, report 03 option (a) — faithful conjunct-4 restoration)**:
escalation research (reports/03_past-admissibility-conjunct4-repair.md) adjudicated the
asymmetry as an in-tree omission by task 352 (Rabinovich Cor 5.4(2) is the exact mirror of
(1); the frozen k=2 `kvE2_pastAdmissible` carried condition 4 symmetrically) and
machine-verified the producer branch. This dispatch: (i) GATE — the V11 Medium-confidence
composite (full Past slice-id with conjunct 4 as hypothesis) machine-run via `lean_run_code`,
GREEN with zero diagnostics → GO; (ii) conjunct 4 restored to `kvE_pastAdmissible`
(`kvE_pastSelfZone` hoisted above the def, mirroring the Future layout) + producer 4th branch
discharged (no order hypotheses consumed, exactly as probed); (iii) the 3 mechanical readers
re-threaded (ConverterPastK dichotomy +1 projection, GateAssembleK:235 one token,
PastConverseK zoneMark +1 rewrite); (iv) both refuted docstrings corrected; (v)
`kvE_pastSliceId_of_end_zero` landed with private helpers `kvE_pastProjFresh_zero`/
`kvE_pastGapItem_pinned_zero`/`kvE_pastRayItem_pinned_zero`. Scoped build GREEN (1030 jobs),
full build GREEN (1736 jobs), all four new/re-keyed decls axiom-clean
(`[propext, Classical.choice, Quot.sound]`), territory sorry census 0, no consumer statement
edits (EndIntervalConsumerK/KampPrior/BracketAssembleK recompile as-is — Phase-3b seam
survives). The original defect record is preserved below for the audit trail.

**BLOCKER (RESOLVED — historical record)** — `kvE_pastSliceId_of_end_zero` is FALSE as the
naive mirror; all other Phase-4 targets LANDED GREEN (see checklist). The stopping condition
fired: a genuine asymmetry, not a transcription slip.

- **What failed**: the SELF-zone/bit-true case of the slice-id mirror. The Future proof
  (ExteriorPinnedConverseK.lean:1041-1082) closes it via `hc4 := hadm'.2` — the FOURTH
  conjunct of `kvE_futAdmissible` (ExteriorNegationK.lean:95-98: all self-zone-prescribed
  fresh profiles coincide) — identifying the σ-marked self element `s` with the single
  element `s0` that `hend`'s self conjunct delivers realized. `kvE_pastAdmissible`
  (ExteriorNegationPastK.lean:134-140) has only THREE conjuncts; its docstring delegates the
  frozen condition (4) to "the full-fiber content channel downstream", but no hypothesis of
  the slice-id signature reads self-zone marks per-item.
- **What was tried (machine evidence, `lean_run_code` this dispatch)**: the mirrored Future
  tactic block `unfold kvE_pastAdmissible at hadm'; rw [Bool.and_eq_true, Bool.and_eq_true,
  Bool.and_eq_true] at hadm'` FAILS at the third rewrite — "Did not find an occurrence of the
  pattern `(?a && ?b) = true`"; the full decomposition visible in the error is exactly
  `(zone-marking ∧ on-fiber) ∧ order-possible-zones` — no fourth conjunct. The two-rewrite
  decomposition compiles and `hadm'.2` is the order-possible-zones conjunct (`nfk_zoneSpec`
  membership), carrying no self-profile-uniqueness content.
- **Why stuck (the statement is false, not merely unproved)**: counterexample σ := honest
  endpoint characteristic τ (at `x1 < x`) with ONE extra self-zone mark
  `s' := nf0_assemble kvE_pastSelfZone χ' τ.1` for any fresh profile `χ'` other than the
  realized one. Every hypothesis holds verbatim: `hadm` (conjunct 1 unchanged; conjunct 2:
  `s'` on-fiber by construction; conjunct 3: `kvE_pastSelfZone_mem`); `hfib`/ambient
  unchanged; `hend` — its self conjunct is `kvE_fiberPosOnShift` over the self list, an
  EXISTENTIAL (`kvE_fiberPosOnShift_correct`, ExteriorFiberK.lean:365-372), satisfied by the
  realized element regardless of `s'`; `hgap`/`hocc`/rayForm read only the gap/ray lists,
  which are unchanged. But the conclusion requires a pinned-realized σ' agreeing with σ on
  the self zone: a σ' realized at any past-exterior endpoint marks at most ONE self-zone
  element (self-witness coincidence forces the witness to the endpoint; `nf_eval_unique`
  makes the realized depth-0 5-type there unique), so no σ' marks both `s0` and `s'`.
  The SAME counterexample refutes the Future statement when conjunct 4 is deleted — the
  Future proof goes through precisely because `kvE_futAdmissible` excludes such σ.
- **Blast radius (feeds the re-adjudication)**: the Phase-3b carried binder `hslicePast`
  (EndIntervalConsumerK.lean:139-144) guards on `kvE_pastAdmissible σ = true` +
  `kvE_pastPos` truth only, so the SAME σ satisfies its guards (slice-constancy on gap/ray +
  the self existential keep `kvE_pastPos σ` true on the honest model) while no admissible
  marked slice-mate exists (`kvE_pastSliceEq` demands self-LIST equality) — the Phase-5
  `kvE_hslicePast_supply_zero` discharge is therefore UNDISCHARGEABLE as the interface
  stands. The `hexclSlicePast` route is NOT affected (it consumes
  `kvE_pastSliceUnique_zero` + `hreal`, both admissibility-conjunct-4-free;
  `kvE_pastSliceUnique_zero` LANDED GREEN this dispatch).
- **What is needed (repair options, out of Phase-4 territory — settled files)**:
  (a) add the missing conjunct 4 (self-zone fresh-profile uniqueness, the exact
  `kvE_futAdmissible` shape with `kvE_pastSelfZone`) to `kvE_pastAdmissible`
  (ExteriorNegationPastK.lean:134) and re-thread its consumers (realizer_admissible D-side
  proofs, ConverterPastK, 3b bracket/gate binders) — restores the symmetric design and both
  Phase-5 Past discharges; or (b) strengthen the `hslicePast` binder guard in the 3b chain
  with an explicit self-uniqueness antecedent (binder-text edits in GateAssembleK /
  EndIntervalConsumerK / KampPrior seam). Option (a) is design-faithful (task-352's Past
  reformulation dropped the conjunct claiming downstream subsumption — refuted here).
  A Past-side machine refutation probe (P1-style) belongs to the probe file (read-only this
  dispatch) and should accompany the repair task.
- **Prohibited**: no sorry, no vacuous placeholder — none introduced; the file carries only
  the GREEN mirrors.

- **Goal:** Port Phase 3's two theorems to the Past side in ExteriorPinnedConversePastK.lean
  (defs + constancy already landed there in 3b): `kvE_pastAtomPinned_zero` (Past mirror of the
  Phase-2 atom layer, if not already implied), `kvE_pastSliceId_of_end_zero`,
  `kvE_pastSliceUnique_zero` (endpoint `x1 < x`, `kvE_pastEnd`, `kvE_pastAdmissible`, Past zone
  specs, raw `P.existF 4 (renameNF rot5Fwd rot5Bwd a)` item form per the Phase-1 record).
- **Bounded unit:** a mechanical mirror of a landed technique; the Future file is the template
  (same lemma names with `past`, same fixed case list).
- **Tasks:**
  - [x] Port the atom-layer lemma (Phase-2 template) with Past zone semantics. *(landed:
        `kvE_pastAdmissible_zoneMark`, `kvE_pastSelfZone_coincide`,
        `kvE_pastFreshPinned_of_end`, `kvE_pastAtomPinned_zero` — all GREEN, axiom-clean)*
  - [x] Port `kvE_futSliceId_of_end_zero` and `kvE_futSliceUnique_zero` (hoist any
        side-agnostic helpers to the Future file and import — prefer hoisting over duplication).
        *(deviation: altered — `kvE_pastSliceUnique_zero` LANDED GREEN (+ its engine
        `kvE_pastInteriorTransfer_zero` and private zone helpers `kvE_pastZone4_of_below`/
        `kvE_pastZoneSpec_of_below`; no hoisting needed — the only shared candidates are
        `private` in their home files, replication precedent applied);
        `kvE_pastSliceId_of_end_zero` landed in the Phase-4a re-dispatch AFTER the conjunct-4
        restoration (statement was FALSE under the 3-conjunct predicate — see resolved
        BLOCKER record; item form is the raw `P.existF 4 (renameNF rot5Fwd rot5Bwd s)` per
        the Past clause-family convention, gate-probed GREEN before production))*
  - [x] `#print axioms` on all new decls; scoped build; commit. *(all six new decls exactly
        `[propext, Classical.choice, Quot.sound]`; scoped build 1024 jobs GREEN; full build
        1736 jobs GREEN)*
- **Done when:** Past theorems sorry-free + axiom-clean; scoped build green.
- **Stopping condition:** if a Past-side zone case fails to mirror (goal-state evidence of a
  genuine asymmetry, not a transcription slip), [BLOCKED] + escalate. *(FIRED — see BLOCKER)*
- **Estimated output:** ~250-400 lines.
- **Timing:** 2-3 hours.
- **Depends on:** 3 (template), 3b (Past defs/constancy in the file)
- **File scope:** ExteriorPinnedConversePastK.lean (+ hoisted helpers appended to
  ExteriorPinnedConverseK.lean); read-only elsewhere.

### Phase 5: m=0 discharge of `hsliceFut`/`hslicePast` [BLOCKED]

**BLOCKER** (Phase 5, dispatch 2026-07-14, sess_1783950096_9d2925) — `hslice*` pair only; the
`hexclSlice*` pair LANDED GREEN (see the updated checklist below):

- **What failed**: `kvE_hsliceFut_supply_zero` (and its Past mirror) in the signature-locked
  binder shape (EndIntervalConsumerK.lean:145-150 at m := 0). The prescribed route (chain
  destructor + `kvE_futSliceId_of_end_zero`, report 02 §3.4/§5-row-2) was machine-probed via
  `lean_run_code` (gate-first, Phase-4a discipline): the ENTIRE route elaborates with exactly
  ONE gap — the slice-id's fiber input `hfib : nfk_dropFresh σ = qnf.1` (its atom-layer fiber
  condition, ExteriorPinnedConverseK.lean:896), which NO binder hypothesis supplies. Probe
  transcript: single `sorry` warning at the `hfib` have-step; all other steps (destructor
  unfold, `himp`, `kvE_futChainDestructG`, slice-id application, admissibility via
  `kvE_futRealizer_admissible`, sliceEq assembly via `kvE_fiberZoneList_congr`) GREEN.
- **What was tried**: (1) the plan-prescribed route (closes modulo `hfib`); (2) derivability
  analysis of `hfib` from the binder's hypothesis set — impossible: every semantic hypothesis
  (`hpos` chain fire, hence `hend`/`hgap`/`hocc`) reads σ through FREE-ENV `P.existF 4`
  content (`kvE_futItemShift_correct`: `∃ env : Fin 4 → M.carrier, …`) and the exterior zone
  lists only, so nothing pins σ's atom layer over the ACTUAL anchors `[w,x,t]` — the same
  footprint property the Phase-3 refutation record documents (ExteriorPinnedConverseK.lean:
  219-240: "σ.2 is never related to qnf.2; hfib relates atom layers").
- **Why stuck — the statement is FALSE as shaped, not merely unprovable by this route**
  (doppelgänger countermodel, analytic): take M = ℤ (satisfies `semantic_prior_UZ`/`SZ`: any
  nonempty set of occurrences bounded below/above in ℤ has a least/greatest element) with one
  monadic predicate Q true exactly at one point w′. Anchors x′ < w′ < t′ < x1′ (e.g.
  0,1,2,100) and x < w < t inside (t′, x1′) (e.g. 3,4,5) with Q(w) = false ≠ Q(w′) = true.
  Set qnf := `nf_characteristic M 2 3 [w,x,t]` (honest ambient — realized), σ :=
  `nf_characteristic M 1 4 [x1′,w′,x′,t′]` (admissible via `kvE_futRealizer_admissible` at
  its own anchors). σ's three exterior zone lists are singletons (all points of (t′,x1′) /
  {x1′} / (x1′,∞) share one char each since Q is constant off w′), and `kvE_futPos P σ` is
  TRUE at t: the one-item chain walks (t, x1′) ⊆ (t′, x1′) with every item/end/gap conjunct
  realized FREE-ENV at the primed anchors. But every qnf-MARKED σ″ is pinned-realized over
  the real `[·,w,x,t]` (ambient fold), so σ″.1 carries Q-at-w-slot = Q(w) = false, while σ.1
  carries Q-at-w-slot = Q(w′) = true — no marked σ″ can satisfy `kvE_futSliceEq σ″ σ`
  (its first conjunct is `decide (σ″.1 = σ.1)`). Conclusion fails; every antecedent holds
  (including `hreal`/`hexcl`, so no ambient strengthening rescues it). Past mirror symmetric.
- **Isolation (root cause)**: the Phase-3b depth-k bracket ranges over ALL
  `kvE_futAdmissible` σ (ExteriorBracketAssembleK.lean:78-85) — admissibility never mentions
  qnf — whereas the frozen k=2 template it descends from ranges over the
  `kvE2_futMarked qnf`-FILTERED subs (ExteriorBracket.lean:364-372), whose marking includes
  the BASE/fiber agreement with qnf (`kvE2_extBase_of_realizer` component, henv). The
  slice re-key fixed the F ∧ ¬F keying defect but silently WIDENED the conjunction range to
  off-fiber σ; the ⇐-side honesty obligation for an off-fiber admissible σ is exactly the
  undischargeable (false) residue. The probe shows the FIBER-RESTRICTED variant (binder +
  `nfk_dropFresh σ = qnf.1` antecedent) closes GREEN end-to-end with landed suppliers.
- **What is needed** (orchestrator decision — interface repair, Phase-3b territory, out of
  Phase-5 scope): restrict the depth-k bracket range (and hence the carried `hslice*` binder)
  to fiber-compatible admissible σ — e.g. filter by
  `kvE_futAdmissible σ && decide (nfk_dropFresh σ = qnf.1)` (the k=2-faithful range), with
  D1-D4/gate/consumer/KampPrior-mirror re-threaded and the σ-quantified obligations gaining
  the fiber antecedent. Under that range the landed probe route discharges `hslice*` at m=0
  verbatim. The landed `hexclSlice*` supply theorems remain valid (their statements only
  gain an unused antecedent). A same-defect check of D1/D2's slice-level exclusion range and
  the `kvE_extNegFut`-truth obligations should ride along.
- **Prohibited**: `sorry`, vacuous defs, resurrecting `hbr*`, or weakening the supply
  statement below what the consumer binder needs (a fiber-restricted supply theorem CANNOT
  discharge the CURRENT unrestricted binder — do not land one against the current interface).

- **Goal:** Prove the two supply theorems (`kvE_hsliceFut_supply_zero`,
  `kvE_hslicePast_supply_zero`) showing the Phase-3b carried obligations HOLD at m = 0: their
  statements are the 3b binder types instantiated at m := 0, quantified over the ambient —
  signature-locked (copy the binder text verbatim from EndIntervalConsumerK), no design freedom.
  These — NOT the four eliminated `kvE_hbr*_supply_zero` (two provably false) — are the
  interface task 358's `:361` arm and task 349 v8 Phase 6 consume.
- **Bounded unit:** two theorems with fixed statements and a fixed route. *(Phase-3b deviation
  record expanded this to FOUR: + `hexclSliceFut`/`hexclSlicePast`.)*
- **Tasks:**
  - [x] Transcribe the `hsliceFut`/`hslicePast` binder types at m := 0 as theorem statements.
        *(deviation: altered — done as machine PROBES (gate-first, Phase-4a discipline), not
        production: the `hslice*` statements are FALSE as shaped — see BLOCKER. The
        `hexclSlice*` binder types transcribed and LANDED as production statements, verbatim
        at k := 0 + the ambient `hreal` binder per report 02 §3.4.)*
  - [ ] Future proof (report 02 §3.4 + §5 row 2 route): given admissible σ with
        `kvE_futPos` true at t, destruct via `kvE_futChainDestructG` → endpoint x1 +
        `hend`/`hgap`/`hocc` → `kvE_futSliceId_of_end_zero` → marked slice-mate σ' — exactly
        the obligation's conclusion. Past mirror symmetric. *(deviation: BLOCKED — the route
        machine-elaborates except the slice-id's `hfib : nfk_dropFresh σ = qnf.1` input,
        which no binder hypothesis supplies and which cannot be added without the Phase-3b
        interface repair; statement refuted by the ℤ doppelgänger countermodel. See BLOCKER.)*
  - [x] `kvE_hexclSliceFut_supply_zero` (ExteriorPinnedConverseK.lean) +
        `kvE_hexclSlicePast_supply_zero` (ExteriorPinnedConversePastK.lean) — the ⇒-side
        exclusion residue supply pair, route: sliceMarked unpack → `hreal` realizes the
        marked mate → endpoint exterior via admissibility zone read-back →
        `kvE_{fut,past}SliceUnique_zero` collapse → bit contradiction. LANDED GREEN,
        probe-first (three `lean_run_code` probes, zero diagnostics on both `hexclSlice*`).
  - [x] Module docstring cross-referencing task 358 `:361` and task 349 v8 Phase 6 as intended
        consumers, and noting the four `kvE_hbr*_supply_zero` are ELIMINATED (two refuted by
        the (σ′,e) witness — cite `kvE_futPinned_of_end_zero_refuted`). *(both files' Phase-5
        section headers; plus the honest `hslice*` BLOCKED status note)*
  - [x] `#print axioms`; scoped builds; commit. *(both supply theorems exactly
        `[propext, Classical.choice, Quot.sound]`; scoped builds 1025/1028 jobs GREEN; FULL
        `lake build` 1736 jobs GREEN; territory sorry census 0)*
- **Done when:** both supply theorems sorry-free with statements verbatim-matching the carried
  interface at m=0; scoped builds green.
- **Estimated output:** ~100-180 lines.
- **Timing:** 2 hours.
- **Depends on:** 3b (binder shapes), 4 (Past slice-id)
- **File scope:** ExteriorPinnedConverseK.lean, ExteriorPinnedConversePastK.lean.

### Phase 6: Zero-debt gate, full build, wrap-up + downstream flags [NOT STARTED]

- **Goal:** Terminal verification, handoff, and the two mandated downstream flags.
- **Tasks:**
  - [ ] Full `lake build` (whole project) green.
  - [ ] `grep -rn "sorry"` over all touched files → zero NEW hits (KampPrior :361/:364
        pre-existing, task-358 territory); `grep -rn ":= True\|:= trivial"` over new files →
        zero; `#print axioms` on the two slice-id theorems, two uniqueness theorems, two supply
        theorems, re-keyed D1/D3/D4, and `endInterval_step_correct` (⊆ [propext,
        Classical.choice, Quot.sound]).
  - [ ] Grep gate: zero `hbrFutReal|hbrFutSat|hbrPastReal|hbrPastSat` in the consumption chain;
        `kvE_futPinned_of_end_zero_refuted` + salvage lemmas still green and unchanged
        (`git diff --stat` scoped review of preserved assets).
  - [ ] Record the AUDIT flag in `.orchestrator-handoff.json`: the frozen k=2
        `kvE2_extBracketFut` (ExteriorBracket.lean:364) and its 348-era consumers
        (KampPrior:351) use the SAME per-σ keying pattern and must be audited for the same
        unsatisfiability defect — recommend a spawned task; OUT of this task's scope/territory.
  - [ ] Record the consumer note: task 349 v8 Phase 6 and task 358 Phase 3 must consume the
        slice-keyed interface + `kvE_hslice*_supply_zero` (NOT the old `hbr*` shapes).
  - [ ] Update `.orchestrator-handoff.json` (phases_completed, next_action_hint, sorry
        inventory unchanged: only the two pre-existing 358-territory sorries).
  - [ ] Write `summaries/02_faithful-slice-repair-summary.md`: sorry inventory (no new),
        probe verdicts (Phase 0 + 0b), the refutation-to-repair narrative, deviation flags.
- **Done when:** full build green, zero-debt checks pass, both flags recorded, handoff +
  summary written.
- **Estimated output:** ~60-100 lines (summary/handoff).
- **Timing:** 1 hour.
- **Depends on:** 5
- **File scope:** handoff JSON, summary, plan-file status markers only.

## Testing & Validation

- [ ] Phase-exit gate at EVERY open phase: scoped `lake build <touched modules>` green (module
      paths `Theories.Bimodal.Metalogic.WeakCanonical.Kamp.NfMultiAnchorBridge.<File>`); FULL
      `lake build` at Phases 3b and 6.
- [ ] Phase 0b probes P1-P3 are the semantic tests for the repair's three Medium-confidence
      steps (C4/C8/C9); persisted in ExteriorPinnedProbeK.lean.
- [ ] H4 σ′-witness check recorded at Phases 3 and 3b exits (σ′ satisfies, never refutes, each
      new statement; the refutation theorem is the standing regression guard).
- [ ] `#print axioms` (authoritative sorry/axiom audit) on every new/re-proved theorem at its
      phase exit — exactly `[propext, Classical.choice, Quot.sound]`.
- [ ] Consumer regression after 3b and thereafter: D1/D3/D4, gate,
      `bracketEndChar_kvExt_correct_prior`, `endInterval_step_correct`, KampPrior :838-876
      mirror all green; grep gate for eliminated binder names.
- [ ] Commit-per-green-substep (git-workflow mandate): `task 360 phase {P}: {name}` at each
      phase exit; `task 360 phase 3.1/3.2` / `3b.1/3b.2` if split triggers fire.

## Artifacts & Outputs

- plans/02_faithful-slice-repair.md (this file)
- Theories/.../NfMultiAnchorBridge/ExteriorPinnedProbeK.lean (Phase 0b P1-P3 section, appended)
- Theories/.../NfMultiAnchorBridge/ExteriorPinnedConverseK.lean (Phase 3 slice machinery +
  theorems; Phase 5 Future supply; existing Phase-2/3-salvage sections read-only)
- Theories/.../NfMultiAnchorBridge/ExteriorPinnedConversePastK.lean (Phase 3b defs, Phase 4
  theorems, Phase 5 Past supply — new file)
- Re-keyed interface across ExteriorBracketAssembleK / ExteriorGateAssembleK /
  EndIntervalConsumerK / KampPrior.lean:838-876 (Phase 3b)
- specs/360_restate_exterior_hbr_pinned_converse/.orchestrator-handoff.json (updated per phase;
  Phase-6 audit + consumer flags)
- summaries/02_faithful-slice-repair-summary.md (Phase 6)

## Rollback/Contingency

- Every phase ends at a green commit; rollback = revert the last phase commit. Phase 3b is the
  only multi-file interface edit and is atomic within one dispatch (or split at a green 3b.1).
- If Phase 0b fails (P1, P2, or P3): Status → [BLOCKED]; escalation handoff carries the failing
  probe + goal state; no production file has been edited (0b touches only the probe file).
- If Phase 3 blocks on a missing zone supplier: the slice defs + constancy lemma remain a green
  partial; escalate with the exact goal state (probe-gate defect); fix-forward first; never
  destructive git on uncommitted work (`git-snapshot.sh` before any intentional rollback).
- If Phase 3b uncovers an unmapped consumer: pass-through the `hslice*` binder by the same
  pattern; if the consumer genuinely needs per-σ content, [BLOCKED] + escalate (do not
  resurrect per-σ keying).
- Stale 351/354 territory locks on NfMultiAnchorBridge/ were overridden in v1 (>30 min stale);
  this plan's file-scope table remains the ownership record.
