# Video Cover Packager

把一份视频素材（脚本 / 大纲 / 字幕 / 逐字稿 / 音频 / 视频）包装成所选平台可直接使用的完整发布方案：封面标题、平台标题、作品描述、平台标签；用户确认标题与场景后再生成封面创意方向与正式封面。

方法参考 [jennie-dingding-cover-packager](https://github.com/JennieWei/jennie-dingding-cover-packager)，并按本仓库 skill 规范重写。

## 支持平台

小红书 / 抖音 / 视频号 / B站 / YouTube（可多选，只输出所选平台）。

## 使用

```text
使用 video-cover-packager。
平台：抖音、小红书。
素材：本期字幕文件。
```

流程：包装简报 → 标题策略 → 封面标题 → 平台标题 → 封面主题 → 封面预审 → 作品描述 → 平台标签 → 待确认 → 生图 → 标题合成出成品封面。

## 标题合成

AI 生图模型渲染中文易出乱码，封面标题一律后期合成。底图生成后运行：

```bash
python3 scripts/add-title.py --image 底图.png \
  --title "AI编码智能体工程技能包" --out 成品封面.png
```

默认按 3:4 竖版规范排版（标题块宽 92%、顶部安全边 7%），支持两行标题（用 `|` 分隔）、自定义描边/填充/阴影色和中文字体。依赖 `pip install pillow`。

## 边界

- 一次只处理一期视频。
- 不编造素材中不存在的数字、结果或背书。
- 文字发布包确认后才进入生图。
