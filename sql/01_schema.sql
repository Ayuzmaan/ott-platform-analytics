/* =====================================================
   SCHEMA DEFINITION
   Project: OTT Analytics
   Purpose:
   - Define final table structures
   - Represent the authoritative data model
   ===================================================== */

CREATE TABLE content_master (
    row_id INTEGER PRIMARY KEY,
    Title TEXT,
    Year INTEGER,
    Age TEXT,
    Content_type TEXT,
    Rotten_Tomatoes TEXT,
    Platform TEXT
);

CREATE TABLE tmdb_enrichment (
    row_id INTEGER PRIMARY KEY,
    tmdb_id INTEGER,
    tmdb_rating REAL,
    tmdb_vote_count INTEGER,
    tmdb_popularity REAL,
    tmdb_genres TEXT
);

CREATE TABLE genre_lookup (
    genre_id INTEGER PRIMARY KEY,
    genre_name TEXT
);

CREATE TABLE genre_priority (
    genre_name TEXT,
    priority_rank INTEGER
);
