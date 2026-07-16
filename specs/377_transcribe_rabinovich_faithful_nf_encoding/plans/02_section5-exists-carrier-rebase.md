# Implementation Plan v2: Section 5 Already Exists — Re-base onto the Faithful Carrier

- **Task**: 377 - transcribe_rabinovich_faithful_nf_encoding
- **Status**: [IMPLEMENTING]
- **Effort**: 9 phases (1-4 landed; 5-9 remaining, ~6-9 dispatches)
- **Dependencies**: None
- **Research Inputs**:
  - `reports/01_faithful-nf-encoding-ruling.md` (primary; **H3 table REFUTED on six rows at v2
    plan time — see Research Integration**)
  - `plans/01_contentful-prop42-section5.md` (v1; the record of what was learned — do not delete)
  - `.orchestrator-handoff.json` Phase 4 canary + five blockers (v2's mandated input; **canary
    partially refuted at v2 plan time — see Research Integration**)
- **Artifacts**: `plans/02_section5-exists-carrier-rebase.md` (this file)
- **Standards**:
  - .claude/rules/artifact-formats.md
  - .claude/rules/plan-format-enforcement.md
  - .claude/rules/plan-compliance.md
  - .claude/rules/lean4.md
- **Type**: lean4

## Overview

Plan v1's Phase 4 sizing canary fired, mandating a re-split of Phases 5-7 before dispatch. This
revision performs that re-split. In doing so it ran the discovery the canary's own recommendation
implied — an inventory of what the tree already supplies for the primitives Phase 4 said were
missing — and that inventory **refutes v1's central premise**.

> ## RABINOVICH SECTION 5 IS ALREADY TRANSCRIBED. IT IS LIVE, SORRY-FREE, AND AXIOM-CLEAN.
>
> `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/EANegationFix/` — **7 files, 3,129 lines, 0
> tactic-position sorries, reachable from `Theories/Bimodal.lean`** — contains Lemma 5.3, Lemma
> 5.1, Cor 5.4, the p.10-11 `A_i`/`B_i` decomposition, and the Prop 4.2/4.3 De Morgan fold. All
> `{propext, Classical.choice, Quot.sound}`, **no `sorryAx`**, verified by `#print axioms` at v2
> plan time.
>
> **A contentful Prop 4.2 already exists**: `VVecEA2.negFix_iff`
> (`EANegationFix/VecEANegFix.lean:164`) proves `v.negFix.holds M atomMap z0 z1 ↔ ¬v.holds M
> atomMap z0 z1`, where `v.negFix` is a function of `v` **alone** — hoisted out of `M`,
> `atomMap`, `z0`, `z1`. That is exactly the shape v1's non-vacuity rule demands, and it is
> **stronger** than `Prop42Contentful` (uniform in the model too).
>
> **v1 Phases 5, 6 and 7 planned to build what already exists.** They are VOID.

v1's Overview asserted: *"The real gap is therefore not a bridge — it is that Rabinovich's
Section 5 (pp.7-11), the actual proof of Prop 4.2, was never transcribed."* **That is false.** The
research report's H3 table marks Lemma 5.1, Lemma 5.3, Cor 5.4 and the closing induction
**ABSENT**; all four are present, live, and proved. The table appears to have been built by
looking for files *named* for the lemmas — `EANegationFix/` is named for the fix, not for the
paper, and was missed.

**What is genuinely wrong is one thing, and Phase 4 already found its shape.** The entire
`EANegationFix/` stack is gated on `HasAttainedINF` / `HasAttainedSUP` (`PriorINF.lean:202`,
`:254`) — the **strongest** of the three candidate carriers, stronger even than
`HasDefinableINF`, which Phase 4 machine-refuted as already too strong
(`hasDefinableINF_excludes_kplus`, `Lemma53.lean`). `OnBuilder.lean:27-33` states the deviation
in its own docstring:

> *"Rabinovich's inductive step has three disjuncts: never-P1, the K+ limit disjunct, and the
> attained-inf pin. On Prior structures the INF is always attained (`HasAttainedINF`), so the K+
> disjunct is vacuous and the pin disjunct is the plain `[¬P-segment, P-point]` prepend."*

That is an **acknowledged, deliberate strengthening**, sound for the live path and infidel to the
paper. Rabinovich's Lemma 5.3 is claimed over *all* Dedekind complete chains; `HasAttainedINF`
does not hold over all of them (the `ℝ`, `P₁ = {x | x > 0}`, `z₀ = 0` counterexample). So:

> **The remaining faithful-transcription gap is a CARRIER gap, not a transcription gap.** The
> proof structure, the primitives, the `A_i`/`B_i` split and the closing induction are all landed
> and proved. What is missing is the `K⁺` disjunct that Dedekind completeness (as opposed to
> attainment) forces.

**And the DoD's second half is not a Prop 4.2 gap either.** `KampPrior.lean:520`'s sorry is the
`k ≥ 2` residual, gated by its own in-code note (`:507-518`) on the Track-A
`P17-frozen-interface-gap` and assigned to **task 358**, with an explicit *"Do NOT discharge
here"*. Its `k = 0` and `k = 1` arms are already discharged — and `AggregateOffDiagK1.lean:1173-1205`
**already consumes `VVecEA2.negFix_iff`** at `k = 1`, discharging the attained carrier via
`prior_hasAttainedINF`/`prior_hasAttainedSUP`. Contentful Prop 4.2 is not merely available on the
live path; it is already wired into it.

**Definition of Done** (unchanged, and now honestly assessable): `KampPrior.lean:519`/`:520`
**and** `:522` both retired; full `lake build` green; no new axioms; every new declaration carries
a page-cited source correspondence. Phase 1 retired `:522`. **The remaining half is task-358
territory by its own in-code gate**, and Phase 9 is scoped to adjudicate and report rather than
force it.

**Honest scope note for the orchestrator.** Phases 5 and 9 are bounded and valuable under any
resolution. Phases 6-8 are the faithful-carrier re-base: real fidelity work, **zero operational
value** (the live path is Prior structures, where attainment holds outright), and entered on a
rescope whose stated basis is void. Phase 7 is an explicit GO/NO-GO gate placed before the
expensive part.

### Research Integration

