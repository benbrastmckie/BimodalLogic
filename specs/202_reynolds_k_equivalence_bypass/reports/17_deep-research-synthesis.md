# Synthesis Report: Reynolds Model Surgery Implementation Path\n\n## 1. Root Cause Analysis\n\n### Why Previous Attempts Failed\n\nThe 17+ implementation cycles reveal three distinct failure modes, each with a different root cause:\n\n**Failure Mode A: Wrong Mathematical Target (cycles 1-14)**\n\nThe dominant failure pattern is agents attempting to construct a temporal formula detecting `contemp_equiv` class *membership* (i.e., \"is t in the same class as a?\") rather than Reynolds' actual construction of `right_gap_class` (i.e., \"does t's class end in a gap on the right?\"). This is a misreading of Reynolds' proof. The class membership formula is provably impossible: `contemp_equiv sig k M a t` depends on a fixed element `a`, but `MonadicFormula sig 1` has only one free variable (for `t`) and cannot reference specific carrier elements. This is not a Lean limitation but a mathematical impossibility -- monadic FO with one free variable and finitely many predicates cannot define membership in a specific equivalence class over an infinite domain.\n\nReynolds' actual construction avoids this by detecting a *structural property* of classes (whether the boundary is a gap), which is definable because it only uses quantified variables, never referencing a fixed element. The formula `right_gap_class_formula` has been correctly identified and defined in the codebase. This failure mode is now understood and should not recur.\n\n**Failure Mode B: Shortcut Attempts Around Model Surgery (cycles 15-16)**\n\nOnce the correct formula target was identified, agents attempted to derive contradictions without the full model surgery -- using `prior_UZ_first_transition` directly on the gap formula R, or enriching the signature with R as a new predicate. These fail for deep mathematical reasons:\n\n- Direct Prior-UZ on R fails because R might hold at ALL points (no transition to contradict).\n- Enriched signature fails because the gap-detecting predicate itself violates Prior-UZ at the gap boundary (the gap prevents the first-occurrence property).\n\nThe model surgery IS mathematically necessary. Reynolds' proof works precisely because it constructs a *new model* where the gap is replaced by a successor-pair boundary, preserves temporal truth across the surgery, and then derives a contradiction from the changed boundary type. There is no shortcut.\n\n**Failure Mode C: De Bruijn Index Arithmetic (cycle 17, current blocker)**\n\nThe one attempt that correctly identified both the right formula target AND the necessity of model surgery got blocked on a Lean-specific technical issue: proving that `good_rel_lifted` (obtained by applying `lift` twice to `good_formula_relativized`) evaluates correctly under a 4-variable environment constructed via `Fin.cons`. The issue is that `Fin.cons` uses `Fin.cases` (pattern matching on 0 vs succ) while `insertEnv` uses `dif` (conditional on index value), and their simplification lemmas do not compose when the index is a variable.\n\nThis is a fixable engineering problem, not a fundamental obstruction.\n\n### Is There a Fundamental Mismatch?\n\nNo. The Reynolds proof and the Lean formalization are compatible. The existing infrastructure (US expressive completeness over Prior structures, right_gap_class_prop with invariance/succ/pred preservation, good_sentence/good_formula_relativized with correctness proofs, relativize/relativize_correct, prior_UZ_first_transition/prior_SZ_last_transition) is all sorry-free and correctly aligned with Reynolds' proof structure. The gap is purely in the unimplemented portions: the formula correctness proof (blocked by De Bruijn arithmetic), and the model surgery itself (never attempted).\n\nThe 700-line estimate for the remaining work is realistic. The mathematical content is well-understood. The implementation requires careful but straightforward Lean engineering.\n\n---\n\n## 2. The Minimal Path\n\n### Critical Sorry Sites\n\nThere are exactly 2 sorry sites that must be closed:\n\n1. `gap_prior_UZ_contradiction` at `GoodStructuresModelSurgery.lean:831`\n2. `gap_prior_SZ_contradiction` at `GoodStructuresModelSurgery.lean:857`\n\nPlus one wiring change:\n\n3. Replace `sorry` in `no_gaps_discrete` at `GoodStructures.lean:852` with delegation to `no_gaps_discrete_model_surgery`\n\n### Minimal Lemma Set (11 pieces, ~700 lines total)\n\nI will list these in dependency order. For each, I provide the conceptual type signature, estimated LOC, difficulty, and what it depends on.\n\n**Piece 1: `eval_good_rel_lifted` (~40 lines, moderate)**\n\n```\ntheorem eval_good_rel_lifted (M : OrderedMonadicStructure sig)\n    (env : Fin 4 -> M.carrier) :\n    eval M env (good_rel_lifted sig k) <->\n    eval M (Fin.cons (env 2) (Fin.cons (env 3) Fin.elim0))\n      (good_formula_relativized sig k)\n```\n\nDepends on: `good_formula_relativized` (exists), `lift_eval` (exists).\nBlocks: piece 2.\n\n**Piece 2: `right_gap_class_formula_correct` (~80 lines, hard)**\n\n```\ntheorem right_gap_class_formula_correct (M : OrderedMonadicStructure sig)\n    (t : M.carrier) :\n    eval M (fun _ => t) (right_gap_class_formula sig k) <->\n    (exists b : M.carrier, t < b /\\\n      exists a' b' : M.carrier, t <= a' /\\ a' <= b' /\\ b' <= b /\\\n        not (good sig k (M.subinterval sig a' b')))\n```\n\nDepends on: piece 1.\nBlocks: piece 3.\nNote: This captures only the \"class bounded above with bad subinterval\" part of `right_gap_class_prop`. The succ-closed conjunct is always true (by `no_boundary_at_successor`) and need not be encoded.\n\n**Piece 3: `gap_formula_R` definition + `gap_formula_R_correct` (~40 lines, moderate)**\n\n```\ndef gap_formula_R (sig : MonadicSignature) (k : Nat)\n    (atomMap : Formula -> sig.preds) : Formula :=\n  (US_expressively_complete_over_prior sig k M atomMap h_surj h_prior_UZ h_prior_SZ\n    (right_gap_class_formula sig k)).val\n\ntheorem gap_formula_R_correct (t : M.carrier) :\n    temporal_truth M atomMap t (gap_formula_R ...) <->\n    right_gap_class_prop sig k M t\n```\n\nDepends on: piece 2, `US_expressively_complete_over_prior` (exists, sorry-free).\nBlocks: pieces 4, 9.\n\n**Piece 4: `R_interval_analysis` (~55 lines, routine)**\n\n```\n-- R holds at a (the assumed gap point)\nlemma R_holds_at_a : temporal_truth M atomMap a (gap_formula_R ...)\n\n-- R fails at some point (because y is not in class(a) but class(a) is succ-closed,\n-- so y's class has no gap on the right in the same sense)\nlemma R_false_somewhere : exists z, not (temporal_truth M atomMap z (gap_formula_R ...))\n\n-- First R-to-not-R transition exists\nlemma R_first_transition : exists c, temporal_truth M atomMap c (gap_formula_R ...) /\\\n    not (temporal_truth M atomMap (Order.succ c) (gap_formula_R ...))\n```\n\nDepends on: piece 3, `prior_UZ_first_transition` (exists, sorry-free).\nBlocks: piece 5.\n\n**Piece 5: `surgery_model_construction` (~40 lines, moderate)**\n\n```\n-- The surgery domain: points outside the bad R-interval, plus one representative class I\ndef surgery_carrier : Type := ...  -- subtype of M.carrier\n\n-- The surgery model inherits order and predicates from M\ninstance : OrderedMonadicStructure sig (surgery model) := ...\n\n-- Key property: the representative class I ends at a successor boundary in N, not a gap\nlemma surgery_class_boundary_is_successor : ...\n```\n\nDepends on: piece 4.\nBlocks: pieces 6, 8.\n\n**Piece 6: `class_homogeneity_in_R_intervals` (~60 lines, hard)**\n\nReynolds Lemma 9: All contemp_equiv classes in a maximal R-interval are elementarily equivalent. If a monadic formula A distinguishes classes C1 and C2 in the same R-interval, construct temporal B (via expressive completeness) true exactly when A holds somewhere in the current class. B transitions between classes at the gap boundary, violating Prior-UZ (which requires transitions at successor pairs). Contradiction.\n\nDepends on: piece 5, `doets_lemma_1_1` (exists, sorry-free), `US_expressively_complete_over_prior` (exists).\nBlocks: piece 7.\n\n**Piece 7: `formula_propagation_in_bad_intervals` (~40 lines, moderate)**\n\nReynolds Lemmas 10-11: Both R and L hold throughout bad intervals. Formulas true at class boundaries propagate throughout.\n\nDepends on: piece 6.\nBlocks: piece 8.\n\n**Piece 8: `surgery_truth_preservation` (~200 lines, hard -- the bulk)**\n\nReynolds Lemma 12: For all temporal formulas A and all points t in the surgery model N:\n`temporal_truth M atomMap t A <-> temporal_truth N atomMap_N t A`\n\nInduction on formula structure:\n- `atom`: trivial (same predicates at same points) -- ~5 lines\n- `bot`: trivial -- ~3 lines\n- `imp`: by induction hypothesis -- ~5 lines\n- `box`: by induction hypothesis (S5 single-class, identity box) -- ~10 lines\n- `untl(A, B)`: 13 subcases (7 forward M->N, 6 backward N->M) -- ~85 lines\n- `snce(A, B)`: 13 subcases mirroring untl -- ~85 lines\n\nEach U/S subcase depends on which regions (Q-, I, Q0\\I, Q+) contain the witness point s and the current point t, and uses pieces 6-7 for transferring formula truth between classes.\n\nDepends on: pieces 5, 7.\nBlocks: piece 9.\n\n**Piece 9: `contradiction_derivation` (~40 lines, moderate)**\n\nReynolds Lemma 13: Close `gap_prior_UZ_contradiction`.\n\nIn surgery model N:\n1. R holds at representative point i in I (by piece 8, truth preservation from M where R holds by piece 4).\n2. By `gap_formula_R_correct` applied to N (which is a Prior structure -- any counterexample in N is one in M by piece 8), R true at i means i's class in N ends in a gap.\n3. But i's class in N ends at a successor boundary (piece 5), not a gap.\n4. Contradiction.\n\nDepends on: pieces 3, 8.\nBlocks: piece 10.\n\n**Piece 10: `gap_prior_SZ_contradiction_close` (~100 lines, moderate)**\n\nClose `gap_prior_SZ_contradiction`. Two approaches:\n\n*Approach A (Order.dual, ~60 lines)*: Show that applying `OrderDual` to M transforms `semantic_prior_SZ` into `semantic_prior_UZ` and `right_gap_class_prop` for left-gaps into `right_gap_class_prop` for right-gaps. Then apply `gap_prior_UZ_contradiction` on the dual. Requires verifying all type class instances (`SuccOrder`, `PredOrder`, `NoMaxOrder`, `NoMinOrder`) transfer correctly under `OrderDual`.\n\n*Approach B (symmetric argument, ~150 lines)*: Mirror the entire UZ argument using `S(A,B)` instead of `U(A,B)`, `left_gap_class` instead of `right_gap_class`, and `prior_SZ_last_transition` instead of `prior_UZ_first_transition`.\n\nApproach A is preferred if the type class instances compose cleanly.\n\nDepends on: piece 9.\nBlocks: piece 11.\n\n**Piece 11: `wire_no_gaps_discrete` (~5 lines, routine)**\n\n```\n-- In GoodStructures.lean, replace sorry at line 852 with:\nexact no_gaps_discrete_model_surgery sig k M atomMap h_surj h_prior_UZ h_prior_SZ a b h_diff_class\n```\n\nThis requires adding `import Theories.Bimodal.Metalogic.WeakCanonical.IntegerModel.GoodStructuresModelSurgery` to GoodStructures.lean.\n\nDepends on: piece 10.\n\n---\n\n## 3. The Fin.cons/insertEnv Problem\n\n### Diagnosis\n\nThe blocker is in piece 1 (`eval_good_rel_lifted`). The definition of `good_rel_lifted` applies `lift` twice to `good_formula_relativized`:\n\n```lean\ndef good_rel_lifted (sig : MonadicSignature) (k : Nat) : MonadicFormula sig 4 :=\n  (good_formula_relativized sig k).lift 2 |>.lift 3\n```\n\nThe `lift_eval` theorem states (roughly):\n\n```lean\ntheorem lift_eval (phi : MonadicFormula sig n) (c : Nat) (M) (env : Fin (n+1) -> M.carrier) :\n    eval M env (phi.lift c) = eval M (insertEnv c env) phi\n```\n\nwhere `insertEnv c env` drops the `c`-th variable from the environment. To compose two `lift` applications, one must show:\n\n```\neval M env4 ((good_formula_relativized sig k).lift 2 |>.lift 3)\n= eval M (insertEnv 3 env4) ((good_formula_relativized sig k).lift 2)   -- first lift_eval\n= eval M (insertEnv 2 (insertEnv 3 env4)) (good_formula_relativized sig k)  -- second lift_eval\n```\n\nThen one must show that `insertEnv 2 (insertEnv 3 env4)` agrees with `Fin.cons (env4 2) (Fin.cons (env4 3) Fin.elim0)` on all indices in `Fin 2`, because `good_formula_relativized` is a `MonadicFormula sig 2`.\n\nThe difficulty: `insertEnv c env` is defined using `dif` (if `i.val < c then env (Fin.castSucc i) else env (Fin.succ i)`), while `Fin.cons` uses `Fin.cases` (pattern matching on `0` vs `succ`). When the index `i` is a *variable* (not a concrete numeral), `simp` cannot reduce either definition to a normal form that makes them equal.\n\n### Is This Fundamental?\n\nNo. This is a purely technical Lean issue with De Bruijn index management. The mathematical content is trivial: both functions map `{0, 1}` to the same pair of carrier elements. The issue is making Lean's type system see this.\n\n### The Fix\n\nThere are three viable approaches, in order of preference:\n\n**Fix A: Case-split on `Fin 2` indices (~15 lines)**\n\nSince `good_formula_relativized` is a `MonadicFormula sig 2`, its `eval` only queries the environment at indices in `Fin 2`. There are exactly two indices: `0` and `1`. Case-split on each:\n\n```lean\ntheorem eval_good_rel_lifted ... := by\n  unfold good_rel_lifted\n  rw [lift_eval, lift_eval]\n  congr 1\n  ext i\n  fin_cases i <;> simp [insertEnv, Fin.cons]\n```\n\nIf `fin_cases` does not work directly on `Fin 2` indices inside `eval`, use `funext` first, then `fin_cases i`. The key insight is that `eval` is parametric in the environment and two environments that agree on all indices give the same result. If there is an `eval_congr` or `eval_ext` lemma available, use it. Otherwise, prove a small extensionality lemma first.\n\n**Fix B: Use `weaken` instead of `lift` (~25 lines)**\n\nThe function `weaken` (= `lift 0`) has a simpler correctness theorem (`weaken_eval`) that composes with `Fin.cons` directly:\n\n```lean\ntheorem weaken_eval (phi : MonadicFormula sig n) (M) (env : Fin (n+1) -> M.carrier) :\n    eval M env phi.weaken = eval M (Fin.tail env) phi\n```\n\nRedefine `good_rel_lifted` using `weaken` combined with variable permutation instead of `lift 2` and `lift 3`. This avoids the `insertEnv` problem entirely but requires restructuring the formula definition.\n\n**Fix C: Inline the formula directly (~40 lines)**\n\nInstead of lifting `good_formula_relativized` through two De Bruijn lifts, construct `right_gap_class_formula` directly as a `MonadicFormula sig 1` using explicit quantifiers and atomic formulas, bypassing the lift machinery entirely. This is less modular but avoids all De Bruijn composition issues.\n\n**Recommendation**: Try Fix A first (5 minutes of work). If `fin_cases`/`simp` do not close it, try Fix C (more work but guaranteed to succeed since it sidesteps the problem entirely).\n\n---\n\n## 4. Recommended Strategy\n\n### What the Next Implementation Attempt MUST Do\n\n1. **Start with the De Bruijn fix (piece 1)**, since everything else is blocked on it.\n2. **Use sorry-first-then-fill for pieces 1-8**, working toward the contradiction derivation (piece 9) as the primary goal.\n3. **Actually write the model surgery construction** (pieces 5-8). This has never been attempted in 17+ cycles and is the mathematical core of the proof.\n\n### What the Next Implementation Attempt Must NOT Do\n\nBased on failure history, the following approaches are **proven dead ends** and must not be attempted:\n\n- **DO NOT** construct a temporal formula detecting `contemp_equiv` class membership (`class_temporal_formula`). This is mathematically impossible.\n- **DO NOT** try to bypass model surgery with a direct Prior-UZ argument on R. The formula R may hold everywhere, providing no transition to contradict.\n- **DO NOT** enrich the monadic signature with `right_gap_class` as a new predicate and try to prove Prior-UZ for the enriched structure. The gap specifically violates Prior-UZ for gap-detecting predicates.\n- **DO NOT** use `h_accessible` instead of `h_surj`. They are different properties; only `h_surj` enables expressive completeness.\n- **DO NOT** attempt to prove `no_gaps_prior` or `no_gaps_faithful` as stated. They are mathematically false (Z+Z counterexample).\n- **DO NOT** spend time on the `countermodel_discrete_reynolds` packaging sorry (Transfer.lean:1289). It is declared unsolvable and is not on the critical path for `completeness_discrete`.\n\n### Dependency Order for Construction\n\n```\nPhase 1 (Formula): pieces 1 -> 2 -> 3          (~160 lines)\nPhase 2 (Analysis): piece 4                      (~55 lines)\nPhase 3 (Surgery): pieces 5 -> 6 -> 7 -> 8      (~340 lines)\nPhase 4 (Close): pieces 9 -> 10 -> 11           (~145 lines)\n```\n\n### Sorry-First Strategy\n\nThe recommended approach is to sorry pieces 1-8 initially, write the contradiction derivation (piece 9) with sorry'd helper lemmas, verify the overall proof structure compiles, and then fill in the sorrys from bottom up (pieces 1 through 8). This is because:\n\n- The contradiction derivation (piece 9) is where the mathematical argument terminates. Writing it first validates the entire proof architecture.\n- The surgery truth preservation (piece 8) is the hardest piece but has 30 independent subcases that can be filled one at a time.\n- The De Bruijn fix (piece 1) is the most uncertain piece; sorry'ing it lets the rest of the work proceed while it is being solved.\n\n### Hardest Pieces (likely to require the most debugging)\n\n1. **surgery_truth_preservation** (piece 8, ~200 lines): 30 subcases for U/S temporal truth preservation. Each subcase requires reasoning about which region (Q-, I, Q0\\I, Q+) contains the relevant points. The subcases are independent but numerous.\n\n2. **right_gap_class_formula_correct** (piece 2, ~80 lines): De Bruijn index correctness proof. Requires careful management of variable environments.\n\n3. **class_homogeneity_in_R_intervals** (piece 6, ~60 lines): Requires constructing auxiliary temporal formulas via expressive completeness and applying Prior-UZ to derive contradictions. Conceptually deep.\n\n### Estimated Total Effort\n\n- **Lines of Lean code**: ~700 (range: 550-900 depending on verbosity and whether Order.dual works for piece 10)\n- **Implementation sessions**: 4-6 sessions of 2-4 hours each\n  - Session 1: Pieces 1-3 (formula construction, De Bruijn fix)\n  - Session 2: Pieces 4-5 (R-interval analysis, surgery domain definition)\n  - Session 3: Piece 6-7 (class homogeneity, formula propagation)\n  - Session 4: Piece 8 (surgery truth preservation -- the bulk)\n  - Session 5: Pieces 9-10 (contradiction + SZ case)\n  - Session 6: Piece 11 + cleanup + lake build verification\n\n---\n\n## 5. Concrete Implementation Checklist\n\n### Session 1: Gap Formula Construction (Pieces 1-3)\n\n**Objective**: Produce a temporal formula R with a sorry-free correctness theorem connecting it to `right_gap_class_prop`.\n\n**Step 1.1**: Fix `eval_good_rel_lifted` (piece 1)\n- File: `GoodStructuresModelSurgery.lean`, after line ~760\n- Try Fix A first: `ext i; fin_cases i <;> simp [insertEnv, Fin.cons]`\n- If that fails, try Fix C: inline the formula directly\n- Success criterion: `eval_good_rel_lifted` compiles without sorry\n\n**Step 1.2**: Prove `right_gap_class_formula_correct` (piece 2)\n- File: `GoodStructuresModelSurgery.lean`, after the formula definition at line ~787\n- Unfold `right_gap_class_formula`, apply `eval_good_rel_lifted`, compose with `good_formula_relativized_correct`\n- Handle the quantifier structure (exists b, exists a', exists b', ...)\n- Success criterion: theorem compiles without sorry, connecting `eval M (fun _ => t) (right_gap_class_formula sig k)` to the semantic predicate\n\n**Step 1.3**: Construct `gap_formula_R` and prove correctness (piece 3)\n- File: `GoodStructuresModelSurgery.lean`, after step 1.2\n- Apply `US_expressively_complete_over_prior` to `right_gap_class_formula`\n- Obtain temporal Formula R and its correctness: `temporal_truth M atomMap t R <-> right_gap_class_prop sig k M t`\n- Note: The full `right_gap_class_prop` includes succ-closed, but this is always true by `no_boundary_at_successor`. The formula only needs to encode the \"bounded above with bad subinterval\" part. Bridge the gap by showing the formula's semantic content plus `contemp_equiv_succ_closed_of_no_boundary` gives full `right_gap_class_prop`.\n- Success criterion: `gap_formula_R_correct` compiles without sorry\n\n**Fallback for Session 1**: If pieces 1-2 prove intractable (De Bruijn issues), sorry them and proceed to pieces 4-5 to avoid blocking on the same issue that blocked cycle 17.\n\n### Session 2: R-Interval Analysis + Surgery Domain (Pieces 4-5)\n\n**Objective**: Establish that R holds at a, fails somewhere, has a first transition, and define the surgery model.\n\n**Step 2.1**: Prove R-interval properties (piece 4)\n- File: `GoodStructuresModelSurgery.lean`, within `gap_prior_UZ_contradiction` proof body\n- `R_holds_at_a`: `gap_formula_R_correct` backward direction + construct `right_gap_class_prop` witness from hypotheses (`h_succ_closed`, `hay`, `h_not_equiv`)\n- `R_false_somewhere`: Need to find a point where `right_gap_class_prop` is false. Use the point y: y is not in class(a), so y's class is different. Must argue y's class does NOT end in a gap (or find another point where R fails). This requires care -- R might hold at y too if y's class also has a gap. The key: y is not in class(a) but `a < y`, and class(a) is succ-closed, so class(a) has a gap between a's succ-orbit and y. In the class containing y, the boundary from below is at the gap (which is the TOP of class(a)'s gap). Whether y's class has a right-gap depends on the structure. Instead, use Prior-UZ: if R holds everywhere above a, then `U(neg R, R)` is false (R never transitions), but `F(neg R)` is also false, so the Prior-UZ antecedent `Fp /\\ U(neg p, p)` with p = neg R fails vacuously. This does not give a contradiction. Need a different argument. Alternative: use the fact that the ORDER is discrete with no endpoints, and if R held at ALL points, then right_gap_class_prop holds at all points, meaning EVERY class is bounded above with a gap. But the union of all classes is the entire carrier, which is unbounded, so not every class can be bounded above. Contradiction. Verify this argument in detail.\n- `R_first_transition`: Apply `prior_UZ_first_transition` with `psi` being the temporal formula whose `temporal_truth` is R.\n- Success criterion: all three lemmas compile (sorry-free or with sorry'd gap_formula_R_correct from session 1 fallback)\n\n**Step 2.2**: Define surgery domain (piece 5)\n- File: `GoodStructuresModelSurgery.lean`\n- Define the \"bad interval\" as the maximal interval where R holds containing a. The transition point c from step 2.1 gives the right boundary: c is the last point where R holds, Order.succ c is the first point where R fails.\n- Define representative class I = class(a) (or class(c), since R holds at c and c is in the same R-interval as a).\n- Surgery domain: `{x : M.carrier // x <= a_left_boundary or contemp_equiv sig k M a x or x >= Order.succ c}` where a_left_boundary needs symmetric left-side analysis.\n- SIMPLIFICATION: For the first implementation, consider a simpler surgery that does not require identifying the full bad interval. Since the goal is contradiction and we have `right_gap_class_prop` holding at a but failing at `Order.succ c`, we can work with just the transition at c. The surgery removes everything in class(a) except one representative and sews the boundaries together.\n- Success criterion: surgery carrier type defined, inherits LinearOrder\n\n**Note on Step 2.2**: The exact surgery construction needs careful design. The Reynolds proof uses Q- union I union Q+, but identifying these regions requires the full Lemma 7-8 analysis (open intervals, no first/last class). For a Lean implementation, consider whether a simpler construction suffices: since `right_gap_class_prop` holds at a and fails at `Order.succ c`, and the class boundary at c/succ(c) is a successor boundary (not a gap), the argument might be completable without the full interval analysis. This would reduce the implementation substantially.\n\n### Session 3: Class Homogeneity + Formula Propagation (Pieces 6-7)\n\n**Objective**: Prove that all classes in the R-interval are elementarily equivalent and that formulas propagate.\n\n**Step 3.1**: Class homogeneity (piece 6)\n- This is Reynolds Lemma 9 and is the most conceptually deep piece after truth preservation.\n- Core argument: Suppose MonadicFormula phi holds in class C1 but not C2 (both in R-interval). Using `US_expressively_complete_over_prior`, get temporal B equivalent to \"phi holds somewhere in my class\" (relativize phi to the class using `contemp_equiv` as the bounding predicate). B is constant within each class (by construction) but differs between C1 and C2. At the class boundary (which is a gap), B transitions. But Prior-UZ requires transitions at successor pairs, not gaps. Contradiction.\n- Key subtlety: \"phi holds somewhere in my class\" requires encoding class membership using quantified variables, which IS possible (unlike the fixed-element class(a) membership). The class is the maximal interval where `contemp_equiv` holds relative to the current point -- this is definable in monadic FO.\n- Success criterion: class homogeneity lemma compiles\n\n**Step 3.2**: Formula propagation (piece 7)\n- Reynolds Lemmas 10-11.\n- Show L holds wherever R holds (and vice versa): use class homogeneity.\n- Show formulas true at class starts extend throughout the bad interval: use Prior-UZ and class homogeneity.\n- Success criterion: propagation lemmas compile\n\n**Possible shortcut**: If the simplified surgery from Step 2.2 (working only with the transition at c) succeeds, pieces 6-7 may be substantially simplified or even unnecessary. The full Lemma 9-11 machinery is needed for the general bad-interval argument, but if we can derive the contradiction from just the transition point, these pieces reduce to checking temporal truth at a few specific points.\n\n### Session 4: Surgery Truth Preservation (Piece 8)\n\n**Objective**: Prove temporal truth is preserved between M and surgery model N.\n\n**Step 4.1**: Atom, bot, imp, box cases (~23 lines)\n- These are all trivial:\n  - `atom a`: same predicates at same points (surgery inherits from M)\n  - `bot`: always false in both\n  - `imp A B`: by induction hypothesis on A and B\n  - `box A`: depends on box semantics; if S5 single-class, box = identity, by IH\n\n**Step 4.2**: U(A,B) forward direction (M satisfies -> N satisfies) (~45 lines)\n- 7 subcases based on regions of t and witness s:\n  1. t in Q-, s in Q-\n  2. t in Q-, s in I\n  3. t in Q-, s in Q0\\I (impossible in N, redirect to s' in I)\n  4. t in Q-, s in Q+\n  5. t in I, s in I\n  6. t in I, s in Q+\n  7. t in Q+, s in Q+\n- Cases 1, 5, 7 are immediate (both t and s in same region, IH applies directly)\n- Cases 2, 4, 6 require transferring formula truth through I using class homogeneity (piece 6) and propagation (piece 7)\n- Case 3 requires showing a witness exists in I (by Lemma 9, if A holds somewhere in Q0, it holds somewhere in I)\n\n**Step 4.3**: U(A,B) backward direction (N satisfies -> M satisfies) (~40 lines)\n- 6 subcases (case 3 does not arise because Q0\\I is not in N):\n  1. t in Q-, s in Q-\n  2. t in Q-, s in I (extend to s' in Q0, then use Lemma 11 to propagate B)\n  3. t in Q-, s in Q+\n  4. t in I, s in I\n  5. t in I, s in Q+ (extend witness into Q0 using Lemma 11)\n  6. t in Q+, s in Q+\n\n**Step 4.4**: S(A,B) both directions (~85 lines)\n- Mirror U(A,B) with time reversed. If the surgery construction and lemmas are set up symmetrically, this should be a clean copy-paste-modify of the U cases.\n\n**Implementation note**: Each subcase should be a separate named lemma (e.g., `surgery_U_forward_case2`, `surgery_S_backward_case5`). This makes debugging manageable and allows independent work on each case.\n\n**Success criterion**: `surgery_truth_preservation` compiles (possibly with individual subcases sorry'd for later filling)\n\n### Session 5: Contradiction + SZ Case (Pieces 9-10)\n\n**Objective**: Close both sorry sites.\n\n**Step 5.1**: Close `gap_prior_UZ_contradiction` (piece 9)\n- Assemble pieces 3, 4, 5, 8:\n  1. R = gap_formula_R, correct by piece 3\n  2. R holds at a in M (piece 4)\n  3. Surgery model N defined (piece 5)\n  4. R holds at a in N (by piece 8, truth preservation)\n  5. right_gap_class_prop fails at a in N (class boundary is successor pair in N, not gap)\n  6. But R correct means right_gap_class_prop holds at a in N. Contradiction.\n- Success criterion: `gap_prior_UZ_contradiction` compiles with `sorry` replaced by actual proof\n\n**Step 5.2**: Close `gap_prior_SZ_contradiction` (piece 10)\n- Try Order.dual approach first:\n  - Check if `SuccOrder (OrderDual M.carrier)` = `PredOrder M.carrier` (and vice versa) automatically\n  - Check if `semantic_prior_SZ M atomMap` translates to `semantic_prior_UZ (OrderDual M) atomMap_dual`\n  - If so, apply `gap_prior_UZ_contradiction` on the dual\n- If Order.dual does not compose cleanly, implement symmetric argument manually\n- Success criterion: `gap_prior_SZ_contradiction` compiles without sorry\n\n### Session 6: Wiring + Verification (Piece 11)\n\n**Objective**: Connect model surgery to the main pipeline and verify the build.\n\n**Step 6.1**: Wire `no_gaps_discrete` to `no_gaps_discrete_model_surgery`\n- Add import of `GoodStructuresModelSurgery` to `GoodStructures.lean`\n- Replace sorry at line 852 with theorem application\n- Check: does the signature match? May need to massage hypothesis names.\n\n**Step 6.2**: Verify full build\n- Run `lake build` and check that the sorry count in the completeness pipeline decreases\n- Verify that `one_class` becomes sorry-free (inherits from `no_gaps_discrete`)\n- Verify that `chronicle_is_good_direct` becomes sorry-free (inherits from `one_class`)\n- Check `#print axioms completeness_discrete` to see if `sorryAx` disappears (it may not, since `completeness_discrete` uses Path A which is already sorry-free; the `sorryAx` may come from other theorems in the same module)\n\n**Step 6.3**: Cleanup\n- Remove any temporary sorry's left in helper lemmas\n- Add documentation comments to the key pieces\n- Ensure all definitions are `@[simp]` or `@[reducible]` as appropriate\n\n---\n\n## Summary of Key Numbers\n\n| Metric | Value |\n|--------|-------|\n| Sorry sites to close | 2 (gap_prior_UZ_contradiction, gap_prior_SZ_contradiction) |\n| Plus 1 wiring change | no_gaps_discrete -> no_gaps_discrete_model_surgery |\n| New lemmas/definitions needed | 11 pieces |\n| Total estimated LOC | ~700 (range 550-900) |\n| Hardest piece | surgery_truth_preservation (200 lines, 30 subcases) |\n| Most blocked piece | eval_good_rel_lifted (everything depends on it) |\n| Implementation sessions | 4-6 sessions of 2-4 hours |\n| Downstream impact | Makes no_gaps_discrete, one_class, chronicle_is_good_direct sorry-free |\n| Critical path impact on completeness_discrete | None (completeness_discrete uses Path A which is already sorry-free) |\n| Mathematical value | Completes the Reynolds model surgery formalization, making the mathematical content sorry-free even though the downstream packaging to TaskFrame has a separate obstruction |\n\n### Risk Assessment\n\n| Risk | Probability | Mitigation |\n|------|-------------|------------|\n| De Bruijn fix (piece 1) proves harder than expected | 25% | Sorry it temporarily, use Fix C (inline formula) as fallback |\n| Surgery model fails to carry required type class instances | 20% | Define instances manually instead of deriving; may need auxiliary lemmas about subtype orders |\n| Order.dual does not compose cleanly for SZ case | 40% | Fall back to symmetric manual argument (~150 lines instead of ~60) |\n| Class homogeneity argument (piece 6) is harder than estimated | 30% | This is the most conceptually novel piece; may need creative encoding of \"formula holds somewhere in my class\" |\n| Total LOC significantly exceeds 700 | 30% | The 700 estimate is for clean implementation; debugging and auxiliary lemmas could push to 900-1000 |"
=== LOOKING FOR LONG TEXT ===


