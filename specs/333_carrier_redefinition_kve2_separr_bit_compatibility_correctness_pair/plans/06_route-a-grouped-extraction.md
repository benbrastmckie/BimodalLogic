# Implementation Plan: Route-A Grouped Extraction, Kit Application, and the Outer Depth-2 Fold (task 333)

- **Task**: 333 - carrier_redefinition_kve2_separr_bit_compatibility_correctness_pair
- **Status**: [IN PROGRESS]
- **Effort**: ~7-10 hours remaining (Phase 1 COMPLETED; 3 phases open, one agent run each)
- **Dependencies**: task 334 (COMPLETED — chartered carrier redefinition: `kvE2_sepArr'` + `kvE2_sepDisjValidOwner`); task 342 (COMPLETED — interior-restricted owner index `kvE2_sepPosI`, tie-admitting weak orders, `hLR` deleted); task 321 (PARTIAL — predecessor lineage / DISSOLVED O4 crux record)
- **Research Inputs**: reports/04_r2-blocker-repair-route.md (authoritative for Phase 2 — Lean-ready signatures, probe-verified); reports/03_pdf-fidelity-r3-dissolved-regrounding.md (PDF re-grounding, R3 dissolution); reports/02_post334-soundness-extraction-frontier.md (partly superseded — its R2 side-condition shapes are the mis-promotion this plan corrects)
- **Artifacts**: plans/06_route-a-grouped-extraction.md (this file)
- **Standards**:
  - .claude/context/formats/plan-format.md
  - .claude/rules/artifact-formats.md
  - .claude/rules/state-management.md
  - .claude/rules/git-workflow.md
- **Type**: lean4

## Overview

This plan (v4) revises plan v3 (`plans/05_kit-application-and-outer-fold.md`) after Phase 2
went `[BLOCKED]`: a hard-mode implementation dispatch machine-established that v3's Phase-2
targets — the universal side-conditions `hpairL`/`hpairR`/`hnd` over **all**
`wo ∈ kvE2_sepArr' qnf` — are **FALSE for general `qnf`** (four-element defect record carried
under Postmortem Constraints below). A follow-up hard-mode blocker-research dispatch
(`reports/04_r2-blocker-repair-route.md`) resolved the repair route with machine evidence:

- **Route A (tie-admitting grouped extraction) is CONFIRMED.** Extract directly from the
  grouped disjunct (`kvE2_sepTieGroupedL/R`) through `kvE2_sepClassType_eval_mem`, replacing
  `kvE2_sepBody_extract` with a **hypothesis-free** version carrying **ZERO universal
  side-conditions**. The one genuinely new piece of mathematics — strict cross-run key
  monotonicity of `kvE2_sepTieRuns` on sorted input — was probe-verified green via
  `lean_run_code` in the report-04 dispatch (~100 lines, core List imports only).
- **Route B (filter strengthening) is REFUTED** — settled, do not reconsider (report 04 §Q2):
  re-adding a `Nodup`/no-tie conjunct falsifies `kvE2_sepHonestOrder'_mem_arr'` (SW:6284),
  because the tie-reporting honest order's payload duplicates on tied honest values
  (SW:6131-6137), breaking the primary completeness hand-off `kvE2_sepBody_complete_holds'`
  (SW:6330, consumed SW:9424-9437); its compat half endangers non-vacuity and violates the
  carrier byte-identity territory clause.

