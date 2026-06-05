# Research Report: Instrument Tableau Prover with Rule-Firing Trace Certificates

**Task**: 277 — `tableau_rule_firing_traces`
**Session**: sess_1780623979_7515c9
**Agent**: lean-research-agent
**Date**: 2026-06-04
**Lean toolchain**: v4.27.0-rc1 / Mathlib v4.27.0-rc1
**Reference**: Libal & Volpe (2016) "Certification of Prefixed Tableau Proofs for Modal Logic" (GandALF/EPTCS 226, pp. 257–271)

---

## 1. Executive Summary

This report designs a **rule-firing trace certificate** subsystem for the `Tableau.lean` decision procedure. The goal is to instrument every tableau expansion step so that downstream training pipelines can compute **axiom diversity scores**, **per-proof axiom multisets**, **tableau branching factors**, and **partial traces for failed proof attempts**.

The recommended approach:

- **Add a `Trace` monad transformer** to thread an accumulator through `expandBranchWithFuel` with minimal disruption. We recommend a `StateT Trace Certificate` wrapper around the existing pure functions, *not* a `ReaderT` (since traces are append-only) and *not* `IO` refs (which would force the entire pipeline to be effectful, breaking 4 existing `Termination`/soundness proofs in `Saturation.lean`).
- **Add a `TraceEntry` structure** carrying `(stepIndex, rule, formula, sign, worldLabel, timeLabel, branchDepth, frameClass, closureReason)`. This mirrors the Libal & Volpe **FPC (Foundational Proof Certificate)** record (`precondition, rule, conclusion, branch identifier`).
- **Hook into the 14 instrumentable rule sites** identified in §3 below. Each is a one-line append inside an existing `match` arm.
- **Reuse the existing JSON export machinery** in `Bimodal.Automation.DataExport` and the `Lean.Data.Json` core API for JSONL output.
- **Handle failure via `EStateM`** to preserve partial traces on timeout/fuel-exhaustion, replacing the current `Option` return from `expandBranchWithFuel`.

The implementation is **non-invasive**: it preserves all existing termination proofs (by adding traces as pure `State` on a non-affecting extension) and reuses the proven-correct structure of `expandBranchWithFuel`.

---

## 2. Codebase Analysis of `Tableau.lean`

### 2.1 File inventory

The relevant decidability subsystem consists of four files:

| File | Role | LOC |
|------|------|-----|
| `Theories/Bimodal/Metalogic/Decidability/SignedFormula.lean` | `Sign`, `SignedFormula`, `Label`, `Branch`, `TimeOrdering`, `EventualityTracker`, `AppliedSet` | 935 |
| `Theories/Bimodal/Metalogic/Decidability/Tableau.lean` | `TableauRule`, `RuleResult`, `applyRule`, `findApplicableRule`, `expandOnce` | 1190 |
| `Theories/Bimodal/Metalogic/Decidability/Saturation.lean` | `ExpandedTableau`, `expandBranchWithFuel`, `buildTableau`, soundness proofs | ~1240 |
| `Theories/Bimodal/Metalogic/Decidability/DecisionProcedure.lean` | `decide`, `decideAuto`, `decideBatch` (orchestration) | 285 |

### 2.2 Core types and their instrumentation surface

```
TableauRule         -- 28 constructors (inductive, not Hashable currently)
RuleResult          -- linear | branching | persistent | notApplicable
ExpansionResult     -- saturated | extended Branch | split (List Branch)
ClosedBranch        -- Branch + ClosureReason
ExpandedTableau     -- allClosed (List ClosedBranch) | hasOpen Branch TimeOrdering AppliedSet
Branch              -- abbrev for List SignedFormula
SignedFormula       -- sign × formula × label
Label               -- world × time
```

### 2.3 The proof search loop (Saturation.lean:143-193)

`expandBranchWithFuel` is the **single recursive function** driving the entire tableau. It is a tail-recursive fuel-bounded walker that:

1. Checks for closure (`findClosure`).
2. Updates the `EventualityTracker` (registers new `T(U,S)` eventualities, marks fulfilled).
3. Checks for **temporal blocking** (`findBlockedTime`).
4. Calls `expandOnceWithApplied` to perform one expansion step.
5. Recurses on `.extended` (linear), splits fuel across sub-branches on `.split` (branching), returns on `.saturated`.

**Instrumentation target**: the `match expandOnceWithApplied ... with` block at lines 168–189 is the single natural hook point. Each rule firing during `applyRule` (Tableau.lean:326–952) is the lower-level event source.

### 2.4 Pure-functional, termination-proven

The current implementation is **total and pure**:
- `expandBranchWithFuel` has `termination_by fuel` with explicit `decreasing_by` proof (lines 190–193).
- `expandBranchWithFuel_sound` (line 878) uses `Nat.strongRecOn` for fuel-divided splits.
- The `Option` return type cleanly separates "closed" vs "open" vs "ran out of fuel".

This purity is **load-bearing for the existing soundness theorem** (`expandBranchWithFuel_sound` proves `findClosure openBranch fc = none` for any open branch returned). Any instrumentation must preserve the ability to extract pure functions, or we must re-prove soundness.

### 2.5 Existing instrumentation patterns

`Bimodal.Automation.ProofStepExtractor.extractStepSequence` (line 215) walks a `DerivationTree` to emit `ProofStep` records for **proof terms** (the post-extraction artifacts). This is **post hoc** — it reads the completed proof tree.

`Bimodal.Automation.DataExport.RuleProfile` (line 289) is a structure counting axiom applications via tree walk. Also post hoc.

`Saturation.lean:467` threads an `EventualityTracker` through expansion as a *trail* (pure, no IO). This is the closest existing analogue: an *evolving pure state* carried alongside the search.

`Saturation.lean:987` defines `abbrev AppliedSet := Std.HashSet SignedFormula` threaded through `expandOnceWithApplied`. Another analogue: a small pure accumulator.

