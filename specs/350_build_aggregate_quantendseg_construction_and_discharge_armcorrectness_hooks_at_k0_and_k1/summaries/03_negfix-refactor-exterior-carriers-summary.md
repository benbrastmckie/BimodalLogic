# Task 350 Implementation Summary — negFix refactor + exterior carriers + six-arm DoD (plan v3)

**Task**: 350 — build aggregate quantEnd/seg construction and discharge arm-correctness hooks at k=0 and k=1
**Plan**: `plans/03_negfix-refactor-exterior-carriers.md` (v3, authoritative)
**Status**: COMPLETE — all phases (7 through 17, incl. 10b/12a/12b/14a-c/15/16a/16b sub-phases and R1.1-R1.6) [COMPLETED]
**Blocker resolution**: `blk-350-p4-offdiag-k1-aggregate` **CLOSED** — the missing `VVecEA2` biconditional
conjunction (Rabinovich Lemma 3.4 iff form) landed as `VVecEA2.conjFull_iff` (P1,
`Kamp/VecEAConjFull.lean`), unblocking the k=1 off-diagonal pair `kampArm_{past,future}_k1_correct`
(delivered Phase 16b, `AggregateOffDiagK1.lean`).

## 1. Deliverable ↔ consuming-site name map (for task 309 Phase 18b)

All names live in namespace `Bimodal.Metalogic.WeakCanonical.Kamp` (`NegFixGateProbe` is the one
sub-namespace). Blocks named `ArmLemmasK0`, `AggregateOffDiag`, `ExteriorNav*` etc. are *sections* —
they do not qualify names.

### The six DoD arm lemmas

| Deliverable | File | Consuming site |
|---|---|---|
| `kampArm_past_k0` / `kampArm_past_k0_correct` | `NfMultiAnchorBridge/AggregateHookDischarge.lean` | 309 Phase 18b past arm at ambient k=0; already consumed by task 358's `kampPrior_case1_arm_k0` (KampPrior.lean, task-358 commit 8a7d504ec) |
| `kampArm_diag_k0` / `kampArm_diag_k0_correct` | `NfMultiAnchorBridge/AggregateHookDischarge.lean` | 309 Phase 18b diagonal arm at k=0 (same consumers) |
| `kampArm_future_k0` / `kampArm_future_k0_correct` | `NfMultiAnchorBridge/AggregateHookDischarge.lean` | 309 Phase 18b future arm at k=0 (same consumers) |
| `kampArm_diag_k1` / `kampArm_diag_k1_correct` | `NfMultiAnchorBridge/AggregateHookDischarge.lean` | 309 Phase 18b diagonal arm at ambient k=1 |
| `kampArm_past_k1` / `kampArm_past_k1_correct` | `NfMultiAnchorBridge/AggregateOffDiagK1.lean` | 309 Phase 18b past arm at k=1 (`sub_nf : NormalForm sig 2 2`, generic-site index `1 + 1`) |
| `kampArm_future_k1` / `kampArm_future_k1_correct` | `NfMultiAnchorBridge/AggregateOffDiagK1.lean` | 309 Phase 18b future arm at k=1 (same shape) |

Each k=1 `_correct` conclusion matches the `kampPrior_site_trichotomy` disjunct shape verbatim —
certified by the `ShapeCertificatesK1` `example`s in `AggregateOffDiagK1.lean` (no KampPrior import).

### P1/P2/P3 primitives and exterior carriers

