const fs = require('fs');
const path = require('path');

const mdPath = path.join('..', 'DATABASE_SCHEMA.md');
const mdContent = fs.readFileSync(mdPath, 'utf8');

const regex = /```sql\n([\s\S]*?)\n```/g;
let match;
const blocks = [];
while ((match = regex.exec(mdContent)) !== null) {
  blocks.push(match[1]);
}

if (blocks.length < 21) {
    console.error("Expected at least 21 SQL blocks, got", blocks.length);
    process.exit(1);
}

const enums = blocks[16];
const tables = blocks.slice(0, 16).join('\n\n');
const rest = blocks.slice(17, 21).join('\n\n');

const outContent = [enums, tables, rest].join('\n\n');

const outDir = path.join(__dirname, 'supabase', 'migrations');
if (!fs.existsSync(outDir)) {
    fs.mkdirSync(outDir, { recursive: true });
}
const outPath = path.join(outDir, '20260607000001_initial_schema.sql');
fs.writeFileSync(outPath, outContent);
console.log("Migration created at", outPath);
