# Teammate D (Horizons) Research Findings — Task 141

## Key Findings

### 1. The 8 Sorries Form Two Independent Groups

The task inventory groups the sorries correctly, but strategically they have different natures:

**Group A — TruthLemma.lean (6 sorries): One root cause, two proof patterns**

The 6 TruthLemma sorries reduce to two root blockers:

- **`until_forward_mcs` sorry (line 426)**: The "intermediate guard condition" — for all z strictly between x and y in the canonical order, psi2 must be in z.val. This requires propagating ψ₂ through intermediate MCS points via a chain construction. The key infrastructure is BX5 (self_accum_until), but the chain proof is blocked by two interdependent missing theorems:
  - `until_unfold_thm` (sorry in TemporalDerived.lean:381) — This needed BX9 which was removed under open-guard semantics (Task 113)
  - `refl_F` (sorry in TemporalDerived.lean:431) — α → F(α) is not valid under irreflexive semantics

- **`until_backward_mcs` sorry (line 443)**: Counter-witness propagation. The contrapositive direction needs the same chain infrastructure.

- **`since_forward_mcs` / `since_backward_mcs`**: Mirror the Until sorries exactly (past direction).

- **`truth_lemma` Until/Since cases (lines 548, 563)**: Declared dependent on the above 4 — they are structural glue that uses the above 4 lemmas and will close once those are proved.

**Critical discovery**: `until_F_expansion` (TemporalDerived.lean:455) itself depends on both `until_unfold_thm` AND `refl_F`, which are both sorry'd. So `until_F_expansion` — cited in TruthLemma.lean's own commentary as the key infrastructure needed — is itself sorry'd. This means the chain cannot be constructed using the documented approach.

**Group B — ReflexiveCanonical.lean (2 sorries): Independent, well-specified**

- **`reflCanR_linear` (line 144)**: Proof path is fully documented in the sorry comment: use BX11 (temp_linearity) + forward_temporal_witness. This is a standard linearity argument for canonical temporal frames. The BX11 axiom exists (temp_linearity in Axioms.lean), and the forward_temporal_witness seed construction exists (in Bundle/CanonicalFrame.lean and BXCanonical/Frame.lean). The proof requires porting `bx_forward_witness` / `bx_G_backward` pattern from BXCanonical/Frame.lean to ReflCanDomain.

- **`canS5R_symm` (line 424)**: Uses modal_b (φ → □◇φ). The axiom exists (Axiom.modal_b in Axioms.lean). The proof pattern is analogous to the `canS5R_trans` proof above it (which uses modal_4 successfully). canS5R_symm needs modal_b + a duality argument.

### 2. The Real Blocker: Open-Guard Semantics Break the Standard Chain Construction

Task 113 (open-guard semantics) removed BX8 (until_step / `ψ → (φ U ψ)`) and BX9 (until_elim) as axioms. The entire Burgess chain construction for Until guard propagation relied on these axioms. Specifically:

- The standard proof that "intermediate points in a canonical Until chain all contain ψ₂" uses: given that φ U ψ₁ is at x, BX5 gives φ U (ψ₂ ∧ (φ U ψ₁)) at x (self-accumulation), so at every intermediate z, both ψ₂ holds AND φ U ψ₁ holds. The chain then terminates at y with ψ₁.
- Under open-guard semantics, `until_unfold_thm` (`(φ U ψ) → ψ ∨ (φ ∧ (φ U ψ))`) is NO LONGER VALID because BX9 is gone. The intermediate points in an interval (t, s) do not include t, so one cannot "unfold" the Until at the current point.

This means the standard textbook chain construction (Burgess 1982, Reynolds 1992) does NOT directly apply to the `ReflCanDomain` / open-guard setting without significant adaptation.

### 3. Literature Alignment Analysis

**Reynolds 1992 (US/R without IRR)** — Section 4 describes the Burgess–Xu completeness proof for linear flows. The key step for Until truth is: given U(A,B) at point t, one constructs a witness s > t with A(s) and B at all points in (t,s). The mechanism is:
1. Place the MCS containing U(A,B) at some rational point
2. For each counter-example tuple (t, U(A,B)), find a new MCS for s
3. Use the "Dovetailing" process to ensure no counter-examples persist

The guard condition satisfaction relies on placing MCS points at intermediate rationals. Under **open-guard** (strict interval), this is structurally compatible: the witnesses are at strict future points. The issue is that the **axioms** used to prove consistency of the witness seed have changed (no BX9 to extract the guard formula from the current point).

**Burgess 1982 (Axioms for tense logic)** — The original construction in Section 2 is for a **linear class** of frames (not a specific flow), which gives strong completeness. It uses BX8/BX9 as named lemmas. The open-guard version needs to replace these.

**Key observation**: The open-guard change is actually semantically compatible with the Burgess/Reynolds proof *structure* — the interval (t,s) is open in both the Burgess proof and our semantics. The difference is that we cannot derive `(φ U ψ) → ψ ∨ (φ ∧ (φ U ψ))` as a theorem at t, because that would require ψ or φ to hold *at t*, not just in (t, s). However, **BX5 self-accumulation** (`U(ψ, φ) → U(ψ, φ ∧ U(ψ, φ))`) IS valid: it says the guard formula also satisfies the Until formula at intermediate points. This is the correct tool for the chain argument.

### 4. Viable Proof Strategy for Group A (TruthLemma)

The correct approach that avoids the removed BX8/BX9 axioms:

**For `until_forward_mcs` guard condition**:

The standard open-guard chain argument works as follows. Given U(ψ₁, ψ₂) ∈ x.val, the construction already (correctly) builds witness y with ψ₁ ∈ y and g_content(x) ⊆ y. The remaining goal is: for all z with tempR_fwd x z and tempR_fwd z y, ψ₂ ∈ z.

Proof by contradiction: Suppose z is a counter-example (g_content(x) ⊆ z, g_content(z) ⊆ y, but ψ₂ ∉ z). Then ¬ψ₂ ∈ z (by negation completeness). But by BX5 (self_accum_until): U(ψ₁, ψ₂) ∈ x → U(ψ₁, ψ₂ ∧ U(ψ₁, ψ₂)) ∈ x. Since g_content(x) ⊆ z, and G(ψ₂ ∧ U(ψ₁, ψ₂)) ... but this requires G(U(ψ₁, ψ₂)) ∈ x to propagate, which is not given.

Alternative: use `g_content_closed_derivation` (already proved sorry-free in ReflexiveCanonical.lean) with BX5. If U(ψ₁, ψ₂) ∈ x.val, then by g_content_closed_derivation applied to G(U(ψ₁, ψ₂)→ U(ψ₁, ψ₂ ∧ U(ψ₁, ψ₂))), we get G(U(ψ₁, ψ₂ ∧ U(ψ₁, ψ₂))) ∈ x.val... Actually this does not work directly since we need G(U(ψ₁, ψ₂)) ∈ x first.

**More precisely**: The key insight is that under open-guard semantics, `g_content_closed_derivation` plus `self_accum_until` can achieve what was previously done with the full chain. Specifically:

1. U(ψ₁, ψ₂) ∈ x (given)
2. By `self_accum_until` (BX5): U(ψ₁, ψ₂ ∧ U(ψ₁, ψ₂)) ∈ x (MCS closure)
3. For any z with tempR_fwd x z and tempR_fwd z y: ψ₂ ∧ U(ψ₁, ψ₂) ∈ z would suffice (gives ψ₂ ∈ z)
4. This reduces to showing: U(ψ₁, ψ₂ ∧ U(ψ₁, ψ₂)) ∈ x → for all z in (x, y), ψ₂ ∧ U(ψ₁, ψ₂) ∈ z

Step 4 still requires G(ψ₂ ∧ U(ψ₁, ψ₂)) ∈ x (or at least that ψ₂ ∧ U(ψ₁, ψ₂) propagates via the temporal relation), which requires that the Until formula itself is in G-content of x. This requires either an additional fixpoint argument or a direct chain induction.

**The most direct approach**: Use the `BXCanonical/Filtration/DefectChain.lean` infrastructure which already implements BX5-based chain reasoning (specifically `defect_step_self_accum`). Port or adapt that construction to `ReflCanDomain`.

**For `until_backward_mcs`**:

The contrapositive direction: if U(ψ₁, ψ₂) ∉ x.val, then ¬U(ψ₁, ψ₂) ∈ x (negation completeness). For any y with tempR_fwd x y and ψ₁ ∈ y, find intermediate z with ψ₂ ∉ z. By BX6 (Axiom.bx6_absorption: `U(φ ∧ U(ψ,φ), φ) → U(ψ,φ)`) combined with ¬U(ψ₁, ψ₂) ∈ x, one derives the required counter-witness via g_content and negation.

### 5. Assessment of canS5R_symm

This sorry is **straightforward** given the existing axiom infrastructure:

```lean
-- canS5R x y means: ∀ φ, □φ ∈ x.val → φ ∈ y.val
-- Want: canS5R y x, i.e., ∀ φ, □φ ∈ y.val → φ ∈ x.val
-- 
-- Given □φ ∈ y.val and canS5R x y (so ∀χ, □χ ∈ x.val → χ ∈ y.val):
-- 
-- Strategy: Suppose □φ ∉ x.val. Then ¬□φ ∈ x.val (negation completeness).
-- By modal_b on ¬□φ: ¬□φ → □◇(¬□φ), so □◇(¬□φ) ∈ x.val.
-- By canS5R x y: ◇(¬□φ) ∈ y.val.
-- ◇(¬□φ) = ¬□¬(¬□φ) = ¬□(□φ) ... no, ◇(¬□φ) = (¬□φ).diamond_neg...
-- Actually easier: use modal_b directly.
-- From □φ ∈ y.val, want □φ ∈ x.val.
-- By canS5R x y: if □(□φ) ∈ x.val then □φ ∈ y.val (given).
-- By modal_4 on x: □φ ∈ x.val → □□φ ∈ x.val (NOT what we want).
-- Use S5 argument: if □φ ∉ x.val, then ◇(¬φ) ∈ x.val.
-- By canS5R x y: ¬φ ∈ y.val. But □φ ∈ y.val gives φ ∈ y.val (modal_t). Contradiction.
```

Wait — this doesn't use modal_b at all. The correct proof is:

Given `canS5R x y` (h: ∀ χ, □χ ∈ x → χ ∈ y), to show `canS5R y x` (∀ φ, □φ ∈ y → φ ∈ x):

Suppose □φ ∈ y.val. We want φ ∈ x.val.

By modal_b applied to φ in x: φ → □◇φ is a theorem, so if φ ∈ x.val then □◇φ ∈ x.val. (Not directly useful.)

Correct S5 approach: Suppose ¬φ ∈ x.val. Then by `bx_modal_witness` style argument on x (or by h applied backwards): We need □(¬φ) or ◇(¬φ) in x.val... By canS5R x y and ¬φ ∈ x... Actually the cleanest proof:

By modal_b: φ → □◇φ, so if φ ∉ x then... the issue is canS5R is defined as a one-way implication. The correct S5 canonical model proof for symmetry requires proving the B axiom at the MCS level.

Straightforward path: if □φ ∈ y but φ ∉ x.val, then ¬φ ∈ x.val (negation completeness). By `canS5R x y` applied to ¬φ (if □(¬φ) ∈ x) we'd get ¬φ ∈ y, but □φ ∈ y → φ ∈ y (modal_t), contradiction. But we need □(¬φ) ∈ x.

