# TODO: Delete this script once you make sure stuff is working fine. This is just a temp reference to qperf and iperf operations.
# guide: https://github.com/linux-rdma/qperf/blob/master/src/help.txt
# Test
qperf --listen_port 33330

#--------- client
# keySize = 23 bytes
# valueSize = 9 (field name + curly braces + equals char) + 100 (actual value) = 109 bytes
# total = 132 bytes
qperf -v --unify_units --listen_port 33330 -ip 33331 --time 5 --msg_size 132 localhost tcp_lat tcp_bw
qperf -v --unify_units --listen_port 33330 -ip 33331 --time 5 --msg_size 132 172.31.39.42 tcp_lat tcp_bw

# Iperf3

#-------- server
iperf3 --server --port 33330 --verbose --json --one-off
iperf3 --server --port 33330 --verbose --json

#-------- client
iperf3 --client localhost --port 33330 --verbose --json --bidir
iperf3 --client localhost --port 33330 --get-server-output --json --bidir --time 5 --length 100
iperf3 --client 172.31.46.57 --port 33330 --get-server-output --json --bidir --time 5 --length 100
iperf3 --client 172.31.46.57 --port 33330 --bidir --time 5 --length 100

iperf3 --client 172.31.39.42 --port 33330 --time 5 --length 1K