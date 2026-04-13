# Teammate A Findings: Until Induction Axiom Path

- **Task**: 102 - implement_quotient_filtration_close_sorries
- **Session**: sess_1776050388_teammate_a
- **Artifact**: 05_teammate-a-findings.md
- **Angle**: Until induction axiom investigation

---

## Key Findings

### 1. The Reflexive Until Induction Axiom — Exact Form

The Until induction axiom in the reflexive (BX) semantics takes this form:

```
G(ψ → χ) ∧ G((φ ∧ χ) → χ) → ((φ U ψ) → χ)
```

Verbally: "If ψ implies χ everywhere (base), and φ∧χ implies χ everywhere (step), then φ U ψ implies χ."

This is the **reflexive-semantics simplification** of the original X-based Until induction:

```
G(ψ → χ) ∧ G((φ ∧ X(χ)) → χ) → ((φ U ψ) → X(χ))   [strict/X version]
```

Under reflexive semantics, `X(α) = α` (proved in task 85), so the X-based step condition `G((φ ∧ X(χ)) → χ)` simplifies to `G((φ ∧ χ) → χ)`, and the conclusion `X(χ)` simplifies to `χ`. This is documented in:
- `specs/archive/086_close_bxcanonical_completeness_sorries/reports/01_team-research.md:63-67`
- `specs/archive/084_establish_until_since_coherent/reports/02_teammate-c-findings.md:145`

### 2. Was It Ever in This Codebase?

Yes, but only in the **X-based (strict semantics) form**. The axiom `until_induction` was present in `Theories/Bimodal/ProofSystem/Axioms.lean` with this signature (from git commit `a34643e49`):

```lean
| until_induction (φ ψ χ : Formula) :
    Axiom (Formula.and
      ((ψ.imp χ).all_future)
      (((Formula.and φ (Formula.untl Formula.bot χ)).imp χ).all_future)
      |>.imp ((Formula.untl φ ψ).imp (Formula.untl Formula.bot χ)))
```

Here `Formula.untl Formula.bot χ` is `⊥ U χ` which represents `X(χ)` in the strict setting.

This axiom was **removed** in the task 83 Phase 1 refactor (commit `1d9bd6160`: "task 83 phase 1: reflexive U/S semantics + partial BX axiom replacement"). It was replaced by:
- **BX5** (`self_accum_until`): `(φ U ψ) → ((φ ∧ (φ U ψ)) U ψ)`
- **BX6** (`absorb_until`): `(φ U (φ ∧ (φ U ψ))) → (φ U ψ)`
- **BX7** (`linear_until`): Three-way linearity axiom for Until witnesses

The rationale given in the Soundness.lean comment (line ~801):
> "These [BX5/BX6/BX7] replace the old `until_induction` from the discrete system. BX5+BX6 resolve Until-eventualities axiomatically."

The reflexive form of the induction axiom has **never been in the codebase** as a named axiom.

### 3. Soundness on All Linear Orders

The reflexive Until induction axiom `G(ψ → χ) ∧ G((φ ∧ χ) → χ) → ((φ U ψ) → χ)` is **sound on all linear orders** (not just discrete ones).

**Soundness proof sketch**: Let the premises hold at time t. Let `φ U ψ` hold at t, so there exists s ≥ t with `ψ(s)` and `φ(r)` for all t ≤ r < s. From the base premise `G(ψ → χ)`, we have `χ(s)`. We now induct backward: for t ≤ r < s, the step premise `G((φ ∧ χ) → χ)` at r gives us: if `χ` holds at some r' > r (close enough), then since `φ(r)` holds, `χ(r)` holds. In a linear order, this backward induction from s to t closes the chain. More precisely, since the order is linear, the set `{r ≥ t : χ(r)}` is nonempty (contains s) and downward-closed under the step condition, so it contains t.

The key property required is **linearity** of the order — the axiom fails on non-linear (branching-time) frames because the backward induction cannot reach t from all branches simultaneously. This matches the current BX system where all axioms are sound on linear orders.

**The old discrete axiom** also required linearity but additionally required discreteness (the X-step `G((φ ∧ X(χ)) → χ)` is trivially satisfied at limit ordinals since X is undefined there). The reflexive form has no such issue — it works at all time points in any linear order.

### 4. Would It Close the 4 Frame.lean Sorries?

**Yes, with high confidence**, but indirectly and through a non-trivial route.

The 4 Frame.lean sorries all have the pattern: given `φ U ψ ∈ w` and `ψ ∉ w`, find v with `ψ ∈ v` and `bx_le w v`, such that the guard `φ ∈ u` holds for all intermediate u. The fundamental obstacle is:

> `bx_le u v` only propagates G-content, so `φ ∈ u'` (with `bx_le u' u`) does NOT imply `φ ∈ u` unless `φ` itself is a G-formula.

