-- Create artist table
CREATE TABLE artist(
	artist_id INTEGER PRIMARY KEY UNIQUE,
	full_name VARCHAR(200) UNIQUE,
	first_name VARCHAR(50) NOT NULL,
	middle_names VARCHAR(100),
	last_name VARCHAR(50) NOT NULL,
	nationality VARCHAR(50),
	style_name VARCHAR(50),
	birth SMALLINT,
	death SMALLINT
);

-- Taking a look at the artist table
SELECT * FROM artist;

-- Create canvas_size table
CREATE TABLE canvas_size(
	size_id INTEGER PRIMARY KEY UNIQUE,
	width INTEGER,
	height INTEGER,
	canvas_label VARCHAR(50)
);

-- Create image_link table
CREATE TABLE image_link(
	work_id INTEGER,
	url VARCHAR(500),
	thumbnail_small_url VARCHAR(500),
	thumbnail_large_url VARCHAR(500)
);

-- Create museum table
CREATE TABLE museum(
	museum_id INTEGER PRIMARY KEY UNIQUE,
	museum_name VARCHAR(100),
	address VARCHAR(50),
	city VARCHAR(50),
	state_name VARCHAR(50),
	postal VARCHAR(50),
	country VARCHAR(50),
	phone VARCHAR(50),
	url VARCHAR(100)
);

-- CREATE TABLE museum hours
CREATE TABLE museum_hours(
	museum_id INTEGER,
	day_name VARCHAR(20),
	open_time TIME,
	close_time TIME
);

-- Needed to convert format on CSV for open_time and close_time from HH:MM:AM/PM to HH:MM 24 hour 

-- Create product size table
CREATE TABLE product_size(
	work_id INTEGER,
	size_id INTEGER,
	sale_price DECIMAL,
	regular_price DECIMAL
);

-- Create subject table
CREATE TABLE subject(
	work_id INTEGER,
	subject VARCHAR(50)
);

-- Create work table
CREATE TABLE work_desc(
	work_id INTEGER PRIMARY KEY UNIQUE,
	work_name VARCHAR(150),
	artist_id INTEGER,
	work_style VARCHAR(100),
	museum_id INTEGER
);

-- Needed to convert all commas on csv to semicolons to import successfully
-- Needed to remove duplicate work id values

-- Add foreign key constraints
ALTER TABLE image_link
ADD CONSTRAINT fk_work_id
FOREIGN KEY(work_id) REFERENCES work_desc(work_id);

ALTER TABLE museum_hours
ADD CONSTRAINT fk_museum_id
FOREIGN KEY(museum_id) REFERENCES museum(museum_id);

ALTER TABLE product_size
ADD CONSTRAINT fk_work_id
FOREIGN KEY(work_id) REFERENCES work_desc(work_id);

-- Cannot create a foreign key constraint for size_id as there are missing values in the canvas_size table:
--ALTER TABLE product_size
--ADD CONSTRAINT fk_size_id
--FOREIGN KEY(size_id) REFERENCES canvas_size(size_id);

-- Show all artists who have the first name James
SELECT * FROM artist
WHERE first_name = 'James';

-- How many artists do not have a middle name
SELECT COUNT(*) FROM artist
WHERE middle_names IS NULL;

-- Show all the realist arists that have an artist_id number between 600 and 700
SELECT * FROM artist
WHERE artist_id BETWEEN 600 AND 700
AND style_name = 'Realist';

-- Who were the 5 first German artists by birth date
SELECT * FROM artist
WHERE nationality = 'German'
ORDER BY birth
LIMIT 5;

-- What museums are in Russia
SELECT museum_name FROM museum
WHERE country = 'Russia';

-- What is the url for the Philadelphia Museum of Art
SELECT url FROM museum
WHERE museum_name = 'Philadelphia Museum of Art';

-- How many museums are in the USA
SELECT COUNT(*) FROM museum
WHERE country = 'USA';

-- What is the width and height in inches of size_id 2126
SELECT width, height FROM canvas_size
WHERE size_id = 2126;

-- Return opening and closing times for museums on a Saturday
SELECT museum.museum_id, museum_name, country, open_time, close_time
FROM MUSEUM
INNER JOIN museum_hours
ON museum.museum_id = museum_hours.museum_id
WHERE day_name = 'Saturday';

-- Return the opening and closing times for museums that are open after 6pm on a Saturday
SELECT museum.museum_id, museum_name, country, open_time, close_time
FROM MUSEUM
INNER JOIN museum_hours
ON museum.museum_id = museum_hours.museum_id
WHERE day_name = 'Saturday'
AND close_time > '18:00';

-- Finding the discount and percentage discount per product, then rank by the highest discounts given
SELECT work_id, size_id, sale_price, regular_price, 
regular_price - sale_price AS discount,
ROUND(((regular_price - sale_price)/regular_price) * 100,1) AS percent_discount
FROM product_size
ORDER BY DISCOUNT DESC;

-- Using a join to include the work name
SELECT work_name, size_id, sale_price, regular_price, 
regular_price - sale_price AS discount,
ROUND(((regular_price - sale_price)/regular_price) * 100,1) AS percent_discount
FROM product_size ps
INNER JOIN work_desc wd
ON ps.work_id = wd.work_id
ORDER BY DISCOUNT DESC;

-- Using a left join to include the canvas label
SELECT work_name, canvas_label, sale_price, regular_price, 
regular_price - sale_price AS discount,
ROUND(((regular_price - sale_price)/regular_price) * 100,1) AS percent_discount
FROM product_size ps
INNER JOIN work_desc wd
ON ps.work_id = wd.work_id
LEFT JOIN canvas_size cs
ON ps.size_id = cs.size_id
ORDER BY DISCOUNT DESC;

-- Using a group by to find the count of each style, order by COUNT - highest to lowest
SELECT style_name, COUNT(style_name)
FROM artist
GROUP BY style_name
ORDER BY COUNT(style_name) DESC;

-- Using a group by to find the count of each style name for each nationality, order by nationality ASC, then by count of style name DESC
SELECT nationality, style_name, COUNT(style_name)
FROM artist
GROUP BY nationality, style_name
ORDER BY nationality, COUNT(style_name) DESC;

-- How many non-null sizes are available for each work_id
SELECT *, 
COUNT(size_id) OVER(PARTITION BY work_id) AS sizes_available
FROM product_size
ORDER BY work_id, size_id;

-- Using joins to include the work name and canvas label
SELECT work_name, canvas_label, sale_price, regular_price, 
COUNT(ps.size_id) OVER(PARTITION BY ps.work_id) AS sizes_available
FROM product_size ps
LEFT JOIN work_desc wd
ON ps.work_id = wd.work_id
LEFT JOIN canvas_size cs
ON ps.size_id = cs.size_id
ORDER BY ps.work_id, ps.size_id;