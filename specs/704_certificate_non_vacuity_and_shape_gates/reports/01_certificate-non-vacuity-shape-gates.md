# Research Report: Task #704

- **Task**: 704 - Certificate non-vacuity and shape gates
- **Started**: 2026-10-02T13:38:29Z
- **Completed**: 2026-10-02T14:05:00Z
- **Effort**: ~1.5 hours (codebase verification, two compiled probes, literature read)
- **Dependencies**: 696 (completed), 703 (completed). Task 706 is `researched`, NOT implemented — see F1.
- **Sources/Inputs**:
  - Codebase: `scripts/check-module-invariants.sh` (6378 lines), `FormalSystem/Metalogic/Decidability/{PlusWitnessFamily,PlusSlicedCertificate,WitnessFamily}/**`
  - Predecessor artifacts: task 699 report + `audit/enumerate-shape-s.sh` + `audit/01_enumeration-snapshot.md` (archived); task 703 `summaries/07_*`; task 706 `reports/01_*` and `probes/NoFiniteCarrierModel.lean`
  - Literature: `beer_bendavid_eisner_rodeh_2001_efficient_detection_of_vacuity` chunks 0003, 0005, 0010, 0011, 0020-0024
  - Probes: `specs/704_certificate_non_vacuity_and_shape_gates/probes/{01_decide_sliced_inhabitant,02_decide_conjuncts}.lean` (compiled with `lake env lean`; see F5 for the build-staleness caveat)
- **Artifacts**: this report
- **Standards**: report-format.md, return-metadata-file.md

## Executive Summary

- **Every declaration name and path in the description was re-verified against the live tree.** The
  PlusGraphCertificate supersession is correctly reflected in the tree (no such type exists;
  `FrameOver.ofStep` occurs only in prose). The description's second layer is also stale: **task 706's
  finite-carrier refutations are NOT landed** — task 706 is `researched`, and its declarations
  (`Probe706.no_finite_carrier_sat`, `no_ofStep_sat`, `not_finite_carrier_fmp`,
  `not_plusValidZTime_neg_θ`, the `θ'` family) exist only in
  `specs/706_lplus_finite_model_property_and_completeness/probes/NoFiniteCarrierModel.lean`. No gate
  under `scripts/` may cite that path (task-reference rule), so the (a3) 706 clause cannot be
  written until task 706 lands `FiniteCarrier.lean` per its own report's recommendation 2.
- **(a1) and the Stage-1 half of (a3) are already covered by C2's axiom baseline** (commit `abb4e85b4`,
  "pin Stage 1"): `plusCertifies_stabSnce_example`, `plusCertifies_stabUntl_example`,
  `not_exists_hopFree_plusCertifies_hopTarget`, `not_exists_plusCertifies_pumpTarget` and both
  `not_plusValidZTime_{hop,pump}Target` are pinned; a renamed or deleted declaration already fails C2
  by `#print axioms` error. What is missing is a NAMED non-vacuity assertion that (i) runs under
  `--no-build`, (ii) states the *interesting-witness* criterion explicitly, and (iii) names the
  coverage-limit declarations as a coverage-limit guard rather than as anonymous axiom rows.
- **(a2) has no exhibited inhabitant today.** The only closed-term `PlusSlicedCertificate.Certifies`
  fact in the tree is `Probe.exists_certifying_triv` (`Complete.lean:701`) at the EMPTY context, whose
  own docstring says it "does **not** show the class is interesting" — the textbook antecedent
  failure. Every embedded family (`Embedded.liveFamily`, `SnceProbe.*`, `BotTargets.*`) is proved
  `TailStable` after embedding but never `Certifies` as a sliced certificate. A compiled probe shows
  `(Embedded.liveFamily.sliced (-1)).Certifies` closes by kernel `decide` in ~5 s, axiom-clean — a
  one-declaration (a2) witness at a non-empty closure with a live `untl` obligation — **but** against a
  stale build (F5), so it must be re-run after `lake build`. A `⊡`-carrying witness (the description's
  "two targets the old class cannot certify", `hopTarget`/`pumpTarget`, both contain `stab`) is new
  Lean construction outside this task's `file_scope` and sits on the OPEN sliced finite-model question
  (task 710). Recommendation: tiered (a2), with the gate blocking only on tiers that are landed.
