# Research: Eliminating the 21 `Overlapping instance parameters` / `[Nontrivial D]` warnings

**Task type**: lean4
**Session**: sess_1788262971_5329aa
**Status**: researched

---

## Executive summary

All 21 warnings are one linter class (`linter.overlappingInstances`), and the fix is a pure
deletion of a duplicated `[Nontrivial D]` binder at every site. The task brief's split into a
"mechanical" Class A and a "needs judgment" Class B is *directionally* right — there really are
two structural shapes — but its diagnosis of the second shape is factually wrong, and correcting
it collapses the hard part of the task.

Three findings drive everything below:

1. **There is no shadowing in `TruthLemma.lean`.** The brief states that the outer
   `variable {D : Type} … [Nontrivial D]` at `:74` shadows into `section Countermodel` at `:343`.
   It does not: `:74` sits inside `section Invariance`, which is closed by `end Invariance` at
   `:335`, eight lines *before* `section Countermodel` opens. The outer `D` is out of scope. The
   duplication is entirely local to `section Countermodel`, between its own `:346` and `:351`.
   The compiler corroborates this: the diagnostic says "There are **2** `[Nontrivial D]`
   instances", not 3, and no `AddCommGroup`/`LinearOrder` overlap is reported at all — both of
   which would follow if `:74` leaked.

2. **`Decidable.lean:2761 truthAt_sep` is Class A**, as the brief suspected. Its
   `[Nontrivial D]` is on continuation line `:2762` next to `[DenselyOrdered D]`, under the
   single file-wide `variable` at `:136`. Delete the token, keep `[DenselyOrdered D]`.

3. **The real Class B count is therefore 3, not 4**, and the "which block owns the instance"
   question has a decisive, evidence-backed answer (Section 4), not a judgment call resolved by
   taste.

The complete fix was **built and verified end-to-end during this research**, then reverted. It
produces a green tree with zero regressions. Measured numbers are in Section 6.

---

## 1. Authoritative site list (from the compiler, not from grep)

Obtained per the brief's instruction via `lake env lean <file>` on each of the three files. The
tree-wide count was independently confirmed against a forced full build (`--no-share`), which
found the warnings in exactly these three files and nowhere else.

| File | Sites | Section binder |
|---|---|---|
| `FormalSystem/Metalogic/Algebraic/FlowFrame.lean` | 13 | `:449` (`section BundleFlow`) |
| `FormalSystem/Metalogic/Decidability/Verified/Decidable.lean` | 5 | `:136` (file-wide, no sections) |
| `FormalSystem/Metalogic/Decidability/Verified/Bridge/TruthLemma.lean` | 3 | `:346` + `:351` (`section Countermodel`) |
| **Total** | **21** | |

Every one of the 21 carries the identical body text:

```
⚠️ There are 2 `[Nontrivial D]` instances; one is sufficient.
```

### Class A — 18 sites (delete the explicit binder)

`FlowFrame.lean`, all under the `:449` binder
`variable {D : Type} [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D] [Nontrivial D]`:

| Line | Declaration | Kind |
|---|---|---|
| 466 | `bundleFlowFrame` | `noncomputable def` |
| 472 | `bundleFlowHistory` | `noncomputable def` |
| 479 | `bundleFlowModel` | `noncomputable def` |
| 483 | `bundleFlowHistory_total` | theorem |
| 491 | `bundleFlow_pos_shift` | theorem |
| 498 | `bundleFlow_comp_iff` | theorem |
| 506 | `bundleFlow_serial` | theorem |
| 514 | `bundleFlow_limit` | theorem |
| 521 | `bundleFlow_spherical` | theorem |
| 533 | `bundleFlow_total_eq` | theorem |
| 549 | `bundleFlow_total_eq_range` | theorem |
| 678 | `bundleFlow_truth_lemma` | theorem |
| 803 | `bundleFlow_completeness_from_neg_membership` | theorem |

`Decidable.lean`, all under the `:136` binder (same bundle shape):

| Line | Declaration | Note |
|---|---|---|
| 2144 | `exists_gt_self` | binder on the declaration line |
| 2149 | `exists_lt_self` | binder on the declaration line |
| 2162 | `exists_gt_not_untl_disj` | binder on the declaration line |
| 2172 | `exists_lt_not_snce_disj` | binder on the declaration line |
| 2761 | `truthAt_sep` | **binder on continuation line `:2762`**, as `[DenselyOrdered D] [Nontrivial D]` |

