/* =====================================================
   GENRE MODELING
   Project: OTT Analytics
   Purpose:
   - Resolve multi-genre titles deterministically
   - Assign exactly one primary genre per title
   - Enforce business-defined genre priorities
   ===================================================== */

/* -----------------------------------------------------
   Step 1: Explode TMDB genre lists into one row per
   title per genre (materialized for stability)
   ----------------------------------------------------- */

CREATE TABLE title_genres_expanded AS
WITH RECURSIVE split_genres AS (

    -- Anchor step
    SELECT
        row_id,
        CASE
            WHEN INSTR(cleaned, ',') > 0
            THEN SUBSTR(cleaned, 1, INSTR(cleaned, ',') - 1)
            ELSE cleaned
        END AS genre_id,
        CASE
            WHEN INSTR(cleaned, ',') > 0
            THEN SUBSTR(cleaned, INSTR(cleaned, ',') + 1)
            ELSE ''
        END AS rest
    FROM (
        SELECT
            row_id,
            REPLACE(REPLACE(tmdb_genres, '[', ''), ']', '') AS cleaned
        FROM tmdb_enrichment
    )

    UNION ALL

    -- Recursive step
    SELECT
        row_id,
        CASE
            WHEN INSTR(rest, ',') > 0
            THEN SUBSTR(rest, 1, INSTR(rest, ',') - 1)
            ELSE rest
        END AS genre_id,
        CASE
            WHEN INSTR(rest, ',') > 0
            THEN SUBSTR(rest, INSTR(rest, ',') + 1)
            ELSE ''
        END AS rest
    FROM split_genres
    WHERE rest <> ''
)

SELECT
    row_id,
    CAST(genre_id AS INTEGER) AS genre_id
FROM split_genres
WHERE genre_id <> '';


/* -----------------------------------------------------
   Step 2: Assign a single primary genre per title
   using predefined priority rules
   ----------------------------------------------------- */

CREATE VIEW primary_genre_assignment AS
SELECT
    row_id,
    genre_name AS primary_genre
FROM (
    SELECT
        tgn.row_id,
        tgn.genre_name,
        tgn.priority_rank,
        ROW_NUMBER() OVER (
            PARTITION BY tgn.row_id
            ORDER BY tgn.priority_rank
        ) AS rn
    FROM (
        SELECT
            tge.row_id,
            gl.genre_name,
            gp.priority_rank
        FROM title_genres_expanded tge
        JOIN genre_lookup gl
          ON tge.genre_id = gl.genre_id
        JOIN genre_priority gp
          ON gl.genre_name = gp.genre_name
    ) tgn
)
WHERE rn = 1;
