import os
import yaml
import pytest
import testinfra.utils.ansible_runner

testinfra_hosts = testinfra.utils.ansible_runner.AnsibleRunner(
    os.environ["MOLECULE_INVENTORY_FILE"]
).get_hosts("all")


@pytest.fixture(scope="module")
def AnsibleVars(host):
    stream = host.file("/tmp/ansible-vars.yml").content
    return yaml.safe_load(stream)


@pytest.mark.parametrize(
    "name,content",
    [
        (
            "/etc/cloudflared/cloudflaredtest.yml",
            'hostname: "cloudflaredtest.keanu.im"',
        ),
        ("/etc/cloudflared/cloudflaredtest.pem", "BEGIN ARGO TUNNEL TOKEN"),
    ],
)
def test_files(host, name, content):
    f = host.file(name)
    assert f.exists
    if content:
        assert f.contains(content)


@pytest.mark.parametrize("name", ["cloudflared@cloudflaredtest"])
def test_services(host, name):
    service = host.service(name)
    assert service.is_running
    assert service.is_enabled
