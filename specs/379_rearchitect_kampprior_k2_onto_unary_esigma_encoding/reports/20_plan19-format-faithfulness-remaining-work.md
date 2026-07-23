# Research Report: Plan 19 Format Audit, Rabinovich Faithfulness Check, and Remaining-Work Inventory

- **Date**: 2026-07-23
- **Task**: 379 - rearchitect_kampprior_k2_onto_unary_esigma_encoding
- **Session**: sess_1784825892_74a2ca
- **Report type**: research (lean-research-agent)
- **Scope**: audit `plans/19_infinite-esigma-alphabet-optionA.md` against the plan-format rules;
  verify each plan-19 construction against Rabinovich (PDF pages 4-6, read directly — companion
  `.md` is corrupt); inventory precisely what remains to retire the last live spine sorry and
  what a revised plan (v20) must contain.
- **Method note**: Rabinovich cited BY PDF PAGE ONLY. Code anchored by DECLARATION NAME. All
  load-bearing claims machine-checked against the working tree (grep / file reads), not trusted
  from older artifacts whose line numbers have rotted.

---

## Executive Summary

Plan 19 is **architecturally sound and faithful to Rabinovich** — Option A is literally Def 4.1's
infinite E[Σ], no novel mathematics is introduced, and the machine-checked Phase-1 GATE returned
**GO**. The problems the reviser must fix are **format/freshness defects, not substance**: the
plan-level Status is stale (`[NOT STARTED]` while Phase 1 is `[COMPLETED]`), the H1 title is a
run-on that embeds a rotted line number (`KampPrior.lean:562`) in violation of the plan's own
binding constraint, Phase-1 has no completion timestamp, `plan_metadata` is internally
inconsistent, and Phase 5's `Depends on` cites phantom phase numbers. The structural content
(Phases 2-5) needs no re-architecture — A is adjudicated, B is machine-refuted, finite-F is
machine-refuted, and the GATE is green. **v20 is a format-compliance + state-refresh revision that
carries Phases 2-5 forward, with one post-GATE risk refinement.**

The live sorry inventory is **exactly the three permitted sorries** — `KampPrior.lean` k+2 arm of
`nf_nvar_exist_all_depths` (the DoD target) plus `EANegation.lean:1090` and `:1249`. No extra
sorry has crept in. Only Phase 1 is landed; Phases 2, 3, 4a/4b/4c, 5 are all verified NOT STARTED.

---

## Section 1 — Plan-Format Audit

Reference: `.claude/rules/plan-format-enforcement.md`, `.claude/context/formats/plan-format.md`,
`.claude/rules/artifact-formats.md`.

### 1.1 What is PRESENT and well-formed (no action needed)

- All eight required **metadata fields** are present: Task, Status, Effort, Dependencies,
  Research Inputs, Artifacts, Standards, Type (lines 3-10).
- All seven required **structural sections** are present and in order: Overview, Goals &
  Non-Goals, Risks & Mitigations, Implementation Phases, Testing & Validation, Artifacts &
  Outputs, Rollback/Contingency.
- A **Dependency Analysis wave table** exists immediately before the first phase (lines 246-253),
  with Wave / Phases / Blocked-by columns.
- **Phase heading status markers** use valid vocabulary: Phase 1 `[COMPLETED]`, Phases 2/3/4/5
  `[NOT STARTED]`. No emojis.
- Each phase carries `Goal`, `Tasks` (checkbox list), `Timing`, `Depends on`.

### 1.2 DEFECTS the reviser must fix (keyed to the format rules)