# Synthesis Report: Reynolds Model Surgery Implementation Path

## 1. Root Cause Analysis

### Why Previous Attempts Failed

The 17+ implementation cycles reveal three distinct failure modes, each with a different root cause:

**Failure Mode A: Wrong Mathematical Target (cycles 1-14)**

The dominant failure pattern is agents attempting to construct a temporal formula detecting `contemp_equiv` class *membership* (i.e., "is t in the same class as a?") rather than Reynolds' actual construction of `right_gap_class` (i.e., "does t's class end in a gap on the right?"). This is a misreading of Reynolds' proof. The class membership formula is provably impossible: `contemp_equiv sig k M a t` depends on a fixed element `a`, but `MonadicFormula sig 1` has only one free variable (for `t`) and cannot reference specific carrier elements. This is not a Lean limitation but a mathematical impossibility -- monadic FO with one free variable and finitely many predicates cannot define membership in a specific equivalence class over an infinite domain.

Reynolds' actual construction avoids this by detecting a *structural property* of classes (whether the boundary is a gap), which is definable because it only uses quantified variables, never referencing a fixed element. The formula `right_gap_class_formula` has been correctly identified and defined in the codebase. This failure mode is now understood and should not recur.

**Failure Mode B: Shortcut Attempts Around Model Surgery (cycles 15-16)**

