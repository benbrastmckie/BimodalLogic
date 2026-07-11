# Task 344 — Continuation Handoff (dispatch 1 → dispatch 2)

- **Session**: sess_1783723095_edd5a7_344
- **Status at handoff**: Phase 1 [PARTIAL]. Foundation landed green (commit `9ea246946`). The
  three PROBEs are all resolved GO with machine evidence. The heavy construction (joint
  extractor + `kvE2_sepGateAtPin_fragL`) is the remaining Phase-1 work.
- **Territory**: `SharedWitness.lean` ADDITIVE-ONLY, below the TASK 344 banner (appended before
  the final `end`, line ~10037). No other `.lean` file edited. Confirmed clean.

## What is landed (green, committed `9ea246946`)

1. Additive banner (before the final `end Bimodal.Metalogic.WeakCanonical.Kamp`).
2. `def kvE2_sepFragment_frag {sig} (qnf : NormalForm sig 2 3) : Prop` — byte-identical to
   `OuterGate.kvE2_sepFragment` (`OuterGate.lean:191`). Restated locally because OuterGate imports
   SharedWitness (importing back = cycle). The two `def`s are **defeq**, so 335 can feed its
   `hfrag : kvE2_sepFragment qnf` directly to a lemma expecting `kvE2_sepFragment_frag qnf`.

## Confirmed GO architecture (the whole chain, evidence-anchored)

The frag chain replaces `kvE2_outer_fold`'s `hgateL`/`hgateR`/`hbdry` with `hfrag` + `hcorrK`,
threading `hexcl` verbatim. Key structural facts established by reading HEAD source:

- **`kvE_subBracket2V_sound_of_parts`** (`SubBracket2V.lean:1290`) consumes the ∀-anchor `hgate`
  at EXACTLY ONE point — `hgate x1 hxx1 hx1t hanchor` (`:1323`), where `x1` is the pin from the
  bundle parts. So a pin-anchored variant just INLINES the six conjuncts at `x1`; the proof
  continuation (`:1324-1345`) is identical.
- **`kvE2_sepBundleL`** (`SW:5327`) = `∃ x1, x < x1 ∧ x1 < w ∧ (kvE2_sepPtX1L … σ).eval_at x1 ∧
  (∀ χ, σ.2(zXU,χ)=true → ∃ u, x<u<x1 ∧ charBase χ at u)`. So `x1 < w` (conjunct 1) and the
  anchor at `x1` (via `kvE2_sepPtX1L_anchor`, `SW:5352`) and the `zXU` below-clause are FREE from
  the bundle. This dissolves the O4 "first obstruction" (`a < w`).
- **`kvE2_sepBody_extract`** (`SW:8410`) → `kvE2_sepDisjunct'_extract` (`SW:8232`) delivers the
  bundle per positive σ, but at `SW:8273` `obtain ⟨ws, hmono, hrange, hpt, -, -, -⟩` it DISCARDS
  the three segment (`beta`) components of the bracket holds. Those are the
  `IntervalPattern.holds_eq_succ` (`ExistsForallNF.lean:188-203`) components 4/5/6:
  first segment `beta 0` on `(x, ws 0)`, middle `beta (i+1)` on `(ws i, ws (i+1))`, last
  `beta (k+1)` on `(ws k, t)`. Their content is `kvE2_sepSegsG charBase qnf gL gR` (`SW:2167`),
  built into `kvE2_sepBracketN` (`SW:1183`) inside `kvE2_sepDisjunct'` (`SW:2204`).

## Remaining Phase-1 work (dispatch 2 — the heavy dispatch, ~300-500 lines)

### Step A — additive JOINT EXTRACTOR (the PROBE-1 mitigation lemma)

