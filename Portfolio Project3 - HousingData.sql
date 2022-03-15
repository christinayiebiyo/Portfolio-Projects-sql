/*
		Cleaning Data in SQL

*/

Select * 
From PortfolioProject..[housingData]

-- Standardizing the date format in SaleData -----

ALTER TABLE [housingData]
ALTER COLUMN [SaleDate] date 
Select *
From PortfolioProject..[housingData]

-- Populating Property address data -----

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
From PortfolioProject..[housingData] a
JOIN PortfolioProject..[housingData] b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null 

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
From PortfolioProject..[housingData] a
JOIN PortfolioProject..[housingData] b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]

-- Breaking out Address into individual columns(Address, City, State)

Select OwnerAddress
From PortfolioProject..[housingData]


Select
PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)
From PortfolioProject..[housingData]



ALTER TABLE [housingData]
Add OwnerSplitAddress Nvarchar(255);

Update [housingData]
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)


ALTER TABLE [housingData]
Add OwnerSplitCity Nvarchar(255);

Update [housingData]
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)



ALTER TABLE [housingData]
Add OwnerSplitState Nvarchar(255);

Update [housingData]
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)



Select PropertyAddress
From [housingData]

Select
PARSENAME(REPLACE(PropertyAddress, ',', '.') , 2),
PARSENAME(REPLACE(PropertyAddress, ',', '.') , 1)
From PortfolioProject..[housingData]



ALTER TABLE [housingData]
Add PropertySplitAddress Nvarchar(255);

Update [housingData]
SET PropertySplitAddress = PARSENAME(REPLACE(PropertyAddress, ',', '.') , 2)


ALTER TABLE [housingData]
Add PropertySplitCity Nvarchar(255);

Update [housingData]
SET PropertySplitCity = PARSENAME(REPLACE(PropertyAddress, ',', '.') , 1)

Select * 
From [housingData]

--Changing Y and N to 'YES' and 'NO' in "SoldAsVacant" column

Select Distinct(SoldAsVacant), COUNT(SoldAsVacant) as Count
From [housingData]
Group by SoldAsVacant
Order by 2

Select SoldAsVacant,
	CASE WHEN SoldAsVacant = 'Y' THEN 'YES'
		WHEN  SoldAsVacant = 'N' THEN 'NO'
		ELSE SoldAsVacant
		END
From [housingData]

UPDATE [housingData]
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'YES'
		WHEN  SoldAsVacant = 'N' THEN 'NO'
		ELSE SoldAsVacant
		END

-- Remove Duplicates ------ 
WITH RowNumCTE AS (
Select * , 
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID, 
				 PropertyAddress, 
				 SalePrice, 
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID)
					row_num
From [housingData]
)
Select * 
FROM RowNumCTE
Where row_num > 1
Order by PropertyAddress

--Deleting Unused Columns --- 

ALTER TABLE [housingData]
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress


ALTER TABLE [housingData]
DROP COLUMN SaleDate

Select * 
From [housingData]