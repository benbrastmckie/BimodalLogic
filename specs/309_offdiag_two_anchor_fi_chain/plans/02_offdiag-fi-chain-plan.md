# Implementation Plan: Off-Diagonal Two-Anchor F_i Chain (task 309) — v2

- **Task**: 309 - offdiag_two_anchor_fi_chain
- **Status**: [IMPLEMENTING]
- **Effort**: ~10-16 hours (Phases 1-5 + 6.1 landed; 4 remaining phases, ~380-670 lines Lean)
- **Dependencies**: None (all consumed assets already landed, sorry-free)
- **Research Inputs**:
  - reports/01_offdiag-fi-chain-research.md (H4-verified, Tier 1)
  - reports/02_endpoint-hook-discharge-research.md (H2/H3/H4/H5 blocker audit; the authority for this revision)
- **Artifacts**:
  - plans/01_offdiag-fi-chain-plan.md (v1, superseded)
  - plans/02_offdiag-fi-chain-plan.md (this file)
- **Standards**:
  - .claude/rules/artifact-formats.md
  - .claude/rules/state-management.md
  - .claude/rules/plan-format-enforcement.md
  - .claude/context/formats/plan-format.md
- **Type**: lean4 (hard-mode; H8 phase sizing, postmortem constraints, wave declarations)

## Overview

Build the off-diagonal (`x ≠ t`) two-anchor navigated characteristic — the Rabinovich Cor 5.4
non-trivial-segment `F_i` chain — so `KampPrior.lean:351` can be rewired to
`A_past ∨ A_diag ∨ A_future`, dropping the live-path sorry at `:351` (live sorries 2 → 1; `:354`
stays, per task 305 scope). Definition of done: `lake build` GREEN (full tree), `#print axioms`
on the rewired live-path theorem shows exactly `[propext, Classical.choice, Quot.sound]`
(0 domain axioms), all new material sorry-free, task 307 Phase 7 unblocked.

**Why v2.** Plan v1 landed Phases 1-5 (all sorry-free, committed) plus the cycle-safe import edge
(Phase 6.1, committed f3827e255). But v1's Phase 6 was scoped as ~40-80 lines of "pure glue" and
went **[BLOCKED]** (commit f4bcd2358): the `:351` rewire cannot be written because all three
live-path `_correct` lemmas (`nf_char2_past_formula_correct`, `nf_char2_future_formula_correct`,
`A_diag_correct`) are **hook-parametric** and DEFER the off-diagonal `(x,t)` coupling to
hook-correctness hypotheses that this step must discharge. Report 02 (§1) shows all four hooks
(`h_quant` past NfMultiAnchorBridge:1023-1026, `h_quant` future :1223-1226, `h_past`/`h_fut`/`h_diag`
:787-795) reduce to a single missing primitive (§1.4):

> A closed (model-independent) builder `endChar : NormalForm sig k 3 → TemporalPred` with
> `(endChar qnf).eval_at M atomMap w ↔ nf_eval_nf M k 3 (zoneEnv3 w a b) qnf` for a **navigated**
> witness `w`, two fixed anchors `{a,b} ⊆ {x,t}`, by **recursion on `k`**, arity capped at 3.

This primitive does not exist. Report 02 (§6) prescribes route (a): revise the 309 plan to make the
primitive the **deliverable** (not a hook parameter) via four bounded construction phases. v2 keeps
Phases 1-5 as completed history, records Phase 6.1 as landed, and replaces the single blocked Phase 6
with report §6's Phases 6-9.

### Research Integration

reports/02_endpoint-hook-discharge-research.md integrated in plan version 2 (2026-07-06). This report
is the authority for the revision. Its decisive findings drive v2:

1. **The four hooks reduce to one primitive** (§1.4): the navigated arity-3 endpoint characteristic
   `endChar`, recursion on `k`, anchors ≤2. Once built, `:351` becomes the ~60-120-line glue v1
   assumed. This primitive is now the explicit deliverable of Phases 6-8.
2. **Route (c) REFUTED, stronger than the v1 handoff stated** (§4.1): `nf_char3_deeper_split` provably
   **grows the anchor set** — arity 3→4, anchors `{x,t}→{y,x,t}`, seven zones, interior all-distinct
   (its own statement, NfMultiAnchorBridge:628-637). The v1 route-audit comments
   (NfMultiAnchorBridge:661, :676-678) claiming residuals stay "arity ≤3, anchor set `{x,t}`" are
   **FALSE against `nf_char3_deeper_split`'s statement**. v2 must NOT route hook discharge through
   `nf_char3_deeper_split`; see the corrected anchor-cap statement below.
