---
name: deploy-oss
description: >-
  Build this Jekyll site and publish it to the Aliyun OSS bucket coutto for
  https://coutto.cn. Use when the user asks to deploy, publish, sync, or push
  the landing page to OSS, Aliyun, or coutto.cn.
---

# Deploy to Aliyun OSS

Publish with the repo scripts. Do not reimplement the sync.

```sh
./scripts/setup.sh          # once: ossutil, gems, .env from .env.example
./scripts/deploy-oss.sh     # jekyll build + ossutil sync --delete
```

The scripts put Homebrew Ruby 3.3 on `PATH` when it is installed. Ruby 4 cannot run the pinned Jekyll 3.9. macOS system Ruby 2.6 cannot install current `github-pages`.

Bucket `coutto` in `cn-shanghai`. Public site is `https://coutto.cn`. AccessKey goes in `.env` only for a manual deploy.

## GitHub Actions

A push to `main` runs `.github/workflows/deploy-oss.yml`, which calls these scripts. Do not reimplement the sync there.

Store the AccessKey as repository Actions secrets. They are encrypted and injected as environment variables. Do not put them in Actions Variables, and do not commit them.

- `OSS_ACCESS_KEY_ID`
- `OSS_ACCESS_KEY_SECRET`

## Rules

- Do not change `_config.yml` `url` or the `CNAME` file. Those stay `coutto.app` for GitHub Pages. The deploy script overrides `url` to `https://coutto.cn` for the OSS build.
- `sync --delete` makes the bucket a mirror of `_site/`. Never point it at another bucket.
- Do not commit `.env`, `.ossutilconfig`, or `bin/ossutil`. Do not print the AccessKey.
- Do not change the bucket ACL, the custom domain, or DNS from this skill. The bucket is already public-read and `coutto.cn` is already bound.
- Do not configure HTTPS or upload a certificate. No certificate is available yet. Keep serving and checking the site over HTTP.
- Pretty URLs (`/en/`, `/open`) need the directory marker and the no-trailing-slash object. The deploy script does that. Do not remove it.
- `.well-known/apple-app-site-association` must be uploaded as `application/json`.

After a deploy, request `http://coutto.cn/` and one nested path such as `http://coutto.cn/en/`. HTTPS has no certificate yet, so check HTTP.
