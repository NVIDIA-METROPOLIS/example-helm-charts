
# Kubernetes (K8) Helm Packaging and Delivery for NVIDIA<small><sup>&reg;</sup></small>

This project documents the NVIDIA<small><sup>&reg;</sup></small> Helm chart templates that provide a standard scafolding for deployment of new GPU-accelerated applications on Kubernetes.

For a quick reference to version 1 standard, please refer to: [standard-values-v1.yaml](standard-values-v1.yaml)

The document below will guide you on how to use VIDIA<small><sup>&reg;</sup></small> Helm chart templates.

## Table of Content

- [Kubernetes (K8) Helm Packaging and Delivery for NVIDIA<small><sup>&reg;</sup></small>](#kubernetes--k8--helm-packaging-and-delivery-for-nvidia-reg-)
  * [Pre-requisites](#pre-requisites)
  * [Kubernetes](#kubernetes)
  * [Helm Charts](#helm-charts)
  * [NVIDIA<small><sup>&reg;</sup></small> Helm starter templates](#nvidia-reg--helm-starter-templates)
  * [Layout of this project](#layout-of-this-project)
  * [Layout of an NVIDIA<small><sup>&reg;</sup></small> standard Helm chart](#layout-of-an-nvidia-reg--standard-helm-chart)
  * [Helm chart samples](#helm-chart-samples)
  * [NVIDIA<small><sup>&reg;</sup></small> Helm values.yaml file](#nvidia-reg--helm-valuesyaml-file)
  * [Values.yaml file layout](#valuesyaml-file-layout)
    + [The Deployment Section](#the-deployment-section)
    + [The Application Section](#the-application-section)
  * [Application PODs](#application-pods)
    + [Containers](#containers)
    + [Service](#service)
    + [Init-Containers](#init-containers)
    + [Persistent volumes](#persistent-volumes)
    + [Other volumes](#other-volumes)
    + [Static Config Map](#static-config-map)
    + [Dynamic Config Maps](#dynamic-config-maps)
    + [Ingress Path](#ingress-path)
  * [Required features to be implemented](#required-features-to-be-implemented)
  * [Packaging](#packaging)
  * [Testing Applications across a firewall](#testing-applications-across-a-firewall)

## Pre-requisites

Dockerized application with some understanding of kubernetes.

## Kubernetes

[Kubernetes](https://kubernetes.io/) is a very popular opensource container deployment and orchestration framework.

Among other things, K8 allows the deployment of software solutions (containerized) at scale, and better management and control of resource utilization.

Application bring up in K8 environments are carried out mostly with a set of manifest files that deals with running the workload (real time & batch) and managing access to applications (APIs/UIs).

More information on K8 can be found at: https://kubernetes.io/docs/concepts/overview/components/

Additional learning resources:

https://www.katacoda.com/courses/kubernetes
https://www.katacoda.com/courses/kubernetes/playground

## Helm Charts

Helm chart is a method to compose, package and deliver all the Kubernetes manifest components of your application as a single unit for final deployment on a Kubernetes cluster.

More details on Helm charts can be found at: https://helm.sh/

Helm chart is the mechanism of deployment on an NVIDIA<small><sup>&reg;</sup></small> environment.

The samples provided in this project support both versions: Helm2 and Helm3.

To be NVIDIA<small><sup>&reg;</sup></small> compatible, an Helm chart should implement a helm package that include specific parameters in its values.yaml file.

Details of the values.yaml file are described bellow.

## NVIDIA<small><sup>&reg;</sup></small> Helm starter templates

If you are starting new on kubernetes and helm please note: An NVIDIA<small><sup>&reg;</sup></small> compatible values.yaml file configuration is necessary.

The starter templates can be found in this project's subfolders.

We highly suggest to use this set of templates for your basic deplyments. But one can supplement these templates as per app-specific requirements.

The following document will discribe in details the usage of the templates.

Using the templates and following the standard structure will minimize the time required to develop an NVIDIA<small><sup>&reg;</sup></small> compatible Helm chart.

## Layout of this project

```
.
├── LICENSE
├── myco-hello-1  <-- First Helm chart sample
├── myco-hello-2  <-- Second Helm chart sample
├── myco-hello-3  <-- Third Helm chart sample
├── nvidia-deepstream-public  <-- Forth Helm chart sample
└── README.md  <-- This document
```

## Layout of an NVIDIA<small><sup>&reg;</sup></small> standard Helm chart

```
.
├── LICENSE
├── README.md
├── Chart.yaml
├── templates
│   ├── configmap.yaml
│   ├── deployment.yaml
│   ├── _helpers.tpl
│   ├── ingress.yaml
│   ├── limitrange.yaml
│   ├── namespace.yaml
│   ├── nvidia-registrykey-secret.yaml
│   ├── persistentvolumeclaim.yaml
│   ├── service.yaml
│   └── ...
└── values.yaml
```

## Helm chart samples

The samples included in this project come with templates that form a scaffolding that can be used by application developers to implement application deployment using Helm charts.

One can deploy each sample after overriding the nvidia.nodes.hostnames and global.nvidia.docker.password from the helm package's values.yaml.

Overriding these parameters can be achieved by creating a new values file ,i.e. commandlevel.values.yaml, holding the modified 'nvidia' and 'global.nvidia' sections.

Here is an example deployment command line using Helm3:

```bash
helm install <deployment name> <helm package> -f commandlevel.values.yaml
```

After deployment of one of the myco-hello samples, one can retrieve the cluster IP and target port for the service using:

```bash
kubectl get services -n myco-hello-1-<hostname>
```
Then test the web server using:

```bash
curl http://<cluster ip>:<target port>
```
Each sample introduces a specific set of features:

1. MyCo-Hello-1

    This is a basic web server example, with no real use for GPU or video stream, that introduces containers.

2. MyCo-Hello-2

    This is also a basic web server example that introduces init-containers and persistent volumes.

3. MyCo-Hello-3

    This is one more basic web server example that introduces static config maps.

4. Nvidia-Deepstream-Public

    This is an example using the Public NVIDIA Deepstream SDK that introduces dynamic config maps.

## NVIDIA<small><sup>&reg;</sup></small> Helm values.yaml file

This values.yaml file is located under root folder of the helm chart.

The purpose of this values.yaml file is to define all the parameters necessary to bring up and run the application in a default setting.

These default parameters can be overriden using arguments on the 'helm install' command line at time of deployment.

For example:

```bash
helm install <deployment name> <helm package> -f commandlevel.values.yaml
```
Command level values are useful to override NVIDIA<small><sup>&reg;</sup></small> standard configuration parameters affecting the current deployment.

Examples of value.yaml files can be found bellow.

## Values.yaml file layout

There are 2 sections that need to be implemented (refer to the values.yaml file in Helm samples). These sections are mandatory.

### The Application Section

Below is the Application Section from the included myco-hello-3 sample Helm chart:

```yaml
# Default values for myco-hello.
# This is a YAML-formatted file.
# NOTE: Only one container can set nvidia.nvidiaDevicePlugin.autoGpu

hello: |-
  hello
  world

pods:
- name: hello
  replicas: 1
  containers:
  - name: hello
#    image: "nvcr.io/isv-myco/hello:2.0.0"
    image: "centos:7"
    command: ["/bin/sh", "-c"]
    args:
    - |
      cd $HTML_ROOT;
      python -m SimpleHTTPServer 80;
    env:
    - name: HTML_ROOT
      value: "/mnt/html"
    ports:
    - containerPort: 80
    volumeMounts:
    - name: hello-volume
      mountPath: /mnt/html
      readOnly: true
    nvidia:
      nvidiaDevicePlugin:
        autoGpu: yes
  volumes:
  - name: hello-volume
    configMap:
      name: hello-config
  configMap:
  - name: hello-config
    dataFromValueAsText:
    - name: index.html
      source: hello
  service:
    type: ClusterIP
    ports:
    - name: http
      port: 80
      targetPort: 80
```

The Application can add any parameters that it sees fit within the values.yaml file.

One example of such application parameters is defining static or dynamic config map data.

The 'pods' parameter is the only mandatory parameter in the application section. This parameter is used to describe your application containers, volumes, config maps, services, etc...

Detailed description of Application PODs and config maps data can be found below.

### The Deployment Section

Below is the Deployment Section from the included myco-hello-3 sample Helm chart:

```yaml
# Below Values must remain compatible with NVIDIA Metropolis Portal
# The following is an example for 1 stream
# An operator should customize the hostnames, GPU IDs and streams before deployment
# When not using nvidiaDevicePlugin, the GPU IDs are assuming PCI BUS order

nvidia:
  version: 1
  nodes:
  - name: "sc-metro-03"
    gpus:
    - id: 0
      streams:
      - url: “rtsp://”
        resolution: “1920 x 1080”
        framerate: 30
        encoding: “H264”
    resources:
      requests:
        cpu: "100m"
        memory: "10Mi"
      limits:
        cpu: "120m"
        memory: "12Mi"

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

The mandatory 'nvidia' parameter describes the nodes, GPUs, video stream URLs and details, as well as compute resource requirements for the video stream workload. This parameter should describe a single video stream as a default deployment. An operator should override this parameter according to the deployment specific video workload using the command line.

For example:

```bash
helm install <deployment name> <helm package> -f commandlevel.values.yaml
```

The mandatory 'global.nvidia.docker' parameter describes the necessary credentials to download the containers. In non-EGX deployment, the password parameter is required, but should not be saved inside the Helm chart's values.yaml file. Doing so would be a security risk.

For example:

```bash
helm install <deployment name> <helm package> --set global.nvidia.password=<NGC_API_KEY>'
```

To get your NGC API key:

1. Log in to your enterprise account on the NGC website: https://ngc.nvidia.com
2. From the user's menu (upper-right corner), select Setup, then click API Key.
3. On the API Key page, click Generate API Key.
4. In response to the warning that your old API Key will become invalid, click CONTINUE to generate the key. Your API key is displayed with examples of how to use it.
5. Click Continue to generate the key. Your API key appears.

## Application PODs

An application workload is defined in the 'pods' section of the values.yaml file.

The following describes few parameters that need to be instantiated to accomplish the desired application function.

Note that an application can be composed of a single POD, or multiple PODs, where a POD is a group of containers.

### Containers

One can add containers to a POD using the following pattern:

```yaml
pods:
- name: hello
  ...
  containers:
  - name: hello-httpd
  ...
```

Each container must define an image source under NVIDIA<small><sup>&reg;</sup></small> NGC or public domain:

```yaml
    image: "nvcr.io/isv-myco/hello-1:2.0.0"
```

If your container image does not include an ENTRYPOINT, one can define or override a default CMD using something like:

```yaml
    command: ["/bin/sh", "-c"]
    args:
    - |
      cd $HTML_ROOT;
      echo hello > index.html;
      python -m SimpleHTTPServer 80;
```

If your container expects environment parameters to be set, one can do so using:

```yaml
    env:
    - name: HTML_ROOT
      value: "/tmp"
```

If your running container is listening to network ports, one can list such ports using:

```yaml 
    ports:
    - containerPort: 80
```

A container port is the port the software within the running docker container listens to. This is not reachable from in the cluster without creating a POD service. You can find details about defining the POD service below in this document.

An application can use one of the following methods of GPU assignment:

- Nvidia Device Plugin: Where whole GPUs are assigned and reserved.
- CUDA_VISIBLE_DEVICES environment variable (default): Useful for embedded systems when multiple applications can share GPUs.

One can instruct the templates for using NVIDIA Device Plugin using the container parameter:

```yaml
    nvidia:
      nvidiaDevicePlugin:
        autoGpu: true
```

The 'autoGpu' parameter instructs the templates to assign the number of GPUs according to the 'nvidia' section of the values.yaml file. This should be used only with the container that implements your GPU model. All other containers can define a static number of GPUs using the following:

```yaml
    nvidia:
      nvidiaDevicePlugin:
        numGpu: 0
```
An application falls in one of below pattern of deployment:

- One containers per Node (default)
- One container per GPU

One can instruct the templates for 'one container per GPU' model using the container parameter:

```yaml
  nvidia:
    singleGpuPerContainer: true
```

### Service

One can define the target network ports of a POD using the following pattern:

```yaml
pods:
- name: hello
  ...
  service:
    type: ClusterIP
    ports:
    - name: http
      port: 80
      targetPort: 80
```

Kubernetes uses cluster IPs and target ports to make container ports reachable within the cluster. The service defines the mapping of container ports to target ports.

In order to reach a service from outside the Kubernetes cluster using any node IP address, but within a local network, one can use 'NodePort' as the service type. Note that reachability using IP address outside of the cluster is usually not needed if defining an inbound path for the application.

If one does use node ports, please note that defining static 'nodePort' ports parameter will break multi-nodes deploment capability because node ports have to be unique within the entire cluster and our templates duplicate your application PODs on each targeted node.

One can list services and allocated ports after deployment using the command line.

For example:

```bash
kubectl get services -n <chart name>-<hostname>
```

### Init-Containers

Init containers are containers that execute once before normal containers. The normal POD containers will not be started before all init-containers have been sucessfully executed.

The init-containers definition follows the same pattern as normal containers, but do not support the 'nvidia' parameters for GPU assignment:

```yaml
pods:
- name: hello
  ... 
  initContainers:
  - name: hello-init
    image: "centos:7"
    command: ["/bin/sh", "-c"]
    args:
    - |
      cd $HTML_ROOT;
      echo hello > index.html;
    env:
    - name: HTML_ROOT
      value: "/mnt/html"
```

### Persistent volumes

Persistent volumes are storage spaces that depend on a Kubernetes storage provider (identified by storage class name).

More information about storage classes can be found at: https://kubernetes.io/docs/concepts/storage/storage-classes/

Here is an example for installing the local-path storage class:

```bash
kubectl apply -f https://raw.githubusercontent.com/rancher/local-path-provisioner/master/deploy/local-path-storage.yaml
```

When using a persistent volume, one should add a note in the application Helm chart's README.md stating that dependency.

Volumes can be mounted on both, init-containers and containers, using the folowing pattern:

```yaml
pods:
- name: hello
  ...
  containers:
  - name: hello-httpd
    ...
    volumeMounts:
    - name: hello-pvc
      subPath: html
      mountPath: /mnt/html
  volumes:
  - name: hello-pvc
    persistentVolumeClaim:
      claimName: hello-pvc
      spec:
        storageClassName: local-path
        accessModes:
        - ReadWriteOnce
        resources:
          requests:
            storage: 100Mi
```

Note the container volume mount point definition as part of the container parameters, and the volumes definition as part of the pod parameters.

In this case, an operator should be notified in the chart's README.md that he has to install this storage class name before deploying this application.

### Other volumes

Other volumes can be defined. Below are a few exmaples of volumes from config map, empty dir and host path:

```yaml
pods:
- name: hello
  ...
  volumes:
  - name: monitoring-volume
    configMap:
      name: monitoring-config
  - name: ds-config-volume
    emptyDir: {}
  - name: host-volume
    hostPath:
      path: /tmp/ds/logs
```

### Static Config Map

One can define a POD config map using the following pattern:

```yaml
hello: |-
  hello
  world

pods:
- name: hello
  ...
  configMap:
  - name: hello-config
    dataFromValueAsText:
    - name: index.html
      source: hello
```

Config maps can use one of the following methods to source the configuration data:

- dataFromValueAsText: source must point to an Helm values parameter, and the value is treated as raw text.
- dataFromValueAsYaml: source must point to an Helm values parameter, and the value is treated as yaml data.
- dataFromFile: source must point to the config file, with a path relative to root of the helm chart.
- data: is the raw yaml data in a format that can be includeed as-is as K8 config map data.

A config map can be consumed by containers as a volume where the data file will be mounted. For example:

```yaml
hello: |-
  hello
  world

pods:
- name: hello
  ...
  containers:
  - hello-httpd
    ...
    volumeMounts:
    - name: hello-volume
      mountPath: /mnt/html
      readOnly: true
  volumes:
  - name: hello-volume
    configMap:
      name: hello-config
  configMap:
  - name: hello-config
    dataFromValueAsText:
    - name: index.html
      source: hello
```

### Dynamic Config Maps

A dynamic config map is a config map with data that includes variables and is interpreted by a custom template that one has to add to the application Helm chart's templates folder.

Consider the following custom config map template. This example shows how to generate a csv file containing the video streams and store it in a config map for each of the gpus:

```yaml
{{- $chart := .Chart -}}
{{- $values := .Values -}}
{{- $appConfig := $values.deepstream.configs }}
{{- range $node := $values.nvidia.nodes }}
   {{- range $gpu_index, $gpu := $node.gpus }}
apiVersion: v1
kind: ConfigMap
metadata:
  annotations:
    app: {{ $chart.Name }}
    app.version: {{ $chart.AppVersion }}
  labels:
    name: streamsconfig-gpu-{{ $gpu_index }}
  name: streamsconfig-gpu-{{ $gpu_index }}
  namespace: {{ $chart.Name }}-{{ $node.name | replace "." "-" }}
data: 
  # generate a CSV file - Note there is a 1 MB limit for the content.
  streamconfig.txt: |-
      {{- range $s1 := $gpu.streams }}
    "{{$s1.url}}", "{{$s1.resolution}}", {{$s1.framerate}}, "{{$s1.encoding}}"
      {{- end }}
   {{- end }}
{{- end }}
```

The generated config map template above would look like (assuming 1 node, 1 gpu, 2 streams):

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  annotations:
    app: myco-myapp
    app.version: 1.0
  labels:
    name: streamsconfig-gpu-1
  name: streamsconfig-gpu-1
  namespace: myco-myapp-sc-metro-03
data:
  # generate a CSV file - Note there is a 1 MB limit for the content.
  streamconfig.txt: |-
    "rtsp://stream1", "1080 x 720", 30, "H264"
    "rtsp://stream2", "1080 x 720", 15, "H264"
---
```

The following is an example values.yaml file that mounts the custom configs, under the pods definition:

```yaml
pods:
- name: deepstream
  ...
  container:
  - name: deepstream-app
  ...
    volumeMounts:
    - name: streamsconfig-gpu-${gpu_index}
      mountPath: /stream-fileloc/
    nvidia:
      singleGpuPerContainer: yes
  volumes:
  - name: streamsconfig-volume-gpu-${gpu_index}
    configMap:
      name: streamsconfig-gpu-${gpu_index}
  ...
```

A more detailed exmaple for dynamic config maps can be found in the Helm chart sample [nvidia-deepstream-public](nvidia-deepstream-public).

### Ingress Path

TBD

## Required features to be implemented

1. The delivered Helm package is expected to implement a Helm configuration values.yaml file compatible with deployment NVIDIA<small><sup>&reg;</sup></small> specifications. Below is an sample for the Deployment specifications:

    ```yaml
    # Below Values must remain compatible with NVIDIA Metropolis Portal
    # The following is an example for 1 stream
    # An operator should customize the hostnames, GPU IDs and streams before deployment
    # When not using nvidiaDevicePlugin, the GPU IDs are assuming PCI BUS order

    nvidia:
      version: 1
      nodes:
      - name: "sc-metro-03"
        gpus:
        - id: 0
          streams:
          - url: “rtsp://”
            resolution: “1920 x 1080”
            framerate: 30
            encoding: “H264”
        resources:
          requests:
            cpu: "100m"
            memory: "10Mi"
          limits:
            cpu: "120m"
            memory: "12Mi"

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

	To validate an application, one should be able to deploy the application using the command (example with Helm3):

	```bash
	helm install <deployment name> <helm package> -f nvidiacompatible-values.yaml
	```
2. If the application includes default configuration parameters in the values.yaml and expects an operator to be able to modify such configuration according to unique deployment parameters, the application should demonstrate a capability to accept/override such default values from the command line (example with Helm3):

	```bash
	helm install <deployment name> <helm package> -f nvidiacompatible-values.yaml -f appconfig-values.yaml
	```
3. Scalable deployment capability

	**Runtime Namespace:**

	An application must run in its own namespace. This is taken care of when using the provided sample templates.

	**Access to storage:**

	If an application uses a Storage Class, the Storage Class Name should be configurable from values file.

	**Access to Web Apps:**

	It is highly recommended to use an Ingress Controller to expose the URI of the application dashboard.

## Packaging

Name your Helm chart <org name>-<app name> in Chart.yaml file.
Add your app and chart versions to the Chart.yaml file as well.

Compose your LICENSE and README.md files.
Optionnaly, you can add a templates/NOTES.txt app-specific template file.

Use the commands:

```bash
helm dependency update <helm chart>
helm package <helm chart>
```

The produced <org name>-<app name>-<version>.tgz is your packaged application Helm chart.

## Testing Applications across a firewall

One can test the application across a firewall using the commands:

```bash
kubectl get services -n <chart name>-<hostname>
ssh -L <local port>:<cluster IP>:<target port> <username>@<hostname>
```

Then open your browser to:

```
http://localhost:<local port>
```

