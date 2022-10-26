/*
Домашнее задание по курсу MS SQL Server Developer в OTUS.

Занятие "08 - Выборки из XML и JSON полей".

Задания выполняются с использованием базы данных WideWorldImporters.

Бэкап БД можно скачать отсюда:
https://github.com/Microsoft/sql-server-samples/releases/tag/wide-world-importers-v1.0
Нужен WideWorldImporters-Full.bak

Описание WideWorldImporters от Microsoft:
* https://docs.microsoft.com/ru-ru/sql/samples/wide-world-importers-what-is
* https://docs.microsoft.com/ru-ru/sql/samples/wide-world-importers-oltp-database-catalog
*/

-- ---------------------------------------------------------------------------
-- Задание - написать выборки для получения указанных ниже данных.
-- ---------------------------------------------------------------------------

USE WideWorldImporters

/*
Примечания к заданиям 1, 2:
* Если с выгрузкой в файл будут проблемы, то можно сделать просто SELECT c результатом в виде XML. 
* Если у вас в проекте предусмотрен экспорт/импорт в XML, то можете взять свой XML и свои таблицы.
* Если с этим XML вам будет скучно, то можете взять любые открытые данные и импортировать их в таблицы (например, с https://data.gov.ru).
* Пример экспорта/импорта в файл https://docs.microsoft.com/en-us/sql/relational-databases/import-export/examples-of-bulk-import-and-export-of-xml-documents-sql-server
*/


/*
1. В личном кабинете есть файл StockItems.xml.
Это данные из таблицы Warehouse.StockItems.
Преобразовать эти данные в плоскую таблицу с полями, аналогичными Warehouse.StockItems.
Поля: StockItemName, SupplierID, UnitPackageID, OuterPackageID, QuantityPerOuter, TypicalWeightPerUnit, LeadTimeDays, IsChillerStock, TaxRate, UnitPrice 

Загрузить эти данные в таблицу Warehouse.StockItems: 
существующие записи в таблице обновить, отсутствующие добавить (сопоставлять записи по полю StockItemName). 

Сделать два варианта: с помощью OPENXML и через XQuery.
*/

--OPEN XML METHOD
DECLARE 
	@xmlStockItems XML
	,@docHandle INT

SELECT @xmlStockItems = BulkColumn
FROM OPENROWSET
	(
		BULK 'C:\Test\StockItems-188-1fb5df.xml', 
		SINGLE_CLOB
	)
AS StockData;

EXEC sp_xml_preparedocument @docHandle OUTPUT, @xmlStockItems;

DROP TABLE IF EXISTS Warehouse.StockItemsXML;

CREATE TABLE Warehouse.StockItemsXML
(
	StockItemName NVARCHAR (100)
	, SupplierID INT
	, UnitPackageID INT
	, OuterPackageID INT
	, QuantityPerOuter INT
	, TypicalWeightPerUnit DECIMAL(18,3)
	, LeadTimeDays INT
	, IsChillerStock BIT
	, TaxRate DECIMAL(18,3)
	, UnitPrice DECIMAL(18,2)
);

INSERT INTO Warehouse.StockItemsXML
SELECT * FROM OPENXML(@docHandle, N'/StockItems/Item')
WITH ( 
	StockItemName NVARCHAR (100) '@Name'
	, SupplierID INT 'SupplierID'
	, UnitPackageID INT 'Package/UnitPackageID'
	, OuterPackageID INT 'Package/OuterPackageID'
	, QuantityPerOuter INT 'Package/QuantityPerOuter' 
	, TypicalWeightPerUnit DECIMAL(18,3) 'Package/TypicalWeightPerUnit'
	, LeadTimeDays INT 'LeadTimeDays'
	, IsChillerStock BIT 'IsChillerStock'
	, TaxRate DECIMAL(18,3) 'TaxRate'
	, UnitPrice DECIMAL(18,2) 'UnitPrice'
);

