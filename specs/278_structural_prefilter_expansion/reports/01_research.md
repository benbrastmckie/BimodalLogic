# Research Report: Structural Prefilter Expansion (Task 278)

**Date**: 2025-06-05
**Project**: BimodalLogic (Lean 4 v4.27.0-rc1)
**Task**: #278 — Expand structural prefilter with polarity analysis, 2-SAT skeleton, and temporal loop detection
**Dependencies**: Task 274

---

## 1. Current Prefilter Analysis

### 1.1 Location and Coverage
The current structural prefilter lives in `Theories/Bimodal/Automation/DatasetGenerator.lean` (lines 406–485). It consists of:

- `isUnsatBotTemporal` (lines 406–411): Detects `⊥` nested under `until`/`since`/`box` event arguments.
- `isStructurallyValid` (lines 427–430): Detects tautologies by identity (`φ → φ`) or valid consequent (`ψ → valid`).
- `structuralPrefilter` / `structuralPrefilterWithAxiom` (lines 448–485): Integration function with 6 axiom-attributed patterns:
  1. `structural_bot_temporal` — `unsat_bot_temporal φ → ψ`
  2. `structural_tautology` — `φ → structurally_valid ψ`
  3. `structural_double_box_bot` — `□□⊥ → ψ`
  4. `structural_modal_4` — `□□φ → φ` (T axiom applied twice)
  5. `structural_modal_t_weakening` — `□φ → (ψ → φ)`
  6. Box descent — `□(valid)` where inner is structurally valid

### 1.2 Coverage Estimate
The prefilter only matches **implication-shaped** formulas (`imp` at top level) or naked `box`. It never returns `some false` (invalid short-circuit). It operates via **structural pattern matching** (no recursive polarity walk, no propositional skeleton, no conjunct decomposition).

Based on the c7 benchmark notes (`EnumBenchmark.lean` lines 1–21), the current baseline valid fraction is **~3–4%** with exhaustive enumeration + axiom seeding. The prefilter likely catches <5% of all valid formulas at c7 because it only handles a handful of fixed shapes.

### 1.3 Integration Points
New patterns plug into `structuralPrefilterWithAxiom` via `match` clauses in the `imp` antecedent/consequent decomposition. The result is consumed in `labelFormula` (line 550) which sets:
- `decisionMethod := "structural_prefilter"`
- `proofReconstructionMethod := some ("structural_prefilter:" ++ axiomPattern)`

This existing telemetry is ideal for before/after comparison.

---

## 2. Feasibility Assessment for Each New Pattern

### 2.1 Polarity / Sign Analysis
**Goal**: Track positive/negative occurrences of subformulas. If a tautology appears only positively, it can be dropped; if a contradiction appears only negatively, the whole formula is valid.

**Feasibility**: ✅ **Medium complexity, high impact**

- The `Formula` AST has only 6 primitive constructors, so a polarity-tracking recursive function is straightforward to implement.
- `neg φ` is derived as `φ → ⊥`, so polarity flips at the left-hand side of `imp`.
- `and` / `or` are also derived from `imp` and `bot`, so polarity tracking must be aware of these common derived shapes.
- We need to define `polarity : Formula → Formula → Option Sign` (or a `collectPolarities` that returns a map of subformula → set of signs).
- A simple version can be implemented in ~40–60 lines of Lean.
- **Risk**: Edge cases with double-negation ( `¬¬φ` = `(φ → ⊥) → ⊥` ) where polarity flips twice. Must handle `and`/`or`/`diamond`/`all_future`/`some_future` as derived-operator patterns.

**Recommended approach**: Implement a `collectPolarities` function that returns a `List (Formula × Sign)` with duplicates. Then define `appearsOnlyPositively` and `appearsOnlyNegatively` predicates. Use these in `structuralPrefilter` to:
- Drop tautology subformulas that appear only positively (implication consequent simplification)
- Short-circuit when `bot` or `unsat_bot_temporal` subformulas appear only negatively

### 2.2 2-SAT Propositional Skeleton
**Goal**: Strip modal/temporal operators, extract the propositional 2-SAT skeleton. If the skeleton is unsatisfiable (detectable in O(n+e)), the full formula is unsatisfiable.

**Feasibility**: ⚠️ **High complexity, medium impact, most risky**