Accordingly this plan: carries Phase 1 forward `[COMPLETED]`; **rewrites Phase 2 as the
Route-A grouped-extraction phase** using report 04's exact Lean-ready signatures (Q1 a-d);
restates Phase 3 **wording-only** (bundle shapes identical; `kvE2_sepBundleL/R_parts` at
**SW:5359 / SW:5376** — v3's SW:5167/5184 refs were stale — consumed unchanged into
`kvE_subBracket2V_sound_of_parts`); and keeps Phase 4 (`kvE2_outer_fold`, THE make-or-break)
unchanged including its no-route escape hatch. Non-vacuity is **preserved trivially** under
Route A (report 04 §Q3): `kvE2_sepArr'`, `kvE2_sepDisjValid`, and `kvE2_sepBody` are
untouched, so `kvE2_sepBody_complete` (SW:3208) and the coincident-order membership
(SW:3259) are consumed unchanged. All `SW:` line references in this plan are to HEAD
`278455724` (report 04's revision); **where report 04 and plan v3 disagree on a line number,
report 04 wins.**

**Definition of done (re-scoped charter, carried from v3)**: the remaining SharedWitness
soundness lemmas (revised Phase 2 Route-A extraction, the per-σ kit application, the outer
fold) land sorry-free and axiom-clean on the `NfMultiAnchorBridge` import path, `lake build`
green, LITMUS grep 0 live hits, the carrier structure (`kvE2_sepArr'`/`kvE2_sepBody`) stays
byte-identical, and the extraction/kit/fold lemmas are available for task 335 to consume in
`OuterGate.lean` to close its BLOCKED ⇒ half. No OuterGate gate assembly, no F4 semantic ℤ
discriminator (out of scope — Territory Contract and Non-Goals).

### Research Integration

- **reports/04_r2-blocker-repair-route.md** (integrated in plan v4, 2026-07-10): the
  authoritative input for the rewritten Phase 2. Supplies (a) the Route A / Route B verdict
  with machine evidence (probe compiled green; Route B refuted on three grounds); (b) the
  exact Lean-ready replacement signatures (§Q1 a-d), transcribed **verbatim** into Phase 2
  below; (c) the decisive-use reads: `hnd` consumed ONLY at the singleton conversion
  (SW:6548-6550), `hpairL/R` ONLY at two same-owner `kvE2_sep_index_lt_of_rank_lt` calls
  (SW:6420, SW:6444) — both eliminated by grouped extraction; (d) the interface-safety fact
  that `kvE2_sepBody_extract` (SW:6520) has **zero consumers repo-wide** (grep: only
  docstring mentions), so replacing its hypothesis list is safe; (e) the H5 confirmed
  mis-promotion finding (see Postmortem Constraints); (f) the corrected line refs
  (`kvE2_sepBundleL_parts` SW:5359, `kvE2_sepBundleR_parts` SW:5376); (g) Phases 3/4
  survival analysis (§Q6) and task-335 impact (§Q5: none adverse — 335 consumes
  `kvE2_outer_fold`, not the extraction).
- **reports/03_pdf-fidelity-r3-dissolved-regrounding.md** (integrated in plan v3, carried):
  PDF fidelity audit (the Rabinovich `.md` conversion is UNSAFE — display equations dropped,
  `k≠m` inverted; cite the PDF by page only; 89 dangling in-code `md:NN` citations exist,
  add none); R3 dissolution; H3 page-cited source map (carried below).
- **reports/02_post334-soundness-extraction-frontier.md** (integrated in plan v2, carried):
  post-334 ground-truth inventory. **Further superseded in v4**: its side-condition
  obligation 1 (the R2 `Pairwise`/`Nodup` shapes) is now known to be a mis-promotion of the
  carrier's configuration-restriction annotations (SW:6505-6519) — retracted alongside its
  already-retracted §C.2 obligation 2 (the dissolved R3). Its obligation 3 (outer fold =
  Phase 4) stands.

### Preserved Assets

The following work is complete, committed green + axiom-clean, and must not regress. Do NOT
re-prove any of it; Phase 2 consumes it.

| Component | File | Status | Verified |
|-----------|------|--------|----------|
| Phase 1 (R1 cleanup: dead `kvE2_sepBody_nonvacuous` deleted; ⇐ axiom triple re-verified) | SharedWitness.lean | [COMPLETED] | commit `924d76c49`, 2026-07-09 |
| Phase-2 provable core: 6 lemmas below | SharedWitness.lean | landed green | commits `98c1b6afa`, `7c1b191ee`, 2026-07-10; `lean_verify` `[propext, Classical.choice, Quot.sound]` |

Six landed Phase-2 lemmas and their Route-A roles (report 04 §Q4) — **4 of 6 are directly
load-bearing for Route A**:

| Landed lemma | SW line | Load-bearing for Route A? | Role under Route A |
|---|---|---|---|
| `kvE2_sepArr'_consistent` | SW:4330 | **YES** | conjunct-(ii) accessor feeding the strict same-owner gIdx read |
| `kvE2_sep_find?_owner_entry` | SW:4341 | **YES** (transitively) | powers `kvE2_sepSlotGIdx_read` |
| `kvE2_sepSlotGIdx_read` | SW:4364 | **YES** | payload read on arbitrary valid `wo` |
| `kvE2_sep_rank_le_of_gidx_le` | SW:4378 | **YES** | its **contrapositive** IS the needed `kvE2_sep_gidx_lt_of_rank_lt` (ℕ: `¬≤` = `<`) |
| `kvE2_sepSlotsLOf_pairwise_sameOwner` | SW:4417 | Not directly | banked, harmless; the grouped route replaces `kvE2_sepSlotLe` reads with class order |
| `kvE2_sepSlotsROf_pairwise_sameOwner` | SW:4450 | Not directly | mirror of the above |

Also preserved consume-only (unchanged from v3): the ⇐ completeness chain
(`kvE2_sepBody_complete` SW:3208, `kvE2_sepBody_complete_holds'` SW:6330,
`kvE2_sepHonestOrder'_mem_arr'` SW:6284); the grouped-disjunct infrastructure
(`kvE2_sepBody_holds_iff` SW:2372, `kvE2_sepClassType_eval_mem` SW:2133,
`kvE2_sepTieGroupedL/R_flatten` SW:2064/2069, `kvE2_sepSlotsLOf_mem`/`ROf_mem`
SW:2268/2278, `kvE2_sepSlotsL/ROf_mergeSorted` SW:4083/4089); the flat extraction template
`kvE2_sepDisjunct_extract` (SW:6359, skeleton donor — kept, not deleted); the singleton
conversion pair `kvE2_sepTieGroupedL/R_of_nodup` / `kvE2_sepDisjunct'_map_singleton_iff`
(SW:5703 — **kept**: the completeness side still uses them at SW:5882-5884); the bundle
reducers `kvE2_sepBundleL_parts` (SW:5359) / `kvE2_sepBundleR_parts` (SW:5376); the
design-guard `kvE2_sepHonest_hLR_absurd` (SW:5714).

### Source-to-Implementation Mapping (H3 — Tier 1: literature, PDF pages; carried from v3)

Ground truth: `~/Projects/Literature/sources/rabinovich_2014/Rabinovich_2014_Proof_of_Kamps_Theorem.pdf`
(16 pp., cited by PAGE only). **Never cite `md:NN`** — the re-extracted `.md` drops every
displayed equation and inverts an inline negation (`k≠m` → `k=m`); all line-number anchors
dangle. 89 dangling in-code `md:NN` citations exist in `SharedWitness.lean`; **add none**.

| Source claim | PDF location | Lean identifier (HEAD 278455724) | Phase |
|--------------|--------------|----------------------------------|-------|
| Def 3.1: strict chain, pinning indices with no distinctness ⇒ tie-collapse forced | **p.4** | `KvE2SepSpikeOrderType`, `kvE2_sepDisjValid` tie conjunct | consumed (all) |
| Lemma 3.2(1): conjunction ≡ disjunction of ⃗∃∀ (stated, no printed proof) | **p.4** | `kvE2_sepArr'` / `kvE2_sepDisjValid` (SW:1767-1772) | consumed (all) |
| Lemma 3.2(2): anchor cap 2 — ≤ two free variables `(x,t)` | **p.4** | outer depth-2 fold (`kvE2_outer_fold`) | 4 |
| Lemma 5.1, formula (5.1): QF point types, open-interval betweens, ends pinned | **p.7** | point types = `charBase` / `charK (nfk_projFresh σ)`; class meets are `formula_conjList` over these (SW:2109) — no `fChainPred`, no nesting (LITMUS) | 2, 3, 4 (audit) |
| Notation 5.2: `[α₀,β₁,…,α_n](z₀,z₁)` | **pp.7-8** | per-owner bracket bundle shape (`kvE2_sepBundleL/R` SW:5302/5318) | 3 |
| Lemma 5.3 + INF (5.2): `¬∃`-chain ≡ `O_n(...)` | **p.8** | navigated `¬∃` interval decomposition | 3, 4 (audit) |
| Cor 5.4 fold `F_{i-1} := α_{i-1} ∧ (β_i Until F_i)` | **p.9** | navigated fold; `NavigatedSpine.lean` | 4 |
| Def 7.5: 3-alternative `z₀ > z₁ ∨ z₀ = z₁ ∨ [bracket]` | **p.13** | tie-admitting validity, coincidence a first-class disjunct | consumed (all) |
| §5 ψ0/ψ1/φ split (interiority a construction invariant) | **p.7** | `kvE2_sepPosI` (task 342) | consumed (all) |

Tie admission itself is a **carrier-design question grounded in Lean source + the task-342
record** (Tier 3 for Phase 2's new lemmas, per report 04's fidelity caveat) — Phase 2's new
lemmas are pure list/ℕ + point-type reads and cite no Rabinovich formula. **Mandated citation
form for Def 3.1 / Lemma 3.2 (verbatim from 342):** *"the construction forced by Def 3.1
(p.4), corroborated by the k=m split (p.7) and Def 7.5 (p.13); Lemma 3.2(1) (p.4) states the
closure without printed proof."*

## Postmortem Constraints

Binding rules for all implementation dispatches. Derived from the Phase-2 blocker (dispatch
sess_1783679696_817168), report 04's H5 divergence audit, and the carried v3 constraints.

### Defect postmortem (carried verbatim in substance from v3's Phase-2 heading — do not drop)

**What failed (plan v3 defect, four-element record):** v3's Phase 2 asked to prove the
universal side-conditions `hpairL`/`hpairR`/`hnd` over all `wo ∈ kvE2_sepArr' qnf`. These
are **FALSE for general `qnf`**, machine-checked via `lean_goal` on structured attempts:

- **What failed**: the exact-shape `hpairL` and `hnd` lemmas. Residual goals (all provable
  structure discharged; `lean_state_search` no hit):
  - Cross-owner `hpair` residue: `hwo : wo ∈ kvE2_sepArr' qnf`, `hkey : kvE2_sepSlotMergeLe
    wo a b = true`, `hsub : ¬kvE2_sepSlotSub a = kvE2_sepSlotSub b` ⊢
    `kvE2_sepCompat a b = true`.
  - `hnd` residue: `heq : kvE2_sepSlotGIdx wo x = kvE2_sepSlotGIdx wo y` ⊢ `x = y` for
    `x, y ∈ kvE2_sepSlotsLOf wo`.
- **What was tried**: (1) full decomposition through `kvE2_sepSlotsLOf_mergeSorted` +
  `List.Pairwise.imp_of_mem` — the SAME-OWNER half IS provable and is LANDED (Preserved
  Assets); (2) `List.Nodup.map_on` over `kvE2_sepSlotsLOf_nodup`, leaving GIdx-injectivity;
  (3) `lean_state_search` on the compat residue — no relevant lemma.
- **Why false (counterexample construction)**: `kvE2_sepDisjValid` (SW:1767-1772) reads NO
  cross-owner OPEN bit at a foreign 1-type, and payload tuples are enumerated freely.
  `hpairL` counterexample: two LEFT-interior owners σ ≠ τ with
  `kvE2_sepBits σ kvE_sub2_zXU χ = false` and τ's payloads below σ's — all four validity
  conjuncts pass but `kvE2_sepCompat … = false` (`kvE2_sepCompat_lX1_eq`, SW:984). `hnd`
  counterexample: two same-rank base slots with EQUAL payload entries — base-base payload
  ties are **deliberately admitted** (SW:1619-1620; conjunct-(iii) removal SW:1756-1759 is
  the task-342 completeness repair). Under Route A both residual goals **disappear** (never
  posed): cross-owner order is never consulted; GIdx injectivity is replaced by class
  grouping.
- **Root cause (H5 CONFIRMED mis-promotion)**: reports 02/03 and plans v2/v3 promoted the
  carrier's own *configuration-restriction annotations* (SW:6505-6519) into universally
  dischargeable side-conditions. The task-334 note (SW:6505-6510) says the `hpair` facts
  hold "whenever the canonical union is a single region-sorted block"; the task-342 note
  (SW:6512-6519) calls `hnd` a restriction "to the TIE-FREE configuration" whose
  tie-admitting replacement is the arbitration item. v3 nonetheless asserted the phase was
  "mechanical and correctly stated". Verified against source by report 04 (H5 table).
- **Prohibited then, still prohibited**: no `sorry` was landed for a false statement; no
  filter weakened; `hgate` not assumed; no vacuous placeholder.

**Do NOT**:
- **Do NOT re-attempt the v3 Phase-2 universal side-conditions** `hpairL`/`hpairR`/`hnd`
  over all `wo ∈ kvE2_sepArr' qnf` — proven FALSE (counterexamples above). Any claim that
  "R2 discharges `hpairL`/`hpairR`/`hnd`" (v3 lines 229-230, 381) is false and has been
  removed from this plan.
- **Do NOT reconsider Route B (filter strengthening)** — REFUTED (report 04 §Q2): the tie
  half re-opens the machine-certified completeness hole (SW:1756-1759; breaks SW:6284 →
  SW:6330 → SW:9424-9437); the compat half endangers non-vacuity (SW:3208-3248 discharges
  via closed-key reads only) and violates the carrier byte-identity territory clause. Both
  routes are decided; do not re-litigate.
- **Do NOT promote configuration-restriction annotations into universal side-conditions.**
  Before stating any new `∀ wo ∈ kvE2_sepArr' qnf` lemma, verify each claimed property
  against `kvE2_sepDisjValid`'s actual conjuncts (SW:1767-1772), not against docstring
  restrictions of the form "holds whenever <config>".
- **Do NOT pursue the deleted plan-02 R3.** The forward-zone conjunct
  `σ.2 (nf0_assemble kvE_sub2_zXU χ σ.1) = true` is the *antecedent* of a per-owner
  `bit ⟹ witness` implication, never a goal. Do not try to "prove the bit true."
- **Do NOT weaken any filter toward vacuity.** `kvE2_sepDisjValidOwner`/`kvE2_sepDisjValid`
  is the consistency filter of Lemma 3.2(1) (p.4). If something cannot be shown to close,
  the fix is NOT to relax the filter; STOP and escalate (Rollback/Contingency).
- **Do NOT introduce a new `sorry`, `sorry` deferral, or assumed-`hgate` on any committed
  path** (zero-debt). Final state: sorry-free on every live path, axiom-clean.
- **Do NOT introduce an `x1 < e_i` relative-position literal** on any live path (LITMUS).
  Read arrangement slot **indices** / class indices and per-owner **validity bits**, never a
  model-order literal between a fresh witness and a slot. Zero live hits, always.
- **Do NOT introduce a `fChainPred` term or nested point-type structure** (no-nesting,
  Lemma 5.1, p.7). Every point-type position stays `charBase χ` or
  `charK (nfk_projFresh σ)`; class meets are `formula_conjList` over existing slot types
  (the landed task-342 shape, SW:2109).
- **Do NOT edit any file other than `SharedWitness.lean`** (H7). `OuterGate.lean`,
  `NavigatedSpine.lean`, the `SubBracket2V` engine bricks, and all sibling do-not-edit
  assets stay byte-identical. The carrier structure
  `kvE2_sepArr'`/`kvE2_sepDisjValidOwner`/`kvE2_sepBody` stays byte-identical.
- **Do NOT add any `md:NN` citation** (89 already dangle; the `.md` conversion is UNSAFE).
  Cite the PDF by page only.
- **Do NOT delete the singleton-conversion pair**
  (`kvE2_sepTieGroupedL/R_of_nodup`, `kvE2_sepDisjunct'_map_singleton_iff` SW:5703) — the
  completeness side still consumes them at SW:5882-5884. Remove them only from the *live
  soundness route*.
- **Do NOT treat the SW cross-σ-order comment or the O4 crux record as a live blocker** —
  intended design post-342, self-annotated "additive and inert."
- **Do NOT keep the L/R macro-side confinement invariant unaudited**: L list carries only
  `(x,w)` slots, R list only `(w,t)` slots — audit on every new lemma.

**MUST preserve** (see Preserved Assets): the 6 landed Phase-2 lemmas (4 load-bearing —
consume, never re-prove); Phase 1's committed state; the ⇐ completeness chain; the
consume-only kit (`kvE_subBracket2V_sound_of_parts` SubBracket2V:1290 per report 04, the
`_parts` reducers SW:5359/5376); the flat `kvE2_sepDisjunct_extract` (SW:6359) as skeleton
donor.

**Design decisions are SETTLED** (do not re-open without concrete counterexample):
- Route A over Route B (report 04 verdict, machine-grounded both directions).
- The replacement `kvE2_sepBody_extract` carries ZERO universal side-conditions and replaces
  the current one **in place** (interface-safe: zero consumers repo-wide).
- Tie admission (task 342) is a completeness-load-bearing carrier feature, not a defect.
- Phase 4 (`kvE2_outer_fold`) remains THE make-or-break; task 335 wraps `kvE2_outer_fold`,
  not the extraction, and is unaffected by the Phase-2 rewrite.

## Goals & Non-Goals

- **Goals**:
  - Phase 1: DONE (provenance only; committed green at `924d76c49`).
  - Phase 2 (REWRITTEN, Route A): land the tie-admitting grouped extraction — generic
    `kvE2_sepTieRuns_const` / `_sorted_strict` / `_classIdx_lt` (probe-verified),
    `kvE2_sep_gidx_lt_of_rank_lt` (contrapositive wrapper of landed SW:4378),
    `kvE2_sepDisjunct'_extract` (grouped analog of SW:6359), and the **hypothesis-free
    `kvE2_sepBody_extract` replacement** (zero universal side-conditions; zero consumers
    repo-wide, so interface-safe).
  - Phase 3 (wording-only restatement): thread the per-σ bundles — shape-identical to
    before (report 04 §Q6) — through `kvE2_sepBundleL_parts` (SW:5359) /
    `kvE2_sepBundleR_parts` (SW:5376) into `kvE_subBracket2V_sound_of_parts`
    (SubBracket2V:1290) to obtain each positive owner's `nf_eval`. No dependence on
    `hpairL`/`hpairR`/`hnd` — inputs come from the revised hypothesis-free
    `kvE2_sepBody_extract`.
  - Phase 4 (unchanged, THE make-or-break): prove `kvE2_outer_fold` — reassemble
    `∃ w, nf_eval_nf M 2 3 [w,x,t] qnf` from the per-σ realizations +
    `ExistProviders.correct` + the navigated sub-chain (`NavigatedSpine.lean:445` sketch).
- **Non-Goals**:
  - No edits outside `SharedWitness.lean`; **no edit to `OuterGate.lean`** (task 335).
  - **Route B is not pursued**; the v3 Phase-2 side-conditions are not re-attempted; the
    plan-02 R3 stays deleted.
  - No R5 gate assembly (`bracketEndChar_kvE2_sound_two_prior` /
    `bracketEndChar_kvE2_correct_two_prior`) — task 335 consumes this plan's lemmas.
  - No F4 semantic ℤ discriminator — OUT OF SCOPE; spawned separately after 335's R5.
  - No carrier-structure edits; no de-privatization; no new axioms; no `sorry` deferral.
  - No repair of the 89 dangling in-code `md:NN` citations (deliberate user decision).

## Risks & Mitigations

- **Risk (HIGH — the single make-or-break: Phase 4 outer fold has no landed depth-2
  quant-layer engine).** `nf_quant_layer_fold_iff` (`NfEFold.lean:391`) folds depth-0 inner
  subs; the k=2 quant layer ranges over depth-1 subs. This is the only HIGH risk in the
  plan; Phases 2-3 are bounded by probe/landed evidence, Phase 4 is not. *Mitigation*:
  assemble from per-σ realizations via `ExistProviders.correct` + the
  `NavigatedSpine.lean:445` sketch, not a generic fold engine; the `_parts` reducers
  (SW:5359/5376) already deliver the kit inputs. **Escape hatch (binding)**: if the fold
  has no viable route, STOP, capture `lean_goal`, and `/spawn` a scoped depth-2
  quant-layer-fold research task — never fabricate a fold, weaken the statement, or
  introduce `sorry`.
- **Risk (MEDIUM): un-probed transposition in Phase 2's grouped extraction.** The generic
  tie-run lemmas are probe-verified, but `kvE2_sep_getElem_mid/left/right` and
  `IntervalPattern.holds_eq_succ` were verified generic **by read**, not by compile, at the
  grouped instantiation (report 04 residual mode 1). If any is secretly specialized to
  `kvE2_sepSlotType` lists, ~30 extra glue lines. *Mitigation*: they are consumed at
  SW:6497 with underscores (shape-generic); budgeted in Phase 2's estimate; if glue exceeds
  budget, commit the green generic lemmas first (sub-step commit) and continue.
- **Risk (MEDIUM): Bool/Prop Pairwise bridge friction.** `mergeSorted` gives
  `Pairwise (kvE2_sepSlotMergeLe wo · · = true)`; the tie-run lemmas want
  `Pairwise (key ≤ key)`. *Mitigation*: `kvE2_sepSlotMergeLe` is literally
  `decide (gIdx ≤ gIdx)` (SW:1932), so `List.Pairwise.imp (by simpa …)` closes it — the
  same move as SW:4438-4439 (report 04 residual mode 2).
- **Risk (MEDIUM — carried): right-interior class kit application residual.** The
  `kvE2_sepBundleR` docstring carries a Phase-7-era note "no landed per-σ correctness kit
  serves this class yet"; `kvE2_sepBundleR_parts` (SW:5376) exists and targets the same
  `kvE_subBracket2V_sound_of_parts`. *Mitigation*: exercise the right-class application
  explicitly in Phase 3; if it does not discharge, add a kit-application lemma in
  `SharedWitness.lean` (333 territory) — never weaken a filter, never assume `hgate`.
- **Risk (MEDIUM — carried): task 335 cannot consume the lemmas** (signature mismatch at
  the SharedWitness↔OuterGate seam). *Mitigation*: report 04 §Q5 already confirms Route A
  is strictly easier for 335 (hypotheses removed; 335 wraps `kvE2_outer_fold`, whose
  statement is unchanged). State `kvE2_outer_fold` in the shape the OuterGate ⇒ path
  expects (`OuterGate.lean:172-201`); re-shape in `SharedWitness.lean`, never edit
  `OuterGate.lean`.
- **Risk (LOW): same-owner tie-class collision** (an anchor and its base slot landing in
  one tie class, breaking strict `u < x1`). *Mitigation*: impossible on valid `wo` —
  conjunct (ii) via `kvE2_sepArr'_consistent` (SW:4330) forces strictly distinct keys for
  same-owner anchor-base pairs, hence distinct classes (report 04 adversarial table, High
  confidence). Cross-owner ties merely enlarge a class's meet;
  `kvE2_sepClassType_eval_mem` reads through it.
- **KNOWN, DOCUMENTED hazard (NOT fixed by this task): 89 dangling `md:NN` citations** in
  `SharedWitness.lean`. Future readers must not trust them. This plan neither relies on
  them nor repairs them; new docstrings cite PDF pages per the H3 table.

## Task 335 coordination (informational — 335 is NOT edited by this task)

Task 335 retains the authorization (carried from plan-02) to consume task 333's additive
soundness lemmas to close its ⇒ half in `OuterGate.lean`. 335's BLOCKED record
(`OuterGate.lean:180-203`) remains doubly stale (names deleted declarations; claims no
authorization is held — false). **Route A does not change 335's interface**: 335's consumer
`bracketEndChar_kvE2_sound_two_prior` wraps `kvE2_outer_fold` (Phase 4), NOT
`kvE2_sepBody_extract`, and the extraction now carries *fewer* hypotheses, so nothing new
bubbles up (report 04 §Q5). Updating 335's record is out of this plan's file scope.

## Territory Contract (H7 — binding ownership scope)

Orchestrator-approved, user-binding. Carried unchanged from v3; honored by Route A as-is.

- **Task 333 owns ONLY
  `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge/SharedWitness.lean`.**
  All Phase 2/3/4 work is soundness lemmas in this single file (Phase 2 additionally
  replaces the zero-consumer `kvE2_sepBody_extract` hypothesis list in place — authorized
  by report 04's interface-safety finding).
- **Task 333 MUST NOT edit `OuterGate.lean`** (task 335's file).
- **Task 335 is GRANTED authorization** to consume 333's extraction/kit/fold lemmas in
  `OuterGate.lean`.
- **Carrier structure `kvE2_sepArr'` / `kvE2_sepDisjValid` / `kvE2_sepDisjValidOwner` /
  `kvE2_sepBody` stays byte-identical.** All do-not-edit assets (`SubBracket2V.lean`,
  `NavigatedSpine.lean` engine bricks, `SubBracket.lean`, `SubBracket2.lean`, `Base.lean`,
  `CarrierK1V.lean`, `CarrierKv.lean`, `PriorInterface.lean`, sibling-Kamp files) stay
  byte-identical — consume-only.
- **F4 semantic ℤ discriminator is EXCLUDED** (downstream of 335's R5; spawned separately;
  when spawned it must genuinely DISCRIMINATE — LHS-FALSE at `(10,20)`, never weakened).

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1, 2 | -- |
| 2 | 3 | 2 |
| 3 | 4 | 3 |

Phase 1 is COMPLETED (committed at `924d76c49`); Phase 2 has no open prerequisite, so waves
1 holds both. Phase 2's hypothesis-free extraction supplies the bundles Phase 3 threads;
Phase 3's per-σ realizations feed Phase 4's fold. Every phase edits the single file
`SharedWitness.lean` (H7 exclusive ownership), so within-wave parallelism is nominal — the
ordering is effectively sequential.

### Phase 1: R1 — Cleanup: dead `kvE2_sepBody_nonvacuous` deleted; ⇐ axiom triple re-verified [COMPLETED]

- **Completed:** 2026-07-09 — committed green at `924d76c49`.
- **Goal (achieved):** removed the dead conditional non-vacuity lemma (zero live consumers,
  superseded by the unconditional `kvE2_sepBody_complete`) and re-confirmed the ⇐-chain
  axiom triple `[propext, Classical.choice, Quot.sound]` on `kvE2_sepBody_complete` /
  `kvE2_sepArr'_sound` / `kvE2_sepBody_holds_of_honest`.
- **Depends on:** none
- **Do NOT re-plan or re-run.** Carried forward for provenance only. (The partial Phase-2
  dispatch additionally landed the 6 preserved-asset lemmas at `98c1b6afa`/`7c1b191ee`;
  they are accounted under Preserved Assets, not re-planned here.)

### Phase 2: Route-A tie-admitting grouped extraction — hypothesis-free `kvE2_sepBody_extract` [IN PROGRESS]

- **Goal:** Replace the v3 side-condition obligation (proven false — see Postmortem
  Constraints) with the Route-A grouped extraction: extract directly from the grouped
  disjunct (`kvE2_sepTieGroupedL/R`) through `kvE2_sepClassType_eval_mem`, eliminating the
  `hnd` singleton conversion and the `hpairL/R` cross-owner Pairwise entirely. The
  replacement `kvE2_sepBody_extract` carries **ZERO universal side-conditions** — every
  needed fact derives from carrier membership `hwo : wo ∈ kvE2_sepArr' qnf` alone — and has
  **zero consumers repo-wide** (grep: only docstring mentions at
  SW:2249/2266/4320/4483/4501/7108), so replacing it in place is interface-safe. All
  targets below are the exact Lean-ready signatures from report 04 §Q1(a-d), probe-verified
  where marked; **transcribe them faithfully — do not paraphrase or "improve" them**:

  ```lean
  -- (a) generic tie-run lemmas, probe-verified green via lean_run_code
  --     (verbatim modulo renaming; ~100 lines as compiled, structural recursion
  --      mirroring kvE2_sepTieRuns SW:1971-1977 + pairwise_iff_getElem + omega):
  theorem kvE2_sepTieRuns_const {α : Type*} (key : α → ℕ) :
      ∀ (l : List α), ∀ c ∈ kvE2_sepTieRuns key l, ∀ x ∈ c, ∀ y ∈ c, key x = key y

  theorem kvE2_sepTieRuns_sorted_strict {α : Type*} (key : α → ℕ) :
      ∀ (l : List α), l.Pairwise (fun x y => key x ≤ key y) →
        (kvE2_sepTieRuns key l).Pairwise (fun c d => ∀ x ∈ c, ∀ y ∈ d, key x < key y)

  theorem kvE2_sepTieRuns_classIdx_lt {α : Type*} (key : α → ℕ) (l : List α)
      (hs : l.Pairwise (fun x y => key x ≤ key y))
      {i j : ℕ} (hi : i < (kvE2_sepTieRuns key l).length)
      (hj : j < (kvE2_sepTieRuns key l).length)
      {a b : α} (ha : a ∈ (kvE2_sepTieRuns key l)[i]) (hb : b ∈ (kvE2_sepTieRuns key l)[j])
      (hab : key a < key b) : i < j

  -- (b) contrapositive wrapper of the LANDED kvE2_sep_rank_le_of_gidx_le (SW:4378),
  --     same hypotheses, same private style (ℕ: ¬≤ = <):
  theorem kvE2_sep_gidx_lt_of_rank_lt … :
      kvE2_sepSlotRank a < kvE2_sepSlotRank b → kvE2_sepSlotGIdx wo a < kvE2_sepSlotGIdx wo b

  -- (c) the grouped extraction (replaces the hpair/hnd-consuming route; skeleton
  --     transposed from the landed flat template kvE2_sepDisjunct_extract SW:6359-6448):
  theorem kvE2_sepDisjunct'_extract {sig} (charBase charK) (qnf)
      {wo : KvE2SepWeakOrder sig} (hwo : wo ∈ kvE2_sepArr' qnf)
      (M) (atomMap) (x t : M.carrier)
      (h : (kvE2_sepDisjunct' charBase charK qnf
          (kvE2_sepTieGroupedL wo) (kvE2_sepTieGroupedR wo)).2.holds M atomMap x t) :
      (kvE2_sepEpL charBase charK qnf).eval_at M atomMap x ∧
      (kvE2_sepEpR charBase charK qnf).eval_at M atomMap t ∧
      ∃ w, x < w ∧ w < t ∧ (kvE2_sepPtW charBase charK qnf).eval_at M atomMap w ∧
        (∀ σ ∈ kvE2_sepPos qnf, nf0_zoneSpec σ.1 = kvE2_sep_zXW3 →
          kvE2_sepBundleL charBase charK σ M atomMap w x) ∧
        (∀ σ ∈ kvE2_sepPos qnf, nf0_zoneSpec σ.1 = kvE2_sep_zWT3 →
          kvE2_sepBundleR charBase charK σ M atomMap w t)

  -- (d) the revised body extraction — NO side-conditions at all:
  theorem kvE2_sepBody_extract (charBase charK qnf M atomMap x t)
      (h : (kvE2_sepBody charBase charK qnf).holds M atomMap x t) :
      ⟨same conclusion as (c)⟩
  -- proof: by_cases hgate; holds_iff → ⟨wo, hwo, hd⟩ → kvE2_sepDisjunct'_extract hwo … hd;
  -- gate-fail branch verbatim SW:6557-6558.
  ```

  Proof architecture for (c) (report 04 §Q1, steps 1-4): destructure the realized grouped
  bracket (`kvE2_sepBody_holds_iff` SW:2372; same skeleton as SW:6382-6397 —
  `IntervalPattern.holds_eq_succ`, `kvE2_sep_getElem_mid/left/right`, generic over point
  lists); shared witness `w := ws ⟨gL.length⟩` realizes `ptW` with `x < w < t` from the
  bracket's own range; per LEFT owner σ, locate `.lX1 σ` in its tie class via
  `kvE2_sepSlotsLOf_mem` (SW:2268) + `kvE2_sepTieGroupedL_flatten` (SW:2064) and project
  through `kvE2_sepClassType_eval_mem` (SW:2133); for each `zXU`-positive χ, get strict
  same-owner key order from (b) applied at conjunct (ii) (`kvE2_sepArr'_consistent`
  SW:4330), then `jχ < iσ` by (a)'s `classIdx_lt` at `kvE2_sepSlotsLOf_mergeSorted`
  (SW:4083; Bool→Prop Pairwise via `List.Pairwise.imp` + `simpa`, `kvE2_sepSlotMergeLe` =
  `decide (gIdx ≤ gIdx)` SW:1932), and `u := ws ⟨jχ⟩ < x1` by bracket monotonicity — the
  strict "below" half of `kvE2_sepBundleL` (SW:5302). Same-owner anchor-base pairs can
  never share a tie class (conjunct (ii) forces strictly distinct keys); cross-owner ties
  merely enlarge a class's meet, read through by `kvE2_sepClassType_eval_mem`. RIGHT
  mirror identically. Coverage facts via `kvE2_sepSlotsLOf_mem`/`ROf_mem` (SW:2268/2278)
  with `hwo' : wo ∈ kvE2_sepOrderTypes` from `List.mem_filter.mp hwo`, as at SW:6545.
- **Tasks:**
  - [ ] Land (a): generic `kvE2_sepTieRuns_const`, `kvE2_sepTieRuns_sorted_strict`,
        `kvE2_sepTieRuns_classIdx_lt` — transcribe the report-04 probe (compiled green,
        zero diagnostics; imports already available in-file). Commit as a green sub-step
        (`task 333 phase 2.1: …`) before proceeding.
  - [ ] Land (b): `kvE2_sep_gidx_lt_of_rank_lt` — contrapositive wrapper of the LANDED
        `kvE2_sep_rank_le_of_gidx_le` (SW:4378, Preserved Assets; do NOT re-prove the
        landed lemma).
  - [ ] Land (c): `kvE2_sepDisjunct'_extract` per the proof architecture above — consume
        the landed load-bearing assets (`kvE2_sepArr'_consistent`, `kvE2_sepSlotGIdx_read`,
        `kvE2_sep_find?_owner_entry`) rather than re-deriving them.
  - [ ] Land (d): replace `kvE2_sepBody_extract` (SW:6520) **in place** with the
        hypothesis-free version; delete the singleton-conversion step from the live
        soundness route ONLY (keep `kvE2_sepTieGroupedL/R_of_nodup` and
        `kvE2_sepDisjunct'_map_singleton_iff` — completeness still uses them at
        SW:5882-5884). Update the replaced lemma's docstring: cite the tie-admitting
        design (task-342 record) and PDF pages per the H3 table; no `md:NN`.
  - [ ] Verify zero consumers assumption still holds before the in-place replacement
        (grep `kvE2_sepBody_extract` over `Theories/`; expect only docstring mentions).
  - [ ] Audits: LITMUS 0 live hits (all new lemmas are pure list/ℕ + point-type reads — no
        zone bit, no order literal); no-nesting (class meets are `formula_conjList` over
        existing slot types, SW:2109); L/R macro-side confinement (L only `(x,w)`, R only
        `(w,t)`); carrier byte-identity (`kvE2_sepArr'`/`kvE2_sepDisjValid`/`kvE2_sepBody`
        untouched — non-vacuity is thereby preserved trivially, report 04 §Q3).
- **Timing:** ~3-4 hours.
- **Depends on:** none (Phase 1 done; the 6 preserved-asset lemmas are already landed)
- **Estimated output:** ~240-330 lines (~100-120 generic tie-run lemmas as probe-compiled +
  ~10-20 contrapositive wrapper + ~120-180 grouped extraction with skeleton transposed from
  SW:6359-6448 + glue; +~30 contingency for the un-probed transposition risk). Fits one
  agent run (H8); if the extraction half stalls past budget, commit the green (a)/(b)
  sub-steps and hand off with the `lean_goal` state — do not split speculatively.
- **Sorry-count target:** 0.
- **Done when:** `lake build …SharedWitness` exit 0; (a)-(d) all proven, sorry-free +
  axiom-clean via `lean_verify` (`[propext, Classical.choice, Quot.sound]`, no `sorryAx`);
  `kvE2_sepBody_extract` takes NO universal side-conditions (binder list = the (d)
  signature exactly); the 6 preserved-asset lemmas byte-unchanged; carrier structure
  byte-identical; LITMUS 0 hits; diff only `SharedWitness.lean`.

### Phase 3: Per-σ kit application: thread bundles through `kvE2_sepBundleL/R_parts` into the sound kit [NOT STARTED]

*(Wording-only restatement of v3's Phase 3 — report 04 §Q6: Route A's extraction produces
bundles of the IDENTICAL shape, so the kit-threading content, timing, and done-criteria are
intact. The only changes: inputs now come from the revised hypothesis-free
`kvE2_sepBody_extract` — the former "with R2's `hpairL`/`hpairR`/`hnd` discharged" wording
is FALSE and removed — and stale line refs corrected to SW:5359/5376.)*

- **Goal:** Apply the landed per-owner sound kit to each bundle. Thread the per-σ bundles
  produced by the revised hypothesis-free `kvE2_sepBody_extract` (Phase 2, via
  `kvE2_sepDisjunct'_extract`) through `kvE2_sepBundleL_parts` (SW:5359) /
  `kvE2_sepBundleR_parts` (SW:5376) into `kvE_subBracket2V_sound_of_parts`
  (SubBracket2V.lean:1290 — consume-only) to obtain each positive owner's `nf_eval`. This
  is a kit application, NOT a bit-proof: the forward-zone conjunct is the *antecedent* of
  the `bit ⟹ witness` implication these bundles carry (`kvE2_sepBundleL` SW:5302), with the
  bit supplied by the owner's own arrangement enumeration — never a goal to prove true.
- **Tasks:**
  - [ ] For an arbitrary realized `wo ∈ kvE2_sepArr' qnf`, take the per-σ bundles from the
        revised hypothesis-free `kvE2_sepBody_extract` (no side-conditions to discharge —
        carrier membership alone suffices).
  - [ ] Reduce each left-class bundle via `kvE2_sepBundleL_parts` (SW:5359) — "yields
        EXACTLY the `kvE_subBracket2V_sound_of_parts` input 5-tuple" — and feed
        `kvE_subBracket2V_sound_of_parts` to obtain the owner's `nf_eval`.
  - [ ] **Verify the right-interior class kit application lands** (the one genuine
        residual; MEDIUM risk): reduce each right-class bundle via `kvE2_sepBundleR_parts`
        (SW:5376) into the same closer. If it does not discharge, add a kit-application
        lemma in `SharedWitness.lean` — never weaken a filter, never assume `hgate`.
  - [ ] Confirm the bit consumed at each owner is self-owned (from that owner's arrangement
        enumeration), NOT a cross-σ goal; no `x1 < e_i` literal (LITMUS).
  - [ ] LITMUS 0 hits; no-nesting audit; macro-side confinement audit (L only `(x,w)`, R
        only `(w,t)`).
- **Timing:** ~1-2 hours (small — near-mechanical kit application).
- **Depends on:** 2
- **Estimated output:** ~80-200 lines (left-class application + right-class verification +
  glue).
- **Sorry-count target:** 0.
- **Done when:** `lake build …SharedWitness` exit 0; each positive owner's `nf_eval`
  obtained from its bundle via `kvE2_sepBundleL/R_parts` →
  `kvE_subBracket2V_sound_of_parts`, sorry-free + axiom-clean via `lean_verify`; the
  right-interior class application confirmed to land; NO filter weakened, NO `hgate`
  assumed; LITMUS 0 hits; diff only `SharedWitness.lean`.

### Phase 4: R4 — Outer depth-2 fold `kvE2_outer_fold` (THE make-or-break) [NOT STARTED]

*(Unchanged from v3 — report 04 §Q6: none of its tasks, risks, or the RESCOPE contingency
reference the deleted side-condition shapes. Task 335's interface wraps `kvE2_outer_fold`,
not the extraction, and is unaffected.)*

- **Goal:** Prove `kvE2_outer_fold`: reassemble `∃ w, nf_eval_nf M 2 3 [w,x,t] qnf` from
  the per-σ realizations (Phase 3) + `ExistProviders.correct` + the navigated sub-chain
  (`NavigatedSpine.lean:445` sketch — consume-only). This is the true make-or-break: there
  is no landed depth-2 quant-layer fold engine (`nf_quant_layer_fold_iff` NfEFold.lean:391
  folds depth-0 inner subs; the k=2 layer ranges over depth-1 subs), so this assembles from
  the per-σ realizations rather than a generic fold.
- **Tasks:**
  - [ ] From the per-σ `nf_eval` realizations obtained in Phase 3, assemble each σ's
        depth-1 realization at a shared pivot `w` with `x < w < t`.
  - [ ] Use `ExistProviders.correct` and the navigated sub-chain (`NavigatedSpine.lean:445`)
        to fold the per-σ realizations into `∃ w, nf_eval_nf M 2 3 [w,x,t] qnf`.
        Consume-only the do-not-edit `NavigatedSpine.lean` engine bricks.
  - [ ] State `kvE2_outer_fold` in the shape task 335's
        `bracketEndChar_kvE2_sound_two_prior` will consume (the OuterGate ⇒ path,
        `OuterGate.lean:172-201`); coordinate the exact interface with 335's consumer
        without editing `OuterGate.lean`.
  - [ ] No `x1 < e_i` literal (LITMUS); no nested point types (no-nesting, Lemma 5.1 p.7);
        L/R confinement audit.
  - [ ] **If the fold has no viable route:** STOP, capture `lean_goal`, and `/spawn` a
        scoped depth-2 quant-layer-fold research task. Do NOT fabricate a fold, weaken the
        statement, or introduce `sorry`.
- **Timing:** ~3-4 hours (make-or-break; split if >300 lines).
- **Depends on:** 3
- **Estimated output:** ~150-300 lines. If assembly exceeds ~300 lines, split into 4.1
  (per-σ depth-1 realization assembly at the shared pivot) and 4.2 (outer `∃ w` fold via
  `ExistProviders.correct`), each with its own green commit.
- **Sorry-count target:** 0.
- **Done when:** `lake build …SharedWitness` exit 0; `kvE2_outer_fold` proven, sorry-free +
  axiom-clean via `lean_verify`; the extraction/kit/fold lemma set is available and shaped
  for task 335's OuterGate ⇒ path; LITMUS 0 hits; diff only `SharedWitness.lean`. (On
  no-route: uncommitted, escalated via `/spawn`.)

## Testing & Validation

Per-phase invariants (run at every open phase's Done-when):
- [ ] `lake build Theories.Bimodal.Metalogic.WeakCanonical.Kamp.NfMultiAnchorBridge.SharedWitness`
      exit 0; `lake build …OuterGate` exit 0 after Phase 4 (no downstream regression).
- [ ] Sorry inventory: `grep -nw "sorry" …/SharedWitness.lean` shows only comment/docstring
      hits — **0 live sorries** at every phase (the import path is already 0-sorry).
- [ ] `lean_verify` axiom-clean (`[propext, Classical.choice, Quot.sound]`, no `sorryAx`) on
      all new/changed symbols — in Phase 2 explicitly on all of (a), (b), (c), (d).
- [ ] Phase-2 specific: the replaced `kvE2_sepBody_extract` binder list matches signature
      (d) exactly (no universal side-condition binder); grep confirms zero non-docstring
      consumers before replacement; the 6 preserved-asset lemmas byte-unchanged.
- [ ] LITMUS grep `grep -nE "fChainPred|x1[[:space:]]*<[[:space:]]*e"` = 0 live hits on new
      lemmas — no `x1 < e_i` literal, ever.
- [ ] No-nesting audit: every point-type position is `charBase χ` or
      `charK (nfk_projFresh σ)`; class meets are `formula_conjList` over existing slot
      types (Lemma 5.1, p.7; task-342 shape SW:2109).
- [ ] Macro-side confinement: L list only `(x,w)` slots, R list only `(w,t)` slots.
- [ ] Citation hygiene: new load-bearing docstrings cite the **PDF by page** (`Rabinovich
      2014, p.N`) — **no `md:NN`** (89 already dangle; add none). Def 3.1 / Lemma 3.2 use
      the mandated 342 form.
- [ ] `git diff --stat` touches only `SharedWitness.lean`; `OuterGate.lean`,
      `NavigatedSpine.lean`, `SubBracket2V.lean`, and the carrier structure
      (`kvE2_sepArr'`/`kvE2_sepDisjValid`/`kvE2_sepBody`) byte-identical — non-vacuity
      thereby preserved trivially (report 04 §Q3).

## Artifacts & Outputs

- plans/06_route-a-grouped-extraction.md (this file)
- Modified: `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge/SharedWitness.lean`
  (Phase 2 Route-A grouped extraction incl. in-place `kvE2_sepBody_extract` replacement;
  Phase 3 per-σ kit application; Phase 4 outer depth-2 fold — all soundness-side, carrier
  structure byte-identical; Phase 1 already committed)
- summaries/06_route-a-grouped-extraction-summary.md (on completion)
- Follow-on (NOT this task): task 335 consumes extraction/kit/fold to close the OuterGate ⇒
  half (R5); a new task spawned after R5 lands for the F4 semantic ℤ discriminator.

## Rollback/Contingency

- **Per-phase git discipline**: commit each phase at its green Done-when
  (`task 333 phase {P}: …`), and each verified-green sub-step within a phase
  (`task 333 phase {P}.{O}: …` — mandated for Phase 2's (a)/(b) milestone). Any phase that
  fails its build-green stays uncommitted; fix forward. Never discard uncommitted work
  without a prior snapshot via `.claude/scripts/git-snapshot.sh`.
- **Phase 2 grouped-extraction transposition stalls** (the un-probed skeleton risk): commit
  the green generic lemmas (a) + wrapper (b) as sub-steps, capture `lean_goal` on the
  stalled (c) obligation, and hand off with the goal state recorded in the plan/handoff —
  do NOT re-attempt the refuted Route B, do NOT weaken a filter, do NOT land a sorry for a
  statement not known provable.
- **Phase 3 right-interior kit does not land**: add a kit-application lemma in
  `SharedWitness.lean` (333 territory). Do NOT weaken
  `kvE2_sepDisjValidOwner`/`kvE2_sepDisjValid`; do NOT introduce `sorry`; do NOT assume
  `hgate`.
- **Phase 4 (make-or-break) has no viable fold route**: if `ExistProviders.correct` + the
  `NavigatedSpine.lean:445` sketch do not fold, STOP, capture `lean_goal`, and `/spawn` a
  scoped depth-2 quant-layer-fold research task; do NOT fabricate a fold or weaken the
  statement.
- **Task 335 cannot consume the lemmas** (interface mismatch): re-shape in
  `SharedWitness.lean` (333 territory) against the `OuterGate.lean:172-201` consumer;
  never edit `OuterGate.lean`.
- **Full revert**: all open-phase edits are confined to `SharedWitness.lean`, so a full
  rollback is `git checkout 7c1b191ee -- …/SharedWitness.lean` (only after a snapshot per
  the dirty-tree rule; `7c1b191ee` is the current landed Phase-2-core HEAD state for this
  file — rolling back further would destroy the preserved assets).
