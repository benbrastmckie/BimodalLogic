# Implementation Plan: Task #349 (v7 — enriched-segment bracket carrier `endInterval`)

- **Task**: 349 - Build the recursive navigated endpoint primitive as
  `endInterval : (k) → BracketEndCharCarrierV sig k` + `endInterval_correct` on the
  **enriched-segment bracket carrier** (`bracketEndChar_kvE2Ext` family, carrier 3)
- **Status**: [NOT STARTED]
- **Effort**: 16 hours
- **Dependencies**: Task 351 (LANDED — `nfEval_le2_reduction` family, green, sorry-free)
- **Research Inputs**:
  - reports/09_carrier-synthesis.md (AUTHORITATIVE — THE carrier decision + full v7
    architecture: carrier type §3.1, recursion step §3.2, green assets §3.3, the 5 new
    lemmas §3.4, phase breakdown §3.5, boneyard actions §4, adversarial self-check §5)
  - reports/10_q3-uniform-k-probe.md (AUTHORITATIVE — the GO verdict on Q3: uniform-k
    fold-determinacy holds via depth-general `nf_eval_unique` (NormalForm.lean:245),
    machine-confirmed; the exact Phase-1 target `nf_eval_nfk_iff_efold`; F2 structurally
    inapplicable at full arity 4; corrects report 09's read of the quarantine)
  - reports/09_teammate-a-carrier-structure.md / 09_teammate-b-completeness.md /
    09_teammate-c-f1-prior.md / 09_teammate-d-completability.md (faithfulness A/B,
    C′-refutation C, completability D evidence)
  - reports/09_boneyard-correctness-audit.md (archival evidence: zero carrier restores)
  - Context — the four prior carrier failures: reports/04 (arity-4 bridge non-theorem),
    05 (v5 residual-conditioned architecture), 06 (Phase-3 gate adjudication),
    07 (Rabinovich faithfulness deep-check), 08 (Phase-3 design resolution)
- **Artifacts**: plans/07_enriched-bracket-carrier.md (this file); supersedes
  plans/06_faithful-two-endpoint-carrier.md (v6, Phase 3 [BLOCKED])
- **Standards**: plan-format.md; status-markers.md; artifact-management.md; tasks.md;
  lean4 extension rules; reference-grounding.md (H3 Tier-1 lean4 override);
  plan-format-enforcement.md
- **Type**: lean4
- **Lean Intent**: true
- **reports_integrated**: [09_carrier-synthesis.md, 10_q3-uniform-k-probe.md]

## Overview

Complete task 349 on **carrier 3 — the enriched-segment bracket carrier**
(`bracketEndChar_kvE2Ext` family), the decision of the 5-report research team + decisive
synthesis (report 09) + GO feasibility probe (report 10). The codomain stays the frozen v6
type `BracketEndCharCarrierV sig k := NormalForm sig k 3 → VVecEA2` (CarrierK1V.lean:365);
the v6 Phase-3 hole `endIntervalStep` (CarrierK1V.lean:2144, currently the honest
empty-disjunction placeholder `⟨[]⟩`) is filled by generalizing the **green k=2**
`bracketEndChar_kvE2Ext` (ExteriorBracket.lean:661) to symbolic `k`; correctness is stated
as **`EndIntervalCorrectPrior`** — the biconditional under `semantic_prior_UZ`/`semantic_prior_SZ`
with provider obligations threaded exactly as the green k=2 gate
`bracketEndChar_kvE2Ext_correct_two_prior_frag` (ExteriorBracket.lean:1069) carries them.

**Carrier 3 in one paragraph** (report 09 §0-§2, report 10 §4): interior content is read at
**FULL arity 4** (`nf_eval_nf M k 4 (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t)))) σ`) —
never through the lossy arity-1 projection `nfk_projFresh`, which is exactly the collapse F2's
refutation of carrier 2 requires (`f2_sub_proj_eq`, RefutationF2.lean:471) and what carrier 3
structurally avoids. Joint claims are pinned against the honest anchor pair by **two adjacent
double-anchor exterior brackets** (`kvE2_extBracketPast` at `x`, `kvE2_extBracketFut` at `t`)
composed by **Lemma-7.6 adjacency** (`bracketEndChar_kvE2Ext_holds_iff`,
ExteriorBracket.lean:674 — "the degenerate Lemma 7.6 conjunction"). The result is a closed
Formula (VVecEA2) under Prior, which is the exact interface the downstream consumer
`nf_nvar_exist_all_depths` (KampPrior.lean:212; n=1 arm = live sorry at :361) is already
wired to consume via task 309 Phase 14.

**Q3 is resolved GO** (report 10): the determinacy wall that killed carrier 2 provably cannot
recur — `nf_eval_unique` (NormalForm.lean:245) is depth-general (proved by
`induction k generalizing n env`), machine-confirmed at the crux type
(`NormalForm sig k 4` co-satisfaction at a fixed arity-4 env forces equality, uniformly in
symbolic `k`, via `lean_run_code` with zero diagnostics). What remains is **index-structural
construction** — the general-`k` fold bridge `nf_eval_nfk_iff_efold` (Phase 1) and
`k`-generalized exterior brackets (Phase 2) — bounded engineering with every determinacy
input already proved, not an open mathematical question.

**Definition of done**: `endInterval`/`endInterval_correct` (the `EndIntervalCorrectPrior`
biconditional) sorry-free; `lean_verify` on `endInterval_correct` = exactly
`[propext, Classical.choice, Quot.sound]`; scoped `lake build` GREEN at every phase and
whole-tree GREEN at Phase 6; zero edits to the 7 frozen providers (all frozen decls
byte-identical), `KampPrior.lean`, `Lemma32Reduction.lean`, or `nf_nvar_exist_all_depths`'s
signature; `endInterval_correct` is a top-level citable name that task 309 Phase 14 / task
350 can consume downstream.

### Scope note — the "frozen `EndCharCarrier`" lift stands; the carrier is now the enriched bracket

The v6 lift of the original task description's `EndCharCarrier sig k` (Base.lean:1007) freeze
**stands** — nothing in v7 reads the single-point Prop carrier as the recursion motive. v7
records the further refinement (report 09 §1-§2, Q4/Q5): the recursion carrier is the
**enriched-segment bracket** — a **closed-Formula-under-Prior** object
(`BracketEndCharCarrierV sig k = NormalForm sig k 3 → VVecEA2`) — and **not** the Prop-valued
navigated carrier D (`→ TemporalPred`). Justification (report 09): pure-D is *equally
faithful* (A/B/C's faithfulness criteria are all satisfied by carrier 3 once carrier 2 and
carrier 3 are separated) but *strictly less completable* — its recursion core
`navMultiAnchorForm(_correct)` is UNBUILT (docstring skeleton only, Base.lean:1831/1957/1969),
its unconditional single-point cousin is provably false (`endCharN0_correct_infeasible`,
Base.lean:1779), and its Prop output mismatches the `Formula`-under-Prior downstream interface
(KampPrior.lean:361). Faithfulness is a tie; completability + downstream wiring decide for
carrier 3.

### Research Integration

Report 09 supplies the architecture followed verbatim here (carrier type, correctness shape,
green assets, new-lemma ledger, phase skeleton). Report 10 supersedes report 09 §Q3's
"Medium / leaning feasible" with **GO on determinacy**, corrects §5's read of the quarantine
(the quarantined `kvE` was the *un-repaired* single-anchor carrier whose own failure record
prescribes exactly the double-anchor repair carrier 3 implements), and names the exact
Phase-1 target lemma. **One deliberate deviation from report 09 §3.5**: its Phase 5 ("wire
KampPrior.lean:361") is OUT of v7 scope — the delegation scope guard forbids editing
`KampPrior.lean`, and the transfer note at KampPrior.lean:352-360 already assigns that wiring
to task 309 Phase 14. v7 delivers the citable `endInterval_correct` name; downstream wiring
is 309/350 work.

### Preserved Assets

Complete, green, sorry-free — **consume by name, do NOT rebuild or regress**.

| Component | File:line | Status | Role in v7 |
|-----------|-----------|--------|------------|
| `bracketEndChar_kvE2Ext` (enriched k=2 carrier) | ExteriorBracket.lean:661 | [COMPLETED] | THE k=2 template the step generalizes |
| `bracketEndChar_kvE2Ext_holds_iff` (Lemma-7.6 adjacency destructuring) | ExteriorBracket.lean:674 | [COMPLETED] | composition law: interior ∧ bracketPast@x ∧ bracketFut@t |
| `bracketEndChar_kvE2Ext_correct_two_prior_frag` (GREEN k=2 gate) | ExteriorBracket.lean:1069 | [COMPLETED] | the correctness statement + proof TEMPLATE (`EndIntervalCorrectPrior` mirrors its hypotheses verbatim) |
| `kvE2_extBracketPast/Fut` + `_sound`/`_complete` | ExteriorBracket.lean:432/456/583+ | [COMPLETED] | per-side exterior-bracket discharge (k=2); Phase 2 generalizes their `habove`/`hbelow` inputs to depth `k` |
| `bracketEndChar_kvE2` interior gate + `_complete_two_prior`/`_sound_two_prior_frag`/`_correct_two_prior_frag` | OuterGate.lean:70/147/268/359 | [COMPLETED] | interior gate soundness/completeness (k=2 template) |
| `ExistProviders` / `existF` (provider interface) | PriorInterface.lean:38-40 | [COMPLETED] | the depth-`k` closed-formula provider channel (already factored; resolves the v6 Phase-3 signature tension) |
| `nf_eval_unique` (depth-general fold-fiber determinacy) | NormalForm.lean:245 | [COMPLETED] | THE determinacy input for every layer of the Phase-1 bridge and Phase-2 brackets (report 10 C2/C3) |
| `nf_eval_nf1_iff_efold` (depth-1 whole-evaluation bridge) | Kamp/NfEFold.lean:490 | [COMPLETED] | the k=1 instance Phase 1's `nf_eval_nfk_iff_efold` generalizes |
| `nf_quant_layer_fold_iff` (arity-general depth-0 fold engine) | Kamp/NfEFold.lean:391 | [COMPLETED] | iterated inside-out in Phase 1's forward direction |
| `bracketEndChar_k1v` family + k1v helper kit | CarrierK1V.lean:433/513-2039 | [COMPLETED] | k=1 base of the `Nat.rec`; proof kit |
| `BracketEndCharCarrierV` (frozen v6 codomain) | CarrierK1V.lean:365 | [COMPLETED] | the recursion motive (UNCHANGED) |
| `endInterval` skeleton + `EndIntervalCorrect` (v6 Phase 2) | CarrierK1V.lean:2159/2179 | [COMPLETED] | `Nat.rec` shape reused; `EndIntervalCorrect` superseded by `EndIntervalCorrectPrior` (bounded revise, Phase 3) |
| `nfEval_le2_reduction` (Rabinovich Lem 3.2(2)) | Lemma32Reduction.lean:535 | [COMPLETED] task 351 | Step-A arity reduction (frozen file — consume only) |
| `nfEval_le2_reduction` depth family (`nfEval3/4_reduction`, `endCharStep_reduceA`/`_quant_reduceA`, `navPiece_reduce`, `endCharNav0_correct`) | NavigatedEndChar.lean:75-459 | [COMPLETED] v5/v6 | green Step-A reductions — preserve verbatim |
| `nf_zone_flatten_navigable` / `_correct` | Base.lean:667/687 | [COMPLETED] | Prop-valued x,t-explicit merge tool |
| `seg` / `seg_holds_correct` / `seg_holds_coupled`; `endChar0`/`endChar0_correct` | Base.lean:1127-1162 / 995+ | [COMPLETED] | interior segment + depth-0 base (inert w.r.t. the recursion motive; cite, do not retype) |
| `f2_relativized_refutation` (carrier-2 refutation) | RefutationF2.lean:859 | [COMPLETED] | NEGATIVE guardrail — the machine-checked reason `kv_body` is dead |
| `endCharN0_correct_infeasible` | Base.lean:1779 | [COMPLETED] | NEGATIVE guardrail — single-point non-theorem |

### The 7 FROZEN providers (do NOT edit their proofs; extend only ADDITIVELY)

1. `NfMultiAnchorBridge/SharedWitness.lean` 2. `NfMultiAnchorBridge/SubBracket2V.lean`
3. `NfMultiAnchorBridge/OuterGate.lean` 4. `NfMultiAnchorBridge/ExteriorBracket.lean`
5. `NfMultiAnchorBridge/ExteriorZoneTriage.lean` 6. `Kamp/ExteriorNegation.lean`
7. `Kamp/ExteriorNegationPast.lean`

The enriched carrier lives in the ExteriorBracket family, so v7 extends it **ADDITIVELY
ONLY**: all new `k`-generalized declarations land in a **new module**
`NfMultiAnchorBridge/ExteriorBracketK.lean` (importing `ExteriorBracket`) — the existing k=2
proofs and every frozen decl stay **byte-identical**. Per-phase landing files are declared in
each phase below. `CarrierK1V.lean`, `NfEFold.lean`, `PriorInterface.lean`, `Base.lean`, and
`NavigatedEndChar.lean` are NOT frozen (additive edits sanctioned); `KampPrior.lean`,
`Lemma32Reduction.lean`, and `nf_nvar_exist_all_depths`'s signature are NO-EDIT.

### Boneyard actions (per reports 09 §4 / 10 §3 — minimal)

| Action | Item | Rationale |
|--------|------|-----------|
| **RESTORE: nothing** for the carrier | — | carrier 3 consumes only live green assets (boneyard audit §3c: zero carrier restores) |
| **REFERENCE-ONLY, never restore** | `Boneyard/MergedBracketQuarantine/MergedBracketQuarantine.lean` (`bracketEndChar_kvE {k}` :269, `kvE_body`) | holds the symbolic-`k` per-sub enriched body PATTERN Phase 4 imitates — but it is `#exit`-archived, and its NO-GO record (:295-372) refutes the *un-repaired single-anchor* carrier. Extract only the faithful per-sub `kvE_body` shape; verify each extracted piece against the live k=2 `kvE2Ext`; never import the file or the merged-bracket nesting |
| **NOT NEEDED for 349** | `RabinovichTranslation` / `SeparationBridge` (Kamp/Boneyard/) | downstream-only (350/309 FO→TL wrap) — optional restores out of v7 scope |
| **KEEP-ARCHIVED** | carrier-2 line (`kv_body`/CarrierKv route), `NavigatedEndCharSinglePoint`, all confirmed-dead Kamp/Boneyard files | F2-refuted / non-theorem / superseded |

### Source-to-Implementation Mapping (H3, Tier 1 — Rabinovich 2014)

Source: `~/Projects/Literature/sources/rabinovich_2014/Rabinovich_2014_Proof_of_Kamps_Theorem.md`
(`md:NNN` line refs; PDF pages per reports 09/10). 5-column format per the lean4
reference-grounding override.

| Source (Rabinovich 2014) | Prop/Location | Lean Identifier | Type Signature / Fact | Status |
|--------------------------|---------------|-----------------|-----------------------|--------|
| Lemma 3.2(2) — reduce to ≤2-free conjunction, witness bound | md:119 (p.4) | `nfEval_le2_reduction` | arity-`n` → conjuncts of anchor-arity ≤3 | transcribed |
| Prop 4.3 — innermost ∃-fold of the quantifier layer | PDF p.6 | `nf_quant_layer_fold_iff` (NfEFold:391); Phase-1 general-`k` iteration `nf_eval_nfk_iff_efold` | fold determinacy per layer, off-fiber via `nf_eval_unique` | transcribed (depth-0/1); pending (general `k`, Phase 1) |
| Prop 4.2 — uniform negation/exclusion disjunctions (the joint-pinning channel) | md:165 (p.7) | `kvE2_extBracketPast/Fut` (k=2); Phase-2 `k`-generalized brackets | per-side exterior exclusion pinned at the honest anchors | transcribed (k=2); pending (general `k`, Phase 2) |
| Lemma 7.6 — adjacency composition of (z0,z1)- and (z1,z2)-∨∃∀ formulas | md:413 (§7) | `bracketEndChar_kvE2Ext_holds_iff` (:674); Phase-4 general-`k` analog | holds ↔ interior ∧ bracketPast@x ∧ bracketFut@t (degenerate adjacency conjunction) | transcribed (k=2); pending (general `k`, Phase 4) |
| Def 7.13 — (z0,…,zk,∞)-∨∃∀ multi-anchor bracket family | md:451 (§7) | `BracketEndCharCarrierV` / VVecEA2 disjuncts | the two-endpoint enriched bracket type discipline | transcribed |
| Cor 5.4 — endpoint characteristic chain (the recursion this task builds) | md:255 (§5) | `endInterval` / `endIntervalStep` / `endInterval_correct` | `(endInterval k qnf).holds M atomMap x t ↔ ∃ w, nf_eval_nf M k 3 [w,x,t] qnf` under Prior | pending (Phases 3-5) |
| Prop 3.5 — single-point TL collapse ONLY at ≤1 free var | md:137 (p.5) | downstream 309/350 extraction | NOT inside the recursion (postmortem strike 1) | out-of-scope guardrail |

**Transcription discipline**: the source wins over instinct. The interior stays full-arity
(Def 7.13 keeps joint content); pinning is by Prop-4.2-style exclusions at the honest anchor
pair (the quarantine record's own "Required behavior", MergedBracketQuarantine.lean:353-357);
composition is Lemma-7.6 adjacency, never `liftInterval`-style arity-m lifting.

### New-lemma ledger (report 09 §3.4 + report 10, enumerated across phases)

| # | New lemma | Phase | Feasibility |
|---|-----------|-------|-------------|
| 1 | `nf_eval_nfk_iff_efold` general-`k` fold bridge (+ index plumbing `efold_of_nfk`/`nfk_dropFresh`/`nfk_zoneSpec`) | 1 | **Bounded-Medium** — index-structural transcription; every semantic input proved (`nf_eval_unique M k n env` off-fiber; `nf_quant_layer_fold_iff` iterated inside-out); NfEFold:388 asserts "the proof is index-structural" |
| 2 | `k`-generalized exterior brackets `kvE_extBracketPast/Fut_sound`/`_complete` (depth-`k` `habove`/`hbelow`) | 2 | **Medium** — same shape as the green k=2, one fold-layer deeper; determinacy supplied by `nf_eval_unique M k` (report 10 C6/C11) |
| 3 | `endIntervalStep` general-`k` body (kvE_body pattern + double-anchor brackets) + `EndIntervalCorrectPrior` statement | 3 | **Bounded** — k=2 body exists (`kvE2Ext`); generalize provider arities; statement mirrors the k=2 gate hypotheses verbatim |
| 4 | general-`k` step sound/complete (generalizing `kvE2Ext_correct_two_prior_frag`) | 4 | **Medium** — the residual construction risk; k=2 proof is the working template; exterior residue discharged by Phase-2 brackets |
| 5 | provider-step + `Nat.rec` induction assembly (`endInterval_correct`) | 5 | **Medium** — provider-parametric within 349 scope (`ExistProviders` interface already factored); termination/well-foundedness must typecheck; full unconditional provider discharge via `nf_nvar_exist_all_depths` is downstream 309 (KampPrior is NO-EDIT) |

(Report 09's lemma 5 "wire KampPrior.lean:361" is out of v7 scope — see Research Integration.)

## Goals & Non-Goals

**Goals**:
- Build the general-`k` inside-out fold bridge `nf_eval_nfk_iff_efold` (the k-analog of the
  green `nf_eval_nf1_iff_efold`), consuming the already-green depth-general `nf_eval_unique`.
- Generalize the k=2 exterior brackets to symbolic `k` (depth-`k` `habove`/`hbelow` inputs),
  additively, in a new `ExteriorBracketK.lean` module.
- Fill the `endIntervalStep` hole (CarrierK1V.lean:2144) with the general-`k` enriched body:
  full-arity-4 interior via depth-`k` providers + two adjacent double-anchor exterior
  brackets (Lemma-7.6 adjacency). Bounded-revise `EndIntervalCorrect` →
  `EndIntervalCorrectPrior` (add `semantic_prior_UZ/SZ` + the provider obligations exactly
  as the k=2 gate carries them).
- Prove step soundness + completeness generalizing the green k=2 gate; close the recursion
  by induction on `k`; `endInterval_correct` sorry-free with axioms exactly
  `[propext, Classical.choice, Quot.sound]`.

**Non-Goals**:
- Editing `KampPrior.lean` (including retiring the n=1 sorry at :361 — that is task 309
  Phase 14, downstream), `Lemma32Reduction.lean`, `nf_nvar_exist_all_depths`'s signature,
  or ANY of the 7 frozen provider files' existing decls.
- Any single-point `EndCharCarrier→TemporalPred` recursion carrier, `navPieceForm(_correct)`,
  `h_res` threading, `kv_body`/`nfk_projFresh` arity-1 projection, or arity-4 collapse —
  all machine-refuted (postmortem).
- Restoring any Boneyard file (reference-only extraction from `MergedBracketQuarantine` is
  sanctioned; imports/restores are not).
- The top-level ≤1-free closed-`TemporalPred` extraction (Prop 3.5 / Thm 4.4) — downstream
  350/309.
- Re-deriving task 351's reductions, the k1v/k2 kits, or any preserved asset.

## Postmortem Constraints

Binding rules for all implementation dispatches. Derived from the FOUR carrier strikes, the
carrier-type root cause, and the research-team resolution. Landing any forbidden construct
is a `[BLOCKED]` escalation, never a silent workaround.

**The FOUR strikes (root cause: carrier TYPE, not proof effort).**
1. **Single-point v4/v5 non-theorem**: the `EndCharCarrier := NormalForm sig k 3 → TemporalPred`
   line (`navBrickForm` → `navMultiAnchorForm` → `navPieceForm` → v5 `h_res` re-freeze) asked a
   one-point object (function of `w` alone) to characterize a two-free-variable object.
   Machine-refuted: `endCharN0_correct_infeasible` (Base.lean:1779) survives the `h_res`
   escape at every k ≥ 1 (reports 04/06/07).
2. **Syntactic-VVecEA2 v6 contradiction**: the v6 Phase-3 signature froze `rec : →VVecEA2`
   threading while specifying `bracketFromLists` assembly, which needs a closed-formula
   `charF : →Formula` provider that neither `rec` nor CarrierK1V's import scope could supply
   — and the closed-formula fiber-projected escape was F1-refuted
   (`bracketEndChar_kv_factors`, CarrierKv.lean:422). v6 Phase 3 [BLOCKED].
3. **`kv_body` C′ F2-refuted**: the general-`k` carrier 2 reads `qnf.2` through the LOSSY
   arity-1 projection `nfk_projFresh`; two genuinely distinct subs collapse
   (`f2_sub_proj_eq`, RefutationF2.lean:471) and `f2_relativized_refutation`
   (RefutationF2.lean:859) kills it on a genuine Prior model for EVERY provider `charF`.
4. **`navMultiAnchorForm`-unbuilt pure-D dead-end**: the Prop-valued navigated carrier's
   recursion core is a docstring skeleton only (Base.lean:1831/1957/1969), its unconditional
   single-point cousin is provably false, and its Prop output mismatches the
   Formula-under-Prior downstream (KampPrior.lean:361).

**Root cause + resolution**: every strike chose a carrier whose per-sub channel loses joint
content (single-point read; arity-1 projection) or cannot be built/consumed. The 5-report
research team + synthesis (report 09) + GO probe (report 10) resolved it: carrier 3 keeps
interior content at FULL arity 4 (no projection — `nf_eval_unique` forbids the F2 collapse at
every depth), pins joint claims at the honest anchor pair via double-anchor exterior brackets
(exactly the repair the quarantine NO-GO record prescribed), composes by Lemma-7.6 adjacency,
threads providers via the factored `ExistProviders` interface (resolving strike 2's signature
tension), and emits the closed Formula the downstream interface requires (mooting strike 4).

**Do NOT** (each is machine-grounded; violation = STOP + `[BLOCKED]`):
1. Re-introduce the single-point `→TemporalPred` recursion carrier or any recursion motive
   read at a single world `w` (strike 1; `endCharN0_correct_infeasible`).
2. State `navPieceForm_correct` or any single-point closed-formula `↔` for a ≥2-free-anchor
   target (shape `temporal_truth w φ ↔ ∃v, nf_eval_nf … [v,w,x,t] sub`) — if this goal shape
   appears, the carrier has regressed: STOP.
3. Thread an `h_res` (atom-residual) hypothesis to pin anchors — no Rabinovich analogue
   (report 07 §3.3); non-theorem to thread (report 06 §SQ3).
4. Read any sub through the arity-1 projection `nfk_projFresh`, or resurrect
   `kv_body`/`bracketEndChar_kv` (strike 3; F2-dead for every provider). Interior obligations
   are stated at FULL arity 4, period.
5. Use an arity-4 enclosing-pair/single-point collapse or any `nfRestrict`-based arity
   collapse on the interior read (report 04 non-theorems). Full-arity reading is not
   collapse: the arity-4 env `[x1,w,x,t]` keeps `x1,w` as bracket witnesses, anchors `{x,t}`.
6. Use the per-pair `∀ij∃w` distribution (non-theorem for n ≥ 3); the witness stays outside
   the reduced inner form.
7. Fake green: no `sorry`, no `def X := True`/`Unit`/vacuous stub, no `simp`/`omega`/`aesop`
   shortcut that silently weakens a Rabinovich chain step (G5). A stuck main target is
   `[BLOCKED]` + exact `lean_goal` record + `/spawn 349`. The Phase-2/v6 honest
   empty-disjunction placeholder pattern (`⟨[]⟩`) is the ONLY sanctioned deferred-body form,
   and only for a hole a later phase explicitly fills.
8. Import `MergedBracketQuarantine` or restore any Boneyard file — extraction is
   reference-only, verified against the live k=2 `kvE2Ext`.

**MUST preserve** (see Preserved Assets table — consume by name, never rebuild or regress):
the k=2 enriched gate + exterior-bracket machinery (ExteriorBracket.lean, FROZEN),
`nf_eval_unique`, `nf_eval_nf1_iff_efold`, `nf_quant_layer_fold_iff`, the green Step-A
reductions (NavigatedEndChar.lean), `nf_zone_flatten_navigable(_correct)`,
`nfEval_le2_reduction`, `seg`, `endChar0`, the k1v family + kit, the v6 `endInterval`
skeleton, and both negative guardrails (`f2_relativized_refutation`,
`endCharN0_correct_infeasible`).

**Design decisions are SETTLED** (do not re-open without a concrete machine-checked
counterexample):
- **The carrier is carrier 3** — enriched-segment bracket, codomain
  `BracketEndCharCarrierV sig k = NormalForm sig k 3 → VVecEA2` (closed Formula under Prior),
  NOT Prop-valued D and NOT `kv_body` (report 09 §0, unanimous after three-carrier
  separation; report 10 GO).
- **Interior reads at FULL arity 4** — the F1/F2 mechanism is structurally inapplicable
  without the `nfk_projFresh` collapse (report 10 C4/C5); this is the load-bearing
  faithfulness + safety property.
- **Correctness is Prior-guarded** (`EndIntervalCorrectPrior` with `semantic_prior_UZ/SZ` +
  provider obligations, verbatim from the k=2 gate). This matches the standing project-wide
  condition already carried by the downstream interface (KampPrior.lean:212/407); v7 delivers
  Kamp-on-Prior-structures, not the unconditional theorem (report 09 §5.2 — disclosed, not a
  fresh corner).
- **Providers thread via `ExistProviders`**, not via `rec` alone and not via a `charF`
  closed-formula fiber projection — this is the adjudicated resolution of the v6 Phase-3
  blocker; re-freezing the v6 `endIntervalStep`/`EndIntervalCorrect` decls accordingly is
  sanctioned (report 09 §3.1 "bounded /revise").
- **The general-`k` work is construction, not open mathematics** — determinacy is proved
  uniformly (report 10); a Phase-1..5 failure is an indexing/typechecking gap to `[BLOCKED]`
  + `/spawn`, never a reason to change carrier type.

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| **Phase-1 fold-bridge index plumbing (`efold_of_nfk`/`nfk_dropFresh`) balloons** — the depth-0 engine's `nf0_*` plumbing is hardcoded; the general-`k` transcription may fight dependent-index arithmetic | H | M | Phase 1 is the construction GATE, isolated exactly per reports 09/10. Fixed attempt surface: transcribe the depth-0 engine's structure one decl at a time, off-fiber via `nf_eval_unique M k n env`; statement shape from report 10 is the target, minor signature adjustment during plumbing is sanctioned. Stop condition: bridge green OR `[BLOCKED]` + exact `lean_goal` + `/spawn 349`. NO carrier-type reopening on failure (SETTLED — a bridge failure is construction, not semantics) |
| **k-generalized exterior brackets drift from the frozen k=2 shape** (Phase 2) | H | M | New module `ExteriorBracketK.lean` ONLY; the k=2 decls are the byte-identical template — mirror `kvE2_extBracketPast_sound`'s statement with `NormalForm sig 0 1 → NormalForm sig k 1` and `nf_eval_unique M k` supplying determinacy (report 10's exact prescription). Diff-check: `git diff` on ExteriorBracket.lean must be EMPTY at every commit |
| **Step-correctness (Phase 4) overruns one run** — the k=2 gate proof is large | H | M | Pre-declared split by proof DIRECTION (4a soundness ⇒ / 4b completeness ⇐ + ↔ assembly), mirroring the k=2 `_sound_two_prior_frag`/`_complete_two_prior` structure. Each direction bounded with the green k=2 proof as working template. Stop: direction closed OR `[BLOCKED]` + `lean_goal` |
| **Provider-recursion termination/well-foundedness fails to typecheck** (Phase 5) | M | M | `Nat.rec` shape already green (v6 skeleton, CarrierK1V:2159); providers are a parameter family, not a mutual def — no genuine mutual recursion inside 349 scope (the mutual partner `nf_nvar_exist_all_depths` is consumed downstream, not here). If the provider-step needs the carrier IH in a way that circles, keep `endInterval_correct` provider-family-parametric (matching how the k=2 gate threads its obligations as hypotheses) and record the discharge obligation for 309 |
| **Regression onto a refuted carrier** because a sub-goal "would be easier" with a projection/single-point read | H | M | PROHIBITED (postmortem Do-NOT 1-6). Discriminators: interior obligations MUST be `nf_eval_nf M k 4 …` (full arity); any `nfk_projFresh` occurrence in new code = STOP; any `temporal_truth w φ ↔ ∃v …` goal = STOP |
| **Accidental frozen-file edit** (7 providers, KampPrior, Lemma32Reduction) | H | L | All new ExteriorBracket-family decls in the NEW `ExteriorBracketK.lean`; `git status --short` + `git diff --staged` before every commit must show only sanctioned scope; frozen files byte-identical |
| **Quarantine extraction imports rot** — copying `kvE_body` shape drags in merged-bracket nesting | M | L | Reference-only extraction (Do-NOT 8); each extracted piece verified against the live k=2 `kvE2Ext` before use; the quarantined file is never imported |
| Fake green under pressure | H | M | PROHIBITED (Do-NOT 7); `[BLOCKED]` + `lean_goal` + `/spawn 349` |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2 | 1 |
| 3 | 3 | 2 |
| 4 | 4 | 3 |
| 5 | 5 | 4 |
| 6 | 6 | 5 |

Phases are sequential (single logical chain: bridge → brackets → body/statement →
correctness → recursion close → audit). **Declared parallel opportunity (H7)**: Phase 3's
statement-only sub-unit (`EndIntervalCorrectPrior`, CarrierK1V.lean) is file-disjoint from
Phase 2 (`ExteriorBracketK.lean`) and depends only on the frozen k=2 gate shape — an
orchestrator MAY dispatch it alongside Phase 2 under a territory contract
(CarrierK1V.lean vs ExteriorBracketK.lean); the wave table above is the safe default.

**Per-phase hard bar (every phase)**:
- Ends GREEN + sorry-free: scoped `lake build` of the touched module(s) GREEN (whole-tree
  GREEN at Phase 6); `lean_verify` on the phase's headline decl = exactly
  `[propext, Classical.choice, Quot.sound]`; no new axiom.
- Preserved assets consumed by name (reuse-vs-rebuild note satisfied); zero frozen-file
  diffs (`git diff` on the 7 providers + KampPrior.lean + Lemma32Reduction.lean EMPTY).
- **Guards (binding, restated)**: **G1** no arity-1 collapse — no `nfk_projFresh` on any
  sub read, no single-point closed-formula collapse inside the recursion (full-arity-4
  interior reading is NOT a G1 violation: `x1,w` are bracket witnesses); **G2/G4** free
  anchors strictly ⊆ {x,t}, ≤2 — `w` and all disjunct/bracket witnesses are bound witnesses,
  never a third free anchor; **G3** interior segments are real exclusions, never
  `TemporalPred.top`; **G5** manual bridges on every Rabinovich chain step
  (`constructor`/`intro`/`exists_congr`/`and_congr` style, mirroring the k=2 kit) — no
  `simp`/`omega`/`aesop` shortcut of a chain step.
- FORBIDDEN constructs grep-clean in new code: `→ TemporalPred` recursion carrier,
  `navPieceForm`, `h_res`, `nfk_projFresh`, `kv_body`, arity-4 collapse, per-pair `∀ij∃w`.
- Commit per green sub-step (`task 349 phase {P}.{O}: …`).

### Phase 1: General-`k` fold bridge `nf_eval_nfk_iff_efold` (construction gate) [NOT STARTED]

- **Goal:** Build the general-`k` inside-out whole-evaluation fold bridge — the k-analog of
  the green depth-1 bridge `nf_eval_nf1_iff_efold` (NfEFold:490) — the load-bearing new
  lemma whose risk this phase isolates (Q3 determinacy already GO, report 10).
- **Target statement** (report 10, exact prescription; minor signature adjustment during
  index plumbing is sanctioned, the biconditional shape is not negotiable):
  ```lean
  theorem nf_eval_nfk_iff_efold {sig} (M : OrderedMonadicStructure sig) {k n : Nat}
      (env : Fin n → M.carrier) (qnf : NormalForm sig (k+1) n) :
      nf_eval_nf M (k+1) n env qnf ↔
        (nf_eval_efold_k M (k+1) n env (efold_of_nfk qnf) ∧
         ∀ sub : NormalForm sig k (n+1), nfk_dropFresh sub ≠ qnf.1 → qnf.2 sub = false)
  ```
- **Construction:** build the index plumbing (`efold_of_nfk`, `nfk_dropFresh`, `nfk_zoneSpec`
  — the depth-`k` analogs of the `nf0_*` family); forward direction iterates the
  arity-general `nf_quant_layer_fold_iff` (NfEFold:391) inside-out; the off-fiber conjunct
  discharges by `nf_eval_unique M k n env` (NormalForm.lean:245 — the depth-`k` analog of the
  depth-0 step at NfEFold:428). NfEFold:388's own note: "the proof is index-structural" —
  every semantic input is already proved.
- **Reuse vs rebuild:** REUSE `nf_quant_layer_fold_iff`, `nf_eval_unique`,
  `nf_eval_nf1_iff_efold` (as the k=1 sanity instance the general lemma must recover), the
  `nf0_*` plumbing as the transcription template. BUILD only the `nfk_*` plumbing + the
  bridge.
- **Tasks:**
  - [ ] Define `efold_of_nfk` / `nfk_dropFresh` / `nfk_zoneSpec` (depth-`k` index plumbing),
        each elaborating green as it lands (commit per green sub-step).
  - [ ] Prove `nf_eval_nfk_iff_efold`: forward by inside-out iteration of
        `nf_quant_layer_fold_iff`; off-fiber by `nf_eval_unique M k n env`; backward by the
        fold-engine reassembly.
  - [ ] Sanity instance: derive (or `example`-check) the k=1 case against
        `nf_eval_nf1_iff_efold` — the general bridge must not be weaker than the green
        depth-1 lemma.
  - [ ] Route audit: no `nfk_projFresh` in any statement; grep FORBIDDEN list clean; scoped
        build GREEN; `lean_verify nf_eval_nfk_iff_efold` = `[propext, Classical.choice, Quot.sound]`.
- **Bounded-unit stop condition:** the bridge is green + sorry-free, OR a specific plumbing
  decl/goal cannot close — then `[BLOCKED]` + exact `lean_goal` + `/spawn 349`. No open-ended
  re-attempts past one dispatch; no carrier reopening (SETTLED).
- **Estimated output:** ~200-400 lines.
- **Timing:** ~3 hours.
- **Done when:** `nf_eval_nfk_iff_efold` green, sorry-free, axiom-clean; k=1 instance
  recovered; scoped build GREEN.
- **Depends on:** none.
- **Files:** `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfEFold.lean` (additive tail
  ONLY — existing decls, including the D7 docstring block, byte-identical).

### Phase 2: `k`-generalized exterior brackets (Prop-4.2 pinning channel at depth `k`) [NOT STARTED]

- **Goal:** Generalize the k=2 per-side exterior brackets so their determinacy inputs read
  depth `k`: `kvE_extBracketPast`/`kvE_extBracketFut` + `_sound`/`_complete`, where the
  k=2 `habove` hypothesis (`(zs : ZoneSpec 3) (χ : NormalForm sig 0 1)` at `nf_eval_nf M 0 1`,
  ExteriorBracket.lean:463-466) becomes `NormalForm sig k 1` / `nf_eval_nf M k 1` — the same
  shape, one fold-layer deeper, with `nf_eval_unique M k` supplying determinacy and the
  Phase-1 bridge supplying the fold characterization (report 10's exact prescription).
- **Reuse vs rebuild:** REUSE the k=2 brackets as the byte-identical statement/proof template
  (`kvE2_extBracketPast_sound` :432+, `_complete` :583+); REUSE Phase-1's bridge +
  `nf_eval_unique`. BUILD only the `k`-parametric analogs.
- **Tasks:**
  - [ ] Define `kvE_extBracketPast`/`kvE_extBracketFut` (depth-`k` bracket builders) in the
        NEW module, mirroring the k=2 defs.
  - [ ] Prove `_sound` per side: strictly-exterior realizer split + refutation via the
        depth-`k` characterization (Phase-1 bridge + `nf_eval_unique M k`).
  - [ ] Prove `_complete` per side, mirroring the k=2 proofs.
  - [ ] Sanity: the k=2 instances of the new decls agree with (are interderivable with) the
        frozen originals — `example`-check, no edit to ExteriorBracket.lean.
  - [ ] Route audit: `git diff` on ExteriorBracket.lean (and all 7 frozen providers) EMPTY;
        grep FORBIDDEN list clean; anchors {x,t} only (G2/G4); segments non-trivial (G3);
        manual bridges (G5); `lean_verify` on both `_sound` lemmas axiom-clean.
- **Bounded-unit stop condition:** all four lemmas (2 sides × sound/complete) green, OR
  `[BLOCKED]` + `lean_goal` on the specific side/direction. If one side closes and the other
  blocks, commit the green side first.
- **Estimated output:** ~300-500 lines.
- **Timing:** ~3.5 hours.
- **Done when:** both sides sound + complete, green, sorry-free, axiom-clean; frozen files
  byte-identical; scoped build GREEN.
- **Depends on:** 1.
- **Files:** `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge/ExteriorBracketK.lean`
  (NEW; imports ExteriorBracket + NfEFold).

### Phase 3: `endIntervalStep` general-`k` body + `EndIntervalCorrectPrior` statement freeze [NOT STARTED]

- **Goal:** Fill the v6 Phase-3 hole with the enriched general-`k` step body, and
  bounded-revise the correctness Prop to the Prior-guarded shape. This is the report-09
  §3.1/§3.2 architecture and the adjudicated resolution of the v6 Phase-3 blocker: providers
  thread via `ExistProviders`, NOT via `rec` alone and NOT via a closed-formula `charF`
  fiber projection.
- **Step body** (kvE_body pattern from the quarantine, verified against the live k=2
  `kvE2Ext` — reference-only extraction): per-sub enriched content — interior point types via
  a depth-`k` provider (`P.existF 0`), interior segment realization via `P.existF 3` at
  **FULL arity 4**, exterior residue via the two adjacent Phase-2 brackets
  `kvE_extBracketPast` (at `x`) ∧ `kvE_extBracketFut` (at `t`) — Lemma-7.6 adjacency. The
  signature extends the v6 freeze with the provider parameter (sanctioned re-freeze):
  ```lean
  noncomputable def endIntervalStep {sig} (atomMap) (h_surj) {k : Nat}
      (P : ExistProviders sig atomMap k) (rec : BracketEndCharCarrierV sig k) :
      BracketEndCharCarrierV sig (k+1)
  ```
  `endInterval` (CarrierK1V:2159) re-frozen accordingly (`Nat.rec`, base unchanged, step =
  `endIntervalStep` with the provider family threaded).
- **Statement freeze** — `EndIntervalCorrectPrior`, VERBATIM generalization of the k=2 gate
  `bracketEndChar_kvE2Ext_correct_two_prior_frag` (ExteriorBracket.lean:1069): under
  `semantic_prior_UZ`/`semantic_prior_SZ`, with the provider obligations
  (`hfrag`/`hrealI`/`hrealB`/`hexcl`, generalized to depth `k` at full arity 4:
  `nf_eval_nf M k 4 (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t)))) σ`) and the six
  order bits, conclude
  `(endInterval atomMap h_surj k qnf).holds M atomMap x t ↔ ∃ w, nf_eval_nf M k 3 (Fin.cons w (Fin.cons x (fun _ => t))) qnf`.
  The old `EndIntervalCorrect` (CarrierK1V:2179) is retained inert with a superseded-by
  docstring (no deletion churn).
- **Reuse vs rebuild:** REUSE `ExistProviders`/`existF` (PriorInterface.lean:38-40), the
  Phase-2 brackets, the v6 skeleton, VVecEA2 assembly vehicles, and the k=2 gate's hypothesis
  package as the statement template. BUILD the body + the statement + a `holds_iff`
  destructuring lemma (the general-`k` analog of ExteriorBracket.lean:674).
- **Tasks:**
  - [ ] Extend/re-freeze the `endIntervalStep` signature with `P : ExistProviders sig atomMap k`;
        define the body (kvE_body pattern + Phase-2 brackets); confirm `endInterval (k+1)`
        typechecks against it.
  - [ ] Prove `endIntervalStep_holds_iff` (Lemma-7.6 adjacency destructuring: holds ↔
        interior ∧ bracketPast@x ∧ bracketFut@t).
  - [ ] State `EndIntervalCorrectPrior` (Prop, compiles sorry-free — statement-only freeze,
        proof in Phases 4-5); document the verbatim correspondence to the k=2 gate's
        hypotheses in its docstring.
  - [ ] Route audit: interior obligations at full arity 4 (no `nfk_projFresh` — G1); anchors
        {x,t} (G2/G4); segments real (G3); grep FORBIDDEN list clean; frozen files
        byte-identical; scoped build GREEN.
- **Bounded-unit stop condition:** body + `holds_iff` + statement all compile green, OR
  `[BLOCKED]` + `lean_goal`. If the body elaborates but `holds_iff` blocks, commit the body.
- **Estimated output:** ~200-350 lines.
- **Timing:** ~2.5 hours.
- **Done when:** `endIntervalStep` (real body, hole gone), `endIntervalStep_holds_iff`, and
  `EndIntervalCorrectPrior` green + sorry-free; `lean_verify` on the def + `holds_iff`
  axiom-clean; scoped build GREEN.
- **Depends on:** 2 (statement-only sub-unit parallelizable with 2 — see Dependency Analysis).
- **Files:** `.../NfMultiAnchorBridge/CarrierK1V.lean` (additive + the sanctioned
  `endIntervalStep`/`endInterval` re-freeze; imports ExteriorBracketK + PriorInterface).

### Phase 4: General-`k` step correctness — soundness + completeness (the k=2 gate at depth `k`) [NOT STARTED]

- **Goal:** Prove the step-level gate biconditional at symbolic `k`, generalizing the GREEN
  k=2 `bracketEndChar_kvE2Ext_correct_two_prior_frag` (ExteriorBracket.lean:1069): under
  Prior + the depth-`k` provider obligations, `(endIntervalStep P rec qnf).holds M atomMap x t
  ↔ ∃ w, nf_eval_nf M (k+1) 3 [w,x,t] qnf`.
- **Proof structure (mirror the k=2 template exactly):**
  - **⇒ (soundness)**: destructure via `endIntervalStep_holds_iff`; thread the provider
    obligations as hypotheses (as the k=2 gate does at :1106-1129); discharge the exterior
    residue `hexclExt` by splitting each strictly-exterior realizer to its side and refuting
    via the Phase-2 `kvE_extBracketPast/Fut_sound` (the k=2 proof's :1126-1128 move, one
    fold-layer deeper); interior realization from `hrealI`/`hrealB`/`hexcl` at full arity 4.
  - **⇐ (completeness)**: from `∃ w, nf_eval_nf M (k+1) 3 [w,x,t] qnf`, apply the Phase-1
    bridge to expose the fold + off-fiber facts, rebuild interior content via the providers,
    and the two brackets via `kvE_extBracketPast/Fut_complete` — mirroring
    `_complete_two_prior` (OuterGate.lean:147) + the k=2 assembly (:1138+).
- **Reuse vs rebuild:** REUSE the whole k=2 gate proof as line-by-line template, Phase-1
  bridge, Phase-2 brackets, `endIntervalStep_holds_iff`. BUILD only the `k`-parametric
  sound/complete/↔.
- **Pre-declared split (bounded-unit guard):** 4a = soundness (⇒), 4b = completeness (⇐) +
  ↔ assembly. If a direction overruns one run, it is its own dispatch; commit each green
  direction as it lands.
- **Tasks:**
  - [ ] Prove `endIntervalStep_sound_prior_frag` (⇒), manual bridges (G5), IH/provider
        obligations threaded as hypotheses (k=2 pattern).
  - [ ] Prove `endIntervalStep_complete_prior_frag` (⇐).
  - [ ] Assemble `endIntervalStep_correct_prior_frag` = ⟨sound, complete⟩.
  - [ ] Route audit: no single-point `↔` goal shape (STOP signal); no `nfk_projFresh`;
        interior at full arity 4; anchors ≤2; grep clean; frozen files byte-identical.
- **Bounded-unit stop condition:** per-direction: closed OR `[BLOCKED]` + exact `lean_goal`
  + `/spawn 349` for the specific missing sub-lemma. The statement is NON-refuted (green
  k=2 witness) — a block is a construction gap, never a carrier question.
- **Estimated output:** ~300-500 lines (split 4a/4b if overrunning).
- **Timing:** ~4 hours.
- **Done when:** step gate biconditional green + sorry-free at symbolic `k`; `lean_verify`
  axiom-clean; scoped build GREEN.
- **Depends on:** 3.
- **Files:** `.../NfMultiAnchorBridge/CarrierK1V.lean` (additive; or `ExteriorBracketK.lean`
  tail if the implementer keeps gate lemmas with the brackets — declare in handoff).

### Phase 5: Recursion close — provider-step + `endInterval_correct` by induction on `k` [NOT STARTED]

- **Goal:** Close the `Nat.rec` and prove
  `endInterval_correct : EndIntervalCorrectPrior …` by induction on `k`: base = the green
  k=1 family (`bracketEndChar_k1v_correct`, CarrierK1V:2041, via the v6 base embedding),
  step = Phase 4's gate with the IH supplying the depth-`k` characterization.
- **Provider threading (349-scoped, SETTLED):** the induction is **provider-family
  parametric** — `endInterval_correct` takes the provider family + per-depth obligations as
  hypotheses, exactly as the k=2 gate threads `hfrag`/`hrealI`/`hrealB`/`hexcl` (report 09
  Q3: "threads 4 provider obligations as hypotheses"). A provider-step lemma
  (`ExistProviders k` + carrier IH → the `k+1` obligations' discharge shape) is built here
  to the extent it stays inside NfMultiAnchorBridge scope; the full unconditional
  instantiation against `nf_nvar_exist_all_depths` is task 309 Phase 14 (KampPrior NO-EDIT
  — the import cycle `KampPrior → NfMultiAnchorBridge` makes in-scope reference impossible
  anyway, per the v6 Phase-3 finding). Record precisely which obligations remain
  hypothesis-side in the summary + handoff.
- **Reuse vs rebuild:** REUSE Phase-4 gate, v6 base case (`endInterval_zero_correct` /
  the k1v family), the `Nat.rec` skeleton. BUILD the induction assembly + provider-step.
- **Tasks:**
  - [ ] Prove the provider-step lemma (bounded; if it demands out-of-scope KampPrior
        machinery, keep that piece hypothesis-side and document — NOT a block).
  - [ ] Prove `endInterval_correct` by induction on `k` (base + Phase-4 step with IH).
  - [ ] Confirm `endInterval` genuinely recurses (not vacuous; step body is the Phase-3
        body, not `⟨[]⟩`).
  - [ ] Route audit: grep FORBIDDEN list clean over all new v7 code; frozen files
        byte-identical; `endInterval_correct` is a top-level citable name.
- **Bounded-unit stop condition:** induction closes OR `[BLOCKED]` + `lean_goal` on the
  specific step-instantiation mismatch. Typecheck/termination issues are re-indexing work,
  not carrier questions (report 10 adversarial §1).
- **Estimated output:** ~200-350 lines.
- **Timing:** ~2.5 hours.
- **Done when:** `endInterval`/`endInterval_correct` green + sorry-free by induction;
  `lean_verify endInterval_correct` = exactly `[propext, Classical.choice, Quot.sound]`;
  scoped build GREEN.
- **Depends on:** 4.
- **Files:** `.../NfMultiAnchorBridge/CarrierK1V.lean` (additive).

### Phase 6: Axiom audit + whole-project build + H3 finalization [NOT STARTED]

- **Goal:** Confirm every definition-of-done gate on the assembled result; no new source
  code.
- **Tasks:**
  - [ ] Whole-project `lake build` GREEN.
  - [ ] `lean_verify` (warm) on `endInterval_correct`, `endIntervalStep_correct_prior_frag`
        (+ `_sound`/`_complete`), `nf_eval_nfk_iff_efold`, the Phase-2 bracket lemmas,
        `endIntervalStep`, `endInterval` — all exactly `[propext, Classical.choice, Quot.sound]`,
        no `sorry`, no new axiom.
  - [ ] FORBIDDEN-list grep over all v7-touched files clean; `git diff` on the 7 frozen
        providers + KampPrior.lean + Lemma32Reduction.lean EMPTY across the whole v7 range;
        `nf_nvar_exist_all_depths` signature untouched.
  - [ ] Finalize the H3 Tier-1 mapping STATUS column in this plan (pending → transcribed);
        any residual hypothesis-side provider obligation is documented in the summary with
        its 309-Phase-14 discharge pointer.
  - [ ] Confirm `endInterval_correct` reachable/citable for 309 Phase 14 / 350 (name-level
        grep).
- **Bounded-unit stop condition:** verification-only phase; any RED finding routes back to
  the owning phase as a defect (churn-counter applies), never patched ad hoc here.
- **Estimated output:** ~0-50 lines (docstring/plan edits only).
- **Timing:** ~0.5 hours.
- **Done when:** all gates pass; plan + summary finalized.
- **Depends on:** 5.
- **Files:** none (verification) + this plan + summary.

## Testing & Validation

- [ ] Scoped `lake build` GREEN after every phase; whole-tree GREEN at Phase 6.
- [ ] `lean_verify` on every headline decl = exactly `[propext, Classical.choice, Quot.sound]`;
      no `sorry` anywhere in v7 code; no new axiom.
- [ ] Interior obligations everywhere at FULL arity 4
      (`nf_eval_nf M k 4 (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t)))) σ`) — zero
      occurrences of `nfk_projFresh` in new code (G1; the F2 discriminator).
- [ ] `endInterval_correct` is the Prior-guarded biconditional
      (`EndIntervalCorrectPrior`), hypotheses verbatim-generalized from the k=2 gate — never
      the unguarded v6 `EndIntervalCorrect` shape, never a single-point `.eval_at w` LHS,
      never `h_res`-conditioned.
- [ ] Exterior residue discharged ONLY via the double-anchor brackets (Past@x ∧ Fut@t,
      Lemma-7.6 adjacency) — no single-anchor pinning (the quarantine gap).
- [ ] Anchors strictly {x,t} (≤2); all witnesses bound in bracket/disjunct slots (G2/G4);
      segments non-trivial (G3); manual bridges on chain steps (G5).
- [ ] `git diff` on SharedWitness/SubBracket2V/OuterGate/ExteriorBracket/ExteriorZoneTriage/
      ExteriorNegation/ExteriorNegationPast + KampPrior.lean + Lemma32Reduction.lean EMPTY
      over the whole v7 range; `nf_nvar_exist_all_depths` signature unchanged.
- [ ] No Boneyard file imported or restored; quarantine extraction reference-only.
- [ ] `endInterval`/`endInterval_correct` top-level citable for task 309 Phase 14 / 350.

## Artifacts & Outputs

- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfEFold.lean` — additive tail (Phase 1:
  `nfk_*` plumbing + `nf_eval_nfk_iff_efold`).
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge/ExteriorBracketK.lean`
  — NEW module (Phase 2: `k`-generalized exterior brackets; possibly Phase-4 gate lemmas).
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge/CarrierK1V.lean` —
  additive + sanctioned `endIntervalStep`/`endInterval` re-freeze (Phases 3-5).
- `specs/349_.../plans/07_enriched-bracket-carrier.md` (this plan; supersedes plans/06).
- `specs/349_.../summaries/07_enriched-bracket-carrier-summary.md` (on completion).

## Rollback/Contingency

- All work is additive (new module + additive tails + the sanctioned CarrierK1V re-freeze);
  the 7 frozen providers, KampPrior.lean, and Lemma32Reduction.lean are never opened, so no
  green asset can be lost by a v7 rollback. Snapshot before any intentional rollback
  (`bash .claude/scripts/git-snapshot.sh` first).
- Commit-per-green-substep mandate: every verified-green sub-step is committed as it lands;
  no progress lost across dispatches.
- **Per-phase feasibility gate**: a phase target that cannot close green without a forbidden
  construct is `[BLOCKED]` + exact `lean_goal` record + `status: partial` +
  `requires_user_review: true` + `/spawn 349` for the specific missing sub-lemma — never a
  fake green. The carrier type is SETTLED: every plausible block in v7 is index-structural
  construction (report 10), so escalations seek the missing plumbing/generalization lemma,
  never a carrier change.
- If Phase 1 blocks hard (the one gating construction), the fallback is a dedicated spawn
  for the fold bridge alone (it is independently valuable — the unbuilt "309-R3 inside-out
  iteration", NfEFold:388-389) while 349 holds `[BLOCKED]`; Phases 2-6 do not proceed
  without it.
