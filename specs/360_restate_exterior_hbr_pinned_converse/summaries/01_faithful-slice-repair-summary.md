# Task 360 Summary: Faithful Slice-Keyed Repair of the Exterior `hbr*` Pinned Converse

**Status**: COMPLETED (all 9 phases, zero-debt gate green) · **Plan**: plans/02_faithful-slice-repair.md (v2)
**Sessions**: sess_1783950096_9d2925 (final) · **Ground truth**: Rabinovich 2014 (Def 7.13, Cor 5.4, Lemmas 7.8/7.10)

## What Changed

The four exterior pinned-converse obligations `hbrFutReal`/`hbrFutSat`/`hbrPastReal`/`hbrPastSat`
were machine-refuted as unsatisfiable in their v1 shapes (ℤ-doppelgänger counterexample,
`kvE_futPinned_of_end_zero_refuted`, ExteriorPinnedConverseK.lean:500 — preserved as the standing
regression guard). This task **eliminated all four** and replaced the consumption chain with a
faithful **slice-keyed, fiber-guarded interface**:

- **Slice-keyed brackets** (ExteriorBracketAssembleK.lean): range re-keyed to
  `kvE_{fut,past}Admissible σ && decide (nfk_dropFresh σ = qnf.1)` (admissible ∧ FIBER), clauses
  keyed per slice via `kvE_futSliceMarked`; `_iff` ×2 and D1–D4
  (`kvE_extBracket{Fut,Past}_{sound,complete}`) re-proved with the per-σ fiber antecedent.
- **Gate** (ExteriorGateAssembleK.lean): `bracketEndChar_kvExt_holds_iff` /
  `bracketEndChar_kvExt_correct_prior` with fiber-guarded `hslice*` binders; new private
  `kvExt_gate_henv` gives the ⇒-callback an off-fiber refutation kernel
  (`nf_eval_nf_atom_layer` → `nf_eval_nf0_cons_factor` → `nf_eval_unique`), so off-fiber σ are
  refuted internally — consumers never owe off-fiber content.
- **Slice-id converses**: `kvE_futSliceId_of_end_zero` (ExteriorPinnedConverseK.lean:891) and
  `kvE_pastSliceId_of_end_zero` (ExteriorPinnedConversePastK.lean:530).
- **Four m=0 supply theorems** discharging the new obligations at end-zero:
  `kvE_hsliceFut_supply_zero`, `kvE_hslicePast_supply_zero`, `kvE_hexclSliceFut_supply_zero`,
  `kvE_hexclSlicePast_supply_zero`.
- **Consumer mirrors**: EndIntervalConsumerK.lean (`endInterval_step_correct`) and
  KampPrior.lean (`kampPrior_site_rungK_gate_match`, :838–888) re-keyed to the `hslice*` /
  `hexclSlice*` binder shapes (mirrors only; threading unchanged).

## The Three Faithful Rabinovich-Grounded Repairs

All three blockers were repaired by transcription from the frozen k=2 template + the paper, each
adjudicated by machine probes (ExteriorPinnedProbeK.lean) before landing:

1. **Per-σ keying → slice keying** (report 02): the v1 per-σ-bit obligation asserted content
   Def 7.13's disjunct does not own; repaired by keying clauses per slice
   (`kvE_futClause_sliceConstant`), matching the paper's per-adjacent-segment brackets.
2. **Fiber filter restored** (report 03/04): the bracket range had widened past the qnf-fiber;
   restored `nfk_dropFresh σ = qnf.1` as a range conjunct — lossless for honest consumers because
   the honesty bridge `nf_eval_nfk_iff_efold` (NfEFold.lean:612/:627) is itself fiber-guarded,
   with off-fiber falsity a separate disjunct-owned fact.
3. **Conjunct-4 admissibility** (report 03, PastK): the depth-k `kvE2_pastAdmissible`
   reformulation had dropped condition 4, which the frozen k=2 carried symmetrically; restored in
   the PastK admissibility layer.

## Zero-Debt Gate (Phase 6 audit outputs)

