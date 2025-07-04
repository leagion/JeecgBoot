const express = require('express');
const path = require('path');
const fs = require('fs');

const app = express();

// 读取 config.json 获取端口配置
function getConfig() {
  try {
    const configPath = path.join(__dirname, 'dist/config.json');
    const configContent = fs.readFileSync(configPath, 'utf-8');
    return JSON.parse(configContent);
  } catch (error) {
    console.warn('Failed to read config.json, using default port 3000');
    return { server: { port: 3000 } };
  }
}

const config = getConfig();
const port = config.server?.port || 3000;

// 静态文件服务
app.use(express.static(path.join(__dirname, 'dist')));

// 所有路由都返回 index.html（SPA 应用）
app.get('*', (req, res) => {
  res.sendFile(path.join(__dirname, 'dist/index.html'));
});

app.listen(port, () => {
  console.log(`Server is running on port ${port}`);
  console.log(`Config loaded:`, config);
}); 