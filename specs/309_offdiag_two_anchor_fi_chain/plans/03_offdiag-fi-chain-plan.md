# Implementation Plan: Off-Diagonal Two-Anchor F_i Chain (task 309) — v3

- **Task**: 309 - offdiag_two_anchor_fi_chain
- **Status**: [IN PROGRESS]
- **Effort**: ~8-14 hours (Phases 1-5 + 6.1 landed; plan-v2 Phases 6-8 abandoned-route; 4 open phases R1-R4, ~280-500 lines Lean)
- **Dependencies**: None (all consumed assets already landed, sorry-free)
- **Research Inputs**:
  - reports/01_offdiag-fi-chain-research.md (H4-verified, Tier 1; source for the outer wrapper + import DAG)
  - reports/02_endpoint-hook-discharge-research.md (background only — its "build the collapse brick / endChar" recommendation is SUPERSEDED and adversarially OVERTURNED by report 03)
  - reports/03_rabinovich-faithful-path-research.md (**REVISION AUTHORITY** — full-PDF Rabinovich 2014 read; Path B carrier reformulation; R1-R4 decomposition)
- **Artifacts**:
  - plans/01_offdiag-fi-chain-plan.md (v1, superseded)
  - plans/02_offdiag-fi-chain-plan.md (v2, superseded — endChar/seg route now [ABANDONED ROUTE])
  - plans/03_offdiag-fi-chain-plan.md (this file)
- **Standards**:
  - .claude/rules/artifact-formats.md
  - .claude/rules/state-management.md
  - .claude/rules/plan-format-enforcement.md
  - .claude/context/formats/plan-format.md
- **Type**: lean4 (hard-mode; H8 phase sizing, postmortem constraints, wave declarations)
- **reports_integrated**: 01_offdiag-fi-chain-research.md, 02_endpoint-hook-discharge-research.md, 03_rabinovich-faithful-path-research.md

## Overview

Build the off-diagonal (`x ≠ t`) two-anchor navigated characteristic — the Rabinovich Prop 3.5 /
Cor 5.4 `F_i` chain — so `KampPrior.lean:351` can be discharged (live sorries 2 → 1; `:354` stays,
task 305 scope). Definition of done: full `lake build` GREEN, `#print axioms` on the rewired
live-path theorem `nf_nvar_exist_all_depths` = exactly `[propext, Classical.choice, Quot.sound]`
(0 domain axioms), all new material sorry-free, task 307 Phase 7 unblocked.

**Why v3.** Plan v2 (Phases 6-8) attempted to build a **navigated arity-3 endpoint characteristic**
`endChar : NormalForm sig k 3 → TemporalPred` (recursion on `k`), and Phase 8 went **[BLOCKED]** on a
structural arity-4 → arity-3 re-bounding obstruction (`nf_eval_nf M (k+1) 3`'s quant layer produces
arity-4 subs; an arity-3 carrier cannot consume them). A subsequent full-PDF literature research pass
(report 03, the revision authority) read Rabinovich 2014 directly and established that **this blocker
is an artifact of the `endChar` carrier choice with no counterpart in Rabinovich's proof**:

- Rabinovich never forms a navigated arity-3 point characteristic and never grows arity with depth. He
  keeps the free-variable count ≤ 2 by construction (Lemma 3.2(2), PDF p.4) via quantifier-free
  `α_j/β_j` (Def 3.1), the E[Σ] monadic-atom fold (Def 4.1, PDF p.5), and existential witnesses realized
  as **Until/Since bracket witnesses** evaluated with endpoint types pinned at the **fixed** points
  `z_0, z_1` — never at an interior existential witness (Prop 3.5, PDF p.5).
- The codebase itself already proved the `endChar` carrier representationally FALSE in free-anchor form
  (`endChar0_correct` deviation note, NfMultiAnchorBridge:1058-1069): a closed navigated-`w`
  `TemporalPred` cannot read the anchor positions `a, b`. That falseness IS the ≤2-cap violation
  surfacing.
- Report 03's Adversarial Self-Verification section **explicitly overturned report 02's "build the
  collapse brick" recommendation**. Do NOT resurrect it.

**The v3 pivot (report 03 Path B, ENDORSED).** Reformulate the recursion carrier from the (false)
arity-1 navigated point characteristic to a **two-anchor VecEA2 bracket characteristic** (fixed
endpoints per Prop 3.5), and build the depth-`k` generalization of the **already-sorry-free depth-0
witness collapse** `nf_3var_bracket_xyt` (VecEADecomp:233), feeding the sorry-free depth-`k` arity-1
point characteristic `char_k1` (KampPrior:307) as the bracket interval type (the E[Σ]-atom of Def 4.1).
This dissolves the arity-4 layer at the representation level rather than re-bounding it with a
~300-500-line brick that fights the encoding. The plan-v2 endChar/seg route is the churn root and is
recorded below as an **abandoned route** (code retained, off the live path).

### Research Integration

reports/03_rabinovich-faithful-path-research.md integrated in plan version 3 (2026-07-06). This report
is the AUTHORITY for the revision. Its decisive findings drive v3:

1. **The Phase-8 blocker is not a paper object** (report 03 §2, H3 mapping table): the navigated
   arity-3 `endChar` carrier and its arity-4 quant layer have **no counterpart in Rabinovich's proof**;
   the arity growth is an artifact of the `nf_eval_nf` encoding, not of the mathematics. Path A (build
   the collapse brick) is REFUTED as the primary route.
