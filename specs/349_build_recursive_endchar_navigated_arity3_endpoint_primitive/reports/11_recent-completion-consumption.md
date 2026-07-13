# Task 349 — Report 11: Recent-Completion Consumption (blocker-resolution research)

**Agent**: lean-research-agent | **Date**: 2026-07-12 | **Task type**: lean4 | **Session**: sess_1783841542_df767b
**Topic**: consuming the task-351/352/354 deliveries to unblock task-349 v7 Phase 2
**Verdict up front**: **REVISE → GO.** The Phase-2 blocker is genuinely cleared. All four deferred
bracket lemmas now map to delivered, green, sorry-free assets. One residual is a *layer* gap (the
delivered assets are the depth-`k` **clause** layer; the deferred lemmas are the **bracket**
layer that wraps it — a bounded ~150–200-line additive assembly, no new mathematics). Plan v7
Phase 2 must be re-pointed at the delivered modules and its `_complete` statements updated to carry
the F2 saturation residue (the frozen "byte-identical k=2 statement" prescription is now stale).

---

## 1. Recent-completion inventory (signatures, sorry-free, axioms)

The blocker-clearing work landed a **fresh depth-`k` clause layer** as a chain of NEW additive
leaf modules under `NfMultiAnchorBridge/` (no frozen file touched; whole tree clean per
`git status --short`). Import chain:

```
ExteriorFiberK ──▶ ExteriorNegationK   ──▶ ExteriorConverterK      (Future)
              └──▶ ExteriorNegationPastK──▶ ExteriorConverterPastK  (Past)
```

### 1a. Task 354 primary deliverables — the reverse `_complete` converters

**`kvE_extNegFut_complete`** — `ExteriorConverterK.lean:119` (module 227 lines, 0 sorry):

```lean
theorem kvE_extNegFut_complete {sig} {atomMap : Formula → sig.preds} {k : Nat}
    (P : ExistProviders sig atomMap k) (M : OrderedMonadicStructure sig)
    (h_UZ : semantic_prior_UZ M atomMap) (h_SZ : semantic_prior_SZ M atomMap)
    (σ : NormalForm sig (k + 1) 4) (w x t : M.carrier) (hxw : x < w) (hwt : w < t)
    (hreal : ∀ x1, t < x1 → ∀ s : NormalForm sig k 5, σ.2 s = true →
      ∃ v, nf_eval_nf M k 5 (Fin.cons v (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t))))) s)
    (hsat : ∀ x1, t < x1 → temporal_truth M atomMap x1 (kvE_futEnd P σ) →
      ∀ s : NormalForm sig k 5, nfk_dropFresh s = σ.1 →
        (∃ v, nf_eval_nf M k 5 (Fin.cons v (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t))))) s) →
        σ.2 s = true)
    (hcl : ∀ x1, t < x1 →
      ¬ nf_eval_nf M (k + 1) 4 (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t)))) σ) :
    temporal_truth M atomMap t (kvE_extNegFut P σ)
```

Reads: assuming (F2-carried) the fiber-forward realization bundle `hreal` and the exterior-anchor
saturation residue `hsat`, if **no** exterior `x1 > t` realizes `σ` over `[x1,w,x,t]` (`hcl`), then
the complement clause `kvE_extNegFut P σ` holds at `t`. Proof: destructs the Cor 5.4 chain via
`kvE_futChainDestructG` (ExteriorNegationK.lean:293), recovers the atom layer via
`kvE_futAtom_of_bundle`, and reassembles `nf_eval_nf M (k+1) 4 [x1,w,x,t] σ` through the Phase-1
bridge `nf_eval_nfk_iff_efold` (NfEFold.lean:627) — contradiction with `hcl`.

**`kvE_extNegPast_complete`** — `ExteriorConverterPastK.lean:94` (module 196 lines, 0 sorry): byte-
mirror with `x1 < x`, conclusion `temporal_truth M atomMap x (kvE_extNegPast P σ)`, chain via
`kvE_pastChainDestructG` (ExteriorNegationPastK.lean:353) under `semantic_prior_SZ`.

### 1b. Task 354 supporting public lemmas (same two modules)

