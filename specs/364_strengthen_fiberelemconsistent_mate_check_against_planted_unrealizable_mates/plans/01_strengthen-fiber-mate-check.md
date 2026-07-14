# Implementation Plan: Task #364

- **Task**: 364 - Strengthen kvE_fiberElemConsistent mate check against planted unrealizable mates
- **Status**: [NOT STARTED]
- **Effort**: 10 hours
- **Dependencies**: Task 363 (landed interface, starting point); blocks task 358 Phase 2/3 resume
- **Research Inputs**:
  - specs/358_realization_recursion_nf_nvar_exist_all_depths/reports/07_spawn-analysis.md
  - specs/358_realization_recursion_nf_nvar_exist_all_depths/handoffs/phase-2-handoff-20260714.md
- **Artifacts**: plans/01_strengthen-fiber-mate-check.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md, .claude/rules/lean4.md
- **Type**: lean4
- **Lean Intent**: false

## Overview

Task 363's depth-graded fiber-consistency guard `kvE_fiberElemConsistent`
(`Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge/ExteriorFiberConsistencyK.lean:48-57`)
has an atom-row-only mate check: `mergeNF e.atom_assgn ⟨1,_⟩ = s'.atom_assgn` over σ-marked `s'`,
with no content, realizability, or fresh-projection constraint on the mate. The sorry-free
certificate `kvE_probe358_eP_atomMate_present` (`ExteriorPinnedProbe358K.lean:134`) machine-refutes
it: the planted mate `(mergeNF e_P.atom_assgn ⟨1,_⟩, fun _ => false)` — unrealizable, vacuously
elem-consistent, interior-zoned — supplies exactly the atom row task 363 proved absent, restoring
the m=1 doppelganger countermodel one layer deeper. This task strengthens the mate check in place
so the plant is rejected while every honestly realized fiber remains accepted and task 363's
original m=1 fake remains rejected. Scope is the interface strengthening plus re-probe ONLY; the
general-m G1/G2 supply build-out stays with task 358.

**Definition of done is the re-probe, not the restated signature**: every phase below ends at a
machine-checkable green/refute gate (a named sorry-free certificate or a scoped `lake build`), per
task 363's probe-first methodology. Zero-debt terminus: no sorry, no vacuous def, no forcing a
proof against a live countermodel. If neither candidate approach closes green, exit `[BLOCKED]`
with a structured escalation.

### Research Integration

From the spawn analysis (report 07) and phase-2 handoff:
- The hole is exterior-leg (G2) only; G1's separation (`kvE_probe363_qnfG1_antecedent_fails`)
  stands because the plant is projection-VISIBLE (fresh coordinate 20 sits inside the
  projection-read bracket).
- Approach (a) — fresh-projection/content-aware mate check — is flagged as the most promising
  direction, mirroring 363's own G1 separation. Approach (b) — realizability-anchored mate — is
  the fallback; a synthesis is acceptable.
- `kvE_probe358_eP_atomMate_present` is a statement about raw atom rows; it remains TRUE after any
  strengthening. The successor gate must therefore be stated at GUARD level (the strengthened
  `kvE_fiberElemConsistent` rejects `s*` within σ₂), not as a negation of the 358 probe statement.
- The not-yet-mechanized σ₂-level universal (`kvE_futAdmissible σ₂ = true` in full, u-class
  enumeration) is what the strengthened interface must make FALSE — Phase 5's gate certificate
  `kvE_futAdmissible m2sigma = false` discharges exactly this.

### Prior Plan Reference

No prior plan for task 364. Effort calibration and methodology come from task 363's successful
same-shape execution (probe-first candidate validation, verbatim promotion to production home,
consumer restatement, Phase-5 re-probe against restated production — visible in
`ExteriorFiberConsistencyProbeK.lean`'s 8-certificate GO record) and from task 358 plan v04's
route-R2 probe-before-landing discipline.

### Roadmap Alignment

No ROADMAP.md consultation requested for this task (roadmap_flag not set). The task sits on the
task-358 critical path (KampPrior live sorries :519/:522 blocked upstream on G2/G1 supply).

### Literature Grounding (--lit)

Per-repo sub-index present (`specs/literature-index.json`: `rabinovich_2014`,
`kamp_1968_tense-logic-linear-order`). The fresh-projection channel `nfk_projFresh`
(`CarrierKv.lean:82`) is grounded in Rabinovich's monadic E[Sigma]-atom extraction (Def 4.1). When
designing the content-aware mate condition in Phase 1, the implementer SHOULD consult the
`rabinovich_2014` chunks (via `literature-search.sh` / `--lit`) for Def 4.1's projection semantics
and follow the literature-fidelity policy (no shortcut tactics around steps the source handles
explicitly). Dispatch `/implement 364 --lit`.

## Goals & Non-Goals

**Goals**:
- Restate `kvE_fiberElemConsistent`'s mate check (approach (a), (b), or synthesis, adjudicated
  in-task against machine probes) so the planted mate no longer qualifies as a mate for `e_P`.
