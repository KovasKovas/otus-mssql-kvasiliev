/*Задания выполняются с использованием базы данных WideWorldImporters.

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
1. Довставлять в базу пять записей используя insert в таблицу Customers или Suppliers 
*/

INSERT INTO Sales.Customers (CustomerID, CustomerName, BillToCustomerID, CustomerCategoryID, BuyingGroupID
							, PrimaryContactPersonID, AlternateContactPersonID, DeliveryMethodID, DeliveryCityID
							, PostalCityID, CreditLimit, AccountOpenedDate, StandardDiscountPercentage, IsStatementSent
							, IsOnCreditHold, PaymentDays, PhoneNumber, FaxNumber, DeliveryRun, RunPosition, WebsiteURL
							, DeliveryAddressLine1, DeliveryAddressLine2, DeliveryPostalCode, DeliveryLocation
							, PostalAddressLine1, PostalAddressLine2, PostalPostalCode, LastEditedBy, ValidFrom, ValidTo)

VALUES (
			NEXT VALUE FOR Sequences.CustomerID, 'Test customer 1', NEXT VALUE FOR Sequences.CustomerID, 3 ,NULL
			,3121, NULL, 3, 18110
			,18110, 9999, CONVERT(DATE, GETDATE()), 10, 0
			,0, 7, '(215) 555-0101', '(215) 555-0101', '', '' ,'http://somesite_1.com' 
			,'Customer 1 first delivery address line', 'Customer 1 second delivery address line', '0000000000', 0xE6100000010C5B5CE333D9EA44403A07CF8426F755C0
			,'Customer 1 first postal address line', 'Customer 1 second postal address line', '0000000000', 1, CONVERT(DATE, GETDATE()), '99991231'
		),
		(
			NEXT VALUE FOR Sequences.CustomerID, 'Test customer 2', NEXT VALUE FOR Sequences.CustomerID, 3 ,NULL
			,3121, NULL, 3, 18110
			,18110, 9999, CONVERT(DATE, GETDATE()), 10, 0
			,0, 7, '(215) 555-0202', '(215) 555-0202', '', '' ,'http://somesite_2.com' 
			,'Customer 2 first delivery address line', 'Customer 2 second delivery address line', '0000000000', 0xE6100000010C5B5CE333D9EA44403A07CF8426F755C0
			,'Customer 2 first postal address line', 'Customer 2 second postal address line', '0000000000', 1, CONVERT(DATE, GETDATE()), '99991231'
		),
		(
			NEXT VALUE FOR Sequences.CustomerID, 'Test customer 3', NEXT VALUE FOR Sequences.CustomerID, 3 ,NULL
			,3121, NULL, 3, 18110
			,18110, 9999, CONVERT(DATE, GETDATE()), 10, 0
			,0, 7, '(215) 555-0303', '(215) 555-0303', '', '' ,'http://somesite_3.com' 
			,'Customer 3 first delivery address line', 'Customer 3 second delivery address line', '0000000000', 0xE6100000010C5B5CE333D9EA44403A07CF8426F755C0
			,'Customer 3 first postal address line', 'Customer 3 second postal address line', '0000000000', 1, CONVERT(DATE, GETDATE()), '99991231'
		),

		(
			NEXT VALUE FOR Sequences.CustomerID, 'Test customer 4', NEXT VALUE FOR Sequences.CustomerID, 3 ,NULL
			,3121, NULL, 3, 18110
			,18110, 9999, CONVERT(DATE, GETDATE()), 10, 0
			,0, 7, '(215) 555-0404', '(215) 555-0404', '', '' ,'http://somesite_4.com' 
			,'Customer 4 first delivery address line', 'Customer 4 second delivery address line', '0000000000', 0xE6100000010C5B5CE333D9EA44403A07CF8426F755C0
			,'Customer 4 first postal address line', 'Customer 4 second postal address line', '0000000000', 1, CONVERT(DATE, GETDATE()), '99991231'
		),
		(
			NEXT VALUE FOR Sequences.CustomerID, 'Test customer 5', NEXT VALUE FOR Sequences.CustomerID, 3 ,NULL
			,3121, NULL, 3, 18110
			,18110, 9999, CONVERT(DATE, GETDATE()), 10, 0
			,0, 7, '(215) 555-0505', '(215) 555-0505', '', '' ,'http://somesite_5.com' 
			,'Customer 5 first delivery address line', 'Customer 5 second delivery address line', '0000000000', 0xE6100000010C5B5CE333D9EA44403A07CF8426F755C0
			,'Customer 5 first postal address line', 'Customer 5 second postal address line', '0000000000', 1, CONVERT(DATE, GETDATE()), '99991231'
		);
