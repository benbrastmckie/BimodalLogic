# Task 348 Phase 4 Progress — Future-side completeness

- **Status**: done (all objectives green)
- **Session**: sess_1783796165_b5b482_348
- **Date**: 2026-07-11
- **File**: `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/ExteriorNegation.lean` (extended
  1323 → 1735 lines, +412; no new imports)

## Objectives

1. **`kvE2_extNegFut_complete`** — done, sorry-free. Statement: under `(hxw, hwt)` + the
   gate-level pins `henv` (anchor base `[w,x,t]` = `qnf.1`) and `hbelow` (at-or-below-`t`
   zone facts ↔ `kvE2_futAnyBit qnf`) + the two recorded σ-side obligations
   `hbase : nf0_dropFresh σ.1 = qnf.1` and `hbits` (σ's six at-or-below-`t` bits =
   `kvE2_futAnyBit qnf`, guarded by the six-constant disjunction), if no exterior `x1 > t`
   realizes σ then `kvE2_extNegFut σ` holds at `t`. Strengthening (mirrors Phase 3): NO
   `zFutT3`-marking hypothesis — a true positive form certifies `kvE2_futAdmissible σ`
   (else-branch `⊥`), and admissibility contains the marking.
2. **Support kit** (both private):
   - `kvE2_futSigma_atom` — generalized `kvE2_futSpikeSigma_atom`: σ's atom layer honest
     over `[x1, w, x, t]` from zone marking (admissibility cond 1) + `hbase` + `henv` +
     fresh profile at `x1`. Fresh-channel reads via `congrFun hzs` projections; env-channel
     reads via `nf0_dropFresh`/`mergeNF`/`skipFin_zero_succ` unfolding + `rfl`.
   - `kvE2_futChainDestruct` — converse of `kvE2_futChainBuild`: a true `D`-guarded chain
     at `s` yields endpoint `x1 > s` with `endF`, `D`-uniform gap `(s, x1)` (given visited
     characteristics pointwise imply `D`), and one occurrence per listed profile.
3. **Phase-8 consumption shape confirmed** — read OuterGate.lean:147
   `bracketEndChar_kvE2_complete_two_prior` (within the plan's read budget): `henv` from
   realized qnf's atom layer, `hbelow` from `kvE2_futAnyBit_correct`, `(hxw, hwt)` from
   qnf's order bits, `hbase`/`hbits` decidable matched-σ facts. Recorded in docstring.

## Proof architecture (contrapositive of the spike template, family-generalized)

`intro hPos`; inadmissible σ ⇒ `hPos : temporal_truth t ⊥` closes. Admissible σ: unpack
the four admissibility conjuncts (zone marking, off-fiber, impossible-zone, self-bit);
destructure the disjunction into a permutation `l ~ kvE2_futGapList σ` with a true chain at
`t`; `kvE2_futChainDestruct` reconstructs `x1 > t`, the endpoint description, the
`D`-uniform gap, and per-profile occurrences; `kvE2_futEnd`/`kvE2_futRayForm` give fresh
profile at `x1`, ray coverage (`¬F(¬D_ray)` ⇒ every `u > x1` carries a ray profile), and
per-ray occurrences. Then `nf_eval_depth1_fold_iff.mpr` with (i) `kvE2_futSigma_atom`,
(ii) per-zone biconditional — forward by 9-zone trichotomy classification
(`kvE2_futBelowClass`/`kvE2_futCharZone4` + profile uniqueness), backward by
`kvE2_futPossibleZones` case split (six below via `hbits`+`hbelow`+`kvE2_futZone4_below_iff`;
gap via occurrence extraction; self via self-bit pattern; ray via ray occurrences;
impossible zones via admissibility cond 3), (iii) off-fiber from admissibility cond 2 —
contradicting `hnorel x1 htx1`.

## Verification (phase gate)

- Scoped `lake build Bimodal.Metalogic.WeakCanonical.Kamp.ExteriorNegation`: GREEN,
  zero file diagnostics.
- Full `lake build`: GREEN (1721 jobs, matches Phase 3 baseline).
- `#print axioms` (lean_verify) on `kvE2_extNegFut_complete` AND preserved
  `kvE2_extNegFut_sound`, `kvE2_extNegFutSpike_complete`:
  all `{propext, Classical.choice, Quot.sound}`.
- Sorry census on ExteriorNegation.lean: 0. Repo-wide census: 163 = Phase-3 baseline
  exactly (0 new).
- Vacuous-definition scan: 0 new (1 hit = pre-existing Examples/TemporalStructures.lean:269).
  Axiom scan: 0 new (2 grep hits are comment text, unchanged).

## Phase-5/6 notes

- Phase 6 (past-side completeness) mirrors this proof; `kvE2_futChainDestruct` and
  `kvE2_futSigma_atom` are `private` — port or re-derive side-parametrically per the
  Phase-5 territory decision (plan: keep past-side copies local if parallel, dedupe in
  Phase 7).
- `HasAttainedINF` still not needed (chains finite; ray handled by exact-ray-content form).

## Commits

- (this commit) task 348 phase 4: future-side completeness kvE2_extNegFut_complete sorry-free
