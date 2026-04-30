import Fastify from 'fastify';

export function buildServer() {
  const app = Fastify({ logger: false });
  const uploadOnly = process.env.UPLOAD_ONLY === 'true';
  const allowedOrigin = process.env.ALLOWED_ORIGIN || '*';

  app.addHook('onSend', async (req, reply, payload) => {
    reply.header('Access-Control-Allow-Origin', allowedOrigin);
    reply.header('Access-Control-Allow-Methods', 'GET,POST,OPTIONS');
    reply.header('Access-Control-Allow-Headers', 'Content-Type');
    return payload;
  });

  app.options('*', async (_, reply) => {
    reply.code(204).send();
  });

  app.get('/health', async () => ({ status: 'ok', service: 'netproof-server', uploadOnly }));

  app.get('/download', async (req, reply) => {
    if (uploadOnly) {
      reply.code(403);
      return { error: 'download disabled in UPLOAD_ONLY mode' };
    }
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
    version: 2,
    uploadOnly,
    suggestedDownloadSizeMB: uploadOnly ? 0 : 10,
    suggestedUploadSizeMB: 8,
    notes: 'Pi mode supports upload-first diagnostics.'
  }));

  return app;
}

if (process.env.NODE_ENV !== 'test') {
  const app = buildServer();
  app.listen({ port: Number(process.env.PORT ?? 8080), host: '0.0.0.0' });
}
