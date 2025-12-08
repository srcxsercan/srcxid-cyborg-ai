#!/usr/bin/env node
import fs from "fs";
import { detectSmells } from "../fixer/smell-detector.js";
import { suggestNamingFix } from "../fixer/naming-fixer.js";
import { validateFolder } from "../fixer/folder-fixer.js";

const file = process.argv[2];
const code = fs.readFileSync(file, "utf8");

console.log("🔍 Smell Analysis:");
console.log(detectSmells(code));

console.log("\n🔧 Naming Suggestion:");
console.log(suggestNamingFix(file));

console.log("\n📁 Folder Validation:");
console.log(validateFolder(file));
