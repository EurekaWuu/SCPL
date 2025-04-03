import sys
import os

dm_control_path = '/mnt/lustre/GPU4/home/wuhanpeng/SCPL/src/env/dm_control'
sys.path.append(dm_control_path)

project_root = '/mnt/lustre/GPU4/home/wuhanpeng/SCPL'
sys.path.append(project_root)

from dm_control import suite
import pprint

def get_action_dim(domain, task):
    try:
        env = suite.load(domain, task)
        return env.action_spec().shape[0]
    except Exception as e:
        return f"Error: {str(e)}"

def list_all_tasks():
    all_tasks = {}
    
    try:
        suite_dir = os.path.join(dm_control_path, 'dm_control/suite')
        domain_files = [f[:-3] for f in os.listdir(suite_dir) 
                       if f.endswith('.py') and f != '__init__.py']
        
        print("Available domains:", domain_files)
        
        for domain in domain_files:
            try:
                domain_module = __import__(f'dm_control.suite.{domain}', fromlist=['SUITE'])
                if hasattr(domain_module, 'SUITE'):
                    tasks = list(domain_module.SUITE.keys())
                    tasks_with_dims = {}
                    for task in tasks:
                        action_dim = get_action_dim(domain, task)
                        tasks_with_dims[task] = action_dim
                    all_tasks[domain] = tasks_with_dims
            except Exception as e:
                print(f"Error loading domain {domain}: {e}")
        
    except Exception as e:
        print(f"Error accessing suite directory: {e}")
    
    return all_tasks

def print_tasks():
    print("\n=== DMControl可用任务列表（包含动作维度）===\n")
    
    tasks_dict = list_all_tasks()
    
    for domain, tasks in tasks_dict.items():
        print(f"\n{domain}:")
        print("-" * 40)
        for task, action_dim in tasks.items():
            print(f"  {task:<20} Action Dimensions: {action_dim}")
    
    if tasks_dict:
        total_tasks = sum(len(tasks) for tasks in tasks_dict.values())
        print(f"\n总共有 {len(tasks_dict)} 个domains和 {total_tasks} 个tasks")
        
        dim_groups = {}
        for domain, tasks in tasks_dict.items():
            for task, dim in tasks.items():
                if isinstance(dim, int):
                    if dim not in dim_groups:
                        dim_groups[dim] = []
                    dim_groups[dim].append((domain, task))
        
        print("\n=== 按动作维度分组 ===")
        for dim, tasks in sorted(dim_groups.items()):
            print(f"\n动作维度 {dim}:")
            for domain, task in sorted(tasks):
                print(f"  - {domain:<15} {task}")

if __name__ == "__main__":
    print("Python path:", sys.path)
    print("Looking for suite in:", dm_control_path)
    print_tasks()





'''

python /mnt/lustre/GPU4/home/wuhanpeng/SCPL/src/find_task.py


=== DMControl可用任务列表（包含动作维度）===

Available domains: ['ball_in_cup', 'lqr', 'walker', 'explore', 'quadruped', 'finger', 'humanoid_CMU', 'base', 'pendulum', 'humanoid', 'point_mass', 'lqr_solver', 'hopper', 'stacker', 'fish', 'cheetah', 'manipulator', 'cartpole', 'acrobot', 'swimmer', 'reacher']

ball_in_cup:
----------------------------------------
  catch                Action Dimensions: 2

lqr:
----------------------------------------
  lqr_2_1              Action Dimensions: 1
  lqr_6_2              Action Dimensions: 2

walker:
----------------------------------------
  stand                Action Dimensions: 6
  walk                 Action Dimensions: 6
  run                  Action Dimensions: 6

quadruped:
----------------------------------------
  walk                 Action Dimensions: 12
  run                  Action Dimensions: 12
  escape               Action Dimensions: 12
  fetch                Action Dimensions: 12

finger:
----------------------------------------
  spin                 Action Dimensions: 2
  turn_easy            Action Dimensions: 2
  turn_hard            Action Dimensions: 2

humanoid_CMU:
----------------------------------------
  stand                Action Dimensions: 56
  run                  Action Dimensions: 56

pendulum:
----------------------------------------
  swingup              Action Dimensions: 1

humanoid:
----------------------------------------
  stand                Action Dimensions: 21
  walk                 Action Dimensions: 21
  run                  Action Dimensions: 21
  run_pure_state       Action Dimensions: 21

point_mass:
----------------------------------------
  easy                 Action Dimensions: 2
  hard                 Action Dimensions: 2

hopper:
----------------------------------------
  stand                Action Dimensions: 4
  hop                  Action Dimensions: 4

stacker:
----------------------------------------
  stack_2              Action Dimensions: 5
  stack_4              Action Dimensions: 5

fish:
----------------------------------------
  upright              Action Dimensions: 5
  swim                 Action Dimensions: 5

cheetah:
----------------------------------------
  run                  Action Dimensions: 6

manipulator:
----------------------------------------
  bring_ball           Action Dimensions: 5
  bring_peg            Action Dimensions: 5
  insert_ball          Action Dimensions: 5
  insert_peg           Action Dimensions: 5

cartpole:
----------------------------------------
  balance              Action Dimensions: 1
  balance_sparse       Action Dimensions: 1
  swingup              Action Dimensions: 1
  swingup_sparse       Action Dimensions: 1
  two_poles            Action Dimensions: 1
  three_poles          Action Dimensions: 1

acrobot:
----------------------------------------
  swingup              Action Dimensions: 1
  swingup_sparse       Action Dimensions: 1

swimmer:
----------------------------------------
  swimmer6             Action Dimensions: 5
  swimmer15            Action Dimensions: 14

reacher:
----------------------------------------
  easy                 Action Dimensions: 2
  hard                 Action Dimensions: 2

总共有 18 个domains和 45 个tasks

=== 按动作维度分组 ===

动作维度 1:
  - acrobot         swingup
  - acrobot         swingup_sparse
  - cartpole        balance
  - cartpole        balance_sparse
  - cartpole        swingup
  - cartpole        swingup_sparse
  - cartpole        three_poles
  - cartpole        two_poles
  - lqr             lqr_2_1
  - pendulum        swingup

动作维度 2:
  - ball_in_cup     catch
  - finger          spin
  - finger          turn_easy
  - finger          turn_hard
  - lqr             lqr_6_2
  - point_mass      easy
  - point_mass      hard
  - reacher         easy
  - reacher         hard

动作维度 4:
  - hopper          hop
  - hopper          stand

动作维度 5:
  - fish            swim
  - fish            upright
  - manipulator     bring_ball
  - manipulator     bring_peg
  - manipulator     insert_ball
  - manipulator     insert_peg
  - stacker         stack_2
  - stacker         stack_4
  - swimmer         swimmer6

动作维度 6:
  - cheetah         run
  - walker          run
  - walker          stand
  - walker          walk

动作维度 12:
  - quadruped       escape
  - quadruped       fetch
  - quadruped       run
  - quadruped       walk

动作维度 14:
  - swimmer         swimmer15

动作维度 21:
  - humanoid        run
  - humanoid        run_pure_state
  - humanoid        stand
  - humanoid        walk

动作维度 56:
  - humanoid_CMU    run
  - humanoid_CMU    stand

'''