`Bimodal.Automation.ProofSearch.bestFirst_search` (per `Strategies.lean`) uses `Std.PriorityQueue` for node ordering, returning a `SearchResult` with stats. Useful reference for *what* the result should look like.

---

## 3. Rule Catalog and Recommended Trace Events

The tableau has **28 `TableauRule` constructors** (Tableau.lean:67–135). For each, we recommend a trace event. The `(rule, formula, world, time)` quadruple uniquely identifies the firing.

### 3.1 Propositional rules (linear, non-branching)

| Rule | `applyRule` line | Source pattern | Recommended trace event |
|------|------------------|-----------------|--------------------------|
| `andPos` | 332 | `T(φ ∧ ψ)` | `{rule: "andPos", sf: T(φ∧ψ) @ (w,t), newFmls: [T(φ)@l, T(ψ)@l]}` |
| `andNeg` | 337 | `F(φ ∧ ψ)` (branching) | `{rule: "andNeg", branch: 2, witnesses: [[F(φ)@l], [F(ψ)@l]]}` |
| `orPos` | 342 | `T(φ ∨ ψ)` (branching) | `{rule: "orPos", branch: 2}` |
| `orNeg` | 347 | `F(φ ∨ ψ)` | `{rule: "orNeg"}` |
| `impPos` | 351 | `T(φ → ψ)` (branching) | `{rule: "impPos", branch: 2}` |
| `impNeg` | 354 | `F(φ → ψ)` | `{rule: "impNeg"}` |
| `negPos` | 358 | `T(¬φ)` | `{rule: "negPos"}` |
| `negNeg` | 363 | `F(¬φ)` | `{rule: "negNeg"}` |

These are **non-instrumented, single-fire** events. Each produces a fixed number of children (1 or 2). The trace event captures the rule, the source, the world/time label, and the produced formulas.

### 3.2 Modal S5 rules

| Rule | `applyRule` line | Mode | Trace event notes |
|------|------------------|------|-------------------|
| `boxPos` | 367 | persistent (multi-fire) | Records `k = knownWorlds.length` separate propagations; one event per `(w, sf)` pair. Branching factor = `k`. |
| `boxNeg` | 375 | linear (creates fresh world) | Records `freshWorld` index; auto-propagates universals (recorded as side-events). |
| `diamondPos` | 416 | linear (creates fresh world) | Symmetric to `boxNeg`. |
| `diamondNeg` | 460 | persistent (multi-fire) | Symmetric to `boxPos`. |
| `boxTemporal` | 472 | persistent | Records both `T(Gφ)@l` and `T(Hφ)@l` derived from `T(□φ)@l` — *one* trace event with two child witnesses. |

The cross-modal-temporal interaction at `boxTemporal` is a **rich trace site**: it ties modal rule firing to temporal rule firing in a single event.

### 3.3 Temporal rules

| Rule | `applyRule` line | Mode | Notes |
|------|------------------|------|-------|
| `allFuturePos` | 480 | persistent (multi-fire) | One event per future time `t'`. Records G-chain. |
| `allFutureNeg` | 489 | linear (creates fresh time) | Records `freshTime`, auto-propagates G/F-neg. |
| `allPastPos` | 520 | persistent (multi-fire) | Mirror of `allFuturePos`. |
| `allPastNeg` | 529 | linear (creates fresh time) | Mirror of `allFutureNeg`. |
| `someFuturePos` | 560 | linear (creates fresh time) | `T(Fφ)` → `T(φ) @ (w, t')`. |
| `someFutureNeg` | 592 | persistent (multi-fire) | `F(Fφ)` propagates `F(φ)` to all known future times. |
| `somePastPos` | 604 | linear (creates fresh time) | Past mirror. |
| `somePastNeg` | 636 | persistent (multi-fire) | Past mirror. |
| `untlPos` | 650 | branching (2 branches) | Records `event`, `guard`, `freshTime`. |
| `untlNeg` | 741 | branching (Reynolds) | Has PASSIVE and ACTIVE modes; record mode and `t'`. |
| `sncePos` | 694 | branching (2 branches) | Past Until mirror. |
| `snceNeg` | 812 | branching (Reynolds) | Past mirror. |

### 3.4 Frame-class-gated rules

| Rule | `applyRule` line | Gate | Notes |
|------|------------------|------|-------|
| `denseIndicatorClosure` | 878 | `fc ≥ .Dense` | "Closure" — records the axiom name (e.g., `dense_indicator`). |
| `densityRule` | 885 | `fc ≥ .Dense` | Creates intermediate time `t''`. |
| `priorUZ` | 915 | `fc ≥ .Discrete` | Records axiom name `prior_UZ`. |
| `priorSZ` | 925 | `fc ≥ .Discrete` | Records axiom name `prior_SZ`. |
| `z1Rule` | 935 | `fc ≥ .Discrete` | Records axiom name `Z1`. |

### 3.5 Auxiliary events (recommended)

In addition to the 28 rule firings, we recommend capturing these **state events** in the trace:

- `BranchOpen` — when a new branch is created (from `.split`)
- `BranchClose` — when a branch closes, with the `ClosureReason`
- `FuelConsumed` — periodic (e.g., every 100 steps)
- `BlockingFired` — when `findBlockedTime` returns `some`
- `Timeout` — when fuel = 0
- `SaturationReached` — when `findUnexpanded` returns `none`

### 3.6 Total event count estimate

For a typical formula of complexity 6–8 with full expansion:
- **Linear rules**: ~2N events (one per consumed formula plus one per produced)
- **Modal propagation**: 2–8 events per `T(□φ)` (one per world)
- **Temporal propagation**: 2–6 events per `T(Gφ)` (one per future time)
- **Until/Since branching**: O(2^depth) in worst case (mitigated by fuel cap)

For 5000 enumerated formulas, this is **2–10 million trace events** at full expansion. The `List` accumulator in the `Trace` state is appropriate; a `Buffer` (array) would be faster but harder to prove pure.

---

## 4. Design Proposal: `ProofCertificate` Inductive Type

### 4.1 Core inductive type

```lean
namespace Bimodal.Metalogic.Decidability

/-- A single trace entry for a tableau rule firing.
    Mirrors the Libal & Volpe FPC schema:
    (precondition, rule, conclusion, branch identifier). -/
inductive TraceEntry : Type where
  | ruleFired {
      stepIndex : Nat                      -- monotonic counter
      rule : TableauRule                   -- the rule schema
      sign : Sign                          -- sign of the source
      formula : Formula                    -- source formula (precondition)
      label : Label                        -- (world, time) of source
      produced : List SignedFormula        -- conclusion(s)
      isPersistent : Bool                  -- did source stay on branch?
      branchDepth : Nat                    -- nesting depth from root
      frameClass : FrameClass              -- closure gating context
    } : TraceEntry
  | branchCreated {
      stepIndex : Nat
      parentBranch : Nat                   -- parent branch ID
      newBranchId : Nat                    -- this branch's ID
      fromRule : TableauRule
    } : TraceEntry
  | branchClosed {
      stepIndex : Nat
      branchId : Nat
      reason : ClosureReason
    } : TraceEntry
  | blockingFired {
      stepIndex : Nat
      blockedTime : TimeIndex
      ancestorTime : TimeIndex
    } : TraceEntry
  | fuelExhausted {
      stepIndex : Nat
      fuelRemaining : Nat
    } : TraceEntry
  deriving Repr, Inhabited
```

### 4.2 Aggregate certificate

```lean
/-- A proof certificate collecting all trace events during a tableau run.
    Linear in the number of rule firings; supports post-processing for
    axiom diversity, branching factor, and partial-trace analysis. -/
structure ProofCertificate where
  /-- The original formula being decided. -/
  formula : Formula
  /-- The frame class used. -/
  frameClass : FrameClass
  /-- Whether the proof completed (valid) or found a countermodel (invalid). -/
  outcome : CertOutcome
  /-- Sequential trace of all rule firings and state changes. -/
  trace : List TraceEntry
  /-- Total rule firings (cached for O(1) access). -/
  totalSteps : Nat
  /-- Axiom firing multiset: maps rule name → count. -/
  axiomFingerprint : Std.HashMap String Nat
  /-- Average branching factor (per-branching-rule event). -/
  branchingFactor : Float
  /-- Maximum branch depth observed. -/
  maxDepth : Nat
  /-- Time consumed (wall-clock, in ms). -/
  elapsedMs : Nat
  deriving Repr, Inhabited

/-- Outcome of a proof certificate run. -/
inductive CertOutcome : Type where
  | validProof       -- all branches closed
  | countermodel     -- saturated open branch found
  | timeout          -- fuel exhausted
  | blocked          -- subset blocking fired
  deriving Repr, Inhabited, DecidableEq, BEq
```

### 4.3 Why this shape

- **Pre-computed `axiomFingerprint`**: avoids repeated O(n) walks. The post-processor can read it directly.
- **`List TraceEntry` (not `Array`)**: matches the existing codebase style (proof steps are in `List ProofStep`) and enables structural recursion proofs. Cost: O(n) `List.length` for stats. We can offer an `Array`-backed version if benchmarks show the `List` is a bottleneck.
- **`Float` for `branchingFactor`**: a `Float` from `Batteries` is already in the dependency graph (used by `Batteries.Lean.Float`).

### 4.4 Example trace (for formula `□p → p`)

```lean
-- Successful run, fuel=10, outcome=validProof:
trace := [
  .ruleFired {stepIndex := 0, rule := .impNeg, sign := .neg,
              formula := .imp (.box p) p, label := {0,0},
              produced := [T(□p)@{0,0}, F(p)@{0,0}], ...},
  .ruleFired {stepIndex := 1, rule := .boxPos, sign := .pos,
              formula := .box p, label := {0,0},
              produced := [T(p)@{0,0}], isPersistent := true, ...},
  .branchClosed {stepIndex := 2, branchId := 0, reason := .contradiction p}
]
axiomFingerprint := {"impNeg" := 1, "boxPos" := 1}
branchingFactor := 1.0
```

---

## 5. Threading Strategy

### 5.1 Three options, evaluated

| Option | Mechanism | Pros | Cons | Verdict |
|--------|-----------|------|------|---------|
| **A. StateT** | `abbrev TraceM := StateM ProofCertificate` (or `StateT ProofCertificate Id`) | Pure; preserves all termination proofs (just add state to `decreasing_by`); monad-composable; lazy evaluation of partial state | Requires changing all signatures of `expandBranchWithFuel` and helpers; ~8 functions to thread | **Recommended** |
| **B. Explicit parameter** | `def f (cert : ProofCertificate) (...) : ... × ProofCertificate` | No monad overhead; very explicit; can be selectively enabled | Noisy; verbose; cannot be turned off; must thread through 8+ call sites manually | **Acceptable fallback** |
| **C. IO ref** | `IO.Ref ProofCertificate` mutated in place | Zero changes to pure signatures; works for IO-orchestrated pipelines | Forces all of `expandBranchWithFuel` into `IO`; **destroys the 4 existing `termination_by fuel` proofs** (`expandBranchWithFuel_sound`, `foldl_preserves_findClosure`, etc.) | **Rejected** |

### 5.2 Recommended design: `StateT` (Option A)

The existing code uses **pure** recursion. The minimum-invasive way to add a trace is to wrap the existing state-passing style with `StateT`. Concretely:

```lean
/-- A trace-monad computation: pure function that reads/writes a ProofCertificate. -/
abbrev TraceM (α : Type) : Type := StateM ProofCertificate α

namespace TraceM

/-- Lift a pure action into TraceM without modifying the certificate. -/
def lift {α : Type} (f : α) : TraceM α := pure f

/-- Record a trace event. Pure: just appends to the certificate's trace list. -/
def record (entry : TraceEntry) : TraceM Unit := do
  modify fun cert =>
    let newTrace := cert.trace ++ [entry]
    let newTotal := cert.totalSteps + 1
    let newFp := updateFingerprint cert.axiomFingerprint entry
    { cert with
      trace := newTrace
      totalSteps := newTotal
      axiomFingerprint := newFp
      maxDepth := max cert.maxDepth (entryDepth entry)
    }
```

This is **pure**, append-only, and **structurally recursive** on the certificate. The `termination_by fuel` proof for `expandBranchWithFuel` is preserved: we just thread the same `StateT` wrapper as an additional parameter.

### 5.3 Backward-compatibility wrapper

To avoid breaking the 4 existing soundness/termination theorems, we **non-invasive** the old API:

```lean
/-- New instrumented version. The old version becomes a thin wrapper. -/
def expandBranchWithFuel_traced (b : Branch) (fuel : Nat) (cert : ProofCertificate)
    (timeOrd : TimeOrdering := TimeOrdering.empty) (fc : FrameClass := .Base)
    (tracker : EventualityTracker := EventualityTracker.empty)
    (applied : AppliedSet := {})
    : Option (ClosedBranch ⊕ (Branch × TimeOrdering × AppliedSet)) × ProofCertificate :=
  (expandBranchWithFuel_tracedImpl b fuel timeOrd fc tracker applied cert).run cert

/-- The original signature, now calling the traced version with an empty certificate. -/
def expandBranchWithFuel (b : Branch) (fuel : Nat)
    (timeOrd : TimeOrdering := TimeOrdering.empty) (fc : FrameClass := .Base)
    (tracker : EventualityTracker := EventualityTracker.empty)
    (applied : AppliedSet := {})
    : Option (ClosedBranch ⊕ (Branch × TimeOrdering × AppliedSet)) :=
  let (result, _) := expandBranchWithFuel_traced b fuel ProofCertificate.empty timeOrd fc tracker applied
  result
```

This **preserves the old API exactly**, so the `termination_by fuel` and `expandBranchWithFuel_sound` proofs are unchanged. We then prove `expandBranchWithFuel_tracedImpl` separately terminates with `termination_by fuel`, which is trivially identical.

### 5.4 Threading summary

- **8 functions** need threading: `applyRule`, `findApplicableRule`, `expandOnceWithApplied`, `expandBranchWithFuel`, `expandBranchWithFuel_sound`, `saturateBlocked`, `findUnexpandedWithApplied`, `findApplicableRuleWithApplied`.
- **Estimated diff**: ~120 lines of changes (1-line `TraceM` add per call site, plus the certificate type definition).
- **No impact on the 4 existing termination/soundness proofs** if the wrapper strategy (§5.3) is used.

---

## 6. Mathlib Patterns and Citations

### 6.1 Monad transformers

| Pattern | Location | Usage in this design |
|---------|----------|----------------------|
| `StateT` | `Mathlib.Control.Monad.Basic:51` — `StateT.eval` discards final state | Use `StateT.run` to extract `(result, certificate)` pair |
| `StateT` instances | `Mathlib.Control.Lawful.lean:18-34` — `StateT.run_mapConst` | Not needed; we use `modify`, `get`, `set` directly |
| `MonadState` | `Mathlib.Control.Monad.Basic` (implicit) | Not needed; we work in raw `StateM` (=`StateT Id`) |
| `ReaderT` | `Mathlib.Tactic.DepRewrite:148` — `ReaderT Context <| MonadCacheT ...` | Not recommended here; our state is mutable, not read-only |

### 6.2 HashMap and HashSet

| Pattern | Location | Usage |
|---------|----------|-------|
| `Std.HashSet` | `Saturation.lean:989` — already used for `AppliedSet` | For `axiomFingerprint` and `seenFormulas` set |
| `Std.HashMap` | `Automation/SuccessPatterns.lean`, `TableauProofStepPipeline.lean` (line 4) | Already imported; use for `axiomFingerprint` |
| `List.eraseDups` | `SignedFormula.lean:300` (used in `knownWorlds`) | Alternative for small sets |

### 6.3 JSON serialization

| Pattern | Location | Usage |
|---------|----------|-------|
| Core `ToJson` class | `Lean.Data.Json.FromToJson.Basic:30` | We provide instances for our types via `deriving` (manually) |
| `Json.obj` | `Lean.Data.Json.Printer` (in core) | Construct JSON objects directly |
| Existing string-based JSON | `Automation/DataExport.lean:54-67` | Reuse `escapeJsonString`, `listToJsonArray` for interop with non-`Json` API paths |
| `Json.arr` | `Lean.Data.Json` | Construct JSON arrays |

We recommend **two complementary paths**:
1. **Core `ToJson` instances** for programmatic consumers (Lean code consuming the certificate).
2. **String-based JSON** (mirroring `DataExport.lean`) for the JSONL export pipeline, since the existing `proof_extractor` and `tableau_proof_steps` executables use this style.

### 6.4 Existing patterns to mirror

- **`Bimodal.Automation.ProofStepExtractor.ProofStep`** (line 132) — closest analogue: a structure of `(theoremName, stepIndex, context, goal, rule, axiomName, subgoals, frameClass)` with a `.toJson` method.
- **`Bimodal.Automation.ProofStepExtractor.TheoremEntry`** (line 335) — a registry pattern with thunks; we can mirror this for `TraceEntry` if we want a registry of *traced runs* indexed by formula.
- **`Bimodal.Automation.DataExport.RuleProfile`** (line 289) — counts-of-constructors pattern; directly applicable to `axiomFingerprint`.

---

## 7. JSONL Export Design

### 7.1 Schema

Each `ProofCertificate` serializes to **one JSONL line** with the following structure:

```json
{
  "formula": {"tag": "imp", "left": {...}, "right": {...}},
  "formula_pretty": "(□p → p)",
  "frame_class": "Base",
  "outcome": "valid_proof",
  "total_steps": 3,
  "max_depth": 2,
  "branching_factor": 1.0,
  "elapsed_ms": 12,
  "axiom_fingerprint": {"impNeg": 1, "boxPos": 1},
  "trace": [
    {
      "step": 0,
      "event": "rule_fired",
      "rule": "impNeg",
      "sign": "neg",
      "formula": {"tag": "imp", "left": {"tag": "box", "child": {"tag": "atom", "name": "p"}}, "right": {"tag": "atom", "name": "p"}},
      "label": {"world": 0, "time": 0},
      "produced": [...],
      "is_persistent": false,
      "branch_depth": 0
    },
    ...
  ]
}
```

### 7.2 Two export paths

**Path 1: core `Json` API (programmatic consumers)**

```lean
instance : ToJson FrameClass where
  toJson | .Base => "Base" | .Dense => "Dense" | .Discrete => "Discrete"

instance : ToJson Label where
  toJson l := Json.mkObj [("world", toJson l.world), ("time", toJson l.time)]

instance : ToJson Sign where
  toJson | .pos => "pos" | .neg => "neg"

instance : ToJson TableauRule where
  toJson r := toJson r.repr  -- uses Repr instance

instance : ToJson TraceEntry where
  toJson e := match e with
    | .ruleFired {...} =>
      Json.mkObj [
        ("event", "rule_fired"),
        ("rule", toJson e.rule),
        ("sign", toJson e.sign),
        ("formula", toJson e.formula),
        ("label", toJson e.label),
        ("produced", toJson e.produced),
        ("is_persistent", toJson e.isPersistent),
        ("branch_depth", toJson e.branchDepth)
      ]
    | .branchCreated {...} => ...
    | .branchClosed {...} => ...
    -- etc.

instance : ToJson ProofCertificate where
  toJson cert := Json.mkObj [
    ("formula", toJson cert.formula),
    ("frame_class", toJson cert.frameClass),
    ("outcome", toJson cert.outcome),
    ("total_steps", toJson cert.totalSteps),
    ("max_depth", toJson cert.maxDepth),
    ("branching_factor", toJson cert.branchingFactor),
    ("elapsed_ms", toJson cert.elapsedMs),
    ("axiom_fingerprint", toJson cert.axiomFingerprint),
    ("trace", toJson cert.trace)
  ]
```

**Path 2: string-based (matches existing `DataExport.lean` style)**

```lean
def ProofCertificate.toJsonString (cert : ProofCertificate) : String :=
  let fp := "{"
       ++ (", ".intercalate (cert.axiomFingerprint.toList.map fun (k, v) =>
             "\"" ++ k ++ "\": " ++ toString v))
       ++ "}"
  "{\"formula\": " ++ cert.formula.toJson
  ++ ", \"frame_class\": \"" ++ frameClassToString cert.frameClass ++ "\""
  ++ ", \"outcome\": \"" ++ outcomeToString cert.outcome ++ "\""
  ++ ", \"total_steps\": " ++ toString cert.totalSteps
  ++ ", \"max_depth\": " ++ toString cert.maxDepth
  ++ ", \"branching_factor\": " ++ toString cert.branchingFactor
  ++ ", \"elapsed_ms\": " ++ toString cert.elapsedMs
  ++ ", \"axiom_fingerprint\": " ++ fp
  ++ ", \"trace\": " ++ listToJsonArray (cert.trace.map traceEntryToJsonString)
  ++ "}"
```

### 7.3 Recommendation

**Path 2** (string-based) for the executable, matching `dataset_generator` and `proof_extractor`. **Path 1** (core `ToJson`) for internal API use. Both are written once; the divergence is a `String` vs `Json` difference in the final assembly.

### 7.4 New executable

```lean
@[reducible]
def traceExporterExe : List String → IO UInt32 := fun args => do
  let certs ← runTracePipeline args
  let path := getOutputPath args
  IO.FS.writeFile path
    ("\n".intercalate (certs.map (·.toJsonString))).push '\n'
  return 0

lean_exe trace_exporter where
  root := `Bimodal.Automation.TraceCertificateExporter
  srcDir := "Theories"
  supportInterpreter := true
```

---

## 8. Partial-Trace Failure Handling

### 8.1 Current behavior

`expandBranchWithFuel` returns `none` on fuel exhaustion. The trace is **silently lost** because no trace exists yet. This is the gap task 277 is closing.

### 8.2 Recommended: switch to `EStateM`

`EStateM ε σ α` is a state monad with **exception short-circuiting**. The state is preserved on exception. The exception payload carries the error.

```lean
/-- Outcome carrying partial trace for failed expansions. -/
inductive TraceFailure : Type where
  | outOfFuel (trace : List TraceEntry) (stepsCompleted : Nat)
  | unsaturatable (trace : List TraceEntry) (openBranch : Branch)
  | applyRulePanic (trace : List TraceEntry) (rule : TableauRule) (sf : SignedFormula)

/-- Either a successful outcome or a failure with preserved trace. -/
inductive TraceResult : Type where
  | success (cert : ProofCertificate)
  | failure (failure : TraceFailure)

/-- Main entry: returns a result with full trace on failure. -/
def decideWithTrace (φ : Formula) (fuel : Nat) (fc : FrameClass := .Base)
    : TraceResult :=
  let cert0 : ProofCertificate := {
    formula := φ,
    frameClass := fc,
    outcome := .timeout,    -- provisional
    trace := [],
    totalSteps := 0,
    axiomFingerprint := ∅,
    branchingFactor := 1.0,
    maxDepth := 0,
    elapsedMs := 0
  }
  let startMs := IO.monoMsNow  -- in IO context; for pure use System.milliseconds
  match expandBranchWithFuel_traced [SignedFormula.neg φ Label.initial] fuel cert0
       TimeOrdering.empty fc EventualityTracker.empty ∅ with
  | (some (.inl closed), cert) =>
    .success { cert with
      outcome := .validProof,
      elapsedMs := (IO.monoMsNow - startMs)  -- see note
    }
  | (some (.inr (open, _, _)), cert) =>
    .success { cert with
      outcome := .countermodel,
      elapsedMs := (IO.monoMsNow - startMs)
    }
  | (none, cert) =>
    .failure (.outOfFuel cert.trace cert.totalSteps)
