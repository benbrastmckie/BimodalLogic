# Research Report: Group C Live/Dead/Portable Reconciliation

- **Task**: 414 `refactor_semantics_to_maximal_history_validity` (reconciliation for the 414/415 planning decision)
- **Session**: sess_1785280411_23b0e6_414r
- **Date**: 2026-07-28
- **Agent**: lean-research-hard-agent (H2+H3+H4 active; **H5 divergence audit ACTIVATED**)
- **Inputs under audit**: Report A (`reports/01_maximal-history-validity-refactor.md`, Finding 8-9) vs Report B
  (`specs/415_completeness_over_maximal_history_semantics/reports/01_completeness-maximal-history-rebase.md`)
- **Reference grounding**: Tier 3 (implementation-backed reconciliation); fix.md B1/C1/C2 read directly
  (`/home/benjamin/Philosophy/Papers/PossibleWorlds/Comments/fix.md`)

## Summary

**Verdict: Report A's ~80-declaration "mathematically unportable" excision list is a 10x overestimate of the
mathematically obstructed set — but its headcount is accidentally close to the right *deletion* count, for the
wrong reason.** A kernel-level used-constants reachability closure over the whole build (root set stated in
Finding 1) shows that of the ~110 Omega/ShiftClosed/TruthAt-affected declarations in Report A's Group C files:

- **≈88 are DEAD** — unreachable from every headline theorem, every test, and every executable. This includes
  the *entire* singleton-Omega device (`Transfer.lean:568-687`), the entire `ZOmegaV2` device, the entire
  D-generic `multiFamOmegaGen` family, all four `ParametricCompleteness.lean` theorems, and — a finding in
  neither prior report — the **entire TruthAt-side Decidability Bridge (~52 declarations)**.
- **16 are LIVE and portable**: 9 by mechanical binder rewrite; 7 (the `multiFam` discrete pipeline) with
  exactly one new characterization lemma (`multiFam_isMax_iff`) plus a rewritten box case.