Once the correct formula target was identified, agents attempted to derive contradictions without the full model surgery -- using `prior_UZ_first_transition` directly on the gap formula R, or enriching the signature with R as a new predicate. These fail for deep mathematical reasons:

- Direct Prior-UZ on R fails because R might hold at ALL points (no transition to contradict).
- Enriched signature fails because the gap-detecting predicate itself violates Prior-UZ at the gap boundary (the gap prevents the first-occurrence property).

The model surgery IS mathematically necessary. Reynolds' proof works precisely because it constructs a *new model* where the gap is replaced by a successor-pair boundary, preserves temporal truth across the surgery, and then derives a contradiction from the changed boundary type. There is no shortcut.

**Failure Mode C: De Bruijn Index Arithmetic (cycle 17, current blocker)**

The one attempt that correctly identified both the right formula target AND the necessity of model surgery got blocked on a Lean-specific technical issue: proving that `good_rel_lifted` (obtained by applying `lift` twice to `good_formula_relativized`) evaluates correctly under a 4-variable environment constructed via `Fin.cons`. The issue is that `Fin.cons` uses `Fin.cases` (pattern matching on 0 vs succ) while `insertEnv` uses `dif` (conditional on index value), and their simplification lemmas do not compose when the index is a variable.

This is a fixable engineering problem, not a fundamental obstruction.