| Audit | Command | Result |
|---|---|---|
| Full build | `lake build` | **GREEN** — "Build completed successfully (1736 jobs)", exit 0 |
| Sorry census (territory) | `lean-sorry-census.sh .../NfMultiAnchorBridge/` | **sorry_count: 0** |
| Vacuous defs | pattern grep over `Theories/` | **0 introduced** (sole repo hit: pre-existing `int_domain_universal := trivial`, Examples/TemporalStructures.lean:269, last touched task 969) |
| Axiom audit | `#print axioms` on all 18 key results (4 supply, 2 slice-id converses, `_iff`×3, D1–D4, gate ×2, `endInterval_step_correct`, `kampPrior_site_rungK_gate_match`, refuted-guard) | **all exactly `[propext, Classical.choice, Quot.sound]`** |
| New axioms | `grep "^axiom "` | **0 declarations** (2 grep hits are docstring prose in Boneyard) |
| `hbr*` elimination | grep 4 binder names repo-wide | **0 live binders** (1 docstring: "unlike the eliminated `hbrFutSat` shape"; all other `hbr`-prefixed identifiers are unrelated pre-existing hypothesis names in SharedWitness/Boneyard) |
| Preserved assets | git history | frozen `ExteriorBracket.lean` last touched task 348 (`1d4a06832`); `kvE_futPinned_of_end_zero_refuted` axiom-clean and byte-unchanged |

## Frozen k=2 Audit Finding (recorded, no edit)

The plan flagged the frozen k=2 layer (`kvE2_extBracketFut`, ExteriorBracket.lean:364–372) for a
same-defect audit. **Finding: the k=2 layer is internally consistent and is the CORRECT
template, not defective.** Both `kvE2_futMarked` (:124–131) and `kvE2_pastMarked` (:137–144)
already carry the fiber conjunct `decide (nf0_dropFresh σ.1 = qnf.1)` alongside the zone-spec and
per-zone bit-agreement conjuncts — exactly the constraint the depth-k rewrite dropped. The k=2
gate discharges `hexclExt` internally; its only live consumer is the KampPrior:351 n=1 arm
(`bracketEndChar_kvE2Ext_correct_two_prior_frag`, task-309-owned strategic sorry, task-348
transfer note), which does **not** need the slice-keyed interface. No k=2 consumer requires
migration.

## Recommended Follow-Up (do not skip): Task-352 Depth-k Rewrite Audit

All three blockers this task fixed trace to **one root cause: task-352's depth-k rewrite
systematically dropped constraints the frozen k=2 template kept** — (1) per-σ keying coherence
(below-zone bit agreements' role), (2) the fiber filter `nf0_dropFresh σ.1 = qnf.1`, (3)
PastK admissibility condition 4. Three independent regressions of the same family strongly
suggest further latent regressions in other depth-k reformulations produced by task 352. A
dedicated audit task should diff every depth-k definition against its frozen k=2 counterpart,
conjunct by conjunct (evidence: report 04 §1.1 comparison table; reports 02/03 for the other two
instances).

## Downstream Consumer Contract

- **Task 349 v8 Phase 6** must consume the NEW slice-keyed interface: the fiber-guarded
  `hslicePast`/`hsliceFut`/`hexclSlicePast`/`hexclSliceFut` binder shapes (see
  `kampPrior_site_rungK_gate_match`, KampPrior.lean:856–888) — NOT the eliminated `hbr*` shapes.
- **Task 358** (KampPrior:361 exterior arm): the arm's exterior obligations are now supplied at
  m=0 by the four `kvE_h{slice,exclSlice}{Fut,Past}_supply_zero` theorems.

## Artifacts

- Reports: 02_faithful-pinned-converse-repair.md, 03 (PastK repairs), 04_fiber-range-bracket-rekey.md
- Plan: plans/02_faithful-slice-repair.md (all phases [COMPLETED])
- Probes: ExteriorPinnedProbeK.lean (P1–P3 machine adjudications, persisted)
- Key commits: `83fd80e78` (P1), `6453bee06` (P2), `1bbb8d741` (hexclSlice pair), `114644bf3`
  (P3c fiber re-key), `c03f359f0` (P5 hslice pair), plus the Phase 6 gate commit.
