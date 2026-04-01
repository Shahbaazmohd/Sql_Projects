DROP TABLE IF EXISTS netflix;
CREATE TABLE netflix
(
    show_id      VARCHAR(5),
    type         VARCHAR(10),
    title        VARCHAR(250),
    director     VARCHAR(550),
    casts        VARCHAR(1050),
    country      VARCHAR(550),
    date_added   VARCHAR(55),
    release_year INT,
    rating       VARCHAR(15),
    duration     VARCHAR(15),
    listed_in    VARCHAR(250),
    description  VARCHAR(550)
);
SELECT * FROM netflix;

SELECT 
	COUNT(*) AS total_content
FROM netflix;

SELECT 
	DISTINCT type 
FROM netflix;

-- Q1. Count the Number of Movies vs TV Shows
SELECT type,
	COUNT(*) as total_content
FROM netflix
GROUP BY type;

-- @2. Find the Most Common Rating for Movies and TV Shows
WITH RatingCounts AS (
    SELECT 
        type,
        rating,
        COUNT(*) AS rating_count
    FROM netflix
    GROUP BY type, rating
),
RankedRatings AS (
    SELECT 
        type,
        rating,
        rating_count,
        RANK() OVER (PARTITION BY type ORDER BY rating_count DESC) AS rank
    FROM RatingCounts
)
SELECT 
    type,
    rating AS most_frequent_rating
FROM RankedRatings
WHERE rank = 1;

-- Q3. List All Movies Released in a Specific Year (e.g., 2020)
SELECT * FROM netflix 
WHERE 
	type = 'Movie'
	AND
	release_year = '2020';

-- Q4. Find the Top 5 Countries with the Most Content on Netflix
SELECT 
	UNNEST(STRING_TO_ARRAY(country,',')) as new_country,
	COUNT(show_id) as total_content
FROM netflix
GROUP BY 1
ORDER BY 2 DESC
LIMIT 5;

-- Q5. Identify the Longest Movie
SELECT * 
FROM netflix
WHERE 
	type = 'Movie'
	and
	duration = (SELECT MAX(duration) FROM netflix)
-- OR, better is the down one
SELECT 
    *
FROM netflix
WHERE type = 'Movie'
ORDER BY SPLIT_PART(duration, ' ', 1)::INT DESC;

-- Q6. Find Content Added in the Last 5 Years
SELECT * FROM netflix 
	Where TO_DATE(date_added, 'Month DD, YYYY') >= CURRENT_DATE - INTERVAL '5 years';

-- Q7.  Find All Movies/TV Shows by Director 'Rajiv Chilaka'
SELECT * FROM netflix 
	Where director ILIKe '%Rajiv Chilaka%';

-- Q8. List All TV Shows with More Than 5 Seasons
SELECT * 
FROM netflix
WHERE type='TV Show'
AND
SPLIT_PART(duration, ' ', 1) >= '5 Season'
-- OR 
SELECT *
FROM netflix
WHERE type = 'TV Show'
  AND SPLIT_PART(duration, ' ', 1)::INT > 5;

-- Q9. Count the Number of Content Items in Each Genre
SELECT 
	UNNEST(STRING_TO_ARRAY(listed_in, ',')) AS genre,
	COUNT(*) AS total_content
FROM netflix
GROUP BY 1;

-- Q10. Find each year and the average numbers of content release in India on netflix.
SELECT 
    country,
    release_year,
    COUNT(show_id) AS total_release,
    ROUND(
        COUNT(show_id)::numeric /
        (SELECT COUNT(show_id) FROM netflix WHERE country = 'India')::numeric * 100, 2 
		--2 is round off, ::numeric does => Converts integers → decimal
    ) AS avg_release
FROM netflix
WHERE country = 'India'
GROUP BY country, release_year
ORDER BY avg_release DESC
LIMIT 5;

-- Q11. List All Movies that are Documentaries
SELECT * 
FROM netflix
WHERE listed_in LIKE '%Documentaries';

-- Q12. Find All Content Without a Director
SELECT * FROM netflix WHERE director is NULL;

-- Q13. Find How Many Movies Actor 'Salman Khan' Appeared in the Last 10 Years
SELECT * FROM netflix WHERE casts LIKE '%Salman Khan%' 
AND release_year > EXTRACT(YEAR FROM CURRENT_DATE) - 10;

-- Q14. Find the Top 10 Actors Who Have Appeared in the Highest Number of Movies 
--Produced in India
SELECT  
	UNNEST(STRING_TO_ARRAY(casts, ',')) AS actor,
	COUNT(*)
FROM netflix WHERE country = 'India' 
GROUP BY actor 
ORDER BY COUNT(*) DESC
LIMIT 10;

-- Q15. Categorize Content Based on the Presence of 'Kill' and 'Violence' Keywords
SELECT 
    category,
    COUNT(*) AS content_count
FROM (
    SELECT 
        CASE 
            WHEN description ILIKE '%kill%' OR description ILIKE '%violence%' THEN 'Bad'
            ELSE 'Good'
        END AS category
    FROM netflix
) AS categorized_content
GROUP BY category;