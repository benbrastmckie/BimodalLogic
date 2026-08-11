# Phase 17 — Box-clause repair, decidability side

- **Plan**: `plans/03_omega-free-totality-refactor.md`, Phase 17
- **Status**: `[COMPLETED]`
- **Outcome**: the whole `FormalSystem` tree is **green** for the first time since the
  box-clause retarget

## What this phase did

Repaired every decidability-side proof whose reasoning still instantiated the box clause against
`σ ∈ Ω` rather than against `σ.IsTotal`, and every decidability-side call site still passing the
pre-delta binder list to a validity predicate. The target predicate throughout is TOTALITY
(`IsTotal τ := ∀ t, τ.domain t`), per `specs/paper-definitions-of-record.md`'s
`def:BL-semantics`. No compatibility shim, alias, or parallel validity notion was introduced, and
nothing from Phase 14 (the box-clause retarget) or Phase 18 (the validity binder delta and
`truthAt_carrier_irrelevant`) was reverted.

## The repair, by shape

### 1. `Decidable.lean` — the `SatState` field

The load-bearing change is one structure field:

```
histMem   : ∀ w, hist w ∈ Om        -- before
histTotal : ∀ w, (hist w).IsTotal   -- after
```

`SatState` is what every rule-soundness proof carries, and its `histMem` field was the sole
supplier of the box-instantiation witness. Retargeting the field dissolved most of the file's
break set at once: 13 of the 16 errors were downstream of it. Five lemma signatures moved with
it — `truthAt_allFuture_of_box`, `truthAt_allPast_of_box`, `forall_truthAt_time_invariant`,
`satAt_of_mem_boxProps`, `satAt_of_mem_diaProps` — each swapping `(hsc : ShiftClosed Om)` plus
`hτ : τ ∈ Om` for a single `hτ : τ.IsTotal`, with the shifted-witness obligation discharged by
`WorldHistory.isTotal_timeShift` instead of by shift-closure. `satAt_of_boxForm_time`'s `hsc`
became vestigial once `forall_truthAt_time_invariant` stopped consuming it and was dropped
(10 call sites, mechanical).

### 2. `Decidable.lean` — the three `.Discrete` sites (different lineage)

`prior_UZ_is_valid`, `prior_SZ_is_valid` and `z1_is_valid` (`SoundnessLemmas/FrameClassVariants`)
broke on an **arity** change, not on the box clause: `IsValid` is now
`∀ F M τ, τ.IsTotal → ∀ t, TruthAt M Set.univ τ t φ`, so the old `Om`/`ShiftClosed`/`τ ∈ Om`
triple no longer fits, and the conclusion lands at the inert carrier `Set.univ` while these proofs
evaluate against a universally quantified `Ω`.

Rather than transporting at each of the three sites, one 4-line helper does it once:

```lean
theorem truthAt_of_isValid {F : TaskFrame D} {M : TaskModel F} (Om : Set (WorldHistory F))
    {φ : Formula} (h : SoundnessLemmas.IsValid D φ)
    (τ : WorldHistory F) (hτ : τ.IsTotal) (t : D) : TruthAt M Om τ t φ :=
  (truthAt_carrier_irrelevant Set.univ Om φ τ t).mp (h F M τ hτ t)
```

This follows Phase 16's precedent (supply the inert `Set.univ` carrier; do not scatter
per-site transports) and disappears with `TruthAt`'s set parameter in Phase 22.

### 3. `Bridge/Interpolate.lean` — the global invariance quantifier

```
InterpInvariant f M Om χ := ∀ τ ∈ Om, ∀ r r', SameRegion f r r' → …    -- before
InterpInvariant f M Om χ := ∀ τ, τ.IsTotal → ∀ r r', SameRegion f r r' → …  -- after
```

The `box` case is the whole reason the global form exists — it needs the induction hypothesis at
every history the box clause ranges over — so the quantifier had to follow the clause. The section
`variable {Om}` **stays**: `Om` is still `TruthAt`'s carrier argument, it simply no longer indexes
what `box` quantifies over. Same arity, so all seven affected declarations
(`interpInvariant_atom`'s and `interpInvariant`'s `hRC`, plus the four private `untl`/`snce`
direction lemmas) needed only a binder-type swap, not a proof restructure.

### 4. `Bridge/Omega.lean` — the box-universal lemmas

`truthAt_box_iff` lost its `ShiftClosed Om` hypothesis and now reads
`TruthAt M Om τ x φ.box ↔ ∀ σ, σ.IsTotal → ∀ y, TruthAt M Om σ y φ`; `truthAt_box_congr` and
`truthAt_box_congr_history` followed. `truthAt_box_iff_base` keeps its statement verbatim and
bridges to `regionOmega` membership through the already-proved `regionOmega_eq_total`, which is
exactly the "reduce against `H_F`" the plan asked for.

### 5. `Bridge/TruthLemma.lean`, `IntTruth.lean`, `DenseTruth.lean`

