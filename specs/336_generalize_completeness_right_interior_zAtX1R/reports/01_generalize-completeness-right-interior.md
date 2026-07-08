# Research Report — Task 336: Generalize `kvE2_sepBody_complete` to Right-Interior Owners

**Task**: Generalize the ⇐ (completeness) half of Rabinovich Lemma 3.2(1)
(`kvE2_sepBody_complete`) from the left-interior positive-owner class (gated by `hL`) to
also cover right-interior owners, by routing the already-landed `zAtX1R` right-coincidence
discharge into the coincident validity predicate.

**File scope**: `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge/SharedWitness.lean`
(2545 lines, namespace `Bimodal.Metalogic.WeakCanonical.Kamp`).

**Status**: researched. All claims below are grounded in source reads and `lean_verify`.

**Session**: sess_1783546987_0faeae_336

---

## Executive Summary

This is **predominantly predicate-wiring, but NOT zero new proof code**. The genuine
mathematics (the right coincidence discharge at `zAtX1R`) is already landed sorry-free and
axiom-clean. What remains is:

1. Making the coincident validity read the **placement-appropriate** closed self-zone bit
   (`zAtX1L` for left-interior, `zAtX1R` for right-interior) instead of hardcoding `zAtX1L`.
2. Adding one new mirror lemma `kvE2_sepCoincidentOwner_valid_right` (~25-30 lines, a
   mechanical mirror of the existing `_valid_left`; uses the landed discharge_R + the same
   bound-extraction pattern already present in `kvE2_sepHonestBundleR`).
3. Relaxing `kvE2_sepBody_complete`'s hypothesis from left-only `hL` to a left-OR-right
   disjunction `hLR`, with a per-owner case split.

**Key finding (scope correction)**: The task cannot drop the interior hypothesis *entirely*.
`kvE2_sepPos` admits **seven** outer zone classes (`kvE2_sepOuterConsistent`, :631-633); only
`zXW3` (left-interior) and `zWT3` (right-interior) have a fresh anchor and a coincidence
discharge. There is **no dichotomy lemma** proving positive owners are always interior. The
honest generalization is therefore `hL` → `hLR` (left ∨ right interior), NOT unconditional. The
task's framing ("generalize ... to right-interior owners") matches this exactly — it asks to
*add* the right class, not to remove the guard. This is the one non-trivial obligation and it
is bounded.

---

## (1) Current definitions, locations, and where `zAtX1L` is hardcoded

### `kvE2_sepClosedLeafStub` (:726-728) — the hardcode site
```lean
def kvE2_sepClosedLeafStub {sig : MonadicSignature}
    (σ : NormalForm sig 1 4) : Bool :=
  kvE2_sepBits σ kvE2_sep_zAtX1L (nf0_projFresh σ.1)   -- zAtX1L HARDCODED here
```
Plain (computable) `def`. This is the single place the left self-zone is hardcoded for the
coincident disjunct.

### `kvE2_sepDisjValidOwner` (:733-737) — the coincident case
```lean
def kvE2_sepDisjValidOwner {sig : MonadicSignature}
    (σ : NormalForm sig 1 4) : KvE2SepSpikeOrderType → Bool
  | .strictBefore => kvE2_sepBits σ kvE_sub2_zXU (nf0_projFresh σ.1)   -- OPEN zXU
  | .strictAfter  => kvE2_sepBits σ kvE_sub2_zUW (nf0_projFresh σ.1)   -- OPEN zUW
  | .coincident   => kvE2_sepClosedLeafStub σ                          -- CLOSED, via stub
```
The `.coincident` branch delegates to the stub, so `zAtX1L` reaches it indirectly. The strict
branches are unaffected by this task (they read OPEN keys — F5).

### Zone specs
- `kvE2_sep_zAtX1L` (:114): left-interior fresh self-zone `v = x1` with `x < x1 < w`.
- `kvE2_sep_zAtX1R` (:123): right-interior fresh self-zone `v = x1` with `w < x1 < t`.

### Downstream chain (all definition-agnostic w.r.t. the `.coincident` branch)
- `kvE2_sepDisjValid` (:742-744): `wo.all (fun p => kvE2_sepDisjValidOwner p.1 p.2)`.
- `kvE2_sepArr'` (:748-750): `(kvE2_sepOrderTypes qnf).filter (kvE2_sepDisjValid qnf)`.
- `kvE2_sepArr'_decidable` (:753-755): decidability via `Decidable (… = true)` on a `Bool` —
  survives any change (even if the stub becomes `noncomputable`).