3. **The correct construction** (§4.2): interior witness `w` stays a **bracket witness** collapsed by
   the navigable brick (G4); the interior `(x,t)` interval is encoded in a **non-trivial segment**
   `seg` (Rabinovich `β_i`), evaluated via `bracketBuildLeft seg` — not left raw as
   `nf_zone_flatten_navigable` currently does (:697), not trivial-top; recursion on `k`, arity ≤3.
4. **Base-case risk** (§4.3): the depth-0 base `nf_nvar_exist_depth0_tl_fn` (NfDepth0Generalized:1615)
   is **existential-at-origin**, whereas the primitive needs a **navigated-point** arity-3
   characteristic at `k=0`. Whether the depth-0 navigated base is directly available or needs a small
   dedicated lemma is the primary open sub-question (Medium risk). Owned + fallback-guarded by Phase 6.

reports/01_offdiag-fi-chain-research.md was integrated in v1 and remains the source for the outer
wrapper (Phases 1-5) and the import DAG (Phase 6.1). Its divergences D1-D4 are preserved below.

### Corrected Anchor-Cap Statement (SUPERSEDES v1 route-audit comments)

**The hook-discharge path MUST keep the anchor set at `{x,t}` (≤2, Rabinovich cap; G2/G4) by the
brick-witness-collapse + non-trivial-segment mechanism (report 02 §4.2), NOT by
`nf_char3_deeper_split`.** `nf_char3_deeper_split` (NfMultiAnchorBridge:625-642) grows arity 3→4 and
anchors `{x,t}→{y,x,t}` (its statement, :628-637); composing it at each depth-descent builds the
forbidden anchor tower (at depth 0 it would demand an arity-`(k+3)` characteristic pinning `k+2`
external anchors). The v1 comments at NfMultiAnchorBridge:661,:676-678 asserting residuals stay
"arity ≤3, anchor `{x,t}`" are false and MUST NOT be trusted by any dispatch. Interior witnesses stay
bracket witnesses; the interior `(x,t)` type rides a non-trivial `seg`; recursion is on `k`, arity
strictly capped at 3 (2 fixed anchors + 1 witness), bottoming out at `k=0`.

### Preserved Assets

Complete, sorry-free, MUST NOT regress. Implementation dispatches consume these; they do not rebuild
or edit them.

| Component | File:line | Status | Role |
|-----------|-----------|--------|------|
| `A_past` / `A_future` (segment-carrying) + `_correct` | NfZoneFlattenNavigable:335/:386 | Landed P1 (f4b9600a1) | non-trivial-segment outer arms |
| `nf_char2_atom_offdiag_{origin,endpoint,correct}` | NfMultiAnchorBridge:364/:375/:391 | Landed P2 (762ea60da) | off-diagonal atom layer (`order 0 1 = true`) |
| `nf_char3_endpoint_tl` / `_correct` | NfMultiAnchorBridge:891/:907 | Landed P3 (010ab616d) | arity-3 endpoint `TemporalPred` shape (hook-parametric; `innerConv` undischarged) |
| `nf_char2_past_formula` / `_correct` | NfMultiAnchorBridge:992/:1015 | Landed P4 (fed9fcd8e) | past-arm F_i wrapper (under `h_quant`) |
| `nf_char2_future_formula` / `_correct` | NfMultiAnchorBridge:1185/… | Landed P5 (b60c63b1a) | future-arm F_i wrapper (under dual `h_quant`) |
| `A_diag` / `_correct` | NfMultiAnchorBridge:763/:808 | Landed (task 307 P2) | diagonal `[t,t]` arm (under `h_past`/`h_fut`/`h_diag`) |
| `nf_char2_formula` / `_correct` | NfMultiAnchorBridge:327 / :345 | Landed (task 308) | diagonal char template |
| `nf_zone_flatten_navigable(_brick)` / `_correct` | NfMultiAnchorBridge:689/:709 | Landed (task 308) | 5-zone `∃w` flatten (hook-parametric; interior raw :697) |
| `nf_char2_zone_split5` | NfMultiAnchorBridge:606 | Landed (task 308) | full-env 5-zone split |
| `nf_char2_diag_exist_tl` / `_correct` | NfMultiAnchorBridge:190/:227 | Landed (task 307) | diagonal 3-zone converter (hook template) |
| `nf_char3_deeper_split` | NfMultiAnchorBridge:625 | Landed | residual discharge — **anchor-growing (3→4); NOT on the hook-discharge path** |
| `nf_zone_exists_trichotomy_k1` | NfZoneFlattenNavigable:188 | Landed (task 307 P3) | `∃x` split into past/diag/future |
| `nf_quant_clause_tl` / `_correct` | NfDepth0Generalized:1745/:1752 | Landed (69998c02d) | shared-ancestor relocation (breaks cycle) |
| `bracketBuildLeft` / `_correct` | VecEATranslation:273/:503 | Landed | non-trivial-segment past bracket |
| `bracketBuildRight` / `_correct` | VecEATranslation:50/:234 | Landed | non-trivial-segment future bracket |
| `nf_nvar_exist_depth0_tl_fn` / `_correct` | NfDepth0Generalized:1615/:1622 | Landed | depth-0 base (existential-at-origin; see §4.3 / Phase 6) |
| `nf_nvar_exist_all_depths` | KampPrior:211 | Landed except `:351`/`:354` sorries | outer recursion; the rewire target |
| Import edge `…Kamp.NfMultiAnchorBridge` in KampPrior | KampPrior imports | Landed P6.1 (f3827e255) | cycle-safe; full-tree GREEN, no regression |

