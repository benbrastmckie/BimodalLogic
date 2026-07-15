# Recommendations & Handoff — M2 spawn + task-358 dependency freeze

Task: 369 — M1 endpoint `kvE_futPos` supply / break render cycle
Session: sess_1784091172_81406c · Agent: lean-implementation-hard-agent (H2/H9)
Date: 2026-07-14
Phase: 2 (final) of plan `plans/01_m2-scope-and-document.md`
Source of record: `reports/01_m1-endpoint-firing-adjudication.md` (VERDICT: M1 NOT PROVABLE),
`reports/02_m2-carrier-redesign-scope.md` (authoritative M2 scope)

> **Scope of this document.** This is the recommendation artifact that closes task 369. It records
> two orchestration actions the M2 verdict implies. **Actual task creation and `specs/state.json`
> dependency edits are performed by the orchestrator/implementer (via `/spawn` or `/task`), NOT by
> this documentation phase.** Everything below is copy-paste ready for that downstream execution.

---

## Action (a) — Spawn the M2 carrier-redesign execution task

This is the task that will actually **build the de-folded interior carrier**. Task 369 only scoped
and documented it (`reports/02`); M2 execution was explicitly OUT OF SCOPE for task 369.

### Copy-paste-ready task descriptor

- **Title**: `M2: de-folded interior carrier redesign — carry full arity-4 fiber (execute reports/02 scope)`
- **Task type**: `lean4`
- **Source of truth (scope)**: `specs/369_m1_endpoint_kvE_futPos_supply_break_render_cycle/reports/02_m2-carrier-redesign-scope.md`
  (grounded in `reports/01_m1-endpoint-firing-adjudication.md`; literature: `rabinovich_2014`
  Cor 5.4(1)⇐).
- **Sizing**: **multi-phase**, explicitly larger than task 369 (a carrier-redesign refactor crossing
  the frozen-carrier boundary — `reports/02` §6).

