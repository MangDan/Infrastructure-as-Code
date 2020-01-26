# Ansible with OCI (Hands-On)
Oracle Infrastructure Cloud (이하 OCI)에 리소스를 프로비저닝하는 테라폼 프로젝트다.

본 실습은 Oracle Cloud Infrastructure (이하 OCI)에서 Ansible을 활용하여 서버 구성 및 프로비저닝을 직접 해볼 수 있도록 구성되었습니다.

---

## 실습 환경 (그림 한장)
- Ansible Control Server
- Ansible Target Server

## 사전에 미리 제공되는 환경 파일
- ~/.oci/config
- ~/.oci/oci_api_key.pem
- ~/.oci/oci_api_key_public.pem
- ~/.ssh/id_rsa

## 실습 환경 구성
1. RSA Key Pair 다운로드


2. Ansible Control Server 접속

    #### Windows (Putty)
    Putty를 통해 접속 방법 가이드

    #### macOS Terminal
    ```
    $ ssh -i ~/.ssh/id_rsa user1@132.145.95.114
    ```

3. python, pip, virtualenv 설치 확인
    ```
    $ python --verion

    $ pip --version

    $ virtualenv --version
    ```

4. virtualenv 환경 생성 및 가상환경 실행
    ```
    $ virtualenv oci-ansible

    $ source ~/oci-ansible/bin/activate
    ```

5. Python 가상환경에 ansible 설치 및 확인
    ```
    $ (oci-ansible) $ pip install ansible

    $ (oci-ansible) $ ansible --version
    ```

6. OCI Python SDK 설치
    Ansible OCI Module에서는 OCI Python SDK를 사용하여 OCI에 접근합니다. 따라서 Ansible OCI Module을 사용하기 위해서는 OCI Python SDK 설치가 필요합니다.

    ```
    $ (oci-ansible) pip install oci
    ```

## Ansible OCI Module 다운로드, 설치, 접속 테스트
Ansible OCI Module은 Ansible Galaxy에서 Role로 제공되고 있으며, GitHub에서도 다운로드 받을 수 있습니다. 본 실습에서는 Ansible Galaxy에서 다운로드 받아서 설치를 진행합니다.
> 현재 OCI에서 Ansible 모듈로 제공되는 서비스는 다음과 같습니다.
> - Block Volume
> - Compute
> - Container Engine for Kubernetes Service (OKE)
> - Database (including support for Autonomous Transaction Processing and Autonomous Data Warehouse Services)
> - Edge Services (DNS, WAF)
> - IAM
> - Load Balancing
> - Networking
> - Object Storage
> - File Storage
> - Email Delivery
> - Search

1. Ansible OCI Module 다운로드 (from Ansible Galaxy)
    ```
    $ (oci-ansible) ansible-galaxy install oracle.oci_ansible_modules
    ```

<details>
 <summary>참고) Ansible OCI Module from GitHub</summary>

 ```
$ (oci-ansible) git clone https://github.com/oracle/oci-ansible-modules.git
 ```

</details>

2. Ansible OCI Module 패키지 설치
    OCI Ansible Module Python 패키지를 설치합니다. 패키지는 일반적으로 Python 인터프리터의 site-packages 디렉토리에 설치됩니다.
    > 보통 다음과 같은 경로에 설치됩니다.  
    > /home/{사용자}/oci-ansible/lib/python2.7/site-packages

    ```
    $ (oci-ansible) ~/.ansible/roles/oracle.oci_ansible_modules/install.py
    ```

3. Ansible OCI Module에서 제공하는 Dynamic Inventory를 사용하여 접속 테스트
    ```
    $ (oci-ansible) ansible-inventory -i .ansible/roles/oracle.oci_ansible_modules/inventory-script/oci_inventory.py --list
    ```

    아래와 같이 Compartment이름과 하위 Host IP 주소를 확인할 수 있습니다.
    ```
    "meetup-compartment-111": {
        "hosts": [
            "140.238.1.142"
        ]
    }
    ```

