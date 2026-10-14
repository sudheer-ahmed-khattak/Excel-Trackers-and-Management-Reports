Attribute VB_Name = "Module1"
Option Explicit

' UPDATE button on the Search sheet:
' writes New Status (H) and New Release Date (I) of each search result into Master Data,
' logs the change in the Notes column, then clears the inputs and recalculates.
Public Sub UpdateRecords()
    Dim ws As Worksheet, md As Worksheet
    Dim r As Long, mRow As Variant, cnt As Long, skipped As String
    Dim idVal As String, newSt As String, newDt As Variant, note As String

    Set ws = ThisWorkbook.Worksheets("Search")
    Set md = ThisWorkbook.Worksheets("Master Data")

    For r = 7 To 56
        idVal = Trim(CStr(ws.Cells(r, "A").Value))
        newSt = Trim(CStr(ws.Cells(r, "H").Value))
        newDt = ws.Cells(r, "I").Value
        If idVal <> "" And (newSt <> "" Or CStr(newDt) <> "") Then
            mRow = Application.Match(idVal, md.Columns("A"), 0)
            If IsError(mRow) Then
                skipped = skipped & vbCrLf & idVal
            Else
                note = ""
                If newSt <> "" Then
                    md.Cells(mRow, "J").Value = newSt
                    note = "Status " & newSt
                End If
                If CStr(newDt) <> "" Then
                    If IsNumeric(newDt) Then newDt = CDate(CDbl(newDt))
                    If IsDate(newDt) Then
                        md.Cells(mRow, "K").Value = CDate(newDt)
                        md.Cells(mRow, "K").NumberFormat = "dd-mmm-yyyy"
                        note = note & IIf(note = "", "", ", ") & "Date " & Format(CDate(newDt), "dd-mmm-yyyy")
                    Else
                        skipped = skipped & vbCrLf & idVal & " (invalid date)"
                    End If
                End If
                If note <> "" Then
                    md.Cells(mRow, "L").Value = md.Cells(mRow, "L").Value & IIf(CStr(md.Cells(mRow, "L").Value) = "", "", " | ") & "Updated " & Format(Date, "dd-mmm-yyyy") & ": " & note
                    cnt = cnt + 1
                End If
            End If
        End If
    Next r

    ws.Range("H7:I56").ClearContents
    Application.CalculateFull

    If cnt = 0 And skipped = "" Then
        MsgBox "Nothing to update." & vbCrLf & "Enter a New Status and/or New Release Date next to an employee, then press UPDATE.", vbInformation, "Update"
    Else
        MsgBox cnt & " employee(s) updated in Master Data." & IIf(skipped <> "", vbCrLf & vbCrLf & "Not updated:" & skipped, ""), vbInformation, "Update"
    End If
End Sub
