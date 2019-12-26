# Terraform with OCI
Oracle Infrastructure Cloud (이하 OCI)에 리소스를 프로비저닝하는 테라폼 프로젝트다.
프로비저닝 할 내용은 다음과 같다.
* IAM Group
* IAM Compartment
* IAM Policy
* Compute
* Network (VCN, Private/Public Subnet, Loadbalancer, Security List, NAT Gateway, Internet Gateway)
* Autonomous Database
* Autonomous Data Warehouse (ADW)
* Autonomous Transaction Processing (ATP)
* Kubernetes Engine (OKE)
* Oracle Funtions (Serverless)

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