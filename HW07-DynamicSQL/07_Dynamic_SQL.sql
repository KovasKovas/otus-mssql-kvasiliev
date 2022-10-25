/*Это задание из занятия "Операторы CROSS APPLY, PIVOT, UNPIVOT."
Нужно для него написать динамический PIVOT, отображающий результаты по всем клиентам.
Имя клиента указывать полностью из поля CustomerName.

Требуется написать запрос, который в результате своего выполнения 
формирует сводку по количеству покупок в разрезе клиентов и месяцев.
В строках должны быть месяцы (дата начала месяца), в столбцах - клиенты.

Дата должна иметь формат dd.mm.yyyy, например, 25.12.2019.

Пример, как должны выглядеть результаты:
-------------+--------------------+--------------------+----------------+----------------------
InvoiceMonth | Aakriti Byrraju    | Abel Spirlea       | Abel Tatarescu | ... (другие клиенты)
-------------+--------------------+--------------------+----------------+----------------------
01.01.2013   |      3             |        1           |      4         | ...
01.02.2013   |      7             |        3           |      4         | ...
-------------+--------------------+--------------------+----------------+----------------------
*/

DECLARE
	@CustomersList NVARCHAR(MAX)
	,@FieldsListForSelect NVARCHAR(MAX)
	,@SQL NVARCHAR(MAX)


SET @CustomersList = (
	SELECT 
		'[' + CustomerName + '],' AS 'data()'  
	FROM 
		Sales.Customers  
	FOR XML PATH('')
	)

SET @CustomersList = SUBSTRING(@CustomersList, 1, LEN(@CustomersList) - 1)

SET @FieldsListForSelect = (
	SELECT 
		'COALESCE([' + CustomerName + '], 0) AS [' + CustomerName + '],' AS 'data()'  
	FROM 
		Sales.Customers  
	FOR XML PATH('')
)

SET @FieldsListForSelect = SUBSTRING(@FieldsListForSelect, 1, LEN(@FieldsListForSelect) - 1)

SET @SQL = '
	WITH TailspinToysSales AS
	(
		SELECT
			FORMAT(DATEADD(dd, -(DAY(InvoiceDate)-1), InvoiceDate),''dd.MM.yyyy'') AS InvoiceMonth
			,CUST.CustomerName
			,SUM(STRN.TransactionAmount) AS TotalSales
		FROM
			[Sales].[Invoices] SINV
			INNER JOIN [Sales].[CustomerTransactions] STRN
			ON SINV.InvoiceID = STRN.InvoiceID 
			INNER JOIN [Sales].[Customers] CUST
			ON SINV.CustomerID = CUST.CustomerID 
		GROUP BY
			FORMAT(DATEADD(dd, -(DAY(InvoiceDate)-1), InvoiceDate),''dd.MM.yyyy'') 
			,CUST.CustomerName
	)

	SELECT 
		InvoiceMonth
		,'
		+ @FieldsListForSelect +

		'
	FROM 
		TailspinToysSales
	PIVOT
		(
			SUM(TotalSales)
			FOR CustomerName IN (
				'
				+ @CustomersList +
				
				'
			)
		) AS PVT;'

EXEC sp_executesql @SQL 