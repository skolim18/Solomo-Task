DROP TABLE IF EXISTS #TableA, #TableB, #MAP

CREATE TABLE #TableA (
    dimension_1 VARCHAR(1),
    dimension_2 VARCHAR(1),
    dimension_3 VARCHAR(1),
    measure_1 INT
);

INSERT INTO #TableA (dimension_1, dimension_2, dimension_3, measure_1)
VALUES
    ('a', 'I', 'K', 1),
    ('a', 'J', 'L', 7),
    ('b', 'I', 'M', 2),
    ('c', 'J', 'N', 5);

CREATE TABLE #TableB (
    dimension_1 VARCHAR(1),
    dimension_2 VARCHAR(1),
    measure_2 INT
);
INSERT INTO #TableB (dimension_1, dimension_2, measure_2)
VALUES
    ('a', 'J', 7),
    ('b', 'J', 10),
    ('d', 'J', 4);

CREATE TABLE #MAP(
	dimension_1 VARCHAR(1),
	correct_dimension_2 VARCHAR(1)
)

INSERT INTO #MAP (dimension_1, correct_dimension_2)
VALUES
    ('a', 'W'),
    ('a', 'W'),
    ('b', 'X'),
	('c', 'Y'),
    ('b', 'X'),
    ('d', 'Z')

CREATE TABLE #TableC (
    dimension_1 VARCHAR(1),
    dimension_2 VARCHAR(1),
	measure_1 INT,
    measure_2 INT
);

INSERT INTO #TableC
  SELECT dimension_1, dimension_2, measure_1, 0 AS measure_2
        FROM #TableA
        UNION ALL
        SELECT dimension_1, dimension_2, 0 AS measure_1, measure_2
        FROM #TableB


WITH corrected_data AS (
    SELECT DISTINCT #TableC.dimension_1,
           COALESCE(MAP.correct_dimension_2, #TableC.dimension_2) AS dimension_2,
           COALESCE(#TableC.measure_1, 0) AS measure_1,
           COALESCE(#TableC.measure_2, 0) AS measure_2
    FROM #TableC
    LEFT JOIN #MAP MAP ON #TableC.dimension_1 = MAP.dimension_1
)

SELECT dimension_1,
       dimension_2,
       SUM(measure_1) AS measure_1,
       SUM(measure_2) AS measure_2
FROM corrected_data
GROUP BY dimension_1, dimension_2;
