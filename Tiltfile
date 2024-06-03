# load extensions
load('ext://helm_remote', 'helm_remote')
load('ext://secret', 'secret_yaml_generic')

# datasil global secrets
k8s_yaml(secret_yaml_generic(name="datasil-secrets", from_env_file="../datasil-api/.env.k8s"))

# postgres
helm_remote(
  'postgresql',
  repo_url='https://charts.bitnami.com/bitnami',
  set=[
    "global.postgresql.auth.database=datasil",
    "global.postgresql.auth.postgresPassword=postgres"
  ],
)
k8s_resource('postgresql', port_forwards=[5434])

# minio
helm_remote(
  'minio',
  repo_url='https://charts.min.io',
  set=[
    "rootUser=rootuser",
    "rootPassword=rootpass123",
    "replicas=1", 
    "resources.requests.memory=128M", 
    "mode=standalone", 
    "persistence.enabled=false",
    "buckets[0].name=datasil,buckets[0].policy=none"
  ],
)
k8s_resource('minio', port_forwards=[9001])

# datasil-api
docker_build(
  "datasil-api", 
  "../datasil-api/", 
  dockerfile="../datasil-api/Dockerfile",
  live_update=[
    sync("../datasil-api/", "/app")
  ]
)
k8s_yaml("k8s/api/deployment.yaml")
k8s_resource('datasil-api', port_forwards=5000)