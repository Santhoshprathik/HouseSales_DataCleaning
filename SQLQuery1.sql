

--DATA CLEANING QUERIES
--where
--projects==database
--Housetable==tablename
------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------

--1. STANDARDIZE DATE FORMAT

------------------------------------------------------------------------------------------------------------------
--To get complete table

SELECT * FROM projects..Housetable

------------------------------------------------------------------------------------------------------------------
-- add new column dateofsale to table

ALTER TABLE Housetable
ADD  dateofsale Date;

------------------------------------------------------------------------------------------------------------------
-- add converted values to new column from old column

UPDATE Housetable
SET dateofsale = CONVERT(Date, SaleDate)

------------------------------------------------------------------------------------------------------------------
-- delete old column

ALTER TABLE Housetable
DROP COLUMN SaleDate;

------------------------------------------------------------------------------------------------------------------
--rename new column to old column name
--syntax for ms sql server is different from mysql

sp_rename 'Housetable.dateofsale','SaleDate', 'column';

------------------------------------------------------------------------------------------------------------------
--check table

select * from Housetable


------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------

--2. populate property adress

------------------------------------------------------------------------------------------------------------------

--get full table

SELECT * FROM projects..Housetable

------------------------------------------------------------------------------------------------------------------
--select rows where property adress is null

SELECT * FROM projects..Housetable 
WHERE PropertyAddress is NULL

------------------------------------------------------------------------------------------------------------------
-- selft joint 

SELECT a.ParcelID, b.ParcelID, a.PropertyAddress,b.PropertyAddress 
FROM projects..Housetable a
JOIN projects..Housetable b
     ON a.ParcelID = b.ParcelID
	 AND a.[UniqueID ]<> b.[UniqueID ]

------------------------------------------------------------------------------------------------------------------
--create new column 
SELECT a.ParcelID, b.ParcelID, a.PropertyAddress,b.PropertyAddress ,ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM projects..Housetable a
JOIN projects..Housetable b
     ON a.ParcelID = b.ParcelID
	 AND a.[UniqueID ]<> b.[UniqueID ]


------------------------------------------------------------------------------------------------------------------
-- update propertyadress column in the table

UPDATE a
SET PropertyAddress= ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM projects..Housetable a
JOIN projects..Housetable b
     ON a.ParcelID = b.ParcelID
	 AND a.[UniqueID ]<> b.[UniqueID ]

------------------------------------------------------------------------------------------------------------------
--check table
SELECT * 
FROM projects..Housetable
WHERE PropertyAddress IS NULL

------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------

--3.split address to city,state
------------------------------------------------------------------------------------------------------------------
-- formulae to split

SELECT
SUBSTRING (PropertyAddress, 1, CHARINDEX(',',PropertyAddress)-1) as Address,
SUBSTRING (PropertyAddress, CHARINDEX( ',', PropertyAddress)+1, LEN(PropertyAddress)) as City

FROM projects..Housetable

------------------------------------------------------------------------------------------------------------------
 -- create dummy columns and update with these two columns

ALTER TABLE Projects..Housetable
ADD SplitAddress Nvarchar(255);

 UPDATE Projects..Housetable
 SET SplitAddress= SUBSTRING (PropertyAddress, 1, CHARINDEX(',',PropertyAddress)-1) 


ALTER TABLE Projects..Housetable
ADD SplitCity Nvarchar(255);

 UPDATE Projects..Housetable
 SET SplitCity= SUBSTRING (PropertyAddress, CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress))

 ------------------------------------------------------------------------------------------------------------------
 --split owner adress

 SELECT *
 FROM projects..Housetable
 where SplitOwnerAddress is not NULL
 order by SplitOwnerAddress

 ------------------------------------------------------------------------------------------------------------------
 --get splited adresses

 SELECT 
 PARSENAME( REPLACE(OwnerAddress,',','.'),1),
 PARSENAME( REPLACE(OwnerAddress,',','.'),2),
 PARSENAME( REPLACE(OwnerAddress,',','.'),3)
 FROM projects..Housetable

 ------------------------------------------------------------------------------------------------------------------
 --create dummy columns and insert

 ALTER TABLE Projects..Housetable
 ADD SplitOwnerAddress Nvarchar(255);

 UPDATE projects..Housetable
 SET SplitOwnerAddress = PARSENAME( REPLACE(OwnerAddress,',','.'),1) 

 ALTER TABLE Projects..Housetable
 ADD Ownercity Nvarchar(255);

 UPDATE projects..Housetable
 SET Ownercity = PARSENAME( REPLACE(OwnerAddress,',','.'),2) 

 ALTER TABLE Projects..Housetable
 ADD Owneradd Nvarchar(255);

 UPDATE projects..Housetable
 SET Owneradd = PARSENAME( REPLACE(OwnerAddress,',','.'),3)

 ------------------------------------------------------------------------------------------------------------------
 ------------------------------------------------------------------------------------------------------------------

 --3. change n to no and y to yes

 ------------------------------------------------------------------------------------------------------------------

 --case statement to change n to no and y to yes
 SELECT SoldAsVacant,
 CASE WHEN SoldAsVacant = 'Y' THEN 'YES'
      WHEN SoldAsVacant = 'N' THEN 'NO'
	  ELSE SoldAsVacant
	  END
FROM projects..Housetable

------------------------------------------------------------------------------------------------------------------

--update the column in the table
UPDATE projects..Housetable
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'YES'
      WHEN SoldAsVacant = 'N' THEN 'NO'
	  ELSE SoldAsVacant
	  END
FROM projects..Housetable

------------------------------------------------------------------------------------------------------------------

--check the distinct no and yes

select distinct(SoldAsVacant), COUNT(SoldAsVacant)
FROM projects..Housetable
group by SoldAsVacant
------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------
--4. Remove duplicates

--show all
SELECT * 
FROM projects..Housetable

------------------------------------------------------------------------------------------------------------------

-- give number of similar rows 

SELECT *,
ROW_NUMBER () OVER (
PARTITION BY ParcelID,
             PropertyAddress,
			 SalePrice,
			 LegalReference,
			 OwnerName
			 ORDER BY UniqueID
			 ) row_num

FROM projects..Housetable

------------------------------------------------------------------------------------------------------------------

--push above table into duplicate table

WITH row_CTE AS(
SELECT *,
ROW_NUMBER () OVER (
PARTITION BY ParcelID,
             PropertyAddress,
			 SalePrice,
			 LegalReference,
			 OwnerName
			 ORDER BY UniqueID
			 ) row_num

FROM projects..Housetable)
SELECT *
FROM row_CTE

------------------------------------------------------------------------------------------------------------------

-- from new table get allduplicate rows

WITH row_CTE AS(
SELECT *,
ROW_NUMBER () OVER (
PARTITION BY ParcelID,
             PropertyAddress,
			 SalePrice,
			 LegalReference,
			 OwnerName
			 ORDER BY UniqueID
			 ) row_num

FROM projects..Housetable)
SELECT *
FROM row_CTE
WHERE row_num >1

------------------------------------------------------------------------------------------------------------------

--Delete duplicates

WITH row_CTE AS(
SELECT *,
ROW_NUMBER () OVER (
PARTITION BY ParcelID,
             PropertyAddress,
			 SalePrice,
			 LegalReference,
			 OwnerName
			 ORDER BY UniqueID
			 ) row_num

FROM projects..Housetable)
DELETE 
FROM row_CTE
WHERE row_num >1

------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------

--5. remove unused columns

ALTER TABLE projects..Housetable
DROP COLUMN PropertyAddress, OwnerAddress, TaxDistrict



SELECT *
FROM projects..Housetable













