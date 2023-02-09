select * 
from CovidPortfolio..NashvilleHousing
--standardize date format


alter table CovidPortfolio..NashvilleHousing
add SaleDateConverted date

update CovidPortfolio..NashvilleHousing
set SaleDateConverted=convert(date,SaleDate)

select * 
from CovidPortfolio..NashvilleHousing
where PropertyAddress is null
order by 2



--populate property address data
select a.ParcelID,b.ParcelID,a.PropertyAddress,b.PropertyAddress, isnull(a.PropertyAddress,b.PropertyAddress)
from CovidPortfolio..NashvilleHousing a
join CovidPortfolio..NashvilleHousing b
on a.ParcelID=b.ParcelID
and a.[UniqueID ]<>b.[UniqueID ]
where a.PropertyAddress is null

update a
set PropertyAddress=isnull(a.PropertyAddress,b.PropertyAddress)
from CovidPortfolio..NashvilleHousing a
join CovidPortfolio..NashvilleHousing b
on a.ParcelID=b.ParcelID
and a.[UniqueID ]<>b.[UniqueID ]
where a.PropertyAddress is null


--breaking address into individual columns (Address,City,State)
select PropertyAddress 
from CovidPortfolio..NashvilleHousing

select 
SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1),
SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress))
from CovidPortfolio..NashvilleHousing


alter table CovidPortfolio..NashvilleHousing
add PropertySplitedAddress nvarchar(255)

update CovidPortfolio..NashvilleHousing
set PropertySplitedAddress=SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1)

alter table CovidPortfolio..NashvilleHousing
add PropertyCity nvarchar(255)

update CovidPortfolio..NashvilleHousing
set PropertyCity=SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress))


select OwnerAddress
from CovidPortfolio..NashvilleHousing
where OwnerAddress is not null

select PARSENAME(REPLACE(OwnerAddress,',','.'),3),
PARSENAME(REPLACE(OwnerAddress,',','.'),2),
PARSENAME(REPLACE(OwnerAddress,',','.'),1)
from CovidPortfolio..NashvilleHousing

alter table CovidPortfolio..NashvilleHousing
add OwnerSplitedAddress nvarchar(255)

update CovidPortfolio..NashvilleHousing
set OwnerSplitedAddress=PARSENAME(REPLACE(OwnerAddress,',','.'),3)

alter table CovidPortfolio..NashvilleHousing
add OwnerSplitedCity nvarchar(255)

update CovidPortfolio..NashvilleHousing
set OwnerSplitedCity=PARSENAME(REPLACE(OwnerAddress,',','.'),2)

alter table CovidPortfolio..NashvilleHousing
add OwnerSplitedState nvarchar(255)

update CovidPortfolio..NashvilleHousing
set OwnerSplitedState=PARSENAME(REPLACE(OwnerAddress,',','.'),1)

select OwnerAddress,OwnerSplitedAddress,OwnerSplitedCity,OwnerSplitedState
from CovidPortfolio..NashvilleHousing


--Change Y & N to Yes & No in 'Sold as Vacant' field
select distinct SoldasVacant, count(SoldasVacant)
from CovidPortfolio..NashvilleHousing
group by SoldasVacant

select SoldasVacant,
case when SoldasVacant = 'Y' then 'Yes'
     when SoldasVacant = 'N' then 'No'
	 else SoldasVacant
	 end
from CovidPortfolio..NashvilleHousing

update CovidPortfolio..NashvilleHousing
set SoldasVacant =
case when SoldasVacant = 'Y' then 'Yes'
     when SoldasVacant = 'N' then 'No'
	 else SoldasVacant
	 end

-- remove duplicate
with CTErownum as (
select *,row_number() over(
         partition by ParcelID,PropertyAddress,SaleDate,SalePrice,LegalReference
		 order by UniqueID) rownum
from CovidPortfolio..NashvilleHousing
--order by ParcelID
)

select *
from CTErownum
where rownum>1
--order by ParcelID


--delete unused columns
alter table CovidPortfolio..NashvilleHousing
drop column PropertyAddress,SaleDate,OwnerAddress,TaxDistrict

select * 
from CovidPortfolio..NashvilleHousing