- **(b): the 699 specification is archived, not in the tree.** `clause_shape_collapse` exists only in
  the archived probe; the audit table predates the `trans` redesign. Re-derived against the live tree:
  30 `↔`-bearing definitions across the three certificate trees (table in F6). Two are genuine
  residual collapses still live on the tree — (C1')'s `untl`/`snce` conjuncts over `trans`, reflexive
  by the skeleton field `trans_refl` (`PlusWitnessFamily/Basic.lean:246`) — the subject of sibling
  task 705; the shape gate must allowlist them with a durable anchor and must not hard-code a verdict
  task 705 may change. The sliced class's nine conjuncts contain no Shape-(S) collapse: its
  two-regime liveness (`TailStable`) is an equality of `Finset`s, not a biconditional, and its box
  clauses' right-hand sides mention no bound position.
- **Vocabulary**: adopt Beer et al.'s NON-VACUITY / INTERESTING WITNESS / ANTECEDENT FAILURE. The
  shape mismatch the description warns about is confirmed from the primary source (their Definitions
  1-2 and §4.3 are post-hoc, model-relative); what transfers is the "affects" criterion, which this
  report operationalizes for a condition set in F7. Next free invariant numbers: **C36, C37** (C35 is
  the last numeric; `C25N`/`C9D` are letter-suffixed and do not collide).

## Context & Scope

Researched: the live declarations behind (a1)-(a3) and (b); the structure and conventions of
`scripts/check-module-invariants.sh` needed to add two checks; whether a non-trivial sliced
inhabitant exists or can be exhibited cheaply; the published vacuity vocabulary. Constraints: task
`file_scope` is `scripts/check-module-invariants.sh` only; sibling task 705 owns
`PlusWitnessFamily/Incompleteness.lean` this cycle; no `lake build` was run (F5); no file outside
`specs/704_*` and the scratchpad was written. Soundness is out of scope throughout.

## Findings

### Codebase Patterns

**F1. Name verification** (every name below confirmed by `grep` on the live tree at `4252ebe92`).

| Description says | Live tree |
|---|---|
| `plusCertifies_stabSnce_example`, `plusCertifies_stabUntl_example` in `PlusWitnessFamily/Examples.lean` | present, `Examples.lean:816` and `:1192`, on `famA`/`famB`; also `stabFamily_separates` (:384) for the (C5) separation witness |
| Stage 1 refutations under `PlusWitnessFamily/Limits/` | `Limits/NoCertificate.lean`: `not_plusCertifies_pumpTarget` (:136), `not_exists_plusCertifies_pumpTarget` (:425), `plusCompression_fails_at_pumpTarget` (:436); `Limits/HopFree.lean`: `not_plusCertifies_hopTarget_of_hopFree` (:235), `not_exists_hopFree_plusCertifies_hopTarget` (:319); `Limits/Targets.lean`: `hopTarget` (:118), `pumpTarget` (:124), `not_plusValidZTime_hopTarget` (:191), `not_plusValidZTime_pumpTarget` (:207) |
| `PlusGraphCertificate` | does not exist; `onePointCertificate` (`PlusSlicedCertificate/Basic.lean:620`) is the finite-graph special case |
| `PlusSlicedCertificate`, three segments, `ℤ × Fin n`, tail-stability | `Basic.lean:328` (fields `n, n_pos, back, mid, fwd, back_ne, fwd_ne, bx, target, targetTime`); `Certifies` at `Check.lean:565` with **nine** conjuncts; `TailStable` at `Stable.lean:841` |
| task 706 refutations "landed beside the Stage 1 declarations" | **FALSE**. `grep -rn 'no_ofStep_sat\|not_finite_carrier_fmp' FormalSystem docs scripts` is empty; task 706 status `researched`; only `specs/706_*/probes/NoFiniteCarrierModel.lean` (namespace `Probe706`) |
| `clause_shape_collapse` | not in the tree; only in `specs/archive/699_*/probes/01_clause_shape_collapse_probe.lean` and the 699 report §A0 |
| "C1-C35" | confirmed: C35 is the last numeric check (citation manifest); `C25N` and `C9D` are sub-checks |

**F2. Existing gate coverage.** C2's `AXIOM_BASELINE` (script lines ~1040-1066) pins 26 declarations,
including the four (a1)/(a3) Stage-1 names above plus `not_plusValidZTime_{stabSnce,stabUntl,hopTarget,pumpTarget}`,
`not_snce_share_congr`, `not_untl_shift_share_congr`, and the four sliced headlines
(`decidableCertifies`, `plusRefutes_of_certifies`, `exists_plusSlicedCertificate_of_tailStable_countermodel`,
`WitnessFamily.exists_plusSlicedCertificate_of_not_plusValidZTime_ofFormula`). C2 is skipped under
`--no-build`. Nothing in the script asserts that any pinned declaration is a *witness* rather than an
*existence theorem*, and nothing names the coverage-limit role.

**F3. The sliced condition set, clause by clause** (what (b) must cover):

| # | Conjunct of `Certifies` | Defined at | Shape |
|---|---|---|---|
| 1 | `BiSerial` | `Basic.lean:467` | `∀ t, (∀ w, ∃ u, edge) ∧ (∀ u, ∃ w, edge)` — no `↔` |
| 2 | `TailStable` (two-regime liveness: back residues `iterBack … ∩ bwdLiveAt = liveAt`, fwd residues `iterFwd … ∩ fwdLiveAt = liveAt`) | `Stable.lean:841` | `Finset` equalities — no `↔` |
| 3 | `BoxLabelFaithful` (C3b) | `Basic.lean:552` | `∀ t w, (box χ ∈ slab t w ↔ bx χ = true)` — unguarded (total relation), RHS mentions no position |
| 4 | `targetTime ∈ winTimes` | `Check.lean` | membership |
| 5 | `TargetPathPos` | `Check.lean:378` | no `↔` |
| 6 | `targetPos targetTime ∈ liveAt targetTime` | `Check.lean` | membership |
| 7 | `StabFaithful` (C5) | `Check.lean:480` | `stab χ ∈ slab t w ↔ ∀ p ∈ liveAt t, p.1 = w → χ ∈ p.2.1` — relation on the **right** side (row-10 shape), not a guard |
| 8 | `BoxLiveFaithful` | `Check.lean:514` | `bx χ = true ↔ ∀ t ∈ winTimes, ∀ p ∈ liveAt t, χ ∈ p.2.1` — LHS mentions no position |
| 9 | `Target` (C4) | `Basic.lean:568` | no `↔` |

Auxiliary `↔`-bearing definitions in the sliced tree (not conjuncts of `Certifies`): `BoxFaithful`
(`Basic.lean:522`, (C3) record only), `BoxLabelFaithfulWindow`, `SlabTrue` (`Complete.lean:123`,
a hypothesis of the completeness direction), `AgreesOnState` (`Position.lean:150`, guarded by
`IsStateShape ψ`, both sides mention `ψ`), `impClauseAt`/`untlClauseAt`/`snceClauseAt`
(`Position.lean:162-198`, one-step `Bool` clauses with no relational guard), `Live.splice`'s `imp`
clause. The two-regime liveness (`untlLive`/`snceLive`, `LiveFix.lean:87-92`) are `lfp` computations,
not biconditionals.

**F4. Exhibited inhabitants, by class** (the (a) inventory the gate would read):

| Class | Inhabitant | Target | Interesting? |
|---|---|---|---|
| `PlusSharingWitnessFamily` | `famA`, `plusCertifies_stabSnce_example` | `targetA = (⊤ S p) → ⊡(⊤ S p)` | yes: closure carries `snce` and `stab`; (C5) live; `famA_separates_snce` |
| same | `famB`, `plusCertifies_stabUntl_example` | `targetB = (⊤ U p) → (¬p → ⊡(⊤ U p))` | yes, dually; `famB_separates_untl` |
| same | `stabFamily`, `stabFamily_separates` | `⊡(⊤ U p)` separated from `⊤ U p` | (C5) non-vacuity witness, already in `docs/theorem-index.md:156` |
| `WitnessFamily` (L class) | `Embedded.liveFamily_certifies (-1)`, `SnceProbe.*_certifies`, `BotTargets.*_certifies` | `p U q`, `g S e`, `⊥ U ⊥`, `⊥ S ⊥` | L-side only; the `BotTargets` pair is deliberately degenerate |
| `PlusSlicedCertificate` | `Probe.triv`, `exists_certifying_triv`, ten `#guard decide triv.*` | empty context | **NO** — empty closure (`closure_empty`), antecedent failure by construction |
| `PlusSlicedCertificate` | `Fixture.cert` (`Fixture.lean:255`) | `gd U ev` | bi-serial but `FixtureStable.not_tailStable_cert` — it does **not** certify, by design |
| `PlusSlicedCertificate` | `W.sliced t` for the L families above | embedded `ofFormula` targets | `TailStable` proved by `decide` (`Embed.lean:838-848`, `EmbedComplete.lean:602-876`); **`Certifies` never stated** |

**F5. Probe results, and the build-staleness caveat.** Two scratch files were compiled with
`lake env lean` (copies under `specs/704_*/probes/`). Results:

- `theorem : (Embedded.liveFamily.sliced (-1)).Certifies := by decide` — **closes**, 5.2 s wall, axioms
  `[propext, Classical.choice, Quot.sound]`. Closure card 1 target formula group (`p U q`), `n = 1`,
  `winTimes.card = 6`, `liveAt (-1) = {(0, ∅)}`.
- `(SnceProbe.snceProbeLiveFamily.sliced 0).Certifies` — `decide` proves it **false**; per-conjunct
  `#eval` isolates `TailStable` as the failing conjunct, with `TailStableFwd` true and `TailStableBack`
  false, `NBnat = NFnat = 1`.
- **The second result contradicts the landed theorem** `snceProbeLiveFamily_tailStable`
  (`EmbedComplete.lean:676`, proved `by decide`). The resolution is not a kernel/compiler divergence
  (no `implemented_by`/`extern`/`native_decide` anywhere under `Decidability/`): the `.lake/build`
  oleans are dated **2026-10-01 10:42**, while `Stable.lean`/`EmbedComplete.lean` sources are dated
  2026-10-02 01:54 (commits `b30a608ab`..`960e39ede`, which swapped `TailStable`'s backward conjunct
  to the liveness-filtered form). The probes therefore ran against the **pre-filter** `TailStable`,
  under which that family is recorded to fail (`snceProbeLiveFamily_not_tailStableBackRaw`). The
  task-703 closing build evidently happened in its dispatch worktree; `git worktree list` shows none
  surviving. No rebuild was started here (sibling dispatches share this tree). Consequence: the
  `liveFamily` result is very likely stable (that family satisfies even the unfiltered conjunct,
  `Embed.lean:838-848`), but **both results must be re-established after `lake build`** before a
  plan relies on them, and any decide-based gate assertion must sit in the `RUN_BUILD=1` section
  after C1, exactly as C2 does.

**F6. Shape (S) allowlist, re-derived against the live tree.** Shape (S) per the 699 report:
`∀ x, R a x → (P ↔ Ψ(x))` with `R` reflexive at the instantiated argument and `P` not mentioning
`x`. The 699 pass-1 enumeration (`awk` over `def/abbrev/structure/class` bodies containing `↔`) was
re-run restricted to the three certificate trees; 30 hits. Classification:

| Definition (live location) | Guard relation | refl? | Verdict | Anchor for the allowlist reason |
|---|---|---|---|---|
| `PlusLocalCoherentShare` `untl` conjunct (`PlusWitnessFamily/Predicates.lean:91`, over `S.trans t i j`) | `trans t` | **yes** (`trans_refl`, `Basic.lean:246`; `trans_refl'` :337) | **RESIDUAL COLLAPSE** (699 row 18, still live) | sibling task 705's subject; residue recorded as `Sharing/Agreement.lean` `untl_succ_congr` (:227) |
| same, `snce` conjunct (over `S.trans (t-1) k i`) | `trans (t-1)` flipped | yes | **RESIDUAL COLLAPSE** (row 19) | `snce_pred_congr` (:240) |
| `LocalCoherentShare` `untl`/`snce` (`WitnessFamily/Sharing/Predicates.lean:156`) | `trans` | yes | RESIDUAL COLLAPSE (`Formula` side, rows 3-4 relocated to `trans`) | same anchors |
| `plusShareClauseAt` `untl`/`snce` arms (`PlusWitnessFamily/Decide.lean:542`; guard `tt i j ∧ rp i = rp j`) and `shareClauseAt` (`Sharing/Decide.lean:468`) | decision mirror of the above | yes | RESIDUAL (mirror) | must track the predicate's verdict |
| `PlusAtomCoherent` (`Predicates.lean:71`), `AtomCoherent` (`Sharing/Predicates.lean:136`), `plusAtomClauseAt` (`Decide.lean:462`), `atomClauseAt` (`Sharing/Decide.lean:389`) | `share u` / `rt i = rt j` | yes | INTENDED (both sides mention the bound index; it *is* the congruence) | 699 rows 7-9 |
| `StabFaithful` (`Predicates.lean:283`), `stabClauseAt` (`Decide.lean:692`) | `share u` on the RHS | yes | INTENDED (relation not a guard) | 699 rows 10-11 |
| `PlusBoxFaithful` (`Predicates.lean:202`), `BoxFaithful` (`WitnessFamily/Predicates.lean:106`), `plusBoxClause` (`Decide.lean:968`), `boxClause` (`WitnessFamily/Decide.lean:898`) | total relation (implicit) | trivially | INTENDED (`plusBox_const`) | 699 rows 12-13 |
| `imp`/`box` conjuncts of `PlusLocalCoherentShare`, `PlusLocalCoherentLab` (:173), `LocalCoherentLab`, `PlusLocalCoherentSeqLab`, `LocalCoherentSeqLab`, `labClauseAt` | none | — | OUT OF SHAPE (no relational guard) | 699 rows 14, 16 |
| Sliced: `BoxFaithful` (:522), `BoxLabelFaithful` (:552), `BoxLabelFaithfulWindow` (:557), `BoxLiveFaithful` (`Check.lean:514`) | total over `(t, w)` | trivially | INTENDED (RHS mentions no bound position / LHS is `bx χ`) | `plusBox_const`; (C3b) docstring |
| Sliced `StabFaithful` (`Check.lean:480`) | `liveAt t`, `p.1 = w` on the RHS | — | INTENDED (row-10 shape) | the (C5) docstring |
| Sliced `SlabTrue`, `AgreesOnState`, `impClauseAt`, `untlClauseAt`, `snceClauseAt`, `Live.splice` | none, or guard `IsStateShape ψ` with `ψ` on both sides | — | OUT OF SHAPE | — |

Result: the live allowlist has 2 (+2 `Formula`-side, +4 mirrors) RESIDUAL rows, all on `trans`,
and **no COLLAPSE row of the landed-and-exploited kind** (699 rows 1-6 are gone with the `trans`
redesign, as the C2 comment block records). The sliced class adds zero Shape-(S) instances. Pass 3
of the 699 script (reflexive relations) applied to the live tree should seed the gate's "reflexive
relation" set: `share_refl` (`Basic.lean:302`), `trans_refl`/`trans_refl'`, `rfl`-guards `rt i = rt j`.

**F7. Script conventions an implementer must follow** (from the script itself):
helpers `pass`/`fail`/`info`/`note`/`soft` (lines 797-802); per-check `ENFORCE_Cnn` flag with a
comment paragraph (lines ~584-778; new checks ship enforced "on the C24/C25 precedent" when green);
`RUN_BUILD` gating (line 172; `--no-build` skips C1/C2/C6/C16/C24/C25); Python-heredoc checks
exit 2 for "untrustworthy scan" and that exit is never suppressed (C34/C35 pattern); allowlist files
live at `scripts/*-allowlist.txt` / `*-baseline.txt` / `*-manifest.txt` and are listed in the header
(lines 145-156); C2's scratch-file compile (`mktemp --suffix=.lean`, `lake env lean`, continuation
rejoin) is the pattern for any decide/axiom assertion; the header enumerates every check (lines
15-126) and the C2 pass message hard-codes the pin count in words. The repository-wide
no-task-reference rule applies to `scripts/` (hook-enforced), so allowlist reasons must cite
declaration names or files, never task numbers or `specs/` paths.

