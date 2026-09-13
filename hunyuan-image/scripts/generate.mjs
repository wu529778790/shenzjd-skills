#!/usr/bin/env node
// 混元生图 — 腾讯云 CloudBase AI (hunyuan-image) 文生图 / 图生图，纯 BYOK
// Web app companion: https://freeimg.shenzjd.com/hunyuan
// Usage:
//   generate.mjs --prompt "..." --out out.png [--size 1024x1024] [--no-revise] [--footnote " "]
//   generate.mjs --prompt "..." --image 垫图.jpg --out out.png        # 图生图(垫图)
// Credentials: env TCB_ENV_ID/TCB_SECRET_ID/TCB_SECRET_KEY > ~/.hunyuan/config.env > guided error.
// SDK: @cloudbase/node-sdk 首次运行自动安装到 ~/.hunyuan/sdk（CloudBase 网关鉴权是自定义签名，自行复刻不可靠）。
import fs from 'node:fs'
import path from 'node:path'
import os from 'node:os'
import { createRequire } from 'node:module'
import { spawnSync } from 'node:child_process'

// 与网页版 lib/tcb.ts 保持一致（旧 hunyuan-image 已于 2026-07 下线，勿改回）
const T2I_MODEL = 'HY-Image-3.0-Plus-4090-Tob-v1.0'
const I2I_MODEL = 'HY-Image-v3.0-I2I-ToB-v1.0.1'
const SIZES = ['1024x1024', '1280x720', '720x1280', '2048x512'] // 宽高 [512,2048] 且面积 ≤ 1024x1024
const PROMPT_MAX = 4000 // 混元 3.0 上限 8192，取 4000 与网页版对齐
const IMAGE_MAX_BYTES = 7.5 * 1024 * 1024 // 垫图文档限 10MB，base64 膨胀 1/3 后按 7.5MB 限制

// 单个空格 = 无水印（实测空串会回退成"AI生成"）；去水印后合规责任在使用方
const DEFAULT_FOOTNOTE = ' '

const CONFIG_HINT = [
  '未找到腾讯云云开发凭据（SecretId / SecretKey / 环境ID）。三步获取：',
  '  1. 微信公众平台「行业能力 → 小程序成长计划」领取资源包（10 亿 Token + 10 万张 AI 生图，6 个月有效），',
  '     领取后点「去使用」创建一个云开发环境，记下环境 ID',
  '  2. 腾讯云控制台「访问管理 → API 密钥管理」 https://console.cloud.tencent.com/cam/capi 新建密钥，',
  '     复制 SecretId 与 SecretKey',
  '  3. 写入本地配置（只需一次）:',
  '       mkdir -p ~/.hunyuan && printf "TCB_ENV_ID=你的环境ID\\nTCB_SECRET_ID=你的SecretId\\nTCB_SECRET_KEY=你的SecretKey\\n" > ~/.hunyuan/config.env && chmod 600 ~/.hunyuan/config.env',
  '  或导出环境变量: export TCB_ENV_ID=... TCB_SECRET_ID=... TCB_SECRET_KEY=...',
  '  可视化网页版（填密钥即用）: https://freeimg.shenzjd.com/hunyuan',
].join('\n')

function loadCreds() {
  const env = {
    envId: process.env.TCB_ENV_ID,
    secretId: process.env.TCB_SECRET_ID,
    secretKey: process.env.TCB_SECRET_KEY,
  }
  if (env.envId && env.secretId && env.secretKey) return env
  const cfg = process.env.HUNYUAN_CONFIG || path.join(os.homedir(), '.hunyuan', 'config.env')
  const keyMap = { TCB_ENV_ID: 'envId', TCB_SECRET_ID: 'secretId', TCB_SECRET_KEY: 'secretKey' }
  try {
    for (const line of fs.readFileSync(cfg, 'utf-8').split('\n')) {
      const m = line.match(/^(TCB_ENV_ID|TCB_SECRET_ID|TCB_SECRET_KEY)=(.*)$/)
      if (m) env[keyMap[m[1]]] = m[2].trim()
    }
  } catch { /* not found */ }
  if (env.envId && env.secretId && env.secretKey) return env
  console.error(CONFIG_HINT)
  process.exit(1)
}

