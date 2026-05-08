# Skill: Regression-Mapping-Logic

**Objective**: Systematically identify if a Jira ticket should be converted into a permanent regression test and how to map it to the existing `POS_Automation_UI` framework.

## 1. Regression Impact Analysis
* **Keyword Scan**: Look for "Fix", "Regression", "Breakage", or "Core" in ticket descriptions.
* **Traceability Check**: Cross-reference the ticket's functionality with the `pos/src/test/resources/suites/regression_suite.xml` to see if a similar test already exists.

## 2. Framework Reuse Protocol (Read-First)
* **Step A**: Locate the Page Object class related to the feature.
* **Step B**: Search for existing methods using `grep` via MCP before drafting code.
* **Step C**: If a method like `clickPayButton()` exists but needs a slight change (e.g., a new timeout), **OVERLOAD** the method or add an optional parameter rather than creating `clickPayButtonNew()`.

## 3. Structural Consistency Rules
* **Inheritance**: Force `extends PosBaseTest` to ensure screenshots and logs are handled globally.
* **Traceability**: Always include `@AioDecorator` so the regression result syncs back to the AIO Tests Regression Cycle.
* **Cleanliness**: If adding new methods to a Page Factory, ensure they use the same `@FindBy` annotation style and access modifiers as the surrounding code.