The Until induction axiom would help as follows:

**Step 1** (already proved): From `φ U ψ ∈ w` and MCS properties, `F(ψ) ∈ w` (by BX10), so `¬G(¬ψ) ∈ w`.

**Step 2** (new): If Until induction is available, it provides a proof of `{ψ} ∪ g_content(w)` consistency — the **same role it was designed for** in `until_witness_seed_consistent` (WitnessSeed.lean:334). The comment there explicitly says: "Apply `until_induction` with χ = ⊥: `G(ψ → ⊥) ∧ G((φ ∧ ⊥) → G(⊥)) → ((φ U ψ) → ⊥)`." But importantly, the **current proof in WitnessSeed.lean does NOT use until_induction** — it uses BX10 contradiction instead. So this step is already handled.

**The real use**: The Until induction axiom would be needed to prove the **guard property** at the MCS level:

> If `G(¬φ) ∈ u` (meaning `φ ∉ u` via G-propagation), can we derive a contradiction with `φ U ψ` being in some ancestor?

More directly: the guard property requires proving that for `u` with `bx_le w u` and `bx_le u v` (strict), `φ ∈ u`. Using Until induction with `χ := ¬(φ U ψ)` (or `χ := φ`):

- Base: `G(ψ → φ)` — NOT derivable in general
- Step: `G((φ ∧ φ) → φ)` — trivially true (`φ → φ`)

The base condition fails because ψ implies χ is not provable without additional information. So **Until induction alone is insufficient to close the guard property** as stated in Frame.lean.

The real impact is on the **seed consistency proof** and **eventuality existence**, not on the guard propagation over arbitrary intermediate BXPoints. The guard property requires totality of the bx_le ordering on the interval [w, v], which Until induction does not provide.

### 5. The WitnessSeed.lean Case — Critical Analysis

The `until_witness_seed_consistent` theorem in WitnessSeed.lean (lines 342–415) was annotated as needing `until_induction` but actually proves the result using BX10 (`(φ U ψ) → F(ψ)`) contradiction. This is the key observation:

The comment says "Apply until_induction with χ = ⊥" but the **actual Lean code** uses:
```lean
have h_F_psi : ψ.some_future ∈ M :=
  SetMaximalConsistent.implication_property h_mcs
    (theorem_in_mcs h_mcs (Bimodal.Theorems.TemporalDerived.until_imp_F φ ψ)) h_U
```

This means: BX10 already handles the seed consistency case that until_induction was supposed to handle. Adding until_induction back would not change `until_witness_seed_consistent`.

The remaining question is whether Until induction helps with the **guard at intermediate BXPoints**. It does not, for the same architectural reason documented throughout the research: arbitrary intermediate BXPoints under the non-total `bx_le` preorder are "junk points" that no axiom-level argument can control.

### 6. Impact on Existing Proofs — What Would Change

If the reflexive Until induction axiom were added to `Axioms.lean`:

**Changes required**:
1. `Axioms.lean`: Add new constructor (e.g., `until_induction_refl`) — 5 lines
2. `Soundness.lean`: Add soundness proof for the new axiom — 15-20 lines
3. `Substitution.lean`: Add substitution case — 3-5 lines
4. `Completeness.lean` and `TruthLemma.lean`: Would NOT automatically close the 4 Frame.lean sorries (see finding #4)

**Proofs that would NOT break**:
- All existing proofs remain valid — adding an axiom only extends the derivability relation
- The soundness theorem structure already has an `isBase` predicate covering all existing axioms; the new axiom is also base-valid (linear orders suffice)

**Implementation effort**: ~30-40 lines of code across 3 files. Very low cost.

### 7. Prior Research Documentation

Several prior research rounds independently identified the reflexive Until induction axiom:

- **specs/archive/086.../01_team-research.md:55-67**: "Until-Induction Is the Missing Piece" — identified reflexive form, estimated 8-16 hours to derive from BX5+BX6+BX7, suggested re-adding as axiom as fallback
- **specs/archive/085.../01_teammate-b-findings.md:142**: Listed as `G(psi -> chi) AND G((phi AND (chi U chi)) -> chi) -> ((phi U psi) -> (chi U chi))` (note: this is incorrect — the step uses `chi U chi` = X(chi) which is wrong for reflexive)
- **CanonicalChain.lean:36**: Explicitly listed as one of three things that "would close" the Frame.lean sorries
- **Task 83 boneyard** (FiniteDeferral.lean:325): Has a sorry comment `sorry /- until_induction removed in BX -/` confirming its removal

---

## Recommended Approach

**Do NOT re-add Until induction as the primary fix for Frame.lean.**

The reasoning:
1. Until induction closes the **seed consistency** problem — but BX10 already handles that (WitnessSeed.lean is sorry-free).
2. Until induction does NOT close the **guard property** over arbitrary intermediate BXPoints — this requires totality of bx_le on intervals, which no pure axiom addition can provide.
3. The Frame.lean sorry signatures are quantified over ALL BXPoints in a bx_le interval, which includes "junk points" with no connection to the specific Until formula.

**The correct path** (consistent with Round 3 consensus): The chain-based completeness proof (Option 3 from report 04, Path 1 from report 03) bypasses Frame.lean entirely by constructing a linear canonical model where the ordering is positional (total by construction). The guard property is then trivially satisfied for chain members.

**If Until induction is to be added anyway** (e.g., for completeness of the axiom system documentation):
1. Add `until_induction_refl` constructor to `Axioms.lean` with form `G(ψ → χ) ∧ G((φ ∧ χ) → χ) → ((φ U ψ) → χ)`
2. Prove soundness in `Soundness.lean` (straightforward by backward induction on the linear order)
3. This would not break any existing proofs

---

## Evidence/Examples

### Evidence 1: WitnessSeed.lean Comment vs. Actual Code Mismatch

The comment at WitnessSeed.lean:334 says "Apply until_induction with χ = ⊥" but lines 409-415 show the actual proof uses `until_imp_F` (BX10). This is conclusive evidence that the "missing until_induction" concern for seed consistency is already resolved by BX10.

### Evidence 2: The Guard Problem is Structural

From CanonicalChain.lean docstring (lines 24-32):
```
This is unprovable from BX1-BX12 because:
1. bx_le (defined as g_content ⊆) is a non-total preorder
2. The proof obtains φ ∈ u' for some u' with bx_le u' u (via backward
   witness + BX9), but φ ∈ u' cannot be lifted to φ ∈ u through bx_le
   because bx_le only propagates G-content
3. BX11 (temporal linearity) constrains F-witnesses but not arbitrary
   BXPoints in a bx_le interval
```

Until induction with `χ = φ` requires base `G(ψ → φ)` — not provable from `φ U ψ ∈ w` alone.

### Evidence 3: Historical Removal was Deliberate

Commit `1d9bd6160` replaced until_induction with BX5/BX6/BX7 explicitly for the **reflexive semantics refactor**. The BX system was designed to be a complete set of axioms for linear orders without needing the induction axiom (replaced by self-accumulation + absorption + linearity). The semantic equivalence of `{BX5, BX6, BX7}` to Until induction on linear orders means derivability is preserved — the axiom is redundant, not missing.

### Evidence 4: Archive Boneyard Documents the Dead End

`FiniteDeferral.lean:324-325` contains:
```lean
-- until_induction axiom: G(¬ψ) ∧ G(step) → ((¬⊥ U ψ) → (⊥ U ⊥))
have h_ax := sorry /- until_induction removed in BX -/ ψ Formula.bot)
```

This sorry was introduced when trying to use until_induction in the boneyard chain construction — and it is ALREADY a boneyard file, meaning this approach was abandoned.

---

## Feasibility Assessment

| Question | Answer | Confidence |
|----------|--------|------------|
| Is the reflexive Until induction derivable from BX1-BX12? | Likely yes (BX5+BX6+BX7 are semantically equivalent) | MEDIUM (70%) |
| Would adding it as a new axiom be sound? | Yes, sound on all linear orders | HIGH (95%) |
| Would it close the 4 Frame.lean sorries as stated? | No — guard problem is structural | HIGH (85%) |
| Would it break existing proofs? | No — only adds derivability | HIGH (99%) |
| Was it previously in the codebase? | Yes, X-based form only, removed deliberately in task 83 | HIGH (99%) |
| Is BX10 already covering the "seed consistency" role? | Yes — WitnessSeed.lean is sorry-free | HIGH (99%) |

---

## Confidence Level: **HIGH**

The evidence from code archaeology, prior research synthesis, and direct analysis of the Frame.lean sorry structure converges strongly:

1. The reflexive Until induction axiom (`G(ψ → χ) ∧ G((φ ∧ χ) → χ) → ((φ U ψ) → χ)`) is sound on all linear orders
2. It was deliberately removed and replaced by BX5+BX6+BX7 (semantically equivalent on linear orders)
3. Re-adding it would not close the 4 Frame.lean sorries because the guard problem is about non-total bx_le ordering over arbitrary BXPoints — a structural issue no axiom addition resolves
4. The chain-based completeness proof (bypassing Frame.lean) remains the correct path forward

The one potential utility: if someone needs to **derive** Until induction from BX5+BX6+BX7 as a named theorem (for pedagogical or reuse purposes), that would be a valid ~8-16 hour proof-engineering exercise. But it would not unblock task 102.