// 依赖解析：本仓库/全局已装则直接用，否则装到 ~/.hunyuan/sdk 复用
function loadSdk() {
  try {
    return createRequire(import.meta.url)('@cloudbase/node-sdk')
  } catch { /* fallthrough to auto install */ }
  const sdkDir = process.env.HUNYUAN_SDK_DIR || path.join(os.homedir(), '.hunyuan', 'sdk')
  const pkgJson = path.join(sdkDir, 'package.json')
  if (!fs.existsSync(pkgJson)) {
    fs.mkdirSync(sdkDir, { recursive: true })
    fs.writeFileSync(pkgJson, JSON.stringify({ name: 'hunyuan-image-sdk', private: true, version: '1.0.0' }))
    console.error('首次使用：安装 @cloudbase/node-sdk 到 ' + sdkDir + ' …')
    const r = spawnSync('npm', ['install', '--prefix', sdkDir, '@cloudbase/node-sdk', '--no-fund', '--no-audit', '--loglevel', 'error'], { stdio: 'inherit' })
    if (r.status !== 0) {
      console.error('SDK 安装失败，请手动执行: npm install --prefix ' + sdkDir + ' @cloudbase/node-sdk')
      process.exit(1)
    }
  }
  return createRequire(path.join(sdkDir, 'package.json'))('@cloudbase/node-sdk')
}

const args = process.argv.slice(2)
const arg = (name, dflt) => {
  const i = args.indexOf('--' + name)
  return i >= 0 ? args[i + 1] : dflt
}
const hasFlag = (name) => args.includes('--' + name)

const prompt = arg('prompt')
const out = arg('out', 'image.png')
const image = arg('image')
if (!prompt) {
  console.error('usage: generate.mjs --prompt "提示词" --out out.png [--size 1024x1024] [--image 垫图.jpg] [--no-revise] [--footnote "品牌名"]')
  process.exit(1)
}
if (prompt.length > PROMPT_MAX) {
  console.error(`提示词最多 ${PROMPT_MAX} 字，当前 ${prompt.length} 字`)
  process.exit(1)
}
const size = arg('size', '1024x1024')
if (!SIZES.includes(size)) {
  console.error(`--size 只支持: ${SIZES.join(' / ')}（宽高 [512,2048] 且面积 ≤ 1024x1024）`)
  process.exit(1)
}

let imageBase64 = null
if (image) {
  const buf = /^data:image\//.test(image) || !fs.existsSync(image)
    ? Buffer.from(image.replace(/^data:image\/(png|jpe?g);base64,/, ''), 'base64') // base64 或 data URL
    : fs.readFileSync(image) // 文件路径
  if (buf.length > IMAGE_MAX_BYTES) {
    console.error(`垫图最大 10MB，当前约 ${(buf.length / 1024 / 1024).toFixed(1)}MB`)
    process.exit(1)
  }
  imageBase64 = buf.toString('base64')
}

const creds = loadCreds()
const tcb = loadSdk()
const app = tcb.init({ env: creds.envId, secretId: creds.secretId, secretKey: creds.secretKey, timeout: 120000 })
const model = app.ai().createImageModel('hunyuan-image')

const params = imageBase64
  ? { model: I2I_MODEL, prompt, images: [imageBase64], footnote: arg('footnote', DEFAULT_FOOTNOTE) }
  : {
      model: T2I_MODEL,
      prompt,
      size,
      revise: { value: !hasFlag('no-revise') },
      footnote: arg('footnote', DEFAULT_FOOTNOTE),
    }

async function call() {
  const res = await model.generateImage(params)
  const item = res?.data?.[0]
  if (!item?.url) throw new Error('模型未返回图片 URL: ' + JSON.stringify(res).slice(0, 300))
  const imgResp = await fetch(item.url) // 签名 URL 会过期，立即取回
  if (!imgResp.ok) throw new Error('图片下载失败: HTTP ' + imgResp.status)
  return { buf: Buffer.from(await imgResp.arrayBuffer()), revised: item.revised_prompt || '' }
}

// 只对限流(429)和服务端抖动(5xx)隔 2 秒重试一次；422 是提示词触发内容审核，重试必然再失败
let buf
let revisedPrompt = ''
for (let attempt = 0; ; attempt++) {
  try {
    ;({ buf, revised: revisedPrompt } = await call())
    break
  } catch (e) {
    const status = Number(e?.code)
    const message = e?.message || String(e)
    if ((status === 429 || (status >= 500 && status <= 599)) && attempt < 1) {
      await new Promise((r) => setTimeout(r, 2000))
      continue
    }
    if (status === 422) {
      console.error('生成失败(422 内容审核未通过): ' + message + '\n（提示词可能触发内容审核，调整措辞后重试）')
    } else {
      console.error('生成失败: ' + message)
    }
    process.exit(1)
  }
}

fs.writeFileSync(out, buf)
console.log('saved: ' + path.resolve(out))
if (revisedPrompt) console.log('revised_prompt: ' + revisedPrompt)
