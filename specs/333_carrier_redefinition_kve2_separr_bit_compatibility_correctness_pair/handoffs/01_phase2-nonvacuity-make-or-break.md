# Task 333 Handoff — resume at Phase 2 (non-vacuity make-or-break)

- **Session**: sess_1783522894_0a5276
- **Status**: partial (Phase 1 partially landed; Phase 2 is the blocking make-or-break)
- **Build**: GREEN — `lake build Bimodal.Metalogic.WeakCanonical.Kamp.NfMultiAnchorBridge.SharedWitness` exit 0
- **Live sorries**: 2 (unchanged strategic pair)
  - `SharedWitness.lean:1889` — `kvE2_sepSingleton_coverage_left` (plan Phase 4 target)
  - `SharedWitness.lean:2021` — `kvE2_sepBody_singleton_complete_left` (plan Phase 5 target)
- **Only file touched**: `SharedWitness.lean`. All do-not-edit assets byte-identical.
- **Module target note**: the correct lake target is `Bimodal.Metalogic.…SharedWitness`
  (root `Bimodal`, srcDir `Theories`). `Theories.Bimodal.…` is an UNKNOWN target — do not use it.

## What landed (committed, green): `e86d9dcf4`

The Rabinovich Lemma 3.2(1) (md:77) cross-σ bit-compatibility predicate, as four documented,
compiling definitions inserted just before `kvE2_sepSlotLe` (~line 326):

- `kvE2_sepSlotChi : KvE2SepSlot → Option (NormalForm sig 0 1)` — the optional base 1-type
  (`none` for the two fresh slots `lX1`/`rX1`).
- `kvE2_sepFreshZoneBefore` / `kvE2_sepFreshZoneAfter : KvE2SepSlot → Option (ZoneSpec 4)` —
  a fresh slot's owner's before/after-fresh region zone patterns. Chosen to EXACTLY match the
  zone each region's own 1-type slots read their bits at:
  - `lX1` → before `kvE_sub2_zXU` (x<v<x1), after `kvE_sub2_zUW` (x1<v<w)
  - `rX1` → before `kvE2_sep_zWX1` (w<v<x1), after `kvE_sub2_zWT` (x1<v<t)
- `kvE2_sepCompat a b : Bool` — for a DIFFERENT-owner ordered pair (a before b): if b is σ's
  fresh slot and a carries χ, require `kvE2_sepBits σ (beforeZone) χ = true`; symmetrically if a
  is σ's fresh slot and b carries χ, require `kvE2_sepBits σ (afterZone) χ = true`. Two 1-type
  slots or two fresh slots impose no cross constraint.

These are **not yet wired** into the live filter. Reason: see "Why the switch cannot land green
without Phase 2" below.

## The full switch + mechanical repairs (verified-compiling): `handoffs/phase1-switch-and-repairs.patch`

`git apply` this patch onto the committed file to reproduce the FULL Phase 1 redefinition. It was
built and **compiles cleanly except for the two Phase 2 lemmas** (`kvE2_sepSlotsL_valid`,
`kvE2_sepSlotsR_valid`). It contains, all verified green in isolation:

1. In-place switch of `kvE2_sepSlotLe` to
   `if kvE2_sepSlotSub a = kvE2_sepSlotSub b then decide (rank a ≤ rank b) else kvE2_sepCompat a b`.
2. `kvE2_sepSlotLe_same` (same-owner rank) + `kvE2_sepSlotLe_of_ne_compat`
   (diff-owner ⇒ compat) replacing the old `_of_rank`/`_of_sub_ne`.
3. `kvE2_sep_pairwise_rank_same` bridge (rank-Pairwise + all-owner-σ ⇒ validity-Pairwise).
4. `kvE2_sepSlotsLFor_rankPairwise` / `kvE2_sepSlotsRFor_rankPairwise` (old block proofs with
   `kvE2_sepSlotLe_of_rank X` → `X`) wrapped by the unchanged-signature `…_pairwise` lemmas.