- **Only 8 are LIVE-AND-UNPORTABLE** — the dense parametric-canonical device
  (`ParametricHistory` Omega unit + the two `fully_restricted_*` truth lemmas + `countermodel_dense_enriched`).
  This is the **actual excision/re-host list**, and it takes exactly two headline theorems
  (`completeness_dense`, and `completeness`'s dense branch) temporarily with it if excised before the 415 flow
  re-host lands.

Report B's three factual claims all verify. Report A's central mathematical claim — that box-transparency at
`Transfer.lean:616` is *false* under maximal-history box — is **refuted for that declaration** (the statement
survives on the `Unit`-state frame; only its proof breaks); the obstruction Report A worried about is real, but
its live instance is the *dense parametric frame*, and its dead instance is the *Decidability Bridge's
`regionFrame`* — neither of which Report A analyzed. Root cause of the divergence: Report A inherited fix.md
C1's stale call-graph citation and never ran reachability (Finding 8, H5 audit).

## Findings

### Finding 1 — Root set and method (what "live" means here)

The default `lake build` target is `lean_lib FormalSystem` (`lakefile.lean`, `@[default_target]`, roots =
`FormalSystem`), which compiles *everything* including dead code — so build membership cannot be the liveness
criterion (it would make DEAD vacuous). **Live = reachable in the kernel used-constants graph from this root
set**:

1. **Headline theorems** (Metalogic.lean:30-46 "Publication-Ready Results" + the Dedekind engine layer +
   the decidability API): `soundness`, `soundness_dense`, `soundness_discrete`, `soundness_dedekind`,
   `completeness`, `completeness_dense`, `completeness_discrete`, `completeness_dedekind_of_engine`,
   `consequence_completeness_dedekind_of_engine`, `soundness_dedekind_consequence`, `decide`, and all ten
   theorems of `Metalogic/Decidability/Correctness.lean` (`decide_sound` … `countermodel_size_bound`).
2. **Every declaration** in `FormalSystem.Theorems.*`, `FormalSystem.Examples.*`, `FormalSystem.Automation.*`
   (the 11 `lean_exe` roots all live under Automation).
3. **Every declaration** in `BimodalTest.*` (the `testDriver` lib, built: `.lake/build/lib/lean/BimodalTest.olean`).

Root count: 2,108 constants; closure size 10,617.

**Method** (per the reachability mandate): primary evidence is a Lean metaprogram run against the built
environment (`import FormalSystem; import BimodalTest`), computing the transitive closure of
`Expr.getUsedConstants` over theorem/def *types and proof terms* from the root set, with parent-pointer witness
chains. This is kernel-level and strictly stronger than both grep and LSP reference search (it sees proof
terms, not text). It was cross-validated three ways before being trusted:
- **Proof-text check**: the closure's chains match the actual proofs — `completeness_discrete` calls
  `countermodel_discrete_reynolds_v2` at `FormalSystem/Metalogic/BXCanonical/Completeness.lean:361`;
  `completeness_dense` calls `countermodel_dense_enriched` at `Completeness.lean:266`; `completeness` calls
  `WeakCanonical.countermodel_discrete` at `Completeness.lean:228`.
- **`lean_references` spot-check**: `z_interval_countermodel` (`Transfer.lean:661`) returns exactly one
  reference — its own declaration. Zero consumers, LSP-confirmed.
- **Test-side textual sweep**: the only mention of any Group C identifier in `Tests/` is a *comment* at
  `Tests/BimodalTest/TemporalWitnessProbe.lean:142` (see Finding 6).

**Tool defect found and fixed during verification**: in this toolchain (Lean v4.33.0-rc1),
`ConstantInfo.value?` returns `none` for imported theorems; a first closure run silently traversed only
statement types and mislabeled `countermodel_dense_enriched` DEAD. Detected by checking the surprising verdict
against `Completeness.lean:221` proof text; fixed by direct `.thmInfo`/`.defnInfo` field access. All verdicts
below are from the corrected run.

### Finding 2 — Per-declaration verdict table

Buckets: **DEAD** (no path to any root; deleting changes no live theorem), **LIVE-P** (live, survives via
mechanical binder rewrite, possibly consuming 414's `isMax_timeShift`/`isMax_of_total`), **LIVE-P+lemma**
(live, statement true Omega-free, proof needs the new `multiFam_isMax_iff` characterization),
**LIVE-UNPORT** (live, the Omega-free restatement is unprovable on the current frame — genuine mathematical
obstruction). "Breaks" = statement mentions `TruthAt`/`valid`-family/`ShiftClosed` and will not compile
post-414; "orphaned" = still compiles but loses its role.

#### WeakCanonical/Transfer.lean (9 affected)

| Declaration (line) | Verdict | Evidence / note |
|---|---|---|
| `zIntervalTaskFrame` :568 | DEAD | closure; no ref outside device |
| `zIntervalHistory` :580 | DEAD | closure |
| `zIntervalHistory_shift_eq` :591 | DEAD | closure |
| `zIntervalOmega` :599 | DEAD | closure |
| `zIntervalOmega_shiftClosed` :602 | DEAD (breaks) | closure |
| `zIntervalHistory_mem_omega` :608 | DEAD | closure |
| `zIntervalBox_transparent` :616 | DEAD (breaks) | closure; **statement would survive Omega-free** — see Finding 5 |
| `z_interval_countermodel` :661 | DEAD (breaks) | closure + `lean_references` (sole ref = its own decl) + repo grep (no non-Boneyard file outside Transfer.lean mentions any zInterval identifier) |
| `countermodel_discrete` :1225 | **LIVE-P** (breaks) | consumer: `completeness` discrete branch (`Completeness.lean:228`). Restate Omega-free (`IsMax τ` packaging); its terminal `sorry` at :1242 — the repo's sole live sorry — persists unchanged (separate programme; not 414/415 scope) |

#### WeakCanonical/IntegerModel/ReynoldsBridge.lean (15 affected)

| Declaration (line) | Verdict | Evidence / note |
|---|---|---|
| `zTaskFrameV2` :453, `zHistoryV2` :461, `ZOmegaV2` :468, `zHistory_v2_mem_omega` :470, `zHistory_v2_shift_eq` :473, `zOmega_v2_shiftClosed` :481, `zTaskModelV2` :488, `zOmega_v2_mem_iff` :580 | DEAD (8) | closure — the single-family V2 device was superseded by multiFam and nothing reaches it. (`z_interval_carrier_contains_all` :502 and the `limitdom_*` cone are LIVE but Omega-FREE — model-theoretic/`TemporalTruth` side, preserved verbatim.) |
| `multiFamTaskFrame` :671 | LIVE-P+lemma (compiles unchanged) | chain: → `countermodel_discrete_reynolds_v2` → `completeness_discrete`. Deterministic serial clock frame: `TaskRel p d q ↔ p.1 = q.1 ∧ q.2 = p.2 + d` (read :671-680) |
| `multiFamHistory` :683 | LIVE-P+lemma (compiles unchanged) | total-domain flow line; `isMax_of_total` gives maximality in one line |
| `multiFamOmega` :694 | LIVE-P+lemma (compiles unchanged — plain `Set.range`) | becomes the RHS of `multiFam_isMax_iff` |
| `multiFamHistory_shift_eq` :698 | LIVE-P (compiles unchanged) | pure `timeShift` equation, Omega-free statement |
| `multiFamOmega_shiftClosed` :708 | LIVE-P+lemma (**breaks** — `ShiftClosed` deleted) | replaced by `multiFam_isMax_iff` + 414's `isMax_timeShift` |
| `multiFamHistory_mem_omega` :716 | LIVE-P (compiles unchanged) | set membership |
| `countermodel_discrete_reynolds_v2` :739 | LIVE-P+lemma (**breaks**) | packaging `(Omega, ShiftClosed, τ ∈ Omega) ↦ IsMax τ`; box case of the truth induction re-destructures via `multiFam_isMax_iff` (needs `[Nonempty FamIdx]`; satisfied by `f₀ := A` at :757) |

**Post-414 compile blast in this file is exactly 2 declarations** (`multiFamOmega_shiftClosed`,
`countermodel_discrete_reynolds_v2`) plus one new lemma — even smaller than Report B implied.

#### BXCanonical/Completeness.lean (4 affected)

| Declaration (line) | Verdict | Evidence / note |
|---|---|---|
| `completeness` :196 | LIVE-P (root) | statement text unchanged; packaging lines :220-229 mechanical, given restored suppliers (dense branch depends on the Finding-4 re-host) |
| `completeness_dense` :255 | LIVE-P (root) | ditto; dense branch consumes `countermodel_dense_enriched` :266 |
| `completeness_discrete` :296 | LIVE-P (root) | discrete branch consumes reynolds v2 :361; dense/mixed branches are pure proof theory, preserved |
| `countermodel_dense_enriched` :133 | **LIVE-UNPORT** (breaks) | statement survives; the *construction* instantiates the parametric-canonical device (:143-151) which cannot be internalized — Finding 4 |

#### Chronicle files

| Declaration | Verdict | Evidence / note |
|---|---|---|
| ChronicleMonadicBridge: `multiFamTaskFrameGen` :139, `multiFamHistoryGen` :158, `multiFamOmegaGen` :170, `multiFamHistoryGen_shift_eq` :176, `multiFamOmegaGen_shiftClosed` :188, `multiFamHistoryGen_mem_omega` :198, `multiFamTaskFrameGen_int` :209, `multiFamHistoryGen_int` :213, `multiFamOmegaGen_int` :217 | DEAD (9) | closure — the D-generic flow-frame family has no consumer yet. **Do not blind-delete**: this is exactly the seed of 415's `bundleFlowFrame` (Report B §4); archive-and-mine or leave for 415 to rewrite |
| ChronicleMonadicBridge: entire `chronicleMonadic*` cluster | DEAD but Omega-FREE | not a 414 obligation; listed for completeness of the file's status |
| ChronicleConstruction: **zero affected declarations** | — | Report A's "(4)" here is a **false positive**: every Omega hit in the file is a section-header comment about the `omegaChain` ω-iteration (`Set Formula`-level; lines 15, 213, 259, 1275, 1344). Most `omega_chain_*`/`limit_*` lemmas are LIVE via the dense suppliers and are untouched by 414 |
| ChronicleToCountermodelBasic: `countermodel_dense` :829 | DEAD (breaks) | closure — superseded by `countermodel_dense_enriched`. The suppliers in the same file (`cantorBfmcsDense`, `rootedCantorFmcsDense`, `cantor_bfmcs_dense_restricted_tc/buc/fuc`, `box_stable_*`) are LIVE and Omega-FREE — preserved, confirming Report B's ledger |
| MCSMixedCase: `countermodelChronicleMixed` :68 | DEAD (breaks) | closure. `mcs_mixed_case_absurd` :42 is LIVE, Omega-free, preserved |

#### Bundle/LimitMCS.lean (1 affected)

| Declaration | Verdict | Evidence |
|---|---|---|
| `fc_theorem_true_in_parametric_model` :467 | DEAD (breaks) | closure; states TruthAt over `ShiftClosedParametricCanonicalOmega` |

#### Algebraic/ (16 affected)

| Declaration | Verdict | Evidence / note |
|---|---|---|
| ParametricCompleteness: `parametric_canonical_completeness_relative` :193, `parametric_completeness_from_neg_membership` :213, `parametric_canonical_completeness_conditional` :263, `countermodel_implies_not_provable` :296 (+2 Omega-free helpers) | DEAD (4 breaking) | closure — the whole file is off the live path (the live dense route goes through `RestrictedParametricTruthLemma` instead) |
| ParametricHistory: `parametricToHistory` :68, `ParametricCanonicalOmega` :110, `ShiftClosedParametricCanonicalOmega` :124, `shiftClosedParametricCanonicalOmega_is_shift_closed` :152 (breaks), `parametricCanonicalOmega_subset_shiftClosed` :162 | **LIVE-UNPORT** (5, as a unit) | chain: → `countermodel_dense_enriched` → `completeness_dense`. The set defs still elaborate post-414, but the role they must play — "`IsMax σ ↔ σ ∈` this Omega" — is FALSE on the parametric frame (Finding 4). Superseded by the flow re-host. (`parametric_to_history_states/_domain_full/_mcs_eq`: DEAD, Omega-free) |
| ParametricTruthLemma: `parametric_canonical_truth_lemma` :240, `parametric_shifted_truth_lemma` :379 | DEAD (2, breaking) | closure — superseded by the `fully_restricted_*` pair. `parametric_box_persistent` :195 is LIVE and **Omega-FREE** (pure MCS-level: `□φ ∈ fam.mcs t → □φ ∈ fam.mcs s`, read :195-199) — preserved verbatim and reusable by the re-host. `ParametricCanonicalTaskModel` :108 LIVE, compiles, superseded by the flow model |
| RestrictedParametricTruthLemma: `restricted_parametric_shifted_truth_lemma` :119, `restricted_parametric_completeness_from_neg_membership` :253 | DEAD (2, breaking) | closure — only the `fully_restricted` forms are consumed |
| RestrictedParametricTruthLemma: `fully_restricted_parametric_shifted_truth_lemma` :286, `fully_restricted_parametric_completeness_from_neg_membership` :417 | **LIVE-UNPORT** (2, breaking) | chain: → `countermodel_dense_enriched` (:155) → `completeness_dense`. Obstruction in Finding 4 |

#### StrongCompleteness.lean (4 affected)

| Declaration | Verdict | Evidence / note |
|---|---|---|
| `SemanticConsequenceDedekindDense` :128, `truthAt_foldr_imp` :147, `semantic_deduction_dedekind_dense` :166, `soundness_dedekind_consequence` :292 | LIVE-P (4) | chains → `completeness_dedekind_of_engine` / `consequence_completeness_dedekind_of_engine`. Mechanical `(Omega, h_sc, h_mem) ↦ (IsMax τ)` binder rewrite, same pattern as 414's Group A `Validity.lean` family. Coordinate with in-flight task 408 (same file) |

#### Decidability/Verified/Bridge/ (~52 affected) + Correctness.lean (1)

| Declaration group | Verdict | Evidence / note |
|---|---|---|
| Bridge/Omega.lean: `regionOmega` :215, `regionHistory_mem_regionOmega` :218, `mem_regionOmega_iff` :222, `shiftClosed_regionOmega` :231, `regionOmega_total` :236, `truthAt_box_iff` :260, `truthAt_box_congr` :271, `truthAt_box_congr_history` :277, `truthAt_regionHistory_offset` :302, `truthAt_box_iff_base` :320 | **DEAD (10)** | closure: the only LIVE Bridge declarations are computable tableau gates (`boxContents`, `regionLabelCheck`, `boxAnchoredCheck`, `boxGridCheck`, `boxTemporalSpreadCheck`, `regionMeets`, `regionLabelCandidates`, guard/demand lists) — used by the engine, zero TruthAt content. `worldHistory_ext` :107, `regionFrame` :136, `regionHistory` :181 are DEAD but Omega-free (and `worldHistory_ext` is exactly the extensionality lemma `multiFam_isMax_iff` will want — mine it) |
| Bridge/TruthLemma.lean: `InterpInvariantAt` :75 + all 15 `interpInvariantAt*` lemmas | DEAD (16, breaking) | closure |
| Bridge/Valuation.lean: all 13 TruthAt/Gap declarations (`truthAt_atom_*` x4, `GapDemands`, `GapAdequate`, `branchGapVal_gapAdequate`, `gapDemands_trivial`, `not_leftCopy_gapAdequate`, `not_rightCopy_gapAdequate`, `refuteBox_gap`, `not_truthLemma_branchGapVal`, `gapAdequate_insufficient`) | DEAD (13, breaking) | closure |
| Bridge/IntTruth.lean: `truthAt_atom_state` :258, `BranchTruthAt` :282, the 11 `branchTruthAt*` lemmas, `not_valid_of_hasOpen_int` :1026, `not_validDiscrete_of_hasOpen_int` :1055 | DEAD (15, breaking) | closure; repo-wide grep: only non-IntTruth mention of `not_valid_of_hasOpen_int` is a comment in `TemporalWitnessProbe.lean:142` — see Finding 6 |
| Bridge/RegionLabel.lean: `truthAt_atom_branch_region` :461, `truthAt_atom_gap_of_box` :477 | DEAD (2, breaking) | closure (the label-machinery around them is LIVE but Omega-free) |
| Bridge/BoxSaturation.lean | 0 affected | its one Omega hit is a docstring |
| Correctness.lean: `decide_sound` :56 | LIVE-P | proof is two binder-plumbing lines (`intro D _ _ _ _ F M Omega h_sc τ h_mem t; exact soundness …` :57-58) → `intro D _ _ _ _ F M τ h_max t`. The other nine Correctness theorems never touch Omega textually |

### Finding 3 — The actual excision list, and the delta against Report A's ~80

**LIVE-AND-UNPORTABLE (the excision/re-host unit) — 8 declarations, all in the dense pipeline:**

1. `Algebraic/ParametricHistory.lean`: `parametricToHistory`, `ParametricCanonicalOmega`,
   `ShiftClosedParametricCanonicalOmega`, `shiftClosedParametricCanonicalOmega_is_shift_closed`,
   `parametricCanonicalOmega_subset_shiftClosed` (5)
2. `Algebraic/RestrictedParametricTruthLemma.lean`: `fully_restricted_parametric_shifted_truth_lemma`,
   `fully_restricted_parametric_completeness_from_neg_membership` (2)
3. `BXCanonical/Completeness.lean`: `countermodel_dense_enriched` (1)

Of these, the mathematically obstructed core is the last 3; the 5 device declarations are their substrate,
superseded wholesale by 415's `bundleFlowFrame` re-host. **If excised in 414 before the re-host lands, they
take `completeness_dense` and `completeness`'s dense branch with them (2 headline theorems)** — nothing else.

**Delta vs Report A (`excision_count 8` vs `report_a_estimate 80`)**: Report A's number is close to the count
of *dead* affected declarations (≈88), not of live-and-broken ones. Its five-file-group list mixes four very
different populations: dead devices (deletable, no restoration debt), the live-and-mechanical Dedekind/
decide plumbing, the live-and-salvageable multiFam discrete pipeline (Boneyarding it would needlessly kill
`completeness_discrete`, which is restorable in-place with one new lemma), and the genuinely obstructed dense
unit (8). Report A's "restored later by 415/417" framing therefore booked ~80 declarations of restoration debt
where the true figure is 8 declarations re-hosted (dense, 415) plus one dead-scaffolding re-host decision
(Bridge, 417/task-165 — Finding 6).

**Operational note for the 414 plan (dead ≠ ignorable)**: every *breaking* declaration, dead or live, must be
deleted/Boneyarded or rewritten for the post-414 build to stay green. The workload split is:
≈88 dead breaking/orphaned declarations → delete or Boneyard (zero live impact, zero restoration obligation on
any live path; keep `multiFamOmegaGen*` and `worldHistory_ext` minable); 9 live mechanical rewrites; 2 live
rewrites + 1 new lemma (discrete); 8-declaration dense unit → planner's ratification point (Boneyard-until-415
vs co-land with 415's dense phase).

### Finding 4 — Verification of Report B's claims (all three confirmed)

**(a) `z_interval_countermodel` has zero live references — CONFIRMED, three independent ways**: kernel closure
(DEAD, no witness chain); `lean_references` at `Transfer.lean:661` returning only the declaration itself; repo
grep showing no non-Boneyard file outside `Transfer.lean` mentions any zInterval identifier.

**(b) `countermodel_discrete_reynolds_v2` at `ReynoldsBridge.lean:739` is the live discrete pipeline —
CONFIRMED**: declaration verified at :739; proof-text call at `Completeness.lean:361`; closure chain
`multiFamOmega → countermodel_discrete_reynolds_v2 → completeness_discrete`.

**(c) `multiFamOmega` = the full maximal-history set of `multiFamTaskFrame` given `Nonempty FamIdx` —
CONFIRMED as mathematics (not yet Lean-checked)**: the frame (read :671-696) is a deterministic serial clock
(`TaskRel p d q ↔ p.1 = q.1 ∧ q.2 = p.2 + d`; exactly one d-successor from every state, every d), so
`respects_task` forces any history with an anchor `(s, (f, z))` onto the flow line `t ↦ (f, z + (t - s))`;
non-total histories are properly extended by `multiFamHistory f (z - s)`; total ones equal it up to
funext/propext/proof-irrelevance (in-repo precedent: `multiFamHistory_shift_eq` :698's
`change WorldHistory.mk …; congr 1`, and the dead-but-minable `worldHistory_ext`, `Bridge/Omega.lean:107`).
The `[Nonempty FamIdx]` fence for the empty history is required and satisfied on the live path (`f₀` :757).
Residual risk is the equality bookkeeping only: Medium-High, matching Report B's own rating.

Also confirmed: **Boneyard is not in the build** (no `import FormalSystem.Boneyard` outside `Boneyard/`
itself; lakefile roots = `FormalSystem`), and **the sole live `sorry` term in non-Boneyard `FormalSystem/` is
`Transfer.lean:1242`** (token-level grep; every other "sorry" hit is prose/comments; corroborated by
`WeakCanonical.lean:73` and the axiom audit at `Completeness.lean:371-409`).

### Finding 5 — Verification of Report A's central claim: REFUTED at its witness, real elsewhere

Report A (Finding 9) claims `zIntervalBox_transparent` (`Transfer.lean:616`) is "mathematically false under
maximal-history semantics." **The claim is wrong for that declaration.** `zIntervalTaskFrame` has
`WorldState := Unit` and a trivial task relation, so *every* total history has `states = fun _ _ => ()` and
all total histories are propositionally equal (via `worldHistory_ext`-style funext/propext); non-total
histories extend properly, so the maximal histories form a singleton up to equality. Under Omega-free
maximal-history box, `□ψ ↔ ψ` at `zIntervalHistory` therefore remains TRUE — the singleton-Omega *proof* dies,
but the *statement* survives with a maximal-history-characterization proof. Since the declaration is dead, the
set of reachable declarations depending on it is **empty** — the dependency set Report A's excision argument
needed does not exist.

The obstruction Report A gestured at ("box quantifies over a set the construction does not control") is
nonetheless real, in exactly two places, neither of which Report A examined:

1. **LIVE — the dense parametric device** (Report B Finding 4, independently re-verified here):
   `ParametricCanonicalTaskFrame` (`Algebraic/ParametricCanonical.lean:207`, read directly) has
   `WorldState := ParametricCanonicalWorldState fc` = *all* MCS pairs and non-deterministic
   `TaskRel := ParametricCanonicalTaskRel` via `ExistsTask`. Take any MCS `M'` with `p ∈ M'` while
   `□¬p ∈ fam.mcs t` (Lindenbaum on the consistent `{p}`); the singleton history `{t ↦ M'}` is legal
   (`nullity_identity` covers the only obligation) and extends by 414's Zorn lemma to a maximal σ' through
   `(t, M')`; the atom clause reads `p` true there, so the Omega-free `□¬p` is false at `t` while `□¬p` is in
   the MCS — the restated truth lemma is *refutable*, not merely unproven. Hence the 8-declaration unit in
   Finding 3 must be re-hosted on a deterministic flow frame, exactly Report B's `bundleFlowFrame` design.
2. **DEAD — the Decidability Bridge's `regionFrame`** (new finding, Finding 6).

### Finding 6 — New finding: the entire TruthAt-side Decidability Bridge is dead, and also unportable as built

Neither prior report analyzed `Decidability/Verified/Bridge/`. Two independent facts:

**(i) Dead.** All ~52 TruthAt/Omega-touching Bridge declarations are unreachable from every root — including
all ten Correctness.lean theorems and every test. The decidability headliners consume `soundness` and the
tableau engine only (e.g. `decide_sound` = 2 lines delegating to `soundness`); `not_valid_of_hasOpen_int` and
`not_validDiscrete_of_hasOpen_int`, the Bridge's intended termini, have no consumer. The only live Bridge
declarations are the computable branch-gate functions, which contain no semantics.

**(ii) Unportable as built.** `regionFrame` (`Bridge/Omega.lean:136`) deliberately takes the *weakest* task
relation `TaskRel s d s' := d = 0 → s = s'` (its docstring: "asking for no more keeps `respects_task` free for
every history"). Consequence under Omega-free semantics: *any* total function `D → W × (Set ι × Set ι)` is a
legal history, so the maximal histories are ALL total state-assignments, and for any state `s` and time `x`
some maximal history sits at `s` at `x`. Omega-free `□p` on this frame therefore means "`p` holds at every
world-state of the frame whatsoever" — `truthAt_box_iff_base` (:320), the box interface of the whole
`InterpInvariantAt`/`BranchTruthAt` chain, becomes flatly false (junk region-codes and gap states included).
The frame cannot be repaired by strengthening `TaskRel` on the same state space (a region code does not
determine its time — `regionCode` is non-injective), so the restoration route is a deterministic re-host with
`WorldState := W × D` — i.e. `multiFamTaskFrame` with `FamIdx := W`, generalized from ℤ to D. The generic
`truthAt_box_iff`/`truthAt_box_congr`/`truthAt_box_congr_history` (:260-280) survive Omega-free with
`isMax_timeShift` in place of `hsc` (their proofs are shift-arguments, frame-independent).

**Coordination flag (in-flight work)**: `Tests/BimodalTest/TemporalWitnessProbe.lean:142` (task-165 territory,
actively committed on main) records that sub-phase 7.3 must discharge `regionLabelCheck b ord = true` — the
hypothesis of `not_valid_of_hasOpen_int`. The Bridge is dead-but-imminent scaffolding: 414 must excise or
rewrite its breaking declarations to keep the build green, and the in-flight tableau-completeness programme
must be told that its 7.3 target lemma will be restated Omega-free AND that its proof route
(`truthAt_box_iff_base`) needs the deterministic re-host. Boneyarding the Bridge without flagging this would
silently strand task 165.

### Finding 7 — Consolidated counts

| Bucket | Count | Members (by group) |
|---|---|---|
| DEAD (affected) | ≈88 | Transfer device 8; V2 device 8; `multiFamOmegaGen` family 9; `countermodelChronicleMixed` 1; `countermodel_dense` 1; `fc_theorem_true_in_parametric_model` 1; ParametricCompleteness 4; superseded parametric truth lemmas 4; Bridge ~52 |
| LIVE-P (mechanical) | 9 | StrongCompleteness 4; `decide_sound` 1; `countermodel_discrete` 1 (sorry persists); `completeness`/`completeness_dense`/`completeness_discrete` 3 (statement text unchanged) |
| LIVE-P+lemma (discrete) | 7 | `multiFamTaskFrame`, `multiFamHistory`, `multiFamOmega`, `multiFamHistory_shift_eq`, `multiFamHistory_mem_omega`, `multiFamOmega_shiftClosed`, `countermodel_discrete_reynolds_v2` (only the last two break textually) |
| **LIVE-UNPORT (excision list)** | **8** | ParametricHistory unit 5 + `fully_restricted_*` pair 2 + `countermodel_dense_enriched` 1 |

## Divergence Audit (H5)

| Target | Report A | Report B | Authoritative verdict |
|---|---|---|---|
| `Transfer.lean:568-687` device | live-ish, unportable, excise | dead, delete | **DEAD** (closure + LSP + grep). B right; A wrong on liveness, wrong on mathematical falsity of :616 (Finding 5) |
| Discrete pipeline | inside 80-decl excision | small localized rebase | **B right**: 2 breaking decls + 1 new lemma; `completeness_discrete` restorable in-place |
| Dense pipeline | inside 80-decl excision | frame re-host required | **Both partially right**: 8 live decls genuinely obstructed (A's concern real here); scope is 8, not 80 (B's re-host is the fix) |
| Decidability Bridge | inside 80-decl excision, unanalyzed | not covered (out of 415 scope) | **Neither examined it**: dead (~52 affected decls) AND unportable-as-built; task-165 coordination required (Finding 6) |
| ChronicleConstruction "(4)" | counted as Group C | not covered | **False positive** — ω-chain comment hits, zero affected declarations |
| StrongCompleteness / Correctness | inside Group C | mechanical restate | **B right**: mechanical (LIVE-P) |

**What each report got right**: A — the existence and precise shape of the maximal-history box obstruction
(its Finding 9 argument is exactly correct *for the parametric frame*), the completeness-file inventory, and
the insight that 414 must keep the build green. B — every checked factual claim (device deadness, live
pipelines, multiFam characterization, parametric refutation, sole sorry, preserved-assets ledger).

**What each got wrong**: A — no reachability analysis at all: "declaration textually mentions Omega in a
completeness-adjacent file" was treated as "live consumer of the singleton-Omega device", inflating 8 to ~80
and mislocating the obstruction onto a dead declaration where the claimed falsity does not even hold. B — scope
too narrow: correct within 415's dense/discrete lanes but silent on the Bridge (~52 decls) and on the dead
V2/Gen device families, so its "small and localized" framing understates 414's total dead-code disposal work.

**Root cause of the divergence**: fix.md C1 (read directly, confirmed) cites `Transfer.lean:603-638` as the
"concrete witness" that "the Lean completeness proofs rest on" singleton-Ω countermodels. That citation is
stale as a call-graph claim (Report B flagged this; independently confirmed here — the device has had zero
consumers). Report A inherited the stale premise as ground truth for where completeness lives, and — having
verified its own (excellent) semantics-core prototype but performed only grep-level analysis on Group C —
generalized one dead device's unportability across five file groups. Divergence class: **different evidence
standards on the same region** (A: textual occurrence; B: reference-level), not different definitions of
"live". The fix applied here is the missing third standard: kernel-level reachability with stated roots.

## Adversarial Self-Verification

| Claim | Source/Counterexample probe | Verification Method | Confidence |
|---|---|---|---|
| Root set as stated; default target = `lean_lib FormalSystem`; exes/tests as listed | `lakefile.lean` read (default_target, testDriver, 11 exes) | direct read | High |
| Reachability verdicts (all LIVE/DEAD labels above) | kernel used-constants closure, 2,108 roots, corrected for the `value?` elision defect; probe: does the closure reproduce the proof-text calls at `Completeness.lean:221/228/266/361`? (yes) | Lean metaprogram vs proof-text cross-check | High |
| First closure run was WRONG (`value?` = none for imported theorems on v4.33.0-rc1) | `countermodel_dense_enriched` flagged DEAD vs its literal call at `Completeness.lean:221` | probe program (`has value: false`; direct `.thmInfo` access shows 57 deps) | High — and the reason verdicts were not published until fixed |
| `z_interval_countermodel` zero consumers | — | `lean_references` (sole item = own decl) + closure + repo grep | High |
| `zIntervalBox_transparent` statement SURVIVES Omega-free (Report A refuted at witness) | Unit-state frame: all total histories propositionally equal; maximality ⇒ totality | mathematical argument against read defs (`Transfer.lean:568-599`) | High (argument), n/a in Lean |
| Parametric frame refutes Omega-free truth lemma (excision unit is genuinely unportable) | junk maximal history through a `p`-MCS at `t` | argument against read defs (`ParametricCanonical.lean:207-215`; uses 414's Zorn lemma) | High |
| `multiFam_isMax_iff` provable (given `Nonempty FamIdx`) | empty-history edge case; equality bookkeeping | frame/history defs read :671-717; precedent `multiFamHistory_shift_eq`, `worldHistory_ext` | Medium-High (bookkeeping risk only) |
| Bridge dead | probe: tests? (only a comment mention); Correctness? (`decide_sound` = 2-line delegation to `soundness`, read :56-58); CountermodelExtraction? (comments only, grep) | closure + grep + bounded reads | High |
| Bridge unportable as built (`truthAt_box_iff_base` false Omega-free) | weakest TaskRel ⇒ arbitrary total histories maximal ⇒ box = global-state truth | argument against `Bridge/Omega.lean:136-139,181-199,320` (read in full) | High |
| Sole live sorry = `Transfer.lean:1242` | probe: "sorry stub" comments in RRelation/SplitPoint/GoodStructuresModelSurgery — token-level check found no proof-term sorry in any of them | token grep + targeted `^sorry$`/`:= sorry` grep + docs at `WeakCanonical.lean:73` | High |
| Boneyard not in build | — | import grep (zero non-Boneyard importers) | High |
| Excision count 8 vs Report A's 80 | full per-declaration table above | arithmetic over verified verdicts | High |

**Contradiction log**:
1. Metaprogram round 1 ("`countermodel_dense_enriched` DEAD") vs proof text (`Completeness.lean:221`).
   Resolution per precedence: proof text (primary source) outranks tool output; tool defect found
   (`ConstantInfo.value?` elision) and fixed; all round-1 verdicts discarded. Recorded because publishing
   round 1 would have been catastrophic for the planning decision.
2. Report A Finding 9 ("box-transparency at :616 mathematically false") vs the Unit-frame argument here.
   Resolution: direct mathematical check on the read definitions wins; A's claim refuted at the witness,
   relocated to the parametric frame and regionFrame where it does hold. No unresolved contradictions remain.
3. fix.md C1 witness citation vs live call graph: resolved as stale (machine-checkable repo state wins);
   fix.md C1's *conclusion* (statements are Ω-relativized; completeness does not transfer as stated) remains
   correct.

**Recommendations modified after verification**: (a) round-1 DEAD verdicts for the dense pipeline reversed
after the tool fix; (b) the Bridge was initially assumed live via the decidability headliners — reversed to
DEAD after the closure + `decide_sound` read; (c) planned second/third `lean_references` sweeps were replaced
by the kernel closure + proof-text cross-checks once the closure proved strictly stronger (one LSP spot-check
retained as calibration).

## Recommendations for the Planner

1. **Ratify the 8-declaration excision unit** (Finding 3) as 414's only Boneyard-with-restoration-debt item,
   with the explicit cost: `completeness_dense` + `completeness`'s dense branch temporarily absent unless
   414's tail co-lands with 415's dense re-host. Alternative worth pricing: sequence 415-Discrete
   (2 rewrites + `multiFam_isMax_iff`) into 414's final phase so `completeness_discrete` never goes dark.
2. **Dispose of the ≈88 dead affected declarations in 414** (delete or Boneyard — no restoration obligation).
   Keep `multiFamOmegaGen*` (bundleFlowFrame seed) and `worldHistory_ext` explicitly minable in the
   Boneyard inventory commit.
3. **Do NOT Boneyard the multiFam discrete pipeline** — restore in place (bucket LIVE-P+lemma).
4. **File the Bridge coordination flag** with the task-165/410-412 tableau programme and 417: its 7.3 target
   (`not_valid_of_hasOpen_int`) must be restated Omega-free and its box interface re-hosted on a
   `WorldState := W × D` clock frame (Finding 6).
5. Mechanical rewrites (StrongCompleteness 4, `decide_sound`, `countermodel_discrete` restatement) belong in
   414's Group B phases; coordinate StrongCompleteness with in-flight task 408.

## References

- `specs/414_refactor_semantics_to_maximal_history_validity/reports/01_maximal-history-validity-refactor.md` (Report A)
- `specs/415_completeness_over_maximal_history_semantics/reports/01_completeness-maximal-history-rebase.md` (Report B)
- `/home/benjamin/Philosophy/Papers/PossibleWorlds/Comments/fix.md` — B1 (:62-83), C1 (:118-132), C2 (:133-145)
- `lakefile.lean`; `FormalSystem/Metalogic.lean:30-46`
- `FormalSystem/Metalogic/BXCanonical/Completeness.lean:120-370`; `FormalSystem/Metalogic/WeakCanonical/Transfer.lean:568-687,1206-1245`
- `FormalSystem/Metalogic/WeakCanonical/IntegerModel/ReynoldsBridge.lean:440-780`
- `FormalSystem/Metalogic/Decidability/Verified/Bridge/Omega.lean` (read in full); `Bridge/IntTruth.lean:1026-1078`
- `FormalSystem/Metalogic/Algebraic/ParametricCanonical.lean:195-215`; `ParametricTruthLemma.lean:186-199`
- `Tests/BimodalTest/TemporalWitnessProbe.lean:125-165`
- Reachability artifacts (session-local): closure metaprogram + verdict dump (scratchpad `reach.lean`, `reach-out2.txt`)