| Lemma | Loc | Fact |
|-------|-----|------|
| `kvE_futAdmissible_fiber_dichotomy` | ExteriorConverterK.lean:48 | admissible σ ⇒ every arity-5 sub is on `σ.1`'s fiber or bit-false |
| `kvE_futAdmissible_onFiber` / `_offFiber` | :63 / :73 | on-fiber recording / off-fiber falsity (the off-fiber conjunct the bridge needs) |
| `kvE_futAtom_of_bundle` | :92 | one carried arity-5 realizer ⇒ `σ.1` atom layer at `[x1,w,x,t]` (via `nf_eval_nf_atom_layer` + `nf_eval_nf0_cons_factor`) |
| **`kvE_futBundle_of_realizer`** | **:208** | **discharge template**: a genuine `nf_eval_nf M (k+1) 4 [x1,w,x,t] σ` ⇒ BOTH carried obligations (`hreal` shape ∧ `hsat` shape) hold. Pure read of `nf_eval_nfk_iff_efold`. |
| Past mirrors: `kvE_pastAdmissible_fiber_dichotomy/_onFiber/_offFiber`, `kvE_pastAtom_of_bundle`, **`kvE_pastBundle_of_realizer`** | ExteriorConverterPastK.lean:33/48/57/72/**177** | Past duals |

`kvE_futBundle_of_realizer` / `kvE_pastBundle_of_realizer` are the load-bearing bridge for
downstream consumption: they prove the carried `hreal`/`hsat` are **not debt** but a dischargeable
interface — whenever the task-349 outer recursion produces a genuine exterior realizer (it does,
by picking `x1` at the Rabinovich inf/sup), both carried hypotheses follow.

### 1c. Task 352 clause-layer inputs (the `_sound` halves + machinery)

| Asset | Loc | Role |
|-------|-----|------|
| `kvE_extNegFut_sound` | ExteriorNegationK.lean:532 | Future complement-clause soundness (depth-`k`) |
| `kvE_extNegPast_sound` | ExteriorNegationPastK.lean:539 | Past mirror |
| `kvE_futPos` / `kvE_extNegFut` | ExteriorNegationK.lean:415 / :425 | positive local-existence clause / its complement (negation) |
| `kvE_futAdmissible` / `kvE_futRealizer_admissible` | :86 / :124 | depth-`k` marking predicate + realizer⇒admissible bridge (the depth-`k` analog of `kvE2_futMarked` / `kvE2_futMarked_of_realizer`) |
| `kvE_futChainDestructG` / `kvE_pastChainDestructG` | :293 / ExteriorNegationPastK.lean:353 | Cor 5.4 `Oₙ` re-anchoring chain destructor |
| `kvE_fiber*` / `kvE_fiberZoneList` / `kvE_fiberPosOnShift(_correct)` | ExteriorFiberK.lean:53–365 | fiber-bucket machinery + arity-5 anchor-shift bridge (`rot5Fwd/Bwd`) |

### 1d. Task 351 input

`nfEval_le2_reduction` (Rabinovich Lem 3.2(2)) — `Lemma32Reduction.lean:535` (frozen; consume
only). Step-A interior arity reduction, used in the Phase-3 body / interior content, **not** in the
bracket lemmas themselves.

### 1e. Sorry-free + axiom footprint

- **grep**: 0 `sorry`/`admit` across all four ConverterK/PastK + NegationK/PastK modules.
- **git**: whole `Theories/` tree clean — all four modules committed; frozen providers,
  `KampPrior.lean`, `Lemma32Reduction.lean`, `ExteriorBracketK.lean` byte-identical.
- **axioms**: task-354 delivery record and the situation brief both state exactly
  `[propext, Classical.choice, Quot.sound]`; the modules are additive and committed green.
  Positive `lean_verify` re-confirmation on `kvE_extNegFut_complete` / `kvE_extNegPast_complete`
  is a Phase-6 gate item (cheap, warm) — not re-run here since the tree is committed-green and no
  claim depends on a fresh axiom.

---

## 2. Task-349 Phase-2 deferred lemmas (exact names, locations, status)

The v7 Phase-2 BLOCKER block (plan lines 411–458) and `.orchestrator-handoff.json:blockers`
name the **four deferred bracket lemmas** — the depth-`k` analogs of the frozen k=2 bracket layer:

| # | Deferred lemma (depth-`k`, NOT yet landed) | k=2 frozen template (byte-identical target the plan cites) |
|---|--------------------------------------------|-------------------------------------------------------------|
| D1 | `kvE_extBracketFut_sound` | `kvE2_extBracketFut_sound` — ExteriorBracket.lean:432 |
| D2 | `kvE_extBracketPast_sound` | `kvE2_extBracketPast_sound` — ExteriorBracket.lean:456 |
| D3 | `kvE_extBracketFut_complete` | `kvE2_extBracketFut_complete` — ExteriorBracket.lean:547 |
| D4 | `kvE_extBracketPast_complete` | `kvE2_extBracketPast_complete` — ExteriorBracket.lean:583 |

**Where they must land**: an additive module in the ExteriorBracket family — either the existing
`ExteriorBracketK.lean` (currently 409 lines, imports only `ExteriorBracket` + `NfEFold`) extended
with the new depth-`k` clause imports, or a NEW `ExteriorBracketAssembleK.lean` importing both
`ExteriorConverterK`/`ExteriorConverterPastK` and `ExteriorBracketK`. **None of the four exist yet.**

**What already landed in Phase 2** (ExteriorBracketK.lean, green, committed — the "determinacy
core", preserve verbatim): `nfk_truncD`/`nf_eval_truncD` (:62/:80), `nf_eval_take`/`nf_eval_projFresh`
(:111/:163), `kvE_sepPos`/`kvE_projFreshD`/`nf_eval_projFreshD` (:183/:198/:203),
`kvE_futAnyBit`+`kvE_futAnyBit_correct` (:218/:230), `kvE_subBit`+`kvE_subBit_iff` (:302/:314),
`kvE_projFreshD_zero`/`kvE_futAnyBit_zero` (:376/:389). These are the depth-`k` `habove`/`hbelow`
determinacy pins — inputs the bracket layer consumes, already in hand.

The frozen k=2 bracket layer's per-side existence extractors `kvE2_extBracketFut_exists`
(ExteriorBracket.lean:483) / `kvE2_extBracketPast_exists` (:513) are the ⇒-side positive residue
templates for the depth-`k` `hpos` obligation.

---

## 3. Consumption mapping (deferred lemma → consumed asset → gluing sketch)

The k=2 bracket proofs are **short** (≈15–35 lines each) and are the line-by-line template. Each
depth-`k` bracket lemma is a conjunction-over-admissible-σ of `if σ.2-bit then kvE_futPos else
kvE_extNegFut`, discharged per-σ by the delivered clause layer.

| Deferred | Consumed assets | Gluing sketch (mirror the cited k=2 proof) |
|----------|-----------------|--------------------------------------------|
| **D1 `kvE_extBracketFut_sound`** | `kvE_extNegFut_sound` (352, :532) + `kvE_futAdmissible`/`kvE_futRealizer_admissible` (352, :86/:124) | Mirror ExteriorBracket.lean:432–452: bracket-true@`t` ⇒ per-σ clause (`_iff` unfold); a bit-false **admissible** σ ⇒ `kvE_extNegFut` holds ⇒ `kvE_extNegFut_sound` refutes any exterior realizer `x1 > t`. **CLEAN — no F2 residue** (sound direction needs none). |
| **D2 `kvE_extBracketPast_sound`** | `kvE_extNegPast_sound` (352, :539) + past admissibility (352) | Mirror ExteriorBracket.lean:456–476, `x1 < x`. **CLEAN.** |
| **D3 `kvE_extBracketFut_complete`** | `kvE_extNegFut_complete` (354, :119) for bit-false σ + `kvE_extNegFut_sound` (352) for bit-true σ; discharge `kvE_futBundle_of_realizer` (354, :208) | Mirror ExteriorBracket.lean:547–579: per-σ, bit-true ⇒ `hpos` gives a realizer, `kvE_extNegFut_sound` contrapositive; bit-false ⇒ `kvE_extNegFut_complete`. **RESIDUAL (G-c below): the depth-`k` `_complete` carries extra `hreal`/`hsat`; the bracket-complete must thread them, discharged by Phase 4 via `kvE_futBundle_of_realizer`.** |
| **D4 `kvE_extBracketPast_complete`** | `kvE_extNegPast_complete` (354, :94) + `kvE_extNegPast_sound` (352); discharge `kvE_pastBundle_of_realizer` (354, :177) | Mirror ExteriorBracket.lean:583–615. Same residual as D3, Past side. |

**Interior / Phase-3 body** (not a bracket lemma but the other consumer): `nfEval_le2_reduction`
(351, Lemma32Reduction.lean:535) feeds the Step-A interior arity reduction; the full-arity interior
read stays `nf_eval_nf M k 4 [x1,w,x,t] σ` (G1).

### Residual gaps (flagged — signature/anchor/reindex mismatches)

- **G-a — Layer, not lemma.** 354 delivered the **clause** layer (`kvE_extNegFut/Past_complete`),
  NOT the **bracket** layer (`kvE_extBracket…`). The four deferred lemmas are the bracket wrapper
  that conjoins the clauses over admissible σ. This wrapper is exactly the deferred Phase-2 work —
  now unblocked, ~150–200 additive lines. *No new mathematics; it is the k=2 bracket proof retyped
  one fold-layer deeper.*
- **G-b — Marking predicate shape.** The depth-`k` clause layer keys on `kvE_futAdmissible`
  (ExteriorNegationK.lean:86), NOT the frozen k=2 `kvE2_futMarked`. The depth-`k` bracket defs must
  be built over `kvE_futAdmissible`, and the `_marked_of_realizer` step used in the k=2 sound proof
  (ExteriorBracket.lean:448) is supplied by `kvE_futRealizer_admissible` (ExteriorNegationK.lean:124).
  The implementer must confirm the exact bridging shape (realizer ⇒ admissible) matches.
- **G-c — `_complete` carries the F2 saturation residue (`hreal`/`hsat`).** The frozen k=2
  `kvE2_extNegFut_complete` does NOT carry these; the depth-`k` `kvE_extNegFut_complete` does (the
  faithful F2-sidestep — provably not in-module derivable, per the 353 NO-GO). So the depth-`k`
  bracket-`complete` signature is **NOT byte-identical** to the k=2 template: it either carries
  `hreal`/`hsat` (or an equivalent joint-depth-content hypothesis) OR receives them pre-discharged.
  The natural composition is to have Phase 4's ⇐ direction — which owns a genuine
  `∃w, nf_eval_nf M (k+1) 3 [w,x,t] qnf` and rebuilds the exterior realizers via the providers —
  invoke `kvE_futBundle_of_realizer`/`kvE_pastBundle_of_realizer` (354) to produce `hreal`/`hsat`,
  then feed the bracket-`complete`. This is precisely plan-BLOCKER resolution **(c)** ("weaken the
  Phase-2 statements with an explicit joint-depth-content hypothesis dischargeable by Phase 4"),
  realized concretely.
- **G-d — Provider parameter + imports.** The depth-`k` clause layer is threaded on
  `P : ExistProviders sig atomMap k` (PriorInterface.lean:38) — plan-BLOCKER resolution **(a)**. The
  bracket defs inherit `P`. `ExteriorBracketK.lean` does **not** yet import the Converter/Negation
  modules; either extend its imports or add a new assembly module. (Both are additive — frozen
  files stay clean.)

---

## 4. Plan-validity verdict — **REVISE (then GO)**

**(a) Does v7 depend on the refuted `extF4` route?** **NO.** `extF4` was a *task-352/353 internal*
converter shape (flat arity-5, all four `[x1,w,x,t]` pinned as a `temporal_truth … t` LHS). The 353
report (`reports/01_extf4-endpoint-pinned-converter.md`) machine-refutes it as an F2/architecture
NO-GO. v7's plan never names `extF4`; its Phase-2 targets are the **bracket** lemmas
`kvE_extBracket…`, and the whole architecture is 2-endpoint (`VVecEA2.holds … x t`). Task 354 then
delivered the *faithful* mechanism (nested re-anchoring: `kvE_extNegFut/Past_complete` driving the
Cor 5.4 chain), which is exactly what v7's bracket layer wants underneath it. **v7 is NOT tied to
the refuted route.**

**(b) Green/committed vs. open:**

| Phase | Status |
|-------|--------|
| 1 — general-`k` fold bridge `nf_eval_nfk_iff_efold` | **GREEN + committed** (NfEFold.lean:627) |
| 2 — determinacy core (ExteriorBracketK.lean) | **GREEN + committed** |
| 2 — the four bracket lemmas D1–D4 | **OPEN** (was [BLOCKED]; now unblocked by 351/352/354) |
| 3 — `endIntervalStep` body + `EndIntervalCorrectPrior` | NOT STARTED |
| 4 — step sound/complete at depth `k` | NOT STARTED |
| 5 — recursion close `endInterval_correct` | NOT STARTED |
| 6 — axiom audit + whole-tree build | NOT STARTED |

**(c) Does v7 need a new plan version?** **YES — a bounded revision (v8), for Phase 2 (and light
touches to 3/4).** The plan's own BLOCKER block says *"Do not re-dispatch Phase 2 in the current
plan shape … adjudicate resolutions (a)/(b)/(c) first (plan revision or /spawn 349)."* Tasks 352/354
have now delivered exactly the assets that resolutions **(a)** (provider-parameterized depth-`k`
clause layer) + **(c)** (F2 residue carried, discharged one level up) require. But v7's Phase-2 task
list is written for a route that no longer matches reality:
- Phase-2 tasks say *"Define `kvE_extBracketPast/Fut` mirroring the k=2 defs"* and *"Prove
  `_sound`/`_complete` mirroring the k=2 proofs"* against **byte-identical k=2 statements** — but
  the delivered clause layer is provider-parameterized and its `_complete` carries `hreal`/`hsat`
  (G-b, G-c, G-d). A byte-identical mirror is impossible; the statements must be updated.
- The Phase-2 heading is still `[BLOCKED]` with a large stale BLOCKER block that instructs against
  re-dispatch.
- Phase 4 must be told to discharge `hreal`/`hsat` via the 354 bundle templates (currently unstated).

**Recommendation: `/revise 349` → v8** with these concrete edits:
1. Phase 2 `[BLOCKED]` → `[IN PROGRESS]`; replace the BLOCKER block with a "resolved by 351/352/354"
   note and lift the "do not re-dispatch" instruction.
2. Re-point Phase-2 tasks D1–D4 at the delivered assets (Section 3 table): consume
   `kvE_extNegFut/Past_sound` (352) + `kvE_extNegFut/Past_complete` (354); build the depth-`k`
   bracket defs over `kvE_futAdmissible` with `P : ExistProviders`.
3. Change the "byte-identical k=2 statement" prescription for D3/D4 to "k=2 statement **plus** the
   carried `hreal`/`hsat` (or an explicit joint-depth-content hypothesis), discharged in Phase 4."
4. Phase 4 ⇐ tasks: add "produce `hreal`/`hsat` via `kvE_futBundle_of_realizer` /
   `kvE_pastBundle_of_realizer` (354) from the reconstructed exterior realizer."
5. Files/imports: declare the depth-`k` bracket module (extend `ExteriorBracketK.lean` imports or a
   new `ExteriorBracketAssembleK.lean`) importing `ExteriorConverterK`/`ExteriorConverterPastK`.
6. Update the Preserved-Assets table + H3 Tier-1 mapping to add the 352/354 modules.

This is a *bounded* revision (statement/route re-pointing), not a carrier change — the carrier
decision is SETTLED and unaffected. After v8, implementation can proceed straight through Phases
2→6. So the net verdict is **REVISE → GO**.

---

## 5. Guards & constraints check

| Guard | Consumption-path status |
|-------|-------------------------|
| **G1 — no arity-1 interior collapse (`nfk_projFresh`)** | **PASS with nuance.** The Converter modules are CLEAN of `nfk_projFresh`; interior content is reassembled at FULL arity (`nf_eval_nf M (k+1) 4 [x1,w,x,t] σ`, `nf_eval_nf M k 5 [v,x1,w,x,t] s`, via `nf_eval_nf_atom_layer` + `nf_eval_nf0_cons_factor`). **Nuance to record**: the 352 fiber machinery (`ExteriorFiberK.lean:182`, `ExteriorNegationK.lean:81/103`) uses `nfk_projFresh` for **fiber-bucket zone classification** (reading the fresh-endpoint coordinate to bucket subs) — this is the faithful Rabinovich bucketing, NOT the F2-forbidden interior-content collapse. The reviser should note this sanctioned classification role so the completion gate does not misflag it. |
| **G2/G4 — anchors strictly ⊆ {x,t}, ≤2** | **PASS.** Each converter exposes a single evaluation point — `temporal_truth M atomMap t (…)` (Future) / `… x (…)` (Past). The exterior anchor `x1`, interior `w`, and fiber witness `v` are quantified (`∀ x1`, `∃ v`), never free anchors — identical discipline to the frozen k=2 layer. |
| **G3 — non-trivial segment (no `TemporalPred.top`)** | **PASS.** `kvE_extNegFut` is a genuine complement (negation of `kvE_futPos`); the chain clauses are real exterior exclusions, not vacuous tops. |
| **G5 — no simp/omega/aesop shortcut of a Rabinovich chain step** | **PASS.** The Cor 5.4 chain is driven explicitly by `kvE_futChainDestructG`/`kvE_pastChainDestructG` with manual `rw`/`obtain`/`constructor`; `simp` appears only in trivial membership goals and `decide` only for Bool absurdity — no chain step is bypassed. |
| **FORBIDDEN `nf_char3_deeper_split`** | **PASS.** Absent from all four modules (grep clean). |
| **Frozen files untouched** | **PASS.** All five depth-`k` modules are NEW additive leaves; `git status --short` clean; 7 frozen providers + `KampPrior.lean` + `Lemma32Reduction.lean` + `ExteriorBracketK.lean` byte-identical. |

**One disclosure item (not a violation)**: G-c's carried `hreal`/`hsat` could *look* like weakened
Rabinovich steps to a strict completion gate. They are the faithful F2-sidestep — the 353 NO-GO
proves they are genuinely not in-module derivable, and `kvE_futBundle_of_realizer` /
`kvE_pastBundle_of_realizer` (354) prove they are *dischargeable* from a genuine realizer. The v8
plan + summary must document this so Phase-6's axiom/debt audit records them as a discharged
interface, not debt.

---

## 6. Concrete next-action recommendation

**For the orchestrator/reviser — do `/revise 349` (v8) first, then implement:**

1. **Revise (v8)** per Section 4(c) items 1–6. This is a route/statement re-pointing driven by the
   351/352/354 deliveries; the carrier is SETTLED and untouched. `next_action_hint = "revise-plan"`.
2. **Then implement Phase 2 (D1–D4)** — a single bounded dispatch (~150–200 additive lines) in a new
   depth-`k` bracket module importing `ExteriorConverterK`/`ExteriorConverterPastK` + `ExteriorBracketK`:
   - D1/D2 (`_sound`): mirror ExteriorBracket.lean:432–476 over `kvE_extNegFut/Past_sound` +
     `kvE_futAdmissible`. CLEAN, no residue.
   - D3/D4 (`_complete`): mirror ExteriorBracket.lean:547–615 over `kvE_extNegFut/Past_complete`,
     threading `hreal`/`hsat` for the bit-false arm; sanity-check the k=2 instance interderives.
   - Per-phase bar: green + sorry-free, `lean_verify = [propext, Classical.choice, Quot.sound]`,
     scoped `lake build`, frozen diffs empty.
3. **Phases 3–5** proceed as planned, with Phase 4's ⇐ direction using the bundle discharge
   templates (Section 4(c) item 4).

**Count**: 4 deferred lemmas; **4/4 map cleanly** to delivered green assets (D1/D2 with no residue;
D3/D4 with the F2 residue discharged by the 354 bundle templates). **Residual**: the bracket-wrapper
assembly layer (G-a) and the statement-shape update (G-c) are bounded engineering / plan text, not
open mathematics. The blocker is cleared.
