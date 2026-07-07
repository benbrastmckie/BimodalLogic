# Implementation Plan: Off-Diagonal Two-Anchor F_i Chain (task 309) — v6

- **Task**: 309 - offdiag_two_anchor_fi_chain
- **Status**: [IMPLEMENTING]
- **Effort**: ~12-18 hours (Phases 1-5 + 6.1 + 9 + 10 + 11 + 12 landed; v5 Phase 13 refuted by F1 and RETIRED; 6 open phases 13.0/13.1/13.2/13.3/13.4/14, ~760-1280 lines Lean incl. two decision gates)
- **Dependencies**: 310 (COMPLETE — `Kamp/NfEFold.lean` E[Σ]-fold landed sorry-free); 311 (COMPLETE — k=1 V-carrier `bracketEndChar_k1v_correct` GO, sorry-free)
- **Research Inputs**:
  - reports/01_offdiag-fi-chain-research.md (H4-verified, Tier 1; source for the outer wrapper + import DAG)
  - reports/02_endpoint-hook-discharge-research.md (background only — "build the collapse brick / endChar" recommendation SUPERSEDED and adversarially OVERTURNED by report 03)
  - reports/03_rabinovich-faithful-path-research.md (Path B carrier reformulation; R1-R4 decomposition; the two-anchor bracket carrier authority)
  - reports/04_spawn-analysis.md (v4 revision authority — R2 k=1 NO-GO root-cause; spawned tasks 310 + 311)
  - reports/05_k2-vocab-enrichment-redesign.md (**REVISION AUTHORITY for v6** — H4-verified k≥2 redesign after finding F1; route (a)-(d) is the settled direction: UZ/SZ-relativized provider-conditional target `BracketCarrierCorrectVPrior`, per-sub enriched carrier `bracketEndChar_kvE`, F2 decision probe first, guard amendments A1/A2)
- **Artifacts**:
  - plans/01_offdiag-fi-chain-plan.md (v1, superseded)
  - plans/02_offdiag-fi-chain-plan.md (v2, superseded — endChar/seg route [ABANDONED ROUTE])
  - plans/03_offdiag-fi-chain-plan.md (v3, superseded — Phase 10 R2 NO-GO handoff superseded by v4)
  - plans/05_offdiag-fi-chain-plan.md (v4/v5, superseded — Phase 13 target refuted by F1; superseded by this v6)
  - plans/06_offdiag-fi-chain-plan.md (this file, v6)
- **Standards**:
  - .claude/rules/artifact-formats.md
  - .claude/rules/state-management.md
  - .claude/rules/plan-format-enforcement.md
  - .claude/context/formats/plan-format.md
- **Type**: lean4 (hard-mode; H8 phase sizing, postmortem constraints, wave declarations)
- **reports_integrated**: 01_offdiag-fi-chain-research.md, 02_endpoint-hook-discharge-research.md, 03_rabinovich-faithful-path-research.md, 04_spawn-analysis.md, 05_k2-vocab-enrichment-redesign.md

## Overview

Build the off-diagonal (`x ≠ t`) two-anchor navigated characteristic — the Rabinovich Prop 3.5 /
Cor 5.4 `F_i` chain — so `KampPrior.lean:351` can be discharged (live sorries 2 → 1; `:354` stays,
task 305 scope). Definition of done: full `lake build` GREEN, `#print axioms` on the rewired
live-path theorem `nf_nvar_exist_all_depths` = exactly `[propext, Classical.choice, Quot.sound]`
(0 domain axioms), all new material sorry-free, task 307 Phase 7 unblocked.

**Plan lineage (v1 → v2 → v3 → v4/v5 → v6).**
- **v1** — original outer-wrapper + navigated-characteristic route (Phases 1-5, 6.1 landed).
- **v2** — navigated arity-3 endpoint characteristic `endChar` (Phases 6-8); Phase 8 went [BLOCKED]
  on an arity-4 → arity-3 re-bounding obstruction. [ABANDONED ROUTE], code retained off the live path.
- **v3** — Path B pivot (report 03): two-anchor VecEA2 bracket carrier; R1 landed (Phase 9); k=1 gate
  (Phase 10, R2) returned NO-GO, root-caused (report 04) to `nf_eval_nf` per-depth arity growth.
- **v4/v5** — folded the spawned prerequisites (tasks 310 + 311, both COMPLETE) back into 309:
  E[Σ]-fold + k=1 V-carrier GO. Phase 12 (R3a, depth-`k` carrier definition `bracketEndChar_kv`)
  landed. **Phase 13 (R3b) went [BLOCKED] on finding F1** (NfMultiAnchorBridge.lean:3871-3934,
  machine-checked via `bracketEndChar_kv_factors` :3838): the unconditional ∀k correctness `↔` for
  the Phase-12 fiber-existential carrier is FALSE at k=2 — the carrier factors through
  `(qnf.1, off-fiber Prop, fiber bits)` and discards joint deeper structure of the fresh witness
  relative to the anchors.