EXEC sp_xml_removedocument @docHandle;

SELECT * FROM Warehouse.StockItemsXML;
TRUNCATE TABLE Warehouse.StockItemsXML;

--XQUERY METHOD

INSERT INTO Warehouse.StockItemsXML
SELECT  
	xTable.Items.value('(@Name)', 'varchar(100)') as [Id]
	,xTable.Items.value('(SupplierID[1])', 'INT') 
	,xTable.Items.value('(Package/UnitPackageID)[1]', 'INT')
	,xTable.Items.value('(Package/OuterPackageID)[1]', 'INT')
	,xTable.Items.value('(Package/QuantityPerOuter)[1]', 'INT')
	,xTable.Items.value('(Package/TypicalWeightPerUnit)[1]', 'DECIMAL(18,3)')
	,xTable.Items.value('(LeadTimeDays)[1]', 'INT')
	,xTable.Items.value('(IsChillerStock)[1]', 'BIT')
	,xTable.Items.value('(TaxRate)[1]', 'DECIMAL(18,3)')
	,xTable.Items.value('(UnitPrice)[1]', 'DECIMAL(18,2)')
FROM 
	@xmlStockItems.nodes('/StockItems/Item') as xTable(Items);
GO


SELECT * FROM Warehouse.StockItemsXML;
DROP TABLE IF EXISTS Warehouse.StockItemsXML;

/*
2. Выгрузить данные из таблицы StockItems в такой же xml-файл, как StockItems.xml
*/

SELECT TOP 15
	StockItemName [@StockItemName]
	, SupplierID [SupplierID]
	, UnitPackageID [Package/UnitPackageID]
	, OuterPackageID [Package/OuterPackageID]
	, QuantityPerOuter [Package/QuantityPerOuter]
	, TypicalWeightPerUnit [Package/TypicalWeightPerUnit]
	, IsChillerStock [IsChillerStock]
	, TaxRate [TaxRate]
	, UnitPrice [UnitPrice]
FROM 
	Warehouse.StockItems
FOR XML PATH('Item'), ROOT('StockItems')

/*
3. В таблице Warehouse.StockItems в колонке CustomFields есть данные в JSON.
Написать SELECT для вывода:
- StockItemID
- StockItemName
- CountryOfManufacture (из CustomFields)
- FirstTag (из поля CustomFields, первое значение из массива Tags)
*/
SELECT TOP 10
	StockItemID
	,StockItemName
	,JSON_VALUE(CustomFields, '$.CountryOfManufacture') AS CountryOfManufacture
	,COALESCE(JSON_VALUE(CustomFields, '$.Tags[0]'), 'No first tag value') AS FirstTag
	,CustomFields
FROM
	Warehouse.StockItems

/*
4. Найти в StockItems строки, где есть тэг "Vintage".
Вывести: 
- StockItemID
- StockItemName
- (опционально) все теги (из CustomFields) через запятую в одном поле
*/

SELECT
	StockItemID
	,StockItemName
FROM
	Warehouse.StockItems
	CROSS APPLY OPENJSON(CustomFields, '$.Tags') Tags
WHERE
	Tags.value = 'Vintage'

SELECT
	StockItemID
	,StockItemName
	,STRING_AGG(CONVERT(NVARCHAR(3),Tags.[key]) + ':' + Tags.value,', ') AS Tags
FROM
	Warehouse.StockItems
	CROSS APPLY OPENJSON(CustomFields, '$.Tags') Tags
GROUP BY
	StockItemID
	,StockItemName
/*
Тэги искать в поле CustomFields, а не в Tags.
Запрос написать через функции работы с JSON.
Для поиска использовать равенство, использовать LIKE запрещено.

Должно быть в таком виде:
... where ... = 'Vintage'

Так принято не будет:
... where ... Tags like '%Vintage%'
... where ... CustomFields like '%Vintage%' 
*/



