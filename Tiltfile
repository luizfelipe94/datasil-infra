# load extensions
load('ext://helm_remote', 'helm_remote')
load('ext://secret', 'secret_yaml_generic')
load('ext://uibutton', 'cmd_button', 'location', 'text_input')
load('ext://deployment', 'deployment_create')

## COMMANDS
cmd_button(name='migrations',
           argv=['make', 'migrate-up'],
           text='Run Migrations',
           location=location.NAV,
           icon_name='waving_hand')

# datasil global secrets
k8s_yaml(secret_yaml_generic(name="datasil-secrets", from_env_file="../datasil-api/.env.k8s"))

## datasil api
# docker_build(
#   "datasil-api", 
#   "../datasil-api/", 
#   dockerfile="../datasil-api/Dockerfile",
#   live_update=[
#     sync("../datasil-api/", "/app")
#   ]
# )
# k8s_yaml("k8s/api/deployment.yaml")
# k8s_resource('datasil-api', port_forwards=5000)

## datasil app
# local_resource(
#   "datasil-app-build",
#   cmd="cd ../datasil-app; npm run build",
#   deps=[
#     "../datasil-app/src/",
#     "../datasil-app/package.json/",
#     "../datasil-app/package-lock.json/",
#     "../datasil-app/public/",
#   ]
# )

# docker_build(
#   "datasil-app",
#   "../datasil-app",
#   dockerfile="../datasil-app/Dockerfile",
#   live_update=[
#     sync("../datasil-app/build/*", "/usr/share/nginx/html")
#   ]
# )

# deployment_create("datasil-app", ports="80")
# k8s_resource('datasil-app', port_forwards=3000)

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

## hive

### hive pg
helm_remote(
  "postgresql",
  release_name="pg-hive",
  repo_url='https://charts.bitnami.com/bitnami',
  set=[
    "image.tag=12",
    "global.postgresql.auth.database=metastore",
    "global.postgresql.auth.postgresPassword=postgres"
  ],
)

### hive metastore
docker_build(
  "hive", 
  "./catalog/hive/",
)
deployment_create("hive", ports=["9083", "10000", "10002"], command="/init-hive.sh")

### hive trino
helm_remote(
  "trino",
  repo_url='https://trinodb.github.io/charts',
  version="0.23.0",
  values="./catalog/trino/values.yaml",
)
k8s_resource('trino-coordinator', port_forwards=[8080])

### superset
# helm_remote(
#   "superset",
#   repo_url='https://apache.github.io/superset',
#   version="0.12.11",
#   set=[
#     "extraSecretEnv.SUPERSET_SECRET_KEY=YOUR_OWN_RANDOM_GENERATED_SECRET_KEY",
#   ]
# )
# k8s_resource('superset', port_forwards=[8088])