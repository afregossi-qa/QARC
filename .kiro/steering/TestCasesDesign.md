---
inclusion: fileMatch
fileMatchPattern: '**/test_plan_*.md,**/*_Test_Cases*.md,**/*_Test_Cases*.csv'
---

# Test Cases Design Template

# Before starting:

1. Consider that test cases should be written so anyone that doesnt know the product can execute it.
2. Keep in mind the end user is a cashier, so outline the steps in a way that reflects how a cashier would actually behave during their workflow.
3. Look for execution flows to guide you in the step creation.


# PROJ-2346 Platform Settings Test Cases

**Generated from Sources:**
- **Original JIRA Ticket PROJ-2346**
- **Test Design Notes**
- **Domain Knowledge: IDEA-2365_Domain_Knowledge.md**
- **Related Ticket: PROJ-2345**

## Test Summary Matrix
| Test Case ID | Title | Priority | Test Type | Automation Status | Regression Potential |
|--------------|-------|----------|-----------|-------------------|---------------------|
| TC-PROJ-2346-008 | Pay Per Item - Require Cash Drawer Closure Enabled | High | Positive | Required | High |
| TC-PROJ-2346-009 | Pay Per Item - Both Drawer Configurations Enabled | High | Positive | Required | High |
| TC-PROJ-2346-010 | Pay Per Item - Require Full Tender Enabled Only | High | Positive | Required | High |

---

## Platform Settings Test Cases

### TC-PROJ-2346-008: Pay Per Item - Require Cash Drawer Closure Enabled
**Priority:** High  
**Test Type:** Positive  
**Automation Status:** Required  
**Regression Potential:** High  
**Source:** Test Design Notes - Platform Settings

**Preconditions:**
- POS user with login security rights and can create/tender orders
- Till is claimed
- Cash payment is configured at store group payment types in EI
- System is operational
- "Penny Rounding" configuration set to "round up" for Cash payment category
- "Hide Pay Per Item" disabled at terminal level
- "Require Cash Drawer Closure" enabled at terminal level

**Test Steps:**
1. Launch POS and log in as cashier
   **Expected:** POS system loads successfully, cashier is authenticated and main screen displays
2. Add 2 items to the check (e.g., total $10.00)
   **Expected:** Items added successfully, total displays $10.00
3. Go to payment and select cash payment
   **Expected:** Cash payment option is available and selectable, payment screen displays
4. Hit on Pay per Item button
   **Expected:** Pay per item mode activated, items available individually for selection
