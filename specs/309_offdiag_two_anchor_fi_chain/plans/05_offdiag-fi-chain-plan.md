# Implementation Plan: Off-Diagonal Two-Anchor F_i Chain (task 309) — v4

- **Task**: 309 - offdiag_two_anchor_fi_chain
- **Status**: [IN PROGRESS]
- **Effort**: ~8-12 hours (Phases 1-5 + 6.1 + 9 landed; Phase 10 gate NO-GO superseded by spawned GO; Phase 11 prerequisite closure landed via tasks 310/311; 3 open phases R3a/R3b/R4, ~290-520 lines Lean)
- **Dependencies**: 310 (COMPLETE — `Kamp/NfEFold.lean` E[Σ]-fold landed sorry-free); 311 (COMPLETE — k=1 V-carrier `bracketEndChar_k1v_correct` GO, sorry-free)
- **Research Inputs**:
  - reports/01_offdiag-fi-chain-research.md (H4-verified, Tier 1; source for the outer wrapper + import DAG)
  - reports/02_endpoint-hook-discharge-research.md (background only — "build the collapse brick / endChar" recommendation SUPERSEDED and adversarially OVERTURNED by report 03)
  - reports/03_rabinovich-faithful-path-research.md (Path B carrier reformulation; R1-R4 decomposition; the two-anchor bracket carrier authority)
  - reports/04_spawn-analysis.md (**REVISION AUTHORITY for v4** — R2 k=1 NO-GO root-cause = `nf_eval_nf` per-depth arity growth is an encoding artifact; spawned tasks 310 + 311 to supply the fixed-arity E[Σ]-fold and re-close the k=1 gate)
- **Artifacts**:
  - plans/01_offdiag-fi-chain-plan.md (v1, superseded)
  - plans/02_offdiag-fi-chain-plan.md (v2, superseded — endChar/seg route [ABANDONED ROUTE])
  - plans/03_offdiag-fi-chain-plan.md (v3, superseded — Phase 10 R2 NO-GO handoff superseded by this v4)
  - plans/05_offdiag-fi-chain-plan.md (this file, v4)
- **Standards**:
  - .claude/rules/artifact-formats.md
  - .claude/rules/state-management.md
  - .claude/rules/plan-format-enforcement.md
  - .claude/context/formats/plan-format.md
- **Type**: lean4 (hard-mode; H8 phase sizing, postmortem constraints, wave declarations)
- **reports_integrated**: 01_offdiag-fi-chain-research.md, 02_endpoint-hook-discharge-research.md, 03_rabinovich-faithful-path-research.md, 04_spawn-analysis.md

## Overview

Build the off-diagonal (`x ≠ t`) two-anchor navigated characteristic — the Rabinovich Prop 3.5 /
Cor 5.4 `F_i` chain — so `KampPrior.lean:351` can be discharged (live sorries 2 → 1; `:354` stays,
task 305 scope). Definition of done: full `lake build` GREEN, `#print axioms` on the rewired
live-path theorem `nf_nvar_exist_all_depths` = exactly `[propext, Classical.choice, Quot.sound]`
(0 domain axioms), all new material sorry-free, task 307 Phase 7 unblocked.

**Plan lineage (v1 → v2 → v3 → v4).**
- **v1** — original outer-wrapper + navigated-characteristic route (Phases 1-5, 6.1 landed).
- **v2** — navigated arity-3 endpoint characteristic `endChar` (Phases 6-8); Phase 8 went [BLOCKED]
  on an arity-4 → arity-3 re-bounding obstruction. [ABANDONED ROUTE], code retained off the live path.
- **v3** — Path B pivot (report 03): reformulated the recursion carrier to a **two-anchor VecEA2
  bracket characteristic** (fixed endpoints `{x,t}`), landed the R1 carrier (Phase 9), then ran the
  `k=1` decision gate (Phase 10, R2). **R2 returned NO-GO**: the `k=1` fold left an irreducible
  arity-4 residual (`[x_1,w,x,t]`), the same obstruction as v2 Phase 8 — now root-caused (report 04)
  to `nf_eval_nf`'s per-depth arity growth, an ENCODING artifact with no counterpart in Rabinovich
  (Def 4.1 folds each depth into a fixed-arity monadic E[Σ]-atom). The gate did its job and triggered
  a `/spawn`.
- **v4 (this revision)** — folds the spawned prerequisites (tasks 310 + 311, both COMPLETE) back into
  309: task 310's fixed-arity E[Σ]-fold encoding (`Kamp/NfEFold.lean`) and task 311's **R2 = GO**
  verdict (the k=1 witness-growing V-carrier `bracketEndChar_k1v_correct` proved sorry-free). The
  v3 Phase-10 NO-GO is **superseded**: Path B is viable at `k=1` under the fold + the G6-AMENDED
  witness-growing carrier. v4 re-scopes the remaining R3/R4 work against the fold-backed V-carrier and
  resumes implementation.

### Research Integration

reports/04_spawn-analysis.md integrated in plan version 4 (2026-07-06). This report is the AUTHORITY
for the v4 revision. Its decisive findings:

1. **The R2 k=1 NO-GO is an ENCODING gap, not a carrier-shape problem** (report 04 "Root Cause"):
   the arity-4 residual `[x_1,w,x,t]` arises specifically from `nf_eval_nf`'s `n → n+1` per-depth
   arity growth (`NormalForm.lean:198-207`), which has no counterpart in Rabinovich 2014. Def 4.1
   (PDF p.5) folds each processed quantifier depth into a **monadic** (arity-1) E[Σ]-atom before the
   next level is decomposed. The two-anchor `VecEA2` carrier SHAPE (task 309 Phase 9,
   `BracketEndCharCarrier`/`BracketCarrierCorrect`/`bracketEndChar_k0`) remains the CORRECT shape per
   G6 — only the recursion mechanism underneath it changes.
2. **Two spawned prerequisites, both now COMPLETE**:
   - Task 310 — *NormalForm E[Σ]-fold encoding (Def 4.1)*: `Kamp/NfEFold.lean`, a fixed-arity monadic
     fold defined alongside `nf_eval_nf` (not replacing it), proved equivalent for the arity-3
     two-anchor shape `[w,x,t]`. Load-bearing lemmas: `nf_eval_nf1_iff_efold` (NfEFold:490),
     `nf_quant_layer_fold_k1_gate` (NfEFold:525), `efold_of_nf1` (NfEFold:472), `nf_eval_efold`
     (NfEFold:102).
   - Task 311 — *Close k=1 BracketCarrierCorrect gate under the E[Σ]-fold*: re-ran the R2 probe using
     310's fold. **R2 = GO**, recorded at NfMultiAnchorBridge.lean:3394-3434. The k=1 correctness `↔`
     closed with NO arity-4 residual and NO navigated arity-3 characteristic; every `qnf.2` read routes
     through `efold_of_nf1` so per-(zone, χ) obligations are zone-bounded MONADIC existentials over
     env `[w,x,t]`. Anchors stay `{x,t}` (a TYPE-level invariant of `VVecEA2.holds`).
