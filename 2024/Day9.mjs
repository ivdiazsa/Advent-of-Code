#!/usr/bin/env node

import fs from 'node:fs';

function main() {
    const inputDisk = fs.readFileSync(process.argv[2], 'utf8').trim();
    console.log("INPUT: %s", inputDisk);
}

main()