5. Select Item 1 and confirm (e.g., Item 1 with item's ancillaries: $5.03)
   **Expected:** Item 1 selected for individual payment, due amount $5.03 displayed
6. Apply pay per item payment (tender $6.00)
   **Expected:** Payment processed, system applies round up: $5.03 → $5.05, cash drawer opens, "Please close cash drawer" curtain appears blocking all POS operations
7. Close cash drawer physically
   **Expected:** Curtain disappears, Cash Payment popup displays with Applied Payment: $5.05 + Change Due: $0.95, POS operations resume
8. Add a new cash payment for remaining item
   **Expected:** Cash payment option available for remaining item
9. Hit on Pay per Item button
   **Expected:** Pay per item mode activated for remaining item
10. Select Item 2 and confirm (e.g., Item 2 with item's ancillaries: $4.97)
    **Expected:** Item 2 selected, due amount $4.97 displayed
11. Apply pay per item payment for final item (tender $5.00)
    **Expected:** Final payment processed, system applies round up: $4.97 → $5.00, cash drawer opens, "Please close cash drawer" curtain appears
12. Close cash drawer physically
    **Expected:** Curtain disappears, Check Closed popup appears with order # and Change Due $0.00
13. Verify RoundingAdjustment for both payments
    **Expected:** Item 1: RoundingAdjustment = +$0.02, Item 2: RoundingAdjustment = +$0.03

**Expected Result:**
Cash drawer closure required after each pay per item payment
- Each cash payment triggers drawer opening and closure requirement
- "Please close cash drawer" curtain blocks operations until drawer closed
- Rounding applied normally to each payment
- POS operations resume after drawer closure

**Test Data:**
- Item 1 due amount: $5.03, Rounded: $5.05, RoundingAdjustment: +$0.02, Tendered: $6.00
- Item 2 due amount: $4.97, Rounded: $5.00, RoundingAdjustment: +$0.03, Tendered: $5.00
- Total order: $10.00 (includes all taxes, discounts, service charges)
- Configuration: "Require Cash Drawer Closure" enabled

---

### TC-PROJ-2346-009: Pay Per Item - Both Drawer Configurations Enabled
**Priority:** High  
**Test Type:** Positive  
**Automation Status:** Required  
**Regression Potential:** High  
**Source:** Test Design Notes - Platform Settings

**Preconditions:**
- POS user with login security rights and can create/tender orders
- Till is claimed
- Cash payment is configured at store group payment types in EI
- System is operational
- "Penny Rounding" configuration set to "round up" for Cash payment category
- "Hide Pay Per Item" disabled at terminal level
- "Require Full Tender to Open Cash Drawer" enabled at terminal level
- "Require Cash Drawer Closure" enabled at terminal level

**Test Steps:**
1. Launch POS and log in as cashier
   **Expected:** POS system loads successfully, cashier is authenticated and main screen displays
2. Add 2 items to the check (e.g., total $10.00)
   **Expected:** Items added successfully, total displays $10.00
3. Go to payment and select cash payment
   **Expected:** Cash payment option is available and selectable, payment screen displays
4. Hit on Pay per Item button
   **Expected:** Pay per item mode activated, items available individually for selection
5. Select Item 1 and confirm (e.g., Item 1 with item's ancillaries: $5.03)
   **Expected:** Item 1 selected for individual payment, due amount $5.03 displayed
6. Apply pay per item payment (tender $6.00)
   **Expected:** Payment processed, system applies round up: $5.03 → $5.05, cash drawer opens, "Please close cash drawer" curtain appears blocking all POS operations (Note: "Require Full Tender" doesn't apply to PPI payments)
7. Close cash drawer physically
   **Expected:** Curtain disappears, Cash Payment popup displays with Applied Payment: $5.05 + Change Due: $0.95, POS operations resume
8. Add a new cash payment for remaining item
   **Expected:** Cash payment option available for remaining item
9. Hit on Pay per Item button
   **Expected:** Pay per item mode activated for remaining item
10. Select Item 2 and confirm (e.g., Item 2 with item's ancillaries: $4.97)
    **Expected:** Item 2 selected, due amount $4.97 displayed
11. Apply pay per item payment for final item (tender $5.00)
    **Expected:** Final payment processed, system applies round up: $4.97 → $5.00, cash drawer opens, "Please close cash drawer" curtain appears
12. Close cash drawer physically
    **Expected:** Curtain disappears, Check Closed popup appears with order # and Change Due $0.00
13. Verify RoundingAdjustment for both payments
    **Expected:** Item 1: RoundingAdjustment = +$0.02, Item 2: RoundingAdjustment = +$0.03

**Expected Result:**
Cash drawer closure required after each pay per item payment with both configurations enabled
- "Require Full Tender" doesn't affect PPI payments (each treated separately)
- "Require Cash Drawer Closure" enforced after each payment
- "Please close cash drawer" curtain blocks operations until drawer closed
- Rounding applied normally to each payment
- POS operations resume after drawer closure

**Test Data:**
- Item 1 due amount: $5.03, Rounded: $5.05, RoundingAdjustment: +$0.02, Tendered: $6.00
- Item 2 due amount: $4.97, Rounded: $5.00, RoundingAdjustment: +$0.03, Tendered: $5.00
- Total order: $10.00 (includes all taxes, discounts, service charges)
- Configuration: Both "Require Full Tender to Open Cash Drawer" and "Require Cash Drawer Closure" enabled

---

### TC-PROJ-2346-010: Pay Per Item - Require Full Tender Enabled Only
**Priority:** High  
**Test Type:** Positive  
**Automation Status:** Required  
**Regression Potential:** High  
**Source:** Test Design Notes - Platform Settings

**Preconditions:**
- POS user with login security rights and can create/tender orders
- Till is claimed
- Cash payment is configured at store group payment types in EI
- System is operational
- "Penny Rounding" configuration set to "round up" for Cash payment category
- "Hide Pay Per Item" disabled at terminal level
- "Require Full Tender to Open Cash Drawer" enabled at terminal level
- "Require Cash Drawer Closure" disabled at terminal level

**Test Steps:**
1. Launch POS and log in as cashier
   **Expected:** POS system loads successfully, cashier is authenticated and main screen displays
2. Add 2 items to the check (e.g., total $10.00)
   **Expected:** Items added successfully, total displays $10.00
3. Go to payment and select cash payment
   **Expected:** Cash payment option is available and selectable, payment screen displays
4. Hit on Pay per Item button
   **Expected:** Pay per item mode activated, items available individually for selection
5. Select Item 1 and confirm (e.g., Item 1 with item's ancillaries: $5.03)
   **Expected:** Item 1 selected for individual payment, due amount $5.03 displayed
6. Apply pay per item payment (tender $6.00)
   **Expected:** Payment processed, system applies round up: $5.03 → $5.05, cash drawer opens normally, Cash Payment popup displays immediately with Applied Payment: $5.05 + Change Due: $0.95 (Note: "Require Full Tender" doesn't apply to PPI payments, cashier can physically close drawer or leave it open)
7. Add a new cash payment for remaining item
   **Expected:** Cash payment option available for remaining item, POS operations continue normally
8. Hit on Pay per Item button
   **Expected:** Pay per item mode activated for remaining item
9. Select Item 2 and confirm (e.g., Item 2 with item's ancillaries: $4.97)
   **Expected:** Item 2 selected, due amount $4.97 displayed
10. Apply pay per item payment for final item (tender $5.00)
    **Expected:** Final payment processed, system applies round up: $4.97 → $5.00, cash drawer opens normally, Check Closed popup appears immediately with order # and Change Due $0.00 (cashier can physically close drawer or leave it open)
11. Verify RoundingAdjustment for both payments
    **Expected:** Item 1: RoundingAdjustment = +$0.02, Item 2: RoundingAdjustment = +$0.03

**Expected Result:**
Normal cash drawer operation with "Require Full Tender" enabled but not affecting PPI payments
- "Require Full Tender" doesn't affect PPI payments (each treated separately)
- Cash drawer opens normally after each payment without closure requirement
- No "Please close cash drawer" curtain appears
- Cashier can physically close drawer or leave it open (no system enforcement)
- POS operations continue without interruption
- Rounding applied normally to each payment

**Test Data:**
- Item 1 due amount: $5.03, Rounded: $5.05, RoundingAdjustment: +$0.02, Tendered: $6.00
- Item 2 due amount: $4.97, Rounded: $5.00, RoundingAdjustment: +$0.03, Tendered: $5.00
- Total order: $10.00 (includes all taxes, discounts, service charges)
- Configuration: "Require Full Tender to Open Cash Drawer" enabled, "Require Cash Drawer Closure" disabled

---

## Test Priority Distribution

| Priority | Count | Description |
|----------|-------|-------------|
| 🟠 **High** | **3** | Platform settings test cases for drawer configurations |

**Total: 3 Platform Settings Test Cases**

---

**Generated:** 11/20/2025  
**Version:** 1.0 - Platform Settings Test Cases  
**Total Test Cases:** 3 test cases covering platform settings combinations for drawer configurations