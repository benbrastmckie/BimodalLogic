# Teammate B Findings: Convention Migration and Notational Alignment

## Key Findings

### 1. Complete Notational Divergence Map

The codebase diverges from Burgess 1982 in five systematic ways:

#### A. untl/snce Argument Order (PRIMARY)

| Position | Codebase | Burgess 1982 |
|----------|----------|--------------|
| 1st arg  | guard (φ) | event (α) |
| 2nd arg  | event (ψ) | guard (β) |

- **untl(guard, event)** vs **U(event, guard)** — exactly reversed
- Confirmed at: `Formula.lean:79-82` (constructor), `Truth.lean:127-130` (semantics)
- Scope: 2,141 references (1,164 untl + 977 snce) across 33 active files

#### B. Variable Naming Mismatch

The codebase's Greek letter usage is systematically swapped from Burgess:

| Variable | Codebase Meaning | Burgess Meaning |
|----------|-----------------|-----------------|
| `xi` (ξ) | guard of Until | event (endpoint) |
| `eta` (η) | event of Until | guard (intermediate) |
| `beta` (β) | guard element in burgessR | guard element in r-relation |
| `gamma` (γ) | event element in C | event element in C |

The `xi`/`eta` swap is explicitly documented across `PointInsertion.lean` at lines 3171, 3613, 3702, 3977, 4368 (e.g., "Convention: untl(xi, eta) = U(eta, xi) in Burgess. xi = guard (Burgess η), eta = event (Burgess ξ).").

The `beta`/`gamma` usage in `burgessR` accidentally aligns with Burgess (see Finding 2 below).

#### C. burgessR Definition (Accidentally Correct)

The `burgessR A β C` definition (ChronicleTypes.lean:292):
```lean
def burgessR (A : Set Formula) (β : Formula) (C : Set Formula) : Prop :=
  ∀ γ ∈ C, Formula.untl β γ ∈ A
```

Expanded: for all γ ∈ C, `untl(β=guard, γ=event) ∈ A`, which equals `U(γ, β) ∈ A`.

Burgess 2.3: r(A, β, C) iff for all γ ∈ C, `U(γ, β) ∈ A`.

**These match perfectly** under the current convention. The beta parameter IS the guard, matching Burgess's beta as guard. After a convention migration, `Formula.untl β γ` would mean `U(β=event, γ=guard)`, making burgessR WRONG — it would need `Formula.untl γ β` instead.

#### D. Axiom Naming vs Burgess Numbering

