
# Deepstream - industrial image inspection Helm chart
This helm chart is a base line deepstream industrial image inspection implementation with following key config parameters

* localhostpath: Dir path on the local host where image streams (direcotries) are placed.
* width: width of the image
* height: height of the image
* batch_size: to denote the batch size
* no_streams: to denote the number of streams supplied.
* streams - Dictionary where value is list of streams in 'stream: <dir-name>'  for each stream entry. This should match to the no_streams param

E.g.;
```yaml
nvidia:
  version: 1
  nodes:
  - name: "node-name"
    localhostpath: /home/metroadmin/mop_scripts/test_image_streams
    width: 512
    height: 512
    batch_size: 10
    no_streams: 10
    gpus:
    - id: 0
      streams:
      - stream: stream10
      - stream: stream9
      - stream: stream8
      - stream: stream7
      - stream: stream6
      - stream: stream5
      - stream: stream4
      - stream: stream3
      - stream: stream2
      - stream: stream1

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