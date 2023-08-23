let
    // **** Parameters ****
    // Start year of date dim table
    StartYear = Date.Year(DateTime.LocalNow()) - 5,
    // End year of date dim table
    EndYear = Date.Year(DateTime.LocalNow()),
    DateList = {
        Number.From(#date(StartYear - 1, 01, 01))..Number.From(
            #date(EndYear, 12, 31)
        )
    },
    #"Converted to Table" = Table.FromList(DateList, Splitter.SplitByNothing(), null, null, ExtraValues.Error),
    DateTableConv = Table.TransformColumnTypes(#"Converted to Table",{{"Column1", type date}}),
    fnGetAllHolidaysOfAYear = (year as number) as list =>
        let
            // get a date of Easter Sunday (Source: https://en.wikipedia.org/wiki/Computus)
            EasterSundayFunc = (year as number) as date =>
                let
                    a = Number.Mod(year, 19),
                    b = Number.RoundDown(year / 100),
                    c = Number.Mod(year, 100),
                    d = Number.RoundDown(b / 4),
                    e = Number.Mod(b, 4),
                    f = Number.RoundDown((b + 8) / 25),
                    g = Number.RoundDown((b - f + 1) / 3),
                    h = Number.Mod((19 * a + b - d - g + 15), 30),
                    i = Number.RoundDown(c / 4),
                    k = Number.Mod(c, 4),
                    l = Number.Mod((32 + 2 * e + 2 * i - h - k), 7),
                    m = Number.RoundDown((a + 11 * h + 22 * l) / 451),
                    n = Number.RoundDown((h + l - 7 * m + 114) / 31),
                    p = Number.Mod((h + l - 7 * m + 114), 31) + 1,
                    dt = #date(year, n, p)
                in
                    dt,
            EasterSunday = EasterSundayFunc(year),
            CurrentYearHolidaysList = {
                // NewYear = always January 1st
                [
                    Date = #date(year, 1, 1),
                    HolidayName = "New Years Day"
                ],
                // MaundyThursday = 3 days before Easter Sunday
                [
                    Date = Date.AddDays(EasterSunday, -3),
                    HolidayName = "Maundy Thursday"
                ],
                // GoodFriday = 2 days before Easter Sunday
                [
                    Date = Date.AddDays(EasterSunday, -2),
                    HolidayName = "Good Friday"
                ],
                // EasterSunday
                [
                    Date = Date.AddDays(EasterSunday, -1),
                    HolidayName = "Holy Saturday"
                ],
                // EasterSunday
                [
                    Date = Date.AddDays(EasterSunday, 0),
                    HolidayName = "Easter Sunday"
                ],
                // EasterMonday = 1 day after Easter Sunday
                [
                    Date = Date.AddDays(EasterSunday, 1),
                    HolidayName = "Easter Monday"
                ],
                // LabourDay = always Mai 1st
                [
                    Date = #date(year, 5, 1),
                    HolidayName = "Labour Day"
                ],
                // 17.may = always Mai 17
                [
                    Date = #date(year, 5, 17),
                    HolidayName = "Norwegian Constitution Day"
                ],
                // AscensionDay = 39 days after Easter Sunday
                [
                    Date = Date.AddDays(EasterSunday, 39),
                    HolidayName = "With Saturday"
                ],
                // WhitSunday = 49 days after Easter Sunday
                [
                    Date = Date.AddDays(EasterSunday, 49),
                    HolidayName = "With Sunday"
                ],
                // WhitMonday = 50 days after Easter Sunday
                [
                    Date = Date.AddDays(EasterSunday, 50),
                    HolidayName = "With Monday"
                ],
                // ChristmasEve = always December 24th
                [
                    Date = #date(year, 12, 24),
                    HolidayName = "Christmas Eve"
                ],
                // ChristmasDay = always December 25th
                [
                    Date = #date(year, 12, 25),
                    HolidayName = "Christmas Day"
                ],
                // StStephensDay = always December 26th
                [
                    Date = #date(year, 12, 26),
                    HolidayName = "Boxing Day"
                ],
                // Silvester = always December 31st
                [
                    Date = #date(year, 12, 31),
                    HolidayName = "New Years Eve"
                ]
            }
        in
            CurrentYearHolidaysList,
    // get a table of all holidays
    fnGetAllHolidaysTable = (startYear as number, endYear as number) as table =>
        let
            // a list of years starting one year before actual start
            yearList = {startYear - 1..endYear},
            holidayYearList = List.Transform(yearList, fnGetAllHolidaysOfAYear),
            holidaysYearListAsTable = Table.FromList(
                holidayYearList, Splitter.SplitByNothing(), null, null, ExtraValues.Error
            ),
            expandList = Table.ExpandListColumn(holidaysYearListAsTable, "Column1"),
            holidaysTable = Table.ExpandRecordColumn(
                expandList, "Column1", {"Date", "HolidayName"}, {"Date", "HolidayName"}
            )
        in
            holidaysTable,
    Step2 = fnGetAllHolidaysTable(StartYear, EndYear),
    #"Merged Queries" = Table.NestedJoin(DateTableConv, {"Column1"}, Step2, {"Date"}, "Date", JoinKind.LeftOuter),
    #"Expanded Date1" = Table.ExpandTableColumn(#"Merged Queries", "Date", {"HolidayName"}, {"HolidayName"}),
    #"Renamed Columns" = Table.RenameColumns(#"Expanded Date1",{{"Column1", "Date"}}),
    Step3 = Table.AddColumn(#"Renamed Columns", "#Week", each Date.WeekOfYear([Date])),
    Step3b = Table.AddColumn(
        Step3,
        "#Week-ISO",
        each
            if Number.RoundDown((Date.DayOfYear([Date]) - (Date.DayOfWeek([Date], Day.Monday) + 1) + 10) / 7) = 0
            then
                Number.RoundDown(
                    (
                        Date.DayOfYear(#date(Date.Year([Date]) - 1, 12, 31)) - (
                            Date.DayOfWeek(#date(Date.Year([Date]) - 1, 12, 31), Day.Monday) + 1
                        ) + 10
                    ) / 7
                )
            else if (
                Number.RoundDown((Date.DayOfYear([Date]) - (Date.DayOfWeek([Date], Day.Monday) + 1) + 10) / 7) = 53
                and (Date.DayOfWeek(#date(Date.Year([Date]), 12, 31), Day.Monday) + 1 < 4)
            ) then
                1
            else
                Number.RoundDown((Date.DayOfYear([Date]) - (Date.DayOfWeek([Date], Day.Monday) + 1) + 10) / 7)
    ),
    Step4 = Table.AddColumn(Step3b, "#Year", each Date.Year([Date])),
    Step4b = Table.AddColumn(Step4, "#Year-ISO", each Date.Year(Date.AddDays([Date], 26 - [#"#Week-ISO"]))),
    Step5 = Table.AddColumn(Step4b, "#Quarter", each Date.QuarterOfYear([Date])),
    Step6 = Table.AddColumn(Step5, "#Month", each Date.Month([Date])),
    Step7 = Table.AddColumn(Step6, "#Day (of year)", each Date.DayOfYear([Date])),
    Step8 = Table.AddColumn(Step7, "#Day (of week)", each Date.DayOfWeek([Date], 1) + 1),
    Step9 = Table.AddColumn(Step8, "#Day (of month)", each Date.Day([Date])),
    Step10 = Table.AddColumn(
        Step9, "#Year and #Quarter", each Text.From([#"#Year"]) & Text.End("0" & Text.From([#"#Quarter"]), 2)
    ),
    Step11 = Table.AddColumn(Step10, "#Year and #Month", each Text.From([#"#Year"]) & Date.ToText([Date], "MM")),
    Step12 = Table.AddColumn(
        Step11, "#Year and #Week", each Text.From([#"#Year"]) & Text.End("0" & Text.From([#"#Week"]), 2)
    ),
    Step12b = Table.AddColumn(
        Step12, "#Year-ISO and #Week-ISO", each
            Text.From([#"#Year-ISO"]) & Text.End("0" & Text.From([#"#Week-ISO"]), 2)
    ),
    Step13 = Table.AddColumn(Step12b, "Weekday", each Text.Start(Text.Proper(Date.DayOfWeekName([Date])), 3)),
    Step14 = Table.AddColumn(Step13, "Month short", each Text.Start(Text.Proper(Date.MonthName([Date])), 3)),
    Step15 = Table.AddColumn(
        Step14, "Month short and year", each Text.From([Month short]) & " " & Text.From([#"#Year"])
    ),
    Step16 = Table.AddColumn(Step15, "Month", each Text.Proper(Date.MonthName([Date]))),
    Step17 = Table.AddColumn(Step16, "Month and year", each Text.From([Month]) & " " & Text.From([#"#Year"])),
    Step18 = Table.AddColumn(
        Step17,
        "Quarter and year",
        each Text.From("Q") & Text.End("0" & Text.From([#"#Quarter"]), 2) & " " & Text.From([#"#Year"])
    ),
    Step19 = Table.AddColumn(
        Step18, "Week and year", each "W" & Text.End("0" & Text.From([#"#Week"]), 2) & " " & Text.From([#"#Year"])
    ),
    Step19b = Table.AddColumn(
        Step19,
        "Week-ISO and year-ISO",
        each "W" & Text.End("0" & Text.From([#"#Week-ISO"]), 2) & " " & Text.From([#"#Year-ISO"])
    ),
    Step20 = Table.AddColumn(Step19b, "Last date in month", each Date.EndOfMonth([Date])),
    Step21 = Table.AddColumn(Step20, "Until today", each if [Date] <= Date.From(DateTime.LocalNow()) then 1 else 0),
    Step22 = Table.AddColumn(Step21, "Before today", each if [Date] < Date.From(DateTime.LocalNow()) then 1 else 0),
    Step23 = Table.AddColumn(
        Step22, "#Passed days", each Duration.Days(Duration.From(Date.From(DateTime.LocalNow()) - Date.From([Date])))
    ),
    Step24 = Table.AddColumn(
        Step23,
        "#Passed years",
        each Value.FromText(Date.Year(Date.From(DateTime.LocalNow()))) - Value.FromText([#"#Year"])
    ),
    Step25 = Table.AddColumn(
        Step24,
        "#Passed months",
        each
            ([#"#Passed years"] * 12) + (
                Value.FromText(Text.From(Date.Month(Date.From(DateTime.LocalNow())))) - Value.FromText([#"#Month"])
            )
    ),
    Step26 = Table.AddColumn(
        Step25,
        "#Passed quarters",
        each
            ([#"#Passed years"] * 4) + (
                Value.FromText(Text.From(Date.QuarterOfYear(Date.From(DateTime.LocalNow())))) - Value.FromText(
                    [#"#Quarter"]
                )
            )
    ),
    Step27 = Table.AddColumn(
        Step26,
        "#Passed weeks",
        each
            Duration.Days(
                Duration.From(
                    Date.From(Date.StartOfWeek(Date.From(DateTime.LocalNow()), 1)) - Date.From(
                        Date.StartOfWeek(Date.From([Date]), 1)
                    )
                )
            ) / 7
    ),
    Step28 = Table.AddColumn(
        Step27,
        "Filter day",
        each
            if [#"#Passed days"] = 0 then
                "Today"
            else if [#"#Passed days"] = 1 then
                "Yesterday"
            else if [#"#Passed days"] = -1 then
                "Tomorrow"
            else
                [Date]
    ),
    Step29 = Table.AddColumn(
        Step28,
        "Filter month",
        each
            if [#"#Passed months"] = 0 then
                "Denne month"
            else if [#"#Passed months"] = 1 then
                "Last month"
            else if [#"#Passed months"] = -1 then
                "Next month"
            else
                [Month short and year]
    ),
    Step29b = Table.AddColumn(
        Step29,
        "Filter week",
        each
            if [#"#Passed weeks"] = 0 then
                "This week"
            else if [#"#Passed weeks"] = 1 then
                "Last week"
            else if [#"#Passed weeks"] = -1 then
                "Next week"
            else
                [Week and year]
    ),
    Step30 = Table.AddColumn(
        Step29b,
        "Filter year",
        each
            if [#"#Passed years"] = 0 then
                "This year"
            else if [#"#Passed years"] = 1 then
                "Last year"
            else if [#"#Passed years"] = -1 then
                "Next year"
            else
                [#"#Year"]
    ),
    Step31 = Table.TransformColumnTypes(
        Step30,
        {
            {"#Passed weeks", Int64.Type},
            {"#Passed quarters", Int64.Type},
            {"#Passed months", Int64.Type},
            {"#Passed years", Int64.Type},
            {"#Passed days", Int64.Type},
            {"#Year", Int64.Type},
            {"#Quarter", Int64.Type},
            {"#Month", Int64.Type},
            {"#Week", Int64.Type},
            {"#Day (of week)", Int64.Type},
            {"#Day (of year)", Int64.Type},
            {"#Day (of month)", Int64.Type},
            {"#Year and #Quarter", Int64.Type},
            {"#Year and #Month", Int64.Type},
            {"#Year and #Week", Int64.Type},
            {"Until today", type logical},
            {"Before today", type logical},
            {"Last date in month", type date},
            {"Date", type date},
            {"HolidayName", type text},
            {"Weekday", type text},
            {"Month short", type text},
            {"Month short and year", type text},
            {"Month", type text},
            {"Month and year", type text},
            {"Quarter and year", type text},
            {"Week and year", type text},
            {"Filter day", type text},
            {"Filter month", type text},
            {"Filter year", type text},
            {"#Week-ISO", Int64.Type},
            {"#Year-ISO and #Week-ISO", Int64.Type},
            {"Week-ISO and year-ISO", type text},
            {"#Year-ISO", Int64.Type}
        }
    ),
    #"Added Custom" = Table.AddColumn(Step31, "StageHolidayCalc", each if [HolidayName] <> null then "Holiday"  else if List.Contains({6,7},[#"#Day (of week)"]) then "Weekend" else "Workday"),
    #"Changed Type" = Table.TransformColumnTypes(#"Added Custom",{{"StageHolidayCalc", type text}}),
    #"Renamed Columns1" = Table.RenameColumns(#"Changed Type",{{"StageHolidayCalc", "Workdays"}}),
    #"Sorted Rows" = Table.Sort(#"Renamed Columns1",{{"Date", Order.Ascending}})
in
    #"Sorted Rows"
