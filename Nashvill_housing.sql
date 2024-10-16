use Housing_Estate;

select *
from Nashville_Housing;

-- Standardize Date Fromat
select SaleDate,CONVERT(date,saledate)
from Nashville_Housing;

update Nashville_Housing
set SaleDate = CONVERT(date,saledate)


Alter Table Nashville_Housing
Add SaleDateConverted Date;

Update Nashville_Housing
Set SaleDateConverted = convert(date,Saledate)

Select Saledate,saledateconverted
from Nashville_Housing

-- Populate Property Address Data
Select PropertyAddress
from Nashville_Housing


Select a.ParcelID, a.PropertyAddress,b.ParcelID, B.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
From Nashville_Housing a
Join Nashville_Housing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is Null

Update a
Set PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
	From Nashville_Housing a
	Join Nashville_Housing b
		ON a.ParcelID = b.ParcelID
		AND a.[UniqueID ] <> b.[UniqueID ]
	Where a.PropertyAddress is Null

--- Breaking out Address into Individual columns (Address, City, State)

Select PropertyAddress
From Nashville_Housing
order by PropertyAddress


-- using the substring to extra the address from the propertyaddress and also using the CHARINDEX to find the character

Select 
Substring(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1) as Address,
Substring(PropertyAddress,CHARINDEX(',',PropertyAddress) + 1, LEN(PropertyAddress)) as City 
From Nashville_Housing
order by PropertyAddress

Alter Table Nashville_Housing
Add PropertySplitAddress nvarchar(255)

Alter Table Nashville_Housing
Add PropertySplitCity nvarchar(255)

Update Nashville_Housing
Set PropertySplitAddress = Substring(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1)

Update Nashville_Housing
Set PropertySplitCity = Substring(PropertyAddress,CHARINDEX(',',PropertyAddress) + 1, LEN(PropertyAddress))e

Select PropertyAddress,PropertysplitAddress,PropertySplitCity
from Nashville_Housing

Select *
from Nashville_Housing


--- spliting the owners address

select OwnerAddress
from Nashville_Housing
order by OwnerAddress

-- using PARSENAME

Select
ownerAddress,
PARSENAME(REPLACE(OwnerAddress, ',','.'),3),
PARSENAME(REPLACE(OwnerAddress, ',','.'),2),
PARSENAME(REPLACE(OwnerAddress, ',','.'),1)
from Nashville_Housing

Alter Table Nashville_Housing
Add OwnerSplitAddress nvarchar(255)

Alter Table Nashville_Housing
Add OwnerSplitCity nvarchar(255)

Alter Table Nashville_Housing
Add OwnerSplitState nvarchar(255)

Update Nashville_Housing
Set OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',','.'),3)

Update Nashville_Housing
Set OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',','.'),2)

Update Nashville_Housing
Set OwnerSplitState= PARSENAME(REPLACE(OwnerAddress, ',','.'),1)

Select *
from Nashville_Housing

--- Change Y and N to Yes and No in "Sold as Vacant" field

Select Distinct(soldAsvacant), count(SoldAsVacant)
From Nashville_Housing
Group by SoldAsVacant
order by 2

Select SoldAsVacant,
	Case
		When SoldAsVacant = 'Y' Then 'Yes'
		When SoldAsVacant = 'N' Then 'No'
		Else SoldAsVacant
		END
	From Nashville_Housing

Update Nashville_Housing
SET SoldAsVacant = 
	Case
		When SoldAsVacant = 'Y' Then 'Yes'
		When SoldAsVacant = 'N' Then 'No'
		Else SoldAsVacant
	END

Select Distinct(soldAsvacant), count(SoldAsVacant)
From Nashville_Housing
Group by SoldAsVacant
order by 2


--- Remove Duplicates
With RowNumCTE As (
	Select *,
		Row_Number() Over (
		Partition by ParcelID,
					 PropertyAddress,
					 SalePrice,
					 SaleDate,
					 LegalReference
					 Order by UniqueID 
					 ) row_num
	From Nashville_Housing
	-- order by ParcelID
)
Delete
from RowNumCTE
where row_num > 1
-- order by PropertyAddress

-- Delete Unused Columns

Select * 
From Nashville_Housing

Alter Table Nashville_Housing
Drop Column
			OwnerAddress,
			TaxDistrict,
			PropertyAddress

Alter Table Nashville_Housing
Drop Column saledate