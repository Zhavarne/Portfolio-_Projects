--Data Cleaning of Nashville Housing Data
--In this project we are just making data more useable for processing and to be displayed

Select *
From PortfolioProject..NashvilleHousing

--Standardize date format
Select SaleDateConverted, CONVERT(Date, SaleDate)
From PortfolioProject..NashvilleHousing

--Updating the better format of date into the table
Update NashvilleHousing
SET SaleDate = CONVERT(Date, SaleDate)

ALTER TABLE NashvilleHousing
Add SaleDateConverted Date;

Update NashvilleHousing
SET SaleDateConverted = CONVERT(Date, SaleDate)


-------------------------------------------------------
--Populate property Address data
Select *
From PortfolioProject..NashvilleHousing
--Where PropertyAddress is null
order by ParcelID

--Matching parcelID to PropertyAddress
Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
From PortfolioProject..NashvilleHousing a
JOIN PortfolioProject..NashvilleHousing b
     on a.ParcelID = b.ParcelID
	 AND a.UniqueID <> b.UniqueID
where a.PropertyAddress is null

Update a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
From PortfolioProject..NashvilleHousing a
JOIN PortfolioProject..NashvilleHousing b
     on a.ParcelID = b.ParcelID
	 AND a.UniqueID <> b.UniqueID
where a.PropertyAddress is null


---------------------------------------------------------------------------
--Breaking out address into individual columns(Address, City, State)
Select PropertyAddress
From PortfolioProject..NashvilleHousing
--Where PropertyAddress is null
order by ParcelID

--we need to seperate address by the comma(comma-delimiter)
--CHARINDEX: searches for '.....'
--CHARINDEX(',', PropertyAddress)-1: removes that comma
SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) as Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, Len(PropertyAddress)) as Address

From PortfolioProject..NashvilleHousing

ALTER TABLE NashvilleHousing
Add PropertySplitAddress Nvarchar(255);

Update NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1)

ALTER TABLE NashvilleHousing
Add PropertySplitCity Nvarchar(255);

Update NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, Len(PropertyAddress))

Select *
From PortfolioProject..NashvilleHousing
--check out 3 columns at the end that we created...(SalesDateConverted, PropertySplitAddress,PropertySplitCity)


--Fixing owner address
Select OwnerAddress
From PortfolioProject..NashvilleHousing


--PARSENAME looks for periods and not commas
--Replacing commas with periods for PARSENAME to work effectively
Select 
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3),
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2),
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
From PortfolioProject..NashvilleHousing



ALTER TABLE NashvilleHousing
Add OwnerSplitAddress Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)

ALTER TABLE NashvilleHousing
Add OwnerSplitCity Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)

ALTER TABLE NashvilleHousing
Add OwnerSplitState Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)


Select*
From PortfolioProject..NashvilleHousing
--check out 3 columns at the end that we created...(OwnerSplitState, OwnerSplitCity, OwnerSplitAddress)


---------------------------------------------------------------------------------'
--Change Y and N to Yes and No in Sold as Vacant field


--used to check if there are Y and N still in the data ad how many there are
Select Distinct(SoldAsVacant), Count(SoldAsVacant)
From PortfolioProject..NashvilleHousing
Group by SoldAsVacant
order by 2

Select SoldAsVacant
, CASE When SoldAsVacant = 'Y' then 'Yes'
       when SoldAsVacant = 'N' then 'No'
	   Else SoldAsVacant
	   END
From PortfolioProject..NashvilleHousing

Update NashvilleHousing
SET SoldAsVacant = CASE When SoldAsVacant = 'Y' then 'Yes'
       when SoldAsVacant = 'N' then 'No'
	   Else SoldAsVacant
	   END



------------------------------------------------------------------------------------------------
--Remove Duplicates


--below is to delete the duplicates with the application of CTE's
WITH RowNumCTE AS(
Select *, 
    ROW_NUMBER() OVER(
	PARTITION BY ParcelID,
	             PropertyAddress,
				 SaleDate,
				 LegalReference
				 ORDER BY
				  UniqueID
				  ) row_num
From PortfolioProject..NashvilleHousing
--order by ParcelID
)
DELETE
From RowNumCTE
where row_num > 1
--Order by PropertyAddress


--lets check if there are any more duplicates left after deleting 
WITH RowNumCTE AS(
Select *, 
    ROW_NUMBER() OVER(
	PARTITION BY ParcelID,
	             PropertyAddress,
				 SaleDate,
				 LegalReference
				 ORDER BY
				  UniqueID
				  ) row_num
From PortfolioProject..NashvilleHousing
--order by ParcelID
)
Select *
From RowNumCTE
where row_num > 1
Order by PropertyAddress

--Check all data
Select *
From PortfolioProject..NashvilleHousing


-------------------------------------------------------------------------------------------
--Delete Unused Columns

Select *
From PortfolioProject..NashvilleHousing

ALTER TABLE PortfolioProject..NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress

ALTER TABLE PortfolioProject..NashvilleHousing
DROP COLUMN SaleDate