### Source-to-Implementation Mapping (H3, Tier 1)

Transcription source: `~/Projects/Literature/sources/rabinovich_2014/Rabinovich_2014_Proof_of_Kamps_Theorem.md`,
Section 5 (Lemma 5.1 md:134-152, Corollary 5.4 md:154-157).

| Literature item (Rabinovich 2014) | Lean target | Phase |
|-----------------------------------|-------------|-------|
| Cor 5.4 non-trivial `β_i` segment, past/future arms (md:154-157) | `A_past`/`A_future` segment-carrying + `_correct` | P1 (landed) |
| Cor 5.4 endpoint atom characteristic at `x` off-diagonal (`order 0 1 = true`) | off-diagonal atom layer | P2 (landed) |
| Cor 5.4 arity-3 endpoint char shape at navigated witness | `nf_char3_endpoint_tl` | P3 (landed) |
| Cor 5.4 `F_i` chain past/future outer wrapper (md:154-157) | `nf_char2_{past,future}_formula` / `_correct` | P4/P5 (landed) |
| Base of recursion, depth-0 **navigated** arity-3 (Lemma 5.3 base, md:143-152) | `endChar0 : NormalForm sig 0 3 → TemporalPred` + interface | **P6** |
| Non-trivial interior segment `β_i` (`x<w<t` encoding, md:154-157) | `seg : BracketFormula 0` + `holds`-correctness | **P7** |
| `F_{i-1} := α_{i-1} ∧ (β_i Until F_i)` recursive primitive (md:154-157) | `endChar : NormalForm sig k 3 → TemporalPred` + `_correct` (recursion on `k`) | **P8** |
| Lemma 5.1 interior five-zone flatten (md:134-152) | consumed via `nf_zone_flatten_navigable(_brick)` | **P8** |
| Interval split at new point (md:168-171) | consumed via `nf_zone_exists_trichotomy_k1` in rewire | **P9** |
| Cor 5.4 endpoint coupling discharged at call site | `h_quant`/`h_past`/`h_fut`/`h_diag` + `:351` rewire | **P9** |

## Postmortem Constraints

Binding rules for all implementation dispatches. Derived from the v1 Phase 6 blocker, task 307 Phase 7
blocker audit (307 reports/03), task 305 findings, and report 02's H4-verified divergence/route audit.

**Obstruction guards G1-G5 (carry verbatim into every dispatch; task 307 report 03 §4):**
- **G1** — No arity-1 collapse of the off-diagonal. (Refuted: report 02 §1; NfDepth0Generalized:1691-1719.)
- **G2** — No projection-based `VecEA2` / third-free-anchor tower. (Refuted: specs/305 report 40; R2.)
- **G3** — No trivial-top segment on the off-diagonal arms. A closed `pastEnd` under a trivial
  segment is model-independent and cannot re-identify the distinct origin `t`, so the hook is
  unsatisfiable off-diagonal (report 03 §1.2/§2.3). The `(x,t)` coupling MUST ride the non-trivial
  Rabinovich `β_i` segment. **Scoped per D4: applies to `A_past`/`A_future` and the new P7 interior
  segment ONLY — the inner brick's trivial-top exterior brackets are sound and MUST stay untouched.**
- **G4** — `w` stays a bracket witness. Env arity never grows past `{w,x,t}=3 → {x,t}=2`; anchor
  set is `{x,t}` (Rabinovich ≤2 cap). `w` is never a third anchor.
- **G5** — Follow Cor 5.4 `F_i` chains step-by-step (`F_n := α_n`, `F_{i-1} := α_{i-1} ∧ (β_i Until F_i)`).
  No `simp`/`omega`/`aesop` shortcut of a chain step (literature-fidelity policy). Cite
  Rabinovich md:154-157 at every chain-construction step.

**Do NOT**:
- Do NOT route hook discharge through `nf_char3_deeper_split` (Corrected Anchor-Cap Statement above;
  report 02 §4.1). It grows the anchor set (3→4) and builds the forbidden tower. Use the
  brick-witness-collapse + non-trivial-segment mechanism (report 02 §4.2) instead.
