#!/usr/bin/env bash
ansible-playbook -v setup.yml \
	-i production \
	--connection=local \
	--ask-sudo-pass
