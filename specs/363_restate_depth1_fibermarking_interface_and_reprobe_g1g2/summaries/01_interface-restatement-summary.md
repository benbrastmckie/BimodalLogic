# Implementation Summary: Task #363 — Restate depth>=1 fiber-marking interface and re-probe G1/G2

- **Task**: 363 - restate_depth1_fibermarking_interface_and_reprobe_g1g2
- **Status**: IMPLEMENTED (GO — all four DoD certificates sorry-free, full `lake build` green)
- **Session**: sess_1784039419_e5b7e9
- **Plan**: plans/01_interface-restatement-plan.md (v1; Phases 1-5 completed, Phase 6 not triggered)
- **Commits**: `0192f2863` (P1 GO), `c5189a7e4` (P2), `a1a0d7917` (P3), `83d216357` (P4), P5 (this commit)

## Outcome

The D7 doppelgänger countermodel (three sorry-free NO-GO probes in
`ExteriorPinnedProbeM1K.lean`) **no longer applies to either leg**. The depth-graded
fiber-consistency guard (research approach (b)) landed as an exterior admissibility conjunct
and an interior rows-5-6 antecedent, machine-re-probed against the restated production
definitions. Zero-debt terminus: no sorry, no vacuous def, no new axioms in any touched
declaration; the frozen boundary (igFoldBit, carrier, k<=1 rungs, m=0 supply) is
byte-unmodified.

## FINAL PREDICATE SIGNATURE (the task-358 contract)

Production home: `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge/ExteriorFiberConsistencyK.lean`

> **Naming note**: the plan's working name `kvE_futFiberConsistent` (+ past mirror) was
> finalized as ONE direction-agnostic predicate pair — the consistency notion never reads
> anchor order, so the same predicate serves the future AND past mirrors.

```lean
-- Per-fiber depth-graded guard (decidable, model-independent, depth-recursive over `.2`)
noncomputable def kvE_fiberElemConsistent {sig : MonadicSignature} :
    {k n : Nat} → NormalForm sig (k + 1) n → NormalForm sig k (n + 1) → Bool
  | 0, _, _, _ => true                                   -- m = 0 inertness
  | (j + 1), n, σ, s =>
    -- (i) mate check: every s-marked inner form e has a σ-marked atom-layer mate
    --     after dropping s's fresh slot (slot 1 of the inner arity)
    ((Finset.univ.toList (α := NormalForm sig j (n + 2))).all fun e =>
      !(s.2 e) ||
        ((Finset.univ.toList (α := NormalForm sig (j + 1) (n + 1))).any fun s' =>
          σ.2 s' && decide (mergeNF (e.atom_assgn) ⟨1, by omega⟩ = s'.atom_assgn))) &&
    -- (ii) depth recursion: every s-marked inner form is consistent one level down
    ((Finset.univ.toList (α := NormalForm sig j (n + 2))).all fun e =>
      !(s.2 e) || kvE_fiberElemConsistent s e)

-- σ-level guard: every σ-marked fiber is elem-consistent
noncomputable def kvE_fiberConsistent {sig : MonadicSignature} {k n : Nat}
    (σ : NormalForm sig (k + 1) n) : Bool :=
  (Finset.univ.toList (α := NormalForm sig k (n + 1))).all fun s =>
    !(σ.2 s) || kvE_fiberElemConsistent σ s
```

Key supporting lemmas (same module):
- `kvE_fiberElemConsistent_zero` / `kvE_fiberConsistent_zero` — depth-0 inertness (`rfl`-level).
- `kvE_fiberElemConsistent_of_realized` / `kvE_fiberConsistent_of_realized` — honest
  preservation: ANY σ realized at ANY env in ANY model passes (the realizer-side discharge and
  the hexcl-reconstruction key).
- `kvE_nf_mem_univ_toList` — symbolic-signature membership helper (NEVER elaborate
  `Finset.mem_univ` at a concrete probe signature: unbounded instance evaluation).

### Exterior conjunct shape (G2 — rows 8-11 admissibility)

The guard lives **inside conjunct 2's body** of `kvE_futAdmissible`
(`ExteriorNegationK.lean`) and `kvE_pastAdmissible` (`ExteriorNegationPastK.lean`) — NOT as a
fifth top-level `&&`:

```lean
((Finset.univ.toList (α := NormalForm sig k 5)).all fun s =>
  (decide (nfk_dropFresh s = σ.1) && kvE_fiberElemConsistent σ s) || !(σ.2 s)) &&
```

