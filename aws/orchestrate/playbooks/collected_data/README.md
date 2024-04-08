# Info

This is the directory where all the results of the load tests are stored. There are two subdirectories:
- [logs](logs): This directory contains the logs from workers if [`workers_GROUP_project_log_level`](../group_vars/workers.yaml)
  is set to `DEBUG`.
- [metrics](metrics): This directory contains the metrics collected from the load tests. The metrics are stored in
  subdirectories named after the workload playbook that was run. For example, if you run the 
  [`W1_run_workload_rw_1k_SSRBEC.yaml`](../W1_run_workload_rw_1k_SSRBEC.yaml) playbook, the results will be stored in the
  [metrics/W1]() directory.
- [vars](vars): This directory contains the variables used in the load tests. All ansible variables (including
  user defined variables) are dumped in this directory for debug/verification purposes.

## Replotting the metrics on the Controller

We have created the [replay_on_controller.R](../remote_data_scripts/replay_on_controller.R) script that can be
used to generate the plots on the controller based on the raw results obtained from load tests which are fetched
under [metrics](metrics) directory.

A note on [metrics/samples](metrics/samples): This directory contains the sample metrics collected from the load tests.
- [metrics/samples/EX](metrics/samples/EX): This directory contains sample metrics from earlier tests that we have
done in the past. Useful for testing the entire R workflow from metrics collection to plotting.
- [metrics/samples/W7](metrics/samples/W7): This directory contains sample metrics from the workload playbook
[`W7_run_workload_rw_10k_RBB.yaml`](../W7_run_workload_rw_10k_RBB.yaml). Useful for testing the R workflow for
plotting the metrics from the test raw data.
