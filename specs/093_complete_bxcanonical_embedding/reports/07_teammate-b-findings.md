# Teammate B Findings — Round 7: Alternative Chain Constructions

## Key Findings

### 1. Deterministic Chain: Exact Sorry Inventory

The deterministic chain (DeterministicChain.lean + DeterministicFMCS.lean) has the following sorry structure:

**Leaf sorries (blocking everything):**
- `deterministic_forward_F` (DeterministicFMCS.lean:65): F(ψ) ∈ chain(t) → ∃ s > t, ψ ∈ chain(s) — SAME blocker as scheduling chain
- `deterministic_backward_P` (DeterministicFMCS.lean:72): symmetric

**Derivative sorries (depend on leaf sorries):**
- `bx_fmcs_forward_F` (CanonicalModel.lean:497): sorry — same leaf
- `bx_fmcs_backward_P` (CanonicalModel.lean:502): sorry — same leaf
- forward Until in `usc` (DeterministicFMCS.lean:484): `intro t phi psi h_U; sorry`
- forward Since in `usc` (DeterministicFMCS.lean:496): `intro t phi psi h_S; sorry`
- `bx_bfmcs_buc` backward Until/Since (CanonicalModel.lean:586): `constructor <;> (intro t φ ψ ⟨r, h_le, h_psi, h_guard⟩; sorry)`
- `bx_bfmcs_restricted_buc` (CanonicalModel.lean:621): same sorry
- forward Until/Since restricted in CanonicalModel (lines 627): sorry

**Infrastructure sorries (removed axioms):**
- `YX_round_trip` (DeterministicFMCS.lean:184-205): uses `sorry /- y_det removed in BX -/`, `sorry /- x_det removed in BX -/`, `sorry /- y_k_dist removed in BX -/`
- `XY_round_trip` (DeterministicFMCS.lean:209-230): uses same removed axioms
- G_persists_forward/backward (DeterministicChain.lean multiple sites): uses `sorry /- temp_4 removed in BX -/`

### 2. x_content / y_content Are Not Defined in Active Code

`x_content` and `y_content` are used in DeterministicChain.lean (via `mem_x_content_iff`, `mem_y_content_iff`, `x_content_mcs`, `y_content_mcs`) but these are NOT defined anywhere in the active Metalogic tree. The file says "Assumes x_content_mcs and y_content_mcs from Phase 2 (TemporalContent)" but TemporalContent.lean only defines g_content, h_content, f_content, p_content, u_content, s_content. This means the deterministic chain cannot compile as-is.

### 3. The Deterministic Chain Has Backward Until PROVED — But It Depends on Broken Infrastructure

`backward_until_chain` (DeterministicFMCS.lean:341-396) and `backward_since_chain` (DeterministicFMCS.lean:398-452) are mathematically complete and sorry-free in their own proof bodies. They use:
- `x_mem_chain_general` (line 368, 392): φ ∈ chain(n+1) ↔ X(φ) ∈ chain(n) for all ℤ
- `y_mem_chain_general` (line 424, 448): φ ∈ chain(n-1) ↔ Y(φ) ∈ chain(n) for all ℤ
- `until_intro` and `since_intro` from TemporalDerived

However, `x_mem_chain_general` itself depends on `YX_round_trip` (DeterministicFMCS.lean:233-259) which contains `sorry /- y_det removed in BX -/` and `sorry /- x_det removed in BX -/`. So backward Until is sorry-free in its BODY but sorry-infected through its dependencies.

### 4. The CanonicalModel Scheduling Chain (Active Code) Has Its Own Sorry Pattern