- **Description** (verbatim, copy-paste ready):

  > Build the de-folded interior carrier (M2) per the authoritative scope in task 369's
  > `reports/02_m2-carrier-redesign-scope.md`. M1 (`kvE_futPos_supply_of_endpoint`) is REFUTED
  > (task 369 `reports/01`, HIGH confidence): the `igFoldBit` fold
  > (`InteriorGateGeneralK.lean:318-332`) lossily ∃-projects the arity-4 fiber `sub : NF sig k 4`
  > down to the arity-1 pair `(zone, nfk_projFresh sub)`, so the endpoint eval cannot rebuild the
  > full arity-4 `σ`-realizer the driver `kampPrior_futRealizer_of_pos` (`KampPrior.lean:1662`)
  > demands. The paper-faithful fix (Rabinovich Cor 5.4(1)⇐, `reports/01` finding #13) is to carry
  > the whole ordered fiber and never fold. Re-key `igEpL`/`igEpR`/`igPtW`
  > (`InteriorGateGeneralK.lean:209/219/243`) and replace/parallel `igFoldBit` (:318) with a
  > non-projecting fiber-carrying selector, feed the de-folded carrier through `igBody` (:290) and
  > `igMkDisjunct` (:276), replace the render-gated bridge `igFoldBit_realize_iff` (:563) with a
  > de-folded `endpoint → arity-4 realizer` extraction, re-type the render production
  > (`ExteriorGateAssembleK.lean:337-338`) and the row-5/6 `hreal`/`hexcl` binders
  > (`KampPrior.lean:955-1000`), re-wire the realizer drivers `kampPrior_{fut,past}Realizer_of_pos`
  > (`KampPrior.lean:1662/1721`), then discharge the downstream leaves
  > (`kampPrior_hreal_supply` `InteriorHrealSupplyK.lean:116` strategic sorry; the rows-12-13
  > general-`m` arms `ExteriorDeepExclSupplyK.lean:105/133`) sorry-free.

- **MANDATORY Phase-0 architectural gate** (must run FIRST, before any carrier code lands):
  decide the **frozen-boundary A-vs-B question** (`reports/02` §2.3):
  - **Option (A)** — modify the frozen private carrier `bracketEndChar_kv`
    (`CarrierKv.lean:246-249`) directly. This **breaks the byte-for-byte defeq**
    `bracketEndChar_kv_succ_eq` `rfl` (`InteriorGateGeneralK.lean:339-351`) that the entire
    Phase 1-4 byte-locked downstream is locked to. Unbounded blast radius.
  - **Option (B)** — build a **parallel** non-folded carrier alongside the frozen one and re-prove
    the full correctness chain (`igBody_holds_iff` :359, `step_sound` :1043, its fiber delegation
    :1150-1165, an `igFoldBit_realize_iff` :563 analog). No defeq break; higher proof volume.
  - The gate exists to make this trade-off **deliberately** rather than discovering it mid-refactor.
    No carrier code may land before the gate resolves.

- **Suggested `file_scope`** (inherited from `reports/02` §6, with `CarrierKv.lean` added — it holds
  the frozen fold that task 369's `file_scope` omitted):
  - `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge/InteriorGateGeneralK.lean`
  - `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge/CarrierKv.lean`
  - `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge/ExteriorGateAssembleK.lean`
  - `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/KampPrior.lean`
  - `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge/InteriorHrealSupplyK.lean`
  - `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge/ExteriorDeepExclSupplyK.lean`

- **Dependency edges** (for the orchestrator to record in `state.json`; `{M2}` = the new task's
  number, assigned at creation):
  - `{M2}.dependencies` **includes `369`** (M2 executes task 369's `reports/02` scope).
  - `{M2}.blocks` (transitively) **task 358** — see Action (b): task 358 Plan v09 Phase 5 now
    depends on M2's outcome, so `358.dependencies` must gain `{M2}` (in addition to its existing
    `369`). Equivalently, add `{M2}` to `358.dependencies`.
  - `{M2}.parent_task`: `358` (same recursion lineage as task 369).

- **Preserved assets M2 must not regress** (`reports/02` / plan Preserved Assets):
  the sorry-free `ExteriorPinnedProbeM1K.lean` + `ExteriorFiberConsistencyProbeK.lean` probes; the
  axiom floor `[propext, sorryAx, Classical.choice, Quot.sound]`; and — until the Phase-0 gate
  explicitly chooses Option (A) — the byte-locked frozen carrier defeq.

---

## Action (b) — Freeze task-358 Plan v09 Phase 5 against the current under-provisioned interface

### The statement (record explicitly)

**Task 358 Plan v09 Phase 5 (`kampPrior_hreal_supply`, `InteriorHrealSupplyK.lean:116`) must NOT be
re-dispatched against the current interface, nor against an `hepR`-enriched binder.** The leaf is
**provably under-provisioned** (`reports/01`:41-42; `reports/02` §5; plan Postmortem Constraints).

### Why the original task-358 assumption is now dead

- **Original task-358 assumption**: "Phase 5 calls task 369's M1 lemma
  (`kvE_futPos_supply_of_endpoint`) by name once landed" — i.e. M1 would supply the arity-4
  realizer and Phase 5 would just invoke it.
- **What changed**: M1 is **REFUTED** (`reports/01`, HIGH confidence). It is NOT PROVABLE from its
  stated hypotheses (`hepR`/`hAmb`/`hcons`/`hmark`/`hfut` + a depth-`k` `P`), because the only object
  that bridges the arity-1 `Until` witness `igEpR@t` fires up to the demanded arity-4 σ-realizer is
  depth-`(k+1)` saturation of the specific `M` — which is (a) absent from M1's signature and (b)
  exactly the task-358 recursion's own conclusion (circular). **That named-lemma path is dead: no
  M1 lemma will ever land for Phase 5 to call.**
- **What Phase 5 now depends on instead**: the **M2 execution task's outcome** (Action (a)), not on
  an M1 lemma. `kampPrior_hreal_supply` is discharged only once the de-folded endpoint carrier
  supplies the arity-4 realizer directly. Until M2 lands, Phase 5 has no sound interface to build
  against.

### Concrete instruction to the orchestrator

- Do **NOT** re-dispatch task 358 Plan v09 Phase 5 while task 358 remains blocked on the folded
  interface. Re-typing/enriching the `hepR` binder does **not** unblock it (the fold, not the
  binder, is the defect — `reports/02` §1-§2).
- **Do NOT** retain the `InteriorHrealSupplyK.lean:116` strategic sorry as a resting state; the
  sorry-free path is M2 (plan Postmortem Constraints).
- **Dependency edit**: task 358 already depends on task 369
  (`358.dependencies` = `[349, 357, 360, 363, 364, 367, 368, 369]`). Add the new M2 task `{M2}` to
  `358.dependencies` so task 358 is transitively gated on M2's completion, not on a (non-existent)
  M1 lemma.

### Source-of-truth pointers

- M1 refutation verdict + model-independence classification: `reports/01` §"The bounded
  adjudication", findings #3/#8/#9/#10, §"Why hcons does NOT rescue M1".
- Under-provisioning of `kampPrior_hreal_supply` and the render dependency: `reports/02` §5.
- Fix direction (de-fold, not firing oracle): `reports/01` finding #13 (Rabinovich fidelity);
  `reports/02` §0 + §3.

---

## Downstream-execution caveat (explicit)

Task 369 (this documentation phase) performs **no** task creation and **no** `state.json` edits.
The orchestrator/implementer executes:
1. Create the M2 task from Action (a) (title, description, `file_scope`, Phase-0 gate).
2. Record `{M2}.dependencies ⊇ {369}`, `{M2}.parent_task = 358`, and add `{M2}` to
   `358.dependencies`.
3. Keep task 358 blocked (do not re-dispatch Phase 5) until M2 completes.