- The `Formula` type uses only `imp` and `bot` as primitives; `neg`, `and`, `or` are all derived. A 2-SAT skeleton is a conjunction of clauses with at most 2 literals. We need to:
  1. **Decompose top-level `and` conjuncts** (detect `and` derived shape)
  2. **Strip modal/temporal** (`box`, `untl`, `snce`) — treat them as opaque atoms or skip them entirely
  3. **Extract binary clauses** from `imp` / `or` / `neg` shapes
  4. **Build implication graph** (for each clause `a ∨ b`, add `¬a → b` and `¬b → a`)
  5. **Check SCCs** for `x` and `¬x` in the same component

- Mathlib has `Quiver.StronglyConnectedComponent` but no direct 2-SAT solver. We would need to write a custom graph + SCC checker in Lean.
- **Risk**: The implementation of an efficient SCC algorithm in pure Lean (with `List`-based adjacency) is non-trivial and may be slow for large skeletons. The benefit is limited to formulas whose propositional skeleton is already a 2-CNF and unsatisfiable — a relatively rare subset of c7 formulas.
- **Alternative**: Implement a **simpler** version: just collect top-level conjuncts and check for direct propositional contradictions (e.g., `p ∧ ¬p` as top-level conjuncts). This is much easier and may catch many of the same cases.

**Recommended approach**: **Phase 2 item.** Start with a lightweight propositional contradiction check (top-level conjuncts) before attempting full 2-SAT. If coverage is insufficient, then implement 2-SAT.

### 2.3 S5 Reflexive Shortcutting
**Goal**: `□φ ∧ ¬φ` as a top-level conjunct is immediately unsatisfiable. This generalizes the existing `modal_t_weakening` pattern.

**Feasibility**: ✅ **Low complexity, high impact**

- Detecting `and (box φ) (neg φ)` requires pattern matching on the derived `and` shape:
  `and a b = (a.imp (b.imp bot)).imp bot`
  So `and (box φ) (neg φ)` has a very specific `imp` shape that is matchable.
- Alternatively, we can write a `collectTopLevelConjuncts` helper that flattens nested `and` and returns a `List Formula`.
- Once conjuncts are collected, check if any pair is `(box φ, neg φ)`.
- The existing `matchAxiom` already knows `modal_t` (lines 378–383 in `ProofSearch/Core.lean`), so this is semantically sound.
- ~20 lines of pattern matching.

**Recommended approach**: Implement `collectTopLevelConjuncts` as a helper, then add a `hasBoxNegConflict` check. This is a quick win.

### 2.4 Temporal Loop Detection
**Goal**: `φ U ψ` co-occurring with `G(¬ψ)` as top-level conjuncts is unsatisfiable.

**Feasibility**: ✅ **Medium complexity, high impact**

- `G(¬ψ)` is `all_future (neg ψ)`. `φ U ψ` is `untl ψ φ` (Burgess convention: event first, guard second). Actually, in the code `untl event guard` means "guard holds until event becomes true". So `φ U ψ` = `untl φ ψ` where `φ` = event, `ψ` = guard. Wait, the code docs say: `untl φ ψ` — "ψ holds until φ becomes true". So `φ U ψ` in standard notation is `untl ψ φ` in the code.
- We need to check top-level conjuncts for the pair `(untl event guard, all_future (neg guard))`.
- `G(¬ψ)` means "at all future times, ¬ψ holds". But `φ U ψ` requires "ψ holds at some future time". These are contradictory.
- `S` (since) with `H(¬ψ)` is the past dual.
- ~30 lines of pattern matching with `collectTopLevelConjuncts`.

**Recommended approach**: Implement alongside `collectTopLevelConjuncts` in the same helper module. Add `hasUntilGuardConflict` and `hasSinceGuardConflict`.

### 2.5 Subformula Subsumption (Syntactic Implication Rules)
**Goal**: Add ~10 modal/temporal syntactic implication rules (e.g., `□φ` implies `φ` under T, `Gφ` implies `φ` at next time, etc.).

**Feasibility**: ✅ **Low complexity, high impact**

- Many of these are already encoded in `matchAxiom` (`ProofSearch/Core.lean`) but the prefilter only catches a few.
- Potential rules to add:
  1. `□φ → φ` (modal T) — already partially covered
  2. `□φ → □□φ` (modal 4) — already covered
  3. `Gφ → φ` (temporal T / reflexive future)
  4. `Hφ → φ` (temporal T / reflexive past)
  5. `Gφ → Fφ` (seriality / non-empty future)
  6. `Hφ → Pφ` (seriality / non-empty past)
  7. `φ → □◇φ` (modal B) — for specific shapes
  8. `Gφ → G(Gφ)` (temporal 4)
  9. `Hφ → H(Hφ)` (temporal 4 past)
  10. `F(Fφ) → Fφ` (temporal density-like)
