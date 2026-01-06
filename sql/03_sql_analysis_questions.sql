/* =====================================================
   SQL ANALYSIS QUESTIONS
   Project: OTT Analytics Portfolio
   Author: Ayushmaan Bhatia
   - To Answer business and analytical questions
   - Queries are written for clarity and explanation,
     not for execution as a single script
   ===================================================== */


-- Question 1: How many titles does each platform have in its catalog?

SELECT
    Platform,
    COUNT(*) AS total_titles
FROM content_master
GROUP BY Platform
ORDER BY total_titles DESC;


-- Question 2: How is each platform’s catalog split by content type?

SELECT
    Platform,
    Content_type,
    COUNT(*) AS total_titles
FROM content_master
GROUP BY Platform, Content_type
ORDER BY Platform, total_titles DESC;


-- Question 3: How has content production volume changed over time across platforms?

SELECT
    Platform,
    Year,
    COUNT(*) AS total_titles
FROM content_master
WHERE Year IS NOT NULL
GROUP BY Platform, Year
ORDER BY Platform, Year;


-- Question 4: Which primary genres dominate each platform’s catalog?

SELECT
    cm.Platform,
    pga.primary_genre,
    COUNT(*) AS total_titles
FROM content_master cm
JOIN primary_genre_assignment pga
    ON cm.row_id = pga.row_id
GROUP BY cm.Platform, pga.primary_genre
ORDER BY cm.Platform, total_titles DESC;


-- Question 5: What is the average rating of content on each platform (weighted by vote count)?

SELECT
    cm.Platform,
    ROUND(
        SUM(te.vote_average * te.vote_count) * 1.0
        / NULLIF(SUM(te.vote_count), 0),
        2
    ) AS weighted_avg_rating
FROM content_master cm
JOIN tmdb_enrichment te
    ON cm.row_id = te.row_id
WHERE te.vote_average IS NOT NULL
  AND te.vote_count IS NOT NULL
GROUP BY cm.Platform
ORDER BY weighted_avg_rating DESC;


-- Question 5: What is the average TMDB rating of content on each platform, weighted by vote count?

SELECT
    cm.Platform,
    ROUND(
        SUM(te.tmdb_rating * te.tmdb_vote_count) * 1.0
        / NULLIF(SUM(te.tmdb_vote_count), 0),
        2
    ) AS weighted_avg_tmdb_rating
FROM content_master cm
JOIN tmdb_enrichment te
    ON cm.row_id = te.row_id
WHERE te.tmdb_rating IS NOT NULL
  AND te.tmdb_vote_count IS NOT NULL
GROUP BY cm.Platform
ORDER BY weighted_avg_tmdb_rating DESC;


-- Question 6: Which primary genres have the highest weighted TMDB ratings on each platform?

SELECT
    cm.Platform,
    pga.primary_genre,
    ROUND(
        SUM(te.tmdb_rating * te.tmdb_vote_count) * 1.0
        / NULLIF(SUM(te.tmdb_vote_count), 0),
        2
    ) AS weighted_avg_tmdb_rating
FROM content_master cm
JOIN tmdb_enrichment te
    ON cm.row_id = te.row_id
JOIN primary_genre_assignment pga
    ON cm.row_id = pga.row_id
WHERE te.tmdb_rating IS NOT NULL
  AND te.tmdb_vote_count IS NOT NULL
GROUP BY cm.Platform, pga.primary_genre
ORDER BY cm.Platform, weighted_avg_tmdb_rating DESC;


-- Question 7: What is the top-performing primary genre on each platform by weighted TMDB rating?

WITH genre_ratings AS (
    SELECT
        cm.Platform,
        pga.primary_genre,
        SUM(te.tmdb_rating * te.tmdb_vote_count) * 1.0
            / NULLIF(SUM(te.tmdb_vote_count), 0) AS weighted_avg_tmdb_rating
    FROM content_master cm
    JOIN tmdb_enrichment te
        ON cm.row_id = te.row_id
    JOIN primary_genre_assignment pga
        ON cm.row_id = pga.row_id
    WHERE te.tmdb_rating IS NOT NULL
      AND te.tmdb_vote_count IS NOT NULL
    GROUP BY cm.Platform, pga.primary_genre
)

