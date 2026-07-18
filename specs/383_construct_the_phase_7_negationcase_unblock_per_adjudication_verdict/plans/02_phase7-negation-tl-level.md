# Implementation Plan: Task #383 — Phase 7 negation-case unblock (TL-level chain split, v2)

- **Task**: 383 - Construct the phase 7 negation-case unblock per adjudication verdict
- **Status**: [IMPLEMENTING]
- **Effort**: 18 hours remaining (range 15-24); Phase 1 (~2-3h) already landed green
- **Dependencies**: 382 (adjudication, COMPLETED — verdict RECONCILE); parent 379 (Phase 7)
- **Research Inputs**: specs/382_adjudicate_rabinovich_faithfulness_of_the_phase_7_negationcase_unblock/reports/01_go-reconcile-verdict.md; specs/383_construct_the_phase_7_negationcase_unblock_per_adjudication_verdict/handoffs/phase-2-handoff.md
- **Artifacts**: plans/02_phase7-negation-tl-level.md (this file); supersedes plans/01_phase7-negation-split.md
- **Standards**: plan-format.md; status-markers.md; artifact-management.md; tasks.md; lean4.md; plan-compliance.md; no-task-references-in-deliverables.md
- **Type**: lean4
- **Lean Intent**: false
- **reports_integrated**: 01_go-reconcile-verdict.md (task 382); phase-2-handoff.md (task 383 encoding-blocker + machine-confirmed repair path)

## Overview

This is a **revision of plan v1** (`plans/01_phase7-negation-split.md`). Plan v1 transcribed the
RECONCILE verdict literally, building the Section-5 three-way chain split as **standalone `efSat`
objects** with a "cap-free" middle discharged through `EndpointPinnedCapTrivial`. A machine-confirmed
scratch probe (EXIT 0) established that this cannot close in this repo's encoding, and the parent
implementer raised it as a Phase-2 blocker per `plan-compliance.md`:

- `efSat` (`ExistsForallFormula.lean:100`) **mandatorily** carries two *universal* exterior-cap
  conjuncts — the before-cap `∀ y < x 0, unaryHolds N (ψ.intervalType 0) y` (**4th** conjunct,
  `:107`) and the after-cap `∀ y > x (Fin.last ψ.n), unaryHolds N (ψ.intervalType (Fin.last (ψ.n+1))) y`
  (**6th** conjunct, `:110-111`). There is no cap-free `efSat`.
- `unaryHolds N τ p` is *exact* atom-agreement on every `AtomKind (sigE sig F) 1` (`unaryHolds_iff`;
  `nf_eval_nf` depth-0, `NormalForm.lean:198`), and `(sigE sig F).preds = sig.preds ⊕ {A // A ∈ F}`
  (`ESigmaExpansion.lean:63`) is non-empty on the spine, so **no fixed `UnaryType` is realized at
  every point** of a general `N`.
- Hence there is no "`UnaryType` top", `EndpointPinnedCapTrivial.capTrivialLeft/Right` is
  undischargeable by construction, and `efSat_split`'s **forward** direction is outright FALSE (the
  below piece's mandatory after-cap `∀ y > z₀` ranges over the middle/above content, not a single
  universal type). v1 conflated `VVecEA2.trivialTrue` (a cap-free *`VecEA2`-level* object) with a
  universally-realized `UnaryType` — different levels.

**What is preserved**: Phase 1 landed green, sorry-free, off-path, committed — the D2 residual
`negLeftClause`/`negLeftClause_holds` and `negRightClause`/`negRightClause_holds`
(`Prop42NegationGeneral.lean:69,80,104,115`): `VVecEA2` endpoint clauses whose `holds (z₀,z₁)` iff a
one-free-variable end piece fails at the pinned endpoint. These are reused as the end-piece negation
mechanism (see Faithfulness note and Phase 6).

**What changes**: the split is rebuilt at the **TL-formula + bounded-`VecEA2` level**, NOT as
standalone `efSat` objects. Rabinovich's cap-free / one-sided pieces are faithfully expressible this
way (the encoding *vehicle* changes; the underlying Section-5 mathematics does not):

- below piece `ψ₀(z₀)` → the one-sided TL formula `α_m ∧ buildLeft(x_{m-1}..x₀, β₀)`
  (`ExistsForallNF.lean:310`; Since/past, terminal `H(β₀)`, constrains only `≤ z₀` — **no after-cap**).
- above piece `ψ₁(z₁)` → `α_k ∧ buildRight(x_{k+1}..x_n, β_{n+1})` (`ExistsForallNF.lean:297`;
  Until/future, terminal `G(β_{n+1})`, constrains only `≥ z₁` — **no before-cap**).
- middle `φ(z₀,z₁)` → a **bounded `BracketFormula`/`VecEA2`** on `(z₀,z₁)` (cap-free *by construction*;
  `BracketFormula.holds`/`VecEA2.holds` carry no exterior universal caps — `VecEAFormula.lean:166,262`),
  negated directly by the legacy `VVecEA2.negFix_iff` engine (`EANegationFix/VecEANegFix.lean:177`),
  NOT via `efSat`/`EndpointPinnedCapTrivial`.

