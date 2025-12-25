## 專案簡介
此Vue專案用來展示Github Action workflow.
嘗試透過 Github Action，在 vue 專案推到 main 後自動編譯及更新 S3 上的網站。
其中 S3及Cloudfront的基礎設施建置, 置於 https://github.com/Wells-Huang/terraform_static_vuepage_deployment , 需先完成

## 使用說明
當main分支有push時, 會觸發專案重新編譯, 設定AWS憑證, 並將編譯好的檔案傳到S3, 最後刷新 CloudFront 快取，讓使用者能看到最新版本

## 驗證步驟:
除了每次將vue專案推到main分支會觸發外
為了驗證方便, 在Github Action也可以用手動觸發上述流程


