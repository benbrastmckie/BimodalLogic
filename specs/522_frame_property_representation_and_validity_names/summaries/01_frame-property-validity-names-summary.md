# Implementation Summary: Frame property representation and validity names

- **Task**: 522 - Frame property representation and validity names
- **Plan**: `specs/522_frame_property_representation_and_validity_names/plans/01_frame-property-validity-names.md`
- **Type**: lean4
- **Status**: all 11 phases complete; `lake build` and `lake build BimodalTest` green;
  `scripts/check-module-invariants.sh` reports ALL CHECKS PASSED

## What landed

The representation fix is two lines: `TaskFrame.IsDense` became an `abbrev` and `FrameClass.Sat`
gained `@[reducible]`, so a `Sat fc F` hypothesis now registers itself in Lean's local instance
cache on `intro`. Everything else in the task followed from that: a `sat_intro` macro, ~21
class-adapter call sites migrated onto generic adapters, the deletion of the tag-specific adapter
families, two BL transfer theorems, and two rename passes.

### Phase 1 — Plan A or Plan B

**Plan A is in force.** The full guarded detached build with both `abbrev TaskFrame.IsDense` and
`@[reducible] FrameClass.Sat` applied exited 0 with no errors, so decision D1 resolves to Plan A
and Phase 2's `sat_intro` uses the Plan A variant (no `haveI : DenselyOrdered _` branch). Plan B
was never exercised.

### Measured adapter counts (pre / post)

| File | Pre | Post |
|---|---|---|
| `Semantics/Validity.lean` | 21 | 13 |
| `Semantics/BLValidity.lean` | 12 | 6 |
| `Metalogic/StrongCompleteness.lean` | 6 | 0 |
| `Metalogic/SetConsequence.lean` | 8 | 3 |
| **Total** | **47** | **22** |

`SatisfiableSet.*_of_forall` went **4 -> 1** exactly as planned. The headline figure is therefore
**47 -> 21 (+ SatisfiableSet 4 -> 1)**, not the plan's 47 -> 12. The 9-adapter gap is fully
itemised in the Phase 7 completion note: 7 of them are the `.Base`-fixed convenience wrappers
(`valid.{of_forall_total, apply, of_not}`, `SemanticConsequence.{of_forall, apply}`,
`BLValid.{of_forall_total, apply}`) that Phase 4 explicitly instructs not to migrate away from —
they discharge `Sat .Base = True` rather than working around the instance cache — and 2 are the
new generic `SemanticConsequenceIn` pair the plan's survivor arithmetic omitted. **The plan's own
machine-checkable acceptance grep passes as written**: zero surviving adapters mention a literal
`.Dense` / `.Discrete` / `.Dedekind` tag.

### Measured rename counts

| Sub-step | Occurrences | Files |
|---|---|---|
| `ValidDedekind -> ValidComplete` | 44 | 8 |
| `ValidDedekindDense -> ValidDedekind` | 98 | 21 |
| BL layer (`BLValidDedekindDense -> BLValidDedekind`, prose `BLValidDedekind -> BLValidComplete`) | 20 | 4 |
| D3 consequence family | 28 | 4 |
| Axiom-validity normalisation (`swap_axiom_*`, `*_is_valid`, `axiom_*_valid`) | 35 | 3 |
| `valid -> Valid` (code) | 77 | 9 |
| `valid -> Valid` (backticked docstring references) | 72 | 18 |

**Hazard 1 invariant holds**: 84 declared identifiers contain `Dedekind`; the non-`Valid*` count
is 73 before and 73 after, and the set differs only in decision D3's three sanctioned
consequence-family names. The `HasDedekind*` / `HasFaithfulDedekind*` / `HasGuardedDedekind*` /
`HasDenseDedekind*` canonical-model layer is byte-unchanged, as is every tag-named declaration.

## Scope Hypotheses that came back different from the plan-time figure

