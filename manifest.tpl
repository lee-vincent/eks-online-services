---
apiVersion: v1
kind: Namespace
metadata:
  name: ${APP_NAMESPACE}
  labels:
    mesh: ${MESH_NAME}
    gateway: ingress-gw
    appmesh.k8s.aws/sidecarInjectorWebhook: enabled
---
apiVersion: appmesh.k8s.aws/v1beta2
kind: Mesh
metadata:
  name: ${MESH_NAME}
spec:
  namespaceSelector:
    matchLabels:
      mesh: ${MESH_NAME}
---
apiVersion: v1
kind: Service
metadata:
  name: ingress-gw
  namespace: ${APP_NAMESPACE}
  annotations:
    service.beta.kubernetes.io/aws-load-balancer-type: "nlb"
spec:
  type: LoadBalancer
  selector:
    app: ingress-gw
  ports:
    - name: http
      protocol: TCP
      port: 80
      targetPort: 8088      
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: ingress-gw
  namespace: ${APP_NAMESPACE}
spec:
  replicas: 2
  selector:
    matchLabels:
      app: ingress-gw
  template:
    metadata:
      labels:
        app: ingress-gw
    spec:
      containers:
        - name: envoy
          image: ${ENVOY_IMAGE}
          ports:
            - containerPort: 8088