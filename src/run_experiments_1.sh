#!/bin/bash

# export PYTORCH_CUDA_ALLOC_CONF=max_split_size_mb:128

# 检查并使用外部传入的CUDA_VISIBLE_DEVICES，如果未设置则默认为0
if [ -z "${CUDA_VISIBLE_DEVICES}" ]; then
    export CUDA_VISIBLE_DEVICES=0
    echo "未检测到CUDA_VISIBLE_DEVICES设置，默认使用GPU 0"
else
    echo "检测到CUDA_VISIBLE_DEVICES=${CUDA_VISIBLE_DEVICES}"
fi

python3 -c "
import torch
if torch.cuda.is_available():
    torch.cuda.empty_cache()
    print('已清理GPU缓存')
"

python3 -c "
import torch
import os
print(f\"CUDA_VISIBLE_DEVICES环境变量: {os.environ.get('CUDA_VISIBLE_DEVICES', '未设置')}\")
print(f\"CUDA可见设备数量: {torch.cuda.device_count()}\")
print(f\"当前设备索引: {torch.cuda.current_device()}\")
print(f\"当前设备名称: {torch.cuda.get_device_name(torch.cuda.current_device())}\")
print(f\"当前设备内存: {torch.cuda.get_device_properties(torch.cuda.current_device()).total_memory / 1e9} GB\")
"

timestamp=$(date +%Y%m%d_%H%M%S)
algorithms=("soda")


# 定义未完成任务列表
# 格式: 域名 任务名 种子 评估模式
declare -a domains
declare -a tasks
declare -a seeds
declare -a eval_modes


# ball_in_cup_catch 任务
# video_easy: 1(重新完成), 6, 8, 66, 88(新增)
domains+=("ball_in_cup"); tasks+=("catch"); seeds+=(1); eval_modes+=("video_easy")
domains+=("ball_in_cup"); tasks+=("catch"); seeds+=(6); eval_modes+=("video_easy")
domains+=("ball_in_cup"); tasks+=("catch"); seeds+=(8); eval_modes+=("video_easy")
domains+=("ball_in_cup"); tasks+=("catch"); seeds+=(66); eval_modes+=("video_easy")
domains+=("ball_in_cup"); tasks+=("catch"); seeds+=(88); eval_modes+=("video_easy")
# video_hard: 全部
domains+=("ball_in_cup"); tasks+=("catch"); seeds+=(1); eval_modes+=("video_hard")
domains+=("ball_in_cup"); tasks+=("catch"); seeds+=(6); eval_modes+=("video_hard")
domains+=("ball_in_cup"); tasks+=("catch"); seeds+=(8); eval_modes+=("video_hard")
domains+=("ball_in_cup"); tasks+=("catch"); seeds+=(66); eval_modes+=("video_hard")
domains+=("ball_in_cup"); tasks+=("catch"); seeds+=(88); eval_modes+=("video_hard")

# cartpole_swingup 任务
# video_easy: 66, 6, 88, 8(重新完成)
domains+=("cartpole"); tasks+=("swingup"); seeds+=(66); eval_modes+=("video_easy")
domains+=("cartpole"); tasks+=("swingup"); seeds+=(6); eval_modes+=("video_easy")
domains+=("cartpole"); tasks+=("swingup"); seeds+=(88); eval_modes+=("video_easy")
domains+=("cartpole"); tasks+=("swingup"); seeds+=(8); eval_modes+=("video_easy")
# video_hard: 全部
domains+=("cartpole"); tasks+=("swingup"); seeds+=(1); eval_modes+=("video_hard")
domains+=("cartpole"); tasks+=("swingup"); seeds+=(6); eval_modes+=("video_hard")
domains+=("cartpole"); tasks+=("swingup"); seeds+=(8); eval_modes+=("video_hard")
domains+=("cartpole"); tasks+=("swingup"); seeds+=(66); eval_modes+=("video_hard")
domains+=("cartpole"); tasks+=("swingup"); seeds+=(88); eval_modes+=("video_hard")

# finger_spin 任务
# color_hard: 1(重新完成)
domains+=("finger"); tasks+=("spin"); seeds+=(1); eval_modes+=("color_hard")
# video_easy: 全部
domains+=("finger"); tasks+=("spin"); seeds+=(1); eval_modes+=("video_easy")
domains+=("finger"); tasks+=("spin"); seeds+=(6); eval_modes+=("video_easy")
domains+=("finger"); tasks+=("spin"); seeds+=(8); eval_modes+=("video_easy")
domains+=("finger"); tasks+=("spin"); seeds+=(66); eval_modes+=("video_easy")
domains+=("finger"); tasks+=("spin"); seeds+=(88); eval_modes+=("video_easy")
# video_hard: 全部
domains+=("finger"); tasks+=("spin"); seeds+=(1); eval_modes+=("video_hard")
domains+=("finger"); tasks+=("spin"); seeds+=(6); eval_modes+=("video_hard")
domains+=("finger"); tasks+=("spin"); seeds+=(8); eval_modes+=("video_hard")
domains+=("finger"); tasks+=("spin"); seeds+=(66); eval_modes+=("video_hard")
domains+=("finger"); tasks+=("spin"); seeds+=(88); eval_modes+=("video_hard")

# walker_stand 任务
# video_hard: 全部
domains+=("walker"); tasks+=("stand"); seeds+=(1); eval_modes+=("video_hard")
domains+=("walker"); tasks+=("stand"); seeds+=(6); eval_modes+=("video_hard")
domains+=("walker"); tasks+=("stand"); seeds+=(8); eval_modes+=("video_hard")
domains+=("walker"); tasks+=("stand"); seeds+=(66); eval_modes+=("video_hard")
domains+=("walker"); tasks+=("stand"); seeds+=(88); eval_modes+=("video_hard")

# walker_walk 任务
# video_hard: 全部
domains+=("walker"); tasks+=("walk"); seeds+=(1); eval_modes+=("video_hard")
domains+=("walker"); tasks+=("walk"); seeds+=(6); eval_modes+=("video_hard")
domains+=("walker"); tasks+=("walk"); seeds+=(8); eval_modes+=("video_hard")
domains+=("walker"); tasks+=("walk"); seeds+=(66); eval_modes+=("video_hard")
domains+=("walker"); tasks+=("walk"); seeds+=(88); eval_modes+=("video_hard")



project_dir="/mnt/lustre/GPU4/home/wuhanpeng/SCPL"


mkdir -p "${project_dir}/logs"

for i in "${!domains[@]}"; do
    domain_name="${domains[i]}"
    task_name="${tasks[i]}"  
    seed="${seeds[i]}"
    eval_mode="${eval_modes[i]}"
    
    algo="${algorithms[0]}"  # 使用数组中定义的算法
    
    log_dir="${project_dir}/logs/${algo}/${domain_name}_${task_name}_${seed}_${timestamp}"
    mkdir -p "${log_dir}"
    
    echo "=== 运行实验: 算法=${algo}, 任务=${domain_name}_${task_name}, 评估模式=${eval_mode}, 种子=${seed} ==="
    
    # 显示训练前GPU使用情况
    echo "训练前GPU使用情况:"
    nvidia-smi
    
    # 显示将要使用的GPU
    echo "即将在GPU ${CUDA_VISIBLE_DEVICES} 上运行训练"
    
    # 不再重新设置CUDA_VISIBLE_DEVICES，使用外部传入的或默认值
    python ${project_dir}/src/my_train_all.py \
        --domain_name ${domain_name} \
        --task_name ${task_name} \
        --algorithm ${algo} \
        --seed ${seed} \
        --eval_mode ${eval_mode} \
        --workdir "${log_dir}" \
        --batch_size 128 \
        2>&1 | tee "${log_dir}/train_${eval_mode}.log"
    
    train_exit_code=$?
    
    # 显示训练后GPU使用情况
    echo "训练后GPU使用情况:"
    nvidia-smi
    
    if [ ${train_exit_code} -ne 0 ]; then
        echo "错误: 算法=${algo}, 任务=${domain_name}_${task_name}, 种子=${seed}. 退出..."
        exit 1
    fi
    
    echo "=== 完成: 算法=${algo}, 任务=${domain_name}_${task_name}, 评估模式=${eval_mode}, 种子=${seed} ==="
    echo "====================================================================="
done

echo "所有实验完成!"


#   CUDA_VISIBLE_DEVICES=0 ./run_experiments_21.sh