### External Resources

- **Beer, Ben-David, Eisner, Rodeh (2001)**, FMSD 18(2). Definition 1 (Affect): "a sub-formula ψ of
  ϕ affects ϕ in model M if there is ψ′ such that ϕ and ϕ[ψ←ψ′] have different truth values in M".
  Definition 2 (Vacuity): ϕ is vacuous in M if some sub-formula does not affect it; antecedent
  failure is the propositional special case. §4.3 (Interesting witness w.r.t. a sub-formula): W is a
  ψ-interesting witness to ϕ in M iff W ≺ M, W ⊨ ϕ and ϕ is not ψ-vacuous in W, W minimal;
  Claim 21: if M ⊨ ϕ, a ψ-interesting witness exists iff ϕ is not ψ-vacuous in M. Theorem 7 /
  Lemma 3: vacuity need only be checked on the ≤-minimal sub-formulas. Chunks 0010, 0011, 0024 are
  the definitional ones; the index entry is marked `unverified_summary`, but the chunk text is the
  paper's own OCR, read directly.
- **Transfer, stated precisely.** Their notion is model-relative and post-hoc. The specification-time
  analogue for a condition set `Certifies : C → Prop` with closure-guarded clauses is: an inhabitant
  `G` is an *interesting witness* for clause family `K` (imp / untl / snce / box / stab) iff the
  closure puts at least one `K`-formula in play at `G` **and** that clause's guard is satisfied at
  some position of `G` — i.e. the clause "affects" `Certifies G` in the Definition-1 sense: negating
  the clause's body at that position flips the verdict. Antecedent failure = empty closure (`triv`)
  or a guard that holds nowhere. This is checkable by `#eval`/`decide` on closed certificates
  (closure cardinality, per-clause guard occupancy), without any model-checking machinery; no
  off-the-shelf algorithm is ported, as the description anticipates.
