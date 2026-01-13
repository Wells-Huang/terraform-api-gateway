<template>
  <div class="todo-container">
    <div class="todo-card">
      <h1 class="todo-title">📝 我的待辦清單</h1>
      
      <!-- 新增 TODO 表單 -->
      <div class="add-todo-section">
        <input
          v-model="newTodoText"
          @keyup.enter="addTodo"
          type="text"
          class="todo-input"
          placeholder="輸入新的待辦事項..."
          :disabled="loading"
        />
        <button @click="addTodo" class="add-button" :disabled="loading || !newTodoText.trim()">
          <span v-if="!adding">➕ 新增</span>
          <span v-else>⏳</span>
        </button>
      </div>

      <!-- 載入狀態 -->
      <div v-if="loading && todos.length === 0" class="loading">
        <div class="spinner"></div>
        <p>載入中...</p>
      </div>

      <!-- 錯誤訊息 -->
      <div v-if="error" class="error-message">
        ⚠️ {{ error }}
      </div>

      <!-- TODO 列表 -->
      <div v-if="!loading || todos.length > 0" class="todo-list">
        <div v-if="todos.length === 0" class="empty-state">
          <p>🎉 目前沒有待辦事項！</p>
          <p class="empty-hint">新增一個開始吧</p>
        </div>

        <transition-group name="todo-list" tag="div">
          <div
            v-for="todo in todos"
            :key="todo.id"
            class="todo-item"
          >
            <div class="todo-content">
              <span class="todo-text">{{ todo.text }}</span>
              <span class="todo-date">{{ formatDate(todo.createdAt) }}</span>
            </div>
            <button @click="deleteTodo(todo.id)" class="delete-button" :disabled="deleting === todo.id">
              <span v-if="deleting !== todo.id">🗑️</span>
              <span v-else>⏳</span>
            </button>
          </div>
        </transition-group>
      </div>

      <!-- API 連線狀態指示 -->
      <div class="api-status">
        <span class="status-dot" :class="{ 'connected': apiConnected }"></span>
        <span class="status-text">{{ apiConnected ? 'API 已連線' : 'API 未連線' }}</span>
      </div>
    </div>
  </div>
</template>

<script>
export default {
  name: 'TodoList',
  data() {
    return {
      todos: [],
      newTodoText: '',
      loading: false,
      adding: false,
      deleting: null,
      error: null,
      apiConnected: false,
      apiBaseUrl: process.env.VUE_APP_API_BASE_URL || ''
    }
  },
  mounted() {
    this.fetchTodos()
  },
  methods: {
    async fetchTodos() {
      this.loading = true
      this.error = null

      try {
        const response = await fetch(`${this.apiBaseUrl}/api/todos`)
        
        if (!response.ok) {
          throw new Error(`HTTP error! status: ${response.status}`)
        }

        const data = await response.json()
        this.todos = data.todos || []
        this.apiConnected = true
      } catch (err) {
        console.error('Failed to fetch todos:', err)
        this.error = '無法載入待辦事項，請檢查網路連線'
        this.apiConnected = false
      } finally {
        this.loading = false
      }
    },

    async addTodo() {
      if (!this.newTodoText.trim()) return

      this.adding = true
      this.error = null

      try {
        const response = await fetch(`${this.apiBaseUrl}/api/todos`, {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json'
          },
          body: JSON.stringify({ text: this.newTodoText.trim() })
        })

        if (!response.ok) {
          throw new Error(`HTTP error! status: ${response.status}`)
        }

        const data = await response.json()
        this.todos.push(data.todo)
        this.newTodoText = ''
        this.apiConnected = true
      } catch (err) {
        console.error('Failed to add todo:', err)
        this.error = '無法新增待辦事項，請稍後再試'
        this.apiConnected = false
      } finally {
        this.adding = false
      }
    },

    async deleteTodo(id) {
      this.deleting = id
      this.error = null

      try {
        const response = await fetch(`${this.apiBaseUrl}/api/todos/${id}`, {
          method: 'DELETE'
        })

        if (!response.ok) {
          throw new Error(`HTTP error! status: ${response.status}`)
        }

        this.todos = this.todos.filter(todo => todo.id !== id)
        this.apiConnected = true
      } catch (err) {
        console.error('Failed to delete todo:', err)
        this.error = '無法刪除待辦事項，請稍後再試'
        this.apiConnected = false
      } finally {
        this.deleting = null
      }
    },

    formatDate(dateString) {
      if (!dateString) return ''
      const date = new Date(dateString)
      return date.toLocaleString('zh-TW', {
        month: '2-digit',
        day: '2-digit',
        hour: '2-digit',
        minute: '2-digit'
      })
    }
  }
}
</script>

