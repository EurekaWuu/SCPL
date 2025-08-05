# SCPL: 视觉强化学习中的状态条件预测学习

## 项目简介

SCPL (State-Conditional Predictive Learning) 在具有视觉干扰的DMControl环境中训练智能体，通过归因机制和状态条件预测学习提高智能体在不同视觉条件下的泛化能力。

## 特点

- **SCPL算法**: 基于SAC的新型视觉强化学习算法，集成归因机制和转移模型
- **视觉泛化**: 支持颜色变化和视频背景干扰的泛化测试
- **多种基线**: 实现了SAC、RAD、CURL、PAD、SODA、DRQ、SVEA等多种算法
- **DMControl环境**: 基于DeepMind Control Suite的连续控制任务
- **归因分析**: 梯度归因识别重要的视觉特征

## 支持的算法

| 算法 | 描述 | 论文 |
|------|------|------|
| **SCPL** | 状态条件预测学习 (本项目核心算法) | - |
| SAC | Soft Actor-Critic | [论文链接](https://arxiv.org/abs/1801.01290) |
| RAD | Random Augmentation for Data | [论文链接](https://arxiv.org/abs/2004.14990) |
| CURL | Contrastive Unsupervised RL | [论文链接](https://arxiv.org/abs/2004.04136) |
| PAD | Policy Adaptation during Deployment | [论文链接](https://arxiv.org/abs/2007.04309) |
| DRQ | Data-regularized Q | [论文链接](https://arxiv.org/abs/2004.13649) |
| SODA | Soft Data Augmentation | [论文链接](https://arxiv.org/abs/2011.13389) |
| SVEA | State-Wise Visual Enhancement | [论文链接](https://arxiv.org/abs/2102.13434) |

## 环境要求

### 系统依赖
- Python 3.7+
- CUDA 11.0+
- MuJoCo 2.1+

### Python依赖
```bash
pip install -r requirements.txt
```

主要依赖包括：
- PyTorch 2.0+
- OpenCV
- NumPy
- Gym
- DMControl
- Kornia (数据增强)

## 开始

### 1. 环境设置

```bash
# 克隆仓库
git clone <repository-url>
cd SCPL

# 安装依赖
pip install -r requirements.txt

# 设置DMControl环境
cd src/env/dm_control
pip install -e .
cd ../dmc2gym  
pip install -e .
```

### 2. 训练智能体

#### 使用SCPL算法训练
```bash
python src/train.py \
    --algorithm scpl \
    --domain_name walker \
    --task_name walk \
    --seed 0 \
    --train_steps 500000
```

#### 使用其他算法训练
```bash
# SAC基线
bash scripts/sac.sh

# RAD算法
bash scripts/rad.sh

# CURL算法  
bash scripts/curl.sh
```

### 3. 评估智能体

```bash
python src/eval.py \
    --algorithm scpl \
    --domain_name walker \
    --task_name walk \
    --eval_mode video_hard \
    --seed 0
```

## 项目结构

```
SCPL/
├── src/
│   ├── algorithms/          # 算法实现
│   │   ├── SCPL.py         # SCPL核心算法
│   │   ├── sac.py          # SAC基线
│   │   ├── rad.py          # RAD算法
│   │   └── ...             # 其他算法
│   ├── env/                # 环境相关
│   │   ├── wrappers.py     # 环境包装器
│   │   ├── distracting_control/  # 干扰环境
│   │   └── dm_control/     # DMControl
│   ├── train.py            # 训练脚本
│   ├── eval.py             # 评估脚本
│   └── arguments.py        # 参数配置
├── scripts/                # 训练脚本
├── figures/                # 结果图表
└── requirements.txt        # 依赖列表
```

## 实验环境

### 训练环境
- **Domain**: walker, cartpole, cheetah, finger, reacher, ball_in_cup
- **Task**: walk, balance, run, spin, reach, catch

### 测试模式
- `train`: 训练环境（无干扰）
- `color_easy`: 简单颜色变化
- `color_hard`: 复杂颜色变化  
- `video_easy`: 简单视频背景（10个视频）
- `video_hard`: 复杂视频背景（100个视频）
- `distracting_cs`: 动态场景干扰

## SCPL算法原理


1. **归因**: 使用梯度归因识别对决策重要的视觉特征
2. **遮挡一致性**: 遮挡重要特征后Q值保持一致
3. **状态转移预测**: 学习状态转移模型预测下一状态
4. **数据增强**: 随机覆盖等方法增强数据多样性

### 核心损失函数
```python
# Critic损失 + 遮挡一致性
critic_loss = mse_loss(Q, target_Q) + mse_loss(Q, masked_Q)

# Actor损失 + KL散度正则化
actor_loss = policy_loss + kl_divergence(π_aug, π_orig)

# 转移模型损失
transition_loss = prediction_loss + reward_loss
```

## 实验

主要指标：

- **颜色泛化**: 在不同颜色背景下的性能
- **视频泛化**: 在动态视频背景下的性能  
- **样本效率**: 达到目标性能所需的样本数量


## 主要参数

### 训练参数
- `--train_steps`: 训练步数 (默认: 500k)
- `--batch_size`: 批大小 (默认: 128)
- `--init_steps`: 随机探索步数 (默认: 1000)
- `--eval_freq`: 评估频率 (默认: 10k)

### 算法参数
- `--actor_lr`: Actor学习率 (默认: 1e-3)
- `--critic_lr`: Critic学习率 (默认: 1e-3)
- `--projection_dim`: 投影维度 (默认: 100)
- `--aux_update_freq`: 辅助任务更新频率 (默认: 2)

### 环境参数
- `--domain_name`: 任务域 (如: walker)
- `--task_name`: 具体任务 (如: walk)
- `--eval_mode`: 评估模式 (如: video_hard)
- `--image_size`: 图像尺寸 (默认: 84)