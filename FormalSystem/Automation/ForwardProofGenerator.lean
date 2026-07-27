/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.ProofSystem
import FormalSystem.ProofSystem.Derivation
import FormalSystem.Automation.DataExport
import FormalSystem.Automation.SuccessPatterns
import FormalSystem.Automation.FormulaEnumerator
import Std.Data.HashMap
import Std.Data.HashSet

/-! # Forward Proof Generator

This module implements a forward-chaining proof generation system for bimodal
logic TM. Starting from axiom instances, it applies productive inference rules
(modus ponens, necessitation, temporal necessitation, temporal duality) to
build a pool of `(formula, DerivationTree)` pairs where every pair is a theorem
by construction.

## References

- Phase 2: foundational data structures (this file)
- Phase 3-6: algorithmic content added later.
-/

namespace FormalSystem.Automation

open FormalSystem.Syntax
open FormalSystem.ProofSystem

/-- Dedup strategy for the proof pool. -/
inductive DedupStrategy where
  | shortestWins
  | distinctAxiomWins
  | firstWins
  deriving Inhabited, Repr, BEq

/-- Configuration for forward-chaining proof generation. -/
structure ForwardConfig where
  /-- Number of axiom instances to seed the pool with. -/
  seedCount : Nat := 2000
  /-- Maximum size of random sub-formulas used to instantiate axiom schemata. -/
  maxParamSize : Nat := 4
  /-- Maximum derivation depth (number of inference-rule applications). -/
  maxDepth : Nat := 3
  /-- Maximum number of entries in the proof pool. -/
  maxPoolSize : Nat := 10000
  /-- Atom vocabulary for random sub-formula generation. -/
  atoms : List Atom
  /-- Frame class for axiom compatibility filtering. -/
  frameClass : FrameClass := .Base
  /-- Numerator of the ex_falso cap fraction. -/
  exFalsoCap : Nat := 1
  /-- Denominator of the ex_falso cap fraction (default 1/5 = 20%). -/
  exFalsoDenom : Nat := 5
  /-- Whether to enforce layer-uniform axiom selection. -/
  layerUniform : Bool := true
  /-- Strategy for resolving duplicate formulas in the pool. -/
  dedupStrategy : DedupStrategy := .shortestWins
  deriving Repr, Inhabited, BEq

/--
Proof pool: a store of `(formula, proof)` pairs with O(1) deduplication.

- `entries`: ordered array of sigma-type pairs
- `formulas`: HashSet for O(1) membership testing
- `index`: HashMap from formula to its index in `entries`
- `cap`: hard upper bound on pool size

The default `add` uses shortest-wins dedup: if the same formula is inserted
again with a shorter proof, the stored proof is replaced.
-/
structure ProofPool (fc : FrameClass) where
  /-- Ordered array of (formula, proof) pairs. -/
  entries : Array (Sigma fun φ => DerivationTree fc [] φ) := #[]
  /-- HashSet for O(1) membership testing. -/
  formulas : Std.HashSet Formula := {}
  /-- Index mapping formula to its position in `entries`. -/
  index : Std.HashMap Formula Nat := {}
  /-- Hard upper bound on pool size. -/
  cap : Nat := 10000

/-- Empty proof pool. -/
def ProofPool.empty {fc : FrameClass} : ProofPool fc := {}

/-- Inhabited instance for the sigma type (needed for Array.get!/set!). -/
instance {fc : FrameClass} : Inhabited (Sigma fun φ => DerivationTree fc [] φ) where
  default :=
    let φ := Formula.bot.imp Formula.bot
    ⟨φ, DerivationTree.axiom [] φ (Axiom.ex_falso Formula.bot) (FrameClass.base_le fc)⟩

instance {fc : FrameClass} : Inhabited (ProofPool fc) := ⟨ProofPool.empty⟩

/-- Current size of the proof pool. -/
def ProofPool.size {fc : FrameClass} (pool : ProofPool fc) : Nat :=
  pool.entries.size

/-- Check whether the pool already contains a formula. -/
def ProofPool.contains {fc : FrameClass} (pool : ProofPool fc) (φ : Formula) : Bool :=
  pool.formulas.contains φ

/--
Add a `(formula, proof)` pair to the pool.

