#!/bin/bash

export PYTORCH_CUDA_ALLOC_CONF=max_split_size_mb:128


python3 -c "
import torch
if torch.cuda.is_available():
    torch.cuda.empty_cache()
    print('已清理GPU缓存')
"

python3 -c "
import torch
print(f\"CUDA可见设备数量: {torch.cuda.device_count()}\")
print(f\"当前设备: {torch.cuda.current_device()}\")
print(f\"设备名称: {torch.cuda.get_device_name(0)}\")
print(f\"设备内存: {torch.cuda.get_device_properties(0).total_memory / 1e9} GB\")
"

timestamp=$(date +%Y%m%d_%H%M%S)
algorithms=("sgsac")


seeds=(1)


domains=("walker" "walker" "cartpole" "ball_in_cup" "finger")
tasks=("stand" "walk" "swingup" "catch" "spin")


eval_modes=("color_hard" "video_easy" "video_hard")


project_dir="/mnt/lustre/GPU4/home/wuhanpeng/SCPL"


mkdir -p "${project_dir}/logs"

for seed in "${seeds[@]}"; do
    for eval_mode in "${eval_modes[@]}"; do
        for i in "${!tasks[@]}"; do
            domain_name="${domains[i]}"
            task_name="${tasks[i]}"
            
            for algo in "${algorithms[@]}"; do
                log_dir="${project_dir}/logs/${algo}/${domain_name}_${task_name}_${seed}_${timestamp}"
                mkdir -p "${log_dir}"
                
                echo "=== 运行实验: 算法=${algo}, 任务=${domain_name}_${task_name}, 评估模式=${eval_mode}, 种子=${seed} ==="
                
                CUDA_VISIBLE_DEVICES=0 python ${project_dir}/src/my_train_all.py \
                    --domain_name ${domain_name} \
                    --task_name ${task_name} \
                    --algorithm ${algo} \
                    --seed ${seed} \
                    --eval_mode ${eval_mode} \
                    --workdir "${log_dir}" \
                    --batch_size 32 \
                    2>&1 | tee "${log_dir}/train_${eval_mode}.log"
                
                if [ $? -ne 0 ]; then
                    echo "错误: 算法=${algo}, 任务=${domain_name}_${task_name}, 种子=${seed}. 退出..."
                    exit 1
                fi
                
                echo "=== 完成: 算法=${algo}, 任务=${domain_name}_${task_name}, 评估模式=${eval_mode}, 种子=${seed} ==="
                echo "====================================================================="
            done
        done
    done
done

echo "所有实验完成!"


#   CUDA_VISIBLE_DEVICES=1 ./run_experiments_9.sh
