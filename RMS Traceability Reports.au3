#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_UseUpx=y
#EndRegion ;**** Directives created by AutoIt3Wrapper_GUI ****
;#RequireAdmin
;#AutoIt3Wrapper_usex64=n
#include <SQLite.au3>
#include <SQLite.dll.au3>
#include <Toast.au3>
#include <JanisonTestAutomationReports.au3>

Local $app_name = "RMS Traceability Reports"

; Authentication

Local $ini_filename = @ScriptDir & "\" & $app_name & ".ini"
_TestRailAuthenticationWithToast($app_name, "https://janison.testrail.com", $ini_filename)
_ConfluenceAuthenticationWithToast($app_name, "https://janisoncls.atlassian.net", $ini_filename)
_ConfluenceAuthenticationWithToast($app_name, "https://janisoncls.atlassian.net", $ini_filename)

; Startup SQLite

_SQLite_Startup()
ConsoleWrite("_SQLite_LibVersion=" & _SQLite_LibVersion() & @CRLF)
FileDelete(@ScriptDir & "\" & $app_name & ".sqlite")
_SQLite_Open(@ScriptDir & "\" & $app_name & ".sqlite")
_SQLite_Exec(-1, "PRAGMA synchronous = OFF;")		; this should speed up DB transactions
_SQLite_Exec(-1, "CREATE TABLE ProjectVersion (Name);") ; CREATE a Table
_SQLite_Exec(-1, "CREATE TABLE Epic (Key,Summary);") ; CREATE a Table
_SQLite_Exec(-1, "CREATE TABLE Story (Key,Summary,EpicKey,ReqID,FixVersion,Status,TestNotes);") ; CREATE a Table
_SQLite_Exec(-1, "CREATE TABLE Task (Key,Summary,StoryKey);") ; CREATE a Table
_SQLite_Exec(-1, "CREATE TABLE Bug (Key,Summary,Reporter,Assignee,Status,Priority,AffectsVersions,FixVersions,Resolution,Labels,Environment,ScrumTeam,Sprint);") ; CREATE a Table
_SQLite_Exec(-1, "CREATE TABLE BugChangeLog (Key,AffectsVersion,Priority,Created,Field,Old,New);") ; CREATE a Table
_SQLite_Exec(-1, "CREATE TABLE BugStateDate (Key,AffectsVersion,Priority,OpenDate,ResolvedDate,BlockerUnresolvedAge Int,CriticalUnresolvedAge Int,MajorUnresolvedAge Int,MinorUnresolvedAge Int,TrivialUnresolvedAge Int);") ; CREATE a Table
_SQLite_Exec(-1, "CREATE TABLE BugTotalResolvedPerDate (AffectsVersion,Date,TotalBugs Int,TotalBugsResolved Int,TotalBlockersResolved Int,TotalCriticalResolved Int,TotalMajorResolved Int,TotalMinorResolved Int,TotalTrivialResolved Int,TotalUnresolved Int);") ; CREATE a Table
_SQLite_Exec(-1, "CREATE TABLE BugTotalActivePerDate (AffectsVersion,Date,TotalActive Int,BlockersActive Int,CriticalActive Int,MajorActive Int,MinorActive Int,TrivialActive Int);") ; CREATE a Table
_SQLite_Exec(-1, "CREATE TABLE BugTotalOpenedPerDate (AffectsVersion,Date,TotalOpened Int,BlockersOpened Int,CriticalOpened Int,MajorOpened Int,MinorOpened Int,TrivialOpened Int);") ; CREATE a Table
_SQLite_Exec(-1, "CREATE TABLE BugOpenedPerWeek (AffectsVersion,WeekStarting,AllOpened Int,BlockersOpened Int,CriticalOpened Int,MajorOpened Int,MinorOpened Int,TrivialOpened Int);") ; CREATE a Table
_SQLite_Exec(-1, "CREATE TABLE TestCase (ProjectName,Id,Title,Type,Reference);") ; CREATE a Table
_SQLite_Exec(-1, "CREATE TABLE Run (Id,Name);") ; CREATE a Table
_SQLite_Exec(-1, "CREATE TABLE Test (Id,Title,TestCaseId,RunId);") ; CREATE a Table
_SQLite_Exec(-1, "CREATE TABLE Result (Id,TestId,StatusId,CreatedOn,Defects);") ; CREATE a Table
_SQLite_Exec(-1, "CREATE TABLE TestStatus (Id,Label);") ; CREATE a Table

; Page header

$storage_format = '<a href=\"https://janisoncls.atlassian.net/wiki/download/attachments/494207048/RMS%20Traceability%20Reports%20portable.exe\">Click to update this page</a><br />'
Confluence_Table_Of_Contents("list", "", "disc", "", "", "", "", "", "Table of Contents")

; Traceability Extract

TraceabilityExtract($app_name, "RMS", 43, 47)

; Traceability Reports

EpicsWithoutStories()
StoriesWithoutTestCases()
ManualTestCasesWithoutStories()
AutomatedTestCasesWithoutStories()
EpicsWithStoriesWithTestCases()

; Update Confluence

_Toast_Show(0, $app_name, "Uploading reports to confluence", -300, False, True)
Update_Confluence_Page("https://janisoncls.atlassian.net", "JAST", "386826341", "497188894", $app_name, $storage_format)

; Shutdown

_JiraShutdown()
_SQLite_Close()
_SQLite_Shutdown()
_Toast_Show(0, $app_name, "Done. Refresh the page in Confluence.", -3, False, True)
Sleep(3000)
