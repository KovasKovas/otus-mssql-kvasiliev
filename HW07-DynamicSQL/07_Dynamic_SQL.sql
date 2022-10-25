/*��� ������� �� ������� "��������� CROSS APPLY, PIVOT, UNPIVOT."
����� ��� ���� �������� ������������ PIVOT, ������������ ���������� �� ���� ��������.
��� ������� ��������� ��������� �� ���� CustomerName.

��������� �������� ������, ������� � ���������� ������ ���������� 
��������� ������ �� ���������� ������� � ������� �������� � �������.
� ������� ������ ���� ������ (���� ������ ������), � �������� - �������.

���� ������ ����� ������ dd.mm.yyyy, ��������, 25.12.2019.

������, ��� ������ ��������� ����������:
-------------+--------------------+--------------------+----------------+----------------------
InvoiceMonth | Aakriti Byrraju    | Abel Spirlea       | Abel Tatarescu | ... (������ �������)
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