Mirror `kvE2_sepDisjunct'_extract` (`SW:8232-8395`) but KEEP the segment components. Signature
target (name suggestion `kvE2_sepBody_extract_frag` at the `kvE2_sepBody` level, going through
`kvE2_sepBody_holds_iff` `SW:2372` + `kvE2_sepDisjunct'_extract`'s guts):

Deliver, for the sole positive `σ0` under `hfrag`, jointly with the bundle:
- the pin `x1` with `x < x1 < w` and `kvE2_sepPtX1L … σ0` at `x1` (already in the bundle), AND
- the segment forms on the open intervals: for each open zone `zs ∈ {zXU=(x,x1), zUW=(x1,w),
  zWT=(w,t)}` (relative to `[x1,w,x,t]`), the appropriate `kvE2_sepSegForm charBase σ0 zs` holds
  at every point of that open interval. Under `hfrag` the tie-grouped lists are `σ0`'s own slots
  only (no cross-σ), so the bracket's segment/witness structure aligns 1:1 with these three zones.

Change from the landed extract: at `SW:8273` bind the last three components
(`hseg0 hsegMid hsegLast`) instead of `-, -, -`, and expose them zone-aligned. The zone alignment
is the substantive sub-task: relate `kvE2_sepSegsG` entries (indexed by tie-class position) to the
`[x1,w,x,t]` zones under the single-positive collapse.

### Step B — `kvE2_sepGateAtPin_fragL` (six conjuncts at the bundle pin `x1`)

With the joint extractor's output + `hcorrK`, prove the six conjuncts of the ∀-anchor gate but AT
the specific bundle pin `x1` (never `∀ a`):
1. `x1 < w` — bundle (`hx1w`).
2. `w < t` — context (`hwt`).
3. `nf_eval_nf M 0 4 [x1,w,x,t] σ.1` — `χ0*` at `x1` from `hcorrK` (provider correctness at the
   pin); `w`/`x`/`t` coordinate 1-types from `kvE2_sepPtW`/`EpL`/`EpR` head conjuncts via
   `nfPred_correct` (pattern at `SW:9963-9977`); order bits from `x<x1<w<t`.
4. off-fiber (`∀ τ, nf0_dropFresh τ ≠ σ.1 → σ.2 τ = false`) — `kvE2_sepHgate_offFiber`
   (`SW:6658`), needs `hg : kvE2_sepGate qnf` (from `.holds` via `kvE2_sepBody_holds_iff`) and
   `hσ : qnf.2 σ = true` (from `σ ∈ kvE2_sepPos`).
5. FORWARD (`∀ zs χ, (∃ v, zoneHolds [x1,w,x,t] zs v ∧ χ at v) → σ.2(zs,χ)=true`) — THE
   substantive conjunct. Channel: contrapositive of `kvE2_sepSegForm_excludes` (`SW:6683`) using
   the joint extractor's segment forms for open zones; `zAtX1L` self-zone via the biconditional
   literal in `kvE2_sepPtX1L` at `x1`; at-points via `kvE2_sepPtW`/`EpL`/`EpR` literals; inconsistent
   zones vacuous via `kvE_sub2V_zone_consistent` contrapositive (`SubBracket2V.lean:1535`) +
   `kvE2_sepHgate_innerNine` (`SW:6669`). Under `hfrag` there are NO cross-σ slots, so the O4
   CRUX-RECORD residue (`SW:6698-6791`, "bracket points inside another σ's zone") VANISHES — this
   is precisely why the fragment is GO where the general form was REFUTED.
6. backward (`∀ zs χ, zs ≠ zXU → σ.2(zs,χ)=true → ∃ v, …`) — σ's own slot channel: the bundle's
   `kvE2_sepPtX1L`/below-witnesses + the extractor's per-slot witnesses (`SW:8305-8340` pattern).

Then wrap into `kvE2_sepBundleL_sound_frag` (frag analog of `kvE2_sepBundleL_sound` `SW:9673`):
feed the six pin-conjuncts into the `kvE_subBracket2V_sound_of_parts` continuation to yield
`∃ x1, nf_eval_nf M 1 4 [x1,w,x,t] σ`.

## Phase 2 (dispatch 3) — mirror + kit

- `kvE2_sepGateAtPin_fragR` = the `zWX1`-mirror (RIGHT geometry: `kvE2_sepBundleR` `SW:5338` gives
  `w < x1 < t`; mirror `kvE2_sepBundleR_sound` `SW:9726`). L/R geometries genuinely differ.
- `kvE2_sepBody_kit_sound_frag`: VERBATIM conclusion of `kvE2_sepBody_kit_sound` (`SW:9830-9839`),
  from `hfrag` + `hcorrK` + `h`. Proof: `kvE2_sepBody_extract` → bundles; for the sole interior
  positive σ0, apply `kvE2_sepBundleL_sound_frag` / `_R` at the pin.

## Phase 3 (dispatch 3/4) — fold + handback

- `kvE2_outer_fold_frag`: proof BYTE-IDENTICAL to `kvE2_outer_fold` (`SW:9897-10035`) EXCEPT
  (a) `obtain … := kvE2_sepBody_kit_sound_frag … hcorrK` instead of `… hgateL hgateR`;
  (b) the final `hbdry` line (`SW:10035`) becomes vacuous under `hfrag` — `σ ∈ kvE2_sepPos qnf`
  with `kvE2_sepPos qnf = [σ0]` and σ0 interior contradicts `¬(zXW3 ∨ zWT3)`; close by
  `simp [hfrag]`/`rcases` on the singleton;
  (c) `hexcl` threaded verbatim (`SW:9952-9956`).
- HANDBACK to 335: the four landed signatures (see summary). 335 discharges `hcorrK` from
  `ExistProviders.correct` at `charK := P.existF 0`, runs the `hexcl` probe, and assembles
  `bracketEndChar_kvE2_correct_two_prior_frag` in `OuterGate.lean` (335 territory).

## Guards (unchanged, hard constraints)

- NEVER attempt the ∀-anchor extractor (report §1 REFUTED — derives a FALSE statement).
- `hcorrK`/`hexcl` stay explicit hypotheses; never discharged inside 344.
- Additive-only below the banner; `#print axioms` (via `lake env lean`, NOT `lean_verify`) must be
  `{propext, Classical.choice, Quot.sound}` on every landed lemma.
