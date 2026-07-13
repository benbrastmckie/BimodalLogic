# Implementation Plan: EndInterval Consumer Reshape (obligation-carrying)

- **Task**: 357 - Reshape the task-349 interval consumer to an obligation-carrying EndIntervalCorrectPrior and fill endIntervalStep
- **Status**: [NOT STARTED]
- **Effort**: 10 hours
- **Dependencies**: 355 (interior gate, green), 356 (general-k hexclExt exterior discharge, green)
- **Research Inputs**: specs/357_reshape_endinterval_consumer_obligation_carrying/reports/01_endinterval-consumer-reshape-shape-and-path.md
- **Artifacts**: plans/01_endinterval-consumer-reshape.md (this file)
- **Standards**: plan-format.md; status-markers.md; artifact-management.md; tasks.md
- **Type**: lean4
- **Lean Intent**: false

## Overview

Reshape the unconditional `EndIntervalCorrect` (`CarrierK1V.lean:2179`) into an obligation-carrying,
depth-cased `EndIntervalCorrectPrior` and fill the sanctioned `⟨[]⟩` placeholder in `endIntervalStep`
(`CarrierK1V.lean:2144`), so that task 349 Phase 5 (`endInterval_step_correct`) closes GREEN. The fill
is depth-cased on the step parameter `{k}` (step maps `k → k+1`): `k=0` uses the interior-only depth-1
rung (task 355); `k=m+1` uses the exterior-composed gate `bracketEndChar_kvExt` (task 356, which
discharges `hexclExt` internally). This forces new `charF` + provider-family params onto
`endIntervalStep`/`endInterval` (the "route the seven provider obligations up to KampPrior" move) and
adds a general-`k` site certificate to `KampPrior.lean` mirroring the k=2 rung. The green deliverable
is an **obligation-carrying** contract — all 11 obligations (7 interior + 4 task-356 exterior) are
**threaded outward**, exactly as tasks 355/356 delivered.

The green scope stops at threading. **Actually discharging** `hreal`/`hexcl`/`hbr*` requires retiring
the still-open `KampPrior.lean:361/364` sorries, which is blocked on the un-landed realization
recursion (`nf_nvar_exist_all_depths` `n≥1` arms) — outside task 357's dependencies. That discharge is
fenced out as a `[BLOCKED]` + spawn milestone (Phase 7), NOT part of the green Definition of Done, and
is **never** to be forced with a `sorry` or vacuous definition (zero-debt gate).

### Research Integration

Plan follows the research report §9 step-ordered wiring path verbatim. Key inputs integrated:
- Reshape shape (§2): 3-arm depth-cased `Prop` mirroring `InteriorGateAllK` (`InteriorGateGeneralK.lean:1239`).
- `endIntervalStep` body fill (§3): depth-cased, dropping the arity-3 IH `rec` (task 355 Phase 7 finding).
- Obligation routing (§4) and discharge-site table (§5): all 11 obligations, landed vs un-landed.
- Import reachability gap (§9.1) and the `CarrierK1V ↔ ExteriorGateAssembleK` cycle risk (§11, Medium).
- Escalation boundary (§7): the "discharge at provider site" DoD item is un-landed at every depth.

### Prior Plan Reference

No prior plan for task 357. Effort calibration and the obligation-carrying discipline are inherited from
the task 355 plan v2 (`specs/355_.../plans/02_interior-gate-deliverable-reshape.md`) and the task 356
summary, both cited by the research report as validated, green, obligation-carrying deliverables. The
same "carry, do not discharge" pattern is reused here.

### Roadmap Alignment

No ROADMAP.md consulted for this dispatch (no roadmap_path / roadmap_flag provided). Parent task 349
(Kamp theorem formalization, Phase 5) is unblocked by the green portion of this plan.

## Goals & Non-Goals