By modal_b on ¬φ: ¬φ → □◇(¬φ) ∈ x.val (theorem in MCS). ◇(¬φ) = ¬□¬(¬φ) = ¬□(φ) (in classical logic). Wait, ◇φ := ¬□(¬φ) by definition in the codebase (diamond ψ = (neg ψ).box.neg). So ◇(¬φ) = ¬□(¬(¬φ)) = ¬□φ. So modal_b gives: ¬φ → □(¬□φ). With ¬φ ∈ x.val, we get □(¬□φ) ∈ x.val. By canS5R x y: ¬□φ ∈ y.val. But □φ ∈ y.val and ¬□φ ∈ y.val contradicts y.val consistent. **This works.**

So `canS5R_symm` can be proved with: negation completeness + modal_b + implication property + MCS consistency.

### 6. Assessment of reflCanR_linear

The sorry comment gives the complete proof path:
1. From ¬tempR_fwd y z: obtain ψ with Gψ ∈ y.val, ψ ∉ z.val (using MCS negation completeness and the definition of tempR_fwd)
2. From ¬tempR_fwd z y: obtain χ with Gχ ∈ z.val, χ ∉ y.val
3. F(¬ψ) ∈ x.val (since Gψ ∈ y.val and tempR_fwd x y, and ¬ψ ∈ z.val and tempR_fwd x z)
4. F(¬χ) ∈ x.val (similarly)
5. Apply BX11 (temp_linearity): F(¬ψ) ∧ F(¬χ) → F(¬ψ ∧ ¬χ) ∨ F(¬ψ ∧ F(¬χ)) ∨ F(F(¬ψ) ∧ ¬χ)
6. In each case derive contradiction with Gψ and Gχ

Actually step 3 requires: we have ¬ψ ∈ z.val and tempR_fwd x z gives g_content(x) ⊆ z.val. We cannot directly get F(¬ψ) ∈ x.val from this without a `P_from_witness` type lemma (which exists in BXCanonical/TruthLemma.lean as `P_from_witness`). Specifically, if Gψ ∈ y.val and tempR_fwd x y (g_content(x) ⊆ y.val), then Gψ ∈ g_content(x) only if... GGψ ∈ x.val. That follows from temp_4.

More carefully: from ¬ψ ∈ z.val and x tempR_fwd z (g_content(x) ⊆ z.val), we need to show F(¬ψ) ∈ x.val. We have some future where ¬ψ holds (namely z). By BX12 (F_until_equiv: F(φ) → U(φ, ⊤)) and its converse, F(¬ψ) can be established from bx_forward_witness in the BXPoint setting — but in ReflCanDomain we need to port this. The witness z itself shows F(¬ψ) ∈ x: since ¬ψ ∈ z.val and z is a future of x (tempR_fwd x z, meaning g_content(x) ⊆ z.val), we need the "F-from-witness" lemma saying: if tempR_fwd x z and φ ∈ z.val then F(φ) ∈ x.val (i.e., some_future φ ∈ x.val). This is essentially `F_from_witness` (in BXCanonical/TruthLemma.lean:235) ported to ReflCanDomain.

## Strategic Assessment

### Priority Ordering for Maximum Impact

Based on dependencies and difficulty:

**Priority 1: `canS5R_symm`** (lowest effort, clean proof, independent)
- Proof is fully specifiable (see Key Findings §5)
- Uses only existing axioms: modal_b, negation completeness, implication_property
- 15-25 lines of Lean
- Not on the critical path to `bx_completeness` (it's documented as "not needed for discrete completeness"), but clears a sorry and improves the completeness picture

**Priority 2: `reflCanR_linear`** (medium effort, clean proof path)
- Requires porting `F_from_witness` to ReflCanDomain (~30 lines) + BX11 application (~50 lines)
- The core BX11 argument is standard linearity reasoning
- Clear blockers: need `F_from_witness` for ReflCanDomain

**Priority 3: TruthLemma `until_forward_mcs` guard condition** (highest effort)
- Core blocker: the open-guard breaking of `until_unfold_thm` / `refl_F`
- Best approach: implement the guard propagation using BX5 (self_accum_until) directly in the chain argument, without going through `until_F_expansion`
- Once `until_forward_mcs` is proved, `since_forward_mcs` follows by mirroring

**Priority 4: TruthLemma `until_backward_mcs`** (medium-high effort)
- Use BX6 absorption + negation completeness
- Mirror `since_backward_mcs`

**Priority 5: `truth_lemma` Until/Since cases** (automatic once 3-4 done)

### Critical Dependency Graph

```
canS5R_symm (independent) ✓ provable now

reflCanR_linear:
  requires: F_from_witness (ReflCanDomain port)
            BX11 (temp_linearity)

until_forward_mcs guard:
  requires: chain construction adapted for open-guard
            BX5 (self_accum_until) — exists, provable
            g_content_closed_derivation — already proved!

since_forward_mcs: mirrors until_forward_mcs

until_backward_mcs:
  requires: BX6 (bx6_absorption) — exists
            negation completeness — exists

truth_lemma Until: requires until_forward + until_backward
truth_lemma Since: requires since_forward + since_backward
```

## Cross-Task Interactions

### Task 141 → Task 142 (Mixed Case)

The `truth_lemma` proved in task 141 is used via `ChronicleExtraction.lean` in the Reynolds pipeline. The mixed-case sorry in task 142 is in `ChronicleToCountermodel.lean` (BXCanonical pipeline), which is a DIFFERENT completeness pipeline. Task 141 works on the WeakCanonical pipeline; task 142 works on BXCanonical.

**Key insight**: The truth_lemma and ReflexiveCanonical sorries in task 141 are NOT directly used in the ChronicleToCountermodel.lean path (task 142). They are on parallel architectural paths in the completeness proof. Solving task 141 does NOT directly enable or complicate task 142.

However, solving task 141 may provide useful patterns:
- The `g_content_closed_derivation` infrastructure (already proved) is in ReflexiveCanonical.lean and could be referenced from the BXCanonical pipeline
- The modal B axiom usage pattern for `canS5R_symm` could provide a template for similar S5 arguments in BXCanonical

### Task 141 vs Task 140 (Truth Transfer)

Task 140 closes `table_correctness` and wires the Reynolds pipeline in Transfer.lean. This is on a different sorry chain. Neither task depends on the other. Task 141 closes the WeakCanonical truth lemma (which the Reynolds pipeline uses for the canonical model), while task 140 closes the table/transfer link.

**The combined picture**: `bx_completeness` will be sorry-free only when ALL of 139+140 (Reynolds pipeline), 141 (truth lemma), and 142 (mixed case) are resolved. Tasks 141 and 140 are parallelizable.

### Open-Guard Semantics as Cross-Cutting Concern

The decision to use open-guard semantics (task 113) removed BX8/BX9 and sorry'd several theorems in TemporalDerived.lean. This affects task 141 significantly (the chain construction issue). **If task 141 is solved by working around the missing `until_unfold_thm`**, the implementation agent should document that `until_unfold_thm` remains sorry'd and why — to avoid confusion in future tasks.

## Creative Alternatives

### Alternative 1: Direct Semantic Argument for Guard Propagation

Rather than routing through `until_F_expansion` (which is sorry'd), implement the guard propagation directly using BX5 at the MCS level:

Given U(ψ₁, ψ₂) ∈ x.val and tempR_fwd x y (witness with ψ₁ ∈ y):

For any z with tempR_fwd x z and tempR_fwd z y, prove ψ₂ ∈ z.val by:
1. From U(ψ₁, ψ₂) ∈ x.val, by self_accum_until: U(ψ₁, ψ₂ ∧ U(ψ₁, ψ₂)) ∈ x.val (MCS closure)
2. So G(ψ₂ ∧ U(ψ₁, ψ₂)) ... no wait, G means "for all strict future", and we can't directly convert U into G.

The correct direct argument: from U(ψ₁, ψ₂) ∈ x.val, show ¬(U(ψ₁, ψ₂)) → ψ₁ ∉ any future MCS that extends g_content(x). Specifically, if ψ₂ ∉ z.val for some z in (x,y), then ¬ψ₂ ∈ z.val, and by the BX6 absorption axiom, the Until formula would fail at z. The cleanest proof in MCS terms: If ¬ψ₂ ∈ z and U(ψ₁, ψ₂) ∈ x (hence G(U(ψ₁, ψ₂)) ∈ x by g_content propagation), then BX6 at z gives... but again we need G(U(ψ₁, ψ₂)) ∈ z.

**Most promising concrete alternative**: Use a "G-transfer" lemma: if U(ψ₁, ψ₂) ∈ x.val and G(U(ψ₁, ψ₂)) ∈ x.val (derivable from temp_4 only if G(U(ψ₁, ψ₂)) is in x, not directly from U being in x), then... This still hits the reflexivity gap.

**The true root cause**: Open-guard semantics means at the current point x, U(ψ₁, ψ₂) being true does NOT mean "ψ₂ ∨ (ψ₁ ∧ ψ₂ continues)" at x — it means there's a strict future y > x with ψ₁ at y and ψ₂ at all strictly intermediate points. The standard "unfolding" approach is incompatible with open-guard. The correct proof requires an induction on the structure of the interval (x, y) in the canonical linear order.

For the canonical model (where the domain is `ReflCanDomain` = all MCS), this interval induction is a coinductive / well-ordering argument on the (potentially infinite) linear chain between x and y.

### Alternative 2: Use the Existing BXCanonical Chain and Port Only What's Needed

Instead of implementing a new chain construction for ReflCanDomain, port the key results from `BXCanonical/Filtration/DefectChain.lean`:

- `defect_step_self_accum`: φ U ψ ∈ w → (φ ∧ (φ U ψ)) U ψ ∈ w (BX5)
- The `DefectChain.lean` file provides a structured chain that accumulates Until witnesses

This avoids duplicating infrastructure. The porting cost is mainly type-level: translating from `BXPoint` to `ReflCanDomain`.

### Alternative 3: Prove truth_lemma Only for the Specific Formula Used

If `truth_lemma` for Until/Since is only needed for specific formula patterns in the Reynolds pipeline (checking if the original formula φ is false at the countermodel point), one could prove a *restricted* version of truth_lemma. However, the current architecture uses `truth_lemma` as a universal statement, so this would require refactoring the downstream usage. **Not recommended** — would introduce technical debt.

### Alternative 4: Consolidate BXCanonical and WeakCanonical Completeness Pipelines

The current architecture has two parallel completeness pipelines: BXCanonical (Chronicle/ChronicleToCountermodel.lean → bx_completeness) and WeakCanonical (ReflexiveCanonical + TruthLemma + Transfer.lean → doets_countermodel_discrete). They share infrastructure via Bundle/ but implement separate proofs.

Could the WeakCanonical pipeline be eliminated in favor of BXCanonical? Looking at the code:
- `doets_countermodel_discrete` in Transfer.lean currently **falls back to** `dd_countermodel_chronicle_discrete` (BXCanonical pipeline) while the Reynolds infrastructure is being built
- The WeakCanonical pipeline is architecturally intended as the Reynolds/Doets replacement for the Chronicle approach
- The 8 task-141 sorries are specifically in the WeakCanonical proof — not in BXCanonical

**Strategic question**: Since Transfer.lean already falls back to BXCanonical for the discrete case, are the 8 task-141 sorries actually blocking `bx_completeness`?

**Answer**: Yes. The task description says these sorries are on the `bx_completeness` critical path. But looking at the code: `doets_countermodel_discrete` in Transfer.lean already falls back to `dd_countermodel_chronicle_discrete` (which is sorry-free in the discrete case post-task-129). The TruthLemma and ReflexiveCanonical sorries may be **local** to the WeakCanonical module and NOT actually propagating into `bx_completeness` via the Chronicle fallback path.

This is a crucial strategic question. If the sorry's in TruthLemma.lean are isolated (not consumed by any sorry-free theorem that reaches bx_completeness), then Task 141 affects **sorry count** and **module completeness** but NOT **bx_completeness** directly.

**Recommendation**: The implementation agent should verify whether `truth_lemma` is actually called (directly or transitively) by `bx_completeness`, or whether the Chronicle fallback bypasses it. Run `#print axioms bx_completeness` to check.

## Recommendations

### Recommended Implementation Order

1. **Close `canS5R_symm` first** (Priority 1):
   - Proof is mechanical and clean (see §5 above)
   - Independent, no prerequisites
   - ~20 lines

2. **Port `F_from_witness` to ReflCanDomain** (infrastructure step):
   - Mirror `bx_forward_witness` from BXCanonical/Frame.lean
   - Needed for both `reflCanR_linear` and potentially the chain argument

3. **Close `reflCanR_linear`** (Priority 2):
   - Use F_from_witness + BX11 (temp_linearity)
   - ~60 lines

4. **Chain construction for `until_forward_mcs`** (Priority 3):
   - Implement direct BX5-based argument (NOT via until_F_expansion)
   - Port `defect_step_self_accum` from BXCanonical/Filtration/DefectChain.lean
   - ~100-150 lines (the hardest sorry)

5. **Mirror to `since_forward_mcs`** (same pattern as step 4, ~30 additional lines)

6. **Close `until_backward_mcs` and `since_backward_mcs`** (Priority 4):
   - Use BX6 absorption + negation completeness
   - ~50 lines each

7. **`truth_lemma` Until/Since cases** close automatically.

### Warning Flags for Implementation Agent

- **Do NOT use `until_F_expansion`**: It is sorry'd and depends on sorry'd `until_unfold_thm` / `refl_F`
- **Do NOT rely on BX8/BX9**: Removed under open-guard semantics (Task 113)
- **Verify axiom chain first**: Before implementing, run `#print axioms bx_completeness` to confirm these sorries actually propagate into the critical path
- **The BX5 (self_accum_until) axiom is sound and available**: It IS valid under open-guard and IS present in Axioms.lean
- **g_content_closed_derivation is available sorry-free**: Use it

### Literature Cross-Reference

The Reynolds 1992 paper (Section 4, Burgess-Xu Theorem 1) confirms that the chain construction should work. The key step (rule 1: if U(A,B) ∈ Γ at t, place Δ at s>t with A∈Δ and all between containing B) is semantically compatible with open-guard. The axioms needed at the MCS level are:

- BX5 (self_accum_until): ✓ valid and present
- BX6 (bx6_absorption): ✓ valid and present
- BX10 (until_implies_some_future): ✓ valid and present (as `until_imp_F` in TemporalDerived.lean)
- BX4 (connect_future): ✓ valid and present

The problematic axioms that were removed (BX8/BX9) are only needed to derive that ψ holds AT THE CURRENT POINT (reflexive step). Since we're in an open-guard setting, the current point is excluded from the guard interval, so those axioms were semantically invalid anyway. The chain construction can proceed without them using BX5/BX6/BX10/BX4.

## Confidence Level

**High confidence**: canS5R_symm proof path, reflCanR_linear proof path, dependency analysis
**Medium confidence**: The direct BX5-based approach for until_forward_mcs guard condition (the proof sketch is sound but Lean formalization details may surface additional obstacles)
**Medium confidence**: Priority ordering and cross-task independence claims
**Low confidence**: Whether the TruthLemma sorries actually propagate into bx_completeness (need to verify via #print axioms)
