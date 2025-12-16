#!/usr/bin/env python3
"""
Fix Truth.lean compilation errors after generalization.

Issues:
1. Replace omega tactics with group lemmas
2. Fix is_valid definition to use polymorphic type
3. Update theorems in TemporalDuality namespace to use Frame parameter
"""

import re

def read_file(path):
    with open(path, 'r') as f:
        return f.read()

def write_file(path, content):
    with open(path, 'w') as f:
        f.write(content)

def fix_omega_tactics(content):
    """Replace omega tactics with proper group lemmas."""
    replacements = [
        # Simple add_sub_cancel patterns
        (r'have h_eq : x \+ \(y - x\) = y := by omega',
         'have h_eq : x + (y - x) = y := add_sub_cancel x y'),
        (r'have h : x \+ \(y - x\) = y := by omega',
         'have h : x + (y - x) = y := add_sub_cancel x y'),

        # sub_add_cancel patterns
        (r'have : \(s - \(y - x\)\) \+ \(y - x\) = s := by omega',
         'have : (s - (y - x)) + (y - x) = s := sub_add_cancel s (y - x)'),

        # sub_sub_self patterns
        (r'have h_shift_eq : s - \(s - \(y - x\)\) = y - x := by omega',
         'have h_shift_eq : s - (s - (y - x)) = y - x := by rw [sub_sub_self]'),

        # add_sub_cancel_left patterns
        (r'have h_shift_eq : \(s\' \+ \(y - x\)\) - s\' = y - x := by omega',
         'have h_shift_eq : (s\' + (y - x)) - s\' = y - x := by rw [add_sub_cancel_left]'),

        # add_comm + sub_add_cancel for y + (x - y) = x
        (r'have h_eq : y \+ \(x - y\) = x := by omega',
         'have h_eq : y + (x - y) = x := by rw [add_comm, sub_add_cancel]'),

        # Double cancel: x + (y - x) + (x - y) = x
        (r'have h_eq : x \+ \(y - x\) \+ \(x - y\) = x := by omega',
         'have h_eq : x + (y - x) + (x - y) = x := by rw [add_sub_cancel, add_sub_cancel]'),

        # neg_sub
        (r'have h_cancel : y - x = -\(x - y\) := by omega',
         'have h_cancel : y - x = -(x - y) := by rw [neg_sub]'),

        # Order comparisons
        (r'have h_s_shifted_lt_x : s - \(y - x\) < x := by omega',
         '''have h_s_shifted_lt_x : s - (y - x) < x := by
        have h1 : s < y := h_s_lt_y
        have h2 : s - (y - x) < y - (y - x) := sub_lt_sub_right h1 (y - x)
        rw [sub_sub_cancel] at h2
        exact h2'''),

        (r'have h_s_lt_y : s\' \+ \(y - x\) < y := by omega',
         '''have h_s_lt_y : s' + (y - x) < y := by
        have h1 : s' < x := h_s'_lt_x
        have h2 : s' + (y - x) < x + (y - x) := add_lt_add_right h1 (y - x)
        rw [add_sub_cancel] at h2
        exact h2'''),

        (r'have h_x_lt_s_shifted : x < s - \(y - x\) := by omega',
         '''have h_x_lt_s_shifted : x < s - (y - x) := by
        have h1 : y < s := h_y_lt_s
        have h2 : y - (y - x) < s - (y - x) := sub_lt_sub_right h1 (y - x)
        rw [sub_sub_cancel] at h2
        exact h2'''),

        (r'have h_y_lt_s : y < s\' \+ \(y - x\) := by omega',
         '''have h_y_lt_s : y < s' + (y - x) := by
        have h1 : x < s' := h_x_lt_s'
        have h2 : x + (y - x) < s' + (y - x) := add_lt_add_right h1 (y - x)
        rw [add_sub_cancel] at h2
        exact h2'''),

        # lt_trans
        (r'have h_u_lt_t : u < t := by omega',
         'have h_u_lt_t : u < t := lt_trans h_u_lt_r h_r_lt_t'),

        # Case split on t < u
        (r'have h_gt : t < u := by omega',
         '''have h_gt : t < u := by
        cases (lt_or_eq_of_le (le_of_not_lt h_ut)) with
        | inl h => exact h
        | inr h => exact absurd h h_eq'''),

        # add_sub_cancel t s
        (r'have h_eq : t \+ \(s - t\) = s := by omega',
         'have h_eq : t + (s - t) = s := add_sub_cancel t s'),
    ]

    for pattern, replacement in replacements:
        content = re.sub(pattern, replacement, content)

    return content

