/*S1.Q1*/
WITH t1 AS
		(SELECT f.title title, c.name category, r.rental_date rented
		  FROM  film f
		  JOIN  film_category fc
			  ON  f.film_id = fc.film_id
		  JOIN  category c
			  ON  fc.category_id = c.category_id
		  JOIN  inventory i
			  ON  i.film_id = f.film_id
		  JOIN  rental r
			  ON  r.inventory_id = i.inventory_id)

  SELECT title, category, COUNT(rented) rental_count
  FROM   t1
  WHERE  category IN ('Animation','Children','Classics','Comedy','Family','Music')
GROUP BY 1, 2
ORDER BY 3 DESC
LIMIT 10;

/*S1.Q2*/
WITH t1 AS
		(SELECT f.title title, c.name category,
		 		    DATE_TRUNC('day', r.return_date) - DATE_TRUNC('day', r.rental_date) rental_time
		  FROM  film f
		  JOIN  film_category fc
			  ON  f.film_id = fc.film_id
		  JOIN  category c
			  ON  fc.category_id = c.category_id
		  JOIN  inventory i
			  ON  i.film_id = f.film_id
		  JOIN  rental r
			  ON  r.inventory_id = i.inventory_id
	GROUP BY  1, 2, 3, r.return_date),

    t2 AS
   (SELECT DISTINCT title, category, rental_time, SUM(rental_time) OVER (PARTITION BY category) tot_rental_time
      FROM t1
     WHERE category IN ('Animation','Children','Classics','Comedy','Family','Music')
  GROUP BY 1, 2, 3)

  SELECT DISTINCT category, tot_rental_time, AVG(rental_time) avg_rental_time
    FROM t2
GROUP BY 1, 2
ORDER BY 2 DESC;

/*S1.Q3*/
WITH t1 AS
		(SELECT c.name category, f.rental_duration rent_durat,
		 		 NTILE(4) OVER (ORDER BY f.rental_duration) standard_tiles
		  FROM  film f
		  JOIN  film_category fc
			  ON  f.film_id = fc.film_id
		  JOIN  category c
			  ON  fc.category_id = c.category_id
      ORDER BY 3)

 SELECT category, standard_tiles,
     	 COUNT(category) cat_tile_count
   FROM  t1
WHERE  category IN ('Animation','Children','Classics','Comedy','Family','Music')
GROUP BY 1, 2
ORDER BY 1, 2;

/*S2.Q1*/
WITH t1 AS (SELECT DATE_PART('month', rental_date) AS rental_month,
		DATE_PART('year', rental_date) AS rental_year,
		s.store_id store_id,
		COUNT(rental_id) count_rentals
FROM	store s
JOIN	customer c
ON		c.store_id = s.store_id
JOIN	rental r
ON		r.customer_id = c.customer_id
GROUP BY rental_date, 3
ORDER BY 2, 1)

SELECT rental_month, rental_year, store_id, SUM(count_rentals)
FROM t1
GROUP BY 1, 2, 3
ORDER BY 2, 1;