| # | Defect | Rule violated | Fix |
|---|--------|---------------|-----|
| D1 | **Plan-level `Status: [NOT STARTED]`** (line 4) while Phase 1 heading is `[COMPLETED]` and the phase-1 return-meta records `phases_completed: 1, gate_verdict: GO`. The plan-level status is factually wrong. | plan-format.md "Status Marker Requirements"; status must track reality. | Set plan-level Status to `[IMPLEMENTING]` (valid plan-level marker; work is underway with 1/5 phases done). Add a `Started:` line. |
| D2 | **H1 title is a ~90-word run-on that embeds a rotted line number** `KampPrior.lean:562` (line 1). The plan's OWN binding constraint (lines 204-208) says "anchor by DECLARATION NAME, never line number"; `:562` is exactly the rotted pointer it warns about. | plan-format.md "keep language concise"; the plan's own no-line-number binding; `no-task-references-in-deliverables.md` spirit (durable anchors). | Rewrite the title to be concise and reference `nf_nvar_exist_all_depths` (the `| _k+2` arm) by declaration name, no `:562`. |
| D3 | **Phase 1 `[COMPLETED]` has no `Completed:` ISO8601 timestamp line.** | plan-format.md Implementation Phases format: "Started/Completed/... timestamp lines when status changes." | Add `Completed: 2026-07-…` (date of commit `fbe26f61c`). |
| D4 | **`plan_metadata` is internally inconsistent.** `plan_version: 14` while the file is `19_…` and the commit is "revise plan (v19)"; `dependency_waves: [[1],[2],[3],[4],[5]]` (5 waves) contradicts the human-readable wave table (6 waves, Phase 4 split 4a→{4b,4c}). The plan flags the human table as authoritative (line 30) but leaves the JSON stale. | plan-format.md "Plan Metadata Schema": `dependency_waves` is the machine-readable parallel-group source. | Reconcile: bump `plan_version`; make `dependency_waves` match the authoritative 6-wave table (`[[1],[2],[3],[4],[4],[5]]`-style with 4a/4b/4c); add report 20 to `reports_integrated`. |
| D5 | **Phase 5 `Depends on: 4b, 4c, 13a, 13b, 13c`** (line 487) cites `13a/13b/13c` — which are NOT phases of THIS plan; they are landed assets carried from v18 (`ZetaAtomMapReconcile.lean`, `ZetaPriorTransfer.lean`, `MonadicFormulaMap.lean`). Phantom phase numbers in a dependency field. | plan-format.md: `Depends on` lists "phase numbers this phase requires." | Change to `Depends on: 4b, 4c` and move the landed-asset dependency into prose (it is already in the task bullets). |
| D6 (minor) | Sub-phases 4a/4b/4c are `####` (H4) headings, not `###` (H3). | plan-format.md: "each phase at level `###`." | Acceptable extension for sub-phases, but either promote to `###` or add a one-line note that `####` denotes sub-phases of Phase 4. |
| D7 (minor) | The wave table has an extra **State** column (line 246) beyond the standard Wave/Phases/Blocked-by. | plan-format.md wave-table format (3 columns). | Harmless; may drop the State column or keep as an annotation. |

**Verdict**: the plan is format-compliant in skeleton (all required fields/sections present) but
has **real freshness defects D1-D5** that make it misrepresent its own state. D1 (stale status)
and D2 (rotted line number in the title) are the load-bearing ones.

---

## Section 2 — Rabinovich Faithfulness Audit

Every plan-19 construction was checked against the primary PDF (pages 4-6 read directly this
dispatch). Verdicts: **FAITHFUL** (literal paper content), **EXTENSION** (faithful-by-content Lean
formalization device not a literal paper object), **NOVEL** (off-paper — a prohibition violation).

### 2.1 What the PDF actually says (ground truth, this dispatch)

- **Def 3.1 (p.4)**: an ∃∀-formula `ψ(z₀,…,z_m) := ∃xₙ…∃x₁∃x₀ [ordering x_n>…>x_0] ∧ ⋀_{j=0}^{n}
  αⱼ(xⱼ) ∧ ⋀_{j=1}^{n} (∀y)^{<xⱼ}_{>x_{j-1}} βⱼ(y) ∧ (∀y)_{>xₙ} β_{n+1}(y) ∧ (∀y)^{<x₀} β₀(y)`,
  with **all αⱼ, βⱼ quantifier-free formulas with ONE variable**, finitely many (j=0..n). Confirms
  the unary point/interval-atom cap and that a fixed ∃∀-formula mentions **finitely many** atoms.
- **Lemma 3.2(2) (p.4)**: "Every ∃∀-formula is equivalent to a conjunction of ∃∀-formulas with **at
  most two free variables**." This is the arity ceiling — it exists precisely so joint types over
  many points are never needed.
- **Prop 3.5 (p.5)**: every ∨∃∀-formula with one free variable ≡ a TL(Until,Since) formula, via the
  **explicit finite** chains `A_k ∧ (B_{k+1} Until (A_{k+1} ∧ (B_{k+2} Until …)))` and the dual
  Since chain. The disjunction/chain is finite in the n of the fixed formula.
- **Def 4.1 (p.5)**: "We denote by E[Σ] the set of unary predicate names Σ ∪ {A | A is a
  TL(Until,Since)-formula over Σ}" — an **infinite** alphabet; the canonical expansion interprets
  each A ∈ E[Σ] as `{a ∈ M | M,a ⊨ A}`.
