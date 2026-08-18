# Repo-Wide `FrameClass.Base` Audit

- **Task**: 450 - frame_class_parameterization_restricted_mcs
- **Deliverable**: (f) — the audit table, as a deliverable artifact
- **Baseline commit**: `d687668ba` (pre-task tree)
- **Audit commit**: post-Phase-11 tree
- **Method**: occurrence counts (not line counts), classified by whether the occurrence lies in
  a code region or in a `/- -/` / `/-- -/` / `--` comment region, by
  `scratchpad/census.py`. Boneyard is excluded throughout.

## 0. Why a token census understates the surface (~4x)

`FrameClass.Base` grep hits are **not** the real measure of the Base-pinned surface. The
notations

```
notation:50 Γ " ⊢ " φ => DerivationTree FrameClass.Base Γ φ   -- ProofSystem/Derivation.lean:325
notation:50 "⊢ " φ    => DerivationTree FrameClass.Base [] φ  -- ProofSystem/Derivation.lean:330
notation:50 G " |-! " p => Derivable FrameClass.Base G p      -- ProofSystem/Derivable.lean:87
notation:50 "|-! " p    => Derivable FrameClass.Base [] p     -- ProofSystem/Derivable.lean:92
```

make every bare `⊢`/`|-!` a Base pin that produces **no grep hit at all**. Under
`FormalSystem/Theorems/` the pre-task grep census was 29 `FrameClass.Base` tokens against
**211 Base-pinned declarations**. This audit therefore reports both:

| Accounting line | Pre-task | Post-task |
|---|---:|---:|
| `FrameClass.Base` occurrences in **code**, `FormalSystem/` + `Tests/` | 604 | 543 |
| `FrameClass.Base` occurrences in **doc/comment** | 70 | 97 |
| Grep-invisible bare-`⊢` pins under `FormalSystem/Theorems/` (declarations) | 211 | 0 |
| `FormalSystem/Theorems/` declarations carrying `{fc : FrameClass}` | 51 / 262 | **267 / 278** |

The doc/comment count **rose** (70 → 97). That is the intended direction: deliverable (e)
requires every surviving pin to carry a "why this class is essential" docstring line, and those
lines name `FrameClass.Base` in prose. Comment occurrences are never a defect; only code
occurrences are classified below.

## 1. Category summary

| Category | Code occurrences | Share |
|---|---:|---:|
| (i) legitimately Base-specific | 45 | 8.3% |
| (ii) generalised by this task (residual is a **default value**, not a pin) | 8 | 1.5% |
| (iii) deliberately deferred, with reason | 490 | 90.2% |
| **Total code occurrences** | **543** | 100% |

Every code occurrence in the live tree is accounted for by exactly one category; the totals
reconcile against the re-run census above.

## 2. Category (i) — legitimately Base-specific (45)

Each of these carries a `**Why `FrameClass.Base` is essential here**` docstring line as of
Phase 11.

