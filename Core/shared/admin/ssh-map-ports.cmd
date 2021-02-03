ssh -L 5000:tasks.devops_portal:80 localhost

ssh -L 5000:tasks.devops_portal:80 -L 5001:tasks.devops_web:9000 -L 5002:tasks.core_consul:8500 -L 5003:tasks.core_vault:8200 localhost
