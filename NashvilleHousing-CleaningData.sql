/****** Script for SelectTopNRows command from SSMS  ******/
SELECT TOP (1000) [UniqueID ]
      ,[ParcelID]
      ,[LandUse]
      ,[PropertyAddress]
      ,[SaleDate]
      ,[SalePrice]
      ,[LegalReference]
      ,[SoldAsVacant]
      ,[OwnerName]
      ,[OwnerAddress]
      ,[Acreage]
      ,[TaxDistrict]
      ,[LandValue]
      ,[BuildingValue]
      ,[TotalValue]
      ,[YearBuilt]
      ,[Bedrooms]
      ,[FullBath]
      ,[HalfBath]
  FROM [PortfolioProject].[dbo].[NashvilleHousing]

  /*

  Cleaning Data in SQL queries

  */

  select * 
  from NashvilleHousing

  --------------------------------------------------------------------------------------------------------------------------------

  -- Standardize Date Format 

  select SaleDateConverted, Convert(Date, SaleDate) 
  from NashvilleHousing


  Alter table NashvilleHousing
  Add SaleDateConverted Date;

  Update NashvilleHousing
  set SaleDateConverted = Convert(Date, SaleDate)

  ---------------------------------------------------------------------------------------------------------------------------------

  --Populate Property Address Data

  select *
  From NashvilleHousing
  --where PropertyAddress is null
  order by ParcelID

  select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, isnull(a.PropertyAddress,b.PropertyAddress)
  From NashvilleHousing a
  Join NashvilleHousing b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID]<>b.[UniqueID]
  where a.PropertyAddress is null


  Update a
  set PropertyAddress = isnull(a.PropertyAddress,b.PropertyAddress)
  from NashvilleHousing a
  Join NashvilleHousing b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID]<>b.[UniqueID]
  where a.PropertyAddress is null

  ------------------------------------------------------------------------------------------------------------------------------------------------

  --Breaking out Address into Individual Columns (Address, City, State)

  
  select PropertyAddress
  From NashvilleHousing
  --where PropertyAddress is null
  --order by ParcelID

  --select 
  --SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress) -1) as Address,
  --SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress) +1, len(PropertyAddress)) as City


  Alter table NashvilleHousing
  Add PropertySplitAddress Nvarchar(255);

  Update NashvilleHousing
  set PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress) -1)

  Alter table NashvilleHousing
  Add PropertySplitCity Nvarchar(255);

  Update NashvilleHousing
  set PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress) +1, len(PropertyAddress))

  select *
  from NashvilleHousing

  select OwnerAddress
  from NashvilleHousing

  select 
  PARSENAME(replace(OwnerAddress,',','.'), 3),
  PARSENAME(replace(OwnerAddress,',','.'), 2),
  PARSENAME(replace(OwnerAddress,',','.'), 1)
  from NashvilleHousing

  Alter table NashvilleHousing
  Add OwnerSplitAddress Nvarchar(255);

  Update NashvilleHousing
  set OwnerSplitAddress = PARSENAME(replace(OwnerAddress,',','.'), 3)

  Alter table NashvilleHousing
  Add OwnerSplitCity Nvarchar(255);

  Update NashvilleHousing
  set OwnerSplitCity = PARSENAME(replace(OwnerAddress,',','.'), 2)

  Alter table NashvilleHousing
  Add  OwnerSplitState Nvarchar(255);

  Update NashvilleHousing
  set OwnerSplitState = PARSENAME(replace(OwnerAddress,',','.'), 1)

  select *
  from NashvilleHousing
  ------------------------------------------------------------------------------------------------------------------------------------------

  --Change Y and N to Yes and No in "Sold as Vacant" field

  select distinct(SoldAsVacant), count(SoldAsVacant)
  from NashvilleHousing
  group by SoldAsVacant
  order by 2

  select SoldAsVacant, 
	CASE when SoldAsVacant = 'Y' then 'Yes'
		 when SoldAsVacant = 'N' then 'No'
		 Else SoldAsVacant
		 End
  from NashvilleHousing

  Update NashvilleHousing
  Set SoldAsVacant = CASE when SoldAsVacant = 'Y' then 'Yes'
		 when SoldAsVacant = 'N' then 'No'
		 Else SoldAsVacant
		 End
------------------------------------------------------------------------------------------------------------------------------------------------

--Remove Duplicates

WITH RowNumCTE As(
select *,
	ROW_NUMBER() Over(
	partition by ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY 
					UniqueID
					) row_num

from NashvilleHousing
--order by ParcelID
)
DELETE 
from RowNumCTE
where row_num > 1
--order by PropertyAddress

-- Run again
WITH RowNumCTE As(
select *,
	ROW_NUMBER() Over(
	partition by ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY 
					UniqueID
					) row_num

from NashvilleHousing
--order by ParcelID
)
select * 
from RowNumCTE
where row_num > 1
order by PropertyAddress
---------------------------------------------------------------------------------------------------------------------------------------------

-- Delete Unused Columns

select *
from NashvilleHousing

alter table NashvilleHousing
drop column OwnerAddress, TaxDistrict, PropertyAddress

alter table NashvilleHousing
drop column SaleDate