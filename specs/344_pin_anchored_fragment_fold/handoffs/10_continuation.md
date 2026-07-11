# Task 344 — Continuation Handoff (dispatch 10 → dispatch 11)

- **Session**: sess_1783723095_edd5a7_344
- **Status at handoff**: **Phase 1 [COMPLETED]**, **Phase 2 [BLOCKED]** — design probe returned
  **NO-GO** for the internal derivation of `kvE2_sepGateAtPin_fragR`'s `h_bwd`. **No code written this
  dispatch** (the blocker was found at goal-level before any lemma, exactly per the dispatch's
  "probe first; if no additive source, commit nothing broken, BLOCK, STOP" instruction). HEAD is
  unchanged (`8ef24bc51`, green). 344-section sorry count = 0 (unchanged).

## Probe verdict: fragR `h_bwd` is NOT internally derivable (the design gap is REAL)

fragL's `h_bwd` (`SW:11072-11291`) classifies the abstract zone `zs` via **gate clause (iv)**:
```
have hcons : kvE2_sepInnerConsistentL zs := by
  by_contra hncons
  rw [hg.2.2.2 σ hσ0true hz zs χ hncons] at hbit   -- SW:11084-11087
  exact absurd hbit (by decide)
```
`hg.2.2.2` is `kvE2_sepGate` clause (iv) (`SW:1244-1246`):
```
(∀ σ, qnf.2 σ = true → nf0_zoneSpec σ.1 = kvE2_sep_zXW3 →
   ∀ zs χ, ¬ kvE2_sepInnerConsistentL zs → σ.2 (nf0_assemble zs χ σ.1) = false)
```
It is **structurally `= kvE2_sep_zXW3`-gated**. For fragR the sole positive `σ0` has
`nf0_zoneSpec σ0.1 = kvE2_sep_zWT3` (`hz : … = kvE2_sep_zWT3`), and `zWT3 ≠ zXW3` is landed
(`kvE2_sep_zWT3_ne_zXW3`, `SW:1482`). So clause (iv) is **vacuous** for `σ0` — it yields no
inner-zone exclusion.

**Exhaustive gate audit (all four `kvE2_sepGate` conjuncts, `SW:1238-1246`):**
- (i) outer off-fiber (`nf0_dropFresh σ.1 ≠ qnf.1 → qnf.2 σ = false`) — about `σ`'s outer skeleton, not `σ0`'s inner bits.
- (ii) outer seven-zone consistency (`¬ kvE2_sepOuterConsistent (nf0_zoneSpec σ.1) → qnf.2 σ = false`) — `zWT3` IS outer-consistent (`SW:1214`), so nothing.
- (iii) inner off-fiber (`qnf.2 σ = true → ∀ τ, nf0_dropFresh τ ≠ σ.1 → σ.2 τ = false`) — **VACUOUS for every assemble**: `nf0_dropFresh_assemble : nf0_dropFresh (nf0_assemble zs χ r) = r` holds **UNCONDITIONALLY** (`NfEFold.lean:219-221`; no consistency hypothesis on `zs`, verified by reading the full proof). So `nf0_dropFresh (nf0_assemble zs χ σ0.1) = σ0.1` for ALL `zs`, and the clause-(iii) antecedent `≠ σ0.1` is never met.
- (iv) inner nine-zone — zXW3-only, as above.

**Conclusion**: `hg` places **ZERO** constraint on `σ0.2 (nf0_assemble zs χ σ0.1)` for inconsistent
`zs` when `σ0` is a zWT3 owner. A gate-legal + hfrag-legal + hcorrK-legal `qnf` can mark an
inconsistent-inner-zone bit true; no witness exists for an inconsistent zone
(`kvE2_sep_zone4_consistent` contrapositive, `SW:6558` — realized ⟹ consistent). Therefore `h_bwd`
(as required by `kvE2_sepBundleR_sound_frag`, `SW:10143-10147`: `∀ zs ≠ zWX1, bit true → ∃ witness`)
is **false in a rich model for the RIGHT owner** and cannot be proved internally. This is not a
"couldn't find the tactic" — it is a missing hypothesis in the gate contract.

**Confirmed absent** (grep over `Theories/`): no `kvE2_sepInnerConsistentR`, no zWT3-gated inner-nine
clause, no stronger gate anywhere. `kvE2_sep_zone4_consistent` only gives the h_fwd direction.

