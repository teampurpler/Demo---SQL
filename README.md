# Demo---SQL
SQL tutorial for beginners/advanced-level-learners

NOTE: Data base from Kaggle



The main takeaways in this demo1:

1. Renaming
- AS operator 
  - change column names
  - change table names
  - Example: 
       - SELECT old_column AS new_column 
note: you can also skip the operator but this is not recommended as it makes the query more difficult to read

2. Creating new columns and basic math operations
 - Instead of selecting a column from a table, you can put down a single value like a number or a string
 - Note that no new rows are being generated
 - Data can also be manipulated on a row-by-row basis using mathematical functions in the SELECT
         - Standard mathematical functions are all supported (+, -, *, /)

3. Queries without a FROM clause
 - SQL doesn’t require a FROM clause 
     - Useful for testing
 - You can also create “singletons” in SQL, which are queries that return a single value only
      - Singletons can be used as if it were that value


4. String Functions
LEFT(string, x)  =>  Take x characters from the left of the string
RIGHT(string, x) => Take x characters from the right of the string
LOWER(string) =>  Convert all characters of the string to lowercase
UPPER(string) =>  Convert all characters of the string to uppercase
LENGTH(string) =>  Return the length of a string
TRIM(string) => Remove whitespace from the start and end of a string
CONCAT(string1, string2, string3…) => Concatenate 2 or more strings into 1 string


5. More Math Functions
ABS(x) =>  Return the absolute value of x
ROUND(x, n) =>  Return x rounded to n decimal places 
LEAST(x, y, z, …) => Return the smallest value of the input numbers
GREATEST(x, y, z …) => Return the greatest value of the input numbers

6. Integer division and casting 
- In most variants of SQL, dividing one integer by another will result in an integer
      - This must be paid attention to when calculating fractions, as you will not get a float
      - In the cases where you want a float, you should either multiply by a float (e.g. 1.0) or cast the numerator or denominator to a float or a decimal before dividing
 - column_name::FLOAT
 - column_name::DECIMAL
 - CAST(column_name AS FLOAT)
 - CAST(column_name AS DECIMAL)


7. Query Evaluation Order
WHERE happens before SELECT
 -  For efficiency, the WHERE clause filters the source data first
 - Then, the SELECT clause acts on the filtered data
 - Thus, any columns defined in the SELECT are not available in the WHERE clause


8. BETWEEN, LIKE and ILIKE 
col_name BETWEEN x AND y 
     - Returns TRUE for any values between x and y inclusive
     - Equivalent to 
           col_name >= x AND col_name <= y
 - col_name LIKE ‘%string%’
      -  Allows the use of wildcards to match strings
              - %  matches 0 or more of any character
              - _ matches exactly one of any character
 - col_name ILIKE ‘%string%’
              - Similar to LIKE but is case insensitive

9 . CASE statement 
Conditional transformations
       -  Use to create a new column based on conditional logic
CASE WHEN <insert condition> THEN <value>
	   WHEN <insert condition> THEN <value>
	   …….
	   ELSE <value> END AS new_column_name
Secondary syntax
CASE <column_name>
	WHEN <equality_value> THEN <value>
	WHEN <equality_value> THEN <value>
	....
	END AS new_column_name


10. DISTINCT
DISTINCT operator is used to remove duplicates in result data
Syntax
SELECT DISTINCT
	col1,
	col2,
	…
Returns a distinct set of the combination of the columns in the SELECT statement.  DISTINCT can operate on one or more columns.


11. More filtering 
Compare column_name against multiple values
WHERE
		column_name IN (x, y, z, …)
WHERE
		column_name NOT IN (x, y, z…)	
	WHERE
		column_name IN (SELECT some_column FROM some_table)



  
  
	
	
	
	
	
	
	
	
	
        
        
        
        
        
	
  

The main takeaways from this demo2 :

1. CRUD Operations
All databases need to be able to handle 4 basic operations, abbreviated CRUD
- Create
    - CREATE: Creates a container for data to be stored (e.g. a table)
    - INSERT: Put data into that container
    - COPY: Bulk data loading
- Read
    - SEL
  ECT: Primary way of retrieving data from a database
    - Update
    - UPDATE: Change data within a table
- ALTER: Change the structure of a table
    - Delete
    - DROP: Remove a database object
    - DELETE: Remove data from a table

2. GROUP BY
- Aggregate data into specified groups
- Scans multiple rows and collapses them into a single aggregate value
- How does it work?
    - Combine rows that have the same value for the grouping variable
    - Use an aggregate function (e.g. SUM, AVG, COUNT … ) to collapse/summarize the other columns of interest into a single value for the group
    - In the SELECT, all columns are either 1) part of the group or 2) being aggregated.
    - Applied after the WHERE clause
         - Rows are filtered out first
         - Then aggregated
    - The result will always have one row per group
    - Groups can consist of one or more columns 

3. Common Aggregation Functions
COUNT
    - COUNT(1) or COUNT(*): Counts the number of rows
    - COUNT(col_name): Counts the number of Non-NULL values in col_name
    - COUNT(DISTINCT col_name):
          - Counts the number of distinct Non-NULL values in col_name
SUM
    - SUM(col_name): Sums the values in col_name
AVG
    - AVG(col_name): Averages the values in col_name
MAX/MIN
   - MAX(col_name): Return the maximum value in col_name
   - MIN(col_name): Return the minimum value in col_name

4. NULL values and Aggregations
If one of the grouping column values is NULL …
    - NULL is treated as a group value and all NULLs are grouped together
If NULLs are aggregated
    - SUM, MAX, MIN, COUNT(col_name), COUNT(DISTINCT col_name)
        - NULLs are ignored
    - COUNT(1) or COUNT(*)
        - NULLs are counted

5. CASE statements and Aggregations
CASE statements can be used to create new groups
    - Transform existing columns/dimensions into new ones to categorize the data in new ways

CASE statements can be used inside an aggregation to only selectively aggregate
    - Useful for calculating % of total
        - SUM(CASE WHEN brand = ‘Toyota’ THEN sales ELSE 0 END) * 100.0 / SUM(sales)

6. Multiple levels of aggregation
Sometimes you need an aggregation on top of another aggregation.
Example: What is the highest average selling price among car models?

Solution: Use a subquery to do the first aggregation (average price in the example above). Then
aggregate the result of the subquery in the outer query with a second aggregation (maximum of the
average price in the example above)

7. HAVING clause
HAVING is a post-aggregation filter
    - This is in contrast to WHERE, which is a pre-aggregation filter
    - In other words, WHERE filters rows and HAVING filters groups
    - Typically, use an aggregation-based filter in HAVING
    - e.g. HAVING COUNT(1) > 1

8. DATE data types
Dates are the least standardized part of SQL
Date data types:
        - DATE: Stores a date e.g. 2021-01-01
        - TIME: Stores a time
        - TIMESTAMP: Stores a date and a time
              - e.g. 2021-01-01 01:59:42.892321 +00:00
              - Sidenote: You may see “timestamps” in data that look like this 1636274895
              - This is unixtime. It represents the number of elapsed seconds from 1970-01-01 and is used to make time-based calculations more convenient
        - INTERVAL: Stores a time interval e.g. 1 year or 3 seconds

9. DATE functions

NOW() : Returns the current timestamp
CURRENT_DATE : Returns the current date
CURRENT_TIME : Returns the current time
DATE_PART(part_string ,date) : Extracts a particular part of the date or time
DATE_TRUNC(granularity, date) : Truncates a date or timestamp to a certain precision
Intervals are used to add or subtract time information e.g SELECT ‘2021-01-01’::DATE + ‘1 day’::INTERVAL
