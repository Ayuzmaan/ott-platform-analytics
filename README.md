# OTT Catalog Strategy & Consumer Value Analysis

## Project Overview

This project is an end-to-end analytical study of OTT platforms focused on three core themes:

- Catalog scale and structure  
- Content quality and rating confidence  
- Platform pricing efficiency and perceived consumer value  

The objective is to demonstrate real-world data analytics capability across the full pipeline: Python for enrichment, SQLite for business analysis, and Tableau for executive communication.

---

## Tech Stack Used

- **Python** – Data cleaning, EDA, and TMDB API enrichment  
- **SQLite** – Relational modelling and analytical SQL queries  
- **Tableau Public** – Interactive multi-page executive dashboards  

---

## Methodology

### Data Preparation

- Raw OTT catalog data was collected as CSV extracts from Tableau Public.  
- Exploratory Data Analysis (EDA) was performed in Jupyter Notebook to understand distributions, missing values, and platform-level differences.

### API Enrichment

- The catalog dataset was enriched using the TMDB API.  
- A caching mechanism was implemented in Python to avoid duplicate API calls.  
- Batch processing was used to efficiently fetch ratings and vote counts for all titles.

### Genre Modelling Logic

To avoid messy multi-genre labels, a deterministic genre system was designed:

- Top 15 most common genres were identified.  
- A 16th category called **“Others”** was added for low-frequency genres.  
- A fixed priority order was established for genres.  
- Each title was assigned exactly ONE genre based on the following rules:

1. If no genre matched the Top 15, it was classified as “Others.”  
2. If only one Top 15 genre existed, it was assigned directly.  
3. If multiple Top 15 genres existed, the highest-priority genre was selected.

This streamlined taxonomy ensures clear, consistent platform-agnostic analysis.

---

## Repository Structure

### Folders

- `/data`  
  - Contains all final cleaned and enriched CSV datasets used for SQL and Tableau.

- `/notebooks`  
  - Jupyter notebook with full EDA and TMDB API enrichment process.

- `/sql`  
  - All analytical SQL scripts used in SQLite Studio.

### SQL Files

1. **schema.sql**  
   - Creates core tables for analysis.

2. **genre_modelling.sql**  
   - Implements genre taxonomy and deterministic assignment logic.

3. **business_questions.sql**  
   - Answers 12 key business and strategy questions using SQLite queries.

---

## Analytical Principles Demonstrated

- Use of **weighted ratings** to incorporate vote confidence.  
- Clean relational joins between catalog and TMDB enrichment tables.  
- Thoughtful handling of genres as first-class analytical entities.  
- Disciplined dashboard design focused on clarity and variance.  
- Platform-agnostic filtering to allow comparisons across all pages.

---

## Tableau Public Dashboard

https://public.tableau.com/views/OTTCatalogStrategyConsumerValueAnalysis/OTTAnalytics-ExecutiveView?:language=en-US&publish=yes&:sid=&:redirect=auth&:display_count=n&:origin=viz_share_link

---

## Business Impact

The analysis helps evaluate:

- Which OTT platforms offer the best value per dollar  
- How catalog freshness varies across services  
- Which genres perform strongly on each platform  
- Overall rating quality and consistency

---

## How to Use This Project

- Open the Jupyter notebook to review the Python enrichment and EDA process.  
- Run SQL files sequentially in SQLite Studio in the following order:
- Use the Tableau Public Story link for interactive exploration of dashboards.

---

## Author

**Ayushmaan Bhatia**  
Data Analyst | Portfolio Project | 2026