- **p.6 collapse note**: "if A is a TL(Until,Since) formula over E[Σ] predicates, then it is
  equivalent to a TL formula over Σ, and hence to an **atomic** formula in the canonical
  expansions." This is the semantic collapse that makes infinite E[Σ] well-founded.
- **Prop 4.2 (p.6)**: "The negation of ∃∀-formulas **with at most two free variables** is
  equivalent over Dedekind complete chains to a disjunction of ∃∀-formulas." Negation closure is
  stated at the ≤2-free-variable arity, not higher.
- **Prop 4.3 (p.6)**: every FO formula ≡ a disjunction of ∃∀-formulas, by **structural induction**;
  the negation case routes through Lemma 3.2(2) (reduce to ≤2 free vars) then Prop 4.2. Composition
  is structural, **not** a Feferman-Vaught product.
- **Thm 4.4 (p.6)**: φ ≡ ⋁ᵢ φᵢ (finite, Prop 4.3), each φᵢ →Prop 3.5→ TL.

### 2.2 Construction-by-construction verdicts

| Plan-19 construction | Phase | Rabinovich anchor (PDF page) | Verdict |
|---|---|---|---|
| Re-index `sigE` fresh summand `{A // A ∈ F}` → full `Formula` (infinite E[Σ]) | 3 | **Def 4.1, p.5** — E[Σ] = Σ ∪ {A \| A a TL(U,S)-formula over Σ}, infinite | **FAITHFUL.** Literally Def 4.1; restores the paper's infinite index the finite-`F` departure had replaced. |
| Per-formula-finite atom representation (`UnaryTypeFin M = {a // a ∈ M} → Bool`); "type = finite disjunction of the mentioned atoms" | 1, 4 | **Prop 3.5, p.5** (finite chains over finitely many αⱼ/βⱼ) + **Def 3.1, p.4** (finitely many one-variable atoms per formula) | **FAITHFUL by content / EXTENSION as a device.** Rabinovich never enumerates the whole alphabet; each fixed formula mentions finitely many atoms. The partial-assignment-over-`M` encoding is a Lean formalization device faithful to that content — it is a *weaker* (more faithful) finiteness than the current whole-alphabet `Finset.univ`. |
| `partialIntervalHolds` uses `Finset.univ : Finset (UnaryTypeFin sig F M)` | 1 | Prop 3.5, p.5 | **FAITHFUL.** This `Finset.univ` ranges over functions from the **finite mentioned subtype** `{a//a∈M}` to `Bool`; its `Fintype` depends only on `M` finite, never on `Fintype (sigE sig F).preds`. It is **not** the forbidden whole-alphabet `Finset.univ : Finset (UnaryType)`. Machine-verified in `InfAlphabetProbe.lean`. |
| Remove `[fintypePreds]`/`[decEqPreds]` from `MonadicSignature`; thread finiteness per-formula | 2 | Def 4.1, p.5 (E[Σ] infinite ⇒ signature must admit infinite preds) | **FAITHFUL (structural necessity).** Not mathematics — a Lean-structural enabling change forced by Def 4.1. |
| Discharge capture DIRECTLY (readback IS an atom); remove `hCapture`/`capFn` | 5 | **p.6 collapse note** + **Thm 4.4, p.6** | **FAITHFUL.** Under infinite E[Σ], every TL readback is already an atom of the canonical expansion — exactly the collapse note. The finite-`F` `∈ F` membership the capture machinery threaded has no Thm 4.4 counterpart (report 18/`not_readbackClosed`). |
| β/γ/δ negation stack SHAPE (De Morgan trichotomy) survives | 4/5 | **Prop 4.2, p.6** (negation at ≤2 free vars) + **Prop 4.3, p.6** (structural induction) | **FAITHFUL.** The trichotomy and structural induction are the paper's negation-closure argument. |
| Retire the k≥2 residual by re-architecting onto the unary E[Σ]-atom encoding so the **arity-4** obligation never arises | 5 (DoD) | **Def 3.1 p.4** (unary) + **Lemma 3.2(2) p.4** (≤2 free vars) + **Prop 4.2 p.6** (≤2) + **Prop 4.3 p.6** (structural, not FV) | **FAITHFUL.** The paper caps arity everywhere the method touches; there is NO arity-4 joint type in the source. Retiring the residual by removing the arity-4 obligation is obeying the paper, not inventing. |