| Input claim | v2 status | Disposition |
|---|---|---|
| Research H3: Lemma 5.1 **ABSENT** | **REFUTED** | `BracketFormula.negFix_iff` (`NegFix.lean:669`), axiom-clean, live |
| Research H3: Lemma 5.3 **ABSENT** | **REFUTED** | `negChainOn_iff` (`OnBuilder.lean:159`), axiom-clean, live |
| Research H3: Cor 5.4 **ABSENT** | **REFUTED** | `negBoundedRightFix_iff` (`BoundedFix.lean:449`), axiom-clean, live |
| Research H3: p.10-11 `A_i`/`B_i` + closing induction **ABSENT** | **REFUTED** | Formalized inside `negFixList` via `concatPin` + pinned `conjFull` DNF (`NegFix.lean:11-33`, `:424`) |
| Research H3: eq (5.2) **PARTIAL, correspondence UNVERIFIED** | **VERIFIED, and the delta is now named** | The carrier is `HasAttainedINF`, which is **strictly stronger** than eq (5.2). This is the whole remaining gap |
| Research H3: Prop 4.2 `neg_2var_vec_ea` **PROVED** | **REFUTED at v1 plan time (vacuous); SUPERSEDED at v2 plan time** | The vacuous `neg_2var_vec_ea` (`EANegationClosure.lean:722`) is the **pre-fix** statement. `EANegationFix/` is the later work that fixed it and was never wired back to Prop 4.2 |
| Canary: *"BracketFormula prepend does not exist"* | **REFUTED** | `BracketFormula.prepend` (`EANegation.lean:123`), `prepend_holds` (`:135`), `prepend_holds_inv` (`:223`), `VBracketFormula.prependAll` (`:333`). The canary searched only `VecEAFormula.lean` |
| Canary: *"`TemporalPred.disj` does not exist"* | **CONFIRMED** | `TemporalPred` has `top`/`bot`/`neg`/`conj` (`ExistsForallNF.lean:59-68`) and `untl`/`snce` (`BoundedFix.lean:38`). No `disj`. Phase 6 builds it |
| Canary: *"`O_n` must be `VVecEA2`, not `VBracketFormula`"* | **REFUTED for the existing stack** | `negChainOn : List TemporalPred → VBracketFormula` works precisely because the attained simplification deletes the `K⁺(P₁)(z₀)` endpoint conjunct. The claim becomes **true again** under the faithful carrier — Phase 7 must carry it |
| Canary: *"Phases 5-7 re-estimate to ~8-12 dispatches"* | **REFUTED** | Built on the premise that Section 5 must be transcribed. It exists. Remaining: ~6-9 dispatches, most of it optional fidelity work |
| Canary: *"closing induction is the highest residual risk; corroborated ONLY by printed text, not formalized anywhere in-tree"* | **REFUTED** | It **is** formalized, live and sorry-free. This retires v1's largest declared risk |
| Canary: *"Phase 4 → Phase 5 order is INVERTED relative to the mathematics"* | **UPHELD** | v2 orders: carrier + `disj` → Lemma 5.3 → Lemma 5.1. Carried into Phases 6→7→8 |
| Phase 4: `HasDefinableINF` is strictly too strong; build the disjunctive carrier | **UPHELD and EXTENDED** | The landed stack uses `HasAttainedINF`, which is stronger still. Phase 6 builds the faithful carrier |
| v1 rescope item 1 (`:522` first) | **DONE** | Phase 1 |
| v1 rescope item 5 (`chain_split` vs non-interval zones before FV) | **RETAINED** | Phase 9's first move, where it is reachable |

### Preserved Assets

Complete and verified; must not regress. **DO NOT RE-PLAN, DO NOT WEAKEN, DO NOT DELETE.**

| Component | File | Status | Verified |
|---|---|---|---|
| Phase 1: `:522` retired via `(hn : n ≤ 1)` domain restriction | `Kamp/KampPrior.lean` | **[COMPLETED]** `1b6d688ff` | Phase 1 |
| Phase 2: Prop 4.2 vacuity guard, CI-reachable | `Kamp/Prop42Vacuity.lean` | **[COMPLETED]** `f581ac1a8` | Phase 2 (BFS walk) |
| Phase 3: contentful Prop 4.2 target + both endpoint cases | `Kamp/Prop42Contentful.lean` | **[COMPLETED]** `f76e3059f` | Phase 3 |
| Phase 3: failed-vacuity worked pattern | `topVVec_contentful_forces_unsat` (`Prop42Contentful.lean:217`) | **The template.** Cite it | Phase 3 |
| Phase 4: Lemma 5.3 Basis + `⊤`-instantiation kit | `Kamp/Lemma53.lean` | **[COMPLETED]** `341c4906e` | Phase 4 |
| Phase 4: the carrier refutation | `hasDefinableINF_excludes_kplus` (`Lemma53.lean:282`) | **Axiom-clean.** v2's pivot | Phase 4 |
| **Lemma 5.3** | `negChainOn` + `negChainOn_iff` (`EANegationFix/OnBuilder.lean:149`, `:159`) | **LIVE, sorry-free, axiom-clean** | **v2 plan time (`#print axioms`)** |
| **Lemma 5.1 general** | `BracketFormula.negFix` + `negFix_iff` (`EANegationFix/NegFix.lean:454`, `:669`) | **LIVE, sorry-free, axiom-clean** | **v2 plan time** |
| **Cor 5.4** | `negBoundedRightFix_iff` (`EANegationFix/BoundedFix.lean:449`) + left mirror | **LIVE, sorry-free, axiom-clean** | **v2 plan time** |
| **Contentful Prop 4.2 / 4.3 De Morgan fold** | `VecEA2.negFix_iff` (`:64`), `VVecEA2.negFix_iff` (`VecEANegFix.lean:164`) | **LIVE, sorry-free, axiom-clean, hoisted** | **v2 plan time** |
| Prepend primitives | `BracketFormula.prepend`/`_holds`/`_holds_inv` (`EANegation.lean:123`/`:135`/`:223`), `VBracketFormula.prependAll` (`:333`) | Live | v2 plan time |
| Conjunction closure (Lemma 3.4) | `VVecEA2.conjFull` + `conjFull_iff` (`VecEAConjFull.lean:491`, `:503`) | Live | v2 plan time |
| Carrier discharge at the live boundary | `prior_hasAttainedINF` (`PriorINF.lean:224`), `prior_hasAttainedSUP` (`:269`) | Live, axiom-clean | v2 plan time |
| Contentful Prop 4.2 **already consumed on the live path** | `NfMultiAnchorBridge/AggregateOffDiagK1.lean:1173-1205` (k=1 arm) | Live | v2 plan time |
| Lemma 3.2(2) primitive (`chain_split`) | `reports/01_lemma32-anchor-split-probe.lean` | Proved, **axiom-free** | Research |
| Def 3.1 / Notation 5.2 object | `Kamp/VecEAFormula.lean` (`VecEA2` :252, `BracketFormula` :128) | Live, sorry-free | Research |
| Prop 3.5 translations | `Kamp/VecEATranslation.lean:515`; `Kamp/NfToVecEA.lean:413` | Live, sorry-free | Research |
| Load-bearing bridge arms (~29% of NfMultiAnchorBridge, 11 files / 13,737 lines) | `AggregateHookDischarge.lean`, `AggregateOffDiagK1.lean` (`kampArm_*_k0/_k1`) | Load-bearing for `completeness_discrete` | Charter |
| Frozen byte-identity surfaces | `CarrierKv.lean:240-249`; rfl bridges `InteriorGateGeneralK.lean:339-351`, `CarrierKv.lean:294-351` | **Inside live files** — surgical decl excision only, never file deletion | Charter |
| Prior task Phase 1 probe + soundness milestone | `ZoneSeamCrossContextProbe.lean`; commit `3b75fc880` | Green | Charter |

## Postmortem Constraints

Binding on every implementation dispatch. Violations are blockers, not judgment calls.

**Do NOT**:

- **Do NOT re-transcribe Rabinovich Section 5.** It exists at `EANegationFix/`, live and
  sorry-free. This plan's Phase 5 lands a CI-protected guard against exactly this mistake, which
  v1 made across three planned phases and one executed dispatch. **Before writing any Section 5
  Lean, grep `EANegationFix/` for the result.**
- **Do NOT accept `∃ v', v'.holds ...` as Prop 4.2, in any file, ever.** Machine-refuted at
  `Kamp/Prop42Vacuity.lean`. Mis-read as a proved asset at least twice.
- **Do NOT weaken, delete, or "clean up" `EANegationFix/`.** It is live, CI-protected, and
  consumed by `AggregateOffDiagK1.lean` at the `k = 1` arm of the goal chain. The faithful-carrier
  work **adds** alongside it; it does not replace it.
- **Do NOT delete or weaken** `Kamp/Prop42Vacuity.lean`, `Kamp/Prop42Contentful.lean`, or
  `Kamp/Lemma53.lean`'s Basis + `hasDefinableINF_excludes_kplus`.
- **Do NOT touch `KampPrior.lean`** except in Phase 9.
- **Do NOT re-prove the bare `BracketFormula` backward direction without INF anchors.** Ruled
  UNFIXABLE by two independent in-tree analyses. **Three-strikes target: a fourth bare attempt is
  forbidden.** Note this ruling is *consistent* with `negFix_iff` existing — `negFix` is
  INF-anchored (it assumes `h_INF`/`h_SUP`), which is precisely what the ruling said would be
  needed. It is not a counterexample to the ruling and must not be cited as license for a bare
  attempt.
