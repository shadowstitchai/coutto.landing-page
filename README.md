# coutto.app 主页

## 安装和设置

### 前置要求

- Ruby 2.7 或更高版本
- Bundler gem

### 安装步骤

1. **克隆仓库**
   ```bash
   git clone https://github.com/your-username/couttoapp.github.io.git
   cd couttoapp.github.io
   ```

2. **安装依赖**
   ```bash
   bundle install
   ```

   这将安装 Jekyll 和所有必需的依赖项（通过 `Gemfile` 和 `github-pages` gem）。

## 本地开发

### 启动 Jekyll 服务器

在项目根目录运行：

```bash
bundle exec jekyll serve
```

服务器将在 `http://localhost:4000` 启动。你可以在浏览器中访问该地址查看网站。

### 调试和开发

- **自动重新加载**：Jekyll 会自动检测文件更改并重新生成网站
- **查看详细输出**：使用 `bundle exec jekyll serve --verbose` 查看详细日志
- **停止服务器**：在终端中按 `Ctrl+C`

### 常见问题

如果遇到端口冲突，可以使用 `--port` 参数指定其他端口：
```bash
bundle exec jekyll serve --port 4001
```

## 配置网站

### 基本配置

编辑 `_config.yml` 文件来配置网站。主要配置项包括：

#### 应用信息
- `ios_app_id`: iOS 应用 ID（用于自动获取应用信息）
- `ios_app_country`: 国家代码（如 `cn` 表示中国）
- `app_name`: 应用名称
- `app_price`: 应用价格
- `app_description`: 应用描述
- `app_icon`: 应用图标路径
- `appstore_link`: App Store 链接
- `playstore_link`: Google Play Store 链接

#### 功能列表（Features）
在 `features` 部分配置功能卡片：

```yaml
features:
  - title: 功能标题
    description: 功能描述
    fontawesome_icon_name: icon-name  # FontAwesome 图标名称（如 video, print, file-pdf 等）
    background_color: "#F5E882"       # 可选：每个功能卡片的背景颜色（十六进制颜色值）
```

**注意**：
- 每个功能卡片可以设置独立的 `background_color`
- 如果不设置 `background_color`，将使用默认的背景颜色
- 可以在 [FontAwesome](https://fontawesome.com/icons) 查找可用的图标名称

#### 主题设置
- `cover_image`: 封面图片路径
- `cover_overlay_color`: 封面遮罩颜色
- `cover_overlay_transparency`: 遮罩透明度（0-1）
- `device_color`: 设备颜色（blue, black, yellow, coral, white）
- `feature_title_color`: 功能标题颜色
- `feature_text_color`: 功能文本颜色
- `feature_background_color`: 功能卡片默认背景颜色

#### 多语言支持
- `languages`: 支持的语言列表，如 `["zh", "en"]`
- `default_lang`: 默认语言

### 页面配置

- **首页**：`index.html` 使用 `default` 布局
- **其他页面**：在 `_pages` 目录下创建 Markdown 文件，使用 `page` 布局
- **404 页面**：`404.html` 使用 `default` 布局

## 部署到 GitHub Pages

### 方法 1：自动部署（推荐）

1. **推送代码到 GitHub**
   ```bash
   git add .
   git commit -m "Update site"
   git push origin main
   ```

2. **启用 GitHub Pages**
   - 进入仓库的 Settings
   - 找到 Pages 部分
   - 选择 Source 为 `main` 分支（或 `gh-pages` 分支）
   - GitHub 会自动构建和部署网站

3. **访问网站**
   - 网站将在 `https://your-username.github.io/repo-name/` 可用
   - 首次部署可能需要几分钟时间

### 方法 2：使用 GitHub Actions（可选）

如果需要更精细的控制，可以设置 GitHub Actions 工作流来自动构建和部署。

### 自定义域名

1. 在仓库根目录创建 `CNAME` 文件，内容为你的域名：
   ```
   yourdomain.com
   ```

2. 在 GitHub Pages 设置中配置自定义域名

3. 在 DNS 提供商处添加 CNAME 记录指向 `your-username.github.io`

## 页面模版基于
- 基于 [Automatic App Landing Page](https://github.com/emilbaehr/automatic-app-landing-page) 项目
- [Jekyll](https://github.com/jekyll/jekyll)
- [FontAwesome](https://fontawesome.github.io/Font-Awesome/)
