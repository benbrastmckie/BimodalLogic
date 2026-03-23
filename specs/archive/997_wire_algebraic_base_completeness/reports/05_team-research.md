# Research Report: Task #997 — Succ-Chain Bypass for Base Completeness

**Task**: wire_algebraic_base_completeness
**Date**: 2026-03-22
**Mode**: Team Research (2 teammates)
**Session**: sess_1774238975_1de1fa

## Summary

Both teammates converge strongly on **Option B: Succ-chain bypass** as the correct approach for mathematically sound, zero-technical-debt completeness. The BFMCS approach has architecturally unprovable sorries due to W=D conflation and cross-family modal coherence requirements that TM logic cannot satisfy. The Succ-chain infrastructure is mature, with sorry-free TaskFrame and WorldHistory constructions already in place.

The key pivot: **focus on CanonicalTask (the three-place task relation) rather than CanonicalR (the existential shadow)**. CanonicalTask directly instantiates TaskFrame Int, provides bounded witness semantics, and aligns with the reflexive temporal semantics established by Task 29.

---

## Key Findings

### 1. BFMCS Is Architecturally Blocked (Both Teammates — HIGH Confidence)

The BFMCS `modal_forward` condition requires cross-family S5 transfer:
```
Box phi in fam.mcs t -> phi in fam'.mcs t (for ALL families)
```

TM's S5 axioms (T, 4, B, modal_5_collapse) operate **within** individual MCS, not across families. This is not a proof gap — it is an **architectural impossibility** under the current semantics. The 5 inherited sorries are fundamentally unprovable.

### 2. CanonicalTask vs CanonicalR — The Critical Distinction

| Aspect | CanonicalR | CanonicalTask |
|--------|-----------|---------------|
| Definition | `g_content M ⊆ N` | Three-place: `(u, n, v)` counting Succ steps |
| Information | Binary accessibility | Quantitative chain distance |
| TaskFrame | Cannot instantiate directly | Directly gives `TaskFrame Int` |
| Witness semantics | None | `bounded_witness` theorem |
| Semantic alignment | Existential shadow | True task relation |

**CanonicalR is a distraction from Task Semantics**. It collapses the rich three-place task relation into a binary approximation, losing the duration parameter that makes Task Semantics distinct from Kripke semantics.

### 3. Succ-Chain Infrastructure Is Mature (Teammate A — HIGH Confidence)

| File | Status | Purpose |
|------|--------|---------|
| `SuccRelation.lean` | 1 sorry (P-direction) | Succ definition, single_step_forcing |
| `SuccExistence.lean` | 3 axioms | successor/predecessor existence |
| `CanonicalTaskRelation.lean` | 2 sorries (P-direction) | CanonicalTask + bounded_witness |
| `SuccChainFMCS.lean` | 3 axioms | succ_chain_fam, F/P coherence |
| `SuccChainTaskFrame.lean` | **0 sorries** | CanonicalTaskTaskFrame (TaskFrame Int) |
| `SuccChainWorldHistory.lean` | **0 sorries** | WorldHistory from Succ-chain |

The core path (TaskFrame + WorldHistory) is **sorry-free**. The remaining issues are in:
- Succ existence axioms (Task 34 targeting these)
- Nesting boundary axioms (provable via formula induction)
- P-direction theorems (not on critical path for standard completeness)

### 4. Reflexive Semantics Simplifies Everything (Teammate B — HIGH Confidence)

Task 29 established reflexive temporal semantics:
- `G phi` and `H phi` use `<=` (including current time)
- T-axioms (`G phi -> phi`, `H phi -> phi`) are semantically valid
- No irreflexivity axioms needed
- Seriality (F⊤, P⊤) is trivially valid under reflexive G/H
- Aligns with Layer 1 (basic completeness) — no order-theoretic enhancements required

### 5. The Mathematical Path to Completeness

```
MCS M (with ¬φ)
    │
    ▼ [successor_exists / predecessor_exists]
succ_chain_fam M₀ : ℤ → Set Formula (bi-infinite chain of MCS)
    │
    ▼ [succ_chain_canonical_task]
CanonicalTask relationship between chain elements
    │
    ▼ [CanonicalTaskTaskFrame]  ← SORRY-FREE
TaskFrame ℤ instance
    │
    ▼ [succ_chain_history]  ← SORRY-FREE
WorldHistory CanonicalTaskTaskFrame
    │
    ▼ [bounded_witness + F/P coherence]
Truth Lemma: φ ∈ fam.mcs t ↔ truth_at model Ω history t φ
    │
    ▼ [contrapositive]
Completeness: valid φ → ⊢ φ
```