### Is There a Fundamental Mismatch?

No. The Reynolds proof and the Lean formalization are compatible. The existing infrastructure (US expressive completeness over Prior structures, right_gap_class_prop with invariance/succ/pred preservation, good_sentence/good_formula_relativized with correctness proofs, relativize/relativize_correct, prior_UZ_first_transition/prior_SZ_last_transition) is all sorry-free and correctly aligned with Reynolds' proof structure. The gap is purely in the unimplemented portions: the formula correctness proof (blocked by De Bruijn arithmetic), and the model surgery itself (never attempted).

The 700-line estimate for the remaining work is realistic. The mathematical content is well-understood. The implementation requires careful but straightforward Lean engineering.

---

## 2. The Minimal Path

### Critical Sorry Sites

There are exactly 2 sorry sites that must be closed:

1. `gap_prior_UZ_contradiction` at `GoodStructuresModelSurgery.lean:831`
2. `gap_prior_SZ_contradiction` at `GoodStructuresModelSurgery.lean:857`

Plus one wiring change:

3. Replace `sorry` in `no_gaps_discrete` at `GoodStructures.lean:852` with delegation to `no_gaps_discrete_model_surgery`

### Minimal Lemma Set (11 pieces, ~700 lines total)

I will list these in dependency order. For each, I provide the conceptual type signature, estimated LOC, difficulty, and what it depends on.

