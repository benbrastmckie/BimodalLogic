# Research Report: R2 Blocker Repair Route — Route A (Tie-Admitting Grouped Extraction) vs Route B (Filter Strengthening)

- **Task**: 333 (`carrier_redefinition_kve2_separr_bit_compatibility_correctness_pair`)
- **Session**: sess_1783679696_817168
- **Date**: 2026-07-10
- **Mode**: hard (H2/H3/H4/H5), blocker research — probes and reads only; `SharedWitness.lean` unchanged
- **File under study**: `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge/SharedWitness.lean` (HEAD `278455724`, 9440 lines — all `SW:` line refs below are to THIS revision; the delegation's SW:63xx/51xx refs are pre-commit and stale)

## Verdict

**Route A closes the blocker. Route B is refuted as a viable repair.**

Route A (tie-admitting grouped extraction through `kvE2_sepClassType_eval_mem` over
`kvE2_sepTieGroupedL/R`) genuinely discharges everything `kvE2_sepBody_extract` owes its
downstream consumers, with **zero** universal side-conditions: the false `hpairL`/`hpairR`/`hnd`
hypotheses are simply deleted, replaced by facts derivable from carrier membership
(`wo ∈ kvE2_sepArr' qnf`) alone. The single genuinely new piece of mathematics Route A needs —
strict cross-run key monotonicity of `kvE2_sepTieRuns` on a sorted list — was **machine-verified
in this dispatch**: a standalone probe against a verbatim copy of `kvE2_sepTieRuns`
(SW:1971-1977) compiled green with zero diagnostics (`tieRuns_const`, `tieRuns_sorted_strict`,
`tieRuns_classIdx_lt`; full code in §Probe below).

Route B (strengthening `kvE2_sepDisjValid` / the arrangement filter so the universal
side-conditions become true) is refuted on three independent grounds, each file:line-grounded
(§Q2). The Phase-2 agent's conflict claim is **CONFIRMED** for the tie (`hnd`) half — it is not
merely a hypothesis.

## H3 — Source-to-Implementation Mapping (Tier 3: implementation-backed; carrier + task-342 record are ground truth per the fidelity caveat)

| Obligation | Source (file:line) | Existing lemma | Gap | Route |
|---|---|---|---|---|
| Extraction conclusion shape (EpL/EpR/∃w/ptW/bundles) | `kvE2_sepBody_extract` concl., SW:6534-6541 | `kvE2_sepDisjunct_extract` SW:6359 (flat only) | grouped analog `kvE2_sepDisjunct'_extract` (new, skeleton reusable from SW:6379-6448) | A |
| Realized grouped disjunct per `wo` | `kvE2_sepBody_holds_iff` SW:2372-2390 | landed, consumed unchanged | none | A |
| Per-class → per-member point realization | `kvE2_sepClassType_eval_mem` SW:2133-2140 | landed | none | A |
| Slot ∈ some tie class (membership) | `kvE2_sepTieGroupedL/R_flatten` SW:2064/2069 + `kvE2_sepSlotsLOf_mem` SW:2268 / `ROf_mem` SW:2278 | landed | trivial glue (`List.mem_flatten` + `List.mem_iff_getElem`) | A |
| Within-class key constancy | `kvE2_sepTieRuns` SW:1971 | absent | **NEW** `kvE2_sepTieRuns_const` — probe-verified green | A |
| Strict cross-class key order on sorted input | `kvE2_sepSlotsLOf_mergeSorted` SW:4083 (`Pairwise (kvE2_sepSlotMergeLe wo)`; key = `kvE2_sepSlotGIdx wo`, SW:1920/1932) | absent | **NEW** `kvE2_sepTieRuns_sorted_strict` + `_classIdx_lt` — probe-verified green | A |
| Same-owner STRICT gIdx order (lXU below lX1, rWX1 below rX1) | conjunct (ii) via `kvE2_sepArr'_consistent` SW:4330 | `kvE2_sep_rank_le_of_gidx_le` SW:4378 | contrapositive wrapper only (`rank b < rank a → gIdx b < gIdx a`; ¬≤ = < on ℕ) | A |
| Bundle → sound-kit 5-tuple | `kvE2_sepBundleL_parts` SW:5359 / `R_parts` SW:5376 | landed; consume `kvE2_sepBundleL/R` (SW:5302/5318) **unchanged** | none — Route A's bundle conclusions are shape-identical | A (Phase 3) |
| Sound kit closer | `kvE_subBracket2V_sound_of_parts` SubBracket2V.lean:1290 | landed, do-not-edit | none | A (Phase 3) |
| Completeness (⇐) chain preservation | `kvE2_sepHonestOrder'_mem_arr'` SW:6284, `kvE2_sepBody_complete_holds'` SW:6330, consumer SW:9424-9437 | landed | none under A; **broken under B** (tie half) | — |
| Non-vacuity `kvE2_sepArr' qnf ≠ []` | `kvE2_sepBody_complete` SW:3208-3214 via `kvE2_sepCoincidentOrder_mem_arr'` SW:3259 | landed | none under A (carrier untouched); **at risk under B** | — |

No Mathlib gap: all list infrastructure needed is either in-file or was closed in the probe
using only `Mathlib.Data.List.Basic` / `.Pairwise` (`List.pairwise_iff_getElem`,
`List.getElem_mem`, `List.mem_cons`, `Nat.lt_of_le_of_ne`, `omega`).

## Q1 — Does Route A discharge what `kvE2_sepBody_extract` needs? YES

**Where the false hypotheses are actually used** (the decisive read):

- `hnd` is consumed at exactly one place: SW:6548-6550, the tie-free **singleton conversion**
  (`kvE2_sepTieGroupedL/R_of_nodup` + `kvE2_sepDisjunct'_map_singleton_iff` SW:5703) that
  flattens the grouped disjunct back to the flat one so `kvE2_sepDisjunct_extract` applies.
- `hpairL`/`hpairR` are consumed at exactly two places inside `kvE2_sepDisjunct_extract`:
  SW:6420 and SW:6444, each a `kvE2_sep_index_lt_of_rank_lt` call deriving "the `lXU`/`rWX1`
  slot's list index is strictly below the `lX1`/`rX1` slot's index" — a **same-owner**
  index-ordering fact routed through the full (cross-owner) Pairwise.

Route A eliminates both uses: extract **directly from the grouped disjunct** (no singleton
conversion, so no `hnd`), and read same-owner ordering at the **class-index** level, where it
follows from carrier membership (no cross-owner relation ever enters):

1. Realized grouped bracket at `wo` (from `kvE2_sepBody_holds_iff` SW:2372): point-type list
   `gL.map kvE2_sepClassType ++ ptW :: gR.map kvE2_sepClassType` with
   `gL/gR = kvE2_sepTieGroupedL/R wo`. Destructure with the SAME skeleton as SW:6382-6397
   (`IntervalPattern.holds_eq_succ`, `kvE2_sep_getElem_mid/left/right` — all generic over the
   point-type list).
2. Shared witness `w := ws ⟨gL.length⟩` realizes `ptW` (`kvE2_sepDisjunct'` carries the same
   EpL/EpR/ptW, SW:2209-2213); `x < w < t` from the bracket's own range (FM-x1t preserved).
3. Per LEFT owner σ: `.lX1 σ ∈ kvE2_sepSlotsLOf wo` (SW:2268) → by
   `kvE2_sepTieGroupedL_flatten` (SW:2064) it lies in class `gL[iσ]`; `x1 := ws ⟨iσ⟩` realizes
   the meet class type, and `kvE2_sepClassType_eval_mem` (SW:2133) projects σ's own
   `kvE2_sepPtX1L` slot type. `iσ < gL.length` gives `x1 < w` by bracket monotonicity.
4. For each `zXU`-positive χ: `.lXU σ χ` lies in class `gL[jχ]`. Strict same-owner key order —
   `kvE2_sepSlotGIdx wo (.lXU σ χ) < kvE2_sepSlotGIdx wo (.lX1 σ)` — is the **contrapositive of
   the landed** `kvE2_sep_rank_le_of_gidx_le` (SW:4378; ranks 0 < 1, cf. the `Nat.zero_lt_one`
   read at SW:6421), which needs only `hwo : wo ∈ kvE2_sepArr' qnf` (conjunct (ii) via
   `kvE2_sepArr'_consistent` SW:4330). Then `jχ < iσ` by the probe-verified
   `tieRuns_classIdx_lt` applied at `kvE2_sepSlotsLOf_mergeSorted` (SW:4083), and
   `u := ws ⟨jχ⟩ < x1` by monotonicity — the strict "below" half of `kvE2_sepBundleL`
   (SW:5302). **A same-owner anchor-base tie cannot put `.lXU σ χ` and `.lX1 σ` in one class**:
   conjunct (ii) forces strictly distinct keys, so distinct classes. Cross-owner ties (the
   task-342-admitted ones) are harmless: they merely enlarge a class's meet, and
   `kvE2_sepClassType_eval_mem` reads through it. RIGHT mirror identically.

**Exact replacement obligation shape** (revised Phase 2, all additive in `SharedWitness.lean`):

```lean
-- (a) generic, probe-verified verbatim modulo renaming:
theorem kvE2_sepTieRuns_const {α : Type*} (key : α → ℕ) :
    ∀ (l : List α), ∀ c ∈ kvE2_sepTieRuns key l, ∀ x ∈ c, ∀ y ∈ c, key x = key y

theorem kvE2_sepTieRuns_sorted_strict {α : Type*} (key : α → ℕ) :
    ∀ (l : List α), l.Pairwise (fun x y => key x ≤ key y) →
      (kvE2_sepTieRuns key l).Pairwise (fun c d => ∀ x ∈ c, ∀ y ∈ d, key x < key y)

theorem kvE2_sepTieRuns_classIdx_lt {α : Type*} (key : α → ℕ) (l : List α)
    (hs : l.Pairwise (fun x y => key x ≤ key y))
    {i j : ℕ} (hi : i < (kvE2_sepTieRuns key l).length)
    (hj : j < (kvE2_sepTieRuns key l).length)
    {a b : α} (ha : a ∈ (kvE2_sepTieRuns key l)[i]) (hb : b ∈ (kvE2_sepTieRuns key l)[j])
    (hab : key a < key b) : i < j

-- (b) contrapositive wrapper of landed SW:4378 (same hypotheses):
theorem kvE2_sep_gidx_lt_of_rank_lt … :
    kvE2_sepSlotRank a < kvE2_sepSlotRank b → kvE2_sepSlotGIdx wo a < kvE2_sepSlotGIdx wo b

-- (c) the grouped extraction (replaces the hpair/hnd-consuming route):
theorem kvE2_sepDisjunct'_extract {sig} (charBase charK) (qnf)
    {wo : KvE2SepWeakOrder sig} (hwo : wo ∈ kvE2_sepArr' qnf)
    (M) (atomMap) (x t : M.carrier)
    (h : (kvE2_sepDisjunct' charBase charK qnf
        (kvE2_sepTieGroupedL wo) (kvE2_sepTieGroupedR wo)).2.holds M atomMap x t) :
    (kvE2_sepEpL charBase charK qnf).eval_at M atomMap x ∧
    (kvE2_sepEpR charBase charK qnf).eval_at M atomMap t ∧
    ∃ w, x < w ∧ w < t ∧ (kvE2_sepPtW charBase charK qnf).eval_at M atomMap w ∧
      (∀ σ ∈ kvE2_sepPos qnf, nf0_zoneSpec σ.1 = kvE2_sep_zXW3 →
        kvE2_sepBundleL charBase charK σ M atomMap w x) ∧
      (∀ σ ∈ kvE2_sepPos qnf, nf0_zoneSpec σ.1 = kvE2_sep_zWT3 →
        kvE2_sepBundleR charBase charK σ M atomMap w t)

-- (d) the revised body extraction — NO side-conditions at all:
theorem kvE2_sepBody_extract (charBase charK qnf M atomMap x t)
    (h : (kvE2_sepBody charBase charK qnf).holds M atomMap x t) :
    ⟨same conclusion as (c)⟩
-- proof: by_cases hgate; holds_iff → ⟨wo, hwo, hd⟩ → kvE2_sepDisjunct'_extract hwo … hd;
-- gate-fail branch verbatim SW:6557-6558.
```

Note (c) internally derives the sortedness input from `kvE2_sepSlotsLOf/ROf_mergeSorted`
(SW:4083/4089) — `kvE2_sepSlotMergeLe wo a b = decide (gIdx ≤ gIdx)` (SW:1932), so
`Bool.Pairwise → Prop.Pairwise` is a `simpa`-level bridge. The `hmemL/hmemR`-style coverage
facts are supplied by `kvE2_sepSlotsLOf_mem`/`ROf_mem` (SW:2268/2278) with
`hwo' : wo ∈ kvE2_sepOrderTypes` from `List.mem_filter.mp hwo`, exactly as at SW:6545.
Estimated size: ~120 lines generic tie-run lemmas (probe: 100 lines as compiled) + ~120-180
lines grouped extraction (skeleton transposed from SW:6359-6448). Fits H8 single-dispatch.

**Disposition of the current `kvE2_sepBody_extract` (SW:6520)**: it has **zero consumers** —
in-file or repo-wide (grep: only docstring mentions at SW:2249/2266/4320/4483/4501/7108).
Replacing its hypothesis list is interface-safe. Recommend replacing in place (its universal
side-conditions are permanently undischargeable, dead weight on the live path); the plan
revision must restate the "consume-only" clause at plan line 229-230, which currently reads
"R2 discharges their `hpairL`/`hpairR`/`hnd`" — impossible as written.

## Q2 — Route B conflict claim: CONFIRMED (tie half), and independently blocked

**(i) The `hnd` half genuinely conflicts with task 342 — machine-grounded, not hypothetical.**
The former global-Nodup conjunct (iii) was removed from `kvE2_sepDisjValid` precisely because
"it made the Lemma 3.2(1) equality-case order types unrepresentable (honest base-base slot ties
and base-foreign-anchor ties realized NO disjunct at all — a machine-certified completeness
hole)" (SW:1756-1759, the validity's own docstring). The PRIMARY completeness hand-off
`kvE2_sepBody_complete_holds'` (SW:6330, consumed at SW:9424-9437) rests on
`kvE2_sepHonestOrder'_mem_arr'` (SW:6284), whose witness `kvE2_sepHonestOrder'` (SW:6138)
carries the value-only payload that "is EQUAL exactly where honest values coincide" — i.e. for
a genuinely-tied honest model its mapped-gIdx list **literally duplicates**. Re-adding any
payload-Nodup conjunct falsifies that membership and re-opens the hole. (The tie-broken
`kvE2_sepHonestOrder`, SW:3863, with Nodup payload SW:5829/5842, only supports the degenerate
`kvE2_sepBody_complete_holds` SW:5869, which the docstring at SW:6325-6328 states "cannot
express" genuinely-tied honest models — the flat bracket demands strictly ordered distinct
witnesses for slots whose honest values coincide.)

**(ii) The cross-owner-compat half is not a 342 conflict per se, but it fails elsewhere.**
A new conjunct making `kvE2_sepCompat` hold across sorted cross-owner pairs must be
re-discharged at every membership site: `kvE2_sepArr'_mem_modelOrder` (SW:1888),
`kvE2_sepCoincidentOrder_mem_arr'` (SW:3259) — which underwrites non-vacuity
`kvE2_sepBody_complete` (SW:3208) — and both honest orders (SW:3906, SW:6284). The coincident
order's validity is discharged by closed-key reads with no cross-owner OPEN-bit fact available
(SW:3220-3248); a conjunct reading `kvE2_sepBits σ kvE_sub2_zXU χ` at foreign 1-types is not
guaranteed for arbitrary `qnf`, so non-vacuity — the property task 333's description requires
re-established — would be put at risk for exactly the configurations the counterexample in the
blocker record constructs (plan 05:305-310).

**(iii) Even a successful compat-strengthening leaves `hnd` false** (ties remain admitted), so
Route B cannot unblock the extraction without ALSO the tie half — which is (i). And the
Territory Contract (plan 05:190) binds "carrier structure `kvE2_sepArr'`/`kvE2_sepDisjValidOwner`/
`kvE2_sepBody` stays byte-identical"; Route B edits `kvE2_sepDisjValid` and is out-of-contract
without renegotiating the task-335 authorization.

