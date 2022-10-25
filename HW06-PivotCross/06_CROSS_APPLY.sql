/*
Домашнее задание по курсу MS SQL Server Developer в OTUS.

Занятие "05 - Операторы CROSS APPLY, PIVOT, UNPIVOT".

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

USE WideWorldImporters;
GO

/*
1. Требуется написать запрос, который в результате своего выполнения 
формирует сводку по количеству покупок в разрезе клиентов и месяцев.
В строках должны быть месяцы (дата начала месяца), в столбцах - клиенты.

Клиентов взять с ID 2-6, это все подразделение Tailspin Toys.
Имя клиента нужно поменять так чтобы осталось только уточнение.
Например, исходное значение "Tailspin Toys (Gasport, NY)" - вы выводите только "Gasport, NY".
Дата должна иметь формат dd.mm.yyyy, например, 25.12.2019.

Пример, как должны выглядеть результаты:
-------------+--------------------+--------------------+-------------+--------------+------------
InvoiceMonth | Peeples Valley, AZ | Medicine Lodge, KS | Gasport, NY | Sylvanite, MT | Jessie, ND
-------------+--------------------+--------------------+-------------+--------------+------------
01.01.2013   |      3             |        1           |      4      |      2        |     2
01.02.2013   |      7             |        3           |      4      |      2        |     1
-------------+--------------------+--------------------+-------------+--------------+------------
*/

WITH TailspinToysSales AS
(
	SELECT
		FORMAT(InvoiceDate,'dd.MM.yyyy') AS InvoiceMonth
		,CUST.CustomerName
		,SUM(STRN.TransactionAmount) AS TotalSales
	FROM
		[Sales].[Invoices] SINV
		INNER JOIN [Sales].[CustomerTransactions] STRN
		ON SINV.InvoiceID = STRN.InvoiceID 
		INNER JOIN [Sales].[Customers] CUST
		ON SINV.CustomerID = CUST.CustomerID 
	WHERE
		SINV.CustomerID BETWEEN 2 AND 6
	GROUP BY
		FORMAT(InvoiceDate,'dd.MM.yyyy') 
		,CUST.CustomerName
)

SELECT 
	InvoiceMonth
	,COALESCE([Tailspin Toys (Sylvanite, MT)], 0) AS [Sylvanite, MT]
	,COALESCE([Tailspin Toys (Peeples Valley, AZ)], 0) AS [Peeples Valley, AZ]
	,COALESCE([Tailspin Toys (Medicine Lodge, KS)], 0) AS [Medicine Lodge, KS]
	,COALESCE([Tailspin Toys (Gasport, NY)], 0) AS [Gasport, NY]
	,COALESCE([Tailspin Toys (Jessie, ND)], 0) AS [Jessie, ND]
FROM 
	TailspinToysSales
PIVOT
	(
		SUM(TotalSales)
		FOR CustomerName IN (
			[Tailspin Toys (Sylvanite, MT)]
			, [Tailspin Toys (Peeples Valley, AZ)]
			, [Tailspin Toys (Medicine Lodge, KS)]
			, [Tailspin Toys (Gasport, NY)]
			, [Tailspin Toys (Jessie, ND)]
		)
	) AS PVT;


/*
2. Для всех клиентов с именем, в котором есть "Tailspin Toys"
вывести все адреса, которые есть в таблице, в одной колонке.

Пример результата:
----------------------------+--------------------
CustomerName                | AddressLine
----------------------------+--------------------
Tailspin Toys (Head Office) | Shop 38
Tailspin Toys (Head Office) | 1877 Mittal Road
Tailspin Toys (Head Office) | PO Box 8975
Tailspin Toys (Head Office) | Ribeiroville
----------------------------+--------------------
*/

SELECT 
	CustomerName
	, AddressLine
FROM (
		SELECT
			CustomerName
			,PostalAddressLine1
			,PostalAddressLine2
		FROM
			[Sales].[Customers]
		WHERE
			CustomerName LIKE '%Tailspin Toys%'
	) TailspinToys
UNPIVOT (
	AddressLine FOR AddressType IN (PostalAddressLine1, PostalAddressLine2)
) AS UnPVT;

/*
3. В таблице стран (Application.Countries) есть поля с цифровым кодом страны и с буквенным.
Сделайте выборку ИД страны, названия и ее кода так, 
чтобы в поле с кодом был либо цифровой либо буквенный код.

Пример результата:
--------------------------------
CountryId | CountryName | Code
----------+-------------+-------
1         | Afghanistan | AFG
1         | Afghanistan | 4
3         | Albania     | ALB
3         | Albania     | 8
----------+-------------+-------
*/

SELECT 
	CountryId
	,CountryName
	,Code
FROM (
		SELECT
			[CountryID]
			,[CountryName]
			,CONVERT(NVARCHAR(3),[IsoNumericCode]) AS [IsoNumericCode]
			,[IsoAlpha3Code]
		FROM
			[Application].[Countries]
	) CountryCodes
UNPIVOT (
	Code FOR CountryCodes IN ([IsoAlpha3Code], [IsoNumericCode])
) AS UnPVT;

/*
4. Выберите по каждому клиенту два самых дорогих товара, которые он покупал.
В результатах должно быть ид клиета, его название, ид товара, цена, дата покупки.
*/

SELECT
	CUST.CustomerID 
	,CUST.CustomerName  
	,TwoMostExpenciveGoods.StockItemID 
	,TwoMostExpenciveGoods.UnitPrice  
	,TwoMostExpenciveGoods.InvoiceDate  
FROM
	Sales.Customers CUST
	OUTER APPLY (
			SELECT
				*
			FROM (	
				SELECT 
					SILN.StockItemID  
					,SINV.CustomerID
					,SINV.InvoiceDate 
					,SILN.UnitPrice	
					,ROW_NUMBER() OVER ( PARTITION BY SINV.CustomerID ORDER BY SILN.UnitPrice DESC) as PriceRank
				FROM
					Sales.Invoices SINV
					INNER JOIN Sales.InvoiceLines SILN
					ON SINV.InvoiceID = SILN.InvoiceID 
				) SalesByCustomer
			WHERE
				SalesByCustomer.PriceRank <= 2
				AND SalesByCustomer.CustomerID = CUST.CustomerID
		) TwoMostExpenciveGoods
