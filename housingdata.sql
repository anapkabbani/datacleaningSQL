/*
Cleaning Data in SQL Queries
*/

SELECT *
FROM [Nashville Housing].[dbo].[nashville_housing] 


--------------------------------------------------------------------------------------------------------------------------

-- Standardize Date Format ( New column: SaleDateConverted)



SELECT  SaleDate
FROM [Nashville Housing].[dbo].[nashville_housing] 

SELECT  SaleDateConverted, CONVERT (Date,SaleDate)
FROM nashville_housing

ALTER TABLE nashville_housing
ADD SaleDateConverted Date;

UPDATE nashville_housing
SET SaleDateConverted = CONVERT(Date,SaleDate)


--------------------------------------------------------------------------------------------------------------------------

-- Property Address Data (filling out null values based on ParcelID)


SELECT  *
FROM nashville_housing
--Where PropertyAddress is null
ORDER BY ParcelID

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM nashville_housing a
JOIN nashville_housing b
   ON a.ParcelID = b.ParcelID
   AND a.[UniqueID] <> b.[UniqueID] -- same ParcelID, but not the same row
WHERE a.PropertyAddress is null

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM nashville_housing a
JOIN nashville_housing b
   ON a.ParcelID = b.ParcelID
   AND a.[UniqueID] <> b.[UniqueID] -- same ParcelID, but not the same row
WHERE a.PropertyAddress is null

--------------------------------------------------------------------------------------------------------------------------



-- Separating Address into Individual Columns ( Address, City, State)

SELECT  PropertyAddress
FROM nashville_housing
--WHERE PropertyAddress is null
--ORDER BY ParcelID

SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX (',',PropertyAddress) -1) as Address
,SUBSTRING(PropertyAddress, CHARINDEX (',',PropertyAddress) + 1, LEN(PropertyAddress)) as Address
FROM nashville_housing

ALTER TABLE nashville_housing
ADD PropertySplitAddress Nvarchar(255);

UPDATE nashville_housing
SET PropertySplitAddress  = SUBSTRING(PropertyAddress, 1, CHARINDEX (',',PropertyAddress) -1)

ALTER TABLE nashville_housing
ADD PropertySplitCity Nvarchar(255);

UPDATE nashville_housing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX (',',PropertyAddress) + 1, LEN(PropertyAddress))

SELECT *
FROM nashville_housing

SELECT OwnerAddress
FROM nashville_housing

SELECT 
PARSENAME(REPLACE(OwnerAddress, ',' , '.' ), 3) 
,PARSENAME(REPLACE(OwnerAddress, ',' , '.' ), 2)
,PARSENAME(REPLACE(OwnerAddress, ',' , '.' ), 1)
FROM [Nashville Housing].[dbo].[nashville_housing]

ALTER TABLE nashville_housing
ADD OwnerSplitAddress Nvarchar(255);

UPDATE nashville_housing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',' , '.' ), 3) 

ALTER TABLE nashville_housing
ADD OwnerSplitCity Nvarchar(255);

UPDATE nashville_housing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',' , '.' ), 2)

ALTER TABLE nashville_housing
ADD OwnerSplitState Nvarchar(255);

UPDATE nashville_housing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',' , '.' ), 1)

SELECT *
FROM nashville_housing


--------------------------------------------------------------------------------------------------------------------------



--Change Y/N to Yes and No in Column "Sold as Vacant"

SELECT DISTINCT (SoldAsVacant), COUNT (SoldAsVacant)
FROM nashville_housing
GROUP BY SoldAsVacant

SELECT SoldAsVacant
, CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	   WHEN SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END
FROM nashville_housing

UPDATE nashville_housing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	   WHEN SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END

--------------------------------------------------------------------------------------------------------------------------



--Removing Duplicates (104 )

WITH RowNUMCTE AS (
SELECT *,
	ROW_NUMBER () OVER (
	PARTITION BY ParcelID,
				PropertyAddress,
				SalePrice,
				SaleDate,
				LegalReference
				ORDER BY
				  ParcelID
				  ) row_num
FROM nashville_housing
)
DELETE
FROM RowNUMCTE
WHERE row_num >1
--ORDER BY PropertyAddress

--------------------------------------------------------------------------------------------------------------------------



--Remove Unused Columns

SELECT *
FROM nashville_housing

ALTER TABLE [Nashville Housing].[dbo].[nashville_housing] 
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate

