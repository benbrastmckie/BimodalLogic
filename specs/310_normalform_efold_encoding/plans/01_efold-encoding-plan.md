# Implementation Plan: E[Σ]-Fold Encoding for NormalForm Depth-Recursion (task 310)

- **Task**: 310 - normalform_efold_encoding (spawned from 309, R2 NO-GO, commit 8fd4340b1)
- **Status**: [NOT STARTED]
- **Effort**: ~6 hours (4 phases, hard-mode H8 one-agent-run sizing)
- **Dependencies**: None (fully additive; nothing imports the new file — off the live path)
- **Research Inputs**: reports/01_efold-encoding-research.md (Tier-1, full Rabinovich 2014 PDF read; PLANNING AUTHORITY)
- **Artifacts**: plans/01_efold-encoding-plan.md (this file)
- **Standards**:
  - .claude/context/formats/plan-format.md
  - .claude/rules/plan-format-enforcement.md
  - .claude/rules/artifact-formats.md
  - .claude/rules/state-management.md
- **Type**: lean4

> **Line-estimate deviation (declared up front)**: This plan sizes to the RESEARCH estimate of
> **~350-550 lines over 4 phases**, NOT the task description's ~150-280. Per report §9 Contradiction
> Log, the spawn-time estimate predated identification of the general-`n` iteration engine and the
> round-trip losslessness lemmas — both load-bearing (the first for 309-R3's inside-out iteration,
> the second for the G2 losslessness defense) and neither is trimmable without downstream cost. The
> task description explicitly anticipates this ("split into sub-phases if it overruns"). Kept as-is.

## Overview

Task 309's R2 k=1 decision gate NO-GOed on an **irreducible arity-4 residual**: `nf_eval_nf`
(NormalForm.lean:198-207) grows environment arity `n → n+1` at every depth descent, coupling a
fresh existential witness jointly to BOTH fixed endpoints. Rabinovich 2014 never grows arity with
depth — Def 4.1 (PDF p.5) folds each processed quantifier depth into a fixed-arity **monadic**
E[Σ]-atom before decomposing the next level. This task defines that fold **as a new, parallel,
additive object** (`NormalFormEFold` / `nf_eval_efold` in a new file
`Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfEFold.lean`) alongside `nf_eval_nf` — NOT a
project-wide re-encoding (report §7 Alt A rejected; report §3 rejects a global rewrite that would
orphan the sorry-free depth-0/arity-1 assets). The quant-assignment domain
`EAtomDom sig k n := ZoneSpec n × NormalForm sig k 1` makes Lemma 3.2(2)'s ≤2-free-variable cap a
**type-level invariant** (no slot exists for a joint (n+1)-ary sub-evaluation), per the binding
user directive that the cap be encoded in the type, not hand-enforced by a guard.

**Definition of done**: `lake build` GREEN on the new module; the fold definition + three bridge
lemmas + the k=1 gate corollary all sorry-free; `#print axioms` = `[propext, Classical.choice,
Quot.sound]` (or fewer) on every new theorem. The DONE signal is
**`nf_quant_layer_fold_k1_gate` proven sorry-free** — its statement matches the R2 NO-GO residual
VERBATIM so task 311 can `exact`/`rw` it at the gate point.

### Research Integration

This plan adopts report 01's §9 phase decomposition verbatim (4 phases), with pre-declared H8
split seams added to Phases 3 and 4 (the two lemma-heavy phases). All load-bearing decisions are
grounded in the report's §3 H3 mapping table and §5 exact signatures. No concrete defect was found
in the research decomposition; the report's Adversarial Self-Verification and Contradiction Log are
treated as the honest bounds (especially D7, below).

### Source-to-Implementation Mapping (H3, Tier 1 — Rabinovich 2014 full PDF)

