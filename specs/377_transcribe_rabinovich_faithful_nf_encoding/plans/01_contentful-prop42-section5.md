# Implementation Plan: Contentful Prop 4.2 via Rabinovich Section 5

- **Task**: 377 - transcribe_rabinovich_faithful_nf_encoding
- **Status**: [COMPLETED]
- **Superseded by**: `plans/02_section5-exists-carrier-rebase.md` (v2). v2 refuted this
  plan's central premise and re-split its remaining phases; the `[PARTIAL]`/`[NOT STARTED]`
  phase markers below are void and do not represent live work.
- **Effort**: 8 phases (Phases 1-3 bounded; Phases 4-8 gated on the Phase 3 decision)
- **Dependencies**: None
- **Research Inputs**: reports/01_faithful-nf-encoding-ruling.md (primary; spine premise partially refuted at plan time — see Postmortem Constraints)
- **Artifacts**: plans/01_contentful-prop42-section5.md (this file)
- **Standards**:
  - .claude/rules/artifact-formats.md
  - .claude/rules/plan-format-enforcement.md
  - .claude/rules/plan-compliance.md
  - .claude/rules/lean4.md
- **Type**: lean4

## Overview

The research report rescoped this task to "the `nf_eval_nf` -> `VecEA2` bridge above depth 0",
resting on the claim that **Prop 4.2 is already PROVED** (`neg_2var_vec_ea`, sorry-free and
axiom-clean) and therefore needs only un-archiving. **A plan-time machine check refutes that
claim.** `neg_2var_vec_ea`'s conclusion is `∃ v' : VVecEA2, v'.holds M atomMap z0 z1`, which
asserts no relation whatsoever between `v'` and the negated input `v`. It is provable **from no
hypotheses at all**:

```
theorem prop42_conclusion_is_vacuous {sig} (M) (atomMap) (z0 z1 : M.carrier) :
    ∃ v' : VVecEA2, v'.holds M atomMap z0 z1
```

`lake build` EXIT 0, axioms `[propext, ...]`, no `sorryAx`. Probe:
`reports/01_prop42-vacuity-probe.lean`. The research's machine checks (sorry-free, axiom-clean,
EXIT 0) are all **true**; what they never tested is whether the statement says anything. It does
not.

This is not a quibble — it is the **root cause of the entire faithful path's collapse**, and it
is already documented in-tree, dated, and was read by nobody:

- `Kamp/Prop43.lean:125-129` states it verbatim: *"This is the same vacuity that the codebase's
  `neg_2var_vec_ea` / `neg_vec_ea_m` carry — their conclusion `∃ v', v'.holds env` is likewise
  closed by `⟨tt, tt_holds⟩`."*
- `Kamp/Boneyard/NegationIndep.lean:357-364` records the decision that produced it: when the
  model-independent Prop 4.2 **backward** direction proved UNFIXABLE at the `BracketFormula`
  level, the lineage took a *"PRE-AUTHORIZED model-DEPENDENT interim"* — falling back to
  `neg_2var_vec_ea` and declaring it *"sufficient for the completeness argument"*. It fell back
  to a contentless theorem.
- `Kamp/Prop43.lean:120-165` is then the downstream casualty and **the answer to "why was Prop
  4.3 orphaned"**: Phase 4b found the per-model existential statement vacuous for the same
  reason and could not ship a non-vacuous `prop43_correct`.

**The real gap is therefore not a bridge — it is that Rabinovich's Section 5 (pp.7-11), the
actual proof of Prop 4.2, was never transcribed.** The research's own H3 table already says so:
Lemma 5.1, Lemma 5.3, Cor 5.4, eq (5.2), eq (5.3), and the closing induction are all marked
**ABSENT**. The lineage repeatedly attempted negation closure *without* Section 5's `INF` anchor
machinery, hit the "per-model bracket witness arrangement" gap (`NegationIndep.lean:341-345`),
and papered it over. Rabinovich's mechanism for exactly that gap is the **`INF` anchor factory**
(eq (5.2) p.8, eq (5.3) p.10), which makes the witness arrangement *definable* instead of
existential — and footnote 4 (p.10) reduces the obligation to **existence only, no uniqueness**.

This plan therefore does what the binding user constraint demands: it **transcribes what is
printed** rather than inventing what is not. Section 5 is fully printed with proofs and, per the
research, contains no "It is clear that" anywhere.