4. 위에서 확인한 Compartment명을 이용해서 해당 Host에 Ping 테스트를 수행합니다.
    ```
    ansible -i .ansible/roles/oracle.oci_ansible_modules/inventory-script/oci_inventory.py {compartment명} -u {사용자명} -m ping --private-key=~/.ssh/id_rsa
    ```

    접속할때마다 key를 입력하지 않도록 known_hosts에 등록하기 위해 yes를 입력합니다.
    ```
    The authenticity of host '140.238.1.158 (140.238.1.158)' can't be established.
    ECDSA key fingerprint is SHA256:88V1g6wPQ7pVuDLtKRl2E5XGzFdd1TpMITZcPPQm1SM.
    ECDSA key fingerprint is MD5:01:dc:0b:02:d3:e9:aa:a3:d9:e4:f5:61:3d:f5:59:a5.
    Are you sure you want to continue connecting (yes/no)? yes
    ```

    PING 테스트 (성공한 경우)
    ```
    140.238.1.158 | SUCCESS => {
        "ansible_facts": {
            "discovered_interpreter_python": "/usr/bin/python"
        }, 
        "changed": false, 
        "ping": "pong"
    }
    ```

## 서버 구성
이 실습에서 만일 Web을 구성할 경우에는 Security-List와 Firewall 설정을 해야 한다. 이 부분을 미리 어떻게 구성할 지 고민해보자.. 
- Terraform에서 VCN 만들때 Security List에 추가
- Ansible 돌릴 때 서버에 Firewall에 허용할 IP 추가...

이제 실제로 서버를 구성해보자. 여기서 구성할 내용은 다음과 같다.
??? 아직 무엇을 할 지 모르겠지만, Ansible Galaxy에서 찾아서 한다.
후보군
- Kafka
- Web 개발 환경
- WebLogic
- ???

## Oracle Autonomous Data warehouse Pronisioning

1. 실습용 소스 다운로드
    > git clone https://github.com/MangDan/Infrastructure-as-Code/ansible

2. tenancy_ocid 확인
메모합니다.
    ```
    $ cat ~/.oci/config

    [DEFAULT]
    tenancy=ocid1.tenancy.oc1..aaaaaaaaczntdhqaqsnfxfykqymelumoplqe5d6amg7ecsaykku6ukiwc37q
    user=ocid1.user.oc1..aaaaaaaaecuviw4zez73bajvj4a7ccdkxkpz7axmcu5yjobtqny3dw753nda
    key_file=~/.oci/oci_api_key.pem
    fingerprint=48:1a:98:8c:cd:f6:63:4b:fb:4d:8d:26:44:aa:37:f6
    region=ap-seoul-1
    ```

3. Compartment 생성 및 Compartment ID 확인
  * compartment.yml playbook
    ```yml
    ---
    # Compartment Module
    - name: Compartment Module
      connection: local
      hosts: localhost
      tasks:
        - name: Create a compartment
          oci_compartment:
            parent_compartment_id: '{{ tenancy_id }}'
            name: ansible_compartment 
            description: Compartment for Ansible handson 
          register: result
          tags:
            - create_compartment
        - name: Delete compartment
          oci_compartment:
            compartment_id: '{{ compartment_id }}'
            state: absent
          register: result
          tags:
            - delete_compartment
        - name: Get details of a root compartment
          oci_compartment_facts:
            compartment_id: '{{ tenancy_id }}'
            name: '{{ compartment_name }}'
            fetch_subcompartments: True 
          register: result
          tags:
            - get_compartments
        - name: Print result
          debug:
            msg: '{{ result }}'
          tags:
            - always
    ...
    ```

  * Compartment 생성 
    ```
    $ ansible-playbook -i .ansible/roles/oracle.oci_ansible_modules/inventory-script/oci_inventory.py playbooks/compartment.yml -t create_compartment -e "{ tenancy_ocid }}"
    ```

  * Compartment 생성 결과, Compartment ID 메모
    ```
    TASK [Print result] ****************************************************************************
    ok: [localhost] => {
        "msg": {
            "changed": true, 
            "compartment": {
                "compartment_id": "ocid1.tenancy.oc1..aaaaaaaagxn3didg4xptrk53xjrw3fvlvle5ma7a5s7vtk7vqbkruwzeubpa", 
                "defined_tags": {
                    "Oracle-Tags": {
                        "CreatedBy": "oracle.testa1@gmail.com", 
                        "CreatedOn": "2020-01-10T07:24:05.257Z"
                    }
                }, 
                "description": "Compartment for Ansible handson", 
                "freeform_tags": {}, 
                "id": "ocid1.compartment.oc1..aaaaaaaap4wtylopltkzs274zppyalavydi6h33jkgrqdp44unsw4edyukia", 
                "inactive_status": null, 
                "is_accessible": true, 
                "lifecycle_state": "ACTIVE", 
                "name": "ansible_compartment", 
                "time_created": "2020-01-10T07:24:05.319000+00:00"
            }, 
            "failed": false
        }
    }
    ```

