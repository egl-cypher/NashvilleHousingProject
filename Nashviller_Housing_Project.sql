/*
        Cleaning Data in SQL Queries
*/

SELECT *
FROM PortfolioProject.. NashvilleHousing


SELECT SaleDate ,CONVERT(date ,SaleDate)
FROM PortfolioProject..NashvilleHousing

--lets update the SaleDate now

 UPDATE NashvilleHousing
 SET SaleDate = CONVERT(date ,SaleDate) -- didn't work for some reason

 ALTER TABLE NashvilleHousing
 ADD  SaleDateConverted date ; -- we had to use alter to add a new column


 UPDATE NashvilleHousing
 SET SaleDateConverted  = CONVERT(date ,SaleDate) -- then we add it finally

  --Populate Property address Data i.e filling the null values


 SELECT * 
 FROM PortfolioProject..NashvilleHousing
 --WHERE PropertyAddress is null
 ORDER BY ParcelID

 SELECT  a.ParcelID , a.PropertyAddress , b.ParcelID, b.PropertyAddress , ISNULL(a.PropertyAddress, b.PropertyAddress)
 FROM PortfolioProject..NashvilleHousing a -- a is the null data
 JOIN PortfolioProject..NashvilleHousing b
      ON  a.ParcelID = b.ParcelID -- this could be related
         AND a.[UniqueID ] <> b.[UniqueID ] -- this going to avoid repetition
 where a.PropertyAddress IS NULL

 UPDATE a
 SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
 FROM PortfolioProject..NashvilleHousing a -- a is the null data
 JOIN PortfolioProject..NashvilleHousing b
      ON  a.ParcelID = b.ParcelID -- this could be related
         AND a.[UniqueID ] <> b.[UniqueID ] -- this going to avoid repetition
 where a.PropertyAddress IS NULL

 --Breaking Property Address into individual Columns ( Address , City , State)
   --SUBSTRING(column, start, end)
   --          propertyaddress,1,charindex(',', propertyaddress) -1)

  SELECT PropertyAddress , SUBSTRING(PropertyAddress , 1, CHARINDEX(',', PropertyAddress) -1) as Address ,
  SUBSTRING(PropertyAddress , CHARINDEX(',', PropertyAddress) +1 , LEN(propertyAddress)  ) as city
 FROM PortfolioProject..NashvilleHousing
 ----WHERE PropertyAddress is null
 --ORDER BY ParcelID

 -- lets add the splited addresses into new columns

 ALTER TABLE NashvilleHousing
 ADD  OwnerSplitAddress nvarchar(255) ; -- we had to use alter to add a new column


 UPDATE NashvilleHousing
 SET OwnerSplitAddress  = SUBSTRING(PropertyAddress , 1, CHARINDEX(',', PropertyAddress)-1) -- then we add it finally


 ALTER TABLE NashvilleHousing
 ADD  OwnerSplitCity nvarchar(255) ; -- we had to use alter to add a new column


 UPDATE NashvilleHousing
 SET OwnerSplitCity =  SUBSTRING(PropertyAddress , CHARINDEX(',', PropertyAddress) +1 , LEN(propertyAddress)  )  -- then we add it finally


  SELECT * 
 FROM PortfolioProject..NashvilleHousing
 --WHERE PropertyAddress is null
 --ORDER BY ParcelID


 ---Breaking OwnerAddress into Column

  SELECT ownerAddress, PARSENAME(REPLACE(OwnerAddress,',','.'),3), -- parse uses dot so replace all the commas with dot starting from the last
   PARSENAME(REPLACE(OwnerAddress,',','.'),2),
    PARSENAME(REPLACE(OwnerAddress,',','.'),1)
 FROM PortfolioProject..NashvilleHousing  

 ALTER TABLE NashvilleHousing
 ADD  OwnerSplitAddress nvarchar(255) ; -- we had to use alter to add a new column


 UPDATE NashvilleHousing
 SET OwnerSplitAddress  = PARSENAME(REPLACE(OwnerAddress,',','.'),3) -- starts with third as the first

 ALTER TABLE NashvilleHousing
 ADD  PropertySplitCity nvarchar(255) ; -- we had to use alter to add a new column


 UPDATE NashvilleHousing
 SET PropertySplitCity =  PARSENAME(REPLACE(OwnerAddress,',','.'),2)

 ALTER TABLE NashvilleHousing
 ADD  PropertySplitState nvarchar(255) ; -- we had to use alter to add a new column


 UPDATE NashvilleHousing
 SET PropertySplitState =  PARSENAME(REPLACE(OwnerAddress,',','.'),1)

 SELECT 
 FROM PortfolioProject..NashvilleHousing
 --WHERE PropertyAddress is null
 --ORDER BY ParcelID


 -- Change Y AND N TO yes and no in " sold  as vacant" field

 Select Distinct(SoldAsVacant) ,count(SoldAsvacant)
 From PortfolioProject..NashvilleHousing
group by SoldAsVacant
order by SoldAsVacant


 Select SoldAsVacant
 ,CASE
   WHEN SoldAsVacant = 'Y' THEN  'Yes'
   WHEN SoldAsVacant = 'N' THEN  'No'
   Else SoldAsVacant 
   END 
 From PortfolioProject..Nashvill eHousing

 Update NashvilleHousing
 SET SoldAsVacant = CASE
   WHEN SoldAsVacant = 'Y' THEN  'Yes'
   WHEN SoldAsVacant = 'N' THEN  'No'
   Else SoldAsVacant 
   END 

   ---Remove Duplicates 
   Select * , ROW_NUMBER()  --check for repetive column date on the partition by column
   OVER (PARTITION BY ParcelID,
                      PropertyAddress,
					  SalePrice,
					  SaleDate,
					  legalReference
					  ORDER BY
					  UniqueID
					  ) row_num
    
 From PortfolioProject..NashvilleHousing
 order by ParcelID


 --- we use the ctE because the output value row_num could not be use to check mathematical operation
	 WITH RowNumCTE 
	 AS
	 (
	 Select * , 
		 ROW_NUMBER() OVER  (
	                 PARTITION BY ParcelID,
                      PropertyAddress,
					  SalePrice,
					  SaleDate,
					  legalReference
					  ORDER BY
					  UniqueID
					  ) row_num	
          From PortfolioProject..NashvilleHousing
 --order by ParcelID
		)
      Select  *
      from	RowNumCTE 
	  where row_num >1 -- Reason we used the CTE
	--order by PropertyAddress
		


			--- Delete unused Columns ( we use alter drop instead of delete which just remove the content from the table)

 Select Distinct(SoldAsVacant) ,count(SoldAsvacant)
 From PortfolioProject..NashvilleHousing

 ALTER TABLE PortfolioProject..NashvilleHousing
 DROP COLUMN  ownerAddress, TaxDistrict, PropertyAddress, SaleDate