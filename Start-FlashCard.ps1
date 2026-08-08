#!/bin/pwsh

# spmather
# 2026-08-07
# v1.0.2

# I have not tested in Windows

function Show-WelcomeMessage {
    Write-Output `
@"
/~~~~~~~    Welcome    ~~~~~~~\
|~~~~~~~      to       ~~~~~~~|
\~~~~~~~  Flash Cards  ~~~~~~~/


This application will prompt you to input the answer to
your questions in a flash card style question and answer.
Score is tallied as pass for 1 point and fail for 0 point.

Flash cards are sequential by default.  Exit and use 
Start-FlashCards -FilePath /path/to/csv -RandomizeOrder
to randomize the order.

If you need to exit, please enter the word "Exit" to return
to the prompt.

Please note, this needs python3 and powershell in Linux 
to score correctly.

Good luck!


"@ | Write-Host -ForegroundColor $MenuTextColor
    Pause
    Clear-Host
}

function Format-Text($String) {
    Write-Output "$String" | Write-Host -ForegroundColor $PromptColor
}

function Show-EndText {

    if ($CardCount -eq 0) {
        $FinalScore = 0
    }
    elseif ($Null -eq $CardCount) {
        $FinalScore = 0
    }
    elseif ($CardCount -ge 1) {
        $FinalScore = $Score / $CardCount
    }
    
    Write-Output `
@"
Thank you for playing flash cards!

Your final score is:  [$($Score)] out of [$($CardCount)] total
Your percent score is:  [$($FinalScore * 100)]"
Your score was saved to [$($PSScriptRoot)/Scores.txt]


"@ | Write-Host -ForegroundColor $MenuTextColor
}

function Show-ProgressSpinner {
<#


    Function will not clear correctly when there is a new line immediately preceding the spinner i.e.: "`r`n $(Show-ProgressSpinner -SpinCount 10)"


   .EXAMPLE 
    Run a single rotation in the default color, which is gray for both light and dark mode compatibility.
    Show-ProgressSpinner
    
   .EXAMPLE 
    Run 1000 rotations in cyan.
    Show-ProgressSpinner -SpinCount 1000 -Color Cyan

   .EXAMPLE
    Use at the end of a ForEach loop on Linux:
    (1..255) | ForEach-Object {. /bin/ping -c 2 -t 10 192.168.0.$_; Write-Output "Working on a ping to 192.168.0.$($_) $(Show-ProgressSpinner -SpinCount 10)"}

    Use at the end of a ForEach loop in Windows:
    (1..255) | ForEach-Object {Test-NetConnection -ComputerName 192.168.0.$_ -ErrorAction SilentlyContinue ; Write-Output "Working on a ping to 192.168.0.$($_) $(Show-ProgressSpinner)"}

    .EXAMPLE
    Select random color with one rotation per color
    for ($k = 0 ; $k -lt 999 ; $k++) {show-progressspinner -color (Get-Random "Black","DarkBlue","DarkGreen","DarkCyan","DarkRed","DarkMagenta","DarkYellow","Gray","DarkGray","Blue","Green","Cyan","Red","Magenta","Yellow","White")}
    
#>

    
    param(
        [Parameter(
            Mandatory = $False
        )]
        [int32] $SpinCount = 1,

        [Parameter(
            Mandatory = $False
        )]
        [ValidateSet(
            "Black","DarkBlue","DarkGreen","DarkCyan","DarkRed","DarkMagenta",
            "DarkYellow","Gray","DarkGray","Blue","Green","Cyan","Red","Magenta",
            "Yellow","White"
        )]
        [string] $Color = "Gray",

        [Parameter(
            Mandatory = $False
        )]
        [int32] $SpinWaitInMilliseconds = 50
    )

    $EmptyStr = ""
    
    $SpinList = @(
        '| | | | | | |',
        '/ / / / / / /',
        '- - - - - - -',
        '\ \ \ \ \ \ \'
    )

    For ($i = 1 ; $i -le $SpinCount ; $i++) {
        ForEach ($Spin in $Spinlist) {
            Write-Host -Object "`r$($Spin)" -ForegroundColor $Color -NoNewline
            Start-Sleep -Milliseconds $SpinWaitInMilliseconds
        }
        Write-Host -Object "`r$EmptyStr" -ForegroundColor $Color -NoNewline
    }
}