SELECT
    Platform,
    primary_genre,
    ROUND(weighted_avg_tmdb_rating, 2) AS weighted_avg_tmdb_rating
FROM (
    SELECT
        *,
        ROW_NUMBER() OVER (
            PARTITION BY Platform
            ORDER BY weighted_avg_tmdb_rating DESC
        ) AS rn
    FROM genre_ratings
)
WHERE rn = 1
ORDER BY weighted_avg_tmdb_rating DESC;


-- Question 8: What percentage of each platform’s catalog is contributed by its top 3 primary genres?

WITH genre_counts AS (
    SELECT
        cm.Platform,
        pga.primary_genre,
        COUNT(*) AS genre_titles
    FROM content_master cm
    JOIN primary_genre_assignment pga
        ON cm.row_id = pga.row_id
    GROUP BY cm.Platform, pga.primary_genre
),
ranked_genres AS (
    SELECT
        *,
        ROW_NUMBER() OVER (
            PARTITION BY Platform
            ORDER BY genre_titles DESC
        ) AS rn,
        SUM(genre_titles) OVER (
            PARTITION BY Platform
        ) AS platform_total_titles
    FROM genre_counts
)

SELECT
    Platform,
    ROUND(
        SUM(CASE WHEN rn <= 3 THEN genre_titles END)_


-- Question 9: Which platforms have the most recent catalogs on average?

SELECT
    Platform,
    ROUND(AVG(Year), 1) AS avg_release_year
FROM content_master
WHERE Year IS NOT NULL
GROUP BY Platform
ORDER BY avg_release_year DESC;


-- Question 10: How does content freshness differ between movies and TV shows across platforms?

SELECT
    Platform,
    Content_type,
    ROUND(AVG(Year), 1) AS avg_release_year
FROM content_master
WHERE Year IS NOT NULL
GROUP BY Platform, Content_type
ORDER BY Platform, avg_release_year DESC;


-- Question 11: What are the top 5 highest-rated titles on each platform (by weighted TMDB rating)?

WITH title_ratings AS (
    SELECT
        cm.Platform,
        cm.Title,
        SUM(te.tmdb_rating * te.tmdb_vote_count) * 1.0
            / NULLIF(SUM(te.tmdb_vote_count), 0) AS weighted_avg_tmdb_rating
    FROM content_master cm
    JOIN tmdb_enrichment te
        ON cm.row_id = te.row_id
    WHERE te.tmdb_rating IS NOT NULL
      AND te.tmdb_vote_count IS NOT NULL
    GROUP BY cm.Platform, cm.Title
)

SELECT
    Platform,
    Title,
    ROUND(weighted_avg_tmdb_rating, 2) AS weighted_avg_tmdb_rating
FROM (
    SELECT
        *,
        ROW_NUMBER() OVER (
            PARTITION BY Platform
            ORDER BY weighted_avg_tmdb_rating DESC
        ) AS rn
    FROM title_ratings
)
WHERE rn <= 5
ORDER BY Platform, weighted_avg_tmdb_rating DESC;


-- Question 12: Which platforms have shown the strongest improvement in content quality over time (by weighted TMDB rating)?

WITH yearly_platform_ratings AS (
    SELECT
        cm.Platform,
        cm.Year,
        SUM(te.tmdb_rating * te.tmdb_vote_count) * 1.0
            / NULLIF(SUM(te.tmdb_vote_count), 0) AS weighted_avg_tmdb_rating
    FROM content_master cm
    JOIN tmdb_enrichment te
        ON cm.row_id = te.row_id
    WHERE cm.Year IS NOT NULL
      AND te.tmdb_rating IS NOT NULL
      AND te.tmdb_vote_count IS NOT NULL
    GROUP BY cm.Platform, cm.Year
),
platform_trends AS (
    SELECT
        Platform,
        Year,
        weighted_avg_tmdb_rating,
        weighted_avg_tmdb_rating
            - LAG(weighted_avg_tmdb_rating) OVER (
                PARTITION BY Platform
                ORDER BY Year
            ) AS yoy_change
    FROM yearly_platform_ratings
)

SELECT
    Platform,
    ROUND(AVG(yoy_change), 2) AS avg_yearly_rating_change
FROM platform_trends
WHERE yoy_change IS NOT NULL
GROUP BY Platform
ORDER BY avg_yearly_rating_change DESC;