def fix_is_valid_definition(content):
    """Update is_valid definition to use polymorphic type and Frame parameter."""
    old_def = r'''private def is_valid \(φ : Formula\) : Prop :=
  ∀ \(F : TaskFrame\) \(M : TaskModel F\) \(τ : WorldHistory F\) \(t : Int\) \(ht : τ\.domain t\),
    truth_at M τ t ht φ'''

    new_def = r'''private def is_valid (φ : Formula) : Prop :=
  ∀ {U : Type*} [LinearOrderedAddCommGroup U] (Frame : TaskFrame U) (M : TaskModel Frame) (τ : WorldHistory Frame) (t : U) (ht : τ.domain t),
    truth_at M τ t ht φ'''

    content = re.sub(old_def, new_def, content)
    return content

def fix_temporal_duality_theorems(content):
    """Fix theorems in TemporalDuality namespace to use Frame and T."""

    # Fix valid_at_triple
    content = re.sub(
        r'theorem valid_at_triple \{φ : Formula\} \(h_valid : is_valid φ\) \(F : TaskFrame\) \(M : TaskModel F\)\n    \(τ : WorldHistory F\) \(t : Int\) \(ht : τ\.domain t\) :',
        r'theorem valid_at_triple {φ : Formula} (h_valid : is_valid φ) (Frame : TaskFrame T) (M : TaskModel Frame)\n    (τ : WorldHistory Frame) (t : T) (ht : τ.domain t) :',
        content
    )
    content = re.sub(
        r'truth_at M τ t ht φ := h_valid F M τ t ht',
        r'truth_at M τ t ht φ := h_valid Frame M τ t ht',
        content
    )

    # Fix truth_swap_of_valid_at_triple signature
    content = re.sub(
        r'theorem truth_swap_of_valid_at_triple \(φ : Formula\) \(F : TaskFrame\) \(M : TaskModel F\)\n    \(τ : WorldHistory F\) \(t : Int\) \(ht : τ\.domain t\) :',
        r'theorem truth_swap_of_valid_at_triple (φ : Formula) (Frame : TaskFrame T) (M : TaskModel Frame)\n    (τ : WorldHistory Frame) (t : T) (ht : τ.domain t) :',
        content
    )

    # Fix induction generalizing
    content = re.sub(
        r'induction φ generalizing F M τ t ht with',
        r'induction φ generalizing Frame M τ t ht with',
        content
    )

    # Fix h_valid calls in atom and bot cases (within truth_swap_of_valid_at_triple)
    # Need to be careful to only match within this function
    # Match patterns like: exact h_valid (F : TaskFrame) M τ t ht
    content = re.sub(
        r'exact h_valid \(F : TaskFrame\) M τ t ht',
        r'exact h_valid (Frame : TaskFrame T) M τ t ht',
        content
    )

    # Fix ih calls
    content = re.sub(
        r'exact ih \(F : TaskFrame\) M',
        r'exact ih (Frame : TaskFrame T) M',
        content
    )

    # Fix intro F' M' patterns in nested validity proofs
    content = re.sub(
        r'intro F\' M\' τ\' (.+) hr',
        r'intro Frame\' M\' τ\' \1 hr',
        content
    )

    # Fix all "intro F M τ t ht" in TemporalDuality theorems
    # This is tricky - need to match only after "namespace TemporalDuality"
    # For now, replace all in the file (safer than trying to parse namespaces)
    lines = content.split('\n')
    in_temporal_duality = False
    result = []

    for i, line in enumerate(lines):
        if 'namespace TemporalDuality' in line:
            in_temporal_duality = True
        elif in_temporal_duality and line.startswith('end ProofChecker.Semantics'):
            in_temporal_duality = False

        if in_temporal_duality:
            # Replace intro F M τ t ht with intro Frame M τ t ht
            line = re.sub(r'intro F M τ t ht', r'intro Frame M τ t ht', line)
            # Replace exact h F M with exact h Frame M
            line = re.sub(r'exact h F M', r'exact h Frame M', line)
            # Fix comments mentioning (F, M, τ, t, ht)
            # but keep (F, M, τ) in type expressions

        result.append(line)

    content = '\n'.join(result)
    return content

def main():
    path = 'ProofChecker/Semantics/Truth.lean'

    print("Reading file...")
    content = read_file(path)

    print("Fixing omega tactics...")
    content = fix_omega_tactics(content)

    print("Fixing is_valid definition...")
    content = fix_is_valid_definition(content)

    print("Fixing TemporalDuality theorems...")
    content = fix_temporal_duality_theorems(content)

    print("Writing file...")
    write_file(path, content)

    print("Done!")

if __name__ == '__main__':
    main()