| Layer | Names | File |
|---|---|---|
| P1 conjFull kit | `BracketFormula.snoc/conjFull(_iff)`, `VVecEA2.conjFull(_iff)`, `trivialTrue` neutrals | `Kamp/VecEAConjFull.lean` |
| P2 negation stack | `negChainOn(_iff)` | `Kamp/EANegationFix/OnBuilder.lean` |
| | `negBounded{Right,Left}Fix(_iff)` (Cor 5.4 folds) | `Kamp/EANegationFix/BoundedFix.lean` |
| | `negBounded{Right,Left}FixAnchored(_iff)` | `Kamp/EANegationFix/BoundedFixAnchored.lean` |
| | `BracketFormula/VBracketFormula.concatPin(_holds_iff)` (Lemma 7.6 pin gluing) | `Kamp/EANegationFix/ConcatPin.lean` |
| | `negFixOne_cover/_iff`, `NegFixGateProbe.caseB4_holds` (ℤ B4 gate-necessity counterexample) | `Kamp/EANegationFix/NegFixOne.lean` |
| | `BracketFormula.negFix(_iff)` (Lemma 5.1 general recursion) | `Kamp/EANegationFix/NegFix.lean` |
| | `VecEA2.negFix_iff`, `VVecEA2.negFix_iff` | `Kamp/EANegationFix/VecEANegFix.lean` |
| P3 point merge | point-channel merge variants (0,1)/(0,2) | `NfMultiAnchorBridge/AggregatePointMergeK1.lean` |
| E1 fiber kit | single-fiber adjudication kit | `NfMultiAnchorBridge/ExteriorFiberKitK1.lean` |
| E2-E4 past nav | `CExtPast_correct` (+ `CExtPast_offGate_false`, `CExtPast_inconsistent_false`) | `NfMultiAnchorBridge/ExteriorNavPastK1.lean` |
| E5-E6 future nav | `CExtFut_correct` (+ `CExtFut_offGate_false`, `CExtFut_inconsistent_false`) | `NfMultiAnchorBridge/ExteriorNavFutK1.lean` |
| Off-diag population | `aggPop1_correct`; k=1 arm lemmas + `ShapeCertificatesK1` | `NfMultiAnchorBridge/AggregateOffDiagK1.lean` |
| PriorINF append | `HasAttainedSUP` (additive) | `Kamp/PriorINF.lean` |

### Post-R1 module DAG (P2 stack)

```
Kamp/VecEAConjFull.lean  (P1; also imported by leaves below)
        │
Kamp/EANegationFix/OnBuilder.lean      (imports VecEAConjFull, EANegation, EANegationClosure)
        │
Kamp/EANegationFix/BoundedFix.lean
        ├── Kamp/EANegationFix/BoundedFixAnchored.lean
        └── Kamp/EANegationFix/ConcatPin.lean
                │ (both)
Kamp/EANegationFix/NegFixOne.lean      (imports BoundedFixAnchored, ConcatPin)
        │
Kamp/EANegationFix/NegFix.lean         (imports NegFixOne, ConcatPin, BoundedFixAnchored, VecEAConjFull)
        │
Kamp/EANegationFix/VecEANegFix.lean    (imports NegFix, VecEAConjFull)

Kamp/EANegationFix.lean = pure re-export SHIM (imports all seven leaves, declares nothing).
Leaves never import the shim or any NfMultiAnchorBridge/* — acyclicity verified Phase 17.
Consumers may import the shim (as NfMultiAnchorBridge.lean does) or individual leaves.
```

## 2. Axiom-check transcript (Phase 17, lean_verify, fully qualified)

Every check returned `{"axioms": ["propext", "Classical.choice", "Quot.sound"], "warnings": []}` —
exactly the three standard axioms, no `sorryAx`, no warnings. Prefix
`K := Bimodal.Metalogic.WeakCanonical.Kamp`:

