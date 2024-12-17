Param([string]$InputFile,
      [int]$GridRows,
      [int]$GridColumns)

class GuardRobot
{
    [int[]]$Position
    [int[]]$Velocity

    GuardRobot([int[]]$vectorData)
    {
        $this.Position = @($vectorData[0], $vectorData[1])
        $this.Velocity = @($vectorData[2], $vectorData[3])
    }

    GuardRobot([int[]]$posData, [int[]]$velData)
    {
        $this.Position = $posData
        $this.Velocity = $velData
    }
}

function Run-Main
{
    ### SETUP! ###

    $inputData = Get-Content -Path $InputFile
    $robotVectors = [GuardRobot[]]::new($inputData.length)

    for ($i = 0; $i -lt $inputData.length; $i++)
    {
        # So glad Powershell casts the number strings to ints when creating the
        # GuardRobot objects :)
        $robotData = ($inputData[$i] -Split " ") | % { ($_ -Split "=")[1] -Split "," }
        $robotVectors[$i] = [GuardRobot]::new($robotData)
    }

    ### PART ONE! ###

    $finalMap = Calculate-Grid -Bots $robotVectors -Seconds 100

    # By flooring this division, we get the 0-value of each axis in our grid.

    $axisX = [int][Math]::Floor($GridRows / 2)
    $axisY = [int][Math]::Floor($GridColumns / 2)

    # Calculate the number of spots occupied by one or more robots in each quadrant
    # of our grid outside the bathroom.

    $quadrantNW = `
      ($finalMap | Where-Object {
           ($_.Position[0] -lt $axisY) -and ($_.Position[1] -lt $axisX)
       }).length

    $quadrantNE = `
      ($finalMap | Where-Object {
           ($_.Position[0] -gt $axisY) -and ($_.Position[1] -lt $axisX)
       }).length

    $quadrantSW = `
      ($finalMap | Where-Object {
           ($_.Position[0] -lt $axisY) -and ($_.Position[1] -gt $axisX)
       }).length

    $quadrantSE = `
      ($finalMap | Where-Object {
           ($_.Position[0] -gt $axisY) -and ($_.Position[1] -gt $axisX)
       }).length

    $safetyFactor = $quadrantNW * $quadrantNE * $quadrantSW * $quadrantSE
    Write-Host "ANSWER: $safetyFactor"
}

function Calculate-Grid([GuardRobot[]]$Bots, [int]$Seconds)
{
    $movedBots = [GuardRobot[]]::new($Bots.length)

    for ($i = 0; $i -lt $Bots.length; $i++)
    {
        # Move each robot the number of times indicated by the seconds elapsed.
        $b = $Bots[$i]
        $moved = Move-Robot -Bot $b -Times 100
        $movedBots[$i] = $moved
    }

    return $movedBots
}

function Move-Robot([GuardRobot]$Bot, [int]$Times)
{
    # Here is the trick to optimizing this. We don't have to actually move the
    # bots n times. We just have to multiply each value of the velocity vector
    # n times, and then take into consideration the grid wrapping using a modulo
    # operation. In the case of negatives, we need to subtract the result of said
    # modulo from the total grid size in that dimension.

    $nextX = ($Bot.Position[0] + ($Bot.Velocity[0] * $Times)) % $GridColumns
    if ($nextX -lt 0) { $nextX = $GridColumns - [Math]::Abs($nextX) }

    $nextY = ($Bot.Position[1] + ($Bot.Velocity[1] * $Times)) % $GridRows
    if ($nextY -lt 0) { $nextY = $GridRows - [Math]::Abs($nextY) }

    return [GuardRobot]::new(@($nextX, $nextY), $Bot.Velocity)
}

Run-Main
