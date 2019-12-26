#!/bin/bash 

action=${1}
tf_workspace=${2}

[ $# -eq 0 ] && { 
  echo "Usage: $0 [action: plan/apply/destroy] "; exit 1; 
}

if [ ${2} ]; then
  if [ -f "env/${2}.tfvars" ]; then
    terraform workspace select ${2}
  fi

  if [ "plan" != "${action}" ]; then
    terraform $action -var-file=env/$(terraform workspace show).tfvars --auto-approve
  else
    terraform $action -var-file=env/$(terraform workspace show).tfvars
  fi
else
  # workspace list with trim
  tf_workspaces=$(terraform workspace list | tr -d ' ')

  # string to array with space delimiter
  tf_workspaces=(${tf_workspaces// / })

  for workspace in "${tf_workspaces[@]}"; do
    if [ -f "env/${workspace/\*/}.tfvars" ]; then
      terraform workspace select ${workspace/\*/}
      
      # wait 10 seconds      
      sleep 30
 
      if [ "plan" != "${action}" ]; then
        terraform $action -var-file=env/$(terraform workspace show).tfvars --auto-approve -lock=false &
      else
        terraform $action -var-file=env/$(terraform workspace show).tfvars -lock=false &
      fi
    else
      echo "Omg! There was an error during ${action}"
    fi
  done
fi