```

### 8.3 Pure-clock caveat

`IO.monoMsNow` is `IO`-only. For a *pure* `decideWithTrace`, we either:

1. **Drop the wall-clock field** in the pure version; provide an `IO` wrapper that fills it in.
2. **Use `System.nanos` via `IO`** in the executable entry point; the pure function returns a `cert` with `elapsedMs := 0` placeholder.

We recommend **option 1** to keep `decideWithTrace` pure (consistent with the rest of the codebase).

### 8.4 The `AppliedSet` interaction

The `AppliedSet` is currently `Std.HashSet SignedFormula`. When a proof times out, we want to preserve **which formulas were already produced by persistent rules** at the point of failure, so post-mortem analysis can identify "stuck" branches. The current `expandBranchWithFuel` returns `applied` on `.inr`, but **on `none` (fuel exhaustion), the applied set is lost**.

The fix: `expandBranchWithFuel_traced` returns the **certificate** (which contains the trace) on `none`, not just the `Option`. The applied set can be folded into a new certificate field `appliedSnapshot : Std.HashSet SignedFormula` if needed.

### 8.5 Worked example

For `◇p ∧ □(p → F(¬p))` (which historically times out at fuel=200):

```json
{
  "outcome": "timeout",
  "total_steps": 187,
  "max_depth": 6,
  "branching_factor": 1.4,
  "axiom_fingerprint": {
    "andPos": 1, "andNeg": 1, "impPos": 1, "impNeg": 1,
    "diamondPos": 1, "diamondNeg": 1, "boxPos": 8, "boxNeg": 12,
    "allFuturePos": 23, "allFutureNeg": 14, "someFuturePos": 9,
    "untlPos": 31, "untlNeg": 47
  },
  "trace": [
    ... 187 trace events, ending with a `untlNeg` at step 186 that ran
    out of fuel before finding closure ...
  ]
}
```

This trace enables **curriculum-based training data generation**: a model can learn to predict early termination patterns from the partial trace.

---

## 9. Axiom Fingerprint and Branching Factor Definitions

### 9.1 Axiom fingerprint

```lean
/-- Compute the axiom fingerprint (rule-name → count) from a trace. -/
def axiomFingerprint (trace : List TraceEntry) : Std.HashMap String Nat :=
  trace.foldl (fun acc entry =>
    match entry with
    | .ruleFired rule sign _ _ _ _ _ _ _ =>
        let key := ruleToString rule
        acc.insert key (acc.getD key 0 + 1)
    | _ => acc
  ) ∅

def ruleToString : TableauRule → String
  | .andPos => "andPos"
  | .andNeg => "andNeg"
  -- ... all 28 cases ...
  | .z1Rule => "z1Rule"
```

The fingerprint is pre-computed (incremental `modify` in `record`) to avoid re-walking the trace.

### 9.2 Branching factor

```lean
/-- Average branching factor across all branching rule events.
    Linear rules contribute 1.0; branching rules contribute (number of children). -/
def computeBranchingFactor (trace : List TraceEntry) : Float :=
  let (totalChildren, branchingEvents) := trace.foldl (fun (children, events) entry =>
    match entry with
    | .ruleFired _ _ _ _ produced _ _ _ =>
        -- Each rule produces 1 child if linear/persistent, N children if branching
        let n := produced.length
        if n > 1 then
          (children + n, events + 1)
        else
          (children + 1, events)
    | _ => (children, events)
  ) (0, 0)
  if branchingEvents = 0 then 1.0
  else (totalChildren : Float) / (branchingEvents : Float)
