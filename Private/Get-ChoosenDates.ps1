﻿function Get-ChoosenDates {
    <#
    .SYNOPSIS
    Retrieves dates based on the specified date range.

    .DESCRIPTION
    This function retrieves dates based on the specified date range. The available date ranges are:
    - Everything
    - PastHour
    - CurrentHour
    - PastDay
    - CurrentDay
    - PastMonth
    - CurrentMonth
    - PastQuarter
    - CurrentQuarter
    - Last14Days
    - Last21Days
    - Last30Days
    - Last7Days
    - Last3Days
    - Last1Days

    .PARAMETER DateRange
    Specifies the date range to retrieve dates for.

    .EXAMPLE
    Get-ChoosenDates -DateRange PastHour
    Retrieves dates for the past hour.

    .EXAMPLE
    Get-ChoosenDates -DateRange CurrentMonth
    Retrieves dates for the current month.
    #>
    [CmdletBinding()]
    param(
        [ValidateSet('Everything', 'PastHour', 'CurrentHour', 'PastDay', 'CurrentDay', 'PastMonth', 'CurrentMonth', 'PastQuarter', 'CurrentQuarter', 'Last14Days', 'Last21Days', 'Last30Days' , 'Last7Days', 'Last3Days', 'Last1Days')][string] $DateRange
    )
    # Report Per Hour
    if ($DateRange -eq 'PastHour') {
        $DatesPastHour = Find-DatesPastHour
        if ($DatesPastHour) {
            $DatesPastHour
        }
    }
    if ($DateRange -eq 'CurrentHour') {
        $DatesCurrentHour = Find-DatesCurrentHour
        if ($DatesCurrentHour) {
            $DatesCurrentHour
        }
    }
    # Report Per Day
    if ($DateRange -eq 'PastDay') {
        $DatesDayPrevious = Find-DatesDayPrevious
        if ($DatesDayPrevious) {
            $DatesDayPrevious
        }
    }
    if ($DateRange -eq 'CurrentDay') {
        $DatesDayToday = Find-DatesDayToday
        if ($DatesDayToday) {
            $DatesDayToday
        }
    }
    # Report Per Month
    if ($DateRange -eq 'PastMonth') {
        # Find-DatesMonthPast runs only on 1st of the month unless -Force is used
        $DatesMonthPrevious = Find-DatesMonthPast -Force $true
        if ($DatesMonthPrevious) {
            $DatesMonthPrevious
        }
    }
    if ($DateRange -eq 'CurrentMonth') {
        $DatesMonthCurrent = Find-DatesMonthCurrent
        if ($DatesMonthCurrent) {
            $DatesMonthCurrent
        }
    }
    # Report Per Quarter
    if ($DateRange -eq 'PastQuarter') {
        # Find-DatesMonthPast runs only on 1st of the quarter unless -Force is used
        $DatesQuarterLast = Find-DatesQuarterLast -Force $true
        if ($DatesQuarterLast) {
            $DatesQuarterLast
        }
    }
    if ($DateRange -eq 'CurrentQuarter') {
        $DatesQuarterCurrent = Find-DatesQuarterCurrent
        if ($DatesQuarterCurrent) {
            $DatesQuarterCurrent
        }
    }
    if ($DateRange -eq 'Everything') {
        $DatesEverything = @{
            DateFrom = Get-Date -Year 1900 -Month 1 -Day 1
            DateTo   = Get-Date -Year 2300 -Month 1 -Day 1
        }
        $DatesEverything
    }
    if ($DateRange -eq 'Last1days') {
        $DatesCurrentDayMinusDaysX = Find-DatesCurrentDayMinuxDaysX -days 1
        if ($DatesCurrentDayMinusDaysX) {
            $DatesCurrentDayMinusDaysX
        }
    }
    if ($DateRange -eq 'Last3days') {
        $DatesCurrentDayMinusDaysX = Find-DatesCurrentDayMinuxDaysX -days 3
        if ($DatesCurrentDayMinusDaysX) {
            $DatesCurrentDayMinusDaysX
        }
    }
    if ($DateRange -eq 'Last7days') {
        $DatesCurrentDayMinusDaysX = Find-DatesCurrentDayMinuxDaysX -days 7
        if ($DatesCurrentDayMinusDaysX) {
            $DatesCurrentDayMinusDaysX
        }
    }
    if ($DateRange -eq 'Last14days') {
        $DatesCurrentDayMinusDaysX = Find-DatesCurrentDayMinuxDaysX -days 14
        if ($DatesCurrentDayMinusDaysX) {
            $DatesCurrentDayMinusDaysX
        }
    }
    if ($DateRange -eq 'Last21days') {
        $DatesCurrentDayMinusDaysX = Find-DatesCurrentDayMinuxDaysX -days 21
        if ($DatesCurrentDayMinusDaysX) {
            $DatesCurrentDayMinusDaysX
        }
    }
    if ($DateRange -eq 'Last30Days') {
        $DatesCurrentDayMinusDaysX = Find-DatesCurrentDayMinuxDaysX -days 30
        if ($DatesCurrentDayMinusDaysX) {
            $DatesCurrentDayMinusDaysX
        }
    }
}