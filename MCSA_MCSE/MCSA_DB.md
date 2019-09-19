# MCSA/MCSE SQL #

## MCSA: SQL 2016 Database Development ##

1. Exam 70-761 Transact-SQL によるデータのクエリ

   情報元：[コース 20761C: Querying Data with Transact-SQL](https://www.microsoft.com/ja-jp/learning/course.aspx?cid=20761)

    1. Introduction to Microsoft SQL Server

        1. The Basic Architecture of SQL Server
        1. SQL Server Editions and Versions
        1. Getting Started with SQL Server Management Studio

    1. Introduction to T-SQL Querying

        1. Introducing T-SQL
        1. Understanding Sets
        1. Understanding Predicate Logic
        1. Understanding the Logical Order of Operations in SELECT statements

    1. Writing SELECT Queries

        1. Writing Simple SELECT Statements
        1. Eliminating Duplicates with DISTINCT
        1. Using Column and Table Aliases
        1. Writing Simple CASE Expressions

    1. Querying Multiple Tables

        1. Understanding Joins
        1. Querying with Inner Joins
        1. Querying with Outer Joins
        1. Querying with Cross Joins and Self Joins

    1. Sorting and Filtering Data

        1. Sorting Data
        1. Filtering Data with Predicates
        1. Filtering Data with TOP and OFFSET-FETCH
        1. Working with Unknown Values

    1. Working with SQL Server Data Types

        1. Introducing SQL Server Data Types
        1. Working with Character Data
        1. Working with Date and Time Data

    1. Using DML to Modify Data

        1. Adding Data to Tables
        1. Modifying and Removing Data
        1. Generating automatic column values

    1. Using Built-In Functions

        1. Writing Queries with Built-In Functions
        1. Using Conversion Functions
        1. Using Logical Functions
        1. Using Functions to Work with NULL

    1. Grouping and Aggregating Data

        1. Using Aggregate Functions
        1. Using the GROUP BY Clause
        1. Filtering Groups with HAVING

    1. Using Subqueries

        1. Writing Self-Contained Subqueries
        1. Writing Correlated Subqueries
        1. Using the EXISTS Predicate with Subqueries

    1. Using Table Expressions

        1. Using Views
        1. Using Inline Table-Valued Functions
        1. Using Derived Tables
        1. Using Common Table Expressions

    1. Using Set Operators

        1. Writing Queries with the UNION operator
        1. Using EXCEPT and INTERSECT
        1. Using APPLY

    1. Using Windows Ranking, Offset, and Aggregate Functions

        1. Creating Windows with OVER
        1. Exploring Window Functions

    1. Pivoting and Grouping Sets

        1. Writing Queries with PIVOT and UNPIVOT
        1. Working with Grouping Sets

    1. Executing Stored Procedures

        1. Querying Data with Stored Procedures
        1. Passing Parameters to Stored procedures
        1. Creating Simple Stored Procedures
        1. Working with Dynamic SQL

    1. Programming with T-SQL

        1. T-SQL Programming Elements
        1. Controlling Program Flow

    1. Implementing Error Handling

        1. Implementing T-SQL error handling
        1. Implementing structured exception handling

    1. Implementing Transactions

        1. Transactions and the database engines
        1. Controlling transactions

1. Exam 70-762 SQL データベースの開発

    情報元：[コース 20762C: Developing SQL Databases](https://www.microsoft.com/ja-jp/learning/course.aspx?cid=20762)

    1. Introduction to Database Development

        1. Introduction to the SQL Server Platform
        1. SQL Server Database Development Tasks

    1. Designing and Implementing Tables

        1. Designing Tables
        1. Data Types
        1. Working with Schemas
        1. Creating and Altering Tables

    1. Advanced Table Designs

        1. Partitioning Data
        1. Compressing Data
        1. Temporal Tables

    1. Ensuring Data Integrity through Constraints

        1. Enforcing Data Integrity
        1. Implementing Data Domain Integrity
        1. Implementing Entity and Referential Integrity

    1. Introduction to Indexes

        1. Core Indexing Concepts
        1. Data Types and Indexes
        1. Heaps, Clustered, and Nonclustered Indexes
        1. Single Column and Composite Indexes

    1. Designing Optimized Index Strategies

        1. Index Strategies
        1. Managing Indexes
        1. Execution Plans
        1. The Database Engine Tuning Advisor
        1. Query Store

    1. Columnstore Indexes

        1. Introduction to Columnstore Indexes
        1. Creating Columnstore Indexes
        1. Working with Columnstore Indexes

    1. Designing and Implementing Views

        1. Introduction to Views
        1. Creating and Managing Views
        1. Performance Considerations for Views

    1. Designing and Implementing Stored Procedures

        1. Introduction to Stored Procedures
        1. Working with Stored Procedures
        1. Implementing Parameterized Stored Procedures
        1. Controlling Execution Context

    1. Designing and Implementing User-Defined Functions

        1. Overview of Functions
        1. Designing and Implementing Scalar Functions
        1. Designing and Implementing Table-Valued Functions
        1. Considerations for Implementing Functions
        1. Alternatives to Functions

    1. Responding to Data Manipulation via Triggers

        1. Designing DML Triggers
        1. Implementing DML Triggers
        1. Advanced Trigger Concepts

    1. Using In-Memory Tables

        1. Memory-Optimized Tables
        1. Natively Compiled Stored Procedures

    1. Implementing Managed Code in SQL Server

        1. Introduction to CLR Integration in SQL Server
        1. Implementing and Publishing CLR Assemblies

    1. Storing and Querying XML Data in SQL Server

        1. Introduction to XML and XML Schemas
        1. Storing XML Data and Schemas in SQL Server
        1. Implementing the XML Data Type
        1. Using the Transact-SQL FOR XML Statement
        1. Getting Started with XQuery
        1. Shredding XML

    1. Storing and Querying Spatial Data in SQL Server

        1. Introduction to Spatial Data
        1. Working with SQL Server Spatial Data Types
        1. Using Spatial Data in Applications

    1. Storing and Querying BLOBs and Text Documents in SQL Server

        1. Considerations for BLOB Data
        1. Working with FILESTREAM
        1. Using Full-Text Search

    1. SQL Server Concurrency

        1. Concurrency and Transactions
        1. Locking Internals

    1. Performance and Monitoring

        1. Extended Events
        1. Working with extended Events
        1. Live Query Statistics
        1. Optimize Database File Configuration
        1. Metrics

[参考](https://www.microsoft.com/ja-jp/learning/mcsa-sql2016-database-development-certification.aspx)

## MCSA: SQL 2016 データベース管理 ##

1. Exam 70-764 SQL データベースインフラストラクチャの管理

    情報元：[コース 20764C: Administering a SQL Database Infrastructure](https://www.microsoft.com/ja-jp/learning/course.aspx?cid=20764)

    1. SQL Server Security

        1. Authenticating Connections to SQL Server
        1. Authorizing Logins to Connect to databases
        1. Authorization Across Servers
        1. Partially Contained Databases

    1. Assigning Server and Database Roles

        1. Working with server roles
        1. Working with Fixed Database Roles
        1. Assigning User-Defined Database Roles

    1. Authorizing Users to Access Resources

        1. Authorizing User Access to Objects
        1. Authorizing Users to Execute Code
        1. Configuring Permissions at the Schema Level

    1. Protecting Data with Encryption and Auditing

        1. Options for auditing data access in SQL Server
        1. Implementing SQL Server Audit
        1. Managing SQL Server Audit
        1. Protecting Data with Encryption

    1. Recovery Models and Backup Strategies

        1. Understanding Backup Strategies
        1. SQL Server Transaction Logs
        1. Planning Backup Strategies

    1. Backing Up SQL Server Databases

        1. Backing Up Databases and Transaction Logs
        1. Managing Database Backups
        1. Advanced Database Options

    1. Restoring SQL Server 2016 Databases

        1. Understanding the Restore Process
        1. Restoring Databases
        1. Advanced Restore Scenarios
        1. Point-in-Time Recovery

    1. Automating SQL Server Management

        1. Automating SQL Server management
        1. Working with SQL Server Agent
        1. Managing SQL Server Agent Jobs
        1. Multi-server Management

    1. Configuring Security for SQL Server Agent

        1. Understanding SQL Server Agent Security
        1. Configuring Credentials
        1. Configuring Proxy Accounts

    1. Monitoring SQL Server with Alerts and Notifications

        1. Monitoring SQL Server Errors
        1. Configuring Database Mail
        1. Operators, Alerts, and Notifications
        1. Alerts in Azure SQL Database

    1. Introduction to Managing SQL Server by using PowerShell

        1. Getting Started with Windows PowerShell
        1. Configure SQL Server using PowerShell
        1. Administer and Maintain SQL Server with PowerShell
        1. Managing Azure SQL Databases using PowerShell

    1. Tracing Access to SQL Server with Extended events

        1. Extended Events Core Concepts
        1. Working with Extended Events

    1. Monitoring SQL Server

        1. Monitoring activity
        1. Capturing and Managing Performance Data
        1. Analyzing Collected Performance Data
        1. SQL Server Utility

    1. Troubleshooting SQL Server

        1. A Trouble Shooting Methodology for SQL Server
        1. Resolving Service Related Issues
        1. Resolving Connectivity and Log-in issues

    1. Importing and Exporting Data

        1. Transferring Data to and from SQL Server
        1. Importing and Exporting Table Data
        1. Using bcp and BULK INSERT to Import Data
        1. Deploying and Upgrading Data-Tier Application

1. Exam 70-765 SQL データベースのプロビジョニング

    情報元：[コース 20765C: Provisioning SQL Databases](https://www.microsoft.com/ja-jp/learning/course.aspx?cid=20765)

    1. SQL Server Components

        1. Introduction to the SQL Server Platform
        1. Overview of SQL Server Architecture
        1. SQL Server Services and Configuration Options

    1. Installing SQL Server

        1. Considerations for SQL Installing Server
        1. TempDB Files
        1. Installing SQL Server
        1. Automating Installation

    1. Upgrading SQL Server to SQL Server 2017

        1. Upgrade Requirements
        1. Upgrade SQL Server Services
        1. Side by Side Upgrade: Migrating SQL Server Data and Applications

    1. Working with Databases

        1. Introduction to Data Storage with SQL Server
        1. Managing Storage for System Databases
        1. Managing Storage for User Databases
        1. Moving and Copying Database Files
        1. Buffer Pool Extension

    1. Performing Database Maintenance

        1. Ensuring Database Integrity
        1. Maintaining Indexes
        1. Automating Routine Database Maintenance

    1. Database Storage Options

        1. SQL Server storage Performance
        1. SMB Fileshare
        1. SQL Server Storage in Microsoft Azure
        1. Stretch Databases

    1. Planning to Deploy SQL Server on Microsoft Azure

        1. SQL Server Virtual Machines in Azure
        1. Azure Storage
        1. Azure SQL Authentication
        1. Deploying an Azure SQL Database

    1. Migrating Databases to Azure SQL Database

        1. Database Migration Testing Tools
        1. Database Migration Compatibility Issues
        1. Migrating a SQL Server Database to Azure SQL Database

    1. Deploying SQL Server on a Microsoft Azure Virtual Machine

        1. Deploying SQL Server on an Azure VM
        1. The Deploy Database to a Microsoft Azure VM Wizard

    1. Managing databases in the Cloud

        1. Managing Azure SQL Database Security
        1. Configure Azure storage
        1. Azure Automation

[参考](https://www.microsoft.com/ja-jp/learning/mcsa-sql2016-database-administration-certification.aspx)

## MCSE: データ管理と分析 ##

[参考](https://www.microsoft.com/ja-jp/learning/mcse-data-management-analytics.aspx)
