# Implementation Plan: Close the k=1 Bracket Gate under the E[Σ]-Fold Encoding

- **Task**: 311 (close_k1_bracket_gate_efold)
- **Status**: PLANNED
- **Effort**: high
- **Dependencies**: 310 (COMPLETE — NfEFold.lean landed sorry-free), parent 309 (BLOCKED, resumes after this)
- **Research Inputs**: `specs/310_normalform_efold_encoding/reports/01_efold-encoding-research.md` (Tier-1, Rabinovich-2014-grounded; §5.4–5.6 are 311's authority), `specs/309_offdiag_two_anchor_fi_chain/plans/03_offdiag-fi-chain-plan.md` (Phase 10 [BLOCKED] handoff + Postmortem Constraints G1–G6), R2 NO-GO record `NfMultiAnchorBridge.lean:1573-1618`
- **Artifacts**: `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge.lean` (edited)
- **Standards**: zero-debt (0 new sorries, same policy as 310); axioms exactly `[propext, Classical.choice, Quot.sound]`; G1–G6 + Corrected Anchor-Cap verbatim; G5 literature-fidelity (no simp/omega/aesop chain-step shortcut)
- **Type**: lean4 (hard mode, H8 sizing)

## Overview

Task 310 delivered the E[Σ]-fold encoding in `Kamp/NfEFold.lean`, landing sorry-free with the gate
corollary `nf_quant_layer_fold_k1_gate` stated **verbatim** against the R2 NO-GO residual, plus the
whole-evaluation bridge `nf_eval_nf1_iff_efold` and the depth-0 split kit. Task 311 consumes these to
close the single obligation that NO-GOed under the old `nf_eval_nf`-only encoding: the `k=1` instance
of `BracketCarrierCorrect` (`NfMultiAnchorBridge.lean:1546-1552` restricted to `k=1`).

The blocker was an **irreducible arity-4 residual** (env `[x_1, w, x, t]` coupling bracket witness `w`
to both fixed endpoints `x, t`) that no `VecEA2 1` monadic component could supply. The fold encoding
dissolves it: `nf_quant_layer_fold_k1_gate` rewrites the arity-4 quant layer into **zone-bounded
monadic existentials** over `EAtomDom sig 0 3 = ZoneSpec 3 × NormalForm sig 0 1` — each a Def-3.1
one-witness object over the fixed points `{x,t}` (report §5.5, PDF p.4–6), never an arity-4 object.

Two H8 phases: (1) define the `k=1` carrier instance `bracketEndChar_k1 : BracketEndCharCarrier sig 1`
via the fold; (2) prove `bracketEndChar_k1_correct` sorry-free by rewriting the RHS through
`nf_eval_nf1_iff_efold` + `nf_quant_layer_fold_k1_gate`, discharging the atom layer with the landed
`nf_3var_bracket_xyt_correct` (= `bracketEndChar_k0_correct` at depth 0), and matching the zone-bounded
monadic existentials to the `VecEA2 1` holds, then record the **R2 = GO** verdict.

**Import-direction resolution (verified this session)**: `NfEFold` imports only
`WeakCanonical.NormalForm` and `Kamp.NfDepth0Generalized`; it does **not** import `NfMultiAnchorBridge`
or `NfZoneFlattenNavigable` (references to the bridge in `NfEFold` are doc-comments only, lines
370/520). `NfDepth0Generalized` does not import the bridge either (only a doc-comment at :1724). Adding
`import Bimodal.Metalogic.WeakCanonical.Kamp.NfEFold` to the top of `NfMultiAnchorBridge` is therefore
**cycle-free** (NfEFold's imports are already transitively present via `NfZoneFlattenNavigable →
NfDepth0Generalized`). The `k=1` carrier instance and its correctness lemma stay **in
`NfMultiAnchorBridge`**, alongside `BracketEndCharCarrier` / `BracketCarrierCorrect` /
`bracketEndChar_k0(_correct)`. No file relocation is required.

**Fintype/DecidableEq for `NormalFormEFold` (deferred item from 310 Phase 1) — NOT required by 311;
dropped with justification.** The only decidability this task touches is the off-fiber falsity clause
`∀ sub : NormalForm sig 0 4, nf0_dropFresh sub ≠ qnf.1 → qnf.2 sub = false` (a conjunct of
`nf_eval_nf1_iff_efold`). It quantifies over `NormalForm sig 0 4` and compares against `qnf.1 :
NormalForm sig 0 3`, using `Fintype (NormalForm sig 0 4)` and `DecidableEq (NormalForm sig 0 3)` — both
**already landed** at `NormalForm.lean:177/181` (`normalForm_fintype` / `normalForm_decEq`). No instance
on the `NormalFormEFold` type itself is used: the carrier's `holds` is a `Prop`-valued semantic
statement (Classical reasoning suffices), and the fold's quant domain is `EAtomDom = ZoneSpec n ×
NormalForm sig k 1`, again a `NormalForm`, not `NormalFormEFold`. If a decidable off-fiber gate is
wanted in the carrier construction, `Classical.dec` on the `Prop` avoids any new instance. Building
`Fintype/DecidableEq (NormalFormEFold …)` would be dead weight for the gate closure and is left to a
future task should 309-R3 iteration need computable fold enumeration.

### Preserved Assets

The following work is COMPLETE and MUST NOT regress. Phases below only ADD to `NfMultiAnchorBridge`;
they touch no existing declaration.

| Component | File:line | Status | Consumed as |
|-----------|-----------|--------|-------------|
| E[Σ]-fold type + eval | `Kamp/NfEFold.lean:77/102` (`NormalFormEFold`, `nf_eval_efold`) | [COMPLETED] 310 | dependency |
| Gate corollary (verbatim R2 residual) | `Kamp/NfEFold.lean:525` (`nf_quant_layer_fold_k1_gate`) | [COMPLETED] 310 | **entry point** |
| k=1 whole-eval bridge | `Kamp/NfEFold.lean:490` (`nf_eval_nf1_iff_efold`) | [COMPLETED] 310 | quant-layer discharge |
| fold-of-nf1 transport | `Kamp/NfEFold.lean:472` (`efold_of_nf1`) | [COMPLETED] 310 | carrier construction |
| depth-0 split kit + round-trips | `Kamp/NfEFold.lean:153-280` (`nf0_zoneSpec/projFresh/dropFresh/assemble`, `nf0_split_assemble`) | [COMPLETED] 310 | zone matching |
| G6 carrier SHAPE | `NfMultiAnchorBridge.lean:1536/1546` (`BracketEndCharCarrier`/`BracketCarrierCorrect`) | [COMPLETED] 309 P9 | **unchanged; instantiated at k=1** |
| depth-0 carrier + correctness | `NfMultiAnchorBridge.lean:1557/1571` (`bracketEndChar_k0(_correct)`) | [COMPLETED] 309 P9 | atom-layer discharge template |
| depth-0 bracket collapse | `VecEADecomp.lean:233/244` (`nf_3var_bracket_xyt(_correct)`) | [COMPLETED] 309 | atom-layer `↔` |
| bracket builders | `VecEATranslation.lean:273/50/503/234` (`bracketBuildLeft/Right(_correct)`) | [COMPLETED] 309 | interval-witness matching |
| ∃-closure vehicle | `VecEAClosure.lean:265` (`existsBounded_right`) | [COMPLETED] 309 | zone-witness absorption |
| VecEA2 holds + ctors | `VecEAFormula.lean:252/305-331` (`VecEA2.holds`, `.fromBracket/.single`, `BracketFormula.single`) | [COMPLETED] | carrier output |
| Fintype/DecidableEq (NormalForm) | `NormalForm.lean:177/181` | [COMPLETED] | off-fiber clause decidability |
| current live sorries | `KampPrior.lean:351` (309 scope), `:354` (305 scope) | held at 2 | not touched |

### Source-to-Implementation Mapping (Tier 1, Rabinovich 2014)

| Rabinovich source | PDF page | Lean asset (consumed) | New 311 artifact using it |
|-------------------|----------|-----------------------|---------------------------|
| Def 4.1 (E[Σ] monadic-atom fold) | p.5 | `nf_eval_efold`, `efold_of_nf1` (NfEFold) | `bracketEndChar_k1` (Phase 1) |
| Lemma 3.2(2) (≤2 free variables, type-level cap) | p.4 | `EAtomDom = ZoneSpec n × NormalForm sig k 1` (NfEFold:69) | anchor-count invariant, both phases |
| Def 3.1 (∃∀ ordering conjuncts; witness meets env only via order) | p.4 | `zoneHolds`, `nf0_zoneSpec` (NfEFold:58/153) | zone matching (Phase 2) |
| Prop 3.5 (∃x_i ⇒ Until/Since bracket at FIXED endpoints z_0,z_1) | p.5 | `nf_3var_bracket_xyt(_correct)`, `bracketBuildLeft/Right` | endpoint + interval encode (both phases) |
| Lemma 3.4 (∃-closure absorbs the zone witness as a bracket witness) | p.5 | `existsBounded_right` (VecEAClosure:265) | interval-zone witness (Phase 2) |
| Prop 4.3 (innermost fold / iteration reading of the reduced residual) | p.6 | `nf_quant_layer_fold_k1_gate` (NfEFold:525) | RHS rewrite (Phase 2) |

## Postmortem Constraints

Binding rules for all implementation dispatches. Derived from the R2 NO-GO record
(`NfMultiAnchorBridge.lean:1573-1618`), the 309 plan-v3 Postmortem Constraints (G1–G6 + Corrected
Anchor-Cap), report §5.5–5.6, and the USER DIRECTIVE (maintain faithfulness with Rabinovich's proof
techniques).

**Do NOT**:
- **Do NOT redefine the fold, the transport, or the gate corollary.** Consume `nf_eval_efold`,
  `efold_of_nf1`, `nf_eval_nf1_iff_efold`, `nf_quant_layer_fold_k1_gate`, and the split kit from
  `NfEFold` by name. Any local re-derivation is a defect (the whole point of 310 was to land these).
- **Do NOT reconstruct the arity-4 residual.** The moment a goal shows env `[x_1, w, x, t]` (arity 4)
  or `NormalForm sig 0 4` on an evaluation RHS that is not immediately routed through
  `nf_quant_layer_fold_k1_gate`, stop — that is the exact NO-GO shape. Rewrite via the gate corollary
  BEFORE splitting the `∃ w` (G4, Corrected Anchor-Cap).
- **Do NOT navigate `x, t` into an arity-3 characteristic** (reading `w` while `x,t` are navigated in).
  That is the arity-4→arity-3 re-bounding obstruction G6 bars and that blocked plan-v2 Phase 8.
- **Do NOT grow the carrier's output shape past `VecEA2 1`.** The carrier stays
  `NormalForm sig 1 3 → VecEA2 1`. Endpoints `{x,t}` fixed (≤2, Lemma 3.2(2)); `w` a bracket WITNESS
  (G4/G6). (Report §5.6 flags that some interior zones `(x,w)`/`(w,t)` are two-witness `BracketFormula`
  objects — encode the extra witness INSIDE the single `VecEA2 1`'s `BracketFormula 1` interval via
  `bracketBuildLeft/Right` + `existsBounded_right`, keeping anchors `{x,t}`; see Risk R1. Do NOT switch
  the carrier codomain to `VVecEA2` or `VecEA2 2` — that changes the G6-settled SHAPE.)
- **Do NOT use `simp`/`omega`/`aesop` to shortcut a Prop-3.5 / Lemma-3.4 chain step** (G5,
  literature-fidelity). Cite the Rabinovich PDF page at each chain step in a comment.
- **Do NOT introduce a third free anchor** (G2) nor an arity-1 navigated-point collapse (G1) nor a
  trivial-top segment on the off-diagonal (G3).
- **Do NOT build `Fintype/DecidableEq (NormalFormEFold …)`** (see Overview — not needed, dead weight).

**MUST preserve**:
- All Preserved Assets above (edits ADD to `NfMultiAnchorBridge` only; no existing decl is modified).
- Live sorry count stays at 2 (`KampPrior.lean:351`, `:354`) — 311 adds ZERO sorries.
- Axiom profile exactly `[propext, Classical.choice, Quot.sound]` on both new declarations.

**Design decisions are SETTLED** (do not re-open without a concrete counterexample):
- The new artifacts live in `NfMultiAnchorBridge` with a single new `import …Kamp.NfEFold`
  (cycle-verified). No relocation, no new file.
- The carrier codomain is `VecEA2 1`, endpoints `{x,t}` fixed, `w` a bracket witness (G6 SHAPE).
- The quant layer is discharged ONLY via `nf_quant_layer_fold_k1_gate` (never by re-attacking the
  arity-4 goal directly — that path is proven NO-GO).
- Fintype/DecidableEq of `NormalFormEFold` is out of scope (Overview justification).

## Goals & Non-Goals

**Goals**:
- Define `bracketEndChar_k1 : BracketEndCharCarrier sig 1` (a `VecEA2 1`-valued carrier) via the fold.
- Prove `bracketEndChar_k1_correct : BracketCarrierCorrect M atomMap bracketEndChar_k1` (the `k=1`
  instance) sorry-free.
- `lake build` GREEN on the full tree; 0 new sorries; axioms exactly `[propext, Classical.choice,
  Quot.sound]` on both new declarations.
- Record an explicit **R2 = GO** verdict doc-comment (mirroring the Phase 10 handoff format) with
  evidence: the fold closed the gate via `nf_quant_layer_fold_k1_gate` with no arity-4 residual and no
  navigated arity-3 characteristic. This un-falsifies Path B at `k=1` and is 311's DONE signal.

**Non-Goals**:
- No depth-`k` (R3) lift, no `F_i`-chain (R4) — those stay 309 scope, dispatchable after this.
- No `NormalFormEFold` Fintype/DecidableEq instances (dropped, justified).
- No change to `BracketEndCharCarrier` / `BracketCarrierCorrect` SHAPE or to any k=0 asset.
- No wiring onto 309's live path (the k=1 instance lands off the live path until `/revise 309`).

## Risks & Mitigations

| ID | Risk | Likelihood | Mitigation |
|----|------|-----------|------------|
| R1 | Interior zones `(x,w)`/`(w,t)` need a SECOND interior witness, exceeding a single `BracketFormula 1` (report §5.6 open question). | Medium | Absorb the second witness INSIDE the `BracketFormula 1` interval via `bracketBuildLeft/Right(_correct)` + `existsBounded_right` (Lemma 3.4 ∃-closure, PDF p.5) — witness COUNT growing under ∃-closure is explicitly NOT what G6 caps (report §5.6). Anchors stay `{x,t}`. If genuinely infeasible within `VecEA2 1`, escalate to the orchestrator BEFORE changing the carrier codomain — do not silently switch to `VVecEA2`. |
| R2 | Off-fiber falsity clause (`nf_eval_nf1_iff_efold` 2nd conjunct) not dischargeable at the carrier. | Low | It is a fixed, `w`-independent, decidable condition on `qnf` (uses `Fintype (NormalForm sig 0 4)` / `DecidableEq (NormalForm sig 0 3)`, both landed). Pull it out of `∃ w` (`∃ w, P w ∧ Q ≡ (∃ w, P w) ∧ Q`) and gate the carrier's `holds` on it (Classical.dec on the Prop). |
| R3 | Zone case analysis (7 zones of `x_1` vs `[w,x,t]` under `x<w<t`) balloons past H8 size. | Medium | Equality zones read a point type at a fixed point/witness (`nf_eval_nf M 0 1`); interval zones are one `existsBounded_right` witness; inconsistent zones are false by order-conflict falsity (`NfDepth0Generalized:90-105` pattern). If Phase 2 exceeds ~150 lines, split at the zone-matching lemma (see Phase 2 note). |
| R4 | Axiom drift (an extra axiom leaks in). | Low | Final `#print axioms bracketEndChar_k1_correct` gate; all inputs are Classical.dec + funext + order reasoning (same profile as landed k=0 / NfEFold lemmas). |

## Implementation Phases

### Phase 1: Define the k=1 fold carrier instance `bracketEndChar_k1` [NOT STARTED]

Add `import Bimodal.Metalogic.WeakCanonical.Kamp.NfEFold` to `NfMultiAnchorBridge` (cycle-verified:
NfEFold imports only NormalForm + NfDepth0Generalized). Define

```
noncomputable def bracketEndChar_k1 {sig} (atomMap …) (h_surj …) : BracketEndCharCarrier sig 1 :=
  fun qnf : NormalForm sig 1 3 => (⟨…⟩ : VecEA2 1)
```

The `VecEA2 1` output encodes `qnf`'s depth-1 content at the FIXED endpoints `{x,t}` with `w` the
bracket witness (G6 SHAPE, codomain unchanged):
- `endpointLeft` / `endpointRight`: the endpoint `TemporalPred`s from the atom layer `qnf.1`, mirroring
  the k=0 collapse `nf_3var_bracket_xyt` on `qnf.1` (Prop 3.5, PDF p.5).
- `bracket : BracketFormula 1`: the single interior bracket witness `w`, whose point/segment types
  carry the fold-reduced quant content of `qnf.2` — i.e. the zone-bounded monadic E[Σ]-atoms
  `EAtomDom sig 0 3 = ZoneSpec 3 × NormalForm sig 0 1` that `nf_quant_layer_fold_k1_gate` exposes
  (`efold_of_nf1 qnf` supplies the transported quant assignment). Built with `BracketFormula.single` /
  `bracketBuildLeft/Right`.
- Gate the construction on the off-fiber falsity of `qnf.2` (decidable on `NormalForm`; empty/⊥ carrier
  for incompatible `qnf`), mirroring Rabinovich's disjunctions ranging only over consistent order types
  (report §5.6).

Cite Def 4.1 (p.5), Lemma 3.2(2) (p.4), Prop 3.5 (p.5) in the doc-comment. No `qnf.2` value is
evaluated at arity 4 — the quant content is read through `efold_of_nf1` / `nf0_assemble` only.

- **Estimated output**: ~50–90 lines (one `import` + one `noncomputable def` + doc-comment).
- **Bounded-unit test**: one definition; done-criterion = typechecks. Fixed attempt surface (a term
  construction against a known target type), not open-ended search.
- **Done when**: `bracketEndChar_k1 : BracketEndCharCarrier sig 1` typechecks; `lake build` GREEN; no
  `sorry`; codomain is `VecEA2 1` (grep-confirm no `VVecEA2`/`VecEA2 2` in the signature).

### Phase 2: Prove `bracketEndChar_k1_correct` sorry-free + record R2 = GO [NOT STARTED]

Prove the `k=1` instance of `BracketCarrierCorrect`:

```
theorem bracketEndChar_k1_correct {sig} (atomMap …) (h_surj …)
    (M : OrderedMonadicStructure sig) (qnf : NormalForm sig 1 3) (x t : M.carrier) :
    (bracketEndChar_k1 atomMap h_surj qnf).holds M atomMap x t ↔
      ∃ w : M.carrier, nf_eval_nf M 1 3 (Fin.cons w (Fin.cons x (fun _ => t))) qnf
```

Proof skeleton (each chain step cites the Rabinovich PDF page; NO simp/omega/aesop shortcut, G5):
1. Rewrite the RHS body `nf_eval_nf M 1 3 [w,x,t] qnf` via **`nf_eval_nf1_iff_efold`** (n=3,
   env=`[w,x,t]`) into `nf_eval_efold M 1 3 [w,x,t] (efold_of_nf1 qnf) ∧ off-fiber(qnf)`. Pull the
   `w`-independent off-fiber conjunct out of `∃ w` (Prop 4.3 innermost fold, p.6).
2. Route the fold's quant layer through **`nf_quant_layer_fold_k1_gate`** (with `h_atom` from the atom
   layer) so the residual is zone-bounded monadic existentials over `ZoneSpec 3 × NormalForm sig 0 1` —
   **no arity-4 object remains** (this is the NO-GO-dissolving step; Lemma 3.4, p.5).
3. Discharge the atom layer via **`nf_3var_bracket_xyt_correct`** (the k=0 template
   `bracketEndChar_k0_correct` reuses at the endpoints `{x,t}`; Prop 3.5, p.5).
4. Match each of the ≤7 order zones of the witness relative to `[w,x,t]` (under `x<w<t`) to the
   `VecEA2 1` `holds`: equality zones = point type at a fixed point/witness (`nf_eval_nf M 0 1`);
   interval zones = one `existsBounded_right` bracket witness (Lemma 3.4 ∃-closure, p.5); inconsistent
   zones = false by order-conflict falsity (`NfDepth0Generalized:90-105` pattern). Use
   `bracketBuildLeft/Right(_correct)`.
5. Close the off-fiber conjunct by the carrier's Phase-1 gate (decidable on `NormalForm`; R2).

Then record a doc-comment **R2 = GO** verdict (mirroring the Phase 10 handoff format): the fold closed
the k=1 gate via `nf_quant_layer_fold_k1_gate` with no arity-4 residual and no navigated arity-3
characteristic; Path B is un-falsified at k=1; task 309's R3/R4 are dispatchable via `/revise 309`.

- **Estimated output**: ~90–150 lines (one theorem + zone case analysis + GO doc-comment).
- **Bounded-unit test**: one theorem; done-criterion = sorry-free + exact axiom set. If the zone case
  analysis pushes past ~150 lines, split at a private `bracketEndChar_k1_zones` matching lemma (Phase
  2.1) feeding the main `↔` (Phase 2.2) — same bounded units, no scope change.
- **Done when**: `bracketEndChar_k1_correct` sorry-free; `lake build` GREEN full tree; live sorries
  still exactly 2; `#print axioms bracketEndChar_k1_correct` = `[propext, Classical.choice,
  Quot.sound]`; R2 = GO doc-comment present.

## Dependency Analysis

| Wave | Phases | Blocked by | Rationale |
|------|--------|------------|-----------|
| 1 | Phase 1 | — | Carrier def + import; no dependency. |
| 2 | Phase 2 | Phase 1 | Correctness references `bracketEndChar_k1` by name. |

Strictly sequential (both phases edit the same file, and Phase 2 consumes Phase 1's definition). No
parallel opportunity; single-agent dispatch per phase. Total ~140–240 lines across the two phases.

## Testing & Validation

- `lake build` GREEN on the full tree after each phase (Phase 1: def typechecks; Phase 2: theorem
  closes).
- `#print axioms bracketEndChar_k1` and `#print axioms bracketEndChar_k1_correct` both =
  `[propext, Classical.choice, Quot.sound]` (Risk R4 gate).
- `grep -rn "sorry" Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge.lean` unchanged
  (0 in this file); repo live-sorry count stays 2 (`KampPrior.lean:351/354`).
- Signature grep: carrier codomain is `VecEA2 1` (no `VVecEA2` / `VecEA2 2`), anchors `{x,t}` (Postmortem
  Constraints / G6).

## Artifacts & Outputs

- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge.lean`: one new `import`, one new
  `noncomputable def bracketEndChar_k1`, one new `theorem bracketEndChar_k1_correct`, one R2 = GO
  doc-comment. No existing declaration modified.

## Rollback / Contingency

- Additive-only: reverting the two new declarations + the import restores the pre-311 state exactly.
- If Risk R1 materializes (single `VecEA2 1` genuinely cannot host the interior witness): STOP, do not
  change the carrier codomain, escalate to the orchestrator with the specific zone and the failing
  goal state — this is a G6-SHAPE decision, not an implementer call.
- If a phase times out: mark it [PARTIAL] in the heading; the next `/implement` resumes from the
  incomplete phase (Phase 1 must be GREEN before Phase 2 starts).
