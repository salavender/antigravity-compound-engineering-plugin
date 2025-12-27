---
pattern_number: 18
title: "Mobile Table Responsiveness"
last_referenced: "2025-12-27"
tags: [patterns, critical-patterns]
---

### Pattern #18: Mobile Table Responsiveness


**Problem:** Native HTML tables (`<table>`, `<tr>`, `<td>`) do not adapt well to mobile screens, causing horizontal scrolling or broken layouts.

**❌ WRONG:**
```tsx
<div className="overflow-x-auto">
  <table>
    <thead>
      <tr>
        <th>Item</th>
        <th>Value</th>
      </tr>
    </thead>
    <tbody>
      <tr>
        <td>Component A</td>
        <td>100</td>
      </tr>
    </tbody>
  </table>
</div>
```

**✅ CORRECT:**
```tsx
<StandardTable className="table-responsive">
  <StandardThead>
    <StandardTr>
      <StandardTh>Item</StandardTh>
      <StandardTh>Value</StandardTh>
    </StandardTr>
  </StandardThead>
  <StandardTbody>
    <StandardTr>
      <StandardTd data-label="Item">Component A</StandardTd>
      <StandardTd data-label="Value">100</StandardTd>
    </StandardTr>
  </StandardTbody>
</StandardTable>
```

**Why:** Using responsive table wrappers with `data-label` transforms rows into vertical cards on mobile, ensuring readability and consistency without horizontal scrolling.

**Source:** UI responsiveness best practices.
