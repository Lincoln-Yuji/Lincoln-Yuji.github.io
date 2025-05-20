---
title: 'CASE/WHEN inside SQL JOIN conditions'
categories: [SQL, MySQL]
tags: [tutorial, sql]
---

To start the post, I'd like to present the task I had to complete at my job in order to write
the sample code I'm about to show here. Also, I'd like to emphasize that no real data is being
used through this post.

Imagine we have the following table `OBJECT_COSTS`:

| REFERENCE         | Cost |
| ----------------- | ---- |
| CUO0001_TY001_001 | $100 |
| CUO0001_TY002_001 | $200 |
| CUO0001_TY003_001 | $730 |
| CUO0002_TY001_001 | $650 |
| CUO0002_TY002_001 | $230 |
| CUO0002_TY003_001 | $190 |
| CUO0003_TY001_001 | $190 |
| CUO0003_TY001_002 | $220 |
| CUO0003_TY001_003 | $500 |
| NA_NA_NA          | $850 |
| CUO0001_NA_NA     | $500 |
| NA_TY003_NA       | $100 |
| NA_NA_002         | $800 |
| CUO0003_TY001_NA  | $710 |
| CUO0002_NA_001    | $280 |

Notice how some of the objects' references have "NA" (Not Available) as part of their structure.
We will call them "None Objects". What we need to do here is to create a table that associates all the
None Objects to the others such that their cost will be realocated to the "Complete Objects".

# Diving into the problem

So now it's important to understand what the criteria is to realocate the costs of these None Objects.
The idea is simple, we need to associate a None Object to all the Complete Objects whose structures match
with the rest of the None Object structure that is available.

Let's use an example to make it easier to digest. The object `CUO0002_NA_001` has to realocate its costs to
`CUO0002_TY001_001`, `CUO0002_TY002_001` and `CUO0002_TY003_001`. Our assignments table needs to have the
following lines:

| SOURCE_REFERENCE | TARGET_REFERENCE  |
| ---------------- | ----------------- |
| CUO0002_NA_001   | CUO0002_TY001_001 |
| CUO0002_NA_001   | CUO0002_TY002_001 |
| CUO0002_NA_001   | CUO0002_TY003_001 |

The question is, considering we have a huge `OBJECT_COSTS` table with millions of objects and possibly more
levels on their reference structure than only 3 as shown in this sample example, how do we write an SQL
code that can build this assignment table for us?

# Splitting the references into levels

The code is actually quite simple, but the ideia behind it might not be obvious for everyone. For the first step,
we will break all the objects references into levels to make the next steps easier. The following code is based on
`MySQL` server:

```sql
DROP TABLE IF EXISTS OBJECT_COSTS_LEVELS;
CREATE TEMPORARY TABLE OBJECT_COSTS_LEVELS;

INSERT INTO OBJECT_COSTS_LEVELS
SELECT *,
	Substring_Index(REFERENCE, '_', 1) AS LV1,
    Substring_Index(Substring_Index(REFERENCE, '_', 2), '_', -1) AS LV2,
    Substring_Index(Substring_Index(REFERENCE, '_', 3), '_', -1) AS LV3
FROM OBJECT_COSTS;
```

That gives us the following table:

| REFERENCE         | Cost | LV1     | LV2   | LV3 |
| ----------------- | ---- | ------- | ----- | --- |
| CUO0001_TY001_001 | $100 | CUO0001 | TY001 | 001 |
| CUO0001_TY002_001 | $200 | CUO0001 | TY002 | 001 |
| CUO0001_TY003_001 | $730 | CUO0001 | TY003 | 001 |
| CUO0002_TY001_001 | $650 | CUO0002 | TY001 | 001 |
| CUO0002_TY002_001 | $230 | CUO0002 | TY002 | 001 |
| CUO0002_TY003_001 | $190 | CUO0002 | TY003 | 001 |
| CUO0003_TY001_001 | $190 | CUO0003 | TY001 | 001 |
| CUO0003_TY001_002 | $220 | CUO0003 | TY001 | 002 |
| CUO0003_TY001_003 | $500 | CUO0003 | TY001 | 003 |
| NA_NA_NA          | $850 | NA      | NA    | NA  |
| CUO0001_NA_NA     | $500 | CUO0001 | NA    | NA  |
| NA_TY003_NA       | $100 | NA      | TY003 | NA  |
| NA_NA_002         | $800 | NA      | NA    | 002 |
| CUO0003_TY001_NA  | $710 | CUO0003 | TY001 | NA  |
| CUO0002_NA_001    | $280 | CUO0002 | NA    | 001 |

# Separating the Complete Objects

Now we can create a `COMPLETE_OBJECT_COSTS_LEVELS` with only the complete objects:

```sql
DROP TABLE IF EXISTS COMPLETE_OBJECT_COSTS_LEVELS;
CREATE TEMPORARY TABLE COMPLETE_OBJECT_COSTS_LEVELS;

INSERT INTO COMPLETE_OBJECT_COSTS_LEVELS
SELECT * FROM OBJECT_COSTS_LEVELS
WHERE LV1 != 'NA' AND LV2 != 'NA' AND LV3 != 'NA';
```

Results in the following table:

| REFERENCE         | Cost | LV1     | LV2   | LV3 |
| ----------------- | ---- | ------- | ----- | --- |
| CUO0001_TY001_001 | $100 | CUO0001 | TY001 | 001 |
| CUO0001_TY002_001 | $200 | CUO0001 | TY002 | 001 |
| CUO0001_TY003_001 | $730 | CUO0001 | TY003 | 001 |
| CUO0002_TY001_001 | $650 | CUO0002 | TY001 | 001 |
| CUO0002_TY002_001 | $230 | CUO0002 | TY002 | 001 |
| CUO0002_TY003_001 | $190 | CUO0002 | TY003 | 001 |
| CUO0003_TY001_001 | $190 | CUO0003 | TY001 | 001 |
| CUO0003_TY001_002 | $220 | CUO0003 | TY001 | 002 |
| CUO0003_TY001_003 | $500 | CUO0003 | TY001 | 003 |

# Creating the Assignments

We can now create the assignments between the `OBJECT_COSTS_LEVELS` and `COMPLETE_OBJECT_COSTS_LEVELS`
by using multiple `CASE/WHEN` statements inside an SQL JOIN query:

```sql
SELECT
    T1.REFERENCE AS SOURCE_REFERENCE,
    T2.REFERENCE AS TARGET_REEFRENCE
FROM
    OBJECT_COSTS_LEVELS AS T1
        JOIN
    COMPLETE_OBJECT_COSTS_LEVELS AS T2
        ON
    CASE WHEN T1.LV1 = 'NA' THEN T2.LV1 ELSE T1.LV1 END = T2.LV1 AND
    CASE WHEN T1.LV2 = 'NA' THEN T2.LV2 ELSE T1.LV2 END = T2.LV2 AND
    CASE WHEN T1.LV3 = 'NA' THEN T2.LV3 ELSE T1.LV3 END = T2.LV3
```
By doing this, whenever the level is 'NA', then we force the match at that level. If not, then
we compare `T1.LVX` and `T2.LVX` normally. We do this at every level and make sure all the
conditions are true to create the assignments via `JOIN`. The result follows like so:

| SOURCE_REFERENCE     | TARGET_REEFRENCE     |
|----------------------|----------------------|
| CUO0001_TY001_001    | CUO0001_TY001_001    |
| CUO0001_TY002_001    | CUO0001_TY002_001    |
| CUO0001_TY003_001    | CUO0001_TY003_001    |
| CUO0002_TY001_001    | CUO0002_TY001_001    |
| CUO0002_TY002_001    | CUO0002_TY002_001    |
| CUO0002_TY003_001    | CUO0002_TY003_001    |
| CUO0003_TY001_001    | CUO0003_TY001_001    |
| CUO0003_TY001_002    | CUO0003_TY001_002    |
| CUO0003_TY001_003    | CUO0003_TY001_003    |
| NA_NA_NA             | CUO0003_TY001_003    |
| NA_NA_NA             | CUO0003_TY001_002    |
| NA_NA_NA             | CUO0003_TY001_001    |
| NA_NA_NA             | CUO0002_TY003_001    |
| NA_NA_NA             | CUO0002_TY002_001    |
| NA_NA_NA             | CUO0002_TY001_001    |
| NA_NA_NA             | CUO0001_TY003_001    |
| NA_NA_NA             | CUO0001_TY002_001    |
| NA_NA_NA             | CUO0001_TY001_001    |
| CUO0001_NA_NA        | CUO0001_TY003_001    |
| CUO0001_NA_NA        | CUO0001_TY002_001    |
| CUO0001_NA_NA        | CUO0001_TY001_001    |
| NA_TY003_NA          | CUO0002_TY003_001    |
| NA_TY003_NA          | CUO0001_TY003_001    |
| NA_NA_002            | CUO0003_TY001_002    |
| CUO0003_TY001_NA     | CUO0003_TY001_003    |
| CUO0003_TY001_NA     | CUO0003_TY001_002    |
| CUO0003_TY001_NA     | CUO0003_TY001_001    |
| CUO0002_NA_001       | CUO0002_TY003_001    |
| CUO0002_NA_001       | CUO0002_TY002_001    |
| CUO0002_NA_001       | CUO0002_TY001_001    |

# Final Alocated Cost computation

For simplicity, we didn't bring the costs of them objects in previous section, bu modifying the columns selected we can bring them
to our output. We will call the following table `OBJECT_COST_ASSIGNMENTS`:

| SOURCE_REFERENCE     | COST | TARGET_REFERENCE     | TARGET_COST  |
|----------------------|------|----------------------|--------------|
| CUO0001_TY001_001    | 100  | CUO0001_TY001_001    | 100          |
| CUO0001_TY002_001    | 200  | CUO0001_TY002_001    | 200          |
| CUO0001_TY003_001    | 730  | CUO0001_TY003_001    | 730          |
| CUO0002_TY001_001    | 650  | CUO0002_TY001_001    | 650          |
| CUO0002_TY002_001    | 230  | CUO0002_TY002_001    | 230          |
| CUO0002_TY003_001    | 190  | CUO0002_TY003_001    | 190          |
| CUO0003_TY001_001    | 190  | CUO0003_TY001_001    | 190          |
| CUO0003_TY001_002    | 220  | CUO0003_TY001_002    | 220          |
| CUO0003_TY001_003    | 500  | CUO0003_TY001_003    | 500          |
| NA_NA_NA             | 850  | CUO0003_TY001_003    | 500          |
| NA_NA_NA             | 850  | CUO0003_TY001_002    | 220          |
| NA_NA_NA             | 850  | CUO0003_TY001_001    | 190          |
| NA_NA_NA             | 850  | CUO0002_TY003_001    | 190          |
| NA_NA_NA             | 850  | CUO0002_TY002_001    | 230          |
| NA_NA_NA             | 850  | CUO0002_TY001_001    | 650          |
| NA_NA_NA             | 850  | CUO0001_TY003_001    | 730          |
| NA_NA_NA             | 850  | CUO0001_TY002_001    | 200          |
| NA_NA_NA             | 850  | CUO0001_TY001_001    | 100          |
| CUO0001_NA_NA        | 500  | CUO0001_TY003_001    | 730          |
| CUO0001_NA_NA        | 500  | CUO0001_TY002_001    | 200          |
| CUO0001_NA_NA        | 500  | CUO0001_TY001_001    | 100          |
| NA_TY003_NA          | 100  | CUO0002_TY003_001    | 190          |
| NA_TY003_NA          | 100  | CUO0001_TY003_001    | 730          |
| NA_NA_002            | 800  | CUO0003_TY001_002    | 220          |
| CUO0003_TY001_NA     | 710  | CUO0003_TY001_003    | 500          |
| CUO0003_TY001_NA     | 710  | CUO0003_TY001_002    | 220          |
| CUO0003_TY001_NA     | 710  | CUO0003_TY001_001    | 190          |
| CUO0002_NA_001       | 280  | CUO0002_TY003_001    | 190          |
| CUO0002_NA_001       | 280  | CUO0002_TY002_001    | 230          |
| CUO0002_NA_001       | 280  | CUO0002_TY001_001    | 650          |

From the table `OBJECT_COST_ASSIGNMENTS`, we can use the following SQL command to get the final alocated cost proportional to the target's cost for each source object:

```sql
SELECT TARGET_REFERENCE AS REFERENCE, SUM(ALOCATED_COST) AS FINAL_COST FROM (
  SELECT *, COST * (TARGET_COST / (SUM(TARGET_COST) OVER (PARTITION BY SOURCE_REFERENCE))) AS ALOCATED_COST
  FROM OBJECT_COST_ASSIGNMENTS
) AS INNER_COMPUTED_ALLOCATION
GROUP BY TARGET_REFERENCE
ORDER BY REFERENCE;
```

The inner query computes them sum of all the target costs within the same source object and uses this value as weight for the cost that will
be alocated in that line. The outer query will aggregate all alocated values for each target object and use their sum as the final cost
of each target object. The final result follows below:

| REFERENCE           | FINAL_COST          |
|---------------------|---------------------|
| CUO0001_TY001_001   | 176.78289197819566  |
| CUO0001_TY002_001   | 353.56578395639133  |
| CUO0001_TY003_001   | 1369.8629375277847  |
| CUO0002_TY001_001   | 1003.6482752196727  |
| CUO0002_TY002_001   | 355.1370820008073   |
| CUO0002_TY003_001   | 314.0262851311017   |
| CUO0003_TY001_001   | 391.89624329159216  |
| CUO0003_TY001_002   | 1253.7745974955278  |
| CUO0003_TY001_003   | 1031.3059033989266  |

# Conclusion

There could be alternative ways to calculate the final cost of each complete object, we could use more sofisticated volumetries or formulas,
but this one gets the job done for our example. We are basically alocating more for objects that already have higher costs, while alocating
less for objects that don't have much cost. It's a criteria we defined that could be considered fair with no additional context. That
should be enough to understand the ideia of reallocating costs of "None Objects" to "Complete Objects".

I hope this can help anyone to apreciate how many interesting things we can do with JOINs in order to
perform conditional assignments between multiple SQL tables very creatively.

See you in the next post!