- **v6 (this revision)** — implements report 05's redesign. Two independent corrections:
  1. **Statement surgery (settled, report 05 F-A)**: the v5 Phase-13 target was stated strictly
     stronger than the `KampPrior:351` consumer needs. The `:351` arm sits inside
     `nf_nvar_exist_all_depths` (KampPrior:212-224) with `h_UZ : semantic_prior_UZ` /
     `h_SZ : semantic_prior_SZ` in scope AND recursive single-anchor existential converters at all
     depths ≤ k, all arities (structural recursion on the first Nat argument; the `n' = 1` call
     already exists at KampPrior:273). The **unconditional ∀k theorem is NOT needed**: the ∀k
     quantifier is discharged by KampPrior's existing `Nat.rec`, not inside the Bridge. The
     corrected R3b target is `BracketCarrierCorrectVPrior` — UZ/SZ-relativized, conditional on an
     `ExistProviders` bundle.
  2. **Carrier redesign for k≥2 (gated by the F2 probe)**: statement surgery alone is very likely
     insufficient — report 05 F-B extends the F1 countermodel to `M* = (ℤ, <)`, `P = {0,10,20}`,
     which SATISFIES UZ/SZ, indicating the fiber-existential carrier stays refuted even
     relativized. F2 is **analysis-only (not machine-checked)**, so v6's first dispatch is a
     formal decision probe (Phase 13.0). If F2 holds, the successor-depth carrier is redesigned as
     `bracketEndChar_kvE` reading `qnf.2` **per-sub** (F1 item 3's required behavior), with
     provider-built temporal formulas in the existing `TemporalPred` slots (no codomain change)
     and per-sub inner existentials flattened as further bracket witnesses (Lemma 3.4 / the
     G6-amendment mechanism); negative-sub exclusion content routes through the landed sorry-free
     EANegationClosure stack keyed on `HasAttainedINF` (bridged from `h_UZ` by
     `prior_hasAttainedINF`, PriorINF:224).

  **Retired deliverable names**: the v5 Phase-13 deliverables `bracketEndChar_kv_correct`,
  `bracketEndChar_kv_sound`, `bracketEndChar_kv_complete` (unconditional forms) are **RETIRED,
  not restated** — refuted at k=2 by F1. Preserved unchanged: the k0/k1v kits, the three landed
  Phase-13 lemmas (`bracketEndChar_kv_correct_zero` :3783, `_one` :3811,
  `bracketEndChar_kv_factors` :3838), `bracketEndChar_kv` itself (kept as the landed k≤1 instance
  and permanent F1 exhibit — NOT edited, NOT consumed at k≥2), the fold engine,
  `VVecEA2`/`bracketFromLists`, and the Phases 1-5 arms.

### Research Integration

reports/05_k2-vocab-enrichment-redesign.md integrated in plan version 6 (2026-07-06). This report
is the AUTHORITY for the v6 revision (H4-verified; adversarial self-verification pass performed;
F-B/F2 explicitly downgraded to analysis-only and mandated as the first dispatch's decision gate).
Its decisive findings, transcribed (not re-litigated):

1. **F-A (verified)**: KampPrior:351 consumes only a UZ/SZ-relativized, provider-conditional
   depth-k correctness at each outer depth k+1. The F1 countermodel `(ℚ,<)` with finite `P`
   violates `semantic_prior_UZ` and never reaches the consumer. Corrected target:
   `BracketCarrierCorrectVPrior` conditional on an `ExistProviders` bundle (the landed
   `nf_succ_char_formula_correct` hypothesis pattern, KampPrior:81-100, moved one arity up).
2. **F-B / proposed F2 (analysis-only, HIGH-confidence but NOT machine-checked)**: the ℤ-extension
   `M* = (ℤ,<)`, `P = {0,10,20}`, `x=2, u₂=4, u₁=12, w=15, t=18` satisfies UZ/SZ and appears to
   refute the relativized statement for the CURRENT carrier at k=2. Mandated as Phase 13.0, a
   formal GO/NO-GO probe — the branch is cheap and high-value either way.
3. **F-C (verified)**: the enrichment vehicle exists at the type level — `TemporalPred` slots hold
   arbitrary `Formula`s (NfMultiAnchorBridge:1886/:1955). Redesign = information-channel change
   (read `qnf.2` per-sub), NOT a codomain change.
4. **F-D (verified)**: a consumable sorry-free Lemma 5.1/Prop 4.2 negation stack exists and was
   absent from the v5 asset table (EANegationClosure.lean :401/:492/:646/:720; `HasAttainedINF`
   PriorINF:202; `prior_hasAttainedINF` PriorINF:224). **Constraint**: these lemmas are
   model-dependent existentials (`∃ v : VVecEA2, v.holds M atomMap z0 z1`), NOT uniform formula
   equivalences — the consuming phase (13.3) must use them proof-side-only (per-model direction
   obligations) or uniformize via finite disjunction over the finitely-generated candidate family.
5. **F-E (verified/analysis)**: rejected alternatives — gate strengthening on the current carrier
   (refuted, F1 item 4 :3922-3928: no model-independent syntactic gate exists); one-jump
   enriched-signature re-indexing (lossy by the F1 pattern one level down); `nf_eval_efold` as
   depth-k semantics (D7, NfEFold:373-375: bridge claimed at depth-0 subs only).
6. **Guard amendments A1 + A2** (report 05 §d) — recorded in Postmortem Constraints below.

reports/01 remains the source for the outer wrapper (Phases 1-5) and the import DAG (Phase 6.1).
reports/02 is retained for background only. reports/03 remains the Path B / carrier-reformulation
authority. reports/04 remains the v4 revision authority (tasks 310/311 integration). v6 does not
re-open any of their verdicts.

### Corrected Anchor-Cap Statement (CARRIED FORWARD; still binding)

**The hook-discharge path MUST keep the anchor set at `{x,t}` (≤2, Rabinovich cap; G2/G4) by the
bracket-witness mechanism (report 03 §3 Path B, as amended by task 311's witness-growth), NOT by
`nf_char3_deeper_split`.** `nf_char3_deeper_split` (NfMultiAnchorBridge:625-642) grows arity 3→4 and
anchors `{x,t}→{y,x,t}` (its statement, :628-637); composing it at each depth-descent builds the
forbidden anchor tower. The v1 route-audit comments at NfMultiAnchorBridge:661,:676-678
("arity ≤3, anchor `{x,t}`") are false and MUST NOT be trusted. Interior witnesses stay **bracket**
witnesses (now possibly several per qnf, per the witness-growth amendment and the v6 per-sub
flattening), recursion is on `k`; anchors strictly `{x,t}` (2, fixed) at every depth.

## Preserved / Live Assets (consume — do NOT rebuild)

Complete, sorry-free, MUST NOT regress. Every open phase (13.0-13.4, 14) consumes from this list
and does not rebuild or edit these.

| Component | File:line | Status | Role in v6 |
|-----------|-----------|--------|------------|
| `A_past` / `A_future` (segment-carrying) + `_correct` | NfZoneFlattenNavigable:335/:386 | Landed P1 | non-trivial-segment outer arms (consumed in Phase 14 or_congr) |
| `nf_char2_atom_offdiag_{origin,endpoint,correct}` | NfMultiAnchorBridge:364/:375/:391 | Landed P2 | off-diagonal atom layer; depth-0 atom decomposition in Phase 14 |
| `nf_char3_endpoint_tl` / `_correct` | NfMultiAnchorBridge:891/:907 | Landed P3 | arity-3 endpoint `TemporalPred` shape (hook-parametric; NOT the carrier) |
| `nf_char2_past_formula` / `_correct` | NfMultiAnchorBridge:992/:1015 | Landed P4 | past-arm F_i wrapper; `h_quant` (:1023-1026) discharged in Phase 14 |
| `nf_char2_future_formula` / `_correct` | NfMultiAnchorBridge:1185/… | Landed P5 | future-arm F_i wrapper; dual `h_quant` (:1223-1226) discharged in Phase 14 |
| `A_diag` / `_correct` | NfMultiAnchorBridge:763/:808 | Landed (task 307 P2) | diagonal `[t,t]` arm; `h_past`/`h_fut`/`h_diag` (:787-795) discharged in Phase 14 |
| `nf_zone_flatten_navigable(_brick)` / `_correct` | NfMultiAnchorBridge:689/:709 | Landed (task 308) | 5-zone `∃w` flatten |
| `nf_zone_exists_trichotomy_k1` | NfZoneFlattenNavigable:188 | Landed (task 307 P3) | `∃x` split into past/diag/future — the Phase 14 three-way `or_congr` seam |
| `nf_3var_bracket_xyt` / `_correct` | VecEADecomp:233/:244 | Landed, sorry-free | the depth-0 witness collapse (atom layer) |
| `char_k1` / `_correct` | KampPrior:307/:310 | Landed, sorry-free | depth-`k` arity-1 point characteristic (E[Σ]-atom, Def 4.1) |
| E[Σ]-fold: `nf_eval_efold` | NfEFold:102 | Landed (task 310) | fixed-arity monadic fold evaluation (Def 4.1) |
| `efold_of_nf1` | NfEFold:472 | Landed (task 310) | fold-of-nf1 transport |
| `nf_eval_nf1_iff_efold` | NfEFold:490 | Landed (task 310) | k=1 whole-eval bridge |
| `nf_quant_layer_fold_k1_gate` | NfEFold:525 | Landed (task 310) | gate corollary (k=1) |
| **general fold engine `nf_quant_layer_fold_iff`** | **NfEFold:391** | **Landed (task 310)** | **consumed at each inner round of the per-sub flattening (13.2/13.3/13.4); never redefined** |
| zone semantics + split kit (`zoneHolds`/`EAtomDom`/`nf0_split_assemble`) | NfEFold:58/69/153-235 | Landed (task 310) | `nf0_split_assemble` is stated at general `n` (report 05: usable at arity 5 in the k=2 gate) |
| `BracketEndCharCarrierV` (abbrev) | NfMultiAnchorBridge:1855 | Landed 309 P9 / amended 311 P3 | the carrier TYPE (unchanged in v6) |
| `BracketCarrierCorrectV` | NfMultiAnchorBridge:1864 | Landed 311 P3 | unconditional predicate — kept for k≤1 statements; relativized variant added in 13.1 |
| `bracketFromLists` (private) | NfMultiAnchorBridge:1883 | Landed 311 P3 | disjunct builder |
| `bracketEndChar_k1v` (k=1 V-carrier) | NfMultiAnchorBridge:1923 | Landed 311, sorry-free | depth-1 template + proof machinery for the kvE step |
| `bracketEndChar_k1v_correct` (R2 = GO) | NfMultiAnchorBridge:3378 | Landed 311, sorry-free; GO record :3394-3434 | k=1 correctness `↔`; kvE step template |
| `bracketEndChar_k1v_sound` / `_complete` (private) | NfMultiAnchorBridge:2325/:2966 | Landed 311 | direction templates |
| k1v helper kit | NfMultiAnchorBridge:2028/2052/2137/2255/2682-2825 | Landed 311 | reusable proof machinery (`k1v_zoneHolds_cons_iff`/`k1v_zone_consistent`/`k1v_bracket_extract`/`k1v_reconstruct_nf3`/extract clones/`k1v_sorted_insert`/`k1v_sorted_realization`/`k1v_bracket_construct`) |
| `bracketEndChar_k0` / `_correct` | NfMultiAnchorBridge:1563/1577 | Landed 309 P9 | depth-0 base (six k0-mirror order hypotheses :1581-1594) |
| **`bracketEndChar_kv` (Phase-12 def) + helpers (`nfk_take` :3480, `nfk_projFresh` :3499, `kv_body` :3530, `bracketEndChar_kv_one_eq` :3711)** | **NfMultiAnchorBridge:3438-3776** | **Landed 309 P12** | **stays as the landed k≤1 instance and F1 exhibit; NOT edited, NOT consumed at k≥2** |
| **`bracketEndChar_kv_correct_zero`** | **NfMultiAnchorBridge:3783** | **Landed 309 P13 seam, sorry-free** | **k=0 instance; 13.1 lifts it to the relativized predicate (unconditional ↔ implies the UZ/SZ-conditional one)** |
| **`bracketEndChar_kv_correct_one`** | **NfMultiAnchorBridge:3811** | **Landed 309 P13 seam, sorry-free** | **k=1 instance; same relativized lift in 13.1** |
| **`bracketEndChar_kv_factors` + F1 record** | **NfMultiAnchorBridge:3838/:3871-3934** | **Landed 309 P13 seam, sorry-free** | **permanent defect exhibit; Phase 13.0 F2-probe input** |
| `bracketBuildLeft/Right` / `_correct` | VecEATranslation:273/:503, :50/:234 | Landed | Prop 3.5 chain builders — VALID ONLY at fixed-endpoint literals `epL`/`epR` (rule N4) |
| `BracketFormula.existsBounded_right`, `VecEAClosure`, `VBracketFormula.existsBounded_right` | VecEAClosure:265/:371 | Landed | Lemma 3.4 bounded ∃-closure / witness-append (13.2/13.3/14) |
| `VVecEA2` structure + holds + disj | VecEAFormula:271/276/282/286 | Landed | witness-growing carrier codomain (two-point `holds` = anchor-cap TYPE invariant) |
| `nf_eval_unique` / `nfPred_correct` | NormalForm:245 / NfToVecEA:69 | Landed | distinctness of realizing points (use `nfPred_correct`, NOT KampPrior:168) |
| `nf_depth0_pair_cycle_empty'` | NfDepth0Generalized:93 | Landed | inconsistent-zone falsity pattern |
| `nf_succ_char_formula` / `_correct` | KampPrior:67/:81 | Landed, sorry-free | **the architectural template**: provider-conditional per-sub enrichment at arity 1 (`nf_quant_clause_tl (exist_tl_fn sub) (nf.2 sub)`, one clause per sub, no fiber projection) |
| `nf_nvar_exist_all_depths` (`char_k1` local, `n=0` arm) | KampPrior:211/307/339 | Landed except `:351`/`:354` | outer recursion; the rewire target; supplies `h_UZ`/`h_SZ` (:216-223) and recursive converters at all depths ≤ k (:273 pattern) |
| **`HasAttainedINF`** | **PriorINF:202** | **Landed, sorry-free (NEW to asset table, report 05 F-D)** | **attained first occurrence for TL-definable P on subintervals** |
| **`prior_hasAttainedINF : semantic_prior_UZ M atomMap → HasAttainedINF M atomMap`** | **PriorINF:224** | **Landed, sorry-free (NEW)** | **bridge from `h_UZ` to the negation stack's key** |
| **`neg_interval_formula` (Lemma 5.1 fwd)** | **EANegationClosure:401** | **Landed; file 0 sorries (NEW)** | **exclusion-content obligations (13.3) — MODEL-DEPENDENT (see constraint in 13.3)** |
| **`neg_bounded_exists` (Cor 5.4 fwd)** | **EANegationClosure:492** | **Landed (NEW)** | **same** |
| **`neg_vecEA2` / `neg_2var_vec_ea` (Prop 4.2)** | **EANegationClosure:646/:720** | **Landed (NEW)** | **same** |
| **`neg_orderedPointsExist_is_vbracket` (Lemma 5.3)** | **EANegation:347** | **Landed (NEW; EANegation's :1090/:1249 sorries are in uniform-backward variants, documented non-blocking)** | **INF splitting base** |
| **F-chain construction (`fChainFrom`/`fChainPred`)** | **EANegation:552/:567** | **Landed (NEW)** | **Cor 5.4 `F_i` builders** |
| Import edge `…Kamp.NfMultiAnchorBridge` in KampPrior | KampPrior:4 | Landed P6.1 | cycle-safe; do NOT re-add/move (D1) |
| Import edge `…Kamp.NfEFold` in NfMultiAnchorBridge | NfMultiAnchorBridge:2 | Landed (311 P1) | cycle-free; do NOT re-add/move |

**New import edge authorized (verified cycle-free, report 05 §d)**: `import …Kamp.EANegationClosure`
into NfMultiAnchorBridge.lean is cycle-free — only KampPrior imports the Bridge; the negation
stack's transitive closure (EANegation, PriorINF, PriorDefs, ExistsForallNF, VecEAFormula,
VecEAClosure) reaches neither KampPrior nor the Bridge. Added in Phase 13.1 (which also verifies
this at compile time); if the verification fails, fall back to explicit ∀-quantified Prop
hypotheses exactly as `nf_succ_char_formula_correct` does (needs no import).

### Source-to-Implementation Mapping (H3, Tier 1)

Transcription source: `~/Projects/Literature/sources/rabinovich_2014/Rabinovich_2014_Proof_of_Kamps_Theorem.pdf` (md chunk refs from report 05).

| Paper item (Rabinovich 2014) | Paper loc | Lean target | Phase |
|------------------------------|-----------|-------------|-------|
| Def 3.1: α/β over the CURRENT (per-round enriched) vocabulary | p.4 (md:61-74) | temporal-formula point/segment types in `TemporalPred` slots, provider-built (slots landed :1886/:1955; provider wiring NEW) | 13.2 |
| Lemma 3.2(2): ≤2 free ANCHORS (not witnesses) | p.4 (md:76-79) | `VVecEA2.holds` two-point signature = TYPE invariant | all |
| Prop 3.5: `∃x_i` → Until/Since bracket witness (mechanism) | p.5 (md:87-94) | `bracketEndChar_k1v_correct` (k=1 template); kvE step | 13.2/13.3 |
| Def 4.1 + p.6 note: E[Σ] atom = monadic fold, inside-out iteration | p.5-6 | `nf_quant_layer_fold_iff` (NfEFold:391, general n) consumed per inner round | 13.2/13.3/13.4 |
| Prop 4.3 fold round | p.6 | cited ONLY for "residual is ∨∃∀ over E[Σ] atoms" (rule N2) | 13.2-13.4 |
| Per-round provider threading (Cor 5.4 `F_i` are TL formulas) | p.7/p.9 (md:154-157) | `nf_succ_char_formula(_correct)` hypothesis pattern (landed); `ExistProviders` bundle (NEW) | 13.1 |
| §5 bracket `[α_0,…,α_n](z_0,z_1)` | p.7 (md:127-132) | `VVecEA2` / `bracketFromLists` (landed, reused) | 13.2 |
| Lemma 3.4: ∨∃∀ closed under bounded `∃x` (witness joins prefix) | p.5 (md:84-85) | `existsBounded_right` (VecEAClosure:265); per-sub flattening license | 13.2/14 |
| Lemma 5.3 (INF splitting base) | md:137-152 | `neg_orderedPointsExist_is_vbracket` (EANegation:347); `HasAttainedINF.first_occ` (PriorINF:202) | 13.3 |
| Lemma 5.1 (bracket negation) | md:134-135 | `neg_interval_formula` (EANegationClosure:401, forward, model-dependent) | 13.3 obligations |
| Prop 4.2 (negation closure) | md:100-101 | `neg_vecEA2` / `neg_2var_vec_ea` (EANegationClosure:646/:720) | 13.3 obligations |
| Dedekind completeness (attained INF over Prior structures) | — | `semantic_prior_UZ/SZ` (PriorDefs:22/:33); `prior_hasAttainedINF` (PriorINF:224) | 13.1 hypotheses |
| Cor 5.4 `F_{i-1} := α_{i-1} ∧ (β_i Until F_i)` past/future arms | p.9 | `A_past`/`A_future`/`_correct` (P1 landed) | 14 or_congr |
| **Navigated arity-3 endpoint char (endChar route)** | **no paper counterpart** | `endChar`/`seg` | **ABANDONED ROUTE (v2 P6-P8)** |
| **`nf_eval_nf` per-depth arity growth `n→n+1`** | **no paper counterpart** | `NormalForm.lean:198-207` | **ENCODING artifact — routed around by the E[Σ]-fold (task 310)** |
| **Fiber-existential fold-bit read at k≥2** | **no paper counterpart (Rabinovich enriches vocabulary per round instead)** | `bracketEndChar_kv` successor case | **REFUTED at k=2 (F1); replaced by per-sub `bracketEndChar_kvE`** |

## Postmortem Constraints

Binding rules for all implementation dispatches. Guards G1-G6 + Corrected Anchor-Cap are carried
from v5 (VERBATIM except the two documented v6 amendments A1/A2 below, per report 05 §d). Rules
N1-N5 are carried VERBATIM from task 311 plan v3 / 309 v5.

**Guards G1-G6 + Corrected Anchor-Cap:**

- **G1** — No arity-1 collapse of the off-diagonal. (Refuted: report 02 §1; NfDepth0Generalized:1691-1719.)
- **G2** — No projection-based `VecEA2` / third-free-anchor tower. (Refuted: specs/305 report 40; R2.)
- **G3** — No trivial-top segment on the off-diagonal arms. A closed `pastEnd` under a trivial segment
  is model-independent and cannot re-identify the distinct origin `t`, so the hook is unsatisfiable
  off-diagonal. The `(x,t)` coupling MUST ride the non-trivial Rabinovich `β_i` segment (a real
  interval type, not `⊤`/trivial). Scoped: applies to `A_past`/`A_future` and the carrier interval
  types ONLY — the inner brick's trivial-top exterior brackets are sound and MUST stay untouched.
- **G4** — `w` stays a **bracket witness**. Env arity never grows past `{w,x,t}=3 → {x,t}=2`; anchor
  set is `{x,t}` (Rabinovich ≤2 cap). `w` is never a third anchor.
- **G5** — Follow Cor 5.4 / Prop 3.5 `F_i` chains step-by-step (`F_n := α_n`,
  `F_{i-1} := α_{i-1} ∧ (β_i Until F_i)`). No `simp`/`omega`/`aesop` shortcut of a chain step
  (literature-fidelity policy). Cite Rabinovich PDF p.4-5 (Def 3.1 / Lemma 3.2(2) / Prop 3.5 / Def 4.1)
  at every chain step, using the N1/N2 splits. **v6 extension (report 05 §d)**: chain steps at k≥2
  must additionally cite Lemma 5.3/5.1 + Prop 4.2 (md:100-152) for exclusion content, keeping the N2
  discipline (fold = Def 4.1 p.6 note; Prop 4.3 cited only for "residual is ∨∃∀ over E[Σ] atoms").
- **G6** — The recursion carrier MUST be the **two-anchor bracket characteristic** with **fixed
  endpoints** `z_0, z_1` (Prop 3.5, PDF p.5), NOT an **arity-1 navigated point characteristic**
  (refuted report 03 §2; NfMultiAnchorBridge:1058-1069), nor an **interior-existential-witness
  evaluation of `alpha_0`** (EANegation.lean:1077-1080). G2 bars a projection tower with a third
  free anchor; G6's carrier is a two-anchor fixed-endpoint bracket, anchor count ≤2 (Lemma 3.2(2)),
  `{x,t}` fixed.

**G6 Amendment (BINDING; carried from task 311 plan v3 / 309 v4)**: G6's carrier SHAPE is unchanged
(two-anchor bracket, FIXED endpoints `{x,t}`, `w` a bracket WITNESS). Amended is ONLY the codomain:
`VecEA2 1` becomes witness-growing `VVecEA2` (refutation: dense-order counterexample
NfMultiAnchorBridge:1782-1796; Rabinovich license: Lemma 3.2(2) caps ANCHORS not witnesses; §5
bracket p.7; Lemma 3.4 ∃-closure). **G2/G4 survive unamended: no third ANCHOR ever.**

**v6 Amendment A1 (NEW — report 05 §d, justification = F1 + F-A):** the correctness *predicate*
gains `(h_UZ : semantic_prior_UZ M atomMap, h_SZ : semantic_prior_SZ M atomMap)` hypotheses and
provider conditionality (an `ExistProviders` bundle): the v6 target is
`BracketCarrierCorrectVPrior`, NOT the unconditional `BracketCarrierCorrectV`, at k≥2. This amends
the plan's TARGET STATEMENT only, not G6's carrier shape. License: F1 is the concrete
counterexample Phase-12 Key Decision 2 demanded for re-opening; F-A verifies the `:351` consumer
carries exactly these hypotheses (KampPrior:216-223) plus recursive converters at all depths ≤ k
(KampPrior:273 pattern). The unconditional predicate remains valid and landed at k≤1.

**v6 Amendment A2 (NEW — report 05 §d):** the v5 rule "Do NOT reconstruct the arity-4 residual" is
REWORDED (its letter banned the only mathematically possible read channel; its intent — no
fiber-blind arity-4 resurrection — is preserved): at k≥2 the per-sub read makes
`NormalForm sig k 4` subs appear as *indices/data* and as *per-sub proof obligations*. **Amended
rule**: every per-sub obligation must be discharged by inside-out application of
`nf_quant_layer_fold_iff` at its innermost (depth-0) layer with witnesses flattened into the
bracket; NO NAVIGATED arity-3/4 characteristic, NO third anchor, NO raw `nf_eval_nf M (k+1)` split
that leaves a joint (n+1)-ary existential standing undischarged.

- **Corrected Anchor-Cap Statement** — the hook-discharge path MUST keep the anchor set at `{x,t}`
  (≤2) by the bracket-witness mechanism, NOT by `nf_char3_deeper_split` (NfMultiAnchorBridge:625-642,
  which grows arity 3→4 and anchors `{x,t}→{y,x,t}` — forbidden tower).

**Rules N1-N5 (VERBATIM from task 311 plan v3):**

- **N1 (caveat C1)** — In every NEW doc-comment and chain-step comment, do NOT cite Prop 3.5 alone for
  the two-fixed-endpoint bracket. Required split: **Prop 3.5 (p.5)** = the one-free-variable
  ∃-witness→Until/Since folding *mechanism*; **Lemma 3.2(2) (p.4) + §5 bracket notation (p.7)** = the
  two-fixed-endpoint `(z_0,z_1)` framing.
- **N2 (caveat C2)** — For fold rewrite steps, cite the **Def 4.1 p.6 note** for the "innermost fold /
  iteration" reading and **Prop 4.3 (p.6)** only for "the residual is ∨∃∀ over E[Σ] atoms"; the
  comment must note that the codebase realizes Prop 4.3's content locally via the fold, not via
  literal structural induction (305 report 14).
- **N3 (caveat C4)** — Any verdict/milestone doc-comment MUST lead with the Def 3.1 evidence: α_j/β_j
  are one-variable quantifier-free formulas, so the arity-4 residual `[x_1,w,x,t]` had no Rabinovich
  counterpart — a Lean `nf_eval_nf` arity-growth artifact; the fold restores Def-4.1 fidelity.
- **N4 (from the NO-GO record :1767-1796)** — Interior-positive content MUST be encoded as bracket
  WITNESSES ordered between the fixed endpoints, NEVER as `bracketBuildLeft`/`bracketBuildRight`
  chains anchored at an existential point of an endpoint TYPE. `bracketBuildLeft/Right` remain valid
  ONLY where the anchor genuinely is the fixed endpoint (the zPastX/zFutT endpoint literals in
  `epL`/`epR`).
- **N5 (arrangement disjunction)** — The model-dependent ORDER of interior witnesses is handled by a
  FINITE DISJUNCTION over linear arrangements inside `VVecEA2.disjuncts` — never by asserting a
  fixed order and never by an order-erasing shortcut. Distinctness of realizing points for DISTINCT
  complete types comes from `nf_eval_unique` (NormalForm:245); same-type multiplicity is NOT encoded.
  **v6 note**: interior-positive content is now per-sub and transitively flattened; index sets
  (subs, arrangements, point-type sets) stay finite at every depth, so N5's finite disjunction
  survives unchanged.

**Do NOT:**
- Do NOT resurrect the plan-v2 `endChar`/`EndCharCarrier`/`seg`/`seg_holds_*` route or report 02's
  "collapse brick" recommendation. Code retained OFF the live path, MUST NOT be built on.
- **Do NOT restate the RETIRED v5 deliverables** `bracketEndChar_kv_correct` / `bracketEndChar_kv_sound`
  / `bracketEndChar_kv_complete` (unconditional forms) — refuted at k=2 (F1). Any dispatch attempting
  the unconditional ∀k `↔` for ANY carrier over arbitrary `M` is a defect.
- **Do NOT edit `bracketEndChar_kv`** (:3630) or its helpers — it stays byte-identical as the landed
  k≤1 instance and the permanent F1 exhibit. `bracketEndChar_kvE` is a NEW definition alongside it.
- Do NOT attempt gate strengthening on the `bracketEndChar_kv` carrier (refuted, F1 item 4
  :3922-3928 — no model-independent syntactic gate separates same-fiber subs).
- Do NOT attempt one-jump enriched-signature re-indexing (`NormalForm sigE 1 n` compression) —
  lossy by the F1 pattern one level down (report 05 F-E.2).
- Do NOT use `nf_eval_efold` as the depth-k semantics (D7, NfEFold:373-375: bridge holds at depth-0
  subs only; `zone × unary-type` cannot separate joint content at k≥2).
- **Do NOT redefine the fold, the transport, or the gate corollary.** Consume `nf_eval_efold`,
  `efold_of_nf1`, `nf_eval_nf1_iff_efold`, `nf_quant_layer_fold_k1_gate`, `nf_quant_layer_fold_iff`,
  and the split kit from `NfEFold` BY NAME.
- Do NOT route hook discharge through `nf_char3_deeper_split` (grows the anchor set 3→4).
- Do NOT trust the v1 route-audit comments at NfMultiAnchorBridge:661,:676-678.
- Do NOT edit `nf_zone_flatten_navigable` inner-`w` trivial-top exterior brackets or
  `nf_char2_diag_exist_tl` (:190) exterior brackets (D4 — sound as-is).
- **Do NOT grow the ANCHOR count.** `VVecEA2.holds` stays two-point (VecEAFormula:276); endpoints
  `{x,t}` FIXED. Witness growth is licensed (G6 amendment + A2 per-sub flattening); anchor growth is not.
- **Do NOT encode interior-positive bits as type-anchored chains** (rule N4 — refuted device).
- Do NOT modify `bracketEndChar_k1v`/`_correct`, `bracketEndChar_k0`/`_correct`,
  `bracketEndChar_kv_correct_zero`/`_one`, `bracketEndChar_kv_factors`, the F1 record, either NO-GO
  record, or any task-310/311 landed asset.
- Do NOT use EANegationClosure's model-dependent lemmas as if they were uniform formula
  equivalences: carrier construction (a fixed formula chosen before `M`) may consume them only
  (i) proof-side (per-model direction obligations) or (ii) after uniformization by finite
  disjunction over the finitely-generated candidate family (report 05 F-D caveat).
- Do NOT introduce any domain axiom or leave any sorry in new material past the phase that owns it
  (sole exception: an explicitly documented strategic-sorry + `follow_up_task`).
- Do NOT reintroduce an import cycle. The `EANegationClosure → Bridge` edge (13.1) is verified
  cycle-free on paper (report 05 §d) and MUST be compile-verified at landing; all other new
  material is additive in NfMultiAnchorBridge.lean / KampPrior.lean.

**MUST preserve:**
- All Preserved/Live Assets above (sorry-free, axiom-clean), including Phases 1-5, P6.1, Phases
  9-12, the three Phase-13 landed lemmas + F1 record, and all task-310/311 material byte-identical.
- The `:354` live-path sorry stays (out of scope; task 305).
- Existing full-tree build green (1705 jobs baseline).

**Design decisions SETTLED (do not re-open without a concrete counterexample):**
- The constructive `A` is the Rabinovich Prop 3.5 / Cor 5.4 bracket `F_i` chain (report 03 VERDICT).
- The carrier is the two-anchor witness-growing `VVecEA2` bracket characteristic (G6 as amended).
- The quant layer is discharged ONLY via the E[Σ]-fold engine, now applied inside-out per sub (A2).
- The k≤1 story is CLOSED: base = `bracketEndChar_k0_correct`; k=1 = `bracketEndChar_k1v_correct`
  (R2 = GO); kv instances `_zero`/`_one` landed. Not re-run, not re-proved.
- **The v6 direction is report 05 route (a)-(d)**: relativized+conditional target
  (`BracketCarrierCorrectVPrior` / `ExistProviders`), per-sub enriched carrier
  (`bracketEndChar_kvE`), F2 probe first, k=2 gate before general k. Do not re-litigate.
- Phase-12 Key Decision 2 (fiber-existential read) is legitimately RE-OPENED at k≥2: F1 is the
  counterexample it demanded. It stays settled at k≤1.
- The `:351` rewire (Phase 14) is live (D1); Phases 1-5 stay off the live import path except as
  Phase 14 consumers.

## Goals & Non-Goals

**Goals:**
- Settle finding F2 formally (Phase 13.0): does UZ/SZ relativization alone rescue the CURRENT
  fiber-existential carrier at k=2? GO/NO-GO gate routing the rest of the plan.
- Land the corrected R3b interface (Phase 13.1): `ExistProviders` bundle +
  `BracketCarrierCorrectVPrior` (UZ/SZ-relativized, provider-conditional) + relativized lifts of
  the landed k=0/k=1 instances.
- Define the per-sub enriched successor-depth carrier `bracketEndChar_kvE` (Phase 13.2) — reads
  `qnf.2` per-sub, provider-built temporal formulas in existing `TemporalPred` slots, per-sub inner
  existentials flattened as bracket witnesses; k=2 instance fully concrete.
- Close the k=2 correctness GO/NO-GO gate (Phase 13.3), then the general-k one-step correctness
  `bracketEndChar_kvE_correct` (Phase 13.4).
- Discharge the four hooks, rewire `KampPrior:351` with providers instantiated from the outer
  recursion's recursive calls, close the `:351` sorry (live sorries 2 → 1), full `lake build`
  GREEN, axioms exactly `[propext, Classical.choice, Quot.sound]` (Phase 14).

**Non-Goals:**
- Closing `:354` (task 305 scope).
- Building or repairing the abandoned `endChar`/`seg` route.
- Re-encoding or re-deriving the E[Σ]-fold (task 310 deliverable — consumed by name).
- Re-running the k=1 gate or re-proving any k≤1 instance (settled; consumed as templates).
- Proving the RETIRED unconditional ∀k theorem (`bracketEndChar_kv_correct` et al.) — refuted (F1);
  the ∀k quantifier lives in KampPrior's `Nat.rec`, not in the Bridge (report 05 F-A).
- Any `nf_char3_deeper_split`-based discharge (anchor-tower forbidden).
- Same-type witness multiplicity encoding (N5).
- Uniform (formula-level) backward negation lemmas (EANegation :1090/:1249 scope) — not needed if
  13.3's proof-side-only consumption works; only the bounded uniformization fallback touches this.

## Risks & Mitigations

- **Risk (High; F2 is analysis-only)**: report 05 F-B (the ℤ countermodel) is NOT machine-checked;
  discreteness makes gap-emptiness depth-1-visible, so the per-entry type-match case analysis is
  more delicate than the ℚ density argument. Building 13.2-13.4 on an unverified F2 could waste the
  redesign (or, worse, skipping the redesign on a false "surgery suffices" could re-refute at
  Phase 14). **Mitigation**: Phase 13.0 is a bounded formal decision probe with explicit two-way
  routing (see the phase); neither continuation is dispatched until the verdict is recorded.
- **Risk (High; 13.3 concentration — exclusion-content encoding)**: the EANegationClosure lemmas
  are model-dependent existentials, not uniform formula equivalences; a fixed carrier formula
  cannot cite them directly. **Mitigation**: consume them proof-side-only (per-model direction
  obligations inside `bracketEndChar_kvE_correct`), with the bounded uniformization fallback
  (finite disjunction over the finitely-generated candidate family — subs, arrangements,
  point-type sets all finite per depth) named as the 13.3 NO-GO route. This is flagged design
  work, not hand-waved (report 05 F-D caveat).
- **Risk (Medium; provider availability claim)**: report 05's claim that recursive calls
  `nf_nvar_exist_all_depths atomMap h_surj k n'` are available at the `:351` arm for ANY `n'` is
  Medium-High confidence (the `n' = 1` call exists at KampPrior:273; generalization is the same
  structural descent but is flagged for compile-check). **Mitigation**: Phase 13.1 states
  `ExistProviders` as an explicit hypothesis bundle (no dependence on the claim); Phase 14 is where
  the instantiation is compile-checked — if some arity is not structurally available, the fallback
  is threading the needed converters as extra hypotheses through `nf_nvar_exist_all_depths`'s
  statement (the same surgery pattern as 13.1, confined to KampPrior.lean).
- **Risk (Medium; `prior_hasAttainedINF` / EANegationClosure usage is model-dependent)**: carried
  from report 05 — see the constraint stated in Phase 13.3 (the sole consuming phase) and the
  Do-NOT bullet above.
- **Risk (Medium; import edge)**: `import …Kamp.EANegationClosure` into the Bridge is verified
  cycle-free on paper only. **Mitigation**: 13.1 compile-verifies it; fallback = explicit
  ∀-quantified Prop hypotheses (the `nf_succ_char_formula_correct` pattern, no import needed).
- **Risk (recurring; the churn root)**: a dispatch re-attempts a refuted device — the `endChar`
  carrier, the anchor tower, gate strengthening on `bracketEndChar_kv`, the one-jump re-indexing,
  or the RETIRED unconditional theorem. **Mitigation**: the Do-NOT list enumerates each refuted
  device with its refutation citation; A2 gives the ONLY licensed read channel.
- **Risk**: Phase 14 puts the carrier on the live path and surfaces a latent axiom leak.
  **Mitigation**: Phase 14 runs full-tree build + `lean_verify` as explicit criteria; the
  newly-live subtree is grep-verified sorry-free.
- **Risk**: G5 literature-fidelity violated by a tactic shortcut. **Mitigation**: each chain step
  cites Rabinovich with the N1/N2 splits and (at k≥2) the G5 v6 extension; no simp/omega/aesop on
  a chain step.

## Implementation History (landed / abandoned / retired — NOT open work)

These sections are history. None match the orchestrator open-phase heading-scan
(`^### Phase [0-9]+(\.[0-9]+)?: .*\[(NOT STARTED|PARTIAL|IN PROGRESS)\]`). Do not re-dispatch them.

### Phase 1: Segment-carrying A_past / A_future + _correct [COMPLETED]

Landed, commit f4b9600a1. Segment-carrying `A_past`/`A_future` (NfZoneFlattenNavigable:335/:386) via
`bracketBuildLeft/Right_correct` (Rabinovich `β_i`). Sorry-free. Live consumer in Phase 14. History only.

### Phase 2: Off-diagonal atom layer for [x,t] [COMPLETED]

Landed, commit 762ea60da. `nf_char2_atom_offdiag_{origin,endpoint,correct}`
(NfMultiAnchorBridge:364/:375/:391), `order 0 1 = true`. Sorry-free; axioms clean. Consumed in
Phase 14 depth-0 atom decomposition. History only.

### Phase 3: Arity-3 endpoint-hook construction [COMPLETED]

Landed, commit 010ab616d. `nf_char3_endpoint_tl` + `_correct` (NfMultiAnchorBridge:891/:907), the
hook-parametric endpoint SHAPE (NOT the carrier). Sorry-free. History only.

### Phase 4: nf_char2_past_formula + _correct (F_i chain past arm) [COMPLETED]

Landed, commit fed9fcd8e. `nf_char2_past_formula` + `_correct` (NfMultiAnchorBridge:992/:1015), RHS
under `h_quant` (:1023-1026). Sorry-free. `h_quant` discharged in Phase 14 via the carrier. History only.

### Phase 5: nf_char2_future_formula + _correct (F_i chain future dual) [COMPLETED]

Landed, commit b60c63b1a. `nf_char2_future_formula` + `_correct` (NfMultiAnchorBridge:1185/…), dual RHS
under dual `h_quant` (:1223-1226). Sorry-free. Discharged in Phase 14. History only.

### Phase 6.1: Cycle-safe import edge (NfMultiAnchorBridge → KampPrior) [COMPLETED]

Landed, commit f3827e255. `import …Kamp.NfMultiAnchorBridge` in `KampPrior.lean` (D1, cycle-safe).
Full-tree GREEN. History only — do not re-add/move.

### Plan-v2 Phases 6-8 (endChar0 / EndCharCarrier / seg / seg_holds_*) [ABANDONED ROUTE — code retained, off live path]

Commits 131615736, 88a785d96, 901484b9c, f663811bb, 310ab8652, 8d8ce7dbf. The navigated arity-3
endpoint route. **Plan-v2 Phase 8 went [BLOCKED]** on the arity-4 → arity-3 re-bounding obstruction —
root-caused (report 04) to `nf_eval_nf`'s per-depth arity growth, an ENCODING artifact. Per report
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

Landed via the two spawned prerequisite tasks (both COMPLETE), folded into 309 by the v4 revision.
This is the integration record; the code exists in the working tree, sorry-free, off the 309 live path
until wired by Phase 14.

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
  fold + witness-growing carrier. History only — do not re-dispatch tasks 310/311.

### Phase 12: Depth-k V-carrier definition `bracketEndChar_kv` (R3a) [COMPLETED]

*(Landed 2026-07-06, NfMultiAnchorBridge.lean:3438-3776. Two documented realization deviations,
both within the phase's settled shape: (1) the depth-`k` char provider is a PARAMETER family
`charF : (j : Nat) → NormalForm sig j 1 → Formula` rather than a by-name consumption of
`char_k1` — `char_k1`/`nf_characterizable_temporal_prior` live in KampPrior.lean, which IMPORTS
NfMultiAnchorBridge (KampPrior.lean:4), so by-name consumption would re-create the import cycle
removed by task 307 P7; Phase 14 instantiates `charF` at the KampPrior call site (the
`nf_succ_char_formula`/`exist_tl_fn` parameterization pattern). (2) The depth-`k` fold bit is
read FIBER-EXISTENTIALLY (`b zs χ = decide (∃ sub, qnf.2 sub = true ∧ zoneSpec = zs ∧
nfk_projFresh sub = χ)`) rather than via a pointwise depth-`k` assemble — no such assemble
exists at `k ≥ 1` (D7, NfEFold:373: deeper joint quant layers are not determined by
`(zs, χ, qnf.1)`); under the gate's off-fiber conjunct this agrees with the `efold_of_nf1`
pointwise read at k=1 (split-kit bijection), discharged by the documented bridge lemma
`bracketEndChar_kv_one_eq` (pointwise EQUALITY, the acceptance's simp-bridge branch). New
helpers: `nfk_take` (depth-`k` prefix restriction), `nfk_projFresh`, private shared successor
body `kv_body` with `bracketEndChar_k1v_eq_kv_body : … = kv_body … := rfl`. Verification: full
tree GREEN (1705 jobs); 0 new sorries; `lean_verify` on `bracketEndChar_kv` AND
`bracketEndChar_kv_one_eq` = exactly `[propext, Classical.choice, Quot.sound]`;
`bracketEndChar_k1v` untouched.)*

**v6 status note**: `bracketEndChar_kv` remains landed and preserved as the k≤1 instance and the
F1 exhibit. Its successor-depth fiber-existential read is REFUTED at k≥2 (finding F1) — the k≥2
role is taken over by `bracketEndChar_kvE` (Phase 13.2). History only.

### Phase 13 (v5): Depth-k V-carrier correctness `bracketEndChar_kv_correct` (R3b) [BLOCKED — RETIRED; superseded by Phases 13.0-13.4 below]

**RETIRED by this v6 revision — do not re-dispatch, do not restate.** The v5 target
`bracketEndChar_kv_correct` (unconditional ∀k `↔` for the Phase-12 carrier) is FALSE at k=2 —
finding F1 (2026-07-06), full record NfMultiAnchorBridge.lean:3871-3934:

- **Counterexample**: `M = (ℚ, <)`, `P = {q, p, r}`, `q < x < u₂ < p < u₁ < w < t < r`; `u₁, u₂`
  share their complete depth-1 1-type but `[u₁,w,x,t]` / `[u₂,w,x,t]` have distinct depth-1
  arity-4 types in one fiber `(zXW, χ, qnf.1)`. With `qnf :=` characteristic depth-2 3-type of
  `[w,x,t]` and `qnf' := qnf` with `sub₂` un-marked, the machine-checked
  `bracketEndChar_kv_factors` (:3838) gives carrier equality while no `w'` realizes `qnf'` in `M`
  — the two instances of the target `↔` are jointly contradictory. `qnf'` is realizable in a
  discrete chain, so no consistency side-hypothesis rescues the statement.
- **Why**: at k≥2 the fiber-existential fold-bit read discards joint deeper structure of the fresh
  witness relative to the anchors; the depth-0 split-kit bijection (NfEFold:235) has no k≥2 analog
  (D7, NfEFold:373). Rabinovich avoids this by ENRICHING the α_j/β_j vocabulary at every Prop-4.3
  fold round (Def 3.1 p.4; Cor 5.4's `F_i` are TL formulas, p.7).
- **NOT refuted**: the completeness direction at all k, and the k≤1 instances.
- **Landed green from the 13a seam (sorry-free, preserved)**: `bracketEndChar_kv_correct_zero`
  (:3783), `bracketEndChar_kv_correct_one` (:3811), `bracketEndChar_kv_factors` (:3838); full tree
  GREEN; `lean_verify` = exactly `[propext, Classical.choice, Quot.sound]` on all three. Commits
  e5924f492, 0f1826739.

The corrected work is decomposed as Phases 13.0-13.4 below (report 05 §c ladder; report labels
13.0 / 13.I / 13.II-a / 13.II-b / 13.III map to plan phases 13.0 / 13.1 / 13.2 / 13.3 / 13.4 —
numeric sub-phase numbering keeps the orchestrator heading-scan dispatchable). History only.

## Implementation Phases (Open — 13.0 / 13.1 / 13.2 / 13.3 / 13.4 / 14)

**Dependency Analysis**:

| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 13.0 (F2 decision probe) | -- (consumes landed assets only) |
| 2 | 13.1 (statement surgery) | 13.0 verdict recorded (either branch needs 13.1) |
| 3 | 13.2 (kvE definition) | 13.1; SKIPPED on the 13.0 surgery-only branch |
| 4 | 13.3 (k=2 GO/NO-GO gate) | 13.2; SKIPPED on the surgery-only branch |
| 5 | 13.4 (general k) | 13.3 = GO; SKIPPED on the surgery-only branch |
| 6 | 14 (hooks + :351 rewire) | 13.4 (full ladder) or 13.1 (surgery-only branch, per 13.0 verdict) |

Phases are strictly sequential (each consumes the previous phase's declarations by name; all edit
`NfMultiAnchorBridge.lean` / `KampPrior.lean` single-file territory, one owner per dispatch). One
agent run per phase (H8). The orchestrator dispatches exactly one open phase per cycle by
heading-scan. **Branch discipline**: the 13.0 verdict is recorded in the file + handoff; if the
verdict is SURGERY-ONLY, the dispatcher runs `/revise 309` (v7) to strike Phases 13.2-13.4 and
re-point Phase 14's dependency at 13.1 — Phases 13.2-13.4 MUST NOT be dispatched on that branch
without the v7 revision.

### Phase 13.0: F2 decision probe — is the relativized statement still false for the CURRENT carrier at k=2? [IN PROGRESS]

*(Report 05 label: Phase 13.0. First dispatch of v6 — nothing else is dispatched before this
verdict is recorded.)*

- **Goal:** Settle finding F2 formally. Report 05 F-B argues (analysis-only, NOT machine-checked)
  that the F1 information loss survives UZ/SZ relativization: `M* = (ℤ, <)`, `P = {0,10,20}`,
  `x = 2, u₂ = 4, u₁ = 12, w = 15, t = 18` satisfies `semantic_prior_UZ`/`semantic_prior_SZ` (every
  nonempty subset of `(t,∞)` / `(-∞,t)` in ℤ has a least/greatest element) while `qnf :=
  nf_characteristic M* 2 3 [15,2,18]` and `qnf' := qnf` with the `u₂`-sub un-marked exhibit the
  F1 contradiction pattern (`bracketEndChar_kv_factors` gives carrier equality; `qnf` realized at
  `w = 15`; the `w'` case analysis — `w' ≤ 11` / `12 ≤ w' ≤ 15` / `w' ≥ 16` — suggests no `w'`
  realizes `qnf'`). Attempt to machine-check this refutation of the UZ/SZ-relativized k=2
  statement for `bracketEndChar_kv`. Caveat to probe honestly: discreteness makes gap-emptiness
  depth-1-visible, so the per-entry type-match check is delicate (report 05 F-B caveat) — the
  probe may legitimately discover the countermodel FAILS.
- **Deliverables:**
  - A machine-checked verdict record next to F1 in NfMultiAnchorBridge.lean (additive; the F1
    record :3871-3934 is NOT edited), in the F1/GO-record house style with N1/N2/N3 citations:
    EITHER `-- finding F2 (CONFIRMED)` with the checked refutation lemma(s) (e.g. a `theorem
    f2_relativized_refutation : ¬ (∀ …UZ/SZ-relativized k=2 statement for bracketEndChar_kv…)` or
    the two jointly-contradictory instance lemmas, mirroring the F1 mechanism), OR `-- finding F2
    (REFUTED — surgery suffices)` with the verified obstruction to the countermodel (which
    per-entry check fails and why).
  - Verdict propagated to the phase handoff (`handoffs/phase-13.0-handoff-{DATE}.md`).
- **GO/NO-GO routing (explicit; neither branch is "try harder"):**
  - **F2 CONFIRMED** (relativization does NOT rescue the current carrier — expected outcome):
    proceed to Phase 13.1 and the FULL ladder 13.2 → 13.3 → 13.4 → 14.
  - **F2 REFUTED** (the UZ/SZ-relativized k=2 statement for `bracketEndChar_kv` is provable, or
    the probe proves the relativized statement outright): the plan COLLAPSES to surgery-only —
    record the verdict, then `/revise 309` (v7) striking Phases 13.2-13.4 and re-scoping Phase
    13.1 to also prove the relativized correctness for the EXISTING carrier, with Phase 14
    consuming that. Do NOT dispatch 13.2-13.4 on this branch.
  - **UNSETTLED within budget** (neither the refutation nor the rescue closes in one H8 run):
    record the partial goal states + the exact stuck per-entry obligations in the verdict comment
    and the handoff, land only green material, and escalate to the orchestrator for ONE bounded
    follow-up probe dispatch with the recorded states; if still unsettled, default to F2
    CONFIRMED routing (the redesign is the report's recommended route and is strictly more
    general — it does not depend on F2's truth, only its expense does).
- **File targets:** `Theories/Bimodal/.../Kamp/NfMultiAnchorBridge.lean` (additive, after the F1
  record). A concrete ℤ-instance `OrderedMonadicStructure` may be built locally (private defs) if
  no suitable one exists; it must not disturb any existing declaration.
- **Consume, do NOT rebuild:** `bracketEndChar_kv` (:3630) + `bracketEndChar_kv_factors` (:3838)
  + the F1 record (probe inputs — read-only); `semantic_prior_UZ`/`semantic_prior_SZ`
  (PriorDefs:22/:33); `nf_eval_unique` (NormalForm:245); the fold split kit (NfEFold:153-235) for
  per-entry type computations. Do NOT edit any landed asset; do NOT strengthen the kv gate (refuted
  device, F1 item 4).
- **Acceptance criteria:** `lake build` GREEN full tree; 0 new live-path sorries (probe material is
  off the live path; 0 sorries in it either — an unsettled probe lands only its green fragments);
  `lean_verify` on each new probe lemma = exactly `[propext, Classical.choice, Quot.sound]`; the
  verdict comment present with explicit routing consequence stated; no modification of
  `bracketEndChar_kv`, the F1 record, or any preserved asset (git diff confirms additive-only).
- **Estimated lines:** 80-200 (one agent run; H8).
- **Guards enforced:** A2 (no navigated characteristic in probe constructions), N1/N2/N3
  (verdict-comment citation discipline), Do-NOT list (no gate strengthening).
- **Commit:** `task 309 phase 13.0: F2 decision probe — relativized k=2 verdict for the current carrier`

### Phase 13.1: Statement surgery — `ExistProviders` bundle + `BracketCarrierCorrectVPrior` + relativized k≤1 lifts [NOT STARTED]

*(Report 05 label: Phase 13.I. Dispatch ONLY after the 13.0 verdict is recorded; runs on BOTH
13.0 branches — on the surgery-only branch its scope is amended by the v7 revision first.)*

- **Goal:** Land the corrected R3b interface (report 05 Pillar 1): the provider bundle and the
  UZ/SZ-relativized, provider-conditional correctness predicate, plus relativized lifts of the
  landed k=0/k=1 instances (an unconditional `↔` implies the UZ/SZ-conditional one — weakening
  lemmas). The ∀k quantifier is NOT restated here: it lives in KampPrior's `Nat.rec` (F-A).
- **Deliverables (exact names/signatures per report 05 Pillar 1; adjust binders only as elaboration forces, documenting any deviation):**
  - ```
    structure ExistProviders (sig : MonadicSignature) (atomMap : Formula → sig.preds) (k : Nat) where
      existF : (n : Nat) → NormalForm sig k (n + 1) → Formula
      correct : ∀ (n : Nat) (sub : NormalForm sig k (n + 1)) (M : OrderedMonadicStructure sig)
          (h_UZ : semantic_prior_UZ M atomMap) (h_SZ : semantic_prior_SZ M atomMap) (t : M.carrier),
          temporal_truth M atomMap t (existF n sub) ↔
            ∃ env : Fin n → M.carrier, nf_eval_nf M k (n + 1) (insertEnv env t) sub
    ```
    (single-anchor existential converters at depth k, all arities — what the outer recursion
    supplies at `:351`).
  - `def BracketCarrierCorrectVPrior {sig} (atomMap : Formula → sig.preds) {k : Nat} (carrier :
    BracketEndCharCarrierV sig k) : Prop` — quantifying over `qnf : NormalForm sig k 3`, the six
    bracket-zone order hypotheses on the atom layer (k0-mirror form, :1581-1594 shape), `M`,
    `h_UZ`, `h_SZ`, `x t`, concluding `(carrier qnf).holds M atomMap x t ↔ ∃ w, nf_eval_nf M k 3
    (Fin.cons w (Fin.cons x (fun _ => t))) qnf`.
  - Relativized lifts: `bracketEndChar_kv_correct_zero_prior` / `bracketEndChar_kv_correct_one_prior`
    (weakening of the landed :3783/:3811 — drop-hypotheses proofs, a few lines each).
  - Import-order resolution: attempt `import …Kamp.EANegationClosure` (transitively supplies
    PriorINF/PriorDefs) in NfMultiAnchorBridge.lean and compile-verify cycle-freedom (report 05 §d
    verified on paper). Fallback if the build objects: state the UZ/SZ hypotheses as explicit
    ∀-quantified Props (the `nf_succ_char_formula_correct` pattern — no import needed) and
    document the deviation.
- **File targets:** `Theories/Bimodal/.../Kamp/NfMultiAnchorBridge.lean` (additive, after the F2
  verdict material).
- **Consume, do NOT rebuild:** `BracketEndCharCarrierV` (:1855); `bracketEndChar_kv_correct_zero`
  / `_one` (:3783/:3811 — lifted, not re-proved); `semantic_prior_UZ`/`_SZ` (PriorDefs:22/:33);
  `insertEnv`/`nf_eval_nf` (NormalForm); the `nf_succ_char_formula_correct` hypothesis pattern
  (KampPrior:81 — template, read-only). Do NOT restate the retired unconditional names; do NOT
  edit `BracketCarrierCorrectV` (kept for the landed k≤1 statements).
- **Acceptance criteria:** `lake build` GREEN full tree; `ExistProviders`,
  `BracketCarrierCorrectVPrior`, and both `_prior` lifts typecheck sorry-free; 0 new sorries;
  `lean_verify` on both lifts = exactly `[propext, Classical.choice, Quot.sound]`; the import edge
  is either landed cycle-free or the documented explicit-Props fallback is in place; doc-comments
  carry the A1 amendment citation (report 05 §d) + N1 split; no preserved asset modified.
- **Estimated lines:** 100-180 (one agent run; H8).
- **Guards enforced:** A1 (this phase IS the A1 amendment's realization), G6-as-amended, N1, N3;
  Do-NOT list (no retired-name restatement).
- **Commit:** `task 309 phase 13.1: statement surgery — ExistProviders + BracketCarrierCorrectVPrior + relativized k≤1 lifts`

### Phase 13.2: Per-sub enriched carrier `bracketEndChar_kvE` — definition + concrete k=2 instance [NOT STARTED]

*(Report 05 label: Phase 13.II-a. Dispatch ONLY after 13.1 lands green AND the 13.0 verdict was
F2 CONFIRMED — SKIPPED on the surgery-only branch.)*

- **Goal:** Define the redesigned successor-depth carrier (report 05 Pillar 2 — the F1 item-3
  "required behavior"): read `qnf.2` **per-sub**, NOT through `(ZoneSpec 3 × NormalForm sig k 1)`
  fibers. Additive definition alongside — NOT replacing — `bracketEndChar_kv`:
  `noncomputable def bracketEndChar_kvE {sig} (atomMap …) (h_surj …) (P : ExistProviders sig
  atomMap k) : BracketEndCharCarrierV sig (k + 1)`. At successor depth: the interior-positive
  enumeration ranges over **positive subs** `σ : NormalForm sig k 4` (each with `qnf.2 σ = true`
  in an interior zone); each positive σ contributes a `z`-witness slot whose point type and
  adjacent segment types are **temporal formulas built from `P.existF`** (the enriched vocabulary
  — `TemporalPred` already wraps arbitrary `Formula`s, NfMultiAnchorBridge:1886/:1955, so NO
  codomain change), plus σ's own inner existentials flattened as further bracket witnesses
  (Lemma 3.4 / G6-amendment license); negative subs contribute segment/endpoint exclusion literals
  over the same enriched vocabulary (their correctness obligations are 13.3's work). Depth
  alignment (report 05 Pillar 3 note): the carrier needed at depth `k` is `bracketEndChar_kvE` at
  `k = j + 1` with providers at depth `j = k - 1`; depth-0 stays `bracketEndChar_k0`, depth-1
  stays the k1v instance (both landed). The **k=2 instance is elaborated concretely** in this
  phase: each positive sub's inner layer is depth-0, so exact literal shapes are fixed here using
  `nf0_split_assemble` at arity 5 and `nf_quant_layer_fold_iff` — the exclusion literal shapes are
  this phase's design deliverable (report 05 fixes the interface and information channel, not
  every conjunct).
- **Deliverables:**
  - `bracketEndChar_kvE` (signature above) with the per-sub successor body; disjuncts via
    `bracketFromLists` over arrangement enumerations (N5); endpoint literals `epL`/`epR` at the
    FIXED endpoints (N4); gate/inconsistency branches = `⟨[]⟩` as in the k1v/kv house style.
  - The concrete k=2 instance (definitional unfolding lemma(s) as needed for 13.3, e.g. a
    `bracketEndChar_kvE_two_eq`-style bridge if the proof wants it).
  - Doc-comment: A2 discipline statement (per-sub obligations discharged inside-out via
    `nf_quant_layer_fold_iff` at the innermost layer; no navigated characteristics, no third
    anchor), N1/N2 splits, Def 3.1 enriched-vocabulary citation (md:61-74), G5 v6 extension refs.
- **File targets:** `Theories/Bimodal/.../Kamp/NfMultiAnchorBridge.lean` (additive, after 13.1).
- **Consume, do NOT rebuild:** `ExistProviders` (13.1); `bracketFromLists` (:1883);
  `VVecEA2`/`VecEA2` (VecEAFormula:271/252); `existsBounded_right` (VecEAClosure:265);
  `nf0_split_assemble` (NfEFold:235, general n — arity 5 use); `nf_quant_layer_fold_iff`
  (NfEFold:391); `bracketEndChar_k0` (:1563) and the k1v instance (depth ≤1 base — read-only);
  the k1v construction house style (:1923-2825 — template, read-only). Do NOT edit
  `bracketEndChar_kv`/`kv_body`; do NOT read `qnf.2` fiber-existentially at k≥2 (refuted, F1); do
  NOT re-index through an enriched signature (rejected, F-E.2); do NOT redefine any fold asset.
- **Acceptance criteria:** `lake build` GREEN full tree; `bracketEndChar_kvE` typechecks
  sorry-free with codomain `VVecEA2` (grep confirms no `VecEA2 1` regression); anchors provably
  `{x,t}` (two-point `VVecEA2.holds` signature — G4/G6); enumeration verifiably per-sub (the body
  quantifies over `σ` with `qnf.2 σ = true`, not over fiber pairs — code-review criterion);
  point/segment types built from `P.existF` where depth > 0; 0 new sorries; `lean_verify
  bracketEndChar_kvE` = exactly `[propext, Classical.choice, Quot.sound]`; doc-comment discipline
  above; additive-only diff.
- **Estimated lines:** 150-250 (one agent run; H8).
- **Guards enforced:** G2, G4, G6-as-amended, A1 (provider parameter), A2 (per-sub read
  discipline — this phase realizes it), N1, N4, N5.
- **Commit:** `task 309 phase 13.2: per-sub enriched carrier bracketEndChar_kvE + concrete k=2 instance`

### Phase 13.3: k=2 correctness GO/NO-GO gate for `bracketEndChar_kvE` [NOT STARTED]

*(Report 05 label: Phase 13.II-b. Dispatch ONLY after 13.2 lands green. DECISION GATE — the
task-311 Phase-5 verdict-record pattern: machine-probe, record the verdict either way, land no
partial theorem, no sorry.)*

- **Goal:** Prove `bracketEndChar_kvE_correct` at the k=2 instance (i.e.
  `BracketCarrierCorrectVPrior atomMap (bracketEndChar_kvE atomMap h_surj P)` for `k + 1 = 2`,
  `P : ExistProviders sig atomMap 1`): soundness + completeness at k=2, where each positive sub's
  inner layer is depth-0 so `nf0_split_assemble` (arity 5) and `nf_quant_layer_fold_iff` apply
  directly. Negative-sub exclusion content is discharged through the `HasAttainedINF` /
  first-occurrence splitting: `prior_hasAttainedINF h_UZ` (PriorINF:224) + the EANegationClosure
  stack (`neg_interval_formula` :401, `neg_bounded_exists` :492, `neg_vecEA2`/`neg_2var_vec_ea`
  :646/:720, `neg_orderedPointsExist_is_vbracket` EANegation:347).
  **BINDING CONSTRAINT (report 05 F-D caveat — carried risk):** the EANegationClosure lemmas are
  MODEL-DEPENDENT existentials (`∃ v : VVecEA2, v.holds M atomMap z0 z1`), not uniform formula
  equivalences. The fixed carrier formula was chosen in 13.2 before `M`; therefore these lemmas
  may be consumed ONLY proof-side (per-model direction obligations inside this proof). If the
  proof-side route is insufficient, that is the NO-GO finding — do NOT silently weaken the 13.2
  carrier or the 13.1 predicate.
- **Deliverables:**
  - `theorem bracketEndChar_kvE_correct_two` (name may carry the instance suffix; the general-k
    statement is 13.4's) — the k=2 instance of `BracketCarrierCorrectVPrior atomMap
    (bracketEndChar_kvE atomMap h_surj P)`, via direction lemmas
    `bracketEndChar_kvE_sound_two` / `_complete_two` (private, mirroring the k1v
    `_sound`/`_complete` split :2325/:2966).
  - A GO/NO-GO verdict record in the file + handoff (house style of the R2 GO record :3394-3434),
    leading with the N3 Def-3.1 evidence and citing Lemma 5.3/5.1 + Prop 4.2 per the G5 v6
    extension.
- **GO/NO-GO routing (explicit):**
  - **GO** (k=2 `↔` closed sorry-free): proceed to Phase 13.4.
  - **NO-GO, exclusion-content encoding** (the model-dependent-negation gap of F-D materializes —
    the proof-side consumption cannot close a direction): the NAMED FALLBACK is a dedicated
    uniformization phase — construct the needed uniform negation formulas as FINITE DISJUNCTIONS
    over the finitely-generated candidate family (subs, arrangements, point-type sets are all
    finite at each depth — report 05 §c contingency), inserted via `/revise 309` (v7) as Phase
    13.2b, then re-run this gate ONCE. Not "try harder": the fallback is a bounded, concrete
    construction with finite index sets.
  - **NO-GO, carrier-shape defect** (a genuinely new obstruction in the 13.2 body, not the F-D
    gap): record the defect in the F1/F2 house style with the goal state, land no partial theorem,
    and ESCALATE via `/revise 309` (v7) with the defect record as revision authority — the same
    discipline that produced F1 → report 05 → this plan. The escalation fence (audit caveat C3)
    bars implementer-level anchor growth under all circumstances.
- **File targets:** `Theories/Bimodal/.../Kamp/NfMultiAnchorBridge.lean` (additive, after 13.2).
- **Consume, do NOT rebuild:** `bracketEndChar_kvE` + k=2 instance material (13.2);
  `BracketCarrierCorrectVPrior`/`ExistProviders` (13.1); `nf0_split_assemble` (NfEFold:235, arity
  5); `nf_quant_layer_fold_iff` (NfEFold:391); the k1v proof kit (:2028-2825) and direction
  templates (:2325/:2966); `prior_hasAttainedINF` (PriorINF:224) + `HasAttainedINF` (PriorINF:202);
  the EANegationClosure stack (:401/:492/:646/:720) + `neg_orderedPointsExist_is_vbracket`
  (EANegation:347) + F-chain builders (EANegation:552/:567); `nf_eval_unique` (NormalForm:245) /
  `nfPred_correct` (NfToVecEA:69); `existsBounded_right` (VecEAClosure:265). Do NOT touch the
  uniform-backward EANegation sorries (:1090/:1249 — out of scope unless the uniformization
  fallback is triggered, and then only via the v7 revision); do NOT redefine any fold or negation
  asset; do NOT silently change the 13.2 carrier (KD3 discipline).
- **Acceptance criteria:** `lake build` GREEN full tree; on GO: k=2 `↔` + both direction lemmas
  sorry-free, `lean_verify` on each = exactly `[propext, Classical.choice, Quot.sound]`, verdict
  record present; on NO-GO: verdict record with goal state + routing named, NO partial theorem,
  NO sorry landed, tree still GREEN; 0 new live-path sorries either way; every chain step cites
  Rabinovich per G5 + v6 extension (no simp/omega/aesop on a chain step); per-sub obligations
  discharged inside-out per A2 (no raw `nf_eval_nf M (k+1)` split leaving a joint existential
  standing).
- **Estimated lines:** 200-250 (one agent run; H8; the difficulty concentration of v6).
- **Guards enforced:** G1, G3, G4, G5 (+v6 extension), G6-as-amended, A1, A2, N1-N5.
- **Commit:** `task 309 phase 13.3: k=2 correctness gate bracketEndChar_kvE_correct_two (GO/NO-GO)`

### Phase 13.4: General-k one-step correctness `bracketEndChar_kvE_correct` [NOT STARTED]

*(Report 05 label: Phase 13.III. Dispatch ONLY after 13.3 records GO.)*

- **Goal:** Prove the general one-step correctness (report 05 Pillar 3):
  `theorem bracketEndChar_kvE_correct {sig} (atomMap …) (h_surj …) (P : ExistProviders sig atomMap
  k) : BracketCarrierCorrectVPrior atomMap (bracketEndChar_kvE atomMap h_surj P)` — ONE successor
  step with symbolic `k`, conditional on providers at depth `k`. NOT a ∀k induction inside the
  Bridge: the ∀k recursion is KampPrior's existing `Nat.rec` (F-A; Phase 14 instantiates). Template
  = the 13.3 k=2 proof with the depth-0 innermost layer replaced by provider-mediated obligations:
  where 13.3 used `nf0_split_assemble` directly on depth-0 inner layers, the symbolic-k step
  consumes `P.correct` for the flattened inner existentials and applies `nf_quant_layer_fold_iff`
  at the innermost layer of each per-sub obligation (A2 inside-out discipline).
- **Deliverables:**
  - `bracketEndChar_kvE_correct` (signature above) + general direction lemmas
    `bracketEndChar_kvE_sound` / `_complete` (private), with the k=2 instance lemmas of 13.3
    either subsumed (re-derived as instances) or kept alongside — do not delete the 13.3 verdict
    record either way.
- **File targets:** `Theories/Bimodal/.../Kamp/NfMultiAnchorBridge.lean` (additive, after 13.3).
- **Consume, do NOT rebuild:** everything 13.3 consumed, plus the 13.3 proof itself as template
  (read-only); `P.correct` (the provider hypothesis — the ONLY channel to inner-existential
  semantics at symbolic depth). Do NOT re-open the k=2 verdict; do NOT restate the retired
  unconditional names; do NOT introduce a ∀k induction over the carrier inside the Bridge.
- **Acceptance criteria:** `lake build` GREEN full tree; `bracketEndChar_kvE_correct` + direction
  lemmas sorry-free — or ONE explicitly documented strategic-sorry + `follow_up_task` if a
  bounded, named residual obligation survives (documented per the Do-NOT exception; NOT silent);
  `lean_verify bracketEndChar_kvE_correct` = exactly `[propext, Classical.choice, Quot.sound]`;
  anchors provably `{x,t}` at the symbolic depth (G4/G6); A2 discipline grep-verifiable
  (`nf_quant_layer_fold_iff` at every innermost per-sub layer; no raw successor split); chain-step
  citation discipline (G5 + v6 extension, N1/N2).
- **H8 split note:** if it overruns one agent run, split at the direction seam (13.4a = soundness;
  13.4b = completeness + assembled `↔`), mirroring the task-311 5.1/5.2 split.
- **Estimated lines:** 150-250 (one agent run; H8).
- **Guards enforced:** G1, G3, G4, G5 (+v6 extension), G6-as-amended, A1, A2, N1-N5.
- **Commit:** `task 309 phase 13.4: general-k one-step correctness bracketEndChar_kvE_correct`

### Phase 14: Discharge four hooks + KampPrior:351 rewire + full-tree axiom check (R4) [NOT STARTED]

*(Dispatch ONLY after 13.4 lands green — or after 13.1 on the 13.0 surgery-only branch (per the
v7 re-scope). Shape unchanged from plan v5 (per the Phase-13 handoff item 4: the hook-discharge
shape survives — only the internal carrier construction and its correctness interface changed);
updated to consume `bracketEndChar_kvE`/`BracketCarrierCorrectVPrior` and to instantiate
providers from the outer recursion. This phase delivers the task goal.)*

- **Goal:** Use the depth-`k` witness-growing enriched V-carrier to **discharge the four deferred
  hooks** — `h_quant` (past, NfMultiAnchorBridge:1023-1026), `h_quant` (future, :1223-1226), and
  `h_past`/`h_fut`/`h_diag` (`A_diag_correct`, :787-795) — then rewire `KampPrior.lean:351` to the
  three-way disjunction `A := nf_char2_past_formula … ∨ A_diag … ∨ nf_char2_future_formula …` via
  `nf_zone_exists_trichotomy_k1` and a three-way `or_congr`, closing the `:351` sorry (live sorries
  2 → 1; `:354` stays, task 305). Mechanically: at `:351` the goal is `∃ A, temporal_truth t A ↔
  ∃ env : Fin 1, nf_eval_nf M (k+1) 2 (insertEnv env t) sub_nf`, with `h_UZ`/`h_SZ` in scope
  (KampPrior:216-223) — exactly the `BracketCarrierCorrectVPrior` hypotheses (A1). **Provider
  instantiation (report 05 Pillar 3):** build `P : ExistProviders sig atomMap j` at each needed
  depth `j ≤ k` from the recursive calls `nf_nvar_exist_all_depths atomMap h_surj j n'` (the
  KampPrior:273 `ih_exist_1` pattern generalized across arities — structural on the first Nat
  argument; compile-check flagged by report 05 as Medium-High: if some arity is not structurally
  available, thread the needed converters as extra hypotheses through the theorem statement, same
  surgery pattern as 13.1, confined to KampPrior.lean, and document the deviation). Also
  instantiate `charF` per the Phase-12 KD1 pattern (`nf_characterizable_temporal_prior`,
  KampPrior:397) where k≤1 kv instances are consumed. Bridge `env : Fin 1` to `∃x` (existing
  `h_env_eq` shape, KampPrior:277-291); decompose `nf_eval_nf M (k+1) 2 [x,t]` into its depth-0
  atom layer (`nf_char2_atom_offdiag_correct`, P2) and, per arity-3 sub `qnf`, the inner
  existential closed by `bracketEndChar_kvE_correct` (13.4) + Lemma 3.4 / `existsBounded_right`
  (VecEAClosure:265); assemble and feed the three arms through the `or_congr` with
  `nf_char2_past_formula_correct` / `A_diag_correct` / `nf_char2_future_formula_correct`.
- **Deliverables:**
  - Proofs of the four hooks at the call site, discharged via the enriched carrier +
    `existsBounded_right` + `nf_zone_flatten_navigable_correct`.
  - The provider-instantiation shim (`ExistProviders` built from recursive calls) at the KampPrior
    call site.
  - The three-way disjunction `A` and the closed `:351` arm of `nf_nvar_exist_all_depths`.
- **File targets:** `Theories/Bimodal/.../Prior/KampPrior.lean` (`:351` arm; local hook wiring
  KampPrior:264-320). The import edge is already landed (P6.1) — do NOT re-add it.
- **Consume, do NOT rebuild:** Phases 4/5 `nf_char2_{past,future}_formula`/`_correct`;
  `A_diag`/`_correct` (:763/:808); `A_past`/`A_future`/`_correct` (P1);
  `nf_char2_atom_offdiag_correct` (P2); `nf_zone_exists_trichotomy_k1`
  (NfZoneFlattenNavigable:188); `nf_zone_flatten_navigable(_brick)`/`_correct` (:689/:709);
  `bracketEndChar_kvE`/`_correct` (13.2/13.4) + `ExistProviders`/`BracketCarrierCorrectVPrior`
  (13.1); the k≤1 kv instances via the `_prior` lifts (13.1); `existsBounded_right`
  (VecEAClosure:265); the E[Σ]-fold assets (NfEFold); local `char_k1` / `ih_exist_1` /
  `nf_characterizable_temporal_prior` (KampPrior:264-320/:397). Do NOT consume the abandoned
  `endChar`/`seg`; do NOT consume `nf_char3_deeper_split`; do NOT consume the retired
  unconditional kv theorems.
- **Acceptance criteria (definition of done):**
  - Full-tree `lake build` GREEN.
  - `#print axioms` (or `lean_verify`) on the rewired `nf_nvar_exist_all_depths` live-path theorem
    = exactly `[propext, Classical.choice, Quot.sound]` (0 domain axioms).
  - Live-path sorry count reduced 2 → 1: `:351` closed; `:354` deliberately remains (task 305).
  - `grep "sorry"` across all new v6 material (13.0-13.4, 14) shows only docstring/comment hits
    (no code sorries; sole exception: an explicitly documented strategic-sorry with a
    `follow_up_task`).
  - Task 307 Phase 7 wiring verification is unblocked (report the unblock; do not execute it here).
- **Estimated lines:** 80-150 (one agent run; H8).
- **Guards enforced:** G1, G3, G4, G5 (+v6 extension), G6-as-amended, A1, A2; D1 (import edge
  already landed); final sorry + axiom discipline; N1-N5.
- **Commit:** `task 309 phase 14: discharge hooks + rewire KampPrior:351 + axiom check (R4)`

## Testing & Validation

- After each phase: `lake build` for the touched file and its dependents; grep for new `sorry`.
- Per-phase axiom check (`#print axioms` / `lean_verify`) on the phase's new lemma(s): exactly
  `[propext, Classical.choice, Quot.sound]`.
- **Anchor-cap check (every phase)**: every new `holds` obligation is at the two-point signature
  `(x, t)`; witness growth occurs only inside `BracketFormula n` / `Σ n, VecEA2 n` (G2/G4/G6-amended).
- **A2 discipline check (13.2/13.3/13.4)**: per-sub obligations discharged by inside-out
  `nf_quant_layer_fold_iff` at the innermost layer (grep confirms usage); no navigated arity-3/4
  characteristic; no raw `nf_eval_nf M (k+1)` split leaving a joint (n+1)-ary existential standing;
  no fiber-existential `qnf.2` read at k≥2.
- **Gate-phase check (13.0, 13.3)**: verdict record present in-file + handoff, with the explicit
  routing consequence stated; NO partial theorem, NO sorry landed on a NO-GO.
- **Model-dependence check (13.3)**: EANegationClosure lemmas appear only inside proofs (or, on
  the fallback branch, behind the v7-added uniformization phase) — never cited as uniform formula
  equivalences in a definition.
- Phase 14 gate (definition of done): as in the phase — full-tree GREEN; rewired live-path theorem
  axioms exactly `[propext, Classical.choice, Quot.sound]`; live sorries 2 → 1; new-material sorry
  grep clean; task 307 Phase 7 unblock reported.

## Artifacts & Outputs

- `Theories/Bimodal/.../Kamp/NfMultiAnchorBridge.lean` — F2 verdict record (13.0);
  `ExistProviders` + `BracketCarrierCorrectVPrior` + relativized k≤1 lifts (13.1);
  `bracketEndChar_kvE` + concrete k=2 instance (13.2); k=2 gate verdict + `_correct_two` (13.3);
  general `bracketEndChar_kvE_correct` + direction lemmas (13.4). The abandoned `endChar`/`seg`
  defs, both NO-GO records, the F1 (and, if confirmed, F2) defect records, `bracketEndChar_kv` and
  all task-310/311 landed material remain byte-identical.
- `Theories/Bimodal/.../Prior/KampPrior.lean` — provider-instantiation shim + hook discharge +
  rewired `:351` arm (Phase 14).
- Per-phase handoffs under `specs/309_offdiag_two_anchor_fi_chain/handoffs/`.
- Up to six scoped commits (`task 309 phase 13.0/13.1/13.2/13.3/13.4/14: …`), continuing the
  P1-P5 + P6.1 + P9-P12 history.

## Rollback/Contingency

- Each phase is a scoped commit; revert the last commit to roll back a single phase without
  disturbing earlier green milestones (H9 incremental-commit discipline).
- Phases 1-5, P6.1, Phases 9-12, the three Phase-13 landed lemmas + F1 record, and all
  task-310/311 material are landed and green; the abandoned-route code is inert. If a later phase
  surfaces an unexpected build or axiom problem, roll back to the prior green commit — the `:351`
  sorry simply remains until the carrier lands, with no downstream regression.
- **13.0 branch contingency**: on F2 REFUTED, collapse to surgery-only via `/revise 309` (v7) —
  Phases 13.2-13.4 struck, 13.1 re-scoped, Phase 14 re-pointed. On an unsettled probe, one bounded
  follow-up dispatch, then default to F2-CONFIRMED routing (the redesign does not depend on F2's
  truth, only its expense does).
- **13.3 NO-GO contingency (named fallbacks, not "try harder")**: exclusion-content encoding gap →
  bounded uniformization phase (finite disjunction over the finitely-generated candidate family)
  inserted as 13.2b via `/revise 309` (v7), then ONE gate re-run; carrier-shape defect → defect
  record in the F1/F2 house style + escalation via `/revise 309` (v7) with the record as revision
  authority. The escalation fence (audit caveat C3) bars any implementer-level anchor growth;
  anchors stay `{x,t}` (2, fixed) under all circumstances.
- If 13.4 overruns the H8 dispatch budget, split at the direction seam (13.4a/13.4b) rather than
  inflating a single dispatch.
