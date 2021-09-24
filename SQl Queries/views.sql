-- identify duplicate rows in each table
select beer_id, brewery_id, beer_name,beer_style, count(*)
from beer group by beer_id, brewery_id, beer_name,beer_style
having count(*) > 1;

-- -- -- -- -- -- -- -- -- 
select brewery_id, brewery_name, count(*)
from brewery group by brewery_id, brewery_name
having count(*) > 1;

-- -- -- -- -- -- -- -- -- -- -- -- -- 
select beer_id, brewery_id, count(*)
from reviews group by  beer_id, brewery_id
having count(*) > 1;
-- -- -- -- -- -- -- Find which Brewery produce max ABV%
select max(beer.beer_abv) as highest_abv, beer.beer_id, brewery.brewery_name from beer
join brewery on beer.brewery_id = brewery.brewery_id
group by beer_id,brewery_name order by highest_abv desc; 

-- -- -- find top 5 beer_id based on Max overall_review
select beer.beer_id, beer.beer_name,reviews.review_overall from beer
inner join reviews on beer.beer_id = reviews.beer_id
order by reviews.review_overall desc;

-- -- -- find top 10 beer_id based on Max overall_review
create view overall_review as Select beer_id, brewery_id, review_overall from reviews order by review_overall desc limit 10;

-- -- -- find top 10 beer_id based on Max review_aroma
create view review_aroma select beer_id, brewery_id, review_aroma from reviews order by review_aroma desc limit 10;

-- -- -- find top 10 beer_id based on Max review_appearance
create view review_appearance select beer_id, brewery_id, review_appearance from reviews order by review_appearance desc limit 10;

-- -- -- find top 10 beer_id based on Max review_palate
create view review_palate select beer_id, brewery_id, review_palate from reviews order by review_palate desc limit 10;

-- -- -- find top 10 beer_id based on Max review_taste
create view review_taste select beer_id, brewery_id, review_taste from reviews order by review_taste desc limit 10;