CanonicalModel.lean is the ACTIVE implementation. It uses `fwd_succ` (scheduling chain) and has:
- `bx_fmcs_forward_F` (line 497): sorry — the fundamental blocker
- `bx_fmcs_backward_P` (line 502): sorry
- `bx_bfmcs_buc` backward Until/Since (line 586): sorry (NOT using the deterministic chain's proof)
- `bx_bfmcs_restricted_buc` (line 621): sorry
- Forward Until/Since restricted (line 627): sorry

**Critical observation**: The scheduling chain has NOT ported the deterministic chain's backward Until proof. `bx_bfmcs_buc` simply has `constructor <;> (intro t φ ψ ⟨r, h_le, h_psi, h_guard⟩; sorry)` — it ignores the machinery in DeterministicFMCS entirely.

### 5. The Removed Axioms (x_det, y_det, x_k_dist, y_k_dist)

These four axioms were removed from BX. Their removal is not incidental — they are needed for:
- `YX_round_trip`: to prove Y(X(φ)) ↔ φ in MCS (needed for negative-index x_mem_chain_general)
- `XY_round_trip`: to prove X(Y(φ)) ↔ φ in MCS

Without these, `x_mem_chain_general` cannot handle negative integer indices (the negSucc case). The natural-number case works via `mem_x_content_iff` which is definitional, but the negSucc cross-boundary case requires the round-trip lemmas.

## Option Assessment

### Option A: Port Deterministic Chain Backward Until to Scheduling Chain

**Verdict: Feasible for backward Until, but infrastructure-intensive.**

The scheduling chain uses `fwd_chain`/`bwd_chain` with `fwd_succ`/`bwd_pred` steps via Lindenbaum. It does NOT have an X-operator property (`φ ∈ chain(n+1) ↔ X(φ) ∈ chain(n)`).

To port `backward_until_chain`, we need a replacement for `x_mem_chain_general`. The scheduling chain's backward Until would need:
- A property that `ψ ∨ (φ ∧ (φ U ψ)) ∈ chain(t+1)` implies `X(ψ ∨ (φ ∧ (φ U ψ))) ∈ chain(t)` implies `(φ U ψ) ∈ chain(t)` via `until_intro`
- But `until_intro` says: `X(ψ ∨ (φ ∧ (φ U ψ))) → (φ U ψ)`. We need `X(A) ∈ chain(t)` to use this.

The scheduling chain's non-resolving step propagates `f_carry` and `g_content` but not general X-operator content. The resolving step adds `ψ` and `g_content` but drops other F-formulas. There is no way to conclude `X(A) ∈ chain(t)` just because `A ∈ chain(t+1)` in the scheduling chain.

**Alternative route for backward Until (without X-operator property)**:
Instead of the until_intro route, use the `backward_until_chain` structure but replace `x_mem_chain_general` with a direct MCS argument. Given ψ ∈ chain(s) and φ ∈ chain(r) for t < r < s, we want (φ U ψ) ∈ chain(t). We can try to show `X(ψ ∨ (φ ∧ (φ U ψ))) ∈ chain(t)` by first showing `(⊥ U (ψ ∨ (φ ∧ (φ U ψ)))) ∈ chain(t)`, which requires that `F(ψ ∨ (φ ∧ (φ U ψ))) ∈ chain(t)`, which circles back to forward_F.

**Conclusion for Option A**: Cannot port backward Until to the scheduling chain without either the X-operator property OR forward_F. The structural mismatch is fundamental.

### Option B: Replace Scheduling Chain with Deterministic Chain Entirely

**Verdict: Blocked by two separate issues.**

1. `x_content` and `y_content` are not defined in the active codebase — they are Boneyard-only. Activating the deterministic chain requires either defining x_content and y_content as X/Y-operator content extractors (`x_content M = {φ | (⊥ U φ) ∈ M}`, `y_content M = {φ | (⊥ S φ) ∈ M}`) OR importing from where they are defined.

2. `x_content_mcs` (x_content of an MCS is an MCS) requires the X-K and X-Det axioms, which are exactly `x_k_dist` and `x_det` — REMOVED from BX. Similarly for `y_content_mcs`.

Without x_det and x_k_dist, there is no way to show that `{φ | X(φ) ∈ M}` is maximally consistent. The deterministic chain's MCS property collapses without these axioms.

**Could x_det / x_k_dist be recovered?** In BX, the logic has G and H as primitive (not X and Y). X(φ) = ⊥ U φ and Y(φ) = ⊥ S φ. The "deterministic" axiom X(¬φ) → ¬X(φ) corresponds to "seriality+determinism" — the current moment has exactly one immediate successor. This is NOT a theorem of BX (which uses G/H over all-future/all-past rather than next-step operators). So x_det is genuinely absent.

**Conclusion for Option B**: Blocked. The deterministic chain requires axioms not in BX.

### Option C: Hybrid Chain

**Verdict: Does not address the core problem.**

If the scheduling chain seed includes `x_content(M)` in addition to `g_content(M)` and `f_carry(M)`, we'd get something like a mini-deterministic step. But `x_content(M)` requires `x_det` and `x_k_dist` to be definable (or else is just {φ | X(φ) ∈ M} which is not guaranteed MCS). This creates the same problem as Option B.

A different hybrid: use the scheduling chain for the F-resolution structure, and inject the backward Until proof by a separate semantic argument. This is essentially saying: instead of proving backward Until via chain induction, prove it via the `bx_bfmcs` bundle's model-theoretic structure. But the model-theoretic backward Until proof in `bx_bfmcs_buc` is also sorry.

**Conclusion for Option C**: No structural advantage over the direct approaches.

### Option D: Quasimodel Approach (GHR 1994)

**Verdict: The right long-term solution, but requires new infrastructure.**

The FiniteDeferral.lean comment recommends this approach and partially implements it:
- Steps 1-4 (F-to-Until conversion, Until persistence, restricted theory finiteness, pigeonhole) are PROVED
- Step 5 (cycle contradiction via Until Induction axiom) is left sorry

The quasimodel approach would prove forward_F by:
1. Assuming F(ψ) ∈ chain(t) but ψ never appears in chain(s) for s > t
2. Showing (⊤ U ψ) persists forever (proved in FiniteDeferral.lean)
3. By pigeonhole, restricted theories cycle (proved in FiniteDeferral.lean)
4. Use Until Induction (axiom in BX): G(ψ → χ) ∧ G((φ ∧ ¬χ) → Xχ) → (φ U ψ → χ) — or its equivalent — to derive a contradiction from an infinite unresolved Until

The `G_neg_kills_until` theorem (FiniteDeferral.lean:164-248) partially implements Step 5 but the comment reveals the issue: to apply until_induction, we need G(step_formula) ∈ chain(t), which requires knowing that `step_formula` holds at ALL future chain positions — which circles back to the need for forward_F or G-propagation beyond g_content.

**Key insight**: The FiniteDeferral infrastructure is the best foundation. The only gap is converting "restricted theory cycles" into "G(¬ψ) ∈ chain(t)" to kill the Until. This requires showing that if chain positions i and j have the same restricted theory, then the chain is "periodic" in a sense that allows G(¬ψ) to be derivable — which is the quasimodel argument proper.

## Recommended Approach

**Primary recommendation: Complete the FiniteDeferral/quasimodel argument for forward_F in the scheduling chain.**

The scheduling chain (CanonicalModel.lean) is the correct active implementation. Its `bx_fmcs_forward_F` sorry is the root blocker. The FiniteDeferral.lean infrastructure (Steps 1-4) is already done and lives in the Boneyard — it can be moved to active code.

The specific gap (Step 5) can be closed by a novel argument:

**Proposed Step 5 proof sketch**:
- Given: restricted theories at positions t+i and t+j are equal (by pigeonhole, i < j ≤ bound)
- The formulas in deferralClosure(ψ) cycle with period (j-i)
- In particular, if ψ ∉ chain(t+k) for k = 1..j, then ψ ∉ chain(t+j+k) by the same reasoning (since restricted theory repeats)
- By induction, ψ ∉ chain(s) for all s > t
- But then G(¬ψ) ∈ chain(t) (can be derived by the G-closure property + MCS negation completeness)
- G(¬ψ) ∈ chain(t) contradicts (⊤ U ψ) ∈ chain(t) via `G_neg_kills_until`

The critical step is "restricted theory repeats implies global persistence of ¬ψ". This is where the quasimodel argument is needed: the restricted theory only captures a finite subformula closure, but the chain construction (with g_content propagation) ensures that what is provable about the restricted theory reflects what is true of the formula ψ globally.

**For backward Until (secondary recommendation)**:

Given that forward_F is the core blocker, and the scheduling chain currently has backward Until sorry in `bx_bfmcs_buc`, the secondary recommendation is to PORT the deterministic chain's backward Until proof to the scheduling chain via a DIFFERENT mechanism:

Instead of `x_mem_chain_general`, use the following:
- `until_intro`: X(ψ ∨ (φ ∧ (φ U ψ))) → (φ U ψ) is a theorem
- For the scheduling chain, show `F(ψ ∨ (φ ∧ (φ U ψ))) ∈ chain(t)` using forward_F (once proved)
- Then show `(ψ ∨ (φ ∧ (φ U ψ))) ∈ chain(t+1)` (from F witness)
- Iterate the argument

But this again requires forward_F. So backward Until cannot be closed independently of forward_F in the scheduling chain.

**Bottom line**: All four sorry sites in the scheduling chain reduce to the same core problem (forward_F). Closing forward_F via the FiniteDeferral/quasimodel argument is the single change that unblocks everything.

## Evidence / Examples

**DeterministicFMCS.lean:341-396**: `backward_until_chain` is the proof we want to port. Its correctness depends on `x_mem_chain_general` (line 368), which depends on `YX_round_trip` (line 246), which has `sorry /- y_det removed in BX -/`.

**FiniteDeferral.lean:1-30**: Documents that Steps 1-4 of the quasimodel argument are done; Step 5 (cycle contradiction) is sorry.

**CanonicalModel.lean:586**: `constructor <;> (intro t φ ψ ⟨r, h_le, h_psi, h_guard⟩; sorry)` — confirms backward Until is not attempted in active code.

**CanonicalModel.lean:493-503**: `bx_fmcs_forward_F` and `bx_fmcs_backward_P` are simple sorries — no partial proof.

## Confidence Level

**High confidence on facts**:
- The deterministic chain cannot be activated without x_det/x_k_dist/y_det/y_k_dist (removed axioms)
- backward Until in DeterministicFMCS uses removed axioms indirectly through YX_round_trip
- All active scheduling chain sorries reduce to forward_F
- FiniteDeferral.lean Steps 1-4 are complete

**Medium confidence on recommendations**:
- The quasimodel Step 5 sketch (restricted theory cycling implies G(¬ψ)) is the right approach but the formalization complexity is significant
- The key lemma needed: "if restrictedTheory cycles, then ψ is globally absent" — this requires showing the scheduling chain is "determined" by its restricted theory on deferralClosure, which may need additional lemmas about g_content and the schedule's surjectivity

**Low confidence on**:
- Whether Step 5 can be closed without new axioms or substantially new infrastructure
- Whether there is a simpler algebraic argument for forward_F that avoids the quasimodel machinery entirely
