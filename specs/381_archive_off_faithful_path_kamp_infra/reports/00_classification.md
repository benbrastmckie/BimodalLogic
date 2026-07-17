# Phase 0 Classification: keep-set / archive-set / per-file

## Method (binding criterion)

Live build closure = transitive `import` closure of `Theories/Bimodal.lean` (the sole
`@[default_target] lean_lib Bimodal` with `roots := #[Bimodal]`, no globs). A module is compiled
("a build job") **iff** it is in that closure. `Kamp/Boneyard/` is compiled by NO lake target
(`BoneyardArchive` globs only `Bimodal.Boneyard`, not `...Kamp.Boneyard`), so moving a
NOT-in-closure file into `Kamp/Boneyard/` changes the job count by **zero**.

Machine-computed live closure size: **239 Bimodal modules** (baseline `lake build` = 1766 jobs).

**Consequence for the 1766 guardrail**: archiving a file that is NOT in the live closure
provably keeps the job count at exactly 1766. Archiving a file that IS in the closure (compiled)
would DROP the count below 1766. This distinction drives every classification below.

## Archive-set — whole-file moves, NOT in live closure (job-count-neutral)

Verified `IN_LIVE_CLOSURE=False`, safe clean-win moves:

| File (module leaf) | Live importers | Batch |
|--------------------|----------------|-------|
| InteriorHrealSupplyK | 0 | Phase 1 |
| ExteriorFiberProbeK | 0 | Phase 1 |
| ExteriorFiberDeepAnchorProbe367K | 0 | Phase 1 |
| ExteriorPinnedProbeK | 0 | Phase 1 |
| ExteriorPinnedProbeM1K | 0 | Phase 1 |
| SeamPairRefutationProbe | 0 | Phase 1 |
| ZoneSeamCrossContextProbe | 0 | Phase 1 |
| ExteriorAmbientDeepAnchorProbe358K (rename → ExteriorAmbientDeepAnchorProbeK) | 0 | Phase 2 |
| ExteriorFiberConsistencyProbe364K | 0 | Phase 2 |
| ExteriorFiberConsistencyProbeK | 0 (1 probe importer: ExteriorPinnedProbe358K) | Phase 2 |
| ExteriorPinnedProbe358K (rename → ExteriorPinnedProbeAnchorK) | 0 | Phase 2 |
| ExteriorPinnedProbe358TailK (rename → ExteriorPinnedProbeTailK) | 0 | Phase 2 |

Intra-set import to rewrite: `ExteriorPinnedProbe358K` imports `ExteriorFiberConsistencyProbeK`
(both move; rewrite import to Boneyard path).

## Archive-set — dead GHR separation cluster, NOT in live closure (Phase 3, LOUD headers)

Verified `dead` (not in closure). LIVE `Separation.Defs`, `Separation.KampTranslation`,
`Separation.SemanticBridge` are EXCLUDED (kept). Dead cluster to move:

- `Separation.lean` (dir aggregator), `Separation.SeparationThm`
- `Separation.Distributivity`, `.DualEliminations`, `.Duality`, `.Eliminations`, `.FormulaOps`,
  `.IntHelpers`, `.NegationEquiv`, `.NormalForm`, `.TemporalClosure`
- `Separation.DedekindZ.Cases`, `.DedekindZ.QLemma`
- `Separation.Hierarchy.HierarchyCaseSep`, `.HierarchyCompletion`, `.HierarchyDefs`, `.HierarchyInduction`
- `ExpressiveCompleteness.Theorem`, `ExpressiveCompleteness.QuantifierElimination`

(`Kamp.Boneyard.SeparationBridge` already lives in Boneyard — pre-existing, untouched.)
The dangerous `ExpressiveCompleteness/Theorem.lean` signature-generalized `outerIH` gets an
explicit "NOT the E[Sigma] solution, do not consume" header.

## Keep-set (MUST NOT archive)

Live spine `completeness_discrete → … → nf_nvar_exist_all_depths`; k=0/k=1 arms; reusable
faithful assets (Prop 3.5 translate*, contentful Prop 4.2 negFix_iff, consumed NfEFold vocab);
parked EANegation sorries; LIVE Separation modules (Defs/KampTranslation/SemanticBridge);
`RefutationF2` (see blocker B2).

## BLOCKERS discovered in Phase 0 (surface to user)

### B1 — Phase 4 (dead Fib decl extraction) is unexecutable as written
`igFoldBitFib`/`igEpLFib`/`igEpRFib`/`igPtWFib` (defined in `InteriorGateGeneralK.lean`) are
GENUINELY CONSUMED IN PROOF TERMS of live-closure declarations — e.g. `kvExtFib_gate_henv` in
`ExteriorGateAssembleK.lean` uses `simp only [igMkDisjunctFib, igEpLFib, TemporalPred.eval_at]`
(line 523), `simp only [igEpRFib]` (529), `simp only [igPtWFib]` (535), and the hypothesis type
at 509-510 `(igPtWFib … (igFoldBitFib qnf)).eval_at`; `KampPrior.lean:1139-1211` mirrors these.
The plan's Phase 4 premise ("live importers use only the retained LIVE decls; extract the dead
Fib decls, importers still resolve") is contradicted by machine evidence: the importers use the
Fib decls directly. Extracting them breaks compilation of `ExteriorGateAssembleK.lean` and
`KampPrior.lean` (both live-closure). Properly archiving per the binding criterion would require
cascading proof-term-reachability splits of MULTIPLE live-closure files (ExteriorGateAssembleK,
KampPrior, …) — new surgery, not clean relocation, risking loss of a live declaration and a
job-count drop below 1766. Per `plan-compliance.md`, escalate rather than deviate. **[BLOCKED]**

### B2 — Phase 5 (aggregator prune) conflicts with the 1766 floor
The `NfMultiAnchorBridge.lean` aggregator imports NONE of the Phase 1-3 archived modules (verified
against its 33-import list), so after Phases 1-3 it has zero dangling imports — nothing to prune.
The only archive-*candidate* it imports is `RefutationF2` (`f2_relativized_refutation`, verified
UNUSED externally = dead-but-compiled). But `RefutationF2` IS in the live closure (compiled via
the aggregator), so pruning its import DROPS the job count to 1765, violating the explicit
"GREEN at 1766 jobs" guardrail. Phase 5 as written ("shrink the closure while staying at 1766")
is internally contradictory. **[BLOCKED]** — user must choose: relax the 1766 floor to allow
dead-code closure reduction (then prune RefutationF2 + archive it), or keep 1766 and retain
RefutationF2 in place.

### Phase 6 — already satisfied (no blocker)
Machine check: ZERO live-closure modules import any `.Boneyard.*` module. The report's F6
importers (`Kamp/Prop43.lean`, `NfMultiAnchorBridge/NavigatedEndChar.lean`) are themselves NOT in
the live closure, so there is no live-import-into-Boneyard to sever. No promotion needed.
