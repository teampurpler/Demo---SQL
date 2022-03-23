/*
Question 1
Of movies with at least 10,000 votes:
Give the distribution of movies in the following categories
>= 9.0  Great
>= 8.0 and < 9.0  Good
>= 7.0 and < 8.0  Decent
>= 6.0 and < 7.0  Questionable
< 6.0  Bad
Order by the number of movies, highest to lowest.
 */

SELECT
     CASE WHEN
         avg_vote >= 9.0 THEN 'Great'
           WHEN avg_vote >= 8.0 AND avg_vote < 9.0 THEN 'Good'
           WHEN avg_vote >= 7.0 AND avg_vote < 8.0 THEN 'Decent'
           WHEN avg_vote >= 6.0 AND avg_vote < 7.0 THEN 'Questionable'
           WHEN avg_vote <6.0 THEN 'Bad' END AS rating_category,
     COUNT(1) AS num_movies
FROM movies
WHERE votes >= 10000
GROUP BY 1
ORDER BY 2 DESC;



/*
Question 2
Show the top 5 Production Companies by total US gross income
Consider only movies with a USD ($) gross income by filtering
to only the movies with a $ symbol in usa_gross_income
 */

SELECT production_company,
       SUM(CAST(LTRIM(usa_gross_income,'$') AS NUMERIC)) AS total_usa_gross_income
FROM movies
WHERE usa_gross_income LIKE '%$%'
GROUP BY 1
ORDER BY 2 DESC
LIMIT 5;


/*
Question 3
Of movies with at least 10,000 votes:
For every year from 2001 - 2010
Show the following metrics per year
- Number of movies
- Average rating per movie (rounded to 1 decimal place)
- Highest rating
- Lowest rating
*/
SELECT
      year,
      COUNT(DISTINCT title) AS num_movies,
      ROUND(AVG(avg_vote),1) AS avg_rating,
      MAX(avg_vote) AS max_rating,
      MIN(avg_vote) AS min_rating
FROM movies
WHERE votes >= 10000
      AND year BETWEEN 2001 AND 2010
GROUP BY 1;



/*
 Question 4
 How many movies in 2008 had an avg_vote above the average avg_vote for 2008?
 Only consider movies with at least 10,000 votes.
 Name the count "num_2008_movies_above_average"
 */

SELECT COUNT(imdb_title_id) AS num_2008_movies_above_average
FROM movies
WHERE votes >= 10000
      AND year = 2008
      AND avg_vote >6.4;


/*
Question 5
For movies released since 1990 with at least 10,000 votes, a budget with "$" in it, and a date_published with format (yyyy-mm-dd)
Show the following, by season,
- Number of movies (num_movies)
- Average budget, rounded to 2 decimals (avg_budget)
- Average USA gross income, rounded to 2 decimals (avg_usa_gross_income)
- Average Worldwide income, rounded to 2 decimals (avg_worldwide_gross_income) *Note I'm correcting the worlwide spelling here when renaming the column

Seasons are defined as
December, January, February = Winter
March, April, May = Spring
June, July, August = Summer
September, October, November = Fall

Order your output by average worldwide gross income, highest to lowest
 */

SELECT
       CASE WHEN DATE_PART('month', DATE(date_published)) IN (12,01,02) THEN 'Winter'
            WHEN DATE_PART('month', DATE(date_published)) IN (03,04,05) THEN 'Spring'
            WHEN DATE_PART('month', DATE(date_published)) IN (06,07,08) THEN 'Summer'
            WHEN DATE_PART('month', DATE(date_published)) IN (09,10,11) THEN 'Fall' END AS season,
       COUNT(imdb_title_id) AS num_movies,
       ROUND(AVG
           (CAST
               (LTRIM(budget,'$') AS NUMERIC)),2) AS avg_budget,
       ROUND(AVG
           (CAST
               (LTRIM(usa_gross_income,'$') AS NUMERIC)),2)AS avg_usa_gross_income,
       ROUND(AVG
           (CAST
               (LTRIM(worlwide_gross_income,'$') AS NUMERIC)),2)AS avg_worldwide_gross_income