- **Do NOT spawn cleanup. Do NOT delete the boneyard.** The vacuous decls are annotated in place;
  deletion is out of scope and they are load-bearing.
- **Do NOT route through `nf_eval_nf` on the characterization path** (hyperedge, treewidth `n`;
  Lemma 3.2(2) machine-proved UNPROVABLE about it at `Base.lean:1779`, verdict `:1801`). Routing
  through it forces Feferman-Vaught for linear orders = novel mathematics = **forbidden by the
  binding user constraint**.
- **Do NOT adopt `NfEFold`.** Its `EAtomDom` (:69) lacks Def 3.1's `beta` slot; its defense (:100)
  is refuted; `nf_eval_efold_k` (:608) is a mis-named non-fold that grows arity.
- **Do NOT budget from grep counts.** `grep -c sorry` returns ~40 on the archived files; there are
  **4** real tactic-position sorries. `EANegationFix/OnBuilder.lean` has raw `sorry` hits of 0 but
  the same trap fires elsewhere: `EANegation.lean` shows raw=15, tactic-position=6. Count by
  tactic position.
- **Do NOT cite `lake build BoneyardArchive` as evidence of health.** It passes **vacuously** —
  `#exit` at line 5 precedes the imports at line 7.
- **Do NOT cite the companion Rabinovich `.md`.** It is corrupt — it drops every displayed
  equation (and Section 5 **is** displayed equations) and inverts `k != m` to `k = m` at md:199.
  **PDF pages only**:
  `~/Projects/Literature/sources/rabinovich_2014/Rabinovich_2014_Proof_of_Kamps_Theorem.pdf`.
  Note `OnBuilder.lean:47` and `NegFix.lean:12` cite `chunk_0014`/`chunk_0017` (md artifacts) —
  **do not propagate that citation style**; re-cite by PDF page.

**MUST preserve**: everything in the Preserved Assets table, in particular the `kampArm_*_k0/_k1`
arms and the frozen byte-identity surfaces. Full `lake build` green at every phase boundary.

**The non-vacuity acceptance rule** (binding on EVERY phase that states a theorem; this task's
hardest-won lesson):

> Sorry-free + axiom-clean + EXIT 0 do **not** establish that a statement **says** anything. A
> vacuous theorem passes all three, and one did for 13 months and was believed by multiple agents.
>
> Quantifier order is the crux. Both of these are **vacuous**:
> - `∀ z0 z1, ∃ v', v'.holds z0 z1` — closed by `⟨tt, tt_holds⟩`.
> - `∀ z0 z1, ∃ v', (v'.holds z0 z1 ↔ ¬v.holds z0 z1)` — with `z0 z1` fixed, `¬v.holds z0 z1` is a
>   fixed truth value; pick `tt` when true and `ff` when false.
>
> The **only** acceptable shape hoists the witness out: `∃ v', ∀ z0 z1, (...)`. `VVecEA2.negFix`
> already has this shape structurally, being a function of `v` alone.
>
> **Every phase that STATES a theorem MUST run a failed-vacuity check**: state it with the key
> hypothesis removed, confirm it does **NOT** compile, and record the failure verbatim in the
> phase's verification block. `topVVec_contentful_forces_unsat` (`Prop42Contentful.lean:217`) is
> the **worked pattern — cite it as the template.**
>
> **v2 extends the rule to hypotheses, not just conclusions.** Phase 4's finding
> (`hasDefinableINF_excludes_kplus`) and v2's finding (the whole stack assumes `HasAttainedINF`)
> are both instances of *unnoticed strengthening of the hypothesis*. A theorem whose hypothesis
> is too strong is as unfaithful as one whose conclusion is too weak, and it passes every machine
> check. **When a phase assumes a carrier, it must state what that carrier excludes.**

**Liveness rule for this tree** (binding):

> Directory location, absence of `#exit`, and a green scoped build are **all unreliable** liveness
> signals. Only reachability from `Theories/Bimodal.lean` decides what CI protects. `lake build
> BoneyardArchive` passes **vacuously**. Any phase that adds a file MUST verify by **import-graph
> walk**, and MUST corroborate with the full-build job count moving up by exactly 1 per new
> module. Validate the walker against known-live and known-dead controls before use.

**Design decisions are SETTLED** (do not re-open without a concrete counterexample):

- **`VecEA2` / `BracketFormula` is the Def 3.1 / Notation 5.2 object.** Not `EAtomDom`, not
  `IntervalPattern`.
- **Lemma 3.2(2) is a THEOREM of Rabinovich's Def 3.1 and a NON-THEOREM of `nf_eval_nf`.** The
  original charter stated this **inverted**; do not propagate the inversion.
- **`KampPrior.lean:522` was mathematically unreachable but still had to be retired**, because
  `sorryAx` is tracked per-declaration, not per-path. Done in Phase 1.
- **`Kamp/Prop43.lean` and `Kamp/Boneyard/Prop43.lean` are NOT two attempts at Prop 4.3.**
  `Boneyard/Prop43.lean` is mis-named NF-side machinery. The "attempted twice, orphaned twice"
  framing is wrong and must not drive a "third attempt".

**Known traps**:

1. `endInterval_correct` (`EndIntervalConsumerK.lean:268`) is arity-1 `charF` machinery, **not**
   arity-4 `charFib`.
2. `ExistsForallNF.lean`'s `VEF.closed_conj` / `closed_ex` / `closed_disj` are **advertised in the
   docstring and never defined**. Its zero-sorry count reflects unstated theorems. (The actual
   conjunction closure lives at `VecEAConjFull.lean:491` under a different name.)
3. 89 in-code citations in `SharedWitness.lean` dangle.
4. `literature-search.sh` throws fts5 syntax errors on period-containing queries (avoid `Prop 4.2`
   as a literal query).
5. **New (v2)**: module names in this tree do **not** track paper structure. Section 5's
   transcription lives under `EANegationFix/`, not under any file named for Lemma 5.1/5.3. An
   absence-of-file search will produce a false ABSENT — as the research's H3 table did on six
   rows.

## Goals & Non-Goals

- **Goals**: Make the "Section 5 exists" finding permanent and CI-protected; retire the live
  `sorryAx` that Phase 4 introduced at `Lemma53.lean:339`; close `Prop42Contentful` from the
  landed `VVecEA2.negFix_iff`; build the faithful (Dedekind, not attained) INF/SUP carrier and
  re-base Lemma 5.3 onto it; adjudicate `KampPrior.lean:520` honestly against its task-358 gate.
- **Non-Goals**: Re-transcribing Section 5 (it exists). Proving Feferman-Vaught composition for
  linear orders (**forbidden** — novel mathematics). Boneyard cleanup or dead-code reclamation.
  Deleting or replacing `EANegationFix/`. Discharging the `P17-frozen-interface-gap` (task 358
  territory). A uniform model-independent Prop 4.3 (blockers stand at `Prop43.lean:136-153`).

## Risks & Mitigations

- **Risk**: The faithful-carrier re-base (Phases 6-8) is scope the user has never authorized, on a
  rescope whose stated basis is void, and it delivers **zero** operational value.
  **Mitigation**: Surfaced as the standing `premise_refuted` blocker for user adjudication. Phases
  5 and 9 are valuable under any resolution and are sequenced so they do not depend on 6-8. Phase
  7 is a GO/NO-GO gate placed before the expensive part (Phase 8).
- **Risk**: Phase 8 (re-basing the 681-line `negFixList` recursion onto a new carrier) exceeds one
  dispatch.
  **Mitigation**: Phase 7 is the canary. Phase 8 declares its dependency boundaries in advance and
  **stopping at one with a documented strategic sorry is the CORRECT outcome, not a failure**.