- Each rule is a simple pattern match on `imp` left/right.
- ~60 lines total.

**Recommended approach**: Add these directly to `structuralPrefilterWithAxiom` as new `match` arms. This is the easiest and most reliable way to boost coverage.

---

## 3. Recommended Implementation Approach

### 3.1 Phase 1: Quick Wins (target ~+3% coverage)
1. **Implement `collectTopLevelConjuncts`** — flatten derived `and` shapes.
2. **Add S5 reflexive shortcutting** — `box φ` + `neg φ` conflict.
3. **Add temporal loop detection** — `untl`/`snce` + `all_future`/`all_past` neg guard conflict.
4. **Add 10 subsumption rules** — `Gφ → φ`, `Hφ → φ`, `Gφ → Fφ`, etc.
5. **Add `isValidConsequent` extension** — catch `φ → ⊤` and `φ → □⊤` as valid.

### 3.2 Phase 2: Polarity Analysis (target ~+2% coverage)
1. Implement `Formula.polarities` returning `List (Formula × Sign)`.
2. Add `isTautologyOnlyPositively` and `isContradictionOnlyNegatively` predicates.
3. Integrate into `structuralPrefilter` for:
   - Dropping tautology subformulas from consequents
   - Short-circuiting when `bot` or unsat temporal appears only negatively

### 3.3 Phase 3: Propositional Skeleton (target ~+1-2% coverage)
1. **Lightweight** (recommended first): `collectTopLevelConjuncts` + check for `p ∧ ¬p` and `φ ∧ (φ → ⊥)`.
2. **Full 2-SAT** (if needed): extract 2-CNF, build implication graph, implement SCC check. This is a significant undertaking and should only be pursued if Phase 1+2 does not reach the ~10% target.

### 3.4 Module Layout
```
DatasetGenerator.lean
  ├── Helpers (new)
  │   ├── collectTopLevelConjuncts
  │   ├── polaritySign
  │   ├── appearsOnlyPositively
  │   └── appearsOnlyNegatively
  ├── isUnsatBotTemporal (existing)
  ├── isStructurallyValid (existing, extend)
  ├── structuralPrefilterWithAxiom (extend with new patterns)
  └── structuralPrefilter (existing, auto-derived)
```

---

## 4. Relevant Mathlib / Codebase Lemmas and Tools

| Tool | Location | Relevance |
|------|----------|-----------|
| `Quiver.StronglyConnectedComponent` | `Mathlib.Combinatorics.Quiver.ConnectedComponent` | Potential building block for 2-SAT SCC check |
| `Formula.subformulas` | `Syntax/Subformulas.lean` | Already used for subformula closure; can be reused for polarity analysis |
| `Formula.atoms` | `Syntax/Formula.lean` | Set of atoms for freshness / propositional skeleton |
| `SignedFormula.pos/neg` | `Metalogic/Decidability/SignedFormula.lean` | Sign type already exists; could reuse for polarity |
| `matchAxiom` | `Automation/ProofSearch/Core.lean` | Pattern matching template for new subsumption rules |
| `decideAutoAdaptive` | `Metalogic/Decidability/DecisionProcedure.lean` | Decision procedure called after prefilter |
| `computeMetrics` / `PatternKey` | `Automation/SuccessPatterns.lean` | For structural indexing and before/after comparison |
| `labelBatch` / `computeBatchStats` | `Automation/DatasetGenerator.lean` | Ready-made pipeline for c7 testing |

### 4.1 No Existing SAT/2-SAT in Mathlib
The `leansearch` and `loogle` searches confirmed that Mathlib has graph theory (`Quiver.StronglyConnectedComponent`) but **no dedicated 2-SAT or SAT solver**. Any 2-SAT implementation must be built from scratch.

### 4.2 No Existing Polarity Analysis
There is **no polarity-tracking function** for `Formula`. The `SignedFormula` type is for tableau branches, not for static formula polarity. Must be implemented from scratch.

### 4.3 No Existing Conjunct Decomposition
While `FormulaMutator.lean` has `and_left`/`and_right` helpers (lines 339–344), there is no `collectTopLevelConjuncts` that flattens nested conjunctions. This needs to be written.

---

## 5. Risk Assessment