### 2.3 Prohibition scan (HARD PROHIBITIONS)

Checked plan 19 for the four prohibited moves. **No violations found:**

- **No Feferman-Vaught / novel mathematics.** Confirmed: Prop 4.3's composition is structural
  induction folding processed depth into the signature as a unary E[Σ]-atom (p.6), not a product
  theorem. The plan's Non-Goals (lines 184-188) explicitly forbid FV and any arity-4 engine.
- **No `chain_split`.** Non-Goals line 188 forbids it; confirmed machine-refuted at all zones per
  the KampPrior in-file adjudication (K₄ complete-graph order atoms, no path cut).
- **No touching `EANegation.lean:1090/:1249`.** Non-Goals line 189 preserves them as UNFIXABLE.
- **No arity-4 object introduced.** The whole point of Phase 5 is to make the arity-4 obligation
  *never arise* by faithful unary re-encoding. The PDF (Def 3.1, Lemma 3.2(2), Prop 4.2) confirms
  the arity cap is a faithfulness boundary, not a defect — matching the KampPrior in-file
  re-adjudication (declaration head at `nf_nvar_exist_all_depths`).

**Faithfulness verdict: PASS.** Plan 19 introduces no novel mathematics. Option A is Def 4.1;
the per-formula-finite representation is Prop 3.5 + Def 3.1; the direct capture discharge is the
p.6 collapse note; the negation shape is Prop 4.2/4.3. This corroborates the H4-verified findings
of reports 18 and 19 by independent PDF read.

---

## Section 3 — Current Implementation State

### 3.1 Live sorry inventory (machine-checked this dispatch)

Bare `sorry` on the completeness-relevant track — **exactly the three permitted**, no more:

| File · declaration | Site | Status |
|---|---|---|
| `KampPrior.lean` · `nf_nvar_exist_all_depths`, the `\| _k + 2` arm | (currently line 562; anchor by name) | **THE DoD TARGET.** The k=0/k=1 arms above it are discharged (`kampPrior_case1_arm_k0`, `kampPrior_case1_arm_k1`, lines 505-506). Only the k≥2 arm sorries. Documented as UNOWNED pending the Def 4.1 re-architecture. |
| `EANegation.lean:1090` | B.1 BracketFormula case | PERMITTED (UNFIXABLE, zero external consumers). Do not touch. |
| `EANegation.lean:1249` | n≥1 backward direction | PERMITTED (UNFIXABLE). Do not touch. |

`#print axioms completeness_discrete` (from the phase-1 return-meta, byte-identical to baseline):
`[propext, sorryAx, Classical.choice, Lean.ofReduceBool, Lean.trustCompiler, Quot.sound]`. The
`sorryAx` is sourced **solely** from the `KampPrior` k+2 residual.

**Stale in-file audit block (finding for Phase 5):** `BXCanonical/Completeness.lean` (the axiom-audit
block, ~lines 355-372) still describes the residual as "KampPrior.lean:212 — sole live proof-term
sorry: `:361` n=1 arm, `:364` n+2 arm" and lists both an n=1 and an n+2 arm as sorry. This is
**doubly rotted**: (a) the line numbers (`:212/:361/:364`) no longer resolve, and (b) the n=1 arm is
now DISCHARGED (`kampPrior_case1_arm_k1`), so only the k+2 arm remains. Phase 5's "update the in-file
axiom-audit block" task must correct this to name `nf_nvar_exist_all_depths` (the `| _k+2` arm) as
the sole residual, by declaration name.

### 3.2 Landed vs remaining plan-19 phases (verified against the working tree)

| Phase | State | Evidence |
|---|---|---|
| **Phase 1** (de-risking GATE) | **[COMPLETED] — GATE GO** | `Kamp/InfAlphabetProbe.lean` present, off-path (grep: not imported anywhere), `#print axioms gate_translateProp35 = [propext, Classical.choice, Quot.sound]`. Commit `fbe26f61c`. |
| **Phase 2** (`Fintype preds` removal) | **NOT STARTED** | `WeakCanonical/MonadicFO.lean:43` still declares `[fintypePreds : Fintype preds]`; `:46` still `attribute [instance]`. |
| **Phase 3** (`sigE` infinite re-index) | **NOT STARTED** | `ESigmaExpansion.lean:64` still `preds := sig.preds ⊕ {A // A ∈ F}`; `esigmaPred` (`:69`) still takes `hA : A ∈ F`. `ZetaReadbackClosure.lean` and `ZetaEngineClosure.lean` still present (Phase 3 would delete them). `OptionBLocalityProbe.lean` present (preserved, correct). |
| **Phase 4a/4b/4c** (enumeration re-encode) | **NOT STARTED** | depends on Phases 2-3; targets (`IntervalType.lean`, `LiftPair.lean`, `Prop43Translate.lean`, `ConjInterleave.lean`) untouched. |
| **Phase 5** (ζ re-wire + residual retirement) | **NOT STARTED** | the k+2 `sorry` is present and untouched, as required (deleted LAST). |

