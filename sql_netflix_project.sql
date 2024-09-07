-- netflix project
drop table if exists netflix;
create table netflix
(
show_id varchar(6),
type varchar(10),
title varchar(150),
director varchar(208),
casts varchar(1000),
country varchar(150),
date_added varchar(50),
release_year int,
rating varchar(10),
duration varchar(15),
listed_in varchar(100),
description varchar(250)
);
select * from netflix;
select count(*) from netflix;
select count(distinct type) from netflix;
--1.count of number of movies vs seriesl/shows:
select type,count(*) as total_content
from netflix
group by type;

--2.find the most common ratings for movies and shows:
select type,rating from (



	select type,
	rating ,
	count(*),
	rank()over(partition by type order by count(*) desc) as rating_rank
	from netflix

	group by 1,2) as t1
where rating_rank=1


--3.list of all movies released in specific year:
select * from netflix
where type ='Movie' and release_year=2020

---4.find the top 5 countries with the most content on netflix :
select UNNEST(STRING_TO_ARRAY (country,',')), count(show_id) as total_content from netflix
group by country
order by count(*) desc
limit 5
	
select 
 UNNEST(STRING_TO_ARRAY (country,',')) from netflix;

--- 5.Identify the longest movies list
select  * 
from netflix
where 
	duration =(select max(duration) from netflix) 
	and 
	type='Movie'


-- 6.identify the content added in last 5 years 
select *
	from netflix 
where TO_DATE(date_added,'Month,DD,YYYY')>=current_date - interval '5 years'

--7.list the movies/shows directed by 'rajiv chilaka'

select * from netflix where
director ilike '%Rajiv chilaka%'
--8.list of all tv shows having seasons more than 5
select *,
	split_part(duration,' ',1) as seasons
	from netflix

where type='TV Show' and 
split_part(duration,' ',1)::numeric>5


--9.count the number of content in each gerner:
select 
	count(show_id),
	unnest(STRING_TO_ARRAY(listed_in,',')) as gerner
	from netflix
	GROUP BY listed_in;
	
--10.find the each year and the average number of content release in india on netflix:
select 
	count(*),
	EXTRACT(YEAR from TO_Date(date_added,'Month,DD,YYYY')) as year,
	round(count(*)::numeric/(select count(*)::numeric from netflix where country='India'),2)*100 as average_content_per_year
	from netflix
where country='India'
GROUP BY 2
order by count(*);

--11.list all the movies that are documentries:
select * 
from netflix
where listed_in ilike '%documentaries%'

--12.find all the content without any director:

select * from netflix
where director is NULL;


--13.LIST THE ALL MOVIES ACTOR 'SULMAN KHAN ' APPEARED IN LAST 10 YEARS:
select * from netflix 
where 
	casts ilike '%salman khan%' 
	and 
	release_year>extract(year from current_date)-10
	
--14.find the top 10 actors who have appeard in the highes number of movieds produced in india

select 
	unnest(string_to_array(casts,',')),
	count(* )as total_content
	from netflix
	where country ilike '%india%'
	group by 1
	order by 2 desc
	limit 10
	
--15.categorize the content based on the key words 'kill','violence' in description as "bad",
--and other as "good"  and count the number of films fall in each category:
with new_table
as(
	select *,
	case
	when 
	description ilike '%kill%'
	 or 
	 description ilike '%violence%' then 'bad'
	 else 'good' end Category
	 from netflix
)
	select 
	category,
	count(*) as total_content 
	from new_table
	group by 1;



