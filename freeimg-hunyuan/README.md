# ⚡ freeimg-hunyuan

腾讯混元生图 skill —— **免费 10 万张额度**，文生图 + 垫图（图生图），走 CloudBase AI。

- **模型**：混元 3.0（`HY-Image-3.0-Plus-4090-Tob-v1.0`，垫图 `HY-Image-v3.0-I2I-ToB-v1.0.1`）
- **费用**：**完全免费** —— 领取微信「小程序成长计划」激励资源包即得 **10 万张 AI 生图 + 10 亿 Token**（6 个月有效），额度烧在你自己环境的资源包上，全程不花钱
- **网页版**：[freeimg.shenzjd.com/hunyuan](https://freeimg.shenzjd.com/hunyuan) —— 配套可视化版本，页面上有**从领取资源包、创建密钥到出图的完整备注教程**，填密钥即用

## 安装

```bash
npx skills add wu529778790/shenzjd-skills -s freeimg-hunyuan -y
```

## 快速开始（免费三步）

1. **免费领激励资源包**：微信公众平台「行业能力 → 小程序成长计划」领取（**10 万张 AI 生图 + 10 亿 Token**，6 个月有效），点「去使用」创建云开发环境，记下环境 ID
2. **建密钥**：[腾讯云 API 密钥管理](https://console.cloud.tencent.com/cam/capi) 新建，复制 SecretId / SecretKey
3. **写配置**（只需一次）：

   ```bash
   mkdir -p ~/.freeimg-hunyuan && printf "TCB_ENV_ID=你的环境ID\nTCB_SECRET_ID=你的SecretId\nTCB_SECRET_KEY=你的SecretKey\n" > ~/.freeimg-hunyuan/config.env && chmod 600 ~/.freeimg-hunyuan/config.env
   ```

4. **让 AI 生图**：对任意支持的 AI 工具说「用混元生成一张××图」，或手动运行：

   ```bash
   node scripts/generate.mjs --prompt "国潮插画：山水之间的亭台楼阁，暖色调，无文字无水印" --size 1280x720 --out output.png
   ```

详细用法见 [SKILL.md](SKILL.md)。

> 💡 卡在哪一步？打开 [freeimg.shenzjd.com/hunyuan](https://freeimg.shenzjd.com/hunyuan) 看图文教程，网页版和本 skill 共用同一套凭据。
>
> 🎁 只想零配置直接出图？用同仓库的 `freeimg-z-image` skill（z-image-turbo，免注册免领取）。