1. **`FrameClass.Sat` reference count**: 58, not 77. The load-bearing half held — no
   `simp [FrameClass.Sat]` or `unfold FrameClass.Sat` site exists — so the `@[reducible]` risk
   profile was as assumed.
2. **Phase 6 call sites**: 21 real call sites, not the asserted ~34. The plan-time grep did not
   separate declaration lines and prose mentions from actual uses; `SetConsequence.lean`,
   `Compactness.lean`, `Decidable.lean` and `BXCanonical/CompletenessDedekind.lean` turned out to
   hold **zero** call sites between them.
3. **`CoValidity.lean`**: 1 class-adapter call site, not 2.
4. **The six `intro F hF M tau h_mem t` ASCII chains** are all in `Metalogic/Soundness.lean`, not
   under `SoundnessLemmas/` where the plan assigns them.
5. **Seven `.apply` dot-notation call sites were invisible to a name-based grep** and were found
   only by Phase 7's full build — two of them in files no phase's file list names
   (`Decidability/BiLasso/Assembly.lean`, `Decidability/Verified/Bridge/DenseTruth.lean`).
6. **`valid -> Valid`**: the plan's exclusion list (`Automation/**` only) is materially
   incomplete. A comment-stripped scan found 169 code-only occurrences of the bare identifier, of
   which only 77 are the semantic predicate; the rest are
   `DecisionProcedure.DecisionResult.valid` (a constructor used throughout
   `Metalogic/Decidability/**`), `MergePair.valid` (`WeakCanonical/Kamp/**`), a `valid : Bool`
   test field, and two `have valid :` / `let valid :` local binders. The pass was run against an
   explicit nine-file allowlist plus one line-level exclusion. `FormalSystem/Automation/**` is
   byte-unchanged.
7. **`BLValidDedekind` already existed — in prose**, naming a hypothetical density-free predicate
   that is deliberately never defined. Renaming `BLValidDedekindDense -> BLValidDedekind` would
   have inverted eight prose occurrences; the prose name was moved to `BLValidComplete` first.
8. **Two docstrings had become factually wrong** after Phase 1 and were corrected:
   `SetConsequence.lean`'s and `DedekindNonCompactness.lean`'s claims that a destructured
   `hd : F.IsDense` is invisible to instance search and needs a `haveI`.
9. **The plan's build invocation does not build.** `lake-build-guard.sh build --timeout 1800 --
   lake build` exits 77 (usage error) without building: build mode requires a recognised *lake
   subcommand* as the first wrapped argument, not the `lake` binary. Every build in this task used
   `-- build`.

## Plan Deviations

- **Phase 1** *(altered)*: build invocation corrected to `-- build` (item 9 above).
- **Phase 2** *(altered)*: the four `example`s were placed at the end of
  `Semantics/DurationClassification.lean` under their own heading rather than "beside
  `noMaxOrder_of_duration`'s pointer" — that theorem lives in
  `Semantics/Correspondence/DurationFrames.lean` and `DurationClassification.lean` carries no
  pointer to it.
- **Phase 5** *(deferred to Phase 4)*: the six ASCII `tau`/`h_mem` chains, per item 4 above.
- **Phase 7** *(exclusions)*: the seven `.Base`-fixed adapters retained; acceptance number
  restated with the measured figure. Full record in the phase's `#### Reasoned Exclusions` table.
- **Phase 8** *(exclusions)*: five `BLValidity.lean` lemmas were not rewritten as corollaries of
  the transfer theorems — `Semantics/BLValidity.lean` is *imported by*
  `Metalogic/BaseLanguageSoundness.lean`, so a downstream theorem cannot be an upstream one's
  proof, and all five are already one-line corollaries of `BLValidIn.mono`. For the same layering
  reason `dn_valid_of_denselyOrdered` was not derived by transporting `density_valid`; the reason
  is now recorded on the theorem. The three documented exceptions
  (`blValid_iff_empty_consequence`, the `BLValidDiscreteSucc` layer, `df_valid_of_succOrder` /
  `df_valid_of_isLeast_pos`) are each annotated in source.
