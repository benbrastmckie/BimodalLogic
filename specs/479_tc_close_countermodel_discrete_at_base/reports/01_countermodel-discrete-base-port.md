# T-C: closing `countermodel_discrete` via the v2 blueprint at `ℚ ×ₗ ℤ`

**Task**: 479 · **Type**: lean4 · **Session**: sess_1787655570_fed45b · **Dispatch**: 1
- **Started**: TBD
- **Completed**: TBD
- **Effort**: TBD
- **Dependencies**: TBD
- **Sources/Inputs**: TBD
- **Artifacts**: TBD
- **Standards**: TBD

All claims below were re-verified **by symbol against the live source** on a green tree
(`lake build` → "Build completed successfully (2492 jobs)") and by a compiled probe at
`specs/479_tc_close_countermodel_discrete_at_base/verification/probe.lean`.

---

## 0. Headline

The port is viable and mechanical **with one structural correction the task description does
not anticipate**: the predecessor lemma is **downstream** of `countermodel_discrete`'s current
home, so the theorem must be **relocated to a new module**, not edited in place. Details in
§6 — this is the only blocker found, and it is a file-layout fix, not a mathematical one.

Two smaller deltas from the stated plan (§4, §5): the predecessor delivers `goodGroupable`
(carrier = the **whole** group), not `good` (a `ZIntervalStructure` with `Option` bounds), so
roughly 40 lines of the v2 body (`h_bounds`/`h_lo`/`h_hi`/`toCarrier`) **delete** rather than
port; and every `omega` in the `untl`/`snce` cases must become an ordered-group lemma, since
`omega` does not run at `ℚ ×ₗ ℤ`.

---

## 1. `WeakCanonical.countermodel_discrete` — exact live statement

`FormalSystem/Metalogic/WeakCanonical/Transfer.lean`, declaration header at **:1069**, `sorry`
token at **:1102**, section header at **:1049** (the task's hints — ~:1069 and ~:1084 — were
close; re-located by symbol).

```lean
theorem countermodel_discrete (A : Set Formula)
    (h_mcs : SetMaximalConsistent (fc := FrameClass.Base) A)
    (φ : Formula) (h_neg_in : φ.neg ∈ A)
    (h_box_discrete : Formula.box nextTop ∈ A) :
    ∃ (D : Type) (_ : AddCommGroup D) (_ : LinearOrder D) (_ : IsOrderedAddMonoid D)
      (_ : Nontrivial D) (F : TaskFrame D) (TM : TaskModel F)
      (τ : WorldHistory F) (_ : τ.IsTotal) (t : D),
      ¬TruthAt TM τ t φ
```

Namespace: `FormalSystem.Metalogic.WeakCanonical`. Sole consumer:
`FormalSystem/Metalogic/BXCanonical/Completeness.lean:229`, inside
`BXCanonical.completeness`, destructured as
`⟨D, _, _, _, _, F, TM, τ, h_tot, t, h_not_true⟩` and fed to `h_valid D F TM τ h_tot t`.
Nothing else in `FormalSystem/` references it outside docstrings.

Probe-confirmed axiom sets on the live tree:

| declaration | axioms |
|---|---|
| `BXCanonical.completeness` | `[propext, sorryAx, Classical.choice, Quot.sound]` |
| `WeakCanonical.countermodel_discrete_reynolds_v2` | `[propext, Classical.choice, Quot.sound]` |
| `WeakCanonical.companionGeneral` | `[propext, Classical.choice, Quot.sound]` |
| `WeakCanonical.companionChronicle` | `[propext, Classical.choice, Quot.sound]` |

## 2. The predecessor lemma (task 478) — real name and signature

**`FormalSystem.Metalogic.WeakCanonical.companionChronicle`**, in
`FormalSystem/Metalogic/WeakCanonical/GroupModel/GroupableCompanion.lean:413`:

```lean
theorem companionChronicle {fc : FrameClass} (A : Set Formula)
    (h_mcs : SetMaximalConsistent (fc := fc) A)
    (h_box : Formula.box nextTop ∈ A)
    (φ : Formula) (k : ℕ) :
    goodGroupable (mkSigFrom φ) k (limitdomMonadicStructure A h_mcs φ)
```

**No `h_fc` hypothesis** — that is the whole point of the predecessor, and it is confirmed by
signature. It supplies `SuccOrder`/`PredOrder` on the limitdom carrier internally via
`box_discrete_gives_discreteness` and delegates to `companionGeneral`.

