Deployment of multimaster FreeIPA controller in Hetzner cloud
=============================================================

This project containes terraform files for deployment of multimaster cluster in Hetzner cloud.
Since for now Hetzner provides cloud in 3 DC this project deployes one server per one DC:
* ipa00 in Nuremberg
* ipa01 in Falkenstein
* ipa10 in Helsinki
That can be extended in a future. Keep in mind [this article](https://www.freeipa.org/page/Deployment_Recommendations#Number_of_servers).

Prerequirements
_______________
* Ansible:
* Terraform:
* Created `floaing_ip`s in Hetzner cloud.

Variables
_________
Some variables have default value (you can redefine them by exporting environment variables starting with `TF_VAR_`).
```
server_type = "cx31-ceph"
remote_user = "root"
ipa00_server_name = "ipa00"
ipa01_server_name = "ipa01"
ipa10_server_name = "ipa10"
ipa00_location = "nbg1"
ipa01_location = "fsn1"
ipa10_location = "hel1"
server_image = "centos-7"
```

Environment variables
_____________________
You need to have a following environment variables:
* `HCLOUD_TOKEN`:
`export HCLOUD_TOKEN="KJKHUH453HH0HIU"`
* `TF_VAR_ssh_key_private`:
`export TF_VAR_ssh_key_private="~/.ssh/id_ed25519"`
* `TF_VAR_ssh_key`:
`export TF_VAR_ssh_key="123456"`
* `TF_VAR_domain`:
`export TF_VAR_domain="example.com"`
* `TF_VAR_ipaadmin_password`:
`export TF_VAR_ipaadmin_password="jaiu34rt8934fa"`
* `TF_VAR_ipadm_password`:
`export TF_VAR_ipadm_password="akfj3984ajfak48"`
