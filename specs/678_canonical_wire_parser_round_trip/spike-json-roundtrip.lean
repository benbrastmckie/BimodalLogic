set_option autoImplicit false

mutual
inductive J where
  | str (s : List Char)
  | arr (xs : JS)
inductive JS where
  | nil
  | cons (x : J) (xs : JS)
end

mutual
def prJ : J → List Char
  | .str s => '"' :: (s ++ ['"'])
  | .arr xs => '[' :: prJS xs
def prJS : JS → List Char
  | .nil => [']']
  | .cons x .nil => prJ x ++ [']']
  | .cons x xs => prJ x ++ ',' :: prJS xs
end

def pStr : List Char → Except String (List Char × List Char)
  | [] => .error "unterminated string"
  | '"' :: cs => .ok ([], cs)
  | c :: cs =>
    match pStr cs with
    | .ok (s, r) => .ok (c :: s, r)
    | .error e => .error e

mutual
def pJ : Nat → List Char → Except String (J × List Char)
  | 0, _ => .error "out of fuel"
  | _+1, '"' :: cs =>
    match pStr cs with
    | .ok (s, r) => .ok (.str s, r)
    | .error e => .error e
  | _+1, '[' :: ']' :: cs => .ok (.arr .nil, cs)
  | f+1, '[' :: cs =>
    match pElems f cs with
    | .ok (xs, r) => .ok (.arr xs, r)
    | .error e => .error e
  | _+1, _ => .error "expected value"
def pElems : Nat → List Char → Except String (JS × List Char)
  | 0, _ => .error "out of fuel"
  | f+1, cs =>
    match pJ f cs with
    | .error e => .error e
    | .ok (x, ',' :: cs) =>
      match pElems f cs with
      | .ok (xs, r) => .ok (.cons x xs, r)
      | .error e => .error e
    | .ok (x, ']' :: cs) => .ok (.cons x .nil, cs)
    | .ok (_, _) => .error "expected , or ] in array"
end

mutual
def szJ : J → Nat
  | .str _ => 1
  | .arr xs => szJS xs + 1
def szJS : JS → Nat
  | .nil => 1
  | .cons x xs => szJ x + szJS xs + 1
end

mutual
def okJ : J → Prop
  | .str s => '"' ∉ s
  | .arr xs => okJS xs
def okJS : JS → Prop
  | .nil => True
  | .cons x xs => okJ x ∧ okJS xs
end

theorem pStr_append (s rest : List Char) (h : '"' ∉ s) :
    pStr (s ++ '"' :: rest) = .ok (s, rest) := by
  induction s with
  | nil => simp [pStr]
  | cons c cs ih =>
    have hc : c ≠ '"' := by intro h'; exact h (by simp [h'])
    have hcs : '"' ∉ cs := fun h' => h (by simp [h'])
    simp [pStr, ih hcs]

theorem prJS_cons_head (x : J) (xs : JS) (t : List Char) :
    ∃ c r, c ≠ ']' ∧ prJS (.cons x xs) ++ t = c :: r := by
  cases xs with
  | nil =>
    cases x with
    | str s => exact ⟨'"', s ++ '"' :: ([']'] ++ t), by simp, by simp [prJS, prJ]⟩
    | arr ys => exact ⟨'[', prJS ys ++ ([']'] ++ t), by simp, by simp [prJS, prJ]⟩
  | cons z zs =>
    cases x with
    | str s => exact ⟨'"', s ++ '"' :: (',' :: prJS (.cons z zs) ++ t), by simp, by simp [prJS, prJ]⟩
    | arr ys => exact ⟨'[', prJS ys ++ (',' :: prJS (.cons z zs) ++ t), by simp, by simp [prJS, prJ]⟩

theorem roundtrip : ∀ f : Nat,
    (∀ (j : J) (rest : List Char), okJ j → szJ j ≤ f → pJ f (prJ j ++ rest) = .ok (j, rest)) ∧
    (∀ (x : J) (xs : JS) (rest : List Char), okJS (.cons x xs) → szJS (.cons x xs) ≤ f →
      pElems f (prJS (.cons x xs) ++ rest) = .ok (.cons x xs, rest)) := by
  intro f
  induction f with
  | zero =>
    refine ⟨?_, ?_⟩
    · intro j _ _ h; cases j <;> simp [szJ] at h
    · intro x xs _ _ h; simp [szJS] at h
  | succ f ih =>
    obtain ⟨ihJ, ihS⟩ := ih
    refine ⟨?_, ?_⟩
    · intro j rest hok hsz
      cases j with
      | str s => simp [prJ, pJ, pStr_append s rest hok]
      | arr xs =>
        cases xs with
        | nil => simp [prJ, prJS, pJ]
        | cons y ys =>
          have hsz' : szJS (JS.cons y ys) ≤ f := by simp [szJ] at hsz; omega
          obtain ⟨c, r, hc, hcr⟩ := prJS_cons_head y ys rest
          show pJ (f+1) ('[' :: (prJS (.cons y ys) ++ rest)) = _
          rw [hcr]
          rw [pJ]
          · rw [← hcr, ihS y ys rest hok hsz']
          · intro cs' hcs'; cases hcs'; exact hc rfl
    · intro x xs rest hok hsz
      have hx : szJ x ≤ f := by simp only [szJS] at hsz; omega
      cases xs with
      | nil =>
        simp only [prJS, List.append_assoc]
        rw [pElems]
        rw [show ([']'] ++ rest) = ']' :: rest by simp, ihJ x (']' :: rest) hok.1 hx]
        rfl
      | cons z zs =>
        have hr : szJS (JS.cons z zs) ≤ f := by
          simp only [szJS] at hsz ⊢; omega
        simp only [prJS, List.append_assoc]
        rw [pElems]
        rw [show (',' :: prJS (JS.cons z zs) ++ rest) = ',' :: (prJS (JS.cons z zs) ++ rest) by simp,
          ihJ x _ hok.1 hx]
        show (match pElems f (prJS (JS.cons z zs) ++ rest) with
          | .ok (xs, r) => Except.ok (JS.cons x xs, r)
          | .error e => .error e) = _
        rw [ihS z zs rest hok.2 hr]

#print axioms roundtrip
#print axioms pStr_append
-- sanity: the parser is a total `def` (no `partial`), so it evaluates on malformed input too
#eval pJ 50 "[\"a\",[\"b\"]]".toList |>.isOk
#eval (pJ 50 "[\"a\",".toList).isOk
#eval (pJ 2 "[\"a\",[\"b\"]]".toList).isOk   -- insufficient fuel: protocol error, not a wrong value