- **Risk**: A dispatch "discharges" an obligation with a vacuous witness or an over-strong
  hypothesis — the failure mode this task exists to correct, now observed **three** times
  (`neg_2var_vec_ea` vacuous; `HasDefinableINF` too strong; `HasAttainedINF` too strong).
  **Mitigation**: The non-vacuity rule, extended to hypotheses, with a mandatory failed-vacuity
  check per phase and a mandatory statement of what each assumed carrier excludes.
- **Risk**: An agent re-transcribes Section 5 because the module names do not track the paper.
  **Mitigation**: Phase 5 lands a CI-protected, in-tree correspondence guard. This is the same
  mechanism Phase 2 used for the vacuity finding, and it is warranted for the same reason: the
  finding was already discoverable and three consecutive dispatches missed it.
- **Risk**: `:520`'s in-code note (`KampPrior.lean:507-518`) says "Do NOT discharge here" and
  assigns it to task 358, so the DoD may be unreachable within this task.
  **Mitigation**: Phase 9 re-reads that note and **reports rather than forces**. A bounded,
  evidenced report is an acceptable terminus. **Reaching for Feferman-Vaught is forbidden.**

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
| 7 | 8 | 7 (GO) |
| 8 | 9 | 1, 5 |

**The orchestrator dispatches EXACTLY ONE PHASE PER CYCLE (H8).** Phase 9 depends only on Phases
1 and 5 — it is **not** gated on the faithful-carrier work (6-8), because `:520` is not a Prop 4.2
gap. If Phases 6-8 are not authorized, dispatch Phase 9 directly after Phase 5.