**Verdict: Route B refuted.** The Phase-2 agent's claim is confirmed for ties; grounds (ii) and
(iii) independently close the remaining escape hatch.

## Q3 — Non-vacuity under Route A: PRESERVED (trivially)

Route A is extraction-side only: `kvE2_sepArr'` (SW:1776), `kvE2_sepDisjValid` (SW:1767), and
`kvE2_sepBody` (SW:2328) are untouched (satisfying the byte-identity clause). The re-established
non-vacuity property — `kvE2_sepArr' qnf ≠ []` under an honest realization, via the coincident
disjunct (SW:3208-3248; carrier docstring SW:2325-2327) — is consumed unchanged. No new
hypothesis is added to any completeness-side lemma.

## Q4 — What the six landed lemmas buy Route A

| Landed lemma (commit 98c1b6afa) | Load-bearing for Route A? | Role |
|---|---|---|
| `kvE2_sepArr'_consistent` SW:4330 | **YES** | conjunct-(ii) accessor feeding the strict same-owner gIdx read |
| `kvE2_sep_find?_owner_entry` SW:4341 | **YES** (transitively) | powers `kvE2_sepSlotGIdx_read` |
| `kvE2_sepSlotGIdx_read` SW:4364 | **YES** | payload read on arbitrary valid `wo` |
| `kvE2_sep_rank_le_of_gidx_le` SW:4378 | **YES** | its **contrapositive** IS the needed `gidx_lt_of_rank_lt` (ℕ: ¬≤ = <) |
| `kvE2_sepSlotsLOf_pairwise_sameOwner` SW:4417 | Not directly | states same-owner `kvE2_sepSlotLe`; the grouped route never consults `kvE2_sepSlotLe` (class order replaces it). Banked, harmless; useful if a flat-path variant is ever revived |
| `kvE2_sepSlotsROf_pairwise_sameOwner` SW:4450 | Not directly | mirror of the above |

