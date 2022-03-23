/*
 Question 1
 Find the top 5 movies ordered by the most 1 star votes.
 Provide the original_title, avg_vote, and votes_1
 */

SELECT m."original_title",
       m."avg_vote",
       MAX(r.votes_1) AS votes_1
FROM movies m
INNER JOIN ratings r ON m."imdb_title_id" = r."imdb_title_id"
GROUP BY 1,2
ORDER BY 3 DESC
LIMIT 5;


/*
 Question 2
 Find the top 10 movies featuring Tom Hanks or Morgan Freeman as an actor (by avg_vote).
 Break ties with original_title in alphabetical order.
 Provide the columns name, characters, original_title, and avg_vote
 */


SELECT a.name,
       tp."characters",
       m."original_title",
       m."avg_vote"
FROM title_principals tp
INNER JOIN actors a ON a.imdb_name_id = tp.imdb_name_id
INNER JOIN movies m on m.imdb_title_id = tp.imdb_title_id
WHERE a.name = 'Tom Hanks' OR a.name = 'Morgan Freeman'
ORDER BY 4 DESC,1
LIMIT 10;


/*
 Question 3
 Find the actors that have played James Bond more than once
 List the start and end years of their James Bond tenure (year of first movie, year of last movie)
 Provide the number of James Bond movies each actor acted in, as well as the average avg_rating of their Bond movies.
 Sort the output by the number of Bond movies (most to least), followed by the avg_rating (highest to lowest)

 Note: If you would like to see the movie titles, you can use ARRAY_AGG to compile the movie titles into an array.  But
 don't include this in the output.

 */

SELECT a.name,
       jb.start_year,
       jb.end_year,
       jb.num_movies,
       jb.avg_rating
FROM actors a
INNER JOIN (
    SELECT
           MIN(m.year) AS start_year,
           MAX(m.year) AS end_year,
           ROUND(AVG(m.avg_vote),1) AS avg_rating,
           COUNT(tp.imdb_title_id) AS num_movies,
           tp.imdb_name_id
    FROM movies m
    INNER JOIN title_principals tp on m.imdb_title_id = tp.imdb_title_id
    WHERE tp.characters ILIKE '%james bond%'
    GROUP BY 5
    HAVING COUNT(tp.imdb_title_id) >1
    ORDER BY 4 DESC, 3 DESC
    ) AS jb
ON a."imdb_name_id" = jb."imdb_name_id"
ORDER BY 4 DESC, 5 DESC;



/*
Questions 4, 5, and 6 will be similarly structured.
You can largely use the same query, but make small adjustments to answer each question.

Question 4
Find the top 5 movies rated higher by the Female 18-30 age group as compared to the Male 18-30 age group.
Use the females_18age_avg_vote and males_18age_avg_vote fields.
Only consider movies that have at least 10,000 votes from each of those demographic categories.
Show the original_title, females_18age_avg_vote, males_18age_avg_vote, and the delta between the two, aliased f_m_difference.
Sort by the difference (highest to lowest), then by original_title (alphabetically)
*/

SELECT m."original_title",
       r."females_18age_avg_vote",
       r."males_18age_avg_vote",
       r."females_18age_avg_vote" -  r."males_18age_avg_vote" AS f_m_difference
FROM movies m
INNER JOIN ratings r ON m.imdb_title_id = r.imdb_title_id
WHERE r.males_18age_votes >=10000 AND r.females_18age_votes >= 10000
ORDER BY 4 DESC,1
LIMIT 5;


/*
Question 5
Find the top 5 movies rated higher by the Male 18-30 age group as compared to the Female 18-30 age group.
Use the females_18age_avg_vote and males_18age_avg_vote fields.
Only consider movies that have at least 10,000 votes from each of those demographic categories.
Show the original_title, females_18age_avg_vote, males_18age_avg_vote, and the delta between the two, aliased m_f_difference.
Sort by the difference (highest to lowest), then by original_title (alphabetically)
*/

SELECT m."original_title",
       r."males_18age_avg_vote",
       r."females_18age_avg_vote",
       r."males_18age_avg_vote"- r."females_18age_avg_vote" AS f_m_difference
FROM movies m
INNER JOIN ratings r ON m.imdb_title_id = r.imdb_title_id
WHERE r.males_18age_votes >=10000 AND r.females_18age_votes >= 10000
ORDER BY 4 DESC,1
LIMIT 5;





/*
Question 6
Find the top 5 movies rated higher by the 45+ age group (both M/F) as compared to the 18-30 age group (both M/F).
Use females_18age_avg_vote, males_18age_avg_vote, females_45age_avg_vote, males_45age_avg_vote fields.
To create an average for an age group, just sum the M and the F avg_vote and divide by 2.

Only consider movies that have at least 10,000 votes from each of the 4 demographic categories.
Show the original_title, avg_vote_18_30, avg_vote_45plus, and the delta between the two.
Sort by the delta (highest to lowest), then by original_title (alphabetically)
*/

SELECT m.original_title,
       ((r.males_18age_avg_vote + r.females_18age_avg_vote)/2) AS avg_vote_18_30,
       ((r.males_45age_avg_vote+ r.females_45age_avg_vote)/2) AS avg_vote_45plus,
       ((r.males_45age_avg_vote+ r.females_45age_avg_vote)/2) - ((r.males_18age_avg_vote + r.females_18age_avg_vote)/2)
           AS delta
FROM movies m
LEFT JOIN ratings r ON m."imdb_title_id" = r."imdb_title_id"
WHERE r.females_18age_votes >=10000 AND r.males_18age_votes >= 10000
      AND r.males_45age_votes >= 10000 AND r.females_45age_votes >= 10000
