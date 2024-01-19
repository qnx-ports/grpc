# Testing gRPC on QNX

1. Compile and install gRPC for desired architecture following the `README.md` under `qnx/`

2. Move gRPC library and the test binary to the target:
    ```
    # You can use other tools like sshpass to simplify the process
    find [PROJECT_ROOT]/qnx/build/[ARCH]/build/ -name "lib*.so*" | xargs -I{} scp {} root@<target-ip-address>:/usr/lib

    scp -r [QNX_TARGET]/[ARCH]/usr/bin/grpc_tests root@<target-ip-address>:[your_test_path]
    ```
3. `ssh root@<target-ip-address>:/usr/lib`
4. Change the default localhosts: `scp [PROJECT_ROOT]/qnx/test/hosts root@<target-ip-address>:/etc/`

5. Run the tests
    ```
    ntpdate -sb 0.pool.ntp.org 1.pool.ntp.org 
    export TMPDIR=/var  
    python3 -m ensurepip --root /  
    python3 -m pip install six
    mkdir -p /tmp/ #DO NOT OMIT THIS
    cd [your_test_path]/grpc_tests
    python3 ./tools/run_tests/run_tests.py -l c++
    ```

---
Tests results are provided on the wiki: https://wikis.rim.net/display/OSG/QNX+Open+Source+Group
