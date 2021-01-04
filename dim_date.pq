let
  /*
  Script name: Simple Date Calendar
  Author: Thommas Andersen (PBC Focus)
  Version: 1 - 2021-01-04
  */
  Source = {Number.From(#date(Date.Year(DateTime.LocalNow())-10,01,01))..Number.From(#date(Date.Year(DateTime.LocalNow())+1,12,31))},
  Convert = Table.FromList(Source, Splitter.SplitByNothing(), null, null, ExtraValues.Error),
  Step1 = Table.TransformColumnTypes(Convert, {{"Column1", type date}}),
  Step2 = Table.RenameColumns(Step1, {{"Column1", "Dato"}}),
  Step3 = Table.AddColumn(Step2, "#År", each Date.Year([Dato])),
  Step4 = Table.AddColumn(Step3, "#Kvartal", each Date.QuarterOfYear([Dato])),
  Step5 = Table.AddColumn(Step4, "#Måned", each Date.Month([Dato])),
  Step6 = Table.AddColumn(Step5, "#Uke", each Date.WeekOfYear([Dato])),
  Step7 = Table.AddColumn(Step6, "#Dag (år)", each Date.DayOfYear([Dato])),
  Step8 = Table.AddColumn(Step7, "#Dag (uke)", each Date.DayOfWeek([Dato], 1)+1),
  Step9 = Table.AddColumn(Step8, "#Dag (måned)", each Date.Day([Dato])),
  Step10 = Table.AddColumn(Step9, "#År og #kvartal", each Text.From([#"#År"])&Text.End("0"&Text.From([#"#Kvartal"]),2)),
  Step11 = Table.AddColumn(Step10, "#År og #måned", each Text.From([#"#År"])&Date.ToText([Dato], "MM")),
  Step12 = Table.AddColumn(Step11, "#År og #uke", each Text.From([#"#År"])&Text.End("0"&Text.From([#"#Uke"]),2)),
  Step13 = Table.AddColumn(Step12, "Ukedag", each Text.Start(Text.Proper(Date.DayOfWeekName([Dato])),3)),
  Step14 = Table.AddColumn(Step13, "Måned kort", each Text.Start(Text.Proper(Date.MonthName([Dato])),3)),
  Step15 = Table.AddColumn(Step14, "Måned", each Text.Proper(Date.MonthName([Dato]))),
  Step16 = Table.AddColumn(Step15, "Måned og år", each Text.From([Måned]) & " " & Text.From([#"#År"])),
  Step17 = Table.AddColumn(Step16, "Kvartal og år", each Text.From("K")&Text.End("0"&Text.From([#"#Kvartal"]),2)&" "&Text.From([#"#År"])),
  Step18 = Table.AddColumn(Step17, "Uke og år", each "U"&Text.End("0"&Text.From([#"#Uke"]),2)&" "&Text.From([#"#År"]))
in
  Step18