# Mutation Operator Statistics
Total number of operators: 25
Transforming C1 into C2 achieves the over-approximation; the inverse achieves the under-approximation.

## Mutation Rule Index (rule1 ~ rule25)

| Rule ID | Category | C1 | C2 |
| ------ | -------- | -- | -- |
| rule1 | Set-Semantic / Relation | SELECT DISTINCT a FROM r | SELECT a FROM r |
| rule2 | Set-Semantic / Relation | r1 UNION r2 | r1 UNION ALL r2 |
| rule3 | Set-Semantic / Relation | A EXCEPT B | A |
| rule4 | Set-Semantic / Relation | A INTERSECT B | A UNION B |
| rule5 | Set-Semantic / Predicate | WHERE cond | WHERE TRUE |
| rule6 | Set-Semantic / Predicate | WHERE FALSE | WHERE cond |
| rule7 | Set-Semantic / Predicate | col LIKE '_abc%' | col LIKE '%abc%' |
| rule8 | Set-Semantic / Predicate | a < b | a <= b |
| rule9 | Set-Semantic / Predicate | a = b | a >= b |
| rule10 | Set-Semantic / Predicate | a > b | a >= b |
| rule11 | Set-Semantic / Predicate | a AND b AND c | a AND b |
| rule12 | Set-Semantic / Predicate | ON cond | ON TRUE |
| rule13 | Set-Semantic / Predicate | ON 1=0 | ON cond |
| rule14 | Set-Semantic / Predicate | REGEXP '^abc+$' | REGEXP 'abc*' |
| rule15 | Set-Semantic / Predicate | HAVING cond | HAVING 1=1 |
| rule16 | Set-Semantic / Predicate | HAVING 1=0 | HAVING cond |
| rule17 | Set-Semantic / Predicate | INNER JOIN | LEFT JOIN |
| rule18 | Value-Semantic / Aggregation | COUNT(DISTINCT c) | COUNT(c) |
| rule19 | Value-Semantic / Aggregation | AVG(c) | MAX(c) |
| rule20 | Value-Semantic / Aggregation | MIN(c) | MAX(c) |
| rule21 | Value-Semantic / Aggregation | VAR_SAMP(c) / STDDEV_SAMP(c) | STDDEV_SAMP(c) (c<1) / VAR_SAMP(c) (c>1) |
| rule22 | Value-Semantic / Aggregation | SUM(c) | SUM(c*k) (k has the same sign as c) |
| rule23 | Value-Semantic / Expression | expr | expr + k (k>0) |
| rule24 | Value-Semantic / Expression | expr | expr * k (k has same sign as expr) |
| rule25 | Value-Semantic / Expression | FUNC(c) (FUNC is monotonic) | FUNC(c*k) (k > 0) |