- Do NOT trust the v1 route-audit comments at NfMultiAnchorBridge:661,:676-678 ("arity ≤3, anchor
  `{x,t}`") — they are false against `nf_char3_deeper_split`'s statement (report 02 Contradiction Log).
- Do NOT edit `nf_zone_flatten_navigable` inner-`w` trivial-top exterior brackets or
  `nf_char2_diag_exist_tl` (:190) exterior brackets — those legitimately bottom out via the depth-`k`
  IH and are sound (D4).
- Do NOT treat `exist_tl_fn_k` / `char_k1` as top-level consumable assets — they are local
  `let`-bindings inside `nf_nvar_exist_all_depths` (D2), arity-2 existential-at-origin, not the
  arity-3 navigated-point characteristic the hooks need.
- Do NOT introduce any domain axiom or leave any sorry in new material past the phase that owns it
  (the sole documented exception: the Phase 6 §4.3 fallback strategic-sorry skeleton, if triggered —
  see Phase 6).
- Do NOT reintroduce an import cycle. The only new import edge is already landed (P6.1, f3827e255).

**MUST preserve**:
- All Preserved Assets above (sorry-free, axiom-clean), including Phases 1-5 and the P6.1 import edge.
- The `:354` live-path sorry stays (out of scope; task 305).
- Existing full-tree build green (the P6.1 import edge is already in; keep it green).

**Design decisions are SETTLED** (do not re-open without a concrete counterexample):
- The constructive `A` is the Cor 5.4 `F_i` chain (task VERDICT, report 03; corroborated report 02 §4.2).
- The four live-path hooks reduce to one primitive `endChar` (report 02 §1.4) — that primitive is the
  deliverable of Phases 6-8, NOT a hook parameter.
- The primitive is built by brick-witness-collapse + non-trivial segment, recursion on `k`, arity ≤3
  — NOT by `nf_char3_deeper_split` (report 02 §4.1/§4.2).
- Deliverables 1-2 (Phases 1-5) stay off the live import path; the `:351` rewire (Phase 9) is live (D1).

## Goals & Non-Goals

**Goals:**
- Build the depth-0 navigated arity-3 endpoint base `endChar0` + the recursive `endChar` interface (P6).
- Build the non-trivial interior segment `seg` + `holds`-correctness (P7).
- Assemble the recursive primitive `endChar` + `_correct` (recursion on `k`, arity ≤3) (P8).
- Discharge `h_quant`/`h_past`/`h_fut`/`h_diag`, rewire `KampPrior.lean:351` to the three-way
  disjunction, close the `:351` sorry (live sorries 2 → 1) (P9).
- Full `lake build` green; axioms exactly `[propext, Classical.choice, Quot.sound]`.

**Non-Goals:**
- Closing `:354` (task 305 scope).
- Refactoring the inner brick's trivial-top exterior brackets (D4 — sound as-is).
- Any `nf_char3_deeper_split`-based discharge (anchor-tower forbidden; report 02 §4.1).

## Risks & Mitigations

- **Risk (Medium, report 02 §4.3)**: the depth-0 base `nf_nvar_exist_depth0_tl_fn` is
  existential-at-origin, but P6 needs a depth-0 **navigated** arity-3 characteristic. It may not be
  directly available and may need a dedicated base lemma. **Mitigation**: Phase 6 OWNS this risk and
  carries an explicit fallback (documented strategic-sorry skeleton + `follow_up_task`) so a single
  phase failure does not re-block the whole task — see Phase 6.
- **Risk (High)**: P8 recursion-on-`k` assembly is the true difficulty concentration (the ~120-200-line
  core). **Mitigation**: P6 (base + interface) and P7 (interior segment) are landed and independently
  verified before P8, so P8 glues already-green sub-pieces; if P8 overruns H8, split at the base-case /
  step-recursion seam.
- **Risk (recurring)**: a dispatch trusts the false v1 route-audit comment and re-attempts the
  `nf_char3_deeper_split` anchor tower (the 4-strike churn root, report 02 §5). **Mitigation**: the
  Corrected Anchor-Cap Statement + the explicit "Do NOT" carry into every dispatch; P7/P8 verify
  anchors are `{x,t}` as an acceptance criterion.
- **Risk**: the new import edge (already landed P6.1) surfaces a latent axiom leak once P9 puts the
  primitive on the live path. **Mitigation**: P9 runs a full-tree build + `#print axioms` as explicit
  criteria; the newly-imported subtree is grep-verified sorry-free.
- **Risk**: G5 literature-fidelity violated by a tactic shortcut. **Mitigation**: each F_i chain step
  in P7/P8 cites Rabinovich md:154-157; no `simp`/`omega`/`aesop` on a chain step.

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1, 2, 3 | -- (landed) |
| 2 | 4 | 1, 2, 3 (landed) |
| 3 | 5 | 4 (landed) |
| 4 | 6.1 | 1, 4, 5 (landed) |
| 5 | 6 | -- |
| 6 | 7 | 6 |
| 7 | 8 | 6, 7 |
| 8 | 9 | 8 (+ 1, 4, 5) |

Phases 1-5 and 6.1 are landed. The remaining Phases 6→7→8→9 are strictly sequential (each consumes the
prior): the depth-0 base + interface (P6) feeds the interior segment (P7) and the recursion (P8); the
recursion assembles the primitive that P9 uses to discharge the hooks and rewire `:351`. The
orchestrator dispatches exactly one phase per cycle by heading-scan
(`^### Phase [0-9]+(\.[0-9]+)?: .*\[(NOT STARTED|PARTIAL|IN PROGRESS)\]`); Phases 6-9 are the only
open headings.

### Phase 1: Segment-carrying A_past / A_future + _correct [COMPLETED]

Landed, commit f4b9600a1. Replaced the hardcoded `BracketFormula.trivial TemporalPred.top` in
`A_past`/`A_future` (NfZoneFlattenNavigable:335/:386) with a caller-supplied non-trivial segment
`seg : BracketFormula 0`; re-proved `_correct` directly through `bracketBuildLeft_correct` /
`bracketBuildRight_correct` (Rabinovich Cor 5.4 `β_i`, md:154-157). Sorry-free, build green. G3/D4
scoped to the two outer defs. History only — do not re-touch.

### Phase 2: Off-diagonal atom layer for [x,t] (new; D3) [COMPLETED]

Landed, commit 762ea60da. Delivered as `nf_char2_atom_offdiag_{origin,endpoint,correct}`
(NfMultiAnchorBridge:364/:375/:391): the `order 0 1 = true` off-diagonal atom characteristic
(x-preds at navigated `x`, t-preds at origin `t`, order fixed by bracket direction) — NOT the
diagonal-only `nf_char2_atom_part`. Sorry-free; axioms exactly `[propext, Classical.choice, Quot.sound]`.
History only.

### Phase 3: Arity-3 endpoint-hook construction (new; D2) [COMPLETED]

Landed, commit 010ab616d. Delivered as `nf_char3_endpoint_tl` + `_correct`
(NfMultiAnchorBridge:891/:907): the arity-3 `TemporalPred`-valued endpoint characteristic shape,
hook-parametric over `atomPart` and `innerConv`. NOTE (report 02 §2): its `h_inner` hook still demands
`innerConv : NormalForm sig k 4` (arity 4) — it is the SHAPE, not the discharged primitive; the actual
`endChar` primitive is built in Phases 6-8. Sorry-free, build green. History only.

### Phase 4: nf_char2_past_formula + _correct (F_i chain past arm) [COMPLETED]

Landed, commit fed9fcd8e. Delivered as `nf_char2_past_formula` + `_correct`
(NfMultiAnchorBridge:992/:1015): the past-arm F_i outer wrapper. `_correct` proves
`temporal_truth M atomMap t (nf_char2_past_formula … sub_nf) ↔ ∃ x, x < t ∧ nf_eval_nf M (k+1) 2
(Fin.cons x (fun _=>t)) sub_nf` **under the hook hypothesis `h_quant`** (:1023-1026). Sorry-free;
axioms clean. The `h_quant` coupling is DEFERRED — discharged in Phase 9 via the Phase-8 primitive.
History only.

### Phase 5: nf_char2_future_formula + _correct (F_i chain future dual) [COMPLETED]

Landed, commit b60c63b1a. Delivered as `nf_char2_future_formula` + `_correct`
(NfMultiAnchorBridge:1185/…): the future dual, RHS `∃ x, t < x ∧ nf_eval_nf M (k+1) 2 (Fin.cons x
(fun _=>t)) sub_nf` **under the dual `h_quant`** (:1223-1226). Sorry-free; axioms clean. Coupling
DEFERRED to Phase 9. History only.

### Phase 6.1: Cycle-safe import edge (NfMultiAnchorBridge → KampPrior) [COMPLETED]

Landed, commit f3827e255. Added `import …Kamp.NfMultiAnchorBridge` to `KampPrior.lean` (D1,
cycle-safe: only `PriorExpressiveness` + Boneyard import KampPrior). Full-tree `lake build` GREEN
(1704 jobs), no downstream regression; Phases 1-5 material grep-confirmed sorry-free. Live-path
sorries UNCHANGED at 2 (`:351`/`:354` after the +1 import-line shift). This is the ONLY new import
edge permitted; it is done. History only — do not re-add or move it.

### Phase 6: Depth-0 navigated arity-3 endpoint base + interface [COMPLETED]

*(landed as documented §4.3 strategic-sorry skeleton — the §4.3 base-case risk BINDS: a closed
navigated-`w` `TemporalPred` cannot reference the arbitrary carrier anchors `a, b`; anchor pinning
needs Phase-7's non-trivial segment. `endChar0` + `EndCharCarrier` interface + sorry-free
`endChar0_wlocus_correct` landed; full `endChar0_correct` carries ONE flagged strategic sorry
[NfMultiAnchorBridge.lean:1066], follow_up_task = discharge depth-0 navigated base after Phase 7.)*

- **Goal**: Resolve report 02 §4.3. Build (or adapt from `nf_nvar_exist_depth0_tl_fn`) the closed
  depth-0 **navigated** characteristic
  `endChar0 : NormalForm sig 0 3 → TemporalPred`
  with `endChar0_correct`:
  `(endChar0 qnf).eval_at M atomMap w ↔ nf_eval_nf M 0 3 (zoneEnv3 w a b) qnf` for `{a,b} ⊆ {x,t}`,
  and fix the `endChar : NormalForm sig k 3 → TemporalPred` interface (report 02 §1.4) that Phase 8
  recurses on. This is the base of the recursion and OWNS the base-case risk.
- **Deliverables (exact names/signatures)**:
  - `endChar0 : NormalForm sig 0 3 → TemporalPred` (navigated, depth-0, anchors `{a,b} ⊆ {x,t}`).
  - `endChar0_correct : (endChar0 qnf).eval_at M atomMap w ↔ nf_eval_nf M 0 3 (zoneEnv3 w a b) qnf`.
  - The `endChar : NormalForm sig k 3 → TemporalPred` interface signature (the recursion carrier fixed
    for Phase 8), mirroring report 02 §1.4 exactly. `zoneEnv3 w x t = Fin.cons w (Fin.cons x (fun _=>t))`.
- **File targets**: `Theories/Bimodal/.../Kamp/NfMultiAnchorBridge.lean` (new base def + `_correct` +
  interface, alongside `nf_char3_endpoint_tl` :891). Do NOT edit `NfDepth0Generalized.lean` beyond
  reading `nf_nvar_exist_depth0_tl_fn`.
- **Consume, do NOT rebuild**: `nf_nvar_exist_depth0_tl_fn` / `_correct` (NfDepth0Generalized:1615/:1622,
  as a base template — note it is **existential-at-origin**, not navigated: adapt, do not consume the
  shape verbatim); `nf_char2_atom_offdiag_*` (P2) for the atom layer; `zoneEnv3` / `nf_eval_nf` unfolding.
- **Acceptance criteria**: `lake build` green for NfMultiAnchorBridge.lean and dependents; `endChar0_correct`
  typechecks at `k=0` against `nf_eval_nf M 0 3 (zoneEnv3 w a b) qnf`; 0 new sorries (or the documented
  §4.3 fallback below); anchors provably `{a,b} ⊆ {x,t}` (G4); axioms exactly
  `[propext, Classical.choice, Quot.sound]`.
- **§4.3 FALLBACK (single-phase de-block)**: if the depth-0 navigated arity-3 characteristic is NOT
  directly derivable from `nf_nvar_exist_depth0_tl_fn` within the H8 budget, land a **documented
  strategic-sorry skeleton** — `endChar0` fully defined, `endChar0_correct` stated with its proof body
  a single `sorry` carrying an inline `-- STRATEGIC SORRY (task 309 P6, report 02 §4.3): depth-0
  navigated arity-3 base; see follow_up_task` comment — and record a `follow_up_task` in the metadata
  so the orchestrator spawns a dedicated base-case task. This keeps the interface + Phases 7-9 dispatchable
  and prevents a single base-case failure from re-blocking the whole task. The strategic sorry is the
  ONLY permitted sorry in new material and must be explicitly flagged (not silent).
- **Estimated lines**: 80-150 (one agent run; H8).
- **Guards enforced**: G1, G4.
- **Commit**: `task 309 phase 6: depth-0 navigated arity-3 endpoint base`

### Phase 7: Non-trivial interior segment builder + holds correctness [NOT STARTED]

- **Goal**: Build the Rabinovich `β_i` interior segment `seg : BracketFormula 0` whose
  `seg.holds M atomMap x t` encodes the **bounded-interior** zone
  `∃ w, x < w < t ∧ nf_eval_nf M k 3 (zoneEnv3 w x t) qnf` with `w` a **bracket witness**
  (report 02 §4.2). NOT `nf_char3_deeper_split` (anchor-growing); NOT trivial-top (G3); NOT left raw
  as `nf_zone_flatten_navigable:697`. This is the load-bearing sub-piece that closes the `(x,t)`
  coupling within the ≤2 anchor cap.
- **Deliverables (exact names/signatures)**:
  - `seg : BracketFormula 0` (the interior `β_i` segment; parametric on the per-`qnf` interior data).
  - `seg_holds_correct : seg.holds M atomMap x t ↔ (interior encoding of ∃ w, x < w < t ∧ nf_eval_nf
    M k 3 (zoneEnv3 w x t) qnf)` — the exact `holds`-shape `bracketBuildLeft_correct` consumes.
- **File targets**: `Theories/Bimodal/.../Kamp/NfMultiAnchorBridge.lean` (new seg def + `holds`-correctness,
  alongside the P6 base).
- **Consume, do NOT rebuild**: `bracketBuildLeft`/`bracketBuildRight` + `_correct` (VecEATranslation:273/:503,
  :50/:234); `nf_zone_flatten_navigable_brick`'s middle (interior) zone (NfMultiAnchorBridge:689,
  middle zone only); the P6 `endChar0`/`endChar` interface for the per-`qnf` clause; `BracketFormula`
  machinery. Do NOT consume `nf_char3_deeper_split`.
