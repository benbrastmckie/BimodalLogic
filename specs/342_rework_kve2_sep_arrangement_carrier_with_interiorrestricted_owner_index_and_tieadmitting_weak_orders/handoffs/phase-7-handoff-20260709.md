# Task 342 Phase 7 Handoff (sess_1783617988_38e7cf)

## Immediate Next Action

Phase 8 (honest non-interior evaluation pack): (a) generalize the coincidence discharges
`kvE2_sepCoincidentAnchor_discharge` (SW:2878) / `_R` (SW:3055) to an arbitrary FOREIGN base
type, concluding `kvE2_sepClosedLeafAt σa χ = true`; (b) the three endpoint/pivot honesty
lemmas `kvE2_sepEpL_eval_of_honest` / `kvE2_sepPtW_eval_of_honest` / `kvE2_sepEpR_eval_of_honest`.
See "Phase 8 Recipe" below. (a) and (b) are independent bounded units — land (a) green +
commit before starting (b).

## Current State

- Phase 7 [COMPLETED] (plan heading + all checklist items updated, deviations annotated).
- Full `lake build` green (1720 jobs). Commits: `ecc1e6056` (7.1 grouped builder defs),
  7.2 (singleton compat + honest Nodup), 7.3 (carrier rewire), phase-complete commit follows
  this handoff. Diff since `010527e6b`: +430/-27 lines, SharedWitness.lean only.
- **`kvE2_sepBody` (SW:2328) now emits GROUPED meet-folded disjuncts**:
  `(kvE2_sepArr' qnf).map fun wo => kvE2_sepDisjunct' charBase charK qnf
  (kvE2_sepTieGroupedL wo) (kvE2_sepTieGroupedR wo)`.
- **New declarations** (all axiom-clean `{propext, Classical.choice, Quot.sound}`):
  - `kvE2_sepClassType` (SW:2109) — meet-folded class point type
    `⟨formula_conjList (c.map (fun s => (kvE2_sepSlotType …).formula))⟩`; eval lemmas
    `_eval_iff` (SW:2116), `_eval_mem` (SW:2133, THE per-class extraction helper owed to the
    337 re-plan), `_singleton_eval` (SW:2144).
  - `kvE2_sepSegsG` (SW:2167) — grouped cut `i` = `kvE2_sepSegLAt` on `gL.flatten` at flat
    cut `((gL.take i).flatten).length`; right mirror; same `≤ gL.length` boundary convention
    as `kvE2_sepSegs`. Private `kvE2_sepSegsG_map_singleton` = flat dispatcher on singleton
    partitions for all bracket-relevant cuts (`i ≤ |lL| + 1 + |lR|` — the min/take arithmetic
    needs that bound in the RIGHT branch; do not "strengthen" to all `i`).
  - `kvE2_sepDisjunct'` (SW:2204) — TOP-LEVEL grouped builder; `kvE2_sepBracketN` consumed
    AS-IS; endpoints/ptW unchanged.
  - **Singleton compat (the Phase-7 exit obligation, PROVED)**:
    `kvE2_sepDisjunct'_map_singleton_iff` (SW:5417, core `gL = lL.map ([·])` shape) and
    `kvE2_sepDisjunct'_singleton_iff` (SW:5473, plan shape: all-singleton + flatten), over
    private `kvE2_sepBracketN_holds_congr` (SW:5336 — cross-length `.holds` congruence
    normalizing both brackets to one witness count via `IntervalPattern.holds_eq_succ`).
  - `kvE2_sepHonestOrder_slotsLOf_gidx_nodup` (SW:5543) / `_slotsROf_` (SW:5556) — the honest
    merged-chain `kvE2_sepSlotGIdx` payload is Nodup (halign bridge + `_honestGIdx_nodup`
    restricted along `kvE2_sep_flatMap_sublist` + `List.mergeSort_perm`/`Perm.flatMap_right`
    transfer). Hence every honest tie class is a singleton.
- **Repaired consumers**: `kvE2_sepBody_holds_iff` (SW:2372, now yields the grouped
  disjunct), `kvE2_sepBody_nonvacuous` (SW:2914, grouped member), `kvE2_sepBody_complete_holds`
  (SW:5579, RELOCATED below the compat block; **statement unchanged — `hdisj` stays FLAT**,
  converted grouped←flat via singleton compat on the honest Nodup payload),
  `kvE2_sepBody_extract` (SW:5825, gained `hnd` per-wo Nodup hypothesis — tie-free restriction,
  deviation annotated in plan; the tie-admitting extraction is Phases 8-10 arbitration).
- **Exit-gate audit**: guard `kvE2_sepHonest_hLR_absurd` (SW:5612) VERBATIM (awk-extracted
  text diff vs `010527e6b` empty); exactly one `(hLR :` binder file-wide (SW:5616);
  `kvE2_sepPosI_eq_pos` 0 repo-wide; `x1 <` count 73 (unchanged, 0 in new code);
  `kvE_sub2_` count 107 (unchanged, 0 in new code); axioms in Theories/ = 2 (baseline);
  vacuous-def scan 1 (pre-existing `Examples/TemporalStructures.lean` baseline); 0 code
  sorries in SharedWitness; `ExistsForallNF.lean`/`NavigatedSpine.lean`/`OuterGate.lean`
  diff EMPTY; `kvE2_sepBracketN` + `kvE2_sepBracketN_construct` diff EMPTY.

