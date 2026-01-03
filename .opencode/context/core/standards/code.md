<!-- Context: standards/code | Priority: critical | Version: 2.0 | Updated: 2025-01-21 -->
# Code Standards

## Quick Reference

**Core Philosophy**: Modular, Functional, Maintainable
**Golden Rule**: If you can't easily test it, refactor it

**Critical Patterns** (use these):
- [PASS] Pure functions (same input = same output, no side effects)
- [PASS] Immutability (create new data, don't modify)
- [PASS] Composition (build complex from simple)
- [PASS] Small functions (< 50 lines)
- [PASS] Explicit dependencies (dependency injection)

**Anti-Patterns** (avoid these):
- [FAIL] Mutation, side effects, deep nesting
- [FAIL] God modules, global state, large functions

---

## Core Philosophy

**Modular**: Everything is a component - small, focused, reusable
**Functional**: Pure functions, immutability, composition over inheritance
**Maintainable**: Self-documenting, testable, predictable

## Principles

### Modular Design
- Single responsibility per module
- Clear interfaces (explicit inputs/outputs)
- Independent and composable
- < 100 lines per component (ideally < 50)

### Functional Approach
- **Pure functions**: Same input = same output, no side effects
- **Immutability**: Create new data, don't modify existing
- **Composition**: Build complex from simple functions
- **Declarative**: Describe what, not how

### Component Structure
```
component/
├── index.js      # Public interface
├── core.js       # Core logic (pure functions)
├── utils.js      # Helpers
└── tests/        # Tests
```

## Patterns

### Pure Functions
```javascript
// [PASS] Pure
const add = (a, b) => a + b;
const formatUser = (user) => ({ ...user, fullName: `${user.firstName} ${user.lastName}` });

// [FAIL] Impure (side effects)
let total = 0;
const addToTotal = (value) => { total += value; return total; };
```

### Immutability
```javascript
// [PASS] Immutable
const addItem = (items, item) => [...items, item];
const updateUser = (user, changes) => ({ ...user, ...changes });

// [FAIL] Mutable
const addItem = (items, item) => { items.push(item); return items; };
```

### Composition
```javascript
// [PASS] Compose small functions
const processUser = pipe(validateUser, enrichUserData, saveUser);
const isValidEmail = (email) => validateEmail(normalizeEmail(email));

// [FAIL] Deep inheritance
class ExtendedUserManagerWithValidation extends UserManager { }
```

### Declarative
```javascript
// [PASS] Declarative
const activeUsers = users.filter(u => u.isActive).map(u => u.name);

// [FAIL] Imperative
const names = [];
for (let i = 0; i < users.length; i++) {
  if (users[i].isActive) names.push(users[i].name);
}
```

## Naming

- **Files**: lowercase-with-dashes.js
- **Functions**: verbPhrases (getUser, validateEmail)
- **Predicates**: isValid, hasPermission, canAccess
- **Variables**: descriptive (userCount not uc), const by default
- **Constants**: UPPER_SNAKE_CASE

## Error Handling

```javascript
// [PASS] Explicit error handling
function parseJSON(text) {
  try {
    return { success: true, data: JSON.parse(text) };
  } catch (error) {
    return { success: false, error: error.message };
  }
}

// [PASS] Validate at boundaries
function createUser(userData) {
  const validation = validateUserData(userData);
  if (!validation.isValid) {
    return { success: false, errors: validation.errors };
  }
  return { success: true, user: saveUser(userData) };
}
```

## Dependency Injection

```javascript
// [PASS] Dependencies explicit
function createUserService(database, logger) {
  return {
    createUser: (userData) => {
      logger.info('Creating user');
      return database.insert('users', userData);
    }
  };
}

// [FAIL] Hidden dependencies
import db from './database.js';
function createUser(userData) { return db.insert('users', userData); }
```

## Anti-Patterns

[FAIL] **Mutation**: Modifying data in place
[FAIL] **Side effects**: console.log, API calls in pure functions
[FAIL] **Deep nesting**: Use early returns instead
[FAIL] **God modules**: Split into focused modules
[FAIL] **Global state**: Pass dependencies explicitly
[FAIL] **Large functions**: Keep < 50 lines

## Best Practices

[PASS] Pure functions whenever possible
[PASS] Immutable data structures
[PASS] Small, focused functions (< 50 lines)
[PASS] Compose small functions into larger ones
[PASS] Explicit dependencies (dependency injection)
[PASS] Validate at boundaries
[PASS] Self-documenting code
[PASS] Test in isolation

**Golden Rule**: If you can't easily test it, refactor it.