function Start-FlashCard {
    param(
        [Parameter(
            Mandatory = $True,
            ValueFromPipeLine = $True,
            Position = 0
        )]
        [string] $FilePath,

        [Parameter(
            Mandatory = $false
        )]
        [int] $CardCount,

        [Parameter(
            Mandatory = $False
        )]
        [switch] $RandomizeOrder,

        [Parameter(
            Mandatory = $False
        )]
        [ValidateSet(
            "Easy","Medium","Hard","Exact"
        )]
        [string] $Difficulty = "Hard",

        [Parameter(
            Mandatory = $False
        )]
        [string] $MenuTextColor = "Green",

        [Parameter(
            Mandatory = $False
        )]
        [string] $PromptColor = "Green"
    )

    begin {

        # Add error correction for not finding a csv file

        $ColorList = @(
            "Black","DarkBlue","DarkGreen","DarkCyan","DarkRed","DarkMagenta",
            "DarkYellow","Gray","DarkGray","Blue","Green","Cyan","Red","Magenta",
            "Yellow","White"
        )

        $FlashCardContent    = @(Get-Content -Path $FilePath)           # If a file has 1 line, (gc /file).length returns the length of the string.  Needs the @ to force type recognition
        $NumberOfItemsInData = @(Get-Content -Path $FilePath).Length   


        # I really don't know why I had to make this switch, but $CardCount somewhere in scripting changed from default $null to 0
        # It used to be a simple if ($null -eq $CardCount) {make it the count of the file}
        # Then I had issues with a single line file cause of indexes starting at 0, which made both a division by 0 issue and immediate
        # failure due to 0 items to print to host.  After longer than I would like to admit, this is the only way I got it to work.
        # I also have to set it to a minimum of 1 to avoid division by 0 errors despite exiting immediately after.
       
        
        switch ($NumberOfItemsInData) {
            0 {
                $CardCount = 1           # cannot set to 0 cause of div by 0 issue
                Write-Output "File is empty"
                Exit
            }
            1 {
                if ($FlashCardContent[0] -ne 'Term,Definition') {
                    $CardCount = 1                                 
                }
                elseif ($FlashCardContent[0] -eq 'Term,Definition') {
                    $CardCount = 1      # cannot set to 0 cause of div by 0 issue
                    Write-Output "File is empty or too small to process"
                    Exit
                }  
            }
            2 {
                if ($FlashCardContent[0] -ne 'Term,Definition') {
                    $CardCount = 2
                }
                elseif ($FlashCardContent[0] -eq 'Term,Definition') {
                    $CardCount = 1
                }
            }
            Default {
                if ($NumberOfItemsInData -gt 2) {
                    if ($Null -eq $CardCount) {
                        if ($FlashCardContent[0] -ne 'Term,Definition') {
                            $CardCount = $NumberOfItemsInData
                        }
                        elseif ($FlashCardContent[0] -eq 'Term,Definition') {
                            $CardCount = $NumberOfItemsInData - 1
                        }
                    }
                    elseif ($CardCount -eq 0) {
                        if ($FlashCardContent[0] -ne 'Term,Definition') {
                            $CardCount = $NumberOfItemsInData
                        }
                        elseif ($FlashCardContent[0] -eq 'Term,Definition') {
                            $CardCount = $NumberOfItemsInData - 1
                        }
                    }
                }
            }
        }
        
        if ($FlashCardContent[0] -ne 'Term,Definition') {
            $FlashCardCSV = Import-Csv -Path $FilePath -Header "Term","Definition"
        }
        elseif ($FlashCardContent[0] -eq 'Term,Definition') {
            $FlashCardCSV = Import-Csv -Path $FilePath
        }
        else {
            Write-Output "Could not locate the path to the FlashCard data file (CSV format)."
            Write-Output "Path to the file was input as [$($FilePath)]"
        }

        switch ($Difficulty) {
            "Easy" {
                $Threshold = 0.649
            }

            "Medium" {
                $Threshold = 0.749
            }

            "Hard" {
                $Threshold = 0.849
            }

            "Exact" {
                $Threshold = 0.949
            }
        }
    }
    
    process {
        
        $Score = 0
        $Index = 0
        Clear-Host
        Show-WelcomeMessage
        
        For ($i = 0 ; $i -lt $CardCount ; $i++) {
            $SpinnerColor = Get-Random $ColorList
            If ($ExitString -ne "Exit") {                     # This if is substituting a while loop but works the same way as the iterations continue
                if ($RandomizeOrder) {
                    $Index = Get-Random -Minimum 0 -Maximum ($NumberOfItemsInData - 1)
                }
                elseif (!($RandomizeOrder)) {
                    $Index = $i
                }
                Write-Debug "Randomize is [$($RandomizeOrder)]"
                Write-Debug "Index is [$($Index)]"

                # Show-Question($Item[$Index].Term)
                
                # Format question
                $Question = $FlashCardCSV[$Index].Term 
                Format-Text("Score:  [$($Score)] out of [$($CardCount)]")
                Write-Output "`n`n"
                Format-Text($Question)
                Write-Output "`n"

                # Format answer
                $Answer = $FlashCardCSV[$Index].Definition
                
                # Format response
                $Response = $Null
                $Response = Read-Host "Please enter your response here"

                if ($Response -eq "Exit") {
                    $ExitString = $False
                    continue
                }

                # Calculate response against answer
                $Result = ./pstr.py pstr $Answer $Response
                Format-Text("Your score is this close to the answer [$($Result)] and you needed [$($Threshold)]")
                
                # Score
                if ($Result -gt $Threshold) {  # Update pass/fail to cumulative
                    Format-Text("The answer is [$($Answer)]")
                    Format-Text("Congratulations, you have earned a point")
                    Show-ProgressSpinner -SpinCount 20 -SpinWaitInMilliseconds 100 -Color $SpinnerColor
                    $Score += 1
                }
                elseif ($Result -le $Threshold) {
                    Format-Text("I'm sorry, this is not the correct answer")
                }

                Start-Sleep -Seconds 2
                Clear-Host
            }
        }
    }
    end {

        if ($CardCount -eq 0) {
            $FinalScore = 0
        }
        elseif ($Null -eq $CardCount) {
            $FinalScore = 0
        }
        elseif ($CardCount -ge 1) {
            $FinalScore = $Score / $CardCount
        }
        
        Clear-Host
        Show-EndText
        for ($i ; $i -lt 20 ; $i++) {
            $SpinnerColor = Get-Random $ColorList
            Show-ProgressSpinner -SpinCount 1 -SpinWaitInMilliseconds 100 -Color $SpinnerColor
        }
        Write-Output "[$(Get-Date)] with quiz name [$($FilePath)]" | Out-File $PSScriptRoot/Scores.txt -Append
        Write-Output "Your final score is:  [$($Score)] out of [$($CardCount)] total" | Out-File $PSScriptRoot/Scores.txt -Append
        Write-Output "Your percent score is:  [$($FinalScore * 100)]" | Out-File $PSScriptRoot/Scores.txt -Append
        Write-Output "" | Out-File $PSScriptRoot/Scores.txt -Append
    }
}

Write-Output `
@"

Please use:
Start-FlashCard -FilePath /path/to/csvfile

Optionally use RandomizeOrder to randomize the order of flashcards:
Start-FlashCard -FilePath /path/to/csvfile -RandomizeOrder

By default, the flashcards will cycle through the number of items
in your quiz.  To limit this, use:
Start-FlashCard -FilePath /path/to/csvfile -CardCount 10
Where 10 is the number of cards you want to have,
but is less than the items on the quiz.

For more parameter help, use:
Get-Help Start-FlashCard

"@ | Write-Host -ForegroundColor Cyan

# fin