**Goals**:
- Fix the aggregator import reachability gap so `CarrierK1V`/`KampPrior` can see the general-`k` modules; verify no import cycle (else relocate reshaped defs to a new leaf module).
- Reshape `endIntervalStep` (`:2144`) and `endInterval` (`:2159`) to thread `charF` + a provider family; depth-case the `endIntervalStep` body (§3).
- Define `EndIntervalCorrectPrior` as a 3-arm depth-cased obligation-carrying `Prop` (§2).
- Prove `endInterval_step_correct` (task 349 Phase 5) GREEN by consuming the depth-1 interior rung (`k=0`) and `bracketEndChar_kvExt_correct_prior` (`k=m+1`), threading all 11 obligations outward.
- Add the general-`k` site certificate `kampPrior_site_rungK_gate_match` in `KampPrior.lean`, carrying the 11 obligations (mirroring `kampPrior_site_rung2_gate_match:761`).
- Full-tree `lake build` GREEN; axioms of `EndIntervalCorrectPrior` / `endInterval_step_correct` exactly `[propext, Classical.choice, Quot.sound]`.

**Non-Goals**:
- Discharging `hreal`/`hexcl`/`hbr*` at the provider site (the DoD "four extra obligations discharged" phrase). This is the escalation boundary (Phase 7), blocked on the realization recursion.
- Retiring the `KampPrior.lean:361/364` sorries.
- Landing the interior/exterior realizer `hσ` production (Rabinovich Cor 5.4 inf/sup witness selection) — a task 309 Phase 14 successor.
- Any new mathematics: task 357 is a wiring/threading task consuming two already-landed discharge lemmas.

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Filling `endIntervalStep` with `bracketEndChar_kvExt` inverts the `CarrierK1V` ↔ `ExteriorGateAssembleK` import order (cycle) | H | M | Phase 1 verifies acyclicity by `lake build` before any reshape; contingency is to relocate reshaped `endInterval`/`EndIntervalCorrectPrior` to a NEW leaf module below `ExteriorGateAssembleK` (research §9.1, §11). |
| Depth-index misalignment between `endIntervalStep {k}` codomain `k+1` and `bracketEndChar_kvExt {k'}` codomain `k'+2` | H | L | Pin `k' = m` at step-param `k = m+1` (research §6); cross-check against the k=2 member (`k'=0`); confirm `zoneEnv3` defeq (`rfl`) during wiring. |
| Obligation binder types drift from the verbatim `ExteriorGateAssembleK.lean:106-167` statements | M | M | Copy the 4 `hbr*` + 7 interior binders verbatim at the matching depth-index; `hexclExt` is NOT an input binder (discharged internally). |
| Temptation to close the un-landed discharge with a `sorry`/vacuous def to satisfy the DoD phrase | H | M | Hard zero-debt gate: Phase 7 is fenced-out `[BLOCKED]` + spawn; the green DoD is obligation-carrying only. Verify realization availability early (Phase 5 task) and escalate, never sorry. |
| Provider family threading changes `endInterval`'s arity, breaking existing `k=0` base consumer | M | L | Reuse `endInterval_zero_correct` (`:2199`) for the `k=0` arm; adjust its application site to the new signature; keep the depth-0 base carrier unchanged. |
| Axiom leakage (extra axioms beyond the target three) from a consumed lemma | M | L | `lean_verify` on the two target identifiers after Phase 6; trace any extra axiom to its source lemma. |

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
| 7 | 7 | 6 |

Phases within the same wave can execute in parallel. This plan is fully sequential (one phase per wave):
each phase produces a build-green Lean artifact the next consumes. Phase 7 is a fenced-out `[BLOCKED]`
escalation milestone, NOT part of the green Definition of Done.

### Phase 1: Import reachability fix + cycle verification [COMPLETED]

**DECISION (cycle confirmed)**: `ExteriorGateAssembleK` → `InteriorGateGeneralK` → `PriorInterface` → `CarrierKv` → `CarrierK1V` (verified by import grep). `BracketEndCharCarrierV` lives in `CarrierK1V:365`, and `bracketEndChar_kv`/`bracketEndChar_kvExt` live BELOW `CarrierK1V`. Making `CarrierK1V` import `ExteriorGateAssembleK` is therefore circular. Per the pre-planned contingency, the reshaped `endIntervalPrior`/`EndIntervalCorrectPrior`/`endInterval_step_correct` are RELOCATED to a NEW leaf module `NfMultiAnchorBridge/EndIntervalConsumerK.lean` (imports `ExteriorGateAssembleK`). The old `endIntervalStep`/`endInterval`/`EndIntervalCorrect` in `CarrierK1V` (the `⟨[]⟩` placeholder) are dead code (referenced only within `CarrierK1V` itself; nothing external consumes them) — left untouched, harmless, not a sorry/vacuous def.

