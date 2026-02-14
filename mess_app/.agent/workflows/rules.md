---
description: Naming Conventions and Golden Production Rules
---

# Naming Convention Rules

## Files
- Always use `snake_case.dart` for file names.

## Classes
- Always use `PascalCase` for class names.

## Variables
- Always use `camelCase` for variables and function names.

## Folders
- Always use `feature_name/` format for folders.

---

# Golden Production Rules

1. **Separation of Concerns**: Never mix UI and API logic.
2. **API Access**: Never call API inside widgets directly.
3. **Architecture**: Use the **Repository Pattern**.
4. **Isolation**: Keep features isolated.
5. **Reusable Logic**: Use the `shared/` folder only for components that are truly reusable across features.
6. **Strings**: Use constants for all strings.
7. **Theming**: Implement a centralized theme.
8. **Responsiveness**: Use a global responsive system.
9. **Error Handling**: Use centralized error handling.
10. **Environment**: Use environment configurations for development and production (e.g., base URLs, keys).