- Machine-confirm (successor probe) that the strengthened guard rejects `s*` within
  `σ₂ = τ ⊕ s* ⊕ mate`: `kvE_fiberElemConsistent m2sigma m2sstar = false`, hence
  `kvE_fiberConsistent m2sigma = false` and `kvE_futAdmissible m2sigma = false`.
- No regression: all of task 363's GO certificates (the 8 certificates in
  `ExteriorFiberConsistencyProbeK.lean`) and the surviving M1 probe records
  (`kvE_probeM1_interiorHreal_NOGO`, `kvE_probeM1_interiorGuard_identical`) compile green against
  the strengthened definition. (`kvE_probeM1_sliceId_NOGO` was RETIRED by task 363, preserved in
  git history — its absence is intentional; record this in the summary rather than resurrecting it.)
- Preserve depth-0 inertness (`kvE_fiberElemConsistent_zero`, `kvE_fiberConsistent_zero`) and the
  honest-preservation lemmas (`kvE_fiberElemConsistent_of_realized`,
  `kvE_fiberConsistent_of_realized`) with UNCHANGED signatures, so all consumers
  (`ExteriorNegationK.lean:97,165`, `ExteriorNegationPastK.lean:157,212`,
  `EndIntervalConsumerK.lean:126-230`, `ExteriorPinnedConverseK.lean:403-594`,
  `KampPrior.lean:960-1026`) compile without restatement.
- Adversarially re-plant against the strengthened guard before declaring victory (do not land a
  second 363-style hole).
- Zero-debt terminus; write `.orchestrator-handoff.json` recording which approach landed (it
  shapes the witness term task 358 Phase 2/3 must construct).

**Non-Goals**:
- The general-m/general-depth G1/G2 supply build-out (`kvE_futAdmissible σ₂ = true` in full, the
  u-class per-order-type constructions) — remains task 358 Phase 2/3.
- Touching or re-opening k=0 layers: rung0/rung1, task 360's m=0 supply theorems,
  `kampPrior_case1_arm_k0` — unrefuted, frozen, must stay byte-unchanged.
- Retiring KampPrior's two live sorries (:519/:522) — blocked upstream on G2/G1 supply, out of
  scope here; the sorry count must simply not increase.
