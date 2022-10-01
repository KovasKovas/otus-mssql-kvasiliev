/*
Домашнее задание по курсу MS SQL Server Developer в OTUS.
Занятие "02 - Оператор SELECT и простые фильтры, GROUP BY, HAVING".

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
1. Посчитать среднюю цену товара, общую сумму продажи по месяцам.
Вывести:
* Год продажи (например, 2015)
* Месяц продажи (например, 4)
* Средняя цена за месяц по всем товарам
* Общая сумма продаж за месяц

Продажи смотреть в таблице Sales.Invoices и связанных таблицах.
*/

SELECT 
	YEAR(SI.InvoiceDate) AS SaleYear
	,DATEPART(MONTH,SI.InvoiceDate) AS SaleMonth
	,AVG(SIL.[UnitPrice]) AS AvgPrice
	,SUM([UnitPrice] * Quantity) AS MonthlyTotal
FROM
	[Sales].[Invoices] SI
	INNER JOIN [Sales].[InvoiceLines] SIL
	ON SI.InvoiceID = SIL.InvoiceID 
GROUP BY
	YEAR(SI.InvoiceDate)
	,DATEPART(MONTH,SI.InvoiceDate)
ORDER BY 
	SaleYear, SaleMonth

/*
2. Отобразить все месяцы, где общая сумма продаж превысила 4 600 000

Вывести:
* Год продажи (например, 2015)
* Месяц продажи (например, 4)
* Общая сумма продаж

Продажи смотреть в таблице Sales.Invoices и связанных таблицах.
*/

SELECT 
	YEAR(SI.InvoiceDate) AS SaleYear
	,DATEPART(MONTH,SI.InvoiceDate) AS SaleMonth
	,SUM([UnitPrice] * Quantity) AS MonthlyTotal
FROM
	[Sales].[Invoices] SI
	INNER JOIN [Sales].[InvoiceLines] SIL
	ON SI.InvoiceID = SIL.InvoiceID 
GROUP BY
	YEAR(SI.InvoiceDate)
	,DATEPART(MONTH,SI.InvoiceDate)
HAVING
	SUM([UnitPrice] * Quantity) > 4600000
ORDER BY 
	SaleYear, SaleMonth;
/*
3. Вывести сумму продаж, дату первой продажи
и количество проданного по месяцам, по товарам,
продажи которых менее 50 ед в месяц.
Группировка должна быть по году,  месяцу, товару.

Вывести:
* Год продажи
* Месяц продажи
* Наименование товара
* Сумма продаж
* Дата первой продажи
* Количество проданного

Продажи смотреть в таблице Sales.Invoices и связанных таблицах.
*/

SELECT 
	YEAR(SI.InvoiceDate) AS SaleYear
	,DATEPART(MONTH,SI.InvoiceDate) AS SaleMonth
	,SIL.Description AS StockName
	,SUM([UnitPrice] * Quantity) AS SalesTotal
	,MIN(SI.InvoiceDate) AS FirstSaleDate
	,SUM(SIL.Quantity) AS SalesQty
FROM
	[Sales].[Invoices] SI
	INNER JOIN [Sales].[InvoiceLines] SIL
	ON SI.InvoiceID = SIL.InvoiceID 
GROUP BY
	YEAR(SI.InvoiceDate)
	,DATEPART(MONTH,SI.InvoiceDate)
	,SIL.Description 
HAVING
	SUM(SIL.Quantity) > 50
ORDER BY 
	SaleYear, SaleMonth;

-- ---------------------------------------------------------------------------
-- Опционально
-- ---------------------------------------------------------------------------
/*
Написать запросы 2-3 так, чтобы если в каком-то месяце не было продаж,
то этот месяц также отображался бы в результатах, но там были нули.
*/

--Запрос из п.2

WITH DateTable 
AS 
(
	SELECT * 
	FROM
		(VALUES (2013), (2014), (2015), (2016)) AS YRS (FYEAR)
		CROSS JOIN 
		(VALUES(1), (2), (3), (4), (5), (6), (7), (8), (9), (10), (11), (12)) AS MNTH (FMONTH)
)


SELECT
	FYEAR AS SaleYear
	,FMONTH AS SaleMonth
	,COALESCE(MonthlyTotal,0) AS MonthlyTotal
FROM
	DateTable
	LEFT JOIN (
		SELECT 
			YEAR(SI.InvoiceDate) AS SaleYear
			,DATEPART(MONTH,SI.InvoiceDate) AS SaleMonth
			,SUM([UnitPrice] * Quantity) AS MonthlyTotal
		FROM
			[Sales].[Invoices] SI
			INNER JOIN [Sales].[InvoiceLines] SIL
			ON SI.InvoiceID = SIL.InvoiceID 
		GROUP BY
			YEAR(SI.InvoiceDate)
			,DATEPART(MONTH,SI.InvoiceDate)
		HAVING
			SUM([UnitPrice] * Quantity) > 4600000
		) ReportData
			ON FYEAR = SaleYear
			AND FMONTH = SaleMonth 
	ORDER BY
		SaleYear, SaleMonth;

--Запрос из п.3

WITH DateTable 
AS 
(
	SELECT * 
	FROM
		(VALUES (2013), (2014), (2015), (2016)) AS YRS (FYEAR)
		CROSS JOIN 
		(VALUES(1), (2), (3), (4), (5), (6), (7), (8), (9), (10), (11), (12)) AS MNTH (FMONTH)
)
SELECT
	FYEAR AS SaleYear
	,FMONTH AS SaleMonth
	,StockName
	,COALESCE(SalesTotal,0) AS SalesTotal
	,FirstSaleDate
	, COALESCE(SalesQty,0) AS SalesQty
FROM
	DateTable
	LEFT JOIN (
		SELECT 
			YEAR(SI.InvoiceDate) AS SaleYear
			,DATEPART(MONTH,SI.InvoiceDate) AS SaleMonth
			,SIL.Description AS StockName
			,SUM([UnitPrice] * Quantity) AS SalesTotal
			,MIN(SI.InvoiceDate) AS FirstSaleDate
			,SUM(SIL.Quantity) AS SalesQty
		FROM
			[Sales].[Invoices] SI
			INNER JOIN [Sales].[InvoiceLines] SIL
			ON SI.InvoiceID = SIL.InvoiceID 
		GROUP BY
			YEAR(SI.InvoiceDate)
			,DATEPART(MONTH,SI.InvoiceDate)
			,SIL.Description 
		HAVING
			SUM(SIL.Quantity) > 50
		) ReportData
		ON FYEAR = SaleYear
		AND FMONTH = SaleMonth 
ORDER BY
	SaleYear, SaleMonth