**Sizing instrument (the canary's key methodological finding)**: **line count is the wrong
instrument.** Phase 4 landed 341 lines against a ~200-350 estimate — "within budget" — while not
fitting its dispatch, because it stopped at a dependency boundary having proved only the Basis.
**Size by DEPENDENCY BOUNDARIES and PROOF OBLIGATIONS.** Every phase below names its boundaries;
where a phase may hit one, stopping there with a documented strategic sorry is the specified
correct outcome.

### Phase 1: Retire KampPrior.lean:522 by declaration restructuring [COMPLETED]

Landed `1b6d688ff`. The `n >= 2` sorry at `KampPrior.lean:522` retired by restricting the
definition's domain with an `(hn : n <= 1)` parameter — not by proving the `n >= 2` case, which
remains unproved and unneeded (the recursion resets arity to 1 at `:407`; the live entry from
`nf_characterizable_temporal_prior` is `n = 1`). All call sites updated. **First DoD half —
complete.**

**Verification (all PASSED, 2026-07-15)**: scoped build EXIT 0 (1052 jobs); full `lake build` EXIT
0 (1761 jobs); exactly one tactic-position sorry remains file-wide, at `:520`.

**Phase 9 baseline, recorded verbatim**: `#print axioms nf_nvar_exist_all_depths` →
`{propext, sorryAx, Classical.choice, Quot.sound}`. Phase 9's success criterion is the
disappearance of `sorryAx` from exactly this set, leaving `{propext, Classical.choice, Quot.sound}`.

**Do not re-plan. Do not re-dispatch.**

### Phase 2: Land the vacuity guard and annotate the live vacuous declarations [COMPLETED]

Landed `f581ac1a8`. `Kamp/Prop42Vacuity.lean` landed and CI-protected via an import edge in
`NfMultiAnchorBridge.lean:5`; reachability confirmed by import-graph BFS walk (234 → 235
reachable modules), walker validated against known-live and known-dead controls. The live vacuous
`neg_2var_vec_ea` (`EANegationClosure.lean:722`) and its re-export `reflatten_neg_step`
(`NavigatedSpine.lean:178`) annotated **in place**, not deleted — they are consumed live.

**Verification (all PASSED)**: scoped build EXIT 0 (982 jobs); `#print axioms
prop42_conclusion_is_vacuous` → `{propext, Classical.choice, Quot.sound}`, no `sorryAx`; full
`lake build` EXIT 0 (1762 jobs, up exactly 1 from Phase 1).

**Do not re-plan. Do not re-dispatch.**

### Phase 3: State contentful Prop 4.2 and decide the INF route [COMPLETED]

Landed `f76e3059f`. **VERDICT: GO.** `Kamp/Prop42Contentful.lean` states `Prop42Contentful` in the
hoisted `∃ v', ∀ z0 z1` shape with **no hypothesis**; the failed-vacuity check was run and landed
positively as `topVVec_contentful_forces_unsat` (`:217`) — **v2's cited template**. Both endpoint
cases (Lemma 5.1 Case 1, p.9) proved sorry-free at full generality
(`endpointLeftNegBlock_sound`, `endpointRightNegBlock_sound`,
`prop42_contentful_endpoint_instance`).

**Verification (all PASSED)**: full `lake build` EXIT 0 (1763 jobs, up exactly 1 from Phase 2); all
new declarations `{propext, Classical.choice, Quot.sound}`, no `sorryAx`.

**Phase 3's `spec_correction` directive (transcribe against `HasDefinableINF`) was REFUTED by
Phase 4 and is SUPERSEDED by Phase 6.** Retained here as the record.

**Do not re-plan. Do not re-dispatch.**

### Phase 4: Transcribe Lemma 5.3 (O_n, all beta_i True) [COMPLETED]

Landed `341c4906e`. **SCOPE CLOSED BY PLAN v2; RESIDUAL RE-HOMED TO PHASE 5. Do not re-dispatch.**

This phase was `[PARTIAL]` in v1: its Done-when ("Lemma 5.3 stated **and proved** sorry-free") was
objectively not met, with a documented strategic sorry at `Lemma53.lean:339` (the `n >= 2` arm).
v2 **formally reduces this phase's scope** to what it delivered and re-homes the residual, because
v2's discovery changes what discharging it means: the `n >= 2` arm does not need to be
*transcribed* (`negChainOn_iff` already proves it) — it needs to be *wired or re-carried*, which
is Phase 5's and Phase 7's work respectively. The obligation is tracked, not dropped.

**Delivered, sorry-free and axiom-clean** (`{propext, Classical.choice, Quot.sound}`):
`TemporalPred.top_eval_at`, `allTopBracket` + `allTopBracket_holds_succ` (which *proves* the
all-`⊤` segment clauses collapse to the paper's displayed formula, rather than asserting the
object is the paper's LHS), `allTopBracket_zero_holds`, `kplus_formula_correct` (the missing
correctness lemma for `kplus_formula`, `PriorINF.lean:87`, which had a correct definition, no
correctness lemma, and no reference anywhere in the tree), `O_zero` + `O_zero_correct`, `O_one` +
`lemma53_basis` (the printed Basis), and **`hasDefinableINF_excludes_kplus` — v2's pivot.**

**Its canary FIRED**, mandating this revision. Its two findings are both upheld and both extended
by v2: (1) the dependency order is inverted — carried into Phases 6→7→8; (2) `HasDefinableINF` is
strictly too strong and deletes the paper's disjunct (2) — extended by v2's finding that the
landed stack assumes `HasAttainedINF`, which is stronger still.

**Verification (all PASSED except the sorry-free criterion)**: scoped build EXIT 0 (984 jobs);
full `lake build` EXIT 0 (1764 jobs, up exactly 1 from Phase 3); import-graph walk 237 modules, up
exactly 1; failed-vacuity check executed both halves with the verbatim failure recorded
(`reports/03_lemma53-failed-vacuity-probe.lean`). **Open residual**: one tactic-position sorry at
`Lemma53.lean:339`, now **live** in the tree. **Phase 5 retires it.**

### Phase 5: Land the Section 5 correspondence guard; close Prop 4.2; retire the live sorry [COMPLETED]

- **Goal:** Make v2's discovery permanent and CI-protected, close `Prop42Contentful` from the
  already-landed `VVecEA2.negFix_iff`, and retire the live `sorryAx` that Phase 4 introduced.
  **This phase is bounded, is valuable under every downstream resolution, and requires no new
  mathematics — it is wiring plus a guard.**
- **Why a guard is warranted:** the vacuity finding was documented in-tree, dated, and read by
  nobody for 13 months; Phase 2 fixed that with a CI-protected guard. The "Section 5 exists"
  finding is the same failure at a larger scale: it was discoverable by grep the whole time, the
  research's H3 table marked six rows ABSENT that are present, and v1 planned three phases and
  spent one dispatch on work already done. Without an in-tree guard, a fourth agent will re-do it.
- **Tasks:**
  - [x] Add a new module `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/Section5Correspondence.lean`
        landing the **page-cited correspondence table** as a module docstring: Lemma 5.3 →
        `negChainOn_iff` (`OnBuilder.lean:159`, PDF p.8); Lemma 5.1 → `BracketFormula.negFix_iff`
        (`NegFix.lean:669`, PDF pp.9-10); Cor 5.4 → `negBoundedRightFix_iff`
        (`BoundedFix.lean:449`, PDF p.9) + left mirror; `A_i`/`B_i` split + closing induction →
        `negFixList` via `concatPin` + pinned `conjFull` (`NegFix.lean:424`, PDF pp.10-11); Prop
        4.2/4.3 De Morgan → `VVecEA2.negFix_iff` (`VecEANegFix.lean:164`, PDF p.6). **PDF pages
        only** — re-cite; do not propagate `OnBuilder.lean:47`/`NegFix.lean:12`'s `chunk_00NN`
        style.
  - [x] In the same module, state and prove **`prop42_contentful_of_attained`**:
        `(h_INF : HasAttainedINF M atomMap) → (h_SUP : HasAttainedSUP M atomMap) → (v : VVecEA2) →
        Prop42Contentful M atomMap v`, discharged by
        `⟨v.negFix, fun z0 z1 hlt => VVecEA2.negFix_iff M atomMap h_INF h_SUP v z0 z1 hlt⟩`.
        **This is v1 Phase 7's milestone — "the milestone the whole faithful path has been missing
        since the `NegationIndep.lean:357-364` fallback" — reached by wiring, not transcription.**
        Note the module must import both `Prop42Contentful` and `EANegationFix.VecEANegFix`;
        `Prop42Contentful.lean` itself imports only `VecEAFormula` and deliberately avoids
        `EANegationClosure`, so **add the new module rather than editing `Prop42Contentful.lean`**
        (no cycle: `Prop42Contentful` is not in `VecEANegFix`'s closure).
  - [x] **State what the carrier excludes** (the extended non-vacuity rule). Document in the same
        module that `prop42_contentful_of_attained` is Prop 4.2 **restricted to attained
        structures**, is NOT Rabinovich's Prop 4.2 over all Dedekind complete chains, and that
        `hasDefinableINF_excludes_kplus` (`Lemma53.lean:282`) already machine-proves the weaker
        `HasDefinableINF` is too strong — so `HasAttainedINF` is *a fortiori* too strong. Cite
        `OnBuilder.lean:27-33`, where the deviation is admitted in its own docstring.
  - [x] Retire the live sorry at `Lemma53.lean:339`. Restate `lemma53`'s hypothesis from
        `HasDefinableINF` to `HasAttainedINF` and discharge the `n >= 2` arm from
        `negChainOn_iff`, bridging `allTopBracket P` to `chainAllTrue Ps`. **If that bridge does
        not close within this dispatch, the sanctioned fallback is to reduce `lemma53` to the two
        arms it proves** (`n = 0`, `n = 1`) and re-home the general statement to Phase 7 — **do
        not leave a live `sorryAx` in the tree**, and do not delete
        `hasDefinableINF_excludes_kplus` or the Basis under any circumstance.
        *(The bridge closed: the `n >= 2` arm is discharged from `negChainOn_iff` via
        `chainAllTrue_ofFn_iff_allTopBracket`. **The sanctioned fallback was NOT taken** and the
        general statement is NOT re-homed to Phase 7. `lemma53` is sorry-free at the attained
        carrier; `hasDefinableINF_excludes_kplus` and the Basis are preserved and axiom-clean.)*
  - [x] Annotate `EANegationFix/OnBuilder.lean`, `NegFix.lean`, and `VecEANegFix.lean` **in
        place** with a pointer to the correspondence guard and a one-line statement of the carrier
        delta. **Do not weaken the theorems; do not touch the proofs.**
  - [x] Correct the research report's H3 table rows in place
        (`reports/01_faithful-nf-encoding-ruling.md`), quoting the old ABSENT claim verbatim and
        refuting it, so a reader who encountered the old text sees the correction. (Report edits
        are `specs/**`, exempt from the no-task-references rule.)
- **Verification:**
  - `lake build Bimodal.Metalogic.WeakCanonical.Kamp.Section5Correspondence` → EXIT 0.
  - `#print axioms prop42_contentful_of_attained` → exactly `{propext, Classical.choice,
    Quot.sound}`, **no `sorryAx`**.
  - `#print axioms lemma53` → **no `sorryAx`** (this is the phase's regression check).
  - **Failed-vacuity check, mandatory**: confirm `prop42_contentful_of_attained` is non-vacuous
    against the `topVVec` template (`topVVec_contentful_forces_unsat`,
    `Prop42Contentful.lean:217`) — state the all-`⊤` witness against it and confirm it does **not**
    typecheck. Record the failure verbatim.
  - Tactic-position sorry census (**not** `grep -c`) over `Kamp/`: no live `sorryAx` outside
    `KampPrior.lean:520`.
  - Reachability by **import-graph walk** from `Theories/Bimodal.lean`, walker validated against
    known-live and known-dead controls; full-build job count up **exactly 1** (expect 1765).
  - Full `lake build` → EXIT 0.
- **Green commit:** `task 377 phase 5: land Section 5 correspondence guard; close Prop 4.2 at the attained carrier`
- **Dependency boundaries:** the `allTopBracket` ↔ `chainAllTrue` bridge is the only one. It is
  named above with a sanctioned fallback, so this phase has **no** unbounded obligation.
- **Done when:** the correspondence guard is live and CI-protected; `prop42_contentful_of_attained`
  is sorry-free and axiom-clean with its carrier exclusion documented; and no live `sorryAx`
  remains outside `KampPrior.lean:520`.
- **Timing:** one dispatch
- **Depends on:** 4

### Phase 6: Build the faithful Dedekind INF/SUP carrier and TemporalPred.disj [NOT STARTED]

- **Goal:** Build the faithful eq (5.2) carrier — the one Rabinovich's Dedekind completeness
  actually supplies — and the one genuinely missing primitive. **Pure, testable, and blocks
  everything downstream** (the canary's explicit recommendation, upheld).
- **The carrier, stated exactly** (superseding Phase 3's `HasDefinableINF` directive, which Phase
  4 refuted):
  ```
  kplus M atomMap P z0
    ∨ (∃ r0, z0 < r0 ∧ r0 < z1 ∧ (∀ y, z0 < y → y < r0 → ¬P(y)) ∧ (P(r0) ∨ kplus M atomMap P r0))
  ```
  The **left disjunct is the paper's `Subcase r₀ = z₀`** (p.8: *"r₀ = z₀ iff K⁺(P₁)(z₀)"*); the
  **right disjunct is eq (5.2) verbatim**; `HasDefinableINF` (`PriorINF.lean:108`) is the right
  disjunct **alone** (modulo `r0 ≤ z1` vs `r0 < z1`). That omission is exactly what
  `hasDefinableINF_excludes_kplus` machine-refutes.
- **Tasks:**
  - [ ] Read PDF p.8 (eq (5.2), Case 2 and its `Subcase r₀ = z₀`) directly. **PDF only.**
  - [ ] Add `TemporalPred.disj` + its `eval_at` correctness lemma. `TemporalPred` is a bare
        `Formula` wrapper (`ExistsForallNF.lean:49`) with `top`/`bot`/`neg`/`conj` at `:59-68`;
        there is **no `disj`**, and disjunct (3)'s point type `P₁ ∨ K⁺(P₁)` needs it. Follow
        `TemporalPred.conj`'s idiom. **Confirmed missing at v2 plan time — this half of the
        canary's primitives finding stands.** (`BracketFormula.prepend` does **not** need
        building: it exists at `EANegation.lean:123` with `prepend_holds` `:135` and
        `prepend_holds_inv` `:223`, plus `VBracketFormula.prependAll` `:333`. The canary's claim
        that it was missing is refuted; **reuse, do not rebuild**.)
  - [ ] Define `HasDedekindINF` as the disjunctive carrier above, plus the `HasDedekindSUP` dual
        (`kminus`, `PriorINF.lean:92`, is the dual atom). Give both a page-cited correspondence.
  - [ ] Prove `HasAttainedINF.toHasDedekindINF` and `HasDefinableINF.toHasDedekindINF` (the
        landed carriers imply the faithful one — the right disjunct), and the duals. These are the
        compatibility shims that let Phase 8 re-base without discarding `EANegationFix/`.
  - [ ] Prove `prior_hasDedekindINF` / `prior_hasDedekindSUP` (Prior structures satisfy the
        faithful carrier), via `prior_hasAttainedINF` (`PriorINF.lean:224`) and the shim. **This
        is the live-path boundary discharge** and is what keeps the faithful route usable by
        `AggregateOffDiagK1.lean`.
  - [ ] **Prove the carrier is strictly weaker** — the point of the exercise. Reuse
        `hasDefinableINF_excludes_kplus` (`Lemma53.lean:282`): `HasDefinableINF` forbids
        `kplus M atomMap P z0` whenever `P` occurs in `(z0,z1)`, whereas `HasDedekindINF` admits
        exactly that case via its left disjunct. State this as a theorem, not prose. The `ℝ`,
        `P₁ = {x | x > 0}`, `z₀ = 0` counterexample (`inf = 0 = z₀`, `ℝ` Dedekind complete, paper
        handles it via disjunct (2)) is the intended reading; **record it as a docstring
        correspondence** and do not claim a formalized `ℝ` instance unless one is actually built.
- **Verification:**
  - Scoped `lake build` of the new module → EXIT 0; `#print axioms` on every new declaration →
    `{propext, Classical.choice, Quot.sound}`, no `sorryAx`.
  - **Failed-vacuity check, mandatory**: `HasDedekindINF` must not be trivially satisfiable. State
    its `first_occ` field with the occurrence hypothesis removed and confirm it does **not**
    compile. Record verbatim, per the `topVVec_contentful_forces_unsat` template.
  - **Carrier-exclusion statement, mandatory** (the extended rule): document what `HasDedekindINF`
    excludes relative to bare Dedekind completeness, and confirm it excludes strictly less than
    `HasDefinableINF` — by the theorem above, not by assertion.
  - Tactic-position sorry census (**not** `grep -c`) over `Kamp/`: no live `sorryAx` outside
    `KampPrior.lean:520` and `EANegation.lean:1090`/`:1249` (**amended gate** — see the DoD
    checklist for why the original wording was unsatisfiable at baseline).
  - Reachability by import-graph walk; full-build job count up exactly 1; full `lake build` → EXIT 0.
- **Green commit:** `task 377 phase 6: faithful Dedekind INF/SUP carrier and TemporalPred.disj (p.8)`
- **Dependency boundaries:** none. Every obligation is local — a definition, four shims, and a
  strictness theorem whose hard half is already proved.
- **Done when:** `HasDedekindINF`/`SUP` exist with page-cited correspondences; the shims from both
  landed carriers are proved; Prior structures are proved to satisfy the faithful carrier; the
  strictness theorem is proved; `TemporalPred.disj` + correctness landed. All sorry-free.
- **Timing:** one dispatch
- **Depends on:** 5

### Phase 7: Re-base Lemma 5.3 onto the faithful carrier — the three-disjunct O_n [NOT STARTED]

- **THIS PHASE IS THE PLAN'S GO/NO-GO GATE AND THE SIZING CANARY FOR PHASE 8.** Phase 8 does not
  dispatch until this resolves GO.
- **Goal:** Transcribe Rabinovich's Lemma 5.3 (PDF p.8) **as printed** — with all three disjuncts
  of the inductive step, over `HasDedekindINF` rather than `HasAttainedINF`. This is the faithful
  Lemma 5.3 that `negChainOn` deliberately does not supply.
- **The printed inductive step (PDF p.8)**, which the landed `negChainOn` truncates to two
  disjuncts: `Oₙ₊₁` is the disjunction of "`(z₀,z₁)` is empty" and
  1. `(∀y)^{<z₁}_{>z₀}¬P₁(y)`
  2. `K⁺(P₁)(z₀) ∧ Oₙ(P₂,…,Pₙ,z₀,z₁)`  ← **deleted by the attained simplification**
  3. `(∃r₀)^{<z₁}_{>z₀}(INF(z₀,r₀,z₁,P₁) ∧ Oₙ(P₂,…,Pₙ,r₀,z₁))`
- **Tasks:**
  - [ ] Read PDF p.8 (Notation 5.2, Lemma 5.3, eq (5.2)) directly. **PDF only.**
  - [ ] Define `negChainOnFaithful : List TemporalPred → VVecEA2` following `negChainOn`
        (`OnBuilder.lean:149`) structurally, **adding disjunct (2)**. The result type **must be
        `VVecEA2`, not `VBracketFormula`** — disjunct (2) conjoins the endpoint predicate
        `K⁺(P₁)` at `z₀`, which `VBracketFormula` cannot carry. (This is the canary's `O_n` claim,
        refuted for the *existing* stack precisely because it drops disjunct (2), and **true again
        here**.) Disjunct (3)'s point type is `P₁ ∨ K⁺(P₁)` — Phase 6's `TemporalPred.disj`.
  - [ ] **Reuse, do not rebuild**: `BracketFormula.prepend`/`prepend_holds`/`prepend_holds_inv`
        (`EANegation.lean:123`/`:135`/`:223`), `VBracketFormula.prependAll` (`:333`),
        `orderedPointsExist_combine` (`OnBuilder.lean:65`), `orderedPointsExist_decompose`,
        `chainAllTrue` (`:130`), `kplus_formula_correct` (`Lemma53.lean:154`),
        `VVecEA2.conjFull`/`conjFull_iff` (`VecEAConjFull.lean:491`/`:503`). Follow
        `negChainOn_iff`'s proof (`OnBuilder.lean:159`) step-by-step — it is the same induction
        with one extra case split.
  - [ ] Prove `negChainOnFaithful_iff` under `HasDedekindINF`, in the hoisted shape. The new case
        is the left disjunct of the carrier (`kplus P z0`), which routes to disjunct (2).
  - [ ] Every new declaration carries a page-cited source correspondence (PDF p.8).
- **Decision point (written kill criterion):**
  - **GO** if `negChainOnFaithful_iff` is proved sorry-free under `HasDedekindINF` in the hoisted
    shape, with the failed-vacuity check confirming non-vacuity. → Phase 8 may dispatch.
  - **NO-GO** if the faithful carrier cannot discharge the printed inductive step without a
    hypothesis absent from Rabinovich p.8, **or** if the `K⁺` disjunct cannot be expressed in
    `VVecEA2`. → **Stop. Do not attempt Phase 8.** Report: the faithful carrier is not
    transcribable in this encoding, which ends the fidelity re-base as scoped. Phases 1-6 remain
    landed and green, and `EANegationFix/` remains live and correct at the attained carrier.
  - **Three-strikes guard:** if this phase does not close in one dispatch, that is a **sizing
    signal about Phase 8, not grounds for a second dispatch on the same target.** Re-split Phase 8
    before dispatching it, exactly as v1's Phase 4 canary mandated for v1's Phases 5-7.
- **Verification:**
  - Scoped `lake build` → EXIT 0; `#print axioms negChainOnFaithful_iff` → no `sorryAx`.
  - **Failed-vacuity check, mandatory**: the per-point ordering `∀ M atomMap z0 z1, ∃ O` is
    **vacuous** and must fail to be accepted; the hoisted `∃ O, ∀ M atomMap z0 z1` is the claim.
    `reports/03_lemma53-failed-vacuity-probe.lean` already contains both halves executed for
    `lemma53` — **reuse it as the template** and record the verbatim failure.
  - **Carrier-exclusion statement, mandatory**: state what `HasDedekindINF` excludes here, and
    confirm disjunct (2) is **reachable** — i.e. that this transcription does not repeat the
    unnoticed-strengthening failure by another route. Concretely: confirm `negChainOnFaithful`'s
    disjunct (2) is not dead code, by exhibiting the `kplus` case as satisfiable.
  - Tactic-position sorry census over `Kamp/`: no live `sorryAx` outside `KampPrior.lean:520` and
    `EANegation.lean:1090`/`:1249` (**amended gate** — see the DoD checklist).
  - Reachability by import-graph walk; full-build job count up exactly 1; full `lake build` → EXIT 0.
- **Green commit:** `task 377 phase 7: faithful three-disjunct Lemma 5.3 over the Dedekind carrier (p.8)`
- **Dependency boundaries:** the `K⁺` disjunct's interaction with `prependAll`'s witness shifting
  is the one place a boundary may appear. **If it does, stop there with a documented strategic
  sorry isolated to that arm and report it — that is the CORRECT outcome, not a failure**, and it
  resolves the gate NO-GO.
- **Done when:** `negChainOnFaithful_iff` is proved sorry-free under `HasDedekindINF`, with a p.8
  citation, a recorded failed-vacuity check, and disjunct (2) demonstrated reachable — **or** a
  bounded NO-GO report with its evidence.
- **Timing:** one dispatch
- **Depends on:** 6

### Phase 8: Re-base Lemma 5.1 and Prop 4.2 onto the faithful carrier [NOT STARTED]

- **DOES NOT DISPATCH UNTIL PHASE 7 RESOLVES GO.** If Phase 7 reports NO-GO, this phase is void.
- **Goal:** Re-base `BracketFormula.negFix_iff` (`NegFix.lean:669`) and `VVecEA2.negFix_iff`
  (`VecEANegFix.lean:164`) from `HasAttainedINF`/`HasAttainedSUP` onto
  `HasDedekindINF`/`HasDedekindSUP`, yielding Rabinovich's Prop 4.2 at the generality he claims.
- **Honest scoping — read before dispatching.** This is the largest and least certain phase in the
  plan. `negFixList` (`NegFix.lean:424`) is a 681-line recursion whose Case 2/Case 3 gates are
  built around the *attained* pin; admitting the `K⁺` limit case adds a third gate to each. **It
  is unlikely to fit one dispatch, and the plan says so up front rather than discovering it as v1
  did.** Its predecessor obligations are named below so the dispatch stops at a boundary rather
  than sprawling.
- **Sub-obligations, in dependency order** (each is a candidate stopping boundary):
  1. `negBoundedRightFix_iff` / the anchored left mirror (Cor 5.4, `BoundedFix.lean:449`) over the
     faithful carrier.
  2. `negFixOne_cover/_iff` (`NegFixOne.lean`, Lemma 5.1 `n = 1`) over the faithful carrier.
  3. `negFixList_iff` general recursion (`NegFix.lean:495`) — the `A_i`/`B_i` split and closing
     induction, which are **already formalized** via `concatPin` + pinned `conjFull` and need
     re-carrying, **not re-deriving**.
  4. `BracketFormula.negFix_iff`, then `VecEA2.negFix_iff`, then `VVecEA2.negFix_iff`.
  5. `prop42_contentful_of_dedekind` — the faithful analogue of Phase 5's
     `prop42_contentful_of_attained`. **This is the terminal fidelity milestone.**
- **Tasks:**
  - [ ] Read PDF pp.9-11 directly, including Figure 1 (p.10), eq (5.3) `INF^{¬β₁}`, and the two
        displayed equivalences (p.11). **PDF only.**
  - [ ] Work the sub-obligations **in the order above**, one boundary at a time. **Prefer
        generalizing the existing proofs over rewriting them** — the structure is Rabinovich's and
        is already proved; only the carrier changes. Per `plan-compliance.md`, do not substitute a
        different decomposition.
  - [ ] **Do not delete or weaken the attained-carrier versions.** They are live and consumed by
        `AggregateOffDiagK1.lean` at the `k = 1` arm. The faithful versions are **additions**; the
        attained ones follow from them via Phase 6's shims.
  - [ ] Literature-fidelity rule applies: follow the printed proof step-by-step; do **not** use
        `simp`/`omega`/`aesop` to bypass a step the paper handles explicitly; do **not** abandon
        the paper's approach after a single tactic failure.
- **Verification:**
  - Scoped `lake build` → EXIT 0; `#print axioms prop42_contentful_of_dedekind` → exactly
    `{propext, Classical.choice, Quot.sound}`, **no `sorryAx`** (or a documented strategic sorry
    isolated to a named boundary).
  - **Failed-vacuity check, mandatory**, re-run against the *final* statement per the
    `topVVec_contentful_forces_unsat` template. A contentful statement that silently drifted to a
    vacuous one during transcription is the exact failure this plan exists to prevent.
  - **Carrier-exclusion statement, mandatory**: confirm no arm re-introduces attainment.
  - Confirm `AggregateOffDiagK1.lean`'s `k = 1` consumption still builds — **the regression check
    that matters most in this phase.**
  - Tactic-position sorry census over `Kamp/`: no live `sorryAx` outside `KampPrior.lean:520` and
    `EANegation.lean:1090`/`:1249` (**amended gate** — see the DoD checklist).
  - Full `lake build` → EXIT 0.
- **Green commit:** `task 377 phase 8: re-base Lemma 5.1 and Prop 4.2 onto the faithful carrier (pp.9-11)`
- **Sizing canary:** this phase is expected to span **2-4 dispatches**. **Stopping at any named
  sub-obligation boundary with a documented strategic sorry and an updated handoff is the CORRECT
  outcome.** Do not compress. Do not repeat v1's optimism. **If sub-obligation 1 alone overruns
  one dispatch, re-split the remainder before dispatching it.**
- **Done when:** `prop42_contentful_of_dedekind` is proved sorry-free and axiom-clean with a
  recorded failed-vacuity check — **or** a bounded report naming exactly which sub-obligation
  holds and why, with the attained-carrier stack still green.
- **Timing:** 2-4 dispatches (explicitly **not** one; sized by sub-obligation boundaries)
- **Depends on:** 7 (GO)

### Phase 9: Retire KampPrior.lean:520, or adjudicate it against task 358 [NOT STARTED]

- **This is the terminal phase and the second DoD half** (v1's Phase 8, renumbered; its baseline
  and non-escalation clause carried forward verbatim).
- **Depends only on Phases 1 and 5 — NOT on 6-8.** `:520` is **not** a Prop 4.2 gap: contentful
  Prop 4.2 is already live (`VVecEA2.negFix_iff`) and already consumed at the `k = 1` arm
  (`AggregateOffDiagK1.lean:1173-1205`). **If the faithful-carrier work (6-8) is not authorized,
  dispatch this phase directly after Phase 5.**
- **Goal:** Retire the `k >= 2` residual at `KampPrior.lean:520`, completing the DoD — **or**
  report, on evidence, why it stands.
- **Read this first — the phase's central question.** `KampPrior.lean:507-518` gates this residual
  on the Track-A `P17-frozen-interface-gap` (the `hrealI`/`hrealB` anchor-content interface gap,
  `OuterGate:374`/`:380` — the frozen producer chain's `kvE2_sepPtW` is a point-type at `w` and
  drops the x/t anchor content; convergent three-agent finding), names **task 358** as successor,
  and says explicitly: *"Do NOT discharge here ... this residual is 358 territory"*. **v2's
  assessment: that gate is about the frozen producer interface, not about negation closure, and
  nothing in Phases 1-8 touches it.** The honest expectation is that this phase **reports**.
- **Tasks:**
  - [ ] Re-read `KampPrior.lean:507-518` and re-evaluate its gating rationale **on its own terms**,
        against a contentful Prop 4.2 that now demonstrably exists. If the rationale still stands,
        **report it rather than forcing a discharge.**
  - [ ] Verify against the landed reality: the `k = 0` and `k = 1` arms are discharged
        (`kampPrior_case1_arm_k0`, `kampPrior_case1_arm_k1`); the `k = 1` arm already consumes
        `VVecEA2.negFix_iff` with the carrier discharged by `prior_hasAttainedINF`/`_SUP`. Confirm
        whether the `k >= 2` obstruction is the `P17` interface gap or something Prop 4.2 now
        addresses. **This is a question of fact — answer it by reading the goal state, not by
        assumption.**
  - [ ] Try `chain_split` (`reports/01_lemma32-anchor-split-probe.lean`) against the non-interval
        zones (1,2,4,5) **before anything else**. It is itself a composition/gluing theorem at a
        shared anchor over a bare `LinearOrder` — structurally the shape the archived path wanted
        from Feferman-Vaught — and it is **axiom-free**. Interval zone 3 already discharges from
        Since/Until witnesses.
  - [ ] If `chain_split` + contentful Prop 4.2 close the zones, discharge `:520`. **If they do
        not, STOP** — do not reach for the Feferman-Vaught literature theorem. That is novel
        mathematics and is **forbidden by the binding user constraint**. Report the residual, and
        confirm task 358 is the correct owner.
- **Verification:**
  - `#print axioms nf_nvar_exist_all_depths` → **Phase 1 recorded the baseline verbatim**:
    `{propext, sorryAx, Classical.choice, Quot.sound}`. Success is `sorryAx` disappearing, leaving
    `{propext, Classical.choice, Quot.sound}`.
  - `#print axioms completeness_discrete` (`Metalogic/BXCanonical/Completeness.lean:276`) → exactly
    `{propext, Classical.choice, Quot.sound}`, no `sorryAx`. **The DoD's terminal check.**
  - `#print axioms` on the full goal chain: `nf_nvar_exist_all_depths` →
    `nf_characterizable_temporal_prior` → `kamp_prior_expressive_completeness` →
    `US_expressively_complete_over_prior`.
  - Tactic-position sorry census over `Kamp/`: no live `sorryAx` outside `KampPrior.lean:520` and
    `EANegation.lean:1090`/`:1249` (**amended gate** — see the DoD checklist). Note that
    `EANegation.lean:1090`/`:1249` are **out of scope for this phase too**: Phase 9 adjudicates
    `KampPrior:520` only.
  - Full `lake build` → EXIT 0.
- **Green commit:** `task 377 phase 9: retire KampPrior:520; complete implementation` — **or**
  `task 377 phase 9: adjudicate KampPrior:520 residual against task 358`
- **Done when:** `:520` is retired and `completeness_discrete` is `sorryAx`-free — **or** a
  bounded, evidenced report of why the residual stands, with **no FV attempt**, naming task 358 as
  owner. **Both are acceptable termini.** The second is the expected one.
- **Timing:** one dispatch
- **Depends on:** 1, 5

## Testing & Validation

- [ ] Full `lake build` → EXIT 0 at **every** phase boundary (no phase may leave the tree red).
- [ ] `#print axioms` on every new declaration → subset of `{propext, Classical.choice,
      Quot.sound}`, no `sorryAx`.
- [ ] **Failed-vacuity check recorded for every phase that states a theorem** (5, 6, 7, 8), against
      the `topVVec_contentful_forces_unsat` template (`Prop42Contentful.lean:217`).
- [ ] **Carrier-exclusion statement recorded for every phase that assumes a carrier** (5, 6, 7, 8).
      The extended non-vacuity rule: an over-strong hypothesis passes every machine check.
- [ ] Tactic-position sorry census (**never** `grep -c sorry`) after every phase: no live `sorryAx`
      outside `KampPrior.lean:520` and `EANegation.lean:1090`/`:1249`. **(AMENDED for Phases 6-9,
      user-approved.)** Why: Phase 5 established by import-graph walk on a baseline worktree at
      commit `341c4906e` that `EANegation.lean:1090`/`:1249` were **already live** (reachable via
      `OnBuilder`) **before any Phase 5 edit** — so the original gate was already false at the
      Phase 4 baseline and would fail every later dispatch on a pre-existing condition. Both are
      the model-independent Prop 4.2 backward direction, i.e. the target the standing three-strikes
      prohibition rules **unfixable** (report 18 §4.3; `Boneyard/NegationIndep.lean:346-364`); **no
      dispatch is permitted to fix them.** Phase 4's handoff claim that `Lemma53.lean:339` was the
      only live sorry was incomplete.
- [ ] Reachability of every new module verified by **import-graph walk** with validated controls,
      corroborated by the full-build job count moving up by exactly 1 per module.
- [ ] Every new declaration carries a page-cited Rabinovich correspondence (**PDF pages only**).
- [ ] Preserved assets unchanged: `EANegationFix/` green and consumed; `kampArm_*_k0/_k1`; the
      frozen byte-identity surfaces; `ZoneSeamCrossContextProbe.lean`; commit `3b75fc880`.
- [ ] `AggregateOffDiagK1.lean`'s `k = 1` consumption of `VVecEA2.negFix_iff` still builds.
- [ ] Terminal DoD: `#print axioms completeness_discrete` shows no `sorryAx` — **or** a bounded
      report naming task 358 as owner.

## Artifacts & Outputs

- `plans/02_section5-exists-carrier-rebase.md` (this file)
- `plans/01_contentful-prop42-section5.md` (v1 — **preserved as the record of what was learned; do
  not delete**)
- `reports/01_faithful-nf-encoding-ruling.md` (H3 table corrected in place at Phase 5)
- `reports/03_lemma53-failed-vacuity-probe.lean` (the failed-vacuity template; reused at Phase 7)
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/Section5Correspondence.lean` (Phase 5, new)
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/Lemma53.lean` (Phase 5, sorry retired)
- New faithful-carrier modules under `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/` (Phases 6-8)
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/KampPrior.lean` (Phases 1, 9)
- `summaries/02_section5-exists-carrier-rebase-summary.md`

## Rollback/Contingency

- Every phase ends at a green commit, so rollback is `git revert` of that phase's commit; no phase
  depends on an uncommitted predecessor.
- Phases 1-5 and 9 are independently valuable and survive **any** resolution of the
  faithful-carrier question. They are sequenced so that Phase 9 (the DoD) does **not** depend on
  Phases 6-8.
- **A Phase 7 NO-GO is a terminal, reportable finding, not a failure.** It would establish that
  the faithful Dedekind carrier is not transcribable in this encoding — while leaving
  `EANegationFix/` live, correct at the attained carrier, and consumed by the live path. Do not
  iterate past it.
- **Phase 8 may legitimately end at a documented strategic sorry** on a named sub-obligation
  boundary. That is the specified correct outcome, not a failure, and it must be reported in the
  handoff with the boundary named.
- Phase 9 has an explicit non-escalation clause: if `chain_split` plus contentful Prop 4.2 do not
  close the non-interval zones, the residual is **reported** and task 358 is named as owner.
  **Reaching for Feferman-Vaught is forbidden, not a fallback.**
- If the user declines the faithful-carrier re-base (Phases 6-8), the plan still terminates
  cleanly: Phase 5 → Phase 9 → report. That path is ~2 dispatches.