- **Acceptance criteria**: `lake build` green; `seg_holds_correct` typechecks; anchors provably `{x,t}`
  (G4) — verify no third anchor is introduced; 0 new sorries; axioms exactly
  `[propext, Classical.choice, Quot.sound]`; each chain step cites Rabinovich md:154-157 (G5, no
  simp/omega/aesop shortcut).
- **H8 split note**: if it overruns one agent run, split at the (per-`qnf` clause) / (interval assembly)
  seam into 7a/7b.
- **Estimated lines**: 120-200 (one agent run; H8).
- **Guards enforced**: G3, G4, G5.
- **Commit**: `task 309 phase 7: non-trivial interior segment builder`

### Phase 8: Recursive navigated endpoint primitive endChar + _correct [NOT STARTED]

- **Goal**: Assemble the missing primitive (report 02 §1.4)
  `endChar : NormalForm sig k 3 → TemporalPred`
  by **recursion on `k`**: base = Phase 6 `endChar0`; step = navigable-brick flatten of each sub's
  `∃w'` with Phase-7 segments for the interior and Phase-6/8 endpoints for the exteriors, keeping
  arity strictly ≤3 (report 02 §4.2). Prove `endChar_correct`:
  `(endChar qnf).eval_at M atomMap w ↔ nf_eval_nf M k 3 (zoneEnv3 w a b) qnf`, `{a,b} ⊆ {x,t}`.