Four of six are directly load-bearing; the other two are compatible bank. Nothing is re-proved.

## Q5 — Task 335 interface impact

None adverse; strictly easier. `bracketEndChar_kvE2_sound_two_prior` (OuterGate.lean:24 blocked
note) consumes `kvE2_outer_fold` (plan 05:174, NavigatedSpine.lean:445 sketch), NOT
`kvE2_sepBody_extract` directly — and `kvE2_sepBody_extract` has zero consumers anywhere
(repo grep). Route A **removes** hypotheses from the extraction, so nothing new bubbles up into
the OuterGate ⇒ path; the `kvE2_outer_fold` statement Phase 4 owes 335 is unchanged.
Coordination needed: only the already-flagged staleness of 335's BLOCKED record
(OuterGate.lean:180-203, see plan 05:166-175) plus one NEW item for the plan revision — the
plan's own consume-only clause (05:229-230) and Phase-3 task text (05:381) both say "with R2's
`hpairL`/`hpairR`/`hnd` discharged" and must be restated to "from the revised hypothesis-free
`kvE2_sepBody_extract`". The Territory Contract's carrier byte-identity clause is honored by
Route A as-is.

## Q6 — Phase 3 / Phase 4 survival

- **Phase 3 (kit application) survives with wording-only restatement.** Its inputs are the
  per-σ `kvE2_sepBundleL/R` Props (SW:5302/5318) and the reducers `kvE2_sepBundleL_parts`
  (SW:5359) / `kvE2_sepBundleR_parts` (SW:5376) into `kvE_subBracket2V_sound_of_parts`
  (SubBracket2V.lean:1290). Route A's revised extraction produces bundles of the **identical
  shape** (conclusion (c) above = SW:6534-6541 verbatim). Only the task bullets referencing
  "R2's hpairL/hpairR/hnd discharged" (05:381) change; the kit-threading content, the
  right-class watch item (SW:5374-5375 "no landed consumer yet"), timing, and done-criteria are
  intact.