/*
2. Удалите одну запись из Customers, которая была вами добавлена
*/

DELETE FROM Sales.Customers 
WHERE CustomerName = 'Test customer 5';

/*
3. Изменить одну запись, из добавленных через UPDATE
*/

UPDATE Sales.Customers 
SET WebsiteURL = 'http://somesite_5-11.com'
WHERE CustomerName = 'Test customer 5';

/*
4. Написать MERGE, который вставит вставит запись в клиенты, если ее там нет, и изменит если она уже есть
*/

MERGE Sales.Customers AS TARGET 
	USING (

			VALUES(
			1046, 'Test customer 6', 1046, 3 ,NULL
			,3121, NULL, 3, 18110
			,18110, 9999, CONVERT(DATE, GETDATE()), 10, 0
			,0, 7, '(215) 555-0606', '(215) 555-0606', '', '' ,'http://somesite_6.com' 
			,'Customer 6 first delivery address line', 'Customer 6 second delivery address line', '0000000000', 0xE6100000010C5B5CE333D9EA44403A07CF8426F755C0
			,'Customer 6 first postal address line', 'Customer 6 second postal address line', '0000000000', 1, CONVERT(DATE, GETDATE()), '99991231'
			)
		) 
	AS SOURCE (
				CustomerID, CustomerName, BillToCustomerID, CustomerCategoryID, BuyingGroupID
				, PrimaryContactPersonID, AlternateContactPersonID, DeliveryMethodID, DeliveryCityID
				, PostalCityID, CreditLimit, AccountOpenedDate, StandardDiscountPercentage, IsStatementSent
				, IsOnCreditHold, PaymentDays, PhoneNumber, FaxNumber, DeliveryRun, RunPosition, WebsiteURL
				, DeliveryAddressLine1, DeliveryAddressLine2, DeliveryPostalCode, DeliveryLocation
				, PostalAddressLine1, PostalAddressLine2, PostalPostalCode, LastEditedBy, ValidFrom, ValidTo
	) 
	
	ON (TARGET.CustomerID = SOURCE.CustomerID) 
	
	WHEN MATCHED 
		
		THEN UPDATE SET CustomerName = SOURCE.CustomerName, 
						BillToCustomerID = SOURCE.BillToCustomerID, 
						CustomerCategoryID = SOURCE.CustomerCategoryID, 
						BuyingGroupID = SOURCE.BuyingGroupID, 
						PrimaryContactPersonID = SOURCE.PrimaryContactPersonID, 
						AlternateContactPersonID = SOURCE.AlternateContactPersonID, 
						DeliveryMethodID = SOURCE.DeliveryMethodID, 
						DeliveryCityID = SOURCE.DeliveryCityID, 
						PostalCityID = SOURCE.PostalCityID, 
						CreditLimit = SOURCE.CreditLimit, 
						AccountOpenedDate = SOURCE.AccountOpenedDate, 
						StandardDiscountPercentage = SOURCE.StandardDiscountPercentage, 
						IsStatementSent = SOURCE.IsStatementSent, 
						IsOnCreditHold = SOURCE.IsOnCreditHold, 
						PaymentDays = SOURCE.PaymentDays, 
						PhoneNumber = SOURCE.PhoneNumber, 
						FaxNumber = SOURCE.FaxNumber, 
						DeliveryRun = SOURCE.DeliveryRun, 
						RunPosition = SOURCE.RunPosition, 
						WebsiteURL = SOURCE.WebsiteURL, 
						DeliveryAddressLine1 = SOURCE.DeliveryAddressLine1, 
						DeliveryAddressLine2 = SOURCE.DeliveryAddressLine2, 
						DeliveryPostalCode = SOURCE.DeliveryPostalCode, 
						DeliveryLocation = SOURCE.DeliveryLocation, 
						PostalAddressLine1 = SOURCE.PostalAddressLine1, 
						PostalAddressLine2 = SOURCE.PostalAddressLine2, 
						PostalPostalCode = SOURCE.PostalPostalCode, 
						LastEditedBy = SOURCE.LastEditedBy, 
						ValidFrom = SOURCE.ValidFrom, 
						ValidTo = SOURCE.ValidTo
	
	WHEN NOT MATCHED THEN 
	
		INSERT (CustomerID, CustomerName, BillToCustomerID, CustomerCategoryID, BuyingGroupID
				, PrimaryContactPersonID, AlternateContactPersonID, DeliveryMethodID, DeliveryCityID
				, PostalCityID, CreditLimit, AccountOpenedDate, StandardDiscountPercentage, IsStatementSent
				, IsOnCreditHold, PaymentDays, PhoneNumber, FaxNumber, DeliveryRun, RunPosition, WebsiteURL
				, DeliveryAddressLine1, DeliveryAddressLine2, DeliveryPostalCode, DeliveryLocation
				, PostalAddressLine1, PostalAddressLine2, PostalPostalCode, LastEditedBy, ValidFrom, ValidTo)

		VALUES(
			1046, 'Test customer 6', 1046, 3 ,NULL
			,3121, NULL, 3, 18110
			,18110, 9999, CONVERT(DATE, GETDATE()), 10, 0
			,0, 7, '(215) 555-0606', '(215) 555-0606', '', '' ,'http://somesite_6.com' 
			,'Customer 6 first delivery address line', 'Customer 6 second delivery address line', '0000000000', 0xE6100000010C5B5CE333D9EA44403A07CF8426F755C0
			,'Customer 6 first postal address line', 'Customer 6 second postal address line', '0000000000', 1, CONVERT(DATE, GETDATE()), '99991231'
			)
	
	;