- Not acquired, not needed: Kupferman-Vardi 2003, Armoni et al. 2003, Kupferman 2006 (SOURCES.md D7).

## Decisions

- **D1.** The description's claim that task 706's refutations are landed is treated as stale; the
  (a3)-706 clause is specified as *deferred until the declarations exist in `FormalSystem/`*, not as
  a probe-path citation (which the task-reference rule forbids under `scripts/`).
- **D2.** (a1) and (a3)-Stage-1 are recorded as *already axiom-pinned by C2*; the new value of the
  gate is the named non-vacuity/coverage-limit assertion with an explicit interesting-witness
  criterion and a `--no-build` structural half, not a second axiom pin.
- **D3.** (a2) is split into tiers; only the tier whose inhabitant is landed can be gated. The
  `⊡`-carrying tier is research-first and must not block the gate.
- **D4.** No `lake build` was run; probe results are reported with the stale-build caveat rather than
  re-derived by starting a 2800-job rebuild on a tree four sibling dispatches share.
- **D5.** Published vocabulary adopted: NON-VACUITY, INTERESTING WITNESS, ANTECEDENT FAILURE.
- **D6.** No `.orchestrator-handoff.json` written; outcome returned via `.return-meta.json` only.

## Recommendations

1. **Rebuild first.** The plan's first implementation step must be a full `lake build`
   (`lake-build-guard.sh`), then re-run both probes. Nothing decide-based is trustworthy until the
   oleans postdate `960e39ede`.
