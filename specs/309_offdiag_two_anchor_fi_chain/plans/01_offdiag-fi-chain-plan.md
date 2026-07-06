# Implementation Plan: Off-Diagonal Two-Anchor F_i Chain (task 309)

- **Task**: 309 - offdiag_two_anchor_fi_chain
- **Status**: [IMPLEMENTING]
- **Effort**: ~10-14 hours (6 phases, ~550-900 lines Lean)
- **Dependencies**: None (all consumed assets already landed, sorry-free)
- **Research Inputs**: reports/01_offdiag-fi-chain-research.md (H4-verified, Tier 1)
- **Artifacts**: plans/01_offdiag-fi-chain-plan.md
- **Standards**:
  - .claude/rules/artifact-formats.md
  - .claude/rules/state-management.md
  - .claude/context/formats/plan-format.md
- **Type**: lean4 (hard-mode; H8 phase sizing, postmortem constraints, wave declarations)

## Overview

Build the off-diagonal (`x ≠ t`) two-anchor navigated characteristic — the Rabinovich Cor 5.4
non-trivial-segment `F_i` chain — so `KampPrior.lean:350` can be rewired to
`A_past ∨ A_diag ∨ A_future`, dropping the live-path sorry at `:350` (live sorries 2 → 1; `:353`
stays, per task 305 scope). Definition of done: `lake build` GREEN (full tree), `#print axioms`
on the rewired live-path theorem shows exactly `[propext, Classical.choice, Quot.sound]`
(0 domain axioms), all new material sorry-free, task 307 Phase 7 unblocked.

The load-bearing new object is `nf_char2_past_formula` / `nf_char2_future_formula`
(`NormalForm sig (k+1) 2 → Formula`) proving
`temporal_truth M atomMap t (nf_char2_past_formula … sub_nf) ↔ ∃ x, x < t ∧ nf_eval_nf M (k+1) 2 (Fin.cons x (fun _=>t)) sub_nf`.
The research report's single ~300-500-line "deliverable 2" phase exceeds the H8 per-dispatch
ceiling, so it is split here into three bounded phases (off-diagonal atom layer, arity-3 endpoint
hooks, past-arm assembly) plus a future-dual phase — each one verifiable in isolation.

### Research Integration

reports/01_offdiag-fi-chain-research.md integrated in plan version 1 (2026-07-06). All consumed
assets below carry file:line citations verified in that report's Adversarial Self-Verification
section. Divergences D1-D4 are addressed per-phase (see Postmortem Constraints and phase text).

### Preserved Assets

The following work is complete, sorry-free, and MUST NOT regress. Implementation dispatches
consume these; they do not rebuild or edit them (except the two `A_past`/`A_future` defs, which
Phase 1 revises).

| Component | File:line | Status | Role |
|-----------|-----------|--------|------|
| `nf_zone_exists_trichotomy_k1` | NfZoneFlattenNavigable:188 | Landed (task 307 P3) | `∃x` split into past/diag/future |
| `A_diag` / `_correct` | NfMultiAnchorBridge:614 / :631 | Landed (task 307 P2) | diagonal `[t,t]` arm |
| `nf_char2_formula` / `_correct` | NfMultiAnchorBridge:327 / :345 | Landed (task 308) | diagonal char template |
| `nf_zone_flatten_navigable_brick` / `_correct` | NfMultiAnchorBridge:686 / :560 | Landed (task 308) | 5-zone `∃w` flatten |
| `nf_char2_zone_split5` | NfMultiAnchorBridge:457 | Landed (task 308) | full-env 5-zone split |
| `nf_char2_atom_part` / `_correct` | NfMultiAnchorBridge:253 / :269 | Landed (task 308) | **diagonal-only** atom layer (D3 template, not verbatim consume) |
| `nf_char2_diag_exist_tl` / `_correct` | NfMultiAnchorBridge:190 | Landed (task 307) | diagonal 3-zone converter (D2 hook template) |
| `nf_char3_deeper_split` | NfMultiAnchorBridge:476 | Landed | residual zone discharge one depth down |
| `nf_quant_clause_tl` / `_correct` | NfDepth0Generalized:1745 / :1752 | Landed (commit 69998c02d) | shared-ancestor relocation (breaks cycle) |
| `bracketBuildLeft` / `_correct` | VecEATranslation:273 / :503 | Landed | non-trivial-segment past bracket |
| `bracketBuildRight` / `_correct` | VecEATranslation:50 / :234 | Landed | non-trivial-segment future bracket |
| `nf_nvar_exist_depth0_tl_fn` / `_correct` | NfDepth0Generalized:1615 / :1622 | Landed | depth-0 base, all arities off-diagonal |
| `nf_nvar_exist_all_depths` (k=0 base, k+1 recursion) | KampPrior:211 | Landed except `:350`/`:353` sorries | outer recursion; the rewire target |

