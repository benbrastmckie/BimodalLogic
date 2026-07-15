# M2 — De-folded Interior Carrier: authoritative scope-and-document

Task: 369 — M1 endpoint `kvE_futPos` supply / break render cycle
Session: sess_1784091172_81406c · Agent: lean-implementation-hard-agent (H2/H9)
Date: 2026-07-14
Source of record: `reports/01_m1-endpoint-firing-adjudication.md` (VERDICT: M1 NOT PROVABLE)
Status of this document: **scope-and-document only** — M2 execution is OUT OF SCOPE for task 369
and becomes a spawned multi-phase follow-up task.

> All file:line references below are reproduced from reports/01 and were re-confirmed against
> live source during this dispatch (spot-checked: `igFoldBit` InteriorGateGeneralK.lean:318;
> the frozen fold CarrierKv.lean:246-249; `bracketEndChar_kv_succ_eq` rfl
> InteriorGateGeneralK.lean:339-351). All paths are under
> `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge/` unless noted otherwise.

---

## 0. Header / verdict restatement (SETTLED — do not re-open)

**M1 (`kvE_futPos_supply_of_endpoint`) is NOT PROVABLE from its stated hypotheses.** The fix is
**M2: a de-folded interior carrier**, not a firing oracle over the existing fold. Both facts are
SETTLED per reports/01 (VERDICT + Postmortem Constraints) and must not be re-opened without a
concrete `lean_goal`-documented counterexample (specifically: a specific-`M` arity-4 witness
manufactured from M1's stated hypotheses, which reports/01 findings #3/#8/#9/#10 show cannot exist).

**The level gap (the core defect).** M1 must upgrade the **arity-1** `Until` witness that `igEpR@t`
fires into a full **arity-4** σ-realizer:

- What `hepR` supplies (arity-1): `igEpR@t`'s FutT conjunct is
  `igLit (igFoldBit qnf igZFutT χ) (Formula.untl (charK χ) ⊤)` over a depth-`(k+1)` **1-type**
  `χ = nfk_projFresh σ` (InteriorGateGeneralK.lean:219-225). Firing yields only
  `∃ v > t` whose arity-1 fresh projection matches `σ` — no ordering, no arity-4/arity-5 relational
  fiber.
- What the conclusion demands (arity-4): `temporal_truth M t (kvE_futPos P σ)` entails (driver
  `kampPrior_futRealizer_of_pos`, KampPrior.lean:1662-1716) `∃ x1 > t, nf_eval_nf M (k+1) 4
  [x1,w,x,t] σ` — a genuine arity-4 relational realization in **this** `M`.
- The only object that bridges arity-1 → arity-4 is depth-`(k+1)` saturation of the specific `M`,
  which is (a) NOT a hypothesis of M1 and (b) exactly the task-358 recursion's own conclusion
  (circular).

**Fix direction (finding #13, Rabinovich fidelity — SETTLED).** `rabinovich_2014` Cor 5.4(1)⇐
fires the future witness directly off `βn+1 Until αn+1` carrying the **full ordered bracket
sequence** and never folds. Lean's `igFoldBit` fold IS the divergence. Therefore the fix is to
**de-fold / carry the whole fiber (M2)**, not to invent an arity-1 → arity-4 upgrade oracle over
the existing fold.

---

## 1. De-folded interior carrier design (reports/01 §"M2 scope" item 1)

### 1.1 The lossy fold to eliminate

`igFoldBit` (InteriorGateGeneralK.lean:318-332) is the F1 loss point. Its signature and body:

```
noncomputable def igFoldBit {sig} {k} (qnf : NormalForm sig (k+1) 3) :
    ZoneSpec 3 → NormalForm sig k 1 → Bool :=
  fun zs χ => decide (∃ sub : NormalForm sig k 4, qnf.2 sub = true ∧
      nf0_zoneSpec (NormalForm.atom_assgn sub) = zs ∧ nfk_projFresh sub = χ)
```

It ∃-projects an **arity-4** `sub : NF sig k 4` down to the **arity-1** pair
`(zone zs, χ = nfk_projFresh sub)` and discards fiber identity. Two distinct fiber-consistent
arity-4 types can share `(zone, nfk_projFresh)` — the fold sees only that pair (reports/01 §"Why
hcons does NOT rescue M1"). This projection is the reason the endpoint eval cannot rebuild `σ`.

### 1.2 Carrier redesign locus (InteriorGateGeneralK.lean)

The endpoint/point carriers to replace or parallel with **de-folded variants keyed on the full
arity-4 fiber `σ : NF (k+1) 4`** (rather than the projected `(zone, χ : NF (k+1) 1)` pair):

| Carrier | Location | Current shape (arity-1 / lossy) | De-folded target |
|---------|----------|---------------------------------|------------------|
| `igEpL` | InteriorGateGeneralK.lean:209-215 | PastX conjunct `igLit (b igZPastX χ) (Formula.snce (charK χ) ⊤)` over 1-types (`Since` mirror) | endpoint past carrier keyed on full arity-4 fiber |
| `igEpR` | InteriorGateGeneralK.lean:219-225 | FutT conjunct `igLit (b igZFutT χ) (Formula.untl (charK χ) ⊤)` over `χ : NF (k+1) 1` | endpoint future carrier keyed on full arity-4 fiber |
| `igPtW` | InteriorGateGeneralK.lean:243-248 | AtW-zone-only `igLit (b igZAtW χ) (charK χ)` over 1-types (root cause F1) | point-at-W carrier keyed on full arity-4 fiber |
| `igFoldBit` | InteriorGateGeneralK.lean:318-332 | `NF (k+1) 3 → ZoneSpec 3 → NF k 1 → Bool`, ∃-projection to `nfk_projFresh` | a non-projecting fiber-carrying selector (no `nfk_projFresh` collapse) |

**Consumers that must accept the de-folded carriers** (same file):
- `igBody` (InteriorGateGeneralK.lean:290) — consumes the carriers into the gate body.
- `igMkDisjunct` (InteriorGateGeneralK.lean:276) — assembles the per-zone disjuncts.

Design principle: the de-folded variant is a **non-`igFoldBit`** carrier that keeps the full
arity-4 fiber content live at the endpoints, so the render's fiber layer is directly readable and
the σ-realizer is extracted from the endpoint eval with NO arity-1 → arity-4 upgrade (the
paper-faithful "carry the whole bracket sequence" shape).

---

## 2. Frozen-carrier boundary hard edge (reports/01 §"M2 scope" item 2)

**This is the central architectural obstruction.** The fold is not confined to `igFoldBit`; it is
**baked into the frozen private carrier**.

### 2.1 The fold is baked into the frozen carrier

`bracketEndChar_kv`'s `k+1` branch (CarrierKv.lean:244-249) contains the identical ∃-projection
fold in-line:

```
| k + 1 => fun qnf =>
    kv_body (nf_depth0_char_formula atomMap h_surj) (charF k) qnf.1
      (∀ sub : NormalForm sig k 4,
        nf0_dropFresh (NormalForm.atom_assgn sub) ≠ qnf.1 → qnf.2 sub = false)
      (fun zs χ => decide (∃ sub : NormalForm sig k 4, qnf.2 sub = true ∧
        nf0_zoneSpec (NormalForm.atom_assgn sub) = zs ∧ nfk_projFresh sub = χ))
```

The `(fun zs χ => decide (∃ sub … nfk_projFresh sub = χ))` argument at CarrierKv.lean:248-249 is
the frozen embodiment of the F1 fold.

### 2.2 The rfl lock

`bracketEndChar_kv_succ_eq` (InteriorGateGeneralK.lean:339-351) proves the successor carrier IS the
public replica by a **pure `rfl`** against that frozen fold:

```
theorem bracketEndChar_kv_succ_eq … (qnf : NormalForm sig (k+1) 3) :
    bracketEndChar_kv atomMap h_surj charF (k+1) qnf =
      igBody (nf_depth0_char_formula atomMap h_surj) (charF k) qnf.1
        (igOffFiber qnf) (igFoldBit qnf) := by
  simp only [bracketEndChar_kv]
  rfl
```

The `rfl` succeeds ONLY because `igFoldBit qnf` matches the frozen fold argument
**byte-for-byte** — including the exact nested decidability instance (documented at
InteriorGateGeneralK.lean:315-317: `Fintype.decidableExistsFintype` over `And` of
`instDecidableEqBool` / `Classical.propDecidable` / `normalForm_decEq`). Any change to the fold on
one side breaks this `rfl`, and the entire downstream is byte-locked to this defeq.

### 2.3 The two architectural options (the M2 execution task's Phase-0 gate)

A de-folded carrier cannot coexist with this frozen `rfl` bridge unchanged. M2 execution must
resolve, as its **own Phase-0 architectural gate**, exactly one of:

- **Option (A): modify the frozen `bracketEndChar_kv` directly.**
  - *Effect*: changes the `k+1` branch (CarrierKv.lean:246-249) to carry the full arity-4 fiber.
  - *Cost*: **breaks the byte-for-byte defeq** the entire Phase 1-4 byte-locked downstream is
    locked to via `bracketEndChar_kv_succ_eq` `rfl`. Every downstream consumer that relies on the
    frozen carrier's exact structure (byte-locked) must be re-audited and re-proven. High blast
    radius; touches files the whole tree is frozen against.

- **Option (B): build a parallel non-folded carrier and re-prove the full correctness chain.**
  - *Effect*: leaves `bracketEndChar_kv` frozen; introduces a sibling de-folded carrier alongside
    it; the render and endpoint extraction route through the parallel carrier.
  - *Cost*: must re-prove the whole correctness chain against the parallel carrier:
    - `igBody_holds_iff` (InteriorGateGeneralK.lean:359) — the body-holds characterization.
    - `step_sound` (InteriorGateGeneralK.lean:1043) — the soundness step.
    - its fiber delegation (InteriorGateGeneralK.lean:1150-1165) — the arity-4 fiber sub-obligation.
    - an `igFoldBit_realize_iff` (InteriorGateGeneralK.lean:563) analog for the de-folded carrier.
  - *Benefit*: no frozen-boundary defeq break; the byte-locked tree stays intact. Higher proof
    volume, lower architectural risk.

**Gate framing:** this modify-frozen (A) vs parallel-carrier (B) decision is the M2 execution
task's **Phase-0 architectural gate** and must be resolved BEFORE any carrier code lands. Task 369
does NOT decide it; it only documents the trade-off. (Per reports/01 Postmortem Constraints, task
369 must not modify the frozen carrier.)

---

## 3. Render bridge replacement (reports/01 §"M2 scope" item 3)

`igFoldBit_realize_iff` (InteriorGateGeneralK.lean:563) is the render-gated bridge that M1 tried to
route around. Under M2 it is **replaced by a de-folded `endpoint → arity-4 realizer` extraction
that needs no render**: because the de-folded carrier keeps the full arity-4 fiber live at the
endpoint, the σ-realizer `∃ x1 > t, nf_eval_nf M (k+1) 4 [x1,w,x,t] σ` is read directly off the
endpoint eval — no arity-1 → arity-4 upgrade and no render-gate detour.

---

## 4. Assembly + binders (reports/01 §"M2 scope" item 4)

De-folding the carrier re-types the render production and the assembly binders that consume it:

- **Render production**: `ExteriorGateAssembleK.lean:337-338` — produces the render; must emit the
  de-folded endpoint evals rather than the folded ones.
- **Row-5/6 binders**: `KampPrior.lean:955-1000` — the `hreal`/`hexcl` binders re-typed to the
  de-folded endpoint evals (currently typed against the folded arity-1 witnesses).
- **Drivers**: `kampPrior_futRealizer_of_pos` (KampPrior.lean:1662) and
  `kampPrior_pastRealizer_of_pos` (KampPrior.lean:1721) — re-wired to consume the de-folded
  endpoint evals. (Note: these drivers are the very lemmas whose conclusion is the arity-4 realizer
  M1 could not supply; under M2 the realizer is now available directly from the de-folded endpoint.)

---

## 5. Downstream re-verification (reports/01 §"M2 scope" item 5)

Every leaf that cites the render must be re-verified against the de-folded carrier. Known consumers:

- **`kampPrior_hreal_supply`** body — `InteriorHrealSupplyK.lean:116`, currently the `:116`
  strategic sorry. This is the leaf whose under-provisioning drove task 369's investigation. It is
  discharged by M2 (the de-folded endpoint supplies the arity-4 realizer directly). **It must NOT
  be re-dispatched against the current or `hepR`-enriched folded interface** (reports/01:41-42;
  Postmortem Constraints).
- **`ExteriorDeepExclSupplyK.lean:105` and `:133`** — rows 12-13 general-`m` arms, currently
  sorried and render-dependent; re-verify against the de-folded render.
- **Every other leaf citing the render** — audit for render dependency and re-verify.

---

## 6. Cost / risk signal (reports/01 §"M2 cost signal")

- **Nature**: a **carrier-redesign refactor crossing the frozen-carrier boundary** — the audit's
  explicit "larger refactor of `InteriorGateGeneralK.lean` … only if M1 is refuted."
- **Size**: substantially larger than a leaf addition; touches files the whole Phase 1-4 tree is
  byte-locked against (`InteriorGateGeneralK.lean`, `CarrierKv.lean`, `ExteriorGateAssembleK.lean`,
  `KampPrior.lean`, `InteriorHrealSupplyK.lean`, `ExteriorDeepExclSupplyK.lean`).
- **Sizing**: **multi-phase**, explicitly **larger than task 369**. It becomes a spawned follow-up
  task.
- **Phase-0 gate**: the frozen-boundary decision (Option A modify-frozen vs Option B
  parallel-carrier, §2.3) is the M2 execution task's Phase-0 architectural gate and must be
  resolved first.
- **Primary risk**: the Option-A `rfl` break (§2.2) has an unbounded blast radius across the
  byte-locked tree; Option B trades that for higher proof volume (full chain re-proof, §2.3).
  The gate exists precisely to make this trade-off deliberately rather than discovering it mid-refactor.

---

## 7. Certainty status

**M1 refutation: HIGH confidence — machine-certainty NOT reached.** The fiber-consistent
fold-collision obstruction is documented in Phase 0: the probe
`kvE_probeM1_foldCollision_hcons_status` (ExteriorPinnedProbeM1K.lean) landed **sorry-free**
(`lean_verify` = `[propext, Classical.choice, Quot.sound]`, no `sorryAx`; `lake build` green). It
machine-checks the fold collision (`nfk_projFresh m1sigma = nfk_projFresh m1tau`),
fiber-consistency of the realized member (`kvE_fiberConsistent m1tau = true`, ambient-marked), and
the non-realization of its fold-mate `m1sigma`. But a **fully-certain both-`hcons` witness** needs
a non-realized fiber-consistent fold-mate — a fiber individually co-realizable yet not jointly
pinned in this `M` — which is the model-independence gap reports/01 rated **Medium/unverified**.
That witness was deliberately NOT attempted (the plan's explicit ballooning boundary).

The verdict direction is unaffected: M1 is not provable **from these hypotheses** regardless,
because the bridging object (depth-`(k+1)` model saturation of this `M`) is absent and circular
(reports/01 findings #3/#8/#9/#10 + §"Why hcons does NOT rescue M1"). The HIGH-confidence verdict
stands on the model-independence classification, not on the probe.

---

## Load-bearing reference index (verbatim from reports/01, re-confirmed against source)

| Element | File:line | Role |
|---------|-----------|------|
| `igEpL` | InteriorGateGeneralK.lean:209-215 | endpoint past carrier (arity-1, `Since` mirror) |
| `igEpR` | InteriorGateGeneralK.lean:219-225 | endpoint future carrier (arity-1, `Until`) |
| `igPtW` | InteriorGateGeneralK.lean:243-248 | point-at-W carrier (arity-1, root cause F1) |
| `igMkDisjunct` | InteriorGateGeneralK.lean:276 | per-zone disjunct assembler (consumer) |
| `igBody` | InteriorGateGeneralK.lean:290 | gate body (consumer) |
| `igFoldBit` | InteriorGateGeneralK.lean:318-332 | the F1-lossy fold (arity-4 → arity-1 ∃-projection) |
| `bracketEndChar_kv_succ_eq` | InteriorGateGeneralK.lean:339-351 | frozen-carrier `rfl` lock |
| `igBody_holds_iff` | InteriorGateGeneralK.lean:359 | body-holds characterization (Option B re-proof) |
| `igFoldBit_realize_iff` | InteriorGateGeneralK.lean:563 | render-gated bridge (replace, §3) |
| `step_sound` | InteriorGateGeneralK.lean:1043 | soundness step (Option B re-proof) |
| `step_sound` fiber delegation | InteriorGateGeneralK.lean:1150-1165 | arity-4 fiber sub-obligation (Option B re-proof) |
| frozen fold in `bracketEndChar_kv` | CarrierKv.lean:246-249 | the baked-in F1 fold (Option A locus) |
| render production | ExteriorGateAssembleK.lean:337-338 | assembly render (re-type, §4) |
| row-5/6 binders | KampPrior.lean:955-1000 | `hreal`/`hexcl` binders (re-type, §4) |
| `kampPrior_futRealizer_of_pos` | KampPrior.lean:1662 | future realizer driver (re-wire, §4) |
| `kampPrior_pastRealizer_of_pos` | KampPrior.lean:1721 | past realizer driver (re-wire, §4) |
| `kampPrior_hreal_supply` (:116 sorry) | InteriorHrealSupplyK.lean:116 | downstream leaf (discharge, §5) |
| rows 12-13 general-`m` arms | ExteriorDeepExclSupplyK.lean:105, :133 | render-dependent leaves (re-verify, §5) |
| Phase-0 probe (landed) | ExteriorPinnedProbeM1K.lean (`kvE_probeM1_foldCollision_hcons_status`) | certainty gate (obstruction documented, §7) |

---

## Recommendations & Handoff (Phase 2)

> Full copy-paste-ready descriptors live in the standalone artifact
> `reports/03_spawn-and-dependency-recommendation.md`. **Actual task creation and `state.json`
> dependency edits are performed by the orchestrator/implementer, NOT by this documentation task.**

### (a) Spawn the M2 carrier-redesign execution task

- **Title**: `M2: de-folded interior carrier redesign — carry full arity-4 fiber (execute reports/02 scope)`
- **Type**: `lean4` · **Sizing**: multi-phase (larger than task 369).
- **Source of truth**: this document (`reports/02`), grounded in `reports/01` + `rabinovich_2014`.
- **MANDATORY Phase-0 architectural gate (runs first)**: the frozen-boundary **A-vs-B** decision
  (§2.3) — Option (A) modify the frozen `bracketEndChar_kv` (CarrierKv.lean:246-249, breaks the
  byte-locked `rfl` :339-351) vs Option (B) parallel non-folded carrier + full-chain re-proof
  (`igBody_holds_iff` :359, `step_sound` :1043 + fiber delegation :1150-1165, `igFoldBit_realize_iff`
  :563 analog). No carrier code lands before the gate resolves.
- **file_scope** (§6 set + `CarrierKv.lean`): InteriorGateGeneralK.lean, CarrierKv.lean,
  ExteriorGateAssembleK.lean, KampPrior.lean, InteriorHrealSupplyK.lean, ExteriorDeepExclSupplyK.lean.
- **Dependency edges**: `{M2}.dependencies ⊇ {369}`; `{M2}.parent_task = 358`; add `{M2}` to
  `358.dependencies` (M2 transitively blocks task 358 — see (b)).

### (b) Freeze task-358 Plan v09 Phase 5 against the current under-provisioned interface

- Task 358 Plan v09 Phase 5 (`kampPrior_hreal_supply`, InteriorHrealSupplyK.lean:116) **must NOT be
  re-dispatched** against the current folded interface, nor an `hepR`-enriched binder — it is
  provably under-provisioned (§5; reports/01:41-42).
- The original assumption "Phase 5 calls task 369's M1 lemma by name once landed" is **dead**: M1 is
  REFUTED (reports/01), so no M1 lemma will ever land. Phase 5 now depends on the **M2 execution
  task's outcome**, not on an M1 lemma.
- Orchestrator: add `{M2}` to `358.dependencies` (358 already depends on 369) and keep task 358
  blocked until M2 completes. Do NOT retain the :116 strategic sorry as a resting state.

### Downstream-execution caveat

Task 369 performs no task creation and no `state.json` edits. The orchestrator/implementer creates
the M2 task, records the dependency edges above, and keeps task 358 blocked until M2 lands. See
`reports/03_spawn-and-dependency-recommendation.md` for the verbatim descriptors.