Edit for all 18: remove the single substring `` [Nontrivial D]`` (with its one leading space)
from the binder list. Nothing else on the line changes. For `:2762` this leaves
`    [DenselyOrdered D]`.

### Class B — 3 sites (delete one of two `variable` lines)

`TruthLemma.lean` `:364 RegionValued`, `:374 atomRegionInvariant_regionHistory`,
`:389 interpInvariantAt_regionHistory`. All three inherit the duplicate from the section header;
none of the three declaration lines is itself edited. See Section 4.

---

## 2. Why the warnings exist: a single upstream commit

`git blame` plus commit archaeology gives an unambiguous origin. Commit `ddfcb59c35`
("`[Nontrivial D]` as a TaskFrame structure binder", 2026-08-12 20:57) made `structure TaskFrame`
and `structure FiniteTaskFrame` carry `[Nontrivial D]`, and threaded the instance into the
standard duration-group `variable` bundle across 33 files. Its own message states the decisive
fact:

> "The instance is threaded through the 33 files whose declarations mention `TaskFrame D` at
> polymorphic `D` — variable lines and per-declaration binder lists alike. […] **Nothing was
> removed anywhere.**"

That is precisely the defect: the sweep *added* `[Nontrivial D]` to the enclosing `variable`
lines without removing the pre-existing per-declaration binders it thereby made redundant. In
`FlowFrame.lean` the sweep's entire diff is two lines — `:131` and `:449` each gained
`[Nontrivial D]` — and those two lines are what turned 13 already-present explicit binders into
duplicates. Same story at `Decidable.lean:136` and `TruthLemma.lean:74`/`:345-346`.

The same commit also records the author's own criterion for when such a binder is *not*
redundant:

> "`valid` and `SemanticConsequence` (`Semantics/Validity.lean`) already carried `[Nontrivial D]`
> and still do: **they bind `D` themselves**, so theirs is not made redundant by the structure's."

This criterion is the one to apply throughout: a binder is redundant exactly when the same `D` is
already bound with `[Nontrivial D]` in enclosing scope; it is *not* redundant when the declaration
introduces its own `D`. All 21 sites are of the first kind — none of them rebinds `D`. This is
also why `Validity.lean` does not appear in the site list despite carrying an explicit binder.

The precedent commit `e73dcb62f` (TaskFrame, 9 sites) is the same defect from the same sweep,
already fixed by the same deletion.

---

## 3. The corroborating second linter, and why it matters

At most of these sites the compiler emits a **second, paired** warning that the brief does not
mention and that is strong independent evidence the deletion is the right fix:

```
FormalSystem/Metalogic/Algebraic/FlowFrame.lean:483:0: warning: automatically included section
variable(s) unused in theorem `…bundleFlowHistory_total`:
  [Nontrivial D]
```

Read the pair together: `linter.overlappingInstances` says *two* `[Nontrivial D]` are in the
signature, and `linter.unusedSectionVars` says the one that came from the **section** is the
unused one — because Lean's instance search resolves against the *nearer*, explicit binder. So
each duplicated site is simultaneously over-supplied and carrying dead weight. Deleting the
explicit binder resolves both: the section variable becomes the single, used instance and both
warnings clear at once.

This is exactly what happened in the TaskFrame precedent, where `unusedSectionVars` dropped
30 → 20 as a side effect of a fix aimed only at `overlappingInstances`. It will happen again here,
and the plan should *expect* the `unusedSectionVars` count to fall rather than treat the drop as
an unexplained delta. Measured drop: 97 → 83 tree-wide (Section 6).

Three sites have no paired `unusedSectionVars` warning (`Decidable.lean:2162`, `:2172`, `:2761`).
That is not an anomaly: at those the section instance is already genuinely used, so only the
explicit binder is surplus. The three `def`s at `FlowFrame.lean:466/:472/:479` also have no pair,
because `unusedSectionVars` does not fire on `def`s. Deletion is correct in both cases.

---

## 4. Class B: which `variable` block owns `[Nontrivial D]`, and why

### 4.1 Correcting the brief's premise

The brief's binding constraint — "a careless fix here can silently change WHICH `D` a theorem
quantifies over" — is predicated on `:74` shadowing into `section Countermodel`. **It does not.**
The file's structure is:

```
:72   section Invariance
:74     variable {D : Type} [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D] [Nontrivial D]
…
:335  end Invariance          ← the outer D dies here
…
:343  section Countermodel
:345    variable {W ι : Type} [Nonempty W] {D : Type} [AddCommGroup D] [LinearOrder D]
:346      [IsOrderedAddMonoid D] [Nontrivial D]
:347    variable [Fintype ι] [DenselyOrdered D] [NoMaxOrder D] [NoMinOrder D]
:348    -- `regionFrame` carries `[Nontrivial D]` (its *Limit* lemma needs it). It is declared
:349    -- here in its own right rather than being recovered from `[NoMaxOrder D]`, so that the
:350    -- `omit` clauses below can still drop the density instances.
:351    variable [Nontrivial D]
…
:394  end Countermodel
```

`section Countermodel` binds its own `{D : Type}` at `:345` as the *only* `D` in scope. There is
no outer binder to shadow, so there is no possibility of a theorem silently re-quantifying over a
different `D`. The `:345` re-declaration of `{D : Type}` is not shadowing — it is the section's
first and only introduction of `D`.

Both `[Nontrivial D]` at `:346` and `:351` therefore refer to the *same* `D`, in the *same*
section. The choice between them cannot change which `D` anything quantifies over. It can only
change the **order** of instance binders in the elaborated signature.

I verified this against the elaborator rather than reasoning about it alone (Section 5).

### 4.2 Which one is the accident

Commit dates settle it:

| Line | Introduced by | When |
|---|---|---|
| `:348-351` (comment + `variable [Nontrivial D]`) | `118ec5fdfd` "regionFrame acquires the Nontrivial D binder" | 2026-08-12 **19:26** |
| `:346`'s `[Nontrivial D]` | `ddfcb59c35` "[Nontrivial D] as a TaskFrame structure binder" | 2026-08-12 **20:57** |

`:351` is the older, deliberate, documented binder. `:346` is the later sweep's addition, made 90
minutes afterward by an author who — per that commit's own "Nothing was removed anywhere" —
was not looking for binders his change made redundant. **`:346` is the accident.**

### 4.3 Recommended owner: `:346` keeps it; delete `:351`

The historically-innocent binder is `:351`, but the recommendation is nonetheless to **keep
`:346` and delete `:351`**, on three grounds:

1. **The comment at `:348-350` states a requirement about scope, not about position.** Its
   content is: `[Nontrivial D]` must be declared independently rather than recovered from
   `[NoMaxOrder D]`, so that `omit [Fintype ι] [DenselyOrdered D] [NoMaxOrder D] [NoMinOrder D]`
   at `:368` cannot strip nontriviality along with the density instances. `:346` satisfies that
   requirement identically — its `[Nontrivial D]` is equally absent from the `omit` list. The
   documented intent survives the deletion of `:351` intact; only its *anchor* moves.

2. **`:346` is the codebase-wide convention.** The bundle
   `{D : Type} [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D] [Nontrivial D]` is the
   standard duration-group prefix established by `ddfcb59c35` across 33 files. Keeping it makes
   `section Countermodel`'s header identical in shape to `section Invariance`'s at `:74` in the
   same file, to `Decidable.lean:136`, to `FlowFrame.lean:449`, and to the TaskFrame section
   binders the precedent commit fixed against.

3. **It is the binder-order-preserving choice** — measured, not assumed. See Section 5.

**Concrete edit**: delete line `:351`, and reword `:348-350` so the comment documents the binder
at `:346` rather than one below it. Suggested replacement, preserving every claim the original
made:

```lean
-- `regionFrame` carries `[Nontrivial D]` (its *Limit* lemma needs it), which is why the binder
-- above declares it in its own right rather than recovering it from `[NoMaxOrder D]`: the `omit`
-- clauses below drop the density instances and must not take nontriviality with them.
```

This is a comment retarget, not a restructuring — it does not touch any `variable` block beyond
removing the duplicate, per the task's prohibition.

---

## 5. Empirical verification of the Class B choice

The brief correctly warns not to infer correctness from a green build, "since both arrangements
may well compile." They do — I built both. So the discriminator used was **elaborated signature
comparison**, obtained by appending `#check @…` for the three affected declarations and reading
the elaborator's output under each arrangement.

- **Variant A** = delete `:351` (recommended)
- **Variant B** = delete `[Nontrivial D]` from `:346`

Both: exit 0, 0 errors, 0 `Overlapping instance parameters`, 0 `unusedSectionVars`, 4 residual
warnings (all pre-existing `push_neg` deprecations at `:193/:223/:254/:266`).

Signature results:

