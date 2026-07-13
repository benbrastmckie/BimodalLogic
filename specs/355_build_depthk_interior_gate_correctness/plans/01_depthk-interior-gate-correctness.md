# Implementation Plan: Task #355 — depth-k interior gate correctness

- **Task**: 355 - Build the depth-k INTERIOR gate correctness lemma `bracketEndChar_kv_correct` (general k, by recursion)
- **Status**: [NOT STARTED]
- **Effort**: ~20 hours (7 phases; deflection-prone formal task, hard-mode phase sizing)
- **Dependencies**: None (self-contained; all cited templates/clause-layer assets already committed and frozen)
- **Research Inputs**: specs/349_.../reports/11_recent-completion-consumption.md; specs/349_.../reports/12_spawn-analysis.md; specs/349_.../.orchestrator-handoff.json; specs/349_.../plans/08_consume-depthk-clause-layer.md (Phase 5-7 RESUME POINT)
- **Artifacts**: plans/01_depthk-interior-gate-correctness.md (this file)
- **Standards**: plan-format.md; status-markers.md; artifact-management.md; tasks.md; lean4.md
- **Type**: lean4
- **Lean Intent**: false

## Overview

Task 349 Phases 5-7 are blocked on a single undelivered piece of mathematics: the depth-`k`
INTERIOR gate correctness for arbitrary `k`. The depth-`k` carrier `bracketEndChar_kv`
(`CarrierKv.lean:238`) exists, but its correctness is delivered only at the recursion base rungs
k=0 (`bracketEndChar_kv_correct_zero`, `CarrierKv.lean:367`) and k=1 (`bracketEndChar_kv_correct_one`,
`CarrierKv.lean:395`). `CarrierKv.lean:22` records the general-`k` gap directly ("Correctness ... is
NOT attempted here"). This task delivers the general-`k` interior gate correctness lemma green,
sorry-free, and axiom-clean, so task 349 Phase 5 can fill the `endIntervalStep` body
(`CarrierK1V.lean:2144`, currently the sanctioned `⟨[]⟩` empty-disjunction placeholder) and Phases
6-7 can induct on it. Work is **additive** in a NEW sibling module
`NfMultiAnchorBridge/InteriorGateGeneralK.lean` — task 349's frozen files stay byte-identical.

### Research Integration

- **Report 11 (§1e, §5)** confirms the depth-`k` clause/bracket layer (351/352/354) is green,
  committed, sorry-free, and axiom-clean at exactly `[propext, Classical.choice, Quot.sound]`; the
  guards G1-G5 pass on the consumption path. That layer is the EXTERIOR residue — it does NOT
  supply the interior gate. This task is the interior half.
- **Report 12 (spawn analysis)** root-causes this as "Technical unknowns / undelivered open
  construction" (~700-1300 proof lines across the interior gate + its consumption), NOT enabled by
  351/352/354.
- **Handoff JSON** fixes the axiom target and the `endIntervalStep` hole location.

### Prior Plan Reference

No prior plan exists for task 355 (this is round 1). The parent task 349's plan v8 Phase 5-7 RESUME
POINT is the primary calibration source: it estimates ~700-1300 lines for the interior gate + its
consumption, describes the k=2 template (`bracketEndChar_kvE2` and its `_sound`/`_complete` halves,
hardwired to depth-1 subs), and states the interior gate is the open frontier. This plan carves the
interior-gate half (this task) out of that estimate: ~7 additive phases, each bounded to one agent
run.

### Roadmap Alignment

No ROADMAP.md consulted (roadmap flag not set). This task advances the parent task 349 recursion
(recursive navigated arity-3 endpoint primitive `endChar`) by delivering its blocking interior lemma.

### CRITICAL feasibility note — the statement must be PROVIDER-GUARDED (F1)

`bracketEndChar_kv_factors` (`CarrierKv.lean:422`) proves the depth-`k` carrier factors through
ONLY the atom layer + the off-fiber Prop + the fiber-EXISTENTIAL fold bits: two quant layers
agreeing on that data yield EQUAL carriers even when they disagree on the marking of individual
depth-`k` arity-4 subs inside a shared `(zoneSpec, projFresh)` fiber. Its docstring records that
this **refutes the UNCONDITIONAL k≥2 soundness direction** (the plan-v5 Phase 13 target). Therefore
the general-`k` deliverable is NOT the unconditional shape of `_correct_zero`/`_correct_one`. It is
the **provider-guarded** shape — mirroring the k=2 template `bracketEndChar_kvE2_sound_two_prior_frag`
(`OuterGate.lean:268`) / `bracketEndChar_kvE2_complete_two_prior` (`OuterGate.lean:147`) and the
consumer's `EndIntervalCorrectPrior` (task 349 Phase 5): under `semantic_prior_UZ`/`semantic_prior_SZ`
and the depth-`k` provider obligations (`P : ExistProviders sig atomMap k`, `PriorInterface.lean:38`),
the provider obligations supply exactly the fiber information F1 shows is not intrinsic to the
carrier, so soundness is recovered. Phase 1 freezes this shape before any proof work. Attempting an
unconditional general-`k` statement is a known dead end (F1) and MUST NOT be pursued.

## Goals & Non-Goals

**Goals**:
- Deliver a general-`k` interior gate correctness lemma (working name `bracketEndChar_kv_correct_prior`)
  green, sorry-free, axiom-clean (`[propext, Classical.choice, Quot.sound]`), consumable by task 349
  Phase 5 to fill the `endIntervalStep` body and by Phases 6-7 to induct on.
- Encode the recursion explicitly: base k=0/k=1 (already delivered, consumed not rebuilt) → inductive
  step k→k+1 (the substantial construction) → general-`k` close by induction.
- Keep every task-349 frozen file byte-identical at every commit.

**Non-Goals**:
- NOT filling task 349's `endIntervalStep` body (`CarrierK1V.lean:2144`) — that is task 349 Phase 5's
  consumption step; this task only supplies the lemma it consumes.
- NOT editing CarrierKv.lean or CarrierK1V.lean (recommended: land in the new sibling module so the
  349-owned `endIntervalStep`/`endInterval` re-freeze does not conflict).
- NOT re-deriving the depth-`k` clause/bracket layer (351/352/354) or the Rabinovich lemmas — cite
  and consume only.
- NOT attempting an unconditional (non-provider-guarded) general-`k` statement (refuted by F1).

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Freezing the wrong (unprovable/unconditional) general-`k` statement | H | M | Phase 1 dedicated to statement freeze; validate by discharging k=0/k=1 instances of the frozen Prop against `_correct_zero`/`_correct_one` before any step proof; mirror the k=2 `_..._two_prior` shape and the consumer `EndIntervalCorrectPrior` verbatim |
| Soundness (⇒) direction blocks on F1 information loss | H | M | Provider obligations reconstruct the lost fiber content (mirror `bracketEndChar_kvE2_sound_two_prior_frag`); if it blocks, mark [BLOCKED] with `lean_goal` — the statement is guarded and NON-refuted, a block is a construction gap not a carrier question |
| Phase overruns one agent run (~500 lines) | M | M | Pre-declared split points (Phases 4, 5 split a/b); commit each green sub-piece; H8 phase sizing |
| Accidental frozen-file edit | H | L | Per-phase acceptance criterion: `git diff` on all 10 frozen paths EMPTY; land in NEW module only |
| Forbidden `nf_char3_deeper_split` route creeps in | H | L | Per-phase grep audit; refuted route (report 02 §4.1) |
| New leaf module not built by full-tree `lake build` | M | M | Scoped `lake build <module>` is the authoritative per-phase gate; note import wiring for the consumer/full-tree check in Phase 7 |
| Rabinovich chain step bypassed by simp/omega/aesop (G5) | M | M | Manual bridges only; per-phase G5 audit; literature-fidelity policy |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2, 3 | 1 |
| 3 | 4 | 2, 3 |
| 4 | 5 | 4 |
| 5 | 6 | 4, 5 |
| 6 | 7 | 6 |

Phases within the same wave can execute in parallel. **H7 territory note**: Phases 2 and 3 both
append to the single new module `InteriorGateGeneralK.lean`. If dispatched in parallel they MUST
own disjoint declaration blocks (Phase 2 = provider/char bridges section; Phase 3 = holds_iff
section) or be serialized; otherwise run sequentially. Phases 4 and 5 are serialized (5 depends on
4) specifically so the easier completeness direction lands and commits as a green milestone first.

**Global per-phase acceptance criteria** (apply to EVERY phase; carried verbatim from task 349):
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

**Goal**: Create the new module and FREEZE the provable general-`k` statement shape
(`bracketEndChar_kv_correct_prior`), reconciling the F1 factors-refutation with the provider-guarded
shape the consumer expects. Statement compiles sorry-free; k=0/k=1 instances discharge against the
existing base lemmas.

**Tasks**:
- [x] Create `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge/InteriorGateGeneralK.lean`
      importing `CarrierKv` (for `bracketEndChar_kv`, `bracketEndChar_kv_correct_zero/_one`,
      `bracketEndChar_kv_factors`) and `PriorInterface` (for `ExistProviders`), plus the OuterGate
      template family for reference (import only what is needed; do not edit it).
- [x] State `bracketEndChar_kv_correct_prior` as a `Prop`/theorem statement mirroring the k=2
      `bracketEndChar_kvE2_sound_two_prior_frag` (`OuterGate.lean:268`) + `_complete_two_prior`
      (`OuterGate.lean:147`) hypothesis package generalized to depth `k`: `P : ExistProviders sig
      atomMap k`, `semantic_prior_UZ`/`semantic_prior_SZ`, the six k0-mirror bracket-zone order bits
      on `qnf`'s atom layer, and the provider-agreement hypothesis `charF 0 = nf_depth0_char_formula
      …` — concluding `(bracketEndChar_kv atomMap h_surj charF (k) qnf).holds M atomMap x t ↔ ∃ w,
      nf_eval_nf M k 3 (Fin.cons w (Fin.cons x (fun _ => t))) qnf`. Align the hypothesis names to the
      consumer's `EndIntervalCorrectPrior` (task 349 Phase 5) so the lemma drops in.
- [x] Compile the statement sorry-free (statement-only; proof deferred to Phases 4-6). Write a
      docstring recording the F1 rationale (why guarded, not unconditional) with the
      `bracketEndChar_kv_factors` citation.
- [x] Reconcile base rungs: prove/confirm the k=0 and k=1 instances of the FROZEN statement discharge
      from `bracketEndChar_kv_correct_zero` (:367) / `bracketEndChar_kv_correct_one` (:395) (the
      provider obligations are trivially/vacuously satisfiable at the base, or the guarded statement
      weakens to the unconditional base cleanly). This validates the freeze BEFORE the step proof.

**Timing**: ~2.5 hours. **Estimated output**: ~150-250 lines.

**Depends on**: none

**Files to modify**: `NfMultiAnchorBridge/InteriorGateGeneralK.lean` (NEW).

**Verification**: statement + base-rung reconciliation lemmas compile green; scoped build GREEN;
`lean_verify` axiom-clean on the base-rung reconciliation; frozen diffs EMPTY; the frozen statement
is byte-quotable for the consumer. **BLOCKED-escalation**: if the guarded statement cannot be made to
discharge the base rungs, STOP — the freeze is wrong; capture the mismatch and escalate before
proceeding (do not build a step proof on an unvalidated statement).

---

### Phase 2: Depth-k provider / char-layer truth bridges [COMPLETED]

**Goal**: Generalize the k=2 char-formula truth bridges `bracketEndChar_kvE2_hcb`
(`OuterGate.lean:102`) and `_hck` (`OuterGate.lean:123`) to depth `k`: the atom-layer bridge
`temporal_truth M atomMap u (charF k χ) ↔ nf_eval_nf M k 1 (fun _ => u) χ` under `ExistProviders.correct`
+ `semantic_prior_UZ`/`SZ` and the `Fin 0` env collapse.

**Tasks**:
- [x] Prove the depth-`k` provider-layer bridge from `P.correct` (`PriorInterface`) — the general-`k`
      analog of `_hck` (`OuterGate.lean:123-139`), using the `insertEnv`/`Fin.elim0` env collapse.
- [x] Prove/thread the depth-0 char-base bridge (`_hcb` analog) via `nf_depth0_char_formula_correct`
      for the fiber's atom layer, at the `charF 0 = nf_depth0_char_formula` agreement from Phase 1.
- [x] Confirm these bridges compose to the per-fiber point-type truth equivalence the step proof
      (Phases 4-5) consumes.

**Timing**: ~2.5 hours. **Estimated output**: ~120-250 lines.

**Depends on**: 1

**Files to modify**: `NfMultiAnchorBridge/InteriorGateGeneralK.lean` (additive; provider/char-bridge
section).

**Verification**: both bridges green + sorry-free; `lean_verify` axiom-clean; scoped build GREEN;
frozen diffs EMPTY; G5 (manual, no chain-step shortcut). **BLOCKED-escalation** as global.

---

### Phase 3: Body-destructuring `holds_iff` at depth k [NOT STARTED]

**Goal**: Expose the successor carrier's `.holds` structurally — the general-`k` analog of the k=2
body-extraction path (`kvE2_sepBody_extract` and the `holds` unfolds used by `_two_prior`) — as the
conjunction of the off-fiber gate and the per-fiber fold-bit disjunction, so Phases 4-5 can prove
each direction. Keep the fold-bit read FIBER-EXISTENTIAL (per `bracketEndChar_kv`'s definition at
`CarrierKv.lean:248`); do NOT collapse it to a pointwise read (that collapse is only valid at k=1
via `bracketEndChar_kv_one_eq` and is exactly the information F1 says is lost at k≥2).

**Tasks**:
- [ ] Prove a `bracketEndChar_kv_succ_holds_iff` lemma: `(bracketEndChar_kv … (k+1) qnf).holds M
      atomMap x t` unfolds (via `kv_body`, `VVecEA2.holds`) to the off-fiber gate conjunct ∧ the
      disjunction over fiber `(zoneSpec, projFresh)` classes of realized-marked subs.
- [ ] Prove the fiber-witness extraction/introduction helpers (the general-`k` analog of the `hbit`
      lemma inside `bracketEndChar_kv_one_eq`, `CarrierKv.lean:304`, but kept existential): from a
      fold bit = true recover a witnessing sub with matching `nf0_zoneSpec`/`nfk_projFresh`; and the
      converse introduction.
- [ ] Confirm the destructuring composes with Phase 2's point-type bridges.

**Timing**: ~3 hours. **Estimated output**: ~150-300 lines.

**Depends on**: 1

**Files to modify**: `NfMultiAnchorBridge/InteriorGateGeneralK.lean` (additive; holds_iff section).

**Verification**: `holds_iff` + fiber helpers green + sorry-free; `lean_verify` axiom-clean; scoped
build GREEN; frozen diffs EMPTY; G1 (fiber classification is the sanctioned bucketing, not interior
collapse). **BLOCKED-escalation** as global.

---

### Phase 4: Inductive step — ⇐ completeness (realizer → carrier holds) [NOT STARTED]

**Goal**: Prove the completeness half of the k→k+1 step (`bracketEndChar_kv_step_complete`): from
`∃ w, nf_eval_nf M (k+1) 3 (Fin.cons w (Fin.cons x (fun _ => t))) qnf` conclude `(bracketEndChar_kv …
(k+1) qnf).holds M atomMap x t`, using the inductive hypothesis (depth-`k` correctness) for the
sub-piece characteristics. This is the direction NOT obstructed by F1 (a genuine realizer supplies
the fiber content), so it lands first as a green milestone.

**Tasks**:
- [ ] From the realizer, apply Phase 3's `holds_iff` introduction: discharge the off-fiber gate
      conjunct (a genuine evaluation lives on `qnf.1`'s fiber) and produce each required fiber fold
      bit existentially from the realizer's own marked subs.
- [ ] Thread the IH (depth-`k` `bracketEndChar_kv_correct_prior` at the sub-pieces) and Phase 2's
      point-type bridges to realize interior content at FULL arity (G1); cite Rabinovich Cor 5.4
      (endpoint characteristic chain) for the per-fiber reconstruction shape.
- [ ] Pre-declared split guard: if this overruns one agent run, split 4a (off-fiber gate + fiber
      bits) / 4b (IH threading + interior realization); commit 4a green first.

**Timing**: ~3.5 hours. **Estimated output**: ~200-400 lines (split 4a/4b if overrunning).

**Depends on**: 2, 3

**Files to modify**: `NfMultiAnchorBridge/InteriorGateGeneralK.lean` (additive).

**Verification**: `bracketEndChar_kv_step_complete` green + sorry-free; `lean_verify` axiom-clean;
scoped build GREEN; frozen diffs EMPTY; G1-G5 audit; FORBIDDEN grep clean. **BLOCKED-escalation**: the
statement is non-refuted; a block is a construction gap — capture `lean_goal`, commit any green
sub-piece, escalate.

---

### Phase 5: Inductive step — ⇒ soundness (carrier holds + provider obligations → realizer) [NOT STARTED]

**Goal**: Prove the soundness half of the k→k+1 step (`bracketEndChar_kv_step_sound`): under
`semantic_prior_UZ`/`SZ` and the depth-`k` provider obligations, from `(bracketEndChar_kv … (k+1)
qnf).holds M atomMap x t` conclude `∃ w, nf_eval_nf M (k+1) 3 [w,x,t] qnf`. **This is the F1-critical
direction**: the carrier's fold data is lossy (`bracketEndChar_kv_factors`), so the realizer is
reconstructed using the provider obligations, which supply the exact fiber content F1 shows is not
intrinsic. Mirror `bracketEndChar_kvE2_sound_two_prior_frag` (`OuterGate.lean:268`) one fold-layer
deeper, threading the IH.

**Tasks**:
- [ ] Destructure the carrier via Phase 3's `holds_iff`; extract the off-fiber gate + the fiber
      fold bits.
- [ ] Reconstruct interior point types via the depth-`k` provider (`P.existF`) and Phase 2 bridges;
      realize the interior segment at FULL arity 4 (G1); use the IH (depth-`k` correctness) for the
      sub-piece realizers.
- [ ] Assemble the arity-3 realizer `nf_eval_nf M (k+1) 3 [w,x,t] qnf` at the bracket witness `w`;
      manual Rabinovich Cor 5.4 chain bridges (G5, no simp/omega/aesop shortcut).
- [ ] Pre-declared split guard: if this overruns one run, split 5a (destructure + point-type
      reconstruction) / 5b (interior realization + realizer assembly); commit 5a green first.

**Timing**: ~4 hours. **Estimated output**: ~300-500 lines (split 5a/5b if overrunning).

**Depends on**: 4

**Files to modify**: `NfMultiAnchorBridge/InteriorGateGeneralK.lean` (additive).

**Verification**: `bracketEndChar_kv_step_sound` green + sorry-free; `lean_verify` axiom-clean; scoped
build GREEN; frozen diffs EMPTY; G1-G5 audit; FORBIDDEN grep clean; confirm no provider obligation
leaks past the step gate. **BLOCKED-escalation**: if soundness blocks, capture the exact `lean_goal`,
record that the block is a construction gap under the guarded (non-refuted) statement, `/spawn 355`
for the specific missing sub-lemma; commit any green sub-piece.

---

### Phase 6: Step assembly + general-k recursion close [NOT STARTED]

**Goal**: Assemble the step biconditional `bracketEndChar_kv_step_correct` = ⟨sound (Phase 5),
complete (Phase 4)⟩ at symbolic `k+1`, then prove the general-`k` deliverable
`bracketEndChar_kv_correct_prior` (∀ `k`) by induction on `k`: base k=0/k=1 via the Phase-1
reconciliation of `bracketEndChar_kv_correct_zero`/`_one`, step via the Phase 4+5 gate with the IH
supplying the depth-`k` characterization.

**Tasks**:
- [ ] Assemble `bracketEndChar_kv_step_correct` (the k+1 biconditional) from Phases 4-5.
- [ ] Prove the general-`k` `∀ k` statement by `Nat.rec`/induction: wire the base rung(s) from Phase
      1 and the step from the assembled gate; confirm the IH is the depth-`k` instance the step
      consumes.
- [ ] Confirm the delivered lemma's conclusion is byte-quotable as the interior obligation the task
      349 Phase 5 `endIntervalStep` body / `EndIntervalCorrectPrior` consumes (shape match).

**Timing**: ~3 hours. **Estimated output**: ~150-300 lines.

**Depends on**: 4, 5

**Files to modify**: `NfMultiAnchorBridge/InteriorGateGeneralK.lean` (additive).

**Verification**: `bracketEndChar_kv_step_correct` + the general-`k` `bracketEndChar_kv_correct_prior`
green + sorry-free; `lean_verify` axiom-clean on the top-level lemma; scoped build GREEN; frozen diffs
EMPTY. **BLOCKED-escalation** as global.

---

### Phase 7: Axiom audit + full-tree build + consumability check [NOT STARTED]

**Goal**: Final gate. Confirm the deliverable meets the Definition of Done and is consumable by task
349.

**Tasks**:
- [ ] `lean_verify` the top-level general-`k` lemma: axioms EXACTLY `[propext, Classical.choice,
      Quot.sound]`; grep the whole new module for `sorry`/`admit` (must be 0) and for vacuous
      `True`/`Unit`/`trivial` defs (must be 0).
- [ ] `git diff` on all 10 frozen paths (seven providers + `KampPrior.lean` + `ExteriorBracketK.lean`
      + `PriorInterface.lean`) and on `CarrierKv.lean`/`CarrierK1V.lean`/`ExteriorBracketAssembleK.lean`
      — all EMPTY.
- [ ] FORBIDDEN `nf_char3_deeper_split` grep clean; G1-G5 route audit recorded.
- [ ] Wire the new module into the build closure (import from the appropriate root so full-tree
      `lake build` compiles it) OR record the scoped-build gate + the exact import line task 349
      Phase 5 must add; run `lake build` (full-tree recommended per DoD).
- [ ] Write an `example`-check (or documented shape match) confirming task 349 Phase 5 can cite the
      lemma for the interior half of the `endIntervalStep` body.

**Timing**: ~1.5 hours. **Estimated output**: ~50-150 lines (mostly audit + example).

**Depends on**: 6

**Files to modify**: `NfMultiAnchorBridge/InteriorGateGeneralK.lean` (additive example/audit); build
manifest/root import if wiring for full-tree.

**Verification**: axioms exactly `[propext, Classical.choice, Quot.sound]`; sorry-free; frozen diffs
EMPTY; FORBIDDEN grep clean; scoped build GREEN (full-tree GREEN if wired); consumability example
green. **BLOCKED-escalation** as global.

## Testing & Validation

- [ ] `lake build Bimodal.Metalogic.WeakCanonical.Kamp.NfMultiAnchorBridge.InteriorGateGeneralK`
      GREEN at every phase end (scoped, authoritative gate for the new leaf module).
- [ ] `lake build` (full-tree) GREEN at Phase 7 (recommended per DoD; requires the module wired into
      the import closure).
- [ ] `lean_verify` on the top-level general-`k` lemma reports EXACTLY `[propext, Classical.choice,
      Quot.sound]`.
- [ ] `grep -rn "sorry\|admit"` on the new module: 0 matches; no vacuous `True`/`Unit`/`trivial` defs.
- [ ] `git diff` on all frozen paths: EMPTY at every commit.
- [ ] `grep -rn "nf_char3_deeper_split"` on the new module: 0 matches (FORBIDDEN route).
- [ ] Guards G1-G5 audit passes on every new lemma.
- [ ] Consumability: an `example`/shape-match shows task 349 Phase 5 can cite the lemma for the
      interior half of `endIntervalStep`.

## Artifacts & Outputs

- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge/InteriorGateGeneralK.lean` (NEW):
  the frozen general-`k` statement, provider/char bridges, `holds_iff`, the ⇐/⇒ step halves, the step
  biconditional, and the general-`k` `bracketEndChar_kv_correct_prior` (top-level deliverable).
- `specs/355_build_depthk_interior_gate_correctness/plans/01_depthk-interior-gate-correctness.md`
  (this plan).
- `specs/355_build_depthk_interior_gate_correctness/summaries/01_*-summary.md` (on completion).
- `specs/355_build_depthk_interior_gate_correctness/.orchestrator-handoff.json` (planned/updated).

## Rollback/Contingency

- Work is entirely additive in ONE new module. To revert, delete/blank `InteriorGateGeneralK.lean`
  (and any import wiring added in Phase 7); no frozen file is ever touched, so no other module is
  affected.
- If a phase blocks: mark it `[BLOCKED]`, capture the exact `lean_goal`, commit any already-green
  sub-piece (green-substep mandate), and escalate per the lean4 vacuous-definitions/escalation rule
  (`status: partial`, `requires_user_review: true`, or `/spawn 355` for the specific missing
  sub-lemma). Never land a `sorry`, a vacuous `True`/`Unit`/`trivial`, or an empty-disjunction
  placeholder in a lemma claimed proved.
- Because the deliverable is a leaf consumed only by task 349 Phase 5 (not yet wired), a block leaves
  the rest of the tree green; task 349 stays [BLOCKED] on 355 exactly as it is now.