### Independent (do-not-touch) sibling: the Phase-1 "spike" cluster
`kvE2_sepSpikeDisjValid` (:2278-2283) is a **separate** predicate over a foreign `χ` that also
hardcodes `zAtX1L` (:2283), consumed by `kvE2_sepCompat_zAtX1L_eq` (:2378). This is NOT
`kvE2_sepClosedLeafStub` and is NOT in scope — leave it alone.

---

## (2) The landed right-coincidence discharge and the `zAtX1R` self-zone

### `kvE2_sepCoincidentAnchor_discharge_R` (:1493-1514) — LANDED, axiom-clean
```lean
theorem kvE2_sepCoincidentAnchor_discharge_R {sig} (σ : NormalForm sig 1 4)
    (M) (x1 w x t) (hxw : x < w) (hwx1 : w < x1) (hx1t : x1 < t)
    (hσ : nf_eval_nf M 1 4 (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t)))) σ)
    (χ : NormalForm sig 0 1) (hp : nf_eval_nf M 0 1 (fun _ => x1) χ) :
    kvE2_sepBits σ kvE2_sep_zAtX1R χ = true
```
Verified: `axioms = [propext, Classical.choice, Quot.sound]`, no warnings. Exact mirror of the
left discharge (`kvE2_sepCoincidentAnchor_discharge`, :1346-1367), routing the same generic
zone-forward channel of `kvE_subBracket2_complete_extract` at `zAtX1R` with right-interior
bounds `w < x1 < t`.

### The `zAtX1R` bit reads referenced by the task
- The task's ":737" pointer is the `.coincident => kvE2_sepClosedLeafStub σ` line (the wiring
  target). The ":2475" region is the Phase-5 RIGHT three-way cut narrative
  (`kvE2_sepSegRForSub'`, :2485-2487) — context only; not a wiring target for the validity
  predicate.
- The right honest bundle `kvE2_sepHonestBundleR` (:1259-1301) already extracts a right-interior
  owner's anchor `x1 ∈ (w, t)` with the exact bound-derivation pattern the new
  `_valid_right` lemma will reuse (`hbit_wx1`/`hbit_x1t` → `hwx1`/`hx1t`, :1275-1286).

---

## (3) The current `hL` hypothesis and what generalizing requires

### `kvE2_sepBody_complete` (:1531-1546) — current form
```lean
theorem kvE2_sepBody_complete {sig} (qnf) (M) (w x t)
    (hxw : x < w) (hwt : w < t)
    (h : nf_eval_nf M 2 3 (Fin.cons w (Fin.cons x (fun _ => t))) qnf)
    (hL : ∀ σ ∈ kvE2_sepPos qnf, nf0_zoneSpec σ.1 = kvE2_sep_zXW3) :   -- LEFT-ONLY GATE
    kvE2_sepArr' qnf ≠ [] := by
  apply List.ne_nil_of_mem (a := kvE2_sepCoincidentOrder qnf)
  rw [kvE2_sepArr', List.mem_filter]
  refine ⟨kvE2_sepCoincidentOrder_mem_orderTypes qnf, ?_⟩
  rw [kvE2_sepDisjValid, kvE2_sepCoincidentOrder, List.all_eq_true]
  intro p hp; rw [List.mem_map] at hp
  obtain ⟨σ, hσmem, rfl⟩ := hp
  exact kvE2_sepCoincidentOwner_valid_left qnf M w x t hxw hwt h σ hσmem (hL σ hσmem)
```
Verified axiom-clean `[propext, Classical.choice, Quot.sound]`.

The **only** use of `hL` is the last line, feeding the left-interior zone guard to
`kvE2_sepCoincidentOwner_valid_left`. Everything else (membership of the coincidence order in
the enumeration, the filter unpacking) is placement-generic.

### `kvE2_sepCoincidentOwner_valid_left` (:1450-1481) — the per-owner left validator
Takes `hzone : nf0_zoneSpec σ.1 = kvE2_sep_zXW3`, extracts `hσ` and bounds `x < x1 < w`, gets
`hfresh : nf_eval_nf M 0 1 (fun _ => x1) (nf0_projFresh σ.1)`, then
`rw [kvE2_sepClosedLeafStub]; exact kvE2_sepCoincidentAnchor_discharge …`.

### What generalization requires
- **Relax `hL` to `hLR`**: `∀ σ ∈ kvE2_sepPos qnf, nf0_zoneSpec σ.1 = kvE2_sep_zXW3 ∨
  nf0_zoneSpec σ.1 = kvE2_sep_zWT3`. Then `cases (hLR σ hσmem)` dispatches to the left/right
  validator. (Dropping the guard entirely is out of scope — see §5.)
- **Add `kvE2_sepCoincidentOwner_valid_right`**: mirror of `_valid_left` with
  `hzone : … = kvE2_sep_zWT3`, right bounds `w < x1 < t` (derive as in `kvE2_sepHonestBundleR`
  :1275-1286), and `kvE2_sepCoincidentAnchor_discharge_R`.