### Source-to-Implementation Mapping (H3, Tier 1)

Transcription source: `~/Projects/Literature/sources/rabinovich_2014/Rabinovich_2014_Proof_of_Kamps_Theorem.md`,
Section 5 (Lemma 5.1 md:134-152, Corollary 5.4 md:154-157).

| Literature item (Rabinovich 2014) | Lean target (this plan) | Phase |
|-----------------------------------|-------------------------|-------|
| Cor 5.4 non-trivial `β_i` segment on past arm (md:154-157) | `A_past` segment-carrying + `_correct` | P1 |
| Cor 5.4 future dual (`z0 < z`) segment (md:154-157) | `A_future` segment-carrying + `_correct` | P1 |
| Cor 5.4 endpoint atom characteristic at `x` (off-diagonal, `order 0 1 = true`) | off-diagonal atom layer (new; D3) | P2 |
| Cor 5.4 arity-3 endpoint char at navigated witness | arity-3 endpoint hooks (new; D2) | P3 |
| Cor 5.4 `F_i` chain `F_{i-1} := α_{i-1} ∧ (β_i Until F_i)`, past arm | `nf_char2_past_formula` / `_correct` | P4 |
| Lemma 5.1 interior five-zone flatten (md:134-152) | consumed via `nf_zone_flatten_navigable_brick` inside P4 | P4 |
| Cor 5.4 `F_i` chain, future arm (`t < x`) | `nf_char2_future_formula` / `_correct` | P5 |
| Lemma 5.1 interval split at new point | consumed via `nf_zone_exists_trichotomy_k1` in rewire | P6 |

## Postmortem Constraints

Binding rules for all implementation dispatches. Derived from task 307 Phase 7 blocker audit
(reports/03), task 305 findings, and the H4-verified research report's divergence table.

**Obstruction guards G1-G5 (carry verbatim into every dispatch; task 307 report 03 §4):**
- **G1** — No arity-1 collapse of the off-diagonal. (Refuted: report 02 §1; NfDepth0Generalized:1691-1719.)
- **G2** — No projection-based `VecEA2` / third-free-anchor tower. (Refuted: specs/305 report 40; R2.)
- **G3** — No trivial-top segment on the off-diagonal arms. A closed `pastEnd` under a trivial
  segment is model-independent and cannot re-identify the distinct origin `t`, so the hook is
  unsatisfiable off-diagonal (report 03 §1.2/§2.3). The `(x,t)` coupling MUST ride the non-trivial
  Rabinovich `β_i` segment. **Scoped per D4: applies to `A_past`/`A_future` ONLY — the inner
  brick's trivial-top exterior brackets are sound and MUST stay untouched.**
- **G4** — `w` stays a bracket witness. Env arity never grows past `{w,x,t}=3 → {x,t}=2`; anchor
  set is `{x,t}` (Rabinovich ≤2 cap). `w` is never a third anchor.
- **G5** — Follow Cor 5.4 `F_i` chains step-by-step (`F_n := α_n`, `F_{i-1} := α_{i-1} ∧ (β_i Until F_i)`).
  No `simp`/`omega`/`aesop` shortcut of a chain step (literature-fidelity policy). Cite
  Rabinovich md:154-157 at every chain-construction step.

**Do NOT**:
- Do NOT edit `nf_zone_flatten_navigable` (NfMultiAnchorBridge:540) or `nf_char2_diag_exist_tl`
  (:190) inner-`w` trivial-top brackets — those exterior zones legitimately bottom out via the
  depth-`k` IH and are sound (D4).
- Do NOT consume `nf_char2_atom_part` verbatim for the off-diagonal atom layer — it is
  **diagonal-only**, returning `⊥` whenever any order atom is true, but off-diagonal `[x,t]` has
  `order 0 1 = true` (D3). Use it as a template only; build a new off-diagonal atom characteristic.
- Do NOT treat `exist_tl_fn_k` / `char_k1` as top-level consumable assets — they are **local
  `let`-bindings inside the proof** of `nf_nvar_exist_all_depths`, and they convert depth-`k`
  **arity-2** existentials, not the **arity-3** endpoint characteristics the hooks need (D2). The
  arity-3 hooks are genuine new construction (template: `nf_char2_diag_exist_tl`).
- Do NOT introduce any domain axiom or leave any sorry in new material past the phase that owns it.
- Do NOT reintroduce an import cycle: the ONLY new import edge permitted is
  `import …Kamp.NfMultiAnchorBridge` added to `KampPrior.lean` in Phase 6 (cycle-safe — nothing in
  that subtree imports `KampPrior`; only `PriorExpressiveness` + Boneyard do).