### 3.3 What the GATE GO means for the downstream phases

- **It retires the plan's single highest risk** (Risks table row 1, "Phase 1 gate fails"). The
  machine-checked GO on `typeEqFiniteDisjunction` + `gate_translateProp35` proves the per-formula-
  finite "type = finite disjunction of atoms" equivalence closes **without a whole-alphabet
  `Finset.univ`**, which was the one obstruction that could have made all of Option A intractable
  and forced escalation. Phases 2-5 are now correctly authorized.
- **It does NOT change the downstream phase STRUCTURE.** The GATE validated the *representation*
  that Phases 4a/4b will promote into `IntervalType`/`LiftPair`; the phase sequence and sizing are
  unchanged.
- **CAVEAT the reviser must carry (post-GATE risk refinement):** the probe exercised the
  representation only on the **point-type clause** of a **trivial** `ξConcrete` (`n = 0`, interval
  clauses = `∅`). It did NOT exercise (i) non-empty interval clauses, (ii) the **tuple** skeleton
  disjunction `Finset.univ : Finset (Fin (K+1) → UnaryType)` that `LiftPair.charType`/`skelDisjunct`
  use, or (iii) the `liftPair_forward`/`liftPair_backward` equivalence. So Phase 4b (LiftPair, the
  Report-19 A3 "hardest single obligation") is **only partially de-risked** by the GATE. The plan's
  existing 4b "split by direction (fwd/bwd)" contingency (lines 416-417) should be kept prominent,
  and v20 should note that 4b — not the GATE — is where the residual representation risk now lives.

---

## Section 4 — Remaining-Work Inventory for Plan Revision (v20)

**Framing for the reviser:** this is a **format-compliance + state-refresh** revision over a
plan whose architecture and faithfulness are already adjudicated and machine-verified. Do **NOT**
re-litigate: Option A is chosen (report 19), Option B is machine-refuted (`capFn_forces_local`),
finite-F is machine-refuted (`not_readbackClosed`), the GATE is GO. Do **NOT** re-derive a new
phase decomposition — Phases 2-5 are sound and H8-sized. The revision's job is to make plan 19
truthful about its own state, format-compliant, and to integrate this report.

### 4.1 Ordered checklist for v20

1. **[format] Fix plan-level Status** `[NOT STARTED]` → `[IMPLEMENTING]`; add `Started:` line. (D1)
2. **[format] Rewrite the H1 title** to be concise and anchor `nf_nvar_exist_all_depths` (`| _k+2`
   arm) **by declaration name**; remove the rotted `KampPrior.lean:562`. (D2)
3. **[format] Add Phase-1 `Completed:` timestamp** (date of `fbe26f61c`). (D3)
4. **[format] Reconcile `plan_metadata`**: bump `plan_version`; make `dependency_waves` match the
   authoritative 6-wave human table (Phase 4 split 4a→{4b,4c}); append `reports/20_…md` to
   `reports_integrated`. (D4)