| Site | Count | Why the class is essential |
|---|---:|---|
| `ProofSystem/Derivation.lean:325,330` — `Γ ⊢ φ` / `⊢ φ` notations | 2 | The notations *are* the Base convenience layer, by design. The polymorphic siblings `Γ ⊢[fc] φ` / `⊢[fc] φ` already exist (`:320`, `:320`); declarations move to those instead of the notations changing. |
| `ProofSystem/Derivable.lean:87,92` — `G \|-! p` / `\|-! p` notations | 2 | Same, for the `Prop`-valued derivability layer. |
| `ProofSystem/Axioms.lean:559` — order-shape regression `example` | 1 | Pins the exact shape of the `FrameClass` order so an edit to the `LE` instance cannot silently change axiom admissibility. `Base` is the subject. |
| `ProofSystem/Axioms.lean:600` — `FrameClass.base_le` | 1 | States that `Base` is the order's bottom element. `Base` is the subject, not a pin. This is the canonical Base-to-any-`fc` lift used repo-wide. |
| `Metalogic/Soundness.lean` — `axiom_valid`, `soundness`, `not_derivable_nil_bot` | 3 | Soundness and consistency are per-frame-class facts. `Base` pairs with unconditional validity `⊨ φ`; the wider classes have their own theorems (`soundness_dense_valid`, `soundness_discrete_valid`, `not_derivable_nil_bot_discrete`). |
| `Metalogic/SoundnessLemmas/FrameClassVariants.lean` — 6 admissibility splits | 6 | `h.minFrameClass ≤ FrameClass.Base` is the split that makes the conclusion hold with no order-theoretic instances on `D`. Two of the six are proof-internal `by_cases` inside `Discrete`-stated theorems. |
| `FrameConditions/Soundness.lean` — `soundness_over`, `soundness_linear`, `axiom_base_valid_linear` | 3 | "Sound on *every* linear temporal frame" is exactly the `Base` admissibility condition. |
| `FrameConditions/Compatibility.lean:181` — `axiom_base_implies_linear_compatible` | 1 | Linear-compatibility *is* Base admissibility; the hypothesis defines the class being characterised. |
| `Metalogic/BXCanonical/Completeness.lean` — `completeness` (+ 2 internal) | 3 | Completeness pairs a validity notion with the axiom set capturing it. `valid φ` is matched by the `Base` set; `completeness_dense` / `completeness_discrete` are the siblings. |
| `Metalogic/Decidability/Correctness.lean` — `fmp_completeness`, `fmp_incompleteness_witness` | 2 | Restatements of the two preserved FMP theorems (see §3). |
| `Metalogic/Decidability/FMP/FMP.lean` — `mcs_finite_model_property`, `fmp_contrapositive`, `fmp_size_bound` | 3 | **Deliverable (b) preserved assets.** Byte-identical to `d687668ba`; see §3. |
| `Metalogic/Decidability/FMP/Filtration.lean` — `setConsistent_empty` (`closureMCSBundle_nonempty` / `filteredWorld_nonempty` carry the same reason but no literal token) | 1 | These consume system consistency, a per-frame-class fact. Each is now the `Base` instance of a new `{fc}`-uniform `_of` variant that takes `¬ Derivable fc [] ⊥` as a hypothesis (see §4). The `instance` cannot carry that hypothesis, so it stays at `Base`. |
| `Metalogic/Decidability/ProofExtraction.lean` — 4 `minFrameClass ≤ Base` guards (`proofFromBot` uses the `.Base` short form, no literal token) | 4 | The extraction pipeline certifies the base decision procedure and emits `Base` trees throughout. |
| `Automation/ProofSearch/Core.lean:1148+` — axiom-admissibility guard | 1 | The search engine decides and certifies the base system; a `Dense`/`Discrete`-only axiom deliberately falls through to other strategies. |
| `Metalogic/Decidability/Propositional/` | 1 | Propositional-fragment decision procedure, same reason as `ProofExtraction`. |
| `Metalogic/Decidability/Verified/{Bridge,Termination}/` | 6 | Verified-decision-procedure bridge: emits `Base` certificates, same reason. |
| `Theorems/Combinators.lean:700` — `baseThm` | 1 | `Base` is the *source* of the lift `DerivationTree FrameClass.Base [] A → DerivationTree fc [] A`. Naming it is the point. |
| `Theorems/DiscreteUnfolding.lean:177,190,269,284` — `unfoldBackward`, `unfoldTableBackward` | 4 | Stated at `Base` because that is the **weakest** class at which they hold; they lift to any `fc` via `baseThm`. Documented in the module docstring. |

**Subtotal: 45.** (Row counts sum to 45 exactly.)

## 3. Deliverable (b): the three preserved theorems

`mcs_finite_model_property`, `fmp_contrapositive` and `fmp_size_bound`
(`Metalogic/Decidability/FMP/FMP.lean`) are theorems **about the Base system** and were never
edited. Verified byte-identical to the pre-task tree:

```
git show d687668ba:FormalSystem/Metalogic/Decidability/FMP/FMP.lean \
  | grep -A6 -E '^theorem (mcs_finite_model_property|fmp_contrapositive|fmp_size_bound) ' > old
grep -A6 -E '^theorem (mcs_finite_model_property|fmp_contrapositive|fmp_size_bound) ' \
  FormalSystem/Metalogic/Decidability/FMP/FMP.lean > new
diff old new     # -> no differences
```

Each gained a Phase-11 docstring paragraph; **no signature or proof line changed**. Hard-coding
`Discrete` in their place was explicitly rejected and was not done.

## 4. Category (ii) — generalised by this task (8 residual code occurrences)

These eight occurrences are `FrameClass.Base` appearing as an **optParam default value**, i.e.
they are the mechanism by which generalisation is backward-compatible, not a pin:

| Site | Declaration |
|---|---|
| `Core/RestrictedMCS/Basic.lean:71,78,275` | `RestrictedConsistent`, `RestrictedMCS`, `RestrictedConsistentSupersets` |
| `Decidability/FMP/ClosureMCS.lean:70,78` | `ClosureMCS`, `ClosureConsistent` |
| `Decidability/FMP/Filtration.lean:122,149,163` | `ClosureMCSBundle`, `ClosureMCSSetoid`, `FilteredWorld` |

All eight have the verified working spelling — a **trailing explicit**
`(fc : FrameClass := FrameClass.Base)` binder — giving e.g.

```
@RestrictedMCS : Formula → Set Formula → optParam FrameClass FrameClass.Base → Prop
```

Leading-explicit optParam and `variable`-level optParam both misassign positional arguments, and
an implicit optParam `{fc : FrameClass := FrameClass.Base}` is a Lean 4 syntax error; none of
those forms is used.

### What else category (ii) covers (no residual token)

| Layer | Pre-task | Post-task |
|---|---|---|
| `Core/RestrictedMCS/Basic.lean` | 21 code pins | 3 defaults; all 14 in-proof pins and all theorem statements `{fc}` |
| `Decidability/FMP/` (6 modules) | 31 code pins | 9 (3 defaults + 3 preserved statements + 3 documented consistency instances) |
| `Theorems/Propositional/` | 17 code pins, 5/33 declarations `{fc}` | 0 code pins, **40/40** declarations `{fc}` |
| `Theorems/` overall | 29 code pins, 51/262 declarations `{fc}` | 5 code pins (all category (i)), **267/278** declarations `{fc}` |
| `Core/{MaximalConsistent,MCSProperties}.lean` | 12 stale-prose pins on already-generic declarations | 0 |

The 11 `Theorems/` declarations without an `{fc}` binder are **not** Base pins:

- `ModalS5.iff` (1) — a `Formula`-level abbreviation; no frame class exists to parameterise.
- `ContextualProofs.mem0`–`mem3` (4) — `List.Mem` proofs about an arbitrary type; likewise.
- `DiscreteUnfolding` (6) — `succIndicator`, `unfoldForward`, `unfoldTableForward`,
  `noBlockingTriple` at `Discrete`; `unfoldBackward`, `unfoldTableBackward` at `Base`. Each is
  stated at the weakest class at which it holds. `succIndicator` derives `U(⊤,⊥)`, whose
  *negation* is `Axiom.dense_indicator`, so a `{fc}`-uniform version would collapse the dense
  system. Documented in the module docstring.

### New results this task added

- `Metalogic.not_derivable_nil_bot_discrete` (`Soundness.lean`) — deliverable (c): the Discrete
  system is consistent. Without it every Discrete-instantiated MCS result is vacuous.
- `FMP.setConsistent_empty_of` / `FMP.closureMCSBundle_nonempty_of` — the `{fc}`-uniform
  statements keyed to a `¬ Derivable fc [] ⊥` hypothesis. These are what make the
  parameterisation non-vacuous at `Discrete`: pass `not_derivable_nil_bot_discrete`.
