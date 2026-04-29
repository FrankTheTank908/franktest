import Fastify from 'fastify';

export function buildServer() {
  const app = Fastify({ logger: false });

  app.get('/health', async () => ({ status: 'ok', service: 'netproof-server' }));

  app.get('/download', async (req, reply) => {
    const sizeMB = Number(req.query.sizeMB ?? 10);
    const bytes = Math.max(1, Math.min(100, sizeMB)) * 1024 * 1024;
    reply.header('Content-Type', 'application/octet-stream');
    return Buffer.alloc(bytes, 'a');
  });

  app.post('/upload', async (req) => {
    const body = await req.body;
    const bytes = Buffer.byteLength(typeof body === 'string' ? body : JSON.stringify(body ?? {}));
    return { receivedBytes: bytes, at: new Date().toISOString() };
  });

  app.get('/config', async () => ({
    version: 1,
    suggestedDownloadSizeMB: 10,
    suggestedUploadSizeMB: 5,
    notes: 'TODO: Add nearest server selection.'
  }));

  return app;
}

if (process.env.NODE_ENV !== 'test') {
  const app = buildServer();
  app.listen({ port: Number(process.env.PORT ?? 8080), host: '0.0.0.0' });
}
