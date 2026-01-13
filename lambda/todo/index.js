const { S3Client, GetObjectCommand, PutObjectCommand } = require('@aws-sdk/client-s3');

const s3Client = new S3Client({ region: process.env.AWS_REGION || 'us-east-1' });
const BUCKET_NAME = process.env.TODO_BUCKET_NAME;
const OBJECT_KEY = process.env.TODO_OBJECT_KEY || 'todos.json';

// CORS headers
const CORS_HEADERS = {
    'Access-Control-Allow-Origin': '*',
    'Access-Control-Allow-Headers': 'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token',
    'Access-Control-Allow-Methods': 'GET,POST,DELETE,OPTIONS',
    'Content-Type': 'application/json'
};

/**
 * Lambda Handler
 */
exports.handler = async (event) => {
    console.log('Event:', JSON.stringify(event, null, 2));
    console.log('Environment:', {
        BUCKET_NAME,
        OBJECT_KEY,
        AWS_REGION: process.env.AWS_REGION
    });

    const httpMethod = event.httpMethod;
    // 移除 stage 前綴（例如 /prod/api/todos ->/api/todos）
    let path = event.path;
    if (event.requestContext && event.requestContext.stage) {
        const stage = event.requestContext.stage;
        if (path.startsWith(`/${stage}/`)) {
            path = path.substring(stage.length + 1);
        }
    }

    console.log('Processed path:', path, 'Method:', httpMethod);

    try {
        // 路由處理
        if (path === '/api/todos' && httpMethod === 'GET') {
            return await getTodos();
        } else if (path === '/api/todos' && httpMethod === 'POST') {
            return await createTodo(event);
        } else if (path.startsWith('/api/todos/') && httpMethod === 'DELETE') {
            return await deleteTodo(event);
        } else {
            console.log('No matching route found');
            return response(404, { error: 'Not Found', path, method: httpMethod });
        }
    } catch (error) {
        console.error('Error:', error);
        console.error('Error stack:', error.stack);
        return response(500, { error: 'Internal Server Error', message: error.message });
    }
};

/**
 * 從 S3 讀取 TODOs
 */
async function readTodosFromS3() {
    try {
        const command = new GetObjectCommand({
            Bucket: BUCKET_NAME,
            Key: OBJECT_KEY
        });

        const data = await s3Client.send(command);
        const bodyString = await streamToString(data.Body);
        return JSON.parse(bodyString);
    } catch (error) {
        if (error.name === 'NoSuchKey') {
            // 檔案不存在，返回空陣列
            return [];
        }
        throw error;
    }
}

/**
 * 將 TODOs 寫入 S3
 */
async function writeTodosToS3(todos) {
    const command = new PutObjectCommand({
        Bucket: BUCKET_NAME,
        Key: OBJECT_KEY,
        Body: JSON.stringify(todos, null, 2),
        ContentType: 'application/json'
    });

    await s3Client.send(command);
}

/**
 * GET /api/todos - 取得所有 TODOs
 */
async function getTodos() {
    const todos = await readTodosFromS3();
    return response(200, { todos });
}

/**
 * POST /api/todos - 新增 TODO
 */
async function createTodo(event) {
    // 處理 API Gateway 可能的 base64 編碼
    let bodyStr = event.body || '{}';

    console.log('Raw body:', bodyStr);
    console.log('isBase64Encoded:', event.isBase64Encoded);

    if (event.isBase64Encoded && bodyStr) {
        bodyStr = Buffer.from(bodyStr, 'base64').toString('utf-8');
        console.log('Decoded body:', bodyStr);
    }

    let body;
    try {
        body = JSON.parse(bodyStr);
    } catch (e) {
        console.error('Failed to parse body:', e);
        return response(400, { error: 'Invalid JSON', message: 'Request body is not valid JSON' });
    }

    const { text } = body;
    console.log('Parsed text:', text);

    if (!text || typeof text !== 'string' || text.trim() === '') {
        return response(400, { error: 'Invalid request', message: 'Text is required' });
    }

    const todos = await readTodosFromS3();

    const newTodo = {
        id: generateId(),
        text: text.trim(),
        completed: false,
        createdAt: new Date().toISOString()
    };

    todos.push(newTodo);
    await writeTodosToS3(todos);

    return response(201, { todo: newTodo });
}

/**
 * DELETE /api/todos/{id} - 刪除 TODO
 */
async function deleteTodo(event) {
    const id = event.pathParameters?.id;

    if (!id) {
        return response(400, { error: 'Invalid request', message: 'ID is required' });
    }

    const todos = await readTodosFromS3();
    const index = todos.findIndex(todo => todo.id === id);

    if (index === -1) {
        return response(404, { error: 'Not Found', message: 'TODO not found' });
    }

    todos.splice(index, 1);
    await writeTodosToS3(todos);

    return response(200, { message: 'TODO deleted successfully' });
}

/**
 * 產生唯一 ID
 */
function generateId() {
    return `${Date.now()}-${Math.random().toString(36).substr(2, 9)}`;
}

/**
 * Stream to String 轉換
 */
async function streamToString(stream) {
    const chunks = [];
    for await (const chunk of stream) {
        chunks.push(chunk);
    }
    return Buffer.concat(chunks).toString('utf-8');
}

/**
 * HTTP Response 建構
 */
function response(statusCode, body) {
    return {
        statusCode,
        headers: CORS_HEADERS,
        body: JSON.stringify(body)
    };
}
