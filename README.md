# Vue TODO List - 無伺服器架構部署

使用 AWS 無伺服器服務建置的現代化 TODO List 應用，展示完整的 Infrastructure as Code (IaC) 實踐。

## 🏗️ 架構說明

```
使用者請求
    ↓
CloudFront (CDN + 地區限制: 台灣、日本)
    ↓
API Gateway (Load Balancer)
    ├─ /api/*     → Lambda Function → S3 (TODO 資料)
    └─ /*         → S3 Static Website (Vue 前端)
```

### 架構特點

- **API Gateway 作為 Load Balancer**：根據路徑智慧路由請求
- **CloudFront CDN**：提供全球加速和地區存取控制
- **Lambda 無伺服器計算**：處理 TODO CRUD API
- **S3 雙重用途**：託管靜態網站 + 儲存 TODO 資料
- **GitHub Actions CI/CD**：自動化部署流程

## 📋 功能特性

✅ 新增待辦事項  
✅ 刪除待辦事項  
✅ 資料持久化（儲存在 S3）  
✅ 現代化響應式 UI  
✅ 實時 API 連線狀態  
✅ 自動部署到 AWS  
✅ 地區限制（僅台灣和日本可存取）

## 🚀 部署步驟

### 前置需求

- AWS 帳號
- Terraform >= 1.0
- Node.js >= 18
- AWS CLI（已配置憑證）

### 1. 部署基礎設施

```bash
# 進入 Terraform 目錄
cd terraform

# 初始化 Terraform
terraform init

# 查看部署計劃
terraform plan

# 部署所有資源
terraform apply
```

部署完成後，記錄以下輸出值：
- `cloudfront_domain_name`
- `cloudfront_distribution_id`
- `website_bucket_name`
- `github_actions_access_key_id`
- `github_actions_secret_access_key`（敏感，需執行 `terraform output -json` 查看）

### 2. 設定 GitHub Secrets

在 GitHub Repository 的 Settings → Secrets and variables → Actions 中新增：

| Secret 名稱 | 值 | 來源 |
|------------|-----|------|
| `AWS_ACCESS_KEY_ID` | xxx | Terraform output |
| `AWS_SECRET_ACCESS_KEY` | xxx | Terraform output（敏感） |
| `AWS_S3_BUCKET_NAME` | xxx | Terraform output: `website_bucket_name` |
| `CLOUDFRONT_DISTRIBUTION_ID` | xxx | Terraform output |
| `CLOUDFRONT_DOMAIN_NAME` | xxx.cloudfront.net | Terraform output: `cloudfront_domain_name` |

### 3. 安裝 Lambda 依賴

```bash
cd lambda/todo
npm install
cd ../..
```

### 4. 首次手動上傳網站

```bash
# 安裝前端依賴
npm install

# 建立環境變數
echo "VUE_APP_API_BASE_URL=https://你的CloudFront域名" > .env.production

# 編譯專案
npm run build

# 上傳到 S3
aws s3 sync dist/ s3://你的bucket名稱 --delete
```

### 5. 自動部署

之後只要將程式碼推送到 `main` 分支，GitHub Actions 會自動：
1. 編譯 Vue 應用
2. 上傳到 S3
3. 刷新 CloudFront 快取

## 🔧 本地開發

```bash
# 安裝依賴
npm install

# 啟動開發伺服器
npm run dev
```

**注意**：本地開發時 API 會指向部署的 CloudFront endpoint。

## 📂 專案結構

```
.
├── terraform/              # Terraform 基礎設施程式碼
│   ├── provider.tf        # AWS Provider 配置
│   ├── variables.tf       # 變數定義
│   ├── s3.tf             # S3 Buckets
│   ├── cloudfront.tf     # CloudFront Distribution
│   ├── api_gateway.tf    # API Gateway (Load Balancer)
│   ├── lambda.tf         # Lambda Function
│   ├── iam.tf            # IAM 角色和權限
│   └── outputs.tf        # 輸出值
├── lambda/
│   └── todo/             # Lambda 函數
│       ├── index.js      # TODO API 邏輯
│       └── package.json  # 依賴定義
├── src/
│   ├── components/
│   │   └── TodoList.vue  # TODO List 組件
│   └── App.vue           # 主應用
├── .github/
│   └── workflows/
│       └── deploy.yml    # GitHub Actions CI/CD
└── README.md
```

## 🔐 安全性

- ✅ S3 Buckets 適當設定存取權限
- ✅ CloudFront 地區限制（僅台灣、日本）
- ✅ HTTPS 強制使用
- ✅ IAM 最小權限原則
- ✅ 敏感資訊使用 GitHub Secrets

## 🌍 地區限制

目前設定僅允許以下地區存取：
- 🇹🇼 台灣 (TW)
- 🇯🇵 日本 (JP)

其他地區將收到 403 Forbidden 錯誤。

若要調整，請修改 `terraform/variables.tf` 中的 `allowed_countries` 變數。

## 🧪 驗證測試

### 測試 CloudFront

```bash
curl -I https://你的CloudFront域名/
```

### 測試 API

```bash
# 取得 TODOs
curl https://你的CloudFront域名/api/todos

# 新增 TODO
curl -X POST https://你的CloudFront域名/api/todos \
  -H "Content-Type: application/json" \
  -d '{"text":"測試項目"}'

# 刪除 TODO
curl -X DELETE https://你的CloudFront域名/api/todos/你的todo-id
```

### 瀏覽器測試

1. 開啟 `https://你的CloudFront域名`
2. 開啟瀏覽器開發者工具（F12）→ Network 標籤
3. 新增一個 TODO
4. 觀察 Network 中的 `/api/todos` POST 請求
5. 確認 API 連線狀態指示燈為綠色

## 📝 TODO API 文件

### GET /api/todos
取得所有待辦事項

**回應範例**：
```json
{
  "todos": [
    {
      "id": "1234567890-abc",
      "text": "完成專案",
      "completed": false,
      "createdAt": "2026-01-12T10:00:00.000Z"
    }
  ]
}
```

### POST /api/todos
新增待辦事項

**請求範例**：
```json
{
  "text": "新的待辦事項"
}
```

### DELETE /api/todos/{id}
刪除指定待辦事項

## 🛠️ 故障排除

### CloudFront 顯示舊內容
執行手動 invalidation：
```bash
aws cloudfront create-invalidation \
  --distribution-id 你的DISTRIBUTION_ID \
  --paths "/*"
```

### Lambda 函數錯誤
檢查 CloudWatch Logs：
```bash
aws logs tail /aws/lambda/你的函數名稱 --follow
```

### API 連線失敗
1. 確認 CloudFront domain 設定正確
2. 檢查瀏覽器 Console 是否有 CORS 錯誤
3. 確認 API Gateway 和 Lambda 都已正確部署

## 📊 成本估算

基於低流量使用（每月 < 10,000 請求）：
- CloudFront: 免費方案內
- API Gateway: ~$0.01
- Lambda: 免費方案內
- S3: ~$0.05

**總計**: 約 USD $0.10/月

## 🙏 致謝

使用的技術棧：
- Vue 3
- AWS Lambda (Node.js 18)
- AWS API Gateway
- AWS S3
- AWS CloudFront
- Terraform
- GitHub Actions

---

**License**: MIT  
**Author**: Wells Huang