Call-site shape vs. the v2 original (`ReynoldsBridge.lean:963`):

```lean
-- v2 (Discrete):  limitdom_is_good N hN_mcs (le_refl _) hN_box φ k   : good (mkSigFrom φ) k …
-- port  (Base ):  companionChronicle N hN_mcs hN_box φ k             : goodGroupable (mkSigFrom φ) k …
```

The `(le_refl _)` argument — the `h_fc : FrameClass.Discrete ≤ fc` slot — simply disappears.

### `good` vs `goodGroupable` — the consequential difference

```lean
-- IntegerModel/GoodStructures.lean:78
def good sig k M := ∃ Z : ZIntervalStructure sig, KEquiv sig k M (Z.toOrdered sig)
-- GroupModel/GoodGroupable.lean:151
def goodGroupable sig k M := ∃ Q : QZStructure sig, KEquiv sig k M (Q.toOrdered sig)
```

Same `∃`, same `KEquiv`, same orientation (target on the right), so `.choose`/`.choose_spec`
port verbatim. But `QZStructure.toOrdered_carrier : (Q.toOrdered sig).carrier = (ℚ ×ₗ ℤ)` is
**`rfl`** (`GoodGroupable.lean:145`, re-verified in the probe), whereas
`ZIntervalStructure.intervalCarrier` is a `lo`/`hi`-carved subtype. Consequences in §5.

## 3. `countermodel_discrete_reynolds_v2` — fc-genericity audit of every step

Body: `ReynoldsBridge.lean:936–1352` (416 lines). Every symbol it invokes, classified:

### 3a. Already `{fc : FrameClass}`-generic (ports with `FrameClass.Discrete` → `FrameClass.Base`, no other change)

| symbol | site |
|---|---|
| `limitdomMonadicStructure` | `ReynoldsBridge.lean:76` |
| `limitdomMonadicStructureSuccOrder` / `…PredOrder` | `ReynoldsBridge.lean:119` |
| `limitdom_temporal_truth_effective` | `ReynoldsBridge.lean:155` |
| `limitdom_root_neg_truth` | `ReynoldsBridge.lean:689` |
| `zero_mem_limit_dom` | `ChronicleConstruction.lean:691` |
| `limit_f_zero` | `ChronicleConstruction.lean:679` |
| `box_stable_in_limit_f` | `ChronicleToCountermodelBasic.lean:319` |
| `limitDomSubtype_countable` | `ChronicleToCountermodelBasic.lean:84` |
| `box_discrete_gives_discreteness` | `ChronicleToCountermodelBasic.lean:1176` |
| `bx_modal_witness_fc` | `ChronicleTypes.lean:118` |
| `liftBase` | `ChronicleTypes.lean:78` (`liftBase FrameClass.Base d` is a no-op lift; `base_le Base` is `trivial`) |
| `truth_transfer` | `Transfer.lean:354` — stated over arbitrary `OrderedMonadicStructure` |
| `table_correctness`, `table_depth_bound`, `k_equiv_preserves_sentence`, `eval`, `TemporalTruth` | `Table.lean` / `NEquivalence.lean` — structure-generic |
| `mkAtomMapFwd_section`, `effectiveFormula_id_of_sub`, `predFormulas_operator_depth_le` | syntax-only |

### 3b. The only Discrete-bound link — confirmed

`limitdom_is_good` (`ReynoldsBridge.lean:361`) carries `h_fc : FrameClass.Discrete ≤ fc` and
spends it on exactly two callees:

- `limitdom_semantic_prior_UZ` (`ReynoldsBridge.lean:262`, signature carries `h_fc`)
- `limitdom_semantic_prior_SZ` (same file, same shape)

which invoke `Axiom.prior_UZ` / `Axiom.prior_SZ`. `Axiom.minFrameClass`
(`ProofSystem/Axioms.lean:591-593`) tags exactly three axioms `.Discrete`: `prior_UZ`,
`prior_SZ`, `z1`. Everything else falls under `| _ => .Base`. The task's claim is exact.

`Axiom.modal_t` — used once in the v2 box case (`ReynoldsBridge.lean:1245`, its only occurrence
in the file) via
`DerivationTree.axiom [] _ (Axiom.modal_t ψ) trivial` — is a `.Base` axiom, and
`FrameClass.le` has `| .Base, _ => True`, so the `trivial` membership proof survives at
`fc := FrameClass.Base` unchanged.

### 3c. `ℤ`-bound (must be replaced, see §5)