**MUST preserve**:
- All 13 Preserved Assets above (sorry-free, axiom-clean).
- The `:353` live-path sorry stays (out of scope; task 305).
- Existing full-tree build green after the Phase 6 import edge lands.

**Design decisions are SETTLED** (do not re-open without a concrete counterexample):
- The constructive `A` is the Cor 5.4 `F_i` chain (task VERDICT, report 03). Not a projection tower,
  not an arity-1 collapse.
- Deliverables 1-2 stay off the live import path; only the Phase 6 `:350` rewire is live (D1).
- `nf_char2_past_formula` / `nf_char2_future_formula` live in `NfMultiAnchorBridge.lean`,
  hook-parametric like `nf_char2_formula` (report §6).
- `A_past`/`A_future` segment refactor stays in `NfZoneFlattenNavigable.lean` (report §6).

## Goals & Non-Goals

**Goals:**
- Segment-carrying `A_past`/`A_future` + `_correct` through `bracketBuildLeft/Right_correct`.
- `nf_char2_past_formula` / `nf_char2_future_formula` + `_correct` (the off-diagonal F_i chain).
- Rewire `KampPrior.lean:350` to the three-way disjunction, closing the `:350` sorry.
- Full `lake build` green; axioms exactly `[propext, Classical.choice, Quot.sound]`.

**Non-Goals:**
- Closing `:353` (task 305 scope).
- Refactoring the inner brick's trivial-top exterior brackets (D4 — sound as-is).
- Any change to `PriorExpressiveness` / Boneyard consumers beyond what the new import forces.

## Risks & Mitigations

- **Risk**: Phase 4 assembly is the true difficulty concentration (F_i chain glue). **Mitigation**:
  P2 (atom layer) and P3 (endpoint hooks) are landed and independently verified before P4 starts,
  so P4 is pure gluing of already-green sub-pieces.
- **Risk**: The new import edge (P6, D1) moves 307/308 assets onto the live path and could surface
  a latent build error or axiom leak elsewhere. **Mitigation**: P6 runs a full-tree build + a
  `#print axioms` check as its explicit verification criterion; if a leak appears, it is localized
  to the newly-imported subtree, all of which is grep-verified sorry-free.
- **Risk**: Off-diagonal atom layer (D3) subtly wrong (order atom, x-vs-t locus). **Mitigation**:
  P2 lands its own `_correct` lemma proving equivalence to `nf_eval_nf M 0 2 [x,t]`-style atom
  agreement, checked by build before it feeds P4.
- **Risk**: G5 literature-fidelity violated by a tactic shortcut. **Mitigation**: each F_i chain
  step in P4/P5 cites Rabinovich md:154-157; no `simp`/`omega`/`aesop` on a chain step.

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2 | -- |
| 3 | 3 | -- |
| 4 | 4 | 1, 2, 3 |
| 5 | 5 | 4 |
| 6 | 6 | 1, 4, 5 |

Phases 1, 2, 3 are mutually data-independent (P1 in NfZoneFlattenNavigable.lean; P2, P3 in
NfMultiAnchorBridge.lean) and may be dispatched in any order. P2 and P3 share
NfMultiAnchorBridge.lean, so under H7 territory rules they must NOT run concurrently; P1 is
file-disjoint. The orchestrator dispatches exactly one phase per cycle (MAX_CYCLES=13, 2 used),
so all six run sequentially regardless; the wave table records the logical parallel opportunity.

### Phase 1: Segment-carrying A_past / A_future + _correct [COMPLETED]

- **Goal**: Replace the hardcoded `BracketFormula.trivial TemporalPred.top` in `A_past`/`A_future`
  with a caller-supplied non-trivial segment, and re-prove `_correct` directly through
  `bracketBuildLeft_correct` / `bracketBuildRight_correct`. (Rabinovich Cor 5.4 `β_i` segment,
  md:154-157.)
- **File targets**: `Theories/Bimodal/.../Kamp/NfZoneFlattenNavigable.lean` (defs :332, :383;
  `_correct` :342-354, :393-405).
- **Consumed assets**: `bracketBuildLeft` / `bracketBuildLeft_correct` (VecEATranslation:273/:503),
  `bracketBuildRight` / `bracketBuildRight_correct` (VecEATranslation:50/:234), `BracketFormula`.
- **Tasks**:
  - Revise `A_past (seg : BracketFormula 0) (pastEnd : TemporalPred)` := `bracketBuildLeft seg pastEnd`.
  - Revise `A_future (seg : BracketFormula 0) (futureEnd : TemporalPred)` := `bracketBuildRight seg futureEnd`.
  - Re-prove `A_past_correct`: `temporal_truth M t (A_past seg pastEnd) ↔ ∃ z0, z0 < t ∧ pastEnd.eval_at z0 ∧ seg.holds M z0 t` directly via `bracketBuildLeft_correct`.
  - Dual for `A_future_correct` via `bracketBuildRight_correct` (`∃ z1, t < z1 ∧ … ∧ seg.holds M t z1`).
  - G3 scope check: touch ONLY these two defs; leave inner-brick trivial-top brackets (D4).
