# Info

This is the directory where all the results of the load tests are stored. There are two subdirectories:
- [logs](logs): This directory contains the logs from workers if [`workers_GROUP_project_log_level`](../group_vars/workers.yaml)
  is set to `DEBUG`.
- [metrics](metrics): This directory contains the metrics collected from the load tests. The metrics are stored in
  subdirectories named after the workload playbook that was run. For example, if you run the 
  [`W1_run_readWriteProp_SSRBE.yaml`](../W1_run_readWriteProp_SSRBE.yaml) playbook, the results will be stored in the
  [metrics/W4T1 W4T2 W4T3 W4T4 W4T5]() directory.
- [vars](vars): This directory contains the variables used in the load tests. All ansible variables (including
  user defined variables) are dumped in this directory for debug/verification purposes.

There are also some other scripts in this directory.
- R scripts: These scripts are used to replot the metrics graphs based on the collected raw data. The idea is to
  execute these scripts on the controller machine to replot the graphs for improved visualization (for example 
  with better width/height and resolution settings).
```
# example replot of all metrics
./redo_all.R "metrics/S1 S2"
```