| # | Theorem | Result |
|---|---|---|
| 1 | `K.kampArm_past_k0_correct` | `[propext, Classical.choice, Quot.sound]` |
| 2 | `K.kampArm_diag_k0_correct` | `[propext, Classical.choice, Quot.sound]` |
| 3 | `K.kampArm_future_k0_correct` | `[propext, Classical.choice, Quot.sound]` |
| 4 | `K.kampArm_diag_k1_correct` | `[propext, Classical.choice, Quot.sound]` |
| 5 | `K.kampArm_past_k1_correct` | `[propext, Classical.choice, Quot.sound]` |
| 6 | `K.kampArm_future_k1_correct` | `[propext, Classical.choice, Quot.sound]` |
| 7 | `K.aggPop1_correct` | `[propext, Classical.choice, Quot.sound]` |
| 8 | `K.CExtPast_correct` | `[propext, Classical.choice, Quot.sound]` |
| 9 | `K.CExtFut_correct` | `[propext, Classical.choice, Quot.sound]` |
| 10 | `K.BracketFormula.conjFull_iff` | `[propext, Classical.choice, Quot.sound]` |
| 11 | `K.VVecEA2.conjFull_iff` | `[propext, Classical.choice, Quot.sound]` |
| 12 | `K.BracketFormula.negFix_iff` | `[propext, Classical.choice, Quot.sound]` |
| 13 | `K.VecEA2.negFix_iff` | `[propext, Classical.choice, Quot.sound]` |
| 14 | `K.VVecEA2.negFix_iff` | `[propext, Classical.choice, Quot.sound]` |
| 15 | `K.negChainOn_iff` | `[propext, Classical.choice, Quot.sound]` |
| 16 | `K.negBoundedRightFix_iff` | `[propext, Classical.choice, Quot.sound]` |
| 17 | `K.negBoundedLeftFix_iff` | `[propext, Classical.choice, Quot.sound]` |
| 18 | `K.negBoundedRightFixAnchored_iff` | `[propext, Classical.choice, Quot.sound]` |
| 19 | `K.negBoundedLeftFixAnchored_iff` | `[propext, Classical.choice, Quot.sound]` |
| 20 | `K.BracketFormula.concatPin_holds_iff` | `[propext, Classical.choice, Quot.sound]` |
| 21 | `K.VBracketFormula.concatPin_holds_iff` | `[propext, Classical.choice, Quot.sound]` |
| 22 | `K.NegFixGateProbe.caseB4_holds` | `[propext, Classical.choice, Quot.sound]` |

Item 22 doubles as the gate-necessity compile check: the ℤ B4 counterexample still compiles and
verifies clean.

## 3. Full-DoD verification results (Phase 17)

- **Full `lake build` GREEN**: 1751 jobs, exit 0, before AND after the Base.lean docstring edit.
  Only pre-existing warning: unused variable `q` in `Automation/DatasetGenerator.lean:2125`
  (outside task territory).
- **Guard audit (subject-anchored over all 73 `task 350` commits)**:
  - Files touched: only `Kamp/EANegationFix(.lean|/…)`, `Kamp/NfMultiAnchorBridge(.lean|/…)`
    (Base, AggregateHookDischarge, AggregatePointMergeK1, ExteriorFiberKitK1, ExteriorNav{Past,Fut}K1,
    AggregateOffDiagK1), `Kamp/VecEAConjFull.lean`, `Kamp/PriorINF.lean` (sanctioned additive
    `HasAttainedSUP` append) + task artifacts.
  - **NO** changes to the seven frozen files (SharedWitness, SubBracket2V, OuterGate,
    ExteriorBracket, ExteriorZoneTriage, ExteriorNegation, ExteriorNegationPast).
  - **NO** `KampPrior.lean` changes by task 350. (Note: a body-text `--grep "task 350"` search
    surfaces commit 8a7d504ec touching KampPrior — that is a **task 358** commit whose message body
    cites task 350's lemmas; subject-anchored filtering excludes it.)
  - **NO** `ExteriorPinnedConverseK.lean` / `ExteriorPinnedConversePastK.lean` changes (G6).
  - KampPrior live sorry count: exactly **2** (`:361`, `:364` — task-358 territory, untouched).
  - `nf_char3_deeper_split`: **zero term-level uses** in all task modules (only docstring
    prohibition notes + the pre-existing definition at `Base.lean:603`).
  - Sorry census over all task-350 modules: **0** live sorries (the 6 in `Kamp/` overall are
    KampPrior :361/:364, `Kamp/Boneyard/*` legacy, and `EANegation.lean` :1090/:1249 — all
    pre-existing, provenance task 305, June 2026).
  - Vacuous-definition scan: **0**. New `axiom` declarations: **0** (the two `^axiom` grep hits are
    prose lines in Boneyard docstrings, April 2026).
- **R1 relocation-only audit**: line-level diff over R1.1-R1 commits
  (`f4ab474b6^..478312356`): **zero** non-blank monolith lines removed without verbatim re-addition
  in a leaf; the only net additions are per-leaf `namespace`/`open`/`end` scaffolding, module
  docstrings, and the shim. Monolith −2900 lines, leaves +2956, no proof-body edits.
- **R1 acyclicity**: no `EANegationFix/*` leaf imports the shim or any `NfMultiAnchorBridge/*`
  (leaf imports: sibling leaves + `VecEAConjFull` + pre-existing `EANegation`/`EANegationClosure`
  only). The aggregator's shim import (`import …Kamp.EANegationFix`, line 78 at the R1 completion
  commit) is unchanged; it sits at `NfMultiAnchorBridge.lean:119` today only because later
  sanctioned phases (14a/15/16) inserted their own import lines above it.

