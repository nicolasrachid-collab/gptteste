#!/usr/bin/env node
const fs = require("fs");
const path = require("path");
const { generateEmailHtml } = require("./generator");

function printHelp() {
  const usage = `
Uso:
  node src/cli.js --input examples/newsletter.json
  node src/cli.js --input examples/newsletter.json --output dist/newsletter.html
  cat examples/newsletter.json | node src/cli.js

Opções:
  --input, -i    Caminho para o arquivo JSON com o payload
  --output, -o   Caminho para salvar o HTML gerado (opcional)
  --help, -h     Mostra esta ajuda
`;

  console.log(usage.trim());
}

function parseArgs(argv) {
  const args = { input: null, output: null, help: false };
  for (let i = 0; i < argv.length; i += 1) {
    const arg = argv[i];
    if (arg === "--input" || arg === "-i") {
      args.input = argv[i + 1];
      i += 1;
    } else if (arg === "--output" || arg === "-o") {
      args.output = argv[i + 1];
      i += 1;
    } else if (arg === "--help" || arg === "-h") {
      args.help = true;
    }
  }
  return args;
}

function readStdin() {
  return new Promise((resolve, reject) => {
    let data = "";
    process.stdin.setEncoding("utf8");
    process.stdin.on("data", (chunk) => {
      data += chunk;
    });
    process.stdin.on("end", () => resolve(data));
    process.stdin.on("error", reject);
  });
}

async function run() {
  const args = parseArgs(process.argv.slice(2));
  if (args.help) {
    printHelp();
    return;
  }

  let payloadRaw = "";
  if (args.input) {
    const inputPath = path.resolve(process.cwd(), args.input);
    payloadRaw = fs.readFileSync(inputPath, "utf8");
  } else if (!process.stdin.isTTY) {
    payloadRaw = await readStdin();
  } else {
    printHelp();
    process.exitCode = 1;
    return;
  }

  const payload = JSON.parse(payloadRaw);
  const html = generateEmailHtml(payload);

  if (args.output) {
    const outputPath = path.resolve(process.cwd(), args.output);
    fs.mkdirSync(path.dirname(outputPath), { recursive: true });
    fs.writeFileSync(outputPath, html, "utf8");
  } else {
    process.stdout.write(`${html}\n`);
  }
}

run().catch((error) => {
  console.error("Erro ao gerar HTML:", error.message);
  process.exitCode = 1;
});