3. **The carrier is the G6-AMENDED witness-growing V-carrier** (task 311 plan v3 G6 Amendment):
   the fixed one-witness codomain `VecEA2 1` is **REFUTED** by a dense-order counterexample
   (NfMultiAnchorBridge.lean:1750-1823). The amended carrier is the witness-growing `VVecEA2`
   (`BracketEndCharCarrierV` :1855, `BracketCarrierCorrectV` :1864, `bracketEndChar_k1v` :1923), with
   anchors FIXED at `{x,t}` (Lemma 3.2(2) PDF p.4 caps ANCHORS at ≤2, NOT witnesses) and each
   interior-positive `(zone, χ)` bit riding an additional bracket WITNESS slot ordered between the
   fixed endpoints (§5 bracket `[α_0,…,α_n](z_0,z_1)`, PDF p.7; Lemma 3.4 PDF p.5 ∃-closure).
4. **After both prerequisites: resume 309** (report 04 "After Completion"): `/revise 309` to plan v4
   (this file) replacing the Phase-10 NO-GO with the GO outcome and re-scoping R3/R4 against the
   fold-backed carrier, then `/implement 309`.

reports/01 remains the source for the outer wrapper (Phases 1-5) and the import DAG (Phase 6.1).
reports/02 is retained for background only (its "collapse brick" recommendation stays superseded).
reports/03 remains the Path B / carrier-reformulation authority; v4 does not re-open its verdict, it
completes it with the fold underneath.

### Corrected Anchor-Cap Statement (CARRIED FORWARD; still binding)