**Piece 1: `eval_good_rel_lifted` (~40 lines, moderate)**

```
theorem eval_good_rel_lifted (M : OrderedMonadicStructure sig)
    (env : Fin 4 -> M.carrier) :
    eval M env (good_rel_lifted sig k) <->
    eval M (Fin.cons (env 2) (Fin.cons (env 3) Fin.elim0))
      (good_formula_relativized sig k)
```

Depends on: `good_formula_relativized` (exists), `lift_eval` (exists).
Blocks: piece 2.

**Piece 2: `right_gap_class_formula_correct` (~80 lines, hard)**

```
theorem right_gap_class_formula_correct (M : OrderedMonadicStructure sig)
    (t : M.carrier) :
    eval M (fun _ => t) (right_gap_class_formula sig k) <->
    (exists b : M.carrier, t < b /\\
      exists a' b' : M.carrier, t <= a' /\\ a' <= b' /\\ b' <= b /\\
        not (good sig k (M.subinterval sig a' b')))
```

Depends on: piece 1.
Blocks: piece 3.
Note: This captures only the "class bounded above with bad subinterval" part of `right_gap_class_prop`. The succ-closed conjunct is always true (by `no_boundary_at_successor`) and need not be encoded.

**Piece 3: `gap_formula_R` definition + `gap_formula_R_correct` (~40 lines, moderate)**