- **Phase 4 (`kvE2_outer_fold`, make-or-break) survives unchanged.** It consumes Phase 3's
  per-σ `nf_eval` realizations + `ExistProviders.correct` + the navigated sub-chain; none of its
  tasks, risks, or the RESCOPE contingency (NavigatedSpine.lean:440-449) reference the R2
  side-condition shapes. Its make-or-break status and no-route escalation path are unaffected
  by the choice of extraction route.

## H5 — Divergence audit (plan framing vs carrier annotations): CONFIRMED mis-promotion

| Target | Churn | Last approach | Failure reason |
|---|---|---|---|
| `hpairL`/`hpairR` exact shape | 2 (plan-02 R2 → plan-05 Phase 2 dispatch) | full decomposition via `mergeSorted` + `imp_of_mem` | cross-owner half FALSE (`kvE2_sepCompat` reads an OPEN bit no `kvE2_sepDisjValid` conjunct reads; counterexample plan 05:305-310) |
| `hnd` exact shape | 2 (same) | `List.Nodup.map_on` over `kvE2_sepSlotsLOf_nodup` | FALSE: base-base ties deliberately admitted (SW:1756-1759, task 342) |

**Root cause**: reports 02/03 and plan-02/05 promoted the carrier's own *configuration
restrictions* into universally dischargeable side-conditions. Verified against source: the
task-334 note (SW:6505-6510) says the `hpair` facts "hold whenever the canonical union is a
single region-sorted block (e.g. the singleton configuration; the general multi-owner pairwise
discharge is the completeness-side Phase-8 obligation)", and the task-342 note (SW:6512-6519)
calls `hnd` a restriction "to the TIE-FREE configuration" whose "genuinely tie-admitting
extraction (reading per-class witnesses through `kvE2_sepClassType_eval_mem`) is the
Phases 8-10 arbitration item, NOT a Phase-7 obligation". The plan nonetheless asserted
(05:342) "Unchanged from plan-02; the report calls it mechanical and correctly stated". The
Phase-2 agent's mis-promotion claim is **verified**. Corrected Lean-ready targets: the exact
signatures in Q1 (a)-(d) — types, not descriptions.

