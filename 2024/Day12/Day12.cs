using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;

public class Day12
{
    class GardenPlot
    {
        public char PlantType { get; }
        public bool Visited { get; private set; }

        public GardenPlot(char plantType)
        {
            PlantType = plantType;
            Visited = false;
        }

        public void MarkVisited() { Visited = true; }
    }

    class GardenRegion
    {
        public char PlantType { get; }
        public int Perimeter { get; set; }
        public int Area { get; set; }

        public GardenRegion(char plantType)
        {
            PlantType = plantType;
            Perimeter = 0;
            Area = 0;
        }

        public override string ToString()
        {
            return $"[{PlantType}, {Area}A, {Perimeter}P]";
        }
    }

    class GardenMap
    {
        private List<List<GardenPlot>> _plots;

        public int Rows { get; }
        public int Columns { get; }
        public int Size => Rows * Columns;

        public GardenMap(List<List<GardenPlot>> gardenPlots,
                         int numRows,
                         int numColumns)
        {
            _plots = gardenPlots;
            Rows = numRows;
            Columns = numColumns;
        }

        public GardenPlot GetPlot(int x, int y)
        {
            return x >= 0 && x < Rows && y >=0 && y < Columns
                   ? _plots[x][y]
                   : null;
        }

        public int GetPlotBoundaries(int x, int y)
        {
            // A plot boundary is defined by that border with another plot with
            // a different plant type, or by an edge of the garden (i.e. neighboring
            // plot is null).

            GardenPlot thisPlot = GetPlot(x, y);
            GardenPlot[] neighbors = new[] {
                GetPlot(x - 1, y),
                GetPlot(x + 1, y),
                GetPlot(x, y - 1),
                GetPlot(x, y + 1)
            };

            return neighbors.Count(n => n is null || n.PlantType != thisPlot.PlantType);
        }
    }

    static int Main(string[] args)
    {
        // SETUP! //

        // Read the garden input and generate the garden map with the little
        // plan objects also containing their visited flags.
        List<List<GardenPlot>> plotsLists =
            File.ReadLines(args[0])
                .Select(line => line.Select(c => new GardenPlot(c)).ToList())
                .ToList();

        // We are guaranteed that our input is a perfect square/rectangle, so we
        // can assume the length of the first row applies to all of them.
        GardenMap theGarden = new(plotsLists, plotsLists.Count, plotsLists[0].Count);

        // PART ONE! //

        int totalPrice = CalculateFencesCost(theGarden);
        Console.WriteLine("PART ONE: {0}", totalPrice);
        return 0;
    }

    static int CalculateFencesCost(GardenMap garden)
    {
        List<GardenRegion> gardenRegions = new();
        int numVisitedPlots = 0;

        for (int i = 0; i < garden.Rows; i++)
        {
            for (int j = 0; j < garden.Columns; j++)
            {
                GardenPlot p = garden.GetPlot(i, j);
                if (p.Visited)
                    continue;

                GardenRegion newRegion = new(p.PlantType);
                TraverseGardenRegion(garden, newRegion, i, j, ref numVisitedPlots);
                gardenRegions.Add(newRegion);
            }

            // No need to continue searching the garden if we know we've already
            // mapped every plot to a region.
            if (numVisitedPlots == garden.Size)
                break;
        }

        // foreach (GardenRegion gr in gardenRegions)
        // {
        //     Console.WriteLine(gr.ToString());
        // }
        return gardenRegions.Sum(region => region.Area * region.Perimeter);
    }

    static void TraverseGardenRegion(GardenMap garden,
                                     GardenRegion region,
                                     int x,
                                     int y,
                                     ref int totalVisited)
    {
        GardenPlot current = garden.GetPlot(x, y);

        // If the next pair of coordinates point outside of the garden boundaries,
        // or to a plot we've already mapped to a region, then there's nothing else
        // we have to do here.
        if (current is null || current.PlantType != region.PlantType || current.Visited)
            return ;

        current.MarkVisited();
        totalVisited++;

        // Update the total region perimeter with this current plot's boundaries.
        region.Perimeter += garden.GetPlotBoundaries(x, y);
        // Increase the total region area by 1 plot.
        region.Area++;

        // Traverse this plots neighbors to continue mapping the region.
        TraverseGardenRegion(garden, region, x-1, y, ref totalVisited);
        TraverseGardenRegion(garden, region, x+1, y, ref totalVisited);
        TraverseGardenRegion(garden, region, x, y-1, ref totalVisited);
        TraverseGardenRegion(garden, region, x, y+1, ref totalVisited);
    }
}