```
def gap_formula_R (sig : MonadicSignature) (k : Nat)
    (atomMap : Formula -> sig.preds) : Formula :=
  (US_expressively_complete_over_prior sig k M atomMap h_surj h_prior_UZ h_prior_SZ
    (right_gap_class_formula sig k)).val

theorem gap_formula_R_correct (t : M.carrier) :
    temporal_truth M atomMap t (gap_formula_R ...) <->
    right_gap_class_prop sig k M t
```

Depends on: piece 2, `US_expressively_complete_over_prior` (exists, sorry-free).
Blocks: pieces 4, 9.

**Piece 4: `R_interval_analysis` (~55 lines, routine)**

```
-- R holds at a (the assumed gap point)
lemma R_holds_at_a : temporal_truth M atomMap a (gap_formula_R ...)

-- R fails at some point (because y is not in class(a) but class(a) is succ-closed,
-- so y's class has no gap on the right in the same sense)
lemma R_false_somewhere : exists z, not (temporal_truth M atomMap z (gap_formula_R ...))

-- First R-to-not-R transition exists
lemma R_first_transition : exists c, temporal_truth M atomMap c (gap_formula_R ...) /\\
    not (temporal_truth M atomMap (Order.succ c) (gap_formula_R ...))
```

Depends on: piece 3, `prior_UZ_first_transition` (exists, sorry-free).
Blocks: piece 5.

**Piece 5: `surgery_model_construction` (~40 lines, moderate)**

```
-- The surgery domain: points outside the bad R-interval, plus one representative class I
def surgery_carrier : Type := ...  -- subtype of M.carrier

-- The surgery model inherits order and predicates from M
instance : OrderedMonadicStructure sig (surgery model) := ...

-- Key property: the representative class I ends at a successor boundary in N, not a gap
lemma surgery_class_boundary_is_successor : ...
```