4. Oracle Autonomous Data Warehouse 생성
**adw.yml playbook**
```yml
---
# Create Autonomous Data Warehouse
- name: Autonomous Data Warehouse Module
  connection: local
  hosts: localhost
  tasks:
    - name: Create Autonomous Data Warehouse
      oci_autonomous_data_warehouse:
        compartment_id: '{{ compartment_id }}'
        admin_password: 'WelCome123##'
        data_storage_size_in_tbs: 1
        cpu_core_count: 2
        db_name: 'ansible-adw'
        display_name: 'ansible-adw'
        license_model: 'LICENSE_INCLUDED'
        freeform_tags:
          owner: 'dan.donghu.kim@gmail.com'
        wait: False
        state: 'present'
      register: result
      tags:
        - create_adw
    # Delete Autonomous Data Warehouse
    - name: Delete Autonomous Data Warehouse
      oci_autonomous_data_warehouse:
        autonomous_data_warehouse_id: '{{ adw_id }}'
        state: 'absent'
      register: result
      tags:
        - delete_adw
    - name: Get Aunonomous Data Warehouse details of compartment
      oci_autonomous_data_warehouse_facts:
        compartment_id: '{{ compartment_id }}'
      register: result
      tags:
        - get_adw_details
    # Print ADW instance result
    - name: Print ADW instance result
      debug:
        msg: '{{ result }}'
      tags:
        - always
```

ADW 생성  
```
$ ansible-playbook -i .ansible/roles/oracle.oci_ansible_modules/inventory-script/oci_inventory.py playbooks/adw.yml -t create_adw -e "compartment_id={compartment ID}"
```











테라폼의 Module을 사용하여 각 리소스를 모듈화 하였고, Workspace를 사용해서 Multi Oracle Tenancy 프로비저닝이 가능하도록 작성되었다.

## 프로젝트 구조
OCI용 테라폼 프로젝트의 디렉토리 구조는 다음과 같다.
```
.
├── oci
│   ├── evn
│   │   ├── {tenancy}.{region}.tfvars
│   │   └── danoci.ap-seoul-1.tfvars
│   ├── provider.tf
│   ├── main.tf
│   ├── vars.tf
│   ├── terraform.tfstate.d
│   ├── modules
│   │   ├── adb
│   │   │   ├── main.tf
│   │   │   ├── datasources.tf
│   │   │   ├── vars.tf
│   │   │   └── outputs.tf
│   │   ├── compartment
│   │   │   ├── main.tf
│   │   │   ├── datasources.tf
│   │   │   ├── vars.tf
│   │   │   └── outputs.tf
│   │   ├── compute
│   │   │   ├── main.tf
│   │   │   ├── datasources.tf
│   │   │   ├── vars.tf
│   │   │   └── outputs.tf
│   │   ├── container
│   │   │   ├── main.tf
│   │   │   ├── datasources.tf
│   │   │   ├── vars.tf
│   │   │   └── outputs.tf
│   │   ├── dbsystem
│   │   │   ├── main.tf
│   │   │   ├── datasources.tf
│   │   │   ├── vars.tf
│   │   │   └── outputs.tf
│   │   ├── functions
│   │   │   ├── main.tf
│   │   │   ├── datasources.tf
│   │   │   ├── vars.tf
│   │   │   └── outputs.tf
│   │   ├── group
│   │   │   ├── main.tf
│   │   │   ├── datasources.tf
│   │   │   ├── vars.tf
│   │   │   └── outputs.tf
│   │   ├── policy
│   │   │   ├── main.tf
│   │   │   ├── datasources.tf
│   │   │   ├── vars.tf
│   │   │   └── outputs.tf
│   │   └── vcn
│   │       ├── main.tf
│   │       ├── datasources.tf
│   │       ├── vars.tf
│   │       └── outputs.tf
│   └── run_tf.sh
└──
```

***

### 테라폼 설치
기본적으로 테라폼 설치가 필요하다.
macOS에서는 간단히 Homebrew를 사용해서 설치할 수 있다.
```
$ brew install terraform
```

Windows에서의 설치는 아래 잘 정리된 블로그 페이지를 참조한다.
> https://www.vasos-koupparis.com/terraform-getting-started-install/