`multiFamTaskFrame`, `multiFamHistory`, `multiFamHistory_total`, `multiFam_total_eq`
(all `ReynoldsBridge.lean:764-935`), `toCarrier` (`:759`),
`z_interval_carrier_contains_all` (`:563`), and every `omega` call.

## 4. `multiFamTaskFrameGen` — signature and instance obligations

`FormalSystem/Metalogic/Algebraic/FlowFrame.lean:150`:

```lean
noncomputable def multiFamTaskFrameGen (D : Type) [AddCommGroup D] [LinearOrder D]
    [IsOrderedAddMonoid D] [Nontrivial D] (FamIdx : Type) [Nonempty FamIdx] : TaskFrame D
```

Companions, all `[Nontrivial D] {FamIdx} [Nonempty FamIdx]`:

- `multiFamHistoryGen f w₀` (`:190`) — `domain := fun _ => True`, `states t _ := (f, w₀ + t)`
- `multiFamHistoryGen_total` (`:217`) — `fun _ => trivial`
- `multiFamGen_total_eq` (`:372`) — `∃ f w₀, σ = multiFamHistoryGen f w₀` for total `σ`
- `multiFamGen_total_eq_range` (`:410`)

**Instance obligations at `D := ℚ ×ₗ ℤ` — all four discharge, probe-verified**
(`AddCommGroup`, `LinearOrder`, `IsOrderedAddMonoid`, `Nontrivial` all `inferInstance`).
These are exactly the four binders `valid` (`Semantics/Validity.lean:94`) requires, and they
are already a compile-time invariant of two existing modules —
`GroupModel/GoodGroupable.lean:118-121` (the "Carrier gate") and
`BXCanonical/DiscreteCarrierProbe.lean:66-69`.

**Import**: `Mathlib.Algebra.Order.Monoid.Prod` is required and only required for the lex
`IsOrderedAddMonoid` instance. It arrives **transitively** through
`GroupModel/GoodGroupable.lean` (which the new module gets via `GroupableCompanion`), so an
explicit import is optional but recommended for legibility.

## 5. Base vs. Discrete existential — precise diff

```
countermodel_discrete_reynolds_v2 (Discrete)     countermodel_discrete (Base)
─────────────────────────────────────────────    ────────────────────────────────
∃ (D : Type)                                     ∃ (D : Type)
  (_ : AddCommGroup D)                             (_ : AddCommGroup D)
  (_ : LinearOrder D)                              (_ : LinearOrder D)
  (_ : IsOrderedAddMonoid D)                       (_ : IsOrderedAddMonoid D)
  (_ : Nontrivial D)                               (_ : Nontrivial D)
  (_ : SuccOrder D)                       ←── DROPPED
  (_ : PredOrder D)                       ←── DROPPED
  (_ : IsSuccArchimedean D)               ←── DROPPED
  (_ : IsPredArchimedean D)               ←── DROPPED
  (F : TaskFrame D) (TM : TaskModel F)             (F : TaskFrame D) (TM : TaskModel F)
  (τ : WorldHistory F) (_ : τ.IsTotal) (t : D)     (τ : WorldHistory F) (_ : τ.IsTotal) (t : D)
, ¬TruthAt TM τ t φ                              , ¬TruthAt TM τ t φ
```

14 binders → 10. Confirmed against the live `valid` (`Validity.lean:94`), which binds exactly
those four instances and no Archimedean condition. The Base target is strictly weaker; the
final `refine ⟨…⟩` drops four `inferInstance` slots. (`ℚ ×ₗ ℤ` in fact *has* `SuccOrder` and
`PredOrder`, but not `IsSuccArchimedean` — irrelevant, since none is demanded.)

### Body-level deltas the carrier change forces

**(i) ~40 lines delete.** `h_bounds` (via `z_interval_carrier_contains_all`), `h_lo`, `h_hi`
(`ReynoldsBridge.lean:971-987`) and every `toCarrier (h_lo f) (h_hi f) e` all vanish: with
`(Q.toOrdered sig).carrier ≡ ℚ ×ₗ ℤ` by `rfl`, the injection is the identity and every
`toCarrier … (w₀ + t)` becomes plain `w₀ + t`. The `Subtype.ext`/`.val` bookkeeping goes with
it, as does the `2 ≤ k` side condition those lemmas needed.

**(ii) every `omega` must be replaced.** The `untl` (`:1278-1312`) and `snce` (`:1313-1350`)
cases carry 16 `omega` calls and 16 `toCarrier` applications doing ℤ arithmetic. At `ℚ ×ₗ ℤ` the replacements are:

| v2 (`ℤ`, `omega`) | port (`ℚ ×ₗ ℤ`) — probe-verified |
|---|---|
| `(w₀ + t : ℤ) < w₀ + s` from `t < s` | `add_lt_add_iff_left w₀` (`example (w t s : ℚ ×ₗ ℤ) : w + t < w + s ↔ t < s := add_lt_add_iff_left w` ✓) |
| `w₀ + (sc.val - w₀) = sc` | `by abel` (`example (w s : ℚ ×ₗ ℤ) : w + (s - w) = s := by abel` ✓) |
| `0 + s₀.val = s₀.val` | `zero_add` |
| witness extraction `rc.val - w₀` | `rc - w₀` |

The structure of both cases is otherwise unchanged: the correspondence map is
`r ↦ w₀ + r`, an order-isomorphism `D ≃o D` on any ordered group, exactly as `+ w₀` was on
`ℤ`. Note `TruthAt`'s `untl`/`snce` clauses (`Semantics/Truth.lean:165-168`) quantify over
**all** `s : D`, not over `τ.domain`, so the correspondence with `TemporalTruth` over the
full carrier is exact with no domain side conditions.

**(iii) `TM` valuation.** `QZStructure.interp : sig.preds → (ℚ ×ₗ ℤ) → Prop`, so
`fun w atom => (getQ w.1).interp (mkAtomMapFwd φ (.atom atom)) w.2` types directly at
`w : FamIdx × (ℚ ×ₗ ℤ)`. `QZStructure.toOrdered` sets `interp p x := Q.interp p x`, so the
`atom` case of the induction stays definitional, as in v2.

**(iv) box case unchanged.** Steps A1–A5, B, C of the forward direction and steps 1–7 of the
backward direction touch only `LimitF`/`KEquiv`/`table` machinery, all fc-generic and all
carrier-agnostic. The box surrogates remain rigid across box-equivalent families by S5,
exactly as the task states. `multiFam_total_eq` → `multiFamGen_total_eq` is the only edit.

## 6. BLOCKER (resolvable): import cycle — the theorem must be relocated

Verified import graph:

```
Transfer.lean                    (hosts countermodel_discrete, :1069)
   ↑ imported by
IntegerModel/ReynoldsBridge.lean (imports FormalSystem.Metalogic.WeakCanonical.Transfer)
   ↑ imported by
GroupModel/GroupableCompanion.lean (imports …IntegerModel.ReynoldsBridge)
                                   (hosts companionChronicle, :413)
```

`Transfer.lean` is **strictly upstream** of `GroupableCompanion.lean`. Adding
`import …GroupModel.GroupableCompanion` to `Transfer.lean` creates a cycle and will not
elaborate. `countermodel_discrete` **cannot be closed in place**.

### Recommended resolution (preserves the fully-qualified name, zero call-site churn)

1. Create `FormalSystem/Metalogic/WeakCanonical/GroupModel/CountermodelBase.lean` with
   ```lean
   import FormalSystem.Metalogic.WeakCanonical.GroupModel.GroupableCompanion
   import FormalSystem.Metalogic.Algebraic.FlowFrame
   ```
   (no cycle: `FlowFrame.lean` imports only `Semantics/`, `Bundle/`, `Syntax/`, `Theorems/`).
2. Declare the ported theorem there under `namespace FormalSystem.Metalogic.WeakCanonical`,
   with the **byte-identical statement** of §1. The fully-qualified name
   `FormalSystem.Metalogic.WeakCanonical.countermodel_discrete` is thereby preserved, so
   `Completeness.lean:229` needs **no edit at all**.
3. Delete the theorem and its `/-! ## countermodel_discrete — the one live sorry -/` section
   header from `Transfer.lean:1049-1102`.
4. Add `import …GroupModel.CountermodelBase` to `FormalSystem/Metalogic/WeakCanonical.lean`
   and demote the existing "CI edge only … leaf" comment block (`WeakCanonical.lean:50-70`)
   — `GroupableCompanion` stops being a leaf once this lands.
5. Reachability from `Completeness.lean` is already satisfied: it imports
   `FormalSystem.Metalogic.WeakCanonical` (the aggregator, which imports
   `GroupableCompanion` at `:70`) **and** `FormalSystem.Metalogic.Algebraic.FlowFrame`.
   No import edit is needed there.

An alternative — moving `truth_transfer` out of `Transfer.lean` to break the cycle upstream —
is strictly worse: `truth_transfer` has many consumers and the churn is unbounded. Do not.

