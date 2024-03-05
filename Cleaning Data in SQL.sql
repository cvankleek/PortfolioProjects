-- Cleaning Data in SQL Queries

Select *
From PortfolioProject.dbo.NashvilleHousing


-- Standardizing Date Format

Select saledateConverted, CONVERT(Date, SaleDate)
From PortfolioProject.dbo.NashvilleHousing

Update NashvilleHousing
Set SaleDate = CONVERT(Date, SaleDate)

--Alter table nashvillehousing
--Add SaleDateConverted Date;

Update NashvilleHousing
Set SaleDateConverted = CONVERT(Date, SaleDate)



--Populate Property Address data

Select *
From PortfolioProject.dbo.NashvilleHousing
--Where PropertyAddress is null
Order by ParcelID


Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
From PortfolioProject.dbo.NashvilleHousing a
join PortfolioProject.dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <>b.[UniqueID ]
Where a.PropertyAddress is null

Update a
Set PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
From PortfolioProject.dbo.NashvilleHousing a
join PortfolioProject.dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <>b.[UniqueID ]
Where a.PropertyAddress is null


--Breaking out address into Individual Columns (Address, City, State)

Select PropertyAddress
From PortfolioProject.dbo.NashvilleHousing
--Where PropertyAddress is null
--Order by ParcelID

Select
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) as Adress
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress)) as Adress

From PortfolioProject.dbo.NashvilleHousing

Alter table NashvilleHousing
Add PropertySplitAddress Nvarchar(255);

Update NashvilleHousing
Set PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1)

Alter table NashvilleHousing
Add PropertySplitCity Nvarchar(255);

Update NashvilleHousing
Set PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress))

Select *
From PortfolioProject.dbo.NashvilleHousing

---splitting Owner Address with Pasrname(Looks for . not ,)

Select OwnerAddress
From PortfolioProject.dbo.NashvilleHousing

Select
PARSENAME(REPLACE(Owneraddress, ',', '.'), 3)
,PARSENAME(REPLACE(Owneraddress, ',', '.'), 2)
,PARSENAME(REPLACE(Owneraddress, ',', '.'), 1)
From PortfolioProject.dbo.NashvilleHousing


Alter table NashvilleHousing
Add OwnerSplitAddress Nvarchar(255);

Update NashvilleHousing
Set OwnerSplitAddress = PARSENAME(REPLACE(Owneraddress, ',', '.'), 3)

Alter table NashvilleHousing
Add OwnerSplitCity Nvarchar(255);

Update NashvilleHousing
Set OwnerSplitCity = PARSENAME(REPLACE(Owneraddress, ',', '.'), 2)

Alter table NashvilleHousing
Add OwnerSplitState Nvarchar(255);

Update NashvilleHousing
Set OwnerSplitState = PARSENAME(REPLACE(Owneraddress, ',', '.'), 1)

Select *
From PortfolioProject.dbo.NashvilleHousing



-- Change Y and N to Yes and No in "Sold as Vacant" field

--Origional data showed y and Yes and n and No we want to change to below
Select Distinct(SoldAsVacant), COUNT(SoldasVacant)
From PortfolioProject.dbo.NashvilleHousing
Group by SoldAsVacant
Order by 2

--Changes the Values for whole talbe
Select SoldAsVacant
, Case When SoldAsVacant = 'Y' Then 'Yes'
	When SoldAsVacant = 'N' Then 'No'
	Else SoldAsVacant
	END
From PortfolioProject.dbo.NashvilleHousing

--Updates table
Update NashvilleHousing
Set SoldAsVacant = Case When SoldAsVacant = 'Y' Then 'Yes'
	When SoldAsVacant = 'N' Then 'No'
	Else SoldAsVacant
	END

--Shows updated table count for Yes and No
Select Distinct(SoldAsVacant), COUNT(SoldasVacant)
From PortfolioProject.dbo.NashvilleHousing
Group by SoldAsVacant
Order by 2



--Remove Duplicates (not typical to delete all data; this does)
--CTE like a temp table
--Deleting will remove Items permanantly

With rownumCTE AS(
Select *,
	Row_Number() over (
	Partition BY ParcelID,
				PropertyAddress,
				SaleDate,
				LegalReference
				Order BY 
					UniqueID
					) row_num

From PortfolioProject.dbo.NashvilleHousing
)

Delete
From rownumCTE
Where row_num >1
--Order by PropertyAddress




--Delete unused Columns (dont do to raw data)

Select *
From PortfolioProject.dbo.NashvilleHousing

Alter Table PortfolioProject.dbo.NashvilleHousing
Drop Column OwnerAddress, TaxDistrict

Alter Table PortfolioProject.dbo.NashvilleHousing
Drop Column SaleDate