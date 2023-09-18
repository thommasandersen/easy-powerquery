let
    Source = {
        Number.From(
            #date(
                Date.Year(DateTime.LocalNow()) - 1,
                01,
                01
            )
        )
        ..
        Number.From(
            #date(
                Date.Year(DateTime.LocalNow()),
                12,
                31
            )
        )
    },
    Convert =
        Table.FromList(
            Source,
            Splitter.SplitByNothing(),
            null,
            null,
            ExtraValues.Error
        ),
    Step1 =
        Table.TransformColumnTypes(
            Convert,
            {
                {
                    "Column1",
                    type date
                }
            }
        ),
    Step2 =
        Table.RenameColumns(
            Step1,
            {
                {
                    "Column1",
                    "Date"
                }
            }
        ),
    Step3 =
        Table.AddColumn(
            Step2,
            "#Week",
            each Date.WeekOfYear([Date])
        ),
    Step3b =
        Table.AddColumn(
            Step3,
            "#Week-ISO",
            each
                if
                    Number.RoundDown(
                        (
                            Date.DayOfYear([Date])
                            - (Date.DayOfWeek([Date], Day.Monday) + 1)
                            + 10
                        )
                        / 7
                    )
                    = 0
                then
                    Number.RoundDown(
                        (
                            Date.DayOfYear(#date(Date.Year([Date]) - 1, 12, 31))
                            - (
                                Date.DayOfWeek(
                                    #date(Date.Year([Date]) - 1, 12, 31),
                                    Day.Monday
                                )
                                + 1
                            )
                            + 10
                        )
                        / 7
                    )
                else if
                    (
                        Number.RoundDown(
                            (
                                Date.DayOfYear([Date])
                                - (Date.DayOfWeek([Date], Day.Monday) + 1)
                                + 10
                            )
                            / 7
                        )
                        = 53 and (
                            Date.DayOfWeek(
                                #date(Date.Year([Date]), 12, 31),
                                Day.Monday
                            )
                            + 1
                            < 4
                        )
                    )
                then
                    1
                else
                    Number.RoundDown(
                        (
                            Date.DayOfYear([Date])
                            - (Date.DayOfWeek([Date], Day.Monday) + 1)
                            + 10
                        )
                        / 7
                    )
        ),
    Step4 =
        Table.AddColumn(
            Step3b,
            "#Year",
            each Date.Year([Date])
        ),
    Step4b =
        Table.AddColumn(
            Step4,
            "#Year-ISO",
            each Date.Year(Date.AddDays([Date], 26 - [#"#Week-ISO"]))
        ),
    Step5 =
        Table.AddColumn(
            Step4b,
            "#Quarter",
            each Date.QuarterOfYear([Date])
        ),
    Step6 =
        Table.AddColumn(
            Step5,
            "#Month",
            each Date.Month([Date])
        ),
    Step7 =
        Table.AddColumn(
            Step6,
            "#Day (of year)",
            each Date.DayOfYear([Date])
        ),
    Step8 =
        Table.AddColumn(
            Step7,
            "#Day (of week)",
            each Date.DayOfWeek([Date], 1) + 1
        ),
    Step9 =
        Table.AddColumn(
            Step8,
            "#Day (of month)",
            each Date.Day([Date])
        ),
    Step10 =
        Table.AddColumn(
            Step9,
            "#Year and #Quarter",
            each
                Text.From([#"#Year"])
                & Text.End(
                    "0" & Text.From([#"#Quarter"]),
                    2
                )
        ),
    Step11 =
        Table.AddColumn(
            Step10,
            "#Year and #Month",
            each
                Text.From([#"#Year"])
                & Date.ToText([Date], "MM")
        ),
    Step12 =
        Table.AddColumn(
            Step11,
            "#Year and #Week",
            each
                Text.From([#"#Year"])
                & Text.End("0" & Text.From([#"#Week"]), 2)
        ),
    Step12b =
        Table.AddColumn(
            Step12,
            "#Year-ISO and #Week-ISO",
            each
                Text.From([#"#Year-ISO"])
                & Text.End(
                    "0" & Text.From([#"#Week-ISO"]),
                    2
                )
        ),
    Step13 =
        Table.AddColumn(
            Step12b,
            "Weekday",
            each
                Text.Start(
                    Text.Proper(Date.DayOfWeekName([Date])),
                    3
                )
        ),
    Step14 =
        Table.AddColumn(
            Step13,
            "Month short",
            each
                Text.Start(
                    Text.Proper(Date.MonthName([Date])),
                    3
                )
        ),
    Step15 =
        Table.AddColumn(
            Step14,
            "Month short and year",
            each
                Text.From([Month short])
                & " "
                & Text.From([#"#Year"])
        ),
    Step16 =
        Table.AddColumn(
            Step15,
            "Month",
            each Text.Proper(Date.MonthName([Date]))
        ),
    Step17 =
        Table.AddColumn(
            Step16,
            "Month and year",
            each
                Text.From([Month])
                & " "
                & Text.From([#"#Year"])
        ),
    Step18 =
        Table.AddColumn(
            Step17,
            "Quarter and year",
            each
                Text.From("Q")
                & Text.End(
                    "0" & Text.From([#"#Quarter"]),
                    2
                )
                & " "
                & Text.From([#"#Year"])
        ),
    Step19 =
        Table.AddColumn(
            Step18,
            "Week and year",
            each
                "W"
                & Text.End("0" & Text.From([#"#Week"]), 2)
                & " "
                & Text.From([#"#Year"])
        ),
    Step19b =
        Table.AddColumn(
            Step19,
            "Week-ISO and year-ISO",
            each
                "W"
                & Text.End(
                    "0" & Text.From([#"#Week-ISO"]),
                    2
                )
                & " "
                & Text.From([#"#Year-ISO"])
        ),
    Step20 =
        Table.AddColumn(
            Step19b,
            "Last date in month",
            each Date.EndOfMonth([Date])
        ),
    Step21 =
        Table.AddColumn(
            Step20,
            "Until today",
            each
                if [Date] <= Date.From(DateTime.LocalNow()) then
                    1
                else
                    0
        ),
    Step22 =
        Table.AddColumn(
            Step21,
            "Before today",
            each
                if [Date] < Date.From(DateTime.LocalNow()) then
                    1
                else
                    0
        ),
    Step23 =
        Table.AddColumn(
            Step22,
            "#Passed days",
            each
                Duration.Days(
                    Duration.From(
                        Date.From(DateTime.LocalNow())
                        - Date.From([Date])
                    )
                )
        ),
    Step24 =
        Table.AddColumn(
            Step23,
            "#Passed years",
            each
                Value.FromText(Date.Year(Date.From(DateTime.LocalNow())))
                - Value.FromText([#"#Year"])
        ),
    Step25 =
        Table.AddColumn(
            Step24,
            "#Passed months",
            each
                ([#"#Passed years"] * 12)
                + (
                    Value.FromText(Text.From(Date.Month(Date.From(DateTime.LocalNow()))))
                    - Value.FromText([#"#Month"])
                )
        ),
    Step26 =
        Table.AddColumn(
            Step25,
            "#Passed quarters",
            each
                ([#"#Passed years"] * 4)
                + (
                    Value.FromText(Text.From(Date.QuarterOfYear(Date.From(DateTime.LocalNow()))))
                    - Value.FromText([#"#Quarter"])
                )
        ),
    Step27 =
        Table.AddColumn(
            Step26,
            "#Passed weeks",
            each
                Duration.Days(
                    Duration.From(
                        Date.From(
                            Date.StartOfWeek(
                                Date.From(DateTime.LocalNow()),
                                1
                            )
                        )
                        - Date.From(Date.StartOfWeek(Date.From([Date]), 1))
                    )
                )
                / 7
        ),
    Step28 =
        Table.AddColumn(
            Step27,
            "Filter day",
            each
                if [#"#Passed days"] = 0 then
                    "This day"
                else if [#"#Passed days"] = 1 then
                    "Last day"
                else if [#"#Passed days"] = -1 then
                    "Next day"
                else
                    [Date]
        ),
    Step29 =
        Table.AddColumn(
            Step28,
            "Filter month",
            each
                if [#"#Passed months"] = 0 then
                    "This month"
                else if [#"#Passed months"] = 1 then
                    "Last month"
                else if [#"#Passed months"] = -1 then
                    "Next month"
                else
                    [Month short and year]
        ),
    Step29b =
        Table.AddColumn(
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
    Step30 =
        Table.AddColumn(
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
    Step31 =
        Table.TransformColumnTypes(
            Step30,
            {
                {
                    "#Passed weeks",
                    Int64.Type
                },
                {
                    "#Passed quarters",
                    Int64.Type
                },
                {
                    "#Passed months",
                    Int64.Type
                },
                {
                    "#Passed years",
                    Int64.Type
                },
                {
                    "#Passed days",
                    Int64.Type
                },
                {
                    "#Year",
                    Int64.Type
                },
                {
                    "#Quarter",
                    Int64.Type
                },
                {
                    "#Month",
                    Int64.Type
                },
                {
                    "#Week",
                    Int64.Type
                },
                {
                    "#Day (of week)",
                    Int64.Type
                },
                {
                    "#Day (of year)",
                    Int64.Type
                },
                {
                    "#Day (of month)",
                    Int64.Type
                },
                {
                    "#Year and #Quarter",
                    Int64.Type
                },
                {
                    "#Year and #Month",
                    Int64.Type
                },
                {
                    "#Year and #Week",
                    Int64.Type
                },
                {
                    "Until today",
                    type logical
                },
                {
                    "Before today",
                    type logical
                },
                {
                    "Last date in month",
                    type date
                },
                {
                    "Date",
                    type date
                },
                {
                    "Weekday",
                    type text
                },
                {
                    "Month short",
                    type text
                },
                {
                    "Month short and year",
                    type text
                },
                {
                    "Month",
                    type text
                },
                {
                    "Month and year",
                    type text
                },
                {
                    "Quarter and year",
                    type text
                },
                {
                    "Week and year",
                    type text
                },
                {
                    "Filter day",
                    type text
                },
                {
                    "Filter month",
                    type text
                },
                {
                    "Filter year",
                    type text
                },
                {
                    "#Week-ISO",
                    Int64.Type
                },
                {
                    "#Year-ISO and #Week-ISO",
                    Int64.Type
                },
                {
                    "Week-ISO and year-ISO",
                    type text
                },
                {
                    "#Year-ISO",
                    Int64.Type
                }
            }
        )
in
    Step31