- **Deliverables (exact names/signatures)**:
  - `endChar : NormalForm sig k 3 → TemporalPred` (recursion on `k`; base P6, step brick+seg).
  - `endChar_correct : (endChar qnf).eval_at M atomMap w ↔ nf_eval_nf M k 3 (zoneEnv3 w a b) qnf`.
- **File targets**: `Theories/Bimodal/.../Kamp/NfMultiAnchorBridge.lean` (recursive def + `_correct`,
  alongside Phases 6/7).
- **Consume, do NOT rebuild**: Phase 6 `endChar0`/`endChar0_correct` (base); Phase 7 `seg`/`seg_holds_correct`
  (interior); `nf_zone_flatten_navigable(_brick)` / `_correct` (NfMultiAnchorBridge:689/:709) for the
  5-zone flatten; `nf_char3_endpoint_tl` (P3) for the endpoint shape; `nf_quant_clause_tl_correct`
  (NfDepth0Generalized:1752). Do NOT consume `nf_char3_deeper_split` (anchor-growing; report 02 §4.1).
- **Acceptance criteria**: `lake build` green; `endChar_correct` typechecks against `nf_eval_nf M k 3
  (zoneEnv3 w a b) qnf` for all `k`; 0 new sorries; `#print axioms` on `endChar_correct` exactly
  `[propext, Classical.choice, Quot.sound]`; anchors provably `{x,t}` at every recursion depth (G4);
  each F_i step cites md:154-157 (G5).
