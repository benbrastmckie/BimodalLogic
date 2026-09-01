# Anchor and Call-Site Inventory (Phase 1)

- **Task**: 508 — Parameterize soundness over indexed validity
- **Produced by**: Phase 1 of `plans/01_soundness-in-parameterized-collapse.md`
- **Baseline commit**: `bee03a88108807a8565f8df12caac2f77348382e`
- **Method**: every line number below came from a `grep -n` run against the working tree at that
  commit. None was copied from the plan.

## 1. Baseline build

**Correction to a first attempt, recorded rather than quietly fixed.** The first baseline
invocation was written as `lake-build-guard.sh build --timeout 1800 --` with nothing after the
`--`. The guard runs `lake "$@"` on the post-`--` arguments, so that call ran bare `lake`, printed
its help, and exited 0 without building anything. Its exit 0 was therefore *not* evidence of a
green tree. The correct shape repeats the subcommand after the separator:

```
bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build [MODULE]
```

Baseline evidence as actually established:
- The whole `.lake/build/lib/lean/` tree carries oleans written at the task-507 completion build,
  and every `#print axioms` probe in §4 below elaborated against those oleans without error —
  which requires the imported modules to have compiled.
- The first correctly-shaped build (`-- build FormalSystem.Metalogic.Soundness`, run at the start
  of Phase 2) reported `Build completed successfully (1008 jobs)`, exit 0, replaying 1007 upstream
  modules from cache without a single error.

Phase 9's full-tree `-- build` is the definitive green check.

Live `.lean` file counts (`find`, Boneyard excluded): 433 under `FormalSystem/`, 54 under
`Tests/` — matching `check-module-invariants.sh` C7's own 488/433/54 census.

## 2. Declaration anchors — verified

### `FormalSystem/Metalogic/Soundness.lean` (2108 lines)

| Declaration | Plan said | Actual | Delta |
|---|---|---|---|
| `axiom_valid` | 925 | 925 | — |
| `axiom_dense_valid` | 979 | 979 | — |
| `axiom_discrete_valid` | 1040 | 1040 | — |
| `soundness` | 1152 | 1152 | — |
| `soundness_dense_valid` | 1256 | 1256 | — |
| `soundness_dense` | 1329 | 1329 | — |
| `soundness_discrete_valid` | 1421 | 1421 | — |
| `soundness_discrete` | 1477 | 1477 | — |
| `sep_swap_valid` | 1763 | 1763 | — |
| `axiom_dedekind_valid` | 1819 | 1819 | — |
| `axiom_dedekind_swap_valid` | 1888 | 1888 | — |
| `derivable_valid_and_swap_valid_dedekind` | 1919 | 1919 | — |
| `soundness_dedekind_valid` | 1995 | 1995 | — |
| `soundness_dedekind` | 2014 | 2014 | — |

### `FormalSystem/Metalogic/StrongCompleteness.lean` (943 lines)

| Declaration | Plan said | Actual | Delta |
|---|---|---|---|
| `SemanticConsequenceDedekindDense` | 174 | 174 | — |
| `soundness_dedekind_consequence` | 530 | 530 | — |
| `soundness_base_consequence` | 676 | 676 | — |
| `SemanticConsequenceDense` | 729 | 729 | — |
| `soundness_dense_consequence` | 781 | 781 | — |
| `SemanticConsequenceDiscrete` | 839 | 839 | — |
| `soundness_discrete_consequence` | 891 | 891 | — |

### `FormalSystem/Metalogic/BaseLanguageSoundness.lean` (482 lines)

| Declaration | Plan said | Actual | Delta |
|---|---|---|---|
| `bl_soundness` | 201 | 201 | — |
| `bl_soundness_dense` | 215 | 215 | — |
| `bl_soundness_discrete` | 229 | 229 | — |
| `bl_soundness_dedekind` | 249 | 249 | — |
| `bl_soundness_valid` | 264 | 264 | — |
| `bl_soundness_dense_valid` | 269 | 269 | — |
| `bl_soundness_discrete_valid` | 274 | 274 | — |
| `bl_soundness_dedekind_valid` | 280 | 280 | — |
| `bl_soundness_discrete_succ` (**preserve**) | 381 | 381 | — |
| `bl_soundness_discrete_succ_valid` (**preserve**) | 413 | 413 | — |

