import http from "http";
import fs from "fs";
import path from "path";

const root = process.cwd();

function readJSON(file, fallback) {
  try {
    if (!fs.existsSync(file)) return fallback;
    return JSON.parse(fs.readFileSync(file, "utf8"));
  } catch {
    return fallback;
  }
}

const server = http.createServer(async (req, res) => {
  const url = new URL(req.url, "http://localhost");

  if (url.pathname === "/health") {
    const rcFile = path.join(root, "starship-rc-report.json");
    const kernelFile = path.join(root, "kernel", "kernel-autonomous-report.json");

    const rc = readJSON(rcFile, { status: "no_rc_report" });
    const kernel = readJSON(kernelFile, { status: "no_kernel_report" });

    res.writeHead(200, { "Content-Type": "application/json" });
    res.end(JSON.stringify({
      status: "ok",
      rc,
      kernel
    }, null, 2));
    return;
  }

  if (url.pathname === "/ledger/accounts") {
    const accountsFile = path.join(root, "ledger", "accounts.json");
    const accounts = readJSON(accountsFile, []);
    res.writeHead(200, { "Content-Type": "application/json" });
    res.end(JSON.stringify(accounts, null, 2));
    return;
  }

  if (url.pathname === "/tx/history") {
    const historyFile = path.join(root, "transactions", "history.json");
    const history = readJSON(historyFile, []);
    res.writeHead(200, { "Content-Type": "application/json" });
    res.end(JSON.stringify(history, null, 2));
    return;
  }

  if (url.pathname === "/routing/routes") {
    const routesFile = path.join(root, "routing", "routes.json");
    const routes = readJSON(routesFile, []);
    res.writeHead(200, { "Content-Type": "application/json" });
    res.end(JSON.stringify(routes, null, 2));
    return;
  }

  res.writeHead(404, { "Content-Type": "application/json" });
  res.end(JSON.stringify({ error: "not_found" }));
});

const port = process.env.PORT || 8080;
server.listen(port, () => {
  console.log("🚀 Starship API dinlemede:", port);
});