- **Make the coincident bit placement-generic** (§4).

---

## (4) Concrete predicate-wiring strategy (axiom-clean, preserves `nonvacuous`)

### Recommended: guard `kvE2_sepClosedLeafStub` on the owner's zone class
```lean
def kvE2_sepClosedLeafStub {sig : MonadicSignature}
    (σ : NormalForm sig 1 4) : Bool :=
  if nf0_zoneSpec σ.1 = kvE2_sep_zXW3 then
    kvE2_sepBits σ kvE2_sep_zAtX1L (nf0_projFresh σ.1)   -- LEFT closed self-zone
  else
    kvE2_sepBits σ kvE2_sep_zAtX1R (nf0_projFresh σ.1)   -- RIGHT closed self-zone
```
This is the pattern already used pervasively (`kvE2_sepSlotsLFor` :294, `kvE2_sepSegLForSub`
:555, `kvE2_sepModelTag` :716, `kvE2_sepSegLForSub'` :2406) — an `if nf0_zoneSpec σ.1 =
kvE2_sep_zXW3` split with `kvE2_sep_zWT3_ne_zXW3` (:1746) to discharge the right branch. F5 is
preserved: both branches read CLOSED self-zone keys, never OPEN keys.

**Proof adjustments (minimal):**
- `_valid_left` (:1480): change `rw [kvE2_sepClosedLeafStub]` to also `rw [if_pos hzone]`
  (reduces the `if` to the left branch under `hzone : … = zXW3`), then the existing
  `kvE2_sepCoincidentAnchor_discharge` line closes it unchanged.
- `_valid_right` (new): after `rw [kvE2_sepClosedLeafStub]`, use
  `rw [if_neg (fun h => kvE2_sep_zWT3_ne_zXW3 (hzone.symm.trans h))]` (the exact idiom at
  :2513) to select the right branch, then `exact kvE2_sepCoincidentAnchor_discharge_R …`.

### Why `kvE2_sepBody_nonvacuous` is NOT broken
`kvE2_sepBody_nonvacuous` (:1382-1401) is parameterized by
`hvalid : kvE2_sepDisjValid qnf (kvE2_sepModelOrder qnf) = true` and routes through
`kvE2_sepArr'_mem_modelOrder` (:785). Two independent reasons it is immune:
1. It concerns the **`kvE2_sepModelOrder`** (strict `.strictBefore`/`.strictAfter` tags,
   :714-721), whose validity reads only the OPEN branches — **untouched** by this task.
2. `hvalid` is a **hypothesis**, and `kvE2_sepArr'_mem_modelOrder` only uses `List.mem_filter`
   membership; the proof is agnostic to the `.coincident` definition body.

`kvE2_sepArr'_sound` (:2536-2543) is likewise definition-agnostic (unpacks the filter via
`List.all_eq_true`), so it automatically upgrades to soundly carry the right closed bit at no
proof cost.

### Computability caveat (low risk)
Adding `if nf0_zoneSpec σ.1 = kvE2_sep_zXW3` may force `kvE2_sepClosedLeafStub` (currently a
plain `def`) to become `noncomputable`, which would ripple to `kvE2_sepDisjValidOwner` (:733)
and `kvE2_sepDisjValid` (:742). This is harmless: `kvE2_sepArr'` is already `noncomputable`, and
`kvE2_sepArr'_decidable` (:753) decides `… = true` on a `Bool` regardless of computability.
The implementer should add `noncomputable` if the build requests it. (Note the same `if` guard
already compiles in the sibling `noncomputable def`s, so decidability of the zone equality is
available.)

### Alternative considered (not recommended): `||` of both closed bits
`kvE2_sepBits σ zAtX1L … || kvE2_sepBits σ zAtX1R …` stays computable and closes both
validators trivially, but it lets an owner read the *other* side's closed bit. This risks the
soundness-direction faithfulness invariants (an owner accepted via a bit not appropriate to its
placement). The `if`-guard is the faithful choice and matches the established codebase pattern;
recommend it.

---

## (5) Is this "not new mathematics"? Hidden obligations

**Verdict: mostly yes, with one bounded new-proof obligation and one scope correction.**

- **The core mathematics is done.** The right coincidence discharge
  `kvE2_sepCoincidentAnchor_discharge_R` (:1493) is landed sorry-free and axiom-clean (verified).
  The §5 meet-type identification on the right side is fully proved. No new model reasoning.