## 7. Verification obligations at acceptance

Beyond `lake build` green and no new sorry/axiom:

1. `#print axioms FormalSystem.Metalogic.WeakCanonical.countermodel_discrete` →
   `[propext, Classical.choice, Quot.sound]`.
2. `#print axioms FormalSystem.Metalogic.BXCanonical.completeness` → same three; **no
   `sorryAx`**. (Nothing in `FormalSystem/` consumes `completeness` itself, so no further
   taint propagation to audit — verified by grep.)
3. **`scripts/check-module-invariants.sh` needs two edits, or C2 and C3 both hard-fail:**
   - **C2** (`:128`) pins the literal baseline string
     `'FormalSystem.Metalogic.BXCanonical.completeness' depends on axioms: [propext, sorryAx, Classical.choice, Quot.sound]`.
     Drop `sorryAx` from that line. C2 is coded as a HARD STOP on divergence.
   - **C3** (`:167-200`) asserts `SORRY_COUNT -eq 1` and pins
     `EXPECTED_FILE=FormalSystem/Metalogic/WeakCanonical/Transfer.lean`,
     `EXPECTED_THM=countermodel_discrete`. With the sorry gone, `SORRY_COUNT` is 0 and C3
     fails with *"expected exactly 1 structural sorry, found 0"*. Re-target C3 to assert
     **zero** structural sorries (and drop the now-dead `EXPECTED_FILE`/`EXPECTED_THM`
     machinery).

## 8. Docstrings that assert the stale sorry (complete inventory, grep-verified)

Every one of these must be updated; several assert "sole"/"only" claims that become false.

| file | lines |
|---|---|
| `FormalSystem/Metalogic.lean` | 49, 116-118 |
| `FormalSystem/Metalogic/WeakCanonical.lean` | 50-70 (CI-edge/leaf block), 96-102, 107-124 ("exactly one structural `sorry`" status section) |
| `FormalSystem/Metalogic/WeakCanonical/Transfer.lean` | 18-26 (module header), 1049-1067 (section header — removed with the theorem) |
| `FormalSystem/Metalogic/BXCanonical/Completeness.lean` | 41-50, 173, 177-188, 215, 382 |
| `FormalSystem/Metalogic/Decidability.lean` | 128-133 |
| `FormalSystem/Metalogic/WeakCanonical/PriorExpressivenessDense.lean` | 95 |
| `FormalSystem/Metalogic/WeakCanonical/RealModel/ShuffleReal.lean` | 43 |
| `FormalSystem/Metalogic/BXCanonical/DiscreteCarrierProbe.lean` | 27-33 (describes the obligation as still open) |
| `FormalSystem/Metalogic/BXCanonical/Chronicle/ChronicleToCountermodel.lean` | 70-85 (route narrative) |

## 9. Zero-debt statement

No step of this port requires a `sorry`, a new axiom, or a weakening of
`countermodel_discrete`'s statement. Every mathematical input is already proved and
axiom-clean on the live tree (§1 table). The single obstruction found (§6) is a module-layout
problem with a mechanical resolution that preserves the theorem's fully-qualified name. If the
port nonetheless fails to elaborate, the failure will be a concrete type mismatch to report —
not a gap to defer.

## 10. Non-goals honoured

The O1 isomorphism and `succ_cofinal` were not re-examined (settled negatively, report 01 of
task 422). `companionChronicle` was consumed by signature, not re-derived. No
construction-level work in `ChronicleConstruction.lean` or `PointInsertion.lean` is entailed.

## 11. Artefacts

- `specs/479_tc_close_countermodel_discrete_at_base/verification/probe.lean` — the compiled
  probe backing §1's axiom table, §4's instance obligations, and §5's arithmetic
  replacements. (Its two reported errors are `noncomputable` annotations missing on two
  throwaway `example`s; the elaboration those examples test succeeded.)

## 12. References

- Governing document: `specs/422_build_discrete_chronicle_over_non_archimedean_block_carrier_with_restricted_coherence/reports/02_o1-verdict-k-equivalence-transfer.md` §3, §6.
- Predecessor delivery: `FormalSystem/Metalogic/WeakCanonical/GroupModel/GroupableCompanion.lean`.
- Blueprint: `FormalSystem/Metalogic/WeakCanonical/IntegerModel/ReynoldsBridge.lean:936-1352`.
- Doets 1987 ch. 7 (pp. 89-93); Reynolds 1992 §8 (printed p.185) — as cited by the two modules above.