### `FormalSystem/Metalogic/SoundnessLemmas/FrameClassVariants.lean` (1041 lines)

| Declaration | Plan said | Actual | Disposition |
|---|---|---|---|
| `axiom_swap_valid_general` | 45 | 45 | **KEEP** |
| `axiom_locally_valid_general` (private) | 393 | 393 | delete |
| `derivable_valid_and_swap_valid_general` | 683 | 683 | delete |
| `derivable_implies_swap_valid_general` | 726 | 726 | delete |
| `prior_UZ_is_valid` | 742 | 742 | **KEEP** |
| `prior_SZ_is_valid` | 782 | 782 | **KEEP** |
| `z1_is_valid` | 821 | 821 | **KEEP** |
| `z1_past_is_valid` | 883 | 883 | **KEEP** |
| `axiom_swap_valid_discrete` (private) | 939 | 939 | delete |
| `axiom_locally_valid_discrete` (private) | 972 | 972 | delete |
| `derivable_valid_and_swap_valid_discrete` | 994 | 994 | delete |
| `derivable_implies_swap_valid_discrete` | 1034 | 1034 | delete |

### `FormalSystem/Metalogic/SoundnessLemmas/DenseValidity.lean` (1375 lines)

| Declaration | Plan said | Actual | Disposition |
|---|---|---|---|
| `axiom_swap_valid` | 296 | 296 | **KEEP** |
| `derivable_valid_and_swap_valid` | 1320 | 1320 | delete |
| `derivable_locally_valid` | 1362 | 1362 | delete |
| `derivable_implies_swap_valid` | 1369 | 1369 | delete |

### `FormalSystem/Semantics/Validity.lean` (945 lines)

| Declaration | Plan said | Actual | Delta |
|---|---|---|---|
| `SemanticConsequence` | 89 | 89 | — |
| `ValidIn.mono` | 413 | 413 | — |
| `ValidOnFrames.of_forall_total` | 426 | **428** | **+2** |
| `ValidOnFrames.apply_total` | 433 | **435** | **+2** |
| `ValidIn.of_forall_total` | 441 | 441 | — |
| `ValidIn.apply_total` | 448 | 448 | — |

### `FormalSystem/Semantics/BLValidity.lean` (309 lines)

| Declaration | Plan said | Actual | Delta |
|---|---|---|---|
| `TaskFrame.BLValidOn` | 96 | 96 | — |
| `BLValidOnFrames` | 102 | 102 | — |
| `BLValidIn` | 107 | 107 | — |
| `BLValidOnFrames.mono` | 141 | 141 | — |
| `BLValidIn.mono` | 147 | 147 | — |
| `BLValidDiscreteSucc` (**preserve**) | 221 | 221 | — |

**Confirmed absent**: `BLValidIn.of_forall_total`, `BLValidIn.apply_total`,
`BLValidOnFrames.of_forall_total`, `BLValidOnFrames.apply_total`. Only the `.mono` pair exists.

### `FormalSystem/Metalogic/SetConsequence.lean` (445 lines)

| Declaration | Plan said | Actual | Delta |
|---|---|---|---|
| `SetConsequenceOnFrames` | 91 | 91 | — |
| `SetSemanticConsequenceOn` | 98 | 98 | — |
| per-class `.of_forall`/`.apply` adapters | 129–197 | 129–197 (129,136,143,151,159,170,179,188) | — |
| `setConsequenceOnFrames_mono` | 208 | 208 | — |
| `setDerivable_iff_exists_finite` | 247 | 247 | — |

**Anchor delta summary**: 2 of ~45 anchors moved (both in `Validity.lean`, both by +2 lines).
Every other anchor in the plan is exact. All later phases locate by declaration name regardless.

## 3. Downstream consumer inventory

`grep -rn '\b<name>\b' FormalSystem/ Tests/ --include=*.lean`, Boneyard excluded. Docstring-only
mentions are noted separately from real call sites.

### The four `axiom_*_valid` dispatchers — **live consumers confirmed, must be RETAINED**

| Name | External call site |
|---|---|
| `axiom_valid` | `Metalogic/Independence/LexIntWitness.lean:182` |
| `axiom_dense_valid` | `Metalogic/Independence/RationalWitness.lean:126` |
| `axiom_discrete_valid` | `Metalogic/Independence/LexIntWitness.lean:233` |
| `axiom_dedekind_valid` | `Metalogic/Independence/RationalWitness.lean:172` |