**Definition of Done** (unchanged): `KampPrior.lean:519` **and** `:522` both retired (same
declaration, so `sorryAx` leaves `completeness_discrete`'s closure only if both go); full
`lake build` green; no new axioms (exactly `{propext, Classical.choice, Quot.sound}`); every new
declaration carries a page-cited source correspondence.

**Honest scope note for the orchestrator**: Phase 1 alone retires `:522` and is independently
achievable. `:519` requires Phases 3-8. The plan is gated at Phase 3 precisely so that a NO-GO
is reported as a finding rather than absorbed as churn.

### Research Integration

| Rescope item | Plan-time status | Disposition |
|---|---|---|
| 1. Sequence `KampPrior.lean:522` first | **Unaffected** | Kept verbatim as Phase 1 |
| 2. Formula-first Prop 4.3 probe; "Lemma 3.2(2) CLEARED and Prop 4.2 PROVED both in hand for the first time" | **Half-refuted** — Prop 4.2 is *not* in hand | Re-aimed. The "find out why orphaned" question is **answered** at `Prop43.lean:120-165`; Prop 4.3's Negation case cannot even be *stated* non-vacuously until Prop 4.2 is contentful. Prop 4.3 is deferred behind Prop 4.2, not probed ahead of it. |
| 3. Adopt `VecEA2` / `BracketFormula` as the Def 3.1 object | **Survives** | Adopted. Caveat encoded: the UNFIXABLE ruling is *at the `BracketFormula` level*, i.e. `VecEA2`'s own substrate — adopting `VecEA2` does not by itself escape it; Section 5's `INF` anchors are what escape it. |
| 4. Un-archive `NegationClosureProp42.lean`, do not rewrite | **Refuted twice over** | Dropped. The theorem is vacuous, **and** a byte-equivalent live copy already exists at `EANegationClosure.lean:722` — un-archiving would duplicate a live vacuous theorem. |
| 5. Try `chain_split` against non-interval zones (1,2,4,5) before reaching for FV | **Survives** | Retained as Phase 8's first move, where it is actually reachable. |

### Preserved Assets

Complete and verified; must not regress.

| Component | File | Status | Verified |
|---|---|---|---|
| Lemma 3.2(2) primitive (`chain_split`) | `reports/01_lemma32-anchor-split-probe.lean` | Proved, **axiom-free** | 2026-07-15 (research) |
| Prop 4.2 vacuity refutation | `reports/01_prop42-vacuity-probe.lean` | Builds EXIT 0, axiom-clean | 2026-07-15 (plan time) |
| Def 3.1 / Notation 5.2 object | `Kamp/VecEAFormula.lean` (`VecEA2` :252, `BracketFormula` :128) | Live, sorry-free, 769L | Research |
| Prop 3.5 Until translation | `Kamp/VecEATranslation.lean` (`translateLeft` :515) | Live, sorry-free, 566L | Research |
| Prop 3.5 Since mirror | `Kamp/NfToVecEA.lean` (`translateRight` :413) | Live, sorry-free, 567L | Research |
| Prop 4.2 forward, model-independent | `Kamp/Boneyard/NegationIndep.lean` (`neg_2var_vec_ea_indep` :315, `_correct` :319) | **Contentful forward direction**, green on demand | Plan time |
| Load-bearing bridge arms | `NfMultiAnchorBridge/AggregateHookDischarge.lean`, `AggregateOffDiagK1.lean` (`kampArm_*_k0/_k1`) | Live, load-bearing for `completeness_discrete` | Charter |
| Prior task Phase 1 probe + soundness milestone | `ZoneSeamCrossContextProbe.lean`; commit `3b75fc880` | Green | Charter |

## Postmortem Constraints

Binding on every implementation dispatch. Violations are blockers, not judgment calls.

**Do NOT**:

- **Do NOT accept `∃ v', v'.holds ...` as Prop 4.2, in any file, ever.** It is vacuous —
  machine-refuted at `reports/01_prop42-vacuity-probe.lean`. This exact statement has been
  mis-read as a proved asset at least twice (the `NegationIndep.lean:357-364` fallback; the
  research's item 4). Any Prop 4.2 must carry the `v'`-to-`v` link **and** the `∃ v', ∀ z0 z1`
  quantifier order (see the non-vacuity rule below).
- **Do NOT un-archive `NegationClosureProp42.lean`.** It is vacuous and its live duplicate is
  already at `EANegationClosure.lean:722`. Restoring it adds a second contentless Prop 4.2.
- **Do NOT re-prove `neg_2var_vec_ea_indep`'s backward direction at the `BracketFormula` level
  without Section 5's `INF` anchors.** Ruled UNFIXABLE twice independently (report 18;
  re-confirmed task 305 plan v37 Phase 3, `NegationIndep.lean:346-364`). This is a three-strikes
  target: a third bare attempt is forbidden. The `INF` anchors are what change the problem.
- **Do NOT route through `nf_eval_nf` on the characterization path.** Its quant clause is a
  hyperedge (treewidth `n`, not 1); Lemma 3.2(2) is machine-proved UNPROVABLE about it in-repo
  (`Base.lean:1779`, verdict at `:1801`). Routing through it forces the Feferman-Vaught
  composition theorem for linear orders = novel mathematics = **forbidden by the binding user
  constraint**.
- **Do NOT adopt `NfEFold`.** Its `EAtomDom` (:69) lacks Def 3.1's `beta` slot; its defense
  (:100) is refuted; `nf_eval_efold_k` (:608) is a mis-named non-fold that grows arity by its
  own docstring.
- **Do NOT budget from grep counts.** `grep -c sorry` on the archived files returns ~40; there
  are **4** real tactic-position sorries. Nearly all hits are docstring prose *about* sorry
  status.
- **Do NOT cite `lake build BoneyardArchive` as evidence of health.** It passes **vacuously** —
  `#exit` at line 5 precedes the imports at line 7, so Lean parses an empty header and halts.
- **Do NOT spawn cleanup. Do NOT delete the boneyard.** Any reclamation is surgical declaration
  excision, never file deletion, and only after the faithful path is green.
- **Do NOT cite the companion Rabinovich `.md`.** It is corrupt — drops displayed equations and
  inverts `k != m` to `k = m` at md:199. **PDF pages only**:
  `~/Projects/Literature/sources/rabinovich_2014/Rabinovich_2014_Proof_of_Kamps_Theorem.pdf`.

**MUST preserve**:

- Everything in the Preserved Assets table above, in particular the `kampArm_*_k0/_k1` arms
  (~29% of `NfMultiAnchorBridge`, 11 files / 13,737 lines) that are load-bearing for
  `completeness_discrete`.
- Frozen byte-identity surfaces (`CarrierKv.lean:240-249`; rfl bridges
  `InteriorGateGeneralK.lean:339-351`, `CarrierKv.lean:294-351`) — these sit **inside live
  files**; surgical excision only, never file deletion.
- Full `lake build` green at every phase boundary.

**The non-vacuity acceptance rule** (binding on Phases 3-8; the plan's central safety property):

> A Prop 4.2 / Prop 4.3 statement is **rejected** if its conclusion is provable with its
> hypotheses discharged. Concretely, quantifier order is the crux and both of these are
> **vacuous**:
> - `∀ z0 z1, ∃ v', v'.holds z0 z1` — closed by `⟨tt, tt_holds⟩`.
> - `∀ z0 z1, ∃ v', (v'.holds z0 z1 ↔ ¬v.holds z0 z1)` — **also vacuous**: with `z0 z1` fixed,
>   `¬v.holds z0 z1` is a fixed truth value, so pick `tt` when it is true and `ff` when false.
>
> The **only** acceptable shape hoists `v'` out: `∃ v', ∀ z0 z1, (v'.holds z0 z1 ↔ ¬v.holds z0
> z1)` — `v'` may depend on `v` but **not** on the points. Rabinovich's own statement is stronger
> still (uniform in the model too, since his translation is syntactic); `neg_2var_vec_ea_indep`
> already has this stronger shape structurally, being a function of `v` alone.
>
> **Every new Prop 4.2-shaped declaration MUST be accompanied by a failed-vacuity check**: state
> the conclusion with the hypotheses removed and confirm it does **not** compile. Record the
> result in the phase's verification block.

**Design decisions are SETTLED** (do not re-open without a concrete counterexample):

- **`VecEA2` / `BracketFormula` is the Def 3.1 / Notation 5.2 object.** Not `EAtomDom`, not
  `IntervalPattern` (which lacks the pinned endpoints Notation 5.2 requires).
- **Lemma 3.2(2) is a THEOREM of Rabinovich's Def 3.1 and a NON-THEOREM of `nf_eval_nf`.** Both
  directions machine-checked. The original charter stated this **inverted**; the inversion must
  not be propagated.
- **`KampPrior.lean:522` is mathematically unreachable but must still be retired**, because
  `sorryAx` is tracked per-declaration, not per-path.
- **`Kamp/Prop43.lean` and `Kamp/Boneyard/Prop43.lean` are NOT two attempts at Prop 4.3.**
  `Boneyard/Prop43.lean` imports `NfToVecEA` and is `nf_succ_char_formula` NF-side machinery —
  mis-named. Only `Kamp/Prop43.lean` is Prop 4.3, it is deliberately off-path by its own
  docstring (:28-29), and it is sorry-free but carries only the trivial `atomAt`/`ltAt` cases.
  The "attempted twice, orphaned twice" framing is wrong and must not drive a "third attempt".

**Liveness rule for this tree** (binding):

> Directory location, absence of `#exit`, and a green scoped build are **all unreliable**
> liveness signals. Only reachability from `Theories/Bimodal.lean` decides what CI protects. Any
> phase that un-archives or adds a file MUST verify with a scoped `lake build` of the **real
> module path**, plus `#print axioms`, and MUST confirm reachability from the root before
> claiming the result is CI-protected.

**Known traps**:

1. `endInterval_correct` (`EndIntervalConsumerK.lean:268`) is arity-1 `charF` machinery, **not**
   arity-4 `charFib` — report 06's dead-leaf list mis-buckets it.
2. `ExistsForallNF.lean`'s `VEF.closed_conj` / `closed_ex` / `closed_disj` are **advertised in
   the docstring and never defined**. Its zero-sorry count reflects unstated theorems.
3. 89 in-code citations in `SharedWitness.lean` dangle.
4. `literature-search.sh` throws fts5 syntax errors on period-containing queries (avoid
   `Prop 4.2` as a literal query).

## Goals & Non-Goals

- **Goals**: Retire `KampPrior.lean:522` and `:519`; establish a **contentful** Prop 4.2 by
  transcribing Rabinovich Section 5 (pp.7-11); leave a durable in-tree guard against re-adopting
  the vacuous statement; full `lake build` green with no new axioms.
- **Non-Goals**: Proving Feferman-Vaught composition for linear orders (forbidden — novel
  mathematics). Re-transcribing sections 3-4 (the objects and Prop 3.5 are live and sorry-free).
  Boneyard cleanup or dead-code reclamation. A uniform (model-independent) Prop 4.3 — its three
  blockers stand documented at `Prop43.lean:136-153` and are explicitly out of scope.

## Risks & Mitigations

- **Risk**: Section 5's `INF` anchors do not in fact dissolve the B.1 per-model-witness gap, and
  a contentful Prop 4.2 is unreachable in this encoding.
  **Mitigation**: Phase 3 is an explicit GO/NO-GO gate with a written kill criterion, placed
  *before* any Section 5 investment. A NO-GO is a reportable finding, not a failure.
- **Risk**: The vacuity finding invalidates a **user-approved** rescope, so the approved scope no
  longer matches reality.
  **Mitigation**: Surfaced in the handoff `blockers[]` for orchestrator/user adjudication before
  Phase 3 commits to Section 5. Phases 1-2 are safe and valuable under **either** resolution.
- **Risk**: Phases 4-7 (Section 5 transcription) exceed one dispatch each.
  **Mitigation**: Each is scoped to one printed lemma with a printed proof and its own scoped
  build target. Phase 4 is the canary: if it overruns, Phases 5-7 are re-split before dispatch.
- **Risk**: A dispatch "discharges" an obligation with a vacuous witness, repeating the lineage's
  failure.
  **Mitigation**: The non-vacuity acceptance rule mandates a failed-vacuity check per new
  Prop 4.2-shaped declaration, recorded in the phase verification block.
- **Risk**: `:519`'s in-code note (`KampPrior.lean:507-518`) says "Do NOT discharge here" and
  assigns it to task 358.
  **Mitigation**: Phase 8 re-reads that note against a contentful Prop 4.2 before acting; if the
  gating rationale still stands, Phase 8 reports rather than forces.

## Implementation Phases

**Dependency Analysis**:

| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1, 2 | -- |
| 2 | 3 | 2 |
| 3 | 4 | 3 |
| 4 | 5 | 4 |
| 5 | 6 | 5 |
| 6 | 7 | 6 |
| 7 | 8 | 1, 7 |

Phases within the same wave can execute in parallel. Phases 1 and 2 are independent (Phase 1
touches `KampPrior.lean` only; Phase 2 touches `EANegationClosure.lean` / `NavigatedSpine.lean`
docstrings and adds one new file) — territory is disjoint.

### Phase 1: Retire KampPrior.lean:522 by declaration restructuring [COMPLETED]

- **Goal:** Remove the `n >= 2` sorry at `KampPrior.lean:522` without proving the general
  `n >= 2` case, by restructuring so the unreachable arm is not inside
  `nf_nvar_exist_all_depths`. This is the one DoD item obtainable independently of all encoding
  work, and it yields the first green commit.
- **Why it is retirable without a proof:** the arm is genuinely unreachable — the recursion
  resets arity to 1 (`KampPrior.lean:407`) and the live entry from
  `nf_characterizable_temporal_prior` (:565) is `n = 1`. The in-code comment at `:521` is correct
  as mathematics. It is only *axiom tracking* that makes it matter: both sorries sit in the
  single `noncomputable def nf_nvar_exist_all_depths`, so `sorryAx` enters that declaration's
  proof term regardless of reachability.
- **Tasks:**
  - [x] Read `KampPrior.lean:346-362` and `:503-523` and confirm the `| n + 2 =>` arm is
        unreachable from every live call site (re-verify; do not inherit). *(Re-verified at
        implementation time by tree-wide grep: the only live code call sites are the
        `ih_exist_1` self-call :407 (`k 1`), and :597/:606 via `_fn`/`_fn_correct` (both `k 1`).
        Every other tree-wide mention is docstring prose. The recursion resets arity to 1 rather
        than growing it, so no call chain reaches `n >= 2`.)*
  - [x] Restructure so the unreachable arm leaves the declaration. Preferred: restrict the
        definition's domain to the reachable arities. Acceptable alternative: split the
        declaration so the `n >= 2` case is a separate, unused declaration. Choose the option
        that does **not** disturb `:519`'s arm — `:519` is Phase 8's target, not this phase's.
        *(Took the preferred option: added an `(hn : n <= 1)` domain parameter. Note: the
        `| _n + 2 =>` arm remains syntactically present but is discharged by `absurd hn (by
        omega)` — the domain restriction — not by a proof of the `n >= 2` case. `:519`'s arm,
        which sits in the inner `match k, sub_nf with` split under `n = 1`, was not touched.)*
  - [x] Update all call sites (`nf_nvar_exist_all_depths_fn` :525, `_fn_correct` :533, and the
        `ih_exist_1` self-call at :407) to the restructured signature. *(All updated, plus the
        two `_fn`/`_fn_correct` uses at :597/:606, each passing `(by omega)` at `n = 1`.)*
  - [x] Confirm `:519` still stands as the **only** remaining sorry in the declaration.
        *(Confirmed: exactly one tactic-position sorry file-wide, now at `:520`, inside the
        declaration spanning `:346-531`. Counted by tactic-position regex, not naive
        `grep -c sorry`.)*
- **Verification:** all four PASSED (2026-07-15):
  - `lake build Bimodal.Metalogic.WeakCanonical.Kamp.KampPrior` -> EXIT 0. PASS (1052 jobs).
  - `#print axioms` on `nf_nvar_exist_all_depths` -> still carries `sorryAx` (from `:519` alone);
    record the axiom set verbatim as the Phase 8 baseline. PASS. **Phase 8 baseline, verbatim**:
    `{propext, sorryAx, Classical.choice, Quot.sound}`. Phase 8's success criterion is the
    disappearance of `sorryAx` from exactly this set, leaving
    `{propext, Classical.choice, Quot.sound}`.
  - Full `lake build` -> EXIT 0 (no regression at any consumer). PASS (1761 jobs).
  - Grep confirms exactly one `sorry` remains in the declaration. PASS (one tactic-position
    sorry file-wide, at `:520`).
- **Green commit:** `task 377 phase 1: retire KampPrior n>=2 arm by restructuring`
- **Estimated output:** ~100-200 lines changed.
- **Done when:** `:522`'s sorry no longer exists, full build is green, and the only sorry left in
  `nf_nvar_exist_all_depths` is the `k>=2` residual formerly at `:519`.
- **Timing:** one dispatch
- **Depends on:** none

### Phase 2: Land the vacuity guard and annotate the live vacuous declarations [COMPLETED]

- **Goal:** Make the vacuity finding permanent and impossible to re-misread. It has been
  mis-read as a proved asset at least twice; without an in-tree guard it will be mis-read a
  third time.
- **Tasks:**
  - [x] Land `reports/01_prop42-vacuity-probe.lean` into the live tree as
        `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/Prop42Vacuity.lean`, reachable from
        `Theories/Bimodal.lean` so CI protects it (per the Liveness Rule — a green scoped build
        is **not** sufficient). Keep `prop42_conclusion_is_vacuous` with a docstring stating
        exactly what it refutes and citing Rabinovich Prop 4.2 p.6 for the contentful target.
        *(Landed. Probe proof body preserved verbatim. Import edge landed in
        `NfMultiAnchorBridge.lean:5`, following that file's documented import-edge idiom;
        cycle-free — Prop42Vacuity imports only `Kamp.VecEAFormula`, already in that file's
        transitive closure. The guard is a leaf: nothing consumes it, so the edge is inert to
        the build beyond forcing compilation.)*
  - [x] Annotate the **live** `neg_2var_vec_ea` (`EANegationClosure.lean:722`) with a warning
        docstring: its conclusion is vacuous, it is **not** Rabinovich's Prop 4.2 (p.6), and
        `Prop42Vacuity.lean` holds the machine refutation. Do **not** delete or weaken it — it is
        consumed live and deletion is out of scope. *(Annotated in place; theorem statement and
        proof untouched. Docstring explicitly pre-empts the sorry-free/axiom-clean/green-build
        rebuttal.)*
  - [x] Annotate `reflatten_neg_step` (`NavigatedSpine.lean:178-184`), whose docstring currently
        claims it is discharged by *"the LANDED Prop 4.2 closure ... the hardest half, already
        proven"* (:174-176). Correct that claim in place: it re-exports a vacuous statement.
        *(Corrected. The old claim is quoted verbatim in the new docstring and refuted, so the
        correction is legible to a reader who encountered the old text.)*
  - [x] Cross-reference `Kamp/Prop43.lean:125-129` and
        `Kamp/Boneyard/NegationIndep.lean:357-364`, which independently recorded this and were
        never acted on. *(Both annotated with pointers to the guard. NegationIndep's fallback
        paragraph is retained as historical record and marked INVALID above itself, naming its
        load-bearing error: "introduces no new sorry or axiom" ⟹ "is sufficient".)*
- **Verification:**
  - `lake build Bimodal.Metalogic.WeakCanonical.Kamp.Prop42Vacuity` -> EXIT 0. PASS (982 jobs).
  - `#print axioms prop42_conclusion_is_vacuous` -> `[propext, ...]`, **no** `sorryAx`. PASS —
    `{propext, Classical.choice, Quot.sound}` via `lean_verify`. No `sorryAx`.
  - Reachability from `Theories/Bimodal.lean` confirmed by import-graph walk (not by scoped
    build). PASS — BFS over `import Bimodal.*` edges (honoring `#exit` truncation) resolves the
    chain root -> `Bimodal.Bimodal` -> `Metalogic.Metalogic` -> `BXCanonical.BXCanonical` ->
    `BXCanonical.Completeness` -> `Chronicle.ChronicleToCountermodel` ->
    `IntegerModel.GoodStructuresModelSurgery` -> `WeakCanonical.PriorExpressiveness` ->
    `Kamp.KampPrior` -> `Kamp.NfMultiAnchorBridge` -> `Kamp.Prop42Vacuity`. Reachable-module
    count moved 234 -> 235, confirming the edge added exactly this module. Walker was validated
    against known-live (`EANegationClosure`, `NavigatedSpine`: REACHABLE) and known-dead
    (`Boneyard.NegationIndep`: NOT REACHABLE) controls before use.
  - Full `lake build` -> EXIT 0. PASS (1762 jobs, up exactly 1 from Phase 1's 1761; zero
    errors, no consumer regression).
- **Green commit:** `task 377 phase 2: land Prop 4.2 vacuity guard; annotate live vacuous decls`
- **Estimated output:** ~120-200 lines (one new file ~40L + docstring corrections).
- **Done when:** the refutation is live and CI-protected, and every live declaration presenting a
  vacuous `∃ v', v'.holds` as Prop 4.2 carries a correcting annotation.
- **Timing:** one dispatch
- **Depends on:** none

### Phase 3: State contentful Prop 4.2 and decide the INF route [COMPLETED]

**VERDICT: GO** (resolved 2026-07-15, session `sess_1784156166_ad146c`). All four GO criteria
pass; neither NO-GO condition is triggered. Evidence below; artifact
`Theories/Bimodal/Metalogic/WeakCanonical/Kamp/Prop42Contentful.lean` (CI-reachable via the
import edge in `NfMultiAnchorBridge.lean`). Full `lake build` EXIT 0, **1763 jobs** — up exactly
1 from Phase 2's 1762, confirming the edge added exactly this module.

| GO criterion | Result | Evidence |
|---|---|---|
| 1. Stated in hoisted-`∃ v'` shape | **PASS** | `Prop42Contentful` (`Prop42Contentful.lean`) — `∃ v', ∀ z0 z1, z0 < z1 → (v'.holds ↔ ¬v.holds)`; compiles |
| 2. Failed-vacuity check confirms non-vacuity | **PASS** | Probe `reports/02_prop42-contentful-failed-vacuity-probe.lean` does **not** compile; its control (vacuous shape, same all-`⊤` witness) **does**. Verbatim failure recorded in `.orchestrator-handoff.json` |
| 3. Both endpoint cases sorry-free | **PASS** | `endpointLeftNegBlock_sound`, `endpointRightNegBlock_sound`, plus complete instance `prop42_contentful_endpoint_instance`; all `[propext, Classical.choice, Quot.sound]`, no `sorryAx` |
| 4. Bracket case mapped to PDF pages, `INF` identified as witness-pinning mechanism | **PASS** | 8-row dependency table (pp.8-11) in the module docstring; mechanism identified at **p.11** |

**The mechanism (criterion 4), stated precisely.** PDF p.11 prints, for `(z0,z1)` non-empty,
`[α₀,…,αₙ₊₁](z0,z1) ⇔ (∀z)^{<z1}_{>z0}(⋁Aᵢ ∨ ⋁Bᵢ)` **and** the same with `(∃z)`. Both
quantifiers agree because the `Aᵢ`/`Bᵢ` family (p.10) is exhaustive relative to an *arbitrary
fixed* `z` — every witness is below `z` (`Aᵢ`) or equal to it (`Bᵢ`). So negating at a fixed `z`
turns the per-model existential arrangement into a conjunction `⋀¬Aᵢ ∧ ⋀¬Bᵢ` over **fixed**
sub-intervals `(z0,z)` and `(z,z1)`, and the IH applies to them. eq (5.3) supplies that `z` as
`INF^{¬β₁}`, making it definable; footnote 4 (p.10) waives uniqueness. This is exactly the B.1
gap's complaint ("the bracket witness `w₀` could be `> r₀`") dissolved: one never needs to know
where the witnesses sit relative to `r₀`, because the decomposition holds at whatever `z` is
named. Report 07's "anchor factory, not a model filter" reading is corroborated.

**Neither NO-GO condition triggered.** (a) `Prop42Contentful` is formulated over `VecEA2`
carrying **no hypothesis at all**; the eventual proof needs only Dedekind completeness, which
p.6 Prop 4.2 explicitly carries. (b) `INF` does pin the arrangement, per p.11 above.

**FINDING — task 5 of this phase resolves AGAINST the spec's assumption.** `HasAttainedINF`
(`PriorINF.lean:202`) is **not** the faithful carrier for eq (5.2) / eq (5.3). It concludes
`… ∧ temporal_truth M atomMap r0 P`, **dropping** the `K⁺` disjunct. The faithful carrier is
**`HasDefinableINF`** (`PriorINF.lean:108`), which concludes
`… ∧ (temporal_truth M atomMap r0 P ∨ kplus M atomMap P r0)` — eq (5.2)'s `(P₁(r₀) ∨ K⁺(P₁)(r₀))`
verbatim. `HasAttainedINF` is sound to *use* (`toHasDefinableINF` `:215`; `prior_hasAttainedINF`
`:224` — "the K⁺ case never arises" on Prior structures), but assuming it in a transcription
assumes strictly more than Rabinovich and silently drops the `K⁺` branch that p.8's
`Subcase r₀ = z₀` and p.10's eq (5.3) both explicitly carry. **Phases 4-7 must transcribe
against `HasDefinableINF`**, discharging via `prior_hasAttainedINF` only at the live-path
boundary. Neither carrier covers p.8's `Subcase r₀ = z₀` (both require `z0 < r0`) — correctly
so: the paper handles it at the formula level via the disjunct `K⁺(P₁)(z₀) ∧ Oₙ(P₂,…,Pₙ,z₀,z₁)`
(p.8 item 2), not via the `INF` hypothesis.

**Residual risk carried into Phase 4** (criterion 4 is an evidentiary/mapping criterion — the
mechanism is corroborated by the paper's printed text, *not* yet formalized): the p.11 route
depends on the `Aᵢ`/`Bᵢ` exhaustiveness biconditional, which is itself a non-trivial
transcription obligation and requires `BracketFormula` to support a split-at-`z` decomposition.
Phase 4 is the sizing canary for exactly this.

**Original phase spec follows.**

- **THIS PHASE IS THE PLAN'S GO/NO-GO GATE.** Phases 4-8 do not dispatch until it resolves GO.
- **Goal:** Write down the **target** — the non-vacuous Prop 4.2 — and decide, on evidence,
  whether Rabinovich's `INF` anchors dissolve the B.1 gap. **This gate exists so that a NO-GO is
  reported rather than absorbed as churn.** No Section 5 investment happens before it resolves.
- **The B.1 gap, stated precisely** (`NegationIndep.lean:341-345`): *"V-bracket formulas are
  existentially quantified, but the backward direction requires universal quantification over all
  possible bracket witness arrangements which vary per model. The IH gives negation on a specific
  sub-interval `(r0, z1)` but the bracket witness `w_0` could be `> r0`, giving a different
  sub-interval `(w_0, z1)`."*
- **The hypothesis under test:** this gap is an artifact of leaving witnesses existential.
  Rabinovich does not: eq (5.2) p.8 defines `r_0 := inf{z ∈ (z_0,z_1) | P_1(z)}` and eq (5.3)
  p.10 defines `r_0 := inf{z ∈ (z_0,z_1) | ¬beta_1(z)}`, each **by an explicit formula**, making
  the arrangement *definable* rather than per-model-arbitrary. Footnote 4 (p.10) states *"We will
  use only existence and will not use uniqueness"* — a real scope reduction. This corroborates
  report 07's "Dedekind completeness is an ANCHOR FACTORY, not a model filter".
- **Tasks:**
  - [ ] Read PDF pp.7-11 directly (PDF only; the `.md` is corrupt). Establish Section 5's
        dependency order before writing any Lean.
  - [ ] State `prop42_contentful` in the **only** acceptable shape per the non-vacuity rule:
        `∃ v', ∀ z0 z1, z0 < z1 → (v'.holds M atomMap z0 z1 ↔ ¬v.holds M atomMap z0 z1)`,
        with `v'` a function of `v` alone. Prefer strengthening
        `neg_2var_vec_ea_indep` (`NegationIndep.lean:315`), which **already has this shape
        structurally** and whose forward direction (`_correct` :319) is **contentful and proved**.
        Do not restate it in the weaker model-dependent form.
  - [ ] Run the mandatory **failed-vacuity check**: state `prop42_contentful`'s conclusion with
        `h_neg` removed and confirm it does **not** compile. Record the failure verbatim.
  - [ ] Prove the two endpoint cases (`¬endpointLeft(z_0)`, `¬endpointRight(z_1)`) in the
        contentful shape. These are the de Morgan cases that need no `INF` machinery and are the
        cheapest evidence that the shape is workable.
  - [ ] Map exactly which Section 5 results the remaining bracket case consumes, and confirm
        `HasAttainedINF` (`NegationIndep.lean:94`) is the right hypothesis carrier for eq (5.2) /
        eq (5.3).
- **Decision point (written kill criterion):**
  - **GO** if: `prop42_contentful` is stated in the hoisted-`∃ v'` shape, the failed-vacuity
    check confirms it is non-vacuous, both endpoint cases are proved sorry-free, and the bracket
    case's Section 5 dependency chain is mapped to specific PDF pages with `INF` identified as
    the witness-pinning mechanism. -> Proceed to Phase 4.
  - **NO-GO** if: the contentful statement cannot be formulated over `VecEA2` without a
    hypothesis absent from Rabinovich (p.4 Lemma 3.2 carries **no** completeness hypothesis;
    p.6 Prop 4.2 carries only Dedekind completeness), **or** `INF` provably does not pin the
    arrangement the B.1 gap needs. -> **Stop. Do not attempt Section 5.** Report: the faithful
    object cannot support Rabinovich's own Prop 4.2, which means `VecEA2` is not faithful despite
    matching Notation 5.2's shape — a finding that ends the task as scoped and supersedes the
    rescope. Phases 1-2 remain landed and green.
  - **Three-strikes guard:** if the endpoint cases are not sorry-free within this single
    dispatch, that is a NO-GO signal, not grounds for a second dispatch on the same target.
- **Verification:**
  - Scoped `lake build` of the new module -> EXIT 0; `#print axioms` on each new declaration.
  - Failed-vacuity check recorded (the non-compiling statement, verbatim).
  - Full `lake build` -> EXIT 0.
- **Green commit:** `task 377 phase 3: state contentful Prop 4.2; endpoint cases; INF route decision`
- **Estimated output:** ~150-300 lines.
- **Done when:** the GO/NO-GO decision is recorded with its evidence, and on GO the contentful
  statement plus both endpoint cases are sorry-free.
- **Timing:** one dispatch
- **Depends on:** 2

### Phase 4: Transcribe Lemma 5.3 (O_n, all beta_i True) [PARTIAL]

**CANARY VERDICT: the phase does NOT fit one dispatch as scoped. Phases 5-7 MUST be re-split
before dispatch**, per this phase's own sizing-canary clause. Resolved 2026-07-15, session
`sess_1784156166_ad146c`. Artifact
`Theories/Bimodal/Metalogic/WeakCanonical/Kamp/Lemma53.lean` (CI-reachable via the import edge in
`NfMultiAnchorBridge.lean`). Full `lake build` EXIT 0, **1764 jobs** — up exactly 1 from Phase
3's 1763. Import-graph walk: 237 reachable modules, up exactly 1 from 236; walker re-validated
against known-live (`Prop42Contentful`, `EANegationClosure`: REACHABLE) and known-dead
(`Boneyard.NegationIndep`: NOT REACHABLE) controls.

**Status is `[PARTIAL]`, not `[COMPLETED]`: the Done-when is objectively not met.** Lemma 5.3 is
**stated** with a p.8 citation but is **not proved sorry-free** — one documented strategic sorry
sits at the `n >= 2` arm, the eq (5.2) boundary the phase spec directed this dispatch to stop at.
Under-claiming here is deliberate: this task exists because "green build + axiom-clean" was once
allowed to stand in for "the statement says something". The orchestrator may promote this to
`[COMPLETED]` on the strategic-sorry exception; that is an adjudication, not this dispatch's call.

**Landed sorry-free and axiom-clean** (`{propext, Classical.choice, Quot.sound}`, no `sorryAx`):
`TemporalPred.top_eval_at`, `allTopBracket` + `allTopBracket_holds_succ`,
`allTopBracket_zero_holds`, `kplus_formula_correct`, `O_zero` + `O_zero_correct`, `O_one` +
`lemma53_basis` (the printed Basis), `hasDefinableINF_excludes_kplus`.

**FINDING — the Phase 3 `spec_correction` directive is itself machine-refuted.** Phase 3 bound
Phases 4-7 to transcribe against `HasDefinableINF` (`PriorINF.lean:108`), correcting
`HasAttainedINF`. That correction moved in the right direction but did not go far enough:
`HasDefinableINF` is **still** strictly stronger than the Dedekind completeness Lemma 5.3
assumes, and it **deletes the paper's disjunct (2)**. `hasDefinableINF_excludes_kplus`
(`Lemma53.lean`) proves it: `HasDefinableINF` forbids `K⁺(P₁)(z₀)` outright whenever `P₁` occurs
in `(z₀,z₁)` — exactly p.8's `Subcase r₀ = z₀`, exactly what disjunct (2)
`K⁺(P₁)(z₀) ∧ Oₙ(P₂,…,Pₙ,z₀,z₁)` exists to handle. Counterexample: on `ℝ` (Dedekind complete)
with `P₁ = {x | x > 0}` and `z₀ = 0`, `inf{z ∈ (0,1) | P₁(z)} = 0 = z₀`, so `first_occ` has no
`r₀` to return and `HasDefinableINF` is false — yet the paper handles this structure fine, via
disjunct (2). Phase 3's note that neither carrier covers `Subcase r₀ = z₀` "correctly so,
because the paper handles it at the FORMULA level" is the error: that reasoning holds only if the
carrier is not *assumed*. Assuming it absorbs the case instead of letting the formula handle it.
**Phase 5 must build the faithful disjunctive carrier**
`K⁺(P₁)(z₀) ∨ (∃r₀, z₀ < r₀ < z₁ ∧ (∀y)^{<r₀}_{>z₀}¬P₁(y) ∧ (P₁(r₀) ∨ K⁺(P₁)(r₀)))`, of which
`HasDefinableINF` is the right disjunct alone. This is the third instance of the same
unnoticed-strengthening pattern in this task's history; it was caught only because the phase
spec's own non-vacuity rule was applied to the *hypothesis* and not just the conclusion.

- **Goal:** Transcribe Rabinovich Lemma 5.3 (PDF p.8) — the induction on `n` for `O_n`, stated
  for the instance where `alpha_0`, `alpha_n` and all `beta_i` are equivalent to `True`. This is
  Section 5's base machinery and the **canary** for Phases 5-7's sizing.
- **Tasks:**
  - [x] Read PDF p.8 (Notation 5.2 and Lemma 5.3) directly. *(Read via the PDF `pages`
        parameter; the corrupt `.md` was never consulted. All citations are by PDF page.)*
  - [x] Transcribe Lemma 5.3's statement against `BracketFormula` / `VecEA2`, following the
        paper's Case 1 / Case 2 split. Rabinovich's `True`-instantiation idiom for unused slots
        is the intended primitive — use `TemporalPred.top`, matching the live
        `BracketFormula.trivial` (`VecEAFormula.lean:305`). *(Done: `allTopBracket` is Notation
        5.2 with every `beta_i` = `TemporalPred.top`; `allTopBracket_holds_succ` proves the
        vacuous segment clauses collapse, so the object is demonstrably the paper's LHS rather
        than asserted to be it. Deviation: `O_n` is a `VVecEA2`, not a `VBracketFormula` —
        forced by disjunct (2), which conjoins the endpoint predicate `K⁺(P₁)` at `z_0`.)*
  - [ ] Prove by induction on `n`, following the printed proof step-by-step. Case 2 needs
        `r_0 := inf{z ∈ (z_0,z_1) | P_1(z)}`; if eq (5.2) is required here rather than in Phase 5,
        stop at that boundary and hand it to Phase 5 rather than inlining an `INF` construction.
        *(deviation: deferred to Phase 5 at the eq (5.2) boundary, as the spec directs. eq (5.2)
        IS required here: it sits in disjunct (3) of the inductive step itself, and disjunct (2)
        is the `r_0 = z_0` subcase of the same Case 2 construction — so BOTH non-trivial
        disjuncts consume it. `n = 0` and `n = 1` (the printed Basis) are discharged sorry-free;
        the strategic sorry is isolated to the `n >= 2` arm.)*
  - [x] Give every new declaration a page-cited source correspondence (`Rabinovich 2014, Lemma
        5.3, PDF p.8`). *(Every declaration carries one.)*
- **Verification:** all PASSED except the sorry-free criterion (2026-07-15):
  - `lake build Bimodal.Metalogic.WeakCanonical.Kamp.Lemma53` -> EXIT 0. PASS (984 jobs).
  - `#print axioms` on each new declaration -> all seven substantive declarations are
    `{propext, Classical.choice, Quot.sound}`, **no** `sorryAx`. PASS. `lemma53` itself carries
    `{propext, sorryAx, Classical.choice, Quot.sound}` from the one strategic sorry. EXPECTED.
  - Full `lake build` -> EXIT 0. PASS (1764 jobs, up exactly 1 from Phase 3's 1763; no consumer
    regression).
  - Tactic-position sorry census: exactly **one**, at `Lemma53.lean:339` (`lemma53`'s `n >= 2`
    arm). The other three `sorry` hits in the file are docstring prose — the trap the plan's
    "Do NOT budget from grep counts" constraint names.
  - Failed-vacuity check (mandated by the non-vacuity rule): PASS, both halves executed.
    Control (`reports/03_lemma53-failed-vacuity-probe.lean`, per-point `∀ M atomMap z0 z1, ∃ O`)
    **compiles** from no hypotheses. The hoisted shape `∃ O, ∀ M atomMap z0 z1` — `lemma53`'s
    actual shape — **fails** to compile by the same trick, exit 1, verbatim failure recorded in
    the probe.
- **Green commit:** `task 377 phase 4: transcribe Lemma 5.3 (p.8)`
- **Estimated output:** ~200-350 lines. *(Actual: 341 lines of new Lean + 96-line probe. Within
  the estimate by LINE count — but the estimate measured the wrong thing: see the canary verdict.
  The line count is low precisely because the phase stopped at its boundary.)*
- **Done when:** Lemma 5.3 is stated and proved sorry-free with a p.8 citation. *(NOT met —
  stated, not proved. See the canary verdict.)*
- **Sizing canary:** if this phase overruns one dispatch, Phases 5-7 MUST be re-split before
  dispatch rather than attempted as written. **TRIGGERED — see the canary verdict above.**
- **Timing:** one dispatch
- **Depends on:** 3 (GO)

### Phase 5: Transcribe eq (5.2) INF anchor and Cor 5.4 [NOT STARTED]

- **Goal:** Transcribe the anchor factory — eq (5.2) `INF(z_0, r_0, z_1, P_1)` (PDF p.8) — and
  Cor 5.4 (PDF p.9). This is the phase that supplies the mechanism Phase 3 identified as
  dissolving the B.1 gap.
- **Tasks:**
  - [ ] Read PDF pp.8-9 directly.
  - [ ] Transcribe eq (5.2) as an explicit defining formula, not as a `Classical.choice` witness
        — the point of the paper's construction is **definability**. Exploit footnote 4 (p.10):
        existence only, **no uniqueness** obligation.
  - [ ] Reconcile with `Kamp/PriorINF.lean` (research marks it PARTIAL — live file exists,
        correspondence UNVERIFIED). Verify the correspondence rather than assuming it; reuse if
        it matches, and record the delta if it does not.
  - [ ] Transcribe Cor 5.4 (p.9): `F_n := alpha_n`, `F_{i-1} := alpha_{i-1} ∧ (beta_i Until
        F_i)`, plus the Since mirror (item 2 of the corollary).
- **Verification:** scoped `lake build` -> EXIT 0; `#print axioms`; full `lake build` green;
  confirm eq (5.2) is a formula, not a choice term.
- **Green commit:** `task 377 phase 5: transcribe eq (5.2) INF anchor and Cor 5.4 (pp.8-9)`
- **Estimated output:** ~200-350 lines.
- **Done when:** eq (5.2) and Cor 5.4 are transcribed sorry-free with page-cited correspondences,
  and the `PriorINF.lean` correspondence is either verified or its delta recorded.
- **Timing:** one dispatch
- **Depends on:** 4

### Phase 6: Transcribe Lemma 5.1 Cases 1-3 and eq (5.3) [NOT STARTED]

- **Goal:** Transcribe Lemma 5.1 proper (PDF pp.9-10) — that `¬[alpha_0,...,alpha_n](z_0,z_1)` is
  a `∨exists-forall` formula — through its three cases, including Figure 1 (p.10) and eq (5.3)
  `INF^{¬beta_1}`. This is the heart of Prop 4.2.
- **Tasks:**
  - [ ] Read PDF pp.9-10 directly, including Figure 1.
  - [ ] Transcribe Cases 1-3 in the paper's order, consuming Phase 5's eq (5.2) and Cor 5.4.
  - [ ] Transcribe eq (5.3) `INF^{¬beta_1}` for Case 3.
  - [ ] Literature-fidelity rule applies: follow the printed proof step-by-step. Do **not** use
        `simp`/`omega`/`aesop` to bypass a step the paper handles explicitly; do **not** abandon
        the paper's approach after a single tactic failure.
- **Verification:** scoped `lake build` -> EXIT 0; `#print axioms`; full `lake build` green.
- **Green commit:** `task 377 phase 6: transcribe Lemma 5.1 cases 1-3 and eq (5.3) (pp.9-10)`
- **Estimated output:** ~300-450 lines.
- **Done when:** Lemma 5.1 is proved sorry-free with page-cited correspondences for all three
  cases.
- **Timing:** one dispatch
- **Depends on:** 5

### Phase 7: Close contentful Prop 4.2 via the pp.10-11 induction [NOT STARTED]

- **Goal:** Transcribe the `A_i^-/A_i^+/A_i` and `B_i^-/B_i^+/B_i` decomposition and the closing
  induction (PDF pp.10-11), discharging `prop42_contentful` from Phase 3. **This is the phase
  that makes Prop 4.2 real.**
- **Tasks:**
  - [ ] Read PDF pp.10-11 directly, including the two displayed equivalences (p.11) and items
        (a)-(e).
  - [ ] Transcribe the `A_i`/`B_i` families. The live
        `BracketFormula.leftPart` / `rightPart` (`VecEAFormula.lean:352+`, documented as "the
        A_i^- / A_i^+ decomposition ... Rabinovich p.10") already exist — verify the
        correspondence and reuse rather than re-deriving.
  - [ ] Close the induction and discharge `prop42_contentful`.
  - [ ] Re-run the **failed-vacuity check** from Phase 3 against the *final* statement and
        confirm it still fails to compile without `h_neg`. A contentful statement that silently
        drifted to a vacuous one during transcription is the exact failure this plan exists to
        prevent.
- **Verification:**
  - scoped `lake build` -> EXIT 0; `#print axioms prop42_contentful` -> exactly
    `{propext, Classical.choice, Quot.sound}`, **no** `sorryAx`.
  - Failed-vacuity check re-run and recorded.
  - Full `lake build` -> EXIT 0.
- **Green commit:** `task 377 phase 7: close contentful Prop 4.2 (pp.10-11 induction)`
- **Estimated output:** ~300-450 lines.
- **Done when:** `prop42_contentful` is proved sorry-free and axiom-clean, and the failed-vacuity
  check confirms it is non-vacuous. **This is the milestone the whole faithful path has been
  missing since the `NegationIndep.lean:357-364` fallback.**
- **Timing:** one dispatch
- **Depends on:** 6

### Phase 8: Retire KampPrior.lean:519 [NOT STARTED]

- **Goal:** Retire the `k >= 2` residual at `KampPrior.lean:519` using the contentful Prop 4.2,
  completing the DoD.
- **Tasks:**
  - [ ] Re-read `KampPrior.lean:507-518` first. Its note gates this residual on the Track-A
        `P17-frozen-interface-gap` and says *"Do NOT discharge here ... this residual is 358
        territory"*. Re-evaluate that gating **against a contentful Prop 4.2**, which did not
        exist when the note was written. If the gating rationale still stands on its own terms,
        **report it rather than forcing a discharge**.
  - [ ] Try `chain_split` (`reports/01_lemma32-anchor-split-probe.lean`) against the non-interval
        zones (1,2,4,5) **before** anything else. It is itself a composition/gluing theorem at a
        shared anchor over a bare `LinearOrder` — structurally the same shape the archived path
        wanted from Feferman-Vaught — and it is **axiom-free**. Interval zone 3 already discharges
        from Since/Until witnesses.
  - [ ] If `chain_split` + contentful Prop 4.2 close the zones, discharge `:519`. **If they do
        not, STOP** — do not reach for the Feferman-Vaught literature theorem. That is novel
        mathematics and is forbidden by the binding user constraint. Report the residual instead.
  - [ ] Confirm `sorryAx` has left `completeness_discrete`'s closure (both `:519` and `:522` are
        required; Phase 1 supplied `:522`).
- **Verification:**
  - `#print axioms completeness_discrete` (`Metalogic/BXCanonical/Completeness.lean:276`) ->
    exactly `{propext, Classical.choice, Quot.sound}`, **no** `sorryAx`. This is the DoD's
    terminal check.
  - `#print axioms` on the full goal chain: `nf_nvar_exist_all_depths` ->
    `nf_characterizable_temporal_prior` -> `kamp_prior_expressive_completeness` ->
    `US_expressively_complete_over_prior`.
  - Full `lake build` -> EXIT 0.
- **Green commit:** `task 377 phase 8: retire KampPrior:519; complete implementation`
- **Estimated output:** ~200-400 lines.
- **Done when:** `:519` is retired, `completeness_discrete` is `sorryAx`-free, and the full build
  is green — **or** a bounded, evidenced report of why the residual stands, with no FV attempt.
- **Timing:** one dispatch
- **Depends on:** 1, 7

## Testing & Validation

- [ ] Full `lake build` -> EXIT 0 at **every** phase boundary (no phase may leave the tree red).
- [ ] `#print axioms` on every new declaration -> subset of `{propext, Classical.choice,
      Quot.sound}`, no `sorryAx`.
- [ ] Failed-vacuity check recorded for every new Prop 4.2-shaped declaration (Phases 3 and 7).
- [ ] Every new declaration carries a page-cited Rabinovich correspondence (PDF pages only).
- [ ] Preserved assets unchanged: `kampArm_*_k0/_k1`, the frozen byte-identity surfaces, and the
      prior task's Phase 1 probe and Phase 2 soundness milestone all still green.
- [ ] Terminal DoD: `#print axioms completeness_discrete` shows no `sorryAx`.

## Artifacts & Outputs

- `plans/01_contentful-prop42-section5.md` (this file)
- `reports/01_prop42-vacuity-probe.lean` (landed at Phase 2 as
  `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/Prop42Vacuity.lean`)
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/KampPrior.lean` (Phases 1, 8)
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/EANegationClosure.lean`,
  `NfMultiAnchorBridge/NavigatedSpine.lean` (Phase 2, docstring corrections only)
- New Section 5 modules under `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/` (Phases 3-7)
- `summaries/01_contentful-prop42-section5-summary.md`

## Rollback/Contingency

- Every phase ends at a green commit, so rollback is `git revert` of that phase's commit; no
  phase depends on an uncommitted predecessor.
- Phases 1 and 2 are independently valuable and survive **any** downstream outcome, including a
  Phase 3 NO-GO. They are deliberately sequenced first for this reason.
- A Phase 3 NO-GO is a **terminal, reportable finding**, not a failure: it would establish that
  `VecEA2` cannot support Rabinovich's own Prop 4.2 despite matching Notation 5.2's shape, which
  ends the task as scoped and supersedes the rescope. Do not iterate past it.
- Phase 8 has an explicit non-escalation clause: if `chain_split` plus contentful Prop 4.2 do not
  close the non-interval zones, the residual is reported. **Reaching for Feferman-Vaught is
  forbidden**, not a fallback.