## 4. Base.lean citability doc-hooks (Phase 17, docstring-only)

The two stale k=1 blocker notes were replaced (no proof/def body changed; working-tree diff
verified free of code-shaped lines):

- `nf_char2_past_formula_correct` docstring (was `Base.lean:1284`): blocker note → DELIVERED
  record (`kampArm_past_k1(_correct)` in `AggregateOffDiagK1.lean`, blocker
  `blk-350-p4-offdiag-k1-aggregate` CLOSED via `VVecEA2.conjFull_iff`) + the **full task-350 name
  map**: six arm lemmas, P1/P2/P3 primitives, and the post-R1 `EANegationFix/` module DAG.
- `nf_char2_future_formula_correct` docstring (was `Base.lean:1494`): blocker note → DELIVERED
  record (`kampArm_future_k1(_correct)`) + cross-reference to the name map above.

## 5. Task-309 Phase-18b consumption instructions

1. **Do not thread the `h_quant` binder** of `nf_char2_{past,future}_formula_correct`. Consume the
   skeleton-shaped conclusions by name (table in section 1). The k=0 pattern to follow is task
   358's `kampPrior_case1_arm_k0` (`KampPrior.lean`, commit 8a7d504ec): assemble the three arm
   formulas with `Formula.or` and discharge via `kampPrior_case1_trichotomy_assemble` + the three
   `_correct` lemmas.
2. **Ambient k=1**: same recipe with the k=1 triple — `kampArm_diag_k1_correct`
   (`AggregateHookDischarge.lean`) + `kampArm_{past,future}_k1_correct`
   (`AggregateOffDiagK1.lean`), at `sub_nf : NormalForm sig 2 2` / generic-site index `1 + 1`;
   the `ShapeCertificatesK1` examples certify the trichotomy-disjunct shapes verbatim.
3. **Imports**: `import …Kamp.NfMultiAnchorBridge` (aggregator) suffices; or import
   `AggregateHookDischarge` + `AggregateOffDiagK1` directly. For P2 primitives import the shim
   `…Kamp.EANegationFix` or individual leaves (never create a leaf → aggregator import).
4. **k ≥ 2 arms** additionally consume the rungK seam obligations (task-358 plan rows 5-6, 8-11) —
   out of task-350 scope.

## 6. Blocker-resolution record

- `blk-350-p4-offdiag-k1-aggregate` — **CLOSED**. Obstruction: the k=1 off-diagonal aggregate
  needed the biconditional (iff-form) `VVecEA2` conjunction population (Rabinovich Lemma 3.4),
  absent at plan v2. Resolution path: P1 `VVecEA2.conjFull_iff` (Phase 7) → P2 negation stack with
  two-sided `B_i` legs and the B4-gated `negFix` recursion (Phases 8-11, gate necessity certified
  by `NegFixGateProbe.caseB4_holds` on ℤ) → P3/E1-E6 exterior carriers (Phases 12-15) →
  `aggPop1_correct` population + `kampArm_{past,future}_k1_correct` (Phases 16a/16b). All landed
  sorry-free on the three standard axioms.

## 7. Phases executed (this dispatch: Phase 17 only)

Phase 17 (G): full-DoD verification + citability doc-hooks + wrap-up. Prior phases 7-16b and
R1.1-R1.6 were completed in earlier dispatches (see `handoffs/` and prior summaries
`03_phase-*.md`). Plan deviations in this phase: none — all checklist items executed as written.

## 8. Sorry inventory

Empty. Zero live sorries across all task-350 modules; `skeleton = false`.