5. `kvE2_sep_index_lt_of_rank_lt` (index lemma) rewrite updated:
   `rw [if_pos hsub.symm, decide_eq_true_eq] at hle`.

Steps 1–5 are all mechanically sound and green. **Do not redo them** — apply the patch.

## The ONLY blocker = Phase 2 make-or-break (plan §Phase 2, HIGH risk)

After applying the patch, exactly two declarations fail to compile, both because the **canonical
identity (block-by-owner) arrangement is no longer valid** under the bit-compat filter:

- `kvE2_sepSlotsL_valid` / `kvE2_sepSlotsR_valid` (`~:822/:834` post-patch) — claim
  `kvE2_sepValid (kvE2_sepSlotsL/R qnf) = true`. FALSE in general now: a σ₁ base slot preceding
  σ₂'s fresh slot requires `kvE2_sepBits σ₂ zXU χ_{σ₁} = true`, which honest models do not force.
- `kvE2_sepBody_nonvacuous` (`~:1018`) consumes those two lemmas (`Perm.refl` witness at
  `:1035/:1039`).

### What Phase 2 must build (the research step)

Replace the identity witness with a **joint model-sorted arrangement** proven valid from the
honest realization `h : nf_eval_nf M 2 3 [w,x,t] qnf`:

- From `h`, every positive σ yields `x1_σ` and its realized atom layer; sort ALL left slots by the
  real model position of their realizing point. That induced permutation of `kvE2_sepSlotsL qnf`
  is (a) a `List.Perm` of the flatMap list, and (b) `kvE2_sepValid`, because each foreign base
  slot carrying χ sits (in the real order) inside σ's before/after-fresh region exactly where the
  honest model realizes χ, so `kvE2_sepBits σ zone χ = true` (compat). Mirror for the right list.
- There is **no reusable joint analog** of `k1v_sorted_realization` /
  `k1v_sorted_realization3` (`SubBracket2V.lean:379`, `CarrierK1V.lean:1447`) — those sort a
  SINGLE σ's per-region points. The joint cross-σ sort over `kvE2_sepPos qnf` must be built new
  (plan Phase 2, ~200–300 lines, budgeted 4–5h, flagged possibly irreducible).
- **Do NOT weaken the filter to vacuity** to make non-vacuity pass (Postmortem Constraint, HIGH):
  if the honest arrangement cannot be shown to pass, the compat predicate is too strong —
  re-examine the before/after zone assignment, do not relax toward vacuity. The zone assignment
  above was chosen so the honest arrangement passes by construction; verify that first.

### Recommended resume sequence

1. `git apply handoffs/phase1-switch-and-repairs.patch` (restores the full switch, green except
   the two `_valid` lemmas + `nonvacuous`).
2. Run the plan's Phase 1 2-positive `#eval`/`decide` sanity check (reject arrangement-blind
   bad interleaving, admit a bit-true one) to validate the predicate BEFORE the hard proof.
3. Build the joint model-sorted arrangement lemma; reprove `kvE2_sepSlotsL_valid`/`_valid` as
   honest-order lemmas (or delete them and inline the sorted witness into `nonvacuous`).
4. Rebuild `kvE2_sepBody_nonvacuous` on the sorted witness → GREEN, sorry count still 2.
5. Then proceed to plan Phases 3–8 (plumbing, discharge the two sorries, multi-positive lift,
   gate wrapper, F4 discriminator).

## Sorry inventory (both pre-existing strategic, tracked)

| file:line | statement | strategic | why deferred | follow-up |
|-----------|-----------|-----------|--------------|-----------|
| SharedWitness.lean:1889 | `kvE2_sepSingleton_coverage_left` | true | plan Phase 4 — needs Phase 3 surfaced segments, which need the Phase 2 filter switch first | task 333 Phase 4 |
| SharedWitness.lean:2021 | `kvE2_sepBody_singleton_complete_left` | true | plan Phase 5 — O6 completeness lift, needs the switched filter + Phase 4 | task 333 Phase 5 |
