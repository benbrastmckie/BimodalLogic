import Mathlib.Combinatorics.SimpleGraph.Acyclic

/-! Probe: oriented-forest core lemmas over a bare one-step relation. -/

namespace Probe870

variable {W : Type}

/-- Repo's `FormalSystem.Semantics.iter`, right-appending. -/
def iter (E : W → W → Prop) : ℕ → W → W → Prop
  | 0 => Eq
  | n + 1 => fun w u => ∃ v, iter E n w v ∧ E v u

@[simp] theorem iter_zero (E : W → W → Prop) (w u : W) : iter E 0 w u ↔ w = u := Iff.rfl
@[simp] theorem iter_succ (E : W → W → Prop) (n : ℕ) (w u : W) :
    iter E (n + 1) w u ↔ ∃ v, iter E n w v ∧ E v u := Iff.rfl

theorem iter_add (E : W → W → Prop) (m n : ℕ) (w u : W) :
    iter E (m + n) w u ↔ ∃ v, iter E m w v ∧ iter E n v u := by
  induction n generalizing u with
  | zero => simp
  | succ n ih =>
    constructor
    · rintro ⟨v, hv, hE⟩
      obtain ⟨c, hc, hcv⟩ := (ih v).mp hv
      exact ⟨c, hc, v, hcv, hE⟩
    · rintro ⟨c, hc, v, hcv, hE⟩
      exact ⟨v, (ih v).mpr ⟨c, hc, hcv⟩, hE⟩

/-- The underlying undirected multigraph of `E` is a forest. -/
structure IsOrientedForest (E : W → W → Prop) : Prop where
  loopFree : ∀ u, ¬ E u u
  oppFree : ∀ u v, E u v → ¬ E v u
  acyclic : (SimpleGraph.fromRel E).IsAcyclic

open SimpleGraph

theorem adj_of_step {E : W → W → Prop} (hF : IsOrientedForest E) {u v : W} (h : E u v) :
    (SimpleGraph.fromRel E).Adj u v :=
  ⟨fun h' => hF.loopFree u (h' ▸ h), Or.inl h⟩

/-- The step out of the endpoint of a directed path cannot re-enter the path. -/
theorem not_mem_support_of_step {E : W → W → Prop} (hF : IsOrientedForest E)
    {a w z : W} {p : (SimpleGraph.fromRel E).Walk a w} (hp : p.IsPath)
    (hpen : 0 < p.length → E p.penultimate w) (hEwz : E w z) : z ∉ p.support := by
  intro hz
  have hzp : z = p.penultimate :=
    hF.acyclic.eq_penultimate_of_adj_end hp (adj_of_step hF hEwz) hz
  rcases Nat.eq_zero_or_pos p.length with hn | hn
  · have hav : a = w := Walk.eq_of_length_eq_zero hn
    have hza : z = a := by rw [hzp]; simp [Walk.penultimate, hn]
    rw [← hav, hza] at hEwz
    exact hF.loopFree a hEwz
  · exact hF.oppFree w z hEwz (hzp ▸ hpen hn)

/-- **(C1)** A directed `E`-walk of length `n` is an undirected path, and its penultimate
vertex carries the last `E`-step. -/
theorem exists_isPath_of_iter {E : W → W → Prop} (hF : IsOrientedForest E) :
    ∀ (n : ℕ) (a z : W), iter E n a z →
      ∃ p : (SimpleGraph.fromRel E).Walk a z,
        p.IsPath ∧ p.length = n ∧ (0 < n → E p.penultimate z) ∧
        (∀ d ∈ p.support, ∃ i, i ≤ n ∧ iter E i a d ∧ iter E (n - i) d z) := by
  intro n
  induction n with
  | zero =>
    intro a z h; subst h
    exact ⟨Walk.nil, Walk.IsPath.nil, rfl, by omega, by
      intro d hd; simp at hd; exact ⟨0, by omega, hd.symm, hd⟩⟩
  | succ n ih =>
    rintro a z ⟨v, hv, hEvz⟩
    obtain ⟨p, hp, hlen, hpen, hbtw⟩ := ih a v hv
    have hadj := adj_of_step hF hEvz
    have hz : z ∉ p.support :=
      not_mem_support_of_step hF hp (by rw [hlen]; exact hpen) hEvz
    refine ⟨p.concat hadj, hp.concat hz hadj, ?_, ?_, ?_⟩
    · rw [Walk.length_concat, hlen]
    · intro _; rw [Walk.penultimate_concat]; exact hEvz
    · intro d hd
      have hd : d ∈ p.support ∨ d = z := by
        simpa [Walk.support_concat, List.concat_eq_append] using hd
      rcases hd with hd | hd
      · obtain ⟨i, hi, h1, h2⟩ := hbtw d hd
        refine ⟨i, by omega, h1, ?_⟩
        have : n + 1 - i = (n - i) + 1 := by omega
        rw [this]
        exact ⟨v, h2, hEvz⟩
      · exact ⟨n + 1, by omega, hd ▸ ⟨v, hv, hEvz⟩, by simpa using hd⟩

