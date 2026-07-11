# Phase 1 Triage Record — fragment-predicate swap break surface

**Session**: sess_1783782450_230288
**Dispatch**: lean-implementation-hard-agent, Phase 1 only
**Swap applied**: `kvE2_sepPos qnf = [σ0]` → `kvE2_sepPosI qnf = [σ0]`, byte-identical, at BOTH sites:
- `OuterGate.lean:202` (`kvE2_sepFragment`)
- `SharedWitness.lean:10221` (`kvE2_sepFragment_frag`)

Both edits are below the SW:10210 341 GATE banner (OuterGate def is a mirror; SW def is at :10219).
`rfl` defeq bridge (OuterGate:223-224) preserved — bodies remain byte-identical.

## Build result: RED (expected for a triage phase) — 3 errors, all in the fold family

Build target: `lake build Bimodal.Metalogic.WeakCanonical.Kamp.NfMultiAnchorBridge.OuterGate`.
Only `SharedWitness` failed to compile; OuterGate was not reached. All 3 errors are BELOW the GATE
banner and confined to the two fold-family decls that DESTRUCTURE the fragment predicate.

### Error 1 & 2 — `kvE2_sepBody_kit_sound_frag` (SW:12487–12520), forward branch  [DIVERGENCE]

- SW:12515 `obtain ⟨σ0, hpos, hzone⟩ := hfrag` now yields `hpos : kvE2_sepPosI qnf = [σ0]`.
- SW:12517-12518 `kvE2_sepGateAtPin_fragL … σ0 hpos hzL hcorrK h` — **type mismatch**: fragL's
  signature demands `kvE2_sepPos qnf = [σ0]`, receives `kvE2_sepPosI qnf = [σ0]`.
- SW:12519-12520 `kvE2_sepGateAtPin_fragR … σ0 hpos hzR hcorrK h` — same mismatch for fragR.

**Divergence from plan**: Phase 1 verification criteria + the Preserved-Assets table (row
`kvE2_sepBody_kit_sound_frag`) predicted kit_sound would NOT error ("pass-through of hfrag …
no direct kvE2_sepPos destructure"). It DOES error. Root cause: kit_sound's forward branch
destructures the fragment predicate and passes the resulting `hpos` to the gate PRODUCERS
`kvE2_sepGateAtPin_fragL`/`_fragR`, whose signatures still require the GLOBAL `kvE2_sepPos qnf = [σ0]`
list equality. The producers themselves (`fragL` SW:10526, `fragR` SW:11553) compile GREEN and are
unchanged — only kit_sound's CONSUMPTION of them via the swapped predicate breaks.

**Non-trivial fix note**: `kvE2_sepPosI_subset` (SW:224) bridges *membership* (`σ ∈ kvE2_sepPosI →
σ ∈ kvE2_sepPos`) but NOT the *list-equality* `kvE2_sepPosI qnf = [σ0] ⇒ kvE2_sepPos qnf = [σ0]`,
which is FALSE under the swap (the global list additionally carries the boundary positives). So
fragL/fragR cannot be fed directly; the kit_sound forward branch needs the Phase-3/4 interior/boundary
machinery, not a one-line subset bridge. **This expands the repair surface: Phase 4 (or a new Phase
3.5) must repair kit_sound's two fragL/fragR call sites in addition to the fold backward branch.**

### Error 3 — `kvE2_outer_fold_frag` (SW:12529+), backward branch (SW:12616–12632)  [as predicted]

- SW:12617-12619 builds `hmem : σ ∈ kvE2_sepPos qnf` from `hbit : qnf.2 σ = true`.
- SW:12626 `obtain ⟨σ0, hpos, hzone⟩ := hfrag` → `hpos : kvE2_sepPosI qnf = [σ0]`.
- SW:12627 `rw [hpos] at hmem` — **rewrite failed**: pattern `kvE2_sepPosI qnf` not found in
  `σ ∈ kvE2_sepPos qnf`. This is exactly the "non-interior `exfalso` losing its contradiction" the
  plan predicted for Phase 4. Semantic root: a non-interior positive `σ` (`hzL`/`hzR` both false) is
  no longer contradictory — `kvE2_sepPosI qnf = [σ0]` no longer forces `σ = σ0` because such `σ ∉
  kvE2_sepPosI`. This is the un-vacuated boundary case Phase 4 realizes via the endpoint/witness
  literals (`kvE2_sepEpL`/`kvE2_sepEpR`/`kvE2_sepPtW`) under the Phase-3 boundary-restricted `hexcl`.

## Survival audit verdict: REFINED, not refuted

- **Preserved-asset PRODUCERS survive (GREEN)**: `kvE2_sepGateAtPin_fragL` (SW:10526),
  `kvE2_sepGateAtPin_fragR` (SW:11553) declarations, symmetric gate clause (v), completeness half
  (OuterGate:139), provider bridge (OuterGate:115). No error above the GATE banner. RE-SCOPE verdict
  intact.
- **Additional break beyond the audit**: `kvE2_sepBody_kit_sound_frag` (a fold-family CONSUMER, not
  an independent producer) also breaks. This is an EXPANSION of the Phase 4 repair scope, not a
  refutation of the interior-singleton approach.

## Actionable handoff for Phase 3 / Phase 4

Repair surface (3 sites), all in `SharedWitness.lean`, all below the GATE banner:
1. `kvE2_sepBody_kit_sound_frag` fwd: SW:12517-12518 (fragL call) + SW:12519-12520 (fragR call).
2. `kvE2_outer_fold_frag` backward: SW:12626-12632 (`exfalso` block, `rw [hpos]` at :12627).

Both require bridging `kvE2_sepPosI qnf = [σ0]` to the global-positive consumers — the substantive
interior-vs-boundary case split (Phases 3+4). No preserved producer needs editing.
