Param([string]$InputFile)

# function Move-Point([int[]]$Pt, [int[]]$Vel, [int]$Rows, [int]$Cols)
# {
#     if ($Vel[0] -ge 0) { $Pt[0] = ($Pt[0] + $Vel[0]) % $Cols }
#     else
#     {
#         $nextX = $Pt[0] + $Vel[0]
#         if ($nextX -lt 0) { $Pt[0] = $Cols - [Math]::Abs($nextX) }
#         else { $Pt[0] = $nextX }
#     }

#     if ($Vel[1] -ge 0) { $Pt[1] = ($Pt[1] + $Vel[1]) % $Rows }
#     else
#     {
#         $nextY = $Pt[1] + $Vel[1]
#         if ($nextY -lt 0) { $Pt[1] = $Rows - [Math]::Abs($nextY) }
#         else { $Pt[1] = $nextY }
#     }

#     return $Pt
# }

function Move-Point([int[]]$Pt, [int[]]$Vel, [int]$Rows, [int]$Cols)
{
    $nextX = ($Pt[0] + $Vel[0]) % $Cols
    if ($nextX -lt 0) { $nextX = $Cols - [Math]::Abs($nextX) }

    $nextY = ($Pt[1] + $Vel[1]) % $Rows
    if ($nextY -lt 0) { $nextY = $Rows - [Math]::Abs($nextY) }

    return @($nextX, $nextY)
}

$origp1 = @(0,0)
$origp2 = @(10,3)
$origp3 = @(2,4)

$v1 = @(1,3)
$v2 = @(-1,2)
$v3 = @(-2,-3)

$rows = 7
$cols = 11

$p1 = $origp1
$p2 = $origp2
$p3 = $origp3

$i = 1

while ($true)
{
    $p1 = Move-Point -Pt $p1 -Vel $v3 -Rows $rows -Cols $cols
    # Write-Host "Step $i; $p1"
    if (($p1[0] -eq $origp1[0]) -and ($p1[1] -eq $origp1[1])) { break; }
    $i++
}

Write-Host "P1 Return: ${i} Movements!"

$p1 = $origp1
Write-Host "P1 Back to Origin: $p1"

for ($j = 1; $j -le 100; $j++)
{
    $p1 = Move-Point -Pt $p1 -Vel $v3 -Rows $rows -Cols $cols
}

Write-Host "P1 after 100 moves: $p1"
