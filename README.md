# Coutto Sew website

Jekyll source for https://coutto.app/, published by GitHub Pages from `main` at the repository root.

- Chinese homepage: `/`
- English homepage: `/en/`
- Tutorials: `/tutorials/` and `/en/tutorials/`
- Legal pages: `_pages/zh/` and `_pages/en/`; existing URLs are retained.
- App fallback: `_pages/open.html`
- Universal Links: `.well-known/apple-app-site-association`
- Existing designer portal: `designer/`

Run `bundle install` and `bundle exec jekyll serve` for local development.

Keep `url: https://coutto.app`, an empty `baseurl`, and the `CNAME` file. Include `.well-known` in the build. The production site allows indexing.

A push to `main` publishes the OSS copy to https://coutto.cn through `.github/workflows/deploy-oss.yml`. That build overrides `url` to `https://coutto.cn` and does not change the GitHub Pages config. Store `OSS_ACCESS_KEY_ID` and `OSS_ACCESS_KEY_SECRET` as Actions secrets. For a manual deploy, run `./scripts/setup.sh` once, put the AccessKey in `.env` (see `.env.example`), then `./scripts/deploy-oss.sh`.

The pre-migration version is preserved by Git tag `backup/before-landing-refresh-2026-10-22`.
