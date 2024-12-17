// Day10 Code!

import Foundation

typealias GridPoint = (val: Int, visited: Bool)
typealias Coordinate = (row: Int, column: Int)

enum TrailsOp {
    case SCORE, RATING
}

func Main() {
    do {
        /* SETUP! */

        // Read the input file into an array with each of its lines.
        let topographyLines: [Substring] =
          try String(contentsOfFile: CommandLine.arguments[1], encoding: String.Encoding.utf8)
              .split(whereSeparator: { $0.isNewline })

        /* PART ONE! */

        var grid: [[GridPoint]] = generateTopographyGrid(topographyMap: topographyLines)
        let result1: Int = calculateTrailheadsScores(topographyGrid: &grid,
                                                     opType: TrailsOp.SCORE)
        print("PART ONE: \(result1)")

        /* PART TWO! */

        let result2: Int = calculateTrailheadsScores(topographyGrid: &grid,
                                                     opType: TrailsOp.RATING)
        print("PART TWO: \(result2)")
    }
    catch let error as NSError {
        print(error)
    }
}

func generateTopographyGrid(topographyMap: [Substring]) -> [[GridPoint]] {
    var grid: [[GridPoint]] = []

    for line in topographyMap {
        var gridLine: [GridPoint] = []

        for char in line {
            gridLine.append((val: char.wholeNumberValue ?? -1, visited: false))
        }

        grid.append(gridLine)
    }

    return grid
}

func calculateTrailheadsScores(topographyGrid: inout [[GridPoint]],
                               opType: TrailsOp) -> Int {
    var result: Int = 0

    for i in stride(from: 0, to: topographyGrid.count, by: 1) {
        let row: [GridPoint] = topographyGrid[i]

        for j in stride(from: 0, to: row.count, by: 1) {
            let tile: GridPoint = row[j]

            // If it's not a zero height, then it can't be a trailhead, so we
            // continue on to the next one.
            if (tile.val != 0) {
                continue
            }

            switch opType {
            case .SCORE:
                // Setting prevTile to a hypothetical -1 tile, just because we need
                // to pass something. The walkTrails() function checks that the previous
                // tile is one less than the current one, so -1 fits that criteria for 0.
                result += walkTrails(grid: &topographyGrid,
                                     position: (i, j),
                                     prevTile: (-1, false))

                // Clear the grid of all visited marks for the next trail.
                resetGrid(grid: &topographyGrid)

            case .RATING:
                // Same deal of the -1 hypothetical tile as with the SCORE walkTrails()
                // alternative function call above.
                result += walkAllTrails(grid: &topographyGrid,
                                        nextPosition: (i, j),
                                        prevPosition: (-1, -1),
                                        prevTile: (-1, false))
            }
        }
    }

    return result
}

func walkTrails(grid: inout [[GridPoint]],
                position: Coordinate,
                prevTile: GridPoint) -> Int {

    let row = position.row
    let column = position.column

    // If we're out of bounds, then there's no trail to walk.
    if (row < 0 || row >= grid.count || column < 0 || column >= grid[0].count) {
        return 0
    }

    let currentTile: GridPoint = grid[row][column]

    // If we've already been to this tile before on this trail, or its height is
    // not one unit higher than the previous one, then there's nothing more to be
    // walked here.
    if (currentTile.visited || (currentTile.val - prevTile.val) != 1) {
        return 0
    }

    // Swift's philosophy is very value-oriented, so we have to set the visited
    // flag to true directly on the grid object. Otherwise, it's set to a copy
    // of the tile object, rather than the tile itself.
    grid[row][column].visited = true

    // We got to the end of a trail! So return its respective +1.
    if (currentTile.val == 9) {
        return 1
    }

    let result: Int =
      walkTrails(grid: &grid, position: (row+1, column), prevTile: currentTile)
      + walkTrails(grid: &grid, position: (row-1, column), prevTile: currentTile)
      + walkTrails(grid: &grid, position: (row, column+1), prevTile: currentTile)
      + walkTrails(grid: &grid, position: (row, column-1), prevTile: currentTile)

    return result
}

func walkAllTrails(grid: inout [[GridPoint]],
                   nextPosition: Coordinate,
                   prevPosition: Coordinate,
                   prevTile: GridPoint) -> Int {

    let currentRow: Int = nextPosition.row
    let currentCol: Int = nextPosition.column
    let currentTile: GridPoint = grid[currentRow][currentCol]
    let heightDiff: Int = currentTile.val - prevTile.val

    // If the current tile's height is different from one higher than the previous
    // one, then this path is not part of a trail.
    if (heightDiff != 1) {
        return 0
    }

    // We got to the end of a trail! So return its respective +1.
    if (currentTile.val == 9) {
        return 1
    }

    var result: Int = 0
    let neighborsCoords: [(Int, Int)] = [
      (currentRow + 1, currentCol),
      (currentRow - 1, currentCol),
      (currentRow, currentCol + 1),
      (currentRow, currentCol - 1)
    ]

    let coordsToVisit: [(Int, Int)] = neighborsCoords.filter {
        $0 != prevPosition
          && $0.0 >= 0 && $0.0 < grid.count
          && $0.1 >= 0 && $0.1 < grid[0].count
    }

    for coord in coordsToVisit {
        result += walkAllTrails(grid: &grid,
                                nextPosition: coord,
                                prevPosition: (currentRow, currentCol),
                                prevTile: currentTile)
    }

    return result
}

func resetGrid(grid: inout [[GridPoint]]) {
    for i in stride(from: 0, to: grid.count, by: 1) {
        for j in stride(from: 0, to: grid[i].count, by: 1) {
            grid[i][j].visited = false
        }
    }
}

Main()