- **Goal:** Make the general-`k` modules reachable from `CarrierK1V`/`KampPrior`, and settle where the reshaped defs live (in-place vs new leaf) by confirming acyclicity.
- **Tasks:**
  - [ ] Add `ExteriorGateAssembleK` and its transitive deps (`InteriorGateGeneralK`, `ExteriorBracketAssembleK`, `ExteriorConverterK`, `ExteriorConverterPastK`) to the `NfMultiAnchorBridge.lean` aggregator (or a direct `KampPrior` import). Research §9.1: all are acyclic additive leaves.
  - [ ] Verify `ExteriorGateAssembleK` does NOT transitively import `CarrierK1V` (grep the import chain: `ExteriorGateAssembleK` → `InteriorGateGeneralK` → `CarrierKv`/`PriorInterface`).
  - [ ] Add a throwaway probe: make `CarrierK1V` `import`/reference `ExteriorGateAssembleK` and `lake build` the module. If it builds, in-place reshape (Phases 2-4 stay in `CarrierK1V`) is safe.
  - [ ] **Decision gate:** if a cycle appears, record that Phases 2-4 must relocate the reshaped `endInterval`/`EndIntervalCorrectPrior` to a NEW leaf module below `ExteriorGateAssembleK`; update the plan note. Otherwise proceed in-place.
- **Timing:** 1.5 hours
- **Depends on:** none
- **Files to modify:**
  - `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge.lean` - add general-`k` module imports (aggregator line ~47)
  - (probe only) `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge/CarrierK1V.lean` - temporary import to test cycle
- **Verification:**
  - `lake build` of the aggregator + `CarrierK1V` succeeds with the general-`k` modules reachable.
  - Cycle decision recorded (in-place vs new leaf) before Phase 2 begins.

---

### Phase 2: Reshape endIntervalStep + endInterval carrier signatures [COMPLETED]

- **Goal:** Thread `charF` + a provider family through the carriers and depth-case the `endIntervalStep` body; carriers typecheck green (no correctness proof yet).
- **Tasks:**
  - [ ] Add params to `endIntervalStep` (`:2144`): `charF : (j) → NormalForm sig j 1 → Formula` and the provider family `Pfam` (exterior branch source of `Pbr : ExistProviders sig atomMap m`). Drop/ignore the arity-3 IH `rec` (research §3, task 355 Phase 7 finding).
  - [ ] Depth-case the body on `{k}`: `k=0 => bracketEndChar_kv atomMap h_surj charF 1` (interior-only depth-1 rung); `k=m+1 => bracketEndChar_kvExt atomMap h_surj charF (Pbr m)` (task 356 exterior-composed, depth `m+2`).
  - [ ] Confirm depth-index alignment: at `k=m+1`, codomain `BracketEndCharCarrierV sig (k+1) = sig (m+2) = sig (m'+2)` with `m'=m` (research §6). Resolve with `rfl`/index rewrite as needed.
  - [ ] Reshape `endInterval` (`:2159`) to thread `charF` + the provider family through its `Nat.rec` (base `bracketEndChar_k0` unchanged; step = reshaped `endIntervalStep`).
  - [ ] Fix all call sites of `endInterval`/`endIntervalStep` broken by the new arity (including the `k=0` base consumer path).
- **Timing:** 2 hours
- **Depends on:** 1
- **Files to modify:**
  - `.../NfMultiAnchorBridge/CarrierK1V.lean` - `endIntervalStep` body fill + `endInterval` signature threading (or the new leaf module per Phase 1 decision)
- **Verification:**
  - `lake build` green: reshaped `endIntervalStep` and `endInterval` typecheck at all depths.
  - No `sorry`/`admit` introduced; the `⟨[]⟩` placeholder is gone.

---

### Phase 3: Define EndIntervalCorrectPrior (3-arm depth-cased Prop) [COMPLETED]