2. **C36 — NON-VACUITY (interesting-witness inventory).** Add `scripts/certificate-witness-inventory.txt`
   with one row per certificate class: `class | inhabitant declaration | target declaration |
   witness kind`. Rows now: `PlusSharingWitnessFamily | plusCertifies_stabSnce_example | targetA |
   interesting(snce,stab)`, `… | plusCertifies_stabUntl_example | targetB | interesting(untl,stab)`,
   and — once tier 1 of item 3 lands — `PlusSlicedCertificate | <new decl> | Embedded.evTarget |
   interesting(untl)`. C36a (`--no-build`): every row's declaration exists in source with a statement
   of the form `… .PlusCertifies _` / `… .Certifies` on a **closed** term, and the row count equals
   the number of certificate classes carrying a `Certifies`/`PlusCertifies` predicate (so a new
   class without a witness fails loudly). C36b (`RUN_BUILD=1`, C2-style scratch file): for each row,
   `#eval` the closure cardinality (> 0), the target context non-empty, and the per-clause guard
   occupancy of the witness kinds the row claims; `#print axioms` stays C2's job. Pass text uses the
   published words ("interesting witness", "antecedent failure").
3. **(a2) in three tiers.** Tier 1 (do now; widen `file_scope` by one new module
   `PlusSlicedCertificate/Examples.lean` + aggregator line + C2 pin): land
   `theorem liveFamily_sliced_certifies : (Embedded.liveFamily.sliced (-1)).Certifies := by decide`
   — a closure with a genuinely discharged `untl`, the first non-degenerate sliced inhabitant.
   Tier 2 (same module, moderate): hand-build sliced certificates for `targetA`/`targetB`
   (`⊡`-carrying, so `StabFaithful` and `BoxLiveFaithful` are live) — the sliced twins of the (a1)
   witnesses. Tier 3 (research-first, separate task): `hopTarget`/`pumpTarget`, which contain `stab`
   and are not covered by the flagship; their sliced certifiability is a case of the open question
   task 710 attacks. The gate gates tiers 1-2 only; the plan must say so explicitly.
