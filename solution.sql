--1. How many unique post types are found in the 'fact_content' table?
select distinct post_type
from fact_content

--2. What are the highest and lowest recorded impressions for each post type?
select 
	post_type,
	max(impressions) as highest_impressions,
    min(impressions) as lowest_impressions
from fact_content
group by post_type

--3. Filter all the posts that were published on a weekend in the month of March and April and export them to a separate csv file.
select
	c.*
from fact_content c
	join
	dim_dates d on d.date = c.date
where d.month_name in ("March", "April") and d.weekday_or_weekend = "Weekend"

/*4. Create a report to get the statistics for the account. The final output includes the following fields:
#	• month_name
#	• total_profile_visits
#	• total_new_followers*/
select
	d.month_name,
	sum(a.profile_visits) as total_profile_visits,
    sum(a.new_followers) as total_new_followers
from fact_account a
	join 
    dim_dates d on d.date = a.date
group by d.month_name

/*5. Write a CTE that calculates the total number of 'likes’ for each 'post_category' during the month of 'July' and subsequently, 
arrange the 'post_category' values in descending order according to their total likes.*/
select
	post_category,
	sum(likes) as total_likes
from fact_content
where month(date) = 7
group by post_category
order by total_likes desc

/*6. Create a report that displays the unique post_category names alongside
their respective counts for each month. The output should have three columns:
	• month_name
	• post_category_names
	• post_category_count
Example:
	• 'April', 'Earphone,Laptop,Mobile,Other Gadgets,Smartwatch', '5'
	• 'February', 'Earphone,Laptop,Mobile,Smartwatch', '4'*/
select
	d.month_name,
    group_concat(distinct post_category) as post_categories,
    count(distinct post_category) as post_categiry_count
from dim_dates d
	join
    fact_content c on d.date = c.date
group by d.month_name

/*7. What is the percentage breakdown of total reach by post type? The final
output includes the following fields:
	• post_type
	• total_reach
	• reach_percentage*/
select
	post_type,
    sum(reach) as total_reach,
    round((reach * 100 / sum(reach) over()), 2) as reach_percentage
from fact_content
group by post_type

/*8. Create a report that includes the quarter, total comments, and total
saves recorded for each post category. Assign the following quarter groupings:
	(January, February, March) → “Q1”
	(April, May, June) → “Q2”
	(July, August, September) → “Q3”
The final output columns should consist of:
	• post_category
	• quarter
	• total_comments
	• total_saves*/
select
	c.post_category,
	case
		when d.month_name in ("January", "February", "March") then "Q1"
        when d.month_name in ("April", "May", "June") then "Q2"
        when d.month_name in ("July", "August", "September") then "Q3"
	end as quarter,
    sum(comments) as total_comments,
    sum(saves) as total_saves
from fact_content c
	join
    dim_dates d on d.date = c.date
group by c.post_category, quarter

/*9. List the top three dates in each month with the highest number of new
followers. The final output should include the following columns:
	• month
	• date
	• new_followers*/
with cte as (select
	d.month_name,
    d.date,
    a.new_followers,
    dense_rank() over(partition by d.month_name order by a.new_followers desc) as drnk
from dim_dates d
	join
    fact_account a on a.date = d.date
)
select
	month_name,
    date,
    new_followers
from cte
where drnk <= 3

/*10. Create a stored procedure that takes the 'Week_no' as input and
generates a report displaying the total shares for each 'Post_type'. The
output of the procedure should consist of two columns:
	• post_type
	• total_shares*/
CREATE PROCEDURE `new_procedure` (in in_week_no varchar(3))
BEGIN
	select
		c.post_type,
        sum(c.shares) as total_shares
	from fact_content c 
		join
        dim_dates d on d.date = c.date
	where d.week_no = in_week_no
    group by c.post_type;
END