### 테라폼 Workspace 생성
테라폼 Workspace명은 환경 구성파일 (tfvars)의 이름과 동일하게 구성하며, **{tenancy}-{region}** 형태로 구성한다. 아래는 예시이다.
* Tenancy : danoci
* Region : ap-seoul-1

#### danoci-ap-seoul-1 라는 이름의 Workspace 생성
```
$ terraform workspace new danoci-ap-seoul-1
```

#### 생성한 Workspace 확인
```
$ terraform workspace list

  default
* danoci-ap-seoul-1
```

### 환경 파일
env 폴더안에 workspace 이름과 동일하게 tfvars 파일을 만든다.
env 폴더안에 danoci.ap-seoul-1.tfvars 파일의 내용을 보면 다음과 같다.
```
tenancy_ocid     = "ocid1.tenancy.oc1......"
compartment_ocid = ""
user_ocid        = "ocid1.user.oc1......"
fingerprint      = "48:1a:98:8c:cd:f6:63:4b:f...."
private_key_path = "~/.oci/oci_api_key.pem"
region           = "ap-seoul-1"
home_region      = "ap-seoul-1"
ssh_public_key   = "~/.ssh/id_rsa.pub
```

tenancy_ocid, user_ocid, fingerprint, private_key, ssh_public_key, region등의 정보는 OCI Console에서 확인할 수 있다.

### 모듈 공통 구성 파일
provider.tf에는 oci 관련 provider 설정이 있으며, vars.tf 안에 각 모듈별 설정이 포함되어 있다. 리소스 설정 변경은 vars.tf에서 한다.

### 테라폼 실행
그럼 생성한 workspace를 선택하고 테라폼을 실행해보겠다. 

#### Workspace 선택
먼저 workspace를 선택한다.
```
$ terraform workspace select danoci-ap-seoul-1
```

#### 현재 Workspace 확인
현재 선택된 workspace를 보려면 다음과 같이 show 명령어를 사용한다.
```
$ terraform workspace show
danoci-ap-seoul-1
```

#### 테라폼 계획 (Plan)
테라폼 적용(apply)전에 plan을 실행해서 수행될 작업에 대한 계획을 확인한다.
```
$ terraform plan -var-file="env/$(terraform workspace show).tfvars"
```

#### 테라폼 적용 (Apply)
plan 결과가 예상한 계획과 일치하면, apply를 통해서 실제 인프라에 반영한다.
```
$ terraform apply -var-file="env/$(terraform workspace show).tfvars"
```

#### 테라폼 적용 결과
오류없이 완료되면 아래와 같은 메시지를 볼 수 있다. 
```
Apply complete! Resources: 30 added, 0 changed, 0 destroyed.
```

> Workspace별 상태 파일(tfstate)는 terraform.tfstate.d 폴더에 각 Workspace별로 생성된다.

### run_tf.sh
등록된 테라폼 workspace들을 순차적으로 실행하기 위한 스크립트를 작성했다. 

> 보통 workspace를 선택하고 실행하면 해당 workspace에 lock을 걸기 때문에 다른 workspace를 동시에 실행하기는 어렵다. 이럴땐 -lock=false 옵션을 주면 된다. 

#### 1개의 특정 workspace에서만 실행
사용 방식은 다음과 같다.  
1개의 workspace만 실행할 경우 (action은 init, plan, apply)
```
$ ./run_tf.sh {action} {workspace명}
```

#### 모든 workspace에서 실행
등록된 모든 workspace를 실행할 경우 (action은 init, plan, apply)
```
$ ./run_tf.sh {action}
```

> 백그라운드로 실행하게 해서 병렬로 실행해봤더니, TLS handshake timeout이 발생한다. 각 OCI Tenancy별로 API 통신을 할 때 핸드쉐이크하는 과정이 있어서 그런거 같은데, wait을 주면 해결될 것 같긴 하지만, 하여튼 병렬로 실행하는 것은 좀 더 확인해봐야 할 거 같다.

