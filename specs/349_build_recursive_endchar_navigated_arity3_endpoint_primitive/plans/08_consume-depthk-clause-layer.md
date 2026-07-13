# Implementation Plan: Task #349 (v8 — consume the depth-`k` clause layer)

- **Task**: 349 - Build the recursive navigated endpoint primitive as
  `endInterval : (k) → BracketEndCharCarrierV sig k` + `endInterval_correct` on the
  **enriched-segment bracket carrier** (`bracketEndChar_kvE2Ext` family, carrier 3)
- **Status**: [IN PROGRESS]
- **Effort**: 13 hours (remaining open work; Phase 1 + the Phase-2 determinacy core already
  landed green under v7)
- **Dependencies**: Task 351 (LANDED — `nfEval_le2_reduction`, green, sorry-free);
  Task 352 (LANDED — depth-`k` exterior-negation clause layer `_sound` halves + machinery,
  green, sorry-free); Task 354 (LANDED — reverse `_complete` converters + bundle discharge
  templates, green, sorry-free); Task 353 (COMPLETE — superseded by 354; provided the F2
  NO-GO that motivates the carried `hreal`/`hsat` interface). **All Phase-2 blockers cleared.**
- **Research Inputs**:
  - reports/11_recent-completion-consumption.md (AUTHORITATIVE for v8 — the blocker-resolution
    consumption research: 351/352/354 signatures §1, the four deferred bracket lemmas §2, the
    consumption mapping table §3, plan-validity verdict REVISE→GO §4, guards check §5, concrete
    next actions §6)
  - reports/09_carrier-synthesis.md (carrier decision + v7 architecture — still authoritative
    for carrier type §3.1, recursion step §3.2, phase skeleton §3.5)
  - reports/10_q3-uniform-k-probe.md (Q3 GO verdict; the Phase-1 fold-bridge target — now DONE)
  - reports/07 (Rabinovich faithfulness deep-check), reports/05/06/04 (prior carrier context)
- **Artifacts**: plans/08_consume-depthk-clause-layer.md (this file); supersedes
  plans/07_enriched-bracket-carrier.md (v7, Phase 2 [BLOCKED])
- **Standards**: plan-format.md; status-markers.md; artifact-management.md; tasks.md;
  lean4 extension rules; reference-grounding.md (H3 Tier-1 lean4 override);
  plan-format-enforcement.md
- **Type**: lean4
- **Lean Intent**: true
- **reports_integrated**: [11_recent-completion-consumption.md, 10_q3-uniform-k-probe.md,
  09_carrier-synthesis.md]

## Overview

v8 is a **bounded route/statement revision of v7 Phase 2**, driven by the tasks 351/352/354
deliveries that cleared the v7 Phase-2 blocker. The carrier decision (carrier 3, enriched-segment
bracket, codomain `BracketEndCharCarrierV sig k = NormalForm sig k 3 → VVecEA2`) is **SETTLED and
untouched** — v8 changes nothing about the architecture, only re-points the four deferred bracket
lemmas at the now-delivered depth-`k` clause layer and updates their statement shape.

**What v7 got stuck on and why it is now unblocked** (report 11 §4): v7's Phase 2 prescribed
proving the four bracket lemmas `kvE_extBracketPast/Fut_sound`/`_complete` against
**byte-identical k=2 statements** in a leaf module importing only `ExteriorBracket` + `NfEFold`.
That is impossible — the faithful depth-`k` clause layer is provider-parameterized and its
`_complete` direction carries an F2 saturation residue (`hreal`/`hsat`) that is provably not
in-module derivable (the task-353 NO-GO). Tasks 352 and 354 then delivered exactly that clause
layer as new additive leaf modules:

```
ExteriorFiberK ──▶ ExteriorNegationK   ──▶ ExteriorConverterK      (Future)
              └──▶ ExteriorNegationPastK──▶ ExteriorConverterPastK  (Past)
```

- Task 352 delivered the **`_sound`** halves (`kvE_extNegFut_sound` ExteriorNegationK.lean:532 /
  `kvE_extNegPast_sound` ExteriorNegationPastK.lean:539) + the depth-`k` marking predicate
  `kvE_futAdmissible`/`kvE_futRealizer_admissible` + the Cor 5.4 chain destructors.
- Task 354 delivered the reverse **`_complete`** converters (`kvE_extNegFut_complete`
  ExteriorConverterK.lean:119 / `kvE_extNegPast_complete` ExteriorConverterPastK.lean:94) — which
  thread `P : ExistProviders` and carry the `hreal`/`hsat` hypotheses — **plus the bundle
  discharge templates** `kvE_futBundle_of_realizer` (ExteriorConverterK.lean:208) /
  `kvE_pastBundle_of_realizer` (ExteriorConverterPastK.lean:177) that prove `hreal`/`hsat` are a
  **dischargeable interface, not debt**.

The remaining work is the **bracket wrapper** (the `kvE_extBracket…` layer that conjoins the
delivered depth-`k` **clause** layer `kvE_extNeg…` over admissible σ) — a bounded, additive
assembly (~150-200 lines total per report 11 §4, split here into two bounded dispatches), plus
the downstream Phases (step body, step correctness, recursion close) carried forward from v7 with
Phase 6's ⇐ direction updated to discharge `hreal`/`hsat` via the 354 bundle templates.

**Definition of done** (unchanged from v7 / the task description): `endInterval`/
`endInterval_correct` (the `EndIntervalCorrectPrior` biconditional) recursive over `k`,
sorry-free; `lean_verify` on `endInterval_correct` = exactly
`[propext, Classical.choice, Quot.sound]`; scoped `lake build` GREEN at every phase and
whole-tree GREEN at the final phase; zero edits to the 7 frozen providers +
`KampPrior.lean` + `Lemma32Reduction.lean` + `ExteriorBracketK.lean` (all byte-identical, `git
diff` empty); `endInterval_correct` a top-level citable name consumable **by name** by task 309
Phase 18/19 and task 350. If any main target cannot close green without a forbidden construct,
mark `[BLOCKED]` + exact `lean_goal` + `/spawn 349` — never land a vacuous or `sorry`'d
`endChar`.

### Research Integration (new in v8)

Report 11 (`reports/11_recent-completion-consumption.md`) is the authoritative input for this
revision. Its verdict is **REVISE → GO**: the Phase-2 blocker is genuinely cleared, all four
deferred bracket lemmas map cleanly to delivered green assets (D1/D2 with no residue; D3/D4 with
the F2 residue discharged by the 354 bundle templates), and the residual is bounded engineering
(the bracket-wrapper assembly) + plan-text (the statement-shape update), not open mathematics.
v8 realizes the six concrete edits report 11 §4(c) prescribes:

1. Phase 2 `[BLOCKED]` → split into a preserved determinacy core (COMPLETED) + two new open
   bracket phases (`_sound`, `_complete`); the stale BLOCKER block and "do not re-dispatch"
   instruction are removed.
2. The bracket lemmas are re-pointed at the delivered assets per the §3 consumption table.
3. The D3/D4 `_complete` statements now thread `P : ExistProviders` and the carried
   `hreal`/`hsat` — documented as a **DISCHARGED interface** (not byte-identical to k=2).
4. Phase 6's ⇐ direction discharges `hreal`/`hsat` via `kvE_futBundle_of_realizer` /
   `kvE_pastBundle_of_realizer` (354).
5. Imports: the depth-`k` bracket-assembly work lands in a NEW module
   `ExteriorBracketAssembleK.lean` importing `ExteriorConverterK`/`ExteriorConverterPastK` +
   `ExteriorBracketK` (the frozen `ExteriorBracketK.lean` is NOT reopened).
6. The Preserved-Assets table + H3 Tier-1 mapping are extended with the 352/354 modules.