If the formula is already present, keeps the proof with the *smaller* height
(shortest-wins). If the pool has reached its capacity, the addition is ignored.
-/
def ProofPool.add {fc : FrameClass} (pool : ProofPool fc) (φ : Formula)
    (d : DerivationTree fc [] φ) : ProofPool fc :=
  if pool.contains φ then
    match pool.index[φ]? with
    | some idx =>
      let existing := pool.entries[idx]!
      if d.height < existing.snd.height then
        { pool with entries := pool.entries.set! idx ⟨φ, d⟩ }
      else
        pool
    | none => pool
  else
    if pool.size ≥ pool.cap then
      pool
    else
      let idx := pool.entries.size
      { pool with
        entries := pool.entries.push ⟨φ, d⟩
        formulas := pool.formulas.insert φ
        index := pool.index.insert φ idx }

/-- Convert the pool to a list. -/
def ProofPool.toList {fc : FrameClass} (pool : ProofPool fc)
    : List (Sigma fun φ => DerivationTree fc [] φ) :=
  pool.entries.toList

/-- Filter pool entries by a predicate on the sigma pair. -/
def ProofPool.filter {fc : FrameClass} (pool : ProofPool fc)
    (p : (Sigma fun φ => DerivationTree fc [] φ) → Bool) : ProofPool fc :=
  let filtered := pool.entries.filter p
  let newFormulas := filtered.foldl (fun acc σ => acc.insert σ.fst) {}
  let newIndex := filtered.foldl (fun (acc : Std.HashMap Formula Nat) σ =>
    acc.insert σ.fst acc.size) {}
  { pool with entries := filtered, formulas := newFormulas, index := newIndex }

/-! ## Axiom Instantiation with DerivationTree Witness -/

/--
List of human-readable schema names for all 42 axiom constructors,
in the same order as the indices used by `mkAxiomAtIdx`.
-/
def schemaNames : List String :=
  [ "prop_k", "prop_s", "ex_falso", "peirce"
  , "modal_t", "modal_4", "modal_b", "modal_5_collapse", "modal_k_dist"
  , "serial_future", "serial_past"
  , "left_mono_until_G", "left_mono_since_H", "right_mono_until", "right_mono_since"
  , "connect_future", "connect_past"
  , "enrichment_until", "enrichment_since"
  , "self_accum_until", "self_accum_since"
  , "absorb_until", "absorb_since"
  , "linear_until", "linear_since"
  , "until_F", "since_P"
  , "temp_linearity", "temp_linearity_past"
  , "F_until_equiv", "P_since_equiv"
  , "modal_future"
  , "discrete_symm_fwd", "discrete_symm_bwd", "discrete_propagate_fwd", "discrete_propagate_bwd",
      "discrete_box_necessity"
  , "prior_UZ", "prior_SZ"
  , "z1"
  , "density", "dense_indicator" ]

/-- Layer classification for axiom schemata. -/
inductive Layer where
  | Propositional
  | Modal
  | BX
  | Interaction
  | Uniformity
  | Prior
  | Z1
  | Density
  deriving Inhabited, Repr, BEq

/-- Map a schema index to its layer. -/
def schemaLayer (idx : Nat) : Layer :=
  match idx with
  | 0 | 1 | 2 | 3 => .Propositional
  | 4 | 5 | 6 | 7 | 8 => .Modal
  | 9 | 10 | 11 | 12 | 13 | 14 | 15 | 16 | 17 | 18 | 19 | 20 | 21 | 22 | 23 | 24 | 25 | 26 | 27 |
      28 | 29 | 30 => .BX
  | 31 => .Interaction
  | 32 | 33 | 34 | 35 | 36 => .Uniformity
  | 37 | 38 => .Prior
  | 39 => .Z1
  | 40 | 41 => .Density
  | _ => .Propositional

/-- Pick a random schema name (for diversity tracking). Respects the frame class filter. -/
def randomAxiomSchema (cfg : ForwardConfig) : IO String := do
  let idx ← pickSchemaIdx cfg.atoms cfg.maxParamSize cfg.frameClass
  match schemaNames[idx]? with
  | some name => return name
  | none => return "unknown"