The planning-time correction to the research's §10 sketch is **confirmed**: deleting these four
would break two modules. They are retained as one-line corollaries over `axiom_validIn`.

(`axiom_dense_valid` and `axiom_discrete_valid` additionally have in-file call sites at
`Soundness.lean:1261`, `:1425`, `:1486`, and `axiom_dedekind_valid` at `:1924`, `:2024` — all
inside bodies Phase 4 retargets.)

### The two genuinely deletable names — **confirmed consumer-free outside `Soundness.lean`**

| Name | Occurrences |
|---|---|
| `axiom_dedekind_swap_valid` | `Soundness.lean:1753` (docstring), `:1888` (defn), `:1915` (docstring), `:1924` (use, inside `derivable_valid_and_swap_valid_dedekind` which is itself deleted) |
| `derivable_valid_and_swap_valid_dedekind` | `Soundness.lean:1917,1919,1928,1929,1944,1957,1973,1983` (self-recursion + defn), `:1997`, `:2041` (uses inside `soundness_dedekind_valid` / `soundness_dedekind`, both retargeted in Phase 4) |

Zero occurrences outside `FormalSystem/Metalogic/Soundness.lean`. Deletion is safe once Phase 4
retargets `:1997` and `:2041`.

### Phase 5 deletion candidates — consumers, all inside bodies Phase 4 retargets

| Name | Consumers outside its own file |
|---|---|
| `axiom_locally_valid_general` | none (in-file only: `:688`, `:977`, both in deleted decls) |
| `derivable_valid_and_swap_valid_general` | none (in-file self-recursion + `:729` inside deleted `derivable_implies_swap_valid_general`) |
| `derivable_implies_swap_valid_general` | `Soundness.lean:1226` (inside `soundness_dense_valid`, retargeted in Phase 4); `:1145`, `:1417` docstring-only |
| `axiom_swap_valid_discrete` | none (in-file `:1000`, inside a deleted decl); `BaseLanguageSoundness.lean:318` docstring-only |
| `axiom_locally_valid_discrete` | none (in-file `:1000`); `BaseLanguageSoundness.lean:319` docstring-only |
| `derivable_valid_and_swap_valid_discrete` | none (in-file self-recursion + `:1038`); `BaseLanguageSoundness.lean:314` docstring-only |
| `derivable_implies_swap_valid_discrete` | `Soundness.lean:1455`, `:1504` (inside `soundness_discrete_valid` / `soundness_discrete`, both retargeted in Phase 4); `:98` docstring-only |
| `derivable_valid_and_swap_valid` (DenseValidity) | none outside its file (in-file self-recursion + `:1365`, `:1372`); `FrameClassVariants.lean:674` docstring-only |
| `derivable_locally_valid` | **zero** occurrences anywhere but its own definition line |
| `derivable_implies_swap_valid` (DenseValidity) | `Soundness.lean:1296`, `:1400` (inside `soundness_dense_valid` / `soundness_dense`, retargeted in Phase 4); `:84`, `DenseValidity.lean:215` docstring-only |

**Consequence**: every Phase 5 deletion candidate becomes consumer-free only *after* Phase 4
lands. The plan's phase ordering (5 depends on 4) is therefore load-bearing, not merely tidy.

### Protected names — consumers confirmed, **must survive**

| Name | Consumers |
|---|---|
| `axiom_swap_valid_general` | `FrameClassVariants.lean:688`, `:944` today; will be consumed by `axiom_swap_validIn_min`'s Base branch |
| `prior_UZ_is_valid` | `Soundness.lean:899`, `FrameClassVariants.lean:951`, `:979`, **`Metalogic/Decidability/Verified/Decidable.lean:2449`** |
| `prior_SZ_is_valid` | `Soundness.lean:906`, `FrameClassVariants.lean:948`, `:980`, **`Decidable.lean:2482`** |
| `z1_is_valid` | `Soundness.lean:914`, `FrameClassVariants.lean:981`, **`Decidable.lean:2532`** |
| `z1_past_is_valid` | `FrameClassVariants.lean:955`; will be consumed by `axiom_swap_validIn_min` |
| `axiom_swap_valid` (DenseValidity) | `FrameClassVariants.lean` and, after Phase 2, `axiom_swap_validIn_min` |

