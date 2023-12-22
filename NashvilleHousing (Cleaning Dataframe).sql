Select *
From DataHousePrice..NashvilleHousing

--Standardize the date format
select SaleDateConverted, CONVERT(date, SaleDate) --convert the string to date format
from DataHousePrice..NashvilleHousing

UPDATE NashvilleHousing
SET SaleDate = CONVERT(date, SaleDate)

ALTER TABLE NashvilleHousing --add new table 
Add SaleDateConverted Date;

UPDATE NashvilleHousing
SET SaleDateConverted = CONVERT(date, SaleDate)



-------------------------------------------------------------------------------------------------------------------------------------------------
--Populate property address data

select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
from DataHousePrice..NashvilleHousing a
JOIN DataHousePrice..NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID] <> b.[UniqueID] --aUniqueID is not bUniqueID
Where a.PropertyAddress is null

--Updating the data
Update a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
from DataHousePrice..NashvilleHousing a
JOIN DataHousePrice..NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID] <> b.[UniqueID] --aUniqueID is not bUniqueID
Where a.PropertyAddress is null



-------------------------------------------------------------------------------------------------------------------------------------------------
-- Breaking out address into individual columns (Address, City, State)

SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 ) as Address -- -1 is to remove the comma at the end 
,SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1 , LEN(PropertyAddress)) as Address -- +1 is to remove the comma at the begining
from DataHousePrice..NashvilleHousing

ALTER TABLE NashvilleHousing --add new table 
Add PropertySplitAddress nvarchar(255);

UPDATE NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 )

ALTER TABLE NashvilleHousing --add new table 
Add PropertySplitCity nvarchar(255);

UPDATE NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1 , LEN(PropertyAddress))


-------------------------------------------------------------------------------------------------------------------------------------------------
--Split the owner address (address, city, and state)

Select 
PARSENAME(REPLACE(OwnerAddress,',', '.'), 3) --Another way to split the address data
,PARSENAME(REPLACE(OwnerAddress,',', '.'), 2) 
,PARSENAME(REPLACE(OwnerAddress,',', '.'), 1)
from DataHousePrice..NashvilleHousing


ALTER TABLE NashvilleHousing --add new table 
Add OwnerSplitAddress nvarchar(255);

UPDATE NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress,',', '.'), 3)

ALTER TABLE NashvilleHousing --add new table 
Add OwnerSplitCity nvarchar(255);

UPDATE NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress,',', '.'), 2)

ALTER TABLE NashvilleHousing --add new table 
Add OwnerSplitState nvarchar(255);

UPDATE NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress,',', '.'), 1)




-------------------------------------------------------------------------------------------------------------------------------------------------
-- Change Y and N to Yes and No in 'Sold as Vacant' field (Because in the field has Y, N, Yes and No)

Select SoldAsvacant 
, CASE When SoldAsVacant = 'Y' then 'Yes' --using case statement to change the string
	   When SoldAsVacant = 'N' then 'No'
	   ELSE SoldAsVacant
	   END
from DataHousePrice..NashvilleHousing

--Update the table 
UPDATE NashvilleHousing
SET SoldAsVacant = CASE When SoldAsVacant = 'Y' then 'Yes' --using case statement to change the string
	   When SoldAsVacant = 'N' then 'No'
	   ELSE SoldAsVacant
	   END

--To check
Select Distinct (SoldAsVacant), Count(SoldAsVacant)
from DataHousePrice..NashvilleHousing
Group by SoldAsVacant
order by 2



-------------------------------------------------------------------------------------------------------------------------------------------------

-- Remove Duplicates 
WITH RowNumCTE AS(
Select *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY UniqueID
				 )row_num
from DataHousePrice..NashvilleHousing
)

DELETE
from RowNumCTE
Where row_num > 1



-------------------------------------------------------------------------------------------------------------------------------------------------

--Delete Unused Columns 

Select *
from DataHousePrice..NashvilleHousing

ALTER TABLE DataHousePrice..NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate