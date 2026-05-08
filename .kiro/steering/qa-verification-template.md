---
inclusion: manual
---

# QA Verification Comment Template

Use this template when adding QA verification comments to Jira bug tickets.

## Template

```markdown
**QA Verification - Build {VERSION}**

**Test Result**: ✅ PASS / ❌ FAIL

**Test Scenario ({TC_ID})**:
1. {Step 1}
2. {Step 2}
3. {Step 3}
...

**Result**: {Describe actual outcome vs expected}

**Technical Observation** (if applicable):
- {Any relevant technical details observed during testing}
- {State behavior, data observations, etc.}

**Build Info**:
- Version: {BUILD_VERSION}
- Branch: {BRANCH_NAME}
```

## Example (PASS)

```markdown
**QA Verification - Build 3.5.567.234**

**Test Result**: ✅ PASS

**Test Scenario (TC-FIX-01)**:
1. Selected Order Type FOT
2. Added items to order
3. Placed Future Order with date ~15 min in future (kitchen buffer = 10 min)
4. Waited for order to reach KDS (sent via buffer before orderReadyTime)
5. Recalled FO from Open Checks → FO filter
6. Applied payment

**Result**: No warning popup displayed. Payment proceeded normally as expected.

**Technical Observation**:
- Local check DB still shows `ProcessingState = "Suspending"` after order reaches kitchen
- This is **expected behavior** - the Order Scheduler worker updates the cloud `OrderScheduleStatuses` collection, not the local DB

**Build Info**:
- Version: 3.5.567.234
- Branch: feature/PG-560_SchedulerFutureOrdersOfflineProcessing
```

## Example (FAIL)

```markdown
**QA Verification - Build 3.5.567.234**

**Test Result**: ❌ FAIL

**Test Scenario (TC-FIX-02)**:
1. Created FO with orderReadyTime 2 hours in future
2. Immediately recalled FO (before kitchenRoutingTime)
3. Applied payment

**Expected**: Warning popup should be displayed
**Actual**: No warning popup displayed - payment proceeded without validation

**Technical Observation**:
- Order was not sent to kitchen yet (verified in OrderScheduleStatuses)
- Warning logic appears to be bypassed incorrectly

**Build Info**:
- Version: 3.5.567.234
- Branch: feature/PG-560_SchedulerFutureOrdersOfflineProcessing

**Recommendation**: Reopen bug, investigate warning condition logic
```

## Usage

When you need to add a QA verification comment, reference this template with `#qa-verification-template` in chat.