- **New proof code IS required** (not zero): `kvE2_sepCoincidentOwner_valid_right` must be
  written. It is a mechanical mirror of `_valid_left` (:1450) reusing the bound-extraction
  already demonstrated in `kvE2_sepHonestBundleR` (:1259) and the landed discharge_R. Estimate
  ~25-35 lines. This is "not new mathematics" in the sense of no new lemma about the model, but
  it is genuine (non-trivial, sorry-free) Lean proof text — not a one-line rewire.

- **Scope correction (the one real subtlety)**: `hL` cannot be removed outright. `kvE2_sepPos`
  (:193-195) filters purely on `qnf.2 σ = true`; positive owners range over **seven** outer
  zone classes (`kvE2_sepOuterConsistent`, :631-633: `zPastX3`, `zAtX3`, `zXW3`, `zAtW3`,
  `zWT3`, `zAtT3`, `zFutT3`). Only `zXW3`/`zWT3` are interior with a fresh anchor and a
  coincidence discharge; the other five are exterior/boundary owners whose content rides an
  endpoint literal (comment :40-41), and they have **no** coincidence bit to discharge. There
  is **no proved dichotomy** that positive owners are always interior (grep-confirmed: no such
  lemma; `kvE2_sepModelTag` :716 uses a bare `else`, not a proof). Therefore the honest,
  axiom-clean generalization replaces `hL` (left-only) with `hLR` (left ∨ right interior). A
  fully unconditional `kvE2_sepBody_complete` (all seven classes) WOULD require new mathematics
  (coincidence handling for exterior owners) and is explicitly out of scope — the task asks to
  "generalize ... to right-interior owners", which `hLR` satisfies exactly.

- **No axiom risk.** All inputs are axiom-clean; the added lemma composes the landed discharge_R
  (clean) with pure order facts and `decide`, so the `[propext, Classical.choice, Quot.sound]`
  profile is preserved. No `sorryAx` is introduced. (Do NOT introduce any `sorry` or axiom to
  bridge the exterior-owner gap — if the implementer discovers positive owners are not provably
  interior in a needed context, mark [BLOCKED], do not defer with `sorry`.)

- **Faithfulness invariants**: F5 (closed vs open key discrimination) is preserved — both
  branches read closed keys. F2 (non-vacuity ⇐) is strengthened (now covers right-interior
  owners). F1/F6 untouched (segment/point content is elsewhere). The `if`-guard is essential to
  avoid the `||` soundness-faithfulness risk noted in §4.

---

## Recommended implementation outline (for the planner)

1. Rewrite `kvE2_sepClosedLeafStub` (:726) with the `if nf0_zoneSpec σ.1 = kvE2_sep_zXW3`
   guard (left → `zAtX1L`, else → `zAtX1R`). Add `noncomputable` if the build requires it, and
   propagate to `kvE2_sepDisjValidOwner`/`kvE2_sepDisjValid` if so.
2. Patch `kvE2_sepCoincidentOwner_valid_left` (:1480) with `rw [if_pos hzone]`.
3. Add `kvE2_sepCoincidentOwner_valid_right` (mirror of `_valid_left`, using discharge_R,
   the R-bundle bound pattern, and `if_neg`/`kvE2_sep_zWT3_ne_zXW3`).
4. Relax `kvE2_sepBody_complete`'s `hL` to `hLR` and add the per-owner `cases`.
5. `lake build` the module; `lean_verify` `kvE2_sepBody_complete`, `kvE2_sepBody_nonvacuous`,
   `kvE2_sepArr'_sound` — confirm all remain `[propext, Classical.choice, Quot.sound]`, no
   `sorryAx`.

## Verification log (grounded)

| Symbol | Location | Grounding |
|--------|----------|-----------|
| `kvE2_sepClosedLeafStub` | :726-728 | source read |
| `kvE2_sepDisjValidOwner` | :733-737 | source read |
| `kvE2_sep_zAtX1L` / `_zAtX1R` | :114 / :123 | source read |
| `kvE2_sepCoincidentAnchor_discharge_R` | :1493-1514 | `lean_verify` → axiom-clean |
| `kvE2_sepCoincidentOwner_valid_left` | :1450-1481 | source read |
| `kvE2_sepBody_complete` (`hL`) | :1531-1546 | `lean_verify` → axiom-clean |
| `kvE2_sepBody_nonvacuous` | :1382-1401 | `lean_verify` → axiom-clean |
| `kvE2_sepHonestBundleR` | :1259-1301 | source read (bound pattern) |
| `kvE2_sepPos` (7-class filter) | :193-195, :631-633 | source read |
| `kvE2_sep_zWT3_ne_zXW3` | :1746 | source read (idiom for `if_neg`) |
| `kvE2_sepArr'_sound` | :2536-2543 | source read (def-agnostic) |
| No dichotomy lemma | grep-confirmed | source search |
