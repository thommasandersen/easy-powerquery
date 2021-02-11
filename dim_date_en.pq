let
    Source = {Number.From(#date(Date.Year(DateTime.LocalNow())-10,01,01))..Number.From(#date(Date.Year(DateTime.LocalNow())+1,12,31))},
    Convert = Table.FromList(Source, Splitter.SplitByNothing(), null, null, ExtraValues.Error),
    Step1 = Table.TransformColumnTypes(Convert, {{"Column1", type date}}),
    Step2 = Table.RenameColumns(Step1, {{"Column1", "Date"}}),
    Step3 = Table.AddColumn(Step2, "#Year", each Date.Year([Date])),
    Step4 = Table.AddColumn(Step3, "#Quarter", each Date.QuarterOfYear([Date])),
    Step5 = Table.AddColumn(Step4, "#Month", each Date.Month([Date])),
    Step6 = Table.AddColumn(Step5, "#Week", each Date.WeekOfYear([Date])),
    Step23 = Table.AddColumn(Step22, "#Passed Days", each Duration.Days(Duration.From(Date.From(DateTime.LocalNow())-Date.From([Date])))),
    Step24 = Table.AddColumn(Step23, "#Passed Years", each Value.FromText(Date.Year(Date.From(DateTime.LocalNow())))-Value.FromText([#"#Year"])),
    Step25 = Table.AddColumn(Step24, "#Passed Months", each ([#"#Passed Years"]*12)+(Value.FromText(Text.From(Date.Month(Date.From(DateTime.LocalNow()))))-Value.FromText([#"#Month"]))),
    Step26 = Table.AddColumn(Step25, "#Passed Quarters", each ([#"#Passed Years"]*4)+(Value.FromText(Text.From(Date.QuarterOfYear(Date.From(DateTime.LocalNow()))))-Value.FromText([#"#Quarter"]))),
    Step27 = Table.AddColumn(Step26, "#Passed Weeks", each Duration.Days(Duration.From(Date.From(Date.StartOfWeek(Date.From(DateTime.LocalNow()),1))-Date.From(Date.StartOfWeek(Date.From([Date]),1))))/7),
    Step28 = Table.AddColumn(Step27, "Filter Day", each if [#"#Passed Days"] = 0 then "This Day" else if [#"#Passed Days"] = 1 then "Last Day" else if [#"#Passed Days"] = -1 then "Next Day" else [Date]),
    Step29 = Table.AddColumn(Step28, "Filter Month", each if [#"#Passed Months"] = 0 then "This Month" else if [#"#Passed Months"] = 1 then "Last Month" else if [#"#Passed Months"] = -1 then "Next Month" else [Month short and Year]),
    Step30 = Table.AddColumn(Step29, "Filter Year", each if [#"#Passed Years"] = 0 then "This Year" else if [#"#Passed Years"] = 1 then "Last Year" else if [#"#Passed Years"] = -1 then "Next Year" else [#"#Year"])
in
    Step31