**v7 does NOT depend on the refuted flat `extF4` route** (report 11 §4a): `extF4` was a
352/353-internal converter shape (flat arity-5, all four `[x1,w,x,t]` pinned as a
`temporal_truth … t` LHS), machine-refuted by the 353 NO-GO. v7/v8's Phase-2 targets are the
**bracket** lemmas over a 2-endpoint architecture (`VVecEA2.holds … x t`); 354 then delivered the
faithful nested-re-anchoring mechanism the bracket layer sits on top of. The carrier is unaffected.

### The `hreal`/`hsat` interface is DISCHARGED, not debt (binding disclosure)

The depth-`k` `_complete` converters carry two extra hypotheses beyond the frozen k=2 template:
`hreal` (the fiber-forward realization bundle) and `hsat` (the exterior-anchor saturation
residue). These are the faithful F2-sidestep: the task-353 NO-GO proves they are **not in-module
derivable**, and the task-354 bundle templates `kvE_futBundle_of_realizer` (:208) /
`kvE_pastBundle_of_realizer` (:177) prove they are **dischargeable from a genuine exterior
realizer** — a pure read of `nf_eval_nfk_iff_efold`. The v8 architecture threads them as an
explicit joint-depth-content interface through the bracket-`complete` layer (Phase 4) and
discharges them one level up in Phase 6's ⇐ direction, where the outer recursion produces a
genuine realizer by picking `x1` at the Rabinovich inf/sup. This is exactly plan-BLOCKER
resolution (c) ("weaken the Phase-2 statements with an explicit joint-depth-content hypothesis
dischargeable by Phase 4") realized concretely. **Phase 8's axiom/debt audit MUST record
`hreal`/`hsat` as a discharged interface, citing the 354 bundle templates — never as debt or a
weakened Rabinovich step** (report 11 §5 disclosure item).

### Preserved Assets

Complete, green, sorry-free — **consume by name, do NOT rebuild or regress.**

| Component | File:line | Status | Role in v8 |
|-----------|-----------|--------|------------|
| **Phase 1 — general-`k` fold bridge** `nf_eval_nfk_iff_efold` (+ `nfk_dropFresh`/`nfk_zoneSpec`/`nf_eval_nf_atom_layer`, `nf_eval_efold_k`, k=1 recovery) | NfEFold.lean:627 | **[COMPLETED] (preserved)** | THE fold characterization every clause/bracket layer consumes; DONE + committed under v7 |
| **Phase 2 determinacy core** (ExteriorBracketK.lean) — `nfk_truncD`/`nf_eval_truncD` (:62/:80), `nf_eval_take`/`nf_eval_projFresh` (:111/:163), `kvE_sepPos`/`kvE_projFreshD`/`nf_eval_projFreshD` (:183/:198/:203), `kvE_futAnyBit`+`_correct` (:218/:230), `kvE_subBit`+`_iff` (:302/:314), `kvE_projFreshD_zero`/`kvE_futAnyBit_zero` (:376/:389) | ExteriorBracketK.lean | **[COMPLETED] (preserved, FROZEN)** | the depth-`k` `habove`/`hbelow` determinacy pins the bracket layer consumes; DONE + committed under v7. **Now a NO-EDIT frozen file** (v8 imports it, never reopens it) |
| `kvE_extNegFut_sound` / `kvE_extNegPast_sound` (352, `_sound` clause halves) | ExteriorNegationK.lean:532 / ExteriorNegationPastK.lean:539 | [COMPLETED] task 352 | consumed by Phase 3 (D1/D2) and the bit-true arm of Phase 4 (D3/D4) |
| `kvE_futAdmissible` / `kvE_futRealizer_admissible` (352 marking predicate + realizer bridge) | ExteriorNegationK.lean:86 / :124 | [COMPLETED] task 352 | the depth-`k` bracket defs are built over `kvE_futAdmissible`; realizer⇒admissible bridges the sound proof |
| `kvE_futPos` / `kvE_extNegFut` (positive clause / its complement) | ExteriorNegationK.lean:415 / :425 | [COMPLETED] task 352 | the per-σ `if bit then kvE_futPos else kvE_extNegFut` clause the bracket conjoins |
| `kvE_futChainDestructG` / `kvE_pastChainDestructG` (Cor 5.4 chain destructors) | ExteriorNegationK.lean:293 / ExteriorNegationPastK.lean:353 | [COMPLETED] task 352 | drive the chain inside the delivered `_complete`; consumed indirectly |
| `kvE_extNegFut_complete` / `kvE_extNegPast_complete` (354 reverse converters — thread `P`, carry `hreal`/`hsat`) | ExteriorConverterK.lean:119 / ExteriorConverterPastK.lean:94 | [COMPLETED] task 354 | consumed by the bit-false arm of Phase 4 (D3/D4) |
| **`kvE_futBundle_of_realizer` / `kvE_pastBundle_of_realizer`** (354 discharge templates: genuine realizer ⇒ `hreal` ∧ `hsat`) | ExteriorConverterK.lean:208 / ExteriorConverterPastK.lean:177 | [COMPLETED] task 354 | **the load-bearing discharge** for `hreal`/`hsat` in Phase 6 ⇐ |
| `kvE_futAtom_of_bundle` / `kvE_futAdmissible_fiber_dichotomy`/`_onFiber`/`_offFiber` (+ Past mirrors) | ExteriorConverterK.lean:92/48/63/73 (Past :72/33/48/57) | [COMPLETED] task 354 | fiber-layer support the `_complete` converters need; consume by name |
| `bracketEndChar_kvE2Ext` / `_holds_iff` / `_correct_two_prior_frag` (k=2 enriched gate + Lemma-7.6 adjacency + correctness TEMPLATE) | ExteriorBracket.lean:661/674/1069 | [COMPLETED] FROZEN | the k=2 line-by-line template Phases 3-7 mirror |
| `kvE2_extBracketPast/Fut` + `_sound`/`_complete` + `_exists` (k=2 bracket layer) | ExteriorBracket.lean:432/456/583/547/483/513 | [COMPLETED] FROZEN | the byte-identical proof template for D1-D4; `_exists` are the ⇒-side positive residue templates |
| `nfEval_le2_reduction` (Rabinovich Lem 3.2(2)) | Lemma32Reduction.lean:535 | [COMPLETED] task 351 | Step-A interior arity reduction — used in the Phase-5 step body / interior content, NOT in the bracket lemmas (frozen — consume only) |
| `ExistProviders` / `existF` (provider interface) | PriorInterface.lean:38-40 | [COMPLETED] | the depth-`k` provider channel `P` threaded through the clause layer + brackets + step |
| `nf_eval_unique` (depth-general fold-fiber determinacy) | NormalForm.lean:245 | [COMPLETED] | determinacy input beneath every layer |
| `BracketEndCharCarrierV` (frozen v6 codomain) / `endInterval` skeleton + `EndIntervalCorrect` | CarrierK1V.lean:365 / 2159/2179 | [COMPLETED] | recursion motive (UNCHANGED); `Nat.rec` shape reused; `EndIntervalCorrect` → `EndIntervalCorrectPrior` (bounded revise, Phase 5) |
| `bracketEndChar_k1v` family + k1v kit | CarrierK1V.lean:433/513-2039/2041 | [COMPLETED] | k=1 base of the `Nat.rec`; proof kit |
| `f2_relativized_refutation` / `endCharN0_correct_infeasible` (negative guardrails) | RefutationF2.lean:859 / Base.lean:1779 | [COMPLETED] | machine-checked reasons the refuted carriers are dead |

### FROZEN files — byte-identical, `git diff` EMPTY at every commit (do NOT edit)

The 7 original frozen providers **plus** two files now frozen for v8:
1. `NfMultiAnchorBridge/SharedWitness.lean` 2. `NfMultiAnchorBridge/SubBracket2V.lean`
3. `NfMultiAnchorBridge/OuterGate.lean` 4. `NfMultiAnchorBridge/ExteriorBracket.lean`
5. `NfMultiAnchorBridge/ExteriorZoneTriage.lean` 6. `Kamp/ExteriorNegation.lean`
7. `Kamp/ExteriorNegationPast.lean`
8. `NfMultiAnchorBridge/ExteriorBracketK.lean` (the landed Phase-2 determinacy core — v8 imports,
   never reopens it) 9. `KampPrior.lean` and `Lemma32Reduction.lean` (NO-EDIT).

The delivered depth-`k` clause modules (`ExteriorConverterK`/`PastK`, `ExteriorNegationK`/`PastK`,
`ExteriorFiberK`) are **consume-only** — additive imports, never edited. All v8 NEW declarations
land in **`NfMultiAnchorBridge/ExteriorBracketAssembleK.lean`** (Phases 3-4) and additive tails of
`CarrierK1V.lean` (Phases 5-7). `NfEFold.lean`, `PriorInterface.lean`, `Base.lean`,
`NavigatedEndChar.lean` are NOT frozen (additive edits sanctioned).

### Consumption Mapping (deferred bracket lemma → consumed asset → gluing sketch)

Verbatim from report 11 §3. The k=2 bracket proofs are short (≈15-35 lines each) and are the
line-by-line template; each depth-`k` bracket lemma is a conjunction-over-admissible-σ of
`if σ.2-bit then kvE_futPos else kvE_extNegFut`, discharged per-σ by the delivered clause layer.

| # | Deferred lemma | k=2 template | Consumed assets | Gluing sketch |
|---|----------------|--------------|-----------------|---------------|
| **D1** | `kvE_extBracketFut_sound` | `kvE2_extBracketFut_sound` (ExteriorBracket.lean:432) | `kvE_extNegFut_sound` (352, :532) + `kvE_futAdmissible`/`kvE_futRealizer_admissible` (352, :86/:124) | Mirror ExteriorBracket.lean:432-452: bracket-true@`t` ⇒ per-σ clause; a bit-false **admissible** σ ⇒ `kvE_extNegFut` holds ⇒ `kvE_extNegFut_sound` refutes any exterior realizer `x1 > t`. **CLEAN — no F2 residue.** |
| **D2** | `kvE_extBracketPast_sound` | `kvE2_extBracketPast_sound` (ExteriorBracket.lean:456) | `kvE_extNegPast_sound` (352, :539) + past admissibility (352) | Mirror ExteriorBracket.lean:456-476, `x1 < x`. **CLEAN.** |
| **D3** | `kvE_extBracketFut_complete` | `kvE2_extBracketFut_complete` (ExteriorBracket.lean:547) | `kvE_extNegFut_complete` (354, :119) for bit-false σ + `kvE_extNegFut_sound` (352) for bit-true σ; discharge via `kvE_futBundle_of_realizer` (354, :208) | Mirror ExteriorBracket.lean:547-579: per-σ, bit-true ⇒ `hpos` gives a realizer, `kvE_extNegFut_sound` contrapositive; bit-false ⇒ `kvE_extNegFut_complete`. **RESIDUAL: threads `hreal`/`hsat`, discharged in Phase 6 via `kvE_futBundle_of_realizer`.** |
| **D4** | `kvE_extBracketPast_complete` | `kvE2_extBracketPast_complete` (ExteriorBracket.lean:583) | `kvE_extNegPast_complete` (354, :94) + `kvE_extNegPast_sound` (352); discharge `kvE_pastBundle_of_realizer` (354, :177) | Mirror ExteriorBracket.lean:583-615. Same residual as D3, Past side. |

**Residual gaps flagged by report 11 §3** (bounded engineering / plan text, not open math):
- **G-a — Layer not lemma.** 354 delivered the **clause** layer; the deferred four are the
  **bracket** wrapper conjoining clauses over admissible σ (~150-200 additive lines).
- **G-b — Marking predicate shape.** The clause layer keys on `kvE_futAdmissible`
  (ExteriorNegationK.lean:86), NOT the frozen k=2 `kvE2_futMarked`; build the bracket defs over
  `kvE_futAdmissible`, using `kvE_futRealizer_admissible` (:124) for the realizer⇒admissible step.
  The implementer confirms the exact bridging shape.
- **G-c — `_complete` carries `hreal`/`hsat`.** NOT byte-identical to k=2 — see the DISCHARGED
  interface disclosure above.
- **G-d — Provider parameter + imports.** The clause layer is threaded on
  `P : ExistProviders sig atomMap k`; the bracket defs inherit `P`. New assembly module imports
  the Converter modules (all additive; frozen files stay clean).

### Source-to-Implementation Mapping (H3, Tier 1 — Rabinovich 2014)

Source: `~/Projects/Literature/sources/rabinovich_2014/Rabinovich_2014_Proof_of_Kamps_Theorem.md`.
5-column format per the lean4 reference-grounding override.

| Source (Rabinovich 2014) | Prop/Location | Lean Identifier | Type Signature / Fact | Status |
|--------------------------|---------------|-----------------|-----------------------|--------|
| Lemma 3.2(2) — reduce to ≤2-free conjunction | md:119 (p.4) | `nfEval_le2_reduction` | arity-`n` → conjuncts of anchor-arity ≤3 | transcribed (351) |
| Prop 4.3 — innermost ∃-fold of the quantifier layer | PDF p.6 | `nf_eval_nfk_iff_efold` (NfEFold:627) | general-`k` fold determinacy, off-fiber via `nf_eval_unique` | **transcribed (Phase 1, DONE)** |
| Prop 4.2 — uniform negation/exclusion disjunctions (joint-pinning channel), **clause layer** | md:165 (p.7) | `kvE_extNegFut/Past` + `_sound` (352) / `_complete` (354) | per-side exterior exclusion, depth-`k` | **transcribed (352/354)** |
| Prop 4.2 — the **bracket** wrapper over admissible σ | md:165 (p.7) | `kvE_extBracketFut/Past_sound`/`_complete` (Phases 3-4) | conjunction-over-admissible-σ of the clause layer | pending (Phases 3-4) |
| Cor 5.4 — chain destructor + bundle discharge | md:255 (§5) | `kvE_futChainDestructG` (352) / `kvE_futBundle_of_realizer` (354, :208) | chain re-anchoring + `hreal`/`hsat` discharge from a realizer | transcribed (352/354) |
| Lemma 7.6 — adjacency composition | md:413 (§7) | `bracketEndChar_kvE2Ext_holds_iff` (:674); Phase-5 general-`k` analog | holds ↔ interior ∧ bracketPast@x ∧ bracketFut@t | transcribed (k=2); pending (Phase 5) |
| Def 7.13 — multi-anchor bracket family | md:451 (§7) | `BracketEndCharCarrierV` / VVecEA2 disjuncts | the two-endpoint enriched bracket type | transcribed |
| Cor 5.4 — endpoint characteristic chain (the recursion this task builds) | md:255 (§5) | `endInterval` / `endIntervalStep` / `endInterval_correct` | `(endInterval k qnf).holds M atomMap x t ↔ ∃ w, nf_eval_nf M k 3 [w,x,t] qnf` under Prior | pending (Phases 5-7) |

## Goals & Non-Goals

**Goals**:
- Build the four depth-`k` exterior-bracket lemmas D1-D4 in a NEW additive module
  `ExteriorBracketAssembleK.lean`, consuming the delivered 352/354 clause layer per the
  Consumption Mapping: D1/D2 `_sound` (clean), D3/D4 `_complete` (threading the DISCHARGED
  `hreal`/`hsat` interface + `P : ExistProviders`), built over `kvE_futAdmissible`.
- Fill the `endIntervalStep` hole (CarrierK1V.lean:2144) with the general-`k` enriched body
  (interior at FULL arity 4 via depth-`k` providers + the two adjacent Phase-3/4 brackets,
  Lemma-7.6 adjacency); bounded-revise `EndIntervalCorrect` → `EndIntervalCorrectPrior`.
- Prove step soundness + completeness generalizing the green k=2 gate, with the ⇐ direction
  discharging `hreal`/`hsat` via the 354 bundle templates; close the recursion by induction on
  `k`; `endInterval_correct` sorry-free with axioms exactly `[propext, Classical.choice, Quot.sound]`.

**Non-Goals**:
- Editing any FROZEN file (the 7 providers, `ExteriorBracketK.lean`, `KampPrior.lean`,
  `Lemma32Reduction.lean`, `nf_nvar_exist_all_depths`'s signature) or the consume-only delivered
  clause modules.
- Re-deriving the depth-`k` clause layer (352/354 delivered it — consume by name).
- Any single-point `→ TemporalPred` recursion carrier, `navPieceForm`, `h_res` threading,
  `kv_body`/`nfk_projFresh` arity-1 projection, arity-4 collapse, per-pair `∀ij∃w`, or the flat
  `extF4` route — all machine-refuted (postmortem / 353 NO-GO).
- Wiring `KampPrior.lean:361` (task 309 Phase 14, downstream), the top-level ≤1-free extraction
  (Prop 3.5 / Thm 4.4, downstream 350/309), or restoring any Boneyard file.

## Postmortem Constraints

Binding rules for all implementation dispatches. Carried forward verbatim from v7 (the FOUR
carrier strikes + root cause remain machine-grounded). **Landing any forbidden construct is a
`[BLOCKED]` escalation, never a silent workaround.**

**Do NOT** (each machine-grounded; violation = STOP + `[BLOCKED]` + exact `lean_goal` + `/spawn 349`):
1. Re-introduce the single-point `→ TemporalPred` recursion carrier or any motive read at a
   single world `w` (strike 1; `endCharN0_correct_infeasible`).
2. State `navPieceForm_correct` or any single-point closed-formula `↔` for a ≥2-free-anchor target
   (shape `temporal_truth w φ ↔ ∃v, nf_eval_nf … [v,w,x,t] sub`) — regression signal: STOP.
3. Thread an `h_res` (atom-residual) hypothesis to pin anchors (no Rabinovich analogue).
4. Read any sub through the arity-1 projection `nfk_projFresh`, or resurrect
   `kv_body`/`bracketEndChar_kv` (strike 3; F2-dead). Interior obligations are stated at FULL
   arity 4, period. **(G1)**
5. Use an arity-4 enclosing-pair/single-point collapse or any `nfRestrict`-based arity collapse on
   the interior read. Full-arity reading is NOT collapse (`x1,w` are bracket witnesses,
   anchors `{x,t}`).
6. Use the per-pair `∀ij∃w` distribution (non-theorem for n ≥ 3); the witness stays outside the
   reduced inner form.
7. Fake green: no `sorry`, no `def X := True`/`Unit`/vacuous stub, no `simp`/`omega`/`aesop`
   shortcut that silently weakens a Rabinovich chain step **(G5)**. A stuck main target is
   `[BLOCKED]` + exact `lean_goal` + `/spawn 349`. The honest empty-disjunction placeholder
   (`⟨[]⟩`) is the ONLY sanctioned deferred-body form, and only for a hole a later phase fills.
8. Import `MergedBracketQuarantine` or restore any Boneyard file (extraction is reference-only,
   verified against the live k=2 `kvE2Ext`). **FORBIDDEN `nf_char3_deeper_split`** (refuted route,
   grows the anchor set to 4) must be grep-clean in all new code.
9. Edit any FROZEN file. The delivered 352/354 clause modules are **consume-only** — never edited.

**Guards (binding, restated verbatim — checked every phase)**:
- **G1** — no arity-1 interior collapse: no `nfk_projFresh` on any sub read; interior obligations
  everywhere at FULL arity 4 (`nf_eval_nf M k 4 (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t)))) σ`).
  **Sanctioned nuance** (report 11 §5, record so the completion gate does not misflag it): the 352
  fiber machinery (`ExteriorFiberK.lean:182`, `ExteriorNegationK.lean:81/103`) uses `nfk_projFresh`
  for **fiber-bucket zone classification** — the faithful Rabinovich bucketing, NOT the F2-forbidden
  interior-content collapse. New v8 code (the bracket wrapper) introduces NO `nfk_projFresh`.
- **G2/G4** — free anchors strictly ⊆ {x,t}, ≤2: each converter exposes a single evaluation point
  (`temporal_truth M atomMap t (…)` Future / `… x (…)` Past); the exterior anchor `x1`, interior
  `w`, and fiber witness `v` are quantified (`∀ x1`, `∃ v`), never free anchors. `w` and all
  disjunct/bracket witnesses are bound witnesses, never a third free anchor.
- **G3** — non-trivial segment: `kvE_extNegFut` is a genuine complement (negation of `kvE_futPos`);
  interior segments are real exclusions, never `TemporalPred.top`.
- **G5** — no `simp`/`omega`/`aesop` shortcut of a Rabinovich chain step: manual bridges
  (`constructor`/`intro`/`obtain`/`rw`/`exists_congr`/`and_congr`) on every chain step, mirroring
  the k=2 kit and the delivered clause-layer discipline (`simp` only in trivial membership goals,
  `decide` only for Bool absurdity).
- **FORBIDDEN `nf_char3_deeper_split`** — grep-clean in all new code.
- **Frozen files** — the 7 providers + `KampPrior.lean` + `Lemma32Reduction.lean` +
  `ExteriorBracketK.lean` byte-identical (`git diff` EMPTY); all v8 work additive-only.
- **Axioms** — exactly `[propext, Classical.choice, Quot.sound]` on every headline decl; no new
  axiom; sorry-free or `[BLOCKED]` + escalate (never a vacuous/sorry'd `endChar`).

**Design decisions are SETTLED** (do not re-open without a machine-checked counterexample): the
carrier is carrier 3 (enriched-segment bracket, `BracketEndCharCarrierV`); interior reads at FULL
arity 4; correctness is Prior-guarded (`EndIntervalCorrectPrior`); providers thread via
`ExistProviders`; the general-`k` work is construction, not open mathematics. **New for v8**: the
depth-`k` clause layer is DELIVERED (352/354) — the remaining bracket layer is a bounded additive
wrapper, and `hreal`/`hsat` is a discharged interface, not debt.

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| **Bracket-wrapper `_sound` (D1/D2) drifts from the k=2 shape via the `kvE_futAdmissible` vs `kvE2_futMarked` marking mismatch (G-b)** | M | M | Build the bracket defs over `kvE_futAdmissible`; use `kvE_futRealizer_admissible` (:124) for the realizer⇒admissible step; confirm the exact bridging shape before the proof. Template is ExteriorBracket.lean:432-476. Diff-check ExteriorBracket.lean EMPTY. |
| **`_complete` (D3/D4) `hreal`/`hsat` threading balloons or is mis-shaped (G-c)** | H | M | Thread `hreal`/`hsat` verbatim from the delivered `kvE_extNegFut/Past_complete` signatures (ExteriorConverterK.lean:119 / PastK:94) as bracket-`complete` hypotheses; do NOT attempt to discharge them in Phase 4 — discharge is Phase 6's job via the bundle templates. Sanity-check the k=2 instance interderives. Stop: side/direction closed OR `[BLOCKED]` + `lean_goal`. |
| **Phase-6 ⇐ fails to produce a genuine realizer to feed `kvE_futBundle_of_realizer`** | H | M | The outer recursion picks `x1` at the Rabinovich inf/sup, producing `∃ w, nf_eval_nf M (k+1) 3 [w,x,t] qnf`; feed it through the Phase-1 bridge to a genuine `nf_eval_nf M (k+1) 4 [x1,w,x,t] σ`, then `kvE_futBundle_of_realizer` (:208) yields `hreal ∧ hsat`. This is a pure read (report 11 §1b). If the realizer reconstruction blocks, `[BLOCKED]` + `lean_goal` on the specific reconstruction, `/spawn 349`. |
| **Step-correctness (Phase 6) overruns one run** — the k=2 gate proof is large | H | M | Pre-declared split by DIRECTION (6a soundness ⇒ / 6b completeness ⇐ + ↔ assembly), mirroring `_sound_two_prior_frag`/`_complete_two_prior`. Commit each green direction. |
| **Provider-recursion termination/well-foundedness fails to typecheck** (Phase 7) | M | M | `Nat.rec` shape already green (v6 skeleton); keep `endInterval_correct` provider-family-parametric (k=2 gate threads obligations as hypotheses); record the discharge obligation for 309. |
| **Regression onto a refuted carrier / projection** because a sub-goal "would be easier" | H | L | PROHIBITED (Do-NOT 1-6). Discriminators: interior obligations MUST be `nf_eval_nf M k 4 …`; any NEW `nfk_projFresh`, any `temporal_truth w φ ↔ ∃v …` goal = STOP. |
| **Accidental frozen-file edit** (now includes `ExteriorBracketK.lean`) | H | L | All new decls in `ExteriorBracketAssembleK.lean` + CarrierK1V additive tails; `git status --short` + `git diff --staged` before every commit; the 8 frozen files + KampPrior + Lemma32Reduction byte-identical. |
| Fake green under pressure | H | M | PROHIBITED (Do-NOT 7); `[BLOCKED]` + `lean_goal` + `/spawn 349`. |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 0 | 1, 2 | — (**preserved, COMPLETED**) |
| 1 | 3 | 1, 2 |
| 2 | 4 | 3 |
| 3 | 5 | 4 |
| 4 | 6 | 5 |
| 5 | 7 | 6 |
| 6 | 8 | 7 |

Phases 1-2 are preserved green assets (no dispatch). The open chain is 3 → 4 → 5 → 6 → 7 → 8
(bracket-sound → bracket-complete → step body/statement → step correctness → recursion close →
audit). **Declared parallel opportunity (H7)**: Phase 5's statement-only sub-unit
(`EndIntervalCorrectPrior`, CarrierK1V.lean) is file-disjoint from Phases 3-4
(`ExteriorBracketAssembleK.lean`) and depends only on the frozen k=2 gate shape — an orchestrator
MAY dispatch it alongside Phase 4 under a territory contract; the wave table is the safe default.

**Per-phase hard bar (every open phase)**:
- Ends GREEN + sorry-free: scoped `lake build` of the touched module(s) GREEN (whole-tree GREEN at
  Phase 8); `lean_verify` on the phase's headline decl(s) = exactly
  `[propext, Classical.choice, Quot.sound]`; no new axiom.
- Preserved/delivered assets consumed by name (reuse-vs-rebuild note satisfied); zero frozen-file
  diffs (`git diff` on the 8 frozen files + KampPrior.lean + Lemma32Reduction.lean EMPTY).
- Guards G1-G5 + FORBIDDEN grep-clean in new code (see Postmortem Constraints).
- Commit per green sub-step (`task 349 phase {P}.{O}: …`).

### Phase 1: General-`k` fold bridge `nf_eval_nfk_iff_efold` (construction gate) [COMPLETED]

- **Preserved asset — DONE + committed under v7. Do not re-plan or regress.** The general-`k`
  inside-out whole-evaluation fold bridge (k-analog of `nf_eval_nf1_iff_efold`) is green,
  sorry-free, axiom-clean at `NfEFold.lean:627`, with the depth-`k` index plumbing
  (`nfk_dropFresh`/`nfk_zoneSpec`/`nf_eval_nf_atom_layer`, `nf_eval_efold_k`) and the k=1 recovery
  instance. It is the load-bearing fold characterization every clause and bracket layer consumes.
- **Done when:** (met) `nf_eval_nfk_iff_efold` green, sorry-free, axiom-clean; k=1 instance
  recovered; scoped build GREEN.
- **Files:** `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfEFold.lean` (NO further edits — frozen for v8 scope by convention; additive-only if ever touched).

### Phase 2: Depth-`k` bracket determinacy core (ExteriorBracketK.lean) [COMPLETED]

- **Preserved asset — DONE + committed under v7. Do not re-plan or regress. Now a FROZEN,
  NO-EDIT file (v8 imports it, never reopens it).** The design-invariant determinacy core landed
  green + sorry-free + axiom-clean in `ExteriorBracketK.lean` (v7 commits 34a173e88, af794abcb,
  c4c5c7eb1): `nfk_truncD`/`nf_eval_truncD`, `nf_eval_take`/`nf_eval_projFresh`,
  `kvE_sepPos`/`kvE_projFreshD`/`kvE_futAnyBit`+`_correct`, `kvE_subBit`/`_iff`,
  `kvE_projFreshD_zero`/`kvE_futAnyBit_zero` — the depth-`k` `habove`/`hbelow` determinacy pins the
  bracket wrapper consumes. **Note (v7 root cause, now resolved):** v7 attempted to also land the
  four bracket lemmas here against byte-identical k=2 statements and correctly discovered that is
  impossible in a leaf module (the faithful clause layer is provider-parameterized and its
  `_complete` carries the F2 residue). That layer is now DELIVERED by 352/354; Phases 3-4 assemble
  the bracket wrapper on top of it.
- **Done when:** (met) the determinacy core green, sorry-free, axiom-clean; frozen files
  byte-identical; scoped build GREEN.
- **Files:** `.../NfMultiAnchorBridge/ExteriorBracketK.lean` (FROZEN — no further edits).

### Phase 3: Bracket `_sound` layer — D1 `kvE_extBracketFut_sound` + D2 `kvE_extBracketPast_sound` [COMPLETED]

- **Goal:** Build the two depth-`k` exterior-bracket **soundness** lemmas by conjoining the
  delivered 352 `_sound` clause layer over admissible σ. **CLEAN — no F2 residue** (the sound
  direction needs no `hreal`/`hsat`).
- **Consumption (report 11 §3, D1/D2):**
  - D1 `kvE_extBracketFut_sound` ← `kvE_extNegFut_sound` (352, ExteriorNegationK.lean:532) +
    `kvE_futAdmissible`/`kvE_futRealizer_admissible` (352, :86/:124). Mirror
    ExteriorBracket.lean:432-452: bracket-true@`t` ⇒ per-σ clause (`_iff` unfold); a bit-false
    **admissible** σ ⇒ `kvE_extNegFut` holds ⇒ `kvE_extNegFut_sound` refutes any exterior realizer
    `x1 > t`.
  - D2 `kvE_extBracketPast_sound` ← `kvE_extNegPast_sound` (352, ExteriorNegationPastK.lean:539) +
    past admissibility. Mirror ExteriorBracket.lean:456-476, `x1 < x`.
- **Reuse vs rebuild:** REUSE the k=2 `_sound` proofs as the byte-identical template + the 352
  clause layer + the Phase-2 determinacy core (`kvE_futAnyBit`/`kvE_subBit_iff`). BUILD only the
  depth-`k` bracket defs (`kvE_extBracketFut`/`kvE_extBracketPast` over `kvE_futAdmissible`,
  threading `P : ExistProviders`) + the two `_sound` lemmas.
- **Tasks:**
  - [x] Define `kvE_extBracketFut`/`kvE_extBracketPast` (depth-`k` bracket builders, over
        `kvE_futAdmissible`, with `P : ExistProviders`) in the NEW module `ExteriorBracketAssembleK.lean`. *(completed — qnf : NormalForm sig (k+2) 3, subs σ : NormalForm sig (k+1) 4; + `_iff` unfold lemmas)*
  - [x] Confirm the G-b bridging shape: `kvE_futRealizer_admissible` (:124) supplies the
        realizer⇒admissible step the k=2 sound proof (ExteriorBracket.lean:448) uses. *(completed — depth-`k` `kvE_futRealizer_admissible`/`kvE_pastRealizer_admissible` take no henv/hbelow; simpler than k=2)*
  - [x] Prove D1 `kvE_extBracketFut_sound` (mirror :432-452 over `kvE_extNegFut_sound`). *(completed, axiom-clean)*
  - [x] Prove D2 `kvE_extBracketPast_sound` (mirror :456-476 over `kvE_extNegPast_sound`). *(completed, axiom-clean)*
  - [ ] Sanity: the k=2 instances of the new defs interderive with the frozen
        `kvE2_extBracketFut/Past_sound` (`example`-check, no edit to ExteriorBracket.lean). *(deviation: skipped — the depth-`k` defs are indexed at k+2/k+1 and cannot be instantiated at the frozen k=2 arity-3/arity-1 template shape without arity coercion; interderivation deferred to the Phase-6 gate where both meet. Not a correctness gap: axiom check + scoped build are green.)*
  - [x] Route audit: `git diff` on the 8 frozen files EMPTY; FORBIDDEN grep clean (no
        `nfk_projFresh` in new code, no `nf_char3_deeper_split`); anchors {x,t} (G2/G4); segments
        non-trivial (G3); manual bridges (G5); `lean_verify` on both `_sound` lemmas axiom-clean. *(completed — grep clean, frozen diffs empty, both axiom-clean)*
- **Bounded-unit stop condition:** both `_sound` lemmas green, OR `[BLOCKED]` + `lean_goal` on the
  specific side. If one side closes and the other blocks, commit the green side first.
- **Estimated output:** ~150-250 lines.
- **Timing:** ~2.5 hours.
- **Done when:** D1 + D2 green, sorry-free, axiom-clean; frozen files byte-identical; scoped build
  GREEN.
- **Depends on:** 1, 2 (preserved).
- **Files:** `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge/ExteriorBracketAssembleK.lean`
  (NEW; imports `ExteriorConverterK` + `ExteriorConverterPastK` + `ExteriorBracketK`).

### Phase 4: Bracket `_complete` layer — D3 `kvE_extBracketFut_complete` + D4 `kvE_extBracketPast_complete` (threads the DISCHARGED `hreal`/`hsat` interface) [NOT STARTED]

- **Goal:** Build the two depth-`k` exterior-bracket **completeness** lemmas over the delivered
  354 `_complete` converters (bit-false arm) + the 352 `_sound` halves (bit-true arm). These
  **thread `P : ExistProviders` and the carried `hreal`/`hsat`** as an explicit joint-depth-content
  interface — documented as DISCHARGED (discharged one level up in Phase 6), NOT as debt. This is
  the one place v8 deviates from v7's stale "byte-identical k=2 statement" prescription.
- **Consumption (report 11 §3, D3/D4):**
  - D3 `kvE_extBracketFut_complete` ← `kvE_extNegFut_complete` (354, ExteriorConverterK.lean:119)
    for bit-false σ + `kvE_extNegFut_sound` (352) for bit-true σ. Mirror ExteriorBracket.lean:547-579:
    per-σ, bit-true ⇒ `hpos` gives a realizer, `kvE_extNegFut_sound` contrapositive; bit-false ⇒
    `kvE_extNegFut_complete`. **Thread `hreal`/`hsat` verbatim from the 354 signature** as
    bracket-`complete` hypotheses; do NOT discharge here.
  - D4 `kvE_extBracketPast_complete` ← `kvE_extNegPast_complete` (354, ExteriorConverterPastK.lean:94)
    + `kvE_extNegPast_sound` (352). Mirror ExteriorBracket.lean:583-615, Past side, same residual.
- **Statement-shape update (report 11 §4c item 3 — SUPERSEDES the v7 "byte-identical" prescription):**
  the depth-`k` `_complete` signature carries `P : ExistProviders sig atomMap k`, the six order
  bits, and the carried `hreal`/`hsat` (or an explicit joint-depth-content hypothesis of that
  shape). Document them in the lemma docstring as the DISCHARGED F2-sidestep interface, citing
  `kvE_futBundle_of_realizer` (354, :208) / `kvE_pastBundle_of_realizer` (354, :177) as their
  Phase-6 discharge.
- **Reuse vs rebuild:** REUSE the k=2 `_complete` proofs as template + the 354 `_complete`
  converters + the 352 `_sound` halves + the Phase-3 bracket defs. BUILD only the two `_complete`
  lemmas.
- **Tasks:**
  - [ ] Fix the `_complete` signatures: thread `P`, the order bits, and `hreal`/`hsat` verbatim
        from `kvE_extNegFut/Past_complete` (ExteriorConverterK.lean:119 / PastK:94); document the
        DISCHARGED interface in the docstring.
  - [ ] Prove D3 `kvE_extBracketFut_complete` (mirror :547-579; bit-false arm via
        `kvE_extNegFut_complete`, bit-true via `kvE_extNegFut_sound` contrapositive).
  - [ ] Prove D4 `kvE_extBracketPast_complete` (mirror :583-615).
  - [ ] Sanity: the k=2 instance (with `hreal`/`hsat` trivially satisfied) interderives with the
        frozen `kvE2_extBracketFut/Past_complete` (`example`-check).
  - [ ] Route audit: 8 frozen diffs EMPTY; FORBIDDEN grep clean; G1 (full arity 4, no
        `nfk_projFresh` in new code); G2-G5; `lean_verify` on both `_complete` lemmas axiom-clean.
- **Bounded-unit stop condition:** both `_complete` lemmas green (carrying, not discharging,
  `hreal`/`hsat`), OR `[BLOCKED]` + `lean_goal` on the specific side/arm. Commit the green side first.
- **Estimated output:** ~150-300 lines.
- **Timing:** ~3 hours.
- **Done when:** D3 + D4 green, sorry-free, axiom-clean; the `hreal`/`hsat` interface documented as
  discharged (with the 354 bundle-template citation); frozen files byte-identical; scoped build GREEN.
- **Depends on:** 3.
- **Files:** `.../NfMultiAnchorBridge/ExteriorBracketAssembleK.lean` (additive tail).

### Phase 5: `endIntervalStep` general-`k` body + `EndIntervalCorrectPrior` statement freeze [NOT STARTED]

- **Goal:** Fill the v6 Phase-3 hole (CarrierK1V.lean:2144, currently `⟨[]⟩`) with the enriched
  general-`k` step body, and bounded-revise the correctness Prop to the Prior-guarded shape.
  Providers thread via `ExistProviders`, NOT via `rec` alone and NOT via a closed-formula `charF`
  fiber projection (the adjudicated v6 Phase-3 resolution).
- **Step body:** per-sub enriched content — interior point types via a depth-`k` provider
  (`P.existF 0`), interior segment realization via `P.existF 3` at **FULL arity 4**, exterior
  residue via the two adjacent Phase-3/4 brackets `kvE_extBracketPast` (at `x`) ∧
  `kvE_extBracketFut` (at `t`) — Lemma-7.6 adjacency. The signature extends the v6 freeze with the
  provider parameter (sanctioned re-freeze):
  ```lean
  noncomputable def endIntervalStep {sig} (atomMap) (h_surj) {k : Nat}
      (P : ExistProviders sig atomMap k) (rec : BracketEndCharCarrierV sig k) :
      BracketEndCharCarrierV sig (k+1)
  ```
  `endInterval` (CarrierK1V:2159) re-frozen accordingly (`Nat.rec`, base unchanged, step =
  `endIntervalStep` with the provider family threaded).
- **Statement freeze — `EndIntervalCorrectPrior`**, VERBATIM generalization of the k=2 gate
  `bracketEndChar_kvE2Ext_correct_two_prior_frag` (ExteriorBracket.lean:1069): under
  `semantic_prior_UZ`/`semantic_prior_SZ`, with the provider obligations
  (`hfrag`/`hrealI`/`hrealB`/`hexcl`, at full arity 4) and the six order bits, conclude
  `(endInterval atomMap h_surj k qnf).holds M atomMap x t ↔ ∃ w, nf_eval_nf M k 3 (Fin.cons w (Fin.cons x (fun _ => t))) qnf`.
  The old `EndIntervalCorrect` (CarrierK1V:2179) is retained inert with a superseded-by docstring.
- **Reuse vs rebuild:** REUSE `ExistProviders`/`existF`, the Phase-3/4 brackets, the v6 skeleton,
  VVecEA2 assembly vehicles, the k=2 gate's hypothesis package as the statement template. BUILD the
  body + statement + a `holds_iff` destructuring lemma (general-`k` analog of ExteriorBracket.lean:674).
- **Tasks:**
  - [ ] Extend/re-freeze `endIntervalStep` with `P : ExistProviders sig atomMap k`; define the body
        (enriched per-sub content + Phase-3/4 brackets); confirm `endInterval (k+1)` typechecks.
  - [ ] Prove `endIntervalStep_holds_iff` (Lemma-7.6 adjacency: holds ↔ interior ∧ bracketPast@x ∧
        bracketFut@t).
  - [ ] State `EndIntervalCorrectPrior` (Prop, compiles sorry-free — statement-only freeze; proof
        in Phases 6-7); document the verbatim correspondence to the k=2 gate's hypotheses.
  - [ ] Route audit: interior obligations at full arity 4 (G1); anchors {x,t} (G2/G4); segments
        real (G3); FORBIDDEN grep clean; 8 frozen files byte-identical; scoped build GREEN.
- **Bounded-unit stop condition:** body + `holds_iff` + statement all compile green, OR
  `[BLOCKED]` + `lean_goal`. If the body elaborates but `holds_iff` blocks, commit the body.
- **Estimated output:** ~200-350 lines.
- **Timing:** ~2.5 hours.
- **Done when:** `endIntervalStep` (real body, hole gone), `endIntervalStep_holds_iff`, and
  `EndIntervalCorrectPrior` green + sorry-free; `lean_verify` on the def + `holds_iff` axiom-clean;
  scoped build GREEN.
- **Depends on:** 4 (statement-only sub-unit parallelizable with 4 — see Dependency Analysis).
- **Files:** `.../NfMultiAnchorBridge/CarrierK1V.lean` (additive + the sanctioned
  `endIntervalStep`/`endInterval` re-freeze; imports `ExteriorBracketAssembleK` + `PriorInterface`).

### Phase 6: General-`k` step correctness — soundness + completeness (discharges `hreal`/`hsat`) [NOT STARTED]

- **Goal:** Prove the step-level gate biconditional at symbolic `k`, generalizing the GREEN k=2
  `bracketEndChar_kvE2Ext_correct_two_prior_frag` (ExteriorBracket.lean:1069): under Prior + the
  depth-`k` provider obligations, `(endIntervalStep P rec qnf).holds M atomMap x t ↔ ∃ w,
  nf_eval_nf M (k+1) 3 [w,x,t] qnf`.
- **Proof structure (mirror the k=2 template exactly):**
  - **⇒ (soundness)**: destructure via `endIntervalStep_holds_iff`; thread the provider obligations
    as hypotheses (k=2 gate :1106-1129); discharge the exterior residue by splitting each
    strictly-exterior realizer to its side and refuting via the Phase-3 `kvE_extBracketPast/Fut_sound`
    (the k=2 :1126-1128 move, one fold-layer deeper); interior realization at full arity 4.
  - **⇐ (completeness)**: from `∃ w, nf_eval_nf M (k+1) 3 [w,x,t] qnf`, apply the Phase-1 bridge to
    expose the fold + off-fiber facts, rebuild interior content via the providers, and the two
    brackets via the Phase-4 `kvE_extBracketPast/Fut_complete`. **This is where `hreal`/`hsat` are
    DISCHARGED:** pick `x1` at the Rabinovich inf/sup to produce a genuine exterior realizer
    `nf_eval_nf M (k+1) 4 [x1,w,x,t] σ`, then invoke `kvE_futBundle_of_realizer` (354, :208) /
    `kvE_pastBundle_of_realizer` (354, :177) to produce `hreal ∧ hsat`, and feed them to the
    bracket-`complete` lemmas. Mirrors `_complete_two_prior` (OuterGate.lean:147) + the k=2
    assembly (:1138+).
- **Reuse vs rebuild:** REUSE the whole k=2 gate proof as line-by-line template, the Phase-1
  bridge, the Phase-3/4 brackets, `endIntervalStep_holds_iff`, and the 354 bundle templates. BUILD
  only the `k`-parametric sound/complete/↔.
- **Pre-declared split (bounded-unit guard):** 6a = soundness (⇒); 6b = completeness (⇐, including
  the `hreal`/`hsat` discharge) + ↔ assembly. If a direction overruns one run, it is its own
  dispatch; commit each green direction.
- **Tasks:**
  - [ ] Prove `endIntervalStep_sound_prior_frag` (⇒), manual bridges (G5), obligations threaded as
        hypotheses (k=2 pattern), exterior residue via Phase-3 `_sound`.
  - [ ] Prove `endIntervalStep_complete_prior_frag` (⇐), discharging `hreal`/`hsat` via the 354
        bundle templates from the reconstructed exterior realizer, then Phase-4 `_complete`.
  - [ ] Assemble `endIntervalStep_correct_prior_frag` = ⟨sound, complete⟩.
  - [ ] Route audit: no single-point `↔` goal shape (STOP signal); no `nfk_projFresh` in new code;
        interior at full arity 4; anchors ≤2; FORBIDDEN grep clean; 8 frozen files byte-identical;
        record the `hreal`/`hsat` discharge (bundle-template citation) for the Phase-8 audit.
- **Bounded-unit stop condition:** per-direction closed OR `[BLOCKED]` + exact `lean_goal` +
  `/spawn 349` for the specific missing sub-lemma. The statement is NON-refuted — a block is a
  construction gap, never a carrier question.
- **Estimated output:** ~300-500 lines (split 6a/6b if overrunning).
- **Timing:** ~4 hours.
- **Done when:** step gate biconditional green + sorry-free at symbolic `k`; `hreal`/`hsat`
  discharged via the 354 templates (no residual hypothesis leaks past the step gate);
  `lean_verify` axiom-clean; scoped build GREEN.
- **Depends on:** 5.
- **Files:** `.../NfMultiAnchorBridge/CarrierK1V.lean` (additive; or `ExteriorBracketAssembleK.lean`
  tail if the implementer keeps gate lemmas with the brackets — declare in handoff).

### Phase 7: Recursion close — provider-step + `endInterval_correct` by induction on `k` [NOT STARTED]

- **Goal:** Close the `Nat.rec` and prove `endInterval_correct : EndIntervalCorrectPrior …` by
  induction on `k`: base = the green k=1 family (`bracketEndChar_k1v_correct`, CarrierK1V:2041, via
  the v6 base embedding), step = Phase 6's gate with the IH supplying the depth-`k` characterization.
- **Provider threading (349-scoped, SETTLED):** provider-family parametric — `endInterval_correct`
  takes the provider family + per-depth obligations as hypotheses, exactly as the k=2 gate threads
  `hfrag`/`hrealI`/`hrealB`/`hexcl`. A provider-step lemma is built here to the extent it stays
  inside NfMultiAnchorBridge scope; the full unconditional instantiation against
  `nf_nvar_exist_all_depths` is task 309 Phase 14 (KampPrior NO-EDIT). Record precisely which
  obligations remain hypothesis-side in the summary + handoff.
- **Reuse vs rebuild:** REUSE the Phase-6 gate, the v6 base case (the k1v family), the `Nat.rec`
  skeleton. BUILD the induction assembly + provider-step.
- **Tasks:**
  - [ ] Prove the provider-step lemma (bounded; if it demands out-of-scope KampPrior machinery,
        keep that piece hypothesis-side and document — NOT a block).
  - [ ] Prove `endInterval_correct` by induction on `k` (base + Phase-6 step with IH).
  - [ ] Confirm `endInterval` genuinely recurses (not vacuous; step body is the Phase-5 body, not `⟨[]⟩`).
  - [ ] Route audit: FORBIDDEN grep clean over all new v8 code; 8 frozen files byte-identical;
        `endInterval_correct` is a top-level citable name.
- **Bounded-unit stop condition:** induction closes OR `[BLOCKED]` + `lean_goal` on the specific
  step-instantiation mismatch. Typecheck/termination issues are re-indexing work, not carrier
  questions.
- **Estimated output:** ~200-350 lines.
- **Timing:** ~2.5 hours.
- **Done when:** `endInterval`/`endInterval_correct` green + sorry-free by induction;
  `lean_verify endInterval_correct` = exactly `[propext, Classical.choice, Quot.sound]`; scoped
  build GREEN.
- **Depends on:** 6.
- **Files:** `.../NfMultiAnchorBridge/CarrierK1V.lean` (additive).

### Phase 8: Axiom audit + whole-project build + H3/interface finalization [NOT STARTED]

- **Goal:** Confirm every definition-of-done gate on the assembled result; no new source code.
- **Tasks:**
  - [ ] Whole-project `lake build` GREEN.
  - [ ] `lean_verify` (warm) on `endInterval_correct`, `endIntervalStep_correct_prior_frag`
        (+ `_sound`/`_complete`), the four Phase-3/4 bracket lemmas (D1-D4), `endIntervalStep`,
        `endInterval` — all exactly `[propext, Classical.choice, Quot.sound]`, no `sorry`, no new
        axiom. (Cheap positive re-confirmation of the delivered `kvE_extNegFut/Past_complete` is
        included per report 11 §1e.)
  - [ ] FORBIDDEN-list grep over all v8-touched files clean; `git diff` on the 8 frozen files +
        KampPrior.lean + Lemma32Reduction.lean EMPTY across the whole v8 range;
        `nf_nvar_exist_all_depths` signature untouched.
  - [ ] **Record `hreal`/`hsat` as a DISCHARGED interface** (citing `kvE_futBundle_of_realizer` /
        `kvE_pastBundle_of_realizer`, 354), NOT debt — in the plan STATUS column and the summary.
        Note the sanctioned `nfk_projFresh` fiber-bucketing role (report 11 §5) so the audit does
        not misflag it.
  - [ ] Finalize the H3 Tier-1 mapping STATUS column (pending → transcribed); any residual
        hypothesis-side provider obligation documented with its 309-Phase-14 discharge pointer.
  - [ ] Confirm `endInterval_correct` reachable/citable for 309 Phase 18/19 / 350 (name-level grep).
- **Bounded-unit stop condition:** verification-only phase; any RED finding routes back to the
  owning phase as a defect (churn-counter applies), never patched ad hoc here.
- **Estimated output:** ~0-50 lines (docstring/plan edits only).
- **Timing:** ~0.5 hours.
- **Done when:** all gates pass; plan + summary finalized; `hreal`/`hsat` recorded as discharged.
- **Depends on:** 7.
- **Files:** none (verification) + this plan + summary.

## Testing & Validation

- [ ] Scoped `lake build` GREEN after every open phase; whole-tree GREEN at Phase 8.
- [ ] `lean_verify` on every headline decl = exactly `[propext, Classical.choice, Quot.sound]`;
      no `sorry` anywhere in v8 code; no new axiom.
- [ ] Interior obligations everywhere at FULL arity 4
      (`nf_eval_nf M k 4 (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t)))) σ`) — zero NEW
      occurrences of `nfk_projFresh` in v8 code (G1; the sanctioned 352 fiber-bucketing use is
      pre-existing and consume-only, not a violation).
- [ ] `endInterval_correct` is the Prior-guarded biconditional (`EndIntervalCorrectPrior`),
      hypotheses verbatim-generalized from the k=2 gate — never the unguarded v6 shape, never a
      single-point `.eval_at w` LHS, never `h_res`-conditioned.
- [ ] The four bracket lemmas D1-D4 consume the DELIVERED 352/354 clause layer by name; D3/D4
      thread and Phase 6 DISCHARGES `hreal`/`hsat` via the 354 bundle templates (recorded as a
      discharged interface, not debt).
- [ ] Exterior residue discharged ONLY via the double-anchor brackets (Past@x ∧ Fut@t, Lemma-7.6
      adjacency) — no single-anchor pinning, no flat `extF4` route.
- [ ] Anchors strictly {x,t} (≤2); all witnesses bound (G2/G4); segments non-trivial (G3); manual
      bridges on chain steps (G5); `nf_char3_deeper_split` grep-clean.
- [ ] `git diff` on the 8 frozen files (7 providers + `ExteriorBracketK.lean`) + KampPrior.lean +
      Lemma32Reduction.lean EMPTY over the whole v8 range; `nf_nvar_exist_all_depths` signature
      unchanged; the delivered 352/354 clause modules unedited.
- [ ] No Boneyard file imported or restored.
- [ ] `endInterval`/`endInterval_correct` top-level citable for task 309 Phase 18/19 / 350.

## Artifacts & Outputs

- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge/ExteriorBracketAssembleK.lean`
  — NEW module (Phases 3-4: the four depth-`k` bracket lemmas D1-D4; imports
  `ExteriorConverterK` + `ExteriorConverterPastK` + `ExteriorBracketK`).
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge/CarrierK1V.lean` — additive +
  sanctioned `endIntervalStep`/`endInterval` re-freeze (Phases 5-7).
- `specs/349_.../plans/08_consume-depthk-clause-layer.md` (this plan; supersedes v7 plans/07).
- `specs/349_.../summaries/08_consume-depthk-clause-layer-summary.md` (on completion).

## Rollback/Contingency

- All work is additive (new `ExteriorBracketAssembleK.lean` + CarrierK1V additive tails + the
  sanctioned re-freeze); the 8 frozen files, the delivered 352/354 clause modules, KampPrior.lean,
  and Lemma32Reduction.lean are never opened, so no green asset can be lost by a v8 rollback.
  Snapshot before any intentional rollback (`bash .claude/scripts/git-snapshot.sh` first).
- Commit-per-green-substep mandate: every verified-green sub-step is committed as it lands; no
  progress lost across dispatches.
- **Per-phase feasibility gate**: a phase target that cannot close green without a forbidden
  construct is `[BLOCKED]` + exact `lean_goal` + `status: partial` + `requires_user_review: true`
  + `/spawn 349` for the specific missing sub-lemma — never a fake green. The carrier type is
  SETTLED and the depth-`k` clause layer is DELIVERED (352/354), so every plausible block in v8 is
  bounded bracket-assembly / index-structural construction, never a carrier change.
- If the bracket-assembly `_sound` (Phase 3) blocks on the G-b marking-shape mismatch, the fallback
  is a focused `/spawn 349` for the `kvE_futAdmissible`↔bracket bridging lemma alone while 349
  holds `[BLOCKED]`; downstream phases do not proceed without the bracket layer.