### 6. Remaining Axioms (All Semantically Justified)

| Axiom | File | Purpose | Provability |
|-------|------|---------|-------------|
| `successor_deferral_seed_consistent` | SuccExistence | Seed consistency for successor | Task 34 in progress |
| `predecessor_deferral_seed_consistent` | SuccExistence | Seed consistency for predecessor | Task 34 in progress |
| `predecessor_f_step` | SuccExistence | F-step for predecessor Succ | Task 34 in progress |
| `succ_chain_fam_p_step` | SuccChainFMCS | P-step along chain | Provable via induction |
| `f_nesting_boundary` | SuccChainFMCS | F^n(φ) finite nesting | Provable via formula structure |
| `p_nesting_boundary` | SuccChainFMCS | P^n(φ) finite nesting | Provable via formula structure |

**Key**: 3 axioms targeted by Task 34; 3 nesting/step axioms provable via well-founded induction on formula depth.

---

## Synthesis

### Conflicts Resolved

**No conflicts.** Both teammates converge on the same conclusion: Succ-chain bypass is the correct approach. Their findings are complementary:
- Teammate A provided implementation-level analysis (code paths, sorry inventory, concrete phases)
- Teammate B provided mathematical foundations (why BFMCS fails, what properties are needed, semantic analysis)

### Gaps Identified

1. **Truth Lemma for Succ-chain model**: The connection from `phi ∈ succ_chain_fam M₀ t` to `truth_at model Ω history t phi` needs explicit construction. Infrastructure exists but the lemma itself may need to be written.

2. **P-direction completion**: P-direction sorries exist in SuccRelation and CanonicalTaskRelation. These may be needed for the full bidirectional Truth Lemma. Needs investigation during planning.

3. **Validity quantification**: The completeness theorem needs to show that validity over ALL TaskModels implies provability. The canonical model provides one specific model — need to clarify the contrapositive structure.

4. **Integration decision**: Should the new Succ-chain completeness theorem replace or coexist with the BFMCS-based `algebraic_base_completeness`?

### Recommendations

1. **Revise task 997 plan** to target Succ-chain completeness, abandoning BFMCS wiring

2. **Phase structure for revised plan**:
   - Phase 1: Verify existing Succ-chain infrastructure compiles (2h)
   - Phase 2: Construct truth lemma connecting chain membership to truth_at (4h)
   - Phase 3: Wire completeness theorem via contrapositive (2h)
   - Phase 4: Address remaining axioms (ongoing, partially via Task 34)

3. **Deprecate BFMCS pathway**: Mark DirectMultiFamilyBFMCS and IntFMCSTransfer as deprecated/superseded

4. **Focus on CanonicalTask throughout**: All new code should reference CanonicalTask, not CanonicalR

---

## Teammate Contributions

| Teammate | Angle | Status | Confidence | Key Contribution |
|----------|-------|--------|------------|-----------------|
| A | CanonicalTask Succ-chain approach | completed | HIGH | Sorry inventory, implementation phases, bounded_witness analysis |
| B | Mathematical foundations | completed | HIGH | BFMCS impossibility proof, Task Semantics analysis, reflexive benefits |

---

## References

### Codebase
- `Theories/Bimodal/Metalogic/Bundle/SuccRelation.lean` — Succ definition, single_step_forcing
- `Theories/Bimodal/Metalogic/Bundle/SuccExistence.lean` — Successor/predecessor existence
- `Theories/Bimodal/Metalogic/Bundle/SuccChainFMCS.lean` — Succ-chain FMCS construction
- `Theories/Bimodal/Metalogic/Bundle/SuccChainTaskFrame.lean` — CanonicalTaskTaskFrame
- `Theories/Bimodal/Metalogic/Bundle/SuccChainWorldHistory.lean` — WorldHistory construction
- `Theories/Bimodal/Metalogic/Bundle/CanonicalTaskRelation.lean` — CanonicalTask + bounded_witness
- `Theories/Bimodal/Metalogic/Bundle/BFMCS.lean` — BFMCS (to be deprecated)
- `Theories/Bimodal/Metalogic/Bundle/DirectMultiFamilyBFMCS.lean` — W=D analysis (to be deprecated)
- `Theories/Bimodal/Semantics/TaskFrame.lean` — TaskFrame structure
- `Theories/Bimodal/Semantics/Truth.lean` — Truth definition (reflexive)

### Prior Reports
- `specs/997_wire_algebraic_base_completeness/reports/04_mid-implementation-review.md` — Option B first identified
- `specs/006_canonical_taskframe_completeness/reports/20_succ-based-bypass-of-covering-lemma.md` — Original Succ bypass analysis