**Sorry inventory**: empty (phase-2 handoff §Sorry Inventory; no sorries anywhere in territory).
**Type-mismatch table**: the two residues are not type mismatches but falsity — recorded
verbatim in plan 05:280-293 (`⊢ kvE2_sepCompat a b = true`; `⊢ x = y` from GIdx equality). Under
Route A both goals **disappear** (never posed): cross-owner order is never consulted, and GIdx
injectivity is replaced by class grouping.

## Probe (H2 — machine verification of the one new obligation)

`lean_run_code`, this dispatch, exit green (`{"success":true,"diagnostics":[]}`): standalone
copy of `kvE2_sepTieRuns` (verbatim from SW:1971-1977, incl. `tieRuns_shape` = SW:1980) plus
full proofs of `tieRuns_const`, `tieRuns_sorted_strict`, `tieRuns_classIdx_lt` — the exact
statements in Q1(a). Imports: `Mathlib.Data.List.Basic`, `Mathlib.Data.List.Pairwise` only.
Proof technique: structural recursion mirroring the def + `List.pairwise_cons` /
`List.pairwise_iff_getElem` + `omega`; ~100 lines total. This bounds revised-Phase-2 risk to
transcription plus the extraction-skeleton transposition (whose flat template SW:6379-6448 is
landed and green).

## Recommended revised Phase 2 (for /revise)

1. Land generic `kvE2_sepTieRuns_const` / `_sorted_strict` / `_classIdx_lt` (probe transcript).
2. Land `kvE2_sep_gidx_lt_of_rank_lt` (contrapositive wrapper of SW:4378, same private style).
3. Land `kvE2_sepDisjunct'_extract` (grouped analog; skeleton = SW:6359-6448 with class types;
   `kvE2_sepClassType_eval_mem` at each point read; class-index ordering per Q1 step 4).
4. Replace `kvE2_sepBody_extract` with the hypothesis-free version (d); delete the singleton
   conversion path from the live route (keep `_of_nodup`/`_map_singleton_iff` — the completeness
   side still uses them at SW:5882-5884).
5. Restate plan 05:229-230 and 05:381; LITMUS/no-nesting/L-R confinement audits as before
   (all new lemmas are pure list/ℕ + point-type reads — no zone bit, no order literal).

Constraint check: no filter weakened (none touched); `hgate` not assumed (gate-fail branch
verbatim); no `x1 < e_i` literal (index-level reads only); no nested point types (class meets
are `formula_conjList` over existing slot types — the landed task-342 shape, SW:2109); no sorry.

## Adversarial Self-Verification

Attempted refutations of the recommendation, each checked against source or probe:

