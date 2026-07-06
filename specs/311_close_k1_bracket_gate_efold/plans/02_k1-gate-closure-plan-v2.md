# Implementation Plan: Close the k=1 Bracket Gate under the E[Σ]-Fold Encoding (v2, audit-integrated)

- **Task**: 311 - close_k1_bracket_gate_efold
- **Status**: [NOT STARTED]
- **Effort**: 5 hours (2 phases, ~150-300 lines total; hard mode, H8 sizing)
- **Dependencies**: 310 (COMPLETE — `Kamp/NfEFold.lean` landed sorry-free), parent 309 (BLOCKED, resumes via `/revise 309` after this task's GO verdict)
- **Research Inputs**:
  - `specs/311_close_k1_bracket_gate_efold/reports/01_rabinovich-faithfulness-audit.md` (adversarial audit of plan v1; verdict FAITHFUL-WITH-CAVEATS — this plan folds in every caveat)
  - `specs/310_normalform_efold_encoding/reports/01_efold-encoding-research.md` (Tier-1, Rabinovich-2014-grounded)
  - `specs/309_offdiag_two_anchor_fi_chain/plans/03_offdiag-fi-chain-plan.md` (Phase 10 [BLOCKED] handoff + Postmortem Constraints G1-G6)
  - R2 NO-GO record `NfMultiAnchorBridge.lean:1586-1618` (line-verified this session; v1 cited :1573-1618 — drifted)
- **Artifacts**: plans/02_k1-gate-closure-plan-v2.md (this file); `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge.lean` (edited, additive only)
- **Standards**: plan-format.md; status-markers.md; artifact-management.md; tasks.md; zero-debt (0 new sorries); axioms exactly `[propext, Classical.choice, Quot.sound]`; G5 literature-fidelity (no simp/omega/aesop chain-step shortcut); lean4.md vacuous-definition prohibition
- **Type**: lean4 (hard mode, H8 sizing)

## Overview

Task 310 delivered the E[Σ]-fold encoding in `Kamp/NfEFold.lean`, sorry-free, with the gate corollary
`nf_quant_layer_fold_k1_gate` (NfEFold.lean:525) stated **verbatim** against the R2 NO-GO residual,
the k=1 whole-evaluation bridge `nf_eval_nf1_iff_efold` (:490), the transport `efold_of_nf1` (:472),
the general-n fold engine `nf_quant_layer_fold_iff` (:391), and the depth-0 split kit (:153-235).
Task 311 consumes these to close the single obligation that NO-GOed under the old `nf_eval_nf`-only
encoding: the `k=1` instance of `BracketCarrierCorrect` (`NfMultiAnchorBridge.lean:1546-1552`
restricted to `k=1`).

The blocker was an **irreducible arity-4 residual** (env `[x_1, w, x, t]` coupling bracket witness `w`
to both fixed endpoints `x, t`) that no `VecEA2 1` monadic component could supply. The fold dissolves
it: `nf_quant_layer_fold_k1_gate` rewrites the arity-4 quant layer into **zone-bounded monadic
existentials** over `EAtomDom sig 0 3 = ZoneSpec 3 × NormalForm sig 0 1` (NfEFold.lean:69) — each a
Def-3.1 one-witness object over the fixed points `{x,t}`, never an arity-4 object. Per the audit
(Red Flag A, Claim 3), this is fidelity-*restoring*: Def 3.1's α_j/β_j are one-variable
quantifier-free formulas, so the arity-4 joint object has **no Rabinovich counterpart** — it was a
Lean `nf_eval_nf` arity-growth artifact.

Two H8 phases (unchanged from v1, which the audit cleared as FAITHFUL-WITH-CAVEATS): (1) define the
`k=1` carrier instance `bracketEndChar_k1 : BracketEndCharCarrier sig 1` via the fold; (2) prove
`bracketEndChar_k1_correct` sorry-free and record the **R2 = GO** verdict. What changes in v2 is
citation discipline (audit caveats C1/C2 below), drift-corrected line references, and an explicit
audit-caveat ledger binding on the implementer.

### Research Integration

| Report | Integrated in plan version | Date |
|--------|---------------------------|------|
| `reports/01_rabinovich-faithfulness-audit.md` | 2 | 2026-07-06 |
| 310 `reports/01_efold-encoding-research.md` | 1 (carried) | 2026-07-05 |

### Audit Caveat Ledger (every audit caveat, and how v2 addresses it)

The audit verdict was **FAITHFUL-WITH-CAVEATS**; no claim was UNSUPPORTED, so no phase is added or
removed. Each caveat maps to a concrete plan element:

| # | Audit caveat / recommendation | How plan v2 addresses it |
|---|-------------------------------|--------------------------|
| C1 | **Claim 4 PARTIAL (Prop 3.5 citation-precision)**: Prop 3.5 as printed is a ONE-free-variable translation; the "bracket at FIXED endpoints z_0,z_1" (two endpoints) framing belongs to **Lemma 3.2(2) (p.4) + §5 bracket notation (p.7)**. Prop 3.5 (p.5) supplies only the ∃-witness→Until/Since **folding mechanism**. | Mapping table row 4 rewritten (below); Phase 1 task requires the corrected split citation in `bracketEndChar_k1`'s doc-comment; new postmortem rule N1 forbids citing Prop 3.5 alone for the two-endpoint bracket. |
| C2 | **Claim 6 PARTIAL (Prop 4.3 attribution)**: the "innermost fold / iteration" reading is the **Def 4.1 p.6 note** (TL over E[Σ] ≡ TL over Σ, iterated); **Prop 4.3 (p.6)** licenses only "the residual is ∨∃∀ over E[Σ] atoms". The codebase realizes Prop 4.3's content locally via the fold, not literal structural induction (305 report 14 line 49). | Mapping table row 6 split into 6a/6b (below); Phase 2 task requires the split citation at the gate-rewrite step and a comment noting the non-literal Prop 4.3 realization; new postmortem rule N2. |
| C3 | **Recommendation 3: preserve the R1 escalation fence** (≤2-anchor cap is the Rabinovich invariant; witness count may grow under ∃-closure, anchor count may not; a `VecEA2 1` representability failure is a Lean-side escalation, never a license for a third anchor or a codomain switch). | Carried unchanged from v1 as Risk R1 + Rollback rule; marked **audit-confirmed (Red Flags B, C)**; explicit non-action beyond v1 — the fence was already correct. |
| C4 | **Recommendation 4: lead the R2 = GO doc-comment with the strongest evidence** — Def 3.1's one-variable α_j/β_j (no joint multi-point atom) proves the arity-4 residual is a Lean artifact and the fold restores fidelity. | Phase 2's GO-verdict task now specifies the doc-comment's LEAD sentence verbatim-in-substance (see Phase 2 task list). |
| C5 | **All six cited page numbers verified exactly correct** (Def 3.1 p.4, Lemma 3.2 p.4, Lemma 3.4 p.5, Prop 3.5 p.5, Def 4.1 p.5, Prop 4.3 p.6, §5 bracket p.7). | Mapping table carries the audit-verified pages; explicit non-action: no re-grounding dispatch is needed, and none may be requested by the implementer (the audit is the grounding authority). |
| C6 | **No UNSUPPORTED claim; plan v1's structure cleared as the faithful path.** | Explicit non-action: phase count, phase boundaries, carrier shape, and proof skeleton carry over from v1 unchanged (see Preserved Assets). |

### Preserved Assets

The following work is COMPLETE and MUST NOT regress. Phases below only ADD to `NfMultiAnchorBridge`;
they touch no existing declaration. All file:line references below were **re-verified this session**
(2026-07-06) with Grep against the working tree; rows marked (drift-corrected) differ from plan v1.

| Component | File:line (verified) | Status | Consumed as |
|-----------|---------------------|--------|-------------|
| E[Σ]-fold type + eval | `Kamp/NfEFold.lean:77/102` (`NormalFormEFold`, `nf_eval_efold`) | [COMPLETED] 310 | dependency |
| zone semantics + E-atom domain | `Kamp/NfEFold.lean:58/69` (`zoneHolds`, `EAtomDom`) | [COMPLETED] 310 | quant-layer domain |
| general-n fold engine | `Kamp/NfEFold.lean:391` (`nf_quant_layer_fold_iff`) | [COMPLETED] 310 | (via the two lemmas below) |
| Gate corollary (verbatim R2 residual) | `Kamp/NfEFold.lean:525` (`nf_quant_layer_fold_k1_gate`) | [COMPLETED] 310 | **entry point** (Phase 2) |
| k=1 whole-eval bridge | `Kamp/NfEFold.lean:490` (`nf_eval_nf1_iff_efold`) | [COMPLETED] 310 | quant-layer discharge (Phase 2) |
| fold-of-nf1 transport | `Kamp/NfEFold.lean:472` (`efold_of_nf1`) | [COMPLETED] 310 | carrier construction (Phase 1) |
| depth-0 split kit + round-trips | `Kamp/NfEFold.lean:153-235` (`nf0_zoneSpec:153/projFresh:162/dropFresh:171/assemble:180`, `nf0_split_assemble:235`) | [COMPLETED] 310 | zone matching |
| G6 carrier SHAPE | `NfMultiAnchorBridge.lean:1536/1546` (`BracketEndCharCarrier`/`BracketCarrierCorrect`; goal shape :1550-1552) | [COMPLETED] 309 P9 | **unchanged; instantiated at k=1** |
| depth-0 carrier + correctness | `NfMultiAnchorBridge.lean:1557/1571` (`bracketEndChar_k0(_correct)`) | [COMPLETED] 309 P9 | atom-layer discharge template |
| R2 NO-GO record (drift-corrected) | `NfMultiAnchorBridge.lean:1586-1618` (Phase 10 section; residual quoted at :1601-1603) | [COMPLETED] 309 P10 | GO-verdict mirror format |
| depth-0 bracket collapse | `VecEADecomp.lean:233/244` (`nf_3var_bracket_xyt(_correct)`) | [COMPLETED] 309 | atom-layer `↔` |
| bracket builders | `VecEATranslation.lean:273/503` (`bracketBuildLeft(_correct)`), `:50/234` (`bracketBuildRight(_correct)`) | [COMPLETED] 309 | interval-witness matching |
| ∃-closure vehicle | `VecEAClosure.lean:265` (`BracketFormula.existsBounded_right`) | [COMPLETED] 309 | zone-witness absorption |
| VecEA2 structure + holds + ctors (drift-corrected) | `VecEAFormula.lean:252/262` (`VecEA2`, `VecEA2.holds`), `:321/328/334` (`BracketFormula.single`, `VecEA2.fromBracket(_holds)`) | [COMPLETED] | carrier output |
| char_k1 template | `KampPrior.lean:307/310` (`char_k1(_correct)`, proof-local) | [COMPLETED] | k=1 shape precedent |
| trichotomy + off-diag arms | `NfZoneFlattenNavigable.lean:188/335/386` (`nf_zone_exists_trichotomy_k1`, `A_past`, `A_future`) | [COMPLETED] 309 | zone case split |
| zone flatten + diag (drift-corrected) | `NfMultiAnchorBridge.lean:689/709/835` (`nf_zone_flatten_navigable(_correct/_brick)`), `:763/780` (`A_diag(_correct)`) | [COMPLETED] 309 | navigated-zone reuse |
| Phase 1-5 off-diag assets (drift-corrected) | `NfMultiAnchorBridge.lean:364/375/391` (`nf_char2_atom_offdiag_{endpoint,origin,correct}`), `:891/907` (`nf_char3_endpoint_tl(_correct)`), `:1229/1252` (`nf_char2_past_formula(_correct)`), `:1428/1452` (`nf_char2_future_formula(_correct)`) | [COMPLETED] 309 | not directly consumed; must not regress |
| Fintype/DecidableEq (NormalForm) | `NormalForm.lean:177/181` (`normalForm_fintype`/`normalForm_decEq`); `nf_eval_nf` unfolding `:201` | [COMPLETED] | off-fiber clause decidability |
| order-conflict falsity pattern | `NfDepth0Generalized.lean:93` (`nf_depth0_pair_cycle_empty'`) | [COMPLETED] | inconsistent-zone falsity |
| current live sorries | `KampPrior.lean:351` (309 scope), `:354` (305 scope) | held at 2 | not touched |
| plan v1 structure | `plans/01_k1-gate-closure-plan.md` (2 phases, wave map, risks R1-R4, import-direction resolution, Fintype-drop justification) | [PLANNED], audit-cleared | carried into v2 with citation fixes only |

**Import-direction resolution (re-verified this session)**: `NfEFold` imports only
`Bimodal.Metalogic.WeakCanonical.NormalForm` and `…Kamp.NfDepth0Generalized` (NfEFold.lean:1-2); it
does not import `NfMultiAnchorBridge` or `NfZoneFlattenNavigable`. `NfMultiAnchorBridge` imports
`…Kamp.NfZoneFlattenNavigable` (:1). Adding `import Bimodal.Metalogic.WeakCanonical.Kamp.NfEFold` to
`NfMultiAnchorBridge` is therefore **cycle-free**. The new k=1 artifacts stay in
`NfMultiAnchorBridge` (file currently ends at :1620), alongside the carrier SHAPE and the k=0
instance. No file relocation.

**Fintype/DecidableEq for `NormalFormEFold` — NOT required; dropped with justification (carried from
v1, unchanged)**: the only decidability 311 touches is the off-fiber clause
`∀ sub : NormalForm sig 0 4, nf0_dropFresh sub ≠ qnf.1 → qnf.2 sub = false` (2nd conjunct of
`nf_eval_nf1_iff_efold`, NfEFold.lean:495), which uses `Fintype (NormalForm sig 0 4)` and
`DecidableEq (NormalForm sig 0 3)` — both landed (`NormalForm.lean:177/181`). `Classical.dec` covers
any Prop-gate in the carrier. Building instances on `NormalFormEFold` itself would be dead weight.

### Source-to-Implementation Mapping (Tier 1, Rabinovich 2014 — audit-corrected)

All PDF pages below were verified against the actual PDF by the audit (report §Findings, "every
cited page is correct"). Rows 4 and 6 are rewritten per audit caveats C1/C2; the others carry from
v1 with audit verdict FAITHFUL.

| # | Rabinovich source | PDF page | Lean asset (consumed) | New 311 artifact using it | Audit verdict |
|---|-------------------|----------|-----------------------|---------------------------|---------------|
| 1 | Def 4.1 (E[Σ] monadic-atom fold; unary predicate names; p.6 note licenses iterated folds) | p.5 (note p.6) | `nf_eval_efold` (NfEFold:102), `efold_of_nf1` (:472) | `bracketEndChar_k1` (Phase 1) | FAITHFUL |
| 2 | Lemma 3.2(2) (every ∃∀ ≡ conj of ∃∀ with ≤2 free variables) | p.4 | `EAtomDom` (NfEFold:69) — the ≤2-cap as a standing carrier-type invariant | anchor-count invariant, both phases | FAITHFUL |
| 3 | Def 3.1 (∃∀ normal form; α_j/β_j quantifier-free with ONE variable; witness meets env only via order/equality conjuncts) | p.4 | `zoneHolds` (NfEFold:58), `nf0_zoneSpec` (:153) | zone matching (Phase 2); LEAD evidence of the GO verdict (caveat C4) | FAITHFUL — strongest anti-"novel-math" evidence |
| 4a | Prop 3.5 (one-free-variable ∨∃∀ → TL; the ∃-witness→Until/Since **folding mechanism**) | p.5 | `nf_3var_bracket_xyt(_correct)` (VecEADecomp:233/244) | witness-folding steps (both phases) | PARTIAL in v1 → corrected (C1) |
| 4b | Lemma 3.2(2) + §5 bracket notation `[α_0,…,α_n](z_0,z_1)` (the **two-fixed-endpoint bracket** framing) | p.4 + p.7 | `BracketEndCharCarrier` shape (Bridge:1536), `bracketBuildLeft/Right` (VecEATranslation:273/50) | endpoint + interval encode (both phases) | corrected split citation (C1) |
| 5 | Lemma 3.4 (∨∃∀ closed under ∃; witness joins the existential prefix — a bracket witness, never an anchor) | p.5 | `BracketFormula.existsBounded_right` (VecEAClosure:265) | interval-zone witness absorption (Phase 2) | FAITHFUL — underwrites R1 |
| 6a | Def 4.1 **p.6 note** (TL over E[Σ] ≡ TL over Σ, iterated inside-out — the "innermost fold / iteration" reading) | p.6 | `nf_quant_layer_fold_k1_gate` (NfEFold:525) | RHS rewrite (Phase 2) | PARTIAL in v1 → corrected (C2) |
| 6b | Prop 4.3 (every FO formula ≡ ∨∃∀; licenses **treating the residual as a ∨∃∀ object over E[Σ] atoms** — realized locally via the fold, NOT via literal structural induction, per 305 report 14) | p.6 | `nf_eval_nf1_iff_efold` (NfEFold:490) | residual-is-∨∃∀ reading (Phase 2) | corrected split citation (C2) |

## Postmortem Constraints

Binding rules for all implementation dispatches. Sources: the R2 NO-GO record
(`NfMultiAnchorBridge.lean:1586-1618`), the 309 plan-v3 Postmortem Constraints (G1-G6 + Corrected
Anchor-Cap, carried VERBATIM below per the task description), the audit caveats (rules N1-N2), and
plan v1's do-not rules (carried).

**Guards G1-G6 + Corrected Anchor-Cap (VERBATIM from the task description / 309 plans/03 Postmortem
Constraints)**:

- G1 -- No arity-1 collapse of the off-diagonal. (Refuted: report 02 SS1; NfDepth0Generalized:1691-1719.)
- G2 -- No projection-based VecEA2 / third-free-anchor tower. (Refuted: specs/305 report 40; R2.)
- G3 -- No trivial-top segment on the off-diagonal arms. A closed pastEnd under a trivial segment is unsatisfiable; the (x,t) coupling MUST ride the non-trivial Rabinovich beta_i segment (a real interval type, not top/trivial).
- G4 -- w stays a bracket witness. Env arity never grows past {w,x,t}=3 -> {x,t}=2; anchor set {x,t}; Rabinovich <=2 cap.
- G5 -- Follow Cor 5.4 / Prop 3.5 F_i chains step-by-step; no simp/omega/aesop shortcut of a chain step (literature-fidelity policy). Cite Rabinovich PDF p.4-5 at every chain step.
- G6 -- The recursion carrier MUST be the two-anchor bracket characteristic with FIXED endpoints z_0,z_1 (Prop 3.5, PDF p.5): NormalForm sig k 3 -> VecEA2 1 (two endpoint TemporalPreds + one interval TemporalPred), {x,t} FIXED, w a bracket WITNESS. It MUST NOT be an arity-1 navigated point characteristic nor an interior-existential-witness evaluation. CRITICAL DISTINCTION from G2: G2 bars a THIRD free anchor; G6's VecEA2 is a fixed-endpoint bracket, not a projection tower -- anchors stay {x,t} (2, fixed).
- Corrected Anchor-Cap Statement: the hook-discharge path MUST keep the anchor set at {x,t} (<=2) by the bracket-witness-collapse mechanism, NOT by nf_char3_deeper_split (NfMultiAnchorBridge.lean:625-642, which grows arity 3->4 and anchors {x,t}->{y,x,t} -- forbidden tower).

*(Precision note, non-modifying: per audit caveat C1, where G6's parenthetical cites "Prop 3.5, PDF
p.5" for the fixed-endpoint framing, the implementer's NEW doc-comments must use the split citation
of rule N1 below. The guard text itself stays verbatim as the settled 309 contract.)*

**New audit-derived rules (v2)**:

- **N1 (caveat C1)** -- In every NEW doc-comment and chain-step comment, do NOT cite Prop 3.5 alone
  for the two-fixed-endpoint bracket. Required split: **Prop 3.5 (p.5)** = the one-free-variable
  ∃-witness→Until/Since folding *mechanism*; **Lemma 3.2(2) (p.4) + §5 bracket notation (p.7)** = the
  two-fixed-endpoint `(z_0,z_1)` framing.
- **N2 (caveat C2)** -- For the gate-corollary rewrite step, cite the **Def 4.1 p.6 note** for the
  "innermost fold / iteration" reading and **Prop 4.3 (p.6)** only for "the residual is ∨∃∀ over
  E[Σ] atoms"; the comment must note that the codebase realizes Prop 4.3's content locally via the
  fold, not via literal structural induction (305 report 14).
- **N3 (caveat C4)** -- The R2 = GO doc-comment MUST lead with the Def 3.1 evidence: α_j/β_j are
  one-variable quantifier-free formulas, so the arity-4 residual `[x_1,w,x,t]` has no Rabinovich
  counterpart — it was a Lean `nf_eval_nf` arity-growth artifact, and the fold restores Def-4.1
  fidelity.

**Do NOT** (carried from v1, line references re-verified):

- **Do NOT redefine the fold, the transport, or the gate corollary.** Consume `nf_eval_efold`,
  `efold_of_nf1`, `nf_eval_nf1_iff_efold`, `nf_quant_layer_fold_k1_gate`, and the split kit from
  `NfEFold` by name. Any local re-derivation is a defect (the whole point of 310 was to land these).
- **Do NOT reconstruct the arity-4 residual.** The moment a goal shows env `[x_1, w, x, t]` (arity 4)
  or `NormalForm sig 0 4` on an evaluation RHS not immediately routed through
  `nf_quant_layer_fold_k1_gate` (NfEFold:525), stop — that is the exact NO-GO shape
  (Bridge:1601-1603). Rewrite via the gate corollary BEFORE splitting the `∃ w` (G4, Corrected
  Anchor-Cap).
- **Do NOT navigate `x, t` into an arity-3 characteristic** (reading `w` while `x,t` are navigated
  in). That is the re-bounding obstruction G6 bars; the abandoned `EndCharCarrier` route
  (Bridge:1029, refuted at :1058-1069) stays inert.
- **Do NOT grow the carrier's output shape past `VecEA2 1`.** The carrier stays
  `NormalForm sig 1 3 → VecEA2 1`. Endpoints `{x,t}` fixed (≤2, Lemma 3.2(2)); `w` a bracket WITNESS
  (G4/G6). Interior two-witness zones are absorbed INSIDE the single `BracketFormula 1` interval via
  `bracketBuildLeft/Right` + `BracketFormula.existsBounded_right` (Lemma 3.4 ∃-closure, p.5; audit
  Red Flag C: witness-count growth under ∃-closure is licensed; anchor-count growth is not). Do NOT
  switch to `VVecEA2` or `VecEA2 2` — that changes the G6-settled SHAPE (see Risk R1 fence).
- **Do NOT use `simp`/`omega`/`aesop` to shortcut a Prop-3.5 / Lemma-3.4 chain step** (G5,
  literature-fidelity). Cite the Rabinovich PDF page at each chain step, using the N1/N2 split
  citations.
- **Do NOT introduce a third free anchor** (G2) nor an arity-1 navigated-point collapse (G1) nor a
  trivial-top segment on the off-diagonal (G3).
- **Do NOT build `Fintype/DecidableEq (NormalFormEFold …)`** (dropped with justification — see
  Preserved Assets).
- **Do NOT request a re-grounding/re-audit dispatch** (caveat C5/C6: the audit verified all six page
  citations and cleared the structure; it is the grounding authority for this task).

**MUST preserve**:

- All Preserved Assets above (edits ADD to `NfMultiAnchorBridge` only; no existing declaration is
  modified; `NfEFold.lean` is not edited at all).
- Live sorry count stays at 2 (`KampPrior.lean:351`, `:354`) — 311 adds ZERO sorries; no vacuous
  definitions (lean4.md prohibition).
- Axiom profile exactly `[propext, Classical.choice, Quot.sound]` on both new declarations.

**Design decisions are SETTLED** (do not re-open without a concrete counterexample):

- The new artifacts live in `NfMultiAnchorBridge` with a single new `import …Kamp.NfEFold`
  (cycle-verified this session). No relocation, no new file.
- The carrier codomain is `VecEA2 1`, endpoints `{x,t}` fixed, `w` a bracket witness (G6 SHAPE —
  audit Red Flag B confirms this is verbatim the Def-3.1/Lemma-3.2 witness/anchor arithmetic).
- The quant layer is discharged ONLY via `nf_quant_layer_fold_k1_gate` /
  `nf_eval_nf1_iff_efold` (never by re-attacking the arity-4 goal directly — proven NO-GO).
- Fintype/DecidableEq of `NormalFormEFold` is out of scope.
- Plan structure stays at 2 phases (audit caveat C6: v1's decomposition was cleared; only citations
  change).

## Goals & Non-Goals

**Goals**:
- Define `bracketEndChar_k1 : BracketEndCharCarrier sig 1` (a `VecEA2 1`-valued carrier) via the
  310 fold assets, with N1-compliant citations.
- Prove `bracketEndChar_k1_correct` — the `k=1` instance of `BracketCarrierCorrect`
  (Bridge:1546-1552) — sorry-free, with N1/N2-compliant chain-step citations.
- `lake build` GREEN on the full tree; 0 new sorries; axioms exactly
  `[propext, Classical.choice, Quot.sound]` on both new declarations.
- Record an explicit **R2 = GO** verdict doc-comment mirroring the Phase 10 handoff format
  (Bridge:1586-1618), leading with the N3/C4 Def-3.1 evidence, with evidence that the fold closed
  the gate via `nf_quant_layer_fold_k1_gate` with no arity-4 residual and no navigated arity-3
  characteristic. This un-falsifies Path B at `k=1` and is 311's DONE signal, enabling
  `/revise 309` (plan v4).

**Non-Goals**:
- No depth-`k` (R3) lift, no `F_i`-chain (R4) — 309 scope, dispatchable after this.
- No `NormalFormEFold` Fintype/DecidableEq instances (dropped, justified).
- No change to `BracketEndCharCarrier` / `BracketCarrierCorrect` SHAPE or to any k=0 asset.
- No edit to `NfEFold.lean`, plan 01, state.json scope beyond normal status flow.
- No wiring onto 309's live path (the k=1 instance lands off the live path until `/revise 309`).
- No re-audit / re-grounding of the Rabinovich citations (caveat C5: pages verified).

## Risks & Mitigations

| ID | Risk | Likelihood | Mitigation |
|----|------|-----------|------------|
| R1 | Interior zones `(x,w)`/`(w,t)` need a SECOND interior witness, exceeding a single `BracketFormula 1` (310 report §5.6 open question). | Medium | **Audit-confirmed fence (caveat C3, Red Flag C)**: the math is licensed by Lemma 3.4 + Lemma 3.2(3) (witness joins the existential prefix); absorb the second witness INSIDE the `BracketFormula 1` interval via `bracketBuildLeft/Right(_correct)` (VecEATranslation:273/503, :50/234) + `BracketFormula.existsBounded_right` (VecEAClosure:265). Anchors stay `{x,t}`. If genuinely infeasible within `VecEA2 1`, this is a Lean-representability escalation: STOP and escalate to the orchestrator with the specific zone and failing goal state BEFORE changing the carrier codomain — never a license for a third anchor or a silent `VVecEA2` switch. |
| R2 | Off-fiber falsity clause (`nf_eval_nf1_iff_efold` 2nd conjunct, NfEFold:495) not dischargeable at the carrier. | Low | It is a fixed, `w`-independent, decidable condition on `qnf` (`Fintype (NormalForm sig 0 4)` / `DecidableEq (NormalForm sig 0 3)`, NormalForm.lean:177/181). Pull it out of `∃ w` (`∃ w, P w ∧ Q ≡ (∃ w, P w) ∧ Q`) and gate the carrier's `holds` on it (`Classical.dec` on the Prop). |
| R3 | Zone case analysis (`ZoneSpec 3` positions of the fold witness relative to `[w,x,t]`) balloons past H8 size. | Medium | Equality zones read a point type at a fixed point/witness (`nf_eval_nf M 0 1`); interval zones are one `existsBounded_right` witness; inconsistent zones are false by order-conflict falsity (`nf_depth0_pair_cycle_empty'`, NfDepth0Generalized:93). If Phase 2 exceeds ~150 lines of proof, split at a private zone-matching lemma (Phase 2.1/2.2 escape hatch in Phase 2 notes) — same bounded units, no scope change. |
| R4 | Axiom drift (an extra axiom leaks in). | Low | Final `#print axioms` / `lean_verify` gate on both declarations; all inputs are Classical.dec + funext + order reasoning (same profile as landed k=0 / NfEFold lemmas). |
| R5 | Citation regression: a chain-step comment reverts to v1's conflated Prop 3.5 / Prop 4.3 citations. | Low | Postmortem rules N1/N2 are binding; Phase verification includes a grep check that new doc-comments contain the split citations (`p.7` / `Def 4.1 p.6 note` markers present). |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2 | 1 |

Phases within the same wave can execute in parallel. Here: strictly sequential — both phases edit
the same file (`NfMultiAnchorBridge.lean`, single-file territory, one owner per dispatch, no
parallel opportunity), and Phase 2 consumes Phase 1's definition by name. One agent run per phase
(H8). Total ~150-300 lines across the two phases.

### Phase 1: Define the k=1 fold carrier instance `bracketEndChar_k1` [NOT STARTED]

- **Goal:** Land the `k=1` carrier definition (typechecks, sorry-free) consuming 310's fold assets,
  with audit-corrected citations.
- **Tasks:**
  - [ ] Add `import Bimodal.Metalogic.WeakCanonical.Kamp.NfEFold` to `NfMultiAnchorBridge.lean`
        (cycle-free, verified: NfEFold imports only NormalForm + NfDepth0Generalized).
  - [ ] Define `noncomputable def bracketEndChar_k1 … : BracketEndCharCarrier sig 1`, i.e.
        `fun qnf : NormalForm sig 1 3 => (… : VecEA2 1)`, encoding `qnf`'s depth-1 content at the
        FIXED endpoints `{x,t}` with `w` the bracket witness (G6 SHAPE, codomain unchanged):
        endpoint `TemporalPred`s mirror the k=0 collapse `nf_3var_bracket_xyt` (VecEADecomp:233) on
        the atom layer `qnf.1`; the single interior `BracketFormula 1` carries the fold-reduced
        quant content of `qnf.2` — the zone-bounded monadic E-atoms
        `EAtomDom sig 0 3 = ZoneSpec 3 × NormalForm sig 0 1` exposed by the fold, read through
        `efold_of_nf1 qnf` (NfEFold:472), built with `BracketFormula.single` /
        `VecEA2.fromBracket` / `bracketBuildLeft/Right`. No `qnf.2` value is evaluated at arity 4 —
        quant content is read through `efold_of_nf1` / `nf0_assemble` only.
  - [ ] Gate the construction on the off-fiber falsity of `qnf.2`
        (`∀ sub : NormalForm sig 0 4, nf0_dropFresh sub ≠ qnf.1 → qnf.2 sub = false` — decidable
        via NormalForm.lean:177/181, or `Classical.dec`; empty/⊥ carrier for incompatible `qnf`),
        mirroring Rabinovich's disjunctions ranging only over consistent order types (Risk R2).
  - [ ] Doc-comment with the **N1 split citation** (caveat C1): Def 4.1 (p.5) for the monadic-atom
        fold; **Prop 3.5 (p.5) only for the ∃-witness→Until/Since folding mechanism**;
        **Lemma 3.2(2) (p.4) + §5 bracket notation (p.7) for the two-fixed-endpoint framing**.
        Do not cite Prop 3.5 alone for the two-endpoint bracket.
  - [ ] Verify: `lake build` GREEN (scoped module build acceptable mid-phase, full tree at phase
        end); no `sorry`; no vacuous definition; signature grep confirms codomain `VecEA2 1` (no
        `VVecEA2` / `VecEA2 2`).
- **Estimated output:** ~50-90 lines (one import + one `noncomputable def` + doc-comment).
- **Bounded-unit test:** one definition; fixed attempt surface (a term construction against a known
  target type), not open-ended search. Done-criterion checkable in isolation.
- **Done when:** `bracketEndChar_k1 : BracketEndCharCarrier sig 1` typechecks sorry-free;
  `lake build` GREEN; N1-compliant doc-comment present; commit
  `task 311 phase 1: define k=1 fold carrier bracketEndChar_k1`.
- **Timing:** ~1.5-2 hours (one agent run).
- **Depends on:** none

### Phase 2: Prove `bracketEndChar_k1_correct` sorry-free + record R2 = GO [NOT STARTED]

- **Goal:** Close the exact blocker goal — the `k=1` instance of `BracketCarrierCorrect`
  (Bridge:1546-1552) — sorry-free via the gate corollary, and record the GO verdict.
- **Tasks:**
  - [ ] State `theorem bracketEndChar_k1_correct … : BracketCarrierCorrect M atomMap
        (bracketEndChar_k1 …)`, unfolding to: for all `qnf : NormalForm sig 1 3` and `x t`,
        `(bracketEndChar_k1 … qnf).holds M atomMap x t ↔
        ∃ w : M.carrier, nf_eval_nf M 1 3 (Fin.cons w (Fin.cons x (fun _ => t))) qnf`.
  - [ ] Chain step 1 — rewrite the RHS body via **`nf_eval_nf1_iff_efold`** (NfEFold:490, at n=3,
        env `[w,x,t]`) into `nf_eval_efold … (efold_of_nf1 qnf) ∧ off-fiber(qnf)`; pull the
        `w`-independent off-fiber conjunct out of `∃ w`. Cite per **N2**: the residual-is-∨∃∀
        reading is **Prop 4.3 (p.6)**, realized locally via the fold rather than literal structural
        induction (305 report 14).
  - [ ] Chain step 2 — route the quant layer through **`nf_quant_layer_fold_k1_gate`**
        (NfEFold:525, with `h_atom` from the atom layer) so the residual is zone-bounded monadic
        existentials over `ZoneSpec 3 × NormalForm sig 0 1` — **no arity-4 object remains** (the
        NO-GO-dissolving step). Cite per **N2**: the "innermost fold / iteration" reading is the
        **Def 4.1 p.6 note**; Lemma 3.4 (p.5) for ∃-closure.
  - [ ] Chain step 3 — discharge the atom layer via **`nf_3var_bracket_xyt_correct`**
        (VecEADecomp:244; the k=0 template `bracketEndChar_k0_correct`, Bridge:1571, reuses at the
        endpoints `{x,t}`). Cite per **N1**: Prop 3.5 (p.5) for the folding mechanism;
        Lemma 3.2(2) (p.4) + §5 bracket (p.7) for the fixed endpoints.
  - [ ] Chain step 4 — match each consistent order zone of the fold witness relative to `[w,x,t]`
        to the `VecEA2 1` `holds` (VecEAFormula:262): equality zones = point type at a fixed
        point/witness (`nf_eval_nf M 0 1`); interval zones = one
        `BracketFormula.existsBounded_right` witness (VecEAClosure:265; Lemma 3.4 ∃-closure, p.5;
        Risk R1 fence applies); inconsistent zones = false by order-conflict falsity
        (`nf_depth0_pair_cycle_empty'`, NfDepth0Generalized:93). Use
        `bracketBuildLeft/Right(_correct)`. NO simp/omega/aesop chain-step shortcut (G5).
  - [ ] Chain step 5 — close the off-fiber conjunct via the carrier's Phase-1 gate (Risk R2).
  - [ ] Record the **R2 = GO** doc-comment mirroring the Phase 10 handoff format
        (Bridge:1586-1618). Per **N3/C4**, LEAD with: Def 3.1's α_j/β_j are one-variable
        quantifier-free formulas (no joint multi-point atom exists in Rabinovich), so the arity-4
        residual was a Lean `nf_eval_nf` artifact; the fold restores Def-4.1 fidelity. Then the
        evidence: gate closed via `nf_quant_layer_fold_k1_gate`, no arity-4 residual, no navigated
        arity-3 characteristic; Path B un-falsified at k=1; 309's R3/R4 dispatchable via
        `/revise 309` (plan v4).
  - [ ] Verify: `lake build` GREEN full tree; live sorries still exactly 2 (KampPrior:351/354);
        `#print axioms` (or `lean_verify`) on BOTH `bracketEndChar_k1` and
        `bracketEndChar_k1_correct` = `[propext, Classical.choice, Quot.sound]`; citation grep (R5).
- **Estimated output:** ~100-160 lines (one theorem + zone case analysis + GO doc-comment).
- **Bounded-unit test:** one theorem with a fixed 5-step chain against landed lemmas — a fixed,
  finite attempt surface (every chain step names its discharging lemma), not open-ended research.
  Stopping condition independent of line count: if any single chain step fails against its named
  lemma after honest attempts, that is a NAMED blocker to escalate (with goal state), not a license
  to search for alternative mathematics (G5, R1 fence).
- **H8 escape hatch (pre-authorized):** if the zone case analysis pushes the proof past ~150 lines,
  split at a private `bracketEndChar_k1_zones` matching lemma (Phase 2.1) feeding the main `↔`
  (Phase 2.2) — same bounded units, no scope change, no new plan version needed.
- **Done when:** `bracketEndChar_k1_correct` sorry-free; `lake build` GREEN full tree; axiom set
  exact; R2 = GO doc-comment present with N3 lead; commit
  `task 311 phase 2: close k=1 bracket gate + R2 GO verdict`.
- **Timing:** ~2.5-3 hours (one agent run).
- **Depends on:** 1

## Testing & Validation

- [ ] `lake build` GREEN on the full tree after each phase (Phase 1: def typechecks; Phase 2:
      theorem closes).
- [ ] `#print axioms bracketEndChar_k1` and `#print axioms bracketEndChar_k1_correct` both =
      `[propext, Classical.choice, Quot.sound]` (Risk R4 gate; `lean_verify` acceptable).
- [ ] `grep -c "sorry" Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge.lean` = 0
      (excluding the word inside comments if any — verify no new `sorry` tokens); repo live-sorry
      count stays 2 (`KampPrior.lean:351/354`).
- [ ] Signature grep: carrier codomain is `VecEA2 1` (no `VVecEA2` / `VecEA2 2` in the new
      signatures), anchors `{x,t}` (G6).
- [ ] Citation grep (R5/N1/N2): new doc-comments contain "p.7" (§5 bracket) and "p.6 note"
      (Def 4.1 iteration) markers; Prop 3.5 never cited alone for the two-endpoint bracket in NEW
      comments.
- [ ] No existing declaration in `NfMultiAnchorBridge.lean` modified (`git diff` shows additive
      hunks + one import only).

## Artifacts & Outputs

- `specs/311_close_k1_bracket_gate_efold/plans/02_k1-gate-closure-plan-v2.md` (this plan)
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge.lean`: one new `import`, one
  new `noncomputable def bracketEndChar_k1`, one new `theorem bracketEndChar_k1_correct` (plus at
  most one private zone-matching lemma under the H8 escape hatch), one R2 = GO doc-comment. No
  existing declaration modified.
- `specs/311_close_k1_bracket_gate_efold/summaries/02_k1-gate-closure-summary.md` (written by the
  implementer at completion, including the GO verdict and the C4-lead evidence).

## Rollback/Contingency

All edits are additive-only within a single file (`NfMultiAnchorBridge.lean`); `NfEFold.lean` and
every Preserved Asset are untouched. This makes rollback trivial and fix-forward the default.

- **Phase 1 breaks the build** (import cycle surprise or carrier definition fails to typecheck):
  the whole phase is one `import` line + one `noncomputable def` block. Rollback = delete that block
  (and the import if it is the cause) — this restores the exact pre-311 tree. Then fix-forward:
  re-derive the carrier term against the target type `VecEA2 1` (never widen the codomain — see Risk
  R1). Commit only once `lake build` is GREEN.
- **Phase 2's 5-step chain stalls**: three graded responses, in order —
  1. If the stall is size/branching (zone case analysis balloons), take the **pre-authorized 2.1/2.2
     split** (private `bracketEndChar_k1_zones` matching lemma feeding the main `↔`; see Phase 2 H8
     escape hatch). Same bounded units, no new plan version.
  2. If a single chain step fails against its NAMED lemma, or Risk R1 materializes (a single
     `VecEA2 1` genuinely cannot host an interior witness), invoke the **R1 escalation fence**
     (audit caveat C3): STOP, do NOT change the carrier codomain or add a third anchor, capture the
     goal state via `lean_goal`, and escalate to the orchestrator — a G6-SHAPE decision, not an
     implementer call. Do NOT substitute alternative mathematics or `simp`/`omega`/`aesop` shortcuts
     (G5).
  3. If the gate cannot be closed this dispatch, **record the verdict either way**: mirror task
     309's Phase 10 handoff format (Bridge:1586-1618) and write a **R2 = NO-GO** doc-comment stating
     the exact failing goal shape and which chain step blocked — per the DECISION-GATE contract, a
     NO-GO lands no partial carrier and no `sorry` (delete any partial block first). This keeps the
     gate verdict on record so `/revise 311` (or `/revise 309`) can act on it, exactly as v1's GO
     path feeds `/revise 309`.
- **Git-snapshot / fix-forward discipline** (repo recovery ladder): commit at every GREEN milestone
  only (Phase 1 committed GREEN before Phase 2 begins). If a phase times out mid-work, mark it
  `[PARTIAL]` in the heading and leave the tree at the last GREEN commit; the next `/implement 311`
  resumes from the incomplete phase. Never commit a red tree or a new `sorry` (live sorry count
  stays 2, KampPrior:351/354).
- See the **Risks & Mitigations** table above for the per-risk mitigations referenced here (R1
  fence, R3 split, R4 axiom gate); this section is the recovery procedure, not a restatement of
  those risks.
