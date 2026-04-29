import test from 'node:test';
import assert from 'node:assert/strict';
import { buildServer } from '../src/index.js';

test('GET /health', async () => {
  const app = buildServer();
  const res = await app.inject({ method: 'GET', url: '/health' });
  assert.equal(res.statusCode, 200);
  assert.equal(res.json().status, 'ok');
});

test('GET /download', async () => {
  const app = buildServer();
  const res = await app.inject({ method: 'GET', url: '/download?sizeMB=1' });
  assert.equal(res.statusCode, 200);
  assert.equal(res.rawPayload.length, 1024 * 1024);
});

test('POST /upload', async () => {
  const app = buildServer();
  const res = await app.inject({ method: 'POST', url: '/upload', payload: { hello: 'world' } });
  assert.equal(res.statusCode, 200);
  assert.ok(res.json().receivedBytes > 0);
});
