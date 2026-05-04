   Direct approach: Use burgess_zeta_consistent with h_neg_until derived as follows.
   Since β.neg ∈ B, from burgessR3: untl(β.neg, γ_hat) ∈ A. Now we want ¬untl(b∧β, γ_hat) ∈ A.
   I'll prove: untl(b∧β, γ_hat) ∉ A, which by MCS completeness gives ¬untl(b∧β, γ_hat) ∈ A.
   Proof by contradiction: Assume untl(b∧β, γ_hat) ∈ A. Since b → β.neg, we have (b∧β) → (β.neg∧β) → ⊥. By untl_left_mono_thm: untl(⊥, γ_hat) ∈ A.
   Now from untl(⊥, γ_hat) ∈ A, by BX10: F(γ_hat) ∈ A. 
   Hmm, this still doesn't give a contradiction. We need F(γ_hat) ∉ A for some reason. But γ_hat is in C and F(γ_hat) could perfectly well be in A.
   Let me try yet another route. Actually, I think I should look at what happens with untl(b∧β, γ_hat) when the guard is contradictory. Under open-guard semantics, if the guard is ⊥, the Until cannot hold. But is this reflected in our axiom system?
   Let me search for theorems about untl(bot, ...):
   Actually, we might be able to prove ⊢ (untl bot ψ).neg (i.e. untl(bot, ψ) is refutable) in our logic. If so, then untl(bot, γ_hat) ∈ A would contradict MCS consistency (since A contains the negation as a theorem).
   Can we prove ⊢ ¬U(⊥, ψ) in our axiom system? Let me think about the soundness: Under open-guard semantics, U(⊥, ψ) is always false (the universal quantifier over the interval fails because ⊥ is never true). If our axioms are complete for this semantics, then ¬U(⊥, ψ) should be provable.
   But do we have a direct proof? Let me check if there's a lemma...
   Actually, let me approach this differently. The simplest way out: just call burgess_zeta_consistent and provide a lemma that derives ¬untl(b∧β, γ_hat) ∈ A from β.neg ∈ B + burgessR3. I'll construct it using MCS case split:
   1. By MCS negation_complete: either untl(b∧β, γ_hat) ∈ A or (untl(b∧β, γ_hat)).neg ∈ A
   2. Show the first case leads to contradiction using a custom lemma
   3. Therefore the second case holds
   For step 2, I need: untl(b∧β, γ_hat) ∈ A → False.
   From b → β.neg (since β.neg ∈ b_list), we have ⊢ (b∧β) → ⊥. So untl_left_mono_deriv (b∧β) γ_hat ⊥ h_impl gives ⊢ untl(b∧β, γ_hat) → untl(⊥, γ_hat).
   Now from untl(b∧β, γ_hat) ∈ A, using theorem_in_mcs + modus ponens: untl(⊥, γ_hat) ∈ A.
   By BX10: F(γ_hat) ∈ A.
   Hmm, and F(γ_hat) ∈ A doesn't directly contradict anything.
   Wait, actually I think the plan's argument is wrong. Let me think about what Burgess actually says for the inconsistent case.
   In Burgess's paper (p. 370-371), the lemma 2.6 proof says (paraphrasing): "D₀ = {S(α,β): α∈A, β∈B} ∪ B ∪ {∼δ} ∪ {U(γ,β): γ∈C, β∈B}. When {δ}∪B is inconsistent, ∼δ ∈ B and the seed is just B ∪ U/S formulas." The consistency is then proved via the BX chain.
   I think the key is that burgess_zeta_consistent already handles the BX chain, and the inconsistent case just needs to provide ¬untl(b∧β, γ_hat) ∈ A. This can be derived from β.neg ∈ B as follows:
   Actually, I just realized: burgess_zeta_consistent has the UNUSED parameter h_F_beta_neg. Maybe the intended use is that in the consistent case, we need to derive F(β.neg) ∈ A first, and then use it. In the inconsistent case, F(β.neg) ∈ A is already derivable because untl(β.neg, γ_hat) ∈ A (burgessR3) → BX10 → F(γ_hat) ∈ A.
   Hmm, that's F(γ_hat), not F(β.neg). Let me re-examine.
   Actually, I think the correct simplified approach is:
   In burgess_D0_finite_subset_consistent_incons, since β.neg ∈ B and b is the conjunction of B-guards including β.neg:
   - b → β.neg (conjunction elimination)
   - Hence ⊢ (b∧β) → ⊥
   - So ⊢ ¬(b∧β) and as an Until formula: ⊢ ¬untl(b∧β, γ_hat)?
   Is ⊢ ¬untl(⊥, γ_hat) provable? Let me check. Under open guard, untl(φ, ψ) means ∃s>t: ψ(s) ∧ ∀u∈(t,s): φ(u). With φ=⊥, the ∀ condition can never be satisfied. So indeed ⊢ ¬untl(⊥, ψ) for any ψ.
   But is this provable in our BX axiom system? I think so:
   - BX16 (converse_until): F(ψ) → untl(⊤, ψ) (where ⊤ = bot.imp bot). This gives one direction.
   - BX10 (until_F): gives the other direction.
   - For untl(⊥, ψ): We have ⊢ ⊥ → ⊥ (identity) but we need ⊢ ¬untl(⊥, ψ).
   Actually, I think we can prove it using the soundness of our system and the fact that the semantics has open guard. But in a syntactic way...
   Let me check if there's an axiom or theorem ¬U(⊥, ψ). Looking at the axioms...
   Actually, from self_accum_until (BX5): untl(⊥, ψ) → untl(⊥∧untl(⊥,ψ), ψ). Not helpful.
   From converse_until (BX16): F(ψ) → untl(⊤, ψ). Not about ⊥.
   I think this might need a custom lemma. Let me try to construct it:
   ⊢ ¬untl(⊥, ψ) proof: Consider the contrapositive of until_F: from ⊢ ¬F(ψ) → ¬untl(φ, ψ), but we don't have an axiom for this direction.
   Hmm, maybe I should just look for existing theorems...
   Let me search for bot and untl in the theorem files.
   Actually, I think I'm overcomplicating this. Let me look at what the code actually needs.
   The code needs:
   - h_ev_b : DerivationTree [] (event.imp b) 
   - h_ev_untl : DerivationTree [] (event.imp (Formula.untl b γ_hat))
   Where event is the enriched event from iterated_enrichment. But the enrichment process doesn't make event imply b or untl(b, γ_hat).
   So the solution is to restructure the code to use burgess_zeta_consistent instead. For that, I need ¬untl(b∧β, γ_hat) ∈ A.
   Let me try to prove it:
   Since β.neg ∈ B and b = conjunction of all B-guards (including β.neg):
   - b → β.neg is provable (by conjunction elimination)
   Now I need to prove: untl(b∧β, γ_hat) ∉ A.
   Suppose untl(b∧β, γ_hat) ∈ A. Since b → β.neg:
   - (b∧β) → (β.neg∧β) → ⊥
   - By untl_left_mono_thm: untl(⊥, γ_hat) ∈ A
   From untl(⊥, γ_hat) ∈ A, we also have (from burgessR3) untl(b, γ_hat) ∈ A. 
   By untl_conj_guard (RRelation.lean:929): untl(b ∧ ⊥, γ_hat) ∈ A. Since b ∧ ⊥ = ⊥: untl(⊥, γ_hat) ∈ A. This is just the same thing.
   Hmm, I need a new lemma. Let me think about what lemma would help...
   Actually wait. Let me look at untl_conj_guard more carefully:
      theorem untl_conj_guard {A : Set Formula}
       (h_mcs : SetMaximalConsistent A)
       {β₁ β₂ γ : Formula}
       (h1 : Formula.untl β₁ γ ∈ A)
       (h2 : Formula.untl β₂ γ ∈ A) :
       Formula.untl (Formula.and β₁ β₂) γ ∈ A
   
   This combines two Until formulas with the same event γ into one. It doesn't help with ⊥.
   OK, I think I need to take a different approach entirely. Let me look at burgess_zeta_consistent more carefully and see if I can simplify it for the inconsistent case:
   In the consistent case, burgess_zeta_consistent uses:
   1. BX5 on untl(b, γ_hat) → untl(b∧untl(b,γ_hat), γ_hat) ∈ A
   2. BX14 (separation) with ¬untl(b∧β, γ_hat) → untl(q, q∧(b∧β).neg) ∈ A where q = b∧untl(b,γ_hat)
   3. BX13 iterated → enriches event with snce formulas
   4. BX10 → F(event) ∈ A
   In the inconsistent case, β.neg ∈ B. We have b → β.neg from conjunction elimination. So b∧β is contradictory.
   For step 2 (BX14), we need ¬untl(b∧β, γ_hat) ∈ A. 
   THE INSIGHT: Since β.neg ∈ B and B is DCS, we know ⊢ b → β.neg. Then if untl(b∧β, γ_hat) were in A, by left_mono we'd get untl(⊥, γ_hat) ∈ A. But untl(⊥, γ_hat).neg is a THEOREM (we need to prove this), which means it's in A (since A is MCS). So A has both untl(⊥, γ_hat) and its negation → contradiction → MCS inconsistent.
   So we need a lemma: ⊢ ¬untl(⊥, ψ) for any ψ. Let me try to prove this from our axioms.
   Actually, maybe I can prove it by contradiction at the semantic level (soundness) rather than syntactically. Let me check if there's a simpler syntatic approach.
   From BX10 (until_F): untl(φ, ψ) → F(ψ). The contrapositive is ¬F(ψ) → ¬untl(φ, ψ). This is NOT an axiom (we only have the forward direction).
   From BX6 (absorb_until): untl(ψ, ψ∧untl(φ, ψ)) → untl(φ, ψ). Not helpful.
   Hmm, I think I need a custom lemma. Let me just try to prove ¬untl(⊥, ψ) using the deduction theorem and modus ponens.
   Actually, maybe I should look at whether there's a ¬F(⊥) theorem. F(⊥) = some_future bot means "eventually false". Under serial time, this is always false. So ⊢ ¬F(⊥). But from untl(⊥, ψ), BX10 gives F(ψ), not F(⊥).
   Wait, I need to look at the axioms more carefully. Let me check connect_future (BX4):
   φ → G(P(φ)) where G = all_future, P = some_past. Not helpful for F(⊥).
   Let me search the codebase for any lemma about untl with ⊥:
   I think I should just look for untl and bot patterns in the theorems files.
   Actually, I just realized something. If b → β.neg, then we can PROVE (untl(b∧β, γ_hat)).neg directly using the MCS property:
   By MCS negation_completeness: either untl(b∧β, γ_hat) ∈ A or (untl(b∧β, γ_hat)).neg ∈ A.
   If the former, we need to derive a contradiction. Let me construct it differently. From untl(b, γ_hat) ∈ A and untl(b∧β, γ_hat) ∈ A:
   Using untl_conj_guard: untl(b ∧ (b∧β), γ_hat) ∈ A = untl((b∧b)∧β, γ_hat) ∈ A = untl(b∧β, γ_hat) ∈ A. 
   Not helpful, circular.
   OK, here's my final approach: I'll prove (untl(b∧β, γ_hat)).neg ∈ A by proving untl(b∧β, γ_hat) ∉ A via a MCS completeness argument and a custom lemma about untl(⊥, ψ).neg being a theorem.
   The custom lemma: lemma untl_bot_neg (ψ : Formula) : DerivationTree [] (Formula.untl Formula.bot ψ).neg.
   Can we prove this? Let me attempt:
   untl(bot, ψ) means we need a future point where ψ holds AND bot holds everywhere in between. Bot never holds, so this is impossible.
   Syntactically, I think we can argue:
   - BX10 gives: untl(bot, ψ) → F(ψ) 
   - But we need the negation: ¬untl(bot, ψ)
   Actually, maybe we can argue using the fact that G(⊤) is a theorem and untl(bot, ψ) → F(ψ). If F(ψ) and G(⊤) coexist, there's no contradiction directly.
   I think the real issue is that this specific lemma may not be easily provable in our BX axiom system. Let me try a COMPLETELY DIFFERENT approach:
   New approach for the inconsistent case:
   Instead of using burgess_zeta_consistent, let me directly prove the consistency of the seed differently. When β.neg ∈ B:
   The seed D₀ = B ∪ {β.neg} ∪ {untl(β',γ): β'∈B, γ∈C} ∪ {snce(β',α): β'∈B, α∈A}.
   Since β.neg ∈ B already, this simplifies to: D₀ = B ∪ untl-formulas ∪ snce-formulas.
   Now, any finite L ⊆ D₀ has:
   - B-elements
   - untl(β',γ) where β'∈B, γ∈C
   - snce(β',α) where β'∈B, α∈A
   I'll use the compressed form: b = ∧(B-guards of L ∪ {β.neg}) ∈ B, γ_hat = ∧(C-events) ∈ C.
   Now from burgessR3: untl(b, γ_hat) ∈ A. (Since b ∈ B, γ_hat ∈ C)
   BX5: untl(b ∧ untl(b, γ_hat), γ_hat) ∈ A = untl(q, γ_hat) ∈ A where q = b∧untl(b,γ_hat).
   BX10: F(γ_hat) ∈ A. This gives us that {γ_hat} is consistent (via consistent_of_F_mem).
   Now, I need to connect γ_hat to all elements of L. Let me think...
   Actually, there's a different approach that I think works: modify the code to use burgess_zeta_consistent and provide ¬untl(b∧β, γ_hat) ∈ A using a direct MCS case split + a new lemma that untl(bot, ψ).neg is a theorem. Let me create this lemma now.
   Lemma: theorem untl_bot_neg (ψ : Formula) : DerivationTree [] ((Formula.untl Formula.bot ψ).neg) :=
   Proof idea: We have axiom until_F which gives untl(bot, ψ) → F(ψ). From temporal duality, we also have G(⊤) as a theorem. Actually we need ¬F(ψ). 
   Wait no. Actually, I don't think ¬untl(bot, ψ) is provable in our system. Under open guard, the guard on (t,s) requires bot to hold everywhere in between. Since BOT is false at every point, the universal quantifier fails. So semantically, untl(bot, ψ) is always false. But syntactically, we need a proof.
   I think this lemma IS provable from the BX axioms. Let me try to construct it:
   From connect_future (BX4): ¬ψ → G(P(¬ψ)) — not helpful.
   Actually, maybe I can use self_accum_until (BX5) in reverse: if untl(bot, ψ), then untl(bot ∧ untl(bot,ψ), ψ). Since bot ∧ X = bot: untl(bot, ψ). This is just idempotence, no help.
   I think the cleanest approach is to create a lemma that uses the MCS case split and burgessR3 properties without needing ¬untl(b∧β, γ) ∈ A. Let me see if burgess_zeta_consistent can be modified or a new version created.
   Actually, you know what, let me just check: in the INCONSISTENT case, burgessR3 already gives us untl(β.neg, γ_hat) ∈ A. Now b → β.neg. So untl(b, γ_hat) ∈ A (via left_mono from untl(β.neg, γ_hat)).
   Wait, that's the opposite direction. b → β.neg means b is STRONGER (i.e., implies more things). So untl(β.neg, γ_hat) → untl(b, γ_hat) via... actually, b → β.neg, so β.neg is WEAKER. More precisely:
   b → β.neg means b implies β.neg. If we have untl(β.neg, γ_hat) ∈ A, we need the guard β.neg to be replaced by b. This is GUARD STRENGTHENING, which is NOT valid (left_mono goes the OTHER way: weaker guard implies stronger guard? No, let me check).
   BX2 (left_mono_until): (φ→χ)∧G(φ→χ) → untl(φ,ψ) → untl(χ,ψ). So if φ implies χ, then untl(φ,ψ) → untl(χ,ψ).
   So: if b → β.neg, then untl(b, ψ) → untl(β.neg, ψ). That is, a STRONGER guard (b) implies a WEAKER guard (β.neg) result. So we CAN'T get untl(b, γ_hat) from untl(β.neg, γ_hat) — the direction is wrong.
   But we DO have untl(b, γ_hat) ∈ A directly from burgessR3 (since b ∈ B, γ_hat ∈ C). So this is not an issue.
   OK, I think the simplest and most robust solution for the inconsistent case is:
   1. Call burgess_zeta_consistent with the SAME pattern as the consistent case
   2. Prove ¬untl(b∧β, γ_hat) ∈ A using MCS case split + a new lemma untl_bot_neg that proves ⊢ ¬untl(⊥, ψ)
   3. Create the lemma untl_bot_neg using the soundness argument (or a direct derivation)
   Actually, I just realized I can construct untl_bot_neg from temporal axioms we have. Here's the idea:
   Under open-guard semantics:
   - untl(⊥, ψ) means: ∃s>t, ψ(s) and ∀u∈(t,s), ⊥(u).
   - ⊥(u) is always false, so the universal quantifier can never be satisfied.
   - Therefore ¬untl(⊥, ψ) is valid.
   Syntactically, one way: use the fact that ⊢ untl(⊤, ψ) ↔ F(ψ) (BX10 gives →, and BX16 gives ←). Then untl(⊥, ψ) → F(ψ) by BX10. But F(ψ) doesn't contradict ¬F(ψ) alone.
   Actually, I bet there's a simpler lemma. Let me look at what connect_future gives:
   ψ → G(P(ψ)) = ψ → all_future (some_past ψ).
   That doesn't help with bot either.
   Let me just try to construct a direct proof for ⊢ ¬untl(⊥, ψ):
   One approach: use the contrapositive of BX13 (enrichment_until). BX13 says: p ∧ untl(φ, ψ) → untl(φ, ψ ∧ snce(φ, p)). 
   Not helpful.
   Actually, let me try the simplest possible approach: use self_accum_until (BX5) repeatedly. 
   Actually I just realized maybe there's a lemma I'm missing. Let me search in the theorems files:
   OK, I think I need to just try to write the lemma. The simplest approach is probably to use the semantics: since soundness is proved, and ¬untl(⊥, ψ) is semantically valid under open-guard semantics, we can appeal to completeness (or just prove it directly from the axioms).
   Actually, I'll just take a pragmatic approach: create a new lemma untl_bot_neg that proves it directly, and if I can't prove it, I'll try an alternative strategy. Let me first look at the existing theorem files for relevant lemmas.
Let me check what theorems exist about untl with ⊥ and F:
✱ Grep "untl.*bot|untl.*⊥|bot.*untl|F.*bot|F.*⊥" in Theories/Bimodal/Theorems (385 matches)
✱ Grep "untl_bot|untl_false|until_bot|until_false" in Theories/Bimodal (5 matches)
Thinking: Let me understand the structure of the problem. In burgess_D0_finite_subset_consistent_incons, we have the case where β.neg ∈ B. The current function follows the same pattern as the consistent case but there's no BX14 step needed because the inconsistency doesn't need to insert β.neg into the event. Instead, we just need to show that event implies both b and untl(b, γ_hat).
Looking at the current approach:
- iterated_enrichment is called with q = b ∧ untl(b, γ_hat) as guard and γ_hat as event
- It returns event' with untl(q, event') ∈ A 
- evt.h_impl gives event' → γ_hat 
- But we need event' → b and event' → untl(b, γ_hat) 
The issue is that iterated_enrichment takes untl(guard, event) ∈ A and enriches the event. But it takes the guard q = b ∧ untl(b, γ_hat) and doesn't prove that the guard implies b. It preserves untl(q, event') but the guard q itself contains both components we need.
Wait, looking more carefully at iterated_enrichment:
iterated_enrichment h_mcs guard alphas event h_untl
where h_untl : untl guard event ∈ A
It returns EnrichedEvent A guard event alphas with:
- event' (enriched event)
- h_untl : untl guard event' ∈ A  
- h_impl : DerivationTree [] (event'.imp event)
- h_snce : ∀ α ∈ alphas, DerivationTree [] (event'.imp (snce guard α))
So h_impl gives event' → event where event is the base (which is γ_hat). But we need event' → b and event' → untl(b, γ_hat).
The guard q = b ∧ untl(b, γ_hat) contains b and untl(b, γ_hat). But we don't have event' → q. We only have untl(q, event') ∈ A. From untl(q, event') ∈ A and BX10, F(event') ∈ A. The key insight: we don't actually need event' → b and event' → untl(b, γ_hat) directly!
The h_event_implies_L block is the one that needs these implications. It uses h_ev_b to handle B-elements and h_ev_untl to handle Until formulas. But we could restructure this differently.
Actually, looking at the approach more carefully, the correct fix is to use the same burgess_zeta_consistent function with the right inputs. The question is: can we get ¬untl(b∧β, γ_hat) ∈ A when β.neg ∈ B?
Since β.neg ∈ B and b implies β.neg (because b is a conjunction that includes β.neg = β₀), we have ⊢ b → β.neg, so ⊢ b∧β → ⊥. Then ⊢ untl(b∧β, γ) → untl(⊥, γ). But untl(⊥, γ) → F(⊥) which contradicts G(⊤). So if untl(b∧β, γ) were in A, we'd get a contradiction. Hence ¬untl(b∧β, γ) ∈ A.
Actually wait, let me reconsider. iterated_enrichment called with q = b ∧ untl(b, γ_hat) as the guard and γ_hat as the event actually works differently than I thought. Let me re-read.
In burgess_D0_finite_subset_consistent_incons (lines 1811-1976):
- line 1860: let evt := iterated_enrichment h_mcs_A q a_list ha_list γ_hat h_bx5
- where h_bx5 = self_accum_until_mcs h_mcs_A b γ_hat h_untl_bg
- h_untl_bg : untl b γ_hat ∈ A
- h_bx5 : untl (b ∧ untl(b, γ_hat)) γ_hat ∈ A = untl q γ_hat ∈ A
So iterated_enrichment is called with guard q, alphas a_list (from A), event γ_hat, and h_bx5 which proves untl q γ_hat ∈ A.
The result evt has:
- evt.event' = some enriched event
- evt.h_untl : untl q evt.event' ∈ A (NOT untl q γ_hat)
- evt.h_impl : evt.event'.imp γ_hat 
- evt.h_snce : ∀ α, evt.event'.imp (snce q α)
Wait, let me re-read iterated_enrichment:
private noncomputable def iterated_enrichment {A : Set Formula}
    (h_mcs : SetMaximalConsistent A)
    (guard : Formula) :
    (alphas : List Formula) →
    (h_alphas : ∀ α ∈ alphas, α ∈ A) →
    (event : Formula) →
    Formula.untl guard event ∈ A →
    EnrichedEvent A guard event alphas
  | [], _, event, h_untl => EnrichedEvent.mk event h_untl (identity event) (fun _ h => by simp at h)
  | α :: rest, h_alphas, event, h_untl => by
    have h_α : α ∈ A := h_alphas α (List.mem_cons.mpr (Or.inl rfl))
    have h_enriched := enrichment_until_mcs h_mcs h_α h_untl
    have h_rest : ∀ α' ∈ rest, α' ∈ A := fun α' hα' =>
      h_alphas α' (List.mem_cons.mpr (Or.inr hα'))
    let evt := iterated_enrichment h_mcs guard rest h_rest
      (Formula.and event (Formula.snce guard α)) h_enriched
    exact EnrichedEvent.mk evt.event' evt.h_untl
      (imp_trans evt.h_impl (lce_imp event (Formula.snce guard α)))
      (fun α' hα' => by
        by_cases h_eq : α' = α
        · subst h_eq; exact imp_trans evt.h_impl (rce_imp event (Formula.snce guard α'))
        · have h : α' ∈ rest := by
            rcases List.mem_cons.mp hα' with rfl | h
            · exact absurd rfl h_eq
            · exact h
          exact evt.h_snce α' h)
So iterated_enrichment takes untl(guard, event) ∈ A and produces a new event' where:
- untl(guard, event') ∈ A (self - preserved)
- event' → event (h_impl)
- event' → snce(guard, α) for each α (h_snce)
In the inconsistent case, it's called with guard = q, event = γ_hat, and h_bx5 : untl(q, γ_hat) ∈ A. So:
- evt.h_impl : evt.event' → γ_hat
- evt.h_snce : evt.event' → snce(q, α) for each α∈a_list
But q = b ∧ untl(b, γ_hat) so snce(q, α) = snce(b ∧ untl(b, γ_hat), α). 
The problem is: we need event → b and event → untl(b, γ_hat) but iterated_enrichment only gives event → γ_hat and event → snce(q, α). The snce(q, α) formulas are for snce formulas in the seed, not for b or untl.
Now I see the fix. In the inconsistent case, we should use the exact same approach as the consistent case with burgess_zeta_consistent. The key input burgess_zeta_consistent requires is ¬untl(b∧β, γ_hat) ∈ A. 
Since β.neg ∈ B (this is the inconsistent case), and b is a conjunction that includes β₀ := β.neg (see line 1828), we have b → β.neg, so b∧β is contradictory. Therefore untl(b∧β, γ_hat) ∈ A would lead to a contradiction (via bot_until_bot_absurd or similar). Hence ¬untl(b∧β, γ_hat) ∈ A.
So I need to:
1. Prove ¬untl(b∧β, γ_hat) ∈ A when β.neg ∈ B and b contains β.neg
2. Then call burgess_zeta_consistent to get event, h_F_event, h_ev_b, h_ev_beta_neg, h_ev_untl, h_ev_snce
Let me write this proof. The key lemma I need: if ⊢ φ → ⊥ (i.e., φ is contradictory), then ¬(untl φ ψ) ∈ MCS A.
Actually, let me just directly prove ¬untl(b∧β, γ_hat) ∈ A:
1. β₀ := β.neg is in b_list (line 1829-1830)
2. b := list_conj b_list includes β₀ via conjunction elimination
3. So ⊢ b → β.neg and ⊢ b∧β → ⊥
4. If untl(b∧β, γ_hat) ∈ A, then by left_mono: untl(⊥, γ_hat) ∈ A (since ⊢ (b∧β) → ⊥)
5. BX10: F(γ_hat) = some_future γ_hat ∈ A
6. Also from ⊥: ⊢ ⊥ → ¬F(γ_hat), so G(¬F(γ_hat)) ∈ A? No...
Actually, let me use a simpler approach. From ⊢ (b∧β) → ⊥, we can derive ⊢ untl(b∧β, γ_hat) → untl(⊥, γ_hat) via left_mono. And we know from existing lemmas that untl(⊥, γ_hat) is contradictory (in MCS) because untl(⊥, γ_hat) → F(⊥) (BX10) and F(⊥) = ¬G(⊤) is contradictory to G(⊤) ∈ A.
Wait, let me check whether bot_until_bot_absurd is still valid. It might depend on BX9 which was removed:
def bot_until_bot_absurd : ⊢ (Formula.untl Formula.bot Formula.bot).imp Formula.bot := by
Let me look at it. Actually, looking at the TemporalDerived.lean earlier:
Line 183: def bot_until_bot_absurd : ⊢ (Formula.untl Formula.bot Formula.bot).imp Formula.bot := by
This might still be valid. Let me not go down that rabbit hole. Instead, let me just write the direct proof.
I think the simplest approach is actually to NOT use burgess_zeta_consistent and instead fix the proof directly in burgess_D0_finite_subset_consistent_incons.
The core issue: iterated_enrichment is called with guard = q = b ∧ untl(b, γ_hat) and h_bx5 : untl(q, γ_hat) ∈ A. The output evt gives:
- evt.h_untl : untl(q, event') ∈ A (not untl(q, γ_hat))
- evt.h_impl : event' → γ_hat
But we need event' → b and event' → untl(b, γ_hat). 
Hmm, let me just use burgess_zeta_consistent instead. The function requires:
1. b ∈ B, ha_list, hγ_C - we have these
2. ¬untl(b∧β, γ_hat) ∈ A - we need to prove this
Let me prove ¬untl(b∧β, γ_hat) ∈ A:
Since β.neg is in b_list (used as β₀), and b is list_conj b_list, we have ⊢ b → β.neg. Therefore ⊢ (b∧β) → ⊥.
If untl(b∧β, γ_hat) ∈ A, then:
- ⊢ (b∧β) → ⊥, so ⊢ untl(b∧β, γ_hat) → untl(⊥, γ_hat) (left_mono)
- So untl(⊥, γ_hat) ∈ A (MCS implication)
- untl(⊥, γ_hat) → F(⊥) (BX10), so F(⊥) ∈ A
- But G(⊤) ∈ A (theorem_in_mcs, because G(⊤) = G(⊥→⊥) is a theorem)
- F(⊥) = ¬G(¬⊥) = ¬G(⊤), contradicting MCS consistency
Therefore ¬untl(b∧β, γ_hat) ∈ A.
Then I can call burgess_zeta_consistent to get the event with the needed implications.
But wait, burgess_zeta_consistent returns a Sigma type (which is in Type, not Prop). Let me use the same pattern that the consistent case uses:
From lines 1684-1686:
obtain ⟨event, h_F_event, h_ev_b, h_ev_beta_neg, h_ev_untl, h_ev_snce⟩ :=
    burgess_zeta_consistent h_mcs_A h_mcs_C h_r3m β _h_β_not_B h_F_beta_neg
      b hb_B a_list ha_list γ_hat hγ_C h_neg_until_b
For the inconsistent case, I also need h_F_beta_neg : F(β.neg) ∈ A. But in the inconsistent case, we don't have this directly. However, burgess_zeta_consistent uses h_F_beta_neg but let me check if it's actually used... Looking at the body of burgess_zeta_consistent (lines 1272-1345), h_F_beta_neg is NOT used anywhere in the function body! It's a parameter that's never referenced.
Similarly _h_β_not_B is never used. So I can pass any dummy value for these. Or better, I can modify the calling convention.
Actually, looking at the function body, burgess_zeta_consistent only uses:
- h_mcs_A
- h_r3m (for h_r3)
- b, hb (for h_untl_bg)
- alpha_list, h_alphas (for enrichment_until_mcs)
- γ, hγ (for h_untl_bg)
- h_neg_until (for separation_until_mcs)
It does NOT use _h_mcs_C, h_F_beta_neg, _h_β_not_B, or β (except in (Formula.and b β) within h_neg_until).
So I can call burgess_zeta_consistent in the inconsistent case by providing dummy values for the unused args. But we need h_F_beta_neg : F(β.neg) ∈ A... let me check if we can get this.
Actually since β.neg ∈ B and we have untl(β.neg, γ) ∈ A for any γ ∈ C (by burgessR3), we can use BX5 + BX14 + ... 
No wait. If β.neg ∈ B, then burgessR3 gives untl(β.neg, γ₀) ∈ A for any γ₀ ∈ C. BX10 gives F(γ₀) ∈ A. That's not F(β.neg). 
But I think the cleanest approach is to just restructure the inconsistent case to use the SAME burgess_zeta_consistent call. Let me also note that _h_β_not_B would be false here (we know β ∉ B is true because if β ∈ B AND β.neg ∈ B, then β ∧ β.neg ∈ B, contradiction with DCS consistency). So β ∉ B holds.
Actually wait, is β ∉ B guaranteed? We have _h_beta_neg_in_B : β.neg ∈ B. If β ∈ B, then β ∧ β.neg ∈ B (DCS closure), and ⊢ (β ∧ β.neg) → ⊥, so ⊥ ∈ B, contradicting DCS consistency. So β ∉ B does hold.
For h_F_beta_neg, we need F(β.neg) ∈ A. But the function doesn't actually use it! So I'll just restructure burgess_zeta_consistent to not take the unused arguments, or pass a trivial proof.
Actually the best approach: simply remove h_F_beta_neg and _h_β_not_B from burgess_zeta_consistent's parameter list since they're unused. This simplifies things. Then we just need to prove ¬untl(b∧β, γ_hat) ∈ A in the inconsistent case.
Let me now write the implementation:
1. First, modify burgess_zeta_consistent to remove unused params
2. Then implement the fix in burgess_D0_finite_subset_consistent_incons
Wait, I also need to handle the unused params in the caller (consistent case at line 1684-1686). Let me check if modifying the Sigma type is really needed or if there's a simpler approach.
Actually, looking at this more carefully, the simplest fix is:
1. In the inconsistent case, prove ¬untl(b∧β, γ_hat) ∈ A 
2. Use burgess_zeta_consistent with whatever h_F_beta_neg is available (or remove it from the function)
3. Remove the iterated_enrichment + direct proof attempt + sorries
For (1), I need to prove: if β.neg ∈ B and b is a conjunction that includes β.neg, then ¬untl(b∧β, γ_hat) ∈ A.
I'll add a helper lemma before using it. Let me also check that F(⊥) actually contradicts G(⊤). In MCS, G(⊤) is always present (theorem). F(⊥) = ¬G(¬⊥) = ¬G(⊤) = G(⊤).neg. So F(⊥) ∈ A implies G(⊤).neg ∈ A, which contradicts G(⊤) ∈ A in MCS.
But I need to prove this at the derivation level, not just reasoning about MCS memberships. Let me think about what lemmas I need...
Actually, looking at the existing proof structure, there's already consistent_of_F_mem and inconsistent_singleton_false at the end. So I don't need to derive ⊥ from F(⊥). I just need to prove ¬untl(b∧β, γ_hat) ∈ A using the MCS completeness property.
Let me write the proof:
have h_b_to_βneg : DerivationTree [] (b.imp β.neg) := ...
-- then (b∧β) → (β.neg ∧ β) → ⊥
have h_contra_impl : DerivationTree [] ((Formula.and b β).imp Formula.bot) := ...
-- left_mono for Until: (b∧β) U γ_hat → ⊥ U γ_hat 
Hmm, actually I don't need to go through ⊥ U γ_hat. I can just use the MCS negation_complete property:
have h_neg_until_b : (Formula.untl (Formula.and b β) γ_hat).neg ∈ A := by
    rcases SetMaximalConsistent.negation_complete h_mcs_A
      (Formula.untl (Formula.and b β) γ_hat) with h | h
    · -- h: untl(b∧β, γ_hat) ∈ A → derive contradiction using b → β.neg
      ...
    · exact h
Then in the case where h holds (untl is in A), I derive a contradiction:
- ⊢ b → β.neg (since β₀ = β.neg ∈ b_list)
- ⊢ (b∧β) → ⊥
- ⊢ untl(b∧β, γ_hat) → untl(⊥, γ_hat) (left_mono)
- So untl(⊥, γ_hat) ∈ A
- But untl(⊥, γ_hat) → F(⊥) (BX10)
- So F(⊥) ∈ A
- F(⊥) = some_future ⊥ = ¬G(¬⊥) = ¬G(⊤) = G(⊤).neg
- But G(⊤) ∈ A by theorem_in_mcs (identity ⊥ is a theorem, and G(⊤) follows by temporal necessitation)
- Contradiction
This is the proof. Let me now write it.
Let me code this up. I need:
1. h_b_to_βneg : DerivationTree [] (b.imp β.neg) from list_conj_implies_elem
2. h_bβ_to_bot : DerivationTree [] ((Formula.and b β).imp Formula.bot) from h_b_to_βneg
3. h_left_mono : DerivationTree [] (untl(b∧β, γ_hat).imp untl(⊥, γ_hat)) via untl_left_mono_deriv
4. Apply to get untl(⊥, γ_hat) ∈ A 
5. BX10: F(⊥) ∈ A
6. G(⊤) ∈ A vs F(⊥) ∈ A contradiction
Let me verify that F(⊥).neg = G(⊤). In our system:
- F(φ) = some_future φ = ¬G(¬φ) = (G(φ.neg)).neg
- F(⊥) = (G(⊥.neg)).neg = (G(⊤)).neg since ⊥.neg = ¬⊥ = ⊤
And G(⊤) is a theorem, hence in MCS A. So F(⊥) = G(⊤).neg ∈ A contradicts G(⊤) ∈ A in MCS.
Let me write the proof now.