- **Verification criterion**: `lake build` green for NfZoneFlattenNavigable.lean and dependents;
  0 new sorries; the two `_correct` lemmas typecheck with the segment-carrying RHS.
- **Estimated lines**: 80-120.
- **Guards enforced**: G3 (non-trivial segment), D4 (scope to A_past/A_future only).
- **Commit**: `task 309 phase 1: segment-carrying A_past/A_future`

### Phase 2: Off-diagonal atom layer for [x,t] (new; D3) [COMPLETED]

*(Delivered as a locus PAIR to fit the `A_past`/`A_future` endpoint interface (NfZoneFlattenNavigable:335):
`nf_char2_atom_offdiag_endpoint : TemporalPred` (x-position preds, checked at navigated `x`; the atom
part of `pastEnd`/`futureEnd`) + `nf_char2_atom_offdiag_origin : Formula` (t-position preds at origin +
off-diagonal order guard, ⊥ when order-inconsistent). Combined `nf_char2_atom_offdiag_correct`:
given `x < t`, `(origin at t) ∧ (endpoint at x) ↔ nf_eval_nf M 0 2 [x,t] nf2` — the exact locus
decomposition Phase 4 needs (t-preds + order factor out of `∃x`). Both loci reuse arity-1
`nf_depth0_char_formula` via private `nf2_locus`. Axioms exactly `[propext, Classical.choice,
Quot.sound]`.)*

- **Goal**: Build a NEW off-diagonal atom characteristic for the `[x,t]` endpoint where
  `order 0 1 = true` (`x < t`): `x`-position atom literals navigated to `x`, `t`-position atom
  literals asserted at origin `t`, order fixed by bracket direction. This is NOT
  `nf_char2_atom_part` (diagonal-only, returns `⊥` on true order atoms).
- **File targets**: `Theories/Bimodal/.../Kamp/NfMultiAnchorBridge.lean` (new def + `_correct`,
  placed alongside `nf_char2_atom_part` :253).
- **Consumed assets (as TEMPLATE, not verbatim)**: `nf_char2_atom_part` / `_correct`
  (NfMultiAnchorBridge:253/:269) for the diagonal pattern; atom/order-literal machinery from
  `NormalForm`. `bracketBuildLeft` endpoint plumbing from Phase 1 shape.
- **Tasks**:
  - Define off-diagonal atom characteristic: partition `sub_nf.1` atoms by locus (`x` vs `t`),
    with `order 0 1` satisfied by the strict `x < t` supplied by the bracket, not forced to `⊥`.
  - Prove `_correct`: characteristic at `[x,t]` ↔ the atom layer of `nf_eval_nf M (k+1) 2 [x,t] sub_nf`
    (order atom true, x-atoms at x, t-atoms at t).
  - Cite Rabinovich md:154-157 for the endpoint atom coupling (G5).
- **Verification criterion**: `lake build` green for NfMultiAnchorBridge.lean; 0 new sorries;
  `_correct` typechecks with `order 0 1 = true` handled (not `⊥`).
- **Estimated lines**: 80-150.
- **Guards enforced**: D3 (new atom layer), G5 (step-by-step, no shortcut).
- **Commit**: `task 309 phase 2: off-diagonal atom layer`

### Phase 3: Arity-3 endpoint-hook construction (new; D2) [COMPLETED]

*(Delivered as `nf_char3_endpoint_tl` + `nf_char3_endpoint_tl_correct` (NfMultiAnchorBridge.lean,
before the closing `end`, commit pending): the arity-3, `TemporalPred`-valued analog of the arity-1
template `nf_succ_char_formula` and the arity-2 `nf_char2_formula`, one arity up. Builds the endpoint
characteristic `NormalForm sig (k+1) 3 → TemporalPred` that Phase 4's `nf_char2_past_formula` plugs
into `nf_zone_flatten_navigable`'s `pastEnd`/`futureEnd`. Hook-parametric over `atomPart` (arity-3
atom layer at the anchors) and `innerConv` (depth-`k`, arity-4 coupled inner converter = the IH);
`_correct` takes their correctness as hypotheses (`h_atom`/`h_inner`) and proves `.eval_at y ↔
nf_eval_nf M (k+1) 3 (zoneEnv3 y x t) q` by matching `nf_eval_nf`'s `k+1` unfolding
(`formula_conjList_iff` + `nf_quant_clause_tl_correct` per clause), mirroring
`nf_char2_formula_correct`. Build GREEN; axioms exactly `[propext, Classical.choice, Quot.sound]`.
G4 preserved: `y` and inner `w` stay bracket witnesses, anchor set `{x,t}`.)*

