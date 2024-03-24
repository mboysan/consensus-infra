# Info

This is the directory where all the results of the load tests are stored. There are two subdirectories:
- [logs](logs): This directory contains the logs from workers if [`workers_GROUP_project_log_level`](../group_vars/workers.yaml)
  is set to `DEBUG`.
- [metrics](metrics): This directory contains the metrics collected from the load tests. The metrics are stored in
  subdirectories named after the workload playbook that was run. For example, if you run the 
  [`W1_run_workload_rw_1k_SSRBE.yaml`](../W1_run_workload_rw_1k_SSRBE.yaml) playbook, the results will be stored in the
  [metrics/W1]() directory.
- [vars](vars): This directory contains the variables used in the load tests. All ansible variables (including
  user defined variables) are dumped in this directory for debug/verification purposes.