/-- The chosen path realizing a directed walk, with its length and last-step data. -/
noncomputable def pathOf {E : W → W → Prop} (hF : IsOrientedForest E) {n : ℕ} {a z : W}
    (h : iter E n a z) : (SimpleGraph.fromRel E).Walk a z :=
  (exists_isPath_of_iter hF n a z h).choose

theorem pathOf_spec {E : W → W → Prop} (hF : IsOrientedForest E) {n : ℕ} {a z : W}
    (h : iter E n a z) :
    (pathOf hF h).IsPath ∧ (pathOf hF h).length = n ∧
      (0 < n → E (pathOf hF h).penultimate z) ∧
      (∀ d ∈ (pathOf hF h).support, ∃ i, i ≤ n ∧ iter E i a d ∧ iter E (n - i) d z) :=
  (exists_isPath_of_iter hF n a z h).choose_spec

/-- Paths between two vertices of a forest agree. -/
theorem walk_unique {E : W → W → Prop} (hF : IsOrientedForest E) {a z : W}
    {p q : (SimpleGraph.fromRel E).Walk a z} (hp : p.IsPath) (hq : q.IsPath) : p = q :=
  Subtype.mk.inj ((hF.acyclic.subsingleton_path a z).elim ⟨p, hp⟩ ⟨q, hq⟩)

/-- **(UPL)** Unique path length: a directed walk's length is determined by its endpoints. -/
theorem iter_length_unique {E : W → W → Prop} (hF : IsOrientedForest E) {n m : ℕ} {a z : W}
    (hn : iter E n a z) (hm : iter E m a z) : n = m := by
  obtain ⟨hp, hplen, _⟩ := pathOf_spec hF hn
  obtain ⟨hq, hqlen, _⟩ := pathOf_spec hF hm
  rw [← hplen, ← hqlen, walk_unique hF hp hq]

/-- No directed cycles. -/
theorem not_iter_self {E : W → W → Prop} (hF : IsOrientedForest E) {s : ℕ} (hs : 0 < s)
    (d : W) : ¬ iter E s d d := fun h => by
  obtain ⟨hp, hlen, _⟩ := pathOf_spec hF h
  have := Walk.length_eq_zero_iff.mpr (Walk.isPath_iff_nil.mp hp)
  omega