| Pattern | Risk Level | Edge Cases / Mitigation |
|---------|-----------|------------------------|
| **Subsumption rules** | 🟢 Low | Double-counting patterns already caught by `isStructurallyValid` or `isUnsatBotTemporal`. Mitigation: order checks correctly (specific before general). |
| **S5 shortcutting** | 🟢 Low | Must handle `and` derived shape correctly. `and` is `imp (imp a (imp b bot)) bot`. Test with `#eval` to confirm pattern matching. |
| **Temporal loop detection** | 🟡 Medium | `all_future` is derived as `neg (some_future (neg φ))`. Must match the derived shape or use `goalCategory`-level detection. `untl` with `Formula.top` guard is `some_future` and should be excluded from the loop check (it's a different operator). |
| **Polarity analysis** | 🟡 Medium | Double-negation flips polarity twice; `and`/`or` derived shapes complicate the walk. Must be exhaustive over all 6 primitives + common derived patterns. |
| **2-SAT skeleton** | 🔴 High | Complex to implement correctly and efficiently. Benefit may be marginal. **Mitigation**: implement lightweight propositional contradiction check first. Only build full 2-SAT if coverage gap remains. |

---

## 6. Testing Strategy: Before/After at c7

### 6.1 Test Harness
The project already has the ideal test harness in `EnumBenchmark.lean` and `DatasetGenerator.lean`:

1. **Generate c7 corpus**:
   ```lean
   let params : EnumParams := {
     maxComplexity := 7,
     maxModalDepth := 2,
     maxTemporalDepth := 2,
     atoms := [p, q, r],
     maxFormulas := 5000,
     samplingMode := .exhaustive,
     validSeedCount := 3000
   }
   let formulas ← generateFormulas params
   ```

2. **Label before and after**:
   ```lean
   let labeledBefore ← labelBatch formulas.take 1000
   -- apply prefilter changes
   let labeledAfter ← labelBatch formulas.take 1000
   ```

3. **Metrics to compare**:
   - `validCount` / `totalCount` — valid fraction
   - `decisionMethod == "structural_prefilter"` count — prefilter hit rate
   - `avgTimeMs` — average decision time (prefilter should reduce it)
   - `timeoutCount` — should decrease if prefilter catches timeout-bound formulas
   - Per-pattern breakdown: `proofReconstructionMethod.startsWith "structural_prefilter:"`

4. **Diversity check**:
   Use `computeDiversity` from `EnumBenchmark.lean` to ensure new patterns don't skew the dataset toward a single category.

### 6.2 Expected Baseline
From `EnumBenchmark.lean` lines 172–175:
- Valid fraction baseline: **~3–4%** (exhaustive + seeds)
- Timeout rate target: **<20%**
- Ex_falso dominance in valid set: **~90%** (needs improvement)

### 6.3 Target Outcome
After implementing all 5 patterns, we aim for:
- **Valid fraction**: ~10% (roughly 3× improvement)
- **Prefilter hit rate**: ~8–10% of all formulas (not just valid ones)
- **Timeout rate**: reduction by 2–3 percentage points
- **No increase in false positives**: all prefilter patterns must be semantically justified (soundness check via `matchAxiom` or existing theorems)

### 6.4 Validation Checklist
- [ ] All new patterns have `#eval` unit tests in `DatasetGenerator.lean` (following the existing style, lines 489–526)
- [ ] `lake build` passes with no errors
- [ ] `lake exe enum_benchmark` runs successfully and shows improved metrics
- [ ] Decision method distribution (`decisionMethodDist`) shows new `structural_prefilter:*` patterns
- [ ] No formulas that were previously `valid` or `invalid` are mislabeled as `timeout` or vice versa

---

## 7. Summary

| Pattern | Effort | Impact | Priority |
|---------|--------|--------|----------|
| Subsumption rules (10x) | Low | High | **P1 — do first** |
| S5 reflexive shortcutting | Low | High | **P1 — do first** |
| Temporal loop detection | Medium | High | **P2 — do next** |
| Polarity analysis | Medium | Medium-High | **P2 — do next** |
| Lightweight prop contradiction | Low | Medium | **P2 — do next** |
| Full 2-SAT skeleton | High | Medium | **P3 — defer unless needed** |

The safest path to ~10% coverage is:
1. **P1** (Phase 1) gives the biggest coverage boost with minimal risk.
2. **P2** (Phase 2) adds the remaining coverage via polarity + lightweight propositional checks.
3. **P3** (Phase 3) is a backup plan only if the target is not reached after P1+P2.

All patterns integrate cleanly with the existing `structuralPrefilterWithAxiom` → `labelFormula` → `decisionMethod` telemetry pipeline, making before/after measurement straightforward.