- **H8 split note**: if it overruns, split at the base-case wiring / step-recursion seam.
- **Estimated lines**: 120-200 (one agent run; H8).
- **Guards enforced**: G1, G2, G4, G5.
- **Commit**: `task 309 phase 8: recursive navigated endpoint primitive endChar`

### Phase 9: Discharge four hooks + KampPrior:351 rewire + full-tree axiom check [NOT STARTED]

- **Goal**: At the `KampPrior.lean` `:351` call site, instantiate `quantEnd`/`seg`/`pastEnd`/`futureEnd`/
  `diagChar` from Phases 6-8 and **prove** the four deferred hooks —
  `h_quant` (past, NfMultiAnchorBridge:1023-1026), `h_quant` (future, :1223-1226), and
  `h_past`/`h_fut`/`h_diag` (`A_diag_correct`, :787-795) — via `endChar_correct` (Phase 8) +
  `nf_zone_flatten_navigable_correct`. Then set
  `A := nf_char2_past_formula … ∨ A_diag … ∨ nf_char2_future_formula …`, bridge the `Fin 1 → ∃x`
  form (`h_env_eq` shape, KampPrior:276-290), `rw [nf_zone_exists_trichotomy_k1]`, discharge the
  three arms with a three-way `or_congr` fed by `nf_char2_past_formula_correct` / `A_diag_correct` /
  `nf_char2_future_formula_correct`. Close the `:351` sorry (live sorries 2 → 1).
