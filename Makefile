export README_DEPS ?=  docs/ansible.md

-include $(shell curl -sSL -o .build-harness "https://gitlab.com/snippets/1957473/raw"; echo .build-harness)


test:
	molecule test