- **Goal**: Build the arity-3 characteristic endpoint hooks
  (`NormalForm sig k 3 → TemporalPred`) that `nf_char2_past_formula` needs at navigated witnesses,
  from the depth-`k` machinery. `exist_tl_fn_k` is a local `let` (arity-2 only) and does NOT
  supply these — this is genuine construction, templated on `nf_char2_diag_exist_tl`.
- **File targets**: `Theories/Bimodal/.../Kamp/NfMultiAnchorBridge.lean` (new hook defs +
  correctness, alongside `nf_char2_diag_exist_tl` :190).
- **Consumed assets**: `nf_char2_diag_exist_tl` / `_correct` (NfMultiAnchorBridge:190/:227) as the
  hook template; `nf_char3_deeper_split` (:476) for one-depth-down discharge; the depth-`k` IH
  contract (mirrors what `nf_char2_diag_exist_tl` uses in the diagonal case).
- **Tasks**:
  - Define arity-3 endpoint char hooks (past-exterior `w<x`, point `w=x`, and the pieces the
    F_i chain endpoint at `x` requires) as `TemporalPred`s parametric on a depth-`k` converter.
  - Prove their `.eval_at`-correctness one depth down via `nf_char3_deeper_split` (route (c);
    `zoneEnv3_arity_invariant`).
  - G4 check: `w` remains a bracket witness; anchor set `{x,t}`, arity capped at 2.
- **Verification criterion**: `lake build` green; 0 new sorries; each hook's correctness lemma
  typechecks against `nf_eval_nf M k 3 (zoneEnv3 · x t) qnf`.
- **Estimated lines**: 100-180.
- **Guards enforced**: G4 (`w` bracket witness, ≤2 anchors), D2 (arity-3 hooks are new work).
- **Commit**: `task 309 phase 3: arity-3 endpoint hooks`

### Phase 4: nf_char2_past_formula + _correct (F_i chain past arm) [COMPLETED]

*(Delivered as `nf_char2_past_formula` + `nf_char2_past_formula_correct` (NfMultiAnchorBridge.lean,
after `nf_char3_endpoint_tl_correct`). Definition: `Formula.and (nf_char2_atom_offdiag_origin …
sub_nf.1) (A_past seg (TemporalPred.conj (nf_char2_atom_offdiag_endpoint … sub_nf.1) quantEnd))` —
the Phase-2 origin atom locus (checked at `t`, factors out of `∃ x`) conjoined with the Phase-1
`A_past` outer `bracketBuildLeft` navigation over the caller's non-trivial segment `seg`, endpoint =
Phase-2 endpoint atom locus ∧ the quant-endpoint hook `quantEnd`. `_correct` proves
`temporal_truth M atomMap t (nf_char2_past_formula … sub_nf) ↔ ∃ x, x < t ∧ nf_eval_nf M (k+1) 2
(Fin.cons x (fun _=>t)) sub_nf` under the depth-`k` IH `h_quant` (the `(x,t)` quant-layer coupling,
routed through `nf_zone_flatten_navigable_brick` + Phase-3 hooks at the caller, exactly as
`nf_char2_formula_correct` defers `h_exist_correct`). Assembly: `temporal_truth_and` (origin split) +
`A_past_correct` (Phase 1) + `nf_char2_atom_offdiag_correct` (Phase 2) + the definitional
depth-`(k+1)` `nf_eval_nf` unfolding (`Iff.rfl`; `zoneEnv3 w x t = Fin.cons w (Fin.cons x (fun _=>t))`)
+ explicit manual propositional glue (no `simp`/`omega`/`aesop` on the chain step, G5). Build GREEN;
`#print axioms` = exactly `[propext, Classical.choice, Quot.sound]`; 0 new sorries. G1-G5 preserved:
`x`/`w` bracket witnesses, anchor set `{x,t}`, `seg` a non-trivial parameter (not trivial-top).)*

- **Goal**: Assemble the load-bearing `nf_char2_past_formula (…hooks…) (sub_nf : NormalForm sig (k+1) 2) : Formula`
  and prove `temporal_truth M atomMap t (nf_char2_past_formula … sub_nf) ↔ ∃ x, x < t ∧ nf_eval_nf M (k+1) 2 (Fin.cons x (fun _=>t)) sub_nf`.
  Outer non-trivial-segment `bracketBuildLeft seg pastEnd` (Phase 1); endpoint atom layer (Phase 2);
  per-`qnf` inner `∃w` flattened via `nf_zone_flatten_navigable_brick`; residual arity-3 zones
  (`w=x`, `x<w<t`, `w=t`) discharged by depth-`k` IH through Phase 3 hooks. Rabinovich Cor 5.4
  `F_i` chain (md:154-157): `F_n := α_n`, `F_{i-1} := α_{i-1} ∧ (β_i Until F_i)`.