2. **The faithful carrier is a two-anchor bracket** (report 03 §3 Path B, ENDORSED): the interior
   existential collapses to an Until/Since bracket witness; the two anchors `{x,t}` are the **fixed**
   bracket endpoints (matching PDF p.5's "endpoint types at `z_0,z_1`", never an interior witness); the
   interval type is a `TemporalPred` = E[Σ]-atom (Def 4.1) supplied by the sorry-free depth-`k` point
   characteristic `char_k1`. Free-variable count is **structurally** ≤ 2.
3. **The depth-0 collapse already exists sorry-free**: `nf_3var_bracket_xyt_correct` (VecEADecomp:244)
   proves `(nf_3var_bracket_xyt … ssn).holds M atomMap x t ↔ ∃ y, nf_eval_nf M 0 3 (Fin.cons y (Fin.cons
   x (fun _=>t))) ssn`. The missing work is its **depth-`k` generalization**, threading `char_k1` as the
   endpoint/interval types instead of depth-0 `nfPred`.
4. **The `k=1` case is the decision gate** (report 03 §3 OPEN RISK + §4 Phase R2): the single experiment
   that decides Path B viability. If `k=1` closes without an arity-4 residual or a navigated arity-3
   char, the recursion closes; if it silently needs a navigated arity-3 char, Path B degrades and a
   `/spawn` encoding-level task is required. This is falsifiable in ~100 lines instead of ~500.

reports/01 remains the source for the outer wrapper (Phases 1-5) and the import DAG (Phase 6.1). Its
divergences D1-D4 are preserved. reports/02 is retained for background only; its recommendation is
superseded per the Contradiction Log of report 03 (report 02 correctly found "all four hooks reduce to
one object" but **mis-scoped that object** as an arity-1 navigated characteristic).

### Corrected Anchor-Cap Statement (CARRIED FORWARD from v2; still binding)

**The hook-discharge path MUST keep the anchor set at `{x,t}` (≤2, Rabinovich cap; G2/G4) by the
bracket-witness-collapse mechanism (report 03 §3 Path B), NOT by `nf_char3_deeper_split`.**
`nf_char3_deeper_split` (NfMultiAnchorBridge:625-642) grows arity 3→4 and anchors `{x,t}→{y,x,t}` (its
statement, :628-637); composing it at each depth-descent builds the forbidden anchor tower. The v1
route-audit comments at NfMultiAnchorBridge:661,:676-678 ("arity ≤3, anchor `{x,t}`") are false and MUST
NOT be trusted. Interior witnesses stay **bracket** witnesses; recursion is on `k`, anchors strictly
`{x,t}`.

## Preserved / Live Assets (consume — do NOT rebuild)

Complete, sorry-free, MUST NOT regress. Every open phase (R1-R4) consumes from this list and does not
rebuild or edit these.

| Component | File:line | Status | Role in v3 |
|-----------|-----------|--------|------------|
| `A_past` / `A_future` (segment-carrying) + `_correct` | NfZoneFlattenNavigable:335/:386 | Landed P1 (f4b9600a1) | non-trivial-segment outer arms (retained; consumed in R4 or_congr) |
| `nf_char2_atom_offdiag_{origin,endpoint,correct}` | NfMultiAnchorBridge:364/:375/:391 | Landed P2 (762ea60da) | off-diagonal atom layer (`order 0 1 = true`); depth-0 atom decomposition in R4 |
| `nf_char3_endpoint_tl` / `_correct` | NfMultiAnchorBridge:891/:907 | Landed P3 (010ab616d) | arity-3 endpoint `TemporalPred` shape (hook-parametric; NOT the v3 carrier) |
| `nf_char2_past_formula` / `_correct` | NfMultiAnchorBridge:992/:1015 | Landed P4 (fed9fcd8e) | past-arm F_i wrapper; `h_quant` (:1023-1026) discharged in R4 via the v3 carrier |
| `nf_char2_future_formula` / `_correct` | NfMultiAnchorBridge:1185/… | Landed P5 (b60c63b1a) | future-arm F_i wrapper; dual `h_quant` (:1223-1226) discharged in R4 |
| `A_diag` / `_correct` | NfMultiAnchorBridge:763/:808 | Landed (task 307 P2) | diagonal `[t,t]` arm; `h_past`/`h_fut`/`h_diag` (:787-795) discharged in R4 |
| `nf_zone_flatten_navigable(_brick)` / `_correct` | NfMultiAnchorBridge:689/:709 | Landed (task 308) | 5-zone `∃w` flatten |
| `nf_zone_exists_trichotomy_k1` | NfZoneFlattenNavigable:188 | Landed (task 307 P3) | `∃x` split into past/diag/future — the R4 three-way `or_congr` seam |
| **`nf_3var_bracket_xyt` / `_correct`** | **VecEADecomp:233/:244** | **Landed, sorry-free** | **the depth-0 witness collapse — the R3 recursion base (Prop 3.5, PDF p.5)** |
| **`char_k1` / `_correct`** | **KampPrior:307/:310** | **Landed, sorry-free** | **the depth-`k` arity-1 point characteristic = E[Σ]-atom (Def 4.1); the R3 endpoint/interval type** |
| `bracketBuildLeft` / `_correct` | VecEATranslation:273/:503 | Landed | non-trivial-segment past bracket (Prop 3.5 chain builder) |
| `bracketBuildRight` / `_correct` | VecEATranslation:50/:234 | Landed | non-trivial-segment future bracket (Prop 3.5 chain builder) |
| `BracketFormula.existsBounded_right`, `VecEAClosure` | VecEAClosure:265/:371 | Landed | Lemma 3.4 bounded ∃-closure vehicle (R4) |
| `nf_nvar_exist_all_depths` (`char_k1` local, `n=0` arm) | KampPrior:211/:307/:339 | Landed except `:351`/`:354` sorries | outer recursion; the rewire target; `n=0` arm sorry-free |
| Import edge `…Kamp.NfMultiAnchorBridge` in KampPrior | KampPrior imports | Landed P6.1 (f3827e255) | cycle-safe; full-tree GREEN. Do NOT re-add/move (D1). |

### Source-to-Implementation Mapping (H3, Tier 1 — report 03 §2)

Transcription source: `~/Projects/Literature/sources/rabinovich_2014/Rabinovich_2014_Proof_of_Kamps_Theorem.pdf`
(full 12-content-page PDF read in report 03; page:§ citations are to the PDF text).

| Paper item (Rabinovich 2014) | Paper loc | Lean target | Phase |
|------------------------------|-----------|-------------|-------|
| Def 3.1: `α_j/β_j` quantifier-free, one-variable | PDF p.4 | (fidelity ground; carrier type honors ≤2 cap) | R1 |
| Lemma 3.2(2): ≤ 2 free variables | PDF p.4 | two-anchor bracket carrier type (the invariant) | R1 |
| Prop 3.5: `∃x_i` → Until/Since bracket witness (depth 0) | PDF p.5 | `nf_3var_bracket_xyt` / `_correct` (VecEADecomp:233/:244) | R3 base (landed) |
| Def 4.1: E[Σ] atom = TL-formula as monadic predicate (depth-`k` fold) | PDF p.5 | `char_k1` / `_correct` (KampPrior:307/:310) | R3 endpoint/interval type (landed) |
| Prop 3.5 chain builders `… Until (A_i ∧ …)` / `… Since …` | PDF p.5 | `bracketBuildLeft/Right` / `_correct` | R3 step / R4 assembly |
| Lemma 3.4: ∨∃∀ closed under bounded `∃x` | PDF p.5 | `existsBounded_right` (VecEAClosure:265) | R4 |
| Cor 5.4 `F_{i-1} := α_{i-1} ∧ (β_i Until F_i)` past/future arms | PDF p.9 | `A_past`/`A_future`/`_correct` (segment-carrying) | R4 or_congr (P1 landed) |
| **Navigated arity-3 endpoint char (endChar route)** | **no paper counterpart** | `endChar`/`seg` | **ABANDONED ROUTE (v2 P6-P8)** |

The two "no paper counterpart" objects (`endChar`, its arity-4 quant layer) are the churn root. v3 does
NOT build on them.

## Postmortem Constraints

Binding rules for all implementation dispatches. Guards G1-G5 are carried **verbatim** from v2; G6 is
**new** (report 03).

**Obstruction guards (carry verbatim into every dispatch):**
- **G1** — No arity-1 collapse of the off-diagonal. (Refuted: report 02 §1; NfDepth0Generalized:1691-1719.)
- **G2** — No projection-based `VecEA2` / third-free-anchor tower. (Refuted: specs/305 report 40; R2.)
- **G3** — No trivial-top segment on the off-diagonal arms. A closed `pastEnd` under a trivial segment
  is model-independent and cannot re-identify the distinct origin `t`, so the hook is unsatisfiable
  off-diagonal. The `(x,t)` coupling MUST ride the non-trivial Rabinovich `β_i` segment (in v3: a real
  `char_k1` interval type, not `⊤`). **Scoped per D4: applies to `A_past`/`A_future` and the R3 interval
  type ONLY — the inner brick's trivial-top exterior brackets are sound and MUST stay untouched.**
- **G4** — `w` stays a **bracket witness**. Env arity never grows past `{w,x,t}=3 → {x,t}=2`; anchor set
  is `{x,t}` (Rabinovich ≤2 cap). `w` is never a third anchor.
- **G5** — Follow Cor 5.4 / Prop 3.5 `F_i` chains step-by-step (`F_n := α_n`, `F_{i-1} := α_{i-1} ∧
  (β_i Until F_i)`). No `simp`/`omega`/`aesop` shortcut of a chain step (literature-fidelity policy).
  Cite Rabinovich PDF p.4-5 (Def 3.1 / Lemma 3.2(2) / Prop 3.5 / Def 4.1) at every chain step.
- **G6 (NEW — report 03; the v3 carrier guard)** — The recursion carrier MUST be the **two-anchor
  bracket characteristic** with **fixed endpoints** `z_0, z_1` (Prop 3.5, PDF p.5): a
  `NormalForm sig k 3 → VecEA2 1` (two endpoint `TemporalPred`s + one interval `TemporalPred`), where
  `{x,t}` are the FIXED bracket endpoints and `w` is a bracket WITNESS. It MUST NOT be:
  - an **arity-1 navigated point characteristic** (the endChar `→ TemporalPred` carrier, v2 route —
    refuted report 03 §2: no paper counterpart, free-anchor form provably FALSE at
    NfMultiAnchorBridge:1058-1069); nor
  - an **interior-existential-witness evaluation of `alpha_0`** (EANegation.lean:1077-1080 fidelity
    note: "Rabinovich avoids this by evaluating `alpha_0` at the ENDPOINT `z_0` (a fixed point)" — the
    endChar "navigated witness `w`" is exactly the interior-existential evaluation Rabinovich avoids).

  **CRITICAL DISTINCTION from G2 (do not conflate):** G2 bars a *projection-based `VecEA2` tower* that
  introduces a **third free anchor** (specs/305 report 40 — a genuine ≤2-cap violation). G6's carrier is
  a *two-anchor* bracket where the `VecEA2` is the Prop-3.5 **bracket witness** structure, anchor count
  stays ≤2 (Lemma 3.2(2)), and `{x,t}` are fixed endpoints — NOT free projection anchors. The v3 carrier
  is `VecEA2`-shaped by Prop 3.5, and this is guard-safe precisely because it is a fixed-endpoint bracket,
  not a projection tower. A future agent MUST verify anchors stay `{x,t}` (2, fixed) — the `VecEA2` form
  alone does not violate G2; a *third free anchor* would.

**Do NOT**:
- Do NOT resurrect the plan-v2 `endChar`/`EndCharCarrier`/`seg`/`seg_holds_*` route or report 02's
  "build the arity-4→3 collapse brick" recommendation. Report 03's Adversarial Self-Verification
  explicitly OVERTURNED it. The code is retained (see Abandoned Route below) but is OFF the live path
  and MUST NOT be built on unless report 03's R1-R4 decomposition says otherwise.
- Do NOT route hook discharge through `nf_char3_deeper_split` (Corrected Anchor-Cap Statement; report 02
  §4.1). It grows the anchor set (3→4) and builds the forbidden tower.
- Do NOT trust the v1 route-audit comments at NfMultiAnchorBridge:661,:676-678 — false against
  `nf_char3_deeper_split`'s statement.
- Do NOT edit `nf_zone_flatten_navigable` inner-`w` trivial-top exterior brackets or
  `nf_char2_diag_exist_tl` (:190) exterior brackets (D4 — sound as-is).
- Do NOT re-encode the core `nf_eval_nf` normal form (report 03 §3 "Adjustment to the NormalForm
  encoding"). Path B achieves faithful behavior at the point of use (the `:351` arm) by treating
  `char_k1` as the E[Σ]-atom; the encoding divergence is a documented known-limitation, not a 309
  deliverable. (The R2 no-go fallback is the ONLY circumstance under which an encoding-level task is
  spawned — see Phase R2.)
- Do NOT introduce any domain axiom or leave any sorry in new material past the phase that owns it (sole
  exception: an explicitly documented strategic-sorry + `follow_up_task`, per acceptance criteria).
- Do NOT reintroduce an import cycle. The only new import edge is already landed (P6.1).

**MUST preserve**:
- All Preserved/Live Assets above (sorry-free, axiom-clean), including Phases 1-5 and the P6.1 edge.
- The `:354` live-path sorry stays (out of scope; task 305).
- Existing full-tree build green.

**Design decisions are SETTLED** (do not re-open without a concrete counterexample):
- The constructive `A` is the Rabinovich Prop 3.5 / Cor 5.4 bracket `F_i` chain (report 03 VERDICT).
- The recursion carrier is the **two-anchor VecEA2 bracket characteristic** (G6), NOT the navigated
  arity-3 `endChar` (v2, refuted).
- The recursion base is the sorry-free depth-0 `nf_3var_bracket_xyt` (report 03 §3 Path B), lifted to
  depth `k` with `char_k1` as endpoint/interval types.
- The `:351` rewire (R4) is live (D1); Phases 1-5 stay off the live import path except as R4 consumers.

## Goals & Non-Goals

**Goals:**
- Reformulate the recursion carrier to the two-anchor VecEA2 bracket characteristic + state its
  fixed-endpoint correctness (R1).
- De-risk Path B with the `k=1` probe (R2, DECISION GATE).
- Build the depth-`k` lift of `nf_3var_bracket_xyt` threading `char_k1` (R3).
- Discharge the four hooks via the v3 carrier + bounded ∃-closure, rewire `KampPrior:351` to the
  three-way disjunction via `nf_zone_exists_trichotomy_k1`, close the `:351` sorry (live sorries 2 → 1),
  full `lake build` GREEN, axioms exactly `[propext, Classical.choice, Quot.sound]` (R4).

**Non-Goals:**
- Closing `:354` (task 305 scope).
- Building or repairing the abandoned `endChar`/`seg` route (off live path; retained only).
- Re-encoding `nf_eval_nf` (documented known-limitation, not a 309 deliverable — unless R2 no-go).
- Any `nf_char3_deeper_split`-based discharge (anchor-tower forbidden).

## Risks & Mitigations

- **Risk (Medium-High; report 03 §3 OPEN RISK)**: the depth-`k` lift silently re-introduces a navigated
  arity-3 characteristic when the inner `nf_eval_nf M k 3 [w,x,t] qnf` (`k ≥ 1`) is expanded — its own
  quant layer must fold to an E[Σ]-atom via the depth-`(k−1)` IH threaded as the bracket interval type.
  **Mitigation**: R2 is an explicit DECISION GATE that runs the `k=1` case in isolation and issues a
  go/no-go verdict BEFORE R3 is attempted. A Path-B failure is detected in one bounded ~100-line dispatch
  rather than after a ~200-line lift attempt.
- **Risk (recurring; the 4-strike churn root)**: a dispatch trusts a stale route-audit comment and
  re-attempts the `endChar` navigated carrier or the `nf_char3_deeper_split` anchor tower. **Mitigation**:
  G6 + the Corrected Anchor-Cap Statement + the explicit "Do NOT" carry into every dispatch; R1 changes
  the carrier TYPE so the arity-4 obstruction cannot re-form.
- **Risk (High; R3 concentration)**: the depth-`k` recursion is the difficulty concentration (~120-200
  lines). **Mitigation**: the base (`nf_3var_bracket_xyt`) and the E[Σ]-atom (`char_k1`) are both landed
  sorry-free; R3 glues green sub-pieces. If R3 overruns H8, split at the base-wiring / step-fold seam.
- **Risk**: R4 puts the carrier on the live path and surfaces a latent axiom leak. **Mitigation**: R4
  runs a full-tree build + `#print axioms` as explicit criteria; the newly-live subtree is grep-verified
  sorry-free.
- **Risk**: G5 literature-fidelity violated by a tactic shortcut. **Mitigation**: each chain step in
  R3/R4 cites Rabinovich PDF p.4-5; no `simp`/`omega`/`aesop` on a chain step.

## Implementation History (landed / abandoned — NOT open work)

These sections are history. None match the orchestrator open-phase heading-scan
(`^### Phase [0-9]+(\.[0-9]+)?: .*\[(NOT STARTED|PARTIAL|IN PROGRESS)\]`). Do not re-dispatch them.

### Phase 1: Segment-carrying A_past / A_future + _correct [COMPLETED]

Landed, commit f4b9600a1. Segment-carrying `A_past`/`A_future` (NfZoneFlattenNavigable:335/:386) via
`bracketBuildLeft/Right_correct` (Rabinovich `β_i`). Sorry-free. Live consumer in R4. History only.

### Phase 2: Off-diagonal atom layer for [x,t] [COMPLETED]

Landed, commit 762ea60da. `nf_char2_atom_offdiag_{origin,endpoint,correct}` (NfMultiAnchorBridge:364/:375/:391),
`order 0 1 = true`. Sorry-free; axioms clean. Consumed in R4 depth-0 atom decomposition. History only.

### Phase 3: Arity-3 endpoint-hook construction [COMPLETED]

Landed, commit 010ab616d. `nf_char3_endpoint_tl` + `_correct` (NfMultiAnchorBridge:891/:907), the
hook-parametric endpoint SHAPE (NOT the v3 carrier). Sorry-free. History only.

### Phase 4: nf_char2_past_formula + _correct (F_i chain past arm) [COMPLETED]

Landed, commit fed9fcd8e. `nf_char2_past_formula` + `_correct` (NfMultiAnchorBridge:992/:1015), RHS
`∃ x, x < t ∧ nf_eval_nf M (k+1) 2 (Fin.cons x (fun _=>t)) sub_nf` **under `h_quant`** (:1023-1026).
Sorry-free. In v3 the `h_quant` hook is discharged in R4 via the two-anchor carrier. History only.

### Phase 5: nf_char2_future_formula + _correct (F_i chain future dual) [COMPLETED]

Landed, commit b60c63b1a. `nf_char2_future_formula` + `_correct` (NfMultiAnchorBridge:1185/…), dual RHS
`∃ x, t < x ∧ …` **under dual `h_quant`** (:1223-1226). Sorry-free. Discharged in R4. History only.

### Phase 6.1: Cycle-safe import edge (NfMultiAnchorBridge → KampPrior) [COMPLETED]

Landed, commit f3827e255. `import …Kamp.NfMultiAnchorBridge` in `KampPrior.lean` (D1, cycle-safe).
Full-tree GREEN. The ONLY new import edge permitted; done. History only — do not re-add/move.

### Plan-v2 Phases 6-8 (endChar0 / EndCharCarrier / seg / seg_holds_*) [ABANDONED ROUTE — code retained, off live path]

Commits 131615736, 88a785d96, 901484b9c, f663811bb, 310ab8652, 8d8ce7dbf. Delivered the navigated
arity-3 endpoint route: `endChar0` + `EndCharCarrier := NormalForm sig k 3 → TemporalPred` interface, the
corrected residual-conditional `endChar0_correct`, and the interior segment `seg`/`seg_holds_correct`/
`seg_holds_coupled`. **Plan-v2 Phase 8 went [BLOCKED]** on the arity-4 → arity-3 re-bounding obstruction.

Report 03 identified this carrier as the **churn root** (no paper counterpart; free-anchor form provably
FALSE at NfMultiAnchorBridge:1058-1069). Per report 03: **do NOT delete this code** (it compiles green and
its lemmas are self-consistent), **do NOT build on it**, and **do NOT resurrect** the "build the collapse
brick" recommendation of report 02. The `seg`/`seg_holds_coupled` machinery and `endChar0` remain in
`NfMultiAnchorBridge.lean` as inert, off-live-path definitions; the v3 live path (R1-R4) routes through the
two-anchor VecEA2 bracket carrier instead. If a future dispatch finds a report-03-sanctioned use for a
retained piece, it must cite report 03's decomposition explicitly. History only.

## Implementation Phases (Open — R1-R4, per report 03 §4)

**Dependency Analysis**:

| Wave | Phase | Blocked by |
|------|-------|------------|
| 1 | 9 (R1) | -- (consumes landed assets only) |
| 2 | 10 (R2, DECISION GATE) | 9 |
| 3 | 11 (R3) | 10 (go verdict) |
| 4 | 12 (R4) | 11 |

Phases 9→10→11→12 are strictly sequential. **Phase 10 (R2) is a hard decision gate**: R3/R4 are dispatched
ONLY on an R2 **go** verdict; an R2 **no-go** verdict halts the recursion route and triggers `/spawn` (see
Phase 10). The orchestrator dispatches exactly one phase per cycle by heading-scan
(`^### Phase [0-9]+(\.[0-9]+)?: .*\[(NOT STARTED|PARTIAL|IN PROGRESS)\]`); Phases 9-12 are the only open
headings.

### Phase 9: Two-anchor VecEA2 bracket carrier reformulation + interface (R1) [COMPLETED]

- **Goal**: Replace the abandoned navigated carrier
  `EndCharCarrier := NormalForm sig k 3 → TemporalPred` with the **two-anchor bracket carrier**
  `EndCharCarrier := NormalForm sig k 3 → VecEA2 1` (or a minimal record capturing two endpoint
  `TemporalPred`s + one interval `TemporalPred`). State the target correctness in the **fixed-endpoint**
  form (Prop 3.5, PDF p.5), mirroring `nf_3var_bracket_xyt_correct` (VecEADecomp:244). This is a
  typechecking + interface phase; it documents the deviation from v2 and installs G6 as a type invariant.
- **Deliverables (exact names/signatures)**:
  - The reformulated carrier abbreviation/record: `EndCharCarrier sig k := NormalForm sig k 3 → VecEA2 1`
    (two fixed endpoint types + one interval type — the Prop-3.5 bracket).
  - The stated (not yet proved beyond `k=0`/typecheck) target-correctness lemma signature, in the form
    `(carrier qnf).holds M atomMap x t ↔ ∃ w, nf_eval_nf M k 3 (Fin.cons w (Fin.cons x (fun _=>t))) qnf`
    — `{x,t}` are the FIXED bracket endpoints, `w` is a bracket witness (G4/G6).
- **File targets**: `Theories/Bimodal/.../Kamp/NfMultiAnchorBridge.lean` (new carrier + interface,
  alongside — not replacing — the retained abandoned-route defs).
- **Consume, do NOT rebuild**: `nf_3var_bracket_xyt`/`_correct` (VecEADecomp:233/:244, the shape to
  mirror); `VecEA2` / `BracketFormula` machinery; `char_k1` (KampPrior:307, the interval-type provider,
  referenced in the signature). Do NOT consume/rebuild the abandoned `endChar`/`seg`; do NOT touch
  Preserved/Live Assets.
- **Acceptance criteria**: `lake build` GREEN for NfMultiAnchorBridge.lean and dependents; the carrier
  and its correctness signature typecheck; anchors provably `{x,t}` (2, fixed — G4/G6); 0 new sorries
  (or a documented strategic-sorry + `follow_up_task`); axioms exactly `[propext, Classical.choice,
  Quot.sound]` on any lemma stated here.
- **Estimated lines**: 40-80 (one agent run; H8).
- **Guards enforced**: G2, G4, G6 (the type is the invariant).
- **Commit**: `task 309 phase 9: two-anchor VecEA2 bracket carrier reformulation (R1)`

### Phase 10: k=1 de-risking probe — DECISION GATE (R2) [BLOCKED]

**R2 VERDICT: NO-GO** (session sess_1783359214_93fd70). The `k=1` fold does NOT close as a `VecEA2`
bracket: it leaves an irreducible arity-4 residual, exactly the plan-v2 Phase-8 obstruction, now
falsified at k=1 in one bounded dispatch. Path B halts. R3/R4 are NOT dispatched. `/spawn` an
encoding-level task (scope below). This is a SUCCESSFUL gate outcome — the gate did its job.

**BLOCKER** (Phase 10, R2 NO-GO):
- **What was probed**: the most faithful `k=1` carrier `bracketEndChar_k1 qnf := nf_3var_bracket_xyt
  atomMap h_surj qnf.1` (mirror the sorry-free depth-0 collapse on the atom part `qnf.1`), and its
  `BracketCarrierCorrect`-at-`k=1` obligation
  `(carrier qnf).holds M atomMap x t ↔ ∃ w, nf_eval_nf M 1 3 [w,x,t] qnf`.
- **Failing goal shape (captured via `lean_goal` + `lean_multi_attempt`, NfMultiAnchorBridge.lean
  ~:1632)**: after `rw [nf_3var_bracket_xyt_correct …]` (discharges the atom layer) and
  `refine ⟨w, h_atom, ?_⟩` (splits off the depth-1 quant conjunct), the residual is
  ```
  h_atom : nf_eval_nf M 0 3 (Fin.cons w (Fin.cons x fun _ ↦ t)) qnf.1   -- ATOM layer only
  ⊢ ∀ (sub_nf : NormalForm sig 0 (3 + 1)),
      (∃ x_1, nf_eval_nf M 0 (3 + 1) (Fin.cons x_1 (Fin.cons w (Fin.cons x fun _ ↦ t))) sub_nf)
        ↔ qnf.2 sub_nf = true
  ```
  `simp_all [nf_eval_nf]` reduces each clause to the two irreducible halves
  `(∃ x_1, ∀ a:AtomKind sig 4, atom_eval M (Fin.cons x_1 (Fin.cons w (Fin.cons x fun _ ↦ t))) a ↔
  sub_nf a) ⟷ qnf.2 sub_nf`.
- **Why stuck (root cause)**: the residual env `[x_1, w, x, t]` is **arity 4** — it couples the
  bracket witness `w` to BOTH fixed endpoints `x, t` (plus a fresh existential `x_1`), and the atom-
  only carrier discarded `qnf.2` (the quant assignment). A `VecEA2 1` carrier's components
  (`endpointLeft`@x, `endpointRight`@t, interval@w) are each **monadic** `TemporalPred`s reading a
  single point; none can represent a property coupling `w` to `x` and `t`. Discharging it would
  require a **navigated arity-3 characteristic** (read `w` while `x, t` are navigated in) — precisely
  what G6 bars, and precisely the arity-4 → arity-3 re-bounding obstruction that blocked plan-v2
  Phase 8 (`nf_eval_nf M (k+1) 3` produces arity-4 subs an arity-3 carrier cannot consume). Report
  03's OPEN RISK ("the depth-`k` lift silently re-introduces a navigated arity-3 characteristic when
  `nf_eval_nf M k 3 [w,x,t] qnf`, `k ≥ 1`, is expanded") is CONFIRMED at `k=1`. No monadic bracket
  carrier (not just the atom-only one) closes it, because even `w`'s own depth-1 arity-1 char is an
  arity-2 property of `w` alone and cannot pull back `qnf.2`'s arity-4 quant coupling to `x, t`.
- **What is needed (`/spawn` scope, report 03 §4 R2 NO-GO fallback)**: spawn a dedicated
  **encoding-level task** — *"NormalForm E[Σ]-fold: re-encode `nf_eval_nf` so each quantifier depth
  folds into a fixed-arity monadic E[Σ]-atom (Rabinovich Def 4.1, PDF p.5) rather than growing the
  environment arity with depth. Only then is the depth-`k` divergence load-bearing; until it lands,
  task 309 stays `[BLOCKED]` on the `KampPrior.lean:351` arm (live sorries stay at 2; `:354` remains
  task 305)."* R3/R4 remain undispatched.
- **Prohibited**: Do NOT land a `sorry`/vacuous carrier to fake a GO; do NOT resurrect the
  endChar/seg navigated route; do NOT route through `nf_char3_deeper_split` (anchor tower). None were
  done — the probe was removed; NfMultiAnchorBridge.lean stays sorry-free and green.

**THIS PHASE IS AN EXPLICIT GO/NO-GO DECISION GATE.** A hard-mode implement agent MUST treat a failed
probe as a STOP-AND-REPORT condition — do NOT push past it into R3/R4, do NOT attempt a workaround brick,
do NOT resurrect the endChar route. The single job of this phase is to decide Path B viability in one
bounded dispatch and write the verdict into the handoff.

- **Goal**: Prove the R1 carrier correctness at **`k = 1` only**. Expand `nf_eval_nf M 1 3 [w,x,t] qnf`,
  fold its depth-0 quant layer via the sorry-free depth-0 assets (`nf_3var_bracket_xyt` + `char_k1` at
  `k=0`), and confirm it closes as a `VecEA2` bracket **with no arity-4 residual and no navigated arity-3
  characteristic** (report 03 §3 OPEN RISK, §4 R2). This is the single experiment that decides Path B.
- **DECISION GATE semantics (write the verdict into the handoff)**:
  - **GO** — the `k=1` case closes sorry-free as a `VecEA2` bracket, no arity-4 residual, no navigated
    arity-3 char, anchors `{x,t}` (2, fixed). Handoff verdict: `R2 = GO`; the recursion closes → proceed
    to R3 (Phase 11). Commit the `k=1` lemma as a landed green milestone.
  - **NO-GO** — the fold silently forces a navigated arity-3 characteristic or leaves an arity-4 residual.
    Handoff verdict: `R2 = NO-GO`; **STOP**, mark the phase `[BLOCKED]`, and the handoff MUST recommend
    `/spawn` of a dedicated **encoding-level task** with report-03-specified scope: *"NormalForm E[Σ]-fold —
    re-encode `nf_eval_nf` to fold each depth into a fixed-arity E[Σ]-atom (Def 4.1) rather than growing
    arity; the depth-`k` divergence is then load-bearing and 309 stays `[BLOCKED]` on the `:351` arm."* Do
    NOT attempt R3/R4 after a NO-GO. (Per report 03 §4: the R2 failure converts the recommendation to
    `/spawn`; this outcome is now falsifiable in ~100 lines instead of ~500.)
- **Deliverables**:
  - `k=1` instance of the R1 carrier-correctness lemma, proved sorry-free (GO) — or a documented
    `[BLOCKED]` record with the NO-GO verdict and the `/spawn` scope above (NO-GO).
  - A one-line `R2 = GO | NO-GO` verdict in the phase handoff, with the evidence (did the fold close via
    `char_k1` + a `VecEA2` bracket, yes/no).
- **File targets**: `Theories/Bimodal/.../Kamp/NfMultiAnchorBridge.lean` (the `k=1` probe lemma,
  alongside the R1 carrier).
- **Consume, do NOT rebuild**: `nf_3var_bracket_xyt`/`_correct` (VecEADecomp:233/:244, depth-0 base);
  `char_k1`/`_correct` (KampPrior:307/:310, the `k=0` E[Σ]-atom); `bracketBuildLeft/Right`/`_correct`;
  the R1 carrier interface. Do NOT consume `nf_char3_deeper_split`; do NOT consume the abandoned
  `endChar`/`seg`.
- **Acceptance criteria**: on GO — `lake build` GREEN; the `k=1` lemma typechecks and is sorry-free;
  axioms exactly `[propext, Classical.choice, Quot.sound]`; anchors `{x,t}` (G4/G6); no arity-4 residual
  in the proof term (verify by inspecting the folded goal). On NO-GO — the `[BLOCKED]` record + `/spawn`
  recommendation is written; no partial/vacuous carrier is committed.
- **Estimated lines**: 60-100 (one agent run; H8).
- **Guards enforced**: G3, G4, G5, G6.
- **Commit (GO only)**: `task 309 phase 10: k=1 de-risking probe — Path B GO (R2)`

### Phase 11: depth-k lift of nf_3var_bracket_xyt threading char_k1 (R3) [NOT STARTED]

*(Dispatch ONLY on an R2 = GO verdict from Phase 10.)*

- **Goal**: Generalize `nf_3var_bracket_xyt` (VecEADecomp:233) so its endpoint types
  (`nf_x_proj3`/`nf_t_proj3`) and interval type (`nf_y_proj`) are the **depth-`k` characteristics**
  `char_k1` (KampPrior:307, the E[Σ]-atom of Def 4.1) instead of depth-0 `nfPred`. Prove the carrier
  correctness for all `k` by recursion on `k`:
  `(carrier qnf).holds M atomMap x t ↔ ∃ w, nf_eval_nf M k 3 (Fin.cons w (Fin.cons x (fun _=>t))) qnf`
  — base = the existing depth-0 `nf_3var_bracket_xyt_correct`; step = fold via `char_k1` +
  `bracketBuildLeft/Right` (Prop 3.5). `w` is a bracket witness (G4/G6); the interval type is a real
  `char_k1` (G3, not `⊤`).
- **Deliverables (exact names/signatures)**:
  - `nf_3var_bracket_xyt_k` (the depth-`k` lift; suggested name — carrier-valued, threading `char_k1`).
  - `nf_3var_bracket_xyt_k_correct : (nf_3var_bracket_xyt_k … qnf).holds M atomMap x t ↔ ∃ w,
    nf_eval_nf M k 3 (Fin.cons w (Fin.cons x (fun _=>t))) qnf` (recursion on `k`).
- **File targets**: `Theories/Bimodal/.../Kamp/NfMultiAnchorBridge.lean` (or `VecEADecomp.lean` if the
  lift is more naturally sited next to `nf_3var_bracket_xyt` — the implement agent chooses the minimal
  edit site; do NOT split the def across files unnecessarily).
- **Consume, do NOT rebuild**: `nf_3var_bracket_xyt`/`_correct` (VecEADecomp:233/:244, the base);
  `char_k1`/`_correct` (KampPrior:307/:310, endpoint/interval types); `bracketBuildLeft/Right`/`_correct`
  (VecEATranslation:273/:503, :50/:234, the chain builders); the R1 carrier. Do NOT consume
  `nf_char3_deeper_split` (anchor-growing); do NOT consume the abandoned `endChar`/`seg`.
- **Acceptance criteria**: `lake build` GREEN; `nf_3var_bracket_xyt_k_correct` typechecks against
  `nf_eval_nf M k 3 [w,x,t] qnf` for all `k`; 0 new sorries (or documented strategic-sorry +
  `follow_up_task`); `#print axioms` exactly `[propext, Classical.choice, Quot.sound]`; anchors provably
  `{x,t}` at every recursion depth (G4/G6); the interval type is a real characteristic not `⊤` (G3);
  each chain step cites Rabinovich PDF p.5 Prop 3.5 (G5, no simp/omega/aesop shortcut).
- **H8 split note**: if it overruns one agent run, split at the base-wiring / step-fold seam (11a/11b).
- **Estimated lines**: 120-200 (one agent run; H8).
- **Guards enforced**: G1, G3, G4, G5, G6.
- **Commit**: `task 309 phase 11: depth-k lift of nf_3var_bracket_xyt (R3)`

### Phase 12: Discharge four hooks + KampPrior:351 rewire + full-tree axiom check (R4) [NOT STARTED]

*(Dispatch ONLY after Phase 11 lands green. This phase delivers the task goal.)*

- **Goal**: Use the Phase-11 depth-`k` two-anchor bracket carrier to **discharge the four deferred
  hooks** — `h_quant` (past, NfMultiAnchorBridge:1023-1026), `h_quant` (future, :1223-1226), and
  `h_past`/`h_fut`/`h_diag` (`A_diag_correct`, :787-795) — then rewire `KampPrior.lean:351` to the
  three-way disjunction `A := nf_char2_past_formula … ∨ A_diag … ∨ nf_char2_future_formula …` via
  `nf_zone_exists_trichotomy_k1` and a three-way `or_congr`, closing the `:351` sorry (live sorries 2 → 1;
  `:354` stays, task 305). Mechanically (report 03 §4 R4): at `:351` the goal is
  `∃ A, temporal_truth t A ↔ ∃ env:Fin 1, nf_eval_nf M (k+1) 2 (insertEnv env t) sub_nf`; bridge
  `env:Fin 1` to `∃x` (existing `h_env_eq` shape, KampPrior:277-291); decompose `nf_eval_nf M (k+1) 2
  [x,t]` into its depth-0 atom layer (`nf_char2_atom_offdiag_correct`, P2) and, per arity-3 sub `qnf`, the
  inner existential closed by the Phase-11 carrier (Lemma 3.4 / `existsBounded_right`, VecEAClosure:265);
  assemble via `bracketBuildLeft/Right` (Prop 3.5) and feed the three arms through the `or_congr` with
  `nf_char2_past_formula_correct` / `A_diag_correct` / `nf_char2_future_formula_correct`.
- **Deliverables**:
  - Proofs of the four hooks (`h_quant` past+future, `h_past`/`h_fut`/`h_diag`) at the call site,
    discharged via the Phase-11 carrier + `existsBounded_right` + `nf_zone_flatten_navigable_correct`.
  - The three-way disjunction `A` and the closed `:351` arm of `nf_nvar_exist_all_depths` (rewired via
    `nf_zone_exists_trichotomy_k1` three-way `or_congr`).
- **File targets**: `Theories/Bimodal/.../Prior/KampPrior.lean` (`:351` arm; local hook wiring
  KampPrior:264-320). The import edge is already landed (P6.1) — do NOT re-add it.
- **Consume, do NOT rebuild**: Phases 4/5 `nf_char2_{past,future}_formula`/`_correct`; `A_diag`/`_correct`
  (NfMultiAnchorBridge:763/:808); `A_past`/`A_future`/`_correct` (P1); `nf_char2_atom_offdiag_correct`
  (P2); `nf_zone_exists_trichotomy_k1` (NfZoneFlattenNavigable:188); `nf_zone_flatten_navigable(_brick)`/
  `_correct` (NfMultiAnchorBridge:689/:709); the Phase-11 `nf_3var_bracket_xyt_k`/`_correct`;
  `existsBounded_right` (VecEAClosure:265); `bracketBuildLeft/Right`/`_correct`; local `char_k1` /
  `ih_exist_1` (KampPrior:264-320) for the `Fin 1 → ∃x` bridge. Do NOT consume the abandoned
  `endChar`/`seg`; do NOT consume `nf_char3_deeper_split`.
- **Acceptance criteria (definition of done)**:
  - Full-tree `lake build` GREEN.
  - `#print axioms` (or `lean_verify`) on the rewired `nf_nvar_exist_all_depths` live-path theorem =
    exactly `[propext, Classical.choice, Quot.sound]` (0 domain axioms).
  - Live-path sorry count reduced 2 → 1: `:351` closed; `:354` deliberately remains (task 305).
  - `grep "sorry"` across the new material (R1/R3/R4) shows only docstring/comment hits (no code sorries;
    sole exception: an explicitly documented strategic-sorry with a `follow_up_task`, which must be
    resolved or carried before this phase's build is considered clean on the live path).
  - Task 307 Phase 7 wiring verification is unblocked (report the unblock; do not execute it here).
- **Estimated lines**: 60-120 (one agent run; H8).
- **Guards enforced**: G1, G3, G4, G5, G6; D1 (import edge already landed); final sorry + axiom discipline.
- **Commit**: `task 309 phase 12: discharge hooks + rewire KampPrior:351 + axiom check (R4)`

## Testing & Validation

- After each phase: `lake build` for the touched file and its dependents; grep for new `sorry`.
- Per-phase axiom check (`#print axioms` / `lean_verify`) on the phase's new `_correct` lemma: exactly
  `[propext, Classical.choice, Quot.sound]`.
- **R2 gate check**: the go/no-go verdict is written into the handoff before any R3 dispatch. A NO-GO
  halts the recursion route and triggers `/spawn` (encoding-level task) per Phase 10.
- Phase R4 gate (definition of done):
  - Full-tree `lake build` GREEN.
  - `#print axioms` on the rewired live-path theorem: exactly `[propext, Classical.choice, Quot.sound]`,
    0 domain axioms.
  - Live-path sorry count reduced 2 → 1 (`:351` closed; `:354` remains).
  - `grep "sorry"` across new material (R1/R3/R4): only docstring/comment hits (or a single documented
    strategic sorry with a `follow_up_task`).
- Regression: task 307 Phase 7 wiring verification is unblocked (report the unblock, do not execute here).

## Artifacts & Outputs

- `Theories/Bimodal/.../Kamp/NfMultiAnchorBridge.lean` — two-anchor VecEA2 bracket carrier + interface
  (R1), `k=1` probe (R2), depth-`k` lift `nf_3var_bracket_xyt_k` + `_correct` (R3). The abandoned
  `endChar`/`seg` defs remain in this file, inert and off the live path.
- `Theories/Bimodal/.../Prior/KampPrior.lean` — hook discharge + rewired `:351` arm (R4).
- Up to four scoped commits (`task 309 phase 9/10/11/12: …`), continuing the P1-P5 + P6.1 history. Phase
  10 commits only on GO; a NO-GO records `[BLOCKED]` + `/spawn` scope instead.

## Rollback/Contingency

- Each phase is a scoped commit; revert the last commit to roll back a single phase without disturbing
  earlier green milestones (H9 incremental-commit discipline).
- Phases 1-5 + the P6.1 import edge are landed and green; the abandoned-route code is inert. If a later
  phase surfaces an unexpected build or axiom problem, roll back to the prior green commit — the `:351`
  sorry simply remains until the carrier lands, with no downstream regression.
- **R2 NO-GO is the primary contingency**: if the `k=1` probe fails, 309 stays `[BLOCKED]` on the `:351`
  arm and a dedicated encoding-level `/spawn` task (NormalForm E[Σ]-fold) is created — a falsifiable
  ~100-line outcome, not a ~500-line brick. R3/R4 are never dispatched after a NO-GO.
- If R3 overruns the H8 dispatch budget, split at the base-wiring / step-fold seam (11a/11b) rather than
  inflating a single dispatch.