FROM movies
WHERE votes >= 10000
      AND year >= 1990
      AND budget LIKE'%$%'
      AND date_published LIKE '____-__-__'
GROUP BY season
ORDER BY avg_worldwide_gross_income DESC;


/*
Question 6
Show the number of movies (min. 10,000 votes), average rating (avg of avg_vote) and max rating (max of avg_vote)
by production companies, of production companies that have a movie with
a max rating >= 9.  Order by max rating, highest to lowest, then by alphabetical order.
*/

SELECT production_company,
       COUNT(imdb_title_id) AS num_movies,
       ROUND(AVG(avg_vote),1) AS avg_rating,
       MAX(avg_vote) AS max_rating
FROM movies
WHERE votes >= 10000
GROUP BY 1
HAVING (MAX(avg_vote)) >= 9
ORDER BY 4 DESC, 1;



/*
 Question 7
 Show the % of actors that were California born by birth decade, for actors born since 1900.
 Columns should be named
 - birth_decade  (formatted as 1900s, 1910s, etc.)
 - count_california_born
 - count_total
 - pct_california_born (rounded to 1 decimal place)

 Order by birth_decade, earliest to latest.

 Note: date_of_birth is an inconsistently formatted column, so you will need to filter to just those that match the
 xxxx-xx-xx format to extract the birth_year.
 */

SELECT
      CONCAT(DATE_PART('decade', DATE(date_of_birth)), '0s') AS birth_decade,
      COUNT(CASE WHEN place_of_birth ILIKE '%California%'THEN place_of_birth END) AS count_california_born,
      COUNT(1) AS count_total,
      ROUND(
          CAST(
               COUNT(
                   CASE WHEN place_of_birth ILIKE '%California%'THEN place_of_birth END
              ) AS NUMERIC)*100/COUNT(1), 1) AS pct_california_born
FROM actors
WHERE date_of_birth LIKE '____-__-__'
      AND date_of_birth >= '1900'
GROUP BY 1
ORDER BY 1;


/*
 Question 8
 What are top 10 first names in the actors table?  Show first_name and num_actors.

 Hint:  Use SPLIT_PART to parse out the first name.  Split on space and consider anything before the first space
 in the name to be the first name.
 */

SELECT SPLIT_PART(name::TEXT,' ', 1) AS first_name,
       COUNT(1) AS num_actors
FROM actors
GROUP BY 1
ORDER BY 2 DESC
LIMIT 10;



/*
 Question 9
How many different production companies are there in the movies table?
 Name the column num_production_companies.
 */


SELECT COUNT(DISTINCT production_company) AS num_production_companies
FROM movies;




/*
Question 10
Show the number of movies by the day of week of date_published, highest to lowest.
Filter to the rows where date_published matches the 'xxxx-xx-xx' format

Hint: Use 'dow' as the extract field in DATE_PART.  'dow' stands for day of week.
It returns 0-6 where 0 = Sunday and 6 = Saturday
 */

SELECT CASE WHEN DATE_PART('dow', DATE(date_published))= 0 THEN 'Sunday'
            WHEN DATE_PART('dow', DATE(date_published))= 1 THEN 'Monday'
            WHEN DATE_PART('dow', DATE(date_published))= 2 THEN 'Tuesday'
            WHEN DATE_PART('dow', DATE(date_published))= 3 THEN 'Wednesday'
            WHEN DATE_PART('dow', DATE(date_published))= 4 THEN 'Thursday'
            WHEN DATE_PART('dow', DATE(date_published))= 5 THEN 'Friday'
            WHEN DATE_PART('dow', DATE(date_published))= 6 THEN 'Saturday' END AS day_of_week,
        COUNT(imdb_title_id) AS num_movies
FROM movies
WHERE date_published LIKE '____-__-__'
GROUP BY 1
ORDER BY 2 DESC;