Depends on: piece 4.
Blocks: pieces 6, 8.

**Piece 6: `class_homogeneity_in_R_intervals` (~60 lines, hard)**

Reynolds Lemma 9: All contemp_equiv classes in a maximal R-interval are elementarily equivalent. If a monadic formula A distinguishes classes C1 and C2 in the same R-interval, construct temporal B (via expressive completeness) true exactly when A holds somewhere in the current class. B transitions between classes at the gap boundary, violating Prior-UZ (which requires transitions at successor pairs). Contradiction.

Depends on: piece 5, `doets_lemma_1_1` (exists, sorry-free), `US_expressively_complete_over_prior` (exists).
Blocks: piece 7.

**Piece 7: `formula_propagation_in_bad_intervals` (~40 lines, moderate)**

Reynolds Lemmas 10-11: Both R and L hold throughout bad intervals. Formulas true at class boundaries propagate throughout.

Depends on: piece 6.
Blocks: piece 8.

**Piece 8: `surgery_truth_preservation` (~200 lines, hard -- the bulk)**

Reynolds Lemma 12: For all temporal formulas A and all points t in the surgery model N:
`temporal_truth M atomMap t A <-> temporal_truth N atomMap_N t A`

Induction on formula structure:
- `atom`: trivial (same predicates at same points) -- ~5 lines
- `bot`: trivial -- ~3 lines
- `imp`: by induction hypothesis -- ~5 lines
- `box`: by induction hypothesis (S5 single-class, identity box) -- ~10 lines
- `untl(A, B)`: 13 subcases (7 forward M->N, 6 backward N->M) -- ~85 lines
- `snce(A, B)`: 13 subcases mirroring untl -- ~85 lines

Each U/S subcase depends on which regions (Q-, I, Q0\\I, Q+) contain the witness point s and the current point t, and uses pieces 6-7 for transferring formula truth between classes.

Depends on: pieces 5, 7.
Blocks: piece 9.

**Piece 9: `contradiction_derivation` (~40 lines, moderate)**

Reynolds Lemma 13: Close `gap_prior_UZ_contradiction`.

In surgery model N:
1. R holds at representative point i in I (by piece 8, truth preservation from M where R holds by piece 4).
2. By `gap_formula_R_correct` applied to N (which is a Prior structure -- any counterexample in N is one in M by piece 8), R true at i means i's class in N ends in a gap.
3. But i's class in N ends at a successor boundary (piece 5), not a gap.
4. Contradiction.

Depends on: pieces 3, 8.
Blocks: piece 10.

**Piece 10: `gap_prior_SZ_contradiction_close` (~100 lines, moderate)**

Close `gap_prior_SZ_contradiction`. Two approaches:

*Approach A (Order.dual, ~60 lines)*: Show that applying `OrderDual` to M transforms `semantic_prior_SZ` into `semantic_prior_UZ` and `right_gap_class_prop` for left-gaps into `right_gap_class_prop` for right-gaps. Then apply `gap_prior_UZ_contradiction` on the dual. Requires verifying all type class instances (`SuccOrder`, `PredOrder`, `NoMaxOrder`, `NoMinOrder`) transfer correctly under `OrderDual`.

*Approach B (symmetric argument, ~150 lines)*: Mirror the entire UZ argument using `S(A,B)` instead of `U(A,B)`, `left_gap_class` instead of `right_gap_class`, and `prior_SZ_last_transition` instead of `prior_UZ_first_transition`.

Approach A is preferred if the type class instances compose cleanly.

Depends on: piece 9.
Blocks: piece 11.

**Piece 11: `wire_no_gaps_discrete` (~5 lines, routine)**

```
-- In GoodStructures.lean, replace sorry at line 852 with:
exact no_gaps_discrete_model_surgery sig k M atomMap h_surj h_prior_UZ h_prior_SZ a b h_diff_class
```

This requires adding `import Theories.Bimodal.Metalogic.WeakCanonical.IntegerModel.GoodStructuresModelSurgery` to GoodStructures.lean.

Depends on: piece 10.

---

## 3. The Fin.cons/insertEnv Problem

### Diagnosis

The blocker is in piece 1 (`eval_good_rel_lifted`). The definition of `good_rel_lifted` applies `lift` twice to `good_formula_relativized`:

```lean
def good_rel_lifted (sig : MonadicSignature) (k : Nat) : MonadicFormula sig 4 :=
  (good_formula_relativized sig k).lift 2 |>.lift 3
```

The `lift_eval` theorem states (roughly):

```lean
theorem lift_eval (phi : MonadicFormula sig n) (c : Nat) (M) (env : Fin (n+1) -> M.carrier) :
    eval M env (phi.lift c) = eval M (insertEnv c env) phi
```

where `insertEnv c env` drops the `c`-th variable from the environment. To compose two `lift` applications, one must show:

```
eval M env4 ((good_formula_relativized sig k).lift 2 |>.lift 3)
= eval M (insertEnv 3 env4) ((good_formula_relativized sig k).lift 2)   -- first lift_eval
= eval M (insertEnv 2 (insertEnv 3 env4)) (good_formula_relativized sig k)  -- second lift_eval
```

Then one must show that `insertEnv 2 (insertEnv 3 env4)` agrees with `Fin.cons (env4 2) (Fin.cons (env4 3) Fin.elim0)` on all indices in `Fin 2`, because `good_formula_relativized` is a `MonadicFormula sig 2`.

The difficulty: `insertEnv c env` is defined using `dif` (if `i.val < c then env (Fin.castSucc i) else env (Fin.succ i)`), while `Fin.cons` uses `Fin.cases` (pattern matching on `0` vs `succ`). When the index `i` is a *variable* (not a concrete numeral), `simp` cannot reduce either definition to a normal form that makes them equal.

### Is This Fundamental?

No. This is a purely technical Lean issue with De Bruijn index management. The mathematical content is trivial: both functions map `{0, 1}` to the same pair of carrier elements. The issue is making Lean's type system see this.

### The Fix

There are three viable approaches, in order of preference:

**Fix A: Case-split on `Fin 2` indices (~15 lines)**

Since `good_formula_relativized` is a `MonadicFormula sig 2`, its `eval` only queries the environment at indices in `Fin 2`. There are exactly two indices: `0` and `1`. Case-split on each:

```lean
theorem eval_good_rel_lifted ... := by
  unfold good_rel_lifted
  rw [lift_eval, lift_eval]
  congr 1
  ext i
  fin_cases i <;> simp [insertEnv, Fin.cons]
```

If `fin_cases` does not work directly on `Fin 2` indices inside `eval`, use `funext` first, then `fin_cases i`. The key insight is that `eval` is parametric in the environment and two environments that agree on all indices give the same result. If there is an `eval_congr` or `eval_ext` lemma available, use it. Otherwise, prove a small extensionality lemma first.

