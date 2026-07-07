# Implementation Plan: Close the k=1 Bracket Gate under the E[Σ]-Fold Encoding (v3, witness-growth carrier after R2 = NO-GO at `VecEA2 1`)

- **Task**: 311 - close_k1_bracket_gate_efold
- **Status**: [IMPLEMENTING]
- **Effort**: 12 hours total (5 phases; Phases 1-2 complete at ~5h; ~7h remaining across Phases 3-5; hard mode, H8 sizing)
- **Dependencies**: 310 (COMPLETE — `Kamp/NfEFold.lean` landed sorry-free), parent 309 (BLOCKED, resumes via `/revise 309` after this task's GO verdict)
- **Research Inputs**:
  - `specs/311_close_k1_bracket_gate_efold/reports/01_rabinovich-faithfulness-audit.md` (adversarial audit of plan v1; caveats C1-C6 folded into v2 and carried here)
  - `specs/310_normalform_efold_encoding/reports/01_efold-encoding-research.md` (Tier-1, Rabinovich-2014-grounded)
  - R2 = NO-GO record at `VecEA2 1` — `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge.lean:1750-1823` (line-verified this session; the authoritative refutation input for this revision)
  - `specs/311_close_k1_bracket_gate_efold/.orchestrator-handoff.json` (`continuation_context` — authoritative revision input: fold assets unchanged; candidate witness-growing carrier; reusable RHS→LHS insight)
  - `specs/311_close_k1_bracket_gate_efold/summaries/01_k1-gate-closure-summary.md` (Phase 2 dispatch summary)
- **Artifacts**: plans/03_k1-gate-closure-plan-v3.md (this file); `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge.lean` (edited, additive only)
- **Standards**: plan-format.md; status-markers.md; artifact-management.md; tasks.md; zero-debt (0 new sorries); axioms exactly `[propext, Classical.choice, Quot.sound]`; G5 literature-fidelity (no simp/omega/aesop chain-step shortcut); lean4.md vacuous-definition prohibition
- **Type**: lean4 (hard mode, H8 sizing)

## Overview

Plan v2's Phase 2 decision-gate dispatch resolved **R2 = NO-GO at codomain `VecEA2 1`** — and
simultaneously **VINDICATED the E[Σ]-fold encoding**. The k=1 `BracketCarrierCorrect` instance for
the Phase-1 carrier `bracketEndChar_k1` (NfMultiAnchorBridge.lean:1670-1748) was REFUTED by a
dense-order semantic counterexample, not stalled: `bracketBuildLeft_correct`
(VecEATranslation.lean:503) anchors interior-positive chains at `∃ z0 < w` of the endpoint TYPE,
not the fixed endpoint `x`, so the χ-witness may land in `(z0, x]`, outside `(x, w)`
(counterexample: sig = {P}, M = ℝ, P ⊨ {1}, x = 2, t = 10, fiber-supported `qnf.2` with
`b zXW χ_P = true`; full record at NfMultiAnchorBridge.lean:1750-1823). Crucially, **no arity-4
residual and no navigated arity-3 characteristic arose anywhere** — chain steps 1-2 discharge
against the landed fold assets (`nf_eval_nf1_iff_efold` NfEFold:490,
`nf_quant_layer_fold_k1_gate` NfEFold:525). The blocker MOVED from anchor arity (unfixable,
Lemma 3.2(2) ≤2 cap) to bracket **witness count** (fixable, Rabinovich-licensed growth).

Plan v3 accepts the G6-SHAPE escalation with the concrete refutation as justification (see "G6
Amendment" below): the carrier codomain is relaxed from `VecEA2 1` to the witness-growing
`VVecEA2` (VecEAFormula.lean:271 — a finite disjunction of `Σ n, VecEA2 n` disjuncts), with the
anchors staying FIXED at `{x, t}`. Each interior-positive `(zone, χ)` fold bit becomes an
additional bracket WITNESS ordered between the fixed endpoints (per-qnf witness count
`1 + #(interior-positive (zone, χ) pairs)`, bounded per signature); the model-dependent ORDER of
those witnesses is handled by a finite disjunction over arrangements — exactly Rabinovich's
"disjunctions ranging only over consistent order types". Three new phases: (3) the witness-growing
carrier type + definition `bracketEndChar_k1v`; (4) the soundness (LHS→RHS) direction; (5) the
completeness (RHS→LHS) direction, the assembled `↔`, and the R2 gate re-probe verdict record.

### Research Integration

| Report | Integrated in plan version | Date |
|--------|---------------------------|------|
| `reports/01_rabinovich-faithfulness-audit.md` | 2 (carried into 3) | 2026-07-06 |
| 310 `reports/01_efold-encoding-research.md` | 1 (carried) | 2026-07-05 |
| R2 = NO-GO record `NfMultiAnchorBridge.lean:1750-1823` + `.orchestrator-handoff.json` continuation_context | 3 | 2026-07-06 |

### G6 Amendment (v3) — recorded per the task-description NOTE

G6's carrier **SHAPE is unchanged**: the recursion carrier stays the two-anchor bracket
characteristic with FIXED endpoints `z_0 = x`, `z_1 = t`, and `w` a bracket WITNESS — never an
arity-1 navigated point characteristic, never an interior-existential-witness evaluation, never a
third free anchor. What is **amended** is ONLY the parenthetical codomain: `VecEA2 1` (one
interval witness) becomes witness-growing `VecEA2 n`, assembled as a `VVecEA2` finite disjunction
(`Σ n, VecEA2 n` disjuncts, VecEAFormula.lean:271). Anchors stay `{x, t}` (2, fixed); `w` stays a
bracket witness — now one among others.

**Refutation justification** (the concrete counterexample the R1 fence required before any
codomain change): the dense-order counterexample at NfMultiAnchorBridge.lean:1782-1796 shows a
`BracketFormula 1` codomain cannot host the interior-positive witnesses — the carrier LHS holds at
(2, 10) via a type-anchored chain absorbing `u = 1 ∉ (2, 5)` while
`∃ w, nf_eval_nf M 1 3 [w,x,t] qnf` is false for every `w`. Monadic point types cannot separate
points `≤ x` from points in `(x, w)`; only a bracket-witness slot ordered between the fixed
endpoints can pin the χ-witness strictly inside the interior zone.

**Rabinovich license for witness growth** (anchors capped, witnesses not):
- **Lemma 3.2(2) (PDF p.4)** caps ANCHORS (free variables) at ≤2 — it says nothing capping
  bracket witnesses. G2 (no third free anchor) and G4 (env arity never grows past
  `{w,x,t}=3 → {x,t}=2`; anchor set `{x,t}`) SURVIVE intact.
- **§5 bracket notation `[α_0, …, α_n](z_0, z_1)` (PDF p.7)** carries `n` witnesses between the
  two fixed endpoints — witness growth is the printed shape of the bracket.
- **Lemma 3.4 (PDF p.5)** (∨∃∀ closed under ∃): each absorbed existential JOINS the existential
  prefix as a witness — implemented by `BracketFormula.existsBounded_right` (VecEAClosure.lean:265,
  verified signature: concludes `∃ m, ∃ bf' : BracketFormula m, bf'.holds M atomMap z0 z1`).
- Audit Red Flag C (caveat C3): witness-count growth under ∃-closure is licensed; anchor-count
  growth is not. The escalation fence was honored — the codomain change happens HERE, at the
  orchestrator/plan level, with the refutation on record, never as an implementer call.

### Preserved Assets

The following work is COMPLETE and MUST NOT regress. Phases below only ADD to
`NfMultiAnchorBridge.lean` (after :1823); no existing declaration is modified; `NfEFold.lean` is
not edited at all. New v3 rows were verified this session (2026-07-06) with Grep/Read against the
working tree; carried rows keep v2's verified references.

| Component | File:line (verified) | Status | Consumed as |
|-----------|---------------------|--------|-------------|
| **k=1 fold carrier (v2 Phase 1)** | `NfMultiAnchorBridge.lean:1670-1748` (`bracketEndChar_k1`) | [COMPLETED] 311 P1 | **building-block template ONLY** — its fold bits `b`, zone specs, `char`, `lit`, `epL`/`epR`, `segL`/`segR`, and gate (:1676-1739) are reused verbatim in the v3 carrier; per handoff item (5) it MUST NOT be resurrected as the correctness carrier |
| **R2 = NO-GO record (v2 Phase 2)** | `NfMultiAnchorBridge.lean:1750-1823` | [COMPLETED] 311 P2 | refutation + fix-direction record; verdict-mirror format for Phase 5; MUST NOT be edited |
| VecEA2 structure + holds | `VecEAFormula.lean:252/262` (`VecEA2`, `VecEA2.holds`) | [COMPLETED] | disjunct type |
| **VVecEA2 structure + holds + disj** | `VecEAFormula.lean:271/276/282/286` (`VVecEA2` with `disjuncts : List (Σ n, VecEA2 n)`, `.holds` = `∃ vea ∈ disjuncts, vea.2.holds`, `.disj`, `disj_holds`) | [COMPLETED] | **revised carrier codomain** |
| VVecEA2/BracketFormula conjunction closure | `VecEAClosure.lean:109/126` (`BracketFormula.conjStruct(_holds)`), `:46` (`conj_to_bracket_exists`), `:195/205` (`VVecEA2.conj_struct(_holds)`) | [COMPLETED] 306 | available combinators |
| ∃-closure vehicle | `VecEAClosure.lean:265` (`BracketFormula.existsBounded_right` — appends one witness; concludes `∃ m, ∃ bf', bf'.holds`), `:371` (`VBracketFormula.existsBounded_right`) | [COMPLETED] 309 | witness-insertion TEMPLATE for Phase 5 (its `n+1` case is the append-a-witness construction to mirror) |
| NF uniqueness at a point | `NormalForm.lean:245/277` (`nf_eval_unique`, `nf_exists_unique`) | [COMPLETED] | distinctness of realizing points for distinct χ (Phase 5) |
| char formula correctness (arity 1) | `KampPrior.lean:168` (`nf_depth0_char_formula_correct_arity1`) | [COMPLETED] | point-type ↔ `nf_eval_nf M 0 1` bridge |
| E[Σ]-fold type + eval | `Kamp/NfEFold.lean:77/102` (`NormalFormEFold`, `nf_eval_efold`) | [COMPLETED] 310 | dependency |
| zone semantics + E-atom domain | `Kamp/NfEFold.lean:58/69` (`zoneHolds`, `EAtomDom`) | [COMPLETED] 310 | quant-layer domain |
| general-n fold engine | `Kamp/NfEFold.lean:391` (`nf_quant_layer_fold_iff`) | [COMPLETED] 310 | (via the two lemmas below) |
| Gate corollary (verbatim old R2 residual) | `Kamp/NfEFold.lean:525` (`nf_quant_layer_fold_k1_gate`) | [COMPLETED] 310 | **entry point** (Phases 4-5) — VINDICATED by the re-probe (no arity-4 residual) |
| k=1 whole-eval bridge | `Kamp/NfEFold.lean:490` (`nf_eval_nf1_iff_efold`) | [COMPLETED] 310 | quant-layer discharge (Phases 4-5) |
| fold-of-nf1 transport | `Kamp/NfEFold.lean:472` (`efold_of_nf1`) | [COMPLETED] 310 | carrier construction (Phase 3) |
| depth-0 split kit + round-trips | `Kamp/NfEFold.lean:153-235` (`nf0_zoneSpec:153/projFresh:162/dropFresh:171/assemble:180`, `nf0_split_assemble:235`) | [COMPLETED] 310 | zone matching |
| G6 carrier SHAPE (original) | `NfMultiAnchorBridge.lean:1542/1552` (`BracketEndCharCarrier` abbrev, `BracketCarrierCorrect`; goal shape :1556-1558) | [COMPLETED] 309 P9 | unchanged and untouched; Phase 3 adds a PARALLEL V-variant, it does not modify these |
| depth-0 carrier + correctness | `NfMultiAnchorBridge.lean:1563/1577` (`bracketEndChar_k0(_correct)`; six order hypotheses :1581-1586) | [COMPLETED] 309 P9 | atom-layer discharge template + the k0-mirror hypothesis style for the k=1 theorem |
| old R2 NO-GO record (309 P10) | `NfMultiAnchorBridge.lean:1586-1618` region (v2-verified; residual quote) | [COMPLETED] 309 P10 | verdict-mirror format |
| depth-0 bracket collapse | `VecEADecomp.lean:233/244` (`nf_3var_bracket_xyt(_correct)`) | [COMPLETED] 309 | atom-layer `↔` |
| bracket builders | `VecEATranslation.lean:273/503` (`bracketBuildLeft(_correct)`), `:50/234` (`bracketBuildRight(_correct)`) | [COMPLETED] 309 | REFUTED as interior-positive carrier device (rule N4); still valid for the zPastX/zFutT endpoint literals where the anchor IS the fixed endpoint |
| trichotomy + off-diag arms | `NfZoneFlattenNavigable.lean:188/335/386` | [COMPLETED] 309 | zone case split |
| zone flatten + diag | `NfMultiAnchorBridge.lean:689/709/835`, `:763/780` | [COMPLETED] 309 | navigated-zone reuse |
| Phase 1-5 off-diag assets | `NfMultiAnchorBridge.lean:364/375/391/891/907/1229/1252/1428/1452` | [COMPLETED] 309 | not directly consumed; must not regress |
| Fintype/DecidableEq (NormalForm) | `NormalForm.lean:177/181`; `nf_eval_nf` unfolding `:201` | [COMPLETED] | off-fiber clause decidability; `Finset.univ.toList` enumeration |
| order-conflict falsity pattern | `NfDepth0Generalized.lean:93` (`nf_depth0_pair_cycle_empty'`) | [COMPLETED] | inconsistent-zone falsity |
| current live sorries | `KampPrior.lean:351` (309 scope), `:354` (305 scope); `EANegation.lean:1090/1249` (documented non-blocking) | held | not touched |
| **RHS→LHS insight (handoff item 3)** | `.orchestrator-handoff.json` continuation_context | recorded | the soundness reasoning for the OLD carrier (chain anchor `z0 := x`; interior points all carry positive-bit types so segment exclusions hold) — reusable in Phase 4's per-zone matching |

**Import-direction resolution (carried, re-verified)**: `import …Kamp.NfEFold` already landed at
`NfMultiAnchorBridge.lean:2` (v2 Phase 1); full build GREEN. No new imports are expected —
`VVecEA2` lives in `VecEAFormula.lean`, already in the import closure (the file uses
`VecEA2`/`BracketFormula.single` today). No file relocation.

**Fintype/DecidableEq for `NormalFormEFold` — NOT required; dropped with justification (carried
from v1/v2, unchanged)**: the only decidability needed is the off-fiber clause + gate Prop, covered
by `NormalForm.lean:177/181` and `Classical.dec`.

### Source-to-Implementation Mapping (Tier 1, Rabinovich 2014 — audit-corrected, v3 witness-growth rows added)

Rows 1-6b carry from v2 (audit-verified pages; caveats C1/C2 split citations). Rows 7-9 are new in
v3 and ground the witness-growth codomain.

| # | Rabinovich source | PDF page | Lean asset (consumed) | New 311 artifact using it | Audit/refutation status |
|---|-------------------|----------|-----------------------|---------------------------|------------------------|
| 1 | Def 4.1 (E[Σ] monadic-atom fold; p.6 note licenses iterated folds) | p.5 (note p.6) | `nf_eval_efold` (NfEFold:102), `efold_of_nf1` (:472) | `bracketEndChar_k1v` (Phase 3) | FAITHFUL |
| 2 | Lemma 3.2(2) (every ∃∀ ≡ conj of ∃∀ with ≤2 free variables) | p.4 | `EAtomDom` (NfEFold:69); `VVecEA2` fixed two-endpoint holds signature | anchor-count invariant, all phases | FAITHFUL — caps ANCHORS, not witnesses (G6 amendment license) |
| 3 | Def 3.1 (∃∀ normal form; α_j/β_j quantifier-free with ONE variable) | p.4 | `zoneHolds` (NfEFold:58), `nf0_zoneSpec` (:153) | zone matching (Phases 4-5); LEAD evidence of the verdict record (N3) | FAITHFUL — strongest anti-"novel-math" evidence; confirmed by the re-probe |
| 4a | Prop 3.5 (one-free-variable ∨∃∀ → TL; ∃-witness→Until/Since **folding mechanism**) | p.5 | `nf_3var_bracket_xyt(_correct)` (VecEADecomp:233/244) | endpoint zPastX/zFutT literals (carried); atom layer (Phases 4-5) | PARTIAL in v1 → corrected split (C1/N1) |
| 4b | Lemma 3.2(2) + §5 bracket notation (the **two-fixed-endpoint bracket** framing) | p.4 + p.7 | `BracketEndCharCarrier` shape (Bridge:1542); V-variant (Phase 3) | endpoint framing (all phases) | corrected split citation (C1) |
| 5 | Lemma 3.4 (∨∃∀ closed under ∃; witness joins the existential prefix — a bracket witness, never an anchor) | p.5 | `BracketFormula.existsBounded_right` (VecEAClosure:265) | witness-insertion induction (Phase 5) | FAITHFUL — now the LOAD-BEARING license: the NO-GO record shows its `∃ m` conclusion is consumable only by a witness-growing codomain |
| 6a | Def 4.1 **p.6 note** (TL over E[Σ] ≡ TL over Σ, iterated — "innermost fold") | p.6 | `nf_quant_layer_fold_k1_gate` (NfEFold:525) | RHS rewrite (Phases 4-5) | corrected split citation (C2/N2); VINDICATED by re-probe |
| 6b | Prop 4.3 (every FO formula ≡ ∨∃∀; residual-is-∨∃∀ over E[Σ] atoms; realized locally via the fold, NOT literal structural induction — 305 report 14) | p.6 | `nf_eval_nf1_iff_efold` (NfEFold:490) | residual reading (Phases 4-5) | corrected split citation (C2); VINDICATED by re-probe |
| 7 | **§5 bracket notation `[α_0, …, α_n](z_0, z_1)`** — the printed bracket carries **n witnesses** between two fixed endpoints | p.7 | `VecEA2 n` / `VVecEA2` (VecEAFormula:252/271) | revised carrier codomain (Phase 3) — per-qnf witness count `1 + #(interior-positive (zone, χ) pairs)` | NEW in v3 — the witness-growth shape is Rabinovich's own |
| 8 | **Lemma 3.4 (p.5) ∃-closure**: absorbed existentials JOIN the prefix as witnesses | p.5 | `existsBounded_right` (VecEAClosure:265, `n → n+1` append construction) | Phase 5 witness-insertion induction (template; the fixed-disjunct target is proved by mirroring its construction, not by invoking its `∃ m` conclusion) | NEW in v3 |
| 9 | **∨ over consistent order types** (the ∨ of ∨∃∀; Def 3.1 disjunctions range over consistent arrangements) | p.4-5 | `VVecEA2.disjuncts` (VecEAFormula:271) | arrangement enumeration: one disjunct per linear ordering of the interior-positive witnesses (Phases 3, 5) | NEW in v3 — handles the model-dependent witness order faithfully |

## Postmortem Constraints

Binding rules for all implementation dispatches. Sources: the NEW R2 = NO-GO record
(`NfMultiAnchorBridge.lean:1750-1823`), the OLD R2 NO-GO record (:1586-1618 region), the 309
plan-v3 Postmortem Constraints (G1-G6 + Corrected Anchor-Cap, carried VERBATIM below per the task
description), the audit caveats (rules N1-N3), and NEW rules N4-N5 distilled from the
counterexample.

**Guards G1-G6 + Corrected Anchor-Cap (VERBATIM from the task description / 309 plans/03
Postmortem Constraints)**:

- G1 -- No arity-1 collapse of the off-diagonal. (Refuted: report 02 SS1; NfDepth0Generalized:1691-1719.)
- G2 -- No projection-based VecEA2 / third-free-anchor tower. (Refuted: specs/305 report 40; R2.)
- G3 -- No trivial-top segment on the off-diagonal arms. A closed pastEnd under a trivial segment is unsatisfiable; the (x,t) coupling MUST ride the non-trivial Rabinovich beta_i segment (a real interval type, not top/trivial).
- G4 -- w stays a bracket witness. Env arity never grows past {w,x,t}=3 -> {x,t}=2; anchor set {x,t}; Rabinovich <=2 cap.
- G5 -- Follow Cor 5.4 / Prop 3.5 F_i chains step-by-step; no simp/omega/aesop shortcut of a chain step (literature-fidelity policy). Cite Rabinovich PDF p.4-5 at every chain step.
- G6 -- The recursion carrier MUST be the two-anchor bracket characteristic with FIXED endpoints z_0,z_1 (Prop 3.5, PDF p.5): NormalForm sig k 3 -> VecEA2 1 (two endpoint TemporalPreds + one interval TemporalPred), {x,t} FIXED, w a bracket WITNESS. It MUST NOT be an arity-1 navigated point characteristic nor an interior-existential-witness evaluation. CRITICAL DISTINCTION from G2: G2 bars a THIRD free anchor; G6's VecEA2 is a fixed-endpoint bracket, not a projection tower -- anchors stay {x,t} (2, fixed).
- Corrected Anchor-Cap Statement: the hook-discharge path MUST keep the anchor set at {x,t} (<=2) by the bracket-witness-collapse mechanism, NOT by nf_char3_deeper_split (NfMultiAnchorBridge.lean:625-642, which grows arity 3->4 and anchors {x,t}->{y,x,t} -- forbidden tower).

*(G6 amendment, binding in v3: the guard text above stays verbatim as the settled 309 contract,
but its parenthetical codomain `VecEA2 1` is AMENDED per the "G6 Amendment (v3)" section — the
carrier codomain is witness-growing `VecEA2 n` assembled as `VVecEA2`, anchors still `{x, t}`
FIXED, `w` still a bracket witness among others. The amendment is refutation-justified
(NfMultiAnchorBridge:1782-1796) and Rabinovich-licensed (Lemma 3.2(2) p.4 caps ANCHORS not
witnesses; §5 bracket p.7 carries n witnesses; Lemma 3.4 p.5 ∃-closure). Every other clause of G6
— SHAPE, fixed endpoints, no navigated characteristic, no interior-existential-witness evaluation
— remains fully binding. G2/G4 survive unamended: no third ANCHOR ever.)*

*(Precision note, carried from v2: per audit caveat C1, where G6's parenthetical cites "Prop 3.5,
PDF p.5" for the fixed-endpoint framing, NEW doc-comments must use the split citation of rule N1.)*

**Audit-derived rules (carried from v2)**:

- **N1 (caveat C1)** -- In every NEW doc-comment and chain-step comment, do NOT cite Prop 3.5 alone
  for the two-fixed-endpoint bracket. Required split: **Prop 3.5 (p.5)** = the one-free-variable
  ∃-witness→Until/Since folding *mechanism*; **Lemma 3.2(2) (p.4) + §5 bracket notation (p.7)** = the
  two-fixed-endpoint `(z_0,z_1)` framing.
- **N2 (caveat C2)** -- For the gate-corollary rewrite step, cite the **Def 4.1 p.6 note** for the
  "innermost fold / iteration" reading and **Prop 4.3 (p.6)** only for "the residual is ∨∃∀ over
  E[Σ] atoms"; the comment must note that the codebase realizes Prop 4.3's content locally via the
  fold, not via literal structural induction (305 report 14).
- **N3 (caveat C4)** -- The R2 verdict doc-comment MUST lead with the Def 3.1 evidence: α_j/β_j are
  one-variable quantifier-free formulas, so the arity-4 residual `[x_1,w,x,t]` had no Rabinovich
  counterpart — a Lean `nf_eval_nf` arity-growth artifact; the fold restores Def-4.1 fidelity.

**New counterexample-derived rules (v3)**:

- **N4 (from the NO-GO record :1767-1796)** -- Interior-positive `(zone, χ)` content MUST be
  encoded as bracket WITNESSES ordered between the fixed endpoints (occupying `pointTypes` slots of
  the `BracketFormula n`), NEVER as `bracketBuildLeft`/`bracketBuildRight` chains anchored at an
  existential point of an endpoint TYPE. **Interior-positive chains must anchor at the FIXED
  endpoint `x` (resp. `t`), not an existential endpoint of the endpoint type**: `∃ z0 < w, xType z0`
  anchoring is REFUTED — the χ-witness may land in `(z0, x]`, outside `(x, w)` (dense-order
  counterexample, NfMultiAnchorBridge:1782-1796). `bracketBuildLeft/Right` remain valid ONLY where
  the anchor genuinely is the fixed endpoint (the zPastX/zFutT endpoint literals in `epL`/`epR`).
- **N5 (arrangement disjunction)** -- The model-dependent ORDER of interior-positive witnesses is
  handled by a FINITE DISJUNCTION over linear arrangements inside `VVecEA2.disjuncts` (Rabinovich's
  ∨ over consistent order types, Def 3.1 / §5) — never by asserting a fixed order and never by an
  order-erasing shortcut. Distinctness of realizing points for DISTINCT complete 1-types comes from
  `nf_eval_unique` (NormalForm.lean:245); same-type multiplicity is NOT encoded (one witness per
  positive `(zone, χ)` pair suffices, since fold bits are existential).

**Do NOT** (updated for v3; line references verified):

- **Do NOT redefine the fold, the transport, or the gate corollary.** Consume `nf_eval_efold`,
  `efold_of_nf1`, `nf_eval_nf1_iff_efold`, `nf_quant_layer_fold_k1_gate`, and the split kit from
  `NfEFold` by name. Any local re-derivation is a defect.
- **Do NOT reconstruct the arity-4 residual.** Any goal showing env `[x_1, w, x, t]` (arity 4) not
  immediately routed through `nf_quant_layer_fold_k1_gate` (NfEFold:525) is the OLD NO-GO shape —
  rewrite via the gate corollary BEFORE splitting the `∃ w` (G4, Corrected Anchor-Cap).
- **Do NOT navigate `x, t` into an arity-3 characteristic.** The abandoned `EndCharCarrier` route
  (Bridge:1029, refuted at :1058-1069) stays inert.
- **Do NOT resurrect `bracketEndChar_k1` (:1670-1748) as the correctness carrier** (handoff item 5).
  It stays landed, sorry-free, OFF the live path. Reuse its BUILDING BLOCKS (fold bits, zone specs,
  `char`, `lit`, `epL`/`epR`, `segL`/`segR`, gate) in the new definition; do not modify or wire it.
- **Do NOT edit the NO-GO records** (:1586-1618 region, :1750-1823) or any existing declaration —
  all edits are additive after :1823.
- **Do NOT grow the ANCHOR count.** The V-carrier's `holds` signature stays two-point
  `(z0 z1 : M.carrier)` (VecEAFormula:276); endpoints `{x, t}` FIXED (Lemma 3.2(2), ≤2). Witness
  growth is licensed (G6 amendment); anchor growth is not (G2/G4). No third free anchor in any new
  declaration.
- **Do NOT encode interior-positive bits as type-anchored chains** (rule N4 — the refuted device).
- **Do NOT use `simp`/`omega`/`aesop` to shortcut a Prop-3.5 / Lemma-3.4 chain step** (G5,
  literature-fidelity). Cite the Rabinovich PDF page at each chain step, using the N1/N2 splits.
- **Do NOT introduce a third free anchor** (G2), an arity-1 navigated-point collapse (G1), or a
  trivial-top segment on the off-diagonal (G3). (N5's arrangement disjuncts carry the REAL
  `segL`/`segR` exclusion segments, not top — G3-compliant.)
- **Do NOT build `Fintype/DecidableEq (NormalFormEFold …)`** (dropped with justification).
- **Do NOT request a re-grounding/re-audit dispatch** (caveats C5/C6: the audit verified all page
  citations; the NO-GO record is machine-probed; both are the grounding authority here).

**MUST preserve**:

- All Preserved Assets above (edits ADD to `NfMultiAnchorBridge.lean` after :1823 only;
  `NfEFold.lean` untouched; `bracketEndChar_k1` and both NO-GO records byte-identical).
- Live sorry count stays at 2 in Kamp scope (`KampPrior.lean:351`, `:354`; `EANegation.lean:1090/
  1249` documented non-blocking) — 311 adds ZERO sorries; no vacuous definitions.
- Axiom profile exactly `[propext, Classical.choice, Quot.sound]` on every new declaration.

**Design decisions are SETTLED** (do not re-open without a concrete counterexample):

- The new artifacts live in `NfMultiAnchorBridge.lean`, additive, after :1823. No relocation.
- The carrier codomain is `VVecEA2` (finite disjunction of `Σ n, VecEA2 n`), endpoints `{x, t}`
  fixed, `w` one bracket witness among `1 + #(interior-positive pairs)` (G6-as-amended). The
  original `BracketEndCharCarrier`/`BracketCarrierCorrect` (:1542/:1552) are NOT modified — a
  parallel V-variant is added.
- The quant layer is discharged ONLY via `nf_quant_layer_fold_k1_gate` / `nf_eval_nf1_iff_efold`
  (proven route; vindicated by the re-probe).
- Interior-positive bits = bracket witness slots; witness order = arrangement disjunction (N4/N5).
- The k=1 correctness theorem is stated in the k0-mirror conditional form (the six bracket-zone
  order hypotheses on `qnf.1`, exactly as `bracketEndChar_k0_correct` :1577-1589 and exactly the
  scope of the refuted v2 target) — the same restriction task 309's R3 lift consumes.

## Goals & Non-Goals

**Goals**:
- Define the witness-growing carrier type `BracketEndCharCarrierV sig k := NormalForm sig k 3 →
  VVecEA2` and its correctness predicate `BracketCarrierCorrectV` (mirroring :1542/:1552 with
  `VVecEA2.holds`), plus the k=1 instance `bracketEndChar_k1v` reusing the Phase-1 building blocks,
  with N1/N4/N5-compliant citations.
- Prove `bracketEndChar_k1v_correct` — the k=1 instance of `BracketCarrierCorrectV` in the
  k0-mirror conditional form — sorry-free, via the two direction lemmas (Phases 4-5).
- `lake build` GREEN on the full tree; 0 new sorries; axioms exactly
  `[propext, Classical.choice, Quot.sound]` on all new declarations.
- Record an explicit **R2 gate re-probe verdict** (GO expected) mirroring the handoff format
  (:1586-1618 region and :1750-1823), leading with the N3 Def-3.1 evidence and recording the G6
  amendment, so task 309 can resume via `/revise 309` (plan v4). The verdict is recorded EITHER
  WAY (DECISION-GATE discipline) — a GO un-falsifies Path B at k=1 under the amended carrier.

**Non-Goals**:
- No depth-`k` (R3) lift, no `F_i`-chain (R4) — 309 scope, dispatchable after this.
- No modification of `BracketEndCharCarrier`/`BracketCarrierCorrect` (:1542/:1552), of
  `bracketEndChar_k1` (:1670-1748), of either NO-GO record, or of any k=0 asset.
- No `NormalFormEFold` Fintype/DecidableEq instances (dropped, justified).
- No edit to `NfEFold.lean`, plans 01/02, or state.json scope beyond normal status flow.
- No wiring onto 309's live path (the k=1 V-instance lands off the live path until `/revise 309`).
- No re-audit / re-grounding of the Rabinovich citations.
- No same-type witness multiplicity encoding (fold bits are existential; one witness per positive
  pair — N5).

## Risks & Mitigations

| ID | Risk | Likelihood | Mitigation |
|----|------|-----------|------------|
| R1' | **Arrangement-selection proof (Phase 5)**: from realized interior points in model order, selecting the matching permutation disjunct and proving its `holds` requires a sorting/insertion induction — the heaviest new machinery. | Medium | Private helper lemma proved by induction on the realized-point list, inserting one point at a time — mirror the append-a-witness construction of `existsBounded_right`'s `n+1` case (VecEAClosure:265, the Lemma 3.4 vehicle); the disjunct list contains ALL arrangements (`List.permutations` of the positive-χ enumerations), so the induction always has a target disjunct. Pre-authorized 5.1/5.2 split (below). |
| R2' | **Distinctness of realizing points**: two distinct positive χ's realized at the same point would break strict monotonicity of the witness tuple. | Low | Distinct complete 1-types cannot hold at one point: `nf_eval_unique` (NormalForm.lean:245) — if both `nf_eval_nf M 0 1 [u] χ1` and `… χ2` then `χ1 = χ2`. Bridge to `char` via `nf_depth0_char_formula_correct_arity1` (KampPrior:168). |
| R3' | Zone case analysis (7 consistent zones × per-χ bits) balloons past H8 size in Phase 4. | Medium | Equality zones = point type at a fixed point/witness; interior-positive zones = the bracket witnesses themselves (by `IntervalPattern.holds` monotonicity the i-th witness lies strictly in `(x,w)`/`(w,t)` — the exact defect fix); interior-negative = segment exclusions; exterior zones = the carried epL/epR Since/Until literals; inconsistent zones = gate conjunct (ii). If Phase 4 exceeds ~300 lines, split at a private per-zone matching lemma (4.1/4.2 escape hatch). |
| R4 | Axiom drift. | Low | `#print axioms` / `lean_verify` gate on ALL new declarations; inputs are Classical.dec + funext + order reasoning (same profile as landed assets). |
| R5 | Citation regression (conflated Prop 3.5 / Prop 4.3 cites; missing N4 flag). | Low | N1/N2/N4 binding; phase verification includes grep for "p.7", "Def 4.1 p.6 note", and "fixed endpoint" markers in new doc-comments. |
| R6 | Disjunct-enumeration blow-up (|S_L|!·|S_R|! disjuncts) makes elaboration slow. | Low | The enumeration is a `noncomputable` definition over `List.permutations` of per-signature-bounded lists; it is never normalized by `decide`/`native_decide`; proofs manipulate it via membership lemmas, not evaluation. If elaboration stalls, factor the disjunct builder into a named `private def`. |
| R7 | **Second refutation** (the V-carrier is still wrong somewhere unforeseen). | Low | Same DECISION-GATE discipline as v2: machine-probe the failing leaf (`lean_goal`/`lean_multi_attempt`), record the verdict EITHER WAY in the handoff-mirror format, land no partial theorem and no sorry, escalate with the goal state. The fence (audit caveat C3) still bars any implementer-level anchor growth. |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2 | 1 |
| 3 | 3 | 2 |
| 4 | 4 | 3 |
| 5 | 5 | 4 |

Phases within the same wave can execute in parallel. Here: strictly sequential — all phases edit
the same file (`NfMultiAnchorBridge.lean`, single-file territory, one owner per dispatch), and each
consumes the previous phase's declarations by name. Waves 1-2 are COMPLETE (v2 Phases 1-2). One
agent run per remaining phase (H8). Remaining output ~450-800 lines across Phases 3-5.

### Phase 1: Define the k=1 fold carrier instance `bracketEndChar_k1` [COMPLETED]

*(Carried VERBATIM from plan v2 Phase 1 — completed record, do not re-execute.)*

- **Goal:** Land the `k=1` carrier definition (typechecks, sorry-free) consuming 310's fold assets,
  with audit-corrected citations.
- **Tasks:**
  - [x] Add `import Bimodal.Metalogic.WeakCanonical.Kamp.NfEFold` to `NfMultiAnchorBridge.lean`
        (cycle-free, verified: NfEFold imports only NormalForm + NfDepth0Generalized).
        *(landed at NfMultiAnchorBridge.lean:2; full build GREEN — no cycle)*
  - [x] Define `noncomputable def bracketEndChar_k1 … : BracketEndCharCarrier sig 1`, i.e.
        `fun qnf : NormalForm sig 1 3 => (… : VecEA2 1)`, encoding `qnf`'s depth-1 content at the
        FIXED endpoints `{x,t}` with `w` the bracket witness (G6 SHAPE, codomain unchanged):
        endpoint `TemporalPred`s mirror the k=0 collapse `nf_3var_bracket_xyt` (VecEADecomp:233) on
        the atom layer `qnf.1`; the single interior `BracketFormula 1` carries the fold-reduced
        quant content of `qnf.2` — the zone-bounded monadic E-atoms
        `EAtomDom sig 0 3 = ZoneSpec 3 × NormalForm sig 0 1` exposed by the fold, read through
        `efold_of_nf1 qnf` (NfEFold:472), built with `BracketFormula.single` /
        `VecEA2.fromBracket` / `bracketBuildLeft/Right`. No `qnf.2` value is evaluated at arity 4 —
        quant content is read through `efold_of_nf1` / `nf0_assemble` only.
        *(landed at NfMultiAnchorBridge.lean:1670-1748: endpoints = `nf_x_proj3`/`nf_t_proj3` via
        `nf_depth0_char_formula` + exterior/equality-zone fold-bit literals; witness point type =
        `nf_y_proj` + at-`w` bits + interior-positive bits as `bracketBuildLeft/Right` chains;
        segment types = interior-negative universal exclusions)*
  - [x] Gate the construction on the off-fiber falsity of `qnf.2`
        (`∀ sub : NormalForm sig 0 4, nf0_dropFresh sub ≠ qnf.1 → qnf.2 sub = false` — decidable
        via NormalForm.lean:177/181, or `Classical.dec`; empty/⊥ carrier for incompatible `qnf`),
        mirroring Rabinovich's disjunctions ranging only over consistent order types (Risk R2).
        *(deviation: altered — gate is a conjunction of (i) the off-fiber clause AND (ii)
        order-conflict falsity: every fold bit on a zone spec inconsistent with the bracket order
        `x < w < t` must be false. (ii) is required for the LHS→RHS direction of Phase 2's `↔`:
        nothing in the `VecEA2.holds` semantics can force an inconsistent-zone bit false, while on
        the RHS such bits are false by order-conflict falsity (`nf_depth0_pair_cycle_empty'`) —
        both gate conjuncts are RHS-derivable, so the gate is symmetric. This realizes the same
        task-bullet rationale: "disjunctions ranging only over consistent order types".)*
  - [x] Doc-comment with the **N1 split citation** (caveat C1): Def 4.1 (p.5) for the monadic-atom
        fold; **Prop 3.5 (p.5) only for the ∃-witness→Until/Since folding mechanism**;
        **Lemma 3.2(2) (p.4) + §5 bracket notation (p.7) for the two-fixed-endpoint framing**.
        Do not cite Prop 3.5 alone for the two-endpoint bracket.
  - [x] Verify: `lake build` GREEN (scoped module build acceptable mid-phase, full tree at phase
        end); no `sorry`; no vacuous definition; signature grep confirms codomain `VecEA2 1` (no
        `VVecEA2` / `VecEA2 2`).
        *(full tree GREEN, 1705 jobs; 0 new sorries — all `sorry` matches in the file are prose;
        vacuous grep = 0; no `VVecEA2`/`VecEA2 2` matches; `lean_verify` on `bracketEndChar_k1` =
        `[propext, Classical.choice, Quot.sound]` exactly (R4 gate passed early); `git diff`
        additive-only — 130 insertions, 0 deletions in Theories/)*
- **Estimated output:** ~50-90 lines (delivered: 130 insertions).
- **Done when:** `bracketEndChar_k1 : BracketEndCharCarrier sig 1` typechecks sorry-free;
  `lake build` GREEN; N1-compliant doc-comment present; commit
  `task 311 phase 1: define k=1 fold carrier bracketEndChar_k1`.
- **Timing:** ~1.5-2 hours (one agent run).
- **Depends on:** none
- **Completed:** 2026-07-06

### Phase 2: k=1 gate probe at `VecEA2 1` (DECISION GATE) — resolved R2 = NO-GO, fold VINDICATED [COMPLETED]

*(This phase is the v2 Phase 2 dispatch, recast as the completed DECISION-GATE probe it was. Its
GO-target was refuted, but its gate function COMPLETED: a verdict was resolved and recorded either
way per v2 Rollback #2/#3 — the DECISION-GATE contract's success criterion. Preserved as the
historical record; do not re-execute; do not edit its landed artifact.)*

- **Goal (as executed):** Probe the k=1 `BracketCarrierCorrect` instance for `bracketEndChar_k1`
  through the v2 5-step chain, and resolve the R2 gate GO/NO-GO with the verdict recorded either
  way.
- **Outcome — R2 = NO-GO at `VecEA2 1`; the E[Σ]-fold VINDICATED:**
  - [x] Chain steps 1-2 discharge against the landed fold assets: `nf_eval_nf1_iff_efold`
        (NfEFold:490) rewrites the k=1 evaluation into fold form + off-fiber clause;
        `nf_quant_layer_fold_k1_gate` (NfEFold:525) reduces the OLD residual verbatim to
        zone-bounded monadic existentials. **No arity-4 residual and no navigated arity-3
        characteristic arises at any step** — the task-309 blocker is dead.
  - [x] Chain step 4 (interval zones) REFUTED for the Phase-1 carrier: the target `↔` (restricted
        to the six bracket-zone order hypotheses) is FALSE — dense-order counterexample
        (sig = {P}, M = ℝ, P ⊨ {1}, x = 2, t = 10, fiber-supported `qnf.2` with
        `b zXW χ_P = true`): carrier LHS holds at (2,10) via w = 5, chain anchor z0 = 0, absorbed
        witness u = 1 ∉ (2,5); RHS `∃ w, nf_eval_nf M 1 3 [w,x,t] qnf` false for every w. Root
        cause: `bracketBuildLeft_correct` (VecEATranslation:503) anchors at `∃ z0 < w` of the
        endpoint TYPE, not the fixed endpoint x; a `BracketFormula 1` has ONE interior witness
        slot while each interior-positive `(zone, χ)` bit needs its own witness joining the
        bracket prefix (Lemma 3.4 p.5; `existsBounded_right` VecEAClosure:265 grows witnesses,
        which a fixed `BracketFormula 1` output cannot consume). Machine-probed leaf
        (`lean_goal`/`lean_multi_attempt`/`lean_state_search`): needed `x < ws 0` underivable.
  - [x] R2 = NO-GO record landed additively (doc-comment only, zero declarations):
        `NfMultiAnchorBridge.lean:1750-1823`, handoff-mirror format, N3 Def-3.1 lead adapted to
        NO-GO, N1/N2 split citations, fix direction (witness growth, anchors fixed) recorded.
  - [x] R1 escalation fence honored (audit caveat C3): carrier codomain unchanged by the
        implementer, no third anchor, no partial theorem, no sorry; carrier intact and off the
        live path. Escalated to the orchestrator for the G6-SHAPE decision — resolved by THIS
        plan's G6 Amendment.
  - [x] Verify: full build GREEN (1705 jobs); zero new sorries (+75 comment-only lines);
        `lean_verify bracketEndChar_k1` = `[propext, Classical.choice, Quot.sound]`; citation
        markers present.
- **Reusable outputs:** the NO-GO record (:1750-1823); the RHS→LHS soundness insight (handoff item
  3); the vindicated chain steps 1-3/5, which remain the discharge route for the V-carrier.
- **Timing:** ~2.5-3 hours (one agent run, as dispatched).
- **Depends on:** 1
- **Completed:** 2026-07-06 (verdict resolved NO-GO; summary at
  `summaries/01_k1-gate-closure-summary.md`)

### Phase 3: Witness-growing carrier type + k=1 V-carrier `bracketEndChar_k1v` [COMPLETED]

- **Goal:** Land the amended-G6 carrier type, its correctness predicate, and the k=1 instance
  definition (typechecks, sorry-free), reusing the Phase-1 building blocks with the refuted chain
  device removed.
- **Tasks:**
  - [x] Define the V-variant carrier type and correctness predicate (parallel to :1542/:1552,
        which stay untouched):
        `abbrev BracketEndCharCarrierV (sig : MonadicSignature) (k : Nat) : Type :=
        NormalForm sig k 3 → VVecEA2` and
        `def BracketCarrierCorrectV … {k} (carrier : BracketEndCharCarrierV sig k) : Prop :=
        ∀ qnf x t, (carrier qnf).holds M atomMap x t ↔
        ∃ w, nf_eval_nf M k 3 (Fin.cons w (Fin.cons x (fun _ => t))) qnf` — same two-anchor
        `holds` signature (VecEAFormula:276), so Lemma 3.2(2)'s ≤2-anchor cap stays a TYPE-level
        invariant. Doc-comment records the **G6 amendment** verbatim-in-substance (SHAPE unchanged;
        codomain `VecEA2 1` → witness-growing `VecEA2 n` via `VVecEA2`; refutation justification
        :1782-1796; licenses Lemma 3.2(2) p.4 / §5 bracket p.7 / Lemma 3.4 p.5) with N1 split
        citations.
        *(landed: `BracketEndCharCarrierV` :1855, `BracketCarrierCorrectV` :1864; G6-amendment
        record in the module doc-comment :1825-1846)*
  - [x] Define `noncomputable def bracketEndChar_k1v … : BracketEndCharCarrierV sig 1`:
        - Reuse the Phase-1 building blocks verbatim (:1676-1739): fold bits
          `b zs χ := (efold_of_nf1 qnf).2 (zs, χ)`, the seven zone specs, `char`, `lit`,
          endpoint preds `epL`/`epR` (incl. the zPastX/zFutT Since/Until literals — N4-valid there:
          the anchor IS the fixed endpoint), segment exclusions `segL`/`segR`, and the two-conjunct
          gate (off-fiber falsity + order-conflict falsity).
        - Interior-positive enumerations: `S_L := allTypes.filter (fun χ => b zXW χ)`,
          `S_R := allTypes.filter (fun χ => b zWT χ)` (duplicate-free: `Finset.univ.toList`).
        - Witness point type at `w`: `char (nf_y_proj qnf.1)` + zAtW biconditional literals ONLY —
          the `bracketBuildLeft/Right` interior chains of :1725-1732 are REMOVED (rule N4: the
          refuted device).
        - Disjuncts (rule N5, mapping row 9): for each `(lL, lR) ∈ S_L.permutations ×
          S_R.permutations`, one disjunct `⟨lL.length + 1 + lR.length, VecEA2⟩` with
          `endpointLeft := epL`, `endpointRight := epR`, and bracket `pointTypes` = the `char`s of
          `lL`, then the `w` point type, then the `char`s of `lR` (each interior-positive pair
          occupies a WITNESS slot ordered between the fixed endpoints — §5 bracket p.7);
          `segmentTypes` = `segL` on every segment left of the `w` slot, `segR` on every segment
          right of it (real exclusion segments — G3-compliant, never top).
        - Gate-failure branch: the empty-disjunct `VVecEA2 ⟨[]⟩` (its `holds` is `False` —
          Rabinovich's empty disjunction over inconsistent order types).
        *(landed at :1923-2001; disjunct builder factored into `private def bracketFromLists`
        :1879 per the pre-authorized Risk R6 mitigation — deviation: altered, the point-type/
        segment-type assembly lives in the named private def rather than inline, so Phases 4-5
        can reason about it via its equations)*
  - [x] Doc-comment with N1 split + N4 flag ("interior-positive content as bracket witnesses
        anchored between the FIXED endpoints; type-anchored chains refuted at :1782-1796") + N5
        arrangement-disjunction citation (∨ over consistent order types).
  - [x] Verify: `lake build` GREEN full tree; no `sorry`; no vacuous definition; `lean_verify
        bracketEndChar_k1v` = `[propext, Classical.choice, Quot.sound]`; `git diff` additive-only
        after :1823; `bracketEndChar_k1` and both NO-GO records byte-identical; grep confirms no
        new `bracketBuildLeft`/`bracketBuildRight` use outside `epL`/`epR`.
        *(full tree GREEN, 1705 jobs; diff = 178 insertions, 0 deletions (byte-identical preserved
        assets by construction); 0 new sorries — scoped census hits only the pre-existing
        KampPrior:351/354, EANegation:1090/1249 (+ Boneyard/TruthLemma, out of scope); the only
        `bracketBuild` match in new code is doc-comment prose (the N4 refutation flag) — zero code
        uses; `lean_verify`: `bracketEndChar_k1v`, `BracketCarrierCorrectV` =
        `[propext, Classical.choice, Quot.sound]`, `bracketFromLists` = `[propext, Quot.sound]`
        (subset); citation markers "p.7" x9, "p.6 note" x1, "fixed endpoint" x11 in the diff)*
- **Estimated output:** ~120-200 lines (two small defs + one carrier def + doc-comments).
- **Bounded-unit test:** term constructions against known target types; fixed attempt surface;
  done-criterion checkable in isolation.
- **Done when:** `bracketEndChar_k1v : BracketEndCharCarrierV sig 1` typechecks sorry-free;
  build GREEN; G6-amendment doc-comment present; commit
  `task 311 phase 3: witness-growing V-carrier bracketEndChar_k1v`.
- **Timing:** ~1.5-2 hours (one agent run).
- **Depends on:** 2
- **Completed:** 2026-07-06

### Phase 4: Soundness direction (LHS→RHS) for the V-carrier [COMPLETED]

- **Goal:** Land the private soundness lemma: if `(bracketEndChar_k1v … qnf).holds M atomMap x t`
  (under the six k0-mirror bracket-zone order hypotheses on `qnf.1`, exactly as
  `bracketEndChar_k0_correct` :1581-1586), then
  `∃ w, nf_eval_nf M 1 3 (Fin.cons w (Fin.cons x (fun _ => t))) qnf`. Sorry-free.
- **Tasks:**
  - [x] State `private theorem bracketEndChar_k1v_sound` with the six order hypotheses. From
        `VVecEA2.holds` obtain the arrangement disjunct `(lL, lR)` and its `VecEA2.holds`; from
        `IntervalPattern.holds` monotonicity the witness tuple is strictly ordered in `(x, t)` —
        take `w :=` the middle witness (position `lL.length`). Each `lL`-witness lies strictly in
        `(x, w)` and each `lR`-witness strictly in `(w, t)` **by construction** — the exact
        counterexample defect removed (rule N4; this replaces the refuted chain reading).
        *(landed at NfMultiAnchorBridge.lean:2308 via the pre-authorized 4.1/4.2 split: private
        helper kit `k1v_zoneHolds_cons_iff`/`k1v_zone_consistent`/`k1v_bracket_extract`/
        `k1v_reconstruct_nf3` (Phase 4.1, commit 425d54d32) + the direction theorem (Phase 4.2).
        Deviation: altered — one additive Mathlib import (`Mathlib.Data.List.Permutation`, for
        `List.mem_permutations`) added at the file head; no project import, no declaration
        modified, diff otherwise after :1823 as planned.)*
  - [x] Chain step 1 — rewrite the RHS target via **`nf_eval_nf1_iff_efold`** (NfEFold:490, n=3,
        env `[w,x,t]`) into fold form + off-fiber clause; the off-fiber conjunct comes from gate
        conjunct (i). Cite per **N2** (Prop 4.3 p.6 = residual-is-∨∃∀ only; realized locally via
        the fold — 305 report 14).
        *(deviation: altered — the LHS→RHS direction consumes the depth-1 unfold (`Iff.rfl`, the
        same defeq split `nf_eval_nf1_iff_efold` itself uses at NfEFold:497-501) + the gate
        corollary directly, because only the ∃-witness direction is being BUILT here, not
        rewritten; N2 citation recorded in the doc-comment. `nf_eval_nf1_iff_efold` remains the
        Phase-5 vehicle for the RHS→LHS direction as planned.)*
  - [x] Chain step 2 — route the quant layer through **`nf_quant_layer_fold_k1_gate`**
        (NfEFold:525, `h_atom` from the atom layer): per-(zone, χ) obligations over
        `ZoneSpec 3 × NormalForm sig 0 1`. Cite per **N2** (Def 4.1 p.6 note = innermost fold;
        Lemma 3.4 p.5 for ∃-closure). *(landed: the `.mpr` of the gate corollary discharges the
        quant layer from `hzone` + gate conjunct (i); no arity-4 residual arose at any point)*
  - [x] Chain step 3 — atom layer at the endpoints via `nf_3var_bracket_xyt_correct`
        (VecEADecomp:244; k=0 template :1577) from `epL`/`epR` + the `w` point type
        (`nf_y_proj`); order bits from the six hypotheses + `x < w < t`. Cite per **N1**.
        *(deviation: altered — `nf_3var_bracket_xyt_correct` concludes `∃ w'` for a fresh
        witness, but the soundness chain needs the atom layer at the SPECIFIC middle witness `w`
        already fixed by the bracket; the same k0 reconstruction it rests on
        (`reconstruct_nf_3var`, VecEADecomp:407) is `private` and not importable, so a verbatim
        private clone `k1v_reconstruct_nf3` landed in the Bridge with the N1 citation. Same
        template, same inputs (three arity-1 point types + six order biconditionals).)*
  - [x] Chain step 4 (per-zone matching, the previously refuted surface — now direct):
        - interior-POSITIVE `(zXW/zWT, χ)`: the corresponding arrangement witness realizes χ
          strictly inside the interior zone (monotonicity, step above) — cite §5 bracket p.7 +
          Lemma 3.4 p.5;
        - interior-NEGATIVE: points of `(x,w)`/`(w,t)` other than witnesses satisfy `segL`/`segR`
          exclusions; witness points carry positive `char`s, and distinct complete 1-types exclude
          each other (`nf_eval_unique`, NormalForm:245, via `nf_depth0_char_formula_correct_arity1`,
          KampPrior:168);
        - equality zones (zAtX/zAtW/zAtT): biconditional literals in `epL`/`ptW`/`epR`;
        - exterior zones (zPastX/zFutT): the Since/Until literals in `epL`/`epR`
          (`bracketBuildLeft/Right_correct` — N4-valid: anchored at the fixed endpoints);
        - inconsistent zones: gate conjunct (ii) (order-conflict falsity;
          `nf_depth0_pair_cycle_empty'` NfDepth0Generalized:93).
        NO simp/omega/aesop chain-step shortcut (G5).
        *(landed: all seven consistent zones + the inconsistent-zone arm proved inside `hzone`;
        interior-negative completeness via the `k1v_bracket_extract` witness/gap classification +
        `nf_eval_unique` (NormalForm:245) through `nfPred_correct` (NfToVecEA:69 — the
        Bridge-accessible form of the KampPrior:168 arity-1 bridge, which is outside this file's
        import closure); inconsistent zones discharged by `k1v_zone_consistent` trichotomy +
        gate conjunct (ii) — `nf_depth0_pair_cycle_empty'` was not needed since the order
        conflict is semantic (LinearOrder trichotomy), not atom-level)*
  - [x] Verify: build GREEN full tree; no sorry; `lean_verify` axiom check; no edit to any
        existing declaration.
        *(full tree GREEN, 1705 jobs; 0 new sorries — all `sorry` matches in the file are prose;
        `#print axioms` on all five new declarations (`bracketEndChar_k1v_sound`,
        `k1v_bracket_extract`, `k1v_zone_consistent`, `k1v_reconstruct_nf3`,
        `k1v_zoneHolds_cons_iff`) = `[propext, Classical.choice, Quot.sound]` exactly; diff
        Theories/ = insertions only, 0 deletions — every existing declaration byte-identical;
        N4 grep: zero `bracketBuild*` occurrences in the new code; citation greps: "p.7" ×5,
        "p.6 note" ×2, "fixed endpoint" ×4 in the new diff)*
- **Estimated output:** ~150-300 lines (one private theorem + per-zone case analysis).
- **Bounded-unit test:** a fixed chain against NAMED landed lemmas; if any single step fails
  against its named lemma after honest attempts, that is a NAMED blocker to escalate with goal
  state (G5, R7 fence) — not a license for alternative mathematics.
- **H8 escape hatch (pre-authorized):** if the per-zone analysis pushes past ~300 lines, split at
  a private per-zone matching lemma (Phase 4.1) feeding the direction lemma (Phase 4.2) — same
  bounded units, no scope change, no new plan version.
- **Done when:** `bracketEndChar_k1v_sound` sorry-free; build GREEN; commit
  `task 311 phase 4: V-carrier soundness (LHS->RHS)`.
- **Timing:** ~2-2.5 hours (one agent run).
- **Depends on:** 3
- **Completed:** 2026-07-06 (4.1 helper kit commit 425d54d32 + 4.2 direction theorem; H8 escape
  hatch exercised as pre-authorized — delivered ~660 lines across the split, all additive)

### Phase 5: Completeness direction (RHS→LHS), assembled `↔`, and R2 gate re-probe verdict [IN PROGRESS]

- **Goal:** Close the k=1 gate: land the completeness lemma, assemble
  `bracketEndChar_k1v_correct` (the k=1 `BracketCarrierCorrectV` instance in k0-mirror conditional
  form), and record the R2 re-probe verdict either way.
- **Tasks:**
  - [ ] State `private theorem bracketEndChar_k1v_complete` (six order hypotheses): from
        `∃ w, nf_eval_nf M 1 3 [w,x,t] qnf`, derive both gate conjuncts (RHS-derivable — v2
        Phase-1 record; off-fiber from `nf_eval_nf1_iff_efold`'s 2nd conjunct, order-conflict
        falsity from `nf_depth0_pair_cycle_empty'`), then the fold biconditionals per (zone, χ)
        via chain steps 1-2 (same NAMED lemmas as Phase 4, N2 citations).
  - [ ] Realizing-point extraction: for each χ ∈ S_L (resp. S_R) the positive fold bit yields a
        point in `(x, w)` (resp. `(w, t)`) of complete type χ; distinctness across distinct χ by
        `nf_eval_unique` (NormalForm:245). Adapt the handoff's RHS→LHS insight: interior points
        all carry positive-bit types, so the `segL`/`segR` exclusions hold on all sub-segments.
  - [ ] Arrangement selection (Risk R1', rule N5): private insertion-induction helper — by
        induction on the realized-point list, insert one point at a time in model order to build
        the sorted witness tuple AND the matching permutation `(lL, lR)` (the disjunct list
        contains ALL arrangements, so a target disjunct always exists); mirror the
        append-a-witness construction of `existsBounded_right`'s `n+1` case (VecEAClosure:265 —
        the Lemma 3.4 p.5 vehicle, used as TEMPLATE since the target here is a fixed disjunct,
        not `∃ m`). Conclude the chosen disjunct's `VecEA2.holds`, hence `VVecEA2.holds`
        (VecEAFormula:276).
  - [ ] Assemble `theorem bracketEndChar_k1v_correct` (six order hypotheses, k0-mirror form
        :1577-1589 at depth 1): `(bracketEndChar_k1v … qnf).holds M atomMap x t ↔
        ∃ w, nf_eval_nf M 1 3 (Fin.cons w (Fin.cons x (fun _ => t))) qnf` from the two direction
        lemmas. Sorry-free.
  - [ ] Record the **R2 re-probe verdict** doc-comment mirroring the handoff format
        (:1586-1618 region, :1750-1823). Per **N3**, LEAD with the Def 3.1 evidence (α_j/β_j
        one-variable; arity-4 residual was a Lean artifact; fold restores Def-4.1 fidelity). Then:
        the G6 amendment (codomain `VecEA2 1` → witness-growing `VVecEA2`; anchors `{x,t}` fixed;
        counterexample justification :1782-1796; licenses Lemma 3.2(2) p.4 / §5 p.7 / Lemma 3.4
        p.5); evidence that the gate closed via `nf_quant_layer_fold_k1_gate` with no arity-4
        residual, no navigated arity-3 characteristic, no third anchor, and interior-positive
        content carried by bracket witnesses (N4). **R2 = GO** un-falsifies Path B at k=1 under
        the amended carrier and is 311's DONE signal, enabling `/revise 309` (plan v4). If the
        probe instead fails (Risk R7): record **R2 = NO-GO** with the failing goal state, no
        partial theorem, no sorry — verdict either way.
  - [ ] Verify: `lake build` GREEN full tree; live Kamp sorries still exactly 2 (KampPrior:351/354);
        `lean_verify` on `bracketEndChar_k1v`, `bracketEndChar_k1v_sound`,
        `bracketEndChar_k1v_complete`, `bracketEndChar_k1v_correct` =
        `[propext, Classical.choice, Quot.sound]`; citation grep (R5: "p.7", "Def 4.1 p.6 note",
        "fixed endpoint" markers); `git diff` additive-only.
- **Estimated output:** ~200-400 lines (two theorems + insertion helper + verdict doc-comment).
- **Bounded-unit test:** fixed chain against NAMED lemmas + one structured induction with a
  declared template; stopping condition independent of line count (G5, R7 fence).
- **H8 escape hatch (pre-authorized):** split at the insertion-induction helper (Phase 5.1:
  helper + completeness lemma; Phase 5.2: assembled `↔` + verdict record) — same bounded units,
  no scope change, no new plan version.
- **Done when:** `bracketEndChar_k1v_correct` sorry-free; build GREEN; axiom set exact; R2 verdict
  doc-comment present with N3 lead + G6-amendment record; commit
  `task 311 phase 5: close k=1 gate at V-carrier + R2 verdict`.
- **Timing:** ~2.5-3 hours (one agent run).
- **Depends on:** 4

## Testing & Validation

- [ ] `lake build` GREEN on the full tree after each phase (Phase 3: defs typecheck; Phase 4:
      soundness closes; Phase 5: `↔` closes).
- [ ] `lean_verify` (or `#print axioms`) on ALL new declarations (`BracketCarrierCorrectV`,
      `bracketEndChar_k1v`, `bracketEndChar_k1v_sound`, `bracketEndChar_k1v_complete`,
      `bracketEndChar_k1v_correct`, any private helpers) = `[propext, Classical.choice,
      Quot.sound]` (Risk R4 gate).
- [ ] Zero new `sorry` tokens in `NfMultiAnchorBridge.lean` (prose mentions in the NO-GO records
      excluded); repo live Kamp sorry count stays 2 (`KampPrior.lean:351/354`).
- [ ] Anchor-cap grep (G2/G4/amended G6): every new `holds` obligation is at the two-point
      signature `(x t : M.carrier)`; no new declaration takes a third free carrier point; witness
      growth appears only inside `BracketFormula n` / `Σ n, VecEA2 n` disjuncts.
- [ ] N4 grep: no `bracketBuildLeft`/`bracketBuildRight` occurrence in the NEW code outside the
      `epL`/`epR` exterior-zone literals.
- [ ] Citation grep (R5/N1/N2): new doc-comments contain "p.7" (§5 bracket) and "p.6 note"
      (Def 4.1 iteration) markers; Prop 3.5 never cited alone for the two-endpoint bracket in NEW
      comments.
- [ ] Preservation check: `git diff` shows additive hunks after :1823 only; `bracketEndChar_k1`
      (:1670-1748) and both NO-GO records (:1586-1618 region, :1750-1823) byte-identical;
      `NfEFold.lean` untouched.
- [ ] R2 verdict doc-comment present (GO or NO-GO), handoff-mirror format, N3 lead, G6-amendment
      record.

## Artifacts & Outputs

- `specs/311_close_k1_bracket_gate_efold/plans/03_k1-gate-closure-plan-v3.md` (this plan)
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge.lean`: one new abbrev
  (`BracketEndCharCarrierV`), one new correctness predicate (`BracketCarrierCorrectV`), one new
  `noncomputable def bracketEndChar_k1v`, two private direction lemmas + at most two private
  helpers (per-zone matching, insertion induction — pre-authorized escape hatches), one
  `theorem bracketEndChar_k1v_correct`, one R2 re-probe verdict doc-comment. All additive after
  :1823; no existing declaration modified.
- `specs/311_close_k1_bracket_gate_efold/summaries/02_k1-gate-closure-summary.md` (written by the
  implementer at completion, including the verdict, the N3-lead evidence, and the G6-amendment
  record).

## Rollback/Contingency

All edits are additive-only within a single file (`NfMultiAnchorBridge.lean`, after :1823);
`NfEFold.lean`, `bracketEndChar_k1`, both NO-GO records, and every Preserved Asset are untouched.
Rollback is trivial and fix-forward is the default.

- **Phase 3 breaks the build** (V-carrier definition fails to typecheck or the permutation
  enumeration stalls elaboration — Risk R6): the phase is a small block of defs. Rollback = delete
  the block (restores the exact post-Phase-2 tree). Fix-forward: factor the disjunct builder into
  named `private def`s and re-derive against the target type `VVecEA2` — never against a widened
  ANCHOR signature (G2/G4; the amendment licenses witness growth only). Commit only once
  `lake build` is GREEN.
- **Phase 4 or 5 stalls**: three graded responses, in order —
  1. If the stall is size/branching, take the **pre-authorized splits** (4.1/4.2 per-zone lemma;
     5.1/5.2 insertion helper). Same bounded units, no new plan version.
  2. If a single chain step fails against its NAMED lemma, or a genuinely new representability
     obstruction appears (Risk R7 — a second refutation), invoke the **DECISION-GATE fence**:
     STOP; do NOT add a third anchor, do NOT change the carrier signature, do NOT substitute
     alternative mathematics or `simp`/`omega`/`aesop` shortcuts (G5); machine-capture the leaf
     (`lean_goal`, `lean_multi_attempt`), and escalate to the orchestrator with the goal state —
     any further SHAPE decision is orchestrator-level, exactly as the `VecEA2 1` → `VVecEA2`
     amendment was.
  3. If the gate cannot be closed this dispatch, **record the verdict either way**: mirror the
     handoff format (:1586-1618 region, :1750-1823) with an **R2 = NO-GO (V-carrier)** doc-comment
     stating the exact failing goal shape and which step blocked; per the DECISION-GATE contract a
     NO-GO lands no partial `↔` theorem and no `sorry` (a sorry-free direction lemma that closed
     GREEN in an earlier phase MAY stay landed — it is a verified asset, mirroring how
     `bracketEndChar_k1` stayed landed after the v2 NO-GO). This keeps the verdict on record so
     `/revise 311` or `/revise 309` can act on it.
- **Git-snapshot / fix-forward discipline** (repo recovery ladder): commit at every GREEN
  milestone only (each phase committed GREEN before the next begins; sub-step commits per
  git-workflow.md where a phase splits). If a phase times out mid-work, mark it `[PARTIAL]` in the
  heading and leave the tree at the last GREEN commit; the next `/implement 311` resumes from the
  incomplete phase. Never commit a red tree or a new `sorry` (live Kamp sorry count stays 2,
  KampPrior:351/354).
- See **Risks & Mitigations** for per-risk mitigations referenced here (R1' insertion template,
  R3' split, R4 axiom gate, R6 elaboration factoring, R7 fence); this section is the recovery
  procedure, not a restatement of those risks.
