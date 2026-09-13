# 🖼️ freeimg

免费 AI 图片生成 skill —— 一句话提示词，直接在 AI 对话里出 2K 高清图。

- **模型**：[Gitee AI](https://ai.gitee.com) Serverless API 的 `z-image-turbo`（8 步极速生成）
- **费用**：免费令牌，每天约 100 张 2K 额度
- **网页版**：[freeimg.shenzjd.com](https://freeimg.shenzjd.com) —— 18000+ 提示词库、12 种预设风格、7 种尺寸、历史记录与图床上传

## 安装

```bash
npx skills add wu529778790/shenzjd-skills -s freeimg -y
```

## 快速开始

1. **配置令牌**（免费，只需一次）：登录 [ai.gitee.com/serverless-api](https://ai.gitee.com/serverless-api) → 任意模型「在线体验」→「API」→「添加令牌」→ 复制，然后：

   ```bash
   mkdir -p ~/.freeimg && echo "GITEE_AI_API_KEY=你的令牌" > ~/.freeimg/config.env && chmod 600 ~/.freeimg/config.env
   ```

2. **让 AI 画图**：对任意支持的 AI 工具说「用 freeimg 生成一张××图」，或手动运行：

   ```bash
   node scripts/generate.mjs --prompt "扁平卡通插画：一只叼着骨头的小狗，居中构图，无文字无水印" \
     --out dog.png --width 1024 --height 1024
   ```

详细用法与提示词模板见 [SKILL.md](SKILL.md)。

> 💡 提示词库与风格预设：直接逛 [freeimg.shenzjd.com](https://freeimg.shenzjd.com)，网页版和本 skill 共用同一枚令牌。