**The hook-discharge path MUST keep the anchor set at `{x,t}` (≤2, Rabinovich cap; G2/G4) by the
bracket-witness mechanism (report 03 §3 Path B, as amended by task 311's witness-growth), NOT by
`nf_char3_deeper_split`.** `nf_char3_deeper_split` (NfMultiAnchorBridge:625-642) grows arity 3→4 and
anchors `{x,t}→{y,x,t}` (its statement, :628-637); composing it at each depth-descent builds the
forbidden anchor tower. The v1 route-audit comments at NfMultiAnchorBridge:661,:676-678
("arity ≤3, anchor `{x,t}`") are false and MUST NOT be trusted. Interior witnesses stay **bracket**
witnesses (now possibly several per qnf, per the witness-growth amendment); recursion is on `k`;
anchors strictly `{x,t}` (2, fixed) at every depth.

## Preserved / Live Assets (consume — do NOT rebuild)

Complete, sorry-free, MUST NOT regress. Every open phase (R3a/R3b/R4) consumes from this list and
does not rebuild or edit these.

| Component | File:line | Status | Role in v4 |
|-----------|-----------|--------|------------|
| `A_past` / `A_future` (segment-carrying) + `_correct` | NfZoneFlattenNavigable:335/:386 | Landed P1 | non-trivial-segment outer arms (consumed in R4 or_congr) |
| `nf_char2_atom_offdiag_{origin,endpoint,correct}` | NfMultiAnchorBridge:364/:375/:391 | Landed P2 | off-diagonal atom layer (`order 0 1 = true`); depth-0 atom decomposition in R4 |
| `nf_char3_endpoint_tl` / `_correct` | NfMultiAnchorBridge:891/:907 | Landed P3 | arity-3 endpoint `TemporalPred` shape (hook-parametric; NOT the carrier) |
| `nf_char2_past_formula` / `_correct` | NfMultiAnchorBridge:992/:1015 | Landed P4 | past-arm F_i wrapper; `h_quant` (:1023-1026) discharged in R4 |
| `nf_char2_future_formula` / `_correct` | NfMultiAnchorBridge:1185/… | Landed P5 | future-arm F_i wrapper; dual `h_quant` (:1223-1226) discharged in R4 |
| `A_diag` / `_correct` | NfMultiAnchorBridge:763/:808 | Landed (task 307 P2) | diagonal `[t,t]` arm; `h_past`/`h_fut`/`h_diag` (:787-795) discharged in R4 |
| `nf_zone_flatten_navigable(_brick)` / `_correct` | NfMultiAnchorBridge:689/:709 | Landed (task 308) | 5-zone `∃w` flatten |
| `nf_zone_exists_trichotomy_k1` | NfZoneFlattenNavigable:188 | Landed (task 307 P3) | `∃x` split into past/diag/future — the R4 three-way `or_congr` seam |
| `nf_3var_bracket_xyt` / `_correct` | VecEADecomp:233/:244 | Landed, sorry-free | the depth-0 witness collapse (atom layer); R3 base template |
| `char_k1` / `_correct` | KampPrior:307/:310 | Landed, sorry-free | depth-`k` arity-1 point characteristic (E[Σ]-atom, Def 4.1); endpoint/interval point type |
| **E[Σ]-fold: `nf_eval_efold`** | **NfEFold:102** | **Landed (task 310)** | **fixed-arity monadic fold evaluation (Def 4.1); dependency** |
| **`efold_of_nf1`** | **NfEFold:472** | **Landed (task 310)** | **fold-of-nf1 transport; carrier construction — reads `qnf.2` monadically** |
| **`nf_eval_nf1_iff_efold`** | **NfEFold:490** | **Landed (task 310)** | **k=1 whole-eval bridge (`nf_eval_nf M 1 3 [w,x,t] qnf` ↔ fold form + off-fiber clause)** |
| **`nf_quant_layer_fold_k1_gate`** | **NfEFold:525** | **Landed (task 310)** | **gate corollary — reduces the OLD arity-4 residual to zone-bounded MONADIC existentials; R3/R4 entry point** |
| zone semantics + split kit + engine | NfEFold:58/69/153-235/391 | Landed (task 310) | `zoneHolds`/`EAtomDom`/`nf0_split_assemble`/`nf_quant_layer_fold_iff` — zone matching |
| **`BracketEndCharCarrierV` (abbrev)** | **NfMultiAnchorBridge:1855** | **Landed 309 P9 / amended 311 P3** | **`NormalForm sig k 3 → VVecEA2` — the R3 carrier TYPE to generalize over `k`** |
| **`BracketCarrierCorrectV`** | **NfMultiAnchorBridge:1864** | **Landed 311 P3** | **two-anchor `holds ↔ ∃ w, nf_eval_nf M k 3 [w,x,t] qnf` — the R3 target predicate** |
| `bracketFromLists` (private) | NfMultiAnchorBridge:1883 | Landed 311 P3 | disjunct builder (point types `lL ++ ptW :: lR`, segment types by `≤ lL.length` split) |
| **`bracketEndChar_k1v` (k=1 V-carrier)** | **NfMultiAnchorBridge:1923** | **Landed 311, sorry-free** | **the R3 recursion TEMPLATE at depth 1** |
| **`bracketEndChar_k1v_correct` (R2 = GO)** | **NfMultiAnchorBridge:3378** | **Landed 311, sorry-free; GO record :3394-3434** | **the k=1 correctness `↔` — the R3 recursion step template (no arity-4 residual, no navigated arity-3 char)** |
| `bracketEndChar_k1v_sound` (private) | NfMultiAnchorBridge:2325 | Landed 311 | LHS→RHS direction template for R3 |
| `bracketEndChar_k1v_complete` (private) | NfMultiAnchorBridge:2966 | Landed 311 | RHS→LHS direction template for R3 |
| k1v helper kit | NfMultiAnchorBridge:2028/2052/2137/2255/2682-2825 | Landed 311 | `k1v_zoneHolds_cons_iff`/`k1v_zone_consistent`/`k1v_bracket_extract`/`k1v_reconstruct_nf3`/extract clones/`k1v_sorted_insert`/`k1v_sorted_realization`/`k1v_bracket_construct` — reusable proof machinery for R3 |
| `bracketEndChar_k0` / `_correct` | NfMultiAnchorBridge:1563/1577 | Landed 309 P9 | depth-0 base (six k0-mirror order hypotheses :1581-1594) — R3 recursion base |
| `bracketBuildLeft/Right` / `_correct` | VecEATranslation:273/:503, :50/:234 | Landed | Prop 3.5 chain builders — VALID ONLY at fixed-endpoint literals `epL`/`epR` (rule N4) |
| `BracketFormula.existsBounded_right`, `VecEAClosure`, `VBracketFormula.existsBounded_right` | VecEAClosure:265/:371 | Landed | Lemma 3.4 bounded ∃-closure / witness-append template (R3/R4) |
| `VVecEA2` structure + holds + disj | VecEAFormula:271/276/282/286 | Landed | witness-growing carrier codomain (`disjuncts : List (Σ n, VecEA2 n)`) |
| `nf_eval_unique` / `nfPred_correct` | NormalForm:245 / NfToVecEA:69 | Landed | distinctness of realizing points for distinct χ (use `nfPred_correct`, NOT KampPrior:168 — outside Bridge import closure) |
| `nf_depth0_pair_cycle_empty'` | NfDepth0Generalized:93 | Landed | inconsistent-zone falsity pattern |
| `nf_nvar_exist_all_depths` (`char_k1` local, `n=0` arm) | KampPrior:211/307/339 | Landed except `:351`/`:354` | outer recursion; the rewire target; `n=0` arm sorry-free |
| Import edge `…Kamp.NfMultiAnchorBridge` in KampPrior | KampPrior imports | Landed P6.1 | cycle-safe; full-tree GREEN. Do NOT re-add/move (D1). |
| Import edge `…Kamp.NfEFold` in NfMultiAnchorBridge | NfMultiAnchorBridge:2 | Landed (311 P1) | cycle-free; full build GREEN. Do NOT re-add/move. |

### Source-to-Implementation Mapping (H3, Tier 1)

Transcription source: `~/Projects/Literature/sources/rabinovich_2014/Rabinovich_2014_Proof_of_Kamps_Theorem.pdf`.

| Paper item (Rabinovich 2014) | Paper loc | Lean target | Phase |
|------------------------------|-----------|-------------|-------|
| Def 3.1: `α_j/β_j` quantifier-free, one-variable | PDF p.4 | carrier point types honor ≤2 cap | R3a |
| Lemma 3.2(2): ≤ 2 free ANCHORS (not witnesses) | PDF p.4 | `VVecEA2.holds` two-point signature = TYPE invariant | all |
| Prop 3.5: `∃x_i` → Until/Since bracket witness (mechanism) | PDF p.5 | `bracketEndChar_k1v_correct` (k=1 template); depth-`k` lift | R3b |
| Def 4.1: E[Σ] atom = monadic fold (depth-`k`) | PDF p.5 (note p.6) | `nf_eval_efold`/`efold_of_nf1`/`nf_quant_layer_fold_k1_gate` (NfEFold) | R3b |
| §5 bracket `[α_0,…,α_n](z_0,z_1)` — n witnesses, 2 fixed endpoints | PDF p.7 | `VVecEA2` / `bracketFromLists` disjuncts | R3a |
| Lemma 3.4: ∨∃∀ closed under bounded `∃x` (witness joins prefix) | PDF p.5 | `existsBounded_right` (VecEAClosure:265) | R3b / R4 |
| ∨ over consistent order types | PDF p.4-5 | `VVecEA2.disjuncts` (arrangement enumeration) | R3a / R3b |
| Cor 5.4 `F_{i-1} := α_{i-1} ∧ (β_i Until F_i)` past/future arms | PDF p.9 | `A_past`/`A_future`/`_correct` (P1 landed) | R4 or_congr |
| **Navigated arity-3 endpoint char (endChar route)** | **no paper counterpart** | `endChar`/`seg` | **ABANDONED ROUTE (v2 P6-P8)** |
| **`nf_eval_nf` per-depth arity growth `n→n+1`** | **no paper counterpart** | `NormalForm.lean:198-207` | **ENCODING artifact — routed around by the E[Σ]-fold (task 310)** |

## Postmortem Constraints

Binding rules for all implementation dispatches. Guards G1-G6 + Corrected Anchor-Cap are carried
**VERBATIM** from task 309 plan v3 / task 311 plan v3. G6 is carried with its **v3 amendment**
(witness-growing codomain). Rules N1-N5 are carried VERBATIM from task 311 plan v3.

**Guards G1-G6 + Corrected Anchor-Cap (VERBATIM):**

- **G1** — No arity-1 collapse of the off-diagonal. (Refuted: report 02 §1; NfDepth0Generalized:1691-1719.)
- **G2** — No projection-based `VecEA2` / third-free-anchor tower. (Refuted: specs/305 report 40; R2.)
- **G3** — No trivial-top segment on the off-diagonal arms. A closed `pastEnd` under a trivial segment
  is model-independent and cannot re-identify the distinct origin `t`, so the hook is unsatisfiable
  off-diagonal. The `(x,t)` coupling MUST ride the non-trivial Rabinovich `β_i` segment (a real
  interval type, not `⊤`/trivial). Scoped: applies to `A_past`/`A_future` and the R3 interval type ONLY
  — the inner brick's trivial-top exterior brackets are sound and MUST stay untouched.
- **G4** — `w` stays a **bracket witness**. Env arity never grows past `{w,x,t}=3 → {x,t}=2`; anchor
  set is `{x,t}` (Rabinovich ≤2 cap). `w` is never a third anchor.
- **G5** — Follow Cor 5.4 / Prop 3.5 `F_i` chains step-by-step (`F_n := α_n`,
  `F_{i-1} := α_{i-1} ∧ (β_i Until F_i)`). No `simp`/`omega`/`aesop` shortcut of a chain step
  (literature-fidelity policy). Cite Rabinovich PDF p.4-5 (Def 3.1 / Lemma 3.2(2) / Prop 3.5 / Def 4.1)
  at every chain step, using the N1/N2 splits.
- **G6** — The recursion carrier MUST be the **two-anchor bracket characteristic** with **fixed
  endpoints** `z_0, z_1` (Prop 3.5, PDF p.5): `NormalForm sig k 3 → VecEA2 1` (two endpoint
  `TemporalPred`s + one interval `TemporalPred`), where `{x,t}` are the FIXED bracket endpoints and
  `w` is a bracket WITNESS. It MUST NOT be an **arity-1 navigated point characteristic** (the endChar
  `→ TemporalPred` carrier — refuted report 03 §2; free-anchor form provably FALSE at
  NfMultiAnchorBridge:1058-1069), nor an **interior-existential-witness evaluation of `alpha_0`**
  (EANegation.lean:1077-1080). **CRITICAL DISTINCTION from G2:** G2 bars a *projection-based `VecEA2`
  tower* with a **third free anchor**; G6's carrier is a *two-anchor* fixed-endpoint bracket, anchor
  count ≤2 (Lemma 3.2(2)), `{x,t}` fixed — NOT a projection tower.

**G6 Amendment (BINDING in v4 — carried from task 311 plan v3):** G6's carrier **SHAPE is
unchanged** (two-anchor bracket, FIXED endpoints `{x,t}`, `w` a bracket WITNESS, never a navigated
point characteristic, never an interior-existential-witness evaluation, never a third free anchor).
What is **amended** is ONLY the parenthetical codomain: `VecEA2 1` (one interval witness) becomes
witness-growing `VecEA2 n`, assembled as a `VVecEA2` finite disjunction (`Σ n, VecEA2 n` disjuncts,
VecEAFormula:271). Anchors stay `{x,t}` (2, fixed); `w` is one bracket witness among
`1 + #(interior-positive (zone, χ) pairs)`. Refutation justification (the concrete counterexample the
codomain change required): the dense-order counterexample at NfMultiAnchorBridge:1782-1796 shows a
`BracketFormula 1` codomain cannot host the interior-positive witnesses. Rabinovich license:
Lemma 3.2(2) (PDF p.4) caps ANCHORS not witnesses; §5 bracket (p.7) carries `n` witnesses between two
fixed endpoints; Lemma 3.4 (p.5) ∃-closure joins each absorbed existential to the prefix as a witness.
**G2/G4 survive unamended: no third ANCHOR ever.**

- **Corrected Anchor-Cap Statement** — the hook-discharge path MUST keep the anchor set at `{x,t}`
  (≤2) by the bracket-witness mechanism, NOT by `nf_char3_deeper_split` (NfMultiAnchorBridge:625-642,
  which grows arity 3→4 and anchors `{x,t}→{y,x,t}` — forbidden tower).

**Rules N1-N5 (VERBATIM from task 311 plan v3):**

- **N1 (caveat C1)** — In every NEW doc-comment and chain-step comment, do NOT cite Prop 3.5 alone for
  the two-fixed-endpoint bracket. Required split: **Prop 3.5 (p.5)** = the one-free-variable
  ∃-witness→Until/Since folding *mechanism*; **Lemma 3.2(2) (p.4) + §5 bracket notation (p.7)** = the
  two-fixed-endpoint `(z_0,z_1)` framing.
- **N2 (caveat C2)** — For the gate-corollary rewrite step, cite the **Def 4.1 p.6 note** for the
  "innermost fold / iteration" reading and **Prop 4.3 (p.6)** only for "the residual is ∨∃∀ over E[Σ]
  atoms"; the comment must note that the codebase realizes Prop 4.3's content locally via the fold, not
  via literal structural induction (305 report 14).
- **N3 (caveat C4)** — Any verdict/milestone doc-comment MUST lead with the Def 3.1 evidence: α_j/β_j
  are one-variable quantifier-free formulas, so the arity-4 residual `[x_1,w,x,t]` had no Rabinovich
  counterpart — a Lean `nf_eval_nf` arity-growth artifact; the fold restores Def-4.1 fidelity.
- **N4 (from the NO-GO record :1767-1796)** — Interior-positive `(zone, χ)` content MUST be encoded as
  bracket WITNESSES ordered between the fixed endpoints (occupying `pointTypes` slots of the
  `BracketFormula n`), NEVER as `bracketBuildLeft`/`bracketBuildRight` chains anchored at an
  existential point of an endpoint TYPE. Interior-positive chains anchored at `∃ z0 < w` of the
  endpoint type are REFUTED (dense-order counterexample). `bracketBuildLeft/Right` remain valid ONLY
  where the anchor genuinely is the fixed endpoint (the zPastX/zFutT endpoint literals in `epL`/`epR`).
- **N5 (arrangement disjunction)** — The model-dependent ORDER of interior-positive witnesses is
  handled by a FINITE DISJUNCTION over linear arrangements inside `VVecEA2.disjuncts` (Rabinovich's ∨
  over consistent order types, Def 3.1 / §5) — never by asserting a fixed order and never by an
  order-erasing shortcut. Distinctness of realizing points for DISTINCT complete 1-types comes from
  `nf_eval_unique` (NormalForm:245); same-type multiplicity is NOT encoded (one witness per positive
  `(zone, χ)` pair suffices).

**Do NOT:**
- Do NOT resurrect the plan-v2 `endChar`/`EndCharCarrier`/`seg`/`seg_holds_*` route or report 02's
  "build the arity-4→3 collapse brick" recommendation. The code is retained (Abandoned Route below), OFF
  the live path, MUST NOT be built on.
- **Do NOT redefine the fold, the transport, or the gate corollary.** Consume `nf_eval_efold`,
  `efold_of_nf1`, `nf_eval_nf1_iff_efold`, `nf_quant_layer_fold_k1_gate`, and the split kit from
  `NfEFold` BY NAME. Any local re-derivation is a defect (task 311 Do-NOT list).
- **Do NOT reconstruct the arity-4 residual.** Any goal showing env `[x_1, w, x, t]` (arity 4) not
  immediately routed through `nf_quant_layer_fold_k1_gate` (NfEFold:525) is the OLD NO-GO shape —
  rewrite via the gate corollary BEFORE splitting the `∃ w` (G4, Corrected Anchor-Cap).
- Do NOT route hook discharge through `nf_char3_deeper_split` (grows the anchor set 3→4).
- Do NOT trust the v1 route-audit comments at NfMultiAnchorBridge:661,:676-678 (false against
  `nf_char3_deeper_split`'s statement).
- Do NOT edit `nf_zone_flatten_navigable` inner-`w` trivial-top exterior brackets or
  `nf_char2_diag_exist_tl` (:190) exterior brackets (D4 — sound as-is).
- **Do NOT grow the ANCHOR count.** The V-carrier's `holds` signature stays two-point (VecEAFormula:276);
  endpoints `{x,t}` FIXED (Lemma 3.2(2), ≤2). Witness growth is licensed (G6 amendment); anchor growth
  is not (G2/G4).
- **Do NOT encode interior-positive bits as type-anchored chains** (rule N4 — refuted device).
- Do NOT modify `bracketEndChar_k1v`/`_correct`, `bracketEndChar_k0`/`_correct`, either NO-GO record,
  or any task-310/311 landed asset. R3 ADDS a depth-`k` generalization consuming these; it does not
  edit them.
- Do NOT introduce any domain axiom or leave any sorry in new material past the phase that owns it
  (sole exception: an explicitly documented strategic-sorry + `follow_up_task`).
- Do NOT reintroduce an import cycle. The two new import edges (P6.1; NfEFold at Bridge:2) are landed.

**MUST preserve:**
- All Preserved/Live Assets above (sorry-free, axiom-clean), including Phases 1-5, P6.1, Phase 9, and
  all task-310/311 landed material (`NfEFold.lean` and the k1v carrier + kit byte-identical).
- The `:354` live-path sorry stays (out of scope; task 305).
- Existing full-tree build green.

**Design decisions are SETTLED** (do not re-open without a concrete counterexample):
- The constructive `A` is the Rabinovich Prop 3.5 / Cor 5.4 bracket `F_i` chain (report 03 VERDICT).
- The recursion carrier is the **two-anchor witness-growing `VVecEA2` bracket characteristic** (G6
  as amended), NOT the navigated arity-3 `endChar` (refuted), NOT the fixed `VecEA2 1` (refuted 311 P2).
- The quant layer is discharged ONLY via the E[Σ]-fold (`nf_quant_layer_fold_k1_gate` /
  `nf_eval_nf1_iff_efold`, task 310) — the vindicated route (R2 = GO).
- The recursion base is the sorry-free depth-0 `bracketEndChar_k0_correct`; the recursion step template
  is the sorry-free k=1 `bracketEndChar_k1v_correct` (R2 = GO).
- The `:351` rewire (R4) is live (D1); Phases 1-5 stay off the live import path except as R4 consumers.

## Goals & Non-Goals

**Goals:**
- Generalize the k=1 V-carrier definition to a depth-`k` V-carrier `bracketEndChar_kv`
  (`BracketEndCharCarrierV sig k`) threading the E[Σ]-fold at each depth (R3a).
- Prove `bracketEndChar_kv_correct : BracketCarrierCorrectV (bracketEndChar_kv …)` for all `k` by
  recursion on `k` — base = `bracketEndChar_k0_correct`, step = the k=1 template lifted via the fold
  (R3b). No arity-4 residual at any depth (route every `qnf.2` read through the fold).
- Discharge the four hooks via the depth-`k` V-carrier + bounded ∃-closure, rewire `KampPrior:351` to
  the three-way disjunction via `nf_zone_exists_trichotomy_k1`, close the `:351` sorry (live sorries
  2 → 1), full `lake build` GREEN, axioms exactly `[propext, Classical.choice, Quot.sound]` (R4).

**Non-Goals:**
- Closing `:354` (task 305 scope).
- Building or repairing the abandoned `endChar`/`seg` route (off live path; retained only).
- Re-encoding or re-deriving the E[Σ]-fold (task 310 deliverable — consumed by name, never redefined).
- Re-running the k=1 gate (task 311 GO is settled; consumed as the R3b step template).
- Any `nf_char3_deeper_split`-based discharge (anchor-tower forbidden).
- No same-type witness multiplicity encoding (fold bits existential; one witness per positive pair — N5).

## Risks & Mitigations

- **Risk (High; R3b concentration)**: the depth-`k` recursion is the difficulty concentration. Each
  step must fold `nf_eval_nf M (k+1) 3 [w,x,t] qnf`'s quant layer through the E[Σ]-fold so the residual
  stays MONADIC — the same move the k=1 step proved. **Mitigation**: the base
  (`bracketEndChar_k0_correct`) and the step template (`bracketEndChar_k1v_correct`, R2 = GO) are both
  landed sorry-free; R3b transcribes the k=1 proof structure with `k` in place of `1`, invoking the
  general-`n` fold engine `nf_quant_layer_fold_iff` (NfEFold:391) rather than the k=1 gate corollary
  where the depth is symbolic. Pre-authorized R3b split at the base-wiring / step-fold seam (13a/13b).
- **Risk (Medium; witness-count generalization)**: the arrangement-disjunction machinery
  (`bracketFromLists`, `k1v_sorted_insert`/`_realization`/`k1v_bracket_construct`) is stated at k=1;
  the depth-`k` lift must generalize the point/interval TYPES from `char (k=0)` to `char_k1 (k)` while
  keeping the SAME arrangement structure. **Mitigation**: the arrangement structure is depth-agnostic
  (it enumerates interior-positive `(zone, χ)` pairs of the fold output, whose count is
  per-signature-bounded at every depth); only the fold entry point and the point-type provider change.
  Reuse the k1v helper kit; parameterize the point type by `char_k1` (KampPrior:307).
- **Risk (recurring; the churn root)**: a dispatch trusts a stale route-audit comment and re-attempts
  the `endChar` navigated carrier, the `nf_char3_deeper_split` anchor tower, or a raw `nf_eval_nf`
  recursion that re-forms the arity-4 residual. **Mitigation**: G6-as-amended + the Corrected Anchor-Cap
  + the "Do NOT reconstruct the arity-4 residual" rule carry into every dispatch; every `qnf.2` read
  goes through `efold_of_nf1` / the gate corollary.
- **Risk**: R4 puts the carrier on the live path and surfaces a latent axiom leak. **Mitigation**: R4
  runs a full-tree build + `#print axioms` / `lean_verify` as explicit criteria; the newly-live subtree
  is grep-verified sorry-free.
- **Risk**: G5 literature-fidelity violated by a tactic shortcut. **Mitigation**: each chain step in
  R3/R4 cites Rabinovich PDF p.4-7 with the N1/N2 splits; no `simp`/`omega`/`aesop` on a chain step.

## Implementation History (landed / abandoned — NOT open work)

These sections are history. None match the orchestrator open-phase heading-scan
(`^### Phase [0-9]+(\.[0-9]+)?: .*\[(NOT STARTED|PARTIAL|IN PROGRESS)\]`). Do not re-dispatch them.

### Phase 1: Segment-carrying A_past / A_future + _correct [COMPLETED]

Landed, commit f4b9600a1. Segment-carrying `A_past`/`A_future` (NfZoneFlattenNavigable:335/:386) via
`bracketBuildLeft/Right_correct` (Rabinovich `β_i`). Sorry-free. Live consumer in R4. History only.

### Phase 2: Off-diagonal atom layer for [x,t] [COMPLETED]

Landed, commit 762ea60da. `nf_char2_atom_offdiag_{origin,endpoint,correct}`
(NfMultiAnchorBridge:364/:375/:391), `order 0 1 = true`. Sorry-free; axioms clean. Consumed in R4
depth-0 atom decomposition. History only.

### Phase 3: Arity-3 endpoint-hook construction [COMPLETED]

Landed, commit 010ab616d. `nf_char3_endpoint_tl` + `_correct` (NfMultiAnchorBridge:891/:907), the
hook-parametric endpoint SHAPE (NOT the carrier). Sorry-free. History only.

### Phase 4: nf_char2_past_formula + _correct (F_i chain past arm) [COMPLETED]

Landed, commit fed9fcd8e. `nf_char2_past_formula` + `_correct` (NfMultiAnchorBridge:992/:1015), RHS
under `h_quant` (:1023-1026). Sorry-free. `h_quant` discharged in R4 via the V-carrier. History only.

### Phase 5: nf_char2_future_formula + _correct (F_i chain future dual) [COMPLETED]

Landed, commit b60c63b1a. `nf_char2_future_formula` + `_correct` (NfMultiAnchorBridge:1185/…), dual RHS
under dual `h_quant` (:1223-1226). Sorry-free. Discharged in R4. History only.

### Phase 6.1: Cycle-safe import edge (NfMultiAnchorBridge → KampPrior) [COMPLETED]

Landed, commit f3827e255. `import …Kamp.NfMultiAnchorBridge` in `KampPrior.lean` (D1, cycle-safe).
Full-tree GREEN. History only — do not re-add/move.

### Plan-v2 Phases 6-8 (endChar0 / EndCharCarrier / seg / seg_holds_*) [ABANDONED ROUTE — code retained, off live path]

Commits 131615736, 88a785d96, 901484b9c, f663811bb, 310ab8652, 8d8ce7dbf. The navigated arity-3
endpoint route. **Plan-v2 Phase 8 went [BLOCKED]** on the arity-4 → arity-3 re-bounding obstruction —
now root-caused (report 04) to `nf_eval_nf`'s per-depth arity growth, an ENCODING artifact. Per report
03: do NOT delete this code, do NOT build on it, do NOT resurrect the "build the collapse brick"
recommendation. Inert, off-live-path. History only.

### Phase 9: Two-anchor VecEA2 bracket carrier reformulation + interface (R1) [COMPLETED]

Landed (309 P9). `BracketEndCharCarrier`/`BracketCarrierCorrect`/`bracketEndChar_k0`/`_correct`
(NfMultiAnchorBridge:1542/1552/1563/1577), the two-anchor carrier interface + depth-0 base with six
k0-mirror order hypotheses (:1581-1594). Sorry-free. The R1 SHAPE — carried forward and amended to the
witness-growing V-variant in Phase 11 (via task 311). History only.

### Phase 10: k=1 de-risking probe — DECISION GATE (R2) [COMPLETED — NO-GO, superseded by Phase 11]

Landed (309 P10; session sess_1783359214_93fd70). The decision-gate probe of the fixed `VecEA2 1`
carrier at `k=1` **completed** and returned **R2 = NO-GO**: the `k=1` fold left an irreducible arity-4
residual `[x_1,w,x,t]` (the plan-v2 Phase-8 obstruction, falsified at k=1 in one bounded dispatch). The
gate did its job — it root-caused the obstruction and triggered a `/spawn` (report 04). **This NO-GO is
SUPERSEDED by Phase 11**: report 04 established the residual is an `nf_eval_nf` ENCODING artifact (not a
carrier-shape defect); spawned tasks 310 (E[Σ]-fold) + 311 (k=1 re-probe) then re-closed the gate as
**R2 = GO** under the fixed-arity fold + the witness-growing V-carrier. The probe left
NfMultiAnchorBridge.lean sorry-free and green; no partial/vacuous carrier was committed. History only —
the NO-GO verdict is closed, not open work.

### Phase 11: Prerequisite gate closure via tasks 310 + 311 (E[Σ]-fold + k=1 V-carrier GO) [COMPLETED]

Landed via the two spawned prerequisite tasks (both COMPLETE), folded into 309 by this v4 revision.
This is the integration record; the code exists in the working tree, sorry-free, off the 309 live path
until wired by R4.

- **Task 310** — `Kamp/NfEFold.lean` (the E[Σ]-fold encoding, Rabinovich Def 4.1): a fixed-arity monadic
  fold defined alongside `nf_eval_nf`, proved equivalent for the arity-3 two-anchor shape `[w,x,t]`.
  Load-bearing: `nf_eval_efold` (:102), `efold_of_nf1` (:472), `nf_eval_nf1_iff_efold` (:490),
  `nf_quant_layer_fold_k1_gate` (:525), general engine `nf_quant_layer_fold_iff` (:391), split kit
  (:153-235). Sorry-free; axioms exactly `[propext, Classical.choice, Quot.sound]`.
- **Task 311** — the G6-AMENDED witness-growing carrier + the k=1 GO. `BracketEndCharCarrierV` (:1855),
  `BracketCarrierCorrectV` (:1864), `bracketFromLists` (:1883), `bracketEndChar_k1v` (:1923),
  `bracketEndChar_k1v_sound` (:2325), `bracketEndChar_k1v_complete` (:2966), the k1v helper kit
  (:2028/2052/2137/2255/2682-2825), and the assembled **`bracketEndChar_k1v_correct` (:3378)** with the
  **R2 = GO** verdict record (:3394-3434). The k=1 correctness `↔` closed with NO arity-4 residual and
  NO navigated arity-3 characteristic; anchors `{x,t}` (TYPE invariant of `VVecEA2.holds`). The fixed
  `VecEA2 1` codomain was refuted (dense-order counterexample :1750-1823) and amended to `VVecEA2`.
  Sorry-free; axioms exactly `[propext, Classical.choice, Quot.sound]`; full tree GREEN (1705 jobs).
- **Integration effect on 309**: the R2 decision gate is now **GO**. Path B is viable at `k=1` under the
  fold + witness-growing carrier. The remaining 309 work (R3a/R3b/R4 below) lifts the k=1 template to
  depth `k` and wires it onto the live path. History only — do not re-dispatch tasks 310/311.

## Implementation Phases (Open — R3a / R3b / R4)

**Dependency Analysis**:

| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 12 (R3a) | -- (consumes landed assets only) |
| 2 | 13 (R3b) | 12 |
| 3 | 14 (R4) | 13 |

Phases 12→13→14 are strictly sequential (each consumes the previous phase's declarations by name, and
all edit `NfMultiAnchorBridge.lean` / `KampPrior.lean` single-file territory, one owner per dispatch).
One agent run per phase (H8). The orchestrator dispatches exactly one open phase per cycle by
heading-scan; Phases 12-14 are the only open headings.

### Phase 12: Depth-k V-carrier definition `bracketEndChar_kv` (R3a) [NOT STARTED]

- **Goal:** Generalize the k=1 V-carrier definition `bracketEndChar_k1v` (NfMultiAnchorBridge:1923) to
  a depth-`k` V-carrier `bracketEndChar_kv : BracketEndCharCarrierV sig k`, threading the E[Σ]-fold at
  depth `k` and using `char_k1` (KampPrior:307, the depth-`k` E[Σ]-atom) as the point/interval type
  provider instead of the k=0 `char`. This is a definitional + typechecking phase; the correctness
  proof is Phase 13.
- **Deliverables (exact names/signatures):**
  - `noncomputable def bracketEndChar_kv … : BracketEndCharCarrierV sig k` — mirroring
    `bracketEndChar_k1v` (:1923) structurally: fold bits read via `efold_of_nf1` / the general fold
    engine at depth `k`; interior-positive enumerations `S_L`/`S_R` over the depth-`k` fold output;
    witness point type = `char_k1`-based (not `char`); disjuncts via `bracketFromLists` (:1883) over
    `S_L.permutations × S_R.permutations`; endpoint literals `epL`/`epR` at the FIXED endpoints (N4);
    gate = off-fiber falsity + order-conflict falsity; gate-failure branch = `⟨[]⟩`.
- **File targets:** `Theories/Bimodal/.../Kamp/NfMultiAnchorBridge.lean` (additive, after the landed
  k1v material; new depth-`k` def alongside — not replacing — `bracketEndChar_k1v`).
- **Consume, do NOT rebuild:** `bracketEndChar_k1v` (:1923, the depth-1 template); `bracketFromLists`
  (:1883); `efold_of_nf1`/`nf_eval_efold`/the fold split kit (NfEFold:472/102/153-235); `char_k1`
  (KampPrior:307, the depth-`k` point type); `VVecEA2`/`VecEA2` (VecEAFormula:271/252). Do NOT consume
  the abandoned `endChar`/`seg`; do NOT consume `nf_char3_deeper_split`; do NOT redefine any NfEFold
  asset; do NOT modify `bracketEndChar_k1v`.
- **Acceptance criteria:** `lake build` GREEN full tree; `bracketEndChar_kv : BracketEndCharCarrierV
  sig k` typechecks sorry-free; codomain is `VVecEA2` (witness-growing; grep confirms no `VecEA2 1`
  regression); anchors provably `{x,t}` (2, fixed — G4/G6, the `VVecEA2.holds` two-point signature);
  `k=1` specialization is defeq/propositionally equal to `bracketEndChar_k1v` (or a documented `simp`
  bridge lemma is provided so Phase 13's base/step can reuse the k1v proof); 0 new sorries; no vacuous
  definition; `lean_verify bracketEndChar_kv` = `[propext, Classical.choice, Quot.sound]`; doc-comment
  carries the N1 split + N4 flag + N5 arrangement-disjunction citation + the G6-amendment reference.
- **Estimated lines:** 80-150 (one agent run; H8).
- **Guards enforced:** G2, G4, G6-as-amended (the type is the invariant), N1, N4, N5.
- **Commit:** `task 309 phase 12: depth-k V-carrier definition bracketEndChar_kv (R3a)`

### Phase 13: Depth-k V-carrier correctness `bracketEndChar_kv_correct` (R3b) [NOT STARTED]

*(Dispatch ONLY after Phase 12 lands green.)*

- **Goal:** Prove `bracketEndChar_kv_correct : BracketCarrierCorrectV (bracketEndChar_kv …)` for all
  `k` — i.e. `(bracketEndChar_kv … qnf).holds M atomMap x t ↔ ∃ w, nf_eval_nf M k 3 (Fin.cons w
  (Fin.cons x (fun _=>t))) qnf` (k0-mirror conditional form, six bracket-zone order hypotheses on
  `qnf.1`) — by recursion on `k`. Base = `bracketEndChar_k0_correct` (:1577). Step = transcribe the
  sorry-free `bracketEndChar_k1v_correct` (:3378, R2 = GO) proof structure with symbolic `k` in place
  of `1`, routing the quant layer through the general fold engine `nf_quant_layer_fold_iff`
  (NfEFold:391) so the residual stays MONADIC over env `[w,x,t]` — NO arity-4 residual at any depth,
  NO navigated arity-3 characteristic.
- **Deliverables (exact names/signatures):**
  - `theorem bracketEndChar_kv_correct : ∀ {k} (qnf …) …, (bracketEndChar_kv … qnf).holds M atomMap x t
    ↔ ∃ w, nf_eval_nf M k 3 (Fin.cons w (Fin.cons x (fun _=>t))) qnf` (recursion on `k`), plus the two
    direction lemmas `bracketEndChar_kv_sound` / `_complete` (mirroring `bracketEndChar_k1v_sound`
    :2325 / `_complete` :2966).
- **File targets:** `Theories/Bimodal/.../Kamp/NfMultiAnchorBridge.lean` (additive, after Phase 12).
- **Consume, do NOT rebuild:** `bracketEndChar_k0_correct` (:1577, base); `bracketEndChar_k1v_correct`
  (:3378, step template); `bracketEndChar_k1v_sound`/`_complete` (:2325/:2966, direction templates);
  the k1v helper kit (`k1v_zoneHolds_cons_iff` :2028, `k1v_zone_consistent` :2052, `k1v_bracket_extract`
  :2137, `k1v_reconstruct_nf3` :2255, `k1v_sorted_insert`/`_realization`/`k1v_bracket_construct`
  :2682-2825); the fold engine `nf_quant_layer_fold_iff` (NfEFold:391) + `efold_of_nf1` (:472) +
  `nf_eval_nf1_iff_efold` (:490); `nf_eval_unique` (NormalForm:245) / `nfPred_correct` (NfToVecEA:69,
  NOT KampPrior:168); `existsBounded_right` (VecEAClosure:265, witness-append template). Do NOT consume
  `nf_char3_deeper_split`; do NOT redefine any fold asset; do NOT reconstruct the arity-4 residual.
- **Acceptance criteria:** `lake build` GREEN full tree; `bracketEndChar_kv_correct` typechecks against
  `nf_eval_nf M k 3 [w,x,t] qnf` for all `k`; 0 new sorries (or a documented strategic-sorry +
  `follow_up_task`); `lean_verify bracketEndChar_kv_correct` = `[propext, Classical.choice, Quot.sound]`;
  anchors provably `{x,t}` at every recursion depth (G4/G6); the quant layer is folded through the
  E[Σ]-fold at every step (grep confirms `nf_quant_layer_fold` usage; no raw `nf_eval_nf M (k+1)` split
  that re-forms the arity-4 residual — the "Do NOT reconstruct the arity-4 residual" rule); each chain
  step cites Rabinovich PDF p.4-7 with the N1/N2 splits (G5, no simp/omega/aesop shortcut).
- **H8 split note:** if it overruns one agent run, split at the base-wiring / step-fold seam (13a =
  soundness + base wiring; 13b = completeness + assembled `↔`), mirroring task 311's 5.1/5.2 split.
- **Estimated lines:** 150-250 (one agent run; H8; the difficulty concentration).
- **Guards enforced:** G1, G3, G4, G5, G6-as-amended, N1-N5.
- **Commit:** `task 309 phase 13: depth-k V-carrier correctness bracketEndChar_kv_correct (R3b)`

### Phase 14: Discharge four hooks + KampPrior:351 rewire + full-tree axiom check (R4) [NOT STARTED]

*(Dispatch ONLY after Phase 13 lands green. This phase delivers the task goal.)*

- **Goal:** Use the Phase-13 depth-`k` witness-growing V-carrier to **discharge the four deferred
  hooks** — `h_quant` (past, NfMultiAnchorBridge:1023-1026), `h_quant` (future, :1223-1226), and
  `h_past`/`h_fut`/`h_diag` (`A_diag_correct`, :787-795) — then rewire `KampPrior.lean:351` to the
  three-way disjunction `A := nf_char2_past_formula … ∨ A_diag … ∨ nf_char2_future_formula …` via
  `nf_zone_exists_trichotomy_k1` and a three-way `or_congr`, closing the `:351` sorry (live sorries
  2 → 1; `:354` stays, task 305). Mechanically: at `:351` the goal is `∃ A, temporal_truth t A ↔ ∃
  env:Fin 1, nf_eval_nf M (k+1) 2 (insertEnv env t) sub_nf`; bridge `env:Fin 1` to `∃x` (existing
  `h_env_eq` shape, KampPrior:277-291); decompose `nf_eval_nf M (k+1) 2 [x,t]` into its depth-0 atom
  layer (`nf_char2_atom_offdiag_correct`, P2) and, per arity-3 sub `qnf`, the inner existential closed
  by the Phase-13 carrier (`bracketEndChar_kv_correct` + Lemma 3.4 / `existsBounded_right`
  VecEAClosure:265); assemble via the fold and feed the three arms through the `or_congr` with
  `nf_char2_past_formula_correct` / `A_diag_correct` / `nf_char2_future_formula_correct`.
- **Deliverables:**
  - Proofs of the four hooks (`h_quant` past+future, `h_past`/`h_fut`/`h_diag`) at the call site,
    discharged via the Phase-13 carrier + `existsBounded_right` + `nf_zone_flatten_navigable_correct`.
  - The three-way disjunction `A` and the closed `:351` arm of `nf_nvar_exist_all_depths` (rewired via
    `nf_zone_exists_trichotomy_k1` three-way `or_congr`).
- **File targets:** `Theories/Bimodal/.../Prior/KampPrior.lean` (`:351` arm; local hook wiring
  KampPrior:264-320). The import edge is already landed (P6.1) — do NOT re-add it.
- **Consume, do NOT rebuild:** Phases 4/5 `nf_char2_{past,future}_formula`/`_correct`; `A_diag`/`_correct`
  (NfMultiAnchorBridge:763/:808); `A_past`/`A_future`/`_correct` (P1); `nf_char2_atom_offdiag_correct`
  (P2); `nf_zone_exists_trichotomy_k1` (NfZoneFlattenNavigable:188); `nf_zone_flatten_navigable(_brick)`/
  `_correct` (NfMultiAnchorBridge:689/:709); the Phase-13 `bracketEndChar_kv`/`_correct`;
  `existsBounded_right` (VecEAClosure:265); the E[Σ]-fold assets (NfEFold); local `char_k1` / `ih_exist_1`
  (KampPrior:264-320) for the `Fin 1 → ∃x` bridge. Do NOT consume the abandoned `endChar`/`seg`; do NOT
  consume `nf_char3_deeper_split`.
- **Acceptance criteria (definition of done):**
  - Full-tree `lake build` GREEN.
  - `#print axioms` (or `lean_verify`) on the rewired `nf_nvar_exist_all_depths` live-path theorem =
    exactly `[propext, Classical.choice, Quot.sound]` (0 domain axioms).
  - Live-path sorry count reduced 2 → 1: `:351` closed; `:354` deliberately remains (task 305).
  - `grep "sorry"` across the new material (R3a/R3b/R4) shows only docstring/comment hits (no code
    sorries; sole exception: an explicitly documented strategic-sorry with a `follow_up_task`).
  - Task 307 Phase 7 wiring verification is unblocked (report the unblock; do not execute it here).
- **Estimated lines:** 60-120 (one agent run; H8).
- **Guards enforced:** G1, G3, G4, G5, G6-as-amended; D1 (import edge already landed); final sorry +
  axiom discipline; N1-N5.
- **Commit:** `task 309 phase 14: discharge hooks + rewire KampPrior:351 + axiom check (R4)`

## Testing & Validation

- After each phase: `lake build` for the touched file and its dependents; grep for new `sorry`.
- Per-phase axiom check (`#print axioms` / `lean_verify`) on the phase's new `_correct` lemma: exactly
  `[propext, Classical.choice, Quot.sound]`.
- **Anchor-cap check (every phase)**: every new `holds` obligation is at the two-point signature
  `(x, t)`; witness growth occurs only inside `BracketFormula n` / `Σ n, VecEA2 n` (G2/G4/G6-amended).
- **Arity-4 residual guard (R3b)**: inspect the folded goal to confirm the quant layer stays MONADIC
  over `[w,x,t]` at every recursion depth (no `[x_1,w,x,t]` env not routed through the fold).
- Phase R4 gate (definition of done):
  - Full-tree `lake build` GREEN.
  - `#print axioms` on the rewired live-path theorem: exactly `[propext, Classical.choice, Quot.sound]`,
    0 domain axioms.
  - Live-path sorry count reduced 2 → 1 (`:351` closed; `:354` remains).
  - `grep "sorry"` across new material (R3a/R3b/R4): only docstring/comment hits (or a single documented
    strategic sorry with a `follow_up_task`).
- Regression: task 307 Phase 7 wiring verification is unblocked (report the unblock, do not execute here).

## Artifacts & Outputs

- `Theories/Bimodal/.../Kamp/NfMultiAnchorBridge.lean` — depth-`k` V-carrier `bracketEndChar_kv` (R3a),
  depth-`k` correctness `bracketEndChar_kv_correct` + direction lemmas (R3b). The abandoned `endChar`/
  `seg` defs, both NO-GO records, and the task-310/311 landed material remain in this file / `NfEFold.lean`,
  byte-identical and off the live path until wired by R4.
- `Theories/Bimodal/.../Prior/KampPrior.lean` — hook discharge + rewired `:351` arm (R4).
- Up to three scoped commits (`task 309 phase 12/13/14: …`), continuing the P1-P5 + P6.1 + P9 history.

## Rollback/Contingency

- Each phase is a scoped commit; revert the last commit to roll back a single phase without disturbing
  earlier green milestones (H9 incremental-commit discipline).
- Phases 1-5, the P6.1 import edge, Phase 9, and all task-310/311 material are landed and green; the
  abandoned-route code is inert. If a later phase surfaces an unexpected build or axiom problem, roll
  back to the prior green commit — the `:351` sorry simply remains until the carrier lands, with no
  downstream regression.
- **Second-refutation contingency (R3b)**: if the depth-`k` lift surfaces an unforeseen obstruction not
  present at k=1, apply the same DECISION-GATE discipline as task 311 — machine-probe the failing leaf
  (`lean_goal`/`lean_multi_attempt`), record the verdict either way, land no partial theorem and no
  sorry, and escalate with the goal state. The escalation fence (audit caveat C3) bars any
  implementer-level anchor growth; anchors stay `{x,t}` (2, fixed) under all circumstances.
- If R3b overruns the H8 dispatch budget, split at the base-wiring / step-fold seam (13a/13b) rather
  than inflating a single dispatch.
