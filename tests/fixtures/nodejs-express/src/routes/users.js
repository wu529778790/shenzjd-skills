const express = require('express');
const router = express.Router();

/**
 * @route GET /api/users
 * @desc 获取用户列表
 * @access Public
 */
router.get('/', async (req, res) => {
  try {
    // TODO: 从数据库获取用户
    res.json({ users: [] });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

/**
 * @route GET /api/users/:id
 * @desc 获取单个用户
 * @access Public
 */
router.get('/:id', async (req, res) => {
  try {
    const { id } = req.params;
    // TODO: 从数据库获取用户
    res.json({ user: { id, name: 'Test User' } });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

/**
 * @route POST /api/users
 * @desc 创建用户
 * @access Private
 */
router.post('/', async (req, res) => {
  try {
    const { name, email } = req.body;
    // TODO: 创建用户
    res.status(201).json({ user: { id: 1, name, email } });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

/**
 * @route PUT /api/users/:id
 * @desc 更新用户
 * @access Private
 */
router.put('/:id', async (req, res) => {
  try {
    const { id } = req.params;
    const { name, email } = req.body;
    // TODO: 更新用户
    res.json({ user: { id, name, email } });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

/**
 * @route DELETE /api/users/:id
 * @desc 删除用户
 * @access Private
 */
router.delete('/:id', async (req, res) => {
  try {
    const { id } = req.params;
    // TODO: 删除用户
    res.json({ message: 'User deleted' });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

module.exports = router;