<style scoped>
.todo-container {
  min-height: 100vh;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  padding: 2rem;
  font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
}

.todo-card {
  max-width: 600px;
  margin: 0 auto;
  background: white;
  border-radius: 20px;
  padding: 2.5rem;
  box-shadow: 0 20px 60px rgba(0, 0, 0, 0.3);
}

.todo-title {
  font-size: 2rem;
  font-weight: 700;
  color: #333;
  margin-bottom: 2rem;
  text-align: center;
}

.add-todo-section {
  display: flex;
  gap: 0.75rem;
  margin-bottom: 2rem;
}

.todo-input {
  flex: 1;
  padding: 0.875rem 1.25rem;
  border: 2px solid #e0e0e0;
  border-radius: 12px;
  font-size: 1rem;
  transition: all 0.3s ease;
  outline: none;
}

.todo-input:focus {
  border-color: #667eea;
  box-shadow: 0 0 0 3px rgba(102, 126, 234, 0.1);
}

.add-button {
  padding: 0.875rem 1.5rem;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  color: white;
  border: none;
  border-radius: 12px;
  font-size: 1rem;
  font-weight: 600;
  cursor: pointer;
  transition: all 0.3s ease;
}

.add-button:hover:not(:disabled) {
  transform: translateY(-2px);
  box-shadow: 0 6px 20px rgba(102, 126, 234, 0.4);
}

.add-button:disabled {
  opacity: 0.6;
  cursor: not-allowed;
}

.loading {
  text-align: center;
  padding: 3rem;
  color: #666;
}

.spinner {
  width: 50px;
  height: 50px;
  margin: 0 auto 1rem;
  border: 4px solid #f3f3f3;
  border-top: 4px solid #667eea;
  border-radius: 50%;
  animation: spin 1s linear infinite;
}

@keyframes spin {
  0% { transform: rotate(0deg); }
  100% { transform: rotate(360deg); }
}

.error-message {
  background: #fee;
  color: #c33;
  padding: 1rem;
  border-radius: 8px;
  margin-bottom: 1rem;
  text-align: center;
}

.todo-list {
  margin-bottom: 1.5rem;
}

.empty-state {
  text-align: center;
  padding: 3rem 1rem;
  color: #999;
}

.empty-state p {
  margin: 0.5rem 0;
  font-size: 1.1rem;
}

.empty-hint {
  font-size: 0.9rem;
}

.todo-item {
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 1rem 1.25rem;
  background: #f8f9fa;
  border-radius: 12px;
  margin-bottom: 0.75rem;
  transition: all 0.3s ease;
}

.todo-item:hover {
  background: #e9ecef;
  transform: translateX(5px);
}

.todo-content {
  flex: 1;
  display: flex;
  flex-direction: column;
  gap: 0.25rem;
}

.todo-text {
  font-size: 1rem;
  color: #333;
  font-weight: 500;
}

.todo-date {
  font-size: 0.75rem;
  color: #999;
}

.delete-button {
  padding: 0.5rem 0.75rem;
  background: #ff6b6b;
  color: white;
  border: none;
  border-radius: 8px;
  font-size: 1.2rem;
  cursor: pointer;
  transition: all 0.3s ease;
}

.delete-button:hover:not(:disabled) {
  background: #ff5252;
  transform: scale(1.1);
}

.delete-button:disabled {
  opacity: 0.6;
  cursor: not-allowed;
}

.api-status {
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 0.5rem;
  padding-top: 1rem;
  border-top: 1px solid #e0e0e0;
  font-size: 0.875rem;
  color: #666;
}

.status-dot {
  width: 10px;
  height: 10px;
  border-radius: 50%;
  background: #ff6b6b;
  transition: background 0.3s ease;
}

.status-dot.connected {
  background: #51cf66;
  box-shadow: 0 0 8px rgba(81, 207, 102, 0.6);
}

/* 動畫 */
.todo-list-enter-active, .todo-list-leave-active {
  transition: all 0.3s ease;
}

.todo-list-enter-from {
  opacity: 0;
  transform: translateX(-30px);
}

.todo-list-leave-to {
  opacity: 0;
  transform: translateX(30px);
}
</style>