ORDER BY 4 DESC,1 ASC
LIMIT 5;


/*
Question 7
Compare the heights of actors/actresses in basketball movies to non-basketball movies
A "basketball movie" is a movie with the word "basketball" in the description.
Only consider movies with at least 10,000 votes and people in the "actor" or "actress" categories.
Also filter to only actors/actresses that have a height listed.

In your results, return the following:
movie_type  (either "Basketball Movie" or "Non-Basketball Movie")
num_movies  (count of movies)
num_actors  (count of actors/actresses)
avg_height  (average height rounded to one decimal place)
*/

SELECT CASE WHEN m.description ILIKE '%basketball%' THEN 'Basketball Movie'
            ELSE 'Non-Basketball Movie' END AS movie_type,
       COUNT(DISTINCT m.imdb_title_id) AS num_movies,
       COUNT(DISTINCT h.actor_identity) AS num_actors,
       ROUND(AVG(h.height),1) AS avg_height
FROM movies m
LEFT JOIN (
    SELECT a.height AS height,
           tp.imdb_title_id AS movie_identity,
           tp.imdb_name_id AS actor_identity
    FROM actors a
    LEFT JOIN title_principals tp
    ON a.imdb_name_id = tp.imdb_name_id
    WHERE tp.category = 'actor'
       OR tp.category = 'actress'
    ) h
 ON m."imdb_title_id" = h.movie_identity
WHERE h.height IS NOT NULL
      AND m.votes>=10000
GROUP BY 1
ORDER BY 4 DESC;


/*
Question 8
Find the top 5 actresses in Drama movies as ranked by the average rating (rounded to 2 decimals) by the top 1000 reviewers
Provide the name, total_votes (by the top1000 voters), and avg_rating (by the top1000 voters)
Only consider the actresses with at least 10,000 total top 1000 votes (across all their movies)
Sort the output by the avg_rating (highest to lowest)
*/


SELECT a.name,
       SUM(r.top1000_voters_votes) AS total_votes,
       ROUND(AVG(r.top1000_voters_rating),2) AS avg_rating
FROM title_principals tp
INNER JOIN actors a ON tp.imdb_name_id = a.imdb_name_id
INNER JOIN movies m ON m.imdb_title_id = tp.imdb_title_id
INNER JOIN ratings r on m.imdb_title_id = r.imdb_title_id
WHERE tp.category = 'actress'
      AND m.genre LIKE '%Drama%'
GROUP BY 1
HAVING SUM(r.top1000_voters_votes) >= 10000
ORDER BY 3 DESC
LIMIT 5;



/*
 Question 9
 List the top 5 actors and actresses that have acted in the most 8+ movies as a % of their total 10,000+ vote movies
 (i.e. actors/actresses with the highest 8+ avg_vote rate)
 Only consider movies with at least 10,000 votes
 Only consider actors/actresses who have acted in at least 10 movies (with at 10K votes)

 Provide the following:
 name
 num_8plus_movies (count of movies with a >= 8 avg_vote and at least 10,000 votes)
 num_total_movies (count of movies with at least 10,000 votes)
 pct_8plus_movies (num_8plus_movies/num_total_movies rounded to 1 decimal place)
 */

SELECT a.name,
       COUNT(CASE WHEN vl.avg_vote >=8.0 THEN vl.imdb_title_id END) as num_8plus_movies,
       COUNT(vl.imdb_title_id) AS num_total_movies,
       ROUND(
           (CAST((COUNT(CASE WHEN vl.avg_vote >=8.0 THEN vl.imdb_title_id END)) AS NUMERIC)*100)/CAST((COUNT(vl.imdb_title_id)) AS NUMERIC)
           ,1) AS pct_8plus_movies
FROM actors a
LEFT JOIN (
    SELECT
         m.avg_vote,
         m.votes,
         tp.category,
         tp.imdb_title_id,
         tp.imdb_name_id
    FROM title_principals tp
    LEFT JOIN movies m ON m."imdb_title_id" = tp."imdb_title_id"
    WHERE tp.category = 'actress'
       OR tp.category = 'actor') vl
ON a.imdb_name_id = vl.imdb_name_id
WHERE vl.votes >=10000
GROUP BY 1
HAVING COUNT(vl.imdb_title_id) >= 10
ORDER BY 4 DESC
LIMIT 5;


/*
 Question 10
 List the top 10 movies by number of child actors in them.  Child actors are defined as actors/actresses with an age
 less than 18 on the date the movie was published (date_published).
 Sort the output by the num_child_actors (highest to lowest) and then by original_title (alphabetically)

 Only consider actors/actresses with a properly formatted date_of_birth (xxxx-xx-xx)
 Only consider movies with a properly formatted date_published (xxxx-xx-xx)
 Only consider movies with at least 10,000 votes

 Hint: Use the AGE function to find the difference between two timestamps.
 https://www.postgresql.org/docs/14/functions-datetime.html

 */

SELECT m.original_title,
       COUNT(al.imdb_title_id) AS num_child_actors
FROM movies m
LEFT JOIN(
    SELECT
          a.date_of_birth,
          tp.category,
          tp.imdb_title_id
    FROM actors a
    LEFT JOIN title_principals tp ON a.imdb_name_id = tp.imdb_name_id
    WHERE category = 'actor'
        OR category = 'actress') al
ON m.imdb_title_id = al.imdb_title_id
WHERE m.votes >= 10000
      AND m.date_published LIKE '____-__-__'
      AND al.date_of_birth LIKE '____-__-__'
      AND AGE(DATE(m.date_published),DATE(al.date_of_birth)) < '18 years'
GROUP BY 1
ORDER BY 2 DESC, 1
LIMIT 10;
