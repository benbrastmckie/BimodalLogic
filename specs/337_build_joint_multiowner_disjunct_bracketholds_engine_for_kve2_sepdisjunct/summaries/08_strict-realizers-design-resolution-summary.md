# Task 337 — Cycle 8 Summary: Strict Realizers + Decisive Design Resolution

**Status**: partial (Phase 1 still in progress; terminal deliverables not delivered).
**Build**: `Bimodal.Metalogic.WeakCanonical.Kamp.NfMultiAnchorBridge.SharedWitness` GREEN throughout; never RED.
**Axioms**: new lemmas `{propext, Classical.choice, Quot.sound}` (verified).

## What landed (green, axiom-clean, committed)

1. **`kvE2_sepHonestBaseRealizerL`** (SW, Phase-1 region-`hreal` block): every base 1-type of a
   LEFT-interior positive owner σ (`zXU`∪`zUW`) has a strict-interior realizer in the WHOLE `(x, w)`,
   from `kvE2_sepHonestAnchorBundleL` closed monotonically through `a_σ < w` / `x < a_σ`.
2. **`kvE2_sepHonestBaseRealizerR`** (mirror): base 1-types of RIGHT owners (`zWX1`∪`zWT`) get a
   strict realizer in `(w, t)` from bundle R.
3. **Packaging decision banked as a docstring** pointing to the existing `kvE2_sepS_nodup` (:372):
   per-region `hnd` uses the per-owner-per-zone set (a `filter` of the `Nodup` universe list),
   NOT a flat `dedup` (which would under-count per-slot points).

## Design questions — DECISIVELY RESOLVED (grounded in code, not abstraction)

**hreal collision (resolution b, committed):** The base slot value `kvE2_sepSlotValue (.lXU σ χ)`
is `Classical.epsilon` in `(x, a_σ)` (SW:2714) and CAN equal a foreign anchor `a_τ` (τ≠σ). So
resolution (a) — base-value ≠ anchor-value — is FALSE in general and abandoned. Strictness for each
χ is supplied OWNER-RELATIVELY by the honest bundles (strict inside `(x,a_σ)`/`(a_σ,w)` by
construction), landed as the two realizer lemmas above.

**Secondary (type-list vs slot-list `Nodup`) — RESOLVED:** the engine `k1v_sorted_realizationK`
(SubBracket2V.lean:633) requires per-region `hnd` on `List (NormalForm 0 1)` (TYPES). Two distinct
slots of different owners can carry the same base type, so the flat joint type list is NOT `Nodup`,
and `dedup` is WRONG (the eventual bracket, per `kvE2_sepDisjunct_extract` SW:3773, needs one
strictly-ordered point PER SLOT). Grounded in the single-owner sound path
(`k1v_bracket_construct3` fed per-owner `hndXU/hndUW/hndWT`, SubBracket2V.lean:1982), the correct
packaging is PER-OWNER-PER-ZONE regions whose type list is `kvE2_sepS σ zs` — already `Nodup`.

## The precise remaining delta for `kvE2_sepHonest_engineInputs` (next dispatch)

The prior plan's value-based gap partition ("hreal holds by partition definition") was optimistic:
it ignored the base-value=anchor-value collision. The genuine remaining work is:
1. the cross-owner value→gap partition of base types into the sorted-anchor fine gaps, PLUS
2. **collision folding** — the "meet-type folding for a foreign base witness forced onto an anchor"
   already flagged in task 340's docstring (SW:~3496, report 06 R3): when a base value coincides
   with an anchor, fold its type into that anchor's point-type instead of placing a separate strict
   gap point.

`hpos`/`hlink` from strict anchor sortedness (`kvE2_sepHonest_rank_strictMono` +
`kvE2_sepAnchorFam_injective`, banked); `hnd` per gap after folding (`kvE2_sepS_nodup`); `hreal`
from value-sortedness upgraded to strict via anchor injectivity + the cycle-8 realizer lemmas.
Sized ~200-350 lines with folding — its own dispatch.

## Preserved
halign trio, value-sortedness lemmas, anchor boundary/distinctness, merged-list Nodup,
`kvE2_sepCoincidentOrder_mem_arr'`, all 334/336/338/339/340 declarations — untouched (all edits
additive, inserted after `kvE2_sepSlotsROf_nodup`).
