# Implementation Summary: Task #508

- **Task**: 508 — Parameterize soundness over indexed validity
- **Plan**: `plans/01_soundness-in-parameterized-collapse.md`
- **Status**: implemented (9/9 phases COMPLETED)
- **Baseline commit**: `bee03a881`
- **Session**: sess_1788282938_f2ac03

## What landed

One soundness theorem now exists where four did.

```lean
theorem soundness_in {fc : FrameClass} (Γ : Context) (φ : Formula)
    (d : DerivationTree fc Γ φ) (F : TaskFrame) (hF : fc.Sat F) (M : TaskModel F)
    (τ : WorldHistory F) (h_mem : τ.IsTotal) (t : F.Duration)
    (h_ctx : ∀ ψ ∈ Γ, TruthAt M τ t ψ) : TruthAt M τ t φ
```

Supporting it: `axiom_validIn_min` / `axiom_swap_validIn_min` (one arm per axiom constructor, each
stated at that axiom's own `minFrameClass`), lifted by `ValidIn.mono` to `axiom_validIn` /
`axiom_swap_validIn` at an arbitrary class; `derivable_valid_and_swap_validIn`, the single
recursion carrying validity and swap-validity together; and `soundness_validIn` for the
empty-context form.

Everything else in the family is now a corollary. `soundness`, `soundness_dense`,
`soundness_discrete`, `soundness_dedekind`, the three `soundness_*_valid`, the four
`axiom_*_valid`, the eight `bl_soundness*`, and the four `soundness_*_consequence` all keep their
exact statements and differ only in supplying their class's `FrameClass.Sat` witness — `trivial`
at `.Base`, the `DenselyOrdered` instance at `.Dense`, the four order instances at `.Discrete`,
the density-plus-LUB pair at `.Dedekind`.

Two new theorems close gaps rather than replacing anything: `bl_soundness_in` (BL soundness at an
arbitrary class, previously only available per-class) and `soundness_setConsequence`
(`SetDerivable fc Γ φ → SetSemanticConsequenceOn fc Γ φ`, which had no statement in the tree at
all and is review H2's literal form).

The list-context consequence layer was collapsed the same way: `ConsequenceOnFrames` /
`SemanticConsequenceIn` in `Semantics/Validity.lean`, with all four named relations
(`SemanticConsequence{,Dense,Discrete,DedekindDense}`) becoming one-line instances, each keeping
its name, its type, and a new `.of_forall`/`.apply` pair recovering its pre-abbreviation binder
shape. The set layer had already been collapsed under task 507, so the two layers are now
symmetric.

## What was deleted

Twelve declarations, each grepped for consumers immediately before removal:

- `Metalogic/Soundness.lean`: `axiom_dedekind_swap_valid`,
  `derivable_valid_and_swap_valid_dedekind`, and the private `validDedekindDense_of_validDense`
  (orphaned by the collapse).
- `SoundnessLemmas/FrameClassVariants.lean` (1041 → 591 lines): `axiom_locally_valid_general`
  (~290 lines, a third full copy of base-axiom validity that the task brief had not counted),
  `derivable_valid_and_swap_valid_general`, `derivable_implies_swap_valid_general`,
  `axiom_swap_valid_discrete`, `axiom_locally_valid_discrete`,
  `derivable_valid_and_swap_valid_discrete`, `derivable_implies_swap_valid_discrete`.
- `SoundnessLemmas/DenseValidity.lean` (1375 → 1296 lines): `derivable_valid_and_swap_valid`,
  `derivable_locally_valid`, `derivable_implies_swap_valid`.

Deliberately preserved: `axiom_swap_valid_general`, the four `prior_UZ/SZ/z1` validity lemmas
(three of which `Metalogic/Decidability/Verified/Decidable.lean` also depends on, independently of
soundness), and `DenseValidity`'s `axiom_swap_valid` — all still consumed by
`axiom_swap_validIn_min`. Also preserved untouched, and verified byte-identical:
`bl_soundness_discrete_succ`, `bl_soundness_discrete_succ_valid`, `BLValidDiscreteSucc`. These are
not schema instances — no `FrameClass.Sat` variant bundles `SuccOrder`+`PredOrder` alone.

## Verification

- `lake build FormalSystem BimodalTest`: exit 0, 2565 jobs, green on two consecutive runs.
- `#print axioms` on all 35 relevant declarations — the 21 flagship baseline results plus all 14
  new ones — reports exactly `[propext, Classical.choice, Quot.sound]`. No profile widened.
- No theorem weakened: 63 retained theorem signatures compared byte-for-byte against `bee03a881`;
  0 changed.
- The four collapsed consequence relations are proved propositionally identical to their
  pre-collapse binder lists in `reports/03_consequence-collapse-equivalence-probe.lean`.
- Zero `sorry` introduced. Raw non-Boneyard `sorry` token count went 356 → 353, the three removed
  being docstring prose. The eight edited `.lean` files carry zero real `sorry` terms.
- `^axiom ` declaration count unchanged at 8.
- `FormalSystem/Boneyard/**` unmodified; the six enumerated downstream consumer modules unmodified.
- `check-module-invariants.sh` C14 (axiom baselines) and C15 (paper anchors) both PASS.

## Plan Deviations

1. **Phase 4 — the eleven corollaries were relocated, not edited in place.** Lean requires
   declare-before-use, and `axiom_validIn_min` consumes `sep_valid`, `sep_swap_valid` and the two
   `prior_*_gap_valid` lemmas, all defined *below* the corollaries' original positions. The
   parameterized family therefore cannot move up, so the corollaries moved down into a new
   `/-! ## Per-class corollaries of \`soundness_in\` -/` section. Statements verified byte-identical
   across the move; instance binders were left anonymous and read with `‹_›` rather than renamed,
   so no signature line changed.
2. **Phase 4 — one unplanned deletion.** `validDedekindDense_of_validDense`, a `private` helper
   whose only consumer was `axiom_dedekind_valid`'s deleted 45-arm body.
3. **Phase 4 — six docstrings rewritten.** They described proof structure the collapse removed
   (the module header's Main Results / Implementation Notes / Full Derivation Soundness /
   Frame-Class Architecture blocks, the `soundness` / `soundness_dense_valid` /
   `soundness_discrete_valid` / `axiom_dedekind_valid` docstrings, the Reynolds section header, and
   one stale `axiom_dedekind_swap_valid` citation). Leaving them would have left the file asserting
   falsehoods about its own proofs.
4. **Phase 5 — `FrameClassVariants.lean` landed at 591 lines, not the predicted "roughly 500".**
   The gap is protected content (`axiom_swap_valid_general` plus the four `prior_UZ/SZ/z1` lemmas)
   being larger than the plan's estimate. No deletion was skipped.
5. **Phase 5 — all five `SoundnessLemmas/README.md` Modules rows were stale, not the two the plan
   predicted.** Rebuilt from `wc -l`: CoValidity 143→141, Core 106→107, DenseValidity 1338→1296,
   FrameClassVariants 971→591, Separability 346→352.
6. **Phase 5 — five docstrings in other files cited deleted names** and were rewritten so they do
   not reference declarations that no longer exist.
7. **Phase 6 — `BLValidIn.of_forall_total` / `.apply_total` report `[propext]`,** not the flagship
   three-axiom profile. Not a regression: they are pure shape adapters with no classical content,
   and their `Validity.lean` originals have the same narrow profile.
8. **Phase 7 — the generic-layer `.of_forall_total`/`.apply_total` pair was deliberately not
   added.** `ConsequenceOnFrames` is already stated over the unbundled
   `(τ : WorldHistory F) (_ : τ.IsTotal)` pair — unlike `ValidOnFrames`, which bundles the history
   into `TaskFrame.HF` — so a generic history-shape adapter would be the identity. The mandated
   template, `SetConsequence.lean`, has no such pair either, for the same reason.
9. **Phase 7 — the Scope Hypothesis "0 existing proofs requiring edits" was false**, as the plan
   itself flagged it was most likely to be. The collapse is propositionally but not definitionally
   identical: `ConsequenceOnFrames` takes the frame condition as an explicit `P F` argument where
   the hand-written lists took it as an instance binder (or, at `.Base`, not at all). Required
   edits: five proofs in `Validity.lean`, the four `semantic_deduction_*` proofs in
   `StrongCompleteness.lean`, and **118 call sites across 7 files of the test suite**, every one
   the same pattern (`soundness Γ φ d` read at type `Γ ⊨ φ`) becoming `soundness_in Γ φ d` — the
   same term at the parameterized level. No test assertion changed, and the transformation is
   compiler-checked. This was unbudgeted work outside the plan's Files-to-modify list, and it is
   the one place where the task's "zero downstream call-site edits" promise does not hold. The
   promise did hold for the nine `FormalSystem/` consumer modules it was made about.
10. **Phase 8 — `soundness_setConsequence` landed in `StrongCompleteness.lean`, not
    `SetConsequence.lean`.** Import direction forces it; the plan anticipated the choice and asked
    for it to be recorded.
11. **Phases 7 and 8 landed in one commit.** Phase 7's binder-shape change necessarily breaks the
    four bodies Phase 8 retargets, so Phase 7 has no independently green state. The two phases are
    one atomic change — a plan-structure finding, not an execution shortcut.
12. **Phase 1 — a build-verification error was made and corrected.** The first baseline invocation
    was `lake-build-guard.sh build --timeout 1800 --` with nothing after the `--`; the guard runs
    `lake "$@"` on the post-`--` arguments, so that ran bare `lake`, printed help, and exited 0
    without building. Its exit 0 was not evidence of a green tree. The correct shape repeats the
    subcommand: `-- build [TARGET]`. Corrected in `reports/02_anchor-and-callsite-inventory.md` §1
    rather than silently fixed.

## Reasoned Exclusions

Two pre-existing gate failures were recorded, not absorbed or repaired — full evidence table under
Phase 9 of the plan:

- `check-module-invariants.sh` C6: four unreachable-and-unmanifested modules belonging to other
  tasks, failing identically at baseline and at Phase 9.
- `readme-lint.sh` check 1: missing `FormalSystem/Semantics/Ultraproduct/README.md`, likewise
  identical at both ends.

## Artifacts

- `reports/02_anchor-and-callsite-inventory.md` — Phase 1 ground truth: every anchor re-verified by
  `grep -n`, the full downstream consumer inventory, baseline axiom profiles and gate results.
- `reports/03_consequence-collapse-equivalence-probe.lean` — machine-checked proof that each
  collapsed consequence relation matches its pre-collapse binder list.
- `handoffs/phase-{1,3,4,5,6,8}-handoff-*.md` — per-phase recovery points.