/--
Instantiate a random axiom schema and wrap the result in a `DerivationTree`
witness (height 0).

Returns `none` if the axiom's `minFrameClass` is incompatible with the config's
`frameClass` (should not happen when using `pickSchemaIdx`).
-/
def instantiateAxiomWithProof (cfg : ForwardConfig) : IO
    (Option (Sigma fun φ => DerivationTree cfg.frameClass [] φ)) := do
  let result ← instantiateAxiomWithWitness cfg.atoms cfg.maxParamSize cfg.frameClass
  match result with
  | some ⟨φ, ax⟩ =>
    if h : ax.minFrameClass ≤ cfg.frameClass then
      return some ⟨φ, DerivationTree.axiom [] φ ax h⟩
    else
      return none
  | none => return none

/-! ## Modus Ponens via Implication Index -/

/--
Apply one pass of modus ponens closure using an implication index.

1. Scans `pool.entries` and builds a `HashMap` from antecedent formula
   to an array of implication proofs with that antecedent.
2. For each entry `(φ, d_ant)` in the pool, looks up implications keyed by `φ`
   and constructs `DerivationTree.modus_ponens` for each match.
3. Adds the conclusion to the pool via shortest-wins dedup.

Complexity filter: conclusions whose `rhs.complexity > cfg.maxParamSize * 4`
are discarded to prevent formula-size explosion.
-/
def applyModusPonens (cfg : ForwardConfig) (pool : ProofPool cfg.frameClass)
    : IO (ProofPool cfg.frameClass) := do
  -- Build implication index: lhs ↦ array of (lhs → rhs, proof)
  let mut impIndex : Std.HashMap Formula
      (Array (Sigma fun (φψ : Formula) => DerivationTree cfg.frameClass [] φψ)) := {}
  for σ in pool.entries do
    match σ.fst with
    | .imp lhs _rhs =>
      let arr := match impIndex[lhs]? with
        | some arr => arr.push σ
        | none => #[σ]
      impIndex := impIndex.insert lhs arr
    | _ => pure ()
  -- Apply MP for each antecedent in the pool
  let mut result := pool
  let mut stepCount : Nat := 0
  for σ in pool.entries do
    let φ := σ.fst
    match impIndex[φ]? with
    | some arr =>
      for impσ in arr do
        match impσ with
        | ⟨.imp lhs rhs, d_imp⟩ =>
          if h : lhs = φ then
            if rhs.complexity ≤ cfg.maxParamSize * 4 then
              let d_ant := h.symm ▸ σ.snd
              let d_mp := DerivationTree.modus_ponens [] lhs rhs d_imp d_ant
              result := result.add rhs d_mp
              stepCount := stepCount + 1
              if stepCount % 1000 == 0 then
                IO.println s!"[proof-first] MP step {stepCount}..."
          else
            pure ()
        | _ => pure ()
    | none => pure ()
  return result

/-! ## Unary Rule Closures -/

/-- Apply necessitation to every formula in the pool. -/
def applyNecessitation {fc : FrameClass} (pool : ProofPool fc) : ProofPool fc :=
  pool.entries.foldl (fun p σ =>
    match σ with
    | ⟨φ, d⟩ => p.add (Formula.box φ) (DerivationTree.necessitation φ d)
  ) pool

/-- Apply temporal necessitation to every formula in the pool. -/
def applyTemporalNecessitation {fc : FrameClass} (pool : ProofPool fc) : ProofPool fc :=
  pool.entries.foldl (fun p σ =>
    match σ with
    | ⟨φ, d⟩ => p.add (Formula.allFuture φ) (DerivationTree.temporal_necessitation φ d)
  ) pool

/-- Apply temporal duality to every formula in the pool. -/
def applyTemporalDuality {fc : FrameClass} (pool : ProofPool fc) : ProofPool fc :=
  pool.entries.foldl (fun p σ =>
    match σ with
    | ⟨φ, d⟩ => p.add (φ.swapTemporal) (DerivationTree.temporal_duality φ d)
  ) pool

/-- Apply all three unary rules in sequence, with progress logging. -/
def applyUnaryRules (cfg : ForwardConfig) (pool : ProofPool cfg.frameClass)
    : IO (ProofPool cfg.frameClass) := do
  let pool1 := applyNecessitation pool
  let pool2 := applyTemporalNecessitation pool1
  let pool3 := applyTemporalDuality pool2
  return pool3

