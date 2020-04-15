import sys
import os

if sys.version_info[0] < 3:
    raise Exception("Must be using Python 3")


def collect_pem_files(coll, **kwargs):
    files = []
    for i in coll:
        name = i["tunnel_name"]
        pem_file = f"/etc/cloudflared/{name}.pem"
        files.append(pem_file)
    return files


def collect_pem_files_by_name(coll, **kwargs):
    files = {}
    for i in coll:
        name = i["tunnel_name"]
        files[name] = f"/etc/cloudflared/{name}.pem"
    return files


def reduce_stat_exists(stat_results, **kwargs):
    all_exist = True
    for result in stat_results:
        all_exist = all_exist and result["stat"]["exists"]
    return all_exist


def reduce_stat_exists_by_name(stat_results, **kwargs):
    files = {}
    for result in stat_results:
        name = os.path.splitext(os.path.basename(result["item"]))[0]
        files[name] = result["stat"]["exists"]
    return files


class FilterModule(object):
    def filters(self):
        return {
            "collect_pem_files": collect_pem_files,
            "collect_pem_files_by_name": collect_pem_files_by_name,
            "reduce_stat_exists": reduce_stat_exists,
            "reduce_stat_exists_by_name": reduce_stat_exists_by_name,
        }
