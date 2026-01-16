const http = require("http");
const { generateEmailHtml } = require("./generator");

const PORT = Number(process.env.PORT) || 3000;

function sendJson(res, statusCode, payload) {
  const body = JSON.stringify(payload, null, 2);
  res.writeHead(statusCode, {
    "Content-Type": "application/json",
    "Content-Length": Buffer.byteLength(body),
  });
  res.end(body);
}

const server = http.createServer((req, res) => {
  if (req.method === "GET" && req.url === "/health") {
    sendJson(res, 200, { status: "ok" });
    return;
  }

  if (req.method !== "POST" || req.url !== "/render") {
    sendJson(res, 404, { error: "Rota não encontrada. Use POST /render." });
    return;
  }

  let body = "";
  req.setEncoding("utf8");
  req.on("data", (chunk) => {
    body += chunk;
  });
  req.on("end", () => {
    try {
      const payload = JSON.parse(body);
      const html = generateEmailHtml(payload);
      res.writeHead(200, {
        "Content-Type": "text/html; charset=utf-8",
      });
      res.end(html);
    } catch (error) {
      sendJson(res, 400, { error: "Payload inválido", details: error.message });
    }
  });
});

server.listen(PORT, () => {
  console.log(`Servidor pronto em http://localhost:${PORT}`);
});