4. **(a3) — COVERAGE-LIMIT GUARD** as C36's second table (`coverage-limit` rows):
   `not_exists_hopFree_plusCertifies_hopTarget`, `not_exists_plusCertifies_pumpTarget`,
   `plusCompression_fails_at_pumpTarget`, `not_plusValidZTime_hopTarget`, `not_plusValidZTime_pumpTarget`;
   structural existence under `--no-build`, axiom-cleanliness delegated to C2 (assert the names are in
   `AXIOM_BASELINE`, C21-style subset check). Reserve a commented "finite-carrier" row group with
   the declaration names task 706's report specifies (`no_finite_carrier_sat`, `no_ofStep_sat`,
   `not_finite_carrier_fmp`, `not_plusValidZTime_neg_θ`) to be activated when `FiniteCarrier.lean`
   lands — cite the future module name, never the probe path.
5. **C37 — SHAPE CHECK.** Port pass 1 of `enumerate-shape-s.sh` (archived under task 699) into the
   script as a Python heredoc (C34 pattern): enumerate `↔`-bearing `def/abbrev/structure` bodies
   under `FormalSystem/Metalogic/Decidability/{PlusWitnessFamily,PlusSlicedCertificate,WitnessFamily}/`,
   and flag any whose `↔` sits under a quantifier guarded by a relation in the reflexive set
   (`share`, `trans`, `=` on `rt`/`rp` images, `tt i j`/`tm k i` edge guards) where the left side does
   not mention the bound variable. Allowlist `scripts/clause-shape-allowlist.txt`, keyed
   `path:declaration:clause`, verdict `INTENDED|RESIDUAL|OUT-OF-SHAPE`, reason = durable anchor
   (F6 table). Un-allowlisted hit = FAIL; allowlisted-but-absent row = FAIL (stale allowlist), on the
   C26 precedent. Seed from F6. Because the two RESIDUAL rows are task 705's subject this same cycle,
   the allowlist must be written so that 705 removing `trans_refl` turns those rows into stale
   entries (a visible FAIL to update), not into silent passes.
