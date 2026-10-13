# Flashcards

Flashcard style quiz for command line using fuzzy strings to calculate accuracy.

## How to Run

### Requirements:

1. Python3

2. PowerShell (if installing on Linux)

   1. See https://learn.microsoft.com/en-us/powershell/scripting/install/install-ubuntu?view=powershell-7.6 for more information on PowerShell on Linux

### Windows

#### In Visual Studio Code

1. Open the file

2. Press `F5` or use `Play` to load the script

3. Run the function

   ```powershell
   Start-FlashCards -FilePath C:\path\to\ExampleQuiz.csv
   ```

#### In PowerShell

1. Start the PowerShell file called Start-FlashCard.ps1 to load the function

```powershell
. $pshome\powershell.exe -executionpolicy bypass -noexit -nologo -file "C:\Path\to\Start-FlashCard.ps1"
```

2. After the function loads, a helpful message will print to the terminal

```
This application will prompt you to input the answer to
your questions in a flash card style question and answer.
Score is tallied as pass for 1 point and fail for 0 point.
   
Flash cards are sequential by default.  Exit and use 
Start-FlashCards -FilePath /path/to/csv -RandomizeOrder
to randomize the order.
  
If you need to exit, please enter the word "Exit" to return
to the prompt.
```

3. Start the function by pointing to a csv file with your questions and answers

```powershell
Start-FlashCards -FilePath C:\path\to\ExampleQuiz.csv
```

### Linux

```powershell
chmod +x ./Start-FlashCard.ps1
. ./Start-FlashCard.ps1
Start-FlashCards -FilePath /path/to/csv -RandomizeOrder
```

# Parameters

1. `-FilePath`:  Mandatory parameter to load a quiz file.  The quiz file should be in the format Question,Answer.  I wrote the csv import to be as forgiving as possible with formatting headers and other items.  As long as it's generally Question,Answer (delimiter, "delim," is comma and fields are in double quotes) and made in libreoffice or other office software, the csv formatting will be fine.

```powershell
Start-FlashCard -FilePath /path/to/csv
```

2. `-CardCount`:  The CardCount parameter creates the number of questions and answer pairs to select.  The following example selects 10 questions form your quiz.

```powershell
Start-FlashCard -FilePath /path/to/csv -CardCount 10
```

3. `-RandomizeOrder`: Randomizes the order of the questions.

```powershell
Start-FlashCards -FilePath /path/to/csv -RandomizeOrder
```

4. `-Difficulty`: This controls the forgiveness of the fuzzy string math.  The options are `Easy`, `Medium`, `Hard`, `Exact`, where the fuzzy string is looking for values (percentages) `0.649`, `0.749`, `0.849`, and `0.949` respectively.  For longer format quizes, a lower percentage is better (unless you're memorizing definitions).  For single word answers, use a higher difficulty