| Claim | Source/Counterexample | Verification Method | Confidence |
|---|---|---|---|
| `hnd` is used ONLY for the singleton conversion (so grouped extraction removes the need) | SW:6548-6550 is the sole use in the proof body; hypothesis binder SW:6528-6530 | Read of full proof SW:6542-6558 | High |
| `hpairL/R` used ONLY via `kvE2_sep_index_lt_of_rank_lt` for same-owner index order | SW:6420, SW:6444 (only occurrences in SW:6359-6448); passed through at SW:6554-6555 | Read of full proof | High |
| Same-owner anchor/base slots can NEVER share a tie class on a valid `wo` (else `u < x1` strictness fails) | conjunct (ii): `kvE2_sepArr'_consistent` SW:4330 + strict block read SW:4402-4405; contrapositive of `kvE2_sep_rank_le_of_gidx_le` SW:4378 gives strict key inequality → distinct runs | Read + landed-lemma contraposition (ℕ `¬≤ = <`) | High |
| The new tie-run lemmas are actually provable (not another mis-promotion) | probe compiled green against a VERBATIM copy of `kvE2_sepTieRuns` | `lean_run_code`, zero diagnostics | High |
| Route B tie half re-opens the completeness hole | SW:1756-1759 (validity docstring: "machine-certified completeness hole"); `kvE2_sepHonestOrder'` payload duplicates on tied honest values (SW:6131-6137) breaking SW:6284 → SW:6330 → SW:9424-9437 | Read of task-342 chain | High |
| Route B compat half endangers non-vacuity | `kvE2_sepBody_complete` SW:3208 discharges via coincident order with closed-key reads only (SW:3220-3248); a cross-owner OPEN-bit conjunct is unavailable there for general `qnf` (counterexample family: plan 05:305-310) | Read; NOT machine-refuted for every conceivable conjunct design | Medium |
| `kvE2_sepBody_extract` hypothesis change is interface-safe | zero consumers in repo (grep over `Theories/`); task 335 consumes `kvE2_outer_fold`, not the extraction (plan 05:174; OuterGate.lean:24) | grep + read | High |
| Grouped destructuring skeleton transposes (holds_eq_succ / getElem_mid generic over point lists) | SW:6382-6397 uses `lL.map (kvE2_sepSlotType …)` only through generic list positions; `kvE2_sepDisjunct'` SW:2204-2215 has the same `map ++ ptW :: map` shape | Read; NOT probe-compiled (transposition risk noted below) | Medium |

**Residual failure modes surfaced** (honest risk register for the implementer):
1. *Un-probed transposition*: `kvE2_sep_getElem_mid/left/right` and
   `IntervalPattern.holds_eq_succ` were verified generic **by read**, not by compile, at the
   grouped instantiation. If any is secretly specialized to `kvE2_sepSlotType` lists, ~30 extra
   glue lines. Mitigation: they are consumed at SW:6497 with underscores (shape-generic).
2. *Bool/Prop Pairwise bridge*: `mergeSorted` gives `Pairwise (kvE2_sepSlotMergeLe wo · · = true)`;
   the probe lemma wants `Pairwise (key ≤ key)`. `kvE2_sepSlotMergeLe` is literally
   `decide (gIdx ≤ gIdx)` (SW:1932), so `List.Pairwise.imp (by simpa …)` closes it — same move
   as SW:4438-4439.
3. *Route B not refuted for EVERY conceivable filter design* (Medium row above): a sufficiently
   clever conjunct might thread compat while preserving all four membership sites — but it must
   simultaneously solve ties (impossible per the High row) and violate the byte-identity
   territory clause, so the verdict stands on the conjunction.

**Contradiction log**: one apparent contradiction found and resolved — the honest order HAS
Nodup gIdx (`kvE2_sepHonestOrder_slotsLOf_gidx_nodup` SW:5829) yet ties were "needed for
completeness". Resolution (source precedence): there are TWO honest orders; the lex-tiebroken
one (SW:3863) is Nodup but its flat disjunct is unrealizable in genuinely-tied honest models
(SW:6325-6328), while the tie-REPORTING one (SW:6138) is the completeness witness and
duplicates. No unresolved contradictions remain.

## References

- Blocker record: plan `05_kit-application-and-outer-fold.md` Phase 2 (lines 271-367) + in-file
  block SW:4482-4508
- Phase-2 handoff: `handoffs/phase-2-handoff-20260710-0359.md`
- Landed halves: commit `98c1b6afa`, `7c1b191ee`
- Fidelity caveat honored: no Rabinovich `md:NN` citations added; tie-admission treated as a
  carrier-design question grounded in Lean source + task-342 record (per report 03)
