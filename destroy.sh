#!/usr/bin/env bash
ansible-playbook -v \
  destroy.yml \
  -i production \
  --connection=local