/-! ## Bounded Fixpoint Loop and Ex-Falso Cap -/

/-- Check if a formula is an ex_falso instance (⊥ → φ). -/
def isExFalso : Formula → Bool
  | .imp .bot _ => true
  | _ => false

/--
Main forward-chaining generator.

1. Seeds the pool with `cfg.seedCount` axiom instances.
2. Caps ex_falso formulas at `cfg.exFalsoCap / cfg.exFalsoDenom` (default 20%).
3. Runs a bounded fixpoint closure under MP + unary rules up to `cfg.maxDepth`.
4. Returns the final list of `(formula, proof)` pairs.
-/
def forwardGenerate (cfg : ForwardConfig)
    : IO (List (Sigma fun φ => DerivationTree cfg.frameClass [] φ)) := do
  let startMs ← IO.monoMsNow
  let mut pool : ProofPool cfg.frameClass :=
    { ProofPool.empty with cap := cfg.maxPoolSize }

  -- Phase 1: Seed pool with axiom instances
  let seedStart ← IO.monoMsNow
  let progressInterval := max 1 (cfg.seedCount / 10)
  for i in List.range cfg.seedCount do
    let result ← instantiateAxiomWithProof cfg
    match result with
    | some ⟨φ, d⟩ => pool := pool.add φ d
    | none => pure ()
    if (i + 1) % progressInterval == 0 then
      let elapsed ← IO.monoMsNow
      IO.println
          s!"[proof-first] Seeding: {i + 1}/{cfg.seedCount}, pool size: {pool.size}, elapsed: \
              {elapsed - seedStart}ms"

  -- Phase 2: Cap ex_falso fraction
  let capStart ← IO.monoMsNow
  let exFalsoCount := pool.entries.foldl (fun acc σ =>
    if isExFalso σ.fst then acc + 1 else acc) 0
  let maxExFalso := pool.size * cfg.exFalsoCap / cfg.exFalsoDenom
  if exFalsoCount > maxExFalso then
    let mut newPool : ProofPool cfg.frameClass :=
      { ProofPool.empty with cap := cfg.maxPoolSize }
    let mut kept : Nat := 0
    for σ in pool.entries do
      if isExFalso σ.fst then
        if kept < maxExFalso then
          newPool := newPool.add σ.fst σ.snd
          kept := kept + 1
      else
        newPool := newPool.add σ.fst σ.snd
    let replacements := exFalsoCount - maxExFalso
    for _ in List.range replacements do
      let mut retry := 0
      let mut found := false
      while !found && retry < 5 do
        let result ← instantiateAxiomWithProof cfg
        match result with
        | some ⟨φ, d⟩ =>
          if !isExFalso φ then
            newPool := newPool.add φ d
            found := true
          else
            retry := retry + 1
        | none => retry := retry + 1
    pool := newPool
  let capEnd ← IO.monoMsNow
  IO.println s!"[proof-first] Ex-falso cap applied in {capEnd - capStart}ms, pool size: {pool.size}"

  -- Phase 3: Fixpoint closure under MP + unary rules
  let closureStart ← IO.monoMsNow
  for depth in List.range cfg.maxDepth do
    let prevSize := pool.size
    if prevSize ≥ cfg.maxPoolSize then
      IO.println s!"[proof-first] Pool cap reached at depth {depth}"
      break
    pool ← applyModusPonens cfg pool
    pool ← applyUnaryRules cfg pool
    let growth := pool.size - prevSize
    let growthRate := if prevSize > 0 then growth * 100 / prevSize else 100
    let elapsed ← IO.monoMsNow
    IO.println
        s!"[proof-first] depth={depth} pool={pool.size} (+{growth}, {growthRate}% growth) \
            elapsed={elapsed - closureStart}ms"
    if growthRate < 1 then
      IO.println s!"[proof-first] Fixpoint converged at depth {depth}"
      break

  let endMs ← IO.monoMsNow
  IO.println s!"[proof-first] Generation complete: {pool.size} theorems in {endMs - startMs}ms"
  return pool.toList

end FormalSystem.Automation