The `Decidable.lean` consumers of the three `prior_*`/`z1` lemmas are a stronger protection
argument than the plan records: those three names are load-bearing for the decision procedure,
entirely independently of the soundness collapse.

## 4. Baseline `#print axioms`

Every one of the following reports exactly `[propext, Classical.choice, Quot.sound]`:

```
FormalSystem.Metalogic.soundness
FormalSystem.Metalogic.soundness_dense
FormalSystem.Metalogic.soundness_discrete
FormalSystem.Metalogic.soundness_dedekind
FormalSystem.Metalogic.soundness_dense_valid
FormalSystem.Metalogic.soundness_discrete_valid
FormalSystem.Metalogic.soundness_dedekind_valid
FormalSystem.Metalogic.bl_soundness
FormalSystem.Metalogic.bl_soundness_dense
FormalSystem.Metalogic.bl_soundness_discrete
FormalSystem.Metalogic.bl_soundness_dedekind
FormalSystem.Metalogic.bl_soundness_valid
FormalSystem.Metalogic.bl_soundness_dense_valid
FormalSystem.Metalogic.bl_soundness_discrete_valid
FormalSystem.Metalogic.bl_soundness_dedekind_valid
FormalSystem.Metalogic.bl_soundness_discrete_succ
FormalSystem.Metalogic.bl_soundness_discrete_succ_valid
FormalSystem.Metalogic.soundness_base_consequence
FormalSystem.Metalogic.soundness_dense_consequence
FormalSystem.Metalogic.soundness_discrete_consequence
FormalSystem.Metalogic.soundness_dedekind_consequence
```

## 5. Baseline `sorry` and `axiom` counts

- Raw `sorry` token occurrences under `FormalSystem/` + `Tests/`, Boneyard excluded: **356**.
- Occurrences in the eight files this task modifies: **12**, and **every one of them is inside a
  docstring** (`Soundness.lean` 7, `StrongCompleteness.lean` 4, `Validity.lean` 1 — all prose of
  the form "sorry-free"). The modified files carry **zero real `sorry` terms**; that is the number
  Phase 9 must preserve.
- `^axiom ` declarations under `FormalSystem/`: **8**.

## 6. Baseline gate-script results

### `scripts/check-module-invariants.sh` — 1 check group failed

**C6 FAIL** on exactly the four modules the plan predicts, and no others:

```
FormalSystem.Metalogic.SpWitness
FormalSystem.Metalogic.TMCompletenessReduction
FormalSystem.Metalogic.Z1Countermodel
FormalSystem.Semantics.LexCarrier
```

**Pre-existing; belongs to other tasks. Not this task's defect.**

**C14 PASS** (axiom baselines and documented counts), **C15 PASS** (47 paper anchors).
Both must still pass at Phase 9; a regression in either *is* this task's defect.

Also informational-only and unchanged by this task: `C9D` TODO on 138 doc task-number citations.

### `scripts/readme-lint.sh` — FAIL

Check 1: **1 missing README**, exactly as predicted:

```
MISSING: FormalSystem/Semantics/Ultraproduct/README.md (4 .lean files)
```

**Pre-existing. Not this task's defect.** Checks 2 (112 files not listed) and 4 (6 missing dates)
are informational and do not affect the exit code. Check 3 (broken references) passes with 0.

Note for Phase 5: `readme-lint.sh` check 2 already reports `FrameClassValidity.lean`,
`FrameProperty.lean`, and `TemporalOrder.lean` as "not listed" in
`FormalSystem/Semantics/README.md`. Those are pre-existing informational findings; Phase 5's
README work is scoped to `SoundnessLemmas/README.md` only.

## 7. Confirmed pre-work facts

- `FormalSystem/FrameConditions/` does not exist; residual references are Boneyard-only.
- `SoundnessLemmas/README.md`'s Modules table is stale before this task begins: it lists
  `FrameClassVariants.lean` at 971 and `DenseValidity.lean` at 1338, against actuals of **1041**
  and **1375**. Phase 5 rebuilds those rows from `wc -l` rather than decrementing.
- `Soundness.lean` is 2108 lines, not the 2044 the brief implies.
