#! /bin/sh

script_root=$(cd $(dirname $0) && pwd)

pattern_root=${script_root}
test_root=${pattern_root}/serverspec
spec_dir=${test_root}/spec

if [ "${CONSUL_SECRET_KEY}" == "" ]; then
  CONSUL_SECRET_KEY=$(cat /etc/consul.d/default.json | jq -r .acl_master_token)
fi

CONSUL_SECRET_KEY_ENCODED=$(python -c "import urllib; print urllib.quote('${CONSUL_SECRET_KEY}')")

app_info=$(curl -s http://localhost:8500/v1/kv/cloudconductor/parameters?raw\&token=${CONSUL_SECRET_KEY_ENCODED} | jq .cloudconductor.applications)

run() {
  [[ ! "$-" =~ e ]] || e=1
  [[ ! "$-" =~ E ]] || E=1
  [[ ! "$-" =~ T ]] || T=1

  set +e
  set +E
  set +T

  output="$("$@" 2>&1)"
  status="$?"
  oldIFS=$IFS
  IFS=$'\n' lines=($output)

  IFS=$oldIFS
  [ -z "$e" ] || set -e
  [ -z "$E" ] || set -E
  [ -z "$T" ] || set -T
}

execute_serverspec() {
  role=$1
  event=$2

  if [ -f "${spec_dir}/${role}/${role}_${event}_spec.rb" ]; then
    run sh -c "cd ${test_root}; rake spec['${role}','${event}']"
    if [ ${status} -ne 0 ]; then
      echo "${output}" >&2
      return $status
    fi
  fi
}

role=$1

execute_serverspec ${role} configure || exit $?

if [ "${app_info}" != "null" ];then
  execute_serverspec ${role} deploy || exit $?
fi
