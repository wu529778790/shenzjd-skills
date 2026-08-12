# GitHub 图床 CDN 链接格式（通用版）

图床 = 任意 GitHub 仓库 + 一个图片目录。脚本会把图片上传到该仓库指定目录，
并用 CDN 域名访问。本文件说明链接格式与踩坑，适用于任何仓库。

## 链接结构

```
<CDN_BASE>/<owner>/<repo>@<branch>/<目录>/<文件名>   (jsdelivr / jsdmirror / jsd-onmicrosoft)
<CDN_BASE>/<owner>/<repo>/<branch>/<目录>/<文件名>   (statically / raw)
```

示例（jsdelivr，owner=alice，repo=my-figure-bed，branch=main，目录=images）：

```
https://cdn.jsdelivr.net/gh/alice/my-figure-bed@main/images/photo.png
```

## 支持的 CDN（脚本 --cdn 参数）

| 名称 | 格式 | 说明 |
|------|------|------|
| `jsdelivr`（默认） | `https://cdn.jsdelivr.net/gh/{o}/{r}@{b}/{path}` | 全球通用、最流行 |
| `jsdmirror` | `https://cdn.jsdmirror.com/gh/{o}/{r}@{b}/{path}` | jsdelivr 国内镜像，大陆访问快 |
| `jsd-onmicrosoft` | `https://jsd.onmicrosoft.cn/gh/{o}/{r}@{b}/{path}` | 另一个国内镜像 |
| `statically` | `https://cdn.statically.io/gh/{o}/{r}/{b}/{path}` | 备用 |
| `raw` | `https://raw.githubusercontent.com/{o}/{r}/{b}/{path}` | GitHub 官方 raw，无缓存加速 |

## Markdown 引用

```
![文件名](https://cdn.jsdelivr.net/gh/{o}/{r}@{b}/{目录}/<文件名>)
```

## ⚠️ 关键坑（踩过必 404）

1. **分支必须与仓库实际分支一致**：jsDelivr 系默认找 `main`，如果仓库用的是其他分支
   （如 `master`），URL 必须显式带 `@master`。脚本会自动检测仓库 `default_branch`，
   无需手动指定；但若仓库图片实际不在默认分支，请用 `--branch` 显式指定。
2. **目录名必须与上传时一致**（默认 `blog/`，可用 `--dir` 或 `IMGX_DIR` 改）。
3. **jsdmirror / jsdelivr 只做静态镜像**：不支持动态 WebP 转换
   （不同于 raw.githubusercontent.com 的 `?format=webp`），仓库里没有 `.webp` 文件就 404。
   图床统一用原图链接，不要加 `?format=webp`。
4. **文件名避免空格和特殊字符**（`#`、`?`、`%` 等），否则链接需要 URL 编码，容易出错。
   中文文件名可用（GitHub 支持），引用时保持原样即可。
5. 引用链接时**不要加 `?raw=true` 之类参数**。
6. **CDN 缓存**：上传后链接通常需数秒~数分钟生效，立即访问偶发 404，稍后重试即可。

## 仓库 API 参考（脚本内部使用）

- 上传/更新: `PUT /repos/{owner}/{repo}/contents/{path}`，body 含 `message`、`content`(base64)、`branch`
- 删除: `DELETE /repos/{owner}/{repo}/contents/{path}`，需 `sha`
- 列出全部: `GET /repos/{owner}/{repo}/git/trees/{branch}?recursive=1`
- 检查存在: `GET /repos/{owner}/{repo}/contents/{path}?ref={branch}`（404 = 不存在）
- 默认分支: `GET /repos/{owner}/{repo}` → `.default_branch`