## Phase 8 Recipe (honest non-interior evaluation pack)

### Which tie-read obligations are open after Phase 7 (exact inventory)

Phase 7 changed the CARRIER only. No tie-read discharge was performed. Open obligations:

1. **F5 foreign-base CLOSED-key discharge (Phase 8a — THE F5 obligation)**. `kvE2_sepTieRead`
   (SW:1639) demands, for every (anchor σa, base χ-slot) tie-class pair in a valid wo,
   `kvE2_sepClosedLeafAt σa χ = true` — the anchor owner's CLOSED `zAtX1L`/`zAtX1R` self-zone
   bit generalized to the FOREIGN base type χ (SW:1525 region; `kvE2_sepClosedLeafStub_eq_at`
   SW:1533 is `rfl`). The landed discharges prove this ONLY for σa's OWN fresh type
   (`nf0_projFresh σ.1`): `kvE2_sepCoincidentAnchor_discharge` (SW:2878, LEFT: under honest
   `h` with `x < x1 < w`, `kvE2_sepBits σ kvE2_sep_zAtX1L χ = true` when χ is realized AT x1)
   and `_R` (SW:3055). **Required shape (a)**: under honest `h`, if base type `χ` is honestly
   realized AT owner σa's anchor point (equal honest values — the tie-class situation), then
   `kvE2_sepBits σa kvE2_sep_zAtX1L χ = true` for left-interior σa (mirror `zAtX1R`), hence
   `kvE2_sepClosedLeafAt σa χ = true`. Follow the existing discharges' proof route VERBATIM
   (same key family — they already take χ as a parameter with an `hp : realized-at-x1`
   hypothesis; inspect SW:2878's hypothesis list: the generalization may be mostly a wrapper
   exposing the foreign-χ instantiation + the `kvE2_sepClosedLeafAt` packaging). **No OPEN
   key (`kvE_sub2_`-shaped) may enter any coincident read; baseline `kvE_sub2_` count 107 —
   do not raise it.**
2. **Endpoint/pivot honesty lemmas (Phase 8b)**: `kvE2_sepEpL_eval_of_honest` (target:
   `(kvE2_sepEpL charBase charK qnf).eval_at M atomMap x`), `kvE2_sepPtW_eval_of_honest`
   (at `w`), `kvE2_sepEpR_eval_of_honest` (at `t`). EpL SW:1054, EpR SW:1076, PtW SW:1100 —
   each a `formula_conjList` of `kvE2_sepLit (kvE2_sepHasPos …) (…)` biconditional literals
   (kvE2_sepLit SW:173, kvE2_sepHasPos SW:244) plus per-owner `kvE2_sepBits` blocks. Reuse
   the house `hchar` hypothesis convention from `kvE2_sepHonestBasePairsL_eval` (SW:4519) and
   the coincidence discharges — do NOT invent a new hypothesis shape. Positive bits: exhibit
   the honest realization at the endpoint/pivot (the σ_w route of `kvE2_sepHonest_hLR_absurd`
   SW:5612, now as an obligation, not a contradiction); negative bits: absence of a positive
   owner with that projection. Cite §5 + Prop 3.5 (pp.5,7) atomic-E[Σ] routing.
3. **NOT Phase 8**: the tie-reporting honest order (`kvE2_sepHonestOrder'`), its `mem_arr'`
   (which is where discharge (a) gets CONSUMED for conjunct (iv)), and
   `kvE2_sepBody_complete_holds'` are Phase 9. The tie-admitting grouped EXTRACTION
   (replacing `kvE2_sepBody_extract`'s `hnd` restriction using `kvE2_sepClassType_eval_mem`
   per class + cross-class strictness from conjunct (ii)) is Phases 8-10 arbitration — do
   not start it inside Phase 8's budget.

### Gotchas carried forward

- `<+` (Sublist) and `~` (Perm) NOTATIONS DO NOT PARSE in SharedWitness.lean (token-level —
  project notation environment). Use `List.Sublist l₁ l₂` / `List.Perm l₁ l₂` explicitly.
- `List.forall_mem_zipIdx'` still not in import closure; `lean_run_code` still returns empty
  diagnostics (untrustworthy) — probe with builds.
- `rw` cannot rewrite under the match-branch binder of `kvE2_sepTieRuns` — `simp only` for
  `if_pos`/`if_neg` there (Phase-6 note, still true).
- The 340-task files (`specs/340_*/plans/03_*.md`, `working-progress-1783582863.patch`)
  remain dirty from an unrelated session — do NOT stage them.
- FORBIDDEN (unchanged): PosI/Pos equality lemma; hLR-shaped hypothesis; `kvE2_sepPosI` as
  zone-filter append; weakening `IntervalPattern.holds` strictness; citing "per the proof of
  Lemma 3.2(1)" (audited form: "forced by Def 3.1; Lemma 3.2(1) states the closure without
  printed proof; corroborated by the k=m split (p.7) and Def 7.5 (p.13)").

## Sorry Inventory

(empty)
