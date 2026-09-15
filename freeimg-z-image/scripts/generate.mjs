#!/usr/bin/env node
// FreeImg — free text-to-image via Gitee AI serverless z-image-turbo
// Web app companion: https://freeimg.shenzjd.com
// Usage:
//   generate.mjs --prompt "..." --out out.png [--width 1024] [--height 1024]
//                [--steps 8] [--negative "..."]
// Token resolution: env GITEE_AI_API_KEY > ~/.freeimg/config.env > guided error.
import fs from 'node:fs'
import path from 'node:path'
import os from 'node:os'

const CONFIG_HINT = [
  '未找到 Gitee AI 令牌。免费获取（三步）：',
  '  1. 登录 https://ai.gitee.com/serverless-api',
  '  2. 任意模型详情页 →「在线体验」→「API」→「添加令牌」→ 复制',
  '  3. 写入本地配置（只需一次）:',
  '       mkdir -p ~/.freeimg && echo "GITEE_AI_API_KEY=你的令牌" > ~/.freeimg/config.env && chmod 600 ~/.freeimg/config.env',
  '  或导出环境变量: export GITEE_AI_API_KEY=你的令牌',
  '  可视化网页版（无需配置）: https://freeimg.shenzjd.com',
].join('\n')

function loadToken() {
  if (process.env.GITEE_AI_API_KEY) return process.env.GITEE_AI_API_KEY.trim()
  const cfg = process.env.FREEIMG_CONFIG || path.join(os.homedir(), '.freeimg', 'config.env')
  try {
    const text = fs.readFileSync(cfg, 'utf-8')
    const m = text.match(/^GITEE_AI_API_KEY=(.+)$/m)
    if (m) return m[1].trim()
  } catch { /* not found */ }
  console.error(CONFIG_HINT)
  process.exit(1)
}

const args = process.argv.slice(2)
const arg = (name, dflt) => {
  const i = args.indexOf('--' + name)
  return i >= 0 ? args[i + 1] : dflt
}
const prompt = arg('prompt')
const out = arg('out', 'image.png')
if (!prompt) {
  console.error('usage: generate.mjs --prompt "提示词" --out out.png [--width 1024] [--height 1024] [--steps 8] [--negative "..."]')
  process.exit(1)
}
for (const k of ['width', 'height', 'steps']) {
  const v = Number(arg(k, { width: 1024, height: 1024, steps: 8 }[k]))
  if (!Number.isInteger(v) || v <= 0) { console.error(`--${k} 必须是正整数`); process.exit(1) }
  if (k !== 'steps' && v % 8 !== 0) { console.error(`--${k} 必须是 8 的倍数（如 1024/1536/2048）`); process.exit(1) }
}

const body = {
  model: 'z-image-turbo',
  prompt,
  width: Number(arg('width', 1024)),
  height: Number(arg('height', 1024)),
  num_inference_steps: Number(arg('steps', 8)),
}
const neg = arg('negative', '文字,字母,水印,签名,模糊')
if (neg) body.negative_prompt = neg

const API = 'https://ai.gitee.com/v1/images/generations'
const headers = {
  'Content-Type': 'application/json',
  Authorization: 'Bearer ' + loadToken(),
  'X-Failover-Enabled': 'true',
}

async function call() {
  const resp = await fetch(API, { method: 'POST', headers, body: JSON.stringify(body) })
  if (!resp.ok) {
    const text = (await resp.text()).slice(0, 300)
    const err = new Error(`HTTP ${resp.status}: ${text}`)
    err.status = resp.status
    throw err
  }
  const data = await resp.json()
  const item = data?.data?.[0]
  if (!item) throw new Error('响应中没有图片数据: ' + JSON.stringify(data).slice(0, 300))
  if (item.b64_json) return Buffer.from(item.b64_json, 'base64')
  if (item.url) {
    const img = await fetch(item.url)
    if (!img.ok) throw new Error('图片下载失败: HTTP ' + img.status)
    return Buffer.from(await img.arrayBuffer())
  }
  throw new Error('响应中既没有 b64_json 也没有 url')
}

// 偶发 502/503：最多重试 2 次，指数退避
let buf
for (let attempt = 0; ; attempt++) {
  try {
    buf = await call()
    break
  } catch (e) {
    const transient = [502, 503, 504].includes(e.status)
    if (transient && attempt < 2) {
      await new Promise(r => setTimeout(r, 2000 * (attempt + 1)))
      continue
    }
    if (e.status === 429 || e.status === 403) {
      console.error('生成失败: ' + e.message + '\n（可能当日免费额度已用完，明天再试或更换令牌）')
    } else {
      console.error('生成失败: ' + e.message)
    }
    process.exit(1)
  }
}

fs.writeFileSync(out, buf)
console.log('saved: ' + path.resolve(out))