**Where the 335 adjudication missed this**: reports/04 (§"recommended path", family-discharge bullet)
and reports/05 (§2 table, "backward" row) both list `kvE2_sepHgate_innerNine` (`SW:6679-6685`, the
zXW3-only clause-(iv) wrapper) as the derivable core for **both** `hgateL` and `hgateR`, without
noticing `innerNine` has no zWT3 instance. fragL landed fine (clause iv exists); fragR surfaces the gap.

## Recommended resolution: R2 (additive; matches the original threaded `hgateR`)

Give `kvE2_sepGateAtPin_fragR` an extra hypothesis — the zWT3 analog of clause (iv):
```
(hInnerR : ∀ (zs : ZoneSpec 4) (χ : NormalForm sig 0 1),
    ¬ kvE2_sepInnerConsistentR zs → σ0.2 (nf0_assemble zs χ σ0.1) = false)
```
Thread it through `kvE2_sepBody_kit_sound_frag` (Phase 2) and `kvE2_outer_fold_frag` (Phase 3); 335
discharges it. **Additive-only**: all three are NEW decls below the 344 banner — zero existing decls
modified, invariant intact. 335 already discharges the FULL right `h_bwd` inside the landed
`kvE2_sepBundleR_sound`/`hgateR` (`SW:9835-9839`), so the discharge machinery provably exists.

Under R2, fragR mirrors fragL exactly:
1. Build `kvE2_sepInnerConsistentR` — the 9 RIGHT-geometry zones for env `[x1,w,x,t]` with `x<w<x1<t`
   (mirror `kvE2_sepInnerConsistentL`, `SW:1220-1229`; the interior below-zone is `zWX1` = `w<v<x1`,
   not `zXU`). Also build a `kvE2_sep_zone4_consistentR` (realized→InnerConsistentR) mirroring `SW:6558`.
2. Missing right-geometry infra still needed (from handoff 09): `kvE2_sepPtX1R_owner_lit`,
   `kvE2_sep_rX1T_mem_slotsRFor`, right owner-lit extractors (`kvE2_sepEpL/EpR/PtW_owner_lits` take
   `hσ : σ ∈ kvE2_sepPosIn qnf zXW3`; the RIGHT owner needs the `Or.inr` variants — the EpL/EpR/PtW
   conjLists already range over `zXW3 ++ zWT3`, `SW:10289`, so this is a one-line change per extractor).
3. fragR `h_bwd`: replace `hg.2.2.2 …` with `hInnerR zs χ hncons`; rcases `kvE2_sepInnerConsistentR`
   into its 9 zones; endpoint/at-point zones via the `Or.inr` owner-lits; interior zones (`zWX1`/`rX1`/
   `x1<v<t`) via the RIGHT slot machinery (`rWX1`/`rX1`/`rX1T` in `kvE2_sepSlotsRFor` under `if_pos zWT3`,
   `SW:345-349`).

**R1 (NOT recommended)**: add clause (v) to `kvE2_sepGate` for zWT3 inner-nine — modifies the LANDED
gate def (violates the 344 invariant) and forces every gate consumer + fragL + 335 to satisfy it. Large
blast radius. Prefer R2.

## What dispatch 11 needs from the orchestrator

A decision: **R2** (thread `hInnerR`; recommended) or **R1** (extend the gate). This is a
signature/contract change to the four 344 target lemmas AND the 335 handback contract, so it needs an
orchestrator call — not implementer improvisation. On R2 GO, dispatch 11 executes steps 1-3 above
(fragR is then a true fragL mirror), then pastes Phases 2-3 (drafts in handoff 09), then the 335
handback (now also verifying that 335 can discharge `hInnerR`).

## Guards (unchanged, HARD)
Additive-only below `SW:10047` banner; zero existing decls modified; SharedWitness.lean only; NEVER the
∀-anchor; `hcorrK`/`hexcl` undischarged; per green milestone `lake build …SharedWitness` +
`#print axioms == {propext, Classical.choice, Quot.sound}` + commit. COMPLETION BAR: zero sorries in the
TASK 344 section + all four target lemmas axiom-clean.

## Note
`gate-producer-wip.lean` does not exist in the tree (nothing to delete on completion).
