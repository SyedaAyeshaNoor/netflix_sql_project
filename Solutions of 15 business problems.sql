-- 15 concerns from the Netflix dataset answered using SQL Queries.
-- 1. Count the number of Movies Vs TV Shows

SELECT
	type,
	count(*) as total_content
FROM netflix
Group By type;

--2. Find the Most Common Rating for Movies and TV Shows

SELECT
	type,
	rating
FROM
(
	SELECT
	type,
	rating,
	COUNT(*),
	RANK() OVER(PARTITION BY type ORDER BY COUNT (*) DESC) as ranking
FROM netflix
GROUP BY 1,2
	) as t1
WHERE
	ranking =1;

--3. List All Movies Released in a Specific Year (e.g., 2020)

SELECT*
FROM netflix
WHERE 
	type = 'Movie'
	AND
	release_year = 2020;

--4. Find the Top 5 Countries with the Most Content on Netflix

SELECT 
	UNNEST(STRING_TO_ARRAY(country, ',')) as new_country,
	Count(show_id) as Total_Content
FROM netflix
Group By 1
ORDER BY 2 DESC
LIMIT 5;

--5. Identify the Longest Movie

SELECT * FROM netflix
WHERE 
	type = 'Movie'
	AND
	duration = (SELECT MAX(duration) FROM netflix);

--6. Find Content Added in the Last 5 Years


SELECT * 
FROM netflix
WHERE 
  date_added IS NOT NULL
  AND date_added LIKE '__-___-__'
  AND TO_DATE(TRIM(date_added), 'DD-Mon-YY') >= CURRENT_DATE - INTERVAL '5 years';

--7. Find All Movies/TV Shows by Director 'Rajiv Chilaka'

SELECT*
FROM netflix
WHERE director ILIKE '%Rajiv Chilaka%';

--OR

SELECT *
	FROM
(
	SELECT 
	*,
	UNNEST(STRING_TO_ARRAY(director, ',')) AS director_name
	FROM netflix
) AS t
WHERE director_name = 'Rajiv Chilaka';

	

--8. List All TV Shows with More Than 5 Seasons

SELECT*
FROM NETFLIX
WHERE type = 'TV Show'
AND SPLIT_PART(duration, ' ', 1)::INT> 5;

--9. Count the Number of Content Items in Each Genre

SELECT 
    UNNEST(STRING_TO_ARRAY(listed_in, ',')) AS genre,
    COUNT(show_id) AS total_content
FROM netflix
GROUP BY 1;

--10.Find each year and the average numbers of content release in United States on netflix.
--return top 5 year with highest avg_relaese of contents.	

SELECT 
    country,
    release_year,
    COUNT(show_id) AS total_release,
    ROUND(COUNT(show_id)::numeric /
        (SELECT COUNT(show_id) FROM  netflix WHERE country = 'United States')::numeric * 100,2) AS avg_release
FROM netflix
WHERE country = 'United States'
GROUP BY country, release_year
ORDER BY avg_release DESC
LIMIT 5;

--11. List All Movies that are Documentaries


SELECT * 
FROM netflix
WHERE listed_in ILIKE '%documentaries%';

--12. Find All Content Without a Director

SELECT * 
FROM netflix
WHERE director IS NULL;

--13. Find How Many Movies Actor 'Salman Khan' Appeared in the Last 10 Years

SELECT*
	FROM netflix
	WHERE
		casts ILIKE '%Salman Khan%'
		AND
		release_year > EXTRACT(YEAR FROM CURRENT_DATE)-10;

--14. Find the Top 10 Actors Who Have Appeared in the Highest Number of Movies Produced in India

SELECT 
    UNNEST(STRING_TO_ARRAY(casts, ',')) AS actor,
    COUNT(*)
FROM netflix
WHERE country = 'United States'
GROUP BY actor
ORDER BY COUNT(*) DESC
LIMIT 10;

--15. Categorize Content Based on the Presence of 'Kill' and 'Violence' Keywords
--Label content containing these keywords as 'Bad' and all other content as 'Good. '' Count how many items fall into each category.


SELECT 
    category,
    COUNT(*) AS content_count
FROM(
	SELECT
        CASE 
            WHEN description ILIKE '%kill%' OR description ILIKE '%violence%' THEN 'Bad'
            ELSE 'Good'
        END AS category
FROM netflix) AS categorized_content
GROUP BY category;