/-- **(PEN)** The penultimate vertex of a directed walk of fixed length is determined. -/
theorem pen_unique {E : W → W → Prop} (hF : IsOrientedForest E) {n : ℕ} {a z w w' : W}
    (hw : iter E n a w) (hEw : E w z) (hw' : iter E n a w') (hEw' : E w' z) : w = w' := by
  obtain ⟨hp, hplen, hppen, _⟩ := pathOf_spec hF hw
  obtain ⟨hq, hqlen, hqpen, _⟩ := pathOf_spec hF hw'
  have hadj := adj_of_step hF hEw
  have hadj' := adj_of_step hF hEw'
  have hzp : z ∉ (pathOf hF hw).support :=
    not_mem_support_of_step hF hp (by rw [hplen]; exact hppen) hEw
  have hzq : z ∉ (pathOf hF hw').support :=
    not_mem_support_of_step hF hq (by rw [hqlen]; exact hqpen) hEw'
  have heq := walk_unique hF (hp.concat hzp hadj) (hq.concat hzq hadj')
  have := congrArg Walk.penultimate heq
  rwa [Walk.penultimate_concat, Walk.penultimate_concat] at this

/-- **(UIV)** The intermediate vertex of a directed walk at a fixed distance is determined.
This is the segment-subsingleton fact (report 03 section 1.2 steps 1 and 3). -/
theorem mid_unique {E : W → W → Prop} (hF : IsOrientedForest E) :
    ∀ (j k : ℕ) (a z v v' : W), iter E k a v → iter E j v z → iter E k a v' → iter E j v' z →
      v = v' := by
  intro j
  induction j with
  | zero => intro _ _ _ _ _ _ h1 _ h2; exact h1.trans h2.symm
  | succ j ih =>
    rintro k a z v v' hav ⟨w, hvw, hEwz⟩ hav' ⟨w', hvw', hEw'z⟩
    have haw : iter E (k + j) a w := (iter_add E k j a w).mpr ⟨v, hav, hvw⟩
    have haw' : iter E (k + j) a w' := (iter_add E k j a w').mpr ⟨v', hav', hvw'⟩
    have : w = w' := pen_unique hF haw hEwz haw' hEw'z
    subst this
    exact ih k a w v v' hav hvw hav' hvw'

/-- **(MERGE)** Two directed walks into a common target factor through a last divergence
point: the paper's merge vertex `m` of report 03 section 1.2 step 4. -/
theorem exists_merge {E : W → W → Prop} :
    ∀ (n m : ℕ) (a b z : W), iter E n a z → iter E m b z →
      ∃ (c : W) (k l j : ℕ), iter E k a c ∧ iter E l b c ∧ iter E j c z ∧
        k + j = n ∧ l + j = m ∧
        (k = 0 ∨ l = 0 ∨ ∃ u u', u ≠ u' ∧ E u c ∧ E u' c ∧
          iter E (k - 1) a u ∧ iter E (l - 1) b u') := by
  intro n
  induction n with
  | zero =>
    intro m a b z hn hm
    exact ⟨z, 0, m, 0, hn, hm, rfl, by omega, by omega, Or.inl rfl⟩
  | succ n ih =>
    intro m a b z hn hm
    match m, hm with
    | 0, hm => exact ⟨z, n + 1, 0, 0, hn, hm, rfl, by omega, by omega, Or.inr (Or.inl rfl)⟩
    | (m + 1), ⟨w', hbw', hEw'z⟩ =>
      obtain ⟨w, haw, hEwz⟩ := hn
      by_cases hww : w = w'
      · subst hww
        obtain ⟨c, k, l, j, h1, h2, h3, h4, h5, h6⟩ := ih m a b w haw hbw'
        exact ⟨c, k, l, j + 1, h1, h2, ⟨w, h3, hEwz⟩, by omega, by omega, h6⟩
      · exact ⟨z, n + 1, m + 1, 0, ⟨w, haw, hEwz⟩, ⟨w', hbw', hEw'z⟩, rfl, by omega, by omega,
          Or.inr (Or.inr ⟨w, w', hww, hEwz, hEw'z, by simpa using haw, by simpa using hbw'⟩)⟩

/-- **(DISJ)** At a *divergent* meet `c` of `a` and `b` (the two last steps into `c` come from
distinct vertices), the two approach walks share no vertex but `c`. This is the input to the
step-4 independence claim, and it consumes only `pen_unique`/`iter_length_unique` — i.e. only
directed-path uniqueness. -/
theorem meet_approach_disjoint {E : W → W → Prop} (hF : IsOrientedForest E)
    {a b c d u u' : W} {kk ll i j i' j' : ℕ}
    (hu : iter E kk a u) (hEu : E u c) (hu' : iter E ll b u') (hEu' : E u' c) (hne : u ≠ u')
    (h1 : iter E i a d) (h2 : iter E j d c) (hk : i + j = kk + 1)
    (h3 : iter E i' b d) (h4 : iter E j' d c) (hl : i' + j' = ll + 1) : d = c := by
  have hjj : j = j' := iter_length_unique hF h2 h4
  rcases Nat.eq_zero_or_pos j with hj0 | hj0
  · subst hj0; exact h2
  · exfalso
    obtain ⟨jm, hjm⟩ : ∃ jm, j = jm + 1 := ⟨j - 1, by omega⟩
    subst hjm
    obtain ⟨w, hdw, hEwc⟩ := h2
    have hik : i + jm = kk := by omega
    have hil : i' + jm = ll := by omega
    have haw : iter E kk a w := hik ▸ (iter_add E i jm a w).mpr ⟨d, h1, hdw⟩
    have hbw : iter E ll b w := hil ▸ (iter_add E i' jm b w).mpr ⟨d, h3, hdw⟩
    exact hne ((pen_unique hF haw hEwc hu hEu).symm.trans
      (pen_unique hF hbw hEwc hu' hEu'))

end Probe870

-- Axiom profile of the verified layer (informational).
#print axioms Probe870.exists_isPath_of_iter
#print axioms Probe870.iter_length_unique
#print axioms Probe870.mid_unique
#print axioms Probe870.exists_merge
#print axioms Probe870.meet_approach_disjoint
