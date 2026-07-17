# Implementation Plan: Task #383 — Phase 7 negation-case unblock (chain-split construction)

- **Task**: 383 - Construct the phase 7 negation-case unblock per adjudication verdict
- **Status**: [IMPLEMENTING]
- **Effort**: 16 hours (range 14-20)
- **Dependencies**: 382 (adjudication, COMPLETED — verdict RECONCILE); parent 379 (Phase 7)
- **Research Inputs**: specs/382_adjudicate_rabinovich_faithfulness_of_the_phase_7_negationcase_unblock/reports/01_go-reconcile-verdict.md
- **Artifacts**: plans/01_phase7-negation-split.md (this file)
- **Standards**: plan-format.md; status-markers.md; artifact-management.md; tasks.md; lean4.md; plan-compliance.md
- **Type**: lean4
- **Lean Intent**: false

## Overview

The adjudication task (382) returned verdict **RECONCILE**: Rabinovich's actual Proposition 4.2
negation (PDF Section 5, p.7) negates a single arbitrary-pin two-free-variable `∃∀`-object by
**splitting its ordered chain at the two pinned points into three consecutive pieces** — a below
piece `ψ_0(z_0)` (one free var, before-cap, negated via Prop 3.5), an above piece `ψ_1(z_1)`
(one free var, after-cap, via Prop 3.5), and a cap-free endpoint-pinned middle `φ(z_0,z_1)` (the
repo's existing `EndpointPinnedCapTrivial` engine) — then reassembles the negation by the
**disjunction** `¬(ψ_0 ∧ ψ_1 ∧ φ) = ¬ψ_0 ∨ ¬ψ_1 ∨ ¬φ`. There is NO conjunction closure and NO
`conjInterleave` on the negation-case critical path. This plan transcribes that split (verdict
deliverables D1 → D2 → D3) into new off-path Lean, totalling ~350-550 lines, and re-attempts the
parent's Phase 7 Prop 4.3 negation case on the new engine. Definition of done: `lake build` stays
EXIT 0 at the existing job count, no new axiom/sorry on `completeness_discrete`'s axiom trace, no
sorry / vacuous placeholder / `Prop43Structural.lean` hole, every deliverable compiles.

### Research Integration

Report 382 (`01_go-reconcile-verdict.md`) is authoritative over the earlier report-06
`conjInterleave` proposal. Its signatures and line estimates (D1 `efSat_split` ~150-250 lines;
D2 `prop42_efSat_negation_general` ~120-220 lines with a ~40-80-line "TL-formula-as-atom"
residual to typecheck first; D3 wiring ~30-60 lines) are treated as the ground truth. The
reused, already-sorry-free assets it cites are:

- `efSat`, `ExistsForallFormula` fields (`ExistsForallFormula.lean:81-111`) — object under negation.
- `prop42_veeSat_negation` + `EndpointPinnedCapTrivial` (`Prop42ExistsForall.lean:435-445`, `:75-86`)
  — negate the endpoint-pinned cap-free **middle** piece.
- `translateProp35` / `translateProp35_correct` (`Prop35Assembly.lean:84-97`) and
  `translateVeeProp35` / `_correct` (`Prop35Assembly.lean:373-395`) — negate the two **end** pieces.
- `gluedChain` + companions (`ExistsForallLemmas.lean:579-688`) — template for the split
  **backward** (gluing) direction; three pieces in FIXED order, so no interleaving enumeration.
- `VVecEA2.disj` / `disj_holds`, `VVecEA2.trivialTrue` (`VecEAFormula.lean:282-286`,
  `VecEAConjFull.lean:542`) — disjunctive reassembly and trivial caps of `splitMiddle`.
- `veeSat_append` (`VeeExistsForall.lean:69`) — `∨∃∀` disjunction closure.

### Prior Plan Reference

No prior plan for task 383. Parent task 379's Phase 7 reached BLOCKED on the negation seam
(arbitrary-pin new mathematics); this task exists to discharge exactly that seam. The RECONCILE
verdict supersedes report-06's `conjInterleave`+`veeConj`+general-negation stack; that heavier
route is explicitly NOT built here.

### Roadmap Alignment

No `roadmap_flag` set for this task; ROADMAP.md is not consulted or modified. Topic:
`kamp-completeness`. This task unblocks the parent's Phase 7 negation case, advancing the Kamp's
Theorem completeness line.

## Goals & Non-Goals

**Goals**:
- Build D1: `efSat_split` and the three split constructors (`splitBelow`, `splitAbove`,
  `splitMiddle`) plus `splitMiddle_endpointPinned`, in a NEW off-path file.
- Build D2: `prop42_efSat_negation_general` (single arbitrary-pin two-free-var object → `VVecEA2`
  witness of its negation) via the split, reassembled by disjunction.
- Build D2 residual first: realize `¬(translateProp35 …)` (a one-free-var TL `Formula`) as a
  `VVecEA2` single-point endpoint clause — the one genuinely new small piece; typecheck it before
  the rest of D2.
- Wire D3: re-target the parent's Phase 7 Prop 4.3 negation-case call from the endpoint-only
  `prop42_veeSat_negation` onto `prop42_efSat_negation_general`, and re-attempt that case.
- Keep `lake build` EXIT 0 at the existing job count throughout; add zero live-path sorries/axioms.

**Non-Goals**:
- Do NOT build `conjInterleave` (Lemma 3.2(1) interleaving) or `veeConj` (Lemma 3.4 conjunction
  closure). Those belong to the separate AND / `¬∨` connective case (`Prop43.lean:151`) and are
  out of scope for the negation unblock.
- Do NOT re-target `augTarget`/`pairProject` to force endpoint pins (verdict cross-check 2: not
  equivalence-preserving; the split is the correct lever, not re-targeting).
- Do NOT touch `Prop43Structural.lean` with a hole, add a vacuous placeholder, or introduce any
  `sorry`.
- Do NOT put new deliverables on the live import path until D3 rewires (mirroring how
  `Prop43.lean` / `Prop42ExistsForall.lean` already sit off-path).

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| D2 residual "TL-formula-as-`∃∀`-atom" realization does not typecheck as expected | H | M | Build it FIRST as a standalone Phase-1 lemma (verdict's explicit instruction); it is construction, not combinatorics; use `atomMap`/`h_surj` surjectivity as `atomAt`/`atom_literal` (`Prop43.lean:75-90`) already do. If it resists, escalate to [BLOCKED] with the exact typecheck obstruction rather than forcing. |
| `efSat_split` backward (gluing) direction harder than the `gluedChain` template suggests | H | M | Reuse `gluedChain`'s "glue along shared pins" verbatim; only THREE pieces in FIXED order (`below < x_m < middle < x_k < above`) so no interleaving enumeration is ever formed. Prove forward direction (decomposition) first, commit green, then backward. |
| Degenerate `k=m` (`z_0=z_1`) case and `wlog m>k` symmetry add unhandled branches | M | M | Handle per verdict A4: `k=m` reduces to a single one-free-var object (no `splitMiddle`); add a small `wlog`/symmetry wrapper normalizing `ψ.pin 0 > ψ.pin 1`. Cover both in the `efSat_split` phase, not deferred. |
| New off-path file silently excluded from `lake build`, hiding compile errors | M | M | After each phase, build the new module BY NAME (`lake build Bimodal.…Kamp.Prop42NegationGeneral`) in addition to the full `lake build`; only D3 adds it to the live path. |
| D3 rewire changes `completeness_discrete`'s axiom trace / job count | H | L | After D3, run the axiom-trace check on `completeness_discrete` and confirm job count unchanged before marking complete; D3 is a call-site swap to an already-proven engine, not new axioms. |
| Wrong seam located for the Phase 7 negation-case call | M | M | The negation-case call site currently routing `pairProject` output to `prop42_veeSat_negation` is the target; confirm the exact declaration with `lean_references`/grep before editing, and keep the edit minimal (~30-60 lines). |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2 | 1 |
| 3 | 3 | 2 |
| 4 | 4 | 1, 3 |
| 5 | 5 | 4 |
| 6 | 6 | 5 |

Phases within the same wave can execute in parallel. This build-up is single-file (one new module)
through Phase 4, so phases are sequenced to avoid same-file territory conflicts; the logical
dependency of Phase 2 on Phase 1 is file-ordering only (the split defs do not use the residual).

### Phase 1: D2 residual — realize `¬(one-free-var TL Formula)` as a `VVecEA2` endpoint clause [COMPLETED]

**Goal**: Build and typecheck FIRST the one genuinely new small piece: a construction turning the
negation of a `translateProp35`-produced one-free-var `Formula` into a single-point `VVecEA2`
endpoint clause (Rabinovich's "atomic in the `E[Σ]` expansion" step, verdict A4 / PDF p.7). This
de-risks D2 before any split machinery is written.

**Tasks**:
- [ ] Create new off-path file `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/Prop42NegationGeneral.lean`
  with a durable-anchor module docstring (cite Rabinovich PDF p.7 by page only; NO task-number
  references). Import only what is needed (`Prop35Assembly`, `Prop42ExistsForall`, `VecEAFormula`,
  `VeeExistsForall`). Do NOT add it to any live import path.
- [ ] State and prove the residual lemma: given `atomMap`, `h_surj`, and a one-free-var
  `ExistsForallFormula`, realize `¬ temporal_truth N atomMap x (translateProp35 …)` as
  `(clause).holds N atomMap x` for a constructed single-point `VVecEA2` clause. Use the
  `atomMap`/`h_surj` surjectivity pattern from `atomAt`/`atom_literal` (`Prop43.lean:75-90`).
- [ ] Build the module by name; confirm zero sorries and EXIT 0.

**Timing**: 2-3 hours

**Depends on**: none

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/Prop42NegationGeneral.lean` (new) — residual lemma
  + module scaffold.

**Verification**:
- `lake build Bimodal.Metalogic.WeakCanonical.Kamp.Prop42NegationGeneral` EXIT 0, no `sorry`.
- `git grep -n sorry` on the new file returns nothing.
- Full `lake build` still EXIT 0 at existing job count (file is off-path; build it by name too).
- Green commit: `task 383 phase 1.1: TL-formula-as-endpoint-clause residual`.

---

### Phase 2: D1 (part a) — the three chain-split constructors + `splitMiddle_endpointPinned` [BLOCKED]

**BLOCKER** (Phase 2 — encoding-level; the plan's Phase 2/3/4 construction as written cannot close):

- **What failed**: The plan/verdict specify the split as standalone `ExistsForallFormula`/`efSat`
  pieces — `splitBelow`/`splitAbove : … 1`, `splitMiddle : … 2`, `splitMiddle_endpointPinned :
  EndpointPinnedCapTrivial N (splitMiddle ψ)`, and `efSat_split : efSat ψ ↔ efSat(splitBelow) ∧
  efSat(splitMiddle) ∧ efSat(splitAbove)` — with the middle "cap-free" (caps set to a `UnaryType`
  top) and routed through `prop42_veeSat_negation`. This does not typecheck/prove as stated.
- **Root cause (machine-confirmed, scratch probe EXIT 0)**: In this repo's encoding,
  (i) `efSat` **mandatorily** carries two *universal* exterior-cap clauses — the 5th conjunct
  `∀ y < x 0, unaryHolds N (ψ.intervalType 0) y` and the 6th `∀ y > x (Fin.last ψ.n),
  unaryHolds N (ψ.intervalType (last)) y` (`ExistsForallFormula.lean:107,110`); there is no
  cap-free `efSat`. (ii) `unaryHolds N τ p ↔ ∀ a : AtomKind (sigE sig F) 1, atom_eval N (fun _=>p) a
  ↔ (τ a = true)` — *exact* agreement on every atom (`unaryHolds_iff`; `nf_eval_nf` depth-0,
  `NormalForm.lean:198`). (iii) `(sigE sig F).preds = sig.preds ⊕ {A // A ∈ F}`
  (`ESigmaExpansion.lean:63`) is non-empty on the completeness spine, so `AtomKind (sigE sig F) 1`
  has genuine predicate atoms. Consequently **no fixed `UnaryType` is realized at every point** of a
  general `N`, so there is no "`UnaryType` top" and `EndpointPinnedCapTrivial`'s
  `capTrivialLeft/Right : ∀ y, unaryHolds N cap y` **cannot be discharged from any construction**.
  Worse, the *forward* direction of `efSat_split` already fails: from `efSat ψ`, the below piece's
  mandatory after-cap `∀ y > z₀, unaryHolds (splitBelow.afterCap) y` is unprovable (the region
  above `z₀ = x_m` contains the middle/above content, not a single universal type). So the
  standalone-`efSat` three-way split iff is **false in this encoding**, independent of proof effort.
  (The plan cited `VVecEA2.trivialTrue` for "the vacuous caps", but that is a `VVecEA2` at the
  cap-free `VecEA2` level — it does not supply a universally-realized `UnaryType`, which is what
  `EndpointPinnedCapTrivial` needs. The two levels were conflated.)
- **What was tried**: Located and read every cited asset (`efSat`, `EndpointPinnedCapTrivial`,
  `prop42_veeSat_negation`, `translateProp35`, `gluedChain`, `VVecEA2`); confirmed the cap semantics
  and the non-existence of a universal `UnaryType` with a compiling scratch probe. No `sorry` /
  vacuous placeholder inserted anywhere.
- **What is needed (concrete continuation / repair path, requires a plan revision)**: Rabinovich's
  cap-free / one-sided pieces ARE expressible in this repo — but NOT as standalone `efSat` objects.
  Build the split at the **TL-formula + bounded-`VecEA2`** level instead:
  * Below piece `ψ₀(z₀)` → the one-sided TL formula `α_m ∧ buildLeft(x_{m-1}..x₀, β₀)`
    (`ExistsForallNF.lean:310`; Since/past, terminates in `H(β₀)`, constrains only `≤ z₀`).
  * Above piece `ψ₁(z₁)` → `α_k ∧ buildRight(x_{k+1}..x_n, β_{n+1})`
    (`ExistsForallNF.lean:297`; Until/future, terminates in `G(β_{n+1})`, constrains only `≥ z₁`).
  * Middle `φ(z₀,z₁)` → a **bounded `BracketFormula`/`VecEA2`** on `(z₀,z₁)` (cap-free *by
    construction* — `VecEA2.holds`/`BracketFormula.holds` carry no exterior caps), negated by the
    legacy `VVecEA2.negFix_iff` engine **directly** (NOT via `efSat`/`EndpointPinnedCapTrivial`).
  * `¬ψ₀`, `¬ψ₁` realize directly as endpoint `TemporalPred`s (exactly this task's Phase-1
    `negLeftClause`/`negRightClause`, already landed sorry-free), combined with `¬φ` by
    `VVecEA2.disj`. `buildLeft_spec_iff_chain`/`buildRight_spec_iff_chain` (`Prop35Chain.lean:56,146`)
    are the correctness bridges. This needs a genuine `efSat ψ ↔ (α_m ∧ leftPart)(z₀) ∧
    bracket(z₀,z₁) ∧ (α_k ∧ rightPart)(z₁)` decomposition lemma (new, ~200-400 lines) — a Prop 4.2
    re-derivation at the TL level, not a re-use of the endpoint-pinned engine.
- **Prohibited workarounds** (not used): `sorry`, `def X := True`/`trivial`, a `UnaryType` falsely
  asserted universal, or weakening `prop42_efSat_negation_general` back to an
  `EndpointPinnedCapTrivial` hypothesis (that reintroduces exactly the endpoint restriction the
  task exists to remove).

**Goal** (original, not achievable as written): Define the three consecutive sub-chain pieces of the
arbitrary-pin two-free-var object and prove the middle piece satisfies `EndpointPinnedCapTrivial`.

**Tasks**:
- [ ] `splitBelow (ψ : ExistsForallFormula sig F 2) : ExistsForallFormula sig F 1` — chain
  `x_0..x_m` with `α_0..α_m`, `β_1..β_m`, and the before-cap `β_0`; free var pinned to the RIGHT
  endpoint `x_m` (verdict D1).
- [ ] `splitAbove (ψ : ExistsForallFormula sig F 2) : ExistsForallFormula sig F 1` — chain
  `x_k..x_n` with `α_k..α_n`, `β_{k+1}..β_n`, and the after-cap `β_{n+1}`; free var pinned to the
  LEFT endpoint `x_k`.
- [ ] `splitMiddle (ψ : ExistsForallFormula sig F 2) : ExistsForallFormula sig F 2` — middle chain
  `x_m..x_k` with `α_m..α_k`, `β_{m+1}..β_k`, caps set to `UnaryType` top so
  `EndpointPinnedCapTrivial` holds.
- [ ] `splitMiddle_endpointPinned (N) (ψ) (hpin : ψ.pin 0 ≤ ψ.pin 1) : EndpointPinnedCapTrivial N
  (splitMiddle ψ)` — discharge `posN`, `pinLeft`, `pinRight`, `capTrivialLeft/Right` from the
  construction (`VVecEA2.trivialTrue` for the vacuous caps).
- [ ] Build the module by name; confirm zero sorries.

**Timing**: 2-3 hours

**Depends on**: 1

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/Prop42NegationGeneral.lean` — split constructors
  + endpoint-pinned lemma.

**Verification**:
- `lake build Bimodal.…Kamp.Prop42NegationGeneral` EXIT 0, no `sorry`.
- `splitMiddle_endpointPinned` typechecks with only `hpin` as the ordering hypothesis.
- Full `lake build` EXIT 0 at existing job count.
- Green commit: `task 383 phase 2.1: chain-split constructors + endpoint-pinned`.

---

### Phase 3: D1 (part b) — the `efSat_split` decomposition theorem [NOT STARTED]

**Goal**: Prove the Section-5 three-way decomposition as an `iff`, including the forward
decomposition and the backward gluing (via the `gluedChain` technique), plus the `k=m` degenerate
branch and the `wlog m>k` symmetry wrapper.

**Tasks**:
- [ ] State `efSat_split (N) (env : Fin 2 → N.carrier) (ψ) (hpin : ψ.pin 0 ≤ ψ.pin 1) :
  efSat N env ψ ↔ efSat N ![env 0] (splitBelow ψ) ∧ efSat N ![env 0, env 1] (splitMiddle ψ) ∧
  efSat N ![env 1] (splitAbove ψ)` (verdict D1 signature).
- [ ] Prove forward direction (decompose the single witness chain into the three sub-chains at the
  pinned points `x_m`, `x_k`); commit green.
- [ ] Prove backward direction by gluing the three sub-chains along their shared pinned endpoints,
  reusing `gluedChain` / `gluedChain_pin` / `consecChain` (`ExistsForallLemmas.lean:579-688`);
  FIXED three-piece order, no interleaving enumeration.
- [ ] Handle the degenerate `ψ.pin 0 = ψ.pin 1` (`k=m`) case (single one-free-var object, no
  `splitMiddle`) and add the `wlog`/symmetry wrapper normalizing `ψ.pin 0 > ψ.pin 1`.
- [ ] Build the module by name; confirm zero sorries.

**Timing**: 3-4 hours

**Depends on**: 2

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/Prop42NegationGeneral.lean` — `efSat_split`
  theorem + degenerate/symmetry handling.

**Verification**:
- `lake build Bimodal.…Kamp.Prop42NegationGeneral` EXIT 0, no `sorry` (both `iff` directions
  closed, all branches covered).
- Full `lake build` EXIT 0 at existing job count.
- Green commits per direction: `task 383 phase 3.1: efSat_split forward`,
  `task 383 phase 3.2: efSat_split backward + degenerate/wlog`.

---

### Phase 4: D2 — `prop42_efSat_negation_general` (single object negation → `VVecEA2` witness) [NOT STARTED]

**Goal**: Assemble the arbitrary-pin single-object negation from the split: negate the middle via
`prop42_veeSat_negation`, negate the two ends via `translateProp35` → `Formula.neg` → the Phase-1
residual, and combine the three by disjunction.

**Tasks**:
- [ ] State `prop42_efSat_negation_general (N) (atomMap) (h_surj) (h_INF) (h_SUP) (ψ :
  ExistsForallFormula sig F 2) : ∃ v' : VVecEA2, ∀ env : Fin 2 → N.carrier, env 0 < env 1 →
  (v'.holds N atomMap (env 0) (env 1) ↔ ¬ efSat N env ψ)` (verdict D2 signature; output shape
  mirrors `prop42_veeSat_negation`).
- [ ] Via `efSat_split`: `¬efSat ψ ↔ ¬efSat(splitBelow) ∨ ¬efSat(splitMiddle) ∨ ¬efSat(splitAbove)`.
- [ ] `¬splitMiddle` via `prop42_veeSat_negation` on the singleton `VeeExistsForall [splitMiddle ψ]`
  discharged by `splitMiddle_endpointPinned` (Phase 2); inherit `HasAttainedINF/SUP` exactly as
  `prop42_veeSat_negation` does.
- [ ] `¬splitBelow`, `¬splitAbove` via `translateProp35` → `Formula.neg` → Phase-1 residual to a
  single-point `VVecEA2` endpoint clause.
- [ ] Combine the three witnesses with `VVecEA2.disj` / `disj_holds` (and `veeSat_append` where the
  `∨∃∀` disjunction closure is needed).
- [ ] Build the module by name; confirm zero sorries.

**Timing**: 3-4 hours

**Depends on**: 1, 3

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/Prop42NegationGeneral.lean` —
  `prop42_efSat_negation_general`.

**Verification**:
- `lake build Bimodal.…Kamp.Prop42NegationGeneral` EXIT 0, no `sorry`.
- `prop42_efSat_negation_general` typechecks with the exact verdict signature (arbitrary pins; no
  `EndpointPinnedCapTrivial` hypothesis on `ψ`).
- Full `lake build` EXIT 0 at existing job count.
- Green commit: `task 383 phase 4.1: prop42_efSat_negation_general via split`.

---

### Phase 5: D3 — wire into parent Phase 7 and re-attempt the Prop 4.3 negation case [NOT STARTED]

**Goal**: Re-target the parent's Phase 7 Prop 4.3 negation-case call from the endpoint-only
`prop42_veeSat_negation` onto `prop42_efSat_negation_general`, bringing the new module onto the
live path only here, and re-attempt the negation case.

**Tasks**:
- [ ] Locate the exact Phase 7 negation-case seam that currently hands `pairProject` output to
  `prop42_veeSat_negation` (confirm with `lean_references`/grep before editing).
- [ ] Add the `Prop42NegationGeneral` import at the seam (its first live-path use) and replace the
  endpoint-only call with `prop42_efSat_negation_general`; the per-object negations combine by
  disjunction (`VVecEA2.disj` / `veeSat_append`) — no conjunction closure.
- [ ] Re-attempt the negation case; confirm it closes without `sorry` / placeholder /
  `Prop43Structural.lean` hole.
- [ ] Build the affected live-path target(s).

**Timing**: 2-3 hours

**Depends on**: 4

**Files to modify**:
- The parent Phase 7 negation-case file (seam confirmed at implementation time; the call site
  routing `pairProject` output to `prop42_veeSat_negation`) — call-site swap + one import.
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/Prop42NegationGeneral.lean` — only if a minor
  signature adjustment is needed for the seam.

**Verification**:
- The negation case closes with no `sorry`, no vacuous placeholder, no `Prop43Structural.lean` hole.
- `lake build` EXIT 0.
- Green commit: `task 383 phase 5.1: wire Phase 7 negation case onto general engine`.

---

### Phase 6: Full verification — build, axiom trace, sorry/placeholder audit [NOT STARTED]

**Goal**: Confirm the whole-project invariants hold after the rewire.

**Tasks**:
- [ ] `lake build` EXIT 0 at the existing job count (compare job count to pre-task baseline).
- [ ] Axiom-trace check on `completeness_discrete` (`lean_verify` / `#print axioms`): no NEW
  axiom and no `sorryAx` introduced by this task.
- [ ] Repo-wide audit: no new `sorry`, no vacuous placeholder, no `Prop43Structural.lean` hole on
  the live path.
- [ ] Confirm all Rabinovich citations in new files are by PDF page only and all new-file headers
  use durable anchors (no task-number references inside `Theories/`).

**Timing**: 1-2 hours

**Depends on**: 5

**Files to modify**:
- None (verification only; fix-forward into prior phases' files if an invariant fails).

**Verification**:
- `lake build` EXIT 0, job count unchanged.
- `completeness_discrete` axiom trace free of new axioms / `sorryAx`.
- `git grep -n sorry` shows no new live-path sorries.
- Final commit: `task 383: complete implementation`.

## Testing & Validation

- [ ] Each phase: `lake build` (and `lake build <new module>` while off-path) EXIT 0, zero new sorries.
- [ ] `efSat_split` proves both `iff` directions incl. `k=m` degenerate and `wlog m>k` symmetry.
- [ ] `prop42_efSat_negation_general` typechecks with arbitrary pins (no `EndpointPinnedCapTrivial`
  hypothesis on the input object).
- [ ] Phase 7 negation case closes on the new engine, reassembled by disjunction only.
- [ ] `completeness_discrete` axiom trace: no new axiom / `sorryAx`; `lake build` job count unchanged.
- [ ] No `Prop43Structural.lean` hole; no vacuous placeholders; Rabinovich cited by PDF page only.

## Artifacts & Outputs

- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/Prop42NegationGeneral.lean` (new, off-path until D3):
  Phase-1 residual, `splitBelow`/`splitAbove`/`splitMiddle`, `splitMiddle_endpointPinned`,
  `efSat_split`, `prop42_efSat_negation_general`.
- Edited parent Phase 7 negation-case file (D3 call-site swap + one import).
- `specs/383_.../plans/01_phase7-negation-split.md` (this plan).
- `specs/383_.../summaries/01_phase7-negation-split-summary.md` (on completion).

## Rollback/Contingency

- The new module is off the live import path through Phase 4, so partial progress is inert:
  reverting the D3 seam edit (Phase 5) fully restores prior `lake build` behavior. Snapshot via
  `bash .claude/scripts/git-snapshot.sh` before the D3 rewire.
- If the Phase-1 residual or `efSat_split` backward direction proves unexpectedly intractable
  (genuinely new mathematics beyond the cited assets), do NOT force a construction or add a
  placeholder: escalate task 383 to [BLOCKED] citing the specific unresolved typecheck/proof
  obstruction, preserving the green sub-steps already committed.
- Each green sub-step is committed as it lands (commit-per-green-substep mandate), so any failure
  resumes from the last green commit via `/implement 383`.