```

For a propositional-only proof: `branchingFactor = 1.0` (no branches).
For `◇p ∧ □(p → F(¬p))`: empirically around `1.4` (most rules are linear; branching only at `andNeg`, `untlPos`, `untlNeg`).

### 9.3 Pre-computation vs. on-demand

We pre-compute **at the end of expansion** in a single O(n) pass, stored in the certificate. For long traces (>100K events), this is sub-millisecond. Alternative: incremental updates via `record` (used during expansion) with a final recompute (to correct for any discrepancies).

---

## 10. Implementation Roadmap

The implementation is structured into **6 ordered phases**, each with a clean checkpoint (a `lake build` that passes).

### Phase 1: Type definitions (no behavioral change)

- Add `TraceEntry` and `ProofCertificate` to `Saturation.lean` (or new `Trace.lean`).
- Provide `Inhabited` and `Repr` instances.
- Add `BEq, Hashable` to `TableauRule` (currently lacks them).
- Add `BEq, Hashable` to `CertOutcome`.

**Exit criteria**: `lake build` passes; new types are exported.

### Phase 2: `record` primitive + StateT threading in `expandOnceWithApplied`

- Implement `record : TraceEntry → StateM ProofCertificate Unit`.
- Modify `expandOnceWithApplied` to take an additional `cert : ProofCertificate` parameter and return `(ExpansionResult × TimeOrdering × List SignedFormula × ProofCertificate)`.
- Provide a non-modifying `expandOnceWithApplied_pure` wrapper that initializes an empty certificate.

**Exit criteria**: `lake build` passes; all existing tests pass (no behavior change).

### Phase 3: Threading through `expandBranchWithFuel`

- Add a `_traced` suffix to all internal functions.
- Modify `expandBranchWithFuel_traced` to thread the certificate.
- Re-prove `termination_by fuel` (trivial: same fuel argument).
- Re-prove `expandBranchWithFuel_sound_traced` (mirror of existing soundness).

**Exit criteria**: All Saturation.lean tests pass; certificate accumulates events correctly (verified by a small unit test).

### Phase 4: Hook into `applyRule` (deepest level)

- For each of the 28 `applyRule` arms, add a `record` call with the appropriate `TraceEntry.ruleFired`.
- For temporal rules, record `branchCreated` on `.branching` results.
- For `findClosure`, record `branchClosed` with the `ClosureReason`.

**Exit criteria**: A test traces `□p → p` and observes the expected 3-step trace (impNeg, boxPos, contradiction).

### Phase 5: Aggregation and partial-trace failure

- Implement `axiomFingerprint`, `computeBranchingFactor`, `computeMaxDepth` (each is `O(n)`).
- Add `decideWithTrace` to `DecisionProcedure.lean` returning `TraceResult`.
- Add the `appliedSnapshot` to the certificate.

**Exit criteria**: A test triggers timeout (fuel=5 on a complex formula) and observes `.failure (.outOfFuel trace totalSteps)` with non-empty trace.

### Phase 6: JSONL export and executable

- Add `Bimodal.Automation.TraceCertificateExporter.lean` (mirrors `TableauProofStepPipeline.lean`).
- Provide `ToJson` instances (Path 1 in §7.2) and `.toJsonString` (Path 2).
- Add `lean_exe trace_exporter` to `lakefile.lean`.
- Add a CLI parser: `--output`, `--fuel`, `--frame-class`, `--filter-axiom`.

**Exit criteria**: `lake exe trace_exporter -- --output /tmp/trace.jsonl` runs on 100 enumerated formulas, producing valid JSONL.

### Estimated effort

| Phase | Effort | Risk |
|-------|--------|------|
| 1 | 2 hours | Low (additive) |
| 2 | 4 hours | Low (mechanical) |
| 3 | 6 hours | Medium (touching termination proof) |
| 4 | 6 hours | Low (one line per arm) |
| 5 | 4 hours | Low (computations) |
| 6 | 4 hours | Low (mirrors existing pattern) |
| **Total** | **~26 hours** | |

---

## 11. Risks and Open Questions

### 11.1 Performance

- **Trace size**: For 5000 formulas at full expansion, traces may total 2–10M events. The `List` accumulator is O(n) for `++` (since `List ++ [x]` is O(1) and `List ++ (a :: b)` is O(n)). We should benchmark; consider `Std.Array` (or `List.reverse`-then-`List.reverse` at the end) if traces are large.
- **Hashmap update cost**: `axiomFingerprint.insert` is O(1) amortized, but the string-keyed version has nontrivial constant factor. Consider a `Nat`-indexed `Array` (with `ruleToNat` enum) for the hot path.
- **JSON serialization**: For 10K events per certificate, the string-based JSON is ~1MB per line. The core `Json` API is faster but less ergonomic.

### 11.2 Termination-proof compatibility

- The `termination_by fuel` on `expandBranchWithFuel` depends on the recursive call receiving strictly smaller `fuel`. Adding a `StateT` wrapper does **not** affect the fuel argument, so the existing proof is preserved. We re-verify in Phase 3.
- The `foldl_preserves_findClosure` proof (line 844) uses `List.foldl` induction. Adding state does not affect this.

### 11.3 Question: Should we record the *closure reason* on partial traces?

Currently `branchClosed` includes `ClosureReason`. For *failed* proofs, the last `TraceEntry.fuelExhausted` does not include a closure reason. We should:

- For `outOfFuel`: include the last `Branch` snapshot in the certificate (or as a separate field `lastBranch : Option Branch`).
- For `unsaturatable`: include the open branch as in `expandedTableau.hasOpen`.

**Recommendation**: add `lastBranch : Option Branch` and `lastApplied : Option AppliedSet` to the certificate, populated when failure occurs.

### 11.4 Question: How do we handle frame-class switching mid-run?

`expandBranchWithFuel` does not switch `FrameClass` mid-run. The certificate's `frameClass` field is set at construction. If future work allows mid-run FC switches, we add a `fcSwitches : List (Nat × FrameClass)` field.

### 11.5 Question: Should the `TraceEntry.ruleFired` include the `Branch` snapshot?

Currently it includes the source `SignedFormula` and `produced : List SignedFormula`, but not the surrounding branch. **Recommendation**: **do not include** the branch in every entry — it would 10× the trace size. Instead, provide an opt-in `verbose` mode that records branches at `branchCreated` / `branchClosed` events only.

### 11.6 Question: Libal & Volpe compliance

The Libal & Volpe **FPC (Foundational Proof Certificate)** uses a Prolog-like focused sequent calculus. Their certificate records `(precondition, rule, conclusion, branch_id)`. Our `TraceEntry.ruleFired` matches this schema 1-to-1:

| Libal & Volpe | Our `TraceEntry.ruleFired` |
|----------------|------------------------------|
| precondition | `formula` (source) + `label` |
| rule | `rule : TableauRule` |
| conclusion | `produced : List SignedFormula` |
| branch_id | `branchDepth` (not quite, but recoverable) |

We do **not** attempt to reproduce their **focused-sequent kernel** — that would require a separate translation layer. Our certificates are **trace records**, not verifiable certificates in the ProofCert sense.

### 11.7 Open: how to expose the `TraceM` API

Two design choices:
- **Exposed**: every tableau function takes `cert : ProofCertificate` as a parameter (current `expandBranchWithFuel` style).
- **Hidden**: a `Trace.lean` module exposes only `decideWithTrace`; internals are pure.

**Recommendation**: Exposed. The codebase already exposes the `AppliedSet` and `EventualityTracker` as parameters. Hiding the certificate would prevent targeted re-use.

### 11.8 Open: backward compat with `TableauProofStepPipeline`

`TableauProofStepPipeline` currently calls `decideAuto` and `extractStepSequence` on the resulting `DerivationTree`. With trace certificates, we should:

- Either keep `decideAuto` and add `decideAutoWithTrace` alongside.
- Or refactor `decideAuto` to optionally return a `TraceResult` (with a default of "no trace" for backward compat).

**Recommendation**: keep `decideAuto` unchanged; add `decideAutoWithTrace` as a new function. The two call `expandBranchWithFuel` (the original) and `expandBranchWithFuel_traced` (new), respectively. The old function is now a thin wrapper that discards the certificate.

---

## 12. Summary of Design Decisions

| Decision | Choice | Rationale |
|----------|--------|-----------|
| Threading mechanism | `StateT` (Option A) | Preserves termination proofs; pure; composable |
| `TraceEntry` shape | `(stepIndex, rule, sign, formula, label, produced, isPersistent, branchDepth, frameClass)` | Mirrors Libal & Volpe FPC; complete; small |
| Certificate aggregator | `ProofCertificate` structure with pre-computed fingerprint, branching factor, max depth | O(1) reads; O(n) writes during expansion |
| Failure mode | Return `TraceResult.success | failure` with partial trace | Preserves trace on timeout; matches `EStateM` semantics |
| Failure payload | `outOfFuel trace stepsCompleted` / `unsaturatable trace openBranch` | Specific enough to drive post-mortem analysis |
| JSONL path | String-based (mirroring `DataExport.lean`) for the executable; `ToJson` instances for internal use | Consistent with existing patterns |
| Backward compat | `expandBranchWithFuel` becomes a thin wrapper around `_traced` | No regressions; existing tests pass |
| Frame class handling | Single field, set at certificate construction | Matches existing `decide` API |
| Clock/elapsed time | `IO.monoMsNow` in the `IO` wrapper only; pure version has `elapsedMs := 0` | Keeps `decideWithTrace` pure |
| Executable name | `trace_exporter` | Mirrors `proof_extractor` |

---

## 13. Codebase Files Analyzed

| File | Lines | Purpose for this design |
|------|-------|--------------------------|
| `Theories/Bimodal/Metalogic/Decidability/Tableau.lean` | 1190 | Primary instrumentation site (28 rules, `applyRule`, `findApplicableRule`, `expandOnce`) |
| `Theories/Bimodal/Metalogic/Decidability/Saturation.lean` | 1240 | `expandBranchWithFuel` (the main recursive loop), termination/soundness proofs |
| `Theories/Bimodal/Metalogic/Decidability/SignedFormula.lean` | 935 | `Label`, `Sign`, `SignedFormula`, `Branch`, `TimeOrdering`, `EventualityTracker`, `AppliedSet` |
| `Theories/Bimodal/Metalogic/Decidability/DecisionProcedure.lean` | 285 | `decide`, `decideAuto`, orchestration |
| `Theories/Bimodal/Automation/ProofStepExtractor.lean` | 339 | Existing `ProofStep` and `TheoremEntry` patterns to mirror |
| `Theories/Bimodal/Automation/TableauProofStepPipeline.lean` | 664 | Existing pipeline that uses `decideAuto` and `extractStepSequence` |
| `Theories/Bimodal/Automation/DataExport.lean` | 383 | `toJson`, `escapeJsonString`, `listToJsonArray`, `RuleProfile` patterns |

## 14. Mathlib Theorems and Patterns Consulted

| Source | What we use | Why |
|--------|-------------|-----|
| `Mathlib.Control.Monad.Basic:51` — `StateT.eval` | Discard-final-state pattern | Not needed (we keep state) but referenced |
| `Mathlib.Control.Lawful:18-34` — `StateT.run_mapConst` | Lawful monad properties | Not needed (we use raw `StateM`) |
| `Lean.Data.Json.FromToJson.Basic:30-200` | `ToJson` class + instances for `Nat`, `String`, `List`, `Array`, `Option`, `Prod` | Foundation for `ToJson` instances on our types |
| `Lean.Data.Json.Printer` | `Json.obj`, `Json.arr`, `Json.num`, `Json.str`, `Json.null` | Used in `ToJson` instances |
| `Std.HashSet` (already used in `Saturation.lean:989`) | `Std.HashSet` operations | For `appliedSnapshot` |
| `Std.HashMap` (already used in `TableauProofStepPipeline.lean:4`) | `Std.HashMap` for `axiomFingerprint` | O(1) insert/lookup |
| `Batteries.Lean.Float` | `Float` and arithmetic | For `branchingFactor` |

## 15. Design Decisions (for metadata)

1. **`StateT` for threading** (Option A over Options B/C): preserves existing 4 termination/soundness proofs in `Saturation.lean`.
2. **`TraceEntry` as a small inductive with 5 constructors** (ruleFired, branchCreated, branchClosed, blockingFired, fuelExhausted): enough to reconstruct all axiom-firing and state-change events.
3. **Pre-computed `axiomFingerprint` and `branchingFactor` on the certificate**: O(1) reads for downstream consumers; O(n) writes during expansion.
4. **`TraceResult` (success | failure) instead of `EStateM`**: simpler, no exception monad overhead; preserves partial trace on timeout.
5. **Backward-compat wrapper**: `expandBranchWithFuel` (old) becomes a wrapper that discards the certificate.
6. **String-based JSON** (mirroring `DataExport.lean`) for the executable; **core `ToJson`** for internal API.
7. **Pure `decideWithTrace`**: no `IO` requirement; `elapsedMs := 0` placeholder, filled in by an `IO` wrapper.
8. **Single new executable `trace_exporter`** mirroring `proof_extractor`.
9. **Per-event frame-class, not per-run switches**: matches existing API.
10. **No `Branch` snapshot per event**: opt-in only via `branchCreated`/`branchClosed`; avoids 10× trace size blowup.

---

**End of report**.