| Paper item | Page | Lean artifact (this task) | Phase | Fidelity / deviation note |
|---|---|---|---|---|
| Def 3.1 ordering conjuncts (`x` vs each fixed point + `z_k = x_{i_k}`) | p.4 | `ZoneSpec n`, `zoneHolds` | 1 | equality zones via LinearOrder trichotomy `(false,false)` — deviation **D6**, fixes absence of equality atoms |
| Def 3.1 monadic point type α (1-var, QF) | p.4 | fold atom slot `NormalForm sig k 1`, semantics `nf_eval_nf M k 1 (fun _ => x)` | 1 | atom's own interior arity growth is invisible/discharged — deviation **D5** (accepted, interior-only) |
| Def 4.1 E[Σ]-atom (processed depth as unary predicate) | p.5 | `EAtomDom sig k n` | 1 | atom = `nf_eval_nf M k 1`, the already-TL-realized arity-1 pipeline (KampPrior:81, n=0 arm :339-346) |
| Lemma 3.2(2) ≤2-free-var cap as standing invariant | p.4 | `NormalFormEFold` quant assignment typed over `EAtomDom` | 1 | **type-level** invariant (user directive); no `n+1`-ary slot exists |
| Def 3.1 whole-shape evaluation | p.4 | `nf_eval_efold` recursion equation | 1 | arity fixed by the equation itself; interval β carried by completeness — deviation **D3** |
| depth-0 base coincidence (fold = old encoding) | p.4 | `nf_eval_efold_zero_iff` (`Iff.rfl`) | 1 | trivial by definitional equality of the two `0` clauses |
| Def 3.1 three coupling channels (factorization data) | p.4 | split kit `nf0_zoneSpec` / `nf0_projFresh` / `nf0_dropFresh` / `nf0_assemble` + 4 round-trips | 2 | `nf0_dropFresh := mergeNF · ⟨0,_⟩` (reuse NfDepth0Generalized:169); bijection = G2 losslessness defense |
| Def 3.1 factorization theorem (3 channels, lossless) | p.4 | `nf_eval_nf0_cons_factor` | 3 | the mathematical core; `extract_*` pattern (VecEADecomp:55-66) generalized |
| Prop 4.3 innermost ∃-fold, general n (reusable engine) | p.6 | `nf_quant_layer_fold_iff` | 4 | uses `nf_eval_unique` (NormalForm.lean:245); general `n` → 309-R3 iteration engine |
| k=1 whole-evaluation transport | p.5-6 | `efold_of_nf1` + `nf_eval_nf1_iff_efold` | 4 | explicit off-fiber falsity conjunct (decidable, model-independent) — the honest bridge |
| the R2 NO-GO residual, fold-reduced (311's entry point) | p.4-6 | `nf_quant_layer_fold_k1_gate` | 4 | stated VERBATIM against the residual; one-line instantiation of the general lemma at n=3 |
| Prop 3.5 / Lemma 3.4 discharge machinery | p.5 | `bracketBuildLeft/Right`, `existsBounded_right`, `nf_3var_bracket_xyt` | — | **existing, sorry-free — consumed by 311, NOT this task** |
| G6 carrier shape (unchanged) | p.5 | `BracketEndCharCarrier` / `BracketCarrierCorrect` | — | **existing — 311's target; SHAPE preserved, only underlying recursion re-grounded** |

### Preserved Assets

This task is **fully additive**: it writes one new file and edits none. The following task-309
assets are `CONSUME, DO NOT REBUILD` — all sorry-free, all on the live path, and MUST NOT regress
(no existing consumer changes; `lake build` on existing modules stays green):

| Component | File:line | Status | Role for task 310 |
|---|---|---|---|
| `nf_3var_bracket_xyt` / `_correct` | VecEADecomp.lean:233/244 | sorry-free | depth-0 base collapse (consumed by 311) |
| `char_k1` / `_correct` | KampPrior.lean:307/310 | sorry-free (proof-local `let`, NOT a global) | do NOT cite as global; use `nf_succ_char_formula` instead |
| `nf_succ_char_formula` / `_correct` + n=0 arm | KampPrior.lean:67/81/339-346 | sorry-free | the global E[Σ]-atom TL-realizability (Def 4.1) |
| `bracketBuildLeft/Right` / `_correct` | VecEATranslation.lean:273/50/503/234 | sorry-free | Prop 3.5 chain builders (311, not 310) |
| `BracketEndCharCarrier` / `BracketCarrierCorrect` / `bracketEndChar_k0` / `_correct` | NfMultiAnchorBridge.lean:1536/1546/1557/1571 | sorry-free | G6 carrier SHAPE to preserve, not rebuild |
| `mergeNF` / `skipFin` / `unskipFin` / `insertEnv` | NfDepth0Generalized.lean:42/109-175 | sorry-free | reused by `nf0_dropFresh` (Phase 2) |
| `nf_eval_unique` | NormalForm.lean:245 | sorry-free | off-fiber falsity step (Phase 4) |
| Fintype/DecidableEq for NormalForm | NormalForm.lean:166-183 | sorry-free | decidability of the off-fiber clause (311 design note) |

## Goals & Non-Goals

- **Goals**:
  - Define `NormalFormEFold`, `EAtomDom`, `ZoneSpec`, `zoneHolds`, `nf_eval_efold` (fixed-arity
    monadic E[Σ]-fold; Def 4.1 + Def 3.1) in the new file `Kamp/NfEFold.lean`.
  - Prove the depth-0 coincidence `nf_eval_efold_zero_iff` (task deliverable).
  - Deliver the four named bridge lemmas: `nf_eval_nf0_cons_factor` (G2 depth-0 lossless
    factorization), `nf_quant_layer_fold_iff` (GENERAL-n one-step fold, full iff),
    `nf_eval_nf1_iff_efold` (k=1 whole-evaluation transport with explicit off-fiber falsity
    conjunct), and `nf_quant_layer_fold_k1_gate` (stated VERBATIM against the R2 NO-GO residual).
  - Every new declaration doc-commented with its Rabinovich PDF page cite (G5 literature-fidelity).
  - `lake build` GREEN on `Kamp.NfEFold`; 0 new sorries; axioms exactly `[propext, Classical.choice,
    Quot.sound]`.
- **Non-Goals**:
  - NOT a global re-encoding of `nf_eval_nf` or a migration of any existing consumer (report §7 Alt A).
  - NOT a depth-k (k≥1) pointwise equivalence of the two encodings — provably FALSE (deviation **D7**);
    the k=1 gate needs only depth-0 subs, where the factorization is a proven bijection.
  - NOT the discharge of the fold-reduced RHS (zone-bounded monadic existentials) — that is **task 311**.
  - NOT any change to G6's carrier shape (`BracketEndCharCarrier` stays `VecEA2 1`-shaped).

## Risks & Mitigations

- **Risk**: Phase 3 (`nf_eval_nf0_cons_factor`) overruns H8 on atom-case analysis with `Fin.cons`
  computation. **Mitigation**: pre-declared split seam at the forward/backward direction boundary
  (Phase 3.1 / 3.2 below); report §9 flags this as the riskiest phase.
- **Risk**: Phase 4 bundles the load-bearing `nf_quant_layer_fold_iff` (the only proof using
  `nf_eval_unique`) with three lighter declarations, risking one-run overrun. **Mitigation**:
  pre-declared split seam (Phase 4.1 = the general engine; Phase 4.2 = transport + gate corollary).
- **Risk**: the gate corollary statement drifts from the exact R2 residual, breaking 311's `exact`.
  **Mitigation**: acceptance criterion pins it VERBATIM to NfMultiAnchorBridge.lean:1601-1603 /
  spawn-analysis §Root Cause; the corollary is a one-line instantiation of the general lemma at n=3.
- **Risk**: reviving a falsified route (lossy depth-k projection / arity-1 navigated carrier / third
  free anchor). **Mitigation**: Postmortem Constraints below bar all three; the fold's projections
  are depth-0 ONLY and proven bijective (round-trip lemmas are Phase-2 deliverables, not hopes).
- **Risk**: `#print axioms` picks up an unexpected axiom. **Mitigation**: all constructions are
  `Classical.dec` + `funext` + order reasoning — same profile as landed NF lemmas; axiom check is a
  per-phase acceptance gate.

## Postmortem Constraints

Binding rules for every implementation dispatch. Derived from task-309's R2 NO-GO, the report's
deviation ledger (D1-D7), and guards G1-G6 + Corrected Anchor-Cap (inherited VERBATIM). Where a
deviation-ledger entry documents a departure from Rabinovich, the owning phase carries that entry
(see per-phase **Deviation carried** lines) — the USER DIRECTIVE requires literature-faithfulness
be maintained, so each phase cites its paper anchor and no chain step is shortcut.

**Do NOT**:
- Re-encode `nf_eval_nf`'s global definition or migrate any existing consumer. This task is
  ADDITIVE — one new file, zero edits to existing files (report §7 Alt A REJECTED; would orphan the
  sorry-free depth-0/arity-1 assets).
- Introduce a lossy depth-k (k≥1) projection / `projFresh`/`dropFresh` at k≥1. Depth-k pointwise
  factorization into arity-1 atoms is provably FALSE (deviation **D7**); it is the shape of the
  refuted "projection tower" (G2). The fold's projections are **depth-0 only**.
- Grow env arity past the fold's fixed `n` in the quant clause. The whole point is that the witness
  `x` NEVER enters an environment (G4). Any `Fin.cons`-into-env in the fold's quant layer is the
  bug being fixed.
- Use `nf_char3_deeper_split` (NfMultiAnchorBridge.lean:625-642) — it grows arity 3→4 / anchors
  {x,t}→{y,x,t}. BARRED (Corrected Anchor-Cap).
- Make the fold atom a `TemporalPred`/`Formula` (report §7 Alt D REJECTED — infinite syntactic
  class breaks the Fintype/completeness mechanism). The atom is `NormalForm sig k 1`.
- Make `nf_eval_efold`'s quant clause recurse through `nf_eval_efold` at arity 1. It must call
  `nf_eval_nf M k 1` (Def 4.1 fidelity + reuses the already-sorry-free TL tie-in; removes an entire
  equivalence obligation — deviation **D5**).
- Absorb the off-fiber falsity clause silently into `nf_eval_nf1_iff_efold`. It MUST be an explicit
  conjunct (`∀ sub, nf0_dropFresh sub ≠ qnf.1 → qnf.2 sub = false`) — the honest bridge.
- Shortcut a chain/atom step with `simp`/`omega`/`aesop` where a step-by-step transcription is
  required (G5 literature-fidelity). Cite Rabinovich PDF p.4-6 at each design step in doc-comments.
- Commit any `sorry` (strategic or otherwise). This task's zero-debt policy is absolute; no
  strategic-sorry division points are planned (report §Forbidden-output check).

**MUST preserve**:
- All task-309 `CONSUME, DO NOT REBUILD` assets (see Preserved Assets table) — sorry-free and on the
  live path. `lake build` on existing modules stays green throughout.
- G6's carrier SHAPE: `BracketEndCharCarrier` remains the two-anchor fixed-endpoint `VecEA2 1`
  bracket; anchors stay `{x,t}` (2, fixed), `w` a bracket witness. 310 changes only the recursion
  mechanism UNDERNEATH it, not the shape.
- Every new lemma's name and signature exactly as stated in report §5 — task 311's re-probe is
  constructed against these names (record them in the completion summary).

**Design decisions are SETTLED** (do not re-open without a concrete counterexample):
- **Alternative B** (parallel fold type + evaluator + lossless depth-0 bridge) is the chosen
  encoding (report §7). Alt A (global rewrite), Alt C (no new type), Alt D (TemporalPred atom), and
  Alt E (lossy depth-k projection) are REJECTED with reasons.
- The fold atom's semantics is `nf_eval_nf M k 1 (fun _ => x)`, NOT a `nf_eval_efold` recursion and
  NOT a `TemporalPred` (settled; deviation D5).
- The ≤2-free-var cap is a TYPE-LEVEL invariant (`EAtomDom` has no joint-evaluation slot), NOT a
  guard (settled; user directive, Lemma 3.2(2)).
- `nf0_dropFresh := mergeNF · ⟨0,_⟩` (reuse), NOT a bespoke restriction (settled after source read
  of NfDepth0Generalized:109-175).
- The main one-step lemma is stated at **general `n`** and the gate corollary INSTANTIATES it at
  n=3 (settled; general n is the reusable engine 309-R3 needs; costs no fidelity — report §5.3,
  Contradiction Log).
- The off-fiber falsity clause is an explicit conjunct (settled; report §5.4).

## Implementation Phases

All phases: new file `Kamp/NfEFold.lean` ONLY; zero edits to existing files. Every new declaration
doc-commented with its Rabinovich PDF page cite. Phase-end acceptance gate (all four required):
1. `lake build Theories.Bimodal.Metalogic.WeakCanonical.Kamp.NfEFold` GREEN.
2. `grep -n sorry` on the file → clean (0 occurrences) for declarations landed this phase.
3. `#print axioms {each new theorem}` = `[propext, Classical.choice, Quot.sound]` (or a subset).
4. Green sub-steps committed incrementally (git-workflow.md commit-per-green-substep mandate).

Imports for the file (Phase 1 header): `Bimodal.Metalogic.WeakCanonical.NormalForm` and
`Bimodal.Metalogic.WeakCanonical.Kamp.NfDepth0Generalized`. Nothing imports `NfEFold` → off the
live path.

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2 | 1 |
| 3 | 3 | 2 |
| 4 | 4 | 3 |

Fully sequential: each phase's declarations reference the prior phase's. No parallel opportunity
exists within this task (the file is a single ownership territory; the only parallelism is
cross-task — 311 is gated on this task's completion). Phases 3 and 4 carry pre-declared H8 split
seams (3.1/3.2, 4.1/4.2) to be exercised only if the one-run line/bounded-unit budget is exceeded.

### Phase 1: Fold encoding core (ZoneSpec, EAtomDom, NormalFormEFold, nf_eval_efold) [COMPLETED]
- **Goal:** Land the fold TYPE and EVALUATOR plus the trivial depth-0 coincidence — the load-bearing
  new objects — in `Kamp/NfEFold.lean`.
- **Artifact / done-when:** `NormalFormEFold`, `nf_eval_efold`, and `nf_eval_efold_zero_iff` compile
  sorry-free; `nf_eval_efold_zero_iff` proven by `Iff.rfl` (definitional coincidence of the two `0`
  clauses); acceptance gate 1-4 pass.
- **Tasks:**
  - [ ] File header + imports (`NormalForm`, `NfDepth0Generalized`); confirm off-live-path.
  - [ ] `ZoneSpec (n : Nat) : Type := Fin n → Bool × Bool` + `zoneHolds` (report §4.1). Cite Def 3.1 p.4.
  - [ ] `EAtomDom sig k n := ZoneSpec n × NormalForm sig k 1` (report §4.2). Cite Def 4.1 p.5, Lemma 3.2(2) p.4.
  - [ ] `NormalFormEFold : Nat → Nat → Type` (report §4.2). Cite Lemma 3.2(2) p.4 (type-level ≤2 cap).
  - [ ] `nf_eval_efold` recursion equation (report §4.3): quant clause folds via `nf_eval_nf M k 1
        (fun _ => x)` coupled to fixed env only through `zoneHolds`; env arity constant. Cite Def 4.1 p.5, Def 3.1 p.4.
  - [ ] `nf_eval_efold_zero_iff` (`:= Iff.rfl`) — depth-0 coincidence, task deliverable (report §4.3).
  - [ ] `skipFin_zero_succ` simp lemma (`skipFin ⟨0⟩ i = i.succ`) to make `nf0_dropFresh` compute in Phase 2.
  - [ ] Fintype/DecidableEq instances for `NormalFormEFold` ONLY IF free (else defer to 311; report §4.2). *(deviation: deferred to 311 — not free; `NormalFormEFold` is a `def` by recursion on `k`, so instances require an induction like `normalForm_fintype_and_decEq` (NormalForm.lean:166), not typeclass inference. Plan permits deferral; Phase 1 acceptance gate does not require them.)*
- **Deviation carried:** D5 (atom semantics = `nf_eval_nf M k 1`, interior arity growth accepted),
  D6 (equality zones via LinearOrder trichotomy), D3 (interval β via quant-assignment completeness).
- **Estimated output:** ~70-110 lines.
- **Depends on:** none.

### Phase 2: Depth-0 split kit + round-trip lemmas (the losslessness/bijection data) [IN PROGRESS]
- **Goal:** Land the four split-kit definitions and the four round-trip lemmas that make the depth-0
  factorization a proven BIJECTION — the G2 losslessness defense that distinguishes the fold from
  the refuted lossy projections.
- **Artifact / done-when:** `nf0_zoneSpec`, `nf0_projFresh`, `nf0_dropFresh`, `nf0_assemble` (total
  match, no `sorry`), and `nf0_split_assemble` + `nf0_zoneSpec_assemble` + `nf0_projFresh_assemble`
  + `nf0_dropFresh_assemble` compile sorry-free; acceptance gate 1-4 pass.
- **Tasks:**
  - [ ] `nf0_zoneSpec` (fresh-var order atoms → ZoneSpec) (report §4.4). Cite Def 3.1 p.4 (ordering channel).
  - [ ] `nf0_projFresh` (fresh-var pred atoms → `NormalForm sig 0 1`; absurd on order atoms at arity 1). Cite Def 3.1 p.4 (monadic α channel).
  - [ ] `nf0_dropFresh := mergeNF sub ⟨0, _⟩` (REUSE NfDepth0Generalized:169). Cite Def 3.1 p.4 (env restriction).
  - [ ] `nf0_assemble` — TOTAL match reassembling from the three channels (~15 lines `Fin.cases`
        bookkeeping; the report §4.4 `sorry` is a report-level elision, implementer writes the full match).
  - [ ] `nf0_split_assemble` (assemble ∘ split = id) + three projection round-trips — `funext` + atom cases.
- **Deviation carried:** Bijectivity is the explicit rebuttal to D7's depth-k falsity — projections
  are depth-0 ONLY (Postmortem: no k≥1 projection).
- **Estimated output:** ~90-140 lines.
- **Depends on:** 1.

### Phase 3: Factorization theorem (nf_eval_nf0_cons_factor) [NOT STARTED]
- **Goal:** Prove the mathematical core — a depth-0 (n+1)-ary evaluation with the fresh witness
  consed factors EXACTLY into Rabinovich's Def 3.1 three channels (ordering / monadic point type /
  env restriction), losslessly.
- **Artifact / done-when:** `nf_eval_nf0_cons_factor` (report §5.2, exact signature) compiles
  sorry-free; acceptance gate 1-4 pass.
- **Tasks:**
  - [ ] State `nf_eval_nf0_cons_factor` VERBATIM per report §5.2 (general `n`). Cite Def 3.1 p.4.
  - [ ] Forward direction: unfold depth-0 `nf_eval_nf` both sides; instantiate at the four atom
        groups (generalized `extract_y_nf` pattern, VecEADecomp:55-66); `Fin.cons_zero`/`Fin.cons_succ`.
  - [ ] Backward direction: given arbitrary `a : AtomKind sig (n+1)`, `Fin.cases` its indices,
        discharge from the matching channel.
- **H8 split seam (pre-declared, exercise only on one-run overrun):**
  - **Phase 3.1** — forward direction (factor-out) sorry-free.
  - **Phase 3.2** — backward direction (reassemble) sorry-free, closing the iff.
- **Deviation carried:** D2 (joint (n+1)-ary domain bridged losslessly at depth-0 subs).
- **Estimated output:** ~100-160 lines (report §9 flags this as the riskiest phase for overrun).
- **Depends on:** 2.

### Phase 4: Bridge lemmas + k=1 gate corollary (the DONE signal) [NOT STARTED]
- **Goal:** Deliver the general-`n` one-step engine, the k=1 whole-evaluation transport, and the
  gate corollary stated VERBATIM against the R2 NO-GO residual — task 311's entry point.
- **Artifact / done-when:** `nf_quant_layer_fold_iff`, `efold_of_nf1`, `nf_eval_nf1_iff_efold`, and
  `nf_quant_layer_fold_k1_gate` compile sorry-free; the gate corollary's LHS matches
  NfMultiAnchorBridge.lean:1601-1603 (spawn-analysis §Root Cause) character-for-character; acceptance
  gate 1-4 pass. **This gate corollary proven sorry-free is the task's DONE signal.**
- **Tasks:**
  - [ ] `nf_quant_layer_fold_iff` (report §5.3, GENERAL `n`, full iff). Forward/backward per report
        §5.3 proof shape; second-conjunct off-fiber falsity via `nf_eval_unique` (NormalForm.lean:245) + `h_r`. Cite Prop 4.3 p.6.
  - [ ] `efold_of_nf1` (transport `NormalForm sig 1 n → NormalFormEFold sig 1 n`) (report §5.4).
  - [ ] `nf_eval_nf1_iff_efold` (report §5.4) — atom layers coincide definitionally; quant layers via
        `nf_quant_layer_fold_iff` with `r := qnf.1`; explicit off-fiber falsity conjunct (NOT absorbed). Cite Def 4.1 p.5, Lemma 3.4 p.5.
  - [ ] `nf_quant_layer_fold_k1_gate` (report §5.5) — one-line instantiation
        `nf_quant_layer_fold_iff M _ qnf.1 h_atom qnf.2` at n=3, env `[w,x,t]`; LHS = verbatim R2 residual. Cite Prop 4.3 p.6, Lemma 3.4 p.5.
  - [ ] `#print axioms nf_quant_layer_fold_k1_gate` = `[propext, Classical.choice, Quot.sound]`.
- **H8 split seam (pre-declared, exercise only on one-run overrun):**
  - **Phase 4.1** — `nf_quant_layer_fold_iff` (the load-bearing engine; only proof using `nf_eval_unique`) sorry-free.
  - **Phase 4.2** — `efold_of_nf1` + `nf_eval_nf1_iff_efold` + `nf_quant_layer_fold_k1_gate` sorry-free.
- **Deviation carried:** D7 — this bridge is claimed ONLY at depth-0 subs (k=1); NO depth-k (k≥1)
  pointwise equivalence is stated or attempted. D3 (interval β via false quant entries surfaces for 311).
- **Estimated output:** ~90-140 lines.
- **Depends on:** 3.

## Testing & Validation

- [ ] `lake build Theories.Bimodal.Metalogic.WeakCanonical.Kamp.NfEFold` GREEN after every phase.
- [ ] `lake build` on the full library GREEN (confirms no existing consumer regressed — additive check).
- [ ] `grep -rn 'sorry\|admit\|native_decide' Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfEFold.lean` → clean.
- [ ] `#print axioms` on each of `nf_eval_efold_zero_iff`, `nf_eval_nf0_cons_factor`,
      `nf_quant_layer_fold_iff`, `nf_eval_nf1_iff_efold`, `nf_quant_layer_fold_k1_gate` =
      `[propext, Classical.choice, Quot.sound]` (or a subset).
- [ ] `nf_quant_layer_fold_k1_gate` LHS diffed against NfMultiAnchorBridge.lean:1601-1603 — verbatim match.
- [ ] Completion summary records the final chosen names/signatures (`NormalFormEFold`,
      `nf_eval_efold`, `nf_quant_layer_fold_iff`, `nf_eval_nf1_iff_efold`,
      `nf_quant_layer_fold_k1_gate`, split-kit names) — task 311's re-probe is built against these.

## Artifacts & Outputs

- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfEFold.lean` (new file; the sole code artifact).
- `specs/310_normalform_efold_encoding/plans/01_efold-encoding-plan.md` (this file).
- `specs/310_normalform_efold_encoding/summaries/01_efold-encoding-summary.md` (on completion;
  MUST document the final fold definition name(s) and bridge lemma signature(s) — 311 depends on them).

## Rollback/Contingency

- The task is additive and off the live path: reverting is deleting `Kamp/NfEFold.lean` (and its
  import line if any). No existing consumer is touched, so rollback cannot break the live build.
- On a phase build failure: fix forward (correct the source); never discard uncommitted changes to
  reach a passing build (recovery.md ladder). If a phase's bounded unit proves genuinely harder than
  the H8 seam anticipates, exercise the pre-declared 3.1/3.2 or 4.1/4.2 split before considering any
  scope change — do NOT introduce a `sorry` (zero-debt policy).
- If Phase 3 or 4 reveals that the report's proof shape has a concrete defect (not merely more
  lines), STOP and report to the orchestrator rather than substituting a falsified route (lossy
  depth-k projection, arity-1 navigated carrier, third free anchor — all BARRED).
