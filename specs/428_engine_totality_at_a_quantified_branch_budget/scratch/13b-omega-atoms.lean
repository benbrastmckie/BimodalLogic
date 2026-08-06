example (a b c : Nat) (h : a * b ≤ c) : a * b ≤ c + 1 := by omega

example (a b c d : Nat) (h : a * b ≤ c * d) (h2 : c * d + 3 ≤ 9) : a * b ≤ 6 := by omega

example (k T d m A : Nat) (hA : A = 2 * (T * T) + 2) (hd : 1 ≤ d)
    (h1 : k * (T * T + 1) + d * (T * T + 1) + T * T ≤ 100)
    (h2 : A * d = 2 * (T * T) * d + 2 * d) : True := by trivial