- **Phase 9** *(altered)*: sub-step 9.1 got its own full build and commit (the ordering constraint
  the plan calls load-bearing); 9.2, 9.3 and 9.4 rename disjoint identifier sets with no ordering
  constraint among them and share one full build, each still its own commit. Four `README.md`
  files under `FormalSystem/` and three under `docs/` also carried the renamed identifiers and
  were updated.
- **Phase 10** *(exclusions)*: the verification bullet forbidding same-named theorems across
  `Metalogic` / `Metalogic.SoundnessLemmas` conflicts with decision D4 in the same plan, which
  prescribes exactly that pair for the four `axiom_*` renames and mitigates it with a docstring.
  D4 (binding Decisions table) was followed. `valid -> Valid` allowlist per item 6 above.

## Verification

- `lake build` — green (guarded, detached).
- `lake build BimodalTest` — green (guarded, detached).
- `scripts/check-module-invariants.sh` — **ALL CHECKS PASSED**, including C1, C2 (all four
  flagship axiom sets match baseline) and both C14 halves. None of the eight pinned names
  (`BXCanonical.{completeness, completeness_dense, completeness_discrete}`,
  `Chronicle.countermodel_dense`, `Decidability.sound_of_isValid`, `completeness_dedekind`,
  `strongCompletenessBase`, `strongCompletenessDense`) is renamed by this task; the set was
  re-derived from `scripts/check-module-invariants.sh` rather than from the plan's list.
- Executable `sorry` count **unchanged at 160, every one of them under `FormalSystem/Boneyard/`**;
  zero outside Boneyard, before and after.
- **Zero `axiom` declarations** in the tree before and after (the eight `grep '^axiom '` hits are
  line-wrapped docstring prose, not declarations).
- `lean_verify` on a representative renamed/added theorem in each touched namespace:
  `Validity.validComplete_iff_validOnFrames_isComplete` `[propext]`;
  `SoundnessLemmas.prior_UZ_valid`, `Semantics.blValidIn_iff_validIn_tr`
  `[propext, Classical.choice, Quot.sound]`; `Metalogic.SatisfiableSet.of_forall` `[propext]`.
  No `sorryAx`.
- Acceptance greps, all three empty:
  - Phase 7: `grep -rEn '\.(of_forall|apply|of_not)\b' FormalSystem/ | grep -E 'Valid(Dense|Discrete|Dedekind)|SemanticConsequence(Dense|Discrete|Dedekind)|SetSemanticConsequence(Base|Dense|Discrete|Dedekind)'`
  - Phase 9: `grep -rn 'ValidDedekindDense\|validDedekindDense\|BLValidDedekindDense' FormalSystem/ Tests/`
  - Phase 10: `grep -rn 'swap_axiom_\|_is_valid\b' FormalSystem/`
- Exactly **one** site in `FormalSystem/` warns that a `Valid*` name is not its apparent `ValidIn`
  tag, and it is on `ValidComplete` (`Semantics/Validity.lean:655`).
- The two naming-deviation-of-record blocks survive (`FrameProperty.lean`'s module-docstring
  section and the block on `TaskFrame.IsDedekind`), with the canonical caveat stating explicitly
  that the rename removed the `ValidDedekind ≠ ValidIn .Dedekind` trap and *not* the
  paper-versus-tree deviation.
- `git diff --stat FormalSystem/Automation/` is empty.
- No `14 axiom` / `21 axiom` / `42 axiom` / `44 axiom` literal introduced.

## Files modified

48 files: 41 Lean sources under `FormalSystem/`, 2 under `Tests/`, 4 `README.md` files under
`FormalSystem/`, 3 under `docs/`, plus the plan. `specs/ROADMAP.md` is untouched, as the plan
requires.