### 좀 더 자세한 내용은 아래 블로그 참조
* [[Terraform] Terraform with OCI 1탄](https://mangdan.github.io/terraform-with-oci-1/)
* [[Terraform] Terraform with OCI 2탄](https://mangdan.github.io/terraform-with-oci-2/)














# Oracle Cloud Infrastructure Ansible Modules

## About

Oracle Cloud Infrastructure Ansible Modules provide an easy way to create and provision resources in Oracle Cloud Infrastructure (OCI) through Ansible. These modules allow you to author Ansible playbooks that help you automate the provisioning and configuring of Oracle Cloud Infrastructure services and resources, such as Compute, Load Balancing, Database, and other Oracle Cloud Infrastructure services.

**Services supported**
- Block Volume
- Compute
- Container Engine for Kubernetes Service (OKE)
- Database (including support for Autonomous Transaction Processing and Autonomous Data Warehouse Services)
- Edge Services (DNS, WAF)
- IAM
- Load Balancing
- Networking
- Object Storage
- File Storage
- Email Delivery
- Search

The OCI Ansible modules are built using the [Oracle Cloud Infrastructure Python SDK](https://docs.us-phoenix-1.oraclecloud.com/Content/API/SDKDocs/pythonsdk.htm). The OCI Ansible modules honour the [SDK configuration](https://docs.us-phoenix-1.oraclecloud.com/Content/ToolsConfig.htm) when available.

## Installation

There are two methods for installation:

#### 1) Installation Script (Preferred Method)

See the [getting started guide](https://docs.cloud.oracle.com/iaas/Content/API/SDKDocs/ansiblegetstarted.htm) for instructions on using the installer script to install the Oracle Cloud Infrastructure Ansible Modules and its prerequisites in your host/Ansible controller node.

![](docs/quick-install.gif)

#### 2) Installation from Ansible Galaxy

Oracle Cloud Infrastructure Ansible Modules can also be downloaded from [Ansible Galaxy](https://galaxy.ansible.com/oracle/oci_ansible_modules) and used as roles.

Note: This method does not support the ansible-doc command.

1. [Install Ansible](https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html)

2. Install the modules:

  ``` bash
  $ ansible-galaxy install oracle.oci_ansible_modules
  ```

3. [Install OCI Python SDK](https://oracle-cloud-infrastructure-python-sdk.readthedocs.io/en/latest/installation.html#downloading-and-installing-the-sdk):

  ``` bash
  $ pip install oci
  ```

**Galaxy Example Playbook using Roles**


    - hosts: localhost
      roles:
        - { role: oracle.oci_ansible_modules }
      tasks:
        - name: Get all the buckets in the namespace
          oci_bucket_facts:
            namespace_name: "{{ namespace_name }}"
            compartment_id: "{{ compartment_id }}"

## Samples

This project includes a catalog of Oracle Cloud Infrastructure Ansible module samples that illustrate using the modules to carry out common infrastructure provisioning and configuration tasks.
The samples are organized in groups associated with Oracle Cloud Infrastructure services under [the samples directory on GitHub](https://github.com/oracle/oci-ansible-modules/tree/master/samples).


Begin by reviewing the Readme.md file that you will find in each sample's root directory.

## Documentation

Documentation to get started and details about prerequisites, installation and configuration instructions, can be found [here](https://docs.cloud.oracle.com/iaas/Content/API/SDKDocs/ansible.htm).

FAQs, technical design documents and development HOWTOs, and web documentation for the OCI Ansible modules can be found [here](https://oracle-cloud-infrastructure-ansible-modules.readthedocs.io).

## Help

See the ["Questions or Feedback”](https://docs.cloud.oracle.com/iaas/Content/API/SDKDocs/ansible.htm) section.

## Changes

See [CHANGELOG](https://github.com/oracle/oci-ansible-modules/blob/master/CHANGELOG.md).

## Contributing

`oci-ansible-modules` is an open source project. See [CONTRIBUTING](https://github.com/oracle/oci-ansible-modules/blob/master/CONTRIBUTING.md) for details.

Oracle gratefully acknowledges the contributions to `oci-ansible-modules` that have been made by the community.

## Known Issues

You can find information on any known issues with OCI [here](https://docs.us-phoenix-1.oraclecloud.com/Content/knownissues.htm) and known issues with the OCI Ansible Modules under the “Issues” tab of this project's [GitHub repository](https://github.com/oracle/oci-ansible-modules).

## License

Copyright (c) 2018, 2019, Oracle and/or its affiliates.

This software is made available to you under the terms of the GPL 3.0 license or the Apache 2.0 license.

See [LICENSE.txt](https://github.com/oracle/oci-ansible-modules/blob/master/LICENSE.txt) for more details.
