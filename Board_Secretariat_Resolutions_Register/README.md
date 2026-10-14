# 🏛️ Board Secretariat & Resolutions Register

![Dashboard Preview](Board_Secretariat_Resolutions_Register_Preview.png)

An Excel workbook that runs the **secretariat of a Joint Venture Board of Directors**: meeting calendar, papers deadlines, minutes, a numbered resolutions register, circular resolutions signed through **DocuSign**, a board action log and an attendance matrix. Everything rolls up into one live dashboard.

> ⚠️ **All data is fictional.** JV, partner companies, board members and envelope numbers are demo data.

## 📂 Files
| File | Description |
|---|---|
| `Board_Secretariat_Resolutions_Register.xlsx` | Working Excel workbook (formulas, drop-downs, conditional formatting) |
| `Board_Secretariat_Resolutions_Register.pdf` | One-page dashboard PDF |
| `Board_Secretariat_Resolutions_Register_Preview.png` | Dashboard preview |

## 🗂️ Sheets
| Sheet | What it does |
|---|---|
| **Dashboard** | KPIs, next board cycle with countdown, resolutions by category, actions by owner, circular resolutions awaiting signature |
| **Meeting Calendar** | Ordinary and extraordinary meetings, quorum check, papers deadline (meeting – 7 days), minutes issued and signed |
| **Resolutions Register** | BR-2026-xxx numbering, meeting vs circular, category, signatures collected, DocuSign envelope, status |
| **Action Log** | Board actions with owner, due date, status and automatic days overdue |
| **Attendance** | Member × meeting matrix (P / A) with attendance % |
| **Board Members** | Members, roles, partner company and attendance linked from the matrix |

## ⚙️ Excel features used
`COUNTIFS` · `MINIFS` · `INDEX/MATCH` with a helper sequence for the live "awaiting signature" list · `TODAY()`-based overdue and countdown · data validation drop-downs · conditional formatting · native Excel charts

## 🔄 How to use
1. Add a meeting in **Meeting Calendar**. The papers deadline and quorum fill in automatically.
2. Log each resolution in **Resolutions Register**. Circular resolutions show on the dashboard until all signatures are in.
3. Record actions in **Action Log**. Overdue items turn red automatically.
4. Mark attendance as **P** or **A**.

## 🛠️ Skills shown
Board secretarial practice · Corporate governance · DocuSign signature tracking · Minutes & action follow-up · Excel dashboard design