- **Deliverables**:
  - Proofs of the four hooks (`h_quant` past+future, `h_past`/`h_fut`/`h_diag`) at the call site,
    discharged via `endChar_correct` + `nf_zone_flatten_navigable_correct`.
  - The three-way disjunction `A` and the closed `:351` arm of `nf_nvar_exist_all_depths`.
- **File targets**: `Theories/Bimodal/.../Prior/KampPrior.lean` (`:351` arm; local hook wiring
  KampPrior:264-320). The import edge is already landed (P6.1) — do NOT re-add it.
- **Consume, do NOT rebuild**: Phases 4/5 `nf_char2_{past,future}_formula` / `_correct`; `A_diag` /
  `_correct` (NfMultiAnchorBridge:763/:808); `nf_zone_exists_trichotomy_k1` (NfZoneFlattenNavigable:188);
  Phase 8 `endChar` / `endChar_correct`; `nf_zone_flatten_navigable_correct` (:709); local
  `ih_exist_1` / `exist_tl_fn_k` / `char_k1` (KampPrior:264-320) for the `Fin 1 → ∃x` bridge.
- **Acceptance criteria (definition of done)**:
  - Full-tree `lake build` GREEN.
  - `#print axioms` (or `lean_verify`) on the rewired `nf_nvar_exist_all_depths` live-path theorem =
    exactly `[propext, Classical.choice, Quot.sound]` (0 domain axioms).
  - Live-path sorry count reduced 2 → 1: `:351` closed; `:354` deliberately remains (task 305 scope).
  - `grep "sorry"` across NfZoneFlattenNavigable.lean + NfMultiAnchorBridge.lean new material (Phases
    6-8) shows only docstring/comment hits (no code sorries; exception: a P6 §4.3 strategic sorry if
    that fallback was triggered — which must then be resolved or carried as a documented follow_up_task
    before this phase's build can be considered clean on the live path).
  - Task 307 Phase 7 wiring verification is unblocked (report the unblock; do not execute it here).
- **Estimated lines**: 60-120 (one agent run; H8).
- **Guards enforced**: D1 (import edge already landed), final sorry + axiom discipline.
- **Commit**: `task 309 phase 9: discharge hooks + rewire KampPrior:351 + axiom check`

## Testing & Validation

- After each phase: `lake build` for the touched file and its dependents; grep for new `sorry`.
- Per-phase axiom check (`#print axioms` / `lean_verify`) on the phase's new `_correct` lemma:
  exactly `[propext, Classical.choice, Quot.sound]`.
- Phase 9 gate (definition of done):
  - Full-tree `lake build` GREEN.
  - `#print axioms` on the rewired live-path theorem: exactly `[propext, Classical.choice, Quot.sound]`,
    0 domain axioms.
  - Live-path sorry count reduced 2 → 1 (`:351` closed; `:354` remains).
  - `grep "sorry"` across the new material (Phases 6-8): only docstring/comment hits (no code sorries;
    or a single documented P6 §4.3 strategic sorry with a `follow_up_task`).
- Regression: task 307 Phase 7 wiring verification is unblocked (report the unblock, do not execute here).

## Artifacts & Outputs

- `Theories/Bimodal/.../Kamp/NfMultiAnchorBridge.lean` — `endChar0` + interface (P6), interior segment
  `seg` (P7), recursive `endChar` + `_correct` (P8).
- `Theories/Bimodal/.../Prior/KampPrior.lean` — hook discharge + rewired `:351` arm (P9).
- Four scoped commits (`task 309 phase 6/7/8/9: …`), continuing the P1-P5 + P6.1 history.

## Rollback/Contingency

- Each phase is a scoped commit; revert the last commit to roll back a single phase without disturbing
  earlier green milestones (H9 incremental-commit discipline).
- Phases 1-5 + the P6.1 import edge are landed and green; if a later phase surfaces an unexpected build
  or axiom problem, roll back to the prior green commit — the `:351` sorry simply remains until the
  primitive lands, with no downstream regression.
- If Phase 6's depth-0 navigated base is intractable within H8, the §4.3 fallback (documented
  strategic-sorry skeleton + `follow_up_task`) keeps the interface and Phases 7-9 dispatchable; a
  single base-case failure does not re-block the task.
- If Phase 7 or Phase 8 overruns the H8 dispatch budget, split at the seams named in each phase
  (7a/7b interior; P8 base-wiring / step-recursion) rather than inflating a single dispatch.
