--Cleaning data in sql
SELECT*
FROM dbo.nashvillehousingdata

---Standardize date format

SELECT SaleDate 
FROM dbo.nashvillehousingdata

SELECT SaleDate,CONVERT(Date, SaleDate) AS SaleDateUpdated
FROM dbo.nashvillehousingdata


ALTER TABLE dbo.nashvillehousingdata
ADD SaleDateUpdated Date


UPDATE dbo.nashvillehousingdata
SET saledateupdated = CONVERT(DATE,SaleDate)

---Property Address data

SELECT PropertyAddress
FROM dbo.nashvillehousingdata

SELECT *
FROM dbo.nashvillehousingdata
WHERE Propertyaddress IS NULL

SELECT *
FROM dbo.nashvillehousingdata
ORDER BY ParcelID

SELECT a.parcelid, a.propertyaddress, b.parcelid, a.propertyaddress
FROM dbo.nashvillehousingdata a
JOIN dbo.nashvillehousingdata b
ON a.parcelid = b.parcelid
AND a.[uniqueid] = b.[uniqueid] --- parcel id with same id are inputed twice with null value in property address

SELECT a.parcelid, a.propertyaddress, b.parcelid, a.propertyaddress
FROM dbo.nashvillehousingdata a
JOIN dbo.nashvillehousingdata b
ON a.parcelid = b.parcelid
AND a.[uniqueid] = b.[uniqueid]
WHERE a.propertyaddress IS NULL
AND b.propertyaddress IS NULL --- here both the address is null

DELETE FROM dbo.nashvillehousingdata
WHERE EXISTS (
    SELECT 1
    FROM dbo.nashvillehousingdata AS tablenashville
    WHERE tablenashville.uniqueid = dbo.nashvillehousingdata.uniqueid
    AND tablenashville.parcelid = dbo.nashvillehousingdata.parcelid
    AND tablenashville.propertyaddress IS NULL
) --- to delete the same uniqueid with the same parcel id but with null value in the property address

SELECT *
FROM dbo.nashvillehousingdata
WHERE Propertyaddress IS NULL -- No null value


--Breaking out address into property address columns
SELECT 
SUBSTRING(propertyaddress, 1, CHARINDEX(',', propertyaddress)) AS address,
CHARINDEX(',',propertyaddress)
FROM dbo.nashvillehousingdata--- to check the posiition of the delimiter 


SELECT 
SUBSTRING(propertyaddress, 1, CHARINDEX(',', propertyaddress)-1) AS address
FROM dbo.nashvillehousingdata --- to remove the ',' we add -1 

SELECT 
    propertyaddress AS originaladdress,
    LEFT(propertyaddress, CHARINDEX(',', propertyaddress) - 1) AS Address,
    LTRIM(SUBSTRING(propertyaddress, CHARINDEX(',', propertyaddress) + 1, LEN(propertyaddress))) AS City
FROM dbo.nashvillehousingdata ---- to seperate both the street number and name in seperate columns



ALTER TABLE dbo.nashvillehousingdata
ADD Address VARCHAR(255),
     City VARCHAR(255) --- to alter the table and add the new columns




UPDATE dbo.nashvillehousingdata
SET 
	Address =   LEFT(propertyaddress, CHARINDEX(',', propertyaddress) - 1),
	City    =   LTRIM(SUBSTRING(propertyaddress, CHARINDEX(',',propertyaddress) +1, LEN(propertyaddress))); --update the new columns


SELECT *
FROM dbo.nashvillehousingdata -- to check the added information which will be updated in the last


--owner address
SELECT owneraddress
FROM dbo.nashvillehousingdata


SELECT 
PARSENAME(REPLACE(owneraddress,',','.'),3),
PARSENAME(REPLACE(owneraddress,',','.'),2),
PARSENAME(REPLACE(owneraddress,',','.'),1) 
FROM dbo.nashvillehousingdata -- here PARSENAME syntax queries  backwords i.e 1 will be count as the last word in the whole senetence


ALTER TABLE dbo.nashvillehousingdata
ADD DeliveryAddress VARCHAR(255),
    DeliveryCity VARCHAR(255),
	DeliveryState VARCHAR(255);

Update dbo.Nashvillehousingdata
SET DeliveryAddress = PARSENAME(REPLACE(OwnerAddress,',','.'),3),
	DeliveryCity = PARSENAME(REPLACE(Owneraddress,',','.'),2),
	DeliveryState = PARSENAME(REPLACE(OwnerAddress,',','.'),1)

SELECT *
FROM dbo.nashvillehousingdata



---Changing Y and N to Yes and No in Sold as vacant row
SELECT DISTINCT(Soldasvacant)
FROM dbo.Nashvillehousingdata

SELECT DISTINCT(Soldasvacant) , COUNT(Soldasvacant)
FROM dbo.Nashvillehousingdata
GROUP BY SoldAsVacant
ORDER BY 2 -- to check how many individual inputs are there

SELECT SoldAsVacant,
 CASE WHEN soldasvacant = 'Y' THEN 'YES'
	  WHEN soldasvacant = 'N' THEN 'NO'
	  ELSE soldasvacant
	  END
FROM dbo.Nashvillehousingdata; -- replacing the y and n to Yes and No


UPDATE dbo.Nashvillehousingdata
SET Soldasvacant = CASE WHEN soldasvacant = 'Y' THEN 'YES'
	  WHEN soldasvacant = 'N' THEN 'NO'
	  ELSE soldasvacant
	  END --- to update the change in the table


---Removing Duplicates
WITH RowNumCTE AS (
SELECT *,
	ROW_NUMBER() OVER (
	PARTITION BY parcelid,
        propertyaddress,
        saledate,
        saleprice,
        legalreference
        ORDER BY 
		   uniqueid
		   ) row_num
 FROM dbo.Nashvillehousingdata
)
SELECT *
FROM RowNumCTE
WHERE row_num > 1
ORDER BY PropertyAddress--- to check the number of duplicates


WITH RowNumCTE AS (
SELECT *,
	ROW_NUMBER() OVER (
	PARTITION BY parcelid,
        propertyaddress,
        saledate,
        saleprice,
        legalreference
        ORDER BY 
		   uniqueid
		   ) row_num
 FROM dbo.Nashvillehousingdata
)
DELETE
FROM RowNumCTE
WHERE row_num > 1   ---- to delete the duplicates




--delete unused columns

SELECT *
FROM dbo.nashvillehousingdata

ALTER TABLE dbo.nashvillehousingdata
DROP COLUMN owneraddress,saledate,taxdistrict,propertyaddress

--Updating the columns
SELECT UniqueID ,ParcelID,SaleDateUpdated,Address,City,LandUse,SalePrice,LegalReference,SoldAsVacant,OwnerName,DeliveryAddress,DeliveryCity,DeliveryState,Acreage,LandValue,BuildingValue,TotalValue,YearBuilt,Bedrooms,FullBath,HalfBath
FROM dbo.nashvillehousingdata


--  create a new updated table


SELECT UniqueID, ParcelID, SaleDateUpdated, Address, City, LandUse, SalePrice, LegalReference, SoldAsVacant, OwnerName, DeliveryAddress, DeliveryCity, DeliveryState, Acreage, LandValue, BuildingValue, TotalValue, YearBuilt, Bedrooms, FullBath, HalfBath
INTO  NewNashvillehousing 
FROM dbo.nashvillehousingdata;