- **Goal:** State the obligation-carrying correctness motive as a `k`-cased `Prop`; typechecks green (motive only, no proof).
- **Tasks:**
  - [ ] Define `EndIntervalCorrectPrior atomMap h_surj charF : (k : Nat) → Prop` with three arms (research §2):
    - `0 =>` clean depth-0 biconditional (matches `endInterval_zero_correct`), obligation-free.
    - `1 =>` interior-only depth-1 biconditional, carrying only `h0` (charF 0 agreement); no exterior obligation (base rung).
    - `(m+2) =>` full bundle: `∀ qnf` (six order bits on `qnf.1`) `P hcharK Pbr M h_UZ h_SZ x t hreal hexcl hbrPastReal hbrPastSat hbrFutReal hbrFutSat`, `(endInterval … (m+2) qnf).holds ↔ ∃ w, nf_eval_nf …`.
  - [ ] Copy the obligation binder types **verbatim** from `ExteriorGateAssembleK.lean:106-167` at the matching depth-index (`k := m`). `hexclExt` is NOT an input binder (discharged internally by `bracketEndChar_kvExt_correct_prior`).
  - [ ] Confirm the order-bit form transfers without rewrite (`NormalForm.atom_assgn` defeq `qnf.1 (.order …)` at successor depth, research §6).
- **Timing:** 1.5 hours
- **Depends on:** 2
- **Files to modify:**
  - `.../NfMultiAnchorBridge/CarrierK1V.lean` (or the new leaf module) - new `EndIntervalCorrectPrior` def
- **Verification:**
  - `lake build` green: `EndIntervalCorrectPrior` typechecks; all binder types resolve at the successor depth.

---

### Phase 4: Prove endInterval_step_correct (task 349 Phase 5) [COMPLETED]

- **Goal:** Discharge the green Phase-5 obligation by consuming the two landed discharge lemmas and threading all 11 obligations outward.
- **Tasks:**
  - [ ] `k=0` base: reuse `endInterval_zero_correct` (`:2199`) adapted to the reshaped signature.
  - [ ] `k=1` arm: consume the depth-1 interior rung `bracketEndChar_kv_correct_one_prior` (`PriorInterface.lean:95`) / `interiorGateTarget_one` (`:102`); carries `h0` only.
  - [ ] `k=m+2` arm: consume `bracketEndChar_kvExt_correct_prior` (`ExteriorGateAssembleK.lean:106`); THREAD the 7 interior obligations (`P, hcharK, h_UZ, h_SZ, hreal, hexcl`, `hexclExt`-internal) + the 4 `hbr*` outward as hypotheses (do not discharge).
  - [ ] Reconcile the env `Fin.cons w (Fin.cons x (fun _ => t))` against the rung certs' `zoneEnv3 w x t` (`NfZoneDepthK.lean:207`) by `rfl` (research §6).
  - [ ] Prove `endInterval_step_correct` / the `∀ k, EndIntervalCorrectPrior … k` consumer green, sorry-free.
- **Timing:** 2 hours
- **Depends on:** 3
- **Files to modify:**
  - `.../NfMultiAnchorBridge/CarrierK1V.lean` (or the new leaf module) - `endInterval_step_correct` proof
- **Verification:**
  - `lake build` green; `endInterval_step_correct` sorry-free.
  - `lean_verify endInterval_step_correct` axioms ⊆ `[propext, Classical.choice, Quot.sound]`.

---

### Phase 5: Add general-k site certificate in KampPrior [COMPLETED]

- **Goal:** Provide the general-`k` supply site `kampPrior_site_rungK_gate_match` carrying the 11 obligations, mirroring `kampPrior_site_rung2_gate_match:761`, so the reshaped consumer has a uniform per-`qnf` seam for all `k`.
- **Tasks:**
  - [ ] Add `kampPrior_site_rungK_gate_match` in `KampPrior.lean` (analogous to `:761`), restating `bracketEndChar_kvExt_correct_prior`'s biconditional against the per-`qnf` seam and CARRYING the 7+4 obligations (exactly as rung2 carries `hrealI`/`hrealB`/`hexcl`).
  - [ ] Supply the landed inputs from KampPrior: `P`/`Pbr`/`hcharK` via `kampPrior_existProviders_of_ih` (`:895`) + `…_correct` (`:912`) + `…_existF0_char` (`:936`); `h_UZ`/`h_SZ` in scope; six order bits from the seam.
  - [ ] Confirm this general-`k` rung uniformly subsumes the k=2 arm (the `k'=0` member is a direct cross-check against `rung2_gate_match`).
  - [ ] Do NOT touch the `nf_nvar_exist_all_depths:361/364` sorry arms — those consume the carried obligations and remain open (fenced to Phase 7).
- **Timing:** 1.5 hours
- **Depends on:** 4
- **Files to modify:**
  - `.../Kamp/KampPrior.lean` - new general-`k` site certificate (near the rung table `:620-798`)
- **Verification:**
  - `lake build` green; `kampPrior_site_rungK_gate_match` sorry-free (carrying, not discharging, the 11 obligations).
  - The k=2 arm still builds via the general rung (or the existing rung2, unchanged).

---

### Phase 6: Full-tree green verification + axiom audit [COMPLETED]

- **Goal:** Confirm the green Definition of Done: full-tree build GREEN and the two target identifiers have exactly the sanctioned three axioms.
- **Tasks:**
  - [ ] `lake build` full-tree GREEN (no `sorry` introduced by task 357's additions; pre-existing `KampPrior:361/364` sorries remain, fenced to Phase 7).
  - [ ] `lean_verify EndIntervalCorrectPrior` and `lean_verify endInterval_step_correct`: axioms exactly `[propext, Classical.choice, Quot.sound]`.
  - [ ] Grep the touched files to confirm no new `sorry`/`admit`/vacuous placeholder was landed for the discharge.
  - [ ] Confirm task 349 Phase 5 is unblocked (the reshaped `endInterval_step_correct` consumer is green and obligation-carrying).
- **Timing:** 1 hour
- **Depends on:** 5
- **Files to modify:**
  - (none — verification only; minor fixups to any file above if the audit surfaces an axiom leak)
- **Verification:**
  - Full-tree `lake build` GREEN.
  - Axiom sets of both targets equal `[propext, Classical.choice, Quot.sound]`.
  - Zero new `sorry`/`admit` in the diff.

---

### Phase 7: Escalation milestone — full discharge + KampPrior:361 retirement [BLOCKED]

**BLOCKER (Phase 7 — fenced out of the green DoD, resolved as [BLOCKED]+spawn):**
- **What failed / not attempted:** actually DISCHARGING (rather than carrying) `hreal`/`hexcl`/`hbr*` at the provider site.
- **Realization availability check (Phase 5 task, expected NO — CONFIRMED):** `nf_nvar_exist_all_depths` `n≥1` arms remain open sorries at `KampPrior.lean:361` (`|1=>`) and `:364` (`|n+2=>`) — the genuine interior/exterior realizer `hσ` is NOT produced anywhere in the tree.
- **Why stuck (root cause):** `kvE_{fut,past}Bundle_of_realizer` (`ExteriorConverterK.lean:208` / `ExteriorConverterPastK.lean:177`) is a CONVERTER only — it needs a genuine realizer `hσ : nf_eval_nf M (m+1) 4 [x1,w,x,t] σ` to yield the `hbr*` conjuncts. Producing `hσ` is the un-landed realization mathematics (Rabinovich Cor 5.4 inf/sup within-bracket bounded witness selection), a task-309 Phase-14 successor OUTSIDE task 357's dependencies (355, 356).
- **What is needed:** land the `nf_nvar_exist_all_depths` `n≥1` arms (retire `:361`/`:364`), then discharge the eleven carried obligations via the provider instantiation.
- **SPAWNED:** task **358** (`realization_recursion_nf_nvar_exist_all_depths`, `parent_task 349`, `dependencies [357]`) recorded in `specs/state.json`. Consumers ready + green: `endInterval_step_correct`/`EndIntervalCorrectPrior` (`EndIntervalConsumerK.lean`) and `kampPrior_site_rungK_gate_match` (`KampPrior.lean`).
- **Zero-debt honored:** NO `sorry`, NO vacuous def, NO new axiom was landed for the discharge. The pre-existing `KampPrior:361/364` sorries are untouched (not a regression).

- **Goal:** Explicitly fence out the DoD phrase "four extra obligations discharged at the provider site." This is the escalation boundary: NOT part of the green Definition of Done, and NEVER to be forced with a `sorry` or vacuous definition.
- **Status rationale:** `hreal`/`hexcl`/`hbr*` are un-discharged at EVERY depth (even the k=2 rung carries them un-discharged, consumed only by the open `KampPrior:361/364` sorries). Discharging them requires producing a genuine realizer `hσ` for `kvE_{fut,past}Bundle_of_realizer` to convert — the un-landed realization recursion (`nf_nvar_exist_all_depths` `n≥1` arms; Rabinovich Cor 5.4 inf/sup witness selection). This is a task 309 Phase 14 successor, outside task 357's dependencies (355, 356).
- **Tasks (do NOT execute as part of the green deliverable):**
  - [ ] Early during Phase 5, verify whether the realization content is available at the `nf_nvar_exist_all_depths` recursion. Expected: NO.
  - [ ] If unavailable (expected): mark the full-discharge / `KampPrior:361` retirement milestone `[BLOCKED]` and SPAWN a realization-recursion task (`/spawn 357 "realization recursion: land nf_nvar_exist_all_depths n≥1 arms to produce interior/exterior realizer hσ (Rabinovich Cor 5.4 inf/sup witness selection); retires KampPrior:361/364 sorries and enables discharging hreal/hexcl/hbr* at the provider site"`).
  - [ ] Record the spawned task number as a dependency-forward link on task 357's escalation and on parent task 349.
  - [ ] Do NOT land a `sorry` or vacuous definition to force the discharge (zero-debt gate; research §7 escalation clause).
- **Timing:** N/A (blocked; spawn only)
- **Depends on:** 6
- **Blocked:** un-landed realization recursion (`nf_nvar_exist_all_depths` `n≥1` arms) — not among task 357's dependencies.
- **Verification:**
  - A realization-recursion task exists in state.json (spawned), linked from task 357/349.
  - No `sorry`/vacuous definition was landed for the discharge.

## Testing & Validation

- [ ] Full-tree `lake build` GREEN after Phase 6.
- [ ] `lean_verify EndIntervalCorrectPrior` axioms exactly `[propext, Classical.choice, Quot.sound]`.
- [ ] `lean_verify endInterval_step_correct` axioms exactly `[propext, Classical.choice, Quot.sound]`.
- [ ] `endIntervalStep` `⟨[]⟩` placeholder removed; depth-cased body typechecks at k=0 and k=m+1.
- [ ] `EndIntervalCorrectPrior` is a 3-arm depth-cased `Prop` with the 11-obligation successor arm.
- [ ] All 11 obligations threaded outward (carried), none discharged with a `sorry`/vacuous def.
- [ ] General-`k` site certificate `kampPrior_site_rungK_gate_match` builds and subsumes the k=2 arm.
- [ ] Task 349 Phase 5 (`endInterval_step_correct`) is unblocked (green, obligation-carrying).
- [ ] No import cycle (or reshaped defs relocated to a new leaf module per Phase 1 decision).
- [ ] Escalation milestone (Phase 7) recorded `[BLOCKED]` + realization-recursion task spawned; zero debt landed.

## Artifacts & Outputs

- `plans/01_endinterval-consumer-reshape.md` (this file)
- `summaries/01_endinterval-consumer-reshape-summary.md` (produced by /implement)
- Modified: `.../Kamp/NfMultiAnchorBridge.lean` (import reachability)
- Modified: `.../NfMultiAnchorBridge/CarrierK1V.lean` (reshaped `endIntervalStep`/`endInterval`, new `EndIntervalCorrectPrior`, `endInterval_step_correct`) — OR a new leaf module if Phase 1 finds a cycle
- Modified: `.../Kamp/KampPrior.lean` (general-`k` site certificate)
- Spawned: realization-recursion task (Phase 7 escalation)

## Rollback/Contingency

- Each phase is a self-contained build-green Lean edit committed on success (commit-per-green-substep). Revert the offending phase's commit to roll back without losing prior phases.
- If Phase 1 finds an import cycle, the contingency is pre-planned: relocate the reshaped `endInterval`/`EndIntervalCorrectPrior`/`endInterval_step_correct` to a NEW leaf module below `ExteriorGateAssembleK` rather than editing `CarrierK1V` in place (research §9.1). `KampPrior` imports the new leaf.
- If any green phase cannot close without a `sorry`, STOP and mark task 357 `[BLOCKED]` + escalate (do not land debt), per the task's zero-debt gate — the same discipline as Phase 7.
- The pre-existing `KampPrior:361/364` sorries are untouched by this task and are not a regression; they are the fenced-out Phase 7 boundary.
