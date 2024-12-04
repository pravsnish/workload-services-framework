>
> **Note: The Workload Services Framework is a benchmarking framework and is not intended to be used for the deployment of workloads in production environments. It is recommended that users consider any adjustments which may be necessary for the deployment of these workloads in a production environment including those necessary for implementing software best practices for workload scalability and security.**
>
### Introduction

ResNet50 is a variant of ResNet model which has 48 Convolution layers along with 1 MaxPool and 1 Average Pool layer. It has 3.8 x 10^9 Floating points operations. It is a widely used ResNet model and we have explored ResNet50 architecture in depth.

- **DATASET**：https://image-net.org/data/ILSVRC/2012/
- **MODEL_WEIGHTS**: https://download.pytorch.org/models/resnet50-0676ba61.pth
- **BENCHMARK_SCRIPT**: https://github.com/IntelAI/models/models/models/image_recognition/pytorch/common/main.py

### Parameters

The Resnet50 workload provides test cases with the following configuration parameters:
- **FUNCTION**: Specify which workload should run: `inference`, `training`.
- **MODE**: Specify the running mode: `latency`, `throughput` or `accuracy`.
  * `latency`: For performance measurement only. 4 cores per test instance, KPI counts on all test instances result together.
  * `throughput`: For performance measurement only. 1 socket per test instance, KPI counts on all test instances result together.
  * `accuracy`: For accuracy measurement only.
- **CASE_TYPE**: This is optional parameter, specify `gated` or `pkm`.  
  - `gated` represents running the workload with reduced parameters: `STEPS=10`, `BATCH_SIZE=1` and `CORES_PER_INSTANCE=$CORES_PER_SOCKET`.
  - `pkm` represents running the workload with the common parameters.
- **PRECISION**: Specify the model precision: `avx_int8`, `avx_fp32`, `amx_int8`, `amx_bfloat16`, or `amx_bfloat32`. For Training case `avx_fp32`, `amx_bfloat16` precision are supported.
- **DATA_TYPE**: Specify the input/output data type: `dummy` or `real`. 
- **BATCH_SIZE**: Specify the size of batch: `--batch_size=1` or empty to set the default values.
- **CORES_PER_INSTANCE**: Define the number of cores in one instance. Default as `cores per numa node`.
- **STEPS**: Specify the inference steps value: default as `STEPS=30`. This parameter is **neither** tunable for **training** nor **accuracy** cases. (Note: make sure the `STEPS` large enough when the `BATCH_SIZE` is small, or may meet `division by zero` error.)
- **WEIGHT_SHARING**: Add the parameter: `--weight_sharing` if want to use weight sharing. Precision `avx_fp32` and `amx_bfloat32` are not supported weight sharing.
- **VERBOSE**: Add the parameter: `--VERBOSE` if want to use verbose.
- **DISTRIBUTED**: **Only** available for training, to specify if enable TorchCCL to do distributed training on one or multiple nodes. *(nodes info should be specified in `hostfile`)*
- **CCL_WORKER**: **Only** available for training, to specify the number of logical cores used for each training process to communicate with others.
- **CUSTOMER_ENV**: Users can customize the environment variables that need to be set, which can be used in conjunction with `ctest --set "CUSTOMER_ENV=<ENV_NAME_1>=<VALUE_1> <ENV_NAME_2>=<VALUE_2> <ENV_NAME_3>=<VALUE_3>"`
- **TORCH_TYPE**: Specify the torch optimization method, you can choose of of `COMPILE-INDUCTOR`, `IPEX`(default).

```
  Note: The KPI depends on the CPU SKU, core count, cache size and memory capacity/performance, etc.
```

### Test Case

The test case name is a combination of `<WORKLOAD>_<FUNCTION>_<MODE>_<PRECISION>_<CASE_TYPE>` (CASE_TYPE is optional). Use the following commands to list and run test cases through service framework automation pipeline:
```
cd build
cmake ..
cd workload/ResNet50-Pytorch-Xeon-Public
./ctest.sh -N (list all designed test cases)

or
./ctest.sh -V (run all test cases) 
```

### System Requirements

Requires ~1TB of disk space available during runtime. See [AI Setup](../../doc/user-guide/preparing-infrastructure/setup-ai.md) for more system setup instructions.

### Docker Image

The ResNet50 workload provides 4 docker images:
- `resnet50-pytorch-inference-dataset-24.04` - inference dataset.
- `resnet50-pytorch-model-24.04` - fp32, bfloat16, int8 model.
- `resnet50-pytorch-benchmark-24.04` - Intel public benchmark script.
- `resnet50-pytorch-intel-public-inference-24.04` - inference.


To run the workload, provide the set of environment variables described in the [Test Case](#Test-Case) section as follows:

```
mkdir -p logs-latency-avx-fp32-inference-dummy
id=$(docker run --rm --detach --privileged -e WORKLOAD=resnet50_pytorch_xeon_public -e PLATFORM=SPR -e MODE=throughput -e TOPOLOGY=resnet50 -e FUNCTION=inference -e PRECISION=avx_fp32 -e BATCH_SIZE=64 -e STEPS=100 -e DATA_TYPE=dummy -e CORES_PER_INSTANCE=56 -e WEIGHT_SHARING=False -e CASE_TYPE= -e VERBOSE=False)
docker exec $id cat /export-logs | tar xf - -C logs-latency-avx-fp32-inference-dummy
docker rm -f $id
```

### KPI

Run the [kpi.sh](kpi.sh) script to parse the KPIs from the validation logs. The script takes the following command line argument:

```
Usage: make_kpi_resnet50
```

The ResNet50 workload produces a single KPI:
- **Throughput**: The model throughput value. 
- **Latency**: The model latency value.
- **Accuracy**: The model accuracy value, a percentage.

KPI output example:
```
latency_amx_bfloat16 (ms): 5.50
throughput_amx_bfloat16 (samples/sec): 5189.72
accuracy_amx_bfloat16 (%): 76.15

```

### Performance BKM
- Minimum system setup: SPR or newer required for AMX tests
- Recommended system setup: 512 GB RAM
- Workload parameter tuning guidelines:
  - Batch Size (BS) and Cores per Instance (CI) - key parameters of the workload​
  - Full sweep for various BS and CI
  - For performance comparison get max throughput for each BS and compare

Performance report results summary for throughput tests (maximum samples per second):
| precision    | BS  | CPI | CPU | value |
| ------------ | ---:| ---:| --- | -----:|
| amx_int8     | 64  |  14 | SPR | 13460 |
| amx_bfloat16 | 32  |  14 | SPR | 7462  |
| avx_int8     | 32  |  7  | SPR | 5514  |
| avx_fp32     | 128 |  4  | SPR | 1451  |

### Index Info
- Name: `ResNet50-PyTorch-Xeon-Public`
- Category: `ML/DL/AI`
- Platform: `SPR`, `ICX`, `EMR`
- Keywords: `AMX`, `TMUL`, `CPU`