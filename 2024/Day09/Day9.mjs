#!/usr/bin/env node

import fs from 'node:fs';

function main() {
    /* SETUP! */

    const inputDisk = fs.readFileSync(process.argv[2], 'utf8').trim();

    // We have to know the sizes (number of blocks) of each file, as well as the
    // size of each one of the free space segments between them to later implement
    // the defragmentation/compression algorithm.
    const {fileBlocks, spaceBlocks} = separateDiskMapContents(inputDisk);

    /* PART ONE! */

    // Next, we build an array of tuples representing how many times each file ID
    // appears in each segment of the compressed disk image.
    const resultDisk = defragmentDisk(fileBlocks, spaceBlocks);

    // Calculate the hash by addingmultiplying everything wooooo!
    const hash = calculateDiskHash(resultDisk);
    console.log("PART ONE: %s", hash);

    return 0;
}

/* HELPER FUNCTIONS! */

function separateDiskMapContents(diskMap) {
    const fileBlocks = [];
    const spaceBlocks = [];

    // We know that the number of blocks of each file and each segment of contiguous
    // space are alternated in the disk map. So, if we're starting with file blocks,
    // and arrays are 0-index-based, then all index pair numbers are file blocks and
    // all odd numbers are space blocks.

    for (let index in diskMap) {
        const numBlocks = parseInt(diskMap[index]);
        index % 2 == 0 ? fileBlocks.push(numBlocks) : spaceBlocks.push(numBlocks);
    }

    return {
        fileBlocks: fileBlocks,
        spaceBlocks: spaceBlocks,
    }
}

function defragmentDisk(files, freeSpace) {
    // Resulting representation of our defragmented disk.
    const defragmented = [];

    let sIndex = 0;
    let fFrontIndex = 1;
    let fBackIndex = files.length - 1;
    let nextFileToPullSize = files[fBackIndex];

    // The first file will always be the first one in the defragmented disk, so we
    // add it here since the beginning.
    //
    // Each tuple contains two elements:
    // 1) How many times this file id is repeated.
    // 2) Said file id.

    defragmented.push([files[0], 0]);

    while (true) {
        // Pick the next empty space where we will pull the "next last" file
        // of the disk.
        const nextSpaceBlockSize = freeSpace[sIndex];
        let remSpaceBlockSize = nextSpaceBlockSize;

        while (remSpaceBlockSize > 0) {
            // Try to fit the "next last" in the empty space we have at hand.
            remSpaceBlockSize -= nextFileToPullSize;

            // If after fitting it, we still have free space to use, then bring
            // the "next last" file and repeat the fit attempting loop.
            if (remSpaceBlockSize >= 0) {
                defragmented.push([nextFileToPullSize, fBackIndex]);
                nextFileToPullSize = files[--fBackIndex];
            }
        }

        // We ran out of empty space. If the remaining space is negative, then that
        // means we still have a fragment of the "next last" file to move. So, we
        // add to the resulting disk a tuple with only the amount of blocks we were
        // able to transfer, and subtract that from the total file size.

        if (remSpaceBlockSize < 0) {
            defragmented.push([remSpaceBlockSize + nextFileToPullSize, fBackIndex]);
            nextFileToPullSize = Math.abs(remSpaceBlockSize);
            remSpaceBlockSize = 0;
        }

        // Add the next file from the front as is.
        sIndex++;
        defragmented.push([files[fFrontIndex], fFrontIndex++]);

        // Exit our loop if we're out of empty space blocks or files to process.
        if (sIndex === freeSpace.length || fFrontIndex >= fBackIndex)
            break;
    }

    // Append the remainder of the last "next last" file, if any.
    if (nextFileToPullSize > 0) {
        defragmented.push([nextFileToPullSize, fBackIndex]);
    }

    // If we ran out of empty space without processing all files, then append those
    // at the end of the defragmented disk.
    while (fFrontIndex < fBackIndex) {
        defragmented.push([files[fFrontIndex]], fFrontIndex++);
    }

    return defragmented;
}

function calculateDiskHash(disk) {
    let result = BigInt(0);
    let index = 0;

    for (let memBlock of disk) {
        const fileSize = memBlock[0];
        const fileId = memBlock[1];

        for (let count = 0; count < fileSize; count++) {
            result += BigInt(fileId * index);
            index++;
        }
    }
    return result;
}

function printArrayOfTuples(arr, label) {
    console.log('\n%s: [', label);
    for (let elem of arr) {
        console.log("    [%s, %s]", elem[0], elem[1]);
    }
    console.log(']\n');
}

main()
