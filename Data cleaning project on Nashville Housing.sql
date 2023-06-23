-- This project is about cleaning the data
select * from NashvilleHousing



-- Standardize Date Format
select SaleDate, CONVERT(Date,SaleDate)
from NashvilleHousing

alter table NashvilleHousing
add SaleDateConverted Date; 

update NashvilleHousing
SET SaleDateConverted=CONVERT(Date,SaleDate)

select *from NashvilleHousing


-- Populate Propery Address data

select * from NashvilleHousing
--where PropertyAddress is NULL
order by ParcelID

select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
from NashvilleHousing a
join NashvilleHousing b
	on a.ParcelID=b.ParcelID
	and a.[UniqueID ]<>b.[UniqueID ]
where a.PropertyAddress is null

update a
set PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
from NashvilleHousing a
join NashvilleHousing b
	on a.ParcelID=b.ParcelID
	and a.[UniqueID ]<>b.[UniqueID ]
where a.PropertyAddress is null 


-- Breaking out Address into Individual Columns (Address, City, State)
select PropertyAddress
from NashvilleHousing
--where PropertyAddress is NULL
--order by ParcelID

select 
SUBSTRING(PropertyAddress, 1, charindex(',', PropertyAddress) -1) as Address,
SUBSTRING(PropertyAddress, charindex(',', PropertyAddress) +1, LEN(PropertyAddress)) as Address
from  NashvilleHousing


alter table NashvilleHousing
Add PropertySplitAddress nvarchar(255);

update NashvilleHousing
set PropertySplitAddress = SUBSTRING(PropertyAddress, 1, charindex(',', PropertyAddress) -1)

alter table NashvilleHousing
Add PropertySplitCity nvarchar(255)

update NashvilleHousing
set PropertySplitCity = SUBSTRING(PropertyAddress, charindex(',', PropertyAddress) +1, LEN(PropertyAddress))


select * from NashvilleHousing


select OwnerAddress from NashvilleHousing

select 
PARSENAME(replace(OwnerAddress, ',', '.'), 3),
PARSENAME(replace(OwnerAddress, ',', '.'), 2),
PARSENAME(replace(OwnerAddress, ',', '.'), 1)
from NashvilleHousing

alter table NashvilleHousing
Add OwnerSplitAddress nvarchar(255);

update NashvilleHousing
set OwnerSplitAddress = PARSENAME(replace(OwnerAddress, ',', '.'), 3)

alter table NashvilleHousing
add OwnerSplitCity nvarchar(255);

update NashvilleHousing
set OwnerSplitCity = PARSENAME(replace(OwnerAddress, ',', '.'), 2)

alter table NashvilleHousing
add OnwerSplitState nvarchar(10)
-- I made a typo and added an incorrectly named column to the table, so I'm going to drop it
alter table NashvilleHousing
drop column OnwerSplitState

alter table NashvilleHousing
add OwnerSplitState nvarchar(10)

update NashvilleHousing
set OwnerSplitState = PARSENAME(replace(OwnerAddress, ',', '.'), 1)


-- Change Y and N to Yes and No in "Sold as Vacant" field
select distinct(SoldAsVacant), count(SoldAsVacant)
from NashvilleHousing
group by SoldAsVacant
order by 2

select SoldAsVacant,
Case when SoldAsVacant ='Y' THEN 'Yes'
	 when SoldAsVacant = 'N' THEN 'No'
	 else SoldAsVacant
	 END
from NashvilleHousing

update NashvilleHousing
set SoldAsVacant = Case when SoldAsVacant ='Y' THEN 'Yes'
	 when SoldAsVacant = 'N' THEN 'No'
	 else SoldAsVacant
	 END

-- Remove Duplicates
WITH RowNumCTE as(
select *, 
	ROW_NUMBER()over(
	partition by ParcelID,
	PropertyAddress,
	SalePrice,
	SaleDate,
	LegalReference 
	order by
		UniqueID) 
			row_num
from NashvilleHousing
)

select *  
from RowNumCTE
where row_num > 1
order by PropertyAddress




-- Delete Unused Columns

select * from NashvilleHousing

alter table NashvilleHousing
drop column OwnerAddress, TaxDistrict, PropertyAddress

alter table NashvilleHousing
drop column SaleDate
