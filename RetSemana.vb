Public Function RetSemana(dat As Date) As Integer

Dim dt_ini As Date
Dim dt_fim As Date
Dim Semana As Integer

For Counter = 3 To 35
    
    dt_ini = Worksheets("semanas").Cells(Counter, 1).Value
    dt_fim = Worksheets("semanas").Cells(Counter, 2).Value
    Semana = Worksheets("semanas").Cells(Counter, 3).Value
    
    If dt_ini <= dat And dt_fim >= dat Then RetSemana = Semana

Next Counter

End Function