- **File targets**: `Theories/Bimodal/.../Kamp/NfMultiAnchorBridge.lean` (new def + `_correct`,
  hook-parametric, alongside `nf_char2_formula` :327).
- **Consumed assets**: Phase 1 `A_past`/`bracketBuildLeft_correct`; Phase 2 off-diagonal atom layer;
  Phase 3 arity-3 endpoint hooks; `nf_zone_flatten_navigable_brick` / `_correct`
  (NfMultiAnchorBridge:686/:560); `nf_char2_zone_split5` (:457); `nf_char3_deeper_split` (:476);
  the `nf_char3_eq_succ_iff`-style quant-layer decomposition (mirroring `nf_char2_formula`).
- **Tasks**:
  - Define `nf_char2_past_formula` with implicit `{sig} {k}`, explicit `atomMap h_surj hooks sub_nf`
    (mirror `nf_char2_formula` conventions exactly).
  - Decompose the `[x,t]` characteristic at the quant layer into (at-`x` / along-`(x,t)` / at-and-future-`t`)
    loci per report §4.
  - Flatten each inner `∃w` per `qnf` into its 5 zones; route the two open exterior zones to
    Phase 3 navigated endpoints (IH one depth down), keep the three residual zones honest arity-3.
  - Prove `_correct` with explicit hook-correctness hypotheses (`h_past`/… each
    `∀ (qnf) (w), … eval_at w ↔ nf_eval_nf M k 3 …`), mirroring `nf_char2_formula_correct` (:345-359).
  - G5: build each `F_i` step-by-step citing md:154-157; no `simp`/`omega`/`aesop` on a chain step.
- **Verification criterion**: `lake build` green; 0 new sorries; `nf_char2_past_formula_correct`
  typechecks with the exact `∃ x, x < t ∧ nf_eval_nf M (k+1) 2 (Fin.cons x (fun _=>t)) sub_nf` RHS.
- **Estimated lines**: 150-250.
- **Guards enforced**: G1 (no arity-1 collapse), G2 (no projection tower), G4 (`w` witness), G5 (step-by-step).
- **Commit**: `task 309 phase 4: nf_char2_past_formula F_i chain`

### Phase 5: nf_char2_future_formula + _correct (F_i chain future dual) [COMPLETED]

