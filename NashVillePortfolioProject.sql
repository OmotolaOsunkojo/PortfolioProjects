--CLEANING DATA IN SQL QUERIES

SELECT * 
FROM [PORTFOLIO PROJECT].dbo.NashVilleProject

--STANDARDIZE DATE FORMAT
SELECT SaleDate, convert (date, SaleDate)
FROM [PORTFOLIO PROJECT]..NashVilleProject

ALTER TABLE [PORTFOLIO PROJECT]..NashVilleProject
ADD SaleDateConverted date

UPDATE [PORTFOLIO PROJECT]..NashVilleProject
SET SaleDateConverted= convert (date, SaleDate)

--POPULATE PROPERTY ADDRESS DATA

SELECT *
FROM [PORTFOLIO PROJECT]..NashVilleProject
--WHERE PropertyAddress IS NULL
ORDER BY ParcelID

SELECT A.ParcelID, A.PropertyAddress, B.ParcelID, B.PropertyAddress, ISNULL(A.PropertyAddress, B.PropertyAddress)
FROM [PORTFOLIO PROJECT]..NashVilleProject A
INNER JOIN [PORTFOLIO PROJECT]..NashVilleProject B
ON A.ParcelID = B.ParcelID
AND A.UniqueID <> B.UniqueID
WHERE A.PropertyAddress is NULL


UPDATE A
SET A.PropertyAddress = ISNULL(A.PropertyAddress, B.PropertyAddress)
FROM [PORTFOLIO PROJECT]..NashVilleProject A
INNER JOIN [PORTFOLIO PROJECT]..NashVilleProject B
ON A.ParcelID = B.ParcelID
AND A.UniqueID <> B.UniqueID

--BREAKING OUT ADDRESS INTO INDIVIDUAL COLUMNS (ADDRESS, CITY, STATE)
SELECT SUBSTRING(PropertyAddress, 1, CHARINDEX (',', PropertyAddress)-1) as Address, PropertyAddress,
 SUBSTRING (PropertyAddress, CHARINDEX (',', PropertyAddress)+1,LEN (PropertyAddress))
FROM [PORTFOLIO PROJECT]..NashVilleProject


ALTER TABLE [PORTFOLIO PROJECT]..NashVilleProject
ADD PropertyAddressSplit nvarchar(255)

UPDATE  [PORTFOLIO PROJECT]..NashVilleProject
SET PropertyAddressSplit = SUBSTRING(PropertyAddress, 1, CHARINDEX (',', PropertyAddress)-1)

ALTER TABLE [PORTFOLIO PROJECT]..NashVilleProject
ADD CitySplit nvarchar(255)

UPDATE  [PORTFOLIO PROJECT]..NashVilleProject
SET CitySplit = SUBSTRING (PropertyAddress, CHARINDEX (',', PropertyAddress)+1,LEN (PropertyAddress))

SELECT OwnerAddress, as 'SplitOwnerAddress',
PARSENAME (REPLACE (OwnerAddress, ',', '.'),2) AS SplitOwnerCity,
PARSENAME (REPLACE (OwnerAddress, ',', '.'),1) as SplitOwnerState
FROM [PORTFOLIO PROJECT]..NashVilleProject

ALTER TABLE [PORTFOLIO PROJECT]..NashVilleProject
ADD SplitOwnerAddress nvarchar(255)

ALTER TABLE [PORTFOLIO PROJECT]..NashVilleProject
ADD SplitOwnerCity nvarchar(255)

ALTER TABLE [PORTFOLIO PROJECT]..NashVilleProject
ADD SplitOwnerState nvarchar(255)

UPDATE [PORTFOLIO PROJECT]..NashVilleProject
SET SplitOwnerAddress =  PARSENAME (REPLACE (OwnerAddress, ',', '.'),3)

UPDATE [PORTFOLIO PROJECT]..NashVilleProject
SET SplitOwnerCity = PARSENAME (REPLACE (OwnerAddress, ',', '.'),2) 

UPDATE [PORTFOLIO PROJECT]..NashVilleProject
SET SplitOwnerState = PARSENAME (REPLACE (OwnerAddress, ',', '.'),1)

--CHANGE Y AND N TO YES AND NO IN 'SOLDASVACANT' COLUMN

SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM [PORTFOLIO PROJECT]..NashVilleProject
GROUP BY SoldAsVacant
ORDER BY 2

SELECT SoldAsVacant,
CASE 
WHEN SoldAsVacant= 'N' THEN 'NO'
WHEN SoldAsVacant= 'Y' THEN 'YES'
END
FROM [PORTFOLIO PROJECT]..NashVilleProject

UPDATE [PORTFOLIO PROJECT]..NashVilleProject
SET SoldAsVacant = CASE 
WHEN SoldAsVacant= 'N' THEN 'NO'
WHEN SoldAsVacant= 'Y' THEN 'YES'
ELSE SoldAsVacant
END

--REMOVE DUPLICATES
 
WITH RowNumCTE AS(
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

From [PORTFOLIO PROJECT]..NashVilleProject
--order by ParcelID
)
Select *
From RowNumCTE
Where row_num > 1
Order by PropertyAddress


--DELETE UNUSED COLUMNS

SELECT *
FROM [PORTFOLIO PROJECT]..NashVilleProject

ALTER TABLE [PORTFOLIO PROJECT]..NashVilleProject
DROP COLUMN OwnerAddress, PropertyAddress, TaxDistrict,SaleDate



