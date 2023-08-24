#use mydatabase;

CREATE TABLE alltrans1
AS
SELECT * from trans2020 where totalcharges >0
union all 
select * from trans2021 where totalcharges >0
union all 
select * from trans2022 where totalcharges >0;

CREATE TABLE yeardummy1 AS
SELECT  CustID, year(orderDate) as year
FROM alltrans1
WHERE CustID IS NOT NULL
GROUP by  CustID, year
order by CustID;
select * from yeardummy limit 10;

ALTER TABLE yeardummy1
ADD column y2020 int,
add	column y2021 int,
ADD column y2022 int;


UPDATE yeardummy1
SET y2020 =
  CASE
    when `year` = 2020 THEN 1
    else 0
    end,
	y2021 = 
    CASE 
    when `year` = 2021 THEN 1 
    else 0 
    end,
    y2022 = 
    case 
    when `year` = 2022 then 1 
    else 0 
    end;
    
    
create table ordersperyear1 as 
SELECT custid,
       MAX(IF(`year` = 2020, 1, 0)) AS y2020,
       MAX(IF(`year` = 2021, 1, 0)) AS y2021,
       MAX(IF(`year` = 2022, 1, 0)) AS y2022
FROM yeardummy1
GROUP BY custid;


create table totalnumorders1 as 
select custid, count(distinct(ordernum)) as totalnumberoforders from alltrans1 group by custid;

CREATE TABLE transtotal1 AS 
SELECT alltrans1.custid, alltrans1.state, alltrans1.ordernum, alltrans1.orderdate, alltrans1.totalcharges, alltrans1.totalmisc, alltrans1.totaldiscount,
alltrans1.prodcode, 
       totalnumorders1.totalnumberoforders AS totalorders
FROM alltrans1 
JOIN totalnumorders1 ON alltrans1.custid = totalnumorders1.custid;


CREATE TABLE transfinal1 AS 
SELECT transtotal1.custid, transtotal1.state, transtotal1.ordernum, transtotal1.orderdate, transtotal1.totalcharges, transtotal1.totalmisc, transtotal1.totaldiscount,
transtotal1.prodcode, transtotal1.totalorders,
       ordersperyear1.y2020, ordersperyear1.y2021,ordersperyear1.y2022
FROM transtotal1 
JOIN ordersperyear1 ON transtotal1.custid = ordersperyear1.custid;


create table prodcodesfix1 as 
SELECT 
  t.custid, 
  t.orderdate, t.prodcode from
  transfinal1 t
JOIN 
  (SELECT 
     custid, 
     MIN(orderdate) AS min_orderdate
   FROM 
     transfinal1
   GROUP BY 
     custid
  ) t2 
ON 
  t.custid = t2.custid AND t.orderdate = t2.min_orderdate;
  
  
ALTER TABLE prodcodesfix1
ADD column Food int,
add	column Sliced int,
ADD column    Cookware int,
  ADD column  Bath int,
 ADD column   Ceramics int,
  ADD column  Book int,
 ADD column   Donation int,
  ADD column  Shipmat int,
  ADD column  Giftcard int;
  
  
UPDATE prodcodesfix1
SET Giftcard =
  CASE
    WHEN prodcode = 'Giftcard' THEN 1
    else 0
    end;  
    
create table prodcodesforjoin1 as 
SELECT custid, orderdate,
       MAX(IF(Food = 1, 1, 0)) as food,
       MAX(IF(Sliced = 1, 1, 0)) as sliced,
       MAX(IF(Cookware = 1, 1, 0)) as cookware,
       MAX(IF(Ceramics = 1, 1, 0)) as ceramics,
       MAX(IF(Donation = 1, 1, 0)) as donations,
       MAX(IF(Bath = 1, 1, 0)) as bath,
       MAX(IF(Book = 1, 1, 0)) as book,
       MAX(IF(Shipmat = 1, 1, 0)) as shipmat,
       MAX(IF(Giftcard = 1, 1, 0)) as giftcard