| Declaration | Baseline | Variant A | Variant B |
|---|---|---|---|
| `RegionValued` | one `[inst_4 : Nontrivial D]` | **identical to baseline** | **identical to baseline** |
| `atomRegionInvariant_regionHistory` | `…[IsOrderedAddMonoid D] [Nontrivial D] [inst_5 : Nontrivial D] {f …}` | `…[IsOrderedAddMonoid D] [inst_4 : Nontrivial D] {f …}` | identical to A |
| `interpInvariantAt_regionHistory` | `…[IsOrderedAddMonoid D] [Nontrivial D] [Fintype ι] [DenselyOrdered D] [NoMaxOrder D] [NoMinOrder D] [inst_9 : Nontrivial D] {f …}` | `…[IsOrderedAddMonoid D] [inst_4 : Nontrivial D] [Fintype ι] [DenselyOrdered D] [NoMaxOrder D] [NoMinOrder D] {f …}` | `…[IsOrderedAddMonoid D] [Fintype ι] [DenselyOrdered D] [NoMaxOrder D] [NoMinOrder D] [inst_8 : Nontrivial D] {f …}` |

Three things this establishes:

- The two arrangements differ **only** in the position of one instance-implicit binder in
  `interpInvariantAt_regionHistory`. Nothing about `D` itself, no explicit argument, no
  proposition changes. The "which `D`" hazard the brief warns about is genuinely absent.
- `RegionValued` (a `def`) and `atomRegionInvariant_regionHistory` (whose `omit` at `:368`
  strips the density block) are **byte-identical under A and B**.
- **Variant A preserves the baseline's binder order**; Variant B permutes it. Baseline's *first*
  `[Nontrivial D]` sits immediately after `[IsOrderedAddMonoid D]` and before `[Fintype ι]`;
  Variant A's surviving binder occupies exactly that slot. For a warning-cleanup task, preserving
  the existing signature layout is the conservative choice — and it is the third and deciding
  ground for the recommendation in 4.3.

No consumer supplies these instances positionally: `grep -rn "@<name>"` across `FormalSystem/`
and `Tests/` returns **zero** `@`-applications for any of the 21 declarations, so even the
Variant-B permutation would have been safe. All cross-file uses are ordinary applications
(`Bridge/Valuation.lean` for `RegionValued` and `interpInvariantAt_regionHistory`; six files for
the `bundleFlow*` family; the `exists_*`/`truthAt_sep` group is `Decidable.lean`-internal, and
`truthAt_sep` is `private`). `Decidable.lean:2168`/`:2178` use the *named* form
`exists_gt_self (D := D) t`, which is order-independent.

---

## 6. Measured outcome of the complete fix

The full 21-site fix (18 Class A deletions + Variant A) was applied, built, tested, and then
reverted; `git status --porcelain FormalSystem/` is clean.

### Per-file, via `lake env lean`

| File | `overlappingInstances` | `unusedSectionVars` | total warnings | errors |
|---|---|---|---|---|
| `FlowFrame.lean` | 13 → **0** | 11 → **1** | 24 → **1** | 0 → 0 |
| `Decidable.lean` | 5 → **0** | 6 → **4** | 15 → **8** | 0 → 0 |
| `TruthLemma.lean` | 3 → **0** | 2 → **0** | 9 → **4** | 0 → 0 |

Every residual warning is a strict subset of the pre-existing set: `FlowFrame.lean:635`
(`fmcs_box_persistent`, unrelated and untouched), four `Decidable.lean` `unusedSectionVars` at
`:1000/:1019/:1153/:1164`, and the `push_neg` deprecations.

### Tree-wide, via forced full build (`--no-share`)

| Metric | Baseline | After fix |
|---|---|---|
| `lake build` exit | 0 | **0** |
| Jobs | 2506 | **2506** |
| `Overlapping instance parameters` | 21 | **0** |
| `automatically included section variable` | 97 | **83** |
| Total `warning:` lines | 381 | **346** |
| `error:` | 0 | **0** |
| `declaration uses 'sorry'` | 0 | **0** |
| `lake test` exit | — | **0** (2556 jobs) |

**No new warning of any class appears.** Verified set-theoretically, not by count: sorting the
full warning text of both builds and taking `comm -13 baseline fix` yields an empty set. The
converse direction confirms all 35 cleared warnings originate in the three target files and
nowhere else — there is no collateral change anywhere in the tree.