`interpInvariantAt_of_interpInvariant` takes `hτ : τ.IsTotal`; `interpInvariantAt_box` and
`interpInvariantAt` drop `ShiftClosed Om` entirely — the box case now costs nothing, where it
used to be the one case shift-closure paid for. The four countermodel headline theorems in
`IntTruth`/`DenseTruth` are error-family A (binder delta): each supplies the totality witness
`fun _ => trivial` (`regionHistory`'s domain is `fun _ => True`) and transports the
`Set.univ` conclusion onto `regionOmega f`.

## Break-set accounting

| Source | Errors | Note |
|--------|--------|------|
| Dispatch's declared break set | 17 | `Decidable.lean` 16, `Interpolate.lean` 1 |
| Actually repaired | 23 | the 6 extra surfaced only after `Interpolate.lean` went green |

`Interpolate.lean` is an import ancestor of `TruthLemma.lean` → `IntTruth.lean` /
`DenseTruth.lean`. Those modules were never elaborated while it was red, so their breakage was
invisible to any pre-dispatch census. **An error count taken on a red tree is a lower bound, not
a measurement** — worth carrying into the remaining phases, which still sit behind edges this
phase has only just opened.

The plan's own estimate went the other way: it put `Decidable.lean` at 42 declarations in the
blast radius against a measured 16, and the structural repair was smaller still.

## Diagnostic note: the two tips pointed opposite ways, and both were partly right

The dispatch supplied Phase 15's tip (mechanical `intro`-arity sweep; all 14 expected judgment
sites dissolved as cascade artifacts) and Phase 16's counter-tip (same-arity box-clause change, so
every site was a genuine judgment site). The break set here had **mixed lineage** and neither tip
covered it alone:

- 13 of 16 `Decidable.lean` errors + all of `Interpolate.lean`/`Omega.lean`/`TruthLemma.lean` were
  Phase 16 lineage — same-arity membership→totality bridges, each a genuine (but small) judgment
  site.
- 3 of 16 `Decidable.lean` errors + all 4 `IntTruth`/`DenseTruth` errors were Phase 15/18 lineage —
  a real arity change in `IsValid`/`Valid*`, diagnosable from the error's
  `Set (WorldHistory F)`-vs-`WorldHistory F` shape rather than from any box reasoning.

Diagnosing per-error before choosing a strategy was the right call; a blanket sweep in either
style would have missed the other half.

## Verification

| Check | Result |
|-------|--------|
| `lake build` (default target `FormalSystem`) | **green** — first green tree since Phase 14 |
| Live sorries, repo-wide, excluding `Boneyard/` | **1** — `WeakCanonical/Transfer.lean:1084`, pre-existing, untouched |
| `declaration uses 'sorry'` warnings | 0 |
| New `axiom` declarations | 0 (no `axiom` declaration exists anywhere under `FormalSystem/` outside `Boneyard/`) |
| Vacuous definitions introduced | 0 |
| Decidability certificate statements | unchanged (proof terms only) |
| `lake build BimodalTest` | 10 `#guard_msgs` mismatches — the identical pre-existing set |

The single grep hit for the vacuous-definition pattern,
`FormalSystem/Examples/TemporalStructures.lean:284`
(`theorem int_domain_universal (t : Int) : intTimeHistory.domain t := trivial`), is a false
positive: it is a substantive statement about a specific history whose domain happens to be
`fun _ => True`, and it is pre-existing and untouched.

### On the ten `#guard_msgs` mismatches

Not re-baselined, for the sixth consecutive dispatch, and the count and per-file split are
**identical** to the recorded baseline: `TableauConformance.lean` 7, `RegionGateProbe.lean` 2,
`BoxSpreadProbe.lean` 1.

The dispatch flagged `RegionGateProbe.lean`'s two as sitting closest to this subtree and asked
that any movement be reported. They did not move, and the reason is structural rather than
observational: every declaration edited in this phase is `Prop`-valued or a proof term
(`SatState`, `InterpInvariant`, `truthAt_box_iff`, and the rule-soundness theorems), and no
`#eval`-reachable computable definition was touched. These probes evaluate the tableau engine,
which this phase does not reach.

## Files modified

- `FormalSystem/Metalogic/Decidability/Verified/Decidable.lean`
- `FormalSystem/Metalogic/Decidability/Verified/Bridge/Interpolate.lean`
- `FormalSystem/Metalogic/Decidability/Verified/Bridge/Omega.lean`
- `FormalSystem/Metalogic/Decidability/Verified/Bridge/TruthLemma.lean`
- `FormalSystem/Metalogic/Decidability/Verified/Bridge/IntTruth.lean`
- `FormalSystem/Metalogic/Decidability/Verified/Bridge/DenseTruth.lean`

`Bridge/RegionLabel.lean` was in the declared scope but needed no edit. Nothing outside the
declared scope was modified.

## Commits

| Commit | Contents |
|--------|----------|
| `86c1d617d` | phase 17.1 — `SatState.histTotal`, the five box helpers, the `.Discrete` transport |
| `92b492762` | phase 17.2 — `Interpolate`/`Omega`/`TruthLemma`/`IntTruth`/`DenseTruth` |
| `cd85c7f70` | phase 17.3 — docstring alignment across the six files |

## Carried forward

`ShiftClosed` is now consumed by **nothing** in the decidability subtree: `SatState.shiftClosed`
survives as a field, but every lemma that used to read it has been retargeted. That field, the
`ShiftClosed` definition itself, and `TruthAt`'s `Om` parameter (with
`truthAt_carrier_irrelevant` and `truthAt_of_isValid`) are Phases 21-22's deletions. Nothing in
this phase obstructs them; the two transports introduced here are deliberately centralised so
they vanish with the parameter rather than needing per-site unwinding.