- `Theorems/DiscreteUnfolding.lean` — deliverable (d), the promoted Discrete unfolding schema.
- `Theorems/Combinators`: `ctxMp`, `thmIn`, `wk`, `baseThm`, `topThm`, `andIntro`, `orElimBot`,
  `necG`, `guardMono`, `eventMono`; `Theorems/Propositional/Core`: `andFst`, `andSnd`,
  `orIntroL`, `orIntroR`, `orElim`, `topNegImpBot`, `untlBotFalse` — deliverable (d), the
  de-triplicated plumbing.

## 5. Category (iii) — deliberately deferred, with reason (489)

| Layer | Code occurrences | Reason for deferral |
|---|---:|---|
| `Metalogic/BXCanonical/` (incl. `Chronicle`, `Filtration`, `Quasimodel`; excludes `Completeness.lean`, counted in (i)) | 124 | Canonical-model construction. Far larger than the named deliverables and the FMP work does not depend on it. **Concrete payoff a future task inherits**: `BXCanonical/CanonicalModel.lean:426` documents that the existing chain machinery (`FwdSucc`, `BwdPred`, `IntChain`) is hardcoded to `Base`, and `:544-572` define parallel `fwdChainFc` / `bwdChainFc` / `IntChainFc` / `FwdSuccFc` / `BwdPredFc` twins with `fc` free — generalising the originals lets the twins be **deleted**. |
| `Metalogic/Bundle/` | 87 | Same construction layer, same reason. |
| `Metalogic/Algebraic/` | 87 | Same. |
| `Metalogic/WeakCanonical/` | 44 | Same. Also holds the repository's single live sorry (`countermodel_discrete`, `Transfer.lean`), which is untouched by this task. |
| `Automation/Tactics/Helpers.lean:1010,1062` | 2 | `tryModalK` / `tryTemporalK` build their subgoal type with `mkConst ``FrameClass.Base` instead of elaborating their own `_fc` argument, so they cannot fire at a non-`Base` class even though `generalizedModalK` / `generalizedTemporalK` are `{fc}`-polymorphic. A **real capability gap**, not a naming issue; fixing it is elaborator work orthogonal to this task. Both now carry a docstring saying exactly this. |
| `Tests/` | 146 | Unaffected: default-to-Base means every pre-existing test call site elaborates unchanged. Recorded here as a deliberate non-target, not an oversight. |

**Subtotal: 490.** (124 + 87 + 87 + 44 + 2 + 146 = 490.)

Three `Tests/` occurrences are *new*: `Integration/ProofSystemSemanticsTest.lean` gained
`(fc := FormalSystem.ProofSystem.FrameClass.Base)` at three call sites where the expected type
no longer determines `fc` after `TemporalDerived` became polymorphic. That is the plan's
prescribed repair (annotate the call site, never revert the generalisation) — 3 of the 146.

## 6. Non-goals confirmed untouched

- Filtered step relation, `filteredStep_fwd`/`bwd`, `FilteredStepFrame`, bi-lasso layer,
  semantic FMP — not implemented.
- No edits under `/home/benjamin/Philosophy/Papers/`.
- Discrete not reconciled with Dense/Dedekind; no joint class added. They remain incomparable in
  `FrameClass`'s order.
- The `⊢` / `Γ ⊢` / `|-!` notations themselves unchanged.

## 7. Final gate

| Check | Result |
|---|---|
| `lake build` | exit 0 |
| `lake build BimodalTest` | exit 0 |
| `scripts/check-module-invariants.sh` | ALL CHECKS PASSED (10 groups) |
| Live sorry count | exactly 1 (`countermodel_discrete`, `WeakCanonical/Transfer.lean`) — unchanged |
| New `axiom` declarations | 0 |
| Vacuous definitions introduced | 0 |
| Preserved FMP theorem statements | byte-identical to `d687668ba` |
| `#print axioms` on new/promoted declarations | `[propext, Classical.choice, Quot.sound]`, no `sorryAx` |