| Codebase Name | Burgess Axiom | Notes |
|---------------|---------------|-------|
| `left_mono_until` (BX2) | A1a | Left mono = "first arg mono" differs in meaning due to swap |
| `left_mono_until_G` (BX2G) | A1a variant | G-only version (open guard adaptation) |
| `right_mono_until` (BX3) | A2a | Right mono = "second arg mono" |
| `enrichment_until` (BX13) | A3a | Comment at Axioms.lean:169-177 explicitly bridges conventions |
| `separation_until` (BX14) | A4a | |
| `self_accum_until` (BX5) | A5a | |
| `absorb_until` (BX6) | A6a | |
| `linear_until` (BX7) | A7a | Different form (3 disjuncts vs Burgess's 3-way split) |

**BX numbering follows Burgess**: BX2=A1a, BX3=A2a, BX5=A5a, BX6=A6a, BX7=A7a. But BX13=A3a and BX14=A4a break the pattern. The "left/right" terminology reflects the CODEBASE argument order (left=guard=1st), not Burgess's (left=event=1st).

#### E. Derived Operator Definitions

```lean
def next (φ : Formula) : Formula := Formula.untl Formula.bot φ  -- Formula.lean:330
def prev (φ : Formula) : Formula := Formula.snce Formula.bot φ  -- Formula.lean:334
```

Current: `next(φ) = untl(bot, φ)` = guard=bot, event=φ. Semantically: ∃s>t, φ(s) ∧ ∀r∈(t,s), bot(r). Bot vacuously true, so: ∃s>t, φ(s). This is correct (X(φ) = next moment φ holds).

Burgess: F(α) = U(α, ⊤), meaning event=α, guard=⊤.

After migration: `next(φ) = untl(φ, bot)` where event=φ, guard=bot. Correct.

### 2. Three Migration Strategies Assessed

#### Strategy A: Semantics-Only Swap

**Change**: Swap phi/psi in `truth_at` for untl/snce cases (Truth.lean:127-130, 2 lines), swap axiom definitions (~35 constructors), swap derived operators (next/prev, 2 lines).

**Pros**: ~40 lines changed. Proofs compile unchanged.
**Cons**: Every variable name in the codebase becomes misleading. `xi` now means event (matching Burgess's ξ=event) by accident, but `eta` now means guard (matching Burgess's η=guard). However, all comments saying "xi = guard" become wrong. The burgessR definition BREAKS: `Formula.untl β γ ∈ A` now means `U(β, γ) ∈ A` (Burgess: `U(γ, β) ∈ A`). **Must also swap burgessR, burgessRSince, and all callers (~200+ sites).**

**True cost**: Not 40 lines — more like 200-300 once burgessR cascade is counted. And variable name confusion persists across 2000+ sites.

**Verdict**: POOR. Creates a two-layer confusion (semantics swapped but names not updated).

#### Strategy B: Full Swap + Variable Renaming

**Change**: Swap constructor arguments at every construction site (`Formula.untl a b` → `Formula.untl b a`), rename variables, update comments.

**Pros**: Complete alignment with Burgess. No confusion layer. Reading Burgess paper ↔ reading code with zero mental overhead.
**Cons**: ~1,100 lines changed across 33 files. 1-2 day effort. Risk of silent semantic errors (both args are `Formula` type).

**Mitigations**: 
- `lake build` catches structural mismatches
- Run soundness proofs to validate axiom-semantics alignment
- The swap is mechanical and can be batch-applied per file

**Verdict**: RECOMMENDED (but timing matters — see below).

#### Strategy C: Named Fields Only (No Semantic Change)

**Change**: Add field names to constructors:
```lean
| untl (guard : Formula) (event : Formula) : Formula
```

**Pros**: Zero risk. Self-documenting. IDE shows field names.
**Cons**: Doesn't solve the fundamental problem: reading Burgess's paper still requires mental swapping. Variable names throughout the codebase remain confusing relative to Burgess.

**Verdict**: USEFUL SUPPLEMENT but insufficient standalone. Could be done immediately as a low-risk improvement. Best combined with Strategy B later.

### 3. Timing Analysis: Before vs After Sorry Closure

**Strongly recommend: AFTER sorry closure.** Report 67 reached the same conclusion. Here's the deeper evidence:

**Evidence that convention swap does NOT help sorry closure**:
- The 2 remaining sorries (ChronicleConstruction.lean:1445, 1457) need `ξ ∈ limit_g(x,y)` — showing guard propagation through splitting steps. The mathematical content is identical regardless of argument order.
- The handoff `burgess-c5a-alignment.md` and `dom-unique-done-guard-analysis.md` both work with the current convention and have identified the exact proof strategy. Changing convention mid-stream would invalidate their code locations and variable references.

**Evidence that convention swap HURTS during sorry closure**:
- Plan 63 Phase 3 Task 3.7 is the active blocker. It references `lemma_2_7` with specific variable names (`xi ∈ B'`). Changing the convention would require rewriting the entire plan and all handoff documents.
- PointInsertion.lean has 1,068 untl+snce references — the largest file. It's also the file where `lemma_2_7` (the blocker) lives. A convention change here during active development is high-risk.

**Evidence that convention swap IS independently valuable**:
- Multiple research reports (35, 48, 59) have identified misreadings caused by the swapped convention. Report 35 explicitly flagged "Convention mismatch is FALSE ALARM" after days of investigation.
- The comment density on convention notes in PointInsertion.lean (lines 2857, 3171, 3613, 3702, 3977, 4368, 4725) shows how frequently developers need reminding.

### 4. Active Confusion Sources in Sorry Closure Work

**Currently NOT blocking**: The convention comments in PointInsertion.lean are frequent and explicit enough that the current sorry closure work (Phase 3 Tasks 3.7-3.8) can proceed. The main confusion risk comes from READING the Burgess paper, not from the code itself.

**One mitigation that could help NOW**: The `swap_temporal` function (Formula.lean:420-428) preserves argument position: `untl φ ψ → snce φ.swap_temporal ψ.swap_temporal`. This is correct under both conventions (guard stays guard, event stays event). No action needed.

### 5. Additional Notational Items Beyond untl/snce

**Lemma numbering**: The codebase uses `lemma_2_4`, `lemma_2_6`, `lemma_2_7`, `lemma_2_8` matching Burgess section numbers exactly. This is good and should be preserved.

**Condition numbering**: `c4_forward`/`c5_forward` in CounterexampleElimination.lean matches Burgess's C4a/C5a. Good alignment.

**Chronicle structure**: ChronicleTypes.lean's `Chronicle` type maps directly to Burgess's `(f, g)` pair with conditions C0-C5. Good alignment.

**rRelation vs burgessR**: The codebase has BOTH `rRelation` (obligation propagation, not from Burgess) and `burgessR` (content-based, from Burgess 2.3). This dual system could be confusing but is documented at ChronicleTypes.lean:273-286. `rRelation` is used in the omega chain invariant; `burgessR` is used in the point insertion lemmas. They serve different purposes.

**BurgessR3Maximal vs R3Maximal**: Both exist. `BurgessR3Maximal` uses `burgessR3` (content-based); `R3Maximal` uses `r3Relation` (obligation-based). The naming is clear enough.

## Recommended Approach

### Phase 1 (NOW — 0 effort): Keep current convention, close sorries
- No convention changes until Phase 3 Tasks 3.7-3.9 and Phase 4 Tasks 4.3-4.5 are done
- The existing convention comments in the code are sufficient

### Phase 2 (AFTER sorry closure — 0.5 day): Named fields as intermediate improvement
```lean
| untl (guard : Formula) (event : Formula) : Formula
| snce (guard : Formula) (event : Formula) : Formula
```
- Self-documenting, zero semantic risk
- Makes the current convention EXPLICIT rather than implicit
- IDE tooltips will show field names

### Phase 3 (AFTER Phase 2 — 1-2 days): Full Burgess alignment
- Strategy B: swap all constructor arguments
- Order: Truth.lean → Axioms.lean → Formula.lean (derived ops) → ChronicleTypes.lean (burgessR) → all other files
- Verify: `lake build` after each file cluster
- Final audit: 10 axiom proofs + 5 Chronicle lemmas spot-checked

### Alternative: Skip Phase 2, go directly to Phase 3 after sorry closure
- Phase 2 is insurance — it documents the current convention, reducing risk during Phase 3
- If sorry closure completes quickly and Phase 3 starts within the same work session, Phase 2 can be skipped

## Evidence/Examples

### Convention comment density (PointInsertion.lean)
- Line 2857: "Convention alignment with Burgess:"
- Line 3171: "Convention: untl(xi, eta) = U(eta, xi) in Burgess. xi = guard (Burgess η), eta = event (Burgess ξ)."
- Line 3613: "Convention: untl(xi, eta) = U(eta, xi) in Burgess."
- Line 3702: "Convention: xi = guard (our), eta = event (our)."
- Line 3977: "Convention: untl(xi, eta) = U(eta, xi) in Burgess."
- Line 4368: "Convention: snce(xi, eta) = S(eta, xi) in Burgess."

Six convention reminders in one file = a clear code smell that the convention is confusing.

### burgessR cascade risk (ChronicleTypes.lean:292)
`def burgessR (A) (β) (C) := ∀ γ ∈ C, Formula.untl β γ ∈ A`

Under current convention: `untl(β=guard, γ=event) = U(γ, β)` → matches Burgess r(A, β, C).
After semantics-only swap: `untl(β=event, γ=guard) = U(β, γ)` → WRONG (should be U(γ, β)).
After full swap: `untl(γ=event, β=guard) = U(γ, β)` → correct after adjusting the formula construction.

### Axiom convention bridging (Axioms.lean:169-177)
```lean
/-- BX13: Until-Since enrichment (Burgess A3a, Xu axiom (3)):
`p ∧ (φ U ψ) → (φ ∧ S(φ, p)) U ψ` (in our guard-first convention:
`p ∧ untl(φ, ψ) → untl(φ, ψ ∧ snce(φ, p))`). -/
```
Every axiom docstring carries an explicit convention bridge. After migration, these become simple direct translations.

### Xu convention note (RRelation.lean:1398-1399)
```
Convention note: In Xu's notation U(event, guard), so Xu's "U(γ, β)" = our untl(β, γ).
```
After migration, this note becomes: "Xu's U(γ, β) = our untl(γ, β)" — no mental swap needed.

## Confidence Level

**High** — This analysis is based on direct code inspection of all relevant files, cross-referenced with the Burgess paper and report 67. The timing recommendation (after sorry closure) is unanimous across all prior analyses.
