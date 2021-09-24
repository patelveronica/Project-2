# Beer Review Analysis

![hero_image.jpg](Images/hero_image.jpg)

### Backgroud

Beer is one of the oldest drinks humans have produced. The first chemically confirmed barley beer dates back to the 5th millennium BC in Iran, and was recorded in the written history of ancient Egypt and Mesopotamia and spread throughout the world. The word beer comes from old Germanic languages, and is with variations used in continental Germanic languages, bier in German and Dutch, but not in Nordic languages. The word was imported into the British Isles by tribes such as the Saxons. It is disputed where the word originally comes from.

### Rational:

Beer is an incredibly complex beverage containing more than 3000 different compounds, including carbohydrates, proteins, ions, microbes, organic acids, and polyphenols, among others. Beer becomes even more complex during storage, for over time it may undergo chemical changes that negatively affect the flavor, aroma, and appearance. Thus, it can be expected that maintaining the quality of beer throughout its lifetime is a difficult task. Since it is such a popular drink throughout the world, and based on the fact that consumers everyday require beers as a common beverage with specific enhanced flavor, aroma, appearance or even ABV% profiles, we got motivated to make ourselves familiar with proper data science analytic techniques for beer evaluation using the existence dataset of 1,048,575 that has discussed in Oreilly conference in 2017 to understand what are the factors that make a brand one of the top five highest-ranking beer styles in beer industry based on existed reviews.

### Data set

This is the dataset originally has discussed in the talk " How to hire and test for data skills: A one-size-fits-all interview kit" 
<a href = 'https://conferences.oreilly.com/strata/strata-ny-2017/public/schedule/detail/59542'>Link</a>

However, we have gotten the data set from Kaggle. 
<a href = 'https://www.kaggle.com/rdoume/beerreviews'>Link</a>

## The ETL Process

ETL stands for extract, transform, and load which are pillars to generate a good workflow build analysis upon.

1. We will need to import the dependencies that we need. We will be using pandas and sqlalchemy for our ETL as the dataset is a csv format. 

```sh
  import pandas as pd
  from sqlalchemy import create_engine
  # password for the local server that we will use to load the data. 
  from config import password
```

2. Extracting the data from the CSV

Next we will be using Pandas to extract the beer data from our CSV. 

```sh
    beer_df = pd.read_csv('Resources/beer_reviews.csv')
```

3. We will now transform the data to the tables that we can use and build upon.

We decided to create four separate tables to load into our data base for improve the efficiency working with the data so that new data can be inserted easily and data can be called in a logical way.

```sh
    # Main Data Tables

    # brewery_df will have all the brewery information, specifically the id, and the brewery name.
    brewery_df = beer_df[['brewery_id','brewery_name']].drop_duplicates(keep='first')
    # review_df will have all the various reviews for each of the beer id's or beer_beerid
    review_df = beer_df[['beer_beerid','review_overall','review_aroma','review_appearance','review_palate','review_taste','review_taste']].groupby('beer_beerid').mean().round(2)
    # beerid_df will have all the beer information such as name, style, and alcohol content for each beer_id
    beerid_df = beer_df[['beer_beerid','beer_name','beer_style','beer_abv']].drop_duplicates('beer_beerid', keep='first').set_index('beer_beerid').sort_index()
```

* The last table that we are creating will be joining the beerid table and the brewery table

```sh
    # beerid_breweryid_df will match beer_beerid to specific brewery id
    beerid_breweryid_df = beer_df[['brewery_id','beer_beerid']].drop_duplicates('beer_beerid').set_index('beer_beerid')
```

4. Setting up the database for loading.

* First we will create an EDR for the tables that we are going to build with the dataset.

![edr.jpeg](Images/Diagram.jpg)

* Then we will generate the tables with the following sql query:

```sh
BEGIN;


CREATE TABLE public.brewery
(
    brewery_id integer,
    brewery_name "char",
    PRIMARY KEY (brewery_id)
);

COMMENT ON TABLE public.brewery
    IS 'brewery_id as primary key';

CREATE TABLE public.beer
(
    beer_beerid bigint,
    beer_name text,
    beer_style text,
    beer_abv double precision,
    PRIMARY KEY (beer_beerid)
);

CREATE TABLE public.beer_brewery
(
    beer_beerid bigint,
    brewery_id bigint
);

CREATE TABLE public.review
(
    beer_beerid bigint,
    review_overall double precision,
    review_aroma double precision,
    review_appearance double precision,
    review_palate double precision,
    review_taste double precision
);

ALTER TABLE public.brewery
    ADD FOREIGN KEY (brewery_id)
    REFERENCES public.beer_brewery (brewery_id)
    NOT VALID;


ALTER TABLE public.beer
    ADD FOREIGN KEY (beer_beerid)
    REFERENCES public.review (beer_beerid)
    NOT VALID;


ALTER TABLE public.beer
    ADD FOREIGN KEY (beer_beerid)
    REFERENCES public.beer_brewery (beer_beerid)
    NOT VALID;

END;
```

5. Loading the table into a database

* the first thing we need to do is to start a connection to the local postgresql server that we will be using to load the data into. 

```sh
  engine = create_engine(f'postgresql://postgres:{password}@localhost/beer_db')
```

* Now we can insert the tables we need individually into the server.

```sh
    brewery_df.to_sql(name='brewery', con = engine, if_exists = 'append', index = True)
    review_df.to_sql(name='review', con = engine, if_exists = 'append', index = True)
    beerid_df.to_sql(name='beer', con = engine, if_exists = 'append', index = True)
    beerid_breweryid_df.to_sql(name='beer_brewery', con = engine, if_exists = 'append', index = True)
```

* After we insert all the tables, we can call the tables from the database to make sure that the process was done correctly.

```sh
engine.table_names()
# This should return a list: ['brewery','review','beer','beer_brewery]
```

* Now we can run some test queries to see if the information was loaded correctly.

```sh
  query = 'SELECT * FROM brewery'
  pd.read_sql_query(query, engine).head
  # this should pull the first 5 rows of the brewery table.
```

* Perform similar tests on the remaining tables. 

### Technologies

Our project dashboard consists of the following technologies:

* Database: PostgreSQL
* Data Visualization: Python ( Seaborn, Matplotlib)
* Programming Language: Python (scikit-learn, pandas, numpy, sql-alchemy)
* IDE tools: Jupyter Notebook

### Conclusion:

The five most popular beer styles were evaluated by grouping by the data frame by beer style and taking the mean of the aroma and appearance as well as the number of available reviews and maximum value in each category. This data is then organized by the number of ratings for aroma and appearance followed by average value and maximum value for both categories. In doing so, it was found that the most popular beer styles were, in descending order, American IPA, American Double / Imperial IPA, American Pale Ale (APA), Russian Imperial Stout, and American Double / Imperial Stout.

### Visualization Inspiration:

Seaborn heatmap has used in order to understand the role of each factors such as aroma, taste, appearance, palette and many other factors in determining the overall quality of a beer as follow:

![correlation.jpeg](Images/Corelation.jpg)

### Top Performing Beers

There are thousands of different beer style exists in this data set. For the ease of analyzing the dataset, we considered the top 10 beer brand that have more than 30K reviews to find the beers with top ratings in this dataset as follow:

![beer_review.jpeg](Images/Beer_reviews.jpg)
![beer_types_by_test.png](Images/Beer_types_by_taste.png)