- Redesigning `kvE_futAdmissible`/`kvE_pastAdmissible` conjunct structure or the interior rows-5-6
  antecedent shape — the guard is strengthened IN PLACE behind stable names and lemma signatures.

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Approach (a) type-shape mismatch: `e : NormalForm sig j (n+2)` vs mate `s' : NormalForm sig (j+1) (n+1)` — `e.2` and `s'.2` mark different types, and `nfk_projFresh e : NormalForm sig j 1` vs `nfk_projFresh s' : NormalForm sig (j+1) 1` carry a depth offset; a naive "full .2 match" does not typecheck | H | M | Phase 1 designs the comparison explicitly (candidate forms: depth-graded drop of `e`'s content; fresh-projection comparison routed through a depth adapter such as `nfk_take`; or mate-marks-a-matching-inner-witness formulations). Adjudicate by probe, not on paper |
| Honest-preservation re-proof fails: the characteristic mate `nf_characteristic M (j+1) (n+1) (Fin.cons u env)` cannot be shown to satisfy the strengthened content condition | H | M | Phase 2 proves this at PROBE level (general model `M`) before any production edit. If (a) fails, fall back to (b)/synthesis; if neither closes, exit [BLOCKED] with structured escalation — never a sorry |
| Adapted plant defeats the strengthened guard (adversary manufactures matching content) | H | M | Phase 3 is a dedicated adversarial re-plant probe. At most ONE redesign loop back to Phase 1 (churn guard); a second defeat exits [BLOCKED] with the adapted-plant certificate as the escalation payload |
| Approach (b) not encodable as decidable model-independent Bool (genuine "∃ model realizing s'" quantifies over models) | M | H | (b) must be a syntactic proxy (e.g., mate nontriviality plus recursive constraints); Phase 1 must adversarially test any proxy immediately (a nontriviality-only proxy is likely plantable). This is why (a) is primary |
| Fake-exclusion certificate proofs (certs 1, 2, 6, 7 in `ExteriorFiberConsistencyProbeK.lean`) break: they unfold the definition body and case-analyze the current mate-check structure | M | H | Statements remain true (a stronger check rejects at least as much; the same atom-row contradiction still closes them). Phase 4 repairs proof scripts; reuse `kvE_nf_mem_univ_toList` symbolic-membership routing and the `set_option maxRecDepth 8000` precedent |
| Elaboration blow-up at concrete signature (Finset.univ over NormalForm instances) | M | M | Follow existing precedent: symbolic helpers, `maxRecDepth 8000`, `decide`-avoidance at concrete signatures except where already proven cheap; scoped `lake build` per module |
| `ExteriorPinnedConverseK.lean` breakage (it `unfold`s `kvE_futAdmissible` at several sites and consumes `kvE_fiberElemConsistent_zero` at k=0) | M | L | The guard appears there as an opaque Bool conjunct or via `_zero`; keeping `_zero` a `rfl`-provable inertness fact and lemma signatures stable makes these robust. Phase 4 gate includes building this module |
| Frozen-layer drift (rung0/rung1, task 360 m=0 supply, `kampPrior_case1_arm_k0`) | H | L | `_zero` inertness lemmas keep the m=0 view of the guard constantly `true`; Phase 5 runs an explicit `git diff` audit that frozen files are byte-unchanged |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2, 3 | 1 |
| 3 | 4 | 2, 3 |
| 4 | 5 | 4 |
| 5 | 6 | 5 |

Phases within the same wave can execute in parallel (Phases 2 and 3 both consume Phase 1's
adjudicated candidate and touch disjoint probe content).

---

### Phase 1: Baseline freeze + candidate design adjudication (probe-side) [COMPLETED]

**Goal**: Choose and machine-validate the strengthened mate-check CANDIDATE in a new additive
probe leaf, without touching any production file. The candidate must reject both the m=2-cast
plant and the m=1 fake.

**Tasks**:
- [x] Baseline: scoped `lake build` of the touched module chain
      (`Bimodal.Metalogic.WeakCanonical.Kamp.NfMultiAnchorBridge.ExteriorPinnedProbe358K` and
      `...ExteriorFiberConsistencyProbeK`) confirming green start; `lean_verify` spot-check on
      `kvE_probe358_eP_atomMate_present` and `kvE_probe363_fake_elem_inconsistent` (floor axioms
      `[propext, Classical.choice, Quot.sound]`, no sorryAx). *(completed — both green)*
- [x] Consult `rabinovich_2014` literature chunks for Def 4.1 (E[Sigma]-atom extraction) semantics
      of the fresh-projection channel before fixing the comparison form. *(completed — Def 4.1
      (chunk_0011, PDF p.5): E[Σ]-atoms are interpreted as `{a ∈ M | M, a ⊨ A}`, i.e. point
      content IS realization content; this grounds the joint-realization mate form)*
- [x] Create NEW probe leaf
      `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge/ExteriorFiberConsistencyProbe364K.lean`
      (template-copy the m1 cast from `ExteriorFiberConsistencyProbeK.lean:82-119` and the m2 cast
      — `m2mate`, `m2sigma`, `m2eP`, `m2sstar` — from `ExteriorPinnedProbe358K.lean:72-120`, per
      the established replication precedent for `private` originals). *(completed)*
- [x] Define candidate `kvE_fiberElemConsistentV2` (and σ-level `kvE_fiberConsistentV2`)
      implementing approach (a): the mate check additionally constrains the mate `s'`'s depth-≥1
      content (fresh projection `nfk_projFresh` through an explicit depth adapter, or a
      depth-graded drop of `e`'s full content) — resolving the type-shape offset documented in
      Risks. Keep the depth-0 arm literally `| 0, _, _, _ => true` so `_zero` inertness stays
      `rfl`. Document approach (b) as the in-file fallback candidate with its syntactic-proxy
      caveat. *(deviation: altered — adjudication landed the (b)-JOINT SYNTHESIS, not (a): every
      (a)-style syntactic content comparison is short-cycle plantable (swap-row 2-cycle closed by
      s* itself since drop∘swap of e_P's row = s*'s row and s*.2 e_P = true; diagonal-row 1-cycle
      self-supporting), and (b)-standalone is defeated by the honest-in-M2M mate
      char M2M 1 5 [20,25,15,2,21]. The landed mate check adds the conjunct
      `∃ M env u, σ realized at env ∧ s' realized at Fin.cons u env` (joint co-realization) —
      full adjudication record in the leaf's module docstring. Depth-0 arm kept literally
      `| 0, _, _, _ => true`; OrderedMonadicStructure.carrier : Type is universe-monomorphic so
      the internal existential is well-formed and the def stays model-independent/noncomputable
      exactly as before)*
- [x] **Gate 1a (plant rejection)**: sorry-free certificate
      `kvE_probe364_plant_rejected : kvE_fiberElemConsistentV2 m2sigma m2sstar = false` — under
      the candidate, the planted mate no longer discharges the mate obligation for `e_P`, so `s*`
      fails the guard within σ₂. *(completed — floor axioms)*
- [x] **Gate 1b (m1 fake still rejected)**: sorry-free certificate
      `kvE_probe364_m1fake_rejected : kvE_fiberElemConsistentV2 m1sigma m1sstar = false`.
      *(completed — floor axioms; proved via the Phase-3 universal joint-unrealizability engine
      `kvE_probe364_sstar_honest_unrealizable`, front-loaded into Phase 1 because it is the
      candidate's core validation mechanism)*
- [x] Scoped `lake build` of the new leaf; `lean_verify` both gate certificates. *(completed —
      build green, all certs `[propext, Classical.choice, Quot.sound]`, no sorryAx)*

**Timing**: 2 hours

**Depends on**: none

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge/ExteriorFiberConsistencyProbe364K.lean` — NEW additive probe leaf (candidate + casts + gates 1a/1b)

**Verification**:
- Both gate certificates compile sorry-free with floor axioms; no production file touched
  (`git status` shows only the new leaf).

---

### Phase 2: Honest-preservation proof for the candidate (probe-side crux) [COMPLETED]

**Goal**: Prove, at probe level and in full generality (any model, any env), that honestly
realized fibers satisfy the strengthened guard. This is the load-bearing mathematics: the
characteristic mate `nf_characteristic M (j+1) (n+1) (Fin.cons u env)` must be shown to carry the
strengthened content, not just the dropped atom row.

**Tasks**:
- [x] Prove `kvE_fiberElemConsistentV2_of_realized` (V2 analog of
      `ExteriorFiberConsistencyK.lean:117-191`): same statement shape, extended to discharge the
      new content conjunct for the characteristic mate. Expect new supporting lemmas relating
      `nfk_projFresh` / the chosen content comparison to realization at
      `Fin.cons u (Fin.cons xs env)` vs `Fin.cons u env` (the `cons_cons_skipOne` bookkeeping
      pattern generalizes). *(completed — no NEW bookkeeping lemma needed beyond the replicated
      `cons_cons_skipOne364`: the co-realization conjunct is discharged by the in-scope witness
      `⟨M, env, u, hσ, nf_characteristic_satisfies⟩`)*
- [x] Prove `kvE_fiberConsistentV2_of_realized` (σ-level corollary) and the inertness pair
      `kvE_fiberElemConsistentV2_zero` (`rfl`) / `kvE_fiberConsistentV2_zero`. *(completed)*
- [x] **Gate 2a (honest cast preservation)**: V2 analogs of GO certificates 3-4 —
      `kvE_fiberConsistentV2 m1tau = true` and, uniformly in `r`,
      `kvE_fiberElemConsistentV2 m1tau (nf_characteristic M1M 1 5 (Fin.cons r m1env4)) = true` —
      derived from the `_of_realized` lemma, not by concrete computation. *(completed — as
      `kvE_probe364_honest_tau_consistent` / `kvE_probe364_honest_fiber_consistent` on the leaf's
      cast objects `m2tau`/`m2env4` (identical values to `m1tau`/`m1env4`); floor axioms)*
- [x] **Adjudication checkpoint**: if the content conjunct is NOT dischargeable for the
      characteristic mate under approach (a), switch the candidate to approach (b)/synthesis and
      loop Phase 1's gates once. If neither candidate closes both Phase-1 gates AND this phase's
      preservation proof, STOP: mark task `[BLOCKED]`, write structured escalation (what was
      tried, the exact failing goal states, the countermodel or unprovable obligation), no sorry,
      no vacuous def, delete or clearly quarantine the probe leaf as a NO-GO record.
      *(completed — checkpoint PASSED on the (b)-joint candidate: co-realization dischargeable
      trivially for the characteristic mate; no redesign loop consumed)*

**Timing**: 2 hours

**Depends on**: 1

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge/ExteriorFiberConsistencyProbe364K.lean` — preservation lemmas + gate 2a certificates

**Verification**:
- `kvE_fiberElemConsistentV2_of_realized` compiles sorry-free at general model/signature; gate 2a
  certificates green; scoped `lake build` of the leaf.

---

### Phase 3: Adversarial re-plant probe [COMPLETED]

**Goal**: Attempt to defeat the CANDIDATE the same way task 358's probe defeated task 363 —
before promotion, not after. The strengthening is only credible if the next-level plant provably
fails.

**Tasks**:
- [x] Construct the strongest adapted plant against V2: a mate whose atom row equals
      `mergeNF e_P.atom_assgn ⟨1,_⟩` AND whose depth-≥1 content is manufactured to satisfy the
      new conjunct (e.g., copying the required fresh-projection/content payload syntactically).
      *(completed — strongest form is the honest-in-M2M realizable fiber
      `m2mate3 := nf_characteristic M2M 1 5 [20,25,15,2,21]`: genuinely realizable standalone,
      exact required dropped row, fully honest depth-≥1 content; it strictly dominates every
      syntactically manufactured payload and is precisely the plant that DEFEATS both rejected
      candidate families)*
- [x] Machine-adjudicate one of the two outcomes:
      - **Gate 3a (candidate survives)**: sorry-free certificate(s) showing the adapted plant is
        self-defeating — it fails an existing check the original plant passed (on-fiber
        `nfk_dropFresh`, zone/slice visibility so `σ₃` is no longer slice-equal to `σ`, or the
        recursive elem-consistency arm now fires on its manufactured content), so
        `kvE_fiberElemConsistentV2 (σ₃) s* = false` or the σ₃ construction is impossible; OR
      - **Gate 3b (candidate defeated)**: a `kvE_probe364_replant_present`-style refutation
        certificate. Then loop back to Phase 1 design ONCE (churn guard). A second defeat exits
        `[BLOCKED]` with the refutation certificate as the escalation payload.
      *(completed — Gate 3a fired, UNIVERSALLY: `kvE_probe364_sstar_honest_unrealizable` (any
      slice marking s* plus one honest fiber is realized in NO model) +
      `kvE_probe364_replant_selfdefeating` (guard-level: `kvE_fiberElemConsistentV2 X m2sstar =
      false` for EVERY such X — quantifying over all manufactured mate contents at once) +
      concrete instance `kvE_probe364_adapted_plant_rejected` on `σ₃ = τ ⊕ s* ⊕ mate₃`. The
      self-defeat channel is the co-realization conjunct itself: s* forces an interior P-point
      through e_P while every honest fiber's M2M-decided quant layer forbids one. No redesign
      loop consumed. Certificates landed in the phase-1 commit (front-loaded engine); all floor
      axioms)*
- [x] Cross-check the written u-class enumeration argument from the phase-2 handoff (u=20
      P-collision class vs honest order-classes under the 18↔21 remap) against the candidate: the
      docstring of the probe leaf must record WHY each class can no longer be serviced by a plant.
      *(completed — leaf module docstring section "u-class enumeration cross-check": under joint
      co-realization the per-class bookkeeping never starts, because the ambient σ₂ admits no
      joint realization at all — no per-class mate supply can service ANY class inside an
      unrealizable ambient)*

**Timing**: 1.5 hours

**Depends on**: 1

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge/ExteriorFiberConsistencyProbe364K.lean` — adversarial section + gate 3a certificate(s) and docstring record

**Verification**:
- Gate 3a certificate compiles sorry-free (or the documented single redesign loop has completed
  with gates 1a/1b/2a/3a all green on the revised candidate).

---

### Phase 4: In-place production restatement + consumer repair [COMPLETED]

**Goal**: Promote the adjudicated candidate into the production home by restating
`kvE_fiberElemConsistent` IN PLACE (stable name, stable signature, stable lemma statements), and
repair everything downstream that inspects the definition body.

**Tasks**:
- [x] Restate `kvE_fiberElemConsistent` in `ExteriorFiberConsistencyK.lean:48-57` per the
      adjudicated candidate; keep the `| 0, _, _, _ => true` arm verbatim; update the module and
      definition docstrings (consumption map, why-this-separates section) to record the task-364
      strengthening and the plant it rejects. *(completed — co-realization conjunct added inside
      the mate `any`; depth-0 arm verbatim; module + def docstrings updated)*
- [x] Re-prove in the production home: `kvE_fiberElemConsistent_zero` (must remain `rfl`),
      `kvE_fiberConsistent_zero`, `kvE_fiberElemConsistent_of_realized`,
      `kvE_fiberConsistent_of_realized` — transcribing the Phase-2 probe proofs; signatures
      byte-identical to current. *(completed — `_zero` pair byte-unchanged and still `rfl`-based;
      `_of_realized` gained only the in-scope co-realization witness; all signatures
      byte-identical)*
- [x] Repair the four fake-exclusion certificate proofs in `ExteriorFiberConsistencyProbeK.lean`
      (`kvE_probe363_fake_elem_inconsistent`, `kvE_probe363_fake_slice_inconsistent`,
      `kvE_probe363_qnfG1_antecedent_fails`, `kvE_probe363_sigma_inadmissible`) — statements
      unchanged, proof scripts adapted to the new conjunct structure (the original atom-row
      contradiction still closes them; the added conjunct only widens the falsity). *(completed —
      only cert 1 needed repair (one extra `Bool.and_eq_true` destructure discarding the new
      conjunct); certs 2, 6, 7 consume cert 1 / the unchanged `kvE_futAdmissible` skeleton and
      compiled untouched, as did honest certs 3, 4, 5a, 5b, 8)*
- [x] Rewire `ExteriorFiberConsistencyProbe364K.lean` to certify against the PRODUCTION
      definition (drop or alias the V2 duplicate so exactly one live definition exists; retain the
      leaf as the permanent regression record, mirroring the 363 probe-module precedent).
      *(completed — V2 defs and V2 lemma duplicates dropped; all certs restated against
      `kvE_fiberElemConsistent`/`kvE_fiberConsistent`/`kvE_futAdmissible`; Phase-5 successor
      certs added in the same rewire)*
- [x] Build the full consumer chain scoped:
      `ExteriorNegationK`, `ExteriorNegationPastK`, `ExteriorPinnedConverseK`,
      `EndIntervalConsumerK`, `ExteriorPinnedProbeM1K`, `KampPrior`. Consumers use the guard
      opaquely or via the stable lemmas, so NO statement changes are expected there; any needed
      edit beyond proof-script repair in the two probe modules is a scope alarm — stop and
      reassess before widening. *(completed — whole chain green including `ExteriorPinnedProbe358K`;
      zero consumer edits; `git diff --stat` over Theories/ shows exactly the three planned files)*

**Timing**: 2 hours

**Depends on**: 2, 3

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge/ExteriorFiberConsistencyK.lean` — the in-place restatement + re-proved lemmas
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge/ExteriorFiberConsistencyProbeK.lean` — proof-script repair only (statements frozen)
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge/ExteriorFiberConsistencyProbe364K.lean` — rewire to production definition

**Verification**:
- Scoped `lake build` green across the whole consumer chain; `git diff --stat` confirms no file
  outside the three listed plus (Phase 5's) probe successor is touched.

---

### Phase 5: Full re-probe gate — the definition of done [COMPLETED]

**Goal**: Machine-adjudicate the task's four-part definition of done against the landed
production interface: plant rejected, no regression on all 363 certificates, frozen layers
untouched, zero debt.

**Tasks**:
- [x] **Successor 358 probe**: in `ExteriorPinnedProbe358K.lean` (or the 364 leaf), KEEP
      `kvE_probe358_eP_atomMate_present` compiling as the permanent atom-row regression record
      (it remains true — the atom row is present; it merely no longer suffices), update its
      docstring/verdict block to record the task-364 supersession, and add the guard-level
      successor certificates against the production definition:
      `kvE_probe364_sigma2_sstar_inconsistent : kvE_fiberElemConsistent m2sigma m2sstar = false`,
      `kvE_probe364_sigma2_slice_inconsistent : kvE_fiberConsistent m2sigma = false`, and
      `kvE_probe364_sigma2_inadmissible : kvE_futAdmissible m2sigma = false` — the plant is now
      correctly rejected and the σ₂ doppelganger no longer defeats G2's exclusion mechanism.
      *(completed — 358K module + theorem docstrings record the supersession; the atom-row cert
      compiles unchanged and remains at floor axioms; successor certs live in the 364 leaf
      (private-cast replication precedent) and are kernel-checked at floor axioms)*
- [x] **363 regression gate**: all 8 GO certificates in `ExteriorFiberConsistencyProbeK.lean`
      compile green (fake excluded: 1, 2, 6, 7; honest preserved: 3, 4, 5a/5b, 8 — in particular
      `kvE_probe363_tau_admissible : kvE_futAdmissible m1tau = true` re-fires through the
      re-proved realizer path). *(completed — all 9 printed axiom sets (certs 1-8 incl. 5a/5b and
      tau_admissible) are exactly `[propext, Classical.choice, Quot.sound]`, kernel-checked)*
- [x] **M1 residual gate**: `kvE_probeM1_interiorHreal_NOGO` and
      `kvE_probeM1_interiorGuard_identical` compile green; record in the summary that
      `kvE_probeM1_sliceId_NOGO` remains retired-to-git-history by task 363 (its absence is the
      documented expected state, not a regression). *(completed — both verified at floor axioms;
      sliceId_NOGO absence confirmed expected)*
- [x] **Frozen-layer audit**: `git diff --name-only` over the change set confirms rung0/rung1
      modules, task 360's m=0 supply theorems, and `kampPrior_case1_arm_k0` are byte-unchanged;
      `kvE_fiberElemConsistent_zero`/`kvE_fiberConsistent_zero` still hold (m=0 view constantly
      true). *(completed — change set over Theories/ is exactly ExteriorFiberConsistencyK,
      ExteriorFiberConsistencyProbeK, ExteriorFiberConsistencyProbe364K (+ the 358K docstring);
      KampPrior byte-unchanged; `_zero` lemmas kernel-checked green)*
- [x] **Zero-debt audit**: full `lake build` green; `lean_verify` on every new/changed certificate
      (floor axioms `[propext, Classical.choice, Quot.sound]`, clean source scan, no `sorryAx`);
      repo-wide sorry count unchanged (exactly KampPrior :519/:522); no vacuous defs
      (`def _ := True`-class patterns) introduced. *(completed — full build 1759 jobs green;
      kernel `#print axioms` sweep over all 14 new/changed certs + 10 regression certs: floor
      axioms only; KampPrior sorries exactly :519/:522; vacuous-pattern scan: 0 introduced (the
      single repo hit is pre-existing in Examples/TemporalStructures.lean:269, outside scope))*

**Timing**: 1.5 hours

**Depends on**: 4

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge/ExteriorPinnedProbe358K.lean` — docstring supersession record + successor certificates (or successor certs in the 364 leaf)

**Verification**:
- Every listed certificate green and sorry-free; full `lake build` passes; frozen-file diff empty;
  sorry inventory unchanged.

---

### Phase 6: Wrap-up — summary, handoff, re-key notes for task 358 [NOT STARTED]

**Goal**: Land the documentation and orchestrator handoff so task 358 can resume Phase 2/3 against
the strengthened interface.

**Tasks**:
- [ ] Write implementation summary
      `specs/364_strengthen_fiberelemconsistent_mate_check_against_planted_unrealizable_mates/summaries/01_strengthen-fiber-mate-check-summary.md`
      recording: which approach landed ((a)/(b)/synthesis) and the exact final mate-check form;
      the full certificate inventory (gates 1a-5); the adversarial re-plant outcome; the
      retired/superseded record decisions.
- [ ] Write `specs/364_strengthen_fiberelemconsistent_mate_check_against_planted_unrealizable_mates/.orchestrator-handoff.json`
      with: final predicate signature and chosen approach (this shapes the witness term task 358's
      G2 supply proof must construct — fresh-projection content vs realizability obligation),
      certificate list with `lean_verify` axiom results, files touched, and the explicit next
      action `resume /implement 358 (Phase 2, plan v04) re-keyed against the strengthened
      interface`.
- [ ] Update plan phase statuses and `.return-meta.json`; commit per green-milestone convention
      (`task 364 phase {P}: {name}` commits should have landed at each phase; final
      `task 364: complete implementation`).

**Timing**: 0.5 hours

**Depends on**: 5

**Files to modify**:
- `specs/364_.../summaries/01_strengthen-fiber-mate-check-summary.md` — NEW
- `specs/364_.../.orchestrator-handoff.json` — NEW
- this plan file — status markers

**Verification**:
- Summary and handoff files exist and are non-empty; handoff JSON parses; plan statuses updated.

## Testing & Validation

- [ ] Gate 1a: `kvE_probe364_plant_rejected` — candidate rejects `s*` within σ₂ (plant no longer
      a qualifying mate for `e_P`)
- [ ] Gate 1b: `kvE_probe364_m1fake_rejected` — original m=1 fake still rejected
- [ ] Gate 2a: V2 `_of_realized` in full generality + honest cast certificates (τ and all pinned
      fibers uniform in r)
- [ ] Gate 3a: adapted (content-matching) plant machine-shown self-defeating; single redesign
      loop maximum
- [ ] Phase 4: scoped `lake build` green across `ExteriorFiberConsistencyK`,
      `ExteriorFiberConsistencyProbeK`, `ExteriorNegationK`, `ExteriorNegationPastK`,
      `ExteriorPinnedConverseK`, `EndIntervalConsumerK`, `ExteriorPinnedProbeM1K`, `KampPrior`
- [ ] Phase 5: successor certificates (`kvE_probe364_sigma2_sstar_inconsistent`,
      `_slice_inconsistent`, `_sigma2_inadmissible`); all 8 363 GO certs; both surviving M1
      records; frozen-layer diff empty; full `lake build`; `lean_verify` floor axioms on all new
      certs; sorry count = 2 (KampPrior :519/:522 only)
- [ ] Blocked-exit contract honored if any gate cannot close: `[BLOCKED]` + structured escalation,
      never sorry/vacuous-def/forced proof

## Artifacts & Outputs

- `plans/01_strengthen-fiber-mate-check.md` (this file)
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge/ExteriorFiberConsistencyProbe364K.lean` (new probe leaf: candidate adjudication, preservation, adversarial re-plant, regression record)
- Restated `ExteriorFiberConsistencyK.lean` (production, in place)
- Repaired `ExteriorFiberConsistencyProbeK.lean` proof scripts (statements frozen)
- Updated `ExteriorPinnedProbe358K.lean` (supersession record + successor certificates)
- `summaries/01_strengthen-fiber-mate-check-summary.md`
- `.orchestrator-handoff.json` (task-358 re-key handoff)

## Rollback/Contingency

- Phases 1-3 are purely additive (one new probe leaf, no production file touched): rollback =
  delete the leaf. A NO-GO adjudication at Phase 2/3 converts the leaf into a quarantined NO-GO
  record and the task exits `[BLOCKED]` with structured escalation.
- Phase 4 is the only production-touching phase. Before editing, snapshot via
  `bash .claude/scripts/git-snapshot.sh`. If consumer repair exceeds proof-script scope (any
  STATEMENT outside the two probe modules needs changing), stop, restore the snapshot, and
  escalate — that indicates the candidate is not signature-stable and needs redesign, not forcing.
- Per-phase green commits (`task 364 phase {P}: ...`) ensure any failure resumes from the last
  green milestone; incomplete phase work is never committed.
- If Phase 5 uncovers a regression on any 363 certificate that cannot be repaired at proof-script
  level, revert the Phase-4 commit(s) (production returns to the task-363 interface, which is
  machine-refuted but self-consistent) and exit `[BLOCKED]` — the frozen reference layer is never
  left broken.