/*
5. Напишите запрос, который выгрузит данные через bcp out и загрузить через bulk insert
*/
DECLARE
	@CmdScript VARCHAR(8000)

SET @CmdScript = 'bcp "[WideWorldImporters].[Application].[DeliveryMethods]" out  "C:\Test\DeliveryMethods.txt" -T -w -t#, -S '
SET @CmdScript = @CmdScript + (SELECT [NAME] FROM sys.servers)

SELECT @CmdScript

EXEC master..xp_cmdshell @CmdScript

DROP TABLE IF EXISTS Application.DeliveryMethods_BCP_Rreceiver;
GO

SELECT 
	* 
INTO Application.DeliveryMethods_BCP_Receiver
FROM 
	Application.DeliveryMethods
WHERE
	1=0;

BULK INSERT Application.DeliveryMethods_BCP_Receiver
			FROM "C:\Test\DeliveryMethods.txt"
			WITH 
				(
				BATCHSIZE = 1000, 
				DATAFILETYPE = 'widechar',
				FIELDTERMINATOR = '#,',
				ROWTERMINATOR ='\n',
				KEEPNULLS,
				TABLOCK        
				);
GO

SELECT * FROM Application.DeliveryMethods_BCP_Receiver;
GO

DROP TABLE IF EXISTS Application.DeliveryMethods_BCP_Receiver;
GO