The one genuinely-new obligation is a **TL-level decomposition lemma** (~200-400 lines; a Prop 4.2
re-derivation at the TL level) that absorbs `efSat`'s two mandatory caps into `buildLeft`'s `H(β₀)`
and `buildRight`'s `G(β_{n+1})` — the caps are not dropped, they find a faithful home in the
one-sided TL terminal operators. `¬ψ₀`, `¬ψ₁` then realize as endpoint `TemporalPred`s (Phase-1
clauses / thin TL-generalizations), `¬φ` via `VVecEA2.negFix_iff`, combined by `VVecEA2.disj`
(`VecEAFormula.lean:282,286`). The **output contract** of `prop42_efSat_negation_general` is
unchanged from v1/the verdict; only the internal construction changes.

Definition of done (unchanged from v1): `lake build` EXIT 0 at the existing **1769-job** baseline
throughout; no new axiom/`sorry` on `completeness_discrete`'s trace
(`[propext, sorryAx, Classical.choice, Lean.ofReduceBool, Lean.trustCompiler, Quot.sound]` — the
`sorryAx` is the pre-existing `KampPrior.lean:562` sorry, NOT to be added to); no `sorry` / vacuous
placeholder / `Prop43Structural.lean` hole; every deliverable in the off-path
`Prop42NegationGeneral.lean`; Rabinovich cited by PDF page only; durable-anchor headers.

### Research Integration

This revision integrates two inputs beyond the v1 basis:

