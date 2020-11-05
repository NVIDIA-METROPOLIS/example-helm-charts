
# Deepstream Helm chart
This helm chart is a base line deepstream implementation with following key config parameters

* Sink type 1 
* Primay gie  
  * resnet10.caffemodel 
* secondary gies
  * resnet18.caffemodel_b16 - config_infer_secondary_vehicletypes.txt
  * resnet18.caffemodel_b16 - config_infer_secondary_carmake.txt

# Install and Run deepstream Helm chart

1. Prepare the values file with following content as in example bellow

**command.values.yaml**

```yaml
#
# ------ APPLICATION SECTION ------------
#
nvidia:
  version: 1
  nodes:
  - name: "yournodename"
    gpus:
    - id: 0
      streams:
      - url: "rtsp://<ipaddress>:<port>/yourstream1.mp4"
        resolution: "1920 x 1080"
        framerate: 30
        encoding: "H264"

      - url:  "rtsp://<ipaddress>:<port>/yourstream2.mp4"
        resolution: "1920 x 1080"
        framerate: 30
        encoding: "H264"

    - id: 1
      streams:
      - url: "rtsp://<ipaddress>:<port>/yourstream3.mp4"
        resolution: "1920 x 1080"
        framerate: 30
        encoding: "H264"

    resources:
      requests:
        cpu: "100m"
        memory: "2Gi"

global:
  nvidia:
    version: 1
    docker:
      imagePullSecret: imagepullsecret
# For Non-EGX deployment only: Please set password to your NGC API KEY
      registry: "nvcr.io"
      username: "$oauthtoken"
      password: ""

```

2. Run the following helm install command
```
helm fetch https://helm.ngc.nvidia.com/isv-nvidia-metropolis/charts/nvidia-deepstream-public-5.0.0.tgz --username='$oauthtoken' --password=$NGC_API_KEYS

helm  helm install nvidia-deepstream-public-5.0.0.tgz -f command.values.yaml

```


3. Check if the application is running
* the application when deployed will creates own namespace
```
  Check Name Space

kubectl get namespaces
NAME                                      STATUS   AGE
default                                   Active   237d
gpu-operator-resources                    Active   5d22h
kube-node-lease                           Active   237d
kube-public                               Active   237d
kube-system                               Active   237d
kubernetes-dashboard                      Active   237d
local-path-storage                        Active   237d
nvidia-deepstream-public-mvp-isv-p1-011   Active   15h    <--------------- 
```
Check POD is running

```
 kubectl get pods -n nvidia-deepstream-public-mvp-isv-p1-011
NAME                          READY   STATUS    RESTARTS   AGE
deepstream-644d99b4dc-gmndv   2/2     Running   26         15h

```

Check logs for deepstream container

```
 kubectl logs -n nvidia-deepstream-public-mvp-isv-p1-011 deepstream-644d99b4dc-gmndv deepstream-0 | grep PERF
**PERF:  FPS 0 (Avg)    FPS 1 (Avg)
**PERF:  0.00 (0.00)    0.00 (0.00)
**PERF:  0.00 (0.00)    0.00 (0.00)
**PERF:  14.89 (14.68)  14.95 (14.90)
**PERF:  15.22 (14.95)  15.18 (14.95)
**PERF:  14.84 (14.97)  14.80 (14.90)
**PERF:  15.03 (14.98)  15.08 (14.98)
**PERF:  14.95 (14.94)  14.95 (14.94)

```

If you see the PERF outputs that indicates the deepstream container is running


# Configuring Deepstream

The default configuration is implemented in the chart level values file, in YAML format, describing each section of the standard deepstream config.

## Structure and usage

Refer to https://github.com/NVIDIA-METROPOLIS/sample-helm-chart for standard template layout structures and usage.

```yaml
deepstream:
   configs:
	<deepstream config section>: |-
		<data content>


pods:
- name: deepstream
  replicas: 1
  containers:

...

nvidia:
  version: 1
  nodes:
  - name: "sc-metro-03"
    gpus:
    - id: 0
      streams:
	  - url: "rtsp://<ipaddress>:<port>/yourstream.mp4"
	  
...

global:
  nvidia:
    version: 1
    docker:
      imagePullSecret: imagepullsecret
# For Non-EGX deployment only: Please set password to your NGC API KEY
      registry: "nvcr.io"
      username: "$oauthtoken"
	  password: ""
	  
...

```

The values in the deepstream config sections can be overridden at the helm commandline using a command level values config file. Command level values typically should contain nvidia and global sections and necessay deepstream config overrides

example:
```
helm install nvidia-deepstream-public -f command.values.yaml
```

example commandline values file with  deepstream config values override
```yaml

deepstream:
	configs:
      application: |-
        enable-perf-measurement=1
        perf-measurement-interval-sec=15

nvidia:
  version: 1
  nodes:
  - name: "sc-metro-03"
    gpus:
    - id: 0
      streams:
	  - url: "rtsp://<ipaddress>:<port>/yourstream.mp4"
	  
...

global:
  nvidia:
    version: 1
    docker:
      imagePullSecret: imagepullsecret
# For Non-EGX deployment only: Please set password to your NGC API KEY
      registry: "nvcr.io"
      username: "$oauthtoken"
	  password: ""
	  
...

```
## Adding features with this deepstrem helm chart
New features can be be built by inheriting the base line helm chart and overriding the necessary parameters to implement any use case scenario. 

