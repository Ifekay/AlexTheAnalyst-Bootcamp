
--				Data cleaning  Cwith SQL Queries
SELECT *
  FROM [PortfolioProject].[dbo].[Nashville Housing]


--				Check SalesDate column datatype

SELECT DATA_TYPE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'Nashville Housing' AND COLUMN_NAME = 'SaleDate'

--				Converting SalesDate column datatype from 'datetime' to 'date' 

Update PortfolioProject..[Nashville Housing]
SET SaleDate = CONVERT(Date,SaleDate)

--    Checking the  DATA_TYPE of SaleDate column after trying to covert it to date datatype

SELECT DATA_TYPE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'Nashville Housing' AND COLUMN_NAME = 'SaleDate'


SELECT *
FROM PortfolioProject..[Nashville Housing]
WHERE PropertyAddress <> OwnerAddress


--					The above did not work, so I will create a new column called SaleDateConverted


ALTER TABLE PortfolioProject..[Nashville Housing]
Add SaleDateConverted Date;

Update PortfolioProject..[Nashville Housing]
SET SaleDateConverted = CONVERT(Date,SaleDate)


--    Checking the  DATA_TYPE of SaleDateConverted column 

SELECT DATA_TYPE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'Nashville Housing' AND COLUMN_NAME = 'SaleDateConverted'

--    Checking the SaleDateConverted column 
SELECT SaleDateConverted
FROM PortfolioProject..[Nashville Housing]

 
 --				Filling Property Address column 
 --				To populate the Property Address column, I will do some explorations

  SELECT *
 FROM PortfolioProject..[Nashville Housing]
 ORDER BY parcelID


 -- Checking all columns for parcelID with NULL values in the PropertyAddress column
 SELECT *
 FROM PortfolioProject..[Nashville Housing]
 WHERE ParcelID IN ( SELECT ParcelID FROM PortfolioProject..[Nashville Housing] WHERE PropertyAddress IS NULL) --I can observe that the rows with Null values in the PropertyAddress column have same parcelID with other rows  

   ---- CHECKING count of ParcelID in more than one row
 --select ParcelID, count(parcelID) AS TEST
 --from PortfolioProject..[Nashville Housing]
 -- GROUP BY ParcelID
 --HAVING count(parcelID)> 1
 --ORDER BY 2 DESC


--The rows with NULL values in the PropertyAddress column

-- This query check all columns where each ParcelID count is 1 and PropertyAddress IS NULL

SELECT *
FROM PortfolioProject..[Nashville Housing]
WHERE ParcelID IN ( select ParcelID
 from PortfolioProject..[Nashville Housing]
  GROUP BY ParcelID
 HAVING count(parcelID)= 1) AND PropertyAddress IS NULL  -- The query shows that no row met this condition, i.e the rows with Null values in the PropertyAddress column have same parcelID with at least one other row and this row can be used to populate the Null values 



 
SELECT a.parcelID, a.PropertyAddress, b.parcelID, b.PropertyAddress,    ISNULL(a.PropertyAddress,b.PropertyAddress) AS NewPropertyAddress  --ISNULL check if the value is NULL and replace it with next attribute
FROM PortfolioProject..[Nashville Housing] AS a
JOIN PortfolioProject..[Nashville Housing] AS b
ON  a.ParcelID = b.ParcelID AND a.[UniqueID ] <> b.[UniqueID ]
WHERE A.PropertyAddress IS NULL 


Update a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
From PortfolioProject..[Nashville Housing] AS a
JOIN PortfolioProject..[Nashville Housing] AS b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null


--									Check if there are still NULL values in the PropertyAddress column
select *
from PortfolioProject..[Nashville Housing]
where PropertyAddress IS NULL   -- This query shows that there are No more Null values in the PropertyAddress column



-- Breaking out PProperty Address into Individual Columns (Address, City, State)

--SELECT SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress)-1) AS Address,
--SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress)+2, LEN(PropertyAddress)) AS Address2  , PropertyAddress
--FROM PortfolioProject..[Nashville Housing]  


ALTER TABLE PortfolioProject..[Nashville Housing]
Add PropertySplitAddress Nvarchar(255);

Update PortfolioProject..[Nashville Housing]
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress)-1) 


ALTER TABLE PortfolioProject..[Nashville Housing]
Add PropertySplitCity Nvarchar(255);

Update PortfolioProject..[Nashville Housing]
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress)+2, LEN(PropertyAddress))



SELECT *
FROM PortfolioProject..[Nashville Housing]


-- Breaking out Owner Address into Individual Columns (Address, City, State)


Select OwnerAddress
From PortfolioProject..[Nashville Housing]



Select
PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)
From PortfolioProject..[Nashville Housing]



ALTER TABLE PortfolioProject..[Nashville Housing]
Add OwnerSplitAddress Nvarchar(255);

Update PortfolioProject..[Nashville Housing]
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)

 
ALTER TABLE PortfolioProject..[Nashville Housing]
Add OwnerSplitCity Nvarchar(255); 

Update PortfolioProject..[Nashville Housing]
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)



ALTER TABLE PortfolioProject..[Nashville Housing]
Add OwnerSplitState Nvarchar(255);

Update PortfolioProject..[Nashville Housing]
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)





Select *
From PortfolioProject..[Nashville Housing]


--						Change Y and N to Yes and No in "Sold as Vacant" Column


SELECT  *, CASE WHEN SoldAsVacant = 'N' THEN 'No' WHEN SoldAsVacant = 'Y' THEN 'Yes' ELSE SoldAsVacant END AS SoldAsVacant2
FROM PortfolioProject..[Nashville Housing]

--ALTER TABLE PortfolioProject..[Nashville Housing]
--ADD SSS vchar(255)


UPDATE PortfolioProject..[Nashville Housing]
SET SoldAsVacant = CASE WHEN SoldAsVacant ='N' THEN 'No' WHEN SoldAsVacant = 'Y' THEN 'Yes' ELSE SoldAsVacant END 


SELECT  SoldAsVacant
FROM PortfolioProject..[Nashville Housing]


---- check columns

--	SELECT COLUMN_NAME as ddd
--	FROM INFORMATION_SCHEMA.COLUMNS
--	WHERE TABLE_NAME = 'Nashville Housing'


-- Check for Possible Duplicates

WITH RowNumCTE AS (
Select *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num

From PortfolioProject..[Nashville Housing]
)
Select *
From RowNumCTE
Where row_num > 1
Order by PropertyAddress   -- 104 rows falls in this category




--    Removing Duplicates
WITH RowNumCTE AS (
Select *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num

From PortfolioProject..[Nashville Housing]
)
DELETE     -- Replace SELECT with DELETE
From RowNumCTE
Where row_num > 1



Select *
From PortfolioProject..[Nashville Housing]



-- Delete Some Unused Columns

Select *
From PortfolioProject..[Nashville Housing]  


ALTER TABLE PortfolioProject.dbo.NashvilleHousing
DROP COLUMN  PropertyAddress, OwnerAddress, TaxDistrict, SaleDate