1. `01_go-reconcile-verdict.md` (task 382) — authoritative RECONCILE verdict (three-way chain split
   negated by disjunction; Lemma 5.1 already discharged via the `VecEA2`/`VVecEA2` engine). Its
   *mathematics* (Part A, PDF-page-cited) is preserved verbatim; only its *Lean-encoding proposal*
   (Part C's D1 `efSat_split` on standalone `efSat` objects) is superseded.
2. `phase-2-handoff.md` (task 383) — the machine-confirmed encoding blocker and the TL-level repair
   path. Every anchor it cites has been re-verified against source for this revision:
   `buildLeft`/`buildRight` (`ExistsForallNF.lean:310,297`), `buildLeft_spec_iff_chain` /
   `buildRight_spec_iff_chain` (`Prop35Chain.lean:146,56`), `VVecEA2.disj` / `disj_holds`
   (`VecEAFormula.lean:282,286`), `VVecEA2.negFix_iff` (`EANegationFix/VecEANegFix.lean:177`, gated on
   `HasAttainedINF`/`HasAttainedSUP`), cap-free `BracketFormula`/`VecEA2.holds`
   (`VecEAFormula.lean:166,262`).

**Correction folded in**: the v1/handoff "5th conjunct" label for the `efSat` before-cap is
inaccurate — it is the **4th** conjunct (`:107`); the after-cap is the 6th (`:110-111`). Both are
mandatory; the substance of the blocker is unaffected.

**Correction folded in (D3 seam)**: the v1 D3 phase assumed "the call site routing `pairProject`
output to `prop42_veeSat_negation`". Source verification found **no such call site exists** anywhere
in `Kamp/` — `prop42_veeSat_negation` (`Prop42ExistsForall.lean:435`) appears only in prose,
`pairProject` only in `ExistsForallLemmas.lean`, and they never co-occur; `Prop43.lean` contains
neither. The wiring phase (Phase 7) must therefore **locate the actual Phase-7 negation-case gap
afresh** rather than swap an assumed call site.

### Faithfulness to Rabinovich (per-piece PDF grounding — REQUIRED INVARIANT)

**Faithfulness invariant**: the TL-formula + bounded-`VecEA2` repair path changes only the Lean
encoding *vehicle*. The underlying mathematics MUST remain Rabinovich's Section-5 three-piece chain
split (ψ₀ below-pin / ψ₁ above-pin / φ endpoint-pinned middle) negated by the disjunction
`¬ψ₀ ∨ ¬φ ∨ ¬ψ₁`. Any step that departs from this shape is **drift** and must be flagged and
escalated (Phase 2 gate / [BLOCKED]), never silently adopted. Every non-trivial construction step
must trace to a specific line of Rabinovich's argument.

PDF: `/home/benjamin/Projects/Literature/sources/rabinovich_2014/Rabinovich_2014_Proof_of_Kamps_Theorem.pdf`
(the `.md`/`.md.bak` transcription is corrupt — **PDF pages only**).

| Repair-path piece | Rabinovich object | PDF grounding |
|-------------------|-------------------|---------------|
| Arbitrary pins `z₀=x_m`, `z₁=x_k`; contentful caps `β₀`, `β_{n+1}` | Def 3.1 `∃∀`-object | p.4 |
| Existence of the three-way split (`m<k` case): `ψ ≡ ψ₀(z₀) ∧ φ(z₀,z₁) ∧ ψ₁(z₁)` | Prop 4.2 proof, three-piece decomposition | p.7 |
| Degenerate `k=m` (`z₀=z₁`): `ψ ≡ z₀=z₁ ∧ ψ'(z₀)`, single one-free-var piece | Prop 4.2 proof, `k=m` branch | p.7 |
| below `ψ₀(z₀) = α_m ∧ buildLeft(…, β₀)`; `¬ψ₀` = negation of a one-free-var `∃∀` → TL → atomic | "first two formulas are `∃∀` with one free variable … by Prop 3.5 … their negations equivalent to atomic (hence `∃∀`) formulas" | p.7 (via Prop 3.5) |
| above `ψ₁(z₁) = α_k ∧ buildRight(…, β_{n+1})`; `¬ψ₁` symmetric | same sentence, right-endpoint mirror | p.7 (via Prop 3.5) |
| middle `φ(z₀,z₁)` endpoint-pinned cap-free; `¬φ` via `VVecEA2.negFix_iff` | Lemma 5.1 (eq. 5.1) + its proof (Lemma 5.3, Cor 5.4, INF/`K⁺`) | p.7 (statement); pp.8-11 (proof) |
| reassembly `¬ψ = ¬(ψ₀∧φ∧ψ₁) = ¬ψ₀ ∨ ¬φ ∨ ¬ψ₁` (`VVecEA2.disj`) | `¬(∧) = ∨(¬)`, trivial reassembly (no conjunction closure) | p.7 |

Phase 2 confirms these correspondences against the PDF **before** the ~200-400-line decomposition
lemma is built; if the PDF's actual decomposition differs from the lemma statement below, the plan's
shape is corrected to match the PDF and the correction recorded.

### Prior Plan Reference

Supersedes `plans/01_phase7-negation-split.md` (v1). v1's Phase 1 is retained verbatim as this
plan's Phase 1 (already committed green). v1 Phases 2-6 (standalone-`efSat` split) are discarded as
unbuildable in this encoding and replaced by Phases 2-8 here. Per `plan-compliance.md`, this is a
sanctioned plan revision, not a mid-implementation substitution.

### Roadmap Alignment

No `roadmap_flag` set; ROADMAP.md is not consulted or modified. Topic: `kamp-completeness`. This task
unblocks the parent's Phase 7 negation case, advancing the Kamp's-Theorem completeness line.

## Goals & Non-Goals

**Goals**:
- Confirm (Phase 2) the TL-level decomposition faithfully restates Rabinovich Section 5 (PDF pp.7-11)
  before any heavy proof is built.
- Build the below/above one-sided TL pieces (`α_m ∧ buildLeft`, `α_k ∧ buildRight`) and the bounded
  cap-free middle `φ` (`BracketFormula`/`VecEA2`) as constructors in the off-path file.
- Prove the TL-level decomposition lemma `efSat N env ψ ↔ belowHolds(z₀) ∧ bracketHolds(z₀,z₁) ∧
  aboveHolds(z₁)` (forward + backward, incl. `k=m` degenerate and `wlog m>k`) — the genuinely-new
  ~200-400-line piece, absorbing `efSat`'s two mandatory caps into the one-sided TL terminals.
- Assemble `prop42_efSat_negation_general` (unchanged output contract) by disjunction: `¬below`,
  `¬above` via endpoint `TemporalPred` clauses (Phase-1 clauses / thin TL-generalizations), `¬φ` via
  `VVecEA2.negFix_iff`, combined by `VVecEA2.disj`.
- Wire (Phase 7) the general engine into the parent's Phase 7 Prop 4.3 negation case, locating the
  actual gap afresh; re-attempt that case.
- Keep `lake build` EXIT 0 at 1769 jobs throughout; add zero live-path `sorry`/axiom.

**Non-Goals**:
- Do NOT resurrect the standalone-`efSat` three-way split, `splitBelow`/`splitAbove`/`splitMiddle` as
  `efSat` objects, `splitMiddle_endpointPinned`, or any route through `EndpointPinnedCapTrivial` for
  the pieces — machine-confirmed unbuildable.
- Do NOT build `conjInterleave` (Lemma 3.2(1) interleaving) or `veeConj` (Lemma 3.4 conjunction
  closure). Those belong to the separate AND / `¬∨` connective case (`Prop43.lean:151`) and are out
  of scope (verdict A6; the negation case reassembles by disjunction only).
- Do NOT re-target `augTarget`/`pairProject` to force endpoint pins (verdict cross-check 2: not
  equivalence-preserving).
- Do NOT introduce a `sorry`, a vacuous placeholder (`def X := True` etc.), a `Prop43Structural.lean`
  hole, or weaken `prop42_efSat_negation_general` back to an `EndpointPinnedCapTrivial` hypothesis
  (that reintroduces exactly the endpoint restriction this task removes).
- Do NOT put deliverables on the live import path until Phase 7 rewires.

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| The TL-level decomposition lemma statement is itself an unfaithful reinvention (drift from Rabinovich Section 5) | H | M | Phase 2 faithfulness gate reads PDF pp.7-11 and confirms the lemma statement matches Rabinovich's own chain split BEFORE the ~200-400-line proof is attempted; adopt the PDF's shape on any mismatch. Mirrors task 382 applied to v1. |
| Absorbing `efSat`'s two mandatory caps into `buildLeft`'s `H(β₀)` / `buildRight`'s `G(β_{n+1})` does not line up definitionally | H | M | The chain bridges `buildLeft_spec_iff_chain`/`buildRight_spec_iff_chain` (`Prop35Chain.lean:146,56`) already state the exact `∀ y, y < x_d` (leftmost) / `∀ y, x_d < y` (rightmost) terminal-cap semantics; the before-cap `β₀` (efSat 4th conjunct) is `buildLeft`'s `H(β₀)` terminal and the after-cap `β_{n+1}` (6th) is `buildRight`'s `G(β_{n+1})` terminal. Prove forward direction first, commit green, then backward. |
| Backward (gluing) direction harder than the `gluedChain` template suggests | H | M | Reuse `gluedChain`'s "glue along shared pins" (`ExistsForallLemmas.lean:579-688`); only THREE pieces in FIXED order (`below < x_m < middle < x_k < above`), so no interleaving enumeration is ever formed. |
| End-piece negation clause: Phase-1 `negLeftClause`/`negRightClause` are stated against `¬ efSat ![z] ψ` (1-var), which re-imports the very cap the below/above piece must avoid | M | M | Reuse Phase-1 clauses **only** where the below/above factor is literally `translateProp35` of a 1-var `∃∀` whose caps are satisfiable; otherwise introduce thin siblings `negLeftClauseTL`/`negRightClauseTL` wrapping the **raw** `Formula` `α_m ∧ buildLeft(…)` at the endpoint, proven by the identical technique (`temporal_truth_neg` + `BracketFormula.trivial_holds` + `eval_at_top`). Same Rabinovich mathematics (¬ψ₀/¬ψ₁ at the endpoint) — a faithfulness-neutral encoding choice, flagged in-phase. |
| `VVecEA2.negFix_iff` gating on `HasAttainedINF`/`HasAttainedSUP` not threaded | M | L | `prop42_efSat_negation_general` already carries `h_INF`/`h_SUP` (verdict D2 signature); thread them into the middle `¬φ` exactly as the endpoint engine does. |
| Wrong / non-existent seam for the Phase-7 negation-case wire | H | M | The v1-assumed `pairProject`→`prop42_veeSat_negation` seam does NOT exist. Phase 7 first LOCATES the actual Prop 4.3 negation-case gap (grep/`lean_references` for where the general two-free-var `∃∀` negation is currently unfilled in the parent Phase-7 territory) before editing; keep the edit minimal. |
| D3 rewire changes `completeness_discrete`'s axiom trace / job count | H | L | Phase 8 runs the axiom-trace check and confirms 1769 jobs unchanged before completion; the wire is a call into an already-proven engine, not new axioms. |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 (done), 2 | -- |
| 2 | 3 | 2 |
| 3 | 4 | 3 |
| 4 | 5 | 4 |
| 5 | 6 | 5 |
| 6 | 7 | 6 |
| 7 | 8 | 7 |

Phases 2-6 are single-file (`Prop42NegationGeneral.lean`), sequenced to avoid same-file territory
conflicts; Phase 7 touches the parent Phase-7 seam file. Each phase ends on a green commit
(commit-per-green-substep mandate).

### Phase 1: D2 residual — one-free-var end-piece negation as a `VVecEA2` endpoint clause [COMPLETED]

**Landed green, sorry-free, off-path, committed.** Deliverables in
`Theories/Bimodal/Metalogic/WeakCanonical/Kamp/Prop42NegationGeneral.lean`:

- `negLeftClause` (`:69`) / `negLeftClause_holds` (`:80`): a single-disjunct `VVecEA2` placing
  `Formula.neg (translateProp35 atomMap h_surj ψ)` at the **left** endpoint (trivial right endpoint +
  bracket); `holds (z₀,z₁) ↔ ¬ efSat N ![z₀] ψ`.
- `negRightClause` (`:104`) / `negRightClause_holds` (`:115`): symmetric, right endpoint.

Built directly from `TemporalPred = ⟨Formula⟩` + `temporal_truth_neg` + `translateProp35_correct`;
no signature-atom/surjectivity routing needed (the verdict's flagged residual risk was overstated).
Reused by Phase 6 as the end-piece negation mechanism (verbatim or as the template for
`negLeftClauseTL`/`negRightClauseTL` — see Phase 6). **Do not modify** except to append per-piece
PDF-grounding to the module docstring (Phase 3).

**Verification** (already met): `lake build` EXIT 0 at 1769 jobs; `git grep -n sorry` on the file is
empty; `completeness_discrete` trace unchanged.

---

### Phase 2: Faithfulness gate — confirm the TL-level decomposition restates Rabinovich Section 5 [COMPLETED]

**Goal**: Before any heavy proof, confirm the planned TL-level decomposition lemma is a *faithful*
restatement of Rabinovich's own Section-5 chain split (PDF pp.7-11), not a heavier or
differently-shaped reinvention. This is task 382's discipline applied to *this* plan's construction.

**Tasks**:
- [ ] Read Rabinovich PDF pp.7-11 (Prop 4.2 proof, three-way split, `k=m` branch; Lemma 5.1 statement
  eq. 5.1 and proof Lemma 5.3 / Cor 5.4 / INF machinery). PDF at the path above; PDF pages only.
- [ ] Confirm, piece by piece against the "Faithfulness to Rabinovich" table, that:
  (a) the below piece `α_m ∧ buildLeft(…, β₀)` is Rabinovich's below one-free-var `∃∀` `ψ₀` (Since
  chain with before-cap `β₀`, free var at the right end `x_m`), negated via Prop 3.5;
  (b) the above piece `α_k ∧ buildRight(…, β_{n+1})` is his above one-free-var `∃∀` `ψ₁`;
  (c) the bounded cap-free middle `φ(z₀,z₁)` is his Lemma 5.1 endpoint-pinned object (eq. 5.1);
  (d) the reassembly is `¬ψ₀ ∨ ¬φ ∨ ¬ψ₁` (disjunction; no conjunction closure).
- [ ] Confirm the decomposition-lemma statement `efSat ψ ↔ (α_m ∧ leftPart)(z₀) ∧ bracket(z₀,z₁) ∧
  (α_k ∧ rightPart)(z₁)` matches Rabinovich's `ψ ≡ ψ₀ ∧ φ ∧ ψ₁`, and that absorbing `efSat`'s
  before-cap (`:107`) into `buildLeft`'s `H(β₀)` terminal and after-cap (`:110-111`) into
  `buildRight`'s `G(β_{n+1})` terminal is content-preserving. If the PDF's decomposition differs,
  record the corrected shape and update Phases 3-6 accordingly (or escalate [BLOCKED] if the
  difference is structural).
- [ ] Write a short cross-check note to
  `specs/383_.../reports/02_rabinovich-faithfulness-crosscheck.md` (per-piece PDF-page citations;
  drift findings if any). No `Theories/` edit in this phase.

**Timing**: 1-2 hours

**Depends on**: none (may run alongside Phase 1's landed state)

**Files to modify**:
- `specs/383_construct_the_phase_7_negationcase_unblock_per_adjudication_verdict/reports/02_rabinovich-faithfulness-crosscheck.md` (new; spec artifact, not a deliverable).

**Verification**:
- Cross-check note exists, cites Rabinovich by PDF page only, and either confirms faithfulness or
  records the corrected decomposition shape.
- `lake build` unaffected (no `Theories/` change).
- Green commit: `task 383 phase 2: Rabinovich faithfulness cross-check`.

---

### Phase 3: TL-level piece constructors — below, above, and the bounded cap-free middle [COMPLETED]

**Goal**: Define the three Section-5 pieces at the TL/bounded-`VecEA2` level (no `efSat` objects) in
the off-path file, plus the per-piece PDF-grounding docstrings.

**Tasks**:
- [ ] `belowFormula (ψ : ExistsForallFormula sig F 2) : Formula` — `α_m ∧ buildLeft(x_{m-1}..x₀, β₀)`
  (`ExistsForallNF.lean:310`; Since/past, terminal `H(β₀)`), where `m = ψ.pin 0`. Constrains only
  `≤ z₀`.
- [ ] `aboveFormula (ψ : ExistsForallFormula sig F 2) : Formula` — `α_k ∧ buildRight(x_{k+1}..x_n,
  β_{n+1})` (`ExistsForallNF.lean:297`; Until/future, terminal `G(β_{n+1})`), where `k = ψ.pin 1`.
  Constrains only `≥ z₁`.
- [ ] `middleBracket (ψ : ExistsForallFormula sig F 2) : VVecEA2` (or `VecEA2` lifted to `VVecEA2`) —
  the bounded, cap-free middle on `(z₀,z₁)`: endpoints `α_m`, `α_k`; interior point types
  `α_{m+1}..α_{k-1}`; interval types `β_{m+1}..β_k`. Cap-free by construction
  (`BracketFormula.holds`/`VecEA2.holds`, `VecEAFormula.lean:166,262`).
- [ ] Add the per-piece PDF-grounding to the module docstring (the Faithfulness table's rows, PDF
  pages only, durable anchors, no task numbers).
- [ ] Build the module by name; confirm zero sorries.

**Timing**: 2-3 hours

**Depends on**: 2

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/Prop42NegationGeneral.lean` — three constructors +
  docstring grounding.

**Verification**:
- `lake build Bimodal.Metalogic.WeakCanonical.Kamp.Prop42NegationGeneral` EXIT 0, no `sorry`.
- Constructors typecheck; `middleBracket` uses no exterior-cap field.
- Full `lake build` EXIT 0 at 1769 jobs (file off-path).
- Green commit: `task 383 phase 3: TL-level below/above/middle constructors`.

---

### Phase 4: Decomposition lemma — forward direction (`efSat ψ → three-piece`) [COMPLETED]

**Goal**: Prove the forward half of the TL-level decomposition — from `efSat` of the general
two-free-var object, derive the three TL/bracket factors — absorbing `efSat`'s two mandatory caps
into the one-sided TL terminals via the chain bridges.

**Tasks**:
- [ ] State `efSat_decompose_tl (N) (env : Fin 2 → N.carrier) (ψ : ExistsForallFormula sig F 2)
  (hpin : ψ.pin 0 ≤ ψ.pin 1) : efSat N env ψ ↔ temporal_truth N atomMap (env 0) (belowFormula ψ) ∧
  (middleBracket ψ).holds N atomMap (env 0) (env 1) ∧ temporal_truth N atomMap (env 1)
  (aboveFormula ψ)` (exact atomMap/param shape settled in Phase 3; keep the output contract of
  `prop42_efSat_negation_general` in mind).
- [ ] Prove the forward direction: decompose the single witness chain at the pinned points
  `x_m = z₀`, `x_k = z₁`; route the below sub-chain (incl. the `∀ y < x₀` before-cap `β₀`, efSat 4th
  conjunct) through `buildLeft_spec_iff_chain` (`Prop35Chain.lean:146`), the above sub-chain (incl.
  the `∀ y > x_last` after-cap `β_{n+1}`, 6th conjunct) through `buildRight_spec_iff_chain` (`:56`),
  and the interior through `middleBracket`.
- [ ] Build the module by name; confirm zero sorries for the forward direction (backward may remain a
  clearly-marked open `↔` half only if split across commits — but no `sorry`: state forward as its
  own `→` lemma first, commit, then assemble the `↔` in Phase 5).
- [ ] Prefer a standalone `efSat_decompose_tl_forward : efSat … → …` lemma for the green commit, so
  the phase lands sorry-free.

**Timing**: 3-4 hours

**Depends on**: 3

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/Prop42NegationGeneral.lean` —
  `efSat_decompose_tl_forward`.

**Verification**:
- `lake build Bimodal.…Kamp.Prop42NegationGeneral` EXIT 0, no `sorry`.
- Forward lemma typechecks; caps demonstrably routed into `H(β₀)`/`G(β_{n+1})` terminals.
- Full `lake build` EXIT 0 at 1769 jobs.
- Green commit: `task 383 phase 4: efSat TL decomposition (forward)`.

---

### Phase 5: Decomposition lemma — backward (gluing), degenerate `k=m`, `wlog m>k` [COMPLETED]

**Deviation (altered)**: The `k=m` degenerate and `wlog m>k` sub-cases are NOT built as standalone
mirrored decompositions. Instead, the `env 0 < env 1` hypothesis (threaded per the Phase-4 handoff's
explicit guidance) makes both vacuous: under `z₀ < z₁`, a satisfying witness pins `z₀ = x_m`,
`z₁ = x_k`, forcing `m < k` (`efSat_pin_lt`), so `m ≥ k` ⇒ `¬efSat` and the negation is trivially
realized in Phase 6. This is the `z₀<z₁`-threaded form of Rabinovich's "w.l.o.g. `m<k`" + `k=m`
branches (PDF p.7), faithful and sanctioned by the handoff. The full `↔` (`efSat_decompose_tl`) is
built for the `m<k` case only; the general-pin negation is completed in Phase 6.

**Goal**: Complete the decomposition `↔` by the backward (gluing) direction, plus the degenerate and
symmetry branches, yielding the full `efSat_decompose_tl`.

**Tasks**:
- [ ] Prove the backward direction: glue the below TL past-chain, the bounded middle, and the above
  TL future-chain along their shared pinned endpoints `x_m = z₀`, `x_k = z₁`, reusing `gluedChain` /
  `gluedChain_strictMono/_between/_pointType/_before/_after` (`ExistsForallLemmas.lean:579-688`);
  FIXED three-piece order, no interleaving enumeration.
- [ ] Handle the degenerate `ψ.pin 0 = ψ.pin 1` (`k=m`) case: reduces to a single one-free-variable
  object with no middle bracket (Rabinovich `k=m` branch, PDF p.7).
- [ ] Add a `wlog`/symmetry wrapper normalizing `ψ.pin 0 > ψ.pin 1` to the `≤` case.
- [ ] Assemble the full `efSat_decompose_tl : efSat N env ψ ↔ belowHolds ∧ bracketHolds ∧ aboveHolds`
  (both directions, all branches).
- [ ] Build the module by name; confirm zero sorries.

**Timing**: 3-4 hours

**Depends on**: 4

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/Prop42NegationGeneral.lean` — backward direction +
  degenerate/symmetry + full `efSat_decompose_tl`.

**Verification**:
- `lake build Bimodal.…Kamp.Prop42NegationGeneral` EXIT 0, no `sorry` (both `↔` directions, `k=m`,
  and `wlog` branches closed).
- Full `lake build` EXIT 0 at 1769 jobs.
- Green commits per sub-step: `task 383 phase 5.1: TL decomposition backward (gluing)`,
  `task 383 phase 5.2: k=m degenerate + wlog symmetry + full iff`.

---

### Phase 6: `prop42_efSat_negation_general` — disjunctive negation of the general object [COMPLETED]

**Goal**: Assemble the arbitrary-pin single-object negation from `efSat_decompose_tl`, reassembling
`¬ψ₀ ∨ ¬φ ∨ ¬ψ₁` by `VVecEA2.disj`. Output contract unchanged from the verdict D2 / v1.

**Tasks**:
- [ ] Via `efSat_decompose_tl`: `¬efSat ψ ↔ ¬belowHolds(z₀) ∨ ¬bracketHolds(z₀,z₁) ∨ ¬aboveHolds(z₁)`.
- [ ] `¬below`, `¬above` → endpoint `TemporalPred` clauses. **Primary**: reuse Phase-1
  `negLeftClause`/`negRightClause` where the below/above factor is `translateProp35` of a 1-var `∃∀`
  with satisfiable caps. **If** the factor is the raw TL formula `α_m ∧ buildLeft(…)` /
  `α_k ∧ buildRight(…)` (to avoid re-importing `efSat` caps — the likely case per the blocker):
  introduce thin siblings `negLeftClauseTL`/`negRightClauseTL` wrapping the raw `Formula` at the
  endpoint, proved by the SAME technique as Phase 1 (`temporal_truth_neg` +
  `BracketFormula.trivial_holds` + `TemporalPred.eval_at_top`). Flag which path is taken as a
  faithfulness-neutral encoding choice (same `¬ψ₀`/`¬ψ₁`-at-endpoint mathematics).
- [ ] `¬φ` via `VVecEA2.negFix_iff` (`EANegationFix/VecEANegFix.lean:177`) on `middleBracket ψ`,
  threading `h_INF`/`h_SUP` and the `z₀ < z₁` hypothesis; `(middleBracket ψ).negFix.holds ↔ ¬holds`.
- [ ] Combine the three witnesses with `VVecEA2.disj` / `disj_holds` (`VecEAFormula.lean:282,286`).
- [ ] State and prove `prop42_efSat_negation_general (N) (atomMap) (h_surj) (h_INF) (h_SUP)
  (ψ : ExistsForallFormula sig F 2) : ∃ v' : VVecEA2, ∀ env, env 0 < env 1 →
  (v'.holds N atomMap (env 0) (env 1) ↔ ¬ efSat N env ψ)` — the exact verdict D2 output shape (no
  `EndpointPinnedCapTrivial` hypothesis on `ψ`; arbitrary pins).
- [ ] Build the module by name; confirm zero sorries.

**Timing**: 2-3 hours

**Depends on**: 5

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/Prop42NegationGeneral.lean` —
  `negLeftClauseTL`/`negRightClauseTL` (if needed) + `prop42_efSat_negation_general`.

**Verification**:
- `lake build Bimodal.…Kamp.Prop42NegationGeneral` EXIT 0, no `sorry`.
- `prop42_efSat_negation_general` typechecks with arbitrary pins (no `EndpointPinnedCapTrivial`).
- Full `lake build` EXIT 0 at 1769 jobs.
- Green commit: `task 383 phase 6: prop42_efSat_negation_general via TL split + disjunction`.

---

### Phase 7: Wire into parent Phase 7 and re-attempt the Prop 4.3 negation case [NOT STARTED]

**Goal**: Bring `Prop42NegationGeneral` onto the live path only here, at the parent's Phase-7 Prop 4.3
negation case, and re-attempt that case on the general engine.

**Tasks**:
- [ ] **Locate the actual seam afresh** (the v1-assumed `pairProject`→`prop42_veeSat_negation` call
  site does NOT exist). Use `lean_references`/grep to find where the parent Phase-7 territory
  currently leaves the general two-free-var `∃∀` negation unfilled (candidate: the `∃∀`/atom negation
  sub-case of Prop 4.3, or the point where `pairProject` output must be negated). Record the exact
  declaration and file:line before editing.
- [ ] Add the `Prop42NegationGeneral` import at the seam (its first live-path use) and route the
  per-object negation through `prop42_efSat_negation_general`; per-object negations combine by
  disjunction (`VVecEA2.disj` / `veeSat_append`) — no conjunction closure (verdict A6).
- [ ] Re-attempt the negation case; confirm it closes with no `sorry` / placeholder /
  `Prop43Structural.lean` hole.
- [ ] Build the affected live-path target(s).

**Timing**: 2-3 hours

**Depends on**: 6

**Files to modify**:
- The parent Phase-7 negation-case file (seam located at implementation time) — minimal call-site
  wire + one import.
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/Prop42NegationGeneral.lean` — only if a minor
  signature adjustment is needed for the seam.

**Verification**:
- The negation case closes with no `sorry`, no vacuous placeholder, no `Prop43Structural.lean` hole.
- `lake build` EXIT 0.
- Green commit: `task 383 phase 7: wire Phase 7 negation case onto general engine`.

---

### Phase 8: Full verification — build, axiom trace, faithfulness + sorry/placeholder audit [NOT STARTED]

**Goal**: Confirm the whole-project invariants and the faithfulness invariant after the rewire.

**Tasks**:
- [ ] `lake build` EXIT 0 at **1769 jobs** (compare to baseline).
- [ ] Axiom-trace check on `completeness_discrete` (`lean_verify` / `#print axioms`): trace remains
  `[propext, sorryAx, Classical.choice, Lean.ofReduceBool, Lean.trustCompiler, Quot.sound]` — no NEW
  axiom; the sole `sorryAx` is still the pre-existing `KampPrior.lean:562` sorry (NOT added to by
  this task).
- [ ] Repo-wide audit: no new `sorry`, no vacuous placeholder, no `Prop43Structural.lean` hole on the
  live path.
- [ ] Faithfulness audit: every non-trivial construction step in `Prop42NegationGeneral.lean` carries
  a PDF-page-cited Rabinovich anchor (below/above → Prop 3.5, PDF p.7; middle → Lemma 5.1, PDF
  pp.7-11; disjunction → PDF p.7); the final construction is `¬ψ₀ ∨ ¬φ ∨ ¬ψ₁`, no drift into
  conjunction closure / interleaving. All headers use durable anchors, no task-number references
  inside `Theories/`.

**Timing**: 1-2 hours

**Depends on**: 7

**Files to modify**:
- None (verification only; fix-forward into prior phases' files if an invariant fails).

**Verification**:
- `lake build` EXIT 0, 1769 jobs.
- `completeness_discrete` axiom trace unchanged (no new axiom / no added `sorryAx`).
- `git grep -n sorry` shows no new live-path sorries.
- Faithfulness invariant confirmed (disjunctive three-piece split, per-piece PDF grounding present).
- Final commit: `task 383: complete implementation`.

## Testing & Validation

- [ ] Each phase: `lake build` (and `lake build <module>` while off-path) EXIT 0, zero new sorries.
- [ ] Phase 2 gate confirms the TL-level decomposition faithfully restates Rabinovich Section 5
  (PDF pp.7-11) before the heavy lemma is built.
- [ ] `efSat_decompose_tl` proves both `↔` directions incl. `k=m` degenerate and `wlog m>k` symmetry;
  `efSat`'s two mandatory caps demonstrably absorbed into `buildLeft`/`buildRight` terminals.
- [ ] `prop42_efSat_negation_general` typechecks with arbitrary pins (no `EndpointPinnedCapTrivial`
  hypothesis), output contract identical to the verdict D2 shape.
- [ ] Phase 7 negation case closes on the new engine, reassembled by disjunction only.
- [ ] `completeness_discrete` axiom trace: no new axiom / added `sorryAx`; `lake build` at 1769 jobs.
- [ ] No `Prop43Structural.lean` hole; no vacuous placeholders; Rabinovich cited by PDF page only;
  every construction step traces to a specific PDF line.

## Artifacts & Outputs

- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/Prop42NegationGeneral.lean` (extended in place;
  off-path until Phase 7): Phase-1 `negLeftClause`/`negRightClause` (landed) + `belowFormula`,
  `aboveFormula`, `middleBracket`, `efSat_decompose_tl` (forward + backward), optional
  `negLeftClauseTL`/`negRightClauseTL`, `prop42_efSat_negation_general`.
- Edited parent Phase-7 negation-case file (Phase 7 call-site wire + one import; seam located afresh).
- `specs/383_.../reports/02_rabinovich-faithfulness-crosscheck.md` (Phase 2 gate output).
- `specs/383_.../plans/02_phase7-negation-tl-level.md` (this plan).
- `specs/383_.../summaries/02_phase7-negation-tl-level-summary.md` (on completion).

## Rollback/Contingency

- The module stays off the live import path through Phase 6, so partial progress is inert: reverting
  the Phase-7 seam edit fully restores prior `lake build` behavior. Snapshot via
  `bash .claude/scripts/git-snapshot.sh` before the Phase-7 rewire.
- If the Phase 2 gate finds the PDF's actual decomposition differs structurally from the planned
  lemma, adopt the PDF's shape (update Phases 3-6) or, if it cannot be reconciled with the repair
  path's engines, escalate [BLOCKED] with the specific mismatch — do NOT force an
  encoding-convenient but unfaithful lemma.
- If the decomposition lemma (Phase 4/5) or the middle negation (Phase 6) proves genuinely
  intractable beyond the cited assets, do NOT force a construction or add a placeholder: escalate
  task 383 [BLOCKED] citing the specific unresolved typecheck/proof obstruction, preserving the green
  sub-steps already committed.
- Each green sub-step is committed as it lands (commit-per-green-substep mandate); any failure resumes
  from the last green commit via `/implement 383`.
