-- ============================================================
--         PAN NUMBER VALIDATION PROJECT (CORRECTED)
--         Database : PostgreSQL
-- ============================================================


---- View All Data ----
SELECT *
       FROM Pan_Number_Validation;


---- Correct Letter Case ----
SELECT *
       FROM Pan_Number_Validation
       WHERE Pan_Number = UPPER(Pan_Number);


---- Handle Leading/Trailing Spaces ----
SELECT *
       FROM Pan_Number_Validation
       WHERE Pan_Number = TRIM(Pan_Number);


---- Check For Duplicates ----
SELECT DISTINCT(Pan_Number)
       FROM Pan_Number_Validation;


---- Identify And Handle Missing Data ----
SELECT *
       FROM Pan_Number_Validation
       WHERE TRIM(Pan_Number) <> ''
       AND Pan_Number IS NOT NULL;


---- Cleaned Data ----
SELECT DISTINCT UPPER(TRIM(Pan_Number)) AS Pan_Number
       FROM Pan_Number_Validation
       WHERE Pan_Number IS NOT NULL
       AND TRIM(Pan_Number) <> '';


-- ============================================================
--   PAN FORMAT VALIDATION : FUNCTIONS
-- ============================================================

---- Function: Check For Adjacent (Repeated) Characters ----
-- Returns TRUE if any two side-by-side characters are the same
-- Example: 'AABCD' → TRUE (invalid), 'ABCDE' → FALSE (ok)

CREATE OR REPLACE FUNCTION Fn_Adjacent_Characters(p_str TEXT)
RETURNS BOOLEAN
LANGUAGE plpgsql
AS $$
BEGIN
    FOR i IN 1 .. (LENGTH(p_str) - 1)
    LOOP
        IF SUBSTRING(p_str, i, 1) = SUBSTRING(p_str, i+1, 1)
        THEN
            RETURN TRUE;
        END IF;
    END LOOP;
    RETURN FALSE;
END;
$$;


---- Function: Check For Sequential Characters ----
-- Returns TRUE if all characters are in alphabetical sequence
-- Example: 'ABCDE' → TRUE (invalid), 'ABCXE' → FALSE (ok)

CREATE OR REPLACE FUNCTION Fn_Sequential_Characters(p_str TEXT)
RETURNS BOOLEAN
LANGUAGE plpgsql
AS $$
BEGIN
    FOR i IN 1 .. (LENGTH(p_str) - 1)
    LOOP
        IF ASCII(SUBSTRING(p_str, i, 1)) <> (ASCII(SUBSTRING(p_str, i+1, 1)) - 1)
        THEN
            RETURN FALSE;
        END IF;
    END LOOP;
    RETURN TRUE;
END;
$$;


---- Test The Functions ----
SELECT Fn_Sequential_Characters('ABCXE');   -- Expected: FALSE
SELECT Fn_Sequential_Characters('ABCDE');   -- Expected: TRUE


---- Check If PAN Numbers Match Format Pattern ----
-- Format Rule: 5 Letters + 4 Digits + 1 Letter
SELECT *
       FROM Pan_Number_Validation
       WHERE Pan_Number ~ '^[A-Z]{5}[0-9]{4}[A-Z]$';


-- ============================================================
--   CLEANED & VALIDATED PAN VIEW WITH REASON COLUMN
-- ============================================================

CREATE OR REPLACE VIEW Pan_Categorization AS
WITH Cleaned_Data AS
(
    -- Step 1: Remove nulls, blanks, fix case and spaces
    SELECT DISTINCT UPPER(TRIM(Pan_Number)) AS Pan_Number
           FROM Pan_Number_Validation
           WHERE Pan_Number IS NOT NULL
           AND TRIM(Pan_Number) <> ''
),
Filtered_Data AS
(
    -- Step 2: Apply all validation rules
    SELECT Pan_Number
           FROM Cleaned_Data
           WHERE Pan_Number ~ '^[A-Z]{5}[0-9]{4}[A-Z]$'
           AND Fn_Adjacent_Characters(Pan_Number) = FALSE
           AND Fn_Sequential_Characters(SUBSTRING(Pan_Number, 1, 5)) = FALSE
)
SELECT
       cl.Pan_Number,
       CASE
           WHEN cl.Pan_Number !~ '^[A-Z]{5}[0-9]{4}[A-Z]$'
               THEN 'INVALID - Bad Format'
           WHEN Fn_Adjacent_Characters(cl.Pan_Number) = TRUE
               THEN 'INVALID - Adjacent Repeated Characters'
           WHEN Fn_Sequential_Characters(SUBSTRING(cl.Pan_Number, 1, 5)) = TRUE
               THEN 'INVALID - Sequential Letters In Prefix'
           ELSE 'VALID_PAN'
       END AS Pan_Status
FROM Cleaned_Data cl;


-- ============================================================
--   SUMMARY REPORT
-- ============================================================

SELECT
    (SELECT COUNT(*) FROM Pan_Number_Validation)                 AS Total_Pan_Numbers,
    COUNT(*) FILTER (WHERE Pan_Status = 'VALID_PAN')             AS Total_Valid_Pan_Numbers,
    COUNT(*) FILTER (WHERE Pan_Status LIKE 'INVALID%')           AS Total_Invalid_Pan_Numbers,
    (SELECT COUNT(*) FROM Pan_Number_Validation)
    - COUNT(*) FILTER (WHERE Pan_Status = 'VALID_PAN')
    - COUNT(*) FILTER (WHERE Pan_Status LIKE 'INVALID%')         AS Total_Missing_Pan_Numbers
FROM Pan_Categorization;


-- ============================================================
--   INVALID REASON BREAKDOWN (BONUS REPORT)
-- ============================================================

SELECT
    Pan_Status     AS Reason,
    COUNT(*)       AS Count
FROM Pan_Categorization
WHERE Pan_Status <> 'VALID_PAN'
GROUP BY Pan_Status
ORDER BY Count DESC;