FROM prodcodesfix1
GROUP BY custid
order by orderdate;


create table finalforjoin1 as 
select custid, state, min(orderdate) as orderdate, totalcharges, totalmisc, totaldiscount, totalorders, y2020,
y2021, y2022 from transfinal1 group by custid order by custid;


CREATE TABLE finaldata1 AS
SELECT finalforjoin1.custid, finalforjoin1.state, finalforjoin1.orderdate, finalforjoin1.totalcharges, 
finalforjoin1.totalmisc, finalforjoin1.totaldiscount, finalforjoin1.totalorders, finalforjoin1.y2020,
finalforjoin1.y2021, finalforjoin1.y2022, prodcodesforjoin1.food,
prodcodesforjoin1.sliced, prodcodesforjoin1.ceramics, prodcodesforjoin1.cookware, prodcodesforjoin1.donations,
prodcodesforjoin1.bath, prodcodesforjoin1.book, prodcodesforjoin1.shipmat, prodcodesforjoin1.giftcard
FROM finalforjoin1
JOIN prodcodesforjoin1 ON finalforjoin1.custid = prodcodesforjoin1.custid
ORDER BY finalforjoin1.custid;



ALTER TABLE finaldata1
ADD COLUMN Transportation VARCHAR(255);

Update finaldata1 
  set Transportation = CASE 
    WHEN state IN ('AK', 'AR', 'CA', 'AZ', 'CO', 'HI', 'ID', 'KS', 'LA', 'MN', 'MO', 'MS', 'MT', 'NM', 'ND', 'NE', 'NV', 'OK'
    'OR', 'PR', 'SD', 'TX', 'UT', 'WA', 'WY') THEN 'AIR' 
    ELSE 'GROUND' 
END;

ALTER TABLE finaldata1
ADD column Jan int,
add	column Feb int,
ADD column March int,
  ADD column May int,
 ADD column  Apr int,
  ADD column  Jun int,
 ADD column   July int,
  ADD column  Aug int,
  ADD column  Sept int,
  ADD column   Octo int,
  ADD column  Nov int,
  ADD column  Dece int;
  
  UPDATE finaldata1
SET Jan =
  CASE
    WHEN month(orderdate) = 1 THEN 1
    else 0
    end,
    Feb = 
    CASE
    WHEN month(orderdate)  = 2 THEN 1
    else 0
    end,
   March = 
    CASE
    WHEN month(orderdate)  = 3 THEN 1
    else 0
    end,
 Apr = 
    CASE
    WHEN month(orderdate)  = 4 THEN 1
    else 0
    end,
 May = 
    CASE
    WHEN month(orderdate)  = 5 THEN 1
    else 0
    end,
  Jun = 
    CASE
    WHEN month(orderdate)  = 6 THEN 1
    else 0
    end,
 July = 
    CASE
    WHEN month(orderdate)  = 7 THEN 1
    else 0
    end,
 Aug = 
    CASE
    WHEN month(orderdate)  = 8 THEN 1
    else 0
    end,
 Sept = 
    CASE
    WHEN month(orderdate)  = 9 THEN 1
    else 0
    end,
     Octo = 
    CASE
    WHEN month(orderdate)  = 10 THEN 1
    else 0
    end,
     Nov = 
    CASE
    WHEN month(orderdate)  = 1 THEN 1
    else 0
    end,
     Dece = 
    CASE
    WHEN month(orderdate)  = 12 THEN 1
    else 0
    end;
    
    
alter table finaldata1
add column competitors int;    


Update finaldata1 
  set competitors = CASE 
    WHEN state IN ('MI', 'IL', 'NH', 'AZ', 'NY', 'CA', 'FL', 'TX') THEN 1 
    ELSE 0
END;


alter table finaldata1 drop column custid, drop column orderdate;

alter table finaldata1 change totalorders retention int;

UPDATE finaldata1
SET retention =
  CASE
    WHEN retention = 1 THEN 0
    else 1
    end;
    
    
select * from finaldata1 limit 10; 