The `unusedSectionVars` drop of 14 decomposes exactly as Section 3 predicts:
FlowFrame −10 (its 11 sites minus the untouched `:635`), Decidable −2 (`:2144`, `:2149`),
TruthLemma −2 (`:374`, `:389`).

---

## 7. Recommended plan shape

The work is small, uniform, and fully verified; it does not warrant fine-grained decomposition.
Three phases, one file each, is the natural sizing — the files are independent (no cross-file
edit is required) but `FlowFrame.lean` and `Decidable.lean` both feed the same downstream
build, so verification is cheapest once at the end.

- **Phase 1 — `FlowFrame.lean` (13 Class A deletions).** Remove `` [Nontrivial D]`` from the 13
  lines in the table in Section 1. Verify: `lake env lean` reports 0 overlapping, 0 errors,
  exactly 1 residual `unusedSectionVars` (at `:635`).
- **Phase 2 — `Decidable.lean` (5 Class A deletions).** Same edit at `:2144`, `:2149`, `:2162`,
  `:2172`, and `:2762`. Note `:2762` is the *continuation* line of the `:2761` declaration and
  must retain `[DenselyOrdered D]`. Verify: 0 overlapping, 4 residual `unusedSectionVars`.
- **Phase 3 — `TruthLemma.lean` (Class B).** Delete `:351`; retarget the `:348-350` comment to
  the `:346` binder using the wording in Section 4.3. Record in the phase notes that `:346` owns
  `[Nontrivial D]` and why (Section 4.2/4.3). Verify: 0 overlapping, 0 `unusedSectionVars`.
- **Phase 4 — acceptance.** Forced full build and test.

### Acceptance commands

```bash
# per-file (0 expected from each)
lake env lean FormalSystem/Metalogic/Algebraic/FlowFrame.lean 2>&1 \
  | grep -c "Overlapping instance parameters"
lake env lean FormalSystem/Metalogic/Decidability/Verified/Decidable.lean 2>&1 \
  | grep -c "Overlapping instance parameters"
lake env lean FormalSystem/Metalogic/Decidability/Verified/Bridge/TruthLemma.lean 2>&1 \
  | grep -c "Overlapping instance parameters"

# forced full build — --no-share defeats the guard's result replay, so this is a genuine build.
# Run detached via Bash(run_in_background: true) per context/project/lean4/operations/long-builds.md.
bash .claude/scripts/lake-build-guard.sh build --timeout 1800 --no-share -- build
bash .claude/scripts/lake-build-guard.sh build --timeout 1800 --no-share -- test

# no linter disabled, no sorry introduced
grep -rn overlappingInstances FormalSystem/          # must return nothing
grep -rn "sorry\|admit\|native_decide" FormalSystem/ # must not grow
```

Expected on the full build: `Build completed successfully (2506 jobs).`, exit 0, 0 overlapping,
83 `unusedSectionVars`, 346 total warnings, 0 errors. **Confirm the 2506 job count explicitly** —
the guard replays a completed result when the fingerprint matches, so a scoped or shared result
can otherwise present as a full pass. `--no-share` is what forces the real thing.

### Notes for the implementer

- **The build cache currently reflects the reverted (baseline) sources.** A restore build was run
  after the probe, so the first build of the implementation should behave normally.
- **Do not touch** `FormalSystem/Semantics/TaskFrame.lean` (already fixed by `e73dcb62f`),
  `FormalSystem/Semantics/Ultraproduct/**`, or `ShiftSet.lean`.
- **Never** add `set_option linter.overlappingInstances false` at any scope. The duplicate is
  what gets removed.
- The three `noncomputable def`s at `FlowFrame.lean:466/:472/:479` change arity by one
  instance-implicit argument, which invalidates the `.olean` of six consuming files
  (`Algebraic.lean`, `BXCanonical/{Completeness,CompletenessDedekind,DiscreteCarrierProbe}.lean`,
  `BXCanonical/Chronicle/ChronicleToCountermodelBasic.lean`, `Bundle/LimitMCS.lean`). No source
  edit is needed in any of them — this was confirmed by the full build — but expect the rebuild
  to be broad.

---

## 8. Zero-debt compliance

No `sorry`, `admit`, `axiom`, or `native_decide` is introduced or required; the tree's `sorry`
count in the build log is 0 both before and after. No linter is disabled anywhere. No proof is
deferred, and no approach considered here requires one — the fix is a deletion of redundant
binders whose removal was verified to preserve every elaborated signature up to the position of
one instance-implicit argument.