6. **Header and numbering.** Add C36/C37 lines to the header block (lines 15-126), the `--no-build`
   note, the allowlist filenames (lines 145-156), and `ENFORCE_C36`/`ENFORCE_C37` paragraphs; ship
   enforced, since both are green on the tree as of F6 and (after item 3 tier 1) F4.
7. **Territory.** `Incompleteness.lean` is task 705's; read it, never edit it. Re-read
   `check-module-invariants.sh` immediately before editing (task 703's phase 21 touched it last).

## Risks & Mitigations

- **Stale build invalidates probe evidence** (F5). Mitigation: item 1; treat the `liveFamily`
  result as "expected, unconfirmed" in the plan.
- **(a2) tier 3 may be unachievable** (open sliced finite-model question). Mitigation: gate only
  landed tiers; file tier 3 as its own research task rather than letting this task end `[BLOCKED]`.
- **Task 705 changes the (C1') verdicts mid-cycle.** Mitigation: allowlist keyed by declaration and
  clause with a stale-row FAIL, so the verdict is re-affirmed, not inherited.
- **Task 706 never lands `FiniteCarrier.lean`.** Mitigation: the reserved row group is inert and
  commented; nothing in the gate depends on it.
- **File-scope creep.** Tier 1 of (a2) needs one new Lean module and two one-line edits
  (aggregator, C2 pin); the plan should declare the widened `file_scope` explicitly.
- **Double-pinning.** C36b must not duplicate `#print axioms` (C2's whole-string equality would
  otherwise need its count word changed twice); delegate axioms to C2 and assert set membership.

## Context Extension Recommendations

- **Topic**: Adding a numbered check to `scripts/check-module-invariants.sh`.
  **Gap**: the conventions in F7 (helpers, `ENFORCE_` flags, `RUN_BUILD` gating, exit-2 semantics,
  allowlist file placement, header enumeration) are documented only inside the 6378-line script.
  **Recommendation**: a short `context/project/lean4/patterns/module-invariant-check-authoring.md`.
- **Topic**: Build freshness before `lake env lean` probes.
  **Gap**: nothing warns that `.lake/build` can lag sources after a worktree-landed commit, making
  `decide` probes silently answer about an older tree.
  **Recommendation**: one paragraph in `context/project/lean4/tools/mcp-tools-guide.md` or the
  bounded-build-waiter pattern: compare olean vs source mtimes (or run `lake build --no-build`
  equivalents) before trusting a probe.

## Appendix

- Probe files: `specs/704_certificate_non_vacuity_and_shape_gates/probes/01_decide_sliced_inhabitant.lean`
  (kernel `decide` on two embedded families, `#print axioms`),
  `02_decide_conjuncts.lean` (per-conjunct `#eval`, closure/width readouts). Compile from the
  repository root with `lake env lean <path>` after `lake build`.
- Enumeration command used for F6: the pass-1 `awk` of
  `specs/archive/699_invariance_clause_audit_and_ockhamist_grounding/audit/enumerate-shape-s.sh`,
  restricted to the three certificate roots and extended to print the first `↔` line per hit.
- Searches: `grep -rn 'no_ofStep_sat\|Probe706\|not_finite_carrier_fmp'`,
  `grep -rn 'clause_shape_collapse'`, `grep -rnE 'Certifies' PlusSlicedCertificate/*.lean`,
  `grep -nE 'C3[45]|PlusWitnessFamily|PlusSliced' scripts/check-module-invariants.sh`,
  `git worktree list`, olean/source `stat` comparison.
- Literature chunks read: `beer_bendavid_eisner_rodeh_2001_efficient_detection_of_vacuity/chunk_{0003,0005,0010,0011,0020,0021,0022,0023,0024}.md`.
- Cross-references: task 699 report §A0, §A1, §A5 and its enumeration snapshot; task 703 summary 07
  (Phase 21 gate disposals, four C2 pins); task 706 report D3 and Recommendations 2-3.
