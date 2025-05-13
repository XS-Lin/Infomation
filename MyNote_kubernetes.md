# kubernetes #

## CKAD ##

### 有用な情報 ###

認定試験内容
中心的な概念: Core Concepts (13%)
構成: Configuration (18 %)
マルチコンテナポッド: Multi-Container Pods (10%)
観察可能性: Observability (18%)
ッド設計: Pod Design (20%)
サービス＆ネットワーキング: Services & Networking (13%)
状態の永続性: State Persistence (8%)

[Candidate Handbook](https://docs.linuxfoundation.org/tc-docs/certification/lf-candidate-handbook)
[Frequently Asked Questions](https://docs.linuxfoundation.org/tc-docs/certification/faq-cka-ckad-cks)

[kubernetes cheatsheet](https://kubernetes.io/docs/reference/kubectl/cheatsheet/)
[kubernetes kubectl-commands](https://kubernetes.io/docs/reference/generated/kubectl/kubectl-commands)
[github kubernetes](https://github.com/kubernetes/kubernetes)

[ckad](https://training.linuxfoundation.org/ja/certification/certified-kubernetes-application-developer-ckad/)

## 練習 ##

### エフェメラルボリューム ###

- MountしなくてもNodeからPodに作られるファイルを取得できる。

~~~powershell
# GKEクラスターの詳細情報表示
gcloud container clusters list --location asia-east1-a
gcloud container clusters describe my-first-cluster-1 --location asia-east1-a

# gcloud components install gke-gcloud-auth-plugin 必要があれば（kubectl実行のため、初回のみ）
gcloud container clusters get-credentials --zone asia-east1-a my-first-cluster-1

# Node情報取得
kubectl get nodes # gke-my-first-cluster-1-default-pool-fc2135dc-m5vb
kubectl describe nodes gke-my-first-cluster-1-default-pool-fc2135dc-m5vb

# Pod情報取得
kubectl describe pods my-pod
kubectl get pods # job-1-nlhn5
kubectl get pod job-1-nlhn5 -o yaml
kubectl describe pods job-1-nlhn5


# 実行中のコンテナに入る。実行中でない場合はエラー。
kubectl exec -it job-1-nlhn5 -- /bin/bash 
# error: cannot exec into a container in a completed pod; current phase is Succeeded

kubectl get pod job-1-nlhn5 -o jsonpath='{.metadata.uid}' # 6d2e354c-b323-4c97-a10c-565babf7787b

# Pod削除
kubectl delete pod job-1-nlhn5
~~~

~~~bash
# 管理者権限が必要
sudo ls  /var/lib/kubelet/pods/6d2e354c-b323-4c97-a10c-565babf7787b
sudo ls -la /var/lib/kubelet/pods/6d2e354c-b323-4c97-a10c-565babf7787b/containers/perl-1/

# Pod削除後は参照不可となる
sudo ls -la  /var/lib/kubelet/pods/6d2e354c-b323-4c97-a10c-565babf7787b 
~~~
