---
title: 'Using SQL windows to realocate our values'
categories: [SQL, MySQL]
tags: [tutorial, sql]
---

This blog post is the sequel of another one where we presented the use of more
sofisticated joins in order to create cost assignments between objects. For a better
contextualization and understanding of the problem presented here, please take a look at
the **"CASE/WHEN inside SQL JOIN conditions"** prior to this post.

# Final Alocated Cost computation

From the table `OBJECT_COST_ASSIGNMENTS`, we can use the following SQL command to get the final alocated cost proportional to the target's cost for each source object:

```sql
SELECT TARGET_REFERENCE AS REFERENCE, SUM(ALOCATED_COST) AS FINAL_COST FROM (
  SELECT *, COST * (TARGET_COST / (SUM(TARGET_COST) OVER (PARTITION BY SOURCE_REFERENCE))) AS ALOCATED_COST
  FROM OBJECT_COST_ASSIGNMENTS
)
GROUP BY TARGET_REFERENCE
ORDER BY REFERENCE;
```