*(Delivered in NfMultiAnchorBridge.lean adjacent to Phase 4: `nf_char2_future_formula` +
`nf_char2_future_formula_correct`, the exact structural dual of Phase 4. Assembly =
`A_future`/`bracketBuildRight` outer navigation (Phase 1) + a future-dual off-diagonal atom layer
(`nf_char2_atom_offdiag_origin_future` + `nf_char2_atom_offdiag_correct_future`, the "order direction
flipped" Phase-2 dual: the antitone env `Fin.cons x (fun _=>t)` with `t < x` gives `env i < env j ↔
(j:Fin 2) < i`, so the origin order guard flips to `↔ (j:Fin 2) < i`; the endpoint `x`-preds locus is
direction-independent and reused verbatim) + `temporal_truth_and` + definitional depth-`(k+1)`
`nf_eval_nf` unfold (`Iff.rfl`) + manual propositional glue. Target proven: `temporal_truth M atomMap t
(nf_char2_future_formula … sub_nf) ↔ ∃ x, t < x ∧ nf_eval_nf M (k+1) 2 (Fin.cons x (fun _=>t)) sub_nf`
under the dual quant-hook `h_quant` (`seg.holds M atomMap t x`, `t < x`). Build GREEN; `#print axioms`
= exactly `[propext, Classical.choice, Quot.sound]`; 0 new sorries. G3-G5 preserved: `seg` a
non-trivial parameter, `x`/`w` bracket witnesses, anchor set `{x,t}`, no simp/omega/aesop on the chain
step.)*

- **Goal**: Build the future dual `nf_char2_future_formula` + `_correct` with RHS
  `∃ x, t < x ∧ nf_eval_nf M (k+1) 2 (Fin.cons x (fun _=>t)) sub_nf`, using `bracketBuildRight`
  (Phase 1 `A_future`) and the mirror of Phase 4. Rabinovich Cor 5.4 future arm (md:154-157).
- **File targets**: `Theories/Bimodal/.../Kamp/NfMultiAnchorBridge.lean` (new def + `_correct`,
  adjacent to Phase 4).
- **Consumed assets**: Phase 4 `nf_char2_past_formula` as the structural template; Phase 1
  `A_future`/`bracketBuildRight_correct`; Phase 2 atom layer (order direction flipped); Phase 3
  endpoint hooks (future-exterior `t<w` zone); `nf_zone_flatten_navigable_brick`.
- **Tasks**:
  - Mirror Phase 4 with `bracketBuildRight seg futureEnd` and `t < x` ordering.
  - Prove `_correct` dual, reusing Phase 4 lemma structure where the mirror is exact.
  - G5: cite md:154-157 for the future `F_i` chain; no tactic shortcut of a chain step.
- **Verification criterion**: `lake build` green; 0 new sorries; `nf_char2_future_formula_correct`
  typechecks with the `t < x` RHS.
- **Estimated lines**: 100-150.
- **Guards enforced**: G3 (non-trivial segment), G4, G5.
- **Commit**: `task 309 phase 5: nf_char2_future_formula dual`

### Phase 6: Rewire KampPrior.lean:350 + import edge + axiom check [BLOCKED]

**BLOCKER** (Phase 6, dispatch sess_1783359214_93fd70):

- **Sub-task DONE (committed, green)**: The cycle-safe import edge
  `import …Kamp.NfMultiAnchorBridge` was added to `KampPrior.lean` (commit `task 309 phase 6.1`).
  D1 verified: full-tree `lake build` GREEN (1704 jobs), no downstream regression; Phases 1-5
  material grep-confirmed sorry-free. Live-path sorries UNCHANGED at 2 (`:351`/`:354` after the
  +1 import-line shift, formerly `:350`/`:353`).
- **What is blocked**: The `:351` rewire (`n = 1` arm), i.e. closing the live-path sorry that
  reduces 2 → 1. Cannot be completed as the planned "pure glue".
- **What failed / root cause**: The Phase 4/5/diag correctness lemmas are all **hook-parametric**
  and DEFER the coupling to hook-correctness hypotheses that this phase must discharge:
  - `nf_char2_past_formula_correct` requires `h_quant : ∀ x < t, (quantEnd.eval_at x ∧
    seg.holds M atomMap x t) ↔ (∀ qnf, (∃ w, nf_eval_nf M k 3 (zoneEnv3 w x t) qnf) ↔ sub_nf.2 qnf)`.
  - `nf_char2_future_formula_correct` requires the dual `h_quant`.
  - `A_diag_correct` requires `h_past`/`h_fut`/`h_diag` over `NormalForm sig k 3 → TemporalPred/Formula`.
  Discharging any of these requires **constructing** the hook terms (`quantEnd`, non-trivial `seg`,
  `pastEnd`/`futureEnd`/`diagChar`) — genuine TWO-ANCHOR navigated characteristics at depth `k`
  (e.g. `nf_eval_nf M k 3 [w,x,t] q` at a navigated witness; the diag arm's `h_past` is itself
  off-diagonal `[w,t,t]`, `w < t`). These:
  - cannot use arity-1 collapse (G1 / route (c) guard) — the anchors are distinct;
  - cannot ride `nf_zone_flatten_navigable`'s trivial-top exterior brackets to carry the `(x,t)`
    coupling (G3: a closed endpoint under a trivial segment is model-independent and cannot
    re-identify the distinct origin `t` off-diagonal — the settled-design claim that the `h_quant`
    hooks are "discharged via nf_zone_flatten_navigable_brick" collides with this guard);
  - require the non-trivial Rabinovich `β_i` segment plus a navigated arity-3 endpoint
    characteristic that RE-FINDS the second anchor.
  No existing builder supplies these hooks. `nf_char3_endpoint_tl` is only hook-parametric (needs
  `atomPart` + `innerConv : NormalForm sig k 4 → Formula`, which recurse into the same two-anchor
  problem). The arity-1 characteristic (`nf_succ_char_formula`/`char_k1`) works ONLY because at
  arity 1 the single anchor is always `t` (no distinct second anchor to navigate to).
- **Why stuck**: This is the endpoint-hook crux that blocked task 307 Phase 7 ("endpoint-hook
  crux blocked", commit b28807116). Phases 1-5 landed all hook-PARAMETRIC scaffolding sorry-free,
  but the hook DISCHARGE — the actual off-diagonal two-anchor characteristic construction — was
  deferred to this phase and remains unbuilt. The plan estimated Phase 6 at 40-80 lines of "pure
  glue"; it is in fact the central research-grade construction of the task. The disjunction
  skeleton `A := nf_char2_past_formula … ∨ A_diag … ∨ nf_char2_future_formula …` cannot even be
  written down without committing to these unsolved hook terms.
- **What is needed**: A dedicated construction (new task) building the depth-`k` two-anchor
  navigated arity-3 endpoint characteristics (`pastEnd`/`futureEnd`/`diagChar` for the diag arm
  and `quantEnd`+non-trivial `seg` for the past/future arms) with their correctness discharged
  through `nf_char3_endpoint_tl` + a navigated segment that re-identifies the second anchor
  (Rabinovich Cor 5.4 `F_i` chain, md:154-157), obeying G1-G5.
- **Prohibited**: Do NOT use `sorry`, `def X := True`, or a vacuous placeholder to fake closure;
  do NOT relocate the `:351` sorry into an unproven disjunction skeleton on the live path.

- **Goal**: Add `import …Kamp.NfMultiAnchorBridge` to `KampPrior.lean` (cycle-safe, D1), rewire the
  `:350` arm to `A := nf_char2_past_formula … ∨ A_diag … ∨ nf_char2_future_formula …`, prove it via
  the `Fin 1 → ∃x` bridge + `rw [nf_zone_exists_trichotomy_k1]` + three-way `or_congr` discharged by
  `nf_char2_past_formula_correct` / `A_diag_correct` / `nf_char2_future_formula_correct`. Close the
  `:350` sorry. Verify full-tree green + axioms.
- **File targets**: `Theories/Bimodal/.../Prior/KampPrior.lean` (import list :1-6; `:350` arm).
- **Consumed assets**: Phases 1/4/5 outputs; `A_diag` / `_correct` (NfMultiAnchorBridge:614/:631);
  `nf_zone_exists_trichotomy_k1` (NfZoneFlattenNavigable:188); local `ih_exist_1` / `exist_tl_fn_k`
  / `char_k1` (KampPrior:264-320) to supply the recursion hooks at the call site.
- **Tasks**:
  - Add the single new import edge; confirm cycle-safe (only PriorExpressiveness + Boneyard import KampPrior).
  - Wire KampPrior's local hooks into the three `_correct` lemmas.
  - Bridge `∃ env : Fin 1` → `∃ x` (`h_env_eq` shape, :276-290), `rw [nf_zone_exists_trichotomy_k1]`,
    discharge the three arms; close the `:350` sorry.
  - Run full `lake build`; run `#print axioms` / `lean_verify` on the rewired live-path theorem.
- **Verification criterion**: full-tree `lake build` GREEN; `#print axioms` on the rewired theorem
  = exactly `[propext, Classical.choice, Quot.sound]` (0 domain axioms); live-path sorry count
  2 → 1 (`:350` closed, `:353` remains); ALL new material (Phases 1-5) grep-confirmed sorry-free.
- **Estimated lines**: 40-80.
- **Guards enforced**: D1 (cycle-safe import edge), final sorry + axiom discipline.
- **Commit**: `task 309 phase 6: rewire KampPrior:350 + axiom check`

## Testing & Validation

- After each phase: `lake build` for the touched file and its dependents; grep for new `sorry`.
- Phase 6 gate (definition of done):
  - Full-tree `lake build` GREEN.
  - `#print axioms` (or `lean_verify`) on the rewired `nf_nvar_exist_all_depths` live-path theorem:
    exactly `[propext, Classical.choice, Quot.sound]`, 0 domain axioms.
  - Live-path sorry count reduced 2 → 1 (`:350` closed; `:353` deliberately remains).
  - `grep "sorry"` across NfZoneFlattenNavigable.lean + NfMultiAnchorBridge.lean new material:
    only docstring/comment hits (no code sorries).
- Regression: task 307 Phase 7 wiring verification is unblocked (report the unblock, do not execute it here).

## Artifacts & Outputs

- `Theories/Bimodal/.../Kamp/NfZoneFlattenNavigable.lean` — revised `A_past`/`A_future` + `_correct` (P1).
- `Theories/Bimodal/.../Kamp/NfMultiAnchorBridge.lean` — off-diagonal atom layer (P2), arity-3
  endpoint hooks (P3), `nf_char2_past_formula`/`_correct` (P4), `nf_char2_future_formula`/`_correct` (P5).
- `Theories/Bimodal/.../Prior/KampPrior.lean` — new import edge + rewired `:350` arm (P6).
- Six scoped commits (`task 309 phase N: …`).

## Rollback/Contingency

- Each phase is a scoped commit; revert the last commit to roll back a single phase without
  disturbing earlier green milestones (H9 incremental-commit discipline).
- P1-P5 are off the live import path (D1): if P6's import edge surfaces an unexpected build or
  axiom problem, P1-P5 remain green and the rollback is limited to the KampPrior import + rewire
  commit; `:350` reverts to its prior sorry with no downstream regression.
- If Phase 4 assembly overruns the H8 dispatch budget, split at the atom-layer / quant-layer /
  bracket-glue seam into P4a/P4b (each already an independently landed sub-piece from P2/P3),
  rather than inflating a single dispatch.