Rationale: the frozen m=0 supply proofs (`kvE_futSliceId_of_end_zero`,
`kvE_hexclSliceFut_supply_zero`, past mirrors) destructure the 4-conjunct top-level chain via
`hh.1.1.1` / `hadm'.2` and 3x `Bool.and_eq_true`; in-body placement keeps every access path
valid and those proofs byte-identical. **Reading conjunct 2** now destructures as
`rw [Bool.or_eq_true, Bool.and_eq_true, decide_eq_true_eq]` (see
`kvE_futAdmissible_fiber_dichotomy`, `ExteriorConverterK.lean`).

`kvE_futRealizer_admissible` / `kvE_pastRealizer_admissible` re-proved: honest realizers
remain admissible (conjunct-2 branch = fold witness + `kvE_fiberElemConsistent_of_realized`).

### Interior antecedent shape (G1 — rows 5-6)

In `EndIntervalCorrectPrior` (m+2 arm, `EndIntervalConsumerK.lean`) and
`kampPrior_site_rungK_gate_match` (`KampPrior.lean`), the restatement is the antecedent PAIR:

```lean
-- NEW population binder (before _hreal):
(_hfiberCons : ∀ σ : NormalForm sig (m + 1) 4, qnf.2 σ = true →
  kvE_fiberConsistent σ = true)
-- per-σ antecedent threaded into _hreal (after `qnf.2 σ = true →`):
    kvE_fiberConsistent σ = true →
-- per-σ antecedent threaded into _hexcl (after `qnf.2 σ = false →`):
    kvE_fiberConsistent σ = true →
```

The consumers (`endInterval_step_correct`, the gate-match proof) reconstruct the
UNRESTRICTED obligations for the unchanged downstream `bracketEndChar_kvExt_correct_prior`:
`hreal` by modus ponens with `hfiberCons`; `hexcl` by case split — an inconsistent σ has no
realization at all (`kvE_fiberConsistent_of_realized`). **Task 358 Phase 8 therefore
discharges the WEAKER rows 5-6** (population restricted to fiber-consistent slices) **plus
`hfiberCons`** (honest/realized ambients satisfy it via `kvE_fiberConsistent_of_realized`;
the fake `qnfG1` fails it and is outside the population).

## The four DoD GO certificates (all sorry-free; axioms = propext, Classical.choice, Quot.sound)

| # | Certificate | Location | Statement |
|---|-------------|----------|-----------|
| 1 | `kvE_probe363_sigma_inadmissible` | ExteriorFiberConsistencyProbeK | `kvE_futAdmissible m1sigma = false` — exterior fake excluded |
| 2 | `kvE_probe363_tau_admissible` (+ `kvE_probe363_honest_fiber_consistent`, all `r`) | ExteriorFiberConsistencyProbeK | honest population preserved (`kvE_futRealizer_admissible` fires on the cast) |
| 3 | `kvE_probe363_qnfG1_antecedent_fails` (+ `kvE_probe363_fake_slice_inconsistent`) | ExteriorFiberConsistencyProbeK | restated interior antecedent fails at `(qnfG1, m1sigma)` — interior fake excluded |
| 4 | m=0 layer | ExteriorPinnedConverseK/PastK | `kvE_hsliceFut_supply_zero`, `kvE_hexclSliceFut_supply_zero`, `kvE_futSliceId_of_end_zero`, `kvE_futSliceUnique_zero` + past mirrors build with byte-unchanged statements AND proofs (git-diff verified) |

Plus Phase-1 GO gate certificates (fake elem/slice rejection, honest acceptance, 358
feasibility: `kvE_probe363_interior_population_clean`/`_nonempty`).

## Old NO-GO probes — disposition

- `kvE_probeM1_sliceId_NOGO` + `m1_sigma_adm` (+ helpers): **RETIRED** — `m1_sigma_adm` is
  now unprovable (that is the fix). Preserved in git history (pre-363 revision = the
  permanent regression test). Replaced by `kvE_probeM1_sliceId_superseded`: the surviving
  semantic core (atom-fiber guard, ambient, full destructor fact set, no-marked-mate) minus
  the dissolved admissibility conjunct.
- `kvE_probeM1_interiorHreal_NOGO`: **RETAINED** (its five facts are model facts, still
  true) with docstring re-keyed: certificate against the SUPERSEDED pre-363 rows-5-6 shape;
  `qnfG1` is outside the restated obligation population.
- `kvE_probeM1_interiorGuard_identical`: **RETAINED — the EXPECTED residual**:
  `igFoldBit qnfG1 = igFoldBit m1qnf` remains true (frozen gate untouched); the separation
  happens at the new antecedent one layer out. Explicitly NOT a regression.

## Files touched