**Fix B: Use `weaken` instead of `lift` (~25 lines)**

The function `weaken` (= `lift 0`) has a simpler correctness theorem (`weaken_eval`) that composes with `Fin.cons` directly:

```lean
theorem weaken_eval (phi : MonadicFormula sig n) (M) (env : Fin (n+1) -> M.carrier) :
    eval M env phi.weaken = eval M (Fin.tail env) phi
```

Redefine `good_rel_lifted` using `weaken` combined with variable permutation instead of `lift 2` and `lift 3`. This avoids the `insertEnv` problem entirely but requires restructuring the formula definition.

**Fix C: Inline the formula directly (~40 lines)**

Instead of lifting `good_formula_relativized` through two De Bruijn lifts, construct `right_gap_class_formula` directly as a `MonadicFormula sig 1` using explicit quantifiers and atomic formulas, bypassing the lift machinery entirely. This is less modular but avoids all De Bruijn composition issues.

**Recommendation**: Try Fix A first (5 minutes of work). If `fin_cases`/`simp` do not close it, try Fix C (more work but guaranteed to succeed since it sidesteps the problem entirely).

---

## 4. Recommended Strategy

### What the Next Implementation Attempt MUST Do

1. **Start with the De Bruijn fix (piece 1)**, since everything else is blocked on it.
2. **Use sorry-first-then-fill for pieces 1-8**, working toward the contradiction derivation (piece 9) as the primary goal.
3. **Actually write the model surgery construction** (pieces 5-8). This has never been attempted in 17+ cycles and is the mathematical core of the proof.

### What the Next Implementation Attempt Must NOT Do

Based on failure history, the following approaches are **proven dead ends** and must not be attempted:

- **DO NOT** construct a temporal formula detecting `contemp_equiv` class membership (`class_temporal_formula`). This is mathematically impossible.
- **DO NOT** try to bypass model surgery with a direct Prior-UZ argument on R. The formula R may hold everywhere, providing no transition to contradict.
- **DO NOT** enrich the monadic signature with `right_gap_class` as a new predicate and try to prove Prior-UZ for the enriched structure. The gap specifically violates Prior-UZ for gap-detecting predicates.
- **DO NOT** use `h_accessible` instead of `h_surj`. They are different properties; only `h_surj` enables expressive completeness.
- **DO NOT** attempt to prove `no_gaps_prior` or `no_gaps_faithful` as stated. They are mathematically false (Z+Z counterexample).
- **DO NOT** spend time on the `countermodel_discrete_reynolds` packaging sorry (Transfer.lean:1289). It is declared unsolvable and is not on the critical path for `completeness_discrete`.

### Dependency Order for Construction

```
Phase 1 (Formula): pieces 1 -> 2 -> 3          (~160 lines)
Phase 2 (Analysis): piece 4                      (~55 lines)
Phase 3 (Surgery): pieces 5 -> 6 -> 7 -> 8      (~340 lines)
Phase 4 (Close): pieces 9 -> 10 -> 11           (~145 lines)
```

### Sorry-First Strategy

The recommended approach is to sorry pieces 1-8 initially, write the contradiction derivation (piece 9) with sorry'd helper lemmas, verify the overall proof structure compiles, and then fill in the sorrys from bottom up (pieces 1 through 8). This is because:

- The contradiction derivation (piece 9) is where the mathematical argument terminates. Writing it first validates the entire proof architecture.
- The surgery truth preservation (piece 8) is the hardest piece but has 30 independent subcases that can be filled one at a time.
- The De Bruijn fix (piece 1) is the most uncertain piece; sorry'ing it lets the rest of the work proceed while it is being solved.

### Hardest Pieces (likely to require the most debugging)

1. **surgery_truth_preservation** (piece 8, ~200 lines): 30 subcases for U/S temporal truth preservation. Each subcase requires reasoning about which region (Q-, I, Q0\\I, Q+) contains the relevant points. The subcases are independent but numerous.

2. **right_gap_class_formula_correct** (piece 2, ~80 lines): De Bruijn index correctness proof. Requires careful management of variable environments.

3. **class_homogeneity_in_R_intervals** (piece 6, ~60 lines): Requires constructing auxiliary temporal formulas via expressive completeness and applying Prior-UZ to derive contradictions. Conceptually deep.

### Estimated Total Effort

- **Lines of Lean code**: ~700 (range: 550-900 depending on verbosity and whether Order.dual works for piece 10)
- **Implementation sessions**: 4-6 sessions of 2-4 hours each
  - Session 1: Pieces 1-3 (formula construction, De Bruijn fix)
  - Session 2: Pieces 4-5 (R-interval analysis, surgery domain definition)
  - Session 3: Piece 6-7 (class homogeneity, formula propagation)
  - Session 4: Piece 8 (surgery truth preservation -- the bulk)
  - Session 5: Pieces 9-10 (contradiction + SZ case)
  - Session 6: Piece 11 + cleanup + lake build verification

---

## 5. Concrete Implementation Checklist

### Session 1: Gap Formula Construction (Pieces 1-3)

**Objective**: Produce a temporal formula R with a sorry-free correctness theorem connecting it to `right_gap_class_prop`.

**Step 1.1**: Fix `eval_good_rel_lifted` (piece 1)
- File: `GoodStructuresModelSurgery.lean`, after line ~760
- Try Fix A first: `ext i; fin_cases i <;> simp [insertEnv, Fin.cons]`
- If that fails, try Fix C: inline the formula directly
- Success criterion: `eval_good_rel_lifted` compiles without sorry

**Step 1.2**: Prove `right_gap_class_formula_correct` (piece 2)
- File: `GoodStructuresModelSurgery.lean`, after the formula definition at line ~787
- Unfold `right_gap_class_formula`, apply `eval_good_rel_lifted`, compose with `good_formula_relativized_correct`
- Handle the quantifier structure (exists b, exists a', exists b', ...)
- Success criterion: theorem compiles without sorry, connecting `eval M (fun _ => t) (right_gap_class_formula sig k)` to the semantic predicate

**Step 1.3**: Construct `gap_formula_R` and prove correctness (piece 3)
- File: `GoodStructuresModelSurgery.lean`, after step 1.2
- Apply `US_expressively_complete_over_prior` to `right_gap_class_formula`
- Obtain temporal Formula R and its correctness: `temporal_truth M atomMap t R <-> right_gap_class_prop sig k M t`
- Note: The full `right_gap_class_prop` includes succ-closed, but this is always true by `no_boundary_at_successor`. The formula only needs to encode the "bounded above with bad subinterval" part. Bridge the gap by showing the formula's semantic content plus `contemp_equiv_succ_closed_of_no_boundary` gives full `right_gap_class_prop`.
- Success criterion: `gap_formula_R_correct` compiles without sorry

**Fallback for Session 1**: If pieces