5. **[format] Fix Phase 5 `Depends on`** to `4b, 4c` only; move the 13a/13b/13c landed-asset
   dependency into prose (it already appears in the phase's task bullets). (D5)
6. **[format, minor] Normalize sub-phase headings** 4a/4b/4c or annotate the `####` convention; drop
   or annotate the extra "State" column in the wave table. (D6, D7)
7. **[substance, carry-forward] Add the post-GATE risk refinement** (Section 3.3 caveat): the GATE
   validated only the point-type clause of a trivial ξ; Phase 4b (LiftPair tuple skeleton
   disjunction + fwd/bwd) is the remaining representation risk. Keep the 4b split-by-direction
   contingency prominent.
8. **[substance, carry-forward] Add to Phase 5 tasks** an explicit item to correct the STALE
   in-file audit block in `BXCanonical/Completeness.lean` (currently cites `:212/:361/:364` and an
   already-discharged n=1 arm) to name the `nf_nvar_exist_all_depths | _k+2` arm by declaration name
   as the sole residual (Section 3.1 finding).

### 4.2 Phase sizing (already H8-compliant — keep, with two optional splits)

The existing sizing is sound (each phase ≈ one agent run):

| Phase | Est. lines | Keep / adjust |
|---|---|---|
| 2 (`Fintype preds` removal) | 200-450 | Keep. Foundational; two files (`MonadicFO.lean`, `NormalForm.lean`). |
| 3 (`sigE` infinite re-index + delete vacuous probes) | 200-400 | Keep. |
| 4a (`IntervalType` representation) | 200-400 | Keep. Lands the GATE representation into production. |
| 4b (`LiftPair` — hardest) | 400-800 | Keep, with the **fwd/bwd split contingency** promoted to a first-class option (this is where post-GATE risk lives). |
| 4c (`Prop43Translate` + `ConjInterleave`) | 350-650 | Keep; may split per file if a run overflows. |
| 5 (ζ re-wire + spine re-point + retire residual LAST) | 400-700 | Keep. **Optional split** 5a (capture removal + ζ `canonExpand` construction, off-path-verifiable) / 5b (spine re-point + residual deletion + axiom-audit-block correction) if the single run overflows — the residual deletion and the `#print axioms` check must be the terminal actions of 5b. |

### 4.3 Definition of Done (UNCHANGED, restated for the reviser)

Retire the `nf_nvar_exist_all_depths | _k+2` arm (currently `KampPrior.lean:562`) LAST, after the
new path builds green with the residual still present, so that `#print axioms completeness_discrete`
no longer lists `sorryAx` and the only remaining permitted sorries anywhere are
`EANegation.lean:1090` and `EANegation.lean:1249`. Target end-state axiom set:
`[propext, Classical.choice, Lean.ofReduceBool, Lean.trustCompiler, Quot.sound]`.

---

## Recommendations for the Reviser

1. **Treat v20 as a format + freshness revision, not a re-architecture.** The costly analysis is
   done and machine-verified; re-opening the A-vs-B decision or the finite-F question would repeat
   already-refuted work. The plan-compliance rule (`.claude/rules/plan-compliance.md`) applies —
   execute the adjudicated decomposition, do not substitute a new one.
2. **Prioritize D1 and D2.** A stale `[NOT STARTED]` status and a rotted line number in the title
   are the defects most likely to mislead the next implementer; they are cheap to fix and
   high-value.
3. **Carry the two substance items (Section 4.1 #7, #8)** — the post-GATE 4b risk refinement and the
   `Completeness.lean` stale-audit-block correction task — into the revised plan; they are new
   findings from this dispatch, not present in plan 19.
4. **Integrate this report** into `plan_metadata.reports_integrated` and cite it as the provenance
   for the format fixes and the post-GATE risk note.
5. **Preserve every faithfulness anchor by PDF page** and every code anchor by declaration name;
   do not reintroduce line numbers into the revised plan's prose or title.

## References

- Rabinovich (2014), *A Proof of Kamp's Theorem*: Def 3.1 (p.4), Lemma 3.2(2) (p.4), Prop 3.5
  (p.5), Def 4.1 (p.5) + collapse note (p.6), Prop 4.2 / 4.3 / Thm 4.4 (p.6). PDF read directly
  this dispatch (`Rabinovich_2014_Proof_of_Kamps_Theorem.pdf`); companion `.md` corrupt, not used.
- Plan under audit: `plans/19_infinite-esigma-alphabet-optionA.md`.
- Reports corroborated by independent PDF read: `reports/19_architecture-spike-A-vs-B.md`
  (A recommended, B machine-refuted), `reports/18_readback-closed-finite-fl-rescope.md` (finite-F
  NO-GO).
- Working-tree evidence (this dispatch): `Kamp/InfAlphabetProbe.lean` (GATE GO, off-path),
  `WeakCanonical/MonadicFO.lean` (`fintypePreds` present — Phase 2 not started),
  `Kamp/ESigmaExpansion.lean` (`sigE` finite-`F` — Phase 3 not started),
  `Kamp/KampPrior.lean` (`nf_nvar_exist_all_depths` k+2 residual),
  `Kamp/EANegation.lean` (`:1090`, `:1249` permitted sorries),
  `BXCanonical/Completeness.lean` (stale in-file audit block).