- NEW `NfMultiAnchorBridge/ExteriorFiberConsistencyK.lean` (production predicate home)
- NEW `NfMultiAnchorBridge/ExteriorFiberConsistencyProbeK.lean` (Phase-1 GO gate + Phase-5 re-probe certificates)
- `NfMultiAnchorBridge/ExteriorNegationK.lean` (conjunct + realizer re-proof)
- `NfMultiAnchorBridge/ExteriorNegationPastK.lean` (past mirror)
- `NfMultiAnchorBridge/ExteriorConverterK.lean` / `ExteriorConverterPastK.lean` (fiber-dichotomy conjunct-2 read repair)
- `NfMultiAnchorBridge/ExteriorPinnedConverseK.lean` (`kvE_futAdmissible_of_subMarking` + `hcons` hypothesis; frozen kernels untouched)
- `NfMultiAnchorBridge/EndIntervalConsumerK.lean` (rows 5-6 restatement + reconstruction + ledger)
- `KampPrior.lean` (`kampPrior_site_rungK_gate_match` mirror; frozen rungs untouched)
- `NfMultiAnchorBridge/ExteriorPinnedProbeM1K.lean` (verdict-layer rewrite)

## Frozen-boundary audit (final)

`git diff 420060b97..HEAD` shows ZERO changes to: `InteriorGateGeneralK.lean` (whole file —
`bracketEndChar_kv_succ_eq` rfl bridge intact), `CarrierKv.lean`, `ExteriorFiberK.lean`,
`ExteriorPinnedConversePastK.lean`, KampPrior's k<=1 rungs (`kampPrior_site_rung0_match`,
`kampPrior_site_rung1_match`, `kampPrior_case1_arm_k0`), and every declaration in the plan's
frozen table. `ExteriorPinnedConverseK.lean` changed ONLY at `kvE_futAdmissible_of_subMarking`
(+ its single k=0 consumer inside the already-historical `kvE_futPinned_of_end_zero_refuted`).

## Verification (final)

- Full `lake build`: green (1752 jobs), plus explicit builds of all four leaf probe modules.
- Sorry census: 0 in every touched file (the repo's pre-existing sorries — KampPrior's two
  fenced `:519/:522` task-309-phase-21 k+2 residuals, `Metalogic/Bundle/Succ*`, Boneyard —
  are untouched baseline debt, count unchanged).
- Vacuous defs: 0 introduced (repo-wide single pre-existing hit is task-184-era, untouched).
- New axioms: 0 (`grep "^axiom "` hits are docstring prose only).
- `lean_verify` on the predicate lemmas, both realizer lemmas, `endInterval_step_correct`,
  `kampPrior_site_rungK_gate_match`, the m=0 supplies, and all probe certificates:
  axioms = `[propext, Classical.choice, Quot.sound]`, no warnings.

## Plan Deviations

- **Phase 1 (altered)**: the "past mirror" of the predicate is the SAME direction-agnostic
  predicate (`kvE_fiberElemConsistent`/`kvE_fiberConsistent`), not a separate `kvE_past*`
  clone — the consistency notion never reads anchor order. The plan's relational
  `(qnf, σ)`-pair option collapsed to the σ-internal form (required for the hexcl
  reconstruction, which has only σ's realization in scope).
- **Phase 2 (altered)**: the conjunct is placed INSIDE `kvE_futAdmissible` conjunct 2's body
  rather than appended as a fifth top-level conjunct — the only placement that keeps the
  FROZEN m=0 supply proofs (which destructure the 4-conjunct chain) byte-identical.
- **Phase 3 (altered)**: `kvE_futAdmissible_of_subMarking` gained a `hcons` hypothesis
  (consistency is not monotone under mark-erasure); its single k=0 consumer discharges it
  by `kvE_fiberElemConsistent_zero`.
- **Phase 4 (altered)**: the "antecedent on rows 5-6" is realized as the antecedent PAIR
  (qnf-level `_hfiberCons` binder + per-σ antecedent) — the binder is what lets the consumer
  reconstruct the frozen downstream interface without touching it.
- **Phase 5 (altered)**: the re-probe certificates live in `ExteriorFiberConsistencyProbeK`
  (which owns the private m=1 cast) rather than in `ExteriorPinnedProbeM1K`; the M1K leaf
  keeps the surviving semantic record (`kvE_probeM1_sliceId_superseded`, retained interior
  theorems) with superseded/residual docstrings.

## Task-358 dovetail (resume contract)

Task 358 resumes at Phase 7 (G2): the slice-identification kernels re-key to the
strengthened `kvE_futAdmissible` — every admissible σ now has fiber-consistent markings, so
`s*`-class fakes are outside the admissible population. Phase 8 (G1): supply the restated
rows 5-6 — `hfiberCons` + the consistency-restricted `hreal`/`hexcl` — over the
fiber-consistent population only; `kvE_fiberConsistent_of_realized` discharges `hfiberCons`
wherever the ambient qnf is realized/characteristic. The exact binder text is in
`EndIntervalConsumerK.lean` (m+2 arm) and `KampPrior.lean` (`kampPrior_site_rungK_gate_match`).