You may build a wrapper helm chart and override the necessary config sections.

## GPU scheduling

By default the chart is configured to use K8 native gpu scheduling determined by the following configuration entry under the "pods" section.

***Refer to https://github.com/NVIDIA-METROPOLIS/sample-helm-chart for configuring gpu scheduling options.***

```yaml
    nvidia:
      singleGpuPerContainer: yes
      nvidiaDevicePlugin:
        autoGpu: true
```

Note: In the values configuration, gpus -> id is used to segregate the gpu association with the video streams assigned to it.

The implementation logic for this can be found in the file templates/deployments.yaml

## Manging Sources
Source urls per gpu id are picked up from the nvidia streams->url sections

The configuration for the sources are controlled by the **"sourcesTemplate"**

```yaml
      sourcesTemplate: |-
        enable=1
        type=3
        uri=${source_uri}
        num-sources=1
        gpu-id=0
        cudadec-memtype=0 
```

In the Yaml snippet above, the source_uri is replaced by the actual URI string supplied under the nvidia section of the values.yaml file.

The implementation logic for this can be found in file "templates/deepstreamConfigMap.yaml"

### Configuring Sink
Default sink is set to type = 1 [Fake Sink]

```yaml
      sinks:
        - sink: |-
            enable=0
            type=1
            gpu-id=0
            nvbuf-memory-type=0
```

example: You may alter the sinks section as follows in a commad level values config file.

```yaml
  deepstream:
    configs:
      sinks:
      - sink: |-
        enable=0
        type=3 #file sink
        output-file=/opt/output/my.mp4
        gpu-id=0
        nvbuf-memory-type=0
        source-id=0
      - sink: |-
        enable=0
        type=1
        gpu-id=0
        nvbuf-memory-type=0

        ...
```

### Configuring Gies

#### Primary

default primary gie is as follows that can be changed to desired settings.

```yaml
      primarygie: |-
        enable=1
        gpu-id=0
        model-engine-file=/opt/nvidia/deepstream/deepstream-5.0/samples/models/Primary_Detector/resnet10.caffemodel_b4_gpu${gpu_index}_int8.engine
        batch-size=${batch}
        bbox-border-color0=1;0;0;1
        bbox-border-color1=0;1;1;1
        bbox-border-color2=0;0;1;1
        bbox-border-color3=0;1;0;1
        interval=0
        gie-unique-id=1
        nvbuf-memory-type=0
        config-file=/opt/nvidia/deepstream/deepstream-5.0/samples/configs/deepstream-app/config_infer_primary.txt
```

Note: ${batch} is replaced with the number of streams associated with the configuration.
      ${gpu_index} is the gpu id used in the configuration, to uniquely attach streams to configuration file associated with the gpu.

The implementation logic for this can be found in file "templates/deepstreamConfigMap.yaml"

### Secondary

default Secondary gies are as follows that can be changed to desired settings.

```yaml
      secondary_gies:
        - secondary_gie: |-
            enable=1
            model-engine-file=/opt/nvidia/deepstream/deepstream-5.0/samples/models/Secondary_VehicleTypes/resnet18.caffemodel_b16_gpu${gpu_index}_int8.engine
            gpu-id=0
            batch-size=${batch}
            gie-unique-id=4
            operate-on-gie-id=1
            operate-on-class-ids=0;
            config-file=/opt/nvidia/deepstream/deepstream-5.0/samples/configs/deepstream-app/config_infer_secondary_vehicletypes.txt
        - secondary_gie: |-
            enable=1
            model-engine-file=/opt/nvidia/deepstream/deepstream-5.0/samples/models/Secondary_VehicleTypes/resnet18.caffemodel_b16_gpu${gpu_index}_int8.engine
            gpu-id=0
            batch-size=${batch}
            gie-unique-id=5
            operate-on-gie-id=1
            operate-on-class-ids=0;
            config-file=/opt/nvidia/deepstream/deepstream-5.0/samples/configs/deepstream-app/config_infer_secondary_vehicletypes.txt
        - secondary_gie: |-
            enable=0
            model-engine-file=/opt/nvidia/deepstream/deepstream-5.0/samples/models/Secondary_CarMake/resnet18.caffemodel_b16_gpu${gpu_index}_int8.engine
            batch-size=${batch}
            gpu-id=0
            gie-unique-id=6
            operate-on-gie-id=1
            operate-on-class-ids=0;
            config-file=/opt/nvidia/deepstream/deepstream-5.0/samples/configs/deepstream-app/config_infer_secondary_carmake.txt
```
Note: ${batch} is replaced with the number of streams associated with the configuration.
      ${gpu_index} is the gpu id used in the configuration to uniquely attach streams to configuration file associated with the gpu.

The implementation logic for this can be found in file "templates/deepstreamConfigMap.yaml"

### Tracker

default Tracker configuration is as follows that can be changed to desired settings.

```yaml
    tracker: |-
      enable=1
      tracker-width=640
      tracker-height=384
      ll-lib-file=/opt/nvidia/deepstream/deepstream-5.0/lib/libnvds_mot_klt.so
      gpu-id=0
      enable-batch-process=1
      enable-past-frame=0
      display-tracking-id=1
```
The implementation logic for this can be found in file "templates/deepstreamConfigMap.yaml"

### Other parameters

Other default parameters can be found in the chart level values.yaml file under the "deepstream" section.
